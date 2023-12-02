def nonempty: length > 0;
def lines: split("\n") | map(select(nonempty));
def revstr: explode | reverse | implode;

def mul: reduce .[] as $x (1; . * $x);
