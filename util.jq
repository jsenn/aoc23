def assert(cond; msg): if cond|not then (msg | halt_error) end;

def is_empty: length == 0;
def nonempty: length > 0;
def lines: split("\n") | map(select(nonempty));
def revstr: explode | reverse | implode;

def min($y): if . < $y then . else $y end;
def max($y): if . > $y then . else $y end;
def min($x; $y): if $x < $y then $x else $y end;
def max($x; $y): if $x > $y then $x else $y end;

def mul: reduce .[] as $x (1; . * $x);

def div($i; $j): $i / $j | floor;

def is_digit: . >= 48 and . <= 57;
def is_dot: . == 46;
def is_lower: . >= 97 and . <= 122;

def extract_numbers: [scan("-?\\d+(?:\\.\\d+)?")] | map(tonumber);
def extract_digits: [scan("\\d")] | map(tonumber);

def hextonumber:
	explode
	| reverse
	| reduce .[] as $c ([0, 1];
		if $c | is_digit then
			.[0] += ($c - 48) * .[1]
		elif $c | is_lower then
			.[0] += ($c - 87) * .[1]
		else
			assert(false; "Invalid character in hex string: \($c)")
		end
		| .[1] *= 16
	)
	| .[0]
	;

def repeatn(n):
	. as $val
	| [range(0; n)] | map($val)
	;

def intersect_with($b): . - (. - $b);

def trim: sub("^\\s+"; "") | sub("\\s+$"; "");

def repeatstr($n):
	explode as $chars
	| reduce range(0; $n) as $_ ([];
		. += $chars
	)
	| implode
	;

def repeatstr($n; $sep):
	explode as $chars
	| ($sep | explode) as $sep_chars
	| reduce range(0; $n) as $i ([];
		if $i > 0 then
			. += $sep_chars + $chars
		else
			. += $chars
		end
	)
	| implode
	;

def left_pad($new_len; $c):
	length as $curr_len
	| assert($c | length == 1; "Invalid pad string: \($c)")
	| ($c | repeatstr($new_len - $curr_len)) + .
	;

def skip($sub):
	.[0] as $str
	| .[1] as $idx
	| ($sub | length) as $l
	| ($str | length) as $L
	| $idx
	| until(. + $l > $L or $str[.:. + $l] != $sub;
		. + $l
	)
	;

def hamming_dist:
	(.[0] | explode) as $first
	| (.[1] | explode) as $second
	| ($first | length) as $n
	| assert(($second | length) == $n; "Invalid input to hamming_dist: \(.)")
	| reduce range(0; $n) as $idx (0;
		if $first[$idx] == $second[$idx] then .  else . + 1 end
	)
	;

def enumerate: [[range(0; length)], .] | transpose;
def unenumerate: map(.[1]);

def solve_quadratic($a; $b; $c):
	($b * $b - 4 * $a * $c) as $d
	| if $d < 0 then
		[]
	else
		[
			(-$b - ($d|sqrt)) / (2*$a),
			(-$b + ($d|sqrt)) / (2*$a)
		]
		| sort
	end
	;

def fit_quadratic_3_points:
	.[0][0] as $x1
	| .[0][1] as $y1
	| .[1][0] as $x2
	| .[1][1] as $y2
	| .[2][0] as $x3
	| .[2][1] as $y3
	| (($x1 - $x2) * ($x1 - $x3) * ($x2 - $x3)) as $d
	| (($x3 * ($y2 - $y1) + $x2 * ($y1 - $y3) + $x1 * ($y3 - $y2)) / $d) as $a
	| (($x3 * $x3 * ($y1 - $y2) + $x2 * $x2 * ($y3 - $y1) + $x1 * $x1 * ($y2 - $y3)) / $d) as $b
	| (($x2 * $x3 * ($x2 - $x3) * $y1 + $x3 * $x1 * ($x3 - $x1) * $y2 + $x1 * $x2 * ($x1 - $x2) * $y3) / $d) as $c
	| [$a, $b, $c]
	;

def eval_quadratic($abc): $abc[0] * . * . + $abc[1] * . + $abc[2];

def gcd($i; $j):
	[$i, $j]
	| until(.[1] == 0;
		.[1] as $old
		| .[1] = .[0] % .[1]
		| .[0] = $old
	)
	| .[0]
	;

def lcm:
	reduce .[] as $i (1;
		. = (. * $i) / gcd(.; $i)
	)
	;

def all_same:
	if length == 0 then
		true
	else
		.[0] as $first
		| all(. == $first)
	end
	;

def sums:
	. as $seq
	| if is_empty then
		[]
	else
		reduce range(1; length) as $i ([.[0]];
			. += [.[-1] + $seq[$i]]
		)
	end
	;

def diffs:
	. as $seq
	| reduce range(1; length) as $idx ([];
		. += [$seq[$idx] - $seq[$idx-1]]
	)
	;

def find_if(p):
	label $done
	| foreach .[] as $x (-1; . + 1;
		if ($x | p) then
			., break $done
		else
			empty
		end
	) // -1
	;

def find_min_by(f):
	. as $xs
	| reduce range(length) as $i ([-1, null];
		($xs[$i] | f) as $val
		| if .[0] < 0 or $val < .[1] then
			[$i, $val]
		else
			.
		end
	)
	| .[0]
	;

def find_min: find_min_by(.);

def find_max_by(f):
	. as $xs
	| reduce range(length) as $i ([-1, null];
		($xs[.] | f) as $val
		| if .[0] < 0 or $val > .[1] then
			[$i, $val]
		else
			.
		end
	)
	| .[0]
	;

def find_max: find_max_by(.);

def swap($i; $j):
	.[$i] as $tmp
	| .[$i] = .[$j]
	| .[$j] = $tmp
	;

def pop: . |= .[0:-1];

def swap_and_pop($i):
	.[$i] = .[-1]
	| pop
	;

def pop_front: . |= .[1:];

def range_pairs($begin; $end):
	range($begin; $end)
	| . as $first
	| range(($first + 1); $end) as $rest
	| $rest
	| [$first, .]
	;

def pairs:
	. as $vals
	| range_pairs(0; length)
	| [$vals[.[0]], $vals[.[1]]]
	;

def partition:
	reduce .[] as $x ([];
		if is_empty or .[-1][0] != $x then
			. += [[$x]]
		else
			.[-1] += [$x]
		end
	)
	;

def partition_by(f):
	reduce .[] as $raw ([];
		($raw | f) as $x
		| if is_empty then
			. += [[$raw]]
		elif (.[-1][0] | f) != $x then
			. += [[$raw]]
		else
			.[-1] += [$raw]
		end
	)
	;

def range_partition:
	reduce .[] as $x ([];
		if is_empty or $x - .[-1][1] > 0 then
			. += [[$x, $x + 1]]
		else
			.[-1][1] += 1
		end
	)
	;

def in_range($range):
	assert($range | length == 2; "Invalid range given to in_range: \($range)")
	| . >= $range[0] and . < $range[1]
	;

def range_intersect_inclusive($other):
	[
		max(.[0]; $other[0]),
		min(.[1]; $other[1])
	]
	| if .[0] > .[1] then [] else . end
	;

def polyarea:
	. as $points
	| length as $n
	| reduce range($n) as $i (0;
		$points[$i] as $p
		| $points[($i + 1) % $n] as $q
		| . + $p[0] * $q[1] - $q[0] * $p[1]
	)
	| . / 2
	;
