CraftReadManagePanel =
{
	nSortID = -1,
	
	nBookID = -1,
	nSegmentID = -1,
	bCoolDown = false,
	bIsSearch = false,
	tExpand = {},

	tFilter = 
	{
		 szType = g_tStrings.STR_BOOK_ALL_TYPE, 
		 szLevel = g_tStrings.STR_BOOK_ALL_LEVEL, 
		 szBind = g_tStrings.STR_BOOK_ALL_STATUS,
	},
}

function CraftReadManagePanel.OnFrameCreate()
	this:RegisterEvent("UI_SCALED")
	this:RegisterEvent("UPDATE_BOOK_STATE")	
	this:RegisterEvent("BAG_ITEM_UPDATE")
	this:RegisterEvent("PLAYER_LEVEL_UPDATE")
	this:RegisterEvent("SYS_MSG")
	this:RegisterEvent("SYNC_ROLE_DATA_END")
	
 	CraftReadManagePanel.UpdateFilterValue(this)
 	CraftReadManagePanel.ChangeCheckBox(this, 3)
 	
 	InitFrameAutoPosInfo(this, 1, nil, nil, function() CloseCraftReadManagePanel(true) end)
end

function CraftReadManagePanel.OnFrameBreathe()
	if CraftReadManagePanel.bCoolDown then
		local recipe  = GetRecipe(12, CraftReadManagePanel.nBookID, CraftReadManagePanel.nSegmentID)
		if recipe.dwCoolDownID > 0 then
			local hThew = this:Lookup("", "Handle_Thew")
			if hThew.szTime then
				local CDRemainTime = GetClientPlayer().GetCDLeft(recipe.dwCoolDownID)
				local szNTime = ForamtCoolDownTime(CDRemainTime)
				
				if hThew.szTime ~= szNTime then
					CraftReadManagePanel.UpdateCondition(this)
				end
			end
		end
	end
end

function CraftReadManagePanel.OnEvent(event)
	if event == "UPDATE_BOOK_STATE" then
		CraftReadManagePanel.UpdateList(this:GetRoot())
	elseif event == "UI_SCALED" then

	elseif event == "BAG_ITEM_UPDATE" or event == "PLAYER_LEVEL_UPDATE" then
		if CraftReadManagePanel.nBookID ~= -1 and CraftReadManagePanel.nSegmentID~= -1 then
			CraftReadManagePanel.UpdateCondition(this:GetRoot())
		end
	elseif event == "SYS_MSG" then
		if arg0 == "UI_OME_ADD_PROFESSION_PROFICIENCY" then
			CraftReadManagePanel.UpdateExperience(this:GetRoot(), CraftReadManagePanel.nSortID)
			if CraftReadManagePanel.nBookID ~= -1 and CraftReadManagePanel.nSegmentID ~= -1 then
				CraftReadManagePanel.UpdateCondition(this:GetRoot())
			end
		elseif arg0 == "UI_OME_CRAFT_RESPOND" then
			if arg1 == CRAFT_RESULT_CODE.SUCCESS then
				if CraftReadManagePanel.nBookID ~= -1 and CraftReadManagePanel.nSegmentID ~= -1 then
					CraftReadManagePanel.UpdateCondition(this:GetRoot())
				end
			end
			if not GetClientPlayer().IsAchievementAcquired(1007) then
				RemoteCallToServer("OnClientAddAchievement", "Copy_Book")
			end
		end
	elseif event == "SYNC_ROLE_DATA_END" then
		CraftReadManagePanel.UpdateList(this:GetRoot())
	end
end

function CraftReadManagePanel.UpdateFilterValue(frame, bSave)
	local handle = frame:Lookup("", "")
	local textT = handle:Lookup("Text_Type")
	local textL = handle:Lookup("Text_Level")
	local textB = handle:Lookup("Text_Kind")
	
	if bSave then
		CraftReadManagePanel.tFilter.szType = textT:GetText()
		CraftReadManagePanel.tFilter.szLevel = textL:GetText()
		CraftReadManagePanel.tFilter.szBind = textB:GetText()
	end
	local tFilter = CraftReadManagePanel.tFilter
	
	textT:SetText(tFilter.szType)
	textL:SetText(tFilter.szLevel)
	textB:SetText(tFilter.szBind)
