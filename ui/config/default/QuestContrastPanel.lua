local SCROLL_STEP_SIZE = 10

QuestContrastPanel = 
{
	tCheckAccept = { Normal = 36, NormalOver = 37, Check = 36, CheckOver = 37 },
	tCheckFinish = { Normal = 32, NormalOver = 33, Check = 32, CheckOver = 33 },
	tCheckTarget = { Normal = 40, NormalOver = 41, Check = 40, CheckOver = 41 }
}

function QuestContrastPanel.OnFrameCreate()
	this:RegisterEvent("UI_SCALED")
	this:RegisterEvent("PEEK_PLAYER_QUEST")
	
	InitFrameAutoPosInfo(this, 2, nil, nil, function() CloseQuestContrastPanel(true) end)
end

function QuestContrastPanel.OnEvent(szEvent)
	if szEvent == "UI_SCALED" then
		QuestContrastPanel.UpdateListScrollInfo(this:Lookup("", "Handle_List"))
		QuestContrastPanel.UpdateInfoScrollInfo(this:Lookup("", "Handle_Info"))
	elseif szEvent == "PEEK_PLAYER_QUEST" then
		QuestContrastPanel.UpdateQuestList(this)
	end
end

function QuestContrastPanel.OnItemLButtonClick()
	if this.bTrace then
		local hFrame = this:GetRoot()
		OnMarkQuestTarget(hFrame.dwQuestID, this.szType, this.nIndex)
	end
end

function QuestContrastPanel.OnItemLButtonDBClick()
	if this.bGroup or this.bTitle then
		return QuestContrastPanel.OnItemLButtonDown()
	elseif this.bTrace then
		return QuestContrastPanel.OnItemLButtonClick()
	end
end

function QuestContrastPanel.OnItemLButtonDown()
	if this.bGroup then
		local hList = this:GetParent()
		local hFrame = this:GetRoot()
		if this:IsExpand() then
			this:Collapse()
			hFrame.tCollapse[this.szName] = true
		else
			this:Expand()
			hFrame.tCollapse[this.szName] = nil
		end
		QuestContrastPanel.UpdateListScrollInfo(hList)
		PlaySound(SOUND.UI_SOUND,g_sound.Button)
	elseif this.bTitle then
		if IsCtrlKeyDown() then
			if IsGMPanelReceiveQuest() then
				GMPanel_LinkQuest(this.dwQuestID)
			else
				EditBox_AppendLinkQuest(this.dwQuestID)
			end
		end
		QuestContrastPanel.Select(this, true)
	end
end

function QuestContrastPanel.OnItemMouseEnter()
	if this:GetName() == "Image_Assist" then
		local szTip = nil
		if this.bCanAssist then
			szTip = g_tStrings.QUEST_CAN_ASSIST
		else
			szTip = g_tStrings.ASSIST_QUEST
		end
		local fPosX, fPosY = this:GetAbsPos()
		local fWidth, fHeight = this:GetSize()
		OutputTip("<text>text="..EncodeComponentsString(szTip).." font=100 </text>", 345, {fPosX, fPosY, fWidth, fHeight})
	elseif this.bTitle then
		this.bOver = true
		QuestContrastPanel.UpdateQuestTitle(this)
		if this.dwQuestID then
			local hFrame = this:GetRoot()
			local hPlayer = GetPlayer(hFrame.dwTargetID)
			local nExperience, nRepeatCutPercent, nLevelCutPercent = hPlayer.GetQuestExpAttenuation(this.dwQuestID)
			local szMsg = ""
			if nRepeatCutPercent ~= 100 then
				szMsg = FormatString(g_tStrings.QUEST_WHO_EXHAUST_MSG1, hPlayer.szName) .. (100 - nRepeatCutPercent) .. "%"..g_tStrings.STR_FULL_STOP.."\n"
			end
			if nLevelCutPercent ~= 100 then
				szMsg = szMsg .. FormatString(g_tStrings.QUEST_WHO_EXHAUST_MSG2, hPlayer.szName) .. (100 - nLevelCutPercent) .. "%" ..g_tStrings.STR_FULL_STOP.."\n"
			end
			if szMsg ~= "" then
				local fPosX, fPosY = this:GetAbsPos()
				local fWidth, fHeight = this:GetSize()
				OutputTip("<text>text="..EncodeComponentsString(szMsg).." font=100 </text>", 345, {fPosX, fPosY, fWidth, fHeight})
			end
		end
	elseif this.bTrace then
		this.bOver = true
		QuestContrastPanel.UpdateQuestTraceImageState(this)
		local fPosX, fPosY = this:GetAbsPos()
		local fWidth, fHeight = this:GetSize()
		local szTip = nil
		if this.bAccept then
			szTip = g_tStrings.QUEST_LOOKUP_ACCEPT_PLACE
		elseif this.bFinish then
			szTip = g_tStrings.QUEST_LOOKUP_FINISH_PLACE
		else
			szTip = g_tStrings.QUEST_LOOKUP_TARGET
		end
		OutputTip("<text>text="..EncodeComponentsString(szTip).." font=100 </text>", 345, {fPosX, fPosY, fWidth, fHeight})
	end
