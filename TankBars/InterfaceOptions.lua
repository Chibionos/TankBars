local addonName, addon = ...
local TBH = TankBars

local function CreateInterfaceOptions()
    -- Main settings panel
    local mainPanel = CreateFrame("Frame", "TankBarsOptionsPanel", UIParent)
    mainPanel.name = "Tank Bar Helper"
    mainPanel:Hide()
    
    -- Title
    local title = mainPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("Tank Bar Helper")
    
    local subtitle = mainPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    subtitle:SetText("Clean and satisfying health and shield tracker for tanks")
    
    local version = mainPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    version:SetPoint("TOPRIGHT", -16, -16)
    version:SetText("v1.0.0")
    
    local yOffset = -60
    
    -- Helper function to create checkboxes
    local function CreateCheckbox(parent, text, dbKey, tooltip)
        local checkbox = CreateFrame("CheckButton", nil, parent, "InterfaceOptionsCheckButtonTemplate")
        checkbox:SetPoint("TOPLEFT", 16, yOffset)
        checkbox.Text:SetText(text)
        
        checkbox:SetChecked(TankBarsDB[dbKey])
        checkbox:SetScript("OnClick", function(self)
            TankBarsDB[dbKey] = self:GetChecked()
            TBH:UpdateSettings()
        end)
        
        if tooltip then
            checkbox.tooltipText = text
            checkbox.tooltipRequirement = tooltip
        end
        
        yOffset = yOffset - 30
        return checkbox
    end
    
    -- Helper function to create sliders
    local function CreateSlider(parent, text, dbKey, min, max, step, tooltip)
        local slider = CreateFrame("Slider", nil, parent, "OptionsSliderTemplate")
        slider:SetPoint("TOPLEFT", 20, yOffset)
        slider:SetWidth(200)
        slider:SetMinMaxValues(min, max)
        slider:SetValue(TankBarsDB[dbKey])
        slider:SetValueStep(step)
        slider:SetObeyStepOnDrag(true)
        
        slider.Text:SetText(text)
        slider.Low:SetText(tostring(min))
        slider.High:SetText(tostring(max))
        
        local valueText = slider:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        valueText:SetPoint("TOP", slider, "BOTTOM", 0, -2)
        valueText:SetText(string.format("%.1f", TankBarsDB[dbKey]))
        
        slider:SetScript("OnValueChanged", function(self, value)
            TankBarsDB[dbKey] = value
            valueText:SetText(string.format("%.1f", value))
            TBH:UpdateSettings()
        end)
        
        if tooltip then
            slider.tooltipText = text
            slider.tooltipRequirement = tooltip
        end
        
        yOffset = yOffset - 50
        return slider
    end
    
    -- General Settings
    local generalHeader = mainPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalMed1")
    generalHeader:SetPoint("TOPLEFT", 16, yOffset)
    generalHeader:SetText("General Settings")
    yOffset = yOffset - 25
    
    CreateCheckbox(mainPanel, "Show Numbers", "showNumbers", "Display health and shield values")
    CreateCheckbox(mainPanel, "Smooth Animations", "smoothAnimation", "Enable smooth bar transitions")
    CreateCheckbox(mainPanel, "Glow on Low Health", "glowOnLowHealth", "Show red glow when health is low")
    CreateCheckbox(mainPanel, "Pulse on Damage", "pulseOnDamage", "Flash effect when taking damage")
    CreateCheckbox(mainPanel, "Show Empty Absorb", "showEmptyAbsorb", "Show indicator when no absorb shield is active")
    
    -- Advanced Features
    local advancedHeader = mainPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalMed1")
    advancedHeader:SetPoint("TOPLEFT", 16, yOffset)
    advancedHeader:SetText("Advanced Features")
    yOffset = yOffset - 25
    
    CreateCheckbox(mainPanel, "Show Damage Projection", "showDamageProjection", "Display predicted incoming damage based on recent history")
    CreateCheckbox(mainPanel, "Show Off-Tank Bar", "showOffTank", "Display health bars for other tanks in your group")
    CreateCheckbox(mainPanel, "Show Boss Abilities", "showBossAbilities", "Show incoming boss ability warnings (requires DBM or BigWigs)")
    
    -- Size Settings
    yOffset = -60
    local sizeHeader = mainPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalMed1")
    sizeHeader:SetPoint("TOPLEFT", 280, yOffset)
    sizeHeader:SetText("Size & Appearance")
    yOffset = yOffset - 25
    
    local sliderParent = mainPanel
    local sliderX = 260
    
    local widthSlider = CreateSlider(mainPanel, "Bar Width", "width", 20, 100, 5, "Width of the health and shield bars")
    widthSlider:SetPoint("TOPLEFT", sliderX, yOffset)
    
    local heightSlider = CreateSlider(mainPanel, "Bar Height", "height", 100, 500, 10, "Height of the health and shield bars")
    heightSlider:SetPoint("TOPLEFT", sliderX, yOffset)
    
    local numberSlider = CreateSlider(mainPanel, "Number Size", "numberSize", 8, 20, 1, "Size of the value text")
    numberSlider:SetPoint("TOPLEFT", sliderX, yOffset)
    
    local speedSlider = CreateSlider(mainPanel, "Animation Speed", "animationSpeed", 0.05, 0.5, 0.05, "Speed of smooth animations")
    speedSlider:SetPoint("TOPLEFT", sliderX, yOffset)
    
    local thresholdSlider = CreateSlider(mainPanel, "Low Health %", "lowHealthThreshold", 10, 50, 5, "Health percentage to trigger warnings")
    thresholdSlider:SetPoint("TOPLEFT", sliderX, yOffset)
    
    -- Position Controls
    local positionHeader = mainPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalMed1")
    positionHeader:SetPoint("BOTTOMLEFT", mainPanel, "BOTTOMLEFT", 16, 120)
    positionHeader:SetText("Position")
    
    local lockButton = CreateFrame("Button", nil, mainPanel, "UIPanelButtonTemplate")
    lockButton:SetSize(100, 22)
    lockButton:SetPoint("BOTTOMLEFT", 16, 80)
    lockButton:SetText("Lock Position")
    lockButton:SetScript("OnClick", function()
        TBH:Lock()
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
    end)
    
    local unlockButton = CreateFrame("Button", nil, mainPanel, "UIPanelButtonTemplate")
    unlockButton:SetSize(100, 22)
    unlockButton:SetPoint("LEFT", lockButton, "RIGHT", 10, 0)
    unlockButton:SetText("Unlock Position")
    unlockButton:SetScript("OnClick", function()
        TBH:Unlock()
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
    end)
    
    local resetButton = CreateFrame("Button", nil, mainPanel, "UIPanelButtonTemplate")
    resetButton:SetSize(100, 22)
    resetButton:SetPoint("LEFT", unlockButton, "RIGHT", 10, 0)
    resetButton:SetText("Reset All")
    resetButton:SetScript("OnClick", function()
        StaticPopup_Show("TANKBARHELPER_RESET_CONFIRM")
    end)
    
    local configButton = CreateFrame("Button", nil, mainPanel, "UIPanelButtonTemplate")
    configButton:SetSize(120, 22)
    configButton:SetPoint("BOTTOMLEFT", 16, 40)
    configButton:SetText("Advanced Config")
    configButton:SetScript("OnClick", function()
        InterfaceOptionsFrame:Hide()
        SlashCmdList["TANKBARHELPER"]("config")
    end)
    
    -- Refresh function
    mainPanel.refresh = function()
        -- Update all checkboxes and sliders with current values
        for _, child in ipairs({mainPanel:GetChildren()}) do
            if child:GetObjectType() == "CheckButton" then
                for key, value in pairs(TankBarsDB) do
                    if child.dbKey == key then
                        child:SetChecked(value)
                    end
                end
            elseif child:GetObjectType() == "Slider" then
                for key, value in pairs(TankBarsDB) do
                    if child.dbKey == key then
                        child:SetValue(value)
                    end
                end
            end
        end
    end
    
    -- Okay/Cancel handlers for options panel
    mainPanel.okay = function()
        -- Settings are saved immediately, nothing to do here
    end
    
    mainPanel.cancel = function()
        -- Could implement revert functionality here if needed
    end
    
    mainPanel.default = function()
        StaticPopup_Show("TANKBARHELPER_RESET_CONFIRM")
    end
    
    -- Register the panel with the new Settings API
    local category = Settings.RegisterCanvasLayoutCategory(mainPanel, "Tank Bar Helper")
    Settings.RegisterAddOnCategory(category)
    
    -- Also store reference for compatibility
    TBH.settingsCategory = category
    
    return mainPanel
end

-- Initialize when addon loads
local function InitializeInterfaceOptions()
    -- Ensure DB is initialized
    if not TankBarsDB then
        TankBarsDB = {}
        for key, value in pairs(TBH.defaults or {}) do
            TankBarsDB[key] = value
        end
    end
    
    -- Create the interface options panel
    CreateInterfaceOptions()
end

-- Register for addon loaded event
local loader = CreateFrame("Frame")
loader:RegisterEvent("ADDON_LOADED")
loader:SetScript("OnEvent", function(self, event, name)
    if name == addonName then
        C_Timer.After(0.1, InitializeInterfaceOptions)
        self:UnregisterEvent("ADDON_LOADED")
    end
end)