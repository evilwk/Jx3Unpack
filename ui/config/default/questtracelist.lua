local INTERVAL_SIZE = 15
local szIniFile = "UI/Config/Default/QuestTraceList.ini"
local tShieldTraceQuest = {5549, 5550, 5552, 5553}

QuestTraceList = 
{
	bAuto = true,
	bShowTeamateQuestTrace = true,
	bShowGPS = true,
	bShowTrace = true,
	--nCount = 7,
	nDefaultCount = 7,
	bShowLinkQuest = true,
	fBgAlpha = 185,
	DefaultAnchor = {s = "TOPRIGHT", r = "TOPRIGHT", x = -65, y = 420},
	Anchor = {s = "TOPRIGHT", r = "TOPRIGHT", x = -65, y = 420}
}

--RegisterCustomData("QuestTraceList.nCount")--该变量已经被保存在玩家本地
RegisterCustomData("QuestTraceList.bAuto")
RegisterCustomData("QuestTraceList.Anchor")
RegisterCustomData("QuestTraceList.bShowLinkQuest")
RegisterCustomData("QuestTraceList.fBgAlpha")
RegisterCustomData("QuestTraceList.bShowTeamateQuestTrace")
RegisterCustomData("QuestTraceList.bShowGPS")
RegisterCustomData("QuestTraceList.bShowTrace")

function QuestTraceList.OnFrameCreate()
	this:RegisterEvent("QUEST_ACCEPTED")
	this:RegisterEvent("QUEST_FAILED")
	this:RegisterEvent("QUEST_CANCELED")
	this:RegisterEvent("QUEST_FINISHED")
	this:RegisterEvent("QUEST_SHARED")	
	this:RegisterEvent("QUEST_DATA_UPDATE")
	this:RegisterEvent("QUEST_TIME_UPDATE")
	this:RegisterEvent("LOADING_END")
	this:RegisterEvent("QUEST_LIST_UPDATE")
	this:RegisterEvent("UI_SCALED")
	this:RegisterEvent("ON_ENTER_CUSTOM_UI_MODE")
	this:RegisterEvent("ON_LEAVE_CUSTOM_UI_MODE")
	this:RegisterEvent("QUEST_TRACE_ANCHOR_CHANGED")
	this:RegisterEvent("QUEST_TRACE_LIST_COUNT_CHANGED")
	this:RegisterEvent("CUSTOM_DATA_LOADED")
	this:RegisterEvent("ON_BG_CHANNEL_MSG")
	this:RegisterEvent("PLAYER_ENTER_SCENE")
	this:RegisterEvent("BAG_ITEM_UPDATE")
	this:RegisterEvent("BANK_ITEM_UPDATE")
	this:RegisterEvent("SOLD_ITEM_UPDATE")
	this:RegisterEvent("DESTROY_ITEM")
	

	local handle = this:Lookup("", "Handle_Info")
	this.nCount = 0	
	QuestTraceList.LoadTraceQuest(this)
	
	QuestTraceList.UpdateAnchor(this)
	UpdateCustomModeWindow(this, g_tStrings.QUEST_TRACE_LIST)
	this:EnableDrag(true)
end

function QuestTraceList.OnFrameDrag()
end

function QuestTraceList.OnFrameDragSetPosEnd()
end

function QuestTraceList.OnFrameDragEnd()
	this:CorrectPos()
	QuestTraceList.Anchor = GetFrameAnchor(this)
end

function QuestTraceList.UpdateAnchor(frame)
	frame:SetPoint(QuestTraceList.Anchor.s, 0, 0, QuestTraceList.Anchor.r, QuestTraceList.Anchor.x, QuestTraceList.Anchor.y)
	frame:CorrectPos()
end

function QuestTraceList.OnFrameBreathe()
	local hPlayer = GetClientPlayer()
	if not hPlayer then
		return
	end
	
	local hTrace = this:Lookup("", "Handle_Info")
	local nCount = hTrace:GetItemCount()
	
	for i = 0, nCount - 1 do
		local hQuest = hTrace:Lookup(i)
		local hItemBox = hQuest:Lookup("Handle_Item/Box_UseItem")
		if hItemBox and not hItemBox:IsEmpty() then
			local _, nVersion, dwType, dwIndex = hItemBox:GetObjectData()
	    	local dwBox, dwX = hPlayer.GetItemPos(dwType, dwIndex)
	    	if dwBox and dwX then
	    		UpdataItemCDProgress(hPlayer, hItemBox, dwBox, dwX)
	    	end
	    end
	end
	
	if not QuestTraceList.bShowGPS or not QuestTraceList.bShowTrace then
		return
	end
	
	for i = 0, nCount - 1 do
		local hQuest = hTrace:Lookup(i)
		local hGPS = hQuest:Lookup("Handle_Compass")
		QuestTraceList.UpdateQuestGPSState(hGPS)
	end
end

function QuestTraceList.OnEvent(event)
	if event == "QUEST_ACCEPTED" then
		if QuestTraceList.bAuto then
			QuestTraceList.AddTraceQuest(this, arg1)
		end
	elseif event == "QUEST_FAILED" then
	
	elseif event == "QUEST_CANCELED" then
		QuestTraceList.RemoveTraceQuest(this, arg0)
	elseif event == "QUEST_FINISHED" then
		QuestTraceList.RemoveTraceQuest(this, arg0)
	elseif event == "QUEST_SHARED" then
	elseif event == "QUEST_DATA_UPDATE" then
		local dwQuestID = GetClientPlayer().GetQuestID(arg0)
		if QuestTraceList.bAuto then	
			QuestTraceList.AddTraceQuest(this, dwQuestID)
		else
			QuestTraceList.UpdateTraceQuest(this, dwQuestID)
		end
	elseif event == "QUEST_TIME_UPDATE" then
		local dwQuestID = GetClientPlayer().GetQuestID(arg0)
		if QuestTraceList.bAuto then	
			QuestTraceList.AddTraceQuest(this, dwQuestID)
		else
			QuestTraceList.UpdateTraceQuest(this, dwQuestID)
		end
	elseif event == "LOADING_END" then
		QuestTraceList.LoadTraceQuest(this)
	elseif event == "QUEST_LIST_UPDATE" then
		QuestTraceList.LoadTraceQuest(this)
	elseif event == "UI_SCALED" then
		QuestTraceList.UpdateSize(this)
		QuestTraceList.UpdateAnchor(this)
	elseif event == "ON_ENTER_CUSTOM_UI_MODE" or event == "ON_LEAVE_CUSTOM_UI_MODE" then
		UpdateCustomModeWindow(this)
		this:EnableDrag(true)
	elseif event == "QUEST_TRACE_ANCHOR_CHANGED" then
		QuestTraceList.UpdateAnchor(this)
	elseif event == "QUEST_TRACE_LIST_COUNT_CHANGED" then
		QuestTraceList.OnTraceQuestCountChanged(this)
	elseif event == "CUSTOM_DATA_LOADED" then
		local hCheck = this:Lookup("CheckBox_Minimize")
		hCheck:Check(not QuestTraceList.bShowTrace)	
		QuestTraceList.UpdateAnchor(this)
		QuestTraceList.OnTraceQuestCountChanged(this)
	elseif event == "ON_BG_CHANNEL_MSG" then
		if QuestTraceList.bShowTeamateQuestTrace then
			local player = GetClientPlayer()
			local t = player.GetTalkData()
			if t and t[2] and t[2].text == "QUEST_SHARE_INFO" and player.szName ~= arg3 and arg1 == PLAYER_TALK_CHANNEL.TEAM then
				if t[4] then
					local szFont = GetMsgFontString("MSG_SYS")
					local nSysFont = GetMsgFont("MSG_SYS")
					local r, g, b = GetMsgFontColor("MSG_SYS")
					local dwQuestID = tonumber(t[4].text)
					local tQuestStringInfo = Table_GetQuestStringInfo(dwQuestID)
					local szText = GetFormatText(t[3].text, nSysFont, r, g, b) 
					.. MakeQuestLink("["..tQuestStringInfo.szName.."]", szFont, dwQuestID)
					
					if t[5] then
						szText = szText .. GetFormatText(t[5].text, nSysFont, r, g, b)
					end
					
					szText = szText .. GetFormatText("\n")
					OutputMessage("MSG_ANNOUNCE_YELLOW", szText, true)
					OutputMessage("MSG_SYS", szText, true)
				else
					OutputMessage("MSG_ANNOUNCE_YELLOW", t[3].text)
				end
				
			end
		end
	elseif event == "BAG_ITEM_UPDATE" or event == "BANK_ITEM_UPDATE" or event == "SOLD_ITEM_UPDATE" then
		local hPlayer = GetClientPlayer()
		if hPlayer then
			local hItem = GetPlayerItem(hPlayer, arg0, arg1)
			if hItem then
				QuestTraceList.OnUpdateUseItemState(this, hItem.dwTabType, hItem.dwIndex)
			end
		end
	elseif event == "DESTROY_ITEM" then
		QuestTraceList.OnUpdateUseItemState(this, arg3, arg4)
	end
