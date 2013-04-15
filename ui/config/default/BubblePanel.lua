
local tAdvanceActive = {}
local bFistCall = false

local BUBBLE_PANEL_MAX_COUNT = 3
local BUBBLE_PANEL_DEFAULT_OFFSET_X = -240
local BUBBLE_PANEL_DEFAULT_OFFSET_Y = -10
local BUBBLE_PANEL_HOLD_TIME = 1000 * 10
local tBubbleMap = {}
BubblePanel = {}

BubblePanel_Base = class()

function BubblePanel_Base.OnFrameCreate()
    this:RegisterEvent("UI_SCALED")
    
end

function BubblePanel_Base.OnEvent(szEvent)
    if szEvent == "UI_SCALED" then
		BubblePanel.UpdateAnchor(tihis)
	end
end

function BubblePanel_Base.OnLButtonClick()
    local szName = this:GetName()
    local hFrame = this:GetRoot()
    if szName == "Btn_Close" then
        CloseBubblePanel(this:GetRoot())
    elseif szName == "Btn_Link" then
        OpenActivePopularize(hFrame.tActive)
    end
end

function BubblePanel_Base.OnItemLButtonDown()
    local szName = this:GetName()
    local hFrame = this:GetRoot()
    if szName == "Handle_Bubble" then
        OpenActivePopularize(hFrame.tActive)
    end
end

function BubblePanel_Base.OnFrameBreathe()
    if this.dwStartTime and GetTickCount() - this.dwStartTime > BUBBLE_PANEL_HOLD_TIME then
		 CloseBubblePanel(this)
         return
	end
    
    if not this.bStart then
        BubblePanel.UpdateMessage(this, this.tActive)
    end
end

function BubblePanel.UpdateAnchor(hFrame)
	local nWidth, nHeight = hFrame:GetSize()
	local nOffsetY = BUBBLE_PANEL_DEFAULT_OFFSET_Y  + hFrame.nIndex * nHeight
	hFrame:SetPoint("TOPRIGHT", 0, 0, "TOPRIGHT", BUBBLE_PANEL_DEFAULT_OFFSET_X , nOffsetY)
	hFrame:CorrectPos()
end

function BubblePanel.Update(hFrame, tActive)
    local hName = hFrame:Lookup("", "Text_ActiveName")
    hName:SetText(tActive[2])
    BubblePanel.UpdateMessage(hFrame, tActive)
end

function BubblePanel.UpdateMessage(hFrame, tActive)
    local nTime = GetCurrentTime()
    local nLiveTime = tActive[3] - nTime
    local hText = hFrame:Lookup("", "Text_ActiveMes")
    local szText = ""
    if nLiveTime > 0 then
        szText = GetTimeText(nLiveTime, false, true, true, true) .. g_tStrings.ACTIVE_POPULARIZE_START
    else
        hFrame.bStart = true
        szText = g_tStrings.ACTIVE_POPULARIZE_STARTED
    end
    hText:SetText(szText)
end

local function GetBubblePanelIndex()
    local nIndex = BUBBLE_PANEL_MAX_COUNT
    for i = 1, BUBBLE_PANEL_MAX_COUNT do
        if not tBubbleMap[i] then
            nIndex = i
            break
        end
    end
    return nIndex
end

function OpenBubblePanel(tActive)
    local nBubbleIndex = GetBubblePanelIndex()
    local hFrame = Wnd.OpenWindow("BubblePanel", "BubblePanel"..nBubbleIndex)
    tBubbleMap[nBubbleIndex] = true
    hFrame.tActive = tActive
    hFrame.nIndex = nBubbleIndex
    hFrame.dwStartTime = GetTickCount()
    BubblePanel.UpdateAnchor(hFrame)
    BubblePanel.Update(hFrame, tActive)
end

function CloseBubblePanel(hFrame, bDisableSound)
    tBubbleMap[hFrame.nIndex] = nil
	Wnd.CloseWindow(hFrame)
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND, g_sound.CloseFrame)
	end	
end

-------------------------------------------
function OnAdviceActoveCall()
    local nTime = GetCurrentTime()
    local nCount = #tAdvanceActive
    if nCount <= 0 then
        return
    end

    local tNeedAdvance = tAdvanceActive[nCount][2]
    for _, tActive in ipairs(tNeedAdvance) do
        OpenBubblePanel(tActive)
    end
    
    if nCount >= 2 then
        DelayCall(tAdvanceActive[nCount - 1][1] - nTime, OnAdviceActoveCall)
    end
    
    table.remove(tAdvanceActive, nCount)
end

function OnStartBubbleCall()
    local nNowTime = GetCurrentTime()
    local tTime = TimeToDate(nNowTime)
    local tAdvancedTimeMap = {}
    if not bFistCall then
        local tAllActive = Table_GetCalenderOfDay(tTime.year, tTime.month, tTime.day, 4)
        for _, tActive in ipairs(tAllActive) do
            if tActive.tAdvancedTime and nNowTime < tActive.nStartTime then
                for _, nTime in ipairs(tActive.tAdvancedTime) do
                    local nAdvanceTime = tActive.nStartTime - nTime * 60 
                    if nAdvanceTime > nNowTime then
                        if not tAdvancedTimeMap[nAdvanceTime] then
                            table.insert(tAdvanceActive, {nAdvanceTime, {}})
                            tAdvancedTimeMap[nAdvanceTime] = #tAdvanceActive
                        end
                        local nIndex = tAdvancedTimeMap[nAdvanceTime]
                        table.insert(tAdvanceActive[nIndex][2], {tActive.dwID, tActive.szName, tActive.nStartTime, tActive.nEndTime})
                    end
                end
            end
        end
    end
    bFistCall = true
    local tNextDay = GetNextDay(tTime)
    local tAllActive = Table_GetCalenderOfDay(tNextDay.year, tNextDay.month, tNextDay.day, 4)
    for _, tActive in ipairs(tAllActive) do
        if tActive.tAdvancedTime then
            for _, nTime in ipairs(tActive.tAdvancedTime) do
                local nAdvanceTime = tActive.nStartTime - nTime * 60 
                if nAdvanceTime > nNowTime then
                    if not tAdvancedTimeMap[nAdvanceTime] then
                        table.insert(tAdvanceActive, {nAdvanceTime, {}})
                        tAdvancedTimeMap[nAdvanceTime] = #tAdvanceActive
                    end
                    local nIndex = tAdvancedTimeMap[nAdvanceTime]
                    table.insert(tAdvanceActive[nIndex][2], {tActive.dwID, tActive.szName, tActive.nStartTime, tActive.nEndTime})
                end
            end
        end
    end
    
    local nNextTime = DateToTime(tNextDay.year, tNextDay.month, tNextDay.day, 1, 0, 0)
    if nNextTime < nNowTime then
        return
    end	
	
    DelayCall(nNextTime - nNowTime, OnStartBubbleCall)

    local SortByTime = function(tLeft, tRight)
        return tLeft[1] > tRight[1]
    end
    table.sort(tAdvanceActive, SortByTime)
    local nIndex = #tAdvanceActive
    if nIndex >= 1 then
        DelayCall(tAdvanceActive[nIndex][1] - nNowTime, OnAdviceActoveCall)
    end
end

RegisterEvent("LOGIN_GAME", function() OnStartBubbleCall() end)
