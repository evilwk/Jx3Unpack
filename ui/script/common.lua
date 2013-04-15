-- ��Ч��
g_sound =
{
	ActionFailed = "data\\sound\\����\\ActionFailed.wav",
	Button = "data\\sound\\����\\Button.wav",
	CloseFrame = "data\\sound\\����\\CloseFrame.wav",
	Complete = "data\\sound\\����\\Complete.wav",
	Destroy = "data\\sound\\����\\Destroy.wav",
	DropSkill = "data\\sound\\����\\DropSkill.wav",
	Friend = "data\\sound\\����\\Friend.wav",
	Gift = "data\\sound\\����\\Gift.wav",
	Invite = "data\\sound\\����\\Invite.wav",
	LevelUp = "data\\sound\\����\\LevelUp.wav",
	Mail = "data\\sound\\����\\Mail.wav",
	MapHit = "data\\sound\\����\\MapHit.wav",
	MapTipShare = "data\\sound\\����\\MapTipShare.wav",
	NewMail = "data\\sound\\����\\NewMail.wav",
	OpenFrame = "data\\sound\\����\\OpenFrame.wav",
	Ornamental = "data\\sound\\����\\Ornamental.wav",
	PickupArmer = "data\\sound\\����\\PickupArmer.wav",
	PickupChina = "data\\sound\\����\\PickupChina.wav",
	PickupCloth = "data\\sound\\����\\PickupCloth.wav",
	PickupHerb = "data\\sound\\����\\PickupHerb.wav",
	PickupIron = "data\\sound\\����\\PickupIron.wav",
	PickupMoney = "data\\sound\\����\\PickupMoney.wav",
	PickupPaper = "data\\sound\\����\\PickupPaper.wav",
	PickupRing = "data\\sound\\����\\PickupRing.wav",
	PickupRock = "data\\sound\\����\\PickupRock.wav",
	PickupWater = "data\\sound\\����\\PickupWater.wav",
	PickupMeat = "data\\sound\\����\\PickupMeat.wav",
	PickupFood = "data\\sound\\����\\PickupFood.wav",
	PickupPill = "data\\sound\\����\\PickupPill.wav",
	Practice = "data\\sound\\����\\Practice.wav",
	Repair= "data\\sound\\����\\Repair.wav",
	Sell = "data\\sound\\����\\Sell.wav",
	TakeUpSkill = "data\\sound\\����\\TakeUpSkill.wav",
	Trade = "data\\sound\\����\\Trade.wav",
	PickupWeapon01 = "data\\sound\\����\\PickupWeapon01.wav",
	PickupWeapon02 = "data\\sound\\����\\PickupWeapon02.wav",
	PickupWeapon03 = "data\\sound\\����\\PickupWeapon03.wav",
	PickupWeapon04 = "data\\sound\\����\\PickupWeapon04.wav",
	Whisper = "data\\sound\\����\\Whisper.wav",
	OpenAuction = "data\\sound\\����\\Auction01.wav",
	CloseAuction = "data\\sound\\����\\Auction02.wav",
	FinishAchievement = "data\\sound\\����\\FinishAchievement.wav",
	FEAddMainDiamond = "data\\sound\\����\\stone1st.wav",
	FEAddDiamond = "data\\sound\\����\\stone2rd.wav",
	FEProduceDiamondFail = "data\\sound\\����\\stonefail.wav",
	FEProduceEquipFail = "data\\sound\\����\\itemfail.wav",
	FEExtractSuccess = "data\\sound\\����\\stonepick.wav",
	
	Fly = "data\\sound\\����\\Fly.wav",
	Enter = "data\\sound\\����\\Enter.wav",
	Hover = "data\\sound\\����\\Hover.wav",
	Fly1 = "data\\sound\\����\\Fly1.wav",
	Fly_f1 = "data\\sound\\����\\Fly_f1.wav",
	Fly_f2 = "data\\sound\\����\\Fly_f2.wav",
	Fly_m2 = "data\\sound\\����\\Fly_m2.wav",
	PeiYin = "data\\sound\\����\\PeiYin.wav",
	Disappear = "data\\sound\\����\\Disappear.wav",
	ButtonDown = "data\\sound\\����\\ButtonDown.wav",
	
	ChapterBG = "data\\sound\\����\\Chapters.wav",
};

function IsEmpty(tTable)
	for _, _ in pairs(tTable) do
		return false
	end
	return true
end

function OnItemLinkDown(hItem)
	local szName = hItem:GetName()
	if szName == "itemlink" then --��Ʒ����
		local dwID = hItem:GetUserData()
		if IsCtrlKeyDown() then
			if IsGMPanelReceiveItem() then
				GMPanel_LinkItem(dwID)
			else		
				EditBox_AppendLinkItem(dwID)
			end
		else
			local x, y = hItem:GetAbsPos()
			local w, h = hItem:GetSize()
			OutputItemTip(UI_OBJECT_ITEM_ONLY_ID, dwID, nil, nil, {x, y, w, h}, true)
		end
	elseif szName == "iteminfolink" then
		if IsCtrlKeyDown() then
			if IsGMPanelReceiveItem() then
				GMPanel_LinkItemInfo(hItem.nVersion, hItem.dwTabType, hItem.dwIndex)
			else
				EditBox_AppendLinkItemInfo(hItem.nVersion, hItem.dwTabType, hItem.dwIndex)
			end
		else	
			local x, y = hItem:GetAbsPos()
			local w, h = hItem:GetSize()
			OutputItemTip(UI_OBJECT_ITEM_INFO, hItem.nVersion or 0, hItem.dwTabType, hItem.dwIndex, {x, y, w, h}, true)
		end
	elseif szName == "questlink" then 
		local dwQuestID = hItem:GetUserData()
		if IsCtrlKeyDown() then
			if IsGMPanelReceiveQuest() then
				GMPanel_LinkQuest(dwQuestID)
			else
				EditBox_AppendLinkQuest(dwQuestID)
			end
		else
			local x, y = hItem:GetAbsPos()
			local w, h = hItem:GetSize()
			OutputQuestTip(dwQuestID, {x, y, w, h}, true)
		end
	elseif szName == "recipelink" then
		if IsCtrlKeyDown() then
			EditBox_AppendLinkRecipe(hItem.dwCraftID, hItem.dwRecipeID)
		else
			local x, y = hItem:GetAbsPos()
			local w, h = hItem:GetSize()
			OutputRecipeLink(hItem.dwCraftID, hItem.dwRecipeID, {x, y, w, h})
		end
	elseif szName == "enchantlink" then
		if IsCtrlKeyDown() then
			EditBox_AppendLinkEnchant(hItem.dwProID, hItem.dwCraftID, hItem.dwRecipeID)
		else
			local x, y = hItem:GetAbsPos()
			local w, h = hItem:GetSize()
			OutputEnchantLink(hItem.dwProID, hItem.dwCraftID, hItem.dwRecipeID, {x, y, w, h})
		end
	elseif szName == "skilllink" then
		if IsCtrlKeyDown() then
			if IsGMPanelReceiveSkill() then
				GMPanel_LinkSkill(hItem.skillKey.skill_id, hItem.skillKey.skill_level)
			else
				EditBox_AppendLinkSkill(hItem.skillKey)
			end
		else
			local x, y = hItem:GetAbsPos()
			local w, h = hItem:GetSize()
			OutputSkillLink(hItem.skillKey, {x, y, w, h})
		end
	elseif szName == "skillrecipelink" then
		if IsCtrlKeyDown() then
			EditBox_AppendLinkSkillRecipe(hItem.dwID, hItem.dwLevel)
		else
			local x, y = hItem:GetAbsPos()
			local w, h = hItem:GetSize()
			OutputSkillRecipeTip(hItem.dwID, hItem.dwLevel, {x, y, w, h}, true)
		end
	elseif szName == "namelink" then
		local szText = hItem:GetText()
		if string.sub(szText, -1, -1) == "]" then
			szText = string.sub(szText, 2, -2)
		else
			szText = string.sub(szText, 2, -3)
		end
		if IsCtrlKeyDown() then
			if IsGMPanelReceivePlayer() then
				GMPanel_LinkPlayerName(szText)
			else
				EditBox_AppendLinkPlayer(szText)
			end
		else
			EditBox_TalkToSomebody(szText)
		end
	elseif szName == "booklink" then
		if IsCtrlKeyDown() then
			EditBox_AppendLinkItemInfo(hItem.nVersion, hItem.dwTabType, hItem.dwIndex, hItem.nBookRecipeID)
		else
			local x, y = hItem:GetAbsPos()
			local w, h = hItem:GetSize()
			OutputItemTip(UI_OBJECT_ITEM_INFO, hItem.nVersion, hItem.dwTabType, hItem.dwIndex, {x, y, w, h}, true, nil, nil, nil, hItem.nBookRecipeID)
		end
	elseif szName == "achievementlink" then
		if IsCtrlKeyDown() then
			EditBox_AppendLinkAchievement(hItem.dwID)
		else
			local x, y = hItem:GetAbsPos()
			local w, h = hItem:GetSize()
			OutputAchievementTip(hItem.dwID, {x, y, w, h})
		end
	elseif szName == "designationlink" then
		if IsCtrlKeyDown() then
			EditBox_AppendLinkDesignation(hItem.dwID, hItem.bPrefix)
		else
			local x, y = hItem:GetAbsPos()
			local w, h = hItem:GetSize()
			OutputDesignationTip(hItem.dwID, hItem.bPrefix, {x, y, w, h}, true)
		end
	elseif szName == "eventlink" then
		if IsCtrlKeyDown() then
			EditBox_AppendEventLink(hItem.szName, hItem.szLinkInfo)
		else
			local nArg = arg0
			arg0 = hItem.szLinkInfo
			FireEvent("EVENT_LINK_NOTIFY")
			arg0 = nArg
		end
	elseif szName == "msglink" then
		EditBox_TalkInMsg(this.szName)
	end
end

function GetQuestTipIconAndFont(dwQuestID, hPlayer)
	local nFrame, nFont = 0, 0	
	local nDifficult = hPlayer.GetQuestDiffcultyLevel(dwQuestID)
	if nDifficult == QUEST_DIFFICULTY_LEVEL.PROPER_LEVEL then
		nFrame, nFont = 2, 99	-- ��
	elseif nDifficult == QUEST_DIFFICULTY_LEVEL.HIGH_LEVEL then
		nFrame, nFont = 5, 158	-- ��
	elseif nDifficult == QUEST_DIFFICULTY_LEVEL.HIGHER_LEVEL then
		nFrame, nFont = 1, 102	-- ��
	elseif nDifficult == QUEST_DIFFICULTY_LEVEL.LOW_LEVEL then
		nFrame, nFont = 4, 173	-- ��
	elseif nDifficult == QUEST_DIFFICULTY_LEVEL.LOWER_LEVEL then
		nFrame, nFont = 3, 110	-- ��
	else
		nFrame, nFont = 2, 99	-- ��
	end
	return nFrame, nFont
end

function OutputActivityTip(dwActivityID, Rect)
	local tActive = Table_GetCalenderActivity(dwActivityID)
	local szTip = GetFormatText(tActive.szName .. "\n", 0)
	-- level ��ʾ��ʱ��ȥ�����ķֺ�
	local nLength = string.len(tActive.szLevel)
	local szLevel = string.sub(tActive.szLevel, 1, nLength - 1)
	local nTitleFont = 27
	szTip = szTip .. GetFormatText(g_tStrings.CYCLOPAEDIA_NOTE_LEVEL, nTitleFont) .. GetFormatText(szLevel .. "\n", 0)
	szTip = szTip .. GetFormatText(g_tStrings.CYCLOPAEDIA_NOTE_HARD, nTitleFont) .. GetFormatText(tActive.szHard .. "\n", 0)
	szTip = szTip .. GetFormatText(g_tStrings.CYCLOPAEDIA_NOTE_TIME, nTitleFont) .. GetFormatText(tActive.szTimeRepresent .. "\n", 0)
	szTip = szTip .. GetFormatText(g_tStrings.CYCLOPAEDIA_NOTE_MAP, nTitleFont) .. GetFormatText(tActive.szDetailMap .. "\n", 0)
	szTip = szTip .. GetFormatText(g_tStrings.CYCLOPAEDIA_NOTE_AWARD, nTitleFont) .. GetFormatText(tActive.szDetailAwards .. "\n", 0)
	szTip = szTip .. GetFormatText(g_tStrings.CYCLOPAEDIA_NOTE_TEXT, nTitleFont) .. GetFormatText(tActive.szText .. "\n", 0)
	OutputTip(szTip, 600, Rect, nil, true, "Activity" .. dwActivityID)
end

function OutputFieldPQTip(dwPQTemplateID, Rect, bLink)
	local tFieldPQ = Table_GetFieldPQ(dwPQTemplateID)
	local nTitleFont = 27
	local szTip = GetFormatText(tFieldPQ.szName .. "\n", nTitleFont)
	szTip = szTip .. GetFormatText(tFieldPQ.szDesc)
	OutputTip(szTip, 400, Rect, nil, bLink, "FieldPQ" .. dwPQTemplateID)
end

