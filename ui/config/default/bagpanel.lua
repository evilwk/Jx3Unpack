BagPanel_Base = class()
local szIniFile = "UI/Config/Default/BagPanel.ini"

function BagPanel_Base.GetIndexAndObjectType(frame)
	local szIndex = string.gsub(frame:GetName(), "(BagPanel)", "")
	frame.nIndex = tonumber(szIndex)
	local t = 
	{
		INVENTORY_INDEX.PACKAGE,
		INVENTORY_INDEX.PACKAGE1,
		INVENTORY_INDEX.PACKAGE2,
		INVENTORY_INDEX.PACKAGE3,
		INVENTORY_INDEX.PACKAGE4,
		INVENTORY_INDEX.BANK_PACKAGE1,
		INVENTORY_INDEX.BANK_PACKAGE2,
		INVENTORY_INDEX.BANK_PACKAGE3,
		INVENTORY_INDEX.BANK_PACKAGE4,
		INVENTORY_INDEX.BANK_PACKAGE5,
	}
	
	frame.nObjectType = t[frame.nIndex];
end

local function UpdatePlayerInfo(handle)
	local image = handle:Lookup("Image_BackBottom02")
    local hCurrency = handle:Lookup("Handle_Currency")

    
    hCurrency:Clear()
    if not image then
		return 0
	end

    local tCheckData = Currency_GetCheckedCurrency()
    local nSize = #tCheckData
    
    for i = 1, 3 - nSize, 1 do
        local hItem = hCurrency:AppendItemFromIni(szIniFile, "Handle_Option")
        hItem:Clear()
    end
    for k, v in ipairs(tCheckData) do
        local hItem = hCurrency:AppendItemFromIni(szIniFile, "Handle_Option")
        hItem:Lookup("Text_Count"):SetText(v.nCount)
        hItem:Lookup("Image_Logo"):SetFrame(v.nFrame)
        hItem.szName = v.szName
    end   
    hCurrency:FormatAllItemPos()
    
    if hCurrency.bShow then
        return
    end
    
    local nImgW = image:GetSize()
	local _, nImgY = image:GetAbsPos()
	local _, y1 = handle:GetAbsPos()
	local nY = nImgY - y1 + 40 + 20
    
    hCurrency:SetRelPos(-5, nY)
    local hImgMid = handle:Lookup("Image_BackMid")
	local nMidW, nMidH = hImgMid:GetSize()
	hImgMid:SetSize(nMidW, nMidH + 24)
    hCurrency.bShow = true;
end

function BagPanel_Base.OnFrameCreate()
	this:GetSelf().GetIndexAndObjectType(this)

	this:RegisterEvent("BAG_ITEM_UPDATE")
	this:RegisterEvent("ON_SET_USE_BIGBAGPANEL")
	if this.nIndex == 1 then --固定背包
		this:RegisterEvent("MONEY_UPDATE")
		this:RegisterEvent("SYNC_COIN")
		this:RegisterEvent("UI_SCALED")
        this:RegisterEvent("CURRENCY_CHECK_NOTIFY")
        this:RegisterEvent("CURRENCY_VALUE_UPDATE")
	end

	local player = GetClientPlayer()
	local btnSplit = this:Lookup("Btn_Split")
    local btnCurrency = this:Lookup("Btn_Currency")
--	local btnMarket = this:Lookup("Btn_Market")
	local handle = this:Lookup("", "")
    handle:Clear()
	
	local nGWBoxIndex = this.nObjectType
    local dwSize = player.GetBoxSize(nGWBoxIndex)
    local w = 4
    local h = math.ceil(dwSize / w)
    this.dwSize = dwSize
    this.nGWBoxIndex = nGWBoxIndex
    
    -------------------------拼背景--------------------------------------
    if nGWBoxIndex >= INVENTORY_INDEX.BANK_PACKAGE1 and nGWBoxIndex <= INVENTORY_INDEX.BANK_PACKAGE5 then
    	handle:AppendItemFromIni(szIniFile, "Image_BackTopB")
    else
    	handle:AppendItemFromIni(szIniFile, "Image_BackTop")
    end
    handle:AppendItemFromIni(szIniFile, "Image_BackMid")
    local img = handle:Lookup(handle:GetItemCount() - 1)
    
    if this.nIndex == 1 then
		--如果是固定背包，底部多一条money条
    	img:SetSize(230, h * 50 + 20)
        handle:AppendItemFromIni(szIniFile, "Image_BackBottom02")
    else
    	img:SetSize(230, h * 50)
    	handle:AppendItemFromIni(szIniFile, "Image_BackBottom")
    	btnSplit:Hide()
        btnCurrency:Hide()
