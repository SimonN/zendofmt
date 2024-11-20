module zendofmt.footer;

import std.algorithm;
static import std.file;
import std.string;

class Footer {
private:
    bool _exists;
    string _output;

public:
    /*
     * Throws:
     * this(fn) may throw on bad UTF-8 in the file with filename (fn).
     */
    this(string fn)
    {
        if (! std.file.exists(fn) || ! std.file.isFile(fn)) {
            return;
        }
        string raw = std.file.readText(fn).strip;
        _output = exchangeBackticksForTT(raw);
    }

    const pure nothrow @safe @nogc {
        bool exists() { return _output.length >= 1; }
        string asFormatted() { return _output; }
    }

private:
    static string exchangeBackticksForTT(in string src)
    {
        if (! src.canFind('`')) {
            return src;
        }
        string remainder = src;
        bool weAreInTT = false;
        string ret;
        while (true) {
            immutable(char)* start = remainder.ptr;
            immutable string tail = remainder.find('`');
            ret ~= remainder[0 .. $ - tail.length];
            if (tail.length == 0) {
                break;
            }
            assert (tail[0] == '`');
            ret ~= weAreInTT ? "[/tt]" : "[tt]";
            weAreInTT = ! weAreInTT;
            remainder = tail[1 .. $];
        }
        if (weAreInTT) {
            ret ~= "[/tt]";
        }
        return ret;
    }
}

unittest {
    void myTest(in string src, in string expected)
    {
        auto exchanged = Footer.exchangeBackticksForTT(src);
        assert (exchanged == expected,
            "\n" ~ src ~ "\n" ~ exchanged ~ "\n" ~ expected);
    }
    myTest(
        "Hello `World`! I'm for`m`atting.",
        "Hello [tt]World[/tt]! I'm for[tt]m[/tt]atting.");
    myTest(
        "Unmatched `backtick` gets `terminated.",
        "Unmatched [tt]backtick[/tt] gets [tt]terminated.[/tt]");
}
