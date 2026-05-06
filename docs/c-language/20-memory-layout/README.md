# 第 20 课：程序内存布局

## C 程序的内存分区

```mermaid
graph TB
    subgraph "内存布局（从高地址到低地址）"
        A["栈区 (Stack)<br>局部变量、函数调用"]
        B["↕ 增长方向相反"]
        C["堆区 (Heap)<br>malloc/free 动态分配"]
        D["BSS 段<br>未初始化的全局/静态变量"]
        E["数据段 (Data)<br>已初始化的全局/静态变量"]
        F["代码段 (Text)<br>程序指令（只读）"]
    end
    A --> B --> C --> D --> E --> F
```

---

## 各区域详解

```c title="memory_layout.c"
#include <stdio.h>
#include <stdlib.h>

// 数据段：已初始化的全局变量
int global_init = 100;

// BSS 段：未初始化的全局变量
int global_uninit;

int main(void)
{
    // 栈区：局部变量
    int local = 42;
    
    // 堆区：动态分配
    int *heap_ptr = malloc(sizeof(int));
    *heap_ptr = 99;
    
    // static 变量在数据段/BSS段
    static int s_init = 50;    // 数据段
    static int s_uninit;       // BSS 段
    
    printf("代码段(函数): %p\n", (void *)main);
    printf("数据段(全局): %p\n", (void *)&global_init);
    printf("BSS段(未初始化): %p\n", (void *)&global_uninit);
    printf("栈区(局部): %p\n", (void *)&local);
    printf("堆区(malloc): %p\n", (void *)heap_ptr);
    
    free(heap_ptr);
    return 0;
}
```

---

## 栈 vs 堆

| 特性 | 栈 (Stack) | 堆 (Heap) |
|------|-----------|-----------|
| 管理方式 | 自动（编译器管理） | 手动（malloc/free） |
| 速度 | 快 | 慢 |
| 大小 | 有限（通常 1~8 MB） | 较大（取决于系统） |
| 生命周期 | 函数结束自动释放 | 必须手动 free |
| 碎片 | 无 | 可能有 |

---

## malloc / calloc / realloc / free

```c
#include <stdlib.h>

// malloc：分配未初始化内存
int *p1 = (int *)malloc(5 * sizeof(int));

// calloc：分配并初始化为 0
int *p2 = (int *)calloc(5, sizeof(int));

// realloc：调整已分配内存大小
p1 = (int *)realloc(p1, 10 * sizeof(int));

// free：释放内存
free(p1);
free(p2);
p1 = NULL;  // 防止野指针
p2 = NULL;
```

### 使用模板

```c
// 标准使用流程
int *arr = (int *)malloc(n * sizeof(int));
if (arr == NULL) {
    fprintf(stderr, "内存分配失败\n");
    return -1;
}

// ... 使用 arr ...

free(arr);
arr = NULL;
```

---

## 常见内存错误

### 1. 内存泄漏

```c
void leak(void) {
    int *p = malloc(100);
    // 忘记 free → 内存泄漏！
}
```

### 2. 野指针

```c
int *p = malloc(sizeof(int));
free(p);
*p = 10;  // ❌ 使用已释放的内存！
// 正确做法：free 后置 NULL
```

### 3. 重复释放

```c
int *p = malloc(sizeof(int));
free(p);
free(p);  // ❌ 重复释放！
```

### 4. 越界访问

```c
int *arr = malloc(5 * sizeof(int));
arr[5] = 100;  // ❌ 越界！只有 arr[0]~arr[4]
```

---

## 练习题

### 练习 1

用 `malloc` 创建动态数组，输入 n 个整数，求和并释放内存。

### 练习 2

实现函数 `int *create_array(int n, int value)`，创建大小为 n 的数组并填充 value。

??? note "参考答案"
    ```c
    int *create_array(int n, int value) {
        int *arr = (int *)malloc(n * sizeof(int));
        if (arr == NULL) return NULL;
        for (int i = 0; i < n; i++) {
            arr[i] = value;
        }
        return arr;
    }
    
    // 使用
    int *arr = create_array(10, 0);
    if (arr) {
        // 使用...
        free(arr);
    }
    ```

---

## 本课小结

| 区域 | 内容 | 管理 |
|------|------|------|
| 栈 | 局部变量 | 自动 |
| 堆 | malloc 分配 | 手动 free |
| 数据段 | 初始化全局/静态 | 程序结束释放 |
| BSS | 未初始化全局/静态 | 程序结束释放 |
| 代码段 | 程序指令 | 只读 |

> **下一课**：[动态内存实战](../21-dynamic-memory/README.md)
