local mod = LCD4WoW:NewModule("LCD4WoW")
mod.name = "LCD Display"
mod.toggled = true
mod.defaultOff = true
local Evaluator = LibStub("StarLibEvaluator-1.0")
local LibCore = LibStub("StarLibCore-1.0")
local LibLCDText = LibStub("StarLibLCDText-1.0")
local LibDriverQTip = LibStub("StarLibDriverQTip-1.0")
local LibDriverCharacter = LibStub("StarLibDriverCharacter-1.0")
local WidgetText = LibStub("StarLibWidgetText-1.0")
local WidgetBar = LibStub("StarLibWidgetBar-1.0")
local WidgetHistogram = LibStub("StarLibWidgetHistogram-1.0")
local WidgetKey = LibStub("StarLibWidgetKey-1.0")
local WidgetTimer = LibStub("StarLibWidgetTimer-1.0")
local LayoutOptions = LibStub("StarLibLayoutOptions-1.0")
local Resources = LibStub("StarLibPluginResourceTools-1.0")

local resources = {}
Resources:New(resources)

local _G = _G
local GameTooltip = _G.GameTooltip

local function copy(tbl)
	local new = {}
	for k, v in pairs(tbl) do
		if type(v) == "table" then
			new[k] = copy(v)
		else
			new[k] = v
		end
	end
	return new
end

local defaults = {profile= {config=copy(LCD4WoW.config)}}
local displays = {}

local options
local blankOptions = {
	restart = {
		name = "Restart Displays",
		type = "execute",
		func = function()
			mod:StopDisplays()
			mod:StartDisplays()
		end,
		order = 1
	},
	defaults = {
		name = "Restore Defaults",
		type = "execute",
		func = function()
			mod.db.profile.config = copy(LCD4WoW.config)
			LCD4WoW:RebuildOpts()
		end,
		order = 2
	},
	displays = {
		name = "Displays",
		type = "group",
		args = {},
		order = 40
	},
	layouts = {
		name = "Layouts",
		type = "group",
		args = {},
		order = 41
	},
	widgets = {
		name = "Widgets",
		type = "group",
		args = {},
		order = 42
	}
}
if resources.scriptProfile then
	blankOptions.scriptProfile = {
		name = "Turn off CPU profiling",
		type = "execute",
		func = function()
			SetCVar("scriptProfile", 0)
			ReloadUI()
		end
	}
else
	blankOptions.scriptProfile = {
		name = "Turn on CPU profiling",
		type = "execute",
		func = function()
			SetCVar("scriptProfile", 1)
			ReloadUI()
		end,
		order = 3
	}
end

