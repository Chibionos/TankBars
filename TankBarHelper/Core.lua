local addonName, addon = ...
local L = {}

TankBarHelper = {}
local TBH = TankBarHelper

local frame = nil
local healthBar = nil
local shieldBar = nil
local healthText = nil
local shieldText = nil
local healthPercentText = nil
local shieldPercentText = nil
local skullIcon = nil
local skullCircle = nil
local damageProjectionBar = nil
local smoothHealthValue = 0
local smoothShieldValue = 0
local lastHealthUpdate = 0
local lastShieldUpdate = 0
local isInitialized = false
local damageHistory = {}
local damageHistoryTime = 5
local projectedDamage = 0
local projectionTime = 5
local safetyBuffer = 1.2

local defaults = {
    position = {"CENTER", UIParent, "CENTER", -200, 0},
    width = 30,
    height = 250,
    spacing = 10,
    healthColor = {0.2, 1, 0.2, 1},
    shieldColor = {0.2, 0.6, 1, 1},
    backgroundColor = {0.1, 0.1, 0.1, 0.8},
    borderColor = {0.3, 0.3, 0.3, 1},
    showNumbers = true,
    numberSize = 11,
    locked = false,
    smoothAnimation = true,
    animationSpeed = 0.15,
    showDamageProjection = true,
    lowHealthThreshold = 40
}

local function SafeCall(func, ...)
    local success, err = pcall(func, ...)
    if not success then
        print("|cffff0000Tank Bar Helper Error:|r " .. tostring(err))
    end
    return success
end

local function ValidateNumber(value, default)
    if type(value) ~= "number" or value ~= value then
        return default or 0
    end
    return value
end

local function ValidateColor(color)
    if type(color) ~= "table" or #color < 3 then
        return {1, 1, 1, 1}
    end
    for i = 1, 4 do
        color[i] = ValidateNumber(color[i], 1)
        color[i] = math.max(0, math.min(1, color[i]))
    end
    return color
end

local function InitializeDB()
    TankBarHelperDB = TankBarHelperDB or {}
    for key, value in pairs(defaults) do
        if TankBarHelperDB[key] == nil then
            TankBarHelperDB[key] = value
        end
    end
    
    TankBarHelperDB.width = ValidateNumber(TankBarHelperDB.width, defaults.width)
    TankBarHelperDB.height = ValidateNumber(TankBarHelperDB.height, defaults.height)
    TankBarHelperDB.spacing = ValidateNumber(TankBarHelperDB.spacing, defaults.spacing)
    TankBarHelperDB.numberSize = ValidateNumber(TankBarHelperDB.numberSize, defaults.numberSize)
    TankBarHelperDB.animationSpeed = ValidateNumber(TankBarHelperDB.animationSpeed, defaults.animationSpeed)
    
    TankBarHelperDB.healthColor = ValidateColor(TankBarHelperDB.healthColor)
    TankBarHelperDB.shieldColor = ValidateColor(TankBarHelperDB.shieldColor)
    TankBarHelperDB.backgroundColor = ValidateColor(TankBarHelperDB.backgroundColor)
    TankBarHelperDB.borderColor = ValidateColor(TankBarHelperDB.borderColor)
    
    if type(TankBarHelperDB.position) ~= "table" or #TankBarHelperDB.position < 3 then
        TankBarHelperDB.position = defaults.position
    end
end

local function UpdateBarPosition()
    if not frame then return end
    
    SafeCall(function()
        frame:ClearAllPoints()
        if TankBarHelperDB.position and #TankBarHelperDB.position >= 3 then
            frame:SetPoint(unpack(TankBarHelperDB.position))
        else
            frame:SetPoint("CENTER", UIParent, "CENTER", -200, 0)
        end
    end)
end

local function AnimateTextChange(fontString, newText)
    if not fontString or not newText then return end
    
    SafeCall(function()
        fontString:SetText(newText)
    end)
end

