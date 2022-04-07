
package system;

use strict;
use warnings;
use v5.10;

use Carp;
use Cwd qw(abs_path);
use File::Basename;
use File::Spec;

use Exporter 'import';
our @EXPORT = qw(file);

sub file {
    my $path = shift;
    my $type;
    my $abspath;
    my $basename;
    my $dirname;
    my @splitted_path;

    # need a special case because Cwd::abs_path rely on stat, which returns undef on
    # symbolic links (not the case with lstat), therefore abs_path also returns undef, prematurely
    if (-l $path) {
        $type = "link";

        $basename = File::Basename::basename $path;
        $dirname  = abs_path shift;
        $abspath = $dirname . "/" . $basename;

        (undef, @splitted_path) = File::Spec->splitdir($abspath);

        my %self = (
            orig_relpath   => $path,
#             orig_cwd    => $dirname,
            abspath     => $abspath,
            dirname     => $dirname,
            basename    => $basename,
            type        => $type,
            pathlist    => \@splitted_path,
        );

        return bless \%self, "file";
    }
    else {
        if (! -e $path) {
            croak "file \"$path\" does not exists";
        }
        if (! -f $path) {
            croak "\"$path\" is not a file";
        }
        $type = "file";
    }

    $abspath  = abs_path($path);
    $dirname  = dirname($abspath);
    $basename = basename($abspath);

    (undef, @splitted_path) = File::Spec->splitdir($abspath);

    my %self = (
        orig_relpath   => $path,
#         orig_cwd    => ,
        abspath     => $abspath,
        dirname     => $dirname,
        basename    => $basename,
        type        => $type,
        pathlist    => \@splitted_path,
    );

    bless \%self, "file";
}

sub dir {
    my $path = shift;
    if (! -e $path) {
        croak "directory \"$path\" does not exists";
    }
    if (! -d $path) {
        croak "\"$path\" is not a directory";
    }

    my $abspath = abs_path($path);
    my %self = (
        orig_relpath   => $path,
        abspath     => $abspath,
    );

    bless \%self, "dir";
}


package file;

use strict;
use warnings;
use v5.10;
use Carp;
use Scalar::Util qw(openhandle);
use overload q{""} => sub { $_[0]->{orig_relpath} };
# use overload q{""} => sub { $_[0]->{abspath} };

sub new {
    my $class = shift;
    my $path = shift;

    if (-e $path) {
        croak "file \"$path\" already exists";
    }

}

sub exists_p {
    my $self = shift;
    -e $self->{abspath} ? 1 : undef
}

sub file_p {
    my $self = shift;
    -f $self->{abspath} ? 1 : undef
}

sub link_p {
    my $self = shift;
    -l $self->{abspath} ? 1 : undef
}

# sub zero_size_p {
sub zero_p {
    my $self = shift;
    -z $self->{abspath} ? 1 : 0
}

sub size {
    my $self = shift;
    (stat $self->{abspath})[7];
}

sub abspath {
#     $_[0]->{abspath}
    basename($_[0]->{abspath})
}

sub basename {
    basename($_[0]->{abspath})
}

sub dirname {
#     $_[0]->{dirname};
    system::dir($_[0]->{dirname});
#     system::dir(dirname($_[0]->{abspath}));

#     my $self = shift;
#     system::dir(dirname($self->{abspath}));
#     system::dir(File::Basename::dirname($self->{abspath}));
}

sub open {
    my $self = shift;
    my $open_arg = shift // "<";
    if (openhandle($self->{fh})) {
        croak "\"$self->{abspath}\" file already opened";
    }
    open my $fh, $open_arg, $self->{abspath};
    $self->{fh} = $fh;
    $self;
}

sub close {
    my $self = shift;
}

sub read {
    my $self = shift;
    if (! openhandle($self->{fh})) {
        croak "\"$self->{abspath} \"filehandle not open";
    }
    if (defined $_[0]) {
        my $bytes;
        read $self->{fh}, $bytes, shift;
        $bytes;
    }
    else {
        local $/;
        readline $self->{fh};
    }
}

sub write {
    my $self = shift;
}

sub slurp {
    my $self = shift;
    $self->open->read;
}

sub spurt {
    my $self = shift;
}

sub readline {
    my $self = shift;
}

sub readlines {
    my $self = shift;
}

sub fh {
    my $self = shift;
    if (my $fh = openhandle($self->{fh})) {
        $fh
    }
    else {
        my $open_opt = shift // "<";
        CORE::open my $fh, $open_opt, $self->{abspath} // croak "could not open $self->{abspath}";
        $self->{fh} = $fh;
    }
}

sub seek {
    my $self = shift;
}

sub tell {
    my $self = shift;
}

sub copy {
}

sub move {
}

sub rename {
}

package dir;

use strict;
use warnings;
use v5.10;
use Carp;
use Cwd;

use overload q{""} => sub { $_[0]->{orig_relpath} };
# use overload q{""} => sub { $_[0]->{abspath} };


sub files {
    my $self = shift;
    my $cwd = cwd();
    opendir my $dir, $self->{abspath};
    chdir $self->{abspath};
    my @files = map { -l ? system::file($_, $self->{abspath}) : system::file($_) } grep { -f || -l } readdir $dir;
    closedir $dir;
    chdir $cwd;
    return @files;
}


sub dirs {
    my $self = shift;
    my $cwd = cwd();
    opendir my $dir, $self->{abspath};
    chdir $self->{abspath};
    my @dirs = map { system::dir($_) } grep { -d } readdir $dir;
    closedir $dir;
    chdir $cwd;
    return @dirs;
}









1;
__END__





