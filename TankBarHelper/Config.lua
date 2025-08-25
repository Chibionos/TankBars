local addonName, addon = ...
local TBH = TankBarHelper

SLASH_TANKBARHELPER1 = "/tbh"
SLASH_TANKBARHELPER2 = "/tankbar"
SLASH_TANKBARHELPER3 = "/tankbarhelper"

local function ShowHelp()
    print("|cff00ccffTank Bar Helper|r Commands:")
    print("|cff00ff00/tbh|r - Show this help menu")
    print("|cff00ff00/tbh lock|r - Lock the frame position")
    print("|cff00ff00/tbh unlock|r - Unlock the frame to move it")
    print("|cff00ff00/tbh reset|r - Reset to default settings")
    print("|cff00ff00/tbh config|r - Open configuration panel")
    print("|cff00ff00/tbh scale [0.5-2.0]|r - Set the scale of the bars")
    print("|cff00ff00/tbh width [20-100]|r - Set the width of the bars")
    print("|cff00ff00/tbh height [100-500]|r - Set the height of the bars")
    print("|cff00ff00/tbh numbers on/off|r - Toggle number display")
    print("|cff00ff00/tbh smooth on/off|r - Toggle smooth animations")
    print("|cff00ff00/tbh glow on/off|r - Toggle low health glow")
    print("|cff00ff00/tbh pulse on/off|r - Toggle damage pulse effect")
    print("|cff00ff00/tbh empty on/off|r - Toggle empty absorb indicator")
end

local function SetScale(scale)
    scale = tonumber(scale)
    if not scale or scale < 0.5 or scale > 2 then
        print("|cff00ccffTank Bar Helper:|r Scale must be between 0.5 and 2.0")
        return
    end
    
    local frame = TankBarHelperFrame
    if frame then
        frame:SetScale(scale)
        TankBarHelperDB.scale = scale
        print("|cff00ccffTank Bar Helper:|r Scale set to " .. scale)
    end
end

local function SetWidth(width)
    width = tonumber(width)
    if not width or width < 20 or width > 100 then
        print("|cff00ccffTank Bar Helper:|r Width must be between 20 and 100")
        return
    end
    
    TankBarHelperDB.width = width
    TBH:UpdateSettings()
    print("|cff00ccffTank Bar Helper:|r Width set to " .. width)
end

local function SetHeight(height)
    height = tonumber(height)
    if not height or height < 100 or height > 500 then
        print("|cff00ccffTank Bar Helper:|r Height must be between 100 and 500")
        return
    end
    
    TankBarHelperDB.height = height
    TBH:UpdateSettings()
    print("|cff00ccffTank Bar Helper:|r Height set to " .. height)
end

local function ToggleOption(option, state)
    local validOptions = {
        numbers = "showNumbers",
        smooth = "smoothAnimation",
        glow = "glowOnLowHealth",
        pulse = "pulseOnDamage",
        empty = "showEmptyAbsorb"
    }
    
    local dbKey = validOptions[option]
    if not dbKey then
        print("|cff00ccffTank Bar Helper:|r Invalid option: " .. option)
        return
    end
    
    local enabled = state == "on"
    TankBarHelperDB[dbKey] = enabled
    TBH:UpdateSettings()
    
    local status = enabled and "|cff00ff00enabled|r" or "|cffff0000disabled|r"
    print("|cff00ccffTank Bar Helper:|r " .. option .. " " .. status)
end

local function ResetSettings()
    TankBarHelperDB = nil
    ReloadUI()
end

