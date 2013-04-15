KeyNotesPanel = 
{
	nBgNormal = 1, nBgOver = 2, 
	nIconQuestNormal = 8, nIconQuestOver = 8, 
	nIconSkillNormal = 16, nIconSkillOver = 16, 
	nIconXiuWeiNormal = 7, nIconXiuWeiOver = 7,
	nIconTiliNormal = 9, nIconTiliOver = 9,
	nIconJinLiNormal = 9, nIconJinLiOver = 9,
	nIconMailNormal = 11, nIconMailOver = 11,
	nIconJX3DailyNormal = 10, nIconJX3DailyOver = 10,
	nIconFriendNormal = 6, nIconFriendOver = 6,
	nIconEventNormal = 10, nIconEventOver = 10,
	
	nExpandUp = 14, nExpandDown = 15,
	bShowTipIcon = true, bShowTip = true,
	bSkillExpand = true,
	
	tJX3DailyState = {},
	bBreakthroughExpand = true,
}

RegisterCustomData("KeyNotesPanel.tJX3DailyState")


local INI_PATH = "UI/Config/Default/KeyNotesPanel.ini"

RegisterCustomData("KeyNotesPanel.bShowTip")

function KeyNotesPanel.OnFrameCreate()
	this:RegisterEvent("UI_SCALED")
	this:RegisterEvent("PLAYER_EXPERIENCE_UPDATE")
	
	this:RegisterEvent("QUEST_ACCEPTED")
	this:RegisterEvent("QUEST_FAILED")
	this:RegisterEvent("QUEST_CANCELED")
	this:RegisterEvent("QUEST_FINISHED")
	this:RegisterEvent("QUEST_SHARED")
	this:RegisterEvent("QUEST_DATA_UPDATE")
	this:RegisterEvent("QUEST_LIST_UPDATE")
	this:RegisterEvent("QUEST_TIME_UPDATE")
	this:RegisterEvent("SYNC_ROLE_DATA_END")
	
	this:RegisterEvent("SKILL_UPDATE")
	this:RegisterEvent("UI_TRAIN_VALUE_UPDATE")
	
	this:RegisterEvent("MAIL_LIST_UPDATE")
	this:RegisterEvent("PLAYER_FELLOWSHIP_UPDATE")
	this:RegisterEvent("PLAYER_FELLOWSHIP_CHANGE")
	this:RegisterEvent("PLAYER_FOE_UPDATE")
	this:RegisterEvent("CURRENT_PLAYER_FORCE_CHANGED")
	
	this:RegisterEvent("PLAYER_LEVEL_UPDATE")
	
	this:Lookup("", "Handle_Msg"):Clear()
	KeyNotesPanel.OnEvent("UI_SCALED")
end

function KeyNotesPanel.OnEvent(event)
	local hList = this:Lookup("", "Handle_Msg")
	if event == "UI_SCALED" then
		this:SetPoint("TOPRIGHT", 0,0, "TOPRIGHT", -120, 260)
	elseif event == "PLAYER_EXPERIENCE_UPDATE" then
		KeyNotesPanel.UpdateTiLi(hList)
		KeyNotesPanel.UpdateJinLi(hList)
	elseif event == "QUEST_ACCEPTED" or event == "QUEST_FAILED" or event == "QUEST_CANCELED" 
		or event == "QUEST_FINISHED" or event == "QUEST_SHARED" or event == "QUEST_TIME_UPDATE" 
		or event == "QUEST_LIST_UPDATE" or event == "QUEST_DATA_UPDATE" then
		KeyNotesPanel.UpdateQuest(hList)
		KeyNotesPanel.UpdateBreakthrough(hList)
	elseif event == "SKILL_UPDATE" then
		KeyNotesPanel.UpdateSkill(hList)
		KeyNotesPanel.UpdateSize(this)
	elseif event == "UI_TRAIN_VALUE_UPDATE" then
		KeyNotesPanel.UpdateXiuWei(hList)
	elseif event == "MAIL_LIST_UPDATE" then
		KeyNotesPanel.UpdateMail(hList)
	elseif event == "PLAYER_FELLOWSHIP_UPDATE" or event == "PLAYER_FELLOWSHIP_CHANGE" or event == "PLAYER_FOE_UPDATE" then
		KeyNotesPanel.UpdateFriend(hList)
	elseif event == "PLAYER_LEVEL_UPDATE" then
		KeyNotesPanel.UpdateSkill(hList)
		KeyNotesPanel.UpdateSize(this)
	elseif event == "CURRENT_PLAYER_FORCE_CHANGED" then
		KeyNotesPanel.UpdateSkill(hList)
		KeyNotesPanel.UpdateSize(this)	
	elseif event == "SYNC_ROLE_DATA_END" then
		KeyNotesPanel.Update(this)
	end
