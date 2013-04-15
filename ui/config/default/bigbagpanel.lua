BigBagPanel = 
{
	nCount = 5,
	aOpen = {true, true, true, true, true},
	bCompact = false,
	bShowSize = true,
	bUseBigBagPanel = true,
	Anchor = {s = "BOTTOMRIGHT", r = "BOTTOMRIGHT", x = -60, y = -80}
}

RegisterCustomData("BigBagPanel.Anchor")
RegisterCustomData("BigBagPanel.aOpen")
RegisterCustomData("BigBagPanel.bCompact")
RegisterCustomData("BigBagPanel.bShowSize")
RegisterCustomData("BigBagPanel.bUseBigBagPanel")

function BigBagPanel.OnFrameCreate()
	this:RegisterEvent("BAG_ITEM_UPDATE")
	this:RegisterEvent("EQUIP_ITEM_UPDATE")
	this:RegisterEvent("SYNC_ROLE_DATA_END")
	this:RegisterEvent("MONEY_UPDATE")
	this:RegisterEvent("SYNC_COIN")
	this:RegisterEvent("ON_SET_SHOW_BAG_SIZE")
	this:RegisterEvent("UI_SCALED")
	this:RegisterEvent("BIG_BAG_PANEL_ANCHOR_LOADED")
	this:RegisterEvent("ON_SET_USE_BIGBAGPANEL")
	this:RegisterEvent("ON_SET_BAG_COMPACT_MODE")
	this:RegisterEvent("CUSTOM_DATA_LOADED")
    this:RegisterEvent("CURRENCY_CHECK_NOTIFY")
    this:RegisterEvent("CURRENCY_VALUE_UPDATE")
end

function BigBagPanel.BagIndexToInventoryIndex(nIndex)
	return INVENTORY_INDEX.PACKAGE + nIndex - 1
end

function BigBagPanel.InventoryIndexToBagIndex(nIndex)
	return nIndex - INVENTORY_INDEX.PACKAGE + 1
end

function BigBagPanel.GetLine(w)
	local nLine = 0
	local player = GetClientPlayer()
	for i = 1, BigBagPanel.nCount, 1 do
		local dwSize = player.GetBoxSize(BigBagPanel.BagIndexToInventoryIndex(i))
		nLine = nLine + math.ceil(dwSize / w)
	end
	return nLine
end

function BigBagPanel.GetSize()
	local dwSize = 0
	local player = GetClientPlayer()
	for i = 1, BigBagPanel.nCount, 1 do
		local dwSizeT = player.GetBoxSize(BigBagPanel.BagIndexToInventoryIndex(i))
		dwSize = dwSize + dwSizeT
	end
	return dwSize
end

function BigBagPanel.Update(frame)
	if BigBagPanel.bCompact then
		BigBagPanel.UpdateCompact(frame)
	else
		BigBagPanel.UpdateNormal(frame)
	end
	RefreshUILockItem()
	UserSelect.RefreshSelectedBox()	
end

local function UpdatePlayerInfo(frame, bBulid, nX, nY)
    local handle = frame:Lookup("", "")
    local tResult = Currency_GetCheckedCurrency()
    local nSize = #tResult
    local hList = handle:Lookup("Handle_Currency")
    hList:Clear()
    
    if bBulid then
        if nSize == 0 then
            handle.bInfoLine = false
            return false;
        end
    else
        if not handle.bInfoLine and nSize == 0 then
            return
        elseif (handle.bInfoLine and nSize == 0) or (not handle.bInfoLine and nSize > 0) then
            BigBagPanel.Update(frame)
            return
        end
    end

    for i = 1, 3 - nSize, 1 do
        local hItem = hList:AppendItemFromIni("UI/Config/Default/BigBagPanel.ini", "Handle_Option")
        hItem:Clear()
    end
    for k, v in ipairs(tResult) do
        local hItem = hList:AppendItemFromIni("UI/Config/Default/BigBagPanel.ini", "Handle_Option")
        hItem:Lookup("Text_Count"):SetText(v.nCount)
        hItem:Lookup("Image_Logo"):SetFrame(v.nFrame)
        hItem.szName = v.szName
    end   
    hList:FormatAllItemPos()
    
    if bBulid then
       local nW = hList:GetSize()
       hList:SetRelPos(nX - nW, nY)
    end
    
    handle.bInfoLine = true
	return true
end

