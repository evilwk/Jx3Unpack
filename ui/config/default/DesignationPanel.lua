DesignationPanel = 
{
}

function DesignationPanel.OnFrameCreate()
	this:RegisterEvent("CORRECT_AUTO_POS")
	this:RegisterEvent("OPEN_CHAR_INFO")
	this:RegisterEvent("CLOSE_CHAR_INFO")
	
	this:RegisterEvent("SYNC_DESIGNATION_DATA")
	this:RegisterEvent("SET_CURRENT_DESIGNATION")
	this:RegisterEvent("ACQUIRE_DESIGNATION")
	this:RegisterEvent("REMOVE_DESIGNATION")
	this:RegisterEvent("SET_GENERATION_NOTIFY")
	this:RegisterEvent("CHARACTER_PANEL_BRING_TOP")
end

function DesignationPanel.OnEvent(event)
	if event == "CORRECT_AUTO_POS" then
		if arg0 == "CharacterPanel" then
			DesignationPanel.OnCorrectPos(this)
		end
	elseif event == "OPEN_CHAR_INFO" or event == "CLOSE_CHAR_INFO" then
		DesignationPanel.OnCorrectPos(this)
	elseif event == "SYNC_DESIGNATION_DATA" or event == "SET_CURRENT_DESIGNATION" or event == "REMOVE_DESIGNATION" then
		DesignationPanel.Update(this)
		DesignationPanel.UpdateDesignation(this)
	elseif event == "SET_GENERATION_NOTIFY" then
		if arg0 == GetClientPlayer().dwID then
			DesignationPanel.Update(this)
			DesignationPanel.UpdateDesignation(this)
		end
	elseif event == "ACQUIRE_DESIGNATION" then
		if arg0 ~= 0 then
			DesignationPanel.bPrefix = true
			DesignationPanel.nLinkID = arg0
		elseif arg1 ~= 0 then
			DesignationPanel.bPrefix = false
			DesignationPanel.nLinkID = arg1
		end

		DesignationPanel.Update(this)
		DesignationPanel.UpdateDesignation(this)
		DesignationPanel.UpdateLinkShow(this)
	elseif event == "CHARACTER_PANEL_BRING_TOP" then
		this:BringToTop()
	end
end

function DesignationPanel.OnSetFocus()
	FireEvent("CHARACTER_PANEL_BRING_TOP")
end

function DesignationPanel.OnCorrectPos(frame)
	local nX = 380
	if IsCharInfoOpened() then
		nX = nX + 230
	end
	
	frame:SetPoint("TOPLEFT", 0, 0, GetCharacterPanelPath(), "TOPLEFT", nX, 0)
end

function DesignationPanel.OnFrameBreathe()
	if not this.nCount or this.nCount > 10 then
		DesignationPanel.UpdateCDInfo(this)
		this.nCount = 0
	else
		this.nCount = this.nCount + 1
	end
end

function DesignationPanel.UpdateCDInfo(frame)
	local player = GetClientPlayer()
	if not player then
		return
	end
	
	local handle = frame:Lookup("", "Handle_Designation")	
	local hWorld = handle:Lookup("World")
	local hCampTitle = handle:Lookup("Title")
	local hPrefix = handle:Lookup("Prefix")
	local hPostfix = handle:Lookup("Postfix")
	local hCourtesy = handle:Lookup("Courtesy")
	
	local bWorld = false
	local bCampTitle = false
	local szPrefixCD = ""
	local nPrefix = player.GetCurrentDesignationPrefix()
	if nPrefix ~= 0 then
		local aInfo = GetDesignationPrefixInfo(nPrefix)
		if aInfo then
			bWorld = aInfo.nType == DESIGNATION_PREFIX_TYPE.WORLD_DESIGNATION 
			bCampTitle = aInfo.nType == DESIGNATION_PREFIX_TYPE.MILITARY_RANK_DESIGNATION
			local dwCD = player.GetCDLeft(aInfo.dwCoolDownID)
			if dwCD ~= 0 then
				szPrefixCD = GetTimeText(dwCD, true, false, true, false)
			end
		end
	end

	local szPostfixCD = ""
	local nPostfix = player.GetCurrentDesignationPostfix()
	if nPostfix ~= 0 then
		local aInfo = GetDesignationPostfixInfo(nPostfix)
		if aInfo then
			local dwCD = player.GetCDLeft(aInfo.dwCoolDownID)
			if dwCD ~= 0 then
				szPostfixCD = GetTimeText(dwCD, true, false, true, false)
			end
		end
	end
	
	if bWorld then
		hWorld:Lookup("Handle_Title/Text_TitleCD"):SetText(szPrefixCD)
		hCampTitle:Lookup("Handle_Title/Text_TitleCD"):SetText("")
		hPrefix:Lookup("Handle_Title/Text_TitleCD"):SetText("")
	elseif bCampTitle then
		hWorld:Lookup("Handle_Title/Text_TitleCD"):SetText("")
		hCampTitle:Lookup("Handle_Title/Text_TitleCD"):SetText(szPrefixCD)
		hPrefix:Lookup("Handle_Title/Text_TitleCD"):SetText("")
	else
		hWorld:Lookup("Handle_Title/Text_TitleCD"):SetText("")
		hCampTitle:Lookup("Handle_Title/Text_TitleCD"):SetText("")
		hPrefix:Lookup("Handle_Title/Text_TitleCD"):SetText(szPrefixCD)
	end
		
	hPostfix:Lookup("Handle_Title/Text_TitleCD"):SetText(szPostfixCD)
	
	local nWorld = 0
	local nCampTitle = 0
	if nPrefix ~= 0 then
		local aPrefixInfo = GetDesignationPrefixInfo(nPrefix)
		if aPrefixInfo and aPrefixInfo.nType == DESIGNATION_PREFIX_TYPE.WORLD_DESIGNATION then
			nWorld = nPrefix
			nCampTitle = 0
			nPrefix = 0
		end	
	end
	
	if nPrefix ~= 0 then
		local aPrefixInfo = GetDesignationPrefixInfo(nPrefix)
		if aPrefixInfo and aPrefixInfo.nType == DESIGNATION_PREFIX_TYPE.MILITARY_RANK_DESIGNATION then
			nWorld = 0
			nCampTitle = nPrefix
			nPrefix = 0
		end	
	end
	
	local bEnbale = true
	if hWorld.dwID and hWorld.dwID ~= nWorld then
		if szPrefixCD ~= "" then
			bEnbale = false
		end
	end
	
	if hCampTitle.dwID and hCampTitle.dwID ~= nCampTitle then
		if szPrefixCD ~= "" then
			bEnbale = false
		end
	end
	
	if hPrefix.dwID and hPrefix.dwID ~= nPrefix then
		if szPrefixCD ~= "" then
			bEnbale = false
		end
	end
		
	if hPostfix.dwID and hPostfix.dwID ~= nPostfix then
		if szPostfixCD ~= "" then
			bEnbale = false
		end
	end
	
	frame:Lookup("Btn_Sure"):Enable(bEnbale)	