function OutputQuestTip(dwQuestID, Rect, bLink)
    local questInfo = GetQuestInfo(dwQuestID)
    local tQuestStringInfo = Table_GetQuestStringInfo(dwQuestID)
    if not questInfo then
    	Trace("get questInfo failed when OutputQuestTip\n")
    	return
    end
    
	local player = GetClientPlayer()
    local _, nFont = GetQuestTipIconAndFont(dwQuestID, player)
    
	local szTip = "<Text>text="..EncodeComponentsString(tQuestStringInfo.szName.."\n").." font="..nFont.." </text>"
	
	
	
	if player.GetQuestState(dwQuestID) == QUEST_STATE.FINISHED then
		szTip = szTip.."<Text>text="..EncodeComponentsString(g_tStrings.STR_QUEST_FINISHED.."\n").." font=106 </text>"
	else
		szTip = szTip.."<Text>text="..EncodeComponentsString(g_tStrings.STR_QUEST_UNFINISHED.."\n").." font=102 </text>"
	end
	
	local szQuestClass = Table_GetQuestClass(questInfo.dwQuestClassID)
	szTip = szTip.."<Text>text="..EncodeComponentsString(szQuestClass.."\n").." font=106 </text>"
    szTip = szTip.."<Text>text="..EncodeComponentsString(g_tStrings.TIP_START_LEVEL..questInfo.nMinLevel.."\n").." font=106 </text>"
    
    local bStart = false
    if questInfo.dwStartNpcTemplateID ~= 0 then
    	szTip = szTip.."<Text>text="..EncodeComponentsString(g_tStrings.TIP_START..Table_GetNpcTemplateName(questInfo.dwStartNpcTemplateID)).." font=106 </text>"
    	bStart = true
    elseif questInfo.dwStartItemType ~= 0 and questInfo.dwStartItemIndex ~= 0 then
    	local itemInfo = GetItemInfo(questInfo.dwStartItemType, questInfo.dwStartItemIndex)
    	if itemInfo then
    		szTip = szTip.."<Text>text="..EncodeComponentsString(g_tStrings.TIP_START..GetItemNameByItemInfo(itemInfo)..g_tStrings.TIP_ITEM).." font=106 </text>"
    		bStart = true
    	end
    end
    
    local tQuestPosInfo = nil
    if bStart or questInfo.dwEndNpcTemplateID ~= 0 then
    	tQuestPosInfo = g_tTable.Quest:Search(dwQuestID)
    end
    
    if bStart then
    	if tQuestPosInfo and tQuestPosInfo.szAccept ~= "" then
    		szTip = szTip.."<image>w=24 h=24 path=\"ui/Image/QuestPanel/QuestPanel.UITex\" frame=13 eventid=341 name=\"accept\" </image>"
    	end
		szTip = szTip.."<text>text=\"\\\n\" font=106 </text>"
	end

    
    if questInfo.dwEndNpcTemplateID ~= 0 then
    	szTip = szTip .. GetFormatText(g_tStrings.TIP_END .. Table_GetNpcTemplateName(questInfo.dwEndNpcTemplateID), 106)
		if tQuestPosInfo and tQuestPosInfo.szFinish ~= "" then
			szTip = szTip.."<image>w=24 h=24 path=\"ui/Image/QuestPanel/QuestPanel.UITex\" frame=13 eventid=341 name=\"finish\" </image>"
		end
		szTip = szTip.."<text>text=\"\\\n\" font=106 </text>"
    end
    
    local szPrev = ""
    local nCount = 0
	for i = 1, 4, 1 do
    	if questInfo["dwPrequestID"..i] ~= 0 then
    		local qPrev = GetQuestInfo(questInfo["dwPrequestID"..i])
    		local tPrevQuestStringInfo = Table_GetQuestStringInfo(questInfo["dwPrequestID"..i])
    		if tPrevQuestStringInfo then
    			szPrev = szPrev.."<Text>text="..EncodeComponentsString("["..tPrevQuestStringInfo.szName.."]\n").." font="..nFont..
    			" eventid=341 name=\"prev\" script=\"this.dwQuestID = "..questInfo["dwPrequestID"..i].."\" </text>"
    			nCount = nCount + 1
    		end
    	end
	end
	if nCount > 0 then
		local szPrevTitle = g_tStrings.TIP_PREQUEST
		if nCount > 1 then
	    	if questInfo.bPrequestLogic then
	    		szPrevTitle = g_tStrings.TIP_PREQUEST_ALL_FINISHED
	    	else
	    		szPrevTitle = g_tStrings.TIP_PREQUEST_ONE_OF
	    	end
	    end
		szTip = szTip.."<Text>text="..EncodeComponentsString(szPrevTitle).." font=100 </text>"..szPrev
	end
	
	szTip = szTip.."<Text>text="..EncodeComponentsString(g_tStrings.TIP_QUEST_TARGET).." font=100 </text>"
    
    OutputTip(szTip, 345, Rect, nil, bLink, "quest"..dwQuestID)
    local handle = GetTipHandle(bLink, "quest"..dwQuestID)
    
    local img = handle:Lookup("accept")
    if img then
    	img:SetFrame(36)
    	img.dwQuestID = dwQuestID
    	img.OnItemMouseEnter = function()
    		local x, y = this:GetAbsPos()
    		local w, h = this:GetSize()
    		OutputTip("<Text>text="..EncodeComponentsString(g_tStrings.QUEST_LOOKUP_ACCEPT_PLACE).." font=100 </text>", 345, {x, y, w, h})
    		this:SetFrame(37)
    	end
    	img.OnItemMouseLeave = function()
    		HideTip()
    		this:SetFrame(36)
    	end
    	img.OnItemLButtonClick = function()
				OnMarkQuestTarget(this.dwQuestID, "accept", 0)
    	end
    end

    local img = handle:Lookup("finish")
    if img then
    	img:SetFrame(32)
    	img.dwQuestID = dwQuestID
    	img.OnItemMouseEnter = function()
    		local x, y = this:GetAbsPos()
    		local w, h = this:GetSize()
    		OutputTip("<Text>text="..EncodeComponentsString(g_tStrings.QUEST_LOOKUP_FINISH_PLACE).." font=100 </text>", 345, {x, y, w, h})
    		this:SetFrame(33)
    	end
    	img.OnItemMouseLeave = function()
    		this:SetFrame(32)
    	end
    	img.OnItemLButtonClick = function()
				OnMarkQuestTarget(this.dwQuestID, "finish", 0)
    	end
    end
    
    local text = handle:Lookup("prev")
    if text then
    	text.OnItemLButtonClick = function()
			local x, y = this:GetAbsPos()
			local w, h = this:GetSize()
			OutputQuestTip(this.dwQuestID, {x, y, w, h},true)
		end
    end
    
	QuestAcceptPanel.EncodeString(handle, tQuestStringInfo.szObjective.."\n", 162)
	
	if questInfo.nFinishTime ~= 0 then
		local szTime = ""
		local h, m, s = GetTimeToHourMinuteSecond(questInfo.nFinishTime)
		if h > 0 then
			szTime = szTime..h..g_tStrings.STR_BUFF_H_TIME_H
		end
		if h > 0 or m > 0 then
			szTime = szTime..m..g_tStrings.STR_BUFF_H_TIME_M_SHORT
		end
		szTime = szTime..s..g_tStrings.STR_BUFF_H_TIME_S
		handle:AppendItemFromString("<text>text="..EncodeComponentsString(g_tStrings.STR_TWO_CHINESE_SPACE..g_tStrings.STR_QUEST_TIME_LIMIT..szTime.."\n").."font=0</text>")
	end
	
	local MarkQuestTrace = function(hHandle, dwQuestID, szType, nIndex)
		if Table_GetQuestPosInfo(dwQuestID, szType, nIndex) then
			hHandle:AppendItemFromString(GetFormatImage("ui/Image/QuestPanel/QuestPanel.UITex", 40, 35, 24, 341))
			local hImage = hHandle:Lookup(handle:GetItemCount() - 1)
			hImage.dwQuestID = dwQuestID
			hImage.nIndex = nIndex
			hImage.szType = szType
			hImage.OnItemMouseEnter = function()
				this:SetFrame(41)
				local x, y = this:GetAbsPos()
	    		local w, h = this:GetSize()
	    		local szTip = GetFormatText(g_tStrings.QUEST_LOOKUP_TARGET, 100)
	    		OutputTip(szTip, 345, {x, y, w, h})
			end
			
			hImage.OnItemMouseLeave = function()
				this:SetFrame(40)
			end
			
			hImage.OnItemLButtonClick = function()
				OnMarkQuestTarget(this.dwQuestID, this.szType, this.nIndex)
			end
		end
	end

	for i = 1, 8, 1 do
		if questInfo["nQuestValue"..i] ~= 0 then
			handle:AppendItemFromString(GetFormatText(g_tStrings.STR_TWO_CHINESE_SPACE..tQuestStringInfo["szQuestValueStr"..i].."��"..questInfo["nQuestValue"..i], 60))
			MarkQuestTrace(handle, dwQuestID, "quest_state", i - 1)
			handle:AppendItemFromString(GetFormatText("\n"))
		end
	end

	for i = 1, 4, 1 do
		if questInfo["dwKillNpcTemplateID"..i] ~= 0 then
			handle:AppendItemFromString("<text>text="..EncodeComponentsString(
				g_tStrings.STR_TWO_CHINESE_SPACE..Table_GetNpcTemplateName(questInfo["dwKillNpcTemplateID"..i]).."��"..questInfo["dwKillNpcAmount"..i]).."font=60</text>")
			MarkQuestTrace(handle, dwQuestID, "kill_npc", i - 1)
			handle:AppendItemFromString(GetFormatText("\n"))
		end
	end

	for i = 1, 4, 1 do
		local dwTab, dwIndex = questInfo["dwEndRequireItemType"..i], questInfo["dwEndRequireItemIndex"..i]
		if dwTab ~= 0 and dwIndex ~= 0 then
			local bHave = false
			for j = 1, i - 1, 1 do
				if questInfo["dwEndRequireItemType"..j] == dwTab and questInfo["dwEndRequireItemIndex"..j] == dwIndex then
					bHave = true
					break
				end
			end
			if not bHave then
				local itemInfo = GetItemInfo(dwTab, dwIndex)
				handle:AppendItemFromString("<text>text="..EncodeComponentsString(
					g_tStrings.STR_TWO_CHINESE_SPACE..GetItemNameByItemInfo(itemInfo).."��"..questInfo["dwEndRequireItemAmount"..i]).."font=60</text>")
				MarkQuestTrace(handle, dwQuestID, "need_item", i - 1)
				handle:AppendItemFromString(GetFormatText("\n"))
			end
		end
	end	

	QuestAcceptPanel.UpdateHortation(handle, questInfo, false, false, true)
	
    OutputTip("", 345, Rect, nil, bLink, "quest"..dwQuestID, true)
end

COLOR_TABLE = {
	[0] = 31,		-- �����ר�������� TITLE ���ֵ�
	[1] = 100,		-- ��ɫ
	[2] = 101,		-- ��ɫ
	[3] = 102,		-- ��ɫ
	[4] = 103,		-- ��ɫ
	[5] = 104,		-- ��ɫ
	[6] = 105,		-- ��ɫ
	[7] = 106,		-- ��ɫ
	[8] = 107,		-- ��ɫ����4
	[9] = 108,		-- ��ɫ����3
	[10] = 109,		-- ��ɫ����2
	[11] = 110,		-- ��ɫ����1
	[12] = 111,		-- �ۺ�
	[13] = 112,		-- ����
	[14] = 113,		-- ����
	}
function ColorText(szText, nColorIndex)
	if not nColorIndex or nColorIndex > 14 or nColorIndex < 0 then nColorIndex = 7 end
	local szColoredText = "<text>text="..EncodeComponentsString(szText).."font="..COLOR_TABLE[nColorIndex].."</text>"
	return szColoredText
end

-- START TIPS

