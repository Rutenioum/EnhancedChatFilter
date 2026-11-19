-- ECF
local addonName, ecf = ...
local B, L, C = unpack(ecf)

local iconPath = "Interface\\AddOns\\"..addonName.."\\Media\\ECFIcon"

-- LibDBIcon owns button creation, dragging, position saving and collector hand-off
function C:SetupMinimapButton()
	if C.minimapBroker then return end
	local ldb = LibStub("LibDataBroker-1.1", true)
	local dbicon = LibStub("LibDBIcon-1.0", true)
	if not ldb or not dbicon then
		print(L["MinimapLibMissing"])
		return
	end

	local broker = ldb:NewDataObject(addonName, {
		type = "launcher",
		icon = iconPath,
		OnClick = function(_, button)
			if button == "LeftButton" then C:OpenSettings() end
		end,
		OnTooltipShow = function(tooltip)
			if not tooltip then return end
			tooltip:AddLine(addonName, 1, 1, 1)
			tooltip:AddLine(L["MinimapButtonClickHint"], 0.8, 0.8, 0.8)
		end,
	})
	if not broker then return end
	if not dbicon:IsRegistered(addonName) then
		dbicon:Register(addonName, broker, C.db.minimap)
	end
	C.minimapBroker = broker
	C.minimapIcon = dbicon
end

B:AddInitScript(function()
	-- Optional UI failures must not abort the following chat-filter initializers.
	local ok, err = pcall(C.SetupMinimapButton, C)
	if not ok then print(L["MinimapInitFailed"], tostring(err)) end
end)