end

function DesignationPanel.GetCDTimeText(dwCD)
	local nSecond = math.ceil(dwCD / 16)
	if nSecond >= 3600 * 24 then
		return math.ceil(nSecond / 3600 / 24)..g_tStrings.STR_BUFF_H_TIME_D_SHORT
	elseif nSecond >= 3600 then
		return math.ceil(nSecond / 3600)..g_tStrings.STR_BUFF_H_TIME_H_SHORT
	elseif nSecond >= 60 then
		return math.ceil(nSecond / 60)..g_tStrings.STR_BUFF_H_TIME_M_SHORT
	elseif nSecond >= 1 then
		return math.ceil(nSecond)..g_tStrings.STR_BUFF_H_TIME_S_SHORT
	else
		return g_tStrings.DESGNATION_CD_NO
	end
end

function DesignationPanel.Update(frame)
	local player = GetClientPlayer()
	if not player then
		return
	end
	
	local handle = frame:Lookup("", "")
	local hList = handle:Lookup("Handle_Designation")	
	local szIniFile = "UI/Config/Default/DesignationPanel_World.ini"
	
	hList:Clear()

	local aPrefixAll = player.GetAcquiredDesignationPrefix()
	local aWorld = {}
	local aTitle = {}
	local aPrefix = {}
	for i, dwID in ipairs(aPrefixAll) do
		local aInfo = GetDesignationPrefixInfo(dwID)
		if aInfo.nType == DESIGNATION_PREFIX_TYPE.WORLD_DESIGNATION then
			table.insert(aWorld, dwID)
		elseif aInfo.nType == DESIGNATION_PREFIX_TYPE.MILITARY_RANK_DESIGNATION then
			table.insert(aTitle, dwID)
		else
			table.insert(aPrefix, dwID)
		end
	end

	local hWorld = hList:AppendItemFromIni(szIniFile, "Handle_Group", "World")
	
	local hTitle = hWorld:Lookup("Handle_Title")
	hTitle.bTitle = true
	hTitle.bWorldTitle = true
	hTitle:Lookup("Text_TitleDesc"):SetText(g_tStrings.DESGNATION_WORLD_TITLE)
	
	local hOption = hWorld:Lookup("Handle_Option")
	hOption:Lookup("Text_Name"):SetText(g_tStrings.DESGNATION_NO)
	hOption:Lookup("Image_Limit"):Show(false)
	hOption:Lookup("Text_CD"):SetText(g_tStrings.DESGNATION_CD_NO)	
	hOption.bWorld = true
	hOption.bCancel = true
	hOption.dwID = 0

	for i, dwID in ipairs(aWorld) do
		local t = g_tTable.Designation_Prefix:Search(dwID)
		local aInfo = GetDesignationPrefixInfo(dwID)
		if t and aInfo then
			hOption = hWorld:AppendItemFromIni(szIniFile, "Handle_Option")
			hOption.bWorld = true
			hOption.dwID = dwID
			hOption:Lookup("Text_Name"):SetText(t.szName)
			hOption:Lookup("Text_Name"):SetFontColor(GetItemFontColorByQuality(t.nQuality))
			hOption:Lookup("Image_Limit"):Show(aInfo.nOwnDuration ~= 0)
			local dwCD = player.GetCDInterval(aInfo.dwCoolDownID)
			if dwCD ~= 0 then
				hOption:Lookup("Text_CD"):SetText(DesignationPanel.GetCDTimeText(dwCD))
			else
				hOption:Lookup("Text_CD"):SetText(g_tStrings.DESGNATION_CD_NO)
			end
		end
	end
		
	hWorld:FormatAllItemPos()
	local w, h = hWorld:GetAllItemSize()
	hWorld:SetSize(w, h + 7)
	hWorld:Lookup("Image_GroupBg"):SetSize(w, h + 15)
	
	szIniFile = "UI/Config/Default/DesignationPanel_Camp.ini"
	
	local hCampTitle = hList:AppendItemFromIni(szIniFile, "Handle_Group", "Title")
	
	hTitle = hCampTitle:Lookup("Handle_Title")
	hTitle.bTitle = true
	hTitle.bCampTitleTitle = true
	hTitle:Lookup("Text_TitleDesc"):SetText(g_tStrings.DESGNATION_CAMP_TITLE)
	
	local hOption = hCampTitle:Lookup("Handle_Option")
	hOption:Lookup("Text_Name"):SetText(g_tStrings.DESGNATION_NO)
	hOption:Lookup("Image_Limit"):Show(false)
	hOption:Lookup("Text_CD"):SetText(g_tStrings.DESGNATION_CD_NO)	
	hOption.bCampTitle = true
	hOption.bCancel = true
	hOption.dwID = 0

	for i, dwID in ipairs(aTitle) do
		local t = g_tTable.Designation_Prefix:Search(dwID)
		local aInfo = GetDesignationPrefixInfo(dwID)
		if t and aInfo then
			hOption = hCampTitle:AppendItemFromIni(szIniFile, "Handle_Option")
			hOption.bCampTitle = true
			hOption.dwID = dwID
			hOption:Lookup("Text_Name"):SetText(t.szName)
			hOption:Lookup("Text_Name"):SetFontColor(GetItemFontColorByQuality(t.nQuality))
			hOption:Lookup("Image_Limit"):Show(aInfo.nOwnDuration ~= 0)
			local dwCD = player.GetCDInterval(aInfo.dwCoolDownID)
			if dwCD ~= 0 then
				hOption:Lookup("Text_CD"):SetText(DesignationPanel.GetCDTimeText(dwCD))
			else
				hOption:Lookup("Text_CD"):SetText(g_tStrings.DESGNATION_CD_NO)
			end
		end
	end
	
	hCampTitle:FormatAllItemPos()
	local w, h = hCampTitle:GetAllItemSize()
	hCampTitle:SetSize(w, h + 7)
	hCampTitle:Lookup("Image_GroupBg"):SetSize(w, h + 15)		
	
	szIniFile = "UI/Config/Default/DesignationPanel_Normal.ini"
	
	local hPrefix = hList:AppendItemFromIni(szIniFile, "Handle_Group", "Prefix")
	
	hTitle = hPrefix:Lookup("Handle_Title")
	hTitle.bTitle = true
	hTitle.bPrefixTitle = true
	hTitle:Lookup("Text_TitleDesc"):SetText(g_tStrings.DESGNATION_PREFIX_TITLE)
	
	local hOption = hPrefix:Lookup("Handle_Option")
	hOption:Lookup("Text_Name"):SetText(g_tStrings.DESGNATION_NO)
	hOption:Lookup("Image_Limit"):Show(false)
	hOption:Lookup("Text_CD"):SetText(g_tStrings.DESGNATION_CD_NO)	
	hOption.bPrefix = true
	hOption.bCancel = true
	hOption.dwID = 0

	for i, dwID in ipairs(aPrefix) do
		local t = g_tTable.Designation_Prefix:Search(dwID)
		local aInfo = GetDesignationPrefixInfo(dwID)
		if t and aInfo then
			hOption = hPrefix:AppendItemFromIni(szIniFile, "Handle_Option")
			hOption.bPrefix = true
			hOption.dwID = dwID
			hOption:Lookup("Text_Name"):SetText(t.szName)
			hOption:Lookup("Text_Name"):SetFontColor(GetItemFontColorByQuality(t.nQuality))
			hOption:Lookup("Image_Limit"):Show(aInfo.nOwnDuration ~= 0)
			local dwCD = player.GetCDInterval(aInfo.dwCoolDownID)
			if dwCD ~= 0 then
				hOption:Lookup("Text_CD"):SetText(DesignationPanel.GetCDTimeText(dwCD))
			else
				hOption:Lookup("Text_CD"):SetText(g_tStrings.DESGNATION_CD_NO)
			end
		end
	end
	
	hPrefix:FormatAllItemPos()
	local w, h = hPrefix:GetAllItemSize()
	hPrefix:SetSize(w, h + 7)
	hPrefix:Lookup("Image_GroupBg"):SetSize(w, h + 15)
	
	local aPostfix = player.GetAcquiredDesignationPostfix()
	
	local hPostfix = hList:AppendItemFromIni(szIniFile, "Handle_Group", "Postfix")
	
	hTitle = hPostfix:Lookup("Handle_Title")
	hTitle.bTitle = true
	hTitle.bPostfixTitle = true
	hTitle:Lookup("Text_TitleDesc"):SetText(g_tStrings.DESGNATION_POSTFIX_TITLE)
	
	local hOption = hPostfix:Lookup("Handle_Option")
	hOption:Lookup("Text_Name"):SetText(g_tStrings.DESGNATION_NO)
	hOption:Lookup("Image_Limit"):Show(false)
	hOption:Lookup("Text_CD"):SetText(g_tStrings.DESGNATION_CD_NO)
	hOption.bPrefix = true
	hOption.bCancel = true
	hOption.dwID = 0

	for i, dwID in ipairs(aPostfix) do
		local t = g_tTable.Designation_Postfix:Search(dwID)
		local aInfo = GetDesignationPostfixInfo(dwID)
		if t then
			hOption = hPostfix:AppendItemFromIni(szIniFile, "Handle_Option")
			hOption.bPostfix = true
			hOption.dwID = dwID
			hOption:Lookup("Text_Name"):SetText(t.szName)
			hOption:Lookup("Text_Name"):SetFontColor(GetItemFontColorByQuality(t.nQuality))
			hOption:Lookup("Image_Limit"):Show(aInfo.nOwnDuration ~= 0)
			local dwCD = player.GetCDInterval(aInfo.dwCoolDownID)
			if dwCD ~= 0 then
				hOption:Lookup("Text_CD"):SetText(DesignationPanel.GetCDTimeText(dwCD))
			else
				hOption:Lookup("Text_CD"):SetText(g_tStrings.DESGNATION_CD_NO)
			end			
		end
	end
	
	hPostfix:FormatAllItemPos()
	local w, h = hPostfix:GetAllItemSize()
	hPostfix:SetSize(w, h + 7)
	hPostfix:Lookup("Image_GroupBg"):SetSize(w, h + 15)
	
	local hCourtesy = hList:AppendItemFromIni(szIniFile, "Handle_Group", "Courtesy")
	
	hTitle = hCourtesy:Lookup("Handle_Title")
	hTitle.bTitle = true
	hTitle.bCourtesyTitle = true
	hTitle:Lookup("Text_TitleDesc"):SetText(g_tStrings.DESGNATION_COURTESY_TITLE)
	
	local hOption = hCourtesy:Lookup("Handle_Option")
	hOption:Lookup("Text_Name"):SetText(g_tStrings.DESGNATION_NO)
	hOption:Lookup("Image_Limit"):Show(false)
	hOption:Lookup("Text_CD"):SetText(g_tStrings.DESGNATION_CD_NO)	
	hOption.bCourtesy = true
	hOption.bCancel = true
	hOption.dwID = 0
		
	local szCourtesyName = ""
	local aGen = g_tTable.Designation_Generation:Search(player.dwForceID, player.GetDesignationGeneration())
	if aGen then
		szCourtesyName = aGen.szName
		if aGen.szCharacter and aGen.szCharacter ~= "" then
			local aCharacter = g_tTable[aGen.szCharacter]:Search(player.GetDesignationByname())
			if aCharacter then
				szCourtesyName = szCourtesyName..aCharacter.szName
			end
		end
	end
	
	if szCourtesyName ~= "" then
		hOption = hCourtesy:AppendItemFromIni(szIniFile, "Handle_Option")
		hOption.bCourtesy = true
		hOption.dwID = 1
		hOption:Lookup("Text_Name"):SetText(szCourtesyName)
		hOption:Lookup("Image_Limit"):Show(false)
		hOption:Lookup("Text_CD"):SetText(g_tStrings.DESGNATION_CD_NO)			
	end

	hCourtesy:FormatAllItemPos()
	local w, h = hCourtesy:GetAllItemSize()
	hCourtesy:SetSize(w, h + 7)
	hCourtesy:Lookup("Image_GroupBg"):SetSize(w, h + 15)
	
	DesignationPanel.UpdateCurrentDesignation(frame)
	
	DesignationPanel.UpdateScrollInfo(hList)
