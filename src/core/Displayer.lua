-- import
local PerHour = PerHour
local Utils = Utils
local BaseModule = BaseModule
local Modules = PerHour.Modules

-- class declaration
PerHour.Displayer = {}
Displayer = PerHour.Displayer

-- private properties
local Padding = 2
local PaddingIcon = 7
local Margin = 5
local FrameWidth = 140
local FrameHeight = 150
local STATIC_UPDATE_INTERVAL = 1

local function PaddingTop(padding) return padding * -1 end
local function PaddingBottom(padding) return padding end
local function PaddingLeft(padding) return padding * -1 end
local function PaddingRight(padding) return padding end
local function GetMarginTop() return Margin * -1 end
local function GetMarginBottom() return Margin end

-- private buttons functions
local function ToggleStartOnClick(contextModule)
    if contextModule.HasStarted and not contextModule.HasPaused then
        contextModule.HasPaused = true
        contextModule.PausedAt = GetTime()
        contextModule.ToggleStartButtom:SetText("Start")
        Utils:AddonMessage(contextModule.Name .. " paused.")
    elseif contextModule.HasStarted and contextModule.HasPaused then
        contextModule.HasPaused = false
        contextModule.PausedTime = contextModule.PausedTime + GetTime() - contextModule.PausedAt
        contextModule.ToggleStartButtom:SetText("Pause")
        Utils:AddonMessage(contextModule.Name .. " was unpaused.")
    elseif not contextModule.HasStarted then
        contextModule.HasStarted = true
        contextModule.StartedAt = GetTime()
        contextModule.ToggleStartButtom:SetText("Pause")
        local startedMessage = contextModule.CustomStartedMessage and contextModule.CustomStartedMessage() or " started."
        Utils:AddonMessage(contextModule.Name .. startedMessage)
    end
end

local function ButtonResetOnClick(contextModule)
    BaseModule:ResetModule(contextModule)
    Utils:AddonMessage(contextModule.Name .. " reset.")
end

-- private render functions
local function RenderFrame(contextModule)
    local Frame = CreateFrame("Frame", PerHour.AddonName .. "-" .. contextModule.TagName .. "-frame", UIParent)
    contextModule.Frame = Frame
    Frame:SetFrameStrata("HIGH")
    Frame:SetWidth(FrameWidth)
    Frame:SetHeight(FrameHeight)
    Frame:SetMovable(true)
    Frame:SetClampedToScreen(true)
    Frame:SetScript("OnMouseDown", function(self) self:StartMoving() end)
    Frame:SetScript("OnMouseUp", function(self) self:StopMovingOrSizing() end)
    Frame:SetPoint("CENTER", 0, 0)
    local FrameTexture = Frame:CreateTexture(nil, "BACKGROUND")
    FrameTexture:SetColorTexture(0, 0, 0, 0.2)
    FrameTexture:SetAllPoints(Frame)
end

