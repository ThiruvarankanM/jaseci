"""Implementations for schema_migration.jac.

Layer 1: field_alias + deprecated_field auto-detected via _subclass_hooks.
"""

import dataclasses;
import logging;
import from jaclang.jac0core.archetype { Archetype }

glob _sm_logger = logging.getLogger('jac_scale.schema_migration');

# ---------------------------------------------------------------------------
# Field-level helpers
# ---------------------------------------------------------------------------

impl field_alias(
    old_name: str,
    default_value: any = None,
    default_factory: (Callable | None) = None
) -> any {
    meta = {FIELD_ALIAS_KEY: old_name};
    if default_factory is not None {
        return dataclasses.field(default_factory=default_factory, metadata=meta);
    }
    return dataclasses.field(default=default_value, metadata=meta);
}

impl deprecated_field(
    default_value: any = None,
    default_factory: (Callable | None) = None
) -> any {
    meta = {FIELD_DEPRECATED_KEY: True};
    if default_factory is not None {
        return dataclasses.field(default_factory=default_factory, metadata=meta);
    }
    return dataclasses.field(default=default_value, metadata=meta);
}

# ---------------------------------------------------------------------------
# Auto-registration hook
# ---------------------------------------------------------------------------

"""Scan a newly-defined archetype class for field_alias() and deprecated_field()
markers and populate the registries automatically.

Registered into Archetype._subclass_hooks (same mechanism as Serializer.register)
so it fires for every user-defined archetype at class-load time. No decorator
or extra code is required on the archetype.
"""
def _auto_register_archetype(cls: type) -> None {
    # Skip jaclang internals and jac_scale itself.
    if cls.__module__.startswith('jaclang.') or cls.__module__.startswith('jac_scale.') {
        return;
    }
    dc_fields = getattr(cls, '__dataclass_fields__', {});
    if not dc_fields {
        return;
    }
    qname: str = f"{cls.__module__}.{cls.__name__}";
    extracted_aliases: dict = {};
    extracted_deprecated: set = set();
    for (field_name, fobj) in dc_fields.items() {
        meta = getattr(fobj, 'metadata', None) or {};
        old_name = meta.get(FIELD_ALIAS_KEY);
        if old_name {
            extracted_aliases[old_name] = field_name;
        }
        if meta.get(FIELD_DEPRECATED_KEY) {
            extracted_deprecated.add(field_name);
        }
    }
    if extracted_aliases {
        existing = _field_aliases_registry.get(qname, {});
        _field_aliases_registry[qname] = {**existing, **extracted_aliases};
    }
    if extracted_deprecated {
        existing_dep = _deprecated_fields_registry.get(qname, set());
        _deprecated_fields_registry[qname] = existing_dep | extracted_deprecated;
    }
}

# Registered the same way Serializer.register is — fires automatically for
# every user-defined archetype at class-load time, zero developer action needed.
glob _schema_auto_hook = Archetype._subclass_hooks.append(_auto_register_archetype);

# ---------------------------------------------------------------------------
# Runtime helpers
# ---------------------------------------------------------------------------

def _scan_deprecated(cls: type) -> set[str] {
    found: set[str] = set();
    dc_fields = getattr(cls, '__dataclass_fields__', {});
    for (fname, fobj) in dc_fields.items() {
        meta = getattr(fobj, 'metadata', None) or {};
        if meta.get(FIELD_DEPRECATED_KEY) {
            found.add(fname);
        }
    }
    return found;
}

impl collect_deprecated_fields(
    qualified_class_name: str,
    arch_cls: (type | None) = None
) -> set[str] {
    result: set[str] = set(_deprecated_fields_registry.get(qualified_class_name, set()));
    if arch_cls is not None {
        result |= _scan_deprecated(arch_cls);
    }
    return result;
}

impl apply_migrations(
    arch_module: str,
    arch_class_name: str,
    arch_dict: dict
) -> tuple[dict, bool] {
    qname: str = f"{arch_module}.{arch_class_name}";

    # Fast path: no aliases registered for this class — nothing to rename.
    if qname not in _field_aliases_registry {
        return (arch_dict, False);
    }

    working: dict = dict(arch_dict);
    was_migrated: bool = False;

    class_aliases: dict = _field_aliases_registry.get(qname, {});
    for (old_key, new_key) in class_aliases.items() {
        if old_key in working and new_key not in working {
            working[new_key] = working.pop(old_key);
            was_migrated = True;
            _sm_logger.debug(
                f"schema_migration [{qname}]: renamed '{old_key}' → '{new_key}'"
            );
        }
    }

    if not was_migrated {
        return (arch_dict, False);
    }
    return (working, True);
}
