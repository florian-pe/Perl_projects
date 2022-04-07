#!/usr/bin/perl

use strict;
use warnings;
use v5.10;
use List::Util qw(sum);

chomp(my @population = split ",", <>);
my %population;
$population{$_}++ for @population;

my $count = 0;

# for (1 .. 18) {
for (1 .. 80) {
    %population = (6 => ($population{0} // 0) + ($population{7} // 0),
                  map { ($_ > 0 ? $_ - 1 : 6) => $population{$_} } 1 .. 6, 8);

    $population{8} = $count;
    $count = $population{0} // 0;
}

say "Part 1: ", sum values %population;

$count = 0;
%population = ();
$population{$_}++ for @population;

# for (1 .. 80) {
for (1 .. 256) {

    %population = (6 => ($population{0} // 0) + ($population{7} // 0),
                  map { ($_ > 0 ? $_ - 1 : 6) => $population{$_} } 1 .. 6, 8);

    $population{8} = $count;
    $count = $population{0} // 0;
}

say "Part 2: ", sum values %population;

