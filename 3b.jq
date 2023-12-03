include "util";
import "grid" as grid;

def parse_input:
	lines
	| length as $nrows
	| (.[0] | length) as $ncols
	| {
		"lines": .,
		"grid": map(explode) | flatten | grid::Grid($nrows; $ncols)
	}
	;

def extract_numbers:
	map([match("(\\d+)"; "g").captures])
	| [foreach .[] as $captures (0; . += 1;
		(. - 1) as $row
		| $captures[][] | {
			"row": $row,
			"begin": .offset,
			"length": .length,
			"val": .string | tonumber
		}
	)]
	;

def is_star: . == 42;
def adj_numbers($numbers):
	. as $rc
	| ($numbers | map(select(
		((.row - $rc[0]) | abs) <= 1 and
		.begin - 1 <= $rc[1] and
		(.begin + .length >= $rc[1])
	)))
	;

def gear_ratio: mul;

parse_input
| (.lines | extract_numbers) as $numbers
| .grid
| grid::enumerate_rc
| map(
	select(.[2] | is_star)
	| adj_numbers($numbers)
	| select(length == 2)
	| map(.val)
	| gear_ratio
)
| add
