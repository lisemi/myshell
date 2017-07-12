#!/bin/bash

#  author : sammy    2017/05/26
#  compile these source pacakge under ubunt 16.04 x32
#  please make sure that your system is connected to internet

grm="rm -rf"

# toolchain_usr=/opt/gcc-linaro-arm-linux-gnueabihf-4.9-2014.09_linux/arm-linux-gnueabihf
# g_host=arm-linux-gnueabihf
# g_compile=arm-linux-gnueabihf-
# g_cc=arm-linux-gnueabihf-gcc
# g_cxx=arm-linux-gnueabihf-g++
# g_ar=arm-linux-gnueabihf-ar
# g_ranlib=arm-linux-gnueabihf-ranlib
# g_ld=arm-linux-gnueabihf-ld
# g_nm=arm-linux-gnueabihf-nm
# g_strip=arm-linux-gnueabihf-strip

#====== A9
toolchain_usr=/opt/poky/1.7/sysroots/cortexa9hf-vfp-neon-poky-linux-gnueabi/usr
g_host=arm-poky-linux-gnueabi
g_compile=arm-poky-linux-gnueabi-
g_cc="arm-poky-linux-gnueabi-gcc"
g_cxx="arm-poky-linux-gnueabi-g++9"
g_ar=arm-poky-linux-gnueabi-ar
g_ranlib=arm-poky-linux-gnueabi-ranlib
g_strip=arm-poky-linux-gnueabi-strip
g_ld=arm-poky-linux-gnueabi-ld
g_as=arm-poky-linux-gnueabi-as
g_target=arm-poky-linux-gnueabi
CFLAGS="-march=armv7-a -mthumb-interwork -mfloat-abi=hard -mfpu=neon -mtune=cortex-a9"


toolchain_libpath=-L$toolchain_usr/lib
toolchain_includepath=-I$toolchain_usr/include

root_path=$PWD
source_packet_path=$root_path'/tar'      #源码目录
root_release_path=$root_path'/release'   #编译输出目录
root_build_path=$root_path'/build'       #编译目录
source_md5_file=$root_path'/conf/md5.list'
source_server_ip=`awk -F= '{print $2}' $root_path/conf/config.ini`
#crosstool_path="`which arm-linux-gnueabihf-g++`"
crosstool_path="`which arm-poky-linux-gnueabi-g++`"


function help_info()
{
	echo -e "\e[0;32;1m iptables       旧版防火墙\e[0m"
	echo -e "\e[0;32;1m nftables       新板防火墙\e[0m"
	echo -e "\e[0;32;1m Linux-PAM      用户认证机制的一套共享库       \e[0m"
	echo -e "\e[0;32;1m libgcrypt      Libgcrypt是一种基于GnuPG代码的通用加密库       \e[0m"
	echo -e "\e[0;32;1m flex           GMP是用于任意精度算术的自由库，对有符号整数，有理数字和浮点数进行操作                  \e[0m"
	echo -e "\e[0;32;1m libmnl         libmnl是面向Netlink开发人员的简约用户空间库。解析，验证，构建Netlink标题和TLVs方面等   \e[0m"
	echo -e "\e[0;32;1m libnftnl       libnftnl是一个用户空间库，为内核nf_tables子系统提供了一个低级别的netlink编程接口（API）\e[0m"
	echo -e "\e[0;32;1m readline       一个开源的跨平台程序库，提供了交互式的文本编辑功能  \e[0m"
	echo -e "\e[0;32;1m binutils       一组二进制工具集,常用命令                           \e[0m"
	echo -e "\e[0;32;1m conreutils     GNU下的一个软件包，包含linux下的 ls等常用命令       \e[0m"
	echo -e "\e[0;32;1m procps-ng      Procps-ng软件包包含用于监视进程的程序工具。sysctl,kill,ps  \e[0m"
	echo -e "\e[0;32;1m util-linux     一个对任何Linux系统的基本工具套件。含有一些标准 UNIX 工具  \e[0m"
	echo -e "\e[0;32;1m libcap         网络接口数据捕获函数库       \e[0m"
	echo -e "\e[0;32;1m findutils      GNU操作系统的基本目录搜索工具; find,locate,locate,xargs    \e[0m"
	echo -e "\e[0;32;1m inetutils      linux下常用的网络工具的代码,如tftp,talk,rlogin,telnet等    \e[0m"
	echo -e "\e[0;32;1m net-tools      Linux的基础网络实用程序的集合,arp,hostname,ifconfig        \e[0m"
	echo -e "\e[0;32;1m ncurses        实现丰富多彩的字符颜色显示         \e[0m"
	echo -e "\e[0;32;1m wrappers       一个基于主机的网络访问控制表系统   \e[0m"
	echo -e "\e[0;32;1m popt           命令行解析工具                     \e[0m"
	echo -e "\e[0;31;1m===========================================================================\e[0m"
}

