MarketTradePanel = {}

function MarketTradePanel.OnFrameCreate()
	this:RegisterEvent("ON_STALL")
	this:RegisterEvent("MONEY_UPDATE")
	this:RegisterEvent("CHANGE_STALL_TITLE")
	this:RegisterEvent("STALL_ITEM_UPDATE")
	this:RegisterEvent("CHANGE_STALL_STATE")
	
	local szIniFile = "UI/Config/Default/MarketTradePanel.ini"
	
	local handle = this:Lookup("", "Handle_Sale")
	handle:Clear()
	
	local player = GetClientPlayer()
    MarketTradePanel.dwSize = player.GetBoxSize(INVENTORY_INDEX.STALL_PACKAGE)
    MarketTradePanel.nPageCount = math.ceil(MarketTradePanel.dwSize / 12)
    MarketTradePanel.nCurrentPage = 1
    for i = 0, 11, 1 do
    	handle:AppendItemFromIni(szIniFile, "Handle_Item", "")
    	local hI = handle:Lookup(i)
    	local w, h = hI:GetSize()
    	if i % 2 == 0 then
    		hI:SetRelPos(0, h * math.floor(i / 2))
    	else
    		hI:SetRelPos(w, h * math.floor(i / 2))
    	end
    	if i < MarketTradePanel.dwSize then
    		hI:Show()
    		MarketTradePanel.UpdateItem(player, hI, nIndex, true)
		else
			hI:Hide()
    	end
    end
    handle:FormatAllItemPos()
	
	MarketTradePanel.UpdateMoneyShow(player, handle:GetParent())
	MarketTradePanel.UpdatePageNumber(handle:GetParent())
	
	InitFrameAutoPosInfo(this, 1, "Dialog", nil, function() CloseMarketTradePanel(true) end)
end

function MarketTradePanel.OnFrameBreathe()
	local player = GetClientPlayer()
	if not player or player.nMoveState == MOVE_STATE.ON_DEATH then
		CloseMarketTradePanel()
		return
	end
	
	local playerSale = GetPlayer(MarketTradePanel.dwPlayerID)
	if not playerSale or not playerSale.CanDialog(player) then
		CloseMarketTradePanel()
	end
	
	local nDisableIndex = nil
	if not Hand_IsEmpty() then
		local boxHand = Hand_Get()
		local nType, _, dwHBox, dwHX, dwSaleID = boxHand:GetObject()
		if nType == UI_OBJECT_OTER_PLAYER_ITEM and dwHBox == INVENTORY_INDEX.STALL_PACKAGE and dwSaleID == MarketTradePanel.dwPlayerID then
			if dwSaleID == MarketTradePanel.dwPlayerID then
				nDisableIndex = dwHX - (MarketTradePanel.nCurrentPage - 1) * 12
			else
				Hand_Clear()
			end
		end
	end
	local handle = this:Lookup("", "Handle_Sale")	
	for i = 0, 11, 1 do
    	local hI = handle:Lookup(i)
    	if nDisableIndex and i == nDisableIndex then
    		hI:Lookup("Box_Item"):EnableObject(false)
		else
			hI:Lookup("Box_Item"):EnableObject(true)
    	end
    end
end

function MarketTradePanel.OnEvent(event)
	if event == "ON_STALL" or event == "STALL_ITEM_UPDATE" then
		local playerSale = GetPlayer(MarketTradePanel.dwPlayerID)
		if playerSale then
			MarketTradePanel.UpdateCurrentPageData(this)
		else
			CloseMarketTradePanel()
		end
	elseif event == "MONEY_UPDATE" then
		MarketTradePanel.UpdateMoneyShow(GetClientPlayer(), this:Lookup("", ""))
		MarketTradePanel.UpdateCurrentPageData(this)
	elseif event == "CHANGE_STALL_TITLE" then
		local playerSale = GetPlayer(MarketTradePanel.dwPlayerID)
		if playerSale then
		    local szTitle = playerSale.GetStallTitle()
		    if not szTitle or szTitle == "" then
		    	szTitle = FormatString(g_tStrings.MARKET_STALL_FOR_ONE, playerSale.szName)
		    end
			this:Lookup("", "Text_Title"):SetText(szTitle)
		else
			CloseMarketTradePanel()
		end
	elseif event == "CHANGE_STALL_STATE" then
	    local playerSale = GetPlayer(MarketTradePanel.dwPlayerID)
	    if not playerSale.bStall then
	        CloseMarketTradePanel()
	    end
	end
