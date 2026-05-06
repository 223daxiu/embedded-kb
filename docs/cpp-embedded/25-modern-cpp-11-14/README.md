# 第 25 课：现代 C++（11/14）

## C++11 核心特性

### auto 与 decltype

```cpp
auto x = 42;               // int
auto v = std::vector<int>{1,2,3};  // std::vector<int>

decltype(x) y = 100;       // 和 x 同类型：int
decltype(auto) z = x;      // C++14
```

### 范围 for

```cpp
std::vector<int> v = {1, 2, 3, 4, 5};

for (int x : v) std::cout << x << " ";      // 值拷贝
for (int &x : v) x *= 2;                    // 引用修改
for (const auto &x : v) std::cout << x;     // const 引用（推荐）
```

### nullptr

```cpp
int *p = nullptr;   // 替代 NULL / 0
void f(int);
void f(int*);
f(nullptr);  // 调用 f(int*)，不会歧义
```

### 初始化列表

```cpp
std::vector<int> v = {1, 2, 3, 4, 5};
std::map<std::string, int> m = {{"a", 1}, {"b", 2}};

class Point {
public:
    Point(std::initializer_list<double> il) {
        auto it = il.begin();
        x = *it++;
        y = *it;
    }
private:
    double x, y;
};
```

### 移动语义

```cpp
std::string a = "hello";
std::string b = std::move(a);  // 移动而非拷贝
// a 现在是空的（已被"搬走"）
```

### constexpr

```cpp
constexpr int square(int x) { return x * x; }
constexpr int result = square(5);  // 编译期计算 = 25
static_assert(square(3) == 9);     // 编译期断言
```

### enum class（强类型枚举）

```cpp
enum class Color { Red, Green, Blue };
Color c = Color::Red;
// int n = c;  // ❌ 不能隐式转为 int
int n = static_cast<int>(c);  // 显式转换
```

### using 类型别名

```cpp
using IntVec = std::vector<int>;           // 替代 typedef
using Callback = std::function<void(int)>;

template <typename T>
using Vec = std::vector<T>;  // 模板别名（typedef 做不到）
```

---

## C++14 新特性

### 泛型 Lambda

```cpp
auto add = [](auto a, auto b) { return a + b; };
```

### 返回类型推导

```cpp
auto factorial(int n) -> int {  // C++11 尾置返回
    return n <= 1 ? 1 : n * factorial(n - 1);
}

auto factorial(int n) {  // C++14 自动推导
    if (n <= 1) return 1;
    return n * factorial(n - 1);
}
```

### make_unique

```cpp
auto p = std::make_unique<int>(42);  // C++14 终于有了！
```

### 二进制字面量与数字分隔符

```cpp
int mask = 0b1111'0000;     // 二进制
int million = 1'000'000;     // 数字分隔符
```

---

## 练习题

### 练习 1

用 C++11/14 特性重写一个之前用 C 风格写的程序。

### 练习 2

使用 `enum class` + `switch` 实现状态机。

---

> **下一课**：[现代 C++（17/20）](../26-modern-cpp-17-20/README.md)
