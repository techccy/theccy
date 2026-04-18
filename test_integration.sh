#!/bin/bash

# 测试脚本 - 验证 diu shell 集成的功能

set -e

echo "==== 测试 diu Shell 集成 ===="

# 测试 1: 验证 --init 命令输出
echo ""
echo "测试 1: 验证 --init 命令输出"
if ./diu-core --init > /tmp/diu-init-test.sh; then
    echo "✓ --init 命令执行成功"
    echo "✓ 初始化脚本已保存到 /tmp/diu-init-test.sh"
else
    echo "✗ --init 命令执行失败"
    exit 1
fi

# 测试 2: 验证帮助信息
echo ""
echo "测试 2: 验证帮助信息"
if ./diu-core | grep -q "Shell 集成"; then
    echo "✓ 帮助信息包含 Shell 集成说明"
else
    echo "✗ 帮助信息不完整"
    exit 1
fi

# 测试 3: 验证脚本包含必要的功能
echo ""
echo "测试 3: 验证脚本包含必要的功能"
if grep -q "fc -ln -1" /tmp/diu-init-test.sh || grep -q "history -p '!!'" /tmp/diu-init-test.sh; then
    echo "✓ 脚本包含历史命令提取功能"
else
    echo "✗ 脚本缺少历史命令提取功能"
    exit 1
fi

if grep -q "timeout 3s" /tmp/diu-init-test.sh; then
    echo "✓ 脚本包含超时机制"
else
    echo "✗ 脚本缺少超时机制"
    exit 1
fi

if grep -q "_diu_blacklist" /tmp/diu-init-test.sh; then
    echo "✓ 脚本包含高危命令黑名单"
else
    echo "✗ 脚本缺少高危命令黑名单"
    exit 1
fi

if grep -q "2>&1 >/dev/null" /tmp/diu-init-test.sh; then
    echo "✓ 脚本包含 stderr 捕获功能"
else
    echo "✗ 脚本缺少 stderr 捕获功能"
    exit 1
fi

echo ""
echo "==== 所有测试通过 ✓ ===="
