#!/bin/sh
#########################################################
# Clash Process Control script for AM380 merlin firmware
# Writen by Awkee (next4nextjob(at)gmail.com)
# Website: https://vlike.work
#########################################################

KSHOME="/koolshare"
app_name="clash"

source ${KSHOME}/scripts/base.sh

eval $(dbus export ${app_name}_)

alias curl="curl --connect-timeout 300"
bin_list="${app_name} yq"
dns_port="53"

LOGGER() {
    # Magic number for Log 9977
    logger -s -t "$(date +'%Y年%m月%d日%H:%M:%S'):clash" "$@"
}

CMD="${app_name} -d ${KSHOME}/${app_name}/"
lan_ipaddr=$(nvram get lan_ipaddr)
if [ "$lan_ipaddr" = "" ]; then
    LOGGER "真糟糕！ nvram 命令没找到局域网路由器地址，这样防火墙规则配置不了啦！还是自己手动设置后再执行吧！"
    exit 1
fi
cron_id="daemon_clash_watchdog" # 调度ID,用来查询和删除操作标识
# 检测是否有 cru 命令
if [ ! -x "$(which cru)" ]; then
    if [ -x "$(which cru.sh)" ]; then
        alias cru="cru.sh"
    else
        LOGGER "糟糕！没有找到 cru 命令！ 这样配置不了调度啦！"
    fi
fi

usage() {
    cat <<END
 使用帮助:
    ${app_name} <start|stop|status|restart>
 参数介绍：
    start   启动服务
    stop    停止服务
    status  状态检查
    restart 重启服务
END
}

echo_status() {
    if [ "$1" = "head" ]; then
        printf "%-20s %-20s %-s" "进程名称" "进程号" "运行状态"
        return 0
    fi
    pids=$(pidof $1)
    if [ "$pids" == "" ]; then
        printf "%-15s %-15s %-s" "$1" "$pids" "已停止."
    else
        printf "%-15s %-15s %-s" "$1" "$pids" "正常运行中."
    fi
}

ARCH=""

# 暂时支持ARM芯片吧，等手里有 MIPS 芯片再适配
case $(uname -m) in
    armv7l)
        if grep -i vfpv3 /proc/cpuinfo >/dev/null 2>&1; then
            ARCH="armv7"
        elif grep -i vfpv1 /proc/cpuinfo >/dev/null 2>&1; then
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

get_proc_status() {
    LOGGER "检查进程信息："
    LOGGER "$(echo_status head)"
    LOGGER "$(echo_status $app_name)"
    LOGGER "$(echo_status dnsmasq)"
    echo "----------------------------------------------------"
    LOGGER "服务守护调度： [$(cru l | grep ${cron_id})]"
    if [ "$dns_port" != "53" ] ; then
        LOGGER "文件更新调度： [$(cru l| grep update_provider_local)]"
    fi
    echo "----------------------------------------------------"
    LOGGER "Clash版本信息： $(clash -v)"
    LOGGER "yq工具版本信息： $(yq -V)"
    echo "----------------------------------------------------"

}

# 添加守护监控脚本
add_cron() {
    if cru l | grep ${cron_id} >/dev/null; then
        LOGGER "进程守护脚本已经添加!不需要重复添加吧？！？"
        return 0
    fi
    cru a "${cron_id}" "*/2 * * * * /koolshare/scripts/clash_control.sh start"
    if [ "$dns_port" != "53" ] ; then
        # 使用iptables转发53端口请求时需要更新
        cru a "update_gfwlist" "0 12 * * * /koolshare/scripts/clash_control.sh update_gfwlist"
    fi
    if cru l | grep ${cron_id} >/dev/null; then
        LOGGER "添加进程守护脚本成功!"
    else
        LOGGER "不知道啥原因，守护脚本没添加到调度里！赶紧查查吧！"
        return 1
    fi
}

# 删除守护监控脚本
del_cron() {
    cru d "update_provider_local"
    cru d "update_gfwlist"
    cru d "${cron_id}"
    LOGGER "删除进程守护脚本成功!"
}

