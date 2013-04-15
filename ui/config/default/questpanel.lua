
QuestPanel = 
{
	aCheckAccept = { Normal = 36, NormalOver = 37, Check = 36, CheckOver = 37 },
	aCheckFinish = { Normal = 32, NormalOver = 33, Check = 32, CheckOver = 33 },
	aCheckTarget = { Normal = 40, NormalOver = 41, Check = 40, CheckOver = 41 }
}

function QuestPanel.OnFrameCreate()
	this:RegisterEvent("QUEST_ACCEPTED")
	this:RegisterEvent("QUEST_FAILED")
	this:RegisterEvent("QUEST_CANCELED")
	this:RegisterEvent("QUEST_FINISHED")
	this:RegisterEvent("QUEST_SHARED")
	this:RegisterEvent("QUEST_DATA_UPDATE")
	this:RegisterEvent("QUEST_LIST_UPDATE")
	this:RegisterEvent("PLAYER_LEVEL_UPDATE")
	this:RegisterEvent("QUEST_TIME_UPDATE")
	this:RegisterEvent("LOADING_END")
	this:RegisterEvent("ON_TRACE_QUEST")
	this:RegisterEvent("ON_SET_AUTO_TRACE_QUEST")
	this:RegisterEvent("UPDATE_ASSIST_DAILY_COUNT")
	this:RegisterEvent("UI_SCALED")
	this:RegisterEvent("DAILY_QUEST_UPDATE")
	this:RegisterEvent("PLAYER_REVIVE")
	
	this:Lookup("CheckBox_AutoTrace"):Check(IsAutoTraceQuest())
	
	InitFrameAutoPosInfo(this, 2, nil, nil, function() CloseQuestPanel(true) end)
end;

function QuestPanel.OnEvent(event)
	if event == "QUEST_ACCEPTED" then
		QuestPanel.UpdateQuestList(this)
	elseif event == "QUEST_FAILED" then
		local player = GetClientPlayer()
		local dwQuestID = player.GetQuestID(arg0)
		QuestPanel.UpdateQuestTitleByID(this, dwQuestID)
		if this.dwQuestID == dwQuestID then
			local tQuestStringInfo = Table_GetQuestStringInfo(dwQuestID)
			QuestPanel.UpdateQuestTrace(this:Lookup("", "Handle_Info"), player.GetQuestTraceInfo(dwQuestID), tQuestStringInfo)
		end
	elseif event == "QUEST_CANCELED" then
		QuestPanel.UpdateQuestList(this)
		if arg0 == GetMarkQuestTargetPlace() then
			ClearMarkQuestTargetPlace()
		end
	elseif event == "QUEST_FINISHED" then
		QuestPanel.UpdateQuestList(this)
		if arg0 == GetMarkQuestTargetPlace() then
			ClearMarkQuestTargetPlace()
		end
	elseif event == "QUEST_SHARED" then
	elseif event == "QUEST_DATA_UPDATE" then
		local player = GetClientPlayer()
		local dwQuestID = player.GetQuestID(arg0)
		QuestPanel.UpdateQuestTitleByID(this, dwQuestID)
		if this.dwQuestID == dwQuestID then
			local tQuestStringInfo = Table_GetQuestStringInfo(dwQuestID)
			QuestPanel.UpdateQuestTrace(this:Lookup("", "Handle_Info"), player.GetQuestTraceInfo(dwQuestID), tQuestStringInfo)
		end
	elseif event == "QUEST_LIST_UPDATE" or event == "PLAYER_REVIVE" then
		QuestPanel.UpdateQuestList(this)
	elseif event == "PLAYER_LEVEL_UPDATE" then
		if arg0 == GetClientPlayer().dwID then
			local hList = this:Lookup("", "Handle_List")
			local nCount = hList:GetItemCount() - 1
			for i = 0, nCount, 1 do
				local hI = hList:Lookup(i)
				if hI.bTitle then
					QuestPanel.UpdateQuestTitle(hI)
				end
			end
			QuestPanel.UpdateAssistCount(this)
			QuestPanel.UpdateDailyCount(this)
		end
	elseif event == "QUEST_TIME_UPDATE" then
		if arg0 >= 0 then
			local player = GetClientPlayer()
			local dwQuestID = player.GetQuestID(arg0)
			QuestPanel.UpdateQuestTitleByID(this, dwQuestID)
			if this.dwQuestID == dwQuestID then
				local tQuestStringInfo = Table_GetQuestStringInfo(dwQuestID)
				QuestPanel.UpdateQuestTrace(this:Lookup("", "Handle_Info"), player.GetQuestTraceInfo(dwQuestID), tQuestStringInfo)
			end
		end
	elseif event == "LOADING_END" then
		QuestPanel.LoadMarkQuestTarget()
		QuestPanel.UpdateQuestList(this)
		QuestPanel.UpdateAssistCount(this)
		QuestPanel.UpdateDailyCount(this)
	elseif event == "ON_TRACE_QUEST" then
		QuestPanel.UpdateQuestTitleByID(this, arg0)
		if arg0 == this.dwQuestID then
			QuestPanel.UpdateBtnState(this)
		end
	elseif event == "ON_SET_AUTO_TRACE_QUEST" then
		this:Lookup("CheckBox_AutoTrace"):Check(IsAutoTraceQuest())
	elseif event == "CUSTOM_DATA_LOADED" then
		this:Lookup("CheckBox_AutoTrace"):Check(IsAutoTraceQuest())
	elseif event == "UPDATE_ASSIST_DAILY_COUNT" then
		QuestPanel.UpdateAssistCount(this)
	elseif event == "UI_SCALED" then
		QuestPanel.UpdateListScrollInfo(this:Lookup("", "Handle_List"))
		QuestPanel.UpdateInfoScrollInfo(this:Lookup("", "Handle_Info"))
	elseif event == "DAILY_QUEST_UPDATE" then
		QuestPanel.UpdateDailyCount(this)
	end
end

