#!/bin/sh
#########################################################
# Clash Process Control script for AM380 merlin firmware
# Writen by Awkee (next4nextjob(at)gmail.com)
# Website: https://vlike.work
#########################################################

KSHOME="/koolshare"
app_name="clash"

source ${KSHOME}/scripts/base.sh

# 路由器IP地址
lan_ipaddr="$(nvram get lan_ipaddr)"

dbus set clash_lan_ipaddr=$lan_ipaddr

eval $(dbus export ${app_name}_)

alias curl="curl --connect-timeout 300 -sSL"

CURL_OPTS=" "

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

debug_log=/tmp/upload/clash_debug.log
# 备份数据文件(包括:providers/rules/config.yaml)
backup_file=/tmp/upload/${app_name}_backup.tar.gz
env_file="${app_name}_env.sh"


# 自定义黑名单规则文件
blacklist_file="/koolshare/${app_name}/ruleset/rule_diy_blacklist.yaml"
# 自定义白名单规则文件
whitelist_file="/koolshare/${app_name}/ruleset/rule_diy_whitelist.yaml"

default_test_node="proxies:\n  - name:  test代理分享站(别选我):https://vlike.work\n    type:  ss\n    server:  127.0.0.1\n    port:  9999\n    password:  123456\n    cipher:  aes-256-gcm"

check_config_file() {
    # 检查 config.yaml 文件配置信息
    clash_yacd_secret=$(yq e '.secret' $config_file)
    clash_yacd_ui="http://${lan_ipaddr}:${yacd_port}/ui/yacd/?hostname=${lan_ipaddr}&port=${yacd_port}&secret=$clash_yacd_secret"
    yq_expr='.redir-port=env(tmp_port)|.dns.listen=strenv(tmp_dns)|.external-controller=strenv(tmp_yacd)|.external-ui="/koolshare/clash/dashboard"|.dns.enhanced-mode="redir-host"'
    tmp_yacd="0.0.0.0:$yacd_port" tmp_dns="0.0.0.0:$dns_port" tmp_port=$redir_port yq e -iP "$yq_expr" $config_file
    dbus set clash_yacd_ui=$clash_yacd_ui
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


get_arch() {
    # 暂时支持ARM芯片吧，等手里有 MIPS 芯片再适配
    case $(uname -m) in
        armv7l)
            if grep -i vfpv3 /proc/cpuinfo >/dev/null 2>&1; then
                ARCH="armv7"
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
    return $ARCH
}

get_proc_status() {
    clash_use_mem="$(cat /proc/$(pidof ${app_name})/status | grep VmRSS | awk '{printf("%.02f MB", $2/1024);}')"
    free_mem="$(free | grep Mem | awk '{printf("%.02f MB", $4/1024);}')"
    total_mem="$(free | grep Mem | awk '{printf("%.02f MB", $2/1024);}')"
    echo "+----------[ 服务信息: ${clash_rule_mode} ]--------------------------------"
    echo "| $(echo_status head)"
    echo "| $(echo_status $app_name)"
    echo "| Clash占用内存: $clash_use_mem, 系统剩余内存: $free_mem, 系统总内存: $total_mem"
    echo "+----------[ 调度信息 ]--------------------------------"
    echo "|  $(cru l| grep ${cron_id})"
    echo "|  $(cru l| grep update_provider_local)"
    if [ "$clash_cfddns_enable" = "on" ] ; then
        echo "|  $(cru l| grep clash_cfddns)"
    fi
    if [ "$clash_watchdog_enable" = "on" ] ; then
        echo "|  $(cru l| grep soft_route_check)"
    fi
    
    echo "+---------------------------------------------------"
    echo "| Clash重启信息: [$(grep start_${app_name} /tmp/syslog.log|wc -l)] 次, 最近 [3次] 时间如下:"
    echo "$(grep start_${app_name} /tmp/syslog.log|tail -3| awk '{printf("| %s\n", $0);}')"
    echo "+---------------------------------------------------"
}

