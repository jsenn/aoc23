# jq -R -s -f <this file> <input file>
include "util";

def parse_input:
	lines
	| map(
		split(": ")[1]
		| split(" | ")
		| map(
			trim
			| split("\\s+"; "g")
			| map(tonumber)
		)
	)
	;

def score: if . <= 0 then 0 else pow(2; . - 1) end;

parse_input
| map(
	.[1] as $drawn
	| .[0] | intersect_with($drawn)
	| length
	| score
)
| add
