# [](https://github.com/learnhard-cn/vClash/compare/v2.2.13...v) (2022-08-12)



## [2.2.13](https://github.com/learnhard-cn/vClash/compare/v2.2.12...v2.2.13) (2022-08-07)


### Bug Fixes

* 更新订阅源方式切换为curl命令实现。 ([00e3c56](https://github.com/learnhard-cn/vClash/commit/00e3c566766d76e0176bdb0a03186db668185d94))
* 修改黑白名单判断逻辑，避免因异常中断导致环境变量提交丢失导致问题。 ([0ed4551](https://github.com/learnhard-cn/vClash/commit/0ed455108585a5e70991af1ad930d4f0d668a031))
* remove gzip binfile after upgrade clash ([4fb4db6](https://github.com/learnhard-cn/vClash/commit/4fb4db65b3b037583ae230cbad97cc521646f8eb))


### Features

* 修改DDNS功能，增加IPv6地址解析 ([b24dd3d](https://github.com/learnhard-cn/vClash/commit/b24dd3de679d3e98492b33fbd1fb1414c87c51cf))



## [2.2.12](https://github.com/learnhard-cn/vClash/compare/v2.2.11...v2.2.12) (2022-07-19)


### Features

* 支持更新clash内核文件,但仍然不建议升级。 ([5316aeb](https://github.com/learnhard-cn/vClash/commit/5316aeb0be45f36a01b4d3317826eef31e11fb4a))
* update clash bin ([34abcdd](https://github.com/learnhard-cn/vClash/commit/34abcdd9cd81e05a171cb202ab71f45db7936880))



## [2.2.11](https://github.com/learnhard-cn/vClash/compare/v2.2.10...v2.2.11) (2022-07-19)


### Bug Fixes

* 修复解析vmess缺少tls/udp导致解析错误问题 ([1b61e56](https://github.com/learnhard-cn/vClash/commit/1b61e56dbadce488bdefb5743b786eac477e43c1))



## [2.2.10](https://github.com/learnhard-cn/vClash/compare/v2.2.9...v2.2.10) (2022-06-22)


### Bug Fixes

* 修复clash_provider_file变量安装时没有进行base64编码问题。 ([5e0ce34](https://github.com/learnhard-cn/vClash/commit/5e0ce345c5e77f220ff95f0dad0c82b07d8cbe61))
* 修复IPv6支持及web页面显示问题 ([e3220bc](https://github.com/learnhard-cn/vClash/commit/e3220bc75dfbd022f9320f0927bdea9ad8f6ab60))



## [2.2.9](https://github.com/learnhard-cn/vClash/compare/v2.2.8...v2.2.9) (2022-06-21)


### Features

* 支持IPv6地址DNS解析 ([eb9f2da](https://github.com/learnhard-cn/vClash/commit/eb9f2da8b42d094904af97644660e81af0f5706b))



## [2.2.8](https://github.com/learnhard-cn/vClash/compare/v2.2.7...v2.2.8) (2022-06-19)


### Bug Fixes

* 修改订阅源更新模块Base64解析规则和编码规则。 ([195981b](https://github.com/learnhard-cn/vClash/commit/195981bf4a66107f75de02b9dd9723ae650790f2))
* 修改更新订阅源命令为uri_decoder ([479a622](https://github.com/learnhard-cn/vClash/commit/479a622b21042e8ae9ae7f6b45b692bb05bb1fe7))



## [2.2.7](https://github.com/learnhard-cn/vClash/compare/v2.2.6...v2.2.7) (2022-06-18)


### Bug Fixes

* 修复更新订阅源失败问题及mac系统快捷键问题 ([86a8a22](https://github.com/learnhard-cn/vClash/commit/86a8a22f496edb70b5e546bf089f543d64ae1eb6))



## [2.2.6](https://github.com/learnhard-cn/vClash/compare/v2.2.5...v2.2.6) (2022-06-17)


### Bug Fixes

* 精简direct.yaml与gfw.yaml内容 ([95f0173](https://github.com/learnhard-cn/vClash/commit/95f0173ce9d9f2c394e9e175afba8ed6052fbb6a))
* 配置调整及脚本验证config.yaml规则调整 ([62672ef](https://github.com/learnhard-cn/vClash/commit/62672ef37d84d3f4e07a560f73bfd5ff89388987))
* 限制在线编辑文件大小不可以超过96KB,修改配置文件关闭IPv6监听地址 ([027907e](https://github.com/learnhard-cn/vClash/commit/027907ea41130fcb1e76f1aa607a20fc45e96e94))
* 修复Moudle_clash.asp内部id名称多出空格问题 ([9599613](https://github.com/learnhard-cn/vClash/commit/95996135ff60d82507ecdb450d47c19957a76824))
* 修改配置文件名，增加了_part部分区别其它配置文件名 ([e3bbf93](https://github.com/learnhard-cn/vClash/commit/e3bbf9307d3e1d2d5448bdcfc052edcfd56d015f))
* 优化代理组组合关系 ([0c9e44b](https://github.com/learnhard-cn/vClash/commit/0c9e44b454ea8de65a14057dd80255fdb6e9826b))


### Features

* 增加日志弹窗模式,支持平铺模式与弹窗模式切换开关。 ([be923ed](https://github.com/learnhard-cn/vClash/commit/be923edb8ac2ec584e5a46114a857ad1e4d13e7f))



## [2.2.5](https://github.com/learnhard-cn/vClash/compare/v2.2.4...v2.2.5) (2022-06-14)


### Bug Fixes

* 发布新版本v2.2.5 ([01c592b](https://github.com/learnhard-cn/vClash/commit/01c592b10f69f16f7dd82e0f31e7079475cb8c5e))



## [2.2.4](https://github.com/learnhard-cn/vClash/compare/v2.2.3...v2.2.4) (2022-06-13)


### Features

* 可视化编辑config.yaml文件及其包含的providers文件 ([6e0b860](https://github.com/learnhard-cn/vClash/commit/6e0b860819b820b9413a6802d350eaa5984576d2))



## [2.2.3](https://github.com/learnhard-cn/vClash/compare/v2.2.1...v2.2.3) (2022-06-10)


### Features

* 完善备份与恢复功能,支持黑白名单规则自定义填写。 ([f9bf88f](https://github.com/learnhard-cn/vClash/commit/f9bf88f5f16a3d92047d9b3e0a016dbc9818668c))



## [2.2.1](https://github.com/learnhard-cn/vClash/compare/v2.2.0...v2.2.1) (2022-06-04)


### Bug Fixes

* uri_decoder支持代理访问HTTP请求 ([39359f9](https://github.com/learnhard-cn/vClash/commit/39359f921005e9f535d50d176c7ec53d6833f3af))


### Features

* 优化更新订阅源和GeoIP文件规则 ([d143e6f](https://github.com/learnhard-cn/vClash/commit/d143e6fbb7da52419553f4ef2e9c5290f0a23d4c))


### Performance Improvements

* 去掉gfwlist模式(没用的功能) ([465495c](https://github.com/learnhard-cn/vClash/commit/465495cba0376424f456dacd05425f1f64aa69b1))



# [2.2.0](https://github.com/learnhard-cn/vClash/compare/v2.1.2...v2.2.0) (2022-05-20)


### Bug Fixes

* 删除全部节点功能优化 ([29e8ff4](https://github.com/learnhard-cn/vClash/commit/29e8ff45a04b06b6fac4dcbf72753f2b60951e56))
* 增加通过代理更新clash程序，github默认访问经常失败 ([79b3407](https://github.com/learnhard-cn/vClash/commit/79b34079ea3776d5a21ef14fbb8b53c3b901dca0))
* some config change ([b49578d](https://github.com/learnhard-cn/vClash/commit/b49578db2757877b4c6058fef583befe37322259))


### Features

* 新增HTTP订阅源解析功能 ([e80aeb8](https://github.com/learnhard-cn/vClash/commit/e80aeb85c390af652e164fc3bdf17bcc2e4df9ca))
* 增加软路由上线、下线检测功能 ([5e1a895](https://github.com/learnhard-cn/vClash/commit/5e1a8958132bd5d78bc80d283565f028d26ff1f8))


### Performance Improvements

* 优化config.yaml配置规则 ([869f988](https://github.com/learnhard-cn/vClash/commit/869f9887c7a976ea0e76140c947116c5f6e090c7))



## [2.1.2](https://github.com/learnhard-cn/vClash/compare/v2.1.1...v2.1.2) (2022-01-02)


### Features

* 优化Clash启动配置文件config.yaml，将节点信息都移到单独文件中管理 ([1dee9b6](https://github.com/learnhard-cn/vClash/commit/1dee9b6076d3d360ce2cdbb83731a09313628f7a))



## [2.1.1](https://github.com/learnhard-cn/vClash/compare/v2.1.0...v2.1.1) (2021-12-04)


### Bug Fixes

* 精简Clash配置文件，增加providers文件源更新节点方式(不需要重启Clash) ([3853ee1](https://github.com/learnhard-cn/vClash/commit/3853ee19092e3e17e57a4a5ae8d075ed58790c1b))
* 优化添加节点更新配置文件逻辑,优化配置文件代理组及规则设置。 ([c7de2f3](https://github.com/learnhard-cn/vClash/commit/c7de2f397efd8fd8cab04306813af90c8c1e5c1f))



# [2.1.0](https://github.com/learnhard-cn/vClash/compare/v2.0.12...v2.1.0) (2021-11-26)


### Bug Fixes

* 更新2.1.0版本，放宽支撑路由器检测条件 ([f9f5cc7](https://github.com/learnhard-cn/vClash/commit/f9f5cc72786dc10cc1b9ac6317c604a005f9e528))
* 修改安装脚本install.sh检测条件和.valid文件支持更多类型路由器 ([b8eaf96](https://github.com/learnhard-cn/vClash/commit/b8eaf9674fafd711293043b0caf071619dbe9b69))



## [2.0.12](https://github.com/learnhard-cn/vClash/compare/v2.0.11...v2.0.12) (2021-11-24)


### Bug Fixes

* 补充DDNS功能缺失的jq命令工具 ([908b30a](https://github.com/learnhard-cn/vClash/commit/908b30a48594ae0d823ee3d41dd65fa7b7ce4a72))
* 优化页面显示relay_option_list为空时报错和其他小修改 ([b958e28](https://github.com/learnhard-cn/vClash/commit/b958e2853a93b56de8d0ef06e4bfe83d47b48082))



## [2.0.11](https://github.com/learnhard-cn/vClash/compare/v2.0.10...v2.0.11) (2021-11-24)


### Features

* 切换为使用rule-provider模式,增加中继代理组 ([ee97c92](https://github.com/learnhard-cn/vClash/commit/ee97c92df9b089f4652868867f4b8a523ae5f83f))


### BREAKING CHANGES

* 拯救被墙节点作为中继出口节点.



## [2.0.10](https://github.com/learnhard-cn/vClash/compare/v2.0.9...v2.0.10) (2021-11-07)



## [2.0.9](https://github.com/learnhard-cn/vClash/compare/v2.0.8...v2.0.9) (2021-11-04)



## [2.0.8](https://github.com/learnhard-cn/vClash/compare/v2.0.7...v2.0.8) (2021-11-04)



## [2.0.7](https://github.com/learnhard-cn/vClash/compare/v2.0.6...v2.0.7) (2021-11-03)



## [2.0.6](https://github.com/learnhard-cn/vClash/compare/v2.0.4...v2.0.6) (2021-10-12)


### Features

* 增加Cloudflare动态DNS功能 ([40a8464](https://github.com/learnhard-cn/vClash/commit/40a8464c889969004c61727593d50f5f33fd5fc4))


### BREAKING CHANGES

* 增加Cloudflare动态DNS功能



## [2.0.4](https://github.com/learnhard-cn/vClash/compare/v2.0.3...v2.0.4) (2021-10-03)



## [2.0.3](https://github.com/learnhard-cn/vClash/compare/v2.0.2...v2.0.3) (2021-10-02)



## [2.0.2](https://github.com/learnhard-cn/vClash/compare/v2.0.1...v2.0.2) (2021-10-02)



## [2.0.1](https://github.com/learnhard-cn/vClash/compare/ef7fc5196940409813602d6537fb3df3202f8211...v2.0.1) (2021-10-02)


### Features

* 新增更新规则集/geoip文件按钮 ([ef7fc51](https://github.com/learnhard-cn/vClash/commit/ef7fc5196940409813602d6537fb3df3202f8211))



