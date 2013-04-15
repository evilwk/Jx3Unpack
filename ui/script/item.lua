------------------这里是与物品有关的公共操作------------------------------

g_ItemNameToID = {}

local _g_UIItemLockTable = {}

function AddUILockItem(key, dwBox, dwX)
	local aItem = _g_UIItemLockTable[key]
	if aItem then
		for k, v in pairs(aItem) do
			if v[1] == dwBox and v[2] == dwX then
				return
			end
		end
		table.insert(aItem, {dwBox, dwX})
	else
		_g_UIItemLockTable[key] = {{dwBox, dwX}}
	end
	local box = GetUIItemBox(dwBox, dwX, true)
	if box then
		box:EnableObject(false)
	end
end

function RemoveUILockItem(key, dwBox, dwX)
	local aItem = _g_UIItemLockTable[key]
	if dwBox and dwX then
		if aItem then
			for k, v in pairs(aItem) do
				if v[1] == dwBox and v[2] == dwX then
					table.remove(aItem, k)
				end
			end
			if table.getn(aItem) == 0 then
				_g_UIItemLockTable[key] = nil
			end
		end
		local box = GetUIItemBox(dwBox, dwX, true)
		if box then
			box:EnableObject(true)
		end
	else
		if aItem then
			for k, v in pairs(aItem) do
				local box = GetUIItemBox(v[1], v[2], true)
				if box then
					box:EnableObject(true)
				end
			end
			_g_UIItemLockTable[key] = nil
		end
	end
	RefreshUILockItem()
end

function RefreshUILockItem()
	for k, v in pairs(_g_UIItemLockTable) do
		for kI, vI in pairs(v) do
			local box = GetUIItemBox(vI[1], vI[2], true)
			if box then
				box:EnableObject(false)
			end
		end
	end
end

function GetUIItemBox(dwBox, dwX, bEvenUnVisible)
	if dwBox == INVENTORY_INDEX.EQUIP then
		if dwX >= EQUIPMENT_INVENTORY.PACKAGE1 and dwX <= EQUIPMENT_INVENTORY.PACKAGE4 then
			return Bag_GetItemBox(dwBox, dwX, bEvenUnVisible)
		elseif dwX >= EQUIPMENT_INVENTORY.BANK_PACKAGE1 and dwX <= EQUIPMENT_INVENTORY.BANK_PACKAGE5 then
			return BankPanel_GetItemBox(dwBox, dwX, bEvenUnVisible)
		else
			return CharacterPanel_GetItemBox(dwBox, dwX, bEvenUnVisible)
		end
	elseif dwBox == INVENTORY_INDEX.BANK then
		 return BankPanel_GetItemBox(dwBox, dwX, bEvenUnVisible)
	elseif dwBox == INVENTORY_INDEX.SOLD_LIST then
		return ShopPanel_GetItemBox(dwBox, dwX, bEvenUnVisible)
	elseif dwBox >= INVENTORY_INDEX.PACKAGE and dwBox <= INVENTORY_INDEX.PACKAGE4 then
		return BagPanel_GetItemBox(dwBox, dwX, bEvenUnVisible)
	elseif dwBox >= INVENTORY_INDEX.BANK_PACKAGE1 and dwBox <= INVENTORY_INDEX.BANK_PACKAGE5 then
		return BankPanel_GetItemBox(dwBox, dwX, bEvenUnVisible)
	elseif dwBox == INVENTORY_GUILD_BANK then
		return GuildBankPanel_GetItemBox(dwBox, dwX, bEvenUnVisible)
	elseif dwBox == INVENTORY_INDEX.BULLET_PACKAGE then
		return WeaponBag_GetItemBox(dwBox, dwX, bEvenUnVisible)
	end
end

function UpdataItemInfoBoxObject(hBox, nVersion, nTabType, nIndex, nCount)
    local ItemInfo = GetItemInfo(nTabType, nIndex)
    hBox:SetObject(UI_OBJECT_ITEM_INFO, ItemInfo.nUiId, nVersion, nTabType, nIndex)
    hBox:SetObjectIcon(Table_GetItemIconID(ItemInfo.nUiId))
    hBox.nCount = nCount
    UpdateItemBoxExtend(hBox, ItemInfo)
    if nCount ~= 1 and ItemInfo.nGenre ~= ITEM_GENRE.BOOK then
        hBox:SetOverTextPosition(0, ITEM_POSITION.RIGHT_BOTTOM)
        hBox:SetOverText(0, nCount)
    end
    hBox.OnItemMouseEnter = function()
        this.bEnter = true
        this:SetObjectMouseOver(1)
        local x, y = this:GetAbsPos()
        local w, h = this:GetSize()
        local _, nVersion, nTabType, nIndex = this:GetObjectData()
        OutputItemTip(UI_OBJECT_ITEM_INFO, nVersion, nTabType, nIndex, {x, y, w, h}, nil, nil, nil, nil, this.count)				
    end
    hBox.OnItemRefreshTip = hBox.OnItemMouseEnter
    hBox.OnItemMouseLeave = function()
        this.bEnter = false
        HideTip()
        if not this:GetParent().bSelected then
            this:SetObjectMouseOver(0)
        end
    end
end

function UpdataItemBoxObject(box, dwBox, dwX, item)
	if item then
		--如果该格子有物品
		box:SetObject(UI_OBJECT_ITEM, item.nUiId, dwBox, dwX, item.nVersion, item.dwTabType, item.dwIndex)			
		box:SetObjectIcon(Table_GetItemIconID(item.nUiId))
		if box:IsObjectMouseOver() then
			local x, y = box:GetAbsPos()
			local w, h = box:GetSize()
			OutputItemTip(UI_OBJECT_ITEM, dwBox, dwX, nil, {x, y, w, h})	
		end
		
		if item.bCanStack and item.nStackNum > 1 then
			box:SetOverText(0, item.nStackNum)
		else
			box:SetOverText(0, "")
		end
		
		UpdateItemBoxExtend(box, item)
	else
		--如果没有物品
		box:ClearObject()
		if box:IsObjectMouseOver() then
			HideTip()	
		end
		box:SetOverText(0, "")
	end	
	
	if not Hand_IsEmpty() then
		local boxHand = Hand_Get()
		if boxHand:GetObjectType() == UI_OBJECT_ITEM then
			local _, dwHBox, dwHX = boxHand:GetObjectData()
			if dwHBox == dwBox and dwHX == dwX then
				if item then
					Hand_Pick(box)
				else
					Hand_Clear()
				end
			end
		end
	end
end

