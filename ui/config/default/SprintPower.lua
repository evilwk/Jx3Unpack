local SRPINT_POWER_MAX_SIZE = 57
local SRPINT_POWER_POS_X = 9
local SRPINT_POWER_POS_Y = 7

local tSprintPowerFrame = {55, 56, 57} --white, green, yellow
SprintPower = {} 

SprintPower.DefaultAnchor = {s = "TOPLEFT", r = "TOPLEFT", x = 350, y = 30}
SprintPower.Anchor = {s = "TOPLEFT", r = "TOPLEFT", x = 350, y = 30}

RegisterCustomData("SprintPower.Anchor")

function SprintPower.OnFrameCreate()
	this:RegisterEvent("ON_ENTER_CUSTOM_UI_MODE")
	this:RegisterEvent("ON_LEAVE_CUSTOM_UI_MODE")
	this:RegisterEvent("UI_SCALED")
    this:RegisterEvent("SPRINT_POWER_ANCHOR_CHANGED")
	
	SprintPower.UpdateAnchor(this)
	UpdateCustomModeWindow(this, g_tStrings.SPRINT_POWER)
end

function SprintPower.OnFrameBreathe()
    SprintPower.Update(this)
end

function SprintPower.OnFrameDrag()
end

function SprintPower.OnFrameDragSetPosEnd()
end

function SprintPower.OnFrameDragEnd()
	this:CorrectPos()
	SprintPower.Anchor = GetFrameAnchor(this)
end

function SprintPower.UpdateAnchor(hFrame)
	hFrame:SetPoint(SprintPower.Anchor.s, 0, 0, SprintPower.Anchor.r, SprintPower.Anchor.x, SprintPower.Anchor.y)
	hFrame:CorrectPos()
end

function SprintPower.OnEvent(szEvent)
	if szEvent == "UI_SCALED" then
		SprintPower.UpdateAnchor(this)
	elseif szEvent == "SPRINT_POWER_ANCHOR_CHANGED" then
		SprintPower.UpdateAnchor(this)
	elseif szEvent == "ON_ENTER_CUSTOM_UI_MODE" or szEvent == "ON_LEAVE_CUSTOM_UI_MODE" then
		UpdateCustomModeWindow(this)
	end
end

function SprintPower.Update(hFrame)
    local hPlayer = GetClientPlayer()
	if not hPlayer then
		return
	end
    
    local nSprintPower = hPlayer.nSprintPower
    if nSprintPower < 0 then
        nSprintPower = 0
    end
    local hHandle = hFrame:Lookup("", "")
    local hSprintPower = hHandle:Lookup("Image_SprintPower")
    local hTextSprintPower = hHandle:Lookup("Text_SprintPower")
    local fPercent = nSprintPower / hPlayer.nSprintPowerMax
    local nShowSprintPower = math.floor(nSprintPower / 100)
    local nShowSprintPowerMax = math.floor(hPlayer.nSprintPowerMax / 100)
    hTextSprintPower:SetText(nShowSprintPower .. "/" .. nShowSprintPowerMax)
    local nIndex = 3
    if fPercent >= 0.6 then
        nIndex = 1
    elseif fPercent >= 0.3 then
        nIndex = 2
    end
    local hAnimateUse = hHandle:Lookup("Animate_SprintPower")
    local hAnimateNoUse = hHandle:Lookup("Animate_SprintPower1")
    if not hFrame.bUseSprintPower then
        if hFrame.fPercent and fPercent < hFrame.fPercent then
            hFrame.bUseSprintPower = true
            hAnimateUse:Show()
            hAnimateNoUse:Hide()
        end
    else
        if hFrame.fPercent and fPercent > hFrame.fPercent then
            hFrame.bUseSprintPower = false
            hAnimateUse:Hide()
            hAnimateNoUse:Show()
        end
    end
    hFrame.fPercent = fPercent
    if hFrame.bUseSprintPower then
         if hPlayer.bFightState then
            hAnimateUse:SetGroup(1)
         else
            hAnimateUse:SetGroup(0)
         end
    end
    
    hSprintPower:SetFrame(tSprintPowerFrame[nIndex])
    local fSize = SRPINT_POWER_MAX_SIZE * fPercent
    local fX = SRPINT_POWER_POS_X + SRPINT_POWER_MAX_SIZE * (1 - fPercent) / 2
    local fY = SRPINT_POWER_POS_Y + SRPINT_POWER_MAX_SIZE * (1 - fPercent) / 2
    hSprintPower:SetSize(fSize, fSize)
    hSprintPower:SetRelPos(fX, fY)
    hHandle:FormatAllItemPos()
end

function SprintPower_SetAnchorDefault()
	SprintPower.Anchor.s = SprintPower.DefaultAnchor.s
	SprintPower.Anchor.r = SprintPower.DefaultAnchor.r
	SprintPower.Anchor.x = SprintPower.DefaultAnchor.x
	SprintPower.Anchor.y = SprintPower.DefaultAnchor.y
	FireEvent("SPRINT_POWER_ANCHOR_CHANGED")
end

RegisterEvent("CUSTOM_UI_MODE_SET_DEFAULT", SprintPower_SetAnchorDefault)