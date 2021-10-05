<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<html xmlns:v>
<head>
    <meta http-equiv="X-UA-Compatible" content="IE=Edge"/>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta HTTP-EQUIV="Pragma" CONTENT="no-cache">
    <meta HTTP-EQUIV="Expires" CONTENT="-1">
    <link rel="shortcut icon" href="images/favicon.png">
    <link rel="icon" href="images/favicon.png">
    <title>科学上网工具-Clash(支持免费订阅源)</title>
    <link rel="stylesheet" type="text/css" href="index_style.css"/>
    <link rel="stylesheet" type="text/css" href="form_style.css"/>
    <link rel="stylesheet" type="text/css" href="usp_style.css"/>
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
            tabtitle[tabtitle.length -1] = new Array("", "软件中心", "离线安装", "Clash版代理工具");
            tablink[tablink.length -1] = new Array("", "Module_Softcenter.asp", "Module_Softsetting.asp", "Module_clash.asp");
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
        function conf2obj(){
            var params = ['clash_group_type', 'clash_provider_file' ];
            var params_chk = ['clash_gfwlist_mode', 'clash_trans', 'clash_enable', 'clash_use_local_dns' ];
            for (var i = 0; i < params_chk.length; i++) {
                if(dbus[params_chk[i]]){
                    E(params_chk[i]).checked = dbus[params_chk[i]] == "on";
                }
            }
            for (var i = 0; i < params.length; i++) {
                if(dbus[params[i]]){
                    E(params[i]).value = dbus[params[i]];
                }
            }
        }

        function update_node_list() {
            get_dbus_data();
            var obj = document.getElementById("proxy_node_name");
            obj.options.length=0;
            const node_arr = dbus["clash_name_list"].trim().split(" ");
            for (let index = 0; index < node_arr.length; index++) {
                const element = node_arr[index];
                obj.options.add(new Option(element, element));
            }
        }

        //提交任务方法,实时日志显示
        function post_dbus_data(script, arg, obj, flag){
            var id = parseInt(Math.random() * 100000000);
            var postData = {"id": id, "method": script, "params":[arg], "fields": obj};
            $j.ajax({
                type: "POST",
                cache:false,
                url: "/_api/",
                data: JSON.stringify(postData),
                dataType: "json",
                success: function(response){
                    if(response.result == id){
                        if(flag && flag == "1"){
                            refreshpage();
                        }else if(flag && flag == "2"){
                            //continue;
                            //do nothing
                        }else{
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
            }).fail(()=>{
                console.log('failed');
            });
        }

        /*********************主要功能逻辑模块实现**************/
        function apply_action(action, data){
            if( ! action ) {
                return ;
            }
            if ( !data ) {
                data = dbus
            }
            post_dbus_data("clash_control.sh", action,  data);
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
        function swtich_localhost_dns() {
            if (document.getElementById('clash_use_local_dns').checked) {
                dbus["clash_use_local_dns"] = "on";
            } else {
                dbus["clash_use_local_dns"] = "off";
            }
            apply_action("swtich_localhost_dns");
        }
        
        function switch_gfwlist_mode(){// 切换gfwlist黑名单模式
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
        function switch_group_type() {// 更新代理组类型: select/url-test/...
            val_new = document.getElementById("clash_group_type").value;
            val_old = dbus["clash_group_type"];
            id = "btn_switch_trans";
            if (val_new != val_old) {
                dbus["clash_group_type"] = val_new;
                apply_action("switch_group_type");
            }
            
        }

        function get_proc_status(){// 查看服务运行状态
            apply_action("get_proc_status");
        }  

        function update_geoip() {// 更新GeoIP
            apply_action("update_geoip");
        }
        function update_ruleset() {// 更新ruleset
            apply_action("update_ruleset");
        }

        function update_provider_file() {// 更新节点订阅源URL
            dbus["clash_provider_file"] = document.getElementById("clash_provider_file").value;
            apply_action("update_provider_file");
        }
        function add_nodes() {// 添加DIY节点
            dbus["clash_node_list"] = document.getElementById("proxy_node_list").value;
            apply_action("add_nodes");
        }
        function delete_one_node() {// 按名称删除 DIY节点
            dbus["clash_delete_name"] = document.getElementById("proxy_node_name").value;
            apply_action("delete_one_node");
            var obj = document.getElementById("proxy_node_name");
            obj.options.remove(obj.selectedIndex);
        }
        function delete_all_nodes() {// 按名称删除 DIY节点
            apply_action("delete_all_nodes");
            var obj = document.getElementById("proxy_node_name");
            obj.options.length = 0;
        }
        function update_clash_bin() {// 按名称删除 DIY节点
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
                            <p><a href='https://github.com/Dreamacro/clash' target='_blank' rel="noopener noreferrer"><em><u>Clash</u></em></a>是一个基于规则的代理程序，支持<a href='https://github.com/shadowsocks/shadowsocks-libev' target='_blank' rel="noopener noreferrer"><em><u>SS</u></em></a>、<a href='https://github.com/shadowsocksrr/shadowsocksr-libev' target='_blank' rel="noopener noreferrer"><em><u>SSR</u></em></a>、<a href='https://github.com/v2ray/v2ray-core' target='_blank'><em><u>V2Ray</u></em></a>、<a href='https://github.com/trojan-gfw/trojan' target='_blank'><em><u>Trojan</u></em></a>等方式科学上网。</p>
                            <p style="text-align: left; color: rgb(19, 209, 41); font-size: 25px;padding-top: 10px;padding-bottom: 10px;">使用说明：</p>
                            <p style="color:#FC0">&nbsp;&nbsp;&nbsp;&nbsp;1. 特点： <b style="font-size: 25px;color: rgb(32, 252, 32);">安装即用</b>，已经内置<a href="https://github.com/learnhard-cn/free_proxy_ss"  target="_blank" style="color: rgb(32, 252, 32); text-decoration: underline;">订阅源URL地址</a> 到配置文件中。插件代码已<a href="https://github.com/learnhard-cn/clash" target="_blank" style="color: rgb(32, 252, 32);text-decoration: underline;">Github开源</a> 。 </p>
                            <p style="color:#FC0">&nbsp;&nbsp;&nbsp;&nbsp;2. 支持功能： 更新订阅源URL地址，若订阅源URL格式错误,请参考<a href="https://github.com/Dreamacro/clash/wiki/configuration#proxy-providers" target="_blank" rel="noopener noreferrer" style="color: rgb(32, 252, 32);text-decoration: underline;">Clash-Provider格式配置参考链接</a> </p>
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
                        <button class="tab" onclick="switch_tabs(event, 'menu_provider_update')">订阅源管理</button>
                        <button class="tab" onclick="switch_tabs(event, 'menu_group_add')">添加节点</button>
                        <button class="tab" onclick="switch_tabs(event, 'menu_group_delete');update_node_list();">删除节点</button>
                        <button class="tab" onclick="switch_tabs(event, 'menu_options');">可选配置</button>
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
                                <td colspan="2">Clash - 订阅源更新</td>
                            </tr>
                        </thead>
                        <tr>
                            <th>
                                <label>订阅源URL链接:</label>
                            </th>
                            <td colspan="2">
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
                    <!-- 可选配置信息 -->
                    <table id="menu_options" class="FormTable">
                        <thead>
                            <tr>
                                <td colspan="2">Clash - 可选配置</td>
                            </tr>
                        </thead>
                        <tr>
                            <th>切换本地DNS解析开关(<b>建议启用</b> ):</th>
                            <td colspan="2">
                                <div class="switch_field">
                                    <label for="clash_use_local_dns">
                                        <input id="clash_use_local_dns" onclick="swtich_localhost_dns();" class="switch" type="checkbox" style="display: none;">
                                        <div class="switch_container">
                                            <div class="switch_bar"></div>
                                            <div class="switch_circle transition_style"></div>
                                        </div>
                                    </label>
                                </div>
                            </td>
                        </tr>
                        <tr>
                            <th>启用Dnsmasq黑名单(<b>建议启用</b> ):</th>
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
                                <div class="switch_field" >
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
                                <label>GeoIP数据文件:</label>
                            </th>
                            <td colspan="2">
                                <span>
                                    全量GeoIP数据文件(6MB左右)<b>https://cdn.jsdelivr.net/gh/Dreamacro/maxmind-geoip@release/Country.mmdb</b><br>
                                    精简只包含国内IP段GeoIP文件(200KB左右，默认值) <b>https://cdn.jsdelivr.net/gh/Hackl0us/GeoIP2-CN@release/Country.mmdb</b><br>
                                </span>
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
                        <tr>
                            <th>
                                <label>路由器信息:</label>
                            </th>
                            <td colspan="2">
                                <button type="button" class="button_gen" onclick="show_router_info()" href="javascript:void(0);">查看</button>
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