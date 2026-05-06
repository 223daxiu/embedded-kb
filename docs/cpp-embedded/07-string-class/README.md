# 第 07 课：string 字符串类

## std::string 基础

```cpp
#include <string>

std::string s1 = "Hello";
std::string s2("World");
std::string s3{5, 'A'};     // "AAAAA"
std::string s4;              // 空串 ""

// 拼接
std::string greeting = s1 + ", " + s2 + "!";

// 比较（直接用 ==，不需要 strcmp）
if (s1 == "Hello") { /* ... */ }

// 长度
std::cout << s1.size() << std::endl;    // 5
std::cout << s1.length() << std::endl;  // 5（同 size）
std::cout << s1.empty() << std::endl;   // false
```

---

## 常用操作

```cpp
std::string s = "Hello, World!";

// 查找
size_t pos = s.find("World");    // 7
size_t nf = s.find("xyz");      // std::string::npos（未找到）

// 截取
std::string sub = s.substr(7, 5);  // "World"

// 替换
s.replace(7, 5, "C++");  // "Hello, C++!"

// 插入
s.insert(5, " Beautiful");  // "Hello Beautiful, C++!"

// 删除
s.erase(5, 10);  // 删除从位置5开始的10个字符

// 字符访问
char c = s[0];       // 'H'（不检查越界）
char c2 = s.at(0);   // 'H'（越界抛异常）

// 遍历
for (char ch : s) { std::cout << ch; }
for (auto &ch : s) { ch = toupper(ch); }  // 转大写
```

---

## string 与 C 字符串互转

```cpp
// string → const char*
std::string s = "hello";
const char *cs = s.c_str();

// const char* → string
const char *cs2 = "world";
std::string s2 = cs2;  // 自动转换

// string → int/double
int n = std::stoi("42");
double d = std::stod("3.14");

// int/double → string
std::string ns = std::to_string(42);
std::string ds = std::to_string(3.14);
```

---

## 练习题

### 练习 1

输入一个句子，统计单词数量。

### 练习 2

实现字符串反转函数 `std::string reverse(const std::string &s)`。

---

> **下一课**：[IO 流与文件操作](../08-iostream/README.md)
