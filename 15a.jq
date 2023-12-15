include "util";

def HASH:
	reduce explode[] as $char (0;
		. = ((. + $char) * 17) % 256
	)
	;

trim
| split(",")
| map(
	HASH
)
| add