local function RenderElements(contextModule)
    local Frame = contextModule.Frame
    local timeText = Frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    timeText:SetPoint("TOP", (FrameWidth / 4) * -1, GetMarginTop())
    timeText:SetText("TIME")
    local timeValue = Frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    timeValue:SetPoint("TOP", timeText, "BOTTOM", 0, PaddingTop(Padding))
    local elementText = Frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    elementText:SetPoint("TOP", (FrameWidth / 4), GetMarginTop())
    elementText:SetText((#contextModule.Name <= 6 and contextModule.Name or contextModule.ShortName):upper())
    local elementValue = Frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    elementValue:SetPoint("TOP", elementText, "BOTTOM", 0, PaddingTop(Padding))
    local elementPerHourText = Frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    elementPerHourText:SetPoint("TOP", 0, -39)
    elementPerHourText:SetText(contextModule.ShortName .. "/h")
    local elementPerHourValue = Frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    elementPerHourValue:SetPoint("TOP", elementPerHourText, "BOTTOM", 0, PaddingTop(Padding))
    elementPerHourValue:SetFont("Fonts\\ARIALN.TTF", 32)
    local elementPerMinuteText = Frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    elementPerMinuteText:SetPoint("TOP", (FrameWidth / 4) * -1, -91)
    elementPerMinuteText:SetText(contextModule.ShortName .. "/min")
    local elementPerMinuteValue = Frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    elementPerMinuteValue:SetPoint("TOP", elementPerMinuteText, "BOTTOM", 0, PaddingTop(Padding))
    local timeToNextLevelText = Frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    timeToNextLevelText:SetPoint("TOP", (FrameWidth / 4) * 1, -91)
    timeToNextLevelText:SetText("TTL")
    local timeToNextLevelValue = Frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    timeToNextLevelValue:SetPoint("TOP", timeToNextLevelText, "BOTTOM", 0, PaddingTop(Padding))
    contextModule.TimeText = timeText
    contextModule.ElementText = elementText
    contextModule.ElementPerHourText = elementPerHourText
    contextModule.ElementPerMinuteText = elementPerMinuteText
    contextModule.TimeToNextLevelText = timeToNextLevelText
    contextModule.TimeValue = timeValue
    contextModule.ElementValue = elementValue
    contextModule.ElementPerHourValue = elementPerHourValue
    contextModule.ElementPerMinuteValue = elementPerMinuteValue
    contextModule.TimeToNextLevelValue = timeToNextLevelValue
end

local function RenderSendTo(contextModule, sendToButton)
    local sendToOptionHeight = 18
    local sendOptionWidth = (FrameWidth - (Margin * 4)) / 2
    local sendToOptions = { "Say", "Yell", "Party", "Guild", "Raid" }
    local sendToOptionsLength = Utils:RoundValue(Utils:GetTableSize(sendToOptions) / 2, 0)
    local sendToFrameHeight = (sendToOptionsLength * sendToOptionHeight) + (sendToOptionHeight + Margin * 2)
    local sendToFrame = CreateFrame("Frame", "SendToFrame" .. contextModule.TagName, sendToButton)
    sendToFrame:SetWidth(FrameWidth)
    sendToFrame:SetHeight(sendToFrameHeight)
    sendToFrame:SetPoint("BOTTOMRIGHT", sendToButton, "TOPRIGHT", PaddingRight(PaddingIcon + Margin), PaddingBottom(0))
    sendToFrame:Hide()
    sendToFrame:SetScript('OnEnter', function(self, motion) if motion then self:Show() end end)
    sendToFrame:SetScript('OnLeave', function(self) self:Hide() end)
    sendToButton:SetScript('OnEnter', function() sendToFrame:Show() end)
    sendToButton:SetScript('OnLeave', function() sendToFrame:Hide() end)
    local function setBorderColor(texture)
        texture:SetColorTexture(0.9, 0.9, 0.9, 1)
    end
    local sendToFrameBorder = CreateFrame("frame", nil, sendToFrame)
    sendToFrameBorder:SetAllPoints(sendToFrame)
    sendToFrameBorder.left = sendToFrameBorder:CreateTexture(nil, "BORDER")
    sendToFrameBorder.left:SetPoint("BOTTOMLEFT", sendToFrameBorder, "BOTTOMLEFT", -2, -1)
    sendToFrameBorder.left:SetPoint("TOPRIGHT", sendToFrameBorder, "TOPLEFT", -1, 1)
    setBorderColor(sendToFrameBorder.left)
    sendToFrameBorder.right = sendToFrameBorder:CreateTexture(nil, "BORDER")
    sendToFrameBorder.right:SetPoint("BOTTOMLEFT", sendToFrameBorder, "BOTTOMRIGHT", 1, -1)
    sendToFrameBorder.right:SetPoint("TOPRIGHT", sendToFrameBorder, "TOPRIGHT", 2, 1)
    setBorderColor(sendToFrameBorder.right)
    sendToFrameBorder.top = sendToFrameBorder:CreateTexture(nil, "BORDER")
    sendToFrameBorder.top:SetPoint("BOTTOMLEFT", sendToFrameBorder, "TOPLEFT", -1, 1)
    sendToFrameBorder.top:SetPoint("TOPRIGHT", sendToFrameBorder, "TOPRIGHT", 1, 2)
    setBorderColor(sendToFrameBorder.top)
    sendToFrameBorder.bottom = sendToFrameBorder:CreateTexture(nil, "BORDER")
    sendToFrameBorder.bottom:SetPoint("BOTTOMLEFT", sendToFrameBorder, "BOTTOMLEFT", -1, -1)
    sendToFrameBorder.bottom:SetPoint("TOPRIGHT", sendToFrameBorder, "BOTTOMRIGHT", 1, -2)
    setBorderColor(sendToFrameBorder.bottom)
    local sendToFrameTexture = sendToFrame:CreateTexture(nil, "BACKGROUND")
    sendToFrameTexture:SetColorTexture(0.1, 0.1, 0.1, 1)
    sendToFrameTexture:SetAllPoints(sendToFrame)
    local sendToTitle = sendToFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    sendToTitle:SetHeight(sendToOptionHeight)
    sendToTitle:SetPoint("TOPLEFT", PaddingRight(Margin), PaddingTop(Padding))
    sendToTitle:SetText("Send to:")
    local pointLeftReference = nil
    local pointRightReference = nil
    local pointIndex = 1
    local firstSendToOptionPadding = sendToOptionHeight + (Padding * 2)
    for key, thisOpt in pairs(sendToOptions) do
        local sendOption = CreateFrame("Button", "SendOption" .. thisOpt, sendToFrame, "OptionsListButtonTemplate")
        sendOption:SetWidth(sendOptionWidth)
        sendOption:SetHeight(sendToOptionHeight)
        sendOption:SetText("/" .. thisOpt:lower())
        sendOption:RegisterForClicks("AnyUp")
        sendOption:SetScript("OnClick", function()
            BaseModule:SendTo(contextModule, thisOpt)
            sendToFrame:Hide()
        end)
        sendOption:SetScript('OnEnter', function() sendToFrame:Show() end)
        sendOption:SetScript('OnLeave', function() sendToFrame:Hide() end)
        local function sideDeciderToPoint(pointReference, sideDecider)
            if pointReference == nil then
                sendOption:SetPoint("TOP", (FrameWidth / 4) * sideDecider, PaddingTop(firstSendToOptionPadding))
            else
                sendOption:SetPoint("TOP", pointReference, "BOTTOM", 0, PaddingTop(Padding))
            end
        end
        if pointIndex % 2 == 0 then
            sideDeciderToPoint(pointRightReference, 1)
            pointRightReference = sendOption
        else
            sideDeciderToPoint(pointLeftReference, -1)
            pointLeftReference = sendOption
        end
        pointIndex = pointIndex + 1
    end
end

local function RenderButtons(contextModule)
    local Frame = contextModule.Frame
    local toggleStartButtom = CreateFrame("Button", "$parent-start-button", Frame, "UIMenuButtonStretchTemplate")
    contextModule.ToggleStartButtom = toggleStartButtom
    toggleStartButtom:SetWidth((FrameWidth / 2) - Margin)
    toggleStartButtom:SetHeight(24)
    toggleStartButtom:SetPoint("BOTTOMLEFT", Frame, "BOTTOM", 0, GetMarginBottom())
    toggleStartButtom:SetText("Start")
    toggleStartButtom:RegisterForClicks("AnyUp")
    toggleStartButtom:SetScript("OnClick", function() ToggleStartOnClick(contextModule) end)
    local resetButtom = CreateFrame("Button", "$parent-reset-button", Frame, "UIMenuButtonStretchTemplate")
    resetButtom:SetWidth((FrameWidth / 2) - Margin)
    resetButtom:SetHeight(24)
    resetButtom:SetPoint("BOTTOMRIGHT", Frame, "BOTTOM", 0, GetMarginBottom())
    resetButtom:SetText("Reset")
    resetButtom:RegisterForClicks("AnyUp")
    resetButtom:SetScript("OnClick", function() ButtonResetOnClick(contextModule) end)
    local sendToButton = CreateFrame("Button", "$parent-sendto-button", Frame, "SecureActionButtonTemplate")
    sendToButton:SetSize(14, 14)
    sendToButton:SetPoint("BOTTOMRIGHT", resetButtom, "TOPRIGHT", PaddingLeft(PaddingIcon), PaddingBottom(Padding))
    sendToButton:SetNormalTexture([[Interface\AddOns\per-hour\src\textures\announcement_black_white]])
    sendToButton:SetHighlightTexture([[Interface\AddOns\per-hour\src\textures\announcement_gold_dark]])
    RenderSendTo(contextModule, sendToButton)
end

local function RegisterScripts(contextModule)
    local Frame = contextModule.Frame
    Frame:SetScript("OnEvent", function(self, event, ...)
        if contextModule.HasStarted and contextModule.CustomOnEvent then
            contextModule.CustomOnEvent(self, event, ...)
        end
    end)
    Frame:SetScript("OnUpdate", function(self, elapsed)
        if contextModule.HasStarted then
            contextModule.TimeSinceLastUpdate = contextModule.TimeSinceLastUpdate + elapsed
            if contextModule.TimeSinceLastUpdate > STATIC_UPDATE_INTERVAL then
                contextModule.TimeSinceLastUpdate = 0
                if contextModule.CustomOnUpdate then
                    contextModule.CustomOnUpdate(self, elapsed)
                end
                if contextModule.HasStarted and not contextModule.HasPaused then
                    contextModule.Time = GetTime() - contextModule.StartedAt - contextModule.PausedTime
                    local elementPerMinute = contextModule.Element / (contextModule.Time / 60)
                    contextModule.ElementPerMinute = Utils:RoundValue(elementPerMinute, 2)
                    contextModule.ElementPerHour = Utils:RoundValue(elementPerMinute * 60, 2)
                    BaseModule:RefreshDisplayedValues(contextModule)
                end
            end
        end
    end)
end

local function RegisterEvents(contextModule)
    local Frame = contextModule.Frame
    Frame:RegisterEvent("ADDON_LOADED")
    for _, value in pairs(contextModule.RegisteredEvents) do
        Frame:RegisterEvent(value)
    end
end

-- public functions
function Displayer:Init()
    for _, contextModule in pairs(Modules) do
        RenderFrame(contextModule)
        RenderElements(contextModule)
        RenderButtons(contextModule)
        RegisterScripts(contextModule)
        RegisterEvents(contextModule)
        ButtonResetOnClick(contextModule)
    end
end

Displayer:Init()
