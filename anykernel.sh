# AnyKernel3 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# begin properties
properties() { '
kernel.string=LoverOrientedKernel miui by 流念wloot
do.devicecheck=1
do.modules=0
do.cleanup=1
do.cleanuponabort=0
device.name1=sagit
device.name2=chiron
supported.versions=9
'; } # end properties

# shell variables
block=/dev/block/bootdevice/by-name/boot;
is_slot_device=0;
ramdisk_compression=auto;

## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. tools/ak3-core.sh;

## AnyKernel file attributes
# set permissions/ownership for included ramdisk files
chmod -R 750 $ramdisk/*;
chown -R root:root $ramdisk/*;

## AnyKernel install
dump_boot;
# begin ramdisk changes

if [ ! -d .backup ]; then
  $bin/magiskpolicy --load sepolicy --save sepolicy \
  "allow init proc file { open write }" \
  "allow init rootfs file execute_no_trans" \
  "allow init sysfs file { open write }" \
  "allow init sysfs_devices_system_cpu file write" \
  "allow init sysfs_graphics file { open write }" \
  "allow init default_prop property_service { set }" \
  ;
fi

key=$(cat /sdcard/id.txt);
test "$key" && patch_cmdline bootcipher "bootcipher=${key}";
test "$key" || patch_cmdline bootcipher;
patch_cmdline lpm_levels.sleep_disabled;
patch_cmdline sched_enable_hmp;
patch_cmdline sched_enable_power_aware;
patch_cmdline androidboot.verifiedbootstate;
patch_cmdline buildvariant;

# end ramdisk changes

write_boot;

mount -o rw,remount -t auto /system;
if [ -z $(cat /system/vendor/etc/fstab.qcom | grep 'fileencryption=ice') ]; then
  mv -f $home/system/vendor/etc/fstab.qcom.noice $home/system/vendor/etc/fstab.qcom;
else
  rm -f $home/system/vendor/etc/fstab.qcom.noice;
fi
cp -rf $home/system/* /system/;
rm -f /system/vendor/etc/perf/perf-profile1.conf;
rm -f /system/vendor/etc/perf/perf-profile2.conf;
rm -f /system/vendor/etc/perf/perf-profile3.conf;
rm -f /system/vendor/etc/perf/perf-profile4.conf;
rm -f /system/vendor/etc/perf/perf-profile5.conf;
rm -f /system/vendor/etc/perf/perf-profile6.conf;
chmod -R 644 /system/vendor/etc/perf/*;
chmod 644 /system/vendor/etc/powerhint.xml;
chmod 644 /system/vendor/etc/fstab.qcom;
mount -o ro,remount -t auto /system;

## end install
