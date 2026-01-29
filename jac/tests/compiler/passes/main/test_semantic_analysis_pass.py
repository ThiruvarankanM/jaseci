
import os
from jaclang.pycore.program import JacProgram


def fixture_path(filename: str) -> str:
    """Get path to a fixture file in semantic_analysis_tests directory."""
    return os.path.join(
        os.path.dirname(__file__),
        "fixtures",
        "semantic_analysis_tests",
        filename,
    )


def test_undeclared_attributes() -> None:
    """Test detection of undeclared attributes with nesting and inheritance."""
    prog = JacProgram()
    prog.compile(fixture_path("attribute_validation.jac"))
    
    errors = [str(e) for e in prog.errors_had if "not declared with 'has'" in str(e)]
    assert len(errors) == 7
    
    # Undeclared attributes should error
    for attr in ["b", "invalid", "code", "region", "missing_attr", "invalid_postinit", "player"]:
        assert any(f"Attribute '{attr}' not declared" in e for e in errors)
    
