CraftManagePanel = 
{
	nProfessionID = 0,
	nProfessionLevel = 0,
	
	nMakeCount    = 0,
	nMakeCraftID  = 0,
	nMakeRecipeID = 0,
	bIsMaking     = false,

	tSelected     = {},
	tMakeChecked  = {},
	bIsSearch     = false,
	tRecipe 	  = {},
	tExpand		  = {},
}

function CraftManagePanel.OnFrameCreate()
	this:RegisterEvent("OT_ACTION_PROGRESS_BREAK")
	this:RegisterEvent("PLAYER_LEVEL_UPDATE")
	this:RegisterEvent("PLAYER_EXPERIENCE_UPDATE")
	this:RegisterEvent("CRAFT_REMOVE")
	this:RegisterEvent("BAG_ITEM_UPDATE")
	this:RegisterEvent("SYS_MSG")
	this:RegisterEvent("SYNC_ROLE_DATA_END")
	
	InitFrameAutoPosInfo(this, 1, nil, nil, function() CloseCraftManagePanel(true) end)
end

function CraftManagePanel.OnFrameBreathe()
	if CraftManagePanel.bCoolDown then
		local nCurProID = CraftManagePanel.nProfessionID
		local nCurCraftID = CraftManagePanel.tSelected[nCurProID].nCraftID
		local nCurRecipeID = CraftManagePanel.tSelected[nCurProID].nRecipeID
		local recipe  = GetRecipe(nCurCraftID, nCurRecipeID)
		if not recipe then
			Trace(string.format("Error: GetRecipe(%d, %d) return nil", nCurCraftID, nCurRecipeID))
			return
		end
        
		if recipe.dwCoolDownID and recipe.dwCoolDownID > 0 and CraftManagePanel.szCoolDownTime then
			local CDRemainTime = GetClientPlayer().GetCDLeft(recipe.dwCoolDownID)
			local szNTime = CraftManagePanel.ForamtCoolDownTime(CDRemainTime)
			if szNTime ~= CraftManagePanel.szCoolDownTime then
				CraftManagePanel.UpdateContent(this)
			end
		end
	end
end


function CraftManagePanel.Init(frame, nProfessionID, nCraftID)
	local player = GetClientPlayer()
	if not player then
		return
	end
	
	CraftManagePanel.bIsSearch        = false
	CraftManagePanel.nProfessionID    = nProfessionID
	--CraftManagePanel.nCraftID         = nCraftID
	CraftManagePanel.nProfessionLevel = player.GetProfessionLevel(nProfessionID)
	
	--CraftManagePanel.nRecipeID      = 0
	--CraftManagePanel.nCurTotalCount = 0
	CraftManagePanel.bCoolDown = false
	
	CraftManagePanel.nMakeCount 	 = 0
	CraftManagePanel.nMakeCraftID  = 0
	CraftManagePanel.nMakeRecipeID = 0
	
	if CraftManagePanel.tMakeChecked[nProfessionID] then
		frame:Lookup("CheckBox_Make"):Check(true)
	else
		frame:Lookup("CheckBox_Make"):Check(false)
	end

	--CraftManagePanel.Selected(frame, nil)
	
	CraftManagePanel.UpdateRecipeTable()
	CraftManagePanel.UpdateTitle(frame)
	CraftManagePanel.UpdateList(frame)
end

function CraftManagePanel.OnEvent(event)
	local frame = this:GetRoot()
	if event == "OT_ACTION_PROGRESS_BREAK" then
		if GetClientPlayer().dwID == arg0 then
			CraftManagePanel.ClearMakeInfo(frame)
		end
	elseif event == "PLAYER_LEVEL_UPDATE" or event == "PLAYER_EXPERIENCE_UPDATE" then
		CraftManagePanel.UpdateInfo(frame)
	elseif event == "CRAFT_REMOVE" then
		CloseCraftManagePanel()
	elseif event == "BAG_ITEM_UPDATE" then
		CraftManagePanel.UpdateRecipeTable()
		CraftManagePanel.UpdateInfo(frame)
	elseif event == "SYS_MSG" then
		if arg0 == "UI_OME_LEARN_RECIPE" then
			if not CraftManagePanel.bIsSearch then
				CraftManagePanel.UpdateRecipeTable()
				CraftManagePanel.UpdateList(frame)
			end
		elseif arg0 == "UI_OME_ADD_PROFESSION_PROFICIENCY" then
			CraftManagePanel.UpdateTitle(frame)
		elseif arg0 == "UI_OME_PROFESSION_LEVEL_UP" then
			CraftManagePanel.UpdateRecipeTable()
			CraftManagePanel.UpdateInfo(frame)
		elseif arg0 == "UI_OME_CRAFT_RESPOND" then
			if arg1 == CRAFT_RESULT_CODE.SUCCESS then
				CraftManagePanel.nMakeCount = CraftManagePanel.nMakeCount - 1
				CraftManagePanel.UpdateRecipeTable()
				if CraftManagePanel.nMakeCount > 0 then
					CraftManagePanel.OnMakeRecipe(frame)
				else
					CraftManagePanel.ClearMakeInfo(frame)
					CraftManagePanel.UpdateList(frame)
				end
				CraftManagePanel.UpdateInfo(frame)
			else
				CraftManagePanel.ClearMakeInfo(frame)
			end
		elseif arg0 == "SYNC_ROLE_DATA_END" then
			CraftManagePanel.UpdateRecipeTable()
			CraftManagePanel.UpdateTitle(frame)
			CraftManagePanel.UpdateList(frame)
		end 
	end     
end

function CraftManagePanel.UpdateBgStatus(hItem)
	if not hItem then
		Trace("KLUA[ERROR] ui\config\default\CraftManagePanel.lua UpdateBgStatus(hItem) hitem is nil\n")
		return
	end
	
	local img  = hItem:Lookup("Image_Food")
	if not img then
		return
	end
	
	if hItem.bSel then
		local nFont, nFrame = CraftManagePanel.GetTextFontAndFrame(hItem.tInfo.nLevel)
		img:FromUITex("ui/Image/Common/TextShadow.UITex", nFrame)
		img:Show()
		img:SetAlpha(255)
	elseif hItem.bOver then
		local nFont, nFrame = CraftManagePanel.GetTextFontAndFrame(hItem.tInfo.nLevel)
		img:FromUITex("ui/Image/Common/TextShadow.UITex", nFrame)
		img:Show()
		img:SetAlpha(128)				
	else
		img:Hide()
	end
