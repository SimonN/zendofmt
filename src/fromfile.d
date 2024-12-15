module zendofmt.fromfile;

import std.algorithm;
import std.conv;
import std.exception;
import std.range;
import std.stdio : File, lines;
import std.string;

import zendofmt.koan;
import zendofmt.table;

class KoansFromFile {
private:
    immutable(Koan)[] raw_koans; // not yet formatted

public:
    this(string fn)
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
        raw_koans = alreadyReadFromFile
            .sort
            .uniq!(Koan.predicateForUniq)
            .array
            .assumeUnique;
    }

    int numKoans() const pure nothrow @safe @nogc
    {
        return raw_koans.length & 0x7FFF_FFFF;
    }

    string asFormattedWithTitle(in string title)
    {
        if (raw_koans.length == 0) {
            return text(title, "\n[i]no koans[/i]");
        }
        return text(
            title, "[tt]\n",
            theBestLayout().asFormatted,
            "[/tt]");
    }

private:
    Layout theBestLayout()
    {
        Layout one = new AllInOne(raw_koans, 10);
        if (one.heedsIdealSize) {
            return one;
        }
        Layout twoA = new TwoTables(raw_koans, 10, 16); // Nice narrow columns
        Layout twoB = new TwoTables(raw_koans, 10, 26);
        return one.vertSize < twoA.vertSize && one.vertSize < twoB.vertSize
            ? one
            : twoB.vertSize < twoA.vertSize
            ? twoB : twoA;
    }
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