# 配置iptables规则
add_iptables() {
    # 1. 转发 HTTP/HTTPS 请求到 Clash redir-port 端口
    # 2. 转发 DNS 53端口请求到 Clash dns.listen 端口
    if [ "$clash_trans" = "off" ]; then
        LOGGER "透明代理模式已关闭！不需要添加iptables转发规则！"
        return 0
    fi
    if iptables -t nat -S ${app_name} >/dev/null 2>&1; then
        LOGGER "已经配置过${app_name}的iptables规则！"
        return 0
    fi
    LOGGER "开始配置 ${app_name} iptables规则..."
    iptables -t nat -N ${app_name}
    iptables -t nat -A PREROUTING -p tcp -s ${lan_ipaddr}/16 -j ${app_name}

    # 本地地址请求不转发
    iptables -t nat -A ${app_name} -d 10.0.0.0/8 -j RETURN
    iptables -t nat -A ${app_name} -d 127.0.0.0/8 -j RETURN
    iptables -t nat -A ${app_name} -d 169.254.0.0/16 -j RETURN
    iptables -t nat -A ${app_name} -d 172.16.0.0/12 -j RETURN
    iptables -t nat -A ${app_name} -d 198.18.0.1/16 -j RETURN
    iptables -t nat -A ${app_name} -d ${lan_ipaddr}/16 -j RETURN

    # 服务端口3333接管HTTP/HTTPS请求转发, 过滤 22,1080,8080一些代理常用端口
    iptables -t nat -A ${app_name} -s ${lan_ipaddr}/16 -p tcp -m multiport --dport 22,1080,8080 -j RETURN
    iptables -t nat -A ${app_name} -s ${lan_ipaddr}/16 -p tcp -m multiport --dport 80,443 -j REDIRECT --to-ports 3333

    # 转发DNS请求到端口 dns_port 解析
    if [ "$dns_port" != "53" ] ; then
        iptables -t nat -A ${app_name} -p udp -s ${lan_ipaddr}/16 --dport 53 -j REDIRECT --to-ports $dns_port
        iptables -t nat -A PREROUTING -p udp -s ${lan_ipaddr}/16 -j ${app_name}
    fi
}

# 清理iptables规则
del_iptables() {
    if ! iptables -t nat -S ${app_name} >/dev/null 2>&1; then
        LOGGER "已经清理过 ${app_name} 的iptables规则！"
        return 0
    fi
    LOGGER "开始清理 ${app_name} iptables规则 ..."
    iptables -t nat -D PREROUTING -p tcp -s ${lan_ipaddr}/16 -j ${app_name}
    iptables -t nat -D PREROUTING -p udp -s ${lan_ipaddr}/16 -j ${app_name}
    iptables -t nat -F ${app_name}
    iptables -t nat -X ${app_name}
}

status() {
    pidof ${app_name}
    # ps | grep ${app_name} | grep -v grep |grep -v /bin/sh | grep -v " vi "
}


# 存放规则文件目录#
rule_src_dir="$KSHOME/clash/ruleset"

get_filelist() {
    for fn in gfw apple google greatfire icloud proxy telegramcidr
    do
        printf "%s/%s.yaml " ${rule_src_dir} $fn
    done
}


## 生成 gfwlist.conf # dnsmasq 服务使用
update_gfwlist() {
    gfwlist_file=$KSHOME/$app_name/gfwlist.conf

    awk '!/^[a-z]/{
        gsub(/\+|'\''/,"",$2);
        rule[$2] += 1;
    }END{
        for( i in rule) {
            printf("%s\n", i) | "sort"
        }
    }' $(get_filelist) | awk -v dnsport=${dns_port} '{
        printf("server=/%s/%s#%s\n", $1, "127.0.0.1", dnsport);
        printf("ipset=/%s/%s\n", $1, "gfwlist");
    }' > ${gfwlist_file}
    LOGGER "已生成 ${gfwlist_file} 文件！ 文件大小: $(du -sm ${gfwlist_file}|awk '{print $1}') MB ! 记录数: $(wc -l ${gfwlist_file}|awk '/^server/{ print $1}') 条."
    run_dnsmasq restart
}

