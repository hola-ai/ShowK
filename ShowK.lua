local frame = CreateFrame("Frame", "ShowKFrame", UIParent)
frame:SetSize(6, 6)  -- 6x6 픽셀
frame:SetPoint("CENTER", UIParent, "CENTER", -1414, -90)  -- 설정된 픽셀 위치에 배치

-- 2x2 픽셀 서브프레임 9개 생성 (3x3 배치, 합쳐서 6x6)
-- 체커보드 패턴 (2x2 단위):
--   검검 하하 검검
--   검검 하하 검검
--   하하 검검 하하
--   하하 검검 하하
--   검검 하하 검검
--   검검 하하 검검
local pixels = {}
for row = 0, 2 do
    for col = 0, 2 do
        local px = CreateFrame("Frame", nil, frame)
        px:SetSize(2, 2)
        px:SetPoint("TOPLEFT", frame, "TOPLEFT", col * 2, -(row * 2))
        px.tex = px:CreateTexture(nil, "BACKGROUND")
        px.tex:SetAllPoints(px)
        px.isBlack = ((row + col) % 2 == 0)
        pixels[row * 3 + col + 1] = px
    end
end

local isKShown = false
local isChanneling = false
local isCasting = false

-- Always-visible GCD bar (independent from ShowK state)
local gcdBar = CreateFrame("StatusBar", "ShowKGCDBar", UIParent)
gcdBar:SetSize(160, 6)
gcdBar:SetPoint("CENTER", UIParent, "CENTER", 0, -236)
local gcdBarTexture = gcdBar:CreateTexture(nil, "ARTWORK")
gcdBarTexture:SetColorTexture(1, 1, 1, 1)
gcdBar:SetStatusBarTexture(gcdBarTexture)
gcdBar:SetMinMaxValues(0, 1)
gcdBar:SetValue(0)
if gcdBar.SetReverseFill then
    gcdBar:SetReverseFill(true)
end

local gcdBarBg = gcdBar:CreateTexture(nil, "BACKGROUND")
gcdBarBg:SetAllPoints(gcdBar)
gcdBarBg:SetColorTexture(0, 0, 0, 1)

local gcdStartTime = 0
local gcdDuration = 0

local function GetGlobalCooldownInfo()
    if C_Spell and C_Spell.GetSpellCooldown then
        local info = C_Spell.GetSpellCooldown(61304)
        if info then
            return info.startTime or 0, info.duration or 0
        end
    end

    -- Fallback for clients/APIs where the legacy function is still used.
    local startTime, duration = GetSpellCooldown(61304)
    return startTime or 0, duration or 0
end

local function RefreshGlobalCooldown()
    local startTime, duration = GetGlobalCooldownInfo()

    if startTime and duration and duration > 0 then
        gcdStartTime = startTime
        gcdDuration = duration
    else
        gcdStartTime = 0
        gcdDuration = 0
        gcdBar:SetValue(0)
    end
end

local function UpdateGlobalCooldownBar()
    if gcdDuration <= 0 then
        gcdBar:SetValue(0)
        return
    end

    local remaining = (gcdStartTime + gcdDuration) - GetTime()
    if remaining <= 0 then
        gcdStartTime = 0
        gcdDuration = 0
        gcdBar:SetValue(0)
        return
    end

    gcdBar:SetValue(remaining / gcdDuration)
end

local function ShowCheckerboard()
    for _, px in ipairs(pixels) do
        if px.isBlack then
            px.tex:SetColorTexture(0, 0, 0, 1)  -- 검정
        else
            px.tex:SetColorTexture(1, 1, 1, 1)  -- 하양
        end
    end
end

local function ShowTransparent()
    for _, px in ipairs(pixels) do
        px.tex:SetColorTexture(0, 0, 0, 0)  -- 투명
    end
end

-- 초기 상태: 투명 (isKShown = false)
ShowTransparent()

local function ShowK()
    ShowCheckerboard()
end

local function HideK()
    ShowTransparent()
end

local function UpdateDisplay()
    if isKShown and not isCasting and not isChanneling then
        ShowK()
    else
        HideK()
    end
end

local function ToggleKDisplay()
    isKShown = not isKShown
    UpdateDisplay()
end

frame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
frame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
frame:RegisterEvent("UNIT_SPELLCAST_START")
frame:RegisterEvent("UNIT_SPELLCAST_STOP")
frame:RegisterEvent("UNIT_SPELLCAST_FAILED")
frame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
frame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
frame:RegisterEvent("SPELL_UPDATE_COOLDOWN")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")

frame:SetScript("OnEvent", function(self, event, arg1)
    -- print("[ShowK] event=" .. event .. " arg1=" .. tostring(arg1))
    local isUnitEvent = string.sub(event, 1, 5) == "UNIT_"
    if isUnitEvent and arg1 ~= "player" then return end

    if event == "UNIT_SPELLCAST_CHANNEL_START" then
        isChanneling = true
    elseif event == "UNIT_SPELLCAST_CHANNEL_STOP" then
        isChanneling = false
    elseif event == "UNIT_SPELLCAST_START" then
        isCasting = true
    elseif event == "UNIT_SPELLCAST_STOP"
        or event == "UNIT_SPELLCAST_FAILED"
        or event == "UNIT_SPELLCAST_INTERRUPTED" then
        isCasting = false
    elseif event == "UNIT_SPELLCAST_SUCCEEDED"
        or event == "SPELL_UPDATE_COOLDOWN"
        or event == "PLAYER_ENTERING_WORLD" then
        RefreshGlobalCooldown()
    end

    UpdateDisplay()
end)

frame:SetScript("OnUpdate", function()
    UpdateGlobalCooldownBar()
end)

local inputFrame = CreateFrame("Frame")
inputFrame:RegisterEvent("PLAYER_LOGIN")
inputFrame:SetScript("OnEvent", function()
    local function OnMouseDown(self, button)
        if button == "MiddleButton" then
            ToggleKDisplay()
        end
    end

    WorldFrame:HookScript("OnMouseDown", OnMouseDown)
end)

