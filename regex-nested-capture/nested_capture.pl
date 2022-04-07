#!/usr/bin/perl

use strict;
use warnings;
use v5.10;
use Data::Dumper;
$Data::Dumper::Sortkeys=1;
$Data::Dumper::Indent = 1;

local $,="";
local $\="\n";

# my $capture;
our $capture;
# my @stack;
our @stack;
our $parent;
our $return;

my $result;

my $parser = qr{

    ^

#     (?<time> .. )
#     (?<data> .. )
    # have to save those result before the first ruled called

    (?{
    })


    (?&date_time)
    (?{

        local $capture;
        $capture->{date_time} = pop @stack;
        local @stack = (@stack, $capture);
        
    })

    $
 
    (?{
        $result = pop @stack;
    })


    (?(DEFINE)
        (?<date>

#                 $<year> = \d{4} - $<month> = \d{2} - $<day> = \d\d
#                 $<year> = \d{4} - $<month> = \d{2} - $<day> = \d\d
                (?<year> \d{4} ) - (?<month> \d{2} ) - (?<day> \d{2} )

                (?{
                    local $capture;
                    $capture->{year} = $+{year};
                    $capture->{month} = $+{month};
                    $capture->{day} = $+{day};
                    local @stack = (@stack, $capture);
                })
         )

        (?<time>

#             $<clock>=[\d\d] (?: : [\d\d] ){2}   $<tz>= .+

             (?<clock> \d\d (?: : \d\d ){2} )
#              (?<tz> .+)
             (?<tz> -? \d{2} : \d{2})

            (?{
                local $capture;
                $capture->{clock} = $+{clock};
                $capture->{tz} = $+{tz};
                local @stack = (@stack, $capture);
            })
        )

        (?<date_time>


            (?&date)
            (?{
                local $capture;
                $capture->{date} = pop @stack;
                local @stack = (@stack, $capture);
            })

            T

            (?&time)
            (?{
                local $return = pop @stack;
                local $capture = pop @stack;
                $capture->{time} = $return;
#                 local @stack = (@stack, $capture);
#                 dd \@stack;
            })

            (?{
                local @stack = (@stack, $capture);
            })
        )
    )
}x;


my $str = "2018-07-26T19:00:00-04:00";
# my $str = "2018-07-26T19:00:00-04:00 garbage";
# print $parser;


if ($str =~ $parser) {
    print "-" x 40;
    print "MATCH";
    print $&;
}
else {
    print "-" x 40;
    print "FAIL";
#     print $&;
}

# dd $capture;
# dd $result;
say Dumper $result;

__END__

raku -e 'my regex date { $<year>=\d**4 "-" $<month>=\d**2 "-" $<day>=[\d\d] }; my regex time { $<clock>=[\d\d]**3 % ":" $<tz>=.+ }; my regex date-time { <date> T <time> }; "2018-07-26T19:00:00-04:00" ~~ &date-time; say $/'


raku -e 'my regex date { $<year>=\d**4 "-" $<month>=\d**2 "-" $<day>=[\d\d] }; my regex time { $<clock>=[\d\d]**3 % ":" $<tz>=.+ }; my regex date-time { <date> T <time> }; "2018-07-26T19:00:00-04:00" ~~ &date-time; say $/'


/ (pat)  (pat)   (?<name> (pat) (pat)  )?  /x


detection of g global


/ (?{ $global = 1 if $success })        pattern          (?{ $success = 1 })  /
--> first pass, $success = 0, $global not set to 1

--> then, pattern suceed, 
either no /g modifier and regex match stop, or it is global and retry another match after the first one succeeded

even if there is a ^ or $ or the first and only match ends just at the end of the string and the regex engine is smart enough to not retry ??


perl -le 'print "abcd" =~ / (?{ print "match attempt" })  b  c (?{ print "success" }) /gx'
perl -le 'print "abcbc" =~ / (?{ print "match attempt" })  b  c (?{ print "success" }) /gx'
perl -le 'print scalar "abcbc" =~ / (?{ print "match attempt" })  b  c (?{ print "success" }) /gx'