end

function KeyNotesPanel.Update(frame)
	local handle = frame:Lookup("", "Handle_Msg")
	handle:Clear()
	
	local player = GetClientPlayer()
	if not player then
		return
	end
	
	GetMailClient().ApplyMailList()
	player.UpdateFellowshipInfo()
	player.UpdateFoeInfo()
	
	KeyNotesPanel.UpdateQuest(handle)
	KeyNotesPanel.UpdateSkill(handle)
	KeyNotesPanel.UpdateXiuWei(handle)
	KeyNotesPanel.UpdateTiLi(handle)
	KeyNotesPanel.UpdateJinLi(handle)
	KeyNotesPanel.UpdateMail(handle)
	KeyNotesPanel.UpdateFriend(handle)
--	KeyNotesPanel.UpdateEvent(handle)
	KeyNotesPanel.UpdateJX3Daily(handle)
	KeyNotesPanel.UpdateBreakthrough(handle)
	
	KeyNotesPanel.UpdateSize(frame)
end

function KeyNotesPanel.GetQuestFinishState()
	local nQuestCount, nFinishCount = 0, 0
	local player = GetClientPlayer()
	local aQuest = player.GetQuestTree()
	for k, v in pairs(aQuest) do
		for i, nQuesIndex in pairs(v) do
			nQuestCount = nQuestCount + 1
			local dwID = player.GetQuestID(nQuesIndex)
			local questTrace = player.GetQuestTraceInfo(dwID)
			if questTrace.finish and questTrace.have_trace then
				nFinishCount = nFinishCount + 1
			end
		end
	end
	
	return nQuestCount, nFinishCount
end

function KeyNotesPanel.UpdateQuest(handle)
	local hI = handle:Lookup("Quest")
	if not hI then
		handle:AppendItemFromIni(INI_PATH, "Handle_Title", "Quest")
		hI = handle:Lookup(handle:GetItemCount() - 1)
		hI.bQuest = true
	end
	hI:Lookup("Image_Bg"):SetFrame(KeyNotesPanel.nBgNormal)
	hI:Lookup("Image_Icon"):SetFrame(KeyNotesPanel.nIconQuestNormal)
	hI:Lookup("Image_Expand"):Hide()
	local hT = hI:Lookup("Handle_TN")
	hT:Clear()
	hT:AppendItemFromString("<text>text="..EncodeComponentsString(g_tStrings.NOTE_QUEST_UNFINISHED).."font=163</text>")
	local nCount, nFinish = KeyNotesPanel.GetQuestFinishState()
	local nFont = 162
	if nFinish == nCount then
		nFont = 161
	end
	hT:AppendItemFromString("<text>text="..EncodeComponentsString((nCount - nFinish).."/"..nCount).."font="..nFont.."</text>")
	hT:FormatAllItemPos()
end

function KeyNotesPanel.UpdateSkill(handle)
	local hI = handle:Lookup("Skill")
	local hIC = handle:Lookup("SkillContent")
	if not hI then
		handle:AppendItemFromIni(INI_PATH, "Handle_Title", "Skill")
		hI = handle:Lookup(handle:GetItemCount() - 1)
		hI.bSkill = true

		handle:AppendItemFromIni(INI_PATH, "Handle_Content", "SkillContent")
		hIC = handle:Lookup(handle:GetItemCount() - 1)
		hI.bSkillContent = true
	end
	hI:Lookup("Image_Bg"):SetFrame(KeyNotesPanel.nBgNormal)
	hI:Lookup("Image_Icon"):SetFrame(KeyNotesPanel.nIconSkillNormal)
	hI:Lookup("Image_Expand"):Hide()
	local hT = hI:Lookup("Handle_TN")
	hT:Clear()
	hT:AppendItemFromString("<text>text="..EncodeComponentsString(g_tStrings.NOTE_SKILL_CAN_LEARN).."font=163</text>")
	
	local nCount = 0
	hIC:Clear()
