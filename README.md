# PX4 External Module Example

External module template for PX4.

## Setup

```bash
sudo apt install just
```

## Usage

```bash
just init   # Setup project
just run    # Run PX4
just clean  # Clean build
```

## Structure

- `/PX4-Autopilot/` - Core PX4 (don't modify)
- `/apps/` - Downloaded apps (gitignored)
- Root - Your module code
