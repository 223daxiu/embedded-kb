# 06 - 网络命令

## ip / ifconfig - 查看网络配置

```bash
# 现代方式（推荐）
ip addr                          # 查看所有网络接口和 IP
ip addr show eth0                # 查看指定接口
ip link                          # 查看接口状态（UP/DOWN）
ip route                         # 查看路由表

# 传统方式
ifconfig                         # 查看网络配置（可能需要安装 net-tools）
ifconfig eth0                    # 查看指定接口
```

### 手动配置 IP（嵌入式常用）

```bash
# 临时设置 IP（重启后失效）
sudo ip addr add 192.168.1.100/24 dev eth0
sudo ip link set eth0 up

# 设置默认网关
sudo ip route add default via 192.168.1.1

# 设置 DNS
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf
```

---

## ping - 测试网络连通性

```bash
ping 192.168.1.1                 # ping 网关
ping www.baidu.com               # ping 外网（测试 DNS 和网络）
ping -c 4 192.168.1.1            # 只 ping 4 次
ping -i 0.2 192.168.1.1          # 每 0.2 秒 ping 一次（快速检测）
```

### 嵌入式网络排查步骤

```bash
# 1. 先 ping 自己（回环测试）
ping 127.0.0.1

# 2. ping 网关（检查局域网连通性）
ping 192.168.1.1

# 3. ping 外网 IP（检查路由）
ping 8.8.8.8

# 4. ping 域名（检查 DNS）
ping www.baidu.com

# 如果第 2 步就失败 → 网线/WiFi 问题
# 如果第 3 步失败 → 网关/路由问题
# 如果第 4 步失败 → DNS 问题
```

---

## ssh - 远程登录

```bash
# 基本连接
ssh pi@192.168.1.100

# 指定端口
ssh -p 2222 pi@192.168.1.100

# 首次连接会询问是否信任，输入 yes
```

### 免密登录（SSH 密钥认证）

```bash
# 1. 在你的电脑上生成密钥对（一路回车）
ssh-keygen -t ed25519

# 2. 把公钥复制到目标设备
ssh-copy-id pi@192.168.1.100

# 3. 之后连接就不需要密码了
ssh pi@192.168.1.100
```

---

## scp - 远程复制文件

```bash
# 从本地复制到远程
scp mydriver.ko pi@192.168.1.100:/home/pi/
scp -r myproject/ pi@192.168.1.100:/home/pi/

# 从远程复制到本地
scp pi@192.168.1.100:/var/log/syslog ./
scp -r pi@192.168.1.100:/home/pi/project/ ./

# 指定端口
scp -P 2222 file.txt pi@192.168.1.100:/tmp/
```

### 嵌入式开发典型流程

```bash
# 在 PC 上交叉编译
arm-linux-gnueabihf-gcc -o myapp main.c

# 传到开发板
scp myapp pi@192.168.1.100:/home/pi/

# 登录开发板运行
ssh pi@192.168.1.100
./myapp
```

---

## curl / wget - 下载文件

```bash
# wget：下载文件（最简单）
wget https://example.com/file.tar.gz
wget -O output.tar.gz https://example.com/file.tar.gz  # 指定文件名

# curl：更灵活
curl -O https://example.com/file.tar.gz     # 下载文件
curl -o output.tar.gz https://example.com/file.tar.gz
curl https://api.example.com/data           # 访问 API
curl -I https://www.baidu.com               # 只看响应头
```

---

## netstat / ss - 查看网络连接

```bash
# 现代方式（推荐）
ss -tlnp                         # 查看所有监听的 TCP 端口
ss -ulnp                         # 查看所有监听的 UDP 端口

# 传统方式
netstat -tlnp                    # 需要安装 net-tools

# 常用组合
ss -tlnp | grep 8080             # 看 8080 端口被谁占用
```

| 选项 | 含义 |
|------|------|
| `-t` | TCP |
| `-u` | UDP |
| `-l` | 只显示监听状态 |
| `-n` | 显示端口号（不解析服务名）|
| `-p` | 显示进程信息 |

---

## 防火墙

```bash
# Ubuntu/Debian 用 ufw
sudo ufw status                  # 查看防火墙状态
sudo ufw allow 22                # 允许 SSH
sudo ufw allow 8080              # 允许 8080 端口
sudo ufw enable                  # 启用防火墙

# CentOS/RHEL 用 firewalld
sudo firewall-cmd --list-all
sudo firewall-cmd --add-port=8080/tcp --permanent
sudo firewall-cmd --reload
```

---

## 练习

!!! question "动手试试"
    1. 用 `ip addr` 查看你的 IP 地址
    2. 用 `ping -c 4 www.baidu.com` 测试网络
    3. 用 `ssh` 连接到你的开发板（如果有的话）
    4. 用 `scp` 传一个文件到开发板
    5. 用 `ss -tlnp` 看看你的系统上有哪些端口在监听
    6. 用 `curl -I www.baidu.com` 查看百度的响应头