--    	btnMarket:Hide()
    end
	
    -------------------------拼背景格子----------------------------------
    local nIndex = 0
    for i = 1, h, 1 do
        for j = 1, w, 1 do
			if nIndex >= dwSize then	
                break
			end
			handle:AppendItemFromIni(szIniFile, "Image_Box")
            local image = handle:Lookup(handle:GetItemCount() - 1)
            image:SetRelPos(215 - j * (48 + 2), 58 + h * (48 + 2) - i * (48 + 2))
            nIndex = nIndex + 1
        end
    end
    
    -------------------------拼格子---------------------------------------
    handle.nStart = handle:GetItemCount()
    nIndex = 0
    for i = 1, h, 1 do
        for j = 1, w, 1 do
			if nIndex >= dwSize then
                break
			end
			local dwX = dwSize - 1 - nIndex
			handle:AppendItemFromIni(szIniFile, "Box", "Box"..dwX)
			local box = handle:Lookup(handle.nStart + nIndex)
			            
			box:SetRelPos(213 - j * (48 + 2) + 2, 56 + h * (48 + 2) - i * (48 + 2) + 2)
			box:SetBoxIndex(dwX)
			
			local item = GetPlayerItem(player, nGWBoxIndex, dwX)
			UpdataItemBoxObject(box, nGWBoxIndex, dwX, item)
			
			box:SetOverTextPosition(0, ITEM_POSITION.RIGHT_BOTTOM)
			box:SetOverTextFontScheme(0, 15)
			
			if item and item.bCanStack and item.nStackNum > 1 then
				box:SetOverText(0, item.nStackNum)
			else
				box:SetOverText(0, "")
			end
			nIndex = nIndex + 1
        end
    end
    handle.nEnd = handle:GetItemCount() - 1

    -------------------------文字和其他----------------------------
    handle:AppendItemFromIni(szIniFile, "Text_BoxName")
    local nPos = BagPanelIndexToEquipIndex(this.nIndex)
    if nPos and nPos ~= -1 then
    	local item = GetPlayerItem(player, INVENTORY_INDEX.EQUIP, nPos)
    	if item then
    		handle:Lookup(handle:GetItemCount() - 1):SetText(GetItemNameByItem(item))
    	end
    end
    
	handle:FormatAllItemPos()
	
    --------------------------金钱---------------------------------
    if this.nIndex == 1 then
        handle:AppendItemFromIni(szIniFile, "Text_Gold")
        handle:AppendItemFromIni(szIniFile, "Image_Gold")
        handle:AppendItemFromIni(szIniFile, "Text_Silver")
        handle:AppendItemFromIni(szIniFile, "Image_Silver")
        handle:AppendItemFromIni(szIniFile, "Text_Copper")
        handle:AppendItemFromIni(szIniFile, "Image_Copper")
        handle:AppendItemFromIni(szIniFile, "Text_Coin")
        handle:AppendItemFromIni(szIniFile, "Image_Coin")
		
        handle:AppendItemFromIni(szIniFile, "Handle_Currency")
        
        UpdatePlayerInfo(handle);
		
        -----调整相对位置-----
        local textG = handle:Lookup("Text_Gold")
        local image = handle:Lookup("Image_BackBottom02")
                
        if image then
        	local x, y = image:GetAbsPos()
        	local x1, y1 = handle:GetAbsPos()
        	local xG, yG = textG:GetRelPos()
        	textG:SetRelPos(xG - 6, y - y1 + 20)
        	
        	local xF, yF = this:GetAbsPos()
        	local xS, yS = btnSplit:GetRelPos()
            local xC, yC = btnCurrency:GetRelPos()
        	btnSplit:SetRelPos(xS, y - yF - 6)
            btnCurrency:SetRelPos(xC, y - yF - 6)
        end
        
        local textC = handle:Lookup("Text_Coin")
        if image and textC then
        	local x, y = image:GetAbsPos()
        	local x1, y1 = handle:GetAbsPos()
        	local xC, yC = textC:GetRelPos()
        	textC:SetRelPos(xC - 6, y - y1 + 40)
        end

        this:GetSelf():UpdateMoneyShow(player, handle)
        
        handle:FormatAllItemPos()
    end
	
	-------重新计算窗口大小-----------
	local w, h = handle:GetAllItemSize()
	handle:SetSize(w, h)
	this:SetSize(w, h)
	
	if not _g_OpenBagIndex then
		_g_OpenBagIndex = 0
	else
		_g_OpenBagIndex = _g_OpenBagIndex + 1
	end
	this.nOpenIndex = _g_OpenBagIndex
	
	RefreshUILockItem()
	UserSelect.RefreshSelectedBox()