end

function DesignationPanel.UpdateCurrentDesignation(frame)
	local player = GetClientPlayer()
	if not player then
		return
	end
	
	local nPrefix = player.GetCurrentDesignationPrefix()
	local nPostfix = player.GetCurrentDesignationPostfix()
	local nCourtesy = 0
	if player.GetDesignationBynameDisplayFlag() then
		nCourtesy = 1
	end
	
	local handle = frame:Lookup("", "Handle_Designation")
	
	frame.bDisableUpdate = true
	local aInfo = GetDesignationPrefixInfo(nPrefix)
	if aInfo and aInfo.nType == DESIGNATION_PREFIX_TYPE.WORLD_DESIGNATION then
		DesignationPanel.SelByID(handle:Lookup("World"), nPrefix)
		DesignationPanel.SelByID(handle:Lookup("Title"), 0)
		DesignationPanel.SelByID(handle:Lookup("Prefix"), 0)
		DesignationPanel.SelByID(handle:Lookup("Postfix"), 0)
		DesignationPanel.SelByID(handle:Lookup("Courtesy"), 0)
	elseif aInfo and aInfo.nType == DESIGNATION_PREFIX_TYPE.MILITARY_RANK_DESIGNATION then
		DesignationPanel.SelByID(handle:Lookup("World"), 0)
		DesignationPanel.SelByID(handle:Lookup("Title"), nPrefix)
		DesignationPanel.SelByID(handle:Lookup("Prefix"), 0)
		DesignationPanel.SelByID(handle:Lookup("Postfix"), 0)
		DesignationPanel.SelByID(handle:Lookup("Courtesy"), 0)
	else
		DesignationPanel.SelByID(handle:Lookup("World"), 0)
		DesignationPanel.SelByID(handle:Lookup("Title"), 0)
		DesignationPanel.SelByID(handle:Lookup("Prefix"), nPrefix)
		DesignationPanel.SelByID(handle:Lookup("Postfix"), nPostfix)
		DesignationPanel.SelByID(handle:Lookup("Courtesy"), nCourtesy)
	end
	frame.bDisableUpdate = false
	
	DesignationPanel.UpdateSelectDesignation(frame)