help_info
echo -e "\e[0;33;1m     select source name, default compile all\e[0m"
echo -e "\e[0;33;1m     package name list - \e[0m"
echo -e "\e[0;33;1m       exit | iptables | sqlite  | pam   | json-c   | libcap   | openssl    \e[0m"
echo -e "\e[0;33;1m       flex | bison    | libmnl  | gmp   | libnftnl | readline | nftables   \e[0m"
echo -e "\e[0;33;1m       sed  | binutils | nettool | bash  | coreutils| procps   | utillinux  \e[0m"
echo -e "\e[0;33;1m       zlib | openssh  | ncurses | snmp  | findutils| wrappers | libgcrypt  \e[0m"
echo -e "\e[0;33;1m       db   | openldap | krb5    | swig  | Python2.7| Python3.7| libcap-ng  \e[0m"
echo -e "\e[0;33;1m       popt | logrotate| audit   | \e[0m"
echo -e "\e[0;32;1m   choose:\e[0m \c"
read compile_args

# need to compile source module
module_name=(
[1]=openssl-1.0.2h
[2]=net-snmp-5.7.2
[3]=iptables-1.4.18
[4]=sqlite-autoconf-3120000
[5]=Linux-PAM-1.3.0
[6]=json-c-0.9
[7]=libgcrypt-1.5.2
[8]=flex-2.5.38
[9]=bison-3.0.4
[10]=gmp-6.1.1
[11]=libmnl-1.0.3
[12]=libnftnl-1.0.6
[13]=readline-6.3
[14]=nftables-0.6
[15]=binutils-2.26
[16]=coreutils-8.25
[17]=procps-ng-3.3.9
[18]=util-linux-2.27.1
[19]=libcap-2.25
[20]=findutils-4.6.0
[21]=zlib-1.2.8
[22]=openssh-7.2
[23]=bash-4.3
[24]=net-tools-1.60
[25]=sed-4.2.2
[26]=ncurses-6.0
[27]=inetutils-1.9.4
[28]=tcp_wrappers_7.6
[29]=Python-2.7.3
[30]=libcap-ng-0.7
[31]=db-5.3.28
[32]=openldap-2.4.44
[33]=Python-3.6.0
[34]=krb5-1.14.5
[35]=swig-3.0.12
[36]=audit-2.7.6
[37]=popt-1.16
[38]=logrotate-3.11.0
)

# check crosstool exist
if [ "$compile_args" = "exit" ] || [ "$compile_args" = "EXIT" ];then
	exit 0
fi

if [ "$crosstool_path" = "" ]
then
    echo -e "\e[0;31;1m[erro] : have no crosstool in /opt/poky\e[0m"
    echo -e "\e[0;31;1m[erro] : check .bashrc or .zshrc\e[0m"
    exit
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


# compile openssl
if [ "$compile_args" = "" ] || [ "$compile_args" = "openssl" ]
then

    get_valid_package "${module_name[1]}.tar.gz" 
    $grm "$root_build_path/${module_name[1]}"
    tar xf "$source_packet_path/${module_name[1]}.tar.gz"
    cd "$root_build_path/${module_name[1]}"
    /bin/bash config shared no-asm --prefix="$root_release_path"
    sed -i 's/PLATFORM=linux-elf/PLATFORM=linux-elf-arm/g' Makefile
    sed -i 's/CC= gcc/CC= arm-linux-gnueabihf-gcc/g' Makefile
    sed -i 's/AR= ar/AR= arm-linux-gnueabihf-ar/g' Makefile
    sed -i 's/RANLIB= /usr/bin/ranlib/RANLIB= arm-linux-gnueabihf-ranlib/g' Makefile
    sed -i 's/NM= nm/NM= arm-linux-gnueabihf-nm/g' Makefile
    sed -i 's/MAKEDEPPROG= gcc/MAKEDEPPROG= arm-linux-gnueabihf-gcc/g' Makefile
    make -j6
    make install
fi

