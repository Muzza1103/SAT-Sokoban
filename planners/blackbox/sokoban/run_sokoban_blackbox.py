import os
import sys
import re
import time
import shutil
import subprocess
import resource
from collections import deque

DEFAULT_DOMAIN_FILE = "domain_blackbox.pddl"

# Put blackbox path
FALLBACK_BLACKBOX = os.path.expanduser("~/planners/blackbox/blackbox")

# Blackbox options
BLACKBOX_INFO_LEVEL = "1"       
BLACKBOX_NOOPT = True           
BLACKBOX_MAXAUTO = 250           #increased search limit 
BLACKBOX_MAX_GLOBAL_SEC = None   



def parse_problem(filename):
    with open(filename, "r") as f:
        text = f.read()

    cells = sorted(set(re.findall(r'\bc\d+\b', text)), key=lambda x: int(x[1:]))

    player_match = re.search(r'\(at-player\s+\w+\s+(c\d+)\)', text)
    if not player_match:
        print("ERROR: Player position not found.")
        sys.exit(1)
    player_pos = player_match.group(1)

    if "(:init" not in text:
        print("ERROR: No (:init ...) section found.")
        sys.exit(1)

    init_section = text.split("(:init", 1)[1]
    init_section = init_section.split("(:goal", 1)[0] if "(:goal" in init_section else init_section

    boxes = dict(re.findall(r'\(at-box\s+(\w+)\s+(c\d+)\)', init_section))

    goals = []
    goal_box_map = {}

    if "(:goal" in text:
        goal_section = text.split("(:goal", 1)[1]

        goals = re.findall(r'\(goal\s+(c\d+)\)', goal_section)

        pairs = re.findall(r'\(at-box\s+(\w+)\s+(c\d+)\)', goal_section)
        if pairs:
            goal_box_map = dict(pairs)
            if not goals:
                goals = [c for _, c in pairs]

    if not goals:
        print("ERROR: No goals found in PDDL file.")
        sys.exit(1)

    walls = set(re.findall(r'\(wall\s+(c\d+)\)', text))

    adj = {"right": [], "left": [], "up": [], "down": []}

    for a, b in re.findall(r'\(adj-right\s+(c\d+)\s+(c\d+)\)', text):
        adj["right"].append((a, b))
        adj["left"].append((b, a))

    for a, b in re.findall(r'\(adj-down\s+(c\d+)\s+(c\d+)\)', text):
        adj["down"].append((a, b))
        adj["up"].append((b, a))

    return cells, player_pos, boxes, goals, goal_box_map, walls, adj



def build_coordinates(cells, adj):
    coords = {}
    q = deque()

    start = cells[0]
    coords[start] = (0, 0)
    q.append(start)

    directions = {
        "right": (1, 0),
        "left": (-1, 0),
        "down": (0, 1),
        "up": (0, -1),
    }

    while q:
        cur = q.popleft()
        x, y = coords[cur]
        for d, (dx, dy) in directions.items():
            for c_from, c_to in adj[d]:
                if c_from == cur and c_to not in coords:
                    coords[c_to] = (x + dx, y + dy)
                    q.append(c_to)

    return coords



def display_grid(step, coords, player, boxes, goals, walls):
    print(f"\nStep {step}")

    xs = [coords[c][0] for c in coords]
    ys = [coords[c][1] for c in coords]
    min_x, max_x = min(xs), max(xs)
    min_y, max_y = min(ys), max(ys)

    width = max_x - min_x + 1
    height = max_y - min_y + 1

    grid = [["#" for _ in range(width)] for _ in range(height)]

    for cell, (x, y) in coords.items():
        grid[y - min_y][x - min_x] = "."

    for cell in walls:
        if cell in coords:
            x, y = coords[cell]
            grid[y - min_y][x - min_x] = "#"

    goals_set = set(goals)
    for g in goals_set:
        if g in coords:
            x, y = coords[g]
            gx, gy = x - min_x, y - min_y
            if grid[gy][gx] != "#":
                grid[gy][gx] = "G"

    for box_pos in boxes.values():
        if box_pos in coords:
            x, y = coords[box_pos]
            gx, gy = x - min_x, y - min_y
            grid[gy][gx] = "*" if box_pos in goals_set else "B"

    if player in coords:
        x, y = coords[player]
        gx, gy = x - min_x, y - min_y
        grid[gy][gx] = "+" if player in goals_set else "P"

    for row in grid:
        print(" ".join(row))
    print("-" * 40)



def resolve_blackbox():
    if shutil.which("blackbox"):
        return "blackbox"
    if os.path.exists(FALLBACK_BLACKBOX):
        return FALLBACK_BLACKBOX
    return None


