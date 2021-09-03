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

        function init() {
            show_menu(menu_hook);
            buildswitch();
            version_show();
            var rrt = document.getElementById("switch_service");
            if (document.form.clash_enable.value != "on") {
                rrt.checked = false;
                $j("#cmdBtn").html("代理关闭中")
            } else {
                rrt.checked = true;
                $j("#cmdBtn").html("代理启用中")
            }
            var s_trans = document.getElementById("switch_trans");
            if (document.form.clash_trans.value != "on") {
                s_trans.checked = false;
            } else {
                s_trans.checked = true;
            }
        }

        function buildswitch() {
            $j("#switch_service").click(
                function() {
                    if (document.getElementById('switch_service').checked) {
                        document.form.clash_enable.value = "on";
                        document.form.clash_action.value = "start";
                        $j("#cmdBtn").html("确定启用")
                    } else {
                        document.form.clash_enable.value = "off";
                        document.form.clash_action.value = "stop";
                        $j("#cmdBtn").html("确定关闭")
                    }
                });
            $j("#switch_trans").click(
                function() {
                    if (document.getElementById('switch_trans').checked) {
                        document.form.clash_trans.value = "on";
                    } else {
                        document.form.clash_trans.value = "off";
                    }
                });
        }

        // 切换透明代理模式
        function switch_trans_mode() {
            var dbus = {};
            dbus["SystemCmd"] = "clash_control.sh";
            dbus["action_mode"] = " Refresh ";
            dbus["current_page"] = "Module_clash.asp";
            dbus["clash_trans"] = document.getElementById("clash_trans").value;
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
        function update_provider_url() {
            var dbus = {};
            dbus["SystemCmd"] = "clash_control.sh";
            dbus["action_mode"] = " Refresh ";
            dbus["current_page"] = "Module_clash.asp";
            dbus["clash_provider_url"] = document.getElementById("clash_provider_url").value;
            dbus["clash_action"] = "update_provider_url";
            apply_action(dbus);
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
                    var retArea = document.getElementById("text_log");
                    var _cmdBtn = document.getElementById("cmdBtn");
                    if (response.search("XU6J03M6") != -1) {
                        document.getElementById("loadingIcon").style.display = "none";
                        _cmdBtn.disabled = false;
                        _cmdBtn.style.color = "#FFF";
                        retArea.value = response.replace("XU6J03M6", " ");
                        retArea.scrollTop = retArea.scrollHeight;
                        return false;
                    }
                    if (_responseLen == response.length)
                        noChange++;
                    else
                        noChange = 0;
                    if (noChange > 10) {
                        document.getElementById("loadingIcon").style.display = "none";
                        _cmdBtn.disabled = false;
                        _cmdBtn.style.color = "#FFF";
                        setTimeout("checkCmdRet();", 1000);
                    } else {
                        _cmdBtn.disabled = true;
                        _cmdBtn.style.color = "#666";
                        document.getElementById("loadingIcon").style.display = "";
                        setTimeout("checkCmdRet();", 1000);
                    }
                    retArea.value = response.replace("XU6J03M6", " ");
                    retArea.scrollTop = retArea.scrollHeight;
                    _responseLen = response.length;
                }
            });
        }

        function onSubmitCtrl(o, s) {
            document.form.action_mode.value = s;
            //showLoading(3);
            document.form.submit();
            document.getElementById("cmdBtn").disabled = true;
            document.getElementById("cmdBtn").style.color = "#666";
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
                            $j("#clash_version_status").html("<i>有新版本：" + obj.name);
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
                    <div class="apply_gen">
                        <div class="clash_top">
                            <div style="float:left;" class="formfonttitle"><b>Clash</b>版科学上网工具</div>
                            <div style="float:right; width:15px; height:25px;margin-top:10px">
                                <img id="return_btn" onclick="reload_Soft_Center();" align="right" style="cursor:pointer;margin-left:-80px;margin-top:-25px;" title="返回软件中心" src="/images/backprev.png" onMouseOver="this.src='/images/backprevclick.png'" onMouseOut="this.src='/images/backprev.png'"></img>
                            </div>
                            <div class="blank_line"><img src="/images/New_ui/export/line_export.png" /></div>
                        </div>
                        <div id="main_content" style="text-align: center;">
                            <div id="clash_version_status">
                                <i>当前版本：<% dbus_get_def("clash_version", "未知" ); %></i>
                            </div>
                            <div id="clash_install_show" style="padding-top:5px;margin-left:330px;margin-top:-25px;">
                                <button id="btn_update_ver" style="display: none;" type="button" class="button_gen" onclick="update_clash_bin()" href="javascript:void(0);">更新版本</button>
                            </div>                            
                        </div>
                        <div class="blank_line"><img src="/images/New_ui/export/line_export.png" /></div>
                        <div class="proc_info">
                            <div class="switch_label">Clash服务开关： </div>
                            <div class="switch_field" style="display:table-cell;float: left; ">
                                <label for="switch_service">
                                    <input id="switch_service" class="switch" type="checkbox" style="display: none;">
                                    <div class="switch_container">
                                        <div class="switch_bar"></div>
                                        <div class="switch_circle transition_style"></div>
                                    </div>
                                </label>
                            </div>
                        </div>
                        <div class="proc_info">
                            <button id="cmdBtn" class="button_gen" onclick="onSubmitCtrl(this, ' Refresh ')">保存</button>
                        </div>
                        <div><img id="loadingIcon" style="display:none;" src="/images/loading.gif"></div>
                        <div class="blank_line"><img src="/images/New_ui/export/line_export.png" /></div>
                        <div><span><b style="color: red"> Clash服务开关</b>:控制着Clash服务的<b>启动和停止</b>！包括对<i>透明代理模式</i>选项的设置。</span></div>
                        <div class="blank_line"><img src="/images/New_ui/export/line_export.png" /></div>

                        <!-- 透明代理模式开关 -->
                        <div class="switch_label">透明代理模式开关： </div>
                        <div class="switch_field" >
                            <label for="switch_trans">
                                <input id="switch_trans" class="switch" type="checkbox" style="display: none;">
                                <div class="switch_container">
                                    <div class="switch_bar"></div>
                                    <div class="switch_circle transition_style"></div>
                                </div>
                            </label>
                        </div>
                        <div>
                            <button type="button" class="button_gen" onclick="switch_trans_mode()" href="javascript:void(0);">切换模式</button>
                        </div>
                        <div class="blank_line"><img src="/images/New_ui/export/line_export.png" /></div>
                        <div><span><b style="color: crimson;">透明代理</b>：局域网不用做任何设置即可科学上网。<br>控制<i>透明代理模式</i>选项，点击<b>切换模式</b>按钮后，会自动<b>重启Clash服务</b></span></div>
                        <div class="blank_line"><img src="/images/New_ui/export/line_export.png" /></div>

                        <!-- 订阅源URL更新部分 -->
                        <div style="display:table-cell;float: left; padding-left: 20px;">Clash节点订阅源URL地址： </div>
                        <input type="url" placeholder="# 此处填入节点订阅源URL地址！填入前确保有效的yaml文件格式哦！以免影响Clash服务状态。" id="clash_provider_url" name="clash_provider_url">
                        <div>
                            <button type="button" class="button_gen" onclick="update_provider_url()" href="javascript:void(0);">更新订阅源</button>
                        </div>
                        <div class="blank_line"><img src="/images/New_ui/export/line_export.png" /></div>

                        <!-- 日志显示部分-->
                        <div>
                            <button type="button" class="button_gen" onclick="get_proc_status()" href="javascript:void(0);">状态检查</button>
                        </div>
                        <div style="margin-top:8px" id="logArea">
                            <div style="display: block;text-align: center; font-size: 14px;">显示日志信息</div>
                            <textarea cols="63" rows="30" wrap="off" readonly="readonly" id="text_log"></textarea>
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
        var textArea = document.getElementById('text_log');
        textArea.scrollTop = textArea.scrollHeight;
    })(jQuery);
    <!--<![endif]-->
</script>

</html>