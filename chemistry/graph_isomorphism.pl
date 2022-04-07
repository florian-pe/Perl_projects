#!/usr/bin/perl

use strict;
use warnings;

sub graph_isomorphism {
	my ($graph_a,$graph_b) = @_;
	my $length_a;
	my $length_b;
	my $permuted_graph_a;
	if ($graph_a->@* != $graph_b->@*) {
		return 0;
	}
	else {
		$length_a = $graph_a->[0]->@*;
		foreach (keys $graph_a->@*) {
			if ($length_a != $graph_a->[$_]->@*) {
				return 0;
			}
		}
		$length_b = $graph_b->[0]->@*;
		foreach (keys $graph_b->@*) {
			if ($length_a != $graph_b->[$_]->@*) {
				return 0;
			}
		}
		if ($length_a != $length_b) {
			return 0;
		}
	}
# 	return 1;

}

my @a = (
	[ 1 , 2 , 3 ],
	[ 4 , 5 , 6 ],
	[ 7 , 8 , 9 ],
);

# my @a = (
# 	[ 1 ,  3 ],
# 	[ 7 ,  9 ],
# );

my @b = (
	[ 1 , 2 , 3 ],
	[ 4 , 5 , 6 ],
	[ 7 , 8 , 9 ],
);

# my @b = (
# 	[ 1 , 2 , 3 ],
# 	[ 4 , 5 ,  ],
# 	[ 7 , 8 , 9 ],
# );

# my @b = (
# 	[ 1 , 2  ],
# 	[ 4 , 5  ],
# );

$\="\n";

# if (graph_isomorphism(\@a, \@b)) {
# 	print "true";
# }
# else {
# 	print "false";
# }


# 			print "ODD";
# 			print "BEFORE \$list[0] = $list[0] \$list[\$size-1] = $list[$size-1]";
# 			print "AFTER \$list[0] = $list[0] \$list[\$size-1] = $list[$size-1]";
# 			print "EVEN";
# 			print "BEFORE \$list[\$i] = $list[$i] \$list[\$size-1] = $list[$size-1]";
# 			print "AFTER \$list[\$i] = $list[$i] \$list[\$size-1] = $list[$size-1]";
# 		print "-" x 40;

our $indentation = -1;

$,="";

sub heap_permutations {
	my $indentation = shift;
	my $size = shift;
	my @list = @_;
# 	$indentation++; 
	$,="";
# 	print " " x $indentation . "\$indentation $indentation";

	print " " x $indentation . "-" x 40;
	print " " x $indentation . "CALL heap_permutations()";
	print " " x $indentation . "SIZE $size";
	print " " x $indentation . "LIST \"@list\"";

	if ($size == 1) {
		print " " x $indentation . "\$size == 1";
		print " " x $indentation . GREEN . "PERMUTATION \"@list\"" . RESET;
		return;
	}
	print " " x $indentation . "FOR \$i in ", join " ", 0 .. $size - 1;
	for my $i (0 .. $size - 1) {
		print " " x $indentation . "\$i = $i";
# 		print " " x $indentation . "CALLING heap_permutations(\$size - 1 = @{[$size - 1]}, \@list = \"@list\")";
		print " " x $indentation . "CALLING heap_permutations(@{[$size - 1]}, \"@list\")";
		heap_permutations($indentation + 4, $size - 1, @list);
		if ($size % 2 == 1) {
			print " " x $indentation . "$size % 2 == 1";
            ($list[0], $list[$size-1]) = ($list[$size-1], $list[0]);
		}
		else {
			print " " x $indentation . "$size % 2 != 1";
            ($list[$i], $list[$size-1]) = ($list[$size-1], $list[$i]);
		}
	}
}

my @array = (1 .. 4);
# $,="\n";
# print scalar @array;
heap_permutations(0, scalar @array, @array);
# print heap_permutations(scalar @array, @array);

# sub heap_permutations {
# 	my $size = shift;
# 	my @list = @_;
# 	my @out;
# 	if ($size == 1) {
# 		print @list;
# 		return;
# 		return "@list";
# 	}
# 	for my $i (0 .. $size - 1) {
# 		push @out, heap_permutations($size - 1, @list);
# 		if ($size % 2 == 1) {
#             ($list[0], $list[$size-1]) = ($list[$size-1], $list[0]);
# 		}
# 		else {
#             ($list[$i], $list[$size-1]) = ($list[$size-1], $list[$i]);
# 		}
# 	}
# 	if ($size == @list) {
# 		return @out;
# 	}
# }

