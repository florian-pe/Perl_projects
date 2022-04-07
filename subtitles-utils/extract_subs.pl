#!/usr/bin/perl

use strict;
use warnings;
use v5.10;
use File::Seen;
use Capture::Tiny q(:all);

my @files = map { chomp; $_ } qx{ ls };
my @archives = grep { / \.zip $ /x } @files;

tie my %seen, "File::Seen", { equal => "bytes", keep_duplicates => 1 },
        map { $_ => 1 } grep { /\.srt$/ } @files;

my $movie;
for (@files) {
    if (/ ^ ( .* ) \.mp4 $ /x) {
        $movie = $1;
        last;
    }
}

mkdir ".temp_subs";

my $i=0;
for (@archives) {
    $i++;
    # extract a .zip archive into its own temporary directory (-d)
    # (-n) don't overwrite existing destination files, in case the script in run twice
    my ($out, $err, $exit) = capture { system "unzip", "-n", "-d", ".temp_subs/temp$i", $_ };
}

my @subs = grep { ! $seen{$_}++ } grep { / \. srt $ /x } map { chomp; $_ } qx{ find ./.temp_subs };

my @unique_subs = grep { ! $seen{$_}++ } @subs;
my $seen = tied %seen;

$i = 1;
for ($seen->unique_files) {
    rename $_->{path}, $movie . $i . ".srt";
    rmdir $_->{dir};
    $i++;
}

for ($seen->duplicates) {
    unlink $_->{path};
    rmdir $_->{dir};
}

unlink $_ for grep { -f } map { chomp; $_ } qx { find ./.temp_subs };
rmdir  $_ for grep { -d } map { chomp; $_ } qx { find ./.temp_subs };

rmdir ".temp_subs";

