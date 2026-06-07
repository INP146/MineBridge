# MineBridge

MineBridge 是一个用于 PlayCover 版 Minecraft 的热注入输入桥。它把一个 dylib 注入到正在运行的游戏进程里，将 macOS 的键盘和鼠标输入接入 Minecraft 现有的 iOS / GameController 输入链路。

## 功能

- 将 `GCKeyboard` 和 `GCMouse` 接入 Minecraft 已有的键鼠 handler。
- 通过游戏的 GameController 输入链路转发键盘、鼠标按键、滚轮和鼠标移动。
- 只在 Minecraft 原生 `prefersPointerLocked` 表示允许 mouse-look 时锁定并隐藏 macOS 鼠标指针。
- 在主界面、暂停界面、背包、文本输入和 MineBridge 菜单中释放鼠标指针。
- 短按 `M` 打开 MineBridge 菜单；菜单中按 `M` 或 `Esc` 关闭。
- 在 MineBridge 菜单里提供 HUD、按键显示和疾跑相关选项。
- HUD 可显示疾跑状态、`WASD`、鼠标左右键和空格按下状态，并支持自定义位置、大小和透明度。

## 兼容性

MineBridge 的发布版本号由“游戏版本 + 插件版本”组成。比如 `26.21.0.2` 表示：

- 游戏版本：`26.21`
- 插件版本：`0.2`

只能使用与当前 Minecraft 版本对应的 MineBridge 版本。游戏版本不一致时，即使 dylib 能注入，也不能保证 pointer lock、输入转发或内部偏移仍然正确。

pointer-lock 桥接目前依赖 Minecraft 内部 platform 对象布局：

```text
platform + 0x412
```

这个值不是 Mach-O 基址偏移，也不依赖 ASLR 后的模块加载地址。它是游戏运行时对象里的字段偏移。Minecraft 更新后，这个偏移必须重新验证。

## 快速使用

在 release 中找到对应版本的下载包，先在 PlayCover 中启动 Minecraft，然后解压后进入目录执行：

```sh
./scripts/hotload.sh
```

脚本会自动：

- 使用 `dist/minebridge.dylib`
- 把 dylib 复制到 PlayCover container
- 归档上一份 MineBridge 日志
- 查找正在运行的 Minecraft 进程
- 通过 `lldb + dlopen` 注入 dylib

默认复制路径：

```text
~/Library/Containers/io.playcover.PlayCover/minebridge_26.21.0.2.dylib
```

默认日志路径：

```text
~/Library/Containers/io.playcover.PlayCover/minebridge.log
```

## 热注入参数

```sh
./scripts/hotload.sh --pid 12345
./scripts/hotload.sh --dylib dist/minebridge.dylib
./scripts/hotload.sh --build
./scripts/hotload.sh --build --verbose
./scripts/hotload.sh --unique-copy
./scripts/hotload.sh --cleanup
./scripts/hotload.sh --cleanup-only
./scripts/hotload.sh --container ~/Library/Containers/io.playcover.PlayCover
./scripts/hotload.sh --pattern /com.mojang.minecraftpe.app/minecraftpe
./scripts/hotload.sh --dry-run
```

`--verbose` 只在配合 `--build` 时有意义，会构建带高频 trace 日志的 dylib。

`--unique-copy` 会复制为带时间戳的 dylib 路径，主要用于开发时反复注入不同构建。普通使用保持默认的版本号路径即可，`--cleanup` 会清掉旧的时间戳副本，但保留当前版本号副本。

## HUD 设置

打开 MineBridge 菜单后，在 `HUD` 页可以分别控制：

- `HUD`：总开关。
- `按键显示`：显示 `WASD`、鼠标左右键和空格的按下状态。
- `疾跑显示`：用图标显示当前疾跑语义。
- `HUD设置`：进入 HUD 编辑器。

进入 HUD 编辑器后，鼠标点击选择要调整的元素：

- 方向键移动选中元素。
- `-` / `=` 调整大小。
- `,` / `.` 调整透明度。
- `R` 重置选中元素布局。
- 双击 HUD 元素可直接输入位置、大小和透明度。
- `Esc` 退出编辑器；从菜单进入时会回到 MineBridge 菜单。

## 构建

仓库里已经包含可直接使用的 `dist/minebridge.dylib`。只有修改源码或需要 verbose trace 版本时才需要重新构建：

```sh
make
```

输出文件：

```text
dist/minebridge.dylib
```

verbose trace 构建：

```sh
make verbose
```

临时输出路径：

```sh
make OUT=/tmp/minebridge-test.dylib
```

`OUT` 路径不能包含空白字符；这是 Make target 路径的限制。

兼容旧流程的脚本仍然可用：

```sh
./scripts/build.sh
./scripts/build.sh --verbose
./scripts/build.sh --output /tmp/minebridge-test.dylib
```

构建系统使用 `arm64-apple-ios14.0-macabi` target，目标产物会做 ad-hoc 签名。对象文件和 depfile 存放在 `build/` 下，`make clean` 会清理这些中间文件。

## 仓库结构

```text
bridge/      Objective-C runtime hook 和输入桥源码
dist/        发布用 dylib
logs/        热注入前归档的旧 MineBridge 日志
scripts/     构建与热注入脚本
VERSION      发布版本号
```
