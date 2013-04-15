local TRADE_PANEL_BOX_COUNT = 7
local TRADE_PANEL_WARNING_TIME = 1000 * 3

TradePanel = {}

function TradePanel.OnFrameCreate()
	--this:RegisterEvent("TRADING_UPDATE_STATE")
	this:RegisterEvent("TRADING_UPDATE_CONFIRM")
	this:RegisterEvent("TRADING_UPDATE_ITEM")
	this:RegisterEvent("TRADING_UPDATE_MONEY")
	this:RegisterEvent("TRADING_CLOSE")
	this:RegisterEvent("BAG_ITEM_UPDATE")
	
	-----添加对方面板----
	local handle = this:Lookup("", "")
	handle:AppendItemFromIni("UI/Config/Default/TradePanel.ini", "Handle_Self", "Handle_Other")
	local handleOther = handle:Lookup("Handle_Other")
	handleOther:SetRelPos(7, 73)
	handle:FormatAllItemPos()
	
--	TradePanel.UpdataOther(this)	
	TradePanel.UpdataTradeOtherMoney(this, 0)
	TradePanel.UpdataTradeSelfMoney(this, 0)
	TradePanel.UpdataBtnSureState(this, false)	
	
	local player = GetPlayer(TradePanel.dwID)
	handle:Lookup("Text_Title"):SetText(FormatString(g_tStrings.STR_TRADING_WITH_SOME_ONE, player.szName))
	
	InitFrameAutoPosInfo(this, 2, "Dialog", nil, function() CloseTradePanel(true) end)  
end

function TradePanel.UpdateItemLock(handle)
	RemoveUILockItem("trade")
	if handle then
		for i = 0, 10, 1 do
			local box = handle:Lookup("Box_"..i)
			if box and not box:IsEmpty() then
				local _, dwBox, dwX = box:GetObjectData()
				AddUILockItem("trade", dwBox, dwX)				
			end
		end
	end
end

function TradePanel.OnFrameBreathe()
	local clientPlayer = GetClientPlayer()
	
	if not clientPlayer then
		CloseTradePanel()
		return
	end
	
	if clientPlayer.nMoveState == MOVE_STATE.ON_DEATH  then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tTradingResultString[TRADING_RESPOND_CODE.YOU_DEAD])
		CloseTradePanel()
		return
	end
	
	if IsEnemy(clientPlayer.dwID, TradePanel.dwID) then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_TRADING_ENEMY)
		CloseTradePanel()
		return
	end
	
	local player = GetPlayer(TradePanel.dwID)
	if not player or player.nMoveState == MOVE_STATE.ON_DEATH or not player.CanDialog(clientPlayer) then
		if player and player.nMoveState == MOVE_STATE.ON_DEATH then
			OutputMessage("MSG_SYS", g_tStrings.STR_TRADING_CANCEL)
		else
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_TRADING_CANCEL_REASON_TOO_FAR)
		end
		CloseTradePanel()
	end
	
	TradePanel.OnCheckTradeWarningEnd(this)
end

function TradePanel.OnEvent(event)
	if event == "TRADING_UPDATE_CONFIRM" then
		local dwID, bConfirm = arg0, arg1
		if dwID == TradePanel.dwID then
			TradePanel.UpdataOtherState(this, bConfirm)
		elseif dwID == GetClientPlayer().dwID then
			TradePanel.UpdataSelfState(this, bConfirm)
		end
	elseif event == "TRADING_UPDATE_ITEM" then
		local dwID, dwBoxIndex, dwPosIndex, dwGridIndex = arg0, arg1, arg2, arg3
		if dwID == GetClientPlayer().dwID then
			TradePanel.UpdataSelfItem(this, dwBoxIndex, dwPosIndex, dwGridIndex)
		elseif dwID == TradePanel.dwID then
			TradePanel.UpdataOtherItem(this, dwBoxIndex, dwPosIndex, dwGridIndex)
		end
	elseif event == "TRADING_UPDATE_MONEY" then
		local dwID, nMoney = arg0, arg1
		if dwID == TradePanel.dwID then
			TradePanel.UpdataTradeOtherMoney(this, nMoney)
		elseif dwID == GetClientPlayer().dwID then
