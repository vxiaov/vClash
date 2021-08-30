#!/bin/sh
#########################################################
# Clash Process Control script for AM380 merlin firmware
# Writen by Awkee (next4nextjob(at)gmail.com) 
# Website: https://vlike.work
#########################################################

source /koolshare/scripts/base.sh

LOGGER() {
    # Magic number for Log 9977
    logger -s -t "9977`date +%H`.clashlog" "$@"
}

app_name="clash"

CMD="${app_name} -d /koolshare/${app_name}/"

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

# 配置iptables规则
add_iptables() {
    # 1. 转发 HTTP/HTTPS 请求到 Clash redir-port 端口
    # 2. 转发 DNS 53端口请求到 Clash dns.listen 端口

    if iptables -t nat -S ${app_name} >/dev/null 2>&1 ; then
        LOGGER "已经配置过${app_name}的iptables规则！"
        return 0
    fi
    LOGGER "开始配置 ${app_name} iptables规则..."
    iptables -t nat -N ${app_name}
    iptables -t nat -A PREROUTING -p tcp -j ${app_name}

    # 本地地址请求不转发
    iptables -t nat -A ${app_name} -d 10.0.0.0/8 -j RETURN
    iptables -t nat -A ${app_name} -d 127.0.0.0/8 -j RETURN
    iptables -t nat -A ${app_name} -d 169.254.0.0/16 -j RETURN
    iptables -t nat -A ${app_name} -d 172.16.0.0/12 -j RETURN
    iptables -t nat -A ${app_name} -d 192.168.50.0/16 -j RETURN

    # 服务端口3333接管HTTP/HTTPS请求转发, 过滤 22,1080,8080一些代理常用端口
    iptables -t nat -A ${app_name} -p tcp -m multiport --dport 22,1080,8080 -j RETURN
    iptables -t nat -A ${app_name} -p tcp -m multiport --dport 80,443 -j REDIRECT --to-ports 3333

    # 转发DNS请求到端口1053解析
    iptables -t nat -A ${app_name} -p udp --dport 53 -j REDIRECT --to-ports 1053
    iptables -t nat -A PREROUTING -p udp -j ${app_name}
}

# 清理iptables规则
del_iptables() {
    if ! iptables -t nat -S ${app_name} >/dev/null 2>&1 ; then
        LOGGER "已经清理过 ${app_name} 的iptables规则！"
        return 0
    fi
    LOGGER "开始清理 ${app_name} iptables规则 ..."
    iptables -t nat -D PREROUTING -p tcp -j ${app_name}
    iptables -t nat -D PREROUTING -p udp -j ${app_name}
    iptables -t nat -F ${app_name}
    iptables -t nat -X ${app_name}
}

status() {
    pidof ${app_name}
    # ps | grep ${app_name} | grep -v grep |grep -v /bin/sh | grep -v " vi "
}

start_dns() {
    LOGGER "添加gfwlist.conf与wblist.conf到 dnsmasq.d 目录下"
    for fn in wblist.conf gfwlist.conf
    do
        ln -sf /koolshare/clash/${fn} /jffs/configs/dnsmasq.d/${fn}
    done
    LOGGER "开始启动 dns2socks5 :"
    nohup dns2socks5 -bind "127.0.0.1:7913" -socks-server "127.0.0.1:1080" >/dev/null 2>&1 &
    run_dnsmasq restart
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
    if status >/dev/null 2>&1 ; then
        LOGGER "$app 已经运行了"
        return 0
    else
        LOGGER "开始启动 ${app_name} :"
        nohup ${CMD}  > /dev/null 2>&1 &
        sleep 3
        dbus set ${app_name}_enable=1
    fi
    add_iptables
    if status >/dev/null 2>&1 ; then
        LOGGER "启动 ${CMD} 成功！"
    else
        LOGGER "启动 ${CMD} 失败！"
    fi
    start_dns
}

stop() {
    # 1. 停止服务进程
    # 2. 清理iptables策略
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
}

do_action() {
    # web界面配置操作
    str_enable=`dbus get ${app_name}_enable`
    if [ "$str_enable" = "1" ] ; then
        LOGGER "执行启动动作 ${app_name} ..."
        start   # 启用动作
    elif [ "$str_enable" = "0" ] ; then
        LOGGER "执行停止动作 ${app_name} ..."
        stop    # 禁用动作
    else
        LOGGER "未知动作:${str_enable}"
    fi
}

main() {
    str_cmd=${1:-"do_action"}
    case "${str_cmd}" in 

        start|stop|status|do_action|add_iptables|del_iptables)
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