end

function BagPanel_Base.OnFrameBreathe()
	local player = GetClientPlayer()
	if not player then
		return
	end
	
	local handle = this:Lookup("", "")
	
	local nEnd = handle.nEnd
	local nBag = this.nGWBoxIndex
	for i = handle.nStart, nEnd, 1 do
		local box = handle:Lookup(i)
		UpdataItemCDProgress(player, box, nBag, box:GetBoxIndex())
	end
end

function BagPanel_Base:UpdateMoneyShow(player, handle)
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
    
    handle:Lookup("Text_Coin"):SetText(player.nCoin)
    handle:Lookup("Image_Coin"):Show()
end

-------左键操作-------
function BagPanel_Base.OnItemLButtonDown()
	local szName = this:GetName()
	if szName == "Text_Coin" or szName == "Image_Coin" then
		return
	end
	
	this.bIgnoreClick = nil
	if IsCtrlKeyDown() and not this:IsEmpty() then
		local _, dwBox, dwX = this:GetObjectData()
		if IsAuctionSearchOpened() then
			local item = GetPlayerItem(GetClientPlayer(), dwBox, dwX)
			Auction_SetItemName(item.szName)
		elseif IsGMPanelReceiveItem() then
			GMPanel_LinkItem(dwBox, dwX)
		else
			EditBox_AppendLinkItem(dwBox, dwX)
		end
		this.bIgnoreClick = true
	end
	this:SetObjectStaring(false)
	this:SetObjectPressed(1)
end

function BagPanel_Base.OnItemLButtonUp()
	local szName = this:GetName()
	if szName == "Text_Coin" or szName == "Image_Coin" then
		return
	end

	this:SetObjectPressed(0)
end

function BagPanel_Base.OnItemLButtonDrag()
	this:SetObjectPressed(0)
	
	if not this:IsObjectEnable() then
		return
	end
	
	if UserSelect.DoSelectItem(this:GetRoot().nObjectType, this:GetBoxIndex()) then
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

function BagPanel_Base.OnItemLButtonDragEnd()
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
		this:GetRoot():GetSelf():OnExchangeBoxAndHandBoxItem(this)
	end	
end