end

function QuestContrastPanel.OnItemMouseLeave()
	if this.bTitle then
		this.bOver = false
		QuestContrastPanel.UpdateQuestTitle(this)
		HideTip()
	elseif this.bTrace then
		this.bOver = false
		QuestContrastPanel.UpdateQuestTraceImageState(this)
		HideTip()
	end
end

function QuestContrastPanel.OnItemMouseWheel()
	local nDistance = Station.GetMessageWheelDelta()
	local hFrame = this:GetRoot()
	if this:GetName() == "Handle_List" then
		hFrame:Lookup("Scroll_List"):ScrollNext(nDistance)
	elseif this:GetName() == "Handle_Info" then
		hFrame:Lookup("Scroll_Info"):ScrollNext(nDistance * 100)
	end
	return true
end

function QuestContrastPanel.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_Close" or szName == "Btn_Close01" then
		CloseQuestContrastPanel()
	end	
end

function QuestContrastPanel.OnLButtonDown()
	QuestContrastPanel.OnLButtonHold()
end

function QuestContrastPanel.OnLButtonHold()
	local hFrame = this:GetRoot()
	local szName = this:GetName()
    if szName == "Btn_Up_List" then
		hFrame:Lookup("Scroll_List"):ScrollPrev()
	elseif szName == "Btn_Down_List" then
		hFrame:Lookup("Scroll_List"):ScrollNext()
	elseif szName == "Btn_Up_Info" then
		hFrame:Lookup("Scroll_Info"):ScrollPrev(100)
	elseif szName == "Btn_Down_Info" then
		hFrame:Lookup("Scroll_Info"):ScrollNext(100)
	end
end

function QuestContrastPanel.OnScrollBarPosChanged()
	local nCurrentValue = this:GetScrollPos()
	local hFrame = this:GetParent()
	local szName = this:GetName()
	if szName == "Scroll_List" then 
		if nCurrentValue == 0 then
			hFrame:Lookup("Btn_Up_List"):Enable(false)
		else
			hFrame:Lookup("Btn_Up_List"):Enable(true)
		end
		
		if nCurrentValue == this:GetStepCount() then
			hFrame:Lookup("Btn_Down_List"):Enable(false)
		else
			hFrame:Lookup("Btn_Down_List"):Enable(true)
		end
	    hFrame:Lookup("", "Handle_List"):SetItemStartRelPos(0, - nCurrentValue * SCROLL_STEP_SIZE)
	elseif szName == "Scroll_Info" then 
		if nCurrentValue == 0 then
			hFrame:Lookup("Btn_Up_Info"):Enable(false)
		else
			hFrame:Lookup("Btn_Up_Info"):Enable(true)
		end
		local nTotal = this:GetStepCount()
		if nCurrentValue == nTotal then
			hFrame:Lookup("Btn_Down_Info"):Enable(false)
		else
			hFrame:Lookup("Btn_Down_Info"):Enable(true)
		end
		if nTotal == 0 then
			hFrame:Lookup("", "Image_InfoScrollBg"):SetPercentage(0)
		else
			hFrame:Lookup("", "Image_InfoScrollBg"):SetPercentage(nCurrentValue / nTotal)
		end
		local nStartY = - math.floor(nCurrentValue / 100) * 10
	    hFrame:Lookup("", "Handle_Info"):SetItemStartRelPos(0, nStartY)
	    hFrame:Lookup("", "Handle_TraceInfo"):SetItemStartRelPos(0, nStartY)
	end
