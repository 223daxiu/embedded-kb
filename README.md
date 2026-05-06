# 📚 嵌入式开发知识库

基于 [MkDocs Material](https://squidfunk.github.io/mkdocs-material/) 构建的嵌入式开发知识库，涵盖 Linux 基础、Linux 驱动、MCU 裸机开发、C 语言进阶、C++ 嵌入式等内容。

## 在线访问

🌐 **GitHub Pages**：<https://223daxiu.github.io/embedded-kb/>

> 如果无法访问 GitHub Pages，请使用下方的本地预览方式。

---

## 本地使用

### 快速启动

**双击 `启动知识库.bat`** 即可自动打开浏览器预览，地址为 `http://127.0.0.1:8000/embedded-kb/`。

### 首次环境搭建（仅需一次）

如果虚拟环境 `.venv/` 不存在，需要先创建：

```bash
# 创建虚拟环境
python -m venv .venv

# 激活虚拟环境
# Windows:
.venv\Scripts\activate
# Linux/macOS:
source .venv/bin/activate

# 安装依赖（国内源）
pip install -r requirements.txt -i https://mirrors.aliyun.com/pypi/simple/
```

### 手动启动预览

```bash
.venv\Scripts\activate
mkdocs serve
```

浏览器打开 `http://127.0.0.1:8000/embedded-kb/`，编辑 `.md` 文件保存后页面自动刷新。

---

## 项目结构

```
embedded-kb/
├── docs/                    # 所有文档内容
│   ├── index.md             # 首页
│   ├── linux-basics/        # Linux 基础命令（10 课）
│   ├── linux-driver/        # Linux 驱动开发（9 课）
│   ├── mcu/                 # MCU 裸机开发（8 课）
│   ├── c-language/          # C 语言进阶（4 课）
│   └── cpp-embedded/        # C++ 嵌入式（2 课）
├── mkdocs.yml               # 站点配置（导航、主题、插件）
├── requirements.txt         # Python 依赖
├── .github/workflows/       # GitHub Actions 自动部署
├── 启动知识库.bat             # 一键本地预览
└── .gitignore
```

---

## 编辑内容

### 添加新课程

1. 在对应目录下创建文件夹和 `README.md`，例如：
   ```
   docs/linux-driver/02-platform-driver/README.md
   ```

2. 编写 Markdown 内容（支持的扩展语法见下方）。

3. 在 `mkdocs.yml` 的 `nav` 部分添加对应条目（如果是新课程）。

### 支持的 Markdown 扩展

```markdown
# 警告框
!!! note "标题"
    内容

!!! warning "注意"
    内容

!!! tip "提示"
    内容

# 可折叠块
??? note "点击展开"
    内容

# 代码块（带行号、高亮）
```c hl_lines="3 4" title="main.c"
int main(void) {
    // ...
}
```​

# Mermaid 流程图
```mermaid
graph LR
    A --> B --> C
```​

# 内容标签页
=== "C"
    ```c
    printf("hello");
    ```
=== "Python"
    ```python
    print("hello")
    ```
```

---

## 与 GitHub 同步

### 拉取最新内容（从远程 → 本地）

```bash
git pull
```

### 推送修改（从本地 → 远程）

```bash
# 查看修改了哪些文件
git status

# 添加所有修改
git add .

# 提交（写清楚改了什么）
git commit -m "更新: linux驱动第2课 平台驱动框架"

# 推送到 GitHub
git push
```

推送后 GitHub Actions 会自动重新部署 Pages，约 1-2 分钟后在线版本更新。

### 常用 Git 命令速查

| 命令 | 说明 |
|------|------|
| `git status` | 查看当前修改状态 |
| `git diff` | 查看具体修改内容 |
| `git add .` | 暂存所有修改 |
| `git add docs/xxx/` | 暂存指定目录 |
| `git commit -m "消息"` | 提交修改 |
| `git push` | 推送到远程 |
| `git pull` | 拉取远程更新 |
| `git log --oneline -10` | 查看最近 10 条提交记录 |

### Git 代理设置

如果 `git push/pull` 失败，可能需要配置代理：

```bash
# 设置代理（根据你的代理端口修改）
git config --global http.proxy http://127.0.0.1:7892
git config --global https.proxy http://127.0.0.1:7892

# 取消代理
git config --global --unset http.proxy
git config --global --unset https.proxy
```

---

## MkDocs 常用命令

| 命令 | 说明 |
|------|------|
| `mkdocs serve` | 启动本地预览服务器 |
| `mkdocs build` | 构建静态网站到 `site/` |
| `mkdocs gh-deploy --force` | 手动部署到 GitHub Pages |

---

## 内容进度

| 板块 | 状态 |
|------|------|
| Linux 基础命令（10 课） | ✅ 已完成 |
| Linux 驱动开发（9 课） | 🔨 第 1 课已完成，其余待写 |
| MCU 裸机开发（8 课） | 🔨 第 3 课已完成，其余待写 |
| C 语言进阶（4 课） | 📝 待写 |
| C++ 嵌入式（2 课） | 📝 待写 |