# compile net-snmp
if [ "$compile_args" = "" ] || [ "$compile_args" = "snmp" ]
then
	get_valid_package "${module_name[2]}.tar.gz"
    $grm "$root_build_path/${module_name[2]}"
    tar xf "$source_packet_path/${module_name[2]}.tar.gz"
	# example.c是snmp的应用，可以选择替换和修改
    #cp new_example.c $root_build_path'/'${module_name[2]}'/'agent'/'mibgroup'/'examples'/'example.c
    cd "$root_build_path/${module_name[2]}"
    CC=$g_cc ./configure --build=i686-linux \
        --host=arm-linux --disable-manuals --enable-mfd-rewrites \
        --with-default-snmp-version="2" \
        --with-sys-contact="contact" \
        --with-sys-location="location" \
        --with-logfile="/log/snmp/snmpd.log" \
        --with-persistent-directory="/tmp/snmp" \
        --enable-shared=no --with-mib-modules=examples/example \
        --with-cc=arm-linux-gnueabihf-gcc --with-ar=arm-linux-gnueabihf-ar \
        --prefix="$root_release_path"
    make -j6
    make install
fi


# compile iptables
if [ "$compile_args" = "iptables" ]
then
	get_valid_package "${module_name[3]}.tar.gz"
    $grm "$root_build_path/${module_name[3]}"
    tar xf "$source_packet_path/${module_name[3]}.tar.gz"
    cd "$root_build_path/${module_name[3]}"
    ./configure --host=$g_host \
        --disable-static --enable-shared \
        --prefix="$root_release_path"
    make -j6
    make install
fi

# compile sqlite
if [ "$compile_args" = "" ] || [ "$compile_args" = "sqlite" ]
then
	get_valid_package "${module_name[4]}.tar.gz"
    $grm "$root_build_path/${module_name[4]}"
    tar xf "$source_packet_path/${module_name[4]}.tar.gz"
    cd "$root_build_path/${module_name[4]}"
    ./configure --disable-tcl --host=$g_host \
        --prefix="$root_release_path"
    make -j6
    make install
fi

# compile pam
if [ "$compile_args" = "" ] || [ "$compile_args" = "pam" ]
then
	get_valid_package "${module_name[5]}.tar.gz"
    $grm "$root_build_path/${module_name[5]}"
    tar xf "$source_packet_path'/'${module_name[5]}.tar.gz"
    cd "$root_build_path/${module_name[5]}"
    ./configure --host=$g_host --disable-static --enable-shared \
        --prefix="$root_release_path"
    make -j6
    make install
fi

# compile  json-c
if [ "$compile_args" = "" ] || [ "$compile_args" = "json-c" ]
then
	get_valid_package "${module_name[6]}.tar.gz"
    $grm "$root_build_path/${module_name[6]}"
    tar xf "$source_packet_path/${module_name[6]}.tar.gz"
    cd "$root_build_path/${module_name[6]}"
    ./configure --host=$g_host  --prefix="$root_release_path"
	sed -i 's/#undef malloc/\/\/#undef malloc/g' config.h.in    # 注释#undef malloc
	sed -i 's/#undef realloc/\/\/#undef realloc/g' config.h.in
    make -j6
    make install
fi

# compile gcrypt
if [ "$compile_args" = "" ] || [ "$compile_args" = "gcrypt" ]
then
	get_valid_package "${module_name[7]}.tar.gz"
    $grm "$root_build_path/${module_name[7]}"
    tar xf "$source_packet_path/${module_name[7]}.tar.gz"
    cd "$root_build_path/${module_name[7]}"
    ./configure --host=$g_host --disable-nls --disable-asm \
        --prefix="$root_release_path"
    make -j6
    make install
fi

# compile flex
if [ "$compile_args" = "" ] || [ "$compile_args" = "flex" ]
then
	get_valid_package "${module_name[8]}.tar.gz"
    $grm "$root_build_path/${module_name[8]}"
    tar xf "$source_packet_path/${module_name[8]}.tar.gz"
    cd "$root_build_path'/'${module_name[8]}"
    sed -i 's/#undef malloc//g' conf.in
    sed -i 's/#undef realloc//g' conf.in
    ./configure --host=$g_host CC=$g_cc --with-gnu-ld \
        --prefix="$root_release_path"
    make -j6
    make install
fi

# compile bison
if [ "$compile_args" = "" ] || [ "$compile_args" = "bison" ]
then
	get_valid_package "${module_name[9]}.tar.gz"
    $grm "$root_build_path/${module_name[9]}"
    tar xf "$source_packet_path/${module_name[9]}.tar.gz"
    cd "$root_build_path/${module_name[9]}"
    ./configure --host=$g_host CC=$g_cc --with-gnu-ld \
        --prefix="$root_release_path"
    make -j6
    make install
    cp "$root_build_path/${module_name[9]}/lib/libbison.a"  "$root_release_path/lib"