end
			
function CraftManagePanel.Selected(frame, hItem)
	local nProID = CraftManagePanel.nProfessionID
	if hItem then
		local hList = hItem:GetParent()
		local nCount = hList:GetItemCount() - 1
		for i = 0, nCount, 1 do
			local hI = hList:Lookup(i)
			if hI.bSel then
				hI.bSel = false
				local nFont, nFrame = CraftManagePanel.GetTextFontAndFrame(hI.tInfo.nLevel)
				hI:Lookup("Image_Food"):Hide()
				hI:Lookup("Text_FoodName"):SetFontScheme(nFont)
			end
		end
		
		hItem.bSel = true
		CraftManagePanel.tSelected[nProID] = {}
		CraftManagePanel.tSelected[nProID].nCraftID  = hItem.tInfo.nCraftID
		CraftManagePanel.tSelected[nProID].nRecipeID = hItem.tInfo.nRecipeID
		CraftManagePanel.tSelected[nProID].nCurTotalCount = hItem.tInfo.nTotalCount
		
		if hItem.tInfo.nTotalCount > 0 then
			frame:Lookup("Edit_Number"):SetText(1)
		else
			frame:Lookup("Edit_Number"):SetText(0)
		end
			
		CraftManagePanel.UpdateBgStatus(hItem)
	else
		if CraftManagePanel.tSelected[nProID] then
			CraftManagePanel.tSelected[nProID] = nil
		end
		
		frame:Lookup("Wnd_Content"):Hide()
		frame:Lookup("Btn_MakeAll"):Enable(false)
		frame:Lookup("Btn_Make"):Enable(false)
	end
	CraftManagePanel.UpdateMakeCount(frame)
end
			
function CraftManagePanel.TableSortCmp(a, b)
	if a.nBelongID == b.nBelongID then
		return a.nLevel > b.nLevel 
	else
		return a.nBelongID < b.nBelongID 
	end
end

function CraftManagePanel.GetRecipeTotalCount(recipe)
	local nTotalCount = 9999999
	
	for nIndex = 1, 6, 1 do
		if recipe["dwRequireItemCount"..nIndex] ~= 0 then
			local nCurrentCount = GetClientPlayer().GetItemAmount(recipe["dwRequireItemType"..nIndex], recipe["dwRequireItemIndex"..nIndex])
			local nCount = math.floor(nCurrentCount / recipe["dwRequireItemCount"..nIndex])
			
			if nCount < nTotalCount then
				nTotalCount = nCount
			end
		end
	end
	if nTotalCount == 9999999 then
		nTotalCount = 0
	end
	return nTotalCount
end

function CraftManagePanel.UpdateRecipeTable()
	local tProfession = GetClientPlayer().GetRecipe(CraftManagePanel.nProfessionID)
	
	local tRecipe = {}
	for i = 1, #tProfession, 1 do
		local recipe = GetRecipe(tProfession[i].CraftID, tProfession[i].RecipeID)
        if recipe then
            table.insert(tRecipe, 
                {
                    nCraftID    = tProfession[i].CraftID,
                    nRecipeID   = tProfession[i].RecipeID,
                    Recipe      = recipe,
                    szName      = Table_GetRecipeName(tProfession[i].CraftID, tProfession[i].RecipeID),
                    nBelongID	= tonumber(recipe.szBelong),
                    nLevel  	= recipe.dwRequireProfessionLevel,
                    nTotalCount = CraftManagePanel.GetRecipeTotalCount(recipe),
                }
            )
        else
            Trace(string.format("Error: GetRecipe(%d, %d) return nil", tProfession[i].CraftID, tProfession[i].RecipeID))
        end
	end
	table.sort(tRecipe, CraftManagePanel.TableSortCmp)

	CraftManagePanel.tRecipe = {}
	local nIndex = 1
	local nMainID = 1
	for i = 1, #tProfession, 1 do
        if tRecipe[i] then
            if i == 1 or (tRecipe[i - 1] and tRecipe[i].nBelongID ~= tRecipe[i - 1].nBelongID ) then
                CraftManagePanel.tRecipe[nIndex] = {}
                CraftManagePanel.tRecipe[nIndex].szName = Table_GetCraftBelongName(CraftManagePanel.nProfessionID, tRecipe[i].nBelongID)
                CraftManagePanel.tRecipe[nIndex].bTitle = true
                CraftManagePanel.tRecipe[nIndex].nCanMakeCount = 0
                nMainID = nIndex
                nIndex = nIndex + 1
            end
            CraftManagePanel.tRecipe[nIndex] = {}
            CraftManagePanel.tRecipe[nIndex] = tRecipe[i]
            if CraftManagePanel.tRecipe[nIndex].nTotalCount > 0 then
                CraftManagePanel.tRecipe[nMainID].nCanMakeCount = CraftManagePanel.tRecipe[nMainID].nCanMakeCount + 1
            end
            nIndex = nIndex + 1
       end
	end
end

