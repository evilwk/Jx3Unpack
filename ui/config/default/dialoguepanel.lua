DialoguePanel = 
{
	bShowAllOneTime = false,
}
DialoguePanel.tGlobalRanking = {}

function DialoguePanel.OnFrameCreate()
	this:RegisterEvent("OPEN_WINDOW")
	this:RegisterEvent("UI_SCALED")
	
	this:Lookup("", "").bTotal = true
	local btnPrev = this:Lookup("Btn_PrevMsg")
	btnPrev.nX, btnPrev.nY = btnPrev:GetRelPos()
	btnPrev.szText = btnPrev:Lookup("", ""):Lookup(0):GetText()
	
	local btnNext = this:Lookup("Btn_NextMsg")
	btnNext.nX, btnNext.nY = btnNext:GetRelPos()
	btnNext.szText = btnNext:Lookup("", ""):Lookup(0):GetText()
	
	InitFrameAutoPosInfo(this, 1, "Dialog", nil, function() CloseDialoguePanel(true) end)
end

function DialoguePanel.OnFrameBreathe()
	local player = GetClientPlayer()
	if not player or player.nMoveState == MOVE_STATE.ON_DEATH then
		CloseDialoguePanel()
		return
	end
	
	if this.dwTargetType then
	    if this.dwTargetType == TARGET.NPC then
			local npc = GetNpc(this.dwTargetId)
			if not npc or not npc.CanDialog(player) then
				CloseDialoguePanel()
			end
	    elseif this.dwTargetType == TARGET.DOODAD then
			local doodad = GetDoodad(this.dwTargetId)
			if not doodad or not doodad.CanDialog(player) then
				CloseDialoguePanel()
			end
	    end
	end
	
	if this.bWait then
		if GetTickCount() - this.dwLastTime >= this.dwWaitTime then
			DialoguePanel.FillContent(this)
		end
	end
end

function DialoguePanel.OnEvent(event)
	if event == "OPEN_WINDOW" then
		local npc = GetNpc(arg3)
		if arg2 == TARGET.NPC and (npc.dwTemplateID == 494 or npc.dwTemplateID == 495 or npc.dwTemplateID == 496 or npc.dwTemplateID == 5926) then
			OpenBookExchangePanel(arg1, arg2, arg3)
		else
			OpenDialoguePanel(arg0, arg1, arg2, arg3)
		end
	elseif event == "UI_SCALED" then
		DialoguePanel.UpdateScrollInfo(this:Lookup("", "Handle_Message"))
	end
end

function DialoguePanel.InitPanel(frame)
	frame.bMentorRank = nil
	frame:Lookup("", "Handle_Rank"):Hide()
	frame:Lookup("Btn_GoodBye"):Show()
	UnRegisterScrollAllControl("DialoguePanel")
	
	local nX, nY = frame:GetAbsPos()
	local btnPrev = frame:Lookup("Btn_PrevMsg")
	btnPrev:SetRelPos(btnPrev.nX, btnPrev.nY)
	btnPrev:SetAbsPos(nX + btnPrev.nX, nY+btnPrev.nY)
	
	local btnNext = frame:Lookup("Btn_NextMsg")
	btnNext:SetRelPos(btnNext.nX, btnNext.nY)
	btnNext:SetAbsPos(nX+btnNext.nX, nY+btnNext.nY)
end

function DialoguePanel.Update(frame, dwIndex, szText, dwTargetType, dwTargetId)
	DialoguePanel.ClearCmd(frame)
    frame:Show()
    frame:BringToTop()
    
	frame.dwIndex = dwIndex
	frame.dwTargetType = dwTargetType
	frame.dwTargetId = dwTargetId
	frame.bDisable = false
	
	local _, aInfo = GWTextEncoder_Encode(szText)
	frame.aInfo = aInfo or {}
	frame.aQuest = {}
	frame.bClear = true
	frame.dwContentIndex = 1
	DialoguePanel.FillContent(frame)
	frame:Lookup("Scroll_Message"):ScrollHome()
    frame:Lookup("", "Text_Title"):SetText(GetTargetName(dwTargetType, dwTargetId) or g_tStrings.STR_DIALOG_PANEL)
end

function DialoguePanel.InitEditBoxInfo(frame)
	frame.bHaveEditBox = false
	frame.bClose = false
	local edit = frame:GetFirstChild()
	while edit do
		if edit.bEditBox then
			edit.bShow = false
			edit:Hide()
		end
		edit = edit:GetNext()
	end
end

function DialoguePanel.ClearCmd(frame)
	if frame.dwTargetType and frame.dwTargetId then
		--Character_StopAnimation(frame.dwTargetId)
		Character_StopSound(frame.dwTargetId)
	end
end

function DialoguePanel.UpdateSubDataBtnState(frame)
	local btn = frame:Lookup("Btn_SubData")
	if frame.bHaveEditBox then
		btn:Show()
		local bDisable = false
		local edit = frame:GetFirstChild()
		while edit do
			if edit.bEditBox and edit.bShow and edit.required and edit:GetText() == "" then
				bDisable = true
				break
			end
			edit = edit:GetNext()
		end
		btn:Enable(not bDisable)
	else
		btn:Hide()
	end
end

function DialoguePanel.OnEditChanged()
	DialoguePanel.UpdateSubDataBtnState(this:GetRoot())
end

