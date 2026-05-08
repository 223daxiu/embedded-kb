# 第 31 课：内存管理与性能优化

## 内存布局

```cpp
struct Bad {   // 24 字节（内存对齐浪费）
    char a;    // 1 + 7 padding
    double b;  // 8
    int c;     // 4 + 4 padding
};

struct Good {  // 16 字节（按大小降序排列）
    double b;  // 8
    int c;     // 4
    char a;    // 1 + 3 padding
};

static_assert(sizeof(Good) < sizeof(Bad));
```

---

## Cache 友好编程

```cpp
// ❌ AoS（Array of Structures）— 缓存不友好
struct Particle {
    float x, y, z;
    float vx, vy, vz;
    float mass;
};
Particle particles[10000];
for (auto &p : particles) p.x += p.vx;  // 每次跳过 28 字节

// ✅ SoA（Structure of Arrays）— 缓存友好
struct Particles {
    float x[10000], y[10000], z[10000];
    float vx[10000], vy[10000], vz[10000];
    float mass[10000];
};
Particles ps;
for (int i = 0; i < 10000; i++) ps.x[i] += ps.vx[i];  // 连续内存访问
```

---

## 内存池

避免频繁 `new/delete`：

```cpp
template <typename T, size_t PoolSize = 1024>
class MemoryPool {
    union Block {
        T obj;
        Block *next;
        Block() {}
        ~Block() {}
    };
    
    Block pool_[PoolSize];
    Block *free_list_ = nullptr;
    
public:
    MemoryPool() {
        for (size_t i = 0; i < PoolSize - 1; i++)
            pool_[i].next = &pool_[i + 1];
        pool_[PoolSize - 1].next = nullptr;
        free_list_ = &pool_[0];
    }
    
    T* allocate() {
        if (!free_list_) return nullptr;
        Block *block = free_list_;
        free_list_ = free_list_->next;
        return &block->obj;
    }
    
    void deallocate(T *ptr) {
        Block *block = reinterpret_cast<Block*>(ptr);
        block->next = free_list_;
        free_list_ = block;
    }
};

// 使用
MemoryPool<int, 100> pool;
int *p = pool.allocate();
*p = 42;
pool.deallocate(p);
```

---

## 对象池

```cpp
template <typename T, size_t N>
class ObjectPool {
    std::array<std::aligned_storage_t<sizeof(T), alignof(T)>, N> storage_;
    std::array<bool, N> used_{};
    
public:
    template <typename... Args>
    T* create(Args&&... args) {
        for (size_t i = 0; i < N; i++) {
            if (!used_[i]) {
                used_[i] = true;
                return new (&storage_[i]) T(std::forward<Args>(args)...);
            }
        }
        return nullptr;
    }
    
    void destroy(T *ptr) {
        ptr->~T();
        size_t idx = reinterpret_cast<char*>(ptr) - reinterpret_cast<char*>(&storage_[0]);
        idx /= sizeof(std::aligned_storage_t<sizeof(T), alignof(T)>);
        used_[idx] = false;
    }
};
```

---

## 避免不必要的拷贝

```cpp
// ❌ 拷贝
std::string get_name() {
    std::string s = "hello";
    return s;  // 实际上 RVO 会优化
}

// ✅ 传引用
void process(const std::vector<int> &data);  // 不拷贝

// ✅ string_view
void print(std::string_view sv);  // 不拷贝

// ✅ 移动
std::vector<int> build() {
    std::vector<int> v(10000);
    return v;  // 移动或 RVO
}
```

---

## 练习题

### 练习 1：结构体内存对齐优化

**要求**：

- 定义一个“坏”的结构体（成员顺序导致内存浪费）
- 定义一个“好”的结构体（按大小降序排列）
- 用 `sizeof` 和 `offsetof` 对比两者的大小和成员偏移

