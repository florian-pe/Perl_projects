#!/usr/bin/perl

use strict;
use warnings;
use v5.10;
use List::Util qw(any);

my (%nodes, $count);
# our $visited;

while (<>) {
    my ($a,$b) = /^(.*?)-(.*)/;
    push $nodes{ $a }->@*, $b;
    push $nodes{ $b }->@*, $a;
}

our $visited = {};

sub dfs {
    my $node = shift;
#     local $visited = { shift->%* };
#     local $visited->{$node}++;
#     local $visited->{$node}+=1;
#     local $visited->{$node}=$visited->{$node}+1;
    my $val =($visited->{$node} // 0)+1; local $visited->{$node}=$val;
    say "val \"$val\"";

    if ($node eq "start") {
#         return if $visited->{start}++ > 0
        return if $visited->{start} > 0
    }
    elsif ($node eq "end") {
        $count++;
        return;
    }
    elsif ($node eq lc $node) {
        if (any { $visited->{$_} == 2 } grep { $_ eq lc } keys $visited->%*) {
#             return if $visited->{$node}++
            return if $visited->{$node}
        }
        else {
#             return if ++$visited->{$node} > 2
            return if $visited->{$node} > 2
#             ++$visited->{$node}
        }
    }

#     dfs($_, $visited) for $nodes{$node}->@*;
    dfs($_) for $nodes{$node}->@*;
}

# dfs("start", {});
dfs("start");
say $count;

