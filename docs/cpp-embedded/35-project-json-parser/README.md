# 第 35 课：项目实战 — JSON 解析器

## 项目目标

用 C++17 实现一个完整的 JSON 解析器，支持解析和序列化。

---

## JSON 值类型

```cpp
#include <variant>
#include <string>
#include <vector>
#include <unordered_map>
#include <memory>

class JsonValue;
using JsonObject = std::unordered_map<std::string, JsonValue>;
using JsonArray  = std::vector<JsonValue>;

class JsonValue {
public:
    using Value = std::variant<
        std::nullptr_t,     // null
        bool,               // true / false
        double,             // 数字
        std::string,        // 字符串
        JsonArray,          // 数组
        JsonObject          // 对象
    >;
    
    Value data;
    
    // 构造
    JsonValue() : data(nullptr) {}
    JsonValue(std::nullptr_t) : data(nullptr) {}
    JsonValue(bool b) : data(b) {}
    JsonValue(double d) : data(d) {}
    JsonValue(int i) : data(static_cast<double>(i)) {}
    JsonValue(const std::string &s) : data(s) {}
    JsonValue(const char *s) : data(std::string(s)) {}
    JsonValue(JsonArray arr) : data(std::move(arr)) {}
    JsonValue(JsonObject obj) : data(std::move(obj)) {}
    
    // 类型判断
    bool is_null()   const { return std::holds_alternative<std::nullptr_t>(data); }
    bool is_bool()   const { return std::holds_alternative<bool>(data); }
    bool is_number() const { return std::holds_alternative<double>(data); }
    bool is_string() const { return std::holds_alternative<std::string>(data); }
    bool is_array()  const { return std::holds_alternative<JsonArray>(data); }
    bool is_object() const { return std::holds_alternative<JsonObject>(data); }
    
    // 取值
    double as_number()       const { return std::get<double>(data); }
    const std::string& as_string() const { return std::get<std::string>(data); }
    bool as_bool()           const { return std::get<bool>(data); }
    const JsonArray& as_array()    const { return std::get<JsonArray>(data); }
    const JsonObject& as_object()  const { return std::get<JsonObject>(data); }
    
    // 对象访问
    JsonValue& operator[](const std::string &key) {
        return std::get<JsonObject>(data)[key];
    }
};
```

---

## 递归下降解析器

```cpp
#include <stdexcept>
#include <cctype>
#include <sstream>

class JsonParser {
    std::string input_;
    size_t pos_ = 0;
    
    char peek() const { return pos_ < input_.size() ? input_[pos_] : '\0'; }
    char advance() { return input_[pos_++]; }
    
    void skip_whitespace() {
        while (pos_ < input_.size() && std::isspace(input_[pos_])) pos_++;
    }
    
    void expect(char c) {
        skip_whitespace();
        if (advance() != c)
            throw std::runtime_error(std::string("期望 '") + c + "'");
    }
    
public:
    JsonValue parse(const std::string &input) {
        input_ = input;
        pos_ = 0;
        auto result = parse_value();
        skip_whitespace();
        if (pos_ != input_.size())
            throw std::runtime_error("输入未完全解析");
        return result;
    }
    
private:
    JsonValue parse_value() {
        skip_whitespace();
        char c = peek();
        if (c == '"')  return parse_string();
        if (c == '{')  return parse_object();
        if (c == '[')  return parse_array();
        if (c == 't' || c == 'f') return parse_bool();
        if (c == 'n')  return parse_null();
        if (c == '-' || std::isdigit(c)) return parse_number();
        throw std::runtime_error("无效的 JSON 值");
    }
    
    JsonValue parse_string() {
        expect('"');
        std::string result;
        while (peek() != '"') {
            if (peek() == '\\') {
                advance();
                switch (advance()) {
                    case '"':  result += '"';  break;
                    case '\\': result += '\\'; break;
                    case 'n':  result += '\n'; break;
                    case 't':  result += '\t'; break;
                    default: break;
                }
            } else {
                result += advance();
            }
        }
        expect('"');
        return JsonValue(result);
    }
    
    JsonValue parse_number() {
        size_t start = pos_;
        if (peek() == '-') advance();
        while (std::isdigit(peek())) advance();
        if (peek() == '.') {
            advance();
            while (std::isdigit(peek())) advance();
        }
        return JsonValue(std::stod(input_.substr(start, pos_ - start)));
    }
    
    JsonValue parse_bool() {
        if (input_.substr(pos_, 4) == "true")  { pos_ += 4; return JsonValue(true); }
        if (input_.substr(pos_, 5) == "false") { pos_ += 5; return JsonValue(false); }
        throw std::runtime_error("无效的布尔值");
    }
    
    JsonValue parse_null() {
        if (input_.substr(pos_, 4) == "null") { pos_ += 4; return JsonValue(nullptr); }
        throw std::runtime_error("无效的 null");
    }
    
    JsonValue parse_array() {
        expect('[');
        JsonArray arr;
        skip_whitespace();
        if (peek() != ']') {
            arr.push_back(parse_value());
            while (peek() != ']') {
                expect(',');
                arr.push_back(parse_value());
            }
        }
        expect(']');
        return JsonValue(std::move(arr));
    }
    
    JsonValue parse_object() {
        expect('{');
        JsonObject obj;
        skip_whitespace();
        if (peek() != '}') {
            auto key = parse_string().as_string();
            expect(':');
            obj[key] = parse_value();
            skip_whitespace();
            while (peek() != '}') {
                expect(',');
                key = parse_string().as_string();
                expect(':');
                obj[key] = parse_value();
                skip_whitespace();
            }
        }
        expect('}');
        return JsonValue(std::move(obj));
    }
};
```

