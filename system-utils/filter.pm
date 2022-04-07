
package filter;

# change module filter, remove $filter->filter->new(\%hash); remove func(); use filter() directly ??
#
# tie %filetype_re so that when querying multiple values @filetype_re{qw(video audio)},
# it returns one regex combining both video and audio

use strict;
use warnings;
use Exporter 'import';
# our @EXPORT = qw(filter);
our @EXPORT = qw(filter %filetype_re);
# our @EXPORT_OK = qw(filter %filetype_re);
# use Tie::Scalar; # loading make script too long ???

use utf8;					# this script contains unicode characters
no warnings "utf8";			# warning "Wide character ..."
use feature "fc";
use File::LsColor qw(ls_color);
use Tie::IxHash;
# use Encode qw(decode encode);
use Encode;

# my %filetype_re = (
our %filetype_re = (
	archive		=> qr/\.(?i:rar|zip|gz|tar\.bz2|tar\.lz|tar|tgz|tar\.lz\.sig|7z|deb|iso)$/,
	picture		=> qr/\.(?i:png|jpg|jpeg|gif|webp|svg|bmp|mpb|pgm)$/,
	subtitle	=> qr/\.(?i:srt|vtt|sub|idx)$/,
	text		=> qr/\.(?i:t(?:xt)?|markdown|md|json|ya?ml)$/,
	html		=> qr/(?i)\.html$/,
	xml			=> qr/(?i)\.xml$/,
	video		=> qr/\.(?i:mp4|mkv|webm|avi|ts|mpe?g|flv|wmv|m4v)$/,
	audio		=> qr/\.(?i:mp3|m4a|webm|weba|opus|aac|wav|wma|ogg|flac)$/,
	script		=> qr/\.(?i:sh|p[lm]?6?|xs|[choy]|py|php|li?sp|l?hs|js|lua|sml|ad[bs])$/,
	part		=> qr/(?i:\.part|\.crdownload)$/,
	pdf			=> qr/(?i)\.pdf$/,
	document	=> qr/\.(?i:pdf|djvu|docx?|odt|xlsx?|chm|html|xml)$/,
);

my %defaults = (
	color => 0,
	sort => 0,
	patterns => [],
	file_types => [],
	# PREFIXED FILE INFO
	longlist => 0,	# human readable file size
	time => 0,		# duration of audio or video file
	pages => 0,		# number of pages for pdf files ,
	# FILE TYPES LOGIC
	invert => 0,
	and => 0,
	or => 1,
	not => 0,
);

# my $sort_slurp = do {
my $sort_slurp = sub {
	my $self = shift;
	if ($self->{longlist}) {
		if ($self->{sort}) {	# numeric sort by bitsize, then convert bitsize to human readable with units (K,M,G,T)
			sub {
				map {
					my ($size, $file) = split /\s+/, $_, 2;
					$size = human_readable_size($size);
					sprintf "%5s   %s", $size, $file
				}
				sort { (split /\s+/, $a, 2)[0] <=> (split /\s+/, $b, 2)[0] } @_
			}
		}
		else {
			sub {
				map { my ($size, $file) = split /\s+/, $_, 2;
					$size = human_readable_size($size);
					sprintf "%5s   %s", $size, $file } @_
			}
		}
	}
	elsif ($self->{time}) {
		if ($self->{sort}) {
			sub { map { s/^ 00h/    /r } sort by_time @_ }
		}
		else {
			sub { map { s/^ 00h/    /r } @_ }
		}
	}
	else {
		if ($self->{sort}) {
# 			sort { fc($a) cmp fc($b) } @_
			sub { sort version_sort @_ }
# 			sub { sort { fc($a) cmp fc($b) } @_ }
		}
		else {
			sub { @_ }
		}
	}
};


# map { $longlist ? (stat)[7] . "\t$_" : $time ? duration($_) . "\t$_" : "$_" } 
# my $file_info = do {
my $file_info = sub {
	my $self = shift;
	if ($self->{longlist}) {
		sub { map { (stat)[7] . "\t$_" } @_ }
	}
	elsif ($self->{time}) {
		sub { map { duration($_) . "\t$_" } @_ }
	}
	elsif ($self->{pages}) {
		sub {
			map {
				my $file = quotemeta;
				my ($pages) = map { m/^Pages:\s+(\d+)/ } grep {/^Pages/} `pdfinfo $file`;
				sprintf "%-8d%s\n", $pages, $_
			} @_
		}
	}
	else {
		sub { @_ } 
	}
};

sub new {
	my $class = shift;
	my %hash = %defaults;
	foreach my $key (keys $_[0]->%*) {
		$hash{ $key } = $_[0]->{$key};
	}

	$hash{file_types}->@* = map { $filetype_re{$_} } $hash{file_types}->@*;

	$hash{file_types}->@* = qr/^/ unless $hash{file_types}->@*;	# for consistency. "filter --" do the same as cat(1)
	$hash{patterns}->@*   = qr/^/ unless $hash{patterns}->@*;

	$sort_slurp = $sort_slurp->(\%hash);
	$file_info = $file_info->(\%hash);

	bless \%hash, $class;
}

