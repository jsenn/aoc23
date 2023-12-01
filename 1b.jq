# invoke with jq -R -s -f <this file> <input file>

include "util";

def normdig:
	{
		"one": "1",
		"two": "2",
		"three": "3",
		"four": "4",
		"five": "5",
		"six": "6",
		"seven": "7",
		"eight": "8",
		"nine": "9",
	}[.] // .;
	
def firstdig: match("\\d|one|two|three|four|five|six|seven|eight|nine").string | normdig;
def lastdig: revstr | match("\\d|eno|owt|eerht|ruof|evif|xis|neves|thgie|enin").string | revstr | normdig;

split("\n")
| map(firstdig + lastdig | tonumber)
| add
