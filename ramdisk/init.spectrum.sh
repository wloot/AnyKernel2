#!/system/bin/sh

# Set default spectrum profile on first boot
if [ -n $(cat /data/property/persistent_properties | grep persist.spectrum.profile) ]; then
    setprop persist.spectrum.profile 0
fi

# Lazy loading configuration to avoid being messed up by stock
{
    sleep 10
    setprop persist.boot_completed.delay 1
}&
