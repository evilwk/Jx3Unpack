BankPanel = {}

function BankPanel.OnFrameCreate()

	this:RegisterEvent("BANK_ITEM_UPDATE")
	this:RegisterEvent("EQUIP_ITEM_UPDATE")
	this:RegisterEvent("MONEY_UPDATE")
	this:RegisterEvent("UPDATE_BANK_SLOT")
	this:RegisterEvent("BAG_ITEM_UPDATE")
	this:RegisterEvent("ON_OPEN_BAG_PANEL")
	this:RegisterEvent("ON_CLOSE_BAG_PANEL")

	local szIniFile = "UI/Config/Default/BankPanel.ini"
	
	local handle = this:Lookup("", "")
	local hBank = handle:Lookup("Handle_Item")
	hBank:Clear()
	
	local player = GetClientPlayer()
	local dwSize = player.GetBoxSize(INVENTORY_INDEX.BANK)
	local w = 7
    local h = math.ceil(dwSize / w)
	
	hBank.dwSize = dwSize
	
    local nIndex = 0
    for i = 1, h, 1 do
        for j = 1, w, 1 do
			if nIndex >= dwSize then
                break
			end
			hBank:AppendItemFromIni(szIniFile, "Image_Box")
            local image = hBank:Lookup(nIndex)
            image:SetRelPos(336 - j * (44 + 4), 0 + h * (44 + 4) - i * (44 + 4))
			nIndex = nIndex + 1
        end
    end	
	
	hBank.nStart = hBank:GetItemCount()
    local nIndex = 0
    for i = 1, h, 1 do
        for j = 1, w, 1 do
			if nIndex >= dwSize then
                break
			end
			local dwX = dwSize - 1 - nIndex
			hBank:AppendItemFromIni(szIniFile, "Box_Item", "Box"..dwX)
			local box = hBank:Lookup(hBank.nStart + nIndex)
			box:SetRelPos(336 - j * (44 + 4) + 2, 0 + h * (44 + 4) - i * (44 + 4) + 2)
			box:SetBoxIndex(dwX)
			box:SetOverTextPosition(0, ITEM_POSITION.RIGHT_BOTTOM)
			box:SetOverTextFontScheme(0, 15)
			
			local item = GetPlayerItem(player, INVENTORY_INDEX.BANK, dwX)
			UpdataItemBoxObject(box, INVENTORY_INDEX.BANK, dwX, item)
			
			nIndex = nIndex + 1
        end
    end
    hBank.nEnd = hBank:GetItemCount() - 1
    
    hBank.nInvertoryIndex = INVENTORY_INDEX.BANK
    hBank:FormatAllItemPos()
    
    BankPanel.UpdateBagSlot(handle)
    BankPanel.UpdataBuyMoneyShow(handle)
    BankPanel.UpdateMoneyShow(handle)
    
    RefreshUILockItem()
    
    InitFrameAutoPosInfo(this, 1, "Dialog", nil, function() CloseNormalBankPanel(true) end)
end

function BankPanel.UpdateBagSlot(handle)
	local player = GetClientPlayer()
    local nBagCount = player.GetBankPackageCount()
    local handleBag = handle:Lookup("Handle_Bag")
    handleBag:Clear()
    local szIniFile = "UI/Config/Default/BankPanel.ini"
    for i = EQUIPMENT_INVENTORY.BANK_PACKAGE1, EQUIPMENT_INVENTORY.BANK_PACKAGE5, 1 do
    	local nIndex = i - EQUIPMENT_INVENTORY.BANK_PACKAGE1
    	if nIndex < nBagCount then
    	    handleBag:AppendItemFromIni(szIniFile, "Image_Able", "Image"..i)
	    	local img = handleBag:Lookup(handleBag:GetItemCount() - 1)
	        local x = nIndex * (52 + 4)
	        img:SetRelPos(x, 0)

			handleBag:AppendItemFromIni(szIniFile, "Box_Item", "Box"..i)
			local box = handleBag:Lookup(handleBag:GetItemCount() - 1)
			box:SetRelPos(x + 4, 4)
			box:SetBoxIndex(i)
			box:SetOverTextPosition(0, ITEM_POSITION.RIGHT_BOTTOM)
			box:SetOverTextFontScheme(0, 15)
			
			local item = GetPlayerItem(player, INVENTORY_INDEX.EQUIP, i)
			UpdataItemBoxObject(box, INVENTORY_INDEX.EQUIP, i, item)
		else
			handleBag:AppendItemFromIni(szIniFile, "Image_Disable", "Image"..i)        
			local img = handleBag:Lookup(handleBag:GetItemCount() - 1)
			img:SetRelPos(nIndex * (52 + 4), 0)
		end
    end
    handleBag.nInvertoryIndex = INVENTORY_INDEX.EQUIP
    handleBag.nBagCount = nBagCount
    handleBag:FormatAllItemPos()