function UpdateItemBoxExtend(box, item, nQuality)
	local szImage, nFrame, szAnimate, nGroup
	local nGenre 
	if item then
		nGenre, nQuality = item.nGenre, item.nQuality
	end
	if nGenre == ITEM_GENRE.TASK_ITEM then
		szImage, nFrame = "\\ui\\Image\\Common\\Box.UITex", 41
	--elseif nQuality == 1 then
		--szImage, nFrame = "\\ui\\Image\\Common\\Box.UITex", 41
	--elseif nQuality == 2 then
		--szImage, nFrame = "\\ui\\Image\\Common\\Box.UITex", 13
	elseif nQuality == 3 then
		szImage, nFrame = "\\ui\\Image\\Common\\Box.UITex", 43
	elseif nQuality == 4 then
		szImage, nFrame = "\\ui\\Image\\Common\\Box.UITex", 42
	elseif nQuality == 5 then
		szImage, nFrame = "\\ui\\Image\\Common\\Box.UITex", 44
		szAnimate, nGroup = "\\ui\\Image\\Common\\Box.UITex", 17
	end
	
	if szImage then
		box:SetExtentImage(szImage, nFrame)
	else
		box:ClearExtentImage()
	end
	
	if szAnimate then
		box:SetExtentAnimate(szAnimate, nGroup, -1)
	else
		box:ClearExtentAnimate(szAnimate)
	end
end

function UpdateMountBoxObject(box, nUiId, bObjectExist)
	if bObjectExist then
		--如果该格子有物品
		box:SetObject(UI_OBJECT_MOUNT, nUiId)			
		box:SetObjectIcon(Table_GetItemIconID(nUiId))
		if box:IsObjectMouseOver() then
			local x, y = box:GetAbsPos()
			local w, h = box:GetSize()
			OutputItemTip(UI_OBJECT_MOUNT, nUiId, nil, nil, {x, y, w, h})
		end
		
		box:SetOverText(0, "")
	else
		--如果没有物品
		box:ClearObject()
		if box:IsObjectMouseOver() then
			HideTip()	
		end
		box:SetOverText(0, "")
	end	
end

--拆分物品
function OnSplitBoxItem(box, fnAutoClose)
	local player = GetClientPlayer()
	local _, nBoxIndex, nBoxItemIndex = box:GetObjectData()
	local item = GetPlayerItem(player, nBoxIndex, nBoxItemIndex)
	if not item or not item.bCanStack or item.nStackNum < 2 then
		--如果没有物品，或是装备且不是远程武器弹药，或物品不可叠加，或物品的叠加数小于2， 则不允许拆分
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_ERROR_ITEM_CANNOT_SPLIT)
		PlayTipSound("002")
		return
	end
	Cursor.Switch(CURSOR.NORMAL)

	local x, y = box:GetAbsPos()
	local w, h = box:GetSize()	
	local ActionSure = function(nCount)
    	if nCount > 0 and box:IsValid() then
    		Hand_Pick(box, nCount)
    	end
	end
	local nIndex = box:GetRoot().nIndex
	local AutoClose = fnAutoClose
	if not AutoClose then 
		AutoClose = function()
			if IsBagPanelOpened(nIndex) then
				return false
			end
			return true
		end
	end
	GetUserInputNumber(1, item.nStackNum, {x, y, x + w, y + h}, ActionSure, ActionCancel, AutoClose)	
end

