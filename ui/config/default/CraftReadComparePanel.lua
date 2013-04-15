CraftReadComparePanel = 
{
	nPlayerID = -1,
	nSortID   = -1, 
	bCoolDown  = false,
	bIsSearch  = false,
	
	tSelectBook = {nBookID = -1, nSegmentID = -1, bRead = false},
	tFilter = 
	{
		 szType = g_tStrings.STR_BOOK_ALL_TYPE, 
		 szLevel = g_tStrings.STR_BOOK_ALL_LEVEL, 
		 szBind = g_tStrings.STR_BOOK_ALL_STATUS,
	},
	tExpand = {},
}

function CraftReadComparePanel.OnFrameCreate()
	this:RegisterEvent("UI_SCALED")
	this:RegisterEvent("UPDATE_BOOK_STATE")
	this:RegisterEvent("SYS_MSG")
	this:RegisterEvent("BAG_ITEM_UPDATE")
	this:RegisterEvent("SYNC_ROLE_DATA_END")
	CraftReadComparePanel.Init(this)
	
	InitFrameAutoPosInfo(this, 1, nil, nil, function() CloseCraftReadComparePanel(true) end)
end

function CraftReadComparePanel.OnFrameBreathe()
	if CraftReadComparePanel.bCoolDown then
		local recipe  = GetRecipe(12, CraftReadComparePanel.tSelectBook.nBookID, CraftReadComparePanel.tSelectBook.nSegmentID)
		if recipe.dwCoolDownID > 0 then
			local hThew = this:Lookup("", "Handle_Thew")
			if hThew.szTime then
				local CDRemainTime = GetClientPlayer().GetCDLeft(recipe.dwCoolDownID)
				local szNTime = ForamtCoolDownTime(CDRemainTime)
				
				if hThew.szTime ~= szNTime then
					CraftReadComparePanel.UpdateCondition(this)
				end
			end
		end
	end
end

function CraftReadComparePanel.OnEvent(event)
	if event == "UPDATE_BOOK_STATE" then
		--CraftReadComparePanel.UpdateList(this:GetRoot())
	elseif event == "UI_SCALED" then

	elseif event == "BAG_ITEM_UPDATE" or event == "PLAYER_LEVEL_UPDATE" then
		if CraftReadComparePanel.tSelectBook.nBookID ~= -1 and CraftReadComparePanel.tSelectBook.nSegmentID ~= -1 then
			CraftReadComparePanel.UpdateCondition(this:GetRoot())
		end
	elseif event == "SYS_MSG" then
		
		if arg0 == "UI_OME_ADD_PROFESSION_PROFICIENCY" then
			if CraftReadComparePanel.tSelectBook.nBookID ~= -1 and CraftReadComparePanel.tSelectBook.nSegmentID ~= -1 then
				CraftReadComparePanel.UpdateCondition(this:GetRoot())
			end
		elseif arg0 == "UI_OME_CRAFT_RESPOND" then
			if arg1 == CRAFT_RESULT_CODE.SUCCESS then
				if CraftReadComparePanel.tSelectBook.nBookID ~= -1 and CraftReadComparePanel.tSelectBook.nSegmentID ~= -1 then
					CraftReadComparePanel.UpdateCondition(this:GetRoot())
				end
			end
		end
	elseif event == "SYNC_ROLE_DATA_END" then
		--CraftReadComparePanel.UpdateList(this:GetRoot())
	end
end
function CraftReadComparePanel.Init(frame)
	CraftReadComparePanel.bIsSearch = false
	CraftReadComparePanel.bCoolDown = false
	CraftReadComparePanel.tExpand = {}
	
	CraftReadComparePanel.tFilter.szType = g_tStrings.STR_BOOK_ALL_TYPE
	CraftReadComparePanel.tFilter.szLevel = g_tStrings.STR_BOOK_ALL_LEVEL
	CraftReadComparePanel.tFilter.szBind = g_tStrings.STR_BOOK_ALL_STATUS
	
	local playerT = GetPlayer(CraftReadComparePanel.nPlayerID)  
	frame:Lookup("", "Text_Player"):SetText(playerT.szName)
	
	
	CraftReadComparePanel.Selected(frame, nil)
	CraftReadComparePanel.UpdateFilterValue(frame)
	CraftReadComparePanel.ChangeCheckBox(frame, 3)
end

