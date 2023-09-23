# SPDX-License-Identifier: AGPL-3.0-or-later
"""Command line"""

import click
from . import __pkginfo__


def main():
    """Entry point for the application script"""
    # pylint: disable=import-outside-toplevel, unused-import, cyclic-import
    from . import prj

    cli()


@click.group()
@click.pass_context
@click.option(
    "--debug/--no-debug",
    envvar="DEBUG",
    default=False,
    help="enable debug messages",
    show_default=True,
)
def cli(ctx, debug):
    """command line interface"""
    ctx.obj = object()
    ctx.obj = {
        "version": __pkginfo__.VERSION,
        "debug": debug,
    }


@cli.command()
@click.pass_obj
def version(obj):
    """prompt version info"""
    click.echo(f"version: {obj['version']} / debug: {obj['debug']}")
