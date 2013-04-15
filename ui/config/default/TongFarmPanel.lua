local TONG_FARM_MATURE = 100

TongFarmPanel = {}

function TongFarmPanel.OnFrameCreate()
	this:RegisterEvent("UI_SCALED")
	this:RegisterEvent("UPDATE_SELECT_TARGET")
	
	TongFarmPanel.OnEvent("UI_SCALED")
end

function TongFarmPanel.OnEvent(szEvent)
	if szEvent == "UI_SCALED" then
		this:SetPoint("CENTER", 0, 0, "CENTER", 0, 0)
	elseif szEvent == "UPDATE_SELECT_TARGET" then
		local hPlayer = GetClientPlayer()
		local dwTargetType, dwTargetID = hPlayer.GetTarget()
		if dwTargetType ~= TARGET.NPC or dwTargetID ~= this.dwNpcID then
			CloseTongFarmPanel()
		end
	end
end

function TongFarmPanel.OnFrameBreathe()
	local hPlayer = GetClientPlayer()
	if not hPlayer or hPlayer.nMoveState == MOVE_STATE.ON_DEATH then
		CloseTongFarmPanel()
		return
	end
	
	if this.dwNpcID then
		local hNpc = GetNpc(this.dwNpcID)
		if not hNpc or not hNpc.CanDialog(hPlayer) then
			CloseTongFarmPanel()
		end
	end
end

function TongFarmPanel.OnLButtonClick()
	local szName = this:GetName()
	local bEnable = this:IsEnabled()
	local hFrame = this:GetRoot()
	if szName == "Btn_Close" then
		CloseTongFarmPanel()
	elseif szName == "Btn_Sowing" then
		if bEnable then
			if hFrame.nSeedLevel > hFrame.nSoilLevel then
				OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.TONG_FARM_SEED_LEVEL_NOT_MATCH)
			else
				RemoteCallToServer("SowingPlant", hFrame.dwNpcID, hFrame.nSeedItemID)
				CloseTongFarmPanel()
			end
		end
	elseif szName == "Btn_Kill" then
		if bEnable then
			local wAll, hAll = Station.GetClientSize()
			local KillPlant = function()
				RemoteCallToServer("KillPlant", hFrame.dwNpcID)
				CloseTongFarmPanel()
			end
			local tMsg = 
			{
				x = wAll / 2, y = hAll / 2,
				szMessage = g_tStrings.TONG_FARM_SEED_KILL,
				szName = "KillPlant", 
				fnAutoClose = function() return not IsTongFarmPanelOpened() end,
				{szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = KillPlant},
				{szOption = g_tStrings.STR_HOTKEY_CANCEL},
			}
			MessageBox(tMsg)
		end
	elseif szName == "Btn_Harvest" then
		if bEnable then
			RemoteCallToServer("ReapPlant", hFrame.dwNpcID)
			CloseTongFarmPanel()
		end
	end
end

function TongFarmPanel.Update(hFrame)
	local hTotalHandle = hFrame:Lookup("", "")
	local hSoilLevel = hTotalHandle:Lookup("Text_LandLevel")
	hSoilLevel:SetText(hFrame.nSoilLevel + 1)
	local hSoilPercent = hTotalHandle:Lookup("Text_LandPercent")
	hSoilPercent:SetText(hFrame.nSoilExperience .. "%")
	local hImageSoil = hTotalHandle:Lookup("Image_LandLine2")
	
	fPercentage = hFrame.nSoilExperience / 100
	hImageSoil:SetPercentage(fPercentage)
	
	local hMaturePercent = hTotalHandle:Lookup("Text_MaturePercent")
	local hHeathPercent = hTotalHandle:Lookup("Text_HealthPercent")
	local hImageMature = hTotalHandle:Lookup("Image_MathureLine2")
	local hImageHealth = hTotalHandle:Lookup("Image_HealthLine2")
	if not hFrame.bEmpty then
		local hBox = hTotalHandle:Lookup("Box_VegeTable")
		local hItemInfo = GetItemInfo(ITEM_TABLE_TYPE.OTHER, hFrame.nSeedItemID)
		local nIconID = Table_GetItemIconID(hItemInfo.nUiId)
		
		hBox:SetObject(UI_OBJECT_ITEM_INFO, hItemInfo.nUiId, GLOBAL.CURRENT_ITEM_VERSION, ITEM_TABLE_TYPE.OTHER, hFrame.nSeedItemID)
		hBox:SetObjectIcon(nIconID)
		hMaturePercent:Show()
		hImageMature:Show()
		hMaturePercent:SetText(hFrame.nMature .. "%")
		hImageMature:SetPercentage(hFrame.nMature / 100)
		hHeathPercent:Show()
		hImageHealth:Show()
		hHeathPercent:SetText(hFrame.nHealth .. "%")
		hImageHealth:SetPercentage(hFrame.nHealth / 100)
	else
		hMaturePercent:Hide()
		hImageMature:Hide()
		hHeathPercent:Hide()
		hImageHealth:Hide()
	end
	TongFarmPanel.UpdateBtnState(hFrame)