function CraftReadComparePanel.OnCheckBoxCheck()
	local frame = this:GetRoot()
	
	if not frame.bDisableSound then
		PlaySound(SOUND.UI_SOUND, g_sound.OpenFrame)
	end
	frame.bDisableSound = true
	
	local szName = this:GetName()

	for i = 1, 3, 1 do
		if szName == "CheckBox_S"..i then
			CraftReadComparePanel.ChangeCheckBox(frame, i)
			break
		end
	end
	
	frame.bDisableSound = false
end

function CraftReadComparePanel.ChangeCheckBox(frame, nSortID)
	frame.bDisableSound = true
	
	local szKey = frame:Lookup("Edit_Search"):GetText()
	if not szKey or szKey == "" then
		CraftReadComparePanel.bIsSearch = false
	end
	CraftReadComparePanel.nSortID = nSortID
	CraftReadComparePanel.bCoolDown = false
	 
	--CraftReadComparePanel.UpdateExperience(frame, nSortID)
	CraftReadComparePanel.UpdateList(frame)
		
    for i = 1, 3, 1 do
    	frame:Lookup("CheckBox_S"..i):Check(nSortID == i)
    end
   	
    frame.bDisableSound = false
end

function CraftReadComparePanel.UpdateFilterValue(frame, bSave)
	local handle = frame:Lookup("", "")
	local textT = handle:Lookup("Text_Type")
	local textL = handle:Lookup("Text_Level")
	local textB = handle:Lookup("Text_Kind")
	
	if bSave then
		CraftReadComparePanel.tFilter.szType = textT:GetText()
		CraftReadComparePanel.tFilter.szLevel = textL:GetText()
		CraftReadComparePanel.tFilter.szBind = textB:GetText()
	end
	local tFilter = CraftReadComparePanel.tFilter
	
	textT:SetText(tFilter.szType)
	textL:SetText(tFilter.szLevel)
	textB:SetText(tFilter.szBind)
end

function CraftReadComparePanel.GetFilterValue(frame)
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
	
	CraftReadComparePanel.UpdateFilterValue(frame, true)
	return nSubSort, nMinLevel, nMaxLevel, nBindType, bCanTrade
end

