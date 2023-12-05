# jq -R -s -f <this file> <input file>
include "util";

def parse_input:
	lines
	| map(
		split(": ")[1]
		| split(" | ")
		| map(
			trim
			| split("\\s+"; "g")
			| map(tonumber)
		)
	)
	;

parse_input
| map(
	.[1] as $drawn
	| .[0] | intersect_with($drawn)
	| length
)
| length as $total
| (1 | repeatn($total)) as $counts
| enumerate
| reduce .[] as $pair ($counts;
	$pair[0] as $idx
	| .[$idx] as $mycount
	| ($idx + 1) as $begin
	| ($begin + $pair[1]) as $end
	| .[range($begin; $end)] += $mycount
)
| add
