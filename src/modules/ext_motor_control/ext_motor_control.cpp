#include <px4_platform_common/px4_config.h>
#include <px4_platform_common/log.h>
#include <drivers/drv_hrt.h>
#include <uORB/topics/actuator_test.h>
#include <uORB/Publication.hpp>
#include <unistd.h>

static bool running = false;

extern "C" __EXPORT int ext_motor_control_main(int argc, char *argv[]);

int ext_motor_control_main(int argc, char *argv[])
{
	if (argc < 2) {
		PX4_INFO("Usage: ext_motor_control {start|stop}");
		return 1;
	}

	if (!strcmp(argv[1], "start")) {
		if (running) {
			PX4_WARN("Already running");
			return 1;
		}
		running = true;

		hrt_abstime start_time = hrt_absolute_time();
		PX4_INFO("Motor test started");

		uORB::Publication<actuator_test_s> actuator_test_pub{ORB_ID(actuator_test)};

		// Enable test mode
		actuator_test_s enable_test{};
		enable_test.timestamp = hrt_absolute_time();
		enable_test.function = actuator_test_s::FUNCTION_MOTOR1;
		enable_test.value = 0.0f;
		enable_test.action = actuator_test_s::ACTION_DO_CONTROL;
		enable_test.timeout_ms = 5000;  // 5 second timeout
		actuator_test_pub.publish(enable_test);

		PX4_INFO("Testing motor 1 for 4 seconds at 15%% max throttle");

		while (running) {
			float elapsed_s = (hrt_absolute_time() - start_time) / 1e6f;

			if (elapsed_s > 4.0f) {
				break;
			}

			float throttle;
			if (elapsed_s < 2.0f) {
				// Ramp up to 15% over 2 seconds
				throttle = (elapsed_s / 2.0f) * 0.15f;
			} else {
				// Ramp down from 15% to 0% over next 2 seconds
				throttle = 0.15f * (1.0f - (elapsed_s - 2.0f) / 2.0f);
			}

			// Send actuator test command
			actuator_test_s test{};
			test.timestamp = hrt_absolute_time();
			test.function = actuator_test_s::FUNCTION_MOTOR1;
			test.value = throttle;
			test.action = actuator_test_s::ACTION_DO_CONTROL;
			test.timeout_ms = 100;
			actuator_test_pub.publish(test);

			// Print progress every 0.5 seconds
			if ((int)(elapsed_s * 2) != (int)((elapsed_s - 0.05f) * 2)) {
				PX4_INFO("Time: %.1fs, Throttle: %.1f%%", (double)elapsed_s, (double)(throttle * 100));
			}

			px4_usleep(20000);  // 50Hz update rate
		}

		// Release motor control
		actuator_test_s stop_test{};
		stop_test.timestamp = hrt_absolute_time();
		stop_test.function = actuator_test_s::FUNCTION_MOTOR1;
		stop_test.value = 0.0f;
		stop_test.action = actuator_test_s::ACTION_RELEASE_CONTROL;
		stop_test.timeout_ms = 0;
		actuator_test_pub.publish(stop_test);

		running = false;
		PX4_INFO("Test complete");
		return 0;
	}

	if (!strcmp(argv[1], "stop")) {
		running = false;
		PX4_INFO("Stopped");
		return 0;
	}

	PX4_WARN("Unknown command: %s", argv[1]);
	return 1;
}