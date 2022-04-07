#!/usr/bin/perl

use strict;
use warnings;
use date;
use LWP::UserAgent;
use HTTP::Request;
use HTTP::Headers;
binmode STDOUT, ":encoding(UTF-8)";
# open my $OUT, ">&:encoding(UTF-8)", *STDOUT;

sub help {
	print STDERR <<~"EOF";
	$0 [\\d+] [today|week] [sciences|sante|noctambu|droit|lettres]
	EOF
}

if (@ARGV) {
	if ($ARGV[0] =~ m/^-{0,2}(help|h)$/ ) {
		help();
		exit;
	}
}


# 'https://nantilus.univ-nantes.fr/horaires/Horaires.php?ics=horaire_bu_sciences&date=2021-05-26'   

my %header_fields = (
	"Connection"       => 'keep-alive',
	"sec-ch-ua"        => '" Not A;Brand";v="99", "Chromium";v="90"',
	"Accept"           => 'application/json, text/javascript, */*; q=0.01',
	"X-Requested-With" => 'XMLHttpRequest',
	"sec-ch-ua-mobile" => '?0',
	"Sec-Fetch-Site"   => 'same-origin',
	"Sec-Fetch-Mode"   => 'cors',
	"Sec-Fetch-Dest"   => 'empty',
	"Referer"          => 'https://nantilus.univ-nantes.fr/horaires/',
	"Accept-Language"  => 'en-US,en;q=0.9,fr;q=0.8',
	"Cookie"           => '_pk_ref.9.d553=%5B%22%22%2C%22%22%2C1620714374%2C%22https%3A%2F%2Fduckduckgo.com%2F%22%5D; _pk_id.9.d553=795d3b1b5bb717c9.1620714374.; _pk_ses.9.d553=1',
	"dnt"              => 1,
	"sec-gpc"          => 1,

);

sub horaires_par_date {
	my $bu = shift;
	my $date = shift;
# 	my $url = "https://nantilus.univ-nantes.fr/horaires/Horaires.php?ics=horaire_bu_sciences&date=$date";
	my $url = $bu . $date;
# 	print "URL \"$url\""; exit;

	my $header = HTTP::Headers->new(%header_fields);
	my $request = HTTP::Request->new(GET => $url, $header);
	my $ua = LWP::UserAgent->new();
	$ua->agent("Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.114 Safari/537.36");
	return $ua->request($request)->{_content} =~ s/\\u([0-9a-fA-F]{4})/chr hex $1/erg;
}

my %BU_URL = (
	sciences      => "https://nantilus.univ-nantes.fr/horaires/Horaires.php?ics=horaire_bu_sciences&date=",
	sante         => "https://nantilus.univ-nantes.fr/horaires/Horaires.php?ics=horaire_bu_sante&date=",
	noctambu      => "https://nantilus.univ-nantes.fr/horaires/Horaires.php?ics=horaire_bu_sante_noctambu&date=",
	droit         => "https://nantilus.univ-nantes.fr/horaires/Horaires.php?ics=horaire_bu_droit&date=",
	lettres       => "https://nantilus.univ-nantes.fr/horaires/Horaires.php?ics=horaire_bu_lettres&date=",
	technologies  => "https://nantilus.univ-nantes.fr/horaires/Horaires.php?ics=horaire_bu_technologies&date=",
	roche_sur_yon => "https://nantilus.univ-nantes.fr/horaires/Horaires.php?ics=horaire_bu_cud&date=",
	saint_nazaire => "https://nantilus.univ-nantes.fr/horaires/Horaires.php?ics=horaire_bu_gavy&date=",
);

my $number_of_weeks = 1;
my $bu = "sciences";
my $every_bu_today = 0; # should be renamed
my $every_bu_week = 0;  # should be renamed

while (my $arg = shift) {
	if ($arg =~ m/^\d+$/) {
		$number_of_weeks = $arg;
	}
	elsif ( grep { $_ eq $arg } keys %BU_URL ) {
		$bu = $arg;
	}
	elsif ($arg eq "today") {
		$every_bu_today = 1;
	}
	elsif ($arg eq "week") {
		$every_bu_week = 1;
	}
}

my $date = date->new()->today();
# print $date->string();
my $date_of_today = $date->format();


$\="\n";

if (not $every_bu_week and not $every_bu_today) {

	while ($date->{weekday} != 1) {
		$date->previous_day;
	}

	print "BU $bu";

	for (1 .. 7 * $number_of_weeks ) {

		print "-" x 40 if $date->{weekday} == 1 and $number_of_weeks > 1;

# 		next if $date->{weekday} == 6 or $date->{weekday} == 0;		# skip samedi et dimanche

		print join "\t", $date->string(),
						 horaires_par_date($BU_URL{$bu}, $date->format()),
						 $date->format() eq $date_of_today ? "(AUJOURD'HUI)" : "";
# 		print "-" x 40 if $date->{weekday} == 5 and $number_of_weeks > 1;

	} continue {
		$date->next_day;
	}
}
elsif ($every_bu_today) {
	print join "\t", "DATE $date_of_today", $date->format() eq $date_of_today ? "(AUJOURD'HUI)" : "";
	foreach my $bu (qw(sciences sante noctambu lettres droit)) {
		 printf "%-16s%s\n", $bu, horaires_par_date($BU_URL{$bu}, $date->format());
	}
}
elsif ($every_bu_week) {
	while ($date->{weekday} != 1) {
		$date->previous_day;
	}

	my @days = qw(Dimanche Lundi Mardi Mercredi Jeudi Vendredi Samedi);

	for (1 .. 7 * $number_of_weeks ) {

# 		next if $date->{weekday} == 6 or $date->{weekday} == 0;		# skip samedi et dimanche

# 		print join "\t", "DATE " . $date->format(),
		print join "\t", $date->format(),
					$days[$date->{weekday}],
					$date->format() eq $date_of_today ? "(AUJOURD'HUI)" : "";

		foreach my $bu (qw(sciences sante noctambu lettres droit)) {
			 printf "%-16s%s\n", $bu, horaires_par_date($BU_URL{$bu}, $date->format());
		}

# 		print join "\t", $date->string(),
# 						 horaires_par_date($BU_URL{$bu}, $date->format()),
# 						 $date->format() eq $date_of_today ? "(AUJOURD'HUI)" : "";
		print "-" x 40;

	} continue {
		$date->next_day;
	}
}









