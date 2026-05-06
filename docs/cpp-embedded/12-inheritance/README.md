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

### 练习 1

设计 `Shape → Circle / Rectangle` 继承体系，包含面积方法。

### 练习 2

理解构造析构顺序：三层继承 `A → B → C`。

---

> **下一课**：[多态与虚函数](../13-polymorphism/README.md)
