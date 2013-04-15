BigBankPanel = 
{
	nCount = 6,
	aOpen = {true, true, true, true, true, true},
	bCompact = false,
	nResetEndTime = 0,
}

RegisterCustomData("BigBankPanel.aOpen")
RegisterCustomData("BigBankPanel.bCompact")

function BigBankPanel.OnFrameCreate()
	this:RegisterEvent("BANK_ITEM_UPDATE")
	this:RegisterEvent("BAG_ITEM_UPDATE")
	this:RegisterEvent("EQUIP_ITEM_UPDATE")
	this:RegisterEvent("SYNC_ROLE_DATA_END")
	this:RegisterEvent("MONEY_UPDATE")
	this:RegisterEvent("UPDATE_BANK_SLOT")
	this:RegisterEvent("ON_SET_SHOW_BAG_SIZE")
	this:RegisterEvent("ON_SET_BANK_COMPACT_MODE")
	this:RegisterEvent("CUSTOM_DATA_LOADED")
	
	InitFrameAutoPosInfo(this, 1, "Dialog", nil, function() CloseBigBankPanel(true) end)
end

function BigBankPanel.BagIndexToInventoryIndex(nIndex)
	return INVENTORY_INDEX.BANK + nIndex - 1
end

function BigBankPanel.InventoryIndexToBagIndex(nIndex)
	return nIndex - INVENTORY_INDEX.BANK + 1
end

function BigBankPanel.GetLine(w)
	local nLine = 0
	local player = GetClientPlayer()
	for i = 1, BigBankPanel.nCount, 1 do
		local dwSize = player.GetBoxSize(BigBankPanel.BagIndexToInventoryIndex(i))
		nLine = nLine + math.ceil(dwSize / w)
	end
	return nLine
end

function BigBankPanel.GetSize()
	local dwSize = 0
	local player = GetClientPlayer()
	for i = 1, BigBankPanel.nCount, 1 do
		local dwSizeT = player.GetBoxSize(BigBankPanel.BagIndexToInventoryIndex(i))
		dwSize = dwSize + dwSizeT
	end
	return dwSize
end

function BigBankPanel.Update(frame)
	if BigBankPanel.bCompact then
		BigBankPanel.UpdateCompact(frame)
	else
		BigBankPanel.UpdateNormal(frame)
	end
	RefreshUILockItem()
	UserSelect.RefreshSelectedBox()	
end

