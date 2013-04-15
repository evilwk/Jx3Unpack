PQTimePanel = 
{
	--DefaultAnchor = {s = "TOPCENTER", r = "TOPCENTER",  x = 0, y = 90},
	Anchor = {s = "TOPLEFT", r = "BOTTOMLEFT", x = -100, y = 80}
}

local OBJECT = PQTimePanel
local WIDGET = {}
--======================================
function OpenPQTimePanel(bDisableSound)
	local frame = Wnd.OpenWindow("PQTimePanel")
    if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end 
end

function ClosePQTimePanel(bDisableSound)
    if IsPQTimePanelOpened() then
		Wnd.CloseWindow("PQTimePanel")
	end
    
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end
end

local function UpdateAddTimeState()
    local nAlpha = WIDGET.hTimeAdd:GetAlpha() - 6
    nAlpha = math.max(nAlpha, 0)
    WIDGET.hTimeAdd:SetAlpha(nAlpha)
    if nAlpha == 0 then
        WIDGET.hFrame.nDeltaTime = nil
        WIDGET.hTimeAdd:SetText("")
    end
end

local function SetCountDownText(nTime)
    local szText = GetTimeText(nTime, nil, true)
    WIDGET.hTime:SetText(szText)
    if nTime > 15 * 60 then
        WIDGET.hTime:SetFontScheme(165)
    elseif nTime > 5 * 60 then
        WIDGET.hTime:SetFontScheme(27)
    else
        WIDGET.hTime:SetFontScheme(166)
    end
    
    if nTime == 0 then
        WIDGET.hTime:SetText("0"..g_tStrings.STR_BUFF_H_TIME_S)
    end
end

local function DoTimeCountDown()
    if WIDGET.hFrame.nEndTime then
        local dwTime = math.ceil(GetLogicFrameCount() / GLOBAL.GAME_FPS);
        local nLeftTime = math.max((WIDGET.hFrame.nEndTime - dwTime), 0)
        SetCountDownText(nLeftTime)
        if nLeftTime == 0 then
            WIDGET.hFrame.nEndTime = nil
        end
    end
end

--======================================

function PQTimePanel.OnFrameCreate()
    this:RegisterEvent("UI_SCALED")
    this:RegisterEvent("PQTIME_TIME_CHANGED")
    this:RegisterEvent("PQTIME_PROGRESS_UPDATE")
    this:RegisterEvent("PQQUEST_STATE_UPDATE")
    this:RegisterEvent("PQQUEST_END_TIME_UPDATE")
    this:RegisterEvent("PQQUEST_LEFT_TIME_UPDATE")
    
    OBJECT.InitObject(this)
    OBJECT.Init()
    PQTimePanel.UpdateAnchor(this)
end

function PQTimePanel.OnFrameBreathe()
    if this.nDeltaTime then
        UpdateAddTimeState()
    end
    
    if not this.nFrame then 
        this.nFrame = 0
    end    
    
    if this.nFrame == 4 and this.nState == 1 then
        DoTimeCountDown()
    end
   
    if this.nFrame == 4 then
        this.nFrame = 0
    end
     this.nFrame = this.nFrame + 1
end

function PQTimePanel.InitObject(hFrame)
    WIDGET.hFrame = hFrame
    local hHandle = hFrame:Lookup("", "Handle_Top");
    WIDGET.hTime = hHandle:Lookup("Text_Time")
    WIDGET.hTimeAdd = hHandle:Lookup("Text_Other")
    
    hHandle = hFrame:Lookup("", "Handle_QuestProgress");
    WIDGET.hProgress = hHandle:Lookup("Text_ProgressMsg")
end

function PQTimePanel.Init()
    PQTimePanel.nTipState = 0
    WIDGET.hFrame.nState = 0
    WIDGET.hFrame.nEndTime = nil
    WIDGET.hFrame.nDeltaTime = nil
    WIDGET.hTime:SetText(g_tStrings.STR_PQQUEST_UNSTART)
    WIDGET.hTime:SetFontScheme(27)
    WIDGET.hTimeAdd:SetText("") 
    WIDGET.hTimeAdd:SetFontScheme(27)
    WIDGET.hProgress:SetText("--/--")
    WIDGET.hProgress:SetFontScheme(32)
