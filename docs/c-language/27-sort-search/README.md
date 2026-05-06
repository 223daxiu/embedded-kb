# 第 27 课：排序与查找算法

## 排序算法对比

| 算法 | 时间复杂度（平均） | 空间 | 稳定性 |
|------|-------------------|------|--------|
| 冒泡排序 | O(n²) | O(1) | 稳定 |
| 选择排序 | O(n²) | O(1) | 不稳定 |
| 插入排序 | O(n²) | O(1) | 稳定 |
| 快速排序 | O(n log n) | O(log n) | 不稳定 |

---

## 冒泡排序

```c
void bubble_sort(int arr[], int n)
{
    for (int i = 0; i < n - 1; i++) {
        int swapped = 0;
        for (int j = 0; j < n - 1 - i; j++) {
            if (arr[j] > arr[j + 1]) {
                int tmp = arr[j];
                arr[j] = arr[j + 1];
                arr[j + 1] = tmp;
                swapped = 1;
            }
        }
        if (!swapped) break;  // 已有序，提前结束
    }
}
```

## 选择排序

```c
void selection_sort(int arr[], int n)
{
    for (int i = 0; i < n - 1; i++) {
        int min_idx = i;
        for (int j = i + 1; j < n; j++) {
            if (arr[j] < arr[min_idx]) min_idx = j;
        }
        if (min_idx != i) {
            int tmp = arr[i];
            arr[i] = arr[min_idx];
            arr[min_idx] = tmp;
        }
    }
}
```

## 插入排序

```c
void insertion_sort(int arr[], int n)
{
    for (int i = 1; i < n; i++) {
        int key = arr[i];
        int j = i - 1;
        while (j >= 0 && arr[j] > key) {
            arr[j + 1] = arr[j];
            j--;
        }
        arr[j + 1] = key;
    }
}
```

## 快速排序

```c
void quick_sort(int arr[], int left, int right)
{
    if (left >= right) return;
    
    int pivot = arr[left];
    int i = left, j = right;
    
    while (i < j) {
        while (i < j && arr[j] >= pivot) j--;
        arr[i] = arr[j];
        while (i < j && arr[i] <= pivot) i++;
        arr[j] = arr[i];
    }
    arr[i] = pivot;
    
    quick_sort(arr, left, i - 1);
    quick_sort(arr, i + 1, right);
}
```

---

## 查找算法

### 线性查找 O(n)

```c
int linear_search(int arr[], int n, int target)
{
    for (int i = 0; i < n; i++) {
        if (arr[i] == target) return i;
    }
    return -1;
}
```

### 二分查找 O(log n)

```c
// 前提：数组已排序
int binary_search(int arr[], int n, int target)
{
    int left = 0, right = n - 1;
    while (left <= right) {
        int mid = left + (right - left) / 2;
        if (arr[mid] == target) return mid;
        else if (arr[mid] < target) left = mid + 1;
        else right = mid - 1;
    }
    return -1;
}
```

---

## 使用 qsort（标准库）

```c title="qsort_example.c"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// 比较函数：升序
int cmp_int(const void *a, const void *b)
{
    return (*(int *)a) - (*(int *)b);
}

// 按字符串排序
int cmp_str(const void *a, const void *b)
{
    return strcmp(*(const char **)a, *(const char **)b);
}

int main(void)
{
    int arr[] = {5, 2, 8, 1, 9, 3};
    int n = sizeof(arr) / sizeof(arr[0]);
    
    qsort(arr, n, sizeof(int), cmp_int);
    
    for (int i = 0; i < n; i++)
        printf("%d ", arr[i]);  // 1 2 3 5 8 9
    printf("\n");
    
    return 0;
}
```

---

## 练习题

### 练习 1

手写快速排序，测试 10 个随机数。

### 练习 2

用二分查找在有序数组中找目标值，找不到时返回应该插入的位置。

---

> **下一课**：[链表进阶](../28-linked-list/README.md)
