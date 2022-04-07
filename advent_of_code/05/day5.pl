#!/usr/bin/perl

use strict;
use warnings;
use v5.10;

my @vents;

while (<>) {
    my @nums = /(\d+),(\d+)\s+->\s+(\d+),(\d+)/;
    push @vents, { orig => [ @nums[0,1] ], to => [ @nums[2,3] ] }
}

# dd \@vents;

sub orthogonal {
    grep { ($_->{orig}[0] == $_->{to}[0]) || ($_->{orig}[1] == $_->{to}[1]) } @_
}

sub _range {
    my ($a, $b) = @_;
    $a <= $b ? $a .. $b : reverse $b .. $a
}

sub zip {
    my ($a, $b) = @_;
    map { [ $a->[$_], $b->[$_] ] } 0 .. $a->$#*
}

sub make_map {
    my $map;

    for my $vent (@_) {

        # x1 = x2
        if ($vent->{orig}[0] == $vent->{to}[0]) {

            my $x = $vent->{orig}[0];

            for my $y (_range($vent->{orig}[1], $vent->{to}[1])) {
                $map->[$x][$y]++
            }
        }
        # y1 = y2
        elsif ($vent->{orig}[1] == $vent->{to}[1]) {

            my $y = $vent->{orig}[1];

            for my $x (_range($vent->{orig}[0], $vent->{to}[0])) {
                $map->[$x][$y]++
            }
        }
        # diagonal
        else {

            my @points = zip([_range($vent->{orig}[0], $vent->{to}[0])],
                             [_range($vent->{orig}[1], $vent->{to}[1])]);

            for my $point (@points) {
                $map->[ $point->[0] ][ $point->[1] ]++
            }
        }
    }
    $map
}

my $count;

$count = grep { defined && $_ >= 2 }
         map { $_->@* if ref eq "ARRAY" }
         make_map(orthogonal @vents)->@*;

say "Part 1: $count";

$count = grep { defined && $_ >= 2 }
         map { $_->@* if ref eq "ARRAY" }
         make_map(@vents)->@*;

say "Part 2: $count";

# dd $map;
# dd grep { !(($_->{orig}[0] == $_->{to}[0]) || ($_->{orig}[1] == $_->{to}[1])) } @vents;


sub print_map {
    my $map = shift;
    for my $y (keys $map->@*) {
        for my $x (keys $map->[0]->@*) {
            print $map->[$x][$y] // "."
        }
        say ""
    }
}


# print_map(make_map(orthogonal @vents));
# print_map(make_map(@vents));



__END__