end

function DesignationPanel.SelByID(handle, dwID)
	local nCount = handle:GetItemCount() - 1
	for i = 0, nCount, 1 do
		local hI = handle:Lookup(i)
		if hI.dwID == dwID then
			DesignationPanel.Sel(hI)
			return
		end
	end
	handle.dwID = nil
	handle.bSel = false
end

function DesignationPanel.UpdateScrollInfo(hList)
	hList:FormatAllItemPos()
	local frame = hList:GetRoot()
	local scroll = frame:Lookup("Scroll_List")
	local btnUp = frame:Lookup("Btn_Up")
	local btnDown = frame:Lookup("Btn_Down")
	
	local wAll, hAll = hList:GetAllItemSize()
    local w, h = hList:GetSize()
    local nCountStep = math.ceil((hAll - h) / 10)
    scroll:SetStepCount(nCountStep)
    if nCountStep > 0 and hList:IsVisible() then
    	scroll:Show()
    	btnUp:Show()
    	btnDown:Show()
    else
    	scroll:Hide()
    	btnUp:Hide()
    	btnDown:Hide()
    end
end

function DesignationPanel.OnScrollBarPosChanged()
	local frame = this:GetRoot()
	local hList = frame:Lookup("", "Handle_Designation")
	local btnUp = frame:Lookup("Btn_Up")
	local btnDown = frame:Lookup("Btn_Down")
	
	local nCurrentValue = this:GetScrollPos()
	btnUp:Enable(nCurrentValue ~= 0)
	btnDown:Enable(nCurrentValue ~= this:GetStepCount())
    hList:SetItemStartRelPos(0, - nCurrentValue * 10)
end

function DesignationPanel.OnMouseWheel()
	if this:GetName() == "DesignationPanel" then
		local nDistance = Station.GetMessageWheelDelta()
		this:Lookup("Scroll_List"):ScrollNext(nDistance)
		return 1
	end
end

function DesignationPanel.OnLButtonDown()
	DesignationPanel.OnLButtonHold()
end

function DesignationPanel.OnLButtonHold()
	local szName = this:GetName()
	local frame = this:GetRoot()
	if szName == "Btn_Up" then
		frame:Lookup("Scroll_List"):ScrollPrev(1)
	elseif szName == "Btn_Down" then
		frame:Lookup("Scroll_List"):ScrollNext(1)
	end
end

function DesignationPanel.UpdateDesignation(frame)
	local player = GetClientPlayer()
	if not player then
		return
	end
	frame:Lookup("", "Text_Designation"):SetText(GetPlayerDesignation(player.dwID))
end

function DesignationPanel.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_Sure" then
		local player = GetClientPlayer()
		local nPrefix = player.GetCurrentDesignationPrefix()
		local nPostfix = player.GetCurrentDesignationPostfix()
		local bShow = player.GetDesignationBynameDisplayFlag()
		local bChange = false
		local frame = this:GetRoot()
		local handle = frame:Lookup("", "Handle_Designation")
		local hWorld = handle:Lookup("World")
		local hCampTitle = handle:Lookup("Title")
		local hPrefix = handle:Lookup("Prefix")
		local hPostfix = handle:Lookup("Postfix")
		local hCourtesy = handle:Lookup("Courtesy")
		
		if hWorld.dwID and hWorld.dwID ~= 0 then
			if hWorld.dwID ~= nPrefix then
				bChange = true
				nPrefix = hWorld.dwID
				nPostfix = 0
				bShow = false		
			end
		elseif hCampTitle.dwID and hCampTitle.dwID ~= 0 then
			if hCampTitle.dwID ~= nPrefix then
				bChange = true
				nPrefix = hCampTitle.dwID
				nPostfix = 0
				bShow = false		
			end
		else
			if hPrefix.dwID and hPrefix.dwID ~= nPrefix then
				bChange = true
				nPrefix = hPrefix.dwID			
			end
			
			if hPostfix.dwID and hPostfix.dwID ~= nPostfix then
				bChange = true
				nPostfix = hPostfix.dwID
			end
			
			if hCourtesy.dwID and hCourtesy.dwID ~= 0 then
				if not bShow then
					bChange = true
					bShow = true
				end
			else
				if bShow then
					bChange = true
					bShow = false
				end
			end
		end
		
		if bChange then
			player.SetCurrentDesignation(nPrefix, nPostfix, bShow)
		end
		
		CloseDesignationPanel()
	elseif szName == "Btn_Cancel" then
		CloseDesignationPanel()
	elseif szName == "Btn_Close" then
		CloseDesignationPanel()
	end
end

function DesignationPanel.UpdateShowInfo(hI)
	local img = hI:Lookup("Image_Sel")
	if hI.bSel then
		img:Show()
		img:SetAlpha(255)
	elseif hI.bOver then
		img:Show()
		img:SetAlpha(128)
	else
		img:Hide()
	end
end

