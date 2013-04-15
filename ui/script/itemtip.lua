local function GetEquipRecipeDesc(Value1, Value2)
    local szText = ""
    local tRecipeSkillAtrri = g_tTable.EquipmentRecipe:Search(Value1, Value2)
    if tRecipeSkillAtrri then
        szText = tRecipeSkillAtrri.szDesc
    end 
    return szText;
end

function GetItemFontColorByStrengthLevel(nLevel)
	local r, g, b = 0, 255, 0
	return " r="..r.." g="..g.." b="..b.." "
end


function GetEnchantDesc(dwID)
	local aAttr, dwTime, nSubType = GetEnchantAttribute(dwID)
	if not aAttr or #aAttr == 0 then
		return ""
	end
	local szDesc = g_tStrings.tEquipTypeNameTable[nSubType]
	local bFirst = true
	for k, v in pairs(aAttr) do
		FormatAttributeValue(v)
		local szText = FormatString(Table_GetMagicAttributeInfo(v.nID, true), v.nValue1, v.nValue2)
		local szPText = GetPureText(szText)
		if szPText ~= "" then
			if bFirst then
				bFirst = false
			else
				szPText = g_tStrings.STR_COMMA..szPText
			end
		end 
		szDesc = szDesc..szPText
	end
	if dwTime == 0 then
		szDesc = szDesc..g_tStrings.STR_FULL_STOP
	else
		szDesc = szDesc..g_tStrings.STR_COMMA.. g_tStrings.STR_TIME_DURATION .. GetTimeText(dwTime)..g_tStrings.STR_FULL_STOP
	end
	return szDesc
end

function GetEnchantTip(nUiId, bCmp)
	local szTip = ""
	
	-----------当前装备---------------
	if bCmp then
		szTip = "<Text>text="..EncodeComponentsString(g_tStrings.TIP_CURRENT_EQUIP).."font=163 </text>"
	end
	
	-----------名字-------------------
	szTip = szTip.."<Text>text="..EncodeComponentsString(Table_GetItemName(nUiId).."\n")..
		" font=60 "..GetItemFontColorByQuality(1, true).." </text>"
		
	local szImg = "\\ui\\image\\item_pic\\"..nUiId..".UITex"
	if IsFileExist(szImg) then
		szTip = szTip.."<image>path="..EncodeComponentsString(szImg).." frame=0 </image><text>text=\"\\\n\"</text>"
	end
		
	local szItemDesc = GetItemDesc(nUiId)
	if szItemDesc and szItemDesc ~= "" then
		szTip = szTip..szItemDesc.."<text>text=\"\\\n\"</text>"
	end
	
	return szTip
end

function OutputBackPendantTip(dwID, Rect, bLink)
	local itemInfo = GetBackPendantItemInfo(dwID)
	if not itemInfo then
		return
	end
	
	local szTip = "<text>text="..EncodeComponentsString(GetItemNameByItemInfo(itemInfo, nBookInfo).."\n")..
		" font=60"..GetItemFontColorByQuality(itemInfo.nQuality, true).." </text>"
	local szItemDesc = GetItemDesc(itemInfo.nUiId)
	if szItemDesc and szItemDesc ~= "" then
		szTip = szTip..szItemDesc.."<text>text=\"\\\n\"</text>"
	end
	OutputTip(szTip, 345, Rect, nil, bLink)
end

function OutputWaistPendantTip(dwID, Rect, bLink)
	local itemInfo = GetWaistPendantItemInfo(dwID)
	if not itemInfo then
		return
	end
	
	local szTip = "<text>text="..EncodeComponentsString(GetItemNameByItemInfo(itemInfo, nBookInfo).."\n")..
		" font=60"..GetItemFontColorByQuality(itemInfo.nQuality, true).." </text>"
	local szItemDesc = GetItemDesc(itemInfo.nUiId)
	if szItemDesc and szItemDesc ~= "" then
		szTip = szTip..szItemDesc.."<text>text=\"\\\n\"</text>"
	end
	OutputTip(szTip, 345, Rect, nil, bLink)
end

function GetItemDesc(nUiId)
	local szDesc = Table_GetItemDesc(nUiId)
	szDesc = string.gsub(szDesc, "<SKILL (%d+) (%d+)>", function(dwID, dwLevel) return GetSubSkillDesc(dwID, dwLevel) end)
	szDesc = string.gsub(szDesc, "<BUFF (%d+) (%d+) (%w+)>", function(dwID, nLevel, szKey)  return GetBuffDesc(dwID, nLevel, szKey) end)
	szDesc = string.gsub(szDesc, "<ENCHANT (%d+)>", function(dwID) return GetEnchantDesc(dwID) end)
	szDesc = string.gsub(szDesc, "<SpiStone (%d+)>", function(dwID) return GetSpiStoneDesc(dwID) end)
	return szDesc
end

--------输出物品的提示-----------------

function GetOtherItemInfoTip(hItemInfo, hPlayer, nIndex)
	local szTip = ""
	----------等级，性别------------
		if hItemInfo.nRequireLevel ~= 0 or hItemInfo.nRequireGender ~= 0 then 
			local nNeedFont = 166
			local nLevelFont = 166
			local nGenderFont = 166
			local szLevelGenderTip = ""
			if hItemInfo.nRequireLevel ~= 0 then
				if hPlayer.nLevel >= hItemInfo.nRequireLevel then
					nNeedFont = 162
					nLevelFont = 162
					
				end
				szLevelGenderTip = "<Text>text="..EncodeComponentsString(FormatString(g_tStrings.TIP_LEVEL_WHAT, hItemInfo.nRequireLevel)).." font="..nLevelFont.." </text>"
			end
			if hItemInfo.nRequireGender ~= 0 then
				if hPlayer.nGender == hItemInfo.nRequireGender then
					nNeedFont = 162
					nGenderFont = 162
				end
				
				if hItemInfo.nRequireLevel ~= 0 then
					szLevelGenderTip = szLevelGenderTip.."<Text>text="..EncodeComponentsString("，").." font="..nNeedFont.."</text>"
				end
				szLevelGenderTip = szLevelGenderTip.."<Text>text="..EncodeComponentsString(g_tStrings.tGender[hItemInfo.nRequireGender]).." font="..nGenderFont.." </text>"
			end
			szTip = szTip.."<Text>text="..EncodeComponentsString(g_tStrings.NEED).." font="..nNeedFont.."</text>"..szLevelGenderTip
			szTip = szTip.."<Text>text="..EncodeComponentsString("\n").." font=162 </text>"
		end
		-----------物品使用的生活技能限制-----------
		if hItemInfo.dwRequireProfessionID ~= 0 and not g_LearnInfo[nIndex] then
			local nFont = 162
			local hProfession = GetProfession(hItemInfo.dwRequireProfessionID)
			local szProfessionTip = g_tStrings.NEED..Table_GetProfessionName(hItemInfo.dwRequireProfessionID)
			
			if hItemInfo.dwRequireProfessionBranch ~= 0 then
				local dwProfessionBranch = hPlayer.GetProfessionBranch(hItemInfo.dwRequireProfessionID)
				if dwProfessionBranch ~= hItemInfo.dwRequireProfessionBranch then
					nFont = 166;
				end
				
				local szBranchName = Table_GetBranchName(hItemInfo.dwRequireProfessionID, hItemInfo.dwRequireProfessionBranch)
				szProfessionTip = szProfessionTip..g_tStrings.STR_PREV_PARENTHESES..szBranchName..g_tStrings.STR_END_PARENTHESES
			end
			
			local nProfessionLevel = hPlayer.GetProfessionLevel(hItemInfo.dwRequireProfessionID)
			if (nProfessionLevel < hItemInfo.nRequireProfessionLevel) then
				nFont = 166
			end	
			
			if hItemInfo.nRequireProfessionLevel ~= 0 then
				szProfessionTip = szProfessionTip..FormatString(g_tStrings.STR_PLAYER_H_WHAT_LEVEL, hItemInfo.nRequireProfessionLevel)
			else
				szProfessionTip = szProfessionTip.."\n"
			end
			
			szTip = szTip.."<Text>text="..EncodeComponentsString(szProfessionTip).." font="..nFont.."</text>"
		end
		-----------阵营需求---------------
		if not hItemInfo.bCanGoodCampUse or not hItemInfo.bCanEvilCampUse or not hItemInfo.bCanNeutralCampUse then
			if not hItemInfo.bCanGoodCampUse and not hItemInfo.bCanEvilCampUse and not  hItemInfo.bCanNeutralCampUse then
				----------三个阵营都不可用,目前定了不显示----
				Log("物品nIndex = " .. nIndex .. "三个阵营均不可用")
			else
				local nFont = 166
				local szCampTip = g_tStrings.NEED
				if hItemInfo.bCanGoodCampUse then
					szCampTip = szCampTip..g_tStrings.TIP_CAMP_GOOD
					if hPlayer.nCamp == 1 then
						nFont = 162
					end
				end
				
				if hItemInfo.bCanEvilCampUse then
					if hItemInfo.bCanGoodCampUse then
						szCampTip = szCampTip..g_tStrings.TIP_COMMAND_OR
					end
					szCampTip = szCampTip..g_tStrings.TIP_CAMP_EVIL
					
					if hPlayer.nCamp == 2 then
						nFont = 162
					end
				end
				
				if hItemInfo.bCanNeutralCampUse then
					if hItemInfo.bCanGoodCampUse or hItemInfo.bCanEvilCampUse then
						szCampTip = szCampTip..g_tStrings.TIP_COMMAND_OR
					end
					szCampTip = szCampTip..g_tStrings.TIP_CAMP_NEUTRAL
					
					if hPlayer.nCamp == 0 then
						nFont = 162
					end
				end
				szCampTip = szCampTip.."\n"
				szTip = szTip.."<Text>text="..EncodeComponentsString(szCampTip).." font="..nFont.."</text>"
			end
		end
		return szTip
end

