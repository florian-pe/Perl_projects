#!/usr/bin/perl

use strict;
use warnings;
use v5.10;
use Tie::IxHash;

my %display = (
    0 => { a => 1, b => 1, c => 1, d => 0, e => 1, f => 1, g => 1 },
    1 => { a => 0, b => 0, c => 1, d => 0, e => 0, f => 1, g => 0 },
    2 => { a => 1, b => 0, c => 1, d => 1, e => 1, f => 0, g => 1 },
    3 => { a => 1, b => 0, c => 1, d => 1, e => 0, f => 1, g => 1 },
    4 => { a => 0, b => 1, c => 1, d => 1, e => 0, f => 1, g => 0 },
    5 => { a => 1, b => 1, c => 0, d => 1, e => 0, f => 1, g => 1 },
    6 => { a => 1, b => 1, c => 0, d => 1, e => 1, f => 1, g => 1 },
    7 => { a => 1, b => 0, c => 1, d => 0, e => 0, f => 1, g => 0 },
    8 => { a => 1, b => 1, c => 1, d => 1, e => 1, f => 1, g => 1 },
    9 => { a => 1, b => 1, c => 1, d => 1, e => 0, f => 1, g => 1 },
);


sub render_num {
    my $segment = shift;
    my $render = $segment->{a} ? " aaaa \n" : " .... \n";

    if ($segment->{b}) {
        $render .= $segment->{c}
                  ? "b    c\nb    c\n"
                  : "b    .\nb    .\n";
    }
    else {
        $render .= $segment->{c}
                  ? ".    c\n.    c\n"
                  : ".    .\n.    .\n";
    }

    $render .= $segment->{d} ? " dddd \n" : " .... \n";

    if ($segment->{e}) {
        $render .= $segment->{f}
                  ? "e    f\ne    f\n"
                  : "e    .\ne    .\n";
    }
    else {
        $render .= $segment->{f}
                  ? ".    f\n.    f\n"
                  : ".    .\n.    .\n";
    }

    $render .= $segment->{g} ? " gggg \n" : " .... \n";
}

# for (0 .. 9) {
#     say render_num($display{$_})
# }

my %segment_number;
# tie my %segment_number, "Tie::IxHash"; # no need ?

$Data::Dumper::Sortkeys = 0;

for my $num (sort keys %display) {

    my $segment_count = grep { $_==1 } values $display{$num}->%*;

    if (! ref $segment_number{ $segment_count }) {
        tie my %hash, "Tie::IxHash";
        $segment_number{ $segment_count } = \%hash;
    }

    $segment_number{ $segment_count }->{$num} = 1;
}

# dd \%segment_number;
# say %segment_number;
# say $segment_number{5}->%*;

my @damaged_display;

my @entries;

while (<>) {
    my (@signals, @digits);
    (@signals[0..9], @digits) = / ([a-g]+) /gx;

    for (@signals, @digits) {
        $_ = join "", sort split "", $_;
    }

    push @entries, { signals => \@signals, digits => \@digits };
}
dd \@entries;


sub unify {
#     my ($entry, $guess) = @_;
    my ($signals, $guess) = @_;

    say "unify($guess->{sig})";

    # $guess => {
    #     numbers  => { right number    => signal pattern index },
    #     segments => { segment pattern => right segment        },
    # }


#     SIGNAL_PATTERN:
#     # for each signal pattern
#     for (my $sig=$guess->{sig}; $sig < $signals->@*; $sig++) {

#         my $signal = $signals->[$sig];
    my $signal = $signals->[ $guess->{sig} ];
    
    NUMBER_GUESS:
    # guess a number
    for my $num (grep { !exists $guess->{numbers}->{$_} }  0 .. 9) {

        # see if the guessed number has the same number of segments than
        # the signal pattern
        next NUMBER_GUESS if !exists $segment_number{ length($signal) }->{$num};

    # abdfec guessed as being 6
    # seg_pat => seg_guess
    # a => c         c not in 6 ( display(6)->(c) == 0 ) so a should not be in signal
    # b => d         d     in 6 ( display(6)->(d) == 1 ) so b should     be in signal

        # see if previous guessed segments match the segments of the signal
        # pattern with guessed number
        for my $seg_pat (keys $guess->{segments}->%*) {

            my $seg_guess = $guess->{segments}->{$seg_pat};

            if ($display{$num}->{ $seg_guess }) {

                next NUMBER_GUESS if index($signal, $seg_pat) == -1;
            }
            else {
                next NUMBER_GUESS if index($signal, $seg_pat) != -1;
            }
        }

        if (keys($guess->{segments}->%*)==7 && keys($guess->{numbers}->%*)==10) {
            return $guess;
        }

        SEGMENT_PATTERN:
#         for my $seg_pat (grep { !exists $guess->{segments}->{$_} && (index($signal, $_)!=-1) } "a" .. "g") {
        for my $seg_pat (grep { !exists $guess->{segments}->{$_} && (index($signal, $_)!=-1) } "a" .. "g") {

            my $seg_guess = $guess->{segments}->{$seg_pat};
#             my $seg_guess = ;

            say "seg_pat $seg_pat";
            say $seg_guess // "seg_guess undefined";
            if ($display{$num}->{ $seg_guess }) {

                next SEGMENT_PATTERN if index($signal, $seg_pat) == -1;
            }
            else {
                next SEGMENT_PATTERN if index($signal, $seg_pat) != -1;
            }


            my $res = unify($signals, {
#                     sig => $guess->{sig},
                    sig => $guess->{sig} + 1,
#                         numbers  => { $guess->{numbers}->%*, $num  => $sig },
                    numbers  => { $guess->{numbers}->%*, $num  => $guess->{sig} },
                    segments => { $guess->{segments}->%*, $seg_pat => $seg_guess  },
                    seg_guesses => { $guess->{seg_guesses}->%*, $seg_guess => 1 },
                });
            if ($res) {
                return $res
            }
        }

    }

    return 0;

#     }

}

# dd $entries[0]->{signals};
# unify($entries[0]->{signals}, { sig => 0 });















__END__



0 => { a b c e   f g },
1 => {     c     f   },
2 => { a   c d e   g },
3 => { a   c d f   g },
4 => { b   c d f     },
5 => { a b   d   f g },
6 => { a b   d e f g },
7 => { a   c     f   },
8 => { a b c d e f g },
9 => { a b c d f   g },












