#!/usr/bin/perl

# this script requires this line in /etc/fstab :
# tmpfs   /tmp/ram/   tmpfs    defaults,noatime,nosuid,nodev,mode=1777,size=32M 0 0
# OR
# mkdir -p /tmp/ram; sudo mount -t tmpfs -o size=32M tmpfs /tmp/ram/

use strict;
use warnings;
use autodie;
use v5.10;

my @include = qw(stdio stdlib);			# list of #include <library.h>
my @compile_flags;		# -E -l/usr/lib/ etc..
my $input;
my $debug = 0;
my $only_headers = 0;	# output of cpp / gcc -E
my $perl = 0;
# my $perl_flags = qx{perl -MExtUtils::Embed -e ccopts -e ldopts} =~ tr/\n//rd;
my $perl_flags = "-Wl,-E -Wl,-rpath,/usr/lib/perl5/5.34/core_perl/CORE -Wl,-O1,--sort-common,--as-needed,-z,relro,-z,now -fstack-protector-strong -L/usr/local/lib  -L/usr/lib/perl5/5.34/core_perl/CORE -lperl -lpthread -ldl -lm -lcrypt -lutil -lc -D_REENTRANT -D_GNU_SOURCE -fwrapv -fno-strict-aliasing -pipe -fstack-protector-strong -I/usr/local/include -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64 -D_FORTIFY_SOURCE=2  -I/usr/lib/perl5/5.34/core_perl/CORE";

sub uniq {
    my %seen;
    grep { !$seen{$_}++ } @_
}

for (1) {
	last if ! @ARGV;
    if ($ARGV[0] =~ m/^-M/) {
        $ARGV[0] =~ s/^-M//;
        push @include, map { s/\.h$//r } split /,/, shift;
        redo;
    }
    elsif ($ARGV[0] =~ m/^-[ILlDUpWfm]/) {
        push @compile_flags, shift;
        redo;
    }
    elsif ($ARGV[0] =~ m/^--?gcc$/) {
        shift;
        push @compile_flags, shift;
        redo;
    }
    elsif ($ARGV[0] eq "-E") {
        $only_headers = 1;
        shift;
        redo;
    }
    elsif ($ARGV[0] =~ /^--?perl$/) {
        $perl = 1;
        shift;
        redo;
    }
    elsif ($ARGV[0] =~ /^--?debug$/) {
        $debug = 1;
        shift;
        redo;
    }
    else {
        last;
    }
}
$/=undef;

if (@ARGV) {
	if (-e $ARGV[0]) { $input = <ARGV>  }
	else             { $input = $ARGV[0]}
}
elsif (not -t STDIN) { $input = <STDIN> }
else                 { exit }

shift @ARGV;

my $source_code   = "/tmp/ram/c_program.c";	# requires mounting tmpfs
my $compiled_code = "/tmp/ram/c_program.o";	# requires mounting tmpfs
# my $source_code   = "./.c_program.c";
# my $compiled_code = "./.c_program.o";

$\="\n";

open my $FH, ">", $source_code;
foreach (uniq @include){
	print $FH "#include <$_.h>";
}

if ($perl) {
	print $FH "#include <EXTERN.h>";
	print $FH "#include <perl.h>";
    print $FH "static PerlInterpreter *my_perl;";
}

print $FH "";

if ($perl) {
    print $FH "int main(int argc, char **argv, char** env) {";
}
else {
    print $FH "int main(int argc, char *argv[]) {";
}

if ($perl) {
print $FH <<'EOF';
	   PERL_SYS_INIT3(&argc,&argv,&env);
	   my_perl = perl_alloc();
	   perl_construct(my_perl);
	   PL_exit_flags |= PERL_EXIT_DESTRUCT_END;

EOF
}

print $FH $input;

if ($perl) {
print $FH <<'EOF';
	   perl_destruct(my_perl);
	   perl_free(my_perl);
	   PERL_SYS_TERM();
	   exit(EXIT_SUCCESS);
EOF
}

print $FH "return 0;";
print $FH "}";
close $FH;

if ($perl) {


    if ($debug) {
        open my $FH, "<", $source_code;
        print <$FH>;
        close $FH;

        say join " ", "gcc", "-I/usr/lib/perl5/5.34/core_perl/CORE/",
                        @compile_flags, $source_code, "-o", $compiled_code,
                        "-O", split /\s+/, $perl_flags;
        exit;
    }

    my $source_code_q = quotemeta $source_code;
    my $compiled_code_q = quotemeta $compiled_code;

    system "gcc", "-I/usr/lib/perl5/5.34/core_perl/CORE/",
            @compile_flags, $source_code, "-o", $compiled_code,
            "-O", split /\s+/, $perl_flags;

    die "compilation error $?" if $?;

	system $compiled_code, @ARGV;
    exit;
}

if ($debug) {
	open my $FH, "<", $source_code;
	print <$FH>;
	close $FH;
    print join " ", "gcc", @compile_flags, $source_code, "-o", $compiled_code;
    exit;
}


if ($only_headers) {
	print qx{ gcc -E @compile_flags $source_code };
}
else {
	system "gcc", @compile_flags, $source_code, "-o", $compiled_code;

    die "compilation error $?" if $?;

	system $compiled_code, @ARGV;

	my $status = $?;
# 	if ($status == -1) {
#     # print "failed to execute: $!\n";
# 		die "failed to execute: $!\n";
# 	}
# 	elsif ($status & 127) {
#     # printf "child died with signal %d, %s coredump\n",
# 		die "child died with signal %d, %s coredump\n",
# 			($status & 127), ($status & 128) ? 'with' : 'without';
# 	}
# 	unlink $source_code, $compiled_code;
}


# my @send;
# pipe CREAD,PWRITE;
# pipe PREAD,CWRITE;
# if(!(my $pid=fork)) {
# 	# C binary process
# 	close PREAD;
# 	close PWRITE;
# 
# 	close STDIN;
# 	open STDIN, "<&", \*CREAD;
# 
# 	close STDOUT;
# 	open STDOUT, ">&", \*CWRITE;
# 	$SIG{SEGV} = sub { die "Segmentation Fault $!" };
# 
# 	exec $compiled_code;
# }else{
# 	# perl process
# 	close CREAD;
# 	close CWRITE;
# 	
# 	print PWRITE @send;
# 	close PWRITE;
# 
# 	chomp (my @receive = <PREAD>);
# 	close PREAD;
# 	print @receive;
# 
# 
# if ($? == -1) {
#    print "failed to execute: $!\n";
# }
# elsif ($? & 127) {
#    printf "child died with signal %d, %s coredump\n",
#        ($? & 127),  ($? & 128) ? 'with' : 'without';
# }

# unlink $source_code, $compiled_code;
# }



