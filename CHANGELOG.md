# Changelog

## 26.21.0.2 - 2026-06-07

- 新增按键显示 HUD，可显示 `WASD`、鼠标左右键和空格按下状态。
- 扩展 HUD 编辑器，按键显示元素现在也可以单独调整位置、大小、透明度，并支持双击输入参数和持久化布局。
- MineBridge 菜单的 `HUD` 页新增 `按键显示` 开关，并重新排布 HUD、疾跑显示和 HUD 设置项。
- 构建流程改为 Makefile 驱动，新增对象文件、depfile、`make verbose`、`make debug`、`make inspect` 等构建入口；`scripts/build.sh` 改为兼容包装。
- 日志路径从固定用户路径改为运行时解析 PlayCover container 路径，修复只在特定本机用户名下可写的问题。
- 改进 Stage Manager 下的窗口中心定位、原生 `keyChangedHandler` 路由和 UI 抑制状态处理，降低菜单 / HUD 编辑器 / mouse-look 之间的输入状态串扰，修复台前调度开启时终端窗口和游戏窗口不在一组时的一系列问题。

## 26.21.0.1 - 2026-06-07

- 发布首个 MineBridge 版本，面向 PlayCover 上运行的 Minecraft `26.21`。
- 热注入生产入口：`scripts/hotload.sh` 默认使用 `dist/minebridge.dylib`。
- 短按 `M` 打开 MineBridge 菜单并释放 bridge/OS 鼠标捕获，不清掉 Minecraft 原生 mouse-look 状态。