--			TradePanel.UpdataTradeSelfMoney(this, nMoney)
		end
	elseif event == "TRADING_CLOSE"	then
		CloseTradePanel(nil, true)
	elseif event == "BAG_ITEM_UPDATE" then
		local player = GetClientPlayer()
		local handle = this:Lookup("", "Handle_Self")
		for i = 0, 6, 1 do
			local box = handle:Lookup("Box_"..i)
			if not box:IsEmpty() and box.dwBoxID == arg0 and box.dwX == arg1 then
				TradingDeleteItem(box:GetBoxIndex())
			end
		end
	end
end

function TradePanel.UpdataTradeOtherMoney(frame, nMoney)
	local handle = frame:Lookup("", "Handle_Other")
	local nGold, nSilver, nCopper = MoneyToGoldSilverAndCopper(nMoney)
	handle:Lookup("Text_Gold"):SetText(nGold)
	handle:Lookup("Text_Silver"):SetText(nSilver)
	handle:Lookup("Text_Copper"):SetText(nCopper)
end

function TradePanel.UpdataTradeSelfMoney(frame, nMoney)
	frame.bChangeEdit = true
	local nGold, nSilver, nCopper = MoneyToGoldSilverAndCopper(nMoney)
	frame:Lookup("Edit_Gold"):SetText(nGold)
	frame:Lookup("Edit_Silver"):SetText(nSilver)
	frame:Lookup("Edit_Copper"):SetText(nCopper)
	frame.bChangeEdit = false
end

function TradePanel.UpdataSelfItem(frame, dwBoxIndex, dwPosIndex, dwGridIndex)
	local handle = frame:Lookup("", "Handle_Self")
	local box = handle:Lookup("Box_"..dwGridIndex)
	local text = handle:Lookup("Text_"..dwGridIndex)
	if not box or not text then
		return
	end

	local player = GetClientPlayer()
	local item = player.GetTradingItem(dwGridIndex)
	if dwBoxIndex == INVENTORY_INDEX.INVALID or not item then
		box:ClearObject()
		box:SetOverText(0, "")
		box.dwBoxID, box.dwX = nil, nil
		if box:IsObjectMouseOver() then
			HideTip()
		end
		text:SetText("")
	else
		box:SetObject(UI_OBJECT_ITEM, item.nUiId, dwBoxIndex, dwPosIndex, item.nVersion, item.dwTabType, item.dwIndex)			
		box:SetObjectIcon(Table_GetItemIconID(item.nUiId))
		UpdateItemBoxExtend(box, item)
		box:SetOverTextPosition(0, ITEM_POSITION.RIGHT_BOTTOM)
		box:SetOverTextFontScheme(0, 15)
		if item.bCanStack and item.nStackNum > 1 then
			box:SetOverText(0, item.nStackNum)
		else
			box:SetOverText(0, "")
		end
		if box:IsObjectMouseOver() then
			local x, y = box:GetAbsPos()
			local w, h = box:GetSize()
			OutputItemTip(UI_OBJECT_ITEM, dwBoxIndex, dwPosIndex, nil, {x, y, w, h})
		end
		
		text:SetFontColor(GetItemFontColorByQuality(item.nQuality, false))		
		text:SetText(GetItemNameByItem(item))
		
		box.dwBoxID, box.dwX = dwBoxIndex, dwPosIndex
	end
	TradePanel.UpdateItemLock(handle)
end

function TradePanel.UpdataSelfState(frame, bConfirm)
	local handle = frame:Lookup("", "Handle_Self")	
	if bConfirm then
		handle:Lookup("Image_Lock0"):Show()
		handle:Lookup("Image_Lock1"):Show()
		TradePanel.UpdataBtnSureState(frame, bConfirm)
	else
		handle:Lookup("Image_Lock0"):Hide()
		handle:Lookup("Image_Lock1"):Hide()
		TradePanel.UpdataBtnSureState(frame, bConfirm)
	end
	
end

