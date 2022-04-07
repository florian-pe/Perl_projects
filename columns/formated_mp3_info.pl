#!/usr/bin/perl

use strict;
use warnings;
use MP3::Info;
use Term::ReadKey;
use List::Util qw(max);

# binmode STDOUT, ":encoding(UTF-8)";
open my $OUT, ">&:encoding(UTF-8)", *STDOUT;

my $zip = sub {
    my ($array_a, $array_b)=@_;
    return [ map {
        if (ref $array_a->[$_] eq "ARRAY") {
            [$array_a->[$_]->@*, $array_b->[$_]]
        }
        else {
            [$array_a->[$_], $array_b->[$_]]
        }
    } 0..$array_a->$#*]
};

sub reduce {
    my $code = shift;
	my $acc = shift;
    while (@_) {
        $acc = $code->($acc, shift);
    }
    return $acc;
}

sub transpose { reduce $zip, @_ }

# print_columns ARRAYREF, ARRAYREF        # CURRENT
# print_columns ARRAYREF, LIST (records with same number of fields) # number of fields ?? ===> specified in the format
# print_columns FORMAT, ARRAYREF
# print_columns FORMAT, LIST
# print_columns FILEHANDLE/GLOB, FORMAT, ARRAYREF
# print_columns FILEHANDLE/GLOB, FORMAT, LIST

# perl -le 'nl; $format="%-19sstring%%sstring%s\n"; print grep {length} split /(?<!%)(%-?\d*s)/, $format'
# perl -le 'printf "%%\n"'
# %
# perl -le 'printf "%%%%\n"'
# %%

# perl -le 'nl; @fields=split /(\d)/, "a1b2b"; print @fields; __; print scalar @fields'   # 5
# perl -le 'nl; @fields=split /(\d)/, "a1b2b3"; print @fields; __; print scalar @fields'  # 6
# perl -le 'nl; @fields=split /(\d)/, "0a1b2b"; print @fields; __; print scalar @fields'  # 7


sub print_columns {
    my $OUT;
    if (ref $_[0] eq "GLOB" || ref $_[0] eq "IO::File") {
#     if (ref $_[0] eq "GLOB" || ref $_[0] eq "IO::File" || ref $_[0] eq "IO") {
        $OUT = shift;
    }
    else {
        $OUT = *STDOUT;
    }

#     my $format = shift;
#     if (ref $_[0] eq "ARRAY") {
#         my $text = shift;
#     }
#     else {
#         my @text = @_;
#     }
#     my $length_literal = length $format =~ s/(?<!%)(%-?\d*s)//gr =~ s/%%/%/gr;
#     my $length_fixed_fields = reduce {$a+$b} map { m/%-?(\d+)s/ ? $1 : 0 } $format =~ m/(?<!%)(%-?\d*s)/g;
#     my $available_columns = $terminal_width - $length_literal - $length_fixed_fields;
#     my $number_unfixed_fields = () = $format =~ m/(?<!%)(%-?s)/g;
#    my @fields_length = map { m/%-?(\d+)s/ ? $1 : "" } $format =~ m/(?<!%)(%-?\d*s)/g;
#    my $remainder = $available_columns % $number_unfixed_fields;
#    my $quotient = int($available_columns / $number_unfixed_fields);
#     for (@fields_length) {
#         if ($_ eq "") {
#             if ($remainder > 0) {
#                 $_ = $quotient + 1;
#                 $remainder--;
#             }
#         }
#     }

	my ($dims, $text)=@_;

	die if $dims->@* % 2 == 1;  # each field should have a start and end column
	my ($terminal_width) = GetTerminalSize();
	if (grep {/\$/} $dims->@*) {
		s/\$/$terminal_width/ for $dims->@*
	}
	my $format = "%" . $dims->[0] ;
	my ($start_col, $end_col);
	my @record_lines;
	our @column_width;
	local @column_width;
# 	my @column_width = $dims->[0];
	@column_width = $dims->[0];

	while ($dims->@*) {
		$start_col = shift $dims->@*;
		$end_col = shift $dims->@*;
		push @column_width, ($end_col - $start_col - 2);
	}
	$format = join("", map({ "%-${_}s" } @column_width), "\n");

	sub compose_lines {
		my $record = shift;
		my @column;
		my $col_no = 0;
		my $max;
		foreach my $field ($record->@*) {
			$col_no++;
			chomp $field;
# 			push @column, [ $field =~ m/\G(.{,$column_width[$col_no]}(?:\w\b|\W))/gs ];
			push @column, [ map {s/^\s+//r} $field =~ m/\G(.{,$column_width[$col_no]}(?:\w\b|\W))/gs ];
		}
        $max = max map { scalar $_->@* } @column;
        for (@column) {
            $_->@* = ($_->@*, ("") x ($max - scalar $_->@*));
        }

        return transpose(@column)->@*;
	}

	foreach my $record ($text->@*) {
		@record_lines = compose_lines($record);
		foreach my $composed_line (@record_lines) {
			printf $OUT $format, "", $composed_line->@*;
		}
	}
}

my $file = shift // exit;
my $tag = get_mp3tag($file);

# printf "%-17s%s\n", $_, $tag->{$_} for sort keys $tag->%*;

#   [0;18[  [18; $]
# print_columns( [0,18,18,'$'], [map { [$_, $tag->{$_}] } sort keys $tag->%*]); # CURRENT
print_columns($OUT, [0,19,19,'$'], [map { [$_, $tag->{$_}] } sort keys $tag->%*]);

# print_columns( [0,18,18,'$'], [(map { [$_, $tag->{$_}] } sort keys $tag->%*)[0]]);
# for (map { [$_, $tag->{$_}] } sort keys $tag->%*) {
#     printf "%-17s%s\n", $_->@*;
#     last;
# }


# printf_columns
# --> directly LIST for lines that have all the same name of fields
# --> or array reference for lines that have variable number of fields


# print_columns( "%-18s%s", [map { [$_, $tag->{$_}] } sort keys $tag->%*]);

close $OUT;

__END__

16173-07.07.2021-ITEMA_22721482-2021F26104S0188.mp3 

./formated_mp3_info.pl 16173-07.07.2021-ITEMA_22721482-2021F26104S0188.mp3 

perl -le 'print join "\n", "Grand bien vous fasse !" =~ m/\G(.{,15}(?:\w\b|\W))/g'
perl -le '$var="words with spaces ! "; print join "\n", $var =~ /.{,11}(?:\w\b|\W)/g'
