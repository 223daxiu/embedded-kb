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

### 练习 1：函数重载

**要求**：

- 写 3 个重载函数 `print`，分别处理 `int`、`double`、`std::string` 参数
- 每个版本打印类型名和值
- 再写一个接受两个 `int` 的 `print` 重载，验证参数个数不同也算重载

??? note "参考答案"

    ```cpp title="exercise01.cpp"
    #include <iostream>
    #include <string>

    void print(int val) {
        std::cout << "[int]    " << val << std::endl;
    }

    void print(double val) {
        std::cout << "[double] " << val << std::endl;
    }

    void print(const std::string &val) {
        std::cout << "[string] " << val << std::endl;
    }

    void print(int a, int b) {
        std::cout << "[int,int] " << a << ", " << b << std::endl;
    }

    int main()
    {
        print(42);
        print(3.14);
        print(std::string("Hello C++"));
        print(10, 20);

        return 0;
    }
    ```

    **预期输出**：
    ```
    [int]    42
    [double] 3.14
    [string] Hello C++
    [int,int] 10, 20
    ```

### 练习 2：constexpr 斛波那契

**要求**：

- 写一个 `constexpr` 函数 `fib(int n)` 计算第 n 个斛波那契数
- 用 `static_assert` 在编译期验证 `fib(10) == 55`
- 在 `main` 中打印前 15 个斛波那契数

??? note "参考答案"

    ```cpp title="exercise02.cpp"
    #include <iostream>

    constexpr int fib(int n) {
        if (n <= 0) return 0;
        if (n == 1) return 1;
        return fib(n - 1) + fib(n - 2);
    }

    // 编译期验证
    static_assert(fib(0) == 0,  "fib(0) 错误");
    static_assert(fib(1) == 1,  "fib(1) 错误");
    static_assert(fib(10) == 55, "fib(10) 错误");

    int main()
    {
        std::cout << "斛波那契数列（前15个）：" << std::endl;
        for (int i = 0; i < 15; i++) {
            std::cout << "fib(" << i << ") = " << fib(i) << std::endl;
        }

        // 编译期常量
        constexpr int f20 = fib(20);
        std::cout << "\nfib(20) = " << f20 << " (编译期计算)" << std::endl;

        return 0;
    }
    ```

    **预期输出**：
    ```
    斛波那契数列（前15个）：
    fib(0) = 0
    fib(1) = 1
    fib(2) = 1
    fib(3) = 2
    fib(4) = 3
    fib(5) = 5
    fib(6) = 8
    fib(7) = 13
    fib(8) = 21
    fib(9) = 34
    fib(10) = 55
    fib(11) = 89
    fib(12) = 144
    fib(13) = 233
    fib(14) = 377

    fib(20) = 6765 (编译期计算)
    ```

---

> **下一课**：[类与对象入门](../05-class-intro/README.md)