function TradePanel.UpdataBtnSureState(frame, bConfirm)
	local btn = frame:Lookup("Btn_Sure")
	if not bConfirm then
		btn:Enable(1)
	else
		btn:Enable(0)
	end
end

function TradePanel.UpdataOtherItem(frame, dwBoxIndex, dwPosIndex, dwGridIndex)
	local handle = frame:Lookup("", "Handle_Other")
	local box = handle:Lookup("Box_"..dwGridIndex)
	local text = handle:Lookup("Text_"..dwGridIndex)
	local hAnimate = handle:Lookup("Animate_Box_" .. dwGridIndex)
	local hChangeImage = handle:Lookup("Image_BoxFlag_" .. dwGridIndex)
	local hTextWarning = frame:Lookup("", "Text_Warning")
	if not box or not text then
		return
	end

	local player = GetPlayer(TradePanel.dwID)
	local item = player.GetTradingItem(dwGridIndex)
	if dwBoxIndex == INVENTORY_INDEX.INVALID or not item then
		box:ClearObject()
		box:SetOverText(0, "")
		box.dwBoxID, box.dwX = nil, nil
		if box:IsObjectMouseOver() then
			HideTip()
		end
		text:SetText("")
	else
		box:SetObject(UI_OBJECT_ITEM_ONLY_ID, item.nUiId, item.dwID, item.nVersion, item.dwTabType, item.dwIndex)	
		box:SetObjectIcon(Table_GetItemIconID(item.nUiId))
		UpdateItemBoxExtend(box, item)
		box:SetOverTextPosition(0, ITEM_POSITION.RIGHT_BOTTOM)
		box:SetOverTextFontScheme(0, 15)
		if item.nGenre == ITEM_GENRE.EQUIPMENT then
			if item.nSub == EQUIPMENT_SUB.ARROW and item.nCurrentDurability > 1 then
				box:SetOverText(0, item.nCurrentDurability)
			else
				box:SetOverText(0, "")
			end
		else
			if item.bCanStack and item.nMaxStackNum > 1 then
				box:SetOverText(0, item.nStackNum)
			else
				box:SetOverText(0, "")
			end
		end
		if box:IsObjectMouseOver() then
			local x, y = box:GetAbsPos()
			local w, h = box:GetSize()
			OutputItemTip(UI_OBJECT_ITEM_ONLY_ID, item.dwID, nil, nil, {x, y, w, h})
		end
		
		text:SetFontColor(GetItemFontColorByQuality(item.nQuality, false))
		text:SetText(GetItemNameByItem(item))
		
		box.dwBoxID, box.dwX = dwBoxIndex, dwPosIndex
		if not box.nChangeCount then
			box.nChangeCount = 0
		else
			box.nChangeCount = box.nChangeCount + 1
		end
		
		if box.nChangeCount > 0 then
			hChangeImage:Show()
			hTextWarning:Show()
			hAnimate:Show()
			hAnimate.nStartWarningTime = GetTickCount()
			local hBtnSure = frame:Lookup("Btn_Sure")
			hBtnSure.nStartWarningTime = GetTickCount()
			hBtnSure:Enable(false)
		end
	end
end

function TradePanel.OnCheckTradeWarningEnd(hFrame)
	local hBoxHandle = hFrame:Lookup("", "Handle_Other")
	if not hBoxHandle then
		return
	end
	local nTime = GetTickCount()
	for i = 0, TRADE_PANEL_BOX_COUNT - 1 do
		local hAnimate = hBoxHandle:Lookup("Animate_Box_" .. i)
		if hAnimate.nStartWarningTime and nTime - hAnimate.nStartWarningTime > TRADE_PANEL_WARNING_TIME then
			hAnimate:Hide()
			hAnimate.nStartWarningTime = nil
		end
	end
	local hBtnSure = hFrame:Lookup("Btn_Sure")
	if hBtnSure.nStartWarningTime and nTime - hBtnSure.nStartWarningTime > TRADE_PANEL_WARNING_TIME then
		hBtnSure:Enable(true)
		hBtnSure.nStartWarningTime = nil
	end
end

