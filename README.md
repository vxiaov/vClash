# clash项目说明
>~~这个项目仅用于斐讯K3路由器`KS梅林改版380固件`。~~目前此项目支持路由器固件： 支持Koolshare开发的梅林改版、华硕官改版本(380、386)， 可执行程序编译的是armv5(大部分ARM平台可用，X86_64平台用不了(废话))。

无论是`梅林改版`还是`华硕官改`固件，实际上`主要的差异影响`就是软件中心插件开发的Web界面`API接口`。


## 使用满足条件

- CPU架构: Armv7l/Armv8 (能运行clash可执行程序)
- 路由器固件： KS梅林改版380/384/386固件

## 基本功能

- [x] Clash服务启动开关
- [x] 透明代理启用开关: 选择是否需要使用透明代理(感觉不到自己使用了代理，内网应用不做任何配置即可访问Google)
- [ ] ~~网络状态检查(似乎这个功能有点多余)~~
- [x] 节点配置:支持provider(url)更新配置。
- [x] DNS设置：使用无污染的DNS解析国外域名。
- [x] 支持添加和删除个人代理节点(单独分组：命名为DIY)。
- [x] 更改`URL订阅源`方式为文件下载更新方式，更合理安全，避免URL无法访问导致Clash无法启动情况。

> 为了支持 ss/ssr/vmess URI后台解析，新增加了一个`uri_decoder`工具，目的是解析URI并生成新增加节点的yaml文件，最后使用`yq`命令合并两个文件，完成节点添加功能。

## 订阅规则手动更新
> 增加手动更新 `ruleset`/`Country.mmdb`文件。

- 更新 `ruleset` ： ~~规则集下载~~取消`ruleset`的使用，以`gfwlist.conf`规则作为黑名单规则实现透明代理。
- 更新 `Country.mmdb` ： ~~官方文件下载(需7MB大小)~~为节省内存，使用了仅包含国内IP地址和私有IP地址的[Country.mmdb数据文件](https://cdn.jsdelivr.net/gh/Hackl0us/GeoIP2-CN@release/Country.mmdb)(仅200KB左右大小)。

## 怎么使用？

```bash
git clone https://github.com/learnhard-cn/clash.git
rm -tr clash/.git
tar zcvf clash.tar.gz clash
```

或者， 到`Release`页面下载安装包 [https://github.com/learnhard-cn/clash/releases/latest](https://github.com/learnhard-cn/clash/releases/latest)

选择最新版本下载到本地，重命名为： `clash.tar.gz` 。

接下来就可以将这个安装包通过SSH传输到路由器上的`/tmp/`目录上，执行如下命令进行手动安装：

```bash
cd /tmp
tar zxvf clash.tar.gz
sh clash/install.sh
```
安装成功后，即可在`软件中心`里看到`clash`插件了。



## 为什么有这个项目

~~由于种种原因，某些路由器的固件停留在了`梅林380改版`，但是现在很多插件开发都不再支持`梅林380改版`了，例如`Clash`没有找到一个支持版本。~~

本来只打算支持`380固件`的，但是写着写着，就支持了梅林`380/384/386`改版固件实现了`Koolshare`两个版本的软件中心API。

希望可以帮助到你吧！

## 相关项目

- [Clash项目，二进制文件下载源](https://github.com/Dreamacro/clash)
- [Clash的Web管理，用于Select类型代理组节点切换管理](https://github.com/haishanh/yacd)
- [优化Country.mmdb大小的GeoIP2-CN项目](https://github.com/Hackl0us/GeoIP2-CN)
- [yq项目，合并yaml格式文件](https://github.com/mikefarah/yq)

That's it! The open source project！


## 主界面

![](./images/demo.png)