def run_blackbox_stdout(domain_file, problem_file):
    bb = resolve_blackbox()
    if not bb:
        print("ERROR: blackbox binary not found.")
        print("Put it in PATH or at:", FALLBACK_BLACKBOX)
        sys.exit(1)

    cmd = [
        bb,
        "-o", domain_file,
        "-f", problem_file,
        "-i", BLACKBOX_INFO_LEVEL,
        "-maxauto", str(BLACKBOX_MAXAUTO),
    ]

    if BLACKBOX_NOOPT:
        cmd.append("-noopt")
    if BLACKBOX_MAX_GLOBAL_SEC is not None:
        cmd += ["-maxglobalsec", str(BLACKBOX_MAX_GLOBAL_SEC)]

    t0 = time.perf_counter()
    r0 = resource.getrusage(resource.RUSAGE_CHILDREN)
    p = subprocess.run(cmd, capture_output=True, text=True)
    t1 = time.perf_counter()
    r1 = resource.getrusage(resource.RUSAGE_CHILDREN)

    mem_kb = max(r0.ru_maxrss, r1.ru_maxrss)
    out = (p.stdout or "") + ("\n" + p.stderr if p.stderr else "")

    runtime = {
        "time_s": (t1 - t0),
        "memory_kb": mem_kb,
        "exit_code": p.returncode,
    }
    return out, runtime


def parse_plan_from_output(output):
    actions = []
    max_time = None

    for raw in output.splitlines():
        line = raw.strip()
        if not line:
            continue

        tm = re.search(r';\s*time\s+(\d+)', line, re.IGNORECASE)
        if tm:
            t = int(tm.group(1))
            max_time = t if max_time is None else max(max_time, t)
            continue

        m = re.search(r'\(([^()]+)\)', line)
        if not m:
            continue

        inside = m.group(1).strip().replace(",", " ")
        parts = [p for p in inside.split() if p]
        if not parts:
            continue

        act = parts[0].lower()
        params = parts[1:]

        if act.startswith("move-") or act.startswith("push-"):
            actions.append((act, params))

    horizon = (max_time + 1) if max_time is not None else len(actions)
    return actions, horizon


def apply_action(action, params, player, boxes):
    if action.startswith("move-") and len(params) >= 3:
        player = params[2]
        return player, boxes

    if action.startswith("push-") and len(params) >= 5:
        box_name = params[1]
        player = params[3]
        boxes[box_name] = params[4]
        return player, boxes

    return player, boxes


def goal_reached(current_boxes, goals, goal_box_map):
    if goal_box_map:
        return all(current_boxes.get(b) == c for b, c in goal_box_map.items())
    goals_set = set(goals)
    return all(pos in goals_set for pos in current_boxes.values())


def get_cnf_stats(domain_file, problem_file, horizon):
    bb = resolve_blackbox()
    if not bb or horizon <= 0:
        return "?", "?"

    cmd = [bb, "-o", domain_file, "-f", problem_file, "-t", str(horizon),
           "-printcnf", "-printexit", "-i", "0"]
    p = subprocess.run(cmd, capture_output=True, text=True)

    cnf_text = (p.stdout or "")
    if "p cnf" not in cnf_text and p.stderr:
        cnf_text += "\n" + p.stderr

    m = re.search(r'^\s*p\s+cnf\s+(\d+)\s+(\d+)\s*$', cnf_text, re.MULTILINE)
    if not m:
        return "?", "?"
    return m.group(1), m.group(2)


def kb_to_gb(kb):
    return kb / (1024 * 1024)


if __name__ == "__main__":
    if len(sys.argv) not in (2, 3):
        print("Usage: python3 run_sokoban_blackbox.py problem.pddl [domain.pddl]")
        sys.exit(1)

    problem_file = sys.argv[1]
    problem_name = os.path.basename(problem_file)
    domain_file = sys.argv[2] if len(sys.argv) == 3 else DEFAULT_DOMAIN_FILE

    print("Parsing problem...\n")
    cells, player_pos, boxes_init, goals, goal_box_map, walls, adj = parse_problem(problem_file)
    coords = build_coordinates(cells, adj)

    print("Initial state:")
    display_grid(0, coords, player_pos, boxes_init, goals, walls)

    print("\nRunning Blackbox...\n")
    output, runtime = run_blackbox_stdout(domain_file, problem_file)

    actions, horizon = parse_plan_from_output(output)

    if not actions:
        print("No plan found (or couldn't parse plan from output).")
        plan_len = 0
    else:
        plan_len = len(actions)
        print(f"Plan found! ({plan_len} actions, horizon={horizon})\n")

        player = player_pos
        current_boxes = boxes_init.copy()
        step = 1
        for act, params in actions:
            player, current_boxes = apply_action(act, params, player, current_boxes)
            display_grid(step, coords, player, current_boxes, goals, walls)
            step += 1

        if goal_reached(current_boxes, goals, goal_box_map):
            print("Goal reached!\n")

    sat_vars, sat_clauses = get_cnf_stats(domain_file, problem_file, horizon if horizon else 0)
    mem_gb = kb_to_gb(runtime["memory_kb"]) if runtime["memory_kb"] else 0.0

    print("===== BLACKBOX SAT STATISTICS =====")
    print("Problem        :", problem_name)
    print("Horizon length :", horizon if horizon else "?")
    print("Plan actions   :", plan_len)
    print("SAT variables  :", sat_vars)
    print("SAT clauses    :", sat_clauses)
    print("BB total time  :", f"{runtime['time_s']:.3f}")
    print("BB memory (GB) :", f"{mem_gb:.3f}")
    print("Exit code      :", runtime["exit_code"])
    print("===================================")