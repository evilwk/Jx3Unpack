
NewCenterPanelArray = {}

function CreateNewAchievementPanel(dwAchievementID)
	local aAchievement = g_tTable.Achievement:Search(dwAchievementID)
	if not aAchievement then
		return
	end
	
	if aAchievement.nVisible == 0 then
		return
	end
	
	ShowFullScreenSFX("ReputationLevelUp")

	local szName = "NewAchievement"..dwAchievementID
	
	local frame = Station.Lookup("Normal/"..szName)
	if frame then
		return
	end
	
	local t = {}
	for k, v in pairs(NewCenterPanelArray) do
		t[v] = true
	end
	
	local nIndex = 1
	for i = 1, 10000, 1 do
		if not t[i] then
			nIndex = i
			break
		end
	end
	
	NewCenterPanelArray[szName] = nIndex
	
	frame = Station.OpenWindow("NewAchievement", szName)
	
	frame.Close = function(frame)
		Station.CloseWindow(frame:GetName())
		PlaySound(SOUND.UI_SOUND, g_sound.CloseFrame)		
	end	
	
	frame.dwStartTime = GetTickCount()
	frame.OnFrameBreathe = function()
		local dwTimeDelta = GetTickCount() - this.dwStartTime
		if dwTimeDelta > 10000 then
			local szName = this:GetName()
			NewCenterPanelArray[szName] = nil
			this:Close()
		elseif dwTimeDelta > 500 and not frame.bShowAni then
			frame.bShowAni = true
			local ani = frame:Lookup("", "Animate_Finish")
			ani:Show()
			ani:Replay()
			PlaySound(SOUND.UI_SOUND, g_sound.FinishAchievement)
		end
	end
	
	frame:RegisterEvent("UI_SCALED")
	
	frame.OnEvent = function(event)
		if event == "UI_SCALED" then
			this:SetPoint(this.Anchor.s, 0, 0, this.Anchor.r, this.Anchor.x, this.Anchor.y)
			this:CorrectPos()
		end
	end

	frame.dwAchievementID = dwAchievementID

	local btn = frame:Lookup("Btn_Close")
	btn.OnLButtonClick = function()
		local frame = this:GetRoot()
		NewCenterPanelArray[frame:GetName()] = nil
		frame:Close()
	end

	local h = frame:Lookup("", "")
	
	h.OnItemLButtonClick = function()
		OpenAchievementPanel(nil, this:GetRoot().dwAchievementID)
	end
	
	h:Lookup("Text_Name"):SetText(aAchievement.szName)
	h:Lookup("Text_Tip"):SetText(aAchievement.szShortDesc)
	
	local _, nP = GetAchievementInfo(dwAchievementID)
	h:Lookup("Text_Point"):SetText(nP or 0)
	
	local box = h:Lookup("Box_Icon")
	box:SetObject(UI_OBJECT_NOT_NEED_KNOWN, 0)
	box:SetObjectIcon(aAchievement.nIconID)
	
	local w, h = frame:GetSize()
	local nDY = -((nIndex - 1) % 3) * (h + 1) - 150
	frame.Anchor = {s = "BOTTOMCENTER", r = "BOTTOMCENTER", x = 0, y = nDY}
	frame:SetPoint(frame.Anchor.s, 0, 0, frame.Anchor.r, frame.Anchor.x, frame.Anchor.y)
end

function CreateNewDesignationPanel(nID, bPrefix)
	local szAdd = ""
	local aDesignation = nil
	local bWorld = false
	local bMilitary = false
	if bPrefix then
		szAdd = "Prefix"
		aDesignation = g_tTable.Designation_Prefix:Search(nID)
		bWorld = GetDesignationPrefixInfo(nID).nType == DESIGNATION_PREFIX_TYPE.WORLD_DESIGNATION
		bMilitary = GetDesignationPrefixInfo(nID).nType == DESIGNATION_PREFIX_TYPE.MILITARY_RANK_DESIGNATION
	else
		szAdd = "Postfix"
		aDesignation = g_tTable.Designation_Postfix:Search(nID)
	end
	if not aDesignation then
		return
	end
	
	local szName = "NewDesignation"..szAdd..nID
	
	local frame = Station.Lookup("Normal/"..szName)
	if frame then
		return
	end
	
	local t = {}
	for k, v in pairs(NewCenterPanelArray) do
		t[v] = true
	end
	
	local nIndex = 1
	for i = 1, 10000, 1 do
		if not t[i] then
			nIndex = i
			break
		end
	end
	
	NewCenterPanelArray[szName] = nIndex
	
	frame = Station.OpenWindow("NewDesignation", szName)
	frame.dwStartTime = GetTickCount()
	frame.OnFrameBreathe = function()
		if GetTickCount() - this.dwStartTime > 10000 then
			local szName = this:GetName()
			NewCenterPanelArray[szName] = nil
			Station.CloseWindow(szName)
			PlaySound(SOUND.UI_SOUND, g_sound.CloseFrame)
		end
	end
	
	frame:RegisterEvent("UI_SCALED")
	
	frame.OnEvent = function(event)
		if event == "UI_SCALED" then
			this:SetPoint(this.Anchor.s, 0, 0, this.Anchor.r, this.Anchor.x, this.Anchor.y)
			this:CorrectPos()
		end
	end	

	frame.nID, frame.bPrefix = nID, bPrefix

	local btn = frame:Lookup("Btn_Close")
	btn.OnLButtonClick = function()
		local szName = this:GetParent():GetName()
		NewCenterPanelArray[szName] = nil
		Station.CloseWindow(szName)
		PlaySound(SOUND.UI_SOUND, g_sound.CloseFrame)
	end

	local h = frame:Lookup("", "")
	if bMilitary then
		h:Lookup("Text_Tip"):SetText(g_tStrings.GET_DESGNATION_TITLE1)
	elseif bWorld then
		h:Lookup("Text_Tip"):SetText(g_tStrings.GET_DESGNATION_WORLD1)
	elseif bPrefix then
		h:Lookup("Text_Tip"):SetText(g_tStrings.GET_DESGNATION_PREFIX1)
	else
		h:Lookup("Text_Tip"):SetText(g_tStrings.GET_DESGNATION_POSTFIX1)
	end
	h:Lookup("Text_Name"):SetText(aDesignation.szName)
	h:Lookup("Text_Name"):SetFontColor(GetItemFontColorByQuality(aDesignation.nQuality))
	
	h.OnItemLButtonClick = function()
		local frame = this:GetRoot()
		OpenDesignationPanel(false, frame.nID, frame.bPrefix)
	end
	
	local w, h = frame:GetSize()
	local nDY = -((nIndex - 1) % 3) * (h + 1) - 150
	frame.Anchor = {s = "BOTTOMCENTER", r = "BOTTOMCENTER", x = 0, y = nDY}
	frame:SetPoint(frame.Anchor.s, 0, 0, frame.Anchor.r, frame.Anchor.x, frame.Anchor.y)
end
