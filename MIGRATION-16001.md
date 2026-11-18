

## 2026.11.18.1 屏蔽记录颜色修复
用户已批准。根因：新版 |cnIQ4: / |cnCOLOR_NAME: 未清理，而 |r 被移除，导致颜色泄漏并计入截断长度。config.lua 在截断前清除命名颜色起始标记，保留物品显示名称。新增紫装、混合嵌套颜色、100 字中文边界三项回归，修复前 34/37，修复后 37/37；全部 36 个 Lua 文件语法通过。运行变更仅 config.lua 和 EnhancedChatFilter.toc（版本 2026.11.18.1）。无新依赖或配置迁移；更新后 /reload 生效。回滚恢复本次安装备份的两个文件后 /reload。真实游戏显示待用户复验。
部署完成：config.lua、EnhancedChatFilter.toc 已同步至无限客户端并通过 SHA-256 对比。原文件备份：C:/Users/cerium/AppData/Local/Temp/EnhancedChatFilter-backup-20261118-124539。