function CraftManagePanel.UpdateTitle(frame)
	local handle 	   = frame:Lookup("", "")
	local textTitle	   = handle:Lookup("Text_BookTitle")
	local hLevel 	   = handle:Lookup("Handle_Lv")
	local textExp	   = handle:Lookup("Text_Exp")
	local imageExp	   = handle:Lookup("Image_Exp")
	local Profession   = GetProfession(CraftManagePanel.nProfessionID)
	local szTitle	   = Table_GetProfessionName(CraftManagePanel.nProfessionID)
	
	local Player 	= GetClientPlayer()
	local nBranchID = Player.GetProfessionBranch(CraftManagePanel.nProfessionID)
	local nLevel	= Player.GetProfessionLevel(CraftManagePanel.nProfessionID)
	local nAdjustLevel = Player.GetProfessionAdjustLevel(CraftManagePanel.nProfessionID)
	local nExp		= Player.GetProfessionProficiency(CraftManagePanel.nProfessionID)
	local nMaxExp	= Profession.GetLevelProficiency(nLevel)
	local nMaxLevel = Player.GetProfessionMaxLevel(CraftManagePanel.nProfessionID)
	
	if nBranchID ~= 0 then
		szTitle = Table_GetBranchName(CraftManagePanel.nProfessionID, nBranchID)
	end
	textTitle:SetText(szTitle)
	textTitle:SetFontScheme(2)
	
	hLevel:Clear()
	local _, nH = hLevel:GetSize()
	hLevel:SetSize(115, nH)
	hLevel:SetRelPos(0, 73)
	
	local szLevelText = GetFormatText(szTitle.."(", 162)
	if nAdjustLevel and nAdjustLevel ~= 0 then
		local szLevel = math.min((nLevel + nAdjustLevel), nMaxLevel)
		szLevelText = szLevelText..GetFormatText(szLevel, 162, 0, 255, 0)
	else
		szLevelText = szLevelText..GetFormatText(nLevel, 162)
	end
	szLevelText = szLevelText..GetFormatText(g_tStrings.STR_LEVEL..")", 162)
	hLevel:AppendItemFromString(szLevelText)
	hLevel:FormatAllItemPos()
	
	local nW, _ = hLevel:GetSize()
	hLevel:SetSizeByAllItemSize()
	
	local nW1, _ = hLevel:GetSize()
	local nX, nY = hLevel:GetRelPos()
	hLevel:SetRelPos(nX + (nW - nW1), nY)
	
	handle:FormatAllItemPos()
	
	textExp:SetText(nExp.."/"..nMaxExp)
	textExp:SetFontScheme(162)
	imageExp:SetPercentage(nExp / nMaxExp)
end

function CraftManagePanel.UpdateInfo(frame)
	local hList = frame:Lookup("Wnd_List", "")
	local nCount = hList:GetItemCount() - 1
	local nProID = CraftManagePanel.nProfessionID
	local tSelected = CraftManagePanel.tSelected[nProID]
	local bSel = false
	
	for i = 0, nCount, 1 do
		local hItem = hList:Lookup(i)	
		if not hItem.bTitle then
			hItem.tInfo = CraftManagePanel.tRecipe[hItem.nTableID]
			local hText  = hItem:Lookup("Text_FoodName")
			local hImage = hItem:Lookup("Image_Food")
			local szText = hItem.tInfo.szName
			local nFont, nFrame = CraftManagePanel.GetTextFontAndFrame(hItem.tInfo.nLevel)
			if hItem.tInfo.nTotalCount ~= 0 then
				szText = szText.." "..hItem.tInfo.nTotalCount
			end
			
			hText:SetText(szText)
			
			if not hItem.bSel then
				hText:SetFontScheme(nFont)
				hImage:Hide()
			end
			
			if tSelected and hItem.tInfo.nCraftID == tSelected.nCraftID and hItem.tInfo.nRecipeID == tSelected.nRecipeID then
				bSel = true
				CraftManagePanel.Selected(frame, hItem)
				CraftManagePanel.UpdateContent(frame)
			end
		end
	end
	
	if not bSel then
		CraftManagePanel.Selected(frame, nil)
	end
	
	CraftManagePanel.UpdateMakeCount(frame)
end

function CraftManagePanel.OnItemLButtonClick()
	local frame = this:GetRoot()
	if this.bTitle then
		CraftManagePanel.tExpand[CraftManagePanel.nProfessionID..this.szName] = not CraftManagePanel.tExpand[CraftManagePanel.nProfessionID..this.szName]
		this:ExpandOrCollapse()
		this:GetParent():FormatAllItemPos()
		CraftManagePanel.OnUpdateScorllList(frame:Lookup("Wnd_List", ""))
		PlaySound(SOUND.UI_SOUND,g_sound.Button)
	elseif this.bItem then
		if IsCtrlKeyDown() then
			EditBox_AppendLinkRecipe(this.tInfo.nCraftID, this.tInfo.nRecipeID)
			return
		end
		CraftManagePanel.Selected(frame, this)
		CraftManagePanel.UpdateContent(frame)
	elseif this.bEnchant then
		if IsCtrlKeyDown() then
			local nProID, nCraftID, nRecipeID = this:GetObjectData()
			EditBox_AppendLinkEnchant(nProID, nCraftID, nRecipeID)
		end
	elseif this.bProduct then
		if IsCtrlKeyDown() then
			local _, dwVer, nTabType, nIndex = this:GetObjectData()
			EditBox_AppendLinkItemInfo(dwVer, nTabType, nIndex)
		end
	elseif this.bMtlBox then
		if IsCtrlKeyDown() then
			local _, dwVer, nTabType, nIndex = this:GetObjectData()
			EditBox_AppendLinkItemInfo(dwVer, nTabType, nIndex)
		end
	end
end

function CraftManagePanel.OnItemMouseEnter()
	local frame = this:GetRoot()
	
	if this.bItem then
		this.bOver = true
		CraftManagePanel.UpdateBgStatus(this)
	elseif this.bEnchant then
		local nProID, nCraftID, nRecipeID = this:GetObjectData()
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
		OutputEnchantTip(nProID, nCraftID, nRecipeID, {x, y, w, h})
	elseif this.bProduct then
		local _, dwVer, nTabType, nIndex = this:GetObjectData()
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
		OutputItemTip(UI_OBJECT_ITEM_INFO, dwVer, nTabType, nIndex, {x, y, w, h})
	elseif this.bMtlBox then
		local _, nVer, nTabType, nIndex = this:GetObjectData()
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
		OutputItemTip(UI_OBJECT_ITEM_INFO, nVer, nTabType, nIndex, {x, y, w, h})
	end
end

function CraftManagePanel.OnItemMouseLeave()
	local frame = this:GetRoot()
	
	if this.bItem then
		this.bOver = false
		CraftManagePanel.UpdateBgStatus(this)
	elseif this.bEnchant then
		HideTip()
	elseif this.bProduct then
		HideTip()
	elseif this.bMtlBox then
		HideTip()
	end
