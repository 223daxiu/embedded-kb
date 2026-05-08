# 第 20 课：RAII 与资源管理

## RAII 原则

**Resource Acquisition Is Initialization**：资源获取即初始化。

核心思想：**把资源的生命周期绑定到对象的生命周期**。

```cpp
class FileGuard {
    FILE *fp;
public:
    FileGuard(const char *path, const char *mode)
        : fp(fopen(path, mode)) {}
    
    ~FileGuard() {
        if (fp) fclose(fp);  // 自动释放
    }
    
    FILE* get() { return fp; }
    operator bool() const { return fp != nullptr; }
    
    // 禁止拷贝
    FileGuard(const FileGuard&) = delete;
    FileGuard& operator=(const FileGuard&) = delete;
};

void process() {
    FileGuard file("data.txt", "r");
    if (!file) return;
    // ... 使用 file.get() ...
}  // 无论正常返回还是异常，文件都会被关闭
```

---

## 锁 Guard

```cpp
#include <mutex>

std::mutex mtx;

void safe_operation() {
    std::lock_guard<std::mutex> lock(mtx);  // 构造时加锁
    // ... 临界区 ...
}  // 析构时自动解锁

// C++17 更简洁
void safe_operation_17() {
    std::scoped_lock lock(mtx);
    // ...
}
```

---

## 嵌入式 RAII：中断屏蔽

```cpp
class InterruptGuard {
    bool was_enabled;
public:
    InterruptGuard() {
        was_enabled = is_interrupt_enabled();
        disable_interrupts();
    }
    ~InterruptGuard() {
        if (was_enabled) enable_interrupts();
    }
};

void critical_section() {
    InterruptGuard guard;
    // 中断已屏蔽，安全操作共享资源
    shared_counter++;
}  // 自动恢复中断状态
```

---

## ScopeGuard

通用的清理器：

```cpp
template <typename Func>
class ScopeGuard {
    Func cleanup;
    bool active;
public:
    ScopeGuard(Func f) : cleanup(std::move(f)), active(true) {}
    ~ScopeGuard() { if (active) cleanup(); }
    void dismiss() { active = false; }
    
    ScopeGuard(const ScopeGuard&) = delete;
};

// 用法
void process() {
    auto *resource = acquire_resource();
    ScopeGuard guard([&]{ release_resource(resource); });
    
    // ... 使用 resource ...
    // 无论如何都会释放
}
```

---

## 练习题

### 练习 1：TimerGuard 计时器

**要求**：

- 实现 `TimerGuard` 类，构造时记录开始时间
- 析构时自动计算并打印耗时（毫秒）
- 使用 `<chrono>` 库获取时间
- 在一段循环代码中测试

??? note "参考答案"

    ```cpp title="exercise01.cpp"
    #include <iostream>
    #include <chrono>
    #include <string>
    #include <numeric>
    #include <vector>

    class TimerGuard {
        std::string name_;
        std::chrono::high_resolution_clock::time_point start_;
    public:
        TimerGuard(const std::string &name = "代码块")
            : name_(name), start_(std::chrono::high_resolution_clock::now()) {
            std::cout << "[" << name_ << "] 开始计时..." << std::endl;
        }

        ~TimerGuard() {
            auto end = std::chrono::high_resolution_clock::now();
            auto duration = std::chrono::duration_cast<std::chrono::microseconds>(end - start_);
            std::cout << "[" << name_ << "] 耗时: " << duration.count() << " 微秒" << std::endl;
        }

        TimerGuard(const TimerGuard&) = delete;
        TimerGuard& operator=(const TimerGuard&) = delete;
    };

    int main()
    {
        {
            TimerGuard t("累加计算");
            long long sum = 0;
            for (int i = 0; i < 1000000; i++) sum += i;
            std::cout << "sum = " << sum << std::endl;
        }

        {
            TimerGuard t("vector 填充");
            std::vector<int> v(100000);
            std::iota(v.begin(), v.end(), 0);
            std::cout << "vector size = " << v.size() << std::endl;
        }

        return 0;
    }
    ```

    **预期输出**（耗时因机器而异）：
    ```
    [累加计算] 开始计时...
    sum = 499999500000
    [累加计算] 耗时: 2345 微秒
    [vector 填充] 开始计时...
    vector size = 100000
    [vector 填充] 耗时: 567 微秒
    ```

### 练习 2：RAII GPIO 封装

**要求**：

- 实现 `GpioPin` 类，构造时初始化引脚（打印提示）
- 析构时恢复默认状态（打印提示）
- 提供 `set_high()`、`set_low()`、`toggle()` 方法
- 禁止拷贝，测试作用域自动释放

??? note "参考答案"

    ```cpp title="exercise02.cpp"
    #include <iostream>
    #include <string>

    class GpioPin {
        std::string name_;
        bool state_ = false;
    public:
        GpioPin(const std::string &name, const std::string &mode = "OUTPUT")
            : name_(name) {
            std::cout << "GPIO " << name_ << " 初始化为 " << mode << std::endl;
        }

        ~GpioPin() {
            std::cout << "GPIO " << name_ << " 恢复默认状态（INPUT 模式）" << std::endl;
        }

        void set_high() {
            state_ = true;
            std::cout << name_ << " → HIGH" << std::endl;
        }

        void set_low() {
            state_ = false;
            std::cout << name_ << " → LOW" << std::endl;
        }

        void toggle() {
            state_ = !state_;
            std::cout << name_ << " → " << (state_ ? "HIGH" : "LOW") << std::endl;
        }

        GpioPin(const GpioPin&) = delete;
        GpioPin& operator=(const GpioPin&) = delete;
    };

    int main()
    {
        std::cout << "=== 进入作用域 ===" << std::endl;
        {
            GpioPin led("PA5");
            led.set_high();
            led.toggle();
            led.toggle();
            led.set_low();
        }
        std::cout << "=== 离开作用域（自动恢复） ===" << std::endl;

        return 0;
    }
    ```

    **预期输出**：
    ```
    === 进入作用域 ===
    GPIO PA5 初始化为 OUTPUT
    PA5 → HIGH
    PA5 → LOW
    PA5 → HIGH
    PA5 → LOW
    GPIO PA5 恢复默认状态（INPUT 模式）
    === 离开作用域（自动恢复） ===
    ```

---

> **下一课**：[STL 概述与容器](../21-stl-containers/README.md)