end

function QuestContrastPanel.UpdateQuestList(hFrame)
	local hPlayer = GetPlayer(hFrame.dwTargetID)
	
	local hHandle = hFrame:Lookup("", "")
	local hList = hHandle:Lookup("Handle_List")
	hList:Clear()
	local szIniFile = "UI/Config/Default/QuestContrastPanel.ini"
	
	local bSelect = false
	local tCollapse = hFrame.tCollapse or {}
	local tQuest = hPlayer.GetQuestTree()
	local nQuestCount = 0
	for dwClassID, tGroup in pairs(tQuest) do
		local hGroup = hList:AppendItemFromIni(szIniFile, "TreeLeaf_Class")
		local szName = Table_GetQuestClass(dwClassID)
		hGroup:Lookup("Text_ClassName"):SetText(szName)
		if tCollapse[szName] then
			hGroup:Collapse()
		else
			hGroup:Expand()
		end
		hGroup.bGroup = true
		hGroup.szName = szName
		for _, nQuesIndex in pairs(tGroup) do
			nQuestCount = nQuestCount + 1
			local dwQuestID = hPlayer.GetQuestID(nQuesIndex)
			local hQuestInfo = GetQuestInfo(dwQuestID)
			local hQuest = hList:AppendItemFromIni(szIniFile, "TreeLeaf_Name")
			hQuest.nQuesIndex = nQuesIndex
			hQuest.dwQuestID = dwQuestID
			hQuest.nLevel = hQuestInfo.nLevel
			hQuest.bTitle = true
			if not hFrame.dwQuestID or hFrame.dwQuestID == dwQuestID then
				QuestContrastPanel.Select(hQuest)
				bSelect = true
			else
				QuestContrastPanel.UpdateQuestTitle(hQuest)
			end
		end
	end
	hFrame.tCollapse = tCollapse
	QuestContrastPanel.UpdateListScrollInfo(hList, bHome)
	if not bSelect then	
		local nCount = hList:GetItemCount()
		if nCount == 0 then
			hFrame.dwQuestID = nil
			QuestContrastPanel.UpdateQuestInfo(hFrame, true)
		else
			for i = 0, nCount - 1 do
				local hQuest = hList:Lookup(i)
				if hQuest.bTitle then
					QuestContrastPanel.Select(hQuest, true)
					break
				end
			end
		end
	end
	
	hHandle:Lookup("Text_Title"):SetText(FormatString(g_tStrings.QUEST_CONTRAST_LIST, hPlayer.szName, nQuestCount))
end

function QuestContrastPanel.Select(hSelect, bHome)
	local hList = hSelect:GetParent()
	local hFrame = hList:GetRoot()
	local nCount = hList:GetItemCount()
	for i = 0, nCount - 1 do
		local hQuest = hList:Lookup(i)
		if hQuest.bSelect then
			hQuest.bSelect = false
			QuestContrastPanel.UpdateQuestTitle(hQuest)
			break
		end
	end
	hSelect.bSelect = true
	hFrame.dwQuestID = hSelect.dwQuestID
	QuestContrastPanel.UpdateQuestTitle(hSelect)
	QuestContrastPanel.UpdateQuestInfo(hFrame, bHome)
end