end

function CraftManagePanel.OnCheckBoxCheck()
	local szName = this:GetName()
	local frame  = this:GetRoot()
	if szName == "CheckBox_Make" then
		CraftManagePanel.tMakeChecked[CraftManagePanel.nProfessionID] = true
		CraftManagePanel.UpdateList(frame)
		CraftManagePanel.UpdateInfo(frame)
	end
end

function CraftManagePanel.OnCheckBoxUncheck()
	local szName = this:GetName()
	local frame  = this:GetRoot()
	if szName == "CheckBox_Make" then
		CraftManagePanel.tMakeChecked[CraftManagePanel.nProfessionID] = false
		CraftManagePanel.UpdateList(frame)
		CraftManagePanel.UpdateInfo(frame)
	end
end

function CraftManagePanel.UpdateList(frame, szKey)
	local hList 	= frame:Lookup("Wnd_List", "")
	local szIniFile = "UI/Config/Default/CraftManagePanel.ini"
	local tRecipe   = CraftManagePanel.tRecipe
	local bExist    = false
	local checkBox  = frame:Lookup("CheckBox_Make")
	local bSel = false
	local nProID = CraftManagePanel.nProfessionID
	local tSelected = CraftManagePanel.tSelected[nProID]
	local bChecked = checkBox:IsCheckBoxChecked()
	
	hList:Clear()
	for i = 1, #tRecipe, 1 do
		if tRecipe[i].bTitle and not CraftManagePanel.bIsSearch and (not bChecked or (bChecked and tRecipe[i].nCanMakeCount > 0)) then
			local hTitle = hList:AppendItemFromIni(szIniFile, "TreeLeaf_ItemClass")
			hTitle.bTitle = true
			hTitle.szName = tRecipe[i].szName
			
			if CraftManagePanel.tExpand[CraftManagePanel.nProfessionID..tRecipe[i].szName] then
				hTitle:Expand()
			end
			
			local hText = hTitle:Lookup("Text_ClassName")
			hText:SetText(tRecipe[i].szName)
			hText:SetFontScheme(162)
			
		elseif not tRecipe[i].bTitle and (not bChecked or (bChecked and tRecipe[i].nTotalCount > 0))then
			local szItemName = "TreeLeaf_ItemName"
			
			local nPos = nil
			if CraftManagePanel.bIsSearch then
				szItemName = "TreeLeaf_Search"
				nPos = string.find(tRecipe[i].szName, szKey)
			else
				nPos = 1
			end
			
			if nPos then
				local hItem = hList:AppendItemFromIni(szIniFile, szItemName)
				hItem.bItem = true
				hItem.tInfo = tRecipe[i]
				hItem.nTableID = i
				
				if CraftManagePanel.bIsSearch then
					bExist = true
					hItem:SetUserData(0 - hItem.tInfo.nLevel)
					hItem:SetName("TreeLeaf_ItemName")
					hItem:Lookup("Text_FoodNameS"):SetName("Text_FoodName")
					hItem:Lookup("Image_FoodS"):SetName("Image_Food")
				end
				
				local hText  = hItem:Lookup("Text_FoodName")
				local hImage = hItem:Lookup("Image_Food")
				local szText = hItem.tInfo.szName
				local nFont, nFrame = CraftManagePanel.GetTextFontAndFrame(hItem.tInfo.nLevel)
				if hItem.tInfo.nTotalCount ~= 0 then
					szText = szText.." "..hItem.tInfo.nTotalCount
				end
				
				hText:SetText(szText)
				hText:SetFontScheme(nFont)
				hImage:Hide()
				
				if tSelected and hItem.tInfo.nCraftID == tSelected.nCraftID and hItem.tInfo.nRecipeID == tSelected.nRecipeID then
					bSel = true
					CraftManagePanel.Selected(frame, hItem)
					CraftManagePanel.UpdateContent(frame)
				end
			end
		end
	end
	
	if not bSel then
		CraftManagePanel.Selected(frame, nil)
	end
	if CraftManagePanel.bIsSearch then
		if not bExist then
			local hItem = hList:AppendItemFromIni(szIniFile, "TreeLeaf_Search")
			
			hItem:Lookup("Text_FoodNameS"):SetText(g_tStrings.STR_MSG_NOT_FIND_LIST)
			hItem:Lookup("Text_FoodNameS"):SetFontScheme(162)
			hItem:Lookup("Image_FoodS"):Hide()
		else
			hList:Sort()
		end
	end
	
	hList:Show()
	CraftManagePanel.OnUpdateScorllList(hList)
end

function CraftManagePanel.OnUpdateScorllList(hList)
	hList:FormatAllItemPos()
	local hWnd  = hList:GetRoot():Lookup("Wnd_List")
	local hScroll = hWnd:Lookup("Scroll_List")
	local w, h = hList:GetSize()
	local wAll, hAll = hList:GetAllItemSize()
	local nStepCount = math.ceil((hAll - h) / 10)

	hScroll:SetStepCount(nStepCount)
	if nStepCount > 0 then
		hScroll:Show()
		hWnd:Lookup("Btn_ListUp"):Show()
		hWnd:Lookup("Btn_ListDown"):Show()
	else
		hScroll:Hide()
		hWnd:Lookup("Btn_ListUp"):Hide()
		hWnd:Lookup("Btn_ListDown"):Hide()
	end
end

