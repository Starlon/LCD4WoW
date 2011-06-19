
local MAJOR = "LibScriptablePluginUnitTooltipScan-1.0" 
local MINOR = 18
assert(LibStub, MAJOR.." requires LibStub") 
local LibUnitTooltipScan = LibStub:NewLibrary(MAJOR, MINOR)
if not LibUnitTooltipScan then return end
local self = LibUnitTooltipScan

if not LibUnitTooltipScan.__index then 
	LibUnitTooltipScan.__index = LibUnitTooltipScan
end

local pool = setmetatable({}, {__mode = "k"})

local objects = {}
local objectsDict = {}
local update
local frame = CreateFrame("Frame")
local tooltip = CreateFrame("GameTooltip", "LibScriptableUnitTooltipScan", UIParent, "GameTooltipTemplate")
local initialized

local factionList = {}

if not LibUnitTooltipScan.__index then
	LibUnitTooltipScan.__index = LibUnitTooltipScan
end

LibUnitTooltipScan.leftLines = {}
LibUnitTooltipScan.rightLines = {}

function initialize()
	if initialized then return end
	for i = 1, 20 do
		tooltip:AddDoubleLine(" ", " ")
		LibUnitTooltipScan.leftLines[i] = _G["LibScriptableUnitTooltipScanTextLeft" .. i]
		LibUnitTooltipScan.rightLines[i] = _G["LibScriptableUnitTooltipScanTextRight" .. i]
	end
	initialized = true
end

local function onEvent(frame, event)
	if event == "UPDATE_FACTION" then
		for i = 1, GetNumFactions() do
			local name = GetFactionInfo(i)
			factionList[name] = true
		end
	end
end

local init

--- Populate an environment with this plugin's fields
-- @usage :New(environment) 
-- @param environment This will be the environment when setfenv is called.
-- @return A new plugin object, aka the environment
function LibUnitTooltipScan:New(environment)

	if not init then
		frame:SetScript("OnEvent", onEvent)
		frame:RegisterEvent("UPDATE_FACTION")
		initialize()
		init = true
	end

	environment.GetUnitTooltipScan = self.GetUnitTooltipScan
	environment.GetUnitTooltipStats = self.GetUnitTooltipScan -- for compatibility, but use the above
	
	return environment
end

local getLocation, getGuild, getName

local scanunit

--- Return the default unit tooltip's information
-- @usage LibUnitTooltipScan:GetUnitTooltipScan(unit)
-- @param unit The unitid to retrieve information about
-- @return Name, guild, and location
function LibUnitTooltipScan.GetUnitTooltipScan(unit)
	if not unit then unit = "mouseover" end
    if not UnitIsConnected(unit) then
        return nil
    end
	tooltip:Hide()
	tooltip:ClearLines()
	tooltip:SetOwner(UIParent, "ANCHOR_NONE")
	tooltip:SetUnit(unit)
	tooltip:Show()
	scanunit = unit
	return getName(), getGuild(), UnitIsPlayer(unit) and getLocation()
end

local LEVEL_start = "^" .. (type(LEVEL) == "string" and LEVEL or "Level")
function getLocation()
    local left_2 = self.leftLines[2]:GetText()
    local left_3 = self.leftLines[3]:GetText()
    if not left_2 or not left_3 then
        return nil
    end
    local hasGuild = not left_2:find(LEVEL_start)
    local factionText = not hasGuild and left_3 or self.leftLines[4]:GetText()
    if factionText == PVP then
        factionText = nil
    end

    local hasFaction = factionText and not UnitPlayerControlled(scanunit) and not UnitIsPlayer(scanunit) and (UnitFactionGroup(scanunit) or factionList[factionText])

	if UnitInParty(scanunit) or UnitInRaid(scanunit) then
		if hasGuild and hasFaction then
			return self.leftLines[5]:GetText()
		elseif (hasGuild or hasFaction) then
			if self.leftLines[4]:GetText() == PVP then return nil end
			return self.leftLines[4]:GetText()
		elseif not left_3:find(LEVEL_start) and not left_3 == PVP then
			return left_3
		end
	end
	return nil
end

function getGuild()
    local left_2 = self.leftLines[2]:GetText()
	if not left_2 then return nil end
    if left_2:find(LEVEL_start) then return nil end
    return "<" .. left_2 .. ">"
end

function getName()
	return self.leftLines[1]:GetText()
end