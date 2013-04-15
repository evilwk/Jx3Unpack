BookExchangePanel = 
{
	tQuestID = {},
	tExpand  = {},
	bIsSearch   = false,
	nSelQuestID = -1,
	nSelHorID1 = -1,
	nSelHorID2 = -1,
	tBagBook = {},
	
	tFilter = 
	{
		szType = g_tStrings.STR_BOOK_ALL_TYPE, 
		szLevel = g_tStrings.STR_BOOK_ALL_LEVEL, 
		szBonus = g_tStrings.STR_BOOK_ALL_REWARD,
	},
}

function BookExchangePanel.OnFrameCreate()
	this:RegisterEvent("QUEST_FINISHED")
	this:RegisterEvent("BAG_ITEM_UPDATE")
	this:RegisterEvent("QUEST_DATA_UPDATE")
	this:RegisterEvent("UI_SCALED")
	
	InitFrameAutoPosInfo(this, 1, "Dialog", nil, function() CloseBookExchangePanel(true) end)
end

function BookExchangePanel.OnEvent(event)
	if event == "QUEST_FINISHED" or event == "BAG_ITEM_UPDATE" or event == "QUEST_DATA_UPDATE" then
		BookExchangePanel.UpdateBagBookInfo()
		BookExchangePanel.UpdateList(this:GetRoot()) 
	end
end


function BookExchangePanel.Init(frame)
	BookExchangePanel.tExpand  = {}
	BookExchangePanel.nSelQuestID = -1
	BookExchangePanel.nSelHorID1  = -1
	BookExchangePanel.nSelHorID2  = -1
	BookExchangePanel.bIsSearch = false
	
	local _, aInfo = GWTextEncoder_Encode(BookExchangePanel.szInfo)
	local player = GetClientPlayer()
	BookExchangePanel.tQuestID = {}
	for k, v in pairs(aInfo) do
		if v.name == "Q" then --任务
			local questInfo = GetQuestInfo(v.attribute.questid)
			local _, dwRecipeID = BookExchangePanel.GetRequireItemInfo(questInfo, 1)
			local nBookID, nSegmentID = GlobelRecipeID2BookID(dwRecipeID)
			local recipe = GetRecipe(8, nBookID, nSegmentID)
				
	        table.insert(BookExchangePanel.tQuestID, {v.attribute.questid,  recipe.dwRequireProfessionLevel, dwRecipeID})
	    end
    end
    function Cmp(a, b)
    	if a[2] ~= b[2] then
    		return a[2] < b[2]
    	else
    		return a[3] < b[3]
    	end
    end
    table.sort(BookExchangePanel.tQuestID, Cmp)
    
    local npc = GetNpc(BookExchangePanel.dwTargetID)
    local szTilte = ""
    if npc then
    	if npc.dwTemplateID == 494 or npc.dwTemplateID == 5926 then
    		szTilte = g_tStrings.STR_CRAFT_READ_BOOK_SORT_NAME_TABLE[3]
    	elseif npc.dwTemplateID == 495 then
    		szTilte = g_tStrings.STR_CRAFT_READ_BOOK_SORT_NAME_TABLE[2]
    	elseif npc.dwTemplateID == 496 then
    		szTilte = g_tStrings.STR_CRAFT_READ_BOOK_SORT_NAME_TABLE[1]
    	end
    end
    frame:Lookup("","Text_BookTitle"):SetText(szTilte)
	
	BookExchangePanel.tFilter.szType = g_tStrings.STR_BOOK_ALL_TYPE
	BookExchangePanel.tFilter.szLevel = g_tStrings.STR_BOOK_ALL_LEVEL
	BookExchangePanel.tFilter.szBonus = g_tStrings.STR_BOOK_ALL_REWARD
	
	BookExchangePanel.UpdateFilterValue(frame)
    BookExchangePanel.UpdateBagBookInfo()
    BookExchangePanel.UpdateList(frame)
end

function BookExchangePanel.OnFrameBreathe()
	local player = GetClientPlayer()
	if not player or player.nMoveState == MOVE_STATE.ON_DEATH then
		CloseBookExchangePanel()
		return
	end
	
    if BookExchangePanel.dwTargetType == TARGET.NPC then
		local npc = GetNpc(BookExchangePanel.dwTargetID)
		if not npc or not npc.CanDialog(player) then
			CloseBookExchangePanel()
			return
		end
	end
end

function BookExchangePanel.UpdateBagBookInfo()
	BookExchangePanel.tBagBook = {}
	
	local player = GetClientPlayer()
	local nNum = INVENTORY_INDEX.PACKAGE + 4
	for dwBox = INVENTORY_INDEX.PACKAGE, nNum, 1 do
		local nSize = player.GetBoxSize(dwBox) - 1
		for dwX = 0, nSize, 1 do
			local Item = GetPlayerItem(player, dwBox, dwX)
			if Item and Item.nGenre == ITEM_GENRE.BOOK then
				local nRecipeID = Item.nBookID
				BookExchangePanel.tBagBook[nRecipeID] = true
			end
		end
	end
	
