# 第 24 课：Lambda 与函数对象

## Lambda 表达式

```cpp
// 基本语法：[捕获列表](参数) -> 返回类型 { 函数体 }
auto add = [](int a, int b) -> int { return a + b; };
std::cout << add(3, 5) << std::endl;  // 8

// 返回类型可自动推导
auto square = [](int x) { return x * x; };
```

---

## 捕获方式

```cpp
int x = 10, y = 20;

// 值捕获（拷贝）
auto f1 = [x]() { return x; };

// 引用捕获
auto f2 = [&x]() { x++; };

// 全部值捕获
auto f3 = [=]() { return x + y; };

// 全部引用捕获
auto f4 = [&]() { x++; y++; };

// 混合
auto f5 = [=, &x]() { x = y; };  // x 引用，其余值捕获

// mutable（允许修改值捕获的副本）
auto f6 = [x]() mutable { x++; return x; };
```

---

## 与 STL 配合

```cpp
std::vector<int> v = {5, 2, 8, 1, 9};

// 自定义排序
std::sort(v.begin(), v.end(), [](int a, int b) { return a > b; });

// 过滤
std::vector<int> evens;
std::copy_if(v.begin(), v.end(), std::back_inserter(evens),
             [](int x) { return x % 2 == 0; });

// 变换
std::transform(v.begin(), v.end(), v.begin(),
               [](int x) { return x * 2; });

// 遍历
std::for_each(v.begin(), v.end(), [](int x) { std::cout << x << " "; });
```

---

## std::function

通用函数包装器，可以存储 Lambda、函数指针、仿函数：

```cpp
#include <functional>

// 存储 Lambda
std::function<int(int, int)> op;

op = [](int a, int b) { return a + b; };
std::cout << op(3, 5) << std::endl;  // 8

op = [](int a, int b) { return a * b; };
std::cout << op(3, 5) << std::endl;  // 15

// 回调
void do_work(std::function<void(int)> callback) {
    for (int i = 0; i < 5; i++) callback(i);
}
do_work([](int n) { std::cout << n << " "; });
```

---

## 泛型 Lambda (C++14)

```cpp
auto print = [](auto x) { std::cout << x << std::endl; };
print(42);        // int
print(3.14);      // double
print("hello");   // const char*
```

---

## 练习题

### 练习 1：多字段排序

**要求**：

- 定义 `Student` 结构体（姓名、成绩）
- 用 Lambda 和 `std::sort` 排序：先按成绩降序，成绩相同按姓名升序
- 打印排序前后的列表

??? note "参考答案"

    ```cpp title="exercise01.cpp"
    #include <iostream>
    #include <vector>
    #include <algorithm>
    #include <string>
    #include <iomanip>

    struct Student {
        std::string name;
        int score;
    };

    int main()
    {
        std::vector<Student> students = {
            {"张三", 85}, {"李四", 92}, {"王五", 85},
            {"赵六", 78}, {"孙七", 92}, {"周八", 85}
        };

        // 打印原始列表
        std::cout << "排序前:" << std::endl;
        for (const auto &s : students)
            std::cout << "  " << std::left << std::setw(6) << s.name << s.score << std::endl;

        // 多字段排序
        std::sort(students.begin(), students.end(),
            [](const Student &a, const Student &b) {
                if (a.score != b.score) return a.score > b.score;  // 成绩降序
                return a.name < b.name;  // 姓名升序
            });

        std::cout << "\n排序后（成绩降序，同分按姓名升序）:" << std::endl;
        for (const auto &s : students)
            std::cout << "  " << std::left << std::setw(6) << s.name << s.score << std::endl;

        return 0;
    }
    ```

    **预期输出**：
    ```
    排序前:
      张三  85
      李四  92
      王五  85
      赵六  78
      孙七  92
      周八  85

    排序后（成绩降序，同分按姓名升序）:
      孙七  92
      李四  92
      张三  85
      王五  85
      周八  85
      赵六  78
    ```

### 练习 2：简易事件系统

**要求**：

- 用 `std::map<string, vector<function<void(int)>>>` 实现事件总线
- 支持 `on(事件名, 回调)` 注册和 `emit(事件名, 数据)` 触发
- 测试多个事件和多个监听器

??? note "参考答案"

    ```cpp title="exercise02.cpp"
    #include <iostream>
    #include <map>
    #include <vector>
    #include <functional>
    #include <string>

    class EventBus {
        std::map<std::string, std::vector<std::function<void(int)>>> listeners_;
    public:
        void on(const std::string &event, std::function<void(int)> callback) {
            listeners_[event].push_back(std::move(callback));
        }

        void emit(const std::string &event, int data) {
            std::cout << "[触发事件: " << event << "(" << data << ")]" << std::endl;
            if (listeners_.count(event)) {
                for (auto &cb : listeners_[event]) cb(data);
            }
        }
    };

    int main()
    {
        EventBus bus;

        // 注册监听器
        bus.on("温度变化", [](int temp) {
            std::cout << "  显示屏: 当前温度 " << temp << "°C" << std::endl;
        });
        bus.on("温度变化", [](int temp) {
            if (temp > 30) std::cout << "  风扇: 启动降温!" << std::endl;
            else std::cout << "  风扇: 待机" << std::endl;
        });
        bus.on("按键按下", [](int key) {
            std::cout << "  处理器: 按键 " << key << " 被按下" << std::endl;
        });

        // 触发事件
        bus.emit("温度变化", 25);
        std::cout << std::endl;
        bus.emit("温度变化", 35);
        std::cout << std::endl;
        bus.emit("按键按下", 1);

        return 0;
    }
    ```

    **预期输出**：
    ```
    [触发事件: 温度变化(25)]
      显示屏: 当前温度 25°C
      风扇: 待机

    [触发事件: 温度变化(35)]
      显示屏: 当前温度 35°C
      风扇: 启动降温!

    [触发事件: 按键按下(1)]
      处理器: 按键 1 被按下
    ```

---

> **下一课**：[现代 C++（11/14）](../25-modern-cpp-11-14/README.md)
