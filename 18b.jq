include "util";

def parse_dir:
	if . == "0" then
		"R"
	elif . == "1" then
		"D"
	elif . == "2" then
		"L"
	else
		assert(. == "3"; "Invalid dir: \(.)")
		| "U"
	end
	;

def parse_input:
	lines
	| map(
		split(" ")
		| [
			(.[2][-2:-1] | parse_dir),
			(.[2][2:-2] | hextonumber)
		]
	)
	;

def walk_points:
	reduce .[] as $instr ([];
		(.[-1] // [0, 0]) as $prev
		| $instr[0] as $dir
		| $instr[1] as $length
		| if $dir == "U" then
			. + [[$prev[0], $prev[1] + $length]]
		elif $dir == "D" then
			. + [[$prev[0], $prev[1] - $length]]
		elif $dir == "R" then
			. + [[$prev[0] + $length, $prev[1]]]
		elif $dir == "L" then
			. + [[$prev[0] - $length, $prev[1]]]
		else
			assert(false; "Invalid dir: \($dir)")
		end
	)
	;

def count_boundary:
	. as $points
	| length as $n
	| reduce range($n) as $i (0;
		$points[$i] as $p
		| $points[($i + 1) % $n] as $q
		| if $p[0] == $q[0] then
			. + ($p[1] - $q[1] | abs)
		else
			assert($p[1] == $q[1]; "Invalid edge: \($p)->\($q)")
			| . + ($p[0] - $q[0] | abs)
		end
	)
	;

# This uses Pick's Theorem, which is a very cool result
parse_input
| walk_points
| (reverse | polyarea) as $A
| count_boundary as $b
| ($A - $b/2 - 1) as $i
| $i + $b + 2
