function CreateLootRollMini(dwStartFrame, dwDoodadID, dwItemID, nLeftFrame)
	local doodad = GetDoodad(dwDoodadID)
	if not doodad then
		Trace("CreateLootRollMini failed because of invalid doodad:"..tostring(dwDoodadID).."\n")
		return
	end
	local item = GetItem(dwItemID)
	if not item then
		Trace("CreateLootRollMini failed because of invalid item:"..tostring(dwItemID).."\n")
		return
	end

	local frame = Station.Lookup("Normal/LootRollMini")
	if not frame then
		frame = Wnd.OpenWindow("LootRollMini")
		frame:Lookup("", ""):Clear()
	end
	
	local handle = frame:Lookup("", "")
	handle:AppendItemFromIni("UI/Config/Default/LootRollMini.ini", "Handle_Item", "")
	local hI = handle:Lookup(handle:GetItemCount() - 1)
	hI.dwStartFrame = dwStartFrame
	hI.dwItemID = dwItemID
	hI.dwDoodadID = dwDoodadID
	hI.nRollFrame = doodad.GetRollFrame()
	hI.nLeftFrame = nLeftFrame
	
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
	
	box.OnItemMouseEnter = function()
		this:SetObjectMouseOver(1)
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()	
		local _, dwID = this:GetObjectData()
		OutputItemTip(UI_OBJECT_ITEM_ONLY_ID, dwID, nil, nil, {x, y, w, h}, nil, true)
	end	
	box.OnItemMouseLeave = function()
		HideTip()
		this:SetObjectMouseOver(0)
	end
	box.OnItemLButtonDown = function()
		local _, dwID = this:GetObjectData()
		if IsCtrlKeyDown() then
			if IsGMPanelReceiveItem() then
				GMPanel_LinkItem(dwID)
			else
				EditBox_AppendLinkItem(dwID)
			end
		end
	end

	frame.OnFrameBreathe = function()
		local dwFrame = GetLogicFrameCount()
		local handle = this:Lookup("", "")
		local nCount = handle:GetItemCount() - 1
		local bRemove = false
		for i = nCount, 0, -1 do
			local hI = handle:Lookup(i)
			local fP = (hI.nLeftFrame - (dwFrame - hI.dwStartFrame)) / hI.nRollFrame
			if fP <= 0 or CreateLootRoll(hI.dwStartFrame, hI.dwDoodadID, hI.dwItemID, hI.nLeftFrame) then
				handle:RemoveItem(i)
				bRemove = true
			else
				if fP < 0.3 then 
					local ani = hI:Lookup("Animate_Sparking")
					if not ani:IsVisible() then
						ani:Show()
					end
				end
				hI:Lookup("Image_Progress"):SetPercentage(fP)
			end
		end
		if bRemove then
			this:UpdatePos()
		end
	end
	
	frame.UpdatePos = function(frame)
		local handle = frame:Lookup("", "")
		handle:SetSize(500, 500)
		handle:FormatAllItemPos()
		local w, h = handle:GetAllItemSize()
		handle:SetSize(w, h)
		frame:SetSize(w, h)
		frame:SetPoint("BOTTOMCENTER", 0, 0, "BOTTOMCENTER", 0, -360)		
	end
	
	frame.OnEvent = function(event)
		if event == "UI_SCALED" then
			this:UpdatePos()
		end
	end
	
	frame:RegisterEvent("UI_SCALED")
	
	frame:UpdatePos()
end
