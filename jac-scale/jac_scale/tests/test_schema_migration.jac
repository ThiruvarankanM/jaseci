"""Tests for jac_scale.schema_migration — Layer 1: field_alias + deprecated_field."""

import dataclasses;
import from jac_scale.schema_migration {
    field_alias,
    deprecated_field,
    apply_migrations,
    collect_deprecated_fields,
    _auto_register_archetype,
    _field_aliases_registry,
    _deprecated_fields_registry,
    FIELD_ALIAS_KEY,
    FIELD_DEPRECATED_KEY
}

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

"""Create a minimal dataclass with __module__ = 'test_module'."""
def _make_dc(name: str, fields: list[tuple] = []) -> type {
    ns: dict = {'__annotations__': {}};
    for (fname, ftype, fdefault) in fields {
        ns['__annotations__'][fname] = ftype;
        ns[fname] = fdefault;
    }
    cls = type(name, (), ns);
    cls.__module__ = 'test_module';
    return dataclasses.dataclass(cls);
}

def _qn(name: str) -> str {
    return f"test_module.{name}";
}

# ---------------------------------------------------------------------------
# field_alias — metadata
# ---------------------------------------------------------------------------

test "field_alias default value is carried through" {
    f = field_alias("score", default_value=0);
    assert f.default == 0;
    assert f.metadata.get(FIELD_ALIAS_KEY) == "score";
}

test "field_alias default_factory is carried through" {
    f = field_alias("tag", default_factory=list);
    assert f.default_factory is list;
    assert f.metadata.get(FIELD_ALIAS_KEY) == "tag";
}

# ---------------------------------------------------------------------------
# deprecated_field — metadata
# ---------------------------------------------------------------------------

test "deprecated_field returns Field with deprecated metadata" {
    f = deprecated_field(default_value="");
    assert isinstance(f, dataclasses.Field);
    assert f.metadata.get(FIELD_DEPRECATED_KEY) is True;
}

test "deprecated_field default_factory is carried through" {
    f = deprecated_field(default_factory=list);
    assert f.default_factory is list;
    assert f.metadata.get(FIELD_DEPRECATED_KEY) is True;
}

# ---------------------------------------------------------------------------
# Auto-registration hook
# ---------------------------------------------------------------------------

test "auto-hook registers field_alias into aliases registry" {
    cls = _make_dc('AutoAlias', [('name', str, field_alias("username", default_value=""))]);
    _auto_register_archetype(cls);
    aliases = _field_aliases_registry.get(_qn('AutoAlias'), {});
    assert aliases.get('username') == 'name';
    assert 'AutoAlias' not in _field_aliases_registry;  # must use qualified name
}

test "auto-hook registers deprecated_field into deprecated registry" {
    cls = _make_dc('AutoDep', [('old_bio', str, deprecated_field(default_value=""))]);
    _auto_register_archetype(cls);
    dep = _deprecated_fields_registry.get(_qn('AutoDep'), set());
    assert 'old_bio' in dep;
}

test "auto-hook ignores classes with no field_alias or deprecated_field markers" {
    cls = _make_dc('AutoClean', [('x', int, 0)]);
    before_aliases = dict(_field_aliases_registry);
    before_dep = dict(_deprecated_fields_registry);
    _auto_register_archetype(cls);
    assert _qn('AutoClean') not in _field_aliases_registry;
    assert _qn('AutoClean') not in _deprecated_fields_registry;
}

test "auto-hook skips jaclang internal modules" {
    cls = _make_dc('Internal', [('name', str, field_alias("old", default_value=""))]);
    cls.__module__ = 'jaclang.runtimelib.memory';
    before = dict(_field_aliases_registry);
    _auto_register_archetype(cls);
    assert 'jaclang.runtimelib.memory.Internal' not in _field_aliases_registry;
}

# ---------------------------------------------------------------------------
# apply_migrations — field rename
# ---------------------------------------------------------------------------

