obj Name {
    has first_name: str,
        last_name: str;
}

obj Person {
    has name: Name;

    def init {  #No parameters
        self.nickname = "NoNick";
    }
}

glob a = Person(name=Name(first_name="Bob", last_name="Brown")),
     b = Person('Jac'),
     c = Person();
# Error: named arg to parameterless init
# Error: positional arg to parameterless init
# OK: no arguments
