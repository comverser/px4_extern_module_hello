#include <px4_platform_common/px4_config.h>
#include <px4_platform_common/log.h>
#include <px4_platform_common/module.h>

extern "C" __EXPORT int hello_px4_main(int argc, char *argv[])
{
	PX4_INFO("Hello from PX4 external module!");

	if (argc >= 2) {
		PX4_INFO("Received argument: %s", argv[1]);
	}

	return 0;
}