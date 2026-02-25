# SAT-Based Planning for Sokoban

## Overview

This project models **Sokoban in PDDL** and solves it using two SAT-based planners:

- Madagascar
- Blackbox



The Python scripts:
- Execute the planner
- Extract SAT statistics (horizon, variables, clauses, time, conflicts)
- Reconstruct and display the plan step by step

## Requirements

- Linux environment (Ubuntu recommended)
- Python 3
- Madagascar binary compiled for Linux
- Blackbox binary compiled for Linux

This project was tested on Ubuntu (WSL2). It may not work on Windows or macOS without adaptation.

Blackbox may require 32-bit libraries:

```bash
sudo dpkg --add-architecture i386
sudo apt update
sudo apt install libc6:i386 libstdc++6:i386
```

---

## Required Structure

Recommended layout:

planners/
│
├── madagascar/
│   ├── Mp
│   └── sokoban/
│       ├── domain.pddl
│       ├── run_sokoban.py
│       ├── problem5x5_two_boxes.pddl
│       └── ...
│
├── blackbox/
│   ├── blackbox
│   └── sokoban/
│       ├── domain_blackbox.pddl
│       ├── run_sokoban_blackbox.py
│       ├── problem5x5_two_boxes.pddl
│       └── ...

Scripts rely on relative paths.
Make sure to execute them from the corresponding sokoban directory.

---

## Naming Convention

- Files ending with `_ua` correspond to unassigned goal formulations.
- Other files use assigned goal specifications.

### Madagascar

In `run_sokoban.py`:

MP_BIN = "../Mp"

Modify if the binary is located elsewhere.

---

### Blackbox

In `run_sokoban_blackbox.py`:

FALLBACK_BLACKBOX = "/path/to/blackbox"

Modify if necessary.

---

## How to Run

### Madagascar

```bash
cd planners/madagascar/sokoban
python3 run_sokoban.py assigned_goal/problem5x5_two_boxes.pddl
```

### Blackbox

```bash
cd planners/blackbox/sokoban
python3 run_sokoban_blackbox.py problem5x5_two_boxes.pddl
```

## Example Instances

Simple structured instance (5x5 grid, 2 boxes):

```
P . . . .
# B # . .
. . B . .
. # . . .
. . . G G
```

More constrained instance (7x7 grid, 7 boxes):

```
# # # . . . #
# G P B . . #
# # # . B G #
# G # # B . #
# . # . G . #
# B . * B B G
# . . . G . .
```

The first instances scale progressively (grid size and number of boxes increase proportionally).

The denser 7x7 instance introduces tighter corridors and stronger box interactions, significantly impacting SAT encoding size and solver performance.