fi

# compile gmp
if [ "$compile_args" = "" ] || [ "$compile_args" = "gmp" ]
then
    get_valid_package "${module_name[10]}.tar.gz"
    $grm "$root_build_path/${module_name[10]}"
    tar xf "$source_packet_path/${module_name[10]}.tar.gz"
    cd "$root_build_path/${module_name[10]}"
    ./configure --host=$g_host CC=$g_cc --with-gnu-ld \
        --prefix="$root_release_path"
    make -j6
    make install
fi

# compile libmnl
if [ "$compile_args" = "" ] || [ "$compile_args" = "libmnl" ]
then
    get_valid_package "${module_name[11]}.tar.bz2"
    $grm "$root_build_path/${module_name[11]}"
    tar xf "$source_packet_path/${module_name[11]}.tar.bz2"
    cd "$root_build_path/${module_name[11]}"
    ./configure --host=$g_host CC=$g_cc --with-gnu-ld \
        --prefix="$root_release_path"
    make -j6
    make install
fi


# compile libnftnl
if [ "$compile_args" = "" ] || [ "$compile_args" = "libnftnl" ]
then
	get_valid_package "${module_name[12]}.tar.bz2"
    $grm "$root_build_path/${module_name[12]}"
    tar xf "$source_packet_path/${module_name[12]}.tar.bz2"
    cd "$root_build_path'/'${module_name[12]}"
    export LIBMNL_CFLAGS="$toolchain_includepath/libmnl/"
    export LIBMNL_LIBS="$toolchain_libpath -lmnl"
    ./configure --host=$g_host CC=$g_cc --with-gnu-ld \
        --prefix="$root_release_path"
    make -j6
    make install
fi

# compile readline
if [ "$compile_args" = "" ] || [ "$compile_args" = "readline" ]
then
    get_valid_package "${module_name[13]}.tar.gz" 
    $grm "$root_build_path/${module_name[13]}"
    tar xf "$source_packet_path/${module_name[13]}.tar.gz"
    cd "$root_build_path/${module_name[13]}"
    sed -i '6324s/yes/no/g' configure
    ./configure --host=$g_host CC=$g_cc \
        --prefix="$root_release_path"
    make -j6
    make install
fi


# compile nftables
if [ "$compile_args" = "" ] || [ "$compile_args" = "nftables" ]
then
    get_valid_package "${module_name[14]}.tar.bz2" 
    $grm "$root_build_path/${module_name[14]}"
    tar xf "$source_packet_path/${module_name[14]}.tar.bz2"
    cd "$root_build_path/${module_name[14]}"
    LIBMNL_CFLAGS="$toolchain_includepath/libmnl/" \
        LIBMNL_LIBS="$toolchain_libpath -lmnl" \
        LIBNFTNL_CFLAGS="$toolchain_includepath/libnftnl/" \
        LIBNFTNL_LIBS="$toolchain_libpath -lnftnl" \
        ./configure --host=$g_host CC=$g_cc --without-cli \
        --prefix="$root_release_path"
    make -j6
    make install
fi

# compile binutils
if [ "$compile_args" = "" ] || [ "$compile_args" = "binutils" ]
then
    get_valid_package "${module_name[15]}.tar.gz"
    $grm "$root_build_path/${module_name[15]}"
    tar xf "$source_packet_path/${module_name[15]}.tar.gz"
    cd "$root_build_path/${module_name[15]}"
    ./configure --host=$g_host CC=$g_cc --without-cli \
        --prefix="$root_release_path"
    make -j6
    make install
fi

# compile coreutils
if [ "$compile_args" = "" ] || [ "$compile_args" = "coreutils" ]
then
    get_valid_package "${module_name[16]}.tar.xz" 
    $grm "$root_build_path/${module_name[16]}"
    tar xf "$source_packet_path/${module_name[16]}.tar.xz"
    cd "$root_build_path/${module_name[16]}"
    ./configure --host=$g_host CC=$g_cc --without-cli \
        --prefix="$root_release_path"
    make -j6
    make install
fi