function mod:RebuildOpts()
	options = copy(blankOptions)
	options.displays.args.add = {
		name = "Add Display",
		type = "input",
		set = function(info, v)
			self.db.profile.config["display_" .. v] = {name = v, layouts = {}, widgets = {}}
			LCD4WoW:RebuildOpts()
		end,
		order = 1
	}
	options.layouts.args.add = {
		name = "Add Layout",
		type = "input",
		set = function(info, v)
			self.db.profile.config["layout_" .. v] = {name = v}
			LCD4WoW:RebuildOpts()
		end,
		order = 1
	}
	options.widgets.args.text = {
		name = "Text Widgets",
		type = "group",
		args = {
			add = {
				name = "Add",
				desc = "Enter a name for your text widget",
				type = "input",
				set = function(info, v)
					self.db.profile.config["widget_" .. v] = {type = "text"}
					LCD4WoW:RebuildOpts()
				end,
				order = 1
			},
		}
	}
	options.widgets.args.bar = {
		name = "Bars",
		type = "group",
		args = {
			add = {
				name = "Add",
				desc = "Enter a name for your bar widget",
				type = "input",
				set = function(info, v)
					self.db.profile.config["widget_" .. v] = {type = "bar"}
					LCD4WoW:RebuildOpts()
				end,
				order = 1
			}
		}	
	}
	options.widgets.args.histogram = {
		name = "Histograms",
		type = "group",
		args = {
			add = {
				name = "Add",
				desc = "Enter a name for your histogram widget",
				type = "input",
				set = function(info, v)
					self.db.profile.config["widget_" .. v] = {type = "histogram"}
					LCD4WoW:RebuildOpts()
				end,
				order = 1
			}
		}	
	}	
	options.widgets.args.icon = {
		name = "Icons",
		type = "group",
		args = {
			add = {
				name = "Add",
				desc = "Enter a name for your icon widget",
				type = "input",
				set = function(info, v)
					self.db.profile.config["widget_" .. v] = {type = "icon"}
					LCD4WoW:RebuildOpts()
				end,
				order = 1
			}
		}
	}	
	options.widgets.args.key = {
		name = "Keys",
		type = "group",
		args = {
			add = {
				name = "Add",
				desc = "Enter a name for your key widget",
				type = "input",
				set = function(info, v)
					self.db.profile.config["widget_" .. v] = {type = "key"}
					LCD4WoW:RebuildOpts()
				end,
				order = 1
			}
		}
	}
	options.widgets.args.timers = {
		name = "Timers",
		type = "group",
		args = {
			add = {
				name = "Add",
				type = "input",
				desc = "Enter a name for your timer widget",
				set = function(info, v)
					self.db.profile.config["widget_" .. v] = {type = "timer"}
					LCD4WoW:RebuildOpts()
				end,
				order = 1
			}
		}
	}
	for k, v in pairs(self.db.profile.config) do
		if k:match("^display_.*") then
			options.displays.args[k:gsub(" ", "_")] = {
				name = k:gsub("display_", ""),
				type = "group",
				args = { 
					enable = {
						name = "Enable",
						type = "toggle",
						get = function()
							return v.enabled
						end,
						set = function(info, val)
							v.enabled = val
						end,
						order = 1
					},
					driver = {
						name = "Driver",
						desc = "This display's driver type",
						type = "select",
						values = LibCore.driverList,
						get = function() return LibCore.driverDict[v.driver] end,
						set = function(info, val)
							v.driver = LibCore.driverList[val]
							LCD4WoW:RebuildOpts()
						end,
						order = 2
				
					},
					send = {
						name = "Send Display",
						desc = "Send this display to someone",
						type = "input",
						set = function(info, name)
							self:SendDisplay(k, name)
						end,
						order = 3
					},
					delete = {
						name = "Delete",
						type = "execute",
						func = function()
							self.db.profile.config[k] = nil
							LCD4WoW:RebuildOpts()
						end,
						order = 100
					}
				}
			}			
			local driverOptions = {}
			if v.driver == "qtip" then
				driverOptions = LibDriverQTip:RebuildOpts(LCD4WoW, v, k)
			elseif v.driver == "character" then
				driverOptions = LibDriverCharacter:RebuildOpts(LCD4WoW, v, k)
			end
			
			for kk, vv in pairs(driverOptions) do
				options.displays.args[k:gsub(" ", "_")].args[kk] = vv
			end
			if v.widgets then
				for i, widget in ipairs(v.widgets) do
					options.displays.args[k:gsub(" ", "_")].args.widgets.args[widget] = {
						name = widget,
						type = "input",
						get = function() return widget end,
						set = function() v.widgets[i] = val end,
						order = 50 + i
					}
				end
			end
		end
		if k:match("^layout_") then
			options.layouts.args[k:gsub(" ", "_")] = {
				name = k,
				type = "group",
				args = {}
			}
			options.layouts.args[k:gsub(" ", "_")].args = LayoutOptions:RebuildOpts(LCD4WoW, v, k)
			options.layouts.args[k:gsub(" ", "_")].args.delete = {
				name = "Delete",
				type = "execute",
				func = function()
					self.db.profile.config[k] = nil
					LCD4WoW:RebuildOpts()
				end
			}
			
		end
		if k:match("^widget_") then
			if v.type == "text" then
				options.widgets.args.text.args[k:gsub(" ", "_")] = {
					name = k:gsub("widget_", ""),
					type = "group",
					args = WidgetText:GetOptions(LCD4WoW, v, k),
					order = 1
				}
				options.widgets.args.text.args[k:gsub(" ", "_")].args.delete = {
					name = "Delete",
					type = "execute",
					func = function()
						self.db.profile.config[k] = nil
						LCD4WoW:RebuildOpts()
					end,
					order = 100
				}
			elseif v.type == "bar" then
				options.widgets.args.bar.args[k:gsub(" ", "_")] = {
					name = k,
					type = "group",
					args = WidgetBar:GetOptions(LCD4WoW, v, k),
					order = 1
				}						
				options.widgets.args.bar.args[k:gsub(" ", "_")].args.delete = {
					name = "Delete",
					type = "execute",
					func = function()
						self.db.profile.config[k] = nil
						LCD4WoW:RebuildOpts()
					end,
					order = 100
				}				
			elseif v.type == "histogram" then
				options.widgets.args.histogram.args[k:gsub(" ", "_")] = {
					name = k,
					type = "group",
					args = WidgetHistogram:GetOptions(LCD4WoW, v, k),
					order = 1
				}						
				options.widgets.args.histogram.args[k:gsub(" ", "_")].args.delete = {
					name = "Delete",
					type = "execute",
					func = function()
						self.db.profile.config[k] = nil
						LCD4WoW:RebuildOpts()
					end,
					order = 100
				}				
			elseif v.type == "icon" then
				options.widgets.args.icon.args[k:gsub(" ", "_")] = {
					name = k,
					type = "group",
					args = {}, --WidgetIcon:GetOptions(LCD4WoW, v, k)},
					order = 2
				}
				options.widgets.args.icon.args[k:gsub(" ", "_")].args.delete = {
					name = "Delete",
					type = "execute",
					func = function()
						self.db.profile.config[k] = nil
						LCD4WoW:RebuildOpts()
					end,
					order = 100
				}				
			elseif v.type == "key" then
				options.widgets.args.key.args[k:gsub(" ", "_")] = {
					name = k,
					type = "group",
					args = WidgetKey:GetOptions(LCD4WoW, v, k),
					order = 3
				}			
				options.widgets.args.key.args[k:gsub(" ", "_")].args.delete = {
					name = "Delete",
					type = "execute",
					func = function()
						self.db.profile.config[k] = nil
						LCD4WoW:RebuildOpts()
					end,
					order = 100
				}			
			elseif v.type == "timer" then
				options.widgets.args.timers.args[k:gsub(" ", "_")] = {
					name = k,
					type = "group",
					args = WidgetTimer:GetOptions(LCD4WoW, v, k),
					order = 3
				}			
				options.widgets.args.timers.args[k:gsub(" ", "_")].args.delete = {
					name = "Delete",
					type = "execute",
					func = function()
						self.db.profile.config[k] = nil
						LCD4WoW:RebuildOpts()
					end,
					order = 100
				}							
			end
		end
	end
