GuildBankPanel =
{
	nPageCount = 1,
}

function GuildBankPanel.OnFrameCreate()
	local handle = this:Lookup("", "")
	local hBg = handle:Lookup("Handle_Bg")
	local hBox = handle:Lookup("Handle_Box")
	hBg:Clear()
	hBox:Clear()
	local nIndex = 0
	for i = 1, 7, 1 do
		for j = 1, 14, 1 do
			hBg:AppendItemFromString("<image>w=52 h=52 path=\"ui/Image/LootPanel/LootPanel.UITex\" frame=13 </image>")
			local img = hBg:Lookup(nIndex)
			hBox:AppendItemFromString("<box>w=48 h=48 eventid=524607 </box>")
			local box = hBox:Lookup(nIndex)
			box.nIndex = nIndex
			box.bItemBox = true
			local x, y = (j - 1) * 52, (i - 1) * 52
			img:SetRelPos(x, y)
			box:SetRelPos(x + 2, y + 2)
			box:SetOverTextPosition(0, ITEM_POSITION.RIGHT_BOTTOM)
			box:SetOverTextFontScheme(0, 15)

			nIndex = nIndex + 1
		end
	end
	hBg:FormatAllItemPos()
	hBox:FormatAllItemPos()

	for i = 1, 10, 1 do
		this:Lookup("CheckBox_"..i).nPage = i - 1
	end
	this:Lookup("CheckBox_1"):Check(true)

	this:Lookup("CheckBox_10"):Hide()

	this:RegisterEvent("UPDATE_TONG_REPERTORY_PAGE")
	this:RegisterEvent("UPDATE_TONG_INFO")
	this:RegisterEvent("TONG_EVENT_NOTIFY")
	this:RegisterEvent("OPEN_TONG_REPERTORY")

	InitFrameAutoPosInfo(this, 2, "Dialog", nil, function() CloseGuildBankPanel(true) end)
end

function GuildBankPanel.OnFrameBreathe()
	local player = GetClientPlayer()
	if not player or player.nMoveState == MOVE_STATE.ON_DEATH then
		CloseGuildBankPanel()
		return
	end

	if GuildBankPanel.dwType then
	    if GuildBankPanel.dwType == TARGET.NPC then
			local npc = GetNpc(GuildBankPanel.dwID)
			if not npc or not npc.CanDialog(player) then
				CloseGuildBankPanel()
			end
	    elseif GuildBankPanel.dwType == TARGET.DOODAD then
			local doodad = GetDoodad(GuildBankPanel.dwID)
			if not doodad or not doodad.CanDialog(player) then
				CloseGuildBankPanel()
			end
	    end
	end
end

function GuildBankPanel.OnEvent(event)
	if event == "UPDATE_TONG_REPERTORY_PAGE" then
		local nPage = arg0

		if nPage == this.nPage then
			GuildBankPanel.Update(this)
		end
	elseif event == "UPDATE_TONG_INFO" then
		GuildBankPanel.UpdateTitle(this)
	elseif event == "TONG_EVENT_NOTIFY" then
		local guild = GetTongClient()
		if arg0 == TONG_EVENT_CODE.REPERTORY_GRID_FILLED_ERROR then
			GetTongClient().ApplyRepertoryPage(this.nPage)
		elseif arg0 == TONG_EVENT_CODE.PUT_ITEM_IN_REPERTORY_SUCCESS or
			arg0 == TONG_EVENT_CODE.TAKE_ITEM_FROM_REPERTORY_SUCCESS or
			arg0 == TONG_EVENT_CODE.EXCHANGE_REPERTORY_ITEM_SUCCESS or
			arg0 == TONG_EVENT_CODE.STACK_ITEM_TO_REPERTORY_FAIL_ERROR or
			arg0 == TONG_EVENT_CODE.ITEM_NOT_IN_REPERTORY_ERROR or
			arg0 == TONG_EVENT_CODE.REPERTORY_TARGET_ITEM_CHANGE_ERROR or
			arg0 == TONG_EVENT_CODE.REPERTORY_PAGE_FULL_ERROR or
            arg0 == TONG_EVENT_CODE.STACK_ITEM_IN_REPERTORY_FAILERROR then
				GetTongClient().ApplyRepertoryPage(arg1)
		end
	elseif event == "OPEN_TONG_REPERTORY" then
		this:Lookup("", "Text_Title"):SetText(arg0)
		GuildBankPanel.nPageCount = arg1
		this.nPage = this.nPage or 0
		if this.nPage >= GuildBankPanel.nPageCount then
			this.nPage = 0
		end
		GetTongClient().ApplyRepertoryPage(nPage)
		GuildBankPanel.UpdatePageCount(this)
	end
