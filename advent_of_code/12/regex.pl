#!/usr/bin/perl

use strict;
use warnings;
use v5.10;

my %nodes;
our $count;
our $visited;
our @stack;

while (<>) {
    my ($a,$b) = /^(.*?)-(.*)/;
    push $nodes{ $a }->@*, $b;
    push $nodes{ $b }->@*, $a;
}

my $str = "a" x 300;
# my $regex = qr{

my $seen = {};

while ($str =~ m{

#     ^ 
    \G
    (?{
        say "start of regex";
#         local $visited = {};
        local $visited = { $seen->%* };
    })

    (?&start)
    | (*ACCEPT)
#     | (?=)

    (?(DEFINE)

        (?<start>
            (??{
                local @stack = (@stack, "start");
#                 say join ",", @stack;
#                 say join ",", @stack if $visited->{start} == 0;
#                 say "start";
                local $visited = { $visited->%* };
                $visited->{start}++ ? "(?!)" : "(?=)"
            })
            .
            (?:
                    (?&A)
                |   (?&b)
            )
        )
        (?<A>
            .
            (?{
                local @stack = (@stack, "A");
#                 say join ",", @stack;
#                 say "A"
            })
            (?:
                (?&c)
            |   (?&b)
            |   (?&start)
            |   (?&end)
#                 (?!)
            )
        )

        (?<b>
            .
            (??{
                local @stack = (@stack, "b");
#                 say join ",", @stack;
#                 say "b";
                local $visited = { $visited->%* };
                $visited->{b}++;
                $visited->{b}++ ? "(?!)" : "(?=)"
            })
            (?:
                    (?&d)
                |   (?&A)
                |   (?&start)
                |   (?&end)
#                     (?!)
            )
        )
        (?<c>
            .
            (??{
                local @stack = (@stack, "c");
#                 say join ",", @stack;
#                 say "c";
                local $visited = { $visited->%* };
#                 $visited->{c}++ ? "(?!)" : "(?=)"
                $visited->{c}++ ? "(*FAIL)" : "(*ACCEPT)"
            })
            (?:
                    (?&A)
            )
        )
        (?<d>
            .
            (??{
                local @stack = (@stack, "d");

#                 say join ",", @stack;
#                 say "d";

                local $visited = { $visited->%* };

#                 $visited->{d}++ ? "(?!)" : "(?=)"
                $visited->{d}++ ? "(*FAIL)" : "(*ACCEPT)"

            })
            (?:
                    (?&b)
            )
        )
        (?<end>
            .
            (??{
                local @stack = (@stack, "end");

                say join ",", @stack;
#                 say "end";

                local $visited = { $visited->%* };
                $visited->{end}++;

                    $count++;
                    $seen = { $visited->%* };
                  "(*FAIL)"
#                   "(*ACCEPT)"
#                   "(*ACCEPT) (*FAIL)"
            })
            (?:
                    (?&A)
                |   (?&b)
            )
        )
    )

}gxc) {};

# my $str = "a" x 300;
# $str =~ $regex;

say $count;



__END__




Infinite recursion in regex
   (F) You used a pattern that references itself without
   consuming any input text.  You should check the pattern to
   ensure that recursive patterns either consume text or fail.



"(?{ code })"
WARNING: Using this feature safely requires that you understand its limitations.  Code executed that has side effects
may not perform identically from version to version due to the effect of future optimisations in the regex engine.  For
more information on this, see "Embedded Code Execution Frequency".


"(??{ code })"
WARNING: Using this feature safely requires that you understand its limitations.  Code executed that has side effects
may not perform identically from version to version due to the effect of future optimisations in the regex engine.  For
more information on this, see "Embedded Code Execution Frequency".



Embedded Code Execution Frequency

The exact rules for how often "(??{})" and "(?{})" are executed in a pattern are unspecified.  In the case of a successful
match you can assume that they DWIM and will be executed in left to right order the appropriate number of times in the
accepting path of the pattern as would any other meta-pattern.  How non-accepting pathways and match failures affect the
number of times a pattern is executed is specifically unspecified and may vary depending on what optimizations can be
applied to the pattern and is likely to change from version to version.

For instance in

 "aaabcdeeeee"=~/a(?{print "a"})b(?{print "b"})cde/;

the exact number of times "a" or "b" are printed out is unspecified for failure, but you may assume they will be printed at
least once during a successful match, additionally you may assume that if "b" is printed, it will be preceded by at least
one "a".

In the case of branching constructs like the following:

 /a(b|(?{ print "a" }))c(?{ print "c" })/;

you can assume that the input "ac" will output "ac", and that "abc" will output only "c".

When embedded code is quantified, successful matches will call the code once for each matched iteration of the quantifier.
For example:

 "good" =~ /g(?:o(?{print "o"}))*d/;

will output "o" twice.