end

function BookExchangePanel.GetRequireItemInfo(questInfo, nIndex)
	local nType, nID, dwRecipeID = 0, 0, 0
	if nIndex == 1 then
		nType  = questInfo.dwEndRequireItemType1 
		nID	 = questInfo.dwEndRequireItemIndex1 
		dwRecipeID  = questInfo.dwEndRequireItemAmount1 
	elseif nIndex == 2 then
		nType  = questInfo.dwEndRequireItemType2 
		nID	 = questInfo.dwEndRequireItemIndex2 
		dwRecipeID  = questInfo.dwEndRequireItemAmount2 
	elseif nIndex == 3 then
		nType  = questInfo.dwEndRequireItemType3 
		nID	 = questInfo.dwEndRequireItemIndex3 
		dwRecipeID  = questInfo.dwEndRequireItemAmount3 
	elseif nIndex == 4 then
		nType  = questInfo.dwEndRequireItemType4 
		nID	 = questInfo.dwEndRequireItemIndex4 
		dwRecipeID  = questInfo.dwEndRequireItemAmount4 
	elseif nIndex == 5 then
		nType  = questInfo.dwEndRequireItemType5 
		nID	 = questInfo.dwEndRequireItemIndex5 
		dwRecipeID  = questInfo.dwEndRequireItemAmount5 
	elseif nIndex == 6 then
		nType  = questInfo.dwEndRequireItemType6 
		nID	 = questInfo.dwEndRequireItemIndex6 
		dwRecipeID  = questInfo.dwEndRequireItemAmount6 
	elseif nIndex == 7 then
		nType  = questInfo.dwEndRequireItemType7 
		nID	 = questInfo.dwEndRequireItemIndex7 
		dwRecipeID  = questInfo.dwEndRequireItemAmount7
	elseif nIndex == 8 then
		nType  = questInfo.dwEndRequireItemType8 
		nID	 = questInfo.dwEndRequireItemIndex8 
		dwRecipeID  = questInfo.dwEndRequireItemAmount8 
	end
	if nType == 0 or nID == 0 then
		return nil, nil,nil,nil
	end
    local itemInfo  = GetItemInfo(nType, nID)
    if not itemInfo then
        Trace(string.format("questInfo Require%s nItemType=%d nIndex=%d dwRecipeID=%d GetItemInfo is nil", nIndex, nType, nID, dwRecipeID))
    end
	return itemInfo, dwRecipeID, nType, nID
end

