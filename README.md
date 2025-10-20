# FRPC 使用说明

本仓库包含：

* `frpc.ini`：FRPC 客户端配置文件（已包含一个名为 `mc` 的 TCP 转发示例）。
* `frpc_start.bat`：Windows 一键管理脚本，提供启动/停止/隐藏启动/查看状态/校验配置等功能菜单。

> 目录中需放置 `frpc.exe`（与上述文件同级）。

---

## 1. 快速开始

1. 将以下文件放到同一目录：

   * `frpc.exe`
   * `frpc.ini`
   * `frpc_start.bat`

2. 双击运行 `frpc_start.bat`，进入交互式菜单。脚本会在启动前检查 `frpc.exe` 与 `frpc.ini` 是否存在。

3. 选择功能：

   * `1` 启动 FRPC（前台运行，窗口显示日志）
   * `2` 隐藏启动（后台运行，不显示窗口）
   * `3` 停止 FRPC（结束 `frpc.exe` 进程）
   * `4` 查看 FRPC 运行状态（查询是否有 `frpc.exe` 进程）
   * `5` 查看配置文件内容（回显 `frpc.ini`）
   * `6` 测试配置文件（调用 `frpc.exe verify -c frpc.ini`）
   * `7` 退出脚本
     （以上菜单与批处理脚本一致。）

---

## 2. 配置文件说明（`frpc.ini`）

```ini
[common]
server_addr = 8.137.12.127
server_port = 7000
token = 123123

# mc
[mc]
type = tcp
local_ip = 127.0.0.1
local_port = 3000
remote_port = 3000
```

* `[common]`：基础连接信息

  * `server_addr`：FRPS 服务端地址
  * `server_port`：FRPS 监听端口
  * `token`：与 FRPS 约定的认证令牌（建议改为随机强口令）
* `[mc]`：一个转发条目（名称可自定义）

  * `type = tcp`：TCP 转发
  * `local_ip` / `local_port`：本地服务监听地址与端口
  * `remote_port`：在服务端暴露的远端端口（外网访问入口）

以上字段与示例来自你当前的配置文件。

> 例：当前配置将本机 `127.0.0.1:3000` 通过 FRPS 暴露为 `server_addr:3000`（即 `8.137.12.127:3000`）。

---

## 3. 管理脚本用法（`frpc_start.bat`）

### 3.1 前台启动（菜单项 1）

脚本会打印启动时间与配置路径，然后执行：

```bat
frpc.exe -c frpc.ini
```

按 `Ctrl + C` 可中断。该行为与脚本内实现一致。

### 3.2 隐藏启动（菜单项 2）

脚本会临时生成 `frpc_hidden.vbs`，以隐藏方式启动 FRPC 到后台，并在 2 秒后检测进程是否存在，成功则提示 `SUCCESS`。

### 3.3 停止（菜单项 3）

通过 `taskkill /f /im frpc.exe` 结束进程；若未运行则提示 `NOT running`。

### 3.4 查看状态（菜单项 4）

查询是否存在 `frpc.exe`，并在运行时显示一个进程表格。

### 3.5 查看配置（菜单项 5）

直接输出 `frpc.ini` 内容到控制台，便于快速核对。

### 3.6 测试配置（菜单项 6）

执行：

```bat
frpc.exe verify -c frpc.ini
```

根据返回码给出 `SUCCESS` 或 `ERROR` 提示。用于在正式启动前检查语法与必填项。

---

## 4. 常见修改场景

### 4.1 更换远端暴露端口

在 `frpc.ini` 对应条目下修改：

```ini
remote_port = 3000   ; 改为未被 FRPS 占用的端口
```

保存后，重新启动 FRPC 生效。该键位来自现有条目。

### 4.2 增加多个服务转发

复制 `[mc]` 区块并重命名，例如：

```ini
[web]
type = tcp
local_ip = 127.0.0.1
local_port = 8080
remote_port = 8080
```

重启 FRPC 后多条转发会同时生效。字段名与结构同示例保持一致。

---

## 5. 故障排查

* **启动时报 `frpc.exe not found` 或 `frpc.ini not found`**
  将脚本与 `frpc.exe`、`frpc.ini` 放在同一目录再运行（脚本已做存在性检查并提示）。

* **隐藏模式无效/未成功**
  脚本会创建 `frpc_hidden.vbs` 并检测进程；若失败会给出 `ERROR`。检查 `token`、`server_addr`/`server_port` 是否正确。

* **端口被占用**
  更换 `remote_port`，并确认 FRPS 侧未占用该端口。示例中的键位即为远端端口设置。

* **配置是否有效**
  使用菜单 `6`（或手动执行 `frpc.exe verify -c frpc.ini`）进行验证。
