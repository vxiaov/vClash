# clash项目说明
>~~这个项目仅用于斐讯K3路由器`KS梅林改版380固件`。~~
> 目前此项目支持路由器固件： 支持Koolshare开发的梅林改版、华硕官改版本(380、386)， 可执行程序编译的是`armv5`(大部分ARM平台可用，X86_64平台用不了(废话))。

无论是`梅林改版`还是`华硕官改`固件，实际上主要的差异影响就是`软件中心插件开发的Web界面API接口`。

- 380版本API版本: `v1.0`
- 384/386版本API版本: `v1.5`

理论上，支持了v1.5版本API后，386和384是可以通用的(没验证过`384`版本哦，懒的刷机啦，有`384`版本的朋友可以验证一下，用不了也没啥影响的)。


## 使用满足条件

- CPU架构: Armv7l/Armv7/Armv8 (能运行clash可执行程序)
- 路由器固件： KS梅林改版、KS官改的380/384/386版本固件

## 基本功能

- [x] Clash服务启动开关
- [x] 透明代理启用开关: 选择是否需要使用透明代理(感觉不到自己使用了代理，内网应用不做任何配置即可访问Google)
- [ ] ~~网络状态检查(似乎这个功能有点多余)~~
- [x] 节点配置:支持provider(url)更新配置。
- [x] DNS设置：使用无污染的DNS解析国外域名。

## 新增功能: **解决 URL 订阅源无法直接访问情况**，改为**文件下载更新**方式。

- [x] 支持添加和删除个人代理节点(单独分组：命名为DIY)。
- [x] ~~支持`PROXY`代理组的添加、配置和删除订阅源。~~ 取消URL订阅源方式，改为文件更新方式，更合理安全，避免URL无法访问导致Clash无法启动情况。

> 为了支持 ss/ssr/vmess URI后台解析，新增加了一个`uri_decoder`工具，目的是解析URI并生成新增加节点的yaml文件，最后使用`yq`命令合并两个文件，完成节点添加功能。

## 怎么获取插件安装包？

- 方式一: 通过源码使用方式：
```bash
git clone https://github.com/learnhard-cn/clash.git

# 用于 380版本固件 ：使用 main 分支
cd clash && git checkout main && cd ../
tar zcvf clash.tar.gz clash/bin  clash/clash  clash/images  clash/install.sh  clash/res  clash/scripts  clash/uninstall.sh  clash/version  clash/webs


# 用于 384/386 版本固件 ：使用 ksmerlin386 分支
cd clash && git checkout ksmerlin386 && cd ../
tar zcvf clash.tar.gz clash/bin  clash/clash  clash/images  clash/install.sh  clash/res  clash/scripts  clash/uninstall.sh  clash/version  clash/webs clash/.valid

```

- 方式二： 通过Release包下载获取


| 适用于**380**固件| 适用于**384/386**固件|
|:-------|:--------|
| [clash插件下载地址](https://github.com/learnhard-cn/clash/releases/tag/latest380) | [clash插件下载地址](https://github.com/learnhard-cn/clash/releases/tag/latest386)


选择最新版本下载到本地，文件名命名为： `clash.tar.gz` 。

## 如何离线安装

### 先关闭离线安装敏感词检测


**离线安装**时，非法关键词检测是在`ks_tar_install.sh`脚本中设置的，检测关键词信息如下：
```sh
    local ILLEGAL_KEYWORDS="ss|ssr|shadowsocks|shadowsocksr|v2ray|trojan|clash|wireguard|koolss|brook|fuck"
```

屏蔽它的方法就是将关键词替换个无意义的词，例如"xxxxxxxxx"。

接下来，我们就来实现这个操作，在路由器控制台终端执行如下命令：
```sh

# 先检查关键词变量是否存在
grep ILLEGAL_KEYWORDS /koolshare/scripts/ks_tar_install.sh

# 替换掉非法关键词信息
sed -i 's/local ILLEGAL_KEYWORDS=.*/local ILLEGAL_KEYWORDS="xxxxxxxxxxxxxxxxxxx"/g' /koolshare/scripts/ks_tar_install.sh

```

就这样，以后可以通过离线上传安装了。
这样就可以正确的安装了。


安装成功后，即可在`软件中心`里看到`clash`插件了。



## 为什么有这个项目

~~由于种种原因，某些路由器的固件停留在了`梅林380改版`，但是现在很多插件开发都不再支持`梅林380改版`了，例如`Clash`没有找到一个支持版本。因此，就产生了这个项目。~~

本来之打算支持`380固件`的，但是写着写着，就支持了梅林`380/384/386`改版固件。

希望可以帮助到你吧！

## 主界面

![](https://raw.githubusercontent.com/learnhard-cn/clash/main/images/demo.png)

