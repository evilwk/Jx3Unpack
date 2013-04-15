QuestAcceptPanel = {}

function QuestAcceptPanel.OnFrameCreate()
	this:RegisterEvent("QUEST_SHARED")
	this:RegisterEvent("QUEST_FINISHED")
	this:RegisterEvent("QUEST_ACCEPTED")
	this:RegisterEvent("UI_SCALED")
	
	this:Lookup("", "").bTotal = true
	
	InitFrameAutoPosInfo(this, 1, "Dialog", nil, function() CloseQuestAcceptPanel(true) end)
end

function QuestAcceptPanel.OnFrameBreathe()
	local player = GetClientPlayer()
	if not player or player.nMoveState == MOVE_STATE.ON_DEATH then
		CloseQuestAcceptPanel()
		return
	end
	if this:IsVisible() then
		if this.dwTargetType then
		    if this.dwTargetType == TARGET.NPC then
				local npc = GetNpc(this.dwTargetId)
				if not npc or not npc.CanDialog(player) then
					CloseQuestAcceptPanel()
				end
		    elseif this.dwTargetType == TARGET.DOODAD then
				local doodad = GetDoodad(this.dwTargetId)
				if not doodad or not doodad.CanDialog(player) then
					CloseQuestAcceptPanel()
				end
		    end
		end
	end
	
	local dwTime = GetTickCount()
	
	if this.bWait then
		if dwTime - this.dwLastTime >= this.dwWaitTime then
			QuestAcceptPanel.FillContent(this)
		end
	end
	
	this.nTraceTime = this.nTraceTime or dwTime
	if dwTime - this.nTraceTime >= 1000 then --每秒跟新一次追踪内容
		local hInfo = this:Lookup("", "Handle_Message")
		local questTrace = player.GetQuestTraceInfo(this.dwQuestId)
		local tQuestStringInfo = Table_GetQuestStringInfo(this.dwQuestId)
		QuestAcceptPanel.UpdateTrace(hInfo, questTrace, tQuestStringInfo)
		this.nTraceTime = dwTime
	end
end

function QuestAcceptPanel.OnEvent(event)
	if event == "QUEST_SHARED" then
		OpenQuestAcceptPanel(arg1, 1, TARGET.PLAYER, arg0, false)
	elseif event == "QUEST_FINISHED" then
		local questInfo = GetQuestInfo(arg0)
		if questInfo then
			if questInfo.dwSubsequenceID ~= 0  then
				local player = GetClientPlayer()
			   	local eCanAccept = player.CanAcceptQuest(questInfo.dwSubsequenceID, this.dwTargetType, this.dwTargetId)	    	
			   	if eCanAccept == QUEST_RESULT.SUCCESS then
		   			OpenQuestAcceptPanel(questInfo.dwSubsequenceID, 1, this.dwTargetType, this.dwTargetId, false, this.aQuest)
		   			return
		   		end
			end
		end
		QuestAcceptPanel.OpenNextQuest(this)		
	elseif event == "QUEST_ACCEPTED" then
		QuestAcceptPanel.OpenNextQuest(this)
	elseif event == "UI_SCALED" then
		QuestAcceptPanel.UpdateScrollInfo(this:Lookup("", "Handle_Message"))
	end
end

function QuestAcceptPanel.OpenNextQuest(frame)
	local aQuest = frame.aQuest or {}
	local player = GetClientPlayer()
	for i, dwQuestId in pairs(aQuest) do
	   	local nState = player.CanFinishQuest(dwQuestId, frame.dwTargetType, frame.dwTargetId)	    	
	   	if nState == QUEST_RESULT.SUCCESS then
   			OpenQuestAcceptPanel(dwQuestId, 2, frame.dwTargetType, frame.dwTargetId, false, frame.aQuest)
   			return
   		end

	   	nState = player.CanAcceptQuest(dwQuestId, frame.dwTargetType, frame.dwTargetId)	    	
	   	if nState == QUEST_RESULT.SUCCESS then
   			OpenQuestAcceptPanel(dwQuestId, 1, frame.dwTargetType, frame.dwTargetId, false, frame.aQuest)
   			return
   		end
	end
end

function QuestAcceptPanel.EncodeString(handle, szInfo, nFont, hPlayer)
	local _, aInfo = GWTextEncoder_Encode(szInfo)	
	if not aInfo then
		return
	end
	
	if not hPlayer then
		hPlayer = GetClientPlayer()
	end
	
	local szText = ""
	for  k, v in pairs(aInfo) do
		if v.name == "text" then --普通文本
			szText = szText.."<text>text="..EncodeComponentsString(v.context).."font="..nFont.."</text>"
        elseif v.name == "N" then	--自己的名字
        	szText = szText.."<text>text="..EncodeComponentsString(hPlayer.szName).."font="..nFont.."</text>"
        elseif v.name == "C" then	--自己的体型对应的称呼
        	szText = szText.."<text>text="..EncodeComponentsString(g_tStrings.tRoleTypeToName[hPlayer.nRoleType]).."font="..nFont.."</text>"
		elseif v.name == "F" then	--字体
			szText = szText.."<text>text="..EncodeComponentsString(v.attribute.text).."font="..v.attribute.fontid.."</text>"
		elseif v.name == "T" then	--图片
			szText = szText.."<image>path=\"fromiconid\" frame="..v.attribute.picid.."</image>"
		elseif v.name == "A" then	--动画
		elseif v.name == "H" then	--控制行高，如果高度大于当前行高，调整为这个高度，否则，不变
			szText = szText.."<null>h="..v.attribute.height.."</null>"
		elseif v.name == "G" then	--4个英文空格
			local szSpace = g_tStrings.STR_TWO_CHINESE_SPACE
			if v.attribute.english then
				szSpace = "    "
			end
			szText = szText.."<text>text=\""..szSpace.."\" font="..nFont.."</text>"
		elseif v.name == "J" then	--金钱
			local nM = tonumber(v.attribute.money)
			local nF = nFont
			if v.attribute.compare then
				if nM > hPlayer.GetMoney() then
					nF = 166
				end
			end
			szText = szText..GetMoneyText(nM, "font="..nF)
		elseif v.name == "AT" then --动作
		elseif v.name == "SD" then --声音
		elseif v.name == "WT" then --延迟			
		else --错误的解析，还原文本
			if v.context then
				szText = szText.."<text>text="..EncodeComponentsString("<"..v.context..">").."font="..nFont.."</text>"
			end
		end
	end
	handle:AppendItemFromString(szText)
