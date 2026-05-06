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

### 练习 1

写函数模板 `swap_val`，交换任意类型的两个变量。

### 练习 2

实现类模板 `Pair<T1, T2>`，存储两个不同类型的值。

---

> **下一课**：[模板进阶](../16-template-advanced/README.md)
