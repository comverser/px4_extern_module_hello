# Run PX4 SITL with Gazebo (builds and launches simulator)
run: _prepare
    cd PX4-Autopilot && make px4_sitl gz_x500 EXTERNAL_MODULES_LOCATION=../

# Clean build artifacts
clean:
    cd PX4-Autopilot && make clean

# Internal: Prepare submodules
_prepare:
    git submodule sync --recursive
    git submodule update --init --recursive --remote