function CraftReadComparePanel.UpdateList(frame)
	local playerC  = GetClientPlayer()
	local playerT = GetPlayer(CraftReadComparePanel.nPlayerID) 
	
	if not playerT then
		return
	end
	
	local bExist = false
	local bSel   = false
	
	local szIniFile = "UI/Config/Default/CraftReadComparePanel.ini"
	local hBook = frame:Lookup("", "Handle_Book")
	local tBookC = playerC.GetBookList()
	local tBookT = playerT.GetBookList()
	
	local tBookTot = {}
	local tFlag = {}
	for i, nBookID in pairs(tBookC) do
		if not tFlag[nBookID] then
			tFlag[nBookID] = true
			table.insert(tBookTot, nBookID)
		end
	end

	for i, nBookID in pairs(tBookT) do
		if not tFlag[nBookID] then
			tFlag[nBookID] = true
			table.insert(tBookTot, nBookID)
		end
	end
	function Cmp(a, b)
		return a < b
	end
	table.sort(tBookTot, Cmp)
	
	local nVersion, nTabtype = GLOBAL.CURRENT_ITEM_VERSION, 5
	local nNeedSubID, nMinLevel, nMaxLevel, nBindType, bCanTrade = CraftReadComparePanel.GetFilterValue(frame)
	hBook:Clear()
	for i, nBookID in pairs(tBookTot) do
		local nSortID = Table_GetBookSort(nBookID, 1)
		local nSubID = Table_GetBookSubSort(nBookID, 1)
		
		if CraftReadComparePanel.nSortID == nSortID and (nNeedSubID == -1 or nNeedSubID == nSubID) then
			local tSegmentBookC = playerC.GetBookSegmentList(nBookID)
			local tSegmentBookT = playerT.GetBookSegmentList(nBookID) 
			local nBookNum = Table_GetBookNumber(nBookID, 1)
			local bFirst = true
			
			local tReadC = {}
			local tReadT = {}
			for k, nID in pairs(tSegmentBookC) do
				tReadC[nID] = true
			end
			
			for k, nID in pairs(tSegmentBookT) do
				tReadT[nID] = true
			end	
			
			local bFirst = true
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
						(nBindType == -1 or (nBindType == itemInfo.nBindType and bCan)) then
						if bFirst and not CraftReadComparePanel.bIsSearch then
							local hItem = hBook:AppendItemFromIni(szIniFile, "TreeLeaf_Name")
							hItem.bTitle = true
							
							local szName = Table_GetBookName(nBookID, 1)
							hItem.szName = szName
								
							local nHaveNum = #tSegmentBookC
								
							hItem:Lookup("Text_Name"):SetText(szName.."("..nHaveNum.."/"..nBookNum..")")
							if CraftReadComparePanel.tExpand[szName] then
								hItem:Expand()
							end
							bFirst = false
						end
						
						local szName = Table_GetSegmentName(nBookID, nSegmentID)
						local szItemName = "TreeLeaf_Page"
			
						local nPos = 1
						if CraftReadComparePanel.bIsSearch then
							szItemName = "TreeLeaf_Search"
							nPos = StringFindW(szName, CraftReadComparePanel.szSearchKey or "")
							if nPos then
								bExist = true
							end
						end
						
						if nPos then
							local hItem = hBook:AppendItemFromIni(szIniFile, szItemName)
							local nR, nG, nB = GetItemFontColorByQuality(itemInfo.nQuality, false)
							hItem.bItem = true
							hItem.bRead = tReadC[nSegmentID]
							
							if CraftReadComparePanel.bIsSearch then
								hItem:SetName("TreeLeaf_Page")
								hItem:Lookup("Text_PageS"):SetName("Text_Page")
								hItem:Lookup("Image_PageS"):SetName("Image_Page")
								hItem:Lookup("Image_Book3"):SetName("Image_Book1")
								hItem:Lookup("Image_Book4"):SetName("Image_Book2")
							end
							
							hItem.nBookID = nBookID
							hItem.nSegmentID = nSegmentID
							hItem:Lookup("Text_Page"):SetText(szName)
							hItem:Lookup("Text_Page"):SetFontScheme(162)
							hItem:Lookup("Text_Page"):SetFontColor(nR, nG, nB)
							
							if tReadC[nSegmentID] then
								hItem:Lookup("Image_Book2"):Show()
							end
							
							if tReadT[nSegmentID] then
								hItem:Lookup("Image_Book1"):Show()
							end
							local tSelect = CraftReadComparePanel.tSelectBook
							if nBookID == tSelect.nBookID and nSegmentID == tSelect.nSegmentID then
								CraftReadComparePanel.Selected(frame, hItem)
								CraftReadComparePanel.UpdateCondition(frame)
								bSel = true
							end
						end
					end
				else
					Trace("KLUA[ERROR] ui/Config/Default/CraftReadComparePanel.lua  the reuturn value of GetRecipe(12, "..nBookID..", "..nSegmentID..") is nil!!\n")
				end
			end
		end
	end
	
	if not bSel then
		CraftReadComparePanel.Selected(frame, nil)
	end
	
	if CraftReadComparePanel.bIsSearch and not bExist then
		hBook:AppendItemFromIni(szIniFile, "TreeLeaf_Search")
		local hItem = hBook:Lookup(hBook:GetItemCount() - 1)
		
		hItem:Lookup("Text_PageS"):SetText(g_tStrings.STR_MSG_NOT_FIND_LIST)
		hItem:Lookup("Text_PageS"):SetFontScheme(162)
		hItem:Lookup("Image_PageS"):Hide()
	end
	
	hBook:Show()
	CraftReadComparePanel.OnUpdateScorllList(hBook)
end

function CraftReadComparePanel.OnUpdateScorllList(hBook)
	hBook:FormatAllItemPos()
	
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

function CraftReadComparePanel.OnScrollBarPosChanged()
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

function CraftReadComparePanel.UpdateCondition(frame)
	local handle  = frame:Lookup("", "")
	local hLvCost = handle:Lookup("Handle_LvCost")
	local hThew   = handle:Lookup("Handle_Thew")
	local hTool   = handle:Lookup("Handle_Cost")	
	local recipe  = GetRecipe(12, CraftReadComparePanel.tSelectBook.nBookID, CraftReadComparePanel.tSelectBook.nSegmentID)
	local player  = GetClientPlayer()
	local bCanCopy = true
	
	hLvCost:Clear()
	hThew:Clear()
	hTool:Clear()
	
	CraftReadComparePanel.bCoolDown = false
	hThew.szTime = nil
	
	local szLvCost = ""
	local szThew   = ""
	local szTool   = ""
	
	if not recipe then
		bCanCopy = false
		szLvCost = szLvCost.."<text>text="..EncodeComponentsString(g_tStrings.CRAFT_READING_CANNOT_COPY).." font=162 </text>"
	else
		local nTabtype = 5
		local nIndex = Table_GetBookItemIndex(CraftReadComparePanel.tSelectBook.nBookID, CraftReadComparePanel.tSelectBook.nSegmentID)
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
			CraftReadComparePanel.bCoolDown = true
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
			local szToolName = GetItemNameByItemInfo(itemTool)
			local nToolCount = player.GetItemAmount(recipe.dwToolItemType, recipe.dwToolItemIndex)
			
			szTool = szTool.."<text>text="..EncodeComponentsString(g_tStrings.CRAFT_NEED_TOOL).." font=162 </text>"
			nFont  = 162
			if nToolCount <= 0 then
				nFont = 102
				bCanCopy = false
			end
			szTool = szTool.."<text>text="..EncodeComponentsString(szToolName .." ").." font="..nFont.." </text>"
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
	
	if not CraftReadComparePanel.tSelectBook.bRead then
		bCanCopy = false
	end
	frame:Lookup("Btn_Copy"):Enable(bCanCopy)
