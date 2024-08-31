# Foo Bar

TODO

## Installation

You can install the package using `pipx`
```bash
pipx install git+https://github.com/misterio77/foo-bar
```

Alternatively, use pip with `--user`:
```bash
pip install --user git+https://github.com/misterio77/foo-bar
```

Or use nix:
```bash
nix shell github:misterio77/foo-bar
```

## Usage

TODO

## Hacking

Use [poetry](https://python-poetry.org/), like so:

```bash
poetry install
poetry shell
```

Or use nix:
```bash
nix develop -c $SHELL
```

You can then use `python -m` to run it, as well as all the usual dev tools:

```bash
python -m foo_bar # Run

mypy # Type check
ruff check # Lint
ruff format # Format
pytest # Run tests
```

Python LSP will also be available. Check your editor docs on how to enable it.