# compile procps-ng
if [ "$compile_args" = "" ] || [ "$compile_args" = "procps" ]
then
    get_valid_package "${module_name[17]}.tar.gz" 
    $grm "$root_build_path/${module_name[17]}"
    tar xf "$source_packet_path/${module_name[17]}.tar.gz"
    cd "$root_build_path/${module_name[17]}"
    NCURSES_CFLAGS="$toolchain_includepath/ncurses"  \
        NCURSES_LIBS="$toolchain_libpath -lncurses"  \
        ./configure --host=$g_host CC=$g_cc \
        --prefix="$root_release_path"
    make -j6
    make install
fi

# compile util-linux
# --disable-skill: 禁用过时和不可靠的技能和snice命令。
# --disable-kill:  禁用构建在util-linux包中安装的kill命令。
# Installed programs:
#     free, pgrep, pkill, pmap, ps, pwdx, slabtop, sysctl, tload, top, uptime, vmstat, w, and, watch
if [ "$compile_args" = "" ] || [ "$compile_args" = "utillinux" ]
then
    get_valid_package "${module_name[18]}.tar.gz"
    $grm "$root_build_path/${module_name[18]}"
    tar xf "$source_packet_path/${module_name[18]}.tar.gz"
    cd "$root_build_path/${module_name[18]}"
    NCURSES_CFLAGS="$toolchain_includepath"  \
        NCURSES_LIBS="$toolchain_libpath -lncurses"  \
        ./configure --host=$g_host CC=$g_cc \
        --prefix="$root_release_path"
    make -j6
    make install
fi

# compile libcap
if [ "$compile_args" = "" ] || [ "$compile_args" = "libcap" ]
then
    get_valid_package "${module_name[19]}.tar.gz" 
    $grm "$root_build_path/${module_name[19]}"
    tar xf "$source_packet_path/${module_name[19]}.tar.gz"
    cd "$root_build_path/${module_name[19]}"
    prefix="$root_release_path" make install
fi

# compile findtuils
if [ "$compile_args" = "" ] || [ "$compile_args" = "findutils" ]
then
    get_valid_package "${module_name[20]}.tar.gz"
    $grm "$root_build_path/${module_name[20]}"
    tar xf "$source_packet_path/${module_name[20]}.tar.gz"
    cd "$root_build_path/${module_name[20]}"
    ./configure --host=$g_host CC=$g_cc \
        --prefix="$root_release_path"
    make -j6
    make install
fi

#comile zlib
if [ "$compile_args" = "" ] || [ "$compile_args" = "zlib" ]
then
    get_valid_package "${module_name[21]}.tar.gz" 
    $grm "$root_build_path/${module_name[21]}"
    tar xf "$source_packet_path/${module_name[21]}.tar.gz"
    cd "$root_build_path/${module_name[21]}"
    CC=$g_cc ./configure --prefix="$root_release_path"
    make -j6
    make install
fi

#comile openssh
if [ "$compile_args" = "" ] || [ "$compile_args" = "openssh" ]
then
    get_valid_package "${module_name[22]}.tar.gz" 
    $grm "$root_build_path/${module_name[22]}"
    tar xf "$source_packet_path/${module_name[22]}.tar.gz"
    cd "$root_build_path/${module_name[22]}"
    exprot prefix="$root_release_path"
    ./configure --host=$g_host CC=$g_cc \
        --prefix="$root_release_path"
    make -j6
    make install
fi

#comile bash 
if [ "$compile_args" = "" ] || [ "$compile_args" = "bash" ]
then
    get_valid_package "${module_name[23]}.tar.gz" 
    $grm "$root_build_path/${module_name[23]}"
    tar xf "$source_packet_path/${module_name[23]}.tar.gz"
    cd "$root_build_path/${module_name[23]}"
    ./configure  --enable-static-link --without-bash-malloc \
        --host=$g_host --prefix="$root_release_path"
    make -j6
    make install
fi

#comile net-tool 
if [ "$compile_args" = "" ] || [ "$compile_args" = "nettool" ]
then
    get_valid_package "${module_name[24]}.tar.gz"
    $grm "$root_build_path/${module_name[24]}"
    tar xf "$source_packet_path/${module_name[24]}.tar.gz"
    cd "$root_build_path/${module_name[24]}"
    export "$root_release_path"
    CC=$g_cc  make
    make
fi

#comile bash
if [ "$compile_args" = "" ] || [ "$compile_args" = "sed" ]
then
    get_valid_package "${module_name[25]}.tar.gz"
    $grm "$root_build_path/${module_name[25]}"
    tar xf "$source_packet_path/${module_name[25]}.tar.gz"
    cd "$root_build_path/${module_name[25]}"
    ./configure  --enable-static-link --without-bash-malloc \
        --host=$g_host --prefix="$root_release_path"
    make -j4
    make install
