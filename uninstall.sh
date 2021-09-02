#! /bin/sh

#########################################################
# Clash script for AM380 merlin firmware
# Writen by Awkee (next4nextjob(at)gmail.com) 
# Website: https://vlike.work
#########################################################

app_name="clash"

sh /koolshare/scripts/${app_name}_control.sh stop

# 清理文件目录
bin_list="${app_name} dns2socks5 yq"

# 清理旧文件，升级情况需要
remove_files() {
    LOGGER 清理旧文件
    rm -rf /koolshare/${app_name}
    rm -rf /koolshare/scripts/${app_name}_*
    rm -rf /koolshare/webs/Module_${app_name}.asp
    for fn in ${bin_list}
    do
        rm -f /koolshare/bin/${fn}
    done
    rm -rf /koolshare/res/icon-${app_name}.png
    rm -rf /koolshare/res/${app_name}_*
    rm -rf /koolshare/init.d/S??${app_name}.sh
}


remove_env() {
    # 清理环境变量, 相当于清理数据库，避免无意义数据遗留在数据库中
    dbus remove softcenter_module_${app_name}_home_url
    dbus remove softcenter_module_${app_name}_install
    dbus remove softcenter_module_${app_name}_title
    dbus remove softcenter_module_${app_name}_version

    dbus remove ${app_name}_enable
    dbus remove ${app_name}_action
    dbus remove ${app_name}_trans
    dbus remove ${app_name}_version
}
