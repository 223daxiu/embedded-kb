# 08 - 软件包管理

## 包管理器对比

不同 Linux 发行版用不同的包管理器：

| 发行版 | 包管理器 | 包格式 |
|--------|---------|--------|
| Ubuntu / Debian / Raspberry Pi OS | `apt` | `.deb` |
| CentOS / RHEL / Fedora | `yum` 或 `dnf` | `.rpm` |
| Arch Linux | `pacman` | `.pkg.tar.zst` |
| Alpine（嵌入式常用） | `apk` | `.apk` |

!!! info "嵌入式开发最常见的是 Ubuntu/Debian 系和 Buildroot/Yocto 自定义系统"

---

## apt - Debian/Ubuntu 系

### 最常用命令

```bash
# 更新软件源列表（每次安装前先执行）
sudo apt update

# 升级所有已安装的包
sudo apt upgrade

# 安装软件
sudo apt install vim
sudo apt install gcc g++ make     # 一次安装多个
sudo apt install -y cmake         # -y 自动确认

# 卸载软件
sudo apt remove vim               # 卸载（保留配置）
sudo apt purge vim                # 彻底卸载（删除配置）
sudo apt autoremove               # 清理不需要的依赖

# 搜索软件
apt search opencv
apt list --installed              # 列出已安装的包
apt show vim                      # 查看包信息
```

### 嵌入式开发常装的包

```bash
# 基础开发工具
sudo apt install build-essential   # gcc, g++, make
sudo apt install cmake
sudo apt install git

# 交叉编译
sudo apt install gcc-arm-linux-gnueabihf
sudo apt install g++-arm-linux-gnueabihf

# 内核开发
sudo apt install linux-headers-$(uname -r)
sudo apt install device-tree-compiler  # 设备树编译器

# 调试工具
sudo apt install gdb gdb-multiarch
sudo apt install strace
sudo apt install minicom              # 串口终端

# 库开发
sudo apt install libgpiod-dev         # GPIO 库
sudo apt install libi2c-dev           # I2C 库
```

---

## yum / dnf - CentOS/RHEL 系

```bash
# yum（CentOS 7 及以下）
sudo yum update
sudo yum install gcc
sudo yum remove gcc
sudo yum search opencv

# dnf（CentOS 8+、Fedora）
sudo dnf update
sudo dnf install gcc
sudo dnf remove gcc
sudo dnf search opencv
```

---

## dpkg - 安装本地 .deb 包

```bash
# 安装
sudo dpkg -i package.deb

# 如果有依赖问题，用 apt 修复
sudo apt install -f

# 查看已安装的包
dpkg -l | grep vim

# 查看包安装了哪些文件
dpkg -L vim

# 查看某个文件属于哪个包
dpkg -S /usr/bin/vim
```

---

## 换源（使用国内镜像）

国内访问官方源很慢，建议换成国内镜像。

### Ubuntu 换源

```bash
# 备份原文件
sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak

# 编辑
sudo nano /etc/apt/sources.list
```

替换为（以阿里云为例，Ubuntu 22.04）：

```
deb http://mirrors.aliyun.com/ubuntu/ jammy main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ jammy-updates main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ jammy-security main restricted universe multiverse
```

```bash
# 更新缓存
sudo apt update
```

### Raspberry Pi OS 换源

```bash
# 编辑软件源
sudo nano /etc/apt/sources.list
# 将 http://raspbian.raspberrypi.org/raspbian/ 替换为
# http://mirrors.tuna.tsinghua.edu.cn/raspbian/raspbian/

sudo apt update
```

---

## 从源码编译安装

有时候软件源里没有你需要的软件或版本，需要自己编译：

```bash
# 典型的源码安装三步走
./configure                      # 检测系统环境，生成 Makefile
make                             # 编译
sudo make install                # 安装到系统

# 完整示例：编译安装 htop
wget https://github.com/htop-dev/htop/releases/download/3.3.0/htop-3.3.0.tar.xz
tar -xJf htop-3.3.0.tar.xz
cd htop-3.3.0
./configure
make
sudo make install
```

---

## 练习

!!! question "动手试试"
    1. 运行 `sudo apt update` 更新软件源
    2. 用 `apt search tree` 搜索 tree 包
    3. 用 `sudo apt install tree` 安装 tree
    4. 用 `dpkg -L tree` 查看 tree 安装了哪些文件
    5. 用 `tree --version` 确认安装成功