g_aGameWorldTip = 
{
	[0] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"Ĭ������"
		local szTip =	ColorText("δ�����Ϣ\n", 0) .. 
						ColorText("�㻹û�л�ô���Ϣ��\n���ְ�����ص���Ϣ����ͨ�����µĽ�չ½����õġ�\n\n", 7)
		OutputTip(szTip, 400, rect)
	end,
	[1] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"Ĭ������"
		local szTip =	ColorText("��ʾ����\n", 0) .. 
						ColorText("��������صĵ��߳�ʾ���Է������������µĻ������ָ��ì�ܵȡ�\n\n", 7) .. 
						ColorText("��Щ���߲���ռ�ñ�����", 6)
		OutputTip(szTip, 400, rect)
	end,
	[2] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"Ĭ������"
		local szTip =	ColorText("ָ���������\n", 0) .. 
						ColorText("��������ص�������ߴ�����֪�Է������������µĻ������ָ��ì�ܵȡ�\n\n", 7) .. 
						ColorText("���������Ϣ������Ϸ�������Զ�׷�ӡ�", 6)
		OutputTip(szTip, 400, rect)
	end,
	[3] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"Ĭ������"
		local szTip =	ColorText("��ʾ��������\n", 0) .. 
						ColorText("��������ص����ϸ�֪�Է������������µĻ������ָ��ì�ܵȡ�\n\n", 7) .. 
						ColorText("�������ϻ�����Ϸ�������Զ�׷�ӡ�", 6)
		OutputTip(szTip, 400, rect)
	end,
	[4] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"Ĭ������"
		local szTip =	ColorText("�������\n", 0) .. 
						ColorText("�ڶԻ������У��������ʻ�����ì�ܵ�̸�����ݽ������ʣ����ܻ���µ���Ϣ��\n\n", 7) .. 
						ColorText("��������Է��ķ��С�", 6)
		OutputTip(szTip, 400, rect)
	end,
	[5] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"Ĭ������"
		local szTip =	ColorText("���Է���һ�仰\n", 0) .. 
						ColorText("Ŀ����ܻ��ж�仰���˰�ť�����ع���һ��Ի����ݡ�\n\n", 7)
		OutputTip(szTip, 400, rect)
	end,
	[6] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"Ĭ������"
		local szTip =	ColorText("�ɲ��õ�֤��\n", 0) .. 
						ColorText("��������ص�֤�ݳ�ʾ���Է������������µĻ������ָ��ì�ܵȡ�\n\n", 7)
		OutputTip(szTip, 400, rect)
	end,
	[7] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"Ĭ������"
		local szTip =	ColorText("ָ���������\n", 0) .. 
						ColorText("��������ص�������ߴ�����֪�Է������������µĻ������ָ��ì�ܵȡ�\n\n", 7) .. 
						ColorText("ÿ�仰���������ݲ������˲�����", 3)
		OutputTip(szTip, 400, rect)
	end,
	[8] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"Ĭ������"
		local szTip =	ColorText("��ʾ��������\n", 0) .. 
						ColorText("��������ص����ϸ�֪�Է������������µĻ������ָ��ì�ܵȡ�\n\n", 7) .. 
						ColorText("ÿ�仰���������ݲ������˲�����", 3)
		OutputTip(szTip, 400, rect)
	end,
	[9] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"Ĭ������"
		local szTip =	ColorText("�������\n", 0) .. 
						ColorText("�ڶԻ������У��������ʻ�����ì�ܵ�̸�����ݽ���ѯ�ʣ����ܻ���µ���Ϣ��\n\n", 7)
		OutputTip(szTip, 400, rect)
	end,
	[10] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"Ĭ������"
		local szTip =	ColorText("���Է���һ�仰\n", 0) .. 
						ColorText("Ŀ����ܻ��ж�仰���˰�ť������ת����һ��Ի����ݡ�", 7)
		OutputTip(szTip, 400, rect)
	end,
	[11] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"Ĭ������"
		local szTip =	ColorText("������֤��\n", 0) .. 
						ColorText("ʬ�屻���ֵ�ʱ����ƽ���ڵ����ϣ�����ʱ������", 7) .. 
						ColorText("��ʱ��һ��", 3) .. 
						ColorText("������������", 7) .. 
						ColorText("�ؿڵļ������ˣ��������ϣ�Ӧ������������", 3) .. 
						ColorText("�������������Աߡ���Χ�в����ĺۼ���", 7)
		OutputTip(szTip, 400, rect)
	end,
	[12] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"Ĭ������"
		local szTip =	ColorText("���ϵ�֤��\n", 0) .. 
						ColorText("������Ǹ���Ů����˵��ϸ��ϸ��ģ�ƽʱ���Ų������Ų�����Ҳ���Ҽ����뷿����ȥ�������塣", 7)
		OutputTip(szTip, 400, rect)
	end,
	[13] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"Ĭ������"
		local szTip =	ColorText("���ϵ�֤��\n", 0) .. 
						ColorText("���㰡����", 7) .. 
						ColorText("����ļ����ܸߣ���Ҳ���侲������û�嶯��", 3) .. 
						ColorText("����˵һ��Ĺ��ֶ��²������ء�", 7)
		OutputTip(szTip, 400, rect)
	end,
	[14] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"Ĭ������"
		local szTip =	ColorText("�������֤��\n", 0) .. 
						ColorText("���찡�������Ҽ������£�", 7) .. 
						ColorText("�����û���š�", 3)
		OutputTip(szTip, 400, rect)
	end,
	[15] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"Ĭ������"
		local szTip =	ColorText("�������֤��\n", 0) .. 
						ColorText("�������������ȷ�������������ˣ�����ʱ���Ҽǲ�ס�ˣ������", 7) .. 
						ColorText("����֮��", 3) .. 
						ColorText("�ɡ�", 7)
		OutputTip(szTip, 400, rect)
	end,
	[16] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"Ĭ������"
		local szTip =	ColorText("�����֤��\n", 0) .. 
						ColorText("�����ص��ң��ҾͿ�����������ڲ������ҾͿ�ʼ��������ʱ�����˴��˷��һ�����ܵ��ˡ�", 7)
		OutputTip(szTip, 400, rect)
	end,
	[17] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"Ĭ������"
		local szTip =	ColorText("���ݵ���֦\n", 0) .. 
						ColorText("��������ʯ�ҵ��ս�����֦����ʯ����������о綾��", 7)
		OutputTip(szTip, 400, rect)
	end,
	[18] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"Ĭ������"
		local szTip =	ColorText("������ʿ��֤��\n", 0) .. 
						ColorText("��һλ���ֵĻ�ʦ�������ӣ����Ҹ���������ʯ��", 7)
		OutputTip(szTip, 400, rect)
	end,
	[19] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"Ĭ������"
		local szTip =	ColorText("������֤��\n", 0) .. 
						ColorText("�����估�ַ����ŵµ����ӣ������������ɱ�������Ű׳�ʧ�١�\n�估������ǰ�������к������д��估δ�죬�������ˡ��д�֮�˼��п������Ű׳���", 7)
		OutputTip(szTip, 400, rect)
	end,
	[20] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"Ĭ������"
		local szTip =	ColorText("ҹ����\n", 0) .. 
						ColorText("���ڽ�ˮ�򶫱��Ŀ�լ�����ҹ���£����䱻����һ�����ӣ����滹մ��Ѫ�ա�", 7)
		OutputTip(szTip, 400, rect)
	end,
	[21] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"Ĭ������"
		local szTip =	ColorText("�估����ʬ����\n", 0) .. 
						ColorText("����ʱ������������ҹ��ʱ������ԭ������һ���廨���������Ҫ������", 7)
		OutputTip(szTip, 400, rect)
	end,
	[22] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"Ĭ������"
		local szTip =	ColorText("�������廨��\n", 0) .. 
						ColorText("����廨���е��ر𣬰�����ͭ���ƣ��ϰ벿������ɫ���°벿���ǽ�ɫ��", 7)
		OutputTip(szTip, 400, rect)
	end,
	[23] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"Ĭ������"
		local szTip =	ColorText("���͵�֤��\n", 0) .. 
						ColorText("�������Ҵҵش���ͷ�ܻ�����������͵�˵��ʲô��Ȼ��ͳ�����һȺ����������ȥ�ˡ�֮������ڷ�����һֱûʲô�������ڶ����������ֵ�������ȥ��ʱ��", 7)
		OutputTip(szTip, 400, rect)
	end,
	[24] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"Ĭ������"
		local szTip =	ColorText("С�л���֤��\n", 0) .. 
						ColorText("�Ǹ����Ǹ���Ʋ�ӣ��ţ�û����������ʯ���������������õ����֣�������û�����������֣�����Ҽǵú�������ҵ�ʱ�����Ƶģ���ˮ����û��������Ʋ�ӵİ���", 7)
		OutputTip(szTip, 400, rect)
	end,
	[25] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"Ĭ������"
		local szTip =	ColorText("�����֤��һ\n", 0) .. 
						ColorText("�����ҳ����������廨��ȥ�ˡ��ҵ��廨�뱻���������ȥ���̸�Ū���ˡ�", 7)
		OutputTip(szTip, 400, rect)
	end,
	[26] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"Ĭ������"
		local szTip =	ColorText("�����֤�ʶ�\n", 0) .. 
						ColorText("�����������ֱ������ˣ����˺ö�Ѫ�����˵���˵����ˡ�˵������˵�������־͸����ˡ�", 7)
		OutputTip(szTip, 400, rect)
	end,
	[27] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"Ĭ������"
		local szTip =	ColorText("������������\n", 0) .. 
						ColorText("�����Ǳ�������ȥ��������廨�롣", 7)
		OutputTip(szTip, 400, rect)
	end,
	[28] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"Ĭ������"
		local szTip =	ColorText("�ְ����Ļ�\n", 0) .. 
						ColorText("�ְ������Ļ��������ɫ�������������ʯ����ͼ�����������ʯ�۱���ж�������", 7)
		OutputTip(szTip, 400, rect)
	end,
	[29] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"Ĭ������"
		local szTip =	ColorText("������ǲ��԰�\n", 0) .. 
						ColorText("�㿴���Ķ��ǲ�����TIPS.\n", 7) .. 
						ColorText("���: ����û���õ�!", 6)
		OutputTip(szTip, 400, rect)
	end,
	[30] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"-50"
		local szTip =	ColorText("��Ԥ��Ѻ�����", 6) .. 
						ColorText("��ʮ��", 0) .. 
						ColorText("��", 6)
		OutputTip(szTip, 400, rect)
	end,
	[31] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"-10"
		local szTip =	ColorText("��Ԥ��Ѻ�����", 6) .. 
						ColorText("ʮ��", 0) .. 
						ColorText("��", 6)
		OutputTip(szTip, 400, rect)
	end,
	[32] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"+10"
		local szTip =	ColorText("��Ԥ��Ѻ������", 6) .. 
						ColorText("ʮ��", 0) .. 
						ColorText("��", 6)
		OutputTip(szTip, 400, rect)
	end,
	[33] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"+50"
		local szTip =	ColorText("��Ԥ��Ѻ������", 6) .. 
						ColorText("��ʮ��", 0) .. 
						ColorText("��", 6)
		OutputTip(szTip, 400, rect)
	end,
	[34] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"ˢ��"
		local szTip =	ColorText("ˢ�µ�ǰҳ�档\n\n", 7) .. 
						ColorText("������µ�ս�����б�ͱ������б���Ϣ��", 6)
		OutputTip(szTip, 400, rect)
	end,
	[35] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"ȷ��"
		local szTip =	ColorText("�����úõ�Ԥ��Ѻ���ύ����̨����Ա��\n\n", 7) .. 
						ColorText("�������������ύ�˸��ߵĽ����п��ܱ������������У���֮ǰ֧����Ѻ��ͨ����ʹȫ������㡣\n", 6) .. 
						ColorText("Ѻ�������ڵ�ǰ�����б��н�����ٵ���ҡ�", 3)
		OutputTip(szTip, 400, rect)
	end,
	--
	--����ľ�����
	--�������
	[36] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"ȷ��"
		local szTip =	ColorText("���ո���\n", 7) .. 
						ColorText("ȡ����ǰ����ĸ���״̬�������ջص�����ľ��������\n", 6) .. 
						ColorText("��ʿҲ����ͨ���Ҽ��������״̬ͼ����ȡ������״̬��", 1)
		OutputTip(szTip, 400, rect)
	end,
	--���黢
	[37] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"ȷ��"
		local szTip =	ColorText("�������⣺���黢\n", 7) .. 
						ColorText("����������⣬���Խ����黢�ٻ�������\n", 6) .. 
						ColorText("ƽ�������⣬ʳ֮����Ѱ��������\nÿ���ٻ�������ʮ��Сʱ��", 1)
		OutputTip(szTip, 400, rect)
	end,
	--�����𣨰ף�
	[38] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"ȷ��"
		local szTip =	ColorText("�����ܲ��������𣨷�ɫ��\n", 7) .. 
						ColorText("����ζ�ĺ��ܲ������ٻ��ۺ�ɫ�ġ������𡱡�\n", 6) .. 
						ColorText("����һ���ܲ����а��У�������ܿ�ͻ᳤���ˡ�\n�����ܲ������ܲ��ı�ƣ��ֳƶ����ܲ���\nÿ���ٻ�������ʮ��Сʱ��", 1)
		OutputTip(szTip, 400, rect)
	end,
	--�����𣨻ң�
	[39] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"ȷ��"
		local szTip =	ColorText("�����ܲ��������𣨻�ɫ��\n", 7) .. 
						ColorText("�ô��ܲ������ٻ���ɫ�ġ������𡱡�\n", 6) .. 
						ColorText("����һ�����ܲ����а��У��������𳤴�����ҵ��������ˡ�\n���֣��ܲ��ı������Ÿ���ʫ�ƣ����������������̣�������־���������\nÿ���ٻ�������ʮ��Сʱ��", 1)
		OutputTip(szTip, 400, rect)
	end,
	--�����飨�ף�
	[40] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"ȷ��"
		local szTip =	ColorText("�����ܲ��������飨��ɫ��\n", 7) .. 
						ColorText("���ܲ�������ľ���еķۺ�ɫ���������ٻ�������\n", 6) .. 
						ColorText("���Ӽ���Ҳ��ԡ����ʡ��ġ�\n���ʣ��ܲ��ı�ƣ�����ڡ����š����ء�\nÿ���ٻ�������ʮ��Сʱ��", 1)
		OutputTip(szTip, 400, rect)
	end,
	--�����飨�ң�
	[41] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"ȷ��"
		local szTip =	ColorText("��ȋ�ܲ��������飨��ɫ��\n", 7) .. 
						ColorText("�ú��ܲ�������ľ���л�ɫ���������ٻ�������\n", 6) .. 
						ColorText("������һֱ�������������Ƕ�����������ļ��鱦����\n��ȋ���ܲ��ı�ƣ���֮���幧����־���м��ء�\nÿ���ٻ�������ʮ��Сʱ��", 1)
		OutputTip(szTip, 400, rect)
	end,
	--�����󣨻ң�
	[42] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"ȷ��"
		local szTip =	ColorText("�������ܲ��������󣨻�ɫ��\n", 7) .. 
						ColorText("�ô��ܲ�������ľ���л�ɫ���������ٻ�������\n", 6) .. 
						ColorText("������ֻ��������������û�ˡ����������������Ҫ���ˣ��ߣ�\nÿ���ٻ�������ʮ��Сʱ��", 1)
		OutputTip(szTip, 400, rect)
	end,
	--�����󣨰ף�
	[43] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"ȷ��"
		local szTip =	ColorText("�������ܲ��������󣨷�ɫ��\n", 7) .. 
						ColorText("�ô��ܲ�������ľ���зۺ�ɫ���������ٻ�������\n", 6) .. 
						ColorText("������ֻ��������������û�ˡ����������������Ҫ���ˣ��ߣ�\nÿ���ٻ�������ʮ��Сʱ��", 1)
						
		OutputTip(szTip, 400, rect)
	end,
	--���ð���
	[44] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"ȷ��"
		local szTip =	ColorText("���ð���\n", 7) .. 
						ColorText("����װ���ʻ��أ�Ȼ�����÷Ž�ȥ��Ϊ������\n", 6) .. 
						ColorText("�����ð��ʡ����ڿ죬�������ð��ʡ�����ÿ��������ġ�\nÿ���ٻ�������ʮ���ӡ�", 1)
		OutputTip(szTip, 400, rect)
	end,
	--���ð���
	[45] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"ȷ��"
		local szTip =	ColorText("���ð���\n", 7) .. 
						ColorText("����װ���ʻ��أ�Ȼ�����÷Ž�ȥ��Ϊ������\n", 6) .. 
						ColorText("�ǡ����ǡ��������ð��ʡ��ܴ��������ܰ�æ�޶�����\n���������̵�ĳ���ÿ��ʮСʱֻ�����ٻ�һ�Σ�ÿ�γ���ʮ���ӡ�", 1)
		OutputTip(szTip, 400, rect)
	end,
	--������
	[46] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"ȷ��"
		local szTip =	ColorText("����\n", 7) .. 
						ColorText("�ŷ���ֻ����С�񣬻����������Χ��\n", 6) .. 
						ColorText("����Ը�������� �ڵ�ԸΪ����֦��\nÿ���ٻ�������ʮ��Сʱ��", 1)
		OutputTip(szTip, 400, rect)
	end,
	--��è����
	[47] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"ȷ��"
		local szTip =	ColorText("���ӣ�����\n", 7) .. 
						ColorText("�����۵����ӣ����Ǹ�Բ�����İ�����������������л��Ѱɡ�\n", 6) .. 
						ColorText("�����˻�䳬��ǿ����è�ˣ��мɽ��츩�ԣ������Ŷ��\nÿ���ٻ�������ʮ��Сʱ��", 1)
		OutputTip(szTip, 400, rect)
	end,
	--������1
	[48] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"ȷ��"
		local szTip =	ColorText("���Ż���������\n", 7) .. 
						ColorText("�ٻ��������ƵĻ���С������\n", 6) .. 
						ColorText("�������ƻ����������ӵ������ȡ�\nÿ���ٻ�������ʮ��Сʱ��", 1)
		OutputTip(szTip, 400, rect)
	end,
	--������2
	[49] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"ȷ��"
		local szTip =	ColorText("���Ż������̵�\n", 7) .. 
						ColorText("�ٻ��������ƵĻ���С���̵�\n", 6) .. 
						ColorText("�������ƻ����������ӵ������ȡ�\nÿ���ٻ�������ʮ��Сʱ��", 1)
		OutputTip(szTip, 400, rect)
	end,
	--������3
	[50] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"ȷ��"
		local szTip =	ColorText("���Ż���������\n", 7) .. 
						ColorText("�ٻ��������ƵĻ���С������\n", 6) .. 
						ColorText("�������ƻ����������ӵ������ȡ�\nÿ���ٻ�������ʮ��Сʱ��", 1)
		OutputTip(szTip, 400, rect)
	end,
	--������4
	[51] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"ȷ��"
		local szTip =	ColorText("���Ż��������\n", 7) .. 
						ColorText("�ٻ��������ƵĻ���С�����\n", 6) .. 
						ColorText("�������ƻ����������ӵ������ȡ�\nÿ���ٻ�������ʮ��Сʱ��", 1)
		OutputTip(szTip, 400, rect)
	end,
		--������--�̵�
	[52] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"ȷ��"
		local szTip =	ColorText("����������\n", 7) .. 
						ColorText("�ٻ�������������\n", 6) .. 
						ColorText("�ƣ��ȵƵȵơ�����ϻװ������������߲��źö�����\n���������̵�ĳ���ÿ��ʮСʱֻ�����ٻ�һ�Σ�ÿ�γ���ʮ���ӡ�", 1)
		OutputTip(szTip, 400, rect)
	end,
		--��������
	[53] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"ȷ��"
		local szTip =	ColorText("��������\n", 7) .. 
						ColorText("�ٻ�����������\n", 6) .. 
						ColorText("������ǧ���������ҡ�\nÿ���ٻ�������ʮ��Сʱ��", 1)
		OutputTip(szTip, 400, rect)
	end,
	--������--���̵�
	[54] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"ȷ��"
		local szTip =	ColorText("����������\n", 7) .. 
						ColorText("�ٻ�������������\n", 6) .. 
						ColorText("�ƣ��ȵƵȵơ�\nÿ���ٻ�������ʮ��Сʱ��", 1)
		OutputTip(szTip, 400, rect)
	end,
	----------------------------
	--�ؽ������ʯͼ��
	[55] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"ȷ��"
		local szTip =	ColorText("����ʯ\n", 7) .. 
						ColorText("���ѡ�����ʯ��\n", 6)
		OutputTip(szTip, 400, rect)
	end,
	--�ؽ������ʯͼ��
	[56] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"ȷ��"
		local szTip =	ColorText("�����ʯ\n", 7) .. 
						ColorText("���ѡ�������ʯ��\n", 6)
		OutputTip(szTip, 400, rect)
	end,
	--�ؽ������ʯͼ��
	[57] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"ȷ��"
		local szTip =	ColorText("���ʯ\n", 7) .. 
						ColorText("���ѡ����ʯ��\n", 6)
		OutputTip(szTip, 400, rect)
	end,
	--����������ͼ��
	[58] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"ȷ��"
		local szTip =	ColorText("����β��\n", 7) .. 
						ColorText("���ѡ�񡾽�β���١�\n", 6)
		OutputTip(szTip, 400, rect)
	end,
	--����������ͼ��
	[59] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"ȷ��"
		local szTip =	ColorText("����粡�\n", 7) .. 
						ColorText("���ѡ����粡��١�\n", 6)
		OutputTip(szTip, 400, rect)
	end,
	--����������ͼ��
	[60] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"ȷ��"
		local szTip =	ColorText("��������\n", 7) .. 
						ColorText("���ѡ���������١�\n", 6)
		OutputTip(szTip, 400, rect)
	end,
	--����������ͼ��
	[61] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"ȷ��"
		local szTip =	ColorText("�����ӡ�\n", 7) .. 
						ColorText("���ѡ�񡾺��ӡ��١�\n", 6)
		OutputTip(szTip, 400, rect)
	end,
	--����ͼ�����--------
	[62] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"ȷ��"
		local szTip =	ColorText("�������㷻\n", 7) .. 
						ColorText("����������㷻����Ϊ���㷻��ʽ���ӣ�\n", 6)
		OutputTip(szTip, 400, rect)
	end,
	--����ͼ�����
	[63] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"ȷ��"
		local szTip =	ColorText("�����򻨹�\n", 7) .. 
						ColorText("��������򻨹ȣ���Ϊ�򻨹���ʽ���ӣ�\n", 6)
		OutputTip(szTip, 400, rect)
	end,
	--����ͼ�����
	[64] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"ȷ��"
		local szTip =	ColorText("�����嶾��\n", 7) .. 
						ColorText("��������嶾�̣���Ϊ�嶾����ʽ���ӣ�\n", 6)
		OutputTip(szTip, 400, rect)
	end,
	--����ͼ�����
	[65] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"ȷ��"
		local szTip =	ColorText("��������\n", 7) .. 
						ColorText("����������ţ���Ϊ�Ƽұ���ʽ���ӣ�\n", 6)
		OutputTip(szTip, 400, rect)
	end,
	--����ͼ�����
	[66] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"ȷ��"
		local szTip =	ColorText("������߸�\n", 7) .. 
						ColorText("���������߸�����Ϊ��߸���ʽ���ӣ�\n", 6)
		OutputTip(szTip, 400, rect)
	end,
	--����ͼ�����
	[67] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"ȷ��"
		local szName =	"ȷ��"
		local szTip =	ColorText("����������\n", 7) .. 
						ColorText("������������£���Ϊ��������ʽ���ӣ�\n", 6)
		OutputTip(szTip, 400, rect)
	end,
	--����ͼ�����
	[68] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"ȷ��"
		local szTip =	ColorText("���봿����\n", 7) .. 
						ColorText("������봿��������Ϊ��������ʽ���ӣ�\n", 6)
		OutputTip(szTip, 400, rect)
	end,
	--����ͼ�����
	[69] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"ȷ��"
		local szTip =	ColorText("����ؽ�ɽׯ\n", 7) .. 
						ColorText("�������ؽ�ɽׯ����Ϊ�ؽ�ɽׯ��ʽ���ӣ�\n", 6)
		OutputTip(szTip, 400, rect)
	end,
	----------------------------
	----------------------------
	[70] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"Ĭ������"
		local szTip =	ColorText("ˮ�Ʒ�", 5)
		OutputTip(szTip, 400, rect)
	end,
	[71] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"Ĭ������"
		local szTip =	ColorText("���㷻", 5)
		OutputTip(szTip, 400, rect)
	end,
	[72] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"Ĭ������"
		local szTip =	ColorText("���·�", 5)
		OutputTip(szTip, 400, rect)
	end,
	[73] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"Ĭ������"
		local szTip =	ColorText("��ӯ¥", 5)
		OutputTip(szTip, 400, rect)
	end,
	[74] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"Ĭ������"
		local szTip =	ColorText("��ʮ����", 5)
		OutputTip(szTip, 400, rect)
	end,
	[75] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"Ĭ������"
		local szTip =	ColorText("������ͷ", 5)
		OutputTip(szTip, 400, rect)
	end,
	[76] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"Ĭ������"
		local szTip =	ColorText("ָ��������ʿ�����ƶ�", 5)
		OutputTip(szTip, 400, rect)
	end,
	[77] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"Ĭ������"
		local szTip =	ColorText("����������ʿ�������⼼��", 5)
		OutputTip(szTip, 400, rect)
	end,
	[78] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"Ĭ������"
		local szTip =	ColorText("ָ��������ʿ�����ƶ�", 5)
		OutputTip(szTip, 400, rect)
	end,
	[79] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"Ĭ������"
		local szTip =	ColorText("ָ��������ʿ��ֹͣ�ƶ�", 5)
		OutputTip(szTip, 400, rect)
	end,
	[80] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"Ĭ������"
		local szTip =	ColorText("ָ��������ʿ�������ƶ�", 5)
		OutputTip(szTip, 400, rect)
	end,	
	[81] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"Ĭ������"
		local szTip =	ColorText("ָ��������ʿ��������ĵ�ǰĿ��", 5)
		OutputTip(szTip, 400, rect)
	end,	
	[82] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"Ĭ������"
		local szTip =	ColorText("ָ��������ʿ������������򼯺�", 5)
		OutputTip(szTip, 400, rect)
	end,
	[83] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"Ĭ������"
		local szTip =	ColorText("ָ��������ʿ�������ƶ�", 5)
		OutputTip(szTip, 400, rect)
	end,	
	[84] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"Ĭ������"
		local szTip =	ColorText("ָ��������ʿ�������������򼯺�", 5)
		OutputTip(szTip, 400, rect)
	end,	
	[100] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"Ĭ������"
		local szTip =	ColorText("ֽ��\n", 0) .. 
						ColorText("ʹ�ã��Ķ�ֽ����", 6)
		OutputTip(szTip, 400, rect)
	end,
		--�����ơ���
	[101] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"ȷ��"
		local szTip =	ColorText("�����ơ���\n", 7) .. 
						ColorText("���������ơ��̡�\n", 6) .. 
						ColorText("ȼ��һյ����������ɫ������\n��ֿ����", 1)
		OutputTip(szTip, 400, rect)
	end,
	--�����ơ���
	[102] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"ȷ��"
		local szTip =	ColorText("�����ơ���\n", 7) .. 
						ColorText("���������ơ��ԡ�\n", 6) .. 
						ColorText("ȼ��һյ����������ɫ������\n��ֿ����", 1)
		OutputTip(szTip, 400, rect)
	end,
	--�����ơ���
	[103] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"ȷ��"
		local szTip =	ColorText("�����ơ���\n", 7) .. 
						ColorText("���������ơ��졣\n", 6) .. 
						ColorText("ȼ��һյ�������ĺ�ɫ������\n��ֿ����", 1)
		OutputTip(szTip, 400, rect)
	end,
	--�����ơ�ִ��֮��
	[104] = function(rect)
		local nIconID =	0
		local szCategory =	"Ĭ�Ϸ���"
		local szName =	"ȷ��"
		local szTip =	ColorText("�����ơ�ִ��֮��\n", 7) .. 
						ColorText("���������ơ�ִ��֮�֡�\n", 6) .. 
						ColorText("ȼ��һյ�������������Ŀ�Ŀ�����\n��ֿ����", 1)
		OutputTip(szTip, 400, rect)
	end,
}

-- END TIPS

if not DetectiveQuestTipInited then
	LoadScriptFile("ui/Script/DetectiveQuestTip.lua")
	InitDetectiveQuestTip()
	DetectiveQuestTipInited = true
end