end

function BankPanel.OnFrameBreathe()
	local player = GetClientPlayer()
	if not player or player.nMoveState == MOVE_STATE.ON_DEATH then
		CloseNormalBankPanel()
		return
	end
	
	local handle = this:Lookup("", "Handle_Item")
	local nEnd = handle.nEnd
	for i = handle.nStart, nEnd, 1 do
		local box = handle:Lookup(i)
		UpdataItemCDProgress(player, box, INVENTORY_INDEX.BANK, box:GetBoxIndex())
	end
	
	if BankPanel.dwTargetType then
	    if BankPanel.dwTargetType == TARGET.NPC then
			local npc = GetNpc(BankPanel.dwTargetID)
			if not npc or not npc.CanDialog(player) then
				CloseNormalBankPanel()
			end
	    elseif BankPanel.dwTargetType == TARGET.DOODAD then
			local doodad = GetDoodad(BankPanel.dwTargetID)
			if not doodad or not doodad.CanDialog(player) then
				CloseNormalBankPanel()
			end
	    end
	end
end

function BankPanel.OnItemLButtonDown()
	this.bIgnoreClick = nil
	if IsCtrlKeyDown() and not this:IsEmpty() then
		local _, dwBox, dwX = this:GetObjectData()
		if IsGMPanelReceiveItem() then
			GMPanel_LinkItem(dwBox, dwX)
		else		
			EditBox_AppendLinkItem(dwBox, dwX)
		end
		this.bIgnoreClick = true
	end

	this:SetObjectPressed(1)
end

function BankPanel.OnItemLButtonUp()
	this:SetObjectPressed(0)
end

function BankPanel.OnItemLButtonDrag()
	this:SetObjectPressed(0)
	
	if not this:IsObjectEnable() then
		return
	end
	
	if UserSelect.DoSelectItem(this:GetParent().nInvertoryIndex, this:GetBoxIndex()) then
		return
	end	
	
	if (IsShiftKeyDown() and not IsCursorInExclusiveMode()) or Cursor.GetCurrentIndex() == CURSOR.SPLIT then
		OnSplitBoxItem(this)
		return
	end
	
	if Hand_IsEmpty() then
		if not this:IsEmpty() then
			if IsCursorInExclusiveMode() then
				OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.SRT_ERROR_CANCEL_CURSOR_STATE)
				PlayTipSound("010")
			else
				Hand_Pick(this)
			end
		end
	end
end

function BankPanel.OnItemLButtonDragEnd()
	this.bIgnoreClick = true
	
	if not this:IsObjectEnable() then
		if not Hand_IsEmpty() and not this:IsEmpty() then
			local box = Hand_Get()
			local dwType, _, dwBox, dwX = box:GetObjectData()
			local dwTType, _, dwTBox, dwTX = this:GetObjectData()
			if dwType == dwTType and dwBox == dwTBox and dwX == dwTX then
				Hand_Clear()
			end
		end
		return
	end
	
	if not Hand_IsEmpty() then
		BankPanel.OnExchangeBoxAndHandBoxItem(this)
	end	
end

