local addonName, addon = ...
local TBH = TankBars

local bossAbilityFrame = nil
local bossAbilityBar = nil
local bossAbilityText = nil
local bossAbilityNameText = nil
local bossAbilityTimeText = nil
local currentBossAbility = nil
local abilityDamageLookup = {}

local TANK_BUSTER_ABILITIES = {
    [398764] = {name = "Colossal Slam", damage = 500000, category = "physical"},
    [396044] = {name = "Greatstaff's Wrath", damage = 450000, category = "magic"},
    [372315] = {name = "Shattering Star", damage = 600000, category = "physical"},
    [375056] = {name = "Chilling Tantrum", damage = 400000, category = "frost"},
    [388691] = {name = "Stonevault", damage = 550000, category = "physical"},
    [372719] = {name = "Titanic Slam", damage = 700000, category = "physical"},
    [376279] = {name = "Concussive Slam", damage = 480000, category = "physical"},
    [384273] = {name = "Colossal Rampage", damage = 650000, category = "physical"},
    [386173] = {name = "Mana Bomb", damage = 420000, category = "arcane"},
    [388523] = {name = "Crushing Stomp", damage = 520000, category = "physical"},
}

local function CreateBossAbilityFrame()
    if bossAbilityFrame then return end
    
    local frame = TankBarsFrame
    if not frame then return end
    
    bossAbilityFrame = CreateFrame("Frame", "TankBarsBossAbilityFrame", frame, "BackdropTemplate")
    bossAbilityFrame:SetSize(200, 60)
    bossAbilityFrame:SetPoint("TOP", frame, "BOTTOM", 0, -60)
    
    if bossAbilityFrame.SetBackdrop then
        bossAbilityFrame:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = false,
            tileSize = 0,
            edgeSize = 10,
            insets = { left = 2, right = 2, top = 2, bottom = 2 }
        })
        bossAbilityFrame:SetBackdropColor(0.1, 0, 0, 0.8)
        bossAbilityFrame:SetBackdropBorderColor(0.8, 0.2, 0.2, 1)
    end
    
    bossAbilityBar = CreateFrame("StatusBar", nil, bossAbilityFrame)
    bossAbilityBar:SetPoint("TOPLEFT", bossAbilityFrame, "TOPLEFT", 5, -25)
    bossAbilityBar:SetPoint("TOPRIGHT", bossAbilityFrame, "TOPRIGHT", -5, -25)
    bossAbilityBar:SetHeight(20)
    bossAbilityBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    bossAbilityBar:SetStatusBarColor(1, 0.3, 0.3, 1)
    bossAbilityBar:SetMinMaxValues(0, 1)
    bossAbilityBar:SetValue(0)
    
    local barBg = bossAbilityBar:CreateTexture(nil, "BACKGROUND")
    barBg:SetAllPoints()
    barBg:SetTexture("Interface\\TargetingFrame\\UI-StatusBar")
    barBg:SetVertexColor(0.2, 0.1, 0.1, 0.8)
    
    bossAbilityNameText = bossAbilityFrame:CreateFontString(nil, "OVERLAY")
    bossAbilityNameText:SetPoint("TOPLEFT", bossAbilityFrame, "TOPLEFT", 5, -5)
    bossAbilityNameText:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
    bossAbilityNameText:SetTextColor(1, 0.8, 0.8)
    bossAbilityNameText:SetText("No Incoming Ability")
    
    bossAbilityText = bossAbilityFrame:CreateFontString(nil, "OVERLAY")
    bossAbilityText:SetPoint("TOPRIGHT", bossAbilityFrame, "TOPRIGHT", -5, -5)
    bossAbilityText:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
    bossAbilityText:SetTextColor(1, 0.5, 0.5)
    bossAbilityText:SetText("0")
    
    bossAbilityTimeText = bossAbilityBar:CreateFontString(nil, "OVERLAY")
    bossAbilityTimeText:SetPoint("CENTER", bossAbilityBar, "CENTER", 0, 0)
    bossAbilityTimeText:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    bossAbilityTimeText:SetTextColor(1, 1, 1)
    bossAbilityTimeText:SetText("")
    
    local warningIcon = bossAbilityFrame:CreateTexture(nil, "OVERLAY")
    warningIcon:SetSize(16, 16)
    warningIcon:SetPoint("LEFT", bossAbilityNameText, "RIGHT", 5, 0)
    warningIcon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_8")
    warningIcon:SetVertexColor(1, 0.5, 0, 1)
    
    bossAbilityFrame:Hide()
end

local function FormatAbilityDamage(damage)
    if damage >= 1000000 then
        return string.format("%.1fM", damage / 1000000)
    elseif damage >= 1000 then
        return string.format("%.0fK", damage / 1000)
    else
        return tostring(damage)
    end
end

