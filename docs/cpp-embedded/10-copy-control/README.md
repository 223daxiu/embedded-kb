# 第 10 课：拷贝控制

## 浅拷贝的问题

```cpp
class Buffer {
    int *data;
    int size;
public:
    Buffer(int n) : size(n), data(new int[n]{}) {}
    ~Buffer() { delete[] data; }
};

Buffer a(10);
Buffer b = a;  // 默认浅拷贝：b.data 和 a.data 指向同一块内存
// 当 a 和 b 都析构时 → 同一块内存被 delete 两次 → 崩溃！
```

---

## 拷贝构造函数

```cpp
class Buffer {
    int *data;
    int size;
public:
    Buffer(int n) : size(n), data(new int[n]{}) {}
    
    // 拷贝构造函数（深拷贝）
    Buffer(const Buffer &other) : size(other.size), data(new int[other.size]) {
        std::copy(other.data, other.data + size, data);
        std::cout << "拷贝构造" << std::endl;
    }
    
    ~Buffer() { delete[] data; }
};

Buffer a(10);
Buffer b = a;   // 调用拷贝构造
Buffer c(a);    // 也是拷贝构造
```

---

## 拷贝赋值运算符

```cpp
class Buffer {
    int *data;
    int size;
public:
    Buffer(int n) : size(n), data(new int[n]{}) {}
    Buffer(const Buffer &other) : size(other.size), data(new int[other.size]) {
        std::copy(other.data, other.data + size, data);
    }
    
    // 拷贝赋值运算符
    Buffer& operator=(const Buffer &other) {
        if (this == &other) return *this;  // 自赋值检查
        
        delete[] data;  // 释放旧内存
        size = other.size;
        data = new int[size];
        std::copy(other.data, other.data + size, data);
        
        return *this;
    }
    
    ~Buffer() { delete[] data; }
};

Buffer a(10), b(5);
b = a;  // 调用拷贝赋值运算符
```

---

## Rule of Three

如果你定义了**析构函数、拷贝构造、拷贝赋值**中的任一个，通常三个都需要定义。

```cpp
class MyClass {
public:
    ~MyClass();                              // 析构
    MyClass(const MyClass &);                // 拷贝构造
    MyClass& operator=(const MyClass &);     // 拷贝赋值
};
```

### Rule of Five（C++11）

加上**移动构造和移动赋值**：

```cpp
class MyClass {
public:
    ~MyClass();
    MyClass(const MyClass &);
    MyClass& operator=(const MyClass &);
    MyClass(MyClass &&) noexcept;            // 移动构造
    MyClass& operator=(MyClass &&) noexcept; // 移动赋值
};
```

### Rule of Zero

最好的做法：**让编译器自动生成所有**，使用智能指针管理资源：

```cpp
class MyClass {
    std::vector<int> data;   // 自动管理内存
    std::string name;        // 自动管理
    // 不需要手写任何特殊函数！
};
```

---

## 练习题

### 练习 1

为一个管理动态字符串的类实现完整的拷贝控制（Rule of Three）。

### 练习 2

解释以下代码为什么会崩溃，如何修复。
```cpp
class A { int *p; public: A() : p(new int(42)) {} ~A() { delete p; } };
A a; A b = a;
```

---

> **下一课**：[运算符重载](../11-operator-overload/README.md)