local function SetupFrame()
    if not SafeCall(function()
        if not frame then
            frame = CreateFrame("Frame", "TankBarHelperFrame", UIParent, "BackdropTemplate")
        end
        
        if not healthBar then
            healthBar = CreateFrame("StatusBar", nil, frame)
        end
        
        if not shieldBar then
            shieldBar = CreateFrame("StatusBar", nil, frame)
        end
        
        if not healthText then
            healthText = frame:CreateFontString(nil, "OVERLAY")
        end
        
        if not shieldText then
            shieldText = frame:CreateFontString(nil, "OVERLAY")
        end
        
        if not healthPercentText then
            healthPercentText = frame:CreateFontString(nil, "OVERLAY")
        end
        
        if not shieldPercentText then
            shieldPercentText = frame:CreateFontString(nil, "OVERLAY")
        end
        
        local totalWidth = (TankBarHelperDB.width * 2) + TankBarHelperDB.spacing
        frame:SetSize(totalWidth + 8, TankBarHelperDB.height)
        
        if frame.SetBackdrop then
            frame:SetBackdrop({
                bgFile = "Interface\\Buttons\\WHITE8x8",
                edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                tile = false,
                tileSize = 0,
                edgeSize = 12,
                insets = { left = 2, right = 2, top = 2, bottom = 2 }
            })
            frame:SetBackdropColor(unpack(ValidateColor(TankBarHelperDB.backgroundColor)))
            frame:SetBackdropBorderColor(unpack(ValidateColor(TankBarHelperDB.borderColor)))
        end
        
        UpdateBarPosition()
        
        frame:SetMovable(not TankBarHelperDB.locked)
        frame:EnableMouse(not TankBarHelperDB.locked)
        frame:RegisterForDrag("LeftButton")
        frame:SetScript("OnDragStart", function(self)
            if not TankBarHelperDB.locked then
                self:StartMoving()
            end
        end)
        frame:SetScript("OnDragStop", function(self)
            self:StopMovingOrSizing()
            SafeCall(function()
                TankBarHelperDB.position = {self:GetPoint()}
            end)
        end)
        
        healthBar:ClearAllPoints()
        healthBar:SetPoint("LEFT", frame, "LEFT", 4, 0)
        healthBar:SetSize(TankBarHelperDB.width, TankBarHelperDB.height - 4)
        healthBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
        healthBar:SetStatusBarColor(unpack(ValidateColor(TankBarHelperDB.healthColor)))
        healthBar:SetOrientation("VERTICAL")
        healthBar:SetReverseFill(false)
        
        if not healthBar.bg then
            healthBar.bg = healthBar:CreateTexture(nil, "BACKGROUND")
            healthBar.bg:SetAllPoints()
            healthBar.bg:SetTexture("Interface\\TargetingFrame\\UI-StatusBar")
        end
        healthBar.bg:SetVertexColor(0.1, 0.1, 0.1, 0.8)
        
        if not damageProjectionBar then
            damageProjectionBar = healthBar:CreateTexture(nil, "OVERLAY")
            damageProjectionBar:SetTexture("Interface\\Buttons\\WHITE8x8")
            damageProjectionBar:SetWidth(TankBarHelperDB.width - 4)
            damageProjectionBar:SetVertexColor(1, 0.3, 0, 0.6)
            damageProjectionBar:SetBlendMode("ADD")
            damageProjectionBar:Hide()
        end
        
        shieldBar:ClearAllPoints()
        shieldBar:SetPoint("RIGHT", frame, "RIGHT", -4, 0)
        shieldBar:SetSize(TankBarHelperDB.width, TankBarHelperDB.height - 4)
        shieldBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
        shieldBar:SetStatusBarColor(unpack(ValidateColor(TankBarHelperDB.shieldColor)))
        shieldBar:SetOrientation("VERTICAL")
        shieldBar:SetReverseFill(false)
        
        if not shieldBar.bg then
            shieldBar.bg = shieldBar:CreateTexture(nil, "BACKGROUND")
            shieldBar.bg:SetAllPoints()
            shieldBar.bg:SetTexture("Interface\\TargetingFrame\\UI-StatusBar")
        end
        shieldBar.bg:SetVertexColor(0.1, 0.1, 0.1, 0.8)
        
        healthPercentText:ClearAllPoints()
        healthPercentText:SetPoint("TOP", healthBar, "BOTTOM", 0, -5)
        healthPercentText:SetFont("Fonts\\FRIZQT__.TTF", TankBarHelperDB.numberSize + 2, "OUTLINE")
        healthPercentText:SetTextColor(0.9, 1, 0.9)
        healthPercentText:SetJustifyH("CENTER")
        healthPercentText:SetDrawLayer("OVERLAY", 7)
        healthPercentText:Show()
        
        shieldPercentText:ClearAllPoints()
        shieldPercentText:SetPoint("TOP", shieldBar, "BOTTOM", 0, -5)
        shieldPercentText:SetFont("Fonts\\FRIZQT__.TTF", TankBarHelperDB.numberSize + 2, "OUTLINE")
        shieldPercentText:SetTextColor(0.7, 0.9, 1)
        shieldPercentText:SetJustifyH("CENTER")
        shieldPercentText:SetDrawLayer("OVERLAY", 7)
        shieldPercentText:Show()
        
        if not skullCircle then
            skullCircle = frame:CreateTexture(nil, "OVERLAY")
            skullCircle:SetSize(50, 50)
            skullCircle:SetPoint("BOTTOM", frame, "TOP", 0, 5)
            skullCircle:SetTexture("Interface\\TARGETINGFRAME\\UI-RaidTargetingIcon_8")
            skullCircle:SetVertexColor(1, 0, 0, 1)
            skullCircle:SetBlendMode("ADD")
            skullCircle:Hide()
        end
        
        if not skullIcon then
            skullIcon = frame:CreateTexture(nil, "OVERLAY")
            skullIcon:SetSize(35, 35)
            skullIcon:SetPoint("CENTER", skullCircle, "CENTER", 0, 0)
            skullIcon:SetTexture("Interface\\TARGETINGFRAME\\UI-RaidTargetingIcon_8")
            skullIcon:SetDrawLayer("OVERLAY", 6)
            skullIcon:Hide()
        end
    end) then
        print("|cffff0000Tank Bar Helper:|r Failed to setup frame")
        return false
    end
    
    return true
