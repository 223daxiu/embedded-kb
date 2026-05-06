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

### 练习 1

实现一个 `TimerGuard` 类，构造时记录开始时间，析构时打印耗时。

### 练习 2

用 RAII 封装一个 GPIO 引脚：构造时初始化，析构时恢复默认状态。

---

> **下一课**：[STL 概述与容器](../21-stl-containers/README.md)
