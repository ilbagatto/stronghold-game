package Stronghold::Game;
use v5.38;
use warnings;

use Exporter qw/import/;
our $VERSION = "0.01";

use constant {
    NORTH => 'N',
    SOUTH => 'S',
    EAST  => 'E',
    WEST  => 'W',
};

use constant DIRECTIONS => {
    NORTH() => [ -1,  0 ],
    SOUTH() => [  1,  0 ],
    EAST()  => [  0,  1 ],
    WEST()  => [  0, -1 ],
};

use constant {
    MAP_PENALTY => 15,
    MAP_SIZE    => 15,
    STAMINA     => 200,
    RESULT_WON  => 'won',
    RESULT_LOST => 'lost',
};

use Stronghold::Map;

sub new {
    my $class = shift;

    my $map  = Stronghold::Map->new( size => MAP_SIZE );
    my $self = {
        _finished => 0,
        _result   => undef,
        _steps    => 0,
        _stamina  => STAMINA,
        _player   => _place_player(),
        _treasure => _place_treasure( $map->size ),
        _map      => $map,
    };

    return bless $self, $class;
}

sub is_finished { $_[0]->{_finished} }

sub result { $_[0]->{_result} }

sub is_won { $_[0]->result && $_[0]->result eq RESULT_WON }

sub is_lost { $_[0]->result && $_[0]->result eq RESULT_LOST }

sub steps { $_[0]->{_steps} }

sub stamina { $_[0]->{_stamina} }

sub remaining_stamina { $_[0]->stamina - $_[0]->steps }

sub is_exhausted { $_[0]->steps >= $_[0]->stamina }

sub player { $_[0]->{_player} }

sub treasure { $_[0]->{_treasure} }

sub game_map { $_[0]->{_map} }

sub is_player_at {
    my $self = shift;
    my ( $row, $col ) = @_;

    my $player = $self->player;
    return $col == $player->{col}
        && $row == $player->{row};
}

sub is_treasure_at {
    my $self = shift;
    my ( $row, $col ) = @_;

    my $treasure = $self->treasure;
    return $col == $treasure->{col}
        && $row == $treasure->{row};
}

sub move {
    my ( $self, $direction ) = @_;

    my $delta = DIRECTIONS->{$direction};
    return 0 if !$delta;

    my ( $drow, $dcol ) = @$delta;

    my $new_row = $self->player->{row} + $drow;
    my $new_col = $self->player->{col} + $dcol;

    return 0 if $self->game_map->is_wall( $new_row, $new_col );

    $self->player->{row} = $new_row;
    $self->player->{col} = $new_col;
    $self->{_steps}++;

    if ( $self->is_treasure_at( $new_row, $new_col ) ) {
        $self->_finish(RESULT_WON);
    }
    elsif ( $self->is_exhausted ) {
        $self->_finish(RESULT_LOST);
    }

    return 1;
}

sub source_beam {
    my $self = shift;

    my $treasure = $self->treasure;
    my $player   = $self->player;
    return abs( $treasure->{row} - $player->{row} ), abs( $treasure->{col} - $player->{col} );
}

sub apply_map_penalty {
    my $self = shift;

    $self->{_steps} += MAP_PENALTY;
    $self->_finish(RESULT_LOST) if $self->is_exhausted;

    return $self->steps;
}

sub _finish {
    my ( $self, $result ) = @_;

    $self->{_finished} = 1;
    $self->{_result}   = $result;

    return $self;
}

sub _place_player {
    return { row => 1, col => 1 };
}

sub _place_treasure {
    my $size = shift;

    my @positions = (
        { row => $size - 2, col => $size - 2 },
        { row => $size - 2, col => 1 },
        { row => 1,         col => $size - 2 },
    );

    return $positions[ int rand @positions ];
}

1;
__END__

=encoding utf-8

=head1 NAME

Stronghold::Game - game state and rules for Stronghold of the Dwarven Lords

=head1 SYNOPSIS

    use Stronghold::Game;

    my $game = Stronghold::Game->new;
    $game->move('N');

=head1 DESCRIPTION

Stronghold::Game coordinates the current game state: the map, player
position, treasure position, movement, score counter, stamina limit, map
penalty, source beam signal, and win/loss result.

The module contains the game rules but does not handle terminal input or
screen rendering.

=head1 LICENSE

Copyright (C) ilbagatto.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

ilbagatto E<lt>sergei.krushinski@gmail.comE<gt>

=cut
