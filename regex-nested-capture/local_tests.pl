#!/usr/bin/perl

use strict;
use warnings;
use v5.10;

local $,="";
local $\="\n";

# my @stack;  # can't localize lexical variable
our @stack;

# "abcde" =~ m%
# "abcdfabcde" =~ m%
"abcdeabcdf" =~ m%

    (
        (?:
            (?{
                print "first group, before";
                print "@stack";
            })

#             (?{
#                 local @stack=@stack;
#             })

            (?&letter)

            (?{
                print "first group, after";
                print "@stack";
                print "-" x 40;
             })
        )+
    )
    
    (?{
        print "before second group, pos = ", pos(), "/",length;
        print "@stack";
        print "-" x 40;
     })

#     (?{
#         local @stack=@stack;
#     })
    
#     ((?&letter))
    (e)
    
    (?{print "SUCCES"})
    
    (?(DEFINE)
        (?<letter> 
#             (?{
#                 local @stack=@stack;
#                 print "@stack";
#             })
           
            (\w)
            
            (?{
               local @stack = @stack;
                push @stack, $+;
#                 print "@stack";
#                 print "-" x40;
             })
         )
    ) 
    
%x;

say $&;

say join " ", $1, $2;

__END__

better to localize stack :
- inside rule, before body
- outside rule, before calling the rule
???

difference ??




perl -le '@main::stack = 5; "abcde" =~ / (?{ print @main::stack }) (?{ local @main::stack = 7 }) (?{ print @main::stack })/x; print'


perl -le '@main::stack = 5; "a" =~ / (?&first_call) (?&second_call)  (?(DEFINE) (?<first_call> (?{ print @main::stack }) (?{ local @main::stack = 7 }) (?{ print @main::stack }) (?!)) (?<second_call> (?{ print @main::stack }) ) )/x; print'

perl -le '@main::stack = 5; "a" =~ / (?&first_call) (?&second_call) (?!)  (?(DEFINE) (?<first_call> (?{ print @main::stack }) (?{ local @main::stack = 7 }) (?{ print @main::stack }) ) (?<second_call> (?{ print @main::stack }) ) )/x; print'

perl -le '@main::stack = 5; "a" =~ / (?&first_call) (?&second_call) (?!)  (?(DEFINE) (?<first_call> (?{ print "first_call"; print @main::stack }) (?{ local @main::stack = 7 }) (?{ print @main::stack }) ) (?<second_call> (?{print "second_call"; local @main::stack=8; print @main::stack }) ) )/x; print'


raku -e '"14:25:10after" ~~ /$<hour>=(\d\d) \: $<min>=(\d\d) \: $<sec>=(\d\d)(.*)/; say $/.list'








