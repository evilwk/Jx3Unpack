local MAX_TIP_COUNT = 5
local TIME_MINUTE = 60
local TIME_SECOND = 1000
local szIniFile = "ui/Config/Default/ActivityTipPanel.ini"
ActivityTipPanel = {}
ActivityTipPanel.tDefaultAnchor = {s = "TOPRIGHT", r = "TOPRIGHT", x = -100, y = 300}
ActivityTipPanel_Base = class()

function ActivityTipPanel_Base.OnFrameCreate()
    this:RegisterEvent("UI_SCALED")
    this:RegisterEvent("PLAYER_ENTER_SCENE")
    
    ActivityTipPanel.UpdateAnchor(this)
end

function ActivityTipPanel_Base.OnEvent(szEvent)
    if szEvent == "UI_SCALED" then
        ActivityTipPanel.UpdateAnchor(this)
    elseif szEvent == "PLAYER_ENTER_SCENE" then
		local hPlayer = GetClientPlayer()
		if hPlayer and hPlayer.dwID == arg0 then
			CloseActivityTipPanel(this.dwActivityID)
		end
    end
end

function ActivityTipPanel_Base.OnItemMouseEnter()
    local szName = this:GetName()
    if szName == "Text_Link" then
        local szLink = this.szLink
        if szLink and szLink ~= "" then
            this:SetFontScheme(59)
        end
    end
end

function ActivityTipPanel_Base.OnItemMouseLeave()
    local szName = this:GetName()
    if szName == "Text_Link" then
        this:SetFontScheme(27)
    end
end

function ActivityTipPanel_Base.OnItemLButtonDown()
    local szName = this:GetName()
    if szName == "Text_Link" then
        local szLink = this.szLink
        if szLink and szLink ~= "" then
            FireUIEvent("EVENT_LINK_NOTIFY", szLink)
        end
    end
end

function ActivityTipPanel_Base.OnFrameDragEnd()
	this:CorrectPos()
	this.tAnchor = GetFrameAnchor(this)
end

function ActivityTipPanel_Base.Init(hFrame)
    local dwActivityID = hFrame.dwActivityID
    local tDesc = Table_GetActiviyTipDesc(dwActivityID)
    local hTitle = hFrame:Lookup("", "Text_Title")
    hTitle:SetText(tDesc.szName)
    ActivityTipPanel.UpdateTime(hFrame)
    ActivityTipPanel.InitTip(hFrame, tDesc)
end

function ActivityTipPanel_Base.OnFrameBreathe()
    if not this.nTime or this.nTime < 0 then
        return
    end
    
    if not this.nStartTime then
        return
    end
    local nNowTime = GetTickCount()
    local nLeftTime = this.nTime - (nNowTime - this.nStartTime) / TIME_SECOND
    ActivityTipPanel.UpdateTime(this)
end

function ActivityTipPanel_Base.OnCheckBoxCheck()
    local szName = this:GetName()
    local hFrame = this:GetRoot()
    if szName == "CheckBox_Minimize" then
        hFrame:GetSelf().MiniSize(hFrame, true)
    end
end

function ActivityTipPanel_Base.OnCheckBoxUncheck()
    local szName = this:GetName()
    local hFrame = this:GetRoot()
    if szName == "CheckBox_Minimize" then
        hFrame:GetSelf().MiniSize(hFrame, false)
    end
end

function ActivityTipPanel_Base.MiniSize(hFrame, bMiniSize)
    local hTotalHandle = hFrame:Lookup("", "")
    hFrame.bMiniSize = true
    local hImageBg = hTotalHandle:Lookup("Image_BG")
    local hState = hTotalHandle:Lookup("Handle_State")
    local hActivity = hTotalHandle:Lookup("Handle_Activity")
    local hTipHandle = hTotalHandle:Lookup("Handle_Tip")
    if bMiniSize then
        hImageBg:Hide()
        hState:Hide()
        hActivity:Hide()
        hTipHandle:Hide()
    else
        hImageBg:Show()
        hState:Show()
        if not hActivity.bHide then
            hActivity:Show()
        end
        hTipHandle:Show()
    end
end

function ActivityTipPanel.InitTip(hFrame, tDesc)
    local hTipHandle = hFrame:Lookup("", "Handle_Tip")
    local hLinkHandle = hFrame:Lookup("", "Handle_Activity")
    local hLink = hLinkHandle:Lookup("Text_Link")
    if tDesc.szLink and tDesc.szLink ~= "" then
        hLinkHandle:Show()
        hLink.szLink = tDesc.szLink
        hLinkHandle.bHide = false
    else
        hLinkHandle:Hide()
        hLinkHandle.bHide = true
    end
    
    hTipHandle:Clear()
    for i = 1, MAX_TIP_COUNT do
        local szTip = tDesc["szTip" .. i] 
        if szTip and szTip ~= "" then
            local hTip = hTipHandle:AppendItemFromIni(szIniFile, "Handle_TipMsg", "Handle_Tip".. (i))
            hTip:Lookup("Text_Name"):SetText(szTip .. g_tStrings.STR_COLON)
            hTip:Lookup("Text_Value"):SetText("")
            hTip:FormatAllItemPos()
        end
    end
    hTipHandle:FormatAllItemPos()
    local hImageBg = hFrame:Lookup("", "Image_BG")
    local fWidth = hImageBg:GetSize()
    local _, fHeight = hTipHandle:GetAllItemSize()
    hTipHandle:SetSize(fWidth, fHeight)
    
    local fPosX, fPosY = hTipHandle:GetRelPos()
    hImageBg:SetSize(fWidth, fPosY + fHeight + 10)
