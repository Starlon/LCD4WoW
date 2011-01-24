local MAJOR = "LibScriptablePluginTalents-1.0"
local MINOR = 16
local PluginTalents = LibStub:NewLibrary(MAJOR, MINOR)
if not PluginTalents then return end
local GroupTalents = LibStub("LibGroupTalents-1.0", true)
assert(GroupTalents, MAJOR .. " requires LibGroupTalents-1.0")
local TalentQuery = LibStub("LibTalentQuery-1.0", true)
assert(TalentQuery, MAJOR .. " requires LibTalentQuery-1.0")
local LibTimer = LibStub("LibScriptableUtilsTimer-1.0", true)
assert(LibTimer, MAJOR .. " requires LibScriptableUtilsTimer-1.0")
local L = LibStub("LibScriptableUtilsLocale-1.0", true)
assert(L, MAJOR .. " requires LibScriptableUtilsLocale-1.0")
L = L.L

local _G = _G
local GameTooltip = _G.GameTooltip
local UnitIsUnit = _G.UnitIsUnit
local GetNumTalentTabs = _G.GetNumTalentTabs
local GetTalentTabInfo = _G.GetTalentTabInfo
local UnitExists = _G.UnitExists
local UnitIsPlayer = _G.UnitIsPlayer
local UnitName = _G.UnitName
local EXPIRE_TIME = 5000
local spec = {}
local frame = CreateFrame("Frame")
local count = 0
local query = {}
local spec_cache = setmetatable({}, {__mode = "v"})
local spec_role = {}
local inspectUnit
local THROTTLE_TIME = 500
local throttleTimer 

if not PluginTalents.__index then
	PluginTalents.__index = PluginTalents
end

local pool = setmetatable({}, {__mode = "k"})
local function new(...)
	local obj = next(pool)
	if obj then
		pool[obj] = nil
	else
		obj = {}
	end
	for i = 1, select("#", ...) do
		obj[i] = select(i, ...)
	end
	return obj
end

local function del(obj)
	wipe(obj)
	pool[obj] = true
end

--- Populate an environment with this plugin's fields
-- @usage :New(environment) 
-- @param environment This will be the environment when setfenv is called.
-- @return A new plugin object, aka the environment
function PluginTalents:New(environment)

	environment.SpecText = self.SpecText
	environment.GetSpec = self.GetSpec
	environment.ClearSpec = self.ClearSpec
	environment.GetRole = self.GetRole
	environment.SendQuery = self.SendQuery
	environment.UnitILevel = self.UnitILevel
	
	return environment
end

local indexOf = function(t, val, talengGroup)
	for i=1, #t do
		if t[i][2] == val then
			return i
		end
	end
end

local talentTrees = {
	[L["Druid"]] = {L["Balance"], L["Feral Combat"], L["Restoration"]},
	[L["Hunter"]] = {L["Beast Mastery"], L["Marksmanship"], L["Survival"]},
	[L["Mage"]] = {L["Arcane"], L["Fire"], L["Frost"]},
	[L["Paladin"]] = {L["Holy"], L["Protection"], L["Retribution"]},
	[L["Priest"]] = {L["Discipline"], L["Holy"], L["Shadow"]},
	[L["Rogue"]] = {L["Assassination"], L["Combat"], L["Subtlety"]},
	[L["Shaman"]] = {L["Elemental"], L["Enhancement"], L["Restoration"]},
	[L["Warlock"]] = {L["Affliction"], L["Demonology"], L["Destruction"]},
	[L["Warrior"]] = {L["Arms"], L["Fury"], L["Protection"]},
	[L["Death Knight"]] = {L["Blood"], L["Frost"], L["Unholy"]}
}

local roleTypes = {
	melee = L["Melee"],
	caster = L["Caster"],
	healer = L["Healer"],
	tank = L["Tank"]
}

-- From LibInspectLess
local function GetInspectItemLinks(unit)
	local done = true
	for i=1, 19 do
		if GetInventoryItemTexture(unit, i) and not GetInventoryItemLink(unit, i) then
			--GetTexture always return stuff but GetLink is not.
			done = false
		end
	end
	return done
end

