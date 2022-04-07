#!/usr/bin/perl

use strict;
use warnings;
use v5.10;
use List::Util qw(all product);

my $heightmap;
my $y = 0;
while (<>) {
    chomp;
    $heightmap->[$y] = [ split "", $_ ];
    $y++;
}

my $X = $heightmap->[0]->@* - 1;
my $Y = $y - 1;
my $height;
my $risk_level;
my @low_points;
my @basins;
my %seen;

for my $y (0 .. $Y) {
    for my $x (0 .. $X) {

        $height = $heightmap->[$y][$x];

        if (all { $height < $_ } grep { defined }
            $x-1 >= 0  ? $heightmap->[$y]->[$x-1] : (),
            $x+1 <= $X ? $heightmap->[$y]->[$x+1] : (),
            $y-1 >= 0  ? $heightmap->[$y-1]->[$x] : (),
            $y+1 <= $Y ? $heightmap->[$y+1][$x]   : () )
        {
            $risk_level += $height + 1;
            push @low_points, [$x,$y];
        }
    }
}


say "Part 1: $risk_level";

sub neighbours {
    my ($x, $y) = @_;
    grep { defined }
    $x-1 >= 0  ? [$x-1, $y  ] : (),
    $x+1 <= $X ? [$x+1, $y  ] : (),
    $y-1 >= 0  ? [$x,   $y-1] : (),
    $y+1 <= $Y ? [$x,   $y+1] : ()
}

sub basin_size {
    my ($point) = @_;
    my ($x, $y) = $point->@*;
    my $height = $heightmap->[$y][$x];
    $seen{join(",", $x, $y)}++;

    return
    map { basin_size($_), $_ }
    grep { !$seen{join(",", @$_)}++ }
    grep { $heightmap->[ $_->[1] ][ $_->[0] ] > $height }
    grep { $heightmap->[ $_->[1] ][ $_->[0] ] != 9 }
    neighbours($x, $y);
}


for my $lowpoint (@low_points) {

    %seen = ();

#     push @basins, basin_size($lowpoint);
#     push @basins, $count = () = basin_size($lowpoint);
    push @basins, 1 + basin_size($lowpoint);
#     push @basins, scalar basin_size($lowpoint);

#     say "($lowpoint->[0],$lowpoint->[1]) ", $basins[-1];
#     say %seen;

#     dd basin_size($lowpoint);

#     push @basins, 0+grep { !$seen{join(",", @$_)}++ } basin_size($lowpoint);
#     exit;
}

# dd \@basins;

say "Part 2: ", join "|", ( (sort {$a <=> $b} @basins)[-3 .. -1] );
say "Part 2: ", product( (sort {$a <=> $b} @basins)[-3 .. -1] );









