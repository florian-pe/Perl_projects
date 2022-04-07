#!/usr/bin/perl

use strict;
use warnings;
use v5.10;
use List::Util qw(sum min max);

my @positions = <> =~ /(\d+)/g;
# dd \@positions;

my %fuel_cost;

sub sum_integers_to {
    (($_[0] + 1) * $_[0]) / 2
}

for my $pos (min(@positions) .. max(@positions)) {

    $fuel_cost{$pos} = sum map { $pos - $_ > 0
                                ? $pos - $_
                                : $_ - $pos } @positions;
}

my $min_fuel_pos = (sort { $fuel_cost{$a} <=> $fuel_cost{$b} } keys %fuel_cost)[0];
say "Part 1: ", $fuel_cost{ $min_fuel_pos };


%fuel_cost = ();

for my $pos (min(@positions) .. max(@positions)) {

    $fuel_cost{$pos} = sum  map { sum_integers_to($_) }
                            map { $pos - $_ > 0
                                ? $pos - $_
                                : $_ - $pos } @positions;
}



$min_fuel_pos = (sort { $fuel_cost{$a} <=> $fuel_cost{$b} } keys %fuel_cost)[0];
say "Part 2: ", $fuel_cost{ $min_fuel_pos };