function QuestPanel.UpdateDailyCount(hFrame)
	local player = GetClientPlayer()
	local hText = hFrame:Lookup("", "Text_DQuest")
	local hImage = hFrame:Lookup("", "Image_DQuest")
	if not player or not player.GetFinishedDailyQuestCount then
		hText:SetText("")
		hImage:Hide()
	else
		local nCurrent = player.GetFinishedDailyQuestCount()
		hText:SetText(FormatString(g_tStrings.QUEST_DAILY, nCurrent, MAX_DAILY_QUEST_COUNT))
		hImage:Show()
	end
end

function QuestPanel.UpdateAssistCount(frame)
	local text = frame:Lookup("", "Text_SQuest")
	local nCurrent, nMax = GetClientPlayer().GetQuestAssistDailyCount()
	text:SetText(FormatString(g_tStrings.QUEST_ASSIST,nCurrent,nMax))
	if nCurrent == nMax then 
		FireHelpEvent("OnAssistQuestFull")
		if IsQuestPanelOpened() then
			FireHelpEvent("OnCommentAssistQuestFull", text)
		end
	end
end

function QuestPanel.UpdateQuestList(frame)
	local player = GetClientPlayer()

	local handle = frame:Lookup("", "")
	local hList = handle:Lookup("Handle_List")
	hList:Clear()
	local szIniFile = "UI/Config/Default/QuestPanel.ini"
	
	local nQuestCount = 0
	local bSel = false
	local aClose, aCloseF = hList.aClose or {}, {}
	local aQuest = player.GetQuestTree()
	for dwClassID, v in pairs(aQuest) do
		hList:AppendItemFromIni(szIniFile, "TreeLeaf_Class")
		local hC = hList:Lookup(hList:GetItemCount() - 1)
		local szName = Table_GetQuestClass(dwClassID)
		hC:Lookup("Text_ClassName"):SetText(szName)
		if aClose[szName] then
			aCloseF[szName] = true
			hC:Collapse()
		else
			hC:Expand()
		end
		hC.bGroup = true
		hC.szClass = szName
		for i, nQuesIndex in pairs(v) do
			nQuestCount = nQuestCount + 1
			local dwQuestID = player.GetQuestID(nQuesIndex)
			local questInfo = GetQuestInfo(dwQuestID)
			hList:AppendItemFromIni(szIniFile, "TreeLeaf_Name")
			local hQ = hList:Lookup(hList:GetItemCount() - 1)
			hQ.nQuesIndex = nQuesIndex
			hQ.dwQuestID = dwQuestID
			hQ.nLevel = questInfo.nLevel
			hQ.bTitle = true
			if not hList.dwQuestID or hList.dwQuestID == dwQuestID then
				QuestPanel.Select(hQ)
				bSel = true
			else
				QuestPanel.UpdateQuestTitle(hQ)
			end
		end
		if nQuestCount == MAX_QUEST_COUNT then
			FireHelpEvent("OnQuestPanelFull") 
		end
	end
	hList.aClose = aCloseF
	QuestPanel.UpdateListScrollInfo(hList, bHome)
	if not bSel then
		local nCount = hList:GetItemCount()
		if nCount == 0 then
			hList.dwQuestID = nil
			frame.dwQuestID = nil
			QuestPanel.UpdateQuestInfo(frame, true)
		else
			nCount = nCount - 1
			for i = 0, nCount, 1 do
				local hQ = hList:Lookup(i)
				if hQ.bTitle then
					QuestPanel.Select(hQ, true)
					break
				end
			end
		end
	end
	
	handle:Lookup("Text_Title"):SetText(FormatString(g_tStrings.QUEST_LIST, nQuestCount))
end

function QuestPanel.UpdateListScrollInfo(hList, bHome)
	local frame = hList:GetRoot()
	local scroll = frame:Lookup("Scroll_List")
	hList:FormatAllItemPos()
	local wAll, hAll = hList:GetAllItemSize()
    local w, h = hList:GetSize()
    local nCountStep = math.ceil((hAll - h) / 10)
    scroll:SetStepCount(nCountStep)
    if nCountStep > 0 then
    	scroll:Show()
    	frame:Lookup("Btn_Up_List"):Show()
    	frame:Lookup("Btn_Down_List"):Show()
    else
    	scroll:Hide()
    	frame:Lookup("Btn_Up_List"):Hide()
    	frame:Lookup("Btn_Down_List"):Hide()
    end
    if bHome then
    	scroll:ScrollHome()
    end
end

function QuestPanel.UpdateInfoScrollInfo(hInfo, bHome)
	local frame = hInfo:GetRoot()
	local handle = frame:Lookup("", "")
	local scroll = frame:Lookup("Scroll_Info")
	hInfo:FormatAllItemPos()
	local wAll, hAll = hInfo:GetAllItemSize()
    local w, h = hInfo:GetSize()
    local nCountStep = math.ceil(math.ceil((hAll - h) / 10) * 100)
    scroll:SetStepCount(nCountStep)
    if nCountStep > 0 then
    	scroll:Show()
    	frame:Lookup("Btn_Up_Info"):Show()
    	frame:Lookup("Btn_Down_Info"):Show()
    	handle:Lookup("Image_Decoration2"):Hide()
    	handle:Lookup("Image_InfoScrollBg"):Show()    	
    else
    	scroll:Hide()
    	frame:Lookup("Btn_Up_Info"):Hide()
    	frame:Lookup("Btn_Down_Info"):Hide()
    	handle:Lookup("Image_Decoration2"):Show()
    	handle:Lookup("Image_InfoScrollBg"):Hide()
    end
    if bHome then
    	scroll:ScrollHome()
    end
end

