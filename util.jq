def nonempty: length > 0;
def lines: split("\n") | map(select(nonempty));
def revstr: explode | reverse | implode;