function OnExchangeItem(dwBox1, dwX1, dwBox2, dwX2, nCount)
	local player = GetClientPlayer()
	if dwBox1 == INVENTORY_GUILD_BANK then
		if nCount then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_GUILD_BANK_ERROR_NO_SPLIT)
			return false
		end
		if dwBox2 == INVENTORY_GUILD_BANK then	
			local item1 = GetPlayerItem(player, dwBox1, dwX1)
			local item2 = GetPlayerItem(player, dwBox2, dwX2)
			local nPage1, nIndex1 = GetGuildBankPagePos(dwBox1, dwX1)
			local nPage2, nIndex2 = GetGuildBankPagePos(dwBox2, dwX2)
			
			if item1 and item2 and nPage1 == nPage2 and 
            item1.dwTabType == item2.dwTabType and  item1.dwIndex == item2.dwIndex and
			item2.bCanStack and item2.nStackNum < item2.nMaxStackNum then
				if not nCount then
					nCount = item1.nStackNum
				end
				if nCount + item2.nStackNum > item2.nMaxStackNum then
					nCount = item2.nMaxStackNum - item2.nStackNum
				end
				
				GetTongClient().StackItemInRepertory(nPage1, nIndex1, nIndex2, nCount)
				return true
			else
				GetTongClient().ExchangeRepertoryItemPos(nPage1, nIndex1, nPage2, nIndex2)
				return true
			end
		else
			if CheckHaveLocked(SAFE_LOCK_EFFECT_TYPE.TONG_REPERTORY, "帮会仓库") then
				return
			end
			
			local item1 = GetPlayerItem(player, dwBox1, dwX1)
			local item2 = GetPlayerItem(player, dwBox2, dwX2)
			if item1 then
				if item2 then
					if item1.dwTabType == item2.dwTabType and item1.dwIndex == item2.dwIndex and item1.bCanStack then
						if item1.nStackNum + item2.nStackNum <= item1.nMaxStackNum then
							local nPage1, nIndex1 = GetGuildBankPagePos(dwBox1, dwX1)
							GetTongClient().TakeRepertoryItem(nPage1, nIndex1, dwBox2, dwX2)
							return true					
						else
							OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_GUILD_BANK_ERROR_OVER_MAX_STACK_NUM)
							return false
						end
					else
						OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_GUILD_BANK_ERROR_NO_EXCHANGE)
						return false
					end
				else
					local nPage1, nIndex1 = GetGuildBankPagePos(dwBox1, dwX1)
					GetTongClient().TakeRepertoryItem(nPage1, nIndex1, dwBox2, dwX2)
				end
				return true
			elseif item2 then
				if item2.nGenre == ITEM_GENRE.TASK_ITEM then
					OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.GUILD_BANK_CAN_NOT_PUT_TASK_ITME)
					return false
				end				

				if item2.bBind then
					OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.GUILD_BANK_CAN_NOT_PUT_BIND_ITME)
					return false
				end	
				
				local itemInfo = GetItemInfo(item2.dwTabType, item2.dwIndex)
				if itemInfo.nExistType ~= ITEM_EXIST_TYPE.PERMANENT then
					OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.ERROR_GUILD_NOT_TIME_LIMIT)
					return false
				end			
				
				local nPage1, nIndex1 = GetGuildBankPagePos(dwBox1, dwX1)
				GetTongClient().PutItemToRepertory(dwBox2, dwX2, nPage1, nIndex1)
				return true
			end
			return true
		end
	elseif dwBox2 == INVENTORY_GUILD_BANK then
		if CheckHaveLocked(SAFE_LOCK_EFFECT_TYPE.TONG_REPERTORY, "帮会仓库") then
			return
		end
			
		local item1 = GetPlayerItem(player, dwBox1, dwX1)
		local item2 = GetPlayerItem(player, dwBox2, dwX2)
		if item1 and item2 then
			local nPage2, nIndex2 = GetGuildBankPagePos(dwBox2, dwX2)
			if item1.dwTabType == item2.dwTabType and item1.dwIndex == item2.dwIndex and item1.bCanStack then
				if item2.nStackNum == item2.nMaxStackNum then
					OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_GUILD_BANK_ERROR_NO_EXCHANGE)
					return false
				end

				if not nCount then
					nCount = item1.nStackNum
				end
				if nCount + item2.nStackNum > item2.nMaxStackNum then
					nCount = item2.nMaxStackNum - item2.nStackNum
				end
				
				GetTongClient().StackRepertoryItem(dwBox1, dwX1, nPage2, nIndex2, nCount)
				return true
			end
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_GUILD_BANK_ERROR_NO_EXCHANGE)
			return false
		elseif item1 then
			if item1.nGenre == ITEM_GENRE.TASK_ITEM then
				OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.GUILD_BANK_CAN_NOT_PUT_TASK_ITME)
				return false
			end

			if item1.bBind then
				OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.GUILD_BANK_CAN_NOT_PUT_BIND_ITME)
				return false
			end
		
			local itemInfo = GetItemInfo(item1.dwTabType, item1.dwIndex)
			if itemInfo.nExistType ~= ITEM_EXIST_TYPE.PERMANENT then
				OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.ERROR_GUILD_NOT_TIME_LIMIT)
				return false
			end							
		
			local nPage2, nIndex2 = GetGuildBankPagePos(dwBox2, dwX2)
			if nCount then
				OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_GUILD_BANK_ERROR_NO_SPLIT_1)
				--GetTongClient().StackRepertoryItem(dwBox1, dwX1, nPage2, nIndex2, nCount)
			else	
				GetTongClient().PutItemToRepertory(dwBox1, dwX1, nPage2, nIndex2)
				return true
			end
		elseif item2 then
			if nCount then
				OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_GUILD_BANK_ERROR_NO_SPLIT)
				return false
			end

			local nPage2, nIndex2 = GetGuildBankPagePos(dwBox2, dwX2)
			GetTongClient().TakeRepertoryItem(nPage2, nIndex2, dwBox1, dwX1)
			return true
		end
		return true
	end
	
	local nCanExchange = player.CanExchange(dwBox1, dwX1, dwBox2, dwX2)
	if nCanExchange == ITEM_RESULT_CODE.SUCCESS then
		local item = nil
		local dwEqPos = nil
		if dwBox1 == INVENTORY_INDEX.EQUIP then
			item = GetPlayerItem(player, dwBox2, dwX2)
			dwEqPos = dwX1
		elseif dwBox2 == INVENTORY_INDEX.EQUIP then
			item = GetPlayerItem(player, dwBox1, dwX1)
			dwEqPos = dwX2
		end
		if item and item.nBindType == ITEM_BIND.BIND_ON_EQUIPPED and not item.bBind and dwEqPos and 
			(dwEqPos < EQUIPMENT_INVENTORY.PACKAGE1 or dwEqPos > EQUIPMENT_INVENTORY.BANK_PACKAGE5 or 
				(item.nGenre == ITEM_GENRE.EQUIPMENT and item.nSub == EQUIPMENT_SUB.PACKAGE)) then
				
			local nUiId = item.nUiId
			local msg = 
			{
				szMessage = FormatLinkString(g_tStrings.EQUIP_BIND_ITEM_SURE, "font=162", GetFormatText("["..GetItemNameByItem(item).."]", 
					"166"..GetItemFontColorByQuality(item.nQuality, true))), 
				bRichText = true,
				szName = "BindItemSure", 
				{szOption = g_tStrings.STR_HOTKEY_SURE, 
				fnAction = function() 
					GetClientPlayer().ExchangeItem(dwBox1, dwX1, dwBox2, dwX2, nCount)
					PlayItemSound(nUiId)
				end
				},
				{szOption = g_tStrings.STR_HOTKEY_CANCEL},
			}
			MessageBox(msg)
		else
			player.ExchangeItem(dwBox1, dwX1, dwBox2, dwX2, nCount)
		end
		return true
	else
		if nCanExchange == ITEM_RESULT_CODE.BANK_PASSWORD_EXIST and CheckHaveLocked(SAFE_LOCK_EFFECT_TYPE.BANK) then
			return
		end
		GlobalEventHandler.OnItemRespond(nCanExchange)
	end
	return false
end

function MountRidesEquip(dwBox, dwX)
	if not dwBox or not dwX then
		return
	end
	
	local player = GetClientPlayer()
	local item = GetPlayerItem(player, dwBox, dwX)
	local nResult = player.CanMountItem(dwBox, dwX, INVENTORY_INDEX.EQUIP, EQUIPMENT_INVENTORY.HORSE)
	
	if nResult == ENCHANT_RESULT_CODE.SUCCESS then
		if IsItemDestroyOnMount(item.dwEnchantID) then
			local nUiId = item.nUiId
			local msg = 
			{
				szMessage = FormatLinkString(g_tStrings.BIND_RIDES_EQUIP_SURE, "font=162", GetFormatText("["..GetItemNameByItem(item).."]", 
					"166"..GetItemFontColorByQuality(item.nQuality, true))), 
				bRichText = true,			
				szName = "BindRidesEquipSure", 
				{szOption = g_tStrings.STR_HOTKEY_SURE,
				fnAction = function() 
					RemoteCallToServer("OnMountItem", dwBox, dwX, INVENTORY_INDEX.EQUIP, EQUIPMENT_INVENTORY.HORSE)
					PlayItemSound(nUiId)--
				end
				},
				{szOption = g_tStrings.STR_HOTKEY_CANCEL},
			}
			MessageBox(msg)
		else
			RemoteCallToServer("OnMountItem", dwBox, dwX, INVENTORY_INDEX.EQUIP, EQUIPMENT_INVENTORY.HORSE)
		end
	else
		local szMsg = g_tStrings.STR_MOUNT_RESULT_CODE[nResult]
		if szMsg and szMsg ~= "" then
			OutputMessage("MSG_ANNOUNCE_RED", szMsg);
		end
	end
end

function UnMountRidesEquip(nMountIndex)
	local player = GetClientPlayer()
	local nResult = player.CanUnMountItem(INVENTORY_INDEX.EQUIP, EQUIPMENT_INVENTORY.HORSE, nMountIndex)
	
	if nResult == ENCHANT_RESULT_CODE.SUCCESS then
		local horse = GetPlayerItem(player, INVENTORY_INDEX.EQUIP, EQUIPMENT_INVENTORY.HORSE)
		
		if IsItemDestroyOnMount(horse.GetMountEnchantID(nMountIndex)) then
			local nUiId = GetItemEnchantUIID(horse.GetMountEnchantID(nMountIndex));
			local msg = 
			{
				szMessage = FormatLinkString(g_tStrings.DESTROY_RIDES_EQUIP_SURE, "font=162", GetFormatText("["..GetItemNameByUIID(nUiId).."]", 162)),
				bRichText = true,				
				szName = "DestroyRidesEquipSure",
				{szOption = g_tStrings.STR_HOTKEY_SURE,
				fnAction = function() 
					RemoteCallToServer("OnUnMountItem", INVENTORY_INDEX.EQUIP, EQUIPMENT_INVENTORY.HORSE, nMountIndex)
					PlayItemSound(nUiId)--
				end
				},
				{szOption = g_tStrings.STR_HOTKEY_CANCEL},
			}
			MessageBox(msg)
		else
			RemoteCallToServer("OnUnMountItem", INVENTORY_INDEX.EQUIP, EQUIPMENT_INVENTORY.HORSE, nMountIndex)
		end
	else
		local szMsg = g_tStrings.STR_MOUNT_RESULT_CODE[nResult]
		if szMsg ~= "" then
			OutputMessage("MSG_ANNOUNCE_RED", szMsg);
		end
	end 