end

function ActivityTipPanel.FormatTime(nTime)
	local szTime = ""
	if nTime < 0 then
        nShowTime = -1
    end
	local nShowTime = math.floor(nTime / TIME_MINUTE)
	if nShowTime < 1 then                                         
		szTime = "<1"                                         
		nFonsScheme = 196
	else                                         
		szTime = nShowTime                                         
		nFonsScheme = 198                                     
	end                                         
	szTime = szTime .. g_tStrings.STR_BUFF_H_TIME_M     
	
	return szTime, nFonsScheme, nShowTime
end 

function ActivityTipPanel.UpdateAnchor(hFrame)
    if not hFrame.tAnchor then
        hFrame.tAnchor = clone(ActivityTipPanel.tDefaultAnchor)
    end
    local tAnchor = hFrame.tAnchor
	hFrame:SetPoint(tAnchor.s, 0, 0, tAnchor.r, tAnchor.x, tAnchor.y)
	hFrame:CorrectPos()
end

function ActivityTipPanel.UpdateTime(hFrame)
    if not hFrame.nTime then
        return 
    end
    
    if not hFrame.nStartTime then
        return 
    end
    
    local nLeftTime = hFrame.nTime - (GetTickCount() - hFrame.nStartTime) / TIME_SECOND
    local szTimeDesc = ""
    if nLeftTime <= 0 then
        szTimeDesc = Table_GetActiviyTimeDesc(hFrame.dwActivityID)
        if szTimeDesc == "" then
            szTimeDesc = g_tStrings.ACTIVITY_TIP_STATE_END
        end
    else
        szTimeDesc = g_tStrings.ACTIVITY_TIP_STATE .. g_tStrings.STR_COLON
    end
    local hState = hFrame:Lookup("", "Handle_State")
    local hTimeDesc = hState:Lookup("Text_State")
    local hTime = hState:Lookup("Text_Time")
    hTime:SetText("")
    if nLeftTime > 0 then
        local szTime, nFontScheme, nShowTime = ActivityTipPanel.FormatTime(nLeftTime)
        hFrame.nShowTime = nShowTime
        hTime:SetFontScheme(nFontScheme)
        hTime:SetText(szTime)
    end
    
    hTimeDesc:SetText(szTimeDesc)
end

function ActivityTipPanel_Base.Update(hFrame, nTime, tValue)
    if nTime then
        hFrame.nTime = nTime
        hFrame.nStartTime = GetTickCount()
        ActivityTipPanel.UpdateTime(hFrame)
    end
    local hTipHandle = hFrame:Lookup("", "Handle_Tip")
    for i = 1, MAX_TIP_COUNT do
        if tValue[i] then
            local szValue = tValue[i]
            local hTip = hTipHandle:Lookup("Handle_Tip" .. i)
            if hTip then
               hTip:Lookup("Text_Value"):SetText(szValue)
               hTip:FormatAllItemPos()
            else
                 Log("ActivityTipPanel not have tip " .. i)
            end
        end
    end
    hTipHandle:FormatAllItemPos()
end

function ActivityTipPanel_OnActivityTipUpdate(dwActivityID, nTime, tValue)
      if not IsActivityTipPanelOpened(dwActivityID) then
         if not nTime then
            Log("ActivityTipPanel must open with live time")
            return 
         end
         OpenActivityTipPanel(dwActivityID, nTime)
      end
        
      local hFrame = Station.Lookup("Normal/ActivityTipPanel" .. dwActivityID)
      hFrame:GetSelf().Update(hFrame, nTime, tValue)
end

function OpenActivityTipPanel(dwActivityID, nTime)
    if not IsActivityTipPanelOpened(dwActivityID) then
        Wnd.OpenWindow("ActivityTipPanel", "ActivityTipPanel"..dwActivityID)
    end
	local hFrame = Station.Lookup("Normal/ActivityTipPanel" .. dwActivityID)
    hFrame.nStartTime = GetTickCount()
    hFrame.dwActivityID = dwActivityID
    hFrame.nTime = nTime
    hFrame:GetSelf().Init(hFrame)
end

function IsActivityTipPanelOpened(dwActivityID)
	local hFrame = Station.Lookup("Normal/ActivityTipPanel" .. dwActivityID)
	if hFrame then
		return true
	end
	
	return false
end

function CloseActivityTipPanel(dwActivityID, bDisableSound)
	if not IsActivityTipPanelOpened(dwActivityID) then
		return
	end
	
	Wnd.CloseWindow("ActivityTipPanel" .. dwActivityID)
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND, g_sound.CloseFrame)
	end
end

RegisterEvent("ACTIVITY_TIP_UPDATE", function() ActivityTipPanel_OnActivityTipUpdate(arg0, arg1, arg2) end)