function BookExchangePanel.UpdateList(frame)
	local szIniFile = "UI/Config/Default/BookExchangePanel.ini"
	local hList = frame:Lookup("Wnd_List", "")
	local player = GetClientPlayer()
	local bHaveSel = false
	local bSearchNothing = true
	local nType, nMinLevel, nMaxLevel, nBonus = BookExchangePanel.GetFilterValue(frame)
	
	hList:Clear()
	frame:Lookup("Btn_change"):Enable(false)
	for k, v in pairs(BookExchangePanel.tQuestID) do
		if BookExchangePanel.CheckFliterState(v[1], nType, nMinLevel, nMaxLevel, nBonus) then
			local questInfo = GetQuestInfo(v[1])
			local tQuestStringInfo = Table_GetQuestStringInfo(v[1])
			local pos = 1
			local bFinishPreQuest = true
			local bSelfFinish = true
			
			if questInfo.dwPrequestID1 ~= 0 then
				if player.GetQuestPhase(questInfo.dwPrequestID1) ~= 3 then
					bFinishPreQuest = false
				end
			end
			
			if questInfo.dwPrequestID2 ~= 0 then
				if player.GetQuestPhase(questInfo.dwPrequestID2) ~= 3 then
					bFinishPreQuest = false
				end
			end
			
			if questInfo.dwPrequestID3 ~= 0 then
				if player.GetQuestPhase(questInfo.dwPrequestID3) ~= 3 then
					bFinishPreQuest = false
				end
			end
			
			if questInfo.dwPrequestID4 ~= 0 then
				if player.GetQuestPhase(questInfo.dwPrequestID4) ~= 3 then
					bFinishPreQuest = false
				end
			end
			
			if player.GetQuestPhase(v[1]) ~= 3 then
					bSelfFinish = false
				end
			
			if BookExchangePanel.bIsSearch then
				pos = StringFindW(tQuestStringInfo.szName, BookExchangePanel.szSearchKey or "")
			end
			
			if pos and bFinishPreQuest and not bSelfFinish then
				bSearchNothing = false
				
				local hTitle = hList:AppendItemFromIni(szIniFile, "TreeLeaf_ItemClass")
				hTitle.bTitle = true
				hTitle.szName = tQuestStringInfo.szName
				hTitle.nQuestID = v[1]
				
				if questInfo.nPresentAll1 and questInfo.nPresentAll1 ~= 0 then
					hTitle.bAll1 = true
				end
			
				if questInfo.nPresentAll2 and questInfo.nPresentAll2 ~= 0 then
					hTitle.bAll2 = true
				end
				
				if BookExchangePanel.tExpand[v[1]] then
					hTitle:Expand()
				end
				
				if v[1] == BookExchangePanel.nSelQuestID then
					bHaveSel = true
					BookExchangePanel.Selected(hTitle)
				end
				
				local nHave, nTotal = 0, 0
				for i=1, 8, 1 do
					local ItemInfo, dwRecipeID = BookExchangePanel.GetRequireItemInfo(questInfo, i)
					if ItemInfo then
						local nR, nG, nB = GetItemFontColorByQuality(ItemInfo.nQuality, false)
						local hItem = hList:AppendItemFromIni(szIniFile, "TreeLeaf_ItemName")
						hItem.bItem = true
						hItem.dwRecipeID = dwRecipeID
						
						local nBookID, nSubID = GlobelRecipeID2BookID(dwRecipeID)
						hItem:Lookup("Text_ItemName"):SetText(Table_GetSegmentName(nBookID, nSubID))
						
						if BookExchangePanel.tBagBook[dwRecipeID] then
							hItem:Lookup("Text_ItemName"):SetFontScheme(162)
							hItem:Lookup("Text_ItemName"):SetFontColor(nR, nG, nB)
							nHave = nHave + 1
						else
							hItem:Lookup("Text_ItemName"):SetFontScheme(109)
						end
						hItem:Lookup("Image_Page1"):SetName("Image_Page")
						nTotal = nTotal + 1
					end
				end
				hTitle:Lookup("Text_ClassName"):SetText(tQuestStringInfo.szName.."("..nHave.."/"..nTotal..")")
				hTitle:Lookup("Text_ClassName"):SetFontScheme(162)
			end
		end
	end
	
	if BookExchangePanel.bIsSearch and bSearchNothing then
		local hItem = hList:AppendItemFromIni(szIniFile, "TreeLeaf_ItemClass")
		hItem:Lookup("Text_ClassName"):SetText(g_tStrings.STR_MSG_NOT_FIND_LIST)
		hItem:Lookup("Text_ClassName"):SetFontScheme(162)
		hItem:Lookup("Image_Page"):Hide()
	end
	
	hList:Show()
	
	if not bHaveSel then
		BookExchangePanel.nSelQuestID = -1
	end
		
	BookExchangePanel.OnUpdateScorllList(hList)
	BookExchangePanel.UpdateHortation(frame)
end

function BookExchangePanel.OnUpdateScorllList(hList)
	hList:FormatAllItemPos()
	local frame = hList:GetRoot()
	local scroll = frame:Lookup("Wnd_List/Scroll_List")
	local w, h = hList:GetSize()
	local wAll, hAll = hList:GetAllItemSize()
	local nStepCount = math.ceil((hAll - h) / 10)
	
	scroll:SetStepCount(nStepCount)
	if nStepCount > 0 then
		scroll:Show()
		frame:Lookup("Wnd_List/Btn_ListUp"):Show()
		frame:Lookup("Wnd_List/Btn_ListDown"):Show()
	else
		scroll:Hide()
		frame:Lookup("Wnd_List/Btn_ListUp"):Hide()
		frame:Lookup("Wnd_List/Btn_ListDown"):Hide()
	end
end

