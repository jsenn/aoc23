def nonempty: length > 0;
def lines: split("\n") | map(select(nonempty));
def revstr: explode | reverse | implode;

def mul: reduce .[] as $x (1; . * $x);

def is_digit: . >= 48 and . <= 57;
def is_dot: . == 46;

def assert(cond): if cond|not then ("Assertion failure" | halt_error) end;

def repeatn(n):
	. as $val
	| [range(0; n)] | map($val)
	;

def intersect_with($b): . - (. - $b);

def trim: sub("^\\s+"; "") | sub("\\s+$"; "");

def enumerate: [[range(0; length)], .] | transpose;
