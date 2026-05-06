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

### 练习 1

用多线程并行计算 1 到 1000000 的和（分段累加再汇总）。

### 练习 2

实现生产者-消费者模型：多个生产者、多个消费者共享一个线程安全队列。

---

> **下一课**：[设计模式](../29-design-patterns/README.md)
