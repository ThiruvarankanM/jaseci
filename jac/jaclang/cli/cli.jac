"""Command line interface tool for the Jac language."""
import ast as ast3;
import fnmatch;
import marshal;
import os;
import pickle;
import sys;
import types;
import from importlib.metadata { version as pkg_version }
import from pathlib { Path }
import from jaclang.cli.cmdreg { cmd_registry }

This module provides the main CLI entry point. Command implementations
are in cli/impl/cli.impl.jac, and command registrations are in cli/commands/.
"""

# Import new registry infrastructure
import from jaclang.cli.registry { get_registry }
import from jaclang.cli.executor { get_executor }

@cmd_registry.register(source='jaclang')
def gen_parser -> str;

@cmd_registry.register(source='jaclang')
def format(paths: list, to_screen: bool = False, fix: bool = False) -> None;

def proc_file_sess(filename: str, session: str, <>root: (str | None) = None) -> tuple;

@cmd_registry.register(source='jaclang')
def run(
    filename: str, session: str = '', main: bool = True, cache: bool = True
) -> None;

@cmd_registry.register(source='jaclang')
def get_object(filename: str, id: str, session: str = '', main: bool = True) -> dict;

@cmd_registry.register(source='jaclang')
def build(filename: str, typecheck: bool = False) -> None;

@cmd_registry.register(source='jaclang')
def check(paths: list, print_errs: bool = True, warnonly: bool = False, ignore: list = []) -> None;

@cmd_registry.register(source='jaclang')
def lsp -> None;

@cmd_registry.register(source='jaclang')
def enter(
    filename: str,
    entrypoint: str,
    args: list,
    session: str = '',
    main: bool = True,
    <>root: str = '',
    <>node: str = ''
) -> None;

@cmd_registry.register(source='jaclang')
def <>test(
    filepath: str,
    test_name: str = '',
    filter: str = '',
    xit: bool = False,
    maxfail: int = None,
    directory: str = '',
    verbose: bool = False
) -> None;

@cmd_registry.register(source='jaclang')
def tool(tool: str, args: (list | None) = None) -> None;

@cmd_registry.register(source='jaclang')
def debug(filename: str, main: bool = True, cache: bool = False) -> None;

@cmd_registry.register(source='jaclang')
def dot(
    filename: str,
    session: str = '',
    initial: str = '',
    depth: int = -1,
    traverse: bool = False,
    connection: list[str] = [],
    bfs: bool = False,
    edge_limit: int = 512,
    node_limit: int = 512,
    saveto: str = '',
    to_screen: bool = False,
    format: str = 'dot'
) -> None;

@cmd_registry.register(source='jaclang')
def py2jac(filename: str) -> None;

@cmd_registry.register(source='jaclang')
def jac2py(filename: str) -> None;

@cmd_registry.register(source='jaclang')
def js(filename: str) -> None;

@cmd_registry.register(source='jaclang')
def serve(
    filename: str,
    session: str = '',
    port: int = 8000,
    main: bool = True,
    faux: bool = False
) -> None;

#===============================================================================
# ENTRY POINT
#===============================================================================
def start_cli -> None;

with entry:__main__ {
    start_cli();
}