end

function CraftReadManagePanel.GetFilterValue(frame)
	local handle = frame:Lookup("", "")
	local textT = handle:Lookup("Text_Type")
	local textL = handle:Lookup("Text_Level")
	local textB = handle:Lookup("Text_Kind")
	
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
	
	local szType = textB:GetText()
	local nBindType = -1
	local bCanTrade = true
	if szType == g_tStrings.STR_BOOK_ALL_STATUS then
		nBindType = -1
	else
		bCanTrade = g_tStrings.tBookBind[szType].bCanTrade
		nBindType = g_tStrings.tBookBind[szType].nBindType
	end
	
	CraftReadManagePanel.UpdateFilterValue(frame, true)
	return nSubSort, nMinLevel, nMaxLevel, nBindType, bCanTrade
end

function CraftReadManagePanel.GetDHMSByFrame(nFrame)
	local szTime = ""
	local nH, nM, nS = GetTimeToHourMinuteSecond(nFrame, true)
	local nD = math.floor(nH / 24)
	if nD >= 1 then
		szTime = nD..g_tStrings.STR_BUFF_H_TIME_D
	elseif nH >= 1 then
		szTime = nH..g_tStrings.STR_BUFF_H_TIME_H
	elseif nM >= 1 then
		szTime = nM..g_tStrings.STR_BUFF_H_TIME_M
	else
		szTime = nS..g_tStrings.STR_BUFF_H_TIME_S
	end
	return szTime
end

function CraftReadManagePanel.UpdateBgStatus(hItem)
	if not hItem then
		Trace("KLUA[ERROR] ui\config\default\CraftReadManagePanel.lua UpdateBgStatus(hItem) hitem is nil\n")
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
			
function CraftReadManagePanel.Selected(frame, hItem)
	if hItem then
		local hList = hItem:GetParent()
		local nCount = hList:GetItemCount() - 1
		for i = 0, nCount, 1 do
			local hI = hList:Lookup(i)
			if hI.bSel then
				hI.bSel = false
				hI:Lookup("Image_Page"):Hide()
			end
		end
		
		hItem.bSel = true
		CraftReadManagePanel.nBookID = hItem.nBookID
		CraftReadManagePanel.nSegmentID = hItem.nSegmentID
		
		frame:Lookup("Btn_Read"):Enable(hItem.bRead)
		CraftReadManagePanel.UpdateBgStatus(hItem)
	else
		CraftReadManagePanel.bCoolDown = false
		CraftReadManagePanel.nBookID = -1
		CraftReadManagePanel.nSegmentID = -1
		
		frame:Lookup("Btn_Read"):Enable(false)
		frame:Lookup("Btn_Copy"):Enable(false)
		frame:Lookup("", "Handle_LvCost"):Hide()
		frame:Lookup("", "Handle_Thew"):Hide()
		frame:Lookup("", "Handle_Cost"):Hide()
	end
end

