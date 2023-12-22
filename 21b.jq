include "util";
import "grid" as grid;
import "priority_queue" as pq;
import "set" as set;

def count_gardens($start; $dist):
	. as $grid
	| {
		"q": pq::PriorityQueue,
		"visited": (set::Set | set::insert($start)),
		"evens": []
	}
	| .q |= pq::insert($start; 0)
	| until(.q | pq::is_empty;
		(.q | pq::get_min) as $curr
		| .q |= pq::pop_min
		| $curr[0] as $rc
		| $curr[1] as $steps
		| if $steps % 2 == $dist % 2 then
			.evens += [$rc]
		end
		| if $steps < $dist then
			(
				.visited as $visited
				| [[-1, 0], [1, 0], [0, -1], [0, 1]]
				| map(
					[$rc[0] + .[0], $rc[1] + .[1]] as $neighbour_rc
					| [
						($neighbour_rc[0] % $grid.nrows + $grid.nrows) % $grid.nrows,
						($neighbour_rc[1] % $grid.ncols + $grid.ncols) % $grid.ncols
					] as $neighbour_mod
					| select(
						($grid | grid::get($neighbour_mod) != 35)
						and ($visited | set::has($neighbour_rc) | not)
					)
					| [$neighbour_rc, ($steps + 1)]
				)
			) as $neighbours
			| reduce $neighbours[] as $neighbour(.;
				.visited |= set::insert($neighbour[0])
				| .q |= pq::insert($neighbour[0]; $neighbour[1])
			)
		end
	)
	| .evens
	| length
	;

grid::parse
| . as $grid
| grid::find_rc(83) as $start
| div($TARGET; $grid.nrows) as $crossings
| ($TARGET % $grid.nrows) as $offset
| [0, 1, 2]
| map(
	. as $x
	| ($x * $grid.nrows + $offset) as $dist
	| $grid
	| count_gardens($start; $dist) as $y
	| [$x, $y]
) as $points
| $points
| fit_quadratic_3_points as $abc
| assert(
	$points
	| all(
		. as $p
		| .[0]
		| eval_quadratic($abc) == $p[1]
	)
	;
	"Invalid quadratic"
)
| $crossings
| eval_quadratic($abc)
