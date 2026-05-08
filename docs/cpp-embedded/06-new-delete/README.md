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

### 练习 1：动态对象

**要求**：

- 定义 `Student` 类，包含 `name`、`age`、`score`
- 提供构造函数和 `print()` 方法
- 用 `new` 在堆上创建对象，设置属性并打印
- 用 `delete` 释放，观察构造/析构顺序

??? note "参考答案"

    ```cpp title="exercise01.cpp"
    #include <iostream>
    #include <string>

    class Student {
    public:
        std::string name;
        int age;
        double score;

        Student(const std::string &n, int a, double s)
            : name(n), age(a), score(s) {
            std::cout << "构造 Student: " << name << std::endl;
        }

        ~Student() {
            std::cout << "析构 Student: " << name << std::endl;
        }

        void print() const {
            std::cout << name << " | 年龄: " << age
                      << " | 成绩: " << score << std::endl;
        }
    };

    int main()
    {
        std::cout << "=== 创建对象 ===" << std::endl;
        Student *s = new Student("张三", 20, 95.5);
        s->print();

        std::cout << "\n=== 释放对象 ===" << std::endl;
        delete s;

        return 0;
    }
    ```

    **预期输出**：
    ```
    === 创建对象 ===
    构造 Student: 张三
    张三 | 年龄: 20 | 成绩: 95.5

    === 释放对象 ===
    析构 Student: 张三
    ```

### 练习 2：动态数组求平均值

**要求**：

- 用户输入数组长度 `n`
- 用 `new int[n]` 动态分配数组
- 用户输入 n 个数
- 计算并打印平均值
- 用 `delete[]` 释放数组

??? note "参考答案"

    ```cpp title="exercise02.cpp"
    #include <iostream>

    int main()
    {
        int n;
        std::cout << "请输入数组长度: ";
        std::cin >> n;

        if (n <= 0) {
            std::cout << "无效长度" << std::endl;
            return 1;
        }

        // 动态分配
        int *arr = new int[n];

        std::cout << "请输入 " << n << " 个整数: ";
        for (int i = 0; i < n; i++) {
            std::cin >> arr[i];
        }

        // 计算平均值
        double sum = 0;
        for (int i = 0; i < n; i++) {
            sum += arr[i];
        }
        double avg = sum / n;

        std::cout << "平均值: " << avg << std::endl;

        // 释放内存
        delete[] arr;

        return 0;
    }
    ```

    **运行示例**：
    ```
    请输入数组长度: 5
    请输入 5 个整数: 10 20 30 40 50
    平均值: 30
    ```

---

> **下一课**：[string 字符串类](../07-string-class/README.md)