fi

# compile ncurses
if [ "$compile_args" = "" ] || [ "$compile_args" = "ncurses" ]
then
	get_valid_package "${module_name[26]}.tar.gz"
    $grm "$root_build_path/${module_name[26]}"
    tar xf "$source_packet_path/${module_name[26]}.tar.gz"
    cd "$root_build_path/${module_name[26]}"
    ./configure --host=$g_host \
        --prefix="$root_release_path"
    make -j6
    make install
fi

# compile inetutils
if [ "$compile_args" = "" ] || [ "$compile_args" = "inetutils" ]
then
    get_valid_package "${module_name[27]}.tar.gz"
    $grm "$root_build_path/${module_name[27]}"
    tar xf "$source_packet_path/${module_name[27]}.tar.gz"
    cd "$root_build_path/${module_name[27]}"
    ./configure --host=$g_host --disable-clients --disable-ipv6 --disable-ncurses \
        --prefix="$root_release_path" \
        CC=$g_cc
    make -j6
    make install
    cp -a ping/ping ping/ping6 "$root_release_path/bin"
fi

# compile wrappers
# TCP Wrapper是一个基于主机的网络访问控制表系统
# 用于过滤对类Unix系统（如Linux或BSD）的网络访问。其能将主机或子网IP地址、名称及ident查询回复作为筛选标记，实现访问控制。
if [ "$compile_args" = "" ] || [ "$compile_args" = "wrappers" ]
then
    get_valid_package "${module_name[28]}.tar.gz"
    $grm "$root_build_path/${module_name[28]}"
    tar xf "$source_packet_path/${module_name[28]}.tar.gz"
    cd "$root_build_path/${module_name[28]}"
	wget -p http://www.linuxfromscratch.org/patches/blfs/6.3/tcp_wrappers-7.6-shared_lib_plus_plus-1.patch
	mv ./www.linuxfromscratch.org/patches/blfs/6.3/tcp_wrappers-7.6-shared_lib_plus_plus-1.patch ./
	rm -r www.linuxfromscratch.org
    #cp $source_packet_path/tcp_wrappers-7.6-shared_lib_plus_plus-1.patch ./
	patch -Np1 -i tcp_wrappers-7.6-shared_lib_plus_plus-1.patch
	sed -i -e "s,^extern char \*malloc();,/* & */," scaffold.c
	make REAL_DAEMON_DIR="$root_release_path" STYLE=-DPROCESS_OPTIONS linux CC=$g_cc
    make install
	cp tcpd tcpdmatch tcpdchk try-from safe_finger "$root_release_path/sbin"
	cp tcpd.h "$root_release_path/include"
	cp shared/libwrap* "$root_release_path/lib"
fi

# compile Python2.7.3
# 交叉编译:
# 在交叉编译Python时，需要用到pgen解释器，如果编译的是arm架构的解释器，显然是不能在PC上运行的，会导致编译失败，所以要首先编译出一个能在PC上运行的pgen
if [ "$compile_args" = "" ] || [ "$compile_args" = "Python2.7.3" ]
then
python_2_7_3_patch=$root_path/conf/Python-2.7.3-xcompile.patch
    get_valid_package "${module_name[29]}.tar.bz2"
    $grm "$root_build_path/${module_name[29]}"
    tar xf "$source_packet_path/${module_name[29]}.tar.bz2"
    cd "$root_build_path/${module_name[29]}"
    ./configure
	#1、编译PC上运行的pgen，并备份
	make python Parser/pgen
	mv python hostpython
	mv Parser/pgen Parser/hostpgen
	make distclean
    #2、打补丁
	patch -p1 < "$python_2_7_3_patch"
	#3、配置
	echo ac_cv_file__dev_ptmx=no > config.site
	echo ac_cv_file__dev_ptc=no >> config.site
	export CONFIG_SITE=config.site
	./configure CC=$g_cc CXX=$g_cxx AR=$g_ar RANLIB=$g_ranlib LD=$g_ld NM=$g_nm --host=arm-linux-gnueabihf --build=x86_64-linux --disable-ipv6
    #4、编译安装
	make HOSTPYTHON=./hostpython HOSTPGEN=./Parser/hostpgen BLDSHARED="$g_cc -shared" CROSS_COMPILE=$g_compile CROSS_COMPILE_TARGET=yes HOSTARCH=g_host BUILDARCH=x86_64-linux
	make install HOSTPYTHON=./hostpython BLDSHARED="$g_cc -shared" CROSS_COMPILE=$g_compile CROSS_COMPILE_TARGET=yes prefix="$root_release_path"
