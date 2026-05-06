# 第 26 课：现代 C++（17/20）

## C++17

### 结构化绑定

```cpp
std::map<std::string, int> scores = {{"张三", 85}};

for (const auto &[name, score] : scores) {
    std::cout << name << ": " << score << std::endl;
}

auto [x, y] = std::make_pair(3, 4);
```

### if/switch 初始化

```cpp
if (auto it = m.find("key"); it != m.end()) {
    std::cout << it->second << std::endl;
}
// it 的作用域仅在 if 块内
```

### std::optional

```cpp
#include <optional>

std::optional<int> find_value(const std::string &key) {
    if (key == "answer") return 42;
    return std::nullopt;
}

auto result = find_value("answer");
if (result.has_value()) {
    std::cout << result.value() << std::endl;
}
// 或者
std::cout << result.value_or(-1) << std::endl;
```

### std::variant

```cpp
#include <variant>

std::variant<int, double, std::string> v;
v = 42;
v = "hello";
v = 3.14;

// 访问
std::cout << std::get<double>(v) << std::endl;

// visitor 模式
std::visit([](auto &val) { std::cout << val << std::endl; }, v);
```

### std::string_view（零拷贝字符串视图）

```cpp
#include <string_view>

void process(std::string_view sv) {  // 不复制字符串
    std::cout << sv.substr(0, 5) << std::endl;
}

process("Hello, World!");         // const char* → 零拷贝
std::string s = "test";
process(s);                        // string → 零拷贝
```

### if constexpr（编译期 if）

```cpp
template <typename T>
auto process(T val) {
    if constexpr (std::is_integral_v<T>) {
        return val * 2;
    } else if constexpr (std::is_floating_point_v<T>) {
        return val + 0.5;
    } else {
        return val;
    }
}
```

---

## C++20

### Concepts（概念）

```cpp
#include <concepts>

template <std::integral T>
T gcd(T a, T b) {
    while (b) { T t = b; b = a % b; a = t; }
    return a;
}

// 自定义概念
template <typename T>
concept Printable = requires(T t) {
    { std::cout << t } -> std::same_as<std::ostream&>;
};

template <Printable T>
void print(const T &val) { std::cout << val << std::endl; }
```

### Ranges

```cpp
#include <ranges>

std::vector<int> v = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};

// 链式操作
auto result = v | std::views::filter([](int x) { return x % 2 == 0; })
                | std::views::transform([](int x) { return x * x; });

for (int x : result) std::cout << x << " ";  // 4 16 36 64 100
```

### 三路比较 <=>

```cpp
#include <compare>

struct Point {
    int x, y;
    auto operator<=>(const Point &) const = default;
};

Point a{1, 2}, b{1, 3};
std::cout << (a < b) << std::endl;   // 1
std::cout << (a == b) << std::endl;  // 0
```

---

## 练习题

### 练习 1

用 `std::optional` 实现安全的除法函数。

### 练习 2

用 `std::variant` + `std::visit` 实现一个简易的计算器表达式节点。

---

> **下一课**：[移动语义与完美转发](../27-move-semantics/README.md)
