module zendofmt.koan;

struct Koan {
    string text;
    bool isNew = false; // new koans will show in bold

    this(string s, bool b = false) pure nothrow @safe @nogc
    {
        text = s;
        isNew = b;
    }

    int opCmp(ref const Koan rhs) const pure nothrow @safe @nogc
    {
        return text < rhs.text ? -1 : text > rhs.text ? 1 : 0;
    }

    int textLen() const pure nothrow @safe @nogc
    {
        return (text.length & 0x0FFF_FFFF) + 2;
    }

    string asFormatted() const pure nothrow @safe
    {
        return (isNew ? "* " : "  ") ~ text;
    }
}

unittest {
    import std.algorithm;

    const koans = [
        Koan("A", true),
        Koan("AA", false),
        Koan("AB", true),
        Koan("BA", false),
        Koan("C"),
        Koan("CA"),
    ];
    assert (koans.isSorted);
}