add_ddns_cron(){
    if [ "$clash_cfddns_enable" = "on" ] ; then
        if cru l | grep clash_cfddns > /dev/null ; then
            LOGGER "已经添加cfddns调度!"
        else
            ttl=`expr $clash_cfddns_ttl / 60`
            if [ "$ttl" -lt "2" -o "$ttl" -ge "1440" ] ; then
                ttl="2"
            fi
            
            cru a clash_cfddns "*/${ttl} * * * * $main_script start_cfddns"
            if [ "$?" = "0" ] ; then
                LOGGER "成功添加cfddns调度!"
            else
                LOGGER "添加cfddns调度失败"
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


service_start() {
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
        
        check_config_file
        LOGGER "启动配置文件 ${config_file} : 检测完毕!"
        nohup ${CMD} >/dev/null 2>&1 &
        sleep 1
        if status >/dev/null 2>&1; then
            LOGGER "${CMD} 启动成功!"
        else
            dbus set clash_enable="off"
            LOGGER "${CMD} 启动失败! 执行失败原因如下:"
            ${CMD}
            return 1
        fi
        # 用于记录Clash服务稳定程度
        SYSLOG "${app_name} 服务启动成功 : pid=$(pidof ${app_name})"
        dbus set ${app_name}_enable="on"
    fi
    add_iptables
    add_cron
    list_nodes
}

service_stop() {
    # 1. 停止服务进程
    # 2. 清理iptables策略
    #echo "停止 $app_name"
    if status >/dev/null 2>&1; then
        LOGGER "开始停止 ${app_name} ..."
        killall ${app_name}
    fi
    del_iptables  2>/dev/null
    del_cron
    if status >/dev/null 2>&1; then
        LOGGER "${CMD} 停止失败!"
        dbus set ${app_name}_enable="on"
    else
        LOGGER "${CMD} 停止成功!"
        dbus set ${app_name}_enable="off"
    fi
}

########## config part ###########

# DIY节点 列表
list_nodes() {
    filename="$provider_diy_file"
    node_list=`yq e '.proxies[].name' $filename| awk '!/test/{ printf("%s ", $0)}'`
    LOGGER "DIY节点列表: [${node_list}]"
    dbus set clash_name_list="$node_list"
}

list_proxy_num() {
    filename="$1"
    yq e '.proxies[].type' ${filename} | awk '{ 
        a[$1]++
    }END{
        printf("\n")
        for(i in a){ 
            printf("| %s:%.0f ",i,a[i]);
        }
        printf("|\n")
    }'
}

# DIY节点 添加节点(一个或多个)
add_nodes() {
    tmp_node_file="/koolshare/clash/tmp_node.yaml"
    # 替换掉回车、多行文本变量页面加载时会出错!

    node_list="$clash_node_list"
    if [ "$node_list" = "" ] ; then
        LOGGER "想啥呢!节点可不会凭空产生!你得传入 ss:// 或 ssr:// 或者 vmess:// 前缀的URI链接!"
        return 1
    fi

    # 生成节点文件
    socks5_proxy="socks5://127.0.0.1:$(yq e '.socks-port' ${config_file})"
    uri_decoder -proxy "$socks5_proxy" -uri "$node_list" -db "/koolshare/clash/Country.mmdb" > ${tmp_node_file}
    if [ "$?" != "0" -o ! -s "${tmp_node_file}" ] ; then
        LOGGER "抱歉!你添加的链接解析失败啦!给个正确的链接吧!"
        return 2
    fi
    LOGGER "获取DIY代理节点数量信息: $(list_proxy_num ${tmp_node_file})"

    cp $provider_diy_file $provider_diy_file.old
    yq_expr='select(fi==1).proxies as $plist | select(fi==0)|.proxies += $plist'
    yq ea -iP "$yq_expr" ${provider_diy_file} ${tmp_node_file}
    if [ "$?" != "0" ] ; then
        cp $provider_diy_file.old $provider_diy_file
        rm -f $provider_diy_file.old ${tmp_node_file}
        LOGGER "怎么会这样! 添加DIY代理节点失败啦!"
        return 2
    fi
    LOGGER "添加DIY节点成功!"
    rm -f ${provider_diy_file}.old ${tmp_node_file}
    dbus remove clash_node_list
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
    node_num="$(yq e '.proxies[].name' $filename |grep -v "test"|wc -l)"
    if [ "$node_num" = "0" ] ; then
        LOGGER "已经清理过了，不用再清理了"
    else
        cp $filename $filename.old
        LOGGER "开始清理所有DIY节点:"
        # 偷个懒: 重置DIY配置文件只包含 test节点 就可以了。
        echo -e "$default_test_node" > $filename
        LOGGER "清理DIY节点完毕!让世界回归平静!"
    fi
    list_nodes
}

