#!/bin/sh

KSHOME="/koolshare"
app_name="clash"

source ${KSHOME}/scripts/base.sh

LOG_FILE="/tmp/clash_proc_status.log"
LOG() {
    echo "$@" >> $LOG_FILE
}
echo "检查进程信息：" > $LOG_FILE

LOG "---------------------------------------"
LOG "进程-clash     : " `pidof $app_name`
LOG "进程-dns2socks5: " `pidof dns2socks5`
LOG "进程-dnsmasq   : " `pidof dnsmasq`
LOG "---------------------------------------"
LOG "XU6J03M6"

