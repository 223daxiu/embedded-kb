# 第 04 课：函数增强

## 默认参数

```cpp
void greet(const std::string &name, const std::string &greeting = "你好")
{
    std::cout << greeting << ", " << name << "!" << std::endl;
}

greet("张三");            // 你好, 张三!
greet("李四", "早上好");   // 早上好, 李四!
```

!!! warning "默认参数规则"
    默认参数必须**从右往左**连续设置：
    ```cpp
    void f(int a, int b = 10, int c = 20);  // ✅
    // void f(int a = 1, int b, int c = 20); // ❌
    ```

---

## 函数重载

同名函数，但**参数不同**（个数、类型、顺序）：

```cpp
int add(int a, int b) { return a + b; }
double add(double a, double b) { return a + b; }
std::string add(const std::string &a, const std::string &b) { return a + b; }

std::cout << add(1, 2) << std::endl;         // 3
std::cout << add(1.5, 2.5) << std::endl;     // 4.0
std::cout << add("Hello", " World") << std::endl;  // Hello World
```

!!! note "注意"
    - 返回值类型不同**不算**重载
    - 默认参数可能导致重载歧义

---

## 内联函数

建议编译器将函数体**展开**到调用处，减少函数调用开销：

```cpp
inline int square(int x) { return x * x; }

// 等价于宏 #define SQUARE(x) ((x)*(x))，但更安全
```

!!! tip "现代 C++"
    - 短小的函数定义在头文件中时，编译器通常会自动内联
    - `constexpr` 函数在编译期自动内联

---

## constexpr 函数

编译期计算的函数：

```cpp
constexpr int factorial(int n)
{
    return (n <= 1) ? 1 : n * factorial(n - 1);
}

constexpr int result = factorial(5);  // 编译期就算出 120
int arr[factorial(5)];  // 可以用作数组大小！
```

---

## 练习题

### 练习 1

写重载函数 `print`，分别处理 `int`、`double`、`std::string` 参数。

### 练习 2

写一个 `constexpr` 函数计算斐波那契数列。

---

> **下一课**：[类与对象入门](../05-class-intro/README.md)
