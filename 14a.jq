include "util";

def parse_input:
	lines
	| map(explode)
	| transpose
	;

def row_weight:
	. as $row
	| length as $start_weight
	| reduce range(0; length) as $i ({"next_weight": $start_weight, "total": 0};
		$row[$i] as $c
		| if $c == 35 then # '#'
			.next_weight |= ($start_weight - $i - 1)
		elif $c == 79 then # 'O'
			.total += .next_weight
			| .next_weight -= 1
		end
	)
	| .total
	;

parse_input
| map(row_weight)
| add
