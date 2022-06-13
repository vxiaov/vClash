#! /bin/sh
#########################################################
# Clash Process Control script for ASUS/merlin firmware compiled by Koolshare
# Writen by Awkee (next4nextjob(at)gmail.com)
# Website: https://vlike.work
#########################################################

KSHOME="/koolshare"

source ${KSHOME}/scripts/base.sh

app_name="clash"
WKDIR="$(dirname $0)"    # 获取脚本所在目录


# 软硬件基本信息 #
MODEL=""            # 路由器设备型号
ARCH=""             # CPU架构
FW_TYPE_NAME=""     # 固件类型名称
# BUILD_VERSION=""    # 固件版本信息

BUILD_VERSION="$(nvram get buildno| cut -d '.' -f1)"

LINUX_VER=$(uname -r|awk -F"." '{print $1$2}')  # Linux内核版本

BIN_LIST="${app_name} yq uri_decoder jq"

# 反馈问题链接
open_issue="请将安装过程日志内容(上面的所有内容)复制好后反馈给开发者,以便于帮您找到安装失败原因！反馈地址: https://github.com/learnhard-cn/vClash/issues/"

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
        LOGGER "糟糕！ 不支持 `uname -m` 平台呀！ 您的路由器型号:$MODEL ,固件类型： $FW_TYPE_NAME ,固件版本：$BUILD_VERSION ,$open_issue"
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
            ARCH="armv8"  # hnd 平台 可以使用 armv5/v6/v7/v8 可执行程序
        ;;
        *)
            exit_install 1
            exit 0
        ;;
    esac
    LOGGER "CPU架构: $ARCH 符合安装要求!"
}

# 固件平台支撑检测
platform_test(){
    # 判断CPU架构
    get_arch

    # 判断KoolShare支持的固件平台
    if [ -d "/koolshare" -a -x "/koolshare/bin/httpdb" -a -x "/usr/bin/skipd" ];then
        LOGGER "KoolShare支持的固件平台!"
    else
        exit_install 1
    fi
    
    ks_ver=$(dbus get softcenter_version | awk -F'.' '{ print $1$2 }')
    if [ "$ks_ver" -lt "15" ];then
        LOGGER "很遗憾! 软件中心版本: $(dbus get softcenter_version) (v1.5版本及以上即可) 不符合安装要求！"
        exit_install 2
    fi
    LOGGER "软件中心版本: $(dbus get softcenter_version) (v1.5版本及以上即可) 符合安装要求！"
}

get_model(){
	local ODMPID=$(nvram get odmpid)
	local PRODUCTID=$(nvram get productid)
	if [ -n "${ODMPID}" ];then
		MODEL="${ODMPID}"
	else
		MODEL="${PRODUCTID}"
	fi
}

get_fw_type() {
    local KS_TAG=$(nvram get extendno|grep koolshare)
    if [ -d "$KSHOME" ];then
        if [ -n "${KS_TAG}" ];then
            FW_TYPE_CODE="2"
            FW_TYPE_NAME="koolshare官改固件"
        else
            FW_TYPE_CODE="4"
            FW_TYPE_NAME="koolshare梅林改版固件"
        fi
    else
        if [ "$(uname -o|grep Merlin)" ];then
            FW_TYPE_CODE="3"
            FW_TYPE_NAME="梅林原版固件"
        else
            FW_TYPE_CODE="1"
            FW_TYPE_NAME="华硕官方固件"
        fi
    fi
}

# 清理旧文件，升级情况需要
remove_files() {
    
    if [ -d "/koolshare/${app_name}" ] ; then
        LOGGER 开始 清理旧文件
        rm -rf /koolshare/${app_name}
        rm -rf /koolshare/scripts/${app_name}_*
        rm -rf /koolshare/webs/Module_${app_name}.asp
        for fn in ${BIN_LIST}; do
            rm -f /koolshare/bin/${fn}
        done
        rm -rf /koolshare/res/icon-${app_name}.png
        rm -rf /koolshare/res/${app_name}_*
        rm -rf /koolshare/init.d/S??${app_name}.sh
        LOGGER 完成 清理旧文件
    else
        LOGGER "没有找到旧文件，跳过清理旧文件"
    fi
}

# 安装前的目录检查工作 
dir_test() {

    if [ ! -d "/koolshare" ]; then
        LOGGER "错误: 找不到 /koolshare 目录！"
        exit_install 1
    fi
    if [ ! -d "/koolshare/init.d" ]; then
        echo "错误: 找不到 /koolshare/init.d 目录！"
        exit_install 2
    fi
    if [ ! -d "/koolshare/scripts" ]; then
        echo "错误: 找不到 /koolshare/scripts 目录！"
        exit_install 3
    fi
    if [ ! -d "/koolshare/webs" ]; then
        echo "错误: 找不到 /koolshare/webs 目录！"
        exit_install 4
    fi
    if [ ! -d "/koolshare/res" ]; then
        echo "错误: 找不到 /koolshare/res 目录！"
        exit_install 5
    fi
    if [ ! -d "/koolshare/bin" ]; then
        echo "错误: 找不到 /koolshare/bin 目录！"
        exit_install 6
    fi
}

