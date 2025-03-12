#!/bin/bash

# 系统更新与必备工具安装脚本
# 适用于Debian/Ubuntu和RHEL/CentOS/Fedora系列Linux发行版

# 输出彩色文本的函数
print_green() {
    echo -e "\e[32m$1\e[0m"
}

print_yellow() {
    echo -e "\e[33m$1\e[0m"
}

print_red() {
    echo -e "\e[31m$1\e[0m"
}

# 检查是否以root权限运行
if [ "$(id -u)" -ne 0 ]; then
    print_red "错误: 请以root权限运行此脚本"
    print_yellow "请尝试: sudo $0"
    exit 1
fi

# 检测Linux发行版类型
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    VERSION=$VERSION_ID
    print_green "检测到操作系统: $NAME $VERSION"
else
    print_red "无法检测操作系统类型，退出脚本"
    exit 1
fi

# 定义常用工具包
COMMON_TOOLS="vim curl wget git htop tmux screen zip unzip net-tools"
DEBIAN_TOOLS="$COMMON_TOOLS apt-transport-https ca-certificates gnupg-agent software-properties-common"
REDHAT_TOOLS="$COMMON_TOOLS epel-release yum-utils"

# 根据不同的发行版执行不同的更新命令
case $OS in
    debian|ubuntu|linuxmint)
        print_green "正在更新APT软件包索引..."
        apt update -y
        
        print_green "正在升级系统软件包..."
        apt upgrade -y
        
        print_green "正在安装常用工具..."
        apt install -y $DEBIAN_TOOLS
        
        print_green "正在清理不需要的软件包..."
        apt autoremove -y
        apt clean
        ;;
        
    centos|rhel|fedora|rocky|almalinux)
        if [ "$OS" = "centos" ] || [ "$OS" = "rhel" ] || [ "$OS" = "rocky" ] || [ "$OS" = "almalinux" ]; then
            print_green "正在安装EPEL仓库..."
            if [ "$OS" = "centos" ] && [ "$VERSION_ID" -ge 8 ]; then
                dnf install -y epel-release
            elif [ "$OS" = "centos" ]; then
                yum install -y epel-release
            elif [ "$OS" = "rocky" ] || [ "$OS" = "almalinux" ]; then
                dnf install -y epel-release
            elif [ "$OS" = "rhel" ]; then
                if [ "$VERSION_ID" -ge 8 ]; then
                    dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
                else
                    yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
                fi
            fi
        fi
        
        if [ "$OS" = "fedora" ] || [ "$VERSION_ID" -ge 8 ]; then
            print_green "正在更新DNF软件包索引..."
            dnf check-update || true
            
            print_green "正在升级系统软件包..."
            dnf upgrade -y
            
            print_green "正在安装常用工具..."
            dnf install -y $REDHAT_TOOLS
            
            print_green "正在清理不需要的软件包..."
            dnf autoremove -y
            dnf clean all
        else
            print_green "正在更新YUM软件包索引..."
            yum check-update || true
            
            print_green "正在升级系统软件包..."
            yum update -y
            
            print_green "正在安装常用工具..."
            yum install -y $REDHAT_TOOLS
            
            print_green "正在清理不需要的软件包..."
            yum autoremove -y
            yum clean all
        fi
        ;;
        
    *)
        print_red "不支持的Linux发行版: $OS"
        exit 1
        ;;
esac

# 安装其他常用开发工具
print_green "是否安装其他开发工具? (y/n)"
read -r install_dev_tools

if [ "$install_dev_tools" = "y" ] || [ "$install_dev_tools" = "Y" ]; then
    case $OS in
        debian|ubuntu|linuxmint)
            print_green "正在安装开发工具..."
            apt install -y build-essential python3 python3-pip nodejs npm
            ;;
            
        centos|rhel|fedora|rocky|almalinux)
            if [ "$OS" = "fedora" ] || [ "$VERSION_ID" -ge 8 ]; then
                print_green "正在安装开发工具..."
                dnf groupinstall -y "Development Tools"
                dnf install -y python3 python3-pip nodejs
            else
                print_green "正在安装开发工具..."
                yum groupinstall -y "Development Tools"
                yum install -y python3 python3-pip nodejs
            fi
            ;;
    esac
fi

# 配置系统时区
print_green "是否配置系统时区为Asia/Shanghai? (y/n)"
read -r set_timezone

if [ "$set_timezone" = "y" ] || [ "$set_timezone" = "Y" ]; then
    print_green "正在设置系统时区..."
    timedatectl set-timezone Asia/Shanghai
    print_green "当前系统时区: $(timedatectl | grep "Time zone")"
fi

# 配置系统语言环境
print_green "是否配置系统语言环境为en_US.UTF-8? (y/n)"
read -r set_locale

if [ "$set_locale" = "y" ] || [ "$set_locale" = "Y" ]; then
    print_green "正在设置系统语言环境..."
    case $OS in
        debian|ubuntu|linuxmint)
            apt install -y locales
            locale-gen en_US.UTF-8
            update-locale LANG=en_US.UTF-8
            ;;
            
        centos|rhel|fedora|rocky|almalinux)
            if [ "$OS" = "fedora" ] || [ "$VERSION_ID" -ge 8 ]; then
                dnf install -y glibc-langpack-en
            else
                yum install -y glibc-langpack-en
            fi
            localectl set-locale LANG=en_US.UTF-8
            ;;
    esac
    print_green "系统语言环境已设置为en_US.UTF-8"
fi

print_green "系统更新和必备工具安装完成!"
print_green "请重启系统以应用所有更改: sudo reboot" 