function DialoguePanel.CreateEditBox(hI)
	local frame = this:GetRoot()
	frame.bHaveEditBox = true
	if hI.bClose then
		frame.bClose = true
	end
	
	local edit = frame:Lookup("Edit_"..hI.id)
	
	if not edit then
		local f = Wnd.OpenWindow("DialogEditBox")
		edit = f:Lookup("Edit_Dialog")
		edit:ChangeRelation(frame, true, true)
		edit:SetName("Edit_"..hI.id)
		Wnd.CloseWindow("DialogEditBox")
	end
	
	edit:ClearText()
	edit:SetSize(hI:GetSize())
	edit:SetLimit(hI.len)
	edit.bEditBox = true
	edit.bShow = true
	edit.bClose = hI.bClose
	edit.bNumber = false
	if hI.type and hI.type == "N" then
		edit:SetType(0)
		edit.bNumber = true
	elseif hI.type and hI.type == "E" then
		edit:SetType(1)
	else
		edit:SetType(2)
	end
	edit.required = hI.required
end

function DialoguePanel.UpdateEditBoxShow(handle)
	local frame = handle:GetRoot()
	
	local x, y = handle:GetAbsPos()
	local w, h = handle:GetSize()
	local edit = frame:GetFirstChild()
	while edit do
		if edit.bEditBox then
			if edit.bShow then
				local hI = handle:Lookup(edit:GetName())
				if hI and hI:IsVisible() then
					local xI, yI = hI:GetAbsPos()
					local wI, hI = hI:GetSize()
					edit:SetSize(wI, hI)
					edit:SetAbsPos(xI, yI)
					if yI < y - 1 or yI + hI > y + h + 1 then
						edit:Hide()
					else
						edit:Show()
					end
				else
					edit:Hide()
				end
			else
				edit:Hide()
			end
		end
		edit = edit:GetNext()
	end
	
end

function DialoguePanel.UpdateScrollInfo(handle)
	local frame = handle:GetRoot()
	local wAll, hAll = handle:GetAllItemSize()
    local w, h = handle:GetSize()
    local scroll = frame:Lookup("Scroll_Message")
    local nCountStep = math.ceil(math.ceil((hAll - h) / 10) * 100)
    scroll:SetStepCount(nCountStep)
	if nCountStep > 0 then
		scroll:Show()
    	frame:Lookup("Btn_Up"):Show()
    	frame:Lookup("Btn_Down"):Show()
    	frame:Lookup("", "Image_Decoration2"):Hide()
    	frame:Lookup("", "Image_MScrollBg"):Show()
    else
    	scroll:Hide()
    	frame:Lookup("Btn_Up"):Hide()
    	frame:Lookup("Btn_Down"):Hide()
    	frame:Lookup("", "Image_Decoration2"):Show()
    	frame:Lookup("", "Image_MScrollBg"):Hide()
    end
    DialoguePanel.UpdateEditBoxShow(handle)
end

function DialoguePanel.AppendSelectableItem(handle, szText, nFrame, nFont, nOverFont, nDisableFont, bNewLine)
	local szText = "<handle>eventid=272<image>name=\"bg\" path=\"UI/Image/common/TextShadow.UITex\" w=300 h=1 frame=6</image>"
					.."<image>name=\"over\" path=\"UI/Image/common/TextShadow.UITex\" lockshowhide=1 w=300 h=1 y=4 frame=2</image>"
					.."<image>name=\"icon\" path=\"UI/Image/Common/DialogueLabel.UITex\"frame="..nFrame.." w=20 h=20 x=8 y=4 </image>"
		            .."<text>name=\"text\" text="..EncodeComponentsString("     "..szText).." font="..nFont.." multiline=1 w=284 x=8 y=6 </text></handle>"
	handle:AppendItemFromString(szText)
	local hI = handle:Lookup(handle:GetItemCount() - 1)
	local w, h = hI:GetSize()
	hI:SetSize(w, h + 10)
	hI:Lookup("bg"):SetSize(w, h + 8)
	hI:Lookup("over"):SetSize(w, h)
	if bNewLine then
		handle:AppendItemFromString("<text>text=\"\\\n\"</text>")
	end
	hI.bSelectableItem = true
	hI.nFont = nFont
	hI.nOverFont = nOverFont
	hI.nDisableFont = nDisableFont
	return hI
end

