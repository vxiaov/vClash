#! /bin/sh
#########################################################
# Clash Process Control script for AM380 merlin firmware
# Writen by Awkee (next4nextjob(at)gmail.com)
# Website: https://vlike.work
#########################################################

KSHOME="/koolshare"

source ${KSHOME}/scripts/base.sh

app_name="clash"
eval $(dbus export $app_name)
LOGGER() {
    # Magic number for Log 9977
    logger -s -t "$(date +%Y年%m月%d日%H:%M:%S):clash" "$@"
}

# ================================== INSTALL_CHECK 安装前的系统信息检查 =========================

ARCH=""
# 暂时支持ARM芯片吧，等手里有 MIPS 芯片再适配
case $(uname -m) in
    armv7l) 
        if grep -i vfpv3 /proc/cpuinfo >/dev/null 2>&1 ; then
            ARCH="armv7"
        elif grep -i vfpv1 /proc/cpuinfo >/dev/null 2>&1 ; then
            ARCH="armv6"
        else
            ARCH="armv5"
        fi
    ;;
    *)
        LOGGER "糟糕！平台类型不支持呀！赶紧通知开发者适配！或者自己动手丰衣足食！"
        exit 0
    ;;
esac

# 固件版本检测
build_ver="$(nvram get buildno| cut -d '.' -f1)"
if [ "$build_ver" != "380" ] ; then
    LOGGER "很抱歉！本插件只支持 KS梅林固件的380.xx版本!"
    exit 2
fi
LOGGER "梅林固件版本： $build_ver"

ks_ver=$(dbus get softcenter_version)
if [ "$ks_ver" = "" ] ; then
    LOGGER "找不到软件中心版本信息！你确定这是KS梅林固件?"
    exit 3
fi
LOGGER "软件中心版本: $ks_ver"

bin_list="${app_name} yq uri_decoder"

# 清理旧文件，升级情况需要
remove_files() {
    LOGGER 清理旧文件
    rm -rf /koolshare/${app_name}
    rm -rf /koolshare/scripts/${app_name}_*
    rm -rf /koolshare/webs/Module_${app_name}.asp
    for fn in ${bin_list}; do
        rm -f /koolshare/bin/${fn}
    done
    rm -rf /koolshare/res/icon-${app_name}.png
    rm -rf /koolshare/res/${app_name}_*
    rm -rf /koolshare/init.d/S??${app_name}.sh
}

# ================================== INSTALL_START 开始安装 =========================

copy_files() {
    LOGGER 开始复制文件！
    cd /tmp/${app_name}/
    mkdir -p /koolshare/${app_name}

    LOGGER 复制相关二进制文件！此步时间可能较长！
    for fn in ${bin_list}; do

        cp -f ./bin/${fn}_for_${ARCH} /koolshare/bin/${fn}
        chmod +x /koolshare/bin/${fn}
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
    [ ! -L "/koolshare/init.d/S99${app_name}.sh" ] && ln -sf /koolshare/scripts/${app_name}_control.sh /koolshare/init.d/S99${app_name}.sh
    
    LOGGER 添加Clash面板页面软链接
    [ ! -L "/www/ext/dashboard" ] && ln -sf /koolshare/${app_name}/dashboard /www/ext/dashboard
}

# 设置初始化环境变量信息 #
init_env() {
    LOGGER 设置一些默认值
    # 默认不启用
    [ -z "$(eval echo '$'${app_name}_enable)" ] && dbus set ${app_name}_enable="off"
    
    # 默认组节点选择模式为 url-test
    dbus set clash_group_type="url-test"
    dbus set clash_provider_file="https://raw.githubusercontent.com/learnhard-cn/free_proxy_ss/main/clash/clash.provider.yaml"
    dbus set clash_provider_file_old="https://cdn.jsdelivr.net/gh/learnhard-cn/free_proxy_ss@main/clash/clash.provider.yaml"

    # 离线安装时设置软件中心内储存的版本号和连接
    CUR_VERSION=$(cat /koolshare/${app_name}/version)
    dbus set ${app_name}_version="$CUR_VERSION"
    dbus set softcenter_module_${app_name}_install="1"
    dbus set softcenter_module_${app_name}_version="$CUR_VERSION"
    dbus set softcenter_module_${app_name}_title="Clash版科学上网"
    dbus set softcenter_module_${app_name}_description="Clash版科学上网 for merlin armv7l 380"
    dbus set softcenter_module_${app_name}_home_url="Module_${app_name}.asp"
}

# 判断是否需要重启，对于升级插件时需要
need_action() {
    action=$1
    if [ "$(eval echo '$'$app_name}_enable)" == "1" ]; then
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

## main 安装流程

LOGGER Clash版科学上网插件开始安装！

need_action stop    # 安装前，停止已安装应用
remove_files        # 清理历史遗留文件，如果有
copy_files          # 安装需要的所有文件
init_env            # 初始化环境变量信息,设置插件信息
need_action restart # 是否需要重启服务
clean               # 清理安装包

LOGGER Clash版科学上网插件安装成功！
