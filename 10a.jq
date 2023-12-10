include "util";
import "grid" as grid;

def parse_lines:
	lines
	| map(split(""))
	| grid::from_rows
	;

def connects_from($orig; $grid):
	grid::get($grid) as $to_val
	| ($orig | grid::get($grid)) as $from_val
	| (.[0] - $orig[0]) as $dr
	| (.[1] - $orig[1]) as $dc
	| assert(($dr + $dc | abs) == 1; "Invalid direction connecting \(orig) to \(.): (\($dr), \($dc))")
	| if $dr == -1 then # up
		(["S", "|", "L", "J"] | index($from_val)) and
		(["S", "|", "7", "F"] | index($to_val))
	elif $dr == 1 then # down
		(["S", "|", "7", "F"] | index($from_val)) and
		(["S", "|", "L", "J"] | index($to_val))
	elif $dc == -1 then # left
		(["S", "-", "7", "J"] | index($from_val)) and
		(["S", "-", "L", "F"] | index($to_val))
	elif $dc == 1 then #right
		(["S", "-", "L", "F"] | index($from_val)) and
		(["S", "-", "7", "J"] | index($to_val))
	else
		assert(false; "Unreachable")
	end
	;

def connections($grid):
	. as $orig
	| grid::neumann_rc($grid)
	| map(select(connects_from($orig; $grid)))
	;

def next_step($prev; $grid):
	connections($grid)
	| map(select(
		. != $prev
	))
	| assert(length == 1; "Invalid loop step. Options: \(.)")
	| .[0]
	;

def track_loop($start; $grid):
	{"prev": $start, "curr": ., "steps": 1}
	| until(.curr == $start;
		.prev as $prev
		#| debug("\(.prev)->\(.curr)   \(.prev | grid::get($grid))->\(.curr | grid::get($grid))")
		| .prev = .curr
		| .curr = (.curr | next_step($prev; $grid))
		| .steps += 1
	)
	| .steps
	;

parse_lines
| . as $grid
| grid::find_rc("S") as $start
| $start
| connections($grid)
| assert(length == 2; "Invalid start")
| .[0]
| track_loop($start; $grid)
| div(.; 2)
