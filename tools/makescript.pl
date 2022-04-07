#!/usr/bin/perl

use strict;
use warnings;
use v5.10;
local $\="\n";
exit unless @ARGV;
my $FH;

sub make_script {
    open $FH, ">>", $_[0];
    close $FH;
    chmod 0755, $_[0];
}

foreach my $script (@ARGV) {

if (-e $script && -s $script) {
	chmod 0755, $script;
	next;
}


# PERL SCRIPT
if ($script =~ /\.pl$/) {

    make_script($script);

	open $FH, ">>", $script;
	print $FH <<~ 'EOF';
    #!/usr/bin/perl

    use strict;
    use warnings;
    use v5.10;
    use dd;



    __END__
    EOF
#     use feature 'signatures';
#     no warnings "experimental::signatures";
	close $FH;
	exec "vim", $script, "+8" if @ARGV == 1;
}
# PERL MODULE
elsif ($script =~ /\.pm$/) {

    make_script($script);

    my ($package) = $script =~ m| ^ ( [^/]+ ) \.pm$ |x;
	open $FH, ">>", $script;
	print $FH <<~ "EOF";

    package $package;
    use strict;
    use warnings;
    use v5.10;


    
    1;
    __END__
    EOF
	close $FH;
	exec "vim", $script, "+7" if @ARGV == 1;
}
# PERL6
elsif ($script =~ /\.(p6|pl6|pm6)$/) {

    make_script($script);

	open $FH, ">>", $script;
    print $FH <<~ "EOF";
    #!/usr/bin/perl6

    use v6;





    =begin END
    =end END

    EOF
	close $FH;
	exec "vim", $script, "+5" if @ARGV == 1;
}
# HASKELL
elsif ($script =~ /\.hs$/) {

    make_script($script);

	open $FH, ">>", $script;
    print $FH <<~ "EOF";
    import System.IO

    main :: IO()
    main = do
        

    EOF
	close $FH;
	exec "vim", $script, "+5" if @ARGV == 1;
}
# GO
elsif ($script =~ /\.go$/) {

    make_script($script);

	open $FH, ">>", $script;
	print $FH <<~ "EOF";
	package main

	import "fmt"

	func main() {
		
	}
	EOF
	close $FH;
	exec "vim", $script, "+6" if @ARGV == 1;
}
# SHELL / BASH
elsif ($script =~ /\.sh$/) {

    make_script($script);

	open $FH, ">>", $script;
	print $FH <<~ "EOF";
	#!/usr/bin/bash

	EOF
	close $FH;
	exec "vim", $script, "+3" if @ARGV == 1;
}
# JAVASCRIPT
elsif ($script =~ /\.js$/) {

    make_script($script);

	open $FH, ">>", $script;
	print $FH <<~ "EOF";
	#!/usr/bin/node
	
	const l = console.log;



	EOF
	close $FH;
	exec "vim", $script, "+5" if @ARGV == 1;
}
# HTML
elsif ($script =~ /\.html$/) {

    make_script($script);

	open $FH, ">>", $script;
    print $FH <<~ "EOF";
    <!DOCTYPE html>
    <html>
    <head>
    <style>
    </style>
    </head>
    <body>

    </body>
    </html>	
    EOF
	close $FH;
	exec "vim", $script, "+7" if @ARGV == 1;
}
# SCHEME
elsif ($script =~ /\.scm$/) {

    make_script($script);

	open $FH, ">>", $script;
	print $FH <<~ "EOF";
    #!/usr/bin/chez --script

    (define (say l) (display l) (newline))



    EOF
	close $FH;
	exec "vim", $script, "+5" if @ARGV == 1;
}
# COMMON LISP
elsif ($script =~ /\.lisp$/) {

    make_script($script);

	open $FH, ">>", $script;
	print $FH <<~ "EOF";
    #!/usr/bin/sbcl --script

    (defun say (l) (princ l) (terpri))
    (defun die (msg) (say msg) (quit))
    (defvar argv sb-ext:*posix-argv*)




    EOF
	close $FH;
	exec "vim", $script, "+5" if @ARGV == 1;
}
# RACKET
elsif ($script =~ /\.rkt$/) {

    make_script($script);

	open $FH, ">>", $script;
    #lang racket/base
	print $FH <<~ "EOF";
    #!/usr/bin/racket
    #lang racket





    EOF
	close $FH;
	exec "vim", $script, "+5" if @ARGV == 1;
}
# EMACS LISP
elsif ($script =~ /\.el$/) {

    make_script($script);

	open $FH, ">>", $script;
	print $FH <<~ "EOF";
    #!/usr/bin/emacs --script




    EOF
	close $FH;
	exec "vim", $script, "+4" if @ARGV == 1;
}
# PYTHON
elsif ($script =~ /\.py$/) {

    make_script($script);

	open $FH, ">>", $script;
	print $FH <<~ "EOF";
	#!/usr/bin/python

	EOF
	close $FH;
	exec "vim", $script, "+3" if @ARGV == 1;
}
# C
elsif ($script =~ /\.c$/) {

    make_script($script);

	open $FH, ">>", $script;
	print $FH <<~ "EOF";
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>

	int main (int argc, char * argv[]) {



		return 0;
	}
	EOF
	close $FH;
	exec "vim", $script, "+7" if @ARGV == 1;
}
# C++
elsif ($script =~ /\.cpp$/) {

    make_script($script);

    open $FH, ">>", $script;
    print $FH <<~ "EOF";
    #include <iostream>

    using namespace std;

    int main (int argc, char * argv[]) {



        return 0;
    }
    EOF
	close $FH;
	exec "vim", $script, "+7" if @ARGV == 1;
}
# PHP
elsif ($script =~ /\.php$/) {

    make_script($script);

	open $FH, ">>", $script;
	print $FH <<~ "EOF";
	#!/usr/bin/php
	<?php

	?>
	EOF
	close $FH;
	exec "vim", $script, "+3" if @ARGV == 1;
}
# LUA
elsif ($script =~ m/\.lua$/) {

    make_script($script);

	open $FH, ">>", $script;
	print $FH <<~ "EOF";
	#!/usr/bin/lua5.3



	EOF
	close $FH;
	exec "vim", $script, "+3" if @ARGV == 1;
}
# RUBY
elsif ($script =~ m/\.rb$/) {

    make_script($script);

	open $FH, ">>", $script;
	print $FH <<~ "EOF";
    #!/usr/bin/ruby



    EOF
	close $FH;
	exec "vim", $script, "+3" if @ARGV == 1;
}
# VIMSCRIPT
elsif ($script =~ m/\.vim$/) {

    make_script($script);

	open $FH, ">>", $script;
	print $FH <<~ "EOF";
    #!/usr/local/bin/vim -nNesc:let&verbose=1|let&viminfo=""|source%|echo""|qall!



    EOF
	close $FH;
	exec "vim", $script, "+3" if @ARGV == 1;
}
# STANDARD ML
elsif ($script =~ m/^(.*)\.sml$/) {

    my $script_name    = $1;
    my $script_name_uc = ucfirst $1;

    make_script($script);

    open $FH, ">>", "$script_name.cm";
    say $FH "Group is\n\t$script\n";
    close $FH;

	open $FH, ">>", $script;
	print $FH <<~ "EOF";

    structure $script_name_uc =
    struct

    fun main (prog_name, args) =
        let
          val _ = print ("Program name: " ^ prog_name ^ "\\n")
          val _ = print "Arguments:\\n"
          val _ = map (fn str => print ("\\t" ^ str ^ "\\n")) args
        in
          1
        end
    end

    EOF
	close $FH;
	exec "vim", $script, "+3" if @ARGV == 1;
}
# OCAML
elsif ($script =~ m/^(.*)\.ml$/) {

#     my $script_name    = $1;
#     my $script_name_uc = ucfirst $1;
    make_script($script);

	open $FH, ">>", $script;
	print $FH <<~ "EOF";
    #!/usr/bin/ocaml




    EOF
	close $FH;
	exec "vim", $script, "+3" if @ARGV == 1;
}
# ADA (BLOCK)  (vs .ads SPEC)
elsif ($script =~ /\.adb$/) {

    make_script($script);

    my ($package) = $script =~ m| ^ ( [^/]+ ) \.adb$ |x;
	open $FH, ">>", $script;
	print $FH <<~ "EOF";

    with TEXT_IO;

    procedure $package is
    begin



    end $package;

    EOF
	close $FH;
	exec "vim", $script, "+6" if @ARGV == 1;
}
elsif ($script =~ /^(.*)\.pro$/) {  # to differentiate with perl_script.pl

    my $prog = $1 . ".pl";
    make_script($prog);
     
	open $FH, ">>", $prog;
    print $FH <<~ 'EOF';
    #!/usr/bin/swipl
    :- set_prolog_flag(verbose, silent).
    :- initialization main.

    say(X) :- write(X), nl.


    main :-

      halt.






    % vim: ft=prolog
    EOF
    close $FH;
	exec "vim", $prog, "+10" if @ARGV == 1;
}
elsif ($script =~ /\.fs$/) {
    make_script($script);
	open $FH, ">>", $script;

    print $FH <<~ 'EOF';
    #! /usr/local/bin/gforth
    







    bye
    EOF
    close $FH;
	exec "vim", $script, "+4" if @ARGV == 1;
}
# OTHER
else {

    make_script($script);

	exec "vim", $script if @ARGV == 1;
}

}
