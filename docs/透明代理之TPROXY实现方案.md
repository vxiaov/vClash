# 透明代理之TPROXY实现方案
> 简略的语言，详述TPROXY实现透明代理解决方案。



TPROXY资料参考:
- [TPROXY透明代理支持](https://www.kernel.org/doc/html/latest/networking/tproxy.html): 内核支持TPROXY模块实现透明代理介绍。
- [Hysteria 2](https://v2.hysteria.network/docs/advanced/TPROXY/) ： 使用owner防止数据包回环问题。
- [对比REDIRECT/DNET/TPROXY的区别](https://gsoc-blog.ecklm.com/iptables-redirect-vs.-dnat-vs.-tproxy/)


## 配置过程

1. 加载TPROXY内核模块: 华硕路由器默认不加载 xt_TPROXY 内核模块，在需要时手动加载。
2. 配置iptables规则和路由策略，路由器流量汇聚到clash的 tproxy-port 端口进行透传处理。


### 加载TPROXY内核模块

```bash
modprobe xt_TPROXY || echo "加载 xt_TPROXY 模块失败!"

#额外需要 socket 模块,避免已有连接的包二次通过 TPROXY
modprobe xt_socket || echo "加载 xt_socket 模块失败!"


# 查找是否支持 xt_TPROXY 模块
find / -name "*TPROXY*"

/lib/modules/4.1.27/kernel/net/netfilter/xt_TPROXY.ko
/sys/module/xt_TPROXY
/usr/lib/xtables/libxt_TPROXY.so

```
其中， xt_TPROXY.ko 就是内核模块文件，找不到则说明路由器固件不支持TPROXY模块。


### 设置路由策略

```bash
# 设置策略路由 v4
tbname="clash"
# 为标记为 1 的数据包添加一条路由规则
ip rule add fwmark 1 table ${tbname}
# 将路由表的数据包路由到 lo 设备
ip route add local 0.0.0.0/0 dev lo table ${tbname}
# 设置策略路由 v6
ip -6 rule add fwmark 1 table 106
ip -6 route add local ::/0 dev lo table 106

```

### 配置iptables规则(ipv4+ipv6)

下面是透传TCP+UDP的配置规则（支持IPv4+IPv6)：
```bash
# 新建 DIVERT 规则，避免已有连接的包二次通过 TPROXY，理论上有一定的性能提升
iptables -t mangle -N DIVERT
iptables -t mangle -F DIVERT
iptables -t mangle -A DIVERT -j MARK --set-mark 1
iptables -t mangle -A DIVERT -j ACCEPT
iptables -t mangle -A PREROUTING -p tcp -m socket -j DIVERT

# 代理局域网设备 v4
iptables -t mangle -N XRAY
iptables -t mangle -F XRAY
iptables -t mangle -A XRAY -m set --match-set localnet4 dst -j RETURN
iptables -t mangle -A XRAY -j RETURN -m mark --mark 0xff
iptables -t mangle -A XRAY -p udp -j TPROXY --on-ip 127.0.0.1 --on-port ${tproxy_port} --tproxy-mark 1
iptables -t mangle -A XRAY -p tcp -j TPROXY --on-ip 127.0.0.1 --on-port ${tproxy_port} --tproxy-mark 1
iptables -t mangle -A PREROUTING -p udp -j XRAY
iptables -t mangle -A PREROUTING -p tcp -j XRAY

# 代理网关本机 v4
iptables -t mangle -N XRAY_MASK
iptables -t mangle -A XRAY_MASK -m set --match-set localnet4 dst -j RETURN
iptables -t mangle -A XRAY_MASK -j RETURN -m mark --mark 0xff
iptables -t mangle -A XRAY_MASK -p udp -j MARK --set-mark 1
iptables -t mangle -A XRAY_MASK -p tcp -j MARK --set-mark 1
iptables -t mangle -A OUTPUT -p udp -j XRAY_MASK
iptables -t mangle -A OUTPUT -p tcp -j XRAY_MASK

# 设置策略路由 v6
ip -6 rule add fwmark 1 table 106
ip -6 route add local ::/0 dev lo table 106

# 新建 DIVERT 规则，避免已有连接的包二次通过 TPROXY，理论上有一定的性能提升
ip6tables -t mangle -N DIVERT
ip6tables -t mangle -A DIVERT -j MARK --set-mark 1
ip6tables -t mangle -A DIVERT -j ACCEPT
ip6tables -t mangle -A PREROUTING -p tcp -m socket -j DIVERT

# # 代理局域网设备 v6
ip6tables -t mangle -N XRAY6
ip6tables -t mangle -F XRAY6
ip6tables -t mangle -A XRAY6 -m set --match-set localnet6 dst -j RETURN
ip6tables -t mangle -A XRAY6 -j RETURN -m mark --mark 0xff
ip6tables -t mangle -A XRAY6 -p udp -j TPROXY --on-ip ::1 --on-port ${tproxy_port} --tproxy-mark 1
ip6tables -t mangle -A XRAY6 -p tcp -j TPROXY --on-ip ::1 --on-port ${tproxy_port} --tproxy-mark 1
ip6tables -t mangle -A PREROUTING -p udp -j XRAY6
ip6tables -t mangle -A PREROUTING -p tcp -j XRAY6

# # 代理网关本机 v6
ip6tables -t mangle -N XRAY6_MASK
ip6tables -t mangle -A XRAY6_MASK -m set --match-set localnet6 dst -j RETURN
ip6tables -t mangle -A XRAY6_MASK -j RETURN -m mark --mark 0xff
ip6tables -t mangle -A XRAY6_MASK -p udp -j MARK --set-mark 1
ip6tables -t mangle -A XRAY6_MASK -p tcp -j MARK --set-mark 1
ip6tables -t mangle -A OUTPUT -p udp -j XRAY6_MASK
ip6tables -t mangle -A OUTPUT -p tcp -j XRAY6_MASK
```

> 上面配置若是直接在路由器上使用是会有问题的，比如DNS查询返回时无法透传给原始地址。因此，我们需要暂且优化处理UDP数据报，改用NAT转发DNS查询请求给clash的DNS服务端口 dns.listen(端口通常不会是53,因为路由器自带的dnsmasq服务不能禁用DNS功能)。

### 优化后的iptables规则(解决UDP异常问题)

优化的主要逻辑：
- TCP协议数据: 由TPROXY透传规则处理
- UDP协议数据: 由NAT转发给Clash的DNS服务处理.

```bash

############ NAT转发UDP协议数据报 DNS服务 ######
iptables -t nat -A PREROUTING -p udp --dport 53 -j REDIRECT --to-ports $dns_port
iptables -t nat -A OUTPUT -p udp --dport 53 -j REDIRECT --to-ports $dns_port

######## TPROXY 处理 TCP协议数据 ##############
# 设置策略路由 v4
ip rule add fwmark 1 table 100
ip route add local 0.0.0.0/0 dev lo table 100

# 新建 ${app_name}_DIVERT 规则，避免已有连接的包二次通过 TPROXY，理论上有一定的性能提升
iptables -t mangle -N ${app_name}_DIVERT
iptables -t mangle -F ${app_name}_DIVERT
iptables -t mangle -A ${app_name}_DIVERT -j MARK --set-mark 1
iptables -t mangle -A ${app_name}_DIVERT -j ACCEPT
iptables -t mangle -A PREROUTING -p tcp -m socket -j ${app_name}_DIVERT

# 代理局域网设备 v4
! iptables -t mangle -N ${app_name}_XRAY && LOGGER "${app_name}_XRAY 表已经创建过，清理后再执行"
iptables -t mangle -F ${app_name}_XRAY
iptables -t mangle -A ${app_name}_XRAY -m set --match-set localnet4 dst -j RETURN
iptables -t mangle -A ${app_name}_XRAY -j RETURN -m mark --mark 0xff
iptables -t mangle -A ${app_name}_XRAY -p tcp -j TPROXY --on-ip 127.0.0.1 --on-port ${tproxy_port} --tproxy-mark 1
iptables -t mangle -A PREROUTING -p tcp -j ${app_name}_XRAY

# 代理网关本机 v4
iptables -t mangle -N ${app_name}_XRAY_MASK
iptables -t mangle -A ${app_name}_XRAY_MASK -m set --match-set localnet4 dst -j RETURN
iptables -t mangle -A ${app_name}_XRAY_MASK -j RETURN -m mark --mark 0xff
iptables -t mangle -A ${app_name}_XRAY_MASK -p tcp -j MARK --set-mark 1
iptables -t mangle -A OUTPUT -p tcp -j ${app_name}_XRAY_MASK

# 设置策略路由 v6
ip -6 rule add fwmark 1 table 106
ip -6 route add local ::/0 dev lo table 106

# 新建 ${app_name}_DIVERT 规则，避免已有连接的包二次通过 TPROXY，理论上有一定的性能提升
ip6tables -t mangle -N ${app_name}_DIVERT
ip6tables -t mangle -A ${app_name}_DIVERT -j MARK --set-mark 1
ip6tables -t mangle -A ${app_name}_DIVERT -j ACCEPT
ip6tables -t mangle -A PREROUTING -p tcp -m socket -j ${app_name}_DIVERT

# # 代理局域网设备 v6
ip6tables -t mangle -N ${app_name}_XRAY6
ip6tables -t mangle -F ${app_name}_XRAY6
ip6tables -t mangle -A ${app_name}_XRAY6 -m set --match-set localnet6 dst -j RETURN
ip6tables -t mangle -A ${app_name}_XRAY6 -j RETURN -m mark --mark 0xff
ip6tables -t mangle -A ${app_name}_XRAY6 -p udp -j TPROXY --on-ip ::1 --on-port ${tproxy_port} --tproxy-mark 1
ip6tables -t mangle -A ${app_name}_XRAY6 -p tcp -j TPROXY --on-ip ::1 --on-port ${tproxy_port} --tproxy-mark 1
ip6tables -t mangle -A PREROUTING -p udp -j ${app_name}_XRAY6
ip6tables -t mangle -A PREROUTING -p tcp -j ${app_name}_XRAY6

# # 代理网关本机 v6
ip6tables -t mangle -N ${app_name}_XRAY6_MASK
ip6tables -t mangle -A ${app_name}_XRAY6_MASK -m set --match-set localnet6 dst -j RETURN
ip6tables -t mangle -A ${app_name}_XRAY6_MASK -j RETURN -m mark --mark 0xff
ip6tables -t mangle -A ${app_name}_XRAY6_MASK -p udp -j MARK --set-mark 1
ip6tables -t mangle -A ${app_name}_XRAY6_MASK -p tcp -j MARK --set-mark 1
ip6tables -t mangle -A OUTPUT -p udp -j ${app_name}_XRAY6_MASK
ip6tables -t mangle -A OUTPUT -p tcp -j ${app_name}_XRAY6_MASK
```

### TPROXY模式的数据包回环问题解决办法

解决回环问题有:
- 通过gid分离数据包(前提是**内核支持OWNER模块**) ,参考[GID透明代理](https://xtls.github.io/Xray-docs-next/document/level-2/iptables_gid.html)， 需要新增用户，并且运行命令需要额外设置运行用户。
- 通过mark标记分离数据包： 此方法更简单通用。




下面是通过gid分离数据包的配置方法：
```bash

# 新增clash用户,uid=65533#
grep -qw clash_tproxy /etc/passwd || echo "clash_tproxy:x:0:65533:::" >> /etc/passwd


# 通过如下命令设置启动程序用户
start-stop-daemon -c clash_tproxy -b --start -x /koolshare/bin/clash -- -d /koolshare/clash


# iptables规则类似如下
iptables -t mangle -A OUTPUT -m owner ! --gid-owner 65533 -j XRAY_SELF

```
> 其中 clash_tproxy 是用户名，0 是 uid，23333 是 gid，用户名和 gid 可以自己定，uid 必须为 0。


对于mark标记分离数据包办法：
- 配置iptables规则，标记为0xff的数据包不再经过重复处理： `iptables -t mangle -A XRAY -j RETURN -m mark --mark 0xff`
- Clash配置文件添加默认的mark标记配置: "routing-mark: 0xff"

这样配置后，就避免了clash处理过的数据包再次无限循环回流到clash服务。


## 总结

透明代理实现方案大致如上，目前在vClash上的实际使用效果还不错，不同透明代理模式切换使用也很正常。

此功能的开发应该不会有大的改动了，算是告一段落了。