function CraftReadManagePanel.UpdateCondition(frame)
	local handle  = frame:Lookup("", "")
	local hLvCost = handle:Lookup("Handle_LvCost")
	local hThew   = handle:Lookup("Handle_Thew")
	local hTool   = handle:Lookup("Handle_Cost")	
	local recipe  = GetRecipe(12, CraftReadManagePanel.nBookID, CraftReadManagePanel.nSegmentID)
	local player  = GetClientPlayer()
	local bCanCopy = true
	
	hLvCost:Clear()
	hThew:Clear()
	hTool:Clear()
	
	CraftReadManagePanel.bCoolDown = false
	hThew.szTime = nil
	
	local szLvCost = ""
	local szThew   = ""
	local szTool   = ""
	
	if not recipe then
		bCanCopy = false
		szLvCost = szLvCost.."<text>text="..EncodeComponentsString(g_tStrings.CRAFT_READING_CANNOT_COPY).." font=162 </text>"
	else
		local nTabtype = 5
		local nIndex = Table_GetBookItemIndex(CraftReadManagePanel.nBookID, CraftReadManagePanel.nSegmentID)
		local itemInfo = GetItemInfo(nTabtype, nIndex)
		local nLevel = player.GetProfessionLevel(8)
		local nFont = 162
		
		if nLevel < recipe.dwRequireProfessionLevel then
			nFont = 102
			bCanCopy = false
		end
		szLvCost = szLvCost.."<text>text="..EncodeComponentsString(FormatString(g_tStrings.CRAFT_READING_REQUIRE_LEVEL, recipe.dwRequireProfessionLevel)).." font="..nFont.." </text>"
		
		if recipe.dwProfessionIDExt ~= 0 then
		    local ProfessionExt = GetProfession(recipe.dwProfessionIDExt);
		    if ProfessionExt then
		        local nExtLevel = player.GetProfessionLevel(recipe.dwProfessionIDExt)
		        nFont = 162
		        
		        if nExtLevel < recipe.dwRequireProfessionLevelExt then
		        	nFont = 102
		        	bCanCopy = false
		        end	
			    szLvCost = szLvCost.."<text>text="..EncodeComponentsString(Table_GetProfessionName(recipe.dwProfessionIDExt)..recipe.dwRequireProfessionLevelExt..g_tStrings.LEVEL_BLANK).." font="..nFont.." </text>"
		    end
		end
		
		if recipe.nRequirePlayerLevel and recipe.nRequirePlayerLevel ~= 0 then
			nFont = 162
			if player.nLevel < recipe.nRequirePlayerLevel then
				nFont = 102
				bCanCopy = false
			end
			szLvCost = szLvCost.."<text>text="..EncodeComponentsString(FormatString(g_tStrings.STR_CRAFT_READ_NEED_PLAYER_LEVEL, recipe.nRequirePlayerLevel)).." font="..nFont.." </text>"
		end
		--if itemInfo.nBindType == ITEM_BIND.BIND_ON_EQUIPPED or itemInfo.nBindType == ITEM_BIND.BIND_ON_PICKED then
		--	szLvCost = szLvCost.."<text>text="..EncodeComponentsString("("..g_tStrings.STR_ITEM_H_BIND_AFTER_COPY..")").." font=106 </text>"
		--end
		
		nFont = 162
		if player.nCurrentThew < recipe.nThew then
			nFont = 102
			bCanCopy = false
		end
		szThew = szThew.."<text>text="..EncodeComponentsString(FormatString(g_tStrings.CRAFT_COST_THEW_BLANK, recipe.nThew)).." font="..nFont.." </text>"
		
		if recipe.dwCoolDownID > 0 then
			CraftReadManagePanel.bCoolDown = true
			local szText = ""
			local CDTotalTime  = player.GetCDInterval(recipe.dwCoolDownID)
			local CDRemainTime = player.GetCDLeft(recipe.dwCoolDownID)
			
			if CDRemainTime <= 0 then
				local szTime = ForamtCoolDownTime(CDTotalTime)
				szText = g_tStrings.TIME_CD..szTime
			else
				local szTime = ForamtCoolDownTime(CDRemainTime)
				if not szTime or szTime == "" then
					CDRemainTime = 0
					local szTime = ForamtCoolDownTime(CDTotalTime)
					szText = g_tStrings.TIME_CD..szTime
				else
					hThew.szTime = szTime
					szText = g_tStrings.TIME_CD1..szTime
				end
			end
	
			nFont = 162
			if CDRemainTime ~= 0 then
				nFont = 102
				bCanCopy = false
			end
			szThew = szThew.."<text>text="..EncodeComponentsString(szText).." font="..nFont.." </text>"
			--.."<text>text="..EncodeComponentsString("(").." font=162 </text>"
			--szThew = szThew.."<text>text="..EncodeComponentsString(g_tStrings.tszItemColor[itemInfo.nQuality]).." font=162"..GetItemFontColorByQuality(itemInfo.nQuality, true).." </text>"
			--szThew = szThew.."<text>text="..EncodeComponentsString(g_tStrings.BOOK_QUALITY..")").." font=162 </text>"
		end
		
		if recipe.dwToolItemType ~= 0 and recipe.dwToolItemIndex ~= 0 then
			local itemTool   = GetItemInfo(recipe.dwToolItemType, recipe.dwToolItemIndex)
			local szItemName = GetItemNameByItemInfo(itemTool)
			local nToolCount = player.GetItemAmount(recipe.dwToolItemType, recipe.dwToolItemIndex)
			
			szTool = szTool.."<text>text="..EncodeComponentsString(g_tStrings.CRAFT_NEED_TOOL).." font=162 </text>"
			nFont  = 162
			if nToolCount <= 0 then
				nFont = 102
				bCanCopy = false
			end
			szTool = szTool.."<text>text="..EncodeComponentsString(szItemName .." ").." font="..nFont.." </text>"
		end
		
		szTool = szTool.."<text>text="..EncodeComponentsString(g_tStrings.CRAFT_ITEM).." font=162 </text>"
		for nIndex = 1, 4, 1 do
			local nType  = recipe["dwRequireItemType"..nIndex]
			local nID	 = recipe["dwRequireItemIndex"..nIndex]
			local nNeed  = recipe["dwRequireItemCount"..nIndex]
			if nNeed > 0 then
				local ItemRequire = GetItemInfo(nType, nID)
				local szItemName = GetItemNameByItemInfo(ItemRequire)
				local nCount = player.GetItemAmount(nType, nID)
				nFont = 162
				if nCount < nNeed then
					nFont = 102
					bCanCopy = false
				end
				szTool = szTool.."<text>text="..EncodeComponentsString(szItemName ..nNeed.." ").." font="..nFont.." </text>"
			end
		end
	end
	
	hLvCost:AppendItemFromString(szLvCost)
	hLvCost:FormatAllItemPos()
	hLvCost:Show()
	
	hThew:AppendItemFromString(szThew)
	hThew:FormatAllItemPos()
	hThew:Show()
	
	hTool:AppendItemFromString(szTool)
	hTool:FormatAllItemPos()
	hTool:Show()
	
	if not frame:Lookup("Btn_Read"):IsEnabled() then
		bCanCopy = false
	end
	frame:Lookup("Btn_Copy"):Enable(bCanCopy)