function QuestPanel.UpdateQuestTitleByID(frame, dwQuestID)
	local dwQuestIndex = GetClientPlayer().GetQuestIndex(dwQuestID)
	if not dwQuestIndex or dwQuestIndex < 0 then
		return 
	end
	
	local hList = frame:Lookup("", "Handle_List")
	local nCount = hList:GetItemCount() - 1
	for i = 0, nCount, 1 do
		local hQ = hList:Lookup(i)
		if hQ.bTitle and hQ.dwQuestID == dwQuestID then
			QuestPanel.UpdateQuestTitle(hQ)
		end
	end
end

function QuestPanel.UpdateQuestTitle(hQ)
	local textTrace = hQ:Lookup("Text_QuestTrace")
	local textName = hQ:Lookup("Text_QuestName")
	local textState = hQ:Lookup("Text_QuestState")
	local img = hQ:Lookup("Image_Sel")
	
	if hQ.bSel then
		img:Show()
		img:SetAlpha(255)		
	elseif hQ.bOver then
		img:Show()
		img:SetAlpha(128)
	else
		img:Hide()
	end
	
	local hPlayer = GetClientPlayer()
	local nFrame, nFont = GetQuestIconAndFont(hQ.dwQuestID, hPlayer)
	img:SetFrame(nFrame)
	textTrace:SetFontScheme(nFont)
	textName:SetFontScheme(nFont)
	textState:SetFontScheme(nFont)
	
	if IsTraceQuest(hQ.dwQuestID) then
		textTrace:SetText(g_tStrings.STR_QUEST_QUEST_IN_QUETSHOW)
	else
		textTrace:SetText("")
	end
	
	local hPlayer = GetClientPlayer()
	local questTrace = hPlayer.GetQuestTraceInfo(hQ.dwQuestID)
	local tQuestStringInfo = Table_GetQuestStringInfo(hQ.dwQuestID)
	textName:SetText(tQuestStringInfo.szName)
	
	if questTrace.finish then
		--if questTrace.have_trace then
			textState:SetText(g_tStrings.STR_QUEST_QUEST_CAN_FINISH)
		--elseif tQuestStringInfo.szQuestDiff then
		--	textState:SetText(tQuestStringInfo.szQuestDiff)
		--else
		--	textState:SetText(g_tStrings.STR_QUEST_QUEST_CAN_FINISH)
			--textState:SetText("")
		--end
	elseif questTrace.fail then
		textState:SetText(g_tStrings.STR_QUEST_QUEST_WAS_FAILED)
	elseif tQuestStringInfo.szQuestDiff then
		textState:SetText(tQuestStringInfo.szQuestDiff)
	else
		textState:SetText("")
	end
	hImageAssist = hQ:Lookup("Image_Assist")
	if questTrace.assist then
		hImageAssist:Show()
		FireHelpEvent("OnAcceptAssistQuest")
		if IsQuestPanelOpened() then
			FireHelpEvent("OnCommentAssistQuest", hImageAssist)	
		end
	else
		hImageAssist:Hide()
	end
end

function QuestPanel.Select(hQ, bHome)
	local hList = hQ:GetParent()
	local frame = hList:GetRoot()
	local nCount = hList:GetItemCount() - 1
	for i = 0, nCount, 1 do
		local hI = hList:Lookup(i)
		if hI.bSel then
			hI.bSel = false
			QuestPanel.UpdateQuestTitle(hI)
			break
		end
	end
	hQ.bSel = true
	hList.dwQuestID = hQ.dwQuestID
	frame.dwQuestID = hQ.dwQuestID
	QuestPanel.UpdateQuestTitle(hQ)
	QuestPanel.UpdateQuestInfo(frame, bHome)
end

function QuestPanel.IsSelectQuest(frame, dwQuestID)
	local hList = frame:Lookup("", "Handle_List")
	return hList.dwQuestID == dwQuestID
end

function QuestPanel.SelectByQuestID(frame, dwQuestID)
	if not dwQuestID then
		return
	end
	local hSel, nSel = nil, nil
	local hList = frame:Lookup("", "Handle_List")
	local nCount = hList:GetItemCount() - 1
	for i = 0, nCount, 1 do
		local hQ = hList:Lookup(i)
		if hQ.dwQuestID == dwQuestID then
			hSel, nSel = hQ, i
			break
		end
	end
	
	if not hSel then
		return
	end
	
	QuestPanel.Select(hSel, true)
	
	for i = nSel, 0, -1 do
		local hQ = hList:Lookup(i)
		if hQ.bGroup then
			if not hQ:IsExpand() then
				hQ:Expand()
				hList.aClose[hQ.szClass] = nil
				QuestPanel.UpdateListScrollInfo(hList)
			end
			break
		end
	end
	
	local x, y = hSel:GetAbsPos()
	local w, h = hSel:GetSize()
	local xL, yL = hList:GetAbsPos()
	local wL, hL = hList:GetSize()
	if y < yL then
		hList:GetRoot():Lookup("Scroll_List"):ScrollPrev(math.ceil((yL - y) / 10))
	elseif y + h > yL + hL then
		hList:GetRoot():Lookup("Scroll_List"):ScrollNext(math.ceil((y + h - yL - hL) / 10))
	end
end

