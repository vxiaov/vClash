#!/bin/sh
########################################################################
# File Name: clash_config.sh
# Author: zioer
# mail: next4nextjob@gmail.com
# Created Time: 2021年08月31日 星期二 12时06分04秒
# 配置文件修改操作脚本
########################################################################

KSHOME="/koolshare"
app_name="clash"

source ${KSHOME}/scripts/base.sh

LOGGER() {
    # Magic number for Log 9977
    logger -s -t "9977`date +%H`.clashlog" "$@"
}
eval `dbus export ${app_name}_`

config_file="/koolshare/${app_name}/config.yaml"
temp_provider_file="/tmp/clash_provider.yaml"

# 更新Clash订阅源URL地址 #
update_yaml_provider_url() {
    if [ "$clash_provider_url" = "" ] ; then
        LOGGER "没有设置订阅源信息: clash_provider_url=${clash_provider_url} ，不更新！"
        return 0
    fi

    status_code=`curl -I ${clash_provider_url} | awk '/HTTP/{ print $2 }'`
    if [ "$status_code" != "200" ] ; then
        LOGGER "提供的远程订阅地址无效,curl访问返回状态码(非200):${status_code},clash_provider_url：${clash_provider_url}"
        return 1
    fi
    curl -o $temp_provider_file ${clash_provider_url}
    if [ "$?" != 0 ] ; then
        LOGGER 下载节点订阅源文件失败!
        return 2
    fi
    # URL地址请求正常，并不能表明 yaml 格式正常
    yq e ${temp_provider_file} >/dev/null
    if [ "$?" != "0" ] ; then
        LOGGER "节点订阅源配置文件yaml格式错误： ${temp_provider_file}"
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

main(){
    case "$1" in
        update_yaml_provider_url)
        $1 ;;
        *)
        update_yaml_provider_url
        ;;
    esac
}

main $@

###
