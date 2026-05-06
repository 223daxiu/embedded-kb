# 第 22 课：文件操作

## 文件操作流程

```mermaid
graph LR
    A[fopen 打开] --> B[读/写操作] --> C[fclose 关闭]
```

## 打开与关闭

```c
FILE *fp = fopen("data.txt", "r");  // 打开
if (fp == NULL) {
    perror("打开文件失败");
    return -1;
}
// ... 操作 ...
fclose(fp);  // 关闭
```

| 模式 | 说明 |
|------|------|
| `"r"` | 只读（文件必须存在） |
| `"w"` | 只写（不存在则创建，存在则清空） |
| `"a"` | 追加（不存在则创建） |
| `"r+"` | 读写（文件必须存在） |
| `"w+"` | 读写（创建/清空） |
| `"rb"` / `"wb"` | 二进制读/写 |

---

## 文本文件读写

### 写文件

```c title="file_write.c"
#include <stdio.h>

int main(void)
{
    FILE *fp = fopen("output.txt", "w");
    if (!fp) { perror("fopen"); return 1; }
    
    fprintf(fp, "姓名: %s\n", "张三");
    fprintf(fp, "成绩: %d\n", 95);
    fputs("这是一行文本\n", fp);
    fputc('A', fp);
    
    fclose(fp);
    printf("写入完成\n");
    return 0;
}
```

### 读文件

```c title="file_read.c"
#include <stdio.h>

int main(void)
{
    FILE *fp = fopen("output.txt", "r");
    if (!fp) { perror("fopen"); return 1; }
    
    char line[256];
    while (fgets(line, sizeof(line), fp) != NULL) {
        printf("%s", line);
    }
    
    fclose(fp);
    return 0;
}
```

---

## 二进制文件读写

```c title="binary_io.c"
#include <stdio.h>

typedef struct {
    char name[20];
    int age;
    float score;
} Student;

int main(void)
{
    // 写入
    Student students[] = {
        {"张三", 20, 92.5},
        {"李四", 19, 88.0},
    };
    
    FILE *fp = fopen("students.dat", "wb");
    fwrite(students, sizeof(Student), 2, fp);
    fclose(fp);
    
    // 读取
    Student buf[2];
    fp = fopen("students.dat", "rb");
    fread(buf, sizeof(Student), 2, fp);
    fclose(fp);
    
    for (int i = 0; i < 2; i++) {
        printf("%s %d %.1f\n", buf[i].name, buf[i].age, buf[i].score);
    }
    
    return 0;
}
```

---

## 文件位置操作

```c
fseek(fp, 0, SEEK_SET);   // 回到文件开头
fseek(fp, 0, SEEK_END);   // 跳到文件末尾
long pos = ftell(fp);     // 获取当前位置
rewind(fp);               // 回到开头

// 获取文件大小
fseek(fp, 0, SEEK_END);
long size = ftell(fp);
rewind(fp);
```

---

## 嵌入式应用：配置文件解析

```c title="config_parser.c"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

typedef struct {
    char key[32];
    char value[64];
} Config;

int load_config(const char *filename, Config *cfg, int max)
{
    FILE *fp = fopen(filename, "r");
    if (!fp) return 0;
    
    char line[128];
    int count = 0;
    while (fgets(line, sizeof(line), fp) && count < max) {
        // 跳过注释和空行
        if (line[0] == '#' || line[0] == '\n') continue;
        
        char *eq = strchr(line, '=');
        if (eq) {
            *eq = '\0';
            strncpy(cfg[count].key, line, 31);
            strncpy(cfg[count].value, eq + 1, 63);
            // 去掉换行符
            char *nl = strchr(cfg[count].value, '\n');
            if (nl) *nl = '\0';
            count++;
        }
    }
    fclose(fp);
    return count;
}
```

---

## 练习题

### 练习 1

实现一个简单的学生成绩管理系统，支持保存到文件和从文件加载。

### 练习 2

统计一个文本文件的行数、单词数、字符数（类似 `wc` 命令）。

---

## 本课小结

| 函数 | 用途 |
|------|------|
| `fopen/fclose` | 打开/关闭 |
| `fprintf/fscanf` | 格式化读写 |
| `fgets/fputs` | 行读写 |
| `fread/fwrite` | 二进制读写 |
| `fseek/ftell` | 位置控制 |

> **下一课**：[预处理器](../23-preprocessor/README.md)
