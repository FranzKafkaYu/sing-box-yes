#!/bin/bash

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# 确认是root用户
if [ "$EUID" -ne 0 ]
  then echo -e "${RED}错误：需要root权限来执行.${NC}" ; exit
fi 

# 设置错误状态退出
set -e

# 创建所需目录并生成SSL证书
mkdir -p /etc/hysteria
echo -e "${GREEN}创建必需的目录并生成SSL证书...${NC}"
openssl ecparam -genkey -name prime256v1 -out /etc/hysteria/private.key
openssl req -new -x509 -days 36500 -key /etc/hysteria/private.key -out /etc/hysteria/cert.pem -subj "/CN=bing.com"
echo -e "${GREEN}完成创建目录和SSL证书.${NC}\n"

# 运行安装脚本
echo -e "${GREEN}运行安装脚本...${NC}"
bash <(curl -Ls https://raw.githubusercontent.com/FranzKafkaYu/sing-box-yes/master/install.sh) install 1.9.0-rc.3
echo -e "${GREEN}完成安装脚本.${NC}\n"

# 创建/修改配置文件
echo -e "${GREEN}创建/修改配置文件...${NC}"
wget -O /usr/local/etc/sing-box/config.json https://github.com/bi4nbn/sing-box_auto/raw/main/server.json
echo -e "${GREEN}完成配置文件的创建/修改.${NC}\n"

# 重启sing-box
echo -e "${GREEN}重启sing-box...${NC}"
sing-box restart
echo -e "${GREEN}完成重启sing-box.${NC}\n"

echo -e "${GREEN}所有任务都已完成！${NC}"