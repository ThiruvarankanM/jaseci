"""Covers two import resolution fixes:
- MyClass: resolved via star re-export chain (from .mymod import *)
- subpkg: resolved as ModuleType for a sub-package __init__.py
"""
import from py_pkg_imports { MyClass, subpkg }
