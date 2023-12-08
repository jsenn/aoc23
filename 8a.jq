include "util";

def parse_instruction:
	split(" = ")
	| {
		(.[0]): {"L": .[1][1:4], "R": .[1][6:9]}
	}
	;

def parse_input:
	split("\n\n")
	| {
		"turns": .[0] | split(""),
		"graph": (
			.[1]
			| lines
			| reduce .[] as $line ({};
				. + ($line | parse_instruction)
			)
		)
	}
	;

parse_input
| .graph as $graph
| .turns as $turns
| {"node": "AAA", "next_turn": 0, "step_count": 0}
| until(.node == "ZZZ";
	{
		"node": $graph[.node][$turns[.next_turn]],
		"next_turn": ((.next_turn + 1) % ($turns | length)),
		"step_count": (.step_count + 1)
	}
)
| .step_count