local function CreateConfigPanel()
    local panel = CreateFrame("Frame", "TankBarHelperConfigPanel", UIParent, "BasicFrameTemplateWithInset")
    panel:SetSize(400, 500)
    panel:SetPoint("CENTER")
    panel:SetMovable(true)
    panel:EnableMouse(true)
    panel:RegisterForDrag("LeftButton")
    panel:SetScript("OnDragStart", panel.StartMoving)
    panel:SetScript("OnDragStop", panel.StopMovingOrSizing)
    panel:Hide()
    
    panel.title = panel:CreateFontString(nil, "OVERLAY")
    panel.title:SetFontObject("GameFontHighlightLarge")
    panel.title:SetPoint("TOP", panel.TitleBg, "TOP", 0, -5)
    panel.title:SetText("Tank Bar Helper Configuration")
    
    local yOffset = -40
    local function CreateCheckbox(text, dbKey)
        local checkbox = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
        checkbox:SetPoint("TOPLEFT", panel, "TOPLEFT", 20, yOffset)
        checkbox.text = checkbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        checkbox.text:SetPoint("LEFT", checkbox, "RIGHT", 5, 0)
        checkbox.text:SetText(text)
        
        checkbox:SetChecked(TankBarHelperDB[dbKey])
        checkbox:SetScript("OnClick", function(self)
            TankBarHelperDB[dbKey] = self:GetChecked()
            TBH:UpdateSettings()
        end)
        
        yOffset = yOffset - 30
        return checkbox
    end
    
    local function CreateSlider(text, dbKey, min, max, step)
        local slider = CreateFrame("Slider", nil, panel, "OptionsSliderTemplate")
        slider:SetPoint("TOPLEFT", panel, "TOPLEFT", 30, yOffset)
        slider:SetWidth(340)
        slider:SetMinMaxValues(min, max)
        slider:SetValue(TankBarHelperDB[dbKey])
        slider:SetValueStep(step)
        slider:SetObeyStepOnDrag(true)
        
        slider.Text:SetText(text)
        slider.Low:SetText(tostring(min))
        slider.High:SetText(tostring(max))
        
        local valueText = slider:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        valueText:SetPoint("TOP", slider, "BOTTOM", 0, -2)
        
        slider:SetScript("OnValueChanged", function(self, value)
            TankBarHelperDB[dbKey] = value
            valueText:SetText(string.format("%.1f", value))
            TBH:UpdateSettings()
        end)
        
        valueText:SetText(string.format("%.1f", TankBarHelperDB[dbKey]))
        
        yOffset = yOffset - 50
        return slider
    end
    
    local function CreateColorPicker(text, dbKey)
        local button = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
        button:SetSize(100, 22)
        button:SetPoint("TOPLEFT", panel, "TOPLEFT", 30, yOffset)
        button:SetText(text)
        
        local colorSwatch = button:CreateTexture(nil, "OVERLAY")
        colorSwatch:SetSize(16, 16)
        colorSwatch:SetPoint("RIGHT", button, "LEFT", -5, 0)
        colorSwatch:SetColorTexture(unpack(TankBarHelperDB[dbKey]))
        
        button:SetScript("OnClick", function()
            local r, g, b, a = unpack(TankBarHelperDB[dbKey])
            ColorPickerFrame:SetColorRGB(r, g, b)
            ColorPickerFrame.hasOpacity = true
            ColorPickerFrame.opacity = a
            ColorPickerFrame.previousValues = {r, g, b, a}
            
            ColorPickerFrame.func = function()
                local r, g, b = ColorPickerFrame:GetColorRGB()
                local a = OpacitySliderFrame:GetValue()
                TankBarHelperDB[dbKey] = {r, g, b, a}
                colorSwatch:SetColorTexture(r, g, b, a)
                TBH:UpdateSettings()
            end
            
            ColorPickerFrame.opacityFunc = ColorPickerFrame.func
            ColorPickerFrame.cancelFunc = function(previousValues)
                TankBarHelperDB[dbKey] = previousValues
                colorSwatch:SetColorTexture(unpack(previousValues))
                TBH:UpdateSettings()
            end
            
            ColorPickerFrame:Show()
        end)
        
        yOffset = yOffset - 30
        return button
    end
    
    CreateCheckbox("Show Numbers", "showNumbers")
    CreateCheckbox("Smooth Animations", "smoothAnimation")
    CreateCheckbox("Glow on Low Health", "glowOnLowHealth")
    CreateCheckbox("Pulse on Damage", "pulseOnDamage")
    CreateCheckbox("Show Empty Absorb", "showEmptyAbsorb")
    CreateCheckbox("Show Off-Tank Bar", "showOffTank")
    CreateCheckbox("Show Boss Abilities", "showBossAbilities")
    
    CreateSlider("Bar Width", "width", 20, 100, 5)
    CreateSlider("Bar Height", "height", 100, 500, 10)
    CreateSlider("Number Size", "numberSize", 8, 20, 1)
    CreateSlider("Animation Speed", "animationSpeed", 0.05, 0.5, 0.05)
    
    CreateColorPicker("Health Color", "healthColor")
    CreateColorPicker("Absorb Color", "absorbColor")
    CreateColorPicker("Background", "backgroundColor")
    
    local lockButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    lockButton:SetSize(100, 22)
    lockButton:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 20, 40)
    lockButton:SetText("Lock Position")
    lockButton:SetScript("OnClick", function()
        TBH:Lock()
        print("|cff00ccffTank Bar Helper:|r Frame locked")
    end)
    
    local unlockButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    unlockButton:SetSize(100, 22)
    unlockButton:SetPoint("LEFT", lockButton, "RIGHT", 10, 0)
    unlockButton:SetText("Unlock Position")
    unlockButton:SetScript("OnClick", function()
        TBH:Unlock()
        print("|cff00ccffTank Bar Helper:|r Frame unlocked - drag to move")
    end)
    
    local resetButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    resetButton:SetSize(100, 22)
    resetButton:SetPoint("LEFT", unlockButton, "RIGHT", 10, 0)
    resetButton:SetText("Reset All")
    resetButton:SetScript("OnClick", function()
        StaticPopup_Show("TANKBARHELPER_RESET_CONFIRM")
    end)
    
    return panel
end

StaticPopupDialogs["TANKBARHELPER_RESET_CONFIRM"] = {
    text = "Are you sure you want to reset all Tank Bar Helper settings to default? This will reload your UI.",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function()
        ResetSettings()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}

local configPanel = nil

SlashCmdList["TANKBARHELPER"] = function(msg)
    local command, arg = strsplit(" ", msg, 2)
    command = command:lower()
    
    if command == "" or command == "help" then
        ShowHelp()
    elseif command == "lock" then
        TBH:Lock()
        print("|cff00ccffTank Bar Helper:|r Frame locked")
    elseif command == "unlock" then
        TBH:Unlock()
        print("|cff00ccffTank Bar Helper:|r Frame unlocked - drag to move")
    elseif command == "reset" then
        StaticPopup_Show("TANKBARHELPER_RESET_CONFIRM")
    elseif command == "config" then
        if not configPanel then
            configPanel = CreateConfigPanel()
        end
        if configPanel:IsShown() then
            configPanel:Hide()
        else
            configPanel:Show()
        end
    elseif command == "scale" then
        SetScale(arg)
    elseif command == "width" then
        SetWidth(arg)
    elseif command == "height" then
        SetHeight(arg)
    elseif command == "numbers" or command == "smooth" or command == "glow" or command == "pulse" or command == "empty" then
        if arg and (arg == "on" or arg == "off") then
            ToggleOption(command, arg)
        else
            print("|cff00ccffTank Bar Helper:|r Usage: /tbh " .. command .. " on/off")
        end
    else
        print("|cff00ccffTank Bar Helper:|r Unknown command: " .. command)
        ShowHelp()
    end
end

print("|cff00ccffTank Bar Helper|r loaded! Type |cff00ff00/tbh|r for help.")