function DesignationPanel.OnItemMouseEnter()
	if this.bWorld then
		this.bOver = true
		DesignationPanel.UpdateShowInfo(this)
		
		if this.dwID ~= 0 then
			local x, y = this:GetAbsPos()
			local w, h = this:GetSize()
			OutputDesignationTip(this.dwID, true, {x, y, w, h})
		end
	elseif this.bCampTitle then
		this.bOver = true
		DesignationPanel.UpdateShowInfo(this)
		
		if this.dwID ~= 0 then
			local x, y = this:GetAbsPos()
			local w, h = this:GetSize()
			OutputDesignationTip(this.dwID, true, {x, y, w, h})
		end
	elseif this.bPrefix then
		this.bOver = true
		DesignationPanel.UpdateShowInfo(this)
		
		if this.dwID ~= 0 then
			local x, y = this:GetAbsPos()
			local w, h = this:GetSize()
			OutputDesignationTip(this.dwID, true, {x, y, w, h})
		end
	elseif this.bPostfix then
		this.bOver = true
		DesignationPanel.UpdateShowInfo(this)

		if this.dwID ~= 0 then
			local x, y = this:GetAbsPos()
			local w, h = this:GetSize()
			OutputDesignationTip(this.dwID, false, {x, y, w, h})
		end
	elseif this.bCourtesy then
		this.bOver = true
		DesignationPanel.UpdateShowInfo(this)
		
		if this.dwID ~= 0 then
			local player = GetClientPlayer()
			local szCourtesyName = this:Lookup("Text_Name"):GetText()
			local nPrefix = player.GetCurrentDesignationPrefix()
			local nPostfix = player.GetCurrentDesignationPostfix()
			local nGeneration = player.GetDesignationGeneration()
			local nCharacter = player.GetDesignationByname()
			local bShow = player.GetDesignationBynameDisplayFlag()
			local nForceID = player.dwForceID
			local aGen = g_tTable.Designation_Generation:Search(nForceID, nGeneration)
			if aGen then			
				local szTip = GetFormatText(szCourtesyName.."\n", 31)
				if aGen.szDesc then
					szTip = szTip..aGen.szDesc
				end
				local x, y = this:GetAbsPos()
				local w, h = this:GetSize()
				OutputTip(szTip, 345, {x, y, w, h})
			end		
		end
	elseif this.bTitle then
		this.bOver = true
		DesignationPanel.UpdateTileInfo(this)
	end
end

function DesignationPanel.OnItemMouseLeave()
	if this.bWorld then
		this.bOver = false
		DesignationPanel.UpdateShowInfo(this)
		
		HideTip()
	elseif this.bCampTitle then
		this.bOver = false
		DesignationPanel.UpdateShowInfo(this)
		
		HideTip()
	elseif this.bPrefix then
		this.bOver = false
		DesignationPanel.UpdateShowInfo(this)
		
		HideTip()
	elseif this.bPostfix then
		this.bOver = false
		DesignationPanel.UpdateShowInfo(this)
		
		HideTip()
	elseif this.bCourtesy then
		this.bOver = false
		DesignationPanel.UpdateShowInfo(this)
	
		HideTip()
	elseif this.bTitle then
		this.bOver = false
		DesignationPanel.UpdateTileInfo(this)
	end
end

function DesignationPanel.GetPrefixName(dwID)
	if dwID and dwID ~= 0 then
		local t = g_tTable.Designation_Prefix:Search(dwID)
		if t then
			return t.szName
		end		
	end
	return g_tStrings.DESGNATION_NO
end

function DesignationPanel.GetPostfixName(dwID)
	if dwID and dwID ~= 0 then
		local t = g_tTable.Designation_Postfix:Search(dwID)
		if t then
			return t.szName
		end
	end
	return g_tStrings.DESGNATION_NO
end

function DesignationPanel.GetCourtesyName(bShow)
	if bShow then
		local player = GetClientPlayer()
		local nGeneration = player.GetDesignationGeneration()
		local nCharacter = player.GetDesignationByname()
		local nForceID = player.dwForceID	
		local aGen = g_tTable.Designation_Generation:Search(nForceID, nGeneration)
		if aGen then
			local szDesignation = aGen.szName
			if aGen.szCharacter and aGen.szCharacter ~= "" then
				local aCharacter = g_tTable[aGen.szCharacter]:Search(nCharacter)
				if aCharacter then
					szDesignation = szDesignation..aCharacter.szName
				end
			end
			return szDesignation
		end
	end
	return g_tStrings.DESGNATION_NO
end

function DesignationPanel.GetBtnSureTip(frame)
	local szTip = ""
	
	local player = GetClientPlayer()
	local nWorld = 0
	local nCampTitle = 0
	local nPrefix = player.GetCurrentDesignationPrefix()
	local nPostfix = player.GetCurrentDesignationPostfix()
	local bShow = player.GetDesignationBynameDisplayFlag()
	local szPrefixCD = ""

	if nPrefix ~= 0 then
		local aInfo = GetDesignationPrefixInfo(nPrefix)
		if aInfo then
			local dwCD = player.GetCDLeft(aInfo.dwCoolDownID)
			if dwCD ~= 0 then
				szPrefixCD = GetTimeText(dwCD, true, false, true, false)
			end
			if aInfo.nType == DESIGNATION_PREFIX_TYPE.WORLD_DESIGNATION then
				nWorld = nPrefix
				nCampTitle = 0
				nPrefix = 0
			elseif aInfo.nType == DESIGNATION_PREFIX_TYPE.MILITARY_RANK_DESIGNATION then
				nWorld = 0
				nCampTitle = nPrefix
				nPrefix = 0
			end
		end
	end
	
	local szPostfixCD = ""
	if nPostfix ~= 0 then
		local aInfo = GetDesignationPostfixInfo(nPostfix)
		if aInfo then
			local dwCD = player.GetCDLeft(aInfo.dwCoolDownID)
			if dwCD ~= 0 then
				szPostfixCD = GetTimeText(dwCD, true, false, true, false)
			end
		end
	end
	
	local handle = frame:Lookup("", "Handle_Designation")
	local hWorld = handle:Lookup("World")
	local hCampTitle = handle:Lookup("Title")
	local hPrefix = handle:Lookup("Prefix")
	local hPostfix = handle:Lookup("Postfix")
	local hCourtesy = handle:Lookup("Courtesy")
	
