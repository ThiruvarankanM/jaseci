# Simple cases - basic attribute validation
obj SomeObj1 {
    has a: int by postinit;

    def postinit -> None;
}

impl SomeObj1.postinit{
    self.a = self.b + 5;  # Error: 'b' not declared with 'has' (right side)
    self.a.res = 10;  # Error: 'res' not an attribute of 'int'
}

# Nested objects for complex tests
obj City {
    has name: str;
    has population: int;
}

obj Country {
    has name: str;
    has capital: City;
}

obj Location {
    has country: Country;
}

# Hardest case: Deep nesting (self.x.y.z.w)
obj Company {
    has location: Location;

    def setup {
        self.location.country.name = "USA";  # Valid: all attributes declared
        self.location.country.capital.name = "DC";  # Valid: no validation for x.attribute
        self.location.country.capital.population = 700000;  # Valid: all attributes declared
        self.location.country.code = "US";  # Error: 'code' not declared in Country
        self.location.country.capital.region = "East";  # Error: 'region' not declared in City
        self.missing_attr = "test";  # Error: 'missing_attr' not declared in Company
    }

}

# Inheritance case - Dynamic inheritance limitation
obj Game {
    has attempts: int;
}

with entry {
    x = Game;
    y = x;
}

obj GuessGame(y) {
    def play {
        self.attempts = 10;
        self.player = "John";
        self.a.b = 5;  # Error: 'a' not declared in GuessGame or Game
    }
}
