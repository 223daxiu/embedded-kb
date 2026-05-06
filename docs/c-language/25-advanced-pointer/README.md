# 第 25 课：指针高级应用

## void 指针

`void *` 是通用指针，可以指向任何类型，但**不能直接解引用**：

```c
void *ptr;
int a = 42;
float b = 3.14;

ptr = &a;
printf("%d\n", *(int *)ptr);   // 必须转型再解引用

ptr = &b;
printf("%.2f\n", *(float *)ptr);
```

### 通用交换函数

```c title="generic_swap.c"
#include <stdio.h>
#include <string.h>

void swap(void *a, void *b, size_t size)
{
    char temp[size];  // VLA
    memcpy(temp, a, size);
    memcpy(a, b, size);
    memcpy(b, temp, size);
}

int main(void)
{
    int x = 10, y = 20;
    swap(&x, &y, sizeof(int));
    printf("x=%d y=%d\n", x, y);  // x=20 y=10
    
    double a = 1.1, b = 2.2;
    swap(&a, &b, sizeof(double));
    printf("a=%.1f b=%.1f\n", a, b);  // a=2.2 b=1.1
    
    return 0;
}
```

---

## 多级指针

```c
int a = 100;
int *p = &a;       // 一级指针
int **pp = &p;     // 二级指针
int ***ppp = &pp;  // 三级指针（实际少用）

printf("%d\n", **pp);   // 100
printf("%d\n", ***ppp); // 100
```

### 二级指针的常见用途

```c
// 在函数中修改指针本身
void alloc_array(int **ptr, int n)
{
    *ptr = (int *)malloc(n * sizeof(int));
}

int main(void)
{
    int *arr = NULL;
    alloc_array(&arr, 10);  // 传指针的地址
    // arr 现在指向 10 个 int 的空间
    free(arr);
    return 0;
}
```

---

## volatile 关键字

告诉编译器不要优化对该变量的访问，**每次都从内存读取**：

```c
// 嵌入式中访问硬件寄存器
volatile uint32_t *GPIO_IDR = (volatile uint32_t *)0x40020010;

// 中断中修改的变量
volatile int flag = 0;

void ISR_Handler(void) {
    flag = 1;
}

int main(void) {
    while (flag == 0) {
        // 如果没有 volatile，编译器可能优化掉这个循环
    }
    printf("收到中断！\n");
}
```

---

## const 与指针的组合

```c
const int *p1;       // 指向常量的指针（不能改值，能改指向）
int *const p2;       // 常量指针（能改值，不能改指向）
const int *const p3; // 都不能改

// 记忆：const 在 * 左边 → 值不可变
//        const 在 * 右边 → 指向不可变
```

---

## 练习题

### 练习 1

用 `void *` 实现通用冒泡排序（参考 `qsort` 接口）。

### 练习 2

解释以下声明：
- `int *p[5]`
- `int (*p)[5]`
- `int (*p)(int)`
- `int *(*p)(int)`

??? note "参考答案"
    - `int *p[5]` — 指针数组：5 个 int 指针
    - `int (*p)[5]` — 数组指针：指向含 5 个 int 的数组
    - `int (*p)(int)` — 函数指针：指向参数为 int、返回 int 的函数
    - `int *(*p)(int)` — 函数指针：指向参数为 int、返回 int* 的函数

---

> **下一课**：[数据结构基础](../26-data-structure-intro/README.md)