function BigBankPanel.UpdateCompact(frame)
	frame.bDisable = true
	local player = GetClientPlayer()
	local aOpen = BigBankPanel.aOpen
	
	local wB, wS = 42, 1 --格子背景宽度，格子跟背景的缩进缩进
	local nW = 10	--一行拥有的格子数量
	local nSize = BigBankPanel.GetSize()
	local nLine = math.ceil(nSize / nW)
	if nLine > 12 then
		nW = math.ceil(nSize / 12)
	end
		
	local wBox = wB - 2 * wS --格子宽度
	local wAll = wB * nW
	if wAll < 313 then
		wAll = 313
	end
	
	local wBB = 42
	local nBagCount = player.GetBankPackageCount()
	local btnBuy = frame:Lookup("Btn_Buy")
	if nBagCount >= GLOBAL.MAX_BANK_PACKAGE_COUNT then
		btnBuy:Hide()
	else
		btnBuy:Show()
		btnBuy:SetSize(wBB, wBB)
		btnBuy:SetRelPos(13 + (nBagCount + 1) * wBB, 58)
	end
	local handle = frame:Lookup("", "")
	for i = 1, BigBankPanel.nCount, 1 do
		local img = handle:Lookup("Image_BagBox"..i)
		local box = handle:Lookup("Box_Bag"..i)
		
		local x = 13 + (i - 1) * wBB
		local y = 58
		img:SetSize(wBB + 2, wBB + 2)
		img:SetRelPos(x, y)
		box:SetSize(wBB - 2 * wS, wBB - 2 * wS)
		box:SetRelPos(x + wS, y + wS)
		
		box:SetOverTextPosition(0, ITEM_POSITION.RIGHT_BOTTOM)
		box:SetOverTextFontScheme(0, 15)
		box.bBag = true
		box.nBagIndex = i
		box.nInventoryIndex = BigBankPanel.BagIndexToInventoryIndex(i)
		if i ~= 1 then
			box.dwBox = INVENTORY_INDEX.EQUIP
			box.dwX = EQUIPMENT_INVENTORY.BANK_PACKAGE1 + i - 2
			if i <= nBagCount + 1 then
				box:Show()
				img:Show()
			else
				box:Hide()
				img:Hide()
			end
		end
		BigBankPanel.UpdateBag(box)
	end
	
	local hBg = handle:Lookup("Handle_BG")
	local hBox = handle:Lookup("Handle_Box")
	local bAdd = false
	local nIndex = 0
	local x, y = 16, 66 + wBB
	for i = 1, BigBankPanel.nCount, 1 do
		local dwBox = BigBankPanel.BagIndexToInventoryIndex(i)
		local dwSize = player.GetBoxSize(dwBox)
		
		local img = handle:Lookup("Image_Bg"..i)
		local imgB = handle:Lookup("Image_BgB"..i)
		local textB = handle:Lookup("Text_Bag"..i)
		local check = frame:Lookup("CheckBox_C"..i)
		img:SetSize(0,0)
		img:SetRelPos(0,0)
		img:Hide()
		imgB:SetSize(0,0)
		imgB:SetRelPos(0,0)
		imgB:Hide()
		textB:SetSize(0,0)
		textB:SetRelPos(0,0)
		textB:Hide()
		check:Hide()
		
		
		local aFrame = {29, 28, 13, 27}
		local nBT = GetBagContainType(dwBox)
		local nFrame = aFrame[nBT] or 13
		if not BigBankPanel.aOpen[i] then
			dwSize = 0
		end
		dwSize = dwSize - 1
		for dwX = 0, dwSize, 1 do
			local img = hBg:Lookup(nIndex)
			if not img then
				hBg:AppendItemFromString("<image>w=48 h=48 path=\"ui/Image/LootPanel/LootPanel.UITex\" frame=13 lockshowhide=1 </image>")
				img = hBg:Lookup(nIndex)
			end
			local box = hBox:Lookup(nIndex)
			if not box then
				hBox:AppendItemFromString("<box>w=44 h=44 eventid=524607 lockshowhide=1 </box>")
				box = hBox:Lookup(nIndex)
			end
			img:SetFrame(nFrame)
			img:Show()
			box:Show()
			box:SetName(dwBox.."_"..dwX)
			img:SetSize(wB, wB)
			img:SetRelPos(x, y)
			box:SetSize(wBox, wBox)
			box:SetRelPos(x + wS - 1, y + wS - 1)

			box:SetOverTextPosition(0, ITEM_POSITION.RIGHT_BOTTOM)
			box:SetOverTextFontScheme(0, 15)
			box.dwBox = dwBox
			box.dwX = dwX
			
			BigBankPanel.UpdateItem(box)
			
			if nIndex % nW == nW - 1 then
				x, y = 16, y + wB + 2
				bAdd = false
			else
				x = x + wB
				bAdd = true
			end
			
			nIndex = nIndex + 1
		end
	end
	
	if bAdd then
		x, y = 16, y + wB + 2
	end	
		
	hBox.nCount = nIndex
	local nCount = hBox:GetItemCount() - 1
	for i = nIndex, nCount, 1 do
		local img = hBg:Lookup(i)
		local box = hBox:Lookup(i)
		img:Hide()
		img:SetRelPos(0, 0)
		img:SetSize(0, 0)
		box:Hide()
		box:SetRelPos(0, 0)
		box:SetSize(0, 0)
	end
	hBg:FormatAllItemPos()
	hBg:SetSizeByAllItemSize()
	hBox:FormatAllItemPos()
	hBox:SetSizeByAllItemSize()
	
	frame:Lookup("Btn_CU"):SetRelPos(15, y + 8)
	frame:Lookup("Btn_Close"):SetRelPos(wAll - 10, 8)
	
	local xM, yM = wAll - 150, y + 10
	handle:Lookup("Image_Gold"):SetRelPos(xM + 66, yM)
	handle:Lookup("Image_Silver"):SetRelPos(xM + 106, yM)
	handle:Lookup("Image_Copper"):SetRelPos(xM + 144, yM)
	handle:Lookup("Text_Gold"):SetRelPos(xM, yM)
	handle:Lookup("Text_Silver"):SetRelPos(xM + 86, yM)
	handle:Lookup("Text_Copper"):SetRelPos(xM + 124, yM)
	
	handle:Lookup("Text_Title"):SetRelPos(wAll / 2 - 20, 6)
	
	handle:Lookup("Image_Bg1C"):SetSize(wAll - 311, 52)
	handle:Lookup("Image_Bg2L"):SetSize(8, y - 88)
	handle:Lookup("Image_Bg2C"):SetSize(wAll + 14, y - 88)
	handle:Lookup("Image_Bg2R"):SetSize(8, y - 88)
	handle:Lookup("Image_Bg3C"):SetSize(wAll - 102, 85)
	
	handle:FormatAllItemPos()
	handle:SetSizeByAllItemSize()
	local w, h = handle:GetSize()
	frame:SetSize(w, h)
	CorrectAutoPosFrameAfterClientResize()
	BigBankPanel.UpdateTotalBagCount(frame)
	frame:Lookup("CheckBox_Compact"):Check(true)
	frame.bDisable = false
end

