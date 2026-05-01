# 04 - 用户与权限管理

## Linux 权限模型

Linux 是多用户系统，每个文件都有三层权限控制：

```
-rwxr-xr-- 1 pi developers 4096 May 1 10:00 script.sh
 ^^^         ^  ^^^^^^^^^^^
 |||         |  |
 |||         |  └── 所有者:所属组
 |||         └── 硬链接数
 |||
 │├┤├┤├┤
 │ │ │ └── 其他用户 (Others): r-- (只读)
 │ │ └──── 所属组 (Group): r-x (读+执行)
 │ └────── 所有者 (Owner): rwx (读+写+执行)
 └──────── 文件类型: - (普通文件)
```

### 权限含义

| 权限 | 字母 | 数字 | 对文件 | 对目录 |
|------|------|------|--------|--------|
| 读 | `r` | 4 | 查看内容 | 列出目录内容 (`ls`) |
| 写 | `w` | 2 | 修改内容 | 创建/删除文件 |
| 执行 | `x` | 1 | 运行程序 | 进入目录 (`cd`) |

### 数字表示法

权限可以用三位数字表示（r=4, w=2, x=1 相加）：

| 数字 | 权限 | 含义 |
|------|------|------|
| `7` | rwx | 读+写+执行 |
| `6` | rw- | 读+写 |
| `5` | r-x | 读+执行 |
| `4` | r-- | 只读 |
| `0` | --- | 无权限 |

```bash
# 755 = rwxr-xr-x = 所有者全部权限，其他人只读+执行
# 644 = rw-r--r-- = 所有者读写，其他人只读
# 777 = rwxrwxrwx = 所有人全部权限（不安全！）
```

---

## chmod - 修改文件权限

```bash
# 数字方式（最常用）
chmod 755 script.sh              # 所有者可执行，其他人只读+执行
chmod 644 config.txt             # 所有者读写，其他人只读
chmod 600 secret.key             # 只有所有者能读写

# 字母方式
chmod +x script.sh               # 给所有人添加执行权限
chmod u+x script.sh              # 只给所有者添加执行权限
chmod g+w file.txt               # 给组添加写权限
chmod o-r file.txt               # 去掉其他人的读权限
chmod u=rwx,g=rx,o=r file.txt    # 精确设置

# 递归修改（整个目录）
chmod -R 755 myproject/
```

### 嵌入式常用权限场景

```bash
# 让脚本可执行
chmod +x startup.sh

# 设备节点权限（让普通用户也能访问串口）
sudo chmod 666 /dev/ttyUSB0

# 驱动模块文件
chmod 644 mydriver.ko
```

---

## chown - 修改文件所有者

```bash
# 改所有者
sudo chown root file.txt

# 改所有者和组
sudo chown pi:gpio /dev/gpiochip0

# 递归修改
sudo chown -R pi:pi /home/pi/project/
```

---

## sudo - 以管理员身份执行

```bash
# 用 sudo 执行单条命令
sudo apt update
sudo insmod mydriver.ko

# 切换到 root 用户（不推荐长期使用）
sudo su
# 或
sudo -i

# 用 root 身份编辑文件
sudo nano /etc/fstab
```

!!! warning "sudo 注意事项"
    - 不要习惯性地在每个命令前加 `sudo`
    - 只有真正需要管理员权限时才用
    - 编译代码 **不需要** sudo（`make` 不需要 sudo）
    - 安装驱动 **需要** sudo（`sudo insmod xxx.ko`）

---

## 用户管理

```bash
# 查看当前用户
whoami

# 查看用户信息
id                               # 当前用户的 UID、GID
id pi                            # 指定用户的信息

# 添加用户
sudo adduser newuser             # 交互式创建用户（推荐）
sudo useradd -m newuser          # 非交互式创建

# 修改密码
passwd                           # 修改自己的密码
sudo passwd newuser              # 修改其他用户的密码

# 删除用户
sudo deluser newuser             # 删除用户
sudo deluser --remove-home newuser  # 删除用户并删除家目录

# 将用户加入组（嵌入式常用：加入 dialout 组以访问串口）
sudo usermod -aG dialout pi
sudo usermod -aG gpio pi
# 修改后需要重新登录才生效
```

---

## 特殊权限

### setuid / setgid

```bash
# 查看 setuid 文件（如 sudo、passwd）
ls -l /usr/bin/sudo
# -rwsr-xr-x  ← 注意 s 表示 setuid

# setuid 让程序以文件所有者身份运行
# passwd 命令能修改 /etc/shadow 就是因为有 setuid
```

### sticky bit

```bash
# /tmp 目录有 sticky bit
ls -ld /tmp
# drwxrwxrwt  ← 注意最后的 t

# sticky bit 让目录中的文件只能被所有者删除
# 即使其他人有目录的写权限
```

---

## 练习

!!! question "动手试试"
    1. 创建一个脚本文件 `test.sh`，内容为 `echo "Hello"`
    2. 用 `ls -l` 查看它的权限
    3. 用 `chmod +x test.sh` 添加执行权限
    4. 用 `./test.sh` 运行脚本
    5. 用 `id` 查看你的用户和组信息
    6. 用 `sudo usermod -aG dialout $USER` 把自己加入 dialout 组（访问串口用）
