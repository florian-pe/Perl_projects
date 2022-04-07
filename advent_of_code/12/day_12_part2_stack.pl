#!/usr/bin/perl

use strict;
use warnings;
use v5.10;

my (%nodes, $count);

while (<>) {
    my ($a,$b) = /^(.*?)-(.*)/;
    push $nodes{ $a }->@*, $b;
    push $nodes{ $b }->@*, $a;
}

my $visited = {};

# $return       $stack[-6]
# $node         $stack[-5]
# $saved        $stack[-4]
# $two          $stack[-3]
# $no_nodes     $stack[-2]
# $i            $stack[-1]

my @stack = (undef) x 1024;
my $SP = 0;

@stack[$SP .. $SP + 5]   = ("FINAL", "start", undef, 0, undef, -1);
$SP += 6;

DFS:
# sub dfs {
$stack[$SP - 4] = $visited->{$stack[$SP - 5]};

if ($stack[$SP - 5] eq "start") {
    if ($visited->{start}++ > 0) {

        $SP -= 6;
        goto $stack[ $SP ];
    }
}
elsif ($stack[$SP - 5] eq "end") {
    $count++;

    $SP -= 6;
    goto $stack[ $SP ];
}
elsif ($stack[$SP - 5] eq lc $stack[$SP - 5]) {
    if ($stack[$SP - 3]) {
        if ($visited->{$stack[$SP - 5]}++) {

            $SP -= 6;
            goto $stack[ $SP ];
        }
    }
    else {
        if ($visited->{$stack[$SP - 5]}++) {
            $stack[$SP - 3] = 1
        }
    }
}

$stack[$SP - 2] = $nodes{$stack[$SP - 5]}->@*;

LOOP:
$stack[$SP - 1]++;

if ($stack[$SP - 1] < $stack[$SP - 2]) {

    @stack[$SP .. $SP + 5] =
    ("LOOP", $nodes{$stack[$SP - 5]}->[$stack[$SP - 1]], undef, $stack[$SP - 3], undef, -1);
    $SP += 6;

    goto DFS;
}

$SP -= 6;
$visited->{ $stack[$SP + 1] } = $stack[$SP + 2];
goto $stack[ $SP ];

# }

FINAL:
say "FINAL";

# dfs("start", 0);

say $count;