function BigBankPanel.UpdateNormal(frame)
	frame.bDisable = true
	local player = GetClientPlayer()
	local aOpen = BigBankPanel.aOpen
	
	local wB, wS = 42, 1 --格子背景宽度，格子跟背景的缩进缩进
	local nW = 10	--一行拥有的格子数量
	local nLine = BigBankPanel.GetLine(nW)
	if nLine > 11 then
		nW = 10
		nLine = BigBankPanel.GetLine(nW)
		if nLine > 11 then
			nW = 12
			nLine = BigBankPanel.GetLine(nW)
			if nLine > 11 then
				nW = 14
				nLine = BigBankPanel.GetLine(nW)
				if nLine > 11 then
					local w = math.floor(wB * 12 / (nLine + 1))
					nW = math.floor(wB * 14 / w)
					if nW % 2 == 1 then
						nW = nW + 1
					end
					wB = w
				end
			end
		end
	end
		
	local wBox = wB - 2 * wS --格子宽度
	local wAll = wB * nW
	if wAll < 313 then
		wAll = 313
	end
	
	local wBB = 42
	local nBagCount = player.GetBankPackageCount()
	local btnBuy = frame:Lookup("Btn_Buy")
	if nBagCount >= GLOBAL.MAX_BANK_PACKAGE_COUNT then
		btnBuy:Hide()
	else
		btnBuy:Show()
		btnBuy:SetSize(wBB, wBB)
		btnBuy:SetRelPos(13 + (nBagCount + 1) * wBB, 58)
	end
	local handle = frame:Lookup("", "")
	for i = 1, BigBankPanel.nCount, 1 do
		local img = handle:Lookup("Image_BagBox"..i)
		local box = handle:Lookup("Box_Bag"..i)
		
		local x = 13 + (i - 1) * wBB
		local y = 58
		img:SetSize(wBB + 2, wBB + 2)
		img:SetRelPos(x, y)
		box:SetSize(wBB - 2, wBB - 2)
		box:SetRelPos(x + wS, y + wS)
		
		box:SetOverTextPosition(0, ITEM_POSITION.RIGHT_BOTTOM)
		box:SetOverTextFontScheme(0, 15)
		box.bBag = true
		box.nBagIndex = i
		box.nInventoryIndex = BigBankPanel.BagIndexToInventoryIndex(i)
		if i ~= 1 then
			box.dwBox = INVENTORY_INDEX.EQUIP
			box.dwX = EQUIPMENT_INVENTORY.BANK_PACKAGE1 + i - 2
			if i <= nBagCount + 1 then
				box:Show()
				img:Show()
			else
				box:Hide()
				img:Hide()
			end
		end
		BigBankPanel.UpdateBag(box)
	end
	
	local hBg = handle:Lookup("Handle_BG")
	local hBox = handle:Lookup("Handle_Box")
	local nIndex = 0
	local x, y = 15, 66 + wBB
	for i = 1, BigBankPanel.nCount, 1 do
		local dwBox = BigBankPanel.BagIndexToInventoryIndex(i)
		local dwSize = player.GetBoxSize(dwBox)
		if not dwSize or dwSize == 0 then
			local img = handle:Lookup("Image_Bg"..i)
			local imgB = handle:Lookup("Image_BgB"..i)
			local textB = handle:Lookup("Text_Bag"..i)
			img:SetSize(0,0)
			img:SetRelPos(0,0)
			img:Hide()
			imgB:SetSize(0,0)
			imgB:SetRelPos(0,0)
			imgB:Hide()
			textB:SetSize(0,0)
			textB:SetRelPos(0,0)
			textB:Hide()
			frame:Lookup("CheckBox_C"..i):Hide()		
		elseif not BigBankPanel.aOpen[i] then
			local img = handle:Lookup("Image_Bg"..i)
			local imgB = handle:Lookup("Image_BgB"..i)
			local textB = handle:Lookup("Text_Bag"..i)
			local check = frame:Lookup("CheckBox_C"..i)
			img:SetFrame(22)
			img:Show()
			img:SetSize(wAll - 6, 25)
			img:SetRelPos(17, y)
			imgB:Hide()
			imgB:SetSize(wAll + 12, 25)
			imgB:SetRelPos(8, y)
			textB:Show()
			textB:SetSize(wAll - 6, 25)
			textB:SetRelPos(17, y + 2)
			check:Show()
			check:Check(true)
			check:SetRelPos(wAll - wB / 2 + 3, y + 2)
			x, y = 15, y + 30
		else
			local img = handle:Lookup("Image_Bg"..i)
			local imgB = handle:Lookup("Image_BgB"..i)
			local textB = handle:Lookup("Text_Bag"..i)			
			local check = frame:Lookup("CheckBox_C"..i)
			img:SetFrame(22)
			img:Show()
			img:SetSize(wAll - 6, 25)
			img:SetRelPos(17, y)
			imgB:Show()
			imgB:SetSize(wAll + 16, 36 + math.ceil(dwSize / nW) * (wB + 2))
			imgB:SetRelPos(8, y - 2)
			textB:Show()
			textB:SetSize(wAll - 10, 25)
			textB:SetRelPos(17, y + 2)
			check:Show()
			check:Check(false)
			check:SetRelPos(wAll - wB / 2 + 3, y + 2)
			
			local aFrame = {29, 28, 13, 27}
			local nBT = GetBagContainType(dwBox)
			local nFrame = aFrame[nBT] or 13
			
			y = y + 25
			dwSize = dwSize - 1
			for dwX = 0, dwSize, 1 do
				local img = hBg:Lookup(nIndex)
				if not img then
					hBg:AppendItemFromString("<image>w=48 h=48 path=\"ui/Image/LootPanel/LootPanel.UITex\" frame=13 lockshowhide=1 </image>")
					img = hBg:Lookup(nIndex)
				end
				local box = hBox:Lookup(nIndex)
				if not box then
					hBox:AppendItemFromString("<box>w=44 h=44 eventid=524607 lockshowhide=1 </box>")
					box = hBox:Lookup(nIndex)
				end
				img:SetFrame(nFrame)
				img:Show()
				box:Show()
				box:SetName(dwBox.."_"..dwX)
				local n = dwX % nW
				local m = (dwX - n) / nW
				if m > 0 and n == 0 then
					x, y = 15, y + wB + 2
				end
				img:SetSize(wB, wB)
				img:SetRelPos(x + n * wB, y)
				box:SetSize(wBox, wBox)
				box:SetRelPos(x + n * wB + wS - 1, y + wS - 1)

				box:SetOverTextPosition(0, ITEM_POSITION.RIGHT_BOTTOM)
				box:SetOverTextFontScheme(0, 15)
				box.dwBox = dwBox
				box.dwX = dwX
				
				BigBankPanel.UpdateItem(box)
				
				nIndex = nIndex + 1
			end
			x, y = 15, y + wB + 8
		end
	end
	hBox.nCount = nIndex
	local nCount = hBox:GetItemCount() - 1
	for i = nIndex, nCount, 1 do
		local img = hBg:Lookup(i)
		local box = hBox:Lookup(i)
		img:Hide()
		img:SetRelPos(0, 0)
		img:SetSize(0, 0)
		box:Hide()
		box:SetRelPos(0, 0)
		box:SetSize(0, 0)
	end
	hBg:FormatAllItemPos()
	hBg:SetSizeByAllItemSize()
	hBox:FormatAllItemPos()
	hBox:SetSizeByAllItemSize()
	
	frame:Lookup("Btn_CU"):SetRelPos(15, y + 8)
	frame:Lookup("Btn_Close"):SetRelPos(wAll - 6, 15)
	
	local xM, yM = wAll - 146, y + 10
	handle:Lookup("Image_Gold"):SetRelPos(xM + 66, yM)
	handle:Lookup("Image_Silver"):SetRelPos(xM + 106, yM)
	handle:Lookup("Image_Copper"):SetRelPos(xM + 144, yM)
	handle:Lookup("Text_Gold"):SetRelPos(xM, yM)
	handle:Lookup("Text_Silver"):SetRelPos(xM + 86, yM)
	handle:Lookup("Text_Copper"):SetRelPos(xM + 124, yM)
	
	handle:Lookup("Text_Title"):SetRelPos(wAll / 2 - 20, 6)
	
	handle:Lookup("Image_Bg1C"):SetSize(wAll - 311, 52)
	handle:Lookup("Image_Bg2L"):SetSize(8, y - 88)
	handle:Lookup("Image_Bg2C"):SetSize(wAll + 14, y - 88)
	handle:Lookup("Image_Bg2R"):SetSize(8, y - 88)
	handle:Lookup("Image_Bg3C"):SetSize(wAll - 102, 85)
	
	
	handle:FormatAllItemPos()
	handle:SetSizeByAllItemSize()
	local w, h = handle:GetSize()
	frame:SetSize(w, h)
	CorrectAutoPosFrameAfterClientResize()
	BigBankPanel.UpdateTotalBagCount(frame)
	frame:Lookup("CheckBox_Compact"):Check(false)
	
	frame.bDisable = false