start_dns() {
    if [ "$clash_trans" = "off" ]; then
        LOGGER "透明代理模式已关闭！不启动DNS转发请求"
        return 0
    fi
    if [ "$dns_port" != "53" ] ; then
        for fn in wblist.conf gfwlist.conf; do
            if [ ! -f /jffs/configs/dnsmasq.d/${fn} ]; then
                LOGGER "添加软链接 ${KSHOME}/clash/${fn} 到 dnsmasq.d 目录下"
                ln -sf ${KSHOME}/clash/${fn} /jffs/configs/dnsmasq.d/${fn}
            fi
        done
    else
        fn="port.conf"  # 自定义dnsmasq的DNS端口为5353
        ln -sf ${KSHOME}/clash/${fn} /jffs/configs/dnsmasq.d/${fn}
    fi
    run_dnsmasq restart
}

stop_dns() {
    LOGGER "删除gfwlist.conf与wblist.conf文件:"
    for fn in wblist.conf gfwlist.conf; do
        rm -f /jffs/configs/dnsmasq.d/${fn}
    done
    LOGGER "开始重启dnsmasq,DNS解析"
    run_dnsmasq restart
}

run_dnsmasq() {
    case "$1" in
    start | stop | restart)
        LOGGER "执行 $1 dnsmasq 操作"
        service $1_dnsmasq
        ;;
    *)
        LOGGER "无效的 dnsmasq 操作"
        ;;
    esac
}

start() {
    # 1. 启动服务进程
    # 2. 配置iptables策略
    if [ "$clash_enable" = "off" ]; then
        echo "Clash开关处于关闭状态，无法启动Clash"
        return 0
    fi
    echo "启动 $app_name"
    if status >/dev/null 2>&1; then
        LOGGER "$app 已经运行了"
    else
        LOGGER "开始启动 ${app_name} :"
        nohup ${CMD} >/dev/null 2>&1 &
        sleep 1
        dbus set ${app_name}_enable="on"
    fi
    if status >/dev/null 2>&1; then
        LOGGER "启动 ${CMD} 成功！"
    else
        LOGGER "启动 ${CMD} 失败！"
    fi
    add_iptables
    start_dns
    add_cron
}

stop() {
    # 1. 停止服务进程
    # 2. 清理iptables策略
    echo "停止 $app_name"
    if status >/dev/null 2>&1; then
        LOGGER "停止 ${app_name} ..."
        killall ${app_name}
        dbus set ${app_name}_enable="off"
    fi
    del_iptables
    if status >/dev/null 2>&1; then
        LOGGER "停止 ${CMD} 失败！"
    else
        LOGGER "停止 ${CMD} 成功！"
    fi
    stop_dns
    del_cron
}

########## config part ###########
config_file="$KSHOME/${app_name}/config.yaml"
temp_provider_file="/tmp/clash_provider.yaml"

# 更新订阅源：文件类型
update_provider_file() {
    update_file="$KSHOME/${app_name}/provider_local.yaml"
    if [ "$clash_provider_file" = "" ]; then
        LOGGER "文件类型订阅源URL地址没设置，就不更新啦！ clash_provider_file=[$clash_provider_file]!"
        return 1
    fi
    curl --insecure -o $temp_provider_file ${clash_provider_file} >/dev/null 2>&1
    if [ "$?" != "0" ]; then
        LOGGER "下载订阅源URL信息失败!可能原因：1.URL地址被屏蔽！2.使用代理不稳定. 重新尝试一次。"
        return 2
    fi
    LOGGER "下载订阅源文件成功! URL=[${clash_provider_file}]."

    # 格式化处理yaml文件，只保留proxies信息
    check_format=$(yq e '.proxies[0].name' $temp_provider_file)
    if [ "$check_format" = "null" ]; then
        LOGGER "节点订阅源配置文件yaml格式错误： ${temp_provider_file}"
        LOGGER "错误原因：没找到 proxies 代理节点配置！ 没有代理节点怎么科学上网呢？"
        LOGGER "订阅源文件格式请参考： https://github.com/Dreamacro/clash/wiki/configuration#proxy-providers "
        return 3
    fi

    yq e '{ "proxies": .proxies}' $temp_provider_file >$update_file

    if cru l | grep update_provider_local >/dev/null; then
        LOGGER "已经添加了调度! $(cru l | grep update_provider_local)"
    else
        cru a "update_provider_local" "0 * * * * /koolshare/scripts/clash_control.sh update_provider_file >/dev/null 2>&1"
        LOGGER "成功添加更新调度配置： $(cru l| grep update_provider_local)"
    fi
    
    if [ "$clash_provider_file" != "$clash_provider_file_old" ]; then
        LOGGER "更新了订阅源！ 旧地址：[$clash_provider_file_old]"
        
        dbus set clash_provider_file_old=$clash_provider_file
    fi

    LOGGER "还不错！更新订阅源成功了！"
    LOGGER "成功导入代理节点：$(yq e '.proxies[].type' $update_file | awk '{a[$1]++}END{for(i in a)printf("%s:%.0f ,",i,a[i])}')"
    rm -f $temp_provider_file
}

