#!/usr/bin/expect -f

set timeout 20
set pwd "123456"
    spawn ssh -l sammy 192.168.199.108
    expect {
	"lost connection" {
		spawn ssh-keygen -f "~/lsm/.ssh/known_hosts" -R 192.168.199.108;   #从known_hosts文件中删除所有属于 192.168.199.108 的密钥
		exp_continue
	}
	"(yes/no)" {
		send "yes\n";
		exp_continue
	}
	"password:" {
		send "$pwd\n";
	}
    }
#expect eof   #登陆后退出
interact      #登陆后保留在登陆远程终端上
