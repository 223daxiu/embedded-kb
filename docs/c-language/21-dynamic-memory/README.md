# 第 21 课：动态内存实战

## 动态字符串

```c title="dynamic_string.c"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// 动态复制字符串
char *my_strdup(const char *s)
{
    char *copy = (char *)malloc(strlen(s) + 1);
    if (copy == NULL) return NULL;
    strcpy(copy, s);
    return copy;
}

int main(void)
{
    char *name = my_strdup("嵌入式开发");
    if (name) {
        printf("复制: %s\n", name);
        free(name);
    }
    return 0;
}
```

---

## 动态二维数组

```c title="dynamic_2d_array.c"
#include <stdio.h>
#include <stdlib.h>

int **create_matrix(int rows, int cols)
{
    int **matrix = (int **)malloc(rows * sizeof(int *));
    if (!matrix) return NULL;
    
    for (int i = 0; i < rows; i++) {
        matrix[i] = (int *)calloc(cols, sizeof(int));
        if (!matrix[i]) {
            // 分配失败，释放已分配的行
            for (int j = 0; j < i; j++) free(matrix[j]);
            free(matrix);
            return NULL;
        }
    }
    return matrix;
}

void free_matrix(int **matrix, int rows)
{
    for (int i = 0; i < rows; i++) {
        free(matrix[i]);
    }
    free(matrix);
}

int main(void)
{
    int rows = 3, cols = 4;
    int **m = create_matrix(rows, cols);
    if (!m) return 1;
    
    // 填充
    int val = 1;
    for (int i = 0; i < rows; i++)
        for (int j = 0; j < cols; j++)
            m[i][j] = val++;
    
    // 打印
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++)
            printf("%3d", m[i][j]);
        printf("\n");
    }
    
    free_matrix(m, rows);
    return 0;
}
```

---

## 动态链表（完整实现）

```c title="linked_list.c"
#include <stdio.h>
#include <stdlib.h>

typedef struct Node {
    int data;
    struct Node *next;
} Node;

// 头插法
Node *list_push(Node *head, int data)
{
    Node *new_node = (Node *)malloc(sizeof(Node));
    if (!new_node) return head;
    new_node->data = data;
    new_node->next = head;
    return new_node;
}

// 尾插法
Node *list_append(Node *head, int data)
{
    Node *new_node = (Node *)malloc(sizeof(Node));
    if (!new_node) return head;
    new_node->data = data;
    new_node->next = NULL;
    
    if (head == NULL) return new_node;
    
    Node *cur = head;
    while (cur->next) cur = cur->next;
    cur->next = new_node;
    return head;
}

// 打印
void list_print(Node *head)
{
    Node *cur = head;
    while (cur) {
        printf("%d → ", cur->data);
        cur = cur->next;
    }
    printf("NULL\n");
}

// 释放整个链表
void list_free(Node *head)
{
    while (head) {
        Node *tmp = head;
        head = head->next;
        free(tmp);
    }
}

int main(void)
{
    Node *list = NULL;
    list = list_append(list, 10);
    list = list_append(list, 20);
    list = list_append(list, 30);
    list = list_push(list, 5);
    
    list_print(list);  // 5 → 10 → 20 → 30 → NULL
    list_free(list);
    return 0;
}
```

---

## 练习题

### 练习 1

实现链表删除指定值节点的函数。

### 练习 2

实现一个动态数组（类似 C++ 的 vector），支持自动扩容。

??? note "参考答案"
    ```c
    typedef struct {
        int *data;
        int size;
        int capacity;
    } Vector;
    
    Vector *vec_create(int cap) {
        Vector *v = malloc(sizeof(Vector));
        v->data = malloc(cap * sizeof(int));
        v->size = 0;
        v->capacity = cap;
        return v;
    }
    
    void vec_push(Vector *v, int val) {
        if (v->size >= v->capacity) {
            v->capacity *= 2;
            v->data = realloc(v->data, v->capacity * sizeof(int));
        }
        v->data[v->size++] = val;
    }
    
    void vec_free(Vector *v) {
        free(v->data);
        free(v);
    }
    ```

---

> **下一课**：[文件操作](../22-file-io/README.md)