end

function TongFarmPanel.OnItemLButtonDrag()
	local szName = this:GetName()
	local hFrame = this:GetRoot()
	if szName == "Box_VegeTable" and hFrame.bEmpty then
		if Hand_IsEmpty() then
			if not this:IsEmpty() then
				if IsCursorInExclusiveMode() then
					OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.SRT_ERROR_CANCEL_CURSOR_STATE)
					PlayTipSound("010")
				else
					Hand_Pick(this)
					this:ClearObject()
					this:SetOverText(0, "")
					hFrame.bSeed = false
					TongFarmPanel.UpdateBtnState(hFrame)
					if this:IsObjectMouseOver() then
						TongFarmPanel.OnItemMouseEnter()
					end
				end
			end
		end
	end
end

function TongFarmPanel.OnItemMouseEnter()
	local szName = this:GetName()
	if szName == "Box_VegeTable" then
		this:SetObjectMouseOver(true)
		if this:IsEmpty() then
			local x, y = this:GetAbsPos()
			local w, h = this:GetSize()
			local szTip = GetFormatText(g_tStrings.TONG_FARM_SEED_EMPTY)
			OutputTip(szTip, 300, {x, y, w, h})
		else
			local x, y = this:GetAbsPos()
			local w, h = this:GetSize()
			local nType = this:GetObjectType()
			if nType == UI_OBJECT_ITEM then		
				local _, dwBox, dwX = this:GetObjectData()
				OutputItemTip(UI_OBJECT_ITEM, dwBox, dwX, nil, {x, y, w, h})
			elseif nType == UI_OBJECT_ITEM_INFO then
				local _, nVersion, dwType, dwIndex = this:GetObjectData()
				OutputItemTip(UI_OBJECT_ITEM_INFO, nVersion, dwType, dwIndex, {x, y, w, h})
			end
		end
	end
end

function TongFarmPanel.OnItemMouseLeave()
	local szName = this:GetName()
	if szName == "Box_VegeTable" then
		this:SetObjectMouseOver(false)
		HideTip()
	end
end

function TongFarmPanel.OnItemLButtonDragEnd()
	local szName = this:GetName()
	local hFrame = this:GetRoot()
	if szName == "Box_VegeTable" then
		if Hand_IsEmpty() then
			return
		end
		local boxHand = Hand_Get()
		if boxHand:GetObjectType() ~= UI_OBJECT_ITEM then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_MSG_MAIL_ONLY_BAG_ITEM)
			return
		end

		local _, dwBox, dwX = boxHand:GetObjectData()
		if not IsObjectFromBag(dwBox) then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_MSG_MAIL_ONLY_BAG_ITEM)
			return
		end

		local hItem = GetPlayerItem(GetClientPlayer(), dwBox, dwX)
		if not hItem then
			return
		end
		
		local tSeed = TongFarmPanel.GetSeedItem(hItem)
	
		if not tSeed then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.TONG_FARM_NOT_SEED)
			return
		end
		
		if not hFrame.bEmpty then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.TONG_FARM_NOT_EMPTY)
			return
		end

		if this:IsEmpty() then
			Hand_Clear()
		else
			Hand_Pick(this)
		end
		
		hFrame.bSeed = true
		hFrame.nSeedItemID = tSeed.nItemID
		hFrame.nSeedLevel = tSeed.nLevel
		
		RemoveUILockItem("TongFarm")
		AddUILockItem("TongFarm", dwBox, dwX)
		this:SetObject(UI_OBJECT_ITEM, hItem.nUiId, dwBox, dwX, hItem.nVersion, hItem.dwTabType, hItem.dwIndex)
		this:SetObjectIcon(Table_GetItemIconID(hItem.nUiId))
		if this:IsObjectMouseOver() then
			TongFarmPanel.OnItemMouseEnter()
		end
		
		TongFarmPanel.UpdateBtnState(hFrame)
	end
end

function TongFarmPanel.OnItemLButtonDown()
	local szName = this:GetName()
	if szName == "Box_VegeTable" then
		this:SetObjectPressed(1)
	end
end

function TongFarmPanel.OnItemLButtonUp()
	local szName = this:GetName()
	if szName == "Box_VegeTable" then
		this:SetObjectPressed(0)
	end
end

function TongFarmPanel.OnItemLButtonClick()
	local szName = this:GetName()
	if szName == "Box_VegeTable" then
		if Hand_IsEmpty() then
			TongFarmPanel.OnItemLButtonDrag()
		else
			TongFarmPanel.OnItemLButtonDragEnd()
		end
	end