function BankPanel.OnItemLButtonClick()
	if this.bIgnoreClick then
		this.bIgnoreClick = nil
		return
	end
	
	if not this:IsObjectEnable() then
		if not Hand_IsEmpty() and not this:IsEmpty() then
			local box = Hand_Get()
			local dwType, _, dwBox, dwX = box:GetObjectData()
			local dwTType, _, dwTBox, dwTX = this:GetObjectData()
			if dwType == dwTType and dwBox == dwTBox and dwX == dwTX then
				Hand_Clear()
			end
		end
		return
	end
	
	if UserSelect.DoSelectItem(this:GetParent().nInvertoryIndex, this:GetBoxIndex()) then
		return
	end	
	
	if (IsShiftKeyDown() and not IsCursorInExclusiveMode()) or Cursor.GetCurrentIndex() == CURSOR.SPLIT then
		OnSplitBoxItem(this)
		return
	end
	
	if Cursor.GetCurrentIndex() == CURSOR.REPAIRE or Cursor.GetCurrentIndex() == CURSOR.UNABLEREPAIRE then	--修理物品
		if not this:IsEmpty() then
			ShopRepairItem(this:GetParent().nInvertoryIndex, this:GetBoxIndex())
		end
		return
	end
		
	if Hand_IsEmpty() then
		if not this:IsEmpty() then
			if this:GetParent().nInvertoryIndex == INVENTORY_INDEX.EQUIP then
				if IsBagPanelOpened(EquipIndexToBagPanelIndex(this:GetBoxIndex())) then
					CloseBagPanel(EquipIndexToBagPanelIndex(this:GetBoxIndex()))
				else
					OpenBagPanel(EquipIndexToBagPanelIndex(this:GetBoxIndex()))
				end
			else
				if IsCursorInExclusiveMode() then
					OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.SRT_ERROR_CANCEL_CURSOR_STATE)
					PlayTipSound("010")
				else
					Hand_Pick(this)
				end
			end
		end
	else
		BankPanel.OnExchangeBoxAndHandBoxItem(this)
	end	
end

-------右键操作-------
function BankPanel.OnItemRButtonDown()
	this:SetObjectPressed(1)
end

function BankPanel.OnItemRButtonUp()
	this:SetObjectPressed(0)
end

function BankPanel.OnItemRButtonClick()
	if this:IsEmpty() then
		return
	end	
	
	if not this:IsObjectEnable() then
		return
	end
	
	local nInvertoryIndex = this:GetParent().nInvertoryIndex
	if nInvertoryIndex == INVENTORY_INDEX.EQUIP then
		return
	end

	local player = GetClientPlayer()
	local dwBox, dwX = player.GetStackRoomInPackage(nInvertoryIndex, this:GetBoxIndex())
	if dwBox and dwX then
		OnExchangeItem(nInvertoryIndex, this:GetBoxIndex(), dwBox, dwX)
		PlayItemSound(this:GetObjectData(), false)
	else
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_ERROR_BAG_IS_FULL);
		PlayTipSound("006")
	end
end

function BankPanel.OnExchangeBoxAndHandBoxItem(box)
	local boxHand, nHandCount = Hand_Get()
	local nSourceType = boxHand:GetObjectType()
	if nSourceType == UI_OBJECT_SKILL then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_ERROR_CANNOT_DRAG_SKILL_IN_BANKPANEL)
		PlayTipSound("001")
		return
	elseif nSourceType == UI_OBJECT_CRAFT then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_ERROR_CANNOT_DRAG_CRAFT_IN_BANKPANEL)
		PlayTipSound("001")
		return
	elseif nSourceType == UI_OBJECT_OTER_PLAYER_ITEM then
		local _, dwBox, dwX, dwSaleID = boxHand:GetObjectData()
		local dwBox2 = box:GetParent().nInvertoryIndex
		local dwX2 = box:GetBoxIndex()
		MarketTradePanel_BuyItem(dwBox, dwX, dwSaleID, dwBox2, dwX2)	
		Hand_Clear()	
		return
	elseif nSourceType ~= UI_OBJECT_ITEM then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_ERROR_CANNOT_DRAG_ITEM_IN_BANKPANEL)
		PlayTipSound("001")
		return
	end
	
	local _, dwBox1, dwX1 = boxHand:GetObjectData()
	local dwBox2 = box:GetParent().nInvertoryIndex
	local dwX2 = box:GetBoxIndex()
		
	if OnExchangeItem(dwBox1, dwX1, dwBox2, dwX2, nHandCount) then
		Hand_Clear()
	end
