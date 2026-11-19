-- Run from the addon directory with Lua 5.1: lua tests/regression.lua
local failures, total = 0, 0
local function test(name, f)
 total = total + 1
 local ok, err = pcall(f)
 print((ok and 'PASS ' or 'FAIL ') .. name .. (ok and '' or ': '..tostring(err)))
 if not ok then failures = failures + 1 end
end
local function setup(modern, saved, noLibs)
 local env = setmetatable({}, {__index = _G})
 env._G = env
 env.format, env.max, env.min, env.tremove = string.format, math.max, math.min, table.remove
 local events, filters, timers, output = {}, {}, {}, {}
 env.CreateFrame = function()
  local f = {}
  function f:RegisterEvent(e) events[e] = self end
  function f:SetScript(_, cb) self.cb = cb end
  return f
 end
 env.GetTime = function() return 100 end
 env.GetUnitName = function() return 'Self' end
 env.GetRealmName = function() return 'Realm' end
 env.UnitLevel = function() return 60 end
 env.GetMaxPlayerLevel = function() return 60 end
 env.GetLocale = function() return 'zhCN' end
 env.GetNumLanguages = function() return 1 end
 env.GetLanguageByIndex = function() return 'Common' end
 env.Ambiguate = function(s) return s:gsub('%-Realm$', '') end
 env.C_BattleNet = {GetGameAccountInfoByGUID = function() end}
 env.C_FriendList = {IsFriend = function(g) return g == 'Player-friend' end}
 env.IsGuildMember = function(g) return g == 'Player-guild' end
 env.IsGUIDInGroup = function(g) return g == 'Player-group' end
 env.C_Timer = {After = function(_, f) timers[#timers+1] = f end}
 env.C_Item = {GetItemInfo = function() end, GetItemQualityByID = function() end}
 env.GetItemInfo = env.C_Item.GetItemInfo
 if modern then env.GetItemInfo = false end
 env.C_CurrencyInfo = {GetCurrencyLink = function(id) return 'currency:'..id end}
 env.C_AddOns = {GetAddOnMetadata = function() return '2026.11.18' end}
 env.C_CVar = {GetCVar = function() return '1' end, SetCVar = function(_, v) env.toast = v end}
 env.SetCVar = env.C_CVar.SetCVar
 env.GetAchievementLink = function(id) return '|Hachievement:'..id..'|h[Achievement]|h' end
 env.GetPlayerInfoByGUID = function() if env.missingPlayer then return end; return 'Warrior','WARRIOR',nil,nil,nil,'Other','' end
 env.RAID_CLASS_COLORS = {WARRIOR = {colorStr = 'ffffffff'}}
 env.ChatTypeInfo = {ACHIEVEMENT={r=1,g=1,b=1}, GUILD_ACHIEVEMENT={r=1,g=1,b=1}}
 env.NUM_CHAT_WINDOWS = 1
 env.ChatFrame1 = {IsEventRegistered=function() return true end, AddMessage=function(_,s) output[#output+1]=s end}
 env.ChatFrame_AddMessageEventFilter = function(e,f) filters[e] = f end
 if modern then
  env.ChatFrameUtil = {AddMessageEventFilter=env.ChatFrame_AddMessageEventFilter}
  env.ChatFrame_AddMessageEventFilter = false
 end
 env.ITEM_QUALITY_COLORS = {}
 for i=0,4 do env.ITEM_QUALITY_COLORS[i]={hex=''}; env['ITEM_QUALITY'..i..'_DESC']='Quality' end
 for _,k in ipairs({'ERR_LEARN_ABILITY_S','ERR_LEARN_SPELL_S','ERR_SPELL_UNLEARNED_S','ERR_LEARN_PASSIVE_S','ERR_PET_SPELL_UNLEARNED_S','ERR_PET_LEARN_ABILITY_S','ERR_PET_LEARN_SPELL_S'}) do env[k]=k..'%s' end
 env.print = function() end
 env.issecretvalue = function(v) return type(v)=='table' and v.secret == true end
 env.DeclineGroup = function() env.declined = true end
 env.StaticPopup_Hide = function() end
 local options
 local dbicon = {registered = {}, shown = {}, registerCount = 0}
 function dbicon:IsRegistered(n) return self.registered[n] ~= nil end
 function dbicon:Register(n, obj, db)
  self.registered[n] = {object = obj, db = db}
  self.registerCount = self.registerCount + 1
 end
 function dbicon:Show(n) self.shown[n] = true end
 function dbicon:Hide(n) self.shown[n] = false end
 env.dbicon = dbicon
 local ldb = {}
 function ldb:NewDataObject(name, obj) env.broker, env.brokerName = obj, name return obj end
 local aceConfig = {
  RegisterOptionsTable = function(_, _, o) options = o end,
  AddToBlizOptions = function(_, appName) return {name = appName}, appName end,
  NotifyChange = function() end,
 }
 env.LibStub = function(major)
  if noLibs and (major == 'LibDataBroker-1.1' or major == 'LibDBIcon-1.0') then return nil end
  if major == 'LibDataBroker-1.1' then return ldb end
  if major == 'LibDBIcon-1.0' then return dbicon end
  return aceConfig
 end
 env.Settings = {OpenToCategory = function(id) env.openedCategory = id end}
 env.ecfDB = saved
 local ns = {}
 for _,file in ipairs({'init.lua','Locales/zhCN.lua','config.lua','minimap.lua','filters.lua'}) do
  local f = assert(io.open(file,'rb')); local src=f:read('*a'); f:close()
  local chunk = assert(loadstring((src:gsub('^\239\187\191','')), '@'..file)); setfenv(chunk,env); chunk('EnhancedChatFilter',ns)
 end
 local function fire(e,...) local f=assert(events[e],e); f.cb(f,e,...) end
 fire('PLAYER_LOGIN')
 local function chat(e,msg,id,guid,player)
  return filters[e]({},e,msg,player or 'Other','Common','', '', '',0,0,'',0,id,guid or 'Player-other',0)
 end
 return ns[3],options,chat,env,timers,output,fire
end
test('namespaced item API',function() local _,o=setup(true); o.args.lootFilter.args.itemFilterList.values() end)
test('uncached loot passes',function() local _,_,chat=setup(); assert(not chat('CHAT_MSG_LOOT','|Hitem:123|h[item]|h',1)) end)
test('achievement GUID and merge',function() local _,_,chat,_,timers,out=setup(); assert(chat('CHAT_MSG_ACHIEVEMENT','|Hachievement:123|h[ach]|h',1)); assert(#timers==1); timers[1](); assert(#out==1) end)
test('first line zero filters and counts once',function() local c,_,chat=setup(); c.db.blackWordList.SPAM={}; assert(chat('CHAT_MSG_CHANNEL','spam',0)); assert(chat('CHAT_MSG_CHANNEL','spam',0)); assert(#c.blockedHistory==1) end)
test('friend keyword exemption',function() local c,_,chat=setup(); c.db.blackWordList.SPAM={}; assert(not chat('CHAT_MSG_CHANNEL','spam',1,'Player-friend')) end)
test('secret chat passes without processing',function() local c,_,chat=setup(); assert(not chat('CHAT_MSG_CHANNEL',{secret=true},1)); assert(#c.blockedHistory==0) end)
test('invalid import does not throw',function() local c,o=setup(); c.UI.stringIO='broken'; o.args.blackListTab.args.import.func() end)
test('export import roundtrip',function() local c,o=setup(); local b=o.args.blackListTab.args; b.batchAdd.set(nil,'alpha, beta'); b.export.func(); c.db.blackWordList={}; b.import.func(); assert(c.db.blackWordList.ALPHA and c.db.blackWordList.BETA) end)
test('history UTF8 boundary',function() local c,o=setup(); c.blockedHistory[1]={msg=string.rep('中',101),player='Other',time=99}; local s=o.args.blockedContent.args.blockedList.name(); assert(s:sub(-303)==string.rep('中',100)..'...') end)
test('short Chinese history stays whole',function() local c,o=setup(); c.blockedHistory[1]={msg=string.rep('中',40),player='Other',time=99}; local s=o.args.blockedContent.args.blockedList.name(); assert(s:sub(-120)==string.rep('中',40)) end)
test('community toggle applies immediately',function() local _,o,_,env=setup(); o.set({'enableCommunity'},true); assert(env.toast==0) end)
test('stranger invite and friend exemption',function() local c,_,_,env,_,_,fire=setup(); c.db.enableInvite=true; fire('PARTY_INVITE_REQUEST','Friend',false,false,false,true,false,'Player-friend'); assert(not env.declined); fire('PARTY_INVITE_REQUEST','Other',false,false,false,true,false,'Player-other'); assert(env.declined) end)
test('invalid saved Lua pattern cannot break chat',function() local c,_,chat=setup(); c.db.blackWordList['[']={regex=true}; assert(not chat('CHAT_MSG_CHANNEL','hello',1)) end)
test('invalid new Lua pattern rejected',function() local c,o=setup(); c.UI.regexToggle=true; o.args.blackListTab.args.blackword.set(nil,'['); assert(not c.db.blackWordList['[']) end)
test('achievement missing player data keeps original',function() local _,_,chat,env,timers,out=setup()
 env.missingPlayer=true
 local msg='|Hachievement:123|h[ach]|h'; assert(chat('CHAT_MSG_ACHIEVEMENT',msg,1)); timers[1](); assert(out[1]==msg)
end)
test('different events do not reuse filter result',function() local c,_,chat=setup(); c.db.blackWordList.SPAM={}; assert(chat('CHAT_MSG_CHANNEL','spam',1)); assert(not chat('CHAT_MSG_SAY','hello',1)) end)
test('self messages exempt',function() local c,_,chat=setup(); c.db.blackWordList.SPAM={}; assert(not chat('CHAT_MSG_CHANNEL','spam',1,nil,'Self')) end)
test('guild aggressive exemption',function() local c,_,chat=setup(); c.db.enableAggressive=true; assert(not chat('CHAT_MSG_CHANNEL','|Hjournal:1|h[Test]|h',1,'Player-guild')) end)
test('group aggressive exemption',function() local c,_,chat=setup(); c.db.enableAggressive=true; assert(not chat('CHAT_MSG_CHANNEL','|Hjournal:1|h[Test]|h',1,'Player-group')) end)
test('repeat filter',function() local _,_,chat=setup(); assert(not chat('CHAT_MSG_SAY','hello',1)); assert(chat('CHAT_MSG_SAY','hello',2)) end)
test('lesser keyword threshold',function() local c,_,chat=setup(); c.db.blackWordList={ONE={lesser=true},TWO={lesser=true}}; c.db.lesserBlackWordThreshold=2; assert(chat('CHAT_MSG_SAY','one two',1)) end)
test('DND message filter',function() local _,_,chat=setup(); assert(chat('CHAT_MSG_DND','busy',1)) end)
test('language toggle',function() local c,_,chat=setup(); c.db.enableLanguage=true; assert(not chat('CHAT_MSG_SAY','hello',1)); c.db.enableLanguage=false; assert(not chat('CHAT_MSG_SAY','different',2)) end)
test('raid alert filter',function() local c,_,chat=setup(); c.db.addonRAF=true; assert(chat('CHAT_MSG_PARTY','**warning**',1)) end)
test('quest report filter',function() local c,_,chat=setup(); c.db.addonQRF=true; assert(chat('CHAT_MSG_PARTY','任务进度: 1/3',1)) end)
test('monster repeat and multiple windows',function() local c,_,chat=setup(); c.db.enableMSF=true; assert(not chat('CHAT_MSG_MONSTER_SAY','roar',1)); assert(not chat('CHAT_MSG_MONSTER_SAY','roar',1)); assert(chat('CHAT_MSG_MONSTER_SAY','roar',2)) end)
test('system spell filter',function() local _,_,chat=setup(); assert(chat('CHAT_MSG_SYSTEM','ERR_LEARN_SPELL_STest',1)) end)
test('explicit loot and currency filters',function() local c,_,chat=setup(); c.db.lootItemFilterList[123]=true; c.db.lootCurrencyFilterList[7]=true; assert(chat('CHAT_MSG_LOOT','|Hitem:123|h[item]|h',1)); assert(chat('CHAT_MSG_CURRENCY','|Hcurrency:7|h[cur]|h',2)) end)
test('missing item info retains saved filter',function() local c,_,_,_,_,_,fire=setup(); fire('GET_ITEM_INFO_RECEIVED',71096,false); assert(c.db.lootItemFilterList[71096]) end)
test('history capped and clear works',function() local c,o,chat=setup(); c.db.blackWordList.SPAM={}; for i=1,501 do chat('CHAT_MSG_CHANNEL','spam',i) end; assert(#c.blockedHistory==500); o.args.blockedContent.args.clear.func(); assert(#c.blockedHistory==0) end)
test('logout retains filter history',function() local c,_,chat,env,_,_,fire=setup(); c.db.blackWordList.SPAM={}; chat('CHAT_MSG_CHANNEL','spam',1); fire('PLAYER_LOGOUT'); assert(env.ecfDB==c.db); assert(c.db.blockedPlayers.Realm.Other==1) end)
test('all chat paths pass secret text',function() local _,_,chat=setup(); for _,e in ipairs({'CHAT_MSG_MONSTER_SAY','CHAT_MSG_SYSTEM','CHAT_MSG_ACHIEVEMENT','CHAT_MSG_LOOT','CHAT_MSG_CURRENCY'}) do assert(not chat(e,{secret=true},1)) end end)
test('secret sender and GUID pass',function() local c,_,chat=setup(); c.db.blackWordList.SPAM={}; assert(not chat('CHAT_MSG_CHANNEL','spam',1,nil,{secret=true})); assert(not chat('CHAT_MSG_CHANNEL','spam',2,{secret=true})); assert(#c.blockedHistory==0) end)
test('guild achievement takes priority and duplicates merge',function() local _,_,chat,_,timers,out=setup(); local msg='|Hachievement:123|h[ach]|h'; chat('CHAT_MSG_ACHIEVEMENT',msg,1); chat('CHAT_MSG_GUILD_ACHIEVEMENT',msg,2); chat('CHAT_MSG_GUILD_ACHIEVEMENT',msg,2); assert(#timers==1); timers[1](); assert(#out==1) end)
test('history strips named epic color',function()
 local c,o=setup()
 c.blockedHistory[1]={msg='before |cnIQ4:|Hitem:123|h[Weapon]|h|r after',player='Other',time=99}
 local text=o.args.blockedContent.args.blockedList.name()
 assert(text:match(': (.*)$')=='before [Weapon] after')
end)
test('history strips mixed nested colors',function()
 local c,o=setup()
 c.blockedHistory[1]={msg='|cffa335ee紫色|r |cnWHITE_FONT_COLOR:外层|cnIQ4:武器|r正文|r',player='Other',time=99}
 local text=o.args.blockedContent.args.blockedList.name()
 assert(text:match(': (.*)$')=='紫色 外层武器正文')
end)
test('history truncates visible Chinese after color cleanup',function()
 local c,o=setup()
 c.blockedHistory[1]={msg=string.rep('中',98)..'|cnIQ4:|Hitem:123|h紫剑|h|r后续',player='Other',time=99}
 local text=o.args.blockedContent.args.blockedList.name()
 assert(text:match(': (.*)$')==string.rep('中',98)..'紫剑...')
end)
test('blocked player uses class color and resets before text',function()
 local c,o,chat,env=setup(); env.RAID_CLASS_COLORS.WARRIOR.colorStr='ffc79c6e'
 c.db.blackWordList.SPAM={}; chat('CHAT_MSG_CHANNEL','spam',1)
 assert(o.args.blockedContent.args.blockedList.name():find('|cffc79c6eOther|r: spam',1,true))
end)
test('unknown class and older history use white',function()
 local c,o,chat,env=setup(); env.missingPlayer=true
 c.db.blackWordList.SPAM={}; chat('CHAT_MSG_CHANNEL','spam',1)
 assert(o.args.blockedContent.args.blockedList.name():find('|cffffffffOther|r: spam',1,true))
 c.blockedHistory[1]={msg='old',player='Other',time=99}
 assert(o.args.blockedContent.args.blockedList.name():find('|cffffffffOther|r: old',1,true))
end)
test('advanced toggle reveals keyword controls',function()
 local _,o=setup(); local b=o.args.blackListTab.args
 for _,k in ipairs({'lesserBlackWordList','regexToggle','lesserToggle','lesserBlackWordThreshold'}) do assert(b[k].hidden()) end
 o.set({'advancedConfig'},true)
 for _,k in ipairs({'lesserBlackWordList','regexToggle','lesserToggle','lesserBlackWordThreshold'}) do assert(not b[k].hidden()) end
end)
test('legacy config gains minimap defaults', function()
 local c = setup(false, {enableDND = false, blackWordList = {SPAM = {}}})
 assert(type(c.db.minimap) == 'table')
 assert(c.db.minimap.hide == false)
 assert(c.db.minimap.minimapPos == 225)
 assert(c.db.enableDND == false)
 assert(c.db.blackWordList.SPAM)
end)
test('non-table minimap field is repaired alone', function()
 local c = setup(false, {minimap = 'broken', enableAggressive = true, blackWordList = {ONE = {lesser = true}}})
 assert(type(c.db.minimap) == 'table' and c.db.minimap.hide == false)
 assert(c.db.enableAggressive == true)
 assert(c.db.blackWordList.ONE.lesser)
end)
test('unknown saved fields dropped without touching filters', function()
 local c = setup(false, {ghostField = 1, blackWordList = {SPAM = {}}, blockedPlayers = {}})
 assert(c.db.ghostField == nil)
 assert(c.db.blackWordList.SPAM)
end)
test('minimap button registers once', function()
 local c, _, _, env = setup()
 assert(env.dbicon.registerCount == 1)
 assert(env.dbicon.registered.EnhancedChatFilter.db == c.db.minimap)
 c:SetupMinimapButton()
 c:SetupMinimapButton()
 assert(env.dbicon.registerCount == 1)
end)
test('left click opens addon settings', function()
 local _, _, _, env = setup()
 env.broker.OnClick(env.broker, 'LeftButton')
 assert(env.openedCategory == 'EnhancedChatFilter')
end)
test('non-left click does not open settings', function()
 local _, _, _, env = setup()
 env.broker.OnClick(env.broker, 'RightButton')
 assert(env.openedCategory == nil)
end)
test('settings fallback uses interface options frame', function()
 local _, _, _, env = setup()
 env.Settings = nil
 local opened
 env.InterfaceOptionsFrame_OpenToCategory = function(frame) opened = frame end
 env.broker.OnClick(env.broker, 'LeftButton')
 assert(opened and opened.name == 'EnhancedChatFilter')
end)
test('minimap toggle hides and shows button', function()
 local c, o, _, env = setup(); local t = o.args.General.args.minimapButton
 assert(t.get() == true)
 t.set(nil, false)
 assert(c.db.minimap.hide == true and env.dbicon.shown.EnhancedChatFilter == false)
 t.set(nil, true)
 assert(c.db.minimap.hide == false and env.dbicon.shown.EnhancedChatFilter == true)
end)
test('hidden state is honoured on login', function()
 local c, o, _, env = setup(false, {minimap = {hide = true, minimapPos = 90}})
 assert(c.db.minimap.hide == true)
 assert(env.dbicon.registered.EnhancedChatFilter.db.hide == true)
 assert(o.args.General.args.minimapButton.get() == false)
end)
test('missing libraries skip button but keep filtering', function()
 local c, _, chat, env = setup(false, nil, true)
 assert(env.broker == nil)
 c.db.blackWordList.SPAM = {}
 assert(chat('CHAT_MSG_CHANNEL', 'spam', 1))
end)
print(string.format('%d/%d passed',total-failures,total))
assert(failures==0,'regression failures')
