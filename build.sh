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
    `basename $0` pack <version>  # 打包指定版本安装包
    `basename $0` yaml    # 精简yaml文件
    `basename $0` yaml0   # 输出完整的yaml文件
    `basename $0` generate_tglist  # 生成TG规则集

 Params:
    version : new version number , v2.2.4
END
}

# 生成最新版本Clash安装包 #
if [ "$1" = "" ] ; then
    usage
    exit
fi

generate_tglist() {
    outfile="./clash/clash/ruleset/rule_diy_tg.yaml"
    tmpfile="./tglist.tmp"
    rm -f "$tmpfile"

    for domain_name in comments.app contest.com graph.org quiz.directory t.me tdesktop.com telega.one telegra.ph telegram.dog telegram.me telegram.org telegram.space telesco.pe tg.dev tx.me usercontent.dev
    do
        echo "$domain_name" >> ${tmpfile}
    done
    curl -s https://core.telegram.org/resources/cidr.txt  >> ${tmpfile}
    if [ "$?" != "0" ] ; then
        echo "Error:获取 Telegram CIDR 文件失败啦!"
        rm -f ${tmpfile}
        return 1
    fi
    # 生成 ruleset
    awk 'BEGIN{ printf("payload:\n  # Telegram\n") }
      /^[a-z]/{ printf("  - DOMAIN-SUFFIX,%s\n", $0) }
     /[0-9]\./{ printf("  - IP-CIDR,%s\n", $0)}
           /:/{ printf("  - IP-CIDR6,%s\n", $0)}' ${tmpfile}  > ${outfile}
    rm -f ${tmpfile}
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

generate_direct() {
    # 生成direct.yaml #
    filter_flag="${1:-0}"
    outdir="./clash/clash/ruleset/"
    curl -s https://cdn.jsdelivr.net/gh/Loyalsoldier/clash-rules@release/direct.txt > ${outdir}/direct.tmp
    if [ "$filter_flag" = "1" ] ; then
        # 精简过滤一些地址
        yq e '.payload[]' ${outdir}/direct.tmp | awk -F'.' 'BEGIN{
            printf("payload:\n");
        }$NF~/org|com|cn|net|edu|gov/ && $(NF-1)!~/[a-z][0-9]/ && $(NF-1)~/qiniu|baidu|cloudflare|upyun|cachemoment|163|265|360|tecent|qq|cdn|verycloud|ali/ {
            idx=$(NF-1)"."$(NF);
            a[idx]++;
        }END{
            for(i in a)
                printf("  - '\''+.%s'\''\n", i);
        }' > ${outdir}/rule_diy_direct.yaml
    else
        yq e -P ${outdir}/direct.tmp > ${outdir}/rule_diy_direct.yaml
    fi
    rm -f ${outdir}/direct.tmp
    echo "rule_diy_direct.yaml 生成完毕."
}

generate_package() {
    # 生成release安装包
    echo "正在生成 release 安装包 ..."
    outdir="./release/"
    new_version="$1"
    sed -i "s/vClash:.*/vClash:$new_version/" clash/clash/version
    echo -n "arm384" > clash/.valid
    tar zcf ./release/clash_384.tar.gz clash/
    echo -n "hnd|arm384|arm386|p1axhnd.675x" > clash/.valid
    tar zcf ./release/clash.tar.gz clash/
}


case "$1" in
    generate_*)
        $1
        ;;
    pack)
        generate_package $2
        git add ./
        git commit -m "docs: 提交$2版本离线包"
        git tag $2
        work_branch="$(git branch --show-current)"
        git checkout ksmerlin386
        git merge ${work_branch}
        git push --set-upstream origin ksmerlin386 --tag        
        ;;
    yaml)
        generate_gfwlist 1
        generate_direct  1
        ;;
    yaml0)
        generate_gfwlist
        generate_direct
        ;;
    *)
        usage
        ;;
esac
