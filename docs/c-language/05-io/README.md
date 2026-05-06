# 第 5 课：格式化输入输出

## printf —— 格式化输出

`printf` 是 C 语言中最常用的输出函数，全称 **print formatted**。

### 基本语法

```c
printf("格式字符串", 参数1, 参数2, ...);
```

格式字符串中的**格式说明符**（以 `%` 开头）会被后面的参数依次替换：

```c
int age = 20;
float height = 1.75;
printf("年龄: %d, 身高: %.2f\n", age, height);
// 输出：年龄: 20, 身高: 1.75
```

---

### 格式说明符大全

| 格式符 | 说明 | 示例 | 输出 |
|--------|------|------|------|
| `%d` | 十进制有符号整数 | `printf("%d", 42)` | `42` |
| `%u` | 十进制无符号整数 | `printf("%u", 42)` | `42` |
| `%x` | 十六进制（小写） | `printf("%x", 255)` | `ff` |
| `%X` | 十六进制（大写） | `printf("%X", 255)` | `FF` |
| `%o` | 八进制 | `printf("%o", 8)` | `10` |
| `%f` | 浮点数（小数形式） | `printf("%f", 3.14)` | `3.140000` |
| `%e` | 浮点数（科学计数法） | `printf("%e", 3.14)` | `3.140000e+00` |
| `%g` | 自动选择 `%f` 或 `%e` | `printf("%g", 3.14)` | `3.14` |
| `%c` | 单个字符 | `printf("%c", 'A')` | `A` |
| `%s` | 字符串 | `printf("%s", "Hi")` | `Hi` |
| `%p` | 指针地址 | `printf("%p", &a)` | `0x7ffd...` |
| `%zu` | `size_t` 类型 | `printf("%zu", sizeof(int))` | `4` |
| `%%` | 打印 `%` 本身 | `printf("100%%")` | `100%` |
| `%ld` | long 整数 | `printf("%ld", 100000L)` | `100000` |
| `%lld` | long long 整数 | `printf("%lld", 9999999999LL)` | `9999999999` |

---

### 格式控制——宽度与对齐

```c title="format_width.c"
#include <stdio.h>

int main(void)
{
    // 最小宽度
    printf("[%10d]\n", 42);      // [        42]  右对齐，宽度10
    printf("[%-10d]\n", 42);     // [42        ]  左对齐，宽度10
    printf("[%010d]\n", 42);     // [0000000042]  补零
    
    // 正号显示
    printf("[%+d]\n", 42);       // [+42]
    printf("[%+d]\n", -42);      // [-42]
    
    // 浮点数精度
    printf("[%f]\n", 3.14159);        // [3.141590]     默认6位小数
    printf("[%.2f]\n", 3.14159);      // [3.14]         2位小数
    printf("[%.0f]\n", 3.14159);      // [3]            0位小数
    printf("[%10.2f]\n", 3.14159);    // [      3.14]   宽度10，2位小数
    
    // 字符串精度
    printf("[%.5s]\n", "Hello World");  // [Hello]  只打印前5个字符
    printf("[%15s]\n", "Hello");        // [          Hello]  宽度15
    printf("[%-15s]\n", "Hello");       // [Hello          ]  左对齐
    
    return 0;
}
```

### 格式说明符完整语法

```
%[标志][宽度][.精度][长度]转换字符
```

| 部分 | 说明 | 示例 |
|------|------|------|
| 标志 | `-` 左对齐，`+` 显示正号，`0` 补零 | `%-10d`, `%+d`, `%05d` |
| 宽度 | 最小输出宽度 | `%10d` |
| 精度 | 小数位数（浮点）或最大字符数（字符串） | `%.2f`, `%.5s` |
| 长度 | `h`=short, `l`=long, `ll`=long long | `%ld`, `%lld` |

### 实用示例：打印表格

```c title="table.c"
#include <stdio.h>

int main(void)
{
    printf("%-15s %8s %8s %8s\n", "姓名", "语文", "数学", "英语");
    printf("%-15s %8d %8d %8d\n", "张三", 85, 92, 78);
    printf("%-15s %8d %8d %8d\n", "李四", 90, 88, 95);
    printf("%-15s %8d %8d %8d\n", "王五", 78, 96, 82);
    
    return 0;
}
```

输出：

```
姓名                语文     数学     英语
张三                  85       92       78
李四                  90       88       95
王五                  78       96       82
```

---

### 十六进制输出（嵌入式常用）

```c title="hex_output.c"
#include <stdio.h>

int main(void)
{
    unsigned int reg = 0x1234ABCD;
    
    printf("十进制:   %u\n", reg);
    printf("十六进制: %x\n", reg);       // 小写
    printf("十六进制: %X\n", reg);       // 大写
    printf("带前缀:  0x%08X\n", reg);    // 8位补零，带 0x 前缀
    
    // 打印内存中的字节
    unsigned char data[] = {0xDE, 0xAD, 0xBE, 0xEF};
    printf("数据: ");
    for (int i = 0; i < 4; i++) {
        printf("%02X ", data[i]);
    }
    printf("\n");
    // 输出：数据: DE AD BE EF
    
    return 0;
}
```

