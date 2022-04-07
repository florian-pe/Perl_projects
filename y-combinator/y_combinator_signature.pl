#!/usr/bin/perl

use strict;
use warnings;
use v5.10;
use feature 'signatures';
no warnings 'experimental::signatures';

# exit unless @ARGV;

sub y_combinator ($le) {
	return sub ($f) {
		return $f->($f);
	}->(sub ($f) {
			return $le->(sub ($x) {
				return $f->($f)->($x);
			});
	});
}

my $factorial = y_combinator ( sub ($fac) {
	sub ($n) {
		$n <= 1 ? 1 : $n * $fac->($n-1);
	};
});

# say $factorial->(shift);
say $factorial->(5);

