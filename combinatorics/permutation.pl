#!/usr/bin/perl

use strict;
use warnings;
use v5.10;
# use dd;
# our $i;

# sub permutation {
#     return [$_[0]] if @_ == 1;
#     my @ret;
# 
#     for my $e (@_) {
#         my @elems = grep {$_!=$e} @_; # doesn't account for when there is several identical elements
#         for my $t (permutation(grep { $_ != $e } @_)) {
#             push @ret, [ $e, $t->@*  ]
#         }
#     }
#     return @ret
# }

sub permutation {
    return [$_[0]] if @_ == 1;
    map { my $e=$_; map { [ $e, $_->@* ] } permutation(grep { $_ != $e } @_) } @_
}

# sub permutation {
#     return [$_[0]] if @_ == 1;
#     my @ret;
#   #   for (my $i=0; $i < @_; $i++) {
#   #           
#   #       for my $t (permutation(grep { defined } @_[0 .. $i-1], @_[$i+1 .. $#_] )) {
#   #           push @ret, [ $_[$i], $t->@*  ]
#   #       }
#   #   }
# 
#     push @ret, [ $_[0],   $_->@* ] for permutation( @_[ 1 .. $#_   ] );
#     for (my $i=1; $i < @_-1; $i++) {
# 
#         push @ret, [ $_[$i], $_->@* ] for permutation(@_[0 .. $i-1], @_[$i+1 .. $#_]);
#     }
#     push @ret, [ $_[$#_], $_->@* ] for permutation( @_[ 0 .. $#_-1 ] );
# 
#     return @ret;
# }


# permutation(1,2,3);
# say $_->@* for permutation(1,2,3)->@*;
# dd permutation(1,2,3);
# say $_->@* for permutation(1,2,3);
say $_->@* for permutation(@ARGV);



__END__


sub permutation {
    return [$_[0]] if @_ == 1;
    map { my $e=$_; map { [ $e, $_->@* ] } permutation(grep { $_ != $e } @_) } @_
}

permutation(x,x,x,1,2)

