end

function mod:GetOptions()
	self:RebuildOpts()
	return options
end

function mod:OnInitialize()
	self.db = LCD4WoW.db:RegisterNamespace(self:GetName(), defaults)
	self.environment = {_G=_G}
	LCD4WoW:RegisterComm("LCD4WoWDisplayTransfer", self.OnCommReceived)
end

function mod:OnEnable()
	self:StartDisplays()
end

function mod:OnDisable()
	self:StopDisplays()
end

function mod:StartDisplays()
	for k, v in pairs(self.db.profile.config) do
		if k:match("^display_") then
			if v.driver == "qtip" and v.enabled then
				local display = LibDriverQTip:New(self, self.environment, k, self.db.profile.config, LCD4WoW.db.profile.errorLevel) 
				--if ResourceServer then ResourceServer:New(display.environment) end
				display:Show()
				tinsert(displays, display)
			elseif v.driver == "character" and v.enabled then
				local display = LibDriverCharacter:New(self, self.environment, k, self.db.profile.config, LCD4WoW.db.profile.errorLevel)
				--if ResourceServer then ResourceServer:New(display.environment) end
				display:Show()
				tinsert(displays, display)				
			end
		end
	end
end

function mod:StopDisplays()
	for i, v in ipairs(displays) do
		v:Hide()
		v:Del()
	end
	table.wipe(displays)
end

function mod.OnCommReceived(prefix, message, distribution, sender)
	local self = mod
	local flag, data = LCD4WoW:Deserialize(message)
	if not flag then LCD4WoW:Print(data, type(message), message); return end
	if type(data) ~= "table" then LCD4WoW:Print("Display data is not a table -- " .. type(data)); return end
	for k, v in pairs(data) do
		if k:match("^display_") then
			if v.driver == "qtip" then
				local display = LibDriverQTip:New(self, self.environment, k, data, LCD4WoW.db.profile.errorLevel) 
				display:Show()
				tinsert(displays, display)
			elseif v.driver == "character" then
				local display = LibDriverCharacter:New(self, self.environment, k, data, LCD4WoW.db.profile.errorLevel)
				display:Show()
				tinsert(displays, display)
			end
		else
			LCD4WoW:Print(k)
		end
	end
end

function mod:SendDisplay(display, name)
	local tbl = {[display] = self.db.profile.config[display]}
	local widgets = self.db.profile.config[display].widgets
	local layouts = self.db.profile.config[display].layouts
	for i, w in ipairs(widgets) do
		tbl[w] = self.db.profile.config[w]
	end
	for i, layout in ipairs(layouts) do
		tbl[layout] = self.db.profile.config[layout]
		if not tbl[layout] then break end
		for layer = 1, tbl[display].layers do
			for row = 1, tbl[display].rows do
				for col = 1, tbl[display].cols do
					if tbl[layout] and tbl[layout][layer] and
						tbl[layout][layer][row] and
						tbl[layout][layer][row][col] then
						local widget = tbl[layout][layer][row][col]
						tbl[widget] = self.db.profile.config[widget]
					end
				end
			end
		end
	end
	local data = LCD4WoW:Serialize(tbl)
	LCD4WoW:SendCommMessage("LCD4WoWDisplayTransfer", data, "WHISPER", name)
end

function mod:MODIFIER_STATE_CHANGED(ev, modifier, up, ...)
	for i, display in ipairs(displays) do
		if display.KeyEvent then
			display:KeyEvent(modifier, up)
		end
	end
end