end

function QuestAcceptPanel.GetPureText(szInfo, bIgnorFirstSpace)
	local _, aInfo = GWTextEncoder_Encode(szInfo)	
	if not aInfo then
		return ""
	end
	
	local szText = ""
	for  k, v in pairs(aInfo) do
		if v.name == "text" then --普通文本
			szText = szText..v.context
        elseif v.name == "N" then	--自己的名字
        	szText = szText..GetClientPlayer().szName
        elseif v.name == "C" then	--自己的体型对应的称呼
        	szText = szText..g_tStrings.tRoleTypeToName[GetClientPlayer().nRoleType]
		elseif v.name == "F" then	--字体
			szText = szText..v.attribute.text
		elseif v.name == "T" then	--图片
		elseif v.name == "A" then	--动画
		elseif v.name == "H" then	--控制行高，如果高度大于当前行高，调整为这个高度，否则，不变
		elseif v.name == "G" then	--4个英文空格
			if not bIgnorFirstSpace then
				if v.attribute.english then
					szText = szText.."    "
				else
					szText = szText..g_tStrings.STR_TWO_CHINESE_SPACE
				end
				bIgnorFirstSpace = true
			end
		elseif v.name == "J" then	--金钱
			szText = szText..GetMoneyPureText(tonumber(v.attribute.money))
		elseif v.name == "AT" then --动作
		elseif v.name == "SD" then --声音
		elseif v.name == "WT" then --延迟
		else --错误的解析，还原文本
			if v.context then
				szText = szText.."<"..v.context..">"
			end
		end
	end
	return szText
end

function QuestAcceptPanel.UpdateFinishQuest(handle, dwQuestId, questInfo, dwTargetType, dwTargetId)
	local dwTID = nil
	local target = nil
	local tQuestStringInfo = Table_GetQuestStringInfo(dwQuestId)
	if dwTargetType == TARGET.NPC then
		dwTID, target = questInfo.dwEndNpcTemplateID, GetNpc(dwTargetId)
	elseif dwTargetType == TARGET.DOODAD then
		dwTID, target = questInfo.dwEndDoodadTemplateID, GetDoodad(dwTargetId)
	end
	local player = GetClientPlayer()
	local btn = handle:GetRoot():Lookup("Btn_Sure")
	if target.dwTemplateID ~= dwTID then
		QuestAcceptPanel.EncodeString(handle, tQuestStringInfo.szDunningDialogue.."\n\n", 160)
		btn:Hide()
	elseif player.CanFinishQuest(dwQuestId) == QUEST_RESULT.SUCCESS then
		QuestAcceptPanel.EncodeString(handle, tQuestStringInfo.szFinishedDialogue.."\n\n", 160)
		btn:Show()
		btn:Enable(true)
		btn:Lookup("", "Text_Sure"):SetText(g_tStrings.STR_QUEST_FINSISH_QUEST)
		FireHelpEvent("OnCommentFinishQuest", btn)
		QuestAcceptPanel.UpdateHortation(handle, questInfo, true, false)
	else
		QuestAcceptPanel.EncodeString(handle, tQuestStringInfo.szUnfinishedDialogue.."\n\n", 160)
		btn:Show()
		btn:Enable(false)
		btn:Lookup("", "Text_Sure"):SetText(g_tStrings.STR_QUEST_FINSISH_QUEST)
		QuestAcceptPanel.UpdateHortation(handle, questInfo, false, false)
	end
end

