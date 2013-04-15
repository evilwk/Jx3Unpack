-- 音效表
g_sound =
{
	ActionFailed = "data\\sound\\界面\\ActionFailed.wav",
	Button = "data\\sound\\界面\\Button.wav",
	CloseFrame = "data\\sound\\界面\\CloseFrame.wav",
	Complete = "data\\sound\\界面\\Complete.wav",
	Destroy = "data\\sound\\界面\\Destroy.wav",
	DropSkill = "data\\sound\\界面\\DropSkill.wav",
	Friend = "data\\sound\\界面\\Friend.wav",
	Gift = "data\\sound\\界面\\Gift.wav",
	Invite = "data\\sound\\界面\\Invite.wav",
	LevelUp = "data\\sound\\界面\\LevelUp.wav",
	Mail = "data\\sound\\界面\\Mail.wav",
	MapHit = "data\\sound\\界面\\MapHit.wav",
	MapTipShare = "data\\sound\\界面\\MapTipShare.wav",
	NewMail = "data\\sound\\界面\\NewMail.wav",
	OpenFrame = "data\\sound\\界面\\OpenFrame.wav",
	Ornamental = "data\\sound\\界面\\Ornamental.wav",
	PickupArmer = "data\\sound\\界面\\PickupArmer.wav",
	PickupChina = "data\\sound\\界面\\PickupChina.wav",
	PickupCloth = "data\\sound\\界面\\PickupCloth.wav",
	PickupHerb = "data\\sound\\界面\\PickupHerb.wav",
	PickupIron = "data\\sound\\界面\\PickupIron.wav",
	PickupMoney = "data\\sound\\界面\\PickupMoney.wav",
	PickupPaper = "data\\sound\\界面\\PickupPaper.wav",
	PickupRing = "data\\sound\\界面\\PickupRing.wav",
	PickupRock = "data\\sound\\界面\\PickupRock.wav",
	PickupWater = "data\\sound\\界面\\PickupWater.wav",
	PickupMeat = "data\\sound\\界面\\PickupMeat.wav",
	PickupFood = "data\\sound\\界面\\PickupFood.wav",
	PickupPill = "data\\sound\\界面\\PickupPill.wav",
	Practice = "data\\sound\\界面\\Practice.wav",
	Repair= "data\\sound\\界面\\Repair.wav",
	Sell = "data\\sound\\界面\\Sell.wav",
	TakeUpSkill = "data\\sound\\界面\\TakeUpSkill.wav",
	Trade = "data\\sound\\界面\\Trade.wav",
	PickupWeapon01 = "data\\sound\\界面\\PickupWeapon01.wav",
	PickupWeapon02 = "data\\sound\\界面\\PickupWeapon02.wav",
	PickupWeapon03 = "data\\sound\\界面\\PickupWeapon03.wav",
	PickupWeapon04 = "data\\sound\\界面\\PickupWeapon04.wav",
	Whisper = "data\\sound\\界面\\Whisper.wav",
	OpenAuction = "data\\sound\\界面\\Auction01.wav",
	CloseAuction = "data\\sound\\界面\\Auction02.wav",
	FinishAchievement = "data\\sound\\界面\\FinishAchievement.wav",
	FEAddMainDiamond = "data\\sound\\界面\\stone1st.wav",
	FEAddDiamond = "data\\sound\\界面\\stone2rd.wav",
	FEProduceDiamondFail = "data\\sound\\界面\\stonefail.wav",
	FEProduceEquipFail = "data\\sound\\界面\\itemfail.wav",
	FEExtractSuccess = "data\\sound\\界面\\stonepick.wav",
	
	Fly = "data\\sound\\界面\\Fly.wav",
	Enter = "data\\sound\\界面\\Enter.wav",
	Hover = "data\\sound\\界面\\Hover.wav",
	Fly1 = "data\\sound\\界面\\Fly1.wav",
	Fly_f1 = "data\\sound\\界面\\Fly_f1.wav",
	Fly_f2 = "data\\sound\\界面\\Fly_f2.wav",
	Fly_m2 = "data\\sound\\界面\\Fly_m2.wav",
	PeiYin = "data\\sound\\界面\\PeiYin.wav",
	Disappear = "data\\sound\\界面\\Disappear.wav",
	ButtonDown = "data\\sound\\界面\\ButtonDown.wav",
	
	ChapterBG = "data\\sound\\界面\\Chapters.wav",
};

function IsEmpty(tTable)
	for _, _ in pairs(tTable) do
		return false
	end
	return true
end

function OnItemLinkDown(hItem)
	local szName = hItem:GetName()
	if szName == "itemlink" then --物品链接
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
		nFrame, nFont = 2, 99	-- 黄
	elseif nDifficult == QUEST_DIFFICULTY_LEVEL.HIGH_LEVEL then
		nFrame, nFont = 5, 158	-- 橙
	elseif nDifficult == QUEST_DIFFICULTY_LEVEL.HIGHER_LEVEL then
		nFrame, nFont = 1, 102	-- 红
	elseif nDifficult == QUEST_DIFFICULTY_LEVEL.LOW_LEVEL then
		nFrame, nFont = 4, 173	-- 绿
	elseif nDifficult == QUEST_DIFFICULTY_LEVEL.LOWER_LEVEL then
		nFrame, nFont = 3, 110	-- 灰
	else
		nFrame, nFont = 2, 99	-- 黄
	end
	return nFrame, nFont
end

function OutputActivityTip(dwActivityID, Rect)
	local tActive = Table_GetCalenderActivity(dwActivityID)
	local szTip = GetFormatText(tActive.szName .. "\n", 0)
	-- level 显示的时候去掉最后的分号
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
			handle:AppendItemFromString(GetFormatText(g_tStrings.STR_TWO_CHINESE_SPACE..tQuestStringInfo["szQuestValueStr"..i].."："..questInfo["nQuestValue"..i], 60))
			MarkQuestTrace(handle, dwQuestID, "quest_state", i - 1)
			handle:AppendItemFromString(GetFormatText("\n"))
		end
	end

	for i = 1, 4, 1 do
		if questInfo["dwKillNpcTemplateID"..i] ~= 0 then
			handle:AppendItemFromString("<text>text="..EncodeComponentsString(
				g_tStrings.STR_TWO_CHINESE_SPACE..Table_GetNpcTemplateName(questInfo["dwKillNpcTemplateID"..i]).."："..questInfo["dwKillNpcAmount"..i]).."font=60</text>")
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
					g_tStrings.STR_TWO_CHINESE_SPACE..GetItemNameByItemInfo(itemInfo).."："..questInfo["dwEndRequireItemAmount"..i]).."font=60</text>")
				MarkQuestTrace(handle, dwQuestID, "need_item", i - 1)
				handle:AppendItemFromString(GetFormatText("\n"))
			end
		end
	end	

	QuestAcceptPanel.UpdateHortation(handle, questInfo, false, false, true)
	
    OutputTip("", 345, Rect, nil, bLink, "quest"..dwQuestID, true)
end

