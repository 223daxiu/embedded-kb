# 第 25 课：现代 C++（11/14）

## C++11 核心特性

### auto 与 decltype

```cpp
auto x = 42;               // int
auto v = std::vector<int>{1,2,3};  // std::vector<int>

decltype(x) y = 100;       // 和 x 同类型：int
decltype(auto) z = x;      // C++14
```

### 范围 for

```cpp
std::vector<int> v = {1, 2, 3, 4, 5};

for (int x : v) std::cout << x << " ";      // 值拷贝
for (int &x : v) x *= 2;                    // 引用修改
for (const auto &x : v) std::cout << x;     // const 引用（推荐）
```

### nullptr

```cpp
int *p = nullptr;   // 替代 NULL / 0
void f(int);
void f(int*);
f(nullptr);  // 调用 f(int*)，不会歧义
```

### 初始化列表

```cpp
std::vector<int> v = {1, 2, 3, 4, 5};
std::map<std::string, int> m = {{"a", 1}, {"b", 2}};

class Point {
public:
    Point(std::initializer_list<double> il) {
        auto it = il.begin();
        x = *it++;
        y = *it;
    }
private:
    double x, y;
};
```

### 移动语义

```cpp
std::string a = "hello";
std::string b = std::move(a);  // 移动而非拷贝
// a 现在是空的（已被"搬走"）
```

### constexpr

```cpp
constexpr int square(int x) { return x * x; }
constexpr int result = square(5);  // 编译期计算 = 25
static_assert(square(3) == 9);     // 编译期断言
```

### enum class（强类型枚举）

```cpp
enum class Color { Red, Green, Blue };
Color c = Color::Red;
// int n = c;  // ❌ 不能隐式转为 int
int n = static_cast<int>(c);  // 显式转换
```

### using 类型别名

```cpp
using IntVec = std::vector<int>;           // 替代 typedef
using Callback = std::function<void(int)>;

template <typename T>
using Vec = std::vector<T>;  // 模板别名（typedef 做不到）
```

---

## C++14 新特性

### 泛型 Lambda

```cpp
auto add = [](auto a, auto b) { return a + b; };
```

### 返回类型推导

```cpp
auto factorial(int n) -> int {  // C++11 尾置返回
    return n <= 1 ? 1 : n * factorial(n - 1);
}

auto factorial(int n) {  // C++14 自动推导
    if (n <= 1) return 1;
    return n * factorial(n - 1);
}
```

### make_unique

```cpp
auto p = std::make_unique<int>(42);  // C++14 终于有了！
```

### 二进制字面量与数字分隔符

```cpp
int mask = 0b1111'0000;     // 二进制
int million = 1'000'000;     // 数字分隔符
```

---

## 练习题

### 练习 1：现代 C++ 风格重写

**要求**：

- 用 `auto`、范围 for、`initializer_list`、`enum class` 等 C++11 特性
- 实现一个小程序：管理一组学生成绩，按等级分类（A/B/C/D）
- 使用 `constexpr` 定义分数线

??? note "参考答案"

    ```cpp title="exercise01.cpp"
    #include <iostream>
    #include <vector>
    #include <string>

    enum class Grade { A, B, C, D };

    constexpr int GRADE_A = 90;
    constexpr int GRADE_B = 80;
    constexpr int GRADE_C = 60;

    Grade get_grade(int score) {
        if (score >= GRADE_A) return Grade::A;
        if (score >= GRADE_B) return Grade::B;
        if (score >= GRADE_C) return Grade::C;
        return Grade::D;
    }

    std::string grade_str(Grade g) {
        switch (g) {
            case Grade::A: return "优秀(A)";
            case Grade::B: return "良好(B)";
            case Grade::C: return "及格(C)";
            case Grade::D: return "不及格(D)";
        }
        return "未知";
    }

    int main()
    {
        // 初始化列表
        std::vector<std::pair<std::string, int>> students = {
            {"张三", 95}, {"李四", 82}, {"王五", 67},
            {"赵六", 55}, {"孙七", 91}
        };

        // 范围 for + auto + 结构化绑定
        for (const auto &[name, score] : students) {
            auto g = get_grade(score);
            std::cout << name << ": " << score << " 分 → " << grade_str(g) << std::endl;
        }

        return 0;
    }
    ```

    **预期输出**：
    ```
    张三: 95 分 → 优秀(A)
    李四: 82 分 → 良好(B)
    王五: 67 分 → 及格(C)
    赵六: 55 分 → 不及格(D)
    孙七: 91 分 → 优秀(A)
    ```

### 练习 2：enum class 状态机

**要求**：

- 用 `enum class` 定义状态（Idle、Running、Paused、Stopped）
- 实现状态转换函数，用 `switch` 处理事件
- 打印每次状态变化

??? note "参考答案"

    ```cpp title="exercise02.cpp"
    #include <iostream>
    #include <string>

    enum class State { Idle, Running, Paused, Stopped };
    enum class Event { Start, Pause, Resume, Stop, Reset };

    std::string state_name(State s) {
        switch (s) {
            case State::Idle:    return "Idle";
            case State::Running: return "Running";
            case State::Paused:  return "Paused";
            case State::Stopped: return "Stopped";
        }
        return "Unknown";
    }

    std::string event_name(Event e) {
        switch (e) {
            case Event::Start:  return "Start";
            case Event::Pause:  return "Pause";
            case Event::Resume: return "Resume";
            case Event::Stop:   return "Stop";
            case Event::Reset:  return "Reset";
        }
        return "Unknown";
    }

    State handle_event(State current, Event event) {
        State next = current;
        switch (current) {
            case State::Idle:
                if (event == Event::Start) next = State::Running;
                break;
            case State::Running:
                if (event == Event::Pause) next = State::Paused;
                if (event == Event::Stop)  next = State::Stopped;
                break;
            case State::Paused:
                if (event == Event::Resume) next = State::Running;
                if (event == Event::Stop)   next = State::Stopped;
                break;
            case State::Stopped:
                if (event == Event::Reset) next = State::Idle;
                break;
        }

        std::cout << state_name(current) << " --[" << event_name(event) << "]--> "
                  << state_name(next);
        if (next == current) std::cout << " (无效事件)";
        std::cout << std::endl;

        return next;
    }

    int main()
    {
        State s = State::Idle;
        s = handle_event(s, Event::Start);
        s = handle_event(s, Event::Pause);
        s = handle_event(s, Event::Start);   // 无效
        s = handle_event(s, Event::Resume);
        s = handle_event(s, Event::Stop);
        s = handle_event(s, Event::Reset);

        return 0;
    }
    ```

    **预期输出**：
    ```
    Idle --[Start]--> Running
    Running --[Pause]--> Paused
    Paused --[Start]--> Paused (无效事件)
    Paused --[Resume]--> Running
    Running --[Stop]--> Stopped
    Stopped --[Reset]--> Idle
    ```

---

> **下一课**：[现代 C++（17/20）](../26-modern-cpp-17-20/README.md)
