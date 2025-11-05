# 🧠 Git Smart Wrapper

一个增强版的 Git 命令行封装工具，提供命令高亮、错误提示、常用命令快捷选项等智能功能，帮助开发者更高效地使用 Git。

---

## 🚀 功能特性

| 功能 | 说明 |
|------|------|
| 🪄 智能包装 | 所有 `git` 命令都会自动经过 `git-smart.ps1` 的优化与格式化输出 |
| 🎨 彩色输出 | 高亮显示 Git 输出内容，让提交、分支、冲突一目了然 |
| ⚙️ 动态路径 | 自动识别 Git 安装路径与脚本目录，免配置、跨机器可用 |
| 💬 自定义扩展 | 可在 PowerShell 脚本中添加自定义命令逻辑，例如：`git -fp pull` |
| 🔄 跨平台支持 | 兼容 Windows 命令提示符 (cmd) 与 PowerShell |

---

## 📁 文件结构

```
git-smart/
├── git-smart.ps1   # PowerShell 核心逻辑脚本（处理 Git 命令封装与输出）
├── git.cmd         # Windows 命令行入口脚本（调用 PowerShell 脚本）
└── install.ps1     # 自动安装脚本（动态生成路径、注册 PATH、复制文件）
```

---

## ⚙️ 安装步骤

### 🪟 方式一：自动安装（推荐）

1. 下载以下三个文件并放在同一目录下：
   ```
   git-smart.ps1
   git.cmd
   install.ps1
   ```
2. 打开 PowerShell（建议以管理员身份）
3. 执行命令：

   ```powershell
   .\install.ps1
   ```

4. 安装完成后，关闭并重新打开命令行窗口。

5. 测试是否成功：

   ```bash
   git status
   ```

   若输出带有颜色或提示信息，则安装成功 ✅

---

### 🧩 方式二：手动安装

1. 创建目录（例如）：
   ```
   C:\Tools\git-smart
   ```
2. 将 `git-smart.ps1` 与 `git.cmd` 复制到该目录。
3. 修改git.cmd中本地的git实际路径以及脚本路径
4. 将目录添加到系统的 **PATH** 环境变量中。
5. 重新打开终端并输入：
   ```bash
   git
   ```

---

## 🧰 install.ps1 脚本说明

安装脚本 `install.ps1` 会自动完成以下操作：

| 步骤 | 功能 |
|------|------|
| 1️⃣ | 检查 PowerShell 执行策略（防止受限执行） |
| 2️⃣ | 创建默认安装目录（`C:\Tools\git-smart`） |
| 3️⃣ | 复制 `git-smart.ps1` 到安装目录 |
| 4️⃣ | 自动生成带当前用户路径的 `git.cmd` 文件 |
| 5️⃣ | 将安装目录自动添加到系统 PATH |
| 6️⃣ | 验证安装是否成功 |

### 示例执行命令
```powershell
# 默认安装
.\install.ps1

# 或指定安装路径
.\install.ps1 -InstallPath "D:\MyTools\git-smart"
```

---

## 💡 使用示例

以下命令示例展示了 git-smart 的封装效果：

```bash
# 正常 Git 命令均可使用
git status
git commit -m "Fix login bug"
git log --oneline

# 支持扩展功能（示例）
git -fp pull      # 执行 pull 并自动格式化输出
git -fp push      # 统一输出样式、颜色和提示
```

> 你可以在 `git-smart.ps1` 内自由扩展命令逻辑，例如添加快捷命令别名或自定义 Git 工作流。

---

## 🧹 卸载

若想卸载 `git-smart`，执行以下命令：

```powershell
Remove-Item -Recurse -Force "C:\Tools\git-smart"
```

然后手动从系统 **PATH** 环境变量中移除对应路径。

> 你也可以使用自定义的 `uninstall.ps1`（可选脚本）自动清理。

---

## 🧑‍💻 技术细节

- `git.cmd`  
  - 用于 CMD 环境中调用 PowerShell 脚本。  
  - 会自动定位到当前安装路径（由 install.ps1 动态生成）。  
  - 自动检测系统中 `git.exe` 所在路径。

- `git-smart.ps1`  
  - 是核心逻辑文件，用于格式化 Git 输出。  
  - 可以扩展参数解析、命令优化、错误提示等高级功能。  
  - 通过 `powershell -File git-smart.ps1` 调用执行。

---

## 🧾 更新日志

| 版本 | 日期 | 更新内容 |
|------|------|----------|
| v1.0.0 | 2025-11-05 | 初始版本发布：支持自动安装、动态路径和命令包装 |
| v1.0.1 | 即将更新 | 添加卸载脚本、命令别名系统、更多输出样式 |

---

## 📜 许可证

本项目采用 **MIT License**，可自由修改、使用与分发。

---

## ❤️ 鸣谢

本工具灵感来自日常开发中 Git 操作的重复性与输出可读性问题，旨在让开发者的 Git 命令更加“智能”和“优雅”。

---

> ✨ **作者建议：**  
> 如果你希望让 `git-smart.ps1` 支持更多命令别名或输出美化，我可以帮你一起设计扩展模块（如 `git log --graph` 彩色化或 `git branch` 自动提示）。
