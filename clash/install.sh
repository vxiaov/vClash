#! /bin/sh
#########################################################
# Clash Process Control script for ASUS/merlin firmware compiled by Koolshare
# Writen by vxiaov (next4nextjob(at)gmail.com)
# Website: https://vlike.work
#########################################################

KSHOME="/koolshare"

source ${KSHOME}/scripts/base.sh

app_name="clash"
# 配置文件根目录(如果希望使用最新版Clash，这是必要的，因为默认的/koolshare/分区为jffs2类型，不支持 mmap操作，结果就是无法缓存上次选择的节点，每次重启服务后都需要重新设置) #
CONFIG_HOME="$KSHOME/${app_name}/"
WKDIR="$(dirname $0)"    # 获取脚本所在目录


# 软硬件基本信息 #
MODEL="$(nvram get model)"           # 路由器设备型号
ARCH=""     # CPU架构

BUILD_VERSION="$(nvram get buildno)"

LINUX_VER=$(uname -r|awk -F"." '{print $1$2}')  # Linux内核版本

# 反馈问题链接
open_issue="请将安装过程日志内容(上面的所有内容)复制好后反馈给开发者,以便于帮您找到安装失败原因！反馈地址: https://github.com/vxiaov/vClash/issues/"

LOGGER() {
    logger -s -t "`date +%Y年%m月%d日%H:%M:%S`:clash" "$@"
}

# ================================== INSTALL_CHECK 安装前的系统信息检查 =========================

exit_install() {
    case "$1" in
    0)
        LOGGER "恭喜您!安装完成！"
        exit 0
    ;;
    *)
        LOGGER "糟糕 返回错误[$1]！ \n调试信息:\n主机类型:  `uname -m` ! \n路由器型号:$MODEL ,\n固件类型:${BUILD_VERSION}\n$open_issue"
        exit $1
    ;;
    esac
}

get_arch(){
    # CPU架构,决定使用哪个编译版本的可执行程序
    # 路由器机型及固件类型参考: https://github.com/koolshare/rogsoft

    case `uname -m` in
        armv7l)     # ARM平台
            ARCH="armv5"
        ;;
        aarch64)    # hnd(High end)平台
            ARCH="arm64"  # hnd 平台 可以使用 armv5/v6/v7/v8 可执行程序
        ;;
        amd64|x86_64)
            ARCH="amd64" 
            ;;
        *)
            exit_install 100
        ;;
    esac
    LOGGER "CPU架构: $ARCH 符合安装要求!"
}

# 固件平台支撑检测
platform_test(){
    # 判断CPU架构
    get_arch

    # 判断KoolShare支持的固件平台
    if [ -d "${KSHOME}"  ] ; then
        LOGGER "KoolShare目录存在，继续检测固件平台支持!"
    else
        exit_install 101
    fi

    if [ -x "${KSHOME}/bin/httpdb" ] ; then
        LOGGER "httpdb已安装，继续检测固件平台支持!"
    else
        exit_install 102
    fi

    if [ "$(which skipd)" != "" ] ; then
        # 384 位置为 /usr/sbin/skipd , 386 位置为 /usr/bin/skipd
        LOGGER "skipd已安装，继续检测固件平台支持!"
    else
        exit_install 103
    fi
}

# 清理旧文件，升级情况需要
remove_files() {
    if [ -d "${CONFIG_HOME}" ] ; then
        LOGGER 开始 清理旧文件
        rm -rf ${KSHOME}/scripts/${app_name}_*
        rm -rf ${KSHOME}/webs/Module_${app_name}.asp
        rm -rf ${KSHOME}/res/icon-${app_name}.png
        rm -rf ${KSHOME}/res/${app_name}_*
        rm -rf ${KSHOME}/init.d/S??${app_name}.sh
        LOGGER 完成 清理旧文件
    else
        LOGGER "没有找到旧文件，跳过清理旧文件"
    fi
}

# 安装前的目录检查工作 
dir_test() {
    if [ ! -d "${KSHOME}" ]; then
        LOGGER "错误: 找不到 ${KSHOME} 目录！"
        exit_install 1
    fi
    if [ ! -d "${KSHOME}/init.d" ]; then
        echo "错误: 找不到 ${KSHOME}/init.d 目录！"
        exit_install 2
    fi
    if [ ! -d "${KSHOME}/scripts" ]; then
        echo "错误: 找不到 ${KSHOME}/scripts 目录！"
        exit_install 3
    fi
    if [ ! -d "${KSHOME}/webs" ]; then
        echo "错误: 找不到 ${KSHOME}/webs 目录！"
        exit_install 4
    fi
    if [ ! -d "${KSHOME}/res" ]; then
        echo "错误: 找不到 ${KSHOME}/res 目录！"
        exit_install 5
    fi
    if [ ! -d "${KSHOME}/bin" ]; then
        echo "错误: 找不到 ${KSHOME}/bin 目录！"
        exit_install 6
    fi
}

