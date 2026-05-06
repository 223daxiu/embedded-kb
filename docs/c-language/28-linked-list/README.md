# 第 28 课：链表进阶

## 单链表完整实现

```c title="singly_linked_list.c"
#include <stdio.h>
#include <stdlib.h>

typedef struct Node {
    int data;
    struct Node *next;
} Node;

typedef struct {
    Node *head;
    int size;
} LinkedList;

// 初始化
void list_init(LinkedList *list) {
    list->head = NULL;
    list->size = 0;
}

// 头插
void list_push_front(LinkedList *list, int val) {
    Node *node = (Node *)malloc(sizeof(Node));
    node->data = val;
    node->next = list->head;
    list->head = node;
    list->size++;
}

// 尾插
void list_push_back(LinkedList *list, int val) {
    Node *node = (Node *)malloc(sizeof(Node));
    node->data = val;
    node->next = NULL;
    
    if (!list->head) {
        list->head = node;
    } else {
        Node *cur = list->head;
        while (cur->next) cur = cur->next;
        cur->next = node;
    }
    list->size++;
}

// 删除指定值
void list_remove(LinkedList *list, int val) {
    Node **pp = &list->head;
    while (*pp) {
        if ((*pp)->data == val) {
            Node *tmp = *pp;
            *pp = (*pp)->next;
            free(tmp);
            list->size--;
            return;
        }
        pp = &(*pp)->next;
    }
}

// 反转
void list_reverse(LinkedList *list) {
    Node *prev = NULL, *cur = list->head, *next;
    while (cur) {
        next = cur->next;
        cur->next = prev;
        prev = cur;
        cur = next;
    }
    list->head = prev;
}

// 打印
void list_print(LinkedList *list) {
    Node *cur = list->head;
    while (cur) {
        printf("%d → ", cur->data);
        cur = cur->next;
    }
    printf("NULL (size=%d)\n", list->size);
}

// 释放
void list_free(LinkedList *list) {
    Node *cur = list->head;
    while (cur) {
        Node *tmp = cur;
        cur = cur->next;
        free(tmp);
    }
    list->head = NULL;
    list->size = 0;
}

int main(void)
{
    LinkedList list;
    list_init(&list);
    
    list_push_back(&list, 10);
    list_push_back(&list, 20);
    list_push_back(&list, 30);
    list_push_front(&list, 5);
    list_print(&list);  // 5 → 10 → 20 → 30 → NULL
    
    list_remove(&list, 20);
    list_print(&list);  // 5 → 10 → 30 → NULL
    
    list_reverse(&list);
    list_print(&list);  // 30 → 10 → 5 → NULL
    
    list_free(&list);
    return 0;
}
```

---

## 双向链表

```c
typedef struct DNode {
    int data;
    struct DNode *prev;
    struct DNode *next;
} DNode;

// 双向链表插入到尾部
void dlist_append(DNode **head, int val) {
    DNode *node = (DNode *)malloc(sizeof(DNode));
    node->data = val;
    node->next = NULL;
    
    if (!*head) {
        node->prev = NULL;
        *head = node;
    } else {
        DNode *cur = *head;
        while (cur->next) cur = cur->next;
        cur->next = node;
        node->prev = cur;
    }
}
```

---

## 练习题

### 练习 1

实现链表排序（可以用冒泡排序的思路）。

### 练习 2

判断链表是否有环（快慢指针法）。

??? note "参考答案"
    ```c
    int has_cycle(Node *head) {
        Node *slow = head, *fast = head;
        while (fast && fast->next) {
            slow = slow->next;
            fast = fast->next->next;
            if (slow == fast) return 1;  // 有环
        }
        return 0;
    }
    ```

---

> **下一课**：[哈希表](../29-hash-table/README.md)
