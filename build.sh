#!/bin/bash
########################################################################
# File Name: build.sh
# Author: zioer
# mail: next4nextjob@gmail.com
# Created Time: 2022年01月02日 星期日 23时06分29秒
########################################################################

usage() {
    cat <<END
 Usage:
    `basename $0` <version>
 Params:
    version : new version number , v2.2.4
END
}
# 生成最新版本Clash安装包 #
if [ "$1" = "" ] ; then
    usage
    exit
fi
new_version="$1"

sed -i "s/vClash:.*/vClash:$new_version/" clash/clash/version

tar zcf ./release/clash.tar.gz clash/