function OutputItemTip(nType, ag1, ag2, ag3, Rect, bLink, szFromLootOrShop, aShopInfo, bNoCmp, nBookInfo, dwPlayerID)
	if nType == UI_OBJECT_ITEM  then
		local item = GetPlayerItem(GetClientPlayer(), ag1, ag2)
		if item then
			local szTip = GetItemTip(item, ag1, ag2, szFromLootOrShop, aShopInfo, nil, dwPlayerID)
			OutputTip(szTip, 345, Rect, nil, bLink, "item"..item.dwID)
			if not bNoCmp and item.nGenre == ITEM_GENRE.EQUIPMENT then
				local itemC, itemCAdd = GetEquipItemCompaireItem(item.nSub, item.nDetail)
				local dwBox, dwX = GetEquipItemEquiped(item.nSub, item.nDetail)
				if itemC then
					-- 七夕戒指处理不同的额外TIP
                    local clientPlayer = GetClientPlayer()
                    Player.dwQixiRingOwnerID = nil
                    if not IsRemotePlayer(clientPlayer.dwID) then
                        Player.dwQixiRingOwnerID = clientPlayer.dwID
                    end
					local szTip = GetItemTip(itemC, dwBox, dwX, nil, nil, true, dwPlayerID)
					OutputTip(szTip, 345, Rect, nil, bLink, "item"..item.dwID, false, true)
					if itemCAdd then
						szTip = GetItemTip(itemCAdd, nil, nil, nil, nil, true, dwPlayerID)
						OutputTip(szTip, 345, Rect, nil, bLink, "item"..item.dwID, false, true, true)
					end
					Player.dwQixiRingOwnerID = nil
				end
			elseif not bNoCmp and item.nGenre == ITEM_GENRE.MOUNT_ITEM and item.nSub == EQUIPMENT_SUB.HORSE then
				local nMountIndex = item.GetMountIndex()
				local horse = GetPlayerItem(GetClientPlayer(), INVENTORY_INDEX.EQUIP, EQUIPMENT_INVENTORY.HORSE)
				if horse then
					local nUiId = GetItemEnchantUIID(horse.GetMountEnchantID(nMountIndex));
					if nUiId > 0 then
						local szTip = GetEnchantTip(nUiId, true)
						OutputTip(szTip, 345, Rect, nil, false, nil, false, true)
					end
				end
			end		
		end
	elseif nType == UI_OBJECT_ITEM_ONLY_ID then
		local item = GetItem(ag1)
		if item then
			local szTip = GetItemTip(item, nil, nil, szFromLootOrShop, aShopInfo, nil, dwPlayerID)
			OutputTip(szTip, 345, Rect, nil, bLink, "item"..item.dwID)
			if not bNoCmp and item.nGenre == ITEM_GENRE.EQUIPMENT then
				local itemC, itemCAdd = GetEquipItemCompaireItem(item.nSub, item.nDetail)
				if itemC then
					-- 七夕戒指处理不同的额外TIP
                    local clientPlayer = GetClientPlayer()
                    Player.dwQixiRingOwnerID = nil
                    if not IsRemotePlayer(clientPlayer.dwID) then
                        Player.dwQixiRingOwnerID = clientPlayer.dwID
                    end
					local szTip = GetItemTip(itemC, nil, nil, nil, nil, true, dwPlayerID)
					OutputTip(szTip, 345, Rect, nil, bLink, "item"..item.dwID, false, true)
					if itemCAdd then
						szTip = GetItemTip(itemCAdd, nil, nil, nil, nil, true, dwPlayerID)
						OutputTip(szTip, 345, Rect, nil, bLink, "item"..item.dwID, false, true, true)
					end
					Player.dwQixiRingOwnerID = nil
				end
			elseif not bNoCmp and item.nGenre == ITEM_GENRE.MOUNT_ITEM and item.nSub == EQUIPMENT_SUB.HORSE then
				local nMountIndex = item.GetMountIndex()
				local horse = GetPlayerItem(GetClientPlayer(), INVENTORY_INDEX.EQUIP, EQUIPMENT_INVENTORY.HORSE)
				if horse then
					local nUiId = GetItemEnchantUIID(horse.GetMountEnchantID(nMountIndex));
					if nUiId > 0 then
						local szTip = GetEnchantTip(nUiId, true)
						OutputTip(szTip, 345, Rect, nil, false, nil, false, true)
					end
				end
			end		
		end
	elseif nType == UI_OBJECT_ITEM_INFO then
		local szTip, itemInfo = GetItemInfoTip(ag1, ag2, ag3, szFromLootOrShop, aShopInfo, nBookInfo, dwPlayerID)
		OutputTip(szTip, 345, Rect, nil, bLink, "iteminfo"..ag1.."x"..ag2.."x"..ag3)
		if not bNoCmp and itemInfo and itemInfo.nGenre == ITEM_GENRE.EQUIPMENT then
			local itemC, itemCAdd = GetEquipItemCompaireItem(itemInfo.nSub, itemInfo.nDetail)
			if itemC then
				-- 七夕戒指处理不同的额外TIP
                Player.dwQixiRingOwnerID = nil
                local clientPlayer = GetClientPlayer()
                if not IsRemotePlayer(clientPlayer.dwID) then
                    Player.dwQixiRingOwnerID = clientPlayer.dwID
                end
                    
				local szTip = GetItemTip(itemC, nil, nil, nil, nil, true, dwPlayerID)
				OutputTip(szTip, 345, Rect, nil, bLink, "iteminfo"..ag1.."x"..ag2.."x"..ag3, false, true)
				if itemCAdd then
					szTip = GetItemTip(itemCAdd, nil, nil, nil, nil, true, dwPlayerID)
					OutputTip(szTip, 345, Rect, nil, bLink, "iteminfo"..ag1.."x"..ag2.."x"..ag3, false, true, true)
				end
				Player.dwQixiRingOwnerID = nil
			end
		end	
	elseif nType == UI_OBJECT_MOUNT then
		local szTip = GetEnchantTip(ag1)
		if szTip and szTip ~= "" then
			OutputTip(szTip, 345, Rect)
		end
	end
end

