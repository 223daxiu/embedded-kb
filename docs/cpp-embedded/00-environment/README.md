# 第 00 课：C++ 开发环境搭建

## 选哪个环境？

C++ 有很多开发环境，不同场景推荐不同方案：

| 方案 | 平台 | 适合场景 | 推荐指数 |
|------|------|---------|---------|
| **Visual Studio 2022** | Windows | 学习/工作/嵌入式上位机 | ⭐⭐⭐⭐⭐ |
| **VS Code + MinGW-w64** | Windows | 轻量、日常写代码 | ⭐⭐⭐⭐ |
| **CLion** | 全平台 | 专业开发（付费/学生免费） | ⭐⭐⭐⭐ |
| **Ubuntu + g++** | Linux | 服务器/嵌入式交叉编译 | ⭐⭐⭐ |

> **推荐**：Windows 上学 C++ 首选 **Visual Studio 2022 Community（免费）**，这也是国内大厂面试默认环境；日常写小程序用 **VS Code + MinGW-w64** 更轻便。

---

## 方案一：Visual Studio 2022（推荐）

### 安装

1. 下载 [Visual Studio 2022 Community](https://visualstudio.microsoft.com/zh-hans/vs/community/)（完全免费）
2. 安装时勾选工作负荷：**使用 C++ 的桌面开发**

    ![勾选工作负荷](https://learn.microsoft.com/zh-cn/cpp/build/media/vscpp-concierge-choose-workload.gif)

3. 点击安装，等待约 5-15 分钟（约 5GB）

### 第一个 C++ 程序

1. 打开 Visual Studio → **创建新项目**
2. 选择 **控制台应用**（C++）→ 下一步
3. 项目名随意，点击创建
4. 在 `main.cpp` 中输入：

```cpp
#include <iostream>

int main() {
    std::cout << "Hello, C++!" << std::endl;
    return 0;
}
```

5. 按 **Ctrl+F5** 运行（无调试运行，窗口不会自动关闭）

### 常用快捷键

| 快捷键 | 功能 |
|--------|------|
| `Ctrl+F5` | 运行（不调试） |
| `F5` | 调试运行 |
| `F9` | 打断点 |
| `F10` | 逐行执行 |
| `Ctrl+K Ctrl+C` | 注释选中行 |
| `Ctrl+Z` | 撤销 |
| `Ctrl+Shift+B` | 生成（编译） |

---

## 方案二：VS Code + MinGW-w64（轻量）

### 安装 MinGW-w64（g++ 编译器）

1. 下载 [WinLibs MinGW-w64](https://winlibs.com/)
   - 选最新版，UCRT runtime，POSIX threads，zip 包
2. 解压到 `C:\mingw64`（路径不要有中文/空格）
3. 添加到环境变量：
   - 右键**此电脑** → 属性 → 高级系统设置 → 环境变量
   - 在 `Path` 中添加 `C:\mingw64\bin`
4. 验证安装（PowerShell）：

```powershell
g++ --version
# 输出类似: g++.exe (MinGW-W64...) 14.2.0
```

### 安装 VS Code 扩展

在 VS Code 中安装以下扩展：

- **C/C++**（Microsoft，必装）
- **C/C++ Extension Pack**（包含 CMake 等）

### 编译运行方式

```powershell
# 单文件编译
g++ -std=c++17 -o hello hello.cpp
.\hello.exe

# 启用调试信息
g++ -std=c++17 -g -o hello hello.cpp
```

---

## 方案三：在线编译器（无需安装）

适合快速验证代码片段：

| 网站 | 特点 |
|------|------|
| [Compiler Explorer](https://godbolt.org/) | 查看汇编，支持所有编译器 |
| [Wandbox](https://wandbox.org/) | 支持 C++23，多编译器 |
| [Coliru](https://coliru.stacked-crooked.com/) | 简洁，g++ |

---

## 编译器版本说明

| 编译器 | 平台 | 说明 |
|--------|------|------|
| **MSVC** | Windows | Visual Studio 默认，兼容性最好 |
| **g++ (GCC)** | Linux/MinGW | 开源，嵌入式交叉编译必用 |
| **Clang** | 全平台 | 错误提示最友好，苹果默认 |

> 本课程所有代码均兼容 **C++17** 标准，编译时加 `-std=c++17`（g++/clang）或在 VS 项目属性中设置。

---

## VS 中设置 C++17

项目 → 属性 → C/C++ → 语言 → **C++ 语言标准** → `ISO C++17 标准(/std:c++17)`

---

## 验证：Hello C++17

```cpp title="hello.cpp"
#include <iostream>
#include <string_view>   // C++17

int main() {
    std::string_view msg = "Hello, C++17!";
    std::cout << msg << std::endl;

    // C++17 结构化绑定
    auto [a, b] = std::pair{42, 3.14};
    std::cout << a << " " << b << std::endl;

    return 0;
}
```

能编译运行就说明环境配置正确！

---

> **下一课**：[从 C 到 C++](../01-c-to-cpp/README.md)