function BookExchangePanel.UpdateHortation(frame)
	local szIniFile = "UI/Config/Default/BookExchangePanel.ini"
	local hList = frame:Lookup("Wnd_List", "")
	local hHortation =  frame:Lookup("Wnd_Hortation", "")
	local nQuestID  = nil
	local hQuest = nil
	
	local nCount = hList:GetItemCount() - 1
	for i=0, nCount, 1 do
		local hI = hList:Lookup(i)
		if hI and hI.bSel then
			nQuestID = hI.nQuestID
			hQuest = hI
			break
		end
	end
	
	hHortation:Clear()	
	if nQuestID then
		local questInfo = GetQuestInfo(nQuestID)
        local tHortation = questInfo.GetHortation() or  {}
        local szText = ""
        for i=1, 4, 1 do
            local forceID = questInfo["dwAffectForceID"..i]
            local value = questInfo["nAffectForceValue"..i]
            if forceID ~= 0 and g_tReputation.tReputationTable[forceID] then
                local szName = g_tReputation.tReputationTable[forceID].szName
                szText = szText..szName.."("..value..") "
            end
        end
        
        if szText ~= "" then
            szText = g_tStrings.STR_QUEST_CAN_GET_REPUTATION .. szText
            local hReward = hHortation:AppendItemFromIni(szIniFile, "Handle_Reward")
            hRewardText = hReward:Lookup("Text_Reward")
            hRewardText:SetText(szText)
        end
        
        if tHortation.presentexamprint and tHortation.presentexamprint ~= 0 then --监本印文
            local hReward = hHortation:AppendItemFromIni(szIniFile, "Handle_Reward")
            hRewardText = hReward:Lookup("Text_Reward")
            local szMsg = FormatString(g_tStrings.STR_QUEST_CAN_GET_PRESENTEXAMPRINT, tHortation.presentexamprint)
            
            hRewardText:SetText(szMsg)
        end
		
        if tHortation.presentjustice and tHortation.presentjustice ~= 0 then --侠义值
            local hReward = hHortation:AppendItemFromIni(szIniFile, "Handle_Reward")
            hRewardText = hReward:Lookup("Text_Reward")
            local szMsg = FormatString(g_tStrings.STR_QUEST_CAN_GET_PRESENTJUSTICE, tHortation.presentjustice)
            
            hRewardText:SetText(szMsg)
        end
        
        if questInfo.nTitlePoint and questInfo.nTitlePoint ~= 0 then --战阶积分
            local hReward = hHortation:AppendItemFromIni(szIniFile, "Handle_Reward")
            hRewardText = hReward:Lookup("Text_Reward")
            local szMsg = FormatString(g_tStrings.STR_QUEST_CAN_GET_TITLE_POINT, questInfo.nTitlePoint)
            
            hRewardText:SetText(szMsg)
        end
        
        if tHortation.presenttrain and tHortation.presenttrain ~= 0 then --修为
            local hReward = hHortation:AppendItemFromIni(szIniFile, "Handle_Reward")
            hRewardText = hReward:Lookup("Text_Reward")
            local szMsg = FormatString(g_tStrings.STR_QUEST_CAN_GET_PRESENTTRAIN, tHortation.presenttrain)
            
            hRewardText:SetText(szMsg)
        end
        
         if tHortation.contribution and tHortation.contribution ~= 0 then --帮贡
            local hReward = hHortation:AppendItemFromIni(szIniFile, "Handle_Reward")
            hRewardText = hReward:Lookup("Text_Reward")
            local szMsg = FormatString(g_tStrings.STR_QUEST_CAN_GET_CONTRIBUTION, tHortation.contribution)
            
            hRewardText:SetText(szMsg)
        end
        
        if tHortation.tongdevelopmentpoint and tHortation.tongdevelopmentpoint ~= 0 then --帮会发展点
            local hReward = hHortation:AppendItemFromIni(szIniFile, "Handle_Reward")
            hRewardText = hReward:Lookup("Text_Reward")
            local szMsg = FormatString(g_tStrings.STR_QUEST_CAN_GET_DEVELOPMENT_POINT, tHortation.tongdevelopmentpoint)
            
            hRewardText:SetText(szMsg)
        end
        
        if tHortation.tongfund and tHortation.tongfund ~= 0 then --帮会发展点
            local hReward = hHortation:AppendItemFromIni(szIniFile, "Handle_Reward")
            hRewardText = hReward:Lookup("Text_Reward")
            local szMsg = FormatString(g_tStrings.STR_QUEST_CAN_GET_GUILD_MONEY, tHortation.tongfund)
            
            hRewardText:SetText(szMsg)
        end
        
		local bHave = false
		local bSel1, bSel2 = false, false
        for i = 1, 2 do
            local itemgroup = tHortation["itemgroup"..i]
            if itemgroup then
                for nIndex, v in ipairs(itemgroup) do
                    local ItemInfo = GetItemInfo(v.type, v.index)
                    local dwForceID  = hPlayer.GetEffectForceID()
                    if not itemgroup.accord2force or v.selectindex == dwForceID - 1 then
                        local nType, nID, nNeed= v.type, v.index, v.count
                        if ItemInfo then
                            if not bHave then
                                local hReward = hHortation:AppendItemFromIni(szIniFile, "Handle_Reward")
                                hRewardText = hReward:Lookup("Text_Reward")
                                
                                if hQuest.bAll1 or hQuest.bAll2 then
                                    hRewardText:SetText(g_tStrings.STR_BOOK_CHANGE_HORTATION)
                                else
                                    hRewardText:SetText(g_tStrings.STR_BOOK_CHANGE_SELECT_HORTATION)
                                end
                                bHave = true
                            end
                            local hItem = hHortation:AppendItemFromIni(szIniFile, "Handle_Item")
                            local box = hItem:Lookup("Box_Item")
                            local text = hItem:Lookup("Text_Item")
                            hItem.nOrder = nIndex
                            
                            hItem["bGroup" .. i] = true
                            if hQuest["bAll" .. i] then
                                hItem["bCanSel" .. i] = false
                            else
                                hItem["bCanSel" .. i] = true  
                            end
                            
                            hItem:Lookup("Image_SBG"):SetName("Image_Page")
                            box:SetObject(UI_OBJECT_ITEM_INFO, ItemInfo.nUiId, GLOBAL.CURRENT_ITEM_VERSION, nType, nID)
                            box:SetObjectIcon(Table_GetItemIconID(ItemInfo.nUiId))
                            UpdateItemBoxExtend(box, ItemInfo)
                            if nNeed == 1 then
                                box:SetOverText(0, "")
                            else
                                box:SetOverText(0, nNeed)
                            end
                            box:SetOverTextPosition(0, ITEM_POSITION.RIGHT_BOTTOM)
                            box:SetOverTextFontScheme(0, 15)
                            box:EnableObject(1)
                            
                            local szItemName = GetItemNameByItemInfo(ItemInfo)
                            text:SetText(szItemName)
                            
                            if hItem.nOrder == BookExchangePanel.nSelHorID1 then
                                bSel1 = true
                                BookExchangePanel.SelectHortation(hItem)
                            elseif hItem.nOrder == BookExchangePanel.nSelHorID2 then
                                bSel2 = true
                                BookExchangePanel.SelectHortation(hItem)
                            end
                            hItem:Show()
                        end
                    end
                end
             end
		end
		
		if not bSel1 then
			BookExchangePanel.nSelHorID1 = -1
		end
		
		if not bSel2 then
			BookExchangePanel.nSelHorID2 = -1
		end
	end
	BookExchangePanel.OnUpdateScorllHortation(hHortation)
