# 第 27 课：移动语义与完美转发

## 左值与右值

```cpp
int a = 10;       // a 是左值（有地址，有名字）
                  // 10 是右值（临时值，没有名字）

int &lr = a;      // 左值引用
// int &lr = 10;  // ❌ 不能绑定右值

int &&rr = 10;    // 右值引用 ✅
// int &&rr = a;  // ❌ 不能绑定左值
```

---

## 移动构造与移动赋值

```cpp
class Buffer {
    int *data;
    size_t size;
public:
    Buffer(size_t n) : size(n), data(new int[n]{}) {
        std::cout << "构造 " << n << std::endl;
    }
    
    // 拷贝构造（深拷贝，慢）
    Buffer(const Buffer &other) : size(other.size), data(new int[other.size]) {
        std::copy(other.data, other.data + size, data);
        std::cout << "拷贝构造" << std::endl;
    }
    
    // 移动构造（"偷"资源，快）
    Buffer(Buffer &&other) noexcept : data(other.data), size(other.size) {
        other.data = nullptr;  // 源对象置空
        other.size = 0;
        std::cout << "移动构造" << std::endl;
    }
    
    // 移动赋值
    Buffer& operator=(Buffer &&other) noexcept {
        if (this != &other) {
            delete[] data;
            data = other.data;
            size = other.size;
            other.data = nullptr;
            other.size = 0;
        }
        return *this;
    }
    
    ~Buffer() { delete[] data; }
};

Buffer create() {
    Buffer b(1000);
    return b;  // 触发移动构造（或 RVO 优化直接省略）
}

Buffer b = create();  // 零拷贝！
```

---

## std::move

`std::move` 本身不移动，只是将左值**转换为右值引用**：

```cpp
Buffer a(100);
Buffer b = std::move(a);  // a 变为"空壳"，资源转给 b
// 之后不要再使用 a！
```

---

## 完美转发

```cpp
template <typename T>
void wrapper(T &&arg) {  // 万能引用（forwarding reference）
    target(std::forward<T>(arg));  // 完美转发：保持左右值属性
}

// std::forward 规则：
// 传入左值 → 转发为左值引用
// 传入右值 → 转发为右值引用
```

### 工厂函数示例

```cpp
template <typename T, typename... Args>
std::unique_ptr<T> make(Args&&... args) {
    return std::make_unique<T>(std::forward<Args>(args)...);
}

auto p = make<std::string>("hello");  // 完美转发参数给 string 构造
```

---

## RVO / NRVO

编译器会自动优化掉不必要的拷贝/移动：

```cpp
std::string create_string() {
    std::string s = "hello";
    return s;  // NRVO：直接在调用者的空间构造，不拷贝不移动
}
```

---

## 练习题

### 练习 1：移动构造对比

**要求**：

- 为 `Buffer` 类实现拷贝构造和移动构造（打印提示）
- 分别测试拷贝和移动的场景
- 观察哪个被调用，理解差异

??? note "参考答案"

    ```cpp title="exercise01.cpp"
    #include <iostream>
    #include <cstring>
    #include <utility>

    class Buffer {
        char *data_;
        size_t size_;
    public:
        Buffer(size_t n) : size_(n), data_(new char[n]{}) {
            std::cout << "构造 Buffer(" << size_ << ")" << std::endl;
        }

        ~Buffer() {
            std::cout << "析构 Buffer(" << size_ << ") "
                      << (data_ ? "释放内存" : "空壳") << std::endl;
            delete[] data_;
        }

        // 拷贝构造
        Buffer(const Buffer &other) : size_(other.size_), data_(new char[other.size_]) {
            std::memcpy(data_, other.data_, size_);
            std::cout << "拷贝构造 Buffer(" << size_ << ") - 深拷贝" << std::endl;
        }

        // 移动构造
        Buffer(Buffer &&other) noexcept : data_(other.data_), size_(other.size_) {
            other.data_ = nullptr;
            other.size_ = 0;
            std::cout << "移动构造 Buffer(" << size_ << ") - 零拷贝" << std::endl;
        }

        size_t size() const { return size_; }
    };

    Buffer create_buffer() {
        Buffer b(1024);
        return b;
    }

    int main()
    {
        std::cout << "=== 拷贝 ===" << std::endl;
        Buffer a(100);
        Buffer b = a;  // 拷贝构造

        std::cout << "\n=== 移动 ===" << std::endl;
        Buffer c = std::move(a);  // 移动构造
        std::cout << "a.size() = " << a.size() << " (已被移动)" << std::endl;

        std::cout << "\n=== 函数返回 ===" << std::endl;
        Buffer d = create_buffer();  // 可能 RVO 或移动

        std::cout << "\n=== 析构 ===" << std::endl;
        return 0;
    }
    ```

    **预期输出**（可能因 RVO 略有不同）：
    ```
    === 拷贝 ===
    构造 Buffer(100)
    拷贝构造 Buffer(100) - 深拷贝

    === 移动 ===
    移动构造 Buffer(100) - 零拷贝
    a.size() = 0 (已被移动)

    === 函数返回 ===
    构造 Buffer(1024)

    === 析构 ===
    析构 Buffer(1024) 释放内存
    析构 Buffer(100) 释放内存
    析构 Buffer(0) 空壳
    析构 Buffer(100) 释放内存
    ```

### 练习 2：完美转发 log 函数

**要求**：

- 写一个 `log(args...)` 函数模板，接受任意参数
- 用 `std::forward` 完美转发参数给内部函数
- 打印日志级别和消息内容

??? note "参考答案"

    ```cpp title="exercise02.cpp"
    #include <iostream>
    #include <string>
    #include <sstream>

    // 内部打印函数
    template <typename... Args>
    void print_impl(std::ostream &os, Args&&... args) {
        ((os << args << " "), ...);
        os << std::endl;
    }

    // 完美转发的 log 函数
    template <typename... Args>
    void log(const std::string &level, Args&&... args) {
        std::cout << "[" << level << "] ";
        print_impl(std::cout, std::forward<Args>(args)...);
    }

    int main()
    {
        log("INFO", "程序启动");
        log("DEBUG", "变量 x =", 42, "地址:", 0x7fff);
        log("WARN", "温度过高:", 85.5, "°C");
        log("ERROR", "连接失败，重试次数:", 3);

        // 测试右值
        std::string msg = "Hello";
        log("INFO", std::move(msg), "World");

        return 0;
    }
    ```

    **预期输出**：
    ```
    [INFO] 程序启动
    [DEBUG] 变量 x = 42 地址: 32767
    [WARN] 温度过高: 85.5 °C
    [ERROR] 连接失败，重试次数: 3
    [INFO] Hello World
    ```

---

> **下一课**：[多线程编程](../28-multithreading/README.md)
