<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<html xmlns:v>

<head>
    <meta http-equiv="X-UA-Compatible" content="IE=Edge" />
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta HTTP-EQUIV="Pragma" CONTENT="no-cache">
    <meta HTTP-EQUIV="Expires" CONTENT="-1">
    <link rel="shortcut icon" href="images/favicon.png">
    <link rel="icon" href="images/favicon.png">
    <title>科学上网工具-Clash(支持免费订阅源)</title>
    <link rel="stylesheet" type="text/css" href="index_style.css" />
    <link rel="stylesheet" type="text/css" href="form_style.css" />
    <link rel="stylesheet" type="text/css" href="usp_style.css" />
    <link rel="stylesheet" type="text/css" href="css/element.css">
    <link rel="stylesheet" type="text/css" href="res/softcenter.css">
    <script type="text/javascript" src="/state.js"></script>
    <script type="text/javascript" src="/popup.js"></script>
    <script type="text/javascript" src="/help.js"></script>
    <script type="text/javascript" src="/js/jquery.js"></script>
    <script type="text/javascript" src="/general.js"></script>
    <script type="text/javascript" language="JavaScript" src="/js/table/table.js"></script>
    <script type="text/javascript" language="JavaScript" src="/client_function.js"></script>
    <script type="text/javascript" src="/res/softcenter.js"></script>
    <link rel="stylesheet" type="text/css" href="/res/clash_style.css">
    <script type="text/javascript">
        var dbus = {};
        var _responseLen;
        var noChange = 0;

        const dnsv4List = [
            { name: '阿里公共 DNS (Alibaba)', ips: '223.5.5.5' },
            { name: 'DNSPod DNS (Tencent)', ips: '119.29.29.29' },
            { name: '114 公共 DNS', ips: '114.114.114.114' },
            { name: 'Cloudflare DNS', ips: '1.1.1.1 ' },
            { name: '谷歌公共 DNS (Google)', ips: '8.8.8.8' },
            { name: '华为公共 DNS (Huawei)', ips: '129.213.4.5' },
            { name: 'AdGuard DNS (安全版)', ips: '94.140.14.14' },
            { name: 'AdGuard DNS (家庭版，含广告过滤)', ips: '176.103.130.130' },
            { name: 'CleanBrowsing DNS (基础版)', ips: '185.228.168.168' },
            { name: 'CleanBrowsing DNS (家庭保护版)', ips: '185.228.168.166' },
        ];
        const dnsv6List = [
            { name: '腾讯 IPv6 DNS (Tencent)', ips: '2402:4e00::' },
            { name: '阿里 IPv6 DNS (Alidns)', ips: '2400:3200::1' },
            { name: '谷歌 IPv6 DNS (Google)', ips: '2001:4860:4860::8888' },
            { name: 'Cloudflare IPv6 DNS', ips: '2606:4700:4700::1111' },
        ];
        const mmdbList = [
            { name: "Dreamacro维护的MaxMin数据", href: "https://github.com/Dreamacro/maxmind-geoip/raw/release/Country.mmdb"},
            { name: "(国内加速)Dreamacro维护的MaxMin数据",  href: "https://cdn.jsdelivr.net/gh/Dreamacro/maxmind-geoip@raw/release/Country.mmdb"},
            { name: "alecthw维护的多合一版本IP数据", href: "https://raw.githubusercontent.com/alecthw/mmdb_china_ip_list/release/Country.mmdb"},
            { name: "(国内加速)alecthw维护的多合一版本IP数据", href: "https://cdn.jsdelivr.net/gh/alecthw/mmdb_china_ip_list@release/Country.mmdb"},
            { name: "Hackl0us维护的精简版IP数据(非必要不使用)", href: "https://github.com/Hackl0us/GeoIP2-CN/raw/release/Country.mmdb"},
            { name: "(国内加速)Hackl0us维护的精简版IP数据(非必要不使用)", href: "https://cdn.jsdelivr.net/gh/Hackl0us/GeoIP2-CN@raw/release/Country.mmdb" },
        ];

        var $j = jQuery.noConflict();


        function init() {
            show_menu(menu_hook);
            clash_config_init(); // 初始化配置，由于执行验证配置文件等操作，返回结果会慢一些
            register_event();
        }

        function menu_hook(title, tab) {
            tabtitle[tabtitle.length - 1] = new Array("", "软件中心", "离线安装", "Clash版代理工具");
            tablink[tablink.length - 1] = new Array("", "Module_Softcenter.asp", "Module_Softsetting.asp", "Module_clash.asp");
        }

        // 切换Clash内核
        function switch_clash_core() {
            apply_action("switch_clash_core", "0", function () {
                show_result("切换为" + dbus["clash_core_current"] + "内核文件", 1000);
            }, {
                "clash_core_current": dbus["clash_core_current"]
            });
        }
        function bind_clash_core_change() {
            dbus["clash_core_current"] = $j(this).val();
            switch_clash_core();
        }

        function bind_edit_filepath_change() {
            if ($j(this).val() == dbus["clash_edit_filepath"]) {
                // 没有变化
                return;
            } else {
                // 切换为查看模式
                switch_edit_filecontent();
            }
        }
        function bind_config_filepath_change() {
            if ($j(this).val() == dbus["clash_config_filepath"]) {
                // 没有变化
                return;
            } else {
                // 切换配置文件
                dbus["clash_config_filepath"] = $j(this).val();
                switch_clash_config();
            }
        }

        // 加载页面时注册事件
        function register_event() {
            // #edit_file_content fucus时，绑定ctrl+s、ctrl+e、ctrl+r快捷键
            $j("#edit_file_content").bind("focus", function() {
                // 先解除已有绑定事件
                $j(this).unbind("keydown");
                $j(this).bind("keydown", function(e) {
                    if ((e.ctrlKey || e.metaKey) && e.keyCode == 83) {
                        e.preventDefault();
                        save_config_content();
                        return false;
                    }
                    // 绑定 ctrl+e 快捷键
                    if ((e.ctrlKey || e.metaKey) && e.keyCode == 69) {
                        e.preventDefault();
                        edit_config_content();
                        return false;
                    }
                    // 绑定 ctrl+r 快捷键
                    if ((e.ctrlKey || e.metaKey) && e.keyCode == 82) {
                        e.preventDefault();
                        load_config_content();
                        return false;
                    }
                });
            });

            // #edit_file_content 失去焦点时，取消绑定的keydown快捷键
            $j("#edit_file_content").bind("blur", function() {
                // 先保存变更内容或者取消变更!
                var current_content = Base64.encode($j("#edit_file_content").val());
                if (dbus["clash_edit_filecontent"] != current_content) {
                    var res = confirm("内容已修改!是否保存?");
                    if (res) {
                        save_config_content();
                    }
                    return false;
                }
                $j(this).unbind("keydown");
                // 设置当前textarea的readonly属性
                $j(this).attr("readonly", true);

            });

            $j("#clash_switch_core").bind("change", bind_clash_core_change);
            $j("#clash_switch_config").bind("change", bind_config_filepath_change);
            $j("#clash_edit_filelist").bind("change", bind_edit_filepath_change);
            $j("#restore_file").bind("change", restore_config_file);
            $j("#file").bind("change", upload_config_file);
            $j("#clash_file").bind("change", upload_clash_file);

            // class="tab"的button被点击时，触发保存当前button的id
            $j(".tab").bind("click", function() {
                // dbus["clash_current_tab"] = this.id;
                apply_action("save_current_tab", "2", null, {
                    "clash_current_tab": this.id,
                });
            });
        }

        function yacd_ui_click_check() {
            // 点击 yacd 按钮时，检测 clash_enable 状态为 off时，弹出警告
            if (dbus["clash_enable"] == "off") {
                show_result("请先启用 clash，再进行 yacd 操作!");
                return false;
            }
        }

        function get_dbus_data() {
            $j.ajax({
                type: "GET",
                url: "/_api/clash",
                async: false,
                success: function (data) {
                    dbus = data.result[0];
                    conf2obj();
                }
            });
        }

    

        function conf2obj() {

            var params = [
                'clash_yacd_ui','clash_lan_ipv6_ports', 'clash_arch_type',
            ];
            var params_chk = [
                'clash_trans', 'clash_enable', 'clash_ipv6_mode', 'clash_log_type'
            ];

            // 更新 geoip mmdb 列表
            update_mmdb_list();
            // 更新 DNS 列表 
            update_dns_list();
            // 更新 clash_core_list
            update_clash_core_list();
            // 更新配置文件列表选项
            update_clash_filelist();

            //更新#clash_edit_filelist 编辑文件选项
            update_edit_filelist();

            set_log_type(); //初始化日志类型

            $j("#clash_vclash_version_status").html("<i>当前版本：" + dbus['clash_vclash_version'] + "</i>");
            $j("#clash_version_status").html("<i>当前版本：" + dbus['clash_version'] + "</i>");



            for (var i = 0; i < params_chk.length; i++) {
                if (dbus[params_chk[i]]) {
                    E(params_chk[i]).checked = dbus[params_chk[i]] == "on";
                } else {
                    // 第一次使用，有些参数没有设置
                    E(params_chk[i]).checked = false;
                }
            }
            for (var i = 0; i < params.length; i++) {
                switch (params[i]) {
                    case 'clash_yacd_ui':
                        // a 标签参数设置
                        if (dbus[ params[i] ]) {
                            E("clash_yacd_ui").href = dbus['clash_yacd_ui'];
                        }
                        break;
                    case 'clash_arch_type':
                        if (dbus[ params[i] ]) {
                            E("clash_arch_type").innerHTML = dbus['clash_arch_type'];
                        }
                        break;
                    default:
                        // 普通类型数据
                        if (dbus[ params[i] ]) 
                            E(params[i]).value = dbus[params[i]];
                        break;
                }
            }

            // 记录上次的tab页面
            if (!dbus["clash_current_tab"]) {
                dbus["clash_current_tab"] = "btn_default_tab";
            }
            document.getElementById(dbus["clash_current_tab"]).click();
        }

        // 更新clash配置文件列表
        function update_clash_filelist() {
            if (dbus["clash_config_filelist"]) {
                var opt = document.getElementById("clash_switch_config");
                opt.options.length = 0;
                filelist = dbus["clash_config_filelist"].trim().split(" ");
                current_file = dbus["clash_config_filepath"];
                if (filelist.length > 0) {
                    for (var i = 0; i < filelist.length; i++) {
                        opt.options.add(new Option(filelist[i], filelist[i]));
                    }
                    if (current_file) {
                        opt.value = current_file;
                    } else {
                        opt.value = filelist[0];
                        dbus["clash_config_filepath"] = filelist[0];
                    }
                }
            }

        }

        function update_clash_core_list() {
            if (dbus["clash_core_list"]) {
                var opt = document.getElementById("clash_switch_core");
                opt.options.length = 0;
                items_list = dbus["clash_core_list"].trim().split(" ");
                current_file = dbus["clash_core_current"];
                if (items_list.length > 0) {
                    for (var i = 0; i < items_list.length; i++) {
                        opt.options.add(new Option(items_list[i], items_list[i]));
                    }
                    if (current_file) {
                        opt.value = current_file;
                    } else {
                        opt.value = items_list[0];
                        dbus["clash_core_current"] = items_list[0];
                    }
                }
            }
        }

        function update_mmdb_list() {
            // 更新 mmdb 列表
            var opt = document.getElementById("clash_geoip_url");
            opt.options.length = 0;
            var matched = false;
            for (var i = 0; i < mmdbList.length; i++) {
                opt.options.add(new Option(mmdbList[i].name, mmdbList[i].href));
                if(dbus["clash_geoip_url"] == mmdbList[i].href){
                    opt.value = mmdbList[i].href;
                    matched = true;
                }
            }
            if (! matched) {
                opt.options.add(new Option(dbus["clash_geoip_url"], dbus["clash_geoip_url"]));
                opt.value = dbus["clash_geoip_url"];
            }
        }
        function update_dns_list() {
            // 更新 dns 列表
            var opt = document.getElementById("clash_ipv4_dns1");
            opt.options.length = 0;
            for (var i = 0; i < dnsv4List.length; i++) {
                opt.options.add(new Option(dnsv4List[i].name, dnsv4List[i].ips));
                if(dbus["clash_ipv4_dns1"] == dnsv4List[i].ips){
                    opt.value = dnsv4List[i].ips;
                }
            }
            opt = document.getElementById("clash_ipv4_dns2");
            opt.options.length = 0;
            for (var i = 0; i < dnsv4List.length; i++) {
                opt.options.add(new Option(dnsv4List[i].name, dnsv4List[i].ips));
                if(dbus["clash_ipv4_dns2"] == dnsv4List[i].ips){
                    opt.value = dnsv4List[i].ips;
                }
            }
            opt = document.getElementById("clash_ipv6_dns1");
            opt.options.length = 0;
            for (var i = 0; i < dnsv6List.length; i++) {
                opt.options.add(new Option(dnsv6List[i].name, dnsv6List[i].ips));
                if(dbus["clash_ipv6_dns1"] == dnsv6List[i].ips){
                    opt.value = dnsv6List[i].ips;
                }
            }
            opt = document.getElementById("clash_ipv6_dns2");
            opt.options.length = 0;
            for (var i = 0; i < dnsv6List.length; i++) {
                opt.options.add(new Option(dnsv6List[i].name, dnsv6List[i].ips));
                if(dbus["clash_ipv6_dns2"] == dnsv6List[i].ips){
                    opt.value = dnsv6List[i].ips;
                }
            }
        }

        function update_edit_filelist() {
            if (dbus["clash_edit_filelist"]) {
                var edit_option = document.getElementById("clash_edit_filelist");
                edit_option.options.length = 0;
                edit_filelist = dbus["clash_edit_filelist"].trim().split(" ");
                current_edit_file = dbus["clash_edit_filepath"];
                if (edit_filelist.length > 0) {
                    for (var i = 0; i < edit_filelist.length; i++) {
                        edit_option.options.add(new Option(edit_filelist[i], edit_filelist[i]));
                    }
                    if (current_edit_file) {
                        edit_option.value = current_edit_file;
                    } else {
                        edit_option.value = edit_filelist[0];
                    }
                }
            }

        }

        function update_node_list() {
            apply_action("list_nodes", "2", function(data) {
                dbus["clash_name_list"] = data.clash_name_list;
                var obj = document.getElementById("proxy_node_name");
                obj.options.length = 0;
                const node_arr = dbus["clash_name_list"].trim().split(" ");
                for (let index = 0; index < node_arr.length; index++) {
                    const element = node_arr[index];
                    obj.options.add(new Option(element, element));
                }
            }, {})
        }


        //提交任务方法,实时日志显示
        // flag: 0:提交任务并查看日志，1:提交任务3秒后刷新页面, 2:提交任务后无特殊操作(可指定callback回调函数),3:提交任务执行完毕后在调用回调函数
        function post_dbus_data(script, arg, obj, flag, callback) {
            var id = parseInt(Math.random() * 100000000);
            var postData = {
                "id": id,
                "method": script,
                "params": [arg],
                "fields": obj
            };
            $j.ajax({
                type: "POST",
                cache: false,
                url: "/_api/",
                async: true,
                data: JSON.stringify(postData),
                dataType: "json",
                success: function(response) {
                    if (response.result == id) {
                        if (response.status == "ok") {
                            if (flag && flag == "0") {
                                // 查看执行过程日志
                                show_status();
                            } else if (flag && flag == "1") {
                                // 页面刷新操作
                                refreshpage(3);
                            } else if (flag && flag == "2") {
                                // 什么也不做...
                            } else if (flag && flag == "3") {
                                show_status(callback, response.data);
                                return ;
                            }
                            // 动态获取数据模式: JSON数据保存在 response.data 变量中
                            // data内部数据使用方式: resp_data.key1 , resp_data.key2 , resp_data.key3 ...
                            var resp_data = response.data;
                            if (callback) {
                                setTimeout(function() {
                                    callback(resp_data);
                                }, 1000);
                            }
                        } else if (flag && flag == "1") {
                            // 页面刷新操作
                            refreshpage(3);
                        } else if (flag && flag == "2") {
                            //continue;
                            if (callback) {
                                setTimeout(function() {
                                    callback();
                                }, 1000);
                            }
                        } else {
                            show_status();
                            if (callback) {
                                setTimeout(function() {
                                    callback();
                                }, 1000);
                            }
                        }
                    }
                }
            });
        }

        // 显示动态结果消息
        function show_result(message, duration) {
            if (!duration) duration = 1000;
            $j('#status_info').text(message);
            $j('#status_info').fadeIn(100);
            $j('#status_info').css('display', 'inline-block');
            setTimeout(() => {
                $j('#status_info').fadeOut(1000);
            }, duration);
        }

        function show_status(callback, data) {
            //显示脚本执行过程的日志信息
            document.getElementById("loadingIcon").style.display = "";
            if(dbus["clash_log_type"] == "on") {
                $j("#logArea").show();
            }else {
                $j("#logMsg").show();
            }
            
            $j.ajax({
                url: '/_temp/clash_status.log',
                type: 'GET',
                async: true,
                cache: false,
                dataType: 'text',
                success: function(response) {
                    var retArea = E("clash_text_log");
                    var logBackup = E("clash_log_backup");
                    var logMsg = E("clash_log_msg");
                    
                    if (response.search("XU6J03M6") != -1) {
                        document.getElementById("loadingIcon").style.display = "none";
                        retArea.value = response.replace("XU6J03M6", " ");
                        logBackup.value = retArea.value;
                        logMsg.value = retArea.value;
                        logMsg.scrollTop = logMsg.scrollHeight;
                        retArea.scrollTop = retArea.scrollHeight;
                        // 任务执行完毕后调用回调函数，支持参数传递
                        if (callback) {
                            setTimeout(function() {
                                if (data) {
                                    callback(data);
                                }else {
                                    callback();
                                }
                            })
                        }
                        ready_close_log_msg();
                        return true;
                    }
                    if (_responseLen == response.length) {
                        noChange++;
                    } else {
                        noChange = 0;
                    }
                    if (noChange > 1000) {
                        document.getElementById("loadingIcon").style.display = "none";
                        return false;
                    } else {
                        setTimeout(function() {
                            show_status(callback, data);
                        }, 500);
                    }
                    retArea.value = response.replace("XU6J03M6", " ");
                    retArea.scrollTop = retArea.scrollHeight;
                    logMsg.value = retArea.value;
                    logMsg.scrollTop = logMsg.scrollHeight;
                    _responseLen = response.length;
                },
                error: function() {
                    setTimeout(function() {
                        show_status(callback, data);
                    }, 500);
                }
            });
        }

        // 关闭日志消息提示
        function ready_close_log_msg() {
            var time_sec = 10;
            var timeoutid = setInterval(function() {
                $j("#btn_log_msg_close").text("关闭(" + time_sec-- + "秒后)");
                if (time_sec == 0) {
                    $j("#btn_log_msg_close").text("关闭");
                    clearInterval(timeoutid);
                    close_log_msg();
                }
            }, 1000);
        }

        function close_log_msg() {
            $j("#logArea").fadeOut(1000);
        }

        function switch_tabs(evt, tab_id) {
            // Declare all variables
            var i, tabcontent, tablinks;

            // Get all elements with class="tabcontent" and hide them
            tabcontent = document.getElementsByClassName("FormTable");
            for (i = 0; i < tabcontent.length; i++) {
                tabcontent[i].style.display = "none";
            }

            // Get all elements with class="tablinks" and remove the class "active"
            tablinks = document.getElementsByClassName("tab");
            for (i = 0; i < tablinks.length; i++) {
                tablinks[i].className = tablinks[i].className.replace(" active", "");
            }

            // Show the current tab, and add an "active" class to the button that opened the tab
            document.getElementById(tab_id).style.display = "inline-table";
            evt.currentTarget.className += " active";
        }

        function reload_Soft_Center() {
            location.href = "/Module_Softcenter.asp";
        }

        function parseVersion(versionString) {
            const [major, branch, patch] = versionString.replace(/^v/, '').split('.').map(Number);
            return { major, branch, patch };
        }

        function compareVersions(version1, version2) {
            const v1 = parseVersion(version1);
            const v2 = parseVersion(version2);

            if (v1.major !== v2.major) {
                return 0; // major_version 必须一致：否则就是下载安装包错误了
            } else if (v1.branch !== v2.branch) {
                return v1.branch - v2.branch; // minor_version  新功能、重大升级会变更此版本号
            } else {
                return v1.patch - v2.patch;  // hotfix_version 小版本修复,变更频繁。
            }
        }

        function vclash_version_check() {
            // 更新vClash 检测
            $j.ajax({
                url: 'https://api.github.com/repos/vxiaov/vclash/tags',
                type: 'GET',
                async: true,
                cache: false,
                retries: 0,
                dataType: 'json',
                success: function(res) {
                    if (typeof(res) != "undefined" && res.length > 0) {
                        var obj = res[0];
                        var ver_res = compareVersions(obj.name, dbus["clash_vclash_version"]);
                        console.log(ver_res,dbus["clash_vclash_version"],obj);
                        if (ver_res > 0 ) {
                            $j("#clash_vclash_version_status").html("当前版本：<i>" + dbus["clash_vclash_version"] + "</i>，发现新版本：<b>" + obj.name + "</b>");
                            dbus["clash_vclash_new_version"] = obj.name;
                            $j("#clash_vclash_install_show").show();
                        } else {
                            $j("#clash_vclash_version_status").html("<i>当前版本：" + dbus["clash_vclash_version"] + "，已是最新版本。</i>");
                            $j("#clash_vclash_install_show").hide();
                        }
                    }
                },
                error: function(res) {
                    $j("#clash_vclash_version_status").html("<i>当前版本：" + dbus["clash_vclash_version"] + "，已是最新版本。</i>");
                }
            }).fail(() => {
                console.log('failed');
            });
        }
        function clash_core_version_check() {
            // 更新 Clash Meta 检测
            $j("#clash_version_status").html("<i>当前版本：" + dbus['clash_version']  + "</i>");
            $j.ajax({
                url: 'https://api.github.com/repos/MetaCubeX/mihomo/tags',
                type: 'GET',
                async: true,
                cache: false,
                retries: 0,
                dataType: 'json',
                success: function(res) {
                    if (typeof(res) != "undefined" && res.length > 0) {
                        var obj = res[0];
                        var ver_res = compareVersions(obj.name, dbus["clash_version"]);
                        console.log(ver_res,dbus["clash_version"],obj);
                        if (ver_res > 0 ) {
                            $j("#clash_version_status").html("当前版本：<i>" + dbus["clash_version"] + "</i>，发现新版本：<b>" + obj.name + "</b>");
                            dbus["clash_new_version"] = obj.name;
                            $j("#clash_install_show").show();
                        } else {
                            $j("#clash_version_status").html("<i>当前版本：" + dbus["clash_version"] + "，已是最新版本。</i>");
                            $j("#clash_install_show").hide();
                        }
                    }
                },
                error: function(res) {
                    $j("#clash_version_status").html("<i>当前版本：" + dbus["clash_version"] + "，已是最新版本。</i>");
                }
            }).fail(() => {
                console.log('failed');
            });
        }


        /*********************主要功能逻辑模块实现**************/
        // flag: 0:提交任务并查看日志，1:提交任务3秒后刷新页面, 2:提交任务后无特殊操作(可指定callback回调函数),3:提交任务执行完毕后在调用回调函数
        function apply_action(action, flag, callback, ret_data) {
            if (!action) {
                return;
            }
            // 如果只需要某个参数，就没必要提交所有dbus数据，参数传递过多也是会有速度影响的。
            if (!ret_data) {
                ret_data = dbus;
            }
            post_dbus_data("clash_control.sh", action, ret_data, flag, callback);
        }

        function service_stop() {
            apply_action("stop", "0", null, {
                "clash_enable": dbus["clash_enable"],
            });
        }

        function service_start() {

            // 由于 start 需要先确保执行成功后再返回执行结果,因此先设置等待状态图片显示，然后再执行 start 操作。
            $j("#loadingIcon").show();
            apply_action("start", "0", function(data) {
                // 更新dbus数据中的 clash_enable 状态 on/off
                dbus = data;
                conf2obj();
            }, {
                "clash_enable": dbus["clash_enable"],
                "clash_switch_config": dbus["clash_switch_config"],
                "clash_core_current" : E("clash_switch_core").value,
            });
        }

        function switch_service() {
            if (document.getElementById('clash_enable').checked) {
                dbus["clash_enable"] = "on";
                dbus["clash_core_current"] = E("clash_switch_core").value;
                service_start();
            } else {
                dbus["clash_enable"] = "off";
                service_stop();
            }
        }
        function set_log_type() {
            // 界面切换日志弹出框模式
            if (dbus["clash_log_type"] == "on") {
                //开启日志弹出框模式
                $j("#logMsg").hide();
                $j("#logBackup").show();
            } else {
                //关闭日志弹出框模式
                $j("#logMsg").show();
                $j("#logBackup").hide();
            }
        }
        //切换日志弹出框模式
        function switch_log_type() {
            if (document.getElementById('clash_log_type').checked) {
                dbus["clash_log_type"] = "on";
            } else {
                dbus["clash_log_type"] = "off";
            }
            apply_action("set_log_type", "2", set_log_type, {
                "clash_log_type": dbus["clash_log_type"]
            });
        }

        // 根据 ipv6_mode 开关决定显示 ipv6_dns[12]
        function switch_ipv6_dns() {
            if (document.getElementById('clash_ipv6_mode').checked) {
                // 开启 ipv6支持
                document.getElementById("clash_ipv6_dns1").style.display = "";
                document.getElementById("clash_ipv6_dns2").style.display = "";
            } else {
                document.getElementById("clash_ipv6_dns1").style.display = "none";
                document.getElementById("clash_ipv6_dns2").style.display = "none";
            }
        }

        // 切换支持ipv6模式
        function switch_ipv6_mode() {
            if (document.getElementById('clash_ipv6_mode').checked) {
                dbus["clash_ipv6_mode"] = "on";
            } else {
                dbus["clash_ipv6_mode"] = "off";
            }
            switch_ipv6_dns();
            apply_action("switch_ipv6_mode", "0", set_log_type, {
                "clash_ipv6_mode": dbus["clash_ipv6_mode"]
            });
        }

        function switch_trans_mode() { //切换透明代理模式，开关
            if (document.getElementById('clash_trans').checked) {
                dbus["clash_trans"] = "on";
            } else {
                dbus["clash_trans"] = "off";
            }
            apply_action("switch_trans_mode", "0", null, {
                "clash_trans": dbus["clash_trans"]
            });
        }

        function get_proc_status() { // 查看服务运行状态
            apply_action("get_proc_status", "0", null, {});
        }

        function update_geoip() { // 更新GeoIP
            dbus["clash_geoip_url"] = document.getElementById("clash_geoip_url").value;
            
            apply_action("update_geoip", "0", null, {
                "clash_geoip_url": document.getElementById("clash_geoip_url").value,
            });
        }

        function update_lan_ipv6_ports() {
            dbus["clash_lan_ipv6_ports"] = document.getElementById("clash_lan_ipv6_ports").value;

            apply_action("update_lan_ipv6_ports", "0", null, {
                "clash_lan_ipv6_ports": document.getElementById("clash_lan_ipv6_ports").value,
            });
        }

        function update_default_dns() {
            dbus["clash_ipv4_dns1"] = document.getElementById("clash_ipv4_dns1").value;
            dbus["clash_ipv4_dns2"] = document.getElementById("clash_ipv4_dns2").value;
            dbus["clash_ipv6_dns1"] = document.getElementById("clash_ipv6_dns1").value;
            dbus["clash_ipv6_dns2"] = document.getElementById("clash_ipv6_dns2").value;
            apply_action("update_default_dns", "0", null, {
                "clash_ipv4_dns1": document.getElementById("clash_ipv4_dns1").value,
                "clash_ipv4_dns2": document.getElementById("clash_ipv4_dns2").value,
                "clash_ipv6_dns1": document.getElementById("clash_ipv6_dns1").value,
                "clash_ipv6_dns2": document.getElementById("clash_ipv6_dns2").value,
            });
        }

        // 删除文件
        function remove_file(file_path) {
            apply_action("remove_file", "3", function(data){
                // update data
                 show_result('已经删除文件:' + file_path, 1000);
            }, {
                "clash_remove_file": file_path, // 相对路径
            });
        }

        function remove_config_file() {
            var opt = document.getElementById("clash_switch_config");
            remove_file(opt.value);
            var selectedIndex = opt.selectedIndex;
            if (selectedIndex !== -1) {
                opt.remove(selectedIndex);
            }
            // 手动触发 change 事件
            opt.dispatchEvent(new Event('change'));
        }
        function remove_core_file() {
            var opt = document.getElementById("clash_switch_core");
            remove_file(opt.value);
            var selectedIndex = opt.selectedIndex;
            if (selectedIndex !== -1) {
                opt.remove(selectedIndex);
            }
            // 手动触发 change 事件
            opt.dispatchEvent(new Event('change'));
        }

        function ignore_vclash_new_version() {
            // 忽略提示
            apply_action("ignore_vclash_new_version", "3", function(data) {
                dbus["clash_vclash_version"] = data["clash_vclash_version"];
                vclash_version_check();
            }, {
                "clash_vclash_new_version": dbus["clash_vclash_new_version"]
            });
        }
        function ignore_core_new_version() {
            // 忽略提示
            apply_action("ignore_core_new_version", "3", function(data) {
                dbus["clash_version"] = data["clash_version"];
                clash_core_version_check();
            }, {
                "clash_new_version": dbus["clash_new_version"]
            });
        }
        function update_core_bin() {
            // 更新 clash core 内核到最新版本
            apply_action("update_clash_bin", "3", function(data){
                dbus["clash_version"]  = data["clash_version"];
            }, {
                "clash_new_version": dbus["clash_new_version"],
            });
        }

        function update_vclash_bin() {
            
            // 更新 vClash 至最新版本,更新后刷新页面:更新了Module_clash.asp页面需要重新加载
            apply_action("update_vclash_bin", "3", function(data) {
                dbus["clash_vclash_version"] = data["clash_vclash_version"];
            }, {
                "clash_vclash_new_version": dbus["clash_vclash_new_version"],
            });
        }

        function show_router_info() {
            apply_action("show_router_info", "0", null, {});
        }

        // 备份配置文件
        function backup_config_file() {
            apply_action("backup_config_file", "0", function() {
                show_result("备份配置文件成功，请到下载本地目录查看");
                window.location = "/_temp/clash_backup.tar.gz"
            }, {});

        }

        // 恢复配置信息的压缩包文件
        function restore_config_file() {
            var filename = $j("#restore_file").val();
            filename = filename.split('\\');
            if (filename == "") {
                alert("请选择需要恢复的文件");
                return false;
            }
            filename = filename[filename.length - 1];
            var filelast = filename.split('.');
            filelast = filelast[filelast.length - 1];
            if (filelast != 'gz') {
                alert('压缩包文件格式不正确!');
                return false;
            }
            document.getElementById('status_info').style.display = "none";
            var formData = new FormData();
            formData.append(filename, $j('#restore_file')[0].files[0]);
            $j.ajax({
                url: '/_upload',
                type: 'POST',
                cache: false,
                data: formData,
                processData: false,
                contentType: false,
                complete: function(res) {
                    if (res.status == 200) {
                        show_result("已上传成功! 3秒后重启服务...", 3000);
                        dbus["clash_restore_file"] = filename;
                        apply_action("restore_config_file", "0", function() {
                            show_result("数据恢复完毕!3秒后自动刷新页面...", 3000);
                            setTimeout(() => {
                                refreshpage(3);
                            }, 3000)
                        }, {
                            "clash_restore_file": filename
                        });
                    }
                },
                error: function(res) {
                    show_result("上传失败，请检查文件是否存在！", 3000);
                }
            });
        }

        // 上传 config.yaml 文件
        function upload_config_file() {
            var filename = $j("#file").val();
            if (filename == "") {
                alert("请选择需要上传的文件");
                return false;
            }
            filename = filename.split('\\');
            filename = filename[filename.length - 1];
            var filelast = filename.split('.');
            filelast = filelast[filelast.length - 1];
            if (filelast != 'yaml' && filelast != 'yml') {
                alert('Yaml文件格式不正确,非yaml/yml后缀名！');
                return false;
            }
            document.getElementById('status_info').style.display = "none";
            var formData = new FormData();
            formData.append(filename, $j('#file')[0].files[0]);
            $j.ajax({
                url: '/_upload',
                type: 'POST',
                cache: false,
                data: formData,
                processData: false,
                contentType: false,
                complete: function(res) {
                    if (res.status == 200) {
                        show_result("已上传成功! 3秒后重启服务...", 3000);
                        dbus["clash_config_file"] = filename;
                        apply_action("applay_new_config", "0", function() {
                            show_result("上传新配置成功", 3000);
                        }, {
                            "clash_config_file": filename
                        });
                    }
                },
                error: function(res) {
                    show_result("上传失败，请检查文件是否存在！", 3000);
                }
            });
        }

        // 上传 clash 文件
        function upload_clash_file() {
            var filename = $j("#clash_file").val();
            if (filename == "") {
                alert("请选择需要上传的文件");
                return false;
            }
            filename = filename.split('\\');
            filename = filename[filename.length - 1];
            var filelast = filename.split('.');
            filelast = filelast[filelast.length - 1];
            if (filelast != 'gz') {
                alert('请上传gz后缀名的文件！');
                return false;
            }
            document.getElementById('status_info').style.display = "none";
            var formData = new FormData();
            formData.append(filename, $j('#clash_file')[0].files[0]);
            $j.ajax({
                url: '/_upload',
                type: 'POST',
                cache: false,
                data: formData,
                processData: false,
                contentType: false,
                complete: function(res) {
                    if (res.status == 200) {
                        dbus["clash_bin_file"] = filename;
                        apply_action("upload_clash_file", "0", function() {
                            show_result("上传Clash内核文件 " + filename + " 成功，手动刷新页面.", 3000);
                        }, {
                            "clash_bin_file": filename
                        });
                    }
                },
                error: function(res) {
                    show_result("上传失败，请检查文件是否存在！", 3000);
                }
            });
        }

        // 切换 clash 启动配置文件
        function switch_clash_config() {
            apply_action("switch_clash_config", "3", function(data) {
                E("clash_yacd_ui").href = data['clash_yacd_ui'];
                show_result("切换为" + dbus["clash_config_filepath"] + "配置文件", 1000);
            }, {
                "clash_config_filepath" : dbus["clash_config_filepath"]
            });
        }

        // 加载config文件内容
        function load_config_content() {
            var config = dbus['clash_edit_filecontent'];
            if (config == "" || config == undefined) {
                return false;
            }
            // 解析base64编码的config文件内容
            var content = Base64.decode(config);
            if (content == "") {
                show_result("解码失败,请检查config文件是否丢失啦?");
                return false;
            }
            $j("#edit_file_content").val(content);
            show_result("重新加载内容完成!", 1000);
        }

        // 获取Clash内核文件列表
        function list_clash_core() {
            apply_action("list_clash_core", "2", function(data) {
                dbus["clash_core_list"] = data.clash_core_list;
                update_clash_core_list();
            }, {});
        }
        // 获取编辑文件列表
        function list_config_files() {
            apply_action("list_config_files", "2", function(data) {
                dbus["clash_edit_filelist"] = data.clash_edit_filelist
                update_edit_filelist();
            }, {});
        }

        // 初始化配置clash运行环境变量
        function clash_config_init() {
            apply_action("clash_config_init", "2", function(data) {
                dbus = data;
                conf2obj();
                // vclash_version_check();
                // clash_core_version_check();
            }, {});
        }

        // 保存config文件内容
        function save_config_content() {
            var content = $j("#edit_file_content").val();
            if (content == "") {
                // alert("config.yaml文件内容不能为空哦!");
                return false;
            }
            var base64_content = Base64.encode(content);

            if (base64_content == "") {
                // alert("编码失败，请检查内容是否包含特殊内容.");
                return false;
            }
            // 检查是否变化
            if (base64_content == dbus['clash_edit_filecontent']) {
                show_result("内容无变化,不用保存了。", 1000);
                return false;
            }
            dbus["clash_edit_filecontent"] = base64_content;
            apply_action("set_one_file", "0", function() {
                show_result("保存文件内容成功!");
            }, {
                "clash_edit_filecontent": base64_content,
                "clash_edit_filepath": $j("#clash_edit_filelist").val()
            });
            // 设置readonly属性为true
            $j("#edit_file_content").attr("readonly", true);
        }

        // 编辑config文件内容
        function edit_config_content() {
            $j("#edit_file_content").attr("readonly", false);
            $j("#edit_file_content").focus();
            show_result("开始编辑文件!")
        }


        function set_edit_content(data) {
            // 解码base64格式的 data.clash_edit_filecontent
            var filecontent = Base64.decode(data.clash_edit_filecontent);
            if (filecontent == "") {
                // 文件内容为空
                console.log("文件内容为空");
                return false;
            }
            // 设置当前textarea的内容为 file_content
            dbus["clash_edit_filecontent"] = data.clash_edit_filecontent;
            $j("#edit_file_content").val(filecontent);
            show_result(dbus["clash_edit_filepath"] + "文件加载成功!", 1000);
        }

        function switch_edit_filecontent() {
            // 根据当前的选择，切换新的文件内容
            list_config_files();
            dbus["clash_edit_filepath"] = $j("#clash_edit_filelist").val();
            apply_action("get_one_file", "2", set_edit_content, {
                "clash_edit_filepath": $j("#clash_edit_filelist").val()
            });
        }


        function fallbackCopyTextToClipboard(text) {
            var textArea = document.createElement("textarea");
            textArea.value = text;

            // Avoid scrolling to bottom
            textArea.style.top = "0";
            textArea.style.left = "0";
            textArea.style.position = "fixed";

            document.body.appendChild(textArea);
            textArea.focus();
            textArea.select();

            try {
                var successful = document.execCommand('copy');
                if (successful) {
                    // jquery 设置 #status_info 1秒后慢慢消失
                    show_result('已复制到剪贴板', 1000);
                } else {
                    alert('复制失败！');
                }

                var msg = successful ? 'successful' : 'unsuccessful';
                console.log('Fallback: Copying text command was ' + msg);
            } catch (err) {
                console.error('Fallback: Oops, unable to copy', err);
            }

            document.body.removeChild(textArea);
        }

        function copyTextToClipboard(text) {
            // 确保 textarea 有内容
            if (!text) {
                alert('没有可复制的内容！');
                return;
            }
            if (!navigator.clipboard) {
                fallbackCopyTextToClipboard(text);
                return;
            }
            navigator.clipboard.writeText(text).then(function() {
                show_result('已复制到剪贴板', 1000);
                console.log('Async: Copying to clipboard was successful!');
            }, function(err) {
                console.error('Async: Could not copy text: ', err);
            });
        }

        function copyURI(evt) {
            evt.preventDefault();
            copyTextToClipboard(evt.target.getAttribute('href'))
        }
        function copyTextLog() {
            const textarea = document.getElementById('clash_text_log');
            copyTextToClipboard(textarea.value)
        }
        function copyLogMsg() {
            const textarea = document.getElementById('clash_log_msg');
            copyTextToClipboard(textarea.value)
        }
        function copyTextBakLog() {
            const textarea = document.getElementById('clash_log_backup');
            copyTextToClipboard(textarea.value)
        }
    </script>
