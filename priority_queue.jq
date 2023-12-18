include "util";

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

def _swap($i; $j):
	.values |= swap($i; $j)
	| .priorities |= swap($i; $j)
	;

def _swap_and_pop($i):
	.values |= swap_and_pop($i)
	| .priorities |= swap_and_pop($i)
	;

def _parent($i):
	if $i == 0 then
		null
	else
		div($i - 1; 2)
	end
	;

def _last_internal_idx:
	if length <= 1 then
		null
	else
		_parent(length - 1)
	end
	;

def _left($i):
	(2 * $i + 1) as $left
	| if $left >= length then
		null
	else
		$left
	end
	;

def _right($i):
	(2 * $i + 2) as $right
	| if $right >= length then
		null
	else
		$right
	end
	;

def _sink($start_idx):
	length as $end_idx
	| [$start_idx, .]
	| until(.[0] == null;
		.[0] as $i
		| (.[1] | _left($i)) as $i_l
		| (.[1] | _right($i)) as $i_r
		| if $i_l == null and $i_r == null then
			.[0] = null
		elif $i_l == null then
			if $i_r < $end_idx and .[1].priorities[$i_r] < .[1].priorities[$i] then
				.[1] |= _swap($i_r; $i)
				| .[0] = $i_r
			else
				.[0] = null
			end
		elif $i_r == null then
			if $i_l < $end_idx and .[1].priorities[$i_l] < .[1].priorities[$i] then
				.[1] |= _swap($i_l; $i)
				| .[0] = $i_l
			else
				.[0] = null
			end
		else
			.[1].priorities[$i_l] as $l
			| .[1].priorities[$i_r] as $r
			| (if $l < $r then $i_l else $i_r end) as $min_idx
			| if $min_idx >= $end_idx then
				.[0] = null
			else
				.[1].priorities[$i] as $c
				| .[1].priorities[$min_idx] as $m
				| if $m < $c then
					.[1] |= _swap($min_idx; $i)
					| .[0] = $min_idx
				else
					.[0] = null
				end
			end
		end
	)
	| .[1]
	;

def _float($start_idx):
	[$start_idx, .]
	| until(.[0] == null;
		.[0] as $i
		| _parent($i) as $i_p
		| if $i_p == null then
			.[0] = null
		else
			if .[1].priorities[$i] < .[1].priorities[$i_p] then
				.[1] |= _swap($i; $i_p)
				| .[0] = $i_p
			else
				.[0] = null
			end
		end
	)
	| .[1]
	;

def _fix($i):
	_parent($i) as $i_p
	| if $i_p != null and .priorities[$i_p] > .priorities[$i] then
		_float($i)
	else
		_sink($i)
	end
	;

def _delete($i):
	. |= _swap_and_pop($i)
	| . |= _fix($i)
	;

def heapify:
	if length <= 1 then
		.
	else
		reduce range(_last_internal_idx; -1; -1) as $i (.;
			_sink($i)
		)
	end
	;

def insert($x; $p):
	.values += [$x]
	| .priorities += [$p]
	| . |= _float(length - 1)
	;

def get_min:
	assert(.values | nonempty; "Can't get min element of empty heap")
	| [.values[0], .priorities[0]]
	;

def pop_min: _delete(0);
