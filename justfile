# Initialize project dependencies
init:
	@git submodule update --init --recursive
	@mkdir -p apps
	@[ -f apps/QGroundControl.AppImage ] || ( \
		wget -qO apps/QGroundControl.AppImage https://d176tv9ibo4jno.cloudfront.net/builds/master/QGroundControl-x86_64.AppImage && \
		chmod +x apps/QGroundControl.AppImage \
	)

# Run PX4 with simulator and ground control
run: init
	@zellij --layout layout.kdl

# Close all PX4 processes
close:
	@killall px4 2>/dev/null || true
	@pkill -KILL -f "QGroundControl" 2>/dev/null || true
	@pkill -KILL -f "gz sim" 2>/dev/null || true
	@killall ruby 2>/dev/null || true
	@echo "Closed all PX4, QGroundControl, and Gazebo processes"

# Clean build artifacts
clean:
	@cd PX4-Autopilot && make clean