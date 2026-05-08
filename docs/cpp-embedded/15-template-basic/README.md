# 第 15 课：模板基础

## 函数模板

```cpp
template <typename T>
T max_val(T a, T b) {
    return (a > b) ? a : b;
}

std::cout << max_val(3, 7) << std::endl;       // 7 (int)
std::cout << max_val(3.14, 2.71) << std::endl; // 3.14 (double)
std::cout << max_val<std::string>("abc", "xyz") << std::endl;  // xyz
```

### 多类型参数

```cpp
template <typename T, typename U>
auto add(T a, U b) -> decltype(a + b) {  // 尾置返回类型
    return a + b;
}

// C++14 更简洁
template <typename T, typename U>
auto add(T a, U b) { return a + b; }

std::cout << add(1, 2.5) << std::endl;  // 3.5
```

---

## 类模板

```cpp title="stack_template.cpp"
template <typename T, int MaxSize = 100>
class Stack {
    T data[MaxSize];
    int top = -1;
public:
    bool empty() const { return top == -1; }
    bool full() const { return top == MaxSize - 1; }
    
    void push(const T &val) {
        if (!full()) data[++top] = val;
    }
    
    T pop() {
        return data[top--];
    }
    
    const T& peek() const { return data[top]; }
};

Stack<int> int_stack;
Stack<std::string, 50> str_stack;

int_stack.push(42);
str_stack.push("hello");
```

---

## 非类型模板参数

```cpp
template <int N>
class FixedArray {
    int data[N];
public:
    int size() const { return N; }
    int& operator[](int i) { return data[i]; }
};

FixedArray<10> arr;  // 编译期确定大小
```

---

## 练习题

### 练习 1：通用 max 函数模板

**要求**：

- 写函数模板 `my_max(T a, T b)` 返回较大值
- 测试 `int`、`double`、`std::string` 三种类型
- 不使用 `std::max`，自己实现

??? note "参考答案"

    ```cpp title="exercise01.cpp"
    #include <iostream>
    #include <string>

    template <typename T>
    T my_max(T a, T b) {
        return (a > b) ? a : b;
    }

    int main()
    {
        std::cout << "max(3, 7) = " << my_max(3, 7) << std::endl;
        std::cout << "max(3.14, 2.71) = " << my_max(3.14, 2.71) << std::endl;
        std::cout << "max(\"apple\", \"banana\") = "
                  << my_max(std::string("apple"), std::string("banana")) << std::endl;

        return 0;
    }
    ```

    **预期输出**：
    ```
    max(3, 7) = 7
    max(3.14, 2.71) = 3.14
    max("apple", "banana") = banana
    ```

### 练习 2：类模板 Stack

**要求**：

- 实现类模板 `Stack<T>`，用 `std::vector` 内部存储
- 支持 `push`、`pop`、`top`、`empty`、`size` 操作
- 分别用 `int` 和 `string` 实例化测试

??? note "参考答案"

    ```cpp title="exercise02.cpp"
    #include <iostream>
    #include <vector>
    #include <string>
    #include <stdexcept>

    template <typename T>
    class Stack {
        std::vector<T> data_;
    public:
        void push(const T &val) { data_.push_back(val); }

        void pop() {
            if (data_.empty()) throw std::runtime_error("栈为空");
            data_.pop_back();
        }

        const T& top() const {
            if (data_.empty()) throw std::runtime_error("栈为空");
            return data_.back();
        }

        bool empty() const { return data_.empty(); }
        size_t size() const { return data_.size(); }
    };

    int main()
    {
        // int 栈
        Stack<int> si;
        si.push(10);
        si.push(20);
        si.push(30);
        std::cout << "int栈 top = " << si.top() << ", size = " << si.size() << std::endl;
        si.pop();
        std::cout << "pop后 top = " << si.top() << std::endl;

        // string 栈
        Stack<std::string> ss;
        ss.push("Hello");
        ss.push("World");
        std::cout << "\nstring栈 top = " << ss.top() << std::endl;

        return 0;
    }
    ```

    **预期输出**：
    ```
    int栈 top = 30, size = 3
    pop后 top = 20

    string栈 top = World
    ```

---

> **下一课**：[模板进阶](../16-template-advanced/README.md)