end

function BigBankPanel.UpdateMoney(frame)
	local handle = frame:Lookup("", "")
    local nMoney = GetClientPlayer().GetMoney()
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

function BigBankPanel.UpdateBag(box)
	local player = GetClientPlayer()
    if box.nBagIndex == 1 then
        box:SetObject(UI_OBJECT_NOT_NEED_KNOWN, box.nBagIndex)
        box:SetObjectIcon(374)
    else
		local item = GetPlayerItem(player, box.dwBox, box.dwX)
		UpdataItemBoxObject(box, box.dwBox, box.dwX, item)
    end
    box:SetObjectSelected(BigBankPanel.aOpen[box.nBagIndex])
    BigBankPanel.UpdateBagCount(box)
end

function BigBankPanel.UpdateBagCount(box)
	if IsShowBagSize() then
		local player = GetClientPlayer()
		local dwSize = player.GetBoxSize(box.nInventoryIndex)
		local dwSizeFree = player.GetBoxFreeRoomSize(box.nInventoryIndex)
		if BigBankPanel.bCompact then
			if not dwSize or dwSize == 0 then
				box:SetOverText(0, "")
			else
				box:SetOverText(0, (dwSize - dwSizeFree).."/"..dwSize)
			end
		else
			box:SetOverText(0, "")
			local text = box:GetParent():Lookup("Text_Bag"..box.nBagIndex)
			local szName = ""
			if box.nBagIndex == 1 then
				szName = g_tStrings.BANK_FIXED
			else
				local item = GetPlayerItem(player, box.dwBox, box.dwX)
				if item then
					szName =GetItemNameByItem(item)
--					text:SetFontColor(GetItemFontColorByQuality(item.nQuality))
				end
			end
			text:SetText(szName.."("..(dwSize - dwSizeFree).."/"..dwSize..")")
		end
	else
		box:SetOverText(0, "")
	end
end

function BigBankPanel.UpdateTotalBagCount(frame)
	local text = frame:Lookup("", "Text_Title")
	if IsShowBagSize() then
		local dwSize, dwFreeSize = 0, 0
		local player = GetClientPlayer()
		for i = 1, BigBankPanel.nCount, 1 do
			local nIndex = BigBankPanel.BagIndexToInventoryIndex(i)
			local dw1 = player.GetBoxSize(nIndex)
			if dw1 and dw1 ~= 0 then
				dwSize = dwSize + dw1
				local dw2 = player.GetBoxFreeRoomSize(nIndex)
				dwFreeSize = dwFreeSize + dw2
			end
		end
		if dwSize == 0 then
			text:SetText(g_tStrings.BIG_BANK)
		else
			text:SetText(g_tStrings.BIG_BANK .. "("..(dwSize - dwFreeSize).."/"..dwSize..")")
		end
	else
		text:SetText(g_tStrings.BIG_BANK)
	end