---

## scanf —— 格式化输入

`scanf` 用来从键盘读取用户输入。

### 基本用法

```c title="scanf_basic.c"
#include <stdio.h>

int main(void)
{
    int age;
    printf("请输入你的年龄: ");
    scanf("%d", &age);  // 注意：变量前要加 & 符号！
    printf("你 %d 岁了\n", age);
    
    float height;
    printf("请输入你的身高(米): ");
    scanf("%f", &height);
    printf("你的身高是 %.2f 米\n", height);
    
    char grade;
    printf("请输入你的等级(A/B/C): ");
    scanf(" %c", &grade);  // %c 前面加空格，跳过上次输入的换行符
    printf("你的等级是 %c\n", grade);
    
    return 0;
}
```

!!! warning "scanf 的 & 符号"
    ```c
    int a;
    scanf("%d", &a);   // ✅ 正确：& 取变量的地址
    scanf("%d", a);    // ❌ 错误：没有 &，程序会崩溃！
    ```
    `scanf` 需要知道数据存到**哪个地址**，所以必须用 `&` 取地址。
    （后面学指针时会深入理解这一点）

### scanf 格式符

| 格式符 | 读取类型 | 示例 |
|--------|----------|------|
| `%d` | int | `scanf("%d", &a)` |
| `%f` | float | `scanf("%f", &f)` |
| `%lf` | double | `scanf("%lf", &d)` |
| `%c` | char | `scanf(" %c", &c)` |
| `%s` | 字符串（到空格为止） | `scanf("%s", str)` |
| `%x` | 十六进制整数 | `scanf("%x", &hex)` |
| `%ld` | long | `scanf("%ld", &l)` |

### 读取多个值

```c
int a, b;
printf("请输入两个整数(用空格分隔): ");
scanf("%d %d", &a, &b);
printf("a=%d, b=%d, 和=%d\n", a, b, a + b);
```

用户输入：`10 20`（中间用空格、Tab 或回车分隔）

---

### scanf 的返回值

`scanf` 返回成功读取的项数，可以用来判断输入是否有效：

```c
int a;
int ret = scanf("%d", &a);

if (ret == 1) {
    printf("读取成功: %d\n", a);
} else {
    printf("输入无效！请输入数字。\n");
}
```

---

### scanf 常见问题

#### 问题 1：读取字符时吃掉换行符

```c
int num;
char ch;

printf("输入数字: ");
scanf("%d", &num);

printf("输入字符: ");
scanf("%c", &ch);  // ⚠️ 这里会读到上一次输入后的换行符 '\n'！
```

**解决方法：**

```c
scanf(" %c", &ch);  // ✅ 在 %c 前加一个空格，跳过空白字符
```

#### 问题 2：%s 只能读到空格

```c
char name[50];
printf("输入姓名: ");
scanf("%s", name);  // 输入 "张 三"，只读到 "张"

// 如果要读取整行（包含空格），用 fgets
char line[100];
printf("输入一行: ");
fgets(line, sizeof(line), stdin);
```

#### 问题 3：缓冲区残留

```c
// 清空输入缓冲区的方法
int c;
while ((c = getchar()) != '\n' && c != EOF);
```

---

## 其他输入输出函数

### putchar / getchar —— 单字符

```c title="char_io.c"
#include <stdio.h>

int main(void)
{
    // 输出单个字符
    putchar('H');
    putchar('i');
    putchar('\n');
    // 输出：Hi
    
    // 读取单个字符
    printf("请输入一个字符: ");
    int ch = getchar();  // 返回 int（为了能表示 EOF）
    printf("你输入了: %c (ASCII: %d)\n", ch, ch);
    
    return 0;
}
```

### puts / gets —— 字符串

```c
#include <stdio.h>

int main(void)
{
    // puts 输出字符串（自动换行）
    puts("Hello World");  // 等价于 printf("Hello World\n");
    
    // 读取一行字符串（推荐用 fgets）
    char name[50];
    printf("请输入姓名: ");
    fgets(name, sizeof(name), stdin);  // 安全地读取一行
    printf("你好, %s", name);
    
    return 0;
}
```

!!! warning "永远不要用 gets()"
    `gets()` 没有长度限制，可能导致**缓冲区溢出**（安全漏洞）。
    C11 标准已经移除了 `gets()`。请使用 `fgets()` 替代。

---

## 综合示例

### 示例 1：简易计算器

