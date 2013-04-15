Bag = 
{
	szSortType = "right_to_left",
	bShowBg = true,
	MAX_BAG_COUNT = 5,
	DefaultAnchor = {s = "BOTTOMRIGHT", r = "BOTTOMRIGHT",  x = -300, y = -76},
	Anchor = {s = "BOTTOMRIGHT", r = "BOTTOMRIGHT", x = -300, y = -76},
}

RegisterCustomData("Bag.Anchor")
RegisterCustomData("Bag.bShowBg")
RegisterCustomData("Bag.szSortType")

function Bag.OnFrameCreate()
	this:RegisterEvent("EQUIP_ITEM_UPDATE")
	this:RegisterEvent("SYNC_ROLE_DATA_END")
	this:RegisterEvent("BAG_ITEM_UPDATE")
	this:RegisterEvent("ON_OPEN_BAG_PANEL")
	this:RegisterEvent("ON_CLOSE_BAG_PANEL")
	this:RegisterEvent("ON_SET_SHOW_BAG_SIZE")
	this:RegisterEvent("HAND_PICK_OBJECT")
	this:RegisterEvent("ON_SET_USE_BIGBAGPANEL")
	this:RegisterEvent("SET_BAG_SORT_TYPE")
	this:RegisterEvent("SET_BAG_SHOW_BG")
	
	this:RegisterEvent("UI_SCALED")
	this:RegisterEvent("ON_ENTER_CUSTOM_UI_MODE")
	this:RegisterEvent("ON_LEAVE_CUSTOM_UI_MODE")
	this:RegisterEvent("BAG_ANCHOR_CHANGED")
	this:RegisterEvent("CUSTOM_DATA_LOADED")
	
	Bag.UpdateBag(this)
	
	Bag.UpdateAnchor(this)
	UpdateCustomModeWindow(this, g_tStrings.BAG)
end

function Bag.OnFrameDrag()
end

function Bag.OnFrameDragSetPosEnd()
end

function Bag.OnFrameDragEnd()
	this:CorrectPos()
	Bag.Anchor = GetFrameAnchor(this)
end

function Bag.UpdateAnchor(frame)
	frame:SetPoint(Bag.Anchor.s, 0, 0, Bag.Anchor.r, Bag.Anchor.x, Bag.Anchor.y)
	frame:CorrectPos()
end

function Bag.UpdateSort(frame)
	local handle = frame:Lookup("", "")
	local bV = false
	if Bag.szSortType == "top_to_bottom" then
		for i = 1, Bag.MAX_BAG_COUNT, 1 do
			local img = handle:Lookup("Image_Bg"..i)
			local box = handle:Lookup("Bag"..i)
			local x, y = 0, (i - 1) * 50
			img:SetRelPos(x, y)
			box:SetRelPos(x, y)
		end
		bV = true
	elseif Bag.szSortType == "bottom_to_top" then
		for i = 1, Bag.MAX_BAG_COUNT, 1 do
			local img = handle:Lookup("Image_Bg"..i)
			local box = handle:Lookup("Bag"..i)
			local x, y = 0, (Bag.MAX_BAG_COUNT - i) * 50
			img:SetRelPos(x, y)
			box:SetRelPos(x, y)
		end
		bV = true
	elseif Bag.szSortType == "left_to_right" then
		for i = 1, Bag.MAX_BAG_COUNT, 1 do
			local img = handle:Lookup("Image_Bg"..i)
			local box = handle:Lookup("Bag"..i)
			local x, y = (i - 1) * 50, 0
			img:SetRelPos(x, y)
			box:SetRelPos(x, y)
		end
	else
		for i = 1, Bag.MAX_BAG_COUNT, 1 do
			local img = handle:Lookup("Image_Bg"..i)
			local box = handle:Lookup("Bag"..i)
			local x, y = (Bag.MAX_BAG_COUNT - i) * 50, 0
			img:SetRelPos(x, y)
			box:SetRelPos(x, y)
		end
	end
	handle:FormatAllItemPos()
	local w, h = handle:GetAllItemSize()
	if bV then
		h = h + 2
	else
		w = w + 2
	end
	handle:SetSize(w, h)
	frame:SetSize(w, h)
	
	Bag.UpdateAnchor(frame)
end

