MarketPanel = {}

function MarketPanel.OnFrameCreate()
	this:RegisterEvent("STALL_ITEM_UPDATE")
	this:RegisterEvent("MONEY_UPDATE")
	this:RegisterEvent("CHANGE_STALL_STATE")
	this:RegisterEvent("ON_SOLD_STALL_ITEM")

	local szIniFile = "UI/Config/Default/MarketPanel.ini"
	
	local player = GetClientPlayer()
	local handle = this:Lookup("PageSet_Main/Page_Market", "Handle_Sale")
    handle:Clear()
	
    MarketPanel.dwSize = player.GetBoxSize(INVENTORY_INDEX.STALL_PACKAGE)
    MarketPanel.nPageCount = math.ceil(MarketPanel.dwSize / 12)
    MarketPanel.nCurrentPage = 1
    for i = 0, 11, 1 do
    	handle:AppendItemFromIni(szIniFile, "Handle_Item", "")
    	local hI = handle:Lookup(i)
    	local w, h = hI:GetSize()
    	if i % 2 == 0 then
    		hI:SetRelPos(0, h * math.floor(i / 2))
    	else
    		hI:SetRelPos(w, h * math.floor(i / 2))
    	end
    	if i < MarketPanel.dwSize then
    		hI:Show()
    		MarketPanel.UpdateItem(player, hI, i)
		else
			hI:Hide()
    	end
    end
    handle:FormatAllItemPos()
    
    local szTitle = player.GetStallTitle()
    if not szTitle or szTitle == "" then
    	szTitle = FormatString(g_tStrings.MARKET_STALL_FOR_ONE, player.szName)
    end
    local edit = handle:GetParent():GetParent():Lookup("Edit_Name")
    edit.bDisable = true
    edit:SetText(szTitle)
    edit.bDisable = false
    
    MarketPanel.UpdateMoneyShow(player, handle:GetParent())
    
    MarketPanel.UpdatePageNumber(handle:GetParent())
    MarketPanel.UpdateMarketState(this, false)
    
    RefreshUILockItem()
    
    InitFrameAutoPosInfo(this, 1, nil, nil, function() CloseMarketPanel(true) end)
end

function MarketPanel.UpdateMarkPriceBtnState(page)
	if MarketPanel.bInMarket then
		page:Lookup("Btn_Amend"):Enable(false)
	else
		local handle = page:Lookup("", "Handle_Sale")
		local nCount = handle:GetItemCount() - 1
		local bEnable = false
		for i = 0, nCount, 1 do
			local hI = handle:Lookup(i)
			if hI:IsVisible() and not hI:Lookup("Box_Item"):IsEmpty() then
				bEnable = true
			end
		end
		if bEnable then
			page:Lookup("Btn_Amend"):Enable(true)
		else
			page:Lookup("Btn_Amend"):Enable(false)
		end
	end
end

function MarketPanel.UpdateMarketState(frame, bNewMarket)
	local page = frame:Lookup("PageSet_Main/Page_Market")
	
	MarketPanel.UpdateMarkPriceBtnState(page)
	
	if MarketPanel.bInMarket then
		page:Lookup("Btn_Stop"):Enable(true)
	else
		page:Lookup("Btn_Stop"):Enable(false)
	end
	
	local handle = frame:Lookup("PageSet_Main/Page_History", "Handle_BusinessHistory")
	if bNewMarket then
		handle:Clear()
	end
	MarketPanel.UpdateScrollInfo(handle)
end

function MarketPanel.UpdateScrollInfo(handle)
	handle:FormatAllItemPos()
	local page = handle:GetParent():GetParent()
	local wA, hA = handle:GetAllItemSize()
	local w, h = handle:GetSize()
	local nStep = (hA - h) / 10
	if nStep > 0 then
		page:Lookup("Scroll_History"):Show()
		page:Lookup("Btn_Up"):Show()
		page:Lookup("Btn_Down"):Show()
	else
		page:Lookup("Scroll_History"):Hide()
		page:Lookup("Btn_Up"):Hide()
		page:Lookup("Btn_Down"):Hide()
	end
	page:Lookup("Scroll_History"):SetStepCount((hA - h) / 10)
end

function MarketPanel.UpdateMoneyShow(player, handle)
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