function CraftManagePanel.UpdateContent(frame)
	local hWnd = frame:Lookup("Wnd_Content")
	local hMaterial = hWnd:Lookup("", "")
	local szIniFile = "UI/Config/Default/CraftManagePanel.ini"
	
	local nCurProID = CraftManagePanel.nProfessionID
	local nCurCraftID = CraftManagePanel.tSelected[nCurProID].nCraftID
	local nCurRecipeID = CraftManagePanel.tSelected[nCurProID].nRecipeID
	local recipe  = GetRecipe(nCurCraftID, nCurRecipeID)
	local bSatisfy = true
	local szProName = Table_GetProfessionName(CraftManagePanel.nProfessionID)
	
	hMaterial:Clear()
		
	local hItem    = hMaterial:AppendItemFromIni(szIniFile, "Handle_Item")
	local hRequire = hMaterial:AppendItemFromIni(szIniFile, "Handle_RequireP")
	local hBox     = hItem:Lookup("Box_Item")
	local hText    = hItem:Lookup("Text_Item")
	
	if recipe.nCraftType == ALL_CRAFT_TYPE.ENCHANT then 
		hBox.bEnchant = true
		local szName = Table_GetEnchantName(nCurProID, nCurCraftID, nCurRecipeID)
		local nIconID = Table_GetEnchantIconID(nCurProID, nCurCraftID, nCurRecipeID)
		local nQuality = Table_GetEnchantQuality(nCurProID, nCurCraftID, nCurRecipeID)
		
		hText:SetText(szName)
		hText:SetFontColor(GetItemFontColorByQuality(nQuality, false))
		
		hBox:SetObject(UI_OBJECT_ITEM_INFO, nCurProID, nCurCraftID, nCurRecipeID)
		hBox:SetObjectIcon(nIconID)
		UpdateItemBoxExtend(hBox, nil, nQuality)
		hBox:SetOverText(0, "")
	else
		hBox.bProduct = true
		local nType = recipe.dwCreateItemType1
		local nID	= recipe.dwCreateItemIndex1
		
		local ItemInfo = GetItemInfo(nType, nID)
		local nMin  = recipe.dwCreateItemMinCount1
		local nMax  = recipe.dwCreateItemMaxCount1
		
		local szRecipeName = Table_GetRecipeName(nCurCraftID, nCurRecipeID)
		hText:SetText(szRecipeName)
		hText:SetFontColor(GetItemFontColorByQuality(ItemInfo.nQuality, false))
		
		hBox:SetObject(UI_OBJECT_ITEM_INFO, ItemInfo.nUiId, GLOBAL.CURRENT_ITEM_VERSION, nType, nID)
		hBox:SetObjectIcon(Table_GetItemIconID(ItemInfo.nUiId))
		UpdateItemBoxExtend(hBox, ItemInfo)
		hBox:SetOverTextPosition(0, ITEM_POSITION.RIGHT_BOTTOM)
		hBox:SetOverTextFontScheme(0, 15)
		
		if nMax == nMin then
			if nMin ~= 1 then
				hBox:SetOverText(0, nMin)
			else
				hBox:SetOverText(0, "")
			end
		else
			hBox:SetOverText(0, nMin.."-"..nMax)
		end
	end
	
	local player   = GetClientPlayer()
	local szText   = ""
	local nFont    = 162
	
	hRequire:Clear()
	
	szText = szText..GetFormatText(g_tStrings.NEED, 162)
	--Tool	
	local bComma = false
	if recipe.dwToolItemType ~= 0 and recipe.dwToolItemIndex ~= 0 then
		local itemInfo   = GetItemInfo(recipe.dwToolItemType, recipe.dwToolItemIndex)
		local nToolCount = player.GetItemAmount(recipe.dwToolItemType, recipe.dwToolItemIndex)
		
		nFont = 162
		if nToolCount <= 0 then
			nFont =  102
		end
		local szItemName = GetItemNameByItemInfo(itemInfo)
		szText = szText..GetFormatText(szItemName, nFont)
		bComma = true
	end
	--Stamina
	nFont = 162
	if player.nCurrentStamina < recipe.nStamina then
		nFont = 102
	end
	if bComma then
		szText = szText..GetFormatText("，", 162)
	end
	szText = szText..GetFormatText(FormatString(g_tStrings.CRAFT_COST_STAMINA_BLANK, recipe.nStamina), nFont)
	
	--Doodad
	if recipe.dwRequireDoodadID ~= 0 then
		local doodadTamplate = GetDoodadTemplate(recipe.dwRequireDoodadID)
		if doodadTamplate then
			local szName = Table_GetDoodadTemplateName(doodadTamplate.dwTemplateID)
			szText = szText..GetFormatText("，"..szName, 162)
		end
	end
	--技艺要求
	local szCraftText = FormatString(g_tStrings.STR_LEARN_NEED_SKILL, szProName, FormatString(g_tStrings.STR_FRIEND_WTHAT_LEVEL1, recipe.dwRequireProfessionLevel))
	local nFont = 162
	local nMaxLevel    = player.GetProfessionMaxLevel(CraftManagePanel.nProfessionID)
    local nLevel       = player.GetProfessionLevel(CraftManagePanel.nProfessionID)
    local nAdjustLevel = player.GetProfessionAdjustLevel(CraftManagePanel.nProfessionID) or 0
    
    nLevel = math.min((nLevel + nAdjustLevel), nMaxLevel)
	if recipe.dwRequireProfessionLevel > nLevel then
		nFont = 102
	end
	szText = szText..GetFormatText(szCraftText, nFont)
	
	--冷却时间
	CraftManagePanel.bCoolDown = false
	CraftManagePanel.szCoolDownTime = nil
	
	if recipe.dwCoolDownID and recipe.dwCoolDownID > 0 then
		local szTimeText = ""
		local CDTotalTime  = player.GetCDInterval(recipe.dwCoolDownID)
		local CDRemainTime = player.GetCDLeft(recipe.dwCoolDownID)
		
		CraftManagePanel.bCoolDown = true
		if CDRemainTime <= 0 then
			local szTime = CraftManagePanel.ForamtCoolDownTime(CDTotalTime)
			szTimeText = g_tStrings.TIME_CD..szTime
		else
			local szTime = CraftManagePanel.ForamtCoolDownTime(CDRemainTime)
			if not szTime or szTime == "" then
				CDRemainTime = 0
				local szTime = CraftManagePanel.ForamtCoolDownTime(CDTotalTime)
				szTimeText = g_tStrings.TIME_CD..szTime
			else
				CraftManagePanel.szCoolDownTime = szTime
				szTimeText = g_tStrings.TIME_CD1..szTime
			end
		end

		local nFont = 162
		if CDRemainTime ~= 0 then
			nFont = 102
			bSatisfy = false
		end
		szText = szText..GetFormatText("\n"..szTimeText, nFont)
	end
	
	hWnd:Show()
	hRequire:Show()
	hRequire:AppendItemFromString(szText)
	hRequire:FormatAllItemPos()
	hRequire:SetSizeByAllItemSize()
	
	local nMW = hMaterial:GetSize()
	local _, nRH = hRequire:GetSize()
	hRequire:SetSize(nMW, nRH)
	
	hItem:FormatAllItemPos()
	--hItem:SetSizeByAllItemSize()
	
	for nIndex = 1, 6, 1 do
		local nType  = recipe["dwRequireItemType"..nIndex]
		local nID	 = recipe["dwRequireItemIndex"..nIndex]
		local nNeed  = recipe["dwRequireItemCount"..nIndex]
		
		if nNeed > 0 then
			local hItem = hMaterial:AppendItemFromIni(szIniFile, "Handle_Item")
			local nCount   = player.GetItemAmount(nType, nID)
			local hBox	   = hItem:Lookup("Box_Item")
			local hText    = hItem:Lookup("Text_Item")
			local ItemInfo = GetItemInfo(nType, nID)
			local szItemName = GetItemNameByItemInfo(ItemInfo)
			
			hBox.bMtlBox = true
			hText:SetText(szItemName)
			hText:SetFontColor(GetItemFontColorByQuality(ItemInfo.nQuality, false))
			
			hBox:SetObject(UI_OBJECT_ITEM_INFO, ItemInfo.nUiId, GLOBAL.CURRENT_ITEM_VERSION, nType, nID)
			hBox:SetObjectIcon(Table_GetItemIconID(ItemInfo.nUiId))
			UpdateItemBoxExtend(hBox, ItemInfo)
			if nNeed > nCount then
				hBox:SetOverText(0, nCount.."/"..nNeed)
				hBox:SetOverTextPosition(0, ITEM_POSITION.RIGHT_BOTTOM)
				hBox:SetOverTextFontScheme(0, 17)	--条件不足字体
				hBox:EnableObject(0)
			elseif nCount >= 100 then
				hBox:SetOverText(0, "../"..nNeed)
				hBox:SetOverTextPosition(0, ITEM_POSITION.RIGHT_BOTTOM)
				hBox:SetOverTextFontScheme(0, 15)	--条件足够字体
				hBox:EnableObject(1)
			else
				hBox:SetOverText(0, nCount.."/"..nNeed)
				hBox:SetOverTextPosition(0, ITEM_POSITION.RIGHT_BOTTOM)
				hBox:SetOverTextFontScheme(0, 15)	--条件足够字体
				hBox:EnableObject(1)
			end
		end
	end
		
	
	if CraftManagePanel.tSelected[nCurProID].nCurTotalCount <= 0 then
		bSatisfy = false
	end
	CraftManagePanel.SetBtnStatus(frame, recipe.nCraftType, bSatisfy)
	
	--if CraftManagePanel.IsOnMakeRecipe() then
	CraftManagePanel.UpdateMakeCount(frame)
	--end
	
	CraftManagePanel.OnUpdateScorllContent(hMaterial)
