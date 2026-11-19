# EnhancedChatFilter 无限服版

版本：2026.11.19.1 · 适用：魔兽世界无限服（Interface 16001）

## 功能

- 关键词屏蔽，支持批量添加、导入导出、次级关键词和 Lua 模式匹配。
- 过滤同一玩家的重复或相近消息，减少广告刷屏。
- 查看被屏蔽的内容、玩家（职业色）、时间与原因；记录最近 500 条，界面显示最近 50 条。
- 按需过滤任务进度、团队技能通报、NPC 重复发言、忙碌回复等消息。
- 合并多人获得同一成就的消息，支持按物品品质、物品 ID 和货币 ID 过滤拾取提示。
- 提供陌生人组队邀请过滤等可选功能。
- 小地图旁提供插件图标，左键打开设置；未被小地图按钮收纳插件接管时可拖动换位。

## 安装与设置

将 EnhancedChatFilter 文件夹放入 `_forever_/Interface/AddOns/`，在角色选择界面启用插件。
设置入口：选项 → 插件 → EnhancedChatFilter。更新后执行 `/reload`。

“显示高级选项”开启后，在关键词页面显示次级关键词列表、正则（Lua 模式）、次级关键词开关和命中阈值。

小地图图标默认显示，可在“常规”中关闭；关闭后仍能从插件设置页面重新开启。

## 致谢

本版本基于 [Rubgrsch 的 EnhancedChatFilterMODFix](https://github.com/Rubgrsch/EnhancedChatFilterMODFix) 修改并适配无限服。感谢 Rubgrsch 的维护，以及原作者 eucalyptisch、早期中文修改者 szpunk 的贡献。
