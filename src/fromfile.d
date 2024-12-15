module zendofmt.fromfile;

import std.algorithm;
import std.conv;
import std.exception;
import std.range;
import std.stdio : File, lines;
import std.string;

import zendofmt.koan;
import zendofmt.table;

string formatKoansFromFile(in string fn, in string title)
{
    const koans = parseKoansFromFile(fn);
    const layout = theBestLayoutFor(koans);
    return layout.asFormattedWithTitle(title);
}

private:

immutable(Koan)[] parseKoansFromFile(in string fn)
{
    auto f = File(fn, "r");
    bool weHaveSeenANewline = false;
    Koan[] alreadyReadFromFile;

    foreach (string line; f.lines) {
        string s = line.strip();
        if (s.length == 0) {
            weHaveSeenANewline = true;
            foreach (ref koan; alreadyReadFromFile.retro) {
                if (koan.isNew)
                    koan.isNew = false;
                else
                    break;
            }
        }
        else {
            alreadyReadFromFile ~= Koan(line.strip(), weHaveSeenANewline);
        }
    }
    return alreadyReadFromFile
        .sort
        .uniq!(Koan.predicateForUniq)
        .array
        .assumeUnique;
}

Layout theBestLayoutFor(immutable(Koan)[] rawKoans)
{
    Layout one = new AllInOne(rawKoans, 10);
    if (one.heedsIdealSize) {
        return one;
    }
    Layout twoA = new TwoTables(rawKoans, 10, 16); // Nice narrow columns
    Layout twoB = new TwoTables(rawKoans, 10, 26);
    return one.vertSize < twoA.vertSize && one.vertSize < twoB.vertSize
        ? one
        : twoB.vertSize < twoA.vertSize
        ? twoB : twoA;
}

abstract class Layout {
private:
    immutable(KoanTable)[] _tables;
    immutable int _idealVertSize;

protected:
    this(
        immutable(KoanTable)[] readilyPartitionedTablesToFormat,
        in int idealVertSize,
    ) {
        _tables = readilyPartitionedTablesToFormat;
        _idealVertSize = idealVertSize;
    }

public:
final:
    int vertSize() const pure nothrow @safe @nogc
    {
        return _tables.map!(t => t.vertSize).sum;
    }

    int numColumns() const pure nothrow @safe @nogc
    {
        return _tables.map!(t => t.numColumns).fold!max(0);
    }

    bool heedsIdealSize() const pure nothrow @safe @nogc
    {
        return vertSize <= _idealVertSize;
    }

    string asFormatted() const pure @safe
    {
        string ret;
        foreach (table; _tables) {
            ret ~= table.asFormatted;
        }
        return ret;
    }

    string asFormattedWithTitle(in string title) const pure @safe
    {
        if (numColumns == 0) {
            return text(title, "\n[i]no koans[/i]");
        }
        return text(title, "[tt]\n", asFormatted, "[/tt]");
    }
}

class AllInOne : Layout {
public:
    this(immutable(Koan)[] rawKoans, in int idealVertSize)
    {
        super(
            [new KoanTable(rawKoans, idealVertSize)].assumeUnique,
            idealVertSize);
    }
}

class TwoTables : Layout {
public:
    this(
        immutable(Koan)[] rawKoans,
        in int idealVertSize,
        in int minLengthForSecondTable,
    ) {
        bool isShort(in Koan k) pure nothrow @safe @nogc
        {
            return k.textLen < minLengthForSecondTable;
        }
        immutable(Koan)[] shortKs = rawKoans.filter!(k => isShort(k)).array;
        immutable(Koan)[] longKs = rawKoans.filter!(k => ! isShort(k)).array;
        super([
                new KoanTable(shortKs, idealVertSize),
                new KoanTable(longKs, 1),
            ].assumeUnique,
            idealVertSize);
    }
}
