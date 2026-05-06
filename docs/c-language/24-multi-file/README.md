# 第 24 课：多文件编程与编译

## 为什么要多文件？

一个程序全写在一个 `.c` 文件里，代码多了会难以管理。多文件编程是把代码按功能**模块化**：

```
project/
├── main.c         // 主程序
├── led.h          // LED 模块头文件（声明）
├── led.c          // LED 模块实现
├── uart.h         // 串口模块头文件
├── uart.c         // 串口模块实现
└── Makefile       // 编译脚本
```

---

## 头文件与源文件

### 头文件 (.h)：声明

```c title="math_utils.h"
#ifndef __MATH_UTILS_H__
#define __MATH_UTILS_H__

// 函数声明
int add(int a, int b);
int max(int a, int b);
double circle_area(double r);

#endif
```

### 源文件 (.c)：实现

```c title="math_utils.c"
#include "math_utils.h"

int add(int a, int b) { return a + b; }
int max(int a, int b) { return a > b ? a : b; }
double circle_area(double r) { return 3.14159 * r * r; }
```

### 主文件：使用

```c title="main.c"
#include <stdio.h>
#include "math_utils.h"

int main(void)
{
    printf("3 + 5 = %d\n", add(3, 5));
    printf("max(3,5) = %d\n", max(3, 5));
    printf("面积 = %.2f\n", circle_area(3.0));
    return 0;
}
```

---

## 编译流程

```bash
# 方法 1：一步编译
gcc main.c math_utils.c -o app

# 方法 2：分步编译（大项目推荐）
gcc -c main.c -o main.o
gcc -c math_utils.c -o math_utils.o
gcc main.o math_utils.o -o app
```

---

## Makefile 基础

```makefile title="Makefile"
CC = gcc
CFLAGS = -Wall -g

# 目标: 依赖
app: main.o math_utils.o
	$(CC) $^ -o $@

# .c → .o 通用规则
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f *.o app
```

```bash
make        # 编译
make clean  # 清理
```

---

## extern 与 static

```c
// file1.c
int global_count = 0;           // 全局变量
static int private_count = 0;   // 仅在 file1.c 可见

// file2.c
extern int global_count;  // 声明外部变量（不是定义）
// extern int private_count; // ❌ 无法访问 static 变量
```

| 关键字 | 作用 |
|--------|------|
| `extern` | 声明变量/函数在其他文件中定义 |
| `static`（全局） | 限制作用域为当前文件 |
| `static`（局部） | 变量在函数调用间保持值 |

---

## 嵌入式项目结构示例

```
embedded_project/
├── Core/
│   ├── Inc/          # 头文件
│   │   ├── main.h
│   │   ├── gpio.h
│   │   └── uart.h
│   └── Src/          # 源文件
│       ├── main.c
│       ├── gpio.c
│       └── uart.c
├── Drivers/          # 驱动库
└── Makefile
```

---

## 练习题

### 练习 1

把学生成绩管理功能拆分为 `student.h`、`student.c`、`main.c` 三个文件，并用 gcc 编译。

### 练习 2

编写一个简单的 Makefile 来管理上面的项目。

---

## 本课小结

| 概念 | 说明 |
|------|------|
| `.h` 头文件 | 放声明 |
| `.c` 源文件 | 放实现 |
| `#include` | 包含头文件 |
| `extern` | 引用外部定义 |
| `static` | 限制作用域 |
| Makefile | 自动化编译 |

> **下一课**：[指针高级应用](../25-advanced-pointer/README.md)
