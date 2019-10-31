#!/system/bin/sh

function write() {
    echo -n $2 > $1
}

{
    sleep 10
    write /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq 518400
    write /sys/devices/system/cpu/cpu4/cpufreq/scaling_min_freq 422400

    write /sys/class/devfreq/5000000.qcom,kgsl-3d0/governor msm-adreno-tz
    # wait 40s before limiting cpu freq
    sleep 30
    write /sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq 2265600
}&

write /dev/cpuset/foreground/boost/cpus 0-3,6-7

# Set the default IRQ affinity to the silver cluster
write /proc/irq/default_smp_affinity f

# Set interaction lock idle time
write /sys/devices/virtual/graphics/fb0/idle_time 100

# Disable thermal hotplug for thermal
write /sys/module/msm_thermal/core_control/enabled 0

write /dev/stune/top-app/schedtune.sched_boost 10
