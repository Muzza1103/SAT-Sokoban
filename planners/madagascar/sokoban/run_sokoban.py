import os
import sys
import subprocess
import re
from collections import deque

DOMAIN_FILE = "domain.pddl"

# Put path to madagascar binary
MP_BIN = "../Mp"

COMPUTE_CLAUSES_VIA_DIMACS = True
DIMACS_PREFIX = "__mada_cnf" 


# PARSE PDDL
def parse_problem(filename):
    with open(filename, "r") as f:
        text = f.read()

    # CELLS
    cells = re.findall(r'\bc\d+\b', text)
    cells = sorted(set(cells), key=lambda x: int(x[1:]))

    # PLAYER
    player_match = re.search(r'\(at-player\s+\w+\s+(c\d+)\)', text)
    if not player_match:
        print("ERROR: Player position not found.")
        sys.exit(1)
    player_pos = player_match.group(1)

    # BOXES (INIT ONLY)
    init_section = text.split("(:init")[1].split("(:goal")[0]
    boxes = dict(re.findall(r'\(at-box\s+(\w+)\s+(c\d+)\)', init_section))

    # GOALS
    goals = re.findall(r'\(goal\s+(c\d+)\)', text)

    if not goals and "(:goal" in text:
        goal_section = text.split("(:goal")[1]
        goals = re.findall(r'\(at-box\s+\w+\s+(c\d+)\)', goal_section)

    if not goals:
        print("ERROR: No goals found in PDDL file.")
        sys.exit(1)

    # WALLS
    walls = set(re.findall(r'\(wall\s+(c\d+)\)', text))

    # ADJACENCY
    adj = {"right": [], "left": [], "up": [], "down": []}

    for a, b in re.findall(r'\(adj-right\s+(c\d+)\s+(c\d+)\)', text):
        adj["right"].append((a, b))
        adj["left"].append((b, a))

    for a, b in re.findall(r'\(adj-down\s+(c\d+)\s+(c\d+)\)', text):
        adj["down"].append((a, b))
        adj["up"].append((b, a))

    return cells, player_pos, boxes, goals, walls, adj


# BUILD GRID COORDINATES
def build_coordinates(cells, adj):
    coords = {}
    queue = deque()

    start = cells[0]
    coords[start] = (0, 0)
    queue.append(start)

    directions = {
        "right": (1, 0),
        "left": (-1, 0),
        "down": (0, 1),
        "up": (0, -1),
    }

    while queue:
        current = queue.popleft()
        x, y = coords[current]

        for direction in directions:
            for (c_from, c_to) in adj[direction]:
                if c_from == current and c_to not in coords:
                    dx, dy = directions[direction]
                    coords[c_to] = (x + dx, y + dy)
                    queue.append(c_to)

    return coords


# DISPLAY GRID
def display_grid(step, coords, player, boxes, goals, walls):
    print(f"\nStep {step}")

    xs = [coords[c][0] for c in coords]
    ys = [coords[c][1] for c in coords]

    min_x, max_x = min(xs), max(xs)
    min_y, max_y = min(ys), max(ys)

    width = max_x - min_x + 1
    height = max_y - min_y + 1

    grid = [["#" for _ in range(width)] for _ in range(height)]

    # Open cells
    for cell, (x, y) in coords.items():
        gx = x - min_x
        gy = y - min_y
        grid[gy][gx] = "."

    # Walls
    for cell in walls:
        if cell in coords:
            x, y = coords[cell]
            gx = x - min_x
            gy = y - min_y
            grid[gy][gx] = "#"

    # Goals
    for goal in goals:
        if goal in coords:
            x, y = coords[goal]
            gx = x - min_x
            gy = y - min_y
            grid[gy][gx] = "G"

    # Boxes
    for box_pos in boxes.values():
        if box_pos in coords:
            x, y = coords[box_pos]
            gx = x - min_x
            gy = y - min_y

            if box_pos in goals:
                grid[gy][gx] = "*"
            else:
                grid[gy][gx] = "B"

    # Player
    if player in coords:
        x, y = coords[player]
        gx = x - min_x
        gy = y - min_y

        if player in goals:
            grid[gy][gx] = "+"
        else:
            grid[gy][gx] = "P"

    for row in grid:
        print(" ".join(row))

    print("-" * 40)


# RUN MADAGASCAR
def run_solver(problem_file, extra_args=None):
    cmd = [MP_BIN]
    if extra_args:
        cmd += extra_args
    cmd += [DOMAIN_FILE, problem_file]

    result = subprocess.run(cmd, capture_output=True, text=True)
    return (result.stdout or "") + ("\n" + result.stderr if result.stderr else "")


# EXTRACT PLAN
def extract_plan(output):
    plan = []
    for line in output.splitlines():
        if line.startswith("STEP"):
            action = line.split(":")[1].strip()
            plan.append(action)
    return plan


