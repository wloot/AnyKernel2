# AnyKernel3 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# begin properties
properties() { '
kernel.string=LoverOriented Kernel by Julian
do.devicecheck=1
do.modules=0
do.systemless=1
do.cleanup=1
do.cleanuponabort=0
device.name1=raphael
device.name2=raphaelin
supported.versions=10
supported.patchlevels=
'; } # end properties

# shell variables
block=/dev/block/by-name/boot;
is_slot_device=0;
ramdisk_compression=auto;


## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. tools/ak3-core.sh;


## AnyKernel file attributes
# set permissions/ownership for included ramdisk files
set_perm_recursive 0 0 755 644 $ramdisk/*;
set_perm_recursive 0 0 750 750 $ramdisk/init* $ramdisk/sbin;


## AnyKernel install
split_boot;

# begin ramdisk changes

key=$(cat /sdcard/id.txt | tr -cd "[0-9]");
test "$key" && ui_print "  • Writing key to kernel" && patch_cmdline bootcipher "bootcipher=${key}";
test "$key" || patch_cmdline bootcipher;

case "$ZIPFILE" in
  *66fps*|*66hz*)
    ui_print "  • Setting 66 Hz refresh rate"
    patch_cmdline "msm_drm.framerate_override" "msm_drm.framerate_override=1"
    ;;
  *69fps*|*69hz*)
    ui_print "  • Setting 69 Hz refresh rate"
    patch_cmdline "msm_drm.framerate_override" "msm_drm.framerate_override=2"
    ;;
  *72fps*|*72hz*)
    ui_print "  • Setting 72 Hz refresh rate"
    patch_cmdline "msm_drm.framerate_override" "msm_drm.framerate_override=3"
    ;;
  *75fps*|*75hz*)
    ui_print "  • Setting 75 Hz refresh rate"
    patch_cmdline "msm_drm.framerate_override" "msm_drm.framerate_override=4"
    ;;
  *)
    patch_cmdline "msm_drm.framerate_override" ""
    fr=$(cat /sdcard/framerate_override | tr -cd "[0-9]");
    [ $fr -eq 66 ] && ui_print "  • Setting 66 Hz refresh rate" && patch_cmdline "msm_drm.framerate_override" "msm_drm.framerate_override=1"
    [ $fr -eq 69 ] && ui_print "  • Setting 69 Hz refresh rate" && patch_cmdline "msm_drm.framerate_override" "msm_drm.framerate_override=2"
    [ $fr -eq 72 ] && ui_print "  • Setting 72 Hz refresh rate" && patch_cmdline "msm_drm.framerate_override" "msm_drm.framerate_override=3"
    [ $fr -eq 75 ] && ui_print "  • Setting 75 Hz refresh rate" && patch_cmdline "msm_drm.framerate_override" "msm_drm.framerate_override=4"
    ;;
esac

mount -o rw,remount -t auto /vendor;
chattr -R -i /vendor/etc/perf/;
cp -rf $home/vendor/* /vendor/;
chmod 0644 /vendor/etc/perf/*;
chattr -R +i /vendor/etc/perf/;
chmod 0644 /vendor/etc/thermal-*.conf;

insert_line /vendor/etc/fstab.qcom "f2fs" after "/data" "/dev/block/bootdevice/by-name/userdata                  /data                    f2fs    noatime,nosuid,nodev,discard,fsync_mode=nobarrier    latemount,wait,fileencryption=ice,wrappedkey,check,quota,formattable,reservedsize=128M,sysfs_path=/sys/devices/platform/soc/1d84000.ufshc,checkpoint=fs";
mount -o ro,remount -t auto /vendor;

# end ramdisk changes

flash_boot;
flash_dtbo;
## end install

