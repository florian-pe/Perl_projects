#!/usr/bin/perl

use strict;
use warnings;
use y;;;;
use Data::Dumper;
$Data::Dumper::Purity = 1;

# open my $FH, ">>", "data_dump.txt";
# my @array=(1,2,3);
# print $FH Data::Dumper->Dump([\@array],["*array"]);		# WORKS
# close $FH;
# do "./data_dump.txt"; print @array;


# formule brute   Cn Hm Nx Oy Sz
# ---------------------------------------------------------------------------------------- 
# find all hydrocarbures with only simple bonds Cn H2n+2
# start from  CH4 and substitute -H by -CH3 to obtain all C2H6,
# and when found all C2H6, eliminate the identical molecules
# - find all C-H bonds
# ---------------------------------------------------------------------------------------- 
# - replace the H node by CH3
# EDGE LIST
# remove Cid - H id
# add Cid - CH3 --> (Cid - C otherid) (Cotherid - Hnewid1) (Cotherid - Hnewid2) (Cotherid - Hnewid3)
# ADJACENCY MATRIX ??   --> triangle = (square - diagonale) / 2
# remove X and Y columns Hid
# add C, H, H, H columns on X and Y column axis
# add 1 to  (Cid - C otherid) (Cotherid - Hnewid1) (Cotherid - Hnewid2) (Cotherid - Hnewid3)
# and the reverse : (if square adjacency matrix)
# add 1 to  reverse(Cid - C otherid) reverse(Cotherid - Hnewid1) reverse(Cotherid - Hnewid2) reverse(Cotherid - Hnewid3)
# ---------------------------------------------------------------------------------------- 
# - (only the first) push it into the array
# - (every one except the first) compare the new molecule to every one of the array
# and if it doesn't match any of them, puh the new molecule on the array
# ---------------------------------------------------------------------------------------- 
# comparison of 2 molecules for identity
# ==> graph isomorphism algorithm
# quasi polynomial polylog babai 2015 2017
# 
# ---------------------------------------------------------------------------------------- 
# remove identitcal hydrocarbures -> symmetry, 5 symmetry operations (identical, rotation, ...)
# 
# ---------------------------------------------------------------------------------------- 
# graph --> edge list, adjency matrix, other matrix
# 
# ---------------------------------------------------------------------------------------- 
# 
# from list of hydrocarbures, find all the solution of the arithmetic equation : xxx ??
# 
# 0 or more double bonds
# 0 or more triple bonds
# 0 or more cycles
# functional group

# ---------------------------------------------------------------------------------------- 

# molecule graph --> "inline" formule developpee ??
# find longest chain ?

# OUTPUT

# number of combinations
# and / or
# list of developped formulas ("inline")


# 1 generate once every permutations of 1 .. $n foreach 1..$max
# 1 1
# 2 12 21
# 3 123 132 213 231 312 321

# graph_isomorphism_match + verify that the atom of each column is of the same nature (C, H, N, O, etc) tfor both matrixess
# ajency matrix -> 0 = no liaison, 1 = simple bond, 2 = double bond, 3 = triple bond
#
#



sub permutations {
	my ($n, @A) = @_;
	my @output;
	my @c; 	# @c is an encoding of the stack state. $c[$k] encodes the for-loop counter for when generate($k - 1, @A) is called

    for (my $i = 0; $i < $n; $i++) {
        $c[$i] = 0;
    }
	push @output, [@A];
    my $i = 1; # $i acts similarly to the stack pointer
    while ($i < $n) {
        if ($c[$i] < $i) {
            if ($i % 2 == 0) {
                ($A[0], $A[$i]) = ($A[$i], $A[0]);
			}
            else {
                ($A[$c[$i]], $A[$i]) = ($A[$i], $A[$c[$i]]);
			}
            push @output, [@A];
            $c[$i]++;	# Swap has occurred ending the for-loop. Simulate the increment of the for-loop counter
            $i = 1; # Simulate recursive call reaching the base case by bringing the pointer to the base case analog in the array
		}
        else {
			# Calling generate($i+1, @A) has ended as the for-loop terminated.
			# Reset the state and simulate popping the stack by incrementing the pointer.
            $c[$i] = 0;
            $i++;
        }
    }
	return @output;
}

