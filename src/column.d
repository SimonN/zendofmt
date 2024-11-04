module zendofmt.column;

import std.algorithm;

import zendofmt.koan;

struct Column {
    Koan[] koans;
    bool last_full;

    int numKoans() const pure nothrow @safe @nogc
    {
        return koans.length & 0x7FFF_FFFF;
    }

    int textLen() const pure nothrow @safe @nogc
    {
        return koans.map!(k => k.textLen).fold!max(0);
    }
}

unittest {
    Column c;
    c.koans ~= Koan("HI");
    c.koans ~= Koan("HELLO");
    c.koans ~= Koan("FOO");
    assert (c.textLen == Koan("HELLO").textLen);
}
