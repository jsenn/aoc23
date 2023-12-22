include "util";

def parse_input:
	lines
	| map(split(" -> "))
	| reduce .[] as $pair ({};
		($pair[1] | split(", ")) as $outputs
		| if $pair[0] == "broadcaster" then
			. + {"broadcaster": {"type": "broadcaster", "outputs": $outputs}}
		else
			. + {($pair[0][1:]): {"type": $pair[0][0:1], "outputs": $outputs}}
		end
	)
	| . as $outputs_only
	| keys
	| reduce .[] as $key ($outputs_only;
		.[$key] as $parent
		| . |= reduce $parent.outputs[] as $child_key (.;
			if .[$child_key].inputs == null then
				.[$child_key].inputs = [$key]
			else
				.[$child_key].inputs += [$key]
			end
		)
	)
	;

def init_state:
	if .type == "broadcaster" then
		null
	elif .type == "%" then
		0
	elif .type == "&" then
		(.inputs | length) as $n
		| 0 | repeatn($n)
	end
	;

def init_states:
	. as $nodes
	| keys
	| reduce .[] as $name ({};
		. + {($name): ($nodes[$name] | init_state)}
	)
	;

def push_button($nodes):
	.q = [[null, "broadcaster", 0]]
	| until (.q | is_empty;
		.q[0] as $curr
		| .q |= pop_front
		| $curr[0] as $sender_name
		| $curr[1] as $receiver_name
		| $curr[2] as $pulse
		| $nodes[$receiver_name] as $receiver
		| if $pulse == 0 then
			.low_pulses += 1
		else
			.high_pulses += 1
		end
		| if $receiver.type == "broadcaster" then
			.q += ($receiver.outputs | map(
				[$receiver_name, ., $pulse]
			))
		elif $receiver.type == "%" then
			if $pulse == 0 then
				.states[$receiver_name] as $old
				| .states[$receiver_name] = (1 - $old)
				| .q += ($receiver.outputs | map(
					[$receiver_name, ., (1 - $old)]
				))
			end
		elif $receiver.type == "&" then
			($receiver.inputs | index($sender_name)) as $idx
			| .states[$receiver_name][$idx] = $pulse
			| (.states[$receiver_name] | all(. == 1)) as $all_high
			| (if $all_high then 0 else 1 end) as $new_pulse
			| .q += ($receiver.outputs | map(
				[$receiver_name, ., $new_pulse]
			))
		end
	)
	;

parse_input
| . as $nodes
| {
	"q": [],
	"states": ($nodes | init_states),
	"low_pulses": 0,
	"high_pulses": 0
} as $init
| reduce range(1000) as $i ($init;
	. |= push_button($nodes)
)
| .low_pulses * .high_pulses
