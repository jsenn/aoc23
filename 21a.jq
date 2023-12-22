include "util";
import "grid" as grid;
import "priority_queue" as pq;
import "set" as set;

def walk_from($start):
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
		| if $steps % 2 == 0 then
			.evens += [$rc]
		end
		| if $steps < 64 then
			(
				.visited as $visited
				| $grid
				| grid::neumann_rc($rc)
				| map(
					select(
						. as $neighbour_rc
						| ($grid | grid::get($neighbour_rc) != 35)
						and ($visited | set::has($neighbour_rc) | not)
					)
					| [., ($steps + 1)]
				)
			) as $neighbours
			| reduce $neighbours[] as $neighbour(.;
				.visited |= set::insert($neighbour[0])
				| .q |= pq::insert($neighbour[0]; $neighbour[1])
			)
		end
	)
	;

grid::parse
| . as $grid
| grid::find_rc(83) as $start
| walk_from($start)
| .evens
| length
#| reduce .[] as $rc ($grid;
	#. |= if grid::get($rc) != 83 then grid::set($rc; 79) end
#)
#| .vals |= map([.]|implode)
#| grid::pprint
#| halt_error

