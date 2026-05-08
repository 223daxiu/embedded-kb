# 第 28 课：多线程编程

## 创建线程

```cpp
#include <thread>
#include <iostream>

void task(int id) {
    std::cout << "线程 " << id << " 运行中\n";
}

int main() {
    std::thread t1(task, 1);
    std::thread t2(task, 2);
    
    t1.join();   // 等待 t1 完成
    t2.join();   // 等待 t2 完成
    
    return 0;
}
// 编译：g++ -std=c++17 -pthread main.cpp
```

---

## 互斥锁 mutex

```cpp
#include <mutex>

int counter = 0;
std::mutex mtx;

void increment(int times) {
    for (int i = 0; i < times; i++) {
        std::lock_guard<std::mutex> lock(mtx);  // RAII 自动加解锁
        counter++;
    }
}

int main() {
    std::thread t1(increment, 100000);
    std::thread t2(increment, 100000);
    t1.join();
    t2.join();
    std::cout << counter << std::endl;  // 200000（正确）
}
```

---

## unique_lock（灵活锁）

```cpp
std::mutex mtx;
std::unique_lock<std::mutex> lock(mtx);
// 可以手动 unlock/lock
lock.unlock();
// ... 做一些不需要锁的事 ...
lock.lock();
```

---

## 条件变量

```cpp
#include <condition_variable>
#include <queue>

std::queue<int> q;
std::mutex mtx;
std::condition_variable cv;

void producer() {
    for (int i = 0; i < 10; i++) {
        {
            std::lock_guard<std::mutex> lock(mtx);
            q.push(i);
        }
        cv.notify_one();  // 通知消费者
    }
}

void consumer() {
    for (int i = 0; i < 10; i++) {
        std::unique_lock<std::mutex> lock(mtx);
        cv.wait(lock, [] { return !q.empty(); });  // 等待直到队列非空
        int val = q.front();
        q.pop();
        std::cout << "消费: " << val << std::endl;
    }
}

int main() {
    std::thread p(producer);
    std::thread c(consumer);
    p.join();
    c.join();
}
```

---

## 原子操作

```cpp
#include <atomic>

std::atomic<int> counter{0};

void increment(int times) {
    for (int i = 0; i < times; i++) {
        counter.fetch_add(1, std::memory_order_relaxed);
    }
}
// 无需 mutex，硬件保证原子性
```

---

## async 与 future

```cpp
#include <future>

int compute(int x) {
    return x * x;
}

auto fut = std::async(std::launch::async, compute, 42);
int result = fut.get();  // 阻塞等待结果
std::cout << result << std::endl;  // 1764
```

---

## 线程安全队列（实战）

```cpp
template <typename T>
class ThreadSafeQueue {
    std::queue<T> queue_;
    mutable std::mutex mutex_;
    std::condition_variable cv_;

public:
    void push(T value) {
        {
            std::lock_guard<std::mutex> lock(mutex_);
            queue_.push(std::move(value));
        }
        cv_.notify_one();
    }

    T pop() {
        std::unique_lock<std::mutex> lock(mutex_);
        cv_.wait(lock, [this] { return !queue_.empty(); });
        T value = std::move(queue_.front());
        queue_.pop();
        return value;
    }

    bool empty() const {
        std::lock_guard<std::mutex> lock(mutex_);
        return queue_.empty();
    }
};
```

---

## 练习题

### 练习 1：多线程并行求和

**要求**：

- 将 1 到 1000000 分成 4 段，每个线程累加一段
- 用 `std::thread` 创建 4 个线程并行计算
- 汇总结果并验证正确性
- 打印每个线程的部分和

??? note "参考答案"

    ```cpp title="exercise01.cpp"
    #include <iostream>
    #include <thread>
    #include <vector>

    void partial_sum(int start, int end, long long &result) {
        long long sum = 0;
        for (int i = start; i <= end; i++) sum += i;
        result = sum;
    }

    int main()
    {
        const int N = 1000000;
        const int NUM_THREADS = 4;
        int chunk = N / NUM_THREADS;

        std::vector<std::thread> threads;
        std::vector<long long> results(NUM_THREADS, 0);

        // 创建线程
        for (int i = 0; i < NUM_THREADS; i++) {
            int start = i * chunk + 1;
            int end = (i == NUM_THREADS - 1) ? N : (i + 1) * chunk;
            threads.emplace_back(partial_sum, start, end, std::ref(results[i]));
        }

        // 等待所有线程完成
        for (auto &t : threads) t.join();

        // 汇总
        long long total = 0;
        for (int i = 0; i < NUM_THREADS; i++) {
            std::cout << "线程 " << i << " 结果: " << results[i] << std::endl;
            total += results[i];
        }

        std::cout << "\n总和: " << total << std::endl;
        std::cout << "验证: " << (long long)N * (N + 1) / 2
                  << (total == (long long)N * (N + 1) / 2 ? " ✓ 正确" : " ✗ 错误")
                  << std::endl;

        return 0;
    }
    ```

    **预期输出**：
    ```
    线程 0 结果: 31250125000
    线程 1 结果: 93750125000
    线程 2 结果: 156250125000
    线程 3 结果: 218750125000

    总和: 500000500000
    验证: 500000500000 ✓ 正确
    ```

### 练习 2：生产者-消费者

**要求**：

- 实现线程安全队列（`mutex` + `condition_variable`）
- 2 个生产者线程各生产 5 个数据
- 1 个消费者线程消费所有 10 个数据
- 打印每次生产和消费的操作

??? note "参考答案"

    ```cpp title="exercise02.cpp"
    #include <iostream>
    #include <thread>
    #include <mutex>
    #include <condition_variable>
    #include <queue>

    std::queue<int> buffer;
    std::mutex mtx;
    std::condition_variable cv;
    bool done = false;

    void producer(int id, int count) {
        for (int i = 0; i < count; i++) {
            int item = id * 100 + i;
            {
                std::lock_guard<std::mutex> lock(mtx);
                buffer.push(item);
                std::cout << "生产者" << id << " 生产: " << item << std::endl;
            }
            cv.notify_one();
        }
    }

    void consumer(int total) {
        int consumed = 0;
        while (consumed < total) {
            std::unique_lock<std::mutex> lock(mtx);
            cv.wait(lock, [] { return !buffer.empty(); });

            int item = buffer.front();
            buffer.pop();
            consumed++;
            std::cout << "  消费者 消费: " << item
                      << " (已消费 " << consumed << "/" << total << ")" << std::endl;
        }
    }

    int main()
    {
        const int ITEMS_PER_PRODUCER = 5;
        const int NUM_PRODUCERS = 2;

        std::thread c(consumer, NUM_PRODUCERS * ITEMS_PER_PRODUCER);
        std::thread p1(producer, 1, ITEMS_PER_PRODUCER);
        std::thread p2(producer, 2, ITEMS_PER_PRODUCER);

        p1.join();
        p2.join();
        c.join();

        std::cout << "\n所有生产和消费完成" << std::endl;
        return 0;
    }
    ```

    **预期输出**（顺序可能不同）：
    ```
    生产者1 生产: 100
      消费者 消费: 100 (已消费 1/10)
    生产者2 生产: 200
    生产者1 生产: 101
      消费者 消费: 200 (已消费 2/10)
    ...
    所有生产和消费完成
    ```

---

> **下一课**：[设计模式](../29-design-patterns/README.md)
