#!/usr/bin/perl

use strict;
use warnings;

# python with curly braces, so that we can write one-liners in the terminal

# exemple :
# ./pyrepl.pl -e 'for x in range(10) { if x % 2 == 0 { print(x) }}'

my $debug = 0;		# if true, dumps the correctly whitespaced file produced

#input
my $cli_commands;	# commands directly passed as @ARGV to pyrepl
my @import;			# list of imported modules
my $INPUT;
my $SCRIPT_FILE;

#output
my $script;			# syntactically correct python code produced, will be passed to python -c 'exec()'

# temporary storage
my $input;			# copy of cli_commands, used as an in-memory file
my $char;
my $line = "";

# whitespace
my $indent_level = 0;
my $indent_size  = 4;	# number of spaces in one identation level

# finite automata state
my $paren_level;	# counter for finding matching closing parenthesis
my $list_level;		# counter for finding matching closing bracket
my $object_level;	# counter for finding matching closing curly bracket
my $end_of_string;

# adding pass automatically
my $first_block_instruction = 0;


sub usage {
print STDERR <<'EOF';
  usage :     pyrepl [debug] [-Imodule1[,module2[,..]]] 'COMMANDS'

  COMMANDS ex : 'var=4; for i in [1,2,3,4,5] { if var == i { print(f"found {var} in list") } }'
	pyrepl -Ire,sys 'for word in re.split("\s+", open(sys.argv[1]).read()) { print(word) }' wd
EOF
}

if (@ARGV) {
	if (-e $ARGV[0]) {
        local $/;
		$cli_commands = <ARGV>
	}
	else {
        ARGUMENT:
		while (my $arg = shift @ARGV) {
			if ($arg =~ /^-{0,2}debug$/) {
				$debug = 1;
			}
			elsif ($arg =~ /^-I/) {
				$arg =~ s/^-I//;
				push @import, split /,/, $arg;
			}
			elsif ($arg =~ /^-M/i) {
				$arg =~ s/^-M//i;
				push @import, split /,/, $arg;
			}
            elsif ($arg eq "-e") {
                $cli_commands = shift @ARGV;
                last ARGUMENT;					# keep the rest of @ARGV
            }
			else {
				die "Can't open python file $arg\n";
			}
		}
	}
}
elsif (not -t STDIN) {
    local $/;
	$cli_commands = <STDIN>
}
else {
#     usage();
    exit;
}


# exit unless $input;
exit if !defined $cli_commands or $cli_commands =~ /^\s*$/;;
$cli_commands = " " if length $cli_commands == 0;

sub get_single_quoted_string {
	my $char;
	my $string = "";
	$end_of_string = 0;
	while (not $end_of_string) {
		while ( read($INPUT, $char, 1), $char ne "'" and $char ne "\\" and not eof $INPUT ) {
			$string .= $char;
		}
		if ($char eq "'") {
			$string .= $char;
			$end_of_string = 1;
		}
		elsif ($char eq "\\") {
			$string .= $char;
			read($INPUT, $char, 1);
			$string .= $char;
		}
		else {	# eof $INPUT
			$string .= $char;
			$end_of_string = 1;
		}
	}
	return $string
}

sub get_double_quoted_string {
	my $char;
	my $string = "";
	$end_of_string = 0;
	while (not $end_of_string) {
		# end of file necessary only in the case of incorrect syntax like: print("this is\\" text")
		while ( read($INPUT, $char, 1), $char ne "\"" and $char ne "\\" and not eof $INPUT ) {
			$string .= $char;
		}
		if ($char eq "\"") {
			$string .= $char;
			$end_of_string = 1;
		}
		elsif ($char eq "\\") {
			$string .= $char;
			read($INPUT, $char, 1);
			$string .= $char;
		}
		else { 	# eof $INPUT
			$string .= $char;
			$end_of_string = 1;
		}
	}
	return $string
}