end

function BigBankPanel.UpdateItem(box)
	local player = GetClientPlayer()
	local item = GetPlayerItem(player, box.dwBox, box.dwX)
	UpdataItemBoxObject(box, box.dwBox, box.dwX, item)
	if box:IsObjectMouseOver() then
		local thisSave = this
		this = box
		BigBankPanel.OnItemMouseEnter()
		this = thisSave
	end	
end

function BigBankPanel.Sort(btn)
	local aBag = 
	{
		INVENTORY_INDEX.BANK, INVENTORY_INDEX.BANK_PACKAGE1, INVENTORY_INDEX.BANK_PACKAGE2, INVENTORY_INDEX.BANK_PACKAGE3, 
		INVENTORY_INDEX.BANK_PACKAGE4, INVENTORY_INDEX.BANK_PACKAGE5
	}
	BigBankPanel.fnSortItemFunc = GetBagSortFunc(aBag)
	if BigBankPanel.fnSortItemFunc then
		btn:Enable(false)
	end
end

function BigBankPanel.OnFrameBreathe()
	local player = GetClientPlayer()
	if not player or player.nMoveState == MOVE_STATE.ON_DEATH then
		CloseBigBankPanel()
		return
	end

	if BigBankPanel.fnSortItemFunc then
		local bF, bT = BigBankPanel.fnSortItemFunc()
		if not bF then
			for i = 0, 5, 1 do
				if BigBankPanel.fnSortItemFunc() then
					break
				end
			end
		elseif bT then
			BigBankPanel.fnSortItemFunc = nil
			this:Lookup("Btn_CU"):Enable(true)
		end
	end
	
	local handle = this:Lookup("", "Handle_Box")
	local nCount = handle.nCount or 0
	nCount = nCount - 1
	for i = 0, nCount, 1 do
		local box = handle:Lookup(i)
		UpdataItemCDProgress(player, box, box.dwBox, box.dwX)
	end
	
	if BigBankPanel.dwType then
	    if BigBankPanel.dwType == TARGET.NPC then
			local npc = GetNpc(BigBankPanel.dwID)
			if not npc or not npc.CanDialog(player) then
				CloseBigBankPanel()
			end
	    elseif BigBankPanel.dwType == TARGET.DOODAD then
			local doodad = GetDoodad(BigBankPanel.dwID)
			if not doodad or not doodad.CanDialog(player) then
				CloseBigBankPanel()
			end
	    end
	end	
end

function BigBankPanel.OnItemLButtonDown()
	local szName = this:GetName()
	if szName == "Image_Bg1" then
		return
	elseif szName == "Image_Bg2" then
		return
	elseif szName == "Image_Bg3" then
		return
	elseif szName == "Image_Bg4" then
		return
	elseif szName == "Image_Bg5" then
		return
	elseif szName == "Image_Bg6" then
		return
	elseif szName == "Image_Bg7" then
		return
	end
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

function BigBankPanel.OnItemLButtonUp()
	local szName = this:GetName()
	if szName == "Image_Bg1" then
		return
	elseif szName == "Image_Bg2" then
		return
	elseif szName == "Image_Bg3" then
		return
	elseif szName == "Image_Bg4" then
		return
	elseif szName == "Image_Bg5" then
		return
	elseif szName == "Image_Bg6" then
		return
	elseif szName == "Image_Bg7" then
		return
	end
	this:SetObjectPressed(0)
end

function BigBankPanel.OnItemLButtonDrag()
	this:SetObjectPressed(0)
	
	if not this:IsObjectEnable() or not this.dwBox or not this.dwX then
		return
	end
	
	if UserSelect.DoSelectItem(this.dwBox, this.dwX) then
		return
	end
	
	if (IsShiftKeyDown() and not IsCursorInExclusiveMode()) or Cursor.GetCurrentIndex() == CURSOR.SPLIT then
		OnSplitBoxItem(this, function() return (not IsBigBankPanelOpened()) end )
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

function BigBankPanel.OnItemLButtonDragEnd()
	this.bIgnoreClick = true
	
	if this.bBag then
		if not Hand_IsEmpty() then
			BigBankPanel.DropHandObjectToBag(this)
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
		BigBankPanel.OnExchangeBoxAndHandBoxItem(this)
	end	
end

function BigBankPanel.DropHandObjectToBag(box)
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
	local dwBox2, dwX2
	if box.nBagIndex == 1 then
		dwBox2 = dwBox2BigBankPanel.BagIndexToInventoryIndex(box.nBagIndex)
		dwX2 = GetClientPlayer().GetFreeRoom(dwBox2)
		if not dwX2 then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_ERROR_BAG_IS_FULL)
			PlayTipSound("006")
			return
		end
	else
		dwBox2, dwX2 = box.dwBox, box.dwX
	end
	if OnExchangeItem(dwBox1, dwX1, dwBox2, dwX2, nHandCount) then
		Hand_Clear()
	end