function Bag.UpdateBag(frame)
    local handle = frame:Lookup("", "")
    local player = GetClientPlayer()
    Bag.UpdateSort(frame)
	for i = 1, Bag.MAX_BAG_COUNT, 1 do
		local box = handle:Lookup("Bag"..i)
		box:SetUserData(i)
		box:SetOverTextPosition(0, ITEM_POSITION.RIGHT_BOTTOM)
		box:SetOverTextFontScheme(0, 15)
		box.nInventoryIndex = INVENTORY_INDEX.PACKAGE + i - 1
        if i == 1 then
        	box:SetBoxIndex(-1)
            box:SetObject(UI_OBJECT_NOT_NEED_KNOWN, i)
            box:SetObjectIcon(374)
        else
        	local nBagIndex = EQUIPMENT_INVENTORY.PACKAGE1 + i - 2
        	box:SetBoxIndex(nBagIndex)
	
			local item = GetPlayerItem(player, INVENTORY_INDEX.EQUIP, nBagIndex)
			UpdataItemBoxObject(box, INVENTORY_INDEX.EQUIP, nBagIndex, item)
        end
        Bag.UpdateBagSize(box)
	end
	Bag.UpdateBgShow(frame)
end

-------左键操作-------
function Bag.OnItemLButtonDown()
	this:SetObjectPressed(1)
end

function Bag.OnItemLButtonUp(szSelfName)
	this:SetObjectPressed(0)
end

function Bag.OnItemLButtonDrag(szSelfName)
	this:SetObjectPressed(0)
	
	if this:GetBoxIndex() == -1 then
		--如果是固定不变的那个背包。
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_ERROR_CANNOT_DRAG_BAG)
		PlayTipSound("007")
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
end;

function Bag.OnItemLButtonDragEnd()
	if not Hand_IsEmpty() then
		Bag.DropHandObject(this)
	end	
end

function Bag.OnItemLButtonClick()
	if not Hand_IsEmpty() then
		--如果手上有东西
		Bag.DropHandObject(this)
	else
		if IsShiftKeyDown() then
			if IsAllBagPanelOpened() then
				CloseAllBagPanel()
			else
				OpenAllBagPanel()
			end
			return
		end
		
		if not this:IsEmpty() then
			if IsBagPanelOpened(this:GetUserData()) then
				CloseBagPanel(this:GetUserData())
			else
				OpenBagPanel(this:GetUserData())
			end	
		end
	end
end

function Bag.OnItemLButtonDBClick()
	Bag.OnItemLButtonClick()
end

function Bag.UpdateBagSize(box)
	if IsShowBagSize() then
		local player = GetClientPlayer()
		if not player then
			return
		end
		local dwSize = player.GetBoxSize(box.nInventoryIndex)
		local dwSizeFree = player.GetBoxFreeRoomSize(box.nInventoryIndex)
		if not dwSize or dwSize == 0 then
			box:SetOverText(0, "")
		else
			box:SetOverText(0, (dwSize - dwSizeFree).."/"..dwSize)
		end
	else
		box:SetOverText(0, "")
	end
end

function Bag.UpdateBgShow(frame)
	local handle = frame:Lookup("", "")
	local bShow = Bag.bShowBg
	if not Hand_IsEmpty() or not IsAllBagPanelClosed() then
		bShow = true
	end
	
	frame:SetSizeWithAllChild(not bShow)	
	if bShow then
		local nCount = handle:GetItemCount() - 1
		for i = 0, nCount, 1 do
			handle:Lookup(i):Show()
		end
	else
		for i = 1, Bag.MAX_BAG_COUNT, 1 do
			local box = handle:Lookup("Bag"..i)
			local img = handle:Lookup("Image_Bg"..i)
			if box:IsEmpty() then
				box:Hide()
			else
				box:Show()
			end
			img:Hide()
		end	
	end		
end

function Bag.DropHandObject(box)
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
	local dwBox2 = INVENTORY_INDEX.EQUIP
	local dwX2 = box:GetBoxIndex()
	if dwX2 == -1 then
		dwBox2 = INVENTORY_INDEX.PACKAGE
		dwX2 = GetClientPlayer().GetFreeRoom(dwBox2)
		if not dwX2 then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_ERROR_BAG_IS_FULL)
			PlayTipSound("006")
			return
		end
	end
	
	if OnExchangeItem(dwBox1, dwX1, dwBox2, dwX2, nHandCount) then
		Hand_Clear()
	end
