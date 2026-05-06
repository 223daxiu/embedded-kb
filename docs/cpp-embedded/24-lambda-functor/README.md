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

### 练习 1

用 Lambda 和 `std::sort` 对学生结构体按多个字段排序（先按成绩降序，成绩相同按姓名升序）。

### 练习 2

实现一个简易的事件系统：用 `std::map<string, std::function<void()>>` 注册和触发事件。

---

> **下一课**：[现代 C++（11/14）](../25-modern-cpp-11-14/README.md)