function QuestPanel.UpdateQuestInfo(frame, bHome)
	local handle = frame:Lookup("", "")
	local hInfo = handle:Lookup("Handle_Info")
	hInfo:Clear()
	if not frame.dwQuestID then
		QuestPanel.UpdateInfoScrollInfo(hInfo, bHome)
		QuestPanel.UpdateBtnState(frame)
		local hTraceInfo = frame:Lookup("", "Handle_TraceInfo")
		local hImgAccept = hTraceInfo:Lookup("Image_Accept")
		hImgAccept:Hide()
		local hImgFinish = hTraceInfo:Lookup("Image_Finish")
		hImgFinish:Hide()
		handle:Lookup("Text_NoQuest"):Show()
		return
	end
	handle:Lookup("Text_NoQuest"):Hide()
	
	local player = GetClientPlayer()
	local questInfo = GetQuestInfo(frame.dwQuestID)
	local tQuestStringInfo = Table_GetQuestStringInfo(frame.dwQuestID)
	local questTrace = player.GetQuestTraceInfo(frame.dwQuestID)
	
	hInfo:AppendItemFromString("<text>text="..EncodeComponentsString(tQuestStringInfo.szName.."\n\n").."font=1</text>")
	QuestAcceptPanel.EncodeString(hInfo, tQuestStringInfo.szObjective.."\n\n", 160)
	QuestPanel.AppendQuestTrace(hInfo, questTrace, tQuestStringInfo)
	hInfo:AppendItemFromString("<text>text="..EncodeComponentsString(g_tStrings.STR_QUEST_QUEST_DESCRIPTION).."font=1</text>")
    QuestAcceptPanel.EncodeString(hInfo, tQuestStringInfo.szDescription.."\n\n", 160, false)
	QuestAcceptPanel.UpdateHortation(hInfo, questInfo, false, true)
	QuestPanel.UpdateInfoScrollInfo(hInfo, bHome)
	
	QuestPanel.UpdateBtnState(frame)
	QuestPanel.UpdateQuestTraceCheckbox(frame)	
end

function QuestPanel.UpdateBtnState(frame)
	local btnTrace = frame:Lookup("Btn_Trace")
	local btnShare = frame:Lookup("Btn_Share")
	local btnCancel = frame:Lookup("Btn_Cancel")
	if frame.dwQuestID then
		btnTrace:Enable(true)
		if IsTraceQuest(frame.dwQuestID) then
			btnTrace:Lookup("", "Text_Trace"):SetText(g_tStrings.QUEST_TRACE_CANCEL)
		else
			btnTrace:Lookup("", "Text_Trace"):SetText(g_tStrings.QUEST_TRACE)
		end
		btnShare:Enable(GetQuestInfo(frame.dwQuestID).bShare)
		btnCancel:Enable(true)
	else
		btnTrace:Enable(false)
		btnShare:Enable(false)
		btnCancel:Enable(false)
	end
end

function QuestPanel.AppendQuestTrace(hInfo, questTrace, tQuestStringInfo)
	local dwQuestID = hInfo:GetRoot().dwQuestID
	if questTrace.time then
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
		hInfo:AppendItemFromString("<text>text="..EncodeComponentsString(g_tStrings.STR_TWO_CHINESE_SPACE..g_tStrings.STR_QUEST_TIME_LIMIT..szTime.."\n").."font=0</text>")
		local text = hInfo:Lookup(hInfo:GetItemCount() - 1)
		text.bTrace = true
		text.bTime = true
	end

	for k, v in pairs(questTrace.quest_state) do
		local szName = tQuestStringInfo["szQuestValueStr" .. (v.i + 1)]
		v.have = math.min(v.have, v.need)
		local szText, nFont = g_tStrings.STR_TWO_CHINESE_SPACE..szName.."£º"..v.have.."/"..v.need, 63
		if v.have >= v.need then
			szText, nFont = szText..g_tStrings.STR_QUEST_QUEST_WAS_FINISHED, 1
		end
		hInfo:AppendItemFromString("<text>text="..EncodeComponentsString(szText).."font="..nFont.."</text>")
		local text = hInfo:Lookup(hInfo:GetItemCount() - 1)
		text.bTrace = true
		text.bState = true
		text.i = v.i
		text.k = k
		
		if Table_GetQuestPosInfo(dwQuestID, "quest_state", v.i) then
			hInfo:AppendItemFromString("<image>w=35 h=24 path=\"ui/Image/QuestPanel/QuestPanel.UITex\" frame=13 eventid=341</image>")
			local image = hInfo:Lookup(hInfo:GetItemCount() - 1)
			image.bTraceCheckbox = true
			image.szType = "quest_state"
			image.i = v.i
			image.k = k
		end
		
		hInfo:AppendItemFromString("<text>text=\"\\\n\"font=0</text>")
	end
	
	local bKillNpc = false
	for k, v in pairs(questTrace.kill_npc) do
		v.have = math.min(v.have, v.need)
		local szName = Table_GetNpcTemplateName(v.template_id)
		if not szName or szName == "" then
			szName = "Unknown Npc"
		end
		local szText, nFont = g_tStrings.STR_TWO_CHINESE_SPACE.. szName .."£º"..v.have.."/"..v.need, 63
		if v.have >= v.need then
			szText, nFont = szText..g_tStrings.STR_QUEST_QUEST_WAS_FINISHED, 1
		end
		hInfo:AppendItemFromString("<text>text="..EncodeComponentsString(szText).."font="..nFont.."</text>")
		local text = hInfo:Lookup(hInfo:GetItemCount() - 1)
		text.bTrace = true
		text.bNpc = true
		text.i = v.i
		text.k = k
		
		if Table_GetQuestPosInfo(dwQuestID, "kill_npc", v.i) then
			hInfo:AppendItemFromString("<image>w=35 h=24 path=\"ui/Image/QuestPanel/QuestPanel.UITex\" frame=13 eventid=341</image>")
			local image = hInfo:Lookup(hInfo:GetItemCount() - 1)
			image.bTraceCheckbox = true
			image.szType = "kill_npc"
			image.i = v.i
			image.k = k
			if not bKillNpc then
				local hFrame = hInfo:GetRoot()
				hFrame.hKillNpcMark = image
				bKillNpc = true
				if IsQuestPanelOpened() then
					FireHelpEvent("OnCommentToMarkKillNpc", dwQuestID, hFrame.hKillNpcMark)
				end
			end
		end
		
		hInfo:AppendItemFromString("<text>text=\"\\\n\"font=0</text>")		
	end

	for k, v in pairs(questTrace.need_item) do
		local itemInfo = GetItemInfo(v.type, v.index)
		local nBookID = v.need
		if itemInfo.nGenre == ITEM_GENRE.BOOK then
			v.need = 1
		end
		v.have = math.min(v.have, v.need)		
		local szName = "Unknown Item"
		if itemInfo then
			szName = GetItemNameByItemInfo(itemInfo, nBookID)
		end
		local szText, nFont = g_tStrings.STR_TWO_CHINESE_SPACE..szName.."£º"..v.have.."/"..v.need, 63
		if v.have >= v.need then
			szText, nFont = szText..g_tStrings.STR_QUEST_QUEST_WAS_FINISHED, 1
		end
		hInfo:AppendItemFromString("<text>text="..EncodeComponentsString(szText).."font="..nFont.."</text>")
		local text = hInfo:Lookup(hInfo:GetItemCount() - 1)
		text.bTrace = true
		text.bItem = true
		text.i = v.i
		text.k = k
		
		if Table_GetQuestPosInfo(dwQuestID, "need_item", v.i) then
			hInfo:AppendItemFromString("<image>w=35 h=24 path=\"ui/Image/QuestPanel/QuestPanel.UITex\" frame=13 eventid=341</image>")
			local image = hInfo:Lookup(hInfo:GetItemCount() - 1)
			image.bTraceCheckbox = true
			image.szType = "need_item"
			image.i = v.i
			image.k = k
			if not bKillNpc then
				local hFrame = hInfo:GetRoot()
				hFrame.hKillNpcMark = image
				bKillNpc = true
				if IsQuestPanelOpened() then
					FireHelpEvent("OnCommentToMarkKillNpc", dwQuestID, hFrame.hKillNpcMark)
				end
			end
		end
		
		hInfo:AppendItemFromString("<text>text=\"\\\n\"font=0</text>")
	end
