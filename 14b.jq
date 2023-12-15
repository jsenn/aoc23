include "util";

def parse_input:
	lines
	| map(explode)
	;

def fall_row:
	. as $row
	| length as $row_length
	| reduce range(0; $row_length) as $i ([];
		$row[$i] as $c
		| if $c == 79 then # 'O'
			. += [79]
		elif $c == 35 then # '#'
			length as $curr_length
			| . += (46 | repeatn($i - $curr_length))
			| . += [35]
		end
	)
	| length as $curr_length
	| if $curr_length < $row_length then
		. + (46 | repeatn($row_length - $curr_length))
	else
		.
	end
	;

def fall: map(fall_row);

def spin:
	transpose
	| fall			# N
	| transpose
	| fall			# W
	| reverse
	| transpose
	| fall			# S
	| reverse
	| transpose
	| fall			# E
	| reverse
	| map(reverse)
	;

def north_load:
	. as $rows
	| length as $nrows
	| reduce range(0; $nrows) as $r (0;
		$rows[$r] as $row
		| ($row | map(select(. == 79)) | length) as $O_count
		| . + $O_count * ($nrows - $r)
	)
	;

def grid_to_str: map(implode) | join("\n");

def spin_many($max):
	. as $grid
	| {"i": 0, "curr": $grid, "cache": {(grid_to_str): 0}, "new_max": null}
	| until(.i == $max;
		.curr |= spin
		| (.curr | grid_to_str) as $str
		| .cache[$str] as $cycle_start
		| if $cycle_start != null then
			(.i - $cycle_start) as $cycle_len
			| (($max - $cycle_start) % $cycle_len) as $cycle_pos
			| .new_max = ($cycle_start + $cycle_pos)
			| .i = $max # break
		else
			.cache += {(.curr | grid_to_str): .i}
			| .i += 1
		end
	)
	;

parse_input
| . as $grid
| spin_many(1e9)
| .new_max as $max
| $grid
| spin_many($max)
| .curr
| north_load
