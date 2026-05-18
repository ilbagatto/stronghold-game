package Stronghold::Map;

# Stores the generated map grid and provides read-only cell queries.
use v5.38;
use warnings;

our $VERSION = "0.01";

use constant {
    WALL             => 'wall',
    FLOOR            => 'floor',
    DEFAULT_MAP_SIZE => 15,
};

use Stronghold::MazeGenerator;
use Stronghold::Tile qw/WALL FLOOR/;

sub _is_border {
    my ( $row, $col, $size ) = @_;

    return
           $row == 0
        || $row == $size - 1
        || $col == 0
        || $col == $size - 1;
}

sub new {
    my $class = shift;
    my %args  = ( size => DEFAULT_MAP_SIZE, @_ );

    my $self = {
        _size => $args{size},
        _grid => Stronghold::MazeGenerator->generate( $args{size} ),
    };

    return bless $self, $class;
}

sub size { $_[0]->{_size} }

sub cell_at {
    my $self = shift;
    my ( $row, $col ) = @_;
    return $self->{_grid}->[$row][$col];
}

sub is_wall {
    my $self = shift;
    return $self->cell_at(@_) eq WALL;
}

sub is_floor {
    my $self = shift;
    return $self->cell_at(@_) eq FLOOR;
}

1;
__END__

=encoding utf-8

=head1 NAME

Stronghold::Map - generated map grid for Stronghold of the Dwarven Lords

=head1 SYNOPSIS

    use Stronghold::Map;

    my $map = Stronghold::Map->new(size => 15);

    my $cell = $map->cell_at(1, 1);
    my $wall = $map->is_wall(0, 0);

=head1 DESCRIPTION

Stronghold::Map stores the generated map grid and exposes a small read-only
interface for querying its size and cell types.

The map does not implement game rules. It delegates maze construction to
Stronghold::MazeGenerator and keeps the grid representation hidden from the
rest of the program.

=head1 LICENSE

Copyright (C) ilbagatto.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

ilbagatto E<lt>sergei.krushinski@gmail.comE<gt>

=cut
