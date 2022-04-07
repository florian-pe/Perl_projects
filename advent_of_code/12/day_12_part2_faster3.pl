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


my $frame;
my @stack = { node => "start", visited => {}, two => 0 };

# DFS:
sub dfs {
# $frame = shift @stack;
$frame = shift;
$frame->{saved} = $frame->{visited}->{ $frame->{node} };

if ($frame->{node} eq "start") {
    return if $frame->{visited}->{start}++ > 0
}
elsif ($frame->{node} eq "end") {
    $count++;
    return;
}
elsif ($frame->{node} eq lc $frame->{node}) {
    if ($frame->{two}) {
        return if $frame->{visited}->{ $frame->{node} }++
    }
    else {
        $frame->{two} = 1 if $frame->{visited}->{ $frame->{node} }++
    }
}

dfs({ node => $_, visited => $frame->{visited}, two => $frame->{two}}) for $nodes{ $frame->{node} }->@*;

$frame->{visited}->{ $frame->{node} } = $frame->{saved};
}

# dfs("start", {}, 0);
dfs({node => "start", visited => {}, two => 0 });
say $count;

