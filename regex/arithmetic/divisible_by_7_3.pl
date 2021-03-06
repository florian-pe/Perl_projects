#!/usr/bin/perl

use strict;
use warnings;
use v5.10;
use re "debug";

# \d+ ((?<= (?=(?&rule)|(?1)).) )

my $regex = qr{
#     ^ [0-9]+ $ ((?<= (?= (?&mod_0) | (?1))))
#     ^ [0-9]+ $ ((?<= (?= (?&mod_0) | (?1)) . ))
#     ^ [0-9]+ $ ((?<= (?= ^ (?&mod_0) | (?1)) . ))

#     ^ [0-9]+ $ ((?<= (?= ^ 123 | (?1)) . ))
#     ^

    (?(DEFINE)
#         (?<mod_0> ^ [0-9] (?<= [07]) 
        (?<mod_0> ^ [0-9] ((?<= (?= [07] | (?-1))  . )) 
                | 0 ((?<= (?= ^ (?&mod_0) | (?-1)) . ))
                | 1 ((?<= (?= ^ (?&mod_2) | (?-1)) . ))
                | 2 ((?<= (?= ^ (?&mod_4) | (?-1)) . ))
                | 3 ((?<= (?= ^ (?&mod_6) | (?-1)) . ))
                | 4 ((?<= (?= ^ (?&mod_1) | (?-1)) . ))
                | 5 ((?<= (?= ^ (?&mod_3) | (?-1)) . ))
                | 6 ((?<= (?= ^ (?&mod_5) | (?-1)) . ))
                | 7 ((?<= (?= ^ (?&mod_0) | (?-1)) . ))
                | 8 ((?<= (?= ^ (?&mod_2) | (?-1)) . ))
                | 9 ((?<= (?= ^ (?&mod_4) | (?-1)) . )))

#         (?<mod_1> ^ [0-9] (?<= [18]) 
        (?<mod_1> ^ [0-9] ((?<= (?= [18] | (?-1))  . )) 
                | 0 ((?<= (?= ^ (?&mod_5) | (?-1)) . ))
                | 1 ((?<= (?= ^ (?&mod_0) | (?-1)) . ))
                | 2 ((?<= (?= ^ (?&mod_2) | (?-1)) . ))
                | 3 ((?<= (?= ^ (?&mod_4) | (?-1)) . ))
                | 4 ((?<= (?= ^ (?&mod_6) | (?-1)) . ))
                | 5 ((?<= (?= ^ (?&mod_1) | (?-1)) . ))
                | 6 ((?<= (?= ^ (?&mod_3) | (?-1)) . ))
                | 7 ((?<= (?= ^ (?&mod_5) | (?-1)) . ))
                | 8 ((?<= (?= ^ (?&mod_0) | (?-1)) . ))
                | 9 ((?<= (?= ^ (?&mod_2) | (?-1)) . )))

#         (?<mod_2> ^ [0-9] (?<= [29]) 
        (?<mod_2> ^ [0-9] ((?<= (?= [29] | (?-1))  . )) 
                | 0 ((?<= (?= ^ (?&mod_3) | (?-1)) . ))
                | 1 ((?<= (?= ^ (?&mod_5) | (?-1)) . ))
                | 2 ((?<= (?= ^ (?&mod_0) | (?-1)) . ))
                | 3 ((?<= (?= ^ (?&mod_2) | (?-1)) . ))
                | 4 ((?<= (?= ^ (?&mod_4) | (?-1)) . ))
                | 5 ((?<= (?= ^ (?&mod_6) | (?-1)) . ))
                | 6 ((?<= (?= ^ (?&mod_1) | (?-1)) . ))
                | 7 ((?<= (?= ^ (?&mod_3) | (?-1)) . ))
                | 8 ((?<= (?= ^ (?&mod_5) | (?-1)) . ))
                | 9 ((?<= (?= ^ (?&mod_0) | (?-1)) . )))

#         (?<mod_3> ^ [0-9] (?<= [30]) 
        (?<mod_3> ^ [0-9] ((?<= (?= [30] | (?-1))  . )) 
                | 0 ((?<= (?= ^ (?&mod_1) | (?-1)) . ))
                | 1 ((?<= (?= ^ (?&mod_3) | (?-1)) . ))
                | 2 ((?<= (?= ^ (?&mod_5) | (?-1)) . ))
                | 3 ((?<= (?= ^ (?&mod_0) | (?-1)) . ))
                | 4 ((?<= (?= ^ (?&mod_2) | (?-1)) . ))
                | 5 ((?<= (?= ^ (?&mod_4) | (?-1)) . ))
                | 6 ((?<= (?= ^ (?&mod_6) | (?-1)) . ))
                | 7 ((?<= (?= ^ (?&mod_1) | (?-1)) . ))
                | 8 ((?<= (?= ^ (?&mod_3) | (?-1)) . ))
                | 9 ((?<= (?= ^ (?&mod_5) | (?-1)) . )))

#         (?<mod_4> ^ [0-9] (?<= [41]) 
        (?<mod_4> ^ [0-9] ((?<= (?= [41] | (?-1))  . )) 
                | 0 ((?<= (?= ^ (?&mod_6) | (?-1)) . ))
                | 1 ((?<= (?= ^ (?&mod_1) | (?-1)) . ))
                | 2 ((?<= (?= ^ (?&mod_3) | (?-1)) . ))
                | 3 ((?<= (?= ^ (?&mod_5) | (?-1)) . ))
                | 4 ((?<= (?= ^ (?&mod_0) | (?-1)) . ))
                | 5 ((?<= (?= ^ (?&mod_2) | (?-1)) . ))
                | 6 ((?<= (?= ^ (?&mod_4) | (?-1)) . ))
                | 7 ((?<= (?= ^ (?&mod_6) | (?-1)) . ))
                | 8 ((?<= (?= ^ (?&mod_1) | (?-1)) . ))
                | 9 ((?<= (?= ^ (?&mod_3) | (?-1)) . )))

#         (?<mod_5> ^ [0-9] (?<= [52]) 
        (?<mod_5> ^ [0-9] ((?<= (?= [52] | (?-1))  . )) 
                | 0 ((?<= (?= ^ (?&mod_4) | (?-1)) . ))
                | 1 ((?<= (?= ^ (?&mod_6) | (?-1)) . ))
                | 2 ((?<= (?= ^ (?&mod_1) | (?-1)) . ))
                | 3 ((?<= (?= ^ (?&mod_3) | (?-1)) . ))
                | 4 ((?<= (?= ^ (?&mod_5) | (?-1)) . ))
                | 5 ((?<= (?= ^ (?&mod_0) | (?-1)) . ))
                | 6 ((?<= (?= ^ (?&mod_2) | (?-1)) . ))
                | 7 ((?<= (?= ^ (?&mod_4) | (?-1)) . ))
                | 8 ((?<= (?= ^ (?&mod_6) | (?-1)) . ))
                | 9 ((?<= (?= ^ (?&mod_1) | (?-1)) . )))

#         (?<mod_6> ^ [0-9] (?<= [63]) 
        (?<mod_6> ^ [0-9] ((?<= (?= [63] | (?-1))  . )) 
                | 0 ((?<= (?= ^ (?&mod_2) | (?-1)) . ))
                | 1 ((?<= (?= ^ (?&mod_4) | (?-1)) . ))
                | 2 ((?<= (?= ^ (?&mod_6) | (?-1)) . ))
                | 3 ((?<= (?= ^ (?&mod_1) | (?-1)) . ))
                | 4 ((?<= (?= ^ (?&mod_3) | (?-1)) . ))
                | 5 ((?<= (?= ^ (?&mod_5) | (?-1)) . ))
                | 6 ((?<= (?= ^ (?&mod_0) | (?-1)) . ))
                | 7 ((?<= (?= ^ (?&mod_2) | (?-1)) . ))
                | 8 ((?<= (?= ^ (?&mod_4) | (?-1)) . ))
                | 9 ((?<= (?= ^ (?&mod_6) | (?-1)) . )))
    )

}x;


# my $allgood=1;
# 
# for (0..100) {
# for (0..10) {
#     print "$_\r";
#     if ($_ =~ $regex) {
#         if ($_ % 7 != 0) {
#             say "$_\tnot divisible by 7";
#             $allgood=0;
#         }
#     }
#     else {
#         if ($_ % 7 == 0) {
#             say "$_\tMISSED";
#             $allgood=0;
#         }
#     }
# }
# 
# say $allgood ? "all good" : "";

# say 0 =~ $regex;
# say "0" =~ $regex;
say "a" =~ $regex;

__END__

perl -E 'for (10..1000) { @digit=split "", $_; $last=pop @digit; say $_, $_ % 7 == 0 ? "\tdiv 7" : ""; say "last ", $last; say "double ", $last * 2; say join("", @digit) - $last*2; __ }' | less

