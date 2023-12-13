include "util";

def parse_input:
	split("\n\n")
	| map(
		lines
	)
	;

def refl($mirror_low):
	($mirror_low - .) as $diff
	| $mirror_low + 1 + $diff
	;

def is_mirror($rows; $smudge_row):
	. as $mirror_low
	| ($rows | length) as $nrows
	| if $mirror_low < div($nrows; 2) then
		[range(0; $mirror_low)]
	else
		[range($mirror_low; $nrows)]
	end
	| all(
		. as $idx
		| ($idx | refl($mirror_low)) as $refl_idx
		| ($idx == $smudge_row)
		or ($refl_idx == $smudge_row)
		or ($rows[$idx] == $rows[$refl_idx])
	)
	;

def find_mirror:
	. as $rows
	| enumerate
	| [pairs]
	| map(
		select(map(.[1]) | hamming_dist == 1)
		| .[0][0] as $first_row
		| .[1][0] as $second_row
		| select(($second_row - $first_row) % 2 == 1)
		| div($first_row + $second_row; 2) as $mid
		| $mid
		| select($mid | is_mirror($rows; $first_row))
	)
	| if length > 0 then
		assert(length == 1; "Multiple mirrors found: \(.)")
		| .[0] + 1
	else
		null
	end
	;

parse_input
| map(
	find_mirror as $hmirror
	| if $hmirror != null then
		100 * $hmirror
	else
		(map(explode) | transpose | map(implode)) as $cols
		| ($cols | find_mirror) as $vmirror
		| assert($vmirror != null; "No mirror found")
		| $vmirror
	end
)
| add