end

local function FormatNumber(value)
    value = ValidateNumber(value, 0)
    
    if value >= 1000000 then
        return string.format("%.1fM", value / 1000000)
    elseif value >= 1000 then
        return string.format("%.1fK", value / 1000)
    else
        return tostring(math.floor(value))
    end
end

local function SmoothUpdate(current, target, speed)
    current = ValidateNumber(current, 0)
    target = ValidateNumber(target, 0)
    speed = ValidateNumber(speed, 0.15)
    
    if not TankBarHelperDB.smoothAnimation then
        return target
    end
    
    local diff = target - current
    if math.abs(diff) < 1 then
        return target
    end
    
    return current + (diff * speed)
end


local function UpdateDamageHistory()
    local currentTime = GetTime()
    local cutoffTime = currentTime - damageHistoryTime
    local totalDamage = 0
    local validEntries = {}
    
    for i, entry in ipairs(damageHistory) do
        if entry.time > cutoffTime then
            table.insert(validEntries, entry)
            totalDamage = totalDamage + entry.amount
        end
    end
    
    damageHistory = validEntries
    
    if #damageHistory > 0 then
        local averageDPS = totalDamage / damageHistoryTime
        projectedDamage = averageDPS * projectionTime * safetyBuffer
    else
        projectedDamage = 0
    end
    
    return projectedDamage
end