function QuestContrastPanel.UpdateQuestTitle(hQuest)
	local hFrame = hQuest:GetRoot()
	local hPlayer = GetPlayer(hFrame.dwTargetID)
	local hTextTrace = hQuest:Lookup("Text_QuestTrace")
	local hTextName = hQuest:Lookup("Text_QuestName")
	local hTextState = hQuest:Lookup("Text_QuestState")
	local hImgSelect = hQuest:Lookup("Image_Sel")
	
	if hQuest.bSelect then
		hImgSelect:Show()
		hImgSelect:SetAlpha(255)		
	elseif hQuest.bOver then
		hImgSelect:Show()
		hImgSelect:SetAlpha(128)
	else
		hImgSelect:Hide()
	end
	
	local nFrame, nFont = GetQuestIconAndFont(hQuest.dwQuestID, hPlayer)
	hImgSelect:SetFrame(nFrame)
	hTextTrace:SetFontScheme(nFont)
	hTextName:SetFontScheme(nFont)
	hTextState:SetFontScheme(nFont)
	
	local hQuestTrace = hPlayer.GetQuestTraceInfo(hQuest.dwQuestID)
	local tQuestStringInfo = Table_GetQuestStringInfo(hQuest.dwQuestID)
	hTextName:SetText(tQuestStringInfo.szName)
	
	if hQuestTrace.finish then
		if hQuestTrace.have_trace then
			hTextState:SetText(g_tStrings.STR_QUEST_QUEST_WAS_FINISHED)
		elseif tQuestStringInfo.szQuestDiff then
			hTextState:SetText(tQuestStringInfo.szQuestDiff)
		else
			hTextState:SetText("")
		end
	elseif hQuestTrace.fail then
		hTextState:SetText(g_tStrings.STR_QUEST_QUEST_WAS_FAILED)
	elseif tQuestStringInfo.szQuestDiff then
		hTextState:SetText(tQuestStringInfo.szQuestDiff)
	else
		hTextState:SetText("")
	end
	
	local hClientPlayer = GetClientPlayer()
    local eState = hClientPlayer.GetQuestState(hQuest.dwQuestID)
    
	local hImageAssist = hQuest:Lookup("Image_Assist")
	if hQuestTrace.assist then
		hImageAssist:Show()
		if eState == QUEST_STATE.FINISHED then
			hImageAssist:SetFrame(64)
			hImageAssist.bCanAssist = true
		else
			hImageAssist:SetFrame(62)
			hImageAssist.bCanAssist = false
		end
	else
		hImageAssist:Hide()
	end
end

function QuestContrastPanel.UpdateQuestInfo(hFrame, bHome)
	local hHandle = hFrame:Lookup("", "")
	local hInfo = hHandle:Lookup("Handle_Info")
	hInfo:Clear()
	
	local hTextNoQuest = hHandle:Lookup("Text_NoQuest")
	if not hFrame.dwQuestID then
		QuestContrastPanel.UpdateInfoScrollInfo(hInfo, bHome)
		local hTraceInfo = hFrame:Lookup("", "Handle_TraceInfo")
		local hImgAccept = hTraceInfo:Lookup("Image_Accept")
		hImgAccept:Hide()
		local hImgFinish = hTraceInfo:Lookup("Image_Finish")
		hImgFinish:Hide()
		hTextNoQuest:Show()
		return
	end
	hTextNoQuest:Hide()
	
	local hPlayer = GetPlayer(hFrame.dwTargetID)
	local hQuestTrace = hPlayer.GetQuestTraceInfo(hFrame.dwQuestID)
	local tQuestStringInfo = Table_GetQuestStringInfo(hFrame.dwQuestID)
	
	local szQuestName = GetFormatText(tQuestStringInfo.szName.."\n\n", 1)
	hInfo:AppendItemFromString(szQuestName)
	QuestAcceptPanel.EncodeString(hInfo, tQuestStringInfo.szObjective.."\n\n", 160, hPlayer)
	QuestContrastPanel.AppendQuestTrace(hInfo, hQuestTrace, tQuestStringInfo)
	
	local szQuestDesc = GetFormatText(g_tStrings.STR_QUEST_QUEST_DESCRIPTION, 1)
	hInfo:AppendItemFromString(szQuestDesc)
    QuestAcceptPanel.EncodeString(hInfo, tQuestStringInfo.szDescription.."\n\n", 160, hPlayer)
	QuestContrastPanel.UpdateInfoScrollInfo(hInfo, bHome)
	
	QuestContrastPanel.UpdateQuestTraceImage(hFrame)	
