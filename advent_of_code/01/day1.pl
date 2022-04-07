#!/usr/bin/perl

use strict;
use warnings;
use v5.10;
use List::Util qw(reduce);

sub sum {
    my $acc = 0;
    $acc += shift while @_;
    $acc;
}

my ($prev, $curr);
my $count = 0;

# $prev = <>;
# 
# while (defined($curr = <>)) {
#     $count++ if $curr - $prev > 0;
#     $prev = $curr;
# }

my @lines = <>;

$prev = $lines[0];
for (my $i=1; $i < @lines; $i++) {
    $curr = $lines[$i];
    $count++ if $curr > $prev;
    $prev = $curr;
}


say "Part 1: $count";

$count = 0;
my ($A, $B);

for (my $i=0; $i < @lines-3; $i++) {
    $A = sum @lines[$i   .. $i+2];
    $B = sum @lines[$i+1 .. $i+3];
    $count++ if $B > $A;
#     last;
}

say "Part 2: $count";



__END__