```c title="simple_calc.c"
#include <stdio.h>

int main(void)
{
    double num1, num2;
    char op;
    
    printf("请输入表达式 (如 3.5 + 2.1): ");
    scanf("%lf %c %lf", &num1, &op, &num2);
    
    printf("%.2f %c %.2f = ", num1, op, num2);
    
    switch (op) {
        case '+': printf("%.2f\n", num1 + num2); break;
        case '-': printf("%.2f\n", num1 - num2); break;
        case '*': printf("%.2f\n", num1 * num2); break;
        case '/':
            if (num2 != 0)
                printf("%.2f\n", num1 / num2);
            else
                printf("错误：除数不能为 0\n");
            break;
        default:
            printf("不支持的运算符\n");
    }
    
    return 0;
}
```

### 示例 2：格式化输出寄存器值（嵌入式风格）

```c title="reg_dump.c"
#include <stdio.h>

int main(void)
{
    // 模拟读取几个寄存器
    unsigned int regs[] = {0x40021000, 0x00000083, 0x40010800, 0x44444444};
    const char *names[] = {"RCC_CR", "RCC_CFGR", "GPIOA_CRL", "GPIOA_CRH"};
    
    printf("========== 寄存器转储 ==========\n");
    printf("%-12s  %-12s  %s\n", "名称", "地址", "值");
    printf("-----------------------------------\n");
    
    for (int i = 0; i < 4; i++) {
        printf("%-12s  0x%08X    0x%08X\n", names[i], 
               0x40021000 + i * 4, regs[i]);
    }
    
    return 0;
}
```

输出：

```
========== 寄存器转储 ==========
名称          地址          值
-----------------------------------
RCC_CR        0x40021000    0x40021000
RCC_CFGR      0x40021004    0x00000083
GPIOA_CRL     0x40021008    0x40010800
GPIOA_CRH     0x4002100C    0x44444444
```

---

## 练习题

### 练习 1：个人信息卡

编写程序，读取用户的姓名、年龄、身高、体重，计算 BMI 并格式化输出。

??? note "参考答案"
    ```c
    #include <stdio.h>
    
    int main(void)
    {
        char name[50];
        int age;
        double height, weight;
        
        printf("姓名: ");
        scanf("%s", name);
        printf("年龄: ");
        scanf("%d", &age);
        printf("身高(米): ");
        scanf("%lf", &height);
        printf("体重(千克): ");
        scanf("%lf", &weight);
        
        double bmi = weight / (height * height);
        
        printf("\n===== 个人信息卡 =====\n");
        printf("姓名: %-10s\n", name);
        printf("年龄: %-10d 岁\n", age);
        printf("身高: %-10.2f 米\n", height);
        printf("体重: %-10.1f 千克\n", weight);
        printf("BMI:  %-10.1f %s\n", bmi,
               bmi < 18.5 ? "偏瘦" :
               bmi < 24.0 ? "正常" :
               bmi < 28.0 ? "偏胖" : "肥胖");
        printf("======================\n");
        
        return 0;
    }
    ```

### 练习 2：十进制转换器

输入一个整数，分别以十进制、八进制、十六进制显示。

??? note "参考答案"
    ```c
    #include <stdio.h>
    
    int main(void)
    {
        int num;
        printf("请输入一个整数: ");
        scanf("%d", &num);
        
        printf("十进制:   %d\n", num);
        printf("八进制:   %o (0%o)\n", num, num);
        printf("十六进制: %x (0x%X)\n", num, num);
        printf("占用字节: %zu\n", sizeof(num));
        
        return 0;
    }
    ```

### 练习 3：乘法表（一行）

输入一个 1~9 的数字 n，打印 n 的乘法表（一行）。

??? note "参考答案"
    ```c
    #include <stdio.h>
    
    int main(void)
    {
        int n;
        printf("输入数字(1-9): ");
        scanf("%d", &n);
        
        for (int i = 1; i <= 9; i++) {
            printf("%d × %d = %-4d", n, i, n * i);
        }
        printf("\n");
        
        return 0;
    }
    ```

---

## 本课小结

| 知识点 | 说明 |
|--------|------|
| `printf` | 格式化输出，`%d` `%f` `%s` `%c` `%x` 等 |
| 宽度控制 | `%10d` 最小宽度，`%-10d` 左对齐，`%010d` 补零 |
| 精度控制 | `%.2f` 2 位小数，`%.5s` 最多 5 个字符 |
| `scanf` | 格式化输入，变量前必须加 `&` |
| `scanf` 返回值 | 返回成功读取的项数 |
| `%c` 前加空格 | `scanf(" %c", &ch)` 跳过空白字符 |
| `fgets` | 安全地读取一行字符串，替代 `gets` |
| `putchar/getchar` | 单字符输入输出 |

> **下一课**：[条件判断](../06-condition/README.md) —— 让程序学会"做选择"
