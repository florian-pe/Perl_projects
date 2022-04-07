#!/usr/bin/perl

# filetypes + logic
# additional info + order of columns
# sort by which field
# filename patterns + logic

# ft=video,audio; pat=// && // (// || //)

# info + order of columns, sort, "patterns" = logic combination of filetype, filename regex

# size, info specific to filetype (time, page), filename

# ls --> filter filetypes --> filter patterns --> get_info + set in right order --> sort --> print

# change module filter, remove $filter->filter->new(\%hash); remove func(); use filter() directly ??

# NOT IN ORDER
# london@archlinux:~/Videos_INFORMATICS/haskell/Haskell for Imperative Programmers
# $ vlt
#
# start

use strict;
use warnings;
use filter;
# no warnings "utf8";

use Encode qw(decode);
@ARGV = map { decode "UTF-8", $_ } @ARGV;

unless (@ARGV) {
	print <<~"EOF";
	  filter [-v] FILETYPES [c|color] [sort] [l|long] [time] [not] [and|or] [--] [PATTERNS]

	     FILETYPES [a/audio|v/video|p/pic|t/txt|s/sub|arc|scr/script|h/html|part|pdf|doc]
	EOF
	exit;
}

open my $IN,  '<&:encoding(UTF-8)', *STDIN;
# open my $IN,  '<&', *STDIN;


open my $OUT, '>&:encoding(UTF-8)', *STDOUT;

my %params = (
	color => -t STDOUT ? 1 : 0,
	patterns => [],
	file_types => [],
);

while (defined(my $arg = shift @ARGV)) {

	# FILE TYPES
	if ($arg =~ /^arcs?$/) {
		push $params{file_types}->@*, "archive";
	}
	elsif ($arg =~ /^(?:p|pics?)$/) {
		push $params{file_types}->@*, "picture"
	}
	elsif ($arg =~ /^(?:s|subs?)$/) {
		push $params{file_types}->@*, "subtitle"
	}
	elsif ($arg =~ /^(?:t|te?xts?)$/) {
		push $params{file_types}->@*, "text"
	}
	elsif ($arg =~ /^(?:h|htmls?)$/) {
		push $params{file_types}->@*, "html"
	}
	elsif ($arg =~ /^(?:xmls?)$/) {
		push $params{file_types}->@*, "xml"
	}
	elsif ($arg =~ /^(?:v|videos?)$/) {
     	push $params{file_types}->@*, "video"
	}
	elsif ($arg =~ /^(?:a|audios?)$/) {
     	push $params{file_types}->@*, "audio"
	}
	elsif ($arg =~ /^(?:scrs?|scripts?)$/) {
		push $params{file_types}->@*, "script"
	}
	elsif ($arg eq "part") {
		push $params{file_types}->@*, "part"
	}
	elsif ($arg eq "pdf") {
		push $params{file_types}->@*, "pdf"
	}
	elsif ($arg eq "doc") {
		push $params{file_types}->@*, "document"
	}


	# need logic programming to handle the cases ? (time only for video and audio, pages only for pdf)
	# need a query language ?


	# ADDITIONAL INFORMATION
	elsif ($arg =~ /^-{0,2}(?:l|long|long-?list)$/ ) {	# for all
		$params{longlist} = 1;
	}
	elsif ($arg eq "time") {	# for audio and video only
		$params{time} = 1;
	}
	elsif ($arg =~ /pages?/ ) {	# for pdf only
		$params{pages} = 1;
	}
	elsif ($arg eq "sort" ) {
		$params{sort} = 1;
	}
	elsif ($arg =~ /^(?:c|colors?)$/ ) {	# force colors
		$params{color} = 1;
	}

	# LOGIC
	#
	elsif ($arg eq "and" ) {	# logic applies to FILETYPES  or patterns ??
		$params{and} = 1;
	}
	elsif ($arg eq "or" ) {
		$params{or} = 1;
	}
	elsif ($arg eq "not" ) {
		$params{not} = 1;
	}
	elsif ($arg eq "-v" ) {	# logic applies to FILETYPES   or patterns ?
		$params{invert} = 1;
	}


	# PATTERNS
	elsif ($arg eq "--" ) {
		while (defined (my $pat = shift @ARGV)) {
			push $params{patterns}->@*, qr/$pat/i;
		}
		last;
	}

	else {
		push $params{patterns}->@*, qr/$arg/i;
	}
}


# my $filter = filter->new(\%params);
# print $OUT $filter->func( ! -t STDIN ? <$IN> : <$LS> );

opendir my $DIR, "./";
# binmode $DIR, ":encoding(UTF-8)"; # can not binmode on DIRHANDLE ??

print $OUT filter(\%params, ! -t STDIN ? <$IN> : readdir $DIR );

close $DIR;
close $IN;
close $OUT;