sub get_block {
	my $char;
	my $block = "";
	$object_level = 1;
	while ($object_level > 0 and not eof $INPUT) {
		read $INPUT, $char, 1;
		$block .= $char;
		if ($char eq "\"") {
			$block .= get_double_quoted_string();
		}
		elsif ($char eq "'") {
			$block .= get_single_quoted_string();
		}
		elsif ($char eq "{") {
			$object_level++;
		}
		elsif ($char eq "}") {
			$object_level--;
		}
	}
	chop $block;	# remove final '}'
	return $block =~ s/^\s+//r;
}

# store the $input into an in-memory file (the scalar variable $oneliner)
# which allow to read one character at a time using a filehandle, using "read"
# open $INPUT, "+<", \$input;
# print $INPUT $cli_commands;
# seek $INPUT, 0, 0;

open $INPUT, "<", \$cli_commands;
# open $INPUT, "<:encoding(UTF-8)", \$cli_commands;	# ???????

open $SCRIPT_FILE, ">", \$script;

foreach (@import) {
	print $SCRIPT_FILE "import $_\n";
}
print $SCRIPT_FILE "\n"
# 	if @import and not $n_switch and not $p_switch;		# avoid empty line between 2 import
	if @import;


# add correct indentation for classes ?
# if empty block --> put 1 ??? or ... or pass

while (not eof $INPUT) {

	while (		read($INPUT, $char, 1),
			($char ne ";")	# end of instruction
		and ($char ne "{")	# block start
		and ($char ne "}")	# block end
		and ($char ne "(")	# function or method or tupple start
		and ($char ne "[")	# list start
		and ($char ne "=")	# assignment (in case an dict or a set is assigned to a variable)
		and (not eof $INPUT)
	)
	{
		next if $char eq " " and $line eq "";	# strip spaces at the begining of an instruction
												# like in pyrepl 'var=5; print(var)' (space before print)
		$line .= $char;
	}
	
	# END OF INSTRUCTION
	if ($char eq ";") {
        $first_block_instruction = 0;
		print $SCRIPT_FILE " " x ($indent_level * $indent_size) . $line . "\n";
		$line = "";
	}

	# BLOCK START (if, for, while)
	elsif ($char eq "{") {
        $first_block_instruction = 1;
        print $SCRIPT_FILE " " x ($indent_level * $indent_size) . $line . ":\n";
        $indent_level++;
        $line = "";
	}

	# BLOCK END (if, for, while)
	elsif ($char eq "}") {		# detect empty block ???
        if ($first_block_instruction) {
            if ($line =~ /^\s*$/) {
		        print $SCRIPT_FILE " " x ($indent_level * $indent_size) . "pass" . "\n\n";
            }
            else {
		        print $SCRIPT_FILE " " x ($indent_level * $indent_size) . $line . "\n\n";
            }
        }
        else {
		    print $SCRIPT_FILE " " x ($indent_level * $indent_size) . $line . "\n\n";
        }
        $first_block_instruction = 0;
		$indent_level--;
		$line = "";
	}

# python -c 'print("hello")'
# python -c 'print ("hello")'


	# FUNCTION OR METHOD OR TUPPLE START
	elsif ($char eq "(") {
        $first_block_instruction = 0;
		$paren_level = 1;
		$line .= $char;
# 		while ($paren_level > 0) {
		while ($paren_level > 0 and not eof $INPUT) {
			read $INPUT, $char, 1;
			$line .= $char;
			if ($char eq "\"") {
				$line .= get_double_quoted_string();
			}
			elsif ($char eq "'") {
				$line .= get_single_quoted_string();
			}
			elsif ($char eq "(") {
				$paren_level++;
			}
			elsif ($char eq ")") {
				$paren_level--;
			}
		}
	}

	# LIST START (for i in [1,2,3,4,5])
	elsif ($char eq "[") {
#         $first_block_instruction = 0;
		$list_level = 1;
		$line .= $char;
		while ($list_level > 0 and not eof $INPUT) {
			read $INPUT, $char, 1;
			$line .= $char;
			if ($char eq "\"") {
				$line .= get_double_quoted_string();
			}
			elsif ($char eq "'") {
				$line .= get_single_quoted_string();
			}
			elsif ($char eq "[") {
				$list_level++;
			}
			elsif ($char eq "]") {
				$list_level--;
			}
		}
	}

	# ASSIGNMENT
	elsif ($char eq "=") {
        $first_block_instruction = 0;
		$line .= $char;
		while( read($INPUT, $char, 1), $char eq " " and not eof $INPUT) {
			$line .= $char;
		}
		# DICT OR SET ASSIGNMENT
		if ($char eq "{") {
			$line .= $char;
			$object_level = 1;
			while ($object_level > 0 and not eof $INPUT) {
				read $INPUT, $char, 1;
				$line .= $char;
				if ($char eq "\"") {
					$line .= get_double_quoted_string();
				}
				elsif ($char eq "'") {
					$line .= get_single_quoted_string();
				}
				elsif ($char eq "{") {
					$object_level++;
				}
				elsif ($char eq "}") {
					$object_level--;
				}
			}
		}
		# LIST ASSIGNMENT
		elsif ($char eq "[") {
			$line .= $char;
			$list_level = 1;
			while ($list_level > 0 and not eof $INPUT) {
				read $INPUT, $char, 1;
				$line .= $char;
				if ($char eq "\"") {
					$line .= get_double_quoted_string();
				}
				elsif ($char eq "'") {
					$line .= get_single_quoted_string();
				}
				elsif ($char eq "[") {
					$list_level++;
				}
				elsif ($char eq "]") {
					$list_level--;
				}
			}
		}

		# SINGLE QUOTED STRING assignment
		elsif ($char eq "'") {
			$line .= $char;
			$line .= get_single_quoted_string();
		}

		# DOUBLE QUOTED STRING assignment
		elsif ($char eq "\"") {
			$line .= $char;
			$line .= get_double_quoted_string();
		}

		# EOF or bare NUMBER or python BUILT-IN CONSTANTS (True, False, None, NotImplemented, Ellipsis, ..., __debug__, etc..)
		else {
			$line .= $char;
			# the following characters of the assignment continue to be appended on the next loop iteration
		}
	}

	# END OF FILE
	else {
		$line .= $char;
		print $SCRIPT_FILE " " x ($indent_level * $indent_size) . $line . "\n";
		$line = "";
	}
}