end

function QuestTraceList.OnUpdateUseItemState(hFrame, dwTabType, dwTabIndex)
	local hPlayer = GetClientPlayer()
	if not hPlayer then
		return
	end
	local nAccount = hPlayer.GetItemAmount(dwTabType, dwTabIndex)
	local hQuestList = hFrame:Lookup("", "Handle_Info")
	local nCount = hQuestList:GetItemCount()
	for i = 0, nCount - 1 do
		local hQuest = hQuestList:Lookup(i)
		local hBox = hQuest:Lookup("Handle_Item/Box_UseItem")
		local _, _, dwT, dwI = hBox:GetObjectData()
		if dwTabType == dwT and dwTabIndex == dwI then
			hBox:EnableObject(nAccount > 0)
		end
	end
end

function QuestTraceList.OnCheckBoxCheck()
	local szName = this:GetName()
	if szName == "CheckBox_Minimize" then
		QuestTraceList.bShowTrace = false
		local hFrame = this:GetRoot()
		QuestTraceList.UpdateSize(hFrame)
	end
end

function QuestTraceList.OnCheckBoxUncheck()
	local szName = this:GetName()
	if szName == "CheckBox_Minimize" then
		QuestTraceList.bShowTrace = true
		local hFrame = this:GetRoot()
		QuestTraceList.LoadTraceQuest(hFrame)
	end
end

function QuestTraceList.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_Setting" then
		local hFrame = this:GetParent()
		local hImageBg = hFrame:Lookup("", "Image_Bg")
		local hImageTitle = hFrame:Lookup("", "Image_Title")
		
		local ChangedBgAlpha = function(UserData)
			local fnAction = function(f)
				QuestTraceList.fBgAlpha = (1 - f) * 255
				hImageBg:SetAlpha(QuestTraceList.fBgAlpha)
				hImageTitle:SetAlpha(QuestTraceList.fBgAlpha)
			end
			local fPosX, fPosY = Cursor.GetPos()
			GetUserPercentage(fnAction, nil, 1 - UserData / 255, g_tStrings.WINDOW_ADJUST_BG_ALPHA, {fPosX, fPosY, fPosX + 1, fPosY + 1})
		end
		
		local ChangedLinkShow = function(UserData, bCheck)
			QuestTraceList.bShowLinkQuest = bCheck
			
			QuestTraceList.LoadTraceQuest(hFrame)
		end
		
		local ChangedGPSShow = function(UserData, bCheck)
			QuestTraceList.bShowGPS = bCheck
			
			QuestTraceList.LoadTraceQuest(hFrame)
		end
		
		local tMenu = 
		{
			{szOption = g_tStrings.QUEST_TRACE_BG_ALPHA_CHANGE, UserData = hImageBg:GetAlpha(), fnAction = ChangedBgAlpha},
			{szOption = g_tStrings.QUEST_TRACE_LINK, bCheck = true, bChecked = QuestTraceList.bShowLinkQuest, fnAction = ChangedLinkShow},
			{szOption = g_tStrings.QUEST_TRACE_SHOW_GPS, bCheck = true, bChecked = QuestTraceList.bShowGPS, fnAction = ChangedGPSShow},
		}
		PopupMenu(tMenu)
	end
end

function QuestTraceList.OnTraceQuestCountChanged(frame)
	local handle = frame:Lookup("", "Handle_Info")
	local nCount = handle:GetItemCount() - 1
	local a = {}
	local dwQuestID = 0
	for i = 0, nCount, 1 do
		local text = handle:Lookup(i)
		if text.dwQuestID ~= dwQuestID then
			dwQuestID = text.dwQuestID
			table.insert(a, dwQuestID)
		end
	end
	
	nCount = #a
	for i = QuestTraceList.nDefaultCount + 1, nCount, 1 do
		QuestTraceList.RemoveTraceQuest(frame, a[i])
	end
end

function QuestTraceList.LoadTraceQuest(frame)
	frame.bLoad = true
	QuestTraceList.ClearTraceQuest(frame)
	for i = 1, QuestTraceList.nDefaultCount, 1 do
		QuestTraceList.AddTraceQuest(frame, GetUserPreferences(1300 + (i - 1) * 4, "d"))
	end
	frame.bLoad = false
end

function QuestTraceList.SaveTraceQuest(hFrame)
	if hFrame.bLoad then
		return
	end
	
	local hTrace = hFrame:Lookup("", "Handle_Info")
	
	local nCount = hTrace:GetItemCount()
	local a = {}
	for i = 0, nCount - 1 do
		local hQuest = hTrace:Lookup(i)
		table.insert(a, hQuest.dwQuestID)
	end
	
	for i = #a + 1, 10, 1 do
		a[i] = 0
	end
	
	SetUserPreferences(1300, "dddddddddd", a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8], a[9], a[10])
end

function QuestTraceList.IsTraceQuest(dwQuestID)
	for i = 1, QuestTraceList.nDefaultCount, 1 do
		if GetUserPreferences(1300 + (i - 1) * 4, "d") == dwQuestID then
			return true
		end
	end
	return false
