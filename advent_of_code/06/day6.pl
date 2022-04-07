#!/usr/bin/perl

use strict;
use warnings;
use v5.10;

chomp(my @population = split ",", <>);

# say "Initial state:\t", join ",", @population;

my $count = 0;

# for (1 .. 18) {
# for (1 .. 80) {
for (1 .. 256) {

    @population = map { $_ > 0 ? $_ - 1 : 6 } @population;
    push @population, (8) x $count;
    $count = grep { $_==0 } @population;

#     say "After $_ day", $_>1 ? "s" : "", ":\t", join ",", @population;
}

say "Part 1: ", scalar @population;


__END__