COLOR_TABLE = {
	[0] = 31,		-- 这个是专门用来做 TITLE 文字的
	[1] = 100,		-- 黄色
	[2] = 101,		-- 橘色
	[3] = 102,		-- 红色
	[4] = 103,		-- 紫色
	[5] = 104,		-- 蓝色
	[6] = 105,		-- 绿色
	[7] = 106,		-- 白色
	[8] = 107,		-- 灰色亮度4
	[9] = 108,		-- 灰色亮度3
	[10] = 109,		-- 灰色亮度2
	[11] = 110,		-- 灰色亮度1
	[12] = 111,		-- 粉红
	[13] = 112,		-- 粉紫
	[14] = 113,		-- 粉蓝
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
		local szCategory =	"默认分类"
		local szName =	"默认名字"
		local szTip =	ColorText("未获得信息\n", 0) .. 
						ColorText("你还没有获得此信息。\n各种案件相关的信息都是通过故事的进展陆续获得的。\n\n", 7)
		OutputTip(szTip, 400, rect)
	end,
	[1] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"默认名字"
		local szTip =	ColorText("出示道具\n", 0) .. 
						ColorText("将案件相关的道具出示给对方，用以引出新的话题或者指明矛盾等。\n\n", 7) .. 
						ColorText("这些道具不会占用背包。", 6)
		OutputTip(szTip, 400, rect)
	end,
	[2] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"默认名字"
		local szTip =	ColorText("指出人物或处所\n", 0) .. 
						ColorText("将案件相关的人物或者处所告知对方，用以引出新的话题或者指明矛盾等。\n\n", 7) .. 
						ColorText("人物或处所信息会在游戏过程中自动追加。", 6)
		OutputTip(szTip, 400, rect)
	end,
	[3] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"默认名字"
		local szTip =	ColorText("出示案件资料\n", 0) .. 
						ColorText("将案件相关的资料告知对方，用以引出新的话题或者指明矛盾等。\n\n", 7) .. 
						ColorText("案件资料会在游戏过程中自动追加。", 6)
		OutputTip(szTip, 400, rect)
	end,
	[4] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"默认名字"
		local szTip =	ColorText("提出质问\n", 0) .. 
						ColorText("在对话过程中，对有疑问或者有矛盾的谈话内容进行质问，可能获得新的信息。\n\n", 7) .. 
						ColorText("可能引起对方的反感。", 6)
		OutputTip(szTip, 400, rect)
	end,
	[5] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"默认名字"
		local szTip =	ColorText("听对方上一句话\n", 0) .. 
						ColorText("目标可能会有多句话，此按钮用来回顾上一句对话内容。\n\n", 7)
		OutputTip(szTip, 400, rect)
	end,
	[6] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"默认名字"
		local szTip =	ColorText("成步堂的证词\n", 0) .. 
						ColorText("将案件相关的证据出示给对方，用以引出新的话题或者指明矛盾等。\n\n", 7)
		OutputTip(szTip, 400, rect)
	end,
	[7] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"默认名字"
		local szTip =	ColorText("指出人物或处所\n", 0) .. 
						ColorText("将案件相关的人物或者处所告知对方，用以引出新的话题或者指明矛盾等。\n\n", 7) .. 
						ColorText("每句话的衍生内容不能做此操作。", 3)
		OutputTip(szTip, 400, rect)
	end,
	[8] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"默认名字"
		local szTip =	ColorText("出示案件资料\n", 0) .. 
						ColorText("将案件相关的资料告知对方，用以引出新的话题或者指明矛盾等。\n\n", 7) .. 
						ColorText("每句话的衍生内容不能做此操作。", 3)
		OutputTip(szTip, 400, rect)
	end,
	[9] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"默认名字"
		local szTip =	ColorText("提出疑问\n", 0) .. 
						ColorText("在对话过程中，对有疑问或者有矛盾的谈话内容进行询问，可能获得新的信息。\n\n", 7)
		OutputTip(szTip, 400, rect)
	end,
	[10] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"默认名字"
		local szTip =	ColorText("听对方下一句话\n", 0) .. 
						ColorText("目标可能会有多句话，此按钮用来跳转到下一句对话内容。", 7)
		OutputTip(szTip, 400, rect)
	end,
	[11] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"默认名字"
		local szTip =	ColorText("仵作的证词\n", 0) .. 
						ColorText("尸体被发现的时候是平躺在地面上，死亡时间大概是", 7) .. 
						ColorText("午时后一刻", 3) .. 
						ColorText("，致命死因是", 7) .. 
						ColorText("胸口的剪刀刀伤，刀口向上，应该是蓄意伤人", 3) .. 
						ColorText("，凶器就扔在旁边。周围有搏斗的痕迹。", 7)
		OutputTip(szTip, 400, rect)
	end,
	[12] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"默认名字"
		local szTip =	ColorText("王氏的证词\n", 0) .. 
						ColorText("秀茹可是个好女孩，说话细声细语的，平时大门不出二门不迈，也就找几个闺房密友去家里下棋。", 7)
		OutputTip(szTip, 400, rect)
	end,
	[13] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"默认名字"
		local szTip =	ColorText("曾氏的证词\n", 0) .. 
						ColorText("秀茹啊，她", 7) .. 
						ColorText("下棋的技术很高，人也很冷静，从来没冲动过", 3) .. 
						ColorText("，据说一般的国手都下不过她呢。", 7)
		OutputTip(szTip, 400, rect)
	end,
	[14] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"默认名字"
		local szTip =	ColorText("张屠夫的证词\n", 0) .. 
						ColorText("那天啊，正好我家里有事，", 7) .. 
						ColorText("中午就没开张。", 3)
		OutputTip(szTip, 400, rect)
	end,
	[15] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"默认名字"
		local szTip =	ColorText("李屠夫的证词\n", 0) .. 
						ColorText("秀茹妹子那天的确在我这里买肉了，具体时间我记不住了，大概是", 7) .. 
						ColorText("中午之后", 3) .. 
						ColorText("吧。", 7)
		OutputTip(szTip, 400, rect)
	end,
	[16] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"默认名字"
		local szTip =	ColorText("秀茹的证词\n", 0) .. 
						ColorText("买好肉回到家，我就看见夫君和人在搏斗，我就开始呼喊，这时候那人刺了夫君一刀就跑掉了。", 7)
		OutputTip(szTip, 400, rect)
	end,
	[17] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"默认名字"
		local szTip =	ColorText("焦枯的树枝\n", 0) .. 
						ColorText("残留着冷石灰的烧焦的树枝。冷石是炼丹产物。有剧毒。", 7)
		OutputTip(szTip, 400, rect)
	end,
	[18] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"默认名字"
		local szTip =	ColorText("炼丹道士的证词\n", 0) .. 
						ColorText("有一位姓林的画师给我银子，让我给他炼制冷石。", 7)
		OutputTip(szTip, 400, rect)
	end,
	[19] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"默认名字"
		local szTip =	ColorText("罗轩的证词\n", 0) .. 
						ColorText("当年武及侵犯了张德的妻子，结果夫妇两被误杀，儿子张白尘失踪。\n武及被害的前天晚上有黑衣人行刺武及未遂，左手受伤。行刺之人极有可能是张白尘。", 7)
		OutputTip(szTip, 400, rect)
	end,
	[20] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"默认名字"
		local szTip =	ColorText("夜行衣\n", 0) .. 
						ColorText("藏在金水镇东北的空宅子里的夜行衣，左袖被划了一道口子，上面还沾着血渍。", 7)
		OutputTip(szTip, 400, rect)
	end,
	[21] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"默认名字"
		local szTip =	ColorText("武及的验尸报告\n", 0) .. 
						ColorText("死亡时间大概是昨日入夜戌时；死亡原因是有一根绣花针刺入脑门要害处。", 7)
		OutputTip(szTip, 400, rect)
	end,
	[22] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"默认名字"
		local szTip =	ColorText("凶器·绣花针\n", 0) .. 
						ColorText("这根绣花针有点特别，半银半铜所制，上半部分是银色，下半部分是金色。", 7)
		OutputTip(szTip, 400, rect)
	end,
	[23] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"默认名字"
		local szTip =	ColorText("武晖的证词\n", 0) .. 
						ColorText("罗轩急匆匆地从外头跑回来进房子里和爹说了什么，然后就出来带一群人往贡橘林去了。之后爹呆在房间里一直没什么动静，第二天起来发现爹爹已死去多时。", 7)
		OutputTip(szTip, 400, rect)
	end,
	[24] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"默认名字"
		local szTip =	ColorText("小叫花的证词\n", 0) .. 
						ColorText("那个人是个左撇子！嗯，没错！他给我冷石，付我银两都是用的左手，从来就没见他动过右手，这点我记得很清楚！我当时还纳闷的，金水镇我没见过有左撇子的啊！", 7)
		OutputTip(szTip, 400, rect)
	end,
	[25] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"默认名字"
		local szTip =	ColorText("武晴的证词一\n", 0) .. 
						ColorText("当天我吃完晚饭就买绣花针去了。我的绣花针被罗轩叔叔借去挑刺给弄丢了。", 7)
		OutputTip(szTip, 400, rect)
	end,
	[26] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"默认名字"
		local szTip =	ColorText("武晴的证词二\n", 0) .. 
						ColorText("罗轩叔叔右手被刺伤了，流了好多血！大夫说都伤到筋了。说不定，说不定右手就给废了。", 7)
		OutputTip(szTip, 400, rect)
	end,
	[27] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"默认名字"
		local szTip =	ColorText("鉴定过的凶器\n", 0) .. 
						ColorText("这正是被罗轩借去的武晴的绣花针。", 7)
		OutputTip(szTip, 400, rect)
	end,
	[28] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"默认名字"
		local szTip =	ColorText("林白轩的画\n", 0) .. 
						ColorText("林白轩作的画，上面白色的云雾皆是用冷石粉所图，吸入过多冷石粉便会中毒而死。", 7)
		OutputTip(szTip, 400, rect)
	end,
	[29] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"默认名字"
		local szTip =	ColorText("这个就是测试啊\n", 0) .. 
						ColorText("你看到的都是测试用TIPS.\n", 7) .. 
						ColorText("点击: 那是没有用的!", 6)
		OutputTip(szTip, 400, rect)
	end,
	[30] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"-50"
		local szTip =	ColorText("将预付押金减少", 6) .. 
						ColorText("五十银", 0) .. 
						ColorText("。", 6)
		OutputTip(szTip, 400, rect)
	end,
	[31] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"-10"
		local szTip =	ColorText("将预付押金减少", 6) .. 
						ColorText("十银", 0) .. 
						ColorText("。", 6)
		OutputTip(szTip, 400, rect)
	end,
	[32] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"+10"
		local szTip =	ColorText("将预付押金增加", 6) .. 
						ColorText("十银", 0) .. 
						ColorText("。", 6)
		OutputTip(szTip, 400, rect)
	end,
	[33] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"+50"
		local szTip =	ColorText("将预付押金增加", 6) .. 
						ColorText("五十银", 0) .. 
						ColorText("。", 6)
		OutputTip(szTip, 400, rect)
	end,
	[34] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"刷新"
		local szTip =	ColorText("刷新当前页面。\n\n", 7) .. 
						ColorText("获得最新的战斗者列表和报名者列表信息。", 6)
		OutputTip(szTip, 400, rect)
	end,
	[35] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"确定"
		local szTip =	ColorText("将设置好的预付押金提交给擂台管理员。\n\n", 7) .. 
						ColorText("如果有其他玩家提交了更高的金额，你有可能被挤出报名队列，你之前支付的押金将通过信使全额返还给你。\n", 6) .. 
						ColorText("押金必须高于当前报名列表中金额最少的玩家。", 3)
		OutputTip(szTip, 400, rect)
	end,
	--
	--宠物木屋相关
	--宠物回收
	[36] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"确定"
		local szTip =	ColorText("回收跟宠\n", 7) .. 
						ColorText("取消当前宠物的跟随状态，将其收回到跟宠木屋中来。\n", 6) .. 
						ColorText("侠士也可以通过右键点击跟随状态图标来取消跟随状态。", 1)
		OutputTip(szTip, 400, rect)
	end,
	--吉祥虎
	[37] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"确定"
		local szTip =	ColorText("醉寅视肉：吉祥虎\n", 7) .. 
						ColorText("香喷喷的视肉，可以将吉祥虎召唤出来。\n", 6) .. 
						ColorText("平丘有视肉，食之尽，寻复更生。\n每次召唤持续二十四小时。", 1)
		OutputTip(szTip, 400, rect)
	end,
	--兔瑞瑞（白）
	[38] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"确定"
		local szTip =	ColorText("甘荀萝卜：兔瑞瑞（粉色）\n", 7) .. 
						ColorText("用美味的胡萝卜，可召唤粉红色的“兔瑞瑞”。\n", 6) .. 
						ColorText("抱着一根萝卜，啃啊啃，兔瑞瑞很快就会长大了。\n甘荀萝卜：胡萝卜的别称，又称丁香萝卜。\n每次召唤持续二十四小时。", 1)
		OutputTip(szTip, 400, rect)
	end,
	--兔瑞瑞（灰）
	[39] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"确定"
		local szTip =	ColorText("土酥萝卜：兔瑞瑞（灰色）\n", 7) .. 
						ColorText("用此萝卜，可召唤灰色的“兔瑞瑞”。\n", 6) .. 
						ColorText("抱着一根胡萝卜，啃啊啃，等兔瑞瑞长大就能找到兔祥祥了。\n土酥：萝卜的别名，杜甫有诗云：“长安冬菹酸且绿，金城土酥净如练”。\n每次召唤持续二十四小时。", 1)
		OutputTip(szTip, 400, rect)
	end,
	--兔祥祥（白）
	[40] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"确定"
		local szTip =	ColorText("莱菔萝卜：兔祥祥（粉色）\n", 7) .. 
						ColorText("用萝卜将躲在木屋中的粉红色的兔祥祥召唤出来。\n", 6) .. 
						ColorText("兔子急了也会吃“莱菔”的。\n莱菔：萝卜的别称，早见于《尔雅》记载。\n每次召唤持续二十四小时。", 1)
		OutputTip(szTip, 400, rect)
	end,
	--兔祥祥（灰）
	[41] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"确定"
		local szTip =	ColorText("雹葖萝卜：兔祥祥（灰色）\n", 7) .. 
						ColorText("用胡萝卜将躲在木屋中灰色的兔祥祥召唤出来。\n", 6) .. 
						ColorText("兔祥祥一直在找兔瑞瑞，它们都是祥瑞兔年的吉祥宝贝。\n雹葖：萝卜的别称，晋之郭义恭《广志》有记载。\n每次召唤持续二十四小时。", 1)
		OutputTip(szTip, 400, rect)
	end,
	--兔轶轶（灰）
	[42] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"确定"
		local szTip =	ColorText("心里美萝卜：兔轶轶（灰色）\n", 7) .. 
						ColorText("用此萝卜将躲在木屋中灰色的兔轶轶召唤出来。\n", 6) .. 
						ColorText("兔轶轶只爱“心里美”，没了“心里美”兔轶轶就要溜了，哼！\n每次召唤持续二十四小时。", 1)
		OutputTip(szTip, 400, rect)
	end,
	--兔轶轶（白）
	[43] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"确定"
		local szTip =	ColorText("心里美萝卜：兔轶轶（粉色）\n", 7) .. 
						ColorText("用此萝卜将躲在木屋中粉红色的兔轶轶召唤出来。\n", 6) .. 
						ColorText("兔轶轶只爱“心里美”，没了“心里美”兔轶轶就要溜了，哼！\n每次召唤持续二十四小时。", 1)
						
		OutputTip(szTip, 400, rect)
	end,
	--祥兔阿甘
	[44] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"确定"
		local szTip =	ColorText("祥兔阿甘\n", 7) .. 
						ColorText("先组装阿甘机关，然后将祥兔放进去作为动力。\n", 6) .. 
						ColorText("“祥兔阿甘”最勤快，不像“瑞兔阿甘”那样每天懒洋洋的。\n每次召唤持续三十分钟。", 1)
		OutputTip(szTip, 400, rect)
	end,
	--瑞兔阿甘
	[45] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"确定"
		local szTip =	ColorText("瑞兔阿甘\n", 7) .. 
						ColorText("先组装阿甘机关，然后将瑞兔放进去作为动力。\n", 6) .. 
						ColorText("咔。。咔。。“瑞兔阿甘”很聪明，还能帮忙修东西。\n带有特殊商店的宠物每二十小时只可以召唤一次，每次持续十分钟。", 1)
		OutputTip(szTip, 400, rect)
	end,
	--比翼鸟
	[46] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"确定"
		local szTip =	ColorText("比翼\n", 7) .. 
						ColorText("放飞两只比翼小鸟，环绕在你的周围。\n", 6) .. 
						ColorText("在天愿作比翼鸟 在地愿为连理枝。\n每次召唤持续二十四小时。", 1)
		OutputTip(szTip, 400, rect)
	end,
	--熊猫滚滚
	[47] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"确定"
		local szTip =	ColorText("竹子：阿宝\n", 7) .. 
						ColorText("用鲜嫩的竹子，将那个圆滚滚的阿宝从懒洋洋的美梦中唤醒吧。\n", 6) .. 
						ColorText("养肥了会变超级强力熊猫人，切忌今天俯卧，明天撑哦。\n每次召唤持续二十四小时。", 1)
		OutputTip(szTip, 400, rect)
	end,
	--机关猪1
	[48] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"确定"
		local szTip =	ColorText("唐门机关猪·毒箭\n", 7) .. 
						ColorText("召唤唐门秘制的机关小猪·毒箭\n", 6) .. 
						ColorText("唐门秘制机关猪，会卖子弹会卖萌。\n每次召唤持续二十四小时。", 1)
		OutputTip(szTip, 400, rect)
	end,
	--机关猪2
	[49] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"确定"
		local szTip =	ColorText("唐门机关猪·短刀\n", 7) .. 
						ColorText("召唤唐门秘制的机关小猪·短刀\n", 6) .. 
						ColorText("唐门秘制机关猪，会卖子弹会卖萌。\n每次召唤持续二十四小时。", 1)
		OutputTip(szTip, 400, rect)
	end,
	--机关猪3
	[50] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"确定"
		local szTip =	ColorText("唐门机关猪·飞镖\n", 7) .. 
						ColorText("召唤唐门秘制的机关小猪·飞镖\n", 6) .. 
						ColorText("唐门秘制机关猪，会卖子弹会卖萌。\n每次召唤持续二十四小时。", 1)
		OutputTip(szTip, 400, rect)
	end,
	--机关猪4
	[51] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"确定"
		local szTip =	ColorText("唐门机关猪·竹简\n", 7) .. 
						ColorText("召唤唐门秘制的机关小猪·竹简。\n", 6) .. 
						ColorText("唐门秘制机关猪，会卖子弹会卖萌。\n每次召唤持续二十四小时。", 1)
		OutputTip(szTip, 400, rect)
	end,
		--御灯龙--商店
	[52] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"确定"
		local szTip =	ColorText("御灯龙·吉\n", 7) .. 
						ColorText("召唤御灯龙·吉。\n", 6) .. 
						ColorText("灯，等灯等灯～机关匣装有御龙袋，里边藏着好东西～\n带有特殊商店的宠物每二十小时只可以召唤一次，每次持续十分钟。", 1)
		OutputTip(szTip, 400, rect)
	end,
		--灯龙宝宝
	[53] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"确定"
		local szTip =	ColorText("灯龙宝宝\n", 7) .. 
						ColorText("召唤灯龙宝宝。\n", 6) .. 
						ColorText("御龙行千里，华灯照万家。\n每次召唤持续二十四小时。", 1)
		OutputTip(szTip, 400, rect)
	end,
	--御灯龙--无商店
	[54] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"确定"
		local szTip =	ColorText("御灯龙·福\n", 7) .. 
						ColorText("召唤御灯龙·福。\n", 6) .. 
						ColorText("灯，等灯等灯～\n每次召唤持续二十四小时。", 1)
		OutputTip(szTip, 400, rect)
	end,
	----------------------------
	--藏剑任务矿石图标
	[55] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"确定"
		local szTip =	ColorText("黑乌石\n", 7) .. 
						ColorText("点击选择黑乌石。\n", 6)
		OutputTip(szTip, 400, rect)
	end,
	--藏剑任务矿石图标
	[56] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"确定"
		local szTip =	ColorText("西域金精石\n", 7) .. 
						ColorText("点击选择西域金精石。\n", 6)
		OutputTip(szTip, 400, rect)
	end,
	--藏剑任务矿石图标
	[57] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"确定"
		local szTip =	ColorText("赤火石\n", 7) .. 
						ColorText("点击选择赤火石。\n", 6)
		OutputTip(szTip, 400, rect)
	end,
	--万花任务名琴图标
	[58] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"确定"
		local szTip =	ColorText("【焦尾】\n", 7) .. 
						ColorText("点击选择【焦尾】琴。\n", 6)
		OutputTip(szTip, 400, rect)
	end,
	--万花任务名琴图标
	[59] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"确定"
		local szTip =	ColorText("【绿绮】\n", 7) .. 
						ColorText("点击选择【绿绮】琴。\n", 6)
		OutputTip(szTip, 400, rect)
	end,
	--万花任务名琴图标
	[60] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"确定"
		local szTip =	ColorText("【绕梁】\n", 7) .. 
						ColorText("点击选择【绕梁】琴。\n", 6)
		OutputTip(szTip, 400, rect)
	end,
	--万花任务名琴图标
	[61] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"确定"
		local szTip =	ColorText("【号钟】\n", 7) .. 
						ColorText("点击选择【号钟】琴。\n", 6)
		OutputTip(szTip, 400, rect)
	end,
	--入门图标相关--------
	[62] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"确定"
		local szTip =	ColorText("加入七秀坊\n", 7) .. 
						ColorText("点击加入七秀坊，成为七秀坊正式弟子！\n", 6)
		OutputTip(szTip, 400, rect)
	end,
	--入门图标相关
	[63] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"确定"
		local szTip =	ColorText("加入万花谷\n", 7) .. 
						ColorText("点击加入万花谷，成为万花谷正式弟子！\n", 6)
		OutputTip(szTip, 400, rect)
	end,
	--入门图标相关
	[64] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"确定"
		local szTip =	ColorText("加入五毒教\n", 7) .. 
						ColorText("点击加入五毒教，成为五毒教正式弟子！\n", 6)
		OutputTip(szTip, 400, rect)
	end,
	--入门图标相关
	[65] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"确定"
		local szTip =	ColorText("加入唐门\n", 7) .. 
						ColorText("点击加入唐门，成为唐家堡正式弟子！\n", 6)
		OutputTip(szTip, 400, rect)
	end,
	--入门图标相关
	[66] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"确定"
		local szTip =	ColorText("加入天策府\n", 7) .. 
						ColorText("点击加入天策府，成为天策府正式弟子！\n", 6)
		OutputTip(szTip, 400, rect)
	end,
	--入门图标相关
	[67] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"确定"
		local szName =	"确定"
		local szTip =	ColorText("加入少林寺\n", 7) .. 
						ColorText("点击加入少林寺，成为少林寺正式弟子！\n", 6)
		OutputTip(szTip, 400, rect)
	end,
	--入门图标相关
	[68] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"确定"
		local szTip =	ColorText("加入纯阳宫\n", 7) .. 
						ColorText("点击加入纯阳宫，成为纯阳宫正式弟子！\n", 6)
		OutputTip(szTip, 400, rect)
	end,
	--入门图标相关
	[69] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"确定"
		local szTip =	ColorText("加入藏剑山庄\n", 7) .. 
						ColorText("点击加入藏剑山庄，成为藏剑山庄正式弟子！\n", 6)
		OutputTip(szTip, 400, rect)
	end,
	----------------------------
	----------------------------
	[70] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"默认名字"
		local szTip =	ColorText("水云坊", 5)
		OutputTip(szTip, 400, rect)
	end,
	[71] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"默认名字"
		local szTip =	ColorText("听香坊", 5)
		OutputTip(szTip, 400, rect)
	end,
	[72] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"默认名字"
		local szTip =	ColorText("星月坊", 5)
		OutputTip(szTip, 400, rect)
	end,
	[73] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"默认名字"
		local szTip =	ColorText("忆盈楼", 5)
		OutputTip(szTip, 400, rect)
	end,
	[74] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"默认名字"
		local szTip =	ColorText("二十四桥", 5)
		OutputTip(szTip, 400, rect)
	end,
	[75] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"默认名字"
		local szTip =	ColorText("仙乐码头", 5)
		OutputTip(szTip, 400, rect)
	end,
	[76] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"默认名字"
		local szTip =	ColorText("指挥你下属士兵向北移动", 5)
		OutputTip(szTip, 400, rect)
	end,
	[77] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"默认名字"
		local szTip =	ColorText("发动你下属士兵的特殊技能", 5)
		OutputTip(szTip, 400, rect)
	end,
	[78] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"默认名字"
		local szTip =	ColorText("指挥你下属士兵向东移动", 5)
		OutputTip(szTip, 400, rect)
	end,
	[79] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"默认名字"
		local szTip =	ColorText("指挥你下属士兵停止移动", 5)
		OutputTip(szTip, 400, rect)
	end,
	[80] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"默认名字"
		local szTip =	ColorText("指挥你下属士兵向西移动", 5)
		OutputTip(szTip, 400, rect)
	end,	
	[81] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"默认名字"
		local szTip =	ColorText("指挥你下属士兵攻击你的当前目标", 5)
		OutputTip(szTip, 400, rect)
	end,	
	[82] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"默认名字"
		local szTip =	ColorText("指挥你下属士兵在你南面横向集合", 5)
		OutputTip(szTip, 400, rect)
	end,
	[83] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"默认名字"
		local szTip =	ColorText("指挥你下属士兵向南移动", 5)
		OutputTip(szTip, 400, rect)
	end,	
	[84] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"默认名字"
		local szTip =	ColorText("指挥你下属士兵在你南面纵向集合", 5)
		OutputTip(szTip, 400, rect)
	end,	
	[100] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"默认名字"
		local szTip =	ColorText("纸条\n", 0) .. 
						ColorText("使用：阅读纸条。", 6)
		OutputTip(szTip, 400, rect)
	end,
		--孔明灯·碧
	[101] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"确定"
		local szTip =	ColorText("孔明灯·碧\n", 7) .. 
						ColorText("点亮孔明灯·碧。\n", 6) .. 
						ColorText("燃放一盏随身飞舞的绿色孔明灯\n诚挚祈福。", 1)
		OutputTip(szTip, 400, rect)
	end,
	--孔明灯·苍
	[102] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"确定"
		local szTip =	ColorText("孔明灯·苍\n", 7) .. 
						ColorText("点亮孔明灯·苍。\n", 6) .. 
						ColorText("燃放一盏随身飞舞的蓝色孔明灯\n诚挚祈福。", 1)
		OutputTip(szTip, 400, rect)
	end,
	--孔明灯·朱
	[103] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"确定"
		local szTip =	ColorText("孔明灯·朱\n", 7) .. 
						ColorText("点亮孔明灯·朱。\n", 6) .. 
						ColorText("燃放一盏随身飞舞的红色孔明灯\n诚挚祈福。", 1)
		OutputTip(szTip, 400, rect)
	end,
	--孔明灯·执子之手
	[104] = function(rect)
		local nIconID =	0
		local szCategory =	"默认分类"
		local szName =	"确定"
		local szTip =	ColorText("孔明灯·执子之手\n", 7) .. 
						ColorText("点亮孔明灯·执子之手。\n", 6) .. 
						ColorText("燃放一盏随身飞舞明亮夺目的孔明灯\n诚挚祈福。", 1)
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
			szMessage = "你确定要XXX么？", 
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
			szMessage = "你确定要加入天策府么？一旦入门，不能退出。", 
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
			szMessage = "你确定要加入七秀坊么？一旦入门，不能退出。", 
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
			szMessage = "你确定要加入纯阳宫么？一旦入门，不能退出。", 
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
			szMessage = "你确定要加入万花谷么？一旦入门，不能退出。", 
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
			szMessage = "你确定要加入少林寺么？一旦入门，不能退出。", 
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
			szMessage = "此武功并非你在门派中日积月累修习而来，如果你想废除此武功，可再来找我。", 
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
			szMessage = "你确定要加入藏剑山庄么？一旦入门，不能退出。", 
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
			szMessage = "你确定要加入五毒圣教么？一旦入门，不能退出。", 
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
			szMessage = "你确定要加入唐门么？一旦入门，不能退出。", 
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
	--预充值赠送附魔道具
	[4715] = {["EnchantID"] = 59},
	--缝纫附魔道具
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
	[7061] = {["EnchantID"] =	193},  -- 线刻·金鸣
	[7066] = {["EnchantID"] =	190},  -- 线刻·旗偃
	[7065] = {["EnchantID"] =	191},  -- 线刻·涛海
	[7064] = {["EnchantID"] =	192},  -- 线刻·文壤
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
	[7983] = {["EnchantID"] =	290}, -- 荻花圣殿后山武器磨石
	[7984] = {["EnchantID"] =	291},
	[7985] = {["EnchantID"] =	292},
	[7986] = {["EnchantID"] =	293},
	[7987] = {["EnchantID"] =	294},
	[7988] = {["EnchantID"] =	295},
	[7989] = {["EnchantID"] =	296},
	[7990] = {["EnchantID"] =	297},
	[10298] = {["EnchantID"] =	4687},--端午戒指附魔
	[10299] = {["EnchantID"] =	4686},
	[10300] = {["EnchantID"] =	4685},
	[10301] = {["EnchantID"] =	4684},
	
		----------巴蜀风云附魔----------
	[8930] = {["EnchantID"] =   326},	--岐黄绣（上装）
	[9083] = {["EnchantID"] =  327},	--岐黄绣（护手）
	[9084] = {["EnchantID"] =  328},	--流纹绣（上装）
	[9085] = {["EnchantID"] =  329},	--流纹绣（护手）
	[9086] = {["EnchantID"] =  330},	--角砾绣（上装）
	[9087] = {["EnchantID"] =  331},	--角砾绣（护手）
	[9088] = {["EnchantID"] =  332},	--益元绣（上装）
	[9089] = {["EnchantID"] =  333},	--益元绣（护手）
	[9090] = {["EnchantID"] =  334},	--云锡绣（上装）
	[9091] = {["EnchantID"] =  335},	--云英绣（护手）
	[9092] = {["EnchantID"] =  336},	--岐黄染（下装）
	[9093] = {["EnchantID"] =  337},	--岐黄染（腰带）
	[9094] = {["EnchantID"] =  338},	--流纹染（下装）
	[9095] = {["EnchantID"] =  339},	--流纹染（腰带）
	[9096] = {["EnchantID"] =  340},	--角砾染（下装）
	[9097] = {["EnchantID"] =  341},	--角砾染（腰带）
	[9098] = {["EnchantID"] =  342},	--益元染（下装）
	[9099] = {["EnchantID"] =  343},	--益元染（腰带）
	[9100] = {["EnchantID"] =  344},	--云锡染（下装）
	[9101] = {["EnchantID"] =  345},	--云英染（腰带）
	[9102] = {["EnchantID"] =  346},	--黑曜绣（上装）
	[9103] = {["EnchantID"] =  347},	--黑曜绣（护手）
	[9108] = {["EnchantID"] =  348},	--雨花绣（上装）
	[9110] = {["EnchantID"] =  349},	--雨花绣（护手）
	[9112] = {["EnchantID"] =  350},	--田黄绣（上装）
	[9114] = {["EnchantID"] =  351},	--田黄绣（护手）
	[9116] = {["EnchantID"] =  352},	--云英绣（上装）
	[9118] = {["EnchantID"] =  353},	--云锡绣（护手）
	[9120] = {["EnchantID"] =  354},	--黑曜染（下装）
	[9122] = {["EnchantID"] =  355},	--黑曜染（腰带）
	[9124] = {["EnchantID"] =  356},	--雨花染（下装）
	[9126] = {["EnchantID"] =  357},	--雨花染（腰带）
	[9128] = {["EnchantID"] =  358},	--田黄染（下装）
	[9130] = {["EnchantID"] =  359},	--田黄染（腰带）
	[9132] = {["EnchantID"] =  360},	--云英染（下装）
	[9134] = {["EnchantID"] =  361},	--云锡染（腰带）
	[9136] = {["EnchantID"] =  362},	--青龙绣（上装）
	[9138] = {["EnchantID"] =  363},	--青龙绣（护手）
	[9140] = {["EnchantID"] =  364},	--白虎绣（上装）
	[9142] = {["EnchantID"] =  365},	--白虎绣（护手）
	[9144] = {["EnchantID"] =  366},	--朱雀绣（上装）
	[9146] = {["EnchantID"] =  367},	--朱雀绣（护手）
	[9148] = {["EnchantID"] =  368},	--鬼虎绣（上装）
	[9150] = {["EnchantID"] =  369},	--鬼虎绣（护手）
	[9152] = {["EnchantID"] =  370},	--青龙染（下装）
	[9154] = {["EnchantID"] =  371},	--青龙染（腰带）
	[9156] = {["EnchantID"] =  372},	--白虎染（下装）
	[9158] = {["EnchantID"] =  373},	--白虎染（腰带）
	[9160] = {["EnchantID"] =  374},	--朱雀染（下装）
	[9162] = {["EnchantID"] =  375},	--朱雀染（腰带）
	[9164] = {["EnchantID"] =  376},	--鬼虎染（下装）
	[9166] = {["EnchantID"] =  377},	--鬼虎染（腰带）
	[7983] = {["EnchantID"] =  378},	--流纹磨石
	[7984] = {["EnchantID"] =  379},	--角砾磨石
	[7985] = {["EnchantID"] =  380},	--玄武磨石
	[7986] = {["EnchantID"] =  381},	--花岗磨石
	[7987] = {["EnchantID"] =  382},	--晶凝磨石
	[7988] = {["EnchantID"] =  383},	--云英磨石
	[7989] = {["EnchantID"] =  384},	--云锡磨石
	[7990] = {["EnchantID"] =  385},	--灵璧磨石
	[9619] = {["EnchantID"] =  386},	--岐黄甲片（头部）
	[9620] = {["EnchantID"] =  387},	--岐黄甲片（鞋子）
	[9621] = {["EnchantID"] =  388},	--流纹甲片（头部）
	[9622] = {["EnchantID"] =  389},	--流纹甲片（鞋子）
	[9623] = {["EnchantID"] =  390},	--角砾甲片（头部）
	[9624] = {["EnchantID"] =  391},	--角砾甲片（鞋子）
	[9626] = {["EnchantID"] =  392},	--益元甲片（头部）
	[9625] = {["EnchantID"] =  393},	--益元甲片（鞋子）
	[9627] = {["EnchantID"] =  394},	--云锡甲片（头部）
	[9628] = {["EnchantID"] =  395},	--云英甲片（鞋子）
	[9630] = {["EnchantID"] =  396},	--雨花磨石
	[9632] = {["EnchantID"] =  397},	--黑曜磨石
	[9634] = {["EnchantID"] =  398},	--燕勒磨石
	[9636] = {["EnchantID"] =  399},	--磷灰磨石
	[9638] = {["EnchantID"] =  400},	--片麻磨石
	[9640] = {["EnchantID"] =  401},	--田黄磨石
	[9642] = {["EnchantID"] =  402},	--黑曜甲片（头部）
	[9644] = {["EnchantID"] =  403},	--黑曜甲片（鞋子）
	[9646] = {["EnchantID"] =  404},	--雨花甲片（头部）
	[9648] = {["EnchantID"] =  405},	--雨花甲片（鞋子）
	[9650] = {["EnchantID"] =  406},	--田黄甲片（头部）
	[9652] = {["EnchantID"] =  407},	--田黄甲片（鞋子）
	[9654] = {["EnchantID"] =  408},	--云英甲片（头部）
	[9656] = {["EnchantID"] =  409},	--云锡甲片（鞋子）
	[9657] = {["EnchantID"] =  410},	--瀑沙熔锭
	[9658] = {["EnchantID"] =  411},	--坠宵熔锭
	[9659] = {["EnchantID"] =  412},	--絮泊熔锭
	[9660] = {["EnchantID"] =  413},	--巨灵熔锭
	[9662] = {["EnchantID"] =  414},	--青龙磨石
	[9664] = {["EnchantID"] =  415},	--白虎磨石
	[9666] = {["EnchantID"] =  416},	--燧棱磨石
	[9668] = {["EnchantID"] =  417},	--天罡磨石
	[9670] = {["EnchantID"] =  418},	--辉玉磨石
	[9672] = {["EnchantID"] =  419},	--朱雀磨石
	[2691] = {["EnchantID"] =  420},	--龙血磨石
	[9792] = {["EnchantID"] =  421},	--鬼虎磨石
	[9674] = {["EnchantID"] =  422},	--青龙甲片（头部）
	[9676] = {["EnchantID"] =  423},	--青龙甲片（鞋子）
	[9678] = {["EnchantID"] =  424},	--白虎甲片（头部）
	[9680] = {["EnchantID"] =  425},	--白虎甲片（鞋子）
	[9682] = {["EnchantID"] =  426},	--朱雀甲片（头部）
	[9684] = {["EnchantID"] =  427},	--朱雀甲片（鞋子）
	[9686] = {["EnchantID"] =  428},	--鬼虎甲片（头部）
	[9688] = {["EnchantID"] =  429},	--鬼虎甲片（鞋子）
	[10784] = {["EnchantID"] =  4691},	--雕纹·玉渊
	[10785] = {["EnchantID"] =  4692},	--雕纹·铃琅
	[10786] = {["EnchantID"] =  4693},	--雕纹·梦泽
	[10787] = {["EnchantID"] =  4694},	--雕纹·展凤
	[11672] = {["EnchantID"] =  5127},	--辰龙·馈岁
	[11673] = {["EnchantID"] =  5128},	--辰龙·别岁
	[11674] = {["EnchantID"] =  5129},	--辰龙·守岁
	[11675] = {["EnchantID"] =  5130},	--辰龙·分岁
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
	
	-------------------------以下是巴蜀风云的配方------------------------	
	--烹饪
	[9795] = {["dwCraftID"] = 4	,["dwRecipeID"] =	143},	--配方：炝炒肉排
	[9796] = {["dwCraftID"] = 4	,["dwRecipeID"] =	144},	--配方：藤椒农家肉
	[9797] = {["dwCraftID"] = 4	,["dwRecipeID"] =	145},	--配方：顿酥肉
	[9798] = {["dwCraftID"] = 4	,["dwRecipeID"] =	146},	--配方：荞面包子
	[9799] = {["dwCraftID"] = 4	,["dwRecipeID"] =	147},	--配方：红烧掌中宝
	[9800] = {["dwCraftID"] = 4	,["dwRecipeID"] =	148},	--配方：双椒猪耳
	[9801] = {["dwCraftID"] = 4	,["dwRecipeID"] =	149},	--配方：焦糖软骨
	[9802] = {["dwCraftID"] = 4	,["dwRecipeID"] =	150},	--配方：东坡肘子
	[9803] = {["dwCraftID"] = 4	,["dwRecipeID"] =	151},	--配方：剁椒肉爪
	[9804] = {["dwCraftID"] = 4	,["dwRecipeID"] =	152},	--配方：椒麻口条
	[9805] = {["dwCraftID"] = 4	,["dwRecipeID"] =	153},	--配方：小炒肉
	[9806] = {["dwCraftID"] = 4	,["dwRecipeID"] =	154},	--配方：酱腌鸡爪
	[9807] = {["dwCraftID"] = 4	,["dwRecipeID"] =	155},	--配方：酥脆软骨
	[9808] = {["dwCraftID"] = 4	,["dwRecipeID"] =	156},	--配方：扒松肉
	[9809] = {["dwCraftID"] = 4	,["dwRecipeID"] =	157},	--配方：蒜香凤爪
	[9810] = {["dwCraftID"] = 4	,["dwRecipeID"] =	158},	--配方：青椒脆骨
	[9811] = {["dwCraftID"] = 4	,["dwRecipeID"] =	159},	--配方：玉笛谁家听落梅
	[9812] = {["dwCraftID"] = 4	,["dwRecipeID"] =	160},	--配方：二十四桥明月夜
	[9813] = {["dwCraftID"] = 4	,["dwRecipeID"] =	161},	--配方：鸳鸯烩珍宴
	[9814] = {["dwCraftID"] = 4	,["dwRecipeID"] =	167},	--配方：蜀味烘焙宴
	[9816] = {["dwCraftID"] = 4	,["dwRecipeID"] =	163},	--配方：熏烤蹄髈
	[9817] = {["dwCraftID"] = 4	,["dwRecipeID"] =	164},	--配方：碳烤软骨
	[9818] = {["dwCraftID"] = 4	,["dwRecipeID"] =	165},	--配方：焦炙肉扒
	[9819] = {["dwCraftID"] = 4	,["dwRecipeID"] =	166},	--配方：过桥米线
	[9841] = {["dwCraftID"] = 4	,["dwRecipeID"] =	168},	--配方：汇珍宴
	[10275] = {["dwCraftID"] = 4 ,["dwRecipeID"] =	169},	--食谱：爆椒扒肉
	[10277] = {["dwCraftID"] = 4 ,["dwRecipeID"] =	170},	--食谱：笑忘筋
	[10278] = {["dwCraftID"] = 4 ,["dwRecipeID"] =	171},	--食谱：霸王餐
	[10279] = {["dwCraftID"] = 4 ,["dwRecipeID"] =	172},	--食谱：龙虎豆
	[10280] = {["dwCraftID"] = 4 ,["dwRecipeID"] =	173},	--食谱：六筋炖
	[10281] = {["dwCraftID"] = 4 ,["dwRecipeID"] =	174},	--食谱：酱腐骨
	--缝纫
	[8924] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	535},	--天工图：立乾上衣
	[8995] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	592},	--天工图：立乾护腕
	[8997] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	593},	--天工图：破天上衣
	[9000] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	595},	--天工图：破天护腕
	[9002] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	596},	--天工图：愈坎上衣
	[9005] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	598},	--天工图：愈坎护腕
	[9007] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	599},	--天工图：芷水上衣
	[9010] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	601},	--天工图：芷水护腕
	[9012] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	602},	--天工图：飓元上衣
	[9015] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	604},	--天工图：飓元护腕
	[9017] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	605},	--天工图：残风上衣
	[9020] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	607},	--天工图：残风护腕
	[9022] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	608},	--天工图：恩泽上衣
	[9025] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	610},	--天工图：恩泽护腕
	[9027] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	611},	--天工图：浊兑上衣
	[9030] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	613},	--天工图：浊兑护腕
	[9035] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	615},	--天工图：霸蜀·立乾下装
	[9039] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	617},	--天工图：霸蜀·立乾腰带
	[9041] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	618},	--天工图：镇蜀·破天下装
	[9045] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	620},	--天工图：镇蜀·破天腰带
	[9047] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	621},	--天工图：净蜀·愈坎下装
	[9051] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	623},	--天工图：净蜀·愈坎腰带
	[9053] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	624},	--天工图：镇蜀·芷水下装
	[9057] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	626},	--天工图：镇蜀·芷水腰带
	[9059] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	627},	--天工图：净蜀·飓元下装
	[9063] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	629},	--天工图：净蜀·飓元腰带
	[9065] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	630},	--天工图：镇蜀·残风下装
	[9069] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	632},	--天工图：镇蜀·残风腰带
	[9071] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	633},	--天工图：净蜀·恩泽下装
	[9075] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	635},	--天工图：净蜀·恩泽腰带
	[9077] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	636},	--天工图：镇蜀·浊兑下装
	[9081] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	638},	--天工图：镇蜀·浊兑腰带
	[9102] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	659},	--黑曜绣秘方：上装
	[9105] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	660},	--黑曜绣秘方：护手
	[9107] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	661},	--雨花绣秘方：上装
	[9109] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	662},	--雨花绣秘方：护手
	[9111] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	663},	--田黄绣秘方：上装
	[9113] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	664},	--田黄绣秘方：护手
	[9115] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	665},	--云英绣秘方：上装
	[9117] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	666},	--云锡绣秘方：护手
	[9119] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	667},	--黑曜染秘方：下装
	[9121] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	668},	--黑曜染秘方：腰带
	[9123] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	669},	--雨花染秘方：下装
	[9125] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	670},	--雨花染秘方：腰带
	[9127] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	671},	--田黄染秘方：下装
	[9129] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	672},	--田黄染秘方：腰带
	[9131] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	673},	--云英染秘方：下装
	[9133] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	674},	--云锡染秘方：腰带
	[9135] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	675},	--青龙天工绣：上装
	[9137] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	676},	--青龙天工绣：护手
	[9139] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	677},	--白虎天工绣：上装
	[9141] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	678},	--白虎天工绣：护手
	[9143] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	679},	--朱雀天工绣：上装
	[9145] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	680},	--朱雀天工绣：护手
	[9147] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	681},	--鬼虎天工绣：上装
	[9149] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	682},	--鬼虎天工绣：护手
	[9151] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	683},	--青龙天工染：下装
	[9153] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	684},	--青龙天工染：腰带
	[9155] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	685},	--白虎天工染：下装
	[9157] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	686},	--白虎天工染：腰带
	[9159] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	687},	--朱雀天工染：下装
	[9161] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	688},	--朱雀天工染：腰带
	[9163] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	689},	--鬼虎天工染：下装
	[9165] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	690},	--鬼虎天工染：腰带
	[10180] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	647},	--云锡绣秘方：上装
	[10181] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	648},	--云英绣秘方：护手
	[10182] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	657},	--云锡染秘方：下装
	[10183] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	658},	--云英染秘方：腰带
	--铸造
	[9481] = {["dwCraftID"] = 6	,["dwRecipeID"] =	374},	--天工图：御坤铠甲
	[9484] = {["dwCraftID"] = 6	,["dwRecipeID"] =	376},	--天工图：御坤护手
	[9486] = {["dwCraftID"] = 6	,["dwRecipeID"] =	377},	--天工图：碎地铠甲
	[9489] = {["dwCraftID"] = 6	,["dwRecipeID"] =	379},	--天工图：碎地护手
	[9491] = {["dwCraftID"] = 6	,["dwRecipeID"] =	380},	--天工图：降震铠甲
	[9494] = {["dwCraftID"] = 6	,["dwRecipeID"] =	382},	--天工图：降震护手
	[9496] = {["dwCraftID"] = 6	,["dwRecipeID"] =	383},	--天工图：续雷铠甲
	[9499] = {["dwCraftID"] = 6	,["dwRecipeID"] =	385},	--天工图：续雷护手
	[9501] = {["dwCraftID"] = 6	,["dwRecipeID"] =	386},	--天工图：拂岳铠甲
	[9504] = {["dwCraftID"] = 6	,["dwRecipeID"] =	388},	--天工图：拂岳护手
	[9507] = {["dwCraftID"] = 6	,["dwRecipeID"] =	390},	--天工图：卫蜀·御坤护腿
	[9510] = {["dwCraftID"] = 6	,["dwRecipeID"] =	392},	--天工图：卫蜀·御坤腰带
	[9512] = {["dwCraftID"] = 6	,["dwRecipeID"] =	393},	--天工图：霸蜀·碎地护腿
	[9515] = {["dwCraftID"] = 6	,["dwRecipeID"] =	395},	--天工图：霸蜀·碎地腰带
	[9517] = {["dwCraftID"] = 6	,["dwRecipeID"] =	396},	--天工图：卫蜀·降震护腿
	[9520] = {["dwCraftID"] = 6	,["dwRecipeID"] =	398},	--天工图：卫蜀·降震腰带
	[9522] = {["dwCraftID"] = 6	,["dwRecipeID"] =	399},	--天工图：霸蜀·续雷护腿
	[9525] = {["dwCraftID"] = 6	,["dwRecipeID"] =	401},	--天工图：霸蜀·续雷腰带
	[9527] = {["dwCraftID"] = 6	,["dwRecipeID"] =	402},	--天工图：霸蜀·拂岳护腿
	[9530] = {["dwCraftID"] = 6	,["dwRecipeID"] =	404},	--天工图：霸蜀·拂岳腰带
	[9629] = {["dwCraftID"] = 6	,["dwRecipeID"] =	423},	--天工图：雨花磨石
	[9631] = {["dwCraftID"] = 6	,["dwRecipeID"] =	424},	--天工图：黑曜磨石
	[9633] = {["dwCraftID"] = 6	,["dwRecipeID"] =	425},	--天工图：燕勒磨石
	[9635] = {["dwCraftID"] = 6	,["dwRecipeID"] =	426},	--天工图：磷灰磨石
	[9637] = {["dwCraftID"] = 6	,["dwRecipeID"] =	427},	--天工图：片麻磨石
	[10245] = {["dwCraftID"] = 6	,["dwRecipeID"] =	428},	--天工图：田黄磨石
	[9641] = {["dwCraftID"] = 6	,["dwRecipeID"] =	429},	--黑曜甲片秘方：头部
	[9643] = {["dwCraftID"] = 6	,["dwRecipeID"] =	430},	--黑曜甲片秘方：鞋子
	[9645] = {["dwCraftID"] = 6	,["dwRecipeID"] =	431},	--雨花甲片秘方：头部
	[9647] = {["dwCraftID"] = 6	,["dwRecipeID"] =	432},	--雨花甲片秘方：鞋子
	[9649] = {["dwCraftID"] = 6	,["dwRecipeID"] =	433},	--田黄甲片秘方：头部
	[9651] = {["dwCraftID"] = 6	,["dwRecipeID"] =	434},	--田黄甲片秘方：鞋子
	[9653] = {["dwCraftID"] = 6	,["dwRecipeID"] =	435},	--云英甲片秘方：头部
	[9655] = {["dwCraftID"] = 6	,["dwRecipeID"] =	436},	--云锡甲片秘方：鞋子
	[9661] = {["dwCraftID"] = 6	,["dwRecipeID"] =	441},	--天工图：青龙磨石
	[9663] = {["dwCraftID"] = 6	,["dwRecipeID"] =	442},	--天工图：白虎磨石
	[9665] = {["dwCraftID"] = 6	,["dwRecipeID"] =	443},	--天工图：燧棱磨石
	[9667] = {["dwCraftID"] = 6	,["dwRecipeID"] =	444},	--天工图：天罡磨石
	[9669] = {["dwCraftID"] = 6	,["dwRecipeID"] =	445},	--天工图：辉玉磨石
	[9671] = {["dwCraftID"] = 6	,["dwRecipeID"] =	446},	--天工图：朱雀磨石
	[2573] = {["dwCraftID"] = 6	,["dwRecipeID"] =	447},	--天工图：龙血磨石
	[9788] = {["dwCraftID"] = 6	,["dwRecipeID"] =	448},	--天工图：鬼虎磨石
	[9673] = {["dwCraftID"] = 6	,["dwRecipeID"] =	449},	--青龙甲片秘方：头部
	[9675] = {["dwCraftID"] = 6	,["dwRecipeID"] =	450},	--青龙甲片秘方：鞋子
	[9677] = {["dwCraftID"] = 6	,["dwRecipeID"] =	451},	--白虎甲片秘方：头部
	[9679] = {["dwCraftID"] = 6	,["dwRecipeID"] =	452},	--白虎甲片秘方：鞋子
	[9681] = {["dwCraftID"] = 6	,["dwRecipeID"] =	453},	--朱雀甲片秘方：头部
	[9683] = {["dwCraftID"] = 6	,["dwRecipeID"] =	454},	--朱雀甲片秘方：鞋子
	[9685] = {["dwCraftID"] = 6	,["dwRecipeID"] =	455},	--鬼虎甲片秘方：头部
	[9687] = {["dwCraftID"] = 6	,["dwRecipeID"] =	456},	--鬼虎甲片秘方：鞋子
	[10179] = {["dwCraftID"] = 6 ,["dwRecipeID"] =	421},	--云锡甲片秘方：头部
	[10174] = {["dwCraftID"] = 6 ,["dwRecipeID"] =	422},	--云英甲片秘方：鞋子
  	--医术
	[9709] = {["dwCraftID"] = 7	,["dwRecipeID"] =	159},	--配方：素针·封
	[9711] = {["dwCraftID"] = 7	,["dwRecipeID"] =	160},	--配方：素针·锢
	[9713] = {["dwCraftID"] = 7	,["dwRecipeID"] =	161},	--配方：素针·水
	[9715] = {["dwCraftID"] = 7	,["dwRecipeID"] =	162},	--配方：素针·火
	[9717] = {["dwCraftID"] = 7	,["dwRecipeID"] =	163},	--配方：素针·土
	[9719] = {["dwCraftID"] = 7	,["dwRecipeID"] =	164},	--药方：上品定痛丸
	[9721] = {["dwCraftID"] = 7	,["dwRecipeID"] =	165},	--药方：上品金创丸
	[9723] = {["dwCraftID"] = 7	,["dwRecipeID"] =	166},	--药方：中品金元丹
	[9725] = {["dwCraftID"] = 7	,["dwRecipeID"] =	167},	--药方：中品玄阴丹
	[9727] = {["dwCraftID"] = 7	,["dwRecipeID"] =	192},	--药方：中品调和散
	[9729] = {["dwCraftID"] = 7	,["dwRecipeID"] =	169},	--药方：上品玉露散
	[9731] = {["dwCraftID"] = 7	,["dwRecipeID"] =	170},	--药方：中品万花丹
	[9733] = {["dwCraftID"] = 7	,["dwRecipeID"] =	171},	--配方：素针·破
	[9735] = {["dwCraftID"] = 7	,["dwRecipeID"] =	172},	--配方：素针·禁
	[9737] = {["dwCraftID"] = 7	,["dwRecipeID"] =	173},	--药方：中品止血丹
	[9739] = {["dwCraftID"] = 7	,["dwRecipeID"] =	174},	--药方：中品活络丹
	[9741] = {["dwCraftID"] = 7	,["dwRecipeID"] =	175},	--药方：中品凝神丹
	[9743] = {["dwCraftID"] = 7	,["dwRecipeID"] =	176},	--药方：中品长生丹
	[9745] = {["dwCraftID"] = 7	,["dwRecipeID"] =	177},	--药方：中品护心丹
	[9747] = {["dwCraftID"] = 7	,["dwRecipeID"] =	178},	--药方：中品静心丸
	[9749] = {["dwCraftID"] = 7	,["dwRecipeID"] =	179},	--药方：中品补筋丹
	[9751] = {["dwCraftID"] = 7	,["dwRecipeID"] =	180},	--药方：中品破秽丹
	[9753] = {["dwCraftID"] = 7	,["dwRecipeID"] =	181},	--药方：中品聚魂丹
	[9755] = {["dwCraftID"] = 7	,["dwRecipeID"] =	182},	--药方：中品亢龙丹
	[9757] = {["dwCraftID"] = 7	,["dwRecipeID"] =	183},	--药方：中品强身丹
	[9793] = {["dwCraftID"] = 7	,["dwRecipeID"] =	184},	--药方：中品活络止血丹
	[9760] = {["dwCraftID"] = 7	,["dwRecipeID"] =	185},	--药方：中品健骨丹
	[9762] = {["dwCraftID"] = 7	,["dwRecipeID"] =	186},	--药方：中品展凤丹
	[9764] = {["dwCraftID"] = 7	,["dwRecipeID"] =	187},	--药方：中品聚元丹
	[9766] = {["dwCraftID"] = 7	,["dwRecipeID"] =	188},	--药方：中品聚神丹
	[9768] = {["dwCraftID"] = 7	,["dwRecipeID"] =	189},	--配方：素针·定
	[9770] = {["dwCraftID"] = 7	,["dwRecipeID"] =	190},	--配方：素针·缓
	[9843] = {["dwCraftID"] = 7	,["dwRecipeID"] =	191},	--药房：中品罡阳散 
	[10287] = {["dwCraftID"] = 7 ,["dwRecipeID"] =	194},	--秘方：般若水
	[10288] = {["dwCraftID"] = 7 ,["dwRecipeID"] =	195},	--秘方：意气水
	[10289] = {["dwCraftID"] = 7 ,["dwRecipeID"] =	196},	--秘方：重黎水
	[10290] = {["dwCraftID"] = 7 ,["dwRecipeID"] =	197},	--秘方：逸隐水
	[10291] = {["dwCraftID"] = 7 ,["dwRecipeID"] =	198},	--秘方：赤炼水  
	[10310] = {["dwCraftID"] = 7 ,["dwRecipeID"] =	199},	--药方：易功丸  
	
	--------------------------------------一代宗师---------------------------------------
	-->缝纫
	[10273] = {["dwCraftID"] = 5 ,["dwRecipeID"] =	694},	--天工图：蜀染布包

	-->铸造
	[11058] = {["dwCraftID"] = 6 ,["dwRecipeID"] =	463},	--天工图：曼变护手
	[11057] = {["dwCraftID"] = 6 ,["dwRecipeID"] =	461},	--天工图：曼变铠甲
	[11060] = {["dwCraftID"] = 6 ,["dwRecipeID"] =	466},	--天工图：浮灭护手
	[11059] = {["dwCraftID"] = 6 ,["dwRecipeID"] =	464},	--天工图：浮灭铠甲	
	[11061] = {["dwCraftID"] = 6 ,["dwRecipeID"] =	467},	--天工图：霸蜀·曼变护腿
	[11062] = {["dwCraftID"] = 6 ,["dwRecipeID"] =	471},	--天工图：霸蜀·曼变腰带
	[11063] = {["dwCraftID"] = 6 ,["dwRecipeID"] =	468},	--天工图：镇蜀·浮灭护腿
	[11064] = {["dwCraftID"] = 6 ,["dwRecipeID"] =	472},	--天工图：镇蜀·浮灭腰带	 		    	
     	
}

local function TongArenaCondition_0()
	local nBuffID = 791 -- 帮会擂台 进行中bu
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
	Upper = 32,			-- >=Upper 使用最低帧间隔
	BaseFrame = 1,	-- 基准帧
	Expire = 4,			-- 稳定帧浮动判断
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
	
	if fps >= tPlayerSyncFrameData.Upper then	-- 默认最快级别
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