function DialoguePanel.FillContent(frame)
	local handle = frame:Lookup("", "Handle_Message")
	if frame.bClear then
		DialoguePanel.InitEditBoxInfo(frame)
		handle:Clear()
		handle:SetItemStartRelPos(0, 0)
	end
	
	frame.bWait = false
	
	local aInfo = frame.aInfo
	local nCount = #aInfo
	frame.dwContentIndex = frame.dwContentIndex or 1
	for i = frame.dwContentIndex, nCount, 1 do
		local v = aInfo[i]
		if v.name == "text" then --普通文本
			handle:AppendItemFromString("<text>text="..EncodeComponentsString(v.context).."font=160</text>")
		elseif v.name == "$" then --选项
			local hI = DialoguePanel.AppendSelectableItem(handle, v.context, 11, 160, 162, 161, false)
			hI.bSel = true
			if v.attribute.close then
				hI.bClose = true
			end
			hI.nID = tonumber(v.attribute.id)
		elseif v.name == "W" then --需要确认的选项
			local hI = DialoguePanel.AppendSelectableItem(handle, v.context, 11, 160, 162, 161, false)
			hI.bSel = true
			hI.bSure = true
			if v.attribute.close then
				hI.bClose = true
			end
			hI.nID = tonumber(v.attribute.id)
			hI.nSureID = tonumber(v.attribute.sureid)
		elseif v.name == "S" then --字符串id
		elseif v.name == "P" then --玩家
		elseif v.name == "I" then --物品
		elseif v.name == "Q" then --任务
        	local dwQuestId = tonumber(v.attribute.questid)
            local tQuestStringInfo = Table_GetQuestStringInfo(dwQuestId)
            if tQuestStringInfo then
            	table.insert(frame.aQuest, dwQuestId)
            	local eQuestState, nLevel = GetQuestState(dwQuestId, frame.dwTargetType, frame.dwTargetId)
            	if eQuestState ~= QUEST_STATE_NO_MARK and eQuestState ~= QUEST_STATE_WHITE_EXCLAMATION then
					local hI = nil 
					if eQuestState == QUEST_STATE_YELLOW_QUESTION then
						hI = DialoguePanel.AppendSelectableItem(handle, tQuestStringInfo.szName, 12, 160, 162, 161, true)					
						hI.dwOperation = 2
						
						local hImage_Quest = hI:Lookup("icon")
						if IsDialoguePanelOpened() and not frame.tHelpEventFlag.bQuestFinishChoose then
							FireHelpEvent("OnOpenpanel", "QuestFinishChoose", hImage_Quest)
							frame.tHelpEventFlag.bQuestFinishChoose = true
						end
					elseif eQuestState == QUEST_STATE_BLUE_QUESTION then
						hI = DialoguePanel.AppendSelectableItem(handle, tQuestStringInfo.szName, 15, 160, 162, 161, true)					
						hI.dwOperation = 2
					elseif eQuestState == QUEST_STATE_HIDE then
						hI = DialoguePanel.AppendSelectableItem(handle, tQuestStringInfo.szName, 13, 160, 162, 161, true)					
						hI.dwOperation = 1
					elseif eQuestState == QUEST_STATE_YELLOW_EXCLAMATION then
						hI = DialoguePanel.AppendSelectableItem(handle, tQuestStringInfo.szName, 13, 160, 162, 161, true)					
						hI.dwOperation = 1
						
						local hImage_Quest = hI:Lookup("icon")
						if IsDialoguePanelOpened() and not frame.tHelpEventFlag.bQuestChoose then
							FireHelpEvent("OnOpenpanel", "QuestChoose", hImage_Quest)
							frame.tHelpEventFlag.bQuestChoose = true
						end
					elseif eQuestState == QUEST_STATE_BLUE_EXCLAMATION then
						hI = DialoguePanel.AppendSelectableItem(handle, tQuestStringInfo.szName, 5, 160, 162, 161, true)					
						hI.dwOperation = 1
					elseif eQuestState == QUEST_STATE_WHITE_QUESTION then
						hI = DialoguePanel.AppendSelectableItem(handle, tQuestStringInfo.szName, 7, 160, 162, 161, true)					
						hI.dwOperation = 2
					elseif eQuestState == QUEST_STATE_DUN_DIA then
						hI = DialoguePanel.AppendSelectableItem(handle, tQuestStringInfo.szName, 11, 160, 162, 161, true)					
						hI.dwOperation = 2
					end
					if hI then
						local nPos = hI:GetIndex()
						hI.bQuest = true
						hI.dwQuestId = dwQuestId
						hI.eQuestState = eQuestState
						hI.nLevel = nLevel
						for i = nPos - 1, 0, -1 do --eQuestState从小到大排列,nLevel从小到大排列
							local hPrev = handle:Lookup(i)
							if hPrev.bQuest then
								if eQuestState < hPrev.eQuestState or (eQuestState == hPrev.eQuestState and nLevel < hPrev.nLevel) then
									handle:ExchangeItemIndex(nPos, i)
									nPos = i
								else
									break
								end
							end
						end
					end
				end
			end
		elseif v.name == "O" then	--对象
        elseif v.name == "M" then	--商店
			local hI = DialoguePanel.AppendSelectableItem(handle, v.attribute.shopname, 9, 160, 162, 161, true)
			hI.bShop = true
			hI.dwShopID = tonumber(v.attribute.shopid)
        elseif v.name == "N" then	--自己的名字
        	handle:AppendItemFromString("<text>text="..EncodeComponentsString(GetClientPlayer().szName).."font=160</text>")
        elseif v.name == "C" then	--自己的体型对应的称呼
        	handle:AppendItemFromString("<text>text="..EncodeComponentsString(g_tStrings.tRoleTypeToName[GetClientPlayer().nRoleType]).."font=160</text>")
        elseif v.name == "L" then	--邮件
        	local hI = DialoguePanel.AppendSelectableItem(handle, v.context, 9, 160, 162, 161, true)
			hI.bMail = true
        elseif v.name == "B" then	--银行
        	local hI = DialoguePanel.AppendSelectableItem(handle, v.context, 9, 160, 162, 161, true)
			hI.bBank = true   
		elseif v.name == "FE" then	--五行石相关
			if v.attribute.type == "Produce" then
				local hI = DialoguePanel.AppendSelectableItem(handle, v.context, 9, 160, 162, 161, true)
				hI.bFEProduce = true 
			elseif v.attribute.type == "Equip" then
				local hI = DialoguePanel.AppendSelectableItem(handle, v.context, 9, 160, 162, 161, true)
				hI.bFEEquip = true 
			elseif v.attribute.type == "ProduceExtract" then
				local hI = DialoguePanel.AppendSelectableItem(handle, v.context, 9, 160, 162, 161, true)
				hI.bFEProduceExtract = true 
			elseif v.attribute.type == "EquipExtract" then
				local hI = DialoguePanel.AppendSelectableItem(handle, v.context, 9, 160, 162, 161, true)
				hI.bFEEquipExtract = true 
			end
		elseif v.name == "GB" then --帮会仓库
        	local hI = DialoguePanel.AppendSelectableItem(handle, v.context, 9, 160, 162, 161, true)
			hI.bGuildBank = true
		elseif v.name == "F" then	--字体
			handle:AppendItemFromString("<text>text="..EncodeComponentsString(v.attribute.text).."font="..v.attribute.fontid.."</text>")
		elseif v.name == "T" then	--图片
			if v.attribute.paramid then --选项
				local szText = "<handle>eventid=272<image>path=\"fromiconid\" frame="..v.attribute.picid.."</image>"
					.."<image>name=\"over\"path=\"UI/Image/common/TextShadow.UITex\" lockshowhide=1 w=1 h=1 frame=2</image></handle>"
				handle:AppendItemFromString(szText)
				local hI = handle:Lookup(handle:GetItemCount() - 1)
				hI:Lookup("over"):SetSize(hI:GetSize())
				hI.bSel = true
				if v.attribute.close then
					hI.bClose = true
				end
				hI.bPic = true
				hI.nID = tonumber(v.attribute.paramid)
				if v.attribute.tipid then
					hI.nTipID = tonumber(v.attribute.tipid)
				end
			else
				if v.attribute.tipid then
					handle:AppendItemFromString("<image>eventid=256 path=\"fromiconid\" frame="..v.attribute.picid.."</image>")
					local img = handle:Lookup(handle:GetItemCount() - 1)
					img.nTipID = tonumber(v.attribute.tipid)
					img.bTipPic = true
				else
					handle:AppendItemFromString("<image>path=\"fromiconid\" frame="..v.attribute.picid.."</image>")
				end
			end
		elseif v.name == "A" then	--动画
		elseif v.name == "H" then	--控制行高，如果高度大于当前行高，调整为这个高度，否则，不变
			handle:AppendItemFromString("<null>h="..v.attribute.height.."</null>")
		elseif v.name == "K" then	--技能学习
			local hI = DialoguePanel.AppendSelectableItem(handle, v.attribute.text, 9, 160, 162, 161, true)
			hI.bLearnSkill = true
			hI.dwMasterID = tonumber(v.attribute.masterid)
			
			local hImage_Quest = hI:Lookup("icon")
			local hPlayer = GetClientPlayer()
			if IsDialoguePanelOpened() then
				FireHelpEvent("OnOpenpanel", "SkillMaster", hImage_Quest)
			end
		elseif v.name == "E" then	--生活技能学习
			local hI = DialoguePanel.AppendSelectableItem(handle, v.attribute.text, 9, 160, 162, 161, true)
			hI.bLearnCraft = true
			hI.dwMasterID = tonumber(v.attribute.masterid)
		elseif v.name == "G" then	--4个英文空格
			local szSpace = g_tStrings.STR_TWO_CHINESE_SPACE
			if v.attribute.english then
				szSpace = "    "
			end
			handle:AppendItemFromString("<text>text=\""..szSpace.."\" font=160</text>")
		elseif v.name == "J" then	--金钱
			local nM = tonumber(v.attribute.money)
			local nF = 160
			if v.attribute.compare then
				if nM > GetClientPlayer().GetMoney() then
					nF = 166
				end
			end
			handle:AppendItemFromString(GetMoneyText(nM, "font="..nF))
		elseif v.name == "U" then	--交通点
			local hI = DialoguePanel.AppendSelectableItem(handle, v.attribute.text, 9, 160, 162, 161, true)
			hI.bTrafficPoint = true
			hI.dwTrafficPointId = tonumber(v.attribute.pointid)
		elseif v.name == "X" then --输入框
			handle:AppendItemFromString("<image>path=\"ui/Image/UICommon/CommonPanel.UITex\" frame=84 imagetype=10 </image>")
			local hI = handle:Lookup(handle:GetItemCount() - 1)
			hI.id = tonumber(v.attribute.id)
			if v.attribute.len then
				hI.len = tonumber(v.attribute.len)
			else
				hI.len = 32
			end
			if not hI.len or hI.len < 2 then
				hI.len = 2
			end
			if v.attribute.width then
				hI.width = tonumber(v.attribute.width)
			end
			if not hI.width or hI.width < 30 then
				hI.width = 30
			end
			
			hI:SetSize(hI.width, 24)
			
			if v.attribute.close then
				hI.bClose = true
			end			
			hI.type = v.attribute.type
			if v.attribute.required then
				hI.required = true
			end
			hI:SetName("Edit_"..hI.id)
			DialoguePanel.CreateEditBox(hI)
		elseif v.name  == "Y" then --拍卖行
     		local hI = DialoguePanel.AppendSelectableItem(handle, v.context, 9, 160, 162, 161, true)
			hI.bAuction = true		
		elseif v.name == "BF" then --战场
			local hItem = DialoguePanel.AppendSelectableItem(handle, v.attribute.context, 66, 160, 162, 161, true)
			hItem.dwNpcID = tonumber(v.attribute.npcid)
			hItem.dwMapID = tonumber(v.attribute.mapid)
			hItem.nGroupID = tonumber(v.attribute.groupid)
			hItem.bBattleFaield = true
		elseif v.name == "AT" then --动作
			local player = GetClientPlayer()
			if frame.dwTargetId and player then
				local bFace = false
				if v.attribute.face then
					bFace = true
				end
				Character_PlayAnimation(frame.dwTargetId, player.dwID, tonumber(v.attribute.actionid), bFace)
			end
		elseif v.name == "SD" then --声音
			local player = GetClientPlayer()
			if frame.dwTargetId and player then
				Character_PlaySound(frame.dwTargetId, player.dwID, v.attribute.soundid, false)
			end
		elseif v.name == "WT" then --延迟
			if not DialoguePanel.bShowAllOneTime then
				frame.bWait = true
				frame.dwLastTime = GetTickCount()
				frame.dwWaitTime = tonumber(v.attribute.waittime) * 1000
				frame.bClear = false
				if v.attribute.clear then
					frame.bClear = true
				end
				frame.bCannotSkip = false
				if v.attribute.cannotskip then
					frame.bCannotSkip = true
				end
				frame.bCannotGoBack = false
				if v.attribute.cannotgoback then
					frame.bCannotGoBack = true
				end
				frame.dwContentIndex = i + 1
				break
			end
		elseif v.name == "CS" then
			local hItem = DialoguePanel.AppendSelectableItem(handle, v.context, 9, 160, 162, 161, true)
			hItem.bCardSell = true
		elseif v.name == "CB" then
			local hItem = DialoguePanel.AppendSelectableItem(handle, v.context, 9, 160, 162, 161, true)
			hItem.bCardBuy = true
		elseif v.name == "MS" then
			local hItem = DialoguePanel.AppendSelectableItem(handle, v.context, 9, 160, 162, 161, true)
			hItem.bMoneySell = true
		elseif v.name == "MB" then
			local hItem = DialoguePanel.AppendSelectableItem(handle, v.context, 9, 160, 162, 161, true)
			hItem.bMoneyBuy = true
		elseif v.name == "MT" then
			local hItem = DialoguePanel.AppendSelectableItem(handle, v.attribute.text, 69, 160, 162, 161, true)
			hItem.dwTrafficID = tonumber(v.attribute.trafficid)
			hItem.bMiddleTraffic = true
        elseif v.name == "HS" then
			local hItem = DialoguePanel.AppendSelectableItem(handle, v.context, 9, 160, 162, 161, true)
			hItem.bHairShop = true
        elseif v.name == "EB" then
			local hItem = DialoguePanel.AppendSelectableItem(handle, v.context, 9, 160, 162, 161, true)
			hItem.bExteriorBuy = true
		elseif v.name == "PG" then --页码
		elseif v.name == "CMD" then 
			DialoguePanel.ParseCMD(frame, v);
		else --错误的解析，还原文本
			if v.context then
				handle:AppendItemFromString("<text>text="..EncodeComponentsString("<"..v.context..">").."font=160</text>")
			end
		end
	end
	
	if not frame.bWait then
		frame.dwContentIndex = #aInfo + 1
	end
	
	DialoguePanel.UpdateBtnPrev(frame)
	DialoguePanel.UpdateBtnNext(frame)
	handle:FormatAllItemPos()
	
	DialoguePanel.UpdateSubDataBtnState(frame)
	
	if not frame.bMentorRank then
		DialoguePanel.UpdateScrollInfo(handle)
	end