--	hIC:AppendItemFromString("<image>path=\"ui/Image/LootPanel/LootPanel.UITex\" frame=35 imagetype=10</image>")
--	local img = hIC:Lookup(0)
	local player = GetClientPlayer()
	local szSkill = Table_GetLearnSkillInfo(player.nLevel, player.dwForceID)
	for s in string.gmatch(szSkill, "%d+") do
		local dwID = tonumber(s)
		local dwLevel = player.GetSkillLevel(dwID)
		if dwLevel == 0 then
			hIC:AppendItemFromString("<box>w=40 h=40 eventid=256</box>")
			local box = hIC:Lookup(hIC:GetItemCount() - 1)
			box:SetObject(UI_OBJECT_SKILL, dwID, 1)
			box:SetObjectIcon(Table_GetSkillIconID(dwID, 1))
			box.dwID = dwID
			box.dwLevel = 1
			box.bSkillBox = true
			box:SetRelPos(16 + (nCount % 5) * 42, 4 + math.floor(nCount / 5) * 42)
			nCount = nCount + 1
		end
	end
	if nCount == 0 then
--		img:SetSize(0, 0)
		hIC:SetSize(0, 0)
		hIC:Hide()
		hIC.w, hIC.h = 0, 0
	else
		local w, h = 240, 8 + math.ceil(nCount / 5) * 42 
--		img:SetSize(w, h)
		hIC:SetSize(w, h)
		hIC:FormatAllItemPos()
		hIC:Show()
		hIC.w, hIC.h = w, h
		hI:Lookup("Image_Expand"):Show()
		hI:Lookup("Image_Expand"):SetFrame(KeyNotesPanel.nExpandUp)
		if not KeyNotesPanel.bSkillExpand then
			hIC:SetSize(0, 0)
			hIC:Hide()
		end		
	end
	
	local nFont = 161
	if nCount ~= 0 then
		nFont = 162
	end
	hT:AppendItemFromString("<text>text="..EncodeComponentsString(nCount).."font="..nFont.."</text>")
		
	
	hT:FormatAllItemPos()
end

function KeyNotesPanel.GetBreakthroughQuest()
	--取得玩家当前的可做突破任务,返回3个参数。
	--第一个参数表示完成状况，"finish", "level_low", "doing"
	--如果返回doing，第二，第三个参数可以不为空，返回 {dwQuestID, szNpc, szMap}
	
	local player = GetClientPlayer()
	if not player then
		return "level_low"
	end

	if player.nLevel < 50 then
		return "level_low"
	end
		
	if player.nMaxLevel > 50 then
		return "finish"
	end
	
	if player.GetQuestState(BreakthroughQuestLineA[1].dwQuestID) == QUEST_STATE.FINISHED then
		for k, v in ipairs(BreakthroughQuestLineA) do
			if player.GetQuestState(v.dwQuestID) ~= QUEST_STATE.FINISHED then
				return "doing", v
			end
		end
	elseif player.GetQuestState(BreakthroughQuestLineB[1].dwQuestID) == QUEST_STATE.FINISHED then
		for k, v in ipairs(BreakthroughQuestLineB) do
			if player.GetQuestState(v.dwQuestID) ~= QUEST_STATE.FINISHED then
				return "doing", v
			end
		end
	else
		return "doing", BreakthroughQuestLineA[1], BreakthroughQuestLineB[1]
	end
	
	return "finish"	
end

function KeyNotesPanel.UpdateBreakthrough(handle)
	local hI = handle:Lookup("Breakthrough")
	local hIC = handle:Lookup("BreakthroughContent")
	if not hI then
		hI = handle:AppendItemFromIni(INI_PATH, "Handle_Title", "Breakthrough")
		hI.bBreakthrough = true

		hIC = handle:AppendItemFromIni(INI_PATH, "Handle_Content", "BreakthroughContent")
		hIC:SetHandleStyle(3)
		hIC.bBreakthroughContent = true
	end
	hI:Lookup("Image_Bg"):SetFrame(KeyNotesPanel.nBgNormal)
	hI:Lookup("Image_Icon"):SetFrame(KeyNotesPanel.nIconQuestNormal)
	hI:Lookup("Image_Expand"):Hide()
	local hT = hI:Lookup("Handle_TN")
	hT:Clear()
	hT:AppendItemFromString("<text>text="..EncodeComponentsString(g_tBreakthroughString.STR_BREAK).."font=163</text>")
	
	hIC:Clear()
	
	local szState, a, b = KeyNotesPanel.GetBreakthroughQuest()
	if szState == "finish" then
		hIC:AppendItemFromString("<text>text="..EncodeComponentsString(g_tBreakthroughString.STR_FINISH).."font=162</text>")
	elseif szState == "level_low" then
		hIC:AppendItemFromString("<text>text="..EncodeComponentsString(g_tBreakthroughString.STR_UNFINISH).."font=162</text>")
	elseif szState == "doing" then
		if a and b then
			local tQuestStringInfoA = Table_GetQuestStringInfo(a.dwQuestID)
			local tQuestStringInfoB = Table_GetQuestStringInfo(b.dwQuestID)
			local szMsg = FormatString(g_tBreakthroughString.STR_DO_2, a.szMap, a.szNpc, tQuestStringInfoA.szName, b.szMap, b.szNpc, tQuestStringInfoB.szName)
			hIC:AppendItemFromString("<text>text="..EncodeComponentsString(szMsg).."font=162</text>")
		else
			a = a or b
			local tQuestStringInfoA = Table_GetQuestStringInfo(a.dwQuestID)
			local szMsg = FormatString(g_tBreakthroughString.STR_DO_1, a.szMap, a.szNpc, tQuestStringInfoA.szName)
			hIC:AppendItemFromString("<text>text="..EncodeComponentsString(szMsg).."font=162</text>")
		end	
	end
	
	local w, h = 240, 1000
	hIC:SetSize(w, h)
	hIC:FormatAllItemPos()
	hIC:Show()
	local _, h = hIC:GetAllItemSize()
	hIC:SetSize(w, h)
	hIC.w, hIC.h = w, h
	hI:Lookup("Image_Expand"):Show()
	hI:Lookup("Image_Expand"):SetFrame(KeyNotesPanel.nExpandUp)
	if not KeyNotesPanel.bBreakthroughExpand then
		hIC:SetSize(0, 0)
		hIC:Hide()
	end
	
	hT:FormatAllItemPos()