function QuestAcceptPanel.UpdateHortation(handle, questInfo, bCanSelect, bIndent, bInTip, bInMiddleMap)
	local h = questInfo.GetHortation()
	if not h then
		return
	end
    
    local hPlayer = GetClientPlayer()
    if not hPlayer then
        return
    end
	
	local nFontT = 1
	if bInTip then
		nFontT = 100
	end
	handle:AppendItemFromString(GetFormatText(g_tStrings.STR_QUEST_QUEST_EARN, nFontT))
	
	nFontT = 160
	if bInTip then
		nFontT = 162
	end	
	if h.money then
		handle:AppendItemFromString(GetFormatText(g_tStrings.STR_QUEST_CAN_GET_MONEY, nFontT))
		handle:AppendItemFromString(GetMoneyTipText(h.money, nFontT).."<text>text=\"\\\n\"</text>")	
	end
    
    if h.exp2money and  h.exp2money > 0 and  hPlayer.nLevel >= 80 then
		handle:AppendItemFromString(GetFormatText(g_tStrings.STR_QUEST_CAN_GET_MORE_MONEY, nFontT))
		handle:AppendItemFromString(GetMoneyTipText(h.exp2money, nFontT).."<text>text=\"\\\n\"</text>")	
	end
	
	if h.presentexamprint then --监本印文
		local szMsg = FormatString(g_tStrings.STR_QUEST_CAN_GET_PRESENTEXAMPRINT, h.presentexamprint)
		szMsg = GetFormatText(szMsg .. " ", nFontT)
		local szImage = GetFormatImage("ui/Image/Common/Money.UITex", 18)
		szMsg = szMsg .. szImage .. GetFormatText("\n")
		handle:AppendItemFromString(szMsg)
	end
	
	if h.presentjustice then --侠义值
		local szMsg = FormatString(g_tStrings.STR_QUEST_CAN_GET_PRESENTJUSTICE, h.presentjustice)
		szMsg = GetFormatText(szMsg .. " ", nFontT)
		local szImage = GetFormatImage("ui/Image/Common/Money.UITex", 25)
		szMsg = szMsg .. szImage .. GetFormatText("\n")
		handle:AppendItemFromString(szMsg)
	end
	
	if h.prestige then -- 威望
		local szMsg = FormatString(g_tStrings.STR_QUEST_CAN_GET_PRESTIGE, h.prestige)
		szMsg = GetFormatText(szMsg .. " ", nFontT)
		local szImage = GetFormatImage("ui/Image/Common/Money.UITex", 22)
		szMsg = szMsg .. szImage .. GetFormatText("\n")
		handle:AppendItemFromString(szMsg)
	end
	
	if questInfo.nTitlePoint and questInfo.nTitlePoint > 0 then --战阶积分
		local szMsg = FormatString(g_tStrings.STR_QUEST_CAN_GET_TITLE_POINT, questInfo.nTitlePoint)
		local szImage = GetFormatImage("ui/Image/Common/Money.UITex", 24)
		szMsg = GetFormatText(szMsg .. " ", nFontT)
		szMsg = szMsg .. szImage .. GetFormatText("\n")
		handle:AppendItemFromString(szMsg)
	end
	
	if h.contribution then--帮贡
		local szMsg = FormatString(g_tStrings.STR_QUEST_CAN_GET_CONTRIBUTION, h.contribution)
		local szImage = GetFormatImage("ui/Image/Common/Money.UITex", 17)
		szMsg = GetFormatText(szMsg .. " ", nFontT)
		szMsg = szMsg .. szImage .. GetFormatText("\n")
		handle:AppendItemFromString(szMsg)
	end
	
	if h.presenttrain then -- 修为
		local szMsg = FormatString(g_tStrings.STR_QUEST_CAN_GET_PRESENTTRAIN, h.presenttrain)
		szMsg = GetFormatText(szMsg .. "\n", nFontT)
		handle:AppendItemFromString(szMsg)
	end
	
	if h.tongdevelopmentpoint then -- 帮会发展点
		local szMsg = FormatString(g_tStrings.STR_QUEST_CAN_GET_DEVELOPMENT_POINT, h.tongdevelopmentpoint)
		szMsg = GetFormatText(szMsg .. "\n", nFontT)
		handle:AppendItemFromString(szMsg)
	end
	
	if h.tongfund then--帮会资金
		handle:AppendItemFromString(GetFormatText(g_tStrings.STR_QUEST_CAN_GET_GUILD_MONEY, nFontT))
		handle:AppendItemFromString(GetMoneyTipText(GoldSilverAndCopperToMoney(h.tongfund, 0,0), nFontT).."<text>text=\"\\\n\"</text>")	
	end
    
    if h.presentarenaaward then --竞技场货币
        local szMsg = FormatString(g_tStrings.STR_QUEST_CAN_GET_PRESENTARENAAWARD, h.presentarenaaward)
		szMsg = GetFormatText(szMsg .. "\n", nFontT)
		handle:AppendItemFromString(szMsg)
    end
	
	if h.reputation then --声望
		handle:AppendItemFromString(GetFormatText(g_tStrings.STR_QUEST_CAN_GET_REPUTATION, nFontT))
		local bFirst = true
		for k, v in pairs(h.reputation) do
			local szText = ""
			if not bFirst then
				szText = g_tStrings.STR_PAUSE
			end
			if v.value >= 0 then
				szText = szText .. g_tReputation.tReputationTable[v.force].szName.."(+"..v.value..")"
			else
				szText = szText .. g_tReputation.tReputationTable[v.force].szName.."("..v.value..")"
			end
			handle:AppendItemFromString(GetFormatText(szText, nFontT))
			bFirst = false
		end
		handle:AppendItemFromString(GetFormatText("\n", nFontT))
	end
    
	
	if h.skill then
		local nSkillID = h.skill
		local nSkillLevel = 1--奖励技能等级默认为1级
		handle:AppendItemFromString("<text>text="..EncodeComponentsString(g_tStrings.STR_QUEST_CAN_GET_SKILL.."\n").."font="..nFontT.."</text>")
 		
 		if bInMiddleMap then
	 		szText = "<handle>firstpostype=0 w=140 h=50 eventID=17<image>w=140 h=50 path=\"UI/Image/QuestPanel/QuestPanelPart.UITex\" frame=13</image>"
 				.."<image>path=\"UI/Image/QuestPanel/QuestPanelPart.UITex\" lockshowhide=1 w=138 h=46 frame=14 x=0 y=2 </image>"
 			   .."<box>w=48 h=48 y=1 eventid=256</box><text>x=52 y=2 w=83 h=46 font=160 valign=1 multiline=1</text></handLe>"--autoetc=1 showall=0 
	 	else
	 		
	 		szText = "<handle>firstpostype=0 w=155 h=50 eventID=17<image>w=155 h=50 path=\"UI/Image/QuestPanel/QuestPanelPart.UITex\" frame=13</image>"
 				.."<image>path=\"UI/Image/QuestPanel/QuestPanelPart.UITex\" lockshowhide=1 w=153 h=46 frame=14 x=0 y=2 </image>"
 			   .."<box>w=48 h=48 y=1 eventid=256</box><text>x=52 y=2 w=98 h=46 font=160 valign=1 multiline=1</text></handLe>"--autoetc=1 showall=0 
	 	end
		handle:AppendItemFromString(szText)
		local hI = handle:Lookup(handle:GetItemCount() - 1)
		
		local box = hI:Lookup(2)
		box:SetObject(UI_OBJECT_SKILL, nSkillID, nSkillLevel)
		box:SetObjectIcon(Table_GetSkillIconID(nSkillID, nSkillLevel))
		box.OnItemMouseEnter = function()
			this:SetObjectMouseOver(1)
			local x, y = this:GetAbsPos()
			local w, h = this:GetSize()
			local dwSkillID, dwSkillLevel = this:GetObjectData()
			OutputSkillTip(dwSkillID, dwSkillLevel, {x, y, w, h}, false, true)
		end
		box.OnItemRefreshTip = box.OnItemMouseEnter
		box.OnItemMouseLeave = function()
			HideTip()
			this:SetObjectMouseOver(0)
		end
		
		hI:Lookup(3):SetText(Table_GetSkillName(nSkillID, nSkillLevel))
		hI.bCanSelect = false
		handle:AppendItemFromString("<text>text="..EncodeComponentsString("\n").."font="..nFontT.."</text>")
	end

	for i = 1, 2, 1 do
		local itemgroup = h["itemgroup"..i]
		if itemgroup then
            local bFirst = true
			local nCount = 1
			
			local nSize = #itemgroup
			for k, v in ipairs(itemgroup) do
		 		local szText = ""
                local ItemInfo = GetItemInfo(v.type, v.index)
                local dwForceID  = hPlayer.GetEffectForceID()
                if not itemgroup.accord2force or v.selectindex == dwForceID - 1 then
                    if bFirst then
                        local szText = g_tStrings.STR_QUEST_ONE_OF_FOLLOW_ENC
                        if itemgroup.all then
                            szText = g_tStrings.STR_QUEST_ALL_OF_FOLLOW_ENC
                        end
                        handle:AppendItemFromString("<text>text="..EncodeComponentsString(szText).."font="..nFontT.."</text>")
                    end
                    bFirst = false
                    if bIndent and (nCount % 2 == 1) then
                        szText = szText.."<null> w=50 h=1 </null>"
                    end		
                    
                    if bInMiddleMap then
                        szText = szText.."<handle>firstpostype=0 w=135 h=50 eventID=17<image>w=140 h=50 path=\"UI/Image/QuestPanel/QuestPanelPart.UITex\" frame=13</image>"
                           .."<box>w=48 h=48 y=1 eventid=256</box><text>x=52 y=2 w=83 h=46 font=160 valign=1 multiline=1 autoetc=1 showall=0 </text>"
                           .."<image>path=\"UI/Image/QuestPanel/QuestPanelPart.UITex\" lockshowhide=1 w=133 h=46 frame=14 x=0 y=2 </image></handLe>" --autoetc=1 showall=0 
                    else
                        szText = szText.."<handle>firstpostype=0 w=155 h=50 eventID=17<image>w=155 h=50 path=\"UI/Image/QuestPanel/QuestPanelPart.UITex\" frame=13</image>"
                           .."<box>w=48 h=48 y=1 eventid=256</box><text>x=52 y=2 w=98 h=46 font=160 valign=1 multiline=1 autoetc=1 showall=0 </text>"
                           .."<image>path=\"UI/Image/QuestPanel/QuestPanelPart.UITex\" lockshowhide=1 w=153 h=46 frame=14 x=0 y=2 </image></handLe>" --autoetc=1 showall=0 
                    end
                    handle:AppendItemFromString(szText)
                    local hI = handle:Lookup(handle:GetItemCount() - 1)
                    hI.OnItemLButtonDown = function()
                        if IsCtrlKeyDown() then
                            local box = hI:Lookup(1)
                            if box then
                                local _, nVersion, dwTabType, dwIndex = box:GetObjectData()
                                if IsGMPanelReceiveItem() then
                                    GMPanel_LinkItemInfo(nVersion, dwTabType, dwIndex)
                                else
                                    EditBox_AppendLinkItemInfo(nVersion, dwTabType, dwIndex, box.count)
                                end
                            end
                        end
                    end
                    
                    local box = hI:Lookup(1)
                    box.count = v.count
                    box:SetObject(UI_OBJECT_ITEM_INFO, ItemInfo.nUiId, v.version, v.type, v.index)
                    box:SetObjectIcon(Table_GetItemIconID(ItemInfo.nUiId))
                    UpdateItemBoxExtend(box, ItemInfo)
                    if v.count ~= 1 and ItemInfo.nGenre ~= ITEM_GENRE.BOOK then
                        box:SetOverTextPosition(0, ITEM_POSITION.RIGHT_BOTTOM)
                        box:SetOverText(0, v.count)
                    end
                    box.OnItemMouseEnter = function()
                        this.bEnter = true
                        this:SetObjectMouseOver(1)
                        local x, y = this:GetAbsPos()
                        local w, h = this:GetSize()
                        local _, nVersion, nTabType, nIndex = this:GetObjectData()
                        OutputItemTip(UI_OBJECT_ITEM_INFO, nVersion, nTabType, nIndex, {x, y, w, h}, nil, nil, nil, nil, this.count)				
                    end
                    box.OnItemRefreshTip = box.OnItemMouseEnter
                    box.OnItemMouseLeave = function()
                        this.bEnter = false
                        HideTip()
                        if not this:GetParent().bSelected then
                            this:SetObjectMouseOver(0)
                        end
                    end
                    
                    hI:Lookup(2):SetText(GetItemNameByItemInfo(ItemInfo, v.count))
                    
                    hI:Lookup(2):SetFontColor(GetItemFontColorByQuality(ItemInfo.nQuality))
                    hI.bCanSelect = bCanSelect
                    if itemgroup.all then
                        hI.bCanSelect = false
                    end
                    if hI.bCanSelect then
                        hI.selectindex = v.selectindex
                        hI.selectgroup = i
    --					if k == 1 then
    --						hI.bSelected = true
    --						hI:Lookup(3):Show()
    --					end
                    end
                    if nCount == nSize or (bIndent and nCount % 2 == 0) or itemgroup.accord2force then
                        handle:AppendItemFromString("<text>text=\"\\\n\"</text>")
                    end
                    nCount = nCount + 1
                end
			end
		end
	end
