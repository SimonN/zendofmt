module zendofmt.table;

import std.algorithm;
import std.conv;
import std.exception;
import std.range;

import zendofmt.column;
import zendofmt.koan;

class KoanTable {
private:
    enum minSpacingBetweenKoans = 2;
    enum maxCharactersPerLine = 80;

    immutable(Koan)[] _rawKoans;
    immutable(Column)[] _columns;

public:
    this(immutable(Koan)[] toPrint, in int idealVertSize)
    {
        _rawKoans = toPrint;
        _columns = columnize(toPrint, idealVertSize);
    }

    int numKoans() const pure nothrow @safe @nogc
    {
        return _rawKoans.length & 0x7FFF_FFFF;
    }

    int numColumns() const pure nothrow @safe @nogc
    {
        return _columns.length & 0x7FFF_FFFF;
    }

    int vertSize() const pure nothrow @safe @nogc
    {
        return _columns.empty ? 0 : _columns[0].numKoans;
    }

    /*
     * We expect that our caller has opened a [tt] tag.
     * We'll print preformatted output for such a tag.
     * We expect that our caller will close the [tt] tag after us.
     */
    string asFormatted() const pure @safe
    {
        if (_columns.empty) {
            return "";
        }
        string ret;
        /*
         * Columns collect the koans column-wise; each column contains
         * alphabetically successive koans (slices of the table's koan list).
         *
         * But we output row-wise.
         */
        for (int row = 0; row < _columns[0].numKoans; ++row) {
            foreach (size_t j, col; _columns) {
                if (row >= col.numKoans) {
                    continue;
                }
                immutable koan = col.koans[row];
                immutable bool isLastInItsRow
                    =  (j + 1 == numColumns)
                    || (j + 2 == numColumns && row >= _columns[$-1].numKoans);

                immutable numSpacesOfPaddingAfterTheKoan
                    = isLastInItsRow ? 0
                    : col.textWidth + minSpacingBetweenKoans - koan.textLen;

                ret ~= text(
                    koan.asFormatted,
                    ' '.repeat(numSpacesOfPaddingAfterTheKoan),
                    isLastInItsRow ? "\n" : "");
            }
        }
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
    immutable(Column)[] columnize(
        immutable(Koan)[] raw_koans,
        in int idealVertSize,
    ) const pure nothrow @safe
    {
        if (numKoans == 0)
            return null;

        for (int vertSize = bestVertSizeIfWeHadInfiniteWidth(idealVertSize);
            ; ++vertSize)
        {
            immutable(Column)[] ret = columnizeForVertSize(vertSize);
            if (isNarrowEnough(ret)) {
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

    static bool isNarrowEnough(in Column[] cols) pure nothrow @safe @nogc
    {
        if (cols.length == 0) {
            return true;
        }
        immutable widthWithoutSpacing = cols.map!(col => col.textWidth).sum;
        immutable withWithSpacing = widthWithoutSpacing
            + (cols.length - 1) * minSpacingBetweenKoans;
        return withWithSpacing < maxCharactersPerLine;
    }

    int bestVertSizeIfWeHadInfiniteWidth(
        in int idealVertSize
    ) const pure nothrow @safe @nogc
    {
        for (int numColumns = 1; ; ++numColumns) {
            immutable vertSize = (numKoans + (numColumns - 1)) / numColumns;
            if (vertSize <= idealVertSize) {
                return vertSize;
            }
        }
    }

    immutable(Column)[] columnizeForVertSize(
        in int vertSize
    ) const pure nothrow @trusted
    in { assert (vertSize >= 1); }
    do {
        Column[] ret;
        ret.length = (numKoans + vertSize - 1) / vertSize;
        columnizeInto(ret, vertSize);
        return ret.assumeUnique;
    }

    void columnizeInto(
        Column[] output,
        in int vertSize) const pure nothrow @safe @nogc
    {
        if (output.length == 0) {
            return;
        }
        foreach (size_t col; 0 .. output.length - 1) {
            output[col].koans = _rawKoans[vertSize * col
                                       .. vertSize * (col + 1)];
        }
        output[$-1].koans = _rawKoans[vertSize * (output.length - 1) .. $];
    }
}
