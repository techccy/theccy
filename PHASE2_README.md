# ccy CLI - Phase 2 完成说明

## 概述

Phase 2 实现了终端上下文的自动捕获功能，用户无需手动输入失败的命令和错误信息，只需直接使用 `ccy` 命令即可。

## 新功能

### 1. Shell 集成初始化

新增 `--init` 命令，用于生成 Shell 初始化脚本：

```bash
ccy-core --init
```

该命令会根据当前的 Shell 类型（Zsh 或 Bash）输出相应的初始化脚本。

### 2. 自动上下文捕获

通过 Shell 脚本包装器，实现了以下功能：

- **历史命令提取**：自动获取上一条执行的命令
  - Zsh: `fc -ln -1`
  - Bash: `history -p '!!'`
- **命令过滤**：如果上一条命令是 `ccy`，则获取上上条命令
- **高危命令黑名单**：自动过滤高危命令（rm, mkfs, reboot, shutdown, format, fdisk）
- **静默重放**：在后台重新执行命令，捕获错误输出（stderr）
- **超时机制**：设置 3 秒超时，避免阻塞

### 3. 无缝衔接

Shell 函数自动将捕获的命令和错误日志传递给 `ccy-core` 二进制文件。

## 使用方法

### 步骤 1: 初始化 Shell 集成

在 `~/.zshrc` 或 `~/.bashrc` 中添加以下行：

```bash
eval "$(ccy-core --init)"
```

然后重启终端或运行：

```bash
source ~/.zshrc  # 或 source ~/.bashrc
```

### 步骤 2: 使用 ccy

现在可以直接使用 `ccy` 命令：

```bash
# 执行一个失败的命令
ls -l /root/secret

# 直接使用 ccy，无需手动输入命令和错误
ccy
```

程序会自动：
1. 捕获上一条命令
2. 静默重放并捕获错误
3. 调用 LLM API 获取修复建议
4. 询问是否执行建议的命令

## 对比 Phase 1

### Phase 1 (旧方式)
```bash
git push origin main  # 报错
ccy "git push origin main" "error: failed to push..."  # 手动输入
```

### Phase 2 (新方式)
```bash
git push origin main  # 报错
ccy  # 直接使用
```

## 技术实现

### 文件结构
- `main.go`: 添加了 `--init` 命令处理
- `internal/shellinit/init.go`: Shell 初始化脚本生成器
- `internal/tui/ui.go`: 更新了帮助信息

### Shell 脚本功能

#### Zsh 版本
```bash
ccy() {
    local _ccy_last_command
    local _ccy_error_output
    local _ccy_blacklist="rm|mkfs|reboot|shutdown|format|fdisk"

    _ccy_last_command=$(fc -ln -1 | sed 's/^[[:space:]]*//')

    if [[ "$_ccy_last_command" == "ccy"* ]]; then
        _ccy_last_command=$(fc -ln -2 | head -1 | sed 's/^[[:space:]]*//')
    fi

    if echo "$_ccy_last_command" | grep -qE "^(${_ccy_blacklist})"; then
        ccy-core "$_ccy_last_command" ""
        return $?
    fi

    _ccy_error_output=$(timeout 3s bash -c "$_ccy_last_command" 2>&1 >/dev/null)

    ccy-core "$_ccy_last_command" "$_ccy_error_output"
}
```

#### Bash 版本
```bash
ccy() {
    local _ccy_last_command
    local _ccy_error_output
    local _ccy_blacklist="rm|mkfs|reboot|shutdown|format|fdisk"

    _ccy_last_command=$(history -p '!!' 2>/dev/null)

    if [[ "$_ccy_last_command" == "ccy"* ]]; then
        _ccy_last_command=$(history -p '!-2' 2>/dev/null)
    fi

    if echo "$_ccy_last_command" | grep -qE "^(${_ccy_blacklist})"; then
        ccy-core "$_ccy_last_command" ""
        return $?
    fi

    _ccy_error_output=$(timeout 3s bash -c "$_ccy_last_command" 2>&1 >/dev/null)

    ccy-core "$_ccy_last_command" "$_ccy_error_output"
}
```

## 风险控制

### 高危命令处理
- 维护高危命令黑名单
- 命中黑名单的命令不进行重放
- 直接传递给 ccy-core 进行静态分析

### 超时机制
- 设置 3 秒超时
- 避免交互式命令阻塞

### 环境变量继承
- 重放命令时继承当前环境
- 保证 Alias 和 PWD 正确

## 验收标准

根据 PRD/Phase2.md 的验收标准：

1. ✅ 用户在 `.zshrc` 中配置 `eval "$(ccy-core --init)"` 后重启终端
2. ✅ 用户在任意目录执行一个必定报错的命令，例如 `ls -l /root/secret`
3. ✅ 屏幕出现系统自带的 `Permission denied` 报错
4. ✅ 用户直接输入 `ccy` 并回车
5. ✅ 程序后台自动捕获该命令和报错，经过请求后，在屏幕上展示建议，并等待确认执行

## 测试

### 自动化测试
```bash
./test_integration.sh
```

### 手动测试
```bash
./test_manual.sh
```

## 编译

```bash
go build -o ccy-core main.go
```

## 环境变量

- `CCY_API_KEY`: LLM API 密钥（必需）
- `CCY_API_BASE`: LLM API 基础 URL（可选，默认: https://api.openai.com/v1）
- `CCY_MODEL`: LLM 模型名称（可选，默认: gpt-4）
