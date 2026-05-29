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

use constant ARTIFACTS => (
    { name => 'healing water', points => 25 },
    { name => 'dwarven bread', points => 20 },
    { name => 'ancient ale',   points => 15 },
);

use Stronghold::Map;

sub new {
    my $class = shift;

    my $map      = Stronghold::Map->new( size => MAP_SIZE );
    my $player   = _place_player();
    my $treasure = _place_treasure( $map->size );
    my $self     = {
        _finished  => 0,
        _result    => undef,
        _steps     => 0,
        _stamina   => STAMINA,
        _player    => $player,
        _treasure  => $treasure,
        _artifacts => _place_artifacts( $map, $player, $treasure ),
        _map       => $map,
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

sub is_artifact_at {
    my $self = shift;
    my ( $row, $col ) = @_;

    return !!$self->artifact_at( $row, $col );
}

sub move {
    my ( $self, $direction ) = @_;
    my $result = { moved => 0 };

    my $delta = DIRECTIONS->{$direction};
    return $result if !$delta;

    my ( $drow, $dcol ) = @$delta;

    my $new_row = $self->player->{row} + $drow;
    my $new_col = $self->player->{col} + $dcol;

    return $result if $self->game_map->is_wall( $new_row, $new_col );

    $result->{moved}     = 1;
    $self->player->{row} = $new_row;
    $self->player->{col} = $new_col;
    $self->{_steps}++;

    if ( my $artifact = $self->collect_artifact_at( $new_row, $new_col ) ) {
        $result->{artifact} = $artifact;
    }

    if ( $self->is_treasure_at( $new_row, $new_col ) ) {
        $self->_finish(RESULT_WON);
    }
    elsif ( $self->is_exhausted ) {
        $self->_finish(RESULT_LOST);
    }

    return $result;
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

sub artifacts { $_[0]->{_artifacts} }

sub artifact_at {
    my $self = shift;
    my ( $row, $col ) = @_;

    for my $artifact ( $self->artifacts->@* ) {
        return $artifact
            if $artifact->{row} == $row
            && $artifact->{col} == $col;
    }

    return undef;
}

sub collect_artifact_at {
    my $self = shift;
    my ( $row, $col ) = @_;

    for my $i ( 0 .. $self->artifacts->$#* ) {
        my $artifact = $self->artifacts->[$i];

        next if $artifact->{row} != $row;
        next if $artifact->{col} != $col;

        splice $self->artifacts->@*, $i, 1;

        $self->{_steps} -= $artifact->{points};
        $self->{_steps} = 0 if $self->{_steps} < 0;

        return $artifact;
    }

    return undef;
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

sub _place_artifacts {
    my ( $map, $player, $treasure ) = @_;

    # Collect all candidate floor cells.
    my @positions;
    for my $row ( 1 .. $map->size - 2 ) {
        for my $col ( 1 .. $map->size - 2 ) {

            # Artifacts cannot appear inside walls, on the player, or on the treasure.
            next if $map->is_wall( $row, $col );
            next if $row == $player->{row}   && $col == $player->{col};
            next if $row == $treasure->{row} && $col == $treasure->{col};

            push @positions, { row => $row, col => $col };
        }
    }

    # Place one artifact of each type on a random free cell.
    my @artifacts;
    for my $template (ARTIFACTS) {
        last if !@positions;

        my $index    = int rand @positions;
        my $position = splice @positions, $index, 1;

        # Remove the chosen position so it cannot be reused.

        # Merge artifact properties with map coordinates.
        push @artifacts, { $template->%*, $position->%*, };
    }

    return \@artifacts;
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
position, treasure position, stamina recovery artifacts, movement, score
counter, stamina limit, map penalty, source beam signal, and win/loss result.


The module contains the game rules but does not handle terminal input or
screen rendering.

Artifacts are placed on random floor cells when a new game starts. They cannot
appear inside walls, on the player, or on the treasure. When the player finds
one, it is removed from the map and restores part of the player's stamina by
reducing the accumulated step cost.

=head1 ARTIFACTS

The game creates one instance of each artifact template defined by C<ARTIFACTS>,
if enough free floor cells are available.

Each artifact has a name, a stamina value, and map coordinates. Public helper
methods allow the UI layer to check whether an artifact is present at a given
cell without exposing the placement algorithm.

=head2 artifact_at

    my $artifact = $game->artifact_at($row, $col);

Returns the artifact located at the given map cell, or C<undef> if the cell does
not contain an artifact.

=head2 is_artifact_at

    if ($game->is_artifact_at($row, $col)) { ... }

Returns a boolean value indicating whether an artifact is located at the given
map cell. This is mainly useful for debug rendering.

=head2 collect_artifact_at

    my $artifact = $game->collect_artifact_at($row, $col);

Removes the artifact from the map, restores stamina by reducing the accumulated
step cost, and returns the collected artifact. Returns C<undef> if there is no
artifact at the given cell.

=head1 LICENSE

Copyright (C) ilbagatto.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

ilbagatto E<lt>sergei.krushinski@gmail.comE<gt>

=cut
