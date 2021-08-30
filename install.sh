#! /bin/sh

# shadowsocks script for AM380 merlin firmware
# by sadog (sadoneli@gmail.com) from koolshare.cn

app_name="clash"
eval `dbus export $app_name`
alias echo_date='echo 【$(TZ=UTC-8 date -R +%Y年%m月%d日\ %X)】:'



# 如果已经安装过并且启用了,先停掉它
enable=`dbus get ${app_name}_enable`
if [ "$enable" == "1" ];then
	sh /koolshare/scripts/${app_name}_control.sh stop
fi

mkdir -p /koolshare/${app_name}
mkdir -p /tmp/${app_name}_backup

# 判断路由架构和平台
case $(uname -m) in
	armv7l)
		echo_date 固件平台【koolshare merlin armv7l】符合安装要求，开始安装插件！
	;;
	*)
		echo_date 本插件适用于koolshare merlin armv7l固件平台，你的平台"$(uname -m)"不能安装！！！
		echo_date 退出安装！
		exit 1
	;;
esac

# 低于7.2的固件不能安装
firmware_version=`nvram get extendno|cut -d "X" -f2|cut -d "-" -f1|cut -d "_" -f1`
firmware_comp=`versioncmp $firmware_version 7.2`
if [ "$firmware_comp" == "1" ];then
	echo_date 本插件不支持X7.2以下的固件版本，当前固件版本$firmware_version，请更新固件！
	echo_date 退出安装！
	exit 1
fi


echo_date 清理旧文件

rm -rf /koolshare/${app_name}
rm -rf /koolshare/scripts/${app_name}_*
rm -rf /koolshare/webs/Module_${app_name}.asp
rm -rf /koolshare/bin/${app_name}
rm -rf /koolshare/res/icon-${app_name}.png
rm -rf /koolshare/res/${app_name}_*
rm -rf /koolshare/init.d/S??${app_name}.sh


# ================================== INSTALL_START 开始安装 =========================
echo_date 开始复制文件！
cd /tmp/${app_name}/

echo_date 复制相关二进制文件！此步时间可能较长！
cp -rf ./bin/${app_name} /koolshare/bin/
cp -rf ./bin/dns2socks5 /koolshare/bin/
chmod 755 /koolshare/bin/${app_name}
chmod 755 /koolshare/bin/dns2socks5

echo_date 复制相关的脚本文件！

cp -rf ./${app_name}/  /koolshare/
cp -f ./scripts/${app_name}_*.sh /koolshare/scripts/
cp -f ./uninstall.sh /koolshare/scripts/${app_name}_uninstall.sh

chmod 755 /koolshare/scripts/${app_name}_*.sh


echo_date 复制相关的网页文件！
cp -rf ./webs/Module_${app_name}.asp /koolshare/webs/
cp -rf ./res/${app_name}_*  /koolshare/res/
cp -rf ./res/icon-${app_name}.png  /koolshare/res/



echo_date 添加自启动脚本软链接
[ ! -L "/koolshare/init.d/S90${app_name}.sh" ] && ln -sf /koolshare/scripts/${app_name}_control.sh /koolshare/init.d/S99${app_name}.sh


echo_date 设置一些默认值
# 默认不启用
[ -z "`eval echo '$'${app_name}_enable`" ] && dbus set ${app_name}_enable=0


# 移除一些没用的值
dbus remove ${app_name}_version

# 离线安装时设置软件中心内储存的版本号和连接
CUR_VERSION=`cat /koolshare/${app_name}/version`
dbus set ${app_name}_version="$CUR_VERSION"
dbus set softcenter_module_${app_name}_install="1"
dbus set softcenter_module_${app_name}_version="$CUR_VERSION"
dbus set softcenter_module_${app_name}_title="Clash版科学上网"
dbus set softcenter_module_${app_name}_description="Clash版科学上网 for merlin armv7l 380"
dbus set softcenter_module_${app_name}_home_url="Module_${app_name}.asp"


echo_date Clash版科学上网插件安装成功！

if [ "`eval echo '$'$app_name}_enable`" == "1" ];then
    echo_date 重启科学上网插件！
	sh /koolshare/scripts/${app_name}_control.sh restart
	echo_date 更新完毕，请等待网页自动刷新！
fi

echo_date 移除安装包！
cd /tmp
rm -rf /tmp/${app_name} >/dev/null 2>&1
