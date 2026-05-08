# 第 02 课：命名空间与输入输出

## 命名空间 (namespace)

命名空间用来避免**名字冲突**：

```cpp
namespace sensor {
    int read() { return 42; }
}

namespace motor {
    int read() { return 100; }
}

int main()
{
    std::cout << sensor::read() << std::endl;  // 42
    std::cout << motor::read() << std::endl;   // 100
    return 0;
}
```

### using 声明

```cpp
using std::cout;
using std::endl;

cout << "不用写 std:: 了" << endl;

// 或者一次性引入整个命名空间（不推荐在头文件中使用）
using namespace std;
```

### 嵌套命名空间

```cpp
namespace company::project::module {  // C++17
    void init() { /* ... */ }
}
// 调用：company::project::module::init();
```

---

## cout 输出

```cpp
#include <iostream>
#include <iomanip>

int main()
{
    int x = 255;
    double pi = 3.14159265;
    
    // 基本输出
    std::cout << "x = " << x << std::endl;
    
    // 进制输出
    std::cout << std::hex << x << std::endl;  // ff
    std::cout << std::oct << x << std::endl;  // 377
    std::cout << std::dec << x << std::endl;  // 255
    
    // 浮点精度
    std::cout << std::fixed << std::setprecision(2) << pi << std::endl;  // 3.14
    
    // 对齐与宽度
    std::cout << std::setw(10) << std::left << "Name" 
              << std::setw(5) << std::right << "Age" << std::endl;
    
    return 0;
}
```

---

## cin 输入

```cpp
#include <iostream>
#include <string>

int main()
{
    int age;
    std::string name;
    
    std::cout << "姓名: ";
    std::cin >> name;           // 读到空格停止
    
    std::cout << "年龄: ";
    std::cin >> age;
    
    std::cout << name << " 今年 " << age << " 岁" << std::endl;
    
    // 读取整行（包含空格）
    std::cin.ignore();          // 忽略上一次留下的换行符
    std::string line;
    std::cout << "说一句话: ";
    std::getline(std::cin, line);
    std::cout << "你说: " << line << std::endl;
    
    return 0;
}
```

---

## 练习题

### 练习 1：自定义命名空间

**要求**：

- 定义命名空间 `math_utils`，包含 `add(int,int)` 和 `multiply(int,int)` 函数
- 在 `main` 中分别用 `math_utils::` 和 `using` 两种方式调用
- 打印计算结果

??? note "参考答案"

    ```cpp title="exercise01.cpp"
    #include <iostream>

    namespace math_utils {
        int add(int a, int b) { return a + b; }
        int multiply(int a, int b) { return a * b; }
    }

    int main()
    {
        // 方式1：完整限定名
        std::cout << "3 + 5 = " << math_utils::add(3, 5) << std::endl;
        std::cout << "3 * 5 = " << math_utils::multiply(3, 5) << std::endl;

        // 方式2：using 声明
        using math_utils::add;
        std::cout << "10 + 20 = " << add(10, 20) << std::endl;

        return 0;
    }
    ```

    **预期输出**：
    ```
    3 + 5 = 8
    3 * 5 = 15
    10 + 20 = 30
    ```

### 练习 2：格式化表格输出

**要求**：

- 用 `setw`、`left`、`right` 打印至少 3 行数据的表格
- 表格包含：姓名（左对齐10列）、年龄（右对齐5列）、成绩（右对齐8列，保留1位小数）
- 先打印表头，然后打印分隔线，再打印数据

??? note "参考答案"

    ```cpp title="exercise02.cpp"
    #include <iostream>
    #include <iomanip>
    #include <string>

    int main()
    {
        // 表头
        std::cout << std::left  << std::setw(10) << "姓名"
                  << std::right << std::setw(5)  << "年龄"
                  << std::right << std::setw(8)  << "成绩" << std::endl;
        std::cout << std::string(23, '-') << std::endl;

        // 数据
        std::cout << std::left  << std::setw(10) << "张三"
                  << std::right << std::setw(5)  << 20
                  << std::right << std::setw(8)  << std::fixed << std::setprecision(1) << 95.5 << std::endl;

        std::cout << std::left  << std::setw(10) << "李四"
                  << std::right << std::setw(5)  << 21
                  << std::right << std::setw(8)  << 88.0 << std::endl;

        std::cout << std::left  << std::setw(10) << "王五"
                  << std::right << std::setw(5)  << 19
                  << std::right << std::setw(8)  << 72.3 << std::endl;

        return 0;
    }
    ```

    **预期输出**：
    ```
    姓名          年龄      成绩
    -----------------------
    张三          20    95.5
    李四          21    88.0
    王五          19    72.3
    ```

---

> **下一课**：[引用与 const](../03-reference-const/README.md)