end

function DialoguePanel.UpdateBtnPrev(frame)
	frame.bCanGoPrev = false
	local btn = frame:Lookup("Btn_PrevMsg")
	if frame.bMentorRank then
		if frame.nStart == 1 then
			btn:Hide()
		else
			btn:Show()
		end
		btn:Show()
		return
	end
	
	if DialoguePanel.bShowAllOneTime then
		btn:Hide()
		return
	end
	local aInfo = frame.aInfo or {}
	local dwIndex = #aInfo
	if frame.bWait then
		dwIndex = frame.dwContentIndex - 2
	end
	
	for i = dwIndex, 1, -1 do
		local v = aInfo[i]
		if v.name == "WT" then
			if v.attribute.clear then
				if v.attribute.cannotgoback then
					btn:Hide()
				else
					btn:Show()
					frame.bCanGoPrev = true
					frame.dwGoPrevIndex = 1
					for j = i - 1, 1, -1 do
						local v1 = aInfo[j]
						if v1.name == "WT" and v1.attribute.clear then
							frame.dwGoPrevIndex = j + 1
							break
						end
					end
				end
				return
			end
		end
	end
	btn:Hide()
end

function DialoguePanel.UpdateBtnNext(frame)
	local btn = frame:Lookup("Btn_NextMsg")
	
	if frame.bMentorRank then
		local nCount = DialoguePanel.GetRankCount(frame.szKey)
		if frame.nStart + frame.nCount - 1 >= nCount then
			btn:Hide()
		else
			btn:Show()
		end
		btn:Show()
		return
	end
	
	if frame.bWait then
		btn:Show()
		btn:Enable(not frame.bCannotSkip)
	else
		btn:Hide()
	end
