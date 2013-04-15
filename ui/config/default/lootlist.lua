LootList = { bNearMouse = true}

RegisterCustomData("LootList.bRButtonPickupAll")
RegisterCustomData("LootList.bNearMouse")

function LootList.OnFrameCreate()
    this:RegisterEvent("SYNC_LOOT_LIST")
    this:RegisterEvent("CLOSE_DOODAD")
    this:RegisterEvent("UI_SCALED")
    
    this:Lookup("", "Handle_LootList"):Clear()
    
    if not LootList.bNearMouse then
    	InitFrameAutoPosInfo(this, 1, nil, nil, function() CloseLootList(true) end)
    end
end

function LootList.OnFrameBreathe()
	local player = GetClientPlayer()
	if not player then
		CloseLootList()
		return
	end
	local doodad = GetDoodad(LootList.dwDoodadID)
	if not doodad or not doodad.CanDialog(player) then
		CloseLootList()
		return
	end
	
	local handle = this:Lookup("", "Handle_LootList")
	if handle:GetItemCount() == 0 then
		CloseLootList()
		return
	end
end

function LootList.OnEvent(event)
	if event == "SYNC_LOOT_LIST" then
		if LootList.dwDoodadID == arg0 then
			LootList.UpdateRootList(this)
		end
	elseif event == "CLOSE_DOODAD" then
		CloseLootList()
	elseif event == "UI_SCALED" then
		if LootList.bNearMouse then
			this:CorrectPos()
		end
	end
end

function LootList.AutoPickup(frame)
	local handle = frame:Lookup("", "Handle_LootList")
	local nCount = handle:GetItemCount() - 1
	for i = 0, nCount, 1 do
		local hI = handle:Lookup(i)
		if hI:IsVisible() then
			if hI.bMoney then
				LootMoney(LootList.dwDoodadID)
				PlaySound(SOUND.UI_SOUND, g_sound.PickupMoney)
			else
				if not hI.bNeedDistribute and not hI.bNeedRoll then
					LootItem(LootList.dwDoodadID, hI.dwID)
					PlayItemSound(hI.nUiId, true)
				end
			end
		end
	end
end

function LootList.UpdateRootList(frame)
    local player = GetClientPlayer()
    local doodad = GetDoodad(LootList.dwDoodadID)
	local handle = frame:Lookup("", "Handle_LootList")
	handle:Clear()
        
    local szIniFile = "UI/Config/Default/LootList.ini"
    local nMoney = doodad.GetLootMoney()
	if nMoney > 0 then
    	local hM = handle:AppendItemFromIni(szIniFile, "Handle_Money")
        hM.bMoney = true
		LootList.UpdateMoneyShow(hM, nMoney)
		hM:SetUserData(0)
		hM:Show()
		local hBoxMoney = hM:Lookup("Box_Money")
	end
	
    for i = 0, LOOT_ITEM.MAX_LOOT_SIZE - 1 do
        local item, bNeedRoll, bNeedDistribute = doodad.GetLootItem(i, player)
        if item then --(item.nMaxExistAmount == 0 or player.GetItemAmountInAllPackages(item.dwTabType, item.dwIndex) < item.nMaxExistAmount) then
        	local hI = handle:AppendItemFromIni(szIniFile, "Handle_Item")
            hI.bNeedRoll = bNeedRoll
            hI.bNeedDistribute = bNeedDistribute
            hI.dwID = item.dwID
            hI.nLootIndex = i
            hI.nUiId = item.nUiId
            if item.nGenre == ITEM_GENRE.TASK_ITEM then
            	hI:SetUserData(1 + item.nQuality)
            else
            	hI:SetUserData(100 + item.nQuality)
            end
            
            local text = hI:Lookup("Text_Item")
            text:SetText(GetItemNameByItem(item))
            text:SetFontColor(GetItemFontColorByQuality(item.nQuality, false))
            
            local box = hI:Lookup("Box_Item")
			box:SetObject(UI_OBJECT_ITEM_ONLY_ID, item.nUiId, item.dwID, item.nVersion, item.dwTabType, item.dwIndex)
			box:SetObjectIcon(Table_GetItemIconID(item.nUiId))
			UpdateItemBoxExtend(box, item)
			
			box:SetOverTextPosition(0, ITEM_POSITION.RIGHT_BOTTOM)
			box:SetOverTextFontScheme(0, 15)
			
			if item and item.bCanStack and item.nStackNum > 1 then
				box:SetOverText(0, item.nStackNum)
			else
				box:SetOverText(0, "")
			end
			
			hI:Show()
		end
    end
    
    if handle:GetItemCount() > 0 then
	    handle:Sort()
	    handle:FormatAllItemPos()
    	LootList.UpdateScrollInfo(frame)	    
    else
    	CloseLootList(true)
    end
