include "util";
import "grid" as grid;

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
	{"prev": $start, "curr": ., "loop": [$start]}
	| until(.curr == $start;
		.prev as $prev
		#| debug("\(.prev)->\(.curr)   \(.prev | grid::get($grid))->\(.curr | grid::get($grid))")
		| .prev = .curr
		| .curr = (.curr | next_step($prev; $grid))
		| .loop += [.prev]
	)
	| .loop
	;

def parse_lines:
	lines
	| map(split(""))
	| grid::from_rows
	;

def adj_cells($grid):
	[
		[.[0] - 1, .[1] - 1],
		[.[0] - 1, .[1]],
		[.[0], .[1] - 1],
		[.[0], .[1]]
	]
	| map(select(grid::valid_rc($grid)))
	;

def adj_cells($orig; $grid):
	if .[0] == -1 then # up
		[
			[$orig[0] - 1, $orig[1] - 1],
			[$orig[0] - 1, $orig[1]]
		]
	elif .[0] == 1 then # down
		[
			[$orig[0], $orig[1] - 1],
			[$orig[0], $orig[1]]
		]
	elif .[1] == -1 then # left
		[
			[$orig[0] - 1, $orig[1] - 1],
			[$orig[0], $orig[1] - 1]
		]
	elif .[1] == 1 then # right
		[
			[$orig[0] - 1, $orig[1]],
			[$orig[0], $orig[1]]
		]
	else
		assert(false; "Unreachable")
	end
	| map(select(grid::valid_rc($grid)))
	;

def is_hwall($grid; $loop):
	assert(all(grid::valid_rc($grid)); "Invalid cells sent to is_hwall: \(.)")
	| sort_by(.[1])
	| if length == 1 then
		false
	elif length == 2 then
		(.[0] | grid::get($grid)) as $left
		| (.[1] | grid::get($grid)) as $right
		| $loop[(.[0] | tostring)] and $loop[(.[1] | tostring)] and
		(($left == "-" and (["S", "-", "J", "7"] | index($right)))
		or ($left == "L" and (["S", "-", "J", "7"] | index($right)))
		or ($left == "F" and (["S", "-", "J", "7"] | index($right)))
		or ($left == "S" and (["S", "-", "J", "7"] | index($right))))
	else
		assert(false; "Invalid cells given to is_hwall: \(.)")
	end
	;

def is_vwall($grid; $loop):
	assert(all(grid::valid_rc($grid)); "Invalid cells sent to is_vwall: \(.)")
	| sort_by(.[0])
	| if length == 1 then
		false
	elif length == 2 then
		(.[0] | grid::get($grid)) as $top
		| (.[1] | grid::get($grid)) as $bottom
		| $loop[(.[0] | tostring)] and $loop[(.[1] | tostring)] and
		(($top == "|" and (["S", "|", "J", "L"] | index($bottom)))
		or ($top == "7" and (["S", "|", "J", "L"] | index($bottom)))
		or ($top == "F" and (["S", "|", "J", "L"] | index($bottom)))
		or ($top == "S" and (["S", "|", "J", "L"] | index($bottom))))
	else
		assert(false; "Invalid cells given to is_vwall: \(.)")
	end
	;

def corner_connects_from($orig; $grid; $loop):
	(.[0] - $orig[0]) as $dr
	| (.[1] - $orig[1]) as $dc
	| ([$dr, $dc] | adj_cells($orig; $grid)) as $adj_cells
	| assert(($dr + $dc | abs) == 1; "Invalid direction connecting \(orig) to \(.): (\($dr), \($dc))")
	| if $dr == -1 or $dr == 1 then # up/down
		$adj_cells | is_hwall($grid; $loop) | not
	elif $dc == -1 or $dc == 1 then # left/right
		$adj_cells | is_vwall($grid; $loop) | not
	else
		assert(false; "Unreachable")
	end
	;

def next_corners($grid; $loop):
	. as $orig
	| [
		[$orig[0] - 1, $orig[1]], # up
		[$orig[0] + 1, $orig[1]], # down
		[$orig[0], $orig[1] - 1], # left
		[$orig[0], $orig[1] + 1] # right
	]
	| map(
		select(
			.[0] >= 0 and .[0] <= $grid.nrows and
			.[1] >= 0 and .[1] <= $grid.ncols and
			corner_connects_from($orig; $grid; $loop)
		)
	)
	;

def trace_corners($grid; $loop):
	{"visited": {}, "q": [.]}
	| until(.q | is_empty;
		.q[-1] as $curr
		| .visited as $visited
		| (
			$curr
			| next_corners($grid; $loop)
			| map(select($visited[tostring] == null))
		) as $next
		| .visited += {($curr | tostring): $curr}
		| .q |= (pop | . + $next)
	)
	| .visited as $lookup
	| $grid
	| grid::enumerate_rc
	| map(
		select(
			[
				[.[0], .[1]], # top left
				[.[0], .[1] + 1], # top right
				[.[0] + 1, .[1]], # bottom left
				[.[0] + 1, .[1] + 1] # bottom right
			] |
			all($lookup[tostring] != null)
		)
	)
	;

def outside_cells($loop):
	. as $grid
	| [0, 0] | trace_corners($grid; $loop)
	;

parse_lines
| . as $grid
| grid::find_rc("S") as $start
| $start
| connections($grid)
| assert(length == 2; "Invalid start")
| .[0]
| track_loop($start; $grid)
| reduce .[] as $rc ({};
	. += {($rc | tostring): $rc}
)
| . as $loop_lookup
| $grid
| outside_cells($loop_lookup)
| length as $outside_count
| ($loop_lookup | length) as $loop_count
| $grid.nrows * $grid.ncols - $outside_count - $loop_count
