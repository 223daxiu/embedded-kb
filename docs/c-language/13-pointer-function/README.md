# 第 13 课：指针与函数

## 传地址调用

通过指针，函数可以修改调用者的变量：

```c title="pass_pointer.c"
#include <stdio.h>

// 通过指针修改外部变量
void set_value(int *p, int value)
{
    *p = value;
}

// 通过指针返回多个值
void get_circle(double radius, double *area, double *circumference)
{
    *area = 3.14159 * radius * radius;
    *circumference = 2 * 3.14159 * radius;
}

int main(void)
{
    int x = 0;
    set_value(&x, 42);
    printf("x = %d\n", x);  // 42
    
    double area, circ;
    get_circle(5.0, &area, &circ);
    printf("面积: %.2f, 周长: %.2f\n", area, circ);
    
    return 0;
}
```

---

## 数组指针 vs 指针数组

### 指针数组：存放指针的数组

```c
int a = 1, b = 2, c = 3;
int *arr[3] = {&a, &b, &c};  // 3 个 int * 指针组成的数组

printf("%d %d %d\n", *arr[0], *arr[1], *arr[2]);  // 1 2 3
```

最常见的用途——字符串数组：

```c title="string_array.c"
#include <stdio.h>

int main(void)
{
    // 指针数组存储字符串
    const char *months[] = {
        "January", "February", "March", "April",
        "May", "June", "July", "August",
        "September", "October", "November", "December"
    };
    
    for (int i = 0; i < 12; i++) {
        printf("%2d月: %s\n", i + 1, months[i]);
    }
    
    return 0;
}
```

### 数组指针：指向数组的指针

```c
int arr[5] = {1, 2, 3, 4, 5};
int (*p)[5] = &arr;  // p 指向整个数组

printf("%d\n", (*p)[2]);  // 3
```

!!! note "区分方法"
    ```c
    int *arr[5];   // 指针数组：arr 是数组，每个元素是 int *
    int (*p)[5];   // 数组指针：p 是指针，指向 int[5] 数组
    ```
    看 `*` 和谁先结合：`[]` 优先级高于 `*`。

---

## 函数返回指针

函数可以返回指针，但要注意**不要返回局部变量的地址**：

```c
// ❌ 错误！返回局部变量的地址
int *bad_function(void)
{
    int x = 42;
    return &x;  // x 在函数返回后被销毁，地址失效！
}

// ✅ 返回静态变量的地址
int *get_static(void)
{
    static int x = 42;  // 静态变量，不会被销毁
    return &x;
}

// ✅ 返回动态分配的内存（第 21 课详细讲）
int *create_array(int n)
{
    int *arr = malloc(n * sizeof(int));
    return arr;  // 调用者负责 free
}

// ✅ 返回传入的指针
int *find_max(int *arr, int n)
{
    int *max = &arr[0];
    for (int i = 1; i < n; i++) {
        if (arr[i] > *max) max = &arr[i];
    }
    return max;
}
```

---

## 实际应用

### 示例：安全的字符串查找

```c title="str_find.c"
#include <stdio.h>

// 在字符串中查找字符，返回位置指针
const char *my_strchr(const char *str, char ch)
{
    while (*str != '\0') {
        if (*str == ch) {
            return str;  // 找到了，返回该位置
        }
        str++;
    }
    return NULL;  // 没找到
}

int main(void)
{
    const char *text = "Hello, World!";
    const char *pos = my_strchr(text, 'W');
    
    if (pos != NULL) {
        printf("找到 'W'，位置: %td\n", pos - text);  // 7
        printf("从这里开始: %s\n", pos);  // World!
    }
    
    return 0;
}
```

### 示例：嵌入式风格——寄存器配置函数

```c title="reg_config.c"
#include <stdio.h>
#include <stdint.h>

// 模拟寄存器操作
typedef struct {
    uint32_t MODER;    // 模式寄存器
    uint32_t OTYPER;   // 输出类型
    uint32_t OSPEEDR;  // 输出速度
    uint32_t ODR;      // 输出数据
} GPIO_TypeDef;

// 配置 GPIO 引脚
void gpio_set_mode(GPIO_TypeDef *gpio, int pin, int mode)
{
    gpio->MODER &= ~(0x3 << (pin * 2));   // 清除原来的配置
    gpio->MODER |=  (mode << (pin * 2));   // 设置新模式
}

void gpio_write(GPIO_TypeDef *gpio, int pin, int value)
{
    if (value) {
        gpio->ODR |= (1 << pin);   // 置位
    } else {
        gpio->ODR &= ~(1 << pin);  // 清零
    }
}

int main(void)
{
    GPIO_TypeDef GPIOA = {0};
    
    gpio_set_mode(&GPIOA, 5, 1);  // PA5 设为输出模式
    gpio_write(&GPIOA, 5, 1);     // PA5 输出高电平
    
    printf("MODER = 0x%08X\n", GPIOA.MODER);  // 0x00000400
    printf("ODR   = 0x%08X\n", GPIOA.ODR);    // 0x00000020
    
    return 0;
}
```

---

## 练习题

### 练习 1：交换数组元素

编写函数 `void swap_elements(int *arr, int i, int j)`，交换数组中第 i 和第 j 个元素。

### 练习 2：字符串反转

编写函数 `void str_reverse(char *str)`，原地反转字符串。

??? note "参考答案"
    ```c
    #include <string.h>
    
    void str_reverse(char *str)
    {
        char *left = str;
        char *right = str + strlen(str) - 1;
        
        while (left < right) {
            char temp = *left;
            *left = *right;
            *right = temp;
            left++;
            right--;
        }
    }
    ```

### 练习 3：指针数组排序

给一个字符串指针数组，按字母顺序排序。

---

## 本课小结

| 知识点 | 说明 |
|--------|------|
| 传地址调用 | 传 `&变量`，函数用 `*指针` 修改 |
| 指针数组 | `int *arr[N]` — 数组中每个元素是指针 |
| 数组指针 | `int (*p)[N]` — 指针指向整个数组 |
| 返回指针 | 不要返回局部变量地址 |
| `const` 保护 | 函数不修改的数组参数加 `const` |

> **下一课**：[多级指针与函数指针](../14-function-pointer/README.md) —— 指针的高级用法
