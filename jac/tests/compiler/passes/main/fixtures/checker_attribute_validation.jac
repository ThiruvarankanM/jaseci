# Simple cases - basic attribute validation
obj SomeObj1 {
    has a: int = 5;
    def postinit -> None;
}

impl SomeObj1.postinit {
    self.b = self.a * 3;  # Error: 'b' not declared with 'has'
    self.a.res = 10;       # Error: 'real' not an attribute of 'int'
}

obj Person1 {
    has greet_msg: str = "";
    def greet {
        self.greet_msg = "hi";  # Valid: greet_msg is declared
        self.invalid = "test";  # Error: 'invalid' not declared with 'has'
    }
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
    has employee_count: int by postinit;

    def setup {
        self.location.country.name = "USA";                   # Valid: all attributes declared
        self.location.country.capital.name = "DC";            # Valid: no validation for x.attribute
        self.location.country.capital.population = 700000;    # Valid: all attributes declared
        self.location.country.code = "US";                    # Error: 'code' not declared in Country
        self.location.country.capital.region = "East";        # Error: 'region' not declared in City
        self.missing_attr = "test";                           # Error: 'missing_attr' not declared in Company
    }

    def postinit -> None;
}

impl Company.postinit {
    y=self;                             
    y.location.country.name = "Canada";                  
    self.invalid_postinit = "fail";
}

# Inheritance case - Dynamic inheritance limitation
obj Game {
    has attempts: int;
}

with entry {
    x = Game;
    y=x;
}

obj GuessGame(y) {
    def play {
        self.attempts = 10;   
        self.player = "John"; 
    }
}
