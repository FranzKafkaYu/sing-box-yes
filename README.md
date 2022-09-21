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
  9. 清除 sing-box 日志
  A. 检查 sing-box 配置
————————————————
  B. 设置 sing-box 开机自启
  C. 取消 sing-box 开机自启
  D. 设置 sing-box 定时清除日志&重启
  E. 取消 sing-box 定时清除日志&重启
————————————————
  F. 一键开启 bbr 
  G. 一键申请SSL证书
 
[INF] 版本信息:sing-box 1.0.4.d2add33 (go1.19.1, linux/amd64, CGO disabled) 
[INF] sing-box状态: 已运行
[INF] sing-box是否开机自启: 是
[INF] ##################### 
[INF] 进程ID:303895 
[INF] 运行时长：Sun 2022-09-18 14:52:42 CST; 1min 42s ago  
[INF] 内存占用:14336 kB 
[INF] ##################### 
[INF] 配置文件路径:/usr/local/etc/sing-box/config.json 
[INF] 可执行文件路径:/usr/local/bin/sing-box 

```   
# 配置样例    
- [shadowsocks2022](https://github.com/FranzKafkaYu/sing-box-yes/tree/main/shadowsocks2022)  
- [shadowsocks2022+shadowTLS](https://github.com/FranzKafkaYu/sing-box-yes/tree/main/shadowsocks2022_with_shadowTLS)  
- [trojan](https://github.com/FranzKafkaYu/sing-box-yes/tree/main/trojan)  
- [hysteria](https://github.com/FranzKafkaYu/sing-box-yes/tree/main/hysteria)   

使用时请自行按照模板修改服务端与客户端的配置.  

# 支持系统  
- Ubuntu  
- Centos  
- Debian  
- Rocky  
- Almalinux    

# 客户端  

目前sing-box仍在开发中，客户端支持尚未完善，大多数时候你都可以通过手动运行程序来进行使用。如果你需要一些客户端，可以尝试以下客户端  
- [V2rayN](https://github.com/2dust/v2rayN/releases/tag/5.36)  
- [SingBox](https://github.com/daodao97/SingBox)  

# 致谢  
[SagerNet/sing-box](https://github.com/SagerNet/sing-box)  

# star:star2:

[![Stargazers over time](https://starchart.cc/FranzKafkaYu/sing-box-yes.svg)](https://starchart.cc/FranzKafkaYu/sing-box-yes)