sub by_time {
	my ($hour, $min, $sec);

	($hour, $min, $sec) = $a =~ m/^ (\d\d)h (\d\d)m (\d\d)s/;
	my $time_a = 3600 * $hour + 60 * $min + $sec;

	($hour, $min, $sec) = $b =~ m/^ (\d\d)h (\d\d)m (\d\d)s/;
	my $time_b = 3600 * $hour + 60 * $min + $sec;

	$time_a <=> $time_b
}

sub human_readable_size {
	my $size = shift;

	if ($size < 1024){
		return $size
	}
	elsif ($size < 1024**2) {
		return int(0.5 + $size/1024)      . "K"
	}
	elsif ($size >= 1024**2) {
		return int(0.5 + $size/(1024**2)) . "M"
	}
}


sub version_sort {	# sort version_sort LIST
	my ($c,$d) = ($a,$b);
	my ($elem_a, $elem_b);
	
	while (1) {
		if ($c =~ m/^\d/) {
			if ($d =~ m/^\d/) {
				($elem_a) = $c =~ m/^(\d+)/;
				($elem_b) = $d =~ m/^(\d+)/;
				if ($elem_a != $elem_b) {
					return $elem_a <=> $elem_b
				}
				else {
					$c =~ s/^\d+//;
					$d =~ s/^\d+//;
				}
			}
			elsif ($d =~ m/^\D/) {
				return -1; # numbers before letters
			}
			elsif (length $d == 0) {
				return 1;	# shortest first
			}
		}
		elsif ($c =~ m/^\D/) {
			if ($d =~ m/^\d/) {
				return 1; # numbers before letters
			}
			elsif ($d =~ m/^\D/) {
				($elem_a) = $c =~ m/^(\D+)/;
				($elem_b) = $d =~ m/^(\D+)/;
				if ($elem_a ne $elem_b) {
# 					return $elem_a cmp $elem_b
					return fc($elem_a) cmp fc($elem_b)
				}
				else {
					$c =~ s/^\D+//;
					$d =~ s/^\D+//;
				}
			}
			elsif (length $d == 0) {
				return 1;	# shortest first
			}
		}
		elsif (length $c == 0) {
			if (length $d == 0) {
				return 0
			}
			else {
				return -1;	# shortest first
			}
		}
	}
}

sub reduce_and {
	foreach (@_) {
		return 0 if $_ == 0;
	}
	return 1;
}

sub reduce_or {
	foreach (@_) {
		return 1 if $_ == 1;
	}
	return 0;
}

sub grep_patterns_logic {
	tie my %input_files, "Tie::IxHash";
	my $patterns = shift;
	my ($and, $or, $not) = (shift,shift,shift);


	while (defined (my $file = shift @_)) {
		foreach my $pat ($patterns->@*) {
			# make that the regex patterns specified with or without accent match filenames with accents
			if ($file =~ $pat or
                $file =~ tr/àÀâÂäÄçÇéÉèÈêÊëËîÎïÏôÔöÖùÙûÛüÜÿŸ/aAaAaAcCeEeEeEeEiIiIoOoOuUuUuUyY/r =~ $pat) {
				push $input_files{$file}->@*, 1;
			}
			else {
				push $input_files{$file}->@*, 0;
			}
		}
	}

	if ($and) {
		return grep {     reduce_and $input_files{$_}->@* } keys %input_files unless $not;
		return grep { not reduce_and $input_files{$_}->@* } keys %input_files if $not;
	}
	elsif ($or) {
		return grep {     reduce_or $input_files{$_}->@* } keys %input_files unless $not;
		return grep { not reduce_or $input_files{$_}->@* } keys %input_files if $not;
	}
}



sub duration {
	my $file = quotemeta $_[0];
 	my ($duration) = map { s/^(\d\d):(\d\d):(\d\d)\.(\d\d)/$1h $2m $3s/r }
                     grep { ($_)=/Duration: (\d\d:\d\d:\d\d\.\d\d),/ }
                     `ffprobe -hide_banner $file 2>&1`;
	sprintf "%12s", $duration;
}

sub filter {
	my $arguments = shift;
	my %params = %defaults;
	foreach my $key (keys $arguments->%*) {
		$params{ $key } = $arguments->{$key};
	}

	$params{file_types}->@* = map { $filetype_re{$_} } $params{file_types}->@*;

	$params{file_types}->@* = qr/^/ unless $params{file_types}->@*;	# for consistency. "filter --" do the same as cat(1)
	$params{patterns}->@*   = qr/^/ unless $params{patterns}->@*;

	# can create a conflict if the same script uses this package twice ?
	my $sort_slurp = $sort_slurp->(\%params);
	my $file_info = $file_info->(\%params);

	return
          map { $params{color} ? ls_color(s/^/ /r) . "\n" : encode("UTF-8","$_\n")}
		  $sort_slurp->(
		  $file_info->(
# 		  grep { -f $_ }
		  grep_patterns_logic $params{patterns}, @params{qw(and or not)},# select files matching specified PATTERNS
		  grep_patterns_logic $params{file_types}, 0, 1, $params{invert},	# select files of the right FILETYPES
		  map { s|^\./||; chomp; $_ }	# only need it for STDIN / find, no need for readdir
		  map { decode("UTF-8", $_) }
		  @_
          ));
}


1;