end

function ExchangeRidesEquip(nMountIndex, dwBox, dwX)
	local player = GetClientPlayer()
	local horse = player.GetItem(INVENTORY_INDEX.EQUIP, EQUIPMENT_INVENTORY.HORSE)
	local item = GetPlayerItem(player, dwBox, dwX)
	local nItemMountIndex = item.GetMountIndex()
	
	if nItemMountIndex ~= nMountIndex then
		return
	end
	
	local nCanUnMount = player.CanUnMountItem(INVENTORY_INDEX.EQUIP, EQUIPMENT_INVENTORY.HORSE, nMountIndex)
	local nCanMount = player.CanMountItem(dwBox, dwX, INVENTORY_INDEX.EQUIP, EQUIPMENT_INVENTORY.HORSE)
	
	if nCanUnMount ~= ENCHANT_RESULT_CODE.SUCCESS then
		local szMsg = g_tStrings.STR_MOUNT_RESULT_CODE[nCanUnMount]
		if szMsg ~= "" then
			OutputMessage("MSG_ANNOUNCE_RED", szMsg);
		end
		return
	end
		
	if nCanMount ~= ENCHANT_RESULT_CODE.SUCCESS then
		local szMsg = g_tStrings.STR_MOUNT_RESULT_CODE[nCanMount]
		if szMsg ~= "" then
			OutputMessage("MSG_ANNOUNCE_RED", szMsg);
		end
		return
	end
	
	local bDestroyNew = IsItemDestroyOnMount(item.dwEnchantID);
	local bDestroyOld = IsItemDestroyOnMount(horse.GetMountEnchantID(nMountIndex));
	
	local szMsg = nil
	if bDestroyNew and bDestroyOld then
		szMsg = FormatLinkString(g_tStrings.EXCHANGE_RIDES_EQUIP_SURE2, "font=162", 
			GetFormatText("["..GetItemNameByUIID(GetItemEnchantUIID(horse.GetMountEnchantID(nMountIndex))).."]", 162),
			GetFormatText("["..GetItemNameByItem(item).."]", "166"..GetItemFontColorByQuality(item.nQuality, true)))
	elseif bDestroyOld then
		szMsg = FormatLinkString(g_tStrings.EXCHANGE_RIDES_EQUIP_SURE1, "font=162", 
			GetFormatText("["..GetItemNameByUIID(GetItemEnchantUIID(horse.GetMountEnchantID(nMountIndex))).."]", 162),
			GetFormatText("["..GetItemNameByItem(item).."]", "166"..GetItemFontColorByQuality(item.nQuality, true)))
	elseif bDestroyNew then
		szMsg = FormatLinkString(g_tStrings.BIND_RIDES_EQUIP_SURE, "font=162", GetFormatText("["..GetItemNameByItem(item).."]", 
			"166"..GetItemFontColorByQuality(item.nQuality, true)))
	end
	
	if szMsg then
		local nUiId = item.nUiId
		local msg = 
		{
			szMessage = szMsg,
			bRichText = true,
			szName = "ExchangeRidesEquipSure", 
			{szOption = g_tStrings.STR_HOTKEY_SURE,
			fnAction = function() 
				RemoteCallToServer("OnMountItem", dwBox, dwX, INVENTORY_INDEX.EQUIP, EQUIPMENT_INVENTORY.HORSE)
				PlayItemSound(nUiId)--
			end
			},
			{szOption = g_tStrings.STR_HOTKEY_CANCEL},
		}
		MessageBox(msg)
	else
		RemoteCallToServer("OnMountItem", dwBox, dwX, INVENTORY_INDEX.EQUIP, EQUIPMENT_INVENTORY.HORSE)
	end
	
end

function UpdataItemCDProgress(player, box, v1, v2, v3)
	local nLeftTime
	local bCool, nLeft, nTotal, bBroken
	if v3 then
		bCool, nLeft, nTotal, bBroken = player.GetItemCDProgress(v1, v2, v3)
	elseif v2 then
		bCool, nLeft, nTotal, bBroken = player.GetItemCDProgress(v1, v2)
	else
		bCool, nLeft, nTotal, bBroken = player.GetItemCDProgress(v1)
	end
	
    if bCool then
        if nLeft == 0 and nTotal == 0 then
            if box:IsObjectCoolDown() then
                box:SetObjectCoolDown(0)
                box:SetObjectSparking(1)
            end
        else
            box:SetObjectCoolDown(1)
            box:SetCoolDownPercentage(1 - nLeft / nTotal)
        end
		nLeftTime = nLeft
    else
        box:SetObjectCoolDown(0)
    end
    
    box:EnableObjectEquip(not bBroken)
	
	return nLeftTime
end

