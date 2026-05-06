# 第 19 课：联合体与枚举

## 联合体 (union)

联合体的所有成员**共享同一块内存**，大小等于最大成员的大小：

```c title="union_basic.c"
#include <stdio.h>

typedef union {
    int i;
    float f;
    char c;
} Data;

int main(void)
{
    Data d;
    printf("union 大小: %zu\n", sizeof(d));  // 4（int 和 float 中较大的）
    
    d.i = 42;
    printf("d.i = %d\n", d.i);  // 42
    
    d.f = 3.14;  // 覆盖了 d.i 的值！
    printf("d.f = %f\n", d.f);  // 3.14
    printf("d.i = %d\n", d.i);  // 乱码（内存被 float 覆盖了）
    
    return 0;
}
```

### 嵌入式应用：协议数据解析

```c
typedef union {
    uint32_t raw;              // 整体读取
    struct {
        uint8_t byte0;         // 按字节访问
        uint8_t byte1;
        uint8_t byte2;
        uint8_t byte3;
    } bytes;
} Register;

Register reg;
reg.raw = 0x12345678;
printf("byte0 = 0x%02X\n", reg.bytes.byte0);  // 0x78（小端序）
```

---

## 枚举 (enum)

枚举用来定义一组**命名的整型常量**：

```c title="enum_basic.c"
#include <stdio.h>

// 定义枚举
typedef enum {
    LED_OFF = 0,
    LED_ON = 1,
    LED_BLINK = 2
} LedState;

typedef enum {
    MON, TUE, WED, THU, FRI, SAT, SUN  // 自动 0,1,2,3,4,5,6
} Weekday;

int main(void)
{
    LedState led = LED_BLINK;
    
    switch (led) {
        case LED_OFF:   printf("LED 关闭\n"); break;
        case LED_ON:    printf("LED 开启\n"); break;
        case LED_BLINK: printf("LED 闪烁\n"); break;
    }
    
    Weekday today = WED;
    printf("今天是星期 %d\n", today + 1);  // 3
    
    return 0;
}
```

---

## typedef 类型别名

```c
typedef unsigned char  uint8_t;   // 无符号 8 位
typedef unsigned int   uint32_t;  // 无符号 32 位
typedef int (*Callback)(int);     // 函数指针类型
```

---

## 位域

位域允许在结构体中精确指定成员占用的**位数**：

```c title="bitfield.c"
#include <stdio.h>

typedef struct {
    unsigned int mode    : 2;  // 2 位 (0~3)
    unsigned int speed   : 2;  // 2 位
    unsigned int pull    : 1;  // 1 位 (0~1)
    unsigned int output  : 1;  // 1 位
    unsigned int reserved: 26; // 保留位
} GPIO_Config;

int main(void)
{
    printf("GPIO_Config 大小: %zu 字节\n", sizeof(GPIO_Config));  // 4
    
    GPIO_Config pin5 = {
        .mode = 1,    // 输出模式
        .speed = 2,   // 高速
        .pull = 0,    // 无上拉
        .output = 1,  // 推挽输出
    };
    
    printf("mode=%d speed=%d pull=%d output=%d\n",
           pin5.mode, pin5.speed, pin5.pull, pin5.output);
    
    return 0;
}
```

---

## 练习题

### 练习 1

用枚举和 switch 实现一个交通灯状态机（红→绿→黄→红）。

### 练习 2

用联合体把一个 `float` 的 4 个字节分别打印出来。

---

## 本课小结

| 知识点 | 说明 |
|--------|------|
| `union` | 所有成员共享内存，节省空间 |
| `enum` | 命名整型常量，增强可读性 |
| `typedef` | 创建类型别名 |
| 位域 | 精确控制成员占几个位 |

> **下一课**：[程序内存布局](../20-memory-layout/README.md) —— 理解栈、堆、数据段