end

function QuestTraceList.ClearTraceQuest(frame)
	local handle = frame:Lookup("", "Handle_Info")
	handle:Clear()
	handle:SetSize(0, 0)
	frame:SetSize(0, 0)
	frame.nCount = 0
	QuestTraceList.UpdateAnchor(frame)
end

function QuestTraceList.UpdateTraceQuest(hFrame, dwQuestID)
	local hPlayer = GetClientPlayer()
	if not hPlayer then
		return
	end
	local tQuestTrace = hPlayer.GetQuestTraceInfo(dwQuestID)
	local tQuestStringInfo = Table_GetQuestStringInfo(dwQuestID)
	if not tQuestTrace then
		return
	end
	local hQuest = QuestTraceList.FindTraceQuest(hFrame, dwQuestID)
	if not hQuest then
		return
	end
	local hQuestInfo = hQuest:Lookup("Handle_QuestInfo")
	QuestTraceList.UpdateQuestInfo(hQuestInfo, tQuestTrace, tQuestStringInfo)
	QuestTraceList.UpdateUseItem(hQuest, tQuestStringInfo)
	if QuestTraceList.bShowGPS then
		local hGPS = hQuest:Lookup("Handle_Compass")
		QuestTraceList.UpdataQuestGPSInfo(hGPS, dwQuestID)
		QuestTraceList.UpdateQuestGPSState(hGPS)
	end
	QuestTraceList.UpdateSize(hFrame)
end

function QuestTraceList.UpdateUseItem(hQuest, tQuestStringInfo)
	local hBoxItem = hQuest:Lookup("Handle_Item")
	hBoxItem:Hide()
	if tQuestStringInfo.bUseItem then
		local hBox = hBoxItem:Lookup("Box_UseItem")
		local dwQuestID = hQuest.dwQuestID
		local tQuestInfo = GetQuestInfo(dwQuestID)
		local dwItemType = tQuestInfo["dwOfferItemType1"]
		local dwItemIndex = tQuestInfo["dwOfferItemIndex1"]
		local nAccount = GetClientPlayer().GetItemAmount(dwItemType, dwItemIndex)
		local tItemInfo = GetItemInfo(dwItemType, dwItemIndex)
		hBox:SetObject(UI_OBJECT_ITEM_INFO, tItemInfo.nUiId, 0, dwItemType, dwItemIndex)
		hBox:SetObjectIcon(Table_GetItemIconID(tItemInfo.nUiId))
    	hBox:EnableObject(nAccount > 0)
    	local hQuestInfo = hQuest:Lookup("Handle_QuestInfo")
    	local fWidth = hQuestInfo:GetSize()
    	local fInfoPosX = hQuestInfo:GetRelPos()
    	local _, fItemPosY = hBoxItem:GetRelPos()
    	hBoxItem:SetRelPos(fInfoPosX + fWidth, fItemPosY)
    	local fBoxItemWidth = hBoxItem:GetSize()
    	hQuest.fWidth = hQuest.fWidth + fBoxItemWidth
    	local _, fQuestHeight = hQuest:GetSize()
    	hQuest:SetSize(hQuest.fWidth, fQuestHeight)
		hQuest:FormatAllItemPos()
		
		hBoxItem:Show()
	end
end


function QuestTraceList.FindTraceQuest(hFrame, dwQuestID)
	local hHandle = hFrame:Lookup("", "Handle_Info")
	local nCount = hHandle:GetItemCount()
	for i = 0, nCount - 1 do
		local hQuest = hHandle:Lookup(i)
		if hQuest.dwQuestID == dwQuestID then
			return hQuest
		end
	end
end

function QuestTraceList.UpdateQuestInfo(hQuestInfo, tQuestTrace, tQuestStringInfo)
	local hQuest = hQuestInfo:GetParent()
	
    if (hQuestInfo.bFinish and not tQuestTrace.finish) or 
    (not hQuestInfo.bFinish and tQuestTrace.finish and tQuestStringInfo.szQuestFinishedObjective ~= "" ) or 
    (hQuestInfo.bFailed and not tQuestTrace.fail) or 
    (not hQuestInfo.bFailed and tQuestTrace.fail)
    then
        hQuestInfo:Clear()
        QuestTraceList.AddQuestInfo(hQuestInfo, hQuest.dwQuestID, tQuestTrace, tQuestStringInfo)
    end
    
    local nCount = hQuestInfo:GetItemCount()
	for i = 0, nCount - 1 do
		hInfo = hQuestInfo:Lookup(i)
		if hInfo.bName then
			QuestTraceList.UpdateQuestName(hInfo, tQuestTrace, tQuestStringInfo)
		elseif hInfo.bTime then
			QuestTraceList.UpdateQuestTime(hInfo, tQuestTrace)
		elseif hInfo.bState then
			QuestTraceList.UpdateQuestState(hInfo, tQuestTrace.quest_state[hInfo.i], tQuestStringInfo)
		elseif hInfo.bNpc then
			QuestTraceList.UpdateQuestNpc(hInfo, tQuestTrace.kill_npc[hInfo.i])
		elseif hInfo.bItem then
			QuestTraceList.UpdateQuestItem(hInfo, tQuestTrace.need_item[hInfo.i])
		elseif hInfo.bObjective then
			QuestTraceList.UpdateQuestObjective(hInfo, tQuestTrace, tQuestStringInfo.szObjective)
        elseif hInfo.bFinishedObjective then
			QuestTraceList.UpdateQuestFinishedObjective(hInfo, tQuestStringInfo.szQuestFinishedObjective)
        elseif hInfo.bFailed then
            QuestTraceList.UpdateQuestFailedObjective(hInfo, tQuestStringInfo.nID, tQuestStringInfo.szQuestFailedObjective)
		end
	end 
	hQuestInfo:SetSize(350, 1000)
	hQuestInfo:FormatAllItemPos()
	local fWidth, fHeight = hQuestInfo:GetAllItemSize()
	fWidth = fWidth + INTERVAL_SIZE
	
	local fQuestWidth = fWidth
	local fQuestHeight = fHeight
	if QuestTraceList.bShowGPS then
		local hGPS = hQuest:Lookup("Handle_Compass")
		local fGPSWidth, fGPSHeight = hGPS:GetSize()
		fQuestWidth = fWidth + fGPSWidth
		fQuestHeight = fQuestHeight + INTERVAL_SIZE
		if fQuestHeight < fGPSHeight then
			fQuestHeight = fGPSHeight
		end
	else
		hQuestInfo:SetRelPos(12, 0)
	end
	hQuestInfo:SetSize(fWidth, fQuestHeight)
	hQuest:SetSize(fQuestWidth, fQuestHeight)
	hQuest.fWidth = fQuestWidth
	hQuest:FormatAllItemPos()
end