end

function QuestContrastPanel.AppendQuestTrace(hInfo, hQuestTrace, tQuestStringInfo)
	local dwQuestID = hInfo:GetRoot().dwQuestID
	if hQuestTrace.time then
		local nHour, nMinute, nSecond = GetTimeToHourMinuteSecond(hQuestTrace.time)
		local szTime = ""
		if hQuestTrace.fail then
			nHour, nMinute, nSecond = 0, 0, 0
		end
		if nHour > 0 then
			szTime = szTime..nHour..g_tStrings.STR_BUFF_H_TIME_H
		end
		if nHour > 0 or nMinute > 0 then
			szTime = szTime..nMinute..g_tStrings.STR_BUFF_H_TIME_M_SHORT
		end
		szTime = szTime..nSecond..g_tStrings.STR_BUFF_H_TIME_S
		szTime = g_tStrings.STR_TWO_CHINESE_SPACE .. g_tStrings.STR_QUEST_TIME_LIMIT .. szTime .. "\n"
		szTime = GetFormatText(szTime, 0)
		hInfo:AppendItemFromString(szTime)
	end

	for _, v in pairs(hQuestTrace.quest_state) do
		v.have = math.min(v.have, v.need)
		local szName = tQuestStringInfo["szQuestValueStr" .. (v.i + 1)]
		local szText =  g_tStrings.STR_TWO_CHINESE_SPACE..szName.."£º"..v.have.."/"..v.need
		local nFont = 63
		if v.have >= v.need then
			szText = szText..g_tStrings.STR_QUEST_QUEST_WAS_FINISHED
			nFont = 1
		end
		hInfo:AppendItemFromString(GetFormatText(szText, nFont))
		
		if Table_GetQuestPosInfo(dwQuestID, "quest_state", v.i) then
			hInfo:AppendItemFromString(GetFormatImage("ui/Image/QuestPanel/QuestPanel.UITex", 13, 35, 24, 341))
			local hImage = hInfo:Lookup(hInfo:GetItemCount() - 1)
			hImage.bTrace = true
			hImage.szType = "quest_state"
			hImage.nIndex = v.i
		end
		
		hInfo:AppendItemFromString(GetFormatText("\n", 0))
	end
	
	for _, v in pairs(hQuestTrace.kill_npc) do
		v.have = math.min(v.have, v.need)
		local szName = Table_GetNpcTemplateName(v.template_id)
		if not szName or szName == "" then
			szName = "Unknown Npc"
		end
		local szText = g_tStrings.STR_TWO_CHINESE_SPACE.. szName .."£º"..v.have.."/"..v.need
		local nFont = 63
		if v.have >= v.need then
			szText = szText..g_tStrings.STR_QUEST_QUEST_WAS_FINISHED
			nFont = 1
		end
		hInfo:AppendItemFromString(GetFormatText(szText, nFont))
		
		if Table_GetQuestPosInfo(dwQuestID, "kill_npc", v.i) then
			hInfo:AppendItemFromString(GetFormatImage("ui/Image/QuestPanel/QuestPanel.UITex", 13, 35, 24, 341))
			local hImage = hInfo:Lookup(hInfo:GetItemCount() - 1)
			hImage.bTrace = true
			hImage.szType = "kill_npc"
			hImage.nIndex = v.i
		end
		
		hInfo:AppendItemFromString(GetFormatText("\n", 0))
	end

	for _, v in pairs(hQuestTrace.need_item) do
		local hItemInfo = GetItemInfo(v.type, v.index)
		local nBookID = v.need
		if hItemInfo.nGenre == ITEM_GENRE.BOOK then
			v.need = 1
		end
		v.have = math.min(v.have, v.need)
		local szName = "Unknown Item"
		if hItemInfo then
			szName = GetItemNameByItemInfo(hItemInfo, nBookID)
		end
				
		local szText = g_tStrings.STR_TWO_CHINESE_SPACE..szName.."£º" .. g_tStrings.QUEST_DOING
		local nFont = 63
		hInfo:AppendItemFromString(GetFormatText(szText, nFont))
		
		if Table_GetQuestPosInfo(dwQuestID, "need_item", v.i) then
			hInfo:AppendItemFromString(GetFormatImage("ui/Image/QuestPanel/QuestPanel.UITex", 13, 35, 24, 341))
			local hImage = hInfo:Lookup(hInfo:GetItemCount() - 1)
			hImage.bTrace = true
			hImage.szType = "need_item"
			hImage.nIndex = v.i
		end
		
		hInfo:AppendItemFromString(GetFormatText("\n", 0))
	end