g_DialogSure = 
{
	[1] = function(fnAction)
		local msg = 
		{
			szMessage = "��ȷ��ҪXXXô��", 
			szName = "DialogSure", 
			fnAutoClose = function() return not IsDialoguePanelOpened() end,
			fnCancelAction = function() CloseDialoguePanel() end,
			{szOption = g_tStrings.STR_PLAYER_SURE, fnAction = fnAction},
			{szOption = g_tStrings.STR_PLAYER_CANCEL }
		}
		MessageBox(msg)
	end,
	
	[2] = function(fnAction)
		local msg = 
		{
			szMessage = "��ȷ��Ҫ������߸�ô��һ�����ţ������˳���", 
			szName = "DialogSure", 
			fnAutoClose = function() return not IsDialoguePanelOpened() end,
			fnCancelAction = function() CloseDialoguePanel() end,
			{szOption = g_tStrings.STR_PLAYER_SURE, fnAction = fnAction},
			{szOption = g_tStrings.STR_PLAYER_CANCEL, fnAction = function() CloseDialoguePanel() end}
		}
		MessageBox(msg)
	end,

	[3] = function(fnAction)
		local msg = 
		{
			szMessage = "��ȷ��Ҫ�������㷻ô��һ�����ţ������˳���", 
			szName = "DialogSure", 
			fnAutoClose = function() return not IsDialoguePanelOpened() end,
			fnCancelAction = function() CloseDialoguePanel() end,
			{szOption = g_tStrings.STR_PLAYER_SURE, fnAction = fnAction},
			{szOption = g_tStrings.STR_PLAYER_CANCEL, fnAction = function() CloseDialoguePanel() end}
		}
		MessageBox(msg)
	end,

	[4] = function(fnAction)
		local msg = 
		{
			szMessage = "��ȷ��Ҫ���봿����ô��һ�����ţ������˳���", 
			szName = "DialogSure", 
			fnAutoClose = function() return not IsDialoguePanelOpened() end,
			fnCancelAction = function() CloseDialoguePanel() end,
			{szOption = g_tStrings.STR_PLAYER_SURE, fnAction = fnAction},
			{szOption = g_tStrings.STR_PLAYER_CANCEL, fnAction = function() CloseDialoguePanel() end}
		}
		MessageBox(msg)
	end,

	[5] = function(fnAction)
		local msg = 
		{
			szMessage = "��ȷ��Ҫ�����򻨹�ô��һ�����ţ������˳���", 
			szName = "DialogSure", 
			fnAutoClose = function() return not IsDialoguePanelOpened() end,
			fnCancelAction = function() CloseDialoguePanel() end,
			{szOption = g_tStrings.STR_PLAYER_SURE, fnAction = fnAction},
			{szOption = g_tStrings.STR_PLAYER_CANCEL, fnAction = function() CloseDialoguePanel() end}
		}
		MessageBox(msg)
	end,

	
	[6] = function(fnAction)
		local msg = 
		{
			szMessage = "��ȷ��Ҫ����������ô��һ�����ţ������˳���", 
			szName = "DialogSure", 
			fnAutoClose = function() return not IsDialoguePanelOpened() end,
			fnCancelAction = function() CloseDialoguePanel() end,
			{szOption = g_tStrings.STR_PLAYER_SURE, fnAction = fnAction},
			{szOption = g_tStrings.STR_PLAYER_CANCEL, fnAction = function() CloseDialoguePanel() end}
		}
		MessageBox(msg)
	end,
	
	[7] = function(fnAction)
		local msg = 
		{
			szMessage = "���书���������������ջ�������ϰ�������������ϳ����书�����������ҡ�", 
			szName = "DialogSure", 
			fnAutoClose = function() return not IsDialoguePanelOpened() end,
			fnCancelAction = function() CloseDialoguePanel() end,
			{szOption = g_tStrings.STR_PLAYER_SURE, fnAction = fnAction},
			{szOption = g_tStrings.STR_PLAYER_CANCEL, fnAction = function() CloseDialoguePanel() end}
		}
		MessageBox(msg)
	end,
	
	[8] = function(fnAction)
		local msg = 
		{
			szMessage = "��ȷ��Ҫ����ؽ�ɽׯô��һ�����ţ������˳���", 
			szName = "DialogSure", 
			fnAutoClose = function() return not IsDialoguePanelOpened() end,
			fnCancelAction = function() CloseDialoguePanel() end,
			{szOption = g_tStrings.STR_PLAYER_SURE, fnAction = fnAction},
			{szOption = g_tStrings.STR_PLAYER_CANCEL, fnAction = function() CloseDialoguePanel() end}
		}
		MessageBox(msg)
	end,
	[9] = function(fnAction)
		local msg = 
		{
			szMessage = "��ȷ��Ҫ�����嶾ʥ��ô��һ�����ţ������˳���", 
			szName = "DialogSure", 
			fnAutoClose = function() return not IsDialoguePanelOpened() end,
			fnCancelAction = function() CloseDialoguePanel() end,
			{szOption = g_tStrings.STR_PLAYER_SURE, fnAction = fnAction},
			{szOption = g_tStrings.STR_PLAYER_CANCEL, fnAction = function() CloseDialoguePanel() end}
		}
		MessageBox(msg)
	end,
	[10] = function(fnAction)
		local msg = 
		{
			szMessage = "��ȷ��Ҫ��������ô��һ�����ţ������˳���", 
			szName = "DialogSure", 
			fnAutoClose = function() return not IsDialoguePanelOpened() end,
			fnCancelAction = function() CloseDialoguePanel() end,
			{szOption = g_tStrings.STR_PLAYER_SURE, fnAction = fnAction},
			{szOption = g_tStrings.STR_PLAYER_CANCEL, fnAction = function() CloseDialoguePanel() end}
		}
		MessageBox(msg)
	end,
}

function SetWidgetWidth(hWidget, nWidth)
	local _, nHeight = hWidget:GetSize()
	hWidget:SetSize(nWidth, nHeight)
end

function SetWidgetHeight(hWidget, nHeight)
	local nWidth, _ = hWidget:GetSize()
	hWidget:SetSize(nWidth, nHeight)
end

function SetWidgetRelPosX(hWidget, nPosX)
	local _, nPosY = hWidget:GetRelPos()
	hWidget:SetRelPos(nPosX, nPosY)
end

function SetWidgetRelPosY(hWidget, nPosY)
	local nPosX, _ = hWidget:GetRelPos()
	hWidget:SetRelPos(nPosX, nPosY)
end

g_EnchantInfo = {
	[2606] = {["EnchantID"] = 41},
	[2607] = {["EnchantID"] = 42},
	[2608] = {["EnchantID"] = 43},
	[2609] = {["EnchantID"] = 44},
	[2618] = {["EnchantID"] = 45},
	[2619] = {["EnchantID"] = 46},
	[2626] = {["EnchantID"] = 47},
	[2627] = {["EnchantID"] = 48},
	[2644] = {["EnchantID"] = 49},
	[2645] = {["EnchantID"] = 50},
	[2668] = {["EnchantID"] = 51},
	[2669] = {["EnchantID"] = 52},
	[2670] = {["EnchantID"] = 53},
	[2671] = {["EnchantID"] = 54},
	[2672] = {["EnchantID"] = 55},
	[1895] = {["EnchantID"] = 56},
	[2691] = {["EnchantID"] = 57},
	[2692] = {["EnchantID"] = 58},
	[2809] = {["EnchantID"] = 59},
	[2590] = {["EnchantID"] = 60},
	[2596] = {["EnchantID"] = 61},
	[2599] = {["EnchantID"] = 62},
	[2615] = {["EnchantID"] = 63},
	[2637] = {["EnchantID"] = 64},
	[2855] = {["EnchantID"] = 69},
	[2856] = {["EnchantID"] = 67},
	[2857] = {["EnchantID"] = 67},
	[5042] = {["EnchantID"] = 65},
	[5043] = {["EnchantID"] = 66},
	[2651] = {["EnchantID"] = 68},
	--Ԥ��ֵ���͸�ħ����
	[4715] = {["EnchantID"] = 59},
	--���Ҹ�ħ����
	[3791] = {["EnchantID"] =	1	},
	[3792] = {["EnchantID"] =	18},
	[3793] = {["EnchantID"] =	25},
	[3807] = {["EnchantID"] =	2	},
	[3806] = {["EnchantID"] =	19},
	[3796] = {["EnchantID"] =	26},
	[3798] = {["EnchantID"] =	8	},
	[3799] = {["EnchantID"] =	13},
	[3805] = {["EnchantID"] =	9	},
	[3801] = {["EnchantID"] =	14},
	[3802] = {["EnchantID"] =	15},
	[3803] = {["EnchantID"] =	20},
	[3804] = {["EnchantID"] =	3	},
	[3808] = {["EnchantID"] =	24},
	[3800] = {["EnchantID"] =	10},
	[3795] = {["EnchantID"] =	21},
	[3794] = {["EnchantID"] =	4	},
	[3809] = {["EnchantID"] =	7	},
	[3821] = {["EnchantID"] =	37},
	[2451] = {["EnchantID"] =	38},
	[2453] = {["EnchantID"] =	5	},
	[2454] = {["EnchantID"] =	22},
	[2455] = {["EnchantID"] =	27},
	[3829] = {["EnchantID"] =	11},
	[2456] = {["EnchantID"] =	16},
	[2457] = {["EnchantID"] =	6	},
	[2458] = {["EnchantID"] =	23},
	[2459] = {["EnchantID"] =	28},
	[2460] = {["EnchantID"] =	12},
	[2461] = {["EnchantID"] =	17},
	[2462] = {["EnchantID"] =	29},
	[2464] = {["EnchantID"] =	30},
	[2469] = {["EnchantID"] =	31},
	[2471] = {["EnchantID"] =	32},
	[2473] = {["EnchantID"] =	39},
	[2474] = {["EnchantID"] =	40},
	[2475] = {["EnchantID"] =	33},
	[2476] = {["EnchantID"] =	34},
	[2481] = {["EnchantID"] =	35},
	[2482] = {["EnchantID"] =	36},
	[5350] = {["EnchantID"] =	169},
	[5351] = {["EnchantID"] =	170},
	[5352] = {["EnchantID"] =	171},
	[5353] = {["EnchantID"] =	172},
	[5354] = {["EnchantID"] =	173},
	[5355] = {["EnchantID"] =	174},
	[5356] = {["EnchantID"] =	175},
	[5341] = {["EnchantID"] =	162},
	[5342] = {["EnchantID"] =	163},
	[5345] = {["EnchantID"] =	164},
	[5346] = {["EnchantID"] =	165},
	[5347] = {["EnchantID"] =	166},
	[5348] = {["EnchantID"] =	167},
	[5349] = {["EnchantID"] =	168},
	[6873] = {["EnchantID"] =	184},
	[6899] = {["EnchantID"] =	185},	
	[7061] = {["EnchantID"] =	193},  -- �߿̡�����
	[7066] = {["EnchantID"] =	190},  -- �߿̡�����
	[7065] = {["EnchantID"] =	191},  -- �߿̡��κ�
	[7064] = {["EnchantID"] =	192},  -- �߿̡�����
        [7500] = {["EnchantID"] =	198},
	[7501] = {["EnchantID"] =	199},
	[7502] = {["EnchantID"] =	200},
	[7504] = {["EnchantID"] =	201},
	[7506] = {["EnchantID"] =	202},
	[7507] = {["EnchantID"] =	203},
	[7508] = {["EnchantID"] =	204},
	[7509] = {["EnchantID"] =	205},
	[7491] = {["EnchantID"] =	206},
	[7493] = {["EnchantID"] =	207},
	[7494] = {["EnchantID"] =	208},
	[7495] = {["EnchantID"] =	209},
	[7497] = {["EnchantID"] =	210},
	[7499] = {["EnchantID"] =	211},	
	[7983] = {["EnchantID"] =	290}, -- ݶ��ʥ���ɽ����ĥʯ
	[7984] = {["EnchantID"] =	291},
	[7985] = {["EnchantID"] =	292},
	[7986] = {["EnchantID"] =	293},
	[7987] = {["EnchantID"] =	294},
	[7988] = {["EnchantID"] =	295},
	[7989] = {["EnchantID"] =	296},
	[7990] = {["EnchantID"] =	297},
	[10298] = {["EnchantID"] =	4687},--�����ָ��ħ
	[10299] = {["EnchantID"] =	4686},
	[10300] = {["EnchantID"] =	4685},
	[10301] = {["EnchantID"] =	4684},
	
		----------������Ƹ�ħ----------
	[8930] = {["EnchantID"] =   326},	--᪻��壨��װ��
	[9083] = {["EnchantID"] =  327},	--᪻��壨���֣�
	[9084] = {["EnchantID"] =  328},	--�����壨��װ��
	[9085] = {["EnchantID"] =  329},	--�����壨���֣�
	[9086] = {["EnchantID"] =  330},	--�����壨��װ��
	[9087] = {["EnchantID"] =  331},	--�����壨���֣�
	[9088] = {["EnchantID"] =  332},	--��Ԫ�壨��װ��
	[9089] = {["EnchantID"] =  333},	--��Ԫ�壨���֣�
	[9090] = {["EnchantID"] =  334},	--�����壨��װ��
	[9091] = {["EnchantID"] =  335},	--��Ӣ�壨���֣�
	[9092] = {["EnchantID"] =  336},	--᪻�Ⱦ����װ��
	[9093] = {["EnchantID"] =  337},	--᪻�Ⱦ��������
	[9094] = {["EnchantID"] =  338},	--����Ⱦ����װ��
	[9095] = {["EnchantID"] =  339},	--����Ⱦ��������
	[9096] = {["EnchantID"] =  340},	--����Ⱦ����װ��
	[9097] = {["EnchantID"] =  341},	--����Ⱦ��������
	[9098] = {["EnchantID"] =  342},	--��ԪȾ����װ��
	[9099] = {["EnchantID"] =  343},	--��ԪȾ��������
	[9100] = {["EnchantID"] =  344},	--����Ⱦ����װ��
	[9101] = {["EnchantID"] =  345},	--��ӢȾ��������
	[9102] = {["EnchantID"] =  346},	--�����壨��װ��
	[9103] = {["EnchantID"] =  347},	--�����壨���֣�
	[9108] = {["EnchantID"] =  348},	--�껨�壨��װ��
	[9110] = {["EnchantID"] =  349},	--�껨�壨���֣�
	[9112] = {["EnchantID"] =  350},	--����壨��װ��
	[9114] = {["EnchantID"] =  351},	--����壨���֣�
	[9116] = {["EnchantID"] =  352},	--��Ӣ�壨��װ��
	[9118] = {["EnchantID"] =  353},	--�����壨���֣�
	[9120] = {["EnchantID"] =  354},	--����Ⱦ����װ��
	[9122] = {["EnchantID"] =  355},	--����Ⱦ��������
	[9124] = {["EnchantID"] =  356},	--�껨Ⱦ����װ��
	[9126] = {["EnchantID"] =  357},	--�껨Ⱦ��������
	[9128] = {["EnchantID"] =  358},	--���Ⱦ����װ��
	[9130] = {["EnchantID"] =  359},	--���Ⱦ��������
	[9132] = {["EnchantID"] =  360},	--��ӢȾ����װ��
	[9134] = {["EnchantID"] =  361},	--����Ⱦ��������
	[9136] = {["EnchantID"] =  362},	--�����壨��װ��
	[9138] = {["EnchantID"] =  363},	--�����壨���֣�
	[9140] = {["EnchantID"] =  364},	--�׻��壨��װ��
	[9142] = {["EnchantID"] =  365},	--�׻��壨���֣�
	[9144] = {["EnchantID"] =  366},	--��ȸ�壨��װ��
	[9146] = {["EnchantID"] =  367},	--��ȸ�壨���֣�
	[9148] = {["EnchantID"] =  368},	--���壨��װ��
	[9150] = {["EnchantID"] =  369},	--���壨���֣�
	[9152] = {["EnchantID"] =  370},	--����Ⱦ����װ��
	[9154] = {["EnchantID"] =  371},	--����Ⱦ��������
	[9156] = {["EnchantID"] =  372},	--�׻�Ⱦ����װ��
	[9158] = {["EnchantID"] =  373},	--�׻�Ⱦ��������
	[9160] = {["EnchantID"] =  374},	--��ȸȾ����װ��
	[9162] = {["EnchantID"] =  375},	--��ȸȾ��������
	[9164] = {["EnchantID"] =  376},	--��Ⱦ����װ��
	[9166] = {["EnchantID"] =  377},	--��Ⱦ��������
	[7983] = {["EnchantID"] =  378},	--����ĥʯ
	[7984] = {["EnchantID"] =  379},	--����ĥʯ
	[7985] = {["EnchantID"] =  380},	--����ĥʯ
	[7986] = {["EnchantID"] =  381},	--����ĥʯ
	[7987] = {["EnchantID"] =  382},	--����ĥʯ
	[7988] = {["EnchantID"] =  383},	--��Ӣĥʯ
	[7989] = {["EnchantID"] =  384},	--����ĥʯ
	[7990] = {["EnchantID"] =  385},	--���ĥʯ
	[9619] = {["EnchantID"] =  386},	--᪻Ƽ�Ƭ��ͷ����
	[9620] = {["EnchantID"] =  387},	--᪻Ƽ�Ƭ��Ь�ӣ�
	[9621] = {["EnchantID"] =  388},	--���Ƽ�Ƭ��ͷ����
	[9622] = {["EnchantID"] =  389},	--���Ƽ�Ƭ��Ь�ӣ�
	[9623] = {["EnchantID"] =  390},	--������Ƭ��ͷ����
	[9624] = {["EnchantID"] =  391},	--������Ƭ��Ь�ӣ�
	[9626] = {["EnchantID"] =  392},	--��Ԫ��Ƭ��ͷ����
	[9625] = {["EnchantID"] =  393},	--��Ԫ��Ƭ��Ь�ӣ�
	[9627] = {["EnchantID"] =  394},	--������Ƭ��ͷ����
	[9628] = {["EnchantID"] =  395},	--��Ӣ��Ƭ��Ь�ӣ�
	[9630] = {["EnchantID"] =  396},	--�껨ĥʯ
	[9632] = {["EnchantID"] =  397},	--����ĥʯ
	[9634] = {["EnchantID"] =  398},	--����ĥʯ
	[9636] = {["EnchantID"] =  399},	--�׻�ĥʯ
	[9638] = {["EnchantID"] =  400},	--Ƭ��ĥʯ
	[9640] = {["EnchantID"] =  401},	--���ĥʯ
	[9642] = {["EnchantID"] =  402},	--���׼�Ƭ��ͷ����
	[9644] = {["EnchantID"] =  403},	--���׼�Ƭ��Ь�ӣ�
	[9646] = {["EnchantID"] =  404},	--�껨��Ƭ��ͷ����
	[9648] = {["EnchantID"] =  405},	--�껨��Ƭ��Ь�ӣ�
	[9650] = {["EnchantID"] =  406},	--��Ƽ�Ƭ��ͷ����
	[9652] = {["EnchantID"] =  407},	--��Ƽ�Ƭ��Ь�ӣ�
	[9654] = {["EnchantID"] =  408},	--��Ӣ��Ƭ��ͷ����
	[9656] = {["EnchantID"] =  409},	--������Ƭ��Ь�ӣ�
	[9657] = {["EnchantID"] =  410},	--��ɳ�۶�
	[9658] = {["EnchantID"] =  411},	--׹���۶�
	[9659] = {["EnchantID"] =  412},	--�����۶�
	[9660] = {["EnchantID"] =  413},	--�����۶�
	[9662] = {["EnchantID"] =  414},	--����ĥʯ
	[9664] = {["EnchantID"] =  415},	--�׻�ĥʯ
	[9666] = {["EnchantID"] =  416},	--����ĥʯ
	[9668] = {["EnchantID"] =  417},	--���ĥʯ
	[9670] = {["EnchantID"] =  418},	--����ĥʯ
	[9672] = {["EnchantID"] =  419},	--��ȸĥʯ
	[2691] = {["EnchantID"] =  420},	--��Ѫĥʯ
	[9792] = {["EnchantID"] =  421},	--��ĥʯ
	[9674] = {["EnchantID"] =  422},	--������Ƭ��ͷ����
	[9676] = {["EnchantID"] =  423},	--������Ƭ��Ь�ӣ�
	[9678] = {["EnchantID"] =  424},	--�׻���Ƭ��ͷ����
	[9680] = {["EnchantID"] =  425},	--�׻���Ƭ��Ь�ӣ�
	[9682] = {["EnchantID"] =  426},	--��ȸ��Ƭ��ͷ����
	[9684] = {["EnchantID"] =  427},	--��ȸ��Ƭ��Ь�ӣ�
	[9686] = {["EnchantID"] =  428},	--����Ƭ��ͷ����
	[9688] = {["EnchantID"] =  429},	--����Ƭ��Ь�ӣ�
	[10784] = {["EnchantID"] =  4691},	--���ơ���Ԩ
	[10785] = {["EnchantID"] =  4692},	--���ơ�����
	[10786] = {["EnchantID"] =  4693},	--���ơ�����
	[10787] = {["EnchantID"] =  4694},	--���ơ�չ��
	[11672] = {["EnchantID"] =  5127},	--����������
	[11673] = {["EnchantID"] =  5128},	--����������
	[11674] = {["EnchantID"] =  5129},	--����������
	[11675] = {["EnchantID"] =  5130},	--����������
}

