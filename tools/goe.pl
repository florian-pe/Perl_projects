#!/usr/bin/perl

# this script requires this line in /etc/fstab :
# tmpfs   /tmp/ram/   tmpfs    defaults,noatime,nosuid,nodev,mode=1777,size=32M 0 0
# OR
# mkdir -p /tmp/ram; sudo mount -t tmpfs -o size=32M tmpfs /tmp/ram/

use strict;
use warnings;
use autodie;
use v5.10;

my $input;
my $debug = 0;
my @import = "fmt";
my $status;
local $/;

exit if -t STDIN && ! @ARGV;

if (not -t STDIN) {
    $input = <STDIN>
}

while (@ARGV) {
    if ($ARGV[0] =~ /^--?debug$/) {
        $debug = 1;
        shift;
    }
    elsif ($ARGV[0] =~ /^-M(.*)/) {
        push @import, split ",", $1;
        shift;
    }
    else {
        $input = shift;
        last;
    }
}


my $source_code   = "/tmp/ram/go_program.go";	# requires mounting tmpfs
my $compiled_code = "/tmp/ram/go_program";      # requires mounting tmpfs
# my $source_code   = "./.go_program.go";
# my $compiled_code = "./.go_program";


open my $FH, ">", $source_code;
say $FH 'package main';
say $FH 'import (';
for (@import) {
    say $FH "    \"$_\""
}
say $FH ")";
say $FH "";
say $FH "func main() {";
say $FH $input;
say $FH "}";
close $FH;

if ($debug) {
	open my $FH, "<", $source_code;
	say <$FH>;
	close $FH;
    exit;
}
# system "go", "build", $source_code;
# system "go", "run", $source_code;
system "go", "run", $source_code, @ARGV;

# print "\"$?\" \"$!\"";
# $status = $?;
# if ($status != 0) {
#     print "failed to compile: $!\n";
# }
# 
# system $compiled_code;
# system $compiled_code, @ARGV;
# print "\"$?\" \"$!\"";
# 
# $status = $?;
# if ($status == -1) {
#     print "failed to execute: $!\n";
# }
# elsif ($status & 127) {
#     printf "child died with signal %d, %s coredump\n",
#         ($status & 127), ($status & 128) ? 'with' : 'without';
# }
# unlink $source_code, $compiled_code;
# unlink $source_code;




