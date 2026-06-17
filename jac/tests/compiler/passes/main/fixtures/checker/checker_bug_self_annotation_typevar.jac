# Bug #SELF-ANNO-TVAR: typeshed pins generic-class TypeVars via overloaded
# constructors that annotate self (e.g. `self: TemporaryDirectory[str]`).
# That binding must propagate so `__enter__() -> AnyStr` resolves to `str`
# instead of falling back to Any.

import tempfile;


def takes_str(s: str) {
    print(s);
}


def go {
    # No type arg given. Matched overload is
    #     def __init__(self: TemporaryDirectory[str], ...) -> None
    # so AnyStr must bind to str, making __enter__() return str.
    td = tempfile.TemporaryDirectory();
    takes_str(td.__enter__());

    # Same binding survives `with ... as` desugaring.
    with tempfile.TemporaryDirectory() as p {
        takes_str(p);
    }
}