g_LearnInfo = {
	[2210] = {["dwCraftID"] = 4, ["dwRecipeID"] = 1},
	[2211] = {["dwCraftID"] = 4, ["dwRecipeID"] = 4},
	[2212] = {["dwCraftID"] = 4, ["dwRecipeID"] = 6},
	[2213] = {["dwCraftID"] = 4, ["dwRecipeID"] = 8},
	[2214] = {["dwCraftID"] = 4, ["dwRecipeID"] = 9},
	[2215] = {["dwCraftID"] = 4, ["dwRecipeID"] = 10},
	[2216] = {["dwCraftID"] = 4, ["dwRecipeID"] = 11},
	[2217] = {["dwCraftID"] = 4, ["dwRecipeID"] = 20},
	[2218] = {["dwCraftID"] = 4, ["dwRecipeID"] = 21},
	[2219] = {["dwCraftID"] = 4, ["dwRecipeID"] = 22},
	[2220] = {["dwCraftID"] = 4, ["dwRecipeID"] = 23},
	[2221] = {["dwCraftID"] = 4, ["dwRecipeID"] = 24},
	[2222] = {["dwCraftID"] = 4, ["dwRecipeID"] = 25},
	[2223] = {["dwCraftID"] = 4, ["dwRecipeID"] = 31},
	[2224] = {["dwCraftID"] = 4, ["dwRecipeID"] = 32},
	[2225] = {["dwCraftID"] = 4, ["dwRecipeID"] = 33},
	[2226] = {["dwCraftID"] = 4, ["dwRecipeID"] = 34},
	[2227] = {["dwCraftID"] = 4, ["dwRecipeID"] = 35},
	[2228] = {["dwCraftID"] = 4, ["dwRecipeID"] = 36},
	[1833] = {["dwCraftID"] = 4, ["dwRecipeID"] = 40},
	[2229] = {["dwCraftID"] = 4, ["dwRecipeID"] = 41},
	[2230] = {["dwCraftID"] = 4, ["dwRecipeID"] = 42},
	[2231] = {["dwCraftID"] = 4, ["dwRecipeID"] = 43},
	[1834] = {["dwCraftID"] = 4, ["dwRecipeID"] = 44},
	[2232] = {["dwCraftID"] = 4, ["dwRecipeID"] = 48},
	[2233] = {["dwCraftID"] = 4, ["dwRecipeID"] = 49},
	[2234] = {["dwCraftID"] = 4, ["dwRecipeID"] = 50},
	[2235] = {["dwCraftID"] = 4, ["dwRecipeID"] = 51},
	[2236] = {["dwCraftID"] = 4, ["dwRecipeID"] = 52},
	[2237] = {["dwCraftID"] = 4, ["dwRecipeID"] = 54},
	[2238] = {["dwCraftID"] = 4, ["dwRecipeID"] = 60},
	[2239] = {["dwCraftID"] = 4, ["dwRecipeID"] = 61},
	[2240] = {["dwCraftID"] = 4, ["dwRecipeID"] = 62},
	[2241] = {["dwCraftID"] = 4, ["dwRecipeID"] = 63},
	[2242] = {["dwCraftID"] = 4, ["dwRecipeID"] = 64},
	[2243] = {["dwCraftID"] = 4, ["dwRecipeID"] = 65},
	[2244] = {["dwCraftID"] = 4, ["dwRecipeID"] = 66},
	[2245] = {["dwCraftID"] = 4, ["dwRecipeID"] = 67},
	[2246] = {["dwCraftID"] = 4, ["dwRecipeID"] = 68},
	[2247] = {["dwCraftID"] = 4, ["dwRecipeID"] = 72},
	[2248] = {["dwCraftID"] = 4, ["dwRecipeID"] = 76},
	[2249] = {["dwCraftID"] = 4, ["dwRecipeID"] = 77},
	[2250] = {["dwCraftID"] = 4, ["dwRecipeID"] = 78},
	[1862] = {["dwCraftID"] = 4, ["dwRecipeID"] = 79},
	[2251] = {["dwCraftID"] = 4, ["dwRecipeID"] = 80},
	[2252] = {["dwCraftID"] = 4, ["dwRecipeID"] = 81},
	[2253] = {["dwCraftID"] = 4, ["dwRecipeID"] = 82},
	[2254] = {["dwCraftID"] = 4, ["dwRecipeID"] = 83},
	[2255] = {["dwCraftID"] = 4, ["dwRecipeID"] = 84},
	[2256] = {["dwCraftID"] = 4, ["dwRecipeID"] = 85},
	[2257] = {["dwCraftID"] = 4, ["dwRecipeID"] = 86},
	[2258] = {["dwCraftID"] = 4, ["dwRecipeID"] = 87},
	[2259] = {["dwCraftID"] = 4, ["dwRecipeID"] = 89},
	[2260] = {["dwCraftID"] = 4, ["dwRecipeID"] = 90},
	[1835] = {["dwCraftID"] = 4, ["dwRecipeID"] = 91},
	[2261] = {["dwCraftID"] = 4, ["dwRecipeID"] = 92},
	[2262] = {["dwCraftID"] = 4, ["dwRecipeID"] = 93},
	[2263] = {["dwCraftID"] = 4, ["dwRecipeID"] = 94},
	[2264] = {["dwCraftID"] = 4, ["dwRecipeID"] = 95},
	[2321] = {["dwCraftID"] = 5, ["dwRecipeID"] = 5},
	[2322] = {["dwCraftID"] = 5, ["dwRecipeID"] = 6},
	[2323] = {["dwCraftID"] = 5, ["dwRecipeID"] = 11},
	[2324] = {["dwCraftID"] = 5, ["dwRecipeID"] = 12},
	[2325] = {["dwCraftID"] = 5, ["dwRecipeID"] = 14},
	[2326] = {["dwCraftID"] = 5, ["dwRecipeID"] = 15},
	[2327] = {["dwCraftID"] = 5, ["dwRecipeID"] = 16},
	[2328] = {["dwCraftID"] = 5, ["dwRecipeID"] = 17},
	[2329] = {["dwCraftID"] = 5, ["dwRecipeID"] = 21},
	[2330] = {["dwCraftID"] = 5, ["dwRecipeID"] = 24},
	[2331] = {["dwCraftID"] = 5, ["dwRecipeID"] = 27},
	[2332] = {["dwCraftID"] = 5, ["dwRecipeID"] = 30},
	[2333] = {["dwCraftID"] = 5, ["dwRecipeID"] = 31},
	[2334] = {["dwCraftID"] = 5, ["dwRecipeID"] = 32},
	[2335] = {["dwCraftID"] = 5, ["dwRecipeID"] = 40},
	[2336] = {["dwCraftID"] = 5, ["dwRecipeID"] = 43},
	[2337] = {["dwCraftID"] = 5, ["dwRecipeID"] = 44},
	[2338] = {["dwCraftID"] = 5, ["dwRecipeID"] = 48},
	[2339] = {["dwCraftID"] = 5, ["dwRecipeID"] = 49},
	[2340] = {["dwCraftID"] = 5, ["dwRecipeID"] = 57},
	[2341] = {["dwCraftID"] = 5, ["dwRecipeID"] = 63},
	[2342] = {["dwCraftID"] = 5, ["dwRecipeID"] = 64},
	[2343] = {["dwCraftID"] = 5, ["dwRecipeID"] = 67},
	[2344] = {["dwCraftID"] = 5, ["dwRecipeID"] = 71},
	[2345] = {["dwCraftID"] = 5, ["dwRecipeID"] = 72},
	[2346] = {["dwCraftID"] = 5, ["dwRecipeID"] = 73},
	[2347] = {["dwCraftID"] = 5, ["dwRecipeID"] = 74},
	[2348] = {["dwCraftID"] = 5, ["dwRecipeID"] = 75},
	[2349] = {["dwCraftID"] = 5, ["dwRecipeID"] = 76},
	[2350] = {["dwCraftID"] = 5, ["dwRecipeID"] = 77},
	[2351] = {["dwCraftID"] = 5, ["dwRecipeID"] = 78},
	[2352] = {["dwCraftID"] = 5, ["dwRecipeID"] = 79},
	[2353] = {["dwCraftID"] = 5, ["dwRecipeID"] = 80},
	[2354] = {["dwCraftID"] = 5, ["dwRecipeID"] = 290},
	[2355] = {["dwCraftID"] = 5, ["dwRecipeID"] = 291},
	[2356] = {["dwCraftID"] = 5, ["dwRecipeID"] = 292},
	[2357] = {["dwCraftID"] = 5, ["dwRecipeID"] = 293},
	[2358] = {["dwCraftID"] = 5, ["dwRecipeID"] = 96},
	[2359] = {["dwCraftID"] = 5, ["dwRecipeID"] = 97},
	[2360] = {["dwCraftID"] = 5, ["dwRecipeID"] = 100},
	[2361] = {["dwCraftID"] = 5, ["dwRecipeID"] = 101},
	[2787] = {["dwCraftID"] = 5, ["dwRecipeID"] = 102},
	[2788] = {["dwCraftID"] = 5, ["dwRecipeID"] = 103},
	[2789] = {["dwCraftID"] = 5, ["dwRecipeID"] = 104},
	[2362] = {["dwCraftID"] = 5, ["dwRecipeID"] = 310},
	[2363] = {["dwCraftID"] = 5, ["dwRecipeID"] = 311},
	[2364] = {["dwCraftID"] = 5, ["dwRecipeID"] = 314},
	[2365] = {["dwCraftID"] = 5, ["dwRecipeID"] = 315},
	[2366] = {["dwCraftID"] = 5, ["dwRecipeID"] = 120},
	[2367] = {["dwCraftID"] = 5, ["dwRecipeID"] = 121},
	[2368] = {["dwCraftID"] = 5, ["dwRecipeID"] = 122},
	[2369] = {["dwCraftID"] = 5, ["dwRecipeID"] = 123},
	[2370] = {["dwCraftID"] = 5, ["dwRecipeID"] = 124},
	[2371] = {["dwCraftID"] = 5, ["dwRecipeID"] = 132},
	[2372] = {["dwCraftID"] = 5, ["dwRecipeID"] = 133},
	[2373] = {["dwCraftID"] = 5, ["dwRecipeID"] = 134},
	[2374] = {["dwCraftID"] = 5, ["dwRecipeID"] = 135},
	[2375] = {["dwCraftID"] = 5, ["dwRecipeID"] = 139},
	[2376] = {["dwCraftID"] = 5, ["dwRecipeID"] = 140},
	[2377] = {["dwCraftID"] = 5, ["dwRecipeID"] = 141},
	[2378] = {["dwCraftID"] = 5, ["dwRecipeID"] = 143},
	[2379] = {["dwCraftID"] = 5, ["dwRecipeID"] = 144},
	[2380] = {["dwCraftID"] = 5, ["dwRecipeID"] = 146},
	[2381] = {["dwCraftID"] = 5, ["dwRecipeID"] = 147},
	[2382] = {["dwCraftID"] = 5, ["dwRecipeID"] = 355},
	[2383] = {["dwCraftID"] = 5, ["dwRecipeID"] = 356},
	[2384] = {["dwCraftID"] = 5, ["dwRecipeID"] = 357},
	[2385] = {["dwCraftID"] = 5, ["dwRecipeID"] = 360},
	[2386] = {["dwCraftID"] = 5, ["dwRecipeID"] = 361},
	[2387] = {["dwCraftID"] = 5, ["dwRecipeID"] = 362},
	[2388] = {["dwCraftID"] = 5, ["dwRecipeID"] = 164},
	[2389] = {["dwCraftID"] = 5, ["dwRecipeID"] = 165},
	[2390] = {["dwCraftID"] = 5, ["dwRecipeID"] = 166},
	[2391] = {["dwCraftID"] = 5, ["dwRecipeID"] = 171},
	[2392] = {["dwCraftID"] = 5, ["dwRecipeID"] = 172},
	[2393] = {["dwCraftID"] = 5, ["dwRecipeID"] = 373},
	[2394] = {["dwCraftID"] = 5, ["dwRecipeID"] = 174},
	[2395] = {["dwCraftID"] = 5, ["dwRecipeID"] = 375},
	[2396] = {["dwCraftID"] = 5, ["dwRecipeID"] = 176},
	[2397] = {["dwCraftID"] = 5, ["dwRecipeID"] = 182},
	[2398] = {["dwCraftID"] = 5, ["dwRecipeID"] = 183},
	[2399] = {["dwCraftID"] = 5, ["dwRecipeID"] = 184},
	[2400] = {["dwCraftID"] = 5, ["dwRecipeID"] = 185},
	[2401] = {["dwCraftID"] = 5, ["dwRecipeID"] = 186},
	[2402] = {["dwCraftID"] = 5, ["dwRecipeID"] = 187},
	[2403] = {["dwCraftID"] = 5, ["dwRecipeID"] = 188},
	[2404] = {["dwCraftID"] = 5, ["dwRecipeID"] = 189},
	[2405] = {["dwCraftID"] = 5, ["dwRecipeID"] = 190},
	[2406] = {["dwCraftID"] = 5, ["dwRecipeID"] = 397},
	[2407] = {["dwCraftID"] = 5, ["dwRecipeID"] = 198},
	[2408] = {["dwCraftID"] = 5, ["dwRecipeID"] = 399},
	[2409] = {["dwCraftID"] = 5, ["dwRecipeID"] = 200},
	[2410] = {["dwCraftID"] = 5, ["dwRecipeID"] = 401},
	[2411] = {["dwCraftID"] = 5, ["dwRecipeID"] = 402},
	[2412] = {["dwCraftID"] = 5, ["dwRecipeID"] = 403},
	[2413] = {["dwCraftID"] = 5, ["dwRecipeID"] = 404},
	[2414] = {["dwCraftID"] = 5, ["dwRecipeID"] = 205},
	[1867] = {["dwCraftID"] = 5, ["dwRecipeID"] = 206},
	[1868] = {["dwCraftID"] = 5, ["dwRecipeID"] = 207},
	[1869] = {["dwCraftID"] = 5, ["dwRecipeID"] = 208},
	[2415] = {["dwCraftID"] = 5, ["dwRecipeID"] = 209},
	[2416] = {["dwCraftID"] = 5, ["dwRecipeID"] = 210},
	[2417] = {["dwCraftID"] = 5, ["dwRecipeID"] = 211},
	[2418] = {["dwCraftID"] = 5, ["dwRecipeID"] = 212},
	[2419] = {["dwCraftID"] = 5, ["dwRecipeID"] = 213},
	[2420] = {["dwCraftID"] = 5, ["dwRecipeID"] = 214},
	[2421] = {["dwCraftID"] = 5, ["dwRecipeID"] = 215},
	[2422] = {["dwCraftID"] = 5, ["dwRecipeID"] = 216},
	[2423] = {["dwCraftID"] = 5, ["dwRecipeID"] = 217},
	[2424] = {["dwCraftID"] = 5, ["dwRecipeID"] = 218},
	[2425] = {["dwCraftID"] = 5, ["dwRecipeID"] = 219},
	[2426] = {["dwCraftID"] = 5, ["dwRecipeID"] = 420},
	[2427] = {["dwCraftID"] = 5, ["dwRecipeID"] = 421},
	[2428] = {["dwCraftID"] = 5, ["dwRecipeID"] = 222},
	[2429] = {["dwCraftID"] = 5, ["dwRecipeID"] = 223},
	[2430] = {["dwCraftID"] = 5, ["dwRecipeID"] = 224},
	[2483] = {["dwCraftID"] = 6, ["dwRecipeID"] = 4},
	[2484] = {["dwCraftID"] = 6, ["dwRecipeID"] = 10},
	[2485] = {["dwCraftID"] = 6, ["dwRecipeID"] = 14},
	[2486] = {["dwCraftID"] = 6, ["dwRecipeID"] = 16},
	[2487] = {["dwCraftID"] = 6, ["dwRecipeID"] = 17},
	[2488] = {["dwCraftID"] = 6, ["dwRecipeID"] = 28},
	[2489] = {["dwCraftID"] = 6, ["dwRecipeID"] = 30},
	[2490] = {["dwCraftID"] = 6, ["dwRecipeID"] = 34},
	[2491] = {["dwCraftID"] = 6, ["dwRecipeID"] = 36},
	[2492] = {["dwCraftID"] = 6, ["dwRecipeID"] = 37},
	[2493] = {["dwCraftID"] = 6, ["dwRecipeID"] = 38},
	[2494] = {["dwCraftID"] = 6, ["dwRecipeID"] = 39},
	[2495] = {["dwCraftID"] = 6, ["dwRecipeID"] = 42},
	[2496] = {["dwCraftID"] = 6, ["dwRecipeID"] = 43},
	[2497] = {["dwCraftID"] = 6, ["dwRecipeID"] = 44},
	[2498] = {["dwCraftID"] = 6, ["dwRecipeID"] = 48},
	[2499] = {["dwCraftID"] = 6, ["dwRecipeID"] = 54},
	[2500] = {["dwCraftID"] = 6, ["dwRecipeID"] = 57},
	[2501] = {["dwCraftID"] = 6, ["dwRecipeID"] = 63},
	[2502] = {["dwCraftID"] = 6, ["dwRecipeID"] = 69},
	[2503] = {["dwCraftID"] = 6, ["dwRecipeID"] = 74},
	[2504] = {["dwCraftID"] = 6, ["dwRecipeID"] = 77},
	[2505] = {["dwCraftID"] = 6, ["dwRecipeID"] = 81},
	[2506] = {["dwCraftID"] = 6, ["dwRecipeID"] = 83},
	[2507] = {["dwCraftID"] = 6, ["dwRecipeID"] = 84},
	[2508] = {["dwCraftID"] = 6, ["dwRecipeID"] = 85},
	[2509] = {["dwCraftID"] = 6, ["dwRecipeID"] = 86},
	[2510] = {["dwCraftID"] = 6, ["dwRecipeID"] = 87},
	[2511] = {["dwCraftID"] = 6, ["dwRecipeID"] = 93},
	[2512] = {["dwCraftID"] = 6, ["dwRecipeID"] = 94},
	[2513] = {["dwCraftID"] = 6, ["dwRecipeID"] = 95},
	[2514] = {["dwCraftID"] = 6, ["dwRecipeID"] = 100},
	[2515] = {["dwCraftID"] = 6, ["dwRecipeID"] = 102},
	[2516] = {["dwCraftID"] = 6, ["dwRecipeID"] = 110},
	[2517] = {["dwCraftID"] = 6, ["dwRecipeID"] = 113},
	[2518] = {["dwCraftID"] = 6, ["dwRecipeID"] = 114},
	[2519] = {["dwCraftID"] = 6, ["dwRecipeID"] = 115},
	[2520] = {["dwCraftID"] = 6, ["dwRecipeID"] = 116},
	[2521] = {["dwCraftID"] = 6, ["dwRecipeID"] = 123},
	[2522] = {["dwCraftID"] = 6, ["dwRecipeID"] = 124},
	[2523] = {["dwCraftID"] = 6, ["dwRecipeID"] = 125},
	[2524] = {["dwCraftID"] = 6, ["dwRecipeID"] = 126},
	[2525] = {["dwCraftID"] = 6, ["dwRecipeID"] = 137},
	[2526] = {["dwCraftID"] = 6, ["dwRecipeID"] = 139},
	[2527] = {["dwCraftID"] = 6, ["dwRecipeID"] = 140},
	[2528] = {["dwCraftID"] = 6, ["dwRecipeID"] = 141},
	[2529] = {["dwCraftID"] = 6, ["dwRecipeID"] = 142},
	[2530] = {["dwCraftID"] = 6, ["dwRecipeID"] = 145},
	[2531] = {["dwCraftID"] = 6, ["dwRecipeID"] = 146},
	[2532] = {["dwCraftID"] = 6, ["dwRecipeID"] = 149},
	[2533] = {["dwCraftID"] = 6, ["dwRecipeID"] = 156},
	[2534] = {["dwCraftID"] = 6, ["dwRecipeID"] = 157},
	[2535] = {["dwCraftID"] = 6, ["dwRecipeID"] = 158},
	[2536] = {["dwCraftID"] = 6, ["dwRecipeID"] = 163},
	[2537] = {["dwCraftID"] = 6, ["dwRecipeID"] = 165},
	[2538] = {["dwCraftID"] = 6, ["dwRecipeID"] = 167},
	[2539] = {["dwCraftID"] = 6, ["dwRecipeID"] = 173},
	[2540] = {["dwCraftID"] = 6, ["dwRecipeID"] = 174},
	[2541] = {["dwCraftID"] = 6, ["dwRecipeID"] = 175},
	[2542] = {["dwCraftID"] = 6, ["dwRecipeID"] = 176},
	[2543] = {["dwCraftID"] = 6, ["dwRecipeID"] = 177},
	[2544] = {["dwCraftID"] = 6, ["dwRecipeID"] = 178},
	[2545] = {["dwCraftID"] = 6, ["dwRecipeID"] = 179},
	[2546] = {["dwCraftID"] = 6, ["dwRecipeID"] = 191},
	[2547] = {["dwCraftID"] = 6, ["dwRecipeID"] = 192},
	[2548] = {["dwCraftID"] = 6, ["dwRecipeID"] = 193},
	[2549] = {["dwCraftID"] = 6, ["dwRecipeID"] = 194},
	[2550] = {["dwCraftID"] = 6, ["dwRecipeID"] = 195},
	[2551] = {["dwCraftID"] = 6, ["dwRecipeID"] = 196},
	[2552] = {["dwCraftID"] = 6, ["dwRecipeID"] = 197},
	[2553] = {["dwCraftID"] = 6, ["dwRecipeID"] = 198},
	[2554] = {["dwCraftID"] = 6, ["dwRecipeID"] = 199},
	[2555] = {["dwCraftID"] = 6, ["dwRecipeID"] = 200},
	[2556] = {["dwCraftID"] = 6, ["dwRecipeID"] = 201},
	[2557] = {["dwCraftID"] = 6, ["dwRecipeID"] = 202},
	[2558] = {["dwCraftID"] = 6, ["dwRecipeID"] = 203},
	[2559] = {["dwCraftID"] = 6, ["dwRecipeID"] = 204},
	[2560] = {["dwCraftID"] = 6, ["dwRecipeID"] = 205},
	[2561] = {["dwCraftID"] = 6, ["dwRecipeID"] = 206},
	[2566] = {["dwCraftID"] = 6, ["dwRecipeID"] = 211},
	[2567] = {["dwCraftID"] = 6, ["dwRecipeID"] = 212},
	[2568] = {["dwCraftID"] = 6, ["dwRecipeID"] = 213},
	[2569] = {["dwCraftID"] = 6, ["dwRecipeID"] = 214},
	[2570] = {["dwCraftID"] = 6, ["dwRecipeID"] = 215},
	[2571] = {["dwCraftID"] = 6, ["dwRecipeID"] = 216},
	[2572] = {["dwCraftID"] = 6, ["dwRecipeID"] = 217},
	[2573] = {["dwCraftID"] = 6, ["dwRecipeID"] = 218},
	[2574] = {["dwCraftID"] = 6, ["dwRecipeID"] = 219},
	[2575] = {["dwCraftID"] = 6, ["dwRecipeID"] = 220},
	[2576] = {["dwCraftID"] = 6, ["dwRecipeID"] = 221},
	[2693] = {["dwCraftID"] = 7, ["dwRecipeID"] = 4},
	[2694] = {["dwCraftID"] = 7, ["dwRecipeID"] = 5},
	[2695] = {["dwCraftID"] = 7, ["dwRecipeID"] = 8},
	[2696] = {["dwCraftID"] = 7, ["dwRecipeID"] = 10},
	[2697] = {["dwCraftID"] = 7, ["dwRecipeID"] = 12},
	[2698] = {["dwCraftID"] = 7, ["dwRecipeID"] = 14},
	[2699] = {["dwCraftID"] = 7, ["dwRecipeID"] = 15},
	[2700] = {["dwCraftID"] = 7, ["dwRecipeID"] = 19},
	[2701] = {["dwCraftID"] = 7, ["dwRecipeID"] = 21},
	[2702] = {["dwCraftID"] = 7, ["dwRecipeID"] = 22},
	[2703] = {["dwCraftID"] = 7, ["dwRecipeID"] = 25},
	[2704] = {["dwCraftID"] = 7, ["dwRecipeID"] = 28},
	[2705] = {["dwCraftID"] = 7, ["dwRecipeID"] = 29},
	[2706] = {["dwCraftID"] = 7, ["dwRecipeID"] = 31},
	[2707] = {["dwCraftID"] = 7, ["dwRecipeID"] = 32},
	[2708] = {["dwCraftID"] = 7, ["dwRecipeID"] = 34},
	[2709] = {["dwCraftID"] = 7, ["dwRecipeID"] = 37},
	[2710] = {["dwCraftID"] = 7, ["dwRecipeID"] = 38},
	[2711] = {["dwCraftID"] = 7, ["dwRecipeID"] = 39},
	[3722] = {["dwCraftID"] = 7, ["dwRecipeID"] = 44},
	[2712] = {["dwCraftID"] = 7, ["dwRecipeID"] = 47},
	[2713] = {["dwCraftID"] = 7, ["dwRecipeID"] = 48},
	[2714] = {["dwCraftID"] = 7, ["dwRecipeID"] = 56},
	[2715] = {["dwCraftID"] = 7, ["dwRecipeID"] = 59},
	[2716] = {["dwCraftID"] = 7, ["dwRecipeID"] = 60},
	[2717] = {["dwCraftID"] = 7, ["dwRecipeID"] = 64},
	[2718] = {["dwCraftID"] = 7, ["dwRecipeID"] = 65},
	[2719] = {["dwCraftID"] = 7, ["dwRecipeID"] = 66},
	[2720] = {["dwCraftID"] = 7, ["dwRecipeID"] = 67},
	[1863] = {["dwCraftID"] = 7, ["dwRecipeID"] = 68},
	[1864] = {["dwCraftID"] = 7, ["dwRecipeID"] = 69},
	[2723] = {["dwCraftID"] = 7, ["dwRecipeID"] = 70},
	[2724] = {["dwCraftID"] = 7, ["dwRecipeID"] = 71},
	[2725] = {["dwCraftID"] = 7, ["dwRecipeID"] = 72},
	[2726] = {["dwCraftID"] = 7, ["dwRecipeID"] = 73},
	[2727] = {["dwCraftID"] = 7, ["dwRecipeID"] = 75},
	[2728] = {["dwCraftID"] = 7, ["dwRecipeID"] = 80},
	[2729] = {["dwCraftID"] = 7, ["dwRecipeID"] = 81},
	[2730] = {["dwCraftID"] = 7, ["dwRecipeID"] = 82},
	[2731] = {["dwCraftID"] = 7, ["dwRecipeID"] = 83},
	[2732] = {["dwCraftID"] = 7, ["dwRecipeID"] = 95},
	[2733] = {["dwCraftID"] = 7, ["dwRecipeID"] = 96},
	[2734] = {["dwCraftID"] = 7, ["dwRecipeID"] = 97},
	[2735] = {["dwCraftID"] = 7, ["dwRecipeID"] = 98},
	[2736] = {["dwCraftID"] = 7, ["dwRecipeID"] = 99},
	[2737] = {["dwCraftID"] = 7, ["dwRecipeID"] = 100},
	[2738] = {["dwCraftID"] = 7, ["dwRecipeID"] = 101},
	[2739] = {["dwCraftID"] = 7, ["dwRecipeID"] = 102},
	[2740] = {["dwCraftID"] = 7, ["dwRecipeID"] = 103},
	[2741] = {["dwCraftID"] = 7, ["dwRecipeID"] = 104},
	[2742] = {["dwCraftID"] = 7, ["dwRecipeID"] = 105},
	[2743] = {["dwCraftID"] = 7, ["dwRecipeID"] = 106},
	[1865] = {["dwCraftID"] = 7, ["dwRecipeID"] = 107},
	[1866] = {["dwCraftID"] = 7, ["dwRecipeID"] = 108},
	[2745] = {["dwCraftID"] = 7, ["dwRecipeID"] = 109},
	[2746] = {["dwCraftID"] = 7, ["dwRecipeID"] = 110},
	[2747] = {["dwCraftID"] = 7, ["dwRecipeID"] = 111},
	[2748] = {["dwCraftID"] = 7, ["dwRecipeID"] = 112},
	[2749] = {["dwCraftID"] = 7, ["dwRecipeID"] = 113},
	[2750] = {["dwCraftID"] = 7, ["dwRecipeID"] = 114},
	[2751] = {["dwCraftID"] = 7, ["dwRecipeID"] = 115},
	[2752] = {["dwCraftID"] = 7, ["dwRecipeID"] = 116},
	[3759] = {["dwCraftID"] = 7, ["dwRecipeID"] = 95},
	[2753] = {["dwCraftID"] = 7, ["dwRecipeID"] = 118},
	[1896] = {["dwCraftID"] = 5, ["dwRecipeID"] = 181},
	[1897] = {["dwCraftID"] = 5, ["dwRecipeID"] = 191},
	[2044] = {["dwCraftID"] = 7, ["dwRecipeID"] = 117},
	[2827] = {["dwCraftID"] = 5, ["dwRecipeID"] = 26},
	[2828] = {["dwCraftID"] = 5, ["dwRecipeID"] = 177},
	[2829] = {["dwCraftID"] = 5, ["dwRecipeID"] = 196},
	[2830] = {["dwCraftID"] = 5, ["dwRecipeID"] = 194},
	[2831] = {["dwCraftID"] = 6, ["dwRecipeID"] = 162},
	[2832] = {["dwCraftID"] = 6, ["dwRecipeID"] = 164},
	[2833] = {["dwCraftID"] = 6, ["dwRecipeID"] = 166},
	[2834] = {["dwCraftID"] = 6, ["dwRecipeID"] = 169},
	[2835] = {["dwCraftID"] = 6, ["dwRecipeID"] = 185},
	[2836] = {["dwCraftID"] = 6, ["dwRecipeID"] = 186},
	[3589] = {["dwCraftID"] = 7, ["dwRecipeID"] = 49},
	[3590] = {["dwCraftID"] = 7, ["dwRecipeID"] = 50},
	[3591] = {["dwCraftID"] = 7, ["dwRecipeID"] = 51},
	[3592] = {["dwCraftID"] = 6, ["dwRecipeID"] = 161},
	[3710] = {["dwCraftID"] = 5, ["dwRecipeID"] = 180},
	[2612] = {["dwCraftID"] = 6, ["dwRecipeID"] = 222},
	[2616] = {["dwCraftID"] = 6, ["dwRecipeID"] = 62},
	[2623] = {["dwCraftID"] = 6, ["dwRecipeID"] = 223},
	[2624] = {["dwCraftID"] = 6, ["dwRecipeID"] = 224},
	[2790] = {["dwCraftID"] = 6, ["dwRecipeID"] = 225},
	[2791] = {["dwCraftID"] = 6, ["dwRecipeID"] = 226},
	[2792] = {["dwCraftID"] = 6, ["dwRecipeID"] = 227},
	[2793] = {["dwCraftID"] = 6, ["dwRecipeID"] = 228},
	[2794] = {["dwCraftID"] = 6, ["dwRecipeID"] = 229},
	[2816] = {["dwCraftID"] = 6, ["dwRecipeID"] = 230},
	[2817] = {["dwCraftID"] = 6, ["dwRecipeID"] = 231},
	[2822] = {["dwCraftID"] = 5, ["dwRecipeID"] = 226},
	[2839] = {["dwCraftID"] = 5, ["dwRecipeID"] = 225},
	[2891] = {["dwCraftID"] = 5, ["dwRecipeID"] = 228},
	[2990] = {["dwCraftID"] = 5, ["dwRecipeID"] = 229},
	[2991] = {["dwCraftID"] = 5, ["dwRecipeID"] = 230},
	[2932] = {["dwCraftID"] = 5, ["dwRecipeID"] = 231},
	[2977] = {["dwCraftID"] = 5, ["dwRecipeID"] = 232},
	[2987] = {["dwCraftID"] = 5, ["dwRecipeID"] = 233},
	[5026] = {["dwCraftID"] = 6, ["dwRecipeID"] = 234},
	[5027] = {["dwCraftID"] = 6, ["dwRecipeID"] = 235},
	[5028] = {["dwCraftID"] = 6, ["dwRecipeID"] = 236},
	[5025] = {["dwCraftID"] = 6, ["dwRecipeID"] = 106},
	[4985] = {["dwCraftID"] = 4, ["dwRecipeID"] = 117},
	[4984] = {["dwCraftID"] = 4, ["dwRecipeID"] = 116},
	[4983] = {["dwCraftID"] = 4, ["dwRecipeID"] = 115},
	[4982] = {["dwCraftID"] = 4, ["dwRecipeID"] = 114},
	[4981] = {["dwCraftID"] = 4, ["dwRecipeID"] = 113},
	[4980] = {["dwCraftID"] = 4, ["dwRecipeID"] = 112},
	[4979] = {["dwCraftID"] = 4, ["dwRecipeID"] = 111},
	[4978] = {["dwCraftID"] = 4, ["dwRecipeID"] = 110},
	[4977] = {["dwCraftID"] = 4, ["dwRecipeID"] = 109},
	[4976] = {["dwCraftID"] = 4, ["dwRecipeID"] = 108},
	[5015] = {["dwCraftID"] = 5, ["dwRecipeID"] = 243},
	[5016] = {["dwCraftID"] = 5, ["dwRecipeID"] = 244},
	[5017] = {["dwCraftID"] = 5, ["dwRecipeID"] = 245},
	[5018] = {["dwCraftID"] = 5, ["dwRecipeID"] = 246},
	[5019] = {["dwCraftID"] = 5, ["dwRecipeID"] = 247},
	[5020] = {["dwCraftID"] = 5, ["dwRecipeID"] = 248},
	[5024] = {["dwCraftID"] = 6, ["dwRecipeID"] = 107},
	[5022] = {["dwCraftID"] = 5, ["dwRecipeID"] = 250},
	[5021] = {["dwCraftID"] = 5, ["dwRecipeID"] = 249},
	[5225] = {["dwCraftID"] = 4, ["dwRecipeID"] = 119},
	[5226] = {["dwCraftID"] = 4, ["dwRecipeID"] = 118},
	[5223] = {["dwCraftID"] = 4, ["dwRecipeID"] = 120},
	[5224] = {["dwCraftID"] = 4, ["dwRecipeID"] = 121},
	[5227] = {["dwCraftID"] = 5, ["dwRecipeID"] = 422},
	[5228] = {["dwCraftID"] = 5, ["dwRecipeID"] = 423},
	[2563] = {["dwCraftID"] = 6, ["dwRecipeID"] = 208},
	[2564] = {["dwCraftID"] = 6, ["dwRecipeID"] = 250},
	[2562] = {["dwCraftID"] = 6, ["dwRecipeID"] = 243},
	[2565] = {["dwCraftID"] = 6, ["dwRecipeID"] = 251},	
	[5033] = {["dwCraftID"] = 6, ["dwRecipeID"] = 244},
	[5034] = {["dwCraftID"] = 6, ["dwRecipeID"] = 245},
	[5035] = {["dwCraftID"] = 6, ["dwRecipeID"] = 246},
	[5036] = {["dwCraftID"] = 6, ["dwRecipeID"] = 247},		
	[5037] = {["dwCraftID"] = 6, ["dwRecipeID"] = 248},
	[5038] = {["dwCraftID"] = 6, ["dwRecipeID"] = 249},
	[5294] = {["dwCraftID"] = 5, ["dwRecipeID"] = 424},
	[5295] = {["dwCraftID"] = 5, ["dwRecipeID"] = 429},
	[5334] = {["dwCraftID"] = 5, ["dwRecipeID"] = 436},
	[5340] = {["dwCraftID"] = 5, ["dwRecipeID"] = 449},	
	[5174] = {["dwCraftID"] = 5, ["dwRecipeID"] = 426},
	[5175] = {["dwCraftID"] = 5, ["dwRecipeID"] = 430},
	[5176] = {["dwCraftID"] = 5, ["dwRecipeID"] = 435},
	[5177] = {["dwCraftID"] = 5, ["dwRecipeID"] = 438},		
	[5178] = {["dwCraftID"] = 5, ["dwRecipeID"] = 427},
	[5179] = {["dwCraftID"] = 5, ["dwRecipeID"] = 431},	
	[5180] = {["dwCraftID"] = 5, ["dwRecipeID"] = 434},	
	[5181] = {["dwCraftID"] = 5, ["dwRecipeID"] = 439},
	[5182] = {["dwCraftID"] = 5, ["dwRecipeID"] = 428},
	[5188] = {["dwCraftID"] = 5, ["dwRecipeID"] = 432},
	[5189] = {["dwCraftID"] = 5, ["dwRecipeID"] = 433},		
	[5194] = {["dwCraftID"] = 5, ["dwRecipeID"] = 440},
	[5045] = {["dwCraftID"] = 5, ["dwRecipeID"] = 235},		
	[5014] = {["dwCraftID"] = 5, ["dwRecipeID"] = 236},
	[6199] = {["dwCraftID"] = 5, ["dwRecipeID"] = 450},
	[6201] = {["dwCraftID"] = 6, ["dwRecipeID"] = 259},	
	[6202] = {["dwCraftID"] = 6, ["dwRecipeID"] = 260},	
	[6203] = {["dwCraftID"] = 6, ["dwRecipeID"] = 261},
	[6200] = {["dwCraftID"] = 5, ["dwRecipeID"] = 451},
	[6204] = {["dwCraftID"] = 6, ["dwRecipeID"] = 262},
	[6205] = {["dwCraftID"] = 6, ["dwRecipeID"] = 263},		
	[6206] = {["dwCraftID"] = 6, ["dwRecipeID"] = 264},
	[6207] = {["dwCraftID"] = 6, ["dwRecipeID"] = 265},		
	[6208] = {["dwCraftID"] = 6, ["dwRecipeID"] = 266},
	[6415] = {["dwCraftID"] = 5	,["dwRecipeID"] =	452},
	[6416] = {["dwCraftID"] = 5	,["dwRecipeID"] =	463},
	[6417] = {["dwCraftID"] = 5	,["dwRecipeID"] =	464},
	[2419] = {["dwCraftID"] = 5	,["dwRecipeID"] =	213},
	[2420] = {["dwCraftID"] = 5	,["dwRecipeID"] =	214},
	[2421] = {["dwCraftID"] = 5	,["dwRecipeID"] =	215},
	[2428] = {["dwCraftID"] = 5	,["dwRecipeID"] =	222},
	[2429] = {["dwCraftID"] = 5	,["dwRecipeID"] =	223},
	[2430] = {["dwCraftID"] = 5	,["dwRecipeID"] =	224},
	[6418] = {["dwCraftID"] = 5	,["dwRecipeID"] =	453},
	[6419] = {["dwCraftID"] = 5	,["dwRecipeID"] =	462},
	[6420] = {["dwCraftID"] = 5	,["dwRecipeID"] =	465},
	[5201] = {["dwCraftID"] = 5	,["dwRecipeID"] =	454},
	[5202] = {["dwCraftID"] = 5	,["dwRecipeID"] =	466},
	[5203] = {["dwCraftID"] = 5	,["dwRecipeID"] =	461},
	[5195] = {["dwCraftID"] = 5	,["dwRecipeID"] =	455},
	[5196] = {["dwCraftID"] = 5	,["dwRecipeID"] =	460},
	[5197] = {["dwCraftID"] = 5	,["dwRecipeID"] =	467},
	[6421] = {["dwCraftID"] = 5	,["dwRecipeID"] =	456},
	[6422] = {["dwCraftID"] = 5	,["dwRecipeID"] =	459},
	[6423] = {["dwCraftID"] = 5	,["dwRecipeID"] =	468},
	[6424] = {["dwCraftID"] = 5	,["dwRecipeID"] =	457},
	[6425] = {["dwCraftID"] = 5	,["dwRecipeID"] =	458},
	[6426] = {["dwCraftID"] = 5	,["dwRecipeID"] =	469},
	[2567] = {["dwCraftID"] = 6	,["dwRecipeID"] =	212},
	[2566] = {["dwCraftID"] = 6	,["dwRecipeID"] =	211},
	[2568] = {["dwCraftID"] = 6	,["dwRecipeID"] =	213},
	[5198] = {["dwCraftID"] = 6	,["dwRecipeID"] =	293},
	[5199] = {["dwCraftID"] = 6	,["dwRecipeID"] =	271},
	[5200] = {["dwCraftID"] = 6	,["dwRecipeID"] =	294},
	[6325] = {["dwCraftID"] = 6	,["dwRecipeID"] =	295},
	[6326] = {["dwCraftID"] = 6	,["dwRecipeID"] =	296},
	[6327] = {["dwCraftID"] = 6	,["dwRecipeID"] =	297},
	[6328] = {["dwCraftID"] = 6	,["dwRecipeID"] =	298},
	[6329] = {["dwCraftID"] = 6	,["dwRecipeID"] =	299},
	[6330] = {["dwCraftID"] = 6	,["dwRecipeID"] =	300},
	[6331] = {["dwCraftID"] = 6	,["dwRecipeID"] =	301},
	[6332] = {["dwCraftID"] = 6	,["dwRecipeID"] =	302},
	[6333] = {["dwCraftID"] = 6	,["dwRecipeID"] =	303},
	[6334] = {["dwCraftID"] = 6	,["dwRecipeID"] =	304},
	[6295] = {["dwCraftID"] = 4	,["dwRecipeID"] =	122},
	[6296] = {["dwCraftID"] = 4	,["dwRecipeID"] =	123},
	[6297] = {["dwCraftID"] = 4	,["dwRecipeID"] =	124},
	[6298] = {["dwCraftID"] = 4	,["dwRecipeID"] =	125},
	[6427] = {["dwCraftID"] = 5	,["dwRecipeID"] =	494},
	[6593] = {["dwCraftID"] = 5	,["dwRecipeID"] =	495},
	[6594] = {["dwCraftID"] = 5	,["dwRecipeID"] =	496},
	[6595] = {["dwCraftID"] = 5	,["dwRecipeID"] =	497},
	[6611] = {["dwCraftID"] = 5	,["dwRecipeID"] =	498},
	[6596] = {["dwCraftID"] = 5	,["dwRecipeID"] =	499},
	[6597] = {["dwCraftID"] = 5	,["dwRecipeID"] =	500},
	[6598] = {["dwCraftID"] = 5	,["dwRecipeID"] =	501},
	[6599] = {["dwCraftID"] = 5	,["dwRecipeID"] =	502},
	[6600] = {["dwCraftID"] = 5	,["dwRecipeID"] =	503},
 	[6601] = {["dwCraftID"] = 5	,["dwRecipeID"] =	504},
	[6602] = {["dwCraftID"] = 5	,["dwRecipeID"] =	505},
	[6603] = {["dwCraftID"] = 5	,["dwRecipeID"] =	506},
	[6895] = {["dwCraftID"] = 6	,["dwRecipeID"] =	309},
 	[6896] = {["dwCraftID"] = 6	,["dwRecipeID"] =	310},
	[6897] = {["dwCraftID"] = 6	,["dwRecipeID"] =	311},
	[6898] = {["dwCraftID"] = 6	,["dwRecipeID"] =	312},	
	[6891] = {["dwCraftID"] = 5	,["dwRecipeID"] =	510}, 
	[6893] = {["dwCraftID"] = 5	,["dwRecipeID"] =	511},      
	[6894] = {["dwCraftID"] = 5	,["dwRecipeID"] =	218}, 
	[6918] = {["dwCraftID"] = 6	,["dwRecipeID"] =	315},      
	[6925] = {["dwCraftID"] = 6	,["dwRecipeID"] =	316}, 
	[6879] = {["dwCraftID"] = 5	,["dwRecipeID"] =	512},
	[6882] = {["dwCraftID"] = 5	,["dwRecipeID"] =	513},
	[6883] = {["dwCraftID"] = 5	,["dwRecipeID"] =	514},
 	[6884] = {["dwCraftID"] = 5	,["dwRecipeID"] =	515},
	[6886] = {["dwCraftID"] = 5	,["dwRecipeID"] =	516},
	[6888] = {["dwCraftID"] = 5	,["dwRecipeID"] =	517},	
	[6889] = {["dwCraftID"] = 5	,["dwRecipeID"] =	518}, 
	
	[7503] = {["dwCraftID"] = 5	,["dwRecipeID"] =	524},
	[7505] = {["dwCraftID"] = 5	,["dwRecipeID"] =	525},	
	[7498] = {["dwCraftID"] = 6	,["dwRecipeID"] =	318}, 	
	[7492] = {["dwCraftID"] = 6	,["dwRecipeID"] =	319}, 	
	[7496] = {["dwCraftID"] = 6	,["dwRecipeID"] =	322}, 	
	[7490] = {["dwCraftID"] = 6	,["dwRecipeID"] =	323}, 		      
	
	-------------------------�����ǰ�����Ƶ��䷽------------------------	
	--���
	[9795] = {["dwCraftID"] = 4	,["dwRecipeID"] =	143},	--�䷽����������
	[9796] = {["dwCraftID"] = 4	,["dwRecipeID"] =	144},	--�䷽���ٽ�ũ����
	[9797] = {["dwCraftID"] = 4	,["dwRecipeID"] =	145},	--�䷽��������
	[9798] = {["dwCraftID"] = 4	,["dwRecipeID"] =	146},	--�䷽���������
	[9799] = {["dwCraftID"] = 4	,["dwRecipeID"] =	147},	--�䷽���������б�
	[9800] = {["dwCraftID"] = 4	,["dwRecipeID"] =	148},	--�䷽��˫�����
	[9801] = {["dwCraftID"] = 4	,["dwRecipeID"] =	149},	--�䷽���������
	[9802] = {["dwCraftID"] = 4	,["dwRecipeID"] =	150},	--�䷽����������
	[9803] = {["dwCraftID"] = 4	,["dwRecipeID"] =	151},	--�䷽���罷��צ
	[9804] = {["dwCraftID"] = 4	,["dwRecipeID"] =	152},	--�䷽���������
	[9805] = {["dwCraftID"] = 4	,["dwRecipeID"] =	153},	--�䷽��С����
	[9806] = {["dwCraftID"] = 4	,["dwRecipeID"] =	154},	--�䷽�����缦צ
	[9807] = {["dwCraftID"] = 4	,["dwRecipeID"] =	155},	--�䷽���ִ����
	[9808] = {["dwCraftID"] = 4	,["dwRecipeID"] =	156},	--�䷽��������
	[9809] = {["dwCraftID"] = 4	,["dwRecipeID"] =	157},	--�䷽�������צ
	[9810] = {["dwCraftID"] = 4	,["dwRecipeID"] =	158},	--�䷽���ཷ���
	[9811] = {["dwCraftID"] = 4	,["dwRecipeID"] =	159},	--�䷽�����˭������÷
	[9812] = {["dwCraftID"] = 4	,["dwRecipeID"] =	160},	--�䷽����ʮ��������ҹ
	[9813] = {["dwCraftID"] = 4	,["dwRecipeID"] =	161},	--�䷽��ԧ�������
	[9814] = {["dwCraftID"] = 4	,["dwRecipeID"] =	167},	--�䷽����ζ�決��
	[9816] = {["dwCraftID"] = 4	,["dwRecipeID"] =	163},	--�䷽��Ѭ�����o
	[9817] = {["dwCraftID"] = 4	,["dwRecipeID"] =	164},	--�䷽��̼�����
	[9818] = {["dwCraftID"] = 4	,["dwRecipeID"] =	165},	--�䷽���������
	[9819] = {["dwCraftID"] = 4	,["dwRecipeID"] =	166},	--�䷽����������
	[9841] = {["dwCraftID"] = 4	,["dwRecipeID"] =	168},	--�䷽��������
	[10275] = {["dwCraftID"] = 4 ,["dwRecipeID"] =	169},	--ʳ�ף���������
	[10277] = {["dwCraftID"] = 4 ,["dwRecipeID"] =	170},	--ʳ�ף�Ц����
	[10278] = {["dwCraftID"] = 4 ,["dwRecipeID"] =	171},	--ʳ�ף�������
	[10279] = {["dwCraftID"] = 4 ,["dwRecipeID"] =	172},	--ʳ�ף�������
	[10280] = {["dwCraftID"] = 4 ,["dwRecipeID"] =	173},	--ʳ�ף�������
	[10281] = {["dwCraftID"] = 4 ,["dwRecipeID"] =	174},	--ʳ�ף�������
	--����
	[8924] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	535},	--�칤ͼ����Ǭ����
	[8995] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	592},	--�칤ͼ����Ǭ����
	[8997] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	593},	--�칤ͼ����������
	[9000] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	595},	--�칤ͼ�����커��
	[9002] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	596},	--�칤ͼ����������
	[9005] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	598},	--�칤ͼ����������
	[9007] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	599},	--�칤ͼ����ˮ����
	[9010] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	601},	--�칤ͼ����ˮ����
	[9012] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	602},	--�칤ͼ���Ԫ����
	[9015] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	604},	--�칤ͼ���Ԫ����
	[9017] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	605},	--�칤ͼ���з�����
	[9020] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	607},	--�칤ͼ���з绤��
	[9022] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	608},	--�칤ͼ����������
	[9025] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	610},	--�칤ͼ��������
	[9027] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	611},	--�칤ͼ���Ƕ�����
	[9030] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	613},	--�칤ͼ���Ƕһ���
	[9035] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	615},	--�칤ͼ��������Ǭ��װ
	[9039] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	617},	--�칤ͼ��������Ǭ����
	[9041] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	618},	--�칤ͼ������������װ
	[9045] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	620},	--�칤ͼ��������������
	[9047] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	621},	--�칤ͼ������������װ
	[9051] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	623},	--�칤ͼ��������������
	[9053] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	624},	--�칤ͼ��������ˮ��װ
	[9057] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	626},	--�칤ͼ��������ˮ����
	[9059] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	627},	--�칤ͼ�������Ԫ��װ
	[9063] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	629},	--�칤ͼ�������Ԫ����
	[9065] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	630},	--�칤ͼ�����񡤲з���װ
	[9069] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	632},	--�칤ͼ�����񡤲з�����
	[9071] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	633},	--�칤ͼ�����񡤶�����װ
	[9075] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	635},	--�칤ͼ�����񡤶�������
	[9077] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	636},	--�칤ͼ�������Ƕ���װ
	[9081] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	638},	--�칤ͼ�������Ƕ�����
	[9102] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	659},	--�������ط�����װ
	[9105] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	660},	--�������ط�������
	[9107] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	661},	--�껨���ط�����װ
	[9109] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	662},	--�껨���ط�������
	[9111] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	663},	--������ط�����װ
	[9113] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	664},	--������ط�������
	[9115] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	665},	--��Ӣ���ط�����װ
	[9117] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	666},	--�������ط�������
	[9119] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	667},	--����Ⱦ�ط�����װ
	[9121] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	668},	--����Ⱦ�ط�������
	[9123] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	669},	--�껨Ⱦ�ط�����װ
	[9125] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	670},	--�껨Ⱦ�ط�������
	[9127] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	671},	--���Ⱦ�ط�����װ
	[9129] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	672},	--���Ⱦ�ط�������
	[9131] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	673},	--��ӢȾ�ط�����װ
	[9133] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	674},	--����Ⱦ�ط�������
	[9135] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	675},	--�����칤�壺��װ
	[9137] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	676},	--�����칤�壺����
	[9139] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	677},	--�׻��칤�壺��װ
	[9141] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	678},	--�׻��칤�壺����
	[9143] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	679},	--��ȸ�칤�壺��װ
	[9145] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	680},	--��ȸ�칤�壺����
	[9147] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	681},	--���칤�壺��װ
	[9149] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	682},	--���칤�壺����
	[9151] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	683},	--�����칤Ⱦ����װ
	[9153] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	684},	--�����칤Ⱦ������
	[9155] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	685},	--�׻��칤Ⱦ����װ
	[9157] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	686},	--�׻��칤Ⱦ������
	[9159] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	687},	--��ȸ�칤Ⱦ����װ
	[9161] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	688},	--��ȸ�칤Ⱦ������
	[9163] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	689},	--���칤Ⱦ����װ
	[9165] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	690},	--���칤Ⱦ������
	[10180] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	647},	--�������ط�����װ
	[10181] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	648},	--��Ӣ���ط�������
	[10182] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	657},	--����Ⱦ�ط�����װ
	[10183] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	658},	--��ӢȾ�ط�������
	--����
	[9481] = {["dwCraftID"] = 6	,["dwRecipeID"] =	374},	--�칤ͼ����������
	[9484] = {["dwCraftID"] = 6	,["dwRecipeID"] =	376},	--�칤ͼ����������
	[9486] = {["dwCraftID"] = 6	,["dwRecipeID"] =	377},	--�칤ͼ���������
	[9489] = {["dwCraftID"] = 6	,["dwRecipeID"] =	379},	--�칤ͼ����ػ���
	[9491] = {["dwCraftID"] = 6	,["dwRecipeID"] =	380},	--�칤ͼ����������
	[9494] = {["dwCraftID"] = 6	,["dwRecipeID"] =	382},	--�칤ͼ��������
	[9496] = {["dwCraftID"] = 6	,["dwRecipeID"] =	383},	--�칤ͼ����������
	[9499] = {["dwCraftID"] = 6	,["dwRecipeID"] =	385},	--�칤ͼ�����׻���
	[9501] = {["dwCraftID"] = 6	,["dwRecipeID"] =	386},	--�칤ͼ����������
	[9504] = {["dwCraftID"] = 6	,["dwRecipeID"] =	388},	--�칤ͼ����������
	[9507] = {["dwCraftID"] = 6	,["dwRecipeID"] =	390},	--�칤ͼ��������������
	[9510] = {["dwCraftID"] = 6	,["dwRecipeID"] =	392},	--�칤ͼ��������������
	[9512] = {["dwCraftID"] = 6	,["dwRecipeID"] =	393},	--�칤ͼ��������ػ���
	[9515] = {["dwCraftID"] = 6	,["dwRecipeID"] =	395},	--�칤ͼ�������������
	[9517] = {["dwCraftID"] = 6	,["dwRecipeID"] =	396},	--�칤ͼ�����񡤽�����
	[9520] = {["dwCraftID"] = 6	,["dwRecipeID"] =	398},	--�칤ͼ�����񡤽�������
	[9522] = {["dwCraftID"] = 6	,["dwRecipeID"] =	399},	--�칤ͼ���������׻���
	[9525] = {["dwCraftID"] = 6	,["dwRecipeID"] =	401},	--�칤ͼ��������������
	[9527] = {["dwCraftID"] = 6	,["dwRecipeID"] =	402},	--�칤ͼ�����񡤷�������
	[9530] = {["dwCraftID"] = 6	,["dwRecipeID"] =	404},	--�칤ͼ�����񡤷�������
	[9629] = {["dwCraftID"] = 6	,["dwRecipeID"] =	423},	--�칤ͼ���껨ĥʯ
	[9631] = {["dwCraftID"] = 6	,["dwRecipeID"] =	424},	--�칤ͼ������ĥʯ
	[9633] = {["dwCraftID"] = 6	,["dwRecipeID"] =	425},	--�칤ͼ������ĥʯ
	[9635] = {["dwCraftID"] = 6	,["dwRecipeID"] =	426},	--�칤ͼ���׻�ĥʯ
	[9637] = {["dwCraftID"] = 6	,["dwRecipeID"] =	427},	--�칤ͼ��Ƭ��ĥʯ
	[10245] = {["dwCraftID"] = 6	,["dwRecipeID"] =	428},	--�칤ͼ�����ĥʯ
	[9641] = {["dwCraftID"] = 6	,["dwRecipeID"] =	429},	--���׼�Ƭ�ط���ͷ��
	[9643] = {["dwCraftID"] = 6	,["dwRecipeID"] =	430},	--���׼�Ƭ�ط���Ь��
	[9645] = {["dwCraftID"] = 6	,["dwRecipeID"] =	431},	--�껨��Ƭ�ط���ͷ��
	[9647] = {["dwCraftID"] = 6	,["dwRecipeID"] =	432},	--�껨��Ƭ�ط���Ь��
	[9649] = {["dwCraftID"] = 6	,["dwRecipeID"] =	433},	--��Ƽ�Ƭ�ط���ͷ��
	[9651] = {["dwCraftID"] = 6	,["dwRecipeID"] =	434},	--��Ƽ�Ƭ�ط���Ь��
	[9653] = {["dwCraftID"] = 6	,["dwRecipeID"] =	435},	--��Ӣ��Ƭ�ط���ͷ��
	[9655] = {["dwCraftID"] = 6	,["dwRecipeID"] =	436},	--������Ƭ�ط���Ь��
	[9661] = {["dwCraftID"] = 6	,["dwRecipeID"] =	441},	--�칤ͼ������ĥʯ
	[9663] = {["dwCraftID"] = 6	,["dwRecipeID"] =	442},	--�칤ͼ���׻�ĥʯ
	[9665] = {["dwCraftID"] = 6	,["dwRecipeID"] =	443},	--�칤ͼ������ĥʯ
	[9667] = {["dwCraftID"] = 6	,["dwRecipeID"] =	444},	--�칤ͼ�����ĥʯ
	[9669] = {["dwCraftID"] = 6	,["dwRecipeID"] =	445},	--�칤ͼ������ĥʯ
	[9671] = {["dwCraftID"] = 6	,["dwRecipeID"] =	446},	--�칤ͼ����ȸĥʯ
	[2573] = {["dwCraftID"] = 6	,["dwRecipeID"] =	447},	--�칤ͼ����Ѫĥʯ
	[9788] = {["dwCraftID"] = 6	,["dwRecipeID"] =	448},	--�칤ͼ����ĥʯ
	[9673] = {["dwCraftID"] = 6	,["dwRecipeID"] =	449},	--������Ƭ�ط���ͷ��
	[9675] = {["dwCraftID"] = 6	,["dwRecipeID"] =	450},	--������Ƭ�ط���Ь��
	[9677] = {["dwCraftID"] = 6	,["dwRecipeID"] =	451},	--�׻���Ƭ�ط���ͷ��
	[9679] = {["dwCraftID"] = 6	,["dwRecipeID"] =	452},	--�׻���Ƭ�ط���Ь��
	[9681] = {["dwCraftID"] = 6	,["dwRecipeID"] =	453},	--��ȸ��Ƭ�ط���ͷ��
	[9683] = {["dwCraftID"] = 6	,["dwRecipeID"] =	454},	--��ȸ��Ƭ�ط���Ь��
	[9685] = {["dwCraftID"] = 6	,["dwRecipeID"] =	455},	--����Ƭ�ط���ͷ��
	[9687] = {["dwCraftID"] = 6	,["dwRecipeID"] =	456},	--����Ƭ�ط���Ь��
	[10179] = {["dwCraftID"] = 6 ,["dwRecipeID"] =	421},	--������Ƭ�ط���ͷ��
	[10174] = {["dwCraftID"] = 6 ,["dwRecipeID"] =	422},	--��Ӣ��Ƭ�ط���Ь��
  	--ҽ��
	[9709] = {["dwCraftID"] = 7	,["dwRecipeID"] =	159},	--�䷽�����롤��
	[9711] = {["dwCraftID"] = 7	,["dwRecipeID"] =	160},	--�䷽�����롤��
	[9713] = {["dwCraftID"] = 7	,["dwRecipeID"] =	161},	--�䷽�����롤ˮ
	[9715] = {["dwCraftID"] = 7	,["dwRecipeID"] =	162},	--�䷽�����롤��
	[9717] = {["dwCraftID"] = 7	,["dwRecipeID"] =	163},	--�䷽�����롤��
	[9719] = {["dwCraftID"] = 7	,["dwRecipeID"] =	164},	--ҩ������Ʒ��ʹ��
	[9721] = {["dwCraftID"] = 7	,["dwRecipeID"] =	165},	--ҩ������Ʒ����
	[9723] = {["dwCraftID"] = 7	,["dwRecipeID"] =	166},	--ҩ������Ʒ��Ԫ��
	[9725] = {["dwCraftID"] = 7	,["dwRecipeID"] =	167},	--ҩ������Ʒ������
	[9727] = {["dwCraftID"] = 7	,["dwRecipeID"] =	192},	--ҩ������Ʒ����ɢ
	[9729] = {["dwCraftID"] = 7	,["dwRecipeID"] =	169},	--ҩ������Ʒ��¶ɢ
	[9731] = {["dwCraftID"] = 7	,["dwRecipeID"] =	170},	--ҩ������Ʒ�򻨵�
	[9733] = {["dwCraftID"] = 7	,["dwRecipeID"] =	171},	--�䷽�����롤��
	[9735] = {["dwCraftID"] = 7	,["dwRecipeID"] =	172},	--�䷽�����롤��
	[9737] = {["dwCraftID"] = 7	,["dwRecipeID"] =	173},	--ҩ������ƷֹѪ��
	[9739] = {["dwCraftID"] = 7	,["dwRecipeID"] =	174},	--ҩ������Ʒ���絤
	[9741] = {["dwCraftID"] = 7	,["dwRecipeID"] =	175},	--ҩ������Ʒ����
	[9743] = {["dwCraftID"] = 7	,["dwRecipeID"] =	176},	--ҩ������Ʒ������
	[9745] = {["dwCraftID"] = 7	,["dwRecipeID"] =	177},	--ҩ������Ʒ���ĵ�
	[9747] = {["dwCraftID"] = 7	,["dwRecipeID"] =	178},	--ҩ������Ʒ������
	[9749] = {["dwCraftID"] = 7	,["dwRecipeID"] =	179},	--ҩ������Ʒ���
	[9751] = {["dwCraftID"] = 7	,["dwRecipeID"] =	180},	--ҩ������Ʒ�ƻ൤
	[9753] = {["dwCraftID"] = 7	,["dwRecipeID"] =	181},	--ҩ������Ʒ�ۻ굤
	[9755] = {["dwCraftID"] = 7	,["dwRecipeID"] =	182},	--ҩ������Ʒ������
	[9757] = {["dwCraftID"] = 7	,["dwRecipeID"] =	183},	--ҩ������Ʒǿ��
	[9793] = {["dwCraftID"] = 7	,["dwRecipeID"] =	184},	--ҩ������Ʒ����ֹѪ��
	[9760] = {["dwCraftID"] = 7	,["dwRecipeID"] =	185},	--ҩ������Ʒ���ǵ�
	[9762] = {["dwCraftID"] = 7	,["dwRecipeID"] =	186},	--ҩ������Ʒչ�ﵤ
	[9764] = {["dwCraftID"] = 7	,["dwRecipeID"] =	187},	--ҩ������Ʒ��Ԫ��
	[9766] = {["dwCraftID"] = 7	,["dwRecipeID"] =	188},	--ҩ������Ʒ����
	[9768] = {["dwCraftID"] = 7	,["dwRecipeID"] =	189},	--�䷽�����롤��
	[9770] = {["dwCraftID"] = 7	,["dwRecipeID"] =	190},	--�䷽�����롤��
	[9843] = {["dwCraftID"] = 7	,["dwRecipeID"] =	191},	--ҩ������Ʒ���ɢ 
	[10287] = {["dwCraftID"] = 7 ,["dwRecipeID"] =	194},	--�ط�������ˮ
	[10288] = {["dwCraftID"] = 7 ,["dwRecipeID"] =	195},	--�ط�������ˮ
	[10289] = {["dwCraftID"] = 7 ,["dwRecipeID"] =	196},	--�ط�������ˮ
	[10290] = {["dwCraftID"] = 7 ,["dwRecipeID"] =	197},	--�ط�������ˮ
	[10291] = {["dwCraftID"] = 7 ,["dwRecipeID"] =	198},	--�ط�������ˮ  
	[10310] = {["dwCraftID"] = 7 ,["dwRecipeID"] =	199},	--ҩ�����׹���  
	
	--------------------------------------һ����ʦ---------------------------------------
	-->����
	[10273] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	694},	--�칤ͼ����Ⱦ����

	-->����
	[11058] = {["dwCraftID"] = 6 ,["dwRecipeID"] =	463},	--�칤ͼ�����令��
	[11057] = {["dwCraftID"] = 6 ,["dwRecipeID"] =	461},	--�칤ͼ����������
	[11060] = {["dwCraftID"] = 6 ,["dwRecipeID"] =	466},	--�칤ͼ��������
	[11059] = {["dwCraftID"] = 6 ,["dwRecipeID"] =	464},	--�칤ͼ����������	
	[11061] = {["dwCraftID"] = 6 ,["dwRecipeID"] =	467},	--�칤ͼ���������令��
	[11062] = {["dwCraftID"] = 6 ,["dwRecipeID"] =	471},	--�칤ͼ��������������
	[11063] = {["dwCraftID"] = 6 ,["dwRecipeID"] =	468},	--�칤ͼ�����񡤸�����
	[11064] = {["dwCraftID"] = 6 ,["dwRecipeID"] =	472},	--�칤ͼ�����񡤸�������	 		    	
     	
}