end

function KeyNotesPanel.UpdateXiuWei(handle)
	local hI = handle:Lookup("XiuWei")
	if not hI then
		handle:AppendItemFromIni(INI_PATH, "Handle_Title", "XiuWei")
		hI = handle:Lookup(handle:GetItemCount() - 1)
		hI.bXiuWei = true
	end
	hI:Lookup("Image_Bg"):SetFrame(KeyNotesPanel.nBgNormal)
	hI:Lookup("Image_Icon"):SetFrame(KeyNotesPanel.nIconXiuWeiNormal)
	hI:Lookup("Image_Expand"):Hide()
	local hT = hI:Lookup("Handle_TN")
	hT:Clear()
	hT:AppendItemFromString("<text>text="..EncodeComponentsString(g_tStrings.NOTE_VENATION).."font=163</text>")
	local player = GetClientPlayer()
	local nFont = 162
	if player.nCurrentTrainValue == 0 then
		nFont = 161
	end
	hT:AppendItemFromString("<text>text="..EncodeComponentsString(player.nCurrentTrainValue.."/"..player.nMaxTrainValue).."font="..nFont.."</text>")
	hT:FormatAllItemPos()
end

function KeyNotesPanel.UpdateTiLi(handle)
	local hI = handle:Lookup("TiLi")
	if not hI then
		handle:AppendItemFromIni(INI_PATH, "Handle_Title", "TiLi")
		hI = handle:Lookup(handle:GetItemCount() - 1)
		hI.bTiLi = true
	end
	hI:Lookup("Image_Bg"):SetFrame(KeyNotesPanel.nBgNormal)
	hI:Lookup("Image_Icon"):SetFrame(KeyNotesPanel.nIconTiliNormal)
	hI:Lookup("Image_Expand"):Hide()
	local hT = hI:Lookup("Handle_TN")
	hT:Clear()
	hT:AppendItemFromString("<text>text="..EncodeComponentsString(g_tStrings.NOTE_THEW).."font=163</text>")
	local player = GetClientPlayer()	
	local nFont = 162
	if player.nCurrentThew == 0 then
		nFont = 161
	end
	hT:AppendItemFromString("<text>text="..EncodeComponentsString(player.nCurrentThew.."/"..player.nMaxThew).."font="..nFont.."</text>")
	
	hT:FormatAllItemPos()
end

function KeyNotesPanel.UpdateJinLi(handle)
	local hI = handle:Lookup("JinLi")
	if not hI then
		handle:AppendItemFromIni(INI_PATH, "Handle_Title", "JinLi")
		hI = handle:Lookup(handle:GetItemCount() - 1)
		hI.bJinLi = true
	end
	hI:Lookup("Image_Bg"):SetFrame(KeyNotesPanel.nBgNormal)
	hI:Lookup("Image_Icon"):SetFrame(KeyNotesPanel.nIconJinLiNormal)
	hI:Lookup("Image_Expand"):Hide()
	local hT = hI:Lookup("Handle_TN")
	hT:Clear()
		
	hT:AppendItemFromString("<text>text="..EncodeComponentsString(g_tStrings.NOTE_STAMINA).."font=163</text>")
	local player = GetClientPlayer()
	local nFont = 162
	if player.nCurrentStamina == 0 then
		nFont = 161
	end
	hT:AppendItemFromString("<text>text="..EncodeComponentsString(player.nCurrentStamina.."/"..player.nMaxStamina).."font="..nFont.."</text>")
	
	hT:FormatAllItemPos()
