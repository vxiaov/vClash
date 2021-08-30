"use strict";
var $$ = document
    , random = parseInt(1e8 * Math.random())
    , IP = {
        get: function (t, e) {
            return fetch(t, {
                method: "GET"
            }).then(function (t) {
                return "text" === e ? Promise.all([t.ok, t.status, t.text(), t.headers]) : Promise.all([t.ok, t.status, t.json(), t.headers])
            }).then(function (t) {
                var e = t[0]
                    , n = t[1]
                    , i = t[2]
                    , r = t[3];
                if (e)
                    return {
                        ok: e,
                        status: n,
                        data: i,
                        headers: r
                    };
                throw new Error([e, n, i, r])
            }).catch(function (t) {
                throw t
            })
        },
        parseIPIpapi: function (t, e) {
            IP.get("https://api.skk.moe/network/parseIp/ipip/v3/" + t, "json").then(function (t) {
                $$.getElementById(e).innerHTML = t.data.country + " " + t.data.regionName + " " + t.data.city + " " + t.data.isp
            })
        },
        parseIPIpip: function (t, o) {
            IP.get("https://api.skk.moe/network/parseIp/ipip/v3/" + t, "json").then(function (t) {
                var e = ""
                    , n = t.data
                    , i = Array.isArray(n)
                    , r = 0;
                for (n = i ? n : n[Symbol.iterator](); ;) {
                    var a;
                    if (i) {
                        if (r >= n.length)
                            break;
                        a = n[r++]
                    } else {
                        if ((r = n.next()).done)
                            break;
                        a = r.value
                    }
                    e += "" !== a ? a + " " : ""
                }
                $$.getElementById(o).innerHTML = e
            })
        },
        parseCZ88Ip: function (t, e) {
            IP.get("https://qqwry.api.skk.moe/" + t, "json").then(function (t) {
                $$.getElementById(e).innerHTML = t.data.geo || t.data.msg
            })
        },
        getIpipnetIP: function () {
            IP.get("https://forge.speedtest.cn/api/location/info?z=" + random, "json").then(function (t) {
                var e = t.data
                    , n = [e.country];
                e.province === e.city ? n.push(e.province) : (n.push(e.province),
                    n.push(e.city)),
                    n.push(e.distinct),
                    n.push(e.isp);
                var i = n.filter(Boolean).join(" ");
                $$.getElementById("ip-ipipnet").innerHTML = "<p>" + e.ip + '</p><p class="sk-text-small">' + i + "</p>"
            })
        },
        getTaobaoIP: function (t) {
            $$.getElementById("ip-taobao").innerHTML = t.ip,
                IP.parseIPIpip(t.ip, "ip-taobao-ipip")
        },
        getSohuIP: function () {
            IP.get("https://myip.ipip.net/?z=" + random, "text").then(function (t) {
                var e = t.data.replace("当前 IP：", "").split(" 来自于：");
                $$.getElementById("ip-sohu").innerHTML = "<p>" + e[0] + '</p><p class="sk-text-small">' + e[1] + "</p>"
            })
        },
        getIpsbIP: function () {
            IP.get("https://api.ip.sb/geoip", "json").then(function (t) {
                var e = t.data
                    , n = function (t) {
                        return Boolean(t) ? t + " " : " "
                    };
                $$.getElementById("ip-ipsb").innerHTML = e.ip,
                    $$.getElementById("ip-ipsb-geo").innerHTML = "" + n(e.country) + n(e.region) + n(e.city) + n(e.organization)
            })
        }
    }
    , HTTP = {
        checker: function (t, e) {
            var n = new Image
                , i = setTimeout(function () {
                    n.onerror = n.onload = null,
                        $$.getElementById(e).innerHTML = '<span class="sk-text-error">连接超时</span>',
                        n.src = null
                }, 6e3);
            n.onerror = function () {
                clearTimeout(i),
                    $$.getElementById(e).innerHTML = '<span class="sk-text-error">无法访问</span>'
            }
                ,
                n.onload = function () {
                    clearTimeout(i),
                        $$.getElementById(e).innerHTML = '<span class="sk-text-success">连接正常</span>'
                }
                ,
                n.src = "https://" + t + "/favicon.ico?" + +new Date
        },
        runcheck: function () {
            HTTP.checker("www.baidu.com", "http-baidu"),
                HTTP.checker("s1.music.126.net/style", "http-163"),
                HTTP.checker("github.com", "http-github"),
                HTTP.checker("www.youtube.com", "http-youtube")
        }
    };

function checkIP() {
    HTTP.runcheck();
    IP.getIpipnetIP();
    IP.getIpsbIP();
    IP.getSohuIP();
}
