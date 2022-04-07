#!/usr/bin/perl

use strict;
use warnings;
use autodie;

# TO DO
# install with argument --systemd or --x
# --systemd --> current script
# --x       --> :
#
# touch ~/.xinitrc and put into it
# ". /home/london/.xprofile >> ~/.xinitrc"
#
# touch ~/.xprofile and put into it
# #!/bin/sh
# mpd &

#perl -le 'print "true" if grep m|^#!/|, <ARGV>' .xprofile

# $ENV{HOME}/.ncmpcpp/config
my $ncmpcpp_config_heredoc = <<"END"
% egrep -v '^#' .ncmpcpp/config
mpd_music_dir = "$ENV{HOME}/Music/"
visualizer_in_stereo = "yes"
visualizer_fifo_path = "/tmp/mpd.fifo"
visualizer_output_name = "my_fifo"
visualizer_sync_interval = "30"
visualizer_type = "spectrum"
visualizer_look = "◆▋"
#visualizer_look = "+|"
message_delay_time = "3"
playlist_shorten_total_times = "yes"
playlist_display_mode = "columns"
browser_display_mode = "columns"
search_engine_display_mode = "columns"
#search_engine_display_mode = "classic"
playlist_editor_display_mode = "columns"
autocenter_mode = "yes"
centered_cursor = "yes"
user_interface = "alternative"
follow_now_playing_lyrics = "yes"
locked_screen_width_part = "60"
display_bitrate = "yes"
external_editor = "nano"
use_console_editor = "yes"
header_window_color = "cyan"
volume_color = "red"
state_line_color = "yellow"
state_flags_color = "red"
progressbar_color = "yellow"
statusbar_color = "cyan"
visualizer_color = "red"
mpd_host = "$ENV{HOME}/.config/mpd/socket"
#mpd_host = "127.0.0.1"
mpd_port = "6600"
#mpd_port = "6601"
#mouse_list_scroll_whole_page = "yes"
mouse_list_scroll_whole_page = "no"
mouse_support = "no"
lines_scrolled = "1"
#ask_before_clearing_main_playlist = "yes" # make ncmpcpp crash
enable_window_title = "yes"
song_columns_list_format = "(25)[cyan]{a} (40)[]{f} (30)[red]{b} (7f)[green]{l}"
END
;

# $ENV{HOME}/.mpd/mpd.conf
my $mpd_conf_heredoc = <<"END"
music_directory "$ENV{HOME}/Music/"
playlist_directory "$ENV{HOME}/Music/"
db_file "$ENV{HOME}/.mpd/mpd.db"
log_file "$ENV{HOME}/.mpd/mpd.log"
pid_file "$ENV{HOME}/.mpd/mpd.pid"
state_file "$ENV{HOME}/.mpd/mpdstate"
	
audio_output {
	type "pulse"
	name "pulse audio"
}

audio_output {
    type                 "fifo"
    name                 "my_fifo"
    path                 "/tmp/mpd.fifo"
    format               "44100:16:2"
}

bind_to_address          "$ENV{HOME}/.config/mpd/socket"
#bind_to_address          "127.0.0.1"
port                     "6600"
#port                     "6601"
END
;

my $FH;

system qw(sudo apt install mpd mpc ncmpcpp);	# doesn't work for ArchLinux

mkdir "$ENV{HOME}/.mpd";
mkdir "$ENV{HOME}/.ncmpcpp";


my $ncmpcpp_config_path  = "$ENV{HOME}/.ncmpcpp/config";
my $mpd_conf_path        = "$ENV{HOME}/.mpd/mpd.conf";

unless ( -e "$ncmpcpp_config_path" and not -z "$ncmpcpp_config_path" ) {
	open  $FH, ">>", "$ncmpcpp_config_path"; 
	print $FH $ncmpcpp_config_heredoc;
	close $FH;
}

unless ( -e "$mpd_conf_path" and not -z "$mpd_conf_path" ) {
	open  $FH, ">>", "$mpd_conf_path";
	print $FH $mpd_conf_heredoc;
	close $FH;
}

# create 3 files
open $FH, ">>", "$ENV{HOME}/.mpd/mpd.db" ; close $FH;
open $FH, ">>", "$ENV{HOME}/.mpd/mpd.log"; close $FH;
open $FH, ">>", "$ENV{HOME}/.mpd/mpd.pid"; close $FH;

mkdir "$ENV{HOME}/.config/mpd";

open $FH, ">>", "$ENV{HOME}/.config/mpd/socket"; close $FH;

#########################
# for mpc
open  $FH, "+<", "$ENV{HOME}/.bashrc";
my @bashrc = <$FH>;
my $mpd_host = grep {/export \s+ MPD_HOST/x} @bashrc;
my $mpd_port = grep {/export \s+ MPD_PORT/x} @bashrc;

if ( ! $mpd_host ) {	# if bashrc do not already have export MPD_HOST="..."
	print $FH "export MPD_HOST=\"$ENV{HOME}/.config/mpd/socket\"","\n";
	print "export MPD_HOST=\"$ENV{HOME}/.config/mpd/socket\"","\n";
}

if ( ! $mpd_port ) {	# if bashrc do not already have export MPD_PORT="..."
	print $FH "export MPD_PORT=6600","\n";
	print "export MPD_PORT=6600","\n";
}
close $FH;
##########################
# launch mpd
system qw(systemctl --user enable mpd.service)
	or warn "systemctl --user enable mpd.service: $!";
system qw(systemctl --user start mpd.service)
	or warn "systemctl --user start mpd.service: $!";

# not strictly necessary
system qw(xfce4-terminal -e ncmpcpp); # on xfce4 desktop
#system qw(x-terminal-emulator -e ncmpcpp); # other terminal emulator



