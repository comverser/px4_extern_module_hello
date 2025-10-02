# PX4 External Module Example

External module template for PX4.

## Requirements

- Ubuntu (x86_64)
- Python 3 with pip
- Gazebo Harmonic
- just
- zellij

## Setup

**Important**: Uninstall Anaconda/Miniconda if installed. It causes protobuf version conflicts with Gazebo.

```bash
just init
```

## Usage

```bash
just          # List available commands
```

## MAVLink Console Examples

### Motor Testing

Test motor 1 by spinning it at 10% throttle for 2 seconds:

```bash
actuator_test set -m 1 -v 0.10 -t 2
```
