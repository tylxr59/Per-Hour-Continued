-- import
local PerHour = PerHour
local Utils = Utils

-- declaration
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

    if Module.LastMaxXp == currentMaxXp then
        xpReceived = currentXp - Module.LastXp
    elseif Module.LastMaxXp ~= 0 and Module.LastMaxXp < currentMaxXp then
        local levelUpDiff = Module.LastMaxXp - Module.LastXp
        xpReceived = levelUpDiff + currentXp
    end

    Module.LastMaxXp = currentMaxXp
    Module.LastXp = currentXp

    if not Module.HasPaused then
        Module.Element = Module.Element + xpReceived
    end

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