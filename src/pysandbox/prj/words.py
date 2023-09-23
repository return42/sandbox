# SPDX-License-Identifier: AGPL-3.0-or-later
"""Print words from ``words.dat``"""

from pathlib import Path
import click
from ._cli import prj

WORDS_DAT = Path(__file__).resolve().parent / "words.dat"


@prj.command()
def words():
    """clear terminal and print words"""
    click.clear()
    i = 1
    with WORDS_DAT.open() as f:
        for line in f:
            click.secho(f"{i}. {line}", fg="bright_green", bg="bright_black", nl=False)
            i += 1
    click.echo()