end

function BookExchangePanel.OnUpdateScorllHortation(hList)
	hList:FormatAllItemPos()
	local frame = hList:GetRoot()
	local scroll = frame:Lookup("Wnd_Hortation/Scroll_Hortation")
	local w, h = hList:GetSize()
	local wAll, hAll = hList:GetAllItemSize()
	local nStepCount = math.ceil((hAll - h) / 10)
	
	scroll:SetStepCount(nStepCount)
	if nStepCount > 0 then
		scroll:Show()
		frame:Lookup("Wnd_Hortation/Btn_HortUp"):Show()
		frame:Lookup("Wnd_Hortation/Btn_HortDown"):Show()
	else
		scroll:Hide()
		frame:Lookup("Wnd_Hortation/Btn_HortUp"):Hide()
		frame:Lookup("Wnd_Hortation/Btn_HortDown"):Hide()
	end
end

function BookExchangePanel.OnScrollBarPosChanged()
	local frame = this:GetRoot()
	local nCurrentValue = this:GetScrollPos()
	local szName = this:GetName()
	
	if szName == "Scroll_List" then
		if nCurrentValue == 0 then
			frame:Lookup("Wnd_List/Btn_ListUp"):Enable(false)
		else
			frame:Lookup("Wnd_List/Btn_ListUp"):Enable(true)
		end
		
		if nCurrentValue == this:GetStepCount() then
			frame:Lookup("Wnd_List/Btn_ListDown"):Enable(false)
		else
			frame:Lookup("Wnd_List/Btn_ListDown"):Enable(true)
		end	
		frame:Lookup("Wnd_List", ""):SetItemStartRelPos(0, -nCurrentValue * 10)
	elseif szName == "Scroll_Hortation" then
		if nCurrentValue == 0 then
			frame:Lookup("Wnd_Hortation/Btn_HortUp"):Enable(false)
		else
			frame:Lookup("Wnd_Hortation/Btn_HortUp"):Enable(true)
		end
		
		if nCurrentValue == this:GetStepCount() then
			frame:Lookup("Wnd_Hortation/Btn_HortDown"):Enable(false)
		else
			frame:Lookup("Wnd_Hortation/Btn_HortDown"):Enable(true)
		end	
		frame:Lookup("Wnd_Hortation", ""):SetItemStartRelPos(0, -nCurrentValue * 10)
	end
end