end

function ForamtCoolDownTime(nTime)
	local szText = ""
	local nH, nM, nS = GetTimeToHourMinuteSecond(nTime, true)
	if nH and nH > 0 then
		if (nM and nM > 0) or (nS and nS > 0) then
			nH = nH + 1
		end
		local nD = math.floor(nH / 24)
		if nD > 0 then
			szText = szText..nD..g_tStrings.STR_BUFF_H_TIME_D
		end
		nH = (nH - nD * 24)
		if nH > 0 then
			szText = szText..nH..g_tStrings.STR_BUFF_H_TIME_H
		end
	else 
		nM = nM or 0
		nS = nS or 0
				
		if nM == 0 and nS == 0 then
			return szText
		end
		
		if nS and nS > 0 then
			nM = nM + 1
		end
		
		if nM >= 60 then
			szText = szText..math.ceil(nM / 60)..g_tStrings.STR_BUFF_H_TIME_H
		else
			szText = szText..nM..g_tStrings.STR_BUFF_H_TIME_M
		end
	end
	
	return szText
end

function CraftReadManagePanel.UpdateExperience(frame, nSortID)
	local player = GetClientPlayer()
	
	local nLevel     = player.GetProfessionLevel(8)
	local nMaxLevel  = player.GetProfessionMaxLevel(8)
	local nExp       = player.GetProfessionProficiency(8)
	local nMaxExp    = GetProfession(8).GetLevelProficiency(nLevel)
	
	local handle     = frame:Lookup("", "")
	local textTitle	 = handle:Lookup("Text_ReadExp")
	local textExp  	 = handle:Lookup("Text_ReadExpValue")
	local imageExp   = handle:Lookup("Image_ReadExp")


	--textTitle:SetText(FormatString(g_tStrings.CRAFT_READING_WHAT_LEVEL, nLevel))
	textTitle:SetText(g_tStrings.CRAFT_READING.."("..nLevel..g_tStrings.STR_LEVEL.." / "..nMaxLevel..g_tStrings.STR_LEVEL..")")
	textTitle:SetFontScheme(162)
	
	textExp:SetText(nExp.."/"..nMaxExp)
	textExp:SetFontScheme(162)
	imageExp:SetPercentage(nExp / nMaxExp)

	if not nSortID and CraftReadManagePanel.nSortID ~= -1 then
		nSortID = CraftReadManagePanel.nSortID
	end
	
	nLevel 	   = player.GetProfessionLevel(8 + nSortID)
	nMaxLevel  = player.GetProfessionMaxLevel(8 + nSortID)
	nExp 	   = player.GetProfessionProficiency(8 + nSortID)
	nMaxExp    = GetProfession(8 + nSortID).GetLevelProficiency(nLevel)
	
	textTitle  = handle:Lookup("Text_SubExp")
	textExp    = handle:Lookup("Text_SubExpValue")
	imageExp   = handle:Lookup("Image_SubExp")

	--textTitle:SetText(g_tStrings.STR_CRAFT_READ_BOOK_SORT_NAME_TABLE[nSortID].."("..FormatString(g_tStrings.STR_FRIEND_WTHAT_LEVEL, nLevel)..")")
	textTitle:SetText(g_tStrings.STR_CRAFT_READ_BOOK_SORT_NAME_TABLE[nSortID].."("..nLevel..g_tStrings.STR_LEVEL.." / "..nMaxLevel..g_tStrings.STR_LEVEL..")")
	textTitle:SetFontScheme(162)
	
	textExp:SetText(nExp.."/"..nMaxExp)
	textExp:SetFontScheme(162)
	imageExp:SetPercentage(nExp / nMaxExp)
