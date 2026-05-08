# 第 30 课：模板元编程

## type_traits 类型萃取

```cpp
#include <type_traits>

// 编译期类型判断
static_assert(std::is_integral_v<int>);          // true
static_assert(std::is_floating_point_v<double>);  // true
static_assert(std::is_pointer_v<int*>);           // true
static_assert(std::is_same_v<int, int32_t>);      // true

// 类型变换
using T1 = std::remove_const_t<const int>;         // int
using T2 = std::remove_reference_t<int&>;          // int
using T3 = std::add_pointer_t<int>;                // int*
using T4 = std::conditional_t<true, int, double>;  // int
```

---

## constexpr if（编译期分支）

```cpp
template <typename T>
std::string to_string(T value) {
    if constexpr (std::is_same_v<T, std::string>) {
        return value;
    } else if constexpr (std::is_arithmetic_v<T>) {
        return std::to_string(value);
    } else if constexpr (std::is_pointer_v<T>) {
        return value ? to_string(*value) : "null";
    }
}
```

---

## 编译期计算

### 编译期阶乘

```cpp
template <int N>
struct Factorial {
    static constexpr int value = N * Factorial<N - 1>::value;
};

template <>
struct Factorial<0> {
    static constexpr int value = 1;
};

static_assert(Factorial<5>::value == 120);

// 现代写法（C++14）
constexpr int factorial(int n) {
    int result = 1;
    for (int i = 2; i <= n; i++) result *= i;
    return result;
}
static_assert(factorial(5) == 120);
```

### 编译期斐波那契

```cpp
constexpr int fib(int n) {
    if (n <= 1) return n;
    return fib(n - 1) + fib(n - 2);
}
static_assert(fib(10) == 55);
```

---

## enable_if（SFINAE）

```cpp
// 只对整数类型启用
template <typename T>
std::enable_if_t<std::is_integral_v<T>, T>
safe_add(T a, T b) {
    return a + b;
}

// C++20 用 concepts 更简洁
template <std::integral T>
T safe_add(T a, T b) {
    return a + b;
}
```

---

## 嵌入式应用：编译期寄存器配置

```cpp
template <uint32_t Addr>
struct Register {
    static volatile uint32_t& ref() {
        return *reinterpret_cast<volatile uint32_t*>(Addr);
    }
    
    template <uint32_t Mask, uint32_t Value>
    static void set_bits() {
        static_assert((Value & ~Mask) == 0, "Value exceeds mask");
        ref() = (ref() & ~Mask) | Value;
    }
};

// 使用：零运行时开销
using GPIOA_MODER = Register<0x48000000>;
GPIOA_MODER::set_bits<0b11, 0b01>();  // 编译期检查
```

---

## 练习题

### 练习 1：编译期最大公约数

**要求**：

- 用 `constexpr` 函数实现编译期 GCD（最大公约数）
- 用 `static_assert` 在编译期验证结果
- 在 `main` 中打印多组测试

??? note "参考答案"

    ```cpp title="exercise01.cpp"
    #include <iostream>

    constexpr int gcd(int a, int b) {
        while (b != 0) {
            int t = b;
            b = a % b;
            a = t;
        }
        return a;
    }

    // 编译期验证
    static_assert(gcd(12, 8) == 4,  "gcd(12,8) 应该是 4");
    static_assert(gcd(100, 75) == 25, "gcd(100,75) 应该是 25");
    static_assert(gcd(17, 13) == 1,  "gcd(17,13) 应该是 1");
    static_assert(gcd(0, 5) == 5,    "gcd(0,5) 应该是 5");

    // 编译期求 LCM
    constexpr int lcm(int a, int b) {
        return a / gcd(a, b) * b;
    }

    static_assert(lcm(4, 6) == 12, "lcm(4,6) 应该是 12");

    int main()
    {
        std::cout << "gcd(12, 8)   = " << gcd(12, 8)   << std::endl;
        std::cout << "gcd(100, 75) = " << gcd(100, 75) << std::endl;
        std::cout << "gcd(17, 13)  = " << gcd(17, 13)  << std::endl;
        std::cout << "lcm(4, 6)    = " << lcm(4, 6)    << std::endl;
        std::cout << "lcm(12, 8)   = " << lcm(12, 8)   << std::endl;

        // 编译期常量
        constexpr int result = gcd(1024, 768);
        std::cout << "gcd(1024, 768) = " << result << " (编译期计算)" << std::endl;

        return 0;
    }
    ```

    **预期输出**：
    ```
    gcd(12, 8)   = 4
    gcd(100, 75) = 25
    gcd(17, 13)  = 1
    lcm(4, 6)    = 12
    lcm(12, 8)   = 24
    gcd(1024, 768) = 256 (编译期计算)
    ```

### 练习 2：通用 serialize 函数

**要求**：

- 用 `if constexpr` + `type_traits` 实现 `to_string_ex(T val)`
- 对整数、浮点数、布尔、字符串分别处理
- 测试多种类型

??? note "参考答案"

    ```cpp title="exercise02.cpp"
    #include <iostream>
    #include <string>
    #include <type_traits>

    template <typename T>
    std::string to_string_ex(T value) {
        if constexpr (std::is_same_v<T, bool>) {
            return value ? "true" : "false";
        } else if constexpr (std::is_integral_v<T>) {
            return std::to_string(value);
        } else if constexpr (std::is_floating_point_v<T>) {
            // 去除末尾零
            std::string s = std::to_string(value);
            s.erase(s.find_last_not_of('0') + 1);
            if (s.back() == '.') s += '0';
            return s;
        } else if constexpr (std::is_same_v<T, std::string>) {
            return "\"" + value + "\"";
        } else if constexpr (std::is_same_v<std::decay_t<T>, const char*>) {
            return std::string("\"" ) + value + "\"";
        } else {
            return "<不支持的类型>";
        }
    }

    int main()
    {
        std::cout << "int:    " << to_string_ex(42) << std::endl;
        std::cout << "bool:   " << to_string_ex(true) << std::endl;
        std::cout << "bool:   " << to_string_ex(false) << std::endl;
        std::cout << "double: " << to_string_ex(3.14) << std::endl;
        std::cout << "float:  " << to_string_ex(2.5f) << std::endl;
        std::cout << "string: " << to_string_ex(std::string("hello")) << std::endl;
        std::cout << "char*:  " << to_string_ex("world") << std::endl;

        return 0;
    }
    ```

    **预期输出**：
    ```
    int:    42
    bool:   true
    bool:   false
    double: 3.14
    float:  2.5
    string: "hello"
    char*:  "world"
    ```

---

> **下一课**：[内存管理与性能优化](../31-memory-performance/README.md)
