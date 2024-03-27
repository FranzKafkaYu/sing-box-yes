#!/bin/bash

VERSION="1.1.8"

info() {
    echo -e "\033[32m[Info]\033[0m $1"
}

error() {
    echo -e "\033[31m[Error]\033[0m $1"
}

red() {
    echo -e "\033[31m$1\033[0m"
}

yellow() {
    echo -e "\033[0;33m$1\033[0m"
}

blue() {
    echo -e "\033[0;34m$1\033[0m"
}

downloadSingBox() {
    prereleaseStatus=false
    version=$(curl -s "https://api.github.com/repos/SagerNet/sing-box/releases?per_page=20" | jq -r ".[]|select (.prerelease==${prereleaseStatus})|.tag_name" | head -1)
    info "Downloading SingBox"
    if [ "$(uname -m)" == "x86_64" ]; then
        file_name=sing-box-${version/v/}-linux-amd64
    elif [ "$(uname -m)" == "aarch64" ]; then
        file_name=sing-box-${version/v/}-linux-arm64
    else
        error "Unsupported CPU architecture"
        exit 1
    fi
    tar_name=${file_name}.tar.gz
    wget https://mirror.ghproxy.com/https://github.com/SagerNet/sing-box/releases/download/${version}/${tar_name} -O $tar_name
    tar -zxvf ${tar_name}
    mv ${file_name}/sing-box /usr/local/bin/singbox
    chmod +x /usr/local/bin/singbox
    blue "sb download success"
}

configSingBox() {
    mkdir ~/singbox
    echo -n "config url :"
    if [ -f ~/singbox/config.json ]; then
        info "config.json is already exist"
    else
        read config_url
        wget -O ~/singbox/config.json $config_url
    fi

    cat >/lib/systemd/system/singbox.service <<-EOF
[Unit]
Description=Singbox Default Server Service
Documentation=https://github.com/SagerNet/sing-box
After=network.target

[Service]
Type=simple
LimitNOFILE=32768
ExecStart=/usr/local/bin/singbox run -D /root/singbox/

[Install]
WantedBy=multi-user.target
EOF
    blue "sb service success"
}

installPkg() {
    yellow "install system package"
    apt update -y
    apt install unzip xz-utils wget jq curl -y
}

configSystemctl() {
    systemctl daemon-reload
    systemctl enable singbox.service
    systemctl start singbox
}

configTproxy() {
    default_interface=$(ip route | awk '/default/ {print $5}')
    cat >/etc/nftables.conf <<-EOF
#!/usr/sbin/nft -f

flush ruleset

table inet singbox {
  set local_ipv4 {
    type ipv4_addr
    flags interval
    elements = {
      10.0.0.0/8,
      127.0.0.0/8,
      169.254.0.0/16,
      172.16.0.0/12,
      192.168.0.0/16,
      240.0.0.0/4
    }
  }

  set local_ipv6 {
    type ipv6_addr
    flags interval
    elements = {
      ::ffff:0.0.0.0/96,
      64:ff9b::/96,
      100::/64,
      2001::/32,
      2001:10::/28,
      2001:20::/28,
      2001:db8::/32,
      2002::/16,
      fc00::/7,
      fe80::/10
    }
  }

  chain singbox-tproxy {
    fib daddr type { unspec, local, anycast, multicast } return
    ip daddr @local_ipv4 return
    ip6 daddr @local_ipv6 return
    udp dport { 123 } return
    meta l4proto { tcp, udp } meta mark set 1 tproxy to :9888 accept
  }

  chain singbox-mark {
    fib daddr type { unspec, local, anycast, multicast } return
    ip daddr @local_ipv4 return
    ip6 daddr @local_ipv6 return
    udp dport { 123 } return
    meta mark set 1
  }

  chain mangle-output {
    type route hook output priority mangle; policy accept;
    meta l4proto { tcp, udp } skgid != 1 ct direction original goto singbox-mark
  }

  chain mangle-prerouting {
    type filter hook prerouting priority mangle; policy accept;
    iifname {  lo, ${default_interface} } meta l4proto { tcp, udp } ct direction original goto singbox-tproxy
  }
}

EOF

    cat >/root/singbox/start.sh <<-EOF
/sbin/ip rule add fwmark 1 table 100
/sbin/ip route add local default dev lo table 100
/sbin/ip -6 rule add fwmark 1 table 101
/sbin/ip -6 route add local ::/0 dev lo table 101
/usr/local/bin/singbox run -D /root/singbox/
EOF
    chmod a+x /root/singbox/start.sh
    cat >/lib/systemd/system/singbox.service <<-EOF
[Unit]
Description=Singbox Default Server Service
Documentation=https://github.com/SagerNet/sing-box
After=network.target

[Service]
User=root
Type=simple
LimitNOFILE=32768
ExecStart=/bin/bash /root/singbox/start.sh

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl restart singbox

    systemctl enable nftables
    systemctl start nftables
    nft -f /etc/nftables.conf
}

