include "util";
import "grid" as grid;
import "priority_queue" as pq;
import "set" as set;

def parse_input:
	lines
	| map(
		extract_digits
	)
	| grid::from_rows
	;

def trace($grid):
	.[0] as $start
	| .[1] as $end
	| {
		"q": (
			pq::PriorityQueue
			| pq::insert(
				{
					"rc": $start,
					"steps": 0,
					"dir": null
				};
				0
			)
		),
		"visited": set::Set,
		"goal_cost": null
	}
	| until((.goal_cost != null) or (.q | pq::is_empty);
		(.q | pq::get_min) as $min
		| .q |= pq::pop_min
		| $min[0] as $curr_node
		| $min[1] as $curr_cost
		| $curr_node.rc as $curr_rc
		| $curr_node.steps as $curr_steps
		| $curr_node.dir as $prev_dir
		| if $curr_rc == $end then
			.goal_cost = $curr_cost
		end
		| (
			.steps as $steps
			| $grid
			| grid::neumann_rc($curr_rc)
			| map(
				grid::dir_from($curr_rc) as $dir
				| select(
					$prev_dir == null

					or (
						$dir != [-$prev_dir[0], -$prev_dir[1]]
						and (
							($dir != $prev_dir and $curr_steps >= 4)
							or ($dir == $prev_dir and $curr_steps < 10)
						)
					)
				)
				| [
					{
						"rc": .,
						"steps": (if $dir == $prev_dir then ($curr_steps + 1) else 1 end),
						"dir": $dir
					},
					($curr_cost + grid::get_from($grid))
				]
			)
		) as $neighbours
		| reduce $neighbours[] as $neighbour_pair (.;
			$neighbour_pair[0] as $neighbour_node
			| $neighbour_pair[1] as $neighbour_cost
			| $neighbour_node.rc as $neighbour_rc
			| if .visited | set::has($neighbour_node) | not then
				.q |= pq::insert($neighbour_node; $neighbour_cost)
				| .visited |= set::insert($neighbour_node)
			end
		)
	)
	;

parse_input
| . as $grid
| [grid::top_left_rc, grid::bottom_right_rc]
| trace($grid)
| .goal_cost