-- this is unthrottled, but it doesn't matter since it's such a short interval before the client finishes downloading everything
local function ItemOnUpdate(elapsed)
	local done = GetInspectItemLinks(inspectUnit)
	local count = 0
	if done then
		local guid = UnitGUID(inspectUnit)
		local total = 0
		for i = 1, 18 do
			local ItemLink = GetInventoryItemLink(inspectUnit, i);
			if ItemLink and i ~= 4 then
				local _, _, _, ilvl = GetItemInfo(ItemLink);
				total = total + ilvl
				count = count + 1
			end
		end
		
		if guid and spec[guid] and count > 0 then
			spec[guid].ilvl = floor(total / 17 + 0.5)
		end
		
		frame:SetScript("OnUpdate", nil)
	end
end


local function sortfunc(a, b)
	return a>b
end

function PluginTalents:OnUpdate(event, guid, unitid, newSpec, talent1, talent2, talent3)
	local class = UnitClass(unitid)
	if not talentTrees[class] then return end
	local guid = UnitGUID(unitid)
	local isnotplayer = not UnitIsUnit("player", unitid)
	local talentGroup = GetActiveTalentGroup(isnotplayer)
	
	if not spec[guid] then
		spec[guid] = new()
		spec[guid].guid = guid
	end

	if not spec[guid][talentGroup] then
		spec[guid][talentGroup] = new()
	end

	for tab = 1, 3 do
		spec[guid][talentGroup][tab] = new(nil, nil, nil, "None", nil)
	end
	
	local specNames 
	if GroupTalents:GetTreeNames(class) then
		specNames = new(GroupTalents:GetTreeNames(class))
	else
		specNames = new(unpack(talentTrees[class]))
	end

	local highPoints = new()
	local pointsspent = new(talent1, talent2, talent3)
	
	for i, point in ipairs(pointsspent) do
		local _, treename, _, iconTexture = GetTalentTabInfo(i, isnotplayer, false, talentGroup)
	
		highPoints[i] = point
		spec[guid][talentGroup][i] = {treename, point, iconTexture}
	end
	
	table.sort(highPoints, sortfunc)
	
	local i = indexOf(spec[guid][talentGroup], highPoints[1])
	spec[guid].tab = i
	spec[guid].talentGroup = talentGroup

	del(specNames)
	del(highPoints)
	del(pointsspent)
	
	inspectUnit = unitid
	
	frame:SetScript("OnUpdate", ItemOnUpdate)
end

function PluginTalents:TalentQuery_Ready(e, name, realm, unitid)
	local class = UnitClass(unitid)
	local specNames = new()
	local guid = UnitGUID(unitid)
	local isnotplayer = not UnitIsUnit("player", unitid)
	local talentGroup = GetActiveTalentGroup(isnotplayer)

	if not spec[guid] then
		spec[guid] = new()
		spec[guid].guid = guid
	end

	if not spec[guid][talentGroup] then
		spec[guid][talentGroup] = new()
	end

	for tab = 1, 3 do
		spec[guid][talentGroup][tab] = new(nil, nil, nil, "None", nil)
	end
	
	local specNames = new()
	local highPoints = new()
	for tab = 1, GetNumTalentTabs(isnotplayer) do
		local _, treename, _, iconTexture, pointsSpent = GetTalentTabInfo(tab, isnotplayer, false, talentGroup)
		highPoints[tab] = pointsSpent
		spec[guid][talentGroup][tab] = new(treename, pointsSpent, iconTexture)
		specNames[tab] = treename
	end
	
	table.sort(highPoints, sortfunc)
	
	local i = indexOf(spec[guid][talentGroup], highPoints[1])
	spec[guid].tab = i
	spec[guid].talentGroup = talentGroup
	
	del(specNames)
	del(highPoints)

	inspectUnit = unitid
	
	frame:SetScript("OnUpdate", ItemOnUpdate)	
end

function PluginTalents:OnRoleChange(event, guid, unit, newrole, oldrole)
	spec[guid] = nil
	spec_cache[guid] = nil
	spec_role[guid].newrole = newrole
	spec_role[guid].oldrole = oldrole
end

local function okToInspect(unit)
	local guid = UnitGUID(unit)
	return 
end

