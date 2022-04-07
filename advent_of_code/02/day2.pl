#!/usr/bin/perl

use strict;
use warnings;
use v5.10;

my @lines = <>;
my ($position, $depth) = (0, 0);
my ($command, $x);

foreach (@lines) {
    ($command, $x) = split;

    if    ($command eq "forward") {
        $position += $x
    }
    elsif ($command eq "up") {
        $depth -= $x
    }
    elsif ($command eq "down") {
        $depth += $x
    }
    else { die "unrecognized command \"$command\"" }
}

# say "Part 1: position = ", $position, ", depth = ", $depth;
say "Part 1: ", $position * $depth;

($position, $depth) = (0, 0);
my $aim = 0;

foreach (@lines) {
    ($command, $x) = split;

    if    ($command eq "forward") {
        $position += $x;
        $depth += $aim * $x;
    }
    elsif ($command eq "up") {
        $aim -= $x
    }
    elsif ($command eq "down") {
        $aim += $x
    }
    else { die "unrecognized command \"$command\"" }
}

say "Part 2: ", $position * $depth;

