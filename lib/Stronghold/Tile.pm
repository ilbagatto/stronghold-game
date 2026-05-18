package Stronghold::Tile;

# Defines shared tile constants used by maps and maze generation.
use v5.38;
use warnings;

use Exporter qw/import/;

our @EXPORT_OK = qw/WALL FLOOR/;

use constant {
    WALL  => 'wall',
    FLOOR => 'floor',
};

1;

__END__

=encoding utf-8

=head1 NAME

Stronghold::Tile - shared tile constants for Stronghold of the Dwarven Lords

=head1 SYNOPSIS

    use Stronghold::Tile qw(WALL FLOOR);

    my $wall = WALL;
    my $floor = FLOOR;

=head1 DESCRIPTION

Stronghold::Tile defines symbolic constants for map cell types.

The module is intentionally small and independent, so other modules can use
shared tile names without creating circular dependencies.

=head1 LICENSE

Copyright (C) ilbagatto.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

ilbagatto E<lt>sergei.krushinski@gmail.comE<gt>

=cut
