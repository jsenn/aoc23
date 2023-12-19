from heapq import *

class Grid:
    def __init__(self, nrows, ncols, vals):
        assert(nrows * ncols == len(vals))
        self.nrows = nrows
        self.ncols = ncols
        self.vals = vals
        
    def valid_rc(self, rc):
        return rc[0] >= 0 and rc[1] >= 0 and rc[0] < self.nrows and rc[1] < self.ncols

    def get_index(self, rc):
        return rc[0] * self.ncols + rc[1]
    
    def get(self, rc):
        return self.vals[self.get_index(rc)]

def parse_input(fpath):
    vals = []
    rows = 0
    with open(fpath) as f:
        for line in f:
            vals += map(int, line.strip())
            rows += 1
    return Grid(rows, len(vals) // rows, vals)

def opposite(dir_a, dir_b):
    return dir_a[0] == -dir_b[0] and dir_a[1] == -dir_b[1]

def get_neighbours(grid, curr_node, curr_cost):
    curr_rc = curr_node[0]
    curr_steps = curr_node[1]
    prev_dir = curr_node[2]
    dirs = [(1, 0), (-1, 0), (0, 1), (0, -1)]
    neighbours = []
    for dir in dirs:
        neighbour_rc = (curr_rc[0] + dir[0], curr_rc[1] + dir[1])
        is_valid =\
            prev_dir is None or (
                not opposite(dir, prev_dir) and
                grid.valid_rc(neighbour_rc) and
                ((dir != prev_dir and curr_steps >= 4) or
                 (dir == prev_dir and curr_steps < 10))
            )
        if is_valid:
            neighbours.append((curr_cost + grid.get(neighbour_rc), (
                neighbour_rc,
                (curr_steps + 1 if dir == prev_dir else 1),
                dir
            )))
    return neighbours

def trace_grid(grid, start, end):
    q = []
    heappush(q, (0, (start, 0, None)))
    visited = set([])
    while len(q) > 0:
        curr_cost, curr_node = heappop(q)
        if curr_node[0] == end:
            return curr_cost
        neighbours = get_neighbours(grid, curr_node, curr_cost)
        for cost, neighbour in neighbours:
            if neighbour in visited: continue
            heappush(q, (cost, neighbour))
            visited.add(neighbour)

if __name__ == "__main__":
    grid = parse_input("17i.txt")
    print(trace_grid(grid, (0, 0), (grid.nrows - 1, grid.ncols - 1)))
