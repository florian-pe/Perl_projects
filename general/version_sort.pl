#!/usr/bin/perl

use strict;
use warnings;
use v5.10;

sub version_sort {	# sort version_sort LIST
	my ($c,$d) = ($a,$b);
	my ($elem_a, $elem_b);
	
	while (1) {
		if ($c =~ m/^\d/) {
			if ($d =~ m/^\d/) {
				($elem_a) = $c =~ m/^(\d+)/;
				($elem_b) = $d =~ m/^(\d+)/;
				if ($elem_a != $elem_b) {
					return $elem_a <=> $elem_b
				}
				else {
					$c =~ s/^\d+//;
					$d =~ s/^\d+//;
				}
			}
			elsif ($d =~ m/^\D/) {
				return -1; # numbers before letters
			}
			elsif (length $d == 0) {
				return 1;	# shortest first
			}
		}
		elsif ($c =~ m/^\D/) {
			if ($d =~ m/^\d/) {
				return 1; # numbers before letters
			}
			elsif ($d =~ m/^\D/) {
				($elem_a) = $c =~ m/^(\D+)/;
				($elem_b) = $d =~ m/^(\D+)/;
				if ($elem_a ne $elem_b) {
					return $elem_a cmp $elem_b
				}
				else {
					$c =~ s/^\D+//;
					$d =~ s/^\D+//;
				}
			}
			elsif (length $d == 0) {
				return 1;	# shortest first
			}
		}
		elsif (length $c == 0) {
			if (length $d == 0) {
				return 0
			}
			else {
				return -1;	# shortest first
			}
		}
	}
}

say join "\n", sort version_sort map {chomp; $_} <STDIN>;


