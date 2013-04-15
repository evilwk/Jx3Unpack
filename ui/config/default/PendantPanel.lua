PendantPanel = 
{
	nBackPendantPage = 1,
	nWastPendantPage = 1,
}

function PendantPanel.OnFrameCreate()
	this:RegisterEvent("CORRECT_AUTO_POS")
	this:RegisterEvent("OPEN_CHAR_INFO")
	this:RegisterEvent("CLOSE_CHAR_INFO")
	this:RegisterEvent("OPEN_DESIGNATION_PANEL")
	this:RegisterEvent("CLOSE_DESIGNATION_PANEL")
	this:RegisterEvent("ON_PENDANT_LIST_CHANGED")
	this:RegisterEvent("ON_PENDANT_SIZE_CHANGED")
	this:RegisterEvent("ON_SLECT_WAIST_PENDANT")
	this:RegisterEvent("ON_SLECT_BACK_PENDANT")
	this:RegisterEvent("CHARACTER_PANEL_BRING_TOP")
	
	local szIniFile = "UI/Config/Default/PendantPanel.ini"
	local hList = this:Lookup("Wnd_Box_Back", "")
	hList:Clear()
	for i = 1, 12, 1 do
		hList:AppendItemFromIni(szIniFile, "Handle_Box")
	end
	hList:FormatAllItemPos()
	
	hList = this:Lookup("Wnd_Box_Waist", "")
	for i = 1, 12, 1 do
		hList:AppendItemFromIni(szIniFile, "Handle_Box")
	end
	hList:FormatAllItemPos()
	
	PendantPanel.Update(this)
	PendantPanel.SelectCurrentPage(this)
end

function PendantPanel.OnEvent(event)
	if event == "CORRECT_AUTO_POS" then
		if arg0 == "CharacterPanel" then
			PendantPanel.OnCorrectPos(this)
		end
	elseif event == "OPEN_CHAR_INFO" or event == "CLOSE_CHAR_INFO" or event == "OPEN_DESIGNATION_PANEL" or event == "CLOSE_DESIGNATION_PANEL" then
		PendantPanel.OnCorrectPos(this)
	elseif event == "ON_PENDANT_LIST_CHANGED" then
		PendantPanel.Update(this)
	elseif event == "ON_PENDANT_SIZE_CHANGED" then
		PendantPanel.Update(this)
	elseif event == "ON_SLECT_WAIST_PENDANT" then
		PendantPanel.Update(this)
	elseif event == "ON_SLECT_BACK_PENDANT" then
		PendantPanel.Update(this)
	elseif event == "CHARACTER_PANEL_BRING_TOP" then
		this:BringToTop()
	end
end

function PendantPanel.OnSetFocus()
	FireEvent("CHARACTER_PANEL_BRING_TOP")
end

function PendantPanel.OnCorrectPos(frame)
	local nX = 380
	if IsCharInfoOpened() then
		nX = nX + 230
	end
	
	if IsDesignationPanelOpened() then
		nX = nX + 230
	end
		
	frame:SetPoint("TOPLEFT", 0, 0, GetCharacterPanelPath(), "TOPLEFT", nX, 0)
end

function PendantPanel.SelectCurrentPage(frame)
	for i, dwID in pairs(PendantPanel.aWaist) do
		if PendantPanel.nWaist == dwID then
			local nPage = math.floor(i / 12)
			if nPage ~= PendantPanel.nWastPendantPage then
				PendantPanel.ShowWastPendantPage(frame, nPage)
			end
			break
		end
	end
	
	for i, dwID in pairs(PendantPanel.aBack) do
		if PendantPanel.nBack == dwID then
			local nPage = math.floor(i / 12)
			if nPage ~= PendantPanel.nBackPendantPage then
				PendantPanel.UpdateBackPendantPage(frame, nPage)
			end
			break
		end
	end
end