function MarketPanel.PagePrevOrPageNext(page, bNext)
	if (bNext and MarketPanel.nCurrentPage >= MarketPanel.nPageCount) or (not bNext and MarketPanel.nCurrentPage <= 1) then
		return
	end
	
	if bNext then
		MarketPanel.nCurrentPage = MarketPanel.nCurrentPage + 1
	else
		MarketPanel.nCurrentPage = MarketPanel.nCurrentPage - 1
	end
	local player = GetClientPlayer()
	local handle = page:Lookup("", "Handle_Sale")
	local nIndexStart = (MarketPanel.nCurrentPage - 1) * 12
	
    for i = 0, 11, 1 do
    	local hI = handle:Lookup(i)
    	if i < MarketPanel.dwSize then
    		hI:Show()
    		MarketPanel.UpdateItem(player, hI, nIndexStart + i)
		else
			hI:Hide()
    	end
    end
    
    MarketPanel.UpdatePageNumber(handle:GetParent())
end

function MarketPanel.UpdatePageNumber(handle)
	handle:Lookup("Text_PageNum"):SetText(MarketPanel.nCurrentPage.."/"..MarketPanel.nPageCount)
	if MarketPanel.nCurrentPage >= MarketPanel.nPageCount then
		handle:GetParent():Lookup("Btn_PageNext"):Enable(false)
	else
		handle:GetParent():Lookup("Btn_PageNext"):Enable(true)
	end
	if MarketPanel.nCurrentPage <= 1 then
		handle:GetParent():Lookup("Btn_PagePrev"):Enable(false)
	else
		handle:GetParent():Lookup("Btn_PagePrev"):Enable(true)
	end
end

function MarketPanel.UpdateItem(player, hI, nIndex)
	local box = hI:Lookup("Box_Item")
	box:SetBoxIndex(nIndex)
	local item = GetPlayerItem(player, INVENTORY_INDEX.STALL_PACKAGE, nIndex)		
	UpdataItemBoxObject(box, INVENTORY_INDEX.STALL_PACKAGE, nIndex, item)
	box:SetOverTextPosition(0, ITEM_POSITION.RIGHT_BOTTOM)
	box:SetOverTextFontScheme(0, 15)
	if item and item.bCanStack and item.nStackNum > 1 then
		box:SetOverText(0, item.nStackNum)
	else
		box:SetOverText(0, "")
	end
	if box:IsObjectMouseOver() then
		local thisSave = this
		this = box
		MarketPanel.OnItemMouseEnter()
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

function MarketPanel.OnEvent(event)
	if event == "STALL_ITEM_UPDATE" then
		local handle = this:Lookup("PageSet_Main/Page_Market", "Handle_Sale")
		local nIndex = arg1 - (MarketPanel.nCurrentPage - 1) * 12
		if nIndex >= 0 and nIndex < 12 then
			local hI = handle:Lookup(nIndex)
			MarketPanel.UpdateItem(GetClientPlayer(), hI, arg1)
			MarketPanel.UpdateMarkPriceBtnState(handle:GetParent():GetParent())
		end
	elseif event == "MONEY_UPDATE" then
		MarketPanel.UpdateMoneyShow(GetClientPlayer(), this:Lookup("PageSet_Main/Page_Market", ""))
	elseif event == "CHANGE_STALL_STATE" then
		MarketPanel.bInMarket = GetClientPlayer().bStall
		MarketPanel.UpdateMarketState(this, true)
	elseif event == "ON_SOLD_STALL_ITEM" then
		local handle = this:Lookup("PageSet_Main/Page_History", "Handle_BusinessHistory")
		local szFont = "font=0"
		local szMsg = ""
		local item = GetItem(arg0)
		if item then
			local szItemName = GetItemNameByItem(item)
			szMsg = szMsg..MakeItemLink("["..szItemName.."]", szFont..GetItemFontColorByQuality(item.nQuality, true), arg0)
        else
        	szMsg = szMsg.."<text>text="..EncodeComponentsString(g_tStrings.STR_TALK_UNKNOWN_ITEM_LINK)..szFont.."</text>"
        end
        if item.bCanStack and item.nStackNum > 1 then
        	szMsg = szMsg.."<text>text="..EncodeComponentsString(" X "..item.nStackNum)..szFont.."</text>"
        end
        szMsg = szMsg.."<text>text="..EncodeComponentsString(g_tStrings.TRADE_BE)..szFont.."</text>"
        local player = GetPlayer(arg1)
        if player then
        	szMsg = szMsg..MakeNameLink("["..player.szName.."]", szFont)
        else
        	szMsg = szMsg.."<text>text="..EncodeComponentsString(g_tStrings.TRADE_OTHER)..szFont.."</text>"
        end
        szMsg = szMsg.."<text>text="..EncodeComponentsString(g_tStrings.TRADE_GET)..szFont.."</text>"
        szMsg = szMsg..GetMoneyText(arg2, szFont)
        szMsg = szMsg.."<text>text=\"\\\n\"</text>"
        
        handle:AppendItemFromString(szMsg)
		
		local scroll = this:Lookup("PageSet_Main/Page_History/Scroll_History")
		local bEnd = false
		page:Lookup("Scroll_History"):GetStepCount()
		if scroll:GetStepCount() == scroll:GetScrollPos() then
			bEnd = true
		end
		MarketPanel.UpdateScrollInfo(handle)
		if bEnd then
			scroll:ScrollEnd()
		end
	end
