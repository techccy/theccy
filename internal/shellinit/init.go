package shellinit

import (
	"fmt"
	"os"
)

func GenerateInitScript() (string, error) {
	shell := os.Getenv("SHELL")
	switch shell {
	case "", "/bin/zsh", "/usr/bin/zsh":
		return generateZshScript(), nil
	case "/bin/bash", "/usr/bin/bash":
		return generateBashScript(), nil
	default:
		return "", fmt.Errorf("unsupported shell: %s", shell)
	}
}

func generateZshScript() string {
	return `# diu shell integration for Zsh
diu() {
	local _diu_last_command
	local _diu_error_output
	local _diu_blacklist="rm|mkfs|reboot|shutdown|format|fdisk"

	_diu_last_command=$(fc -ln -1 | sed 's/^[[:space:]]*//')

	if [[ -z "$_diu_last_command" ]]; then
		return 1
	fi

	if [[ "$_diu_last_command" == "diu"* ]]; then
		_diu_last_command=$(fc -ln -2 | head -1 | sed 's/^[[:space:]]*//')
	fi

	if [[ "$_diu_last_command" == "diu"* ]]; then
		return 1
	fi

	if echo "$_diu_last_command" | grep -qE "^(${_diu_blacklist})"; then
		diu-core "$_diu_last_command" ""
		return $?
	fi

	_diu_error_output=$(timeout 3s bash -c "$_diu_last_command" 2>&1 >/dev/null)

	diu-core "$_diu_last_command" "$_diu_error_output"
}
 `
}

func generateBashScript() string {
	return `# diu shell integration for Bash
diu() {
	local _diu_last_command
	local _diu_error_output
	local _diu_blacklist="rm|mkfs|reboot|shutdown|format|fdisk"

	_diu_last_command=$(history -p '!!' 2>/dev/null)

	if [[ -z "$_diu_last_command" ]]; then
		return 1
	fi

	if [[ "$_diu_last_command" == "diu"* ]]; then
		_diu_last_command=$(history -p '!-2' 2>/dev/null)
	fi

	if [[ "$_diu_last_command" == "diu"* ]]; then
		return 1
	fi

	if echo "$_diu_last_command" | grep -qE "^(${_diu_blacklist})"; then
		diu-core "$_diu_last_command" ""
		return $?
	fi

	_diu_error_output=$(timeout 3s bash -c "$_diu_last_command" 2>&1 >/dev/null)

	diu-core "$_diu_last_command" "$_diu_error_output"
}
 `
}
