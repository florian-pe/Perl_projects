#!/usr/bin/perl

use strict;
use warnings;
use File::Copy;

sub save_original_subs;

use v5.10;
local $,="\n"; 
local $\="\n"; 
# folder containing a copy of the original subtitle files
my $original_subs = "./.original_subs";
my ($s, $e);	# season, episode
my $vid_name;
my ($sub_name, $sub_ext);
my $sub_number;
my $new_sub_name;

my $video_file    = qr/ \. (?i) (mp4 | mkv | avi | m4v) $ /x;
my $subtitle_file = qr/ \. (?i) (srt | vtt | sub | idx) $ /x;

my $serie_episode_format = qr/ S (\d+) \.? E (\d+) /xi;


my @videos = map {chomp; $_} grep { /$video_file/ } qx( ls );
my @subs = map {chomp; $_} grep { /$subtitle_file/ } `ls`;

save_original_subs(@subs);

sub get_video_name {
	my $video = shift;
	my ($ext) = $video =~ $video_file;

	if (defined $ext) {
		return $video =~ s/\.$ext$//r;
	}
}

sub get_sub_ext {
	my $subtitle = shift;
	my ($ext) = $subtitle =~ $subtitle_file;
	my $name;

	if (defined $ext) {
		$name = $subtitle =~ s/\.$ext$//r;
	}
	return ($name, $ext);
}

# make a copy of the original subtitle files
sub save_original_subs {
    my @subs = @_;
    mkdir $original_subs;
    foreach my $sub (@subs) {
        if (! -e "$original_subs/$sub") {
#             copy($sub, "$original_subs/$sub");
        }
    }
}



foreach my $vid (@videos) {

	$sub_number = 1;

	($s, $e) = $vid =~ $serie_episode_format;

	if (not defined $s) {
		print "season number not found in :\n$vid\n";
		next;
	}
	elsif (not defined $e) {
		print "episode number not found in :\n$vid\n";
		next;
	}

	$s =~ s/^0+//;
	$e =~ s/^0+//;

	$vid_name = get_video_name($vid);

	foreach my $sub (@subs) {
		if ($sub =~ m/ S? 0? $s [.XE] 0? $e (?: \D | $ ) /xi) {

			($sub_name, $sub_ext) = get_sub_ext($sub);

			# don't rename correctly named subtitle file
			next if $sub_name =~ m/ ^ \Q$vid_name\E (?: _ \d+)? $ /x;

			# don't replace existing subtitle file
			do {
				$new_sub_name = $vid_name
							. ($sub_number > 1 ? "_$sub_number" : "")
							. "." . $sub_ext;
				$sub_number++;
			} while (-e $new_sub_name);

			print "$sub \n-> $new_sub_name\n";
			say "rename", $sub, $new_sub_name;
			rename $sub, $new_sub_name;
		}
	}
}