end

function DialoguePanel.Disable(handle)
	local nCount = handle:GetItemCount() - 1
	for i = 0, nCount, 1 do
		local hI = handle:Lookup(i)
		if hI.nDisableFont then
			hI:Lookup("text"):SetFontScheme(hI.nDisableFont)
		end
	end
end

function DialoguePanel.OnItemLButtonClick()
	local frame = this:GetRoot()
	if frame.bDisable then
		return
	end
	
	if this.bTotal then
		if frame.bWait and not frame.bCannotSkip then
--			DialoguePanel.ClearCmd(frame)
			DialoguePanel.FillContent(frame)
		end
	elseif this.bSel then	
		local bClose = this.bClose and not this.bSure
		if bClose then
			CloseDialoguePanel()
		else
			frame.bDisable = true
			this:Lookup("over"):Hide()
			DialoguePanel.Disable(frame:Lookup("", "Handle_Message"))
		end
	
		if this.bSure and g_DialogSure and g_DialogSure[this.nSureID] then
			local dwIndex, dwID, bClose = frame.dwIndex, this.nID, this.bClose
			local fnAction = function()
				if bClose then
					CloseDialoguePanel()
				end
				GetClientPlayer().WindowSelect(dwIndex, dwID)
			end
			g_DialogSure[this.nSureID](fnAction)
		else
			GetClientPlayer().WindowSelect(frame.dwIndex, this.nID)
		end
	elseif this.bShop then
		CloseDialoguePanel(true)
		OpenShopRequest(this.dwShopID, frame.dwTargetId)
	elseif this.bQuest then
		if IsCtrlKeyDown() then
			if IsGMPanelReceiveQuest() then
				GMPanel_LinkQuest(this.dwQuestId)
			else
				EditBox_AppendLinkQuest(this.dwQuestId)
			end
		else
			CloseDialoguePanel(true)
			OpenQuestAcceptPanel(this.dwQuestId, this.dwOperation, frame.dwTargetType, frame.dwTargetId, true, frame.aQuest)
		end
	elseif this.bMail then
		CloseDialoguePanel(true)
		OpenMailPanel(frame.dwTargetType, frame.dwTargetId)
	elseif this.bBank then
		CloseDialoguePanel(true)
		if frame.dwTargetType == TARGET.NPC then
			GetClientPlayer().OpenBank(frame.dwTargetId)
		end
	elseif this.bGuildBank then
		CloseDialoguePanel(true)
		if frame.dwTargetType == TARGET.NPC then
			OpenGuildBankPanel(frame.dwTargetType, frame.dwTargetId)
		end
	elseif this.bLearnSkill then 
		CloseDialoguePanel(true)
		if frame.dwTargetType == TARGET.NPC then
			OpenSkillFormulaPanel(frame.dwTargetId, this.dwMasterID, true)
		end
	elseif this.bLearnCraft then
		CloseDialoguePanel(true)
		if frame.dwTargetType == TARGET.NPC then
			OpenSkillFormulaPanel(frame.dwTargetId, this.dwMasterID, false)
		end
	elseif this.bTrafficPoint then
		CloseDialoguePanel(true)
		if frame.dwTargetType == TARGET.NPC then
			OpenWorldMap(true, this.dwTrafficPointId)
		end
	elseif this.bMiddleTraffic then
		CloseDialoguePanel(true)
		OpenTrafficMiddleMap(this.dwTrafficID, frame.dwTargetId)
	elseif this.bBattleFaield then
		--CloseDialoguePanel(true)
		--OpenBattleFieldQueue(this.dwNpcID, this.dwMapID, this.nGroupID)
	elseif this.bAuction then
		CloseDialoguePanel(true)
		OpenAuctionPanel(frame.dwTargetType, frame.dwTargetId) --以后可能要加上参数
	elseif this.bCardBuy then
		OpenCardBuy()
	elseif this.bCardSell then
		OpenCardSell()
	elseif this.bMoneyBuy then
		OpenMoneyBuy()
	elseif this.bMoneySell then
		OpenMoneySell()
	elseif this.bFEEquip then
		CloseDialoguePanel(true)
		OpenFEEquipPanel(frame.dwTargetType, frame.dwTargetId)
	elseif this.bFEProduceExtract then
		CloseDialoguePanel(true)
		OpenFEEquipExtractPanel(frame.dwTargetType, frame.dwTargetId, "UnStrength")
	elseif this.bFEEquipExtract then
		CloseDialoguePanel(true)
		OpenFEEquipExtractPanel(frame.dwTargetType, frame.dwTargetId, "UnMount")
    elseif this.bHairShop then
        CloseDialoguePanel(true)
        OpenHairShop(frame.dwTargetId)
    elseif this.bExteriorBuy then
        CloseDialoguePanel(true)
        OpenExteriorBuy(frame.dwTargetId)
	end