--[[	
	if hWorld.dwID and hWorld.dwID ~= nWorld then
		local szOld = DesignationPanel.GetPrefixName(nWorld)
		local szNew = DesignationPanel.GetPrefixName(hWorld.dwID)
		szTip = szTip..GetFormatText(FormatString(g_tStrings.DESGNATION_MODIFY_WORLD, szOld, szNew), 106)
		if szPrefixCD ~= "" and nWorld ~= 0 then
			szTip = szTip..GetFormatText(FormatString(g_tStrings.DESGNATION_CD_LEFT_TIME.."\n", szPrefixCD), 106)
		else
			szTip = szTip..GetFormatText("\n", 106)
		end
	end
	
	if hPrefix.dwID and hPrefix.dwID ~= nPrefix then
		local szOld = DesignationPanel.GetPrefixName(nPrefix)
		local szNew = DesignationPanel.GetPrefixName(hPrefix.dwID)
		szTip = szTip..GetFormatText(FormatString(g_tStrings.DESGNATION_MODIFY_PREFIX, szOld, szNew), 106)
		if szPrefixCD ~= "" and nPrefix ~= 0 then
			szTip = szTip..GetFormatText(FormatString(g_tStrings.DESGNATION_CD_LEFT_TIME.."\n", szPrefixCD), 106)
		else
			szTip = szTip..GetFormatText("\n", 106)
		end
	end
		
	if hPostfix.dwID and hPostfix.dwID ~= nPostfix then
		local szOld = DesignationPanel.GetPostfixName(nPostfix)
		local szNew = DesignationPanel.GetPostfixName(hPostfix.dwID)
		szTip = szTip..GetFormatText(FormatString(g_tStrings.DESGNATION_MODIFY_POSTFIX, szOld, szNew), 106)
		if szPostfixCD ~= "" then
			szTip = szTip..GetFormatText(FormatString(g_tStrings.DESGNATION_CD_LEFT_TIME.."\n", szPostfixCD), 106)
		else
			szTip = szTip..GetFormatText("\n", 106)
		end
	end
		
	local bCourtesy = false
	if hCourtesy.dwID and hCourtesy.dwID ~= 0 then
		if not bShow then
			bCourtesy = true
		end
	else
		if bShow then
			bCourtesy = true
		end
	end
	
	if bCourtesy then
		local szOld = DesignationPanel.GetCourtesyName(bShow)
		local szNew = DesignationPanel.GetCourtesyName(not bShow)
		szTip = szTip..GetFormatText(FormatString(g_tStrings.DESGNATION_MODIFY_COURTESY.."\n", szOld, szNew), 106)
	end
]]

	if hWorld.dwID and hWorld.dwID ~= nWorld then
		if szPrefixCD ~= "" and nWorld ~= 0 then
			szTip = szTip..GetFormatText(g_tStrings.DESGNATION_CHANGE_CONDITION_WORLD, 162)..
				GetFormatText(FormatString(g_tStrings.DESGNATION_CD_LEFT_TIME.."\n", szPrefixCD), 166)
		end
	end
	
	if hCampTitle.dwID and hCampTitle.dwID ~= nCampTitle then
		if szPrefixCD ~= "" and nCampTitle ~= 0 then
			szTip = szTip..GetFormatText(g_tStrings.DESGNATION_CHANGE_CONDITION_TITLE, 162)..
				GetFormatText(FormatString(g_tStrings.DESGNATION_CD_LEFT_TIME.."\n", szPrefixCD), 166)
		end
	end
	
	if hPrefix.dwID and hPrefix.dwID ~= nPrefix then
		if szPrefixCD ~= "" and nPrefix ~= 0 then
			szTip = szTip..GetFormatText(g_tStrings.DESGNATION_CHANGE_CONDITION_PREFIX, 162)..
				GetFormatText(FormatString(g_tStrings.DESGNATION_CD_LEFT_TIME.."\n", szPrefixCD), 166)
		end
	end
		
	if hPostfix.dwID and hPostfix.dwID ~= nPostfix then
		if szPostfixCD ~= "" then
			szTip = szTip..GetFormatText(g_tStrings.DESGNATION_CHANGE_CONDITION_POSTFIX, 162)..
				GetFormatText(FormatString(g_tStrings.DESGNATION_CD_LEFT_TIME.."\n", szPostfixCD), 166)
		end
	end
	
	if szTip ~= "" then
		szTip = GetFormatText(g_tStrings.DESGNATION_CHANGE_CONDITION, 162)..szTip
	end
		
	return szTip
end

function DesignationPanel.OnMouseEnter()
	local szName = this:GetName()
	if szName == "Btn_Sure" then
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
		local szTip = DesignationPanel.GetBtnSureTip(this:GetRoot())
		if szTip and szTip ~= "" then
			OutputTip(szTip, 600, {x, y, w, h})
		end
	end
end

function DesignationPanel.OnRefreshTip()
	DesignationPanel.OnMouseEnter()
end

function DesignationPanel.OnMouseLeave()
	local szName = this:GetName()
	if szName == "Btn_Sure" then
		HideTip()
	end
end

function DesignationPanel.UpdateTileInfo(hI)
	if hI.bOver then
		if this.bCollapse then
			this:Lookup("Image_Expand"):SetFrame(9)
		else
			this:Lookup("Image_Expand"):SetFrame(13)
		end
	else
		if this.bCollapse then
			this:Lookup("Image_Expand"):SetFrame(8)
		else
			this:Lookup("Image_Expand"):SetFrame(12)
		end
	end
end

function DesignationPanel.Sel(hI)
	local hList = hI:GetParent()
	local nCount = hList:GetItemCount() - 1
	for i = 0, nCount, 1 do
		local hB = hList:Lookup(i)
		if hB.bSel then
			hB.bSel = false
			DesignationPanel.UpdateShowInfo(hB)
			break
		end
	end
		
	hI.bSel = true
	DesignationPanel.UpdateShowInfo(hI)
	hList.bSel = true
	hList.dwID = hI.dwID
	
	local frame = hList:GetRoot()
	local bDisable = frame.bDisableUpdate
	
	frame.bDisableUpdate = true
	if hI.dwID ~= 0 then
		local handle = hList:GetParent()
		if hI.bWorld then
			DesignationPanel.SelByID(handle:Lookup("Title"), 0)
			DesignationPanel.SelByID(handle:Lookup("Prefix"), 0)
			DesignationPanel.SelByID(handle:Lookup("Postfix"), 0)
			DesignationPanel.SelByID(handle:Lookup("Courtesy"), 0)
		elseif hI.bCampTitle then
			DesignationPanel.SelByID(handle:Lookup("World"), 0)
			DesignationPanel.SelByID(handle:Lookup("Prefix"), 0)
			DesignationPanel.SelByID(handle:Lookup("Postfix"), 0)
			DesignationPanel.SelByID(handle:Lookup("Courtesy"), 0)
		else
			DesignationPanel.SelByID(handle:Lookup("World"), 0)
			DesignationPanel.SelByID(handle:Lookup("Title"), 0)
		end
	end
	frame.bDisableUpdate = false
	
	if not bDisable then
		DesignationPanel.UpdateSelectDesignation(frame)
	end
end

