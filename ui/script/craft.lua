--------------------Craft-------------------------
function OnUseCraft(nProID, nBranchID, nCraftID, box)
	if nProID == 100 then
        if CompassPanel.IsOpened() then
            CompassPanel.ClosePanel()
        else
            CompassPanel.OpenPanel()
        end
        return
    end
    
    local Craft = GetCraft(nCraftID)
	local nType = Craft.CraftType
	local Profession = GetProfession(Craft.ProfessionID);
	
	if nType == ALL_CRAFT_TYPE.RADAR and Profession.dwCraftRadarID then
		local player = GetClientPlayer()
		local eType, nParam = player.GetMiniMapRadar()
		if eType == MINI_RADAR_TYPE.FIND_CRAFT_DOODAD and nParam == Profession.dwCraftRadarID then
			player.SetMinimapRadar(MINI_RADAR_TYPE.NO_RADAR, 0)
		else
			player.SetMinimapRadar(MINI_RADAR_TYPE.FIND_CRAFT_DOODAD, Profession.dwCraftRadarID)
		end
	elseif nType == ALL_CRAFT_TYPE.PRODUCE or nType == ALL_CRAFT_TYPE.ENCHANT then
		if IsCraftManagePanelOpenedSameCraft(nProID, nBranchID, nCraftID) then
			CloseCraftManagePanel()
		else
			OpenCraftManagePanel(nProID, nCraftID)
		end
	elseif nType == ALL_CRAFT_TYPE.EQUIPBREAK then
		BreakEquip()
	end
end

local g_tBreakEquip = {
	dwBox = 0,
	dwX = 0,
	dwItemID = 0,
}

function OnBreakEquip()
	local player = GetClientPlayer()
	if not player then
		return
	end
	
	local item = player.GetItem(g_tBreakEquip.dwBox, g_tBreakEquip.dwX)
	if not item or item.dwID ~= g_tBreakEquip.dwItemID then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.BREAK_EQUIP_FAIL)
		return
	end
	
	OpenItemBoxByCraft(g_tBreakEquip.dwBox, g_tBreakEquip.dwX)
end

function BreakEquip()
	if CheckHaveLocked(SAFE_LOCK_EFFECT_TYPE.OPERATE_DIAMOND, "OPERATE_DIAMOND") then
		return
	end
	
	local fnAction = function(dwTargetBox, dwTargetX)
		local player = GetClientPlayer()
		if not player then
			return
		end
		
		local hItem = player.GetItem(dwTargetBox, dwTargetX)
		if not hItem then
			return
		end
		
		local ret = player.BreakEquip(dwTargetBox, dwTargetX)
		if ret == DIAMOND_RESULT_CODE.NOT_ENOUGH_STAMINA then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.BREAK_EQUIP_NOT_ENOUGH_STAMINA)
			return;
		elseif ret == DIAMOND_RESULT_CODE.CAN_NOT_OPERATE_IN_FIGHT then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.BREAK_EQUIP_CAN_NOT_OPERATE_IN_FIGHT)
			return;
		end
		
		g_tBreakEquip.dwBox = dwTargetBox
		g_tBreakEquip.dwX = dwTargetX
		g_tBreakEquip.dwItemID = hItem.dwID
		RemoteCallToServer("OnBeforeBreakEquip", hItem.dwID)
	end
	
	local fnCancel = function()
		return
	end
	
	local fnCondition = function(dwTargetBox, dwTargetX)	
		local player = GetClientPlayer()
		if not player then
			return false
		end
		local hItem = player.GetItem(dwTargetBox, dwTargetX)
		if not hItem then
			return false
		end
		
		local nRet = player.CanBreakEquip(dwTargetBox, dwTargetX)
		if not nRet then
			return false
		end
		
		return true
	end
	
	UserSelect.SelectItem(fnAction, fnCancel, fnCondition, nil, true)
end