end

function BankPanel.OnItemMouseEnter()
	this:SetObjectMouseOver(1)
	
	if not this:IsEmpty() then
		local _, dwBox, dwX = this:GetObjectData()
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
		OutputItemTip(UI_OBJECT_ITEM, dwBox, dwX, nil, {x, y, w, h})	
	end
	
	if UserSelect.IsSelectItem() then
		UserSelect.SatisfySelectItem(box:GetParent().nInvertoryIndex, this:GetBoxIndex())
		return
	end
	
	if this:IsEmpty() then
		if Cursor.GetCurrentIndex() == CURSOR.SPLIT then
			Cursor.Switch(CURSOR.UNABLESPLIT)
		elseif Cursor.GetCurrentIndex() == CURSOR.REPAIRE then
			Cursor.Switch(CURSOR.UNABLEREPAIRE)			
		elseif not IsCursorInExclusiveMode() then
			Cursor.Switch(CURSOR.NORMAL)
		end
	else
		local _, dwBox, dwX = this:GetObjectData()
		if Cursor.GetCurrentIndex() == CURSOR.SPLIT then
			local item = GetPlayerItem(GetClientPlayer(), dwBox, dwX)
			if not item or not item.bCanStack or item.nStackNum < 2 then
				Cursor.Switch(CURSOR.UNABLESPLIT)
			end
		elseif Cursor.GetCurrentIndex() == CURSOR.REPAIRE then
			local item = GetPlayerItem(GetClientPlayer(), dwBox, dwX)
			if not item or not item.IsRepairable() then
				Cursor.Switch(CURSOR.UNABLEREPAIRE)
			end			
		elseif not IsCursorInExclusiveMode() and IsShopOpened() then
			local item = GetPlayerItem(GetClientPlayer(), dwBox, dwX)
			if item and item.bCanTrade then
				Cursor.Switch(CURSOR.SELL)
			else
				Cursor.Switch(CURSOR.UNABLESELL)
			end
		end
	end
end

function BankPanel.OnItemRefreshTip()
	BankPanel.OnItemMouseEnter()
end

function BankPanel.OnItemMouseLeave()
	this:SetObjectMouseOver(0)
	HideTip()
	
	if UserSelect.IsSelectItem() then
		UserSelect.SatisfySelectItem(-1, -1, true)
		return
	end
	
	if Cursor.GetCurrentIndex() == CURSOR.UNABLESPLIT then
		Cursor.Switch(CURSOR.SPLIT)
	elseif Cursor.GetCurrentIndex() == CURSOR.UNABLEREPAIRE then
		Cursor.Switch(CURSOR.REPAIRE)
	elseif not IsCursorInExclusiveMode() then
		Cursor.Switch(CURSOR.NORMAL)
	end
end

