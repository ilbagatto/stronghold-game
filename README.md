# Stronghold of the Dwarven Lords

- [Stronghold of the Dwarven Lords](#stronghold-of-the-dwarven-lords)
  - [Requirements](#requirements)
  - [Installation](#installation)
  - [Running the game](#running-the-game)
  - [Standalone executables](#standalone-executables)
    - [macOS](#macos)
    - [Building executables locally](#building-executables-locally)
  - [Development](#development)
  - [Controls](#controls)
    - [Main menu](#main-menu)
    - [In game](#in-game)
  - [Debug options](#debug-options)
  - [Inspiration](#inspiration)
  - [Future ideas](#future-ideas)
  - [Notes](#notes)
  - [License](#license)


A retro-style terminal adventure game written in modern Perl.

Explore the ancient stronghold, search for the hidden treasure, and survive
the endless halls beneath the mountain.

The game features:

- procedurally generated maze
- source beam distance hints
- stamina system
- hidden artifacts that restore stamina
- colored terminal interface
- old-school dungeon atmosphere

## Requirements

- Perl 5.38+
- cpanminus
- GNU Make

## Installation

Clone the repository:

```bash
git clone https://github.com/ilbagatto/stronghold-game.git
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

## Standalone executables

Prebuilt executables for macOS, Linux, and Windows are available from the
GitHub Releases page.

The binaries are built automatically with GitHub Actions and PAR::Packer.

### macOS

The macOS build is unsigned. On first launch, Gatekeeper may block execution.

Remove the quarantine attribute:

```bash
xattr -d com.apple.quarantine ./stronghold-macos-arm64
```

Make the file executable:

```bash
chmod +x ./stronghold-macos-arm64
```

Run the game:

```bash
./stronghold-macos-arm64
```

### Building executables locally

Build a standalone executable:

```bash
make pack
```

The executable will be placed in:

```text
packed/
```

PAR::Packer builds platform-specific binaries. Windows builds should be
produced on Windows, Linux builds on Linux, and so on.

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

Ancient artifacts may be hidden in the stronghold. When found, they restore
part of the player's stamina.

## Debug options

The following environment variables are available for debugging:

| Variable | Description |
| --- | --- |
| `STRONGHOLD_DEBUG_SHOW_MAP` | Show the maze map during gameplay without spending stamina. |
| `STRONGHOLD_DEBUG_SHOW_ARTIFACTS` | Show artifact positions on the debug map. |

Example:

```bash
STRONGHOLD_DEBUG_SHOW_MAP=1 \
STRONGHOLD_DEBUG_SHOW_ARTIFACTS=1 \
make run
```

## Inspiration

The original idea was inspired by classic type-in and text adventure games from
*The Giant Book of Computer Games* by Tim Hartnell.

This project reimagines those ideas in modern Perl with procedural maze
generation, terminal graphics, stamina mechanics, and standalone builds.

## Future ideas

Possible future extensions include:

- more artifact types and effects
- localized versions in multiple languages
- web version
- Telegram playable version
- richer dungeon interactions and events

## Notes

This project is part of a personal effort to revisit Perl through small games,
algorithms, and console applications using modern practices and clean code.

## License

This project is licensed under the same terms as Perl itself.
