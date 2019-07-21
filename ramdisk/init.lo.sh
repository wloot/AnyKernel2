#!/system/bin/sh

function write() {
    echo -n $2 > $1
}

{
    sleep 10

    # Set the default IRQ affinity to the silver cluster
    write /proc/irq/default_smp_affinity f

    # Set interaction lock idle time
    write /sys/devices/virtual/graphics/fb0/idle_time 100

    # Disable thermal hotplug for thermal
    write /sys/module/msm_thermal/core_control/enabled 0
}&