# # 更新订阅源：URL订阅类型
update_provider_url() {
    LOGGER "更新订阅源URL地址"
    if [ "$clash_provider_url" = "" ]; then
        LOGGER "没有设置订阅源信息: clash_provider_url=[${clash_provider_url}] ，不更新！"
        return 99
    fi
    LOGGER "curl版本信息： $(curl -V)"
    LOGGER "yq版本信息: $(yq -V)"

    insecure_flag="0" # 标记是否SSL证书有问题
    curl -I ${clash_provider_url} >/dev/null
    ret_val="$?"
    if [ "$ret_val" != "0" ]; then
        # URL地址一定有问题，除了SSL证书问题外，其他问题都不继续执行
        if [ "$ret_val" = "60" ]; then
            insecure_flag="1"
            LOGGER "订阅源URL地址SSL证书失效啦！不过请放心！此类订阅源更新通过curl命令定时更新啦。"
        else
            LOGGER "订阅源地址有问题(curl命令返回值非0和60) 。检测命令： curl -I ${clash_provider_url} >/dev/null"
            LOGGER "这个订阅源可能被墙，或者已经不能访问了！换个更好的订阅源试试！"
            return 98
        fi
    fi
    # 处理SSL证书失效类型URL地址
    if [ "$insecure_flag" = "1" ]; then
        LOGGER "URL地址存在证书失效问题，只能使用文件类型订阅更新啦！"
        dbus set clash_provider_file=$clash_provider_url
        export clash_provider_file=$clash_provider_url
        dbus remove clash_provider_url
        update_provider_file $temp_provider_file
        return 0
    fi
    status_code=$(curl -I ${clash_provider_url} | awk '/HTTP/{ print $2 }')
    if [ "$status_code" != "200" ]; then
        LOGGER "订阅URL地址无效,curl访问返回状态码(非200):${status_code},clash_provider_url：[${clash_provider_url}]"
        return 1
    fi
    curl -o $temp_provider_file ${clash_provider_url} >/dev/null 2>&1
    if [ "$?" != "0" ]; then
        LOGGER 下载订阅源URL信息失败!可能原因：1.URL地址被屏蔽！2.使用代理不稳定. 重新尝试一次。
        return 2
    fi
    # URL地址请求正常，并不能表明 yaml 格式正常
    # 配置文件不规范的使用文件类型更新
    check_format=$(yq e '.redir-port' $temp_provider_file)
    if [ "$check_format" != "null" ]; then
        LOGGER "yaml订阅源格式不规范，只能使用文件类型订阅更新啦！"
        dbus set clash_provider_file=$clash_provider_url
        export clash_provider_file=$clash_provider_url
        dbus remove clash_provider_url
        update_provider_file $temp_provider_file
        return 0
    fi
    check_format=$(yq e '.proxies[0].name' $temp_provider_file)
    if [ "$check_format" = "null" ]; then
        LOGGER "节点订阅源配置文件yaml格式错误： ${temp_provider_file}"
        LOGGER "错误原因：没找到 proxies 代理节点配置！ 没有代理节点怎么科学上网呢？"
        LOGGER "订阅源文件格式应该是这样的：<br\>proxies:<br\>- name: xxx<br\>  type: ss<br\>  server: 1.2.3.4<br\>  port: 12304<br\>  cipher: aes-256-gcm<br\>  password: 123132131<br\>...<br\>"
        return 3
    fi

    basic_proxy_info=$(yq e '.proxies[].type' ${temp_provider_file} | awk '{a[$1]++}END{for(i in a)printf("%s:%.0f ,",i,a[i])}')
    rm -f ${temp_provider_file}
    LOGGER "开始更新订阅源地址:"
    yq e -i '.proxy-providers.provider01.url = strenv(clash_provider_url)' $config_file
    if [ "$?" != "0" ]; then
        LOGGER "替换订阅源地址失败了！ 赶紧看看 $config_file 的 proxy-providers.provider01.url 参数路径为啥错误吧！"
        return 4
    fi
    rm -f $KSHOME/${app_name}/provider_remote.yaml
    LOGGER "万幸！恭喜呀！更新订阅源成功了！"
    LOGGER "成功导入代理节点：$basic_proxy_info"
}