end

function BigBankPanel.OnItemLButtonClick()
	local szName = this:GetName()
	if szName == "Image_Bg1" then
		local frame = this:GetRoot()
    	BigBankPanel.aOpen[1] = not BigBankPanel.aOpen[1]
    	BigBankPanel.Update(frame)
		return
	elseif szName == "Image_Bg2" then
		local frame = this:GetRoot()
    	BigBankPanel.aOpen[2] = not BigBankPanel.aOpen[2]
    	BigBankPanel.Update(frame)
		return
	elseif szName == "Image_Bg3" then
		local frame = this:GetRoot()
    	BigBankPanel.aOpen[3] = not BigBankPanel.aOpen[3]
    	BigBankPanel.Update(frame)
		return
	elseif szName == "Image_Bg4" then
		local frame = this:GetRoot()
    	BigBankPanel.aOpen[4] = not BigBankPanel.aOpen[4]
    	BigBankPanel.Update(frame)
		return
	elseif szName == "Image_Bg5" then
		local frame = this:GetRoot()
    	BigBankPanel.aOpen[5] = not BigBankPanel.aOpen[5]
    	BigBankPanel.Update(frame)
		return
	elseif szName == "Image_Bg6" then
		local frame = this:GetRoot()
    	BigBankPanel.aOpen[6] = not BigBankPanel.aOpen[6]
    	BigBankPanel.Update(frame)
		return
	elseif szName == "Image_Bg7" then
		local frame = this:GetRoot()
    	BigBankPanel.aOpen[7] = not BigBankPanel.aOpen[7]
    	BigBankPanel.Update(frame)
		return
	end
	if this.bIgnoreClick then
		this.bIgnoreClick = nil
		return
	end
	
	if this.bBag then
		if Hand_IsEmpty() and not this:IsEmpty() then
			BigBankPanel.aOpen[this.nBagIndex] = not BigBankPanel.aOpen[this.nBagIndex]
			BigBankPanel.Update(this:GetRoot())
		else
			BigBankPanel.DropHandObjectToBag(this)
		end
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
	
	if UserSelect.DoSelectItem(this.dwBox, this.dwX) then
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
		BigBankPanel.OnExchangeBoxAndHandBoxItem(this)
	end	
end

function BigBankPanel.OnItemLButtonDBClick()
	BigBankPanel.OnItemLButtonClick()
end

-------右键操作-------
function BigBankPanel.OnItemRButtonDown()
	if this.bBag then
		BigBankPanel.OnItemLButtonDown()
		return
	end
	this:SetObjectPressed(1)
	this:SetObjectStaring(false)
end

function BigBankPanel.OnItemRButtonUp()
	if this.bBag then
		BigBankPanel.OnItemLButtonUp()
		return
	end
	this:SetObjectPressed(0)
end

function BigBankPanel.OnItemRButtonClick()
	if this.bBag then
		BigBankPanel.OnItemLButtonClick()
		return
	end
	if this:IsEmpty() then
		return
	end
	
	if not this:IsObjectEnable() then
		return
	end
	
	if this.bBag then
		return
	end

	local player = GetClientPlayer()
	local dwTBox, dwTX = player.GetStackRoomInPackage(this.dwBox, this.dwX)
	if dwTBox and dwTBox then
		OnExchangeItem(this.dwBox, this.dwX, dwTBox, dwTX)
		PlayItemSound(this:GetObjectData(), false)
	else
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_ERROR_BAG_IS_FULL);
		PlayTipSound("006")
	end
end

function BigBankPanel.OnExchangeBoxAndHandBoxItem(box)
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
		MarketTradePanel_BuyItem(dwBox, dwX, dwSaleID, box.dwBox, box.dwX)
		Hand_Clear()
		return
	elseif nSourceType ~= UI_OBJECT_ITEM then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_ERROR_CANNOT_DRAG_ITEM_IN_BAGPANEL)
		PlayTipSound("001")
		return	
	end	
		
	local _, dwBox1, dwX1 = boxHand:GetObjectData()
	if OnExchangeItem(dwBox1, dwX1, box.dwBox, box.dwX, nHandCount) then
		Hand_Clear()
	end
end

function BigBankPanel.OnItemMouseEnter()
	this:SetObjectMouseOver(1)
	if not this:IsEmpty() then
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
		if this.bBag and this.nBagIndex == 1 then
			local player = GetClientPlayer()
			local szTip = "<text>text="..EncodeComponentsString(g_tStrings.BANK).." font=60 "..GetItemFontColorByQuality(1, true)..
				" </text><text>text="..EncodeComponentsString(g_tStrings.BANK_FIXED1).." font=106 </text><text>text="
				..EncodeComponentsString(FormatString(g_tStrings.STR_ITEM_H_BAG_SIZE, player.GetBoxSize(this.nInventoryIndex))).."font=106</text>"
			OutputTip(szTip, 335, {x, y, w, h})
		else
			local _, dwBox, dwX = this:GetObjectData()
			OutputItemTip(UI_OBJECT_ITEM, dwBox, dwX, nil, {x, y, w, h})
		end		
	end
	
	if UserSelect.IsSelectItem() then
		UserSelect.SatisfySelectItem(this.dwBox, this.dwX)
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

