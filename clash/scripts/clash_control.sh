#!/bin/sh
#########################################################
# Clash Process Control script for AM380 merlin firmware
# Writen by Awkee (next4nextjob(at)gmail.com)
# Website: https://vlike.work
#########################################################

KSHOME="/koolshare"
app_name="clash"

source ${KSHOME}/scripts/base.sh

# 避免出现 out of memory 问题
ulimit -s unlimited

# 路由器IP地址
lan_ipaddr="$(nvram get lan_ipaddr)"

dbus set clash_lan_ipaddr=$lan_ipaddr

eval $(dbus export ${app_name}_)

alias curl="curl --connect-timeout 300"

CURL_OPTS="-L "

if [ "$clash_use_local_proxy" == "on" ] ; then
    CURL_OPTS="--proxy socks5h://127.0.0.1:1080 $CURL_OPTS"
fi

bin_list="${app_name} yq"

dns_port="1053"         # Clash DNS端口
redir_port="3333"       # Clash 透明代理端口
yacd_port="9090"        # Yacd 端口
# 存放规则文件目录#
rule_src_dir="${KSHOME}/clash/ruleset"
config_file="${KSHOME}/${app_name}/config.yaml"
temp_provider_file="/tmp/clash_provider.yaml"





check_config_file() {
    # 检查 config.yaml 文件配置信息
    clash_yacd_secret=$(yq e '.secret' $config_file)
    clash_yacd_ui="${lan_ipaddr}:${yacd_port}"
    tmp_port=$redir_port yq e -iP '.redir-port=env(tmp_port)' $config_file
    tmp_yacd="0.0.0.0:$yacd_port" yq e -iP '.external-controller=strenv(tmp_yacd)' $config_file
    tmp_dns="0.0.0.0:$dns_port" yq e -iP '.dns.listen=strenv(tmp_dns)' $config_file
    yq e -iP '.external-ui="/koolshare/clash/dashboard/yacd"' $config_file
    yq e -iP '.dns.enhanced-mode="redir-host"' $config_file
    dbus set clash_yacd_ui=$clash_yacd_ui
    dbus set clash_yacd_secret=$clash_yacd_secret
}

# 开启对旁路由IP自动化监控脚本
main_script="${KSHOME}/scripts/clash_control.sh"

# provider_url_bak="${KSHOME}/${app_name}/provider_url.yaml"        # URL订阅源配置信息
# provider_file_bak="${KSHOME}/${app_name}/provider_file.yaml"      # FILE订阅源配置信息

provider_remote_file="${KSHOME}/${app_name}/providers/provider_remote.yaml"    # 远程URL更新文件
provider_diy_file="${KSHOME}/${app_name}/providers/provider_diy.yaml"          # 远程URL更新文件

CMD="${app_name} -d ${KSHOME}/${app_name}/"
cron_id="clash_daemon"             # 调度ID,用来查询和删除操作标识
FW_TYPE_CODE=""     # 固件类型代码
FW_TYPE_NAME=""     # 固件类型名称

LOGFILE="/tmp/upload/clash_status.log"
echo > $LOGFILE
LOGGER() {
    echo -e "$(date +'%Y年%m月%d日%H:%M:%S'): $@"
}

SYSLOG() {
    logger -t "$(date +'%Y年%m月%d日%H:%M:%S'):clash" "$@"
}
if [ "$lan_ipaddr" = "" ]; then
    LOGGER "真糟糕! nvram 命令没找到局域网路由器地址，这样防火墙规则配置不了啦!还是自己手动设置后再执行吧!"
    echo "XU6J03M6"
    exit 1
fi
# 检测是否有 cru 命令
if [ ! -x "$(which cru)" ]; then
    if [ -x "$(which cru.sh)" ]; then
        alias cru="cru.sh"
    else
        LOGGER "糟糕!没有找到 cru 命令! 这样配置不了调度啦!"
    fi
fi

usage() {
    cat <<END
 使用帮助:
    ${app_name} <start|stop|status|restart>
 参数介绍:
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
    aarch64)
        ARCH="armv8"
        ;;
    *)
        LOGGER "糟糕!平台类型不支持呀!赶紧通知开发者适配!或者自己动手丰衣足食!"
        echo "XU6J03M6"
        exit 0
        ;;
esac

