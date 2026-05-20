.PHONY: run run-cn open open-cn stop clean install

PORT ?= 8080

# 一键启动（英文），自动安装依赖并打开浏览器
run: install
	@echo "Starting A Dark Room on http://localhost:$(PORT) ..."
	@node dev-server.js &>/dev/null & \
		sleep 1 && open http://localhost:$(PORT) && \
		echo "Press Ctrl+C to stop."

# 一键启动（简体中文）
run-cn: install
	@echo "Starting A Dark Room (简体中文) on http://localhost:$(PORT)?lang=zh_cn ..."
	@node dev-server.js &>/dev/null & \
		sleep 1 && open "http://localhost:$(PORT)?lang=zh_cn" && \
		echo "Press Ctrl+C to stop."

# 只安装依赖（无 node_modules 时自动拉取）
install:
	@test -d node_modules || yarn install --frozen-lockfile 2>/dev/null || yarn install

# 仅打开浏览器（假设已在运行）
open:
	@open http://localhost:$(PORT)

open-cn:
	@open "http://localhost:$(PORT)?lang=zh_cn"

# 停止本地服务
stop:
	@lsof -ti:$(PORT) | xargs kill 2>/dev/null && echo "Stopped." || echo "No process on port $(PORT)."

# 清理
clean: stop
	@rm -rf node_modules
	@echo "Cleaned."
