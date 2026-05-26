"""Forward-ref strings in Union/Optional should resolve as type names, not Literal[...]."""

import from typing { Union, Optional }

obj Foo {}
obj Bar {}

# Original case: Union with tuple of strings
glob TupleType = Union[('Foo', 'Bar')];

def make_tuple -> TupleType {
    return Foo();
}

# Single-arg Union with string forward ref
glob UniType = Union['Foo'];

def make_uni -> UniType {
    return Foo();
}

# Optional with string forward ref
glob OptType = Optional['Foo'];

def make_opt -> OptType {
    return Foo();
}

# Mixed: string forward ref + direct type in tuple
glob MixedType = Union[('Foo', Bar)];

def make_mixed -> MixedType {
    return Foo();
}

# Negative: true string literals stay as Literal (not resolved as types)
glob LitType = Union[('red', 'green')];
