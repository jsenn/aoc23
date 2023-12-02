# jq -R -s -f <this file> <input file>
include "util";

def channel($name): (scan("(\\d+) \($name)")[0] | tonumber) // 0;
def rgb: [channel("red"), channel("green"), channel("blue")];
def draws: split(": ") | .[1] | split("; ");
def parse_input: lines | map(draws | map(rgb));

def lower_bound: transpose | map(max);

parse_input
| map(lower_bound | mul)
| add
