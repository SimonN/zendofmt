/*
 * zendofmt - Formats lists of Forum Zendo koans for an SMF 2.x message board
 *
 * See README.md for build instructions and usage.
 *
 * License: CC0 Public Domain Dedication, Version 1.0
 *
 * This software is marked with CC0 1.0 Universal. This software is published
 * from Germany. To view a copy of the CC0 1.0 Universal license, visit:
 *      https://creativecommons.org/publicdomain/zero/1.0/
 */

module zendofmt.main;

import std.stdio;

import zendofmt.table;
import zendofmt.versioning;

int main(string[] args)
{
    try {
        const options = processCommandLineArgs(args);
        auto koansW = new KoanTable(options.filenameWhite);
        auto koansB = new KoanTable(options.filenameBlack);

        koansW.asFormattedWithTitle("White koans:").writeln;
        koansB.asFormattedWithTitle("Black koans:").writeln;
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
    writeln("zendofmt ",
        ourVersion.asString,
        " - Forum Zendo koan list formatter");
    writeln(`List koans in "`,
        CmdArgs.init.filenameWhite, `" and in "`,
        CmdArgs.init.filenameBlack, `" and run this.`);
    writeln("Alternatively, use other filenames, and pass them as arguments.");
    writeln();
    writeln("Rules for these koan lists:");
    writeln(" * List one koan per line. No special line termination.");
    writeln(" * An empty line marks subsequent koans as new (asterisk).");
    writeln(" * To not mark any koans as new, end with an empty line.");
}

struct CmdArgs{
    string filenameWhite = "koans-w.txt";
    string filenameBlack = "koans-b.txt";
}

CmdArgs processCommandLineArgs(string[] args)
{
    CmdArgs ret;
    if (args.length == 3) {
        ret.filenameWhite = args[1];
        ret.filenameBlack = args[2];
    }
    else if (args.length != 1) {
        throw new Exception("Pass either no arguments, or two filenames.");
    }
    return ret;
}
