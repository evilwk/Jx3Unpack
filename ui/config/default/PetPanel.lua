local PET_PANEL_BUFF_MAX_SIZE = 3

PetPanel = {}
PetPanel.DefaultAnchor = {s = "TOPLEFT", r = "TOPLEFT", x = 120, y = 93}
PetPanel.Anchor = {s = "TOPLEFT", r = "TOPLEFT", x = 120, y = 93}

RegisterCustomData("PetPanel.Anchor")

function PetPanel.OnFrameCreate()
	this:RegisterEvent("PLAYER_STATE_UPDATE")
	this:RegisterEvent("BUFF_UPDATE")
	this:RegisterEvent("PET_PANEL_ANCHOR_CHANGED")
	this:RegisterEvent("REMOVE_PET_TEMPLATEID")
	this:RegisterEvent("ON_ENTER_CUSTOM_UI_MODE")
	this:RegisterEvent("ON_LEAVE_CUSTOM_UI_MODE")
	this:RegisterEvent("UI_SCALED")
	this:RegisterEvent("SET_SHOW_VALUE_BY_PERCENTAGE")
	this:RegisterEvent("SET_SHOW_VALUE_TWO_FORMAT")
	this:RegisterEvent("SET_SHOW_PLAYER_STATE_VALUE")
	
	PetPanel.UpdateAnchor(this)
	UpdateCustomModeWindow(this, g_tStrings.PET_PANEL)
end

function PetPanel.OnFrameDrag()
end

function PetPanel.OnFrameDragSetPosEnd()
end

function PetPanel.OnFrameDragEnd()
	this:CorrectPos()
	PetPanel.Anchor = GetFrameAnchor(this)
end

function PetPanel.UpdateAnchor(hFrame)
	hFrame:SetPoint(PetPanel.Anchor.s, 0, 0, PetPanel.Anchor.r, PetPanel.Anchor.x, PetPanel.Anchor.y)
	hFrame:CorrectPos()
end

function PetPanel.OnItemLButtonDown()
	local szName = this:GetName()
	local hFrame = this:GetRoot()
	if szName == "Handle_PetPanel" then 
		SelectTarget(TARGET.NPC, hFrame.dwID)
	end
end

function PetPanel.OnItemMouseEnter()
	local szName = this:GetName()
	if szName == "Image_PetHealth" then
		this:GetParent():Lookup("Text_HealthMsg"):Show()
	end
end

function PetPanel.OnItemMouseLeave()
	local szName = this:GetName()
	if szName == "Image_PetHealth" then
		if not IsPlayerShowStateValue() then
			this:GetParent():Lookup("Text_HealthMsg"):Hide()
		end
	end
end

function PetPanel.OnEvent(szEvent)
	local hPlayer = GetClientPlayer()
	local hPet
	if hPlayer then
		hPet = hPlayer.GetPet()
	end
	
	if szEvent == "PLAYER_STATE_UPDATE" then
		if hPet then
			PetPanel.UpdateLM(this, hPet)
		end
	elseif szEvent == "BUFF_UPDATE" then
		if this.dwID == arg0 then
			PetPanel.UpdateBuff(this, hPet)
		end
	elseif szEvent == "PET_PANEL_ANCHOR_CHANGED" then
		PetPanel.UpdateAnchor(this)
	elseif szEvent == "UI_SCALED" then
		PetPanel.UpdateAnchor(this)
	elseif szEvent == "REMOVE_PET_TEMPLATEID" then
		ClosePetPanel()
	elseif szEvent == "ON_ENTER_CUSTOM_UI_MODE" or szEvent == "ON_LEAVE_CUSTOM_UI_MODE" then
		UpdateCustomModeWindow(this)
	elseif szEvent == "SET_SHOW_VALUE_BY_PERCENTAGE" or szEvent == "SET_SHOW_VALUE_TWO_FORMAT" then
		if hPet then
			PetPanel.UpdateLM(this, hPet)
		end
	elseif szEvent == "SET_SHOW_PLAYER_STATE_VALUE" then
		PetPanel.UpdatePlayerStateValueShow(this)
		if hPet then
			PetPanel.UpdateLM(this, hPet)
		end
	end
end

