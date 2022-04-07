#!/usr/bin/perl

use strict;
use warnings;
use v5.10;
use Capture::Tiny qw(capture);
exit unless @ARGV;

my $debug;
my ($prog, $compiled);
sub parse_file;

if ($ARGV[0] =~ /^--?debug$/) {
    shift;
    $debug = 1;
}

exit unless @ARGV;
die "file does not exists" if ! -e $ARGV[0];

if ($ARGV[0] =~ /\.c$/) {
    $prog = shift;
    $compiled = $prog =~ s/\.c$/\.o/r;
    my @compile_flags = parse_file($prog);

    if ($debug) {
        say join "|", "gcc", (@compile_flags ? @compile_flags : ()), $prog, "-o", $compiled;
    }

      system "gcc", (@compile_flags ? @compile_flags : ()), $prog, "-o", $compiled;

    die "compilation error $?" if $?;

    system "./$compiled", @ARGV;
}
elsif ($ARGV[0] =~ /\.java$/) {
    $prog = shift;
    $compiled = $prog =~ s/\.java$//r;
    system "javac", $prog;
    system "java", $compiled, @ARGV;
}
elsif ($ARGV[0] =~ /^(.*)\.sml$/) {
    $prog = $1;
    $compiled = "$prog.amd64-linux";
    my $main = ucfirst($prog) . ".main";
    shift;
    my ($out, $err);

    my ($stdout, $stderr, $exit);

    if ($debug) {
        system "ml-build \"$prog.cm\" \"$main\" \"$prog\"";
    }
    else {

        ($stdout, $stderr, $exit)
        = capture { system "ml-build \"$prog.cm\" \"$main\" \"$prog\"" }
    }

    if ($exit == 256) {
        say $stdout // "", $stderr // "";
        exit;
    }
    system "sml", "\@SMLload", $compiled, @ARGV;
}


sub parse_file {
    my $file = shift // die;
    die if ! -f $file;
    open my $fh, "<", $file;

    while (<$fh>) {
        if (m| ^ \s* // \s* crepl \s* : \s* (pkg-config\b .*) |x) {
            close $fh;
            return split /\s+/, qx{ $1 };
        }
    }
    return ();
}















__END__