function BagPanel_Base.OnItemLButtonClick()
	local szName = this:GetName()
	if szName == "Text_Coin" or szName == "Image_Coin" then
		if IsTongBaoPanelPannelOpened() then
			CloseTongBaoPanelPannel()
		else
			OpenTongBaoPanelPannel()
		end
		return
	end

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
	
	if UserSelect.DoSelectItem(this:GetRoot().nObjectType, this:GetBoxIndex()) then
		return
	end
	
	if (IsShiftKeyDown() and not IsCursorInExclusiveMode())	or Cursor.GetCurrentIndex() == CURSOR.SPLIT then
		OnSplitBoxItem(this)
		return
	end
	
	if Cursor.GetCurrentIndex() == CURSOR.REPAIRE or Cursor.GetCurrentIndex() == CURSOR.UNABLEREPAIRE then	--修理物品
		if not this:IsEmpty() then
			local _, dwBox, dwX = this:GetObjectData()
			ShopRepairItem(dwBox, dwX)
		end
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
	else
		this:GetRoot():GetSelf():OnExchangeBoxAndHandBoxItem(this)
	end	
end

-------右键操作-------
function BagPanel_Base.OnItemRButtonDown()
	this:SetObjectPressed(1)
	this:SetObjectStaring(false)
end

function BagPanel_Base.OnItemRButtonUp()
	this:SetObjectPressed(0)
end

function BagPanel_Base.OnItemRButtonClick()
	if this:IsEmpty() then
		return
	end	
	
	if not this:IsObjectEnable() then
		return
	end

	local player = GetClientPlayer()
	local nUiId, dwBox, dwX = this:GetObjectData()

	if IsCtrlKeyDown() and IsAuctionSellOpened() and not this:IsEmpty() and dwBox and dwX then
		Auction_ExchangeBagAndAuctionItem(this)
		return
	end
	
	if IsShiftKeyDown() and not this:IsEmpty() and dwBox and dwX then
		OpenFEActivationPanel(this)
		return
	end
	
	if IsTradePanelOpened() then
		AppendTradingItem(dwBox, dwX)
		return
	end

	if IsBankPanelOpened() then
		local dwTargetBox, dwTargetX;
		local dwBoxType = player.GetBoxType(dwBox);

		if dwBoxType == INVENTORY_TYPE.BANK then
			dwTargetBox, dwTargetX = player.GetStackRoomInPackage(dwBox, dwX)
			if dwTargetBox and dwTargetX then
				OnExchangeItem(dwBox, dwX, dwTargetBox, dwTargetX)
				PlayItemSound(nUiId)
			else
				OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_ERROR_PACKAGE_IS_FULL);
			end
		end

		if dwBoxType == INVENTORY_TYPE.PACKAGE then
			dwTargetBox, dwTargetX = player.GetStackRoomInBank(dwBox, dwX)
			if dwTargetBox and dwTargetX then
				OnExchangeItem(dwBox, dwX, dwTargetBox, dwTargetX)
				PlayItemSound(nUiId)
			else
				OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_ERROR_BANK_IS_FULL);
				PlayTipSound("005")
			end
		end
		
		return
	end

	if IsFEProducePanelOpened() then
		local item = GetPlayerItem(player, dwBox, dwX)
		if not item then
			return
		end
		local nCount = 1
		if item.bCanStack then
			nCount = item.nStackNum
		end
		AddProduceItemOnBag(this, nCount)
		return
	end
	
	if IsFEActivationPanelOpened() then
		local item = GetPlayerItem(player, dwBox, dwX)
		if not item then
			return
		end
		local nCount = 1
		if item.bCanStack then
			nCount = item.nStackNum
		end
		AddFEActivationOnItemRButton(this, nCount)
		return
	end
	
	if IsFEEquipExtractPanelOpened() then
		local item = GetPlayerItem(player, dwBox, dwX)
		if not item then
			return
		end
		local nCount = 1
		if item.bCanStack then
			nCount = item.nStackNum
		end
		AddFEEquipExtractOnItemRButtonClick(this, nCount)
		return
	end
	
	if IsFEPeelPanelOpened() then
		local item = GetPlayerItem(player, dwBox, dwX)
		if not item then
			return
		end
		local nCount = 1
		if item.bCanStack then
			nCount = item.nStackNum
		end
		AddItemToFEPeelPanel(this, nCount)
		return
	end
	
	if IsShopOpened() then
		local item = GetPlayerItem(player, dwBox, dwX)
		if item then
			local nCount = 1	
			if item.bCanStack then		
				nCount = item.nStackNum
			end
			SellItemToShop(dwBox, dwX, nCount)
		end
		return
	end
	
	if IsMailPanelOpened() then
		AppendMailItem(dwBox, dwX)
		return
	end
	
	if IsMarketPanelOpened() then
		AppendItemToMarketPanel(dwBox, dwX)
		return
	end
	
	if IsGuildBankPanelOpened() then
		AddItemToGuildBank(dwBox, dwX)
		return
	end
	
	if IsTongFarmPanelOpened() then
		AppendTongFarmItem(dwBox, dwX)
		return
	end
    
    if IsExteriorBuyOpened() then
        AddItemToExteriorBuy(dwBox, dwX)
        return
    end
	
	local item = GetPlayerItem(player, dwBox, dwX)
	if item and item.nGenre == ITEM_GENRE.EQUIPMENT then
		if item.nSub == EQUIPMENT_SUB.BACK_EXTEND or item.nSub == EQUIPMENT_SUB.WAIST_EXTEND then
			OnUsePendentItem(dwBox, dwX)
		else	
		    local eRetCode, nEquipPos = player.GetEquipPos(dwBox, dwX)
		    if eRetCode == ITEM_RESULT_CODE.SUCCESS then
			    OnExchangeItem(dwBox, dwX, INVENTORY_INDEX.EQUIP, nEquipPos)
			    PlayItemSound(nUiId)
	        else
	            OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tItem_Msg[eRetCode])
	        end
	    end
        return;
    elseif item and item.nGenre == ITEM_GENRE.BOOK then
        player.OpenBook(dwBox, dwX)
        return;
    elseif item and item.nGenre == ITEM_GENRE.MOUNT_ITEM then
        if item.nSub == EQUIPMENT_SUB.HORSE then
            local horse = player.GetItem(INVENTORY_INDEX.EQUIP, EQUIPMENT_INVENTORY.HORSE)
            if horse then
                local nMountIndex = item.GetMountIndex()
                local page = CharacterPanel.GetPageRides()
                local box = nil
                for i = 1, 4 do
                    if page:Lookup("", "Box_RideEquipBox"..i).nMountIndex == nMountIndex then
                        box = page:Lookup("", "Box_RideEquipBox"..i)
                        break
                    end
                end
                if box and not box:IsEmpty() then
                    ExchangeRidesEquip(nMountIndex, dwBox, dwX)
                else
                    MountRidesEquip(dwBox, dwX)
                end
            else
                OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.DIS_NOT_EQUIP_HORSE)
            end
        end
        return
    end	

    OnUseItem(dwBox, dwX, this)