function BigBagPanel.UpdateCompact(frame)
	frame.bDisable = true
	local player = GetClientPlayer()
	local aOpen = BigBagPanel.aOpen
	
	local wB, wS = 42, 1 --格子背景宽度，格子跟背景的缩进缩进
	local nW = 8	--一行拥有的格子数量
	local nSize = BigBagPanel.GetSize()
	local nLine = math.ceil(nSize / nW)
	if nLine > 12 then
		nW = math.ceil(nSize / 12)
	end
		
	local wBox = wB - 2 * wS --格子宽度
	local wAll = wB * nW
	if wAll < 313 then
		wAll = 313
	end
		
	local handle = frame:Lookup("", "")
	for i = 1, BigBagPanel.nCount, 1 do
		local img = handle:Lookup("Image_BagBox"..i)
		local box = handle:Lookup("Box_Bag"..i)
		local x = 13 + (i - 1) * (wB + 2)
		local y = 58
		img:SetSize(wB + 2, wB + 2)
		img:SetRelPos(x, y)
		box:SetSize(wBox, wBox)
		box:SetRelPos(x + wS, y + wS)
		
		box:SetOverTextPosition(0, ITEM_POSITION.RIGHT_BOTTOM)
		box:SetOverTextFontScheme(0, 15)
		box.bBag = true
		box.nBagIndex = i
		box.nInventoryIndex = BigBagPanel.BagIndexToInventoryIndex(i)
		if i ~= 1 then
			box.dwBox = INVENTORY_INDEX.EQUIP
			box.dwX = EQUIPMENT_INVENTORY.PACKAGE1 + i - 2
		end
		BigBagPanel.UpdateBag(box)
	end
	
	local hBg = handle:Lookup("Handle_BG")
	local hBox = handle:Lookup("Handle_Box")
	local bAdd = false
	local nIndex = 0
	local x, y = 16, 66 + wB
	for i = 1, BigBagPanel.nCount, 1 do
		local dwBox = BigBagPanel.BagIndexToInventoryIndex(i)
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
		if not BigBagPanel.aOpen[i] then
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
			BigBagPanel.UpdateItem(box)
			
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
	--todo :wangbin4  以后要删除
	local bShow = UpdatePlayerInfo(frame, true, wAll + 14, y + 57)
	local nInfoH = 0
	if bShow then
		nInfoH = 25
	end
	--end--------------
	
	frame:Lookup("Btn_Split"):SetRelPos(15, y + 8)
	frame:Lookup("Btn_CU"):SetRelPos(105, y + 8)
    frame:Lookup("Btn_Currency"):SetRelPos(wAll - 77, y + 8)
	frame:Lookup("Btn_Close"):SetRelPos(wAll - 6, 15)
	
	local xM, yM = wAll - 150, y + 10
    local nAddH, nSubW = 25, 100
	handle:Lookup("Image_Gold"):SetRelPos(xM + 66 - nSubW, yM + nAddH)
	handle:Lookup("Image_Silver"):SetRelPos(xM + 106 - nSubW, yM + nAddH)
	handle:Lookup("Image_Copper"):SetRelPos(xM + 144 - nSubW, yM + nAddH)
	handle:Lookup("Image_Coin"):SetRelPos(xM + 144, yM + nAddH)
	handle:Lookup("Text_Gold"):SetRelPos(xM - nSubW, yM + nAddH)
	handle:Lookup("Text_Silver"):SetRelPos(xM + 82 - nSubW, yM + nAddH)
	handle:Lookup("Text_Copper"):SetRelPos(xM + 122 - nSubW, yM + nAddH)
	handle:Lookup("Text_Coin"):SetRelPos(xM + 120, yM + nAddH)
	
	handle:Lookup("Text_Title"):SetRelPos(wAll / 2 - 20, 6)

	handle:Lookup("Image_Bg1C"):SetSize(wAll - 311, 52)
	handle:Lookup("Image_Bg2L"):SetSize(8, y - 81 + nInfoH)
	handle:Lookup("Image_Bg2C"):SetSize(wAll + 14, y - 81 + nInfoH)
	handle:Lookup("Image_Bg2R"):SetSize(8, y - 81 + nInfoH)
	handle:Lookup("Image_Bg3C"):SetSize(wAll - 102, 85)
	
	
	handle:FormatAllItemPos()
	handle:SetSizeByAllItemSize()
	local w, h = handle:GetSize()
	frame:SetSize(w, h)
	frame:EnableDrag(true)
	frame:SetDragArea(0, 0, w, 30)
	frame:CorrectPos()
	BigBagPanel.UpdateTotalBagCount(frame)
	frame:Lookup("CheckBox_Compact"):Check(true)
	frame.bDisable = false
end

