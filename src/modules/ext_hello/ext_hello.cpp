#include <px4_platform_common/px4_config.h>
#include <px4_platform_common/log.h>
#include <px4_platform_common/module.h>

extern "C" __EXPORT int ext_hello_main(int argc, char *argv[])
{
	PX4_INFO("External module test");
	return 0;
}