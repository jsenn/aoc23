include "util";

def parse_input:
	trim
	| split(",")
	| map(
		match("([a-z]+)([=-])(\\d+)?")
		| .captures
		| {
			"key": .[0].string,
			"op": .[1].string,
			"val": (.[2].string | if . == null then null else tonumber end)
		}
	)
	;

def HASH:
	reduce explode[] as $char (0;
		. = ((. + $char) * 17) % 256
	)
	;

def HASHMAP:
	reduce .[] as $instr (([] | repeatn(256));
		($instr.key | HASH) as $bucket_idx
		| (.[$bucket_idx] | find_if(.[0] == $instr.key)) as $found_idx
		| if $instr.op == "-" then
			if $found_idx != -1 then
				.[$bucket_idx] |= del(.[$found_idx])
			end
		else
			if $found_idx == -1 then
				.[$bucket_idx] += [[$instr.key, $instr.val]]
			else
				.[$bucket_idx][$found_idx] = [$instr.key, $instr.val]
			end
		end
	)
	;

parse_input
| HASHMAP
| enumerate
| map(
	.[0] as $box
	| .[1] as $vals
	| $vals
	| enumerate
	| map(
		.[0] as $slot
		| .[1][1] as $focal_length
		| ($box + 1) * ($slot + 1) * $focal_length
	)
)
| flatten
| add
