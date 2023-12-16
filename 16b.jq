include "util";
import "grid" as grid;
import "set" as set;


def valid_dir:
	(.[0] == 0 and .[1] == -1)
	or (.[0] == 0 and .[1] == 1)
	or (.[0] == -1 and .[1] == 0)
	or (.[0] == 1 and .[1] == 0)
	;

def trace_beam($grid):
	assert((.[0] | grid::valid_rc($grid)); "Invalid grid pos: \(.[0])")
	| assert((.[1] | valid_dir); "Invalid dir: \(.[1])")
	| .[0] as $start_pos
	| .[1] as $start_dir
	| (.[2] // {}) as $start_visited
	| {
		"pos": $start_pos,
		"dir": $start_dir,
		"visited": $start_visited
	}
	| until(
		[.pos, .dir] as $pose
		| (.visited | set::has($pose))
		or ((.pos | grid::valid_rc($grid)) | not)
		;
		[.pos, .dir] as $pose
		| .visited |= set::insert($pose)
		| (.pos | grid::get($grid)) as $c
		| if $c == 46 then # '.'
			.pos[0] += .dir[0]
			| .pos[1] += .dir[1]
		elif $c == 47 then # '/'
			.dir |= [-.[1], -.[0]]
			| .pos[0] += .dir[0]
			| .pos[1] += .dir[1]
		elif $c == 92 then # '\'
			.dir |= [.[1], .[0]]
			| .pos[0] += .dir[0]
			| .pos[1] += .dir[1]
		elif $c == 45 then # '-'
			if .dir[0] == 0 then # horizontal
				.pos[0] += .dir[0]
				| .pos[1] += .dir[1]
			else # vertical
				.visited = ([.pos, [0, -1], .visited] | trace_beam($grid)) # left
				| .visited = ([.pos, [0, 1], .visited] | trace_beam($grid)) # right
			end
		elif $c == 124 then # '|'
			if .dir[1] == 0 then # vertical
				.pos[0] += .dir[0]
				| .pos[1] += .dir[1]
			else # horizontal
				.visited = ([.pos, [-1, 0], .visited] | trace_beam($grid)) # up
				| .visited = ([.pos, [1, 0], .visited] | trace_beam($grid)) # down
			end
		else
			assert(false; "Invalid character: \($c)")
		end
	)
	| .visited
	;

def count_energized($grid):
	trace_beam($grid)
	| keys
	| map(
		fromjson
		| .[0]
	)
	| set::from
	| length
	;

def starts:
	. as $grid
	| ( [range(0; .ncols)] | map([[0, .], [1, 0]])) # top
	+ ( [range(0; .ncols)] | map([[$grid.nrows - 1, .], [-1, 0]])) # bottom
	+ ( [range(0; .nrows)] | map([[., 0], [0, 1]])) # left
	+ ( [range(0; .nrows)] | map([[., $grid.ncols - 1], [0, -1]])) # right
	;

grid::parse
| . as $grid
| starts
| map(
	count_energized($grid)
)
| max

