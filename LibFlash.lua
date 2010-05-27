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


LibFlash = {
	pool = {},
	New = function(self, frame)
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

		self.__index = self

		obj.frame = frame

		if not obj.UpdateFrame then
			obj.UpdateFrame = CreateFrame("Frame")
		end

		obj.UpdateFrame.obj = obj

		return obj
	end,
	Del = function(self) 
		if self.frame then
			LibFlash.pool[self] = true
		end
	end
}

function LibFlash:Stop()
	self.UpdateFrame:SetScript("OnUpdate", nil)
	if self.childFlash then 
		self.childFlash:Stop()
	end
	self.active = false
	self.elapsed = 0
end

function LibFlash:Fade(dur, startA, finishA, callback, data)
	if self.active then return false end
	self.UpdateFrame.timer = 0
	self.UpdateFrame.elapsed = 0

	self.frame:SetAlpha(startA)

	local function update(self, elapsed)
		self.timer = (self.timer or 0) + elapsed

		if self.timer < .1 then
			self.elapsed = self.elapsed + elapsed
			return
		end
		local alpha = 0
		if startA < finishA then 
			alpha = (finishA - startA) * (self.elapsed / dur) + startA
		else
			alpha = (startA - finishA) * (1 - self.elapsed / dur) + finishA
		end

		if alpha < 0 then
			alpha = 0
		elseif alpha > 1 then
			alpha = 1
		end

		self.obj.frame:SetAlpha(alpha)
		self.timer = 0

		if self.elapsed > dur then
			self.obj:Stop()
			self.obj.frame:SetAlpha(finishA)
			if callback then callback(data) end
		end
	end

	
	self.UpdateFrame:SetScript("OnUpdate", update)
	self.active = true
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

function LibFlash:Flash(fadeinTime, fadeoutTime, flashDuration, showWhenDone, flashinHoldTime, flashoutHoldTime, shouldBlink, blinkRate, callback, data)

	if self.active then return false end
	if not self.childFlash then self.childFlash = LibFlash:New(self.frame) end

	self.UpdateFrame.timer = 0
	self.UpdateFrame.elapsed = 0
	self.UpdateFrame.smallElapse = 0
	self.UpdateFrame.flashinHoldTimer = 0
	self.UpdateFrame.flashoutHoldTimer = 0
	self.UpdateFrame.blinkTimer = 0
	self.UpdateFrame.blinkState = 0

	local state = 0

	local incrementState = function()
		state = state + 1
	end

	local decrementState = function()
		state = state - 1
	end

	local setState = function(val)
		state = val
	end

	local setBlinkState = function(val)
		self.UpdateFrame.blinkState = val
		self.UpdateFrame.blinkTimer = 0
	end

	local update = function(self, elapsed)
		self.timer = self.timer + elapsed

		self.elapsed = self.elapsed + elapsed

		if self.timer < 0.1 then
			self.smallElapse = self.smallElapse + elapsed
			return
		end

		if state == 0 then
			self.flashinHoldTimer = self.flashinHoldTimer + self.timer

			if self.flashinHoldTimer > flashinHoldTime then
				incrementState()
				self.flashinHoldTimer = 0
			end
		elseif state == 1 then
			self.obj.childFlash:FadeIn(fadeinTime, 0, 1, incrementState)
		elseif state == 2 then
			self.flashoutHoldTimer = self.flashoutHoldTimer + self.timer
			self.blinkTimer = self.blinkTimer + self.timer
			if self.blinkTimer > (blinkRate or .3) and shouldBlink then
				if self.blinkState then
					self.obj.childFlash:FadeIn(fadeinTime, 0, 1, setBlinkState, 1)
				else
					self.obj.childFlash:FadeOut(fadeoutTime, 1, 0, setBlinkState, 0)
				end
				self.blinkTimer = 0	
			end
			if self.flashoutHoldTimer > flashoutHoldTime then
				self.obj.childFlash:Stop()
				self.obj.childFlash:FadeOut(fadeoutTime, 1, 0, incrementState)
				self.flashoutHoldTimer = 0xdead * -1
			end
		elseif state == 3 then
			if self.elapsed > flashDuration - fadeinTime then
				self.obj:Stop()
				if showWhenDone then
					self.obj.childFlash:FadeIn(fadeinTime, 0, 1, callback, data)
				elseif callback then
					callback(data)
				end
				self.obj:Stop()
			end		
		end

		self.timer = 0
		self.smallElapse = 0
	end

	self.UpdateFrame:SetScript("OnUpdate", update)
	self.active = true
	return true
end
