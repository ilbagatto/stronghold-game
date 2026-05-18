#!/usr/bin/env perl

# Console frontend for Stronghold: menus, input handling, and terminal rendering.

use v5.38;
use warnings;

use Term::ReadKey;
use Term::ANSIColor qw/colored/;

use Stronghold::Tile qw/WALL FLOOR/;
use Stronghold::Game;

use constant DEBUG_SHOW_TREASURE => ( $ENV{STRONGHOLD_DEBUG_SHOW_TREASURE} // 0 );
use constant DEBUG_SHOW_MAP      => ( $ENV{STRONGHOLD_DEBUG_SHOW_MAP}      // 0 );

sub show_status {
    my $message = shift;

    return if !$message;

    say '';
    say colored( $message, 'bold bright_yellow' );
}

sub clear_screen {
    print "\e[2J\e[H";
}

sub wait_for_key {
    my $message = shift;

    say '';
    say colored( $message, 'bold yellow' );
    read_command();
}

sub show_main_menu {
    clear_screen();
    say colored( "================================", "bright_black" );
    say colored( " Stronghold of the Dwarven Lords", "bold yellow" );
    say colored( "================================", "bright_black" );
    say "";
    say colored( "[N]", "bold green" ) . " New game";
    say colored( "[H]", "bold cyan" ) . " Help";
    say colored( "[Q]", "bold red" ) . " Quit";
    say "";
}

sub show_help {
    clear_screen();
    say '';
    say colored( 'The ancient Stronghold of the Dwarven Lords lies buried', 'bold white' );
    say colored( 'deep beneath the mountain.',                              'bold white' );
    say '';
    say colored( 'Somewhere within its endless halls rests a lost treasure.', 'bold white' );
    say colored( 'You must find it before your strength fails.',              'bold white' );
    say '';
    say colored( 'The source beam reveals your distance from the treasure.', 'bold white' );
    say colored( 'Use it wisely.',                                           'bold white' );
    say '';
    say colored( 'Maps may be summoned from the ancient archives,',   'bold white' );
    say colored( 'but each glimpse of the maze costs precious time.', 'bold white' );
    say '';
    say colored( 'Press any key to return to the main menu.', 'bold yellow' );

    read_command();
}

sub show_game_menu {
    say "";
    say colored( "Game commands", "bold yellow" );
    say colored( "-------------", "bright_black" );
    say colored( "[N]",           "bold green" ) . " Move north";
    say colored( "[S]",           "bold green" ) . " Move south";
    say colored( "[E]",           "bold green" ) . " Move east";
    say colored( "[W]",           "bold green" ) . " Move west";
    say colored( "[M]",           "bold cyan" ) . " Show map";
    say colored( "[Q]",           "bold red" ) . " Return to main menu";
    say "";
}

sub read_command {
    ReadMode('cbreak');

    my $key = ReadKey(0);
    ReadMode('restore');
    return defined $key ? uc $key : '';
}

sub cell_char {
    my $cell = shift;
    return $cell eq WALL ? '██' : '  ';
}

sub show_map {
    my $game = shift;
    my $map  = $game->game_map;
    say '';
    for my $row ( 0 .. $map->size - 1 ) {
        for my $col ( 0 .. $map->size - 1 ) {
            if ( $game->is_player_at( $row, $col ) ) {
                print colored( '@@', 'bold red' );
            }
            elsif ( DEBUG_SHOW_TREASURE && $game->is_treasure_at( $row, $col ) ) {
                print colored( '◆◆', 'bold yellow' );
            }
            else {
                print colored( cell_char( $map->cell_at( $row, $col ) ), "white" );
            }
        }
        say "";
    }
    say "\n";
}

sub show_beam {
    my $game = shift;
    my ( $v, $h ) = $game->source_beam;
    say colored( "Source beam signal: ", "bold cyan" )
        . colored( 'V=',   'white' )
        . colored( "$v, ", "bold white" )
        . colored( 'H=',   'white' )
        . colored( $h,     "bold white" );
}

sub show_stamina {
    my $game = shift;

    say colored( "Stamina: ", "bold cyan" )
        . colored( "@{[ $game->remaining_stamina ]}/@{[ $game->stamina ]}", "bold white" );
}

sub show_game_result {
    my $game = shift;

    if ( $game->is_won ) {
        show_status(
            "The treasure is yours.\nThe Stronghold yields after @{[ $game->steps ]} moves.");
        return;
    }

    if ( $game->is_lost ) {
        show_status("Your strength is spent.\nThe darkness of the Stronghold closes around you.");
        return;
    }
}

sub move_status {
    my ( $before_v, $before_h, $after_v, $after_h ) = @_;

    my $before = $before_v + $before_h;
    my $after  = $after_v + $after_h;

    return "The path grows warmer.\nThe hidden treasure draws nearer. Your next move."
        if $after < $before;

    return "The signal fades.\nYou have strayed farther from the prize. Your next move."
        if $after > $before;

    return "You advance, yet the ancient signal holds steady.\nYour next move.";
}

sub run_game {

    my $game = Stronghold::Game->new();

    clear_screen();
    show_status(
"Before you descend, the ancient gate reveals the shape of the halls.\nStudy it well. Further visions will cost you strength."
    );
    show_map($game);
    wait_for_key('Press any key to enter the stronghold.');

    my $status = "The adventure begins.\nThe halls of the Dwarven Lords await your first step.";

    clear_screen();
    while ( !$game->is_finished ) {

        show_status($status);
        show_game_menu();
        show_beam($game);
        show_stamina($game);

        my $command = read_command();
        clear_screen();

        if ( $command eq 'Q' ) {
            last;
        }
        elsif ( $command eq 'M' ) {
            $game->apply_map_penalty;
            show_map($game);

            if ( $game->is_finished ) {
                show_game_result($game);
                wait_for_key('Press any key to exit.');
                last;
            }

            wait_for_key('Press any key to continue.');
            clear_screen();
            $status = "The ancient map is revealed. Wisdom has its price.\nYour next move.";
        }
        elsif ( $command =~ /^[NSEW]$/ ) {
            my ( $before_v, $before_h ) = $game->source_beam;
            my $move = $game->move($command);
            my ( $after_v, $after_h ) = $game->source_beam;

            show_map($game) if DEBUG_SHOW_MAP;

            if ( !$move ) {
                $status =
                    "Stone bars the way. The mountain itself denies your passage.\nYour next move.";
                next;
            }
            if ( $game->is_finished ) {
                show_game_result($game);
                wait_for_key('Press any key to continue.');
                last;
            }

            $status = move_status( $before_v, $before_h, $after_v, $after_h );
        }
    }
}

while (1) {

    # say $MAIN_MENU;
    show_main_menu();

    my $command = read_command();

    if ( $command eq 'N' ) {
        run_game();
    }
    elsif ( $command eq 'H' ) {
        show_help();
    }
    elsif ( $command eq 'Q' ) {
        last;
    }
}

__END__

=encoding utf-8

=head1 NAME

stronghold.pl - console frontend for Stronghold of the Dwarven Lords

=head1 SYNOPSIS

    perl -Ilib script/stronghold.pl

=head1 DESCRIPTION

This script provides the terminal interface for the game: main menu, game
commands, keyboard input, colored output, screen clearing, map rendering,
stamina display, and status display.

The game rules and state are implemented in Stronghold::Game. Map storage and
maze generation are implemented in modules under C<lib/Stronghold>.

=head1 AUTHOR

ilbagatto

=cut
