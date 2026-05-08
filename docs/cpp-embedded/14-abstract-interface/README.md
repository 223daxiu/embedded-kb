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

### 练习 1：接口设计

**要求**：

- 定义接口 `IShape`，包含 `area()` 和 `name()` 纯虚函数
- 实现 `Circle`、`Triangle`、`Square` 三个类
- 写一个 `print_shape(const IShape&)` 函数打印图形信息
- 用不同图形对象调用该函数

??? note "参考答案"

    ```cpp title="exercise01.cpp"
    #include <iostream>
    #include <cmath>
    #include <string>

    class IShape {
    public:
        virtual double area() const = 0;
        virtual std::string name() const = 0;
        virtual ~IShape() = default;
    };

    class Circle : public IShape {
        double r;
    public:
        Circle(double radius) : r(radius) {}
        double area() const override { return M_PI * r * r; }
        std::string name() const override { return "圆形(r=" + std::to_string(r) + ")"; }
    };

    class Triangle : public IShape {
        double base, height;
    public:
        Triangle(double b, double h) : base(b), height(h) {}
        double area() const override { return 0.5 * base * height; }
        std::string name() const override { return "三角形"; }
    };

    class Square : public IShape {
        double side;
    public:
        Square(double s) : side(s) {}
        double area() const override { return side * side; }
        std::string name() const override { return "正方形(边=" + std::to_string(side) + ")"; }
    };

    void print_shape(const IShape &s) {
        std::cout << s.name() << " → 面积 = " << s.area() << std::endl;
    }

    int main()
    {
        Circle c(5);
        Triangle t(6, 4);
        Square sq(3);

        print_shape(c);
        print_shape(t);
        print_shape(sq);

        return 0;
    }
    ```

    **预期输出**：
    ```
    圆形(r=5.000000) → 面积 = 78.5398
    三角形 → 面积 = 12
    正方形(边=3.000000) → 面积 = 9
    ```

### 练习 2：嵌入式接口

**要求**：

- 定义 `ISensor` 接口，包含 `init()`、`read()` 和 `name()` 纯虚函数
- 实现 `TempSensor`（返回温度）和 `HumiditySensor`（返回湿度）
- 用接口指针数组统一管理多个传感器

??? note "参考答案"

    ```cpp title="exercise02.cpp"
    #include <iostream>
    #include <vector>
    #include <memory>
    #include <string>

    class ISensor {
    public:
        virtual void init() = 0;
        virtual double read() = 0;
        virtual std::string name() const = 0;
        virtual ~ISensor() = default;
    };

    class TempSensor : public ISensor {
    public:
        void init() override { std::cout << "温度传感器初始化" << std::endl; }
        double read() override { return 25.6; }  // 模拟读取
        std::string name() const override { return "温度传感器"; }
    };

    class HumiditySensor : public ISensor {
    public:
        void init() override { std::cout << "湿度传感器初始化" << std::endl; }
        double read() override { return 65.2; }
        std::string name() const override { return "湿度传感器"; }
    };

    int main()
    {
        std::vector<std::unique_ptr<ISensor>> sensors;
        sensors.push_back(std::make_unique<TempSensor>());
        sensors.push_back(std::make_unique<HumiditySensor>());

        // 统一初始化
        for (auto &s : sensors) s->init();

        // 统一读取
        std::cout << "\n--- 传感器读数 ---" << std::endl;
        for (auto &s : sensors) {
            std::cout << s->name() << ": " << s->read() << std::endl;
        }

        return 0;
    }
    ```

    **预期输出**：
    ```
    温度传感器初始化
    湿度传感器初始化

    --- 传感器读数 ---
    温度传感器: 25.6
    湿度传感器: 65.2
    ```

---

> **下一课**：[模板基础](../15-template-basic/README.md)
