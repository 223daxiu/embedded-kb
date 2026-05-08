# 第 29 课：设计模式

## 单例模式（Singleton）

全局唯一实例：

```cpp
class Logger {
public:
    static Logger& instance() {
        static Logger inst;  // C++11 保证线程安全
        return inst;
    }
    
    void log(const std::string &msg) {
        std::lock_guard<std::mutex> lock(mtx_);
        std::cout << "[LOG] " << msg << std::endl;
    }
    
    Logger(const Logger&) = delete;
    Logger& operator=(const Logger&) = delete;

private:
    Logger() = default;
    std::mutex mtx_;
};

// 使用
Logger::instance().log("系统启动");
```

---

## 工厂模式（Factory）

```cpp
class Shape {
public:
    virtual void draw() = 0;
    virtual ~Shape() = default;
};

class Circle : public Shape {
public:
    void draw() override { std::cout << "画圆" << std::endl; }
};

class Rectangle : public Shape {
public:
    void draw() override { std::cout << "画矩形" << std::endl; }
};

// 工厂函数
std::unique_ptr<Shape> create_shape(const std::string &type) {
    if (type == "circle") return std::make_unique<Circle>();
    if (type == "rect")   return std::make_unique<Rectangle>();
    return nullptr;
}

auto shape = create_shape("circle");
shape->draw();
```

---

## 观察者模式（Observer）

```cpp
#include <functional>
#include <vector>
#include <string>

class EventBus {
    std::unordered_map<std::string, std::vector<std::function<void(int)>>> listeners_;
public:
    void subscribe(const std::string &event, std::function<void(int)> callback) {
        listeners_[event].push_back(std::move(callback));
    }
    
    void publish(const std::string &event, int data) {
        if (listeners_.count(event)) {
            for (auto &cb : listeners_[event]) cb(data);
        }
    }
};

EventBus bus;
bus.subscribe("温度变化", [](int temp) {
    std::cout << "传感器收到: " << temp << "°C" << std::endl;
});
bus.publish("温度变化", 25);
```

---

## 策略模式（Strategy）

```cpp
class SortStrategy {
public:
    virtual void sort(std::vector<int> &data) = 0;
    virtual ~SortStrategy() = default;
};

class BubbleSort : public SortStrategy {
public:
    void sort(std::vector<int> &data) override {
        for (size_t i = 0; i < data.size(); i++)
            for (size_t j = 0; j + 1 < data.size() - i; j++)
                if (data[j] > data[j+1]) std::swap(data[j], data[j+1]);
    }
};

class QuickSort : public SortStrategy {
public:
    void sort(std::vector<int> &data) override {
        std::sort(data.begin(), data.end());
    }
};

class Sorter {
    std::unique_ptr<SortStrategy> strategy_;
public:
    void set_strategy(std::unique_ptr<SortStrategy> s) {
        strategy_ = std::move(s);
    }
    void sort(std::vector<int> &data) {
        strategy_->sort(data);
    }
};
```

---

## CRTP（编译期多态）

嵌入式中避免虚函数开销：

```cpp
template <typename Derived>
class DriverBase {
public:
    void init() {
        static_cast<Derived*>(this)->do_init();
    }
    void read() {
        static_cast<Derived*>(this)->do_read();
    }
};

class SpiDriver : public DriverBase<SpiDriver> {
public:
    void do_init() { std::cout << "SPI 初始化" << std::endl; }
    void do_read() { std::cout << "SPI 读取" << std::endl; }
};

class I2cDriver : public DriverBase<I2cDriver> {
public:
    void do_init() { std::cout << "I2C 初始化" << std::endl; }
    void do_read() { std::cout << "I2C 读取" << std::endl; }
};

template <typename T>
void use_driver(DriverBase<T> &drv) {
    drv.init();
    drv.read();
}
// 零虚函数开销！编译期确定调用
```

---

## 练习题

### 练习 1：工厂 + 策略日志系统

**要求**：

