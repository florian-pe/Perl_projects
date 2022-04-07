#!/usr/bin/perl

use strict;
use warnings;
use v5.10;
use List::Util qw(sum);

chomp (my @lines = <>);
my @stack;
my @index;
my @open_close;
my $i=0;
my $j=0;
my @illegal;
my @incomplete;
my @completion;

my %matching = (
    ")" => "(",
    "]" => "[",
    "}" => "{",
    ">" => "<",
    "(" => ")",
    "[" => "]",
    "{" => "}",
    "<" => ">",
);
my %points = (
    ")" => 3,
    "]" => 57,
    "}" => 1197,
    ">" => 25137,
);

my %score = (
    ")" => 1,
    "]" => 2,
    "}" => 3,
    ">" => 4,
);

sub union {
    my @intervals = sort { $a->[0] <=> $b->[0] } @_;
    my @union = shift @intervals;
    my $interval;
    while (@intervals) {
        $interval = shift @intervals;

        if ($interval->[0] <= $union[-1]->[1]) {
            if ($union[-1]->[1] < $interval->[1]) {
                $union[-1]->[1] = $interval->[1];
            }
        }
        else {
            push @union, $interval;
        }
    }
    return @union;
}

# my @array = ([5, 6], [8, 9], [10, 11]);
# my @array = ([5, 6], [4, 7]);
# dd \@array;
# dd union @array;
# 
# exit;

LINE:
for my $line (@lines) {
    my $idx = 0;
    my $last;
#     say "$i $line";
#     say "$j $line";
    @stack = ();
    @index = ();
    @open_close = ();
    for (split "", $line) {
        if (/[([{<]/) {
            push @stack, $_;
            push @index, $idx;
#             push @open_close, [$idx];
        }
#         elsif (/[])}>]/) {
        else {
            if ($stack[-1] eq $matching{$_}) {
                pop @stack;
#                 pop @index;
                push @open_close, [pop @index, $idx];
            }
            else {
                push @illegal, $_;
                next LINE;
#                 say "LOOP";
                say "illegal $_ on line $i";
                say substr($line, 0, $idx), RED, $_, RESET, "...";
                @open_close = union @open_close;
#                 dd \@open_close;


#                 print substr($line, 0, $open_close[0]->[0] // $idx);
                if (defined $open_close[0]->[0]) {
                    print substr($line, 0, $open_close[0]->[0]);
#                     say substr($line, 0, $open_close[0]->[0]);
#                     $last = $open_close[0]->[0] // $idx;
                    $last = $open_close[0]->[0];
                }
                else {
                    print substr($line, 0, $idx);
#                     say substr($line, 0, $idx);
                }
                my $len;

                for (my $i=0; $i < @open_close; $i++) {
                    next unless defined $open_close[$i]->[0];
                    $len = $open_close[$i]->[1]-$open_close[$i]->[0]+1;

#                     say GREEN, substr($line, $last, $len), RESET;
                    print GREEN, substr($line, $last, $len), RESET;

                    if (defined $open_close[$i+1]) {
#                         say substr($line, $last+$len, $last+$len-$open_close[$i+1]->[0]+1);
                        print substr($line, $last+$len, $open_close[$i+1]->[0]-$last-$len);
#                         $last += $len + $last+$len-$open_close[$i+1]->[0]+1;
                        $last += $len + $open_close[$i+1]->[0] - $last - $len;
                    }
                    else {
#                         $last = $curr;
                        $last += $len;
                    }
                }
                say RED, $_, RESET, "...";

                say "";
#                 exit;
                next LINE;
            }
        }
    } continue { $idx++ }

    push @incomplete, $line;
    push @completion, [ map { $matching{$_} } reverse @stack ];
}
continue { $i++ }
# continue { $j++ }


# dd \@illegal;


say "Part 1: ", sum map { $points{$_} } @illegal;

# nl;
# say for @incomplete;
# say @$_ for @completion;


my @scores;

for my $comp (@completion) {
    my $score = 0;
    for ($comp->@*) {
        $score *= 5;
        $score += $score{$_};
    }
    push @scores, $score;
}

say "Part 2: ", (sort { $a <=> $b } @scores)[ (@scores-1)/2 ];









