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
		order = 3
	},
	layouts = {
		name = "Layouts",
		type = "group",
		args = {},
		order = 4
	},
	widgets = {
		name = "Widgets",
		type = "group",
		args = {},
		order = 5
	}
}

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
	options.widgets.args.timer = {
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
			if v.driver == "qtip" then
				local display = LibDriverQTip:New(self, self.environment, k, self.db.profile.config, LCD4WoW.db.profile.errorLevel) 
				--if ResourceServer then ResourceServer:New(display.environment) end
				display:Show()
				tinsert(displays, display)
			elseif v.driver == "character" then
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

function mod:MODIFIER_STATE_CHANGED(ev, modifier, up, ...)
	for i, display in ipairs(displays) do
		display:KeyEvent(modifier, up)
	end
end