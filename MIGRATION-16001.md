# EnhancedChatFilter 无限服移植记录

日期：2026-11-18。用户已批准移植范围并指定版本 2026.11.18。
目标：Interface 16001，保留现有过滤功能、魔改管理界面与 ecfDB 结构。

## 设计和实际变更

采用原架构内最小适配，修改 TOC、init.lua、config.lua、filters.lua；沿用已有 Ace Settings 注册分支和内置库。运行文件、配置和回滚要求见 README.md 完整部署清单。

- TOC：Interface 16001、Version 2026.11.18、AllowLoadGameType camelot。
- init.lua：集中检查受限值；存在社区提示 CVar 时应用开关。
- config.lua：优先 C_Item.GetItemInfo；物品查询无结果时保留旧名单；社区开关即时应用；错误导入格式不再报错；按完整 UTF-8 字符截断。
- filters.lua：优先 ChatFrameUtil.AddMessageEventFilter，兼容旧入口；玩家身份和满级条件推迟到登录初始化；空物品品质安全放行；去重区分事件并处理首条 ID 0；受限数据交回原聊天显示；非法 Lua 模式不打断过滤；成就回填资料缺失时显示原消息。
- README.md、changelog.txt、tests/regression.lua、tests/syntax.lua：交付说明及离线验证。

## 排查与验证记录

原始代码隔离回归首轮 5/12 通过，复现未缓存物品比较报错、ID 0 跳过、受限文本处理、无分隔符导入报错、两种中文截断、社区开关延迟生效。修复后 12/12 通过。
增加现代聊天注册入口、非法 Lua 模式、成就回填缺失用例，修复后 15/15 通过。
补充原有过滤分类、旧名单、历史上限与清空、配置保存、跨事件去重、受限发送者/GUID、成就地区/公会优先级，最终 34/34 通过。
全部 36 个 Lua 文件语法检查通过；40 个 TOC/XML 引用文件存在；git diff --check 通过。
环境：已有 rollledger-validation:local Docker 镜像，Lua 5.1；无网络、只读工作区挂载、移除 capabilities。未在宿主机下载执行脚本。

成就 GUID 原参数位置核对正确，保持原签名。邀请 GUID 为事件第 7 项，保持原签名。
参考：暴雪生成 ChatInfoDocumentation.lua、PartyInfoDocumentation.lua 及 Blizzard_ChatFrameBase/Shared/ChatFrameFilters.lua，Gethe/wow-ui-source live 镜像。live 源码只用于接口参考，不充当无限目标构建实测证据。
https://github.com/Gethe/wow-ui-source/tree/live/Interface/AddOns

## 独立审查与限制

独立审查未发现明确 P0/P1 新错误。审查发现输入阶段基于空串的 Lua 模式探测只覆盖部分非法模式，例如 a[ 可以进入名单；运行期 pcall 已阻止其破坏其他过滤。保留此基础检查，并明确其不属于完整语法验证，避免引入新的模式解析器。该规则本身需用户修正才能命中。
Ace 库未发现已证实需要修改的静态兼容点；实际布局和共享库版本仍需游戏内验证。
真实 secret value 的限制无法由普通 Lua 替身完全模拟。

## 交付进度

- [x] 用户批准与指定版本记录。
- [x] 实施范围内兼容修改及 changelog。
- [x] 34 项行为回归、语法、引用和差异检查。
- [x] 独立代码审查。
- [ ] 无限服游戏内加载、设置界面和实际频道/战斗/邀请验收。

用户提供客户端 D:/Game/World of Warcraft/_forever_ 并表示已登录。已确认游戏窗口存在，Computer Use 返回“Computer Use was not approved to use wow”，未操作游戏、重载或发送消息。

安装记录：已首次安装到上述客户端的 Interface/AddOns/EnhancedChatFilter，共 41 个运行文件，逐文件 SHA-256 与工程一致。TOC 现场核对为 Interface 16001、Version 2026.11.18。目标目录安装前不存在，未覆盖旧版或 SavedVariables。首次发现新插件建议用户退出并重新启动客户端，在插件列表启用后执行 README 中游戏内验收。