end

function MarketPanel.OnItemLButtonDown()
	local szName = this:GetName()
	if szName == "itemlink" then
		local dwID = this:GetUserData()
		if IsCtrlKeyDown() then
			if IsGMPanelReceiveItem() then
				GMPanel_LinkItem(dwID)
			else
				EditBox_AppendLinkItem(dwID)
			end
		else
			local x, y = this:GetAbsPos()
			local w, h = this:GetSize()
			OutputItemTip(UI_OBJECT_ITEM_ONLY_ID, dwID, nil, nil, {x, y, w, h}, true)
		end
		return
	elseif szName == "namelink" then
		local szText = this:GetText()
		if string.sub(szText, -1, -1) == "]" then
			szText = string.sub(szText, 2, -2)
		else
			szText = string.sub(szText, 2, -3)
		end
		if IsCtrlKeyDown() then
			if IsGMPanelReceivePlayer() then
				GMPanel_LinkPlayerName(szText)
			else		
				EditBox_AppendLinkPlayer(szText)
			end
		else
			EditBox_TalkToSomebody(szText)
		end
		return
	end

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

function MarketPanel.OnItemLButtonUp()
	this:SetObjectPressed(0)
end

function MarketPanel.OnItemLButtonDrag()
	this:SetObjectPressed(0)
	
	if not this:IsObjectEnable() then
		return
	end
	
	if MarketPanel.bInMarket then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.ERROR_NOT_OPERATE_ITEM_INMARKET)
		return
	end
	
	if UserSelect.DoSelectItem(INVENTORY_INDEX.STALL_PACKAGE, this:GetBoxIndex()) then
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

function MarketPanel.OnItemLButtonDragEnd()
	this.bIgnoreClick = true
	
	local thisSave = this
	if this:GetName() ~= "Box_Item" then
		this = this:Lookup("Box_Item")
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
		this = thisSave
		return
	end

	if MarketPanel.bInMarket then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.ERROR_NOT_OPERATE_ITEM_INMARKET)
		this = thisSave
		return
	end	
	
	if not Hand_IsEmpty() then
		MarketPanel.OnExchangeBoxAndHandBoxItem(this)
	end
	
	this = thisSave
end

function MarketPanel.OnItemLButtonClick()
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
	
	if MarketPanel.bInMarket then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.ERROR_NOT_OPERATE_ITEM_INMARKET)
		return
	end		
	
	if UserSelect.DoSelectItem(INVENTORY_INDEX.STALL_PACKAGE, this:GetBoxIndex()) then
		return
	end	

	if (IsShiftKeyDown() and not IsCursorInExclusiveMode()) or Cursor.GetCurrentIndex() == CURSOR.SPLIT then
		OnSplitBoxItem(this)
		return
	end

	if (IsAltKeyDown() and not IsCursorInExclusiveMode()) or Cursor.GetCurrentIndex() == CURSOR.MARKPRICE then
		local _, dwTBox, dwTX = this:GetObjectData()
		local item = GetPlayerItem(GetClientPlayer(), dwTBox, dwTX)
		if item then
			local szMsg = g_tStrings.MARKET_INPUT_PRICE
			local fnAction = function(nPrice)
				GetClientPlayer().SetItemPrice(dwTBox, dwTX, nPrice)
				local box = MarketPanel_GetItemBox(dwTBox, dwTX)
				if box then 
					box:EnableObject(true)
				end				
			end
			local fnCancel = function()
				local box = MarketPanel_GetItemBox(dwTBox, dwTX)
				if box then 
					box:EnableObject(true)
				end
			end
			this:EnableObject(false)
			GetUserSetPrice(szMsg, item.nUserPrice, fnAction,  fnCancel, function() if IsMarketPanelOpened() then return false end return true end)
			Cursor.Switch(CURSOR.NORMAL)
		end
		return
	end

	
	if Cursor.GetCurrentIndex() == CURSOR.REPAIRE or Cursor.GetCurrentIndex() == CURSOR.UNABLEREPAIRE then	--修理物品
		if not this:IsEmpty() then
			ShopRepairItem(INVENTORY_INDEX.STALL_PACKAGE, this:GetBoxIndex())
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
		MarketPanel.OnExchangeBoxAndHandBoxItem(this)
	end	
