
package nested_capture;
use strict;
use warnings;
# use diagnostics;
use v5.10;
use Carp;
# use dd;
# use Exporter 'import';
# our @EXPORT = qw();
# use Tie::IxHash;
# use Symbol

# perl -MSymbol -E '$sym=gensym->**; $sym->$* = "SCALAR"; $sym->@* = 1..5; $sym->%* = (key => "value"); *myvar = $sym->**; say $myvar; say @myvar; say %myvar; say $myvar[2]; say $myvar{key}'

our @stack;

sub new {
    my $class = shift;
    my %self;
    while (my $key = shift) {
        $self{ $key } = shift // croak "need value for named parameter: $key\n";
    }
    if (!exists $self{regex} || ref $self{regex} ne "Regexp") {
        croak "not a regex\n";
    }
    $self{regex} = add_nested_capture($self{regex});
    bless \%self, $class;
}

sub match {
    use re 'eval';

    my ($self, $string) = @_;
    our $match;
#     say "REGEX {";
#     say $self->{regex};
#     dd $self;
#     say "}";
#     exit;

#     say "STRING \"$string\"";
#     say "REGEX { $self->{regex} }";
    $string =~ $self->{regex};

#     my $regex = $self->{regex};
#     if ("abcdef" =~ $regex) {
#         say "true"
#     }
#     else {
#         say "false"
#     }
#     exit;

#     say "MATCH \"$match\"";
    return $match;
}


