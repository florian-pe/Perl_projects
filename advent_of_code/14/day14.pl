#!/usr/bin/perl

use strict;
use warnings;
use v5.10;
# use dd;
use List::Util qw(pairmap);
use List::MoreUtils qw(slide);

chomp (my $template = <>);
my %insertion_rule;
my %rule;

while (<>) {
    next if /^\s*$/;
    my ($pair, $insert) = /^(\S+)\s+->\s+(\S+)/;
    $insertion_rule{$pair} = $insert;
}

for (keys %insertion_rule) {
    $rule{$_} =
        [     substr($_, 0, 1) . $insertion_rule{$_},
           $insertion_rule{$_} . substr($_, 1, 1)     ]
}

sub step {
    my $n = shift;
    my $polymer = shift;
    my %delta;
    my %pair_count;

    $pair_count{$_}++ for slide { "$a$b" } split "", $polymer;

    my $first_pair = substr($polymer, 0, 2);
    my $last_pair  = substr($polymer, -2);

    goto AFTER_FOR_LOOP if $n <= 0;

    for (1 .. $n) {
        %delta = ();
        $first_pair = $rule{$first_pair}->[0];
        $last_pair  = $rule{$last_pair}->[1];

        for my $pair (keys %pair_count) {
            $delta{$pair} -= $pair_count{$pair};

            $delta{ $rule{$pair}->[0] } += $pair_count{$pair};
            $delta{ $rule{$pair}->[1] } += $pair_count{$pair};
        }

        for my $delta (keys %delta) {

            $pair_count{$delta} += $delta{$delta};
        }
    }
    
    AFTER_FOR_LOOP:

    $first_pair, $last_pair, \%pair_count;
}

sub grok_pair_count {
    my ($first_pair, $last_pair, $pair_count) = @_;
    my %element_count;

    $pair_count->{$first_pair}--;
    $pair_count->{$last_pair}--;

    for my $pair (keys $pair_count->%*) {
        my ($elem_one, $elem_two) = split "", $pair;

        $element_count{$elem_one} += $pair_count->{$pair};
        $element_count{$elem_two} += $pair_count->{$pair};
    }

    $element_count{ substr($first_pair, 1, 1) }++;
    $element_count{ substr($last_pair,  0, 1) }++;

    for my $elem (keys %element_count) {
        $element_count{$elem} /= 2
    }

    $element_count{ substr($first_pair, 0, 1) }++;
    $element_count{ substr($last_pair,  1, 1) }++;

    my ($least_common, $most_common) =
    (sort { $element_count{$a} <=> $element_count{$b} } keys %element_count)[0, %element_count - 1];

    @element_count{$most_common, $least_common };
}

sub difference {
    $_[0] - $_[1]
}

# say "Part 1: ", difference grok_pair_count step 4, $template;

say "Part 1: ", difference grok_pair_count step 10, $template;
say "Part 2: ", difference grok_pair_count step 40, $template;


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






