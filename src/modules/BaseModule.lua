-- definition
BaseModule = {}

function BaseModule:SendTo(contextModule, chatType)

    -- chatType = chatType:upper()
    local addonNamePrepend = "Per Hour || "

    local greetingsMessage = addonNamePrepend.."A performance tracker AddOn!"
    local trackingMessage = addonNamePrepend.."Tracking: "..contextModule.Name
    local perHourMessage = addonNamePrepend..contextModule.ElementPerHourText:GetText()..": "..contextModule.ElementPerHour
    local perMinuteMessage = addonNamePrepend..contextModule.ElementPerMinuteText:GetText()..": "..contextModule.ElementPerMinute
    local forMessage = addonNamePrepend.."For: "..Utils:DisplayTimer(contextModule.Time).."s"
    local totalMessage = addonNamePrepend.."Total of "..contextModule.ShortName:lower()..": "..Utils:DisplayNumber(contextModule.Element)
    
    SendChatMessage(greetingsMessage, chatType)
    SendChatMessage(trackingMessage, chatType)
    SendChatMessage(perHourMessage, chatType)
    SendChatMessage(perMinuteMessage, chatType)
    SendChatMessage(forMessage, chatType)
    SendChatMessage(totalMessage, chatType)
    
    if contextModule.CustomSendToMessages ~= nil then
        for key,value in pairs(contextModule.CustomSendToMessages) do
            SendChatMessage(addonNamePrepend..value(), chatType)
        end
    end

    Utils:AddonMessage("results sent to "..chatType:lower().." successfully.")
end

function BaseModule:RefreshDisplayedValues(contextModule)
    contextModule.TimeValue:SetText(Utils:DisplayTimer(contextModule.Time))
    contextModule.ElementValue:SetText(Utils:DisplayNumber(contextModule.Element))
    contextModule.ElementPerHourValue:SetText(Utils:DisplayRoundedNumber(contextModule.ElementPerHour, 0))
    contextModule.ElementPerMinuteValue:SetText(Utils:DisplayRoundedNumber(contextModule.ElementPerMinute, 1))
end

-- public functions
function BaseModule:ResetModule(contextModule)
    -- control values
    contextModule.HasStarted = false
    contextModule.HasPaused = false

    contextModule.StartedAt = 0
    contextModule.PausedAt = 0
    contextModule.PausedTime = 0

    contextModule.TimeSinceLastUpdate = 0

    -- displayable values
    contextModule.Time = 0
    contextModule.Element = 0
    contextModule.ElementPerHour = 0
    contextModule.ElementPerMinute = 0
    
    -- run custom
    if contextModule.CustomReset~=nil then
        contextModule.CustomReset()
    end

    -- reset the button
    if contextModule.ToggleStartButtom~=nil then
        contextModule.ToggleStartButtom:SetText("Start")
    end
    
    BaseModule:RefreshDisplayedValues(contextModule)
end

