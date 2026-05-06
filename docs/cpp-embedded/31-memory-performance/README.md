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

### 练习 1

优化一个结构体的内存对齐，对比优化前后的 `sizeof`。

### 练习 2

实现一个固定大小的内存池，用在嵌入式场景中替代 `new/delete`。

---

> **下一课**：[嵌入式 C++](../32-embedded-cpp/README.md)
