# 第 01 课：从 C 到 C++

## C++ 是什么？

C++ 是 C 语言的超集，由 Bjarne Stroustrup 于 1979 年在贝尔实验室开始设计。它在 C 的基础上增加了：

- **面向对象编程**（类、继承、多态）
- **泛型编程**（模板）
- **标准库**（STL）
- **异常处理**
- **RAII 资源管理**

```mermaid
graph TB
    A[C 语言] --> B[C++98/03]
    B --> C[C++11 — 现代C++开始]
    C --> D[C++14]
    D --> E[C++17]
    E --> F[C++20]
    F --> G[C++23]
```

---

## C 和 C++ 的区别

| 特性 | C | C++ |
|------|---|-----|
| 编程范式 | 过程式 | 过程式 + 面向对象 + 泛型 |
| 文件扩展名 | `.c` | `.cpp` / `.cc` / `.cxx` |
| 编译器 | `gcc` | `g++` |
| 输入输出 | `printf/scanf` | `cout/cin`（也支持 printf） |
| 内存管理 | `malloc/free` | `new/delete`（也支持 malloc） |
| 字符串 | `char[]` | `std::string` |
| 布尔类型 | `_Bool`（C99） | `bool`（内建） |

---

## 第一个 C++ 程序

```cpp title="hello.cpp"
#include <iostream>  // C++ 头文件不带 .h

int main()
{
    std::cout << "Hello, C++!" << std::endl;
    return 0;
}
```

```bash
# 编译运行
g++ hello.cpp -o hello -std=c++17
./hello
```

---

## C++ 的新特性速览

### bool 类型

```cpp
bool is_ready = true;
bool is_empty = false;
std::cout << std::boolalpha << is_ready << std::endl;  // true
```

### auto 自动类型推导

```cpp
auto x = 42;        // int
auto pi = 3.14;     // double
auto name = "C++";  // const char*
auto s = std::string("hello");  // std::string
```

### nullptr（替代 NULL）

```cpp
int *p = nullptr;  // C++11 推荐用 nullptr
if (p == nullptr) {
    std::cout << "空指针" << std::endl;
}
```

### 初始化方式

```cpp
int a = 10;       // C 风格
int b(20);        // 构造式
int c{30};        // 列表初始化（C++11，推荐）
int d = {40};     // 也可以

// {} 可以防止窄化转换
// int x{3.14};   // 编译错误！
int x = 3.14;     // 只是警告，值为 3
```

---

## 编译选项

```bash
# 常用编译选项
g++ -std=c++17 -Wall -Wextra -g main.cpp -o app

# -std=c++17  指定 C++ 标准
# -Wall       开启常见警告
# -Wextra     开启更多警告
# -g          生成调试信息
# -O2         开启优化
```

---

## 练习题

### 练习 1

编写一个 C++ 程序，使用 `cout` 输出你的名字和年龄。

### 练习 2

用 `auto` 声明 5 种不同类型的变量并打印。

---

> **下一课**：[命名空间与输入输出](../02-namespace-io/README.md)
