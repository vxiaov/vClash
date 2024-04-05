#!/bin/sh
# 挂载虚拟内存开启脚本

res="失败"

swapfile=/dev/sda1
filename=`basename $0`
i=1
while [ "$i" -le "10" ] ;
do
        ls $swapfile
        if [ "$?" = "0" ] ; then
                logger -st "$(date +'%Y年%m月%d日%H:%M:%S'):$filename"  "$swapfile 已准备好!"
                break
        fi
        logger -st "$(date +'%Y年%m月%d日%H:%M:%S'):$filename" "$swapfile 没找到!"
        i=`expr $i + 1`
        sleep 1
done

/sbin/swapon $swapfile

[ "$?" = "0" ] && res="成功"
logger -st "$(date +'%Y年%m月%d日%H:%M:%S'):$filename" "挂载虚拟内存: ${res}"
