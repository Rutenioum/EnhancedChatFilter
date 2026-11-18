-- ECF
local _, ecf = ...
ecf[1] = {} -- Base
ecf[2] = {} -- Locales
ecf[3] = {} -- Config
setmetatable(ecf[2], {__index=function(_, key) return key end})
local B = unpack(ecf)

-- Restricted chat values must be left to Blizzard's normal chat display.
function B:IsReadable(...)
	if not issecretvalue then return true end
	for i = 1, select("#", ...) do
		if issecretvalue(select(i, ...)) then return false end
	end
	return true
end

function B:ApplyCommunitySetting(enabled)
	if C_CVar.GetCVar("showToastClubInvitation") ~= nil then
		C_CVar.SetCVar("showToastClubInvitation", enabled and 0 or 1)
	end
end

-- Lua
local ipairs = ipairs

--Event
local frame = CreateFrame("Frame")
frame:SetScript("OnEvent", function(self,event,...)
	for _, func in ipairs(self[event]) do func(self,event,...) end
end)

function B:AddEventScript(event, func)
	if not frame[event] then
		frame[event] = {}
		frame:RegisterEvent(event)
	end
	local t = frame[event]
	t[#t+1] = func
end

-- Init
local init = {}
B:AddEventScript("PLAYER_LOGIN", function()
	for _,f in ipairs(init) do f() end
	init = nil
end)

function B:AddInitScript(func) init[#init+1] = func end
