include "util";

def next_int:
	. as $val
	| ceil as $c
	| if $val == $c then $val + 1 else $c end
	;

def win_count:
	.[0] as $t
	| .[1] as $d
	| solve_quadratic(-1; $t; -$d)
	| assert(length == 2 and all(. > 0); "Invalid roots found")
	| (.[1] | ceil) - (.[0] | next_int)
	;

[54946592, 302147610291404]
| win_count
