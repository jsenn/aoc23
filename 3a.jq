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

def is_symbol: is_digit or is_dot | not;
def symbol_mask:
	. as $grid
	| .vals
	| map(is_symbol) 
	| grid::Grid($grid.nrows; $grid.ncols)
	;
def symbol_neighbours: symbol_mask | grid::dilate;

parse_input
| (.grid | symbol_neighbours) as $mask
| .lines
| extract_numbers
| map(
	. as $n
	| .row
	| grid::colrange($n.begin; $n.begin + $n.length)
	| map(grid::get($mask))
	| select(any)
	| $n.val
)
| add
