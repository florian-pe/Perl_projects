#!/usr/bin/perl

use strict;
use warnings;
use v5.10;
# use dd;

my $c;
my %nodes;

open my $fh, "<", "./input";
for (<$fh>) {
    my ($a,$b) = /^(.*?)-(.*)/;
    push $nodes{ $a }->@*, $b;
    push $nodes{ $b }->@*, $a;
}
close $fh;

my $node="start";

# my %seen;
# $seen{start}++;


# say join "|", grep { !$seen{$_}++ } $nodes{ $node }->@*;
# say join "|", grep { /^[[:upper:]]+$/ } $nodes{ $node }->@*;
# say join "|", grep { /^[[:lower:]]+$/ } $nodes{ $node }->@*;

# say join "|", grep { /^[[:lower:]]+$/ ? !$seen{$_}++ : 1 } $nodes{ $node }->@*;


# for $to (grep { !$seen{$_}++ } $nodes{ $node }->@*) {
# 
# }

# for my $to (grep { /^[[:lower:]]+$/ ? !$seen{$_}++ : 1 } $nodes{ $node }->@*) {
#     
# }


# dd \%nodes;
# exit;

# my %visited;

# sub dfs {
#     my $node = shift;
#     # return if $visited{$node}++;
#     return if $node=~/^[[:lower:]]+$/ ? $visited{$node}++ : 0;
#     # say $node;
#     say $node if $node eq "end";
#     dfs($_) for $nodes{$node}->@*;
# }


# dfs("start");

our $path;
our $visited;

sub dfs {
    my $node = shift;
#     local $path;
#     local $visited;
#     $path = shift;
#     $visited = shift;
#     local $path = shift;
#     local $visited = shift;
#     local $path = $path;
#     local $visited = $visited;

    local $path = [ shift->@* ];
    local $visited = { shift->%* };

#     say $node;
#     dd $visited;

#     return if $visited{$node}++;
#     return if ($node=~/^[[:lower:]]+$/ ? $visited->{$node}++ : 0);
    return if ($node=~/^[[:lower:]]+$/ ? $visited->{$node} : 0);
    $visited->{$node}++;

#     say $node;
    push $path->@*, $node;
#     say join ",", $path->@*;

#     say $node;
#     say $node if $node eq "end";
#     say join ",", $path->@* if $node eq "end";

    if ($node eq "end") {
#         say $node;
#         say "END: ", join ",", $path->@*;
        say join ",", $path->@*;

        return;
    }

#     dfs($_) for $nodes{$node}->@*;
#     dfs($_, $path, $visited) for $nodes{$node}->@*;

    for ($nodes{$node}->@*) {

#     for (grep { /^[[:lower:]]+$/ ? !$visited->{$_} : 1 } $nodes{ $node }->@*) {
#     for (grep { /^[[:lower:]]+$/ ? !$visited->{$_} : 1 } $nodes{ $node }->@*) {

#         local $path = $path;
#         local $visited = $visited;
#         say "-> $_";
#         say join ",", $path->@*;

        dfs($_, $path, $visited)
    }
}


# dfs("start");
# dfs("start", ["start"]);
dfs("start", [], {});



__END__

