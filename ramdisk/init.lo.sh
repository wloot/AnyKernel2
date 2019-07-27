#!/system/bin/sh

function write() {
    echo -n $2 > $1
}

{
    sleep 10

    write /sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq 2112000

    # Set the default IRQ affinity to the silver cluster
    write /proc/irq/default_smp_affinity f

    # Set interaction lock idle time
    write /sys/devices/virtual/graphics/fb0/idle_time 100

    # Disable thermal hotplug for thermal
    write /sys/module/msm_thermal/core_control/enabled 0

    # Flash doesn't have back seek problem, so penalty is as low as possible
    write /sys/block/sda/queue/iosched/back_seek_penalty 1

    # UFS 2.0+ hardware queue depth is 32
    write /sys/block/sda/queue/iosched/quantum 16

    write /dev/stune/top-app/schedtune.sched_boost 10
}&