end

function CraftReadComparePanel.UpdateExperience(frame, nSortID)
	Trace(CraftReadComparePanel.nPlayerID.." CraftReadComparePanel.nPlayerID\n")
	local playerT = GetPlayer(CraftReadComparePanel.nPlayerID)
	
	local nLevel     = playerT.GetProfessionLevel(8)
	local nMaxLevel  = playerT.GetProfessionMaxLevel(8)
	local nExp       = playerT.GetProfessionProficiency(8)
	local nMaxExp    = GetProfession(8).GetLevelProficiency(nLevel)
	
	local handle     = frame:Lookup("", "")
	local textTitle	 = handle:Lookup("Text_ReadExp")
	local textExp  	 = handle:Lookup("Text_ReadExpValue")
	local imageExp   = handle:Lookup("Image_ReadExp")
	
	textTitle:SetText(g_tStrings.CRAFT_READING.."("..nLevel..g_tStrings.STR_LEVEL.." / "..nMaxLevel..g_tStrings.STR_LEVEL..")")
	textTitle:SetFontScheme(162)
	
	textExp:SetText(nExp.."/"..nMaxExp)
	textExp:SetFontScheme(162)
	imageExp:SetPercentage(nExp / nMaxExp)

	if not nSortID and CraftReadComparePanel.nSortID ~= -1 then
		nSortID = CraftReadComparePanel.nSortID
	end
	
	nLevel 	   = playerT.GetProfessionLevel(8 + nSortID)
	nMaxLevel  = playerT.GetProfessionMaxLevel(8 + nSortID)
	nExp 	   = playerT.GetProfessionProficiency(8 + nSortID)
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

function CraftReadComparePanel.UpdateBgStatus(hItem)
	if not hItem then
		Trace("KLUA[ERROR] ui\config\default\CraftReadComparePanel.lua UpdateBgStatus(hItem) hitem is nil\n")
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
			
function CraftReadComparePanel.Selected(frame, hItem)
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
		CraftReadComparePanel.tSelectBook.nBookID    = hItem.nBookID
		CraftReadComparePanel.tSelectBook.nSegmentID = hItem.nSegmentID
		CraftReadComparePanel.tSelectBook.bRead      = hItem.bRead
		CraftReadComparePanel.UpdateBgStatus(hItem)
	else
		CraftReadComparePanel.bCoolDown = false
		CraftReadComparePanel.tSelectBook.nBookID    = -1
		CraftReadComparePanel.tSelectBook.nSegmentID = -1
		
		frame:Lookup("Btn_Copy"):Enable(false)
		frame:Lookup("", "Handle_LvCost"):Hide()
		frame:Lookup("", "Handle_Thew"):Hide()
		frame:Lookup("", "Handle_Cost"):Hide()
	end
end

function CraftReadComparePanel.PopupMenu(hBtn, text, tData)
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
				CraftReadComparePanel.UpdateList(text:GetRoot())
			end
		end,
		fnAutoClose = function() return not IsCraftReadComparePanelOpened() end,
	}
	for k, v in pairs(tData) do
		table.insert(menu, {szOption = v, UserData = v})
	end
	PopupMenu(menu)
end

function CraftReadComparePanel.OnItemMouseEnter()
	if this.bItem then
		this.bOver = true
		CraftReadComparePanel.UpdateBgStatus(this)
						
		local ID = this:GetIndex()
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
		OutputBookTipByID(this.nBookID, this.nSegmentID, {x, y, w, h})
	end
end

function CraftReadComparePanel.OnItemMouseLeave()
	if this.bItem then
		this.bOver = false
		CraftReadComparePanel.UpdateBgStatus(this)
	
		HideTip()
	end
end

