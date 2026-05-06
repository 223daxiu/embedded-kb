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

### 练习 1

用模板元编程实现编译期求最大公约数。

### 练习 2

用 `type_traits` + `if constexpr` 实现一个通用的 `serialize` 函数。

---

> **下一课**：[内存管理与性能优化](../31-memory-performance/README.md)