function QuestTraceList.AddTraceQuest(hFrame, dwQuestID)
	local hPlayer = GetClientPlayer()
	
	if not hPlayer then
		return
	end
	local nIndex = hPlayer.GetQuestIndex(dwQuestID)
	if not nIndex then
		return
	end
	local tQuestTrace = hPlayer.GetQuestTraceInfo(dwQuestID)
	local tQuestStringInfo = Table_GetQuestStringInfo(dwQuestID)
	if not tQuestTrace then
		return
	end
	local hQuest = QuestTraceList.FindTraceQuest(hFrame, dwQuestID)
	if hQuest then
		QuestTraceList.UpdateTraceQuest(hFrame, dwQuestID)
	else
		QuestTraceList.AddOneTraceQuest(hFrame, dwQuestID)
	end
	if hFrame.nCount > QuestTraceList.nDefaultCount then
		local hTrace = hFrame:Lookup("", "Handle_Info")
		local nCount = hTrace:GetItemCount()
		assert(hFrame.nCount == nCount)
		local dwRemoveQuestID = hTrace:Lookup(0).dwQuestID
		QuestTraceList.RemoveTraceQuest(hFrame, dwRemoveQuestID)
	end
	
	QuestTraceList.UpdateSize(hFrame)
	QuestTraceList.SaveTraceQuest(hFrame)
	
	local argS0, argS1 = arg0, arg1
	arg0, arg1 = dwQuestID, true
	FireEvent("ON_TRACE_QUEST")
	arg0, arg1 = argS0, argS1
end

function QuestTraceList.AddOneTraceQuest(hFrame, dwQuestID)
	local hPlayer = GetClientPlayer()
	
	if not hPlayer then
		return
	end
	local nIndex = hPlayer.GetQuestIndex(dwQuestID)
	if not nIndex then
		return
	end
	local tQuestTrace = hPlayer.GetQuestTraceInfo(dwQuestID)
	local tQuestStringInfo = Table_GetQuestStringInfo(dwQuestID)
	if not tQuestTrace then
		return
	end
	
	local hTrace = hFrame:Lookup("", "Handle_Info")
	local nCount = hTrace:GetItemCount()
	local hQuest = hTrace:AppendItemFromIni(szIniFile, "Handle_Quest", "Handle_Quest".. (nCount + 1))
	hQuest:Show()
	hQuest:Clear()
    hQuest.dwQuestID = dwQuestID
    
	local hQuestInfo = hQuest:AppendItemFromIni(szIniFile, "Handle_QuestInfo")
	QuestTraceList.AddQuestInfo(hQuestInfo, dwQuestID, tQuestTrace, tQuestStringInfo)
	
	hFrame.nCount = hFrame.nCount + 1
	if QuestTraceList.bShowGPS then
		local hGPS = hQuest:AppendItemFromIni(szIniFile, "Handle_Compass")
		QuestTraceList.UpdataQuestGPSInfo(hGPS, dwQuestID)
		QuestTraceList.UpdateQuestGPSState(hGPS)
	end
	
	QuestTraceList.UpdateQuestInfo(hQuestInfo, tQuestTrace, tQuestStringInfo)
	hQuest:AppendItemFromIni(szIniFile, "Handle_Item")
	QuestTraceList.UpdateUseItem(hQuest, tQuestStringInfo)
	hTrace:FormatAllItemPos()
end

function QuestTraceList.AddQuestInfo(hQuestInfo, dwQuestID, tQuestTrace, tQuestStringInfo)
    hQuestInfo:AppendItemFromString("<handle>eventid=853 handletype=3<text></text><image>w=20 h=20 path=\"ui/Image/QuestPanel/QuestPanel.UITex\" frame=33 eventid=85 lockshowhide=1</image><handle>")
	nCount = hQuestInfo:GetItemCount()
	local text = hQuestInfo:Lookup(nCount - 1)
	text.bName = true
	text.bTimerQuest = tQuestTrace.time
	QuestTraceList.UpdateQuestName(text, tQuestTrace, tQuestStringInfo)
	text.dwQuestID = dwQuestID
	
	hQuestInfo:AppendItemFromString("<text>text=\"\\\n\"font=0</text>")
	nCount = hQuestInfo:GetItemCount()
	local text = hQuestInfo:Lookup(nCount - 1)
	text.bTimerQuest = tQuestTrace.time
    
    if tQuestTrace.time then
        hQuestInfo:AppendItemFromString("<text></text>")
        nCount = hQuestInfo:GetItemCount()
        local text = hQuestInfo:Lookup(nCount - 1)
        text.bTime = true
        text.bTimerQuest = tQuestTrace.time
    end

    if tQuestTrace.fail then
        hQuestInfo:AppendItemFromString("<text></text>")
		nCount = hQuestInfo:GetItemCount()
		local text = hQuestInfo:Lookup(nCount - 1)
		text.bFailed = true
		text.bTimerQuest = tQuestTrace.time
        hQuestInfo.bFailed = true
        hQuestInfo.bFinish = false
    elseif tQuestTrace.finish and tQuestStringInfo.szQuestFinishedObjective ~= "" then
        hQuestInfo:AppendItemFromString("<text></text>")
		nCount = hQuestInfo:GetItemCount()
		local text = hQuestInfo:Lookup(nCount - 1)
		text.bFinishedObjective = true
		text.bTimerQuest = tQuestTrace.time
        hQuestInfo.bFinish = true
        hQuestInfo.bFailed = false
    else
        hQuestInfo.bFinish = false
        hQuestInfo.bFailed = false
        for k, v in pairs(tQuestTrace.quest_state) do
            hQuestInfo:AppendItemFromString("<text></text>")
            nCount = hQuestInfo:GetItemCount()
            local text = hQuestInfo:Lookup(nCount - 1)
            text.bState = true
            text.bTimerQuest = tQuestTrace.time
            text.i = k
        end
        
        for k, v in pairs(tQuestTrace.kill_npc) do
            hQuestInfo:AppendItemFromString("<text></text>")
            nCount = hQuestInfo:GetItemCount()
            local text = hQuestInfo:Lookup(nCount - 1)
            text.bNpc = true
            text.bTimerQuest = tQuestTrace.time
            text.i = k
        end

        for k, v in pairs(tQuestTrace.need_item) do
            hQuestInfo:AppendItemFromString("<text></text>")
            nCount = hQuestInfo:GetItemCount()
            local text = hQuestInfo:Lookup(nCount - 1)
            text.bItem = true
            text.bTimerQuest = tQuestTrace.time
            text.i = k
        end
        
        if not tQuestTrace.have_trace then
            hQuestInfo:AppendItemFromString("<text></text>")
            nCount = hQuestInfo:GetItemCount()
            local text = hQuestInfo:Lookup(nCount - 1)
            text.bObjective = true
            text.bTimerQuest = tQuestTrace.time
            text.dwQuestID = dwQuestID
        end
    end
end