perl -le 'print scalar "abcdddddd" =~ / (?{ print "match attempt" })  b  c (?{ print "success" }) /gx'


SCALAR CONTEXT
"string" =~ m//
"string" =~ m/()/
"string" =~ m//g
"string" =~ m/()/g

LIST CONTEXT
"string" =~ m//
"string" =~ m/()/
"string" =~ m//g
"string" =~ m/()/g




perl -le 'print "abcdddddd" =~ / (<!(?{ print "match attempt" }))  b  c (?{ print "success" }) /gx'


perl -le 'print "abcdddddd" =~ / (<=(?{ print "match attempt" }))  b  c (?{ print "success" }) /gx'

perl -le 'print "abcdddddd" =~ / (?=(?{ print "match attempt" }))  b  c (?{ print "success" }) /gx'
perl -le 'print "abcdddddd" =~ / (?<=(?{ print "match attempt" }))  b  c (?{ print "success" }) /gx'
perl -le 'print "abcdddddd" =~ / b (?<=(?{ print "match attempt" }))  c (?{ print "success" }) /gx'
perl -le 'print "abcdddddd" =~ / b (?{ print "match attempt" })  c (?{ print "success" }) /gx'







recursive descent parser
--> function calls
--> simluate function calls
==> manual call stack manipulation
    - passing arguments (no arguments passed in this case)
            - caller => push arguments
            - calee  -> pop  arguments
    - return
            - callee => push return value
            - caller => pop  return value


local / dynamic variable (the @stack) to deal with backtracking


post-order

(?&rule)

(?(DEFINE)
    (?<rule>
        before
        PATTERN
        after
    )
)


(?<date>

    (?<year> \d{4} ) - (?<month> \d{2} ) - (?<day> \d{2} )

)


leaves => 1
leaves => 0



only nested named captures

nested named captures + rules

only rules

multiple (?<rule>) (?<rule>)




(?&rule)
--> inside main                    => capture after
--> inside another rule definition => capture after



(?<rule>)
--> main                    => capture after
--> define
    - top rule              => 
    - inside a definition   => capture after


()
--> main            => capture after
--> inside a rule   => capture after




turing machine

post system
string rewrite rules
inference rules
logic
generative rules
prolog
parsing --> applying generative/transformation/string rewrite rules in reverse ??   ==> bottom up parsing

==> top down parsing ?? / recursive descent parsing

==> operator precedence parsing ??

lamda calculus --> AST evaluation ?


equations


prolog --> DPS  backtracking


post, refal --> pattern matching, rewrite ? inference ? rules



someting analog to hashes but for ... ??





search algorithm ==> backtracking ??

search algorithm ==> traversal of a data structure + testing/conditional

regex ==> DFS ? BFS ??


implement a search algorithm with regex engine ??

search algorithm using DFS on a data structure
--> can we transform the data structure in a way to still use the same DFS algorithm, obtain the exact same results, but be equivalent to a BFS search on the original data structure ??





closure
- function with state
- object with one method
- allows a programming language to have lambda calculus semantics




control flow graph <=> DFA + inlined callbacks



consistency / soudness ?        coherence       
completeness                    completude
decidable

halting problem
complexity theory



unification algorithm


change the execution model of imperative languages


semantic
- denotational
- operational
- axiomatic



recursive implementation
DFS
BFS

using perl regex to do DFS ??
using perl regex to do BFS ?????



imperative / procedural         turing machine
functional                      lambda calculus => abstract rewrite system ?
logic / declarative             first order logic
rewrite system / production systems / inference rules / Post systems, string rewriting


inference rules --> implications ????


SAT/SMT, unification, inference rules







backtracking
- dynamical scope

searching --> iteration/walking + conditionals/predicates

iteration/traversal/walking
- DFA, stack, etc ..
- mutual recursion
- inference rules ???

unification
- backtracking ?

control flow
- goto / imperative stack function call;                              conditionals
- function call / variable binding in lambda expressions / closures;  conditionals  
- inference rules ? match/dispatch ? unification ? backtracking ?


lists
- call stack, subroutines taking/returning lists
- relationship with lambda calculus ??? --> Lisp; currying ??


