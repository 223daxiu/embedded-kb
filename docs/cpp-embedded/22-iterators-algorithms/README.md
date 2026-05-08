# 第 22 课：迭代器与算法

## 迭代器

迭代器是**容器和算法之间的桥梁**：

```cpp
std::vector<int> v = {5, 2, 8, 1, 9};

auto it = v.begin();   // 指向第一个元素
auto end = v.end();    // 指向最后一个的下一位

while (it != end) {
    std::cout << *it << " ";
    ++it;
}
```

### 反向迭代器

```cpp
for (auto rit = v.rbegin(); rit != v.rend(); ++rit) {
    std::cout << *rit << " ";  // 9 1 8 2 5
}
```

---

## 常用算法

```cpp
#include <algorithm>
#include <numeric>

std::vector<int> v = {5, 2, 8, 1, 9, 3};

// 排序
std::sort(v.begin(), v.end());          // 升序
std::sort(v.begin(), v.end(), std::greater<int>());  // 降序

// 查找
auto it = std::find(v.begin(), v.end(), 8);
if (it != v.end()) std::cout << "找到: " << *it << std::endl;

// 计数
int cnt = std::count(v.begin(), v.end(), 5);

// 最值
auto [min_it, max_it] = std::minmax_element(v.begin(), v.end());

// 累加
int sum = std::accumulate(v.begin(), v.end(), 0);

// 变换
std::transform(v.begin(), v.end(), v.begin(),
               [](int x) { return x * 2; });

// 遍历
std::for_each(v.begin(), v.end(),
              [](int x) { std::cout << x << " "; });

// 去重（需先排序）
std::sort(v.begin(), v.end());
auto last = std::unique(v.begin(), v.end());
v.erase(last, v.end());

// 复制
std::vector<int> dst(v.size());
std::copy(v.begin(), v.end(), dst.begin());

// 填充
std::fill(v.begin(), v.end(), 0);

// 是否有满足条件的元素
bool has_even = std::any_of(v.begin(), v.end(), [](int x) { return x % 2 == 0; });
bool all_pos = std::all_of(v.begin(), v.end(), [](int x) { return x > 0; });
```

---

## 自定义排序

```cpp
struct Student {
    std::string name;
    int score;
};

std::vector<Student> students = {{"张三", 85}, {"李四", 92}, {"王五", 78}};

// 按成绩降序
std::sort(students.begin(), students.end(),
          [](const Student &a, const Student &b) {
              return a.score > b.score;
          });
```

---

## 练习题

### 练习 1：去重排序

**要求**：

- 定义一个包含重复元素的 `vector<int>`
- 用 `std::sort` + `std::unique` + `erase` 去重排序
- 打印去重前后的内容

??? note "参考答案"

    ```cpp title="exercise01.cpp"
    #include <iostream>
    #include <vector>
    #include <algorithm>

    void print_vec(const std::string &label, const std::vector<int> &v) {
        std::cout << label << ": [";
        for (size_t i = 0; i < v.size(); i++) {
            if (i > 0) std::cout << ", ";
            std::cout << v[i];
        }
        std::cout << "] (size=" << v.size() << ")" << std::endl;
    }

    int main()
    {
        std::vector<int> v = {5, 3, 8, 3, 1, 9, 5, 2, 8, 1, 7, 3};
        print_vec("原始数组", v);

        // 排序
        std::sort(v.begin(), v.end());
        print_vec("排序后  ", v);

        // 去重
        auto last = std::unique(v.begin(), v.end());
        v.erase(last, v.end());
        print_vec("去重后  ", v);

        return 0;
    }
    ```

    **预期输出**：
    ```
    原始数组: [5, 3, 8, 3, 1, 9, 5, 2, 8, 1, 7, 3] (size=12)
    排序后  : [1, 1, 2, 3, 3, 3, 5, 5, 7, 8, 8, 9] (size=12)
    去重后  : [1, 2, 3, 5, 7, 8, 9] (size=7)
    ```

### 练习 2：奇偶分区

**要求**：

- 用 `std::partition` 将 vector 分为奇数在前、偶数在后
- 打印分区后的数组
- 打印奇数部分和偶数部分的个数

??? note "参考答案"

    ```cpp title="exercise02.cpp"
    #include <iostream>
    #include <vector>
    #include <algorithm>

    int main()
    {
        std::vector<int> v = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};

        std::cout << "原始: ";
        for (int x : v) std::cout << x << " ";
        std::cout << std::endl;

        // 分区：奇数在前
        auto mid = std::partition(v.begin(), v.end(), [](int x) { return x % 2 != 0; });

        std::cout << "分区后: ";
        for (int x : v) std::cout << x << " ";
        std::cout << std::endl;

        int odd_count = std::distance(v.begin(), mid);
        int even_count = std::distance(mid, v.end());

        std::cout << "奇数个数: " << odd_count << std::endl;
        std::cout << "偶数个数: " << even_count << std::endl;

        // 分别排序
        std::sort(v.begin(), mid);
        std::sort(mid, v.end());

        std::cout << "各自排序: ";
        for (int x : v) std::cout << x << " ";
        std::cout << std::endl;

        return 0;
    }
    ```

    **预期输出**（partition 不保证相对顺序）：
    ```
    原始: 1 2 3 4 5 6 7 8 9 10
    分区后: 1 9 3 7 5 6 4 8 2 10
    奇数个数: 5
    偶数个数: 5
    各自排序: 1 3 5 7 9 2 4 6 8 10
    ```

---

> **下一课**：[关联容器与哈希](../23-associative-containers/README.md)
