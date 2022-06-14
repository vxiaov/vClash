# vClash说明


## 001.如何使用vClash


### 安装vClash
最新版本安装包存放到release目录中，对应下载链接:


| Github分支    | 支持Koolshare路由器固件版本 | Github下载链接                                                                                                                                                                        | 国内CDN下载链接                                                                                             |
| ----------- | ------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------- |
| main        | 华硕380版本(停止更新)            | [斐迅K3梅林380版本](https://github.com/learnhard-cn/vClash/raw/main/release/clash.tar.gz)                     | [斐迅K3梅林380版本](https://cdn.jsdelivr.net/gh/learnhard-cn/vClash@main/release/clash.tar.gz)              |
| ksmerlin386(默认主分支) | 华硕官改、梅林386版本(持续更新)       | [梅林386版本](https://github.com/learnhard-cn/vClash/raw/ksmerlin386/release/clash.tar.gz) | [梅林386版本](https://cdn.jsdelivr.net/gh/learnhard-cn/vClash@ksmerlin386/release/clash.tar.gz) |


路由器插件的安装方法使用 **“离线安装”**，安装前遇到**非法关键词检测**问题可以看下面解决方法。

### 离线安装非法关键词检测不通过怎么办？这样解决。


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

### 001.配置vClash-代理订阅源
> vClash实际上安装后即可启动使用，因为配置文件已经内置了，但没有代理节点启动了网络也是有问题的。因此，还是需要 **添加自己的代理节点** 或者更新一下 **订阅源** 才可以。

添加代理节点:

1. 有自己的代理节点： 在 **节点管理**页面添加即可，注意格式是base64链接格式
2. 有机场订阅源HTTP链接: 推荐 在**节点管理**页面中添加，也可以在 **订阅管理**中添加订阅源URL地址，两者更新的代理节点区别是:添加的代理组不一样，使用的命令不一样，前者使用uri_decoder,或者使用curl。
3. 网上找的免费订阅源HTTP链接: 因为这种免费HTTP订阅源不稳定，推荐在**订阅管理**中添加，而**节点管理**适合保存自己私人的订阅源。

### 002.配置vClash-黑名单白名单规则

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

### 003.在线编辑页面使用说明

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

## 002.开发知识

由于开发插件过程想法和需求总是在变化，所以新版本可能会去掉了以前不需要或者冗余的一些功能，而且实现的逻辑也在更新，以达到最简便快捷的实现方式。

如果你打算开发一个自己的插件，多阅读一些插件的代码对你非常有帮助的。


### vClash插件基本目录结构

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

### vClash功能说明

看到上面的目录结构后，只有一个功能脚本 **clash_control.sh**文件，这是大部分插件的基本样子了，具体有什么功能都是通过将参数传递给clash_control.sh来决定。

- clash_control.sh : 所有的功能都集成在这个脚本中，根据传入参数不同调用不同功能。
- Module_clash.asp : 插件的Web前端UI界面，就是浏览器中看到的样子，都是在这里配置的。
- install.sh/uninstall.sh: 只在插件离线安装和卸载时调用，初始化和清理与vClash插件相关内容用。
- clash : 这个目录包含Clash运行的基础配置信息，启动配置config.yaml, Country.mmdb包含IP数据， dashboard包含Yacd前端，providers包含代理订阅文件，ruleset包含订阅规则文件，version包含插件版本信息，bin包含所有相关的命令工具。
- res   : clash_style.css美化布局在Module_clash.asp页面中的按钮、标签的样式， icon-clash.png就是 vClash的Logo图标。

以上就是vClash包含的内容了。

### 实现功能简述




## 003.koolshare开发的API知识
> 软件中心的API说明文档在固件中详细说明的不多，多数是通过阅读代码了解，这里简单的做一下总结分享。

先列举他人分享内容:
- [官方软件中心1.0老版本API文档说明-(想开发插件推荐先阅读)](https://github.com/koolshare/koolshare.github.io/wiki/%E6%A2%85%E6%9E%97AM380%E8%BD%AF%E4%BB%B6%E4%B8%AD%E5%BF%83%E6%8F%92%E4%BB%B6%E5%BC%80%E5%8F%91%E6%95%99%E7%A8%8B%E8%AF%A6%E8%A7%A3)
- [SukkaW分享的软件中心API文档说明](https://github.com/SukkaW/Koolshare-OpenWrt-API-Documents)
- [httpdb-软件中心API源码](https://github.com/thesadboy/httpdb)

### 关于执行shell脚本返回值如何实现JSON数据传递?

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

- skipdb限制单个 value 最长大小，没详细研究但 **1MB**的数据是肯定不可以啦，比如rule订阅文件中的 **direct.yaml** 传递过程就因为value太大而报错，这里在实现时需要增加文件大小判断,推荐限制到 **0.75MB**以内，你会问为啥？我只能说实际经验，俺也没读过skipdb源代码，没办法给出精准数据。
- httpdb限制， httpdb对单个value的限制应该是在 skipdb之上，所以对于单个value限制，skipdb才是导致木桶漏水的短板。
- 多个value数据限制： 没实际测试过，但传递数据越多意味着传输时间就越久，而进行Base64编码和解码的时间也会越久(虽然感知不明显)，做到这一点是最好的: **一个操作任务只返回相关的结果数据!**


## 999.最后

