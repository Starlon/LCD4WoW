
local MAJOR = "LibScriptableUtilsTimer-1.0" 
local MINOR = 17
assert(LibStub, MAJOR.." requires LibStub") 
local LibTimer = LibStub:NewLibrary(MAJOR, MINOR)
if not LibTimer then return end
local LibError = LibStub("LibScriptableUtilsError-1.0")
assert(LibError, MAJOR .. " requires LibScriptableUtilsError-1.0")

local pool = setmetatable({}, {__mode = "k"})

local objects = {}
local update
local frame = CreateFrame("Frame")

local DEFAULT_LIMIT = 100

if not LibTimer.__index then
	LibTimer.__index = LibTimer
end

local function stopTimers()
	local stop = true
	for i, v in ipairs(objects) do
		if v.active > 0 then
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
	for i, v in ipairs(objects) do
		if v.active > 0 then
			start = true
		end
	end
	if start then
		frame:SetScript("OnUpdate", update)
		return true
	end
	return false
end

local function sortfunc(a, b)
	return a.active > b.active
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
	
	tinsert(objects, obj)
		
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
	for i, o in ipairs(objects) do
		if o == timer then
			timer.i = i
			break
		end
	end
	if timer.i then
		tremove(objects, timer.i)
		timer.i = false
	end
end

--- Start a timer
-- @usage object:Start([duration], [data])
-- @param duration The duration in milliseconds. This is optional.
-- @param data Replace the timer's data that will be sent through the callback with this value
-- @return True if the timer was started
function LibTimer:Start(duration, data)
	if type(duration) == "number" then
		self.duration = duration / 1000
	end
	if self.duration == 0 then
		return
	end
	self.timer = 0
	self.startTime = GetTime()
	self.active = 1
	sort(objects, sortfunc)	
	
	if type(data) ~= "nil" then self.data = data end
	return startTimers()
end

--- Stop a timer
-- @usage object:Stop()
-- @return True if the timer was stopped
function LibTimer:Stop()
	self.active = 0
	sort(objects, sortfunc)	
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
	for i, o in ipairs(objects) do
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

