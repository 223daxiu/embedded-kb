# 第 16 课：字符串处理函数

## `<string.h>` 常用函数速查

| 函数 | 功能 | 原型 |
|------|------|------|
| `strlen` | 求长度 | `size_t strlen(const char *s)` |
| `strcpy` | 复制 | `char *strcpy(char *dest, const char *src)` |
| `strncpy` | 安全复制 | `char *strncpy(char *dest, const char *src, size_t n)` |
| `strcat` | 拼接 | `char *strcat(char *dest, const char *src)` |
| `strncat` | 安全拼接 | `char *strncat(char *dest, const char *src, size_t n)` |
| `strcmp` | 比较 | `int strcmp(const char *s1, const char *s2)` |
| `strncmp` | 比较前 n 个 | `int strncmp(const char *s1, const char *s2, size_t n)` |
| `strstr` | 查找子串 | `char *strstr(const char *haystack, const char *needle)` |
| `strchr` | 查找字符 | `char *strchr(const char *s, int c)` |
| `strtok` | 分割字符串 | `char *strtok(char *str, const char *delim)` |
| `sprintf` | 格式化到字符串 | `int sprintf(char *str, const char *format, ...)` |
| `memcpy` | 内存复制 | `void *memcpy(void *dest, const void *src, size_t n)` |
| `memset` | 内存填充 | `void *memset(void *s, int c, size_t n)` |

---

## 详细讲解

### strlen — 字符串长度

```c
#include <string.h>

char str[] = "Hello";
size_t len = strlen(str);  // 5（不含 \0）
```

### strcpy / strncpy — 复制

```c
char dest[20];

// strcpy：不安全，可能溢出
strcpy(dest, "Hello World");

// strncpy：安全版本
strncpy(dest, "Hello World", sizeof(dest) - 1);
dest[sizeof(dest) - 1] = '\0';  // 确保以 \0 结尾
```

### strcat / strncat — 拼接

```c
char greeting[50] = "Hello";
strcat(greeting, ", ");
strcat(greeting, "World!");
printf("%s\n", greeting);  // Hello, World!

// 安全版本
char buf[20] = "Hello";
strncat(buf, ", World!", sizeof(buf) - strlen(buf) - 1);
```

### strcmp — 比较

```c
int result = strcmp("abc", "abd");
// result < 0  → "abc" < "abd"
// result == 0 → 相等
// result > 0  → 第一个更大

// 常见用法
if (strcmp(input, "quit") == 0) {
    printf("退出程序\n");
}

// 忽略大小写比较（非标准，但常见）
// strcasecmp (Linux) / _stricmp (Windows)
```

### strstr — 查找子串

```c
const char *text = "Hello, World!";
char *pos = strstr(text, "World");
if (pos != NULL) {
    printf("找到，位置: %td\n", pos - text);  // 7
    printf("从这里开始: %s\n", pos);  // World!
}
```

### strchr — 查找字符

```c
const char *path = "/home/user/file.txt";
char *dot = strchr(path, '.');
if (dot) {
    printf("扩展名: %s\n", dot);  // .txt
}

// strrchr 从后往前找
char *last_slash = strrchr(path, '/');
if (last_slash) {
    printf("文件名: %s\n", last_slash + 1);  // file.txt
}
```

### strtok — 分割字符串

```c title="strtok_example.c"
#include <stdio.h>
#include <string.h>

int main(void)
{
    char data[] = "192.168.1.100";
    
    char *token = strtok(data, ".");  // 第一次调用传字符串
    while (token != NULL) {
        printf("[%s] ", token);
        token = strtok(NULL, ".");     // 后续调用传 NULL
    }
    printf("\n");
    // 输出：[192] [168] [1] [100]
    
    return 0;
}
```

!!! warning "strtok 会修改原字符串"
    `strtok` 会把分隔符替换为 `\0`，所以**会破坏原字符串**。如果需要保留原串，先复制一份。

### sprintf — 格式化到字符串

```c
char buf[100];
int year = 2025, month = 7, day = 10;
sprintf(buf, "%04d-%02d-%02d", year, month, day);
printf("日期: %s\n", buf);  // 2025-07-10

// 安全版本
snprintf(buf, sizeof(buf), "温度: %.1f°C", 36.5);
```