get_proc_status() {
    echo "检查进程信息:"
    echo "$(echo_status head)"
    echo "$(echo_status $app_name)"
    echo "----------------------------------------------------"
    echo "守护调度:$(cru l | grep ${cron_id})"
    if [ "$clash_cfddns_enable" = "on" ] ; then
        echo "DDNS调度: [$(cru l| grep clash_cfddns)]"
    fi
    if [ "$clash_watchdog_enable" = "on" ] ; then
        echo "旁路由Watchdog调度: [$(cru l| grep soft_route_check)]"
    fi
    echo "----------------------------------------------------"
    echo "代理订阅: $clash_provider_file"
    echo "订阅更新:$(cru l| grep update_provider_local)"
    echo "----------------------------------------------------"
    # echo "Clash版本信息: `clash -v`"
    # echo "yq工具版本信息: `yq -V`"
    # echo "----------------------------------------------------"
    echo "Clash服务最近重启次数:$(grep start_${app_name} /tmp/syslog.log|wc -l)"
    echo "Clash服务最近重启时间(最近3次): "
    echo "$(grep start_${app_name} /tmp/syslog.log|tail -3)"
    echo "----------------------------------------------------"
    #echo "中继列表信息:"
    #yq e '.proxy-groups[2].proxies.[]' $config_file
    #echo "----------------------------------------------------"
}

add_ddns_cron(){
    if [ "$clash_cfddns_enable" = "on" ] ; then
        if cru l | grep clash_cfddns > /dev/null ; then
            echo "已经添加cfddns调度!"
        else
            ttl=`expr $clash_cfddns_ttl / 60`
            if [ "$ttl" -lt "2" -o "$ttl" -ge "1440" ] ; then
                ttl="2"
            fi
            
            cru a clash_cfddns "*/${ttl} * * * * $main_script start_cfddns"
            if [ "$?" = "0" ] ; then
                echo "成功添加cfddns调度!"
            else
                echo "添加cfddns调度失败"
                cru l| grep clash_cfddns
            fi
        fi
    fi
}
# 添加守护监控脚本
add_cron() {
    add_ddns_cron
    if cru l | grep ${cron_id} >/dev/null && cru l |grep update_provider_local >/dev/null; then
        LOGGER "进程守护脚本已经添加!不需要重复添加吧？!？"
        return 0
    fi

    cru a "${cron_id}" "*/5 * * * * $main_script start"
    if cru l | grep ${cron_id} >/dev/null; then
        LOGGER "添加进程守护脚本成功!"
    else
        LOGGER "不知道啥原因，守护脚本没添加到调度里!赶紧查查吧!"
        return 1
    fi

    cru a "update_provider_local" "0 * * * * $main_script update_provider_file >/dev/null 2>&1"
    if cru l | grep update_provider_local >/dev/null; then
        LOGGER "添加订阅源更新调度脚本成功!"
    else
        LOGGER "不知道啥原因，订阅源更新调度脚本没添加到调度里!赶紧查查吧!"
        return 1
    fi

}

# 删除守护监控脚本
del_cron() {
    cru d "update_provider_local"
    cru d "${cron_id}"
    LOGGER "删除进程守护脚本成功!"
}

