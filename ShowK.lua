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

local function ToggleKDisplay()
    if isKShown then
        isKShown = false
        if not isChanneling then
            HideK()
        end
    else
        isKShown = true
        ShowK()
    end
end

frame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
frame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")

frame:SetScript("OnEvent", function(self, event, arg1, arg2)
    if event == "UNIT_SPELLCAST_CHANNEL_START" and arg1 == "player" then
        isChanneling = true
        ShowK()
    elseif event == "UNIT_SPELLCAST_CHANNEL_STOP" and arg1 == "player" then
        isChanneling = false
        if not isKShown then
            HideK()
        end
    end
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
