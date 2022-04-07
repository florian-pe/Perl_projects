
# Disclaimer :
# this module builds on top the general architecture of Tie::IxHash


package File::Seen::Object;

use strict;
use warnings;
use File::Basename;
use Cwd 'abs_path';
use Digest::MD5;

use overload q{""} => sub { $_[0]->{path} };

sub new {
    my $class = shift;
    my $path = shift;
    my %self;

    $self{path} = $path;

    if (! -e $path) {
        return undef;
#         return bless { non_existent => 1 }, $class
    }
    $self{size}     = -s $path;
    $self{abspath}  = abs_path($path);
    $self{dir}      = dirname($self{abspath});
    my $md5 = Digest::MD5->new;

    open $self{fh}, "<", $path;

    $md5->addfile($self{fh});
    $self{hash} = $md5->hexdigest;

    seek $self{fh}, 0, 0;

    $self{duplicates} = [];

    bless \%self, $class;
}

package File::Seen;

use strict;
use warnings;
use Carp;

my $equal_bytes = sub {
    my ($file_a, $file_b) = @_;

    if ($file_a->{size} != $file_b->{size}) {
        return 0;
    }
    elsif ($file_a->{hash} ne $file_b->{hash}) {
        return 0;
    }

    my ($bytes_a, $bytes_b);

    while (! eof($file_a->{fh})) {
        read $file_a->{fh}, $bytes_a, 4096;
        read $file_b->{fh}, $bytes_b, 4096;

        if ($bytes_a ne $bytes_b) {
            seek $file_a->{fh}, 0, 0;
            seek $file_b->{fh}, 0, 0;
            return 0;
        }
    }
    seek $file_a->{fh}, 0, 0;
    seek $file_b->{fh}, 0, 0;
    return 1;
};

my $equal_path = sub {
    $_[0]->{abspath} eq $_[1]->{abspath};
};

sub equal {
    my $self = shift;
    $self->[5]->&*;
}

sub TIEHASH {
    my $class = shift;
    my $option;
    my %option = (
        keep_duplicates => 1,
    );

    my $self = [];
    $self->[0] = {};    # hash
    $self->[1] = [];    # keys
    $self->[2] = [];    # values
    $self->[3] = 0;     # iterator state
    $self->[4] = \%option;
    $self->[5] = undef; # "equal" anonymous subroutine

    if (@_ && ref($_[0]) eq "HASH") {
        $option = shift;
    }
    else {
        croak "File::Seen: need a HASH ref of parameters";
    }
    
    while (my ($opt, $arg) = each $option->%*) {

        if (not defined $arg) {
            croak "File::Seen: no defined argument passed to parameter \"$opt\""
        }
        $option{ $opt } = $arg;

        if ($opt eq "equal") {

            # ref eq ""
            # ref eq "ARRAY"
            # ref eq "SUB"
            # string
            # size
            # path / abpath
            # md5
            # bytes


            if ($arg eq "bytes") {
                $self->[5] = $equal_bytes;
            }
            elsif ($arg eq "path") {
                $self->[5] = $equal_path;
            }
            else {
                croak "File::Seen: unrecognized argument to parameter $opt";
            }

        }
        elsif ($opt eq "keep_duplicates") {
            if ($arg != 0 && $arg != 1) {
                croak "File::Seen: argument to keep_duplicates should be 0 or 1";
            }
            $option{keep_duplicates} = $arg;
        }
        else {
            croak "File::Seen: unrecognized parameter $opt";
        }
    }

    if (! exists $option{equal}) {
        croak "File::Seen: no mandatory parameter \"equal\" given";
    }

    bless $self, $class;

    while (@_) {
        my $key = shift;
        my $value = shift // croak "File::Seen: odd number of elements during initialization";
        $self->STORE($key, $value);
    }

    # the use case of this field is to mark all the files that we care about that we don't want changed
    # they will be removed from the result of unique_files(), unique_files_ref() and duplicates() so that we don't have to filter existing files when iterating

    foreach my $file ($self->[2]->@*) {
        $file->{protected} = 1;
    }

    return $self;
}


sub FETCH {
    my ($self, $key) = @_;
    my $newfile = File::Seen::Object->new($key);

    foreach my $file ($self->[2]->@*) {

        if ($self->equal($file, $newfile)) {
            return $file->{value}
        }
    }

    return;
}

sub STORE {
    my ($self, $key, $value) = @_;
    my $newfile = File::Seen::Object->new($key);
    $newfile->{value} = $value;

    foreach my $file ($self->[2]->@*) {

        if ($self->equal($file, $newfile)) {
            if ($self->[4]->{keep_duplicates}) {

                push $file->{duplicates}->@*, $newfile
            }
            return
        }
    }

    push $self->[1]->@*, $key;
    push $self->[2]->@*, $newfile;
    $self->[0]{$key} = $self->[1]->$#*;
}

sub DELETE {
    my ($self, $key) = @_;

    if (exists $self->[0]->{$key}) {
        my ($i) = $self->[0]->{$key};

        for ($i+1 .. $self->[1]->$#*) {

            $self->[0]->{ $self->[1][$_] }--;
        }
        if ( $i == $self->[3]-1 ) {
            $self->[3]--;
        }
        delete $self->[0]->{$key};
        splice $self->[1]->@*, $i, 1;
        return (splice($self->[2]->@*, $i, 1))[0];
    }
    return undef;
}

sub CLEAR {
    $_[0]->[0]->%* = ();
    $_[0]->[1]->@* = ();
    $_[0]->[2]->@* = ();
    $_[0]->[3]     = 0;
}

sub EXISTS {
    exists $_[0][0]->{ $_[1] };
}

sub FIRSTKEY {
    $_[0][3] = 0;
    &NEXTKEY;
}

sub NEXTKEY {
    return $_[0][1][ $_[0][3]++ ] if ($_[0][3] <= $_[0][1]->$#* );
    return undef;
}

sub SCALAR {
    scalar $_[0][0]->%*
}

sub UNTIE {
    untie $_[0]->@*;
}

sub DESTROY {
    if ($_[0][4]->{keep_duplicates}) {
        foreach my $file ($_[0][2]->@*) {
            close $file->{fh};
            foreach my $dup ($file->{duplicates}->@*) {
                close $dup->{fh}
            }
        }
    }
    else {
        foreach my $file ($_[0][2]->@*) {
            close $file->{fh}
        }
    }
}

sub hash   { $_[0][0]->%* }
sub keys   { $_[0][1]->@* }
sub values { $_[0][2]->@* }
sub opts   { $_[0][4]->%* }

sub hash_ref   { $_[0][0] }
sub keys_ref   { $_[0][1] }
sub values_ref { $_[0][2] }
sub opts_ref   { $_[0][4] }


sub initial_files {
    grep { $_->{protected} } $_[0][2]->@*
}

sub unique_files     {
    grep { ! $_->{protected} } $_[0][2]->@*
}
sub unique_files_ref {
    [ grep { ! $_->{protected} } $_[0][2]->@* ]
}

sub duplicates {
    my $self = shift;
    my @dups;
    if (! $self->[4]->{keep_duplicates}) {
        croak "File::Seen: method duplicates: keep_duplicates is not set";
    }
    foreach my $file ($self->[2]->@*) {
        push @dups, grep { ! $file->{protected} } $file->{duplicates}->@*;
    }
    return @dups
}



1;
__END__

=pod 

=head1 NAME

    File::Seen

=head1 SYNOPSIS


=cut


