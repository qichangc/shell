#!/bin/bash
function get_elapsed_time()
{
	user_hz=$(getconf CLK_TCK) #mostly it's 100 on x86/x86_64
	pid=$1
	jiffies=$(cat /proc/$pid/stat | cut -d" " -f22)
	jiffies=${jiffies:=0}   #avoid jiffies is empty
	sys_uptime=$(cat /proc/uptime | cut -d" " -f1)
	last_time=$(( ${sys_uptime%.*} - $jiffies/$user_hz ))
	#echo "the process $pid lasts for $last_time seconds."
	echo $last_time
}

function kill_by_ppid()
{
	my_ppid=$1
	PIDs=$(ps -ef|awk -v awk_ppid="$my_ppid" '{if(awk_ppid==$3) {print $2}}')
	for i in $PIDs
	do
		kill -9 $i
	done
	kill -9 $my_ppid
}

pid_files="/home/repo/git-sync.pid"
threshold=$((1*3600))

for i in $pid_files
do
	if [ -f $i ]; then
		git_pid=$(cat $i)
		interval=$(get_elapsed_time $git_pid)
		if [ "1$interval" -gt "1$threshold" ]; then
			kill_by_ppid $git_pid
			rm -f $i
		fi
	fi
done