function OnUpdateCraftState(player, box)
	local nProID, nBranchID, nCraftID = box:GetObjectData()
	if nProID == 100 then
		return
	end
	
	local Craft = GetCraft(nCraftID)
	if not Craft then
		return
	elseif Craft.CraftType == ALL_CRAFT_TYPE.RADAR then
		local eType, nParam =  player.GetMiniMapRadar()
		local Profession = GetProfession(Craft.ProfessionID);
		box:SetObjectSelected(eType == MINI_RADAR_TYPE.FIND_CRAFT_DOODAD and nParam == Profession.dwCraftRadarID)
	elseif Craft.CraftType == ALL_CRAFT_TYPE.PRODUCE or Craft.CraftType == ALL_CRAFT_TYPE.ENCHANT then
		box:SetObjectSelected(IsCraftManagePanelOpenedSameCraft(nProID, nBranchID, nCraftID))
	else
		box:SetObjectSelected(false)
	end	
end

function OutputCraftTip(nProID, nBranchID, nCraftID, Rect)
	local szTip = ""
	
	--------------名字-------------------------
	local szText = Table_GetProfessionName(nProID)
	if nBranchID ~= 0 then
		local szBranchName = Table_GetBranchName(nProID, nBranchID)
		if szBranchName then	--分支名字
			szTip = szTip.."<Text>text="..EncodeComponentsString(szText).." font=163 </text> "..
		    			   "<Text>text="..EncodeComponentsString(g_tStrings.STR_SKILL_H_AT).." font=106 </text>"..
		    			   "<Text>text="..EncodeComponentsString(szBranchName.."\n").." font=163 </text>"
	    else
	    	szTip = szTip.."<Text>text="..EncodeComponentsString(szText.."\n").." font=163 </text> "
	    end
	else
		szTip = szTip.."<Text>text="..EncodeComponentsString(szText.."\n").." font=163 </text> "
	end

	--------------描述-------------------------
	szTip = szTip..Table_GetCraftDesc(nProID, nCraftID).."<text>text=\"\\\n\"</text>"
	
    OutputTip(szTip, 400, Rect)
end

--------------------BOOK--------------------------
function OutputBookTipByID(nBookID, nSegmentID, Rect)
	local Copyrecipe = GetRecipe(12, nBookID, nSegmentID)
	if Copyrecipe then
		local itemInfo = GetItemInfo(Copyrecipe.dwCreateItemType, Copyrecipe.dwCreateItemIndex)
		local szTip = GetBookTipByItemInfo(itemInfo, nBookID, nSegmentID)
		OutputTip(szTip, 400, Rect)
	end
end

