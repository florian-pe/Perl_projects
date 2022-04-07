#!/usr/bin/perl

use strict;
use warnings;
use v5.10;

chomp(my $nums=<>);

our (@nums, @res);
our %matched;
our $reached = 1;
our (@path, @stack);

sub reset_state {

#     say "reset_state()";
#     say "STACK @stack";
# 
#     say $_[0]    // die "\$_[0] undefined";
#     say $path[0] // die "\$path[0] undefined";

    if ($_[0] eq $path[0]) {
        shift @path;
#         say $_[0];
#         if (@path == 1) {   # skip just ahead of where we left off
        if (@path == 0) {   # skip just ahead of where we left off
            $reached = 1;
            return 0;     # CURRENT
#             return 1;
        }
        else {              # follow the path to the last state
            return 1;
        }
    }
    else {
        return 0;
    }
}

my $regex = qr/

    (?{ local @nums })
    (?{ local %matched })
    (?{ local @stack })

    ^
#     (?&start)
    (?&number){10}

    (?{
#         say "end";
        @res = @nums;
        $reached = 0;
        @path = @stack;
     })
    
    (?(DEFINE)
        (?<start> ^ )
        (?<number>
#             (?(?{ %matched == 0 ? 1 : 0 }) ^ )
#             (?(?{ %matched == 0 }) ^ )
#             (?(?{ %matched == 0 }) ^ | (?=) )

            (?:
#                   (?(?{ !exists $matched{0} }) (?&zero)      | (?!) )

    # also works. Which is faster ? $hash{key} or exists $hash{key} ??

#       (?(?{ !$reached ? reset_state(0) : 1 }) | (?!)) (?(?{ !$matched{0} }) (?&zero)  | (?!) )
#     | (?(?{ !$reached ? reset_state(1) : 1 }) | (?!)) (?(?{ !$matched{1} }) (?&one)   | (?!) )
#     | (?(?{ !$reached ? reset_state(2) : 1 }) | (?!)) (?(?{ !$matched{2} }) (?&two)   | (?!) )
#     | (?(?{ !$reached ? reset_state(3) : 1 }) | (?!)) (?(?{ !$matched{3} }) (?&three) | (?!) )
#     | (?(?{ !$reached ? reset_state(4) : 1 }) | (?!)) (?(?{ !$matched{4} }) (?&four)  | (?!) )
#     | (?(?{ !$reached ? reset_state(5) : 1 }) | (?!)) (?(?{ !$matched{5} }) (?&five)  | (?!) )
#     | (?(?{ !$reached ? reset_state(6) : 1 }) | (?!)) (?(?{ !$matched{6} }) (?&six)   | (?!) )
#     | (?(?{ !$reached ? reset_state(7) : 1 }) | (?!)) (?(?{ !$matched{7} }) (?&seven) | (?!) )
#     | (?(?{ !$reached ? reset_state(8) : 1 }) | (?!)) (?(?{ !$matched{8} }) (?&eight) | (?!) )
#     | (?(?{ !$reached ? reset_state(9) : 1 }) | (?!)) (?(?{ !$matched{9} }) (?&nine)  | (?!) )

      (?(?{ !$reached ? reset_state(0) : 1 }) | (?!))  (?&zero)  
    | (?(?{ !$reached ? reset_state(1) : 1 }) | (?!))  (?&one)   
    | (?(?{ !$reached ? reset_state(2) : 1 }) | (?!))  (?&two)   
    | (?(?{ !$reached ? reset_state(3) : 1 }) | (?!))  (?&three) 
    | (?(?{ !$reached ? reset_state(4) : 1 }) | (?!))  (?&four)  
    | (?(?{ !$reached ? reset_state(5) : 1 }) | (?!))  (?&five)  
    | (?(?{ !$reached ? reset_state(6) : 1 }) | (?!))  (?&six)   
    | (?(?{ !$reached ? reset_state(7) : 1 }) | (?!))  (?&seven) 
    | (?(?{ !$reached ? reset_state(8) : 1 }) | (?!))  (?&eight) 
    | (?(?{ !$reached ? reset_state(9) : 1 }) | (?!))  (?&nine)  



            )
        )

        (?<zero>
            (?{ local @nums=(@nums, 0) })
            [a-g]{6} \s+
            (?{ local %matched = (%matched, 0 => 1) })
            (?{ local @stack = (@stack, 0) })

#             (?{ say "STACK @stack" })
        )
        (?<one>
            (?{ local @nums=(@nums, 1) })
            [a-g]{2} \s+
            (?{ local %matched = (%matched, 1 => 1) })
            (?{ local @stack = (@stack, 1) })

#             (?{ say "STACK @stack" })
        )
        (?<two>
            (?{ local @nums=(@nums, 2) })
            [a-g]{5} \s+
            (?{ local %matched = (%matched, 2 => 1) })
            (?{ local @stack = (@stack, 2) })

#             (?{ say "STACK @stack" })
        )
        (?<three>
            (?{ local @nums=(@nums, 3) })
            [a-g]{5} \s+
            (?{ local %matched = (%matched, 3 => 1) })
            (?{ local @stack = (@stack, 3) })

#             (?{ say "STACK @stack" })
        )
        (?<four>
            (?{ local @nums=(@nums, 4) })
            [a-g]{4} \s+
            (?{ local %matched = (%matched, 4 => 1) })
            (?{ local @stack = (@stack, 4) })

#             (?{ say "STACK @stack" })
        )
        (?<five>
            (?{ local @nums=(@nums, 5) })
            [a-g]{5} \s+
            (?{ local %matched = (%matched, 5 => 1) })
            (?{ local @stack = (@stack, 5) })

#             (?{ say "STACK @stack" })
        )
        (?<six>
            (?{ local @nums=(@nums, 6) })
            [a-g]{6} \s+
            (?{ local %matched = (%matched, 6 => 1) })
            (?{ local @stack = (@stack, 6) })

#             (?{ say "STACK @stack" })
        )
        (?<seven>
            (?{ local @nums=(@nums, 7) })
            [a-g]{3} \s+
            (?{ local %matched = (%matched, 7 => 1) })
            (?{ local @stack = (@stack, 7) })

#             (?{ say "STACK @stack" })
        )
        (?<eight>
            (?{ local @nums=(@nums, 8) })
            [a-g]{7} \s+
            (?{ local %matched = (%matched, 8 => 1) })
            (?{ local @stack = (@stack, 8) })

#             (?{ say "STACK @stack" })
        )
        (?<nine>
            (?{ local @nums=(@nums, 9) })
            [a-g]{6} \s+
            (?{ local %matched = (%matched, 9 => 1) })
            (?{ local @stack = (@stack, 9) })

#             (?{ say "STACK @stack" })
        )


    )
    