function PendantPanel.Update(frame)
	local player = GetClientPlayer()
	if not player then
		return
	end
	
	PendantPanel.aWaist = player.GetAllWaistPendent() or {}
	table.insert(PendantPanel.aWaist, 1, 0)
	PendantPanel.aBack = player.GetAllBackPendent() or {}
	table.insert(PendantPanel.aBack, 1, 0)
	PendantPanel.nWaistBoxSize = player.nWaistPendentBoxSize + 1
	PendantPanel.nBackBoxSize = player.nBackPendentBoxSize + 1
	local t = player.GetRepresentID()
	PendantPanel.nWaist = t[EQUIPMENT_REPRESENT.WAIST_EXTEND]
	PendantPanel.nBack = t[EQUIPMENT_REPRESENT.BACK_EXTEND]
	
	PendantPanel.ShowBackPendantPage(frame, PendantPanel.nBackPendantPage)
	PendantPanel.ShowWastPendantPage(frame, PendantPanel.nWastPendantPage)
	PendantPanel.UpdateName(frame)
end

function PendantPanel.UpdateName(frame)
	local textBack = frame:Lookup("", "Handle_Back/Text_Back")
	local itemInfo, dwTabType, dwTabIndex = GetBackPendantItemInfo(PendantPanel.nBack)
	if itemInfo then
		textBack:SetText(GetItemNameByItemInfo(itemInfo))
		textBack:SetFontColor(GetItemFontColorByQuality(itemInfo.nQuality))
	else
		textBack:SetText(g_tStrings.PENDANT_NO)
		textBack:SetFontColor(GetItemFontColorByQuality(1))
	end
	
	local textWaist = frame:Lookup("", "Handle_Waist/Text_Waist")
	local itemInfo, dwTabType, dwTabIndex = GetWaistPendantItemInfo(PendantPanel.nWaist)
	if itemInfo then
		textWaist:SetText(GetItemNameByItemInfo(itemInfo))
		textWaist:SetFontColor(GetItemFontColorByQuality(itemInfo.nQuality))
	else
		textWaist:SetText(g_tStrings.PENDANT_NO)
		textWaist:SetFontColor(GetItemFontColorByQuality(1))
	end
end

function PendantPanel.UpdateBackPendantPage(frame)
	local hList = frame:Lookup("Wnd_Box_Back", "")
	local nCount = hList:GetItemCount() - 1
	local nPos = (PendantPanel.nBackPendantPage - 1) * 12
	for i = 0, nCount, 1 do
		local hI = hList:Lookup(i)
		hI.nPos = nPos + i + 1
		hI:Show(hI.nPos <= 129)
		hI.bEnable = hI.nPos <= PendantPanel.nBackBoxSize
		hI:Lookup("Image_Bg"):Show(hI.bEnable)
		hI:Lookup("Image_Bg_Disable"):Show(not hI.bEnable)
		hI.dwID = PendantPanel.aBack[hI.nPos]
		local itemInfo, dwTabType, dwTabIndex = GetBackPendantItemInfo(hI.dwID)
		local box = hI:Lookup("Box_Pendant")
		box.dwID = hI.dwID
		box.nPos = hI.nPos
		box.bEnable = hI.bEnable
		box.bBack = true
		box.bUnmont = false
		if itemInfo then
			box:SetObject(UI_OBJECT_ITEM_INFO, itemInfo.nUiId, 0, dwTabType, dwTabIndex)
			box:SetObjectIcon(Table_GetItemIconID(itemInfo.nUiId))
			UpdateItemBoxExtend(box, itemInfo)
			box:SetObjectInUse(PendantPanel.nBack == box.dwID)
		elseif hI.nPos == 1 then
			box.bUnmont = true
			box:SetObject(UI_OBJECT_NOT_NEED_KNOWN, 0)
			box:SetObjectIcon(2590)
			box:SetObjectInUse(PendantPanel.nBack == box.dwID)				
		else
			box:ClearObject()
		end
	end
end

