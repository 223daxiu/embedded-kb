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

### 练习 1

定义一个命名空间 `math_utils`，包含 `add` 和 `multiply` 函数，在 main 中调用。

### 练习 2

用 `cout` 和 `iomanip` 打印一个整齐的表格（3列：姓名、年龄、成绩）。

---

> **下一课**：[引用与 const](../03-reference-const/README.md)
