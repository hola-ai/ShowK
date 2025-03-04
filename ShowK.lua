local frame = CreateFrame("Frame", "ShowKFrame", UIParent)
frame:SetSize(55, 40)  -- 표시할 영역의 크기 설정
frame:SetPoint("CENTER", UIParent, "CENTER", -55, -223)  -- 화면 중앙에서 오른쪽으로 200, 위로 100 픽셀 위치에 배치

-- 배경 텍스처 추가 및 설정
frame.bg = frame:CreateTexture(nil, "BACKGROUND")
frame.bg:SetAllPoints(frame)
frame.bg:SetColorTexture(0, 0, 0, 1)  -- 초기 상태는 불투명 (검은색 배경)

local text = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
text:SetFont("Fonts\\FRIZQT__.TTF", 30, "OUTLINE")  -- 폰트 설정 (폰트 파일 경로, 크기, 스타일)
text:SetText("K")
text:SetAllPoints(frame)
text:Show()  -- 초기 상태는 보이는 상태

local isKShown = true
local isChanneling = false

local function ShowK()
    text:Show()
    frame.bg:SetColorTexture(0, 0, 0, 1)
end

local function HideK()
    text:Hide()
    frame.bg:SetColorTexture(0, 0, 0, 0)
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

frame:RegisterEvent("MODIFIER_STATE_CHANGED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
frame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")

local isAltPressed = false

frame:SetScript("OnEvent", function(self, event, arg1, arg2)
    if event == "MODIFIER_STATE_CHANGED" then
        if arg1 == "LALT" or arg1 == "RALT" then
            isAltPressed = (arg2 == 1)
        end
    elseif event == "PLAYER_LOGIN" then
        -- 키 바인딩 설정
        SetBindingClick("ALT-K", frame:GetName(), "LeftButton")
    elseif event == "UNIT_SPELLCAST_CHANNEL_START" and arg1 == "player" then
        isChanneling = true
        ShowK()
    elseif event == "UNIT_SPELLCAST_CHANNEL_STOP" and arg1 == "player" then
        isChanneling = false
        if not isKShown then
            HideK()
        end
    end
end)

frame:SetScript("OnKeyDown", function(self, key)
    if isAltPressed and key == "K" then
        ToggleKDisplay()
    end
end)

frame:EnableKeyboard(true)
frame:SetPropagateKeyboardInput(true)
