include "util";

def Grid($nrows; $ncols):
	assert($nrows * $ncols == length; "Can't create \($nrows)x\($ncols) grid from \(length) values")
	| {"nrows": $nrows, "ncols": $ncols, "vals": .}
	;

def i2rc($i): [div($i; .ncols), $i % .ncols];
def rc2i($rc): $rc[0] * .ncols + $rc[1];
def valid_rc($rc): $rc[0] >= 0 and $rc[0] < .nrows and $rc[1] >= 0 and $rc[1] < .ncols;

def from_rows:
	length as $nrows
	| (.[0] | length) as $ncols
	| flatten
	| Grid($nrows; $ncols)
	;

def parse: lines | map(explode) | from_rows;

def to_rows:
	. as $grid
	| reduce range(0; .nrows) as $row_idx ([];
		($row_idx * $grid.ncols) as $row_start
		| ($row_start + $grid.ncols) as $row_end
		| . += [$grid.vals[$row_start:$row_end]]
	)
	;

def to_cols: to_rows | transpose;

def subgrid($min; $max):
	. as $grid
	| reduce range($min[0]; $max[0]) as $row ([];
		($grid | rc2i([$row, $min[1]])) as $start
		| ($grid | rc2i([$row, $max[1]])) as $end
		| . + $grid.vals[$start:$end]
	)
	| Grid($max[0] - $min[0]; $max[1] - $min[1])
	;

def filled($val; $nrows; $ncols):
	$val | repeatn($nrows * $ncols)
	| Grid($nrows; $ncols)
	;

def zeros($nrows; $ncols): filled(0; $nrows; $ncols);

def transpose: to_cols | from_rows;

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
	to_rows
	| map(
		map(if . then "1" else "0" end)
		| join("")
	)
	| join("\n")
	;

def pprint:
	. as $grid
	| (.vals | map(tostring)) as $str_vals
	| ($str_vals | map(length) | max) as $max_len
	| $str_vals
	| map(
		left_pad($max_len; " ")
	)
	| Grid($grid.nrows; $grid.ncols)
	| to_rows
	| if $max_len == 1 then
		map(join(""))
	else
		map(join(" "))
	end
	| join("\n")
	;

def dir_from($rc): [.[0] - $rc[0], .[1] - $rc[1]];
def dir_to($rc): [$rc[0] - .[0], $rc[1] - .[1]];

def top_left_rc: [0, 0];
def top_right_rc: [0, .ncols - 1];
def bottom_left_rc: [.nrows - 1, 0];
def bottom_right_rc: [.nrows - 1, .ncols - 1];

def _bounds_check($rc): assert(valid_rc($rc); "Invalid grid access: \($rc)");

def get($rc):
	_bounds_check($rc)
	| rc2i($rc) as $idx
	| .vals[$idx]
	;

def get_from($grid):
	. as $rc
	| $grid
	| get($rc)
	;

def set($rc; $val):
	_bounds_check($rc)
	| rc2i($rc) as $idx
	| .vals[$idx] |= $val
	;

def update($rc; expr):
	get($rc) as $old
	| set($rc; ($old | expr))
	;

def is_edge($rc): $rc[0] == 0 or $rc[1] == 0 or $rc[0] == .nrows - 1 or $rc[1] == .ncols - 1;

def find_rc($elem):
	(.vals | index($elem)) as $found_idx
	| if $found_idx >= 0 then i2rc($found_idx) else null end
	;

def colrange($colbegin; $colend):
	. as $row
	| ($colend - $colbegin) as $count
	| [($row | repeatn($count)), [range($colbegin; $colend)]] | transpose
	;

def neumann_rc($rc):
	. as $grid
	| [
		[($rc[0] - 1), ($rc[1] + 0)],
		[($rc[0] + 0), ($rc[1] - 1)],
		[($rc[0] + 0), ($rc[1] + 1)],
		[($rc[0] + 1), ($rc[1] + 0)]
	]
	| map(select(
		. as $rc
		| $grid
		| valid_rc($rc)
	))
	;

def moore_rc($rc):
	. as $grid
	| [
		[($rc[0] - 1), ($rc[1] - 1)],
		[($rc[0] - 1), ($rc[1] + 0)],
		[($rc[0] - 1), ($rc[1] + 1)],
		[($rc[0] + 0), ($rc[1] - 1)],
		[($rc[0] + 0), ($rc[1] + 1)],
		[($rc[0] + 1), ($rc[1] - 1)],
		[($rc[0] + 1), ($rc[1] + 0)],
		[($rc[0] + 1), ($rc[1] + 1)]
	]
	| map(select(
		. as $rc
		| $grid
		| valid_rc($rc)
	))
	;

def dilate:
	. as $grid
	| moore_neighbourhoods.vals
	| map(any)
	| Grid($grid.nrows; $grid.ncols)
	;

def flood_fill($start):
	{
		"q": [$start],
		"grid": .
	}
	| until(.q | is_empty;
		.q.[-1] as $curr
		| .q |= pop
		| if (.grid | get($curr)) == 0 then
			.grid |= set($curr; 1)
			| .q += (.grid | neumann_rc($curr))
		end
	)
	| .grid
	;

def manhattan_dist($q):
	(.[0] - $q[0] | abs) as $rowdiff
	| (.[1] - $q[1] | abs) as $coldiff
	| $rowdiff + $coldiff
	;
