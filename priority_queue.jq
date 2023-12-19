include "util";

# I don't know why, but this dumb sorted array implementation blows a heap based one out of the water in a simple benchmark...
def PriorityQueue: 
	{
		"values": [],
		"priorities": []
	}
	;

def is_priority_queue:
	type == "object"
	and (.values | type == "array")
	and (.priorities | type == "array")
	and ((.values | length) == (.priorities | length))
	;

def _length: length;
def length:
	if is_priority_queue then
		.values | _length
	else
		_length
	end
	;

def is_empty: .values | length == 0;

def clear:
	.values = []
	| .priorities = []
	;

def insert($x; $p):
	(
		.priorities
		| bsearch($p)
		| if . < 0 then
			-1 - .
		else 
			.
		end
	) as $bs_idx
	| .values |= .[0:$bs_idx] + [$x] + .[$bs_idx:]
	| .priorities |= .[0:$bs_idx] + [$p] + .[$bs_idx:]
	;

def get_min: [.values[0], .priorities[0]];

def pop_min:
	.values |= .[1:]
	| .priorities |= .[1:]
	;