# 切换模式： 透明代理开关 + 组节点切换开关
switch_trans_mode() {
    if [ "$clash_group_type" != "$clash_select_type" ]; then
        LOGGER 切换了组节点模式为: "$clash_select_type"
        yq e -i '.proxy-groups[0].type = strenv(clash_select_type)' $config_file
        dbus set clash_group_type=$clash_select_type
    fi
}

# 更新新版本clash客户端可执行程序
update_clash_bin() {
    cd /tmp
    new_ver=$clash_new_version
    old_version=$clash_version
    
    # 专业版更新
    download_url="$(curl https://github.com/Dreamacro/clash/releases/tag/premium| awk '/premium.clash-linux-armv5/{ gsub(/href=|["]/,""); print "https://github.com"$2 }'|head -1)"
    bin_file=$(basename $download_url)
    LOGGER "新版本地址：${download_url}"
    # bin_file="clash-linux-${ARCH}-${new_ver}"
    # download_url="https://github.com/Dreamacro/clash/releases/download/${new_ver}/${bin_file}.gz"
    curl -o ${bin_file}.gz -L $download_url && gzip -d ${bin_file}.gz && chmod +x ${bin_file} && mv $KSHOME/bin/${app_name} /tmp/${app_name}.${old_version} && mv ${bin_file} ${KSHOME}/bin/${app_name}
    if [ "$?" != "0" ]; then
        LOGGER "更新出现了点问题!"
        [[ -f /tmp/${app_name}.${old_version} ]] && mv /tmp/${app_name}.${old_version} $KSHOME/bin/${app_name}
        if [ -f $KSHOME/bin/${app_name} ]; then
            LOGGER "更新 $KSHOME/bin/${app_name} 失败啦！"
            LOGGER 当前Clash版本信息: $($KSHOME/bin/${app_name} -v)
            LOGGER "别急！先把更新失败原因找到再想更新的事儿吧！"
        else
            LOGGER "太牛啦！如果走到这里，说明Clash可执行程序搞的不翼而飞啦！谁吃了呢？"
        fi
        return 1
    else
        # 更新成功啦
        LOGGER "更新到新版本！"
        dbus set clash_version=$clash_new_version
        dbus remove clash_new_version
        rm -f /tmp/${app_name}.${old_version}
    fi
}

######## 执行主要动作信息  ########
do_action() {
    # web界面配置操作
    LOGGER "执行动作 ${clash_action} ..."
    case "$clash_action" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    restart)
        stop
        start
        ;;
    update_provider_url | update_provider_file | update_clash_bin | switch_trans_mode)
        # 需要重启的操作分类
        $clash_action
        if [ "$?" != "0" ]; then
            return $?
        fi
        stop
        start
        ;;
    get_proc_status)
        # 不需要重启操作
        $clash_action
        ;;
    *)
        LOGGER "无效的操作！ clash_action:[$clash_action]"
        ;;
    esac
    # 执行完成动作后，清理动作.
    dbus remove clash_action
}

# 命令行参数处理
# main 与 do_action 类似， 但 do_action 根据 clash_action 选择要执行什么操作
main() {
    str_cmd=${1:-"do_action"}
    case "${str_cmd}" in
    start | stop | status | do_action | add_iptables | del_iptables | get_proc_status|update_provider_file|update_gfwlist)
        ${str_cmd}
        ;;
    restart)
        stop
        start
        ;;
    *)
        usage
        ;;
    esac
}

main $@
