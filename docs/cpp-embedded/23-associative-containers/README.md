# 第 23 课：关联容器与哈希

## map（有序键值对）

```cpp
#include <map>

std::map<std::string, int> scores;

// 插入
scores["张三"] = 85;
scores["李四"] = 92;
scores.insert({"王五", 78});

// 查找
if (scores.count("张三")) {
    std::cout << scores["张三"] << std::endl;
}

auto it = scores.find("李四");
if (it != scores.end()) {
    std::cout << it->first << ": " << it->second << std::endl;
}

// 遍历（按键排序）
for (const auto &[name, score] : scores) {  // C++17 结构化绑定
    std::cout << name << " → " << score << std::endl;
}

// 删除
scores.erase("王五");
```

---

## set（有序集合）

```cpp
#include <set>

std::set<int> s = {5, 2, 8, 2, 1};  // 自动去重排序
// s = {1, 2, 5, 8}

s.insert(3);
s.erase(2);

if (s.count(5)) std::cout << "5 存在" << std::endl;
```

---

## unordered_map（哈希表，O(1) 查找）

```cpp
#include <unordered_map>

std::unordered_map<std::string, int> dict;
dict["apple"] = 5;
dict["banana"] = 3;

// 与 map 接口相同，但无序，更快
for (const auto &[k, v] : dict) {
    std::cout << k << ": " << v << std::endl;
}
```

---

## 容器对比

| 容器 | 底层 | 查找 | 插入 | 有序 |
|------|------|------|------|------|
| `map` | 红黑树 | O(log n) | O(log n) | ✅ |
| `set` | 红黑树 | O(log n) | O(log n) | ✅ |
| `unordered_map` | 哈希表 | O(1) | O(1) | ❌ |
| `unordered_set` | 哈希表 | O(1) | O(1) | ❌ |

---

## multimap / multiset

允许重复键：

```cpp
std::multimap<std::string, int> grades;
grades.insert({"张三", 85});
grades.insert({"张三", 90});  // 同一个键可以有多个值

auto range = grades.equal_range("张三");
for (auto it = range.first; it != range.second; ++it) {
    std::cout << it->second << std::endl;  // 85, 90
}
```

---

## 练习题

### 练习 1

用 `unordered_map` 统计一段文本中每个单词的出现频率。

### 练习 2

用 `set` 实现集合运算（交集、并集、差集）。

---

> **下一课**：[Lambda 与函数对象](../24-lambda-functor/README.md)
