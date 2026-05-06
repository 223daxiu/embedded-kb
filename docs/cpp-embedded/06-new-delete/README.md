# 第 06 课：new/delete 与内存管理

## new 与 delete

```cpp
// 单个对象
int *p = new int(42);       // 分配并初始化
std::cout << *p << std::endl;
delete p;                   // 释放

// 数组
int *arr = new int[10]{0};  // 分配 10 个 int，初始化为 0
arr[0] = 100;
delete[] arr;               // 数组必须用 delete[]
```

## new vs malloc

| 特性 | `new` | `malloc` |
|------|-------|----------|
| 返回类型 | 对应类型指针 | `void*`（需转型） |
| 构造函数 | 自动调用 | 不调用 |
| 析构函数 | `delete` 自动调用 | `free` 不调用 |
| 失败处理 | 抛异常 | 返回 NULL |
| 计算大小 | 自动 | 手动 `sizeof` |

```cpp
class Sensor {
public:
    Sensor() { std::cout << "构造\n"; }
    ~Sensor() { std::cout << "析构\n"; }
};

Sensor *s = new Sensor();   // 输出"构造"
delete s;                   // 输出"析构"

// malloc 不会调用构造函数！
Sensor *s2 = (Sensor*)malloc(sizeof(Sensor));  // 不输出
free(s2);  // 也不调用析构
```

---

## 常见内存问题

```cpp
// 1. 内存泄漏
void leak() {
    int *p = new int(42);
    // 忘记 delete → 泄漏！
}

// 2. 重复释放
int *p = new int(42);
delete p;
delete p;  // ❌ 未定义行为！

// 3. delete vs delete[]
int *arr = new int[10];
delete arr;    // ❌ 应该用 delete[]
delete[] arr;  // ✅
```

!!! tip "后面会学智能指针来解决这些问题"

---

## 练习题

### 练习 1

用 `new` 创建一个动态 `Student` 对象，设置属性后打印并释放。

### 练习 2

用 `new[]` 创建动态数组，输入 n 个数求平均值。

---

> **下一课**：[string 字符串类](../07-string-class/README.md)
