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
    <script type="text/javascript">
        var $j = jQuery.noConflict();

        function E(e) {
            return (typeof(e) == 'string') ? document.getElementById(e) : e;
        }
        function init() {
            show_menu(menu_hook);
            buildswitch();
            version_show();
            var rrt = document.getElementById("switch");
            if (document.form.clash_enable.value != "1") {
                rrt.checked = false;
            } else {
                rrt.checked = true;
            }
        }

        function buildswitch() {
            $j("#switch").click(
                function() {
                    if (document.getElementById('switch').checked) {
                        document.form.clash_enable.value = 1;
                    } else {
                        document.form.clash_enable.value = 0;
                    }
                });
        }

        var _responseLen;
        var noChange = 0;

        function get_proc_status() {
            var dbus = {};
            dbus["SystemCmd"] = "clash_proc_status.sh";
            dbus["action_mode"] = " Refresh ";
            dbus["current_page"] = "Module_kms.asp";
            $j.ajax({
                type: "POST",
                url: '/applydb.cgi?p=clash_',
                contentType: "application/x-www-form-urlencoded",
                dataType: 'text',
                data: dbus,
                success: function(response) {
                    // 检查结果
                    setTimeout("write_proc_status();", 500);
                }
            });
        }

        var noChange3 = 0;
        function write_proc_status() {
            E("textarea").value = ""
            $j.ajax({
                url: '/res/clash_proc_status.htm',
                dataType: 'html',
                error: function(xhr) {
                    setTimeout("write_proc_status();", 1400);
                },
                success: function(response) {
                    var retArea = E("textarea");
                    if (response.search("XU6J03M6") != -1) {
                        retArea.value = response.replace("XU6J03M6", " ");
                        //retArea.scrollTop = retArea.scrollHeight;
                        return true;
                    } else {}
                    if (_responseLen == response.length) {
                        noChange3++;
                    } else {
                        noChange3 = 0;
                    }
                    if (noChange3 > 100) {
                        return false;
                    } else {
                        setTimeout("write_proc_status();", 500);
                    }
                    retArea.value = response.replace("XU6J03M6", " ");
                    //retArea.scrollTop = retArea.scrollHeight;
                    _responseLen = response.length;
                }
            });
        }


        function checkCmdRet() {
            $j.ajax({
                url: '/cmdRet_check.htm',
                dataType: 'html',
                error: function(xhr) {
                    setTimeout("checkCmdRet();", 1000);
                },
                success: function(response) {
                    var retArea = document.getElementById("textarea");
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
                    retArea.value = response;
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
            tabtitle[tabtitle.length - 1] = new Array("", "Clash");
            tablink[tablink.length - 1] = new Array("", "Module_clash.asp");
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
        <input type="hidden" id="clash_enable" name="clash_enable" value='<% dbus_get_def("clash_enable", "0"); %>' />
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
                    <div class="clash_all">
                        <div class="clash_top">
                            <div style="float:left;" class="formfonttitle">系统工具- Clash科学上网 </div>
                            <div style="float:right; width:15px; height:25px;margin-top:10px">
                                <img id="return_btn" onclick="reload_Soft_Center();" align="right" style="cursor:pointer;position:absolute;margin-left:-30px;margin-top:-25px;" title="返回软件中心" src="/images/backprev.png" onMouseOver="this.src='/images/backprevclick.png'" onMouseOut="this.src='/images/backprev.png'"></img>
                            </div>
                            <div style="margin-left:5px;margin-top:10px;margin-bottom:10px">
                                <img src="/images/New_ui/export/line_export.png">
                            </div>
                        </div>
                        <div id="main_content" style="text-align: center;">
                            <div style="display:table-cell;float: left; padding-left: 20px;">Clash服务开关： </div>
                            <div class="switch_field" style="display:table-cell;float: left;">
                                <label for="switch">
                                    <input id="switch" class="switch" type="checkbox" style="display: none;">
                                    <div class="switch_container">
                                        <div class="switch_bar"></div>
                                        <div class="switch_circle transition_style"></div>
                                    </div>
                                </label>
                            </div>
                            <div id="clash_version_status" style="padding-top:5px;margin-left:230px;margin-top:0px;">
                                <i>当前版本：<% dbus_get_def("clash_version", "未知" ); %></i>
                            </div>
                            <div id="clash_install_show" style="padding-top:5px;margin-left:330px;margin-top:-25px;">
                            </div>
                        </div>
                    </div>
                    <div style="margin-left:5px;margin-top:10px;margin-bottom:10px">
                        <img src="/images/New_ui/export/line_export.png">
                    </div>
                    <div class="apply_gen">
                        <button id="cmdBtn" class="button_gen" onclick="onSubmitCtrl(this, ' Refresh ')">提交</button>
                        <img id="loadingIcon" style="display:none;" src="/images/loading.gif">
                        <a type="button" class="ss_btn" style="cursor:pointer" onclick="get_proc_status(3)" href="javascript:void(0);">详细状态</a>
                    </div>
                    <div style="margin-top:8px" id="logArea">
                        <textarea cols="63" rows="27" wrap="off" readonly="readonly" id="textarea" style="width:99%;font-family:Courier New, Courier, mono; font-size:11px;background:#475A5F;color:#FFFFFF;">
                            <% nvram_dump("syscmd.log",""); %>
                        </textarea>
                    </div>
                    <div style="margin-left:5px;margin-top:10px;margin-bottom:10px"><img src="/images/New_ui/export/line_export.png" /></div>
                    <div class="KoolshareBottom" style="margin-top:540px;">
                        技术支持： <a href="https://t.me/share_proxy_001" target="_blank" rel="noopener noreferrer">电报群:@share_proxy_001</a>
                        <a href="http://vlike.work/" target="_blank">
                            <i><u>http://vlike.work</u></i> </a> <br /> Github项目：
                        <a href="https://github.com/learnhard-cn/clash" target="_blank">
                            <i><u>https://github.com/learnhard-cn/clash</u></i> </a> <br /> Shell by： <i>Awkee</i> , Web by： <i>Awkee</i>
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
<script type="text/javascript">
    <!--[if !IE]>-->
    (function($) {
        var textArea = document.getElementById('textarea');
        textArea.scrollTop = textArea.scrollHeight;
    })(jQuery);
    <!--<![endif]-->
</script>

</html>