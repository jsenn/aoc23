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

def is_mirror($rows):
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
		| $rows[$idx] == $rows[$refl_idx]
	)
	;

def find_mirror:
	. as $rows
	| enumerate
	| partition_by(.[1])
	| map(
		select(length > 1)
		| map(
			.[0]
			| select(is_mirror($rows))
		)
	)
	| flatten
	| if length > 0 then
		assert(length == 1; "Invalid mirror found")
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