function OnUseItem(dwBox, dwX, box)
	local player = GetClientPlayer()
	local item = GetPlayerItem(player, dwBox, dwX)
	if not item then

		return
	end
	
	local bNormal = true
	local skill = GetSkill(item.dwSkillID, item.dwSkillLevel);
	if skill then
		local nMode = skill.nCastMode
		if (nMode == SKILL_CAST_MODE.POINT_AREA) or (nMode == SKILL_CAST_MODE.POINT) then
	    	local fnAction = function(x, y, z)
	    		Selection_HideSFX()
	    		UseItem(dwBox, dwX, nMode, x, y, z)
	    	end
	    	local fnCancel = function()
	    		Selection_HideSFX()
	    	end
	    	local fnCondition = function(x, y, z)
	    		if SceneMain_IsCursorIn() then
					if skill.CheckDistance(GetClientPlayer().dwID, x, y, z) == SKILL_RESULT_CODE.SUCCESS then
						if not bNormal then
							Selection_HideSFX()
						end
						
						Selection_ShowSFX(skill.dwSkillID, skill.dwSkillLevel)
						bNormal = true
						return true
					else
						if bNormal then
							Selection_HideSFX()
						end
						Selection_ShowSFX(SKILL_SELECT_POINT_UNNORMAL.nSkillID, SKILL_SELECT_POINT_UNNORMAL.nLevel)	
						bNormal = false
					end
	    		end
	    		return false
	    	end
	    	Selection_ShowSFX(skill.dwSkillID, skill.dwSkillLevel)
	    	UserSelect.SelectPoint(fnAction, fnCancel, fnCondition, box)		
		elseif nMode == SKILL_CAST_MODE.ITEM then
	    	local fnAction = function(dwTargetBox, dwTargetX)
	    		local player = GetClientPlayer()
	    		local item = GetPlayerItem(player, dwBox, dwX)
	    		if item.dwTabType == 5 and g_EnchantInfo[item.dwIndex] then
	    			local itemTarget = GetPlayerItem(player, dwTargetBox, dwTargetX)
	    			if IsTempEnchantAttribute(g_EnchantInfo[item.dwIndex].EnchantID) then
						local tempEnchantAttrib = GetItemEnchantAttrib(itemTarget.dwTemporaryEnchantID);
						if tempEnchantAttrib then
							local szAttr = ""
							for k, v in pairs(tempEnchantAttrib) do
								FormatAttributeValue(v)
								local szInfo = FormatString(Table_GetMagicAttributeInfo(v.nID, true), v.nValue1, v.nValue2)
								szInfo = string.gsub(szInfo, "font=%d+", "font=113")
								if szInfo ~= "" then
									szInfo = szInfo.."<text>text=\"\\\n\"font=113</text>"
								end 
								szAttr = szAttr..szInfo
							end
							local msg = 
							{
								szMessage = "<text>text="..EncodeComponentsString(g_tStrings.MSG_ON_USE_ITEM).."</text>"
									..szAttr.."<text>text="..EncodeComponentsString(g_tStrings.MSG_SURE_QO_ON).."</text>", 
								bRichText = true,
								szName = "ReplaceEnchantSure", 
								{szOption = g_tStrings.STR_HOTKEY_SURE, 
									fnAction = function() 
										UseItem(dwBox, dwX, nMode, dwTargetBox, dwTargetX)
									end
								},
								{szOption = g_tStrings.STR_HOTKEY_CANCEL},
							}
							MessageBox(msg)
							return
						end		
	    			else
						local enchantAttrib = GetItemEnchantAttrib(itemTarget.dwPermanentEnchantID);
						if enchantAttrib then
							local szAttr = ""
							for k, v in pairs(enchantAttrib) do
								FormatAttributeValue(v)
								local szInfo = FormatString(Table_GetMagicAttributeInfo(v.nID, true), v.nValue1, v.nValue2)
								szInfo = string.gsub(szInfo, "font=%d+", "font=113")
								if szInfo ~= "" then
									szInfo = szInfo.."<text>text=\"\\\n\"font=113</text>"
								end 
								szAttr = szAttr..szInfo
							end
							local msg = 
							{
								szMessage = "<text>text="..EncodeComponentsString(g_tStrings.MSG_ON_USE_ITEM1).."</text>"
									..szAttr.."<text>text="..EncodeComponentsString(g_tStrings.MSG_SURE_QO_ON).."</text>",
								bRichText = true,
								szName = "ReplaceEnchantSure", 
								{szOption = g_tStrings.STR_HOTKEY_SURE, 
									fnAction = function() 
										UseItem(dwBox, dwX, nMode, dwTargetBox, dwTargetX)
									end
								},
								{szOption = g_tStrings.STR_HOTKEY_CANCEL},
							}
							MessageBox(msg)
							return
						end
	    			end
	    		end
	    		UseItem(dwBox, dwX, nMode, dwTargetBox, dwTargetX)
	    	end
	    	local fnCancel = function()
	  			return
	    	end
	    	local fnCondition = function(dwTargetBox, dwTargetX)
	    		if GetPlayerItem(GetClientPlayer(), dwTargetBox, dwTargetX) then
	    			return true
	    		else
	    			return false
	    		end
	    	end
	    	UserSelect.SelectItem(fnAction, fnCancel, fnCondition, box)		
		else
	    	UserSelect.CancelSelect()
			UseItem(dwBox, dwX, nMode)		
		end
	elseif item.nGenre == ITEM_GENRE.BOX_KEY then
		local dwTabType, dwIndex = item.dwTabType, item.dwIndex
		local rc = nil
		if box then
			rc = {}
			rc[1], rc[2] = box:GetAbsPos()
			rc[3], rc[4] = box:GetSize()
		end
    	local fnAction = function(dwTargetBox, dwTargetX)
    		local item = GetPlayerItem(GetClientPlayer(), dwTargetBox, dwTargetX)
    		if item and item.nGenre == ITEM_GENRE.BOX and item.nSub == BOX_SUB_TYPE.NEED_KEY then
    			local itemInfo = GetItemInfo(item.dwTabType, item.dwIndex)
    			local itemInfokey = GetItemAdvanceBoxKeyInfo(itemInfo.dwBoxTemplateID);
    			if itemInfokey.dwID == dwIndex then
    				OpenRandomRewardPanel(dwBox, dwX, dwTargetBox, dwTargetX, rc)
    			end
    		end
    	end
    	local fnCancel = function()
  			return
    	end
    	local fnCondition = function(dwTargetBox, dwTargetX)
    		local item = GetPlayerItem(GetClientPlayer(), dwTargetBox, dwTargetX)
    		if item and item.nGenre == ITEM_GENRE.BOX and item.nSub == BOX_SUB_TYPE.NEED_KEY then
    			local itemInfo = GetItemInfo(item.dwTabType, item.dwIndex)
    			local itemInfokey = GetItemAdvanceBoxKeyInfo(itemInfo.dwBoxTemplateID);
    			if itemInfokey.dwID == dwIndex then
    				return true
    			else
    				return false
    			end
    		else
    			return false
    		end
    	end
    	UserSelect.SelectItem(fnAction, fnCancel, fnCondition, box)		
	else
    	UserSelect.CancelSelect()
		UseItem(dwBox, dwX)
	end
end