end

function LootList.UpdateMoneyShow(handle, nMoney)
    local nGold, nSilver, nCopper = MoneyToGoldSilverAndCopper(nMoney)
    
    local textG = handle:Lookup("Text_Gold")
    local textS = handle:Lookup("Text_Silver")
    local textC = handle:Lookup("Text_Copper")
    local imageG = handle:Lookup("Image_Gold")
    local imageS = handle:Lookup("Image_Silver")
    local imageC = handle:Lookup("Image_Copper")
    local imageB = handle:Lookup("Image_MoneyBg")
    
    textG:SetText(nGold)
    textS:SetText(nSilver)
    textC:SetText(nCopper)
    imageG:Show()
    imageS:Show()
    imageC:Show()
    imageB:Show()
    if nGold == 0 then
    	textG:SetText("")
    	imageG:Hide()
    	if nSilver == 0 then
    		textS:SetText("")
    		imageS:Hide()
    	end
    end
    
    local boxMoney = handle:Lookup("Box_Money")
	if nGold ~= 0 then
		boxMoney:SetObject(UI_OBJECT_NOT_NEED_KNOWN, 0)
		if nGold <= 10 then
		  boxMoney:SetObjectIcon(95) --金的图标
		else
		  boxMoney:SetObjectIcon(94) --金的图标
		end
	elseif nSilver ~= 0 then
		boxMoney:SetObject(UI_OBJECT_NOT_NEED_KNOWN, 1)
		if nSilver <= 10 then
		  boxMoney:SetObjectIcon(97) --银的图标
		else
		  boxMoney:SetObjectIcon(96) --银的图标
		end
    else
		boxMoney:SetObject(UI_OBJECT_NOT_NEED_KNOWN, 2)
	  if nCopper <= 10 then
		  boxMoney:SetObjectIcon(99) --铜的图标
		else
		  boxMoney:SetObjectIcon(98) --铜的图标
		end 
    end
end

function LootList.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_Close" then
		CloseLootList()
	elseif szName == "Btn_Sure" then
		LootList.AutoPickup(this:GetRoot())
	end
end

function LootList.OnItemLButtonDown()
	if IsCtrlKeyDown() then
		if IsGMPanelReceiveItem() then
			GMPanel_LinkItem(this.dwID)
		else		
			EditBox_AppendLinkItem(this.dwID)
		end
		this.bIgnorClick = true
		return
	end
	this.bIgnorClick = false
end

function LootList.OnItemLButtonUp()
end

