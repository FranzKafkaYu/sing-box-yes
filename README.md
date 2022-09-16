# sing-box-yes
CN|[EN](./README_EN.md)  

方便快捷的安装、管理sing-box:100:  

sing-box是一个新的通用代理平台,对标*ray core与clash,且具有许多新的[特性](https://sing-box.sagernet.org/features/),目前支持以下协议:  

`入站`： 
- Shadowsocks(including shadowsocks2022)    
- Vmess  
- Trojan  
- Naive  
- Hysteria  
- ShadowTLS  
- Tun  
- Redirect  
- TProxy  
- Socks  
- HTTP  

`出站`:  
- Shadowsocks(including shadowsocks2022)    
- Vmess  
- Trojan 
- Wireguard  
- Hysteria  
- ShadowTLS  
- ShadowsocksR  
- VLESS  
- Tor  
- SSH
- DNS 

针对sing-box的更多内容,请点击这里:point_right:[official site](https://sing-box.sagernet.org/)
# 一键安装  
```
bash <(curl -Ls https://raw.githubusercontent.com/FranzKafkaYu/sing-box-yes/master/install.sh)
```    
执行后会自行显示管理菜单，通过菜单选项`1`将会自动安装最新release版本。与此同时，你也可以通过`sing-box install`来安装最新版本。  

如果你想安装某个特定版本,请使用以下命令,将`1.0.3`替换为特定版本号即可。  
```
bash <(curl -Ls https://raw.githubusercontent.com/FranzKafkaYu/sing-box-yes/master/install.sh) install 1.0.3
```
# 快捷方式
在服务器command line内输入sing-box回车即可进入管理菜单,当前菜单内容如下所示：  

```
sing-box-v0.0.1 管理脚本
  0. 退出脚本
————————————————
  1. 安装 sing-box 服务
  2. 更新 sing-box 服务
  3. 卸载 sing-box 服务
  4. 启动 sing-box 服务
  5. 停止 sing-box 服务
  6. 重启 sing-box 服务
  7. 查看 sing-box 状态
  8. 查看 sing-box 日志
  9. 检查 sing-box 配置
————————————————
  A. 设置 sing-box 开机自启
  B. 取消 sing-box 开机自启
————————————————
  C. 一键开启 bbr 
  D. 一键申请SSL证书
 
[INF] 版本信息:sing-box 1.0.4.d2add33 (go1.19.1, linux/amd64, CGO disabled) 
[INF] sing-box状态: 已运行
[INF] sing-box是否开机自启: 是
[INF] ##################### 
[INF] 进程ID:2615900 
[INF] 运行时长：Thu 2022-09-15 16:29:14 CST; 1s ago  
[INF] 内存占用:11488 kB 
[INF] ##################### 
[INF] 配置文件路径:/usr/local/etc/sing-box/config.json 
[INF] 可执行文件路径:/usr/local/bin/sing-box 
```   
# 配置样例    
- client_config.json可作为客户端配置,入站协议:`tun`,出站协议:`shadowsocks`  
- server_config.json可作为服务端配置,入站协议:`shadowcoks`,出站协议:`direct`  

服务端安装时，将会自动拉取sing-box官方自带的配置模板,你可以参考`server_config.json`的内容结合官方配置文档完成服务端配置  
客务端请自行下载对应的版本，进行客户端的配置  




