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

### 练习 1

用模板实现一个零开销的 GPIO 封装。

### 练习 2

用 CRTP + RAII 实现一个嵌入式 SPI 驱动。

---

> **下一课**：[项目实战：网络通信库](../33-project-network/README.md)