function BankPanel.OnEvent(event)
	if event == "BANK_ITEM_UPDATE" then
		local nBoxIndex = arg0
		local nItemIndex = arg1
		if nBoxIndex == INVENTORY_INDEX.BANK then
			local box = this:Lookup("", "Handle_Item/Box"..nItemIndex)
			local player = GetClientPlayer()
			local item = GetPlayerItem(player, nBoxIndex, nItemIndex)
			UpdataItemBoxObject(box, nBoxIndex, nItemIndex, item)
			if box:IsObjectMouseOver() then
				local thisSave = this
				this = box
				BankPanel.OnItemMouseEnter()
				this = thisSave
			end
		end
	elseif event == "EQUIP_ITEM_UPDATE" then
		local nBoxIndex = arg0
		local nItemIndex = arg1
		if nBoxIndex == INVENTORY_INDEX.EQUIP and
			nItemIndex >= EQUIPMENT_INVENTORY.BANK_PACKAGE1 and
			nItemIndex <= EQUIPMENT_INVENTORY.BANK_PACKAGE5 then
			if IsBagPanelOpened(EquipIndexToBagPanelIndex(nItemIndex)) then
				CloseBagPanel(EquipIndexToBagPanelIndex(nItemIndex))
			end

			local box = this:Lookup("", "Handle_Bag/Box"..nItemIndex)
			if box then
				box.nInventoryIndex = INVENTORY_INDEX.BANK_PACKAGE1 + nItemIndex - EQUIPMENT_INVENTORY.BANK_PACKAGE1
				box:SetOverTextPosition(0, ITEM_POSITION.RIGHT_BOTTOM)
				box:SetOverTextFontScheme(0, 15)			
				local player = GetClientPlayer()
				local item = GetPlayerItem(player, nBoxIndex, nItemIndex)
				UpdataItemBoxObject(box, nBoxIndex, nItemIndex, item)
				Bag.UpdateBagSize(box)
				if box:IsObjectMouseOver() then
					local thisSave = this
					this = box
					BankPanel.OnItemMouseEnter()
					this = thisSave
				end
			end
		end
	elseif event == "MONEY_UPDATE" then
		BankPanel.UpdateMoneyShow(this:Lookup("", ""))
		BankPanel.UpdataBuyMoneyShow(this:Lookup("", ""))
	elseif event == "UPDATE_BANK_SLOT" then
		local handle = this:Lookup("", "")
		BankPanel.UpdateBagSlot(handle)
		BankPanel.UpdataBuyMoneyShow(handle)
	elseif event == "BAG_ITEM_UPDATE" then
	   	if arg0 >= INVENTORY_INDEX.BANK_PACKAGE1 and arg0 <= INVENTORY_INDEX.BANK_PACKAGE5 then
	   		local nIndex = EQUIPMENT_INVENTORY.BANK_PACKAGE1 + arg0 - INVENTORY_INDEX.BANK_PACKAGE1
			local box = this:Lookup("", "Handle_Bag/Box"..nIndex)
			if box then
				Bag.UpdateBagSize(box)
			end
	    end
	elseif event == "ON_OPEN_BAG_PANEL" then
		local nPos = BagPanelIndexToEquipIndex(arg0)
		if nPos and nPos >= EQUIPMENT_INVENTORY.BANK_PACKAGE1 and nPos <= EQUIPMENT_INVENTORY.BANK_PACKAGE5 then
			local box = this:Lookup("", "Handle_Bag/Box"..nPos)
			if box and not box:IsEmpty() then
				box:SetObjectSelected(true)
			end
		end	
	elseif event == "ON_CLOSE_BAG_PANEL" then
		local nPos = BagPanelIndexToEquipIndex(arg0)
		if nPos and nPos >= EQUIPMENT_INVENTORY.BANK_PACKAGE1 and nPos <= EQUIPMENT_INVENTORY.BANK_PACKAGE5 then
			local box = this:Lookup("", "Handle_Bag/Box"..nPos)
			if box and not box:IsEmpty() then
				box:SetObjectSelected(false)
			end
		end
	end
end

function BankPanel.OnLButtonClick()
    if this:GetName() == "Btn_Close" then
    	CloseNormalBankPanel()
    elseif this:GetName() == "Btn_Buy" then
		local msg = 
		{
			szMessage = g_tStrings.MSG_SURE_BUY_BAG_PANEL1, 
			szName = "BuyBagSure", 
			fnAutoClose = function() if not IsNormalBankPanelOpened() then return true end end,
			{szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = function() GetClientPlayer().EnableBankPackage() end, szSound = g_sound.Trade},
			{szOption = g_tStrings.STR_HOTKEY_CANCEL}
		}
		MessageBox(msg)
    end
end

function BankPanel.UpdateMoneyShow(handle)
	local player = GetClientPlayer()
    local nMoney = player.GetMoney()
    local nGold, nSilver, nCopper = MoneyToGoldSilverAndCopper(nMoney)
    
    local textG = handle:Lookup("Text_Gold")
    local textS = handle:Lookup("Text_Silver")
    local textC = handle:Lookup("Text_Copper")
    local imageG = handle:Lookup("Image_Gold")
    local imageS = handle:Lookup("Image_Silver")
    local imageC = handle:Lookup("Image_Copper")
    textG:SetText(nGold)
    textS:SetText(nSilver)
    textC:SetText(nCopper)
    imageG:Show()
    imageS:Show()
    imageC:Show()
    if nGold == 0 then
    	textG:SetText("")
    	imageG:Hide()
    	if nSilver == 0 then
    		textS:SetText("")
    		imageS:Hide()
    	end
    end  
