module zendofmt.column;

import std.algorithm;

import zendofmt.koan;

struct Column {
    immutable(Koan)[] koans;

    int numKoans() const pure nothrow @safe @nogc
    {
        return koans.length & 0x7FFF_FFFF;
    }

    int textWidth() const pure nothrow @safe @nogc
    {
        return koans.map!(k => k.textLen).fold!max(0);
    }
}

unittest {
    Column c;
    c.koans ~= Koan("HI");
    c.koans ~= Koan("HELLO");
    c.koans ~= Koan("FOO");
    assert (c.textWidth == Koan("HELLO").textLen);
}
