#!/bin/bash

# Linux系统更新与必备工具安装脚本
# 整合了系统更新和快捷方式创建功能
# 适用于Debian/Ubuntu和RHEL/CentOS/Fedora系列Linux发行版

# 脚本版本
VERSION="1.2.0"
SCRIPT_URL="https://raw.githubusercontent.com/yourusername/linux-update-script/main/linux_system_tool.sh"

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

print_blue() {
    echo -e "\e[34m$1\e[0m"
}

# 检查是否以root权限运行
if [ "$(id -u)" -ne 0 ]; then
    print_red "错误: 请以root权限运行此脚本"
    print_yellow "请尝试: sudo $0"
    exit 1
fi

# 获取当前脚本所在的绝对路径和脚本名称
SCRIPT_PATH="$(readlink -f "$0")"
SCRIPT_DIR="$(dirname "$SCRIPT_PATH")"
SCRIPT_NAME="$(basename "$SCRIPT_PATH")"

# 检查网络连接
check_network() {
    print_blue "正在检查网络连接..."
    if ping -c 1 google.com &> /dev/null || ping -c 1 baidu.com &> /dev/null; then
        print_green "网络连接正常"
        return 0
    else
        print_red "网络连接异常，请检查网络设置"
        return 1
    fi
}

# 检查脚本更新
check_update() {
    print_blue "正在检查脚本更新..."
    
    # 检查是否安装了curl或wget
    if command -v curl &> /dev/null; then
        DOWNLOAD_CMD="curl -s"
    elif command -v wget &> /dev/null; then
        DOWNLOAD_CMD="wget -qO-"
    else
        print_yellow "未安装curl或wget，无法检查更新"
        return 1
    fi
    
    # 获取远程脚本版本
    REMOTE_VERSION=$($DOWNLOAD_CMD "$SCRIPT_URL" | grep -m 1 "VERSION=" | cut -d'"' -f2)
    
    if [ -z "$REMOTE_VERSION" ]; then
        print_yellow "无法获取远程版本信息"
        return 1
    fi
    
    print_blue "当前版本: $VERSION"
    print_blue "最新版本: $REMOTE_VERSION"
    
    # 比较版本
    if [ "$VERSION" != "$REMOTE_VERSION" ]; then
        print_yellow "发现新版本！是否更新? (y/n)"
        read -r update_script
        
        if [ "$update_script" = "y" ] || [ "$update_script" = "Y" ]; then
            print_blue "正在更新脚本..."
            
            # 下载新版本脚本到临时文件
            TMP_FILE="/tmp/linux_system_tool.sh.new"
            $DOWNLOAD_CMD "$SCRIPT_URL" > "$TMP_FILE"
            
            # 检查下载是否成功
            if [ $? -eq 0 ] && [ -s "$TMP_FILE" ]; then
                # 备份当前脚本
                cp "$SCRIPT_PATH" "${SCRIPT_PATH}.bak"
                print_blue "已备份原脚本到 ${SCRIPT_PATH}.bak"
                
                # 替换当前脚本
                cat "$TMP_FILE" > "$SCRIPT_PATH"
                chmod +x "$SCRIPT_PATH"
                
                print_green "脚本已更新到最新版本！"
                print_yellow "请重新运行脚本以应用更新"
                
                # 清理临时文件
                rm -f "$TMP_FILE"
                
                exit 0
            else
                print_red "更新失败，请手动下载最新版本"
                rm -f "$TMP_FILE"
                return 1
            fi
        else
            print_blue "已取消更新"
        fi
    else
        print_green "当前已是最新版本"
    fi
    
    return 0
}

# 创建快捷方式函数
create_shortcut() {
    print_green "正在创建全局快捷方式 'liunx'..."
    
    # 创建软链接到/usr/local/bin目录
    ln -sf "$SCRIPT_PATH" /usr/local/bin/liunx
    
    # 检查是否创建成功
    if [ -L "/usr/local/bin/liunx" ]; then
        print_green "快捷方式创建成功！现在您可以在任何位置通过输入 'liunx' 来运行此脚本。"
    else
        print_red "快捷方式创建失败，请检查权限。"
        return 1
    fi
    
    return 0
}

