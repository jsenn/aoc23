include "util";

def parse_input:
	lines
	| map(extract_numbers)
	;

def predict_seq:
	assert(nonempty; "Can't predict empty sequence")
	| if all_same then
		.[-1]
	else
		.[-1] + (diffs | predict_seq)
	end
	;

parse_input
| map(reverse | predict_seq)
| add