function BigBagPanel.UpdateNormal(frame)
	frame.bDisable = true
	local player = GetClientPlayer()
	local aOpen = BigBagPanel.aOpen
	
	local wB, wS = 42, 1 --格子背景宽度，格子跟背景的缩进缩进
	local nW = 8	--一行拥有的格子数量
	local nLine = BigBagPanel.GetLine(nW) --行数
	if nLine > 10 then
		nW = 10
		nLine = BigBagPanel.GetLine(nW)
		if nLine > 10 then
			nW = 12
		end
	end
		
	local wBox = wB - 2 * wS --格子宽度
	local wAll = wB * nW
	if wAll < 313 then
		wAll = 313
	end
		
	local handle = frame:Lookup("", "")
	for i = 1, BigBagPanel.nCount, 1 do
		local img = handle:Lookup("Image_BagBox"..i)
		local box = handle:Lookup("Box_Bag"..i)
		local x = 13 + (i - 1) * (wB + 2)
		local y = 58
		img:SetSize(wB + 2, wB + 2)
		img:SetRelPos(x, y)
		box:SetSize(wBox, wBox)
		box:SetRelPos(x + wS, y + wS)
		
		box:SetOverTextPosition(0, ITEM_POSITION.RIGHT_BOTTOM)
		box:SetOverTextFontScheme(0, 15)
		box.bBag = true
		box.nBagIndex = i
		box.nInventoryIndex = BigBagPanel.BagIndexToInventoryIndex(i)
		if i ~= 1 then
			box.dwBox = INVENTORY_INDEX.EQUIP
			box.dwX = EQUIPMENT_INVENTORY.PACKAGE1 + i - 2
		end
		BigBagPanel.UpdateBag(box)
	end
	
	local hBg = handle:Lookup("Handle_BG")
	local hBox = handle:Lookup("Handle_Box")
	local nIndex = 0
	local x, y = 15, 70 + wB
	for i = 1, BigBagPanel.nCount, 1 do
		local dwBox = BigBagPanel.BagIndexToInventoryIndex(i)
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
		elseif not BigBagPanel.aOpen[i] then
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
			imgB:SetRelPos(8, y - 2)
			textB:Show()
			textB:SetSize(wAll - 10, 25)
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
				box:SetRelPos(x + n * wB + wS-1, y + wS-1)

				box:SetOverTextPosition(0, ITEM_POSITION.RIGHT_BOTTOM)
				box:SetOverTextFontScheme(0, 15)
				box.dwBox = dwBox
				box.dwX = dwX
				
				BigBagPanel.UpdateItem(box)
				
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
	
    --todo :wangbin4  以后要删除
    local bShow = UpdatePlayerInfo(frame, true, wAll + 17, y + 57)
    local nInfoH = 0
    if bShow then
        nInfoH = 25
    end
    --end--------------
	
	frame:Lookup("Btn_Split"):SetRelPos(15, y + 8)
	frame:Lookup("Btn_CU"):SetRelPos(105, y + 8)
    frame:Lookup("Btn_Currency"):SetRelPos(wAll - 77, y + 8)
    
	frame:Lookup("Btn_Close"):SetRelPos(wAll - 6, 15)
    
	local xM, yM = wAll - 146, y + 10
    local nAddH, nSubW = 25, 100
    
	handle:Lookup("Image_Gold"):SetRelPos(xM + 66 - nSubW, yM + nAddH)
	handle:Lookup("Image_Silver"):SetRelPos(xM + 106 - nSubW, yM + nAddH)
	handle:Lookup("Image_Copper"):SetRelPos(xM + 144 - nSubW, yM + nAddH)
	handle:Lookup("Image_Coin"):SetRelPos(xM + 144, yM + nAddH)
	handle:Lookup("Text_Gold"):SetRelPos(xM - nSubW, yM + nAddH)
	handle:Lookup("Text_Silver"):SetRelPos(xM + 84 - nSubW, yM + nAddH)
	handle:Lookup("Text_Copper"):SetRelPos(xM + 124 - nSubW, yM + nAddH)
	handle:Lookup("Text_Coin"):SetRelPos(xM + 120, yM + 20)	
	
	handle:Lookup("Text_Title"):SetRelPos(wAll / 2 - 20, 6)
	
	handle:Lookup("Image_Bg1C"):SetSize(wAll - 311, 52)
	handle:Lookup("Image_Bg2L"):SetSize(8, y - 81 + nInfoH)
	handle:Lookup("Image_Bg2C"):SetSize(wAll + 14, y - 81 + nInfoH)
	handle:Lookup("Image_Bg2R"):SetSize(8, y - 81 + nInfoH)
	handle:Lookup("Image_Bg3C"):SetSize(wAll - 102, 85)
	
	handle:FormatAllItemPos()
	handle:SetSizeByAllItemSize()
	local w, h = handle:GetSize()
	frame:SetSize(w, h)
	frame:EnableDrag(true)
	frame:SetDragArea(0, 0, w, 30)
	frame:CorrectPos()
	BigBagPanel.UpdateTotalBagCount(frame)
	frame:Lookup("CheckBox_Compact"):Check(false)
	frame.bDisable = false
end

function BigBagPanel.UpdateMoney(frame)
	local handle = frame:Lookup("", "")
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
    
    handle:Lookup("Text_Coin"):SetText(player.nCoin)

end

function BigBagPanel.UpdateCurrency(frame)
    local handle = frame:Lookup("", "")
    local tResult = Currency_GetCheckedCurrency() or {}
    local hList = handle:Lookup("Handle_Currency")
    local nCount = hList:GetItemCount() - 1
    
    for i=0, nCount, 1 do
        local hItem = hList:Lookup(i)
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

function BigBagPanel.UpdateBag(box)
	local player = GetClientPlayer()
    if box.nBagIndex == 1 then
        box:SetObject(UI_OBJECT_NOT_NEED_KNOWN, box.nBagIndex)
        box:SetObjectIcon(374)
    else
		local item = GetPlayerItem(player, box.dwBox, box.dwX)
		UpdataItemBoxObject(box, box.dwBox, box.dwX, item)
    end
    box:SetObjectSelected(BigBagPanel.aOpen[box.nBagIndex])
    BigBagPanel.UpdateBagCount(box)
end

function BigBagPanel.UpdateBagCount(box)
	if IsShowBagSize() then
		local player = GetClientPlayer()
		local dwSize = player.GetBoxSize(box.nInventoryIndex)
		local dwSizeFree = player.GetBoxFreeRoomSize(box.nInventoryIndex)
		if BigBagPanel.bCompact then
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
				szName = g_tStrings.BAG1
			else
				local item = GetPlayerItem(player, box.dwBox, box.dwX)
				if item then
					szName = GetItemNameByItem(item)
--					text:SetFontColor(GetItemFontColorByQuality(item.nQuality))
				end
			end
			text:SetText(szName.."("..(dwSize - dwSizeFree).."/"..dwSize..")")
		end
	else
		box:SetOverText(0, "")
	end
end

function BigBagPanel.UpdateTotalBagCount(frame)
	local text = frame:Lookup("", "Text_Title")
	if IsShowBagSize() then
		local dwSize, dwFreeSize = 0, 0
		local player = GetClientPlayer()
		for i = 1, BigBagPanel.nCount, 1 do
			local nIndex = BigBagPanel.BagIndexToInventoryIndex(i)
			local dw1 = player.GetBoxSize(nIndex)
			if dw1 and dw1 ~= 0 then
				dwSize = dwSize + dw1
				local dw2 = player.GetBoxFreeRoomSize(nIndex)
				dwFreeSize = dwFreeSize + dw2
			end
		end
		if dwSize == 0 then
			text:SetText(g_tStrings.BAG)
		else
			text:SetText(g_tStrings.BAG .. "("..(dwSize - dwFreeSize).."/"..dwSize..")")
		end
	else
		text:SetText(g_tStrings.BAG)
	end