# 安装Docker
install_docker() {
    print_blue "正在安装Docker..."
    
    # 检查Docker是否已安装
    if command -v docker &> /dev/null; then
        print_green "Docker已安装，版本: $(docker --version)"
        
        # 检查Docker服务状态
        if systemctl is-active --quiet docker; then
            print_green "Docker服务正在运行"
        else
            print_yellow "Docker服务未运行，正在启动..."
            systemctl start docker
            systemctl enable docker
        fi
        
        return 0
    fi
    
    # 根据不同的发行版安装Docker
    case $OS in
        debian|ubuntu|linuxmint)
            # 安装依赖
            apt update
            apt install -y apt-transport-https ca-certificates curl gnupg lsb-release
            
            # 添加Docker官方GPG密钥
            mkdir -p /etc/apt/keyrings
            curl -fsSL https://download.docker.com/linux/$OS/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
            
            # 设置Docker仓库
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$OS $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
            
            # 安装Docker
            apt update
            apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
            ;;
            
        centos|rhel|rocky|almalinux)
            if [ "$OS" = "fedora" ] || [ "$VERSION_ID" -ge 8 ]; then
                # 安装依赖
                dnf install -y dnf-plugins-core
                
                # 设置Docker仓库
                dnf config-manager --add-repo https://download.docker.com/linux/$OS/docker-ce.repo
                
                # 安装Docker
                dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
            else
                # 安装依赖
                yum install -y yum-utils
                
                # 设置Docker仓库
                yum-config-manager --add-repo https://download.docker.com/linux/$OS/docker-ce.repo
                
                # 安装Docker
                yum install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
            fi
            ;;
            
        fedora)
            # 安装依赖
            dnf install -y dnf-plugins-core
            
            # 设置Docker仓库
            dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
            
            # 安装Docker
            dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
            ;;
            
        *)
            print_red "不支持的Linux发行版: $OS"
            return 1
            ;;
    esac
    
    # 启动Docker服务
    systemctl start docker
    systemctl enable docker
    
    # 验证安装
    if command -v docker &> /dev/null; then
        print_green "Docker安装成功，版本: $(docker --version)"
        
        # 添加当前用户到docker组
        if [ -n "$SUDO_USER" ]; then
            usermod -aG docker $SUDO_USER
            print_green "已将用户 $SUDO_USER 添加到docker组，重新登录后生效"
        fi
        
        return 0
    else
        print_red "Docker安装失败"
        return 1
    fi
}

# 安装青龙面板依赖
install_qinglong_dependencies() {
    print_blue "正在安装青龙面板所需的依赖..."
    
    # 安装Docker（青龙面板需要Docker环境）
    install_docker
    
    # 安装Node.js和npm
    print_blue "正在安装Node.js和npm..."
    case $OS in
        debian|ubuntu|linuxmint)
            # 使用NodeSource安装最新的Node.js LTS版本
            curl -fsSL https://deb.nodesource.com/setup_16.x | bash -
            apt install -y nodejs
            ;;
            
        centos|rhel|rocky|almalinux|fedora)
            if [ "$OS" = "fedora" ] || [ "$VERSION_ID" -ge 8 ]; then
                # 使用NodeSource安装最新的Node.js LTS版本
                curl -fsSL https://rpm.nodesource.com/setup_16.x | bash -
                dnf install -y nodejs
            else
                # 使用NodeSource安装最新的Node.js LTS版本
                curl -fsSL https://rpm.nodesource.com/setup_16.x | bash -
                yum install -y nodejs
            fi
            ;;
            
        *)
            print_red "不支持的Linux发行版: $OS"
            return 1
            ;;
    esac
    
    # 验证Node.js和npm安装
    if command -v node &> /dev/null && command -v npm &> /dev/null; then
        print_green "Node.js安装成功，版本: $(node -v)"
        print_green "npm安装成功，版本: $(npm -v)"
    else
        print_red "Node.js或npm安装失败"
        return 1
    fi
    
    # 安装Python3和pip3
    print_blue "正在安装Python3和pip3..."
    case $OS in
        debian|ubuntu|linuxmint)
            apt install -y python3 python3-pip python3-venv
            ;;
            
        centos|rhel|rocky|almalinux|fedora)
            if [ "$OS" = "fedora" ] || [ "$VERSION_ID" -ge 8 ]; then
                dnf install -y python3 python3-pip python3-devel
            else
                yum install -y python3 python3-pip python3-devel
            fi
            ;;
            
        *)
            print_red "不支持的Linux发行版: $OS"
            return 1
            ;;
    esac
    
    # 验证Python3和pip3安装
    if command -v python3 &> /dev/null && command -v pip3 &> /dev/null; then
        print_green "Python3安装成功，版本: $(python3 --version)"
        print_green "pip3安装成功，版本: $(pip3 --version)"
    else
        print_red "Python3或pip3安装失败"
        return 1
    fi
    
    # 安装Python常用模块
    print_blue "正在安装Python常用模块..."
    pip3 install --upgrade pip
    pip3 install requests aiohttp telethon python-telegram-bot cryptography pillow qrcode prettytable PyExecJS
    
    # 安装npm全局包
    print_blue "正在安装npm全局包..."
    npm install -g pm2 pnpm typescript ts-node
    
    # 安装其他依赖
    print_blue "正在安装其他依赖..."
    case $OS in
        debian|ubuntu|linuxmint)
            apt install -y jq git curl wget cron
            ;;
            
        centos|rhel|rocky|almalinux|fedora)
            if [ "$OS" = "fedora" ] || [ "$VERSION_ID" -ge 8 ]; then
                dnf install -y jq git curl wget cronie
            else
                yum install -y jq git curl wget cronie
            fi
            ;;
            
        *)
            print_red "不支持的Linux发行版: $OS"
            return 1
            ;;
    esac
    
    print_green "青龙面板所需的依赖安装完成！"
    
    # 提供青龙面板安装命令
    print_yellow "您可以使用以下命令安装青龙面板："
    print_yellow "docker run -dit \\"
    print_yellow "  -v /opt/ql:/ql/data \\"
    print_yellow "  -p 5700:5700 \\"
    print_yellow "  --name qinglong \\"
    print_yellow "  --hostname qinglong \\"
    print_yellow "  --restart unless-stopped \\"
    print_yellow "  whyour/qinglong:latest"
    
    return 0
}

