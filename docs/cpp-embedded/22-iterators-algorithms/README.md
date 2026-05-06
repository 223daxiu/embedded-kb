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

### 练习 1

用 STL 算法实现：输入一组数，去重排序后输出。

### 练习 2

用 `std::partition` 将数组分为奇数和偶数两部分。

---

> **下一课**：[关联容器与哈希](../23-associative-containers/README.md)
