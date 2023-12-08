def nonempty: length > 0;
def lines: split("\n") | map(select(nonempty));
def revstr: explode | reverse | implode;

def mul: reduce .[] as $x (1; . * $x);

def is_digit: . >= 48 and . <= 57;
def is_dot: . == 46;

def extract_numbers: [scan("\\d+")] | map(tonumber);

def assert(cond; msg): if cond|not then (msg | halt_error) end;

def repeatn(n):
	. as $val
	| [range(0; n)] | map($val)
	;

def intersect_with($b): . - (. - $b);

def trim: sub("^\\s+"; "") | sub("\\s+$"; "");

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