end

function CraftManagePanel.OnUpdateScorllContent(hMaterial)
	hMaterial:FormatAllItemPos()
	local hWnd  = hMaterial:GetRoot():Lookup("Wnd_Content")
	local hMaterial = hWnd:Lookup("", "")
	
	local hScroll = hWnd:Lookup("Scroll_Content")
	local w, h = hMaterial:GetSize()
	local wAll, hAll = hMaterial:GetAllItemSize()
	local nCountStep = math.ceil((hAll - h) / 10)

	hScroll:SetStepCount(nCountStep)
	if nCountStep > 0 then
		hScroll:Show()
		hWnd:Lookup("Btn_ContentUp"):Show()
		hWnd:Lookup("Btn_ContentDown"):Show()
	else
		hScroll:Hide()
		hWnd:Lookup("Btn_ContentUp"):Hide()
		hWnd:Lookup("Btn_ContentDown"):Hide()
	end
end

function CraftManagePanel.OnScrollBarPosChanged()
	local hWnd  = this:GetParent()
	local szName = this:GetName()
	local nCurrentValue = this:GetScrollPos()
	
	
	if szName == "Scroll_List" then
		if nCurrentValue == 0 then
			hWnd:Lookup("Btn_ListUp"):Enable(false)
		else
			hWnd:Lookup("Btn_ListUp"):Enable(true)
		end
		
		if nCurrentValue == this:GetStepCount() then
			hWnd:Lookup("Btn_ListDown"):Enable(false)
		else
			hWnd:Lookup("Btn_ListDown"):Enable(true)
		end
		
		local hList = hWnd:Lookup("", "")
		hList:SetItemStartRelPos(0, -nCurrentValue * 10)
	elseif szName == "Scroll_Content" then
		if nCurrentValue == 0 then
			hWnd:Lookup("Btn_ContentUp"):Enable(false)
		else
			hWnd:Lookup("Btn_ContentUp"):Enable(true)
		end
		
		if nCurrentValue == this:GetStepCount() then
			hWnd:Lookup("Btn_ContentDown"):Enable(false)
		else
			hWnd:Lookup("Btn_ContentDown"):Enable(true)
		end
		hWnd:Lookup("", ""):SetItemStartRelPos(0, -nCurrentValue * 10)
	end
end

