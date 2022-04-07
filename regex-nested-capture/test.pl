#!/usr/bin/perl

use strict;
use warnings;
use v5.10;
use Data::Dumper;
$Data::Dumper::Sortkeys=1;
$Data::Dumper::Indent = 1;
# use Regexp::Debugger;
use re 'eval';

our @stack;
our $match;

# my $regex = qr{
#    (?{ local @stack; })
# 
#    ^ (
#        (...) (?{ push @stack, $+ })
#        (...) (?{ push @stack, $+ })
#      )
#      (?{ local @stack = @stack; my @caps = @stack[-2..-1]; pop @stack for 1 .. 2; push @stack, \@caps; })
# 
# 
#    (?{ say "MATCH"; dd \@stack; $match = pop @stack; })
# 
# }x;

# my $regex = qr{
#         (?{ local @stack; })
# 
#    ^ ( (...)(?{ push @stack, $+ }) (...)(?{ push @stack, $+ }) )(?{ local @stack = @stack; my @caps = @stack[-2..-1]; pop @stack for 1 .. 2; push @stack, \@caps; })(?{ my @caps = @stack[-1..-1]; pop @stack for 1 .. 1; push @stack, \@caps; })(?{ say "MATCH"; dd \@stack; $match = pop @stack; })
# }x;

my $regex = qr{
        (?{ local @stack; })

           ^ ( (...)(?{ push @stack, $+ }) (...)(?{ push @stack, $+ }) )(?{ local @stack = @stack; my @caps = @stack[-2..-1]; pop @stack for 1 .. 2; push @stack, \@caps; })(?{ say "MATCH"; say Dumper \@stack; $match = pop @stack; }) (?{ my @caps
= @stack[-1..-1]; pop @stack for 1 .. 1; push @stack, \@caps; })
}x;

say $regex;

if ("abcdef" =~ $regex) {
    say "true"
}
else {
    say "false"
}

# dd $match;

__END__

