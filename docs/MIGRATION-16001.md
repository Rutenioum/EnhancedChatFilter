
## 2026.11.18.2 职业色与提示
用户批准后实施：filters.lua 在新增屏蔽记录时按 GUID 取得可读职业标识，config.lua 使用 RAID_CLASS_COLORS 给名字着色并在正文前结束颜色；未知职业和旧记录显示白色。简繁中文提示准确描述重复过滤缓存规则及高级选项在关键词页新增的四项控件。TOC 版本 2026.11.18.2，README 为玩家功能、安装和致谢说明。
职业色与白色兜底两项新增测试修改前失败，修改后全套 40/40 通过；高级选项可见性检查通过；全部 36 个 Lua 文件语法检查及 diff --check 通过。
部署清单：EnhancedChatFilter.toc、config.lua、filters.lua、Locales/zhCN.lua、Locales/zhTW.lua。无依赖或配置迁移，游戏内 /reload 生效。五文件已同步并通过 SHA-256 比对。备份：C:/Users/cerium/AppData/Local/Temp/EnhancedChatFilter-backup-20261118-171612。回滚恢复备份五文件并 /reload。游戏内显示待用户复验。

## 2026.11.18.1 屏蔽记录颜色修复
用户已批准。根因：新版 |cnIQ4: / |cnCOLOR_NAME: 未清理，而 |r 被移除，导致颜色泄漏并计入截断长度。config.lua 在截断前清除命名颜色起始标记，保留物品显示名称。新增紫装、混合嵌套颜色、100 字中文边界三项回归，修复前 34/37，修复后 37/37；全部 36 个 Lua 文件语法通过。运行变更仅 config.lua 和 EnhancedChatFilter.toc（版本 2026.11.18.1）。无新依赖或配置迁移；更新后 /reload 生效。回滚恢复本次安装备份的两个文件后 /reload。真实游戏显示待用户复验。
部署完成：config.lua、EnhancedChatFilter.toc 已同步至无限客户端并通过 SHA-256 对比。原文件备份：C:/Users/cerium/AppData/Local/Temp/EnhancedChatFilter-backup-20261118-124539。
