local MAJOR = "LibScriptablePluginNoise-1.0" 
local MINOR = 19

local PluginNoise = LibStub:NewLibrary(MAJOR, MINOR)
if not PluginNoise then return end
local LibBuffer = LibStub("LibScriptableUtilsBuffer-1.0", true)
assert(LibBuffer, MAJOR .. " requires LibScriptableUtilsBuffer-1.0")

local frame = CreateFrame("Frame")
local data = {}
local buffers = {}
local objects = {}
local update
local maxhit = 0
local MAXRECORDS = 32

local rand = LibBuffer:New(MAJOR .. " random", MAXRECORDS, 0)
for i = 0, MAXRECORDS - 1 do
	rand.buffer[i] = math.sin(random(100)) -- / 100
end
rand = rand:MovingAverageExp(0.5, nil, rand)

local function onEvent(self, event, ...)
	if PluginNoise[event] then
		PluginNoise[event](PluginNoise, ...)
	end
end
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

local function randomize()
	for i = 0, MAXRECORDS - 1 do
		rand.buffer[i] = random(100) / 100
	end
	rand = rand:MovingAverageExp(0.2, nil, rand)
end

local timer = 0
local function update(frame, elapsed)
	timer = timer + elapsed
	if timer < .5 then return end
	timer = 0
	randomize()
	for unit, buffer in pairs(buffers) do
		
		if data[unit] then
			buffers[unit] = data[unit]:MovingAverageExp(0.9, nil)
		end
	end
end
frame:Show()

local data = {}

if not PluginNoise.__index then
	PluginNoise.__index = PluginNoise
end

local count = 0

local SINGLETON_CLASSIFICATIONS = {
	"player",
	"pet",
	"pettarget",
	"target",
	"targettarget",
	"targettargettarget",
	"focus",
	"focustarget",
	"focustargettarget",
	"mouseover",
}

local UNIT_PARTY_GROUPS = {
	"party",
	"partytarget",
	"partytargettarget",
	"partypet",
	"partypettarget",
	"partypettargettarget"
}

local UNIT_RAID_GROUPS = {
	"raid",
	"raidtarget",
	"raidtargettarget",
	"raidpet",
	"raidpettarget",
	"raidpettargettarget",
}

local UNITS = {UNIT_RAID_GROUPS=true, UNIT_PARTY_GROUPS=true, SINGLETON_CLASSIFICATION=true}

-- Populate an environment with this plugin's fields
-- @usage :New(environment) 
-- @parma environment This will be the environment when setfenv is called.
-- @param size How large the samples are
-- @return A new plugin object, aka the environment
function PluginNoise:New(environment, size)
		
	local obj = {}
	setmetatable(obj, self)

	count = count + 1
	obj.buffer = LibBuffer:New(MAJOR.."-"..count, size or 96, 0)
	
	environment.UnitNoise = self.UnitNoise
	environment.WipeNoise = self.WipeNoise
	environment.StartNoise = self.StartNoise
	environment.StopNoise = self.StopNoise
	
	tinsert(objects, obj)
	
	return environment, obj
	
end

function PluginNoise.StartNoise()
	frame:SetScript("OnUpdate", update)
	frame:SetScript("OnEvent", onEvent)
end

function PluginNoise.StopNoise()
	frame:SetScript("OnUpdate", nil)
	frame:SetScript("OnEvent", nil)
end

local events = {
	SWING_DAMAGE = true,
	RANGE_DAMAGE = true,
	SPELL_DAMAGE = true,
	SPELL_PERIODIC_DAMAGE = true,
	DAMAGE_SHIELD = true,
	DAMAGE_SPLIT = true,
}

local lastTime = GetTime()
function PluginNoise:COMBAT_LOG_EVENT_UNFILTERED(timestamp, eventType, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName,
		destFlags, destRaidFlags, spellID, spellName, spellSchool, damage, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing)
	local elapsed = GetTime() - lastTime
	if elapsed < .05 then return end
	lastTime = GetTime()

	if not events[eventType] then return end
	
	if eventType == "SWING_DAMAGE" then
		damage = spellID
	end
	
	local unit = "local"
	
	for k, v in pairs(SINGLETON_CLASSIFICATIONS) do
		if UnitGUID(v) == sourceGUID then
			unit = v
		end
	end
	
	for k, v in pairs(UNIT_RAID_GROUPS) do
		for i = 1, 40 do
			if UnitGUID(v..i) == sourceGUID then
				unit = v..i
			end
		end
	end
	
	for k, v in pairs(UNIT_PARTY_GROUPS) do
		for i = 1, 5 do
			if UnitGUID(v..i) == sourceGUID then
				unit = v..i
			end
		end
	end
	
	unit = "local"
		
	data[unit] = data[unit] or LibBuffer:New(MAJOR .. " " .. unit, MAXRECORDS, 0)
	
	data[unit].count = data[unit].count or 0
	data[unit].max = data[unit].max or 0
	data[unit].critical = data[unit].critical or critical
	
	if damage > maxhit then 
		maxhit = damage
	end
	if damage > data[unit].max then
		data[unit].max = damage
	end
	
	data[unit].buffer[data[unit].count] = damage / data[unit].max + -.5 
	if unit ~= "local" then
		data["local"].count = data["local"].count or 0
		data["local"].buffer[data["local"].count] = data[unit].buffer[data[unit].count]
		data["local"].count = (data["local"].count + 1) % MAXRECORDS
	end
	data[unit].count = (data[unit].count + 1) % MAXRECORDS

	buffers[unit] = data[unit]:MovingAverageExp(0.2	, nil, buffers[unit])
end

--- Return noise data for the provided unit, else return random data
-- @usage UnitNoise(unit)
-- @param unit The associated unit id
-- @param random Boolean indicating whether to return random data, otherwise return data for the unit if it exists
-- @return first return: a LibBuffer filled with noise data. second return: isBeat data -- AKA critical strikes.
function PluginNoise.UnitNoise(unit, random)
	local isBeat = data[unit] and data[unit].critical
	if data[unit] then data[unit].critical = false end
	if not buffers[unit] then
		local total = 0
		local max = 0
		for i = 1, rand:Size() - 1 do
			total = total + rand.buffer[i] * 100
			if rand.buffer[i] > max then
				max = rand.buffer[i]
			end
		end
		isBeat = (total / rand:Size()) > 52
	end
		
	if isBeat then 
		isBeat = 1
	else
		isBeat = 0
	end
	
	return (random and rand) or (buffers[unit] or rand), isBeat
end

--- Wipe individual unit records or all noise data
-- @usage WipeNoise([unit])
-- @param An optional unit id. If not provided then all data is wiped.
-- @return Nothing
function PluginNoise.WipeNoise(unit)
	if unit then 
		if buffers[unit] then buffers[unit]:Del() end
		data[unit] = nil; buffers[unit] = nil; 
	else 
		data = {}; buffers = {} 
	end
	randomize()
end