end

function BigBagPanel.UpdateItem(box)
	local player = GetClientPlayer()
	local item = GetPlayerItem(player, box.dwBox, box.dwX)
	UpdataItemBoxObject(box, box.dwBox, box.dwX, item)
	if box:IsObjectMouseOver() then
		local thisSave = this
		this = box
		BigBagPanel.OnItemMouseEnter()
		this = thisSave
	end	
end

function BigBagPanel.OnFrameDrag()
end

function BigBagPanel.OnFrameDragSetPosEnd()
end

function BigBagPanel.OnFrameDragEnd()
	this:CorrectPos()
	BigBagPanel.Anchor = GetFrameAnchor(this)
end

function BigBagPanel.Sort(btn)
	local aBag = {INVENTORY_INDEX.PACKAGE, INVENTORY_INDEX.PACKAGE1, INVENTORY_INDEX.PACKAGE2, INVENTORY_INDEX.PACKAGE3, INVENTORY_INDEX.PACKAGE4}
	BigBagPanel.fnSortItemFunc = GetBagSortFunc(aBag)
	if BigBagPanel.fnSortItemFunc then
		btn:Enable(false)
		
		if IsFEProducePanelOpened() then
			CloseFEProducePanel()
		end
		
		if IsFEEquipExtractPanelOpened() then
			CloseFEProducePeelPanel()
		end
		
		if IsFEActivationPanelOpened() then
			CloseFEActivationPanel()
		end
	end
end

function BigBagPanel.OnFrameBreathe()
	local player = GetClientPlayer()
	if not player then
		return
	end
	
	if BigBagPanel.fnSortItemFunc then
		local bF, bT = BigBagPanel.fnSortItemFunc()
		if not bF then
			for i = 0, 5, 1 do
				if BigBagPanel.fnSortItemFunc() then
					break
				end
			end
		elseif bT then
			BigBagPanel.fnSortItemFunc = nil
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
end

function BigBagPanel.OnItemLButtonDown()

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
	elseif szName == "Text_Coin" or szName == "Image_Coin" then
		return		
	end
	this.bIgnoreClick = nil
	if IsCtrlKeyDown() and not this:IsEmpty() and this.dwBox and this.dwX then
		if IsAuctionSearchOpened() then
			local item = GetPlayerItem(GetClientPlayer(), this.dwBox, this.dwX)
			local szName = GetItemNameByItem(item)
			Auction_SetItemName(szName)
		elseif IsGMPanelReceiveItem() then
			GMPanel_LinkItem(this.dwBox, this.dwX)
		else
			EditBox_AppendLinkItem(this.dwBox, this.dwX)
		end
		this.bIgnoreClick = true
	end
	this:SetObjectStaring(false)
	this:SetObjectPressed(1)
end

function BigBagPanel.OnItemLButtonUp()
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
	elseif szName == "Text_Coin" or szName == "Image_Coin" then
		return		
	end
	this:SetObjectPressed(0)
end

function BigBagPanel.OnItemLButtonDrag()
	this:SetObjectPressed(0)
	
	if not this:IsObjectEnable() or not this.dwBox or not this.dwX then
		return
	end
	
	if UserSelect.DoSelectItem(this.dwBox, this.dwX) then
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

function BigBagPanel.OnItemLButtonDragEnd()
	this.bIgnoreClick = true
	
	if this.bBag then
		if not Hand_IsEmpty() then
			BigBagPanel.DropHandObjectToBag(this)
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
		BigBagPanel.OnExchangeBoxAndHandBoxItem(this)
	end	
end

function BigBagPanel.DropHandObjectToBag(box)
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
		dwBox2 = dwBox2BigBagPanel.BagIndexToInventoryIndex(box.nBagIndex)
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

function BigBagPanel.OnItemLButtonClick()
	local szName = this:GetName()
	if szName == "Text_Coin" or szName == "Image_Coin" then
		if IsTongBaoPanelPannelOpened() then
			CloseTongBaoPanelPannel()
		else
			OpenTongBaoPanelPannel()
		end
		return
	end

	local szName = this:GetName()
	if szName == "Image_Bg1" then
		local frame = this:GetRoot()
    	BigBagPanel.aOpen[1] = not BigBagPanel.aOpen[1]
    	BigBagPanel.Update(frame)
    	BigBagPanel.Anchor = GetFrameAnchor(frame)		
		return
	elseif szName == "Image_Bg2" then
		local frame = this:GetRoot()
    	BigBagPanel.aOpen[2] = not BigBagPanel.aOpen[2]
    	BigBagPanel.Update(frame)
    	BigBagPanel.Anchor = GetFrameAnchor(frame)		
		return
	elseif szName == "Image_Bg3" then
		local frame = this:GetRoot()
    	BigBagPanel.aOpen[3] = not BigBagPanel.aOpen[3]
    	BigBagPanel.Update(frame)
    	BigBagPanel.Anchor = GetFrameAnchor(frame)		
		return
	elseif szName == "Image_Bg4" then
		local frame = this:GetRoot()
    	BigBagPanel.aOpen[4] = not BigBagPanel.aOpen[4]
    	BigBagPanel.Update(frame)
    	BigBagPanel.Anchor = GetFrameAnchor(frame)		
		return
	elseif szName == "Image_Bg5" then
		local frame = this:GetRoot()
    	BigBagPanel.aOpen[5] = not BigBagPanel.aOpen[5]
    	BigBagPanel.Update(frame)
    	BigBagPanel.Anchor = GetFrameAnchor(frame)		
		return
	end
	
	if this.bIgnoreClick then
		this.bIgnoreClick = nil
		return
	end
	
	if this.bBag then
		if Hand_IsEmpty() and not this:IsEmpty() then
			BigBagPanel.aOpen[this.nBagIndex] = not BigBagPanel.aOpen[this.nBagIndex]
			local frame = this:GetRoot()
			BigBagPanel.Update(frame)
			BigBagPanel.Anchor = GetFrameAnchor(frame)
		else
			BigBagPanel.DropHandObjectToBag(this)
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
		BigBagPanel.OnExchangeBoxAndHandBoxItem(this)
	end	