function DesignationPanel.UpdateSelectDesignation(frame)
	local handle = frame:Lookup("", "Handle_Designation")
	
	local szDesignation = ""
	local hWorld = handle:Lookup("World")
	local hCampTitle = handle:Lookup("Title")
	if hWorld.bSel and hWorld.dwID ~= 0 then
		local t = g_tTable.Designation_Prefix:Search(hWorld.dwID)
		if t then
			szDesignation = t.szName
		end
	elseif hCampTitle.bSel and hCampTitle.dwID ~= 0 then
		local t = g_tTable.Designation_Prefix:Search(hCampTitle.dwID)
		if t then
			szDesignation = t.szName
		end
	else
		local hPrefix = handle:Lookup("Prefix")
		if hPrefix.bSel and hPrefix.dwID then
			local t = g_tTable.Designation_Prefix:Search(hPrefix.dwID)
			if t then
				szDesignation = szDesignation..t.szName
			end
		end	

		local hPostfix = handle:Lookup("Postfix")
		if hPostfix.bSel and hPostfix.dwID then
			local t = g_tTable.Designation_Postfix:Search(hPostfix.dwID)
			if t then
				szDesignation = szDesignation..t.szName
			end
		end	

		local hCourtesy = handle:Lookup("Courtesy")
		if hCourtesy.bSel and hCourtesy.dwID == 1 then
			local player = GetClientPlayer()
			local aGen = g_tTable.Designation_Generation:Search(player.dwForceID, player.GetDesignationGeneration())
			if aGen then
				szDesignation = szDesignation..aGen.szName
				if aGen.szCharacter and aGen.szCharacter ~= "" then
					local aCharacter = g_tTable[aGen.szCharacter]:Search(player.GetDesignationByname())
					if aCharacter then
						szDesignation = szDesignation..aCharacter.szName
					end
				end
			end
		end
	end
	
	frame:Lookup("", "Text_Designation"):SetText(szDesignation)
	
	DesignationPanel.UpdateCDInfo(frame)
end

function DesignationPanel.OnItemLButtonDown()
	if this.bWorld then
		if IsCtrlKeyDown() then
			EditBox_AppendLinkDesignation(this.dwID, true)
		else
			DesignationPanel.Sel(this)
		end	
	elseif this.bCampTitle then
		if IsCtrlKeyDown() then
			EditBox_AppendLinkDesignation(this.dwID, true)
		else
			DesignationPanel.Sel(this)
		end	
	elseif this.bPrefix then
		if IsCtrlKeyDown() then
			EditBox_AppendLinkDesignation(this.dwID, true)
		else
			DesignationPanel.Sel(this)
		end
	elseif this.bPostfix then
		if IsCtrlKeyDown() then
			EditBox_AppendLinkDesignation(this.dwID, false)
		else
			DesignationPanel.Sel(this)
		end
	end
end

function DesignationPanel.OnItemLButtonClick()
	if this.bWorld then
		DesignationPanel.Sel(this)
	elseif this.bCampTitle then
		DesignationPanel.Sel(this)
	elseif this.bPrefix then
		DesignationPanel.Sel(this)
	elseif this.bPostfix then
		DesignationPanel.Sel(this)
	elseif this.bCourtesy then
		DesignationPanel.Sel(this)
	elseif this.bTitle then
		DesignationPanel.ExpandOrCollapse(this)
	end
end

function DesignationPanel.ExpandOrCollapse(hI)
	local hList = hI:GetParent()
	local nStart = hI:GetIndex() + 1
	local nCount = hList:GetItemCount() - 1
	if hI.bCollapse then
		hI.bCollapse = false
		DesignationPanel.UpdateTileInfo(hI)
		local w, h = hList:GetAllItemSize()
		hList:SetSize(w, h + 7)
		hList:Lookup("Image_GroupBg"):SetSize(w, h + 15)
		hList:Lookup("Image_GroupBg"):Show()
		for i = nStart, nCount, 1 do
			hList:Lookup(i):Show()
		end		
	else
		hI.bCollapse = true
		DesignationPanel.UpdateTileInfo(hI)
		local w, h = hI:GetSize()
		hList:SetSize(w, h + 7)
		hList:Lookup("Image_GroupBg"):SetSize(w, h + 15)
		hList:Lookup("Image_GroupBg"):Hide()
		for i = nStart, nCount, 1 do
			hList:Lookup(i):Hide()
		end
	end
	local handle = hList:GetParent()
	DesignationPanel.UpdateScrollInfo(handle)
end

function DesignationPanel.OnItemLButtonDBClick()
	return DesignationPanel.OnItemLButtonClick()
end

function DesignationPanel.UpdateLinkShow(frame)
	local dwID = DesignationPanel.nLinkID
	if not dwID then
		return
	end

	local handle = frame:Lookup("", "Handle_Designation")
	
	local hList = nil
	if bPrefix then
		local t = GetDesignationPrefixInfo(dwID)
		if t and t.nType == DESIGNATION_PREFIX_TYPE.WORLD_DESIGNATION then
			hList = handle:Lookup("World")
		elseif t and t.nType == DESIGNATION_PREFIX_TYPE.MILITARY_RANK_DESIGNATION then
			hList = handle:Lookup("Title")
		else
			hList = handle:Lookup("Prefix")
		end
	else
		hList = handle:Lookup("Postfix")
	end
	
	if hList.bCollapse then
		DesignationPanel.ExpandOrCollapse(hList)
	end
	
	local hLink = nil
	local nCount = hList:GetItemCount() - 1
	for i = 0, nCount, 1 do
		local hI = hList:Lookup(i)
		if hI.dwID == dwID then
			hLink = hI
			break
		end
	end
	
	if hLink then
		local x, y = hLink:GetAbsPos()
		local w, h = hLink:GetSize()
		local xL, yL = handle:GetAbsPos()
		local wL, hL = handle:GetSize()
		local scroll = frame:Lookup("Scroll_List")
		if y < yL then
			scroll:ScrollPrev(math.ceil((yL - y) / 10))
		elseif y + h > yL + hL then
			scroll:ScrollNext(math.ceil((y + h - yL - hL) / 10))
		end		
	end
end

function OpenDesignationPanel(bDisableSound, nLinkID, bPrefix)
	DesignationPanel.nLinkID = nLinkID
	DesignationPanel.bPrefix = bPrefix

	OpenCharacterPanel()
	if IsDesignationPanelOpened() then
		DesignationPanel.UpdateLinkShow(Station.Lookup("Normal/DesignationPanel"))
		return
	end
	local frame = Wnd.OpenWindow("DesignationPanel")
	frame:Show()
	DesignationPanel.Update(frame)
	DesignationPanel.UpdateDesignation(frame)
	DesignationPanel.UpdateLinkShow(frame)
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end

	FireEvent("OPEN_DESIGNATION_PANEL")
	
	DesignationPanel.OnCorrectPos(frame)
end

function IsDesignationPanelOpened()
	local frame = Station.Lookup("Normal/DesignationPanel")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end

function CloseDesignationPanel(bDisableSound, bIgnor)
	if not IsDesignationPanelOpened() then
		return
	end

	local frame = Station.Lookup("Normal/DesignationPanel")
	frame:Hide()
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end
	
	local argS = arg0
	arg0 = not bIgnor
	FireEvent("CLOSE_DESIGNATION_PANEL")
	arg0 = argS
end

