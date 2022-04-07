#!/usr/bin/perl
use strict;
#use warnings;
use IPC::Open2;

binmode WRITE, ":utf8";

my %videos;

exit unless @ARGV;
my $keywords = join "+", @ARGV;
my $webpage = "https://www.youtube.com/results?search_query=" . $keywords;
my @file = `chromium --headless --disable-gpu --dump-dom $webpage`;

my $selection = "";
my $i = 0;
my ($url, $title);

# extract video titles
my @titles = grep /<a id="video-title" class="yt-simple-endpoint style-scope ytd-video-renderer" title=/, @file;
foreach (@titles) {
	chomp;
	s/.*?title="(.*?)".*/$1/;

	# HTML Ampersand Character Codes
	s/&amp;/&/g;
	s/&#39;/'/g;
	s/&quot;/"/g;
}

# extract video urls
my @urls = grep /<a id="video-title" class="yt-simple-endpoint style-scope ytd-video-renderer" title=/, @file;
foreach (@urls) {
	chomp;
	s/^.*?href="(.*?)".*/$1/;
	s|^|https://www.youtube.com|;

	# HTML Ampersand Character Codes
	s/&amp;/&/g;
}

# required to conserve playlist order
# number prefix will be removed before printing
foreach (@titles) {
	chomp;
	$i++;
	s/^/$i /;
}

for (my $i=0; $i < @urls; $i++) {
	$videos{$titles[$i]} = $urls[$i];
}

#my $pid = open2('READ', 'WRITE', 'dmenu', '-i', '-l', '30');
	
# remove number prefix before printing
$,="\n";
$\="\n";
#print WRITE map {s/^\d+ //r} sort {$a <=> $b} keys %videos;
print map {s/^\d+ //r} sort {$a <=> $b} keys %videos;
#close WRITE;
#waitpid($pid, 0);

#chomp ($selection = <READ>);
#close READ;

# remove number prefix from the hash
foreach (keys %videos) {
	$url = $videos{$_};
	$title = s/^\d+ //r;
	$videos{$title} = $url;
	delete $videos{$_};
}
#system "mpv $videos{$selection} > /dev/null 2> /dev/null &" if $selection ne "";


