#!/usr/bin/perl

use strict;
use warnings;
use v5.10;

# [0369]
# [147]
# [258]

my $regex = qr{
    ^ [0-9] $ (?<=[048]) | ^[0-9]{2,}$ (?<= [13579][26] | [02468][048])
}x;

# below 10 --> 0, 4, 8
# above 10 --> if 10**1 digit if odd,  then div by 4 if unit digit is 2 or 6
# above 10 --> if 10**1 digit if even, then div by 4 if unit digit is 0, 4 or 8

my $allgood=1;

for (0..1000000) {
    print "$_\r";
    if ($_ =~ $regex) {
        if ($_ % 4 != 0) {
            say "$_\tnot divisible by 4";
            $allgood=0;
        }
    }
    else {
        if ($_ % 4 == 0) {
            say "$_\tMISSED";
            $allgood=0;
        }
    }
}

say $allgood ? "all good" : "";



__END__

