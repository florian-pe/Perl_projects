#!/usr/bin/perl

use strict;
use warnings;
use v5.10;
use List::Util qw(any);

my (%nodes, $count);
our $visited;

while (<>) {
    my ($a,$b) = /^(.*?)-(.*)/;
    push $nodes{ $a }->@*, $b;
    push $nodes{ $b }->@*, $a;
}

sub dfs {
    my $node = shift;
    local $visited = { shift->%* };

    if ($node eq "start") {
        return if $visited->{start}++ > 0
    }
    elsif ($node eq "end") {
        $count++;
        return;
    }
#     elsif ($node =~ /^[[:lower:]]+$/) {
    elsif ($node eq lc $node) {
#         if (grep { $visited->{$_} == 2 } grep { /^[[:lower:]]+$/ } keys $visited->%*) {
#         if (any { $visited->{$_} == 2 } grep { /^[[:lower:]]+$/ } keys $visited->%*) {
        if (any { $visited->{$_} == 2 } grep { $_ eq lc } keys $visited->%*) {
            return if $visited->{$node}++
        }
        else {
            return if ++$visited->{$node} > 2
        }
    }

    dfs($_, $visited) for $nodes{$node}->@*;
}

dfs("start", {});
say $count;


__END__

