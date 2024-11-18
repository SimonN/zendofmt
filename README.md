zendofmt
========

zendofmt is a koan formatter for Forum Zendo.

Forum Zendo is a classic free-form, turn-less induction game. The host
fixes a secret rule that evaluates words (nonempty strings over the
alphabet A-Z) deterministically as either white or black.
E.g., the host may choose: "A word is white if and only if it contains
at least one double letter, and black otherwise."

Players post words, and the host classifies each word publicly as
white or black according to the prefixed rule. zendofmt helps the host
of a game of Forum Zendo to format the two word lists for posting to an
SMF 2.x message board.

Download
--------

I've released [standalone exetucables for Windows or
Linux](https://github.com/SimonN/zendofmt/releases).

Build Instructions
------------------

1. Install a D compiler, e.g., DMD or LDC. Both of them ship with dub.
2. Clone the zendofmt repository.
3. In zendofmt's root directory, run: `$ dub`

Usage
-----

1. Create two files `koans-w.txt` and `koans-b.txt` in the same directory
    as the executable. In each file, list one word per line.
2. Run: `$ ./zendofmt`
3. The next time you add new words to the `koans-*.txt` files,
    first remove all empty lines from these files, then append an empty line,
    then add the new words below that new empty line.
4. Rerun `$ ./zendofmt` to get the newly added words marked with asterisks.

License/Copying
---------------

This software is placed in the public domain via the [CC0 Public Domain
Dedication, Version 1.0](https://creativecommons.org/publicdomain/zero/1.0/).

Based on: Zendo
---------------

The names (Forum Zendo for the game, and koan for the example words) come from
Zendo, a tabletop induction game designed in 2001 by Kory Heath.

The main features in regular Zendo are

* the goal of guessing the secret rule with your own words
    (instead of, e.g., providing many correct examples for the rule),
* a turn order (build example, quiz it or have it marked, guess the rule),
* a way to earn and spend guessing stones (a collectible resource), and
* construction of counterexamples after wrong rule guesses.

These features set Zendo apart from other induction games. For example,
you may have played rule-guessing word games in your childhood during
long road trips. Such games have turns, but no guessing stones.

Forum Zendo gives up _both_ the turn order (to make the game independent of
idling players) and the guessing stones. This makes it even more remote from
regular Zendo than those word-guessing games. Nonetheless, we've kept the
naming from Zendo. We're all Zendo players and are used to the terminology.
