#!/bin/sh

user="admin"
pass="admin"
ip="192.168.128.81"
bt1="1"
bt2="2"
{
	sleep 1
	echo "$user";
	sleep 1
	echo "$pass";

	for i in $(seq 1 2)
	do
		sleep 1
		echo "ls"
		sleep 1
		echo "ls > test.txt"


	done

}|telnet $ip

