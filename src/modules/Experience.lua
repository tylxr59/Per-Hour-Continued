-- import
local PerHour = PerHour
local Utils = Utils

-- declaretion
local Module = {}
PerHour.Modules.Experience = Module

-- properties
Module.Name = "Experience"
Module.TagName = "experience"
Module.ShortName = "XP"
Module.RegisteredEvents = {}

-- custom properties
Module.LastMaxXp = 0
Module.LastXp = 0
Module.TimeToNextLevelValue = 0

-- custom functions
Module.CustomOnUpdate = function(self, elapsed)
    local xpReceived = 0
    local currentMaxXp = UnitXPMax("player")
    local currentXp = UnitXP("player")

    --Utils:AddonMessage("Current XP: " .. currentXp .. " / " .. currentMaxXp)

    if Module.LastMaxXp == currentMaxXp then
        xpReceived = currentXp - Module.LastXp
    elseif Module.LastMaxXp ~= 0 and Module.LastMaxXp < currentMaxXp then
        -- if last max xp is zero, we are in the first loop
        -- else not, just lvl up :) gratz
        local levelUpDiff = Module.LastMaxXp - Module.LastXp
        xpReceived = levelUpDiff + currentXp
    end

    -- update lasts
    Module.LastMaxXp = currentMaxXp
    Module.LastXp = currentXp
    
    -- Element is the amount of XP
    if not Module.HasPaused then
        Module.Element = Module.Element + xpReceived
    end

    -- Calculate time to next level
    if Module.ElementPerHour and Module.ElementPerHour > 0 then
        local xpRemaining = currentMaxXp - currentXp
        Module.TimeToNextLevel = xpRemaining / (Module.ElementPerHour / 60)
    else
        Module.TimeToNextLevel = 0
    end
end

Module.CustomReset = function()
    Module.LastMaxXp = 0
    Module.LastXp = 0
    Module.TimeToNextLevel = 0
end