#!/usr/bin/perl

use strict;
use warnings;
use v5.10;
use lib '.';
use nested_capture;
use Data::Dumper;
$Data::Dumper::Sortkeys=1;
$Data::Dumper::Indent = 1;

my $regex = qr{
   ^ ( (...) (...) )
}x;

my $actions = {};
my $parser = nested_capture->new(regex => $regex, actions => $actions);
my $res = $parser->match("abcdef");

# dd $res;
# say $res->[0];
# say $res->[0][0];
# say $res->[0][1];


say Dumper (nested_capture->new(regex => qr{ ^ ((.) ((.))) }x)->match("hello"));



__END__