# 配置iptables规则
add_iptables() {
    # 1. 转发 HTTP/HTTPS 请求到 Clash redir-port 端口
    # 2. 转发 DNS 53端口请求到 Clash dns.listen 端口
    if [ "$clash_trans" = "off" ]; then
        LOGGER "透明代理模式已关闭!不需要添加iptables转发规则!"
        return 0
    fi
    if iptables -t nat -S ${app_name} >/dev/null 2>&1; then
        LOGGER "已经配置过${app_name}的iptables规则!"
        return 0
    fi

    LOGGER "开始配置 ${app_name} iptables规则..."
    
    # Fake-IP 规则添加
    iptables -t nat -A OUTPUT -p tcp -d 198.18.0.0/16 -j REDIRECT --to-port ${redir_port}

    
    if [ "$clash_gfwlist_mode" = "on" ] ; then
        # 根据dnsmasq的ipset规则识别流量代理
        LOGGER "创建ipset规则集"
        ipset -! create gfwlist nethash && ipset flush gfwlist
        # ipset -! create router nethash && ipset flush router
        iptables -t nat -N ${app_name}
        iptables -t nat -A ${app_name} -p tcp -m set --match-set gfwlist dst -j REDIRECT --to-ports ${redir_port}
        iptables -t nat -A PREROUTING -p tcp -s ${lan_ipaddr}/16 -m set --match-set gfwlist dst -j ${app_name}
    else
        iptables -t nat -N ${app_name}
        iptables -t nat -F ${app_name}
        iptables -t nat -A PREROUTING -p tcp -s ${lan_ipaddr}/16  -j ${app_name}
        # 本地地址请求不转发
        iptables -t nat -A ${app_name} -d 10.0.0.0/8 -j RETURN
        iptables -t nat -A ${app_name} -d 127.0.0.0/8 -j RETURN
        iptables -t nat -A ${app_name} -d 169.254.0.0/16 -j RETURN
        iptables -t nat -A ${app_name} -d 172.16.0.0/12 -j RETURN
        iptables -t nat -A ${app_name} -d ${lan_ipaddr}/16 -j RETURN
        # 服务端口${redir_port}接管HTTP/HTTPS请求转发, 过滤 22,1080,8080一些代理常用端口
        iptables -t nat -A ${app_name} -s ${lan_ipaddr}/16 -p tcp -m multiport --dport 80,443 -j REDIRECT --to-ports ${redir_port}
        # 转发DNS请求到端口 dns_port 解析
        iptables -t nat -N ${app_name}_dns
        iptables -t nat -F ${app_name}_dns
        iptables -t nat -A ${app_name}_dns -p udp -s ${lan_ipaddr}/16 --dport 53 -j REDIRECT --to-ports $dns_port
        iptables -t nat -A PREROUTING -p udp -s ${lan_ipaddr}/16 --dport 53 -j ${app_name}_dns
        iptables -t nat -I OUTPUT -p udp --dport 53 -j ${app_name}_dns
    fi
}

# 清理iptables规则
del_iptables() {
    if ! iptables -t nat -S ${app_name} >/dev/null 2>&1; then
        LOGGER "已经清理过 ${app_name} 的iptables规则!"
        return 0
    fi
    LOGGER "开始清理 ${app_name} iptables规则 ..."
    # Fake-IP 规则清理
    iptables -t nat -D OUTPUT -p tcp -d 198.18.0.0/16 -j REDIRECT --to-port ${redir_port}
    
    iptables -t nat -D PREROUTING -p tcp -s ${lan_ipaddr}/16 -m set --match-set gfwlist dst -j ${app_name}
    iptables -t nat -D PREROUTING -p tcp -s ${lan_ipaddr}/16 -j ${app_name}
    iptables -t nat -D ${app_name} -p tcp -m set --match-set gfwlist dst -j REDIRECT --to-ports ${redir_port}
    iptables -t nat -F ${app_name}
    iptables -t nat -X ${app_name}

    iptables -t nat -D PREROUTING -p udp -s ${lan_ipaddr}/16 --dport 53 -j ${app_name}_dns
    iptables -t nat -D OUTPUT -p udp --dport 53 -j ${app_name}_dns
    iptables -t nat -F ${app_name}_dns
    iptables -t nat -X ${app_name}_dns
}

status() {
    pidof ${app_name}
    # ps | grep ${app_name} | grep -v grep |grep -v /bin/sh | grep -v " vi "
}

get_filelist() {
    for fn in gfw apple google greatfire icloud proxy telegramcidr
    do
        printf "%s/%s.yaml " ${rule_src_dir} $fn
    done
}


# 解决路由器上执行 curl 或者 wget 等请求时出现DNS服务器污染问题!
# 添加本地DNS服务进行DNS解析
swtich_localhost_dns(){
    # clash_use_local_proxy
    # 取消变量:clash_use_local_dns
    if [ "$clash_use_local_proxy" = "on" ] ; then
        if grep 127.0.0.1 /etc/resolv.conf >/dev/null 2>&1 ; then
            LOGGER "已经添加了本地DNS服务，不必重复添加了!"
        else
            LOGGER "添加本地DNS服务到 /etc/resolv.conf 文件中(临时生效)!"
            sed -i '1 i nameserver 127.0.0.1' /etc/resolv.conf
        fi
    else
        if grep 127.0.0.1 /etc/resolv.conf >/dev/null 2>&1 ; then
            sed -i '/127.0.0.1/d' /etc/resolv.conf
            LOGGER "已经删除了本地DNS服务"
            LOGGER "当前DNS配置:\n$(cat /etc/resolv.conf)"
        else
            LOGGER "您没添加过本地DNS服务，不用删除了!"
        fi
    fi
}

