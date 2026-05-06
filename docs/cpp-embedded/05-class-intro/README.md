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

### 练习 1

设计一个 `Rectangle` 类，包含宽和高，提供面积和周长方法。

### 练习 2

设计一个 `BankAccount` 类，支持存款、取款、查询余额，余额不能为负。

---

> **下一课**：[new/delete 与内存管理](../06-new-delete/README.md)