</head>

<body onload="init();">
    <div id="TopBanner"></div>
    <div id="Loading" class="popup_bg"></div>
    <iframe name="hidden_frame" id="hidden_frame" src="" width="0" height="0" frameborder="0"></iframe>
    <!-- 主要页面内容定义-->
    <table class="content" align="center" cellpadding="0" cellspacing="0">
        <tr>
            <td width="17">&nbsp;</td>
            <td valign="top" width="202">
                <div id="mainMenu"></div>
                <div id="subMenu"></div>
            </td>
            <td valign="top">
                <div id="tabMenu" class="submenuBlock"></div>
                <div class="apply_gen FormTitle">
                    <div class="clash_top" style="padding-top: 20px;">
                        <div class="formfonttitle" ><a class="links" target="_blank" href="https://github.com/vxiaov/vClash">vClash</a>:配置简单、安装即用。
                            <img id="return_btn" onclick="reload_Soft_Center();" class="softcenterRetBtn" title="返回软件中心""></img>
                        </div>
                    </div>
                    <div class="clash_basic_info">
                        <!--插件特点-->
                        <p style="color:#FC0;">
                            <b style="color: rgb(255, 26, 26);">* 问题反馈:</b>点击<a class="links" href="https://github.com/vxiaov/vClash/issues" target="_blank">Issue</a>，提交<b>"路由信息"</b>。<br />
                            <b>* DNS污染问题解决：</b>支持修改默认DNS功能，可以更换默认DNS啦。<br/>
                            <b>* 破U盘再利用</b><b style="color: red;">(必须要做):</b>具体方法请阅读<a class="links" href="https://github.com/vxiaov/vClash/wiki/U%E7%9B%98%E6%8C%82%E8%BD%BD%E8%B7%AF%E7%94%B1%E5%99%A8%E7%9A%84%E4%BD%BF%E7%94%A8%E6%96%B9%E6%B3%95%E6%80%BB%E7%BB%93">wiki文档</a>了解。<br />
                        </p>
                        <div style="margin:8px;">
                            <a class="links" href="https://vlike.work/" target="_blank ">小V的博客</a>
                            <a class="links" href="https://t.me/share_proxy_001" target="_blank ">Telegram群</a>
                            <a class="links" href="https://www.youtube.com/@xiaov" target="_blank ">小V的油管</a>
                        </div>
                        <hr>
                    </div>
                    <!-- Tab菜单 -->
                    <div class="tabs">
                        <button id="btn_default_tab" class="tab" onclick="switch_tabs(event, 'menu_default');list_clash_core();">主面板</button>
                        <button id="btn_config_tab" class="tab" onclick="switch_tabs(event, 'menu_config');switch_edit_filecontent();">在线编辑</button>
                        <button id="btn_option_tab" class="tab" onclick="switch_tabs(event, 'menu_options'); switch_ipv6_dns();">可选配置</button>
                        <button id="btn_log_tab" class="tab" onclick="switch_tabs(event, 'menu_log');">日志信息</button>
                        <button id="btn_help_tab" class="tab" onclick="switch_tabs(event, 'menu_help');">自助学习</button>
                    </div>

                    <!-- 默认设置Tab -->
                    <table id="menu_default" class="FormTable">
                        <thead width="100%">
                            <tr>
                                <td colspan="3">Clash - 设置面板</td>
                            </tr>
                        </thead>
                        <tr>
                            <th>
                                <label>开启vClash</label>
                            </th>
                            <td colspan="2">
                                <div class="switch_field">
                                    <label for="clash_enable">
                                        <input id="clash_enable" onclick="switch_service();" class="switch" type="checkbox" style="display: none;">
                                        <div class="switch_container">
                                            <div class="switch_bar"></div>
                                            <div class="switch_circle transition_style"></div>
                                        </div>
                                    </label>
                                </div>
                            </td>
                        </tr>
                        <tr>
                            <th>订阅配置:</th>
                            <td>
                                <input type="text" class="input_text" id="clash_config_http" placeholder="http(s)订阅配置">
                            </td>
                            <td>
                                <a class="button_gen" onclick="add_config_http();" href="javascript:void(0);">添加订阅</a>
                            </td>
                        </tr>
                        <tr>
                            <th>启动配置: </th>
                            <td>
                                <div class="switch_field">
                                    <select id="clash_switch_config" class="input_option" style="width:260px;margin:0px 0px 0px 2px;"></select>
                                </div>
                            </td>
                            <td>
                                <input style="display:none;" id="file" type="file" name="file">
                                <a class="button_gen" onclick="document.getElementById('file').click();" href="javascript:void(0);">上传(.yaml)</a>
                                <a class="button_gen" onclick="remove_config_file();" href="javascript:void(0);">删除</a>
                            </td>
                        </tr>
                        <tr>
                            <th>
                                <label>Clash内核(<b id="clash_arch_type"></b>):</label>
                            </th>
                            <td> <!-- Clash内核切换 -->
                                <div class="switch_field">
                                    <select id="clash_switch_core" class="input_option" style="width:260px;margin:0px 0px 0px 2px;"></select>
                                </div>
                            </td>
                            <td>
                                <input style="display:none;" id="clash_file" type="file" name="clash_file">
                                <a class="button_gen" onclick="document.getElementById('clash_file').click();" href="javascript:void(0);">上传(.gz格式)</a>
                                <a class="button_gen" onclick="remove_core_file();" href="javascript:void(0);">删除</a>
                            </td>
                        </tr>
                        <tr>
                            <th>
                                <label>Clash内核版本:</label>
                            </th>
                            <td>
                                <div id="clash_version_status"><i>正在获取...</i></div>
                                <div id="clash_install_show" style="display: none;">
                                    <a class="button_gen" onclick="ignore_core_new_version()" href="javascript:void(0);">忽略</a>
                                    &nbsp;&nbsp;&nbsp;&nbsp;
                                    <a class="button_gen" onclick="update_core_bin()" href="javascript:void(0);">更新</a>
                                </div>
                            </td>
                            <td>
                                    <a class="button_gen" onclick="clash_core_version_check();" href="javascript:void(0);">检查更新</a>
                            </td>
                        </tr>
                        <tr>
                            <th>
                                <label>vClash版本:</label>
                            </th>
                            <td>
                                <div id="clash_vclash_version_status"><i>正在获取...</i></div>
                                <div id="clash_vclash_install_show" style="display: none;">
                                    <a class="button_gen" onclick="ignore_vclash_new_version()" href="javascript:void(0);">忽略</a> &nbsp;&nbsp;&nbsp;&nbsp;
                                    <a class="button_gen" onclick="update_vclash_bin()" href="javascript:void(0);">更新</a>
                                </div>
                            </td>
                            <td>
                                    <a class="button_gen" onclick="vclash_version_check()" href="javascript:void(0);">检查更新</a>
                            </td>
                        </tr>
                    </table>
                    <!-- 可选配置信息 -->
                    <table id="menu_options" class="FormTable">
                        <thead>
                            <tr>
                                <td colspan="3">Clash - 可选配置</td>
                            </tr>
                        </thead>
                        <tr>
                            <th>
                                <label title="默认开启，开启此模式后内网无任何配置即可科学上网。&#010;如果只想使用clash提供的socks5代理,可关闭此选项。">透明代理模式</label>
                            </th>
                            <td colspan="2">
                                <div class="switch_field">
                                    <label for="clash_trans">
                                        <input id="clash_trans" onclick="switch_trans_mode();" class="switch" type="checkbox" style="display: none;">
                                        <div class="switch_container">
                                            <div class="switch_bar"></div>
                                            <div class="switch_circle transition_style"></div>
                                        </div>
                                    </label>
                                </div>
                            </td>
                        </tr>
                        <tr>
                            <th>
                                <label title="默认关闭，如果有公网IPv6地址，可开启此选项。">支持IPv6模式</label>
                            </th>
                            <td colspan="2">
                                <div class="switch_field">
                                    <label for="clash_ipv6_mode">
                                        <input id="clash_ipv6_mode" onclick="switch_ipv6_mode();" class="switch" type="checkbox" style="display: none;">
                                        <div class="switch_container">
                                            <div class="switch_bar"></div>
                                            <div class="switch_circle transition_style"></div>
                                        </div>
                                    </label>
                                </div>
                            </td>
                        </tr>
                        <tr>
                            <th>
                                <label title="用于外网访问内网IPv6地址主机放行规则">开放IPv6访问端口</label>
                            </th>
                            <td>
                                <input type="text" class="input_text" id="clash_lan_ipv6_ports" placeholder="22,80,443">
                            </td>
                            <td class="hasButton">
                                <button type="button" class="button_gen" onclick="update_lan_ipv6_ports();" href="javascript:void(0);">更新</button>
                            </td>
                        </tr>
                        <tr>
                            <th><label title="DNS修改只是临时生效，重启后恢复运营商的DNS">默认DNS</label></th>
                            <td>
                                <div class="switch_field">
                                    <select id="clash_ipv4_dns1" class="input_option" style="width:300px;margin:0px 0px 0px 2px;"></select>
                                    <select id="clash_ipv4_dns2" class="input_option" style="width:300px;margin:0px 0px 0px 2px;"></select>
                                    <select id="clash_ipv6_dns1" class="input_option" style="display:none;width:300px;margin:0px 0px 0px 2px;"></select>
                                    <select id="clash_ipv6_dns2" class="input_option" style="display:none;width:300px;margin:0px 0px 0px 2px;"></select>
                                </div>
                            </td>
                            <td class="hasButton"><button type="button" class="button_gen" onclick="update_default_dns();" href="javascript:void(0);">更新DNS</button></td>
                        </tr>
                        <tr>
                            <th>
                                <label title="更新频率不高." class="hintstyle">Country.mmdb文件</label>
                            </th>
                            <td>
                                <div class="switch_field">
                                    <select id="clash_geoip_url" class="input_option" style="width:300px;margin:0px 0px 0px 2px;"></select>
                                </div>
                            </td>
                            <td class="hasButton">
                                <button type="button" class="button_gen" onclick="update_geoip();" href="javascript:void(0);">更新</button>
                            </td>
                        </tr>
                        <tr>
                            <th>
                                <label title="包括:环境变量、自定义providers、自定义rules等。不包括: clash内核文件和网络自动下载的文件">备份配置</label>
                            </th>
                            <td colspan="2">
                                <input type="button" class="button_gen" onclick="backup_config_file();" value="开始备份">
                            </td>
                        </tr>
                        <tr>
                            <th>
                                <label title=">提示：上传.gz后缀格式备份文件。">恢复配置</label>
                            </th>
                            <td colspan="2">
                                <input style="display:none;" id="restore_file" type="file" name="file">
                                <input type="button" class="button_gen" onclick="document.getElementById('restore_file').click();" value="恢复配置">
                            </td>
                        </tr>
                    </table>
                    <!-- 在线编辑配置文件内容 -->
                    <table id="menu_config" class="FormTable">
                        <thead>
                            <tr>
                                <td colspan="3">Clash - 配置文件编辑</td>
                            </tr>
                        </thead>
                        <!-- 编辑文件选择操作 -->
                        <tr>
                            <th>编辑文件</th>
                            <td>
                                <div class="switch_field">
                                    <select id="clash_edit_filelist" class="input_option" style="width:300px;margin:0px 0px 0px 2px;"></select>
                                </div>
                            </td>
                        </tr>
                        <tr>
                            <td colspan="2">
                                <textarea id="edit_file_content" readonly="true" rows="20" class="input_text" style="width: 98%;" title="为了防止误编辑，默认为只读，点击编辑后才可修改哦！&#010;快捷键Ctrl+S: 保存.&#010;快捷键Ctrl+E: 编辑.&#010;快捷键Ctrl+R: 重新加载。"></textarea>
                            </td>
                        </tr>
                        <tr>
                            <td colspan="2" style="text-align: center;">
                                <a class="button_gen" onclick="edit_config_content(); " href="javascript:void(0); ">编辑</a> &nbsp;&nbsp;&nbsp;
                                <a class="button_gen" onclick="set_edit_content(); " href="javascript:void(0); ">保存</a> &nbsp;&nbsp;&nbsp;
                                <a class="button_gen" onclick="load_config_content(); " href="javascript:void(0); ">重载</a>
                            </td>
                        </tr>
                        <tr>
                            <td colspan="2">
                                <p style="color: rgb(182, 222, 2);"><br/></p>
                                <p style="color: rgb(248, 5, 62);">&nbsp;&nbsp;&nbsp;&nbsp;编辑快捷键: Ctrl+E: <b>开始编辑</b> Ctrl+S: <b>保存</b> Ctrl+R: <b>重新加载</b><br/>&nbsp;&nbsp;&nbsp;&nbsp; Ctrl+C:<b>复制</b> Ctrl+V:<b>粘帖</b>  Ctrl+Z: <b>撤销(undo)</b> Ctrl+Shift+Z: <b>重做(redo)</b></p>
                                <p style="color: rgb(248, 5, 62);">&nbsp;&nbsp;&nbsp;&nbsp; <b>保存失败？</b>文件太大就会如此，可以先本地编辑，然后通过  可选配置页 -> 上传启动配置 上传覆盖配置。</p>
                            </td>
                        </tr>
                    </table>
                    <!-- 帮助信息 -->
                    <table id="menu_help" class="FormTable">
                        <thead>
                            <tr>
                                <td>vClash - 使用帮助</td>
                            </tr>
                        </thead>
                        <tr>
                            <td>
                                <div style="text-align: left; color: rgb(32, 252, 32); font-size: 18px;padding-top: 10px;padding-bottom: 10px;">使用说明：</div>
                                <div style="padding-top: 5px;" >&nbsp;&nbsp;&nbsp;&nbsp;<b style="color: rgb(248, 5, 62);">1. 插件的兼容性</b>: 透明代理模式可能会与<b style="color: rgb(248, 5, 62);">其他代理插件冲突</b> ，使用前要关闭其他透明代理插件。</div>
                                <div style="padding-top: 5px;">&nbsp;&nbsp;&nbsp;&nbsp;<b style="color: rgb(32, 252, 32);">2. 学习vClash插件用法</b>: <a class="button_gen" target="_blank" href="https://github.com/vxiaov/vClash/wiki">vClash介绍</a></div>
                                <div style="padding-top: 5px;">&nbsp;&nbsp;&nbsp;&nbsp;<b style="color: rgb(32, 252, 32);">3. Clash配置规则</b>: <a class="button_gen" target="_blank" href="https://wiki.metacubex.one/config/">Meta文档</a></div>
                                <div style="padding-top: 5px;">&nbsp;&nbsp;&nbsp;&nbsp;<b style="color: rgb(32, 252, 32);">4. 可选Clash内核下载源</b>: <a class="button_gen" target="_blank" href="https://github.com/MetaCubeX/mihomo/releases">Clash Meta</a></div>
                                <span style="text-align:left;">
                                    1. 全量GeoIP版本(6MB左右)<a class="copyToClipboard"  href="https://github.com/Dreamacro/maxmind-geoip/raw/release/Country.mmdb" onclick="copyURI(event)">点击复制</a> &nbsp;&nbsp;  <a style="color:chartreuse" href="https://github.com/Dreamacro/maxmind-geoip" target="_blank" rel="noopener noreferrer">Github地址</a> <br>
                                    2. 精简版(200KB左右，默认使用)<a class="copyToClipboard" href="https://github.com/Hackl0us/GeoIP2-CN/raw/release/Country.mmdb" onclick="copyURI(event)">点击复制</a> &nbsp;&nbsp;  <a style="color: chartreuse;" href="https://github.com/Hackl0us/GeoIP2-CN" target="_blank" rel="noopener noreferrer">Github地址</a><br>
                                    3. <b>(推荐)</b>全量多源合并版(6MB左右)<a class="copyToClipboard" href="https://raw.githubusercontent.com/alecthw/mmdb_china_ip_list/release/Country.mmdb" onclick="copyURI(event)">点击复制</a> &nbsp;&nbsp; <a style="color: chartreuse;" href="https://github.com/alecthw/mmdb_china_ip_list" target="_blank" rel="noopener noreferrer">Github地址</a> 
                                </span>
                            </td>
                        </tr>
                    </table>
                    <table id="menu_log" class="FormTable">
                        <thead>
                            <tr>
                                <td colspan="2">vClash - 日志</td>
                            </tr>
                        </thead>
                        <tr>
                            <th>日志弹窗模式</th>
                            <td>
                                <div class="switch_field">
                                    <label for="clash_log_type">
                                        <input id="clash_log_type" onclick="switch_log_type();" class="switch" type="checkbox" style="display: none;">
                                        <div class="switch_container">
                                            <div class="switch_bar"></div>
                                            <div class="switch_circle transition_style"></div>
                                        </div>
                                    </label>
                                </div>
                            </td>
                        </tr>
                        <tr id="logBackup">
                            <td colspan="2">
                                <input type="button" class="button_gen" onclick="copyTextBakLog();" value="复制日志">
                                <textarea rows="20 " wrap="off" readonly="readonly" id="clash_log_backup" class="input_text"></textarea>
                            </td>
                        </tr>
                    </table>
                    <!--打开 Clash控制面板-->
                    <div style="margin-top: 5px; padding-bottom: 10px;">
                        <a class="button_gen" onclick="get_proc_status(); " href="javascript:void(0); ">状态检查</a> &nbsp;&nbsp;&nbsp;
                        <a class="button_gen" onclick="show_router_info(); " href="javascript:void(0); ">路由信息</a> &nbsp;&nbsp;&nbsp;
                        <a class="button_gen" id="clash_yacd_ui"  href="javascript:void(0); " target="_blank">控制面板</a>
                    </div>

                    <div>
                        <div>
                            <img id="loadingIcon" style="display:none; " src="/images/loading.gif">
                            <!-- 显示动态消息 -->
                            <label id="status_info" style="display: none;color:#ffc800;font-size: 24px; "></label>
                        </div>
                    </div>
                    <div id="logMsg" style="display: none;">
                        <input type="button" class="button_gen" onclick="copyLogMsg();" value="复制日志">
                        <textarea rows="16" wrap="off" readonly="readonly" id="clash_log_msg" class="input_text"></textarea>
                    </div>

                    <div id="logArea" style="display: none; ">
                        <div>日志信息</div>
                        <input type="button" class="button_gen" onclick="copyTextLog();" value="复制日志">
                        <textarea rows="30 " wrap="off" readonly="readonly" id="clash_text_log" class="input_text"></textarea>
                        <a class="button_gen" id="btn_log_msg_close" onclick="close_log_msg(); " href="javascript:void(0); ">关闭(10秒后)</a>
                    </div>
            </td>
            <div class="author-info"></div>
        </tr>
    </table>
    <div id="footer"></div>
</body>
</html>