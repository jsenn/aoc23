include "util";

def parse_range:
	split(" ")
	| map(tonumber)
	| {
		"src": [.[1], .[1] + .[2]],
		"dst": [.[0], .[0] + .[2]],
	}
	;

def parse_input:
	split("\n\n")
	| {
		"seeds": .[0]
		| extract_numbers
		| enumerate
		| group_by ((.[0] / 2) | floor)
		| map(
			unenumerate
			| [.[0], .[0] + .[1]]
		),
		"maps":
			.[1:]
			| map(
				split(":")
				| .[1]
				| lines
				| map(parse_range)
				| sort_by(.src[0])
			)
	}
	;

def apply_range($range):
	if . >= $range.src[0] and . < $range.src[1] then
		$range.dst[0] + (. - $range.src[0])
		| assert(. >= $range.dst[0] and . < $range.dst[1]; "Invalid range output")
	else
		null
	end
	;

def split_range($range):
	.[0] as $in_begin
	| .[1] as $in_end
	| $range[0] as $r_begin
	| $range[1] as $r_end
	| assert($in_begin < $in_end and $r_begin < $r_end; "Internal error in split_range. In: [\($in_begin), \($in_end)], $range: [\($r_begin), \($r_end)]")
	| if $in_begin < $r_begin and $in_end > $r_end then # contains
		{
			"before": [$in_begin, $r_begin],
			"during": [$r_begin, $r_end],
			"after": [$r_end, $in_end]
		}
	  elif $in_begin < $r_begin and $in_end > $r_begin then # tail inside
	  	{
			"before": [$in_begin, $r_begin],
			"during": [$r_begin, $in_end],
			"after": []
		}
	  elif $in_begin < $r_end and $in_end > $r_end then # head inside
	  	{
			"before": [],
			"during": [$in_begin, $r_end],
			"after": [$r_end, $in_end]
		}
	  elif $in_end <= $r_begin then # entirely before
	  	{
			"before": [$in_begin, $in_end],
			"during": [],
			"after": []
		}
	  elif $in_begin >= $r_end then # entirely after
	  	{
			"before": [],
			"during": [],
			"after": [$in_begin, $in_end]
		}
	  else
	  	assert($in_begin >= $r_begin and $in_end <= $in_end; "Internal error in split_range. In: [\($in_begin), \($in_end)], $range: [\($r_begin), \($r_end)]")
		| {
			"before": [],
			"during": [$in_begin, $in_end],
			"after": []
		}
	  end
	  ;

def apply_map($map):
	. as $seed_range
	| {"curr": ., "results": []} as $state
	| reduce $map[] as $range ($state;
		if .curr[0] >= .curr[1] then
			.
		else
			(.curr | split_range($range.src)) as $split
			| {
				"curr": [if .curr[0] > $range.src[1] then .curr[0] else $range.src[1] end, .curr[1]],
				"results": (
					.results +
					if $split.before|length > 0 then
						[$split.before]
					else
						[]
					end +
					if $split.during|length > 0 then
						[
							[
								($split.during[0] | apply_range($range)),
								($split.during[1] - 1 | apply_range($range) | . + 1)
							]
						]
					else
						[]
					end
				)
			}
		end
	)
	| .results
	| if length == 0 then [$seed_range] else . end
	;

def to_location($maps):
	. as $seed
	| $maps
	| reduce .[] as $map ([$seed];
		map(apply_map($map)) | flatten(1)
	)
	;

parse_input
| .maps as $maps
| .seeds
| map(to_location($maps))
| flatten
| min
