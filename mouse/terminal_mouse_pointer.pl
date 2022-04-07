#!/usr/bin/perl

# requires sudo

use strict;
use warnings;
use autodie;
use Term::ReadKey;

my $fh;
my $bytes;
my ($button, $delta_X, $delta_Y);
my ($X, $Y);
my $button_right;
my $button_left;
my ($wchar,$hchar) = GetTerminalSize();
$wchar--;

open $fh, "<", "/dev/input/mice";
binmode $fh;
$|=1;	# $OUTPUT_AUTOFLUSH

($X, $Y) = (int($wchar/2), int ($hchar/2) );
coordinates($X, $Y);

while(1){
	read $fh, $bytes, 3;
	($button,$delta_X,$delta_Y) = unpack "h c c", $bytes;

	$button_right = (ord $button & 64) ? 1 : 0;
	$button_left = ((ord $button & 8) and (ord $button & 1)) ? 1 : 0;

#	printf "left: %d right: %d X:%4d   Y:%4d\n", $button_left, $button_right, $delta_X, $delta_Y;

	$X += $delta_X / 10;
	$Y -= $delta_Y / 20;

	$X = 0 if $X < 0;
	$Y = 0 if $Y < 0;

	$X = $wchar if $X > $wchar;
	$Y = $hchar if $Y > $hchar;

	coordinates($X, $Y);
}

close $fh;


sub coordinates {
	my ($width, $heigth) = @_;
	local $\="";
	system "clear";
	print "\n" x $heigth;
	print " " x $width;
	print "X";
}