function PetPanel.UpdatePlayerStateValueShow(hFrame)
	local hTextHealth = hFrame:Lookup("", "Text_HealthMsg")
	if IsPlayerShowStateValue() then
		hTextHealth:Show()
	else
		hTextHealth:Hide()
	end
end

function PetPanel.Update(hFrame)
	local hPlayer = GetClientPlayer()
	if not hPlayer then
		return
	end
	local hPet = hPlayer.GetPet()
	if not hPet then
		return
	end
	PetPanel.UpdatePlayerStateValueShow(hFrame)
	PetPanel.UpdateLM(hFrame, hPet)
	PetPanel.UpdateAvatar(hFrame, hPet)
	PetPanel.UpdateBuff(hFrame, hPet)
end

function PetPanel.UpdateAvatar(hFrame, hPet)
	if not hPet then
		return
	end
	local szPath = Table_GetPetAvatar(hPet.dwTemplateID)
	local hAvatar = hFrame:Lookup("", "Handle_PetAvatar/Image_Avatar")
	hAvatar:Hide()
	if szPath then
		hAvatar:FromTextureFile(szPath)
		hAvatar:AutoSize()
		hAvatar:Show()
	end
end

function PetPanel.UpdateLM(hFrame, hPet)
	if not hPet then
		return
	end
	
	local hImageHealth = hFrame:Lookup("", "Image_PetHealth")
	local fHealth = 0
	if hPet.nMaxLife > 0 then
		fHealth = hPet.nCurrentLife / hPet.nMaxLife
	end
	hImageHealth:SetPercentage(fHealth)
	local hTextHealth = hFrame:Lookup("", "Text_HealthMsg")
	local szShow = GetStateString(hPet.nCurrentLife, hPet.nMaxLife, false)
	hTextHealth:SetText(szShow)
end

function PetPanel.UpdateBuff(hFrame, hPet)
	if not hPet then
		return
	end
	
	local hHandle = hFrame:Lookup("", "")
	local hBuff = hHandle:Lookup("Handle_Buff")
	local hDebuff = hHandle:Lookup("Handle_Debuff")
	hBuff:Clear()
	hDebuff:Clear()
	local nBuffCount = 0
	local nDebuffCount = 0
	local tBuffList = hPet.GetBuffList()
	if tBuffList then
		local tShowBuff = {}
		local tShowDebuff = {}
		local nListCount = #tBuffList
		for i = nListCount, 1, -1  do
			local tBuff = tBuffList[i]
			local bVisible = Table_BuffIsVisible(tBuff.dwID, tBuff.nLevel)
			if tBuff.bCanCancel and bVisible and nBuffCount < PET_PANEL_BUFF_MAX_SIZE then
				nBuffCount = nBuffCount + 1
				table.insert(tShowBuff, tBuff)
			elseif not tBuff.bCanCancel and bVisible and nDebuffCount < PET_PANEL_BUFF_MAX_SIZE then
				
				nDebuffCount = nDebuffCount + 1
				table.insert(tShowDebuff, tBuff)
			end
			if nBuffCount >= PET_PANEL_BUFF_MAX_SIZE and nDebuffCount >= PET_PANEL_BUFF_MAX_SIZE then
				break
			end
		end
		for i = nBuffCount, 1, -1 do
			local tBuff = tShowBuff[i]
			PetPanel.UpdateSingleBuff(hBuff, tBuff.nIndex, true, tBuff.dwID, tBuff.nStackNum,tBuff.nEndFrame, tBuff.nLevel)
		end
		for i = nDebuffCount, 1, -1 do
			local tBuff = tShowDebuff[i]
			PetPanel.UpdateSingleBuff(hDebuff, tBuff.nIndex, false, tBuff.dwID, tBuff.nStackNum, tBuff.nEndFrame, tBuff.nLevel)
		end
	end
end

