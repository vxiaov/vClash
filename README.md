<h1 align="center">
  <img src="https://raw.githubusercontent.com/vxiaov/vclash/main/clash/res/icon-clash.png" alt="vClash" width="200">
  <br>vClash科学上网插件<br>
</h1>

# vClash项目说明
>这个项目插件适用于`Koolshare的华硕官改、梅林改版 380/384/386固件`。~~会不会有openwrt版本呢？有时间再考虑吧~~，还有一个**Openwrt**版本，不过是运行在X86_64架构上并且是支持Koolshare的固件才能运行，有想尝试的可以访问这个项目[Koolshare-Clash-openwrt-amd64](https://github.com/vxiaov/Koolshare-Clash-openwrt-amd64)，内置了启动配置文件(安装即用!)


## 获取安装包

| Github分支    | 支持Koolshare路由器固件版本 | Github下载链接                                                                                                                                                                        | 国内CDN下载链接                                                                                             |
| ----------- | ------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------- |
| main        | 华硕380版本(停止更新)            | [Github安装包](https://github.com/vxiaov/vClash/raw/main/release/clash.tar.gz)                     | [CDN安装包](https://cdn.jsdelivr.net/gh/vxiaov/vClash@main/release/clash.tar.gz)              |
| ksmerlin386 | 华硕官改、梅林386版本(持续更新)       | [Github安装包](https://github.com/vxiaov/vClash/raw/ksmerlin386/release/clash.tar.gz) | [CDN安装包](https://cdn.jsdelivr.net/gh/vxiaov/vClash@ksmerlin386/release/clash.tar.gz) |


## 功能

- <b style="color:red">安装即用</b>: 只需要更新内部提供的 **代理节点订阅源**即可使用。
- <b style="color:red">支持个人节点添加</b>: 支持ss/ssr/vmess链接、http链接订阅源。
- <b style="color:red">配置两级中继代理组</b>: Clash启动配置文件配置了两级中继代理组，<b style="color:red">免费解锁奈飞</b>变得更加容易了。
- <b style="color:red">支持Cloudflare的DDNS功能</b>: 支持<b style="color:red">同时更新同一个帐号下的多个域名</b>，例如 CF帐号下有两个域名 a.com和 b.com, 可以配置 "home.a.com,home.b.com" 两个域名之间用逗号分隔。
- <b style="color:red">支持在线编辑配置文件</b>: 修改配置文件可以在插件页面上完成。
- <b style="color:red">Clash-Premium可用的配置文件</b>： https://raw.githubusercontent.com/vxiaov/vClash/ksmerlin386/clash/clash/config.yaml

## 说明

1. 如果你的 /koolshare目录所在分区使用的是 jffs2 文件系统类型，推荐你使用`v2.3.0`之前的版本，原因可以在WIKI文档中看到。
2. 最新版本将会一直保持与 Clash Premium最新版一致，省去了自己手动更新的问题。
3. 20240403更新(告别软路由的高功耗100W+，回归自己的小路由插件10W功耗太省电了)：去掉了uri解码功能（添加节点直接编辑yaml文件)，取消clash内核版本检查功能(有能力就自己更新吧，历史版本链接本插件wiki能找到）， 更宽松的yaml配置文件检查（意味着更为通用的yaml配置规则定制，近自动修改yacdUI控制参数，提供更大的DIY能力）。

> 注释：一些使用者反馈了使用问题，主要都是不规范的URI格式解析问题，这的确是个头疼问题，代码越写越乱，干脆放弃这个功能，以后**添加节点通过直接修改yaml格式文件**，至于**订阅机场**更新可以修改启动配置文件增加HTTP类型proxy_provider来实现(如自带配置就是此方法实现）添加yaml格式订阅源，关于配置节点个人建议是**尽量不要在启动配置文件的proxies下面配置节点，因为会导致下面使用时配置很乱，难管理；建议做法：使用proxy_provider订阅源管理（file或http类型)**。


## 主界面

![](./images/demo.gif)


## 问题反馈

开发过程的实测路由器型号不多，一些小问题还在不断完善，如果希望本项目可以使用到自己的路由器上，有两个方法：

1. **提交issue**: 详细描述或截图出现的问题提交个issue，不要吝惜文字，描述的越详细越容易得到帮助(聊聊几个字俺也很无可奈何)。
2. **Fork本项目**: 自己有开发能力，把问题解决，分享修改代码内容给这个项目，让你的问题不再出现，也让这个插件可以更稳定。

## 相关项目

- [Clash项目，二进制文件下载源](https://github.com/Dreamacro/clash)
- [Clash的Web管理，用于Select类型代理组节点切换管理](https://github.com/haishanh/yacd)
- [优化Country.mmdb大小的GeoIP2-CN项目](https://github.com/Hackl0us/GeoIP2-CN)
- [yq项目，合并yaml格式文件](https://github.com/mikefarah/yq)
- [jq项目,Cloudflare的DDNS功能使用](https://github.com/stedolan/jq)
- ~~[urldecoder项目,一个解析ss/ssr/vmess链接小工具](https://github.com/vxiaov/uridecoder)~~


That's it! The open source project！
