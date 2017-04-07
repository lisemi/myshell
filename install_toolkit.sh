#!/bin/bash

#  author : sammy    2017/03/24
#  compile these source pacakge under ubunt 16.04 x32
#  please make sure that your system is connected to internet
#

USER_PATH=$HOME
USER_NAME=$USER
GIT_NAME=sammy
GIT_EMAIL=lisemi@163.com
GIT_KEY=$USER_PATH/.ssh/id_rsa.pub
NFS_PATH=$USER_PATH/nfs
TFTP_PATH=$USER_PATH/tftpboot

echo -e "\e[0;33;1m     exit| install | config\e[0m"
echo -e "\e[0;33;1m     select toolkit name, default compile all\e[0m"
echo -e "\e[0;33;1m     toolkit name list - \e[0m"
echo -e "\e[0;33;1m       g++ | flex | gettext   | makeinfo  | automake  | build-essential\e[0m"
echo -e "\e[0;33;1m       git | lzop | help2man  | odblatex  | autoconf  | python3.5-dev\e[0m"
echo -e "\e[0;33;1m       m4  | zsh  | indent    | docbook2x | mtd-utils | openssh-server\e[0m"
echo -e "\e[0;33;1m       bc  | vim  | autopoint | bison     | md5sum    | indicator-netspeed\e[0m"
echo -e "\e[0;33;1m       nfs | scons| samba     | cmake     | compizconfig-settings-manager\e[0m"
echo -e "\e[0;33;1m       dbus| tftp | d-feet    | libgtk2.0 | libncurses5-dev\e[0m"
echo -e "\e[0;32;1m   choose:\e[0m \c"
read compile_args

# install package
package_name=(
[1]=g++
[2]=build-essential
[3]=git
[4]=gettext                      #GNU国际化与本地化(i18n)函数库。它常被用于编写多语言程序
[5]=m4
[6]=help2man                     #自动生成man手册的工具:help2man
[7]=indent
[8]=autopoint                    #是GNU gettext的一部分，用于将程序翻译成不同语言的一组工具
[9]=makeinfo                     #将Texinfo源文档转换为各种其他格式
[10]=odblatex
[11]=docbook2x
[12]=flex
[13]=bison
[14]=automake
[15]=autoconf
[16]=mtd-utils
[17]=bc
[18]=lzop
[19]=md5sum
[20]=python3.5-dev
[21]=cmake
[22]=openssh-server
[23]=indicator-netspeed             #拼音输入法
[24]=compizconfig-settings-manager  #显示桌面:win + D
[25]="samba samba-common smbclient"
[26]=zsh
[27]=vim
[28]=dbus                           #进程间通信
[29]=d-feet                         #dbus信息查看工具: d-feet
[30]=libgtk2.0-dev
[31]=libncurses5-dev
[32]=scons
[33]="nfs-kernel-server nfs-common"
[34]="tftpd-hpa tftp-hpa"
)

trap - INT

case $compile_args in
	install)                    toolkit_index=0;;
	g++)                        toolkit_index=1;;
	build-essential+)           toolkit_index=2;;
	git)						toolkit_index=3;;
	gettext)					toolkit_index=4;;
	m4)							toolkit_index=5;;
	help2man)					toolkit_index=6;;
	indent)						toolkit_index=7;;
	autopoint)					toolkit_index=8;;
	makeinfo)					toolkit_index=9;;
	odblatex)					toolkit_index=10;;
	docbook2x)					toolkit_index=11;;
	flex)						toolkit_index=12;;
	bison)						toolkit_index=13;;
	automake)					toolkit_index=14;;
	autoconf)					toolkit_index=15;;
	mtd-utils)					toolkit_index=16;;
	bc)							toolkit_index=17;;
	lzop)						toolkit_index=18;;
	md5sum)						toolkit_index=19;;
	python3.5-dev)				toolkit_index=20;;
	cmake)						toolkit_index=21;;
	openssh-server)				toolkit_index=22;;
	indicator-netspeed)			toolkit_index=23;;
	compizconfig-settings-manager) toolkit_index=24;;
	samba)						toolkit_index=25;;
	zsh)						toolkit_index=26;;
	vim)						toolkit_index=27;;
	dbus)						toolkit_index=28;;
	d-feet)						toolkit_index=29;;
	libgtk2.0)					toolkit_index=30;;
	libncurses5-dev)            toolkit_index=31;;
	scons)                      toolkit_index=32;;
	nfs)                        toolkit_index=33;;
	tftp)                       toolkit_index=34;;
	config)					    toolkit_index=1000;;
	exit)                       exit 0;;
	*)                          echo -e "\e[0;32;1m[info] : invalid arguments\e[0m"; exit 0;;
