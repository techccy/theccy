package shellinit

import (
	"fmt"
	"os"
)

func GenerateInitScript() (string, error) {
	shell := os.Getenv("SHELL")
	switch {
	case shell == "" || shell == "/bin/zsh" || shell == "/usr/bin/zsh":
		return generateZshScript(), nil
	case shell == "/bin/bash" || shell == "/usr/bin/bash":
		return generateBashScript(), nil
	default:
		return "", fmt.Errorf("unsupported shell: %s", shell)
	}
}

func generateZshScript() string {
	return `# ccy shell integration for Zsh
ccy() {
	local _ccy_last_command
	local _ccy_error_output
	local _ccy_blacklist="rm|mkfs|reboot|shutdown|format|fdisk"

	_ccy_last_command=$(fc -ln -1 | sed 's/^[[:space:]]*//')

	if [[ -z "$_ccy_last_command" ]]; then
		return 1
	fi

	if [[ "$_ccy_last_command" == "ccy"* ]]; then
		_ccy_last_command=$(fc -ln -2 | head -1 | sed 's/^[[:space:]]*//')
	fi

	if [[ "$_ccy_last_command" == "ccy"* ]]; then
		return 1
	fi

	if echo "$_ccy_last_command" | grep -qE "^(${_ccy_blacklist})"; then
		ccy-core "$_ccy_last_command" ""
		return $?
	fi

	_ccy_error_output=$(timeout 3s bash -c "$_ccy_last_command" 2>&1 >/dev/null)

	ccy-core "$_ccy_last_command" "$_ccy_error_output"
}
`
}

func generateBashScript() string {
	return `# ccy shell integration for Bash
ccy() {
	local _ccy_last_command
	local _ccy_error_output
	local _ccy_blacklist="rm|mkfs|reboot|shutdown|format|fdisk"

	_ccy_last_command=$(history -p '!!' 2>/dev/null)

	if [[ -z "$_ccy_last_command" ]]; then
		return 1
	fi

	if [[ "$_ccy_last_command" == "ccy"* ]]; then
		_ccy_last_command=$(history -p '!-2' 2>/dev/null)
	fi

	if [[ "$_ccy_last_command" == "ccy"* ]]; then
		return 1
	fi

	if echo "$_ccy_last_command" | grep -qE "^(${_ccy_blacklist})"; then
		ccy-core "$_ccy_last_command" ""
		return $?
	fi

	_ccy_error_output=$(timeout 3s bash -c "$_ccy_last_command" 2>&1 >/dev/null)

	ccy-core "$_ccy_last_command" "$_ccy_error_output"
}
`
}
