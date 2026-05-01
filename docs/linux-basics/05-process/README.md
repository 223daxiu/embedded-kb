# 05 - 进程管理

## 什么是进程

每个正在运行的程序都是一个**进程**。每个进程都有一个唯一的 **PID**（进程号）。

---

## ps - 查看进程

```bash
# 查看当前终端的进程
ps

# 查看所有进程（最常用）
ps aux
# a: 所有用户  u: 详细信息  x: 包括无终端的进程

# 查看进程树
ps auxf

# 搜索特定进程
ps aux | grep nginx
ps aux | grep python
```

### 理解 `ps aux` 输出

```
USER  PID %CPU %MEM   VSZ   RSS TTY STAT START TIME COMMAND
root    1  0.0  0.1 16940  4520 ?   Ss   May01 0:03 /sbin/init
pi    1234  2.5  1.0 23456 10240 pts/0 S+ 10:00 0:05 ./myapp
```

| 列 | 含义 |
|----|------|
| PID | 进程号（用于 kill） |
| %CPU | CPU 占用率 |
| %MEM | 内存占用率 |
| STAT | 状态：S=睡眠, R=运行, Z=僵尸, T=停止 |
| COMMAND | 启动命令 |

---

## top / htop - 实时监控

```bash
top                              # 实时进程监控（自带）
htop                             # 更好看的版本（需安装）
# sudo apt install htop
```

**top 常用操作：**

| 按键 | 作用 |
|------|------|
| `q` | 退出 |
| `P` | 按 CPU 排序 |
| `M` | 按内存排序 |
| `k` | 输入 PID 终止进程 |
| `1` | 显示每个 CPU 核心 |

---

## kill - 终止进程

```bash
# 正常终止（发送 SIGTERM，程序可以做清理）
kill PID
kill 1234

# 强制终止（发送 SIGKILL，立即杀死）
kill -9 PID
kill -9 1234

# 按进程名终止
killall nginx
killall -9 python3

# 用 pkill 模糊匹配
pkill -f "my_app"
```

### 常用信号

| 信号 | 数字 | 含义 |
|------|------|------|
| SIGTERM | 15 | 正常终止（默认） |
| SIGKILL | 9 | 强制终止（不可捕获） |
| SIGSTOP | 19 | 暂停进程 |
| SIGCONT | 18 | 继续运行 |
| SIGHUP | 1 | 重新加载配置 |

---

## 前台与后台任务

```bash
# 在后台运行（命令末尾加 &）
./long_task &

# Ctrl+Z 暂停当前任务
# 然后用 bg 让它在后台继续
bg

# 查看后台任务
jobs

# 将后台任务调回前台
fg
fg %1                            # 调回编号为 1 的任务

# nohup：关闭终端后继续运行
nohup ./myserver &
# 输出会写入 nohup.out
```

### 嵌入式场景

```bash
# 在开发板上后台运行你的程序
nohup ./sensor_app > /var/log/sensor.log 2>&1 &

# 查看是否在运行
ps aux | grep sensor_app

# 停止
pkill sensor_app
```

---

## systemctl - 服务管理

现代 Linux 用 `systemd` 管理系统服务。

```bash
# 查看服务状态
sudo systemctl status nginx
sudo systemctl status sshd

# 启动/停止/重启
sudo systemctl start nginx
sudo systemctl stop nginx
sudo systemctl restart nginx

# 开机自启
sudo systemctl enable nginx      # 设置开机自启
sudo systemctl disable nginx     # 取消开机自启

# 查看所有运行中的服务
systemctl list-units --type=service --state=running
```

### 创建自己的服务（嵌入式常用）

```bash
sudo nano /etc/systemd/system/myapp.service
```

```ini
[Unit]
Description=My Embedded Application
After=network.target

[Service]
Type=simple
ExecStart=/opt/myapp/bin/myapp
Restart=always
RestartSec=5
User=pi
WorkingDirectory=/opt/myapp

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl daemon-reload
sudo systemctl enable myapp
sudo systemctl start myapp
```

---

## free - 查看内存

```bash
free -h                          # 人类可读格式
```

```
              total   used   free  shared  buff/cache  available
Mem:          1.9Gi  512Mi  800Mi    28Mi       600Mi     1.3Gi
Swap:         100Mi    0B   100Mi
```

!!! info "嵌入式内存管理"
    嵌入式设备内存小，`free -h` 是检查内存是否够用的第一步。`available` 才是真正可用的内存（包括可释放的缓存）。

---

## df / du - 查看磁盘空间

```bash
# df：查看磁盘分区使用情况
df -h

# du：查看目录/文件占用大小
du -sh /home/pi                  # 查看某个目录总大小
du -sh *                         # 查看当前目录下每项大小
du -sh * | sort -rh | head -10   # 找出最大的 10 个文件/目录
```

---

## 练习

!!! question "动手试试"
    1. 用 `ps aux | grep bash` 查看你的 bash 进程
    2. 用 `top` 查看系统负载，按 `M` 按内存排序，按 `q` 退出
    3. 在后台运行 `sleep 60 &`，用 `jobs` 查看，用 `fg` 调回前台，按 `Ctrl+C` 终止
    4. 用 `free -h` 查看内存使用情况
    5. 用 `df -h` 查看磁盘使用情况
    6. 用 `du -sh /var/log` 查看日志目录大小