end

function KeyNotesPanel.UpdateMail(handle)
	local hI = handle:Lookup("Mail")
	if not hI then
		handle:AppendItemFromIni(INI_PATH, "Handle_Title", "Mail")
		hI = handle:Lookup(handle:GetItemCount() - 1)
		hI.bMail = true
	end
	hI:Lookup("Image_Bg"):SetFrame(KeyNotesPanel.nBgNormal)
	hI:Lookup("Image_Icon"):SetFrame(KeyNotesPanel.nIconMailNormal)
	hI:Lookup("Image_Expand"):Hide()

	local nUnread, nTotal = GetMailClient().CountMail()

	local hT = hI:Lookup("Handle_TN")
	hT:Clear()
	hT:AppendItemFromString("<text>text="..EncodeComponentsString(g_tStrings.NOTE_MAIL_UNREAD).."font=163</text>")
	local nFont = 162
	if nUnread == 0 then
		nFont = 161
	end
	hT:AppendItemFromString("<text>text="..EncodeComponentsString(nUnread.."/"..nTotal).."font="..nFont.."</text>")
	
	hT:FormatAllItemPos()
end

function KeyNotesPanel.UpdateJX3Daily(hList)
	local hDaily = hList:Lookup("JX3Daily")
	if not hDaily then
		hDaily = hList:AppendItemFromIni(INI_PATH, "Handle_Title", "JX3Daily")
		hDaily.bDaily = true
	end
	hDaily:Lookup("Image_Bg"):SetFrame(KeyNotesPanel.nBgNormal)
	hDaily:Lookup("Image_Icon"):SetFrame(KeyNotesPanel.nIconJX3DailyNormal)
	hDaily:Lookup("Image_Expand"):Hide()
	
	local hTitle = hDaily:Lookup("Handle_TN")
	hTitle:Clear()
	local szTitle = GetFormatText(g_tStrings.NOTE_EVENT_JX3DAILY, 163)
	
	local nCurrentTime = GetCurrentTime()
	local tCurrentTime = TimeToDate(nCurrentTime)
	if tCurrentTime.weekday == 2 or tCurrentTime.weekday == 5 then	-- 周二和周五更新
		if not KeyNotesPanel.tJX3DailyState.tLastResetTime
		or KeyNotesPanel.tJX3DailyState.tLastResetTime.year ~= tCurrentTime.year
		or KeyNotesPanel.tJX3DailyState.tLastResetTime.month ~= tCurrentTime.month
		or KeyNotesPanel.tJX3DailyState.tLastResetTime.day ~= tCurrentTime.day then
			KeyNotesPanel.tJX3DailyState.bRead = false
			KeyNotesPanel.tJX3DailyState.tLastResetTime = tCurrentTime
		end
	end
	
	if KeyNotesPanel.tJX3DailyState.bRead then
		szTitle = szTitle .. GetFormatText(g_tStrings.NOTE_EVENT_JX3DAILY_READ, 161)
	else
		szTitle = szTitle .. GetFormatText(g_tStrings.NOTE_EVENT_JX3DAILY_UNREAD, 165)
	end
	
	hTitle:AppendItemFromString(szTitle)
	hTitle:FormatAllItemPos()
end

function KeyNotesPanel.CountFellowship(nGroupId)
	local nOnline 	= 0
	local nOffLine	= 0

	local aInfo = GetClientPlayer().GetFellowshipInfo(nGroupId)
	if aInfo then
		for k, v in pairs(aInfo) do
			if v.level > 0 then
				nOnline = nOnline + 1
			else
				nOffLine = nOffLine + 1
			end
		end
	end

	return nOnline, nOffLine
end

function KeyNotesPanel.GetFriendCount()
	local nOnline 	= 0
	local nOffLine	= 0
	local player = GetClientPlayer()
	local aGroup = player.GetFellowshipGroupInfo() or {}
	table.insert(aGroup, {id = 0, name = g_tStrings.STR_MAKE_FRIEND})
	for k, v in ipairs(aGroup) do
		local aFriend = player.GetFellowshipInfo(v.id) or {}
		for i, aInfo in ipairs(aFriend) do
			if aInfo.level > 0 then
				nOnline = nOnline + 1
			else
				nOffLine = nOffLine + 1
			end			
		end
	end
	return nOnline, nOffLine
