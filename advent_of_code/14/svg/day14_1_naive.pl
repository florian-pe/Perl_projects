#!/usr/bin/perl

use strict;
use warnings;
use v5.10;
# use dd;

chomp (my $template = <>);
my %rule;
my $polymer;

while (<>) {
    next if /^\s*$/;
    my ($pair, $insert) = /^(\S+)\s+->\s+(\S+)/;
    $rule{$pair} = $insert;
}


# say "Template:\t$polymer";
# for (1 .. 4) {
#     $polymer = step($polymer);
#     say "After step $_:\t$polymer";
# }


sub most_least_common_diff {
    my $polymer = shift;
    my %count;
    $count{$_}++ for split "", $polymer;

    my ($least, $most)
    = (sort { $count{$a} <=> $count{$b} } keys %count)[0, %count -1];

    $count{$most} - $count{$least};
}

# say "Template:\t$polymer";
# $polymer = step($polymer) for 1 .. 10;
# for (1 .. 10) {
#     $polymer = step($polymer);
#     say "After step $_:\t$polymer";
# }
# 
# say "Part 1: ", most_least_common_diff($polymer);
# 
# $polymer = step($polymer) for 1 .. 30;
# for (11 .. 40) {
#     $polymer = step($polymer);
#     say "After step $_:\t$polymer";
#     say "After step $_:";
# }
# 
# 
# say "Part 2: ", most_least_common_diff($polymer);
# 


$polymer = step(40, $template);
# $polymer = step(10, $template);
# $polymer = step(3, $template);
# $polymer = step(1, $template);

# for (1 .. 4) {
#     $polymer = step($_, $template);
# 
#     say $polymer;
# }

# say "Part 1: ", most_least_common_diff($polymer);









__END__

takes too much memory for the 40 steps part 2

# 1 linked list of anonynmous hashes

sub step {
    my $polymer = shift;
    my @elements = map { { elem => $_ } } split "", $polymer;
    my $chain = $elements[0];
    my @polymer;
    my ($first, $second);

    for (my $i=0; $i < @elements-1; $i++) {

        ($first, $second) = @elements[$i .. $i+1];

        $first->{next} = $second;
    }

    my $ptr = $chain;
    while (exists $ptr->{next}) {

        $first = $ptr;
        $ptr = $ptr->{next};
        $second = $ptr;

        $first->{next} = {
            elem => $rule{ $first->{elem} . $second->{elem} },
            next => $second,
        };
    }

    $ptr = $chain;

    while (exists $ptr->{next}) {
        push @polymer, $ptr->{elem};
        $ptr = $ptr->{next};
    }
    push @polymer, $ptr->{elem};

    return join "", @polymer;
}


# 2 array

# 3 string

sub step {
    my $polymer = shift;
    my $new_polymer = substr($polymer, 0, 1);
    my ($first, $second);

    for (my $i=1; $i < length $polymer; $i++) {

        $first = substr($new_polymer, -1);
        $second = substr($polymer, $i, 1);

        $new_polymer .= $rule{ $first . $second } . $second;
    }

    return $new_polymer;
}


# 4 recursion


my $count = 0;

sub apply_rule {
    if ($_[0] == 1) {
#         $_[1] . $rule{ $_[1] . $_[2] } . $_[2]
        $count++;
        say $count++;
    }
    else {
#         apply_rule($_[0] - 1, $_[1], $rule{ $_[1] . $_[2] })
#         .
#         apply_rule($_[0] - 1, $rule{ $_[1] . $_[2] }, $_[2])

#         apply_rule($_[0] - 1, $_[1], $rule{ $_[1] . $_[2] });
#         apply_rule($_[0] - 1, $rule{ $_[1] . $_[2] }, $_[2]);
        apply_rule($_[0] - 1);
        apply_rule($_[0] - 1);
    }
#     0;
}

sub step {
#     join "", pairmap { apply_rule($_[0], $a, $b) } slide { $a, $b } split "", $_[1];
    
    pairmap { apply_rule($_[0], $a, $b) } slide { $a, $b } split "", $_[1];
 
    return 0;


    #
#     say join "", pairmap { apply_rule($_[0], $a, $b) } slide { $a, $b } split "", $_[1];
#     say pairmap { "$a,$b|" } slide { $a, $b } split "", $_[1];
#     say slide { $a, $b } split "", $_[1];
#     exit;
}


# iteration is not possible because there is too much elements produced


# 5 

template = HH

number of elements at step = n ==> 2 + 2 ** (n-1)   (for n >= 1)

step    elements    sliding_elements   sliding_pairs
0           2             2              1
1           3             4              2
2           5             8              4
3           9             16             8
4           17            32            16
5           33                          32
6           65                          64
7           129                         128
8           257                         256
9           513                         512
10          1025                        1024


AB
BC CD DE EF FG GH HI
IJ

A
B BC CD DE EF FG GH HI I
I

besides first and last, each character appear 2 times

$first_pair
$last_pair

CD  => 44
DG  => 12
HD  => 24


start = HD
end   = DG

CD  => 44
DG  => 11
HD  => 23


C = (44    + 2 + 2)/2
D = (44+11)/2
G = 11/2
H = 23/2






