local frame = CreateFrame("Frame", "ShowKFrame", UIParent)
frame:SetSize(6, 6)  -- 표시할 영역의 크기 설정
frame:SetPoint("CENTER", UIParent, "CENTER", -1403, -237)  -- 설정된 픽셀 위치에 배치

-- 배경 텍스처 추가 및 설정
frame.bg = frame:CreateTexture(nil, "BACKGROUND")
frame.bg:SetAllPoints(frame)
frame.bg:SetColorTexture(1, 1, 1, 1)  -- 초기 상태는 불투명 (하얀색 배경)

local isKShown = true
local isChanneling = false

local function ShowK()
    frame.bg:SetColorTexture(1, 1, 1, 1)
end

local function HideK()
    frame.bg:SetColorTexture(1, 1, 1, 0)
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