function GetItemInfoTip(nVersion, nTabType, nIndex, szFromLootOrShop, aShopInfo, nBookInfo, dwPlayerID)
	local itemInfo = GetItemInfo(nTabType, nIndex)
	if not itemInfo then
		Trace("[UI ItemTip] error get itemInfo failed when OutputItemTipByInfo!\n")
		return ""
	end

	local player = GetClientPlayer()
	if not dwPlayerID then
		dwPlayerID = player.dwID
	end
	local szTip = ""
	-----------名字-------------------
	if not IsItemCanBeEquip(itemInfo.nGenre, itemInfo.nSub) then
		szTip = "<Text>text="..EncodeComponentsString(GetItemNameByItemInfo(itemInfo, nBookInfo).."\n")..
		" font=60"..GetItemFontColorByQuality(itemInfo.nQuality, true).." </text>"
		
	else
	----------加强化等级--------------
		szTip = "<Text>text="..EncodeComponentsString(GetItemNameByItemInfo(itemInfo, nBookInfo))..
		" font=60"..GetItemFontColorByQuality(itemInfo.nQuality, true).." </text>"

		szTip = szTip .. "<Text>text=" .. EncodeComponentsString("\t") .. " </text>"
		
		szTip = szTip .. "<Text>text=" .. EncodeComponentsString(FormatString(g_tStrings.STR_ITEM_H_STRENGTH_LEVEL, 0, itemInfo.nMaxStrengthLevel)) .. 
			" font=192 " .. " </text>"
	end
	
	-----------唯一性------------------
	--[[
	if itemInfo.nMaxExistAmount ~= 0 then
		if itemInfo.nMaxExistAmount == 1 then
			szTip = szTip.."<Text>text="..EncodeComponentsString(g_tStrings.STR_ITEM_H_UNIQUE).." font=106 </text>"
		else
			szTip = szTip.."<Text>text="..EncodeComponentsString(FormatString(g_tStrings.STR_ITEM_H_UNIQUE_MULTI, itemInfo.nMaxExistAmount)).." font=106 </text>"
		end
	end
	--]]

	-----------绑定属性----------------
	if itemInfo.nGenre == ITEM_GENRE.DESIGNATION then
		szTip = szTip.."<Text>text="..EncodeComponentsString(g_tStrings.DESGNATION_ITEM).." font=106 </text>"
	end
	if itemInfo.nGenre == ITEM_GENRE.TASK_ITEM then
		szTip = szTip.."<Text>text="..EncodeComponentsString(g_tStrings.STR_ITEM_H_QUEST_ITEM).." font=106 </text>"
	elseif itemInfo.nBindType == ITEM_BIND.INVALID then
	elseif itemInfo.nBindType == ITEM_BIND.NEVER_BIND then
	elseif itemInfo.nBindType == ITEM_BIND.BIND_ON_EQUIPPED then
		szTip = szTip.."<Text>text="..EncodeComponentsString(g_tStrings.STR_ITEM_H_BIND_AFTER_EQUIP).." font=106 </text>"
	elseif itemInfo.nBindType == ITEM_BIND.BIND_ON_PICKED then
		szTip = szTip.."<Text>text="..EncodeComponentsString(g_tStrings.STR_ITEM_H_BIND_AFTER_PICK).." font=106 </text>"
	elseif itemInfo.nBindType == ITEM_BIND.BIND_ON_TIME_LIMITATION then
		szTip = szTip.."<Text>text="..EncodeComponentsString(g_tStrings.STR_ITEM_H_BIND_TIME_LIMITATION1.."\n").." font=107 </text>"
		szTip = szTip.."<Text>text="..EncodeComponentsString(g_tStrings. STR_BIND_TIME_LIMITATION_DESC.."\n").." font=107</text>"
	end
	
	---------道具存在类型----------------
	local nExistType = itemInfo.nExistType
	if nExistType == ITEM_EXIST_TYPE.OFFLINE then
		szTip = szTip.."<Text>text="..EncodeComponentsString(g_tStrings.STR_ITEM_TIME_TYPE1.."\n").." font=107</text>"
	elseif nExistType == ITEM_EXIST_TYPE.ONLINE then
		szTip = szTip.."<Text>text="..EncodeComponentsString(g_tStrings.STR_ITEM_TIME_TYPE2.."\n").." font=107</text>"
	elseif nExistType == ITEM_EXIST_TYPE.ONLINEANDOFFLINE or nExistType == ITEM_EXIST_TYPE.TIMESTAMP then
		szTip = szTip.."<Text>text="..EncodeComponentsString(g_tStrings.STR_ITEM_TIME_TYPE3.."\n").." font=107</text>"
	end
	
	------OtherItemInfo 的需求信息----------
	if nTabType == ITEM_TABLE_TYPE.OTHER then 
		szTip = szTip .. GetOtherItemInfoTip(itemInfo, player, nIndex)
	end
	----------其他--------------------
	local nFont = 106
	local szText = ""
	if itemInfo.nGenre == ITEM_GENRE.EQUIPMENT then
		-------------装备类型-----------------
		szText = g_tStrings.tEquipTypeNameTable[itemInfo.nSub]
		if itemInfo.nSub == EQUIPMENT_SUB.MELEE_WEAPON or
			itemInfo.nSub == EQUIPMENT_SUB.RANGE_WEAPON or
			itemInfo.nSub == EQUIPMENT_SUB.ARROW then
			szText = szText.."\t"..GetWeapenType(itemInfo.nDetail)
		elseif itemInfo.nSub == EQUIPMENT_SUB.AMULET or
			itemInfo.nSub == EQUIPMENT_SUB.RING or
			itemInfo.nSub == EQUIPMENT_SUB.PENDANT then
			--饰品	
		elseif itemInfo.nSub == EQUIPMENT_SUB.PACKAGE then
			--包裹	
		elseif itemInfo.nSub == EQUIPMENT_SUB.BULLET then
			szText = szText.."\t"..g_tStrings.tBulletDetail[itemInfo.nDetail] or g_tStrings.UNKNOWN_WEAPON
		else
			--防具
		end	
		szTip = szTip.."<Text>text="..EncodeComponentsString(szText.."\n").." font="..nFont.." </text>"
		-------------基本属性-----------------
		local baseAttib = itemInfo.GetBaseAttrib()
		local nWeaponDamageMin, nWeaponDamageMax, fWeaponSpeed
		
		for k, v in pairs(baseAttib) do
			if v.nID == ATTRIBUTE_TYPE.MELEE_WEAPON_ATTACK_SPEED_BASE or
				v.nID == ATTRIBUTE_TYPE.RANGE_WEAPON_ATTACK_SPEED_BASE then
				--如果是武器速度,则转换参数
				v.nMin = v.nMin / 16
				v.nMax = v.nMax / 16
				fWeaponSpeed = v.nMin
			elseif v.nID == ATTRIBUTE_TYPE.MELEE_WEAPON_DAMAGE_BASE or v.nID == ATTRIBUTE_TYPE.RANGE_WEAPON_DAMAGE_BASE then
				nWeaponDamageMin = v.nMin
				nWeaponDamageMax = v.nMin + v.nMin1
			end
			if not v.nMin1 or not v.nMax1 then
				v.nMin1 = 0
				v.nMax1 = 0
			end
			if v.nID == ATTRIBUTE_TYPE.SKILL_EVENT_HANDLER then
				local skillEvent = g_tTable.SkillEvent:Search(v.nMin)
				if skillEvent then
					szText = FormatString(skillEvent.szDesc, v.nMin, v.nMax, v.nMin + v.nMin1, v.nMax + v.nMax1)
				else
					szText = "<text>text=\"unknown skill event id:"..v.nMin.."\"</text>"
				end
            elseif v.nID == ATTRIBUTE_TYPE.SET_EQUIPMENT_RECIPE then
                szText = GetEquipRecipeDesc(v.nMin, v.nMin1)
			else
				szText = FormatString(Table_GetBaseAttributeInfo(v.nID, false), v.nMin, v.nMax, v.nMin + v.nMin1, v.nMax + v.nMax1)
			end
			if itemInfo.nSub == EQUIPMENT_SUB.MELEE_WEAPON or
				itemInfo.nSub == EQUIPMENT_SUB.RANGE_WEAPON then
				if v.nID == ATTRIBUTE_TYPE.MELEE_WEAPON_ATTACK_SPEED_BASE or v.nID == ATTRIBUTE_TYPE.RANGE_WEAPON_ATTACK_SPEED_BASE then
					szText = "<text>text=\"\\\t\"</text>"..szText	-- .."<text>text=\"\\\n\"</text>"
				end
			elseif szText ~= "" then
				szText = szText.."<text>text=\"\\\n\"</text>"
			end	
			szTip = szTip..szText
		end
		
		-------------武器DPS-----------------
		if itemInfo.nSub == EQUIPMENT_SUB.MELEE_WEAPON or
			itemInfo.nSub == EQUIPMENT_SUB.RANGE_WEAPON then
			local fDps = (nWeaponDamageMin + nWeaponDamageMax) / 2 / fWeaponSpeed
			fDps = FixFloat(fDps, 1)
			szTip = szTip.."<Text>text="..EncodeComponentsString(g_tStrings.STR_ITEM_H_WEAPON_DPS..fDps.."\n").." font="..nFont.." </text>"
		end
		
		-----------魔法属性-------------------
		local magicAttrib = GetItemMagicAttrib(itemInfo.GetMagicAttribIndexList());
		for k, v in pairs(magicAttrib) do
			if v.nID == ATTRIBUTE_TYPE.SKILL_EVENT_HANDLER then
				local skillEvent = g_tTable.SkillEvent:Search(v.Param0)
				if skillEvent then
					szText = FormatString(skillEvent.szDesc, v.Param0, v.Param1, v.Param2, v.Param3)
				else
					szText = "<text>text=\"unknown skill event id:"..v.Param0.."\"</text>"
				end
            elseif v.nID == ATTRIBUTE_TYPE.SET_EQUIPMENT_RECIPE then
                szText = GetEquipRecipeDesc(v.Param0, v.Param2)
			else
				FormatAttributeValue(v)
				szText = FormatString(Table_GetMagicAttributeInfo(v.nID, false), v.Param0, v.Param1, v.Param2, v.Param3)			
			end
			if szText ~= "" then
				szText = szText.."<text>text=\"\\\n\"</text>"
			end	
			szTip = szTip..szText				
		end
		
		------------需求属性------------------
		if nTabType ~= ITEM_TABLE_TYPE.OTHER then
			local requireAttrib = itemInfo.GetRequireAttrib()
			for k, v in pairs(requireAttrib) do
				nFont = 106
				if player and not player.SatisfyRequire(v.nID, v.nValue) then
					nFont = 102
				end
				if v.nID == 7 then		-- 需求的是性别
					v.nValue = g_tStrings.tGender[v.nValue]
				end
				szText = FormatString(Table_GetRequireAttributeInfo(v.nID, false), v.nValue, nFont)
				if szText ~= "" then
					szText = szText.."<text>text=\"\\\n\"</text>"
				end
				szTip = szTip..szText
			end
		end
		-------------耐久度------------------
		if itemInfo.nSub == EQUIPMENT_SUB.AMULET or
			itemInfo.nSub == EQUIPMENT_SUB.RING or
			itemInfo.nSub == EQUIPMENT_SUB.PENDANT or
			itemInfo.nSub == EQUIPMENT_SUB.WAIST_EXTEND or 
			itemInfo.nSub == EQUIPMENT_SUB.BACK_EXTEND or 
			itemInfo.nSub == EQUIPMENT_SUB.BULLET or 
			itemInfo.nSub == EQUIPMENT_SUB.HORSE then --饰品(挂件),饰品没有耐久度
		elseif itemInfo.nSub == EQUIPMENT_SUB.PACKAGE then --包裹,包裹的耐久度用作格子大小
			szTip = szTip.."<Text>text="..EncodeComponentsString(FormatString(g_tStrings.STR_ITEM_H_BAG_SIZE, itemInfo.nMaxDurability)).." font=106 </text>"
		elseif itemInfo.nSub == EQUIPMENT_SUB.ARROW then --如果是远程武器弹药，则耐久度为数量
		else
			szTip = szTip.."<Text>text="..EncodeComponentsString(FormatString(g_tStrings.STR_ITEM_H_MAX_DURABILITY, itemInfo.nMaxDurability)).." font=106 </text>"
		end
		
		----------套装属性-------------------
		local setUiId, setTableOrg, nTotal, nHave, setAttrib = GetItemSetAttrib(itemInfo.nSetID, dwPlayerID);
		if setUiId then
			szTip = szTip.."<text>text=\"\\\n\"</text>".."<text>text="..EncodeComponentsString(FormatString(g_tStrings.STR_ITEM_H_SET_NAME, GetItemNameByUIID(setUiId), nHave, nTotal)).."font=100</text>"
			
			local setTable = {}
			for k, v in pairs(setTableOrg) do
				local nUsefulUiID = v.nUiId
				local tReplace = g_tTable.EquipSet:Search(itemInfo.nSetID, v.nUiId)
				if tReplace and tReplace.nReplaceUIID ~= 0 then
					nUsefulUiID = tReplace.nReplaceUIID
				end
			
				if setTable[nUsefulUiID] == nil then
					setTable[nUsefulUiID] = v.bEquiped
				else
					setTable[nUsefulUiID] = setTable[nUsefulUiID] or v.bEquiped
				end
			end
			
			for k, v in pairs(setTable) do
				local nF = 108
				if v then
					nF = 100
				end
				szTip = szTip .. GetFormatText(GetItemNameByUIID(k).."\n", nF)
			end
			
			local bFirst = true
			for k, v in pairs(setAttrib) do
				local szAt = ""
				if v.nID == ATTRIBUTE_TYPE.SKILL_EVENT_HANDLER then
					local skillEvent = g_tTable.SkillEvent:Search(v.nValue1)
					if skillEvent then
						szAt = FormatString(skillEvent.szDesc, v.nValue1, v.nValue2)
					else
						szAt = "<text>text=\"unknown skill event id:"..v.nValue1.."\"</text>"
					end
                elseif v.nID == ATTRIBUTE_TYPE.SET_EQUIPMENT_RECIPE then
                    szAt = GetEquipRecipeDesc(v.nValue1, v.nValue2)
				else
					FormatAttributeValue(v)
					szAt = FormatString(Table_GetMagicAttributeInfo(v.nID, true), v.nValue1, v.nValue2)
				end
				if szAt ~= "" then
					local nF = 108
					if v.bEquiped then
						nF = 105
					end
					szAt = string.gsub(szAt, "font=%d+", "font="..nF)
					if bFirst then
						bFirst = false
						szTip = szTip.."<text>text=\"\\\n\"</text>"
					end
					szTip = szTip.."<text>text=\"["..v.nCount.."]\"font="..nF.."</text>"..szAt.."<text>text=\"\\\n\"</text>"
				end
			end
			szTip = szTip..Table_GetItemDesc(setUiId).."<text>text=\"\\\n\"</text>"
		end		
	elseif itemInfo.nGenre == ITEM_GENRE.POTION then
		--药品
		local szType = g_tStrings.POISON_TYPE[itemInfo.nSub]
		if szType and szType ~= "" then
			szTip = szTip.."<Text>text="..EncodeComponentsString(szType.."\n").." font=106 </text>"
		end
	elseif itemInfo.nGenre == ITEM_GENRE.TASK_ITEM then
		--任务道具		
	elseif itemInfo.nGenre == ITEM_GENRE.MATERIAL then
		--材料
	elseif itemInfo.nGenre == ITEM_GENRE.BOOK then
		--书籍
		local nBookID, nSegID = GlobelRecipeID2BookID(nBookInfo)
		szTip = GetBookTipByItemInfo(itemInfo, nBookID, nSegID, true)
	elseif itemInfo.nGenre == ITEM_GENRE.DESIGNATION then
	   --称号道具
		if itemInfo.nPrefix ~= 0 then
			local aPrefix = g_tTable.Designation_Prefix:Search(itemInfo.nPrefix)
			if aPrefix then
				local szFinish = g_tStrings.DESGNATION_POSTFIX_UNGET
				if player.IsDesignationPrefixAcquired(itemInfo.nPrefix) then
					szFinish = g_tStrings.DESGNATION_POSTFIX_HAS_GET
				end
				local t = GetDesignationPrefixInfo(itemInfo.nPrefix)
				if t and t.nType == DESIGNATION_PREFIX_TYPE.WORLD_DESIGNATION then
					szTip = szTip..GetFormatText(FormatString(g_tStrings.USE_TO_GET_DESGNATION_WORLD, aPrefix.szName, szFinish), 105)
				elseif t and t.nType == DESIGNATION_PREFIX_TYPE.MILITARY_RANK_DESIGNATION then
					szTip = szTip..GetFormatText(FormatString(g_tStrings.USE_TO_GET_DESGNATION_MILITARY, aPrefix.szName, szFinish), 105)
				else
					szTip = szTip..GetFormatText(FormatString(g_tStrings.USE_TO_GET_DESGNATION_PREFIX, aPrefix.szName, szFinish), 105)
				end
			end
		end
		
		if itemInfo.nPostfix ~= 0 then
			local aPostfix = g_tTable.Designation_Postfix:Search(itemInfo.nPostfix)
			if aPostfix then
				local szFinish = g_tStrings.DESGNATION_POSTFIX_UNGET
				if player.IsDesignationPostfixAcquired(itemInfo.nPostfix) then
					szFinish = g_tStrings.DESGNATION_POSTFIX_HAS_GET
				end
				szTip = szTip..GetFormatText(FormatString(g_tStrings.USE_TO_GET_DESGNATION_POSTFIX, aPostfix.szName, szFinish), 105)
			end
		end
	elseif itemInfo.nGenre == ITEM_GENRE.BOX then
		szTip = szTip.."<Text>text="..EncodeComponentsString(g_tStrings.ITEM_TREASURE_BOX.."\n").."font=106</text>"
		if itemInfo.nSub == BOX_SUB_TYPE.NEED_KEY then
			local itemInfokey = GetItemAdvanceBoxKeyInfo(itemInfo.dwBoxTemplateID);
			szTip = szTip.."<Text>text="..EncodeComponentsString(FormatString(g_tStrings.ITEM_TREASURE_BOX_NEED_KEY.."\n", GetItemNameByItemInfo(itemInfokey))).."font=106</text>"
		end
	elseif itemInfo.nGenre == ITEM_GENRE.BOX_KEY then
		szTip = szTip.."<Text>text="..EncodeComponentsString(g_tStrings.ITEM_TREASURE_BOX_KEY.."\n").."font=106</text>"
	end
	
	if nTabType == ITEM_TABLE_TYPE.OTHER and g_LearnInfo[nIndex] then
		local recipe = GetRecipe(g_LearnInfo[nIndex].dwCraftID, g_LearnInfo[nIndex].dwRecipeID)
    	if recipe then
    		local profession = GetProfession(recipe.dwProfessionID);
			local bLearned = player.IsRecipeLearned(g_LearnInfo[nIndex].dwCraftID, g_LearnInfo[nIndex].dwRecipeID)
			
		    --local nMaxLevel               = player.GetProfessionMaxLevel(recipe.dwProfessionID)
	        local nLevel                  = player.GetProfessionLevel(recipe.dwProfessionID)
	        local nAdjustLevel            = player.GetProfessionAdjustLevel(recipe.dwProfessionID) or 0
	        --local nExp                    = player.GetProfessionProficiency(recipe.dwProfessionID)
			local nBranchID = player.GetProfessionBranch(recipe.dwProfessionID);    		
			
			if bLearned then
				szTip = szTip.."<Text>text="..EncodeComponentsString(g_tStrings.TIP_LEARNED).."font=108</text>"
			else
				local nFont = 105
				if (nLevel + nAdjustLevel) < recipe.dwRequireProfessionLevel then
					nFont = 102
				end
				szTip = szTip.."<Text>text="..EncodeComponentsString(FormatString(g_tStrings.STR_MSG_NEED_CRAFT, Table_GetProfessionName(recipe.dwProfessionID), recipe.dwRequireProfessionLevel)).." font="..nFont.." </text>"
				if recipe.dwRequireBranchID ~= 0 then
					local nFont = 105
					if nBranchID ~= recipe.dwRequireBranchID then
						nFont = 102
					end
	    			szTip = szTip.."<Text>text="..EncodeComponentsString(FormatString(g_tStrings.STR_MSG_NEED_BRANCH, Table_GetBranchName(recipe.dwProfessionID, recipe.dwRequireBranchID))).." font="..nFont.." </text>"					
				end
			end
    	end
	end
	
	local szItemDesc = GetItemDesc(itemInfo.nUiId)
	if szItemDesc and szItemDesc ~= "" then
		szTip = szTip..szItemDesc.."<text>text=\"\\\n\"</text>"
	end
	
    if nTabType == ITEM_TABLE_TYPE.OTHER and g_LearnInfo[nIndex] then
		local recipe = GetRecipe(g_LearnInfo[nIndex].dwCraftID, g_LearnInfo[nIndex].dwRecipeID)
		if recipe then
			szTip = szTip.."<text>text=\"\\\n\"</text>"..GetItemInfoTip(0, recipe.dwCreateItemType1, recipe.dwCreateItemIndex1)
			local bFirst = true
			for nIndex = 1, 6, 1 do
				local nType  = recipe["dwRequireItemType"..nIndex]
				local nID = recipe["dwRequireItemIndex"..nIndex]
				local nNeed  = recipe["dwRequireItemCount"..nIndex]
				local szText = ""
				
				if nNeed > 0 then
					local szComma = "，"
					if bFirst then
						szTip = szTip.."<Text>text="..EncodeComponentsString("\n"..g_tStrings.STR_CRAFT_TIP_RECIPE_REQUIRE).."font=163</text>"
						szComma = ""
						bFirst = false
					end
					
					local ItemInfo = GetItemInfo(nType, nID)
					local szItemName = GetItemNameByItemInfo(ItemInfo)
					local nCount   = player.GetItemAmount(nType, nID)
					local nFont = 163
					if nCount < nNeed then
						nFont = 102 
					end
					szTip = szTip.."<Text>text="..EncodeComponentsString(szComma.. szItemName .."("..nNeed..")").." font="..nFont.." </text>"
				end
			end
			if not bFirst then
				szTip = szTip.."<Text>text="..EncodeComponentsString("\n").." font=105 </text>"
			end
		end
	end

	-----------品质等级---------------------------
	if itemInfo.nGenre == ITEM_GENRE.EQUIPMENT then
		szTip = szTip.."<text>text="..EncodeComponentsString(FormatString(g_tStrings.STR_ITEM_H_ITEM_LEVEL, itemInfo.nLevel)).." font=163 </text>"
		szTip = szTip..GetFormatText("\n")
		
		------------装备分数-------------------
		local nBaseScore = itemInfo.nBaseScore
		if nBaseScore > 0 then
			szTip = szTip..GetFormatText(FormatString(g_tStrings.STR_ITEM_H_ITEM_SCORE, nBaseScore).."\n", 101)
		end
		
		if itemInfo.nRecommendID and g_tTable.EquipRecommend then 
			local t = g_tTable.EquipRecommend:Search(itemInfo.nRecommendID)
			if t and t.szDesc and t.szDesc ~= "" then
				szTip = szTip.."<text>text="..EncodeComponentsString(FormatString(g_tStrings.RECOMMEND_SCHOOL.."\n", t.szDesc)).." font=106 </text>"
			end
		end
	end
	
	local nRestTime = GetItemCoolDown(itemInfo.dwSkillID, itemInfo.dwSkillLevel, itemInfo.dwCoolDownID);
	if nRestTime and nRestTime ~= 0 and nRestTime ~= 16 then
		szTip = szTip.."<text>text="..EncodeComponentsString(FormatString(g_tStrings.STR_ITEM_USE_TIME, GetTimeText(nRestTime, true))).." font=106 </text>"  	
	end
	--以下为测试代码
	if IsCtrlKeyDown() then
		szTip = szTip.."<Text>text="..EncodeComponentsString("\n".."调试用信息：".."\n".."ID: "..nTabType..", "..nIndex.."\n".."ItemLevel: "..itemInfo.nLevel.."\n".."UIID: "..itemInfo.nUiId.."\n").." font=102 </text>"
	end
	--以上为测试代码
	
	return szTip, itemInfo