copy_files() {
    LOGGER 开始复制文件！
    # 确保进入的目录是当前文件所在目录
    # cd ${WKDIR}
    mkdir -p ${CONFIG_HOME}

    LOGGER 复制相关的脚本文件！
    if [[  ! -d "${KSHOME}/${app_name}" ]]  ; then
        LOGGER "新建 ${KSHOME}/${app_name} 目录"
        mkdir ${KSHOME}/${app_name}
    fi
    [[ ! -d "${KSHOME}/${app_name}" ]] && LOGGER "目录缺失: ${KSHOME}/${app_name} ,无法继续安装!" && exit_install 10

    # 复制目录下所有文件和目录信息#
    for tn in `ls ${WKDIR}/${app_name}/` ;  do
        cp -rf ${WKDIR}/${app_name}/${tn} ${KSHOME}/${app_name}/ || LOGGER "拷贝 ${tn} 失败!"
    done

    cp -f ${WKDIR}/scripts/${app_name}_control.sh ${KSHOME}/scripts/  || LOGGER "拷贝 ${app_name}_control.sh 失败!"
    cp -f ${WKDIR}/uninstall.sh ${KSHOME}/scripts/uninstall_${app_name}.sh || LOGGER "拷贝 uninstall_${app_name}.sh 失败!"

    chmod 755 ${KSHOME}/scripts/${app_name}_*.sh

    LOGGER 复制相关的网页文件！
    cp -rf ${WKDIR}/webs/Module_${app_name}.asp ${KSHOME}/webs/ || LOGGER "拷贝 webs/Module_${app_name}.asp 文件失败!"
    cp -rf ${WKDIR}/res/clash_style.css ${KSHOME}/res/  || LOGGER "拷贝 res/clash_style.css 文件失败!"
    cp -rf ${WKDIR}/res/icon-${app_name}.png ${KSHOME}/res/ || LOGGER "拷贝 res/icon-${app_name}.png 文件失败!"

    LOGGER 添加自启动脚本软链接
    ln -sf ${KSHOME}/scripts/${app_name}_control.sh ${KSHOME}/init.d/S99${app_name}.sh
    LOGGER 完成复制所有文件工作！
}

# 设置初始化环境变量信息 #
init_env() {
    LOGGER 设置一些默认值
    # 默认不启用
    [ -z "$(eval echo '$'${app_name}_enable)" ] && dbus set ${app_name}_enable="off"

    vClash_VERSION=$(sed -n '1p' ${CONFIG_HOME}/version| cut -d: -f2)
    CLASH_VERSION=$(sed -n '2p' ${CONFIG_HOME}/version| cut -d: -f2)
    dbus set ${app_name}_version="$CLASH_VERSION"
    dbus set ${app_name}_vclash_version="$vClash_VERSION"
    dbus set ${app_name}_tmode="TPROXY"
    # 默认 DNS 配置解决 运营商DNS污染问题 #
    dbus set ${app_name}_ipv4_dns1="223.5.5.5"
    dbus set ${app_name}_ipv4_dns2="119.29.29.29"
    dbus set ${app_name}_ipv6_dns1="2402:4e00::"
    dbus set ${app_name}_ipv6_dns2="2400:3200::1"

    dbus set ${app_name}_config_filepath="config/config_meta.yaml"
    dbus set ${app_name}_arch_type=${ARCH}

    # 离线安装时设置软件中心内储存的版本号和连接
    dbus set softcenter_module_${app_name}_install="1"
    dbus set softcenter_module_${app_name}_version="${vClash_VERSION:1}"
    dbus set softcenter_module_${app_name}_title="Clash版科学上网"
    dbus set softcenter_module_${app_name}_description="Clash版科学上网 for Koolshare"
    dbus set softcenter_module_${app_name}_home_url="Module_${app_name}.asp"
}

# 判断是否需要重启，对于升级插件时需要
need_action() {
    action=$1
    if [ "$(eval echo '$'$app_name}_enable)" == "on" ]; then
        LOGGER 安装前需要的执行操作: ${action} ！
        sh ${KSHOME}/scripts/${app_name}_control.sh ${action}
    fi

}

# 清理安装包
clean() {
    LOGGER 移除安装包！
    cd /tmp
    rm -rf /tmp/${app_name} >/dev/null 2>&1
    echo "清理完成"
}

# ================================== INSTALL_START 开始安装 =========================

main() {
    LOGGER "Clash版科学上网插件开始安装！"

    platform_test       # 安装前平台支撑检测(只有符合条件才会继续安装)
    dir_test            # 安装前目录检测
    need_action stop    # 安装前，停止已安装应用
    cd ${WKDIR}
    remove_files        # 清理历史遗留文件，如果有
    copy_files          # 安装需要的所有文件
    init_env            # 初始化环境变量信息,设置插件信息
    need_action restart # 是否需要重启服务
    clean               # 清理安装包

    LOGGER Clash版科学上网插件安装成功!
    LOGGER "提示: Clash运行时分配很大虚拟内存，如果你的内存很小，那么启动失败的概率很大！"
    LOGGER "解决办法是: 用U盘挂载1GB的虚拟内存! 切记！"
    LOGGER "如何挂载虚拟内存? 软件中心自带 虚拟内存 插件，安装即用！"
    echo "安装完成!"
}

main