local function UpdateBars()
    if not isInitialized or not frame or not healthBar or not shieldBar then
        return
    end
    
    SafeCall(function()
        local currentHealth = UnitHealth("player") or 0
        local maxHealth = UnitHealthMax("player") or 1
        local currentShield = UnitGetTotalAbsorbs("player") or 0
        
        currentHealth = ValidateNumber(currentHealth, 0)
        maxHealth = ValidateNumber(maxHealth, 1)
        currentShield = ValidateNumber(currentShield, 0)
        
        if maxHealth <= 0 then maxHealth = 1 end
        
        local healthPercent = (currentHealth / maxHealth) * 100
        
        if currentHealth < lastHealthUpdate and lastHealthUpdate > 0 then
            local damageTaken = lastHealthUpdate - currentHealth
            table.insert(damageHistory, {time = GetTime(), amount = damageTaken})
        end
        
        UpdateDamageHistory()
        
        if projectedDamage > 0 and damageProjectionBar then
            local damageHeight = (projectedDamage / maxHealth) * (TankBarHelperDB.height - 4)
            damageHeight = math.min(damageHeight, TankBarHelperDB.height - 4)
            
            damageProjectionBar:SetHeight(damageHeight)
            damageProjectionBar:ClearAllPoints()
            damageProjectionBar:SetPoint("BOTTOM", healthBar, "BOTTOM", 0, 0)
            damageProjectionBar:Show()
            
            local projectedHealthAfterDamage = math.max(0, currentHealth - projectedDamage)
            local safeHealthPercent = (projectedHealthAfterDamage / maxHealth) * 100
            
            if safeHealthPercent < 20 then
                damageProjectionBar:SetVertexColor(1, 0, 0, 0.7)
            elseif safeHealthPercent < 40 then
                damageProjectionBar:SetVertexColor(1, 0.5, 0, 0.6)
            else
                damageProjectionBar:SetVertexColor(1, 0.8, 0, 0.5)
            end
        elseif damageProjectionBar then
            damageProjectionBar:Hide()
        end
        
        smoothHealthValue = SmoothUpdate(smoothHealthValue, currentHealth, TankBarHelperDB.animationSpeed)
        smoothShieldValue = SmoothUpdate(smoothShieldValue, currentShield, TankBarHelperDB.animationSpeed)
        
        healthBar:SetMinMaxValues(0, maxHealth)
        healthBar:SetValue(smoothHealthValue)
        
        local maxShield = maxHealth * 0.5
        if maxShield <= 0 then maxShield = 1 end
        
        shieldBar:SetMinMaxValues(0, maxShield)
        shieldBar:SetValue(smoothShieldValue)
        
        if TankBarHelperDB.showNumbers and healthPercentText and shieldPercentText then
            local healthStr = FormatNumber(smoothHealthValue)
            local shieldStr = FormatNumber(smoothShieldValue)
            
            local healthPct = math.floor((smoothHealthValue / maxHealth) * 100)
            local shieldPct = math.floor((smoothShieldValue / maxShield) * 100)
            
            healthPct = math.max(0, math.min(100, healthPct))
            shieldPct = math.max(0, math.min(100, shieldPct))
            
            local newHealthText = healthStr .. "\n" .. healthPct .. "%"
            local newShieldText = shieldStr .. "\n" .. shieldPct .. "%"
            
            healthPercentText:SetText(newHealthText)
            
            if currentShield > 0 then
                shieldPercentText:SetText(newShieldText)
                shieldPercentText:SetAlpha(1)
            else
                shieldPercentText:SetText("0\n0%")
                shieldPercentText:SetAlpha(0.3)
            end
        end
        
        if healthPercent <= TankBarHelperDB.lowHealthThreshold and skullIcon and skullCircle then
            skullIcon:Show()
            skullCircle:Show()
            
            if not frame.skullAnimation then
                frame.skullAnimation = frame:CreateAnimationGroup()
                
                local pulse = frame.skullAnimation:CreateAnimation("Scale")
                pulse:SetScale(1.2, 1.2)
                pulse:SetDuration(0.5)
                pulse:SetOrder(1)
                
                local shrink = frame.skullAnimation:CreateAnimation("Scale")
                shrink:SetScale(0.833, 0.833)
                shrink:SetDuration(0.5)
                shrink:SetOrder(2)
                
                frame.skullAnimation:SetLooping("REPEAT")
                frame.skullAnimation:SetTarget(skullIcon)
            end
            
            if not frame.circleAnimation then
                frame.circleAnimation = frame:CreateAnimationGroup()
                
                local fadeIn = frame.circleAnimation:CreateAnimation("Alpha")
                fadeIn:SetFromAlpha(0.2)
                fadeIn:SetToAlpha(1)
                fadeIn:SetDuration(0.4)
                fadeIn:SetOrder(1)
                
                local fadeOut = frame.circleAnimation:CreateAnimation("Alpha")
                fadeOut:SetFromAlpha(1)
                fadeOut:SetToAlpha(0.2)
                fadeOut:SetDuration(0.4)
                fadeOut:SetOrder(2)
                
                frame.circleAnimation:SetLooping("REPEAT")
                frame.circleAnimation:SetTarget(skullCircle)
            end
            
            if not frame.skullAnimation:IsPlaying() then
                frame.skullAnimation:Play()
            end
            if not frame.circleAnimation:IsPlaying() then
                frame.circleAnimation:Play()
            end
        else
            if skullIcon then skullIcon:Hide() end
            if skullCircle then skullCircle:Hide() end
            
            if frame.skullAnimation and frame.skullAnimation:IsPlaying() then
                frame.skullAnimation:Stop()
            end
            if frame.circleAnimation and frame.circleAnimation:IsPlaying() then
                frame.circleAnimation:Stop()
            end
        end
        
        
        lastHealthUpdate = currentHealth
        lastShieldUpdate = currentShield
    end)
