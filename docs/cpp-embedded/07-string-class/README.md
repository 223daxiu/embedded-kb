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

### 练习 1：统计单词数量

**要求**：

- 输入一个句子（用 `getline` 读取整行）
- 统计其中的单词数量（用空格分隔）
- 打印单词数和每个单词

??? note "参考答案"

    ```cpp title="exercise01.cpp"
    #include <iostream>
    #include <string>
    #include <sstream>
    #include <vector>

    int main()
    {
        std::string sentence;
        std::cout << "请输入一个句子: ";
        std::getline(std::cin, sentence);

        // 用 istringstream 拆分单词
        std::istringstream iss(sentence);
        std::vector<std::string> words;
        std::string word;
        while (iss >> word) {
            words.push_back(word);
        }

        std::cout << "单词数量: " << words.size() << std::endl;
        std::cout << "单词列表:" << std::endl;
        for (size_t i = 0; i < words.size(); i++) {
            std::cout << "  [" << i + 1 << "] " << words[i] << std::endl;
        }

        return 0;
    }
    ```

    **运行示例**：
    ```
    请输入一个句子: Hello World from C++
    单词数量: 4
    单词列表:
      [1] Hello
      [2] World
      [3] from
      [4] C++
    ```

### 练习 2：字符串反转

**要求**：

- 实现 `std::string reverse(const std::string &s)` 函数
- 不使用标准库的 `std::reverse`，手动实现
- 测试多个用例（空串、单字符、回文串、普通字符串）

??? note "参考答案"

    ```cpp title="exercise02.cpp"
    #include <iostream>
    #include <string>

    std::string reverse(const std::string &s) {
        std::string result;
        result.reserve(s.size());  // 预分配空间
        for (int i = s.size() - 1; i >= 0; i--) {
            result += s[i];
        }
        return result;
    }

    int main()
    {
        // 测试用例
        std::string tests[] = {"", "A", "hello", "abcba", "C++ is great"};

        for (const auto &t : tests) {
            std::string rev = reverse(t);
            std::cout << "\"" << t << "\" → \"" << rev << "\""
                      << (t == rev ? "  (回文✓)" : "") << std::endl;
        }

        return 0;
    }
    ```

    **预期输出**：
    ```
    "" → ""  (回文✓)
    "A" → "A"  (回文✓)
    "hello" → "olleh"
    "abcba" → "abcba"  (回文✓)
    "C++ is great" → "taerg si ++C"
    ```

---

> **下一课**：[IO 流与文件操作](../08-iostream/README.md)
