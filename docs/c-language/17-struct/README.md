# 第 17 课：结构体

## 什么是结构体？

结构体是把**多个不同类型的数据**组合成一个整体。就像一张学生信息卡：

```c
struct Student {
    char name[20];
    int age;
    float score;
};
```

---

## 定义与使用

```c title="struct_basic.c"
#include <stdio.h>

// 定义结构体类型
struct Student {
    char name[20];
    int age;
    float score;
};

int main(void)
{
    // 声明并初始化
    struct Student s1 = {"张三", 20, 92.5};
    
    // 访问成员（用 . 运算符）
    printf("姓名: %s\n", s1.name);
    printf("年龄: %d\n", s1.age);
    printf("成绩: %.1f\n", s1.score);
    
    // 修改成员
    s1.age = 21;
    s1.score = 95.0;
    
    // 逐个赋值
    struct Student s2;
    strcpy(s2.name, "李四");  // 字符串不能直接用 = 赋值
    s2.age = 19;
    s2.score = 88.0;
    
    return 0;
}
```

### 用 typedef 简化

```c
typedef struct {
    char name[20];
    int age;
    float score;
} Student;

// 使用时不需要写 struct
Student s1 = {"张三", 20, 92.5};
```

---

## 结构体数组

```c title="struct_array.c"
#include <stdio.h>
#include <string.h>

typedef struct {
    char name[20];
    int age;
    float score;
} Student;

int main(void)
{
    Student class_a[] = {
        {"张三", 20, 92.5},
        {"李四", 19, 88.0},
        {"王五", 21, 95.5},
        {"赵六", 20, 78.0},
    };
    int n = sizeof(class_a) / sizeof(class_a[0]);
    
    // 打印所有学生
    printf("%-8s %4s %6s\n", "姓名", "年龄", "成绩");
    printf("--------------------\n");
    for (int i = 0; i < n; i++) {
        printf("%-8s %4d %6.1f\n", class_a[i].name, class_a[i].age, class_a[i].score);
    }
    
    // 找最高分
    int max_idx = 0;
    for (int i = 1; i < n; i++) {
        if (class_a[i].score > class_a[max_idx].score) {
            max_idx = i;
        }
    }
    printf("最高分: %s %.1f\n", class_a[max_idx].name, class_a[max_idx].score);
    
    return 0;
}
```

---

## 嵌套结构体

```c
typedef struct {
    int year, month, day;
} Date;

typedef struct {
    char name[20];
    Date birthday;     // 嵌套结构体
    float score;
} Student;

Student s = {"张三", {2004, 3, 15}, 92.5};
printf("生日: %d-%d-%d\n", s.birthday.year, s.birthday.month, s.birthday.day);
```

---

## 结构体作为函数参数

```c
// 值传递（复制整个结构体，效率低）
void print_student(Student s) {
    printf("%s %d %.1f\n", s.name, s.age, s.score);
}

// 指针传递（推荐，效率高）
void print_student_ptr(const Student *s) {
    printf("%s %d %.1f\n", s->name, s->age, s->score);
}

// s.member    用于结构体变量
// s->member   用于结构体指针（等价于 (*s).member）
```

---

## 嵌入式应用：传感器数据

```c title="sensor.c"
#include <stdio.h>
#include <stdint.h>

typedef struct {
    uint16_t id;
    char type[20];
    float value;
    uint8_t status;  // 0:正常 1:异常
} SensorData;

void print_sensor(const SensorData *s)
{
    printf("ID:%04X  %-12s  值:%.2f  状态:%s\n",
           s->id, s->type, s->value,
           s->status == 0 ? "正常" : "异常");
}

int main(void)
{
    SensorData sensors[] = {
        {0x0001, "温度传感器", 25.6, 0},
        {0x0002, "湿度传感器", 65.3, 0},
        {0x0003, "压力传感器", -1.0, 1},
    };
    
    for (int i = 0; i < 3; i++) {
        print_sensor(&sensors[i]);
    }
    
    return 0;
}
```

---

## 练习题

### 练习 1：通讯录

定义 `Contact` 结构体（姓名、电话、邮箱），实现添加和显示功能。

### 练习 2：结构体排序

对学生数组按成绩从高到低排序。

??? note "参考答案"
    ```c
    void sort_students(Student arr[], int n) {
        for (int i = 0; i < n-1; i++) {
            for (int j = 0; j < n-1-i; j++) {
                if (arr[j].score < arr[j+1].score) {
                    Student temp = arr[j];
                    arr[j] = arr[j+1];
                    arr[j+1] = temp;
                }
            }
        }
    }
    ```

---

## 本课小结

| 知识点 | 说明 |
|--------|------|
| `struct` | 把多种类型组合成一个类型 |
| `.` 运算符 | 结构体变量访问成员 |
| `->` 运算符 | 结构体指针访问成员 |
| `typedef` | 给结构体起别名 |
| 函数参数 | 用指针传递，加 `const` 保护 |

> **下一课**：[结构体与指针](../18-struct-pointer/README.md) —— 链表初步与内存对齐