function PluginTalents.SendQuery(unit)
	local guid = UnitGUID(unit)
	if not UnitIsPlayer(unit) or not (CheckInteractDistance(unit, 1) and not spec[guid]) then return end

	if UnitIsUnit(unit, "player") then
		PluginTalents:TalentQuery_Ready(_, UnitName(unit), nil, "player")
	else
		TalentQuery:Query(unit)
	end
end

function PluginTalents.UnitILevel(unit)
	if type(unit) ~= "string" then return end
	local guid = UnitGUID(unit)
	if not UnitIsPlayer(unit) or not UnitExists(unit) then return end
	if not CheckInteractDistance(unit, 1) and not spec[guid] then return L["Out of Range"] end
	
	local periods = ""
	for i = 0, count % 3 do
		periods = periods .. "."
	end
	count = count + 1
	
	local talentGroup = spec[guid] and spec[guid].talentGroup
	
	if not spec[guid] or not spec[guid].ilvl then return L["Loading"] .. periods end
	
	return format("%d", spec[guid].ilvl)
end

function PluginTalents.SpecText(unit)
	if type(unit) ~= "string" then return end
	if not UnitIsPlayer(unit) or not UnitExists(unit) then return end
	local guid = UnitGUID(unit)
	if not CheckInteractDistance(unit, 1) and not spec[guid] then return L["Out of Range"] end
	local guid = UnitGUID(unit)
			
	local periods = ""
	for i = 0, count % 3 do
		periods = periods .. "."
	end
	count = count + 1
	
	if not spec[guid] then return L["Loading"] .. periods end
	
	local cur = spec[guid][spec[guid].talentGroup]
	local one = cur[1][2]
	local two = cur[2][2]
	local three = cur[3][2]
	local name = cur[spec[guid].tab][1]
	local texture = cur[spec[guid].tab][3]
	
	if not name or not texture or not one or not two or not three then return end
	
	return ('|T%s:12|t %s (%d/%d/%d)'):format(texture or "", name, one, two, three)
end

function PluginTalents.GetSpec(unit)
	if type(unit) ~= "string" or not UnitExists(unit) then return end
	local guid = UnitGUID(unit)

	return unpack(spec[guid])
end

function PluginTalents.GetSpecData()
	return spec
end

function PluginTalents.ClearSpec(unit)
	if type(unit) ~= "string" or not UnitExists(unit) then return end
	local guid = UnitGUID(unit)
	spec[guid] = nil
end

function PluginTalents.GetRole(unit)
	local guid = UnitGUID(unit)
	if spec[guid] then
		return roleTypes[spec[guid].role], roleTypes[spec[guid].oldrole or -1]
	end
end

local function onTooltipSetUnit()
	
	local _, unit = GameTooltip:GetUnit()
	
	if not CheckInteractDistance(unit, 1) then return end
	
	if unit then
		GroupTalents:RefreshTalentsByUnit(unit)
	end
	
	if not UnitIsPlayer(unit) then return end
	
	local guid = UnitGUID(unit)
	
	if spec_cache[guid] and spec_cache[guid].ilvl then
		spec[guid] = spec_cache[guid]
		spec_cache[guid] = nil
	else
		throttleTimer:Start(nil, unit) -- Plugintalents.SendQuery(unit)
	end
	frame:SetScript("OnUpdate", nil)
end
GameTooltip:HookScript("OnTooltipSetUnit", onTooltipSetUnit)

local function onHide()
	for i, v in ipairs(spec) do
		if v[5] == "mouseover" then
			del(v)
			spec_cache[v.guid] = v
			spec[k] = nil
		end
	end
	frame:SetScript("OnUpdate", nil)
end
GameTooltip:HookScript("OnHide", onHide)

GroupTalents.RegisterCallback(PluginTalents, "LibGroupTalents_Update", "OnUpdate")
TalentQuery.RegisterCallback(PluginTalents, "TalentQuery_Ready")
TalentQuery.RegisterCallback(PluginTalents, "LibGroupTalents_RoleChange", "OnRoleChange")
throttleTimer = LibTimer:New(MAJOR .. " throttle timer", THROTTLE_TIME, true, PluginTalents.SendQuery)

