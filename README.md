# PX4 External Module Example

External module template for PX4.

## Requirements

- Ubuntu (x86_64)
- Python 3 packages: `python3-kconfiglib python3-empy pyros-genmsg`
- Gazebo Harmonic
- just
- zellij

## Setup

**Important**: Uninstall Anaconda/Miniconda if installed. It causes protobuf version conflicts with Gazebo.

Install system dependencies:
```bash
sudo apt-get install -y python3-kconfiglib python3-empy
pip3 install --break-system-packages pyros-genmsg
```

Initialize the project:
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
