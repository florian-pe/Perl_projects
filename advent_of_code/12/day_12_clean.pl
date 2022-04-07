#!/usr/bin/perl

use strict;
use warnings;
use v5.10;

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
#     return if $node =~ /^[[:lower:]]+$/ ? $visited->{$node}++ : 0;
    return if $node eq lc $node ? $visited->{$node}++ : 0;
    $count++, return if $node eq "end";
    dfs($_, $visited) for $nodes{$node}->@*;
}

dfs("start", {});
say $count;


__END__