#############  provider 订阅源管理

# 更新订阅源:文件类型
update_provider_file() {

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
    LOGGER "成功导入代理节点:$(list_proxy_num $provider_remote_file)"
    rm -f $temp_provider_file
}

# 更新Country.mmdb文件
update_geoip() {
    #
    geoip_file="${KSHOME}/clash/Country.mmdb"
    cp ${geoip_file} ${geoip_file}.bak
    # 精简中国IP列表生成MaxMind数据库: https://cdn.jsdelivr.net/gh/Hackl0us/GeoIP2-CN@release/Country.mmdb
    # 全量MaxMind数据库文件: https://cdn.jsdelivr.net/gh/Dreamacro/maxmind-geoip@release/Country.mmdb
    # 全量MaxMind数据库文件（融合了ipip.net数据）: https://cdn.jsdelivr.net/gh/alecthw/mmdb_china_ip_list@release/Country.mmdb
    # 切换使用代理dns转发

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
    LOGGER "「$geoip_file」文件更新成功!"
    LOGGER "文件大小变化[`du -h ${geoip_file}.bak|cut -f1`]=>[`du -h ${geoip_file}|cut -f1`]"
    rm ${geoip_file}.bak
}

# 透明代理开关
switch_trans_mode(){
    LOGGER "切换透明代理模式:$clash_trans"
}

# 忽略clash新版本提醒
ignore_new_version() {
    dbus set clash_version=$clash_new_version
    LOGGER "已忽略当前版本:$clash_new_version"
}

# 更新新版本clash客户端可执行程序
update_clash_bin() {
    cd /tmp
    new_ver=$clash_new_version
    old_version=$clash_version
    
    # 专业版更新
    # https://hub.fastgit.org/Dreamacro/clash/releases/tag/premium
    # https://github.com/Dreamacro/clash/releases/tag/premium
    LOGGER "CURL_OPTS:${CURL_OPTS}"
    LOGGER "正在执行命令: curl ${CURL_OPTS} https://github.com/Dreamacro/clash/releases/tag/premium"
    ARCH="$(get_arch)"
    download_url="$(curl ${CURL_OPTS} https://github.com/Dreamacro/clash/releases/tag/premium | grep "clash-linux-${ARCH}" | awk '{ gsub(/href=|["]/,""); print "https://github.com"$2 }'|head -1)"
    bin_file="new_$app_name"
    LOGGER "正在下载新版本:curl ${CURL_OPTS} -o ${bin_file}.gz $download_url"
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
        # echo "当前域名: $current_domain"
        clash_cfddns_zone=`echo $current_domain| cut -d. -f2,3`
        clash_cfddns_zid=$(curl -X GET "https://api.cloudflare.com/client/v4/zones?name=$clash_cfddns_zone" -H "X-Auth-Email: $clash_cfddns_email" -H "X-Auth-Key: $clash_cfddns_apikey" -H "Content-Type: application/json" | jq -r '.result[0].id')
        clash_cfddns_recid=$(curl -X GET "https://api.cloudflare.com/client/v4/zones/$clash_cfddns_zid/dns_records?name=$current_domain" -H "X-Auth-Email: $clash_cfddns_email" -H "X-Auth-Key: $clash_cfddns_apikey" -H "Content-Type: application/json" | jq -r '.result[0].id')
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
            LOGGER "当前域名: $current_domain, 更新DDNS成功!"
            # 添加cron调度
            add_ddns_cron
            clash_cfddns_lastmsg="$(date +'%Y/%m/%d %H:%M:%S')"
            dbus set clash_cfddns_lastmsg=$clash_cfddns_lastmsg
        fi
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
    if [ "$cur_gateway" = "" ] ; then
        LOGGER "没有设置默认网关地址，取路由器本机IP地址,例如: 192.168.50.1"
        cur_gateway="${lan_ipaddr}"
    fi
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
            service_stop
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