function GetBookTipByItem(item, szFromLoorOrShop)
	local szTip  = ""
	local player = GetClientPlayer()
	local nBookID, nSegmentID = GlobelRecipeID2BookID(item.nBookID)
	local nSort  = Table_GetBookSort(nBookID, nSegmentID)
	local recipe = GetRecipe(8, nBookID, nSegmentID)
	local nRequireLevel = recipe.dwRequireProfessionLevel
	--------------名字-------------------------
	szTip = szTip.."<Text>text="..EncodeComponentsString(Table_GetSegmentName(nBookID, nSegmentID).."\n").." font=106"..GetItemFontColorByQuality(item.nQuality, true).." </text>"

	--------------绑定-------------------------
	if item.nGenre == ITEM_GENRE.TASK_ITEM then
		szTip = szTip.."<Text>text="..EncodeComponentsString(g_tStrings.STR_ITEM_H_QUEST_ITEM).." font=106 </text>"	
	elseif item.bBind and not szFromLoorOrShop then
		szTip = szTip.."<Text>text="..EncodeComponentsString(g_tStrings.STR_ITEM_H_HAS_BEEN_BIND).." font=107 </text>"
	else
		if item.nBindType == ITEM_BIND.INVALID then
		elseif item.nBindType == ITEM_BIND.NEVER_BIND then
		elseif item.nBindType == ITEM_BIND.BIND_ON_EQUIPPED then
			szTip = szTip.."<Text>text="..EncodeComponentsString(g_tStrings.STR_ITEM_H_BIND_AFTER_EQUIP).." font=107 </text>"
		elseif item.nBindType == ITEM_BIND.BIND_ON_PICKED then
			if szFromLoorOrShop == "shop" then
				szTip = szTip.."<Text>text="..EncodeComponentsString(g_tStrings.STR_ITEM_H_BIND_AFTER_BUY).." font=107</text>"
			else
				szTip = szTip.."<Text>text="..EncodeComponentsString(g_tStrings.STR_ITEM_H_BIND_AFTER_PICK).." font=107</text>"
			end
		end
	end

	-----------唯一性------------------
	if item.nMaxExistAmount ~= 0 then
		if item.nMaxExistAmount == 1 then
			szTip = szTip.."<Text>text="..EncodeComponentsString(g_tStrings.STR_ITEM_H_UNIQUE).." font=106 </text>"
		else
			szTip = szTip.."<Text>text="..EncodeComponentsString(FormatString(g_tStrings.STR_ITEM_H_UNIQUE_MULTI, item.nMaxExistAmount)).." font=106 </text>"
		end
	end	

	--------------大类-------------------------
	local nSort = Table_GetBookSort(nBookID, nSegmentID)
	szTip = szTip.."<Text>text="..EncodeComponentsString(g_tStrings.STR_CRAFT_READ_BOOK_SORT_NAME_TABLE[nSort].."\n").." font=106 </text> "
	
	--------------需求-------------------------
	--Level
	--local nMaxLevel = player.GetProfessionMaxLevel(8)
	local nLevel = player.GetProfessionLevel(8)
	--local nExp = player.GetProfessionProficiency(8)
	
	if nLevel >= recipe.dwRequireProfessionLevel then
		szTip = szTip.."<Text>text="..EncodeComponentsString(FormatString(g_tStrings.CRAFT_READING_REQUIRE_LEVEL1, nRequireLevel)).." font=106 </text>"
	else
		szTip = szTip.."<Text>text="..EncodeComponentsString(FormatString(g_tStrings.CRAFT_READING_REQUIRE_LEVEL1, nRequireLevel)).." font=166 </text>"
	end
	--Stamina
	if player.nCurrentStamina >= recipe.nStamina then
		szTip = szTip.."<Text>text="..EncodeComponentsString(FormatString(g_tStrings.STR_CRAFT_COST_STAMINA_ENTER, recipe.nStamina)).." font=106 </text>"
	else
		szTip = szTip.."<Text>text="..EncodeComponentsString(FormatString(g_tStrings.STR_CRAFT_COST_STAMINA_ENTER, recipe.nStamina)).." font=166 </text>"
	end
	
	--------------描述-------------------------
	if player.IsBookMemorized(nBookID, nSegmentID) then
		szTip = szTip.."<Text>text="..EncodeComponentsString(g_tStrings.TIP_ALREADY_READ).." font=108 </text>"
	else
		szTip = szTip.."<Text>text="..EncodeComponentsString(g_tStrings.TIP_UNREAD).." font=105 </text>"
	end
	
	szTip = szTip.."<Text>text="..EncodeComponentsString(Table_GetBookDesc(nBookID, nSegmentID).."\n").." font=163 </text>"

	return szTip
end

