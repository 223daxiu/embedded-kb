# 第 19 课：类型转换

## C++ 四种类型转换

### static_cast — 编译期转换

```cpp
double pi = 3.14;
int n = static_cast<int>(pi);  // 3（显式窄化转换）

// 向上转型（安全）
Derived d;
Base *bp = static_cast<Base*>(&d);

// 向下转型（不安全，不检查）
Base *bp2 = new Derived();
Derived *dp = static_cast<Derived*>(bp2);
```

### dynamic_cast — 运行时安全转换

```cpp
Base *bp = new Derived();

// 安全向下转型（失败返回 nullptr）
Derived *dp = dynamic_cast<Derived*>(bp);
if (dp) {
    dp->derived_method();
}

// 引用版本（失败抛 std::bad_cast）
try {
    Derived &dr = dynamic_cast<Derived&>(*bp);
} catch (const std::bad_cast &e) {
    std::cerr << e.what() << std::endl;
}
```

!!! note "dynamic_cast 要求基类有虚函数"

### const_cast — 移除/添加 const

```cpp
const int x = 42;
int *p = const_cast<int*>(&x);  // 移除 const（修改行为未定义）

// 实际用途：调用不接受 const 的旧接口
void legacy_api(char *s);
const char *msg = "hello";
legacy_api(const_cast<char*>(msg));
```

### reinterpret_cast — 底层位转换

```cpp
// 指针与整数互转（嵌入式常用）
volatile uint32_t *reg = reinterpret_cast<volatile uint32_t*>(0x40020000);

// 不同指针类型互转
int x = 42;
char *bytes = reinterpret_cast<char*>(&x);
```

---

## RTTI (运行时类型信息)

```cpp
#include <typeinfo>

Base *bp = new Derived();
std::cout << typeid(*bp).name() << std::endl;  // Derived 的类型名
```

---

## 对比

| 转换方式 | 时机 | 安全性 | 用途 |
|----------|------|--------|------|
| `static_cast` | 编译期 | 中 | 常规转换 |
| `dynamic_cast` | 运行时 | 高 | 多态向下转型 |
| `const_cast` | 编译期 | 低 | 移除 const |
| `reinterpret_cast` | 编译期 | 最低 | 底层位转换 |

---

## 练习题

### 练习 1

用 `dynamic_cast` 实现安全的多态类型检查。

### 练习 2

用 `reinterpret_cast` 查看一个 float 的二进制位表示。

---

> **下一课**：[RAII 与资源管理](../20-raii/README.md)
