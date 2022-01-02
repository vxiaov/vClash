# clash项目说明
> 目前此项目支持路由器固件： 支持Koolshare开发的梅林改版、华硕官改版本(380、386)， 可执行程序编译的是`armv5`(大部分ARM平台可用，X86_64平台用不了(废话))。

无论是`梅林改版`还是`华硕官改`固件，实际上主要的差异影响就是`软件中心插件开发的Web界面API接口`。

- 380版本API版本: `v1.0`
- 384/386版本API版本: `v1.5`

理论上，支持了v1.5版本API后，386和384是可以通用的(没验证过`384`版本哦，懒的刷机啦，有`384`版本的朋友可以验证一下，用不了也没啥影响的)。


## 使用满足条件

- CPU架构: Armv7l/Armv7/Armv8 (能运行clash可执行程序)
- 路由器固件： KS梅林改版、KS官改的380/384/386版本固件


## 功能特点介绍

- <b style="color:red">安装即用</b>，只需要更新内部提供的`代理节点订阅源`即可使用(即不需要自己搭建梯子就能用)。
- Clash启动配置文件规划好了两级、三级中继代理组，<b style="color:red">免费解锁奈</b>飞变得更加容易了。
- 内置Cloudflare的DDNS功能，支持<b style="color:red">同时更新多个域名</b>。

## 使用前说明
> 由于GoLang版本Clash启动时分配内存空间较大，对于小内存路由器最容易出现**启动失败问题**,以`RT-AC86U`为例，启动时分配虚拟内存(VIRT)有600-700MB左右，对于512MB物理内存路由器直接起不来。

启动失败问题解决：

1. 挂载虚拟内存: 支持**USB接口路由器**可以插入一个1GB以上的优盘作为虚拟内存挂载，可以使用路由器自带了虚拟内存插件。[阅读挂载虚拟内存教程文章](https://vlike.work/VPS/router-mount-swap.html)。



## 怎么获取插件安装包？

| Github分支    | 支持Koolshare路由器固件版本 | Github下载链接                                                                                                                                                                        | 国内CDN下载链接                                                                                             |
| ----------- | ------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------- |
| main        | 华硕380版本(停止更新)            | [斐迅K3梅林380版本](https://github.com/learnhard-cn/vClash/raw/main/release/clash.tar.gz)                     | [斐迅K3梅林380版本](https://cdn.jsdelivr.net/gh/learnhard-cn/vClash@main/release/clash.tar.gz)              |
| ksmerlin386 | 华硕官改、梅林386版本(持续更新)       | [华硕RT-AC86U梅林386版本](https://github.com/learnhard-cn/vClash/raw/ksmerlin386/release/clash.tar.gz) | [华硕RT-AC86U梅林386版本](https://cdn.jsdelivr.net/gh/learnhard-cn/vClash@ksmerlin386/release/clash.tar.gz) |



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

本来只打算支持`380固件`的，但是写着写着，就支持了梅林`380/384/386`改版固件。

希望可以帮助到你吧！

## 主界面

![](https://raw.githubusercontent.com/learnhard-cn/clash/main/images/demo.png)