# $script = correctly_whitespaced($cli_commands);	# $cli_program


# final flush
if ($line ne "") {	# case when program finishes after "]" or ")" but no trailing ";" on the last instruction
	print $SCRIPT_FILE " " x ($indent_level * $indent_size) . $line . "\n";
}


close $INPUT;
close $SCRIPT_FILE;

die   "unmatched curly bracket\n" if $indent_level != 0 and not $debug;
print "unmatched curly bracket\n" if $indent_level != 0 and $debug;

$script = "\n" . $script . "\n";

my $exec = 'exec("'
          . $script =~ s/\\/\\\\/gr =~ s/\n/\\n/gr =~ s/"/\\"/gr
          . '")';

system "python", "-c", $exec, @ARGV;

if ($debug) {
	print "-" x 40, "\n";
	print "WHITESPACE EQUIVALENT\n";
# 	print $script =~ s/\\n/\n/gr;			# original
	chomp $script;							# added
	print $script =~ s/\\n/\n/gr, "\n";		# added
	print "-" x 40, "\n";
	print "COMMAND\n";
	print "python -c \'$exec\'\n";
}



__END__



PREVIOUS EDGE CASES RESOLVED

==> manage empty blocks
pyrepl -e 'def slurp(arg) {  }; slurp(1, 2, 3, 4, 5)'
pyrepl -e 'for i in ["a","b","c"] { }'
pyrepl -e 'class Color() {}'

pyrepl 'for i in iter([1,2,3,4,5]) {print(i)}'

# def add(a,b) { return a+b }
# for i in [1,2,3,4,5] { print(i) }
# pyrepl -e 'var="text"; if var == "text" { print("true") }'

pyrepl -e 'array=list(range(5)); try {print(array[4])} except { }'
pyrepl -e 'array=list(range(5)); try {print(array[5])} except { print("err") }'
pyrepl -e 'array=list(range(5)); for i in range(5) { try {print(array[5])} except { print("err") }}'


