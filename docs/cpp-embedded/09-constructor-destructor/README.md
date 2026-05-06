# 第 09 课：构造函数与析构函数

## 构造函数

```cpp
class Timer {
    int interval;
    bool running;
public:
    // 默认构造函数
    Timer() : interval(1000), running(false) {
        std::cout << "Timer 创建" << std::endl;
    }
    
    // 参数构造函数
    Timer(int ms) : interval(ms), running(false) {}
    
    // 委托构造（C++11）
    Timer(int ms, bool start) : Timer(ms) {
        if (start) running = true;
    }
    
    void info() const {
        std::cout << "间隔: " << interval << "ms, 运行: " 
                  << std::boolalpha << running << std::endl;
    }
};

Timer t1;              // 默认构造
Timer t2(500);         // 参数构造
Timer t3(100, true);   // 委托构造
```

### 初始化列表（推荐）

```cpp
class Point {
    const double x, y;  // const 成员必须用初始化列表
    int &ref;            // 引用成员也必须
public:
    // 初始化列表（在函数体之前执行）
    Point(double x, double y, int &r) : x(x), y(y), ref(r) {}
    
    // ❌ 不能在函数体中赋值 const/引用成员
    // Point(double x, double y) { this->x = x; }  // 编译错误
};
```

---

## 析构函数

对象销毁时自动调用，用于**释放资源**：

```cpp
class FileHandler {
    FILE *fp;
public:
    FileHandler(const char *path) {
        fp = fopen(path, "r");
        std::cout << "文件已打开" << std::endl;
    }
    
    ~FileHandler() {
        if (fp) fclose(fp);
        std::cout << "文件已关闭" << std::endl;
    }
};

{
    FileHandler fh("test.txt");  // 构造：文件已打开
}  // 离开作用域 → 析构：文件已关闭
```

---

## 构造与析构的顺序

```cpp
class A { public: A() { std::cout << "A构造\n"; } ~A() { std::cout << "A析构\n"; } };
class B { public: B() { std::cout << "B构造\n"; } ~B() { std::cout << "B析构\n"; } };

int main() {
    A a;
    B b;
}
// 输出：A构造 → B构造 → B析构 → A析构
// 构造顺序和声明顺序一致，析构顺序相反（栈行为）
```

---

## explicit 关键字

```cpp
class Distance {
    double meters;
public:
    explicit Distance(double m) : meters(m) {}
    // 加 explicit 后：
    // Distance d = 3.14;  // ❌ 禁止隐式转换
    // Distance d(3.14);   // ✅ 显式构造
};
```

---

## 练习题

### 练习 1

设计 `DynamicArray` 类，构造时分配内存，析构时释放。

### 练习 2

观察嵌套对象的构造析构顺序。

---

> **下一课**：[拷贝控制](../10-copy-control/README.md)