end

-------右键操作-------
function MarketPanel.OnItemRButtonDown()
	if this:GetName() == "namelink" then
		local szText = this:GetText()
		if string.sub(szText, -1, -1) == "]" then
			szText = string.sub(szText, 2, -2)
		else
			szText = string.sub(szText, 2, -3)
		end
		
		local player = GetClientPlayer()
		local menu = 
		{
			{szOption = g_tStrings.STR_SAY_SECRET, fnAction = function() EditBox_TalkToSomebody(szText) end},
			{szOption = g_tStrings.STR_MAKE_PARTY, bDisable = not CanMakeParty(), fnAction = function() GetClientTeam().InviteJoinTeam(szText) end},
			{szOption = g_tStrings.STR_MAKE_FRIEND, fnAction = function() GetClientPlayer().AddFellowship(szText) end},
		}
		PopupMenu(menu)
		return
	end

	this:SetObjectPressed(1)
end

function MarketPanel.OnItemRButtonUp()
	this:SetObjectPressed(0)
end

function MarketPanel.OnItemRButtonClick()
	if this:IsEmpty() then
		return
	end	
	
	if not this:IsObjectEnable() then
		return
	end
	
	if MarketPanel.bInMarket then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.ERROR_NOT_OPERATE_ITEM_INMARKET)
		return
	end	

	local player = GetClientPlayer()
	local dwBox, dwX = player.GetStackRoomInPackage(INVENTORY_INDEX.STALL_PACKAGE, this:GetBoxIndex())
	if dwBox and dwX then
		OnExchangeItem(INVENTORY_INDEX.STALL_PACKAGE, this:GetBoxIndex(), dwBox, dwX)
		PlayItemSound(this:GetObjectData(), false)
	else
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_ERROR_BAG_IS_FULL)
		PlayTipSound("006")
	end
end

function MarketPanel.OnExchangeBoxAndHandBoxItem(box)
	local boxHand, nHandCount = Hand_Get()
	local nSourceType = boxHand:GetObjectType()
	if nSourceType == UI_OBJECT_SKILL then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_ERROR_CANNOT_DRAG_SKILL_IN_MarketPanel)
		return
	elseif nSourceType == UI_OBJECT_CRAFT then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_ERROR_CANNOT_DRAG_CRAFT_IN_MarketPanel)
		return
	elseif nSourceType == UI_OBJECT_OTER_PLAYER_ITEM then
		local _, dwBox, dwX, dwSaleID = boxHand:GetObjectData()
		local dwBox2 = INVENTORY_INDEX.STALL_PACKAGE
		local dwX2 = box:GetBoxIndex()
		MarketTradePanel_BuyItem(dwBox, dwX, dwSaleID, dwBox2, dwX2)	
		Hand_Clear()
		return	
	elseif nSourceType ~= UI_OBJECT_ITEM then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_ERROR_CANNOT_DRAG_ITEM_IN_MarketPanel)
		return
	end
	
	local _, dwBox1, dwX1 = boxHand:GetObjectData()
	local dwBox2 = INVENTORY_INDEX.STALL_PACKAGE
	local dwX2 = box:GetBoxIndex()
		
	if OnExchangeItem(dwBox1, dwX1, dwBox2, dwX2, nHandCount) then
		Hand_Clear()
	end
end

function MarketPanel.OnItemMouseEnter()
	this:SetObjectMouseOver(1)
	if not this:IsEmpty() then
		local _, dwBox, dwX = this:GetObjectData()
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
		OutputItemTip(UI_OBJECT_ITEM, dwBox, dwX, nil, {x, y, w, h})	
	end
	
	if UserSelect.IsSelectItem() then
		UserSelect.SatisfySelectItem(INVENTORY_INDEX.STALL_PACKAGE, this:GetBoxIndex())
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

function MarketPanel.OnItemMouseLeave()
	HideTip()
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


function MarketPanel.OnFrameBreathe()
end