function OnDestroyItem()
	if IsBagInSort() or IsBankInSort() then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_CANNOT_DESTROY_IN_SORT)
		return
	end
	
	local box = Hand_Get()
	if box and box:GetObjectType() == UI_OBJECT_ITEM then
		local _, dwBox, dwX = box:GetObjectData()
		if dwBox == INVENTORY_GUILD_BANK then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_CANNOT_DESTROY_GUILD_BANK_ITEM)
			return
		end
	else
		return
	end
	
	local _, dwBox, dwX = box:GetObjectData()
	
	local player = GetClientPlayer()			
	local item = GetPlayerItem(player, dwBox, dwX) 
	
	if not item then
		return
	end
	
	local dwTabType, dwIndex, nStackNum = item.dwTabType, item.dwIndex, item.nStackNum
	
	local msg = 
	{
		szMessage = FormatLinkString(g_tStrings.DESTROY_ITEM_SURE, "font=162", GetFormatText("["..GetItemNameByItem(item).."]", 
			"166"..GetItemFontColorByQuality(item.nQuality, true))), 
		szName = "DropItemSure", 
		bRichText = true,
		{szOption = g_tStrings.STR_HOTKEY_SURE, 
		fnAutoClose = function() 
			if IsBagInSort() or IsBankInSort() then
				return true
			end
			local item = GetPlayerItem(GetClientPlayer(), dwBox, dwX)
			if not item or item.dwTabType ~= dwTabType or item.dwIndex ~= dwIndex or nStackNum ~= item.nStackNum then
				return true
			end
			return false
		end,
		fnAction = function() 
			if IsBagInSort() or IsBankInSort() then
				OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_CANNOT_DESTROY_IN_SORT)
				return
			end
			local box = Hand_Get()
			if box and box:GetObjectType() == UI_OBJECT_ITEM then
				local _, dwBoxD, dwXD = box:GetObjectData()
				if dwBoxD == dwBox and dwXD == dwX then
					local player = GetClientPlayer()
					local item = GetPlayerItem(player, dwBox, dwX) 
					if item and item.bCanDestroy and item.dwTabType == dwTabType and item.dwIndex == dwIndex and nStackNum == item.nStackNum then
						local nRet = DestroyItem(dwBox, dwX)
						if nRet == ITEM_RESULT_CODE.BANK_PASSWORD_EXIST then
							OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tItem_Msg[nRet])	
						end
						PlaySound(SOUND.UI_SOUND,g_sound.Destroy)
					end
				end
			end
			Hand_Clear()
		end
		},
		{szOption = g_tStrings.STR_HOTKEY_CANCEL},
	}
	
	if item.nQuality > 2 and CheckHaveLocked(SAFE_LOCK_EFFECT_TYPE.EQUIP, "destroy") then
		return
	end
	
	MessageBox(msg)	
end

function GetItemFontColorByQuality(nQuality, bText)
	local r, g, b = 169, 169, 169
	if nQuality then	
		if nQuality == 1 then
			r, g, b = 255, 255, 255
		elseif nQuality == 2 then
			r, g, b = 0, 200, 72
		elseif nQuality == 3 then
			r, g, b = 0, 126, 255
		elseif nQuality == 4 then
			r, g, b = 255, 40, 255
		elseif nQuality == 5 then
			r, g, b = 255, 165, 0
		end
	end
	if bText then
		return " r="..r.." g="..g.." b="..b.." "
	end
	return r, g, b
end

function GetWeapenType(nType)
	return g_tStrings.WeapenDetail[nType] or g_tStrings.UNKNOWN_WEAPON
end

function GetWaistPendantItemInfo(dwID)
	if dwID and dwID ~= 0 then
		local t = g_tTable.WaistPendant:Search(dwID)
		if t then
			local itemInfo = GetItemInfo(t.dwType, t.dwIndex)
			return itemInfo, t.dwType, t.dwIndex
		end
	end
end

function GetBackPendantItemInfo(dwID)
	if dwID and dwID ~= 0 then
		local t = g_tTable.BackPendant:Search(dwID)
		if t then
			local itemInfo = GetItemInfo(t.dwType, t.dwIndex)
			return itemInfo, t.dwType, t.dwIndex
		end
	end
end

function GetEquipItemEquiped(nEqSubType, nDetailType)
	local nPos = 0
	if nEqSubType == EQUIPMENT_SUB.MELEE_WEAPON then
		nPos = EQUIPMENT_INVENTORY.MELEE_WEAPON
		if nDetailType == WEAPON_DETAIL.BIG_SWORD then
			nPos = EQUIPMENT_INVENTORY.BIG_SWORD
		end
	elseif nEqSubType == EQUIPMENT_SUB.RANGE_WEAPON then
		nPos = EQUIPMENT_INVENTORY.RANGE_WEAPON
	elseif nEqSubType == EQUIPMENT_SUB.ARROW then
		nPos = EQUIPMENT_INVENTORY.ARROW
	elseif nEqSubType == EQUIPMENT_SUB.CHEST then
		nPos = EQUIPMENT_INVENTORY.CHEST
	elseif nEqSubType == EQUIPMENT_SUB.HELM then
		nPos = EQUIPMENT_INVENTORY.HELM
	elseif nEqSubType == EQUIPMENT_SUB.AMULET then
		nPos = EQUIPMENT_INVENTORY.AMULET
	elseif nEqSubType == EQUIPMENT_SUB.RING then
		nPos = EQUIPMENT_INVENTORY.RIGHT_RING
	elseif nEqSubType == EQUIPMENT_SUB.WAIST then
		nPos = EQUIPMENT_INVENTORY.WAIST	
	elseif nEqSubType == EQUIPMENT_SUB.PENDANT then
		nPos = EQUIPMENT_INVENTORY.PENDANT
	elseif nEqSubType == EQUIPMENT_SUB.PANTS then
		nPos = EQUIPMENT_INVENTORY.PANTS
	elseif nEqSubType == EQUIPMENT_SUB.BOOTS then
		nPos = EQUIPMENT_INVENTORY.BOOTS	
	elseif nEqSubType == EQUIPMENT_SUB.BANGLE then
		nPos = EQUIPMENT_INVENTORY.BANGLE
	elseif nEqSubType == EQUIPMENT_SUB.WAIST_EXTEND then
		nPos = EQUIPMENT_INVENTORY.WAIST_EXTEND
	elseif nEqSubType == EQUIPMENT_SUB.BACK_EXTEND then
		nPos = EQUIPMENT_INVENTORY.BACK_EXTEND
	elseif nEqSubType == EQUIPMENT_SUB.HORSE then
		nPos = EQUIPMENT_INVENTORY.HORSE
	end
	
	return INVENTORY_INDEX.EQUIP, nPos
end

