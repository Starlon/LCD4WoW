local MAJOR = "LibScriptableImagesAVSSuperScope-1.0"
local MINOR = 17
assert(LibStub, MAJOR.." requires LibStub")
local LibAVSSuperScope = LibStub:NewLibrary(MAJOR, MINOR)
if not LibAVSSuperScope then return end
local LibCore = LibStub("LibScriptableLCDCoreLite-1.0", true)
assert(LibCore, MAJOR .. " requires LibScriptableLCDCoreLite-1.0")
local LibWidget = LibStub("LibScriptableWidget-1.0", true)
assert(LibWidget, MAJOR .. " requires LibScriptableWidget-1.0")
local PluginBlend = LibStub("LibScriptablePluginBlend-1.0", true)
assert(PluginBlend, MAJOR .. " requires LibScriptablePluginBlend-1.0")
PluginBlend = PluginBlend:New({})
local PluginMath = LibStub("LibScriptablePluginMath-1.0", true)
assert(PluginMath, MAJOR .. " requires LibScriptablePluginMath-1.0")
local Evaluator = LibStub("LibScriptableUtilsEvaluator-1.0", true)
assert(Evaluator, MAJOR .. " requires LibScriptableUtilsEvaluator-1.0")
local LibBuffer = LibStub("LibScriptableUtilsBuffer-1.0", true)
assert(LibBuffer, MAJOR .. " requires LibScriptableUtilsBuffer-1.0")
local LibError = LibStub("LibScriptableUtilsError-1.0")
assert(LibError, MAJOR .. " requires LibScriptableUtilsError-1.0")
local L = LibStub("LibScriptableUtilsLocale-1.0", true)
assert(L, MAJOR .. " requires LibScriptableUtilsLocale-1.0")
L = L.L

local environment = {}

local pool = setmetatable({}, {__mode = "k"})

if not LibAVSSuperScope.__index then
	LibAVSSuperScope.__index = LibAVSSuperScope
end

local PI = 3.14159265358979323846

local blendModesList = {L["Replace"], L["Add"], L["Max"], L["Average"], L["Subtractive (1-2)"], L["Subtractive (2-1)"], L["Multiplicative"], L["Adjustable (cc=blend ratio)"], L["XOR"], L["Minimum"]}

local defaults = {
	width = 32,
	height = 32,
	pixel = 2,
	drawLayer = "UIParent",
	line_blend_mode = 1,
	drawMode = 0,
	unit = "local"
}
LibAVSSuperScope.defaults = defaults

-- @name LibScriptableAVSSuperScope:New
-- @usage LibScriptableAVSSuperScope:New(name, size, defval, errorLevel)
-- @param name A name for the buffer
-- @param config This object's parameters
-- @param errorLevel The verbocity level
-- @return A new LibScriptableAVSSuperScope object

function LibAVSSuperScope:New(name, config, errorLevel)
	assert(type(name) ~= "nil", "LibAVSSuperScope requires a name")
	assert(type(config) == "table", "LibAVSSuperScope requires a config")

	local obj = next(pool)

	if obj then
		pool[obj] = nil
	else
		obj = {}
	end

	setmetatable(obj, self)

	obj.name = name

	obj.n = 100
	obj.b = 0
	obj.x = 0
	obj.y = 0
	obj.i = 0
	obj.v = 0
	obj.w = 0
	obj.h = 0
	obj.t = 0
	obj.d = 0
	obj.red = 0
	obj.green  = 0
	obj.blue = 0
	obj.linesize = 0
	obj.skip = 0
	obj.drawMode = config.drawMode or defaults.drawMode
	obj.PI = PI
	obj.E = 2.71828
	obj.PHI = 1.61033

	for k, v in pairs(environment) do
		obj[k] = v
	end

	obj.self = obj

	obj.needs_init = true

	obj.init = Evaluator.ExecuteCode(obj, MAJOR .. " init", config.init, false, "", true)
	obj.beat = Evaluator.ExecuteCode(obj, MAJOR .. " beat", config.beat, false, "", true)
	obj.frame = Evaluator.ExecuteCode(obj, MAJOR .. " frame", config.frame, false, "", true)
	obj.point = Evaluator.ExecuteCode(obj, MAJOR .. " point", config.point, false, "", true)

	obj.width = config.width or defaults.width
	obj.height = config.height or defaults.height
	obj.pixel = config.pixel or defaults.pixel
	obj.drawLayer = config.drawLayer or defaults.drawLayer
	obj.line_blend_mode = config.line_blend_mode or defaults.line_blend_mode
	obj.config = config


	obj.buffer = LibBuffer:New(MAJOR .. " buffer", obj.width * obj.height, 0, errorLevel)

	return obj