end

function MarketTradePanel.UpdateMoneyShow(player, handle)
    local nMoney = player.GetMoney()
    local nGold, nSilver, nCopper = MoneyToGoldSilverAndCopper(nMoney)
    
    local textG = handle:Lookup("Text_GoldSale")
    local textS = handle:Lookup("Text_SilverSale")
    local textC = handle:Lookup("Text_CopperSale")
    local imageG = handle:Lookup("Image_GoldSale")
    local imageS = handle:Lookup("Image_SilverSale")
    local imageC = handle:Lookup("Image_CopperSale")
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

function MarketTradePanel.PagePrevOrPageNext(frame, bNext)
	if (bNext and MarketTradePanel.nCurrentPage >= MarketTradePanel.nPageCount) or (not bNext and MarketTradePanel.nCurrentPage <= 1) then
		return
	end
	
	if bNext then
		MarketTradePanel.nCurrentPage = MarketTradePanel.nCurrentPage + 1
	else
		MarketTradePanel.nCurrentPage = MarketTradePanel.nCurrentPage - 1
	end
	
	MarketTradePanel.UpdateCurrentPageData(frame)
    MarketTradePanel.UpdatePageNumber(frame:Lookup("", ""))
end

function MarketTradePanel.UpdateCurrentPageData(frame)
	local player = GetPlayer(MarketTradePanel.dwPlayerID)
	local handle = frame:Lookup("", "Handle_Sale")
	local nIndexStart = (MarketTradePanel.nCurrentPage - 1) * 12
	
    for i = 0, 11, 1 do
    	local hI = handle:Lookup(i)
    	if i < MarketTradePanel.dwSize then
    		hI:Show()
    		MarketTradePanel.UpdateItem(player, hI, nIndexStart + i)
		else
			hI:Hide()
    	end
    end
    
    local szTitle = player.GetStallTitle()
    if not szTitle or szTitle == "" then
    	szTitle = FormatString(g_tStrings.MARKET_STALL_FOR_ONE, player.szName)
    end
    handle:GetParent():Lookup("Text_Title"):SetText(szTitle)
end

function MarketTradePanel.UpdatePageNumber(handle)
	handle:Lookup("Text_PageNum"):SetText(MarketTradePanel.nCurrentPage.."/"..MarketTradePanel.nPageCount)
	if MarketTradePanel.nCurrentPage >= MarketTradePanel.nPageCount then
		handle:GetParent():Lookup("Btn_PageNext"):Enable(false)
	else
		handle:GetParent():Lookup("Btn_PageNext"):Enable(true)
	end
	if MarketTradePanel.nCurrentPage <= 1 then
		handle:GetParent():Lookup("Btn_PagePrev"):Enable(false)
	else
		handle:GetParent():Lookup("Btn_PagePrev"):Enable(true)
	end
end

