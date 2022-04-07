#!/usr/bin/perl


package rat;
use strict;
use warnings;
use v5.10;
use dd;
use Carp;

# use B::Hooks::EndOfScope;
# sub import {
#     no strict;
#     *{(caller)[0] . '::hello'} = \&hello;
#     my $caller = caller;
#     on_scope_end(sub {
#         no strict;
#         delete ${$caller . "::"}{hello};
#     });
# }

use overload
#     q{""}   => sub { say "overload()"; $_[0]->string },
    q{""}   => sub { $_[0]->string },
;

sub string {
#     croak "not rationals"
#         unless UNIVERSAL::isa($_[0], "rat");
    "$_[0][0]/$_[0][1]"
}

package main;
use strict;
use warnings;
use v5.10;
use dd;
use Carp;


# use overload
#     q{""}   => sub { say "overload()"; $_[0]->string };


# use overload;
# BEGIN {
#     overload::constant q => sub { "overload(" .join("|",@_) . ")" }
#     overload::constant q => sub { "overload($_[0])" }
# }





sub make_rat {
    bless [$_[0], $_[1]], "rat"
}

sub add_rat {
    croak "not rationals"
        unless UNIVERSAL::isa($_[0], "rat")
            && UNIVERSAL::isa($_[1], "rat");
    bless [$_[0][0]*$_[1][1] + $_[1][0]*$_[0][1],
           $_[0][1]*$_[1][1]], "rat";
}

sub sub_rat {
    croak "not rationals"
        unless UNIVERSAL::isa($_[0], "rat")
            && UNIVERSAL::isa($_[1], "rat");
    bless [$_[0][0] * $_[1][1] - $_[1][0] * $_[0][1],
           $_[0][1] * $_[1][1]], "rat";
}

sub mul_rat {
    croak "not rationals"
        unless UNIVERSAL::isa($_[0], "rat")
            && UNIVERSAL::isa($_[1], "rat");
    bless [$_[0][0] * $_[1][0],
           $_[0][1] * $_[1][1]], "rat";
}



my $rat = make_rat 1, 3;

# say $rat->string;
# say add_rat(make_rat(1,2), make_rat(1,3))->string;
# say sub_rat(make_rat(1,2), make_rat(1,3))->string;
say $rat;
say add_rat(make_rat(1,2), make_rat(1,3));
say sub_rat(make_rat(1,2), make_rat(1,3));
# say "r";

# dd \%rat::;
# dd \%::rat::;


