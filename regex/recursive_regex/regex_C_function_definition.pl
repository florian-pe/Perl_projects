#!/usr/bin/perl

use strict;
use warnings;
use v5.10;
# use Regexp::Debugger;
# use re 'eval';

open my $fh, "<", "./C_file.txt";
my $file = do { local $/; <$fh> };
close $fh;

# definition of a pattern to be reused in a regex to match the definition of a C function

my $func = qr{
    (?(DEFINE)

        (?<func> \s* \( (?>.*? \) ) (?! \s* ; ) .*? (?&block) )

        (?<block> \{
                (?:   (?&ws)
                    | (?&op)
                    | (?&word)
                    | (?&string)
                    | (?&paren)
                    | (?&block)
                 )*+ \} )
        
        (?<word> \w++ )
        
        (?<paren> \(
                (?:   (?&ws)
                    | (?&op)
                    | (?&word)
                    | (?&string)
                    | (?&paren)
                )*+ \) )

#   gcc warnings indicating that multicharacter single quoted strings are allowed
#         warning: character constant too long for its type
#         printf("%c\n", 'abcde' );
#         warning: multi-character character constant [-Wmultichar]
#         printf("%c\n", '\ab' );

        (?<string> \' (?: [^'\\]++ | \\. )*+ \'
                  | " (?: [^"\\]++ | \\. )*+  " )

        (?<op> [ - + * / % . , ; \[ \] < > = ! ? : ~ & | ^ ]++ )

        (?<ws> (?: \s++ | (?: \\\\ | \# ) [^\v]*+  )++ )
    ) 
   
}xxs;

my ($match) = $file =~ / (\bgram_parse\b (?&func) ) $func/x;

say $match;