# EXTRACT STATS
def extract_stats(output):
    stats = {}

    # Horizon + variables
    horizons = re.findall(r'Horizon\s+(\d+):\s+(\d+)\s+variables', output)
    if horizons:
        last_horizon, last_vars = horizons[-1]
        stats["horizon"] = int(last_horizon)
        stats["variables"] = last_vars

    decisions = re.findall(r'\((\d+)\s+decisions', output)
    if decisions:
        stats["decisions"] = decisions[-1]

    conflicts = re.findall(r'(\d+)\s+conflicts', output)
    if conflicts:
        stats["conflicts"] = conflicts[-1]

    time_m = re.search(r'total time\s+([0-9.]+)', output)
    if time_m:
        stats["time"] = time_m.group(1)

    memory_m = re.search(r'total size\s+([0-9.]+\s+(?:MB|GB))', output)
    if memory_m:
        stats["memory"] = memory_m.group(1)

    m_clause = re.findall(r'(\d+)\s+clauses', output, flags=re.IGNORECASE)
    if m_clause:
        stats["clauses"] = m_clause[-1]

    return stats


# GET CLAUSES VIA DIMACS DUMP (-O -b)
def _dimacs_vc_from_file(path):
    with open(path, "r") as f:
        for line in f:
            if line.startswith("p cnf"):
                parts = line.strip().split()
                if len(parts) >= 4:
                    return parts[2], parts[3] 
    return None, None


def get_clauses_via_dimacs(problem_file, horizon):
    """
    Dump DIMACS for a single horizon, read "p cnf V C", then cleanup.
    Returns (vars, clauses) or (None, None) if fails.
    """
    before = set(f for f in os.listdir(".") if f.startswith(DIMACS_PREFIX))

    args = [
        "-O",                 # output DIMACS instead of solving
        "-b", DIMACS_PREFIX, 
        "-F", str(horizon),   # start horizon
        "-T", str(horizon),   
        "-S", "1",           
    ]
    _ = run_solver(problem_file, extra_args=args)

    after = set(f for f in os.listdir(".") if f.startswith(DIMACS_PREFIX))
    created = sorted(list(after - before))

    if not created:
        return None, None

    cnf_files = [f for f in created if f.lower().endswith(".cnf")]
    if cnf_files:
        target = cnf_files[0]
    else:
        target = max(created, key=lambda fn: os.path.getmtime(fn))

    v, c = _dimacs_vc_from_file(target)

    for f in created:
        try:
            os.remove(f)
        except OSError:
            pass

    return v, c



if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python3 run_sokoban.py problem.pddl")
        sys.exit(1)

    problem_file = sys.argv[1]
    problem_name = os.path.basename(problem_file)

    print("========================================")
    print("Problem file :", problem_name)
    print("Domain file  :", DOMAIN_FILE)
    print("========================================\n")

    print("Parsing problem...\n")
    cells, player_pos, boxes, goals, walls, adj = parse_problem(problem_file)
    coords = build_coordinates(cells, adj)

    print("Initial state:")
    display_grid(0, coords, player_pos, boxes, goals, walls)

    print("\nRunning Madagascar...\n")
    output = run_solver(problem_file)

    stats = extract_stats(output)
    plan_length = 0  

    if "PLAN FOUND" not in output:
        print("No plan found.")
    else:
        print("Plan found!\n")
        plan = extract_plan(output)

        plan_length = len(plan)  

        player = player_pos
        current_boxes = boxes.copy()
        step = 1

        for action in plan:
            if "move" in action:
                new_cell = action.split(",")[2].replace(")", "")
                player = new_cell

            if "push" in action:
                parts = action.replace(")", "").split(",")
                box_name = parts[1]
                new_player = parts[3]
                new_box = parts[4]
                player = new_player
                current_boxes[box_name] = new_box

            display_grid(step, coords, player, current_boxes, goals, walls)
            step += 1

        if all(current_boxes[b] in goals for b in current_boxes):
            print("Goal reached!\n")

    # SAT clauses (best-effort)
    clauses = stats.get("clauses", "?")
    if clauses == "?" and COMPUTE_CLAUSES_VIA_DIMACS and "horizon" in stats:
        v, c = get_clauses_via_dimacs(problem_file, stats["horizon"])
        if c:
            clauses = c

    print("===== SAT STATISTICS =====")
    print("Problem        :", problem_name)
    print("Horizon length :", stats.get("horizon", "?"))
    print("Plan steps     :", plan_length if plan_length else "0")
    print("SAT variables  :", stats.get("variables", "?"))
    print("SAT clauses    :", clauses)
    print("Decisions      :", stats.get("decisions", "?"))
    print("Conflicts      :", stats.get("conflicts", "?"))
    print("Total time (s) :", stats.get("time", "?"))
    print("Memory usage   :", stats.get("memory", "?"))
    print("==========================")