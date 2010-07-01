--[[
 LibFlash
 
 Copyright (C) 2010 Scott Sibley <starlon@users.sourceforge.net>

 Authors: Scott Sibley

 $Id$

 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU Lesser General Public License as
 published by the Free Software Foundation; either version 3
 of the License, or (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU Lesser General Public License for more details.

 You should have received a copy of the GNU Lesser General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
]]

local MAJOR = "LibFlash" 
local MINOR = 1 
assert(LibStub, MAJOR.." requires LibStub") 
local LibFlash = LibStub:NewLibrary(MAJOR, MINOR)
if not LibFlash then return end

if not LibFlash.pool then
	LibFlash.pool = {}
	LibFlash.UpdateFrame = CreateFrame("Frame")
	LibFlash.objects = {}
end

if not LibFlash.__index then
	LibFlash.__index = LibFlash
end

local FADETYPE = 0
local FLASHTYPE = 1

local function findFlash(obj)
	for i, o in ipairs(LibFlash.objects) do
		if o == obj then
			return i
		end
	end
	return 0
end

function LibFlash:New(frame)
	if not frame then
		error("No frame specified")
	end

	local obj = next(self.pool)

	if obj then
		self.pool[obj] = nil
	else
		obj = {}
	end

	setmetatable(obj, self)

	obj.frame = frame

	if not obj.UpdateFrame then
		obj.UpdateFrame = CreateFrame("Frame")
	end

	obj.UpdateFrame.obj = obj

	table.insert(self.objects, 1, obj)
	
	return obj
end

function LibFlash:Del()
	if self.frame then
		self:Stop()
		LibFlash.pool[self] = true
		local i = findFlash(self)
		if i > 0 then
			table.remove(LibFlash.objects, i)
		end
	end
end

function LibFlash:Stop()
	if self.childFlash then 
		self.childFlash:Stop()
	end
	self.active = false
	self.timer = 0
	self:StopTimer()
end

local function fadeUpdate(self, timer)

	if timer < 0.1 then
		return
	end
	
	local alpha = 0
	if self.startA < self.finishA then 
		alpha = (self.finishA - self.startA) * (timer / self.dur) + self.startA
	else
		alpha = (self.startA - self.finishA) * (1 - timer / self.dur) + self.finishA
	end

	if alpha < 0 then
		alpha = 0
	elseif alpha > 1 then
		alpha = 1
	end

	self.frame:SetAlpha(alpha)

	if timer > self.dur then
		self:Stop()
		self.frame:SetAlpha(self.finishA)
		if self.callback then self.callback(self.data) end
	end
end

function LibFlash:Fade(dur, startA, finishA, callback, data)
	if self.active then return false end
	
	self.frame:SetAlpha(startA)
	
	self.dur = dur
	self.startA = startA
	self.finishA = finishA
	self.callback = callback
	self.data = data
	
	self.active = true
	self.type = FADETYPE
	self:StartTimer()
	
	return true
end

function LibFlash:FadeIn(dur, startA, finishA, callback, data)
	if startA < finishA then
		return self:Fade(dur, startA, finishA, callback, data)
	else
		error("FadeIn with bad parameters")
	end
end

function LibFlash:FadeOut(dur, startA, finishA, callback, data)
	if startA > finishA then
		return self:Fade(dur, startA, finishA, callback, data)
	else
		error("FadeOut with bad parameters")
	end
end

local incrementState = function(flash)
	flash.state = flash.state + 1
end

local decrementState = function(flash)
	flash.state = flash.state - 1
end

local setState = function(flash)
	flash.state = flash.newState
end

local setBlinkState = function(flash)
	flash.blinkState = flash.newBlinkState
	flash.blinkTimer = 0
end

local flashUpdate = function(self, elapsed)

	if elapsed < 0.1 then
		return
	end
	
	if self.state == 0 then
		self.flashinHoldTimer = self.flashinHoldTimer + elapsed

		if self.flashinHoldTimer > self.flashinHoldTime then
			incrementState(self)
			self.flashinHoldTimer = 0
		end
	elseif self.state == 1 then
		self.childFlash:FadeIn(self.fadeinTime, 0, 1, incrementState, self)
	elseif self.state == 2 then
		self.flashoutHoldTimer = self.flashoutHoldTimer + elapsed
		self.blinkTimer = self.blinkTimer + elapsed
		if self.blinkTimer > (self.blinkRate or .3) and self.shouldBlink then
			if self.blinkState == 0 or self.blinkState == nil then
				self.newBlinkState = 1
				self.childFlash:FadeIn(self.fadeinTime, 0, 1, setBlinkState, self)
			else
				self.newBlinkState = 0
				self.childFlash:FadeOut(self.fadeoutTime, 1, 0, setBlinkState, self)
			end
			self.blinkTimer = 0	
		end
		if self.flashoutHoldTimer > self.flashoutHoldTime then
			self.childFlash:Stop()
			self.childFlash:FadeOut(self.fadeoutTime, 1, 0, incrementState, self)
			self.flashoutHoldTimer = 0xdead * -1
		end
	elseif self.state == 3 then
		if self.elapsed > self.flashDuration - self.fadeinTime then
			self:Stop()
			if self.showWhenDone then
				self.childFlash:FadeIn(self.fadeinTime, 0, 1, self.callback, self.data)
			elseif self.callback then
				self.callback(self.data)
			end
			self:Stop()
		end		
	end
end
	
function LibFlash:Flash(fadeinTime, fadeoutTime, flashDuration, showWhenDone, flashinHoldTime, flashoutHoldTime, shouldBlink, blinkRate, callback, data)

	if self.active then return false end
	if not self.childFlash then self.childFlash = LibFlash:New(self.frame) end

	self.timer = 0
	self.elapsed = 0
	self.flashinHoldTimer = 0
	self.flashoutHoldTimer = 0
	self.blinkTimer = 0
	self.blinkState = 0

	self.state = 0

	self.fadeinTime = fadeinTime
	self.fadeoutTime = fadeoutTime
	self.flashDuration = flashDuration
	self.showWhenDone = showWhenDone
	self.flashinHoldTime = flashinHoldTime
	self.flashoutHoldTime = flashoutHoldTime
	self.shouldBlink = shouldBlink
	self.blinkRate = blinkRate
	self.callback = callback
	self.data = data

	self.active = true
	self.type = FLASHTYPE
	self:StartTimer()
	
	return true
end

local startCurrent
function LibFlash:GetNextActive()

	if #LibFlash.objects == 0 then
		return nil
	end
	
	LibFlash.current = (LibFlash.current or 0) + 1

	if LibFlash.current > #LibFlash.objects then
		LibFlash.current = 1
	end
		
	if LibFlash.current == startCurrent then
		startCurrent = nil
		return nil
	end

	if not startCurrent then
		startCurrent = LibFlash.current
	end

	local obj
	if LibFlash.objects[LibFlash.current].active then
		obj = LibFlash.objects[LibFlash.current]
	end
	
	if obj then
		startCurrent = nil
		return obj
	else
		return self:GetNextActive()
	end
end

local update = function(self, elapsed)

	if #LibFlash.objects == 0 then
		LibFlash:StopTimer()
		return
	end
	
	self.timer = (self.timer or 0) + elapsed
	
	for i, o in ipairs(LibFlash.objects) do
		if o.active then
			o.timer = (o.timer or 0) + self.timer
		end
	end

	local obj = LibFlash:GetNextActive()
	
	if obj and obj.type == FADETYPE then
		fadeUpdate(obj, obj.timer)
	elseif obj and obj.type == FLASHTYPE then
		flashUpdate(obj, obj.timer)
	end
	
	self.timer = 0
end

function LibFlash:StartTimer()
	if not LibFlash.UpdateFrame.active then
		local test = false
		for i, o in ipairs(LibFlash.objects) do
			if o.active then
				test = true
			end
		end
		if test then
			LibFlash.UpdateFrame.timer = 0
			LibFlash.UpdateFrame:SetScript("OnUpdate", update)
			LibFlash.UpdateFrame.active = true
		end
	end
end

function LibFlash:StopTimer()
	if LibFlash.UpdateFrame.active then
		local test = false
		for i, o in ipairs(LibFlash.objects) do
			if o.active then
				test = true
			end
		end
		if not test then
			LibFlash.UpdateFrame.timer = 0
			LibFlash.UpdateFrame:SetScript("OnUpdate", nil)
			LibFlash.UpdateFrame.active = false
		end
	end
end