end

-- @name LibScriptableAVSSuperScope:Del
-- @usage LibScriptableAVSSuperScope:Del([lcd]) or object:Del()
-- @param lcd An optional lcd object
-- @return Nothing
function LibAVSSuperScope:Del()
	pool[self] = true
	for i = 0, self.buffer:Size() do
		self.buffer[i] = false
	end
	self.size = 0
	self.buffer:Del()
end

-- (visdata[2][2][576], int isBeat, int *framebuffer, int *fbout, int w, int h
function LibAVSSuperScope:Render(visdata, isBeat, framebuffer, fbout, w, h)
	local size = 5

    if(self.needs_init) then
        self.needs_init = false;
		self.init()
		self.beat()
    end

	--[[self.buffer:Line4(0, 0, w - 1, h - 1, 0xff0000, w)
	self.buffer:Line4(0, 20, w - 1, h - 1, 0x00ff00, w)
	self.buffer:Line4(70, 0, w - 1, h - 1, 0x0000ff, w)
	self.buffer:Line4(w - 1, h - 1, 70, 0, 0xffffff, w)
	do return end
	]]
    local a, l
	local size = 32
	local lx, ly, x, y = 0, 0, 0, 0
	local current_color = 0xfffff
	local ws = 1
	local xorv = (ws * size) ^ size
	--local fa_data = {}

    self.h = h
    self.w = w
    self.b = isBeat
    self.blue = bit.band(current_color, 0xff) / 255
    self.green = bit.band(bit.rshift(current_color, 8), 0xff) / 255
    self.red = bit.band(bit.rshift(current_color, 16), 0xff) / 255
	self.alpha = bit.band(bit.rshift(current_color, 24), 0xff) / 255
    self.skip = 0;
    self.linesize = 3
    self.drawmode = 1 --self.draw_type ? 1.0 : 0.0;

    --scope_run(self, SCOPE_RUNNABLE_FRAME);
	self.frame()

    if (isBeat ~= 0) then
        --scope_run(self, SCOPE_RUNNABLE_BEAT);
		self.beat()
    end

    l = self.n;
    if (l > size*size) then
        l = size*size;
	end

    if( l == 0 or l == 1 ) then
        l = 2;
	end

    for a=0, l - 1 do	
		--[[local r = (a*4)/1
		local s1 = r - floor(r)
		local yr = (visdata[floor(r)]^xorv)*(1-s1)+(floor(visdata[floor(r)+1]^xorv))*s1
		self.v = yr/size - 1
		]]

		local i = floor(a * size / l * 100)  % self.n
        self.v = visdata[i] or random(100) / 100;
        self.i = a/(l-1);
        self.skip = 0.0;

		self.point()

        local x = floor(((self.x + 1.0) * self.width * 0.5))
        local y = floor(((self.y + 1.0) * self.height * 0.5))

		local this_color = bit.bor(self.blue * 255, bit.bor(bit.lshift(self.green * 255, 8), bit.lshift(self.red * 255, 16)))

        if self.skip == 0 then
			if self.drawMode == 0 then
				if (y >= 0 and y < self.height and x >= 0 and x < self.width) then
					PluginBlend.BLEND_LINE(self.line_blend_mode, self.buffer.buffer, y * self.width + x, this_color);
				end
			else
				if (a > 0) then
					if (y >= 0 and y < self.h and x >= 0 and x < self.w and
						ly >= 0 and ly < self.h and lx >= 0 and lx < self.w) then
							self.buffer:Line5(lx, ly, x, y, this_color, self.width)
					end
				end
			end
			lx = x;
			ly = y;
		end
    end
    return 0;
end

function LibAVSSuperScope:GetOptions(db, callback, data)
	local options = {
		enabled = {
			name = L["Enabled"],
			type = "toggle",
			get = function() return db.enabled end,
			set = function(info, val)
				db.enabled = val
				db.enabledDirty = true
				if type(callback) == "function" then
					callback(data)
				end
			end,
			order = 1
		},
		width = {
			name = L["Width"],
			type = "input",
			pattern = "%d",
			get = function() return tostring(db.width or defaults.width) end,
			set = function(info, val)
				db.width = tonumber(val)
				db.widthDirty = true
				if type(callback) == "function" then
					callback(data)
				end
			end,
			order = 2
		},
		height = {
			name = L["Height"],
			type = "input",
			pattern = "%d",
			get = function() return tostring(db.height or defaults.height) end,
			set = function(info, val)
				db.height = tonumber(val)
				db.heightDirty = true
				if type(callback) == "function" then
					callback(data)
				end
			end,
			order = 3
		},
		pixel = {
			name = L["Pixel"],
			desc = L["Size per pixel"],
			type = "input",
			pattern = "%d",
			get = function() return tostring(db.pixel or defaults.pixel) end,
			set = function(info, val)
				db.pixel = tonumber(val)
				db.pixelDirty = true
				if type(callback) == "function" then
					callback(data)
				end
			end,
			order = 4
		},
		drawLayer = {
			name = L["Draw Layer"],
			desc = L[""],
			type = "input",
			pattern = "%d",
			get = function() return tostring(db.pixel or defaults.pixel) end,
			set = function(info, val)
				db.pixel = tonumber(val)
				db.pixelDirty = true
				if type(callback) == "function" then
					callback(data)
				end
			end,
			order = 5
		},
		drawMode = {
			name = L["Draw Mode"],
			type = "select",
			values = {L["Dots"], L["Lines"]},
			get = function() 
				return (db.drawMode or defaults.drawMode) + 1
			end,
			set = function(info, val)
				db.drawMode = val - 1
				db.drawModeDirty = true
				if type(callback) == "function" then
					callback(data)
				end
			end,
			order = 6
		},
		line_blend_mode = { -- FIXME: this should be a global setting.
			name = L["Blend Mode"],
			desc = L["The selected method of blending"],
			type = "select",
			values = blendModesList,
			get = function() return db.line_blend_mode or defaults.line_blend_mode end,
			set = function(info, val)
				db.line_blend_mode = val
				db.line_blend_modeDirty = true
				if type(callback) == "function" then
					callback(data)
				end
			end,
			order = 7
		},
		unit = {
			name = L["Unit ID"],
			desc = L["Use this unit for noise input"],
			type = "input",
			get = function() return db.unit or defaults.unit end,
			set = function(info, val)
				db.unit = val
				db.unitDirty = true
				if type(callback) == "function" then
					callback(data)
				end
			end,
			order = 8
		},
		init = {
			name = L["Init Script"],
			type = "input",
			multiline = true,
			width = "full",
			get = function() return db.init end,
			set = function(info, val)
				db.init = val
				db.initDirty = true
				if type(callback) == "function" then
					callback(data)
				end
			end,
			order = 50
		},
		beat = {
			name = L["Beat Script"],
			type = "input",
			multiline = true,
			width = "full",
			get = function() return db.beat end,
			set = function(info, val)
				db.beat = val
				db.beatDirty = true
				if type(callback) == "function" then
					callback(data)
				end
			end,
			order = 51
		},
		frame = {
			name = L["Frame Script"],
			type = "input",
			multiline = true,
			width = "full",
			get = function() return db.frame end,
			set = function(info, val)
				db.frame = val
				db.frameDirty = true
				if type(callback) == "function" then
					callback(data)
				end
			end,
			order = 52
		},
		point = {
			name = L["Point Script"],
			type = "input",
			multiline = true,
			width = "full",
			get = function() return db.point end,
			set = function(info, val)
				db.point = val
				db.pointDirty = true
				if type(callback) == "function" then
					callback(data)
				end
			end,
			order = 53
		}
	}

	options.widget = LibWidget:GetOptions(db, callback, data)
	return options
end