function TradePanel.UpdataOtherState(frame, bConfirm)
	local handle = frame:Lookup("", "Handle_Other")	
	
	if bConfirm then
		handle:Lookup("Image_Lock0"):Show()
		handle:Lookup("Image_Lock1"):Show()
	else
		handle:Lookup("Image_Lock0"):Hide()
		handle:Lookup("Image_Lock1"):Hide()
	end	
end

function TradePanel.OnItemLButtonDown()
	this.bIgnoreClick = false
	if this:GetType() == "Box" then
		if IsCtrlKeyDown() then
			local player = nil
			if this:GetParent():GetName() == "Handle_Self" then
				player = GetClientPlayer()
			else
				player = GetPlayer(TradePanel.dwID)
			end
			local item = player.GetTradingItem(this:GetBoxIndex())					
			if item then
				if IsGMPanelReceiveItem() then
					GMPanel_LinkItem(item.dwID)
				else		
					EditBox_AppendLinkItem(item.dwID)
				end
			end
			this.bIgnoreClick = true
		elseif this:GetParent():GetName() == "Handle_Self" then
			this:SetObjectPressed(1)			
		end
	end
end

function TradePanel.OnItemLButtonUp()
	if this:GetType() == "Box" and this:GetParent():GetName() == "Handle_Self" then
		this:SetObjectPressed(0)
	end
end

function TradePanel.OnItemLButtonDrag()
	if this:GetType() == "Box" and this:GetParent():GetName() == "Handle_Self" then
		if Hand_IsEmpty() then
			if not this:IsEmpty() then
				if IsCursorInExclusiveMode() then
					OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.SRT_ERROR_CANCEL_CURSOR_STATE)
					PlayTipSound("010")
				else			
					Hand_Pick(this)
					local player = GetClientPlayer()
					TradingDeleteItem(this:GetBoxIndex())
				end
			end
		end
	end
end

function TradePanel.OnItemLButtonDragEnd()
	this.bIgnoreClick = true
	if not Hand_IsEmpty() then
		local boxHand, nHandCount = Hand_Get()
		local dwHandType = boxHand:GetObjectType()
		if dwHandType ~= UI_OBJECT_ITEM then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.TRADE_ONLY_FROM_BAG)
			return
		end
		
		local _, dwBox, dwX = boxHand:GetObjectData()
		if not IsObjectFromBag(dwBox) then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.TRADE_ONLY_FROM_BAG)
			return
		end
		
		if nHandCount then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_SHOP_ONLY_TRADE_GLOUP)
			return
		end
		
		local player = GetClientPlayer()
		local item = GetPlayerItem(player, dwBox, dwX)
		if not item then
			return
		end
		if IsBagInSort() or IsBankInSort() then
			OutputMessage("MSG_SYS", g_tStrings.STR_CANNOT_TRADE_ITEM_INSORT)
			return
		end		
		if this:GetType() == "Box" then
			if this:IsEmpty() then
				TradingAddItem(dwBox, dwX, this:GetBoxIndex())
				Hand_Clear()
			else
				Hand_Pick(this)
				TradingDeleteItem(this:GetBoxIndex())
				TradingAddItem(dwBox, dwX, this:GetBoxIndex())
			end
		else
			if this:GetName() == "Handle_Self" then
				local bDo = false
				for i = 0, 6, 1 do
					local box = this:Lookup("Box_"..i)
					if box:IsEmpty() then
						TradingAddItem(dwBox, dwX, i)
						Hand_Clear()
						bDo = true
						break
					end
				end
				if not bDo then
					OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.TRADE_ITEM_FULL)
				end
			end
		end
	end
end

