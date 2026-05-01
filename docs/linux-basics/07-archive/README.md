# 07 - 压缩与解压

## tar - 打包与解压

`tar` 是 Linux 最常用的打包工具。它本身只是"打包"（把多个文件合并成一个），通常配合压缩算法使用。

### 最常用的命令（背这三个就够了）

```bash
# 打包并压缩（创建 .tar.gz）
tar -czf archive.tar.gz mydir/

# 解压
tar -xzf archive.tar.gz

# 查看内容（不解压）
tar -tzf archive.tar.gz
```

### 参数解释

| 参数 | 含义 | 助记 |
|------|------|------|
| `-c` | 创建（Create） | **c**reate |
| `-x` | 解压（eXtract） | e**x**tract |
| `-t` | 查看（lisT） | lis**t** |
| `-z` | 用 gzip 压缩 | g**z**ip |
| `-j` | 用 bzip2 压缩 | b**j**ip2 |
| `-J` | 用 xz 压缩 | x**J** |
| `-f` | 指定文件名（必须放最后） | **f**ile |
| `-v` | 显示过程 | **v**erbose |
| `-C` | 指定解压目录 | **C**hange dir |

### 完整示例

```bash
# 打包压缩
tar -czf project.tar.gz project/           # gzip 压缩（最常用）
tar -cjf project.tar.bz2 project/          # bzip2 压缩（更小但更慢）
tar -cJf project.tar.xz project/           # xz 压缩（最小但最慢）

# 解压到指定目录
tar -xzf project.tar.gz -C /opt/

# 只解压某个文件
tar -xzf project.tar.gz project/main.c

# 追加文件到已有的 tar
tar -rf archive.tar newfile.txt
```

---

## gzip / gunzip - 压缩单个文件

```bash
gzip file.txt                    # 压缩（原文件被替换为 file.txt.gz）
gunzip file.txt.gz               # 解压
gzip -k file.txt                 # 压缩但保留原文件
gzip -d file.txt.gz              # 解压（等同于 gunzip）
```

---

## zip / unzip - 跨平台压缩

Windows 和 Linux 通用格式。

```bash
# 可能需要安装
sudo apt install zip unzip

# 压缩
zip -r project.zip project/      # 递归压缩目录
zip archive.zip file1.txt file2.txt  # 压缩多个文件

# 解压
unzip project.zip                # 解压到当前目录
unzip project.zip -d /opt/       # 解压到指定目录
unzip -l project.zip             # 查看内容（不解压）
```

---

## 各格式速查表

| 格式 | 压缩 | 解压 | 查看 |
|------|------|------|------|
| `.tar.gz` / `.tgz` | `tar -czf a.tar.gz dir/` | `tar -xzf a.tar.gz` | `tar -tzf a.tar.gz` |
| `.tar.bz2` | `tar -cjf a.tar.bz2 dir/` | `tar -xjf a.tar.bz2` | `tar -tjf a.tar.bz2` |
| `.tar.xz` | `tar -cJf a.tar.xz dir/` | `tar -xJf a.tar.xz` | `tar -tJf a.tar.xz` |
| `.gz` | `gzip file` | `gunzip file.gz` | `zcat file.gz` |
| `.zip` | `zip -r a.zip dir/` | `unzip a.zip` | `unzip -l a.zip` |
| `.7z` | `7z a a.7z dir/` | `7z x a.7z` | `7z l a.7z` |

!!! tip "万能解压"
    不管什么格式，`tar -xf` 通常能自动识别并解压：
    ```bash
    tar -xf archive.tar.gz
    tar -xf archive.tar.bz2
    tar -xf archive.tar.xz
    ```

---

## 嵌入式常见场景

```bash
# 下载并解压交叉编译工具链
wget https://example.com/gcc-arm-10.tar.xz
tar -xJf gcc-arm-10.tar.xz -C /opt/

# 打包内核源码
tar -czf linux-5.10-custom.tar.gz linux-5.10/

# 备份开发板根文件系统
sudo tar -czf rootfs-backup.tar.gz -C /mnt/rootfs .
```

---

## 练习

!!! question "动手试试"
    1. 创建一个目录 `test/`，里面放几个文件
    2. 用 `tar -czf test.tar.gz test/` 打包压缩
    3. 删除 `test/` 目录
    4. 用 `tar -xzf test.tar.gz` 解压还原
    5. 用 `tar -tzf test.tar.gz` 查看包内容
