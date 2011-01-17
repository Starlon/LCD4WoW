local MAJOR = "LibScriptablePluginRecount-1.0" 
local MINOR = 16

local PluginRecount = LibStub:NewLibrary(MAJOR, MINOR)
if not PluginRecount then return end

local ScriptEnv = {}

local Recount

--- Populate an environment with this plugin's fields
-- @usage :New(environment) 
-- @param environment This will be the environment when setfenv is called.
-- @return A new plugin object, aka the environment
function PluginRecount:New(environment)
	for k, v in pairs(ScriptEnv) do
		environment[k] = v
		self[k] = v
	end
	if not Recount then Recount = _G.Recount end
	return environment
end

local function sortFunc(a, b)
	if a[2]>b[2] then
		return true
	elseif a[2]==b[2] then
		if a[1]<b[1] then
			return true
		end
	end
	return false
end

--- Return Recount data for a given unit
-- @usage RecountUnitData(unit)
-- @param unit A valid unit id
-- @return value, percent, persecond, maxValue, total
local function RecountUnitData(unit)
	if not Recount then return end
	local dataMode=Recount.MainWindowData[Recount.db.profile.MainWindowMode]
	local data=Recount.db2.combatants
	local reportTable=Recount.MainWindow.DispTableSorted
	local Total = 0
	local maxValue = 0
	
	if table.maxn(reportTable)>0 then
		table.sort(reportTable,sortFunc)
		maxValue=reportTable[1][2] or 0
	end
		
	if type(data)=="table" then
		for k, v in pairs(data) do
			if v.Fights[Recount.db.profile.CurDataSet] then
				local Value = dataMode[2](Recount, v, 1)
				Total = Total + Value
			end
		end
		if type(dataMode[4])=="function" then
			Total=Recount.MainWindow:SpecialTotal()
		end
		for k,v in pairs(data) do
			if v.GUID == (UnitGUID(unit)) and v.Fights[Recount.db.profile.CurDataSet] then
				local Value, PerSec = dataMode[2](Recount, v, 1)
				if type(PerSec) == "number" then
					PerSec = floor(10*PerSec)/10
				elseif type(PerSec) == "string" then
					PerSec = floor(10*tonumber(PerSec))/10
				end
				if type(Value) == "number" then
					return Value, Total ~= 0 and math.floor(Value/Total*100) or 0, PerSec, maxValue, Total
				end
			end
		end
	end
end
ScriptEnv.RecountUnitData = RecountUnitData

--- Return the raw Recount value for a given unit. The currently active Recount window is used.
-- @usage RecountUnitValue(unit)
-- @param unit A valid unit id
-- @return Recount information for a given unit
local function RecountUnitValue(unit)
	return select(1, RecountUnitData(unit))
end
ScriptEnv.RecountUnitValue = RecountUnitValue

--- Return value/total. The currently active Recount window is used.
-- @usage RecountUnitPercent(unit)
-- @param unit A valid unit id
-- @return Recount information for a given unit.
local function RecountUnitPercent(unit)
	return select(2, RecountUnitData(unit))
end
ScriptEnv.RecountUnitPercent = RecountUnitPercent

--- Return per second information for a unit. The currently active Recount window is used.
-- @usage RecountUnitPerSecond(unit)
-- @param unit A valid unit id
-- @return Recount information for a given unit.
local function RecountUnitPerSecond(unit)
	return select(3, RecountUnitData(unit))
end
ScriptEnv.RecountUnitPerSecond = RecountUnitPerSecond

--- Return the maximum value for the currently active Recount window.
-- @usage RecountUnitMaxValue(unit)
-- @return Recount max value 
local function RecountUnitMaxValue()
	return select(4, RecountUnitData("player"))
end
ScriptEnv.RecountUnitMaxValue = RecountUnitMaxValue

--- Return the current window's total
-- @usage RecountGetTotal()
-- @return Recount total for the currently active window.
local function RecountGetTotal()
	return select(5, RecountUnitData("player"))
end
ScriptEnv.RecountGetTotal = RecountGetTotal
	