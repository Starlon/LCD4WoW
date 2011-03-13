
local MAJOR = "LibScriptableUtilsTimer-1.0" 
local MINOR = 18
assert(LibStub, MAJOR.." requires LibStub") 
local LibTimer = LibStub:NewLibrary(MAJOR, MINOR)
if not LibTimer then return end
local LibError = LibStub("LibScriptableUtilsError-1.0")
assert(LibError, MAJOR .. " requires LibScriptableUtilsError-1.0")

local pool = setmetatable({}, {__mode = "k"})

local cache = {}
local storage = {}
local update
local frame = CreateFrame("Frame")
local throttleFrame = CreateFrame("Frame")
local manageFrame = CreateFrame("Frame")
frame:Show()
throttleFrame:Show()
manageFrame:Show()

local DEFAULT_LIMIT = 100

if not LibTimer.__index then
	LibTimer.__index = LibTimer
end

local function sortfunc(a, b)
	return a.active > b.active
end

local manageElapsed = 0
local function manageTimers(frame, elapsed) 
	manageElapsed = manageElapsed + elapsed
	if manageElapsed < 1 then
		return
	end
	manageElapsed = 0
	local now = GetTime()
	local removal = {}
	local doSort = false
	for i, v in ipairs(storage) do
		if v.active ~= 0 then
			tinsert(cache, v)
			tinsert(removal, 1)
			v.lastUpdate = now
			doSort = true
		end
	end
	for i, v in ipairs(removal) do
		tremove(storage, v)
	end
	wipe(removal)
	for i, v in ipairs(cache) do
		if (now - v.lastUpdate) > 5 and v.active == 0 then
			tinsert(storage, v)
			tinsert(removal, i)
		end
	end
	for i, v in ipairs(removal) do
		tremove(cache, v)
		doSort = true
	end
	if doSort then
		sort(cache, sortfunc)
		throttleFrame:SetScript("OnUpdate", nil)
		throttleElapsed = 0
	end
	ChatFrame1:AddMessage("cache size " .. #cache)
end
--manageFrame:SetScript("OnUpdate", manageTimers)

local function stopTimers()
	local stop = true
	for i, v in ipairs(cache) do
		if v.active ~= 0 then
			stop = false
		end
	end
	
	if stop then
		frame:SetScript("OnUpdate", nil)
		return true
	end
	return false
end

local function startTimers()
	local start = false
	for i, v in ipairs(cache) do
		if v.active ~= 0 then
			start = true
		end
	end
	if start then
		frame:SetScript("OnUpdate", update)
		return true
	end
	return false
end

local throttleElapsed = 0
local throttleFunc = function(frame, elapsed)
	throttleElapsed = throttleElapsed + elapsed
	if throttleElapsed < 0.05 then
		return
	end
	throttleElapsed = 0
	sort(cache, sortfunc)	
	throttleFrame:SetScript("OnUpdate", nil)
end

--- Create a new LibTimer object
-- @usage LibScriptableTimer:New(name, duration, repeating, callback, data, errorLevel, durationLimit)
-- @param name A name for this timer object
-- @param duration The timer's duration in milliseconds.
-- @param repeating Whether to repeat the timer or not
-- @param callback Function to call when the timer has expired
-- @param data Data to pass to the callback
-- @param errorLevel Error verbosity level
-- @return A new LibScriptableTimer object
function LibTimer:New(name, duration, repeating, callback, data, errorLevel)
	assert(type(duration) == "number", ("%s: Duration sent to LibTimer.New is invalid"):format(name))
	
	local obj = next(pool)

	if obj then
		pool[obj] = nil
	else
		obj = {}
	end

	setmetatable(obj, self)
	
	obj.error = LibError:New(MAJOR .. ": " .. name, errorLevel)
	
	obj.name = name
	obj.duration = duration / 1000
	obj.repeating = repeating
	obj.callback = callback
	obj.data = data
	obj.errorLevel = errorLevel
	obj.active = 0
	obj.lastUpdate = 0
	
	tinsert(cache, obj)
		
	return obj	
	
end

--- Delete a LibTimer object
-- @usage object:Del()
-- @return Nothing
function LibTimer:Del()
	local timer = self
	pool[timer] = true
	timer:Stop()
	timer.error:Del()
	for i, o in ipairs(cache) do
		if o == timer then
			timer.i = i
			break
		end
	end
	if timer.i then
		tremove(cache, timer.i)
		timer.i = false
	end
end

--- Start a timer
-- @usage object:Start([duration], [data])
-- @param duration The duration in milliseconds. This is optional.
-- @param data Replace the timer's data that will be sent through the callback with this value
-- @param func Replace the timer's callback function
-- @return True if the timer was started
function LibTimer:Start(duration, data, func)
	if type(duration) == "number" then
		self.duration = duration / 1000
	end
	if self.duration == 0 then
		return
	end
	self.timer = 0
	self.startTime = GetTime()
	self.active = 1
	throttleElapsed = 0
	throttleFrame:SetScript("OnUpdate", throttleFunc)

	self.data = data or self.data
	if type(func) == "function" then self.callback = func end
	
	return startTimers()
end

--- Stop a timer
-- @usage object:Stop()
-- @return True if the timer was stopped
function LibTimer:Stop()
	self.active = 0
	throttleElapsed = 0
	--throttleFrame:SetScript("OnUpdate", throttleFunc)
	return stopTimers()
end

--- Return the timer's remaining duration
-- @usage object:TimeRemaining()
-- @return The remaining duration
function LibTimer:TimeRemaining()
	if type(self.startTime) ~= "number" or not self.active then return 0 end
	
	local time = GetTime()
	local diff = time - self.startTime
	
	return time - diff
end

local timer = 0
local duration = DEFAULT_LIMIT / 1000
update = function(self, elapsed)
	if timer < duration then
		timer = timer + elapsed
		return
	end
	for i, o in ipairs(cache) do
		if o.active == 0 then
			break
		else
			o.timer = (o.timer or 0) + timer
			if o.timer > o.duration then
				if not o.repeating then o:Stop() end
				if o.callback then o.callback(o.data) end
				o.timer = 0
			end
		end
	end
	timer = 0
end

