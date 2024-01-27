# 修改后的安装脚本
```
curl -o- https://raw.githubusercontent.com/bi4nbn/sing-box_auto/main/install.sh | bash
```
# 15秒内自动生成以下两种协议的帐号,主打就是一个便捷

```
hysteria2://nt0538@你服务器ip:1538?sni=bing.com&alpn=h2&insecure=1#Hysteria2
```
```
vless://nt0538@你服务器ip:2538?encryption=none&flow=xtls-rprx-vision&security=reality&sni=www.tesla.com&fp=chrome&pbk=I8mdTZIKlw1eCiPei9KUqu4Kpxu1E6an3kXgQ8BSwEQ&sid=0538&type=tcp&headerType=none#Vless(tcp+reality)
```


# sing-box-yes这是原作者的re
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
执行后会自行显示管理菜单，通过菜单选项`1`将会自动安装最新release版本。与此同时，你也可以通过`sing-box install`来安装最新版本    

如果你想安装某个特定版本(包括Pre-release),请使用以下命令,将`1.1-beta8`替换为特定版本号即可    
```
bash <(curl -Ls https://raw.githubusercontent.com/FranzKafkaYu/sing-box-yes/master/install.sh) install 1.1-beta8
```  
如果在安装后想更新到最新的release版本,且保留原有的配置文件,请使用如下命令或通过菜单选项`2`进行更新  
```
sing-box update 
```
如果在安装后想更新到某个特定版本(包括Pre-release),且保留原有的配置文件,请使用如下命令进行更新,将`1.1-beta8`替换为特定版本号即可
```
sing-box update 1.1-beta8
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
如果你厌倦了频繁输入数字,脚本也提供了一些快捷命令,具体如下：  
```
  sing-box              - 显示快捷菜单 (功能更多)  
  sing-box start        - 启动 sing-box服务  
  sing-box stop         - 停止 sing-box服务  
  sing-box restart      - 重启 sing-box服务  
  sing-box status       - 查看 sing-box 状态  
  sing-box enable       - 设置 sing-box 开机自启  
  sing-box disable      - 取消 sing-box 开机自启  
  sing-box log          - 查看 sing-box 日志  
  sing-box clear        - 清除 sing-box 日志  
  sing-box update       - 更新 sing-box 服务  
  sing-box install      - 安装 sing-box 服务  
  sing-box uninstall    - 卸载 sing-box 服务  
```

# 使用说明  
安装完sing-box后,你可能需要遵循以下几步方能正常使用：  

1)配置服务端：脚本默认路径为`/usr/local/etc/sing-box/config.json`,请使用`nano`或者`vim`进行编辑,具体的内容可以参考下方的配置样例部分,请依据个人实际情况进行填写  
2)配置检查：编辑保存好配置文件后，尽可能使用脚本提供的配置文件检查功能进行检查，该功能会对配置的格式进行检查确认，请确保检查通过  
3)重启sing-box：配置检查通过后，可以使用脚本中的重启功能重启`sing-box`，观察`sing-box`是否正常工作,请确保其正常工作  
4)下载客户端：请根据运行环境自行下载客户端，解压获得可执行文件  
5)下载geo数据：客户端运行需要`geoip.db`,`geosite.db`文件，请手动下载geo数据放入与`sing-box`执行文件同级目录下  
6)配置客户端：请将`client_config.json`放入与`sing-box`可执行文件同级目录下,对照配置模板并结合个人实际情况进行修改填写  
7)运行客户端：  
Windows下请以管理员打开命令行工具（推荐PowerShell），使用如下命令运行客户端：  
```
sing-box.exe run -c client_config.json  
```  
Linux下请以Root用户运行客户端:
```
sing-box run -c client_config.json
```  

# 配置样例    
- [shadowsocks2022](https://github.com/FranzKafkaYu/sing-box-yes/tree/main/shadowsocks2022)  
- [shadowsocks2022+shadowTLS](https://github.com/FranzKafkaYu/sing-box-yes/tree/main/shadowsocks2022_with_shadowTLS)  
- [trojan](https://github.com/FranzKafkaYu/sing-box-yes/tree/main/trojan)  
- [hysteria](https://github.com/FranzKafkaYu/sing-box-yes/tree/main/hysteria)   
- [vmess](https://github.com/FranzKafkaYu/sing-box-yes/tree/main/vmess)  

使用时请自行按照模板修改服务端与客户端的配置    

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




