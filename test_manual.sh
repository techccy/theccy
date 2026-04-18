#!/bin/bash

# 手动测试脚本 - 验证完整的用户场景

set -e

echo "==== 手动测试 - 完整用户场景 ===="
echo ""
echo "注意：此脚本需要手动验证以下步骤"
echo ""

# 步骤 1: 显示如何初始化 Shell 集成
echo "步骤 1: 初始化 Shell 集成"
echo "----------------------------------------"
echo "在 ~/.zshrc 或 ~/.bashrc 中添加以下行："
echo ""
./ccy-core --init
echo ""
echo "然后运行: source ~/.zshrc 或 source ~/.bashrc"
echo ""

# 步骤 2: 模拟用户场景
echo "步骤 2: 模拟用户场景"
echo "----------------------------------------"
echo "场景：用户执行一个失败的命令，然后直接使用 ccy"
echo ""
echo "示例命令序列："
echo "  1. ls -l /nonexistent     (执行失败的命令)"
echo "  2. ccy                    (直接使用 ccy，无需手动输入)"
echo ""

# 步骤 3: 测试 Shell 脚本的核心功能
echo "步骤 3: 测试 Shell 脚本的核心功能"
echo "----------------------------------------"

# 创建一个测试函数
eval "$(./ccy-core --init)"

# 测试历史命令提取
echo "测试 3.1: 验证历史命令提取"
echo "请手动执行以下命令："
echo "  1. echo 'test command'   (执行一条测试命令)"
echo "  2. ccy                   (运行 ccy)"
echo "预期：ccy 应该能够获取到上一条命令 'echo test command'"
echo ""

# 测试高危命令过滤
echo "测试 3.2: 验证高危命令过滤"
echo "高危命令黑名单: rm|mkfs|reboot|shutdown|format|fdisk"
echo "请手动执行以下命令："
echo "  1. rm -rf /tmp/test    (执行一条高危命令)"
echo "  2. ccy                   (运行 ccy)"
echo "预期：ccy 应该跳过重放，直接将命令传递给 ccy-core"
echo ""

# 测试错误捕获
echo "测试 3.3: 验证错误捕获"
echo "请手动执行以下命令："
echo "  1. ls -l /root/secret   (执行一条会失败的命令)"
echo "  2. ccy                   (运行 ccy)"
echo "预期：ccy 应该捕获到错误信息并传递给 ccy-core"
echo ""

echo "==== 手动测试说明 ===="
echo "请按照上述步骤手动测试功能"
echo "由于需要实际的 API 密钥，完整的端到端测试需要设置 CCY_API_KEY 环境变量"
