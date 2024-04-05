# vClash说明
> vClash插件的安装、开发过程说明。

## 001.如何使用vClash
> 安装vClash方法以及安装过程遇到问题怎么解决。

### 001.安装vClash
最新版本安装包存放到release目录中，对应下载链接:


| Github分支    | 支持Koolshare路由器固件版本 | Github下载链接                                                                                                                                                                        | 国内CDN下载链接                                                                                             |
| ----------- | ------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------- |
| main        | 华硕380版本(停止更新)            | [斐迅K3梅林380版本](https://github.com/vxiaov/vClash/raw/main/release/clash.tar.gz)                     | [斐迅K3梅林380版本](https://cdn.jsdelivr.net/gh/vxiaov/vClash@main/release/clash.tar.gz)              |
| ksmerlin386(默认主分支) | 华硕官改、梅林386版本(持续更新)       | [梅林386版本](https://github.com/vxiaov/vClash/raw/ksmerlin386/release/clash.tar.gz) | [梅林386版本](https://cdn.jsdelivr.net/gh/vxiaov/vClash@ksmerlin386/release/clash.tar.gz) |


路由器插件的安装方法使用 **“离线安装”**，安装前遇到**非法关键词检测**问题可以看下面解决方法。

#### 001.离线安装非法关键词检测不通过怎么办？这样解决。


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

#### 002.clash启动失败问题
> 由于GoLang版本Clash启动时分配内存空间较大，对于小内存(512MB及以下)路由器会出现**启动失败问题**,以`RT-AC86U`为例，启动时分配虚拟内存(VIRT)有600-700MB左右(实际内存使用在30-80MB左右)，对于512MB物理内存路由器直接起不来。

**解决方法**

1. 挂载虚拟内存: 支持**USB接口路由器**可以插入一个1GB以上的优盘作为虚拟内存挂载，可以使用路由器自带了虚拟内存插件。[阅读挂载虚拟内存教程文章](https://vlike.work/VPS/router-mount-swap.html)。


### 002.配置vClash-代理订阅源
> vClash实际上安装后即可启动使用，因为配置文件已经内置了，但没有代理节点启动了网络也是有问题的。因此，还是需要 **添加自己的代理节点** 或者更新一下 **订阅源** 才可以。

添加代理节点:

1. 有自己的代理节点： 在 **节点管理**页面添加即可，注意格式是base64链接格式
2. 有机场订阅源HTTP链接: 推荐 在**节点管理**页面中添加，也可以在 **订阅管理**中添加订阅源URL地址，两者更新的代理节点区别是:添加的代理组不一样，使用的命令不一样，前者使用uri_decoder,或者使用curl。
3. 网上找的免费订阅源HTTP链接: 因为这种免费HTTP订阅源不稳定，推荐在**订阅管理**中添加，而**节点管理**适合保存自己私人的订阅源。

### 003.配置vClash-黑名单白名单规则

配置rule规则前提： [阅读clash官网rule订阅规则配置方法](https://github.com/Dreamacro/clash/wiki/premium-core-features#rule-providers)

阅读了解配置规则后，在 **在线编辑**页面中可以找到如下几个文件:

- ./ruleset/rule_diy_blacklist.yaml : 自定义的黑名单规则，这里的规则将会走代理节点。
- ./ruleset/rule_diy_whitelist.yaml : 自定义的白名单规则，这里的规则将会直连。

上面两个配置文件规则实现在 **./ruleset/rule_basic.yaml**中定义，内容如下:

```yaml
  - RULE-SET,whitelist_rules,DIRECT
  - RULE-SET,blacklist_rules,默认代理组
```

如果你又别的想法，也可以自己修改 **./ruleset/rule_basic.yaml**文件实现。

### 004.在线编辑页面使用说明

**在线编辑**页面提供了编辑文件的功能，类似一个简易的编辑器，没有任何按钮，编辑过程通过下面几个快捷键实现:

1. 编辑文件 : ctrl+e
2. 保存文件 : ctrl+s
3. 重载文件 : ctrl+r
4. 复制选中 : ctrl+c
5. 粘帖内容 : ctrl+v
6. 撤销操作 : ctrl+z
7. 重做操作 : ctrl+shift+z
8. 全选内容 : ctrl+a

这几个快捷键已经足够编辑文件使用了。

如果编辑文件没保存就点击其他页面时会提示是否保存编辑内容，不会担心忘记保存而丢失配置情况了。

### 005.是否升级新版本clash?使用Clash版本建议

如果你使用最新版本的Clash程序发现不正常(例如：每次重启后都需要设置节点信息，无法保存select模式节点信息)，那么建议你更换到[Clash Premium 2021.09.15 版本](https://github.com/vlikev/clash_binary/tree/f3c4db627f8d091682dc26d5bfe5efd7ad93a8f4/premium/)。

为什么呢？

可以从代码里看到， Clash 这个版本是使用文件方式保存节点选择信息，保存信息目的是为了重启clash后可以不用重新手工设置节点选择信息，但下一个版本`2021.11.08(对应v1.8.0)版本`就更换为名为`cache.db`文件保存信息(代码里是使用了第三方k/v库`bbolt`,但在一些arm系列路由器里无法正常工作)，原因在于/jffs文件系统类型jffs2不支持 **mmap**导致。

如果你使用的不是jffs2类型文件系统，比如自己动手改成了 **ext4**类型文件系统，可以更新到最新版本。

### 006.关于内存使用率问题-clash不能被黑锅

**clash内存占用太大怎么办？**

什么情况算是占用内存过大呢？ 还是需要举个例子:

以 512MB 内存的路由器来说，使用 **白名单模式**启动时占用内存 **68MB**, 其中包含了国内的 **direct.yaml**规则文件(文件大小约1.3MB)，用了一段时间后，clash内存使用情况增长到了 **158MB** ，此时可能就有问题了。

这个问题要分情况来说：

- 情况一:DNS配置错误导致,配置过多DNS也没好处，比如谷歌的DoH和DoT无法使用，所以发送的DNS请求无应答(状态是SYN_SENT),解决方法是**删掉无效的DNS**,例如下面情况:

        lsof -p 11833| grep -i syn
        clash   11833 root   56u     inet 33184179      0t0      TCP you-public-ip:41808->8.8.8.8:853 (SYN_SENT)
        clash   11833 root   59u     inet 33184180      0t0      TCP you-public-ip:37848->1.1.1.1:853 (SYN_SENT)
        clash   11833 root   60u     inet 33184181      0t0      TCP you-public-ip:58164->8.8.8.8:https (SYN_SENT)

- 情况二:使用规则文件过大导致, 网上分享的某些规则集文件非常大，加载到内存中会导致占用内存空间增大，这种情况就只能通过**精简rule规则文件**来达到 **减少内存占用**效果。



## 002.开发知识

由于开发插件过程想法和需求总是在变化，所以新版本可能会去掉了以前不需要或者冗余的一些功能，而且实现的逻辑也在更新，以达到最简便快捷的实现方式。

如果你打算开发一个自己的插件，多阅读一些插件的代码对你非常有帮助的。


### 001.vClash插件基本目录结构

下面是vClash源码的目录结构:

```text
./clash
├── bin
│   ├── clash_for_armv5
│   ├── clash_for_armv8
│   ├── jq_for_armv5
│   ├── jq_for_armv8 -> jq_for_armv5
│   ├── uri_decoder_for_armv5
│   ├── uri_decoder_for_armv8 -> uri_decoder_for_armv5
│   ├── yq_for_armv5
│   └── yq_for_armv8 -> yq_for_armv5
├── clash
│   ├── config.yaml
│   ├── Country.mmdb
│   ├── dashboard
│   ├── providers
│   ├── ruleset
│   └── version
├── install.sh
├── res
│   ├── clash_style.css
│   └── icon-clash.png
├── scripts
│   └── clash_control.sh
├── uninstall.sh
└── webs
    └── Module_clash.asp
```

### 002.vClash功能说明

看到上面的目录结构后，只有一个功能脚本 **clash_control.sh**文件，这是大部分插件的基本样子了，具体有什么功能都是通过将参数传递给clash_control.sh来决定。

- clash_control.sh : 所有的功能都集成在这个脚本中，根据传入参数不同调用不同功能。
- Module_clash.asp : 插件的Web前端UI界面，就是浏览器中看到的样子，都是在这里配置的。
- install.sh/uninstall.sh: 只在插件离线安装和卸载时调用，初始化和清理与vClash插件相关内容用。
- clash : 这个目录包含Clash运行的基础配置信息，启动配置config.yaml, Country.mmdb包含IP数据， dashboard包含Yacd前端，providers包含代理订阅文件，ruleset包含订阅规则文件，version包含插件版本信息，bin包含所有相关的命令工具。
- res   : clash_style.css美化布局在Module_clash.asp页面中的按钮、标签的样式， icon-clash.png就是 vClash的Logo图标。

以上就是vClash包含的内容了。

### 003.实现功能简述



#### v1开头版本为支持KS梅林380版本固件

- [x] Clash服务启动开关
- [x] 透明代理启用开关: 选择是否需要使用透明代理(感觉不到自己使用了代理，内网应用不做任何配置即可访问Google)
- [ ] ~~网络状态检查(似乎这个功能有点多余)~~
- [x] 节点配置:支持provider(url)更新配置。
- [x] DNS设置：使用无污染的DNS解析国外域名。
- [x] 支持添加和删除个人代理节点(单独分组：命名为DIY)。
- [x] 更改URL订阅源方式为下载文件更新方式，更合理安全，避免URL无法访问导致Clash无法启动情况。

> 为了支持 ss/ssr/vmess URI后台解析，个人开发了`GoLang`版本的`uri_decoder`工具，目的是解析URI并生成新增加节点的yaml文件，最后使用`yq`命令合并两个文件，完成节点添加功能。


#### v2开头版本为支持KS梅林384/386版本固件

与v1系列版本差别就是对`Koolshare`软件中心API的`1.5`版本支持。

由于差异比较大的缘故，单独分了一个分支进行维护。

目前支持功能：
- [x] 透明代理模式
- [x] URL订阅源更新(走路由器代理访问)
- [x] 支持**DIY代理组**节点`添加`/`删除`功能(由于URI的不规范原因,支持的代理参数可能存在解析问题)
- [x] ~~代理组类型切换功能: select/url-test/load-blance/fallback~~
- [x] 默认支持Yacd控制面板，
- [x] 支持自定义更新GeoIP数据文件，文件大小由自己选择(200KB~6MB)。
- [x] 支持CloudFlare的DDNS功能，可同时更新同一账号多个域名(多个域名可用)
- [x] 支持中继代理组配置，初衷为了支持解锁Netflix，可以拯救被墙的代理组。
- [x] 增加上传自定义的config.yaml文件功能: 用户可以使用自己的订阅源proxy-providers,以及自己的代理组.
- [x] 增加备份与恢复配置功能: 方便使用者折腾,如果折腾失败了可以快速恢复到备份前状态.
- [x] 增加自定义**黑、白名单规则**界面配置功能: 想要单独设置某个网站使用代理或者直连(比如游戏网站、视频网站等)，这个功能就满足要求了.
- [x] 增加了**黑名单模式/白名单模式**选择: 黑名单模式时默认直连，白名单模式时默认走代理，匹配规则都来自于github分享。
- [x] 可视化编辑config.yaml文件及其包含的providers文件: **v2.2.4**版本支持。



### 004.为什么不提供代理可用性检测
> 因为检测代理可用性总要访问一些没必要的地址。**即使检测了，有时候也是不能证明代理是否可用的**！这就是多此一举的功能,Yacd页面就具备了这个检测功能。

到底代理可不可用，验证就很简单，直接使用就可以了：
- **国外验证**直接通过浏览国外Youtube就可以验证了
- **国内验证** 访问国内网站就可以了。


### 005.插件安装过程条件检测

安装过程需要对路由器的一些基础环境检测, 主要是判断是否能使用此插件,我总结了主要的检测如下:

1. **koolshare**软件中心版本检测: 在[github项目中](https://github.com/koolshare/rogsoft/blob/master/README.md)有介绍, 主要的区别就是 **软件中心API**分 **1.0代(在华硕380版本固件使用)** 和 **1.5代(华硕384/386版本固件使用)**, 二者代码不兼容通用, 最开始开发的main分支就是 **1.0代的华硕380版本固件使用的**, 之后新的路由器都过渡到了 **1.5代的华硕386版本固件**.
2. CPU架构检测: 根据一些分析,主要的架构型号有: armv7l/aarch64/x86_64/mips , 其中华硕固件并不支持x86_64/mips两种架构的CPU, 因此目前也只支持了 armv7l 和 aarch64(armv8).
3. Linux内核版本检测(可选): 如果编译的可执行程序非静态链接生成(依赖一些动态库),可能需要做这个检测,对于没有动态库依赖的可执行程序就没必要检测了,比如**GoLang语言编写的工具**.
4. 固件版本检测(可选): 比如华硕的目前的三个版本号(380/384/386),以后可能有更高版本, 如果对固件自带特殊命令没什么依赖就没什么必要检测.

如果安装失败了,就将安装过程日志反馈给开发者,了解上面几个检测情况,哪个环节不支持,以便于支持更多的固件。你虽然没有写代码，但这样做也是帮助这个插件更加稳定。



## 003.koolshare插件开发的API知识
> 软件中心的API说明文档在固件中详细说明的不多，多数是通过阅读代码了解，这里简单的做一下总结分享。

先列举他人分享内容:
- [官方软件中心1.0老版本API文档说明-(想开发插件推荐先阅读)](https://github.com/koolshare/koolshare.github.io/wiki/%E6%A2%85%E6%9E%97AM380%E8%BD%AF%E4%BB%B6%E4%B8%AD%E5%BF%83%E6%8F%92%E4%BB%B6%E5%BC%80%E5%8F%91%E6%95%99%E7%A8%8B%E8%AF%A6%E8%A7%A3)
- [SukkaW分享的软件中心API文档说明](https://github.com/SukkaW/Koolshare-OpenWrt-API-Documents)
- [httpdb-软件中心API源码](https://github.com/thesadboy/httpdb)

### 001.关于执行shell脚本返回值如何实现JSON数据传递?

常规的方式返回结果就是个字符串数据，调用方法为:

```Bash
http_response "ok"
```

这样在Web前端就会得到如下结果:
```json
{
    "result": "ok"
}
```

想要实现返回JSON数据就要从 **http_response**返回值上入手了，经过一番尝试，成功的返回了JSON结果，看看下面的示例:


```Bash

# 用于返回JSON格式数据: {result: id, status: ok, data: {key:value, ...}}
response_json() {
    # 其中 data 内容格式示例: "{\"key\":\"value\"}"
    # 参数说明:
    #   $1: 请求ID
    #   $2: 想要传递给页面的JSON数据:格式为:key=value\nkey=value\n...
    #   $3: 返回状态码, ok为成功, error等其他为失败
    http_response "$1\",\"data\": "$2", \"status\": \"$3"  >/dev/null 2>&1
}


....#省略了若干代码

    case "$action_job" in
        test_json)
            # awk使用=分隔符会导致追加尾部的=号被忽略而出现错误
            # 因此使用了sub只替换第一个=号为":"，后面的=号不变
            ret_data="{$(dbus list clash_edit| awk '{sub("=", "\":\""); printf("\"%s\",", $0)}'|sed 's/,$//')}"
            response_json "$1" "$ret_data" "ok"
            return 0
            ;;
        *)
            ....
            ;;
    esac

```

看到了，我增加了一个 **response_json()**函数，对 http_response 进行了封装，然后对"key=value\nkey=value\n..."这样格式的数据进行了双引号添加处理(这里没有进行类型检测，一律按字符串处理了)。

看看Web前端得到结果数据吧:

```json
{
    "result": "99822551",
    "data": {
        "clash_edit_filecontent": "cGF5b。。。。。="
    },
    "status": "ok"
}
```

就这样，Ajax动态加载数据的功能就可以实现了, 这样解析数据既简单有快速，比拼接一个很长很长的字符串，然后再截取字符串操作要容易的多了，且不会出错的。

当然，这种返回数据大小是有限制的，取决于这个实现过程的下面几个限制:

- skipdb限制单个 value 最长大小，实测应该是**128KB**以内的value可以设置成功,这里的128KB是value值，如果使用base64编码数据的话，原始数据应该在**96KB**以内，比如rule订阅文件中的 **direct.yaml** 传递过程就因为value太大而报错，这里在实现时需要增加文件大小判断,推荐限制到 **0.75MB**以内，你会问为啥？我只能说实际经验，俺也没读过skipdb源代码，没办法给出精准数据。
- httpdb限制， httpdb对单个value的限制应该是在 skipdb之上，所以对于单个value限制，skipdb才是导致木桶漏水的短板。
- 多个value数据限制： 没实际测试过，但传递数据越多意味着传输时间就越久，而进行Base64编码和解码的时间也会越久(虽然感知不明显)，做到这一点是最好的: **一个操作任务只返回相关的结果数据!**



## 004.为什么有这个项目
> 作为程序员的俺，用了很多年别人写的插件，一天翻出了垃圾堆里**零元购计划**的斐迅K3路由器，打算**变斐为宝**，毕竟曾经被他欺骗过感情的。。。

一开机，发现装了`梅林380版固件`，那就从这里开始吧。

**如何写个小巧的插件呢？** 第一个想法就是 **拿来主义**，毕竟没有 **Ctrl+C/Ctrl+V**解决不了的(玩笑话)。

找了几个插件(比如fancyss、merlinclash等)，都过于庞大,此时恰好看到**clash**挺火的，那就使用**clash**作为核心功能吧。

至此, 这个项目就诞生了。但当时名字为clash，这与clash重名可不行呀，俺想到了《V字仇杀队》电影的V,那就起名为**vClash**啦。

V带着面具，但Clash图标加面具就啥也看不到了，于是想到了另一个角色Z(佐罗)，于是在vClash上加了Z的蒙眼带。

之后，新路由器使用了`梅林改版386固件`, 于是又开发了支持`386版本`的**ksmerlin386分支**版本。

## 005.问题记录

### 路由器更新Github上安装包失败问题

插件实现了将内网发给路由器的DNS请求传给代理转发，并没有解决路由器内部DNS请求的代理转发，所以，从路由器本机的DNS请求都是直接转发出去的，必然存在DNS污染问题。

解决方法：

暂时没解决，计划通过集成其他DNS代理工具、或者使用dnsmasq的DNS转发配置临时解决。

1. 配置dnsmasq，将tcp/udp的dns解析上游转到Clash的DNS端口


总之，这都是因为RT-AC86U上没有启用TPROXY模块引起的问题。

## 999.最后


点个赞就是支持！

关注[我的博客](https://vlike.work/)或者[油管频道](https://www.youtube.com/channel/UCsb-LlhxstK3VRLz5_3kZxQ)获取一些相关内容, 虽然更新的并不是很多。

获取免费代理节点，可以订阅[TG频道](https://t.me/free_proxy_001)。