sub add_nested_capture {
    my $regex = shift;
#     use re 'eval';


#     $regex =~ s{ ^ }{ (?{ local \@stack; }) }x;
    if ( not $regex =~ s{ ^ \s* \(\?\^([alupimnsx]*): }{(?{ local \@stack; })}x) {
        croak "could not find outter (?^: .... ) group"
    }

    my $flags = $1;
    $regex =~ s/ \) \s* $ //x;

#     say "FLAGS \"$flags\"";
#     exit;
    
#     $regex =~ s{ $ }{
#         (?{ say "MATCH"; dd \\\@stack; \$match = pop \@stack; })
#     }x;
#         (?{ \$match = pop \@stack; })

    my @groups;
    push @groups, { type => "root" };

    $regex =~ s{

            (?<backslash> \\ . )
        |
            (?<comment> [(] [?] [#] )
        |
            (?<non_capturing>
                    [(] [?]  [adluimnsx]* (?: - [imnsx]* )? :
                |
                    [(] [\^] [aluimnsx]* :
            )
        |
            (?<pattern_modifier>
                    [(] [?]      [adlupimnsx]* (?: - [imnsx]* )?
                |
                    [(] [?] [\^] [alupimnsx]* :
            )
        |
            (?<positive_lookahead>  [(] [?] =  )
        |
            (?<negative_lookahead>  [(] [?] !  )
        |
            (?<positive_lookbehind> [(] [?] <= )
        |
            (?<negative_lookbehind> [(] [?] <! )
        |
            (?<subrule_call>        [(] [?] & (?&NAME) [)] )
        |
            (?<sub_pattern>         [(] [?] >  )
        |
            (?<named_capture>       [(] [?]
                                            (?:
                                                   P? < (?&NAME) >
                                                |
                                                    ' (?&NAME) '
                                             )
            )
        |
            (?<branch_reset>        [(] [?] [|] )
        |
            (?<extended_charclass>  [(] [?] \[ )
        |
            (?<embedded_code>       [(] [?]     (?&CODEBLOCK) [)] )
        |
            (?<embedded_code_regex> [(] [?] [?] (?&CODEBLOCK) [)] )
        |
            (?<conditional>         [(] [?] [(]
                    (?:
                            DEFINE [)]
                        |
                            [1-9][0-9]* [)]
                        |
                           (?<lookaround_conditional> [?] < ? [=!] )
                        |
                            R \d* [)]
                        |
                            R & (?&NAME) [)]
                        |
                            [?] (?&CODEBLOCK) [)]
                    )
            )
        |
            (?<recurse_subpattern>  [(] [?] [-+]? (?: \d+ | R ) )
        |
            (?<positive_lookahead>  [(] [*] (?:pla|positive_lookahead)  : )
        |
            (?<negative_lookahead>  [(] [*] (?:nla|negative_lookahead)  : )
        |
            (?<positive_lookbehind> [(] [*] (?:plb|positive_lookbehind) : )
        |
            (?<negative_lookbehind> [(] [*] (?:nlb|negative_lookbehind) : )
        |
            (?<sub_pattern>         [(] [*] atomic : )
        |
            (?<script_run>          [(] [*] (?:sr|script_run) : )
        |
            (?<atomic_script_run>   [(] [*] (?:asr|atomic_script_run) : )
        |
            (?: [(] [*]
                (?:
                        PRUNE (?: : (?&NAME))?
                    |
                        SKIP  (?: : (?&NAME))?
                    |
                      (?:MARK)?   : (?&NAME)
                    |
                        THEN  (?: : (?&NAME))?
                    |
                        COMMIT (?: : (?&arg))?
                    |
                        (?: F (?:AIL)? ) (?: : (?&arg))?
                    |
                        ACCEPT (?: : (?&arg))?
                )
                [)]
            )
        |
            [(] [?] P [=>] (?&NAME) [)]
        |
            (?<capturing_group> [(] )
        |
            (?<group_end> [)] )

        (?(DEFINE)
            (?<NAME> [a-zA-Z_][a-zA-Z_0-9]*)
            (?<arg>  [a-zA-Z_][a-zA-Z_0-9]*)

            # doesn't take into account strings containing unbalanced { or } ??
            (?<CODEBLOCK>  \{ (?: (?&CODEBLOCK) | . )*? \}  )
            # single quoted strings
            # double quoted strings
            # hash subscript
            # blocks
            # anonymous array
            # regex (?{}) (??{}) {min,max}, etc .. --> recurse ????
            # s{}{} m{} tr{}{} y{}{} qr{}{} qw{} q{} qq{} qx{}
        )

    }{
        my $ret;

        if    (defined $+{comment}) {
            push @groups, { type => "comment" }
        }
        elsif (defined $+{non_capturing}) {
            push @groups, { type => "non_capturing" }
        }
        elsif (defined $+{pattern_modifier}) {
#             say "seen pattern modifier \"$+{pattern_modifier}\"";
            push @groups, { type => "pattern_modifier" };
#             $ret = '';
        }
        elsif (defined $+{positive_lookahead}) {
            push @groups, { type => "positive_lookahead" }
        }
        elsif (defined $+{negative_lookahead}) {
            push @groups, { type => "negative_lookahead" }
        }
        elsif (defined $+{positive_lookbehind}) {
            push @groups, { type => "positive_lookbehind" }
        }
        elsif (defined $+{negative_lookbehind}) {
            push @groups, { type => "negative_lookbehind" }
        }
        elsif (defined $+{subrule_call}) {    # closing paren already passed
            $groups[-1]->{named}++;
            # push @groups, { type => "subrule_call" };
            # put clode directly after subrule_call ??
        }
        elsif (defined $+{sub_pattern}) {
            push @groups, { type => "sub_pattern" }
        }
        elsif (defined $+{branch_reset}) {
            push @groups, { type => "branch_reset" }
        }
        elsif (defined $+{named_capture}) {
            $groups[-1]->{named}++;
            push @groups, { type => "named_capture" };
        }
        elsif (defined $+{extended_charclass}) {
            push @groups, { type => "extended_charclass" }
        }
        elsif (defined $+{embedded_code}) {
#             push @stack, { type => "embedded_code" };
            # do nothing, let the codeblock be replaced by itelf / $&
        }
        elsif (defined $+{embedded_code_regex}) {
#             push @groups, { type => "embedded_code_regex" };
            # do nothing, let the codeblock be replaced by itelf / $&
        }
        elsif (defined $+{conditional}) {
            push @groups, { type => "conditional" };
            if (defined $+{lookaround_conditional}) {
                push @groups, { type => "lookaround_conditional" };
            }
        }
        elsif (defined $+{recursive_sub_pattern}) {
#             push @groups, { type => "recursive_sub_pattern" }
        }
        elsif (defined $+{script_run}) {
            push @groups, { type => "script_run" }
        }
        elsif (defined $+{atomic_script_run}) {
            push @groups, { type => "atomic_script_run" }
        }
        elsif (defined $+{capturing_group}) {
            $groups[-1]->{numbered}++;
            push @groups, { type => "capturing_group" };
#             $ret = '(' . '(?{ local @stack = @stack; push @stack, [] })';
        }
        elsif (defined $+{group_end}) {
            if ($groups[-1]->{type} eq "capturing_group") {

                if (exists $groups[-1]->{named} || exists $groups[-1]->{numbered}) {     # not a leaf

                    my $caps = ($groups[-1]->{named} // 0 ) + ($groups[-1]->{numbered} // 0);
                    $ret = ')' . '(?{ local @stack = @stack; '
                               . "my \@caps = \@stack[-$caps..-1]; "
                               . "pop \@stack for 1 .. $caps; push \@stack, \\\@caps; })";
                }
                else {      # leaf
                    $ret = ')' . '(?{ push @stack, $+ })'
                }
            }
            elsif ($groups[-1]->{type} eq "named_capture" || $groups[-1]->{type} eq "subrule_call") {
                $ret = ')';
            }
            pop @groups;
        }

        $ret // $&
        
    }xesg;

#     say "REGEX { $regex }";
#     dd \@groups;
#     exit;
    
#     $regex =~ s/^/(?^x:/;
    $regex =~ s/^\s*/(?^$flags:/;

#     say "------------------------------";
#     dd \@groups;
#     say "------------------------------";
#     exit;

    my $caps = ($groups[-1]->{named} // 0 ) + ($groups[-1]->{numbered} // 0);
#     my $end = '(?{ local @stack = @stack; '
    my $end = '(?{ '
              . "my \@caps = \@stack[-$caps..-1]; "
              . "pop \@stack for 1 .. $caps; push \@stack, \\\@caps; })";

    if ($caps > 0) {
        $regex =~ s{ $ }{ $end }x;
#         $regex =~ s{ \s* $ }{(?{ say "MATCH"; dd \\\@stack; \$match = pop \@stack; }))}x;
        $regex =~ s{ \s* $ }{(?{ \$match = pop \@stack; }))}x;

#         $regex =~ s{$}{ )$end}x;
#         $regex =~ s{$}{ ) (?{ $end }) }xe;
    }
    else {
#         $regex =~ s/\s*$/)/;
#         $regex =~ s{ \s* $ }{(?{ say "MATCH"; dd \\\@stack; \$match = pop \@stack; }))}x;
        $regex =~ s{ \s* $ }{(?{ \$match = pop \@stack; }))}x;
    }

#     $regex =~ s{ $ }{(?{ say "MATCH"; dd \\\@stack; \$match = pop \@stack; })}x;
#         (?{ \$match = pop \@stack; })


#     say $regex;
#     exit;
    return $regex;
}



















1;
__END__



#           (?#text)          A comment
#           (?:...)           Groups subexpressions without capturing (cluster)
#           (?pimsx-imsx:...) Enable/disable option (as per m// modifiers)
#           (?=...)           Zero-width positive lookahead assertion
#           (*pla:...)        Same, starting in 5.32; experimentally in 5.28
#           (*positive_lookahead:...) Same, same versions as *pla
#           (?!...)           Zero-width negative lookahead assertion
#           (*nla:...)        Same, starting in 5.32; experimentally in 5.28
#           (*negative_lookahead:...) Same, same versions as *nla
#           (?<=...)          Zero-width positive lookbehind assertion
#           (*plb:...)        Same, starting in 5.32; experimentally in 5.28
#           (*positive_lookbehind:...) Same, same versions as *plb
#           (?<!...)          Zero-width negative lookbehind assertion
#           (*nlb:...)        Same, starting in 5.32; experimentally in 5.28
#           (*negative_lookbehind:...) Same, same versions as *plb
#           (?>...)           Grab what we can, prohibit backtracking
#           (*atomic:...)     Same, starting in 5.32; experimentally in 5.28
#           (?|...)           Branch reset
#           (?<name>...)      Named capture
#           (?'name'...)      Named capture
#           (?P<name>...)     Named capture (python syntax)
#           (?[...])          Extended bracketed character class
#           (?{ code })       Embedded code, return value becomes $^R
#           (??{ code })      Dynamic regex, return value used as regex
#           (?N)              Recurse into subpattern number N
#           (?-N), (?+N)      Recurse into Nth previous/next subpattern
#           (?R), (?0)        Recurse at the beginning of the whole pattern
#           (?&name)          Recurse into a named subpattern
#           (?P>name)         Recurse into a named subpattern (python syntax)
#           (?(cond)yes|no)
#           (?(cond)yes)      Conditional expression, where "(cond)" can be:
#                             (?=pat)   lookahead; also (*pla:pat)
#                                       (*positive_lookahead:pat)
#                             (?!pat)   negative lookahead; also (*nla:pat)
#                                       (*negative_lookahead:pat)
#                             (?<=pat)  lookbehind; also (*plb:pat)
#                                       (*lookbehind:pat)
#                             (?<!pat)  negative lookbehind; also (*nlb:pat)
#                                       (*negative_lookbehind:pat)
#                             (N)       subpattern N has matched something
#                             (<name>)  named subpattern has matched something
#                             ('name')  named subpattern has matched something
#                             (?{code}) code condition
#                             (R)       true if recursing
#                             (RN)      true if recursing into Nth subpattern
#                             (R&name)  true if recursing into named subpattern
#                             (DEFINE)  always false, no no-pattern allowed

+ script run ?
+ backtracking control verbs


"abcdef" =~ / ^ ( (...) (...) ) /x

[ ["abc"], ["def"] ]

$match->[0] => []

$match->[0][0] => "abc"
$match->[0][0] => "def"

/

^

(
    
    (
        ...
    )
    push @stack, $+
    
    (
        ...
    )
    push @stack, $+
)

@caps = @stack[-(2) .. -1]
pop @stack for 1 .. 2
push @stack, \@caps

(

..

)


$two = pop
$one = pop
push @stack, [$one, $two]




    
/x




