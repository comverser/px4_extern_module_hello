# PX4 External Module Example

External module template for PX4.

## Requirements

- Ubuntu (x86_64)
- just
- zellij

## Setup

```bash
just init
```

## Usage

```bash
just run      # Run PX4 SITL with QGC (press Ctrl-Q to end Zellij)
just close    # Close all processes
just clean    # Clean build
just build_hw # Build firmware for hardware (interactive)
```

## MAVLink Console Examples

### Motor Testing

Test motor 1 by spinning it at 10% throttle for 2 seconds:

```bash
actuator_test set -m 1 -v 0.10 -t 2
```
