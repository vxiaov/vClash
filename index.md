# clash项目说明
>这个项目仅用于斐讯K3路由器`KS梅林改版380固件`。

## 使用满足条件

- CPU架构: Armv7l (能运行clash可执行程序)
- 路由器固件： KS梅林改版380固件

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

由于种种原因，某些路由器的固件停留在了`梅林380改版`，但是现在很多插件开发都不再支持`梅林380改版`了，例如`Clash`没有找到一个支持版本。

因此，就产生了这个项目。

## 主界面

![](https://github.com/learnhard-cn/clash/blob/main/images/demo.png)

