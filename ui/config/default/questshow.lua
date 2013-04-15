QuestShow={

g_nMaxQuestShowNumber = 5;
g_nQuestID = -1;		--玩家任务表ID
g_nQuestTabID = -1;		--实际任务表ID
g_nShowQuestNumber = 0;
g_nMaxSize = 0;

OnFrameCreate=function()
	this:RegisterEvent("UI_SCALED")
	QuestShow.OnUpdateFrameSize()
	
	QuestShow.OnEvent("UI_SCALED")
end;

GetQuestShowInfoByIndex=function(nIndex)
	local handle = Station.Lookup("Normal/QuestShow", "")
	local Subhandle = handle:Lookup(nIndex)
	if not Subhandle then
		return 0, 0
	end
	return Subhandle.nQuestID, Subhandle.nQuestTabID
end;

GetQuestShowCount=function()
	return QuestShow.g_nShowQuestNumber
end;


SaveQuestShowToDB=function ()
	local nCount = QuestShow.GetQuestShowCount()
	SetUserPreferences(1300, "c", nCount)
	for index = 1, nCount, 1 do
		local nQuestID, nQuestTabID = QuestShow.GetQuestShowInfoByIndex(index)
		SetUserPreferences(1300 + index * 4 - 3, "d", nQuestTabID)
	end
end;

SetQuestShowPost=function()
	local frame = Station.Lookup("Normal/QuestShow")
	frame:SetPoint("TOPLEFT", 0, 0, "TOPRIGHT",  -10 - QuestShow.g_nMaxSize, 345)
end;

OnEvent=function(event)
	if  event == "UI_SCALED" then
		QuestShow.SetQuestShowPost()
		QuestShow.OnResetAllHandle()
	end
end;

OnGetQuestShowInfo=function(szEvent, nQuestID, nQuestTabID, bNeedErrorText)
	QuestShow.g_nQuestTabID = nQuestTabID
	QuestShow.g_nQuestID = nQuestID
	if szEvent == "Add" then
		local nIsAdd = 0
		nIsAdd = QuestShow.AddOrRemoveQuestShowList(true, bNeedErrorText)
		QuestShow.SetQuestShowPost()
		return nIsAdd
	elseif szEvent == "Updata" then
		QuestShow.OnUpdataQuestShow()
		QuestShow.SetQuestShowPost()
	elseif szEvent == "Cancel" then
		QuestShow.AddOrRemoveQuestShowList(false, bNeedErrorText)
		QuestShow.SetQuestShowPost()
	elseif szEvent == "IsShow" then
		local Subhandle = Station.Lookup("Normal/QuestShow", ""):Lookup(""..QuestShow.g_nQuestTabID.."")
		if Subhandle then
			return 1
		else
			local questInfo = GetQuestInfo(QuestShow.g_nQuestTabID)
			if questInfo.nFinishTime ~= 0 then
				local nIsAdd = 0
				--限时任务相关
				nIsAdd = QuestShow.AddOrRemoveQuestShowList(true, false)
				QuestShow.SetQuestShowPost()
				return nIsAdd
			else
				return 0
			end
		end
	end
end;

OnResetAllHandle=function()
	local handle = Station.Lookup("Normal/QuestShow", "")
	local nCount = handle:GetItemCount() - 1
	for id = 0, nCount, 1 do
		local Subhandle = handle:Lookup(id)
		Subhandle:SetSize(350, 10) --先放大后缩小
		Subhandle:FormatAllItemPos()
		Subhandle:SetSizeByAllItemSize()
	end
	handle:FormatAllItemPos()
	handle:SetSizeByAllItemSize()
end;

OnUpdateFrameSize=function()
	local w, h = 0, 0
	local nMaxSize = 0
	local handle = Station.Lookup("Normal/QuestShow"):Lookup("", "")
	local nCount = handle:GetItemCount() - 1
	for nIndex = 0, nCount, 1 do
		local Subhandle = handle:Lookup(nIndex)
		w, h = Subhandle:GetSize()
		if nMaxSize < w then
			nMaxSize = w
		end
	end
	QuestShow.g_nMaxSize = nMaxSize
end;

IsNothingShow=function(questInfo)
	local questInfoTable = QuestPanel.QuestInfoChangeTable(questInfo)
	for Index = 9, 24, 1 do
		if questInfoTable[Index][2] > 0 then
			return 0
		end
	end
	return 1
end;

AddOrRemoveQuestShowList=function(bIsAddOne, bNeedErrorText)
	if QuestShow.g_nQuestTabID == -1 then
		return
	end
	local player = GetClientPlayer()
	local handle = Station.Lookup("Normal/QuestShow", "")
	local Subhandle = handle:Lookup(""..QuestShow.g_nQuestTabID.."")
	local szIniFile = "UI/Config/Default/QuestShow.ini"	
	
	if not Subhandle and bIsAddOne then
		local questInfo = GetQuestInfo(QuestShow.g_nQuestTabID)
		--限时任务相关
		local bIsNotUsed = questInfo.nFinishTime == 0 --判断是否是限时任务
		if bIsNotUsed and QuestShow.g_nShowQuestNumber == QuestShow.g_nMaxQuestShowNumber then
			if bNeedErrorText then
				OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_QUESTSHOW_FOLLOW_COUNT_MAX)
			end
			return 0
		end
		handle:AppendItemFromIni(szIniFile, "Handle_SubQuestShow", ""..QuestShow.g_nQuestTabID.."")
		Subhandle = handle:Lookup(""..QuestShow.g_nQuestTabID.."")
		Subhandle.nQuestTabID = QuestShow.g_nQuestTabID
		Subhandle.nQuestID    = QuestShow.g_nQuestID		
		Subhandle.bIsNotUsed  = bIsNotUsed
		if bIsNotUsed then
			QuestShow.g_nShowQuestNumber = QuestShow.g_nShowQuestNumber + 1
		end
		QuestShow.OnUpdateQuestInfo(player, handle, Subhandle, questInfo)
		QuestShow.SaveQuestShowToDB()
		return 1
	--限时任务相关
	elseif Subhandle and bIsAddOne and not Subhandle.bIsNotUsed then
		return 1
	else
		if Subhandle then
			local nIndex = Subhandle:GetIndex()
			local parent = Subhandle:GetParent()
			if Subhandle.bIsNotUsed then
				QuestShow.g_nShowQuestNumber = QuestShow.g_nShowQuestNumber - 1
			end
			if QuestShow.g_nShowQuestNumber < 0 then
				QuestShow.g_nShowQuestNumber = 0
			end
			parent:RemoveItem(nIndex)
			handle:FormatAllItemPos()
			QuestShow.OnUpdateFrameSize()
			QuestShow.SaveQuestShowToDB()
		end
		return 0
	end