function GetEquipItemCompaireItem(nEqSubType, nDetailType)
	local nPos = nil
	if nEqSubType == EQUIPMENT_SUB.MELEE_WEAPON then
		nPos = EQUIPMENT_INVENTORY.MELEE_WEAPON
		if nDetailType == WEAPON_DETAIL.BIG_SWORD then
			nPos = EQUIPMENT_INVENTORY.BIG_SWORD
		end
	elseif nEqSubType == EQUIPMENT_SUB.RANGE_WEAPON then
		nPos = EQUIPMENT_INVENTORY.RANGE_WEAPON
	elseif nEqSubType == EQUIPMENT_SUB.ARROW then
		nPos = EQUIPMENT_INVENTORY.ARROW
	elseif nEqSubType == EQUIPMENT_SUB.CHEST then
		nPos = EQUIPMENT_INVENTORY.CHEST
	elseif nEqSubType == EQUIPMENT_SUB.HELM then
		nPos = EQUIPMENT_INVENTORY.HELM
	elseif nEqSubType == EQUIPMENT_SUB.AMULET then
		nPos = EQUIPMENT_INVENTORY.AMULET	
	elseif nEqSubType == EQUIPMENT_SUB.RING then
		local item = GetPlayerItem(GetClientPlayer(), INVENTORY_INDEX.EQUIP, EQUIPMENT_INVENTORY.LEFT_RING)
		if item then
			return item, GetPlayerItem(GetClientPlayer(), INVENTORY_INDEX.EQUIP, EQUIPMENT_INVENTORY.RIGHT_RING)
		end
		nPos = EQUIPMENT_INVENTORY.RIGHT_RING
	elseif nEqSubType == EQUIPMENT_SUB.WAIST then
		nPos = EQUIPMENT_INVENTORY.WAIST		
	elseif nEqSubType == EQUIPMENT_SUB.PENDANT then
		nPos = EQUIPMENT_INVENTORY.PENDANT
	elseif nEqSubType == EQUIPMENT_SUB.PANTS then
		nPos = EQUIPMENT_INVENTORY.PANTS
	elseif nEqSubType == EQUIPMENT_SUB.BOOTS then
		nPos = EQUIPMENT_INVENTORY.BOOTS		
	elseif nEqSubType == EQUIPMENT_SUB.BANGLE then
		nPos = EQUIPMENT_INVENTORY.BANGLE
	elseif nEqSubType == EQUIPMENT_SUB.WAIST_EXTEND then
		--nPos = EQUIPMENT_INVENTORY.WAIST_EXTEND
	elseif nEqSubType == EQUIPMENT_SUB.BACK_EXTEND then
		--nPos = EQUIPMENT_INVENTORY.BACK_EXTEND
	elseif nEqSubType == EQUIPMENT_SUB.HORSE then
		nPos = EQUIPMENT_INVENTORY.HORSE
	end
	if not nPos then
		return nil
	end
	return GetPlayerItem(GetClientPlayer(), INVENTORY_INDEX.EQUIP, nPos)	
end

function GetItemNameByItem(item)
	if item.nGenre == ITEM_GENRE.BOOK then
		local nBookID, nSegID = GlobelRecipeID2BookID(item.nBookID)
		return Table_GetSegmentName(nBookID, nSegID) or g_tStrings.BOOK
	else
		return Table_GetItemName(item.nUiId)
	end
end

function GetItemNameByItemInfo(itemInfo, nBookInfo)
	if itemInfo.nGenre == ITEM_GENRE.BOOK then
		if nBookInfo then
			local nBookID, nSegID = GlobelRecipeID2BookID(nBookInfo)
			return Table_GetSegmentName(nBookID, nSegID) or g_tStrings.BOOK
		else
			return Table_GetItemName(itemInfo.nUiId)
		end
	else
		return Table_GetItemName(itemInfo.nUiId)
	end
end

function GetItemNameByUIID(nUiId)
	return Table_GetItemName(nUiId)
end

function GetItemPosByItemTypeIndex(dwTabType, dwIndex)
	local tBag = {INVENTORY_INDEX.PACKAGE, INVENTORY_INDEX.PACKAGE1, INVENTORY_INDEX.PACKAGE2, INVENTORY_INDEX.PACKAGE3, INVENTORY_INDEX.PACKAGE4}
	
	local dwX
	for _, dwBox in ipairs(tBag) do
		dwX = GetItemPosInPackage(dwTabType, dwIndex, dwBox)
		if dwX then
			return dwBox, dwX
		end
	end
end

function GetItemPosInPackage(dwTabType, dwIndex, dwBox)
	local hPlayer = GetClientPlayer()
	if not hPlayer then
		return
	end
	local dwSize = hPlayer.GetBoxSize(dwBox)
	if not dwSize or dwSize == 0 then
		return
	end
	
	for dwX = 0, dwSize - 1 do
		hItem = hPlayer.GetItem(dwBox, dwX)
		if hItem and hItem.dwTabType == dwTabType and hItem.dwIndex == dwIndex then
			return dwX
		end
	end
end

function PlayItemSound(nUiId, bPickUp)
	local nSound = Table_GetItemSoundID(nUiId)
	if nSound == 0 then
		PlaySound(SOUND.UI_SOUND, g_sound.Ornamental)
	elseif nSound == 1 then
		PlaySound(SOUND.UI_SOUND, g_sound.PickupArmer)
	elseif nSound == 2 then
		PlaySound(SOUND.UI_SOUND, g_sound.PickupChina)
	elseif nSound == 3 then
		PlaySound(SOUND.UI_SOUND, g_sound.PickupCloth)
	elseif nSound == 4 then
		PlaySound(SOUND.UI_SOUND, g_sound.PickupHerb)
	elseif nSound == 5 then
		PlaySound(SOUND.UI_SOUND, g_sound.PickupIron)
	elseif nSound == 6 then
		PlaySound(SOUND.UI_SOUND, g_sound.PickupMoney)
	elseif nSound == 7 then
		PlaySound(SOUND.UI_SOUND, g_sound.PickupPaper)
	elseif nSound == 8 then
		PlaySound(SOUND.UI_SOUND, g_sound.PickupRing)
	elseif nSound == 9 then
		PlaySound(SOUND.UI_SOUND, g_sound.PickupRock)
	elseif nSound == 10 then
		PlaySound(SOUND.UI_SOUND, g_sound.PickupWeapon01)
	elseif nSound == 11 then
		PlaySound(SOUND.UI_SOUND, g_sound.PickupWeapon02)
	elseif nSound == 12 then
		PlaySound(SOUND.UI_SOUND, g_sound.PickupWeapon03)
	elseif nSound == 13 then
		PlaySound(SOUND.UI_SOUND, g_sound.PickupWeapon04)
	elseif nSound == 14 then
		PlaySound(SOUND.UI_SOUND, g_sound.PickupWater)
	elseif nSound == 15 then
		PlaySound(SOUND.UI_SOUND, g_sound.PickupMeat)
	elseif nSound == 16 then
		PlaySound(SOUND.UI_SOUND, g_sound.PickupFood)
	elseif nSound == 17 then
		PlaySound(SOUND.UI_SOUND, g_sound.PickupPill)
	else
		PlaySound(SOUND.UI_SOUND, g_sound.Ornamental)
	end
end

function GetBagContainType(dwBox)
	local player = GetClientPlayer()
	local dwGener, dwSub = player.GetContainType(dwBox)
	if dwGener == ITEM_GENRE.BOOK then
		return 4
	end
	if dwGener == ITEM_GENRE.MATERIAL then
		return dwSub
	end 
	return 0
end

function FormatAttributeValue(v)
	if v.nID == ATTRIBUTE_TYPE.DAMAGE_TO_LIFE_FOR_SELF or v.nID == ATTRIBUTE_TYPE.DAMAGE_TO_MANA_FOR_SELF then
		if v.nValue1 then
			v.nValue1 = KeepTwoByteFloat(v.nValue1 * 100 / 1024)
			v.nValue2 = KeepTwoByteFloat(v.nValue2 * 100 / 1024)
		end
		if v.Param0 then
			v.Param0 = KeepTwoByteFloat(v.Param0 * 100 / 1024)
			v.Param1 = KeepTwoByteFloat(v.Param1 * 100 / 1024)
			v.Param2 = KeepTwoByteFloat(v.Param2 * 100 / 1024)
			v.Param3 = KeepTwoByteFloat(v.Param3 * 100 / 1024)
		end
	
	end