function QuestTraceList.UpdateQuestGPSState(hGPS)
	if hGPS.bChange then
		QuestTraceList.AppendQuestGPSHandle(hGPS)
		hGPS.bChange = false
	end
	local nCount = hGPS:GetItemCount()
	
	hGPS.fDistance = nil
	for i = 0, nCount - 1 do 
		local hItem = hGPS:Lookup(i)
		local szName = hItem:GetName()
		if szName == "Image_PointGreen" or szName == "Image_PointRed" then
			local tPoint = hGPS.tTarget[hItem.nPointIndex]
			if tPoint then
				QuestTraceList.UpdataQuestGPSTarget(hItem, tPoint.fX, tPoint.fY)
				hItem.szName = tPoint.szName
			end
		elseif szName == "Image_Player" then
			QuestTraceList.UpdateQuestGPSSelf(hItem)
		end
	end
	if hGPS.fDistance then
		local hDistance = hGPS:Lookup("Text_Distance")
		local fDistance = hGPS.fDistance / 64 -- 1米 = 64点
		local szDistance = FixFloat(fDistance, 0)
		hDistance:SetText(szDistance)
	end
	hGPS:FormatAllItemPos()
end

function QuestTraceList.AppendQuestGPSHandle(hGPS)
	hGPS:Clear()
	local hImage = hGPS:AppendItemFromIni(szIniFile, "Image_CompassBg")
	FireHelpEvent("OnCommentToQuestGPS", hImage)
    --[[
	if hGPS.szTraceState == "Failed_Target" or
    hGPS.szTraceState == "Failed_Carriage" or 
    hGPS.szTraceState == "Failed_Dungeon" 
    then
		hGPS:AppendItemFromIni(szIniFile, "Image_Fail")
    end
    --]]
	if hGPS.szTraceState == "Finish_Target" or 
    hGPS.szTraceState == "UnFinish_Target" or 
    hGPS.szTraceState == "Failed_Target" then
		hGPS:AppendItemFromIni(szIniFile, "Image_Player")
		hGPS:AppendItemFromIni(szIniFile, "Text_Distance")
		for nPointIndex, tPoint in ipairs(hGPS.tTarget) do
			local hPoint
			if tPoint.bGreen then
				hPoint = hGPS:AppendItemFromIni(szIniFile, "Image_PointGreen")
			elseif tPoint.bRed then
				hPoint = hGPS:AppendItemFromIni(szIniFile, "Image_PointRed")
			end
			hPoint.nPointIndex = nPointIndex
		end
	elseif hGPS.szTraceState == "Finish_Carriage" or 
    hGPS.szTraceState == "UnFinish_Carriage" or
    hGPS.szTraceState == "Failed_Carriage" 
    then
		local hPoint = hGPS:AppendItemFromIni(szIniFile, "Image_Carriage")
	elseif hGPS.szTraceState == "Finish_Dungeon" or 
    hGPS.szTraceState == "UnFinish_Dungeon" or 
    hGPS.szTraceState == "Failed_Dungeon" 
    then
		local hDungeon = hGPS:AppendItemFromIni(szIniFile, "Image_Dungeon")
	else
		hImage.bNoQuestGPS = true
	end
	hGPS:FormatAllItemPos()
end

function QuestTraceList.UpdateQuestGPSSelf(hImageSelf)
	local hPlayer = GetClientPlayer()
	if not hPlayer then
		return
	end
	local h = (255 - hPlayer.nFaceDirection) * 6.2832 / 255
	hImageSelf:SetRotate(h)
end

function QuestTraceList.UpdataQuestGPSTarget(hPoint, fTargetX, fTargetY)
	local hPlayer = GetClientPlayer()
	if not hPlayer then
		return
	end
	
	local hImageBg = hPoint:GetParent():Lookup("Image_CompassBg")
	local fX, fY = hImageBg:GetRelPos()
	local fWidth, fHeight = hImageBg:GetSize()
	local fR = fWidth / 2
	fX = fX + fR
	fY = fY + fR
	fR = fR - 3 --由于贴图比实际的圆圈大，所以半径应该小一些
	local fDistance = math.sqrt((hPlayer.nX - fTargetX) * (hPlayer.nX - fTargetX) + (hPlayer.nY - fTargetY) * (hPlayer.nY - fTargetY)) 
	local fRate = fR / fDistance
	local fRelTargetX = fX + fRate * (fTargetX - hPlayer.nX)
	local fRelTargetY = fY + fRate * (hPlayer.nY - fTargetY)
	local fPointWidth, fPointHeight = hPoint:GetSize()
	fRelTargetX = fRelTargetX - fPointWidth / 2
	fRelTargetY = fRelTargetY - fPointHeight / 2
	hPoint:SetRelPos(fRelTargetX, fRelTargetY)
	local hGPS = hPoint:GetParent()
	if not hGPS.fDistance or hGPS.fDistance > fDistance then
		hGPS.fDistance = fDistance
	end
end

function QuestTraceList.UpdataQuestGPSInfo(hGPS, dwQuestID)
	local hPlayer = GetClientPlayer()
	if not hPlayer then
		return
	end
	local hQuestInfo = GetQuestInfo(dwQuestID)
	local tQuestStringInfo = Table_GetQuestStringInfo(dwQuestID)
	local tQuestTrace = hPlayer.GetQuestTraceInfo(dwQuestID)
	
	hGPS.tMaps = {}
	hGPS.tTarget = {}
	hGPS.szTraceState = ""
	hGPS.bChange = true
	hGPS.fDistance = nil
	
	if tQuestTrace.fail then
		hGPS.szTraceState = "Failed"
        QuestTraceList.GetGPSInfo(hGPS, "Failed", dwQuestID, "accept", 0)
		return
	end
	if tQuestTrace.finish then
		QuestTraceList.GetGPSInfo(hGPS, "Finish", dwQuestID, "finish", 0)
		return
	end
	
	for k, v in pairs(tQuestTrace.quest_state) do
		if v.have < v.need then
			QuestTraceList.GetGPSInfo(hGPS, "UnFinish", dwQuestID, "quest_state", v.i)
		end
	end
	
	for k, v in pairs(tQuestTrace.kill_npc) do
		if v.have < v.need then
			QuestTraceList.GetGPSInfo(hGPS, "UnFinish", dwQuestID, "kill_npc", v.i)
		end
	end
	
	for k, v in pairs(tQuestTrace.need_item) do
		if v.have < v.need then
			QuestTraceList.GetGPSInfo(hGPS, "UnFinish", dwQuestID, "need_item", v.i)
		end
	end
end