configRedirect() {
    cat >/etc/nftables.conf <<-EOF
#!/usr/sbin/nft -f

flush ruleset

define lan = {
        0.0.0.0/8,
        10.0.0.0/8,
        127.0.0.0/8,
        169.254.0.0/16,
        172.16.0.0/12,
        192.168.0.0/16,
        224.0.0.0/4,
        240.0.0.0/4
}

table ip nat {
        chain proxy {
                ip daddr \$lan return
                ip protocol tcp redirect to :9887
        }

        chain prerouting {
                type nat hook prerouting priority 0; policy accept;
                jump proxy
        }
}

table ip mangle{
    chain output {
        type route hook output priority mangle;policy accept;
        ip daddr \$lan return
        ip protocol udp mark set 0x233
    }
    chain prerouting {
        type filter hook prerouting priority mangle; policy accept;
        ip daddr \$lan return
        ip protocol udp tproxy to :9888
    }
}
EOF

    cat >/lib/systemd/system/singbox.service <<-EOF
[Unit]
Description=Singbox Default Server Service
Documentation=https://github.com/SagerNet/sing-box
After=network.target

[Service]
Type=simple
LimitNOFILE=32768
ExecStart=/usr/local/bin/singbox run -D /root/singbox/

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl restart singbox

    systemctl enable nftables
    systemctl start nftables
    nft -f /etc/nftables.conf
}

configSystem() {
    cat >>/etc/sysctl.conf <<-EOF
net.ipv4.ip_forward = 1
net.ipv4.tcp_congestion_control = bbr
EOF
    cat >>/etc/systemd/resolved.conf <<-EOF
DNSStubListener=no
EOF
    sudo ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf
    reboot
}

# installPkg
# downloadSingBox
# configSingBox
# configSystemctl
# configSystem
upgradeSingbox() {
    downloadSingBox
    blue 'start restart singbox service'
    systemctl restart singbox
    blue "sb upgrade success"
}

uninstall() {
    systemctl stop singbox
    systemctl stop nftables
    systemctl disable singbox
    systemctl disable nftables
    systemctl daemon-reload
    rm /usr/local/bin/singbox
    rm -rf /root/singbox
    rm /etf/nftables.conf
    rm /lib/systemd/system/singbox.service

    blue "拜拜了您内"
}

showMenu() {
    yellow "1. 安装"
    yellow "2. Redirect模式安装"
    yellow "3. 更新配置"
    yellow "4. 升级Singbox"
    yellow "5. 重新配置Redirect (推荐)"
    yellow "6. 重新配置Tproxy (测试)"
    yellow "110. 卸载"
    red "0. exit"
    read -p "输入操作: " num

    if [ "$num" == "1" ]; then
        installPkg
        yellow "install singbox"
        if [ -f /usr/local/bin/singbox ]; then
            info "SingBox is already installed"
        else
            downloadSingBox
        fi
        configSingBox
        configSystemctl
        configSystem
    elif [ "$num" == "2" ]; then
        installPkg
        apt install nftables -y
        yellow "install singbox"
        if [ -f /usr/local/bin/singbox ]; then
            info "SingBox is already installed"
        else
            downloadSingBox
        fi
        configSingBox
        configSystemctl
        configRedirect
        configSystem
    elif [ "$num" == "3" ]; then
        read -p "输入配置url: " config_url
        wget -O ~/singbox/config.json.temp $config_url
        mv ~/singbox/config.json.temp ~/singbox/config.json
        systemctl restart singbox
    elif [ "$num" == "4" ]; then
        upgradeSingbox
    elif [ "$num" == "5" ]; then
        configRedirect
    elif [ "$num" == "6" ]; then
        configTproxy
    elif [ "$num" == "110" ]; then
        uninstall
    elif [ "$num" == "0" ]; then
        exit 0
    else
        error "输入错误"
    fi

}

showMenu
