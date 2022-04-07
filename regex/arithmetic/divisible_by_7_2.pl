#!/usr/bin/perl

use strict;
use warnings;
use v5.10;

my $regex = qr{
    ^ (?&mod_0)

    (?(DEFINE)
        (?<mod_0> [0-9] $ (?<= [07]) 
                | (?&mod_0) 0
                | (?&mod_2) 1
                | (?&mod_4) 2
                | (?&mod_6) 3
                | (?&mod_1) 4
                | (?&mod_3) 5
                | (?&mod_5) 6
                | (?&mod_0) 7
                | (?&mod_2) 8
                | (?&mod_4) 9 )

        (?<mod_1> [0-9] $ (?<= [18]) 
                | (?&mod_5) 0
                | (?&mod_0) 1
                | (?&mod_2) 2
                | (?&mod_4) 3
                | (?&mod_6) 4
                | (?&mod_1) 5
                | (?&mod_3) 6
                | (?&mod_5) 7
                | (?&mod_0) 8
                | (?&mod_2) 9 )

        (?<mod_2> [0-9] $ (?<= [29]) 
                | (?&mod_3) 0
                | (?&mod_5) 1
                | (?&mod_0) 2
                | (?&mod_2) 3
                | (?&mod_4) 4
                | (?&mod_6) 5
                | (?&mod_1) 6
                | (?&mod_3) 7
                | (?&mod_5) 8
                | (?&mod_0) 9 )

        (?<mod_3> [0-9] $ (?<= [30]) 
                | (?&mod_1) 0
                | (?&mod_3) 1
                | (?&mod_5) 2
                | (?&mod_0) 3
                | (?&mod_2) 4
                | (?&mod_4) 5
                | (?&mod_6) 6
                | (?&mod_1) 7
                | (?&mod_3) 8
                | (?&mod_5) 9 )

        (?<mod_4> [0-9] $ (?<= [41]) 
                | (?&mod_6) 0
                | (?&mod_1) 1
                | (?&mod_3) 2
                | (?&mod_5) 3
                | (?&mod_0) 4
                | (?&mod_2) 5
                | (?&mod_4) 6
                | (?&mod_6) 7
                | (?&mod_1) 8
                | (?&mod_3) 9 )

        (?<mod_5> [0-9] $ (?<= [52]) 
                | (?&mod_4) 0
                | (?&mod_6) 1
                | (?&mod_1) 2
                | (?&mod_3) 3
                | (?&mod_5) 4
                | (?&mod_0) 5
                | (?&mod_2) 6
                | (?&mod_4) 7
                | (?&mod_6) 8
                | (?&mod_1) 9 )

        (?<mod_6> [0-9] $ (?<= [63]) 
                | (?&mod_2) 0
                | (?&mod_4) 1
                | (?&mod_6) 2
                | (?&mod_1) 3
                | (?&mod_3) 4
                | (?&mod_5) 5
                | (?&mod_0) 6
                | (?&mod_2) 7
                | (?&mod_4) 8
                | (?&mod_6) 9 )
    )

}x;


my $allgood=1;

for (0..9) {
# for (0..100) {
    print "$_\r";
    if ($_ =~ $regex) {
        if ($_ % 7 != 0) {
            say "$_\tnot divisible by 7";
            $allgood=0;
        }
    }
    else {
        if ($_ % 7 == 0) {
            say "$_\tMISSED";
            $allgood=0;
        }
    }
}

say $allgood ? "all good" : "";


__END__

perl -E 'for (10..1000) { @digit=split "", $_; $last=pop @digit; say $_, $_ % 7 == 0 ? "\tdiv 7" : ""; say "last ", $last; say "double ", $last * 2; say join("", @digit) - $last*2; __ }' | less

