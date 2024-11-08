#!/usr/bin/rdmd

/* Formatting list of zendo koans
 *
 * You have to install a D compiler, e.g., dmd. It's packaged for all popular
 * operating systems here:
 *
 *      http://dlang.org/download.html
 *
 * After installation, on Linux, do this:
 *
 *      chmod +x zendo-format.d
 *      ./zendo-format.d
 *
 * If you're on Windows, you might want to avoid the command-line shell.
 * Make a batch file instead in the same directory as this script, with:
 *
 *      rdmd zendo-koans.d > output.txt
 *
 * General usage for all operating systems:
 *
 * Make a text file `zendo-w.txt' with unsorted white koans, one per line.
 * Make a text file `zendo-b.txt' with the black koans.
 * Run this program in the same dir as those files. Alternatively, name
 * the files however you want, and give them to this program as arguments.
 */

module zendofmt.main;

import std.algorithm;
import std.conv;
import std.math;
import std.range;
import std.stdio;
import std.string;

import zendofmt.column;
import zendofmt.koan;

enum filenameWhiteDefault = "koans-w.txt";
enum filenameBlackDefault = "koans-b.txt";

int main(string[] args)
{
    string fnWhite = filenameWhiteDefault;
    string fnBlack = filenameBlackDefault;

    try {
        process_args(args, fnWhite, fnBlack);

        auto koans_w = new Koans(fnWhite);
        auto koans_b = new Koans(fnBlack);

        koans_w.outputWithTitle("White koans:");
        koans_b.outputWithTitle("Black koans:");
    }
    catch (Exception e) {
        usage();
        writeln("\nError:\n", e.msg);
        return 1;
    }
    return 0;
}

void usage()
{
    writeln("Zendo koan list formatter");
    writeln(`List koans in "`,
        filenameWhiteDefault, `" and in "`,
        filenameBlackDefault, `" and run this.`);
    writeln("Alternatively, use other filenames, and pass them as arguments.");
    writeln();
    writeln("Rules for these koan lists:");
    writeln(" * List one koan per line. No special line termination.");
    writeln(" * Insert an empty line to mark subsequent koans as new (bold).");
    writeln(" * If you don't have any new koans, end with an empty line.");
}

void process_args(string[] args, ref string fw, ref string fb)
{
    if (args.length == 3) {
        fw = args[1];
        fb = args[2];
    }
    else if (args.length != 1) {
        throw new Exception("Pass either no arguments, or two filenames.");
    }
}



class Koans {

    Koan[] raw_koans; // not yet formatted

    immutable spacing =  2; // min spaces between columns
    immutable maxchar = 80; // lines must be smaller than this

    static int acceptable_vert_size = 10; // up to this, prefer long vertical
                                          // list instead of many rows

    this(string fn)
    {
        auto f = File(fn, "r");
        bool any_newline_at_all = false;

        foreach (string line; f.lines) {
            string s = line.strip();
            if (s.length == 0) {
                any_newline_at_all = true;
                foreach (ref koan; raw_koans.retro) {
                    if (koan.isNew)
                        koan.isNew = false;
                    else
                        break;
                }
            }
            else
                raw_koans ~= Koan(line.strip(), true);
        }
        if (! any_newline_at_all) {
            foreach (ref koan; raw_koans)
                koan.isNew = false;
        }

        raw_koans = raw_koans.sort().uniq().array();
    }

    void outputWithTitle(in string title)
    {
        if (raw_koans.length == 0) {
            writeln("(no koans)");
            return;
        }
        writeln(title, "[tt]");
        Column[] columns = columnize();

        // output the columns, we iterate row-wise however
        for (int row = 0; row < columns[0].numKoans; ++row) {
            foreach (size_t j, col; columns) {
                if (row >= col.numKoans) continue;

                auto koan  = col.koans[row];
                bool endl  = (j + 1 == columns.length
                           || j + 2 == columns.length
                           && row >= columns[$-1].numKoans);

                write(koan.asFormatted,
                    endl ? "\n" : "",
                    ' '.repeat((!endl) * (
                        col.textLen + spacing - koan.textLen
                    )));
            }
        }
        writeln("[/tt]");
    }

    Column[] columnize()
    {
        if (! raw_koans.length)
            return null;

        // returns an array of columns. A column has an array of koans.
        // 0 3 6    Therefore, the _rows_ don't contain successive koans.
        // 1 4      The rightmost column may have fewer entries than others.
        // 2 5
        immutable koanmax = raw_koans.length.to!int;

        int vert_size = koanmax;
        for (int i = 1; vert_size > acceptable_vert_size; ++i)
            vert_size = (koanmax + i-1) / i;

        // Try making columns with maximal vertical length of (vert_size),
        // return them from the loop. If too wide, retry with ++vert_size
        for (; ; ++vert_size) {
            // how many columns to make
            immutable maxcol = (koanmax + vert_size - 1) / vert_size;

            Column[] ret;
            ret.length = maxcol;

            if (vert_size * maxcol == koanmax)
                ret[$-1].last_full = true;
            else
                ret[$-2].last_full = true;

            // fill these columns with koans
            foreach (size_t k, ref koan; raw_koans) {
                immutable size_t cur_col = k / vert_size;
                assert (cur_col < maxcol);
                ret[cur_col].koans ~= koan;
            }
            // are these columns narrow enough to be returned?
            if (ret.map!(col => col.textLen).sum < maxchar) {
                return ret;
            }
            // if not, do another iteration with ++vert_size
        }
    }
}
