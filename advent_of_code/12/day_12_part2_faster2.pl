#!/usr/bin/perl

use strict;
use warnings;
use v5.10;
# use y;;;;

my (%nodes, $count);

while (<>) {
    my ($a,$b) = /^(.*?)-(.*)/;
    push $nodes{ $a }->@*, $b;
    push $nodes{ $b }->@*, $a;
}

# my @stack = ("FINAL", -1, "start", {}, 0);
my @stack = ("FINAL", "start", {}, 0);
# my @stack = ("FINAL", -1, "start", {}, 0, []);
my ($return, $two, $visited, $node);
my $saved;
my $no_nodes;
my $i;
my $path;

DFS:
# $path = pop @stack
($two, $visited, $node) = (pop @stack, pop @stack, pop @stack);

# push $path->@*, $node;
$saved = $visited->{$node};

# say $node;
# say "$node ", $visited->{$node} // 0;

if ($node eq "start") {
#     say "start ", $visited->{start} // 0;
    if ($visited->{start}++ > 0) {
#         pop @stack;
#         pop @stack;
        say "goto 1 $stack[-1]";
#             __;
        $visited->{start}--;
        goto pop @stack;
    }
}
elsif ($node eq "end") {
    say "END";
    $count++;
    say $count;

#     pop @stack;
#     pop @stack;
    say "goto 2 $stack[-1]";
#             __;
    goto pop @stack;
}
elsif ($node eq lc $node) {
    if ($two) {
#         say "two";
        if ($visited->{$node}++) {
#             pop @stack;
#             pop @stack;
#             say $node;
            say "goto 3 $stack[-1]";
#             __;
            $visited->{$node}--;
            goto pop @stack;
        }
    }
    else {
        $two = 1 if $visited->{$node}++
    }
}

$no_nodes = $nodes{$node}->@*;

# say join "|", $nodes{$node}->@*;

push @stack, ($node, $saved, -1);

LOOP:
$stack[-1]++;

if ($stack[-1] < $no_nodes) {

#     say "CALLING $nodes{$node}->[$stack[-1]]";
#     push @stack, ("RETURN", -1, $nodes{$node}->[$stack[-1]], $visited, $two);
    push @stack, ("LOOP", $nodes{$stack[-3]}->[$stack[-1]], $visited, $two);
    goto DFS;

}

# $visited->{$node} = $saved;

# say @stack;
pop @stack;
# pop @stack;

$visited->{pop @stack} = pop @stack;

say "goto 4 $stack[-1]";
goto pop @stack;


FINAL:
say "FINAL";
say $count;

