#!/system/bin/sh
MODDIR=${0%/*}

echo 16 > /sys/block/sda/queue/iosched/quantum
echo 1 > /sys/block/sda/queue/iosched/back_seek_penalty
echo 4096 > /sys/block/sda/queue/iosched/back_seek_max

set_top_app_task() {
	local dump
	local flag

	flag=0
	dump="$(ps -Ao pid,args)"
	for pid in $(echo "$dump" | grep "$1" | awk '{print $1}'); do
		for tid in $(ls /proc/$pid/task/); do
			if test "$(cat /proc/$tid/comm | grep -x "$2")"; then
				echo 1 >/proc/$tid/top_app_no_override
				flag=1
			fi
		done
	done
	echo $flag
}

set_top_app_process() {
	local dump
	local flag

	flag=0
	dump="$(ps -Ao pid,args)"
	for pid in $(echo "$dump" | grep "$1" | awk '{print $1}'); do
		echo 1 >/proc/$pid/top_app_no_override
		flag=1
		[ ! "$2" ] && continue
		for tid in $(ls /proc/$pid/task/); do
			echo 1 >/proc/$tid/top_app_no_override
		done
	done
	echo $flag
}

flag=0
until [[ "$flag" -eq 6 ]]; do
	sleep 5s
	flag=0
	let "flag+=$(set_top_app_task system_server android.anim.lf)"
	let "flag+=$(set_top_app_task system_server android.anim)"
	let "flag+=$(set_top_app_task system_server android.ui)"
	let "flag+=$(set_top_app_task system_server android.display)"
	let "flag+=$(set_top_app_task com.miui.home RenderThread)"
	let "flag+=$(set_top_app_process com.miui.home)"
done

set_process() {
	local dump

	dump="$(ps -Ao pid,args)"
	for pid in $(echo "$dump" | grep "$1" | awk '{print $1}'); do
		echo $pid >"/dev/$4/$2/$3"
		[ ! "$5" ] && continue
		for tid in $(ls /proc/$pid/task/); do
			echo $tid >"/dev/$4/$2/$3"
		done
	done
}

set_task() {
	local dump

	dump="$(ps -Ao pid,args)"
	for pid in $(echo "$dump" | grep "system_server" | awk '{print $1}'); do
		for tid in $(ls /proc/$pid/task/); do
			if test "$(cat /proc/$tid/comm | grep -x "$1")"; then
				echo $tid >"/dev/$4/$2/$3"
			fi
		done
	done
}

store_bg_stune() {
	local dump

	dump="$(ps -Ao pid,args)"
	rm -f $MODDIR/saved_tids
	for pid in $(echo "$dump" | grep "system_server" | awk '{print $1}'); do
		for tid in $(ls /proc/$pid/task/); do
			if test $(cat /dev/stune/background/tasks | grep -x $tid); then
				echo $tid >>$MODDIR/saved_tids
			fi
		done
	done
}

restore_bg_stune() {
	for tid in $(cat $MODDIR/saved_tids); do
		echo $tid >/dev/stune/background/tasks
	done
}

set_process surfaceflinger foreground cgroup.procs cpuset

return 0

store_bg_stune
set_process system_server foreground cgroup.procs stune
restore_bg_stune
set_task android.io foreground tasks stune
set_task android.anim top-app tasks stune
set_task android.anim.lf top-app tasks stune
set_task android.bg background tasks stune
set_task android.fg foreground tasks stune
set_task android.ui top-app tasks stune
set_task android.display top-app tasks stune
set_task PackageManager background tasks stune

set_process system_server foreground cgroup.procs cpuset
set_task CompactionThrea system-background tasks cpuset
set_task android.io foreground tasks cpuset
set_task android.anim top-app tasks cpuset
set_task android.anim.lf top-app tasks cpuset
set_task android.bg system-background tasks cpuset
set_task android.fg foreground tasks cpuset
set_task android.ui foreground tasks cpuset
set_task android.display top-app tasks cpuset

while true; do
	local temp=0
	local dump

	dump="$(ps -Ao pid,args)"
	for pid in $(echo "$dump" | grep "system_server" | awk '{print $1}'); do
		for tid in $(ls /proc/$pid/task/); do
			if test "$(cat /proc/$tid/comm | grep -x RenderThread)"; then
				echo $tid >/dev/stune/background/tasks
				temp=1
			fi
		done
	done
	[ "$temp" -eq "1" ] && break
	sleep 10s
done
