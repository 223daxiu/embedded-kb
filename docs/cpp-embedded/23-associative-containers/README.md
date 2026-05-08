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

### 练习 1：单词频率统计

**要求**：

- 定义一段英文文本字符串
- 用 `istringstream` 拆分单词，用 `unordered_map` 统计频率
- 按频率降序输出结果

??? note "参考答案"

    ```cpp title="exercise01.cpp"
    #include <iostream>
    #include <string>
    #include <sstream>
    #include <unordered_map>
    #include <vector>
    #include <algorithm>

    int main()
    {
        std::string text = "the cat sat on the mat and the cat ate the rat";
        std::cout << "文本: " << text << std::endl;

        // 统计频率
        std::unordered_map<std::string, int> freq;
        std::istringstream iss(text);
        std::string word;
        while (iss >> word) {
            freq[word]++;
        }

        // 按频率降序排序
        std::vector<std::pair<std::string, int>> sorted(freq.begin(), freq.end());
        std::sort(sorted.begin(), sorted.end(),
                  [](const auto &a, const auto &b) { return a.second > b.second; });

        // 输出
        std::cout << "\n单词频率统计:" << std::endl;
        for (const auto &[w, c] : sorted) {
            std::cout << "  " << w << ": " << c << " 次" << std::endl;
        }

        return 0;
    }
    ```

    **预期输出**：
    ```
    文本: the cat sat on the mat and the cat ate the rat

    单词频率统计:
      the: 4 次
      cat: 2 次
      sat: 1 次
      on: 1 次
      mat: 1 次
      and: 1 次
      ate: 1 次
      rat: 1 次
    ```

### 练习 2：集合运算

**要求**：

- 定义两个 `set<int>` 集合 A 和 B
- 用 `std::set_intersection`、`std::set_union`、`std::set_difference` 计算交集、并集、差集
- 打印每种运算的结果

??? note "参考答案"

    ```cpp title="exercise02.cpp"
    #include <iostream>
    #include <set>
    #include <vector>
    #include <algorithm>
    #include <iterator>

    void print_set(const std::string &label, const std::vector<int> &v) {
        std::cout << label << ": {";
        for (size_t i = 0; i < v.size(); i++) {
            if (i > 0) std::cout << ", ";
            std::cout << v[i];
        }
        std::cout << "}" << std::endl;
    }

    int main()
    {
        std::set<int> A = {1, 2, 3, 4, 5, 6};
        std::set<int> B = {4, 5, 6, 7, 8, 9};

        std::cout << "A = {1,2,3,4,5,6}" << std::endl;
        std::cout << "B = {4,5,6,7,8,9}" << std::endl;
        std::cout << std::endl;

        // 交集
        std::vector<int> inter;
        std::set_intersection(A.begin(), A.end(), B.begin(), B.end(),
                              std::back_inserter(inter));
        print_set("A ∩ B", inter);

        // 并集
        std::vector<int> uni;
        std::set_union(A.begin(), A.end(), B.begin(), B.end(),
                       std::back_inserter(uni));
        print_set("A ∪ B", uni);

        // 差集
        std::vector<int> diff;
        std::set_difference(A.begin(), A.end(), B.begin(), B.end(),
                            std::back_inserter(diff));
        print_set("A - B", diff);

        return 0;
    }
    ```

    **预期输出**：
    ```
    A = {1,2,3,4,5,6}
    B = {4,5,6,7,8,9}

    A ∩ B: {4, 5, 6}
    A ∪ B: {1, 2, 3, 4, 5, 6, 7, 8, 9}
    A - B: {1, 2, 3}
    ```

---

> **下一课**：[Lambda 与函数对象](../24-lambda-functor/README.md)