function PendantPanel.UpdateWaistPendantPage(frame)
	local hList = frame:Lookup("Wnd_Box_Waist", "")
	local nCount = hList:GetItemCount() - 1
	local nPos = (PendantPanel.nWastPendantPage - 1) * 12
	for i = 0, nCount, 1 do
		local hI = hList:Lookup(i)
		hI.nPos = nPos + i + 1
		hI:Show(hI.nPos <= 129)
		hI.bEnable = hI.nPos <= PendantPanel.nWaistBoxSize
		hI:Lookup("Image_Bg"):Show(hI.bEnable)
		hI:Lookup("Image_Bg_Disable"):Show(not hI.bEnable)
		hI.dwID = PendantPanel.aWaist[hI.nPos]
		local itemInfo, dwTabType, dwTabIndex = GetWaistPendantItemInfo(hI.dwID)
		local box = hI:Lookup("Box_Pendant")
		box.dwID = hI.dwID
		box.nPos = hI.nPos
		box.bEnable = hI.bEnable
		box.bWaist = true
		box.bUnmont = false
		if itemInfo then
			box:SetObject(UI_OBJECT_ITEM_INFO, itemInfo.nUiId, 0, dwTabType, dwTabIndex)
			box:SetObjectIcon(Table_GetItemIconID(itemInfo.nUiId))
			UpdateItemBoxExtend(box, itemInfo)
			box:SetObjectInUse(PendantPanel.nWaist == box.dwID)
		elseif hI.nPos == 1 then
			box.bUnmont = true
			box:SetObject(UI_OBJECT_NOT_NEED_KNOWN, 0)
			box:SetObjectIcon(2590)
			box:SetObjectInUse(PendantPanel.nWaist == box.dwID)			
		else
			box:ClearObject()
		end
	end	
end

function PendantPanel.ShowBackPendantPage(frame, nPage)
	local wndPage = frame:Lookup("Wnd_Page_1")

	wndPage:Lookup("Btn_PagePrev_1"):Enable(true)
	wndPage:Lookup("Btn_PageNext_1"):Enable(true)
	if nPage <= 1 then
		nPage = 1
		wndPage:Lookup("Btn_PagePrev_1"):Enable(false)
	end
	
	if nPage >= 11 then
		nPage = 11
		wndPage:Lookup("Btn_PageNext_1"):Enable(false)
	end

	for i = 1, 7, 1 do
		local c = wndPage:Lookup("CheckBox_PageNum_1_"..i)
		local t = c:Lookup("", "Text_PageNum_1_"..i)
		local n = i
		local s = i
		local b = true
		if nPage < 7 then
			if n == 7 then
				s = "..."
			end
		else
			n = 5 + i
			s = n
			if i == 1 then
				s = "..."
			elseif i == 7 then
				s = ""
				b = false
			end
		end
		c.nPage = n
		c.bDisable = true
		c:Check(nPage == n)
		c.bDisable = false
		c:Show(b)
		t:SetText(s)
	end
	
	PendantPanel.nBackPendantPage = nPage
	PendantPanel.UpdateBackPendantPage(frame)
end

function PendantPanel.ShowWastPendantPage(frame, nPage)
	local wndPage = frame:Lookup("Wnd_Page_2")

	wndPage:Lookup("Btn_PagePrev_2"):Enable(true)
	wndPage:Lookup("Btn_PageNext_2"):Enable(true)
	if nPage <= 1 then
		nPage = 1
		wndPage:Lookup("Btn_PagePrev_2"):Enable(false)
	end
	
	if nPage >= 11 then
		nPage = 11
		wndPage:Lookup("Btn_PageNext_2"):Enable(false)
	end

	for i = 1, 7, 1 do
		local c = wndPage:Lookup("CheckBox_PageNum_2_"..i)
		local t = c:Lookup("", "Text_PageNum_2_"..i)
		local n = i
		local s = i
		local b = true
		if nPage < 7 then
			if n == 7 then
				s = "..."
			end
		else
			n = 5 + i
			s = n
			if i == 1 then
				s = "..."
			elseif i == 7 then
				s = ""
				b = false
			end
		end
		c.nPage = n
		c.bDisable = true
		c:Check(nPage == n)
		c.bDisable = false
		c:Show(b)
		t:SetText(s)
	end
	
	PendantPanel.nWastPendantPage = nPage
	PendantPanel.UpdateWaistPendantPage(frame)
end

function PendantPanel.OnItemMouseEnter()
	if this.bBack or this.bWaist then
		this:SetObjectMouseOver(1)
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
		if this:IsEmpty() then
			if not this.bEnable then
				OutputTip("<Text>text="..EncodeComponentsString(g_tStrings.PENDANT_NEED_UNLOCK).." font=106 </text>", 345, {x, y, w, h})
			end
		else
			if this.bUnmont then
				OutputTip("<Text>text="..EncodeComponentsString(g_tStrings.PENDANT_UNMONT_TIP).." font=106 </text>", 345, {x, y, w, h})
			else
				if this.bBack then
					OutputBackPendantTip(this.dwID, {x, y, w, h})
				elseif this.bWaist then
					OutputWaistPendantTip(this.dwID, {x, y, w, h})
				end
			end
		end
	end
