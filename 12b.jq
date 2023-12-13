include "util";

def parse_input:
	lines
	| map(
		split(" ")
		| [
			.[0],
			(.[1] | extract_numbers)
			#(.[0] | repeatstr(5; "?")),
			#(.[1] | repeatstr(5; ",") | extract_numbers)
		]
	)
	;

def is_broken($str):
	.[0] as $begin
	| .[1] as $end
	| ($str | length) as $str_len
	| ($str | explode) as $chars
	| $end < $str_len
	and ($begin == 0 or $chars[$begin - 1] != 35)
	and $chars[$end] != 35
	and ([range($begin; $end)] | all($chars[.] != 46))
	#| debug("[\($begin), \($end)] | is_broken(\($str)) => \(.)")
	;

def all_partitions:
	#debug("call: \(.)")|
	.[0] as $str
	| ($str | explode) as $chars
	| ($str | length ) as $N
	| .[1] as $groups
	| ($groups | length) as $group_count
	| if $group_count == 0 then
		[]
	elif $group_count == 1 then
		#debug("in group == 1 case")|
		range(0; $N - $groups[0] + 1)
			#| debug("group == 1 range: \(.)")
			| . as $idx
			| [range($idx; $idx + $groups[0])] as $idxs
			| if [$idx, $idx + $groups[0]] | is_broken($str) then
				[$idx]
			else
				empty
			end
	else
		($groups | add) as $group_total
		| $groups[0] as $first
		#| debug("starting range->\($N - $group_total)")
		| range(0; $N - $group_total)
			#| debug("range: \(.)")
			| . as $start_idx
			| $chars[$start_idx] as $char
			#| debug("starting if $char")
			| if $char != 46 then # '.'
				#debug("in != 46")|
				($start_idx + $first + 1) as $next_start
				#| debug("Created $next_start: \($next_start)")
				| if [$start_idx, $next_start - 1] | is_broken($str) then
					#debug("In next - start if")|
					[$str[$next_start:], $groups[1:]] as $next
					| $next
					| all_partitions
						#| debug("partition: \(.)")
						| map(. + $start_idx + $first + 1)
						| [$start_idx] + .
				else
					#debug("in else")|
					empty
				end
			else
				empty
			end
	end
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

parse_input
| map(
	.[0] as $str
	| .[1] as $groups
	| ($str | length) as $str_length
	| [all_partitions]
	| map(
		enumerate
		| map(
			.[0] as $idx
			| .[1] as $start
			| [$start, $start + $groups[$idx]]
		)
		| reconstruct($str_length)
		#| select(validate($str))
		#| $str, ., $groups
	)
	| length
)
| add
