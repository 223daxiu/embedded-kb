# 第 32 课：嵌入式 C++

## 零开销抽象

C++ 的核心理念：**你不用的东西不会产生开销，你用的东西手写也不会更快。**

```cpp
// 模板 vs 虚函数：编译期多态，零运行时开销
template <typename Pin>
void toggle(Pin &pin) {
    pin.set_high();
    pin.set_low();
}
// 编译后等同于直接操作寄存器
```

---

## GPIO HAL 模板

```cpp
template <uint32_t BaseAddr, uint8_t PinNum>
class Gpio {
    static volatile uint32_t& odr() {
        return *reinterpret_cast<volatile uint32_t*>(BaseAddr + 0x14);
    }
    static volatile uint32_t& moder() {
        return *reinterpret_cast<volatile uint32_t*>(BaseAddr);
    }

public:
    static void init_output() {
        uint32_t val = moder();
        val &= ~(0b11 << (PinNum * 2));
        val |=  (0b01 << (PinNum * 2));
        moder() = val;
    }
    
    static void set()   { odr() |=  (1 << PinNum); }
    static void clear() { odr() &= ~(1 << PinNum); }
    static void toggle(){ odr() ^=  (1 << PinNum); }
};

// 使用（编译期确定地址，零开销）
using LED = Gpio<0x48000000, 5>;  // PA5
LED::init_output();
LED::set();
```

---

## 中断安全 RAII

```cpp
class CriticalSection {
public:
    CriticalSection() {
        // __disable_irq();  // ARM 关中断
        saved_primask_ = __get_PRIMASK();
        __set_PRIMASK(1);
    }
    ~CriticalSection() {
        __set_PRIMASK(saved_primask_);  // 恢复之前的中断状态
    }
    CriticalSection(const CriticalSection&) = delete;
    CriticalSection& operator=(const CriticalSection&) = delete;
private:
    uint32_t saved_primask_;
};

// 使用
void update_shared_data() {
    CriticalSection cs;  // 自动关中断
    shared_counter++;
}  // 自动恢复中断
```

---

## 静态多态驱动框架

```cpp
template <typename Impl>
class UartBase {
public:
    void init(uint32_t baud) {
        static_cast<Impl*>(this)->do_init(baud);
    }
    void send(uint8_t byte) {
        static_cast<Impl*>(this)->do_send(byte);
    }
    void send_string(const char *str) {
        while (*str) send(*str++);
    }
};

class Uart1 : public UartBase<Uart1> {
    friend class UartBase<Uart1>;
    void do_init(uint32_t baud) {
        // USART1 寄存器配置
    }
    void do_send(uint8_t byte) {
        // 写 USART1->DR
    }
};

Uart1 uart;
uart.init(115200);
uart.send_string("Hello embedded C++!\r\n");
```

---

## constexpr 编译期计算

```cpp
// 编译期计算波特率寄存器值
constexpr uint16_t calc_brr(uint32_t pclk, uint32_t baud) {
    return static_cast<uint16_t>(pclk / baud);
}

constexpr auto BRR_115200 = calc_brr(72'000'000, 115200);  // 编译期算好
```

---

## 嵌入式中避免的 C++ 特性

| 特性 | 原因 | 替代方案 |
|------|------|---------|
| 异常 `throw` | 栈展开开销大 | 返回错误码 / `std::expected` |
| RTTI `typeid` | 额外内存开销 | `enum` 标识 |
| `std::string` | 动态内存分配 | `char[]` / `string_view` |
| `std::vector` | 动态内存分配 | `std::array` / 静态数组 |
| 虚函数 | 间接调用 + vtable | CRTP 模板 |

---

## 练习题

### 练习 1：模板 GPIO 封装

**要求**：

- 用模板参数封装 GPIO 操作（基址、引脚号）
- 实现 `init_output()`、`set()`、`clear()`、`toggle()` 静态方法
- 模拟测试（不实际操作硬件，用打印代替）
- 体现零开销抽象的思想