end

function BigBagPanel.OnItemLButtonDBClick()
	BigBagPanel.OnItemLButtonClick()
end

-------右键操作-------
function BigBagPanel.OnItemRButtonDown()
	if this.bBag then
		BigBagPanel.OnItemLButtonDown()
		return
	end
	this:SetObjectPressed(1)
	this:SetObjectStaring(false)
end

function BigBagPanel.OnItemRButtonUp()
	if this.bBag then
		BigBagPanel.OnItemLButtonUp()
		return
	end
	this:SetObjectPressed(0)
end

function BigBagPanel.OnItemRButtonClick()
	if this.bBag then
		BigBagPanel.OnItemLButtonClick()
		return
	end
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
		elseif item.nSub == EQUIPMENT_SUB.BULLET then
			local dwFreeBox, dwFreeX = WeaponBag_GetFreeBox()
			if dwFreeX and dwFreeBox then
				OnExchangeItem(dwBox, dwX, dwFreeBox, dwFreeX, item.nStackNum)
			end
		else
		    local eRetCode, nEquipPos = player.GetEquipPos(dwBox, dwX)
		    if eRetCode == ITEM_RESULT_CODE.SUCCESS then
			    OnExchangeItem(dwBox, dwX, INVENTORY_INDEX.EQUIP, nEquipPos)
			    PlayItemSound(nUiId)
	        else
	            OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tItem_Msg[eRetCode]);
	        end
	    end
        return
    elseif item and item.nGenre == ITEM_GENRE.BOOK then
        player.OpenBook(dwBox, dwX)
        return
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

function BigBagPanel.OnExchangeBoxAndHandBoxItem(box)
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

function BigBagPanel.OnItemMouseEnter()
	local szName = this:GetName()
	if szName == "Image_Coin" or szName == "Text_Coin" then
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
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
		if this.bBag and this.nBagIndex == 1 then
			local player = GetClientPlayer()
			local szTip = "<text>text="..EncodeComponentsString(g_tStrings.BAG2).." font=60 "..GetItemFontColorByQuality(1, true)..
				" </text><text>text="..EncodeComponentsString(g_tStrings.PACKAGE).." font=106 </text><text>text="
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

function BigBagPanel.OnItemRefreshTip()
	BigBagPanel.OnItemMouseEnter()
end

function BigBagPanel.OnItemMouseLeave()
	local szName = this:GetName()
	if szName == "Image_Coin" or szName == "Text_Coin" then
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


function BigBagPanel.OnEvent(event)
	if event == "BAG_ITEM_UPDATE" then
		if arg0 >= INVENTORY_INDEX.PACKAGE and arg0 <= INVENTORY_INDEX.PACKAGE4 then
			local box = this:Lookup("", "Handle_Box/"..arg0.."_"..arg1)
			if box then
				BigBagPanel.UpdateItem(box)
				box = this:Lookup("", "Box_Bag"..BigBagPanel.InventoryIndexToBagIndex(arg0))
				if box then
					BigBagPanel.UpdateBagCount(box)
					BigBagPanel.UpdateTotalBagCount(this)
					if BigBagPanel.IsBagPanelFull() then
				    		FireHelpEvent("OnBagPanelFull") 
					end
				end
			end
		end
	elseif event == "EQUIP_ITEM_UPDATE" then
		
		if arg1 >= EQUIPMENT_INVENTORY.PACKAGE1 and arg1 <= EQUIPMENT_INVENTORY.PACKAGE4 then
			if GetPlayerItem(GetClientPlayer(), INVENTORY_INDEX.EQUIP, arg1) then
				BigBagPanel.aOpen[arg1 - EQUIPMENT_INVENTORY.PACKAGE1 + 2] = true
			end
		    BigBagPanel.Update(this)
		    BigBagPanel.Anchor = GetFrameAnchor(this)
		    if BigBagPanel.IsBagPanelFull() then
		    	FireHelpEvent("OnBagPanelFull") 
		    end
		end
	elseif event == "MONEY_UPDATE" then
		BigBagPanel.UpdateMoney(this)
	elseif event == "SYNC_COIN" then
		BigBagPanel.UpdateMoney(this)	
	elseif event == "SYNC_ROLE_DATA_END" then
		BigBagPanel.Update(this)
		BigBagPanel.Anchor = GetFrameAnchor(this)
	elseif event == "UI_SCALED" or event == "BIG_BAG_PANEL_ANCHOR_LOADED" then
		this:SetPoint(BigBagPanel.Anchor.s, 0, 0, BigBagPanel.Anchor.r, BigBagPanel.Anchor.x, BigBagPanel.Anchor.y)
		this:CorrectPos()
	elseif event == "ON_SET_SHOW_BAG_SIZE" then
		for i = 1, BigBagPanel.nCount, 1 do
			box = this:Lookup("", "Box_Bag"..i)
			if box then
				BigBagPanel.UpdateBagCount(box)
				BigBagPanel.UpdateTotalBagCount(this)
			end
		end
	elseif event == "ON_SET_USE_BIGBAGPANEL" then
		if not IsUseBigBagPanel() then
			CloseBigBagPanel()
		end
	elseif event == "ON_SET_BAG_COMPACT_MODE" then
		BigBagPanel.Update(this)	
	elseif event == "CUSTOM_DATA_LOADED" then
		for i = 1, BigBagPanel.nCount, 1 do
			box = this:Lookup("", "Box_Bag"..i)
			if box then
				BigBagPanel.UpdateBagCount(box)
				BigBagPanel.UpdateTotalBagCount(this)
			end
		end
		if not IsUseBigBagPanel() then
			CloseBigBagPanel()
		end
		BigBagPanel.Update(this)
		this:SetPoint(BigBagPanel.Anchor.s, 0, 0, BigBagPanel.Anchor.r, BigBagPanel.Anchor.x, BigBagPanel.Anchor.y)
		this:CorrectPos()
    elseif event == "CURRENCY_CHECK_NOTIFY" then
        UpdatePlayerInfo(this)
    elseif event == "CURRENCY_VALUE_UPDATE" then
        BigBagPanel.UpdateCurrency(this)
	end