graphs
- control flow graph, conditionals
- (mutual) recursion
- inference rules, relations ?




current regex have to do everything with literals, can put a variable without requiring re compilation




query languages ????


symbolic computation
- symbolic expressions, and those expressions are not evaluated ???
- similar to AST manipulations ??
laziness ??

difference symbol vs reference ??



literal, variable, symbols, reference



naive sorting algorithm in Prolog
==> permutation sort




satisfiability
unsatisfiability









perl -E '"abcde" =~ m/ (?<cap> . )  (?<cap> . ) /x; say $+{cap}'

perl -E '"abcde" =~ m/ (?<cap> . )  (?<cap> . ) /x; say $-{cap}[0]'
perl -E '"abcde" =~ m/ (?<cap> . )  (?<cap> . ) /x; say $-{cap}[1]'

perl -E '"abcde" =~ m/ (?<cap> a ) (?(DEFINE) (?<cap> b )  )/x; say "\"$&\""; say $+{cap}'

perl -E '"abcde" =~ m/ (?&cap) (?(DEFINE) (?<cap> b )  )/x; say "\"$&\""; say $+{cap}'

perl -E '"abcde" =~ m/ (?&cap) (?(DEFINE) (?<cap> b ) (?<cap> a ) )/x; say "\"$&\""; say $+{cap}'
perl -E '"abcde" =~ m/ (?&cap) (?(DEFINE) (?<cap> a ) (?<cap> b ) )/x; say "\"$&\""; say $+{cap}'
perl -E '"abcde" =~ m/ (?&cap) (?(DEFINE) (?<cap> z ) (?<cap> a ) )/x; say "\"$&\""; say $+{cap}'

perl -E '"abcde" =~ m/ (?&cap) (?(DEFINE) (?<cap> z ) ) (?(DEFINE) (?<cap> a ) )/x; say "\"$&\""; say $+{cap}'
perl -E '"abcde" =~ m/ (?&cap) (?(DEFINE) (?<cap> a ) ) (?(DEFINE) (?<cap> z ) )/x; say "\"$&\""; say $+{cap}'

perl -E 'use strict; use warnings; "abcde" =~ m/ (?&cap) (?(DEFINE) (?<cap> a ) ) (?(DEFINE) (?<cap> z ) )/x; say "\"$&\""; say $+{cap}'



perl -E '"abcde" =~ m/ (?&cap) (?(DEFINE) (?<CAP> a ) ) (?(DEFINE) (?<cap> z ) )/x; say "\"$&\""; say $+{cap}'
perl -E '"abcde" =~ m/ (?&cap) (?(DEFINE) (?<CAP> a ) ) (?(DEFINE) (?<cap> b ) )/x; say "\"$&\""; say $+{cap}'

? ! <? <! as prefix lookaround operators    --> only for (?&rule) ??
\? <? as quantifiers ??

?a <?a
!a <!a

  (?&rule)
 .(?&rule)
 |(?&rule)
 ?(?&rule)
 !(?&rule)
<?(?&rule)
<!(?&rule)

& conjuction ??

% / %% quantifier modifier ??

push/pop    --> only store offsets

tied hash --> get substrings lazily ??

parsing push/pop
--> "root" of capture
--> only leaves


POSITIVE LOOKAHEAD / PREDICATE
atom/group quanfitifed (whithout quantifier modifier)  

?(?&rule)   --> positive lookahead / predicate
? (?&rule)  --> lazy atom followed by rule call


atom/group quanfitifed (quantifier modifier)

\?(?&rule)   --> positive lookahead / predicate
\? (?&rule)  --> lazy atom followed by literal '?' followed by rule call


POSITIVE LOOKBEHIND / PREDICATE



<?(?&rule)   --> positive lookbehind / predicate
<? (?&rule)  --> optional '<' followed by rule call


(?=)
(?<=)


ordering expression for data structure iteration/traversal
ordering expression for generating combinations of a grammar / regex ?

\S+ \s+ \S+ \s+

2 > 1 > 3 > 4   this standalone or with ranges

2[1..3] > 1[1..50]


optimization, execution model





