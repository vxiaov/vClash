<h1 align="center">
  <img src="https://github.com/learnhard-cn/clash/raw/main/clash/res/icon-clash.png" alt="Clash" width="200">
  <br>vClash科学上网插件<br>
</h1>

# vClash项目说明
>这个项目插件适用于`Koolshare的华硕官改、梅林改版 380/384/386固件`。~~会不会有openwrt版本呢？有时间再考虑吧~~，还有一个**Openwrt**版本，不过是运行在X86_64架构上并且是支持Koolshare的固件才能运行，有想尝试的可以访问这个项目[Koolshare-Clash-openwrt-amd64](https://github.com/learnhard-cn/Koolshare-Clash-openwrt-amd64)，内置了启动配置文件(安装即用!)


## 获取安装包

| Github分支    | 支持Koolshare路由器固件版本 | Github下载链接                                                                                                                                                                        | 国内CDN下载链接                                                                                             |
| ----------- | ------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------- |
| main        | 华硕380版本(停止更新)            | [Github安装包](https://github.com/learnhard-cn/vClash/raw/main/release/clash.tar.gz)                     | [CDN安装包](https://cdn.jsdelivr.net/gh/learnhard-cn/vClash@main/release/clash.tar.gz)              |
| ksmerlin386 | 华硕官改、梅林386版本(持续更新)       | [Github安装包](https://github.com/learnhard-cn/vClash/raw/ksmerlin386/release/clash.tar.gz) | [CDN安装包](https://cdn.jsdelivr.net/gh/learnhard-cn/vClash@ksmerlin386/release/clash.tar.gz) |


## 功能

- <b style="color:red">安装即用</b>: 只需要更新内部提供的 **代理节点订阅源**即可使用。
- <b style="color:red">支持个人节点添加</b>: 支持ss/ssr/vmess链接、http链接订阅源。
- <b style="color:red">配置两级中继代理组</b>: Clash启动配置文件配置了两级中继代理组，<b style="color:red">免费解锁奈飞</b>变得更加容易了。
- <b style="color:red">支持Cloudflare的DDNS功能</b>: 支持<b style="color:red">同时更新同一个帐号下的多个域名</b>，例如 CF帐号下有两个域名 a.com和 b.com, 可以配置 "home.a.com,home.b.com" 两个域名之间用逗号分隔。
- <b style="color:red">支持在线编辑配置文件</b>: 修改配置文件可以在插件页面上完成。



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
- [urldecoder项目,一个解析ss/ssr/vmess链接小工具](https://github.com/learnhard-cn/uridecoder)


That's it! The open source project！
