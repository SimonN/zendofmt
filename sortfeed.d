#!/usr/bin/rdmd

import std.algorithm;
import std.range;
import std.stdio : File, lines;
import std.string;

void main()
{
    auto f = File("feed.txt", "r");
    auto w = File("koans-w.txt", "w");
    auto b = File("koans-b.txt", "w");

    foreach (string unstrippedLine; f.lines) {
        string line = unstrippedLine.strip;
        if (line.length == 0) {
            w.writeln;
            b.writeln;
            continue;
        }
        (line.hasBuddha ? &w : &b).writeln(line);
    }
}

bool hasBuddha(in string koan) pure @safe
{
    return koan.isSorted || koan.retro.isSorted;
}