end

function KeyNotesPanel.GetEnemyCount()
	local nOnline 	= 0
	local nOffLine	= 0
	local player = GetClientPlayer()
	local aEnemy = player.GetFoeInfo() or {}
	for k, v in ipairs(aEnemy) do
		if v.level > 0 then
			nOnline = nOnline + 1
		else
			nOffLine = nOffLine + 1
		end			
	end
	return nOnline, nOffLine
end

function KeyNotesPanel.UpdateFriend(handle)
	local hI = handle:Lookup("Friend")
	if not hI then
		handle:AppendItemFromIni(INI_PATH, "Handle_Title", "Friend")
		hI = handle:Lookup(handle:GetItemCount() - 1)
		hI.bFriend = true
	end
	hI:Lookup("Image_Bg"):SetFrame(KeyNotesPanel.nBgNormal)
	hI:Lookup("Image_Icon"):SetFrame(KeyNotesPanel.nIconFriendNormal)
	hI:Lookup("Image_Expand"):Hide()
	
	local nOnlineFriend, nOfflineFriend = KeyNotesPanel.GetFriendCount()
	local nOnlineFoe, nOfflineFoe = KeyNotesPanel.GetEnemyCount()
	
	local hT = hI:Lookup("Handle_TN")
	hT:Clear()
	hT:AppendItemFromString("<text>text="..EncodeComponentsString(g_tStrings.NOTE_FRIEND_ONLINE).."font=163</text>")
	local nFont = 162
	if nOnlineFriend == 0 then
		nFont = 161
	end	
	hT:AppendItemFromString("<text>text="..EncodeComponentsString(nOnlineFriend.."/"..nOnlineFriend + nOfflineFriend).."font="..nFont.."</text>")

	hT:AppendItemFromString("<text>text="..EncodeComponentsString("  " .. g_tStrings.NOTE_ENEMY).."font=163</text>")
	local nFont = 162
	if nOnlineFoe == 0 then
		nFont = 161
	end
	hT:AppendItemFromString("<text>text="..EncodeComponentsString(nOnlineFoe.."/"..nOnlineFoe + nOfflineFoe).."font="..nFont.."</text>")
	
	hT:FormatAllItemPos()
end

function KeyNotesPanel.UpdateEvent(handle)
	local hI = handle:Lookup("Event")
	if not hI then
		handle:AppendItemFromIni(INI_PATH, "Handle_Title", "Event")
		hI = handle:Lookup(handle:GetItemCount() - 1)
		hI.bEvent = true
	end
	hI:Lookup("Image_Bg"):SetFrame(KeyNotesPanel.nBgNormal)
	hI:Lookup("Image_Icon"):SetFrame(KeyNotesPanel.nIconEventNormal)
	hI:Lookup("Image_Expand"):Hide()
	local hT = hI:Lookup("Handle_TN")
	hT:Clear()
	hT:AppendItemFromString("<text>text="..EncodeComponentsString(g_tStrings.NOTE_EVENT_ONLINE).."font=163</text>")
	local nFont = 161
	hT:AppendItemFromString("<text>text="..EncodeComponentsString("0").."font="..nFont.."</text>")
	
	hT:FormatAllItemPos()
end

function KeyNotesPanel.UpdateSize(frame)
	local handle = frame:Lookup("", "")
	local hList = handle:Lookup("Handle_Msg")
	hList:FormatAllItemPos()
	hList:SetSizeByAllItemSize()
	local w, h = hList:GetSize()
	
	handle:Lookup("Image_Bg20"):SetSize(135, h - 50)
	handle:Lookup("Image_Bg21"):SetSize(135, h - 50)
	handle:FormatAllItemPos()
	handle:SetSizeByAllItemSize()
	local w, h = handle:GetSize()
	frame:SetSize(w, h)
end

function KeyNotesPanel.OnItemLButtonDown()
end

function KeyNotesPanel.OnItemLButtonUp()
end

