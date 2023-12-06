include "util";

def parse_range:
	split(" ")
	| map(tonumber)
	| {
		"src": .[1],
		"dst": .[0],
		"len": .[2]
	}
	;

def apply_range($range):
	. as $val
	| ($val - $range.src) as $diff
	| if $diff >= 0 and $diff < $range.len then
		$range.dst + $diff
	else
		null
	end
	;

def apply_map($map):
	. as $val
	| $map
	| map(select(.src <= $val and $val < .src + .len))
	| if length == 0 then
		$val
	else
		assert(length == 1)
		| .[0] as $range
		| $val
		| apply_range($range)
		| . // $val
	end
	;

def parse_input:
	split("\n\n")
	| {
		"seeds": .[0] | extract_numbers,
		"maps":
			.[1:]
			| map(
				split(":")
				| .[1]
				| lines
				| map(parse_range)
				| sort_by(.src)
			)
	}
	;

def to_location($maps):
	. as $seed
	| $maps
	| reduce .[] as $map ($seed;
		. | apply_map($map)
	)
	;

parse_input
| .maps as $maps
| .seeds
| map(
	. | to_location($maps)
)
| min