end

function CraftReadManagePanel.UpdateList(frame)
	local player = GetClientPlayer()
	local szIniFile = "UI/Config/Default/CraftReadManagePanel.ini"
	local hBook = frame:Lookup("", "Handle_Book")
	local tBook = player.GetBookList()
	local bExist = false
	local bSel   = false
	local nNeedSubSortID, nMinLevel, nMaxLevel, nNeedBind, bCanTrade = CraftReadManagePanel.GetFilterValue(frame)
	
	hBook:Clear()
	for i, nBookID in pairs(tBook) do
		local nSortID = Table_GetBookSort(nBookID, 1)
		local nSubSortID = Table_GetBookSubSort(nBookID, 1)
		local nVersion, nTabtype = GLOBAL.CURRENT_ITEM_VERSION, 5
		
		if CraftReadManagePanel.nSortID == nSortID and (nNeedSubSortID == -1 or nNeedSubSortID == nSubSortID) then 
			local tSegmentBook = player.GetBookSegmentList(nBookID)
			local nBookNum = Table_GetBookNumber(nBookID, 1)
			local bFirst = true
			
			local aRead = {}
			for k, nID in pairs(tSegmentBook) do
				aRead[nID] = true
			end
			
			for nSegmentID = 1, nBookNum, 1 do
				local CopyRecipe   = GetRecipe(12, nBookID, nSegmentID)
				if CopyRecipe then
					local nReLevel = CopyRecipe.dwRequireProfessionLevel		
					local itemInfo = GetItemInfo(CopyRecipe.dwCreateItemType, CopyRecipe.dwCreateItemIndex)
			
					local bCan = false
					if (itemInfo.bCanTrade and bCanTrade) or (not itemInfo.bCanTrade and not bCanTrade) then
						bCan = true
					end
					
					if (nMinLevel == -1 or (nReLevel >= nMinLevel and nReLevel <= nMaxLevel)) and
					   (nNeedBind == -1 or (nNeedBind == itemInfo.nBindType and bCan)) then
						if bFirst and not CraftReadManagePanel.bIsSearch then
							local hItem = hBook:AppendItemFromIni(szIniFile, "TreeLeaf_Name")
							hItem.bTitle = true
							
							local szName = Table_GetBookName(nBookID, 1)
							hItem.szName = szName
								
							local nHaveNum = #tSegmentBook
							hItem:Lookup("Text_Name"):SetText(szName.."("..nHaveNum.."/"..nBookNum..")")
							if CraftReadManagePanel.tExpand[szName] then
								hItem:Expand()
							end
							bFirst = false
						end
						local szName = Table_GetSegmentName(nBookID, nSegmentID)
						local szItemName = "TreeLeaf_Page"
			
						local nPos = 1
						if CraftReadManagePanel.bIsSearch then
							szItemName = "TreeLeaf_Search"
							nPos = StringFindW(szName, CraftReadManagePanel.szSearchKey or "")
							if nPos then
								bExist = true
							end
						end
						
						if nPos then
							local hItem = hBook:AppendItemFromIni(szIniFile, szItemName)
							local nR, nG, nB = GetItemFontColorByQuality(itemInfo.nQuality, false)
							hItem.bItem = true
							hItem.bRead = aRead[nSegmentID]
							
							if CraftReadManagePanel.bIsSearch then
								hItem:SetName("TreeLeaf_Page")
								hItem:Lookup("Text_PageS"):SetName("Text_Page")
								hItem:Lookup("Image_PageS"):SetName("Image_Page")
							end
							
							hItem.nBookID = nBookID
							hItem.nSegmentID = nSegmentID
							hItem:Lookup("Text_Page"):SetText(szName)
							if hItem.bRead then
								hItem:Lookup("Text_Page"):SetFontScheme(162)
								hItem:Lookup("Text_Page"):SetFontColor(nR, nG, nB)
							else
								hItem:Lookup("Text_Page"):SetFontScheme(109)
							end
							
							if nBookID == CraftReadManagePanel.nBookID and nSegmentID == CraftReadManagePanel.nSegmentID then
								CraftReadManagePanel.Selected(frame, hItem)
								CraftReadManagePanel.UpdateCondition(frame)
								bSel = true
							end
						end
					end
				else
					Trace("KLUA[ERROR] ui/Config/Default/CraftReadManagePanel.lua  the reuturn value of GetRecipe(12, "..nBookID..", "..nSegmentID..") is nil!!\n")
				end
			end
		end
	end
	
	if not bSel then
		CraftReadManagePanel.Selected(frame, nil)
	end
	
	if CraftReadManagePanel.bIsSearch and not bExist then
		hBook:AppendItemFromIni(szIniFile, "TreeLeaf_Search")
		local hItem = hBook:Lookup(hBook:GetItemCount() - 1)
		
		hItem:Lookup("Text_PageS"):SetText(g_tStrings.STR_MSG_NOT_FIND_LIST)
		hItem:Lookup("Text_PageS"):SetFontScheme(162)
		hItem:Lookup("Image_PageS"):Hide()
	end
	
	hBook:Show()
	hBook:FormatAllItemPos()
	
	CraftReadManagePanel.OnUpdateScorllList(hBook)
