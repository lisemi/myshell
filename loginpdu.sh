#!/usr/bin/expect

set user "sysadmin"
set pwd "peersafe"
set ip "[lindex $argv 0]"

puts "telnet to : $ip"

spawn telnet $ip
expect {
	"login" {
		send "$user\n"
		exp_continue
	}
	"Password" {
		send "$pwd"
	}
}
puts "\nconnect to $ip is ok!"
interact
