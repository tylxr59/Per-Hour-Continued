-- import
local PerHour = PerHour
local Utils = Utils

-- declaretion
local Module = {}
PerHour.Modules.Honor = Module

-- properties
Module.Name = "Honor"
Module.TagName = "honor"
Module.ShortName = "hon"
Module.RegisteredEvents = {"CHAT_MSG_COMBAT_HONOR_GAIN","TIME_PLAYED_MSG"}

-- custom properties
Module.TimeToNextLevel = 0

-- custom functions
Module.CustomOnEvent = function(self, event, ...)
    if not Module.HasPaused then
    
        if event == "CHAT_MSG_COMBAT_HONOR_GAIN" then
            local arg = {...}
            -- have to be better tested
            startPoint, endPoint, honorPoints = string.find(arg[1], "(%d+)")
            Module.Element = Module.Element + tonumber(honorPoints, 10)
        elseif event == "TIME_PLAYED_MSG" then
            -- testing
            -- Module.Element = Module.Element + 420
        end
        
        -- Calculate time to next level
        if Module.ElementPerHour and Module.ElementPerHour > 0 then
            local honorRemaining = Module.NextLevelHonor - Module.Element
            Module.TimeToNextLevel = honorRemaining / (Module.ElementPerHour / 60)
        else
            Module.TimeToNextLevel = 0
        end
    end
end

Module.CustomReset = function()
    Module.Element = 0
    Module.TimeToNextLevel = 0
end