function QuestTraceList.GetGPSInfo(hGPS, szFinishState, dwQuestID, szType, nIndex)
	tPointList = Table_GetQuestPoint(dwQuestID, szType, nIndex)
	if not tPointList then
		return
	end
	
	local hPlayer = GetClientPlayer()
	if not hPlayer then
		return
	end
	
	local hQuestInfo = GetQuestInfo(dwQuestID)
	local tQuestStringInfo = Table_GetQuestStringInfo(dwQuestID)
	
	local hScene = hPlayer.GetScene()
	local dwMapID = hScene.dwMapID
	local _, nCurrentMapType = GetMapParams(dwMapID)
	
	if nCurrentMapType ~= 1 and tPointList[dwMapID] then --任务目标是否在本场景中，并且本场景不是副本,优先级最高
		hGPS.tMps = {}
		hGPS.szTraceState = szFinishState .. "_Target"
		tInfo = tPointList[dwMapID][1]
		local tPoint = {}
		tPoint.fX = tInfo[1]
		tPoint.fY = tInfo[2]
        if szType == "accept" then
            tPoint.szName = Table_GetNpcTemplateName(hQuestInfo.dwStartNpcTemplateID)
			tPoint.bGreen = true
		elseif szType == "finish" then
			tPoint.szName = Table_GetNpcTemplateName(hQuestInfo.dwEndNpcTemplateID)
			tPoint.bGreen = true
		elseif szType == "quest_state" then
			tPoint.szName = tQuestStringInfo["szQuestValueStr"..(nIndex + 1)]
			tPoint.bRed = true
		elseif szType == "kill_npc" then
			tPoint.szName = Table_GetNpcTemplateName(hQuestInfo["dwKillNpcTemplateID"..(nIndex + 1)])
			tPoint.bRed = true
		elseif szType == "need_item" then
			local dwType, dwIndex = hQuestInfo["dwEndRequireItemType"..(nIndex + 1)], hQuestInfo["dwEndRequireItemIndex"..(nIndex + 1)]
	    	local hItemInfo = GetItemInfo(dwType, dwIndex)
	    	if hItemInfo then
	    		tPoint.szName = GetItemNameByItemInfo(hItemInfo)
	    	end
	    	tPoint.bRed = true
		end
		table.insert(hGPS.tTarget, tPoint)
	end
	
	if hGPS.szTraceState == "UnFinish_Target" or 
    hGPS.szTraceState == "Finish_Target" or
    hGPS.szTraceState == "Failed_Target" 
    then
		return
	end
	
	local bInDungeon = true
	for k,_ in pairs(tPointList) do
		local _, nMapType = GetMapParams(k)
		if nMapType ~= 1 then
			bInDungeon = false
		end		
	end
	if not bInDungeon then --目标在其他场景的显示优先级高于，目标在副本
		if hGPS.szTraceState == "UnFinish_Dungeon" then 
			hGPS.tMps = {}
		end
		
		hGPS.szTraceState = szFinishState .. "_Carriage"
		--任务目标在其他场景中
		for k in pairs(tPointList) do
			if not hGPS.tMaps[k] then
				hGPS.tMaps[k] = true
			end
		end
	end
	
	if hGPS.szTraceState == "UnFinish_Carriage" or 
    hGPS.szTraceState == "Finish_Carriage" or
    hGPS.szTraceState == "Failed_Carriage"
    then
		return
	end
		
	hGPS.szTraceState = szFinishState .. "_Dungeon"
	for k in pairs(tPointList) do
		if not hGPS.tMaps[k] then
			hGPS.tMaps[k] = true
		end
	end
end

function QuestTraceList.UpdateSize(hFrame)
	local hHandleTotal = hFrame:Lookup("", "")
	local hImageBg = hHandleTotal:Lookup("Image_Bg")
	local hHandleInfo = hHandleTotal:Lookup("Handle_Info")
	local hImageTitle = hHandleTotal:Lookup("Image_Title")
	
	if hFrame.nCount == 0 then
		hFrame:Hide()
		return 
	end
	hFrame:Show()
	
	local fX, fY = hHandleInfo:GetRelPos()
	local _, h = hImageTitle:GetSize()
	local nCount = hHandleInfo:GetItemCount()
	local fMaxWidth
	for i = 0, nCount - 1 do
		local hQuest = hHandleInfo:Lookup(i)
		if not fMaxWidth or fMaxWidth < hQuest.fWidth then
			fMaxWidth = hQuest.fWidth
		end
	end
	for i = 0, nCount - 1 do
		local hQuest = hHandleInfo:Lookup(i)
		local _, fHeight = hQuest:GetSize()
		hQuest:SetSize(fMaxWidth, fHeight)
	end
	hHandleInfo:SetSize(fMaxWidth, 1000)
	hHandleInfo:FormatAllItemPos()
	local fWidth, fHeight = hHandleInfo:GetAllItemSize()
	
	if QuestTraceList.bShowTrace then
		hHandleInfo:SetSize(fWidth, fHeight)
		fWidth = fWidth + fX + INTERVAL_SIZE
		fHeight = fHeight + fY + INTERVAL_SIZE
		hHandleInfo:Show()
	else
		hHandleInfo:SetSize(fWidth, 0)
		fHeight = h
		hHandleInfo:Hide()
	end
	
	hImageTitle:SetSize(fWidth, h)
	hImageTitle:SetAlpha(QuestTraceList.fBgAlpha)
	hImageBg:SetAlpha(QuestTraceList.fBgAlpha)
	hImageBg:SetSize(fWidth, fHeight)
	hHandleTotal:SetSize(fWidth, fHeight)
	hHandleTotal:FormatAllItemPos()
	hFrame:SetSize(fWidth, fHeight)
	local hMinimize = hFrame:Lookup("CheckBox_Minimize")
	local fMinimizeX, fMinimizeY = hMinimize:GetRelPos()
	fMinimizeX = fWidth - 30
	hMinimize:SetRelPos(fMinimizeX, fMinimizeY)
	
	QuestTraceList.UpdateAnchor(hFrame)
	UpdateCustomModeWindow(hFrame)
	hFrame:EnableDrag(true)
end

function QuestTraceList.UpdateQuestObjective(text, questTrace, szObjective)
	text:SetText(QuestAcceptPanel.GetPureText(szObjective, true).."\n")
	if questTrace.finish then
		text:SetFontScheme(44)
	else
		text:SetFontScheme(45)
	end
end

function QuestTraceList.UpdateQuestFinishedObjective(hText, szFinishedObjective)
	hText:SetText(QuestAcceptPanel.GetPureText(szFinishedObjective, true).."\n")
	hText:SetFontScheme(44)
end

function QuestTraceList.UpdateQuestFailedObjective(hText, dwQuestID, szFailedObjective)
    local szText = ""
    if szFailedObjective ~= "" then
        szText = szFailedObjective
    else
        local hQuestInfo = GetQuestInfo(dwQuestID)
        local szNpcName = Table_GetNpcTemplateName(hQuestInfo.dwStartNpcTemplateID)
        if szNpcName ~= "" then
            szText = FormatString(g_tStrings.QUEST_FAILED_BOJECTIVE_FOR_NPC, szNpcName)
        else
            szText = g_tStrings.QUEST_FAILED_BOJECTIVE_FOR_NOT_NPC
        end
    end
    hText:SetText(QuestAcceptPanel.GetPureText(szText, true).."\n")
	hText:SetFontScheme(44)
end

function QuestTraceList.UpdateQuestNpc(text, state)
	state.have = math.min(state.have, state.need)
	local szName = Table_GetNpcTemplateName(state.template_id)
	if not szName or szName == "" then
		szName = "Unknown Npc"
	end
	local szText, nFont = szName .."："..state.have.."/"..state.need, 45
	if state.have >= state.need then
		szText, nFont = szText..g_tStrings.STR_QUEST_QUEST_WAS_FINISHED, 44
	end
	text:SetText(szText.."\n")
	text:SetFontScheme(nFont)		