end

function BagPanel_Base:OnExchangeBoxAndHandBoxItem(box)
	local boxHand, nHandCount = Hand_Get()	
	local nSourceType = boxHand:GetObjectType()
	if nSourceType == UI_OBJECT_SKILL then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_ERROR_CANNOT_DRAG_SKILL_IN_BAGPANEL)
		PlayTipSound("001")
		return
	elseif nSourceType == UI_OBJECT_CRAFT then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_ERROR_CANNOT_DRAG_CRAFT_IN_BAGPANEL)
		PlayTipSound("001")
		return
	elseif nSourceType == UI_OBJECT_OTER_PLAYER_ITEM then
		local _, dwBox, dwX, dwSaleID = boxHand:GetObjectData()
		local dwBox2 = box:GetRoot().nObjectType
		local dwX2 = box:GetBoxIndex()
		MarketTradePanel_BuyItem(dwBox, dwX, dwSaleID, dwBox2, dwX2)
		Hand_Clear()
		return
	elseif nSourceType ~= UI_OBJECT_ITEM then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_ERROR_CANNOT_DRAG_ITEM_IN_BAGPANEL)
		PlayTipSound("001")
		return	
	end	
		
	local _, dwBox1, dwX1 = boxHand:GetObjectData()
	local dwBox2 = box:GetRoot().nObjectType
	local dwX2 = box:GetBoxIndex()
	
	if OnExchangeItem(dwBox1, dwX1, dwBox2, dwX2, nHandCount) then
		Hand_Clear()
	end