end

function GetItemTip(item, nBoxIndex, nBoxItemIndex, szFromLoorOrShop, aShopInfo, bCmp, dwPlayerID)
	local itemInfo = GetItemInfo(item.dwTabType, item.dwIndex)
	if not itemInfo then
		Trace("[UI ItemTip] error get itemInfo failed when OutputItemTip!\n")
		return ""
	end
	local player = GetClientPlayer()

	if not dwPlayerID then
		dwPlayerID = player.dwID
	end
	
	local szTip = ""
	if bCmp then -- 跟身上的装备比较时 如果是身上穿的 显示：当前装备
		szTip = "<Text>text="..EncodeComponentsString(g_tStrings.TIP_CURRENT_EQUIP).."font=163 </text>"
	end
	
	-----------名字-------------------
	if not IsItemCanBeEquip(item.nGenre, item.nSub) then
		szTip = szTip.."<Text>text="..EncodeComponentsString(GetItemNameByItem(item).."\n")..
			" font=60 "..GetItemFontColorByQuality(item.nQuality, true).." </text>"
	else
	----------加强化等级--------------
		szTip = szTip.."<Text>text="..EncodeComponentsString(GetItemNameByItem(item))..
			" font=60 "..GetItemFontColorByQuality(item.nQuality, true).." </text>"
		
		for i = 1, item.nStrengthLevel do
			szTip = szTip .. "<image>w=16 h=16 path=\"ui/Image/UICommon/FEPanel.UITex\" frame=39 </image>"
		end
		
		szTip = szTip .. "<Text>text=" .. EncodeComponentsString("\t") .. " </text>"
		
		szTip = szTip .. "<Text>text=" .. EncodeComponentsString(FormatString(g_tStrings.STR_ITEM_H_STRENGTH_LEVEL, item.nStrengthLevel, itemInfo.nMaxStrengthLevel)) .. 
			" font=192 " .. " </text>"
	end
	
	-----------绑定属性----------------
	if item.nGenre == ITEM_GENRE.DESIGNATION then
		szTip = szTip.."<Text>text="..EncodeComponentsString(g_tStrings.DESGNATION_ITEM).." font=106 </text>"
	end	
	if item.nGenre == ITEM_GENRE.TASK_ITEM then
		szTip = szTip.."<Text>text="..EncodeComponentsString(g_tStrings.STR_ITEM_H_QUEST_ITEM).." font=106 </text>"	
		
	elseif item.nBindType == ITEM_BIND.BIND_ON_TIME_LIMITATION then
		local scene = player.GetScene()
		local nLeftTime = scene.TimeLimitationBindItemGetLeftTime(item.dwID)
		
		if nLeftTime == 0 and item.bBind and not szFromLootOrShop then
			szTip = szTip.."<Text>text="..EncodeComponentsString(g_tStrings.STR_ITEM_H_HAS_BEEN_BIND).." font=107 </text>"
		elseif nLeftTime ~= 0 then
			local nM = math.floor(nLeftTime / 60)
			local szTime = nM..g_tStrings.STR_BUFF_H_TIME_M_SHORT
			szTime = szTime..(nLeftTime - nM * 60)..g_tStrings.STR_BUFF_H_TIME_S
			szTip = szTip.."<Text>text="..EncodeComponentsString(g_tStrings.STR_ITEM_H_BIND_TIME_LIMITATION.."："..szTime.."\n").." font=107</text>"
			szTip = szTip.."<Text>text="..EncodeComponentsString(g_tStrings. STR_BIND_TIME_LIMITATION_DESC.."\n").." font=107</text>"
		else
			szTip = szTip.."<Text>text="..EncodeComponentsString(g_tStrings.STR_ITEM_H_BIND_TIME_LIMITATION1.."\n").." font=107 </text>"
			szTip = szTip.."<Text>text="..EncodeComponentsString(g_tStrings. STR_BIND_TIME_LIMITATION_DESC.."\n").." font=107</text>"
		end
			
	elseif item.bBind and not szFromLootOrShop then
		szTip = szTip.."<Text>text="..EncodeComponentsString(g_tStrings.STR_ITEM_H_HAS_BEEN_BIND).." font=107 </text>"
	else
		if item.nBindType == ITEM_BIND.INVALID then
		elseif item.nBindType == ITEM_BIND.NEVER_BIND then
		elseif item.nBindType == ITEM_BIND.BIND_ON_EQUIPPED then
			szTip = szTip.."<Text>text="..EncodeComponentsString(g_tStrings.STR_ITEM_H_BIND_AFTER_EQUIP).." font=107 </text>"
		elseif item.nBindType == ITEM_BIND.BIND_ON_PICKED then
			if szFromLootOrShop == "shop" then
				szTip = szTip.."<Text>text="..EncodeComponentsString(g_tStrings.STR_ITEM_H_BIND_AFTER_BUY).." font=107</text>"
			else
				szTip = szTip.."<Text>text="..EncodeComponentsString(g_tStrings.STR_ITEM_H_BIND_AFTER_PICK).." font=107</text>"
			end
		end
	end
	
	if item.CheckIgnoreBindMask(ITEM_IGNORE_BIND_TYPE.MENTOR) then
		szTip = szTip..g_tStrings.STR_TRADE_MENTOR..GetFormatText("\n")
	end
	-----------唯一性------------------
	if item.nMaxExistAmount ~= 0 then
		if item.nMaxExistAmount == 1 then
			szTip = szTip.."<Text>text="..EncodeComponentsString(g_tStrings.STR_ITEM_H_UNIQUE).." font=106 </text>"
		else
			szTip = szTip.."<Text>text="..EncodeComponentsString(FormatString(g_tStrings.STR_ITEM_H_UNIQUE_MULTI, item.nMaxExistAmount)).." font=106 </text>"
		end
	end
	
	-----------道具存在类型----------------
	if itemInfo.nExistType == ITEM_EXIST_TYPE.OFFLINE then
		local nLeftTime = item.GetLeftExistTime() or 0
		if nLeftTime > 0 then
			local szTime = GetTimeText(nLeftTime)
			szTip = szTip..FormatString(g_tStrings.STR_ITEM_OFF_LINE_TIME_OVER, szTime)
		else
			szTip = szTip.."<Text>text="..EncodeComponentsString(g_tStrings.STR_ITEM_TIME_TYPE1.."\n").." font=107</text>"
		end
	elseif itemInfo.nExistType == ITEM_EXIST_TYPE.ONLINE then
		local nLeftTime = item.GetLeftExistTime() or 0
		if nLeftTime > 0 then
			local szTime = GetTimeText(nLeftTime)
			szTip = szTip..FormatString(g_tStrings.STR_ITEM_ON_LINE_TIME_OVER, szTime)
		else
			szTip = szTip.."<Text>text="..EncodeComponentsString(g_tStrings.STR_ITEM_TIME_TYPE2.."\n").." font=107</text>"
		end
	elseif itemInfo.nExistType == ITEM_EXIST_TYPE.ONLINEANDOFFLINE or itemInfo.nExistType == ITEM_EXIST_TYPE.TIMESTAMP then
		local nLeftTime = item.GetLeftExistTime() or 0
		if nLeftTime > 0 then
			local szTime = GetTimeText(nLeftTime)
			szTip = szTip..FormatString(g_tStrings.STR_ITEM_TIME_OVER, szTime)
		else
			szTip = szTip.."<Text>text="..EncodeComponentsString(g_tStrings.STR_ITEM_TIME_TYPE3.."\n").." font=107</text>"
		end
	end
	
	------OtherItemInfo 的需求信息----------
	if item.dwTabType == ITEM_TABLE_TYPE.OTHER then 
		szTip = szTip..GetOtherItemInfoTip(itemInfo, player, item.dwIndex)
	end
	
	----------其他--------------------
	local nFont = 106
	local szText = ""
	local szText1 = ""
	if item.nGenre == ITEM_GENRE.EQUIPMENT then
		-------------装备类型-----------------		
		szText = g_tStrings.tEquipTypeNameTable[item.nSub]
		if item.nSub == EQUIPMENT_SUB.MELEE_WEAPON or
			item.nSub == EQUIPMENT_SUB.ARROW or
			item.nSub == EQUIPMENT_SUB.RANGE_WEAPON then
			szText = szText.."\t"..GetWeapenType(item.nDetail)