end

function QuestTraceList.UpdateQuestItem(text, state)
	local itemInfo = GetItemInfo(state.type, state.index)
	local nBookID = state.need
	if itemInfo.nGenre == ITEM_GENRE.BOOK then
		state.need = 1
	end	
	state.have = math.min(state.have, state.need)
	local szName = "Unknown Item"
	if itemInfo then
		szName = GetItemNameByItemInfo(itemInfo, nBookID)
	end
	local szText, nFont = szName.."："..state.have.."/"..state.need, 45
	if state.have >= state.need then
		szText, nFont = szText..g_tStrings.STR_QUEST_QUEST_WAS_FINISHED, 44
	end
	text:SetText(szText.."\n")
	text:SetFontScheme(nFont)
end

function QuestTraceList.UpdateQuestState(text, state, tQuestStringInfo)
	local szName = tQuestStringInfo["szQuestValueStr" .. (state.i + 1)]
	state.have = math.min(state.have, state.need)
	local szText, nFont = szName.."："..state.have.."/"..state.need, 45
	if state.have >= state.need then
		szText, nFont = szText..g_tStrings.STR_QUEST_QUEST_WAS_FINISHED, 44
	end
	text:SetText(szText.."\n")
	text:SetFontScheme(nFont)		
end

function QuestTraceList.UpdateQuestName(hName, questTrace, tQuestStringInfo)
	local text = hName:Lookup(0)
	local image = hName:Lookup(1)
	if QuestTraceList.bShowLinkQuest then
		image:Show()
	else
		image:Hide()
	end
	image.bQuestButton = true
	if questTrace.finish then
		--if questTrace.have_trace then
			text:SetText(tQuestStringInfo.szName..g_tStrings.STR_QUEST_QUEST_CAN_FINISH)
			text:SetFontScheme(65)
		--else
		--	text:SetText(tQuestStringInfo.szName)
		--	text:SetFontScheme(65)
		--end
	elseif questTrace.fail then
		text:SetText(tQuestStringInfo.szName..g_tStrings.STR_QUEST_QUEST_WAS_FAILED)
		text:SetFontScheme(65)
	else
		text:SetText(tQuestStringInfo.szName)
		text:SetFontScheme(65)
	end
	hName:FormatAllItemPos()
	hName:SetSizeByAllItemSize()
end

function QuestTraceList.UpdateQuestTime(text, questTrace)
	local h, m, s = GetTimeToHourMinuteSecond(questTrace.time)
	local szTime = ""
	
	if questTrace.fail then
		h, m, s = 0, 0, 0
	end
	
	if h > 0 then
		szTime = szTime..h..g_tStrings.STR_BUFF_H_TIME_H
	end
	if h > 0 or m > 0 then
		szTime = szTime..m..g_tStrings.STR_BUFF_H_TIME_M_SHORT
	end
	szTime = szTime..s..g_tStrings.STR_BUFF_H_TIME_S
	
	text:SetText(g_tStrings.STR_QUEST_TIME_LIMIT..szTime.."\n")
	text:SetFontScheme(0)
end

function QuestTraceList.RemoveTraceQuest(hFrame, dwQuestID)
	local hTrace = hFrame:Lookup("", "Handle_Info")
	local bRemove = false
	local nCount = hTrace:GetItemCount()
	for i = nCount - 1, 0, -1 do
		local hQuest = hTrace:Lookup(i)
		if hQuest.dwQuestID == dwQuestID then
			hTrace:RemoveItem(i)
			bRemove = true
			break
		end
	end
	if not bRemove then
		return
	end
	nCount = hTrace:GetItemCount()
	hFrame.nCount = hFrame.nCount - 1

	QuestTraceList.UpdateSize(hFrame)
	QuestTraceList.SaveTraceQuest(hFrame)
	
	local argS0, argS1 = arg0, arg1
	arg0, arg1 = dwQuestID, false
	FireEvent("ON_TRACE_QUEST")
	arg0, arg1 = argS0, argS1	
end

function QuestTraceList.OnItemLButtonDown()
	local szName = this:GetName()
	if szName == "Box_UseItem" then
		this:SetObjectPressed(1)
	elseif IsCtrlKeyDown() then
		if IsGMPanelReceiveQuest() then
			GMPanel_LinkQuest(this.dwQuestID)
		else
			EditBox_AppendLinkQuest(this.dwQuestID)
		end
	end
	if this.bQuestButton then
		this:SetFrame(34)
	end
end

function QuestTraceList.OnItemLButtonUp()
	local szName = this:GetName()
	if szName == "Box_UseItem" then
		this:SetObjectPressed(0)
	elseif this.bQuestButton then
		this:SetFrame(33)
	end
end

function QuestTraceList.OnItemRButtonDown()
	local szName = this:GetName()
	if szName == "Box_UseItem" then
		this:SetObjectPressed(1)
	end
end

function QuestTraceList.OnItemRButtonUp()
	local szName = this:GetName()
	if szName == "Box_UseItem" then
		this:SetObjectPressed(0)
	end
end

function QuestTraceList.OnItemLButtonClick()
	local szName = this:GetName()
	if szName == "Box_UseItem" then
		local hPlayer = GetClientPlayer()
		if hPlayer then
			local _, nVersion, dwType, dwIndex = this:GetObjectData()
	    	local dwBox, dwX = hPlayer.GetItemPos(dwType, dwIndex)
	    	if dwBox and dwX then
	    		OnUseItem(dwBox, dwX, this)
	    	end
		end
	elseif this.bQuestButton then
		local dwQuestID = this:GetParent().dwQuestID
		MiddleMap_OpenQuestMap(dwQuestID)
	end
end

function QuestTraceList.OnItemRButtonClick()
		local szName = this:GetName()
	if szName == "Box_UseItem" then
		local hPlayer = GetClientPlayer()
		if hPlayer then
			local _, nVersion, dwType, dwIndex = this:GetObjectData()
	    	local dwBox, dwX = hPlayer.GetItemPos(dwType, dwIndex)
	    	if dwBox and dwX then
	    		OnUseItem(dwBox, dwX, this)
	    	end
		end
	end
end

function QuestTraceList.OnItemLButtonDBClick()
	if this.bQuestButton then
		local dwQuestID = this:GetParent().dwQuestID
		if IsQuestPanelOpened(dwQuestID) then
			CloseQuestPanel()
		else
			OpenQuestPanel(false, dwQuestID)
		end
	else
		local dwQuestID = this.dwQuestID
		if IsQuestPanelOpened(dwQuestID) then
			CloseQuestPanel()
		else
			OpenQuestPanel(false, dwQuestID)
		end
	end
end