function BigBankPanel.OnItemRefreshTip()
	BigBankPanel.OnItemMouseEnter()
end

function BigBankPanel.OnItemMouseLeave()
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


function BigBankPanel.OnEvent(event)
	if event == "BAG_ITEM_UPDATE" then
		if arg0 >= INVENTORY_INDEX.BANK_PACKAGE1 and arg0 <= INVENTORY_INDEX.BANK_PACKAGE5 then
			local box = this:Lookup("", "Handle_Box/"..arg0.."_"..arg1)
			if box then
				BigBankPanel.UpdateItem(box)
				box = this:Lookup("", "Box_Bag"..BigBankPanel.InventoryIndexToBagIndex(arg0))
				if box then
					BigBankPanel.UpdateBagCount(box)
					BigBankPanel.UpdateTotalBagCount(this)
				end
			end
		end
	elseif event == "BANK_ITEM_UPDATE" then
		local box = this:Lookup("", "Handle_Box/"..arg0.."_"..arg1)
		if box then
			BigBankPanel.UpdateItem(box)
			box = this:Lookup("", "Box_Bag"..BigBankPanel.InventoryIndexToBagIndex(arg0))
			if box then
				BigBankPanel.UpdateBagCount(box)
				BigBankPanel.UpdateTotalBagCount(this)
			end
		end		
	elseif event == "EQUIP_ITEM_UPDATE" then
		if arg1 >= EQUIPMENT_INVENTORY.BANK_PACKAGE1 and arg1 <= EQUIPMENT_INVENTORY.BANK_PACKAGE5 then
			if GetPlayerItem(GetClientPlayer(), INVENTORY_INDEX.EQUIP, arg1) then
				BigBankPanel.aOpen[arg1 - EQUIPMENT_INVENTORY.BANK_PACKAGE1 + 2] = true
			end
		    BigBankPanel.Update(this)
		end
	elseif event == "MONEY_UPDATE" then
		BigBankPanel.UpdateMoney(this)
	elseif event == "SYNC_ROLE_DATA_END" then
		BigBankPanel.Update(this)
	elseif event == "UPDATE_BANK_SLOT" then
		BigBankPanel.Update(this)
	elseif event == "ON_SET_SHOW_BAG_SIZE" then
		for i = 1, BigBankPanel.nCount, 1 do
			box = this:Lookup("", "Box_Bag"..i)
			if box then
				BigBagPanel.UpdateBagCount(box)
				BigBagPanel.UpdateTotalBagCount(this)
			end
		end
	elseif event == "ON_SET_BANK_COMPACT_MODE" then
		BigBankPanel.Update(this)
	elseif event == "CUSTOM_DATA_LOADED" then
		for i = 1, BigBankPanel.nCount, 1 do
			box = this:Lookup("", "Box_Bag"..i)
			if box then
				BigBagPanel.UpdateBagCount(box)
				BigBagPanel.UpdateTotalBagCount(this)
			end
		end
		BigBankPanel.Update(this)
	end
end

function BigBankPanel.OnLButtonClick()
	local szName = this:GetName()
    if szName == "Btn_Close" then
    	CloseBigBankPanel()
    elseif szName == "Btn_CU" then
    	BigBankPanel.Sort(this)
    elseif szName == "Btn_Buy" then
    	local player = GetClientPlayer()
    	local nCount = player.GetBankPackageCount()
		if nCount >= GLOBAL.MAX_BANK_PACKAGE_COUNT then
		    return
		end
		local nMoney = GetBankPackagePrice(nCount + 1)
		local msg = nil
		if nMoney > player.GetMoney() then
			msg = 
			{
				bRichText = true,
				szMessage = "<text>text="..EncodeComponentsString(g_tStrings.MSG_BUY_BAG_PANEL_NEED_MONEY).." font=105 </text>"..
					GetMoneyTipText(nMoney, 102).."<text>text="..EncodeComponentsString(g_tStrings.MSG_NOT_ENOUGH_MONEY).." font=105</text>", 
				szName = "BuyBagSure", 
				fnAutoClose = function() if not IsBigBankPanelOpened() then return true end end,
				{szOption = g_tStrings.STR_HOTKEY_SURE},
			}
		else
			msg = 
			{
				bRichText = true,
				szMessage = "<text>text="..EncodeComponentsString(g_tStrings.MSG_BUY_BAG_PANEL_NEED_MONEY).." font=105 </text>"..
					GetMoneyTipText(nMoney, 105).."<text>text="..EncodeComponentsString(g_tStrings.MSG_SURE_BUY_BAG_PANEL).." font=105</text>", 			
				szName = "BuyBagSure", 
				fnAutoClose = function() if not IsBigBankPanelOpened() then return true end end,
				{szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = function() GetClientPlayer().EnableBankPackage() end, szSound = g_sound.Trade},
				{szOption = g_tStrings.STR_HOTKEY_CANCEL}
			}
		end
		MessageBox(msg)
    end
end

