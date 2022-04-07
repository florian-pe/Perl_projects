#!/usr/bin/perl -l

use strict;
use warnings;

my %hash= (
word         => ['doc', 'docx', 'odt'],
excel        => ['xls', 'xlsx', 'ods'],
documents    => ['pdf', 'ps', 'epub','djvu'],
presentation => ['ppt', 'pptx', 'pps', 'odp'],
txt          => ['txt','md'],
pictures     => ['jpg', 'jpeg', 'png', 'tif', 'swf', 'bmp', 'gif', 'svg'],
audio        => ['mp3', 'wav', 'wma','opus', 'm4a'],
video        => ['srt', 'vtt', 'wmv', 'avi', 'mp4', 'mkv', 'webm', 'ts', 'mpg', 'mpeg', 'mov'],
# web_pages    => ['htm', 'html', 'xml', 'css', 'js'],
web_pages    => ['htm', 'html', 'xml', 'css'],
archives     => ['rar', 'zip', 'tar\.gz', 'tar\.bz2', 'tar\.lz', 'tar', 'tgz', 'tar\.lz\.sig', '7z', 'deb'],
exe          => ['exe', 'dll', 'sys'],
scripts      => [ 'sh','pl','pm', 'pl6', 'php', 'c', 'o', 'js', 'py', 'pyc', 'lisp'],
links        => [ 'torrent', 'm3u', 'm3u8'],
autocad      => [ 'dwg', 'dwt', 'dst', 'dgn'],
data         => ['db', 'csv']
);

my %files;

foreach my $category (keys %hash){
	foreach my $extension ($hash{$category}->@*) {
		push $files{$category}->@*, grep {/\.$extension$/i} `ls`;
	}
}

# there are 2 invocations possible: ./script.pl and perl script.pl
$0 =~ s|^\./||;

# remove this current script file from the list of files to move
for (my $i = 0; $i < $files{scripts}->@* ; $i++) {
	chomp  $files{scripts}->@[$i];
	splice $files{scripts}->@*, $i, 1 if $files{scripts}->@[$i] eq $0;
}

foreach my $category (keys %hash) {
	print "\nCATEGORY $category" unless $files{$category}->@* == 0;
	mkdir ($category) unless $files{$category}->@* == 0; #uncomment this line

	foreach my $files_to_move ($files{$category}->@*) {
		chomp $files_to_move;
		print $files_to_move;
		system("mv","-v","$files_to_move","$category/");  #uncomment this line
	}
}	
