#include <px4_platform_common/px4_config.h>
#include <px4_platform_common/log.h>
#include <px4_platform_common/module.h>
#include <px4_platform_common/px4_work_queue/ScheduledWorkItem.hpp>

#include <uORB/Subscription.hpp>
#include <uORB/topics/sensor_accel.h>

using namespace px4;

class ExtAccelMonitor : public ModuleBase<ExtAccelMonitor>, public ScheduledWorkItem
{
public:
    ExtAccelMonitor();
    ~ExtAccelMonitor() override = default;

    static int task_spawn(int argc, char *argv[]);
    static int custom_command(int argc, char *argv[]);
    static int print_usage(const char *reason = nullptr);

    void Run() override;

private:
    uORB::Subscription _accel_sub{ORB_ID(sensor_accel)};
    uint32_t _count{0};
    uint64_t _last_timestamp{0};
};

ExtAccelMonitor::ExtAccelMonitor() :
    ModuleBase(),
    ScheduledWorkItem(MODULE_NAME, px4::wq_configurations::test1)
{
}

void ExtAccelMonitor::Run()
{
    if (should_exit()) {
        ScheduleClear();
        exit_and_cleanup();
        return;
    }

    sensor_accel_s accel{};
    if (_accel_sub.copy(&accel)) {
        // Only process if we have a new timestamp
        if (accel.timestamp > _last_timestamp) {
            _last_timestamp = accel.timestamp;
            _count++;
            if (_count % 100 == 0) {
                PX4_INFO("Accel: x=%.2f y=%.2f z=%.2f (samples: %u)",
                        (double)accel.x, (double)accel.y, (double)accel.z, _count);
            }
        }
    }

    // Use a longer delay to reduce system load
    ScheduleDelayed(200000);  // 200ms instead of 100ms
}

int ExtAccelMonitor::task_spawn(int argc, char *argv[])
{
    ExtAccelMonitor *instance = new ExtAccelMonitor();

    if (instance) {
        _object.store(instance);
        _task_id = task_id_is_work_queue;
        instance->ScheduleNow();
        PX4_INFO("Accel monitor started successfully");
        return PX4_OK;
    }

    PX4_ERR("alloc failed");
    delete instance;
    _object.store(nullptr);
    _task_id = -1;
    return PX4_ERROR;
}

int ExtAccelMonitor::custom_command(int argc, char *argv[])
{
    return print_usage("unknown command");
}

int ExtAccelMonitor::print_usage(const char *reason)
{
    if (reason) {
        PX4_WARN("%s\n", reason);
    }

    PRINT_MODULE_DESCRIPTION(
        R"DESCR_STR(
### Description
Monitors accelerometer data and prints values periodically.

### Examples
Start the monitor:
$ ext_accel_monitor start

Stop the monitor:
$ ext_accel_monitor stop

Check status:
$ ext_accel_monitor status
)DESCR_STR");

    PRINT_MODULE_USAGE_NAME("ext_accel_monitor", "driver");
    PRINT_MODULE_USAGE_COMMAND("start");
    PRINT_MODULE_USAGE_COMMAND("stop");
    PRINT_MODULE_USAGE_COMMAND("status");

    return 0;
}

extern "C" __EXPORT int ext_accel_monitor_main(int argc, char *argv[])
{
    return ExtAccelMonitor::main(argc, argv);
}