function QuestTraceList.OnItemMouseEnter()
	local szName = this:GetName()
	local szTip
	local x, y = this:GetAbsPos()
	local w, h = this:GetSize()
	if szName == "Image_CompassBg" and this.bNoQuestGPS then
		szTip = GetFormatText(g_tStrings.QUEST_TRACE_NO_GPS)
	elseif szName == "Image_PointGreen" or szName == "Image_PointRed" then
		szTip = GetFormatText(this.szName)
	elseif szName == "Image_Player" then
		local hPlayer = GetClientPlayer()
		local hScene = hPlayer.GetScene()
		local szMap = Table_GetMapName(hScene.dwMapID)
		local szTraceState = this:GetParent().szTraceState
		if szTraceState == "UnFinish_Target" then
			szTip = GetFormatText(g_tStrings.QUEST_TRACE_UNFINISH_TARGET_TIP)
		elseif szTraceState == "Finish_Target" then
			szTip = GetFormatText(g_tStrings.QUEST_TRACE_FINISH_TARGET_TIP)
		end
	elseif szName == "Image_Carriage" then
		local hGPS = this:GetParent()
		local szMap = ""
		for k in pairs(hGPS.tMaps) do
			if szMap ~= "" then
				szMap = szMap .. g_tStrings.STR_COMMA
			end
			szMap = szMap .. Table_GetMapName(k)
		end
		local szTraceState = hGPS.szTraceState
		if szTraceState == "UnFinish_Carriage" then
			szTip = GetFormatText(FormatString(g_tStrings.QUEST_TRACE_UNFINISH_CARRIAGE_TIP, szMap))
		elseif szTraceState == "Finish_Carriage" then
			szTip = GetFormatText(FormatString(g_tStrings.QUEST_TRACE_FINISH_CARRIAGE_DUNGEON_TIP, szMap))
		end
	elseif szName == "Image_Dungeon" then
		local hGPS = this:GetParent()
		local szMap = ""
		for k in pairs(hGPS.tMaps) do
			if szMap ~= "" then
				szMap = szMap .. g_tStrings.STR_COMMA
			end
			szMap = szMap .. Table_GetMapName(k)
		end
		local szTraceState = hGPS.szTraceState
		if szTraceState == "UnFinish_Dungeon" then
			szTip = GetFormatText(g_tStrings.QUEST_TRACE_UNFINISH_DUNGEON_TIP .. szMap)
		elseif szTraceState == "Finish_Dungeon" then
			szTip = GetFormatText(FormatString(g_tStrings.QUEST_TRACE_FINISH_CARRIAGE_DUNGEON_TIP, szMap))
		end
	elseif szName == "Image_Fail" then
		szTip = GetFormatText(g_tStrings.QUEST_TRACE_FAILD_TIP)
	elseif szName == "Text_Distance" then
		local hGPS = this:GetParent()
		if hGPS.fDistance then
			local fDistance = hGPS.fDistance / 64
			szDistance = FixFloat(fDistance, 0)
			szTip = GetFormatText(FormatString(g_tStrings.QUEST_TRACE_DISTANCE, szDistance))
		end
	elseif szName == "Box_UseItem" then
		local _, nVersion, dwType, dwIndex = this:GetObjectData()
		OutputItemTip(UI_OBJECT_ITEM_INFO, nVersion, dwType, dwIndex, {x, y, w, h})
		this:SetObjectMouseOver(1)
		this.bTip = true
	elseif this.bName then
		this:Lookup(1):Show()
	end
	
	if szTip and szTip ~= "" then
		w = w + 20
		h = h + 20
		this.bTip = true
		OutputTip(szTip, 200, {x, y, w, h})
	end
end

function QuestTraceList.OnItemMouseLeave()
	local szName = this:GetName()
	if szName == "Box_UseItem" then
		this:SetObjectMouseOver(0)
	elseif this.bTip then
		HideTip()
	elseif this.bName then
		if not QuestTraceList.bShowLinkQuest then 
			this:Lookup(1):Hide()
		end
	end
	
end

function AddTraceQuest(dwQuestID)
	local frame = Station.Lookup("Normal/QuestTraceList")
	if frame then
		QuestTraceList.AddTraceQuest(frame, dwQuestID)
	end
end

function RemoveTraceQuest(dwQuestID)
	local frame = Station.Lookup("Normal/QuestTraceList")
	if frame then
		QuestTraceList.RemoveTraceQuest(frame, dwQuestID)
	end
end

function SetQuestTraceCount(nCount)
	if nCount < 1 then
		nCount = 1
	elseif nCount > 10 then
		nCount = 10
	end
	QuestTraceList.nDefaultCount = nCount
	FireEvent("QUEST_TRACE_LIST_COUNT_CHANGED")
end


function GetQuestTraceCount()
	return QuestTraceList.nDefaultCount
end

function IsTraceQuest(dwQuestID)
	return QuestTraceList.IsTraceQuest(dwQuestID)
end

function SetAutoTraceQuest(bAuto)
	if QuestTraceList.bAuto == bAuto then
		return
	end
	
	QuestTraceList.bAuto = bAuto
	
	FireEvent("ON_SET_AUTO_TRACE_QUEST")
end

function IsAutoTraceQuest(bAuto)
	return QuestTraceList.bAuto
end

function SetQuestTraceListAnchor(Anchor)
	QuestTraceList.Anchor = Anchor
	
	FireEvent("QUEST_TRACE_ANCHOR_CHANGED")
end

function GetQuestTraceListAnchor(Anchor)
	return QuestTraceList.Anchor
end

function QuestTraceList_SetAnchorDefault()
	QuestTraceList.Anchor.s = QuestTraceList.DefaultAnchor.s
	QuestTraceList.Anchor.r = QuestTraceList.DefaultAnchor.r
	QuestTraceList.Anchor.x = QuestTraceList.DefaultAnchor.x
	QuestTraceList.Anchor.y = QuestTraceList.DefaultAnchor.y
	FireEvent("QUEST_TRACE_ANCHOR_CHANGED")
end

RegisterEvent("CUSTOM_UI_MODE_SET_DEFAULT", QuestTraceList_SetAnchorDefault)

function IsShowTeamateQuestTrace()
	return QuestTraceList.bShowTeamateQuestTrace
end

function SetShowTeamateQuestTrace(bShow)
	QuestTraceList.bShowTeamateQuestTrace = bShow
end


function ShareQuestTrace(szText, dwQuestID, szEnd, bQuestData)
	local player = GetClientPlayer()
	if player and player.IsInParty() then
		if dwQuestID and bQuestData then
			
			local bShield = false
			for _, dwShieldQuestID in ipairs(tShieldTraceQuest) do
				if dwQuestID == dwShieldQuestID then
					bShield = true
					break
				end
			end
			if bShield then
				return 
			end
		end
		
		local t = 
		{
			{type = "text", text = "BG_CHANNEL_MSG"},
			{type = "text", text = "QUEST_SHARE_INFO"},
			{type = "text", text = szText},
		}
		
		if dwQuestID then
			table.insert(t, {type = "text", text = tostring(dwQuestID)})
		end
		
		if szEnd then
			table.insert(t, {type = "text", text = szEnd})
		end
		player.Talk(PLAYER_TALK_CHANNEL.TEAM, "", t)
	end
end

