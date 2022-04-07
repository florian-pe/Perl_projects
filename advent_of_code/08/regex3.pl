#!/usr/bin/perl

use strict;
use warnings;
use v5.10;

chomp(my $nums=<DATA>);

our (@nums, @res);
our %matched;
our $reached = 1;
our (@path, @stack);

sub reset_state {
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
    (?&number){10}

    (?{
        @res = @nums;
        $reached = 0;
        @path = @stack;
     })
    
    (?(DEFINE)
        (?<number>

            (?:

    # also works. Which is faster ? $hash{key} or exists $hash{key} ??

      (?(?{ !$reached ? reset_state(0) : 1 }) | (?!)) (?(?{ !$matched{0} }) (?&zero)  | (?!) )
    | (?(?{ !$reached ? reset_state(1) : 1 }) | (?!)) (?(?{ !$matched{1} }) (?&one)   | (?!) )
    | (?(?{ !$reached ? reset_state(2) : 1 }) | (?!)) (?(?{ !$matched{2} }) (?&two)   | (?!) )
    | (?(?{ !$reached ? reset_state(3) : 1 }) | (?!)) (?(?{ !$matched{3} }) (?&three) | (?!) )
    | (?(?{ !$reached ? reset_state(4) : 1 }) | (?!)) (?(?{ !$matched{4} }) (?&four)  | (?!) )
    | (?(?{ !$reached ? reset_state(5) : 1 }) | (?!)) (?(?{ !$matched{5} }) (?&five)  | (?!) )
    | (?(?{ !$reached ? reset_state(6) : 1 }) | (?!)) (?(?{ !$matched{6} }) (?&six)   | (?!) )
    | (?(?{ !$reached ? reset_state(7) : 1 }) | (?!)) (?(?{ !$matched{7} }) (?&seven) | (?!) )
    | (?(?{ !$reached ? reset_state(8) : 1 }) | (?!)) (?(?{ !$matched{8} }) (?&eight) | (?!) )
    | (?(?{ !$reached ? reset_state(9) : 1 }) | (?!)) (?(?{ !$matched{9} }) (?&nine)  | (?!) )

#       (?(?{ !$reached ? reset_state(0) : 1 }) | (?!))  (?&zero)  
#     | (?(?{ !$reached ? reset_state(1) : 1 }) | (?!))  (?&one)   
#     | (?(?{ !$reached ? reset_state(2) : 1 }) | (?!))  (?&two)   
#     | (?(?{ !$reached ? reset_state(3) : 1 }) | (?!))  (?&three) 
#     | (?(?{ !$reached ? reset_state(4) : 1 }) | (?!))  (?&four)  
#     | (?(?{ !$reached ? reset_state(5) : 1 }) | (?!))  (?&five)  
#     | (?(?{ !$reached ? reset_state(6) : 1 }) | (?!))  (?&six)   
#     | (?(?{ !$reached ? reset_state(7) : 1 }) | (?!))  (?&seven) 
#     | (?(?{ !$reached ? reset_state(8) : 1 }) | (?!))  (?&eight) 
#     | (?(?{ !$reached ? reset_state(9) : 1 }) | (?!))  (?&nine)  

            )
        )

        (?<zero>
            (?{ local @nums=(@nums, 0) })
            [a-g]{6} \s+
            (?{ local %matched = (%matched, 0 => 1) })
            (?{ local @stack = (@stack, 0) })
        )
        (?<one>
            (?{ local @nums=(@nums, 1) })
            [a-g]{2} \s+
            (?{ local %matched = (%matched, 1 => 1) })
            (?{ local @stack = (@stack, 1) })
        )
        (?<two>
            (?{ local @nums=(@nums, 2) })
            [a-g]{5} \s+
            (?{ local %matched = (%matched, 2 => 1) })
            (?{ local @stack = (@stack, 2) })
        )
        (?<three>
            (?{ local @nums=(@nums, 3) })
            [a-g]{5} \s+
            (?{ local %matched = (%matched, 3 => 1) })
            (?{ local @stack = (@stack, 3) })
        )
        (?<four>
            (?{ local @nums=(@nums, 4) })
            [a-g]{4} \s+
            (?{ local %matched = (%matched, 4 => 1) })
            (?{ local @stack = (@stack, 4) })
        )
        (?<five>
            (?{ local @nums=(@nums, 5) })
            [a-g]{5} \s+
            (?{ local %matched = (%matched, 5 => 1) })
            (?{ local @stack = (@stack, 5) })
        )
        (?<six>
            (?{ local @nums=(@nums, 6) })
            [a-g]{6} \s+
            (?{ local %matched = (%matched, 6 => 1) })
            (?{ local @stack = (@stack, 6) })
        )
        (?<seven>
            (?{ local @nums=(@nums, 7) })
            [a-g]{3} \s+
            (?{ local %matched = (%matched, 7 => 1) })
            (?{ local @stack = (@stack, 7) })
        )
        (?<eight>
            (?{ local @nums=(@nums, 8) })
            [a-g]{7} \s+
            (?{ local %matched = (%matched, 8 => 1) })
            (?{ local @stack = (@stack, 8) })
        )
        (?<nine>
            (?{ local @nums=(@nums, 9) })
            [a-g]{6} \s+
            (?{ local %matched = (%matched, 9 => 1) })
            (?{ local @stack = (@stack, 9) })
        )
    )
/x;

say $nums;
say "";

while ($nums =~ /$regex/) {     # THE TRICK (bypass optimizations ?)
    say "@res";
}

__DATA__
acedgfb cdfbe gcdfa fbcad dab cefabd cdfgeb eafb cagedb ab | cdfeb fcadb cdfeb cdbaf
