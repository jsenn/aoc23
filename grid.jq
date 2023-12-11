include "util";

def Grid($nrows; $ncols):
	assert($nrows * $ncols == length; "Can't create \($nrows)x\($ncols) grid from \(length) values")
	| {"nrows": $nrows, "ncols": $ncols, "vals": .}
	;

def from_rows:
	length as $nrows
	| (.[0] | length) as $ncols
	| flatten
	| Grid($nrows; $ncols)
	;

def to_rows:
	. as $grid
	| reduce range(0; .nrows) as $row_idx ([];
		($row_idx * $grid.ncols) as $row_start
		| ($row_start + $grid.ncols) as $row_end
		| . += [$grid.vals[$row_start:$row_end]]
	)
	;

def to_cols: to_rows | transpose;

def zeros($nrows; $ncols):
	0 | repeatn($nrows * $ncols)
	| Grid($nrows; $ncols)
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

def i2rc($grid): [div(.; $grid.ncols), . % $grid.ncols];
def rc2i($grid): .[0] * $grid.ncols + .[1];
def valid_rc($grid): .[0] >= 0 and .[0] < $grid.nrows and .[1] >= 0 and .[1] < $grid.ncols;

def get($grid):
	assert(valid_rc($grid); "Invalid grid access: \(.)")
	| rc2i($grid) as $idx
	| $grid.vals[$idx]
	;

def update($grid; expr):
	assert(valid_rc($grid); "Invalid grid access: \(.)")
	| rc2i($grid) as $i
	| get($grid) as $old
	| $grid.vals | .[$i] |= ($old | expr)
	;

def is_edge($grid): .[0] == 0 or .[1] == 0 or .[0] == $grid.nrows - 1 or .[1] == $grid.ncols - 1;

def find_rc($elem):
	. as $grid
	| .vals
	| index($elem)
	| if . >= 0 then i2rc($grid) else null end
	;

def colrange($colbegin; $colend):
	. as $row
	| ($colend - $colbegin) as $count
	| [($row | repeatn($count)), [range($colbegin; $colend)]] | transpose
	;

def neumann_rc($grid):
	[
		[(.[0] - 1), (.[1] + 0)],
		[(.[0] + 0), (.[1] - 1)],
		[(.[0] + 0), (.[1] + 1)],
		[(.[0] + 1), (.[1] + 0)]
	]
	| map(select(valid_rc($grid)))
	;

def moore_rc($grid):
	[
		[(.[0] - 1), (.[1] - 1)],
		[(.[0] - 1), (.[1] + 0)],
		[(.[0] - 1), (.[1] + 1)],
		[(.[0] + 0), (.[1] - 1)],
		[(.[0] + 0), (.[1] + 1)],
		[(.[0] + 1), (.[1] - 1)],
		[(.[0] + 1), (.[1] + 0)],
		[(.[0] + 1), (.[1] + 1)]
	]
	| map(select(valid_rc($grid)))
	;

def moore_neighbourhoods:
	. as $grid
	| enumerate_rc
	| map(
		moore_rc
		| get($grid)
	)
	| Grid($grid.nrows; $grid.ncols)
	;

def dilate:
	. as $grid
	| moore_neighbourhoods.vals
	| map(any)
	| Grid($grid.nrows; $grid.ncols)
	;

