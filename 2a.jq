# jq -R -s -f <this file> <input file>
include "util";

def game_id: split(" ") | .[1] | tonumber;

def channel($name): scan("(\\d+) \($name)")[0] | tonumber;
def rgb: [channel("red"), channel("green"), channel("blue")];

def parse_input:
	lines
	| map(
		split(": ")
		| {"ID": (.[0] | game_id), "draws": .[1] | split("; ") | map(rgb)}
	)
;

def possible_game: .draws | all(.[0] <= 12 and .[1] <= 13 and .[2] <= 14);

parse_input
| map(select(possible_game) | .ID)
| add
