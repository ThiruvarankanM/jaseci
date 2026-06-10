"""Schema drift helpers for jac-scale (Layer 1).

Handles two common cases when a Jac archetype changes:

  field_alias("old_name")  — field was renamed. Old documents are fixed on read.
  deprecated_field()       — field is being removed. It is stripped on every write.

No decorators or version numbers needed. jac-scale detects these markers
automatically at startup and applies them transparently.
"""

# Keyed by "module.ClassName" to avoid collisions between same-named classes in different modules.
glob _field_aliases_registry: dict[str, dict[str, str]] = {};     # old_name -> new_name
glob _deprecated_fields_registry: dict[str, set[str]] = {};       # fields being phased out

glob FIELD_ALIAS_KEY: str = '__jac_field_alias__';
glob FIELD_DEPRECATED_KEY: str = '__jac_deprecated__';

# ---------------------------------------------------------------------------
# Field-level helpers (used as default values in `has` declarations)
# ---------------------------------------------------------------------------

"""Declare that a field was renamed. Old documents are fixed on the next read.

Example — `username` in MongoDB is now called `name` in code:
    node User {
        has name: str = field_alias("username", default_value="");
        has tags: list[str] = field_alias("tag", default_factory=list);
    }
"""
def field_alias(
    old_name: str,
    default_value: any = None,
    default_factory: (Callable | None) = None
) -> any;

"""Mark a field that is being removed so old documents don't crash on load.

Keep the `has` declaration while old documents still exist — jac-scale will
strip this field on every write. Once no documents carry it, delete the line.

Example:
    node User {
        has old_bio: str = deprecated_field(default_value="");
        has bio: str = "";
    }
"""
def deprecated_field(
    default_value: any = None,
    default_factory: (Callable | None) = None
) -> any;

# ---------------------------------------------------------------------------
# Runtime helpers — called by MongoBackend
# ---------------------------------------------------------------------------

"""Rename old field keys in a raw archetype dict before the Serializer sees it.

Returns (migrated_dict, was_migrated). When was_migrated=True the caller
writes the fixed document back to MongoDB immediately (read-repair).
Returns the original dict unchanged if no aliases are registered for this class.
"""
def apply_migrations(
    arch_module: str,
    arch_class_name: str,
    arch_dict: dict
) -> tuple[dict, bool];

"""Return all deprecated field names for an archetype class.

Used by _anchor_to_doc to strip deprecated fields before writing to MongoDB.
Passes arch_cls as a fallback for classes that were loaded before the hook ran.
"""
def collect_deprecated_fields(
    qualified_class_name: str,
    arch_cls: (type | None) = None
) -> set[str];