function BookExchangePanel.CheckFliterState(nQuestID, nType, nMinLevel, nMaxLevel, nBonus)
	local questInfo = GetQuestInfo(nQuestID)
	local tFlag = {}
		
	local ItemInfo, dwRecipeID = BookExchangePanel.GetRequireItemInfo(questInfo, 1)
	local nBookID, nSegmentID = GlobelRecipeID2BookID(dwRecipeID)
	local nSubSortID = Table_GetBookSubSort(nBookID, 1)
	
	local recipe   = GetRecipe(8, nBookID, nSegmentID)
	local nReLevel = recipe.dwRequireProfessionLevel
	
	if questInfo.dwAffectForceID1 ~=0 or questInfo.dwAffectForceID2 ~=0 or 
	   questInfo.dwAffectForceID3 ~=0 or questInfo.dwAffectForceID4 ~=0 then
		tFlag[0] = true
	end
	
	local bHave = false
	local bSel1, bSel2 = false, false
    local tHortation = questInfo.GetHortation() or  {}
    for i = 1, 2 do
        local itemgroup = tHortation["itemgroup"..i]
        if itemgroup then
            for _, v in ipairs(itemgroup) do 
                local ItemInfo = GetItemInfo(v.type, v.index)
                if ItemInfo then
                    tFlag[v.type] = true
                end
            end
         end
    end
	
	if (nType == -1 or nType == nSubSortID) and 
	   (nMinLevel == -1 or (nReLevel >= nMinLevel and nReLevel <= nMaxLevel)) and 
	   (nBonus == -1 or tFlag[nBonus]) then 
		return true
	end
	
	return false
end

function BookExchangePanel.UpdateFilterValue(frame, bSave)
	local handle = frame:Lookup("", "")
	local textT = handle:Lookup("Text_Type")
	local textL = handle:Lookup("Text_Level")
	local textB = handle:Lookup("Text_Bonus")
	
	if bSave then
		BookExchangePanel.tFilter.szType = textT:GetText()
		BookExchangePanel.tFilter.szLevel = textL:GetText()
		BookExchangePanel.tFilter.szBonus = textB:GetText()
	end
	local tFilter = BookExchangePanel.tFilter
	
	textT:SetText(tFilter.szType)
	textL:SetText(tFilter.szLevel)
	textB:SetText(tFilter.szBonus)
end

function BookExchangePanel.GetFilterValue(frame)
	local handle = frame:Lookup("", "")
	local textT = handle:Lookup("Text_Type")
	local textL = handle:Lookup("Text_Level")
	local textB = handle:Lookup("Text_Bonus")
	
	local nSubSort = textT:GetText()
	if nSubSort == g_tStrings.STR_BOOK_ALL_TYPE then
		nSubSort = -1 
	else
		nSubSort = g_tStrings.tBookType[nSubSort]
	end
	
	local nMinLevel = -1
	local nMaxLevel = -1
	local nLevel = textL:GetText()
	if nLevel ~= g_tStrings.STR_BOOK_ALL_LEVEL then
		nMinLevel = g_tStrings.tBookLevel[nLevel][1]
		nMaxLevel = g_tStrings.tBookLevel[nLevel][2]
	end
	
	local szBonus = textB:GetText()
	local nBonus = -1
	if szBonus ~= g_tStrings.STR_BOOK_ALL_REWARD then
		nBonus = g_tStrings.tBookReward[szBonus]
	end
	
	BookExchangePanel.UpdateFilterValue(frame, true)
	return nSubSort, nMinLevel, nMaxLevel, nBonus
end

function BookExchangePanel.PopupMenu(hBtn, text, tData)
	if hBtn.bIgnor then
		hBtn.bIgnor = nil
		return
	end
	
	local xT, yT = text:GetAbsPos()
	local wT, hT = text:GetSize()
	local menu = 
	{
		nMiniWidth = wT,
		x = xT, y = yT + hT,
		fnCancelAction = function() 
			if hBtn:IsValid() then
				local x, y = Cursor.GetPos()
				local xA, yA = hBtn:GetAbsPos()
				local w, h = hBtn:GetSize()
				if x >= xA and x < xA + w and y >= yA and y <= yA + h then
					hBtn.bIgnor = true
				end
			end
		end,
		fnAction = function(UserData)
			if text:IsValid() then
				text:SetText(UserData)
				BookExchangePanel.UpdateList(text:GetRoot())
			end
		end,
		fnAutoClose = function() return not IsBookExchangePanelOpened() end,
	}
	for k, v in pairs(tData) do
		table.insert(menu, {szOption = v, UserData = v})
	end
	PopupMenu(menu)
end

function BookExchangePanel.UpdateBgStatus(hItem)
	if not hItem then
		Trace("KLUA[ERROR] ui\config\default\BookExchangePanel.lua UpdateBgStatus(hItem) hitem is nil\n")
		return
	end
	
	local img = hItem:Lookup("Image_Page")
	if not img then
		return
	end
	
	if hItem.bSel then
		img:Show()
		img:SetAlpha(255)
	elseif hItem.bOver then
		img:Show()
		img:SetAlpha(128)				
	else
		img:Hide()
	end
end
			