end

function Bag.OnItemMouseEnter()
    this:SetObjectMouseOver(1)
	if not this:IsEmpty() then
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
		if this:GetBoxIndex() == -1 then
			local player = GetClientPlayer()
			local szTip = "<text>text="..EncodeComponentsString(g_tStrings.BAG2).." font=60 "..GetItemFontColorByQuality(1, true)..
			" </text><text>text="..EncodeComponentsString(g_tStrings.PACKAGE).." font=106 </text><text>text="
				..EncodeComponentsString(FormatString(g_tStrings.STR_ITEM_H_BAG_SIZE, player.GetBoxSize(this.nInventoryIndex))).."font=106</text>"
			OutputTip(szTip, 335, {x, y, w, h, 1})
		else
			local _, dwBox, dwX = this:GetObjectData()
			OutputItemTip(UI_OBJECT_ITEM, dwBox, dwX, nil, {x, y, w, h, 1})
		end
	end
end

function Bag.OnItemRefreshTip()
	return Bag.OnItemMouseEnter()
end

function Bag.OnItemMouseLeave()
    HideTip()
	this:SetObjectMouseOver(0)
end

function Bag.OnEvent(event)
	if event == "BAG_ITEM_UPDATE" then
	    local box = this:Lookup("", "Bag"..(arg0 - INVENTORY_INDEX.PACKAGE + 1))
	    if box then
	    	Bag.UpdateBagSize(box)
	    end
	elseif event == "EQUIP_ITEM_UPDATE" then
		if arg0 ~= INVENTORY_INDEX.EQUIP then
			return
		end    	
		if arg1 < EQUIPMENT_INVENTORY.PACKAGE1 or arg1 > EQUIPMENT_INVENTORY.PACKAGE4 then
			return
		end
		
	    local player = GetClientPlayer()
	    
	    local nBagIndex = arg1 - EQUIPMENT_INVENTORY.PACKAGE1 + 2
	        
	    local box = this:Lookup("", "Bag"..nBagIndex)
	    if not box then
	        return
	    end 
	    
	    local item = GetPlayerItem(player, INVENTORY_INDEX.EQUIP, arg1)
		if IsBagPanelOpened(nBagIndex) then
			CloseBagPanel(nBagIndex)
		end
		UpdataItemBoxObject(box, INVENTORY_INDEX.EQUIP, arg1, item)
		Bag.UpdateBagSize(box)
		
		Bag.UpdateBgShow(this)
	elseif event == "SYNC_ROLE_DATA_END" then
		Bag.UpdateBag(this)
	elseif event == "ON_OPEN_BAG_PANEL" then
		local box = this:Lookup("", "Bag"..arg0)
		if box and not box:IsEmpty() then
			box:SetObjectSelected(true)
		end
		Bag.UpdateBgShow(this)
	elseif event == "ON_CLOSE_BAG_PANEL" then
		local box = this:Lookup("", "Bag"..arg0)
		if box and not box:IsEmpty() then
			box:SetObjectSelected(false)
		end
		Bag.UpdateBgShow(this)
	elseif event == "ON_SET_SHOW_BAG_SIZE" then
	    local handle = this:Lookup("", "")
		for i = 1, Bag.MAX_BAG_COUNT, 1 do
			local box = handle:Lookup("Bag"..i)	
		    if box then
		    	Bag.UpdateBagSize(box)
		    end
		end
	elseif event == "HAND_PICK_OBJECT" then
		Bag.UpdateBgShow(this)
	elseif event == "ON_SET_USE_BIGBAGPANEL" then
		if IsUseBigBagPanel() then
			CloseBagList(this)
		end
	elseif event == "SET_BAG_SORT_TYPE" then
		Bag.UpdateSort(this)
	elseif event == "SET_BAG_SHOW_BG" then
		Bag.UpdateBgShow(this)
	elseif event == "UI_SCALED" then
		Bag.UpdateAnchor(this)
	elseif event == "ON_ENTER_CUSTOM_UI_MODE" or event == "ON_LEAVE_CUSTOM_UI_MODE" then
		UpdateCustomModeWindow(this)
	elseif event == "BAG_ANCHOR_CHANGED" then
		Bag.UpdateAnchor(this)		
	elseif event == "CUSTOM_DATA_LOADED" then
		Bag.UpdateSort(this)
		Bag.UpdateBgShow(this)
		Bag.UpdateAnchor(this)
	end