# const permutations = array => {
#   // Sort the input
#   array.sort();
#   // Add a copy and initialize our list of permutations
#   let perms = [array.slice()];
# 
#   while (array) {
#     let [i, j, k] = Array(3).fill(array.length - 1);
# 
#     // Find the first non-increasing element
#     while (i > 0 && array[i - 1] >= array[i]) i--;
#     // If we don't find one, we're done!
#     if (i <= 0) break;
# 
#     // Find first element larger 
#     while (array[j] <= array[i - 1]) j--;
# 
#     // Swap them
#     [array[i - 1], array[j]] = [array[j], array[i - 1]];
# 
#     // Reverse the suffix
#     while (i < k) {
#       [array[i], array[k]] = [array[k], array[i]];
#       i++;
#       k--;
#     }
#     // Add a copy of the current state of the array to the list of permutations
#     perms.push(array.slice());
#   }
#   return perms;
# };
# 
sub permutations {
	# Sort the input
	my @array = sort { $a <=> $b } @_;
	# Add a copy and initialize our list of permutations
	my @perms;
# 	my @perms = [array.slice()];
	my ($i, $j, $k);

	while (@array) {
# 		($i, $j, $k) = Array(3).fill(array.length - 1);

		# Find the first non-increasing element
		while ($i > 0 and $array[$i - 1] >= $array[$i]) {
			$i--;
		}

		# If we don't find one, we're done!
		if ($i <= 0) {
			last;
		}

		# Find first element larger 
		while ($array[$j] <= $array[$i - 1]) {
			$j--;
		}

		# Swap them
		($array[$i - 1], $array[$j]) = ($array[$j], $array[$i - 1]);

		# Reverse the suffix
		while ($i < $k) {
			($array[$i], $array[$k]) = ($array[$k], $array[$i]);
			$i++;
			$k--;
		}
		# Add a copy of the current state of the array to the list of permutations
		push @perms, [@array];
	}
	return @perms;
}


# my @array = (1 .. 4);
# $,="\n";
# heap_permutations(scalar @array, @array);
# print heap_permutations(scalar @array, @array);


__END__

12 The Master Algorithm

The algorithm will refer to a polylogarithmic function ℓ(x) to be specified later.
 Whenever a subroutine in the algorithm exits and returns a good color-partition of Ω,
the algorithm starts over (recursively). If it returns a structure such as a UPCC, we move to
the next line. If the subroutine returns isomorphism rejection, that branch of the recursion
terminates and the algorithm backtracks.

Procedure String-Isomorphism

Input: group G ≤ S(Ω), strings x, y : Ω → Σ

Output: IsoG(x, y)

1. Apply Procedure Reduce-to-Johnson (Luks reductions, Sec. 3.3)
  (: The rest of this algorithm constitutes the ProcessJohnsonAction routine announced
  in Sec. 3.3)

74

2. (: G is transitive, G-action G on blocks is Johnson group isomorphic to Sm or Am :)
  set ℓ = (log n)^3

  if m ≤ ℓ then apply strong Luks reduction to reduce to kernel of the G-action on the
  blocks (brute force on small primitive group G, multiplicative cost ℓ! :)

3. (: G-action on blocks is isomorphic to S(Γ) or A(Γ), |Γ| = m > ℓ :)
  Let ϕ : G → S(Γ) be a giant representation (inferred from G)
  Let N = ker(ϕ) and let Φ = {BT | T ∈ (Γ t)  } be the set of standard blocks (Thm. 8.19)
  (: the BT partition Ω and G acts on Φ as S(t) (Γ) or A (t) (Γ) :)


4. if G primitive (: i. e., Ω = Φ :)
if t = 1 then find IsoG(x, y), exit (: trivial case: Ω = Γ, G = A(Ω);
isomorphism only depends on the multiplicity of each letter in the strings x, y :)

5. else (: t ≥ 2 :) view x, y as edge-colored t-uniform hypergraphs H(x) and H(y)
on vertex set Γ
if relative symmetry defect of H(x) is < 1/2 then apply Cor. 9.9

6. else (: now their relative symmetry defect is ≥ 1/2 :)
(: view these hypergraphs as t-ary relational structures :)
apply Extended Design Lemma (Theorem 7.12)

7. (: canonical structure X on Γ found: colored equipartition or Johnson scheme :)
apply Procedure Align to X (Sec. 11.1)


8. else (: G imprimitive, i. e., |Φ| ≤ (1/2)|Ω| :)
  apply AggregateCertificates (Theorem 10.14)
  (: Note: this is where our main group-theoretic Divide-and-Conquer algorithm,
  Procedure LocalCertificates (Theorem 10.3) is used :)

9. if AggregateCertificates returns canonically embedded k-ary relational structure on Γ
with relative symmetry defect ≥ 1/2 then

10. apply Extended Design Lemma (Theorem 7.12)
   X ← canonical structure on Γ returned
   (: X is a colored equipartition of Γ or a Johnson scheme embedded in Γ :)

11. else (: AggregateCertificates returns canonical colored equipartition on Γ :)
    X ← colored equipartition returned

12. apply Procedure Align to X (Sec. 11.1)
   The essence of the analysis is in the analysis of Procedure Align given in Section 11.1