end

function QuestContrastPanel.UpdateQuestTraceImage(hFrame, hQuestTrace)
	local dwQuestID = hFrame.dwQuestID
	hInfo = hFrame:Lookup("", "Handle_Info")
	local nCount = hInfo:GetItemCount()
	for i = 0, nCount - 1 do
		local hImage = hInfo:Lookup(i)
		if hImage.bTrace then
			hImage.bOnTrace = IsMarkQuestTargetPlace(dwQuestID, hImage.szType, hImage.nIndex)
			QuestContrastPanel.UpdateQuestTraceImageState(hImage)
		end
	end
	
	local hTraceInfo = hFrame:Lookup("", "Handle_TraceInfo")
	local hImgAccept = hTraceInfo:Lookup("Image_Accept")
	local hImgFinish = hTraceInfo:Lookup("Image_Finish")
	if dwQuestID then
		if Table_GetQuestPosInfo(dwQuestID, "accept", 0) then
			hImgAccept:Show()
			hImgAccept.bTrace = true
			hImgAccept.bAccept = true
			hImgAccept.szType = "accept"
			hImgAccept.nIndex = 0
			hImgAccept.bOnTrace = IsMarkQuestTargetPlace(dwQuestID, "accept", 0)
			QuestContrastPanel.UpdateQuestTraceImageState(hImgAccept)
		else
			hImgAccept:Hide()
			hImgAccept.bOver = false
			hImgAccept.bOnTrace = false
		end
	
		if Table_GetQuestPosInfo(dwQuestID, "finish", 0) then
			hImgFinish:Show()
			hImgFinish.bTrace = true
			hImgFinish.bFinish = true
			hImgFinish.szType = "finish"
			hImgFinish.nIndex = 0
			hImgFinish.bOnTrace = IsMarkQuestTargetPlace(dwQuestID, "finish", 0)
			QuestContrastPanel.UpdateQuestTraceImageState(hImgFinish)
		else		
			hImgFinish:Hide()
			hImgFinish.bOver = false
			hImgFinish.bOnTrace = false
		end
	else
		hImgAccept:Hide()
		hImgAccept.bOver = false
		hImgAccept.bOnTrace = false
		hImgFinish:Hide()
		hImgFinish.bOver = false
		hImgFinish.bOnTrace = false
	end	
end

function QuestContrastPanel.UpdateQuestTraceImageState(hImage)
	local tCheck = nil
	if hImage.bAccept then
		tCheck = QuestContrastPanel.tCheckAccept
	elseif hImage.bFinish then
		tCheck = QuestContrastPanel.tCheckFinish
	else
		tCheck = QuestContrastPanel.tCheckTarget
	end
	if hImage.bOnTrace then
		if hImage.bOver then
			hImage:SetFrame(tCheck.CheckOver)
		else
			hImage:SetFrame(tCheck.Check)
		end
	else
		if hImage.bOver then
			hImage:SetFrame(tCheck.NormalOver)
		else
			hImage:SetFrame(tCheck.Normal)
		end
	end
end

