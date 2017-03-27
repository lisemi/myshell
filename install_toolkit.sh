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

echo -e "\e[0;33;1m     select toolkit name, default compile all\e[0m"
echo -e "\e[0;33;1m     toolkit name list - \e[0m"
echo -e "\e[0;33;1m       all | configure\e[0m"
echo -e "\e[0;33;1m       g++ | flex | gettext   | makeinfo  | automake  | build-essential\e[0m"
echo -e "\e[0;33;1m       git | lzop | help2man  | odblatex  | autoconf  | python3.5-dev\e[0m"
echo -e "\e[0;33;1m       m4  | zsh  | indent    | docbook2x | mtd-utils | openssh-server\e[0m"
echo -e "\e[0;33;1m       bc  | vim  | autopoint | bison     | md5sum    | indicator-netspeed\e[0m"
echo -e "\e[0;33;1m       sambacommon| smbclient | samba     | cmake     | compizconfig-settings-manager\e[0m"
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
[25]=samba
[26]=samba-common
[27]=smbclient
[28]=zsh
[29]=vim
)

trap - INT

case $compile_args in
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
	sambacommon)				toolkit_index=26;;
	smbclient)					toolkit_index=27;;
	zsh)						toolkit_index=28;;
	vim)						toolkit_index=29;;
	configure)					toolkit_index=100;;
	*)                          toolkit_index=0;;
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
elif [ $toolkit_index -gt 0 -a $toolkit_index -lt 30 ];then
	tool=${package_name[$toolkit_index]}
	echo -e "\e[0;32;1m[info] : install $tool\e[0m"
	sudo apt-get -y --assume-yes install $tool
fi


# configure ========================================================
# 不是安装全部或者指定配置，则直接退出，不进行配置
if [ $toolkit_index -eq 0 -o $toolkit_index -eq 100 ];then
	echo -e "\033[0;32;1m[info] : support configure"
else
	exit 0
fi

echo -e "\033[0;32;1m[info] : detection zsh\e[0m"
if [ ! -f $HOME/.zshrc ]; then
	echo -e "\033[0;32;1m[info] : configure zsh\e[0m"
	wget --no-check-certificate https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | sh
	sudo usermod -s /bin/zsh $USER
fi

echo -e "\033[0;32;1m[info] : detaction samba"
grep "$USER_PATH" /etc/samba/smb.conf > /dev/null 2>&1
if [ $? != "0" ];then
	echo -e "\033[0;32;1m[info] : configure samba"
	sudo sed -i '$a ['$USER_NAME']' /etc/samba/smb.conf
	sudo sed -i '$a path='$USER_PATH'' /etc/samba/smb.conf
	sudo sed -i '$a available = yes' /etc/samba/smb.conf
	sudo sed -i '$a browseable = yes' /etc/samba/smb.conf
	sudo sed -i '$a public = yes' /etc/samba/smb.conf
	sudo sed -i '$a writable = yes' /etc/samba/smb.conf
	sudo sed -i '$a create mask = 0775' /etc/samba/smb.conf
	sudo sed -i '$a directory mask = 0775' /etc/samba/smb.conf
fi

echo -e "\033[0;32;1m[info] : detaction ssh"
ps -x | grep "sshd" | grep -v grep > /dev/null 2>&1
if [ $? != 0 ]; then
	echo -e "\033[0;32;1m[info] : configure ssh"
	/etc/init.d/ssh start
fi

echo -e "\033[0;32;1m[info] : detaction git"
if [ ! -f $GIT_KEY ]; then
	echo -e "\033[0;32;1m[info] : configure git"
	ssh-keygen -t rsa -C "$GIT_EMAIL"
	git config --global user.name "$GIT_NAME"
	git config --global user.email "$GIT_EMAIL"
fi

echo -e "\033[0;32;1m[info] : configure vim"
if [ ! -d $USER_PATH/.vim/bundle/vundle ]; then
	git clone https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle
	git@github.com:lisemi/vimrc.git $USER_PATH
	cp $USER_PATH/vimrc/vimrc ~/.vimrc
	rm -r $USER_PATH/vimrc
fi
