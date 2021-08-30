#! /bin/sh

#########################################################
# Clash script for AM380 merlin firmware
# Writen by Awkee (next4nextjob(at)gmail.com) 
# Website: https://vlike.work
#########################################################

app_name="clash"

sh /koolshare/scripts/${app_name}_control.sh stop

# 清理文件目录
rm -rf /koolshare/${app_name}
rm -f /koolshare/scripts/${app_name}_*
rm -f /koolshare/webs/Module_${app_name}.asp
rm -f /koolshare/bin/${app_name}
rm -f /koolshare/bin/dns2socks5
rm -f /koolshare/res/${app_name}_*
rm -f /koolshare/res/icon-${app_name}.png
rm -f /koolshare/init.d/S??${app_name}.sh


# 清理环境变量
dbus remove softcenter_module_${app_name}_home_url
dbus remove softcenter_module_${app_name}_install
dbus remove softcenter_module_${app_name}_md5
dbus remove softcenter_module_${app_name}_version

dbus remove ${app_name}_enable
dbus remove ${app_name}_action
dbus remove ${app_name}_version
