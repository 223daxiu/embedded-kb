# 第 12 课：继承

## 基本继承

```cpp
class Animal {
protected:
    std::string name;
    int age;
public:
    Animal(const std::string &n, int a) : name(n), age(a) {}
    void eat() const { std::cout << name << " 在吃东西" << std::endl; }
};

class Dog : public Animal {
    std::string breed;
public:
    Dog(const std::string &n, int a, const std::string &b)
        : Animal(n, a), breed(b) {}  // 调用基类构造
    
    void bark() const { std::cout << name << " 汪汪！" << std::endl; }
};

Dog d("旺财", 3, "柴犬");
d.eat();   // 继承自 Animal
d.bark();  // Dog 自己的方法
```

---

## 继承方式

| 基类成员 | public 继承 | protected 继承 | private 继承 |
|----------|------------|---------------|-------------|
| public | public | protected | private |
| protected | protected | protected | private |
| private | 不可访问 | 不可访问 | 不可访问 |

**99% 的情况用 `public` 继承**。

---

## 构造与析构顺序

```cpp
class Base {
public:
    Base() { std::cout << "Base 构造\n"; }
    ~Base() { std::cout << "Base 析构\n"; }
};

class Derived : public Base {
public:
    Derived() { std::cout << "Derived 构造\n"; }
    ~Derived() { std::cout << "Derived 析构\n"; }
};

Derived d;
// 构造：Base → Derived
// 析构：Derived → Base
```

---

## 函数覆盖与隐藏

```cpp
class Base {
public:
    void greet() { std::cout << "Hello from Base\n"; }
};

class Derived : public Base {
public:
    void greet() { std::cout << "Hello from Derived\n"; }  // 隐藏基类版本
    
    void call_base() {
        Base::greet();  // 显式调用基类版本
    }
};

Derived d;
d.greet();       // Hello from Derived
d.call_base();   // Hello from Base
```

---

## 多继承

```cpp
class Printable {
public:
    virtual void print() const = 0;
};

class Serializable {
public:
    virtual std::string serialize() const = 0;
};

class Config : public Printable, public Serializable {
    std::string data;
public:
    Config(const std::string &d) : data(d) {}
    void print() const override { std::cout << data << std::endl; }
    std::string serialize() const override { return data; }
};
```

!!! warning "菱形继承问题"
    多继承可能导致菱形继承，用 `virtual` 继承解决：
    ```cpp
    class A { public: int x; };
    class B : virtual public A {};
    class C : virtual public A {};
    class D : public B, public C {};  // 只有一份 A::x
    ```

---

## 练习题

### 练习 1：Shape 继承体系

**要求**：

- 设计基类 `Shape`，包含 `name` 和 `area()` 方法
- 派生 `Circle`（半径）和 `Rectangle`（宽、高）
- 每个类实现自己的 `area()` 和 `print()` 方法
- 创建对象并打印信息

??? note "参考答案"

    ```cpp title="exercise01.cpp"
    #include <iostream>
    #include <string>
    #include <cmath>

    class Shape {
    protected:
        std::string name;
    public:
        Shape(const std::string &n) : name(n) {}
        virtual double area() const = 0;
        virtual void print() const {
            std::cout << name << ", 面积 = " << area() << std::endl;
        }
        virtual ~Shape() = default;
    };

    class Circle : public Shape {
        double radius;
    public:
        Circle(double r) : Shape("圆形"), radius(r) {}
        double area() const override {
            return M_PI * radius * radius;
        }
        void print() const override {
            std::cout << name << "(半径=" << radius << "), 面积 = "
                      << std::fixed << std::setprecision(2) << area() << std::endl;
        }
    };

    class Rectangle : public Shape {
        double width, height;
    public:
        Rectangle(double w, double h) : Shape("矩形"), width(w), height(h) {}
        double area() const override {
            return width * height;
        }
        void print() const override {
            std::cout << name << "(" << width << "x" << height << "), 面积 = "
                      << area() << std::endl;
        }
    };

    int main()
    {
        Circle c(5.0);
        Rectangle r(4.0, 6.0);

        c.print();
        r.print();

        return 0;
    }
    ```

    **预期输出**：
    ```
    圆形(半径=5), 面积 = 78.54
    矩形(4x6), 面积 = 24
    ```

### 练习 2：三层继承构造析构顺序

**要求**：

- 定义三个类 `A` → `B` → `C`（继承关系）
- 每个类的构造和析构函数中打印提示
- 观察并记录构造/析构顺序

??? note "参考答案"

    ```cpp title="exercise02.cpp"
    #include <iostream>

    class A {
    public:
        A()  { std::cout << "A 构造" << std::endl; }
        ~A() { std::cout << "A 析构" << std::endl; }
    };

    class B : public A {
    public:
        B()  { std::cout << "B 构造" << std::endl; }
        ~B() { std::cout << "B 析构" << std::endl; }
    };

    class C : public B {
    public:
        C()  { std::cout << "C 构造" << std::endl; }
        ~C() { std::cout << "C 析构" << std::endl; }
    };

    int main()
    {
        std::cout << "=== 创建 C 对象 ===" << std::endl;
        {
            C obj;
        }
        std::cout << "=== 对象已销毁 ===" << std::endl;

        return 0;
    }
    ```

    **预期输出**：
    ```
    === 创建 C 对象 ===
    A 构造
    B 构造
    C 构造
    C 析构
    B 析构
    A 析构
    === 对象已销毁 ===
    ```

    > 规律：构造从基类到派生类（A→B→C），析构顺序相反（C→B→A）。

---

> **下一课**：[多态与虚函数](../13-polymorphism/README.md)
