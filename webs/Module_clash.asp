<!DOCTYPE html
    PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">

<head>
    <meta http-equiv="X-UA-Compatible" content="IE=Edge" />
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta HTTP-EQUIV="Pragma" CONTENT="no-cache" />
    <meta HTTP-EQUIV="Expires" CONTENT="-1" />
    <link rel="shortcut icon" href="images/favicon.png" />
    <link rel="icon" href="images/favicon.png" />
    <title>软件中心 - 系统工具</title>
    <link rel="stylesheet" type="text/css" href="index_style.css" />
    <link rel="stylesheet" type="text/css" href="form_style.css" />
    <link rel="stylesheet" type="text/css" href="usp_style.css" />
    <link rel="stylesheet" type="text/css" href="ParentalControl.css">
    <link rel="stylesheet" type="text/css" href="css/icon.css">
    <link rel="stylesheet" type="text/css" href="css/element.css">
    <script type="text/javascript" src="/state.js"></script>
    <script type="text/javascript" src="/popup.js"></script>
    <script type="text/javascript" src="/help.js"></script>
    <script type="text/javascript" src="/validator.js"></script>
    <script type="text/javascript" src="/js/jquery.js"></script>
    <script type="text/javascript" src="/general.js"></script>
    <script type="text/javascript" src="/switcherplugin/jquery.iphone-switch.js"></script>
    <script type="text/javascript" src="/client_function.js"></script>
    <script type="text/javascript" src="/dbconf?p=clash_&v=<% uptime(); %>"></script>
    <link rel="stylesheet" type="text/css" href="/res/clash_style.css">
    <script type="text/javascript">
        var $j = jQuery.noConflict();
        function E(e) {
            return (typeof(e) == 'string') ? document.getElementById(e) : e;
        }
        function init() {
            show_menu(menu_hook);
            buildswitch();
            version_show();

            clash_group_type = db_clash_["clash_group_type"];
            if (typeof(clash_group_type) != "undefined" && clash_group_type != "") {
                $j("#clash_select_type").val(clash_group_type);
            } else {
                $j("#clash_select_type").val("url-test");
            }

            clash_provider_file = db_clash_["clash_provider_file"];
            if (typeof(clash_provider_file) != "undefined" && clash_provider_file != "") {
                $j("#provider_value").val(clash_provider_file);
            }

            var rrt = document.getElementById("switch_service");
            if (document.form.clash_enable.value != "on") {
                rrt.checked = false;
            } else {
                rrt.checked = true;
            }
            var s_trans = document.getElementById("switch_trans");
            if (document.form.clash_trans.value != "on") {
                s_trans.checked = false;
            } else {
                s_trans.checked = true;
            }
            document.getElementById("btn_default_tab").click();
        }

        function buildswitch() {
            $j("#switch_service").click(
                function() {
                    if (document.getElementById('switch_service').checked) {
                        document.form.clash_enable.value = "on";
                        document.form.clash_action.value = "start";
                    } else {
                        document.form.clash_enable.value = "off";
                        document.form.clash_action.value = "stop";
                    }
                    onSubmitCtrl(' Refresh ');
                });
            $j("#switch_trans").click(
                function() {
                    if (document.getElementById('switch_trans').checked) {
                        document.form.clash_trans.value = "on";
                    } else {
                        document.form.clash_trans.value = "off";
                    }
                    switch_trans_mode();
                });
            $j("#clash_select_type").change(function(){
                val_new = document.getElementById("clash_select_type").value;
                val_old = db_clash_["clash_group_type"];
                id = "btn_switch_trans";
                if (val_new != val_old) {
                    switch_trans_mode();
                }
            });
        }

        // 切换透明代理模式
        function switch_trans_mode() {
            var dbus = {};
            dbus["SystemCmd"] = "clash_control.sh";
            dbus["action_mode"] = " Refresh ";
            dbus["current_page"] = "Module_clash.asp";
            //透明代理模式切换
            dbus["clash_trans"] = document.getElementById("clash_trans").value;
            //节点组切换模式更新，clash_group_type 存储old值，clash_select_type存储新变更值
            dbus["clash_select_type"] = document.getElementById("clash_select_type").value;
            dbus["clash_action"] = "switch_trans_mode";
            apply_action(dbus);
        }

        // 进程状态检查
        function get_proc_status() {
            var dbus = {};
            dbus["SystemCmd"] = "clash_control.sh";
            dbus["action_mode"] = " Refresh ";
            dbus["current_page"] = "Module_clash.asp";
            dbus["clash_action"] = "get_proc_status";
            apply_action(dbus);
        }

        // 更新节点订阅源URL
        function update_provider_file() {
            var dbus = {};
            dbus["SystemCmd"] = "clash_control.sh";
            dbus["action_mode"] = " Refresh ";
            dbus["current_page"] = "Module_clash.asp";
            dbus["clash_provider_file"] = document.getElementById("provider_value").value;
            dbus["clash_action"] = "update_provider_file";
            apply_action(dbus);
        }

        // 更新GeoIP
        function update_geoip() {
            var dbus = {};
            dbus["SystemCmd"] = "clash_control.sh";
            dbus["action_mode"] = " Refresh ";
            dbus["current_page"] = "Module_clash.asp";
            dbus["clash_action"] = "update_geoip";
            apply_action(dbus);
        }

        // 更新 ruleset
        function update_ruleset() {
            var dbus = {};
            dbus["SystemCmd"] = "clash_control.sh";
            dbus["action_mode"] = " Refresh ";
            dbus["current_page"] = "Module_clash.asp";
            dbus["clash_action"] = "update_ruleset";
            apply_action(dbus);
        }

        // DIY节点添加
        function add_nodes() {
            var dbus = {};
            dbus["SystemCmd"] = "clash_control.sh";
            dbus["action_mode"] = " Refresh ";
            dbus["current_page"] = "Module_clash.asp";
            dbus["clash_node_list"] = document.getElementById("proxy_node_list").value;
            dbus["clash_node_list"].replace(/\n/g, " ")
            dbus["clash_action"] = "add_nodes";
            apply_action(dbus);
        }

        // 更新DIY节点 名称列表
        function update_node_list(f) {
            $j.ajax({
                type: "GET",
                url: '/dbconf?p=clash_',
                dataType: 'html',
                success: function(response) {
                    $j.globalEval(response);
                    var obj = document.getElementById("proxy_node_name");
                    obj.options.length=0;
                    const node_arr = db_clash_["clash_name_list"].trim().split(" ");
                    for (let index = 0; index < node_arr.length; index++) {
                        const element = node_arr[index];
                        obj.options.add(new Option(element, element));
                    }
                }
            });
        }

        // DIY节点 全部删除
        function delete_all_nodes() {
            var dbus = {};
            dbus["SystemCmd"] = "clash_control.sh";
            dbus["action_mode"] = " Refresh ";
            dbus["current_page"] = "Module_clash.asp";
            dbus["clash_action"] = "delete_all_nodes";
            apply_action(dbus);
            var obj = document.getElementById("proxy_node_name");
            obj.options.length = 0;
        }

        // DIY节点 按名称删除
        function delete_one_node() {
            var dbus = {};
            dbus["SystemCmd"] = "clash_control.sh";
            dbus["action_mode"] = " Refresh ";
            dbus["current_page"] = "Module_clash.asp";
            dbus["clash_delete_name"] = document.getElementById("proxy_node_name").value;
            dbus["clash_action"] = "delete_one_node";
            apply_action(dbus);
            var obj = document.getElementById("proxy_node_name");
            obj.options.remove(obj.selectedIndex);
        }

        // 更新节点订阅源URL
        function update_clash_bin() {
            var dbus = {};
            dbus["SystemCmd"] = "clash_control.sh";
            dbus["action_mode"] = " Refresh ";
            dbus["current_page"] = "Module_clash.asp";
            dbus["clash_new_version"] = document.getElementById("clash_new_version").value;
            dbus["clash_action"] = "update_clash_bin";
            apply_action(dbus);
            $j("#btn_update_ver").style.display = "none";
        }

        function apply_action(data) {
            $j.ajax({
                type: "POST",
                url: '/applydb.cgi?p=clash_',
                contentType: "application/x-www-form-urlencoded",
                dataType: 'text',
                data: data,
                success: function(response) {
                    // 检查结果
                    document.getElementById("loadingIcon").style.display = "";
                    setTimeout("checkCmdRet();", 500);
                    
                }
            });
        }

        function update_dbconf() {
            $j.ajax({
                type: "GET",
                url: '/dbconf?p=clash_&v=uptime()',
                dataType: 'html',
                success: function(response) {
                    $j.globalEval(response);
                    init();
                }
            });
        }


        var _responseLen;
        var noChange = 0;

        function checkCmdRet() {
            $j.ajax({
                url: '/cmdRet_check.htm',
                dataType: 'html',
                error: function(xhr) {
                    setTimeout("checkCmdRet();", 1000);
                },
                success: function(response) {
                    var retArea = document.getElementById("clash_text_log");
                    if (response.search("XU6J03M6") != -1) {
                        document.getElementById("loadingIcon").style.display = "none";
                        retArea.value = response.replace("XU6J03M6", " ");
                        retArea.scrollTop = retArea.scrollHeight;
                        update_dbconf();
                        return false;
                    }
                    if (_responseLen == response.length)
                        noChange++;
                    else
                        noChange = 0;
                    if (noChange > 10) {
                        document.getElementById("loadingIcon").style.display = "none";
                        setTimeout("checkCmdRet();", 1000);
                    } else {
                        document.getElementById("loadingIcon").style.display = "";
                        setTimeout("checkCmdRet();", 1000);
                    }
                    retArea.value = response.replace("XU6J03M6", " ");
                    retArea.scrollTop = retArea.scrollHeight;
                    _responseLen = response.length;
                }
            });
        }

        function onSubmitCtrl(s) {
            document.form.action_mode.value = s;
            //showLoading(3);
            document.form.submit();
            document.getElementById("loadingIcon").style.display = "";
            setTimeout("checkCmdRet();", 500);
        }

        function reload_Soft_Center() {
            location.href = "/Main_Soft_center.asp";
        }

        function version_show() {
            $j("#clash_version_status").html("<i>当前版本：" + db_clash_['clash_version']);
            $j.ajax({
                url: 'https://api.github.com/repos/Dreamacro/clash/tags',
                type: 'GET',
                dataType: 'json',
                success: function(res) {
                    if (typeof(res) != "undefined" && res.length > 0) {
                        var obj = res[0];
                        if (obj.name != db_clash_["clash_version"]) {
                            $j("#clash_version_status").html("<i>当前版本：" + db_clash_["clash_version"] + "，<i>有新版本：" + obj.name);
                            document.getElementById("clash_new_version").value = obj.name;
                            document.getElementById("btn_update_ver").style.display = "";
                        } else {
                            $j("#clash_version_status").html("<i>当前版本：" + obj.name + "，已是最新版本。");
                        }
                    }
                }
            });
        }

        var enable_ss = "<% nvram_get("
        enable_ss "); %>";
        var enable_soft = "<% nvram_get("
        enable_soft "); %>";

        function menu_hook(title, tab) {
            tabtitle[tabtitle.length -1] = new Array("", "软件中心", "离线安装", "Clash版代理工具");
            tablink[tablink.length -1] = new Array("", "Main_Soft_center.asp", "Main_Soft_setting.asp", "Module_clash.asp");
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
    </script>
</head>

<body onload="init();">
    <div id="TopBanner"></div>
    <div id="Loading" class="popup_bg"></div>
    <iframe name="hidden_frame" id="hidden_frame" src="" width="0" height="0" frameborder="0"></iframe>
    <form method="POST" name="form" action="/applydb.cgi?p=clash_" target="hidden_frame">
        <input type="hidden" name="current_page" value="Module_clash.asp" />
        <input type="hidden" name="next_page" value="Module_clash.asp" />
        <input type="hidden" name="group_id" value="" />
        <input type="hidden" name="modified" value="0" />
        <input type="hidden" name="action_mode" value="" />
        <input type="hidden" name="action_script" value="" />
        <input type="hidden" name="action_wait" value="5" />
        <input type="hidden" name="first_time" value="" />
        <input type="hidden" name="preferred_lang" id="preferred_lang" value="<% nvram_get(" preferred_lang "); %>" />
        <input type="hidden" name="SystemCmd" value="clash_control.sh" />
        <input type="hidden" name="firmver" value="<% nvram_get(" firmver "); %>" />
        <input type="hidden" id="clash_enable" name="clash_enable" value='<% dbus_get_def("clash_enable", "off"); %>' />
        <input type="hidden" id="clash_trans" name="clash_trans" value='<% dbus_get_def("clash_trans", "on"); %>' />
        
        
        <input type="hidden" id="clash_action" name="clash_action" value='' />
        <input type="hidden" id="clash_new_version" value='' />
        
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
                            <div style="float:left;" class="formfonttitle"><b>Clash</b>版科学上网工具</div>
                            <div style="float:right; width:15px; height:25px;margin-top:10px">
                                <img id="return_btn" onclick="reload_Soft_Center();" align="right" style="cursor:pointer;margin-left:-80px;margin-top:-25px;" title="返回软件中心" src="/images/backprev.png" onMouseOver="this.src='/images/backprevclick.png'" onMouseOut="this.src='/images/backprev.png'"></img>
                            </div>
                            <div class="clash_basic_info">
                                <!--插件特点-->
                                <p><a href='https://github.com/Dreamacro/clash' target='_blank'><em><u>Clash</u></em></a>是一个基于规则的代理程序，支持<a href='https://github.com/shadowsocks/shadowsocks-libev' target='_blank'><em><u>SS</u></em></a>、<a href='https://github.com/shadowsocksrr/shadowsocksr-libev' target='_blank'><em><u>SSR</u></em></a>、<a href='https://github.com/v2ray/v2ray-core' target='_blank'><em><u>V2Ray</u></em></a>、<a href='https://github.com/trojan-gfw/trojan' target='_blank'><em><u>Trojan</u></em></a>等方式科学上网。</p>
                                <p style="text-align: left; color: red; font-size: 20px;padding-top: 10px;">使用说明：</p>
                                <p style="color:#FC0">&nbsp;&nbsp;&nbsp;&nbsp;1. 特点： <b style="font-size: 25px;">安装即用</b>，已经内置<a href="https://github.com/learnhard-cn/free_proxy_ss"  target="_blank">订阅源URL地址</a> 到配置文件中。<b>插件代码已<a href="https://github.com/learnhard-cn/clash" target="_blank">Github开源</a> </b>。 </p>
                                <p style="color:#FC0">&nbsp;&nbsp;&nbsp;&nbsp;2. 支持功能： 更新订阅源URL地址，若订阅源URL格式错误,请参考<a href="https://github.com/Dreamacro/clash/wiki/configuration#proxy-providers" target="_blank" rel="noopener noreferrer">Clash-Provider格式配置参考链接</a> </p>
                                <p style="color:#FC0">&nbsp;&nbsp;&nbsp;&nbsp;3. 兼容性： 如果使用了透明代理模式，这可能会与<b>其他代理插件可能产生冲突</b> ，使用前要关闭其他透明代理插件。</p>
                                <p style="color:#FC0">&nbsp;&nbsp;&nbsp;&nbsp;4. <b style="color: red;">透明代理</b>：局域网不用做任何设置即可科学上网。</p>
                                <p style="color:#FC0">&nbsp;&nbsp;&nbsp;&nbsp;5. 关闭透明代理，可结合 <b>switchyomega插件</b> 使用SOCKS5代理端口： <b>1080</b> ! 非大陆IP自动使用代理转发。</p>
                                <p style="color:#FC0">&nbsp;&nbsp;&nbsp;&nbsp;6. 代理节点切换模式： </p>
                                <p style="color:#FC0">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-<b>url-test</b>: 优先选择低延迟节点。定期验证可用性并进行延迟排序。<b>推荐选择此模式！默认使用此模式。</b> </p>
                                <p style="color:#FC0">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-<b>select</b>: 按配置顺序选择结点。<b>使用哪个结点你说了算!</b>，但结点不可用时你得自己切换。 </p>
                                <p style="color:#FC0">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-<b>fallback</b>: 按顺序选择第一个可用代理，与 url-test 区别是 <b>不按照延迟排序</b> 。</p>
                                <p style="color:#FC0">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-<b>load-balance</b>: 个人不建议使用，应用场景：同一个域名请求使用相同节点，<b>适合并发多网站请求模式</b> 。</p>
                                <p style="text-align: center; color: #FC0; font-size: 20px;">闲话少说！<b style="font-size: 25px;">安装即用</b>就对了。</p>
                            </div>
                            <div class="blank_line"><img src="/images/New_ui/export/line_export.png" /></div>
                        </div>
                        <!-- Tab菜单 -->
                        <div id="tabs">
                            <button id="btn_default_tab" class="tab" onclick="switch_tabs(event, 'menu_default')">帐号设置</button>
                            <button class="tab" onclick="switch_tabs(event, 'menu_provider_update')">订阅源管理</button>
                            <button class="tab" onclick="switch_tabs(event, 'menu_group_add')">添加节点</button>
                            <button class="tab" onclick="switch_tabs(event, 'menu_group_delete');update_node_list()">删除节点</button>
                        </div>
                        <div class="blank_line"><img src="/images/New_ui/export/line_export.png" /></div>
                        <!-- 默认设置Tab -->
                        <table id="menu_default" class="FormTable">
                            <thead width="100%">
                                <tr>
                                    <td colspan="2">Clash - 设置面板</td>
                                </tr>
                            </thead>
                            <tr>
                                <th>
                                    <label>开启Clash服务:</label>
                                </th>
                                <td colspan="2">
                                    <div class="switch_field">
                                        <label for="switch_service">
                                            <input id="switch_service" class="switch" type="checkbox" style="display: none;">
                                            <div class="switch_container">
                                                <div class="switch_bar"></div>
                                                <div class="switch_circle transition_style"></div>
                                            </div>
                                        </label>
                                    </div>
                                    <div id="clash_version_status">
                                        <i>当前版本：<% dbus_get_def("clash_version", "未知" ); %></i>
                                    </div>
                                    <div id="clash_install_show" style="padding-top:5px;margin-left:330px;margin-top:-25px;">
                                        <button id="btn_update_ver" style="display: none;" type="button" class="button_gen" onclick="update_clash_bin()" href="javascript:void(0);">更新版本</button>
                                    </div>
                                    <div><img id="loadingIcon" style="display:none;" src="/images/loading.gif"></div>
                                </td>
                            </tr>
                            <tr>
                                <th>
                                    <label>透明代理模式开关:</label>
                                </th>
                                <td colspan="2">
                                    <div class="switch_field" >
                                        <label for="switch_trans">
                                            <input id="switch_trans" class="switch" type="checkbox" style="display: none;">
                                            <div class="switch_container">
                                                <div class="switch_bar"></div>
                                                <div class="switch_circle transition_style"></div>
                                            </div>
                                        </label>
                                    </div>
                                </td>
                            </tr>
                            <!-- 节点切换模式 -->
                            <tr>
                                <th>
                                    <label>节点组切换模式:</label>
                                </th>
                                <td colspan="2">
                                    <div class="switch_field">
                                        <select id="clash_select_type" class="input_option" style="width:180px;margin:0px 0px 0px 2px;">
                                            <option value="select">【1】 select模式</option>
                                            <option value="url-test">【2】 url-test模式</option>
                                            <option value="fallback">【3】 fallback模式</option>
                                            <option value="load-balance">【4】 LB负载均衡模式</option>
                                        </select>
                                    </div>
                                </td>
                            </tr>
                            
                        </table>
                        <!-- 订阅源URL更新部分 -->
                        <table id="menu_provider_update" class="FormTable">
                            <thead>
                                <tr>
                                    <td colspan="2">Clash - 订阅源更新</td>
                                </tr>
                            </thead>
                            <tr>
                                <th>
                                    <label>订阅源URL链接:</label>
                                </th>
                                <td colspan="2">
                                    <input type="url" placeholder="# 此处填入节点订阅源URL地址！yaml文件格式！" id="provider_value" class="input_text">
                                </td>
                            </tr>
                            <tr>
                                <td colspan="2">
                                    <button id="btn_update_url" type="button" class="button_gen" onclick="update_provider_file()" href="javascript:void(0);">更新订阅源</button>
                                </td>
                            </tr>
                            <tr>
                                <td colspan="2">
                                    <span>支持更新订阅源数量： <b>一个</b> 。 多个订阅源可以自行合并后再添加，合并方法可以放在Github上使用Action合并更新。</span>
                                </td>
                            </tr>
                            <tr>
                                <th>
                                    <label>GeoIP数据文件:</label>
                                </th>
                                <td colspan="2">
                                    <button type="button" class="button_gen" onclick="update_geoip()" href="javascript:void(0);">更新</button>
                                </td>
                            </tr>
                            <tr>
                                <th>
                                    <label>规则集ruleset文件:</label>
                                </th>
                                <td colspan="2">
                                    <button type="button" class="button_gen" onclick="update_ruleset()" href="javascript:void(0);">更新</button>
                                </td>
                            </tr>
                        </table>
                        <!-- 代理组添加节点操作 -->
                        <table id="menu_group_add" class="FormTable">
                            <thead>
                                <tr>
                                    <td colspan="2">Clash - 代理组添加节点</td>
                                </tr>
                            </thead>
                            <tr>
                                <th>输入链接：</th>
                                <td colspan="2">
                                    <textarea rows="5" class="input_text" id="proxy_node_list" placeholder="#粘贴代理链接，每行一个代理,支持SS/SSR/VMESS类型URI链接解析"></textarea>
                                </td>
                            </tr>
                            <tr>
                                <td colspan="2">
                                    <button type="button" class="button_gen" onclick="add_nodes()" href="javascript:void(0);">添加</button>
                                </td>
                            </tr>
                        </table>
                        <!-- 代理组删除节点操作 -->
                        <table id="menu_group_delete" class="FormTable">
                            <thead>
                                <tr>
                                    <td colspan="2">Clash - 代理组删除节点</td>
                                </tr>
                            </thead>
                            <tr>
                                <th>名称:</th>
                                <td colspan="2">
                                    <div class="switch_field">
                                        <select id="proxy_node_name" class="input_option" style="width:180px;margin:0px 0px 0px 2px;">
                                        </select>
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <td colspan="2">
                                    <button type="button" class="button_gen" onclick="delete_one_node()" href="javascript:void(0);">删除</button>
                                    <button type="button" class="button_gen" onclick="delete_all_nodes()" href="javascript:void(0);">删除全部</button>
                                </td>
                            </tr>
                        </table>
                        <div class="blank_line"><img src="/images/New_ui/export/line_export.png" /></div>
                       
                        <div>
                            <!--打开 Clash控制面板-->
                            <span><b>Web控制面板(默认密码：route):</b></span>
                            <a type="button" class="button_gen" href="/ext/dashboard/yacd/index.html" target="_blank">Clash面板</a>
                            <!-- 日志显示部分-->
                            <a type="button" class="button_gen" onclick="get_proc_status()" href="javascript:void(0);">状态检查</a>
                        </div>
                        <div class="blank_line"><img src="/images/New_ui/export/line_export.png" /></div>
                        
                        <div style="margin-top:8px" id="logArea">
                            <div style="display: block;text-align: center; font-size: 14px;">显示日志信息</div>
                            <textarea cols="63" rows="30" wrap="off" readonly="readonly" id="clash_text_log" class="input_text"></textarea>
                        </div>
                        <div class="blank_line"><img src="/images/New_ui/export/line_export.png" /></div>
                        <div class="KoolshareBottom" style="margin-top:10px;">
                            技术支持： <a href="https://t.me/share_proxy_001" target="_blank" rel="noopener noreferrer">电报群:@share_proxy_001</a>
                            <a href="http://vlike.work/" target="_blank">
                                <i><u>http://vlike.work</u></i> </a> <br /> Github项目：
                            <a href="https://github.com/learnhard-cn/clash" target="_blank">
                                <i><u>https://github.com/learnhard-cn/clash</u></i> </a> <br /> Shell by： <i>Awkee</i> , Web by： <i>Awkee</i>
                        </div>
                    </div>
                </td>
                <div class="author-info">

                </div>
            </tr>
        </table>
    </form>
    
    </td>
    <div id="footer"></div>
</body>
<script type="text/css">

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