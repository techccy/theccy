#!/bin/bash

# Phase 2 演示脚本

echo "=========================================="
echo "  diu CLI Phase 2 - 自动上下文捕获演示"
echo "=========================================="
echo ""

echo "1. 构建 diu-core 二进制文件"
echo "-----------------------------------"
go build -o diu-core main.go
echo "✓ 构建完成"
echo ""

echo "2. 显示初始化脚本"
echo "-----------------------------------"
./diu-core --init | head -5
echo "..."
echo "✓ 初始化脚本生成成功"
echo ""

echo "3. 显示帮助信息"
echo "-----------------------------------"
./diu-core
echo ""

echo "=========================================="
echo "  安装说明"
echo "=========================================="
echo ""
echo "步骤 1: 将 diu-core 复制到 PATH 中的目录"
echo "  sudo cp diu-core /usr/local/bin/"
echo ""
echo "步骤 2: 在 ~/.zshrc 或 ~/.bashrc 中添加"
echo "  eval \"\$(diu-core --init)\""
echo ""
echo "步骤 3: 重启终端或运行"
echo "  source ~/.zshrc  # 或 source ~/.bashrc"
echo ""
echo "步骤 4: 开始使用"
echo "  ls -l /root/secret  # 执行失败的命令"
echo "  diu                  # 直接使用 diu"
echo ""