end

function TongFarmPanel.UpdateBtnState(hFrame)
	local hBtnSowing = hFrame:Lookup("Btn_Sowing")
	local hBtnKill = hFrame:Lookup("Btn_Kill")
	local hBtnHarvest = hFrame:Lookup("Btn_Harvest")
	hBtnSowing:Enable(false)
	hBtnKill:Enable(false)
	hBtnHarvest:Enable(false)
	
	if hFrame.bSeed then
		hBtnSowing:Enable(true)
	elseif not hFrame.bEmpty then
		if hFrame.nMature >= TONG_FARM_MATURE then
			hBtnHarvest:Enable(true)
		else
			hPlayer = GetClientPlayer()
			if hPlayer and hPlayer.dwID == hFrame.dwOwnerID then
				hBtnKill:Enable(true)
			end
		end
	end
end

function OpenTongFarmPanel(dwNpcID, bEmpty, dwOwnerID, nHealth, nMature, nSeedItemID, nSoilLevel, nSoilExperience, bDisableSound)
	if not IsTongFarmPanelOpened() then
		Wnd.OpenWindow("TongFarmPanel")
	end
	
	local hFrame = Station.Lookup("Normal/TongFarmPanel")
	hFrame.dwNpcID = dwNpcID
	hFrame.nSoilLevel = nSoilLevel
	hFrame.nSoilExperience = nSoilExperience
	if hFrame.nSoilExperience and hFrame.nSoilExperience > TONG_FARM_MATURE then
		hFrame.nSoilExperience = TONG_FARM_MATURE
	end	

	hFrame.bEmpty = bEmpty
	hFrame.dwOwnerID = dwOwnerID
	hFrame.nHealth = nHealth 
	if hFrame.nHealth and hFrame.nHealth > TONG_FARM_MATURE then
		hFrame.nHealth = TONG_FARM_MATURE
	end	
	hFrame.nMature = nMature
	if hFrame.nMature and hFrame.nMature > TONG_FARM_MATURE then
		hFrame.nMature = TONG_FARM_MATURE
	end	
	hFrame.nSeedItemID = nSeedItemID
	
	TongFarmPanel.Update(hFrame)
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND, g_sound.OpenFrame)
	end
end

function CloseTongFarmPanel(bDisableSound)
	if not IsTongFarmPanelOpened() then
		return
	end
	
	RemoveUILockItem("TongFarm")
	Wnd.CloseWindow("TongFarmPanel")
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND, g_sound.CloseFrame)
	end
end

function IsTongFarmPanelOpened()
	local hFrame = Station.Lookup("Normal/TongFarmPanel")
	if hFrame then
		return true
	end
	
	return false
end

function TongFarmPanel.GetSeedItem(hItem)
	if not hItem.dwTabType == ITEM_TABLE_TYPE.OTHER then
		return
	end
	
	local tSeed = nil
	for i = 1, #SEED do
		if SEED[i][1] == hItem.dwIndex then
			
			tSeed = {}
			tSeed.nItemID = hItem.dwIndex
			tSeed.nLevel = SEED[i][6]
			break
		end
	end
	return tSeed
end

function AppendTongFarmItem(dwBoxID, dwIndex)
	local hPlayer = GetClientPlayer()
	local hItem = GetPlayerItem(hPlayer, dwBoxID, dwIndex)
		
	if not hItem then
		return
	end
	
	if not IsTongFarmPanelOpened() then
		return
	end
	
	if IsBagInSort() then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_CANNOT_TRADE_ITEM_INSORT)
		return
	end

	local tSeed = TongFarmPanel.GetSeedItem(hItem)
	
	if not tSeed then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.TONG_FARM_NOT_SEED)
		return
	end

	local hFrame = Station.Lookup("Normal/TongFarmPanel")
	local hBox = hFrame:Lookup("", "Box_VegeTable")
	
	if not hFrame.bEmpty then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.TONG_FARM_NOT_EMPTY)
		return
	end
	
	if hBox:IsObjectMouseOver() then
		local thisSave = this
		this = hBox
		TongFarmPanel.OnItemMouseEnter()
		this = thisSave
	end
	
	RemoveUILockItem("TongFarm")
	AddUILockItem("TongFarm", dwBoxID, dwIndex)
	
	hBox:SetObject(UI_OBJECT_ITEM, hItem.nUiId, dwBoxID, dwIndex, hItem.nVersion, hItem.dwTabType, hItem.dwIndex)
	hBox:SetObjectIcon(Table_GetItemIconID(hItem.nUiId))
	hFrame.nSeedItemID = tSeed.nItemID
	hFrame.nSeedLevel = tSeed.nLevel
	hFrame.bSeed = true
	
	TongFarmPanel.UpdateBtnState(hFrame)
end


