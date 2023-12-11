# Pass expansion factor using --argjson EXPANSION <val>
include "util";
import "grid" as grid;

def parse_input:
	lines
	| map(split(""))
	| grid::from_rows
	;

def expansion: if any(. == "#") then 1 else $EXPANSION end;

def galaxy_dist($row_sums; $col_sums):
	$row_sums[.[0][0]] as $row0
	| $row_sums[.[1][0]] as $row1
	| (($row1 - $row0) | abs) as $rowdiff
	| $col_sums[.[0][1]] as $col0
	| $col_sums[.[1][1]] as $col1
	| (($col1 - $col0) | abs) as $coldiff
	| $rowdiff + $coldiff
	;

parse_input
| . as $grid
| (grid::to_rows | map(expansion) | sums) as $row_sums
| (grid::to_cols | map(expansion) | sums) as $col_sums
| grid::enumerate_rc
| map(select(.[2] == "#"))
| [pairs | galaxy_dist($row_sums; $col_sums)]
| add