end

function QuestAcceptPanel.UpdateTrace(hInfo, questTrace, tQuestStringInfo)
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
				local szText, nFont = g_tStrings.STR_TWO_CHINESE_SPACE..szName.."："..v.have.."/"..v.need, 63
				if v.have >= v.need then
					nFont = 1
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
				local szText, nFont = g_tStrings.STR_TWO_CHINESE_SPACE.. szName .."："..v.have.."/"..v.need, 63
				if v.have >= v.need then
					nFont = 1
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
				local nFont = 159
				if v.have >= v.need then
					nFont = 167
				end
				local box = text:Lookup(1)
				box:SetOverTextFontScheme(0, nFont)
				box:SetOverText(0, v.have.."/"..v.need)
			end
		end
	end
	
	hInfo:FormatAllItemPos()
	QuestAcceptPanel.UpdateScrollInfo(hInfo)
end

function QuestAcceptPanel.AppendTrace(hInfo, questTrace, tQuestStringInfo)
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
		local szText, nFont = g_tStrings.STR_TWO_CHINESE_SPACE..szName.."："..v.have.."/"..v.need, 63
		if v.have >= v.need then
			szText, nFont = szText..g_tStrings.STR_QUEST_QUEST_WAS_FINISHED, 1
		end
		hInfo:AppendItemFromString("<text>text="..EncodeComponentsString(szText).."font="..nFont.."</text>")
		local text = hInfo:Lookup(hInfo:GetItemCount() - 1)
		text.bTrace = true
		text.bState = true
		text.i = v.i
		text.k = k
		
		hInfo:AppendItemFromString("<text>text=\"\\\n\"font=0</text>")
	end
	
	for k, v in pairs(questTrace.kill_npc) do
		v.have = math.min(v.have, v.need)
		local szName = Table_GetNpcTemplateName(v.template_id)
		if not szName or szName == "" then
			szName = "Unknown Npc"
		end
		local szText, nFont = g_tStrings.STR_TWO_CHINESE_SPACE.. szName .."："..v.have.."/"..v.need, 63
		if v.have >= v.need then
			szText, nFont = szText..g_tStrings.STR_QUEST_QUEST_WAS_FINISHED, 1
		end
		hInfo:AppendItemFromString("<text>text="..EncodeComponentsString(szText).."font="..nFont.."</text>")
		local text = hInfo:Lookup(hInfo:GetItemCount() - 1)
		text.bTrace = true
		text.bNpc = true
		text.i = v.i
		text.k = k
		
		hInfo:AppendItemFromString("<text>text=\"\\\n\"font=0</text>")		
	end

	for k, v in pairs(questTrace.need_item) do
		local itemInfo = GetItemInfo(v.type, v.index)
		if itemInfo then
			local nBookID = v.need
			if itemInfo.nGenre == ITEM_GENRE.BOOK then
				v.need = 1
			end
			v.have = math.min(v.have, v.need)		
	 		local szText = "<handle>firstpostype=0 w=155 h=50 eventID=17<image>w=155 h=50 path=\"UI/Image/QuestPanel/QuestPanelPart.UITex\" frame=13</image>"
	 			   .."<box>w=48 h=48 y=1 eventid=256</box><text>x=52 y=2 w=98 h=46 font=160 valign=1 multiline=1 autoetc=1 showall=0 </text>"
	 			   .."<image>path=\"UI/Image/QuestPanel/QuestPanelPart.UITex\" lockshowhide=1 w=153 h=46 frame=14 x=0 y=2 </image></handLe>" --autoetc=1 showall=0 
			hInfo:AppendItemFromString(szText)
			local hI = hInfo:Lookup(hInfo:GetItemCount() - 1)
			hI.bTrace = true
			hI.bItem = true
			hI.i = v.i
			hI.k = k
			hI.OnItemLButtonDown = function()
				if IsCtrlKeyDown() then
					local box = hI:Lookup(1)
					if box then
						local _, nVersion, dwTabType, dwIndex = box:GetObjectData()
						if IsGMPanelReceiveItem() then
							GMPanel_LinkItemInfo(nVersion, dwTabType, dwIndex)
						else
							EditBox_AppendLinkItemInfo(nVersion, dwTabType, dwIndex, box.count)
						end
					end
				end
			end
			local box = hI:Lookup(1)
			box.count = nBookID
			box:SetObject(UI_OBJECT_ITEM_INFO, itemInfo.nUiId, GLOBAL.CURRENT_ITEM_VERSION, v.type, v.index)
			box:SetObjectIcon(Table_GetItemIconID(itemInfo.nUiId))
			UpdateItemBoxExtend(box, itemInfo)
			box:SetOverTextPosition(0, ITEM_POSITION.RIGHT_BOTTOM)
			local nFont = 159
			if v.have >= v.need then
				nFont = 167
			end
			box:SetOverTextFontScheme(0, nFont)
			box:SetOverText(0, v.have.."/"..v.need)
			box.OnItemMouseEnter = function()
				this:SetObjectMouseOver(1)
				local x, y = this:GetAbsPos()
				local w, h = this:GetSize()
				local _, nVersion, nTabType, nIndex = this:GetObjectData()
				OutputItemTip(UI_OBJECT_ITEM_INFO, nVersion, nTabType, nIndex, {x, y, w, h}, nil, nil, nil, nil, this.count)				
			end
			box.OnItemRefreshTip = box.OnItemMouseEnter
			box.OnItemMouseLeave = function()
				HideTip()
				this:SetObjectMouseOver(0)
			end
			
			hI:Lookup(2):SetText(GetItemNameByItemInfo(itemInfo, nBookID))
			hI:Lookup(2):SetFontColor(GetItemFontColorByQuality(itemInfo.nQuality))
			
			if k % 2 == 0 or k == #(questTrace.need_item) then
	 			hInfo:AppendItemFromString("<text>text=\"\\\n\"</text>")
	 		end
	 	end
	end
	
	hInfo:AppendItemFromString("<text>text=\"\\\n\"</text>")