# Dnsmasq 配置
start_dns() {
    if [ "$clash_gfwlist_mode" = "off" ] ; then
        LOGGER "未启用DNSMASQ黑名单列表，不需要设置gfwlist.conf配置!"
        return 0
    fi
    if [ "$clash_trans" = "off" ]; then
        LOGGER "透明代理模式已关闭!不启动DNS转发请求"
        return 0
    fi
    for fn in gfwlist.conf netflix.conf; do
        if [ ! -f /jffs/configs/dnsmasq.d/${fn} ]; then
            LOGGER "添加软链接 ${KSHOME}/clash/${fn} 到 dnsmasq.d 目录下"
            ln -sf ${KSHOME}/clash/${fn} /jffs/configs/dnsmasq.d/${fn}
        fi
    done
    swtich_localhost_dns
    run_dnsmasq restart
    
}
# 清理Dnsmasq配置
stop_dns() {
    
    LOGGER "删除gfwlist.conf文件:"
    for fn in gfwlist.conf netflix.conf; do
        rm -f /jffs/configs/dnsmasq.d/${fn}
    done
    LOGGER "开始重启dnsmasq,DNS解析"
    run_dnsmasq restart
}

# dnsmasq 管理
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
    # echo "启动 $app_name"
    if status >/dev/null 2>&1; then
        LOGGER "$app_name 正常运行中! pid=$(pidof ${app_name})"
    else
        LOGGER "开始启动 ${app_name} :"
        nohup ${CMD} >/dev/null 2>&1 &
        sleep 1
        if status >/dev/null 2>&1; then
            LOGGER "启动 ${CMD} 成功!"
        else
            LOGGER "启动 ${CMD} 失败!请手工执行命令并将报错信息发给开发者帮助解决."
            return 1
        fi
        # 用于记录Clash服务稳定程度
        SYSLOG "start_${app_name} : pid=$(pidof ${app_name})"
        dbus set ${app_name}_enable="on"
        [ ! -L "/www/ext/dashboard" ] && ln -sf /koolshare/${app_name}/dashboard /www/ext/dashboard
        start_dns
    fi
    add_iptables
    add_cron
}

stop() {
    # 1. 停止服务进程
    # 2. 清理iptables策略
    #echo "停止 $app_name"
    if status >/dev/null 2>&1; then
        LOGGER "停止 ${app_name} ..."
        killall ${app_name}
        dbus set ${app_name}_enable="off"
    fi
    del_iptables  2>/dev/null
    if status >/dev/null 2>&1; then
        LOGGER "停止 ${CMD} 失败!"
    else
        LOGGER "停止 ${CMD} 成功!"
    fi
    stop_dns
    del_cron
}

########## config part ###########

# DIY节点 列表
list_nodes() {
    filename="$provider_diy_file"
    node_list=`yq e '.proxies[].name' $filename| awk '!/test/{ printf("%s ", $0)}'`
    LOGGER "DIY节点列表: [${node_list}]"
    dbus set clash_name_list="$node_list"
}

# DIY节点 添加节点(一个或多个)
add_nodes() {
    tmp_node_file="/koolshare/clash/tmp_node.yaml"
    # 替换掉回车、多行文本变量页面加载时会出错!
    dbus set clash_node_list="$(echo "$clash_node_list" | sed 's/\n/\t/g')"
    node_list="$clash_node_list"
    if [ "$node_list" = "" ] ; then
        LOGGER "想啥呢!节点可不会凭空产生!你得传入 ss:// 或 ssr:// 或者 vmess:// 前缀的URI链接!"
        return 1
    fi

    # 生成节点文件
    uri_decoder -uri "$node_list" -db "/koolshare/clash/Country.mmdb" > ${tmp_node_file}
    if [ "$?" != "0" -o ! -s "${tmp_node_file}" ] ; then
        LOGGER "抱歉!你添加的链接解析失败啦!给个正确的链接吧!"
        return 2
    fi
    LOGGER "成功导入DIY代理节点"

    cp $provider_diy_file $provider_diy_file.old
    # yq_expr='select(fi==1).proxies as $plist | select(fi==1).proxies[].name as $nlist | select(fi==0)|.proxies += $plist | (.proxy-groups[]|select(.name == "DIY组")).proxies += [$nlist]'
    yq_expr='select(fi==1).proxies as $plist | select(fi==0)|.proxies += $plist'
    yq ea -iP "$yq_expr" ${provider_diy_file} ${tmp_node_file}
    if [ "$?" != "0" ] ; then
        LOGGER "怎么会这样! 添加DIY代理节点失败啦!"
        return 2
    fi
    LOGGER "添加DIY节点成功!"
    rm -f ${tmp_node_file}
    list_nodes
}