function TradePanel.OnItemLButtonClick()
	if this.bIgnoreClick then
		this.bIgnoreClick = false
		return
	end
	
	if Hand_IsEmpty() then
		if this:GetType() == "Box" and not this:IsEmpty() and this:GetParent():GetName() == "Handle_Self" then
			if IsCursorInExclusiveMode() then
				OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.SRT_ERROR_CANCEL_CURSOR_STATE)
				PlayTipSound("010")
			else		
				local player = GetClientPlayer()
				TradingDeleteItem(this:GetBoxIndex())
				Hand_Pick(this)
			end
		end
	else
		local boxHand, nHandCount = Hand_Get()		
		local dwHandType = boxHand:GetObjectType()
		if dwHandType ~= UI_OBJECT_ITEM then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.TRADE_ONLY_FROM_BAG)
			return		
		end
		local _, dwBox, dwX = boxHand:GetObjectData()
		if not IsObjectFromBag(dwBox) then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.TRADE_ONLY_FROM_BAG)
			return
		end
		
		if nHandCount then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_SHOP_ONLY_TRADE_GLOUP)
			return
		end
		
		local player = GetClientPlayer()
		local item = GetPlayerItem(player, dwBox, dwX)
		if not item then
			return
		end
		
		if this:GetType() == "Box" then
			if this:IsEmpty() then
				TradingAddItem(dwBox, dwX, this:GetBoxIndex())
				Hand_Clear()
			else
				Hand_Pick(this)
				TradingDeleteItem(this:GetBoxIndex())
				TradingAddItem(dwBox, dwX, this:GetBoxIndex())
			end	
		else
			if this:GetName() == "Handle_Self" then
				local bDo = false
				for i = 0, 6, 1 do
					local box = this:Lookup("Box_"..i)
					if box:IsEmpty() then
						TradingAddItem(dwBox, dwX, i)
						Hand_Clear()
						bDo = true
						break
					end
				end
				if not bDo then
					OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.TRADE_ITEM_FULL)
				end
			end
		end
	end
end

function TradePanel.OnItemRButtonDown()
	if this:GetType() == "Box" and this:GetParent():GetName() == "Handle_Self" then
		this:SetObjectPressed(true)
	end
end

function TradePanel.OnItemRButtonUp()
	if this:GetType() == "Box" and this:GetParent():GetName() == "Handle_Self" then
		this:SetObjectPressed(false)
	end
end

function TradePanel.OnItemRButtonClick()
	if this:GetType() == "Box" and this:GetParent():GetName() == "Handle_Self" then
		local player = GetClientPlayer()
		TradingDeleteItem(this:GetBoxIndex())		
	end
end

function TradePanel.OnItemMouseEnter()
	if this:GetType() ~= "Box" then
		return
	end	
	if this:IsEmpty() then
		if this:GetParent():GetName() == "Handle_Self" then
			this:SetObjectMouseOver(1)
		end
		return
	end
	
	this:SetObjectMouseOver(1)
	local player = nil
	if this:GetParent():GetName() == "Handle_Self" then
		player = GetClientPlayer()
	else
		player = GetPlayer(TradePanel.dwID)
	end
	local item = player.GetTradingItem(this:GetBoxIndex())
			
	if item then
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
		OutputItemTip(UI_OBJECT_ITEM_ONLY_ID, item.dwID, nil, nil, {x, y, w, h})
	end
end

function TradePanel.OnItemRefreshTip()
	return TradePanel.OnItemMouseEnter()
end

function TradePanel.OnItemMouseLeave()
	HideTip()
	if this:GetType() == "Box" then
		this:SetObjectMouseOver(0)
	end
end

function TradePanel.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_Close" then
		TradingConfirm(false)
	elseif szName == "Btn_Cancle" then
		TradingConfirm(false)
	elseif szName == "Btn_Sure" then
		if IsBagInSort() or IsBankInSort() then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_CANNOT_TRADE_ITEM_INSORT)
			return
		end		

		TradingConfirm(true)
	end
end

function TradePanel.OnKillFocus()
	local szName = this:GetName()
	if szName == "Edit_Gold" or szName == "Edit_Silver" or szName == "Edit_Copper" then
		this:CancelSelect()
	end
end

function TradePanel.OnSetFocus()
	local szName = this:GetName()
	if szName == "Edit_Gold" or szName == "Edit_Silver" or szName == "Edit_Copper" then
		this:SelectAll()
	end
end

