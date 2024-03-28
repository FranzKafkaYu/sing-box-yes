#!/bin/bash
set -e

# 创建所需目录并生成SSL证书
echo "创建必需的目录并生成SSL证书..."
mkdir -p /etc/hysteria
# Generate a Private Key
openssl ecparam -genkey -name prime256v1 -out /etc/hysteria/private.key
# Generate a Self-Signed Certificate
openssl req -new -x509 -days 36500 -key /etc/hysteria/private.key -out /etc/hysteria/cert.pem -subj "/CN=bing.com"
echo "完成创建目录和SSL证书.\n"

# 运行安装脚本
echo "运行安装脚本..."
# Download and run the install script
bash <(curl -Ls https://raw.githubusercontent.com/FranzKafkaYu/sing-box-yes/master/install.sh) install 1.9.0-rc.3
echo "完成安装脚本.\n"

# 创建/修改配置文件
echo "创建/修改配置文件..."
# Download and replace the config file
wget -O /usr/local/etc/sing-box/config.json https://github.com/bi4nbn/sing-box_auto/raw/main/server.json
echo "完成配置文件的创建/修改.\n"

# 重启sing-box
echo "重启sing-box..."
# Restart the service
sing-box restart
echo "完成重启sing-box.\n"

echo "所有任务都已完成！"