# 第 16 课：模板进阶

## 模板特化

为特定类型提供专门实现：

```cpp
// 通用版本
template <typename T>
class Formatter {
public:
    static std::string format(const T &val) {
        return std::to_string(val);
    }
};

// 全特化：针对 std::string
template <>
class Formatter<std::string> {
public:
    static std::string format(const std::string &val) {
        return "\"" + val + "\"";
    }
};

// 全特化：针对 bool
template <>
class Formatter<bool> {
public:
    static std::string format(const bool &val) {
        return val ? "true" : "false";
    }
};
```

---

## 偏特化

```cpp
// 通用版本
template <typename T, typename U>
class Pair { /* ... */ };

// 偏特化：两个类型相同时
template <typename T>
class Pair<T, T> {
public:
    T first, second;
    T sum() { return first + second; }  // 只有类型相同才能相加
};

// 偏特化：第二个是指针时
template <typename T, typename U>
class Pair<T, U*> { /* 特殊处理指针 */ };
```

---

## 变参模板 (C++11)

```cpp
// 递归终止
void print() { std::cout << std::endl; }

// 变参模板
template <typename T, typename... Args>
void print(const T &first, const Args&... rest) {
    std::cout << first;
    if constexpr (sizeof...(rest) > 0) {
        std::cout << ", ";
    }
    print(rest...);
}

print(1, "hello", 3.14, true);  // 1, hello, 3.14, 1
```

### 折叠表达式 (C++17)

```cpp
template <typename... Args>
auto sum(Args... args) {
    return (args + ...);  // 右折叠
}

std::cout << sum(1, 2, 3, 4, 5) << std::endl;  // 15
```

---

## SFINAE

**Substitution Failure Is Not An Error** —— 替换失败不是错误：

```cpp
#include <type_traits>

// 只有整数类型才启用
template <typename T>
typename std::enable_if<std::is_integral<T>::value, T>::type
safe_divide(T a, T b) {
    if (b == 0) return 0;
    return a / b;
}

// C++20 更简洁：concepts
template <std::integral T>
T safe_divide(T a, T b) {
    if (b == 0) return 0;
    return a / b;
}
```

---

## 练习题

### 练习 1：模板特化

**要求**：

- 写函数模板 `to_string(T val)` 把任意类型转成字符串
- 对 `bool` 类型做全特化：返回 `"true"` 或 `"false"` 而不是 `"1"` / `"0"`
- 测试 `int`、`double`、`bool` 三种类型

??? note "参考答案"

    ```cpp title="exercise01.cpp"
    #include <iostream>
    #include <string>

    // 通用版本
    template <typename T>
    std::string my_to_string(T val) {
        return std::to_string(val);
    }

    // bool 特化
    template <>
    std::string my_to_string<bool>(bool val) {
        return val ? "true" : "false";
    }

    int main()
    {
        std::cout << "int:    " << my_to_string(42) << std::endl;
        std::cout << "double: " << my_to_string(3.14) << std::endl;
        std::cout << "bool:   " << my_to_string(true) << std::endl;
        std::cout << "bool:   " << my_to_string(false) << std::endl;

        return 0;
    }
    ```

    **预期输出**：
    ```
    int:    42
    double: 3.140000
    bool:   true
    bool:   false
    ```

### 练习 2：可变参数模板 print

**要求**：

- 用可变参数模板实现 `print(args...)`，打印任意个参数，空格分隔，末尾换行
- 测试 `print(1, 2.5, "hello", true)`

??? note "参考答案"

    ```cpp title="exercise02.cpp"
    #include <iostream>

    // 递归终止
    void print() {
        std::cout << std::endl;
    }

    // 递归展开
    template <typename T, typename... Args>
    void print(T first, Args... rest) {
        std::cout << first;
        if constexpr (sizeof...(rest) > 0) std::cout << " ";
        print(rest...);
    }

    int main()
    {
        print(1, 2.5, "hello", true);
        print("C++", 17, "is", "great");
        print(42);

        return 0;
    }
    ```

    **预期输出**：
    ```
    1 2.5 hello 1
    C++ 17 is great
    42
    ```

---

> **下一课**：[异常处理](../17-exception/README.md)