---

## 序列化

```cpp
std::string to_json(const JsonValue &val, int indent = 0) {
    return std::visit([&](auto &&arg) -> std::string {
        using T = std::decay_t<decltype(arg)>;
        
        if constexpr (std::is_same_v<T, std::nullptr_t>) {
            return "null";
        } else if constexpr (std::is_same_v<T, bool>) {
            return arg ? "true" : "false";
        } else if constexpr (std::is_same_v<T, double>) {
            std::ostringstream oss;
            oss << arg;
            return oss.str();
        } else if constexpr (std::is_same_v<T, std::string>) {
            return "\"" + arg + "\"";
        } else if constexpr (std::is_same_v<T, JsonArray>) {
            std::string result = "[";
            for (size_t i = 0; i < arg.size(); i++) {
                if (i > 0) result += ", ";
                result += to_json(arg[i]);
            }
            return result + "]";
        } else if constexpr (std::is_same_v<T, JsonObject>) {
            std::string result = "{";
            bool first = true;
            for (const auto &[k, v] : arg) {
                if (!first) result += ", ";
                result += "\"" + k + "\": " + to_json(v);
                first = false;
            }
            return result + "}";
        }
    }, val.data);
}
```

---

## 使用示例

```cpp
int main() {
    JsonParser parser;
    
    auto val = parser.parse(R"({
        "name": "STM32F4",
        "freq_mhz": 168,
        "features": ["FPU", "DSP", "DMA"],
        "gpio": {"count": 144, "5v_tolerant": true}
    })");
    
    std::cout << val["name"].as_string() << std::endl;           // STM32F4
    std::cout << val["freq_mhz"].as_number() << std::endl;       // 168
    std::cout << val["features"].as_array()[0].as_string() << std::endl;  // FPU
    
    // 序列化
    std::cout << to_json(val) << std::endl;
    
    return 0;
}
```

---

## 练习题

### 练习：扩展 JSON 解析器

**要求**：

- 扩展解析器支持科学计数法（如 `1.5e10`、`-3.14E-2`）
- 测试多种数字格式：整数、小数、科学计数法、负数
- 验证解析结果的正确性

??? note "参考答案"

    ```cpp title="exercise.cpp"
    #include <iostream>
    #include <string>
    #include <cmath>
    #include <stdexcept>
    #include <cctype>

    class NumberParser {
        std::string input_;
        size_t pos_ = 0;

        char peek() const { return pos_ < input_.size() ? input_[pos_] : '\0'; }
        char advance() { return input_[pos_++]; }

    public:
        double parse(const std::string &input) {
            input_ = input;
            pos_ = 0;
            double result = parse_number();
            if (pos_ != input_.size())
                throw std::runtime_error("未完全解析");
            return result;
        }

    private:
        double parse_number() {
            size_t start = pos_;

            // 符号
            if (peek() == '-') advance();

            // 整数部分
            if (!std::isdigit(peek()))
                throw std::runtime_error("无效数字");
            while (std::isdigit(peek())) advance();

            // 小数部分
            if (peek() == '.') {
                advance();
                while (std::isdigit(peek())) advance();
            }

            // 科学计数法
            if (peek() == 'e' || peek() == 'E') {
                advance();
                if (peek() == '+' || peek() == '-') advance();
                if (!std::isdigit(peek()))
                    throw std::runtime_error("无效指数");
                while (std::isdigit(peek())) advance();
            }

            return std::stod(input_.substr(start, pos_ - start));
        }
    };

    int main()
    {
        NumberParser parser;

        std::string tests[] = {
            "42", "-17", "3.14", "-0.5",
            "1.5e10", "-3.14E-2", "6.022e23", "1E3"
        };

        for (const auto &t : tests) {
            try {
                double val = parser.parse(t);
                std::cout << "\"" << t << "\" → " << val << std::endl;
            } catch (const std::exception &e) {
                std::cerr << "\"" << t << "\" 解析失败: " << e.what() << std::endl;
            }
        }

        return 0;
    }
    ```

    **预期输出**：
    ```
    "42" → 42
    "-17" → -17
    "3.14" → 3.14
    "-0.5" → -0.5
    "1.5e10" → 1.5e+10
    "-3.14E-2" → -0.0314
    "6.022e23" → 6.022e+23
    "1E3" → 1000
    ```

---

> **下一课**：[面试高频考点](../36-interview/README.md)