function QuestContrastPanel.UpdateListScrollInfo(hList, bHome)
	local hFrame = hList:GetRoot()
	local hScroll = hFrame:Lookup("Scroll_List")
	hList:FormatAllItemPos()
	local fAllWidth, fAllHeight = hList:GetAllItemSize()
    local fWidth, fHeight = hList:GetSize()
    local nCountStep = math.ceil((fAllHeight - fHeight) / SCROLL_STEP_SIZE)
    hScroll:SetStepCount(nCountStep)
    if nCountStep > 0 then
    	hScroll:Show()
    	hFrame:Lookup("Btn_Up_List"):Show()
    	hFrame:Lookup("Btn_Down_List"):Show()
    else
    	hScroll:Hide()
    	hFrame:Lookup("Btn_Up_List"):Hide()
    	hFrame:Lookup("Btn_Down_List"):Hide()
    end
    if bHome then
    	hScroll:ScrollHome()
    end
end

function QuestContrastPanel.UpdateInfoScrollInfo(hInfo, bHome)
	local hFrame = hInfo:GetRoot()
	local hHandle = hFrame:Lookup("", "")
	local hScroll = hFrame:Lookup("Scroll_Info")
	hInfo:FormatAllItemPos()
	local fAllWidth, fAllHeight = hInfo:GetAllItemSize()
    local fWidth, fHeight = hInfo:GetSize()
    local nCountStep = math.ceil(math.ceil((fAllHeight - fHeight) / SCROLL_STEP_SIZE) * 100)
    hScroll:SetStepCount(nCountStep)
    if nCountStep > 0 then
    	hScroll:Show()
    	hFrame:Lookup("Btn_Up_Info"):Show()
    	hFrame:Lookup("Btn_Down_Info"):Show()
    	hHandle:Lookup("Image_Decoration2"):Hide()
    	hHandle:Lookup("Image_InfoScrollBg"):Show()    	
    else
    	hScroll:Hide()
    	hFrame:Lookup("Btn_Up_Info"):Hide()
    	hFrame:Lookup("Btn_Down_Info"):Hide()
    	hHandle:Lookup("Image_Decoration2"):Show()
    	hHandle:Lookup("Image_InfoScrollBg"):Hide()
    end
    if bHome then
    	hScroll:ScrollHome()
    end
end

function QuestContrastPanel.Clear(hFrame)
	local hHandle = hFrame:Lookup("", "")
	local hInfo = hHandle:Lookup("Handle_Info")
	hInfo:Clear()
	local hList = hHandle:Lookup("Handle_List")
	hList:Clear()
	local hPanelTitle = hHandle:Lookup("Text_Title")
	hPanelTitle:SetText("")
	local hTraceInfo = hHandle:Lookup("Handle_TraceInfo")
	local hImgAccept = hTraceInfo:Lookup("Image_Accept")
	hImgAccept:Hide()
	local hImgFinish = hTraceInfo:Lookup("Image_Finish")
	hImgFinish:Hide()
end

function OpenQuestContrastPanel(dwTargetID, bDisableSound)
	if IsOptionOrOptionChildPanelOpened() then
		return
	end
	
	if IsQuestContrastPanelOpened() then
		local hFrame = Station.Lookup("Normal/QuestContrastPanel")
		if hFrame.dwTargetID ~= dwTargetID then
			hFrame.dwTargetID = dwTargetID
			hFrame.dwQuestID = nil
			hFrame.tCollapse = nil
		end
		QuestContrastPanel.Clear(hFrame)
		PeekOtherPlayerQuest(dwTargetID)
		return
	end
	
	local hFrame = Wnd.OpenWindow("QuestContrastPanel")
	hFrame:Show()
	hFrame:BringToTop()
	hFrame.dwTargetID = dwTargetID
	hFrame.dwQuestID = nil
	hFrame.tCollapse = nil
	QuestContrastPanel.Clear(hFrame)
	PeekOtherPlayerQuest(dwTargetID)
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND, g_sound.OpenFrame)
	end	
end

function CloseQuestContrastPanel(bDisableSound)
	if not IsQuestContrastPanelOpened() then
		return
	end

	local hFrame = Station.Lookup("Normal/QuestContrastPanel")
	if hFrame then
		hFrame:Hide()
	end
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end	
end

function IsQuestContrastPanelOpened()
	local hFrame = Station.Lookup("Normal/QuestContrastPanel")
	if hFrame and hFrame:IsVisible() then
		return true
	end
	return false
end
