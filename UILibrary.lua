--[[
    Professional UI Library for Roblox
    Version: 2.0.0
    
    A modern, performant UI library with proper error handling,
    modular architecture, and professional code standards.
]]

local UILibrary = {}
UILibrary.__index = UILibrary
UILibrary.Version = "2.0.0"

-- Services
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:FindFirstChild("CoreGui")
local PlayerGui = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")

-- Module Components
local Theme = loadstring(game:HttpGet("https://raw.githubusercontent.com/example/library/main/Utils/Theme.lua"))()
local Utilities = loadstring(game:HttpGet("https://raw.githubusercontent.com/example/library/main/Utils/Utilities.lua"))()
local InputHandler = loadstring(game:HttpGet("https://raw.githubusercontent.com/example/library/main/Utils/InputHandler.lua"))()
local Window = loadstring(game:HttpGet("https://raw.githubusercontent.com/example/library/main/Core/Window.lua"))()

-- Library State
UILibrary.flags = {}
UILibrary.items = {}
UILibrary.windows = {}

--[[
    Creates a new window instance
    @param config: table - Window configuration
    @return Window: Window instance
]]
function UILibrary:createWindow(config)
    -- Input validation
    if type(config) ~= "table" then
        error("UILibrary:createWindow expects a configuration table", 2)
    end
    
    local windowConfig = Utilities.validateConfig(config, {
        title = { type = "string", default = "UI Library" },
        toggleKey = { type = "EnumItem", default = Enum.KeyCode.RightShift },
        visible = { type = "boolean", default = true },
        resizable = { type = "boolean", default = false },
        minSize = { type = "Vector2", default = Vector2.new(500, 300) },
        maxSize = { type = "Vector2", default = Vector2.new(1200, 800) }
    })
    
    local window = Window.new(windowConfig, self)
    table.insert(self.windows, window)
    
    return window
end

--[[
    Gets a flag value
    @param flagName: string - Flag identifier
    @return any: Flag value
]]
function UILibrary:getFlag(flagName)
    if type(flagName) ~= "string" then
        warn("UILibrary:getFlag expects a string flag name")
        return nil
    end
    
    return self.flags[flagName]
end

--[[
    Sets a flag value
    @param flagName: string - Flag identifier
    @param value: any - Flag value
]]
function UILibrary:setFlag(flagName, value)
    if type(flagName) ~= "string" then
        error("UILibrary:setFlag expects a string flag name", 2)
    end
    
    local oldValue = self.flags[flagName]
    self.flags[flagName] = value
    
    -- Notify listeners if value changed
    if oldValue ~= value then
        self:_notifyFlagChange(flagName, value, oldValue)
    end
end

--[[
    Internal method to notify flag changes
    @param flagName: string - Flag identifier
    @param newValue: any - New value
    @param oldValue: any - Previous value
]]
function UILibrary:_notifyFlagChange(flagName, newValue, oldValue)
    for _, window in ipairs(self.windows) do
        if window._onFlagChanged then
            pcall(window._onFlagChanged, window, flagName, newValue, oldValue)
        end
    end
end

--[[
    Destroys all library instances and cleans up resources
]]
function UILibrary:destroy()
    for _, window in ipairs(self.windows) do
        if window.destroy then
            pcall(window.destroy, window)
        end
    end
    
    self.windows = {}
    self.flags = {}
    self.items = {}
end

--[[
    Creates a new library instance
    @return UILibrary: New library instance
]]
function UILibrary.new()
    local self = setmetatable({}, UILibrary)
    self.flags = {}
    self.items = {}
    self.windows = {}
    
    return self
end

-- Default instance for backward compatibility
local defaultLibrary = UILibrary.new()

-- Export both class and default instance
return setmetatable({
    new = UILibrary.new,
    createWindow = function(config) return defaultLibrary:createWindow(config) end,
    getFlag = function(flag) return defaultLibrary:getFlag(flag) end,
    setFlag = function(flag, value) return defaultLibrary:setFlag(flag, value) end,
    destroy = function() return defaultLibrary:destroy() end,
    flags = defaultLibrary.flags,
    Theme = Theme
}, {
    __index = UILibrary,
    __call = function(_, ...)
        return UILibrary.new(...)
    end
})
