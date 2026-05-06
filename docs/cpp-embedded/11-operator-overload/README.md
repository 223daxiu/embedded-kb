# 第 11 课：运算符重载

## 基本语法

```cpp
class Vector2D {
public:
    double x, y;
    Vector2D(double x = 0, double y = 0) : x(x), y(y) {}
    
    // + 运算符
    Vector2D operator+(const Vector2D &other) const {
        return Vector2D(x + other.x, y + other.y);
    }
    
    // - 运算符
    Vector2D operator-(const Vector2D &other) const {
        return {x - other.x, y - other.y};
    }
    
    // == 比较
    bool operator==(const Vector2D &other) const {
        return x == other.x && y == other.y;
    }
    
    // * 标量乘法
    Vector2D operator*(double scalar) const {
        return {x * scalar, y * scalar};
    }
};

Vector2D a(1, 2), b(3, 4);
Vector2D c = a + b;   // (4, 6)
Vector2D d = a * 2.0; // (2, 4)
```

---

## << 输出运算符（友元函数）

```cpp
class Vector2D {
    // ... 同上 ...
    
    // 友元：允许访问私有成员
    friend std::ostream& operator<<(std::ostream &os, const Vector2D &v);
};

std::ostream& operator<<(std::ostream &os, const Vector2D &v) {
    os << "(" << v.x << ", " << v.y << ")";
    return os;
}

Vector2D v(3, 4);
std::cout << v << std::endl;  // (3, 4)
```

---

## [] 下标运算符

```cpp
class Array {
    int *data;
    int size;
public:
    Array(int n) : size(n), data(new int[n]{}) {}
    ~Array() { delete[] data; }
    
    int& operator[](int index) {
        return data[index];
    }
    
    const int& operator[](int index) const {
        return data[index];
    }
};

Array arr(5);
arr[0] = 42;
std::cout << arr[0] << std::endl;
```

---

## () 函数调用运算符（仿函数）

```cpp
class Multiplier {
    int factor;
public:
    Multiplier(int f) : factor(f) {}
    
    int operator()(int x) const {
        return x * factor;
    }
};

Multiplier triple(3);
std::cout << triple(10) << std::endl;  // 30
std::cout << triple(7) << std::endl;   // 21
```

---

## ++ 前缀/后缀

```cpp
class Counter {
    int count;
public:
    Counter(int c = 0) : count(c) {}
    
    Counter& operator++() {       // 前缀 ++c
        count++;
        return *this;
    }
    
    Counter operator++(int) {     // 后缀 c++（int 是占位符）
        Counter old = *this;
        count++;
        return old;
    }
    
    int get() const { return count; }
};
```

---

## 不能重载的运算符

| 运算符 | 说明 |
|--------|------|
| `::` | 作用域解析 |
| `.` | 成员访问 |
| `.*` | 成员指针访问 |
| `?:` | 三目运算符 |
| `sizeof` | 大小 |

---

## 练习题

### 练习 1

为 `Matrix2x2` 类重载 `+`、`*`、`<<` 运算符。

### 练习 2

实现一个 `String` 类，重载 `+`（拼接）、`[]`（下标）、`==`（比较）。

---

> **下一课**：[继承](../12-inheritance/README.md)
