#!/usr/bin/perl

use strict;
use warnings;
use v5.10;

chomp(my $nums=<DATA>);

our @nums;
our @res;
our %matched;

my $regex = qr/

    (?{ local @nums })

    ^ (?&number){10}

    (?{
#         say "end";
        @res = @nums;
     })
    
    (?(DEFINE)
        (?<number>
            (?:
#                   (?(?{ !exists $matched{0} }) (?&zero)      | (?!) )

                # also works. Which is faster ? $hash{key} or exists $hash{key} ??
                  (?(?{ !$matched{0} }) (?&zero)      | (?!) )
                | (?(?{ !$matched{1} }) (?&one)       | (?!) )
                | (?(?{ !$matched{2} }) (?&two)       | (?!) )
                | (?(?{ !$matched{3} }) (?&three)     | (?!) )
                | (?(?{ !$matched{4} }) (?&four)      | (?!) )
                | (?(?{ !$matched{5} }) (?&five)      | (?!) )
                | (?(?{ !$matched{6} }) (?&six)       | (?!) )
                | (?(?{ !$matched{7} }) (?&seven)     | (?!) )
                | (?(?{ !$matched{8} }) (?&eight)     | (?!) )
                | (?(?{ !$matched{9} }) (?&nine)      | (?!) )
            )
        )

        (?<zero>
            (?{ local @nums=(@nums, 0) })
            [a-g]{6} \s+
            (?{ local %matched = (%matched, 0 => 1) })
        )
        (?<one>
            (?{ local @nums=(@nums, 1) })
            [a-g]{2} \s+
            (?{ local %matched = (%matched, 1 => 1) })
        )
        (?<two>
            (?{ local @nums=(@nums, 2) })
            [a-g]{5} \s+
            (?{ local %matched = (%matched, 2 => 1) })
        )
        (?<three>
            (?{ local @nums=(@nums, 3) })
            [a-g]{5} \s+
            (?{ local %matched = (%matched, 3 => 1) })
        )
        (?<four>
            (?{ local @nums=(@nums, 4) })
            [a-g]{4} \s+
            (?{ local %matched = (%matched, 4 => 1) })
        )
        (?<five>
            (?{ local @nums=(@nums, 5) })
            [a-g]{5} \s+
            (?{ local %matched = (%matched, 5 => 1) })
        )
        (?<six>
            (?{ local @nums=(@nums, 6) })
            [a-g]{6} \s+
            (?{ local %matched = (%matched, 6 => 1) })
        )
        (?<seven>
            (?{ local @nums=(@nums, 7) })
            [a-g]{3} \s+
            (?{ local %matched = (%matched, 7 => 1) })
        )
        (?<eight>
            (?{ local @nums=(@nums, 8) })
            [a-g]{7} \s+
            (?{ local %matched = (%matched, 8 => 1) })
        )
        (?<nine>
            (?{ local @nums=(@nums, 9) })
            [a-g]{6} \s+
            (?{ local %matched = (%matched, 9 => 1) })
        )


    )
    
/x;

say $nums;
say "";

while ($nums =~ /$regex/) {
# while ($nums =~ /$regex/g) {
    say "@res";
}

__DATA__
acedgfb cdfbe gcdfa fbcad dab cefabd cdfgeb eafb cagedb ab | cdfeb fcadb cdfeb cdbaf
