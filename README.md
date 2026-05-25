# dotfiles（chezmoi）

用 [chezmoi](https://www.chezmoi.io/) 管理多台机器上的配置文件（shell、终端、编辑器等），源码在 GitHub，按系统和模板变量生成不同内容。

仓库地址：`git@github.com:zhanghaomiao/dotfiles.git`

---

## 核心概念（30 秒看懂）

| 概念 | 说明 |
|------|------|
| **源码目录** | `~/.local/share/chezmoi`（本仓库克隆到这里） |
| **目标文件** | 你 home 目录里的真实配置，如 `~/.zshrc`、`~/.config/wezterm/` |
| **`chezmoi apply`** | 把源码渲染后，同步到目标路径 |
| **`chezmoi edit`** | 改的是源码，不是直接改 `~/.zshrc`（改完记得 `apply`） |

文件名约定（chezmoi 标准）：

- `dot_xxx` → 部署为 `~/.xxx`（例如 `dot_zshrc.tmpl` → `~/.zshrc`）
- `private_dot_config/` → `~/.config/`，且权限为 `600`
- `*.tmpl` → Go 模板，会根据「机器变量」生成不同内容

---

## 新主机：从零开始

```bash
chezmoi init --apply git@github.com:zhanghaomiao/dotfiles.git
```

第一次运行会**交互式询问**（答案写入 `~/.config/chezmoi/chezmoi.toml`）：

| 变量 | 含义 | 示例 |
|------|------|------|
| `email` | 邮箱（模板里可用） | `you@example.com` |
| `role` | 机器角色 | `desktop` 或 `server` |
| `theme` | 终端/UI 主题 | `light` 或 `dark` |

等价两步：

```bash
chezmoi init git@github.com:zhanghaomiao/dotfiles.git
chezmoi apply
```

验证：

```bash
chezmoi doctor
chezmoi managed
chezmoi diff
```

---

## 平台差异

| 系统 | 说明 |
|------|------|
| **macOS** | 会管理 `~/Library/...`（如 Antigravity 设置） |
| **Linux** | 管理 `~/.config/...`（WSL 也算 Linux） |
| **Windows** | 在 **Windows 用户目录** 下部署；与 WSL 的 home **不是同一份** |

---

## 日常使用（记住这几条就够）

```bash
chezmoi diff                              # 查看会改什么
chezmoi apply                             # 应用所有变更
chezmoi apply ~/.zshrc                    # 只应用单个文件
chezmoi edit ~/.zshrc                     # 编辑源码
chezmoi edit ~/.config/wezterm/config/bindings.lua
chezmoi cd                                # 进入源码目录
chezmoi add ~/.foo/bar.conf               # 纳入管理
chezmoi update                            # 从 GitHub 拉取并应用
chezmoi data                              # 查看机器变量
```

**推荐工作流：** `chezmoi edit` → `chezmoi diff` → `chezmoi apply` → `git commit` + `git push`。

别名：部署后的 `~/.zshrc` 里有 `alias cz='chezmoi'`。

---

## 修改机器变量

```bash
chezmoi edit-config    # 编辑 email / role / theme
chezmoi apply
```

---

## 已初始化机器：模板或配置变了怎么办？

先分清**两份配置**（容易混）：

| 文件 | 位置 | 作用 |
|------|------|------|
| **源码模板** | `~/.local/share/chezmoi/` 里的 `dot_*.tmpl`、`private_*` 等 | 所有机器共享，在 Git 里 |
| **本机变量** | `~/.config/chezmoi/chezmoi.toml` 的 `[data]` | **仅这一台机器**，init 时问答生成，一般不提交 Git |

改模板 ≠ 改 `chezmoi.toml`；处理方式不同。

### 情况 1：Git 上的模板改了（在别的机器上 commit 了）

本机已 init 过，只需**拉源码 + 再 apply**：

```bash
chezmoi diff      # 先看 home 里哪些文件会变（建议必做）
chezmoi update    # = 在源码目录 git pull + chezmoi apply
```

或手动：

```bash
chezmoi cd && git pull && cd -
chezmoi apply
```

只更新某一个文件：

```bash
chezmoi diff ~/.config/wezterm/config/bindings.lua
chezmoi apply ~/.config/wezterm/config/bindings.lua
```

### 情况 2：只改了本机 `chezmoi.toml`（换 theme 等）

例如把 `theme` 从 `light` 改成 `dark`：

```bash
chezmoi edit-config   # 或直接编辑 ~/.config/chezmoi/chezmoi.toml
chezmoi diff          # 所有 .tmpl 渲染结果可能都变
chezmoi apply
```

**不需要**重新 `chezmoi init`。

### 情况 3：仓库里 `.chezmoi.toml.tmpl` 加了新变量

`promptStringOnce` **只在第一次 init 时问一次**，已初始化的机器不会自动弹窗。

需要自己在本机 `chezmoi.toml` 里补上，例如：

```toml
[data]
    email = "you@example.com"
    role = "desktop"
    theme = "dark"
    new_field = "新值"    # 手动添加
```

然后 `chezmoi apply`。

### 情况 4：仓库里删了某些配置（如去掉 tmux）

`chezmoi apply` **不会**自动删除 home 里已有文件。需要：

```bash
chezmoi diff    # 确认源码里已无该项
# 手动删 home 里的旧文件，或：
chezmoi apply --remove    # 按 chezmoi 策略删除「源码已不存在」的目标文件（用前先看 diff）
chezmoi forget <路径>     # 让 chezmoi 不再管理该路径
```

### 情况 5：你直接改过 `~/.zshrc`，但模板也更新了

`chezmoi apply` 可能提示目标文件比上次 apply 后又被改过：

- 要保留本机手改：先 `chezmoi diff`，把改动合并进源码（`chezmoi edit ~/.zshrc`），再 `apply`
- 要用模板覆盖：`chezmoi apply --force`（会丢掉 home 里未合并的修改）

### 一张图记流程

```
别的机器改了模板并 push
        ↓
  本机: chezmoi update   （或 git pull + apply）

只改本机 theme
        ↓
  本机: edit-config → apply

仓库删了某个配置
        ↓
  本机: apply --remove 或手动 rm + forget
```

**日常口诀：** 已 init 的机器永远不用重做 init；**先看 `diff`，再 `update` 或 `apply`**。

---

## 当前管理的配置

运行 `chezmoi managed` 查看完整列表。主要包括：

| 路径 | 说明 |
|------|------|
| `~/.zshrc` | Zsh + Oh My Zsh + Starship |
| `~/.vimrc` | Vim |
| `~/.config/wezterm/` | WezTerm |
| `~/.ssh/config.d/chezmoi-hosts` | SSH 主机清单（MagicDNS 名，全机同步） |
| `~/.config/starship.toml` | Starship |
| `~/.config/yazi/` | Yazi |
| `~/.config/opencode/` | OpenCode |
| `~/.condarc` | Conda |
| `~/.config/pip/`、`~/.config/containers/` | Python / 容器 |

---

## WezTerm 快捷键

Leader：**`Ctrl + Space`**（先按 Leader，松手，再按命令键）。

> **Windows 注意：** 中文输入法常占用 `Ctrl+Space`，会导致 Leader 无效；需在输入法设置里关掉该快捷键，或把 Leader 改成 `Ctrl+b`。

| 先 `Ctrl+Space`，再按 | 动作 |
|----------------------|------|
| `%` 或 `Shift+5` | 左右分屏 |
| `"` 或 `Shift+'` | 上下分屏 |
| `h` / `j` / `k` / `l` | pane 间移动 |
| `x` | 关闭当前 pane |
| `p` 再 `h/j/k/l` | 调整 pane 大小 |
| `f` 再 `k/j` | 调整字体大小 |

### WSL + Windows WezTerm

- WSL 里 `chezmoi apply` → `~/.config/wezterm`
- Windows 版 WezTerm → `C:\Users\<你>\.config\wezterm`

若只用 Windows 版 WezTerm，需在 Windows 上也执行 `chezmoi init --apply`。

---

## SSH 与 Tailscale：一处改，全机同步

### 问题从哪来

| 写法 | Tailscale 重连后 |
|------|------------------|
| `HostName 172.16.3.222` | 公司外连不上 |
| `HostName 100.121.9.76` | **IP 可能变**，SSH 断 |
| `HostName iregene-222` | **MagicDNS 短名不变**，推荐 |

Tailscale 管连通，SSH config 管别名；**HostName 永远写 MagicDNS 名，不写 IP**。

查看机器名：

```bash
tailscale status    # 第一列就是 HostName 应填的名字
```

### 推荐方案：`Include` 片段 + chezmoi

主配置 `~/.ssh/config` **留在本机**（Coder 自动生成段不能进 Git）。  
主机清单单独放在 chezmoi 管理的片段里：

```
~/.ssh/config              ← 本机维护：Include + Coder 段
~/.ssh/config.d/chezmoi-hosts   ← chezmoi 管理：n1/n2/225/ub...
```

**源码：** `private_dot_ssh/private_config.d/chezmoi-hosts`

### 一次性设置（每台机器做一次）

编辑本机 `~/.ssh/config`：

1. **最上面**加一行：

   ```ssh
   Include ~/.ssh/config.d/chezmoi-hosts
   ```

2. **删掉**已迁到片段里的 `Host n1` / `n2` / `225` / `ub` 段落（避免重复）

3. **保留** Coder 段不动

4. 部署片段：

   ```bash
   chezmoi apply ~/.ssh/config.d/chezmoi-hosts
   ```

之后 `ssh n1`、`ssh 225`、WezTerm **F3** 的 `SSH:n1` 照常可用。

### 日常：加机器 / 改名 / Tailscale 变了

只改 chezmoi 源码一处，所有机器同步：

```bash
chezmoi edit ~/.ssh/config.d/chezmoi-hosts
chezmoi apply
git commit -am "ssh: add myserver" && git push

# 别的机器
chezmoi update
```

**新加一台：**

```ssh
Host myserver
    HostName iregene-999    # tailscale status 里的名字
    User zhanghm
    IdentityFile ~/.ssh/id_ecdsa
```

### 什么不用放进 chezmoi

- Coder 自动生成的 `Host coder.*` 段
- 仅某台机器才有的临时 Host

---

## 仓库目录结构

```
.chezmoi.toml.tmpl      # 首次 init 交互变量
.chezmoitemplates/
.chezmoignore           # 按 OS 忽略规则
dot_zshrc.tmpl          # → ~/.zshrc
dot_vimrc.tmpl          # → ~/.vimrc
private_dot_config/     # → ~/.config/
private_dot_ssh/        # → ~/.ssh/config.d/chezmoi-hosts
private_Library/        # → ~/Library/（仅 macOS）
```

---

## 常见问题

### 改了 `~/.zshrc` 但下次 apply 被覆盖

用 `chezmoi edit ~/.zshrc` 改源码，再 `apply`。

### 本机还有已删除工具的旧配置

从仓库移除后，chezmoi 不会自动删掉 home 里已有文件。可手动删除，例如：

```bash
rm -rf ~/.config/alacritty ~/.config/zellij ~/.tmux.conf ~/.local/bin/tmux-smart
chezmoi forget ~/.config/alacritty ~/.config/zellij ~/.tmux.conf ~/.local/bin/tmux-smart 2>/dev/null || true
```

---

## 参考

- [chezmoi 文档](https://www.chezmoi.io/user-guide/)
- [WezTerm 文档](https://wezfurlong.org/wezterm/)
