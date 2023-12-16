def Set: {};

def get_key: tostring;

def insert($val; $count):
	($val | get_key) as $key
	| if has($key) then
		.[$key] += $count
	else
		.[$key] = $count
	end
	;

def insert($val): insert($val; 1);

def remove($val):
	($val | get_key) as $key
	| del(.[$key])
	;

def count($val):
	($val | get_key) as $key
	| .[$key] // 0
	;

def has($val):
	($val | get_key) as $key
	| .[$key] != null
	;

def from:
	reduce .[] as $val (Set;
		. |= insert($val)
	)
	;

def union($other):
	reduce ($other | keys)[] as $key (.;
		insert($key; $other[$key])
	)
	;
