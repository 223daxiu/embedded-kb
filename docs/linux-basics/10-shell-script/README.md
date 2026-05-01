# 10 - Shell 脚本入门

## 什么是 Shell 脚本

Shell 脚本就是把你平时在终端里手动输入的命令，写到一个文件里，让计算机**自动依次执行**。

---

## 第一个脚本

```bash
#!/bin/bash
# 文件名：hello.sh
# 这是注释

echo "Hello, World!"
echo "当前时间：$(date)"
echo "当前用户：$(whoami)"
echo "当前目录：$(pwd)"
```

```bash
# 创建并运行
nano hello.sh        # 写入上面的内容
chmod +x hello.sh    # 添加执行权限
./hello.sh           # 运行
```

!!! info "第一行 #!/bin/bash"
    这叫 **shebang**，告诉系统用哪个程序来执行这个脚本。
    - `#!/bin/bash` — 用 bash 执行
    - `#!/bin/sh` — 用 sh 执行（兼容性更好）
    - `#!/usr/bin/env python3` — 用 python3 执行

---

## 变量

```bash
#!/bin/bash

# 定义变量（等号两边不能有空格！）
name="Linux"
version=5.10
project_dir="/home/pi/project"

# 使用变量（加 $ 符号）
echo "系统：$name"
echo "内核版本：${version}"

# 命令执行结果赋值给变量
current_date=$(date +%Y-%m-%d)
ip_addr=$(hostname -I | awk '{print $1}')
echo "日期：$current_date"
echo "IP：$ip_addr"

# 只读变量
readonly PI=3.14159
# PI=3.14    # 这会报错

# 特殊变量
echo "脚本名称：$0"
echo "第一个参数：$1"
echo "第二个参数：$2"
echo "参数个数：$#"
echo "所有参数：$@"
echo "上一条命令的返回值：$?"
echo "当前进程 PID：$$"
```

---

## 条件判断

### if 语句

```bash
#!/bin/bash

# 基本 if
if [ -f "/dev/ttyUSB0" ]; then
    echo "USB 串口已连接"
else
    echo "USB 串口未找到"
fi

# if-elif-else
score=$1
if [ "$score" -ge 90 ]; then
    echo "优秀"
elif [ "$score" -ge 60 ]; then
    echo "及格"
else
    echo "不及格"
fi
```

### 常用判断条件

**文件判断：**

| 条件 | 含义 |
|------|------|
| `-f file` | 文件存在且是普通文件 |
| `-d dir` | 目录存在 |
| `-e path` | 路径存在（文件或目录） |
| `-r file` | 可读 |
| `-w file` | 可写 |
| `-x file` | 可执行 |
| `-s file` | 文件大小不为 0 |

**数字比较：**

| 条件 | 含义 |
|------|------|
| `-eq` | 等于 (equal) |
| `-ne` | 不等于 (not equal) |
| `-gt` | 大于 (greater than) |
| `-ge` | 大于等于 |
| `-lt` | 小于 (less than) |
| `-le` | 小于等于 |

**字符串比较：**

| 条件 | 含义 |
|------|------|
| `=` 或 `==` | 相等 |
| `!=` | 不等 |
| `-z str` | 字符串为空 |
| `-n str` | 字符串不为空 |

```bash
# 实用示例：检查编译工具
if command -v arm-linux-gnueabihf-gcc &>/dev/null; then
    echo "交叉编译器已安装"
else
    echo "请先安装交叉编译器"
    exit 1
fi
```

---

## 循环

### for 循环

```bash
#!/bin/bash

# 遍历列表
for fruit in apple banana orange; do
    echo "水果：$fruit"
done

# 遍历文件
for file in *.c; do
    echo "C 文件：$file"
    wc -l "$file"
done

# 数字范围
for i in {1..10}; do
    echo "第 $i 次"
done

# C 语言风格
for ((i=0; i<5; i++)); do
    echo "计数：$i"
done
```

### while 循环

```bash
#!/bin/bash

# 基本 while
count=0
while [ $count -lt 5 ]; do
    echo "count = $count"
    count=$((count + 1))
done

# 读取文件每一行
while IFS= read -r line; do
    echo "行内容：$line"
done < file.txt

# 无限循环（嵌入式常用：等待设备就绪）
while true; do
    if [ -e "/dev/ttyUSB0" ]; then
        echo "设备已连接！"
        break
    fi
    echo "等待设备..."
    sleep 1
done
```

