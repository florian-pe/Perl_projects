#!/usr/bin/perl

use strict;
use warnings;
use v5.10;
use List::Util qw(sum);
use List::AllUtils qw(zip_by);

my $zip = sub {
    my ($array_a, $array_b)=@_;
    return [ map {
        if (ref $array_a->[$_] eq "ARRAY") {
            [$array_a->[$_]->@*, $array_b->[$_]]
        }
        else {
            [$array_a->[$_], $array_b->[$_]]
        }
    } 0..$array_a->$#*]
};

sub reduce {
    my $code = shift;
	my $acc = shift;
    while (@_) {
        $acc = $code->($acc, shift);
    }
    return $acc;
}

sub transpose { reduce $zip, @_ }

chomp(my @random_numbers = split ",", <>);
my @random_numbers_copy = @random_numbers;

my @boards;
my $i = 0;

while (defined (my $line = <>)) {
    next if $line =~ /^\s*$/;

    push($boards[$i]->{row_array}->@*, [ $line =~ /(\d+)/g ]);
    push($boards[$i]->{row_array}->@*, [   <>  =~ /(\d+)/g ]) for 1..4;

    $i++;
}

for my $board (@boards) {

    for my $row ($board->{row_array}->@*) {

        push $board->{rows}->@*, { map { $_ => 1 } $row->@* };
    }

    for (transpose($board->{row_array}->@*)->@*) {
#     for (zip_by { [@_] } ($board->{row_array}->@*)->@*) {
#     for (zip_by { [@_] } $board->{row_array}->@*) {

        push $board->{columns}->@*, { map { $_ => 1 } $_->@* };
    }
}

sub board_wins {
    my ($board, $numbers) = @_;

    ROW:
    for my $row ($board->{rows}->@*) {

        for my $n (keys $row->%*) {

            next ROW if ! exists $numbers->{$n};
        }
        return 1;
    }

    COLUMN:
    for my $col ($board->{columns}->@*) {

        for my $n (keys $col->%*) {

            next COLUMN if ! exists $numbers->{$n};
        }
        return 1;
    }

    return 0;
}

my %numbers;
my $last_number;
my $winner;

sub score {
    my ($board, $numbers, $last_number) = @_;

    my @board_numbers = map { $_->@* } $board->{row_array}->@*;

    $last_number * sum grep { ! exists $numbers{$_} } @board_numbers;
}

for (1..4) {
    $numbers{ shift @random_numbers } = 1
}

RANDOM_NUMBER:
while (@random_numbers) {

    $last_number = shift @random_numbers;
    $numbers{ $last_number } = 1;

    for (my $i=0; $i < @boards; $i++) {

        if (board_wins($boards[$i], \%numbers)) {
            $winner = $i;
            last RANDOM_NUMBER;
        }
    }

}

if (defined $winner) {

    say "Part 1: board ", $winner+1, " wins with ",
        score($boards[$winner], \%numbers, $last_number),
        " points";
}
else {
    say "no winner";
}

%numbers = ();
my $last_winner;
my $resting_players = @boards;
$last_number = undef;


for (1..4) {
    $numbers{ shift @random_numbers_copy } = 1
}

RANDOM_NUMBER:
while (@random_numbers_copy) {

    $last_number = shift @random_numbers_copy;
    $numbers{ $last_number } = 1;

    for (my $i=0; $i < @boards; $i++) {

        next if $boards[$i]->{won};

        if (board_wins($boards[$i], \%numbers)) {

            $boards[$i]->{won} = 1;
            $resting_players--;
            $last_winner = $i;

            last RANDOM_NUMBER if $resting_players == 0;
        }
    }
}

if (defined $last_winner) {

    say "Part 2: board ", $last_winner+1, " wins last with ",
        score($boards[$last_winner], \%numbers, $last_number),
        " points";
}
else {
    say "no last winner";
}