end

function QuestPanel.UpdateQuestTrace(hInfo, questTrace, tQuestStringInfo)
	local nCount = hInfo:GetItemCount() - 1
	for i = 0, nCount, 1 do
		local text = hInfo:Lookup(i)
		if text.bTrace then
			if text.bTime then
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
				text:SetText(g_tStrings.STR_TWO_CHINESE_SPACE..g_tStrings.STR_QUEST_TIME_LIMIT..szTime.."\n")
			elseif text.bState then
				local v = questTrace.quest_state[text.k]
				local szName = tQuestStringInfo["szQuestValueStr" .. (v.i + 1)]
				v.have = math.min(v.have, v.need)
				local szText, nFont = g_tStrings.STR_TWO_CHINESE_SPACE..szName.."£º"..v.have.."/"..v.need, 63
				if v.have >= v.need then
					szText, nFont = szText..g_tStrings.STR_QUEST_QUEST_WAS_FINISHED, 1
				end
				text:SetText(szText)
				text:SetFontScheme(nFont)
			elseif text.bNpc then
				local v = questTrace.kill_npc[text.k]
				v.have = math.min(v.have, v.need)
				local szName = Table_GetNpcTemplateName(v.template_id)
				if not szName or szName == "" then
					szName = "Unknown Npc"
				end
				local szText, nFont = g_tStrings.STR_TWO_CHINESE_SPACE.. szName .."£º"..v.have.."/"..v.need, 63
				if v.have >= v.need then
					szText, nFont = szText..g_tStrings.STR_QUEST_QUEST_WAS_FINISHED, 1
				end
				text:SetText(szText)
				text:SetFontScheme(nFont)
			elseif text.bItem then
				local v = questTrace.need_item[text.k]
				local itemInfo = GetItemInfo(v.type, v.index)
				local nBookID = v.need
				if itemInfo.nGenre == ITEM_GENRE.BOOK then
					v.need = 1
				end
				v.have = math.min(v.have, v.need)		
				local szName = "Unknown Item"
				if itemInfo then
					szName = GetItemNameByItemInfo(itemInfo, nBookID)
				end
				local szText, nFont = g_tStrings.STR_TWO_CHINESE_SPACE..szName.."£º"..v.have.."/"..v.need, 63
				if v.have >= v.need then
					szText, nFont = szText..g_tStrings.STR_QUEST_QUEST_WAS_FINISHED, 1
				end
				text:SetText(szText)
				text:SetFontScheme(nFont)
			end
		end
	end
	QuestPanel.UpdateInfoScrollInfo(hInfo)
end

function QuestPanel.UpdateQuestTraceCheckboxState(image)
	local a 
	if image.bAccept then
		a = QuestPanel.aCheckAccept
	elseif image.bFinish then
		a = QuestPanel.aCheckFinish
	else
		a = QuestPanel.aCheckTarget
	end
	if image.bOnTrace then
		if image.bOver then
			image:SetFrame(a.CheckOver)
		else
			image:SetFrame(a.Check)
		end
	else
		if image.bOver then
			image:SetFrame(a.NormalOver)
		else
			image:SetFrame(a.Normal)
		end
	end
end

function QuestPanel.UpdateQuestTraceCheckbox(frame, questTrace)
	local dwQuestID = frame.dwQuestID
	hInfo = frame:Lookup("", "Handle_Info")
	local nCount = hInfo:GetItemCount() - 1
	for i = 0, nCount, 1 do
		local image = hInfo:Lookup(i)
		if image.bTraceCheckbox then
			image.bOnTrace = IsMarkQuestTargetPlace(dwQuestID, image.szType, image.i)
			QuestPanel.UpdateQuestTraceCheckboxState(image)
		end
	end
	
	local hTraceInfo = frame:Lookup("", "Handle_TraceInfo")
	local imgA = hTraceInfo:Lookup("Image_Accept")
	local imgF = hTraceInfo:Lookup("Image_Finish")
	if dwQuestID then
		if Table_GetQuestPosInfo(dwQuestID, "accept", 0) then
			imgA:Show()
			imgA.bTraceCheckbox = true
			imgA.bAccept = true
			imgA.szType = "accept"
			imgA.i = 0
			imgA.bOnTrace = IsMarkQuestTargetPlace(dwQuestID, "accept", 0)
			QuestPanel.UpdateQuestTraceCheckboxState(imgA)
		else
			imgA:Hide()
			imgA.bOver = false
			imgA.bOnTrace = false
		end
	
		if Table_GetQuestPosInfo(dwQuestID, "finish", 0) then
			imgF:Show()
			imgF.bTraceCheckbox = true
			imgF.bFinish = true
			imgF.szType = "finish"
			imgF.i = 0
			imgF.bOnTrace = IsMarkQuestTargetPlace(dwQuestID, "finish", 0)
			QuestPanel.UpdateQuestTraceCheckboxState(imgF)
			
			if IsQuestPanelOpened() then
				FireHelpEvent("OnOpenpanel", "QuestFinishTrace", imgF)
			end
		else		
			imgF:Hide()
			imgF.bOver = false
			imgF.bOnTrace = false
		end
	else
		imgA:Hide()
		imgA.bOver = false
		imgA.bOnTrace = false
		imgF:Hide()
		imgF.bOver = false
		imgF.bOnTrace = false
	end	