end

function CraftReadManagePanel.OnUpdateScorllList(hBook)
	local frame = hBook:GetRoot()
	local scroll = frame:Lookup("Scroll_List")
	local w, h = hBook:GetSize()
	local wAll, hAll = hBook:GetAllItemSize()
	local nStepCount = math.ceil((hAll - h) / 10)
	
	scroll:SetStepCount(nStepCount)
	if nStepCount > 0 then
		scroll:Show()
		frame:Lookup("Btn_Up"):Show()
		frame:Lookup("Btn_Down"):Show()
	else
		scroll:Hide()
		frame:Lookup("Btn_Up"):Hide()
		frame:Lookup("Btn_Down"):Hide()
	end
end

function CraftReadManagePanel.OnScrollBarPosChanged()
	local frame = this:GetRoot()
	local nCurrentValue = this:GetScrollPos()
	local szName = this:GetName()
	
	if szName == "Scroll_List" then
		if nCurrentValue == 0 then
			frame:Lookup("Btn_Up"):Enable(false)
		else
			frame:Lookup("Btn_Up"):Enable(true)
		end
		
		if nCurrentValue == this:GetStepCount() then
			frame:Lookup("Btn_Down"):Enable(false)
		else
			frame:Lookup("Btn_Down"):Enable(true)
		end	
		frame:Lookup("", "Handle_Book"):SetItemStartRelPos(0, -nCurrentValue * 10)
	end
