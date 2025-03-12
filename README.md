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

## 支持的Linux发行版

- Debian/Ubuntu/Linux Mint
- CentOS/RHEL/Fedora/Rocky Linux/AlmaLinux

## 安装的常用工具

- vim - 文本编辑器
- curl/wget - 网络下载工具
- git - 版本控制系统
- htop - 系统监控工具
- tmux/screen - 终端复用器
- zip/unzip - 压缩/解压缩工具
- net-tools - 网络工具集合
- 以及其他发行版特定的必要工具

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
4. 退出

### 命令行参数

脚本也支持命令行参数：

```bash
# 显示帮助信息
sudo ./linux_system_tool.sh --help

# 仅创建快捷方式
sudo ./linux_system_tool.sh --install

# 仅执行系统更新
sudo ./linux_system_tool.sh --update
```

### 使用快捷方式

创建快捷方式后，您可以在任何位置通过输入 `liunx` 命令来运行此脚本：

```bash
liunx
```

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

## 许可证

MIT 