function GetBookTipByItemInfo(itemInfo, nBookID, nSegmentID, bAddInfo)
	local szTip  = ""
	local player = GetClientPlayer()
	local nSort  = Table_GetBookSort(nBookID, nSegmentID)
	local recipe = GetRecipe(8, nBookID, nSegmentID)
	local nRequireLevel = recipe.dwRequireProfessionLevel
	--------------名字-------------------------
	szTip = szTip.."<Text>text="..EncodeComponentsString(Table_GetSegmentName(nBookID, nSegmentID).."\n").." font=106"..GetItemFontColorByQuality(itemInfo.nQuality, true).." </text>"

	--------------绑定-------------------------
	if itemInfo.nGenre == ITEM_GENRE.TASK_ITEM then
		szTip = szTip.."<Text>text="..EncodeComponentsString(g_tStrings.STR_ITEM_H_QUEST_ITEM).." font=106 </text>"
	elseif itemInfo.nBindType == ITEM_BIND.INVALID then
	elseif itemInfo.nBindType == ITEM_BIND.NEVER_BIND then
	elseif itemInfo.nBindType == ITEM_BIND.BIND_ON_EQUIPPED then
		szTip = szTip.."<Text>text="..EncodeComponentsString(g_tStrings.STR_ITEM_H_BIND_AFTER_EQUIP).." font=106 </text>"
	elseif itemInfo.nBindType == ITEM_BIND.BIND_ON_PICKED then
		szTip = szTip.."<Text>text="..EncodeComponentsString(g_tStrings.STR_ITEM_H_BIND_AFTER_PICK).." font=106 </text>"
	end

	--------------大类-------------------------
	local nSort = Table_GetBookSort(nBookID, nSegmentID)
	szTip = szTip.."<Text>text="..EncodeComponentsString(g_tStrings.STR_CRAFT_READ_BOOK_SORT_NAME_TABLE[nSort].."\n").." font=106 </text> "
	
	--------------需求-------------------------
	--Level
	--local nMaxLevel = player.GetProfessionMaxLevel(8)
	local nLevel = player.GetProfessionLevel(8)
	--local nExp = player.GetProfessionProficiency(8)
	
	if nLevel >= recipe.dwRequireProfessionLevel then
		szTip = szTip.."<Text>text="..EncodeComponentsString(FormatString(g_tStrings.CRAFT_READING_REQUIRE_LEVEL1, nRequireLevel)).." font=106 </text>"
	else
		szTip = szTip.."<Text>text="..EncodeComponentsString(FormatString(g_tStrings.CRAFT_READING_REQUIRE_LEVEL1, nRequireLevel)).." font=166 </text>"
	end
	--Stamina
	if player.nCurrentStamina >= recipe.nStamina then
		szTip = szTip.."<Text>text="..EncodeComponentsString(FormatString(g_tStrings.STR_CRAFT_COST_STAMINA_ENTER, recipe.nStamina)).." font=106 </text>"
	else
		szTip = szTip.."<Text>text="..EncodeComponentsString(FormatString(g_tStrings.STR_CRAFT_COST_STAMINA_ENTER, recipe.nStamina)).." font=166 </text>"
	end
	
	if bAddInfo then
		if player.IsBookMemorized(nBookID, nSegmentID) then
			szTip = szTip.."<Text>text="..EncodeComponentsString(g_tStrings.TIP_ALREADY_READ).." font=108 </text>"
		else
			szTip = szTip.."<Text>text="..EncodeComponentsString(g_tStrings.TIP_UNREAD).." font=105 </text>"
		end
	end
	
	szTip = szTip.."<Text>text="..EncodeComponentsString(Table_GetBookDesc(nBookID, nSegmentID).."\n").." font=163 </text>"

	return szTip
end

