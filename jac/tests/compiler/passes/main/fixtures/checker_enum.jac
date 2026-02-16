"""Tests for enum type checking."""
import from enum { IntEnum, IntFlag }

# ============================================================================
# Enum Definitions
# ============================================================================

enum Color {
    RED = 1,
    GREEN = 2,
    BLUE = 3
}

enum Status {
    PENDING = "pending",
    ACTIVE = "active"
}

enum AutoValueTest {
    FIRST,
    SECOND = 10,
    THIRD
}

enum BaseEnum ( IntEnum ) {
    BASE = 100
}

enum DerivedEnum ( BaseEnum ) {
    A = 1,
    B = "jac"  # Error: IntEnum requires int values, got str
}

enum Permission ( IntFlag ) {
    READ = 1,
    WRITE = 2,
    EXECUTE = 4
}

enum ShapeType;
impl ShapeType {
    CIRCLE = "circle",
    SQUARE = "square"
}

# ============================================================================
# Scenario 1: Basic Enum Member Access
# ============================================================================

with entry {
    basic_c: Color = Color.RED;
}

# ============================================================================
# Scenario 2: Enum .name Attribute (should be str)
# ============================================================================

with entry {
    name_ok: str = Color.RED.name;
    name_err: int = Color.RED.name;  # Error: str assigned to int
}

# ============================================================================
# Scenario 3: Enum .value Attribute (type depends on enum values)
# ============================================================================

with entry {
    # Int value enums
    value_ok: int = Color.BLUE.value;
    value_err: str = Color.BLUE.value;  # Error: int assigned to str

    # String value enums
    value_status_ok: str = Status.PENDING.value;
    value_status_val_err: int = Status.ACTIVE.value;  # Error: str assigned to int
}

# ============================================================================
# Scenario 4: Auto-Generated Enum Values
# ============================================================================

with entry {
    auto_val_ok: int = AutoValueTest.FIRST.value;
    auto_val_err: str = AutoValueTest.THIRD.value;  # Error: int assigned to str
}

# ============================================================================
# Scenario 5: IntFlag Bitwise Operations
# ============================================================================

with entry {
    flag_perm: Permission = Permission.READ;
    flag_val: int = flag_perm.value;
    flag_combined: int = Permission.READ.value | Permission.WRITE.value;
}

# ============================================================================
# Scenario 6: Enum with Separate impl Block
# ============================================================================

with entry {
    impl_shape_ok: str = ShapeType.SQUARE.name;
    impl_shape_name_err: int = ShapeType.SQUARE.name;  # Error: str assigned to int
}

# ============================================================================
# Scenario 6: Enum as Function Parameters
# ============================================================================

def process_color(c: Color) -> str {
    return c.name;
}

with entry {
    func_ok: str = process_color(Color.BLUE);
    func_wrong_type: str = process_color("not a color");  # Error: str not Color
}