end

function CraftReadManagePanel.ChangeCheckBox(frame, nSortID)
	--if CraftReadManagePanel.nSortID == nSortID then
	--	return
	--end
	frame.bDisableSound = true
	
	local szKey = frame:Lookup("Edit_Search"):GetText()
	if not szKey or szKey == "" then
		CraftReadManagePanel.bIsSearch = false
	end
	
	CraftReadManagePanel.nSortID = nSortID
	CraftReadManagePanel.bCoolDown = false
	 
	CraftReadManagePanel.UpdateExperience(frame, nSortID)
	CraftReadManagePanel.UpdateList(frame)
		
    for i = 1, 3, 1 do
    	frame:Lookup("CheckBox_S"..i):Check(nSortID == i)
    end
   	
   	if nSortID == 1 or nSortID == 2 then
   		FireDataAnalysisEvent("FIRST_READ_SELECT_MORAL_OR_BUDDHISM")
   	end
    frame.bDisableSound = false
end

function CraftReadManagePanel.OnCheckBoxCheck()
	local frame = this:GetRoot()
	
	if not frame.bDisableSound then
		PlaySound(SOUND.UI_SOUND, g_sound.OpenFrame)
	end
	frame.bDisableSound = true
	
	local szName = this:GetName()

	for i = 1, 3, 1 do
		if szName == "CheckBox_S"..i then
			CraftReadManagePanel.ChangeCheckBox(frame, i)
			break
		end
	end
	
	frame.bDisableSound = false
end

function CraftReadManagePanel.PopupMenu(btn, text, tData)
	if btn.bIgnor then
		btn.bIgnor = nil
		return
	end
	
	local xT, yT = text:GetAbsPos()
	local wT, hT = text:GetSize()
	local menu = 
	{
		nMiniWidth = wT,
		x = xT, y = yT + hT,
		fnCancelAction = function() 
			if btn:IsValid() then
				local x, y = Cursor.GetPos()
				local xA, yA = btn:GetAbsPos()
				local w, h = btn:GetSize()
				if x >= xA and x < xA + w and y >= yA and y <= yA + h then
					btn.bIgnor = true
				end
			end
		end,
		fnAction = function(UserData)
			if text:IsValid() then
				text:SetText(UserData)
				CraftReadManagePanel.UpdateList(text:GetRoot())
				
				FireDataAnalysisEvent("FIRST_READ_FILTER")
			end
		end,
		fnAutoClose = function() return not IsCraftReadManagePanelOpened() end,
	}
	for k, v in pairs(tData) do
		table.insert(menu, {szOption = v, UserData = v})
	end
	PopupMenu(menu)
end

function  CraftReadManagePanel.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_Close" then
		CloseCraftReadManagePanel(this:GetRoot().bDisableSound)
	elseif szName == "Btn_Read" then
		assert(CraftReadManagePanel.nBookID ~= -1 and CraftReadManagePanel.nSegmentID ~= -1)
		OpenCraftReaderPanel(CraftReadManagePanel.nBookID, CraftReadManagePanel.nSegmentID, 0, 0, false)
	elseif szName == "Btn_Copy" then
		GetClientPlayer().CastProfessionSkill(12, CraftReadManagePanel.nBookID, CraftReadManagePanel.nSegmentID)
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
		CraftReadManagePanel.PopupMenu(this, text, tData)
	elseif szName == "Btn_Level" then
		local tData = {}
		for k, v in pairs(g_tStrings.tBookLevel) do
			table.insert(tData, k)
		end
		table.sort(tData)
		table.insert(tData, 1, g_tStrings.STR_BOOK_ALL_LEVEL)
		
		local text = this:GetParent():Lookup("", "Text_Level")
		CraftReadManagePanel.PopupMenu(this, text, tData)
	elseif szName == "Btn_Kind" then
		local tData = {}
		for k, v in pairs(g_tStrings.tBookBind) do
			table.insert(tData, k)
		end
		function Cmp(a, b)
			return g_tStrings.tBookBind[a].nBindType <= g_tStrings.tBookBind[b].nBindType
		end
		table.sort(tData, Cmp)
		table.insert(tData, 1, g_tStrings.STR_BOOK_ALL_STATUS)
		
		local text = this:GetParent():Lookup("", "Text_Kind")
		CraftReadManagePanel.PopupMenu(this, text, tData)
	end