debug_info() {
    printf "|%20s : %-40.40s|\n" "$1" "$2"
}

# DEBUG 路由器信息
show_router_info() {
    get_fw_type
    echo "您的路由器基本信息(反馈开发者帮您分析问题用):"
    echo "| system : $(uname -nmrso)|"
    echo "| rom    : $(nvram get productid):${FW_TYPE_NAME}:$(nvram get buildno)|"
    echo "| memory : $(free -m|awk '/Mem/{printf("free: %6.2f MB,total: %6.2f MB,usage: %6.2f%%\n", $4/1024,$2/1024, $3/$2*100)}')|"
    echo "| /jffs  : $(df /jffs|awk '/jffs/{printf("free: %6.2f MB,total: %6.2f MB,usage: %6.2f%%\n", $4/1024,$2/1024, $3/$2*100)}')|"
    echo "+---------------------------------------------------------------+"
    echo "|>> vClash实际使用的软件版本:                                   << |"
    debug_info "vClash" "$(dbus get softcenter_module_${app_name}_version)"
    debug_info "clash_premium" $(clash -v|head -n1|awk '{printf("%s_%s_%s", $2, $3, $4)}')
    debug_info "yq" "$(yq -V|awk '{ print $NF}')"
    debug_info "jq" "$(jq -V)"
    echo "|>> vClash安装包自带软件版本:                                   << |"
    cat /koolshare/${app_name}/version | awk -F':' '{ printf("|%20s : %-40.40s|\n",$1,$2) }'
    echo "+---------------------------------------------------------------+"
    echo "vClash的转发规则(iptables -t nat -S ${app_name}):"
    iptables -t nat -S ${app_name}
    echo "---------------------------------------------------------------"
}


backup_env() {
    # 输出环境变量到/koolshare/${app_name}/$env_file文件
    LOGGER "开始备份环境变量"
    echo "source /koolshare/scripts/base.sh" > /koolshare/${app_name}/$env_file
    dbus list clash_ | grep -v "=o[nf]" | sed 's/^/dbus set /; s/=/=\"/;s/$/\"/' >> /koolshare/${app_name}/$env_file
    if [ "$?" != "0" ] ; then
        LOGGER "备份环境变量失败"
    else
        LOGGER "备份环境变量成功"
    fi
    # echo "echo '恢复环境变量完成'" >> /koolshare/${app_name}/$env_file
}

backup_config_file() {
    # 备份配置信息,打包生成压缩包文件
    # 备份文件名列表
    file_list="providers config.yaml ruleset $env_file .cache"    
    LOGGER "开始备份配置信息: $file_list"
    if [ -d "/koolshare/${app_name}" ] ; then
        backup_env
        cur_filelist=""
        for fn in $file_list
        do
            if [ ! -r "/koolshare/${app_name}/${fn}" ] ; then
                LOGGER "没不到备份文件或目录: /koolshare/${app_name}/${fn}"
                # return 1
                continue
            fi
            if [ "$cur_filelist" == "" ] ; then
                cur_filelist="$fn"
            else
                cur_filelist="$cur_filelist $fn"
            fi
        done
        # 压缩文件名
        tar -zcvf $backup_file -C /koolshare/${app_name} ${cur_filelist}
        if [ "$?" != "0" ] ; then
            LOGGER "备份配置信息失败"
        else
            LOGGER "备份配置信息成功"
            rm -f /koolshare/${app_name}/$env_file
        fi
    else
        LOGGER "备份配置信息失败"
    fi
}