local function UpdateBossAbilityBar(abilityName, timeRemaining, maxTime, expectedDamage)
    if not bossAbilityFrame then
        CreateBossAbilityFrame()
    end
    
    if not bossAbilityFrame or not TankBarsDB.showBossAbilities then
        return
    end
    
    if timeRemaining and timeRemaining > 0 then
        bossAbilityFrame:Show()
        
        bossAbilityNameText:SetText(abilityName or "Unknown Ability")
        bossAbilityText:SetText(FormatAbilityDamage(expectedDamage or 0))
        bossAbilityTimeText:SetText(string.format("%.1fs", timeRemaining))
        
        local percent = timeRemaining / maxTime
        bossAbilityBar:SetValue(1 - percent)
        
        if timeRemaining < 2 then
            bossAbilityBar:SetStatusBarColor(1, 0, 0, 1)
            local pulse = math.sin(GetTime() * 10) * 0.3 + 0.7
            bossAbilityFrame:SetAlpha(pulse)
        elseif timeRemaining < 5 then
            bossAbilityBar:SetStatusBarColor(1, 0.5, 0, 1)
            bossAbilityFrame:SetAlpha(1)
        else
            bossAbilityBar:SetStatusBarColor(1, 0.8, 0, 1)
            bossAbilityFrame:SetAlpha(1)
        end
        
        local playerHealth = UnitHealth("player") or 0
        if expectedDamage and expectedDamage > playerHealth * 0.8 then
            bossAbilityFrame:SetBackdropBorderColor(1, 0, 0, 1)
        elseif expectedDamage and expectedDamage > playerHealth * 0.5 then
            bossAbilityFrame:SetBackdropBorderColor(1, 0.5, 0, 1)
        else
            bossAbilityFrame:SetBackdropBorderColor(0.8, 0.2, 0.2, 1)
        end
    else
        bossAbilityFrame:Hide()
    end
end

local activeTimers = {}

local function OnDBMTimer(mod, id, msg, timer, icon, colorType, spellId, ...)
    if not spellId then return end
    
    local abilityInfo = TANK_BUSTER_ABILITIES[spellId]
    if not abilityInfo then return end
    
    activeTimers[id] = {
        name = abilityInfo.name,
        damage = abilityInfo.damage,
        startTime = GetTime(),
        duration = timer,
        spellId = spellId
    }
end

local function OnBigWigsBar(bar)
    if not bar or not bar.label then return end
    
    local text = bar.label:GetText()
    if not text then return end
    
    for spellId, abilityInfo in pairs(TANK_BUSTER_ABILITIES) do
        if text:find(abilityInfo.name) then
            activeTimers[text] = {
                name = abilityInfo.name,
                damage = abilityInfo.damage,
                startTime = GetTime(),
                duration = bar.remaining or 0,
                spellId = spellId
            }
            break
        end
    end
end

local function UpdateActiveTimers()
    if not TankBarsDB or not TankBarsDB.showBossAbilities then
        if bossAbilityFrame then
            bossAbilityFrame:Hide()
        end
        return
    end
    
    local currentTime = GetTime()
    local nextAbility = nil
    local shortestTime = math.huge
    
    for id, timer in pairs(activeTimers) do
        local elapsed = currentTime - timer.startTime
        local remaining = timer.duration - elapsed
        
        if remaining > 0 and remaining < shortestTime then
            shortestTime = remaining
            nextAbility = timer
        elseif remaining <= 0 then
            activeTimers[id] = nil
        end
    end
    
    if nextAbility then
        UpdateBossAbilityBar(nextAbility.name, shortestTime, nextAbility.duration, nextAbility.damage)
    else
        if bossAbilityFrame then
            bossAbilityFrame:Hide()
        end
    end
end

function TBH:InitializeBossAbilityPrediction()
    CreateBossAbilityFrame()
    
    if _G.DBM then
        if _G.DBM.RegisterCallback then
            _G.DBM:RegisterCallback("DBM_TimerStart", OnDBMTimer)
        end
    end
    
    if _G.BigWigsLoader then
        local eventFrame = CreateFrame("Frame")
        eventFrame:RegisterEvent("CHAT_MSG_ADDON")
        eventFrame:SetScript("OnEvent", function(self, event, prefix, msg, channel, sender)
            if prefix == "BigWigs" and msg:find("StartBar") then
                C_Timer.After(0.1, function()
                    if _G.BigWigsAnchor and _G.BigWigsAnchor.bars then
                        for _, bar in pairs(_G.BigWigsAnchor.bars) do
                            OnBigWigsBar(bar)
                        end
                    end
                end)
            end
        end)
        
        C_ChatInfo.RegisterAddonMessagePrefix("BigWigs")
    end
    
    local updateFrame = CreateFrame("Frame")
    updateFrame:SetScript("OnUpdate", function(self, elapsed)
        self.elapsed = (self.elapsed or 0) + elapsed
        if self.elapsed > 0.1 then
            self.elapsed = 0
            UpdateActiveTimers()
        end
    end)
end

function TBH:AddCustomBossAbility(spellId, name, damage, category)
    TANK_BUSTER_ABILITIES[spellId] = {
        name = name,
        damage = damage,
        category = category or "physical"
    }
end

function TBH:ClearBossAbilityTimers()
    activeTimers = {}
    if bossAbilityFrame then
        bossAbilityFrame:Hide()
    end
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ENCOUNTER_START")
eventFrame:RegisterEvent("ENCOUNTER_END")
eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "ENCOUNTER_START" then
        activeTimers = {}
    elseif event == "ENCOUNTER_END" then
        TBH:ClearBossAbilityTimers()
    end
end)