# Linux系统更新与必备工具安装脚本

这个脚本用于新装的Linux系统，可以自动更新软件包并安装日常必备的命令行工具。所有功能已整合到一个单一脚本中，使用更加方便。

## 功能特点

- 自动检测Linux发行版类型（支持Debian/Ubuntu和RHEL/CentOS/Fedora系列）
- 更新系统软件包
- 安装常用命令行工具
- 可选安装开发工具
- 可选配置系统时区和语言环境
- 创建全局快捷命令 `liunx`
- 交互式菜单界面
- 支持命令行参数
- 彩色输出，提高可读性
- **新增功能：在线检测和自动更新脚本**
- **新增功能：SSH服务配置**
- **新增功能：更全面的工具包安装**
- **新增功能：青龙面板依赖安装**

## 支持的Linux发行版

- Debian/Ubuntu/Linux Mint
- CentOS/RHEL/Fedora/Rocky Linux/AlmaLinux

## 安装的常用工具

### 基础工具
- vim/nano - 文本编辑器
- curl/wget - 网络下载工具
- git - 版本控制系统
- htop/top - 系统监控工具
- tmux/screen - 终端复用器
- zip/unzip - 压缩/解压缩工具
- net-tools - 网络工具集合

### 网络工具
- dnsutils - DNS查询工具
- iputils-ping - ping工具
- traceroute - 路由跟踪工具
- nmap - 网络扫描工具
- tcpdump - 网络数据包分析工具
- netcat - 网络工具
- telnet - 远程登录工具
- mtr - 网络诊断工具

### 系统工具
- lsof - 列出打开文件
- rsync - 文件同步工具
- tree - 目录树显示工具
- jq - JSON处理工具
- sysstat - 系统性能监控工具
- iotop - I/O监控工具
- iftop - 网络带宽监控
- nload - 网络流量监控
- atop/glances - 系统监控工具
- ncdu - 磁盘使用分析工具

### 文件搜索工具
- fzf - 模糊查找工具
- bat - 增强版cat
- fd-find - 替代find命令
- ripgrep - 替代grep命令

### 安全工具
- fail2ban - 防暴力破解工具
- ufw/firewalld - 防火墙

### 开发工具（可选）
- build-essential/Development Tools - 编译工具集
- python3 - Python解释器
- python3-pip - Python包管理器
- nodejs/npm - JavaScript运行环境和包管理器
- gcc/g++ - C/C++编译器
- make/cmake - 构建工具
- autoconf/automake - 自动配置工具
- pkg-config/libtool - 开发辅助工具

## 青龙面板依赖

脚本可以安装青龙面板所需的所有依赖，包括：

### Docker环境
- docker-ce - Docker引擎
- docker-ce-cli - Docker命令行工具
- containerd.io - 容器运行时
- docker-compose-plugin - Docker Compose插件

### Node.js环境
- nodejs - Node.js运行环境（v16.x LTS版本）
- npm - Node.js包管理器
- pm2 - Node.js进程管理工具
- pnpm - 快速的Node.js包管理器
- typescript - TypeScript编译器
- ts-node - 直接运行TypeScript代码的工具

### Python环境
- python3 - Python解释器
- python3-pip - Python包管理器
- python3-venv/python3-devel - Python虚拟环境/开发包
- 常用Python模块：
  - requests - HTTP请求库
  - aiohttp - 异步HTTP客户端/服务器
  - telethon - Telegram客户端
  - python-telegram-bot - Telegram Bot API
  - cryptography - 加密库
  - pillow - 图像处理库
  - qrcode - 二维码生成库
  - prettytable - 表格输出库
  - PyExecJS - 执行JavaScript代码的库

### 其他工具
- jq - JSON处理工具
- git - 版本控制系统
- curl/wget - 网络下载工具
- cron/cronie - 定时任务服务

## 使用方法

### 下载脚本

```bash
wget https://raw.githubusercontent.com/yourusername/linux-update-script/main/linux_system_tool.sh
# 或者
curl -O https://raw.githubusercontent.com/yourusername/linux-update-script/main/linux_system_tool.sh
```

### 添加执行权限

```bash
chmod +x linux_system_tool.sh
```

### 运行脚本

```bash
sudo ./linux_system_tool.sh
```

脚本将显示交互式菜单，您可以选择：
1. 仅创建快捷方式 'liunx'
2. 仅执行系统更新和工具安装
3. 执行全部操作（创建快捷方式并更新系统）
4. 检查脚本更新
5. 安装青龙面板所需的依赖
6. 退出

### 命令行参数

脚本也支持命令行参数：

```bash
# 显示帮助信息
sudo ./linux_system_tool.sh --help

# 仅创建快捷方式
sudo ./linux_system_tool.sh --install

# 仅执行系统更新
sudo ./linux_system_tool.sh --update

# 检查脚本更新
sudo ./linux_system_tool.sh --check

# 显示版本信息
sudo ./linux_system_tool.sh --version

# 安装青龙面板所需的依赖
sudo ./linux_system_tool.sh --qinglong
```

### 使用快捷方式

创建快捷方式后，您可以在任何位置通过输入 `liunx` 命令来运行此脚本：

```bash
liunx
```

## 在线更新功能

脚本现在支持自动检查和更新自身：

1. 通过菜单选项 "4. 检查脚本更新" 或命令行参数 `--check` 检查更新
2. 如果发现新版本，脚本会询问是否更新
3. 确认更新后，脚本会：
   - 下载最新版本
   - 备份当前版本
   - 替换为新版本
   - 保持执行权限

## SSH服务配置

脚本现在可以帮助您配置SSH服务：

1. 安装SSH服务器
2. 可选禁用密码登录，仅允许密钥登录
3. 可选修改SSH默认端口
4. 自动配置防火墙规则
5. 重启SSH服务以应用更改

## 青龙面板安装

安装完依赖后，脚本会提供安装青龙面板的Docker命令：

```bash
docker run -dit \
  -v /opt/ql:/ql/data \
  -p 5700:5700 \
  --name qinglong \
  --hostname qinglong \
  --restart unless-stopped \
  whyour/qinglong:latest
```

安装完成后，您可以通过浏览器访问 `http://服务器IP:5700` 来使用青龙面板。

## 在服务器上使用

1. 将脚本上传到服务器：

```bash
scp linux_system_tool.sh username@server_ip:/path/to/destination/
```

2. 连接到服务器并运行脚本：

```bash
ssh username@server_ip
cd /path/to/destination/
sudo ./linux_system_tool.sh
```

3. 选择选项3创建快捷方式并更新系统，或者根据需要选择其他选项

4. 安装完成后，可以随时通过 `liunx` 命令运行脚本

## 注意事项

- 脚本需要以root权限运行
- 在生产环境中使用前，请先在测试环境中验证
- 更新系统可能需要一些时间，请耐心等待
- 某些操作可能需要网络连接
- 如果禁用SSH密码登录，请确保已设置SSH密钥，否则可能无法登录系统
- 修改SSH端口后，请记住新端口号，否则可能无法连接到服务器
- 安装青龙面板需要Docker环境，确保您的系统支持Docker

## 许可证

MIT 