end

function QuestAcceptPanel.Update(frame, dwQuestId, dwOperation, dwTargetType, dwTargetId, bCanReturn, aQuest)
	QuestAcceptPanel.ClearCmd(frame)

	frame.dwQuestId = dwQuestId
	frame.dwOperation = dwOperation
	frame.dwTargetType = dwTargetType
	frame.dwTargetId = dwTargetId
	frame.aQuest = aQuest
	
	QuestAcceptPanel.FormatInfo(frame)
	frame.bClear = true
	frame.dwIndex = 1
	QuestAcceptPanel.FillContent(frame)	
	

	local szName = g_tStrings.STR_QUEST
	if dwTargetType == TARGET.PLAYER then
		szName = g_tStrings.STR_SHARE_QUEST
	else
		szName = GetTargetName(dwTargetType, dwTargetId) or g_tStrings.STR_QUEST
	end
	frame:Lookup("", "Text_Title"):SetText(szName)

	local btn = frame:Lookup("Btn_Return")
	btn.bCanReturn = bCanReturn
	if bCanReturn then
		btn:Lookup("", "Text_Return"):SetText(g_tStrings.STR_RETURN)
	else
		btn:Lookup("", "Text_Return"):SetText(g_tStrings.STR_CLOSE)
	end
	
	frame:Lookup("Scroll_Message"):ScrollHome()
	
    frame:Show()
    frame:BringToTop()
end