function KeyNotesPanel.OnItemLButtonClick()
	if this.bQuest then
		if IsQuestPanelOpened() then
			CloseQuestPanel()
		else
			OpenQuestPanel()
			
			FireDataAnalysisEvent("KEY_NOTES_QUEST")
		end
	elseif this.bSkill then
		local handle = this:GetParent()
		local hSkill = handle:Lookup("SkillContent")
		if hSkill:IsVisible() then
			hSkill:Hide()
			hSkill:SetSize(0, 0)
			this:Lookup("Image_Expand"):SetFrame(KeyNotesPanel.nExpandDown)
			KeyNotesPanel.bSkillExpand = false
		else
			hSkill:Show()
			hSkill:SetSize(hSkill.w, hSkill.h)
			hSkill:FormatAllItemPos()
			this:Lookup("Image_Expand"):SetFrame(KeyNotesPanel.nExpandUp)
			KeyNotesPanel.bSkillExpand = true
			
			FireDataAnalysisEvent("KEY_NOTES_SKILL")
		end
		KeyNotesPanel.UpdateSize(handle:GetRoot())
	elseif this.bXiuWei then
		if IsChannelsPanelOpened() then
			CloseChannelsPanel()
		else
			OpenChannelsPanel()
			
			FireDataAnalysisEvent("KEY_NOTES_XIUWEI")
		end
	elseif this.bTiLi then
		if IsCraftPanelOpened() then
			CloseCraftPanel()
		else
			OpenCraftPanel()
			
			FireDataAnalysisEvent("KEY_NOTES_TILI")
		end
	elseif this.bJinLi then
		if IsCraftPanelOpened() then
			CloseCraftPanel()
		else
			OpenCraftPanel()
			
			FireDataAnalysisEvent("KEY_NOTES_JINLI")
		end	
	elseif this.bMail then
		FireDataAnalysisEvent("KEY_NOTES_MAIL")
	elseif this.bFriend then
		if IsPartyPanelOpened() then
			ClosePartyPanel()
		else
			OpenPartyPanel()
			
			FireDataAnalysisEvent("KEY_NOTES_FRIEND")
		end
	elseif this.bEvent then
	elseif this.bDaily then
		OpenJX3Daily()
	elseif this.bBreakthrough then
		local handle = this:GetParent()
		local hBreakthrough = handle:Lookup("BreakthroughContent")
		if hBreakthrough:IsVisible() then
			hBreakthrough:Hide()
			hBreakthrough:SetSize(0, 0)
			this:Lookup("Image_Expand"):SetFrame(KeyNotesPanel.nExpandDown)
			KeyNotesPanel.bBreakthroughExpand = false
		else
			hBreakthrough:Show()
			hBreakthrough:SetSize(hBreakthrough.w, hBreakthrough.h)
			hBreakthrough:FormatAllItemPos()
			this:Lookup("Image_Expand"):SetFrame(KeyNotesPanel.nExpandUp)
			KeyNotesPanel.bBreakthroughExpand = true			
		end
		KeyNotesPanel.UpdateSize(handle:GetRoot())
	end
end

function KeyNotesPanel.OnItemLButtonDBClick()
	return KeyNotesPanel.OnItemLButtonClick()
end

function KeyNotesPanel.OnItemMouseEnter()
	if this.bQuest then
		this:Lookup("Image_Bg"):SetFrame(KeyNotesPanel.nBgOver)
		this:Lookup("Image_Icon"):SetFrame(KeyNotesPanel.nIconQuestOver)
	elseif this.bSkill then
		this:Lookup("Image_Bg"):SetFrame(KeyNotesPanel.nBgOver)
		this:Lookup("Image_Icon"):SetFrame(KeyNotesPanel.nIconSkillOver)
	elseif this.bXiuWei then
		this:Lookup("Image_Bg"):SetFrame(KeyNotesPanel.nBgOver)
		this:Lookup("Image_Icon"):SetFrame(KeyNotesPanel.nIconXiuWeiOver)
	elseif this.bTiLi then
		this:Lookup("Image_Bg"):SetFrame(KeyNotesPanel.nBgOver)
		this:Lookup("Image_Icon"):SetFrame(KeyNotesPanel.nIconTiliOver)
	elseif this.bJinLi then
		this:Lookup("Image_Bg"):SetFrame(KeyNotesPanel.nBgOver)
		this:Lookup("Image_Icon"):SetFrame(KeyNotesPanel.nIconJinLiOver)	
	elseif this.bMail then
		this:Lookup("Image_Icon"):SetFrame(KeyNotesPanel.nIconMailOver)
	elseif this.bFriend then
		this:Lookup("Image_Bg"):SetFrame(KeyNotesPanel.nBgOver)
		this:Lookup("Image_Icon"):SetFrame(KeyNotesPanel.nIconFriendOver)
	elseif this.bEvent then
		this:Lookup("Image_Icon"):SetFrame(KeyNotesPanel.nIconEventOver)
	elseif this.bSkillBox then
		this:SetObjectMouseOver(true)
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
		OutputSkillTip(this.dwID, this.dwLevel, {x, y, w, h}, false)
	elseif this.bDaily then
		this:Lookup("Image_Bg"):SetFrame(KeyNotesPanel.nBgOver)
		this:Lookup("Image_Icon"):SetFrame(KeyNotesPanel.nIconJX3DailyOver)
	elseif this.bBreakthrough then
		this:Lookup("Image_Bg"):SetFrame(KeyNotesPanel.nBgOver)
		this:Lookup("Image_Icon"):SetFrame(KeyNotesPanel.nIconQuestOver)	
	end
