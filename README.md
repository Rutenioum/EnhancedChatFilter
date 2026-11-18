# EnhancedChatFilter

无限服移植版 **2026.11.18**，目标 **Interface 16001 / camelot**。

保留关键词与次级关键词、Lua 模式、重复消息、语言、DND、团队/任务通报、怪物与系统消息、成就合并、拾取与邀请过滤，以及批量添加、独立导入导出、屏蔽原因和最近 500 条记录（界面显示最近 50 条）。

## 安装与使用

将 EnhancedChatFilter 文件夹放到 `_forever_/Interface/AddOns/`。插件目录应直接包含 EnhancedChatFilter.toc。
首次安装建议退出并重新启动游戏。在角色选择的插件列表中启用 EnhancedChatFilter，进入游戏后通过“选项 → 插件 → EnhancedChatFilter”配置。更新已有插件可使用 `/reload`。

已有配置保存在账户的 `WTF/Account/<账户>/SavedVariables/EnhancedChatFilter.lua`，沿用 ecfDB，无需迁移。

## 完整部署清单

- EnhancedChatFilter.toc
- init.lua
- config.lua
- filters.lua
- Libs/ 整个目录（随包 AceGUI、AceConfig、LibStub、CallbackHandler）
- Locales/ 整个目录（locales.xml、zhCN.lua、zhTW.lua）

README.md、changelog.txt、MIGRATION-16001.md 和 tests/ 是开发/说明文件，不要求复制到游戏目录。无外部运行依赖安装、数据库迁移或额外配置文件。首次安装须让客户端重新发现插件；更新后重载界面。

## 验证状态

Lua 5.1 隔离容器回归 **34/34** 通过；全部 **36** 个 Lua 文件语法检查通过；TOC/XML 引用 **40** 个文件存在。
测试使用 WoW API 替身，不等于客户端实测。尚需在无限服验证设置窗口、真实频道、成就、拾取、好友/公会豁免和邀请场景，以及与其他 Ace 插件共存。

受客户端保护而不可读取的消息交回游戏正常显示；插件不会解析或记录这些内容。Lua 模式在运行时受到错误保护，非法规则不会中断聊天。输入时只做基础错误检查，不保证识别全部非法模式。

## 游戏内验收

1. 插件列表显示版本 2026.11.18；设置窗口可打开且没有 EnhancedChatFilter Lua 错误。
2. 批量添加测试关键词，导出、清空、导入，核对列表恢复。测试结束清理测试词。
3. 用另一个非好友角色发送命中关键词的消息，检查屏蔽原因；多个聊天窗口只计一次。用好友测试豁免。
4. 分别启用并测试重复、团队/任务通报、怪物、语言、拾取和邀请过滤；检查开关关闭后恢复原聊天行为。
5. 检查成就多人合并、中文长消息展示、记录刷新/清空；重载后关键词和配置仍在。

如有报错，请提供 BugSack 中首条 EnhancedChatFilter 错误的完整堆栈及触发动作。

## 回滚

覆盖已有版本前退出游戏，备份原插件目录及上述 SavedVariables `.lua`、`.lua.bak` 文件。回滚时退出游戏，恢复这两处备份后重新登录。首次安装可在插件列表取消启用。

## 本地回归

在项目目录执行 `lua5.1 tests/regression.lua`。测试不列入 TOC。语法检查支持 `lua5.1 tests/syntax.lua <Lua文件列表>`，兼容原文件 UTF-8 BOM。
