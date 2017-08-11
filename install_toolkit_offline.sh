#!/bin/bash

root_path=$PWD
source_packet_path=$root_path'/tar'      #源码目录
root_release_path=$root_path'/release'   #编译输出目录
root_build_path=$root_path'/build'       #编译目录
source_md5_file=$root_path'/conf/md5.list'
source_server_ip=`awk -F= '{print $2}' $root_path/conf/config.ini`

function help_info()
{
	echo -e "\e[0;32;1m crosstool-ng   制作交叉编译工具\e[0m"
	echo -e "\e[0;31;1m===========================================================================\e[0m"
}

help_info
echo -e "\e[0;33;1m     select source name, default compile all\e[0m"
echo -e "\e[0;33;1m     package name list - \e[0m"
echo -e "\e[0;33;1m       exit | uuid | mtd-utils | crosstool-ng    \e[0m"
echo -e "\e[0;33;1m       lzo     \e[0m"
echo -e "\e[0;32;1m   choose:\e[0m \c"
read compile_args

# need to compile source module
module_name=(
[1]=crosstool-ng-1.21.0
[2]=lzo-2.10
[3]=libuuid-1.0.3
[4]=mtd-utils-1.4.5
[5]=shc-3.8.9
)

# check crosstool exist
if [ "$compile_args" = "exit" ] || [ "$compile_args" = "EXIT" ];then
	exit 0
fi

# create release dirrent
if [ ! -d "$root_release_path" ]
then
    echo -e "\e[0;32;1m[info] : create release success\e[0m"
    mkdir "$PWD/release"
fi

# create build dirrent
if [ ! -d "$root_build_path" ]
then
    echo -e "\e[0;32;1m[info] : create build success\e[0m"
    mkdir "$PWD/build"
fi


# check md5 value for every package
function get_valid_package(){
    cd "$root_build_path"
    echo -e "\e[0;32;1m[info] : tar xf $1$2 to build\e[0m"
    if [ ! -f "$source_packet_path/$1$2" ]; then
		echo -e "\e[0;32;1m[info] : wget addr $source_server_ip$1$2 \e[0m"
        wget -P "$source_packet_path" "$source_server_ip$1$2"
    else
        download_md5=`md5sum "$source_packet_path/$1$2" | awk -F" "  '{print $1}'`
        correct_md5=`grep -r "$1" "$source_md5_file" | awk -F" "  '{print $2}'`

        if [ "$correct_md5" = "" ]; then
            echo -e "\e[0;31;1m[erro] : add md5value for $1 in md5.cfg\e[0m"
        fi

        if [ "$download_md5" != "$correct_md5" ]; then
            echo -e "\e[0;32;1m[info] : md5 value error, download again \e[0m"
            echo -e "\e[0;31;1m[erro] : download-md5 : $download_md5\e[0m"
            echo -e "\e[0;31;1m[erro] : correct-md5  : $correct_md5 \e[0m"
            #$grm "$source_packet_path/$1$2"
            wget -P "$source_packet_path" "$source_server_ip$1$2"
        else
            echo -e "\e[0;32;1m[info] : [$1$2] md5 ok \e[0m"
        fi
    fi
}

# compile crosstool-ng
if [ "$compile_args" = "crosstool-ng" ]
then
	get_valid_package "${module_name[1]}.tar.bz2"
	if [ ! -f "$source_packet_path/${module_name[1]}.tar.bz2" ]; then
		wget -P "$source_packet_path" "http://crosstool-ng.org/download/crosstool-ng/${module_name[1]}.tar.bz2"
		if [ $? -ne 0 ]; then
			exit 0
		fi
	fi
    $grm "$root_build_path/${module_name[1]}"
    tar xf "$source_packet_path/${module_name[1]}.tar.bz2"
    cd "$root_build_path/${module_name[1]}"
    ./configure --with-libtool=/usr/share/libtool \
        --disable-static --enable-shared \
        --prefix="$root_release_path"
    make -j6
    make install
fi

# compile lzo
if [ "$compile_args" = "lzo" ]
then
	get_valid_package "${module_name[2]}.tar.gz"
	if [ ! -f "$source_packet_path/${module_name[2]}.tar.bz2" ]; then
		wget -P "$source_packet_path" "http://www.oberhumer.com/opensource/lzo/download/${module_name[2]}.tar.gz"
		if [ $? -ne 0 ]; then
			exit 0
		fi
	fi
    $grm "$root_build_path/${module_name[2]}"
    tar xf "$source_packet_path/${module_name[2]}.tar.gz"
    cd "$root_build_path/${module_name[2]}"
    ./configure
    #    --prefix="$root_release_path"
    make -j6
    sudo make install
fi

# compile libuuid
if [ "$compile_args" = "uuid" ]
then
	get_valid_package "${module_name[3]}.tar.gz"
	if [ ! -f "$source_packet_path/${module_name[3]}.tar.gz" ]; then
		git clone http://www.oberhumer.com/opensource/lzo/download/${module_name[3]}.tar.gz "$source_packet_path"
		if [ $? -ne 0 ]; then
			echo -e "\e[0;31;1m[erro] : no have libuuid \e[0m"
			exit 0
		fi
	fi
    $grm "$root_build_path/${module_name[3]}"
    tar xf "$source_packet_path/${module_name[3]}.tar.gz"
    cd "$root_build_path/${module_name[3]}"
    ./configure
    make -j6
    sudo make install
fi

# compile mtd-utils-1.4.5
# depend on uuid lzo
if [ "$compile_args" = "mtd-utils" ]
then
	get_valid_package "${module_name[4]}.tar.bz2"
	if [ ! -f "$source_packet_path/${module_name[4]}.tar.bz2" ]; then
		wget -P "$source_packet_path" "ftp://ftp.infradead.org/pub/mtd-utils/${module_name[4]}.tar.bz2"
		if [ $? -ne 0 ]; then
			exit 0
		fi
	fi
    $grm "$root_build_path/${module_name[4]}"
    tar xf "$source_packet_path/${module_name[4]}.tar.bz2"
    cd "$root_build_path/${module_name[4]}"
    ./configure
    make -j6
    sudo make install
fi

# compile shc
if [ "$compile_args" = "shc" ]
then
	get_valid_package "${module_name[5]}.tgz"
	if [ ! -f "$source_packet_path/${module_name[5]}.tgz" ]; then
		wget -P "$source_packet_path" "http://www.datsi.fi.upm.es/~frosal/sources/${module_name[5]}.tgz"
		if [ $? -ne 0 ]; then
			exit 0
		fi
	fi
    $grm "$root_build_path/${module_name[5]}"
    tar xf "$source_packet_path/${module_name[5]}.tgz"
    cd "$root_build_path/${module_name[5]}"
    make test
	make strings
    sudo make install
fi
