include "util";

def Grid($nrows; $ncols):
	assert($nrows * $ncols == length)
	| {"nrows": $nrows, "ncols": $ncols, "vals": .}
	;

def enumerate_rc:
	.nrows as $nrows
	| .ncols as $ncols
	| .vals
	| [foreach .[] as $val (0; . += 1;
		[((.-1) / $ncols | floor), ((.-1) % $ncols, $val)]
	)]
	;

def to_rows:
	. as $grid
	| .vals
	| reduce .[] as $val ([];
		if (.[-1] == null or (.[-1] | length) == $grid.ncols) then
			. += [[$val]]
		else
			.[-1] += [$val]
		end
	)
	;

def print_bin:
	rows
	| map(
		map(if . then "1" else "0" end)
		| join("")
	)
	| join("\n")
	;

def get($grid): $grid.vals[.[0] * $grid.ncols + .[1]];

def colrange($colbegin; $colend):
	. as $row
	| ($colend - $colbegin) as $count
	| [($row | repeatn($count)), [range($colbegin; $colend)]] | transpose
	;

def moore_neighbourhoods:
	. as $grid
	| enumerate_rc
	| map([
		([(.[0] - 1), (.[1] - 1)] | get($grid)),
		([(.[0] - 1), (.[1] + 0)] | get($grid)),
		([(.[0] - 1), (.[1] + 1)] | get($grid)),
		([(.[0] + 0), (.[1] - 1)] | get($grid)),
		([(.[0] + 0), (.[1] + 0)] | get($grid)),
		([(.[0] + 0), (.[1] + 1)] | get($grid)),
		([(.[0] + 1), (.[1] - 1)] | get($grid)),
		([(.[0] + 1), (.[1] + 0)] | get($grid)),
		([(.[0] + 1), (.[1] + 1)] | get($grid))
	] | map(select(. != null)))
	| Grid($grid.nrows; $grid.ncols)
	;

def dilate:
	. as $grid
	| moore_neighbourhoods.vals
	| map(any)
	| Grid($grid.nrows; $grid.ncols)
	;

