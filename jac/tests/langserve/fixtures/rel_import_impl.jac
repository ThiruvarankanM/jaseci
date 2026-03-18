"""Fixture: tests relative import visibility in impl files.

MyServer is imported via a relative import here.
The impl file uses MyServer without re-importing it.
"""

import from .rel_import_server { MyServer }

"""Run the server."""
def run_lang_server -> None;
