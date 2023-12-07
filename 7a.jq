include "util";

def parse_input:
	lines
	| map(
		split(" ")
		| [(.[0] | split("")), (.[1] | tonumber)]
	)
	;

def arrange_hand:
	group_by(.)
	| map(length)
	| sort
	| reverse
	;

def kind_score:
	. as $hand
	| arrange_hand
	| if .[0] == 5 then # 5 of a kind
		6
	elif .[0] == 4 then # 4 of a kind
		5
	elif .[0] == 3 and .[1] == 2 then # full house
		4
	elif .[0] == 3 then # 3 of a kind
		3
	elif .[0] == 2 and .[1] == 2 then # 2 pair
		2
	elif .[0] == 2 then # 1 pair
		1
	else # high card
		assert(length == 5; "Invalid card ranking: \($hand)")
		| 0
	end
	;

def card_score:
	. as $card
	| [
		"2",
		"3",
		"4",
		"5",
		"6",
		"7",
		"8",
		"9",
		"T",
		"J",
		"Q",
		"K",
		"A"
	] | index($card)
	;

def strength: [kind_score] + map(card_score);

parse_input
| map([
	(.[0] | strength),
	.[1],
	.[0]
])
| sort_by(.[0])
| map(.[1])
| enumerate
| map((.[0] + 1) * .[1])
| add