??? note "参考答案"

    ```cpp title="exercise01.cpp"
    #include <iostream>
    #include <cstdint>

    // 模拟寄存器（实际嵌入式中是硬件地址）
    uint32_t simulated_moder = 0;
    uint32_t simulated_odr = 0;

    template <uint32_t* ModerReg, uint32_t* OdrReg, uint8_t PinNum>
    class Gpio {
    public:
        static void init_output() {
            uint32_t val = *ModerReg;
            val &= ~(0b11 << (PinNum * 2));
            val |=  (0b01 << (PinNum * 2));
            *ModerReg = val;
            std::cout << "GPIO Pin" << (int)PinNum << " 初始化为输出" << std::endl;
        }

        static void set() {
            *OdrReg |= (1 << PinNum);
            std::cout << "Pin" << (int)PinNum << " = HIGH" << std::endl;
        }

        static void clear() {
            *OdrReg &= ~(1 << PinNum);
            std::cout << "Pin" << (int)PinNum << " = LOW" << std::endl;
        }

        static void toggle() {
            *OdrReg ^= (1 << PinNum);
            bool state = (*OdrReg >> PinNum) & 1;
            std::cout << "Pin" << (int)PinNum << " = " << (state ? "HIGH" : "LOW")
                      << " (toggle)" << std::endl;
        }
    };

    // 类型别名（实际使用时指向硬件地址）
    using LED_Green  = Gpio<&simulated_moder, &simulated_odr, 5>;
    using LED_Red    = Gpio<&simulated_moder, &simulated_odr, 13>;

    int main()
    {
        LED_Green::init_output();
        LED_Red::init_output();

        LED_Green::set();
        LED_Red::clear();
        LED_Green::toggle();
        LED_Green::toggle();

        return 0;
    }
    ```

    **预期输出**：
    ```
    GPIO Pin5 初始化为输出
    GPIO Pin13 初始化为输出
    Pin5 = HIGH
    Pin13 = LOW
    Pin5 = LOW (toggle)
    Pin5 = HIGH (toggle)
    ```

### 练习 2：CRTP + RAII SPI 驱动

**要求**：

- 用 CRTP 实现 `PeripheralBase`（init/deinit）
- 用 RAII `ScopedPeripheral` 自动管理生命周期
- 实现 `SpiDriver`，模拟 SPI 传输

??? note "参考答案"

    ```cpp title="exercise02.cpp"
    #include <iostream>
    #include <cstdint>

    template <typename Derived>
    class PeripheralBase {
    public:
        void init() {
            std::cout << "[初始化] ";
            static_cast<Derived*>(this)->do_init();
        }
        void deinit() {
            std::cout << "[反初始化] ";
            static_cast<Derived*>(this)->do_deinit();
        }
    };

    template <typename T>
    class ScopedPeripheral {
        T &dev_;
    public:
        ScopedPeripheral(T &dev) : dev_(dev) { dev_.init(); }
        ~ScopedPeripheral() { dev_.deinit(); }
        T& get() { return dev_; }
        ScopedPeripheral(const ScopedPeripheral&) = delete;
    };

    class SpiDriver : public PeripheralBase<SpiDriver> {
        friend class PeripheralBase<SpiDriver>;
        void do_init()   { std::cout << "SPI: CPOL=0 CPHA=0 1MHz" << std::endl; }
        void do_deinit() { std::cout << "SPI: 关闭" << std::endl; }
    public:
        uint8_t transfer(uint8_t tx) {
            std::cout << "SPI TX: 0x" << std::hex << (int)tx;
            uint8_t rx = ~tx;  // 模拟接收
            std::cout << " → RX: 0x" << (int)rx << std::dec << std::endl;
            return rx;
        }
    };

    int main()
    {
        SpiDriver spi;
        {
            ScopedPeripheral guard(spi);
            guard.get().transfer(0xAA);
            guard.get().transfer(0x55);
            guard.get().transfer(0x00);
        }  // 自动 deinit

        std::cout << "SPI 已自动关闭" << std::endl;
        return 0;
    }
    ```

    **预期输出**：
    ```
    [初始化] SPI: CPOL=0 CPHA=0 1MHz
    SPI TX: 0xaa → RX: 0x55
    SPI TX: 0x55 → RX: 0xaa
    SPI TX: 0x0 → RX: 0xff
    [反初始化] SPI: 关闭
    SPI 已自动关闭
    ```

---

> **下一课**：[项目实战：网络通信库](../33-project-network/README.md)