function MarketTradePanel.UpdateItem(player, hI, nIndex, bClear)
	local box = hI:Lookup("Box_Item")
	box:SetBoxIndex(nIndex)
	local item = nil
	if not bClear then
		item = GetPlayerItem(player, INVENTORY_INDEX.STALL_PACKAGE, nIndex)	
	end
	
	if item then
		--如果该格子有物品
		box:SetObject(UI_OBJECT_OTER_PLAYER_ITEM, item.nUiId, INVENTORY_INDEX.STALL_PACKAGE, nIndex, MarketTradePanel.dwPlayerID)			
		box:SetObjectIcon(Table_GetItemIconID(item.nUiId))
		
		if item.bCanStack and item.nStackNum > 1 then
			box:SetOverText(0, item.nStackNum)
		else
			box:SetOverText(0, "")
		end		
	else
		--如果没有物品
		box:ClearObject()
		box:SetOverText(0, "")
	end	
	
	if not Hand_IsEmpty() then
		local boxHand = Hand_Get()
		local nType, _, dwHBox, dwHX, dwSaleID = boxHand:GetObject()
		if nType == UI_OBJECT_OTER_PLAYER_ITEM and dwHBox == INVENTORY_INDEX.STALL_PACKAGE and dwHX == nIndex and dwSaleID == MarketTradePanel.dwPlayerID then
			if item then
				Hand_Pick(box)
			else
				Hand_Clear()
			end
		end
	end	
			
	box:SetOverTextPosition(0, ITEM_POSITION.RIGHT_BOTTOM)
	box:SetOverTextFontScheme(0, 15)
	if box:IsObjectMouseOver() then
		local thisSave = this
		this = box
		MarketTradePanel.OnItemMouseEnter()
		this = thisSave
	end
	
	if item then
		hI:Lookup("Text_Name"):SetText(GetItemNameByItem(item))
		hI:Lookup("Text_Name"):SetFontColor(GetItemFontColorByQuality(item.nQuality))
		local nGold, nSilver, nCopper = MoneyToGoldSilverAndCopper(item.nUserPrice)
		if nGold == 0 then
	    	hI:Lookup("Text_Gold"):SetText("")
	    	hI:Lookup("Image_Gold"):Hide()
	    	if nSilver == 0 then
		    	hI:Lookup("Text_Silver"):SetText("")
		    	hI:Lookup("Image_Silver"):Hide()
		    	hI:Lookup("Text_Copper"):SetText(nCopper)
		    	hI:Lookup("Image_Copper"):Show()
		    else
				hI:Lookup("Text_Silver"):SetText(nSilver)
				hI:Lookup("Text_Copper"):SetText(nCopper)
				hI:Lookup("Image_Silver"):Show()
				hI:Lookup("Image_Copper"):Show()		    
	    	end
		else
			hI:Lookup("Text_Gold"):SetText(nGold)
			hI:Lookup("Text_Silver"):SetText(nSilver)
			hI:Lookup("Text_Copper"):SetText(nCopper)
			hI:Lookup("Image_Gold"):Show()
			hI:Lookup("Image_Silver"):Show()
			hI:Lookup("Image_Copper"):Show()
		end
		if GetClientPlayer().GetMoney() < item.nUserPrice then
			hI:Lookup("Image_Disable"):Show()
		else
			hI:Lookup("Image_Disable"):Hide()
		end
	else
		hI:Lookup("Text_Name"):SetText("")
		hI:Lookup("Text_Gold"):SetText("")
		hI:Lookup("Text_Silver"):SetText("")
		hI:Lookup("Text_Copper"):SetText("")
		hI:Lookup("Image_Gold"):Hide()
		hI:Lookup("Image_Silver"):Hide()
		hI:Lookup("Image_Copper"):Hide()
	end
end


function MarketTradePanel.OnItemLButtonDown()
	this.bIgnoreClick = nil
	if IsCtrlKeyDown() and not this:IsEmpty() then
		local _, dwBox, dwX = this:GetObjectData()
		local player = GetPlayer(MarketTradePanel.dwPlayerID)
		if player then
			local item = GetPlayerItem(player, dwBox, dwX)
			if item then
				if IsGMPanelReceiveItem() then
					GMPanel_LinkItem(item.dwID)
				else
					EditBox_AppendLinkItem(item.dwID)
				end
			end
		end
		this.bIgnoreClick = true
	end

	this:SetObjectPressed(1)
end

function MarketTradePanel.OnItemLButtonUp()
	this:SetObjectPressed(0)
end

function MarketTradePanel.OnItemLButtonDrag()
	this:SetObjectPressed(0)
	
	if not this:IsObjectEnable() then
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
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.TRADE_HAND_EMPTY)
	end
end

function MarketTradePanel.OnItemLButtonClick()
	if this.bIgnoreClick then
		this.bIgnoreClick = nil
		return
	end
	
	if not this:IsObjectEnable() then
		if not Hand_IsEmpty() and not this:IsEmpty() then
			local box = Hand_Get()
			local dwType, _, dwBox, dwX = box:GetObject()
			local dwTType, _, dwTBox, dwTX = this:GetObject()
			if dwType== dwTType and dwBox == dwTBox and dwX == dwTX then
				Hand_Clear()
			end
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
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.TRADE_HAND_EMPTY)
	end	
end

-------右键操作-------
function MarketTradePanel.OnItemRButtonDown()
	this:SetObjectPressed(1)
end

function MarketTradePanel.OnItemRButtonUp()
	this:SetObjectPressed(0)
end

function MarketTradePanel.OnItemRButtonClick()
	if this:IsEmpty() then
		return
	end	
	
	if not this:IsObjectEnable() then
		return
	end
	
	local _, dwBox, dwX, dwSaleID = this:GetObjectData()
	MarketTradePanel_BuyItem(dwBox, dwX, dwSaleID)
