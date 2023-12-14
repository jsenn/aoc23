import re
import functools

def parse_input(fpath):
    lines = []
    with open(fpath) as f:
        for line in f:
            lines.append(line)
    for i in range(len(lines)):
        line = lines[i]
        pattern, number_string = line.split(" ")
        pattern = '?'.join([pattern]*5)
        number_string = ','.join([number_string]*5)
        numbers = [int(s) for s in re.findall(r"\d+", number_string)]
        lines[i] = [pattern, numbers]
    return lines

@functools.cache
def possible_arrangements(s, groups):
    N = len(s)
    G = len(groups)
    if N == 0 or G == 0:
        return []
    group_total = sum(groups) + G - 1
    #ret = []
    ret = 0
    i = 0
    while i <= N - group_total:
        c = s[i]
        if c == ".":
            i += 1
        elif c == "?":
            smod = "#" + s[i+1:]
            arrs = possible_arrangements(smod, groups)
            ret += arrs
            """
            for arr in arrs:
                assert(len(arr) == G)
                ret.append([k + i for k in arr])
            """
            i += 1
        else:
            assert(c == "#")
            j = i
            while j < i + groups[0]:
                cj = s[j]
                if cj == ".":
                    return ret
                j += 1
            if j < N and s[j] == "#":
                return ret
            elif j == N:
                #ret.append([i])
                ret += 1
            elif G == 1:
                srest = s[j+1:]
                if srest.find('#') == -1:
                    #ret.append([i])
                    ret += 1
            else:
                tails = possible_arrangements(s[j+1:], groups[1:])
                ret += tails
                """
                for tail in tails:
                    assert(len(tail) == G - 1)
                    ret.append([i] + [k + j + 1 for k in tail])
                """
            return ret
    return ret

if __name__ == "__main__":
    lines = parse_input("12i.txt")
    ret = 0
    i = 0
    for i in range(len(lines)):
        line = lines[i]
        # apparently python can't hash a list but can hash a tuple.
        # The function is memoized so the inputs have to be hashable,
        # so we convert the groups to a tuple.
        ret += possible_arrangements(line[0], tuple(line[1]))
    print(ret)

