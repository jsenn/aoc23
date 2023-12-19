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
		($workflow.rules + [{"dest": $workflow.default}]) as $rules
		| . + {($workflow.name): $rules}
	)
	;

def parse_input:
	split("\n\n")
	| .[0] | parse_workflows
	;

def index_by_rule:
	. as $workflows
	| keys
	| reduce .[] as $name ({};
		$workflows[$name] as $rules
		| reduce range($rules | length) as $rule_idx (.;
			$rules[$rule_idx] as $rule
			| if .[$rule.dest] == null then
				.[$rule.dest] = [[$name, $rule_idx]]
			else
				.[$rule.dest] += [[$name, $rule_idx]]
			end
		)
	)
	;

def winnow_rule($rule):
	if $rule.comp == "<" then
		.[$rule.xmas] |= range_intersect_inclusive([1, $rule.val - 1])
	elif $rule.comp == ">" then
		.[$rule.xmas] |= range_intersect_inclusive([$rule.val + 1, 4000])
	end
	;

def winnow_opp_rule($rule):
	if $rule.comp == "<" then
		.[$rule.xmas] |= range_intersect_inclusive([$rule.val, 4000])
	else
		assert($rule.comp == ">"; "Invalid comparator: \($rule)")
		| .[$rule.xmas] |= range_intersect_inclusive([1, $rule.val])
	end
	;

def winnow($rules):
	winnow_rule($rules[-1]) as $ranges
	| $rules[:-1]
	| reverse
	| reduce .[] as $rule ($ranges;
		. |= winnow_opp_rule($rule)
	)
	;

def trace($workflows; $reverse_index):
	.[0] as $workflow
	| .[1] as $rule_idx
	| .[2] as $ranges
	| $workflows[$workflow] as $rules
	| ($ranges | winnow($rules[0:$rule_idx + 1])) as $new_ranges
	| $reverse_index[$workflow]
	| if . == null then
		assert($workflow == "in"; "Un-indexed workflow: \($workflow)")
		| [$new_ranges]
	else
		reduce .[] as $next ([];
			. + (($next + [$new_ranges]) | trace($workflows; $reverse_index))
		)
	end
	;

parse_input
| . as $workflows
| index_by_rule
| . as $reverse_index
| .A
| map(
	. + [{
		"x": [1, 4000],
		"m": [1, 4000],
		"a": [1, 4000],
		"s": [1, 4000]
	}]
	| trace($workflows; $reverse_index)
	| map(
		(.x[1] - .x[0] + 1) * (.m[1] - .m[0] + 1) * (.a[1] - .a[0] + 1) * (.s[1] - .s[0] + 1)
	)
)
| flatten
| add
#| reduce .A as $accepted ([];
	#. + ($accepted | trace($workflows; $reverse_index)
#)