# DIY节点 删除一个节点
delete_one_node() {
    filename="$provider_diy_file"
    cp $filename $filename.old
    LOGGER "开始删除DIY节点 (${clash_delete_name}):"
    f=${clash_delete_name} yq e -i 'del(.proxies[]|select(.name == strenv(f)))' $filename
    # f=${clash_delete_name} yq e -i 'del(.proxy-groups[].proxies[]|select(. == strenv(f)))' $filename
    LOGGER "节点删除完成!"
    list_nodes
}

# DIY节点 全部删除
delete_all_nodes() {
    filename="$provider_diy_file"
    cp $filename $filename.old
    LOGGER "开始清理所有DIY节点:"
    # for fn in `yq e '.proxies[].name' $filename|grep -v test`
    for fn in ${clash_name_list}
    do
        # 保留 test 节点，删掉后添加节点会很出问题的哦!
        if [ $fn != "test" ] ; then
            f="$fn" yq e -i 'del(.proxies[]|select(.name == strenv(f)))' $filename
            # f="$fn" yq e -i 'del(.proxy-groups[].proxies[]|select(. == strenv(f)))' $filename
        fi
    done
    LOGGER "清理DIY节点完毕!让世界回归平静!"
    list_nodes
}

#############  provider 订阅源管理

# 更新订阅源:文件类型
update_provider_file() {
    # 切换使用代理dns转发
    swtich_localhost_dns

    if [ "$clash_provider_file" = "" ]; then
        LOGGER "文件类型订阅源URL地址没设置，就不更新啦! clash_provider_file=[$clash_provider_file]!"
        return 1
    fi
    curl ${CURL_OPTS} -o $temp_provider_file ${clash_provider_file}
    if [ "$?" != "0" ]; then
        echo "curl ${CURL_OPTS} -o $temp_provider_file ${clash_provider_file}"
        LOGGER "下载订阅源URL信息失败!可能原因:1.URL地址被屏蔽!2.使用代理不稳定. 重新尝试一次。"
        return 2
    fi
    LOGGER "下载订阅源文件成功! URL=[${clash_provider_file}]."

    # 格式化处理yaml文件，只保留proxies信息
    check_format=$(yq e '.proxies[0].name' $temp_provider_file)
    if [ "$check_format" = "null" ]; then
        LOGGER "节点订阅源配置文件yaml格式错误: ${temp_provider_file}"
        LOGGER "错误原因:没找到 proxies 代理节点配置! 没有代理节点怎么科学上网呢？"
        LOGGER "订阅源文件格式请参考: https://github.com/Dreamacro/clash/wiki/configuration#proxy-providers "
        return 3
    fi

    yq e '{ "proxies": .proxies}' $temp_provider_file > ${provider_remote_file}.new
    if [ "$?" != "0" ] ; then
        LOGGER "更新节点错误![$?]!订阅源配置可能存在问题!"
        rm -f ${provider_remote_file}.new
        return 4
    else
        mv ${provider_remote_file} ${provider_remote_file}.old
        mv ${provider_remote_file}.new  ${provider_remote_file}
    fi

    if cru l | grep update_provider_local >/dev/null; then
        LOGGER "已经添加了调度! $(cru l | grep update_provider_local)"
    else
        cru a "update_provider_local" "0 * * * * $main_script update_provider_file >/dev/null 2>&1"
        LOGGER "成功添加更新调度配置: $(cru l| grep update_provider_local)"
    fi
    
    if [ "$clash_provider_file" != "$clash_provider_file_old" ]; then
        LOGGER "更新了订阅源! 旧地址:[$clash_provider_file_old]"
        dbus set clash_provider_file_old=$clash_provider_file
    fi

    LOGGER "还不错!更新订阅源成功了!"
    LOGGER "成功导入代理节点:$(yq e '.proxies[].type' ${provider_remote_file} | awk '{a[$1]++}END{for(i in a)printf("%s:%.0f ,",i,a[i])}')"
    rm -f $temp_provider_file
}

