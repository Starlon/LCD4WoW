
local MAJOR = "LibScriptableUtilsEvaluator-1.0" 
local MINOR = 16
assert(LibStub, MAJOR.." requires LibStub") 
local LibEvaluator = LibStub:NewLibrary(MAJOR, MINOR)
if not LibEvaluator then return end
local LibError = LibStub("LibScriptableUtilsError-1.0")
assert(LibError, "LibEvaluator requires LibScriptableUtilsError-1.0")
local olderror = error
local error = LibError:New("Evaluator")

local pool = setmetatable({}, {__mode = "k"})
	
if not LibEvaluator.__index then
	LibEvaluator.__index = LibEvaluator
end

--[[
-- Create a new LibScriptableEvaluator
-- @usage :New(environment, errorLevel)
-- @param environment Your script environment.
-- @param errorLevel The errorLevel for this object
-- @return A new LibScriptableEvaluator object
function LibEvaluator:New(environment, errorLevel) 	
	local obj = next(pool)

	if obj then
		pool[obj] = nil
	else
		obj = {}
	end

	setmetatable(obj, self)

	obj.environment = environment
	obj.errorLevel = errorLevel
	obj.error = LibError:New(MAJOR, errorLevel)
	
	return obj	
end

-- Delete a LibScriptableEvaluator object
-- @usage :Del()
-- @return Nothing
function LibEvaluator:Del(ev)
	if not ev then ev = self end
	ev.error:Del()
	pool[ev] = true
end
]]

do 
	local function errorhandler(str)
		error:Print(str)
	end
	
	local cache = {} --setmetatable({},{__mode='v'})	
	
	local unit 
	
	--- Execute some code
	-- @usage LibEvaluator.ExecuteCode(self, tag, code, dontSandbox, defval, forRunnable, test)
	-- @param self The script environment.
	-- @param tag A name for your runnable
	-- @param dontSandbox Whether to sandbox the execution or not
	-- @param defval The default value if any
	-- @param forRunnable Boolean indicating whether to return the actual function object or not
	-- @param test Whether to test the runnable before returning it. This is useful if you don't want your script to execute twice.
	-- @return ret1, ret2, ret3, ret4 -- return values from your code. You can pass 4 return values back from your script.
	LibEvaluator.ExecuteCode = function(self, tag, code, dontSandbox, defval, forRunnable, test)
		
		assert(self, "LibEvaluator.ExecuteCode requires an environment")
		assert(tag, "LibEvaluator.ExecuteCode requires a tag")
				
		code = code or "return nil"
		
		code = "return function() " .. code .. "\n end"
				
		local runnable = cache[code]
		local err
		
		local first
				
		if not runnable then
			runnable, err = loadstring(code, tag)
	
			if type(runnable) ~= "function" then 
				error:Print("Error in runnable: " .. err)
				return nil
			end
									
			if not dontSandbox then
				setfenv(runnable, self)
			end
			
			cache[code] = runnable(xpcall, errorhandler)
			
			runnable = cache[code]	
			
			first = true
		end

		if forRunnable and test then
			return runnable() and runnable
		elseif forRunnable then
			return runnable
		end
				
		if type(self.unit) ~= "string" then 
			self.unit = "mouseover" 
		end
		
		local ret1, ret2, ret3, ret4 = runnable()
		
		self.unit = nil
								
		if not ret1 then ret1 = defval end

		return ret1, ret2, ret3, ret4
	end
end