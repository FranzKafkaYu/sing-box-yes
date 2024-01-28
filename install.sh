#!/bin/bash

# 创建所需目录并生成SSL证书
mkdir -p /etc/hysteria
openssl ecparam -genkey -name prime256v1 -out /etc/hysteria/private.key
openssl req -new -x509 -days 36500 -key /etc/hysteria/private.key -out /etc/hysteria/cert.pem -subj "/CN=bing.com"

# 运行安装脚本
bash <(curl -Ls https://raw.githubusercontent.com/FranzKafkaYu/sing-box-yes/master/install.sh) install

# 创建/修改配置文件
cat << EOF > /usr/local/etc/sing-box/config.json
{
    "log": {
        "disabled": false,
        "level": "info",
        "output": "/usr/local/sing-box/sing-box.log",
        "timestamp": true
    },
    "dns": {
        "servers": [{
                "address": "1.1.1.1"
            }, {
                "tag": "netflix",
                "address": "218.166.6.206"
            }
        ],
        "rules": [{
                "server": "netflix",
                "geosite": [
                    "netflix",
                    "openai",
                    "disney",
                    "dazn",
                    "amazon",
                    "hbo",
                    "now",
                    "viu",
                    "bilibili"
                ]
            }
        ]
    },
    "inbounds": [{
            "type": "hysteria2",
            "listen": "::",
            "listen_port": 1538,
            "users": [{
                    "password": "nt0538"
                }
            ],
            "masquerade": "https://bing.com",
            "tls": {
                "enabled": true,
                "alpn": [
                    "h3"
                ],
                "certificate_path": "/etc/hysteria/cert.pem",
                "key_path": "/etc/hysteria/private.key"
            }
        }, {
            "type": "vless",
            "listen": "::",
            "listen_port": 2538,
            "users": [{
                    "uuid": "nt0538",
                    "flow": "xtls-rprx-vision"
                }
            ],
            "tls": {
                "enabled": true,
                "server_name": "www.tesla.com",
                "reality": {
                    "enabled": true,
                    "handshake": {
                        "server": "www.tesla.com",
                        "server_port": 443
                    },
                    "private_key": "kPK8-OTeP2OmcLha67P476p-7V3-DHUxJ7EEMQ2vBWo",
                    "short_id": [
                        "0538"
                    ]
                }
            }
        }
    ],
    "outbounds": [{
            "type": "direct"
        }
    ]
}
EOF

# 最后重启sing-box
sing-box restart
