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

### 练习 1：dynamic_cast 安全类型检查

**要求**：

- 定义基类 `Shape`（含 `virtual` 方法）和派生类 `Circle`、`Rectangle`
- 写函数接受 `Shape*` 参数，用 `dynamic_cast` 判断实际类型
- 转换成功时调用子类专有方法，失败时提示类型不匹配

??? note "参考答案"

    ```cpp title="exercise01.cpp"
    #include <iostream>
    #include <vector>
    #include <memory>

    class Shape {
    public:
        virtual void draw() const = 0;
        virtual ~Shape() = default;
    };

    class Circle : public Shape {
        double r;
    public:
        Circle(double radius) : r(radius) {}
        void draw() const override { std::cout << "画圆" << std::endl; }
        double radius() const { return r; }
    };

    class Rectangle : public Shape {
        double w, h;
    public:
        Rectangle(double w, double h) : w(w), h(h) {}
        void draw() const override { std::cout << "画矩形" << std::endl; }
        double width() const { return w; }
        double height() const { return h; }
    };

    void identify(Shape *s) {
        if (auto *c = dynamic_cast<Circle*>(s)) {
            std::cout << "这是圆形，半径 = " << c->radius() << std::endl;
        } else if (auto *r = dynamic_cast<Rectangle*>(s)) {
            std::cout << "这是矩形，" << r->width() << "x" << r->height() << std::endl;
        } else {
            std::cout << "未知形状" << std::endl;
        }
    }

    int main()
    {
        std::vector<std::unique_ptr<Shape>> shapes;
        shapes.push_back(std::make_unique<Circle>(5.0));
        shapes.push_back(std::make_unique<Rectangle>(3, 4));
        shapes.push_back(std::make_unique<Circle>(2.5));

        for (auto &s : shapes) {
            s->draw();
            identify(s.get());
            std::cout << std::endl;
        }

        return 0;
    }
    ```

    **预期输出**：
    ```
    画圆
    这是圆形，半径 = 5

    画矩形
    这是矩形，3x4

    画圆
    这是圆形，半径 = 2.5
    ```

### 练习 2：reinterpret_cast 查看内存表示

**要求**：

- 用 `reinterpret_cast` 把 `float` 的地址转为 `unsigned char*`
- 逐字节打印 float 的二进制/十六进制内存表示
- 测试 `0.0f`、`1.0f`、`-1.0f` 三个值

??? note "参考答案"

    ```cpp title="exercise02.cpp"
    #include <iostream>
    #include <iomanip>
    #include <bitset>

    void print_float_bytes(float f) {
        auto *bytes = reinterpret_cast<unsigned char*>(&f);
        std::cout << f << " 的内存表示: ";
        for (int i = sizeof(float) - 1; i >= 0; i--) {
            std::cout << std::hex << std::setw(2) << std::setfill('0')
                      << static_cast<int>(bytes[i]) << " ";
        }
        std::cout << " → 二进制: ";
        for (int i = sizeof(float) - 1; i >= 0; i--) {
            std::cout << std::bitset<8>(bytes[i]) << " ";
        }
        std::cout << std::dec << std::endl;
    }

    int main()
    {
        print_float_bytes(0.0f);
        print_float_bytes(1.0f);
        print_float_bytes(-1.0f);
        print_float_bytes(3.14f);

        return 0;
    }
    ```

    **预期输出**（小端序）：
    ```
    0 的内存表示: 00 00 00 00  → 二进制: 00000000 00000000 00000000 00000000
    1 的内存表示: 3f 80 00 00  → 二进制: 00111111 10000000 00000000 00000000
    -1 的内存表示: bf 80 00 00  → 二进制: 10111111 10000000 00000000 00000000
    3.14 的内存表示: 40 48 f5 c3  → 二进制: 01000000 01001000 11110101 11000011
    ```

---

> **下一课**：[RAII 与资源管理](../20-raii/README.md)