end

---------------------插件重新实现方法:--------------------------------
--1, Wnd.CloseWindow("Bag")
--2, Bag = nil
--3, 重载下面函数
----------------------------------------------------------------------

function Bag_GetBagFrame()
	return Station.Lookup("Normal/Bag")
end

function NormalBag_GetItemBox(dwBox, dwX, bEvenUnVisible)
	if dwBox == INVENTORY_INDEX.EQUIP and dwX >= EQUIPMENT_INVENTORY.PACKAGE1 and dwX <= EQUIPMENT_INVENTORY.PACKAGE4 then
		local frame =Station.Lookup("Normal/Bag")
		if frame and (frame:IsVisible() or bEvenUnVisible) then
			return frame:Lookup("", "Bag"..(dwX - EQUIPMENT_INVENTORY.PACKAGE1 + 2))
		end
	end
	return nil
end

function OpenBagList()
	local frame = Wnd.OpenWindow("Bag")
	Bag.UpdateBag(frame)
end

function IsBagListOpened()
	local frame =Station.Lookup("Normal/Bag")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end

function CloseBagList()
	Wnd.CloseWindow("Bag")
end

function GetBagRect()
	local frame =Station.Lookup("Normal/Bag")
	if frame and frame:IsVisible() then
		local x, y = frame:GetAbsPos()
		local w, h = frame:GetSize()
		return {x, y, x + w, y + h}		
	end
	local w, h = Station.GetClientSize()
	return {w, h, w, h}
end

function SetBagSortType(szType)
	if Bag.szSortType == szType then
		return
	end
	
	Bag.szSortType = szType
	
	FireEvent("SET_BAG_SORT_TYPE")
end

function GetBagSortType(szType)
	return Bag.szSortType
end

function SetBagShowBg(bShow)
	if Bag.bShowBg == bShow then
		return
	end
	
	Bag.bShowBg = bShow
	
	FireEvent("SET_BAG_SHOW_BG")
end

function IsBagShowBg(bShow)
	return Bag.bShowBg
end

function SetBagAnchor(Anchor)
	Bag.Anchor = Anchor
	
	FireEvent("BAG_ANCHOR_CHANGED")
end

function GetBagAnchor()
	return Bag.Anchor
end

function Bag_SetAnchorDefault()
	Bag.Anchor.s = Bag.DefaultAnchor.s
	Bag.Anchor.r = Bag.DefaultAnchor.r
	Bag.Anchor.x = Bag.DefaultAnchor.x
	Bag.Anchor.y = Bag.DefaultAnchor.y
	FireEvent("BAG_ANCHOR_CHANGED")
end

RegisterEvent("CUSTOM_UI_MODE_SET_DEFAULT", Bag_SetAnchorDefault)

function LoadBagSetting()
	local szIniFile = GetUserDataPath()
	if szIniFile == "" then
		return
	end
	szIniFile = szIniFile.."\\PannelSave.ini"

	local iniS = Ini.Open(szIniFile)
	if not iniS then
		return
	end
	
	local szSection = "Bag"	
	
	local value = iniS:ReadInteger(szSection, "ShowBg", 1)
	if not value or value ~= 0 then
		SetBagShowBg(true)
	else
		SetBagShowBg(false)
	end

	local value = iniS:ReadString(szSection, "Sort", Bag.szSortType)
	if value then
		SetBagSortType(value)
	end

	local Anchor = {s = Bag.Anchor.s, r = Bag.Anchor.r, x = Bag.Anchor.x, y = Bag.Anchor.y}
	local value = iniS:ReadString(szSection, "SelfSide", Bag.Anchor.s)
	if value then
		Anchor.s = value
	end
	value = iniS:ReadString(szSection, "RelSide", Bag.Anchor.r)
	if value then
		Anchor.r = value
	end
	value = iniS:ReadInteger(szSection, "RelX", Bag.Anchor.x)
	if value then
		Anchor.x = value
	end
	value = iniS:ReadInteger(szSection, "RelY", Bag.Anchor.y)
	if value then
		Anchor.y = value
	end
	
	SetBagAnchor(Anchor)
	
	iniS:Close()
end

RegisterLoadFunction(LoadBagSetting)