function QuestAcceptPanel.FormatInfo(frame)
	frame.aInfo = {}
	local questInfo = GetQuestInfo(frame.dwQuestId)
	local tQuestStringInfo = Table_GetQuestStringInfo(frame.dwQuestId)
	table.insert(frame.aInfo, {name = "F", attribute = {text = tQuestStringInfo.szName.."\n", fontid = 1}})
	
	if frame.dwOperation == 1 then	
		local _, aInfo = GWTextEncoder_Encode(tQuestStringInfo.szDescription.."\n\n")
		for k, v in pairs(aInfo) do
			table.insert(frame.aInfo, v)
		end
		table.insert(frame.aInfo, {name = "F", attribute = {text = g_tStrings.STR_QUEST_QUEST_GOAL, fontid = 1}})
		local _, aInfo = GWTextEncoder_Encode(tQuestStringInfo.szObjective.."\n")
		for k, v in pairs(aInfo) do
			table.insert(frame.aInfo, v)
		end
		table.insert(frame.aInfo, {name = "Trace", attribute = {dwQuestId = frame.dwQuestId}})
		table.insert(frame.aInfo, {name = "Hortation", attribute = {dwQuestId = frame.dwQuestId, bCanSelect = false, bIndent = false, bInTip = false}})
	
	    local btn = frame:Lookup("Btn_Sure")
	    btn:Show()
	    btn:Enable(true)
        btn:Lookup("", "Text_Sure"):SetText(g_tStrings.STR_QUEST_ACCEPT_QUEST)
        FireHelpEvent("OnCommentAcceptQuest", btn)      
	else
		local dwTID, target = nil, nil
		if frame.dwTargetType == TARGET.NPC then
			dwTID, target = questInfo.dwEndNpcTemplateID, GetNpc(frame.dwTargetId)
		elseif frame.dwTargetType == TARGET.DOODAD then
			dwTID, target = questInfo.dwEndDoodadTemplateID, GetDoodad(frame.dwTargetId)
		end
		local player = GetClientPlayer()
		local btn = frame:Lookup("Btn_Sure")
		if target.dwTemplateID ~= dwTID then
			local _, aInfo = GWTextEncoder_Encode(tQuestStringInfo.szDunningDialogue.."\n\n")
			for k, v in pairs(aInfo) do
				table.insert(frame.aInfo, v)
			end
			btn:Hide()
		elseif player.CanFinishQuest(frame.dwQuestId) == QUEST_RESULT.SUCCESS then
			local _, aInfo = GWTextEncoder_Encode(tQuestStringInfo.szFinishedDialogue.."\n\n")
			for k, v in pairs(aInfo) do
				table.insert(frame.aInfo, v)
			end
			table.insert(frame.aInfo, {name = "F", attribute = {text = g_tStrings.STR_QUEST_QUEST_GOAL, fontid = 1}})
			local _, aInfo = GWTextEncoder_Encode(tQuestStringInfo.szObjective.."\n")
			for k, v in pairs(aInfo) do
				table.insert(frame.aInfo, v)
			end
			table.insert(frame.aInfo, {name = "Trace", attribute = {dwQuestId = frame.dwQuestId}})
			table.insert(frame.aInfo, {name = "Hortation", attribute = {dwQuestId = frame.dwQuestId, bCanSelect = true, bIndent = false, bInTip = false}})
			btn:Show()
			btn:Enable(true)
			btn:Lookup("", "Text_Sure"):SetText(g_tStrings.STR_QUEST_FINSISH_QUEST)
			FireHelpEvent("OnCommentFinishQuest", btn)
		else
			local _, aInfo = GWTextEncoder_Encode(tQuestStringInfo.szUnfinishedDialogue.."\n\n")
			for k, v in pairs(aInfo) do
				table.insert(frame.aInfo, v)
			end
			table.insert(frame.aInfo, {name = "F", attribute = {text = g_tStrings.STR_QUEST_QUEST_GOAL, fontid = 1}})
			local _, aInfo = GWTextEncoder_Encode(tQuestStringInfo.szObjective.."\n")
			for k, v in pairs(aInfo) do
				table.insert(frame.aInfo, v)
			end	
			table.insert(frame.aInfo, {name = "Trace", attribute = {dwQuestId = frame.dwQuestId}})
			table.insert(frame.aInfo, {name = "Hortation", attribute = {dwQuestId = frame.dwQuestId, bCanSelect = false, bIndent = false, bInTip = false}})
			btn:Show()
			btn:Enable(false)
			btn:Lookup("", "Text_Sure"):SetText(g_tStrings.STR_QUEST_FINSISH_QUEST)
		end
	end
end

function QuestAcceptPanel.FillContent(frame)
	local handle = frame:Lookup("", "Handle_Message")
	if frame.bClear then
		DialoguePanel.InitEditBoxInfo(frame)
		handle:Clear()
		handle:SetItemStartRelPos(0, 0)
	end
	
	frame.bWait = false
	
	local nFont = 160
	local aInfo = frame.aInfo
	local nCount = #aInfo
	frame.dwIndex = frame.dwIndex or 1
	for i = frame.dwIndex, nCount, 1 do
		local v = aInfo[i]
		if v.name == "text" then --普通文本
			handle:AppendItemFromString("<text>text="..EncodeComponentsString(v.context).."font="..nFont.."</text>")
        elseif v.name == "N" then	--自己的名字
        	handle:AppendItemFromString("<text>text="..EncodeComponentsString(GetClientPlayer().szName).."font="..nFont.."</text>")
        elseif v.name == "C" then	--自己的体型对应的称呼
        	handle:AppendItemFromString("<text>text="..EncodeComponentsString(g_tStrings.tRoleTypeToName[GetClientPlayer().nRoleType]).."font="..nFont.."</text>")
		elseif v.name == "F" then	--字体
			handle:AppendItemFromString("<text>text="..EncodeComponentsString(v.attribute.text).."font="..v.attribute.fontid.."</text>")
		elseif v.name == "T" then	--图片
			handle:AppendItemFromString("<image>path=\"fromiconid\" frame="..v.attribute.picid.."</image>")
		elseif v.name == "A" then	--动画
		elseif v.name == "H" then	--控制行高，如果高度大于当前行高，调整为这个高度，否则，不变
			handle:AppendItemFromString("<null>h="..v.attribute.height.."</null>")
		elseif v.name == "G" then	--4个英文空格
			local szSpace = g_tStrings.STR_TWO_CHINESE_SPACE
			if v.attribute.english then
				szSpace = "    "
			end
			handle:AppendItemFromString("<text>text=\""..szSpace.."\" font="..nFont.."</text>")
		elseif v.name == "J" then	--金钱
			local nM = tonumber(v.attribute.money)
			local nF = nFont
			if v.attribute.compare then
				if nM > GetClientPlayer().GetMoney() then
					nF = 166
				end
			end
			handle:AppendItemFromString(GetMoneyText(nM, "font="..nF))
		elseif v.name == "AT" then --动作
			local player = GetClientPlayer()
			if frame.dwTargetType and frame.dwTargetType == TARGET.NPC and frame.dwTargetId and player then
				local bFace = false
				if v.attribute.face then
					bFace = true
				end
				Character_PlayAnimation(frame.dwTargetId, player.dwID, tonumber(v.attribute.actionid), bFace)
			end
		elseif v.name == "SD" then --声音
			local player = GetClientPlayer()
			if frame.dwTargetType and frame.dwTargetType == TARGET.NPC and player then
				Character_PlaySound(frame.dwTargetId, player.dwID, v.attribute.soundid, false)
			end
		elseif v.name == "WT" then --延迟
			if not IsShowDialogOneTime() then
				frame.bWait = true
				frame.dwLastTime = GetTickCount()
				frame.dwWaitTime = tonumber(v.attribute.waittime) * 1000
				frame.bClear = false
