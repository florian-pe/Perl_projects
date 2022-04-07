#!/usr/bin/perl 

use strict;
use warnings;
use autodie;
use Encode qw(decode);
@ARGV = map { decode "UTF-8", $_ } @ARGV;
use HTML::Entities;
no warnings "utf8";
# binmode STDOUT, ":utf8";
# binmode STDERR, ":utf8";
binmode STDOUT, ':encoding(UTF-8)';
binmode STDERR, ':encoding(UTF-8)';

my @files;
my @urls;
my @titles;
my @videos;
my %seen;
my @output;
my $url;

sub usage {
print <<"EOF";
  usage: 
        vidextract youtube_page.html
EOF
}

if (not @ARGV) {
	usage();
	exit;
}

while (my $arg = shift @ARGV) {
	if ($arg =~ m/^(?:-{0,2}h|-{0,2}help)$/ ) {
		usage();
		exit;
	}
	elsif (-e $arg) {
		push @files, $arg;
	}
}

my %page_type = (
           video => 0,
        research => 0,
        playlist => 0,
         channel => 0,
);

foreach (@files) {

# 	open FH, "<:utf8", $_;
	open my $FH, "<:encoding(UTF-8)", $_;

	@urls   = ();
	@titles = ();
	@videos = ();
	%page_type = map { $_ => 0 } keys %page_type;

	<$FH>;						# read and discard first line
	my $saved_from = <$FH>;		# read second line of the file

	if    ($saved_from =~ m# youtube\.com/ watch #x ) {
		$page_type{video} = 1;
	}
	elsif ($saved_from =~ m# youtube\.com/ playlist #x ) {
		$page_type{playlist} = 1;
	}
	elsif ($saved_from =~ m# youtube\.com/ results #x ) {
		$page_type{research} = 1;
	}
	elsif ($saved_from =~ m# youtube\.com/.*?/.*?/ videos #x ) {
		$page_type{channel} = 1;
	}

	$,="\n";
	$\="\n";

# 	print %page_type;

	# https://www.youtube.com/c/pbsspacetime/videos
	# CHANNEL VIDEOS (the videos section of a channel)
	if ($page_type{channel}) {
		while (<$FH>) {
			next unless / <a\ id="video-title"
							\ class="yt-simple-endpoint
							\ style-scope
							\ ytd-grid-video-renderer"
							\ aria-label="
						/x;
			chomp;
			if (m/ ^ .*? title="(?<title>.*?)" .*? href="(?<url>.*?)" /x ) {
				push @videos, $+{url} . " " .  decode_entities($+{title});
			}
		}
	}
	# https://www.youtube.com/playlist?list=PLsPUh22kYmNCLrXgf8e6nC_xEzxdx4nmY
	# PLAYLIST
	elsif ($page_type{playlist}) {
		while (<$FH>) {
			chomp;
			if ( m/ <(?:span|a) \ id="video-title"
						\ class="(?:yt-simple-endpoint \ )? style-scope
						\ ytd-playlist-video-renderer"
						(?:\ href= .*?)?
						\ aria-label= .*? title=" (?<title>.*?) "
				/x){
# 				print decode_entities($+{title});
				push @titles, decode_entities($+{title});
			}
			elsif ( m/ <a\ id="thumbnail"
						\ class="yt-simple-endpoint
						\ inline-block
						\ style-scope
						\ ytd-thumbnail"
						\ aria-hidden="true"
						\ tabindex="-1"
						\ rel="null .*? href=" (?<url>.*?) "
					/x) {
				push @urls, $+{url} =~ s/&.*//r;
			}
		}
	}

	# https://www.youtube.com/results?search_query=muon&sp=EgIIBA%253D%253D
	# RESEARCH RESULTS
	elsif ($page_type{research}) {
		while (<$FH>) {
			next unless / <a\ id="video-title"
							\ class="yt-simple-endpoint
							\ style-scope
							\ ytd-video-renderer"
						/x;
			chomp;
			if (m/ ^ .*? title="(?<title>.*?)" .*? href="(?<url>.*?)" /x) {
				push @videos, $+{url} . " " .  decode_entities($+{title});
			}
		}
	}

	# https://www.youtube.com/watch?v=O4Ko7NW2yQo
	# SUGGESTIONS THAT APPEAR ON A VIDEO PAGE
	elsif ($page_type{video}) {
		while (<$FH>) {
			chomp;
			if ( m/ <span\ id="video-title"
						\ class="style-scope
						\ ytd-compact-video-renderer"
						\ aria-label= .*? title=" (?<title>.*?) "
				/x){
				push @titles, decode_entities($+{title});
				
			}
			elsif ( m/ <a\ id="thumbnail"
						\ class="yt-simple-endpoint
						\ inline-block
						\ style-scope
						\ ytd-thumbnail"
						\ aria-hidden="true"
						\ tabindex="-1"
						\ rel="nofollow .*? href=" (?<url>.*?) "
					/x) {
				push @urls, $+{url} =~ s/&.*//r;
			}
		}
	}

	close $FH;

	if (@videos) {					# channel and research
		foreach (@videos) {
			($url) = (split)[0];
			push @output, $_ if !$seen{$url}++
		}
	}
	elsif (@urls and @titles) {		# playlist and suggestions
		for (my $i=0; $i < @urls; $i++) {
			push @output, "$urls[$i] $titles[$i]" if !$seen{ $urls[$i] }++
		}
	}
# 	else { die "no \@videos nor (\@urls and \@titles)\n" }
}

print @output;

# print join "\n", @urls;
# print join "\n", @titles;



