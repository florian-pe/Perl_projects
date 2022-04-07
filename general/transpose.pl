#!/usr/bin/perl

use strict;
use warnings;
use v5.10;

sub zip {
    my ($array_a, $array_b)=@_;
    return [ map {
        if (ref $array_a->[$_] eq "ARRAY") {
            [$array_a->[$_]->@*, $array_b->[$_]]
        }
        else {
            [$array_a->[$_], $array_b->[$_]]
        }
    } 0..$array_a->$#*]
}

sub reduce {
    my $code = shift;
	my $acc = shift;
    while (@_) {
        $acc = $code->($acc, shift);
    }
    return $acc;
}


sub transpose { reduce \&zip, @_ }

say $_->@* for (transpose [1,2,3], [4,5,6], [7,8,9])->@*;




