-- This file is Copyright (c) 2007-2010, Ace3 Development Team
-- All rights reserved.

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
local OnFinish

LibTimer.frame = CreateFrame("Frame", MAJOR)

if not LibTimer.__index then
	LibTimer.__index = LibTimer
end

-- Full timer recycling unlike AceTimer.  We recycle everything because we don't
-- want to making any more AnimationGroup and Animation objects than necessary.
local timerCache = {}
local function new()
	local timer = next(timerCache)
	if timer then
		timerCache[timer] = nil
	else
		local ag = LibTimer.frame:CreateAnimationGroup()
		timer = ag:CreateAnimation("Animation")
	end
	return timer
end

local function del(timer)
	if not timer then return end
	timerCache[timer] = true
	return nil
end

--[[
   xpcall safecall implementation
]]
local xpcall = xpcall

local function errorhandler(err)
	return geterrorhandler()(err)
end

local function CreateDispatcher(argCount)
	local code = [[
	local xpcall, eh = ...  -- our arguments are received as unnamed values in "..." since we don't have a proper function declaration
	local method, ARGS
	local function call() return method(ARGS) end

	local function dispatch(func, ...)
		method = func
		if not method then return end
		ARGS = ...
		return xpcall(call, eh)
	end

	return dispatch
	]]

	local ARGS = {}
	for i = 1, argCount do ARGS[i] = "arg"..i end
	code = code:gsub("ARGS", tconcat(ARGS, ", "))
	return assert(loadstring(code, "safecall Dispatcher["..argCount.."]"))(xpcall, errorhandler)
end

local Dispatchers = setmetatable({}, {
	__index=function(self, argCount)
		local dispatcher = CreateDispatcher(argCount)
		rawset(self, argCount, dispatcher)
		return dispatcher
	end
})
Dispatchers[0] = function(func)
	return xpcall(func, errorhandler)
end

local function safecall(func, ...)
	return Dispatchers[select('#', ...)](func, ...)
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
	
	local timer = new()
	obj.timer = timer
	
	timer.obj = obj
			
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
	del(timer.timer)
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
	
	self.startTime = GetTime()
		
	self.data = data or self.data
	if type(func) == "function" then self.callback = func end
	
	local timer = self.timer
	local delay = self.duration
	local repeating = self.repeating
	
	local ag = timer:GetParent()
	if delay == 0 then
		do return end
		-- If the delay is 0 switch the OnFinished to be called on the next
		-- OnUpdate.  0 length durations do nothing in the animation system
		-- so if we want 0 lenth durations to work we have to handle them
		-- ourselves.
		timer:SetScript("OnFinished",nil)
		timer:SetScript("OnUpdate",OnFinished)
		timer:SetDuration(1) -- just set the delay to 1 second.
		-- Always setup 0 length durations as repeating timers.  OnUpdate gets
		-- called as soon as you call Play().  Which is not our intent with 0
		-- length timers.
		ag:SetLooping("REPEAT")
		timer.repeating = 1.2 
	else
		timer:SetScript("OnFinished",OnFinished)
		timer:SetScript("OnUpdate",nil)
		timer:SetDuration(delay)
		timer.repeating = repeating and delay * 1.2
		if repeating then
			ag:SetLooping("REPEAT")
		else
			ag:SetLooping("NONE")
		end
	end
	
	ag:Play()

end

-- state variables to prevent timers canceled during callbacks from being returned
-- from the pool until OnFinished finishes.
local in_OnFinished
local canceled_in_OnFinished

--- Stop a timer
-- @usage object:Stop()
-- @return True if the timer was stopped
function LibTimer:Stop()
		if not handle then return end
		if type(handle) ~= "string" then
			error(MAJOR..": CancelTimer(handle): 'handle' - expected a string", 2)
		end
		timer:GetParent():Stop()
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

function OnFinished(self, elapsed)
	---safecall(self.obj.callback, self.obj.data)
	self.obj.callback(self.obj.data)
end
