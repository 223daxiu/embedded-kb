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

### 练习 1：unique_ptr 资源管理

**要求**：

- 定义 `Sensor` 类（构造/析构打印提示）
- 用 `unique_ptr` 管理 `Sensor` 对象
- 测试 `make_unique`、`std::move` 转移所有权、作用域结束自动释放

??? note "参考答案"

    ```cpp title="exercise01.cpp"
    #include <iostream>
    #include <memory>
    #include <string>

    class Sensor {
        std::string name_;
    public:
        Sensor(const std::string &n) : name_(n) {
            std::cout << "Sensor(" << name_ << ") 创建" << std::endl;
        }
        ~Sensor() {
            std::cout << "Sensor(" << name_ << ") 销毁" << std::endl;
        }
        void read() const { std::cout << name_ << " 读数: 25.6" << std::endl; }
    };

    int main()
    {
        std::cout << "=== 创建 ===" << std::endl;
        auto s1 = std::make_unique<Sensor>("温度");
        s1->read();

        std::cout << "\n=== 转移所有权 ===" << std::endl;
        auto s2 = std::move(s1);
        std::cout << "s1 是否为空: " << (s1 == nullptr ? "是" : "否") << std::endl;
        s2->read();

        std::cout << "\n=== 作用域结束 ===" << std::endl;
        {
            auto s3 = std::make_unique<Sensor>("湿度");
            s3->read();
        }  // s3 自动释放
        std::cout << "s3 已被自动释放" << std::endl;

        std::cout << "\n=== 程序结束 ===" << std::endl;
        return 0;
    }
    ```

    **预期输出**：
    ```
    === 创建 ===
    Sensor(温度) 创建
    温度 读数: 25.6

    === 转移所有权 ===
    s1 是否为空: 是
    温度 读数: 25.6

    === 作用域结束 ===
    Sensor(湿度) 创建
    湿度 读数: 25.6
    Sensor(湿度) 销毁
    s3 已被自动释放

    === 程序结束 ===
    Sensor(温度) 销毁
    ```

### 练习 2：shared_ptr 与 weak_ptr

**要求**：

- 用 `shared_ptr` 共享一个资源，打印引用计数变化
- 制造循环引用场景，然后用 `weak_ptr` 修复

??? note "参考答案"

    ```cpp title="exercise02.cpp"
    #include <iostream>
    #include <memory>

    struct Node {
        std::string name;
        std::shared_ptr<Node> next;      // 改为 weak_ptr 可修复循环引用
        // std::weak_ptr<Node> next;      // ← 修复版本

        Node(const std::string &n) : name(n) {
            std::cout << "Node(" << name << ") 创建" << std::endl;
        }
        ~Node() {
            std::cout << "Node(" << name << ") 销毁" << std::endl;
        }
    };

    int main()
    {
        // 1. 观察引用计数
        std::cout << "=== 引用计数 ===" << std::endl;
        auto p1 = std::make_shared<int>(42);
        std::cout << "创建后 count = " << p1.use_count() << std::endl;
        {
            auto p2 = p1;
            std::cout << "p2=p1 后 count = " << p1.use_count() << std::endl;
            auto p3 = p1;
            std::cout << "p3=p1 后 count = " << p1.use_count() << std::endl;
        }
        std::cout << "p2,p3 销毁后 count = " << p1.use_count() << std::endl;

        // 2. 循环引用（会内存泄漏！）
        std::cout << "\n=== 循环引用演示 ===" << std::endl;
        {
            auto a = std::make_shared<Node>("A");
            auto b = std::make_shared<Node>("B");
            a->next = b;
            b->next = a;  // 循环引用！
            std::cout << "离开作用域..." << std::endl;
        }  // A 和 B 都不会被销毁！
        std::cout << "（注意：A 和 B 没有被销毁 → 内存泄漏）" << std::endl;
        std::cout << "修复方法：将 next 改为 weak_ptr<Node>" << std::endl;

        return 0;
    }
    ```

    **预期输出**：
    ```
    === 引用计数 ===
    创建后 count = 1
    p2=p1 后 count = 2
    p3=p1 后 count = 3
    p2,p3 销毁后 count = 1

    === 循环引用演示 ===
    Node(A) 创建
    Node(B) 创建
    离开作用域...
    （注意：A 和 B 没有被销毁 → 内存泄漏）
    修复方法：将 next 改为 weak_ptr<Node>
    ```

---

> **下一课**：[类型转换](../19-type-cast/README.md)