end

function GetPlayerItem(player, dwBox, dwX)
	if dwBox == INVENTORY_GUILD_BANK then
		return GetTongClient().GetRepertoryItem(GetGuildBankPagePos(dwBox, dwX))
	else
		return player.GetItem(dwBox, dwX)
	end
end

function OnUsePendentItem(dwBox, dwX)
	local player = GetClientPlayer()
	if not player then
		return
	end
	
	if player.bFightState then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.CANNOT_CHANGE_PENDENT_IN_FIGHT)
		return
	end
	
	if player.nMoveState == MOVE_STATE.ON_DEATH then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_ERROR_CANNOT_EQUIP_PENDANT_WHEN_DIE)
		return
	end
	
	local item = player.GetItem(dwBox, dwX)
	if not item or item.nGenre ~= ITEM_GENRE.EQUIPMENT then
		return
	end
	
	if item.nSub ~= EQUIPMENT_SUB.BACK_EXTEND and item.nSub ~= EQUIPMENT_SUB.WAIST_EXTEND then
		return
	end
	
	local nRetCode = player.CheckEquipRequire(dwBox, dwX)
	if nRetCode ~= ITEM_RESULT_CODE.SUCCESS then
		GlobalEventHandler.OnItemRespond(nRetCode)
		return
	end
	
	if item.nSub == EQUIPMENT_SUB.BACK_EXTEND then
		if player.IsBackPendentExist(item.nRepresentID) then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_ERROR_ALEADY_GOT_PENDANT)
			return
		end
		
		local aBack = player.GetAllBackPendent() or {}
		if #aBack >= player.nBackPendentBoxSize then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_ERROR_NOT_ENOUGH_PENDANT_SIZE)
			return
		end
	end

	if item.nSub == EQUIPMENT_SUB.WAIST_EXTEND then
		if player.IsWaistPendentExist(item.nRepresentID) then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_ERROR_ALEADY_GOT_PENDANT)
			return
		end
		
		local aWaist = player.GetAllWaistPendent() or {}
		if #aWaist >= player.nWaistPendentBoxSize then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_ERROR_NOT_ENOUGH_PENDANT_SIZE)
			return
		end
	end
	
	local nUiId = item.nUiId
	local msg = 
	{
		szMessage = FormatLinkString(g_tStrings.EQUIP_BIND_PENDANT_SURE, "font=162", GetFormatText("["..GetItemNameByItem(item).."]", 
			"166"..GetItemFontColorByQuality(item.nQuality, true))), 
		bRichText = true,
		szName = "BindPendantSure", 
		{szOption = g_tStrings.STR_HOTKEY_SURE, 
		fnAction = function() 
			RemoteCallToServer("OnUsePendentItem", dwBox, dwX)
			PlayItemSound(nUiId)
		end
		},
		{szOption = g_tStrings.STR_HOTKEY_CANCEL},
	}
	MessageBox(msg)
end


function IsMystiqueRecipeRead(item) --提升技能属性的秘籍
    local player = GetClientPlayer()
    local bRead = false;
    local tInfo = SkillRecipeTable[item.dwIndex]
    local dwSkillID = tInfo.SkillID
    local dwSkillLevel = player.GetSkillLevel(dwSkillID);
    
    if dwSkillLevel == 0 then
        return false;
    end
    
    local dwRecipeID, dwRecipeLevel = tInfo.RecipeID, tInfo.RecipeLevel
    local tRecipeList = player.GetSkillRecipeList(dwSkillID, dwSkillLevel)
    if tRecipeList then
        for _, tRecipe in ipairs(tRecipeList) do
            if tRecipe and tRecipe.recipe_id and tRecipe.recipe_level
            and tRecipe.recipe_id == dwRecipeID and tRecipe.recipe_level == dwRecipeLevel then
                bRead = true
                break
            end
        end
    end
    return bRead;             
end

function IsMystiqueSkillRead(item)--用学习内功, 招式的秘籍
    local player = GetClientPlayer()
    local bRead = false;
    
    local tInfo = SkillLearnTable[item.dwIndex]
    local nKungfuID = tInfo.NeedFormID
    local nKungfuLevel = player.GetSkillLevel(nKungfuID)
    local dwSkillID = tInfo.SkillID
    local dwLearnLevel = tInfo.SkillLevel
    local dwSkillLevel = player.GetSkillLevel(dwSkillID)
    
    if dwLearnLevel == 0 then
        return bRead, true -- bExpMystique = true
    end
    
    if nKungfuLevel ~= 0 and dwSkillLevel >= dwLearnLevel then
        bRead = true
    end
        
    return bRead;             
end

function GetStrengthQualityLevel(nStrengthLevel)
	return math.floor(nStrengthLevel * (nStrengthLevel + 3) / 2  + 0.5)
end
function GetEquipScoresLevel(nScores)
	local tLevel = 
	{
		[0] = {nLow=0, nHigh=1000},
		[1] = {nLow=1000, nHigh=2000},
		[2] = {nLow=2000, nHigh=3000},
		[3] = {nLow=3000, nHigh=3500},
		[4] = {nLow=3500, nHigh=4000},
		[5] = {nLow=4000, nHigh=5000},
		[6] = {nLow=5000, nHigh=100000000},
	}
	local nMax = 6
	for i = 0, nMax,1 do
		if nScores >= tLevel[i].nLow and  nScores < tLevel[i].nHigh then
			return i
		end
	end
	return nMax
end

local function OnBagItemUpdate()
	local player = GetClientPlayer()
	local item = player.GetItem(arg0, arg1)
	if item then
		local szName = GetItemNameByItem(item)
		g_ItemNameToID[szName] = {item.dwTabType, item.dwIndex}
	end
end

local function OnUpdateAllItem()
	local player = GetClientPlayer()
	for dwBox = INVENTORY_INDEX.TOTAL - 1, INVENTORY_INDEX.EQUIP, -1 do
		local nCount = player.GetBoxSize(dwBox) or 0
		nCount = nCount - 1
		for dwX = 0, nCount, 1 do
			local item = player.GetItem(dwBox, dwX)
			if item then
				local szName = GetItemNameByItem(item)
				g_ItemNameToID[szName] = {item.dwTabType, item.dwIndex}
			end
		end
	end
end

RegisterEvent("BAG_ITEM_UPDATE", OnBagItemUpdate)
RegisterEvent("EQUIP_ITEM_UPDATE", OnBagItemUpdate)
RegisterEvent("BANK_ITEM_UPDATE", OnBagItemUpdate)
RegisterEvent("SOLD_ITEM_UPDATE", OnBagItemUpdate)
RegisterEvent("SYNC_ROLE_DATA_END", OnUpdateAllItem)
