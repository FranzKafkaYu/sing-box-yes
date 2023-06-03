# sing-box-yes  
[CN](./README.md)| EN  
Install sing-box easily:100:  

sing-box is a universal proxy platform which supports many protocols.Currently it supports:  

`inbound`： 
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

`outbound`:  
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

For more details,please check here:point_right:[official site](https://sing-box.sagernet.org/)
# usage
```
bash <(curl -Ls https://raw.githubusercontent.com/FranzKafkaYu/sing-box-yes/master/install.sh)
```    
If you want install specific version,plz use coomand line as follows:
```
bash <(curl -Ls https://raw.githubusercontent.com/FranzKafkaYu/sing-box-yes/master/install.sh) install 1.0.3
```
# quick start
Just type `sing-box` to enter control menu,as follows showed here:
```
sing-box-v0.0.1 管理脚本
  0. Exit script
————————————————
   1. Install the sing-box service
   2. Update the sing-box service
   3. Uninstall Sing-BOX service
   4. Start the sing-box service
   5. Stop Sing-BOX service
   6. Restart the sing-box service
   7. View Sing-BOX status
   8. View Sing-BOX log
   9. Check the sing-box configuration
————————————————
   A. Set Sing-BOX boot self-starting
   B. Cancel Sing-BOX boot self-starting
————————————————————————
   C. Open BBR with one click
   D. Apply for SSL certificate with one click
 
[Inf] Version Information: Sing-Box 1.0.4.d2add33 (GO1.19.1, Linux/AMD64, CGO Disabled)
[Inf] Sing-BOX Status: Running
[INF] Sing-BOX Whether to turn on it self-started: Yes
[Inf] #########################
[INF] Process ID: 2615900
[INF] Running time: ThU 2022-09-15 16:29:14 cst; 1S AGO
[INF] Memory occupation: 11488 KB
[Inf] #########################
[Inf] Configuration file path: /usr/local/etc/ only-box/config.json
[INF] executable file path:/usr/local/bin/sing-box
```   
# examples  
- client_config.json will be used as client config,inbound:`tun`,outbound:`shadowsocks`  
- server_config.json will be used as server config,inbound:`shadowcoks`,outbound:`direct`  