- 定义 `ILogger` 接口（`log(string)`）
- 实现 `ConsoleLogger` 和 `FileLogger`（模拟）
- 用工厂函数根据字符串创建对应的 Logger
- 通过接口指针统一调用

??? note "参考答案"

    ```cpp title="exercise01.cpp"
    #include <iostream>
    #include <memory>
    #include <string>

    class ILogger {
    public:
        virtual void log(const std::string &msg) = 0;
        virtual ~ILogger() = default;
    };

    class ConsoleLogger : public ILogger {
    public:
        void log(const std::string &msg) override {
            std::cout << "[控制台] " << msg << std::endl;
        }
    };

    class FileLogger : public ILogger {
        std::string filename_;
    public:
        FileLogger(const std::string &f) : filename_(f) {}
        void log(const std::string &msg) override {
            std::cout << "[文件:" << filename_ << "] " << msg << std::endl;
        }
    };

    // 工厂函数
    std::unique_ptr<ILogger> create_logger(const std::string &type) {
        if (type == "console") return std::make_unique<ConsoleLogger>();
        if (type == "file")    return std::make_unique<FileLogger>("app.log");
        return nullptr;
    }

    int main()
    {
        auto logger1 = create_logger("console");
        auto logger2 = create_logger("file");

        logger1->log("程序启动");
        logger2->log("程序启动");
        logger1->log("处理完成");
        logger2->log("处理完成");

        return 0;
    }
    ```

    **预期输出**：
    ```
    [控制台] 程序启动
    [文件:app.log] 程序启动
    [控制台] 处理完成
    [文件:app.log] 处理完成
    ```

### 练习 2：CRTP 驱动框架

**要求**：

- 用 CRTP 实现基类 `DriverBase`，提供 `init()`、`read()`、`write()` 接口
- 实现 `UartDriver` 和 `SpiDriver` 两个具体驱动
- 用模板函数统一调用，无虚函数开销

??? note "参考答案"

    ```cpp title="exercise02.cpp"
    #include <iostream>
    #include <string>

    template <typename Derived>
    class DriverBase {
    public:
        void init() {
            std::cout << "[初始化] ";
            static_cast<Derived*>(this)->do_init();
        }
        int read() {
            return static_cast<Derived*>(this)->do_read();
        }
        void write(int data) {
            static_cast<Derived*>(this)->do_write(data);
        }
    };

    class UartDriver : public DriverBase<UartDriver> {
        friend class DriverBase<UartDriver>;
        void do_init()  { std::cout << "UART 115200 8N1" << std::endl; }
        int do_read()    { std::cout << "UART 读取" << std::endl; return 0x41; }
        void do_write(int d) { std::cout << "UART 发送: 0x" << std::hex << d << std::dec << std::endl; }
    };

    class SpiDriver : public DriverBase<SpiDriver> {
        friend class DriverBase<SpiDriver>;
        void do_init()  { std::cout << "SPI Mode0 1MHz" << std::endl; }
        int do_read()    { std::cout << "SPI 读取" << std::endl; return 0xFF; }
        void do_write(int d) { std::cout << "SPI 发送: 0x" << std::hex << d << std::dec << std::endl; }
    };

    template <typename T>
    void test_driver(DriverBase<T> &drv) {
        drv.init();
        drv.write(0xAA);
        int val = drv.read();
        std::cout << "读取结果: 0x" << std::hex << val << std::dec << std::endl;
    }

    int main()
    {
        std::cout << "=== UART ==="  << std::endl;
        UartDriver uart;
        test_driver(uart);

        std::cout << "\n=== SPI ==="  << std::endl;
        SpiDriver spi;
        test_driver(spi);

        return 0;
    }
    ```

    **预期输出**：
    ```
    === UART ===
    [初始化] UART 115200 8N1
    UART 发送: 0xaa
    UART 读取
    读取结果: 0x41

    === SPI ===
    [初始化] SPI Mode0 1MHz
    SPI 发送: 0xaa
    SPI 读取
    读取结果: 0xff
    ```

---

> **下一课**：[模板元编程](../30-metaprogramming/README.md)
