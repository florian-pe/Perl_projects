#!/usr/bin/perl

use strict;
use warnings;
use v5.10;
use List::Util qw(all);

my $heightmap;
my $y = 0;
while (<>) {
    chomp;
    $heightmap->[$y] = [ split "", $_ ];
    $y++;
}

# dd $heightmap;
# say @$_ for @$heightmap;

my $X = $heightmap->[0]->@* - 1;
my $Y = $y - 1;
# say $width, $height;

my $height;
my @low_points;
my $risk_level;


# for my $y (0 .. $Y) {
#     for my $x (0 .. $X) {
# 
#         $height = $heightmap->[$y][$x];
# 
#         # EDGES
#         if ($x == 0  && 0 < $y < $Y) {
#             if (all { $height < $_ } $heightmap->[$y-1][0], $heightmap->[$y+1][0], $heightmap->[$y][1]) {
#                 $risk_level += $height + 1;
#                 push @low_points, [$x,$y], 1;
#             }
#         }
#         elsif ($x == $X && 0 < $y < $Y) {
#             if (all { $height < $_ } $heightmap->[$y-1][$X], $heightmap->[$y+1][$X], $heightmap->[$y][$X-1]) {
#                 $risk_level += $height + 1;
#                 push @low_points, [$x,$y], 2;
#             }
#         }
#         elsif ($y == 0  && 0 < $x < $X) {
#             if (all { $height < $_ } $heightmap->[0]->@[$x-1,$x+1], $heightmap->[1][$x]) {
#                 $risk_level += $height + 1;
#                 push @low_points, [$x,$y], 3;
#             }
#         }
#         elsif ($y == $Y && 0 < $x < $X) {
#             if (all { $height < $_ } $heightmap->[$Y]->@[$x-1,$x+1], $heightmap->[$Y-1][$x]) {
#                 $risk_level += $height + 1;
#                 push @low_points, [$x,$y], 4;
#             }
#         }
#         # CORNERS
#         elsif ($x == 0  && $y == 0) {
#             if (all { $height < $_ } $heightmap->[0][1], $heightmap->[1][0]) {
#                     # THIS
#                 $risk_level += $height + 1;
#                 push @low_points, [$x,$y], 5;
#             }
#         }
#         elsif ($x == 0  && $y == $Y) {
#             if (all { $height < $_ } $heightmap->[$Y-1][0], $heightmap->[$Y][1]) {
#                 $risk_level += $height + 1;
#                 push @low_points, [$x,$y], 6;
#             }
#         }
#         elsif ($x == $X && $y == 0) {
#             if (all { $height < $_ } $heightmap->[0][$X-1], $heightmap->[1][$X]) {
#                 $risk_level += $height + 1;
#                 push @low_points, [$x,$y], 7;
#             }
#         }
#         elsif ($x == $X && $y == $Y) {
#             if (all { $height < $_ } $heightmap->[$Y-1][$X], $heightmap->[$Y][$X-1]) {
#                 $risk_level += $height + 1;
#                 push @low_points, [$x,$y], 8;
#             }
#         }
#         # NOT EDGE NOR CORNER
#         else {
#             if (all { $height < $_ } $heightmap->[$y]->@[$x-1,$x+1],
#                                      $heightmap->[$y-1]->[$x], $heightmap->[$y+1][$x] ) {
#                 $risk_level += $height + 1;
#                 push @low_points, [$x,$y], 9;
#             }
#         }
#     }
# }

for my $y (0 .. $Y) {
    for my $x (0 .. $X) {

        $height = $heightmap->[$y][$x];

#         if (all { $height < $_ } grep { defined } $heightmap->[$y]->@[$x-1,$x+1],
#         if (all { $height < $_ } map {$_+0} grep { defined } $heightmap->[$y]->@[$x-1,$x+1],
        if (all { $height < $_ } map {$_+0} grep { defined } $heightmap->[$y]->[$x-1], $heightmap->[$y][$x+1],
                                 $heightmap->[$y-1]->[$x], $heightmap->[$y+1][$x] ) {
            $risk_level += $height + 1;
            push @low_points, [$x,$y], 9;

#             say "$height < ", join " ", grep { $height < $_ } grep { defined } $heightmap->[$y]->@[$x-1,$x+1],
#                                  $heightmap->[$y-1]->[$x], $heightmap->[$y+1][$x];

        }
        elsif ($x == 0 && $y == 22) {
#             say "one";
#             say "height $height";

#             dd all { $height < $_ } grep { defined } $heightmap->[$y]->@[$x-1,$x+1], $heightmap->[$y-1]->[$x], $heightmap->[$y+1][$x];
#             dd grep { defined } $heightmap->[$y]->@[$x-1,$x+1], $heightmap->[$y-1]->[$x], $heightmap->[$y+1][$x];

        }
        elsif ($x == 0 && $y == 46) {
            say "two";
            say "height $height";

#             dd all { $height < $_ } grep { defined } $heightmap->[$y]->@[$x-1,$x+1], $heightmap->[$y-1]->[$x], $heightmap->[$y+1][$x];

          dd grep { defined } $heightmap->[$y]->@[$x-1,$x+1], $heightmap->[$y-1]->[$x], $heightmap->[$y+1][$x];
          dd $heightmap->[$y]->@[-1];
        }

#         dd map { 0+$_ } grep {defined} $heightmap->[$y]->@[$x-1,$x+1], $heightmap->[$y-1]->[$x], $heightmap->[$y+1][$x];
   
    }
}


say "Part 1: $risk_level";

# dd @low_points;
# say join "\n", map { "($_->[0],$_->[1])" } grep {ref} @low_points;

sub print_map {
#     say @$_ for @$heightmap;

    for my $y (0 .. $Y) {
        for my $x (0 .. $X) {
            $height = $heightmap->[$y][$x];

            if (grep { ref eq "ARRAY" && $x == $_->[0] && $y == $_->[1] } @low_points) {
                print GREEN, $height, RESET;
            }
            else {
                print $height;
            }
        }
        say "";
    }
}

# print_map();



say "$heightmap->[22][0] < ", join " ", grep { $heightmap->[22][0] < $_ } grep { defined } $heightmap->[22]->@[-1,1],
                                $heightmap->[21]->[0], $heightmap->[23][0];

say "$heightmap->[46][0] < ", join " ", grep { $heightmap->[46][0] < $_ } grep { defined } $heightmap->[46]->@[-1,1],
                                $heightmap->[45]->[0], $heightmap->[47][0];













