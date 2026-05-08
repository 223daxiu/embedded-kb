# 第 03 课：引用与 const

## 引用 (Reference)

引用是变量的**别名**，不占额外内存：

```cpp
int a = 10;
int &ref = a;    // ref 是 a 的别名

ref = 20;
std::cout << a << std::endl;   // 20（a 也变了）
std::cout << &a << " " << &ref << std::endl;  // 地址相同
```

### 引用的规则

```cpp
int &ref = a;    // ✅ 必须初始化
// int &ref;     // ❌ 不能不初始化
// int &ref = 10; // ❌ 不能绑定字面量
ref = b;         // 这是赋值，不是改变绑定！ref 仍然是 a 的别名
```

### 引用作函数参数（传引用）

```cpp
// C 语言用指针实现
void swap_c(int *a, int *b) {
    int t = *a; *a = *b; *b = t;
}

// C++ 用引用实现（更简洁）
void swap_cpp(int &a, int &b) {
    int t = a; a = b; b = t;
}

int main()
{
    int x = 1, y = 2;
    swap_cpp(x, y);  // 不需要取地址
    // x=2, y=1
}
```

---

## const

### const 变量

```cpp
const int MAX = 100;     // 编译期常量
// MAX = 200;            // ❌ 不能修改

constexpr int SIZE = 50; // C++11，保证编译期计算
```

### const 引用

```cpp
int a = 10;
const int &cref = a;   // 可以读，不能通过 cref 修改
// cref = 20;           // ❌

const int &rlit = 42;   // const 引用可以绑定字面量！
const int &rexpr = a + 1; // 也可以绑定临时表达式
```

### const 与指针

```cpp
const int *p1;        // 指向常量的指针（值不可改）
int *const p2 = &a;   // 常量指针（指向不可改）
const int *const p3 = &a;  // 都不可改
```

### const 修饰函数参数

```cpp
// 传 const 引用：高效 + 安全（不会复制，也不会修改）
void print(const std::string &s) {
    std::cout << s << std::endl;
    // s = "xxx";  // ❌ 编译错误
}
```

!!! tip "C++ 最佳实践"
    - 小对象（int, double）直接传值
    - 大对象（string, vector, 自定义类）传 `const &`
    - 需要修改的参数传 `&`

---

## 引用 vs 指针

| 特性 | 引用 | 指针 |
|------|------|------|
| 语法 | `int &r = a` | `int *p = &a` |
| 是否可为空 | 不可以 | 可以（nullptr） |
| 是否可重新绑定 | 不可以 | 可以 |
| 是否占内存 | 不占（别名） | 占（存地址） |
| 解引用 | 自动 | 需要 `*p` |

---

## 练习题

### 练习 1：引用传参

**要求**：

- 写函数 `void increment(int &n)`，让传入的值加 1
- 写函数 `void swap(int &a, int &b)`，交换两个变量的值
- 在 `main` 中调用并打印调用前后的值，验证修改生效

??? note "参考答案"

    ```cpp title="exercise01.cpp"
    #include <iostream>

    void increment(int &n) {
        n++;
    }

    void swap(int &a, int &b) {
        int temp = a;
        a = b;
        b = temp;
    }

    int main()
    {
        int x = 10;
        std::cout << "increment 前: x = " << x << std::endl;
        increment(x);
        std::cout << "increment 后: x = " << x << std::endl;

        int a = 100, b = 200;
        std::cout << "swap 前: a = " << a << ", b = " << b << std::endl;
        swap(a, b);
        std::cout << "swap 后: a = " << a << ", b = " << b << std::endl;

        return 0;
    }
    ```

    **预期输出**：
    ```
    increment 前: x = 10
    increment 后: x = 11
    swap 前: a = 100, b = 200
    swap 后: a = 200, b = 100
    ```

### 练习 2：const 引用返回

**要求**：

- 写函数 `const std::string& longer(const std::string &a, const std::string &b)`
- 返回两个字符串中更长的那个
- 长度相同时返回第一个
- 测试多组数据验证正确性

??? note "参考答案"

    ```cpp title="exercise02.cpp"
    #include <iostream>
    #include <string>

    const std::string& longer(const std::string &a, const std::string &b) {
        return a.size() >= b.size() ? a : b;
    }

    int main()
    {
        std::string s1 = "hello";
        std::string s2 = "world!!!";
        std::string s3 = "hi";

        std::cout << "longer(\"" << s1 << "\", \"" << s2 << "\") = \""
                  << longer(s1, s2) << "\"" << std::endl;

        std::cout << "longer(\"" << s1 << "\", \"" << s3 << "\") = \""
                  << longer(s1, s3) << "\"" << std::endl;

        // 验证返回的是引用（地址相同）
        const std::string &result = longer(s1, s2);
        std::cout << "返回的是引用: " << (&result == &s2 ? "是" : "否") << std::endl;

        return 0;
    }
    ```

    **预期输出**：
    ```
    longer("hello", "world!!!") = "world!!!"
    longer("hello", "hi") = "hello"
    返回的是引用: 是
    ```

---

> **下一课**：[函数增强](../04-function-enhanced/README.md)