end

function GuildBankPanel.UpdatePageCount(frame)
	for i = 1, GuildBankPanel.nPageCount, 1 do
		local c = frame:Lookup("CheckBox_"..i)
		c:Enable(true)
		c:Lookup("", "Text_"..i):SetFontScheme(162)
	end

	for i = GuildBankPanel.nPageCount + 1, 10, 1 do
		local c = frame:Lookup("CheckBox_"..i)
		c:Enable(false)
		c:Lookup("", "Text_"..i):SetFontScheme(161)
	end

	if not frame.nPage or frame.nPage >= GuildBankPanel.nPageCount then
		frame:Lookup("CheckBox_1"):Check(true)
	else
		frame:Lookup("CheckBox_"..(frame.nPage + 1)):Check(true)
	end
	GuildBankPanel.Update(frame)
end

function GuildBankPanel.UpdateItem(box)
	local frame = box:GetRoot()
	local dwBox, dwX = GetGuildBankBagPos(frame.nPage, box.nIndex)
	local item = GetPlayerItem(GetClientPlayer(), dwBox, dwX)
	UpdataItemBoxObject(box, dwBox, dwX, item)
	if box:IsObjectMouseOver() then
		local thisSave = this
		this = box
		GuildBankPanel.OnItemMouseEnter()
		this = thisSave
	end
end

function GuildBankPanel.OnCheckBoxCheck()
	local frame = this:GetParent()

	local c = frame:GetFirstChild()
	while c do
		if c.nPage then
			c:Check(c == this)
		end
		c = c:GetNext()
	end

	frame.nPage = this.nPage
	GetTongClient().ApplyRepertoryPage(frame.nPage)
	GuildBankPanel.Update(frame)
end

function GuildBankPanel.Update(frame)
	local hBox = frame:Lookup("", "Handle_Box")
	local nCount = hBox:GetItemCount() - 1
	for i = 0, nCount, 1 do
		local box = hBox:Lookup(i)
		GuildBankPanel.UpdateItem(box)
	end
	RefreshUILockItem()
end

function GuildBankPanel.OnItemLButtonDown()
	if this.bItemBox then
		this.bIgnoreClick = nil
		if IsCtrlKeyDown() and not this:IsEmpty() and this.dwBox and this.dwX then
			if IsGMPanelReceiveItem() then
				GMPanel_LinkItem(this.dwBox, this.dwX)
			else
				EditBox_AppendLinkItem(this.dwBox, this.dwX)
			end
			this.bIgnoreClick = true
		end
		this:SetObjectStaring(false)
		this:SetObjectPressed(1)
	end
end

function GuildBankPanel.OnItemLButtonUp()
	if this.bItemBox then
		this:SetObjectPressed(0)
	end
end

function GuildBankPanel.OnItemLButtonDrag()
	if not this.bItemBox then
		return
	end

	this:SetObjectPressed(0)

	if not this:IsObjectEnable() or this:IsEmpty() then
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

function GuildBankPanel.OnItemLButtonDragEnd()
	if not this.bItemBox then
		return
	end

	this.bIgnoreClick = true

	if this.bBag then
		if not Hand_IsEmpty() then
			GuildBankPanel.DropHandObjectToBag(this)
			return
		end
	end

	if not this:IsObjectEnable() then
		if not Hand_IsEmpty() and not this:IsEmpty() then
			local box = Hand_Get()
			local dwType, _, dwBox, dwX = box:GetObject()
			local dwTType, _, dwTBox, dwTX = this:GetObject()
			if dwType == dwTType and dwBox == dwTBox and dwX == dwTX then
				Hand_Clear()
			end
		end
		return
	end

	if not Hand_IsEmpty() then
		GuildBankPanel.OnExchangeBoxAndHandBoxItem(this)
	end
