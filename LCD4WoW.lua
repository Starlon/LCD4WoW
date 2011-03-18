LCD4WoW = StarTip or LibStub("AceAddon-3.0"):NewAddon("LCD4WoW: 1.1.15b", "AceConsole-3.0", "AceHook-3.0", "AceEvent-3.0", "AceComm-3.0", "AceSerializer-3.0") 
LCD4WoW.version = GetAddOnMetadata("LCD4WoW", "X-LCD4WoW-Version") or ""
if StarTip then return end
local LibDBIcon = LibStub("LibDBIcon-1.0")
local LSM = _G.LibStub("LibSharedMedia-3.0")
local LDB = LibStub:GetLibrary("LibDataBroker-1.1")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local LibError = LibStub("LibScriptableUtilsError-1.0")
local LibQTip = LibStub("LibQTip-1.0")

local _G = _G
local GameTooltip = _G.GameTooltip
local ipairs, pairs = _G.ipairs, _G.pairs

local LDB = LibStub("LibDataBroker-1.1"):NewDataObject("LCD4WoW", {
	type = "data source",
	text = "LCD4WoW",
	icon = "Interface\\Icons\\INV_Chest_Cloth_17",
	OnClick = function() LCD4WoW:OpenConfig() end
})

local defaults = {profile={minimap={}, modules={}, errorLevel=1}}

local options = {
	name = "LCD4WoW",
	type = "group",
	args = {}
}

function LCD4WoW:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("LCD4WoWDB", defaults, "Default")
	
	LibStub("AceConfig-3.0"):RegisterOptionsTable("LCD4WoW", options)
	self:RegisterChatCommand("lcd4wow", "OpenConfig")
	self:RegisterChatCommand("lcd4linux4wow", "OpenConfig")
	AceConfigDialog:AddToBlizOptions("LCD4WoW")
	LibDBIcon:Register("LCD4WoWLDB", LDB, self.db.profile.minimap)
	
end

function LCD4WoW:OnEnable()
	if self.db.profile.minimap.hide then
		LibDBIcon:Hide("LCD4WoWLDB")
	else
		LibDBIcon:Show("LCD4WoWLDB")
	end
	
	for k,v in self:IterateModules() do
		if (self.db.profile.modules[k]  == nil and not v.defaultOff) or self.db.profile.modules[k] then
			v:Enable()
		end
	end
		
	self:RebuildOpts()
	
	self:RegisterEvent("MODIFIER_STATE_CHANGED")
end

function LCD4WoW:OnDisable()
	for k, v in self:IterateModules() do
		v:Disable()
	end
	self:UnRegisterEvent("MODIFIER_STATE_CHANGED")
end

function LCD4WoW:OpenConfig()
	AceConfigDialog:SetDefaultSize("LCD4WoW", 800, 450)
	AceConfigDialog:Open("LCD4WoW")	
end


function LCD4WoW:RebuildOpts()
	local driver = self:GetModule("LCD4WoW")
	options.args = driver:GetOptions()
	options.args.errorLevel = {
		name = "Error Verbosity",
		type = "select",
		values = LibError.defaultTexts,
		get = function()
			return self.db.profile.errorLevel
		end,
		set = function(info, v)
			self.db.profile.errorLevel = v
		end,
		order = 100
	}
end

-- Taken from CowTip and modified a bit
function LCD4WoW:MODIFIER_STATE_CHANGED(ev, modifier, up, ...)
	for i, v in self:IterateModules() do
		if v.MODIFIER_STATE_CHANGED then
			v:MODIFIER_STATE_CHANGED(ev, modifier, up, ...)
		end
	end
	
	local mod
	if self.db.profile.modifier == 2 then
		mod = (modifier == "LCTRL" or modifier == "RCTRL") and "LCTRL"
		modifier = "LCTRL"
	elseif self.db.profile.modifier == 3 then
		mod = (modifier == "LALT" or modifier == "RALT") and "LALT"
		modifier = "LALT"
	elseif self.db.profilemodifier == 4 then
		mod = (modifier == "LSHIFT" or modifier == "RSHIFT") and "LSHIFT"
		modifier = "LSHIFT"
	end
		
	if mod ~= modifier then
		return
	end
	
	if up == 0 then
		GameTooltip:Hide()
		return
	end
	
	local mouseover_unit = StarTip:GetMouseoverUnit()

	local frame = GetMouseFocus()
	if frame == WorldFrame or frame == UIParent then
		if not UnitExists(mouseover_unit) then
			GameTooltip:Hide()
			return
		end
		GameTooltip:Hide()
		GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
		GameTooltip:SetUnit(mouseover_unit)
		GameTooltip:Show()
	else
		local OnLeave, OnEnter = frame:GetScript("OnLeave"), frame:GetScript("OnEnter")
		if OnLeave then
			_G.this = frame
			OnLeave(frame)
			_G.this = nil
		end
		if OnEnter then
			_G.this = frame
			OnEnter(frame)
			_G.this = nil
		end
	end
end