end

function BankPanel.UpdataBuyMoneyShow(handle)
	local player = GetClientPlayer()
	local nCount = player.GetBankPackageCount()
	
	if nCount >= GLOBAL.MAX_BANK_PACKAGE_COUNT then
		this:GetRoot():Lookup("Btn_Buy"):Enable(false)
	    handle:Lookup("Text_GoldBuy"):Hide()
	    handle:Lookup("Text_SilverBuy"):Hide()
	    handle:Lookup("Text_CopperBuy"):Hide()
	    handle:Lookup("Image_GoldBuy"):Hide()
	    handle:Lookup("Image_SilverBuy"):Hide()
	    handle:Lookup("Image_CopperBuy"):Hide()
	    return
	end
	
	local nMoney = GetBankPackagePrice(nCount + 1)
	if nMoney > player.GetMoney() then
		this:GetRoot():Lookup("Btn_Buy"):Enable(false)
	else
		this:GetRoot():Lookup("Btn_Buy"):Enable(true)
	end
	
    local nGold, nSilver, nCopper = MoneyToGoldSilverAndCopper(nMoney)
    
    local textG = handle:Lookup("Text_GoldBuy")
    local textS = handle:Lookup("Text_SilverBuy")
    local textC = handle:Lookup("Text_CopperBuy")
    local imageG = handle:Lookup("Image_GoldBuy")
    local imageS = handle:Lookup("Image_SilverBuy")
    local imageC = handle:Lookup("Image_CopperBuy")
    textG:SetText(nGold)
    textS:SetText(nSilver)
    textC:SetText(nCopper)
    imageG:Show()
    imageS:Show()
    imageC:Show()
    if nGold == 0 then
    	textG:SetText("")
    	imageG:Hide()
    	if nSilver == 0 then
    		textS:SetText("")
    		imageS:Hide()
    	end
    end
end

function OpenNormalBankPanel(dwTargetType, dwTargetID, bDisableSound)
	if IsOptionOrOptionChildPanelOpened() then
		return
	end

	local player = GetClientPlayer()
	if not player or player.nMoveState == MOVE_STATE.ON_DEATH then
		return
	end

	BankPanel.dwTargetType = dwTargetType
	BankPanel.dwTargetID = dwTargetID

	if not IsNormalBankPanelOpened() then
		Wnd.OpenWindow("BankPanel")
		OpenAllBagPanel(true)
	end
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
end

function IsNormalBankPanelOpened()
	local frame = Station.Lookup("Normal/BankPanel")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end

function CloseNormalBankPanel(bDisableSound)
	GetClientPlayer().CloseBank()
	if IsNormalBankPanelOpened() then
		CloseAllBagPanel(true)
	end
	Wnd.CloseWindow("BankPanel")
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end	
end

function NormalBankPanel_GetItemBox(dwBox, dwX, bEvenUnVisible)
	if dwBox == INVENTORY_INDEX.EQUIP and dwX >= EQUIPMENT_INVENTORY.BANK_PACKAGE1 and dwX <= EQUIPMENT_INVENTORY.BANK_PACKAGE5 then
		local frame = Station.Lookup("Normal/BankPanel")
		if frame and (frame:IsVisible() or bEvenUnVisible) then
			return frame:Lookup("", "Handle_Bag/Box"..dwX)
		end
	elseif dwBox == INVENTORY_INDEX.BANK then
		local frame = Station.Lookup("Normal/BankPanel")
		if frame and (frame:IsVisible() or bEvenUnVisible) then
			return frame:Lookup("", "Handle_Item/Box"..dwX)
		end
	else
		return BagPanel_GetItemBox(dwBox, dwX, bEvenUnVisible)
	end
	return nil
end
