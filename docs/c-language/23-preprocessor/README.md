# 第 23 课：预处理器

## 什么是预处理？

预处理是编译的第一步，在真正编译之前处理所有 `#` 开头的指令：

```mermaid
graph LR
    A[".c 源文件"] -->|预处理| B[".i 文件"] -->|编译| C[".s 汇编"] -->|汇编| D[".o 目标文件"] -->|链接| E["可执行文件"]
```

---

## 宏定义 #define

### 常量宏

```c
#define PI 3.14159
#define MAX_SIZE 100
#define LED_PIN 13
#define ARRAY_SIZE(arr) (sizeof(arr) / sizeof((arr)[0]))
```

### 函数宏

```c
#define MAX(a, b) ((a) > (b) ? (a) : (b))
#define MIN(a, b) ((a) < (b) ? (a) : (b))
#define ABS(x)    ((x) >= 0 ? (x) : -(x))
#define SWAP(a, b) do { typeof(a) _t = (a); (a) = (b); (b) = _t; } while(0)
```

!!! warning "宏的陷阱"
    ```c
    #define SQUARE(x) x * x
    int r = SQUARE(3 + 1);  // 展开为 3 + 1 * 3 + 1 = 7 ❌
    
    // 正确：加括号
    #define SQUARE(x) ((x) * (x))
    int r = SQUARE(3 + 1);  // 展开为 ((3+1) * (3+1)) = 16 ✅
    ```

---

## 条件编译

```c
// 1. 平台适配
#ifdef _WIN32
    #include <windows.h>
    #define SLEEP(ms) Sleep(ms)
#elif defined(__linux__)
    #include <unistd.h>
    #define SLEEP(ms) usleep((ms) * 1000)
#endif

// 2. 调试开关
#define DEBUG 1

#if DEBUG
    #define LOG(fmt, ...) printf("[DEBUG] " fmt "\n", ##__VA_ARGS__)
#else
    #define LOG(fmt, ...)   // 空操作
#endif

// 3. 头文件保护（防止重复包含）
#ifndef __MY_HEADER_H__
#define __MY_HEADER_H__
// 头文件内容...
#endif

// 或者用 pragma once（更简洁，大多数编译器支持）
#pragma once
```

---

## 嵌入式常用宏

```c title="embedded_macros.h"
#ifndef __EMBEDDED_MACROS_H__
#define __EMBEDDED_MACROS_H__

#include <stdint.h>

// 位操作宏
#define BIT(n)           (1UL << (n))
#define SET_BIT(reg, n)  ((reg) |= BIT(n))
#define CLR_BIT(reg, n)  ((reg) &= ~BIT(n))
#define TOG_BIT(reg, n)  ((reg) ^= BIT(n))
#define GET_BIT(reg, n)  (((reg) >> (n)) & 1)

// 寄存器操作
#define REG32(addr)      (*(volatile uint32_t *)(addr))
#define GPIOA_ODR        REG32(0x40020014)

// 数组长度
#define ARRAY_LEN(arr)   (sizeof(arr) / sizeof((arr)[0]))

// 字节操作
#define HIGH_BYTE(x)     (((x) >> 8) & 0xFF)
#define LOW_BYTE(x)      ((x) & 0xFF)

#endif
```

---

## #include 的区别

```c
#include <stdio.h>     // 在系统目录搜索
#include "my_header.h" // 先在当前目录搜索，再搜系统目录
```

---

## 练习题

### 练习 1

编写一个头文件，包含 LED 控制的宏定义（ON/OFF/TOGGLE）。

### 练习 2

用条件编译实现：DEBUG 模式打印调试信息，RELEASE 模式不打印。

---

## 本课小结

| 指令 | 用途 |
|------|------|
| `#define` | 宏定义 |
| `#include` | 包含头文件 |
| `#ifdef/#ifndef/#endif` | 条件编译 |
| `#pragma once` | 防止重复包含 |

> **下一课**：[多文件编程与编译](../24-multi-file/README.md)
