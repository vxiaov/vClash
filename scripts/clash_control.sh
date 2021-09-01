#!/bin/sh
#########################################################
# Clash Process Control script for AM380 merlin firmware
# Writen by Awkee (next4nextjob(at)gmail.com) 
# Website: https://vlike.work
#########################################################

KSHOME="/koolshare"
app_name="clash"

source ${KSHOME}/scripts/base.sh

eval `dbus export ${app_name}_`

LOGGER() {
    # Magic number for Log 9977
    logger -s -t "9977`date +%H`.clashlog" "$@"
}

CMD="${app_name} -d ${KSHOME}/${app_name}/"
lan_ipaddr=$(nvram get lan_ipaddr)


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
    if [ "$1" = "head" ] ; then
        printf "%-20s %-20s %-s" "进程名称" "进程号" "运行状态"
        return 0
    fi
    pids=`pidof $1`
    if [ "$pids" == "" ] ; then
        printf "%-15s %-15s %-s" "$1" "$pids" "已停止."
    else
        printf "%-15s %-15s %-s" "$1" "$pids" "正常运行中."
    fi
}

get_proc_status() {
    echo "----------------------------------------------------"
    LOGGER "检查进程信息："
    LOGGER "`echo_status head`"
    LOGGER "`echo_status $app_name`"
    LOGGER "`echo_status dns2socks5`"
    LOGGER "`echo_status dnsmasq`"
    echo "----------------------------------------------------"
}

cron_id="daemon_clash_watchdog"
# 添加守护监控脚本
add_cron() { 
    if cru l |grep ${cron_id} >/dev/null  ; then
        LOGGER "进程守护脚本已经添加!不需要重复添加吧？！？"
        return 0
    fi
    cru a "${cron_id}"  "*/2 * * * * /koolshare/scripts/clash_control.sh start"
    if cru l |grep ${cron_id} >/dev/null  ; then
        LOGGER "添加进程守护脚本成功!"
    else
        LOGGER "不知道啥原因，守护脚本没添加到调度里！赶紧查查吧！"
        return 1
    fi
}
# 删除守护监控脚本
del_cron() {
    if cru l |grep ${cron_id} >/dev/null  ; then
        cru d "${cron_id}"
    else
        LOGGER "进程守护脚本没添加到cron调度中，不用删除啦！"
        return 0
    fi
    
    if cru l |grep ${cron_id} >/dev/null  ; then
        LOGGER "删除失败啦！进程守护脚本调度配置没有删除成功！赶紧查查吧！"
    else
        LOGGER "删除进程守护脚本成功!"
        return 1
    fi
}

# 配置iptables规则
add_iptables() {
    # 1. 转发 HTTP/HTTPS 请求到 Clash redir-port 端口
    # 2. 转发 DNS 53端口请求到 Clash dns.listen 端口
    if [ "$clash_trans" = "off" ] ; then
        LOGGER "透明代理模式已关闭！不需要添加iptables转发规则！"
        return 0
    fi
    if iptables -t nat -S ${app_name} >/dev/null 2>&1 ; then
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
    iptables -t nat -A ${app_name} -d ${lan_ipaddr}/16 -j RETURN

    # 服务端口3333接管HTTP/HTTPS请求转发, 过滤 22,1080,8080一些代理常用端口
    iptables -t nat -A ${app_name} -s ${lan_ipaddr}/16 -p tcp -m multiport --dport 22,1080,8080 -j RETURN
    iptables -t nat -A ${app_name} -s ${lan_ipaddr}/16 -p tcp -m multiport --dport 80,443 -j REDIRECT --to-ports 3333

    
    # 转发DNS请求到端口1053解析
    iptables -t nat -A ${app_name} -p udp -s ${lan_ipaddr}/16 --dport 53 -j REDIRECT --to-ports 1053
    iptables -t nat -A PREROUTING -p udp -s ${lan_ipaddr}/16 -j ${app_name}
}

