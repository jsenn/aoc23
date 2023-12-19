include "util";
import "grid" as grid;

def parse_input:
	lines
	| map(
		split(" ")
		| [
			.[0],
			(.[1] | tonumber),
			.[2][1:-1]
		]
	)
	;

def trace_loop:
	reduce .[] as $instr ([[0, 0], []];
		$instr[0] as $dir
		| $instr[1] as $steps
		| .[0] as $start
		| if $dir == "L" then
			.[0] |= [.[0], .[1] - $steps]
			| .[1] += [$start + ["C"]] + [
				[$start[0]]
				+ (range($start[1] - 1; $start[1] - $steps; -1) | [.])
				+ ["L"]
			]
		elif $dir == "R"  then
			.[0] |= [.[0], .[1] + $steps]
			| .[1] += [$start + ["C"]] + [
				[$start[0]]
				+ (range($start[1] + 1; $start[1] + $steps) | [.])
				+ ["R"]
			]
		elif $dir == "U" then
			.[0] |= [.[0] - $steps, .[1]]
			| .[1] += [$start + ["C"]] + [
				(range($start[0] - 1; $start[0] - $steps; -1) | [.])
				+ [$start[1]]
				+ ["U"]
			]
		else
			assert($dir == "D"; "Invalid dir: \($dir)")
			| .[0] |= [.[0] + $steps, .[1]]
			| .[1] += [$start + ["C"]] + [
				(range($start[0] + 1; $start[0] + $steps) | [.])
				+ [$start[1]]
				+ ["D"]
			]
		end
	)
	| .[1]
	;

def index_by_row:
	group_by(.[0])
	| map(
		map(.[1:])
		| sort
	)
	;

parse_input
| trace_loop
| min_by(.[0])[0] as $min_row
| max_by(.[0])[0] as $max_row
| min_by(.[1])[1] as $min_col
| max_by(.[1])[1] as $max_col
| ($max_row - $min_row + 1) as $nrows
| ($max_col - $min_col + 1) as $ncols
| map(
	[
		(.[0] - $min_row),
		(.[1] - $min_col)
	]
)
| reduce .[] as $cell (grid::zeros($nrows; $ncols);
	. |= grid::set($cell; 1)
)
| [-$min_row, -$min_col] as $start
| [$start[0] - 1, $start[1] + 1] as $inside
#| [1, 1] as $inside
| grid::flood_fill($inside)
| .vals
| add
