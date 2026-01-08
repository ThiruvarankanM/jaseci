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

# Import commands module to trigger auto-registration
import from jaclang.cli {
    commands
}

#===============================================================================
# ENTRY POINT
#===============================================================================
def start_cli -> None;

with entry:__main__ {
    start_cli();
}
