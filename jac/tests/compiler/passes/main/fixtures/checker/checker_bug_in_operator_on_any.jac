"""Bug #ANY-IN-1: `x in any_value` rejected with false E1111.

Per PEP 484, `Any` supports all operations including `__contains__`.
mypy and Pyright accept this; Jac was rejecting it because the
CompareExpr handler used `TypeBase.is_any_type()` (category-only check)
instead of `TypeEvaluator.is_any_type()` (which matches the prefetched
typing.Any class).

Expected: 0 errors.
"""

def check(x: any) -> bool {
    return "key" in x;
}