end

function BigBagPanel.OnLButtonClick()
	local szName = this:GetName()
    if szName == "Btn_Close" then
    	CloseBigBagPanel()
    elseif szName == "Btn_Split" then
    	if not Hand_IsEmpty() then
    		Hand_Clear()
    	end
    	Cursor.Switch(CURSOR.SPLIT)	--拆分下的鼠标
    	PlaySound(SOUND.UI_SOUND,g_sound.Button)
    elseif szName == "Btn_CU" then
    	BigBagPanel.Sort(this)
    	PlaySound(SOUND.UI_SOUND,g_sound.Button)
    elseif szName == "Btn_Currency" then
        if IsCurrencyPanelOpened() then
            CloseCurrencyPanel()
        else
            OpenCurrencyPanel()
        end
    end
end

function BigBagPanel.OnCheckBoxCheck()
	local frame = this:GetRoot()
	if frame.bDisable then
		return
	end
	local szName = this:GetName()
    if szName == "CheckBox_C1" then
    	BigBagPanel.aOpen[1] = false
    	BigBagPanel.Update(frame)
    	BigBagPanel.Anchor = GetFrameAnchor(frame)
    elseif szName == "CheckBox_C2" then
    	BigBagPanel.aOpen[2] = false
    	BigBagPanel.Update(frame)
    	BigBagPanel.Anchor = GetFrameAnchor(frame)
    elseif szName == "CheckBox_C3" then
    	BigBagPanel.aOpen[3] = false
    	BigBagPanel.Update(frame)
    	BigBagPanel.Anchor = GetFrameAnchor(frame)
    elseif szName == "CheckBox_C4" then
    	BigBagPanel.aOpen[4] = false
    	BigBagPanel.Update(frame)
    	BigBagPanel.Anchor = GetFrameAnchor(frame)
    elseif szName == "CheckBox_C5" then
    	BigBagPanel.aOpen[5] = false
    	BigBagPanel.Update(frame)
    	BigBagPanel.Anchor = GetFrameAnchor(frame)
    elseif szName == "CheckBox_Compact" then
    	SetUseCompactBagPanel(true)
    end	
end

function BigBagPanel.OnCheckBoxUncheck()
	local frame = this:GetRoot()
	if frame.bDisable then
		return
	end
	local szName = this:GetName()
    if szName == "CheckBox_C1" then
    	BigBagPanel.aOpen[1] = true
    	BigBagPanel.Update(frame)
    	BigBagPanel.Anchor = GetFrameAnchor(frame)
    elseif szName == "CheckBox_C2" then
    	BigBagPanel.aOpen[2] = true
    	BigBagPanel.Update(frame)
    	BigBagPanel.Anchor = GetFrameAnchor(frame)
    elseif szName == "CheckBox_C3" then
    	BigBagPanel.aOpen[3] = true
    	BigBagPanel.Update(frame)
    	BigBagPanel.Anchor = GetFrameAnchor(frame)
    elseif szName == "CheckBox_C4" then
    	BigBagPanel.aOpen[4] = true
    	BigBagPanel.Update(frame)
    	BigBagPanel.Anchor = GetFrameAnchor(frame)
    elseif szName == "CheckBox_C5" then
    	BigBagPanel.aOpen[5] = true
    	BigBagPanel.Update(frame)
    	BigBagPanel.Anchor = GetFrameAnchor(frame)
    elseif szName == "CheckBox_Compact" then
    	SetUseCompactBagPanel(false)
    end
end

function BigBagPanel.IsBagPanelFull()--背包位满
	
	local nBag = 0
	for i = 1, BigBagPanel.nCount do
		local nIndex = BigBagPanel.BagIndexToInventoryIndex(i)
		local dwSize = GetClientPlayer().GetBoxSize(nIndex)
		if dwSize and dwSize ~= 0 then
			nBag = nBag + 1
		end
    end
    if nBag == BigBagPanel.nCount then
    	return true
    else
    	return false
    end
end
function BigBagPanel_GetItemBox(dwBox, dwX, bEvenUnVisible)
	local frame = Station.Lookup("Normal/BigBagPanel")
	if frame and (frame:IsVisible() or bEvenUnVisible) then
		if dwBox == INVENTORY_INDEX.EQUIP then
			return frame:Lookup("", "Box_Bag"..(dwX - EQUIPMENT_INVENTORY.PACKAGE1 + 2))
		else
			return frame:Lookup("", "Handle_Box/"..dwBox.."_"..dwX)
		end
	end	
end