# 系统更新函数
update_system() {
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
    
    # 定义常用工具包 - 扩展了更多日常使用的基本命令
    COMMON_TOOLS="vim nano curl wget git htop tmux screen zip unzip net-tools dnsutils iputils-ping traceroute nmap tcpdump netcat telnet lsof rsync tree jq sysstat iotop iftop nload htop atop glances ncdu fzf bat fd-find ripgrep mtr socat iproute2 procps psmisc sudo"
    DEBIAN_TOOLS="$COMMON_TOOLS apt-transport-https ca-certificates gnupg-agent software-properties-common python3-pip openssh-server openssh-client fail2ban ufw"
    REDHAT_TOOLS="$COMMON_TOOLS epel-release yum-utils python3-pip openssh-server openssh-clients fail2ban firewalld"
    
    # 根据不同的发行版执行不同的更新命令
    case $OS in
        debian|ubuntu|linuxmint)
            print_green "正在更新APT软件包索引..."
            apt update -y
            
            print_green "正在升级系统软件包..."
            apt upgrade -y
            
            print_green "正在安装常用工具..."
            # 分批安装，避免因某个包不存在导致整个安装失败
            for tool in $DEBIAN_TOOLS; do
                apt install -y $tool || print_yellow "无法安装 $tool，跳过"
            done
            
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
                # 分批安装，避免因某个包不存在导致整个安装失败
                for tool in $REDHAT_TOOLS; do
                    dnf install -y $tool || print_yellow "无法安装 $tool，跳过"
                done
                
                print_green "正在清理不需要的软件包..."
                dnf autoremove -y
                dnf clean all
            else
                print_green "正在更新YUM软件包索引..."
                yum check-update || true
                
                print_green "正在升级系统软件包..."
                yum update -y
                
                print_green "正在安装常用工具..."
                # 分批安装，避免因某个包不存在导致整个安装失败
                for tool in $REDHAT_TOOLS; do
                    yum install -y $tool || print_yellow "无法安装 $tool，跳过"
                done
                
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
                apt install -y build-essential python3 python3-pip python3-venv nodejs npm gcc g++ make cmake autoconf automake pkg-config libtool
                ;;
                
            centos|rhel|fedora|rocky|almalinux)
                if [ "$OS" = "fedora" ] || [ "$VERSION_ID" -ge 8 ]; then
                    print_green "正在安装开发工具..."
                    dnf groupinstall -y "Development Tools"
                    dnf install -y python3 python3-pip python3-devel nodejs npm gcc gcc-c++ make cmake autoconf automake libtool pkgconfig
                else
                    print_green "正在安装开发工具..."
                    yum groupinstall -y "Development Tools"
                    yum install -y python3 python3-pip python3-devel nodejs npm gcc gcc-c++ make cmake autoconf automake libtool pkgconfig
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
    
    # 配置SSH服务
    print_green "是否配置SSH服务? (y/n)"
    read -r config_ssh
    
    if [ "$config_ssh" = "y" ] || [ "$config_ssh" = "Y" ]; then
        print_green "正在配置SSH服务..."
        
        # 确保SSH服务已安装
        case $OS in
            debian|ubuntu|linuxmint)
                apt install -y openssh-server
                ;;
            centos|rhel|fedora|rocky|almalinux)
                if [ "$OS" = "fedora" ] || [ "$VERSION_ID" -ge 8 ]; then
                    dnf install -y openssh-server
                else
                    yum install -y openssh-server
                fi
                ;;
        esac
        
        # 备份SSH配置文件
        cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
        print_blue "已备份SSH配置到 /etc/ssh/sshd_config.bak"
        
        # 修改SSH配置
        print_green "是否禁用SSH密码登录，仅允许密钥登录? (y/n)"
        read -r disable_password
        
        if [ "$disable_password" = "y" ] || [ "$disable_password" = "Y" ]; then
            # 确保有密钥登录方式
            print_yellow "警告: 请确保您已经设置了SSH密钥，否则可能无法登录系统"
            print_yellow "是否继续? (y/n)"
            read -r confirm_disable
            
            if [ "$confirm_disable" = "y" ] || [ "$confirm_disable" = "Y" ]; then
                sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
                print_green "已禁用SSH密码登录"
            fi
        fi
        
        # 修改SSH端口
        print_green "是否修改SSH默认端口? (y/n)"
        read -r change_port
        
        if [ "$change_port" = "y" ] || [ "$change_port" = "Y" ]; then
            print_green "请输入新的SSH端口号 (1024-65535):"
            read -r new_port
            
            if [[ "$new_port" =~ ^[0-9]+$ ]] && [ "$new_port" -ge 1024 ] && [ "$new_port" -le 65535 ]; then
                sed -i "s/#Port 22/Port $new_port/" /etc/ssh/sshd_config
                print_green "SSH端口已修改为 $new_port"
                
                # 配置防火墙
                case $OS in
                    debian|ubuntu|linuxmint)
                        if command -v ufw &> /dev/null; then
                            ufw allow $new_port/tcp
                            print_green "已在UFW防火墙中开放端口 $new_port"
                        fi
                        ;;
                    centos|rhel|fedora|rocky|almalinux)
                        if command -v firewall-cmd &> /dev/null; then
                            firewall-cmd --permanent --add-port=$new_port/tcp
                            firewall-cmd --reload
                            print_green "已在firewalld防火墙中开放端口 $new_port"
                        fi
                        ;;
                esac
            else
                print_red "无效的端口号，保持默认设置"
            fi
        fi
        
        # 重启SSH服务
        print_green "正在重启SSH服务..."
        systemctl restart sshd
        print_green "SSH服务已重启"
    fi
    
    print_green "系统更新和必备工具安装完成!"
    print_green "请重启系统以应用所有更改: sudo reboot"
}

