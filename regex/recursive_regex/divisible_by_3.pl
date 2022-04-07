#!/usr/bin/perl

use strict;
use warnings;
use v5.10;

# recent regex challenge that I did which was not particularly easy
# the goal was to code a regex matching integers divisible by 3
#
# OBVIOUSLY this has nothing to do in production code

# [0369]
# [147]
# [258]

my $regex = qr{

    ^ (?&div_3) $

#     (?(DEFINE)
#         (?<div_3>
#             (?: [0369]+
#               | [147] (?&div_3)* (?: [258] | [147] (?&div_3)* [147])
#               | [258] (?&div_3)* (?: [147] | [258] (?&div_3)* [258]))
#             (?&div_3)* )
#     )

    (?(DEFINE)
        (?<div_3>
            (?: [0369]+
              | [147] (?&div_3)? (?: [258] | [147] (?&div_3)? [147])
              | [258] (?&div_3)? (?: [147] | [258] (?&div_3)? [258]))
            (?&div_3)? )
    )
}x;

# divisible by 3 => sum of its digits must be divisible by 3
#                => number modulo 3 == 0

# [0369] is modulo 3 == 0, so [0369]+ modulo 3 is also 0

# 3 times any number will be a multiple of 3
# so [147]{3} and [358]{3} are multiples of 3

# because [147] % 3 == 1 and [258] % 3 == 3
# ( [147] + [258] ) % 3 == 0

# lastly, an addition of any numbers divisible by 3 is divisible by 3
# and because addition is commutative, any permutation of those numbers is also divisible by 3


my $allgood=1;

# test the regex against numbers between 0 and 100 000
for (0..100_000) {
    print "$_\r";
    if ($_ =~ $regex) {
        if ($_ % 3 != 0) {
            say "$_\tnot divisible by 3";
            $allgood=0;
        }
    }
    else {
        if ($_ % 3 == 0) {
            say "$_\tMISSED";
            $allgood=0;
        }
    }
}

say $allgood ? "all good" : "";



__END__

