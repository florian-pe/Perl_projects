#!/usr/bin/perl

# DEPENDENCY :
# sudo cpan install JSON::XS

# usage :
# find -name "*.php" | ./extract_queries.pl 

# what it does :
# exrtact SQL queries stored in functions containing statements like this one :
# $query = "SELECT * from urls";

use strict;
use warnings;
use v5.10;
use JSON::XS;

my @files = map { chomp; $_ } <STDIN>;

our $capture;
our @capture;

my $regex = qr{

    (?{
        local $capture;
    })

    (?&func)

    (?{
        push @capture, $capture
    })

    (?(DEFINE)
    
    (?<func> function \s+ ((?&identifier))

        (?{
            local $capture = { name => $+ }
         })
        
        \s* \( .*? \) (?&block)
    )

    (?<identifier> [_a-zA-Z][_a-zA-Z0-9]* )

    (?<comment> (?: // | \# ) [^\v]* | /\* .*? \*/  )

    (?<block> \s*  \{
            (?:   (?&ws)
                | (?&comment)
                | (?&query)
                | (?&op)
                | (?&variable)
                | (?&word)
                | (?&string)
                | (?&paren)
                | (?&block)
             )*+ \} )
    
    (?<word> \s* \w++ )
    
    (?<paren> \s* \(
            (?:   (?&ws)
                | (?&comment)
                | (?&query)
                | (?&op)
                | (?&variable)
                | (?&word)
                | (?&string)
                | (?&paren)
                | (?&block)
            )*+ \) )


    (?<string> \s* \' (?: [^'\\]++ | \\. )*+ \'
              | " (?: [^"\\]++ | \\. )*+  " )

    (?<op> \s* [ - + * / % . , ; \[ \] < > = ! ? : ~ & | ^ ]++ )

    (?<ws>  (?: \s++ | (?: \\\\ | \# ) [^\v]*+  )++ )

    (?<variable> \$ \w*+ )

    (?<query>
            \$ query \s* = \s* (?&string) \s* ;?

            (?{
                local $capture = $capture;
                push $capture->{queries}->@*, $+ =~ s/^\s*['"]//r =~ s/['"]$//r;
             })
    )

    )
}xs;

my $queries;
 
for my $file (@files) {

    if (! -e $file) {
        say "file '$file' does noot exists";
        next;
    }

    @capture = ();
    $capture = undef;

    open my $fh, "<", $file;
    my $str = do { local $/; <$fh> };
    close $fh;

    while ($str =~ /$regex/g) {
    }

    my @queries = grep { exists $_->{queries} } @capture;
    next if @queries == 0;

    push $queries->@*, {
        filename => $file,
        functions => \@queries
    };
}


say encode_json $queries;