esac


function install_all(){
	sudo apt-get update
	for var in ${package_name[@]};
	do
		echo -e "\e[0;32;1m[info] : install $var\e[0m"
		sudo apt-get -y --assume-yes install $var
	done
}

if [ $toolkit_index = "0" ]; then
	echo -e "\e[0;32;1m[info] : install all toolkit\e[0m"
    install_all
elif [ $toolkit_index -gt 0 -a $toolkit_index -lt 100 ];then
	tool=${package_name[$toolkit_index]}
	echo -e "\e[0;32;1m[info] : install $tool\e[0m"
	sudo apt-get -y --assume-yes install $tool
fi


# configure ========================================================
# 不是安装全部或者指定配置，则直接退出，不进行配置
# if [ $toolkit_index -eq 0 -o $toolkit_index -eq 100 ];then
	# echo -e "\033[0;32;1m[info] : support configure"
# else
	# exit 0
# fi

function is_run(){
	ps -ef | grep "$1" | grep -v "grep" > /dev/null 2>&1  #进程已经启动，则重启，否则启动进程
}

function config_zsh(){
	echo -e "\033[0;32;1m[info] : detection zsh\e[0m"
	if [ ! -f $HOME/.zshrc ]; then
		echo -e "\033[0;32;1m[info] : configure zsh\e[0m"
		wget --no-check-certificate https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | sh
		sudo usermod -s /bin/zsh $USER
	fi
}

function config_samba(){
	echo -e "\033[0;32;1m[info] : detaction samba\e[0m"
	grep "$USER_PATH" /etc/samba/smb.conf > /dev/null 2>&1
	if [ $? != "0" ];then
		echo -e "\033[0;32;1m[info] : configure samba\e[0m"
		sudo sed -i '44a hosts allow = 192.168.199.138' /etc/samba/smb.conf
		sudo sed -i '$a ['$USER_NAME']' /etc/samba/smb.conf
		sudo sed -i '$a path='$USER_PATH'' /etc/samba/smb.conf
		sudo sed -i '$a available = yes' /etc/samba/smb.conf
		sudo sed -i '$a browseable = yes' /etc/samba/smb.conf
		sudo sed -i '$a public = yes' /etc/samba/smb.conf
		sudo sed -i '$a writable = yes' /etc/samba/smb.conf
		sudo sed -i '$a create mask = 0775' /etc/samba/smb.conf
		sudo sed -i '$a directory mask = 0775' /etc/samba/smb.conf
	else
		echo -e "\033[0;32;1m[info] : The $USER_PATH has been configured into /etc/samba/smb.conf\e[0m"
	fi
	ps -ef | grep "smbd" | grep -v "grep" > /dev/null 2>&1  #进程已经启动，则重启，否则启动进程
	if [ $? = "0" ];then
		echo -e "\033[0;32;1m[info] : restart samba!\e[0m"
		sudo /etc/init.d/samba reload
		sudo /etc/init.d/samba restart
	else
		echo -e "\033[0;32;1m[info] : start samba!\e[0m"
		sudo /etc/init.d/samba reload
		sudo /etc/init.d/samba start
	fi
}

function config_ssh(){
	echo -e "\033[0;32;1m[info] : detaction ssh\e[0m"
	ps -x | grep "sshd" | grep -v grep > /dev/null 2>&1
	if [ $? != 0 ]; then
		echo -e "\033[0;32;1m[info] : configure ssh\e[0m"
		/etc/init.d/ssh start
	fi
}

function config_git(){
	echo -e "\033[0;32;1m[info] : detaction git\e[0m"
	if [ ! -f $GIT_KEY ]; then
		echo -e "\033[0;32;1m[info] : configure git"
		ssh-keygen -t rsa -C "$GIT_EMAIL"
		git config --global user.name "$GIT_NAME"
		git config --global user.email "$GIT_EMAIL"
	fi
}

