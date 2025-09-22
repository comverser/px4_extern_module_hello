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
	@killall px4 2>/dev/null || true
	@pkill -KILL -f "QGroundControl" 2>/dev/null || true
	@pkill -KILL -f "gz sim" 2>/dev/null || true
	@killall ruby 2>/dev/null || true
	@echo "Closed all PX4, QGroundControl, and Gazebo processes"

# Clean build artifacts
clean:
	@cd PX4-Autopilot && make clean