end

function MarketTradePanel.OnItemMouseEnter()
	this:SetObjectMouseOver(1)
	
	if Cursor.GetCurrentIndex() == CURSOR.SPLIT then
		Cursor.Switch(CURSOR.UNABLESPLIT)
	elseif Cursor.GetCurrentIndex() == CURSOR.REPAIRE then
		Cursor.Switch(CURSOR.UNABLEREPAIRE)			
	elseif not IsCursorInExclusiveMode() then
		if this:GetParent():Lookup("Image_Disable"):IsVisible() then
			Cursor.Switch(CURSOR.UNABLEBUYBACK)
		else
			Cursor.Switch(CURSOR.BUYBACK)
		end
	end
	
	HideTip()
	if not this:IsEmpty() then
		local _, dwBox, dwX = this:GetObjectData()
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
		local player = GetPlayer(MarketTradePanel.dwPlayerID)
		if player then
			local item = GetPlayerItem(player, dwBox, dwX)
			if item then
				OutputItemTip(UI_OBJECT_ITEM_ONLY_ID, item.dwID, nil, nil, {x, y, w, h})
			end
		end
	end
end

function MarketTradePanel.OnItemMouseLeave()
	HideTip()
	this:SetObjectMouseOver(0)
	if Cursor.GetCurrentIndex() == CURSOR.UNABLESPLIT then
		Cursor.Switch(CURSOR.SPLIT)
	elseif Cursor.GetCurrentIndex() == CURSOR.UNABLEREPAIRE then
		Cursor.Switch(CURSOR.REPAIRE)
	elseif not IsCursorInExclusiveMode() then
		Cursor.Switch(CURSOR.NORMAL)
	end
end

function MarketTradePanel.OnLButtonClick()
	local frame = this:GetRoot()
    local szName = this:GetName()
	if szName == "Btn_PagePrev" then
		MarketTradePanel.PagePrevOrPageNext(this:GetParent(), false)
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
	elseif szName == "Btn_PageNext" then
		MarketTradePanel.PagePrevOrPageNext(this:GetParent(), true)
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
	elseif szName == "Btn_Close" then
        CloseMarketTradePanel()
    end
end

function OpenMarketTradePanel(dwPlayerID, bDisableSound)
	if IsOptionOrOptionChildPanelOpened() then
		return
	end

	MarketTradePanel.dwPlayerID = dwPlayerID
	GetClientPlayer().ApplyStallItem(dwPlayerID)
	Wnd.OpenWindow("MarketTradePanel")
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
end

function CloseMarketTradePanel(bDisableSound)
	Wnd.CloseWindow("MarketTradePanel")
	if not Hand_IsEmpty() then
		local boxHand = Hand_Get()
		local nType, _, dwHBox, dwHX, dwSaleID = boxHand:GetObject()
		if nType == UI_OBJECT_OTER_PLAYER_ITEM and dwHBox == INVENTORY_INDEX.STALL_PACKAGE and dwSaleID == MarketTradePanel.dwPlayerID then
			Hand_Clear()
		end
	end	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end
end

function IsMarketTradePanelOpened()
	local frame = Station.Lookup("Normal/MarketTradePanel")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end

function MarketTradePanel_BuyItem(dwBox, dwX, dwSaleID, dwTX, dwTY)
	local playerSale = GetPlayer(dwSaleID)
	if playerSale then
		local item = GetPlayerItem(playerSale, dwBox, dwX)
		if item then
			local msg = 
			{
				szName = "MarketBuyItemSure",
				bRichText = true,
				szMessage = FormatString(g_tStrings.TRADE_SURE_BUY, GetItemNameByItem(item), GetMoneyText(item.nUserPrice, "font=0")),
				fnAutoClose = function() return not IsMarketTradePanelOpened() end,
				{szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = function() 
												if dwTX and dwTY then 
													GetClientPlayer().BuyStallItem(dwSaleID, dwX, dwTX, dwTY)
												else 
													GetClientPlayer().BuyStallItem(dwSaleID, dwX) 
												end
											end
				},
				{szOption = g_tStrings.STR_HOTKEY_CANCEL}
			}
			MessageBox(msg, true)		
		end
	end
end
