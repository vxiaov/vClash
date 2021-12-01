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

        function E(e) {
            return (typeof(e) == 'string') ? document.getElementById(e) : e;
        }

        function init() {
            show_menu(menu_hook);
            get_dbus_data();
            version_show();
            document.getElementById("btn_default_tab").click();
        }

        function menu_hook(title, tab) {
            tabtitle[tabtitle.length - 1] = new Array("", "软件中心", "离线安装", "Clash版代理工具");
            tablink[tablink.length - 1] = new Array("", "Module_Softcenter.asp", "Module_Softsetting.asp", "Module_clash.asp");
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

        function conf2obj() {
            if(dbus['clash_name_list'])
                dbus['relay_option_list'] = dbus['clash_name_list'].trim() + " PROXY DIY组 被墙代理组" ;
            else
                dbus['relay_option_list'] = "PROXY DIY组 被墙代理组";
            update_relay_list("clash_relay01");
            update_relay_list("clash_relay02");

            var params = ['clash_group_type', 'clash_provider_file', 'clash_geoip_url', 'clash_cfddns_email', 'clash_cfddns_domain', 'clash_cfddns_apikey', 'clash_cfddns_ttl', 'clash_cfddns_ip', 'clash_netflix_dns', 'clash_relay01', 'clash_relay02', 'clash_netflix_sniproxy'];
            var params_chk = ['clash_gfwlist_mode', 'clash_trans', 'clash_enable', 'clash_use_local_proxy', 'clash_cfddns_enable', 'clash_relay_enable', 'clash_netflixdns_enable'];
            for (var i = 0; i < params_chk.length; i++) {
                if (dbus[params_chk[i]]) {
                    E(params_chk[i]).checked = dbus[params_chk[i]] == "on";
                }
            }
            for (var i = 0; i < params.length; i++) {
                if (dbus[params[i]]) {
                    E(params[i]).value = dbus[params[i]];
                }
            }
            document.getElementById("clash_cfddns_lastmsg").innerHTML = dbus["clash_cfddns_lastmsg"];

        }

        function update_node_list() {
            get_dbus_data();
            var obj = document.getElementById("proxy_node_name");
            obj.options.length = 0;
            const node_arr = dbus["clash_name_list"].trim().split(" ");
            for (let index = 0; index < node_arr.length; index++) {
                const element = node_arr[index];
                obj.options.add(new Option(element, element));
            }
        }
        function update_relay_list(relay_id) {
            //更新显示的代理列表信息: dbus['relay_option_list']
            var obj = document.getElementById(relay_id);
            obj.options.length = 0;
            const node_arr = dbus["relay_option_list"].trim().split(/ +/);
            for (let index = 0; index < node_arr.length; index++) {
                const element = node_arr[index];
                obj.options.add(new Option(element, element));
            }
        }
        function update_relay01() {
            //更新显示的代理列表信息: dbus['relay_option_list']
            var obj = document.getElementById("clash_relay02");
            obj.options.length = 0;
            var relay01 = document.getElementById("clash_relay01").value;
            var relay_node_list = dbus["relay_option_list"].replace( relay01,""); //清理已经选择的relay01
            const node_arr = relay_node_list.trim().split(/ +/);
            for (let index = 0; index < node_arr.length; index++) {
                const element = node_arr[index];
                obj.options.add(new Option(element, element));
            }
        }

        //提交任务方法,实时日志显示
        function post_dbus_data(script, arg, obj, flag) {
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
                        if (flag && flag == "1") {
                            refreshpage(1);
                        } else if (flag && flag == "2") {
                            //continue;
                            //do nothing
                        } else {
                            document.getElementById("loadingIcon").style.display = "";
                            show_status();
                        }
                    }
                }
            });
        }

        function show_status() {
            //显示脚本执行过程的日志信息
            $j.ajax({
                url: '/_temp/clash_status.log',
                type: 'GET',
                async: true,
                cache: false,
                dataType: 'text',
                success: function(response) {
                    var retArea = E("clash_text_log");
                    if (response.search("XU6J03M6") != -1) {
                        document.getElementById("loadingIcon").style.display = "none";
                        retArea.value = response.replace("XU6J03M6", " ");
                        retArea.scrollTop = retArea.scrollHeight;
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
                        setTimeout("show_status();", 500);
                    }
                    retArea.value = response.replace("XU6J03M6", " ");
                    retArea.scrollTop = retArea.scrollHeight;
                    _responseLen = response.length;
                },
                error: function() {
                    setTimeout("show_status();", 500);
                }
            });
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

        function version_show() {
            $j("#clash_version_status").html("<i>当前版本：" + dbus['clash_version']);
            $j.ajax({
                url: 'https://api.github.com/repos/Dreamacro/clash/tags',
                type: 'GET',
                async: true,
                cache: false,
                retries: 0,
                dataType: 'json',
                success: function(res) {
                    if (typeof(res) != "undefined" && res.length > 0) {
                        var obj = res[0];
                        if (obj.name != dbus["clash_version"]) {
                            $j("#clash_version_status").html("<i>当前版本：" + dbus["clash_version"] + "，<i>有新版本：" + obj.name);
                            dbus["clash_new_version"] = obj.name;
                            document.getElementById("btn_update_ver").style.display = "";
                        } else {
                            $j("#clash_version_status").html("<i>当前版本：" + obj.name + "，已是最新版本。");
                        }
                    }
                },
                error: function(res) {
                    $j("#clash_version_status").html("访问最新版本信息失败!<i>当前版本：" + dbus["clash_version"] + "，已是最新版本。");
                }
            }).fail(() => {
                console.log('failed');
            });
        }

        /*********************主要功能逻辑模块实现**************/
        function apply_action(action, data) {
            if (!action) {
                return;
            }
            if (!data) {
                data = dbus
            }
            post_dbus_data("clash_control.sh", action, data);
        }

        function service_stop() {
            apply_action("stop");
        }

        function service_start() {
            apply_action("start");
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

        function swtich_use_localhost_proxy() {
            if (document.getElementById('clash_use_local_proxy').checked) {
                dbus["clash_use_local_proxy"] = "on";
            } else {
                dbus["clash_use_local_proxy"] = "off";
            }
            //apply_action("swtich_use_localhost_proxy");
        }

        function switch_gfwlist_mode() { // 切换gfwlist黑名单模式
            if (document.getElementById('clash_gfwlist_mode').checked) {
                dbus["clash_gfwlist_mode"] = "on";
            } else {
                dbus["clash_gfwlist_mode"] = "off";
            }
            apply_action("switch_gfwlist_mode");
        }

        function switch_trans_mode() { //切换透明代理模式，开关
            if (document.getElementById('clash_trans').checked) {
                dbus["clash_trans"] = "on";
            } else {
                dbus["clash_trans"] = "off";
            }
            apply_action("switch_trans_mode");
        }

        function switch_group_type() { // 更新代理组类型: select/url-test/...
            val_new = document.getElementById("clash_group_type").value;
            val_old = dbus["clash_group_type"];
            id = "btn_switch_trans";
            if (val_new != val_old) {
                dbus["clash_group_type"] = val_new;
                apply_action("switch_group_type");
            }

        }

        function switch_cfddns_mode() { //启用cfddns
            if (document.getElementById('clash_cfddns_enable').checked) {
                dbus["clash_cfddns_enable"] = "on";
            } else {
                dbus["clash_cfddns_enable"] = "off";
            }
            document.getElementById("clash_cfddns_enable").disabled = true;
            dbus["clash_cfddns_email"] = document.getElementById("clash_cfddns_email").value;
            dbus["clash_cfddns_apikey"] = document.getElementById("clash_cfddns_apikey").value;
            dbus["clash_cfddns_domain"] = document.getElementById("clash_cfddns_domain").value;
            dbus["clash_cfddns_ttl"] = document.getElementById("clash_cfddns_ttl").value;
            dbus["clash_cfddns_ip"] = document.getElementById("clash_cfddns_ip").value;
            apply_action("save_cfddns");
            document.getElementById("clash_cfddns_enable").disabled = false;
        }

        function get_proc_status() { // 查看服务运行状态
            apply_action("get_proc_status");
        }

        function update_geoip() { // 更新GeoIP
            dbus["clash_geoip_url"] = document.getElementById("clash_geoip_url").value;
            if (document.getElementById('clash_use_local_proxy').checked) {
                dbus["clash_use_local_proxy"] = "on";
            } else {
                dbus["clash_use_local_proxy"] = "off";
            }
            apply_action("update_geoip");
        }

        function update_netflix_dns() { // 更新Netflix地区解锁DNS地址
            dbus["clash_netflixdns_enable"] = document.getElementById("clash_netflix_dns").checked? "on" : "off";
            dbus["clash_netflix_dns"] = document.getElementById("clash_netflix_dns").value;
            dbus["clash_netflix_sniproxy"] = document.getElementById("clash_netflix_sniproxy").value;
            apply_action("update_netflix_dns");
        }

        function update_netflix_relay() { // 更新Netflix地区解锁中继代理列表
            dbus["clash_relay_enable"] = document.getElementById("clash_relay_enable").checked? "on" : "off";
            dbus["clash_relay01"] = document.getElementById("clash_relay01").value;
            dbus["clash_relay02"] = document.getElementById("clash_relay02").value;
            apply_action("update_netflix_relay");
        }

        function update_provider_file() { // 更新节点订阅源URL
            dbus["clash_provider_file"] = document.getElementById("clash_provider_file").value;
            if (document.getElementById('clash_use_local_proxy').checked) {
                dbus["clash_use_local_proxy"] = "on";
            } else {
                dbus["clash_use_local_proxy"] = "off";
            }
            apply_action("update_provider_file");
        }

        function add_nodes() { // 添加DIY节点
            dbus["clash_node_list"] = document.getElementById("proxy_node_list").value.replaceAll("\n", " ");
            apply_action("add_nodes");
        }

        function delete_one_node() { // 按名称删除 DIY节点
            dbus["clash_delete_name"] = document.getElementById("proxy_node_name").value;
            apply_action("delete_one_node");
            var obj = document.getElementById("proxy_node_name");
            obj.options.remove(obj.selectedIndex);
        }

        function delete_all_nodes() { // 按名称删除 DIY节点
            apply_action("delete_all_nodes");
            var obj = document.getElementById("proxy_node_name");
            obj.options.length = 0;
        }

        function update_clash_bin() { // 按名称删除 DIY节点
            apply_action("update_clash_bin");
            document.getElementById("btn_update_ver").style.display = "none";
        }

        function show_router_info() {
            apply_action("show_router_info");
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
                        <div style="float:left;" class="formfonttitle"><b>Clash</b>版科学上网工具</div>
                        <div style="float:right; width:15px; height:25px;margin-top:10px">
                            <img id="return_btn" onclick="reload_Soft_Center();" align="right" style="cursor:pointer;margin-left:-80px;margin-top:-25px;" title="返回软件中心" src="/images/backprev.png" onMouseOver="this.src='/images/backprevclick.png'" onMouseOut="this.src='/images/backprev.png'"></img>
                        </div>
                        <div class="clash_basic_info">
                            <!--插件特点-->
                            <p><a href='https://github.com/Dreamacro/clash' target='_blank' rel="noopener noreferrer"><em><u>Clash</u></em></a>是一个基于规则的代理程序，支持<a href='https://github.com/shadowsocks/shadowsocks-libev' target='_blank' rel="noopener noreferrer"><em><u>SS</u></em></a>、
                                <a
                                    href='https://github.com/shadowsocksrr/shadowsocksr-libev' target='_blank' rel="noopener noreferrer"><em><u>SSR</u></em></a>、<a href='https://github.com/v2ray/v2ray-core' target='_blank'><em><u>V2Ray</u></em></a>、<a href='https://github.com/trojan-gfw/trojan' target='_blank'><em><u>Trojan</u></em></a>等方式科学上网。</p>
                            <p style="text-align: left; color: rgb(19, 209, 41); font-size: 25px;padding-top: 10px;padding-bottom: 10px;">使用说明：</p>
                            <p style="color:#FC0">&nbsp;&nbsp;&nbsp;&nbsp;1. 特点： <b style="font-size: 25px;color: rgb(32, 252, 32);">安装即用</b>，已经内置<a href="https://github.com/learnhard-cn/free_proxy_ss" target="_blank" style="color: rgb(32, 252, 32); text-decoration: underline;">订阅源URL地址</a>                                到配置文件中。插件代码已<a href="https://github.com/learnhard-cn/clash" target="_blank" style="color: rgb(32, 252, 32);text-decoration: underline;">Github开源</a> 。 </p>
                            <p style="color:#FC0">&nbsp;&nbsp;&nbsp;&nbsp;2. 支持功能： 更新订阅源URL地址，若订阅源URL格式错误,请参考<a href="https://github.com/Dreamacro/clash/wiki/configuration#proxy-providers" target="_blank" rel="noopener noreferrer" style="color: rgb(32, 252, 32);text-decoration: underline;">Clash-Provider格式配置参考链接</a>                                </p>
                            <p style="color:#FC0">&nbsp;&nbsp;&nbsp;&nbsp;3. 兼容性： 如果使用了透明代理模式，这可能会与<b>其他代理插件可能产生冲突</b> ，使用前要关闭其他透明代理插件。</p>
                            <p style="color:#FC0">&nbsp;&nbsp;&nbsp;&nbsp;4. <b style="color: rgb(32, 252, 32);">透明代理</b>：局域网不用做任何设置即可科学上网。</p>
                            <p style="color:#FC0">&nbsp;&nbsp;&nbsp;&nbsp;5. 关闭透明代理，可结合 <b>switchyomega插件</b> 使用SOCKS5代理端口： <b>1080</b> ! 非大陆IP自动使用代理转发。</p>
                            <p style="color:#FC0">&nbsp;&nbsp;&nbsp;&nbsp;6. 代理节点切换模式： </p>
                            <p style="color:#FC0">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-<b>url-test</b>: 优先选择低延迟节点。定期验证可用性并进行延迟排序。<b>推荐选择此模式！默认使用此模式。</b> </p>
                            <p style="color:#FC0">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-<b>select</b>: 按配置顺序选择结点。<b>使用哪个结点你说了算!</b>，但结点不可用时你得自己切换。 </p>
                            <p style="color:#FC0">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-<b>fallback</b>: 按顺序选择第一个可用代理，与 url-test 区别是 <b>不按照延迟排序</b> 。</p>
                            <p style="color:#FC0">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-<b>load-balance</b>: 个人不建议使用，应用场景：同一个域名请求使用相同节点，<b>适合并发多网站请求模式</b> 。</p>
                            <p style="text-align: center; color: #FC0; font-size: 20px;">闲话少说！<b style="font-size: 25px;">安装即用</b>就对了。</p>
                        </div>

                    </div>
                    <!-- Tab菜单 -->
                    <div id="tabs">
                        <button id="btn_default_tab" class="tab" onclick="switch_tabs(event, 'menu_default')">帐号设置</button>
                        <button class="tab" onclick="switch_tabs(event, 'menu_provider_update')">更新管理</button>
                        <button class="tab" onclick="switch_tabs(event, 'menu_group_add')">添加节点</button>
                        <button class="tab" onclick="switch_tabs(event, 'menu_group_delete');update_node_list();">删除节点</button>
                        <button class="tab" onclick="switch_tabs(event, 'menu_options');">可选配置</button>
                        <button class="tab" onclick="switch_tabs(event, 'menu_ddns');">CF动态DNS</button>
                        <button class="tab" onclick="switch_tabs(event, 'menu_netflix');">解锁Netflix</button>
                        
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
                                <label>开启Clash服务:</label>
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
                                <div id="clash_version_status">
                                    <i>当前版本：<% dbus_get_def("clash_version", "未知" ); %></i>
                                </div>
                                <div id="clash_install_show" style="padding-top:5px;margin-left:330px;margin-top:-25px;">
                                    <button id="btn_update_ver" style="display: none;" type="button" class="button_gen" onclick="update_clash_bin()" href="javascript:void(0);">更新版本</button>
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
                                    <select id="clash_group_type" onchange="switch_group_type();" class="input_option" style="width:180px;margin:0px 0px 0px 2px;">
                                        <option value="select">【1】 select模式</option>
                                        <option value="url-test">【2】 url-test模式</option>
                                        <option value="fallback">【3】 fallback模式</option>
                                        <option value="load-balance">【4】 LB负载均衡模式</option>
                                    </select>
                                </div>
                            </td>
                        </tr>
                        <tr>
                            <th>Web控制面板:</th>
                            <td colspan="2">
                                <span>默认URL地址: <b>http://192.168.50.1:9090</b> 默认密码：<b>route</b></span><br>
                                <a type="button" class="button_gen" href="/ext/dashboard/yacd/index.html" target="_blank">Clash面板</a>
                            </td>
                        </tr>
                    </table>
                    <!-- 订阅源URL更新部分 -->
                    <table id="menu_provider_update" class="FormTable">
                        <thead>
                            <tr>
                                <td colspan="2">Clash -更新管理</td>
                            </tr>
                        </thead>
                        <tr>
                            <th>走Clash代理(URL被墙时使用):</th>
                            <td colspan="2">
                                <div class="switch_field">
                                    <label for="clash_use_local_proxy">
                                        <input id="clash_use_local_proxy" onclick="swtich_use_localhost_proxy();" class="switch" type="checkbox" style="display: none;">
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
                                <label>订阅源URL链接:</label>
                            </th>
                            <td colspan="2">
                                <span>
                                    1. 分享免费订阅源(下载失败率较大) <a style="color:chartreuse" href="https://cdn.jsdelivr.net/gh/learnhard-cn/free_proxy_ss@main/clash/clash.provider.yaml" target="_blank" rel="noopener noreferrer">Github订阅源(原始链接)</a> <br>
                                    2. 分享免费订阅源(CDN访问，成功率高) <a style="color:chartreuse" href="https://cdn.jsdelivr.net/gh/learnhard-cn/free_proxy_ss@main/clash/clash.provider.yaml" target="_blank" rel="noopener noreferrer">Github订阅源(CDN)</a> <br>
                                </span>
                                <input type="url" placeholder="# 此处填入节点订阅源URL地址！yaml文件格式！" id="clash_provider_file" class="input_text">
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
                                <span>
                                    1. 全量GeoIP版本(6MB左右) <a style="color:chartreuse" href="https://github.com/Dreamacro/maxmind-geoip" target="_blank" rel="noopener noreferrer">Github项目地址</a> <br>
                                    2. 精简版(200KB左右，默认使用) <a style="color: chartreuse;" href="https://github.com/Hackl0us/GeoIP2-CN" target="_blank" rel="noopener noreferrer">Github项目地址</a><br>
                                    3. 全量多源合并版(6MB左右) <a style="color: chartreuse;" href="https://github.com/alecthw/mmdb_china_ip_list" target="_blank" rel="noopener noreferrer">Github项目地址</a> 
                                </span>
                                <input type="text" class="input_text" id="clash_geoip_url" placeholder="设置GeoIP数据URL地址(已经内置精简版地址)">
                            </td>
                        </tr>
                        <tr>
                            <td colspan="2">
                                <button type="button" class="button_gen" onclick="update_geoip()" href="javascript:void(0);">更新Country.mmdb</button>
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
                            <td colspan="2" style="text-align: left;">
                                <p style="text-align: left;color: burlywood;">温馨提示：添加新节点会<b style="color: chocolate;font-size: 20px;">覆盖</b> 已有节点。</p>
                                <p style="text-align: left; color: rgb(19, 209, 41); font-size: 25px;padding-top: 10px;padding-bottom: 10px;">支持解析URI格式:</p>
                                <p style="font-size: 20px;color:rgb(19, 209, 41)"><b style="color: aquamarine;">ss://</b>base64string@host:port/?plugin=xxx&obfs=xxx&obfs-host=xxx#notes</p>
                                <p style="color:#FC0">其中，ss的base64string格式为：method:password</p>
                                <p style="font-size: 20px;color:rgb(19, 209, 41)"><b style="color: aquamarine;">ss://</b>base64string</p>
                                <p style="color:#FC0">其中，ss的base64string内容格式：method:password@host:port </p>
                                <p style="font-size: 20px;color:rgb(19, 209, 41)"><b style="color: aquamarine;">ssr://</b>server:server_port:protocol:method:obfs:base64-encode-password/?obfsparam=base64-encode-string&protoparam=base64-encode-string&remarks=base64-encode-string&group=base64-encode-string</p>
                                <p style="font-size: 20px;color:rgb(19, 209, 41)"><b style="color: aquamarine;">vmess://</b>base64string</p>
                                <p style="color:#FC0">其中，vmess的base64string内容为JSON配置格式： {"add":"server_ip","v":"2","ps":"name","port":158,"id":"683ec608-5af9-4f91-bd5b-ce493307fe56","aid":"0","net":"ws","type":"","host":"","path":"/path","tls":"tls"}</p>
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
                    <!-- netflix解锁配置信息 -->
                    <table id="menu_netflix" class="FormTable">
                        <thead>
                            <td colspan="2">使用前说明</td>
                        </thead>
                        <tr>
                            <td colspan="2">
                                解锁Netflix方式只能<b style="color: #FC0;">选择其中一个</b>有效的方式即可!
                            </td>
                        </tr>
                        <thead>
                            <td colspan="2">Clash-中继代理解锁Netflix配置</td>
                        </thead>
                        <tr>
                            <td colspan="2">中继解锁适用于解锁机<b>无法直连</b>或<b>直连速度慢</b>等情况，如需更多中继节点可自己修改配置。</td>
                        </tr>
                        <tr>
                            <th>中继代理开关:</th>
                            <td>
                                <div class="switch_field">
                                    <label for="clash_relay_enable">
                                        <input id="clash_relay_enable" class="switch" type="checkbox" style="display: none;">
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
                                <label>中继代理入口(代理机):</label>
                            </th>
                            <td colspan="2">
                                <div class="switch_field">
                                    <select id="clash_relay01" onchange="update_relay01();" class="input_option" style="width:180px;margin:0px 0px 0px 2px;">
                                    </select>
                                </div>
                            </td>
                        </tr>
                        <tr>
                            <th>中继代理出口(解锁机):</th>
                            <td colspan="2">
                                <div class="switch_field">
                                    <select id="clash_relay02" class="input_option" style="width:180px;margin:0px 0px 0px 2px;">
                                    </select>
                                </div>
                            </td>
                        </tr>
                        <tr>
                            <td colspan="2">
                                <button type="button" class="button_gen" onclick="update_netflix_relay()" href="javascript:void(0);">更新中继列表</button>
                            </td>
                        </tr>
                        <thead>
                            <td colspan="2">Clash-DNS解锁Netflix配置</td>
                        </thead>
                        <tr>
                            <td colspan="2">
                                <b>DNS解锁Netflix方式</b>简单，只需要<b>使用特定DNS</b>解析netflix相关域名就可以实现解锁Netflix。<br>
                                <b style="color: #FC0;">注意:</b>确定<b>DNS地址</b>可以访问(能ping通)。
                            </td>
                        </tr>
                        <tr>
                            <th>DNS解锁Netflix开关:</th>
                            <td>
                                <div class="switch_field">
                                    <label for="clash_netflixdns_enable">
                                        <input id="clash_netflixdns_enable" class="switch" type="checkbox" style="display: none;">
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
                                <label>解锁Netflix的<b>DNS地址</b>:</label>
                            </th>
                            <td colspan="2">
                                <input type="text" class="input_text" id="clash_netflix_dns" placeholder="输入解锁Netflix地区影片的DNS服务器">
                            </td>
                        </tr>
                        <tr>
                            <th>
                                <label><b>解锁机</b>IP(被墙需要走代理时配置):</label>
                            </th>
                            <td colspan="2">
                                <input type="text" class="input_text" id="clash_netflix_sniproxy" placeholder="可为空，输入Netflix解锁sniproxy服务器地址(解锁机)">
                            </td>
                        </tr>
                        <tr>
                            <td colspan="2">
                                <button type="button" class="button_gen" onclick="update_netflix_dns()" href="javascript:void(0);">更新解锁DNS</button>
                            </td>
                        </tr>
                    </table>
                    <!-- 可选配置信息 -->
                    <table id="menu_options" class="FormTable">
                        <thead>
                            <tr>
                                <td colspan="2">Clash - 可选配置</td>
                            </tr>
                        </thead>
                        
                        <tr>
                            <th>启用黑名单模式(<b>建议开启</b> ):</th>
                            <td colspan="2">
                                <div class="switch_field">
                                    <label for="clash_gfwlist_mode">
                                        <input id="clash_gfwlist_mode" onclick="switch_gfwlist_mode();" class="switch" type="checkbox" style="display: none;">
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
                                <label>透明代理模式开关(<b>建议启用</b> ):</label>
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
                                <label>路由器信息:</label>
                            </th>
                            <td colspan="2">
                                <button type="button" class="button_gen" onclick="show_router_info()" href="javascript:void(0);">查看路由信息</button>
                            </td>
                        </tr>
                    </table>
                    <!-- 可选配置信息 -->
                    <table id="menu_ddns" class="FormTable">
                        <thead>
                            <tr>
                                <td colspan="2">配置DDNS(CloudFlare动态DNS)</td>
                            </tr>
                        </thead>
                        <tr>
                            <th>启用CloudflareDDNS功能:</th>
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
                            <th>
                                <label>Email邮箱地址：</label>
                            </th>
                            <td colspan="2">
                                <input type="email" class="input_text" name="email" id="clash_cfddns_email" placeholder="CF注册的邮箱：you@example.com">
                            </td>
                        </tr>
                        <tr>
                            <th>
                                <label>API KEY：</label>
                            </th>
                            <td colspan="2">
                                <span>获取方法：<a target="_blank" style="color: greenyellow;" href="https://dash.cloudflare.com/profile/api-tokens">直达Cloudflare链接(查看<b>Global API Key</b>)</a> </span>
                                <input type="text" class="input_text" id="clash_cfddns_apikey" placeholder="获取方法：">
                            </td>
                        </tr>
                        <tr>
                            <th title="提前添加一条A记录（例如:home,IPv4地址可以写 127.0.0.1，添加成功后会更新，这里就填写 home.example.com,其中 example.com 是您的购买的域名）">
                                <label>Domain(<b>多域名逗号分割</b>)：</label>
                            </th>
                            <td colspan="2">
                                <input type="text" class="input_text" id="clash_cfddns_domain" placeholder="示例：home.example.com,test.example.com">
                            </td>
                        </tr>
                        <tr>
                            <th title="设置解析TTL，免费版的范围是120-86400,设置1为自动,默认值为1(调度更新时间2分钟)">
                                <label>TTL生命周期[?]<b>(可不填)</b> ：</label>
                            </th>
                            <td colspan="2">
                                <input type="text" class="input_text" class="input_text" id="clash_cfddns_ttl" placeholder="范围是120-86400,设置1为自动,默认值为1(调度更新时间2分钟)">
                            </td>
                        </tr>
                        <tr>
                            <th title="自动获取公网IP地址的检测命令，尽量自建或选择信任的网站！">
                                <label>获取公网IP命令[?]<b>(可不填)</b> ：</label>
                            </th>
                            <td colspan="2">
                                <input type="text" class="input_text" id="clash_cfddns_ip" placeholder="curl https://httpbin.org/ip|grep origin|cut -d\&quot; -f4">
                            </td>
                        </tr>
                        <tr>
                            <th>
                                <label>最后一次更新时间：</label>
                            </th>
                            <td colspan="2">
                                <p>
                                    <div style="color: chartreuse;font-size: 18px;" id="clash_cfddns_lastmsg"></div>
                                </p>

                            </td>
                        </tr>
                    </table>
                    <!--打开 Clash控制面板-->
                    <div style="display: inline-table;padding-top: 15px;">
                        <a type="button" class="button_gen" onclick="get_proc_status();" href="javascript:void(0);">状态检查</a>
                    </div>
                    <div>
                        <div><img id="loadingIcon" style="display:none;" src="/images/loading.gif"></div>
                    </div>

                    <div style="margin-top:8px" id="logArea">
                        <div style="display: block;text-align: center; font-size: 14px;">显示日志信息</div>
                        <textarea cols="63" rows="30" wrap="off" readonly="readonly" id="clash_text_log" class="input_text"></textarea>
                    </div>

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