??? note "参考答案"

    ```cpp title="exercise01.cpp"
    #include <iostream>
    #include <cstddef>

    struct BadLayout {
        char  a;    // 1 + 7 padding
        double b;   // 8
        char  c;    // 1 + 3 padding
        int   d;    // 4
    };

    struct GoodLayout {
        double b;   // 8
        int    d;   // 4
        char   a;   // 1
        char   c;   // 1 + 2 padding
    };

    int main()
    {
        std::cout << "=== BadLayout ===" << std::endl;
        std::cout << "sizeof = " << sizeof(BadLayout) << " 字节" << std::endl;
        std::cout << "  a 偏移: " << offsetof(BadLayout, a) << std::endl;
        std::cout << "  b 偏移: " << offsetof(BadLayout, b) << std::endl;
        std::cout << "  c 偏移: " << offsetof(BadLayout, c) << std::endl;
        std::cout << "  d 偏移: " << offsetof(BadLayout, d) << std::endl;

        std::cout << "\n=== GoodLayout ===" << std::endl;
        std::cout << "sizeof = " << sizeof(GoodLayout) << " 字节" << std::endl;
        std::cout << "  b 偏移: " << offsetof(GoodLayout, b) << std::endl;
        std::cout << "  d 偏移: " << offsetof(GoodLayout, d) << std::endl;
        std::cout << "  a 偏移: " << offsetof(GoodLayout, a) << std::endl;
        std::cout << "  c 偏移: " << offsetof(GoodLayout, c) << std::endl;

        std::cout << "\n节省: " << sizeof(BadLayout) - sizeof(GoodLayout) << " 字节" << std::endl;

        return 0;
    }
    ```

    **预期输出**（典型 64 位系统）：
    ```
    === BadLayout ===
    sizeof = 24 字节
      a 偏移: 0
      b 偏移: 8
      c 偏移: 16
      d 偏移: 20

    === GoodLayout ===
    sizeof = 16 字节
      b 偏移: 0
      d 偏移: 8
      a 偏移: 12
      c 偏移: 13

    节省: 8 字节
    ```

### 练习 2：简易内存池

**要求**：

- 实现固定大小的 `FixedPool<T, N>` 内存池
- 支持 `allocate()` 和 `deallocate()` 操作
- 测试分配、释放、重新分配的流程

??? note "参考答案"

    ```cpp title="exercise02.cpp"
    #include <iostream>
    #include <array>

    template <typename T, size_t N>
    class FixedPool {
        struct Block {
            alignas(T) char data[sizeof(T)];
            bool used = false;
        };
        std::array<Block, N> pool_;

    public:
        T* allocate() {
            for (auto &block : pool_) {
                if (!block.used) {
                    block.used = true;
                    return reinterpret_cast<T*>(block.data);
                }
            }
            return nullptr;  // 池已满
        }

        void deallocate(T *ptr) {
            for (auto &block : pool_) {
                if (reinterpret_cast<T*>(block.data) == ptr) {
                    block.used = false;
                    return;
                }
            }
        }

        size_t used_count() const {
            size_t count = 0;
            for (const auto &b : pool_) if (b.used) count++;
            return count;
        }
    };

    int main()
    {
        FixedPool<int, 5> pool;

        // 分配
        int *a = pool.allocate(); *a = 10;
        int *b = pool.allocate(); *b = 20;
        int *c = pool.allocate(); *c = 30;
        std::cout << "分配 3 个，已用: " << pool.used_count() << "/5" << std::endl;
        std::cout << "*a=" << *a << " *b=" << *b << " *c=" << *c << std::endl;

        // 释放
        pool.deallocate(b);
        std::cout << "\n释放 b 后，已用: " << pool.used_count() << "/5" << std::endl;

        // 重新分配（复用 b 的位置）
        int *d = pool.allocate(); *d = 40;
        std::cout << "重新分配 d，已用: " << pool.used_count() << "/5" << std::endl;
        std::cout << "*d=" << *d << std::endl;

        return 0;
    }
    ```

    **预期输出**：
    ```
    分配 3 个，已用: 3/5
    *a=10 *b=20 *c=30

    释放 b 后，已用: 2/5
    重新分配 d，已用: 3/5
    *d=40
    ```

---

> **下一课**：[嵌入式 C++](../32-embedded-cpp/README.md)
