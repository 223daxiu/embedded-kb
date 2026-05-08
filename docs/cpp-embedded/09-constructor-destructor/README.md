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

### 练习 1：DynamicArray 类

**要求**：

- 设计 `DynamicArray` 类，构造时分配指定大小的 `int` 数组
- 析构时释放内存
- 提供 `set(index, value)` 和 `get(index)` 方法
- 提供 `print()` 方法打印所有元素
- 测试创建、赋值、打印、自动释放

??? note "参考答案"

    ```cpp title="exercise01.cpp"
    #include <iostream>

    class DynamicArray {
        int *data;
        int size;
    public:
        DynamicArray(int n) : size(n), data(new int[n]{}) {
            std::cout << "DynamicArray(大小=" << size << ") 构造" << std::endl;
        }

        ~DynamicArray() {
            delete[] data;
            std::cout << "DynamicArray(大小=" << size << ") 析构" << std::endl;
        }

        void set(int index, int value) {
            if (index >= 0 && index < size) {
                data[index] = value;
            }
        }

        int get(int index) const {
            if (index >= 0 && index < size) return data[index];
            return -1;
        }

        void print() const {
            std::cout << "[";
            for (int i = 0; i < size; i++) {
                if (i > 0) std::cout << ", ";
                std::cout << data[i];
            }
            std::cout << "]" << std::endl;
        }
    };

    int main()
    {
        {
            DynamicArray arr(5);
            arr.set(0, 10);
            arr.set(1, 20);
            arr.set(2, 30);
            arr.set(3, 40);
            arr.set(4, 50);
            arr.print();
        }  // 析构自动调用

        std::cout << "程序结束" << std::endl;
        return 0;
    }
    ```

    **预期输出**：
    ```
    DynamicArray(大小=5) 构造
    [10, 20, 30, 40, 50]
    DynamicArray(大小=5) 析构
    程序结束
    ```

### 练习 2：观察嵌套对象构造析构顺序

**要求**：

- 定义 `Engine` 和 `Car` 类，`Car` 包含一个 `Engine` 成员
- 构造和析构中打印提示信息
- 观察嵌套对象的构造/析构顺序

??? note "参考答案"

    ```cpp title="exercise02.cpp"
    #include <iostream>
    #include <string>

    class Engine {
        std::string type;
    public:
        Engine(const std::string &t) : type(t) {
            std::cout << "  Engine(" << type << ") 构造" << std::endl;
        }
        ~Engine() {
            std::cout << "  Engine(" << type << ") 析构" << std::endl;
        }
    };

    class Car {
        std::string brand;
        Engine engine;  // 成员对象
    public:
        Car(const std::string &b, const std::string &e)
            : brand(b), engine(e) {  // engine 先于 Car 构造体构造
            std::cout << "Car(" << brand << ") 构造" << std::endl;
        }
        ~Car() {
            std::cout << "Car(" << brand << ") 析构" << std::endl;
        }
    };

    int main()
    {
        std::cout << "=== 创建 Car ===" << std::endl;
        {
            Car car("宝马", "V8");
        }
        std::cout << "=== Car 已销毁 ===" << std::endl;

        return 0;
    }
    ```

    **预期输出**：
    ```
    === 创建 Car ===
      Engine(V8) 构造
    Car(宝马) 构造
    Car(宝马) 析构
      Engine(V8) 析构
    === Car 已销毁 ===
    ```

    > 规律：成员对象先构造，外层对象后构造；析构顺序相反。

---

> **下一课**：[拷贝控制](../10-copy-control/README.md)
