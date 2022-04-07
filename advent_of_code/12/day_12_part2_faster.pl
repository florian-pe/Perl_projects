#!/usr/bin/perl

use strict;
use warnings;
use v5.10;

my (%nodes, $count);
# my ($a, $b);

while (<>) {
#     my ($a,$b) = /^(.*?)-(.*)/;
#     my ($a,$b) = /^(.*?)-(.*)/;
    chomp;
    my ($a,$b) = split "-", $_;
#     ($a,$b) = split "-", $_;


    push $nodes{ $a }->@*, $b;
    push $nodes{ $b }->@*, $a;
}

sub dfs {
    my ($node, $visited, $two) = @_;
    my $saved = $visited->{$node};

    if ($node eq "start") {
        return if $visited->{start}++ > 0
    }
    elsif ($node eq "end") {
        $count++;
        return;
    }
    elsif ($node eq lc $node) {
        if ($two) {
            return if $visited->{$node}++
        }
        else {
            $two = 1 if $visited->{$node}++
        }
    }

    dfs($_, $visited, $two) for $nodes{$node}->@*;
    $visited->{$node} = $saved;
}

dfs("start", {}, 0);
say $count;