restore_config_file() {
    # 恢复配置信息,解压生成配置文件
    LOGGER "开始恢复配置信息"
    if [ "$clash_restore_file" = "" ] ; then
        LOGGER "恢复配置文件上传失败"
        return 1
    fi
    if [ -f "/tmp/upload/$clash_restore_file" ] ; then
        tar -zxvf "/tmp/upload/$clash_restore_file" -C /koolshare/${app_name}
        if [ "$?" != "0" ] ; then
            LOGGER "恢复配置信息失败!解压过程出错! 文件名:${clash_restore_file}"
        else
            if [ -f "/koolshare/${app_name}/$env_file" ] ; then
                LOGGER "开始执行恢复环境变量脚本"
                sh "/koolshare/${app_name}/$env_file"
                # rm -f "/koolshare/${app_name}/$env_file"
                LOGGER "执行恢复环境变量脚本完成"
            fi
            LOGGER "恢复配置信息成功"
        fi
    else
        LOGGER "恢复配置信息文件没找到!"
        return 2
    fi
    rm -f "/tmp/upload/$clash_restore_file"
    dbus remove clash_restore_file
}

# 上传并应用新的config.yaml配置文件
applay_new_config() {
    
    LOGGER "开始应用新配置"
    if [ "$clash_config_file" = "" ] ; then
        LOGGER "没有设置[clash_config_file]参数"
        return 1
    fi
    if [ ! -f "/tmp/upload/${clash_config_file}" ] ; then
        LOGGER "找不到配置文件: /tmp/upload/${clash_config_file}"
        return 2
    fi
    # 先备份后复制
    cp -p /koolshare/${app_name}/config.yaml /koolshare/${app_name}/config.yaml.bak
    cp -f "/tmp/upload/${clash_config_file}" "/koolshare/${app_name}/config.yaml"
    if [ -f "/koolshare/${app_name}/config.yaml" ] ; then
        LOGGER "拷贝新配置成功"
    else
        LOGGER "拷贝新配置失败"
    fi
    rm -f "/tmp/upload/${clash_config_file}"
    dbus remove clash_config_file
    LOGGER "应用新配置完成,准备重启clash服务...\n"
}

check_valid_rule() {
    # 检查rule参数是否有效
    rule="$1"
    # 检查是否为IPv4地址或IPv4段
    
    if [ "$(echo $rule | grep -E "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$")" != "" ] ; then
        return "IP-CIDR,$rule/32"
    fi
    # 检查rule是否为域名后缀
    if [ "$(echo $rule | grep -E "^[a-zA-Z0-9]+\.[a-zA-Z]{2,}$")" != "" ] ; then
        return "DOMAIN-SUFFIX,$rule"
    fi
    # 检查rule为单词
    if [ "$(echo $rule | grep -E "^[a-zA-Z0-9]+$")" != "" ] ; then
        return "DOMAIN-KEYWORD,$rule"
    fi

    # 返回字符串表示无效rule
    return ""
}

# 添加base64编码的blacklist规则
save_blacklist_rule() {
    LOGGER "开始添加黑名单规则"
    if [ "$clash_blacklist_rules" = "" ] ; then
        LOGGER "没有设置[clash_blacklist_rules]参数"
        return 1
    fi
    tmp_file="/tmp/upload/clash_blacklist_rules.yaml"
    echo $clash_blacklist_rules | base64_decode  > $tmp_file
    if [ ! -f "$tmp_file" ] ; then
        LOGGER "base64解码失败"
        return 2
    fi
    
    # 格式化yaml文件，备份并保存新文件
    yq e -iP $tmp_file && cp -f $blacklist_file $blacklist_file.bak && cp -f $tmp_file $blacklist_file
    if [ "$?" != "0" ] ; then
        LOGGER "添加黑名单规则失败"
        return 2
    fi
    rm -f $tmp_file
    LOGGER "添加黑名单规则成功"
}