end

function GuildBankPanel.DropHandObjectToBag(box)
	local boxHand, nHandCount = Hand_Get()
	local nSourceType = boxHand:GetObjectType()
	if nSourceType == UI_OBJECT_SKILL then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_ERROR_CANNOT_DRAG_SKILL_IN_BAG)
		PlayTipSound("001")
		return
	elseif nSourceType == UI_OBJECT_CRAFT then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_ERROR_CANNOT_DRAG_CRAFT_IN_BAG)
		PlayTipSound("001")
		return
	elseif nSourceType ~= UI_OBJECT_ITEM then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_ERROR_CANNOT_DRAG_ITEM_IN_BAG)
		PlayTipSound("001")
		return
	end

	local _, dwBox1, dwX1 = boxHand:GetObjectData()
	local dwBox2, dwX2 = GetGuildBankBagPos(box:GetRoot().nPage, box.nIndex)
	if OnExchangeItem(dwBox1, dwX1, dwBox2, dwX2, nHandCount) then
		Hand_Clear()
	end
end

function GuildBankPanel.OnItemLButtonClick()
	if not this.bItemBox then
		return
	end

	if this.bIgnoreClick then
		this.bIgnoreClick = nil
		return
	end

	if not this:IsObjectEnable() then
		if not Hand_IsEmpty() and not this:IsEmpty() then
			local box = Hand_Get()
			local dwType, _, dwBox, dwX = box:GetObject()
			local dwTType, _, dwTBox, dwTX = this:GetObject()
			if dwType == dwTType and dwBox == dwTBox and dwX == dwTX then
				Hand_Clear()
			end
		end
		return
	end

	if (IsShiftKeyDown() and not IsCursorInExclusiveMode())	or Cursor.GetCurrentIndex() == CURSOR.SPLIT then
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
	else
		GuildBankPanel.OnExchangeBoxAndHandBoxItem(this)
	end
end

function GuildBankPanel.OnItemLButtonDBClick()
	GuildBankPanel.OnItemLButtonClick()
end

-------ÓÒ¼ü²Ù×÷-------
function GuildBankPanel.OnItemRButtonDown()
	if this.bBag then
		GuildBankPanel.OnItemLButtonDown()
		return
	end
	this:SetObjectPressed(1)
	this:SetObjectStaring(false)
end

function GuildBankPanel.OnItemRButtonUp()
	if this.bBag then
		GuildBankPanel.OnItemLButtonUp()
		return
	end
	this:SetObjectPressed(0)
end

function GuildBankPanel.OnItemRButtonClick()
	if not this.bItemBox then
		return
	end
	if this:IsEmpty() then
		return
	end

	if not this:IsObjectEnable() then
		return
	end

	local TongClient = GetTongClient()
	local nPage = this:GetRoot().nPage
	if CheckHaveLocked(SAFE_LOCK_EFFECT_TYPE.TONG_REPERTORY) then
		return
	end
			
	local CheckResult = TongClient.TakeRepertoryItem(nPage, this.nIndex)
    
    if CheckResult == ADD_ITEM_RESULT_CODE.NOT_ENOUGH_FREE_ROOM then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.GUILD_BANK_ERROR_BAG_IS_FULL)
		return
	end
end

function GuildBankPanel.OnExchangeBoxAndHandBoxItem(box)
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
	elseif nSourceType ~= UI_OBJECT_ITEM then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_ERROR_CANNOT_DRAG_ITEM_IN_BAGPANEL)
		PlayTipSound("001")
		return
	end

	local _, dwBox1, dwX1 = boxHand:GetObjectData()
	local dwBox2, dwX2 = GetGuildBankBagPos(box:GetRoot().nPage, box.nIndex)
	if OnExchangeItem(dwBox1, dwX1, dwBox2, dwX2, nHandCount) then
		Hand_Clear()
	end
end