end

function KeyNotesPanel.OnItemRefreshTip()
	if this.bSkillBox then
		return KeyNotesPanel.OnItemMouseEnter()
	end
end

function KeyNotesPanel.OnItemMouseLeave()
	if this.bQuest then
		this:Lookup("Image_Bg"):SetFrame(KeyNotesPanel.nBgNormal)
		this:Lookup("Image_Icon"):SetFrame(KeyNotesPanel.nIconQuestNormal)
	elseif this.bSkill then
		this:Lookup("Image_Bg"):SetFrame(KeyNotesPanel.nBgNormal)
		this:Lookup("Image_Icon"):SetFrame(KeyNotesPanel.nIconSkillNormal)
	elseif this.bXiuWei then
		this:Lookup("Image_Bg"):SetFrame(KeyNotesPanel.nBgNormal)
		this:Lookup("Image_Icon"):SetFrame(KeyNotesPanel.nIconXiuWeiNormal)
	elseif this.bTiLi then
		this:Lookup("Image_Bg"):SetFrame(KeyNotesPanel.nBgNormal)
		this:Lookup("Image_Icon"):SetFrame(KeyNotesPanel.nIconTiliNormal)
	elseif this.bJinLi then
		this:Lookup("Image_Bg"):SetFrame(KeyNotesPanel.nBgNormal)
		this:Lookup("Image_Icon"):SetFrame(KeyNotesPanel.nIconJinLiNormal)		
	elseif this.bMail then
		this:Lookup("Image_Icon"):SetFrame(KeyNotesPanel.nIconMailNormal)
	elseif this.bFriend then
		this:Lookup("Image_Bg"):SetFrame(KeyNotesPanel.nBgNormal)
		this:Lookup("Image_Icon"):SetFrame(KeyNotesPanel.nIconFriendNormal)
	elseif this.bEvent then
		this:Lookup("Image_Icon"):SetFrame(KeyNotesPanel.nIconEventNormal)
	elseif this.bSkillBox then
		this:SetObjectMouseOver(false)
		HideTip()
	elseif this.bDaily then
		this:Lookup("Image_Bg"):SetFrame(KeyNotesPanel.nBgNormal)
		this:Lookup("Image_Icon"):SetFrame(KeyNotesPanel.nIconJX3DailyNormal)
	elseif this.bBreakthrough then
		this:Lookup("Image_Bg"):SetFrame(KeyNotesPanel.nBgNormal)
		this:Lookup("Image_Icon"):SetFrame(KeyNotesPanel.nIconQuestNormal)		
	end
end

function KeyNotesPanel.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_Close" then
		CloseKeyNotesPanel()
	end
end

function OpenKeyNotesPanel(bDisableSound)
	if IsKeyNotesPanelOpened() then
		return
	end
	
	local frame = Wnd.OpenWindow("KeyNotesPanel")
	KeyNotesPanel.Update(frame)
	
	if not KeyNotesPanel.bAlreadOpened then
		KeyNotesPanel.bAlreadOpened = true
		KeyNotesPanel.nOpenTime = GetTickCount()
	end
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
end

function IsKeyNotesPanelOpened()
	local frame = Station.Lookup("Normal/KeyNotesPanel")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end

function CloseKeyNotesPanel(bDisableSound)
	if not IsKeyNotesPanelOpened() then
		return
	end
	
	if KeyNotesPanel.nOpenTime then
		local nNowTime = GetTickCount()
		FireDataAnalysisEvent("KEY_NOTES_TIME", {KeyNotesPanel.nOpenTime, nNowTime})
		KeyNotesPanel.nOpenTime = nil
	end
	
	Wnd.CloseWindow("KeyNotesPanel")
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end	
end

function IsShowLoginTipIcon()
	return KeyNotesPanel.bShowTipIcon
end

function SetShowLoginTipIcon(bShow)
	KeyNotesPanel.bShowTipIcon = bShow
end

function IsShowLoginTip()
	return KeyNotesPanel.bShowTip
end

function SetShowLoginTip(bShow)
	KeyNotesPanel.bShowTip = bShow
end

