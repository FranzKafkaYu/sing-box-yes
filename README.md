# 修服务端一键安装脚本
```
curl -sS https://raw.githubusercontent.com/bi4nbn/sing-box_auto/main/singbox_server_install.sh | bash
```
# 15秒内自动生成以下两种协议的帐号,主打就是一个便捷

```
hysteria2://nt0538@你服务器ip:1538?sni=bing.com&alpn=h2&insecure=1#Hysteria2
```
```
vless://nt0538@你服务器ip:2538?encryption=none&flow=xtls-rprx-vision&security=reality&sni=www.tesla.com&fp=chrome&pbk=I8mdTZIKlw1eCiPei9KUqu4Kpxu1E6an3kXgQ8BSwEQ&sid=0538&type=tcp&headerType=none#Vless(tcp+reality)
```



# 客户端安装脚本
```
curl -O https://raw.githubusercontent.com/bi4nbn/sing-box_auto/main/singbox_cient_install.sh && chmod +x singbox_cient_install.sh && ./singbox_cient_install.sh
```