### memcpy / memset — 内存操作

```c
#include <string.h>

// 内存复制（比 strcpy 更通用，可以复制任何数据）
int src[] = {1, 2, 3, 4, 5};
int dest[5];
memcpy(dest, src, sizeof(src));  // 复制 20 字节

// 内存填充
char buffer[100];
memset(buffer, 0, sizeof(buffer));   // 全部填 0
memset(buffer, 'A', 10);            // 前 10 个字节填 'A'
```

---

## 综合示例

### 示例：解析 AT 指令（嵌入式通信）

```c title="at_parser.c"
#include <stdio.h>
#include <string.h>

typedef struct {
    char cmd[20];
    char param[50];
} ATCommand;

int parse_at(const char *input, ATCommand *result)
{
    // 检查 AT 前缀
    if (strncmp(input, "AT+", 3) != 0) return -1;
    
    // 查找 = 号
    const char *eq = strchr(input + 3, '=');
    if (eq != NULL) {
        int cmd_len = eq - (input + 3);
        strncpy(result->cmd, input + 3, cmd_len);
        result->cmd[cmd_len] = '\0';
        strncpy(result->param, eq + 1, sizeof(result->param) - 1);
    } else {
        strncpy(result->cmd, input + 3, sizeof(result->cmd) - 1);
        result->param[0] = '\0';
    }
    
    return 0;
}

int main(void)
{
    const char *commands[] = {
        "AT+BAUD=115200",
        "AT+NAME=MyDevice",
        "AT+RESET",
    };
    
    for (int i = 0; i < 3; i++) {
        ATCommand cmd = {0};
        if (parse_at(commands[i], &cmd) == 0) {
            printf("命令: %-10s 参数: %s\n", cmd.cmd, 
                   cmd.param[0] ? cmd.param : "(无)");
        }
    }
    
    return 0;
}
```

---

## `<ctype.h>` 字符判断函数

| 函数 | 说明 |
|------|------|
| `isalpha(c)` | 是否是字母 |
| `isdigit(c)` | 是否是数字 |
| `isalnum(c)` | 是否是字母或数字 |
| `isupper(c)` | 是否是大写字母 |
| `islower(c)` | 是否是小写字母 |
| `isspace(c)` | 是否是空白字符 |
| `toupper(c)` | 转大写 |
| `tolower(c)` | 转小写 |

```c
#include <ctype.h>

// 安全的大小写转换
void str_to_upper(char *s) {
    while (*s) { *s = toupper(*s); s++; }
}
```

---

## 练习题

### 练习 1：字符串拼接

不用 `strcat`，手写字符串拼接函数。

### 练习 2：单词统计

统计一个句子中有多少个单词，最长的单词是什么。

### 练习 3：CSV 解析

解析一行 CSV 数据 `"张三,85,92,78"`，提取姓名和各科成绩。

??? note "参考答案"
    ```c
    #include <stdio.h>
    #include <string.h>
    #include <stdlib.h>
    
    int main(void)
    {
        char csv[] = "张三,85,92,78";
        
        char *token = strtok(csv, ",");
        printf("姓名: %s\n", token);
        
        int scores[3], i = 0;
        while ((token = strtok(NULL, ",")) != NULL && i < 3) {
            scores[i++] = atoi(token);
        }
        
        printf("成绩: %d %d %d\n", scores[0], scores[1], scores[2]);
        return 0;
    }
    ```

---

## 本课小结

| 函数 | 用途 | 安全替代 |
|------|------|----------|
| `strlen` | 长度 | — |
| `strcpy` | 复制 | `strncpy` |
| `strcat` | 拼接 | `strncat` |
| `strcmp` | 比较 | `strncmp` |
| `strstr` | 查找子串 | — |
| `strtok` | 分割 | — |
| `sprintf` | 格式化 | `snprintf` |
| `memcpy/memset` | 内存操作 | — |

> **下一课**：[结构体](../17-struct/README.md) —— 自定义数据类型
