"""Find prose blocks over a word ceiling: docstrings, `comment=` strings and comment runs.

Run it for the worklist: `python prose_ceiling.py [root] --exclude db/generated`.
"""

from __future__ import annotations

import argparse
import ast
import io
import os
import sys
import tokenize
from collections.abc import Iterable, Iterator
from dataclasses import dataclass
from itertools import islice, pairwise
from pathlib import Path

CEILING = 50
"""Words per block. A one-line summary and a trap sentence fit; an argument does not."""

DIRECTIVE_PREFIXES = (
    "!",
    "cspell:",
    "fmt:",
    "noqa",
    "pyright:",
    "ruff:",
    "shellcheck",
    "type:",
    "vale ",
    "yaml-language-server:",
)
"""Lines a tool reads, from a shebang to a lint directive, counted as no words."""

HASH_SUFFIXES = frozenset({".ps1", ".py", ".sh", ".toml", ".yaml", ".yml", ".zsh"})
HASH_NAMES = frozenset({"Justfile", "justfile"})
SEMICOLON_SUFFIXES = frozenset({".ini"})
DEFAULT_EXCLUDED = (".git", ".venv", "node_modules", "tmp")


@dataclass(frozen=True)
class Block:
    """One run of prose, located by the line it starts on."""

    path: Path
    line: int
    kind: str
    words: int


def word_count(text: str) -> int:
    return len(text.split())


def string_value(node: ast.stmt) -> str | None:
    if not isinstance(node, ast.Expr):
        return None
    constant = node.value
    if isinstance(constant, ast.Constant) and isinstance(constant.value, str):
        return constant.value
    return None


def grouped_comment_blocks(
    path: Path, comment_lines: Iterable[tuple[int, str]], marker: str
) -> Iterator[Block]:
    """Consecutive comment lines form one block."""
    start: int | None = None
    words = 0
    previous: int | None = None
    for number, text in comment_lines:
        if start is not None and previous is not None and number != previous + 1:
            yield Block(path, start, "comment block", words)
            start, words = None, 0
        if start is None:
            start = number
        body = text.lstrip(marker).strip()
        if not body.startswith(DIRECTIVE_PREFIXES):
            words += word_count(body)
        previous = number
    if start is not None:
        yield Block(path, start, "comment block", words)


def python_blocks(path: Path, source: str) -> Iterator[Block]:
    tree = ast.parse(source)
    for node in ast.walk(tree):
        if isinstance(node, (ast.Module, ast.ClassDef, ast.FunctionDef, ast.AsyncFunctionDef)):
            docstring = ast.get_docstring(node, clean=True)
            if docstring is not None:
                yield Block(path, node.body[0].lineno, "docstring", word_count(docstring))
        if isinstance(node, (ast.Module, ast.ClassDef)):
            for previous, current in pairwise(node.body):
                text = string_value(current)
                if isinstance(previous, (ast.Assign, ast.AnnAssign)) and text is not None:
                    yield Block(path, current.lineno, "attribute docstring", word_count(text))
        if isinstance(node, ast.Call):
            for keyword in node.keywords:
                value = keyword.value
                if (
                    keyword.arg == "comment"
                    and isinstance(value, ast.Constant)
                    and isinstance(value.value, str)
                ):
                    yield Block(path, value.lineno, "comment= string", word_count(value.value))
    tokens = tokenize.generate_tokens(io.StringIO(source).readline)
    comment_lines = [
        (token.start[0], token.string) for token in tokens if token.type == tokenize.COMMENT
    ]
    yield from grouped_comment_blocks(path, comment_lines, "#")


def hash_blocks(path: Path, source: str, marker: str = "#") -> Iterator[Block]:
    comment_lines = [
        (number, line.strip())
        for number, line in enumerate(source.splitlines(), start=1)
        if line.strip().startswith(marker)
    ]
    yield from grouped_comment_blocks(path, comment_lines, marker)


def source_files(root: Path, excluded: Iterable[str]) -> Iterator[Path]:
    """Every file with a `#` comment syntax, skipping excluded directories without descending."""
    excluded_paths = {root / entry for entry in excluded}
    for directory, subdirectories, filenames in os.walk(root):
        current = Path(directory)
        subdirectories[:] = sorted(
            name for name in subdirectories if current / name not in excluded_paths
        )
        for filename in sorted(filenames):
            path = current / filename
            is_source = (
                path.suffix in HASH_SUFFIXES
                or path.suffix in SEMICOLON_SUFFIXES
                or path.name in HASH_NAMES
            )
            if is_source and path not in excluded_paths:
                yield path


def blocks_in(root: Path, excluded: Iterable[str] = DEFAULT_EXCLUDED) -> Iterator[Block]:
    for path in source_files(root, excluded):
        source = path.read_text(encoding="utf-8")
        if path.suffix == ".py":
            yield from python_blocks(path, source)
        else:
            marker = ";" if path.suffix in SEMICOLON_SUFFIXES else "#"
            yield from hash_blocks(path, source, marker)


def over_ceiling(
    root: Path, excluded: Iterable[str] = DEFAULT_EXCLUDED, ceiling: int = CEILING
) -> list[Block]:
    """Blocks over the ceiling, longest first."""
    return sorted(
        (block for block in blocks_in(root, excluded) if block.words > ceiling),
        key=lambda block: (-block.words, str(block.path), block.line),
    )


def describe(block: Block, root: Path) -> str:
    return f"{block.path.relative_to(root)}:{block.line}  {block.words} words  {block.kind}"


def worklist(blocks: Iterable[Block], root: Path, limit: int = 20) -> str:
    """The first `limit` blocks, one per line."""
    return "\n".join(describe(block, root) for block in islice(blocks, limit))


def ratchet_message(over: list[Block], known: int, root: Path) -> str:
    """Lower the ratchet after a cut; shorten a block after a rise."""
    if len(over) < known:
        return f"{known - len(over)} blocks cut; lower the ratchet to {len(over)}."
    return (
        f"{len(over) - known} new blocks over {CEILING} words; shorten one. The longest:\n"
        f"{worklist(over, root)}"
    )


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("root", nargs="?", default=".", type=Path)
    parser.add_argument("--exclude", action="append", default=[])
    parser.add_argument("--ceiling", type=int, default=CEILING)
    arguments = parser.parse_args(argv)
    root = arguments.root.resolve()
    blocks = over_ceiling(root, [*DEFAULT_EXCLUDED, *arguments.exclude], arguments.ceiling)
    for block in blocks:
        print(describe(block, root))
    print(f"{len(blocks)} blocks over {arguments.ceiling} words")
    return 1 if blocks else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