function MarketPanel.OnLButtonClick()
	local frame = this:GetRoot()
    local szName = this:GetName()
	if szName == "Btn_Amend" then
    	if not Hand_IsEmpty() then
    		Hand_Clear()
    	end
    	Cursor.Switch(CURSOR.MARKPRICE)
    	PlaySound(SOUND.UI_SOUND,g_sound.Button)
	elseif szName == "Btn_Stop" then
		local msg = 
		{
			szMessage = g_tStrings.MARKET_STOP, 
			szName = "StopStallSure", 
			{szOption = g_tStrings.STR_HOTKEY_SURE, 
				fnAction = function() 
					GetClientPlayer().EndStall()
				end
			},
			{szOption = g_tStrings.STR_HOTKEY_CANCEL},
		}
		MessageBox(msg)
	elseif szName == "Btn_PagePrev" then
		MarketPanel.PagePrevOrPageNext(this:GetParent(), false)
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
	elseif szName == "Btn_PageNext" then
		MarketPanel.PagePrevOrPageNext(this:GetParent(), true)
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
	elseif szName == "Btn_Sure" then
		local edit = this:GetParent():Lookup("Edit_Name")
		GetClientPlayer().SetStallTitle(edit:GetText())
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
	elseif szName == "Btn_Close" then
        CloseMarketPanel()
    end
end

function MarketPanel.OnScrollBarPosChanged()
	local nCurrentValue = this:GetScrollPos()
	local page = this:GetParent()
	if nCurrentValue == 0 then
		page:Lookup("Btn_Up"):Enable(false)
	else
		page:Lookup("Btn_Up"):Enable(true)
	end
	if nCurrentValue == this:GetStepCount() then
		page:Lookup("Btn_Down"):Enable(false)
	else
		page:Lookup("Btn_Down"):Enable(true)
	end
	
    local handle = page:Lookup("", "Handle_BusinessHistory")
    handle:SetItemStartRelPos(0, - nCurrentValue * 10)
end

function MarketPanel.OnLButtonDown()
	MarketPanel.OnLButtonHold()
end

function MarketPanel.OnLButtonHold()
    local szName = this:GetName()
	if szName == "Btn_Up" then
		this:GetParent():Lookup("Scroll_History"):ScrollPrev(1)
	elseif szName == "Btn_Down" then
		this:GetParent():Lookup("Scroll_History"):ScrollNext(1)
    end
end

function MarketPanel.OnItemMouseWheel()
	local nDistance = Station.GetMessageWheelDelta()
	this:GetParent():Lookup("Scroll_History"):ScrollNext(nDistance)
	return 1
end

function MarketPanel.OnEditChanged()
	local szName = this:GetName()
	if szName == "Edit_Name" then
	end
end

function OpenMarketPanel(bDisableSound)
	if IsOptionOrOptionChildPanelOpened() then
		return
	end

	MarketPanel.bInMarket = GetClientPlayer().bStall
	
	if IsMarketPanelOpened() then
		MarketPanel.UpdateMarketState(Station.Lookup("Normal/MarketPanel"), true)
		return
	end
	local frame = Wnd.OpenWindow("MarketPanel")
	frame:Show()
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
end

function CloseMarketPanel(bDisableSound)
	if not IsMarketPanelOpened() then
		return		
	end

	Station.Lookup("Normal/MarketPanel"):Hide()
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND, g_sound.CloseFrame)
	end
end

function IsMarketPanelOpened()
	local frame = Station.Lookup("Normal/MarketPanel")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end

function AppendItemToMarketPanel(dwBox, dwx)
	local frame = Station.Lookup("Normal/MarketPanel")
	if frame and frame:IsVisible() then
		local handle = frame:Lookup("PageSet_Main/Page_Market", "Handle_Sale")
		local nCount = handle:GetItemCount() - 1
		for i = 0, nCount, 1 do
			local hI = handle:Lookup(i)
			if hI:IsVisible() and hI:Lookup("Box_Item"):IsEmpty() then
				OnExchangeItem(dwBox, dwx, INVENTORY_INDEX.STALL_PACKAGE, hI:Lookup("Box_Item"):GetBoxIndex())
				return
			end
		end
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.MARKET_FULL)
	end
end

function MarketPanel_GetItemBox(dwBox, dwX)
	if dwBox ~= INVENTORY_INDEX.STALL_PACKAGE then
		return nil
	end
	local frame = Station.Lookup("Normal/MarketPanel")
	if frame and frame:IsVisible() then
		local handle = frame:Lookup("PageSet_Main/Page_Market", "Handle_Sale")
		local nCount = handle:GetItemCount() - 1
		for i = 0, nCount, 1 do
			local hI = handle:Lookup(i)
			if hI:IsVisible() and hI:Lookup("Box_Item"):GetBoxIndex() == dwX then
				return hI:Lookup("Box_Item")
			end
		end
	end
	return nil
end
