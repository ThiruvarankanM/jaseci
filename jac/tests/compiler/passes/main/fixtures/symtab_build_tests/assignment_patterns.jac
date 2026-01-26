with entry {
    d: dict = {};
    [a2, b2, (c2, d["e"], [f2, g2])] = [1, 2, (3, 4, [5, 6])];

    obj Person {
        has name: str = "";
        has age: int = 0;
    }
    
    # Attribute assignment
    person = Person();
    person.name = "Jason";
    # Index/subscript assignment (covers both list[0] and dict['key'])
    items: list = [0, 0, 0];
    items[0] = 42;
    
    # Chained attribute access (complex expression)
    obj Container {
        has nested: Person;
    }
    container = Container(nested=Person());
    container.nested.name = "Jason Mars"; 
}