end

function PQTimePanel.OnEvent(szEvent)
    if szEvent == "UI_SCALED" then
        PQTimePanel.UpdateAnchor(this)
    elseif szEvent == "PQTIME_PANEL_VISIBLE" then
        local bVisible = arg0
        if bVisible == true then
            OpenPQTimePanel()
        else
            ClosePQTimePanel()
        end
    elseif szEvent == "PQTIME_TIME_CHANGED" then
        local nDeltaTime = arg0
        WIDGET.hFrame.nDeltaTime = nDeltaTime
        local szText = GetTimeText(nDeltaTime)
        WIDGET.hTimeAdd:SetText("+"..szText)
        WIDGET.hTimeAdd:SetAlpha(255)
        
    elseif szEvent == "PQTIME_PROGRESS_UPDATE" then
        local nCurrent, nTotal = arg0, arg1
        WIDGET.hProgress:SetText(nCurrent.."/"..nTotal)
        
    elseif szEvent == "PQQUEST_STATE_UPDATE" then
        local nState = arg0
        WIDGET.hFrame.nState = nState 
        if nState == 0 then --未开启
            PQTimePanel.Init()
        elseif nState == 1 then --开启
            WIDGET.hTime:SetText("")
            WIDGET.hTimeAdd:SetText("")
        elseif nState == 2 then--成功
            PQTimePanel.nTipState = 1
            WIDGET.hFrame.nDeltaTime = nil
            local szText = WIDGET.hTime:GetText()
            if szText == g_tStrings.STR_PQQUEST_UNSTART then
                SetCountDownText(0)
            end
            WIDGET.hTimeAdd:SetText(g_tStrings.STR_PQQUEST_SUCCESS)
            WIDGET.hTimeAdd:SetAlpha(255)
            
        elseif nState == 3 then--失败
            PQTimePanel.nTipState = 2
            WIDGET.hFrame.nDeltaTime = nil
            WIDGET.hTimeAdd:SetText(g_tStrings.STR_PQQUEST_FAIL)
            WIDGET.hTimeAdd:SetAlpha(255)
            
            SetCountDownText(0)
        end
    elseif szEvent == "PQQUEST_END_TIME_UPDATE" then
        local nEndTime = arg0
        WIDGET.hFrame.nEndTime = tonumber(nEndTime)
    
    elseif szEvent == "PQQUEST_LEFT_TIME_UPDATE" then
        local nLeftTime = tonumber(arg0)
        SetCountDownText(nLeftTime)
    end
end

function PQTimePanel.OnFrameDragEnd()
	this:CorrectPos()
	PQTimePanel.Anchor = GetFrameAnchor(this)
end

function PQTimePanel.UpdateAnchor(frame)
	frame:SetPoint(PQTimePanel.Anchor.s, 0, 0, "Topmost/Minimap", PQTimePanel.Anchor.r, PQTimePanel.Anchor.x, PQTimePanel.Anchor.y)
	frame:CorrectPos()
end

function PQTimePanel.OnItemMouseEnter()
	local szName = this:GetName()
    if szName == "Handle_Top" then
        local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
        local szText = ""
        if PQTimePanel.nTipState == 0 then
            szText = GetFormatText(g_tStrings.STR_PQQUEST_TIP1)
        elseif PQTimePanel.nTipState == 1 then
            szText = GetFormatText(g_tStrings.STR_PQQUEST_TIP2)
        elseif PQTimePanel.nTipState == 2 then
            szText = GetFormatText(g_tStrings.STR_PQQUEST_TIP3)
        end
        OutputTip(szText, 400, {x, y, w, h})
    end
end

function PQTimePanel.OnItemMouseLeave()
	local szName = this:GetName()
    if szName == "Handle_Top" then
        HideTip()
    end
end

function IsPQTimePanelOpened(bDisableSound)
    local frame = Station.Lookup("Normal/PQTimePanel")
    if frame and frame:IsVisible() then
        return true
    end
end

RegisterEvent("PQTIME_PANEL_VISIBLE", function(szEvent) PQTimePanel.OnEvent(szEvent) end)