end

function BagPanel_Base.OnItemMouseEnter()
	local szName = this:GetName()
	if szName == "Text_Coin" or szName == "Image_Coin" then
		return
	end
    
    if szName == "Handle_Option" then
        local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
        if this.szName then
            local szTip = GetFormatText(this.szName, 162)
            OutputTip(szTip, 400, {x+w, y, w, h})	
        end
        return
    end
    local szType = this:GetType()
    if szType ~= "Box" then
    	return
    end

	this:SetObjectMouseOver(1)
	if not this:IsEmpty() then
		local _, dwBox, dwX = this:GetObjectData()
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
		OutputItemTip(UI_OBJECT_ITEM, dwBox, dwX, nil, {x, y, w, h})
	end
	
	if UserSelect.IsSelectItem() then
		UserSelect.SatisfySelectItem(this:GetRoot().nObjectType, this:GetBoxIndex())
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

function BagPanel_Base.OnItemRefreshTip()
	return this:GetRoot():GetSelf().OnItemMouseEnter()
end

function BagPanel_Base.OnItemMouseLeave()
	local szName = this:GetName()
	if szName == "Text_Coin" or szName == "Image_Coin" then
		return
	end
    HideTip()
    if szName == "Handle_Option" then
        return
    end
    
    local szType = this:GetType()
    if szType ~= "Box" then
    	return
    end
    
	this:SetObjectMouseOver(0)
	
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

function BagPanel_Base.OnEvent(event)
	if event == "BAG_ITEM_UPDATE" then
		local nBoxIndex = arg0
		local nItemIndex = arg1
		
		if nBoxIndex == this.nObjectType then
			local box = this:Lookup("", "Box"..nItemIndex)
			local player = GetClientPlayer()
			local item = GetPlayerItem(player, nBoxIndex, nItemIndex)
			UpdataItemBoxObject(box, nBoxIndex, nItemIndex, item)
			if box:IsObjectMouseOver() then
				local thisSave = this
				this = box
				thisSave:GetSelf().OnItemMouseEnter()
				this = thisSave
			end
		end
	elseif event == "MONEY_UPDATE" or event == "SYNC_COIN" then
		this:GetSelf():UpdateMoneyShow(GetClientPlayer(), this:Lookup("", ""))
	elseif event == "UI_SCALED" then
		BagPanel_AjustPos()
	elseif event == "ON_SET_USE_BIGBAGPANEL" then
		if IsUseBigBagPanel() then
			CloseNormalBagPanel(this:GetRoot().nIndex)
		end
    elseif event == "CURRENCY_CHECK_NOTIFY" then
        if this.nIndex ==  1 then
            local handle = this:Lookup("", "")
            UpdatePlayerInfo(handle)
        end
    elseif event == "CURRENCY_VALUE_UPDATE" then
        if this.nIndex ~=  1 then
            return
        end
        local handle = this:Lookup("", "")
        local hCurrency = handle:Lookup("Handle_Currency")
        if not hCurrency then
            return
        end
        local tResult = Currency_GetCheckedCurrency() or {}
        local nCount = hCurrency:GetItemCount() - 1
        for i=0, nCount, 1 do
            local hItem = hCurrency:Lookup(i)
            if hItem and hItem.szName then
                for k, v in ipairs(tResult) do
                    if v and v.szName ==  hItem.szName then
                        hItem:Lookup("Text_Count"):SetText(v.nCount)
                        hItem:Lookup("Image_Logo"):SetFrame(v.nFrame)
                    end
                end
            end
        end 
	end
end