function CraftManagePanel.SetBtnStatus(frame, nCraftType, bEnable)
	local hText = frame:Lookup("Btn_Make", "Text_Make")
	if nCraftType == ALL_CRAFT_TYPE.ENCHANT then
		frame:Lookup("", "Image_NumFrame"):Hide()
		frame:Lookup("Edit_Number"):Hide()
		frame:Lookup("Btn_MakeAll"):Hide()
		frame:Lookup("Btn_Add"):Hide()
		frame:Lookup("Btn_Del"):Hide()
		
		hText:SetText(g_tStrings.STR_CRAFT_BOOK_SPECIAL_MAKE_BUTTON_TEXT)
	else
		frame:Lookup("", "Image_NumFrame"):Show()
		frame:Lookup("Edit_Number"):Show()
		frame:Lookup("Btn_MakeAll"):Show()
		frame:Lookup("Btn_Add"):Show()
		frame:Lookup("Btn_Del"):Show()
		frame:Lookup("Btn_MakeAll"):Enable(bEnable)
		
		hText:SetText(g_tStrings.STR_CRAFT_BOOK_NORMAL_MAKE_BUTTON_TEXT)
	end
	
	frame:Lookup("Btn_Make"):Enable(bEnable)
	
	local editNum = frame:Lookup("Edit_Number")
	if bEnable then
		hText:SetFontScheme(162)
		
		local szText = editNum:GetText()
		if szText == "" then
			editNum:SetText(1)	
		end
	else
		hText:SetFontScheme(161)
		
		editNum:SetText(0)
	end
	
	if CraftManagePanel.nRecipeID == 0 then
		frame:Lookup("Edit_Number"):SetText("")
	end
end

function CraftManagePanel.IsOnMakeRecipe()
	if CraftManagePanel.nMakeCraftID == 0 or CraftManagePanel.nMakeRecipeID == 0 then
	   return nil
	end
	local tSel = CraftManagePanel.tSelected[CraftManagePanel.nProfessionID]
	if tSel and CraftManagePanel.nMakeCraftID == tSel.nCraftID and CraftManagePanel.nMakeRecipeID == tSel.nRecipeID then
		return true
	end
	return nil
end

function CraftManagePanel.UpdateMakeCount(frame, nDelta)
	if CraftManagePanel.nRecipeID == 0 then
		frame:Lookup("Btn_Del"):Enable(false)
		frame:Lookup("Btn_Add"):Enable(false)
		frame:Lookup("Edit_Number"):SetText("")
		return
	end

	if not nDelta then
		nDelta = 0
	end
	
	local hEdit = frame:Lookup("Edit_Number")
	local szCount = hEdit:GetText()
	local nCount  = 0
	local nValue  = 0
	
	if CraftManagePanel.IsOnMakeRecipe() and nDelta == 0 then
		nCount = CraftManagePanel.nMakeCount 
	else
		if szCount == "" then
			szCount = 0
		end
		nCount = tonumber(szCount)
	end
	
	nCount = nCount + nDelta
	nValue = nCount
	frame:Lookup("Btn_Del"):Enable(true)
	frame:Lookup("Btn_Add"):Enable(true)
	
	if nCount <= 0 then
		nValue = 0
		frame:Lookup("Btn_Del"):Enable(false)
	end
	
	local tSel = CraftManagePanel.tSelected[CraftManagePanel.nProfessionID]
	local nTotCount  = 0
	if not tSel or not tSel.nCurTotalCount then
		nTotCount = 0 
	else
		nTotCount = tSel.nCurTotalCount
	end
	if nCount >= nTotCount then
		nValue = nTotCount
		frame:Lookup("Btn_Add"):Enable(false)
	end
	
	hEdit:SetText(nValue)
end

function CraftManagePanel.OnItemMouseWheel()
	local szName = this:GetName()
	local nDistance = Station.GetMessageWheelDelta()
	if szName == "Handle_Material" then
		this:GetRoot():Lookup("Wnd_Content/Scroll_Content"):ScrollNext(nDistance)
	elseif szName == "Handle_List" then
		this:GetRoot():Lookup("Wnd_List/Scroll_List"):ScrollNext(nDistance)
	end
	return true
end

function CraftManagePanel.GetTextFontAndFrame(nRequireLevel) --根据等级差显示字体和背影颜色
	local nDeltaLevel = CraftManagePanel.nProfessionLevel - nRequireLevel
	if nDeltaLevel >= 20 then	
		return 161, 3
	elseif nDeltaLevel >= 14 then	
		return 165, 4
	elseif nDeltaLevel >= 7 then	
		return 163, 2
	elseif nDeltaLevel >= 0 then	
		return 101, 0
	else							
		return 166, 1
	end
end

function CraftManagePanel.SetMakeInfo(frame, bAll)
	local nProID = CraftManagePanel.nProfessionID
	local tSel =  CraftManagePanel.tSelected[nProID]
	
	if bAll then
		CraftManagePanel.nMakeCount = tSel.nCurTotalCount
	else	
		local szCount = frame:Lookup("Edit_Number"):GetText()
		if szCount == "" then
			CraftManagePanel.nMakeCount = 0
		else
			CraftManagePanel.nMakeCount = tonumber(szCount)
		end
		
		if CraftManagePanel.nMakeCount > tSel.nCurTotalCount then
			CraftManagePanel.nMakeCount = tSel.nCurTotalCount
		end
	end
		
	CraftManagePanel.nMakeCraftID = tSel.nCraftID
	CraftManagePanel.nMakeRecipeID = tSel.nRecipeID
	
	CraftManagePanel.UpdateMakeCount(frame)
end

function CraftManagePanel.ClearMakeInfo(frame)
	CraftManagePanel.nMakeCount = 0
	CraftManagePanel.nMakeCraftID = 0
	CraftManagePanel.nMakeRecipeID = 0
end

function CraftManagePanel.OnMakeRecipe(frame)
	if CraftManagePanel.nMakeCount > 0 then
		GetClientPlayer().CastProfessionSkill(CraftManagePanel.nMakeCraftID, CraftManagePanel.nMakeRecipeID)
	end
end

function CraftManagePanel.OnEnchantItem()
	local fnAction = function(dwTargetBox, dwTargetX)
		local item = GetPlayerItem(GetClientPlayer(), dwTargetBox, dwTargetX)
		if item then
			GetClientPlayer().CastProfessionSkill(CraftManagePanel.nMakeCraftID, CraftManagePanel.nMakeRecipeID, TARGET.ITEM, item.dwID)
		end
	end
	local fnCancel = function()
		return
	end
	local fnCondition = function(dwTargetBox, dwTargetX)	
		local item   = GetPlayerItem(GetClientPlayer(), dwTargetBox, dwTargetX)
		local recipe = GetRecipe(CraftManagePanel.nMakeCraftID, CraftManagePanel.nMakeRecipeID)

		if not item then 
			return false
		end
		
		if not recipe then
			return false
		end
		
		return true
	end
	UserSelect.SelectItem(fnAction, fnCancel, fnCondition, nil)