end

function DialoguePanel.OnItemLButtonDBClick()
	return DialoguePanel.OnItemLButtonClick()
end

function DialoguePanel.OnItemRButtonClick()
	local frame = this:GetRoot()
	if frame.bDisable then
		return
	end
	
	if this.bTotal then
		if frame.bCanGoPrev then
			DialoguePanel.ClearCmd(frame)
			frame.dwContentIndex = frame.dwGoPrevIndex
			DialoguePanel.FillContent(frame)
		end
	end
end

function DialoguePanel.OnItemRButtonDBClick()
	return DialoguePanel.OnItemRButtonClick()
end

function DialoguePanel.OnItemMouseEnter()
	local frame = this:GetRoot()
	if frame.bDisable then
		return
	end
	
	if this.bSelectableItem then
		this:Lookup("over"):Show()
		this:Lookup("text"):SetFontScheme(this.nOverFont)
	end
	
	if this.bSel then
		if this.bPic then
			this:Lookup("over"):Show()
			if this.nTipID then
				local fnTip = g_aGameWorldTip[this.nTipID]
				if fnTip then
					local x, y = this:GetAbsPos()
					local w, h = this:GetSize()
					fnTip({x, y, w, h})
				end
			end
		end
	elseif this.bTipPic then
		if this.nTipID then
			local fnTip = g_aGameWorldTip[this.nTipID]
			if fnTip then
				local x, y = this:GetAbsPos()
				local w, h = this:GetSize()
				fnTip({x, y, w, h})
			end
		end
	end	
end

function DialoguePanel.OnItemMouseLeave()
	local frame = this:GetRoot()
	if frame.bDisable then
		return
	end
	
	if this.bSelectableItem then
		local img = this:Lookup("over")
		if img then
			img:Hide()
		end
		local text = this:Lookup("text")
		if text then
			text:SetFontScheme(this.nFont)
		end
	end

	if this.bSel then
		if this.bPic then
			local img = this:Lookup("over")
			if img then
				img:Hide()
			end
			HideTip()
		end
	elseif this.bTipPic then
		HideTip()
	end
end

function DialoguePanel.OnItemMouseWheel()
	local nDistance = Station.GetMessageWheelDelta()
	this:GetRoot():Lookup("Scroll_Message"):ScrollNext(nDistance * 100)
	return 1
end

function DialoguePanel.OnScrollBarPosChanged()
	local nCurrentValue = this:GetScrollPos()
	local frame = this:GetParent()
	if nCurrentValue == 0 then
		frame:Lookup("Btn_Up"):Enable(0)
	else
		frame:Lookup("Btn_Up"):Enable(1)
	end
	local nTotal = this:GetStepCount()
	if nCurrentValue == nTotal then
		frame:Lookup("Btn_Down"):Enable(0)
	else
		frame:Lookup("Btn_Down"):Enable(1)
	end
	
	if nTotal == 0 then
		frame:Lookup("", "Image_MScrollBg"):SetPercentage(0)
	else
		frame:Lookup("", "Image_MScrollBg"):SetPercentage(nCurrentValue / nTotal)
	end
	
	local handle
	if not frame.bMentorRank then
		handle = frame:Lookup("", "Handle_Message")
	else
		handle = frame:Lookup("", "Handle_Rank/Handle_RankList")
	end
	handle:SetItemStartRelPos(0, - math.floor(nCurrentValue / 100) * 10)
    DialoguePanel.UpdateEditBoxShow(handle)
