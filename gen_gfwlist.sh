#!/bin/bash
########################################################################
# File Name: gen.sh
# Author: zioer
# mail: next4nextjob@gmail.com
# Created Time: 2021年09月04日 星期六 14时40分10秒
########################################################################

# 重定向的DNS端口#
DNS_PORT="${1:-1053}"

# 存放规则文件目录#
src_dir="./clash/ruleset"

get_filelist() {
    for fn in gfw apple google greatfire icloud proxy telegramcidr
    do
        printf "%s/%s.yaml " ${src_dir} $fn
    done
}


## 生成 gfwlist.conf # dnsmasq 服务使用
awk '!/^[a-z]/{
    gsub(/+.|'\''/,"",$2);
    rule[$2] += 1;
}END{
    for( i in rule) {
        printf("%s\n", i) | "sort"
    }
}' $(get_filelist) | awk -v dnsport=${DNS_PORT} '{
    printf("server=/%s/%s#%s\n", $1, "127.0.0.1", dnsport);
    printf("ipset=/%s/%s\n", $1, "gfwlist");
}'

