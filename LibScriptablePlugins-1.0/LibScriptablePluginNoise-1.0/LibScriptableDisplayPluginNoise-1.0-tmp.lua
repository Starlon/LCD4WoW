local MAJOR = "LibScriptablePluginNoise-1.0" 
local MINOR = 16

local PluginNoise = LibStub:NewLibrary(MAJOR, MINOR)
if not PluginNoise then return end
local LibBuffer = LibStub("LibScriptableBuffer-1.0", true)
assert(LibBuffer, MAJOR .. " requires LibScriptableBuffer-1.0")

local frame = CreateFrame("Frame")
local data = {}
local buffers = {}
local objects = {}
local update
local maxhit = 0
local MAXRECORDS = 32

local rand = LibBuffer:New(MAJOR .. " random", MAXRECORDS, 0)
for i = 0, MAXRECORDS - 1 do
	rand.buffer[i] = random(100) / 100
end
rand = rand:MovingAverageExp(0.5, nil, rand)

local function onEvent(self, event, ...)
	if PluginNoise[event] then
		PluginNoise[event](PluginNoise, ...)
	end
end

frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
frame:SetScript("OnEvent", onEvent)

local function randomize()
	for i = 0, MAXRECORDS - 1 do
		rand.buffer[i] = random(100) / 100
	end
	rand = rand:MovingAverageExp(0.3, nil, rand)
end

local timer = 0
local function update(frame, elapsed)
	timer = timer + elapsed
	if timer < .3 then return end
	timer = 0
	for unit, record in pairs(data) do
		buffers[unit] = record:MovingAverageExp(0.3, nil, buffers[unit])
	end
	--randomize()
end
frame:SetScript("OnUpdate", update)
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
	"focustargettarget"
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
	
	tinsert(objects, obj)

	return environment, obj
	
end

local events = {
	SWING_DAMAGE = true,
	RANGE_DAMAGE = true,
	SPELL_DAMAGE = true,
	SPELL_PERIODIC_DAMAGE = true,
	DAMAGE_SHIELD = true,
	DAMAGE_SPLIT = true,
}

local timer = 0
local startTime = GetTime()
function PluginNoise:COMBAT_LOG_EVENT_UNFILTERED(_, eventType, id, _, _, _, _, _, spellID, _, _, damage, _, _, _, critical)
	if not events[eventType] then return end
	local elapsed = GetTime() - startTime
	timer = timer + elapsed
	if timer < 1 then StarTip:Print("Throttled") return end
	timer = 0
	startTime = GetTime()
	StarTip:Print("Test")
	if eventType == "SWING_DAMAGE" then
		damage = spellID
	end
	
	local unit = "local"
	
	for k, v in pairs(SINGLETON_CLASSIFICATIONS) do
		if UnitGUID(v) == id then
			unit = v
		end
	end
	
	for k, v in pairs(UNIT_RAID_GROUPS) do
		for i = 1, 40 do
			if UnitGUID(v..i) == id then
				unit = v..i
			end
		end
	end
	
	for k, v in pairs(UNIT_PARTY_GROUPS) do
		for i = 1, 5 do
			if UnitGUID(v..i) == id then
				unit = v..i
			end
		end
	end
	
	if UnitExists(unit) and not UnitIsPlayer(unit) then
		return
	end
	
	data[unit] = data[unit] or LibBuffer:New(MAJOR .. " " .. unit, MAXRECORDS, 1)
	
	data[unit].count = data[unit].count or 0
	data[unit].max = data[unit].max or 1
	data[unit].critical = critical
	
	if damage > maxhit then 
		maxhit = damage
	end
	if damage > data[unit].max then
		data[unit].max = damage
	end
	
	data[unit].buffer[data[unit].count] = damage / data[unit].max * 2
	data[unit].count = (data[unit].count + 1) % MAXRECORDS
	
	buffers[unit] = data[unit]:MovingAverageExp(0.3, nil, buffers[unit])
end

-- Return noise data for the provided unit, else return random data
-- @usage UnitNoise(unit)
-- @param unit The associated unit id
-- @return first return: a LibBuffer filled with noise data. second return: isBeat data -- AKA critical strikes.
function PluginNoise.UnitNoise(unit)
	local isBeat
	if data[unit] and data[unit].critical then
		data[unit].critical = false
		isBeat = true
	end
	if not buffers[unit] and not isBeat then
		local total = 0
		for i = 1, rand:Size() - 1 do
			total = total + rand.buffer[i]
		end
		isBeat = (total / rand:Size()) > .8
	end
	return (buffers[unit] or rand), isBeat
end

-- Wipe individual records or all noise data
-- @usage WipeNoise([unit])
-- @param An optional unit id
-- @return Nothing
function PluginNoise.WipeNoise(unit)
	if unit then 
		if buffers[unit] then buffers[unit]:Del() end
		data[unit] = nil; buffers[unit] = nil; 
	else 
		data = {}; buffers = {} 
	end
end