copy_files() {
    LOGGER 开始复制文件！
    # 确保进入的目录是当前文件所在目录
    cd ${WKDIR}
    mkdir -p /koolshare/${app_name}

    LOGGER 复制相关二进制文件！此步时间可能较长！
    for fn in ${BIN_LIST}; do

        # cp -f ./bin/${fn}_for_${ARCH} /koolshare/bin/${fn}
        if [ -f "./bin/${fn}_for_${ARCH}" ]; then
            cp -f ./bin/${fn}_for_${ARCH} /koolshare/bin/${fn}
        else
            LOGGER "错误: 找不到 ./bin/${fn}_for_${ARCH} 文件！"
            exit_install 1
        fi
        
        chmod +x /koolshare/bin/${fn}   # 设置可执行权限
        LOGGER "安装可执行程序: ${fn} 完成."
    done

    LOGGER 复制相关的脚本文件！
    cp -rf ./${app_name}/ /koolshare/
    cp -f ./scripts/${app_name}_*.sh /koolshare/scripts/
    cp -f ./uninstall.sh /koolshare/scripts/uninstall_${app_name}.sh

    chmod 755 /koolshare/scripts/${app_name}_*.sh

    LOGGER 复制相关的网页文件！
    cp -rf ./webs/Module_${app_name}.asp /koolshare/webs/
    cp -rf ./res/${app_name}_* /koolshare/res/
    cp -rf ./res/icon-${app_name}.png /koolshare/res/

    LOGGER 添加自启动脚本软链接
    ln -sf /koolshare/scripts/${app_name}_control.sh /koolshare/init.d/S99${app_name}.sh
    LOGGER 完成复制所有文件工作！
}

# 设置初始化环境变量信息 #
init_env() {
    LOGGER 设置一些默认值
    # 默认不启用
    [ -z "$(eval echo '$'${app_name}_enable)" ] && dbus set ${app_name}_enable="off"

    dbus set clash_provider_file="https://cdn.jsdelivr.net/gh/learnhard-cn/free_proxy_ss@main/clash/clash.provider.yaml"
    dbus set clash_provider_file_old="https://cdn.jsdelivr.net/gh/learnhard-cn/free_proxy_ss@main/clash/clash.provider.yaml"
    dbus set clash_geoip_url="https://raw.githubusercontent.com/alecthw/mmdb_china_ip_list/release/Country.mmdb"
    dbus set clash_trans="on"           # 默认开启透明代理模式
    dbus set clash_rule_mode="blacklist" # 默认为黑名单模式
    dbus set clash_cfddns_enable="off"  # 默认关闭DDNS解析
    
    vClash_VERSION=$(sed -n '1p' /koolshare/${app_name}/version| cut -d: -f2)
    CLASH_VERSION=$(sed -n '2p' /koolshare/${app_name}/version| cut -d: -f2)
    dbus set ${app_name}_version="$CLASH_VERSION"

    # 离线安装时设置软件中心内储存的版本号和连接
    dbus set softcenter_module_${app_name}_install="1"
    dbus set softcenter_module_${app_name}_version="$vClash_VERSION"
    dbus set softcenter_module_${app_name}_title="Clash版科学上网"
    dbus set softcenter_module_${app_name}_description="Clash版科学上网 for Koolshare"
    dbus set softcenter_module_${app_name}_home_url="Module_${app_name}.asp"
}

# 判断是否需要重启，对于升级插件时需要
need_action() {
    action=$1
    if [ "$(eval echo '$'$app_name}_enable)" == "on" ]; then
        LOGGER 安装前需要的执行操作: ${action} ！
        sh /koolshare/scripts/${app_name}_control.sh ${action}
    fi

}

# 清理安装包
clean() {
    LOGGER 移除安装包！
    cd /tmp
    rm -rf /tmp/${app_name}  /tmp/${app_name}.tar.gz >/dev/null 2>&1
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

    LOGGER Clash版科学上网插件安装成功！
    LOGGER "忠告: Clash运行时分配很大虚拟内存，可能在700MB左右, 如果你的内存很小，那么启动失败的概率很大！"
    LOGGER "解决办法是：用U盘挂载1GB的虚拟内存!切记！"
    LOGGER "如何挂载虚拟内存? 软件中心自带 虚拟内存 插件，安装即用！"
}

main