end

function QuestPanel.OnItemMouseEnter()
	if this.bTitle then
		this.bOver = true
		QuestPanel.UpdateQuestTitle(this)
		if this.dwQuestID then
			local nExp, nP1, nP2 = GetClientPlayer().GetQuestExpAttenuation(this.dwQuestID)
			local szMsg = ""
			if nP1 ~= 100 then
				szMsg = g_tStrings.QUEST_EXHAUST_MSG1 .. (100 - nP1) .. "%"..g_tStrings.STR_FULL_STOP.."\n"
			end
			if nP2 ~= 100 then
				szMsg = szMsg .. g_tStrings.QUEST_EXHAUST_MSG2 .. (100 - nP2) .. "%" ..g_tStrings.STR_FULL_STOP.."\n"
			end
			if szMsg ~= "" then
				local x, y = this:GetAbsPos()
				local w, h = this:GetSize()
				OutputTip("<text>text="..EncodeComponentsString(szMsg).." font=100 </text>", 345, {x, y, w, h})
			end
		end
	elseif this.bTraceCheckbox then
		this.bOver = true
		QuestPanel.UpdateQuestTraceCheckboxState(this)
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
		local szTip
		if this.bAccept then
			szTip = g_tStrings.QUEST_LOOKUP_ACCEPT_PLACE
		elseif this.bFinish then
			szTip = g_tStrings.QUEST_LOOKUP_FINISH_PLACE
		else
			szTip = g_tStrings.QUEST_LOOKUP_TARGET
		end
		OutputTip("<text>text="..EncodeComponentsString(szTip).." font=100 </text>", 345, {x, y, w, h})
	end
end

function QuestPanel.OnItemMouseLeave()
	if this.bTitle then
		this.bOver = false
		QuestPanel.UpdateQuestTitle(this)
		HideTip()
	elseif this.bTraceCheckbox then
		this.bOver = false
		QuestPanel.UpdateQuestTraceCheckboxState(this)
		HideTip()
	end
end

function QuestPanel.OnItemLButtonDown()
	if this.bGroup then
		local hList = this:GetParent()
		if this:IsExpand() then
			this:Collapse()
			hList.aClose[this.szClass] = true
		else
			this:Expand()
			hList.aClose[this.szClass] = nil
		end
		QuestPanel.UpdateListScrollInfo(hList)
		PlaySound(SOUND.UI_SOUND,g_sound.Button)
		this:GetRoot().bScrollList = true
	elseif this.bTitle then
		if IsShiftKeyDown() then
			if IsTraceQuest(this.dwQuestID) then
				RemoveTraceQuest(this.dwQuestID)
			else
				AddTraceQuest(this.dwQuestID)
			end
		elseif IsCtrlKeyDown() then
			if IsGMPanelReceiveQuest() then
				GMPanel_LinkQuest(this.dwQuestID)
			else
				EditBox_AppendLinkQuest(this.dwQuestID)
			end
		end
		QuestPanel.Select(this, true)
		this:GetRoot().bScrollList = true
	elseif this:GetName() == "Handle_List" then
		this:GetRoot().bScrollList = true
	else
		this:GetRoot().bScrollList = false
	end
end

function QuestPanel.OnItemLButtonClick()
	if this.bTraceCheckbox then
--		if this.bOnTrace then
--			ClearMarkQuestTargetPlace()
--		else
			local frame = this:GetRoot()
			OnMarkQuestTarget(frame.dwQuestID, this.szType, this.i)
			
			--Êý¾Ý·ÖÎö
			local szImgName = this:GetName()
			if szImgName == "Image_Accept" then
				FireDataAnalysisEvent("LOOK_ACCEPT_QUEST_POINT")
			elseif szImgName == "Image_Finish" then
				FireDataAnalysisEvent("LOOK_SUBMIT_QUEST_POINT")
			end
--		end
	end
end

function QuestPanel.OnItemLButtonDBClick()
	if this.bGroup or this.bTitle then
		return QuestPanel.OnItemLButtonDown()
	elseif this.bTraceCheckbox then
		return QuestPanel.OnItemLButtonClick()
	end
end

function QuestPanel.OnScrollBarPosChanged()
	local nCurrentValue = this:GetScrollPos()
	local frame = this:GetParent()
	local szName = this:GetName()
	if szName == "Scroll_List" then 
		if nCurrentValue == 0 then
			frame:Lookup("Btn_Up_List"):Enable(false)
		else
			frame:Lookup("Btn_Up_List"):Enable(true)
		end
		
		if nCurrentValue == this:GetStepCount() then
			frame:Lookup("Btn_Down_List"):Enable(false)
		else
			frame:Lookup("Btn_Down_List"):Enable(true)
		end
	    frame:Lookup("", "Handle_List"):SetItemStartRelPos(0, - nCurrentValue * 10)
	elseif szName == "Scroll_Info" then 
		if nCurrentValue == 0 then
			frame:Lookup("Btn_Up_Info"):Enable(false)
		else
			frame:Lookup("Btn_Up_Info"):Enable(true)
		end
		local nTotal = this:GetStepCount()
		if nCurrentValue == nTotal then
			frame:Lookup("Btn_Down_Info"):Enable(false)
		else
			frame:Lookup("Btn_Down_Info"):Enable(true)
		end
		if nTotal == 0 then
			frame:Lookup("", "Image_InfoScrollBg"):SetPercentage(0)
		else
			frame:Lookup("", "Image_InfoScrollBg"):SetPercentage(nCurrentValue / nTotal)
		end
		local nStartY = - math.floor(nCurrentValue / 100) * 10
	    frame:Lookup("", "Handle_Info"):SetItemStartRelPos(0, nStartY)
	    frame:Lookup("", "Handle_TraceInfo"):SetItemStartRelPos(0, nStartY)
	end