function OpenBigBagPanel(bDisableSound)
	if IsBigBagPanelOpened() then
		return
	end
	local frame = Station.Lookup("Normal/BigBagPanel")
	if not frame then
		frame = Wnd.OpenWindow("BigBagPanel")
		BigBagPanel.Update(frame)
		BigBagPanel.UpdateMoney(frame)
		
		local thisSave = this
		this = frame
		BigBagPanel.OnEvent("UI_SCALED")
		this = thisSave
	end
    UpdatePlayerInfo(frame)
    
	frame:Show()
	frame:BringToTop()
	UserSelect.RefreshSelectedBox()
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
end

function IsBigBagPanelOpened()
	local frame = Station.Lookup("Normal/BigBagPanel")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end

function CloseBigBagPanel(bDisableSound)
	if not IsBigBagPanelOpened() then
		return
	end
	local frame = Station.Lookup("Normal/BigBagPanel")
	frame:Hide()
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end
end

function SetShowBagSize(bShow)
	if BigBagPanel.bShowSize == bShow then
		return
	end
	
	BigBagPanel.bShowSize = bShow
	FireEvent("ON_SET_SHOW_BAG_SIZE")
end

function IsShowBagSize()
	return BigBagPanel.bShowSize
end

function SetUseBigBagPanel(bUse)
	if BigBagPanel.bUseBigBagPanel == bUse then
		return
	end
	
	BigBagPanel.bUseBigBagPanel = bUse
	
	FireEvent("ON_SET_USE_BIGBAGPANEL")
end

function IsUseBigBagPanel()
	return BigBagPanel.bUseBigBagPanel
end

function SetUseCompactBagPanel(bUse)
	if BigBagPanel.bCompact == bUse then
		return
	end
	
	BigBagPanel.bCompact = bUse
	FireEvent("ON_SET_BAG_COMPACT_MODE")
end

function IsUseCompactBagPanel()
	return BigBagPanel.bCompact
end

function OpenBagPanel(nIndex, bDisableSound, bDisableAdjPos)
	if IsUseBigBagPanel() then
		return OpenBigBagPanel(bDisableSound)
	else
		return OpenNormalBagPanel(nIndex, bDisableSound, bDisableAdjPos)
	end
end

function CloseBagPanel(nIndex, bDisableSound, bDisableAdjPos)
	if IsUseBigBagPanel() then
		return CloseBigBagPanel(bDisableSound)
	else
		return CloseNormalBagPanel(nIndex, bDisableSound, bDisableAdjPos)
	end
end

function IsBagPanelOpened(i)
	if IsUseBigBagPanel() then
		return IsBigBagPanelOpened(i)
	else
		return IsNormalBagPanelOpened(i)
	end
end

function OpenAllBagPanel(bDisableSound)
	if IsUseBigBagPanel() then
		return OpenBigBagPanel(bDisableSound)
	else
		return OpenAllNormalBagPanel(bDisableSound)
	end
end

function CloseAllBagPanel(bDisableSound)
	if IsUseBigBagPanel() then
		return CloseBigBagPanel(bDisableSound)
	else
		return CloseAllNormalBagPanel(bDisableSound)
	end
end

function IsAllBagPanelOpened()
	if IsUseBigBagPanel() then
		return IsBigBagPanelOpened()
	else
		return IsAllNormalBagPanelOpened()
	end
end

function IsAllBagPanelClosed()
	if IsUseBigBagPanel() then
		return not IsBigBagPanelOpened()
	else
		return IsAllNormalBagPanelClosed()
	end
end

function BagPanel_GetItemBox(dwBox, dwX, bEvenUnVisible)
	if IsUseBigBagPanel() then
		return BigBagPanel_GetItemBox(dwBox, dwX, bEvenUnVisible)
	else
		return NormalBagPanel_GetItemBox(dwBox, dwX, bEvenUnVisible)
	end	
end

function Bag_GetItemBox(dwBox, dwX, bEvenUnVisible)
	if IsUseBigBagPanel() then
		return BigBagPanel_GetItemBox(dwBox, dwX, bEvenUnVisible)
	else
		return NormalBag_GetItemBox(dwBox, dwX, bEvenUnVisible)
	end	
end

