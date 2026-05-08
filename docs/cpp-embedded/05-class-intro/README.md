# 第 05 课：类与对象入门

## 什么是类？

类是**数据 + 操作**的封装，是面向对象编程的基础：

```cpp title="class_intro.cpp"
#include <iostream>
#include <string>

class Student {
public:     // 公有成员（外部可访问）
    std::string name;
    int age;
    
    void introduce() {
        std::cout << "我是 " << name << "，今年 " << age << " 岁" << std::endl;
    }
    
private:    // 私有成员（仅类内部可访问）
    float score;
    
public:
    void set_score(float s) {
        if (s >= 0 && s <= 100) score = s;  // 数据验证
    }
    
    float get_score() const { return score; }
};

int main()
{
    Student s;
    s.name = "张三";
    s.age = 20;
    s.set_score(95.5);
    // s.score = 95.5;  // ❌ 私有成员不能直接访问
    
    s.introduce();
    std::cout << "成绩: " << s.get_score() << std::endl;
    
    return 0;
}
```

---

## 访问控制

| 修饰符 | 类内 | 子类 | 外部 |
|--------|------|------|------|
| `public` | ✅ | ✅ | ✅ |
| `protected` | ✅ | ✅ | ❌ |
| `private` | ✅ | ❌ | ❌ |

!!! tip "class vs struct"
    - `class` 默认 `private`
    - `struct` 默认 `public`
    - 其他完全一样

---

## 构造函数

```cpp
class Point {
public:
    double x, y;
    
    // 默认构造
    Point() : x(0), y(0) {}
    
    // 参数构造
    Point(double x, double y) : x(x), y(y) {}
    
    void print() const {
        std::cout << "(" << x << ", " << y << ")" << std::endl;
    }
};

Point p1;          // (0, 0)
Point p2(3, 4);    // (3, 4)
Point p3{1, 2};    // C++11 列表初始化
```

---

## this 指针

`this` 是指向当前对象的指针：

```cpp
class Counter {
    int count = 0;
public:
    Counter& increment() {
        count++;
        return *this;  // 返回自身引用，支持链式调用
    }
    int get() const { return count; }
};

Counter c;
c.increment().increment().increment();
std::cout << c.get() << std::endl;  // 3
```

---

## static 成员

```cpp
class Connection {
    static int total;  // 所有对象共享
public:
    Connection() { total++; }
    ~Connection() { total--; }
    static int get_total() { return total; }
};
int Connection::total = 0;  // 类外初始化

Connection a, b, c;
std::cout << Connection::get_total() << std::endl;  // 3
```

---

## 练习题

### 练习 1：Rectangle 类

**要求**：

- 设计 `Rectangle` 类，包含私有成员 `width` 和 `height`（double 类型）
- 提供构造函数，支持指定宽高
- 提供 `area()` 和 `perimeter()` 方法计算面积和周长
- 提供 `print()` 方法输出信息
- 创建多个矩形对象测试

??? note "参考答案"

    ```cpp title="exercise01.cpp"
    #include <iostream>

    class Rectangle {
    private:
        double width;
        double height;

    public:
        Rectangle(double w, double h) : width(w), height(h) {}

        double area() const { return width * height; }
        double perimeter() const { return 2 * (width + height); }

        void print() const {
            std::cout << "Rectangle(" << width << " x " << height << ")  "
                      << "面积=" << area() << "  周长=" << perimeter() << std::endl;
        }
    };

    int main()
    {
        Rectangle r1(5, 3);
        Rectangle r2(10, 10);
        Rectangle r3(7.5, 2.4);

        r1.print();
        r2.print();
        r3.print();

        return 0;
    }
    ```

    **预期输出**：
    ```
    Rectangle(5 x 3)  面积=15  周长=16
    Rectangle(10 x 10)  面积=100  周长=40
    Rectangle(7.5 x 2.4)  面积=18  周长=19.8
    ```

### 练习 2：银行账户类

**要求**：

- 设计 `BankAccount` 类，包含私有成员 `owner`（字符串）和 `balance`（余额）
- 提供 `deposit(double)` 存款方法（金额必须为正）
- 提供 `withdraw(double)` 取款方法（余额不足时拒绝并提示）
- 提供 `show()` 查询余额方法
- 测试存款、取款、余额不足等场景

??? note "参考答案"

    ```cpp title="exercise02.cpp"
    #include <iostream>
    #include <string>
    #include <iomanip>

    class BankAccount {
    private:
        std::string owner;
        double balance;

    public:
        BankAccount(const std::string &name, double init_balance = 0)
            : owner(name), balance(init_balance) {}

        void deposit(double amount) {
            if (amount <= 0) {
                std::cout << "✗ 存款金额必须为正数" << std::endl;
                return;
            }
            balance += amount;
            std::cout << "✓ 存款 " << std::fixed << std::setprecision(2)
                      << amount << " 元成功" << std::endl;
        }

        void withdraw(double amount) {
            if (amount <= 0) {
                std::cout << "✗ 取款金额必须为正数" << std::endl;
                return;
            }
            if (amount > balance) {
                std::cout << "✗ 余额不足！当前余额: " << std::fixed
                          << std::setprecision(2) << balance << " 元" << std::endl;
                return;
            }
            balance -= amount;
            std::cout << "✓ 取款 " << std::fixed << std::setprecision(2)
                      << amount << " 元成功" << std::endl;
        }

        void show() const {
            std::cout << "[账户] " << owner << "  余额: "
                      << std::fixed << std::setprecision(2) << balance << " 元" << std::endl;
        }
    };

    int main()
    {
        BankAccount acc("张三", 1000);
        acc.show();

        acc.deposit(500);
        acc.show();

        acc.withdraw(300);
        acc.show();

        acc.withdraw(2000);  // 余额不足
        acc.show();

        return 0;
    }
    ```

    **预期输出**：
    ```
    [账户] 张三  余额: 1000.00 元
    ✓ 存款 500.00 元成功
    [账户] 张三  余额: 1500.00 元
    ✓ 取款 300.00 元成功
    [账户] 张三  余额: 1200.00 元
    ✗ 余额不足！当前余额: 1200.00 元
    [账户] 张三  余额: 1200.00 元
    ```

---

> **下一课**：[new/delete 与内存管理](../06-new-delete/README.md)