local function TongArenaCondition_0()
	local nBuffID = 791 -- �����̨ ������bu
	if Player_IsBuffExist(nBuffID) then
		return true
	end
	return false
end

function IsFilterOperate(szEvent, nParam)
	if szEvent == "TRADING_INVITE" or szEvent == "INVITE_ARENA_CORPS" or 
	   szEvent == "INVITE_JOIN_TONG_REQUEST" or szEvent == "PARTY_INVITE_REQUEST" or 
	   szEvent == "STR_PLAYER_APPLY_PARTY" or szEvent == "PLAYER_BE_ADD_FELLOWSHIP" then
	  	if TongArenaCondition_0() then 
			return true
		end		
	end
	
	return false
end

local dwClientPlayerID
function UI_GetClientPlayerID()
	if not dwClientPlayerID then
		local player = GetClientPlayer()
		dwClientPlayerID = player.dwID
	end
	return dwClientPlayerID
end

local tPlayerSyncFrameData = {
	Force = false,
	Upper = 32,			-- >=Upper ʹ�����֡���
	BaseFrame = 1,	-- ��׼֡
	Expire = 4,			-- �ȶ�֡�����ж�
	LastTime = 0,
	LastFrame = 0,
	
	16,		-- 1
	16,		-- 2
	15, 	-- 3
	14,  	-- 4
	12,		-- 5
	10,		-- 6
	10,		-- 7
	10, 	-- 8
	8,		-- 9
	8,		-- 10
	8, 		-- 11
	8, 		-- 12
	8, 		-- 13
	8, 		-- 14
	8, 		-- 15
	4, 		-- 16
	4, 		-- 17
	4, 		-- 18
	4, 		-- 19
	4, 		-- 20
	4, 		-- 21
	4, 		-- 22
	4, 		-- 23
	4, 		-- 24
	4, 		-- 25
	2, 		-- 26
	2, 		-- 27
	2, 		-- 28
	2, 		-- 29
	2, 		-- 30
	2, 		-- 31
}