test "apply_migrations renames old key to new key" {
    cls = _make_dc('MigRename', [('name', str, field_alias("username", default_value=""))]);
    _auto_register_archetype(cls);
    doc = {"username": "alice", "age": 30};
    (result, migrated) = apply_migrations('test_module', 'MigRename', doc);
    assert migrated;
    assert result.get('name') == 'alice';
    assert 'username' not in result;
    assert result.get('age') == 30;
}

test "apply_migrations fast-path returns same object when no aliases registered" {
    cls = _make_dc('MigNoOp', [('x', int, 0)]);
    doc = {"x": 1};
    (result, migrated) = apply_migrations('test_module', 'MigNoOp', doc);
    assert not migrated;
    assert result is doc;
}

test "apply_migrations is idempotent — skips rename if new key already present" {
    cls = _make_dc('MigIdem', [('name', str, field_alias("username", default_value=""))]);
    _auto_register_archetype(cls);
    doc = {"name": "alice", "username": "old"};
    (result, migrated) = apply_migrations('test_module', 'MigIdem', doc);
    assert not migrated;
    assert result['name'] == 'alice';
}

test "apply_migrations handles multiple aliases in one class" {
    cls = _make_dc('MigMulti', [
        ('name', str, field_alias("username", default_value="")),
        ('score', int, field_alias("points", default_value=0))
    ]);
    _auto_register_archetype(cls);
    doc = {"username": "bob", "points": 99};
    (result, migrated) = apply_migrations('test_module', 'MigMulti', doc);
    assert migrated;
    assert result.get('name') == 'bob';
    assert result.get('score') == 99;
}

test "apply_migrations unknown class is a no-op, not an error" {
    doc = {"x": 1};
    (result, migrated) = apply_migrations('nonexistent', 'Ghost', doc);
    assert not migrated;
    assert result is doc;
}

# ---------------------------------------------------------------------------
# collect_deprecated_fields
# ---------------------------------------------------------------------------

test "collect_deprecated_fields from auto-hook registry" {
    cls = _make_dc('DepReg', [
        ('old_bio', str, deprecated_field(default_value="")),
        ('bio', str, "")
    ]);
    _auto_register_archetype(cls);
    result = collect_deprecated_fields(_qn('DepReg'));
    assert 'old_bio' in result;
    assert 'bio' not in result;
}

test "collect_deprecated_fields arch_cls fallback for unregistered class" {
    cls = _make_dc('DepFall', [('old_f', str, deprecated_field(default_value="")), ('name', str, '')]);
    # Do NOT call _auto_register_archetype — test the fallback path.
    result = collect_deprecated_fields(_qn('DepFall'), arch_cls=cls);
    assert 'old_f' in result;
    assert 'name' not in result;
}

# ---------------------------------------------------------------------------
# __init_subclass__ wiring
# ---------------------------------------------------------------------------

test "auto-hook fires automatically via __init_subclass__ for real Archetype subclass" {
    # This test verifies the glob _schema_auto_hook registration is wired correctly.
    # No manual _auto_register_archetype call — the hook must fire on its own.
    import from jaclang.jac0core.archetype { Archetype }

    ns = {
        '__module__': 'myapp.hooktest',  # set before type() so hook sees it on fire
        '__annotations__': {'name': str, 'old_bio': str},
        'name': field_alias("username", default_value=""),
        'old_bio': deprecated_field(default_value="")
    };
    # Subclassing Archetype triggers __init_subclass__ → make_archetype (applies
    # @dataclass) → _subclass_hooks loop → _auto_register_archetype fires.
    cls = type('HookNode', (Archetype,), ns);

    qname = 'myapp.hooktest.HookNode';
    aliases = _field_aliases_registry.get(qname, {});
    dep = _deprecated_fields_registry.get(qname, set());

    assert aliases.get('username') == 'name', f"field_alias not auto-registered (got {aliases})";
    assert 'old_bio' in dep, f"deprecated_field not auto-registered (got {dep})";
}