---

## 函数

```bash
#!/bin/bash

# 定义函数
check_device() {
    local device=$1    # local 表示局部变量
    if [ -e "$device" ]; then
        echo "$device 存在"
        return 0
    else
        echo "$device 不存在"
        return 1
    fi
}

# 调用函数
check_device "/dev/ttyUSB0"
check_device "/dev/spidev0.0"

# 获取函数返回值
if check_device "/dev/i2c-1"; then
    echo "可以使用 I2C"
fi
```

---

## 实战脚本

### 1. 交叉编译脚本

```bash
#!/bin/bash
# build.sh - 交叉编译项目

CROSS_COMPILE=arm-linux-gnueabihf-
TARGET_IP="192.168.1.100"
TARGET_USER="pi"
TARGET_DIR="/home/pi/app"

# 编译
echo "=== 开始编译 ==="
${CROSS_COMPILE}gcc -o myapp main.c utils.c -I include/
if [ $? -ne 0 ]; then
    echo "编译失败！"
    exit 1
fi
echo "=== 编译成功 ==="

# 传输到开发板
echo "=== 传输到开发板 ==="
scp myapp ${TARGET_USER}@${TARGET_IP}:${TARGET_DIR}/
if [ $? -ne 0 ]; then
    echo "传输失败！"
    exit 1
fi
echo "=== 传输成功 ==="

# 在开发板上运行
echo "=== 远程运行 ==="
ssh ${TARGET_USER}@${TARGET_IP} "${TARGET_DIR}/myapp"
```

### 2. 系统信息收集脚本

```bash
#!/bin/bash
# sysinfo.sh - 收集嵌入式设备系统信息

echo "========== 系统信息 =========="
echo "主机名：$(hostname)"
echo "内核版本：$(uname -r)"
echo "系统架构：$(uname -m)"
echo ""

echo "========== CPU 信息 =========="
grep "model name" /proc/cpuinfo | head -1
echo "CPU 核心数：$(nproc)"
echo ""

echo "========== 内存信息 =========="
free -h | grep "Mem:"
echo ""

echo "========== 磁盘信息 =========="
df -h | grep -E "^/dev/"
echo ""

echo "========== 网络信息 =========="
ip -4 addr show | grep "inet " | awk '{print $NF, $2}'
echo ""

echo "========== 温度信息 =========="
if [ -f /sys/class/thermal/thermal_zone0/temp ]; then
    temp=$(cat /sys/class/thermal/thermal_zone0/temp)
    echo "CPU 温度：$((temp/1000))°C"
else
    echo "无法读取温度"
fi
```

### 3. 日志监控脚本

```bash
#!/bin/bash
# monitor.sh - 监控内核日志中的驱动信息

KEYWORD=${1:-"mydriver"}   # 默认搜索 mydriver
LOG_FILE="monitor_$(date +%Y%m%d_%H%M%S).log"

echo "监控关键词：$KEYWORD"
echo "日志保存到：$LOG_FILE"
echo "按 Ctrl+C 停止"
echo "---"

dmesg -w | grep --line-buffered "$KEYWORD" | tee -a "$LOG_FILE"
```

---

## 调试技巧

```bash
# 显示执行的每一条命令（调试用）
bash -x script.sh

# 在脚本中开启调试
set -x    # 开启
set +x    # 关闭

# 遇到错误立即退出（推荐在脚本开头加）
set -e

# 使用未定义变量时报错
set -u

# 推荐的脚本开头
#!/bin/bash
set -euo pipefail
```

---

## 练习

!!! question "动手试试"
    1. 写一个脚本打印 "Hello, 你的名字"（名字从命令行参数传入）
    2. 写一个脚本，检查 `/dev/ttyUSB0` 是否存在
    3. 写一个 for 循环，统计当前目录下每个 `.c` 文件的行数
    4. 写系统信息收集脚本 `sysinfo.sh`，在你的设备上运行
    5. 给脚本加上 `set -euo pipefail`，体验出错自动退出
