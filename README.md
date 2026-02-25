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

sudo dpkg --add-architecture i386
sudo apt update
sudo apt install libc6:i386 libstdc++6:i386

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
Run them from inside their respective planner directory.

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
python3 run_sokoban.py problems_with_assigned_goal/problem5x5_two_boxes.pddl
```

### Blackbox

```bash
cd planners/blackbox/sokoban
python3 run_sokoban_blackbox.py problem5x5_two_boxes.pddl
```
