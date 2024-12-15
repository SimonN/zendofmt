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

import std.conv : text;
import std.stdio;

import zendofmt.footer;
import zendofmt.fromfile;
import zendofmt.versioning;

int main(string[] args)
{
    try {
        const options = processCommandLineArgs(args);
        formatKoansFromFile(options.filenameWhite, "White koans:").writeln;
        formatKoansFromFile(options.filenameBlack, "Black koans:").writeln;

        const footer = new Footer(options.filenameFooter);
        if (footer.exists) {
            footer.asFormatted.writeln;
        }
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
    writeln("(Or use other filenames and pass them as 1st and 2nd argument.)");
    writeln(" * List one koan per line. No special line termination.");
    writeln(" * An empty line marks subsequent koans as new (asterisk).");
    writeln(" * To not mark any koans as new, end with an empty line.");
    writeln("");
    writeln(`You can add a third file "`,
        CmdArgs.init.filenameFooter,
            `" with free-form text to print below.`);
    writeln("(Or use another filename and pass it as a 3rd argument.)");
    writeln(" * You can use backticks: `ABC` will become [tt]ABC[/tt].");
    writeln(" * Linebreaks will appear as-is.");
}

struct CmdArgs{
    string filenameWhite = "koans-w.txt";
    string filenameBlack = "koans-b.txt";
    string filenameFooter = "footer.txt";
}

CmdArgs processCommandLineArgs(string[] args)
{
    CmdArgs ret;
    if (args.length >= 3) {
        ret.filenameWhite = args[1];
        ret.filenameBlack = args[2];
    }
    if (args.length >= 4) {
        ret.filenameFooter = args[3];
    }
    if (args.length == 2 || args.length >= 5) {
        throw new Exception(text(
            "Pass either no arguments, or 2 or 3 filenames. ",
            "(You passed ", args.length - 1, " arguments.)"));
    }
    return ret;
}
