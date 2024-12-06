module zendofmt.table;

import std.algorithm;
import std.conv;
import std.math;
import std.range;
import std.stdio : File, lines;
import std.string;

import zendofmt.column;
import zendofmt.koan;

class KoanTable {
private:
    Koan[] raw_koans; // not yet formatted

    immutable minSpacingBetweenKoans = 2;
    immutable maxCharactersPerLine = 80;

    // Up to this, prefer a long vertical list instead of many rows.
    enum int niceColumnLengthBeforeMakingMultipleColumns = 10;

public:
    this(string fn)
    {
        auto f = File(fn, "r");
        bool weHaveSeenANewline = false;

        foreach (string line; f.lines) {
            string s = line.strip();
            if (s.length == 0) {
                weHaveSeenANewline = true;
                foreach (ref koan; raw_koans.retro) {
                    if (koan.isNew)
                        koan.isNew = false;
                    else
                        break;
                }
            }
            else {
                raw_koans ~= Koan(line.strip(), weHaveSeenANewline);
            }
        }
        raw_koans = raw_koans
            .sort
            .uniq!(Koan.predicateForUniq)
            .array;
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
        auto ret = text(title, "[tt]\n");
        Column[] columns = columnize();

        /*
         * Columns collect the koans column-wise; each column contains
         * alphabetically successive koans (slices of the table's koan list).
         *
         * But we output row-wise.
         */
        for (int row = 0; row < columns[0].numKoans; ++row) {
            foreach (size_t j, col; columns) {
                if (row >= col.numKoans) {
                    continue;
                }
                immutable koan = col.koans[row];
                immutable bool isLastInItsRow
                    =  (j + 1 == columns.length)
                    || (j + 2 == columns.length
                        && row >= columns[$-1].numKoans);

                immutable numSpacesOfPaddingAfterTheKoan
                    = isLastInItsRow ? 0
                    : col.textWidth + minSpacingBetweenKoans - koan.textLen;

                ret ~= text(
                    koan.asFormatted,
                    ' '.repeat(numSpacesOfPaddingAfterTheKoan),
                    isLastInItsRow ? "\n" : "");
            }
        }
        ret ~= "[/tt]";
        return ret;
    }

private:
    /*
     * Returns an array of columns. A column contains a slice of our koans,
     * i.e., some alphabetically successive koans.
     *
     * 0 3 6    Therefore, the _rows_ don't contain successive koans.
     * 1 4      The rightmost column may have fewer entries than others.
     * 2 5
     */
    Column[] columnize() const pure nothrow @safe
    {
        if (! raw_koans.length)
            return null;

        for (int vertSize = bestVertSizeIfWeHadInfiniteWidth(); ; ++vertSize) {
            Column[] ret = columnizeForVertSize(vertSize);
            if (ret.map!(col => col.textWidth).sum < maxCharactersPerLine) {
                // These columns are finally narrow enough (horizontally).
                return ret;
            }
            if (ret.length == 1) {
                /*
                 * This output will be too wide horizontally, but we're
                 * already printing everything into a single long column.
                 * We can't improve that; accept it.
                 */
                return ret;
            }
        }
    }

    int bestVertSizeIfWeHadInfiniteWidth() const pure nothrow @safe @nogc
    {
        for (int numColumns = 1; ; ++numColumns) {
            immutable vertSize = (numKoans + (numColumns - 1)) / numColumns;
            if (vertSize <= niceColumnLengthBeforeMakingMultipleColumns) {
                return vertSize;
            }
        }
    }

    Column[] columnizeForVertSize(in int vertSize) const pure nothrow @safe
    in { assert (vertSize >= 1); }
    do {
        Column[] ret;
        ret.length = (raw_koans.length + vertSize - 1) / vertSize;
        columnizeInto(ret, vertSize);
        return ret;
    }

    void columnizeInto(
        Column[] output,
        in int vertSize) const pure nothrow @safe @nogc
    {
        if (output.length == 0) {
            return;
        }
        foreach (size_t col; 0 .. output.length - 1) {
            output[col].koans = raw_koans[vertSize * col
                                       .. vertSize * (col + 1)];
        }
        output[$-1].koans = raw_koans[vertSize * (output.length - 1) .. $];
    }
}
