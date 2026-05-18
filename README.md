# Stronghold of the Dwarven Lords

A retro-style terminal adventure game written in modern Perl.

Explore the ancient stronghold, search for the hidden treasure, and survive
the endless halls beneath the mountain.

The game features:

- procedurally generated maze
- source beam distance hints
- stamina system
- colored terminal interface
- old-school dungeon atmosphere

## Requirements

- Perl 5.38+
- cpanminus
- GNU Make

## Installation

Clone the repository:

```bash
git clone https://github.com/YOUR_USERNAME/stronghold-game.git
cd stronghold-game
```

Install dependencies:

```bash
cpanm --installdeps .
```

## Running the game

```bash
make run
```

Or directly:

```bash
perl -Ilib script/stronghold.pl
```

## Development

Run code checks:

```bash
make check
```

Format source code:

```bash
make tidy
```

Run tests:

```bash
make test
```

Show available commands:

```bash
make help
```

## Controls

### Main menu

- `N` — new game
- `H` — help
- `Q` — quit

### In game

- `N` — move north
- `S` — move south
- `E` — move east
- `W` — move west
- `M` — show map (costs stamina)
- `Q` — return to main menu

## Project structure

```text
lib/Stronghold/
    Game.pm
    Map.pm
    MazeGenerator.pm
    Tile.pm

script/
    stronghold.pl
```

## Notes

This project is part of a personal effort to revisit Perl through small games,
algorithms, and console applications using modern practices and clean code.

## License

This project is licensed under the same terms as Perl itself.
