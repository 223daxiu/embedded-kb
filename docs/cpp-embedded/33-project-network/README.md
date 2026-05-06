# 第 33 课：项目实战 — 网络通信库

## 项目目标

封装 POSIX Socket API，实现一个简洁的 TCP 通信库。

---

## Socket 封装

```cpp
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <string>
#include <stdexcept>
#include <cstring>

class Socket {
    int fd_ = -1;
public:
    Socket() : fd_(::socket(AF_INET, SOCK_STREAM, 0)) {
        if (fd_ < 0) throw std::runtime_error("socket 创建失败");
    }
    
    explicit Socket(int fd) : fd_(fd) {}
    
    ~Socket() { if (fd_ >= 0) ::close(fd_); }
    
    // 移动语义
    Socket(Socket &&other) noexcept : fd_(other.fd_) { other.fd_ = -1; }
    Socket& operator=(Socket &&other) noexcept {
        if (this != &other) {
            if (fd_ >= 0) ::close(fd_);
            fd_ = other.fd_;
            other.fd_ = -1;
        }
        return *this;
    }
    
    // 禁止拷贝
    Socket(const Socket&) = delete;
    Socket& operator=(const Socket&) = delete;
    
    int fd() const { return fd_; }
    
    void set_reuse_addr() {
        int opt = 1;
        setsockopt(fd_, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt));
    }
};
```

---

## TCP Server

```cpp
class TcpServer {
    Socket listen_sock_;
    
public:
    void bind(uint16_t port) {
        listen_sock_.set_reuse_addr();
        
        sockaddr_in addr{};
        addr.sin_family = AF_INET;
        addr.sin_addr.s_addr = INADDR_ANY;
        addr.sin_port = htons(port);
        
        if (::bind(listen_sock_.fd(), (sockaddr*)&addr, sizeof(addr)) < 0)
            throw std::runtime_error("bind 失败");
    }
    
    void listen(int backlog = 128) {
        if (::listen(listen_sock_.fd(), backlog) < 0)
            throw std::runtime_error("listen 失败");
    }
    
    Socket accept() {
        sockaddr_in client_addr{};
        socklen_t len = sizeof(client_addr);
        int fd = ::accept(listen_sock_.fd(), (sockaddr*)&client_addr, &len);
        if (fd < 0) throw std::runtime_error("accept 失败");
        return Socket(fd);
    }
};
```

---

## TCP Client

```cpp
class TcpClient {
    Socket sock_;
    
public:
    void connect(const std::string &ip, uint16_t port) {
        sockaddr_in addr{};
        addr.sin_family = AF_INET;
        addr.sin_port = htons(port);
        inet_pton(AF_INET, ip.c_str(), &addr.sin_addr);
        
        if (::connect(sock_.fd(), (sockaddr*)&addr, sizeof(addr)) < 0)
            throw std::runtime_error("connect 失败");
    }
    
    void send(const std::string &data) {
        ::send(sock_.fd(), data.c_str(), data.size(), 0);
    }
    
    std::string recv(size_t max_len = 4096) {
        std::string buf(max_len, '\0');
        ssize_t n = ::recv(sock_.fd(), buf.data(), max_len, 0);
        if (n <= 0) return "";
        buf.resize(n);
        return buf;
    }
};
```

---

## Echo Server 示例

```cpp
#include <thread>
#include <iostream>

void handle_client(Socket client) {
    char buf[1024];
    while (true) {
        ssize_t n = ::recv(client.fd(), buf, sizeof(buf), 0);
        if (n <= 0) break;
        ::send(client.fd(), buf, n, 0);  // 原样回发
    }
}

int main() {
    TcpServer server;
    server.bind(8080);
    server.listen();
    std::cout << "Echo server listening on :8080\n";
    
    while (true) {
        Socket client = server.accept();
        std::thread(handle_client, std::move(client)).detach();
    }
}
```

---

## 知识点总结

| 技术 | 应用 |
|------|------|
| RAII | Socket 自动关闭 |
| 移动语义 | Socket 所有权转移 |
| 多线程 | 并发处理客户端 |
| 异常处理 | 网络错误处理 |

---

## 练习题

### 练习

在此基础上增加：简单的 HTTP 请求解析（解析 GET 请求的 URL 路径）。

---

> **下一课**：[项目实战：驱动框架](../34-project-driver-framework/README.md)