# 添加base64编码的whitelist规则
save_whitelist_rule() {
    LOGGER "开始添加白名单规则"
    if [ "$clash_whitelist_rules" = "" ] ; then
        LOGGER "没有设置[clash_whitelist_rules]参数"
        return 1
    fi
    tmp_file="/tmp/upload/clash_whitelist_rules.yaml"
    echo $clash_whitelist_rules| base64_decode  > $tmp_file
    if [ ! -f "$tmp_file" ] ; then
        LOGGER "base64解码失败"
        return 2
    fi
    # 格式化yaml文件，备份并保存新文件
    yq e -iP $tmp_file && cp -f $whitelist_file $whitelist_file.bak && cp -f $tmp_file $whitelist_file
    if [ "$?" != "0" ] ; then
        LOGGER "添加白名单规则失败"
        return 2
    fi
    rm -f $tmp_file
    LOGGER "添加白名单规则成功"
}

# 获取黑名单规则并编码为base64
get_blacklist_rules(){
    dbus set clash_blacklist_rules=$(cat $blacklist_file|base64_encode)
    if [ "$?" != "0" ] ; then
        LOGGER "读取黑名单规则失败"
        return 1
    fi
    LOGGER "读取黑名单规则成功"
}

# 获取白名单规则并编码为base64
get_whitelist_rules(){
    dbus set clash_whitelist_rules=$(cat $whitelist_file|base64_encode)
    if [ "$?" != "0" ] ; then
        LOGGER "读取白名单规则失败"
        return 1
    fi
    LOGGER "读取白名单规则成功"
}

# 切换为黑名单模式(默认模式)
switch_blacklist_mode() {
    LOGGER "开始切换为黑名单模式"
    # 切换为黑名单模式: 修改 rule 配置信息
    yq_expr='select(fi==1).rules as $p1list | select(fi==2).rules as $p2list | select(fi==0)|.rules = $p1list + $p2list'
    rule_basic_file="${KSHOME}/${app_name}/ruleset/rule_part_basic.yaml"
    rule_blacklist_file="${KSHOME}/${app_name}/ruleset/rule_part_blacklist.yaml"
    yq ea -iP "$yq_expr" ${config_file} ${rule_basic_file} ${rule_blacklist_file}
    if [ "$?" != "0" ] ; then
        LOGGER "切换为黑名单模式失败"
        return 1
    fi
    dbus set clash_rule_mode=$clash_rule_mode
    LOGGER "切换为黑名单模式成功"
}

# 切换为白名单模式
switch_whitelist_mode() {
    LOGGER "开始切换为白名单模式"
    # 切换为白名单模式: 修改 rule 配置信息
    yq_expr='select(fi==1).rules as $p1list | select(fi==2).rules as $p2list | select(fi==0)|.rules = $p1list + $p2list'
    rule_basic_file="${KSHOME}/${app_name}/ruleset/rule_part_basic.yaml"
    rule_whitelist_file="${KSHOME}/${app_name}/ruleset/rule_part_whitelist.yaml"
    yq ea -iP "$yq_expr" ${config_file} ${rule_basic_file} ${rule_whitelist_file}
    if [ "$?" != "0" ] ; then
        LOGGER "切换为白名单模式失败"
        return 1
    fi
    dbus set clash_rule_mode=$clash_rule_mode
    LOGGER "切换为白名单模式成功"
}

save_current_tab() {
    # 保存当前tab标签页面id操作
    echo "仅仅用于实时保存最后选择的tab页面id" >/dev/null
}

# 获取 config.yaml 中配置的文件路径
list_config_files() {
    # local tmp_rule_filepath="$(yq e '.rule-providers[]|select(.type == "file").path' ${config_file} | awk '{ printf("%s ",$0);}')"
    # local tmp_proxy_filepath="$(yq e '.proxy-providers[]|select(.type == "file").path' ${config_file} | awk '{ printf("%s ",$0);}')"
    tmp_filepath_list="$(yq e '.rule-providers[]|select(.type=="file").path,.proxy-providers[]|select(.type=="file").path' ${config_file})"
    if [ -z "$tmp_filepath_list" ] ; then
        LOGGER "您的config.yaml配置文件没有 file 类型的配置文件(rule-providers/proxy-providers)"
    fi
    tmp_filelist="./config.yaml ./ruleset/rule_part_basic.yaml ./ruleset/rule_part_blacklist.yaml ./ruleset/rule_part_whitelist.yaml"
    for fn in $tmp_filepath_list
    do
        # 忽略 1MB大小以上的文件: dbus value大小限制为1MB
        if [ `cat $KSHOME/$app_name/$fn | wc -c` -lt 786432 ]; then
            # 保留文件内容比较少的文件,文件过大无法直接保存和修改
            tmp_filelist="$tmp_filelist $fn"

        fi
    done
    dbus set clash_edit_filelist="$tmp_filelist"
    LOGGER "获取配置文件列表成功!"
}

