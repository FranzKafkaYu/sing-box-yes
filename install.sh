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
		"servers": [
			{
				"tag": "cloudflare",
				"address": "1.1.1.1",
				"strategy": "ipv4_only",
				"detour": "direct"
			},
			{
				"tag": "video",
				"address": "203.9.150.233",
				"strategy": "ipv4_only",
				"detour": "direct"
			}
		],
		"rules": [
			{
				"rule_set": [
					"geosite-netflix",
					"geoip-netflix",
					"geosite-now",
					"geosite-disney",
					"geosite-openai",
					"geosite-dazn",
					"geosite-tvb",
					"geosite-primevideo",
					"geosite-hbo"
				],
				"server": "video"
			}
		],
		"final": "cloudflare",
		"strategy": "",
		"disable_cache": false,
		"disable_expire": false
	},
	"inbounds": [
		{
			"type": "hysteria2",
			"listen": "::",
			"listen_port": 1538,
			"users": [
				{
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
		},
		{
			"type": "vless",
			"listen": "::",
			"listen_port": 2538,
			"users": [
				{
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
	"outbounds": [
		{
			"type": "direct",
			"tag": "direct"
		}
	],
	"route": {
		"rule_set": [
			{
				"type": "remote",
				"format": "binary",
				"tag": "geosite-netflix",
				"url": "https://wiki.jokin.uk/geo/geosite/netflix.srs"
			},
			{
				"type": "remote",
				"format": "binary",
				"tag": "geoip-netflix",
				"url": "https://wiki.jokin.uk/geo/geoip/netflix.srs"
			},
			{
				"type": "remote",
				"format": "binary",
				"tag": "geosite-now",
				"url": "https://wiki.jokin.uk/geo/geosite/now.srs"
			},
			{
				"type": "remote",
				"format": "binary",
				"tag": "geosite-disney",
				"url": "https://wiki.jokin.uk/geo/geosite/disney.srs"
			},
			{
				"type": "remote",
				"format": "binary",
				"tag": "geosite-openai",
				"url": "https://wiki.jokin.uk/geo/geosite/openai.srs"
			},
			{
				"type": "remote",
				"format": "binary",
				"tag": "geosite-dazn",
				"url": "https://wiki.jokin.uk/geo/geosite/dazn.srs"
			},
			{
				"type": "remote",
				"format": "binary",
				"tag": "geosite-tvb",
				"url": "https://wiki.jokin.uk/geo/geosite/tvb.srs"
			},
			{
				"type": "remote",
				"format": "binary",
				"tag": "geosite-primevideo",
				"url": "https://wiki.jokin.uk/geo/geosite/primevideo.srs"
			},
			{
				"type": "remote",
				"format": "binary",
				"tag": "geosite-hbo",
				"url": "https://wiki.jokin.uk/geo/geosite/hbo.srs"
			}
		],
		"auto_detect_interface": true,
		"final": "direct"
	},
	"experimental": {
		"cache_file": {
			"enabled": true,
			"path": "cache.db",
			"cache_id": "mycacheid",
			"store_fakeip": true
		}
	}
}
EOF

# 最后重启sing-box
sing-box restart
