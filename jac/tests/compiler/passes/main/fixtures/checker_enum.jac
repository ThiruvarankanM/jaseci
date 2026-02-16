"""Tests for enum type checking."""
import from enum { IntEnum, StrEnum, IntFlag }

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
    ACTIVE = "active",
    COMPLETED = "completed"
}

enum Priority {
    LOW,
    MEDIUM,
    HIGH
}

enum Direction {
    NORTH = 0,
    SOUTH = 1,
    EAST = 2,
    WEST = 3
}

enum AutoValueTest {
    FIRST,
    SECOND,
    THIRD = 10,
    FOURTH,
    FIFTH,
    SIXTH = 20,
    SEVENTH
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
    EXECUTE = 4,
    DELETE = 8
}

enum HttpStatus ( IntEnum ) {
    OK = 200,
    ERROR = 500
}

enum ShapeType;
impl ShapeType {
    CIRCLE = "circle",
    SQUARE = "square",
    TRIANGLE = "triangle"
}

# ============================================================================
# Scenario 1: Basic Enum Member Access and Type Assignment
# ============================================================================

with entry {
    basic_c: Color = Color.RED;
    basic_my_color: Color = Color.GREEN;
    basic_dir: Direction = Direction.NORTH;
}

# ============================================================================
# Scenario 2: Enum .name and ._name_ Attributes (should be str)
# ============================================================================

with entry {
    name_ok: str = Color.RED.name;
    name_err: int = Color.RED.name;  # Error: str assigned to int
    
    name2_ok: str = Color.GREEN._name_;
    name2_err: int = Color.GREEN._name_;  # Error: str assigned to int
}

# ============================================================================
# Scenario 3: Enum .value and ._value_ Attributes
# ============================================================================

with entry {
    # Int value enums
    value_ok: int = Color.BLUE.value;
    value_err: str = Color.BLUE.value;  # Error: int assigned to str
    
    value2_ok: int = Color.RED._value_;
    value2_err: str = Color.RED._value_;  # Error: int assigned to str
    
    value_dir_val: int = Direction.NORTH.value;
    
    # String value enums
    value_status_val: str = Status.PENDING.value;
    value_status_val_err: int = Status.ACTIVE.value;  # Error: str assigned to int
}

# ============================================================================
# Scenario 4: Auto-Generated Enum Values
# ============================================================================

with entry {
    auto_first: AutoValueTest = AutoValueTest.FIRST;
    auto_first_val: int = auto_first.value;
    
    auto_third_val: int = AutoValueTest.THIRD.value;
    auto_fourth_val: int = AutoValueTest.FOURTH.value;
    auto_seventh_val: int = AutoValueTest.SEVENTH.value;
    
    auto_val_err: str = AutoValueTest.FIFTH.value;  # Error: int assigned to str
}

# ============================================================================
# Scenario 5: Enum Inheritance (IntEnum)
# ============================================================================

with entry {
    inherit_derived: DerivedEnum = DerivedEnum.A;
    inherit_derived_val: int = inherit_derived.value;
    inherit_derived_val_err: str = DerivedEnum.B.value;
    
    inherit_base: BaseEnum = BaseEnum.BASE;
    inherit_base_val: int = inherit_base.value;
}

# ============================================================================
# Scenario 6: IntFlag Enums (Bitwise Operations)
# ============================================================================

with entry {
    flag_read_perm: Permission = Permission.READ;
    flag_read_val: int = flag_read_perm.value;
    flag_read_write: int = Permission.READ.value | Permission.WRITE.value;
}

# ============================================================================
# Scenario 7: Enum Comparisons and Operations
# ============================================================================

with entry {
    comp_status: HttpStatus = HttpStatus.ERROR;
    comp_is_same: bool = (comp_status == HttpStatus.ERROR);
    comp_status_val: int = comp_status.value;
    comp_is_error: bool = (comp_status.value >= 400);
}

# ============================================================================
# Scenario 8: Enum with Separate impl Block
# ============================================================================

with entry {
    impl_s: ShapeType = ShapeType.CIRCLE;
    
    impl_shape_name: str = ShapeType.SQUARE.name;
    impl_shape_name_err: int = ShapeType.SQUARE.name;  # Error: str assigned to int
    
    impl_shape_val: str = ShapeType.TRIANGLE.value;
    impl_shape_val_err: int = ShapeType.TRIANGLE.value;  # Error: str assigned to int
}

# ============================================================================
# Scenario 9: Enum as Function Parameters and Return Types
# ============================================================================

def process_color(c: Color) -> str {
    return c.name;
}

def get_default_color -> Color {
    return Color.RED;
}

with entry {
    func_result: str = process_color(Color.BLUE);
    func_default_color: Color = get_default_color();
    func_wrong_type: str = process_color("not a color");  # Error: str not Color
}
