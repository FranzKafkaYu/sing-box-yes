#!/bin/bash

#####################################################
#This shell script is used for sing-box installation
#Usage：
#
#Author:FranzKafka
#Date:2022-09-15
#Version:0.0.1
#####################################################

#Some basic definitions
plain='\033[0m'
red='\033[0;31m'
blue='\033[1;34m'
pink='\033[1;35m'
green='\033[0;32m'
yellow='\033[0;33m'

#os
OS_RELEASE=''

#arch
OS_ARCH=''

#sing-box version
SING_BOX_VERSION=''

#script version
SING_BOX_YES_VERSION='0.0.1'

#package download path
DOWNLAOD_PATH='/usr/local/sing-box'

#scritp install path
SCRIPT_FILE_PATH='/usr/local/sbin/sing-box'

#config install path
CONFIG_FILE_PATH='/usr/local/etc/sing-box'

#binary install path
BINARY_FILE_PATH='/usr/local/bin/sing-box'

#service install path
SERVICE_FILE_PATH='/etc/systemd/system/sing-box.service'

#log file save path
DEFAULT_LOG_FILE_SAVE_PATH='/usr/local/sing-box/sing-box.log'

#sing-box status define
declare -r SING_BOX_STATUS_RUNNING=1
declare -r SING_BOX_STATUS_NOT_RUNNING=0
declare -r SING_BOX_STATUS_NOT_INSTALL=255

#log file size which will trigger log clear
#here we set it as 25M
declare -r DEFAULT_LOG_FILE_DELETE_TRIGGER=25

#utils
function LOGE() {
    echo -e "${red}[ERR] $* ${plain}"
}

function LOGI() {
    echo -e "${green}[INF] $* ${plain}"
}

function LOGD() {
    echo -e "${yellow}[DEG] $* ${plain}"
}

confirm() {
    if [[ $# > 1 ]]; then
        echo && read -p "$1 [默认$2]: " temp
        if [[ x"${temp}" == x"" ]]; then
            temp=$2
        fi
    else
        read -p "$1 [y/n]: " temp
    fi
    if [[ x"${temp}" == x"y" || x"${temp}" == x"Y" ]]; then
        return 0
    else
        return 1
    fi
}

#Root check
[[ $EUID -ne 0 ]] && LOGE "请使用root用户运行该脚本" && exit 1

#System check
os_check() {
    LOGI "检测当前系统中..."
    if [[ -f /etc/redhat-release ]]; then
        OS_RELEASE="centos"
    elif cat /etc/issue | grep -Eqi "debian"; then
        OS_RELEASE="debian"
    elif cat /etc/issue | grep -Eqi "ubuntu"; then
        OS_RELEASE="ubuntu"
    elif cat /etc/issue | grep -Eqi "centos|red hat|redhat"; then
        OS_RELEASE="centos"
    elif cat /proc/version | grep -Eqi "debian"; then
        OS_RELEASE="debian"
    elif cat /proc/version | grep -Eqi "ubuntu"; then
        OS_RELEASE="ubuntu"
    elif cat /proc/version | grep -Eqi "centos|red hat|redhat"; then
        OS_RELEASE="centos"
    else
        LOGE "系统检测错误,请联系脚本作者!" && exit 1
    fi
    LOGI "系统检测完毕,当前系统为:${OS_RELEASE}"
}

#arch check
arch_check() {
    LOGI "检测当前系统架构中..."
    OS_ARCH=$(arch)
    LOGI "当前系统架构为 ${OS_ARCH}"

    if [[ ${OS_ARCH} == "x86_64" || ${OS_ARCH} == "x64" || ${OS_ARCH} == "amd64" ]]; then
        OS_ARCH="amd64"
    elif [[ ${OS_ARCH} == "aarch64" || ${OS_ARCH} == "arm64" ]]; then
        OS_ARCH="arm64"
    else
        OS_ARCH="amd64"
        LOGE "检测系统架构失败，使用默认架构: ${OS_ARCH}"
    fi
    LOGI "系统架构检测完毕,当前系统架构为:${OS_ARCH}"
}

#sing-box status check,-1 means didn't install,0 means failed,1 means running
status_check() {
    if [[ ! -f "${SERVICE_FILE_PATH}" ]]; then
        return ${SING_BOX_STATUS_NOT_INSTALL}
    fi
    temp=$(systemctl status sing-box | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
    if [[ x"${temp}" == x"running" ]]; then
        return ${SING_BOX_STATUS_RUNNING}
    else
        return ${SING_BOX_STATUS_NOT_RUNNING}
    fi
}

#check config provided by sing-box core
config_check() {
    if [[ ! -f "${CONFIG_FILE_PATH}/config.json" ]]; then
        LOGE "${CONFIG_FILE_PATH}/config.json 不存在,配置检查失败"
        return
    else
        info=$(${BINARY_FILE_PATH} check -c ${CONFIG_FILE_PATH}/config.json)
        if [[ $? -ne 0 ]]; then
            LOGE "配置检查失败,请查看日志"
        else
            LOGI "恭喜:配置检查通过"
        fi
    fi
}

set_as_entrance() {
    if [[ ! -f "${SCRIPT_FILE_PATH}" ]]; then
        wget --no-check-certificate -O ${SCRIPT_FILE_PATH} https://raw.githubusercontent.com/FranzKafkaYu/sing-box-yes/main/install.sh
        chmod +x ${SCRIPT_FILE_PATH}
    fi
}

#show sing-box status
show_status() {
    status_check
    case $? in
    0)
        show_sing_box_version
        echo -e "[INF] sing-box状态: ${yellow}未运行${plain}"
        show_enable_status
        LOGI "配置文件路径:${CONFIG_FILE_PATH}/config.json"
        LOGI "可执行文件路径:${BINARY_FILE_PATH}"
        ;;
    1)
        show_sing_box_version
        echo -e "[INF] sing-box状态: ${green}已运行${plain}"
        show_enable_status
        show_running_status
        LOGI "配置文件路径:${CONFIG_FILE_PATH}/config.json"
        LOGI "可执行文件路径:${BINARY_FILE_PATH}"
        ;;
    255)
        echo -e "[INF] sing-box状态: ${red}未安装${plain}"
        ;;
    esac
}

