#!/bin/sh
# 挂载Clash分区开启脚本

# 使用前准备：
#   1. 创建分区 /dev/sda2 , 文件系统类型推荐 ext3
#   2. 先拷贝 /koolshare/clash 内部文件到 /dev/sda2 分区中
#   3. 拷贝完成后，手动挂载 /dev/sda2 到 /koolshare/clash
#   4. 为了以后自动化，请将此脚本拷贝到 /koolshare/init.d/ 目录下.

# 文件名说明
# 1. 脚本会在路由器启动时执行比较早，挂载分区可能失败，因此循环尝试10次挂载。
# 2. S02的数字是执行顺序，数值越大，执行顺序越晚。


res="失败"

mnt_path=/koolshare/clash
dst_path=/dev/sda2
filename=`basename $0`
i=1
while [ "$i" -le "10" ] ;
do
        ls $mnt_path
        if [ "$?" = "0" ] ; then
                logger -st "$(date +'%Y年%m月%d日%H:%M:%S'):$filename"  "$dst_path 已准备好!"
                break
        fi
        logger -st "$(date +'%Y年%m月%d日%H:%M:%S'):$filename" "$dst_path 没找到!"
        i=`expr $i + 1`
        sleep 1
done

j=1
while [ "$j" -le "4" ] ; do
	mount $dst_path $mnt_path
	[ "$?" = "0" ] && res="成功"
	logger -st "$(date +'%Y年%m月%d日%H:%M:%S'):$filename" "挂载Clash分区: ${res}"
	j=`expr $j + 1`
	sleep 1
done