end

function QuestPanel.OnLButtonDown()
	QuestPanel.OnLButtonHold()
end

function QuestPanel.OnLButtonHold()
	local frame = this:GetRoot()
	local szName = this:GetName()
    if szName == "Btn_Up_List" then
		frame:Lookup("Scroll_List"):ScrollPrev()
	elseif szName == "Btn_Down_List" then
		frame:Lookup("Scroll_List"):ScrollNext()
	elseif szName == "Btn_Up_Info" then
		frame:Lookup("Scroll_Info"):ScrollPrev(100)
	elseif szName == "Btn_Down_Info" then
		frame:Lookup("Scroll_Info"):ScrollNext(100)
	end
end

function QuestPanel.OnItemMouseWheel()
	local nDistance = Station.GetMessageWheelDelta()
	local frame = this:GetRoot()
	if frame.bScrollList then
		frame:Lookup("Scroll_List"):ScrollNext(nDistance)
	else
		frame:Lookup("Scroll_Info"):ScrollNext(nDistance * 100)
	end
	return true
end

function QuestPanel.OnCheckBoxCheck()
	local szName = this:GetName()
	if szName == "CheckBox_AutoTrace" then
		SetAutoTraceQuest(true)
	end
end

function QuestPanel.OnCheckBoxUncheck()
	local szName = this:GetName()
	if szName == "CheckBox_AutoTrace" then
		SetAutoTraceQuest(false)
	end
end

function QuestPanel.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_Close" or szName == "Btn_Close01" then
		CloseQuestPanel()
	elseif szName == "Btn_Share" then
		local frame = this:GetRoot()
		if frame.dwQuestID then
	        local player = GetClientPlayer()
			player.ShareQuest(player.GetQuestIndex(frame.dwQuestID))
			PlaySound(SOUND.UI_SOUND, g_sound.Button)
			
			FireDataAnalysisEvent("SHARE_QUEST")
		end
	elseif szName == "Btn_Trace" then
		local frame = this:GetRoot()
		if frame.dwQuestID then
			if IsTraceQuest(frame.dwQuestID) then
				RemoveTraceQuest(frame.dwQuestID)
			else
				AddTraceQuest(frame.dwQuestID)
			end
			PlaySound(SOUND.UI_SOUND, g_sound.Button)
		end
	elseif szName == "Btn_Cancel" then
		local frame = this:GetRoot()
		if frame.dwQuestID then
			local player = GetClientPlayer()
			local tQuestStringInfo = Table_GetQuestStringInfo(frame.dwQuestID)
			if tQuestStringInfo then
				local dwQuestID = frame.dwQuestID
				local fCancelQuest = function()
					local player = GetClientPlayer()
		        	player.CancelQuest(player.GetQuestIndex(dwQuestID))        	
				end
				local msg = 
				{
					szMessage = FormatString(g_tStrings.STR_QUEST_SURE_REMOVE_QUEST, tQuestStringInfo.szName),
					szName = "CancelQuestResult", 
					{szOption = g_tStrings.STR_QUEST_SURE, fnAction = fCancelQuest},
					{szOption = g_tStrings.STR_QUEST_CANCEL},
				}
				MessageBox(msg)
			end
		end
	elseif szName == "Btn_Suggest" then
		OpenSuggestPanel()
	end	
end

function QuestPanel.LoadMarkQuestTarget()
	QuestPanel.bLoad = true
	if GetUserPreferences(1340, "b") then
		local dwQuestID = GetUserPreferences(1341, "d")
		local nType = GetUserPreferences(1345, "c")
		local szType = "finish"
		if nType == 1 then
			szType = "accept"
		elseif nType == 2 then
			szType = "finish"
		elseif nType == 3 then
			szType = "quest_state"
		elseif nType == 4 then
			szType = "kill_npc"
		elseif nType == 5 then
			szType = "need_item"
		end
		local nIndex = GetUserPreferences(1346, "c")
		local player = GetClientPlayer()
		local nQuestIndex = player.GetQuestIndex(dwQuestID)
		if nQuestIndex and nQuestIndex >= 0 then
			MarkQuestTargetPlace(dwQuestID, szType, nIndex)
		else
			ClearMarkQuestTargetPlace()
		end
	else
		ClearMarkQuestTargetPlace()
	end
	QuestPanel.bLoad = false
end

function QuestPanel.SaveMarkQuestTarget()
	if QuestPanel.bLoad then
		return
	end
	
	local dwQuestID, szType, nIndex = GetMarkQuestTargetPlace()
	if dwQuestID and szType and nIndex then
		local nType = 2
		if szType == "accept" then
			nType = 1
		elseif szType == "finish" then
			nType = 2
		elseif szType == "quest_state" then
			nType = 3
		elseif szType == "kill_npc" then
			nType = 4
		elseif szType == "need_item" then
			nType = 5
		end
		SetUserPreferences(1340, "bdcc", true, dwQuestID, nType, nIndex)
	else
		SetUserPreferences(1340, "b", false)
	end
end

