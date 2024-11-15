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

import std.stdio;

import zendofmt.table;

enum filenameWhiteDefault = "koans-w.txt";
enum filenameBlackDefault = "koans-b.txt";

int main(string[] args)
{
    string fnWhite = filenameWhiteDefault;
    string fnBlack = filenameBlackDefault;

    try {
        process_args(args, fnWhite, fnBlack);

        auto koans_w = new KoanTable(fnWhite);
        auto koans_b = new KoanTable(fnBlack);

        koans_w.asFormattedWithTitle("White koans:").writeln;
        koans_b.asFormattedWithTitle("Black koans:").writeln;
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


