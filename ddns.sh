#!/bin/bash

# 配置参数
interval=60       # 更新间隔（秒）
domain="ddns.ddnsfanke.ddns-ip.net"  # 替换为你的域名
token="fbdd26343facbf9ac81538c32328e722"   # 替换为你的API Token
api_url="https://dns.cngames.site/ddnsapi.php"

# 获取IPv4地址函数
get_ipv4() {
    curl -s https://ddns.oray.com/checkip | \
    grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' || echo "未找到IPv4地址"
}

# 获取IPv6地址函数
get_ipv6() {
    # 查找以240开头的全局IPv6地址
    ip -6 addr show | \
    grep -E 'inet6 240' | \
    awk '{print $2}' | \
    cut -d'/' -f1 | \
    head -n1 || echo "未找到IPv6地址"
}

# 更新DNS函数
update_dns() {
    local addr_type=$1
    local ip=$2
    local response
    
    response=$(curl -s "$api_url?domain=$domain&token=$token&addr=$ip")
    
    if [[ $response == *"\"success\":true"* ]]; then
        echo "[$(date)] $addr_type DNS更新成功: $ip"
    else
        echo "[$(date)] $addr_type DNS更新失败: $response"
    fi
}

# 主循环
while true; do
    ipv4=$(get_ipv4)
    ipv6=$(get_ipv6)
    
    echo "检测到IPv4: $ipv4"
    echo "检测到IPv6: $ipv6"
    
    # 优先使用IPv6
    if [ "$ipv6" != "未找到IPv6地址" ]; then
        update_dns "IPv6" "$ipv6"
    elif [ "$ipv4" != "未找到IPv4地址" ]; then
        update_dns "IPv4" "$ipv4"
    else
        echo "[$(date)] 错误：未找到有效IP地址"
    fi
    
    sleep $interval
done