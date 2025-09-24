# CLAUDE.md

Guidance for Claude Code when working with this repository.

## Project

PX4 external module example - extends PX4 functionality without modifying core source.

## Structure

- `/PX4-Autopilot/` - Core PX4 submodule (DO NOT MODIFY)
- Root - External module implementation

## Build Commands

Launch QGroundControl (QGC) first, then build and run PX4 SITL with external modules:
```bash
# First launch QGC
QGroundControl

# Then in another terminal, build and run SITL
cd PX4-Autopilot
make px4_sitl gz_x500 EXTERNAL_MODULES_LOCATION=../
```

## Constraints

- Ubuntu x86_64 only
- Never modify PX4-Autopilot submodule
