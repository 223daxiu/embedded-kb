# 第 14 课：抽象类与接口

## 纯虚函数与抽象类

```cpp
class Device {
public:
    virtual void init() = 0;       // 纯虚函数（= 0）
    virtual void read() = 0;
    virtual void write(int val) = 0;
    virtual ~Device() = default;
};

// Device d;  // ❌ 抽象类不能实例化

class LED : public Device {
    int pin;
public:
    LED(int p) : pin(p) {}
    void init() override { std::cout << "LED pin " << pin << " 初始化\n"; }
    void read() override { /* LED 不读 */ }
    void write(int val) override {
        std::cout << "LED " << (val ? "ON" : "OFF") << std::endl;
    }
};
```

---

## 接口设计

C++ 没有 `interface` 关键字，用**只有纯虚函数的抽象类**模拟：

```cpp title="interface_example.cpp"
// 接口：可打印
class IPrintable {
public:
    virtual void print() const = 0;
    virtual ~IPrintable() = default;
};

// 接口：可序列化
class ISerializable {
public:
    virtual std::string serialize() const = 0;
    virtual bool deserialize(const std::string &data) = 0;
    virtual ~ISerializable() = default;
};

// 实现多个接口
class SensorData : public IPrintable, public ISerializable {
    int id;
    double value;
public:
    SensorData(int id, double v) : id(id), value(v) {}
    
    void print() const override {
        std::cout << "Sensor#" << id << ": " << value << std::endl;
    }
    
    std::string serialize() const override {
        return std::to_string(id) + "," + std::to_string(value);
    }
    
    bool deserialize(const std::string &data) override {
        // 简化实现
        return true;
    }
};
```

---

## 实战：驱动接口

```cpp
class IDriver {
public:
    virtual int open() = 0;
    virtual int close() = 0;
    virtual int read(void *buf, int len) = 0;
    virtual int write(const void *buf, int len) = 0;
    virtual ~IDriver() = default;
};

class UARTDriver : public IDriver {
    int baudrate;
public:
    UARTDriver(int baud) : baudrate(baud) {}
    int open() override { /* 初始化 UART */ return 0; }
    int close() override { return 0; }
    int read(void *buf, int len) override { return len; }
    int write(const void *buf, int len) override { return len; }
};

// 通过接口使用，不关心具体实现
void transfer(IDriver &drv, const char *msg) {
    drv.open();
    drv.write(msg, strlen(msg));
    drv.close();
}
```

---

## 练习题

### 练习 1

设计 `ILogger` 接口（log/warn/error 方法），实现 `ConsoleLogger` 和 `FileLogger`。

### 练习 2

设计一个插件系统：`IPlugin` 接口（init/run/stop），多个插件通过基类指针管理。

---

> **下一课**：[模板基础](../15-template-basic/README.md)
