-- import
local PerHour = PerHour
local Utils = Utils
local BaseModule = BaseModule

-- declaration
local Module = {}
PerHour.Modules.Reputation = Module

-- properties
Module.Name = "Reputation"
Module.TagName = "reputation"
Module.ShortName = "Rep"
Module.RegisteredEvents = {}

-- custom properties
Module.LastReputationName = ""
Module.LastReputationValue = 0
Module.TimeToNextLevel = 0

-- custom messages
Module.CustomSendToMessages = {
    ["message1"] = function()
        local reputationName = Module.LastReputationName ~= "" and Module.LastReputationName or ""
        return "Reputation: ...... " .. reputationName
    end
}

Module.HasWaitingWithoutFaction = false
Module.WaitingWithoutFactionTime = 0
local STATIC_TOLERATION_INTERVAL = 0.1

-- custom functions
Module.CustomOnUpdate = function(self, elapsed)
    local reputationReceived = 0
    local watchedFactionData = C_Reputation.GetWatchedFactionData()
    if watchedFactionData then
        local currentName = watchedFactionData.name
        local currentValue = watchedFactionData.currentStanding
        local currentThreshold = watchedFactionData.currentReactionThreshold 
        local nextThreshold = watchedFactionData.nextReactionThreshold

        if nextThreshold then
            local displayCurrentValue = math.abs(currentValue - currentThreshold)
            local displayNextThreshold = math.abs(nextThreshold - currentThreshold)
            local percentComplete = (displayCurrentValue / displayNextThreshold) * 100

            if Module.ElementPerHour and Module.ElementPerHour > 0 then
                local reputationRemaining = displayNextThreshold - displayCurrentValue
                Module.TimeToNextLevel = reputationRemaining / (Module.ElementPerHour / 60)
            else
                Module.TimeToNextLevel = 0
            end
        end

        if currentName then
            Module.HasWaitingWithoutFaction = true
            Module.WaitingWithoutFactionTime = 0

            if Module.LastReputationName ~= "" and Module.LastReputationName ~= currentName then
                Utils:AddonMessage(Module.Name .. " was changed from " .. Module.LastReputationName .. " to " .. currentName .. ".")
                Utils:AddonMessage(Module.Name .. " reset.")
                BaseModule:ResetModule(Module)
            else
                if Module.LastReputationValue ~= 0 then
                    reputationReceived = currentValue - Module.LastReputationValue
                end

                Module.LastReputationValue = currentValue
                Module.LastReputationName = currentName

                if not Module.HasPaused then
                    Module.Element = Module.Element + reputationReceived
                end
            end
        else
            if Module.HasWaitingWithoutFaction then
                Module.WaitingWithoutFactionTime = Module.WaitingWithoutFactionTime + elapsed
                if Module.WaitingWithoutFactionTime > STATIC_TOLERATION_INTERVAL then
                    Module.HasWaitingWithoutFaction = false
                end
            else
                Utils:AddonMessage(Module.Name .. " must be selected to be displayed as Experience Bar.")
                BaseModule:ResetModule(Module)
            end
        end
    else
        Utils:AddonMessage("Debug: No watched faction data available.")
    end
end

Module.CustomReset = function()
    Module.LastReputationName = ""
    Module.LastReputationValue = 0
    Module.HasWaitingWithoutFaction = false
    Module.WaitingWithoutFactionTime = 0
    Module.TimeToNextLevel = 0
end

Module.CustomStartedMessage = function()
    local startedMessage = " was not selected."
    local watchedFactionData = C_Reputation.GetWatchedFactionData()
    if watchedFactionData and watchedFactionData.name then
        startedMessage = " [" .. watchedFactionData.name .. "] monitoring started."
    end
    return startedMessage
end