#show sing-box running status
show_running_status() {
    status_check
    if [[ $? == ${SING_BOX_STATUS_RUNNING} ]]; then
        local pid=$(pidof sing-box)
        local runTime=$(systemctl status sing-box | grep Active | awk '{for (i=5;i<=NF;i++)printf("%s ", $i);print ""}')
        local memCheck=$(cat /proc/${pid}/status | grep -i vmrss | awk '{print $2,$3}')
        LOGI "#####################"
        LOGI "进程ID:${pid}"
        LOGI "运行时长：${runTime}"
        LOGI "内存占用:${memCheck}"
        LOGI "#####################"
    else
        LOGE "sing-box未运行"
    fi
}

#show sing-box version
show_sing_box_version() {
    LOGI "版本信息:$(${BINARY_FILE_PATH} version)"
}

#show sing-box enable status,enabled means sing-box can auto start when system boot on
show_enable_status() {
    local temp=$(systemctl is-enabled sing-box)
    if [[ x"${temp}" == x"enabled" ]]; then
        echo -e "[INF] sing-box是否开机自启: ${green}是${plain}"
    else
        echo -e "[INF] sing-box是否开机自启: ${red}否${plain}"
    fi
}

#installation path create & delete,1->create,0->delete
create_or_delete_path() {

    if [[ $# -ne 1 ]]; then
        LOGE "invalid input,should be one paremete,and can be 0 or 1"
        exit 1
    fi
    if [[ "$1" == "1" ]]; then
        LOGI "Will create ${DOWNLAOD_PATH} and ${CONFIG_FILE_PATH} for sing-box..."
        rm -rf ${DOWNLAOD_PATH} ${CONFIG_FILE_PATH}
        mkdir -p ${DOWNLAOD_PATH} ${CONFIG_FILE_PATH}
        if [[ $? -ne 0 ]]; then
            LOGE "create ${DOWNLAOD_PATH} and ${CONFIG_FILE_PATH} for sing-box failed"
            exit 1
        else
            LOGI "create ${DOWNLAOD_PATH} adn ${CONFIG_FILE_PATH} for sing-box success"
        fi
    elif [[ "$1" == "0" ]]; then
        LOGI "Will delete ${DOWNLAOD_PATH} and ${CONFIG_FILE_PATH}..."
        rm -rf ${DOWNLAOD_PATH} ${CONFIG_FILE_PATH}
        if [[ $? -ne 0 ]]; then
            LOGE "delete ${DOWNLAOD_PATH} and ${CONFIG_FILE_PATH} failed"
            exit 1
        else
            LOGI "delete ${DOWNLAOD_PATH} and ${CONFIG_FILE_PATH} success"
        fi
    fi

}

#install some common utils
install_base() {
    if [[ ${OS_RELEASE} == "ubuntu" || ${OS_RELEASE} == "debian" ]]; then
        apt install wget tar -y
    elif [[ ${OS_RELEASE} == "centos" ]]; then
        yum install wget tar -y
    fi
}

#download sing-box  binary
download_sing-box() {
    LOGD "开始下载sing-box..."
    os_check && arch_check && install_base
    if [[ $# -gt 1 ]]; then
        echo -e "${red}invalid input,plz check your input: $* ${plain}"
        exit 1
    elif [[ $# -eq 1 ]]; then
        SING_BOX_VERSION=$1
        local SING_BOX_VERSION_TEMP="v${SING_BOX_VERSION}"
    else
        local SING_BOX_VERSION_TEMP=$(curl -Ls "https://api.github.com/repos/SagerNet/sing-box/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
        SING_BOX_VERSION=${SING_BOX_VERSION_TEMP:1}
    fi
    LOGI "将选择使用版本:${SING_BOX_VERSION}"
    local DOWANLOAD_URL="https://github.com/SagerNet/sing-box/releases/download/${SING_BOX_VERSION_TEMP}/sing-box-${SING_BOX_VERSION}-linux-${OS_ARCH}.tar.gz"

    #here we need create directory for sing-box
    create_or_delete_path 1
    wget -N --no-check-certificate -O ${DOWNLAOD_PATH}/sing-box-${SING_BOX_VERSION}-linux-${OS_ARCH}.tar.gz ${DOWANLOAD_URL}

    if [[ $? -ne 0 ]]; then
        LOGE "Download sing-box failed,plz be sure that your network work properly and can access github"
        create_or_delete_path 0
        exit 1
    else
        LOGI "下载sing-box成功"
    fi
}

#dwonload office config examples
download_config() {
    LOGD "开始下载sing-box配置模板..."
    if [[ ! -f "${CONFIG_FILE_PATH}/config.json" ]]; then
        wget --no-check-certificate -O ${CONFIG_FILE_PATH}/config.json https://raw.githubusercontent.com/FranzKafkaYu/sing-box-yes/main/shadowsocks2022/server_config.json
        if [[ $? -ne 0 ]]; then
            LOGE "下载sing-box配置模板失败,请检查网络"
            exit 1
        else
            LOGI "下载sing-box配置模板成功"
        fi
    else
        LOGI "${CONFIG_FILE_PATH} 已存在,无需重复下载"
    fi
}

#install sing-box
install_sing-box() {
    set_as_entrance
    LOGD "开始安装sing-box..."
    if [[ $# -ne 0 ]]; then
        download_sing-box $1
    else
        download_sing-box
    fi
    download_config
    if [[ ! -f "${DOWNLAOD_PATH}/sing-box-${SING_BOX_VERSION}-linux-${OS_ARCH}.tar.gz" ]]; then
        clear_sing_box
        LOGE "could not find sing-box packages,plz check dowanload sing-box whether suceess"
        exit 1
    fi
    cd ${DOWNLAOD_PATH}
    #decompress sing-box packages
    tar -xvf sing-box-${SING_BOX_VERSION}-linux-${OS_ARCH}.tar.gz && cd sing-box-${SING_BOX_VERSION}-linux-${OS_ARCH}

    if [[ $? -ne 0 ]]; then
        clear_sing_box
        LOGE "解压sing-box安装包失败,脚本退出"
        exit 1
    else
        LOGI "解压sing-box安装包成功"
    fi

    #install sing-box
    install -m 755 sing-box ${BINARY_FILE_PATH}

    if [[ $? -ne 0 ]]; then
        LOGE "install sing-box failed,exit"
        exit 1
    else
        LOGI "install sing-box suceess"
    fi
    install_systemd_service && enable_sing-box && start_sing-box
    LOGI "安装sing-box成功,已启动成功"
}

#update sing-box
update_sing-box() {
    LOGD "开始更新sing-box..."
    if [[ ! -f "${SERVICE_FILE_PATH}" ]]; then
        LOGE "system did not install sing-box,please install it firstly"
        show_menu
    fi
    download_sing-box && install_sing-box
    if ! systemctl restart sing-box; then
        LOGE "update sing-box failed,please check logs"
        show_menu
    else
        LOGI "update sing-box success"
    fi
}

clear_sing_box() {
    LOGD "开始清除sing-box..."
    create_or_delete_path 0 && rm -rf ${SERVICE_FILE_PATH} && rm -rf ${BINARY_FILE_PATH} && rm -rf ${SCRIPT_FILE_PATH}
    LOGD "清除sing-box完毕"
}

#uninstall sing-box
uninstall_sing-box() {
    LOGD "开始卸载sing-box..."
    pidOfsing_box=$(pidof sing-box)
    if [ -n ${pidOfsing_box} ]; then
        stop_sing-box
    fi
    clear_sing_box

    if [ $? -ne 0 ]; then
        LOGE "卸载sing-box失败,请检查日志"
        exit 1
    else
        LOGI "卸载sing-box成功"
    fi
}

#install systemd service
install_systemd_service() {
    LOGD "开始安装sing-box systemd服务..."
    if [ -f "${SERVICE_FILE_PATH}" ]; then
        rm -rf ${SERVICE_FILE_PATH}
    fi
    #create service file
    touch ${SERVICE_FILE_PATH}
    if [ $? -ne 0 ]; then
        LOGE "create service file failed,exit"
        exit 1
    else
        LOGI "create service file success..."
    fi
    cat >${SERVICE_FILE_PATH} <<EOF
[Unit]
Description=sing-box Service
Documentation=https://sing-box.sagernet.org/
After=network.target nss-lookup.target
Wants=network.target
[Service]
Type=simple
ExecStart=${BINARY_FILE_PATH} run -c ${CONFIG_FILE_PATH}/config.json
Restart=on-failure
RestartSec=30s
RestartPreventExitStatus=23
LimitNPROC=10000
LimitNOFILE=1000000
[Install]
WantedBy=multi-user.target
EOF
    chmod 644 ${SERVICE_FILE_PATH}
    systemctl daemon-reload
    LOGD "安装sing-box systemd服务成功"
}

#start sing-box
start_sing-box() {
    if [ -f "${SERVICE_FILE_PATH}" ]; then
        systemctl start sing-box
        sleep 1s
        status_check
        if [ $? == ${SING_BOX_STATUS_NOT_RUNNING} ]; then
            LOGE "start sing-box service failed,exit"
            exit 1
        elif [ $? == ${SING_BOX_STATUS_RUNNING} ]; then
            LOGI "start sing-box service success"
        fi
    else
        LOGE "${SERVICE_FILE_PATH} does not exist,can not start service"
        exit 1
    fi
}

#restart sing-box
restart_sing-box() {
    if [ -f "${SERVICE_FILE_PATH}" ]; then
        systemctl restart sing-box
        sleep 1s
        status_check
        if [ $? == 0 ]; then
            LOGE "restart sing-box service failed,exit"
            exit 1
        elif [ $? == 1 ]; then
            LOGI "restart sing-box service success"
        fi
    else
        LOGE "${SERVICE_FILE_PATH} does not exist,can not restart service"
        exit 1
    fi
}

#stop sing-box
stop_sing-box() {
    LOGD "开始停止sing-box服务..."
    status_check
    if [ $? == ${SING_BOX_STATUS_NOT_INSTALL} ]; then
        LOGE "sing-box did not install,can not stop it"
        exit 1
    elif [ $? == ${SING_BOX_STATUS_NOT_RUNNING} ]; then
        LOGI "sing-box already stoped,no need to stop it again"
        exit 1
    elif [ $? == ${SING_BOX_STATUS_RUNNING} ]; then
        if ! systemctl stop sing-box; then
            LOGE "stop sing-box service failed,plz check logs"
            exit 1
        fi
    fi
    LOGD "停止sing-box服务成功"
}

#enable sing-box will set sing-box auto start on system boot
enable_sing-box() {
    systemctl enable sing-box
    if [[ $? == 0 ]]; then
        LOGI "设置sing-box开机自启成功"
    else
        LOGE "设置sing-box开机自启失败"
    fi
}

#disable sing-box
disable_sing-box() {
    systemctl disable sing-box
    if [[ $? == 0 ]]; then
        LOGI "取消sing-box开机自启成功"
    else
        LOGE "取消sing-box开机自启失败"
    fi
}

#show logs
show_log() {
    confirm "确认是否在配置中开启日志记录" "y"
    if [[ $? -ne 0 ]]; then
        LOGI "将从console中读取日志:"
        journalctl -u sing-box.service -e --no-pager -f
    else
        local tempLog=''
        read -p "将从日志文件中读取日志,请输入日志文件路径,直接回车将使用默认路径": tempLog
        if [[ -n ${tempLog} ]]; then
            LOGI "日志文件路径:${tempLog}"
            if [[ -f ${tempLog} ]]; then
                tail -f ${tempLog} -s 3
            else
                LOGE "${tempLog}不存在,请确认配置"
            fi
        else
            LOGI "日志文件路径:${DEFAULT_LOG_FILE_SAVE_PATH}"
            tail -f ${DEFAULT_LOG_FILE_SAVE_PATH} -s 3
        fi
    fi
}

#clear log,the paremter is log file path
clear_log() {
    local filePath=''
    if [[ $# -gt 0 ]]; then
        filePath=$1
    else
        read -p "请输入日志文件路径": filePath
        if [[ ! -n ${filePath} ]]; then
            LOGI "输入的日志文件路径无效,将使用默认的文件路径"
            filePath=${DEFAULT_LOG_FILE_SAVE_PATH}
        fi
    fi
    LOGI "日志路径为:${filePath}"
    if [[ ! -f ${filePath} ]]; then
        LOGE "清除sing-box 日志文件失败,${filePath}不存在,请确认"
        exit 1
    fi
    fileSize=$(ls -la ${filePath} --block-size=M | awk '{print $5}' | awk -F 'M' '{print$1}')
    if [[ ${fileSize} -gt ${DEFAULT_LOG_FILE_DELETE_TRIGGER} ]]; then
        rm $1 && systemctl restart sing-box
        if [[ $? -ne 0 ]]; then
            LOGE "清除sing-box 日志文件失败"
        else
            LOGI "清除sing-box 日志文件成功"
        fi
    else
        LOGI "当前日志大小为${fileSize}M,小于${DEFAULT_LOG_FILE_DELETE_TRIGGER}M,将不会清除"
    fi
}

#enable auto delete log，need file path as
enable_auto_clear_log() {
    LOGI "设置sing-box 定时清除日志..."
    local filePath=''
    if [[ $# -gt 0 ]]; then
        filePath=$1
    else
        filePath=${DEFAULT_LOG_FILE_SAVE_PATH}
    fi
    if [[ ! -f ${filePath} ]]; then
        LOGE "${filePath}不存在,设置sing-box 定时清除日志失败"
        exit 1
    fi
    crontab -l >/tmp/crontabTask.tmp
    echo "0 0 * * 6 sing-box clear ${filePath}" >>/tmp/crontabTask.tmp
    crontab /tmp/crontabTask.tmp
    rm /tmp/crontabTask.tmp
    LOGI "设置sing-box 定时清除日志成功"
}

#disable auto dlete log
disable_auto_clear_log() {
    crontab -l | grep -v "sing-box clear" | crontab -
    if [[ $? -ne 0 ]]; then
        LOGI "取消sing-box 定时清除日志失败"
    else
        LOGI "取消sing-box 定时清除日志成功"
    fi
}

#enable bbr
enable_bbr() {
    # temporary workaround for installing bbr
    bash <(curl -L -s https://raw.githubusercontent.com/teddysun/across/master/bbr.sh)
    echo ""
}

#show help
show_help() {
    echo "sing-box-v${SING_BOX_YES_VERSION} 管理脚本使用方法: "
    echo "------------------------------------------"
    echo "sing-box              - 显示快捷菜单 (功能更多)"
    echo "sing-box start        - 启动 sing-box服务"
    echo "sing-box stop         - 停止 sing-box服务"
    echo "sing-box restart      - 重启 sing-box服务"
    echo "sing-box status       - 查看 sing-box 状态"
    echo "sing-box enable       - 设置 sing-box 开机自启"
    echo "sing-box disable      - 取消 sing-box 开机自启"
    echo "sing-box log          - 查看 sing-box 日志"
    echo "sing-box clear        - 清除 sing-box 日志"
    echo "sing-box update       - 更新 sing-box 服务"
    echo "sing-box install      - 安装 sing-box 服务"
    echo "sing-box uninstall    - 卸载 sing-box 服务"
    echo "------------------------------------------"
}

#show menu
show_menu() {
    echo -e "
  ${green}sing-box-v${SING_BOX_YES_VERSION} 管理脚本${plain}
  ${green}0.${plain} 退出脚本
————————————————
  ${green}1.${plain} 安装 sing-box 服务
  ${green}2.${plain} 更新 sing-box 服务
  ${green}3.${plain} 卸载 sing-box 服务
  ${green}4.${plain} 启动 sing-box 服务
  ${green}5.${plain} 停止 sing-box 服务
  ${green}6.${plain} 重启 sing-box 服务
  ${green}7.${plain} 查看 sing-box 状态
  ${green}8.${plain} 查看 sing-box 日志
  ${green}9.${plain} 清除 sing-box 日志
  ${green}A.${plain} 检查 sing-box 配置
————————————————
  ${green}B.${plain} 设置 sing-box 开机自启
  ${green}C.${plain} 取消 sing-box 开机自启
  ${green}D.${plain} 设置 sing-box 定时清除日志&重启
  ${green}E.${plain} 取消 sing-box 定时清除日志&重启
————————————————
  ${green}F.${plain} 一键开启 bbr 
  ${green}G.${plain} 一键申请SSL证书
 "
    show_status
    echo && read -p "请输入选择[0-C]:" num

    case "${num}" in
    0)
        exit 0
        ;;
    1)
        install_sing-box && show_menu
        ;;
    2)
        update_sing-box && show_menu
        ;;
    3)
        uninstall_sing-box && show_menu
        ;;
    4)
        start_sing-box && show_menu
        ;;
    5)
        stop_sing-box && show_menu
        ;;
    6)
        restart_sing-box && show_menu
        ;;
    7)
        show_menu
        ;;
    8)
        show_log && show_menu
        ;;
    9)
        clear_log && show_menu
        ;;
    A)
        config_check && show_menu
        ;;
    B)
        enable_sing-box && show_menu
        ;;
    C)
        disable_sing-box && show_menu
        ;;
    D)
        enable_auto_clear_log
        ;;
    E)
        disable_auto_clear_log
        ;;

    F)
        enable_bbr && show_menu
        ;;
    *)
        LOGE "请输入正确的选项 [0-C]"
        ;;
    esac
}

start_to_run() {
    set_as_entrance
    clear
    show_menu
}

main() {
    if [[ $# > 0 ]]; then
        case $1 in
        "start")
            start_sing-box
            ;;
        "stop")
            stop_sing-box
            ;;
        "restart")
            restart_sing-box
            ;;
        "status")
            show_status
            ;;
        "enable")
            enable_sing-box
            ;;
        "disable")
            disable_sing-box
            ;;
        "log")
            show_log
            ;;
        "clear")
            clear_log
            ;;
        "update")
            update_sing-box
            ;;
        "install")
            if [[ $# == 2 ]]; then
                install_sing-box $2
            else
                install_sing-box
            fi
            ;;
        "uninstall")
            uninstall_sing-box
            ;;
        *) show_help ;;
        esac
    else
        start_to_run
    fi
}

main $*