# 显示帮助信息
show_help() {
    echo "Linux系统更新与必备工具安装脚本 v$VERSION"
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  -h, --help       显示此帮助信息"
    echo "  -i, --install    仅创建快捷方式 'liunx'"
    echo "  -u, --update     仅执行系统更新"
    echo "  -c, --check      检查脚本更新"
    echo "  -v, --version    显示版本信息"
    echo "  -q, --qinglong   安装青龙面板所需的依赖"
    echo ""
    echo "如果不指定选项，脚本将显示交互式菜单。"
}

# 主菜单函数
show_menu() {
    clear
    echo "============================================"
    echo "    Linux系统更新与必备工具安装脚本 v$VERSION"
    echo "============================================"
    echo "1. 创建快捷方式 'liunx'"
    echo "2. 执行系统更新和工具安装"
    echo "3. 执行全部操作（创建快捷方式并更新系统）"
    echo "4. 检查脚本更新"
    echo "5. 安装青龙面板所需的依赖"
    echo "6. 退出"
    echo "============================================"
    echo -n "请输入选项 [1-6]: "
    read -r choice
    
    case $choice in
        1)
            create_shortcut
            ;;
        2)
            update_system
            ;;
        3)
            create_shortcut && update_system
            ;;
        4)
            check_network && check_update
            ;;
        5)
            # 检测Linux发行版类型
            if [ -f /etc/os-release ]; then
                . /etc/os-release
                OS=$ID
                VERSION=$VERSION_ID
            fi
            install_qinglong_dependencies
            ;;
        6)
            print_green "感谢使用，再见！"
            exit 0
            ;;
        *)
            print_red "无效选项，请重新选择"
            sleep 2
            show_menu
            ;;
    esac
}

# 根据命令行参数执行不同操作
if [ $# -gt 0 ]; then
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        -i|--install)
            create_shortcut
            exit $?
            ;;
        -u|--update)
            update_system
            exit $?
            ;;
        -c|--check)
            check_network && check_update
            exit $?
            ;;
        -v|--version)
            echo "Linux系统更新与必备工具安装脚本 v$VERSION"
            exit 0
            ;;
        -q|--qinglong)
            # 检测Linux发行版类型
            if [ -f /etc/os-release ]; then
                . /etc/os-release
                OS=$ID
                VERSION=$VERSION_ID
            fi
            install_qinglong_dependencies
            exit $?
            ;;
        *)
            print_red "未知选项: $1"
            show_help
            exit 1
            ;;
    esac
else
    # 如果没有命令行参数，显示交互式菜单
    show_menu
fi 
