"""Covers two import resolution fixes:
- MyClass: resolved via star re-export chain (from .mymod import *)
- subpkg: resolved as ModuleType for a sub-package __init__.py
"""
import from py_pkg_imports { MyClass, subpkg }

with entry {
    obj = MyClass(42);
    greeting: str = obj.greet();  # OK: greet() -> str

    inner = subpkg.InnerClass(1);  # OK: subpkg is ModuleType with InnerClass
    v: int = inner.val;            # OK: val is int
}