--				if v.attribute.clear then  --clear属性在结交任务面板不起作用
--					frame.bClear = true
--				end
				frame.bCannotSkip = false
				if v.attribute.cannotskip then
					frame.bCannotSkip = true
				end
--				frame.bCannotGoBack = false
--				if v.attribute.cannotgoback then
--					frame.bCannotGoBack = true
--				end
				frame.dwIndex = i + 1
				break
			end
		elseif v.name == "Hortation" then
			local questInfo = GetQuestInfo(v.attribute.dwQuestId)
			QuestAcceptPanel.UpdateHortation(handle, questInfo, v.attribute.bCanSelect, v.attribute.bIndent, v.attribute.bInTip)
		elseif v.name == "Trace" then
			local questTrace = GetClientPlayer().GetQuestTraceInfo(v.attribute.dwQuestId)
			local tQuestStringInfo = Table_GetQuestStringInfo(v.attribute.dwQuestId)
			QuestAcceptPanel.AppendTrace(handle, questTrace, tQuestStringInfo)
		else --错误的解析，还原文本
			if v.context then
				handle:AppendItemFromString("<text>text="..EncodeComponentsString("<"..v.context..">").."font="..nFont.."</text>")
			end
		end
	end
	
	if not frame.bWait then
		frame.dwIndex = #aInfo + 1
	end
	
	QuestAcceptPanel.UpdateBtnNext(frame)
	
	handle:FormatAllItemPos()
	QuestAcceptPanel.UpdateScrollInfo(handle)
end

function QuestAcceptPanel.UpdateBtnNext(frame)
	local btn = frame:Lookup("Btn_NextMsg")
	if frame.bWait then
		btn:Show()
		btn:Enable(not frame.bCannotSkip)
	else
		btn:Hide()
	end
end

function QuestAcceptPanel.ClearCmd(frame)
	if frame.dwTargetType and frame.dwTargetType == TARGET.NPC and frame.dwTargetId then
		Character_StopAnimation(frame.dwTargetId)
		Character_StopSound(frame.dwTargetId)
	end
end

function QuestAcceptPanel.UpdateScrollInfo(handleMsg)
	local handle = handleMsg:GetParent()
	local frame = handleMsg:GetRoot()
	local wAll, hAll = handleMsg:GetAllItemSize()
    local w, h = handleMsg:GetSize()
    local scroll = frame:Lookup("Scroll_Message")
    local nCountStep = math.ceil(math.ceil((hAll - h) / 10) * 100)
    scroll:SetStepCount(nCountStep)
    if nCountStep > 0 then
    	scroll:Show()
    	frame:Lookup("Btn_Up"):Show()
    	frame:Lookup("Btn_Down"):Show()
    	handle:Lookup("Image_Decoration2"):Hide()
    	handle:Lookup("Image_MScrollBg"):Show()
    else
    	scroll:Hide()
    	frame:Lookup("Btn_Up"):Hide()
    	frame:Lookup("Btn_Down"):Hide()
    	handle:Lookup("Image_Decoration2"):Show()
    	handle:Lookup("Image_MScrollBg"):Hide()
    end	
end

function QuestAcceptPanel.OnLButtonDown()
	QuestAcceptPanel.OnLButtonHold()
end

function QuestAcceptPanel.OnLButtonHold()
	local szSelfName = this:GetName()
	if szSelfName == "Btn_Up" then
		this:GetRoot():Lookup("Scroll_Message"):ScrollPrev(100)
	elseif szSelfName == "Btn_Down" then
		this:GetRoot():Lookup("Scroll_Message"):ScrollNext(100)	
    end
end