function TradePanel.OnEditChanged()
	local father = this:GetParent()
	if father.bChangeEdit then
		return
	end
	father.bChangeEdit = true

	local nGold = father:Lookup("Edit_Gold"):GetText()
	if nGold and nGold ~= "" then
		nGold = tonumber(nGold)
	else
		nGold = 0
	end
	local nSilver = father:Lookup("Edit_Silver"):GetText()
	if nSilver and nSilver ~= "" then
		nSilver = tonumber(nSilver)
	else
		nSilver = 0
	end	
	local nCopper = father:Lookup("Edit_Copper"):GetText()
	if nCopper and nCopper ~= "" then
		nCopper = tonumber(nCopper)
	else
		nCopper = 0
	end	
	
	local player = GetClientPlayer()
	local nMoney = GoldSilverAndCopperToMoney(nGold, nSilver, nCopper)
	local nMoneyHave = player.GetMoney()
	local nGoldHave, nSilverHave, nCopperHave = MoneyToGoldSilverAndCopper(nMoneyHave)
	
	local bOver = TradePanel.CheckMoneyOver(nGold, nSilver, nCopper, nGoldHave, nSilverHave, nCopperHave)
	if bOver then
		nMoney = nMoneyHave
		father:Lookup("Edit_Gold"):SetText(nGoldHave)
		father:Lookup("Edit_Silver"):SetText(nSilverHave)
		father:Lookup("Edit_Copper"):SetText(nCopperHave)
	end
	
	TradingSetMoney(nMoney)
	
	father.bChangeEdit = false
end

function TradePanel.CheckMoneyOver(nGold, nSilver, nCopper, nGoldHave, nSilverHave, nCopperHave)
	if nGold == nGoldHave then
		if nSilver == nSilverHave then
			return nCopper > nCopperHave
		else
			return nSilver > nSilverHave
		end
	else 
		return nGold > nGoldHave
	end
end

function OpenTradePanel(dwID)
	if CheckHaveLocked(SAFE_LOCK_EFFECT_TYPE.TRADE) then
		TradingConfirm(false)
		return
	end
	
	local player = GetClientPlayer()
	if not player or player.nMoveState == MOVE_STATE.ON_DEATH then
		return
	end

	TradePanel.dwID = dwID
	if not IsTradePanelOpened() then
		OpenAllBagPanel(true)
		Wnd.OpenWindow("TradePanel")
	end
	TradePanel.UpdateItemLock()
	hBtnSure = Station.Lookup("Normal/TradePanel/Btn_Sure")
	FireHelpEvent("OnOpenpanel", "TRADE", hBtnSure)
	PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
end

function CloseTradePanel(bDisableSound, bNotConfirm)
	if not IsTradePanelOpened() then
		return
	end
	
	if not bNotConfirm then
		TradingConfirm(false)
	end
	TradePanel.UpdateItemLock()
	if IsTradePanelOpened() then
		CloseAllBagPanel(true)	
	end
	Wnd.CloseWindow("TradePanel")
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end
	
end

function IsTradePanelOpened()
	if IsOptionOrOptionChildPanelOpened() then
		return
	end

	local frame = Station.Lookup("Normal/TradePanel")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end

function IsItemInTradePanel(dwBoxID, dwX)
	local frame = Station.Lookup("Normal/TradePanel")
	if frame and frame:IsVisible() then
		local handle = frame:Lookup("", "Handle_Self")
		for i = 0, 6, 1 do
			local box = handle:Lookup("Box_"..i)
			if not box:IsEmpty() and box.dwBoxID == dwBoxID and box.dwX == dwX then
				return true
			end
		end
	end
	return false
end

function AppendTradingItem(dwBoxID, dwX)
	local player = GetClientPlayer()
	local item = GetPlayerItem(player, dwBoxID, dwX)
	if not item then
		return
	end
	if IsBagInSort() or IsBankInSort() then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_CANNOT_TRADE_ITEM_INSORT)
		return
	end		
	local frame = Station.Lookup("Normal/TradePanel")
	if frame and frame:IsVisible() then
		local handle = frame:Lookup("", "Handle_Self")
		
		local bDo = false
		for i = 0, 6, 1 do
			if handle:Lookup("Box_"..i):IsEmpty() then
				TradingAddItem(dwBoxID, dwX, i)
				bDo = true
				break
			end
		end
		if not bDo then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.TRADE_ITEM_FULL)
		end
	end
end