# open my $FH, ">>", "data_dump.txt";
# open my $FH, ">", "data_dump.txt";
# my @array=(1,2,3);
# print $FH Data::Dumper->Dump([\@array],["*array"]);		# WORKS

our @permutations;
# permutations(11, 0 .. 10);
# our @permutations = map { [permutations($_, 0 .. $_-1)] } 0..10;
# print $FH Data::Dumper->Dump([[map { [permutations($_, 0 .. $_-1)] } 0..9]], ["*permutations"]);
# print "PERMUTATIONS generated\n";

do "./data_dump.txt";

# push @permutations, [permutations(8, 0 .. 7)];
# push @permutations, [permutations(9, 0 .. 8)];
# push @permutations, [permutations(10, 0 .. 9)];
# push @permutations, [permutations(11, 0 .. 10)];

# print $FH Data::Dumper->Dump([\@permutations], ["*permutations"]);

# close $FH;

# print @permutations;
# sleep 5;
# exit;

sub matrix_equality {
	my $matrix_a = shift;
	my $matrix_b = shift;
	for (my $i=0; $i < $matrix_a->@*; $i++) {
		foreach (my $j=0; $j < $matrix_a->[$i]->@*; $j++) {
			if ($matrix_a->[$i]->[$j] != $matrix_b->[$i]->[$j]) {
				return 0;
			}
		}
	}
	return 1;
}

sub identical_molecules {
# sub graph_isomorphism {
	my ($molecule_a, $molecule_b) = @_;
	my ($graph_a, $graph_b) = ($molecule_a->{matrix}, $molecule_b->{matrix});
	my ($atoms_a, $atoms_b) = ($molecule_a->{atoms}, $molecule_b->{atoms});
	my $half_permutated_graph_a;
	my $permutated_graph_a;
	my $permutated_atoms_a;
# 	my @permutations = $permutations[scalar $graph_a->@*]->@*;

# 	print "scalar ", scalar @permutations;
# 	print $permutations[10];
	exit;

# 	print "scalar ", scalar $graph_a->@*;
# 	if (not defined $permutations[scalar $graph_a->@*]) {
# 		print "UNDEFINED";
# 		print
# 		print Dumper $molecule_
# 		exit;
# 	}


	my ($i, $j);
	my $col;

	PERMUTATION:
	foreach my $permutation (@permutations) {
		# keep lines in the original order but rearrange columns
		for ($i = 0; $i < $graph_a->@*; $i++) {		# LINES
			$j = 0;
			foreach $col ($permutation->@*) {		# COLUMNS
				$half_permutated_graph_a->[$i]->[$j] = $graph_a->[$i]->[$col];
				$j++;
			}
		}
		# rearrange lines
		$i = 0;
		foreach $col ($permutation->@*) {
			$permutated_graph_a->[$i]->@* = $half_permutated_graph_a->[$col]->@*;
			$i++;
		}
		$i = 0;
		for $col ($permutation->@*) {
			$permutated_atoms_a->[$i] = $atoms_a->[$col];
			$i++;
		}
# 		if (each columns corresponds to same atom) {
			# right now this logic is inside identical_molecules()
			# but it would be an optimization to have it here
			if (matrix_equality($permutated_graph_a, $graph_b) ) {
				for ($i=0; $i < $atoms_b->@*; $i++) {
					if ($atoms_b->[$i] ne $permutated_atoms_a->[$i]) {
						next PERMUTATION;
					}
				}
				return 1;
			}
# 		}
	}
	return 0;
}


my $methane = {
	atoms => [qw(C H H H H)],
	matrix => [
				[0,1,1,1,1],
				[1,0,0,0,0],
				[1,0,0,0,0],
				[1,0,0,0,0],
				[1,0,0,0,0],
              ],
};

my $methane_2 = {
	atoms => [qw(H H C H H)],
	matrix => [
				[0,0,1,0,0],
				[0,0,1,0,0],
				[1,1,0,1,1],
				[0,0,1,0,0],
				[0,0,1,0,0],
              ],
};

