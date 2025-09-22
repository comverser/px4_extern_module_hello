# Initialize submodules and download QGroundControl
init:
	@git submodule update --init --recursive
	@mkdir -p apps
	@[ -f apps/QGroundControl.AppImage ] || \
	(echo "Downloading QGroundControl..." && \
	wget -qO apps/QGroundControl.AppImage https://d176tv9ibo4jno.cloudfront.net/builds/master/QGroundControl-x86_64.AppImage && \
	chmod +x apps/QGroundControl.AppImage)

# Run PX4 with QGroundControl
run:
	@[ -f apps/QGroundControl.AppImage ] || just init
	@./apps/QGroundControl.AppImage &
	cd PX4-Autopilot && make px4_sitl gz_x500 EXTERNAL_MODULES_LOCATION=../

# Clean build
clean:
	cd PX4-Autopilot && make clean