fi

# compile libcap-ng
# libcap-ng库旨在使POSIX功能的编程比传统的libcap库更容易。它包括可以分析所有当前运行的应用程序以查找可能拥有太多权限的应用程序的实用程序。
# 依赖库:
# Python2.7; 注意Python编译出来的头文件是放在一个Python2.7的目录里，当把这个目录拷贝到交叉编译工具include目录时，首先要
# 在include中建立一个arm-linux-gnueabihf文件夹，然后把Python2.7文件夹拷贝到arm-linux-gnueabihf里。因为本地python在检测
# 是编译arm版本是，寻找到arm版本头文件路径前有arm-linux-gnueabihf
if [ "$compile_args" = "" ] || [ "$compile_args" = "libcap-ng" ]
then
    get_valid_package "${module_name[30]}.tar.gz"
    $grm "$root_build_path/${module_name[30]}"
    tar xf "$source_packet_path/${module_name[30]}.tar.gz"
    cd "$root_build_path/${module_name[30]}"
    ./configure --host=$g_host --prefix="$root_release_path" CC=$g_cc
    make -j6
    make install
fi

# compile db
# Installed Programs:
#   db_archive, db_checkpoint, db_deadlock, db_dump, db_hotbackup, db_load, db_log_verify, db_printlog, 
#   db_recover, db_replicate, db_stat, db_tuner, db_upgrade, and db_verify
if [ "$compile_args" = "" ] || [ "$compile_args" = "db" ]
then
    get_valid_package "${module_name[31]}.tar.gz"
    $grm "$root_build_path/${module_name[31]}"
    tar xf "$source_packet_path/${module_name[31]}.tar.gz"
    cd "$root_build_path/${module_name[31]}/build_unix"
	../dist/configure --enable-compat185 --enable-compat185 --disable-static --enable-cxx \
		--prefix="$root_release_path" --host=$g_host \
		CC="$g_cc $CFLAGS"
    make -j6
    make docdir="$root_release_path/doc/db-5.3.28" install
	#chown -v -R root:root                        \
	#   $root_release_path/bin/db_*                          \
	#   $root_release_path/include/db{,_185,_cxx}.h          \
	#   $root_release_path/lib/libdb*.{so,la}                \
	#   $root_release_path/doc/db-6.2.32
fi

# compile openldap
#	ldap协议库
# 依赖库: db
#    注意openldap-2.4.44依赖的db库要求版本在4.4到6.0.20之间，否则会提示: configure: error: BerkeleyDB version incompatible with BDB/HDB backends
# 错误：
#      出现undefined reference to `lutil_memcmp'错误，解决方法：
#      在openldap-2.4.16/include/ac/string.h中注释92-95行
#        /*#ifdef NEED_MEMCMP_REPLACEMENT
#            int (lutil_memcmp)(const void *b1, const void *b2, size_t len);
#		     #define memcmp lutil_memcmp
#		   #endif*/
#      重新配置编译
if [ "$compile_args" = "" ] || [ "$compile_args" = "openldap" ]
then
    get_valid_package "${module_name[32]}.tgz"
    $grm "$root_build_path/${module_name[32]}"
    tar xf "$source_packet_path/${module_name[32]}.tgz"
    cd "$root_build_path/${module_name[32]}"
	sed -i '95a */' include/ac/string.h       #注释lutil_memcmp错误
	sed -i '91a /*' include/ac/string.h
	./configure --disable-ipv6 --with-yielding_select=yes --prefix="$root_release_path" --host=$g_host CC="$g_cc $CFLAGS"
	make depend
    make -j6
    make install
fi

# compile Python3.6
# 前提：在系统中没有安装Python3.6，请先安装Python3.6，否则无法构建
if [ "$compile_args" = "" ] || [ "$compile_args" = "Python3.6" ]
then
    get_valid_package "${module_name[33]}.tar.xz"
    $grm "$root_build_path/${module_name[33]}"
    tar xf "$source_packet_path/${module_name[33]}.tar.gz"
    cd "$root_build_path/${module_name[33]}"
    ./configure CC=$g_cc CXX=$g_cxx AR=$g_ar RANLIB=$g_ranlib LD=$g_ld NM=$g_nm --host=$g_host --build=armv7 --disable-ipv6 ac_cv_file__dev_ptmx="yes" ac_cv_file__dev_ptc="no" prefix="$root_release_path"
    make -j6
    make install
