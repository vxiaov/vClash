<h1 align="center">
  <img src="https://github.com/learnhard-cn/clash/raw/main/clash/res/icon-clash.png" alt="Clash" width="200">
  <br>vClash科学上网插件<br>
</h1>

# vClash项目说明
>这个项目插件适用于`Koolshare的华硕官改、梅林改版 380/384/386固件`。会不会有openwrt版本呢？有时间再考虑吧。


| Github分支    | 支持Koolshare路由器固件版本 | Github下载链接                                                                                                                                                                        | 国内CDN下载链接                                                                                             |
| ----------- | ------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------- |
| main        | 华硕380版本(停止更新)            | [斐迅K3梅林380版本](https://github.com/learnhard-cn/vClash/raw/main/release/clash.tar.gz)                     | [斐迅K3梅林380版本](https://cdn.jsdelivr.net/gh/learnhard-cn/vClash@main/release/clash.tar.gz)              |
| ksmerlin386 | 华硕官改、梅林386版本(持续更新)       | [华硕RT-AC86U梅林386版本](https://github.com/learnhard-cn/vClash/raw/ksmerlin386/release/clash.tar.gz) | [华硕RT-AC86U梅林386版本](https://cdn.jsdelivr.net/gh/learnhard-cn/vClash@ksmerlin386/release/clash.tar.gz) |



## 功能特点介绍

- <b style="color:red">安装即用</b>，只需要更新内部提供的`代理节点订阅源`即可使用(即不需要自己搭建梯子就能用)。
- Clash启动配置文件规划好了两级、三级中继代理组，<b style="color:red">免费解锁奈</b>飞变得更加容易了。
- 内置Cloudflare的DDNS功能，支持<b style="color:red">同时更新多个域名</b>。

## 使用前说明
> 由于GoLang版本Clash启动时分配内存空间较大，对于小内存路由器最容易出现**启动失败问题**,以`RT-AC86U`为例，启动时分配虚拟内存(VIRT)有600-700MB左右，对于512MB物理内存路由器直接起不来。

启动失败问题解决：

1. 挂载虚拟内存: 支持**USB接口路由器**可以插入一个1GB以上的优盘作为虚拟内存挂载，可以使用路由器自带了虚拟内存插件。[阅读挂载虚拟内存教程文章](https://vlike.work/VPS/router-mount-swap.html)。



## 为什么有这个项目

最开始为了斐迅K3路由器的`梅林380改版`开发，产生了这个项目。

之后，用着用着就过渡到了`华硕RT-AC86U`的`华硕官改386固件`,进而又开发了支持`386版本`的插件。

但实测路由器型号不多，一些小问题在所难免，如果希望本项目可以使用到自己的路由器上，有两个方法：

1. 详细描述或截图出现的问题提交个issue，回复不一定及时，看到必回。
2. 自己有开发能力，把问题解决，分享修改代码内容给这个项目，让你的问题不再出现，也让这个插件可以更稳定。


## 主界面

![](./images/demo.png)

