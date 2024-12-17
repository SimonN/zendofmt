#!/usr/bin/rdmd

import std.algorithm;
import std.range;
import std.process;
import std.stdio : File, lines;
import std.string;

void main()
{
    sortTheFeed();

    import std.stdio;
    execute("./zendofmt").output.write;
}

void sortTheFeed()
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

bool I(in char c) pure nothrow @safe @nogc
{
    return c == 'I';
}

bool isPalindrome(Range)(Range range)
{
    return range.save.equal(range.save.retro);
}

bool hasBuddha(in string koanAsUtf8) pure nothrow @safe @nogc
{
    immutable koan = koanAsUtf8.representation;
    return koan.map!I.isPalindrome;
}