function config_vim(){
	echo -e "\033[0;32;1m[info] : configure vim\e[0m"
	if [ ! -d $USER_PATH/.vim/bundle/vundle ]; then
		git clone https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle
		git@github.com:lisemi/vimrc.git $USER_PATH
		cp $USER_PATH/vimrc/vimrc ~/.vimrc
		rm -r $USER_PATH/vimrc
	fi
}

function config_nfs(){
	echo -e "\033[0;32;1m[info] : configure nfs\e[0m"
	if [ -f /etc/exports ]; then
		grep "$NFS_PATH" /etc/exports > /dev/null 2>&1
		if [ $? != "0" ]; then
			sudo sed -i '$a '$NFS_PATH' *(rw,sync,no_root_squash)' /etc/exports
			# “ *” 表示允许任何网段 IP 的系统访问该 NFS 目录
			sudo /etc/init.d/nfs-kernel-server start
			if [ $? != "0" ]; then
				echo -e "\033[0;32;1m[info] : nfs start fail; now restart!\e[0m"
				sudo /etc/init.d/nfs-kernel-server restart
				if [ $? != 0 ]; then
					echo -e "\033[0;32;1m[info] : nfs restart fail!\e[0m"
				fi
			else
				echo -e "\033[0;32;1m[info] : nfs start ok!\e[0m"
			fi
		else
			echo -e "\033[0;32;1m[info] : The nfs directory has been configured!\e[0m"
		fi
	fi
}

function config_tftp(){
	echo -e "\033[0;32;1m[info] : configure tftp\e[0m"
	if [ ! -d $TFTP_PATH ]; then
		echo -e "\033[0;32;1m[info] : create $TFTP_PATH\e[0m"
		mkdir $TFTP_PATH
		sudo chmod –R 777 $TFTP_PATH
	fi

	if [ -f /etc/default/tftpd-hpa ]; then
		if [ ! -f /etc/default/tftpd-hpa_bak ]; then
			sudo cp /etc/default/tftpd-hpa /etc/default/tftpd-hpa_bak
		fi
		grep "$TFTP_PATH" /etc/default/tftpd-hpa > /dev/null 2>&1
		if [ $? = "0" ]; then
			echo -e "\033[0;32;1m[info] : The $TFTP_PATH has been configured!\e[0m"
		else
			cat /etc/default/tftpd-hpa | sed -e '3,$d' > $TFTP_PATH/tftpd-tmp     #删除第三到末尾的数据
			sed -i '2a TFTP_USERNAME="tftp"'          $TFTP_PATH/tftpd-tmp
			sed -i '$a TFTP_DIRECTORY="'$TFTP_PATH'"' $TFTP_PATH/tftpd-tmp
			sed -i '$a TFTP_ADDRESS=":69"'            $TFTP_PATH/tftpd-tmp
			sed -i '$a TFTP_OPTIONS="--secure"'       $TFTP_PATH/tftpd-tmp
			sudo cp $TFTP_PATH/tftpd-tmp /etc/default/tftpd-hpa
			rm $TFTP_PATH/tftpd-tmp
		fi
		ps -ef | grep "tftpd" | grep -v "grep" > /dev/null 2>&1  #进程已经启动，则重启，否则启动进程
		if [ $? = "0" ];then
			echo -e "\033[0;32;1m[info] : restart tftp!\e[0m"
			sudo service tftpd-hpa restart
		else
			echo -e "\033[0;32;1m[info] : start tftp!\e[0m"
			sudo service tftpd-hpa start
		fi
	fi
}

function config_all(){
	config_zsh
	config_samba
	config_ssh
	config_git
	config_vim
	config_nfs
	config_tftp
}


if [ $toolkit_index = "0" -o $toolkit_index = "1000" ]; then
	echo -e "\e[0;33;1m     select toolkit name, default configure all\e[0m"
	echo -e "\e[0;33;1m     toolkit name list - \e[0m"
	echo -e "\e[0;33;1m       all | zsh | samba | ssh  | git  | vim\e[0m"
	echo -e "\e[0;33;1m       nfs | tftp|\e[0m"
	echo -e "\e[0;32;1m   choose:\e[0m \c"
	read config_args
else
	exit 0
fi

case $config_args in
	all)      config_all;;
	zsh)      config_zsh;;
	samba)    config_samba;;
	ssh)      config_ssh;;
	git)      config_git;;
	vim)      config_vim;;
	nfs)      config_nfs;;
	tftp)     config_tftp;;
	*)        echo -e "\e[0;32;1m[info] : invalid arguments\e[0m"
esac
