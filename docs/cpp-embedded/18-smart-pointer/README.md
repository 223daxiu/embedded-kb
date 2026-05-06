# 第 18 课：智能指针

## 为什么需要智能指针？

```cpp
void bad_function() {
    int *p = new int(42);
    // ... 如果这里抛异常 ...
    delete p;  // 永远执行不到 → 内存泄漏！
}
```

智能指针利用 **RAII** 自动管理内存：离开作用域自动 `delete`。

---

## unique_ptr（独占所有权）

```cpp
#include <memory>

// 创建
auto p = std::make_unique<int>(42);         // C++14 推荐
std::unique_ptr<int> p2(new int(100));      // 也可以

// 使用
std::cout << *p << std::endl;   // 42

// 不能拷贝，只能移动
// auto p3 = p;                 // ❌ 编译错误
auto p3 = std::move(p);         // ✅ p 变为空

// 数组
auto arr = std::make_unique<int[]>(10);
arr[0] = 42;

// 自定义删除器
auto fp = std::unique_ptr<FILE, decltype(&fclose)>(
    fopen("test.txt", "r"), fclose
);
```

---

## shared_ptr（共享所有权）

```cpp
auto sp1 = std::make_shared<int>(42);
auto sp2 = sp1;  // 引用计数 +1

std::cout << sp1.use_count() << std::endl;  // 2

sp2.reset();  // 引用计数 -1
std::cout << sp1.use_count() << std::endl;  // 1

// sp1 离开作用域时引用计数归 0，自动 delete
```

---

## weak_ptr（解决循环引用）

```cpp
struct Node {
    std::shared_ptr<Node> next;
    std::weak_ptr<Node> prev;  // 用 weak_ptr 打破循环！
    int data;
    ~Node() { std::cout << "Node " << data << " 析构\n"; }
};

auto a = std::make_shared<Node>();
auto b = std::make_shared<Node>();
a->data = 1; b->data = 2;
a->next = b;
b->prev = a;  // weak_ptr 不增加引用计数
```

### 使用 weak_ptr

```cpp
std::weak_ptr<int> wp;
{
    auto sp = std::make_shared<int>(42);
    wp = sp;
    
    if (auto locked = wp.lock()) {  // 尝试获取 shared_ptr
        std::cout << *locked << std::endl;  // 42
    }
}
// sp 已销毁
if (wp.expired()) {
    std::cout << "对象已销毁" << std::endl;
}
```

---

## 智能指针对比

| 特性 | `unique_ptr` | `shared_ptr` | `weak_ptr` |
|------|-------------|-------------|-----------|
| 所有权 | 独占 | 共享 | 无 |
| 拷贝 | ❌ | ✅ | ✅ |
| 移动 | ✅ | ✅ | ✅ |
| 开销 | 零 | 引用计数 | 极小 |
| 用途 | 默认选择 | 共享资源 | 打破循环 |

!!! tip "选择指南"
    1. 优先用 `unique_ptr`
    2. 需要共享时用 `shared_ptr`
    3. 需要观察但不拥有时用 `weak_ptr`
    4. **永远用 `make_unique` / `make_shared` 创建**

---

## 练习题

### 练习 1

用 `unique_ptr` 管理动态数组，实现安全的资源管理。

### 练习 2

构造一个循环引用场景，演示 `shared_ptr` 导致的泄漏，再用 `weak_ptr` 修复。

---

> **下一课**：[类型转换](../19-type-cast/README.md)
