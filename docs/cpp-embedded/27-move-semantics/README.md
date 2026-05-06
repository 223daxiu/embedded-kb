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

### 练习 1

为自定义的 `String` 类添加移动构造和移动赋值，对比拷贝和移动的性能。

### 练习 2

写一个完美转发的 `log` 函数模板。

---

> **下一课**：[多线程编程](../28-multithreading/README.md)