function BagPanel_Base.OnLButtonClick()
	local szName = this:GetName()
    if szName == "Btn_Close" then
    	CloseNormalBagPanel(this:GetRoot().nIndex)
    elseif szName == "Btn_Split" then
    	if not Hand_IsEmpty() then
    		Hand_Clear()
    	end
    	Cursor.Switch(CURSOR.SPLIT)	--拆分下的鼠标
    	PlaySound(SOUND.UI_SOUND,g_sound.Button)
--    elseif szName == "Btn_Market" then
--    	if IsMarketPanelOpened() then
--    		CloseMarketPanel()
--    	else
--    		OpenMarketPanel()
--    	end
    elseif szName == "Btn_Currency" then
        if IsCurrencyPanelOpened() then
            CloseCurrencyPanel()
        else
            OpenCurrencyPanel()
        end
    end
end

---------------------插件重新实现方法:--------------------------------
--1, BagPanel_Base = nil
--2, 重载下面函数
----------------------------------------------------------------------

function BagPanelIndexToEquipIndex(nIndex)
	local t = 
	{
		-1,
		EQUIPMENT_INVENTORY.PACKAGE1,
		EQUIPMENT_INVENTORY.PACKAGE2,
		EQUIPMENT_INVENTORY.PACKAGE3,
		EQUIPMENT_INVENTORY.PACKAGE4,
		EQUIPMENT_INVENTORY.BANK_PACKAGE1,
		EQUIPMENT_INVENTORY.BANK_PACKAGE2,
		EQUIPMENT_INVENTORY.BANK_PACKAGE3,
		EQUIPMENT_INVENTORY.BANK_PACKAGE4,
		EQUIPMENT_INVENTORY.BANK_PACKAGE5,
	}
	return t[nIndex]
end

function EquipIndexToBagPanelIndex(nIndex)
	if nIndex == EQUIPMENT_INVENTORY.PACKAGE1 then
		return 2
	elseif nIndex == EQUIPMENT_INVENTORY.PACKAGE2 then
		return 3
	elseif nIndex == EQUIPMENT_INVENTORY.PACKAGE3 then
		return 4
	elseif nIndex == EQUIPMENT_INVENTORY.PACKAGE4 then
		return 5
	elseif nIndex == EQUIPMENT_INVENTORY.BANK_PACKAGE1 then
		return 6
	elseif nIndex == EQUIPMENT_INVENTORY.BANK_PACKAGE2 then
		return 7
	elseif nIndex == EQUIPMENT_INVENTORY.BANK_PACKAGE3 then
		return 8
	elseif nIndex == EQUIPMENT_INVENTORY.BANK_PACKAGE4 then
		return 9
	elseif nIndex == EQUIPMENT_INVENTORY.BANK_PACKAGE5 then
		return 10
	end
	return nil
end

function OpenNormalBagPanel(nIndex, bDisableSound, bDisableAdjPos)
	if IsOptionOrOptionChildPanelOpened() then
		return
	end

	if IsNormalBagPanelOpened(nIndex) then
		return
	end
	local nPos = BagPanelIndexToEquipIndex(nIndex)
	if not nPos then
		return
	end
	if nPos ~= -1 then
		local item = GetPlayerItem(GetClientPlayer(), INVENTORY_INDEX.EQUIP, nPos)
		if not item then
			return
		end
		if nPos >= EQUIPMENT_INVENTORY.BANK_PACKAGE1 and 
			nPos <= EQUIPMENT_INVENTORY.BANK_PACKAGE5 and
			not IsBankPanelOpened() then
			return
		end		
	end
	
	Wnd.OpenWindow("BagPanel", "BagPanel"..nIndex)
	
	local argS = arg0
	arg0 = nIndex
	FireEvent("ON_OPEN_BAG_PANEL")
	arg0 = argS
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
	
	if not bDisableAdjPos then
		BagPanel_AjustPos()
	end
end

function CloseNormalBagPanel(nIndex, bDisableSound, bDisableAdjPos)
	if not IsNormalBagPanelOpened(nIndex) then
		return
	end
				
	Wnd.CloseWindow("BagPanel"..nIndex)
	
	local argS = arg0
	arg0 = nIndex
	FireEvent("ON_CLOSE_BAG_PANEL")
	arg0 = argS
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end
	
	if not bDisableAdjPos then
		BagPanel_AjustPos()
	end