function GuildBankPanel.OnItemMouseEnter()
	if not this.bItemBox then
		return
	end
	this:SetObjectMouseOver(1)

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
			Cursor.Switch(CURSOR.UNABLEREPAIRE)
		end

		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
		OutputItemTip(UI_OBJECT_ITEM, dwBox, dwX, nil, {x, y, w, h})
	end
end

function GuildBankPanel.OnItemRefreshTip()
	GuildBankPanel.OnItemMouseEnter()
end

function GuildBankPanel.OnItemMouseLeave()
	if not this.bItemBox then
		return
	end

	this:SetObjectMouseOver(0)
	HideTip()

	if Cursor.GetCurrentIndex() == CURSOR.UNABLESPLIT then
		Cursor.Switch(CURSOR.SPLIT)
	elseif Cursor.GetCurrentIndex() == CURSOR.UNABLEREPAIRE then
		Cursor.Switch(CURSOR.REPAIRE)
	elseif not IsCursorInExclusiveMode() then
		Cursor.Switch(CURSOR.NORMAL)
	end
end

function GuildBankPanel.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_Close" then
		CloseGuildBankPanel()
	elseif szName == "Btn_Refresh" then
		--GetTongClient().ApplyOpenRepertory(GuildBankPanel.dwID)
		GetTongClient().ApplyRepertoryPage(this:GetRoot().nPage or 0)
		PlaySound(SOUND.UI_SOUND,g_sound.Button)
	end
end

function OpenGuildBankPanel(dwTargetType, dwTargetId, bDisableSound)
	GuildBankPanel.dwType, GuildBankPanel.dwID = dwTargetType, dwTargetId

	local player = GetClientPlayer()
	if not player or not player.dwTongID or player.dwTongID == 0 then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_GUILD_NOT_ACTIVE)
		return
	end

	if IsGuildBankPanelOpened() then
		return
	end

	local frame = Wnd.OpenWindow("GuildBankPanel")

	GetTongClient().ApplyOpenRepertory(dwTargetId)

	OpenAllBagPanel(true);

	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
end

function IsGuildBankPanelOpened()
	local frame = Station.Lookup("Normal/GuildBankPanel")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end

function CloseGuildBankPanel(bDisableSound)
	Station.CloseWindow("GuildBankPanel")
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end
end

function GuildBankPanel_GetItemBox(dwBox, dwX, bEvenUnVisible)
	if dwBox ~= INVENTORY_GUILD_BANK then
		return nil
	end
	local frame = Station.Lookup("Normal/GuildBankPanel")
	if not frame then
		return
	end
	if not bEvenUnVisible and not frame:IsVisible() then
		return
	end
	local nPage, nIndex = GetGuildBankPagePos(dwBox, dwX)
	if nPage ~= frame.nPage then
		return
	end
	return frame:Lookup("", "Handle_Box"):Lookup(nIndex)
end

function AddItemToGuildBank(dwBox, dwX)
	if not IsGuildBankPanelOpened() then
		return
	end

	local item = GetClientPlayer().GetItem(dwBox,dwX)
	if not item then
		return
	end

	if item.nGenre == ITEM_GENRE.TASK_ITEM then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.GUILD_BANK_CAN_NOT_PUT_TASK_ITME)
		return false
	end

	if item.bBind then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.GUILD_BANK_CAN_NOT_PUT_BIND_ITME)
		return false
	end

	local itemInfo = GetItemInfo(item.dwTabType, item.dwIndex)
	if itemInfo.nExistType ~= ITEM_EXIST_TYPE.PERMANENT then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.ERROR_GUILD_NOT_TIME_LIMIT)
		return false
	end

	local frame = Station.Lookup("Normal/GuildBankPanel")

	if not GetTongClient().FindRepertoryEmptyGrid(frame.nPage) then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.GUILD_BANK_ERROR_PAGE_FULL)
		return false
	end

	if CheckHaveLocked(SAFE_LOCK_EFFECT_TYPE.TONG_REPERTORY, "°ï»á²Ö¿â") then
		return
	end
			
	if frame then
		GetTongClient().PutItemToRepertory(dwBox, dwX, frame.nPage)
	end
end
