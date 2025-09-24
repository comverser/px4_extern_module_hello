#include <px4_platform_common/px4_config.h>
#include <px4_platform_common/log.h>
#include <drivers/drv_hrt.h>
#include <uORB/topics/actuator_test.h>
#include <uORB/Publication.hpp>
#include <unistd.h>

static bool running = false;
static bool armed = false;
static hrt_abstime start_time = 0;

extern "C" __EXPORT int ext_motor_control_main(int argc, char *argv[]);

int ext_motor_control_main(int argc, char *argv[])
{
	if (argc < 2) {
		PX4_INFO("Usage: ext_motor_control {start|stop|arm|disarm}");
		return 1;
	}

	if (!strcmp(argv[1], "start")) {
		if (running) {
			PX4_WARN("Already running");
			return 1;
		}
		running = true;
		armed = false;
		PX4_INFO("Started - use 'ext_motor_control arm' to test motor");
		return 0;
	}

	if (!strcmp(argv[1], "stop")) {
		running = false;
		armed = false;
		PX4_INFO("Stopped");
		return 0;
	}

	if (!strcmp(argv[1], "arm")) {
		if (!running) {
			PX4_WARN("Not running - use 'ext_motor_control start' first");
			return 1;
		}

		PX4_WARN("Motor test - Remove propellers! Press 'y' to continue");
		char c;
		if (read(0, &c, 1) != 1 || c != 'y') {
			return 1;
		}

		armed = true;
		start_time = hrt_absolute_time();
		PX4_INFO("Motor test started");

		uORB::Publication<actuator_test_s> actuator_test_pub{ORB_ID(actuator_test)};

		while (armed && running) {
			float elapsed_s = (hrt_absolute_time() - start_time) / 1e6f;

			if (elapsed_s > 10.0f) {
				armed = false;
				break;
			}

			float throttle;
			if (elapsed_s < 5.0f) {
				throttle = elapsed_s / 5.0f;
			} else {
				throttle = 2.0f - (elapsed_s / 5.0f);
			}

			actuator_test_s test{};
			test.timestamp = hrt_absolute_time();
			test.function = actuator_test_s::FUNCTION_MOTOR1;
			test.value = throttle;
			test.action = actuator_test_s::ACTION_DO_CONTROL;
			test.timeout_ms = 100;
			actuator_test_pub.publish(test);


			px4_usleep(50000);
		}

		actuator_test_s stop_test{};
		stop_test.timestamp = hrt_absolute_time();
		stop_test.function = actuator_test_s::FUNCTION_MOTOR1;
		stop_test.value = 0.0f;
		stop_test.action = actuator_test_s::ACTION_RELEASE_CONTROL;
		stop_test.timeout_ms = 0;
		actuator_test_pub.publish(stop_test);

		armed = false;
		PX4_INFO("Test complete");
		return 0;
	}

	if (!strcmp(argv[1], "disarm")) {
		armed = false;
		PX4_INFO("Disarmed");
		return 0;
	}

	PX4_WARN("Unknown command: %s", argv[1]);
	return 1;
}