function UpdatePlayerSyncFrameInterval(nFrame)
	if LoadingPanel.bInLoading then
		return
	end

	if tPlayerSyncFrameData.Force and nFrame == nil then
		return
	end
	
	if nFrame then
		SetPlayerSyncFrameInterval(nFrame)
		tPlayerSyncFrameData.Force = true
		return
	end
	
	local time = GetTickCount()
	if time - tPlayerSyncFrameData.LastTime < 2000 then
		return
	end
	
	tPlayerSyncFrameData.LastTime = time
	
	local fps = GetFPS()
	if math.abs(fps - tPlayerSyncFrameData.BaseFrame) <= tPlayerSyncFrameData.Expire then
		return
	end
	
	tPlayerSyncFrameData.BaseFrame = fps
	
	if fps >= tPlayerSyncFrameData.Upper then	-- Ĭ����켶��
		if tPlayerSyncFrameData.LastFrame ~= 1 then
			SetPlayerSyncFrameInterval(1)
			tPlayerSyncFrameData.LastFrame = 1
		end
		return
	end
	
	local frame = tPlayerSyncFrameData[fps]
	if not frame or frame == tPlayerSyncFrameData.LastFrame then
		return
	end
	
	SetPlayerSyncFrameInterval(frame)
	tPlayerSyncFrameData.LastFrame = frame
end

RegisterEvent("LOADING_END", function() dwClientPlayerID = nil end)