function LootList.OnItemLButtonClick()
    if this.nClickFrame and ((this.nClickFrame + GLOBAL.GAME_FPS) > GetLogicFrameCount()) then
        return
    end 
    
    this.nClickFrame = GetLogicFrameCount()
    
	if this.bIgnorClick then
		this.bIgnorClick = false
		return
	end
	
	if this.bMoney then
		LootMoney(LootList.dwDoodadID)
		PlaySound(SOUND.UI_SOUND, g_sound.PickupMoney)
		return
	end
	
    local doodad = GetDoodad(LootList.dwDoodadID);
    local player = GetClientPlayer()

	if this.bNeedDistribute then
			local dwBelongTeamID = doodad.GetBelongTeamID();
			local clientteam = GetClientTeam()
			
			if not clientteam then
			    	return
			end
			
			if dwBelongTeamID ~= clientteam.dwTeamID then
				OutputMessage("MSG_ANNOUNCE_RED",g_tStrings.ERROR_LOOT_DISTRIBUTE)
				return
			end
			
			local dwDistributerID = clientteam.GetAuthorityInfo(TEAM_AUTHORITY_TYPE.DISTRIBUTE)
			if dwDistributerID ~= player.dwID then
				OutputMessage("MSG_ANNOUNCE_RED",g_tStrings.ERROR_LOOT_DISTRIBUTE)  
				return
			end
			
			local aPartyMember = doodad.GetLooterList()
			if aPartyMember then
					local dwItemID = this.dwID
					local nLootIndex = this.nLootIndex
					local dwDoodadID = LootList.dwDoodadID
					local fAction = function(k)
						local doodad = GetDoodad(dwDoodadID)
						if doodad then
							local item = doodad.GetLootItem(nLootIndex, GetClientPlayer())
							if item and item.nQuality >= 3 then
								local msg = 
								{
									szMessage = FormatLinkString(
										g_tStrings.PARTY_DISTRIBUTE_ITEM_SURE, 
										"font=162", 
										GetFormatText("["..GetItemNameByItem(item).."]", "166"..GetItemFontColorByQuality(item.nQuality, true)),
										GetFormatText("["..k.szName.."]", 162)
										), 
									szName = "Distribute_Item_Sure"..dwItemID, 
									bRichText = true,
									{szOption = g_tStrings.STR_HOTKEY_SURE, 
									fnAutoClose = function() 
										if not IsLootListOpened() then
											return true
										end
										return false
									end,
									fnAction = function() 
										local doodad = GetDoodad(dwDoodadID)
										if doodad then
											doodad.DistributeItem(dwItemID, k.dwID)
										end
									end
									},
									{szOption = g_tStrings.STR_HOTKEY_CANCEL},
								}
								MessageBox(msg)	
							else
								doodad.DistributeItem(dwItemID, k.dwID)
							end
						end
					end
					local menu = {fnAction = fAction}
					for i, k in ipairs(aPartyMember) do
						table.insert(menu, {szOption = k.szName, UserData = k, bDisable = not(k.bOnlineFlag)})
					end
					PopupMenu(menu)	
			end
			return
	end
	
	if this.bNeedRoll then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.ERROR_LOOT_ROLL)  
		return
	end
	
	LootItem(LootList.dwDoodadID, this.dwID)
	PlayItemSound(this.nUiId, true)
end

function LootList.OnItemLButtonDBClick()
	LootList.OnItemLButtonClick()
end

function LootList.OnItemMouseEnter()
	local szName = this:GetName()
	if szName == "Box_Item" then
		this:SetObjectMouseOver(true)
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
		local _, dwID = this:GetObjectData()
		OutputItemTip(UI_OBJECT_ITEM_ONLY_ID, dwID, nil, nil, {x, y, w, h}, nil, "loot")				
		this:GetParent():Lookup("Image_ItemMO"):Show()
	elseif szName == "Box_Money" then
		this:SetObjectMouseOver(true)
		this:GetParent():Lookup("Image_MoneyMO"):Show()
	elseif szName == "Handle_Money" then
		this:Lookup("Image_MoneyMO"):Show()
	elseif szName == "Handle_Item" then
		this:Lookup("Image_ItemMO"):Show()
	end
end

