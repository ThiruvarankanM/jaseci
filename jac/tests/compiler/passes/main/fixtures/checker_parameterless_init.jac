obj Name {
    has first_name: str;
    has last_name: str;
}

obj Person {
    has name: Name;

    def init {  # No parameters
        self.nickname = "NoNick";
    }
}

with entry {
    a = Person(name=Name(first_name="Bob", last_name="Brown"));  # Error: named arg to parameterless init
    b = Person('Jac');  # Error: positional arg to parameterless init
    c = Person();  # OK: no arguments
}
