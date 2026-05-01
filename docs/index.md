# 嵌入式开发知识库

> 系统性的嵌入式开发学习资料，涵盖 Linux 驱动、MCU 裸机、C/C++ 进阶。

## 📚 内容结构

每个知识模块按以下四层组织：

```
课程模块/
├── README.md          # 原理讲解 + 逻辑流程
├── hardware/          # 硬件原理图、接线说明、引脚定义
└── code/              # 驱动代码 + 测试例程
```

## 🗺️ 知识地图

| 模块 | 内容 | 状态 |
|------|------|------|
| [Linux 基础命令](linux-basics/index.md) | Shell 入门、文件操作、权限、进程、网络、脚本 | ✅ 已完成 |
| [Linux 驱动开发](linux-driver/index.md) | 字符设备、平台驱动、设备树、GPIO/I2C/SPI/UART | 🚧 构建中 |
| [MCU 裸机开发](mcu/index.md) | Cortex-M 内核、外设驱动、FreeRTOS | 🚧 构建中 |
| [C 语言进阶](c-language/index.md) | 指针、状态机、环形缓冲区、位操作 | 🚧 构建中 |
| [C++ 嵌入式](cpp-embedded/index.md) | HAL 模板类、RAII | 🚧 构建中 |

## 🔧 阅读建议

- **初学者**：先从 [Linux 基础命令](linux-basics/index.md) 入手，再到 [MCU 裸机开发](mcu/index.md)，最后进阶 Linux 驱动
- **有 MCU 基础**：可直接从 [Linux 驱动开发](linux-driver/index.md) 的基础框架入手
- **每个课程**都包含硬件连接说明、原理讲解和可运行的代码

!!! tip "在线编辑"
    本库托管在 GitHub，每个页面右上角有 ✏️ 编辑按钮，可直接在网页上修改内容并提交。
