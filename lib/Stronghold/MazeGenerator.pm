package Stronghold::MazeGenerator;

# Builds a connected maze grid using recursive backtracking.
use v5.38;
our $VERSION = "0.01";
use warnings;

use Stronghold::Tile qw/WALL FLOOR/;

sub generate {
    my ( $class, $size ) = @_;

    my $grid = _filled_grid( $size, WALL );

    # Step 1: start carving from the first inner cell.
    _carve_passages( $grid, 1, 1, $size );

    return $grid;
}

sub _filled_grid {
    my ( $size, $cell ) = @_;

    my @grid;

    # Step 2: fill the whole grid with walls.
    for my $row ( 0 .. $size - 1 ) {
        for my $col ( 0 .. $size - 1 ) {
            $grid[$row][$col] = $cell;
        }
    }

    return \@grid;
}

sub _carve_passages {
    my ( $grid, $row, $col, $size ) = @_;

    # Step 3: mark the current cell as a floor tile.
    $grid->[$row][$col] = FLOOR;

    # Step 4: try directions in random order.
    for my $direction ( _shuffled_directions() ) {
        my ( $drow, $dcol ) = @$direction;

        # Step 5: jump two cells to keep walls between corridors.
        my $next_row = $row + $drow * 2;
        my $next_col = $col + $dcol * 2;

        # Step 6: skip cells outside the inner map area.
        next if _is_border( $next_row, $next_col, $size );

        # Step 7: skip cells that were already carved.
        next if $grid->[$next_row][$next_col] eq FLOOR;

        # Step 8: remove the wall between the current cell and the next cell.
        $grid->[ $row + $drow ][ $col + $dcol ] = FLOOR;

        # Step 9: continue carving from the next cell.
        _carve_passages( $grid, $next_row, $next_col, $size );
    }
}

sub _shuffled_directions {
    my @directions = ( [ -1, 0 ], [ 1, 0 ], [ 0, 1 ], [ 0, -1 ], );

    for my $i ( reverse 1 .. $#directions ) {
        my $j = int rand( $i + 1 );
        @directions[ $i, $j ] = @directions[ $j, $i ];
    }

    return @directions;
}

sub _is_border {
    my ( $row, $col, $size ) = @_;

    return
           $row <= 0
        || $row >= $size - 1
        || $col <= 0
        || $col >= $size - 1;
}

1;
__END__

=encoding utf-8

=head1 NAME

Stronghold::MazeGenerator - recursive maze generator for Stronghold of the Dwarven Lords

=head1 SYNOPSIS

    use Stronghold::MazeGenerator;

    my $grid = Stronghold::MazeGenerator->generate(15);

=head1 DESCRIPTION

Stronghold::MazeGenerator builds a square maze grid using recursive
backtracking.

The generator starts with a grid filled with walls, then carves connected
passages from the first inner cell. It returns the generated grid as an
array reference suitable for Stronghold::Map.

The module does not know anything about player position, treasure position,
or game rules.

=head1 LICENSE

Copyright (C) ilbagatto.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

ilbagatto E<lt>sergei.krushinski@gmail.comE<gt>

=cut

