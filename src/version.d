module zendofmt.versioning;

import std.conv;

enum Version ourVersion = Version(1, 0, 0);

struct Version {
    int major;
    int minor;
    int patch;

    string asString() const pure nothrow @safe
    {
        return text(major, ".", minor, ".", patch);
    }
}

