#!/usr/bin/perl

use strict;
use warnings;
use v5.10;

# chomp (my $grid->@*=<>);
my $grid;
my $y=0;
while (<>) {
    chomp;
    $grid->[$y]->@* = split "", $_;
    $y++;
}

my $X = $grid->[0]->@*;
my $Y = $y;

# say for $grid->@*;
# say $grid->[0];

# dd $grid;

# my $X = $grid->[0]->@*;

sub step {
    for my $y (0 .. $Y) {
        for my $x (0 .. $X) {

            $grid->[$y][$x]++;
        }
    }
}



































