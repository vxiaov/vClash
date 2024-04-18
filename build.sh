#!/bin/bash
########################################################################
# File Name: build.sh
# Author: vxiaov
# mail: next4nextjob@gmail.com
# Created Time: 2022年01月02日 星期日 23时06分29秒
########################################################################

usage() {
    cat <<END
 Usage:
    `basename $0` go <version>  # 打包指定版本安装包
    `basename $0` pack  <version>  # 打包指定版本安装包并提交版本即tag
    `basename $0` gen_dns          # 生成dnsmasq使用的劫持DNS请求的转发规则

 Params:
    version : new version number , v2.2.4
 
 示例:

    `basename $0` go v2.5.1

END
}

# 生成最新版本Clash安装包 #
if [ "$1" = "" ] ; then
    usage
    exit
fi

generate_package() {
    # 生成release安装包
    echo "正在生成 release 安装包 ..."
    outdir="./release/"
    new_version="$1"
    arch="${2:-arm64}"
    sed -i "s/vClash:.*/vClash:$new_version/" clash/clash/version
    echo -n "arm384" > clash/.valid

    # 拷贝可执行文件，构建最小安装包
    rm -rf ./clash/clash/bin
    mkdir ./clash/clash/bin
    bin_list="yq jq clash"
    for fn in ${bin_list} ; do
        cp ./bin/${fn}_for_${arch} ./clash/clash/bin/${fn}
    done
    tar zcf ./release/clash_384.tar.gz clash/
    echo -n "hnd|arm384|arm386|p1axhnd.675x" > clash/.valid
    tar zcf ./release/clash.tar.gz clash/
    rm -rf ./clash/clash/bin

}

# 更新ruleset内部的文件
update_ruleset() {
    wkdir=./clash/clash
    yq e '.rule-providers[]|select(.type=="http")|.path + " " + .url' ${wkdir}/config.yaml | while read fname furl ; do
        echo "Loading rule provider $fname"
        wget -O ${wkdir}/$fname $furl     > /dev/null 2>&1
    done
}


print_dnsmasq() {

    dns_port=1053
    dns_server=127.0.0.1

    cat $@ | awk -F, '/DOMAIN-SUFFIX/{ print $2 }' | sort -u | while read line 
    do
        # 生成conf配置格式: server=/xxx.com/127.0.0.1#1053
        echo "server=/${line}/${dns_server}#${dns_port}"
    done
}

# 生成路由器dnsmasq使用的DNS请求转发规则
generate_dnsmasq_conf() {

    out_file="dnsmasq_rules/gfwlist.conf"
    wkdir="./clash/clash"

    cd ${wkdir}
    echo -n > ${out_file}   # 清空历史数据
    # 生成Dnsmasq转发DNS请求规则列表
    print_dnsmasq `yq e '.rule-providers[]|select(.type=="http" and .behavior == "classical" )|.path' ./config.yaml`  >> ${out_file}
    [[ -f ./ruleset/my_blacklist.yaml ]] && print_dnsmasq ./ruleset/my_blacklist.yaml   >> ${out_file}

    cd -
}


generate_gfwlist() {
    # 生成gfw.yaml #
    filter_flag="${1:-0}"
    outdir="./clash/clash/ruleset/"
    curl -s https://cdn.jsdelivr.net/gh/Loyalsoldier/clash-rules@release/gfw.txt > ${outdir}/gfw.tmp
    if [ "$filter_flag" = "1" ] ; then
        # 精简过滤一些地址
        yq e -P '.payload[]' ${outdir}/gfw.tmp | awk -F'.' 'BEGIN{
            printf("payload:\n");
        }{
            idx=$(NF-1)"."$(NF);
            a[idx]++;
        }END{
            for(i in a)
                printf("  - '\''+.%s'\''\n", i);
        }' > ${outdir}/rule_diy_gfw.yaml
    else
        yq e -P ${outdir}/gfw.tmp > ${outdir}/rule_diy_gfw.yaml
    fi
    rm -f ${outdir}/gfw.tmp
    echo "rule_diy_gfw.yaml 生成完毕."
}

case "$1" in
    go)
        [[ "$2" == "" ]] && echo "缺少版本号信息!" && exit 1
        generate_package $2 $3
        ;;
    pack)
        [[ "$2" == "" ]] && echo "缺少版本号信息!" && exit 1
        generate_package $2 $3
        git add ./
        git commit -m "docs: 提交$2版本离线包"
        git tag $2
        work_branch="$(git branch --show-current)"
        git checkout ksmerlin386
        git merge ${work_branch}
        git push --set-upstream origin ksmerlin386 --tag        
        ;;
    gen_dns) # 生成Dnsmasq配置规则
        generate_dnsmasq_conf
        ;;
    update_ruleset) # 手动更新Ruleset规则集
        update_ruleset
        ;;
    *)
        usage
        ;;
esac
