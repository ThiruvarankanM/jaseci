obj Person {
    has x: int = 0,
        y: int = 0;
    
    can set_values with entry {
        # Multiple assignment with self attributes
        self.x = self.y = 10;
    }
}

with entry {
    p = Person();
    p.set_values();
    print(p.x, p.y);
}