function GetBagSortFunc(aBagOrder)
	local player = GetClientPlayer()
	local aC = {3, 2, 4, 1}
	local fnSortBag = function(a, b)
		local cA = GetBagContainType(a)
		local cB = GetBagContainType(b)
		if cA == cB then
			return a < b
		end
		local nA = aC[cA] or 0
		local nB = aC[cB] or 0
		return nA > nB
	end
	table.sort(aBagOrder, fnSortBag)

	local aGenre = 
	{
		[ITEM_GENRE.TASK_ITEM] = 1, 
		[ITEM_GENRE.EQUIPMENT] = 2, 
		[ITEM_GENRE.BOOK] = 3, 
		[ITEM_GENRE.POTION] = 4, 
		[ITEM_GENRE.MATERIAL] = 5
	}
	local aSub = 
	{
		[EQUIPMENT_SUB.HORSE] = 1, 
		[EQUIPMENT_SUB.PACKAGE] = 2, 
		[EQUIPMENT_SUB.MELEE_WEAPON] = 3, 
		[EQUIPMENT_SUB.RANGE_WEAPON] = 4, 
	}
		
	local nBagIndex, nIndex, bFinish, nResultIndex, aChange, aResult = 1, 0, false, 1, {}, {}
	local fnSortItemFunc = function()
		local player = GetClientPlayer()
		if bFinish then
			local a = aResult[nResultIndex]
			if a then
				OnExchangeItem(a[1], a[2], a[3], a[4])
				nResultIndex = nResultIndex + 1
			else
				return true, true
			end
			return true
		end
		local dwBox = aBagOrder[nBagIndex]
		if not dwBox then
			bFinish = true
			return true
		end
		
		local cType = GetBagContainType(dwBox)
		local dwSize = player.GetBoxSize(dwBox)
		if not dwSize or dwSize == 0 or nIndex >= dwSize then
			nBagIndex = nBagIndex + 1
			nIndex = 0
			return
		end
		
		local dwTBox, dwTX, itemT = nil, nil, nil
		for i = nBagIndex, #aBagOrder, 1 do
			local dwBoxL = aBagOrder[i]
			local dwSizeL = player.GetBoxSize(dwBoxL) - 1
			local jS = 0
			if i == nBagIndex then
				jS = nIndex
			end
			for j = jS, dwSizeL, 1 do
				local item, aC = nil, aChange[dwBoxL.."_"..j]
				if aC then
					item = GetPlayerItem(player, aC[1], aC[2])
				else
					item = GetPlayerItem(player, dwBoxL, j)
				end
				if item then
					local bChange = false
					if cType ~= 0 then
						if cType == item.nSub then
							if item.nGenre == ITEM_GENRE.MATERIAL then
								bChange = not itemT or (item.nQuality > itemT.nQuality or 
									(item.nQuality == itemT.nQuality and (item.dwTabType < itemT.dwTabType or 
									(item.dwTabType == itemT.dwTabType and item.dwIndex < itemT.dwIndex))))
							elseif item.nGenre == ITEM_GENRE.BOOK then
								bChange = not itemT or (item.nQuality > itemT.nQuality or 
									(item.nQuality == itemT.nQuality and (item.dwTabType < itemT.dwTabType or 
									(item.dwTabType == itemT.dwTabType and (item.dwIndex < itemT.dwIndex or 
									(item.dwIndex == itemT.dwIndex and item.nBookID < itemT.nBookID))))))
							end
						end
					else
						if itemT then
							local nG, nGT = aGenre[item.nGenre] or (100 + item.nGenre), aGenre[itemT.nGenre] or (100 + itemT.nGenre)
							if nG < nGT then
								bChange = true
							elseif nG == nGT then
								local bCommon = false
								if itemT.nGenre == ITEM_GENRE.EQUIPMENT then
									local nS, nST = aSub[item.nSub] or (100 + item.nSub), aSub[itemT.nSub] or (100 + itemT.nSub)
									if nS < nST then
										bChange = true
									elseif nS == nST then
										if itemT.nSub == EQUIPMENT_SUB.MELEE_WEAPON or itemT.nSub == EQUIPMENT_SUB.RANGE_WEAPON then
											if item.nDetail < itemT.nDetail then
												bChange = true
											elseif item.nDetail == itemT.nDetail then
												bCommon = true
											end
										elseif itemT.nSub == EQUIPMENT_SUB.PACKAGE then
											if item.nCurrentDurability > itemT.nCurrentDurability then
												bChange = true
											elseif item.nCurrentDurability == itemT.nCurrentDurability then
												bCommon = true
											end
										else
											bCommon = true
										end
									end
								else
									bCommon = true
								end
								if bCommon then
									bChange = (item.nQuality > itemT.nQuality or 
										(item.nQuality == itemT.nQuality and (item.dwTabType < itemT.dwTabType or 
										(item.dwTabType == itemT.dwTabType and item.dwIndex < itemT.dwIndex))))									
								end
							end
						else
							bChange = true
						end
					end
					if bChange then
						dwTBox, dwTX, itemT = dwBoxL, j, item
					end					
				end
			end
		end
		if itemT then
			if dwBox ~= dwTBox or nIndex ~= dwTX then
				if aChange[dwBox.."_"..nIndex] then
					aChange[dwTBox.."_"..dwTX] = aChange[dwBox.."_"..nIndex]
				else
					aChange[dwTBox.."_"..dwTX] = {dwBox, nIndex}
				end
				table.insert(aResult, {dwTBox, dwTX, dwBox, nIndex})
			end
			nIndex = nIndex + 1
			if nIndex >= dwSize then
				nBagIndex = nBagIndex + 1
				nIndex = 0
			end
		else
			if cType == 0 then
				bFinish = true
				return true
			else
				nBagIndex = nBagIndex + 1
				nIndex = 0
			end
		end
	end
	return fnSortItemFunc
end

function IsBagInSort()
	if IsBagPanelOpened() and BigBagPanel.fnSortItemFunc then
		return true
	end
	return false
end

function IsBigBagFull()--背包满
   local player = GetClientPlayer()
   local nFreeSize = 0
   local bFull = false
   for i = 1, BigBagPanel.nCount do
		local nIndex = BigBagPanel.BagIndexToInventoryIndex(i)
		local nBoxSize = player.GetBoxSize(nIndex)
		if nBoxSize and nBoxSize ~= 0 then
			local nBoxFreeSize = player.GetBoxFreeRoomSize(nIndex)
			nFreeSize = nFreeSize + nBoxFreeSize
		end
    end
    if nFreeSize == 0 then
        bFull = true
    end
    return bFull
end

function Bag_GetFreeBox()
	local player = GetClientPlayer()
	for i = 1, BigBagPanel.nCount do
		local nIndex = BigBagPanel.BagIndexToInventoryIndex(i)
		local nBoxSize = player.GetBoxFreeRoomSize(nIndex)
		if nBoxSize and nBoxSize ~= 0 then
			local dwX = player.GetFreeRoom(nIndex)
			if dwX then
				return nIndex, dwX
			end
		end
    end
end