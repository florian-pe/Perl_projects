#!/usr/bin/perl

use strict;
use warnings;
use v5.10;

my @report;

while (<>) {
    chomp;
    push @report, [ split "", $_ ]
}

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

sub binary_to_decimal {
    my ($num, $i);
    $num += ($_ * 2 ** $i++) for reverse split "", shift;
    $num;
}

my ($gamma_rate, $epsilon_rate);
my $power_consumption;

for (transpose(@report)->@*) {
    my $one  = grep { $_ == 1 } $_->@*;
    my $zero = grep { $_ == 0 } $_->@*;

    if ($one > $zero) {
        $gamma_rate   .= 1;
        $epsilon_rate .= 0;
    }
    else {
        $gamma_rate   .= 0;
        $epsilon_rate .= 1;
    }
}

$gamma_rate   = binary_to_decimal $gamma_rate;
$epsilon_rate = binary_to_decimal $epsilon_rate;

$power_consumption = $gamma_rate * $epsilon_rate;

say "Part 1: $power_consumption";


sub bit_criteria {
    my $criteria = shift;
    my $bit = shift;
    my (@one, @zero);
    my $number;
    while ($_[0]->@*) {
        $number = shift $_[0]->@*;
        if ($number->[ $bit ]) {
            push @one, $number;
        }
        else {
            push @zero, $number;
        }
    }
    if ($criteria eq "most") {
        @one >= @zero ? \@one : \@zero;
    }
    elsif ($criteria eq "least") {
        @one >= @zero ? \@zero : \@one;
    }
}

my ($oxygen_generator_rating, $C02_scrubber_rating);
my $life_support_rating;

my $oxygen_nums = [@report];
my $CO2_nums    = [@report];

my $i = 0;

while ($oxygen_nums->@* > 1) {
    $oxygen_nums = bit_criteria("most", $i, $oxygen_nums);
    $i++;
}

$i = 0;

while ($CO2_nums->@* > 1) {
    $CO2_nums = bit_criteria("least", $i, $CO2_nums);
    $i++;
}

$oxygen_generator_rating = binary_to_decimal join "", $oxygen_nums->[0]->@*;
$C02_scrubber_rating     = binary_to_decimal join "", $CO2_nums->[0]->@*;

$life_support_rating = $oxygen_generator_rating * $C02_scrubber_rating;
say "Part 2: $life_support_rating";

__END__

bits from left to right

1   most common = first bit of gamma rate
2   most common = 2nd
3
4
5



















