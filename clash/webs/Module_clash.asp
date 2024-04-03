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

        var $j = jQuery.noConflict();


        function init() {
            show_menu(menu_hook);
            clash_config_init(); // 初始化配置
            get_dbus_data();
            vclash_version_check();
            register_event();

            if (dbus["clash_current_tab"] == "" || dbus["clash_current_tab"] == undefined) {
                dbus["clash_current_tab"] = "btn_default_tab";
            }
            document.getElementById(dbus["clash_current_tab"]).click();
            // 
            // DEBUG: class 包含 debug 的标签设置为 隐藏
            for (var i = 0; i < document.getElementsByClassName("debug").length; i++) {
                document.getElementsByClassName("debug")[i].style.display = "none";
            }
            // 隐藏 class 包含 to_be_deleted 的标签
            for (var i = 0; i < document.getElementsByClassName("to_be_deleted").length; i++) {
                document.getElementsByClassName("to_be_deleted")[i].style.display = "none";
            }

        }

        function menu_hook(title, tab) {
            tabtitle[tabtitle.length - 1] = new Array("", "软件中心", "离线安装", "Clash版代理工具");
            tablink[tablink.length - 1] = new Array("", "Module_Softcenter.asp", "Module_Softsetting.asp", "Module_clash.asp");
        }

        // 加载页面时注册事件
        function register_event() {

            function bind_whitelist_keydown() {
                // 先解除已有绑定事件
                $j(this).unbind("keydown");
                $j(this).bind("keydown", function(e) {
                    // mac 绑定 command+s
                    if ((e.ctrlKey || e.metaKey) && e.keyCode == 83) {
                        e.preventDefault();
                        save_whitelist_rule();
                        return false;
                    }
                    // 绑定 ctrl+e 快捷键
                    if ((e.ctrlKey || e.metaKey) && e.keyCode == 69) {
                        e.preventDefault();
                        edit_whitelist_rule();
                        return false;
                    }
                    // 绑定 ctrl+r 快捷键
                    if ((e.ctrlKey || e.metaKey) && e.keyCode == 82) {
                        e.preventDefault();
                        load_whitelist_rule();
                        return false;
                    }
                });
            }
            // 当 #rule_diy_whitelist focus时，绑定ctrl+s快捷键
            $j("#rule_diy_whitelist").bind("focus", bind_whitelist_keydown);

            function bind_blacklist_keydown() {
                // 先解除已有绑定事件
                $j(this).unbind("keydown");
                $j(this).bind("keydown", function(e) {
                    if ((e.ctrlKey || e.metaKey) && e.keyCode == 83) {
                        e.preventDefault();
                        save_blacklist_rule();
                        return false;
                    }
                    // 绑定 ctrl+e 快捷键
                    if ((e.ctrlKey || e.metaKey) && e.keyCode == 69) {
                        e.preventDefault();
                        edit_blacklist_rule();
                        return false;
                    }
                    // 绑定 ctrl+r 快捷键
                    if ((e.ctrlKey || e.metaKey) && e.keyCode == 82) {
                        e.preventDefault();
                        load_blacklist_rule();
                        return false;
                    }
                });
            }
            // 当 #rule_diy_blacklist focus时，绑定ctrl+s快捷键
            $j("#rule_diy_blacklist").bind("focus", bind_blacklist_keydown);

            function unbind_whitelist_keydown() {
                // 先保存规则
                save_whitelist_rule();
                $j(this).unbind("keydown");
                // 设置当前textarea的readonly属性
                $j(this).attr("readonly", true);
            }
            // 当 #rule_diy_whitelist 离开焦点时， 取消绑定的keydown快捷键
            $j("#rule_diy_whitelist").bind("blur", unbind_whitelist_keydown);

            function unbind_blacklist_keydown() {
                // 先保存规则
                save_blacklist_rule();
                $j(this).unbind("keydown");
                // 设置当前textarea的readonly属性
                $j(this).attr("readonly", true);
            }

            // 当 #rule_diy_blacklist 失去焦点时， 取消绑定的keydown快捷键
            $j("#rule_diy_blacklist").bind("blur", unbind_blacklist_keydown);

            // #clash_config_content fucus时，绑定ctrl+s、ctrl+e、ctrl+r快捷键
            $j("#clash_config_content").bind("focus", function() {
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

            // #clash_config_content 失去焦点时，取消绑定的keydown快捷键
            $j("#clash_config_content").bind("blur", function() {
                // 先保存变更内容或者取消变更!
                var current_content = Base64.encode($j("#clash_config_content").val());
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

            function switch_rule_mode() {
                if ($j(this).val() == "blacklist") {
                    // 切换为黑名单模式
                    switch_blacklist_mode();
                } else if ($j(this).val() == "whitelist") {
                    // 切换为白名单模式
                    switch_whitelist_mode();
                }
            }
            // 当 #clash_rule_mode change时，触发事件
            $j("#clash_rule_mode").bind("change", switch_rule_mode);

            function bind_edit_filepath_change() {
                if ($j(this).val() == dbus["clash_edit_filepath"]) {
                    // 没有变化
                    return;
                } else {
                    // 切换为查看模式
                    switch_edit_filecontent();
                }
            }
            // 当 #clash_edit_filelist change时，触发事件
            $j("#clash_edit_filelist").bind("change", bind_edit_filepath_change);

            // class="tab"的button被点击时，触发保存当前button的id
            $j(".tab").bind("click", function() {
                // dbus["clash_current_tab"] = this.id;
                apply_action("save_current_tab", "2", null, {
                    "clash_current_tab": this.id,
                });
            });
        }

        function get_dbus_data() {
            $j.ajax({
                type: "GET",
                url: "/_api/clash",
                async: false,
                success: function(data) {
                    dbus = data.result[0];
                    conf2obj();
                }
            });
        }

        function yacd_ui_click_check() {
            // 点击 yacd 按钮时，检测 clash_enable 状态为 off时，弹出警告
            if (dbus["clash_enable"] == "off") {
                show_result("请先启用 clash，再进行 yacd 操作!");
                return false;
            }
        }

        function conf2obj() {

            var params = [
                'clash_geoip_url', 'clash_cfddns_email', 'clash_cfddns_domain', 'clash_cfddns_apikey',
                'clash_cfddns_ttl', 'clash_cfddns_ipv4', 'clash_cfddns_ipv6', 'clash_watchdog_soft_ip', 'clash_yacd_ui', 'clash_cfddns_switch', 'clash_watchdog_switch'
            ];
            var params_chk = [
                'clash_trans', 'clash_enable', 'clash_cfddns_enable', 'clash_ipv6_mode',
                'clash_watchdog_enable', 'clash_watchdog_start_clash', 'clash_log_type', 'clash_cfddns_switch', 'clash_watchdog_switch'
            ];
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
                        if (dbus[ params[i] ]) 
                            E(params[i]).href = dbus[params[i]];
                        break;
                    case 'clash_cfddns_switch':
                        // 判断是否启用#btn_ddns_tab tab页面
                        if (dbus[params[i]] == "on") {
                            $j("#btn_ddns_tab").show();
                        } else {
                            $j("#btn_ddns_tab").hide();
                        }
                        break;
                    case 'clash_watchdog_switch':
                        // 判断是否启用#btn_watchdog_tab tab页面
                        if (dbus[params[i]] == "on") {
                            $j("#btn_watchdog_tab").show();
                        } else {
                            $j("#btn_watchdog_tab").hide();
                        }
                        break;
                    default:
                        // 普通类型数据
                        if (dbus[ params[i] ]) 
                            E(params[i]).value = dbus[params[i]];
                        break;
                }
            }
            document.getElementById("clash_cfddns_lastmsg").innerHTML = dbus["clash_cfddns_lastmsg"];

            // 更新规则模式选项
            var obj = document.getElementById("clash_rule_mode");
            obj.options.length = 0;
            const node_arr = {
                "blacklist": "黑名单模式",
                "whitelist": "白名单模式",
            }

            for (var key in node_arr) {
                obj.options.add(new Option(node_arr[key], key));
            }
            obj.value = dbus["clash_rule_mode"];

            //更新#clash_edit_filelist 编辑文件选项
            update_edit_filelist();

            set_log_type(); //初始化日志类型
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
            $j('#copy_info').text(message);
            $j('#copy_info').fadeIn(100);
            $j('#copy_info').css('display', 'inline-block');
            setTimeout(() => {
                $j('#copy_info').fadeOut(1000);
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
            var time_sec = 5;
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

        function vclash_version_check() {
            // TODO: 更新vClash 检测
            $j("#clash_vclash_version_status").html("<i>当前版本：" + dbus['clash_vclash_version']  + "</i>");
            $j("#clash_version_status").html("<i>当前版本：" + dbus['clash_version'] + "</i>");
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
                        if (obj.name != dbus["clash_vclash_version"]) {
                            $j("#clash_vclash_version_status").html("<i>当前版本：" + dbus["clash_vclash_version"] + "，</i>有新版本：" + obj.name);
                            dbus["clash_vclash_new_version"] = obj.name;
                            $j("#clash_vclash_install_show").show();
                        } else {
                            $j("#clash_vclash_version_status").html("<i>当前版本：" + obj.name + "，已是最新版本。</i>");
                            $j("#clash_vclash_install_show").hide();
                        }
                    }
                },
                error: function(res) {
                    $j("#clash_vclash_version_status").html("访问最新版本信息失败!<i>当前版本：" + dbus["clash_vclash_version"] + "，已是最新版本。</i>");
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
                "clash_rule_mode": dbus["clash_rule_mode"]
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
                "clash_rule_mode": dbus["clash_rule_mode"]
            });
        }

        function switch_service() {
            if (document.getElementById('clash_enable').checked) {
                dbus["clash_enable"] = "on";
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

        // 切换cfddns模式tab页面功能
        function switch_cfddns_tab() {
            if (document.getElementById('clash_cfddns_switch').checked) {
                dbus["clash_cfddns_switch"] = "on";
                $j("#btn_ddns_tab").show();
            } else {
                dbus["clash_cfddns_switch"] = "off";
                $j("#btn_ddns_tab").hide();
            }
            apply_action("switch_option_tab", "2", null, {
                "clash_cfddns_switch": dbus["clash_cfddns_switch"]
            });
        }
        //切换watchdog模式tab页面功能
        function switch_watchdog_tab() {
            if (document.getElementById('clash_watchdog_switch').checked) {
                dbus["clash_watchdog_switch"] = "on";
                $j("#btn_watchdog_tab").show();
            } else {
                dbus["clash_watchdog_switch"] = "off";
                $j("#btn_watchdog_tab").hide();
            }
            apply_action("switch_option_tab", "2", null, {
                "clash_watchdog_switch": dbus["clash_watchdog_switch"]
            });
        }

        // 切换支持ipv6模式
        function switch_ipv6_mode() {
            if (document.getElementById('clash_ipv6_mode').checked) {
                dbus["clash_ipv6_mode"] = "on";
            } else {
                dbus["clash_ipv6_mode"] = "off";
            }
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

        function switch_cfddns_mode() { //启用cfddns
            if (document.getElementById('clash_cfddns_enable').checked) {
                dbus["clash_cfddns_enable"] = "on";
            } else {
                dbus["clash_cfddns_enable"] = "off";
            }
            
            if (document.getElementById('clash_cfddns_ipv6_enable').checked) {
                dbus["clash_cfddns_support_ipv6"] = "on";
            } else {
                dbus["clash_cfddns_support_ipv6"] = "off";
            }
            // 启用ipv6解析支持
            if (document.getElementById('clash_cfddns_proxy_enable').checked) {
                dbus["clash_cfddns_support_proxy"] = "on";
            } else {
                dbus["clash_cfddns_support_proxy"] = "off";
            }
            document.getElementById("clash_cfddns_enable").disabled = true;
            dbus["clash_cfddns_email"] = document.getElementById("clash_cfddns_email").value;
            dbus["clash_cfddns_apikey"] = document.getElementById("clash_cfddns_apikey").value;
            dbus["clash_cfddns_domain"] = document.getElementById("clash_cfddns_domain").value;
            dbus["clash_cfddns_ttl"] = document.getElementById("clash_cfddns_ttl").value;
            dbus["clash_cfddns_ipv4"] = document.getElementById("clash_cfddns_ipv4").value;
            dbus["clash_cfddns_ipv6"] = document.getElementById("clash_cfddns_ipv6").value;
            apply_action("save_cfddns", "0", null, {
                "clash_cfddns_enable": dbus["clash_cfddns_enable"],
                "clash_cfddns_support_ipv6": dbus["clash_cfddns_support_ipv6"],
                "clash_cfddns_email": dbus["clash_cfddns_email"],
                "clash_cfddns_apikey": dbus["clash_cfddns_apikey"],
                "clash_cfddns_domain": dbus["clash_cfddns_domain"],
                "clash_cfddns_ttl": dbus["clash_cfddns_ttl"],
                "clash_cfddns_ipv6": dbus["clash_cfddns_ipv6"],
                "clash_cfddns_ipv4": dbus["clash_cfddns_ipv4"],
                "clash_cfddns_support_proxy": dbus["clash_cfddns_support_proxy"],
            });
            document.getElementById("clash_cfddns_enable").disabled = false;
        }

        function switch_cfddns_ipv6_mode() {
            // 启用ipv6解析支持
            if (document.getElementById('clash_cfddns_ipv6_enable').checked) {
                $j("#clash_cfddns_ipv6").show();
            } else {
                $j("#clash_cfddns_ipv6").hide();
            }
        }

        function switch_route_watchdog() { //启用旁路由监控工具
            if (document.getElementById('clash_watchdog_enable').checked) {
                dbus["clash_watchdog_enable"] = "on";
            } else {
                dbus["clash_watchdog_enable"] = "off";
            }
            if (document.getElementById('clash_watchdog_start_clash').checked) {
                dbus["clash_watchdog_start_clash"] = "on";
            } else {
                dbus["clash_watchdog_start_clash"] = "off";
            }
            document.getElementById("clash_watchdog_enable").disabled = true;
            dbus["clash_watchdog_soft_ip"] = document.getElementById("clash_watchdog_soft_ip").value;
            apply_action("switch_route_watchdog", "0", null, {
                "clash_watchdog_enable": dbus["clash_watchdog_enable"],
                "clash_watchdog_start_clash": dbus["clash_watchdog_start_clash"],
                "clash_watchdog_soft_ip": dbus["clash_watchdog_soft_ip"]
            });
            document.getElementById("clash_watchdog_enable").disabled = false;
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


        function ignore_vclash_new_version() {
            // 忽略新版本提示
            apply_action("ignore_vclash_new_version", "3", function(data) {
                dbus["clash_vclash_version"] = data["clash_vclash_version"];
                vclash_version_check();
            }, {
                "clash_vclash_new_version": dbus["clash_vclash_new_version"]
            });
        }

        function update_vclash_bin() {
            // if (document.getElementById('clash_vclash_switch_cdn').checked) {
            //     dbus["clash_vclash_switch_cdn"] = "on";
            // } else {
            //     dbus["clash_vclash_switch_cdn"] = "off";
            // }
            dbus["clash_vclash_switch_cdn"] = "off";
            // 更新 vClash 至最新版本,更新后刷新页面:更新了Module_clash.asp页面需要重新加载
            apply_action("update_vclash_bin", "3", function(data) {
                dbus["clash_vclash_version"] = data["clash_vclash_version"];
            }, {
                "clash_vclash_new_version": dbus["clash_vclash_new_version"],
                "clash_vclash_switch_cdn" : dbus["clash_vclash_switch_cdn"]
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
            document.getElementById('copy_info').style.display = "none";
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
            document.getElementById('copy_info').style.display = "none";
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
                            show_result("应用新配置成功，3秒后重启服务...", 3000);
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
            document.getElementById('copy_info').style.display = "none";
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
                        show_result("已上传成功! 3秒后重启服务...", 3000);
                        dbus["clash_bin_file"] = filename;
                        apply_action("update_clash_file", "0", function() {
                            show_result("应用新配置成功，3秒后重启服务...", 3000);
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

        // 重新加载blacklist规则
        function reload_content() {
            apply_action("reload_content", "1");
        }

        // 解析base64编码的clash_blacklist_rules并加载blacklist规则
        function load_blacklist_rule() {

            var base64_rule = dbus['clash_blacklist_rules'];
            if (base64_rule == "" || base64_rule == undefined) {
                reload_content();
                return false;
            }
            var rule = Base64.decode(base64_rule);
            $j("#rule_diy_blacklist").val(rule);
        }

        // 解析base64编码的clash_whitelist_rules并加载whitelist规则
        function load_whitelist_rule() {
            var base64_rule = dbus['clash_whitelist_rules'];
            if (base64_rule == "" || base64_rule == undefined) {
                reload_content();
                return false;
            }
            var rule = Base64.decode(base64_rule);
            $j("#rule_diy_whitelist").val(rule);
        }

        // 保存黑名单规则
        function save_blacklist_rule() {
            var rule = $j("#rule_diy_blacklist").val();
            if (rule == "") {
                alert("请输入黑名单规则");
                return false;
            }
            var base64_rule = Base64.encode(rule);
            if (base64_rule == "") {
                alert("编码失败，请检查规则");
                return false;
            }
            // 检查是否变化
            if (base64_rule == dbus['clash_blacklist_rules']) {
                // show_result("黑名单规则未发生变化", 1000);
                return false;
            }
            dbus["clash_blacklist_rules"] = base64_rule;
            apply_action("save_blacklist_rule", "0", function() {
                show_result("保存黑名单规则成功!", 1000);
            });
            // 设置readonly属性为true
            $j("#rule_diy_blacklist").attr("readonly", true);
        }

        // 保存白名单规则
        function save_whitelist_rule() {
            var rule = $j("#rule_diy_whitelist").val();
            if (rule == "") {
                alert("请输入白名单规则");
                return false;
            }
            var base64_rule = Base64.encode(rule);
            if (base64_rule == "") {
                alert("编码失败，请检查规则");
                return false;
            }
            // 检查是否变化
            if (base64_rule == dbus['clash_whitelist_rules']) {
                // show_result("白名单规则未发生变化", 1000);
                return false;
            }
            dbus["clash_whitelist_rules"] = base64_rule;
            apply_action("save_whitelist_rule", "0", function() {
                show_result("保存白名单规则成功!", 1000);
            });
            // 设置readonly属性为true
            $j("#rule_diy_whitelist").attr("readonly", true);
        }
        // 编辑黑名单规则(设置 rule_diy_blacklist readonly属性为false),并绑定ctrl+s快捷键
        function edit_blacklist_rule() {
            $j("#rule_diy_blacklist").attr("readonly", false);
            $j("#rule_diy_blacklist").focus();
        }

        // 编辑白名单规则(设置 rule_diy_whitelist readonly属性为false),并绑定ctrl+s快捷键
        function edit_whitelist_rule() {
            $j("#rule_diy_whitelist").attr("readonly", false);
            $j("#rule_diy_whitelist").focus();
        }

        // 点击tab标签时，实时加载规则文件内容
        function load_rule_content(data) {
            var clash_blacklist_rules = data.clash_blacklist_rules;
            var clash_whitelist_rules = data.clash_whitelist_rules;
            $j("#rule_diy_blacklist").val(Base64.decode(clash_blacklist_rules));
            $j("#rule_diy_whitelist").val(Base64.decode(clash_whitelist_rules));
        }

        // 切换为黑名单模式
        function switch_blacklist_mode() {
            if (dbus["clash_rule_mode"] != "blacklist") {
                dbus["clash_rule_mode"] = "blacklist";
                apply_action("switch_blacklist_mode", "0", function() {
                    show_result("切换为黑名单模式成功!", 1000);
                }, {
                    "clash_rule_mode": "blacklist"
                });
            } else {
                alert("当前已经是黑名单模式！");
            }
        }

        // 切换为白名单模式
        function switch_whitelist_mode() {
            if (dbus["clash_rule_mode"] != "whitelist") {
                dbus["clash_rule_mode"] = "whitelist";
                apply_action("switch_whitelist_mode", "0", function() {
                    show_result("切换为白名单模式成功!", 1000);
                }, {
                    "clash_rule_mode": "whitelist"
                });
            } else {
                alert("当前已经是白名单模式！");
            }
        }

        // 加载config文件内容
        function load_config_content() {
            var config = dbus['clash_edit_filecontent'];
            if (config == "" || config == undefined) {
                reload_content();
                return false;
            }
            // 解析base64编码的config文件内容
            var content = Base64.decode(config);
            if (content == "") {
                show_result("解码失败,请检查config文件是否丢失啦?");
                return false;
            }
            $j("#clash_config_content").val(content);
            show_result("重新加载内容完成!", 1000);
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
                dbus["clash_edit_filelist"] = data.clash_edit_filelist
                update_edit_filelist();
            }, {});
        }

        // 保存config文件内容
        function save_config_content() {
            var content = $j("#clash_config_content").val();
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
            $j("#clash_config_content").attr("readonly", true);
        }

        // 编辑config文件内容
        function edit_config_content() {
            $j("#clash_config_content").attr("readonly", false);
            $j("#clash_config_content").focus();
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
            $j("#clash_config_content").val(filecontent);
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
                    // jquery 设置 #copy_info 1秒后慢慢消失
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
                // alert("已复制到剪贴板");
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
                        <div class="formfonttitle" ><b>Clash</b>版科学上网工具
                            <img id="return_btn" onclick="reload_Soft_Center();" class="softcenterRetBtn" title="返回软件中心""></img>
                        </div>
                    </div>
                    <div class="clash_basic_info">
                        <!--插件特点-->
                        <p style="color:#FC0;">
                            <b><a style="color: rgb(0, 255, 60);font-size: 16px;" href="https://github.com/vxiaov/vClash">vClash目标</a></b>:实现一个简单、安装即用的科学上网插件,支持ss/ssr/v2ray/trojan等方式科学上网。<br/>
                            <b style="color: rgb(0, 255, 60);font-size: 16px;">1.问题反馈:</b>访问<a style="color: rgb(0, 255, 60);" href="https://github.com/vxiaov/vClash/issues" target="_blank">vClash项目>新建Issue</a>反馈你的问题，请尽量详细描述问题现象，将你的<b>路由信息</b>内容也包含在内。
                        </p>
                        <p style="color:#FC0"><b style="color: rgb(0, 255, 60);font-size: 16px;">2.工作模式</b>: <b style="color: rgb(0, 255, 60);">黑名单模式</b>(默认，特定网站列表走代理，大部分流量直连) ; <b style="color: rgb(0, 255, 60);">白名单模式</b>(国内IP直连，大部分其他流量走代理)</p>
                        <hr>
                    </div>
                    <!-- Tab菜单 -->
                    <div class="tabs">
                        <button id="btn_default_tab" class="tab" onclick="switch_tabs(event, 'menu_default')">主面板</button>
                        <button id="btn_config_tab" class="tab" onclick="switch_tabs(event, 'menu_config');switch_edit_filecontent();">在线编辑</button>
                        <button id="btn_option_tab" class="tab" onclick="switch_tabs(event, 'menu_options');">可选配置</button>
                        <button id="btn_log_tab" class="tab" onclick="switch_tabs(event, 'menu_log');">日志信息</button>
                        <button id="btn_ddns_tab" class="tab" onclick="switch_tabs(event, 'menu_ddns');">配置DDNS</button>
                        <button id="btn_watchdog_tab" class="tab" onclick="switch_tabs(event, 'menu_watchdog');">旁路由Watchdog</button>
                        <button id="btn_help_tab" class="tab" onclick="switch_tabs(event, 'menu_help');">自助学习</button>
                    </div>

                    <!-- 默认设置Tab -->
                    <table id="menu_default" class="FormTable">
                        <thead width="100%">
                            <tr>
                                <td colspan="2">Clash - 设置面板</td>
                            </tr>
                        </thead>
                        <tr>
                            <th>
                                <label>开启Clash服务</label>
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
                            <th>
                                <label>Clash-Premium版本:</label>
                            </th>
                            <td colspan="2">
                                <div id="clash_version_status">
                                    <i style="color:rgb(7, 234, 7)">(作者删库，不再为更新犯愁了，能用就用吧)</i>
                                </div>
                            </td>
                        </tr>
                        <tr>
                            <th>
                                <label>vClash(本插件)版本:</label>
                            </th>
                            <td colspan="2">
                                <div id="clash_vclash_version_status">
                                    <i style="color:rgb(7, 234, 7)">当前版本：<% dbus_get_def("clash_vclash_version", "未知" ); %></i>
                                </div>


                                <div id="clash_vclash_install_show" style="display: none;">
                                    <a type="button" class="button_gen" onclick="ignore_vclash_new_version()" href="javascript:void(0);">忽略新版本</a> &nbsp;&nbsp;&nbsp;&nbsp;
                                    <a type="button" class="button_gen" onclick="update_vclash_bin()" href="javascript:void(0);">更新最新版</a>
                                </div>
                            </td>
                        </tr>
                        <tr>
                            <th>模式选择</th>
                            <td>
                                <div class="switch_field">
                                    <select id="clash_rule_mode" class="input_option" style="width:300px;margin:0px 0px 0px 2px;">
                                        </select>
                                </div>
                            </td>
                        </tr>
                    </table>
                    <!-- 配置DDNS信息 -->
                    <table id="menu_ddns" class="FormTable">
                        <thead>
                            <tr>
                                <td colspan="2">配置DDNS(CloudFlare动态DNS)</td>
                            </tr>
                        </thead>
                        <tr>
                            <th title="启动Cloudflare的DDNS功能">启用DDNS功能</th>
                            <td colspan="2">
                                <div class="switch_field">
                                    <label for="clash_cfddns_enable">
                                        <input id="clash_cfddns_enable" onclick="switch_cfddns_mode();" class="switch" type="checkbox" style="display: none;">
                                        <div class="switch_container">
                                            <div class="switch_bar"></div>
                                            <div class="switch_circle transition_style"></div>
                                        </div>
                                    </label>
                                </div>
                            </td>
                        </tr>
                        <tr>
                            <th title="启动DDNS支持代理功能">支持代理(小云朵)</th>
                            <td colspan="2">
                                <div class="switch_field">
                                    <label for="clash_cfddns_proxy_enable">
                                        <input id="clash_cfddns_proxy_enable" class="switch" type="checkbox" style="display: none;">
                                        <div class="switch_container">
                                            <div class="switch_bar"></div>
                                            <div class="switch_circle transition_style"></div>
                                        </div>
                                    </label>
                                </div>
                            </td>
                        </tr>
                        <tr>
                            <th title="启动DDNS支持的IPv6地址,但此IPv6地址为路由器公网地址,非内网主机IPv6地址!">支持IPv6地址</th>
                            <td colspan="2">
                                <div class="switch_field">
                                    <label for="clash_cfddns_ipv6_enable">
                                        <input id="clash_cfddns_ipv6_enable" onclick="switch_cfddns_ipv6_mode();" class="switch" type="checkbox" style="display: none;">
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
                                <label>Email邮箱地址</label>
                            </th>
                            <td colspan="2">
                                <input type="email" class="input_text" name="email" id="clash_cfddns_email" placeholder="CF注册的邮箱：you@example.com">
                            </td>
                        </tr>
                        <tr>
                            <th>
                                <label>API KEY</label>
                            </th>
                            <td colspan="2">
                                <span>获取方法：<a target="_blank" style="color: greenyellow;" href="https://dash.cloudflare.com/profile/api-tokens">直达Cloudflare链接(查看<b>Global API Key</b>)</a>
                                                </span>
                                <input type="text" class="input_text" id="clash_cfddns_apikey" placeholder="获取方法：">
                            </td>
                        </tr>
                        <tr>
                            <th title="提前添加一条A记录（例如:home,IPv4地址可以写 127.0.0.1，添加成功后会更新，这里就填写 home.example.com,其中 example.com 是您的购买的域名）">
                                <label>域名列表</label>
                            </th>
                            <td colspan="2">
                                <input type="text" class="input_text" id="clash_cfddns_domain" placeholder="示例：home.example.com,test.example.com">
                            </td>
                        </tr>
                        <tr>
                            <th title="设置解析TTL生命周期，免费版的范围是120-86400,设置1为自动,默认值为1(调度更新时间2分钟)">
                                <label>TTL<b>(可不填)</b></label>
                            </th>
                            <td colspan="2">
                                <input type="text" class="input_text" class="input_text" id="clash_cfddns_ttl" placeholder="范围是120-86400,设置1为自动,默认值为1(调度更新时间2分钟)">
                            </td>
                        </tr>
                        <tr>
                            <th title="自动获取公网IP地址的检测命令，尽量自建或选择信任的网站！">
                                <label>获取公网IP命令<b>(可不填)</b></label>
                            </th>
                            <td colspan="2">
                                <input type="text" class="input_text" id="clash_cfddns_ipv4" placeholder="curl https://httpbin.org/ip|grep origin|cut -d\&quot; -f4">
                                <input type="text" class="input_text" id="clash_cfddns_ipv6" placeholder="curl 6.ipw.cn" style="display: none;">
                            </td>
                        </tr>
                        <tr>
                            <th>
                                <label>最后一次更新</label>
                            </th>
                            <td colspan="2">
                                <p>
                                    <div style="color: chartreuse;font-size: 18px;" id="clash_cfddns_lastmsg"></div>
                                </p>

                            </td>
                        </tr>
                    </table>
                    <!-- 配置软路由监控脚本 -->
                    <table id="menu_watchdog" class="FormTable">
                        <thead>
                            <tr>
                                <td colspan="2">配置监控旁路由状态(当前路由器为主路由哦)</td>
                            </tr>
                        </thead>
                        <tr>
                            <th>自动开启Clash功能</th>
                            <td colspan="2">
                                <div class="switch_field">
                                    <label for="clash_watchdog_start_clash">
                                        <input id="clash_watchdog_start_clash" class="switch" type="checkbox" style="display: none;">
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
                                <label>旁路由IP地址</label>
                            </th>
                            <td colspan="2">
                                <input type="text" class="input_text" name="route_soft_ip" id="clash_watchdog_soft_ip" placeholder="旁路由IP地址： 192.168.50.1">
                            </td>
                        </tr>
                        <tr>
                            <th>启用监控(立即生效)</th>
                            <td colspan="2">
                                <div class="switch_field">
                                    <label for="clash_watchdog_enable">
                                        <input id="clash_watchdog_enable" onclick="switch_route_watchdog();" class="switch" type="checkbox" style="display: none;">
                                        <div class="switch_container">
                                            <div class="switch_bar"></div>
                                            <div class="switch_circle transition_style"></div>
                                        </div>
                                    </label>
                                </div>
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
                                <label title="显示/隐藏DDNS配置页面">CFDDNS功能开关</label>
                            </th>
                            <td colspan="2">
                                <div class="switch_field">
                                    <label for="clash_cfddns_switch">
                                        <input id="clash_cfddns_switch" onclick="switch_cfddns_tab();" class="switch" type="checkbox" style="display: none;">
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
                                <label title="显示/隐藏旁路由watchdog功能配置页面">旁路由监控开关</label>
                            </th>
                            <td colspan="2">
                                <div class="switch_field">
                                    <label for="clash_watchdog_switch">
                                        <input id="clash_watchdog_switch" onclick="switch_watchdog_tab();" class="switch" type="checkbox" style="display: none;">
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
                                <label title="更新频率不同过高,一周更新一次即可." class="hintstyle">Country.mmdb文件</label>
                            </th>
                            <td>
                                <span style="text-align:left;">
                                    1. 全量GeoIP版本(6MB左右)<a class="copyToClipboard"  href="https://github.com/Dreamacro/maxmind-geoip/raw/release/Country.mmdb" onclick="copyURI(event)">点击复制</a> &nbsp;&nbsp;  <a style="color:chartreuse" href="https://github.com/Dreamacro/maxmind-geoip" target="_blank" rel="noopener noreferrer">Github地址</a> <br>
                                    2. 精简版(200KB左右，默认使用)<a class="copyToClipboard" href="https://github.com/Hackl0us/GeoIP2-CN/raw/release/Country.mmdb" onclick="copyURI(event)">点击复制</a> &nbsp;&nbsp;  <a style="color: chartreuse;" href="https://github.com/Hackl0us/GeoIP2-CN" target="_blank" rel="noopener noreferrer">Github地址</a><br>
                                    3. 全量多源合并版(6MB左右)<a class="copyToClipboard" href="https://raw.githubusercontent.com/alecthw/mmdb_china_ip_list/release/Country.mmdb" onclick="copyURI(event)">点击复制</a> &nbsp;&nbsp; <a style="color: chartreuse;" href="https://github.com/alecthw/mmdb_china_ip_list" target="_blank" rel="noopener noreferrer">Github地址</a> 
                                </span>
                                <input type="text" class="input_text" id="clash_geoip_url" placeholder="设置GeoIP数据下载地址">
                            </td>
                            <td class="hasButton">
                                <button type="button" class="button_gen" onclick="update_geoip()" href="javascript:void(0);">更新</button>
                            </td>
                        </tr>
                        <tr>
                            <th>
                                <label>备份配置</label>
                            </th>
                            <td colspan="2">
                                <input type="button" class="button_gen" onclick="backup_config_file();" value="开始备份">
                            </td>
                        </tr>
                        <tr>
                            <th>
                                <label>恢复配置</label>
                            </th>
                            <td colspan="2">
                                <input type="button" class="button_gen" onclick="restore_config_file();" value="开始恢复">
                                <input style="color:#FFCC00;*color:#000;width: 200px;" id="restore_file" type="file" name="file">
                            </td>
                        </tr>
                        <tr>
                            <th>
                                <label>上传<b>config.yaml</b>文件</label>
                            </th>
                            <td colspan="2">
                                <input type="button" class="button_gen" onclick="upload_config_file();" value="开始上传">
                                <input style="color:#FFCC00;*color:#000;width: 200px;" id="file" type="file" name="file">
                            </td>
                        </tr>
                        <tr>
                            <th>
                                 <label>手工升级(备份链接)<b>Clash</b>版本(<a target="_blank" href="https://github.com/vxiaov/clash_binary/">获取最新版</a>)</label>
                            </th>
                            <td colspan="2">
                                <input type="button" class="button_gen" onclick="upload_clash_file();" value="开始上传">
                                <input style="color:#FFCC00;*color:#000;width: 200px;" id="clash_file" type="file" name="file">
                            </td>
                        </tr>
                        <tr>
                            <td colspan="3">
                                <b>注意事项</b>:<br>&nbsp;&nbsp;&nbsp;&nbsp;
                                <b>1. 确保配置的Yaml格式正确性: </b>本插件会修改redir-port/dns.listen/external-controller/external-ui参数<br>&nbsp;&nbsp;&nbsp;&nbsp;
                                <b>2. 重要提醒: 修改前记得备份!!!</b><br/>
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
                                <textarea id="clash_config_content" readonly="true" rows="20" class="input_text" style="width: 98%;" title="为了防止误编辑，默认为只读，点击编辑后才可修改哦！&#010;快捷键Ctrl+S: 保存.&#010;快捷键Ctrl+E: 编辑.&#010;快捷键Ctrl+R: 重新加载。"></textarea>
                            </td>
                        </tr>
                        <tr>
                            <td colspan="2" style="text-align: center;">
                                <a type="button" class="button_gen" onclick="edit_config_content(); " href="javascript:void(0); ">编辑</a> &nbsp;&nbsp;&nbsp;
                                <a type="button" class="button_gen" onclick="set_edit_content(); " href="javascript:void(0); ">保存</a> &nbsp;&nbsp;&nbsp;
                                <a type="button" class="button_gen" onclick="load_config_content(); " href="javascript:void(0); ">重载</a>
                            </td>
                        </tr>
                        <tr>
                            <td colspan="2">
                                <p style="color: rgb(182, 222, 2);"> Clash配置规则</b>: 请阅读<a target="_blank" href="https://github.com/Dreamacro/clash/wiki/configuration">官方配置说明文档</a>，编辑快捷键: <br/></p>
                                <p style="color: rgb(248, 5, 62);">&nbsp;&nbsp;&nbsp;&nbsp;Ctrl+E: <b>开始编辑</b> Ctrl+S: <b>保存</b> Ctrl+R: <b>重新加载</b> Ctrl+C:<b>复制</b> Ctrl+V:<b>粘帖</b><br/>&nbsp;&nbsp;&nbsp;&nbsp;Ctrl+Z: <b>撤销(undo)</b> Ctrl+Shift+Z: <b>重做(redo)</b></p>
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
                                <p style="text-align: left; color: rgb(32, 252, 32); font-size: 18px;padding-top: 10px;padding-bottom: 10px;">使用说明：</p>
                                <p style="color:#FC0">&nbsp;&nbsp;&nbsp;&nbsp;<b style="color: rgb(32, 252, 32);">1. 插件的兼容性</b>: 透明代理模式时会与<b style="color: rgb(32, 252, 32);">其他代理插件冲突</b> ，使用前要关闭其他透明代理插件。</p>
                                <p style="color:#FC0">&nbsp;&nbsp;&nbsp;&nbsp;<b style="color: rgb(32, 252, 32);">2. 学习配置规则</b>: 官方文档已经删库，学习文档自己网上查找，很多的。</p>
                                <p style="color:#FC0">&nbsp;&nbsp;&nbsp;&nbsp;<b style="color: rgb(32, 252, 32);">3. 学习插件用法</b>: 可阅读<a target="_blank" href="https://github.com/vxiaov/vClash/wiki">vClash项目wiki页面</a></p>
                                <p style="color:#FC0">&nbsp;&nbsp;&nbsp;&nbsp;<b style="color: rgb(32, 252, 32);">4. clash的更新</b>: 官方不再更新并不意味着不能使用，clash只是一个代理路由功能，能用即可，这里提供了<a target="_blank" href="https://github.com/vxiaov/clash_binary">clash历史发布版本链接</a></p>
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
                                <p style="text-align: left; color: rgb(32, 252, 32); font-size: 18px;padding-top: 10px;padding-bottom: 10px;">日志信息</p>
                                <textarea rows="20 " wrap="off" readonly="readonly" id="clash_log_backup" class="input_text"></textarea>
                            </td>
                        </tr>
                    </table>
                    <!--打开 Clash控制面板-->
                    <div id="status_tools " style="margin-top: 25px; padding-bottom: 20px;">
                        <a type="button" class="button_gen" onclick="get_proc_status(); " href="javascript:void(0); ">状态检查</a> &nbsp;&nbsp;&nbsp;
                        <a type="button" class="button_gen" onclick="show_router_info(); " href="javascript:void(0); ">路由信息</a> &nbsp;&nbsp;&nbsp;
                        <a type="button" class="button_gen" id="clash_yacd_ui" onclick="yacd_ui_click_check(); " href="javascript:void(0); " target="_blank">Yacd控制面板</a>
                    </div>

                    <div>
                        <div style="height: 60px;margin-top:10px; ">
                            <div><img id="loadingIcon" style="display:none; " src="/images/loading.gif"></div>
                            <!-- 显示动态消息 -->
                            <label id="copy_info" style="display: none;color:#ffc800;font-size: 24px; "></label>
                        </div>
                    </div>

                    <div id="logMsg" style="display: none;">
                        <div>显示日志信息</div>
                        <textarea rows="20 " wrap="off" readonly="readonly" id="clash_log_msg" class="input_text"></textarea>
                    </div>

                    <div id="logArea" style="display: none; ">
                        <div>显示日志信息</div>
                        <textarea rows="20 " wrap="off" readonly="readonly" id="clash_text_log" class="input_text"></textarea>
                        <a type="button" class="button_gen" id="btn_log_msg_close" onclick="close_log_msg(); " href="javascript:void(0); ">关闭(5秒后)</a>
                    </div>

                    <div class="KoolshareBottom" style="margin-top:5px; ">
                        <a class="tab item-tab " href="https://github.com/Dreamacro/clash" target="_blank ">Clash项目</a>
                        <a class="tab item-tab " href="https://github.com/haishanh/yacd" target="_blank ">Yacd项目</a>
                        <a class="tab item-tab " href="https://github.com/vxiaov/vClash" target="_blank ">vClash项目</a>
                        <a class="tab item-tab " href="https://t.me/share_proxy_001" target="_blank ">TG讨论群</a>
                        <a class="tab item-tab " href="https://vlike.work/" target="_blank ">小V的博客</a>
                        <a class="tab item-tab " href="https://www.youtube.com/@xiaov" target="_blank ">小V的油管</a>
                    </div>
            </td>
            <div class="author-info"></div>
        </tr>
    </table>
    <div id="footer"></div>
</body>
<script type="text/css ">

</script>
<script type="text/javascript">
    <!--[if !IE]>-->
    (function($) {
        var textArea = document.getElementById('clash_text_log');
        textArea.scrollTop = textArea.scrollHeight;
    })(jQuery);
    <!--<![endif]-->
</script>

</html>