function LootList.OnItemMouseLeave()
	local szName = this:GetName()
	if szName == "Box_Item" then
		HideTip()
		this:SetObjectMouseOver(false)
		local hP = this:GetParent()
		if hP then
			local img = hP:Lookup("Image_ItemMO")
			if img then
				img:Hide()
			end
		end
	elseif szName == "Box_Money" then
		this:SetObjectMouseOver(false)
		local hP = this:GetParent()
		if hP then
			local img = hP:Lookup("Image_MoneyMO")
			if img then
				img:Hide()
			end
		end
	elseif szName == "Handle_Item" then
		local img = this:Lookup("Image_ItemMO")
		if img then
			img:Hide()
		end
	elseif szName == "Handle_Money" then
		local img = this:Lookup("Image_MoneyMO")
		if img then
			img:Hide()
		end
	end
end

function LootList.OnLButtonHold()
	if this:GetName() == "Btn_Up" then
		this:GetParent():Lookup("Scroll_LootList"):ScrollPrev(1)
	elseif this:GetName() == "Btn_Down" then
		this:GetParent():Lookup("Scroll_LootList"):ScrollNext(1)
    end	
end

function LootList.OnLButtonDown()
	LootList.OnLButtonHold()
end

function LootList.OnItemMouseWheel()
	local nDistance = Station.GetMessageWheelDelta()
	this:GetRoot():Lookup("Scroll_LootList"):ScrollNext(nDistance)
	return true
end

function LootList.OnScrollBarPosChanged()
	local nCurrentValue = this:GetScrollPos()
	if nCurrentValue == 0 then
		this:GetParent():Lookup("Btn_Up"):Enable(0)
	else
		this:GetParent():Lookup("Btn_Up"):Enable(1)
	end	
	
	if nCurrentValue == this:GetStepCount() then
		this:GetParent():Lookup("Btn_Down"):Enable(0)
	else
		this:GetParent():Lookup("Btn_Down"):Enable(1)
	end	
	
	local handle = this:GetParent():Lookup("", "Handle_LootList")
	handle:SetItemStartRelPos(0, -nCurrentValue * 10)
end

function LootList.UpdateScrollInfo(frame)
	local handle = frame:Lookup("", "Handle_LootList")
	local wA, hA = handle:GetAllItemSize()
	local w, h = handle:GetSize()
	local nStep = (hA - h) / 10
	if nStep > 0 then
		frame:Lookup("Scroll_LootList"):Show()
		frame:Lookup("Btn_Up"):Show()
		frame:Lookup("Btn_Down"):Show()
	else
		frame:Lookup("Scroll_LootList"):Hide()
		frame:Lookup("Btn_Up"):Hide()
		frame:Lookup("Btn_Down"):Hide()
	end
	frame:Lookup("Scroll_LootList"):SetStepCount((hA - h) / 10)
	
end

function LootList_SetPickupAll(bAll)
	LootList.bPickupAll = bAll
end

function LootList_SetRButtonPickupAll(bAll)
	LootList.bRButtonPickupAll = bAll
end

function LootList_IsRButtonPickupAll()
	if LootList.bRButtonPickupAll then
		return true
	end
	return false
end

function LootList_SetOpenPosNearMouse(bNear)
	LootList.bNearMouse = bNear
end

function LootList_IsOpenPosNearMouse()
	if LootList.bNearMouse then
		return true
	end
	return false
end

function OpenLootList(dwDoodadID, bDisableSound)
	LootList.dwDoodadID = dwDoodadID
	local frame = Wnd.OpenWindow("LootList")
	if LootList.bNearMouse then
		frame:SetRelPos(Cursor.GetPos())
		frame:CorrectPos()
	end
	LootList.UpdateRootList(frame)
	local hBtnLootAll = frame:Lookup("Btn_Sure")
	if hBtnLootAll then
		FireHelpEvent("OnOpenpanel", "LOOT", hBtnLootAll)
	end
	if LootList.bPickupAll and IsLootListOpened() then
		LootList.AutoPickup(frame)
	end
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end	
end

function IsLootListOpened()
	local frame = Station.Lookup("Normal/LootList")
	if frame and frame:IsVisible() then
		return true
	end
end

function CloseLootList(bDisableSound)
	GetClientPlayer().OnCloseLootWindow();
    Wnd.CloseWindow("LootList");	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end
end