function CraftReadComparePanel.OnItemLButtonDown()
	local frame = this:GetRoot()
	if this.bTitle then
		CraftReadComparePanel.tExpand[this.szName] = not CraftReadComparePanel.tExpand[this.szName]
		this:ExpandOrCollapse()
		
		this:GetParent():FormatAllItemPos()
		CraftReadComparePanel.OnUpdateScorllList(frame:Lookup("", "Handle_Book"))
		PlaySound(SOUND.UI_SOUND,g_sound.Button)
	elseif this.bItem then
		if IsCtrlKeyDown() then
			local nBookInfo = BookID2GlobelRecipeID(this.nBookID, this.nSegmentID)
			EditBox_AppendLinkBook(nBookInfo)
		else
			CraftReadComparePanel.Selected(frame, this)
			CraftReadComparePanel.UpdateCondition(frame)
		end
	end
end

function CraftReadComparePanel.OnItemMouseWheel()
	local nDistance = Station.GetMessageWheelDelta()
	this:GetRoot():Lookup("Scroll_List"):ScrollNext(nDistance)
	return true
end

function CraftReadComparePanel.OnLButtonHold()
	local szName = this:GetName()
	if szName == "Btn_Up" then
		this:GetRoot():Lookup("Scroll_List"):ScrollPrev(1)
	elseif szName == "Btn_Down" then
		this:GetRoot():Lookup("Scroll_List"):ScrollNext(1)	
    end
end

function CraftReadComparePanel.OnLButtonDown()
	CraftReadComparePanel.OnLButtonHold()
end

function  CraftReadComparePanel.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_Close" then
		CloseCraftReadComparePanel(this:GetRoot().bDisableSound)
	elseif szName == "Btn_Copy" then
		GetClientPlayer().CastProfessionSkill(12, CraftReadComparePanel.tSelectBook.nBookID, CraftReadComparePanel.tSelectBook.nSegmentID)
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
		CraftReadComparePanel.PopupMenu(this, text, tData)
	elseif szName == "Btn_Level" then
		local tData = {}
		for k, v in pairs(g_tStrings.tBookLevel) do
			table.insert(tData, k)
		end
		table.sort(tData)
		table.insert(tData, 1, g_tStrings.STR_BOOK_ALL_LEVEL)
		
		local text = this:GetParent():Lookup("", "Text_Level")
		CraftReadComparePanel.PopupMenu(this, text, tData)
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
		CraftReadComparePanel.PopupMenu(this, text, tData)
	end
end

function CraftReadComparePanel.OnSearch(frame)
	local szKey = frame:Lookup("Edit_Search"):GetText()
	if not szKey or szKey == "" then
		if CraftReadComparePanel.bIsSearch then
			CraftReadComparePanel.bIsSearch = false
			CraftReadComparePanel.Selected(frame, nil)
			CraftReadComparePanel.UpdateList(frame)
		end
	else

		CraftReadComparePanel.bIsSearch = true
		CraftReadComparePanel.Selected(frame, nil)
		CraftReadComparePanel.szSearchKey = szKey
		CraftReadComparePanel.UpdateList(frame)
	end
end

function CraftReadComparePanel.OnEditChanged()
	local szName = this:GetName()
	if szName == "Edit_Search" then
		CraftReadComparePanel.OnSearch(this:GetRoot())
	end
end

function CraftReadComparePanel.OnSetFocus()
	local szName = this:GetName()
	if szName == "Edit_Search" then
		this:SelectAll()
	end
end

function CraftReadComparePanel.OnKillFocus()
	local szName = this:GetName()
	if szName == "Edit_Search" then
	end	
end

function OpenCraftReadComparePanel(nPlayerID, bDisableSound)
	if IsOptionOrOptionChildPanelOpened() then
		return
	end
	
	if IsCraftReadComparePanelOpened() and nPlayerID == CraftReadComparePanel.nPlayerID then
		return
	end
	
	CraftReadComparePanel.nPlayerID = nPlayerID
	
	local frame = nil
	if not IsCraftReadComparePanelOpened() then
		frame = Wnd.OpenWindow("CraftReadComparePanel")
		if not bDisableSound then
			PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
		end
	else
		frame = Station.Lookup("Normal/CraftReadComparePanel")
	end
	CraftReadComparePanel.Init(frame)
end

function CloseCraftReadComparePanel(bDisableSound)
	if IsCraftReadComparePanelOpened() then
		Wnd.CloseWindow("CraftReadComparePanel")
		if not bDisableSound then
			PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
		end
	end
end

function IsCraftReadComparePanelOpened()
	local frame = Station.Lookup("Normal/CraftReadComparePanel")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end