--			Trace("[UI ITEMTIP]item.nDetail is "..item.nDetail.."\n")
			--Trace("[UI ITEMTIP]WEAPON_DETAIL.SLING_SHOT is "..WEAPON_DETAIL.SLING_SHOT.."\n")
		elseif item.nSub == EQUIPMENT_SUB.AMULET or
			item.nSub == EQUIPMENT_SUB.RING or
			item.nSub == EQUIPMENT_SUB.PENDANT then
			--饰品	
		elseif item.nSub == EQUIPMENT_SUB.PACKAGE then
			--包裹	
		else
			--防具
		end	
		szTip = szTip.."<Text>text="..EncodeComponentsString(szText.."\n").." font="..nFont.." </text>"

		-------------基本属性-----------------
		local baseAttib = item.GetBaseAttrib()
		local nWeaponDamageMin, nWeaponDamageMax, fWeaponSpeed
		
		for k, v in pairs(baseAttib) do
			if v.nID == ATTRIBUTE_TYPE.MELEE_WEAPON_ATTACK_SPEED_BASE or
				v.nID == ATTRIBUTE_TYPE.RANGE_WEAPON_ATTACK_SPEED_BASE then
				--如果是武器速度,则转换参数
				v.nValue1 = v.nValue1 / GLOBAL.GAME_FPS
				v.nValue2 = v.nValue2 / GLOBAL.GAME_FPS
				fWeaponSpeed = v.nValue1
			elseif v.nID == ATTRIBUTE_TYPE.MELEE_WEAPON_DAMAGE_BASE or v.nID == ATTRIBUTE_TYPE.RANGE_WEAPON_DAMAGE_BASE then
				nWeaponDamageMin = v.nValue1
				nWeaponDamageMax = v.nValue2
			end
			if v.nID == ATTRIBUTE_TYPE.SKILL_EVENT_HANDLER then
				local skillEvent = g_tTable.SkillEvent:Search(v.nValue1)
				if skillEvent then
					szText = FormatString(skillEvent.szDesc, v.nValue1, v.nValue2)
				else
					szText = "<text>text=\"unknown skill event id:"..v.nValue1.."\"</text>"
				end
            elseif v.nID == ATTRIBUTE_TYPE.SET_EQUIPMENT_RECIPE then
                szText = GetEquipRecipeDesc(v.nValue1, v.nValue2)
			else		
				szText = FormatString(Table_GetBaseAttributeInfo(v.nID, true), v.nValue1, v.nValue2)
			end
			
			if item.nSub == EQUIPMENT_SUB.MELEE_WEAPON or
				item.nSub == EQUIPMENT_SUB.RANGE_WEAPON then
				if v.nID == ATTRIBUTE_TYPE.MELEE_WEAPON_ATTACK_SPEED_BASE or v.nID == ATTRIBUTE_TYPE.RANGE_WEAPON_ATTACK_SPEED_BASE then
					szText = "<text>text=\"\\\t\"</text>"..szText	-- .."<text>text=\"\\\n\"</text>"
				end
			elseif szText ~= "" then
				szText = szText.."<text>text=\"\\\n\"</text>"
			end
			szTip = szTip..szText
		end
		
		-------------武器DPS-----------------
		if item.nSub == EQUIPMENT_SUB.MELEE_WEAPON or
			item.nSub == EQUIPMENT_SUB.RANGE_WEAPON then
			local fDps = 0
			if nWeaponDamageMin and  nWeaponDamageMax and fWeaponSpeed then
				fDps = (nWeaponDamageMin + nWeaponDamageMax) / 2 / fWeaponSpeed
				fDps = FixFloat(fDps, 1)
			end
			szTip = szTip.."<Text>text="..EncodeComponentsString(g_tStrings.STR_ITEM_H_WEAPON_DPS..fDps.."\n").." font="..nFont.." </text>"
		end
		
		-----------魔法属性-------------------
		local magicAttrib = item.GetMagicAttrib()
		local magicStrengthAttribOrg = item.GetMagicAttribByStrengthLevel(0)
		local magicStrengthAttrib = item.GetMagicAttribByStrengthLevel(item.nStrengthLevel)
		for k, v in pairs(magicAttrib) do
			szText1 = ""
			if v.nID == ATTRIBUTE_TYPE.SKILL_EVENT_HANDLER then
				local skillEvent = g_tTable.SkillEvent:Search(v.nValue1)
				if skillEvent then
					szText = FormatString(skillEvent.szDesc, v.nValue1, v.nValue2)
				else
					szText = "<text>text=\"unknown skill event id:"..v.nValue1.."\"</text>"
				end
                
            elseif v.nID == ATTRIBUTE_TYPE.SET_EQUIPMENT_RECIPE then
                szText = GetEquipRecipeDesc(v.nValue1, v.nValue2)
			else
				-----------------是否是装备强化属性------------------
				local bStrengthAttrib = false
				local nTop = #magicStrengthAttribOrg
				local index = 0
				for i = 1, nTop, 1 do
					if v.nID == magicStrengthAttribOrg[i].nID then
						bStrengthAttrib = true
						index = i
						break
					end
				end
				if not bStrengthAttrib then	
					FormatAttributeValue(v)
					szText = FormatString(Table_GetMagicAttributeInfo(v.nID, true), v.nValue1, v.nValue2)
				else
					szText = FormatString(Table_GetMagicAttributeInfo(v.nID, true), magicStrengthAttribOrg[index].nValue1, magicStrengthAttribOrg[index].nValue2)
					szText1 = "<text>text=" .. EncodeComponentsString(" (+" .. magicStrengthAttrib[index].nValue1 - magicStrengthAttribOrg[index].nValue1 .. ")") ..
						" font=192 " .. " </text>"
				end
			end
		
			szText1 = szText1.."<text>text=\"\\\n\"</text>"
			szTip = szTip..szText..szText1
		end
		
		------------孔的属性------------------
		local itemInfo = GetItemInfo(item.dwTabType, item.dwIndex)
		local nSlots = item.GetSlotCount()
		for i = 1, nSlots, 1 do
			local nLevel = 0
			local nEnchantID = item.GetMountDiamondEnchantID(i - 1)
			local diamon = false
			if nEnchantID > 0 then
				local nType, nIndex = GetDiamondInfoFromEnchantID(nEnchantID)
				if nType and nIndex then
					diamon = GetItemInfo(nType, nIndex)
				end
			end
			szText = ""
			if diamon then
				nLevel = diamon.nDetail
				szText = "<image>w=24 h=24 path=\"fromiconid\" frame=" .. Table_GetItemIconID(diamon.nUiId) .. "</image>"
			else
				szText = "<image>w=24 h=24 path=\"ui/Image/UICommon/FEPanel.UITex\" frame=5 </image>"
			end
			local bActived = item.IsDiamondSlotAttributeActive(i - 1)
			local equipAttrib = item.GetSlotAttrib(i - 1, nLevel)
			if not bActived then
				equipAttrib.Param0 = "？"
				equipAttrib.Param1 = "？"
			end
			
			local szTmpText = nil
			if not bActived then
				szTmpText = g_tStrings.tDeactives[equipAttrib.nID]
			end
			
			if not szTmpText then
				szTmpText = FormatString(Table_GetMagicAttributeInfo(equipAttrib.nID, true), equipAttrib.Param0, equipAttrib.Param1)
				szTmpText = GetPureText(szTmpText)
			end
			
			szTmpText = FormatString(g_tStrings.tFECommon.ITEM_SLOT_DESC, GetFEMountType(equipAttrib.nMask)) .. szTmpText
			
			if not bActived then
				szTmpText = "<text>text=" .. EncodeComponentsString(szTmpText) .. " font=161 valign=1 h=24 richtext=0 </text>"
			else
				szTmpText = "<text>text=" .. EncodeComponentsString(szTmpText) .. " font=105 valign=1 h=24 richtext=0 </text>"
			end
			szText = szText .. szTmpText
			
			if szText ~= "" then
				szText = szText.."<text>text=\"\\\n\"</text>"
			end
			szTip = szTip .. szText
		end
		
		-----------五彩石----------------
		if item.CanMountColorDiamond() then
			local nEnchantID = item.GetMountFEAEnchantID()
			if nEnchantID == 0 then
				szText = "<image>w=24 h=24 path=\"ui/Image/UICommon/FEPanel.UITex\" frame=5 </image>"
				szText = szText .. "<text>text=" .. EncodeComponentsString(g_tStrings.STR_ITEM_H_COLOR_DIAMOND) .. " font=161 valign=1 h=24 richtext=0 </text>"
				szText = szText.."<text>text=\"\\\n\"</text>"
				szTip = szTip .. szText
			elseif nEnchantID > 0 then
				local dwTabType, dwIndex = GetColorDiamondInfoFromEnchantID(nEnchantID)
				local itemInfo = GetItemInfo(dwTabType, dwIndex)
				szText = "<image>w=24 h=24 path=\"fromiconid\" frame=" .. Table_GetItemIconID(itemInfo.nUiId) .. "</image>"
				szTip = szTip .. szText
				
				szText = ""
				local aAttr = GetFEAInfoByEnchantID(nEnchantID)
				local bFirst = true
				for k, v in pairs(aAttr) do
					FormatAttributeValue(v)
					
					local szPText = FormatString(Table_GetMagicAttributeInfo(v.nID, true), v.nValue1, v.nValue2)
					szPText = GetPureText(szPText)
					if not bFirst then
						szPText = "      " .. szPText
					end
					bFirst = false
					local bActive = GetFEAActiveFlag(dwPlayerID, nBoxIndex, nBoxItemIndex, tonumber(k) - 1)
					if bActive then
						szText = "<text>text=\"" .. szPText .. "\" font=105 </text>"
					else
						--local szDiamondName = GetDiamondFormatString(v.nDiamondType)
						--szPText = szPText .. FormatString(g_tStrings.tActivation.COLOR_CONDITION, szDiamondName, g_tStrings.tActivation.COLOR_COMPARE[v.nCompare], v.nDiamondCount, v.nDiamondIntensity)
						szText = "<text>text=\"" .. szPText .. "\" font=161 </text>"
					end
					szText = szText .. "<text>text=\"\\\n\"</text>"
					szTip = szTip .. szText
				end
			end
		end
		
		if nSlots > 0 then
			szTip = szTip .. "<text>text=" .. EncodeComponentsString(g_tStrings.STR_ITEM_H_MOUNT_INFO) .. " font=105 </text>"
			szTip = szTip.."<text>text=\"\\\n\"</text>"
		end
		
		------------需求属性------------------
		if item.dwTabType ~= ITEM_TABLE_TYPE.OTHER then
			local requireAttrib = item.GetRequireAttrib()
			for k, v in pairs(requireAttrib) do
				nFont = 106
				if player and not player.SatisfyRequire(v.nID, v.nValue1, v.nValue2) then
					nFont = 102
				end
				if v.nID == 7 then		-- 需求的是性别
					v.nValue1 = g_tStrings.tGender[v.nValue1]
				end
				szText = FormatString(Table_GetRequireAttributeInfo(v.nID, true), v.nValue1, v.nValue2, nFont)
				if szText ~= "" then
					szText = szText.."<text>text=\"\\\n\"</text>"
				end
				szTip = szTip..szText
			end
		end
		
		-------------耐久度------------------
		if item.nSub == EQUIPMENT_SUB.AMULET or
			item.nSub == EQUIPMENT_SUB.RING or
			item.nSub == EQUIPMENT_SUB.PENDANT or
			item.nSub == EQUIPMENT_SUB.WAIST_EXTEND or
			item.nSub == EQUIPMENT_SUB.BACK_EXTEND or
			item.nSub == EQUIPMENT_SUB.BULLET or
			item.nSub == EQUIPMENT_SUB.HORSE then
			--饰品,饰品没有耐久度
		elseif item.nSub == EQUIPMENT_SUB.PACKAGE then
			--包裹,包裹的耐久度用作格子大小
			
			szTip = szTip.."<Text>text="..EncodeComponentsString(FormatString(g_tStrings.STR_ITEM_H_BAG_SIZE, item.nCurrentDurability)).." font=106 </text>"
		elseif item.nSub == EQUIPMENT_SUB.ARROW then
			--如果是远程武器弹药，则耐久度为数量
		else
			--武器、防具
			if item.nCurrentDurability == 0 then
				szTip = szTip.."<Text>text="..EncodeComponentsString(FormatString(g_tStrings.STR_ITEM_H_DURABILITY, item.nCurrentDurability, item.nMaxDurability)).." font=102 </text>"
			else
				szTip = szTip.."<Text>text="..EncodeComponentsString(FormatString(g_tStrings.STR_ITEM_H_DURABILITY, item.nCurrentDurability, item.nMaxDurability)).." font=106 </text>"
			end
		end
		
		---------- 附魔属性 -----------------
		local enchantAttrib = GetItemEnchantAttrib(item.dwPermanentEnchantID);
		if enchantAttrib then
			for k, v in pairs(enchantAttrib) do
				if v.nID == ATTRIBUTE_TYPE.SKILL_EVENT_HANDLER then
					local skillEvent = g_tTable.SkillEvent:Search(v.nValue1)
					if skillEvent then
						szText = FormatString(skillEvent.szDesc, v.nValue1, v.nValue2)
					else
						szText = "<text>text=\"unknown skill event id:"..v.nValue1.."\"</text>"
					end
                elseif v.nID == ATTRIBUTE_TYPE.SET_EQUIPMENT_RECIPE then
                    szText = GetEquipRecipeDesc(v.nValue1, v.nValue2)
				else
					FormatAttributeValue(v)
					szText = FormatString(Table_GetMagicAttributeInfo(v.nID, true), v.nValue1, v.nValue2)
				end
			
				szText = string.gsub(szText, "font=%d+", "font=113")
				if szText ~= "" then
					szText = szText.."<text>text=\"\\\n\"</text>"
				end 
				szTip = szTip..szText
			end
		end
		
		---------- 临时附魔属性 -------------
		local tempEnchantAttrib = GetItemEnchantAttrib(item.dwTemporaryEnchantID);
		if tempEnchantAttrib then
			for k, v in pairs(tempEnchantAttrib) do
				if v.nID == ATTRIBUTE_TYPE.SKILL_EVENT_HANDLER then
					local skillEvent = g_tTable.SkillEvent:Search(v.nValue1)
					if skillEvent then
						szText = FormatString(skillEvent.szDesc, v.nValue1, v.nValue2)
					else
						szText = "<text>text=\"unknown skill event id:"..v.nValue1.."\"</text>"
					end
                elseif v.nID == ATTRIBUTE_TYPE.SET_EQUIPMENT_RECIPE then
                    szText = GetEquipRecipeDesc(v.nValue1, v.nValue2)
				else
					FormatAttributeValue(v)
					szText = FormatString(Table_GetMagicAttributeInfo(v.nID, true), v.nValue1, v.nValue2)
				end
				
				szText = string.gsub(szText, "font=%d+", "font=113")
				if szText ~= "" then
					local szTime = FormatString(g_tStrings.STR_ITEM_TEMP_ECHANT_LEFT_TIME.."\n", GetTimeText(item.GetTemporaryEnchantLeftSeconds()))					
					szText = szText..GetFormatText(szTime, 102)
				end 
				szTip = szTip..szText
			end
		end
		----------套装属性-------------------
		local setUiId, setTableOrg, nTotal, nHave, setAttrib = GetItemSetAttrib(item.dwSetID, dwPlayerID);
		if setUiId then
			local setTable = {}
			nTotal = 0
			nHave = 0
			for k, v in pairs(setTableOrg) do
				local nUsefulUiID = v.nUiId
				local tReplace = g_tTable.EquipSet:Search(item.dwSetID, v.nUiId)
				if tReplace and tReplace.nReplaceUIID ~= 0 then
					nUsefulUiID = tReplace.nReplaceUIID
				end
			
				if setTable[nUsefulUiID] == nil then
					setTable[nUsefulUiID] = v.bEquiped
					nTotal = nTotal + 1
				else
					setTable[nUsefulUiID] = setTable[nUsefulUiID] or v.bEquiped
				end
			end
			
			for k, v in pairs(setTable) do
				if v then
					nHave = nHave + 1
				end
			end

			szTip = szTip.."<text>text=\"\\\n\"</text>".."<text>text="..EncodeComponentsString(FormatString(g_tStrings.STR_ITEM_H_SET_NAME, GetItemNameByUIID(setUiId), nHave, nTotal)).."font=100</text>"
			
			for k, v in pairs(setTable) do
				local nF = 108
				if v then
					nF = 100
				end
				szTip = szTip .. GetFormatText(GetItemNameByUIID(k).."\n", nF)
			end
			
			local bFirst = true
			for k, v in pairs(setAttrib) do
				local szAt = ""
				if v.nID == ATTRIBUTE_TYPE.SKILL_EVENT_HANDLER then
					local skillEvent = g_tTable.SkillEvent:Search(v.nValue1)
					if skillEvent then
						szAt = FormatString(skillEvent.szDesc, v.nValue1, v.nValue2)
					else
						szAt = "<text>text=\"unknown skill event id:"..v.nValue1.."\"</text>"
					end
                elseif v.nID == ATTRIBUTE_TYPE.SET_EQUIPMENT_RECIPE then
                    szAt = GetEquipRecipeDesc(v.nValue1, v.nValue2)
				else
					FormatAttributeValue(v)
					szAt = FormatString(Table_GetMagicAttributeInfo(v.nID, true), v.nValue1, v.nValue2)
				end		
				
				if szAt ~= "" then
					local nF = 108
					if v.bEquiped then
						nF = 105
					end
					szAt = string.gsub(szAt, "font=%d+", "font="..nF)
					if bFirst then
						bFirst = false
						szTip = szTip.."<text>text=\"\\\n\"</text>"
					end					
					szTip = szTip.."<text>text=\"["..v.nCount.."]\"font="..nF.."</text>"..szAt.."<text>text=\"\\\n\"</text>"
				end
			end
			szTip = szTip..Table_GetItemDesc(setUiId).."<text>text=\"\\\n\"</text>"
		end
		
	elseif item.nGenre == ITEM_GENRE.POTION then
		--药品
		local szType = g_tStrings.POISON_TYPE[item.nSub]
		if szType and szType ~= "" then
			szTip = szTip.."<Text>text="..EncodeComponentsString(szType.."\n").." font=106 </text>"
		end
	elseif item.nGenre == ITEM_GENRE.TASK_ITEM then
		--任务道具
	elseif item.nGenre == ITEM_GENRE.MATERIAL then
         --材料
        if item.nSub == ITEM_SUBTYPE_RECIPE then
            szTip = szTip .. GetFormatText(g_tStrings.STR_SKILL_RECIPE .. "\n", 162)
            local bRead = IsMystiqueRecipeRead(item)
            if bRead then
                szTip = szTip .. GetFormatText(g_tStrings.TIP_ALREADY_READ, 108)
            else
                szTip = szTip .. GetFormatText(g_tStrings.TIP_UNREAD, 105)
            end
        elseif item.nSub == ITEM_SUBTYPE_SKILL_RECIPE then 
            szTip = szTip .. GetFormatText(g_tStrings.STR_SKILL_RECIPE .. "\n", 162)
            local bRead, bExpMystique = IsMystiqueSkillRead(item)
            if not bExpMystique then -- 不是熟练度秘籍
                if bRead then
                    szTip = szTip .. GetFormatText(g_tStrings.TIP_LEARNED, 108)
                else
                    szTip = szTip .. GetFormatText(g_tStrings.TIP_UNLEARNED, 105)
                end
            end
        end
	elseif item.nGenre == ITEM_GENRE.BOOK then
		--书籍
		szTip = GetBookTipByItem(item, szFromLootOrShop)
	elseif item.nGenre == ITEM_GENRE.DESIGNATION then
		if itemInfo.nPrefix ~= 0 then
			local aPrefix = g_tTable.Designation_Prefix:Search(itemInfo.nPrefix)
			if aPrefix then
				local szFinish = g_tStrings.DESGNATION_POSTFIX_UNGET
				if player.IsDesignationPrefixAcquired(itemInfo.nPrefix) then
					szFinish = g_tStrings.DESGNATION_POSTFIX_HAS_GET
				end
				
				local t = GetDesignationPrefixInfo(itemInfo.nPrefix)
				if t and t.nType == DESIGNATION_PREFIX_TYPE.WORLD_DESIGNATION then
					szTip = szTip..GetFormatText(FormatString(g_tStrings.USE_TO_GET_DESGNATION_WORLD, aPrefix.szName, szFinish), 105)
				elseif t and t.nType == DESIGNATION_PREFIX_TYPE.MILITARY_RANK_DESIGNATION then
					szTip = szTip..GetFormatText(FormatString(g_tStrings.USE_TO_GET_DESGNATION_MILITARY, aPrefix.szName, szFinish), 105)
				else
					szTip = szTip..GetFormatText(FormatString(g_tStrings.USE_TO_GET_DESGNATION_PREFIX, aPrefix.szName, szFinish), 105)
				end
			end
		end
		
		if itemInfo.nPostfix ~= 0 then
			local aPostfix = g_tTable.Designation_Postfix:Search(itemInfo.nPostfix)
			if aPostfix then
				local szFinish = g_tStrings.DESGNATION_POSTFIX_UNGET
				if player.IsDesignationPostfixAcquired(itemInfo.nPostfix) then
					szFinish = g_tStrings.DESGNATION_POSTFIX_HAS_GET
				end
				szTip = szTip..GetFormatText(FormatString(g_tStrings.USE_TO_GET_DESGNATION_POSTFIX, aPostfix.szName, szFinish), 105)
			end
		end
	elseif item.nGenre == ITEM_GENRE.BOX then
		szTip = szTip.."<Text>text="..EncodeComponentsString(g_tStrings.ITEM_TREASURE_BOX.."\n").."font=106</text>"
		if item.nSub == BOX_SUB_TYPE.NEED_KEY then
			local itemInfokey = GetItemAdvanceBoxKeyInfo(itemInfo.dwBoxTemplateID);
			szTip = szTip.."<Text>text="..EncodeComponentsString(FormatString(g_tStrings.ITEM_TREASURE_BOX_NEED_KEY.."\n", GetItemNameByItemInfo(itemInfokey))).."font=106</text>"
		end
	elseif item.nGenre == ITEM_GENRE.BOX_KEY then
		szTip = szTip.."<Text>text="..EncodeComponentsString(g_tStrings.ITEM_TREASURE_BOX_KEY.."\n").."font=106</text>"		
	end
	if nBoxIndex and nBoxItemIndex and IsShopOpened() then
		if Cursor.GetCurrentIndex() == CURSOR.REPAIRE or Cursor.GetCurrentIndex() == CURSOR.UNABLEREPAIRE then
			local nPrice = GetShopItemRepairPrice(ShopPanel.nNpcID, ShopPanel.nShopID, nBoxIndex, nBoxItemIndex)
			if nPrice then
				szTip = szTip.."<text>text="..EncodeComponentsString(g_tStrings.STR_REPAIR_MONEY).." font=107 </text>"..
					GetMoneyTipText(nPrice, 106).."<text>text=\"\\\n\"</text>"
			end
		else
			if not item.bCanTrade then
				szTip = szTip.."<text>text="..EncodeComponentsString(g_tStrings.STR_SELL_CAN_NOT_SELL).."font=107 </text>"
			else
				local nPrice = GetShopItemSellPrice(ShopPanel.nNpcID, ShopPanel.nShopID, nBoxIndex, nBoxItemIndex)
				if nPrice then
					szTip = szTip.."<text>text="..EncodeComponentsString(g_tStrings.STR_SELL_OUT_MONEY).." font=107 </text>"..
						GetMoneyTipText(nPrice, 106).."<text>text=\"\\\n\"</text>"
				end
			end
		end
	end
	
	if item.dwTabType == ITEM_TABLE_TYPE.OTHER and g_LearnInfo[item.dwIndex] then
		local recipe = GetRecipe(g_LearnInfo[item.dwIndex].dwCraftID, g_LearnInfo[item.dwIndex].dwRecipeID)
	  	if recipe then
	  		local profession = GetProfession(recipe.dwProfessionID)
			local bLearned = player.IsRecipeLearned(g_LearnInfo[item.dwIndex].dwCraftID, g_LearnInfo[item.dwIndex].dwRecipeID)
			
			--local nMaxLevel               = player.GetProfessionMaxLevel(recipe.dwProfessionID)
	        local nLevel                  = player.GetProfessionLevel(recipe.dwProfessionID)
	        local nAdjustLevel            = player.GetProfessionAdjustLevel(recipe.dwProfessionID) or 0
	        --local nExp                    = player.GetProfessionProficiency(recipe.dwProfessionID)
	    
			local nBranchID = player.GetProfessionBranch(recipe.dwProfessionID);    		
			
			if bLearned then
				szTip = szTip.."<Text>text="..EncodeComponentsString(g_tStrings.TIP_LEARNED1).."font=108</text>"
			else
				local nFont = 105
				if (nLevel + nAdjustLevel) < recipe.dwRequireProfessionLevel then
					nFont = 102
				end
				szTip = szTip.."<Text>text="..EncodeComponentsString(FormatString(g_tStrings.STR_MSG_NEED_CRAFT, Table_GetProfessionName(recipe.dwProfessionID), recipe.dwRequireProfessionLevel)).." font="..nFont.." </text>"
				if recipe.dwRequireBranchID ~= 0 then
					local nFont = 105
					if nBranchID ~= recipe.dwRequireBranchID then
						nFont = 102
					end
	    			szTip = szTip.."<Text>text="..EncodeComponentsString(FormatString(g_tStrings.STR_MSG_NEED_BRANCH, Table_GetBranchName(recipe.dwProfessionID, recipe.dwRequireBranchID))).." font="..nFont.." </text>"					
				end
			end
	    end
	end
	
	local szImg = "\\ui\\image\\item_pic\\"..itemInfo.nUiId..".UITex"
	if IsFileExist(szImg) then
		szTip = szTip.."<image>path="..EncodeComponentsString(szImg).." frame=0 </image><text>text=\"\\\n\"</text>"
	end	
	
	local szItemDesc = GetItemDesc(item.nUiId)
	if szItemDesc and szItemDesc ~= "" then
		szTip = szTip..szItemDesc.."<text>text=\"\\\n\"</text>"
	end
	
	if item.dwTabType == ITEM_TABLE_TYPE.OTHER and g_LearnInfo[item.dwIndex] then
		local recipe = GetRecipe(g_LearnInfo[item.dwIndex].dwCraftID, g_LearnInfo[item.dwIndex].dwRecipeID)
		if recipe then
			szTip = szTip.."<text>text=\"\\\n\"</text>"..GetItemInfoTip(0, recipe.dwCreateItemType1, recipe.dwCreateItemIndex1)
			
			local bFirst = true
			for nIndex = 1, 6, 1 do
				local nType  = recipe["dwRequireItemType"..nIndex]
				local nID	 = recipe["dwRequireItemIndex"..nIndex]
				local nNeed  = recipe["dwRequireItemCount"..nIndex]
				local szText = ""
				
				if nNeed > 0 then
					local szComma = "，"
					if bFirst then
						szTip = szTip.."<Text>text="..EncodeComponentsString("\n"..g_tStrings.STR_CRAFT_TIP_RECIPE_REQUIRE).."font=163</text>"
						szComma = ""
						bFirst = false
					end
					
					local ItemInfo = GetItemInfo(nType, nID)
					local szItemName = GetItemNameByItemInfo(ItemInfo)
					local nCount   = player.GetItemAmount(nType, nID)
					local nFont = 163
					if nCount < nNeed then
						nFont = 102 
					end
					szTip = szTip.."<Text>text="..EncodeComponentsString(szComma.. szItemName .."("..nNeed..")").." font="..nFont.." </text>"
				end
			end
			if not bFirst then
				szTip = szTip.."<Text>text="..EncodeComponentsString("\n").." font=105 </text>"
			end
		end
	end
	
	------------品质等级-------------------
	if item.nGenre == ITEM_GENRE.EQUIPMENT then
		szTip = szTip..GetFormatText(FormatString(g_tStrings.STR_ITEM_H_ITEM_LEVEL, item.nLevel), 163)
		local nStrengthQuality = GetStrengthQualityLevel(item.nStrengthLevel)
		if nStrengthQuality and nStrengthQuality > 0 then
			local szContent = g_tStrings.STR_EN_PREV_PANT..FormatString(g_tStrings.STR_ADD_VALUE, nStrengthQuality) .. g_tStrings.STR_EN_END_PANT 
			szTip = szTip..GetFormatText(" "..szContent , 192)
		end
		szTip = szTip..GetFormatText("\n")
		
		------------装备分数-------------------
		local nBaseScore = item.nBaseScore
		local nStrengthScore = item.nStrengthScore
		local nStoneScore = item.nMountsScore
		if nBaseScore > 0 then
			szTip = szTip..GetFormatText(FormatString(g_tStrings.STR_ITEM_H_ITEM_SCORE, nBaseScore), 101)
			if nStrengthScore >0 or nStoneScore > 0 then
				local szContent = g_tStrings.STR_EN_PREV_PANT..
					FormatString(g_tStrings.STR_ADD_VALUE, nStrengthScore) ..
					FormatString(g_tStrings.STR_ADD_VALUE, nStoneScore) ..
					g_tStrings.STR_EN_END_PANT 
					
				szTip = szTip..GetFormatText(" "..szContent , 192)
			end
			szTip = szTip..GetFormatText("\n")
		end
		
		if itemInfo.nRecommendID and g_tTable.EquipRecommend then 
			local t = g_tTable.EquipRecommend:Search(itemInfo.nRecommendID)
			if t and t.szDesc and t.szDesc ~= "" then
				szTip = szTip.."<text>text="..EncodeComponentsString(FormatString(g_tStrings.RECOMMEND_SCHOOL.."\n", t.szDesc)).." font=106 </text>"
			end
		end	
	end
	
	if itemInfo then
	  	local nRestTime = GetItemCoolDown(itemInfo.dwSkillID, itemInfo.dwSkillLevel, itemInfo.dwCoolDownID);
	  	if nRestTime and nRestTime ~= 0 and nRestTime ~= 16 then
	  		szTip = szTip.."<text>text="..EncodeComponentsString(FormatString(g_tStrings.STR_ITEM_USE_TIME, GetTimeText(nRestTime, true))).." font=106 </text>"  	
	  	end
	end	
		
	if aShopInfo then
		if g_tReputation.tReputationTable[aShopInfo.dwNeedForce] and aShopInfo.dwNeedLevel > 3 and g_tReputation.tReputationLevelTable[aShopInfo.dwNeedLevel] then
			local szText = FormatString(g_tStrings.STR_LEARN_NEED_REPUT_BUY, g_tReputation.tReputationTable[aShopInfo.dwNeedForce].szName, g_tReputation.tReputationLevelTable[aShopInfo.dwNeedLevel].szLevel)
			local nFont = 102
			if aShopInfo.bSatisfy then
				nFont = 2
			end
			szTip = szTip.."<text>text="..EncodeComponentsString(szText).."font="..nFont.."</text>"
		end
		
		if aShopInfo.nRequireAchievementRecord and aShopInfo.nRequireAchievementRecord > 0 then
			local szText = FormatString(g_tStrings.STR_NEED_ACHIVEMENT_RECORD_BUY, aShopInfo.nRequireAchievementRecord)
			local nFont = 102
			if aShopInfo.bSatisfyAchievementRecord then
				nFont = 2
			end
			szTip = szTip.."<text>text="..EncodeComponentsString(szText).."font="..nFont.."</text>"
		end
		
		if aShopInfo.bLimit then
			if aShopInfo.nLeftCount == 0 then
				szTip = szTip.."<text>text="..EncodeComponentsString(g_tStrings.SHOP_ITEM_SELL_OUT).." font=102 </text>"
			else
			    local nTotal, nLeft = GetBuyLimitItemCDLeftFrames()
			    if nTotal and nLeft and nLeft > 0 then
			    	local szTime = GetTimeText(nLeft, true, false, true)
			    	if szTime and szTime ~= "" then
						szTip = szTip.."<text>text="..EncodeComponentsString(FormatString(g_tStrings.SHOP_ITEM_REST, szTime)).." font=102 </text>"
					end
				end
			end
		end
		
		if aShopInfo.nCampTitle and aShopInfo.nCampTitle > 0 then
			local szTitleLevel = FormatString(g_tStrings.STR_CAMP_TITLE_LEVEL, g_tStrings.STR_CAMP_TITLE_NUMBER[aShopInfo.nCampTitle])
			local szText = FormatString(g_tStrings.STR_NEED_CAMP_TITLE_BUY, szTitleLevel)
			local nFont = 102
			if aShopInfo.bSatisfyCampTitle then
				nFont = 2
			end
			szTip = szTip.."<text>text="..EncodeComponentsString(szText).."font="..nFont.."</text>"
		end
		
		if aShopInfo.nRequireCorpsValue and aShopInfo.nRequireCorpsValue > 0 then
			local dwMask = aShopInfo.dwMaskCorpsNeedToCheck % (2 ^ ARENA_TYPE.ARENA_END)
			local szCorpsText = nil
			for i = ARENA_TYPE.ARENA_END - 1, ARENA_TYPE.ARENA_BEGIN, -1 do
				if dwMask >= 2 ^ i then
					if szCorpsText then
						szCorpsText = g_tStrings.tCorpsType[i] .. g_tStrings.TIP_COMMAND_OR .. szCorpsText
					else
						szCorpsText = g_tStrings.tCorpsType[i]
					end
					
					dwMask = dwMask - 2 ^ i;
				end
			end
			
			local szText = FormatString(g_tStrings.STR_NEED_COPRS_VALUE_BUY, szCorpsText, aShopInfo.nRequireCorpsValue)
			local nFont = 102
			if aShopInfo.bSatisfyCorpsValue then
				nFont = 2
			end
			szTip = szTip.."<text>text="..EncodeComponentsString(szText).."font="..nFont.."</text>"
		end
	end
	
	------- 装备是否可分解 --------
	local dwBox, dwX = player.GetItemPos(item.dwID)
	if not player.CanBreakEquip(dwBox, dwX) and item.nGenre == ITEM_GENRE.EQUIPMENT then
		szTip = szTip .. "<text>text=" .. EncodeComponentsString(g_tStrings.STR_ITEM_H_CAN_NOT_BREAK) .. " font=102 </text>"
	end
	
	------- 七夕配对玩家名字 ------
    
	local tQixiRings = {[1899] = true, [1900] = true, [1901] = true, [1902] = true, [1903] = true, [1904] = true, [1905] = true, [1906] = true, [1907] = true, [1908] = true, [1909] = true, [1910] = true, [1911] = true, [1912] = true, [1913] = true, [1914] = true, [1915] = true, }
	if not IsRemotePlayer(player.dwID) and Player.dwQixiRingOwnerID and not IsRemotePlayer(Player.dwQixiRingOwnerID) and Player.tInscriptionList and item.nGenre == ITEM_GENRE.EQUIPMENT and item.nSub == EQUIPMENT_SUB.RING and tQixiRings[item.dwIndex] then
		local tInfo = Player.tInscriptionList[Player.dwQixiRingOwnerID]
		if (tInfo and tInfo[1] and tInfo[1].szName) then
			local szTipQixiRing = ""
			if tInfo[2] and tInfo[2].szName and tInfo[3] and tInfo[3].szName then
				szTipQixiRing = "<Text>text=" .. EncodeComponentsString(g_tStrings.QIXI_TIPS.TITLE) .. " font=100 </text>" ..
					"<Text>text=" .. EncodeComponentsString(g_tStrings.QIXI_TIPS.MARK[1]) .. " font=105 </text>" ..
					"<Text>text=" .. EncodeComponentsString("%s") .. " font=112 </text>" ..
					"<Text>text=" .. EncodeComponentsString(g_tStrings.QIXI_TIPS.AND) .. " font=105 </text>" ..
					"<Text>text=" .. EncodeComponentsString("%s") .. " font=112 </text>" ..
					"<Text>text=" .. EncodeComponentsString(g_tStrings.QIXI_TIPS.MARK[2]) .. " font=105 </text>" ..
					"<Text>text=" .. EncodeComponentsString("%s") .. " font=112 </text>" ..
					"<Text>text=" .. EncodeComponentsString(g_tStrings.QIXI_TIPS.TAIL) .. " font=105 </text>"
				szTipQixiRing = szTipQixiRing:format(tInfo[1].szName, tInfo[2].szName, tInfo[3].szName)
			elseif tInfo[2] and tInfo[2].szName then
				szTipQixiRing = "<Text>text=" .. EncodeComponentsString(g_tStrings.QIXI_TIPS.TITLE) .. " font=100 </text>" ..
					"<Text>text=" .. EncodeComponentsString(g_tStrings.QIXI_TIPS.MARK[1]) .. " font=105 </text>" ..
					"<Text>text=" .. EncodeComponentsString("%s") .. " font=112 </text>" ..
					"<Text>text=" .. EncodeComponentsString(g_tStrings.QIXI_TIPS.AND) .. " font=105 </text>" ..
					"<Text>text=" .. EncodeComponentsString("%s") .. " font=112 </text>" ..
					"<Text>text=" .. EncodeComponentsString(g_tStrings.QIXI_TIPS.TAIL) .. " font=105 </text>"
				szTipQixiRing = szTipQixiRing:format(tInfo[1].szName, tInfo[2].szName)
			elseif tInfo[3] and tInfo[3].szName then
				szTipQixiRing = "<Text>text=" .. EncodeComponentsString(g_tStrings.QIXI_TIPS.TITLE) .. " font=100 </text>" ..
					"<Text>text=" .. EncodeComponentsString(g_tStrings.QIXI_TIPS.MARK[1]) .. " font=105 </text>" ..
					"<Text>text=" .. EncodeComponentsString("%s") .. " font=112 </text>" ..
					"<Text>text=" .. EncodeComponentsString(g_tStrings.QIXI_TIPS.AND) .. " font=105 </text>" ..
					"<Text>text=" .. EncodeComponentsString("%s") .. " font=112 </text>" ..
					"<Text>text=" .. EncodeComponentsString(g_tStrings.QIXI_TIPS.TAIL) .. " font=105 </text>"
				szTipQixiRing = szTipQixiRing:format(tInfo[1].szName, tInfo[3].szName)
			end
			szTip = szTip .. szTipQixiRing
		end
	end
	--七夕连理枝
	local tQixiPendants = {[4196] = true, [4197] = true, [4198] = true, [4199] = true, [4200] = true, [4201] = true, [4202] = true, [4203] = true, [4204] = true, [4205] = true, [4206] = true, [4207] = true, [4208] = true,}
	if not IsRemotePlayer(player.dwID) and Player.dwQixiRingOwnerID and not IsRemotePlayer(Player.dwQixiRingOwnerID) and Player.tInscriptionList and item.nGenre == ITEM_GENRE.EQUIPMENT and item.nSub == EQUIPMENT_SUB.PENDANT and tQixiPendants[item.dwIndex] then
		local tInfo = Player.tInscriptionList[Player.dwQixiRingOwnerID]
		if (tInfo and tInfo[1] and tInfo[1].szName) then
			local szTipQixiRing = ""
			if tInfo[4] and tInfo[4].szName then
				szTipQixiRing = "<Text>text=" .. EncodeComponentsString(g_tStrings.QIXI_TIPS2.TITLE) .. " font=100 </text>" ..
					"<Text>text=" .. EncodeComponentsString(g_tStrings.QIXI_TIPS2.MARK[1]) .. " font=105 </text>" ..
					"<Text>text=" .. EncodeComponentsString("%s") .. " font=112 </text>" ..
					"<Text>text=" .. EncodeComponentsString(g_tStrings.QIXI_TIPS2.AND) .. " font=105 </text>" ..
					"<Text>text=" .. EncodeComponentsString("%s") .. " font=112 </text>" ..
					"<Text>text=" .. EncodeComponentsString(g_tStrings.QIXI_TIPS2.TAIL) .. " font=105 </text>"
				szTipQixiRing = szTipQixiRing:format(tInfo[1].szName, tInfo[4].szName)
			end
			szTip = szTip .. szTipQixiRing
		end
	end
	--以下为测试代码
	if IsCtrlKeyDown() then
		szTip = szTip.."<Text>text="..EncodeComponentsString("\n".."调试用信息：".."\n".."ID: "..item.dwTabType..", "..item.dwIndex.."\n".."ItemLevel: "..item.nLevel.."\n".."RepresentID: "..item.nRepresentID.."\n".."UIID: "..item.nUiId.."\n").." font=102 </text>"
	end
	--以上为测试代码
	
	return szTip, item