end

function IsNormalBagPanelOpened(nIndex)
	local frame = Station.Lookup("Normal/BagPanel"..nIndex)
	if frame and frame:IsVisible() then
		return true
	end
	return false
end

function GetBagPanelFrame(nIndex)
	return Station.Lookup("Normal/BagPanel"..nIndex)
end

function OpenAllNormalBagPanel(bDisableSound)
	if IsOptionOrOptionChildPanelOpened() then
		return
	end

	local bHave = false
	for i = 1, 15, 1 do
		if not IsNormalBagPanelOpened(i) then
			OpenNormalBagPanel(i, true, true)
			bHave = true
		end
	end
	
	if bHave then
		if not bDisableSound then
			PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
		end
		BagPanel_AjustPos()
	end
end

function CloseAllNormalBagPanel(bDisableSound)
	local bHave = false
	for i = 1, 15, 1 do
		if IsNormalBagPanelOpened(i) then
			CloseNormalBagPanel(i, true, true)
			bHave = true
		end
	end
	
	if bHave and not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end
	_g_OpenBagIndex = 0
end

function IsAllNormalBagPanelOpened()
	if not IsNormalBagPanelOpened(1) then
		return false
	end
	local player = GetClientPlayer()
	for i = 2, 5, 1 do
	    local nBoxIndex = i + EQUIPMENT_INVENTORY.PACKAGE1 - 2
	    local item = GetPlayerItem(player, INVENTORY_INDEX.EQUIP, nBoxIndex)
	    if item then
			if not IsNormalBagPanelOpened(i) then
				return false
			end
	    end
	end
	return true
end

function IsAllNormalBagPanelClosed()
	for i = 1, 5, 1 do
		if IsNormalBagPanelOpened(i) then
			return false
		end
	end
	return true
end

function IsTwoRectIntersect(rc1, rc2)
	local bX = (rc1[1] > rc2[1] and rc1[1] < rc2[3]) or (rc1[3] > rc2[1] and rc1[3] < rc2[3]) or (rc2[1] > rc1[1] and rc2[1] < rc1[3])
	local bY = (rc1[2] > rc2[2] and rc1[2] < rc2[4]) or (rc1[4] > rc2[2] and rc1[4] < rc2[4]) or (rc2[2] > rc1[2] and rc2[2] < rc1[4])
	return bX and bY
end

function BagPanel_AjustPos()

	local t = {}
	for i = 1, 15, 1 do
		local frame = GetBagPanelFrame(i)
		if frame and frame:IsVisible() then
			table.insert(t, frame)
		end
	end
	
	if table.getn(t) == 0 then
		_g_OpenBagIndex = 0
		return
	end
	
	table.sort(t, function(a, b) return a.nOpenIndex < b.nOpenIndex end)
	
	local rc = GetBagRect()
	local bV = rc[4] - rc[2] > rc[3] - rc[1]
	local wS, hS = Station.GetClientSize()
	local xStart, yStart = 52, 80 
	local x, y = wS - xStart, hS - yStart
	for i, frame in ipairs(t) do
		local w, h = frame:GetSize()
		if y - h < 0 then
			x = x - w - 4
			y = hS - yStart
		end
		if not bV and IsTwoRectIntersect(rc, {x - w, y - h, x, y}) then
			y = rc[2]
			if y - h < 0 then
				x = x - w - 4
				y = hS - yStart
			end
		end
		frame:SetAbsPos(x - w, y - h)
		y = y - h
	end
end

function NormalBagPanel_GetItemBox(dwBox, dwID, bEvenUnVisible)
	local frame = Station.Lookup("Normal/BagPanel"..dwBox)
	if frame and (frame:IsVisible() or bEvenUnVisible) then
		return frame:Lookup("", "Box"..dwID)
	end
	return nil
end