end

local function OnUpdate(self, elapsed)
    if not isInitialized then return end
    
    elapsed = ValidateNumber(elapsed, 0)
    
    UpdateBars()
end

local function OnEvent(self, event, unit)
    if not isInitialized then return end
    
    if event == "PLAYER_LOGIN" or event == "PLAYER_ENTERING_WORLD" then
        SafeCall(UpdateBars)
    elseif unit == "player" then
        SafeCall(UpdateBars)
    end
end

function TBH:Initialize()
    if isInitialized then return end
    
    SafeCall(function()
        InitializeDB()
        
        if not SetupFrame() then
            print("|cffff0000Tank Bar Helper:|r Failed to initialize addon")
            return
        end
        
        smoothHealthValue = UnitHealth("player") or 0
        smoothShieldValue = UnitGetTotalAbsorbs("player") or 0
        
        if frame then
            frame:RegisterEvent("UNIT_HEALTH")
            frame:RegisterEvent("UNIT_MAXHEALTH")
            frame:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED")
            frame:RegisterEvent("PLAYER_ENTERING_WORLD")
            frame:RegisterEvent("PLAYER_LOGIN")
            
            frame:SetScript("OnEvent", OnEvent)
            frame:SetScript("OnUpdate", OnUpdate)
            
            frame:Show()
            
            isInitialized = true
            
            UpdateBars()
            
            print("|cff00ccffTank Bar Helper|r loaded successfully!")
        end
    end)
end

function TBH:Lock()
    if not frame then return end
    
    SafeCall(function()
        TankBarHelperDB.locked = true
        frame:SetMovable(false)
        frame:EnableMouse(false)
    end)
end

function TBH:Unlock()
    if not frame then return end
    
    SafeCall(function()
        TankBarHelperDB.locked = false
        frame:SetMovable(true)
        frame:EnableMouse(true)
    end)
end

function TBH:UpdateSettings()
    if not isInitialized then return end
    
    SafeCall(function()
        SetupFrame()
        UpdateBars()
    end)
end

local loader = CreateFrame("Frame")
loader:RegisterEvent("ADDON_LOADED")
loader:SetScript("OnEvent", function(self, event, name)
    if name == addonName then
        SafeCall(function()
            TBH:Initialize()
        end)
        self:UnregisterEvent("ADDON_LOADED")
    end
end)