end

function GetSpiStoneDesc(dwID)
	local aAttr = GetFEAInfoByEnchantID(dwID)
	if not aAttr or #aAttr == 0 then
		return ""
	end
	
	local szDesc = "\"</text>"
	local szTmp = ""
	local bFirst = true
	
	for k, v in pairs(aAttr) do
		if not bFirst then
			szDesc = szDesc .. "<text>text=\"\\\n\"</text>"
		end
		if bFirst then
			bFirst = false
		end
		
		FormatAttributeValue(v)
		local szText = FormatString(g_tStrings.tActivation.COLOR_ATTRIBUTE, k)
		szTmp = FormatString(Table_GetMagicAttributeInfo(v.nID, true), v.nValue1, v.nValue2)
		local szPText = szText .. GetPureText(szTmp)
		szDesc = szDesc .. "<Text>text=\"" .. szPText .. "\n" .. "\" font=100 </text>"
		szText = FormatString(g_tStrings.tActivation.COLOR_CONDITION, k)
		
		local szName = GetDiamondFormatString(v.nDiamondType)
		szTmp = FormatString(g_tStrings.tActivation.COLOR_CONDITION1, szName, g_tStrings.tActivation.COLOR_COMPARE[v.nCompare], v.nDiamondCount)
		szText = szText .. szTmp .. "\n"
		
		szTmp = FormatString(g_tStrings.tActivation.COLOR_CONDITION2, szName, v.nDiamondIntensity)
		szText = szText .. szTmp
		szDesc = szDesc .. "<Text>text=\"" .. szText .. "\" font=177 </text>"
	end
	szDesc = szDesc .. "<Text>"
	return szDesc
end