function QuestAcceptPanel.OnLButtonClick()
	local frame = this:GetRoot()
    local szName = this:GetName()
	if szName == "Btn_Sure" then
        local player = GetClientPlayer()
        if frame.dwOperation == 1 then
            player.AcceptQuest(frame.dwTargetType, frame.dwTargetId, frame.dwQuestId)
            PlaySound(SOUND.UI_SOUND, g_sound.Invite)
            CloseQuestAcceptPanel(true)
        else
        	local nSelect1, nSelect2 = 0, 4
        	local handle = frame:Lookup("", "Handle_Message")
        	local nCount = handle:GetItemCount() - 1
        	local bSelect1, bSelect2 = false, false
        	local bHaveSelect1, bHaveSelect2 = false, false
        	for i = 0, nCount, 1 do
        		local hI = handle:Lookup(i)
        		if hI.bCanSelect then
        			if hI.selectgroup == 1 then
        				bSelect1 = true
        				if hI.bSelected then
        					nSelect1 = hI.selectindex
        					bHaveSelect1 = true
        				end
        			else
        				bSelect2 = true
        				if hI.bSelected then
        					nSelect2 = hI.selectindex
        					bHaveSelect2 = true
        				end
        			end
        		end
        	end
        	
        	if (bSelect1 and not bHaveSelect1) or (bSelect2 and not bHaveSelect2) then
        		local xC, yC = Cursor.GetPos()
				local msg = 
				{
					x = xC, y = yC,
					szMessage = g_tStrings.STR_MSG_SELECT_HOR, 
					szName = "SelHortationNotice", 
					fnAutoClose = function() if IsQuestAcceptPanelOpened() then return false end return true end,
					{szOption = g_tStrings.STR_HOTKEY_SURE },
				}
				MessageBox(msg)
        	else
	        	player.FinishQuest(frame.dwQuestId, frame.dwTargetType, frame.dwTargetId, nSelect1, nSelect2)
	        	PlaySound(SOUND.UI_SOUND, g_sound.Complete)        	
	        	CloseQuestAcceptPanel(true)
        	end
        end
	elseif szName == "Btn_Return" then
        CloseQuestAcceptPanel(true)
        if this.bCanReturn then
        	ReturnToDialoguePanel()
        end
    elseif szName == "Btn_NextMsg" then
    	local frame = this:GetRoot()
    	if frame.bWait and not frame.bCannotSkip then
--			QuestAcceptPanel.ClearCmd(frame)
			QuestAcceptPanel.FillContent(frame)
		end
	elseif szName == "Btn_Close" then
        CloseQuestAcceptPanel()
    end
end

function QuestAcceptPanel.OnScrollBarPosChanged()
	local nCurrentValue = this:GetScrollPos()
	local frame = this:GetParent()
	if nCurrentValue == 0 then
		frame:Lookup("Btn_Up"):Enable(false)
	else
		frame:Lookup("Btn_Up"):Enable(true)
	end
	local nTotal = this:GetStepCount()
	if nCurrentValue == nTotal then
		frame:Lookup("Btn_Down"):Enable(false)
	else
		frame:Lookup("Btn_Down"):Enable(true)
	end
	
	if nTotal == 0 then
		frame:Lookup("", "Image_MScrollBg"):SetPercentage(0)
	else
		frame:Lookup("", "Image_MScrollBg"):SetPercentage(nCurrentValue / nTotal)
	end
	
    local handle = frame:Lookup("", "Handle_Message")
    handle:SetItemStartRelPos(0, - math.floor(nCurrentValue / 100) * 10)
end

function QuestAcceptPanel.OnLButtonDown()
	QuestAcceptPanel.OnLButtonHold()
end

function QuestAcceptPanel.OnLButtonHold()
    local szName = this:GetName()
	if szName == "Btn_Up" then
		this:GetParent():Lookup("Scroll_Message"):ScrollPrev(100)
	elseif szName == "Btn_Down" then
		this:GetParent():Lookup("Scroll_Message"):ScrollNext(100)
    end
end

function QuestAcceptPanel.OnItemMouseWheel()
	local nDistance = Station.GetMessageWheelDelta()
	this:GetRoot():Lookup("Scroll_Message"):ScrollNext(nDistance * 100)
	return 1
end

function QuestAcceptPanel.OnItemLButtonClick()
	if this.bTotal then
		local frame = this:GetRoot()
		if frame.bWait and not frame.bCannotSkip then
--			QuestAcceptPanel.ClearCmd(frame)
			QuestAcceptPanel.FillContent(frame)
		end
	elseif this.bCanSelect and not this.bSelected then
		local hP = this:GetParent()
		local nCount = hP:GetItemCount() - 1
		for i = 0, nCount, 1 do
			local hI = hP:Lookup(i)
			if hI.selectgroup then
				if hI.bCanSelect and hI.selectgroup == this.selectgroup then
					hI.bSelected = false
					hI:Lookup(3):Hide()
					local box = hI:Lookup(1)
					if not box.bEnter then
						box:SetObjectMouseOver(0)
					end
				end
			end
		end
		this.bSelected = true
		this:Lookup(3):Show()
		this:Lookup(1):SetObjectMouseOver(1)
	end
end

function QuestAcceptPanel.OnItemMouseEnter()
	if this:GetType() == "Box" then
		local nType = this:GetObjectType()
		if nType == UI_OBJECT_ITEM_INFO then
			this:SetObjectMouseOver(1)
			local x, y = this:GetAbsPos()
			local w, h = this:GetSize()
			local _, nVersion, nTabType, nIndex = this:GetObjectData()
			OutputItemTip(UI_OBJECT_ITEM_INFO, nVersion, nTabType, nIndex, {x, y, w, h}, nil, nil, nil, nil, this.count)
		elseif nType == UI_OBJECT_SKILL then
			this:SetObjectMouseOver(1)
			local x, y = this:GetAbsPos()
			local w, h = this:GetSize()
			local dwSkillID, dwSkillLevel = this:GetObjectData()
			OutputSkillTip(dwSkillID, dwSkillLevel, {x, y, w, h}, false, true)
		end
	end
end

function QuestAcceptPanel.OnItemRefreshTip()
	return QuestAcceptPanel.OnItemMouseEnter()
end

function QuestAcceptPanel.OnItemMouseLeave()
	if this:GetType() == "Box" then
		HideTip()
		this:SetObjectMouseOver(0)
	end
end

function OpenQuestAcceptPanel(dwQuestId, dwOperation, dwTargetType, dwTargetId, bCanReturn, aQuest, bDisableSound)
	local player = GetClientPlayer()
	if not player or player.nMoveState == MOVE_STATE.ON_DEATH then
		return
	end
	
	local frame = Station.Lookup("Normal/QuestAcceptPanel")
	if not frame then
		frame = Wnd.OpenWindow("QuestAcceptPanel")
	end
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
	
	QuestAcceptPanel.Update(frame, dwQuestId, dwOperation, dwTargetType, dwTargetId, bCanReturn, aQuest)	
end

function CloseQuestAcceptPanel(bDisableSound)
	local frame = Station.Lookup("Normal/QuestAcceptPanel")
	if frame then
		frame:Hide()
		QuestAcceptPanel.ClearCmd(frame)
	end
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end
end

function IsQuestAcceptPanelOpened()
	local frame = Station.Lookup("Normal/QuestAcceptPanel")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end