update_geoip() {
    #
    geoip_file="${KSHOME}/clash/Country.mmdb"
    cp ${geoip_file} ${geoip_file}.bak
    # 精简中国IP列表生成MaxMind数据库: https://cdn.jsdelivr.net/gh/Hackl0us/GeoIP2-CN@release/Country.mmdb
    # 全量MaxMind数据库文件: https://cdn.jsdelivr.net/gh/Dreamacro/maxmind-geoip@release/Country.mmdb
    # 全量MaxMind数据库文件（融合了ipip.net数据）: https://cdn.jsdelivr.net/gh/alecthw/mmdb_china_ip_list@release/Country.mmdb
    # 切换使用代理dns转发
    swtich_localhost_dns

    geoip_url="https://cdn.jsdelivr.net/gh/Hackl0us/GeoIP2-CN@release/Country.mmdb"
    if [ ! -z "$clash_geoip_url" ] ; then
        geoip_uri="$clash_geoip_url"
    fi
    curl ${CURL_OPTS} -o ${geoip_file} ${geoip_uri}
    if [ "$?" != "0" ] ; then
        LOGGER "下载「$geoip_file」文件失败!"
        mv -f ${geoip_file}.bak ${geoip_file}
        return 1
    fi
    LOGGER "「$geoip_file」文件更新成功!，大小变化[`du -h ${geoip_file}.bak|cut -f1`]=>[`du -h ${geoip_file}|cut -f1`]"
    rm ${geoip_file}.bak
}


# 切换gfwlist黑名单模式(使用dnsmasq过滤黑名单URL规则请求到代理处理)
switch_gfwlist_mode(){
    gfw_status="关闭"
    if [ "$clash_gfwlist_mode" = "on" ] ; then
        gfw_status="启用"
    fi
    LOGGER "${gfw_status} 黑名单模式: dnsmasq过滤黑名单URL规则请求到代理中!"
}

# 切换模式: 组节点切换开关
switch_group_type() {
    LOGGER 切换了组节点模式为: "$clash_group_type"
    yq e -i '(.proxy-groups[] | select(.name == "PROXY")).type = strenv(clash_group_type)' $config_file
}

# 透明代理开关
switch_trans_mode(){
    LOGGER "切换透明代理模式:$clash_trans"
}

# 更新新版本clash客户端可执行程序
update_clash_bin() {
    cd /tmp
    new_ver=$clash_new_version
    old_version=$clash_version
    
    # 切换使用代理dns转发
    swtich_localhost_dns

    # 专业版更新
    # https://hub.fastgit.org/Dreamacro/clash/releases/tag/premium
    # https://github.com/Dreamacro/clash/releases/tag/premium
    LOGGER "CURL_OPTS:${CURL_OPTS}"
    LOGGER "正在执行命令: curl ${CURL_OPTS} https://github.com/Dreamacro/clash/releases/tag/premium"
    download_url="$(curl ${CURL_OPTS} https://github.com/Dreamacro/clash/releases/tag/premium | grep "clash-linux-${ARCH}" | awk '{ gsub(/href=|["]/,""); print "https://github.com"$2 }'|head -1)"
    bin_file="new_$app_name"
    LOGGER "正在下载新版本:curl ${CURL_OPTS} -o ${bin_file}.gz $download_url"
    # bin_file="clash-linux-${ARCH}-${new_ver}"
    # download_url="https://github.com/Dreamacro/clash/releases/download/${new_ver}/${bin_file}.gz"
    curl ${CURL_OPTS} -o ${bin_file}.gz $download_url && gzip -d ${bin_file}.gz && chmod +x ${bin_file} && mv ${KSHOME}/bin/${app_name} /tmp/${app_name}.${old_version} && mv ${bin_file} ${KSHOME}/bin/${app_name}
    if [ "$?" != "0" ]; then
        LOGGER "更新出现了点问题!"
        [[ -f /tmp/${app_name}.${old_version} ]] && mv /tmp/${app_name}.${old_version} ${KSHOME}/bin/${app_name}
        if [ -f ${KSHOME}/bin/${app_name} ]; then
            LOGGER "更新 ${KSHOME}/bin/${app_name} 失败啦!"
            LOGGER 当前Clash版本信息: $(${KSHOME}/bin/${app_name} -v)
            LOGGER "别急!先把更新失败原因找到再想更新的事儿吧!"
        else
            LOGGER "太牛啦!如果走到这里，说明Clash可执行程序搞的不翼而飞啦!谁吃了呢？"
        fi
        return 1
    else
        # 更新成功啦
        LOGGER "更新到新版本!"
        dbus set clash_version=$clash_new_version
        dbus remove clash_new_version
        rm -f /tmp/${app_name}.${old_version}
    fi
}