get_one_file() {
    # 获取单个文件的内容
    local file_name="$(echo $KSHOME/${app_name}/$clash_edit_filepath | sed 's/\/\.\//\//g')"
    if [ ! -f ${file_name} ]; then
        LOGGER "文件没找到: ${file_name}"
        return 1
    fi
    dbus set clash_edit_filecontent=$(cat ${file_name} | base64_encode)
    if [ $? -ne 0 ]; then
        LOGGER "${file_name} 文件读取失败!"
        return 2
    fi
    LOGGER "${file_name} 文件读取完成!"
}

set_one_file() {
    # 设置单个文件的内容: 过滤掉中间的 "./"部分
    local file_name="$(echo $KSHOME/${app_name}/$clash_edit_filepath | sed 's/\/\.\//\//g')"
    if [ ! -f ${file_name} ]; then
        LOGGER "文件没找到: ${file_name}"
        return 1
    fi
    cp ${file_name} ${file_name}.bak
    echo -n ${clash_edit_filecontent} | base64_decode > ${file_name}.tmp
    if [ $? -eq 0 ]; then
        mv ${file_name}.tmp ${file_name}
        LOGGER "${file_name} 保存成功!"
    else
        rm -f ${file_name}.bak
        LOGGER "${file_name} 保存失败!"
        return 1
    fi
    rm -f ${file_name}.bak
}

clash_config_init() {
    # 初始化配置文件
    # 初始化编辑文件列表
    list_config_files

    # 校验配置文件:初始化 yacd 访问链接: 执行太慢了，影响页面加载速度,暂时屏蔽
    # check_config_file
}
# 使用帮助信息
usage() {
    cat <<END
 ======================================================
 使用帮助:
    ${app_name} <start|stop|restart>
    ${app_name} start_cfddns|stop_cfddns
    ${app_name} update_provider_file

 参数介绍:
    start   启动服务
    stop    停止服务
    restart 重启服务
    start_cfddns  启动自动更新DNS
    stop_cfddns   停止自动更新DNS
    update_provider_file 更新provider_free.yaml文件

 ======================================================
END
    exit 0
}

# 用于返回JSON格式数据: {result: id, status: ok, data: {key:value, ...}}
response_json() {
    # 其中 data 内容格式示例: "{\"key\":\"value\"}"
    # 参数说明:
    #   $1: 请求ID
    #   $2: 想要传递给页面的JSON数据:格式为:key=value\nkey=value\n...
    #   $3: 返回状态码, ok为成功, error等其他为失败
    http_response "$1\",\"data\": "$2", \"status\": \"$3"  >/dev/null 2>&1
}