function QuestPanel.DoHelper(hFrame)
	
	local hPlayer = GetClientPlayer()
	if hPlayer then
		local nCurrent, nMax = hPlayer.GetQuestAssistDailyCount()
		if nCurrent == nMax then 
			local hText = hFrame:Lookup("", "Text_SQuest")
			FireHelpEvent("OnCommentAssistQuestFull", hText)
		end
	end
	
	local hList = hFrame:Lookup("", "Handle_List")
	local nCount = hList:GetItemCount()
	for i = 0, nCount - 1 do
		local hQuest = hList:Lookup(i)
		if hQuest.bTitle then
			local hImageAssist = hQuest:Lookup("Image_Assist")
			if hImageAssist:IsVisible() then
				FireHelpEvent("OnCommentAssistQuest", hImageAssist)
				break
			end
		end
	end
	
	local hImageFinish = hFrame:Lookup("", "Handle_TraceInfo/Image_Finish")
	if hImageFinish:IsVisible() and hFrame.dwQuestID then
		FireHelpEvent("OnOpenpanel", "QuestFinishTrace", hImageFinish, hFrame.dwQuestID)
	end
	
	if hFrame.hKillNpcMark and hFrame.hKillNpcMark:IsVisible() and hFrame.dwQuestID then
		FireHelpEvent("OnCommentToMarkKillNpc", hFrame.dwQuestID, hFrame.hKillNpcMark)
	end
end

function MarkQuestTargetPlace(dwQuestID, szType, nIndex)
	if IsMarkQuestTargetPlace(dwQuestID, szType, nIndex) then
		return
	end
	QuestPanel.aMark = {}
	QuestPanel.aMark.dwQuestID = dwQuestID
	QuestPanel.aMark.szType = szType
	QuestPanel.aMark.nIndex = nIndex
	
	QuestPanel.SaveMarkQuestTarget()
	
	FireEvent("ON_MARK_QUEST_TARGET_PLACE")
end

function IsMarkQuestTargetPlace(dwQuestID, szType, nIndex)
	if QuestPanel.aMark and QuestPanel.aMark.dwQuestID == dwQuestID
		and QuestPanel.aMark.szType == szType and QuestPanel.aMark.nIndex == nIndex then
		return true
	end
end

function ClearMarkQuestTargetPlace()
	QuestPanel.aMark = nil
	
	QuestPanel.SaveMarkQuestTarget()
	FireEvent("ON_MARK_QUEST_TARGET_PLACE")
end

function GetMarkQuestTargetPlace()
	if QuestPanel.aMark then
		return QuestPanel.aMark.dwQuestID, QuestPanel.aMark.szType, QuestPanel.aMark.nIndex
	end
	return nil, nil, nil
end


function OpenQuestPanel(bDisableSound, dwQuestID)
	if IsOptionOrOptionChildPanelOpened() then
		return
	end

	local frame = Station.Lookup("Normal/QuestPanel")
	if IsQuestPanelOpened() then
		if dwQuestID then
			QuestPanel.SelectByQuestID(frame, dwQuestID)
		end
		return
	end
	
	if frame then
		frame:Show()
		frame:BringToTop()
		if dwQuestID then
			QuestPanel.SelectByQuestID(frame, dwQuestID)
		end
	end
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
	QuestPanel.DoHelper(frame)
	
end


function CloseQuestPanel(bDisableSound)
	if not IsQuestPanelOpened() then
		return
	end

	local frame = Station.Lookup("Normal/QuestPanel")
	if frame then
		frame:Hide()
	end
		
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end	
end

function IsQuestPanelOpened(dwQuestID)
	local frame = Station.Lookup("Normal/QuestPanel")
	if frame and frame:IsVisible() then
		if dwQuestID then
			return QuestPanel.IsSelectQuest(frame, dwQuestID)
		else
			return true
		end
	end
	return false
end

function OnMarkQuestTarget(dwQuestID, szType, nIndex)
	local tPointList = Table_GetQuestPoint(dwQuestID, szType, nIndex)
	if not tPointList or IsEmpty(tPointList) then
		Log("[UI DEBUG]Warnning OnMarkQuestTarget: dwQuestID=" .. tostring(dwQuestID) .. ", szType=" .. tostring(szType) .. ", nIndex=" .. tostring(nIndex))
		return
	end
	MarkQuestTargetPlace(dwQuestID, szType, nIndex)
	local hPlayer = GetClientPlayer()
	local hScene = hPlayer.GetScene()
	if tPointList[hScene.dwMapID] then
		OpenMiddleMap(hScene.dwMapID, 0)
		return
	end

	local dwLastUnvisitedMap = nil
	for dwMapID, tPoint in pairs(tPointList) do
		if hPlayer.GetMapVisitFlag(dwMapID) then
			OpenMiddleMap(dwMapID, 0)
			return
		end
		dwLastUnvisitedMap = dwMapID
	end
	
	if not dwLastUnvisitedMap then
		return
	end
	
	OpenWorldMap()
	local argSave = arg0
	arg0 = dwLastUnvisitedMap
	FireEvent("SELECT_CITY_COPY")
	arg0 = argSave

end

function GetQuestIconAndFont(dwQuestID, hPlayer)
	local nFrame, nFont = 0, 0	
	local nDifficult = hPlayer.GetQuestDiffcultyLevel(dwQuestID)
	if nDifficult == QUEST_DIFFICULTY_LEVEL.PROPER_LEVEL then
		nFrame, nFont = 2, 99	-- »Æ
	elseif nDifficult == QUEST_DIFFICULTY_LEVEL.HIGH_LEVEL then
		nFrame, nFont = 5, 158	-- ³È
	elseif nDifficult == QUEST_DIFFICULTY_LEVEL.HIGHER_LEVEL then
		nFrame, nFont = 1, 102	-- ºì
	elseif nDifficult == QUEST_DIFFICULTY_LEVEL.LOW_LEVEL then
		nFrame, nFont = 4, 173	-- ÂÌ
	elseif nDifficult == QUEST_DIFFICULTY_LEVEL.LOWER_LEVEL then
		nFrame, nFont = 3, 110	-- »Ò
	else
		nFrame, nFont = 2, 99	-- »Æ
	end
	return nFrame, nFont
end
