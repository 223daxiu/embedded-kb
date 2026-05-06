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

### 练习 1

用工厂模式 + 策略模式实现一个日志系统（支持输出到控制台、文件、网络）。

### 练习 2

用 CRTP 实现一个嵌入式外设驱动框架（UART、SPI、I2C）。

---

> **下一课**：[模板元编程](../30-metaprogramming/README.md)
