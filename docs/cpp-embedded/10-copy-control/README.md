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

### 练习 1：Rule of Three 实践

**要求**：

- 设计 `MyString` 类，内部用 `char*` 管理字符串
- 实现构造函数、析构函数、拷贝构造、拷贝赋值（Rule of Three）
- 提供 `print()` 和 `length()` 方法
- 测试拷贝构造、拷贝赋值、自赋值场景

??? note "参考答案"

    ```cpp title="exercise01.cpp"
    #include <iostream>
    #include <cstring>

    class MyString {
        char *data_;
        size_t len_;
    public:
        // 构造
        MyString(const char *s = "") : len_(strlen(s)), data_(new char[strlen(s) + 1]) {
            strcpy(data_, s);
            std::cout << "构造: \"" << data_ << "\"" << std::endl;
        }

        // 析构
        ~MyString() {
            std::cout << "析构: \"" << (data_ ? data_ : "null") << "\"" << std::endl;
            delete[] data_;
        }

        // 拷贝构造（深拷贝）
        MyString(const MyString &other) : len_(other.len_), data_(new char[other.len_ + 1]) {
            strcpy(data_, other.data_);
            std::cout << "拷贝构造: \"" << data_ << "\"" << std::endl;
        }

        // 拷贝赋值（copy-and-swap 手法）
        MyString& operator=(const MyString &other) {
            std::cout << "拷贝赋值: \"" << other.data_ << "\"" << std::endl;
            if (this != &other) {
                char *new_data = new char[other.len_ + 1];
                strcpy(new_data, other.data_);
                delete[] data_;
                data_ = new_data;
                len_ = other.len_;
            }
            return *this;
        }

        void print() const { std::cout << "\"" << data_ << "\" (len=" << len_ << ")" << std::endl; }
        size_t length() const { return len_; }
    };

    int main()
    {
        std::cout << "--- 构造 ---" << std::endl;
        MyString s1("Hello");

        std::cout << "\n--- 拷贝构造 ---" << std::endl;
        MyString s2 = s1;

        std::cout << "\n--- 拷贝赋值 ---" << std::endl;
        MyString s3("World");
        s3 = s1;

        std::cout << "\n--- 打印结果 ---" << std::endl;
        s1.print();
        s2.print();
        s3.print();

        std::cout << "\n--- 析构 ---" << std::endl;
        return 0;
    }
    ```

    **预期输出**：
    ```
    --- 构造 ---
    构造: "Hello"

    --- 拷贝构造 ---
    拷贝构造: "Hello"

    --- 拷贝赋值 ---
    构造: "World"
    拷贝赋值: "Hello"

    --- 打印结果 ---
    "Hello" (len=5)
    "Hello" (len=5)
    "Hello" (len=5)

    --- 析构 ---
    析构: "Hello"
    析构: "Hello"
    析构: "Hello"
    ```

### 练习 2：分析崩溃原因

**题目**：以下代码会崩溃，请解释原因并修复。

```cpp
class A {
    int *p;
public:
    A() : p(new int(42)) {}
    ~A() { delete p; }
};
A a;
A b = a;
```

??? note "参考答案"

    **崩溃原因**：

    1. `A b = a;` 调用默认拷贝构造，执行**浅拷贝**
    2. `a.p` 和 `b.p` 指向**同一块内存**
    3. 程序结束时 `b` 先析构，`delete b.p` 释放内存
    4. `a` 再析构，`delete a.p` 重复释放→ **未定义行为（崩溃）**

    **修复方法**：添加拷贝构造函数（深拷贝）：

    ```cpp title="fix.cpp"
    class A {
        int *p;
    public:
        A() : p(new int(42)) {}
        ~A() { delete p; }

        // 添加深拷贝
        A(const A &other) : p(new int(*other.p)) {
            std::cout << "深拷贝，值=" << *p << std::endl;
        }

        // 拷贝赋值
        A& operator=(const A &other) {
            if (this != &other) {
                *p = *other.p;  // 拷贝值，不拷贝指针
            }
            return *this;
        }
    };
    ```

---

> **下一课**：[运算符重载](../11-operator-overload/README.md)
