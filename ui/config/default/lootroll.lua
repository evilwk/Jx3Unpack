
function CreateLootRoll(dwStartFrame, dwDoodadID, dwItemID, nLeftFrame)
	local nIndex = nil
	for i = 1, 3, 1 do
		local frame = Station.Lookup("Normal/LootRoll"..i)
		if not frame then
			nIndex = i
			break
		end
	end
	if not nIndex then
		return false
	end
	
	local doodad = GetDoodad(dwDoodadID)
	if not doodad then
		Trace("CreateLootRoll failed because of invalid doodad:"..tostring(dwDoodadID).."\n")
		return true
	end
	local item = GetItem(dwItemID)
	if not item then
		Trace("CreateLootRoll failed because of invalid item:"..tostring(dwItemID).."\n")
		return true
	end
	
	local frame = Wnd.OpenWindow("LootRoll", "LootRoll"..nIndex)
	frame.dwStartFrame = dwStartFrame
	frame.dwDoodadID = dwDoodadID
	frame.dwItemID = dwItemID
	frame.nRollFrame = doodad.GetRollFrame()
	frame.nLeftFrame = nLeftFrame
    
	local box = frame:Lookup("", "Box_Item")
	box:SetObject(UI_OBJECT_ITEM_ONLY_ID, item.nUiId, dwItemID, item.nVersion, item.dwTabType, item.dwIndex)
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
	
	local text = frame:Lookup("", "Text_Item")
	text:SetText(GetItemNameByItem(item))
	text:SetFontColor(GetItemFontColorByQuality(item.nQuality))
	
	local img = frame:Lookup("", "Image_Progress")
	img:Show()
	
	frame:Lookup("Btn_Roll").OnLButtonClick = function()
		local frame = this:GetParent()
		local szName = frame:GetName()
		local dwDoodadID, dwItemID, nChoice = frame.dwDoodadID, frame.dwItemID, ROLL_ITEM_CHOICE.NEED
	    local nUiId = frame:Lookup("", "Box_Item"):GetObjectData()
		
		local fnRool = function()
		    RollItem(dwDoodadID, dwItemID, nChoice)
		    PlayItemSound(nUiId, true)
		    Wnd.CloseWindow(szName)
		end
		
		local item = GetItem(dwItemID)
		if item and item.nBindType == ITEM_BIND.BIND_ON_PICKED then
			local msg =
			{
				szMessage = FormatLinkString(g_tStrings.ROLL_ITEM_SURE, "font=162", GetFormatText("["..GetItemNameByItem(item).."]", 
					"166"..GetItemFontColorByQuality(item.nQuality, true))), 
				bRichText = true,
				szName = "Roll_Sure"..dwItemID,
				fnAutoClose = function() return not frame or not frame:IsValid() end,
				{szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = fnRool},
				{szOption = g_tStrings.STR_HOTKEY_CANCEL}
			}
			MessageBox(msg)
		else
			fnRool()
		end
	end
	
	frame:Lookup("Btn_Greed").OnLButtonClick = function()
		local frame = this:GetParent()
		local szName = frame:GetName()
		local dwDoodadID, dwItemID, nChoice = frame.dwDoodadID, frame.dwItemID, ROLL_ITEM_CHOICE.GREED
	    local nUiId = frame:Lookup("", "Box_Item"):GetObjectData()
		
		local fnRool = function()
		    RollItem(dwDoodadID, dwItemID, nChoice)
		    PlayItemSound(nUiId, true)
		    Wnd.CloseWindow(szName)
		end
		
		local item = GetItem(dwItemID)
		if item and item.nBindType == ITEM_BIND.BIND_ON_PICKED then
			local msg =
			{
				szMessage = FormatLinkString(g_tStrings.ROLL_ITEM_SURE, "font=162", GetFormatText("["..GetItemNameByItem(item).."]", 
					"166"..GetItemFontColorByQuality(item.nQuality, true))), 
				bRichText = true,
				szName = "Roll_Sure"..dwItemID,
				fnAutoClose = function() return not frame or not frame:IsValid() end,
				{szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = fnRool},
				{szOption = g_tStrings.STR_HOTKEY_CANCEL}
			}
			MessageBox(msg)
		else
			fnRool()
		end
	end
	
	frame:Lookup("Btn_Cancel").OnLButtonClick = function()
		local frame = this:GetParent()
	    RollItem(frame.dwDoodadID, frame.dwItemID, ROLL_ITEM_CHOICE.CANCEL)
	    local nUiId = frame:Lookup("", "Box_Item"):GetObjectData()
	    PlayItemSound(nUiId, true)
	    Wnd.CloseWindow(frame:GetName())
	end
	
	frame.OnEvent = function(event)
		if event == "UI_SCALED" then
			if not this.nIndex then
				this.nIndex = 1
			end
			frame:SetPoint("TOPCENTER", 0, 0, "TOPCENTER", 0, 240 + 110 * (this.nIndex - 1))
		end
	end
		
	frame.OnFrameBreathe = function()
		local fP = (this.nLeftFrame - (GetLogicFrameCount() - this.dwStartFrame)) / frame.nRollFrame
	
		if fP <= 0 then
			Wnd.CloseWindow(this:GetName())
			PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
			return
		end
		
		local handle = this:Lookup("", "")
		local img = handle:Lookup("Image_Progress")
		local img2 = handle:Lookup("Image_Progress2")
		local imgSparking = handle:Lookup("Image_Sparking")
		local imgPoint = handle:Lookup("Image_Point")
		
		if fP < 0.3 then	--иак╦
			img:Hide()
			img2:Show()
			img = img2
			imgSparking:Show()
			local alpha = imgSparking:GetAlpha()
			if imgSparking.bAdd then
				alpha = alpha + 10
				if alpha >= 255 then
					alpha = 255
					imgSparking.bAdd = false
				end
				imgSparking:SetAlpha(alpha)
			else
				alpha = alpha - 10
				if alpha <= 0 then
					alpha = 0
					imgSparking.bAdd = true
				end
				imgSparking:SetAlpha(alpha)			
			end
		else
			img:Show()
			img2:Hide()
			imgSparking:Hide()
		end
		
		img:SetPercentage(fP)
		local w, h = img:GetSize()
		local x, y = img:GetRelPos()
		local xP, yP = imgPoint:GetRelPos()
		imgPoint:SetRelPos(x + w * fP - 7, yP)
		local xH, yH = handle:GetAbsPos()
		imgPoint:SetAbsPos(xH + x + w * fP - 7, yH + yP)
	end
	
	local thisSave = this
	this = frame
	this.OnFrameBreathe()
	this = thisSave
	
	frame.nIndex = nIndex
	frame:SetPoint("TOPCENTER", 0, 0, "TOPCENTER", 0, 240 + 110 * (nIndex - 1))
	frame:RegisterEvent("UI_SCALED")
	PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	
	FireHelpEvent("OnOpenpanel", "LOOTROOL")
	return true
end
