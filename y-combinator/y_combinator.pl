#!/usr/bin/perl

use strict;
use warnings;
use v5.10;

# exit unless @ARGV;

sub y_combinator {
	my $le = shift;
	return sub {
		my $f = shift;
		return $f->($f);
	}->(sub {
			my $f = shift;
			return $le->(sub {
				my $x = shift;
# 				return $f->(($f)->($x));
# 				return ($f->($f))->($x);
				return $f->($f)->($x);
			});
	});
}

my $factorial = y_combinator ( sub {
	my $fac = shift;
	return sub {
		my $n = shift;
		return $n <= 1 ? 1 : $n * $fac->($n-1);
	};
});

# say $factorial->(shift);
say $factorial->(5);

