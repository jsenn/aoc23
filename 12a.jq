include "util";

def parse_input:
	lines
	| map(
		split(" ")
		| [.[0], (.[1] | extract_numbers)]
	)
	;

def all_partitions:
	.[0] as $N
	| .[1] as $groups
	| ($groups | length) as $group_count
	| if $group_count == 0 then
		[]
	elif $group_count == 1 then
		range(0; $N - $groups[0] + 1)
			| [.]
	else
		($groups | add) as $group_total
		| $groups[0] as $first
		| range(0; $N - $group_total)
			| . as $start_idx
			| [$N - $start_idx - $first - 1, $groups[1:]] as $next
			| ($next | all_partitions) as $tail
			| $tail
				| map(. + $start_idx + $first + 1)
				| [$start_idx] + .
	end
	;

def validate($orig_str):
	. as $test_str
	| ($orig_str | explode) as $orig
	| explode
	| enumerate
	| all(
		.[0] as $idx
		| .[1] as $char
		| $orig[$idx] as $orig_char
		| ( $char == 46 and ($orig_char == 46 or $orig_char == 63))
		or ($char == 35 and ($orig_char == 35 or $orig_char == 63))
	)
	;

def reconstruct($length):
	reduce .[] as $range ([0, ""];
		($range[0] - .[0]) as $dot_count
		| ($range[1] - $range[0]) as $hash_count
		| .[0] = $range[1]
		| .[1] += ("." | repeatstr($dot_count)) + ("#" | repeatstr($hash_count))
	)
	| .[0] as $last_broken
	| .[1] + ("." | repeatstr($length - $last_broken))
	;

parse_input
| map(
	.[0] as $str
	| .[1] as $groups
	| ($str | length) as $str_length
	| [$str_length, $groups]
	| [all_partitions]
	| map(
		enumerate
		| map(
			.[0] as $idx
			| .[1] as $start
			| [$start, $start + $groups[$idx]]
		)
		| reconstruct($str_length)
		| select(validate($str))
	)
	| length
)
| add