function BookExchangePanel.Selected(hItem)
	if hItem then
		local hList = hItem:GetParent()
		local nCount = hList:GetItemCount() - 1
		for i = 0, nCount, 1 do
			local hI = hList:Lookup(i)
			if hI.bSel then
				hI.bSel = false
				BookExchangePanel.UpdateBgStatus(hI)
			end
		end
		
		hItem.bSel = true
		BookExchangePanel.nSelQuestID = hItem.nQuestID
		BookExchangePanel.UpdateBgStatus(hItem)
		
		hItem:GetRoot():Lookup("Btn_change"):Enable(true)
	end
end

function BookExchangePanel.SelectHortation(hItem)
	if hItem then
		local hList = hItem:GetParent()
		local nCount = hList:GetItemCount() - 1
		for i = 0, nCount, 1 do
			local hI = hList:Lookup(i)
			if hItem.bGroup1 and hI.bGroup1 then
				if hI.bSel then
					hI.bSel = false
					BookExchangePanel.UpdateBgStatus(hI)
					hI:Lookup("Box_Item"):SetObjectMouseOver(0)
				end
			elseif hItem.bGroup2 and hI.bGroup2 then
				if hI.bSel then
					hI.bSel = false
					BookExchangePanel.UpdateBgStatus(hI)
					hI:Lookup("Box_Item"):SetObjectMouseOver(0)
				end
			end
		end
		
		hItem.bSel = true
		BookExchangePanel.UpdateBgStatus(hItem)
		hItem:Lookup("Box_Item"):SetObjectMouseOver(1)
		if hItem.bGroup2 then
			BookExchangePanel.nSelHorID2 = hItem.nOrder
		else
			BookExchangePanel.nSelHorID1 = hItem.nOrder
		end 
	end
end

function BookExchangePanel.FinishQuest(frame)
	local hList = frame:Lookup("Wnd_List", "")
	local hHortation = frame:Lookup("Wnd_Hortation", "")
	local nCount = hList:GetItemCount() - 1
	local player = GetClientPlayer()
	local nQuestID = nil
	local hQuest   = nil
	
	for i=0, nCount, 1 do
		local hItem = hList:Lookup(i)
		if hItem and hItem.bSel then
			nQuestID = hItem.nQuestID
			hQuest = hItem
			break		
		end
	end
	
	local npcType = BookExchangePanel.dwTargetType
	local npcID   = BookExchangePanel.dwTargetID
	local nChoice1, nChoice2 = 1, 5
	local bSel1, bSel2 = nil, nil
	local nCount1 = hHortation:GetItemCount() - 1 
	local bExist1, bExist2 = false, false
	for i=0, nCount1, 1 do
		local hI = hHortation:Lookup(i)
		if hI.bGroup1 then
			bExist1 = true
		elseif hI.bGroup2 then
			bExist2 = true
		end
		if hI.bCanSel1 and hI.bSel then
			nChoice1 = hI.nOrder
			bSel1 = true
		elseif hI.bCanSel2 and hI.bSel then
			nChoice2 = hI.nOrder
			bSel2 = true
		end 
	end
	
	if (bExist1 and not hQuest.bAll1  and not bSel1) or (bExist2 and not hQuest.bAll2 and not bSel2) then
		local xC, yC = Cursor.GetPos()
		local msg = 
		{
			x = xC, y = yC,
			szMessage = g_tStrings.STR_MSG_SELECT_HOR, 
			szName = "SelHortationNotice", 
			fnAutoClose = function() if IsBookExchangePanelOpened() then return false end return true end,
			{szOption = g_tStrings.STR_HOTKEY_SURE },
		}
		MessageBox(msg)
	else
		player.FinishQuest(nQuestID, npcType, npcID, nChoice1 - 1, nChoice2 - 1)
		PlaySound(SOUND.UI_SOUND, g_sound.Complete)
	end
end

function BookExchangePanel.OnItemLButtonClick()
	local frame = this:GetRoot()
	local szName = this:GetName()
	if this.bTitle then
		BookExchangePanel.tExpand[this.nQuestID] = not BookExchangePanel.tExpand[this.nQuestID]
		this:ExpandOrCollapse()
		BookExchangePanel.OnUpdateScorllList(frame:Lookup("Wnd_List", ""))
		BookExchangePanel.nSelHorID1 = -1
		BookExchangePanel.nSelHorID2 = -1
		BookExchangePanel.Selected(this)
		BookExchangePanel.UpdateHortation(frame)
		PlaySound(SOUND.UI_SOUND,g_sound.Button)
	elseif szName == "Handle_Item" then
		if this.bCanSel1 or this.bCanSel2 then
			this.bSel = true
			BookExchangePanel.SelectHortation(this)
		end
	end
end