start_cfddns(){
    # 配置检测
    [[ -z "$clash_cfddns_email" ]]  && LOGGER "email 没填写!" && return 1
    [[ -z "$clash_cfddns_apikey" ]]  && LOGGER "apikey 没填写!" && return 1
    [[ -z "$clash_cfddns_domain" ]]  && LOGGER "domain 没填写!" && return 1
    [[ -z "$clash_cfddns_ttl" ]]  && clash_cfddns_ttl="120"
    [[ -z "$clash_cfddns_ip" ]]  && clash_cfddns_ip='curl https://httpbin.org/ip 2>/dev/null |grep origin|cut -d\" -f4'
    [[ -z "$clash_cfddns_ip" ]]  && LOGGER "可能网络链接有问题，暂时无法访问外网,稍后再试!" && return 1
    # 支持多个域名更新
    for current_domain in `echo $clash_cfddns_domain | sed 's/[,，]/ /g'`
    do
        echo "当前域名: $current_domain"
        clash_cfddns_zone=`echo $current_domain| cut -d. -f2,3`
        clash_cfddns_zid=$(curl -X GET "https://api.cloudflare.com/client/v4/zones?name=$clash_cfddns_zone" -H "X-Auth-Email: $clash_cfddns_email" -H "X-Auth-Key: $clash_cfddns_apikey" -H "Content-Type: application/json" | jq -r '.result[0].id')
        clash_cfddns_recid=$(curl -X GET "https://api.cloudflare.com/client/v4/zones/$clash_cfddns_zid/dns_records?name=$current_domain" -H "X-Auth-Email: $clash_cfddns_email" -H "X-Auth-Key: $clash_cfddns_apikey" -H "Content-Type: application/json" | jq -r '.result[0].id')
        #dbus set clash_cfddns_ip=$clash_cfddns_ip
        dbus set clash_cfddns_ttl=$clash_cfddns_ttl
        real_ip=`echo ${clash_cfddns_ip}|sh 2>/dev/null`
        if [ "$?" != "0" -o "$real_ip" = "" ] ; then
            LOGGER "获取IP地址失败! 执行命令:[$clash_cfddns_ip], 提取结果:[$real_ip]"
            return 1
        fi
        update=$(curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$clash_cfddns_zid/dns_records/$clash_cfddns_recid" -H "X-Auth-Email: $clash_cfddns_email" -H "X-Auth-Key: $clash_cfddns_apikey" -H "Content-Type: application/json" --data "{\"id\":\"$clash_cfddns_zid\",\"type\":\"A\",\"name\":\"$current_domain\",\"content\":\"$real_ip\"}")
        res=`echo $update| jq -r .success`
        if [[ "$res" != "true" ]]; then
            LOGGER "更新结果失败!"
            echo "失败详细信息:"
            echo "$update| jq ."
        else
            LOGGER "更新DDNS成功!"
            # 添加cron调度
            add_ddns_cron
            clash_cfddns_lastmsg="`date +'%Y/%m/%d %H:%M:%S'`"
            dbus set clash_cfddns_lastmsg=$clash_cfddns_lastmsg
        fi
        LOGGER "$clash_cfddns_lastmsg"
    done
}

# 保存DDNS配置
save_cfddns() {
    if [ "$clash_cfddns_enable" != "on" ] ; then
        LOGGER "正在关闭 Cloudflare DDNS功能:"
        cru d clash_cfddns
        LOGGER "已经关闭 Cloudflare DDNS功能了."
    else
        LOGGER "正在启用 Cloudflare DDNS功能:"
        start_cfddns
        LOGGER "启用 Cloudflare DDNS 成功!"
    fi
}

# 修改网关和DNS服务器IP地址
change_gateway() {
    gateway_ip="$1"
    nvram set dhcp_dns1_x=${gateway_ip}
    nvram set dhcp_gateway_x=${gateway_ip}
    nvram commit
    echo "重启网卡!!!"
    service restart_net_and_phy
}

# 软路由监控状态
soft_route_check() {

    cur_gateway=$(nvram get  dhcp_gateway_x)
    
    ping -c 2 -W 1 -q $clash_watchdog_soft_ip
    if [ "$?" != "0" ] ; then
        if [ "${cur_gateway}" == "${lan_ipaddr}" ]; then
            echo "软路由已下线,DHCP配置已经添加,不用重复添加"
        else
            echo "软路由已下线,开始配置软路由DHCP信息"

            if [ "$clash_watchdog_start_clash" == "on" ] ; then
                LOGGER "设置自动开启Clash服务"
                dbus set clash_enable="on"
            fi
            change_gateway ${lan_ipaddr}
        fi
    else
        # 软路由上线: 检测配置文件是否已添加
        if [ "${cur_gateway}" == "${clash_watchdog_soft_ip}" ]; then
            echo "软路由的DHCP配置已经添加"
        else
            echo "软路由的DHCP配置没添加, 开始配置软路由DHCP信息"
            change_gateway ${clash_watchdog_soft_ip}
            LOGGER "关闭Clash服务"
            stop
        fi
    fi
}

# 启用旁路由监控工具
switch_route_watchdog() {

    if [ "$clash_watchdog_enable" == "on" ] ; then 
        LOGGER "开启旁路由watchdog自动监控服务"
        LOGGER "添加cron调度脚本"
        cru a soft_route_ctl "*/2 * * * * $main_script soft_route_check >/dev/null"
    else
        LOGGER "关闭旁路由watchdog自动监控服务"
        cru d soft_route_ctl
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

show_router_info() {
    get_fw_type
    echo "您的路由器基本信息(使用过程有问题时，粘贴以下内容，及问题现象说明):"
    echo "==========================================================="
    echo "路由器型号信息:$(nvram get productid)"
    echo "路由器固件信息:${FW_TYPE_NAME} $(nvram get buildno)"
    echo "Linux内核版本:$(uname -mnor)"
    echo "软件中心版本: $(dbus get softcenter_version)"
    echo "==========================================================="
    echo "默认DNS配置(/etc/resolv.conf):"
    echo "$(cat /etc/resolv.conf)"
    echo "iptables中关于Clash的转发规则(iptables -t nat -S clash):"
    echo "$(iptables -t nat -S clash)"
    if [ "$clash_gfwlist_mode" = "on" ] ; then
        echo "==========================================================="
        echo "Dnsmasq配置的gfwlist.conf信息:"
        confdir=`awk -F'=' '/^conf-dir/{ print $2 }' /etc/dnsmasq.conf`
        echo "$(wc -l ${confdir}/*.conf)"
    fi
    echo "==========================================================="
    echo "服务运行状态-clash: $(pidof clash)"
    echo "服务运行状态-dnsmasq: $(pidof dnsmasq)"
    echo "==========================================================="
    echo "Clash服务连接数量:$(netstat -anp|grep clash|grep ESTAB|wc -l)"
    echo "Clash监听端口信息:"
    echo "$(netstat -anp|head -2;netstat -anp|grep clash|grep LISTEN)"
}
######## 执行主要动作信息  ########
do_action() {
    if [ "$#" = "2" ] ; then
        http_response "$1"  >/dev/null
        action_job="$2"
    else
        # web界面配置操作
        if [ "$1" = "" ] ; then
            action_job="$clash_action"
        else
            action_job="$1"
        fi
    fi
    # LOGGER "执行动作 ${action_job} ..."
    case "$action_job" in
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
    update_clash_bin | switch_trans_mode|switch_group_type|switch_gfwlist_mode)
        # 需要重启的操作分类
        $action_job
        if [ "$?" = "0" ]; then
            stop
            start
        else
            LOGGER "$action_job 执行出错啦!"
        fi
        ;;
    get_proc_status|add_nodes|delete_one_node|delete_all_nodes|update_provider_file|update_geoip|swtich_localhost_dns|show_router_info)
        # 不需要重启操作
        $action_job
        ;;
    add_iptables | del_iptables|list_nodes|save_cfddns|start_cfddns | switch_route_watchdog| soft_route_check)
        $action_job
        ;;
    *)
        LOGGER "无效的操作! clash_action:[$action_job]"
        usage
        ;;
    esac
    # 执行完成动作后，清理动作.
    dbus remove clash_action
    echo "XU6J03M6"
}

do_action $@ 2>&1 >> $LOGFILE