function PetPanel.UpdateSingleBuff(hBuff, nIndex, bCanCancel, dwBuffID, nCount, nEndFrame, nLevel)
	if not Table_BuffIsVisible(dwBuffID, nLevel) then
		return
	end
	
	local nItemCount = hBuff:GetItemCount()
	if nItemCount >= PET_PANEL_BUFF_MAX_SIZE then
		return
	end
	local hBox = hBuff:Lookup("b"..nIndex)
	if not hBox then
		hBuff:AppendItemFromString("<box>w=20 h=20 eventid=262912 postype=7</box>")
		hBox = hBuff:Lookup(hBuff:GetItemCount() - 1)
		hBox:SetName("b"..nIndex)
		hBox.nCount = nCount
		hBox.nEndFrame = nEndFrame
		hBox.bCanCancel = bCanCancel
		hBox.dwBuffID = dwBuffID
		hBox.nLevel = nLevel
		hBox.nIndex = nIndex
		hBox.bSparking = Table_BuffNeedSparking(dwBuffID, nLevel)
		hBox.bShowTime = Table_BuffNeedShowTime(dwBuffID, nLevel)
		hBox:SetObject(UI_OBJECT_NOT_NEED_KNOWN, dwBuffID)
		hBox:SetObjectIcon(Table_GetBuffIconID(dwBuffID, nLevel))
		hBox:SetOverTextFontScheme(0, 15)
		if nCount > 1 then
			hBox:SetOverText(0, nCount)
		end
		
		hBox.OnItemMouseEnter = function()
			local hFrame = this:GetRoot()
			this:SetObjectMouseOver(1)
			local nTime = math.floor(this.nEndFrame - GetLogicFrameCount()) / 16 + 1
			local x, y = this:GetAbsPos()
			local w, h = this:GetSize()
			OutputBuffTip(hFrame.dwID, this.dwBuffID, this.nLevel, this.nCount, this.bShowTime and not hBox.bCanCancel, nTime, {x, y, w, h})					
		end
		hBox.OnItemMouseHover = hBox.OnItemMouseEnter
		
		hBox.OnItemMouseLeave = function()
			HideTip()
			this:SetObjectMouseOver(0)
		end
		hBuff:FormatAllItemPos()
	else
		hBox.nCount = nCount
		hBox.nEndFrame = nEndFrame
		hBox.bCanCancel = bCanCancel
		hBox.dwBuffID = dwBuffID
		hBox.nLevel = nLevel
		hBox.bSparking = Table_BuffNeedSparking(dwBuffID, nLevel)
		hBox.bShowTime = Table_BuffNeedShowTime(dwBuffID, nLevel)
		hBox:SetObject(UI_OBJECT_NOT_NEED_KNOWN, dwBuffID)
		hBox:SetObjectIcon(Table_GetBuffIconID(dwBuffID, nLevel))						
		if nCount > 1 then
			hBox:SetOverText(0, nCount)
		end
	end
end

function OpenPetPanel(bDisableSound)
	local hPlayer = GetClientPlayer()
	if not hPlayer then
		return
	end
	local hPet = hPlayer.GetPet()
	if not hPet then
		return
	end
	if not IsPetPanelOpened() then
		Wnd.OpenWindow("PetPanel")
	end
	local hFrame = Station.Lookup("Normal/PetPanel")
	hFrame.dwID = hPet.dwID
	PetPanel.Update(hFrame)
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND, g_sound.OpenFrame)
	end
end

function IsPetPanelOpened()
	local hFrame = Station.Lookup("Normal/PetPanel")
	if hFrame then
		return true
	end
	
	return false
end

function ClosePetPanel()
	if not IsPetPanelOpened() then
		return
	end
	Wnd.CloseWindow("PetPanel")
end


function PetPanel_SetAnchorDefault()
	PetPanel.Anchor.s = PetPanel.DefaultAnchor.s
	PetPanel.Anchor.r = PetPanel.DefaultAnchor.r
	PetPanel.Anchor.x = PetPanel.DefaultAnchor.x
	PetPanel.Anchor.y = PetPanel.DefaultAnchor.y
	FireEvent("PET_PANEL_ANCHOR_CHANGED")
end

function PetDisplayDataUpdate(szEvent)
	if szEvent == "PET_DISPLAY_DATA_UPDATE" then
		OpenPetPanel()
	end
end

RegisterEvent("CUSTOM_UI_MODE_SET_DEFAULT", PetPanel_SetAnchorDefault)
RegisterEvent("PET_DISPLAY_DATA_UPDATE", PetDisplayDataUpdate)