end

function DialoguePanel.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_Close" or szName == "Btn_GoodBye" then
    	CloseDialoguePanel()
    elseif szName == "Btn_SubData" then
    	local frame = this:GetRoot()
    	local aParam = {frame.dwTargetType or TARGET.INVALID, frame.dwTargetId or 0}
    	local edit = frame:GetFirstChild()
    	while edit do
			if edit.bEditBox and edit.bShow then
				 if edit.bNumber then
				 	table.insert(aParam, tonumber(edit:GetText()))
				 else
				 	table.insert(aParam, edit:GetText())
				 end
			end
			edit = edit:GetNext()
		end
		RemoteCallToServer("OnDialogueInput", unpack(aParam))
    	if frame.bClose then
    		CloseDialoguePanel()
    	end
    elseif szName == "Btn_NextMsg" then
    	local frame = this:GetRoot()
		if frame.bMentorRank then
			DialoguePanel.AppendMentorRank(frame, frame.nStart + frame.nCount)
			DialoguePanel.UpdateBtnPrev(frame)
			DialoguePanel.UpdateBtnNext(frame)
			return
		end
		
    	if frame.bWait and not frame.bCannotSkip then
--			DialoguePanel.ClearCmd(frame)
			DialoguePanel.FillContent(frame)
		end
	elseif szName == "Btn_PrevMsg" then
		local frame = this:GetRoot()
		if frame.bMentorRank and  frame.nStart ~= 1 then
			DialoguePanel.AppendMentorRank(frame, frame.nStart - frame.nCount)
			DialoguePanel.UpdateBtnNext(frame)
			DialoguePanel.UpdateBtnPrev(frame)
		elseif frame.bCanGoPrev then
			DialoguePanel.ClearCmd(frame)
			frame.dwContentIndex = frame.dwGoPrevIndex
			DialoguePanel.FillContent(frame)
		end
    end
end

function DialoguePanel.OnLButtonDown()
	DialoguePanel.OnLButtonHold()
end

function DialoguePanel.OnLButtonHold()
	local szSelfName = this:GetName()
	if szSelfName == "Btn_Up" then
		this:GetParent():Lookup("Scroll_Message"):ScrollPrev(100)
	elseif szSelfName == "Btn_Down" then
		this:GetParent():Lookup("Scroll_Message"):ScrollNext(100)	
    end
end

function ReturnToDialoguePanel()
	local frame = Station.Lookup("Normal/DialoguePanel")
	if frame then
		frame:Show()
	end
	PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
end

function OpenDialoguePanel(dwIndex, szText, dwTargetType, dwTargetId, bDisableSound)
	if IsOptionOrOptionChildPanelOpened() then
		return
	end

	local player = GetClientPlayer()
	if not player or player.nMoveState == MOVE_STATE.ON_DEATH then
		return
	end

	local frame = Station.Lookup("Normal/DialoguePanel")
	if not frame then
		frame = Wnd.OpenWindow("DialoguePanel")
	end
	
	CloseQuestAcceptPanel(true)
	CloseShop(true)
	CloseMailPanel(true)
	CloseBankPanel(true)
	CloseSkillFormulaPanel(true)
	CloseGuildBankPanel(true)
	
	DialoguePanel.InitPanel(frame)
	
	frame.tHelpEventFlag = {}
	DialoguePanel.Update(frame, dwIndex, szText, dwTargetType, dwTargetId)
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND, g_sound.OpenFrame)	
	end
	
	FireHelpEvent("OnDialogue", dwTargetType, dwTargetId)
end

function CloseDialoguePanel(bDisableSound)
	local frame = Station.Lookup("Normal/DialoguePanel")
	if frame then
		frame:Hide()
		frame.bMentorRank = nil
		DialoguePanel.ClearCmd(frame)
	end

	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND, g_sound.CloseFrame)
	end
end

function IsDialoguePanelOpened()
	local frame = Station.Lookup("Normal/DialoguePanel")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end

function IsShowDialogOneTime()
	return DialoguePanel.bShowAllOneTime
end

function SetShowDialogOneTime(bOneTime)
	DialoguePanel.bShowAllOneTime = bOneTime
end

--=================通用解析===============================
function DialoguePanel.UpdatePageInfo(frame)
	local hText = frame:Lookup("", "Handle_Rank/Text_Page")
	local nCount = DialoguePanel.GetRankCount(frame.szKey)
	local nPages = math.ceil(nCount / frame.nCount)
	local nIndex = math.ceil(frame.nStart / frame.nCount)
	hText:SetText(nIndex.."/"..nPages)
end

function DialoguePanel.ParseCMD(frame, tData)
	local szType = tData.attribute.attri0
	if szType == "MENTOR_STONE_RANK" then
		local btnPrev = frame:Lookup("Btn_PrevMsg")
		local nX, nY  = frame:GetAbsPos()
		
		btnPrev:SetAbsPos(nX + btnPrev.nX, nY + btnPrev.nY + 31)
		btnPrev:SetRelPos(btnPrev.nX, btnPrev.nY + 31)
		btnPrev:Lookup("", ""):Lookup(0):SetText(g_tStrings.STR_PREV_PAGE)
		
		local btnNext = frame:Lookup("Btn_NextMsg")
		btnNext:SetAbsPos(nX + btnNext.nX, nY + btnNext.nY + 31)
		btnNext:SetRelPos(btnNext.nX, btnNext.nY + 31)
		btnNext:Lookup("", ""):Lookup(0):SetText(g_tStrings.STR_NEXT_PAGE)
		
		frame:Lookup("", "Handle_Rank"):Show()
		frame:Lookup("Btn_GoodBye"):Hide()
		
		frame.nForceID   = tData.attribute.attri1
		frame.nStart 	 = tonumber(tData.attribute.attri2)
		frame.nCount 	 = tonumber(tData.attribute.attri3)
		frame.nReqestTotal 	= tonumber(tData.attribute.attri4)
		frame.szKey     = "Rank_Role_ItemMentor_"..frame.nForceID 
		
		frame.bMentorRank = true
		DialoguePanel.AppendMentorRank(frame)
	end