function BigBankPanel.OnCheckBoxCheck()
	local frame = this:GetRoot()
	if frame.bDisable then
		return
	end
	local szName = this:GetName()
    if szName == "CheckBox_C1" then
    	BigBankPanel.aOpen[1] = false
    	BigBankPanel.Update(frame)
    elseif szName == "CheckBox_C2" then
    	BigBankPanel.aOpen[2] = false
    	BigBankPanel.Update(frame)
    elseif szName == "CheckBox_C3" then
    	BigBankPanel.aOpen[3] = false
    	BigBankPanel.Update(frame)
    elseif szName == "CheckBox_C4" then
    	BigBankPanel.aOpen[4] = false
    	BigBankPanel.Update(frame)
    elseif szName == "CheckBox_C5" then
    	BigBankPanel.aOpen[5] = false
    	BigBankPanel.Update(frame)
    elseif szName == "CheckBox_C6" then
    	BigBankPanel.aOpen[6] = false
    	BigBankPanel.Update(frame)
    elseif szName == "CheckBox_C7" then
    	BigBankPanel.aOpen[7] = false
    	BigBankPanel.Update(frame)
    elseif szName == "CheckBox_Compact" then
    	SetUseCompactBankPanel(true)
    end	
end

function BigBankPanel.OnCheckBoxUncheck()
	local frame = this:GetRoot()
	if frame.bDisable then
		return
	end
	local szName = this:GetName()
    if szName == "CheckBox_C1" then
    	BigBankPanel.aOpen[1] = true
    	BigBankPanel.Update(frame)
    elseif szName == "CheckBox_C2" then
    	BigBankPanel.aOpen[2] = true
    	BigBankPanel.Update(frame)
    elseif szName == "CheckBox_C3" then
    	BigBankPanel.aOpen[3] = true
    	BigBankPanel.Update(frame)
    elseif szName == "CheckBox_C4" then
    	BigBankPanel.aOpen[4] = true
    	BigBankPanel.Update(frame)
    elseif szName == "CheckBox_C5" then
    	BigBankPanel.aOpen[5] = true
    	BigBankPanel.Update(frame)
    elseif szName == "CheckBox_C6" then
    	BigBankPanel.aOpen[6] = true
    	BigBankPanel.Update(frame)
    elseif szName == "CheckBox_C7" then
    	BigBankPanel.aOpen[7] = true
    	BigBankPanel.Update(frame)
    elseif szName == "CheckBox_Compact" then
    	SetUseCompactBankPanel(false)    	
    end
end

function BigBankPanel_GetItemBox(dwBox, dwX, bEvenUnVisible)
	local frame = Station.Lookup("Normal/BigBankPanel")
	if frame and (frame:IsVisible() or bEvenUnVisible) then
		if dwBox == INVENTORY_INDEX.EQUIP then
			return frame:Lookup("", "Box_Bag"..(dwX - EQUIPMENT_INVENTORY.BANK_PACKAGE1 + 2))
		else
			return frame:Lookup("", "Handle_Box/"..dwBox.."_"..dwX)
		end
	end	
end

function OpenBigBankPanel(dwType, dwID, bDisableSound)
	if IsOptionOrOptionChildPanelOpened() then
		return
	end
	if IsBigBankPanelOpened() then
		return
	end
	BigBankPanel.dwType = dwType
	BigBankPanel.dwID = dwID
	local frame = Station.Lookup("Normal/BigBankPanel")
	if not frame then
		frame = Wnd.OpenWindow("BigBankPanel")
		BigBankPanel.Update(frame)
		BigBankPanel.UpdateMoney(frame)
	end
	frame:Show()
	frame:BringToTop()
	UserSelect.RefreshSelectedBox()
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
	OpenAllBagPanel(true)
	local hBtnBuy = frame:Lookup("Btn_Buy")
	FireHelpEvent("OnOpenpanel", "BANK", hBtnBuy)
end

function IsBigBankPanelOpened()
	local frame = Station.Lookup("Normal/BigBankPanel")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end

function CloseBigBankPanel(bDisableSound) 
	if not IsBigBankPanelOpened() then
		return
	end
	GetClientPlayer().CloseBank()
	Wnd.CloseWindow("BigBankPanel")
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end
end

function SetUseCompactBankPanel(bUse)
	if BigBankPanel.bCompact == bUse then
		return
	end
	
	BigBankPanel.bCompact = bUse
	FireEvent("ON_SET_BANK_COMPACT_MODE")
end

function IsBankInSort()
	if IsBankPanelOpened() and BigBankPanel.fnSortItemFunc then
		return true
	end
	return false
end

function IsUseCompactBankPanel()
	return BigBankPanel.bCompact
end

function OpenBankPanel(dwType, dwID, bDisableSound)
	if IsUseBigBagPanel() then
		return OpenBigBankPanel(dwType, dwID, bDisableSound)
	else
		return OpenNormalBankPanel(dwType, dwID, bDisableSound)
	end
end

function IsBankPanelOpened()
	if IsUseBigBagPanel() then
		return IsBigBankPanelOpened()
	else
		return IsNormalBankPanelOpened()
	end
end

function CloseBankPanel(bDisableSound)
	if IsUseBigBagPanel() then
		return CloseBigBankPanel()
	else
		return CloseNormalBankPanel()
	end
end

function BankPanel_GetItemBox(dwBox, dwX, bEvenUnVisible)
	if IsUseBigBagPanel() then
		return BigBankPanel_GetItemBox(dwBox, dwX, bEvenUnVisible)
	else
		return NormalBankPanel_GetItemBox(dwBox, dwX, bEvenUnVisible)
	end
end