end;

OnUpdataQuestShow=function()
	local player = GetClientPlayer()
	local handle = Station.Lookup("Normal/QuestShow", "")
	local Subhandle = handle:Lookup(""..QuestShow.g_nQuestTabID.."")
	local questInfo = GetQuestInfo(QuestShow.g_nQuestTabID)
	
	if Subhandle then
		Subhandle:Clear()
		QuestShow.OnUpdateQuestInfo(player, handle, Subhandle, questInfo)
	end
end;

OnUpdateQuestInfo=function(player, handle, Subhandle, questInfo)
	local tQuestStringInfo = Table_GetQuestStringInfo(Subhandle.nQuestID)
	local nFinishedType = player.CanFinishQuest(Subhandle.nQuestTabID)
	Subhandle:SetItemStartRelPos(0, 0)
	if nFinishedType == QUEST_RESULT.SUCCESS then--任务名字
		Subhandle:AppendItemFromString("<text>text="..EncodeComponentsString("　　"..tQuestStringInfo.szName..g_tStrings.STR_QUEST_QUEST_WAS_FINISHED.."\n").."font=65</text>")
	elseif player.GetQuestFailedFlag(Subhandle.nQuestID) then
		Subhandle:AppendItemFromString("<text>text="..EncodeComponentsString("　　"..tQuestStringInfo.szName..g_tStrings.STR_QUEST_QUEST_WAS_FAILED.."\n").."font=65</text>")
	else
		Subhandle:AppendItemFromString("<text>text="..EncodeComponentsString("　　"..tQuestStringInfo.szName.."\n").."font=65</text>")
	end
	
	if QuestShow.IsNothingShow(questInfo) == 1 then
		if nFinishedType == QUEST_RESULT.SUCCESS then
			QuestAcceptPanel.EncodeString(Subhandle, tQuestStringInfo.szObjective, 0)
		else
			QuestAcceptPanel.EncodeString(Subhandle, tQuestStringInfo.szObjective, 60)
		end
	else
		QuestPanel.UpdatePlan(Subhandle, questInfo, 60, 0, Subhandle.nQuestID) --任务进度
	end
	Subhandle:SetSize(350, 10) --先放大后缩小
	Subhandle:FormatAllItemPos()
	Subhandle:SetSizeByAllItemSize()
	handle:FormatAllItemPos()
	handle:SetSizeByAllItemSize()
	QuestShow.OnUpdateFrameSize()
end;

}