# 清理iptables规则
del_iptables() {
    if ! iptables -t nat -S ${app_name} >/dev/null 2>&1 ; then
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

start_dns() {
    if [ "$clash_trans" = "off" ] ; then
        LOGGER "透明代理模式已关闭！不启动DNS转发请求"
        return 0
    fi
    for fn in wblist.conf gfwlist.conf
    do
        if [ ! -f /jffs/configs/dnsmasq.d/${fn} ] ; then
            LOGGER "添加软链接 ${KSHOME}/clash/${fn} 到 dnsmasq.d 目录下"
            ln -sf ${KSHOME}/clash/${fn} /jffs/configs/dnsmasq.d/${fn}
        fi
    done
    if ! pidof dns2socks5 >/dev/null 2>&1 ; then
        LOGGER "开始启动 dns2socks5 :"
        nohup dns2socks5 -bind "127.0.0.1:7913" -socks-server "127.0.0.1:1080" >/dev/null 2>&1 &
        run_dnsmasq restart
    fi
}

stop_dns(){
    LOGGER "删除gfwlist.conf与wblist.conf文件:"
    for fn in wblist.conf gfwlist.conf
    do
        rm -f /jffs/configs/dnsmasq.d/${fn}
    done
    LOGGER "开始停止 dns2socks5 DNS解析"
    killall dns2socks5
    run_dnsmasq restart
}

run_dnsmasq() {
    case "$1" in
        start|stop|restart)
        LOGGER "执行 $1 dnsmasq 操作"
        service $1_dnsmasq
        ;;
    *)
        LOGGER "无效的 dnsmasq 操作"
    esac
}

start() {
    # 1. 启动服务进程
    # 2. 配置iptables策略
    if [ "$clash_enable" = "0" ] ; then
        echo "Clash开关处于关闭状态，无法启动Clash"
        return 0
    fi
    echo "启动 $app_name"
    if status >/dev/null 2>&1 ; then
        LOGGER "$app 已经运行了"
    else
        LOGGER "开始启动 ${app_name} :"
        nohup ${CMD}  > /dev/null 2>&1 &
        sleep 1
        dbus set ${app_name}_enable=1
    fi
    if status >/dev/null 2>&1 ; then
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
    if status >/dev/null 2>&1 ; then
        LOGGER "停止 ${app_name} ..."
        killall ${app_name}
        dbus set ${app_name}_enable=0
    fi
    del_iptables
    if status >/dev/null 2>&1 ; then
        LOGGER "停止 ${CMD} 失败！"
    else
        LOGGER "停止 ${CMD} 成功！"
    fi
    stop_dns
    del_cron
}

########## config part ###########

# 更新Clash订阅源URL地址 #
update_provider_url() {
    config_file="$KSHOME/${app_name}/config.yaml"
    temp_provider_file="/tmp/clash_provider.yaml"
    LOGGER "更新订阅源URL地址"
    if [ "$clash_provider_url" = "" ] ; then
        LOGGER "没有设置订阅源信息: clash_provider_url=${clash_provider_url} ，不更新！"
        return 99
    fi
    LOGGER "curl版本信息：\n`curl -V`"
    LOGGER "yq版本信息:\n `yq -V`"

    status_code=`curl -I ${clash_provider_url} | awk '/HTTP/{ print $2 }'`
    if [ "$status_code" != "200" ] ; then
        LOGGER "提供的远程订阅地址无效,curl访问返回状态码(非200):${status_code},clash_provider_url：${clash_provider_url}"
        return 1
    fi
    curl -o $temp_provider_file ${clash_provider_url} >/dev/null 2>&1
    if [ "$?" != 0 ] ; then
        LOGGER 下载节点订阅源文件失败!
        return 2
    fi
    
    # URL地址请求正常，并不能表明 yaml 格式正常
    check_format=`yq e '.proxies[0].name' $temp_provider_file`
    if [ "$check_format" = "null" ] ; then
        LOGGER "节点订阅源配置文件yaml格式错误： ${temp_provider_file}"
        LOGGER "订阅源文件格式应该是这样的：\nproxies:\n- name: xxx\n  type: ss\n  server: 1.2.3.4\n  port: 12304\n  cipher: aes-256-gcm\n  password: 123132131\n...\n"
        return 3
    fi
    LOGGER "开始替换订阅源地址:"
    cp ${config_file} ${config_file}.old
    yq e -i '.proxy-providers.provider01.url = strenv(clash_provider_url)' $config_file
    if [ "$?" != "0" ] ; then
        LOGGER "替换订阅源地址失败了！ 赶紧看看 $config_file 的 proxy-providers.provider01.url 参数路径为啥错误吧！"
        return 4
    fi
    LOGGER "万幸！恭喜呀！更新订阅源成功了！"
}

######## 执行主要动作信息  ########
do_action() {
    # web界面配置操作
    LOGGER "执行动作 ${clash_action} ..."
    case "$clash_action" in
        1|start)
            start
        ;;
        0|stop)
            stop
        ;;
        restart|switch_trans_mode)
            stop
            start
        ;;
        update_provider_url) 
            # 需要重启的操作分类
            $clash_action
            if [ "$?" != "0" ] ; then
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
        start|stop|status|do_action|add_iptables|del_iptables|get_proc_status|update_provider_url)
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