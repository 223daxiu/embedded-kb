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

### 练习 1

为 `Formatter` 添加 `const char*` 的特化。

### 练习 2

用变参模板实现 `max_of(args...)` 函数，返回所有参数中的最大值。

---

> **下一课**：[异常处理](../17-exception/README.md)