/x;

say $nums;
say "";

while ($nums =~ /$regex/) {     # THE TRICK (bypass optimizations ?)
# while ($nums =~ /$regex/g) {
# while ($nums =~ /$regex/gc) {
#     say "@nums";
    say "@res";
#     say "PATH @path";
}

__END__


acedgfb     8
cdfbe       2/3/5
gcdfa       2/3/5
fbcad       2/3/5
dab         3
cefabd      0/6/9
cdfgeb      0/6/9
eafb        4
cagedb      0/6/9
ab          1

8 2 3 5 7 0 6 4 9 1


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



2 -> 3 -> 5
0 -> 6 -> 9



2 3 5 0 6 9
2 3 5 0 9 6

2 3 5 6 0 9
2 3 5 6 9 0

2 3 5 9 0 6
2 3 5 9 6 0

2 5 3 0 6 9
2 5 3 0 9 6

2 5 3 6 0 9
2 5 3 6 9 0

2 5 3 9 0 6
2 5 3 9 6 0
------------------------
3 2 5 0 6 9
3 2 5 0 9 6

3 2 5 6 0 9
3 2 5 6 9 0

3 2 5 9 0 6
3 2 5 9 6 0

3 5 2 0 6 9
3 5 2 0 9 6

3 5 2 6 0 9
3 5 2 6 9 0

3 5 2 9 0 6
3 5 2 9 6 0
------------------------
5 2 3 0 6 9
5 2 3 0 9 6

5 2 3 6 0 9
5 2 3 6 9 0

5 2 3 9 0 6
5 2 3 9 6 0

5 3 2 0 6 9
5 3 2 0 9 6

5 3 2 6 0 9
5 3 2 6 9 0

5 3 2 9 0 6
5 3 2 9 6 0

36 instead of 729

(2 among 3) * (2 among 3)   instead of 3 ** 3   *   3 ** 3

NO works as it should