function OutputDesignationTip(nID, bPrefix, Rect, bLink)
	local szAdd = ""
	local aInfo, aDesignation = nil, nil
	if bPrefix then
		szAdd = "Prefix"
		aInfo = GetDesignationPrefixInfo(nID)
		aDesignation = g_tTable.Designation_Prefix:Search(nID)
	else
		szAdd = "Postfix"
		aInfo = GetDesignationPostfixInfo(nID)
		aDesignation = g_tTable.Designation_Postfix:Search(nID)
	end
	if not aDesignation or not aInfo then
		return
	end
    
	local szTip = "<text>text="..EncodeComponentsString(aDesignation.szName.."\n").." font=31 "..GetItemFontColorByQuality(aDesignation.nQuality, true).." </text>"
	if bPrefix then
		if aInfo.nType == DESIGNATION_PREFIX_TYPE.WORLD_DESIGNATION then
			szTip = szTip..GetFormatText(g_tStrings.DESGNATION_WORLD, 106)
		elseif aInfo.nType == DESIGNATION_PREFIX_TYPE.MILITARY_RANK_DESIGNATION then
			szTip = szTip..GetFormatText(g_tStrings.DESGNATION_TITLE, 106)
		else
			szTip = szTip..GetFormatText(g_tStrings.DESGNATION_PREFIX, 106)
		end
	else
		szTip = szTip..GetFormatText(g_tStrings.DESGNATION_POSTFIX, 106)
	end
	
	if aDesignation.dwAchievement ~= 0 then
		local aAchievement = g_tTable.Achievement:Search(aDesignation.dwAchievement)
		if aAchievement then
			szTip = szTip..GetFormatText(g_tStrings.DESGNATION_AHIVEMENT_GET, 106).."<text>text="..EncodeComponentsString("["..aAchievement.szName.."]").." font=103"..
			" eventid=341 name=\"achievement\" script=\"this.dwAchievement = "..aDesignation.dwAchievement.."\" </text>"..
			GetFormatText(g_tStrings.DESGNATION_AHIVEMENT_GET1.."\n", 106)
		end
	end
	
	if aDesignation.dwTableIndex ~= 0 then
		local itemInfo = GetItemInfo(5, aDesignation.dwTableIndex)
		if itemInfo then
			szTip = szTip..GetFormatText(g_tStrings.DESGNATION_USE_ITEM_GET, 106).."<text>text="..EncodeComponentsString("["..GetItemNameByItemInfo(itemInfo).."]")
				.." font=102"..GetItemFontColorByQuality(itemInfo.nQuality, true)..
			" eventid=341 name=\"item\" script=\"this.dwTableType = 5 this.dwTableIndex = "..aDesignation.dwTableIndex.."\" </text>"..
			GetFormatText(g_tStrings.DESGNATION_USE_ITEM_GET1.."\n", 106)
		end
	end
	
	if aInfo.dwBuffID ~= 0 and aInfo.nBuffLevel ~= 0 then
		local szDesc = GetBuffDesc(aInfo.dwBuffID, aInfo.nBuffLevel, "desc")
		if szDesc then
			szDesc = szDesc..g_tStrings.STR_FULL_STOP.."\n"
		end
		szTip = szTip.."<text>text="..EncodeComponentsString(szDesc).." font=165 </text>"
	end
	
	if aDesignation.szDesc and aDesignation.szDesc ~= "" then
		szTip = szTip..aDesignation.szDesc
	end
	
	if aInfo.dwCoolDownID ~= 0 then
		local dwCD = GetCoolDownFrame(aInfo.dwCoolDownID)
		if dwCD and dwCD ~= 0 then
			local szLeftTime = GetTimeText(dwCD, true, false, true)
			szTip = szTip..GetFormatText(FormatString("\n"..g_tStrings.DESGNATION_NEED_REST, szLeftTime), 162)
		end
	end
	
	if bLink then
		if aInfo.nOwnDuration > 0 then
			local szTime = GetTimeText(aInfo.nOwnDuration, false, true, true)
			szTip = szTip..GetFormatText(FormatString("\n"..g_tStrings.DESGNATION_OWN_TIME, szTime), 163)
		end
	else
		local player = GetClientPlayer()
		local nEndTime = nil
		if bPrefix then
			nEndTime = player.GetDesignationPrefixEndTime(nID)
		else
			nEndTime = player.GetDesignationPostfixEndTime(nID)
		end
		if nEndTime and nEndTime > 0 then
			local nDelta = nEndTime - GetCurrentTime()
			if nDelta < 0 then
				nDelta = 0
			end
			local szTime = GetTimeText(nDelta, false, true, true)
			szTip = szTip..GetFormatText("\n"..FormatString(g_tStrings.DESGNATION_DISSAPPEAR_TIME, szTime), 163)
		end
	end

    local szName = "Designation"..szAdd..nID
    
    OutputTip(szTip, 345, Rect, nil, bLink, szName)
    local handle = GetTipHandle(bLink, szName)
    
    local text = handle:Lookup("achievement")
    if text then
    	text.OnItemLButtonClick = function()
    		OpenAchievementPanel(nil, text.dwAchievement)
		end
    end

    local text = handle:Lookup("item")
    if text then
    	text.OnItemLButtonClick = function()
    		local x, y = this:GetAbsPos()
    		local w, h = this:GetSize()
			OutputItemTip(UI_OBJECT_ITEM_INFO, GLOBAL.CURRENT_ITEM_VERSION, this.dwTableType, this.dwTableIndex, {x, y, w, h}, true)
		end
    end
    
    OutputTip("", 345, Rect, nil, bLink, szName, true)
end

function OnUpdatePlayerDesignation(event)
	if event == "PLAYER_DISPLAY_DATA_UPDATE" then
		local player = GetPlayer(arg0)
		if player then
			player.SetDesignationContent(GetPlayerDesignation(player.dwID), false)
		end		
	elseif event == "SET_CURRENT_DESIGNATION" then
		local player = GetPlayer(arg0)
		if player then
			player.SetDesignationContent(GetPlayerDesignation(player.dwID), true)
		end		
	elseif event == "SYNC_DESIGNATION_DATA" then
		local player = GetPlayer(arg0)
		if player then
			player.SetDesignationContent(GetPlayerDesignation(player.dwID), true)
		end
	elseif event == "SYNC_ROLE_DATA_END" then
		local player = GetClientPlayer()
		if player then
			player.SetDesignationContent(GetPlayerDesignation(player.dwID), false)
		end
	end
end

RegisterEvent("PLAYER_DISPLAY_DATA_UPDATE", OnUpdatePlayerDesignation)
RegisterEvent("SET_CURRENT_DESIGNATION", OnUpdatePlayerDesignation)
RegisterEvent("SYNC_DESIGNATION_DATA", OnUpdatePlayerDesignation)
RegisterEvent("SYNC_ROLE_DATA_END", OnUpdatePlayerDesignation)