######## 执行主要动作信息  ########
do_action() {

    if [ "$#" = "2" ] ; then
        # web界面配置操作
        action_job="$2"
        case "$action_job" in 
            test_res)
                # awk使用=分隔符会导致追加尾部的=号被忽略而出现错误
                # 因此使用了sub只替换第一个=号为":"，后面的=号不变
                ret_data="{$(dbus list clash_edit| awk '{sub("=", "\":\""); printf("\"%s\",", $0)}'|sed 's/,$//')}"
                response_json "$1" "$ret_data" "ok"
                return 0
                ;;
            start)
                # 启动服务, 并返回状态
                service_start
                ret_data="{$(dbus list clash_ | awk '{sub("=", "\":\""); printf("\"%s\",", $0)}'|sed 's/,$//')}"
                response_json "$1" "$ret_data" "ok"
                # 先返回成功结果,放在后面执行启动功能，否则页面会一直等待且没有动态执行中的效果
                # service_start
                return 0
                ;;
            get_one_file)
                get_one_file
                ret_data="{$(dbus list clash_edit_filecontent | awk '{sub("=", "\":\""); printf("\"%s\",", $0)}'|sed 's/,$//')}"
                response_json "$1" "$ret_data" "ok"
                return 0
                ;;
            list_config_files)
                list_config_files
                ret_data="{$(dbus list clash_edit_filelist  | awk '{sub("=", "\":\""); printf("\"%s\",", $0)}'|sed 's/,$//')}"
                response_json "$1" "$ret_data" "ok"
                return 0
                ;;
            list_nodes)
                list_nodes
                ret_data="{$(dbus list clash_name_list  | awk '{sub("=", "\":\""); printf("\"%s\",", $0)}'|sed 's/,$//')}"
                response_json "$1" "$ret_data" "ok"
                return 0
                
                ;;
            load_rules) # 点击进入规则管理tab页面时调用
                get_blacklist_rules
                get_whitelist_rules
                # 获取 clash_blacklist_rules clash_whitelist_rules 信息
                ret_data="{$(dbus list clash_ | grep list_rules | awk '{sub("=", "\":\""); printf("\"%s\",", $0)}'|sed 's/,$//')}"
                response_json "$1" "$ret_data" "ok"
                return 0
                ;;
            clash_config_init)
                clash_config_init
                ret_data="{$(dbus list clash_  | awk '{sub("=", "\":\""); printf("\"%s\",", $0)}'|sed 's/,$//')}"
                response_json "$1" "$ret_data" "ok"
                return 0
                ;;
            ignore_new_version)
                ignore_new_version
                ret_data="{$(dbus list clash_version  | awk '{sub("=", "\":\""); printf("\"%s\",", $0)}'|sed 's/,$//')}"
                response_json "$1" "$ret_data" "ok"
                return 0
                ;;
            *)
                http_response "$1" >/dev/null 2>&1
                ;;
        esac
    else
        # 后台执行脚本
        if [ "$1" = "" ] ; then
            action_job="help"
        else
            action_job="$1"
        fi
    fi
    # LOGGER "执行动作 ${action_job} ..."
    case "$action_job" in
    stop)
        service_stop
        ;;
    start)
        service_start
        ;;
    restart)
        service_stop
        service_start
        ;;
    update_clash_bin | switch_trans_mode|switch_group_type| applay_new_config|switch_whitelist_mode|switch_blacklist_mode|restore_config_file)
        # 需要重启的操作分类
        $action_job
        if [ "$?" = "0" ]; then
            service_stop
            service_start
        else
            LOGGER "$action_job 执行出错啦!"
        fi
        ;;
    get_proc_status|add_nodes|delete_one_node|delete_all_nodes|update_provider_file|update_geoip|backup_config_file|get_blacklist_rules|get_whitelist_rules|save_blacklist_rule|save_whitelist_rule)
        # 不需要重启操作
        $action_job
        ;;
    add_iptables | del_iptables|save_cfddns|start_cfddns | switch_route_watchdog| soft_route_check)
        $action_job
        ;;
    set_one_file)
        # 不需要重启操作
        $action_job
        ;;
    show_router_info)
        # 输出debug信息
        $action_job  | tee -a $debug_log
        ;;
    help)
        usage
        ;;
    *)
        LOGGER "无效的操作! clash_action:[$action_job]"
        usage
        ;;
    esac
    # 执行完成动作后，清理动作.
    dbus remove clash_action
}

LOGFILE="/tmp/upload/clash_status.log"
if [ "$#" = "1" ] ; then
    # 后台执行脚本: 输出结果不保存
    LOGFILE=/dev/null
fi


no_output_log=0
case "$2" in
    clash_config_init|save_current_tab|list_config_files|list_nodes)
        # 不需要输入日志内容
        no_output_log=1
        ;;
esac

if [ "$no_output_log" = "0" ] ; then
    echo > $LOGFILE
    do_action $@ 2>&1 | tee -a $LOGFILE
    echo "XU6J03M6" >> $LOGFILE
else
    do_action $@  >/dev/null 2>&1
fi