end

function PendantPanel.OnItemMouseLeave()
	if this.bBack or this.bWaist then
		this:SetObjectMouseOver(0)	
		HideTip()
	 end
end

function PendantPanel.OnItemLButtonDown()
	if this.bBack or this.bWaist and not this:IsEmpty() then
		this:SetObjectPressed(1)
	end
end

function PendantPanel.OnItemLButtonUp()
	if this.bBack or this.bWaist and not this:IsEmpty() then
		this:SetObjectPressed(0)
	end
end

function PendantPanel.OnItemLButtonClick()
	if this:IsEmpty() then
		return
	end
	
	local player = GetClientPlayer()
	
	if player.bFightState then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.CANNOT_CHANGE_PENDENT_IN_FIGHT)
		return
	end
	
	if player.nMoveState == MOVE_STATE.ON_DEATH then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_ERROR_CANNOT_EQUIP_PENDANT_WHEN_DIE)
		return
	end	
	
	if not Hand_IsEmpty() then
		PendantPanel.OnItemLButtonDragEnd()
		return
	end

	if this.bBack then
		PendantPanel.nBack = this.dwID
		RemoteCallToServer("OnSelectBackPendent", this.dwID) 
		PendantPanel.UpdateBackPendantPage(this:GetRoot())
		PendantPanel.UpdateName(this:GetRoot())
	elseif this.bWaist then
		PendantPanel.nWaist = this.dwID
		RemoteCallToServer("OnSelectWaistPendent", this.dwID) 
		PendantPanel.UpdateWaistPendantPage(this:GetRoot())
		PendantPanel.UpdateName(this:GetRoot())
	end
end

function PendantPanel.OnItemLButtonDragEnd()
	if Hand_IsEmpty() then
		return
	end
	
	local szName = this:GetName()
	
	local bEquiped = false
	local boxHand, nHandCount = Hand_Get()	
	local nSourceType = boxHand:GetObjectType()
	if nSourceType == UI_OBJECT_ITEM then
		local _, dwBox1, dwX1 = boxHand:GetObjectData()
		local player = GetClientPlayer()
		local item = player.GetItem(dwBox1, dwX1)
		if item and item.nGenre == ITEM_GENRE.EQUIPMENT then
			if this.bBack or szName == "Handle_Box_Back" then
				if item.nSub == EQUIPMENT_SUB.BACK_EXTEND then
					OnUsePendentItem(dwBox1, dwX1)
					bEquiped = true
				end		
			elseif this.bWaist or szName == "Handle_Box_Waist" then
				if item.nSub == EQUIPMENT_SUB.WAIST_EXTEND then
					OnUsePendentItem(dwBox1, dwX1)
					bEquiped = true
				end
			end
		end
	end
	if not bEquiped then
		if this.bBack or szName == "Handle_Box_Back" then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_ERROR_ONLY_BACK_PENDANT)
			PlayTipSound("012")
		elseif this.bWaist or szName == "Handle_Box_Waist" then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_ERROR_ONLY_WAIST_PENDANT)
			PlayTipSound("012_1")
		end
	end
end

function PendantPanel.OnItemRButtonDown()
	PendantPanel.OnItemLButtonDown()
end

function PendantPanel.OnItemRButtonUp()
	PendantPanel.OnItemLButtonUp()
end

function PendantPanel.OnItemRButtonClick()
	PendantPanel.OnItemLButtonClick()
end

