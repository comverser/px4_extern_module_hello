# List available commands
default:
	@just --list --unsorted

# Initialize submodules and download QGroundControl
init:
	@git submodule update --init --recursive
	@mkdir -p apps
	@[ -f apps/QGroundControl.AppImage ] || ( \
		wget -qO apps/QGroundControl.AppImage https://d176tv9ibo4jno.cloudfront.net/builds/master/QGroundControl-x86_64.AppImage && \
		chmod +x apps/QGroundControl.AppImage \
	)

# Run PX4 with simulator and ground control
run: init
	@echo 'layout {' > /tmp/px4_layout.kdl
	@echo '    tab name="PX4" {' >> /tmp/px4_layout.kdl
	@echo '        pane split_direction="vertical" {' >> /tmp/px4_layout.kdl
	@echo '            pane name="PX4" {' >> /tmp/px4_layout.kdl
	@echo '                command "bash"' >> /tmp/px4_layout.kdl
	@echo '                args "-c" "cd '$(pwd)'/PX4-Autopilot && make px4_sitl gz_x500 EXTERNAL_MODULES_LOCATION=../"' >> /tmp/px4_layout.kdl
	@echo '            }' >> /tmp/px4_layout.kdl
	@echo '            pane split_direction="horizontal" {' >> /tmp/px4_layout.kdl
	@echo '                pane name="QGC" {' >> /tmp/px4_layout.kdl
	@echo '                    command "bash"' >> /tmp/px4_layout.kdl
	@echo '                    args "-c" "sleep 5 && '$(pwd)'/apps/QGroundControl.AppImage"' >> /tmp/px4_layout.kdl
	@echo '                }' >> /tmp/px4_layout.kdl
	@echo '                pane name="Terminal" focus=true {' >> /tmp/px4_layout.kdl
	@echo '                    command "bash"' >> /tmp/px4_layout.kdl
	@echo '                }' >> /tmp/px4_layout.kdl
	@echo '            }' >> /tmp/px4_layout.kdl
	@echo '        }' >> /tmp/px4_layout.kdl
	@echo '    }' >> /tmp/px4_layout.kdl
	@echo '}' >> /tmp/px4_layout.kdl
	@zellij --layout /tmp/px4_layout.kdl

# Close all PX4 processes
close:
	#!/bin/bash
	echo "Checking for running processes..."
	# Check what's running before killing
	pgrep -f "PX4-Autopilot.*bin/px4" > /dev/null 2>&1 && echo "  → Closing PX4 processes..." || true
	pgrep -f "gz sim" > /dev/null 2>&1 && echo "  → Closing Gazebo simulator..." || true
	pgrep -f "QGroundControl" > /dev/null 2>&1 && echo "  → Closing QGroundControl..." || true
	pgrep -f "make px4_sitl" > /dev/null 2>&1 && echo "  → Closing PX4 build processes..." || true
	ls /tmp/px4-sock-* > /dev/null 2>&1 && echo "  → Cleaning PX4 instance locks..." || true
	# Clean up PX4 instance locks and sockets first
	rm -f /tmp/px4-sock-* 2>/dev/null || true
	# Kill PX4 processes (specific patterns that won't match the just command itself)
	pkill -f "PX4-Autopilot.*bin/px4" 2>/dev/null || true
	pkill -f "px4_sitl_default" 2>/dev/null || true
	killall px4 2>/dev/null || true
	# Kill Gazebo processes (both gz and ruby)
	pkill -f "gz sim" 2>/dev/null || true
	pkill -f "gz_" 2>/dev/null || true
	killall gz 2>/dev/null || true
	killall ruby 2>/dev/null || true
	# Kill QGroundControl (force kill as it may ask for confirmation)
	pkill -KILL -f "QGroundControl" 2>/dev/null || true
	# Kill any make processes for px4_sitl
	pkill -f "make px4_sitl" 2>/dev/null || true
	# Clean up any remaining cmake/ninja build processes
	pkill -f "cmake.*px4_sitl" 2>/dev/null || true
	pkill -f "ninja.*gz_x500" 2>/dev/null || true
	# Wait a moment for processes to terminate
	sleep 1
	# Force kill any stubborn processes
	pkill -9 -f "PX4-Autopilot.*bin/px4" 2>/dev/null || true
	pkill -9 -f "px4_sitl_default" 2>/dev/null || true
	pkill -9 -f "gz sim" 2>/dev/null || true
	# Final status
	echo ""
	echo "✓ Cleanup complete"
	# Check if anything is still running
	pgrep -f "PX4-Autopilot.*bin/px4" > /dev/null 2>&1 && echo "⚠ Warning: Some PX4 processes may still be running" || echo "✓ All PX4 processes closed"
	pgrep -f "gz sim" > /dev/null 2>&1 && echo "⚠ Warning: Gazebo may still be running" || echo "✓ Gazebo closed"
	pgrep -f "QGroundControl" > /dev/null 2>&1 && echo "⚠ Warning: QGroundControl may still be running" || echo "✓ QGroundControl closed"

# Build firmware for hardware with external modules
build_hw:
	#!/bin/bash
	echo "Select hardware:"
	echo "  1) Cube Orange"
	echo "  2) Holybro 6C mini"
	read -p "Enter choice [1-2]: " choice
	case $choice in
		1) target="cubepilot_cubeorange" ;;
		2) target="holybro_pix32v6c" ;;
		*) echo "Invalid choice"; exit 1 ;;
	esac
	cd PX4-Autopilot && make ${target}_default EXTERNAL_MODULES_LOCATION=../
	# Copy firmware to root directory maintaining path structure
	mkdir -p ../build/${target}_default
	cp -v build/${target}_default/${target}_default.px4 ../build/${target}_default/
	cp -v build/${target}_default/${target}_default.elf ../build/${target}_default/
	cp -v build/${target}_default/${target}_default.bin ../build/${target}_default/ 2>/dev/null || true
	echo ""
	echo "✓ Firmware copied to: build/${target}_default/${target}_default.px4"
	echo "  Upload this file to your hardware using QGroundControl"

# Clean build artifacts
clean:
	@cd PX4-Autopilot && make clean