end

function DialoguePanel.AppendMentorRank(frame, nStart)
	local nSize = 0
	local szKey = frame.szKey
	local tGlobalKey = DialoguePanel.tGlobalRanking[szKey]
	if tGlobalKey and tGlobalKey.tRanking then
		nSize = #tGlobalKey.tRanking
	end
	
	if nStart then
		if nStart > nSize then
			return
		end
		frame.nStart = nStart
	end
	local nEnd = frame.nStart + frame.nCount
	
	DialoguePanel.UpdateMentorStone(frame)
	if nEnd > nSize then
		DialoguePanel.RequestRankData(szKey, nSize + 1)
	end
end

function DialoguePanel.RequestRankData(szKey, nStart)
	local a = DialoguePanel.tGlobalRanking[szKey]
	local nTime = GetCurrentTime()
	if not a or not a.nQueryTime then
		RemoteCallToServer("OnQueryGlobalRanking", szKey, nStart, 2)
		return
	end
	
	local nlastQTime = a.nQueryTime or 0
	local nTimeRefresh = AchievementRanking.GetRankingRefreshTime(nTime)
	if nTime > nTimeRefresh and nlastQTime < nTimeRefresh then
		RemoteCallToServer("OnQueryGlobalRanking", szKey, nStart, 2)
		a.nQueryTime = nTime
		return 
	end
end

function DialoguePanel.GetRankCount(szKey)
	local tGlobalKey = DialoguePanel.tGlobalRanking[szKey]
    if not tGlobalKey or not tGlobalKey.tRanking then
		return 0
    end
	
	return #tGlobalKey.tRanking
end

local function OnMentorStoneRank()
	local frame
	if IsDialoguePanelOpened() then
		frame = Station.Lookup("Normal/DialoguePanel")
	end
	
	local szKey, tMsg, bSuccess, nStartIndex, nNextIndex = arg0, arg1, arg2, arg3, arg4
	local tGlobalKey = DialoguePanel.tGlobalRanking[szKey]
    if not tGlobalKey or not tGlobalKey.tRanking then
        DialoguePanel.tGlobalRanking[szKey] = {nQueryTime = GetCurrentTime(), tRanking = {}}
        tGlobalKey = DialoguePanel.tGlobalRanking[szKey]
    end
		
    local tRanking = tGlobalKey.tRanking
    for _, v in ipairs(tMsg) do
        table.insert(tRanking, v)
    end
	
	if frame and frame.bMentorRank then
		DialoguePanel.UpdateMentorStone(frame)
		DialoguePanel.UpdateBtnNext(frame)
	end
	
	if nNextIndex ~= 0 and frame and frame.bMentorRank and frame.nReqestTotal > nNextIndex then
		RemoteCallToServer("OnQueryGlobalRanking", szKey, nNextIndex, 2)
    end
end

function DialoguePanel.UpdateMentorStone(frame)
	local handle = frame:Lookup("", "Handle_Rank") 
	local hList  = handle:Lookup("Handle_RankList")
	local tGlobalKey = DialoguePanel.tGlobalRanking[frame.szKey] or {}
	local tRanking = tGlobalKey.tRanking or {}
	local nCount = #tRanking
	local nStart = frame.nStart
	local nEnd = frame.nStart + frame.nCount - 1
	nEnd = math.min(nEnd, nCount)
	hList:Clear()
	
	for i = nStart, nEnd, 1 do
		local tData = tRanking[i]
		if tData[7] ~=0 then
			local hItem = hList:AppendItemFromIni("ui/config/default/DialoguePanel.ini", "Handle_RankItem")
			hItem:Lookup("Text_Rank"):SetText(tData[8])
			hItem:Lookup("Text_Name"):SetText(tData[1])
			hItem:Lookup("Text_Camp"):SetText(g_tStrings.STR_CAMP_TITLE[tData[6]])
			hItem:Lookup("Text_Value"):SetText(tData[7])
		end
	end
	DialoguePanel.UpdatePageInfo(frame)
	
	hList:FormatAllItemPos()
	DialoguePanel.UpdateScrollInfo(hList)
end

RegisterCustomData("DialoguePanel.tGlobalRanking")

RegisterEvent("ON_MENTORSTONE_GET_RANKING", OnMentorStoneRank)
--[[测试代码
function DialoguePanel.Request(nStart)
	local tResult = {}
	local nSize = #Test_MentorRank
	local nEnd = nStart+9
	nEnd = math.min(nEnd, nSize)
	for i = nStart , nEnd, 1 do
		table.insert(tResult, Test_MentorRank[i])
	end
	local nNextIndex = nEnd + 1;
	if nEnd == nSize then
		nNextIndex = 0
	end
	FireUIEvent("ON_MENTORSTONE_GET_RANKING", "Rank_Role_ItemMentor_1", tResult, true, nStart, nNextIndex)
end

Test_MentorRank = 
{
	{szPlayerName="神人1", RoleCampID=1, RankValue=10000, Rank=1},
	{szPlayerName="神人1", RoleCampID=1, RankValue=10000, Rank=1},
	{szPlayerName="神人1", RoleCampID=1, RankValue=10000, Rank=1},
}
]]