end

function CraftReadManagePanel.OnSearch(frame)
	local szKey = frame:Lookup("Edit_Search"):GetText()
	if not szKey or szKey == "" then
		if CraftReadManagePanel.bIsSearch then
			CraftReadManagePanel.bIsSearch = false
			CraftReadManagePanel.Selected(frame, nil)
			CraftReadManagePanel.UpdateList(frame)
		end
	else
		CraftReadManagePanel.bIsSearch = true
		CraftReadManagePanel.Selected(frame, nil)
		CraftReadManagePanel.szSearchKey = szKey
		CraftReadManagePanel.UpdateList(frame)
		FireDataAnalysisEvent("FIRST_READ_SEARCH")
	end
end

function CraftReadManagePanel.OnEditChanged()
	local szName = this:GetName()
	if szName == "Edit_Search" then
		CraftReadManagePanel.OnSearch(this:GetRoot())
	end
end

function CraftReadManagePanel.OnSetFocus()
	local szName = this:GetName()
	if szName == "Edit_Search" then
		this:SelectAll()
	end
end

function CraftReadManagePanel.OnKillFocus()
	local szName = this:GetName()
	if szName == "Edit_Search" then
	end	
end

function CraftReadManagePanel.OnLButtonHold()
	local szName = this:GetName()
	if szName == "Btn_Up" then
		this:GetRoot():Lookup("Scroll_List"):ScrollPrev(1)
	elseif szName == "Btn_Down" then
		this:GetRoot():Lookup("Scroll_List"):ScrollNext(1)	
    end
end

function CraftReadManagePanel.OnLButtonDown()
	CraftReadManagePanel.OnLButtonHold()
end

function CraftReadManagePanel.OnItemMouseWheel()
	local nDistance = Station.GetMessageWheelDelta()
	this:GetRoot():Lookup("Scroll_List"):ScrollNext(nDistance)
	return true
end

function CraftReadManagePanel.OnItemLButtonDown()
	local frame = this:GetRoot()
	if this.bTitle then
		CraftReadManagePanel.tExpand[this.szName] = not CraftReadManagePanel.tExpand[this.szName]
		this:ExpandOrCollapse()
		
		this:GetParent():FormatAllItemPos()
		CraftReadManagePanel.OnUpdateScorllList(frame:Lookup("", "Handle_Book"))
		PlaySound(SOUND.UI_SOUND,g_sound.Button)
	elseif this.bItem then
		if IsCtrlKeyDown() then
			local nBookInfo = BookID2GlobelRecipeID(this.nBookID, this.nSegmentID)
			EditBox_AppendLinkBook(nBookInfo)
		else
			CraftReadManagePanel.Selected(frame, this)
			CraftReadManagePanel.UpdateCondition(frame)
		end
	end
end

function CraftReadManagePanel.OnItemMouseEnter()
	if this.bItem then
		this.bOver = true
		CraftReadManagePanel.UpdateBgStatus(this)
						
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
		OutputBookTipByID(this.nBookID, this.nSegmentID, {x, y, w, h})
	end
end

function CraftReadManagePanel.OnItemMouseLeave()
	if this.bItem then
		this.bOver = false
		CraftReadManagePanel.UpdateBgStatus(this)
	
		HideTip()
	end
end

function OpenCraftReadManagePanel(bDisableSound)
	if IsOptionOrOptionChildPanelOpened() then
		return
	end

	if not IsCraftReadManagePanelOpened() then
		Wnd.OpenWindow("CraftReadManagePanel")
		if not bDisableSound then
			PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
		end
	end
end

function CloseCraftReadManagePanel(bDisableSound)
	if IsCraftReadManagePanelOpened() then
		Wnd.CloseWindow("CraftReadManagePanel")
		if not bDisableSound then
			PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
		end
	end
end

function IsCraftReadManagePanelOpened()
	local frame = Station.Lookup("Normal/CraftReadManagePanel")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end
