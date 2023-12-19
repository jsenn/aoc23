include "util";

def parse_workflows:
	lines
	| map(
		index("{") as $name_end
		| [capture("(?<xmas>[xmas])(?<comp>[><])(?<val>\\d+):(?<dest>[a-zA-Z]+)"; "g")] as $rules
		| match("([a-zA-Z]+)}").captures[0].string as $default
		| {
			"name": .[:$name_end],
			"rules": ($rules | map(.val |= tonumber)),
			"default": $default
		}
	)
	| reduce .[] as $workflow ({};
		. + {($workflow.name): {
			"rules": $workflow.rules,
			"default": $workflow.default
		}}
	)
	;

def parse_parts:
	lines
	| map(
		gsub("(?<xmas>[xmas])="; "\"\(.xmas)\":")
		| fromjson
	)
	;

def parse_input:
	split("\n\n")
	| {
		"workflows": (.[0] | parse_workflows),
		"parts": (.[1] | parse_parts)
	}
	;

def match_rule($part):
	if .comp == "<" then
		$part[.xmas] < .val
	else
		assert(.comp == ">"; "Invalid comparator: \(.)")
		| $part[.xmas] > .val
	end
	;

def accepted($workflows):
	. as $part
	| "in"
	| until(. == "A" or . == "R";
		$workflows[.] as $workflow
		| ($workflow.rules | find_if(match_rule($part))) as $match_idx
		| if $match_idx != -1 then
			$workflow.rules[$match_idx] as $rule
			| . = $rule.dest
		else
			. = $workflow.default
		end
	)
	| . == "A"
	;

parse_input
| .workflows as $workflows
| .parts
| map(
	select(accepted($workflows))
	| add
)
| add