fi

# compile krb5-1.14.5
# 说明：
#     Kerberos协议主要用于计算机网络的身份鉴别，它使网络上的用户可以相互证明自己的身份。
# 错误：
#     出现“can not upload ^^^^^^^” 注释掉./include/k5-platform.h中的
#     //#else
#     //# error "Don't know how to do unload-time finalization for this configuration."
#     出现 kadmin.c:212:5: warning: function might be possible candidate for ‘gnu_printf’ format attribute
#     将 vfprintf改成 gnu_printf不管用，改成 fprintf就管用了
if [ "$compile_args" = "" ] || [ "$compile_args" = "krb5" ]
then
    get_valid_package "${module_name[34]}.tar.xz"
    $grm "$root_build_path/${module_name[34]}"
    tar xf "$source_packet_path/${module_name[34]}.tar.gz"
    cd "$root_build_path/${module_name[34]}"
	echo krb5_cv_attr_constructor_destructor=yes>linux-cache
	echo ac_cv_func_regcomp=yes>linux-cache
	echo ac_cv_printf_positional=yes>linux-cache
	echo ac_cv_file__etc_environment=yes>linux-cache
	echo ac_cv_file__etc_TIMEZONE=yes>linux-cache
	echo ac_cv_lib_resolv_res_search=yes>linux-cache
    ./configure CC="$g_cc" --host="$g_host" prefix="$root_release_path" --cache-file=linux-cache
    make -j6
    make install
fi


# compile swig
# 说明：
#     SWIG是个帮助使用C或者C++编写的软件能与其它各种高级编程语言进行嵌入联接的开发工具。
# SWIG能应用于各种不同类型的语言包括常用脚本编译语言例如Perl, PHP, Python, Tcl, Ruby and PHP
if [ "$compile_args" = "" ] || [ "$compile_args" = "swig" ]
then
    get_valid_package "${module_name[35]}.tar.gz"
    $grm "$root_build_path/${module_name[35]}"
    tar xf "$source_packet_path/${module_name[35]}.tar.gz"
    cd "$root_build_path/${module_name[35]}"
	./configure prefix="$root_release_path" --host="$g_host"
    make -j6
    make install
fi

# compile audit
# 依赖库：
# libwrap-->tcp_wrappers 需要把编译出来的库和源码里tcpd.h文件拷到工具相对应目录才能配置通道
# libcap-ng krb5 libldap python2 python3 swig
# 编译错误还没解决 
if [ "$compile_args" = "" ] || [ "$compile_args" = "audit" ]
then
    get_valid_package "${module_name[36]}.tar.gz"
     $grm "$root_build_path/${module_name[36]}"
    tar xf "$source_packet_path/${module_name[36]}.tar.gz"
    cd "$root_build_path/${module_name[36]}"
	./configure --with-python=yes --with-libwrap --enable-gssapi-krb5=yes --with-libcap-ng=yes \
		prefix="$root_release_path" --sbindir="$root_release_path/sbin" \
		--host=$g_host CC="$g_cc $CFLAGS"
    make -j6
    make install
fi

# compile popt
# 说明：
#     解析命令行选项.它不使用全局变量，因此可以并行解析argv；它可以解析任意的argv风格的元素数组，
#     可以解析来自任何源文件的命令行字符串
if [ "$compile_args" = "" ] || [ "$compile_args" = "popt" ]
then
    get_valid_package "${module_name[37]}.tar.gz"
    $grm "$root_build_path/${module_name[37]}"
    tar xf "$source_packet_path/${module_name[37]}.tar.gz"
    cd "$root_build_path/${module_name[37]}"
	./configure prefix="$root_release_path" --host="$g_host" CC=$g_cc \
		--enable-shared=no --enable-static=yes
    make -j6
    make install
fi

# compile logrotate
# 说明：
#     解析命令行选项.它不使用全局变量，因此可以并行解析argv；它可以解析任意的argv风格的元素数组，
#     可以解析来自任何源文件的命令行字符串
if [ "$compile_args" = "" ] || [ "$compile_args" = "logrotate" ]
then
    get_valid_package "${module_name[38]}.tar.gz"
    $grm "$root_build_path/${module_name[38]}"
    tar xf "$source_packet_path/${module_name[38]}.tar.gz"
    cd "$root_build_path/${module_name[38]}"
	./configure prefix="$root_release_path" --host="$g_host" CC=$g_cc 
    make -j6
    make install
fi