function PendantPanel.OnLButtonClick()
	local szName = this:GetName() 
	if szName == "Btn_Sure" then
		ClosePendantPanel()
	elseif szName == "Btn_Cancel" then
		ClosePendantPanel()
	elseif szName == "Btn_Close" then
		ClosePendantPanel()
	elseif szName == "Btn_PagePrev_1" then
		PendantPanel.ShowBackPendantPage(this:GetRoot(), PendantPanel.nBackPendantPage - 1)
	elseif szName == "Btn_PageNext_1" then
		PendantPanel.ShowBackPendantPage(this:GetRoot(), PendantPanel.nBackPendantPage + 1)
	elseif szName == "Btn_PagePrev_2" then
		PendantPanel.ShowWastPendantPage(this:GetRoot(), PendantPanel.nWastPendantPage - 1)
	elseif szName == "Btn_PageNext_2" then
		PendantPanel.ShowWastPendantPage(this:GetRoot(), PendantPanel.nWastPendantPage + 1)
	end
end

function PendantPanel.OnCheckBoxCheck()
	local szName = this:GetName()
	if szName == "CheckBox_PageNum_1_1" then
		if not this.bDisable then
			PendantPanel.ShowBackPendantPage(this:GetRoot(), this.nPage)
		end
	elseif szName == "CheckBox_PageNum_1_2" then
		if not this.bDisable then
			PendantPanel.ShowBackPendantPage(this:GetRoot(), this.nPage)
		 end
	elseif szName == "CheckBox_PageNum_1_3" then
		if not this.bDisable then
			PendantPanel.ShowBackPendantPage(this:GetRoot(), this.nPage)
		end
	elseif szName == "CheckBox_PageNum_1_4" then
		if not this.bDisable then
			PendantPanel.ShowBackPendantPage(this:GetRoot(), this.nPage)
		end
	elseif szName == "CheckBox_PageNum_1_5" then
		if not this.bDisable then
			PendantPanel.ShowBackPendantPage(this:GetRoot(), this.nPage)
		end
	elseif szName == "CheckBox_PageNum_1_6" then
		if not this.bDisable then
			PendantPanel.ShowBackPendantPage(this:GetRoot(), this.nPage)
		end
	elseif szName == "CheckBox_PageNum_1_7" then
		if not this.bDisable then
			PendantPanel.ShowBackPendantPage(this:GetRoot(), this.nPage)
		end
	elseif szName == "CheckBox_PageNum_2_1" then
		if not this.bDisable then
			PendantPanel.ShowWastPendantPage(this:GetRoot(), this.nPage)
		end
	elseif szName == "CheckBox_PageNum_2_2" then
		if not this.bDisable then
			PendantPanel.ShowWastPendantPage(this:GetRoot(), this.nPage)
		end
	elseif szName == "CheckBox_PageNum_2_3" then
		if not this.bDisable then
			PendantPanel.ShowWastPendantPage(this:GetRoot(), this.nPage)
		end
	elseif szName == "CheckBox_PageNum_2_4" then
		if not this.bDisable then
			PendantPanel.ShowWastPendantPage(this:GetRoot(), this.nPage)
		end
	elseif szName == "CheckBox_PageNum_2_5" then
		if not this.bDisable then
			PendantPanel.ShowWastPendantPage(this:GetRoot(), this.nPage)
		end
	elseif szName == "CheckBox_PageNum_2_6" then
		if not this.bDisable then
			PendantPanel.ShowWastPendantPage(this:GetRoot(), this.nPage)
		end
	elseif szName == "CheckBox_PageNum_2_7" then
		if not this.bDisable then
			PendantPanel.ShowWastPendantPage(this:GetRoot(), this.nPage)
		end
	end
end

function OpenPendantPanel(bDisableSound)
	OpenCharacterPanel()
	if IsPendantPanelOpened() then
		PendantPanel.Update(Station.Lookup("Normal/PendantPanel"))
		return
	end
	local frame = Wnd.OpenWindow("PendantPanel")
	frame:Show()
	PendantPanel.Update(frame)
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end

	FireEvent("OPEN_PENDANT_PANEL")
	
	PendantPanel.OnCorrectPos(frame)
end

function IsPendantPanelOpened()
	local frame = Station.Lookup("Normal/PendantPanel")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end

function ClosePendantPanel(bDisableSound, bIgnor)
	if not IsPendantPanelOpened() then
		return
	end

	local frame = Station.Lookup("Normal/PendantPanel")
	frame:Hide()
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end
	
	local argS = arg0
	arg0 = not bIgnor
	FireEvent("CLOSE_PENDANT_PANEL")
	arg0 = argS
end