end

function CraftManagePanel.OnEditChanged()
	local szName = this:GetName()
	if szName == "Edit_Search" then
		CraftManagePanel.OnSearch(this:GetRoot())
	end
end

function CraftManagePanel.OnSetFocus()
	local szName = this:GetName()
	if szName == "Edit_Search" then
		this:SelectAll()
	end
end

function CraftManagePanel.OnKillFocus()
	local szName = this:GetName()
	if szName == "Edit_Search" then
	end	
end

function CraftManagePanel.OnLButtonClick()
	local frame  = this:GetRoot()
	local szName = this:GetName()
	
	if szName == "Btn_Close" then
		CloseCraftManagePanel()
	elseif szName == "Btn_Add" then
		CraftManagePanel.UpdateMakeCount(frame, 1)
	elseif szName == "Btn_Del" then
		CraftManagePanel.UpdateMakeCount(frame, -1)
	elseif szName == "Btn_Make" then
		local nProID = CraftManagePanel.nProfessionID
		local nCraftID = CraftManagePanel.tSelected[nProID].nCraftID
		local nRecipeID = CraftManagePanel.tSelected[nProID].nRecipeID
		local recipe = GetRecipe(nCraftID, nRecipeID)
		
		if recipe.nCraftType == ALL_CRAFT_TYPE.PRODUCE then	
			CraftManagePanel.SetMakeInfo(frame)		
			CraftManagePanel.OnMakeRecipe(frame)
		elseif  recipe.nCraftType == ALL_CRAFT_TYPE.ENCHANT then
			CraftManagePanel.nMakeCraftID  = nCraftID
			CraftManagePanel.nMakeRecipeID = nRecipeID
			CraftManagePanel.nMakeCount =1
			CraftManagePanel.OnEnchantItem()
		end
	elseif szName == "Btn_MakeAll" then
		CraftManagePanel.SetMakeInfo(frame, true)
		CraftManagePanel.OnMakeRecipe(frame)
	end
end

function CraftManagePanel.OnSearch(frame)
	local szKey = frame:Lookup("Edit_Search"):GetText()
	if not szKey or szKey == "" then
		if CraftManagePanel.bIsSearch then
			CraftManagePanel.bIsSearch = false
			
			CraftManagePanel.Selected(frame, nil)
			CraftManagePanel.UpdateList(frame)
		end
	else
		CraftManagePanel.bIsSearch = true
		CraftManagePanel.Selected(frame, nil)
		CraftManagePanel.UpdateList(frame, szKey)
	end
end

function CraftManagePanel.ForamtCoolDownTime(nTime)
	local szText = ""
	local nH, nM, nS = GetTimeToHourMinuteSecond(nTime, true)
	if nH and nH > 0 then
		if (nM and nM > 0) or (nS and nS > 0) then
			nH = nH + 1
		end
		szText = szText..nH..g_tStrings.STR_BUFF_H_TIME_H
	else 
		nM = nM or 0
		nS = nS or 0
				
		if nM == 0 and nS == 0 then
			return szText
		end
		
		if nM > 0 and nS > 0 then
			nM = nM + 1
		end
		
		if nM >= 60 then
			szText = szText..math.ceil(nM / 60)..g_tStrings.STR_BUFF_H_TIME_H
		elseif nM > 0 then
			szText = szText..nM..g_tStrings.STR_BUFF_H_TIME_M
		else
			szText = szText..nS..g_tStrings.STR_BUFF_H_TIME_S
		end
	end
	
	return szText
end


function CraftManagePanel.OnLButtonHold()
	local szSelfName = this:GetName()
	if szSelfName == "Btn_ListUp" then
		this:GetRoot():Lookup("Wnd_List/Scroll_List"):ScrollPrev(1)
	elseif szSelfName == "Btn_ListDown" then
		this:GetRoot():Lookup("Wnd_List/Scroll_List"):ScrollNext(1)	
	elseif szSelfName == "Btn_ContentUp" then
		this:GetRoot():Lookup("Wnd_Content/Scroll_Content"):ScrollPrev(1)
	elseif szSelfName == "Btn_ContentDown" then
		this:GetRoot():Lookup("Wnd_Content/Scroll_Content"):ScrollNext(1)	
    end
end

function CraftManagePanel.OnLButtonDown()
	CraftManagePanel.OnLButtonHold()
end

function OpenCraftManagePanel(nProfessionID, nCraftID, bDisableSound)
	if IsOptionOrOptionChildPanelOpened() then
		return
	end

	local frame
	if IsCraftManagePanelOpened()  then
		if nProfessionID == 0 or CraftManagePanel.nProfessionID == nProfessionID then
			CloseCraftManagePanel()
			return
		end
		frame = Station.Lookup("Normal/CraftManagePanel")
	else
		frame = Wnd.OpenWindow("CraftManagePanel")
	end
	
	CraftManagePanel.Init(frame, nProfessionID, nCraftID)
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end	
end

function CloseCraftManagePanel(bDisableSound)
	if IsCraftManagePanelOpened() then
		Wnd.CloseWindow("CraftManagePanel")
	end
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end		
end

function IsCraftManagePanelOpened()
	local frame = Station.Lookup("Normal/CraftManagePanel")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end

function IsCraftManagePanelOpenedSameCraft(nProID, nBranchID, nCraftID)
	local nProID = CraftManagePanel.nProfessionID
	local tSel   = CraftManagePanel.tSelected[nProID]
	if IsCraftManagePanelOpened() then
		local nCraftBranchID = GetClientPlayer().GetProfessionBranch(CraftManagePanel.nProfessionID)
		if tSel and nProID == nProID and nCraftBranchID == tSel.nBranchID and nCraftID == tSel.nCraftID then
			return true
		end
	end
	return false
end