function BookExchangePanel.OnItemMouseEnter()
	local szName = this:GetName()
	if this.bItem then
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
		local nBookID, nSegmentID = GlobelRecipeID2BookID(this.dwRecipeID)
		OutputBookTipByID(nBookID, nSegmentID, {x, y, w, h})
		this.bOver = true
		BookExchangePanel.UpdateBgStatus(this)
	elseif this.bTitle then
		this.bOver = true
		BookExchangePanel.UpdateBgStatus(this)
	elseif szName == "Box_Item" then
		this:SetObjectMouseOver(1)
		local _, dwVer, nTabType, nIndex = this:GetObjectData()
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
		OutputItemTip(UI_OBJECT_ITEM_INFO, dwVer, nTabType, nIndex, {x, y, w, h})
		return
	elseif szName == "Handle_Item" then
		this.bOver = true
		BookExchangePanel.UpdateBgStatus(this)
	end
end

function BookExchangePanel.OnItemMouseLeave()
	local szName = this:GetName()
	if this.bItem then
		HideTip()
		
		this.bOver = false
		BookExchangePanel.UpdateBgStatus(this)
	elseif this.bTitle then
		this.bOver = false
		BookExchangePanel.UpdateBgStatus(this)
	elseif szName == "Box_Item"  then
		if not this:GetParent().bSel then
			this:SetObjectMouseOver(0)
		end
		HideTip()
	elseif szName == "Handle_Item" then
		this.bOver = false
		BookExchangePanel.UpdateBgStatus(this)
	end
end

function BookExchangePanel.OnItemMouseWheel()
	local nDistance = Station.GetMessageWheelDelta()
	local szName = this:GetName()
	if szName == "Handle_List" then
		this:GetParent():Lookup("Scroll_List"):ScrollNext(nDistance)
	elseif szName == "Handle_Hortation" then
		this:GetParent():Lookup("Scroll_Hortation"):ScrollNext(nDistance)
	end
	return true
end


function BookExchangePanel.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_Close" or szName == "Btn_Cancel" then
		CloseBookExchangePanel()
	elseif szName == "Edit_Search" then
		 BookExchangePanel.OnSearch(this:GetRoot())
	elseif szName == "Btn_Change" then
		BookExchangePanel.FinishQuest(this:GetRoot())
	elseif szName == "Btn_Type" then
		local tData = {}
		for k, v in pairs(g_tStrings.tBookType) do
			table.insert(tData, k)
		end
		function Cmp(a , b)
			return g_tStrings.tBookType[a] < g_tStrings.tBookType[b]
		end
		table.sort(tData, Cmp)
		table.insert(tData, 1, g_tStrings.STR_BOOK_ALL_TYPE)
		
		local text = this:GetParent():Lookup("", "Text_Type")
		BookExchangePanel.PopupMenu(this, text, tData)
	elseif szName == "Btn_Level" then
		local tData = {}
		for k, v in pairs(g_tStrings.tBookLevel) do
			table.insert(tData, k)
		end
		table.sort(tData)
		table.insert(tData, 1, g_tStrings.STR_BOOK_ALL_LEVEL)
		
		local text = this:GetParent():Lookup("", "Text_Level")
		BookExchangePanel.PopupMenu(this, text, tData)
	elseif szName == "Btn_Bonus" then
		local tData =  {}
		for k, v in pairs(g_tStrings.tBookReward) do
			table.insert(tData, k)
		end
		table.insert(tData, 1, g_tStrings.STR_BOOK_ALL_REWARD)
		local text = this:GetParent():Lookup("", "Text_Bonus")
		BookExchangePanel.PopupMenu(this, text, tData)
	end
end

function BookExchangePanel.OnEditChanged()
	local szName = this:GetName()
	if szName == "Edit_Search" then
		BookExchangePanel.OnSearch(this:GetRoot())
	end
end

function BookExchangePanel.OnSearch(frame)
	local szKey = frame:Lookup("Edit_Search"):GetText()
	if not szKey or szKey == "" then
		if BookExchangePanel.bIsSearch then
			BookExchangePanel.bIsSearch = false
			BookExchangePanel.UpdateList(frame)
		end
	else
		BookExchangePanel.bIsSearch = true
		BookExchangePanel.szSearchKey = szKey
		BookExchangePanel.UpdateList(frame)
	end
end

function IsBookExchangePanelOpened()
	local frame = Station.Lookup("Normal/BookExchangePanel")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end

function OpenBookExchangePanel(szInfo, dwTargetType, dwTargetID, bDisableSound)
	if IsBookExchangePanelOpened() and BookExchangePanel.dwTargetID  == dwTargetID then
		return
	end
	
	BookExchangePanel.szInfo       = szInfo
	BookExchangePanel.dwTargetType = dwTargetType
	BookExchangePanel.dwTargetID   = dwTargetID
	
	local frame = Wnd.OpenWindow("BookExchangePanel")
	BookExchangePanel.Init(frame)
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end	
end

function CloseBookExchangePanel(bDisableSound)
	if IsBookExchangePanelOpened() then
		Wnd.CloseWindow("BookExchangePanel")
	end
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end		
end

