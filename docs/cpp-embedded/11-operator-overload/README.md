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

### 练习 1：2x2 矩阵类

**要求**：

- 设计 `Matrix2x2` 类，内部用 `double data[2][2]` 存储
- 重载 `+`（矩阵加法）、`*`（矩阵乘法）、`<<`（输出）
- 测试矩阵运算并打印结果

??? note "参考答案"

    ```cpp title="exercise01.cpp"
    #include <iostream>

    class Matrix2x2 {
        double data[2][2];
    public:
        Matrix2x2(double a=0, double b=0, double c=0, double d=0) {
            data[0][0]=a; data[0][1]=b;
            data[1][0]=c; data[1][1]=d;
        }

        Matrix2x2 operator+(const Matrix2x2 &other) const {
            return Matrix2x2(
                data[0][0]+other.data[0][0], data[0][1]+other.data[0][1],
                data[1][0]+other.data[1][0], data[1][1]+other.data[1][1]
            );
        }

        Matrix2x2 operator*(const Matrix2x2 &other) const {
            return Matrix2x2(
                data[0][0]*other.data[0][0] + data[0][1]*other.data[1][0],
                data[0][0]*other.data[0][1] + data[0][1]*other.data[1][1],
                data[1][0]*other.data[0][0] + data[1][1]*other.data[1][0],
                data[1][0]*other.data[0][1] + data[1][1]*other.data[1][1]
            );
        }

        friend std::ostream& operator<<(std::ostream &os, const Matrix2x2 &m) {
            os << "|" << m.data[0][0] << " " << m.data[0][1] << "|" << std::endl
               << "|" << m.data[1][0] << " " << m.data[1][1] << "|";
            return os;
        }
    };

    int main()
    {
        Matrix2x2 a(1, 2, 3, 4);
        Matrix2x2 b(5, 6, 7, 8);

        std::cout << "A =" << std::endl << a << std::endl;
        std::cout << "B =" << std::endl << b << std::endl;
        std::cout << "A + B =" << std::endl << (a + b) << std::endl;
        std::cout << "A * B =" << std::endl << (a * b) << std::endl;

        return 0;
    }
    ```

    **预期输出**：
    ```
    A =
    |1 2|
    |3 4|
    B =
    |5 6|
    |7 8|
    A + B =
    |6 8|
    |10 12|
    A * B =
    |19 22|
    |43 50|
    ```

### 练习 2：String 类运算符重载

**要求**：

- 在第10课的 `MyString` 基础上，重载：
  - `+`（字符串拼接）
  - `[]`（下标访问）
  - `==`（字符串比较）
  - `<<`（输出）

??? note "参考答案"

    ```cpp title="exercise02.cpp"
    #include <iostream>
    #include <cstring>

    class MyString {
        char *data_;
        size_t len_;
    public:
        MyString(const char *s = "") : len_(strlen(s)), data_(new char[strlen(s)+1]) {
            strcpy(data_, s);
        }
        ~MyString() { delete[] data_; }
        MyString(const MyString &o) : len_(o.len_), data_(new char[o.len_+1]) {
            strcpy(data_, o.data_);
        }
        MyString& operator=(const MyString &o) {
            if (this != &o) {
                delete[] data_;
                len_ = o.len_;
                data_ = new char[len_+1];
                strcpy(data_, o.data_);
            }
            return *this;
        }

        // + 拼接
        MyString operator+(const MyString &other) const {
            char *buf = new char[len_ + other.len_ + 1];
            strcpy(buf, data_);
            strcat(buf, other.data_);
            MyString result(buf);
            delete[] buf;
            return result;
        }

        // [] 下标
        char& operator[](size_t i) { return data_[i]; }
        const char& operator[](size_t i) const { return data_[i]; }

        // == 比较
        bool operator==(const MyString &other) const {
            return strcmp(data_, other.data_) == 0;
        }

        // << 输出
        friend std::ostream& operator<<(std::ostream &os, const MyString &s) {
            os << s.data_;
            return os;
        }
    };

    int main()
    {
        MyString a("Hello");
        MyString b(" World");
        MyString c = a + b;

        std::cout << "a = " << a << std::endl;
        std::cout << "b = " << b << std::endl;
        std::cout << "a + b = " << c << std::endl;
        std::cout << "c[0] = " << c[0] << std::endl;
        std::cout << "a == \"Hello\"? " << (a == MyString("Hello") ? "是" : "否") << std::endl;
        std::cout << "a == b? " << (a == b ? "是" : "否") << std::endl;

        return 0;
    }
    ```

    **预期输出**：
    ```
    a = Hello
    b =  World
    a + b = Hello World
    c[0] = H
    a == "Hello"? 是
    a == b? 否
    ```

---

> **下一课**：[继承](../12-inheritance/README.md)
