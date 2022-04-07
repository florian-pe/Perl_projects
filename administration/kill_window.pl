#!/usr/bin/perl

use strict;
use warnings;

my @mpv = map { (split)[1] } grep { (split)[10] =~ /mpv$/ ? $_ : () } `ps aux`;
my @wmctrl = `wmctrl -lp`;
my @windows = map { s/ ^ \S+ \s+ \S+ \s+ (.*) /$1/xr } map { y/ //rs } @wmctrl;
# my @windows = map { ($_)=m/ ^ \S+ \s+ \S+ \s+ (.*) /x; "$_\n" } map { y/ //rs } @wmctrl;

pipe DMENU_READ,PERL_WRITE;	#  ./script.pl | dmenu	(1st step)
pipe PERL_READ,DMENU_WRITE;	#  dmenu | ./script.pl	(2nd step)
if (!(my $pid_dmenu=fork)) {
	# dmenu process
	close PERL_READ;
	close PERL_WRITE;
	
	close STDIN;
	open STDIN, "<&", \*DMENU_READ;

	close STDOUT;
	open STDOUT, ">&", \*DMENU_WRITE;

	exec "dmenu -i -l 30";
} else {
	# perl script process
	close DMENU_READ;
	close DMENU_WRITE;
	close STDERR;

	foreach my $pid ( @mpv) {
		print PERL_WRITE map { s|N/A ||r } grep { /$pid/ } @windows;
	}
	chomp (my $hostname = `uname --nodename`);
	my @others = map { y/ //s; s/ $hostname//; s/ ^ \S+ \s+ \S+ \s+ (.*) /$1/xr }
                 grep { !/ - mpv/ } @wmctrl;
	print PERL_WRITE "-"x60,"\n" if @mpv and @others;
	print PERL_WRITE @others;
	close PERL_WRITE;

	my @goners = map { s/^(\S+).*/$1/r } <PERL_READ>;
	close PERL_READ;

	foreach (@goners) {
		system "kill $_";
	}
}