--------------------Recipe------------------------
function OutputRecipeLink(dwCraftID, dwRecipeID, Rect)
	local recipe = GetRecipe(dwCraftID, dwRecipeID)
    local player = GetClientPlayer()
    --------------名字-------------------------
    local prof = GetProfession(recipe.dwProfessionID)
    local szTitle = Table_GetProfessionName(recipe.dwProfessionID)
    local szRecipeName = Table_GetRecipeName(dwCraftID, dwRecipeID)
   
    local szTip = "<Text>text="..EncodeComponentsString(szTitle.."："..szRecipeName).." font=106 </text>"
    --------------需求-------------------------
	
    local nRequireLevel = recipe.dwRequireProfessionLevel
	local szText = FormatString(g_tStrings.STR_LEARN_NEED_SKILL, szTitle, FormatString(g_tStrings.STR_FRIEND_WTHAT_LEVEL1, nRequireLevel))
	
	--local nMaxLevel               = player.GetProfessionMaxLevel(recipe.dwProfessionID)
	local nLevel                  = player.GetProfessionLevel(recipe.dwProfessionID)
	--local nExp                    = player.GetProfessionProficiency(recipe.dwProfessionID)
	if nRequireLevel > nLevel then
		szTip = szTip.."<text>text="..EncodeComponentsString(szText.."\n").."font=102".."</text>"
	else
		szTip = szTip.."<text>text="..EncodeComponentsString(szText.."\n").."font=162".."</text>"
	end
	if recipe.dwToolItemType ~= 0 and recipe.dwToolItemIndex ~= 0 then
    	local itemInfo = GetItemInfo(recipe.dwToolItemType, recipe.dwToolItemIndex)
    	szTip = szTip.."<text>text="..EncodeComponentsString(FormatString(g_tStrings.STR_MSG_NEED_TOOL, GetItemNameByItemInfo(itemInfo))).."font=162 </text>"
    end
    --------------材料-------------------------
	szTip = szTip.."<Text>text="..EncodeComponentsString(g_tStrings.STR_CRAFT_TIP_RECIPE_REQUIRE.."\n").." font=163 </text>"
	for nIndex = 1, 6, 1 do
		local nType  = recipe["dwRequireItemType"..nIndex]
		local nID	 = recipe["dwRequireItemIndex"..nIndex]
		local nNeed  = recipe["dwRequireItemCount"..nIndex]
		
		if nType ~= 0 and nID ~= 0 then
			local ItemR = GetItemInfo(nType, nID)
			local nCount   = player.GetItemAmount(nType, nID)
			local nFont = 163
			if nCount < nNeed then
				nFont = 102 
			end
			szTip = szTip.."<Text>text="..EncodeComponentsString(GetItemNameByItemInfo(ItemR).." ("..nNeed..")\n").." font="..nFont.." </text>"
		end
	end
    --------------产物-------------------------
	szTip = szTip.."<text>text=\"\\\n\"font=163</text>"..GetItemInfoTip(nil, recipe.dwCreateItemType1, recipe.dwCreateItemIndex1)

    OutputTip(szTip, 400, Rect, nil, true, "recipe"..dwCraftID.."x"..dwRecipeID)
end

--------------------Enchant-----------------------
function OutputEnchantTip(dwProID, dwCraftID, dwRecipeID, Rect)
	local szName = Table_GetEnchantName(dwProID, dwCraftID, dwRecipeID)
	local szDesc = Table_GetEnchantDesc(dwProID, dwCraftID, dwRecipeID)
	local nQuality = Table_GetEnchantQuality(dwProID, dwCraftID, dwRecipeID)
	local szTip = ""
	
	--------------名字-------------------------
	szTip = szTip.."<Text>text="..EncodeComponentsString(szName.."\n").." font=163"..GetItemFontColorByQuality(nQuality, true).." </text>"
	--------------描述-------------------------
	szDesc = string.gsub(szDesc, "<ENCHANT (%d+)>", function(dwID) return GetEnchantDesc(dwID) end)
	szTip = szTip..szDesc.."<text>text=\"\\\n\"</text>"
	
    OutputTip(szTip, 400, Rect)
end

function OutputEnchantLink(dwProID, dwCraftID, dwRecipeID, Rect)
	local szName = Table_GetEnchantName(dwProID, dwCraftID, dwRecipeID)
	local szDesc = Table_GetEnchantDesc(dwProID, dwCraftID, dwRecipeID)
	local nQuality = Table_GetEnchantQuality(dwProID, dwCraftID, dwRecipeID)
	local szTip = ""
	
	--------------名字-------------------------
	szTip = szTip.."<Text>text="..EncodeComponentsString(szName.."\n").." font=163"..GetItemFontColorByQuality(nQuality, true).." </text>"
	--------------描述-------------------------
	szDesc = string.gsub(szDesc, "<ENCHANT (%d+)>", function(dwID) return GetEnchantDesc(dwID) end)
	szTip = szTip..szDesc.."<text>text=\"\\\n\"</text>"

	OutputTip(szTip, 400, Rect, nil, true, "enchant"..dwProID.."x"..dwCraftID.."x"..dwRecipeID)
end