# 1 -> 2
# 2 -> 3
# 2 -> 4
my $graph_1 = [
	[0,1,0,0],
	[1,0,1,1],
	[0,1,0,0],
	[0,1,0,0],
];

# 3 -> 4
# 3 -> 1
# 3 -> 2
my $graph_2 = [
	[0,0,1,0],
	[0,0,1,0],
	[1,1,0,1],
	[0,0,1,0],
];

$\="\n";

# if(graph_isomorphism($graph_1, $graph_2)) {
# 	print "graph isomorphism";
# }
# else {
# 	print "no graph isomorphism";
# }

# if (identical_molecules($methane, $methane_2)) {
# 	print "identical molecules";
# }
# else {
# 	print "not identical molecules";
# }

my @hydrocarbures = ([$methane]);	# hydrocarbure index == number of carbons - 1, contains array of all CnH2n+2

sub copy_molecule {
	my ($molecule, $copy) = @_;
	$copy->{atoms}->@* = $molecule->{atoms}->@*;
	for (my $i=0; $i < $molecule->{matrix}->@*; $i++) {
		for (my $j=0; $j < $molecule->{matrix}->[$i]->@*; $j++) {
			$copy->{matrix}->[$i]->[$j] = $molecule->{matrix}->[$i]->[$j];
		}
	}
}

sub substitutions_hydrogen_methyl {
	# substitute each C-H by C-CH3 and remove duplicate (identical) molecules (because of symmetry / graph isomorphism)
	my $hydrocarbures = shift;
	my @hydrogen_carbon;
	my @hydrogen_columns;
	my @hydrogen_lines;
	my $number_of_atoms;
	my $line;
	my $hydrogen;
	my $new_hydrocarbure;
	my @new_hydrocarbures;

	foreach my $hydrocarbure ($hydrocarbures->@*) {	# all hydrocarbures having n Carbons
		@hydrogen_carbon = ();
		@hydrogen_lines = grep { $hydrocarbure->{atoms}->[$_] eq "H" } keys $hydrocarbure->{atoms}->@*;

		foreach $hydrogen (@hydrogen_lines) {
			for (my $col=0; $col < $hydrocarbure->{matrix}->[$hydrogen]->@*; $col++) {

				# find the atom which is bonded to this Hydrogen (there is only one because H is monovalent)

				if ($hydrocarbure->{matrix}->[$hydrogen]->[$col] == 1) {	# single bond found
					if ($hydrocarbure->{atoms}->[$col] eq "C") {	# if the only bond of this H is to a C (and not to O or N)
						push @hydrogen_carbon, $hydrogen;
					}
				}
			}
		}

		foreach $hydrogen (@hydrogen_carbon) {	# column / line of hydrogen to be replace by C

			$new_hydrocarbure = {};
			copy_molecule($hydrocarbure, $new_hydrocarbure);

			$number_of_atoms = $new_hydrocarbure->{atoms}->@*;
			$new_hydrocarbure->{atoms}->[$hydrogen] = "C";

			push $new_hydrocarbure->{atoms}->@*, "H", "H", "H";

			# add 3 columns to the existing lines for the 3 H
			foreach $line ($new_hydrocarbure->{matrix}->@*) {
				push $line->@*, 0, 0, 0;
			}

			# mark each hydrogen column at carbon line
			$new_hydrocarbure->{matrix}->[$hydrogen]->[$number_of_atoms + $_] = 1 for 0..2;

			# add 3 lines for the 3 H
			push $new_hydrocarbure->{matrix}->@*, [ (0) x ($number_of_atoms + 3) ] for 1..3;

			# mark each hydrogen line at the carbon column
			foreach $line ($number_of_atoms .. $number_of_atoms + 2) {
				$new_hydrocarbure->{matrix}->[$line]->[$hydrogen] = 1;
			}

			if ( not grep { identical_molecules($new_hydrocarbure, $_) } @new_hydrocarbures ) {
				push @new_hydrocarbures, $new_hydrocarbure;
			}
		}
	}
# 	print Dumper @new_hydrocarbures;
	return @new_hydrocarbures;
}




push @hydrocarbures, [substitutions_hydrogen_methyl($hydrocarbures[0])];
push @hydrocarbures, [substitutions_hydrogen_methyl($hydrocarbures[1])];








