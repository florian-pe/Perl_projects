#!/usr/bin/perl

use strict;
use warnings;
use v5.10;
use Tie::IxHash;

my %display = (
    0 => { a => 1, b => 1, c => 1, d => 0, e => 1, f => 1, g => 1 },
    1 => { a => 0, b => 0, c => 1, d => 0, e => 0, f => 1, g => 0 },
    2 => { a => 1, b => 0, c => 1, d => 1, e => 1, f => 0, g => 1 },
    3 => { a => 1, b => 0, c => 1, d => 1, e => 0, f => 1, g => 1 },
    4 => { a => 0, b => 1, c => 1, d => 1, e => 0, f => 1, g => 0 },
    5 => { a => 1, b => 1, c => 0, d => 1, e => 0, f => 1, g => 1 },
    6 => { a => 1, b => 1, c => 0, d => 1, e => 1, f => 1, g => 1 },
    7 => { a => 1, b => 0, c => 1, d => 0, e => 0, f => 1, g => 0 },
    8 => { a => 1, b => 1, c => 1, d => 1, e => 1, f => 1, g => 1 },
    9 => { a => 1, b => 1, c => 1, d => 1, e => 0, f => 1, g => 1 },
);

my %segment_number;
# tie my %segment_number, "Tie::IxHash"; # no need ?

$Data::Dumper::Sortkeys = 0;

for my $num (sort keys %display) {

    my $segment_count = grep { $_==1 } values $display{$num}->%*;

    if (! ref $segment_number{ $segment_count }) {
        tie my %hash, "Tie::IxHash";
        $segment_number{ $segment_count } = \%hash;
    }

    $segment_number{ $segment_count }->{$num} = 1;
}

# dd \%segment_number;
# say %segment_number;
# say $segment_number{5}->%*;

my @damaged_display;

my @entries;

while (<>) {
    my (@signals, @digits);
    (@signals[0..9], @digits) = / ([a-g]+) /gx;

    for (@signals, @digits) {
        $_ = join "", sort split "", $_;
    }

    push @entries, { signals => \@signals, digits => \@digits };
}
dd \@entries;
















__END__



0 => { a b c e   f g },
1 => {     c     f   },
2 => { a   c d e   g },
3 => { a   c d f   g },
4 => { b   c d f     },
5 => { a b   d   f g },
6 => { a b   d e f g },
7 => { a   c     f   },
8 => { a b c d e f g },
9 => { a b c d f   g },












