local SUGGEST_PANEL_PATH = "UI/Config/default/SuggestPanel.ini"
local SCROLL_STEP_SIZE = 10

SuggestPanel = {}

function SuggestPanel.OnFrameCreate()
	this:RegisterEvent("PLAYER_LEVEL_UPDATE")
	this:RegisterEvent("CORRECT_AUTO_POS")
	
	this.tCollapse = {}
	SuggestPanel.UpdateSuggestInfo(this, true)
	
	InitFrameAutoPosInfo(this, 1, nil, nil, function() CloseSuggestPanel(true) end)
end

function SuggestPanel.OnEvent(szEvent)
	if szEvent == "PLAYER_LEVEL_UPDATE" then
		SuggestPanel.UpdateSuggestInfo(this, true)
	end
end

function SuggestPanel.OnScrollBarPosChanged()
	local szName = this:GetName()
	local nCurrentValue = this:GetScrollPos()
	if szName == "Scroll_List" then
		local hFrame = this:GetRoot()
		if nCurrentValue == 0 then
			hFrame:Lookup("Btn_Up"):Enable(false)
		else
			hFrame:Lookup("Btn_Up"):Enable(true)
		end
		
		if nCurrentValue == this:GetStepCount() then
			hFrame:Lookup("Btn_Down"):Enable(false)
		else
			hFrame:Lookup("Btn_Down"):Enable(true)
		end
		
		local hHandle = hFrame:Lookup("", "Handle_List")
		hHandle:SetItemStartRelPos(0, - nCurrentValue * SCROLL_STEP_SIZE)
	end
end

function SuggestPanel.OnLButtonHold()
	SuggestPanel.OnLButtonDown()
end

function SuggestPanel.OnLButtonDown()
	local szName = this:GetName()
	local hScroll = this:GetRoot():Lookup("Scroll_List")
	if szName == "Btn_Up" then
		hScroll:ScrollPrev(1)
	elseif szName == "Btn_Down" then
		hScroll:ScrollNext(1)
	end
end

function SuggestPanel.SelectTitle(hTitle)
	local hPlayer = GetClientPlayer()
	
	local hList = hTitle:GetParent()
	local nCount = hList:GetItemCount()
	
	local hChild = nil
	for i = 0, nCount - 1 do
		hChild = hList:Lookup(i)
		if hChild.bSelect then
			hChild.bSelect = false
			SuggestPanel.UpdateTitle(hChild)
			break
		end
	end
	hTitle.bSelect = true
	SuggestPanel.UpdateTitle(hTitle)
	
	local dwMapID = hTitle.dwMapID
	local dwAreaID = hTitle.dwAreaID
	
	if not dwAreaID or not hPlayer.GetMapVisitFlag(dwMapID) then
		OpenWorldMap()
		local argSave = arg0
		arg0 = dwMapID
		FireEvent("SELECT_CITY_COPY")
		arg0 = argSave
	else
		local nIndex = nil
		for _, tMap in pairs(g_aCityPoint) do
			if tMap.mapid == dwMapID then
				nIndex = tMap.middlemapindex
			end
		end
		OpenMiddleMap(dwMapID, nIndex)
		local argSave = arg0
		arg0 = dwAreaID
		FireEvent("SELECT_QUEST_AREA")
		arg0 = argSave
	end
end

function SuggestPanel.OnItemLButtonDown()
	local szName = this:GetName()
	if szName == "TreeLeaf_Group" then
		local hFrame = this:GetRoot()
		if hFrame.tCollapse[this.szTitle] then
			hFrame.tCollapse[this.szTitle] = false
		else
			hFrame.tCollapse[this.szTitle] = true
		end
		SuggestPanel.UpdateSuggestInfo(this:GetRoot(), false)
	elseif this.bQuest or this.bCopy then
		SuggestPanel.SelectTitle(this)
	end
end

function SuggestPanel.OnItemMouseEnter()
	local szName = this:GetName()
	if szName == "TreeLeaf_Title" then
		this.bEnter = true
		SuggestPanel.UpdateTitle(this)
	end
	
	if this.bBattleField then
		local nX, nY = this:GetAbsPos()
		local nWidth, nHeight = this:GetSize()
		local szTip = GetFormatText(g_tStrings.SUGGEST_COPY_TIP, 106)
		OutputTip(szTip, 335, {nX, nY, nWidth, nHeight})
	end
	
end

function SuggestPanel.OnItemMouseLeave()
	local szName = this:GetName()
	if szName == "TreeLeaf_Title" then
		this.bEnter = false
		SuggestPanel.UpdateTitle(this)
	end
	
	if this.bBattleField then
		HideTip()
	end
	
end

function SuggestPanel.OnLButtonClick()
	local szName = this:GetName()

	if szName == "Btn_Close" then
		CloseSuggestPanel(true)
	end
end

function SuggestPanel.UpdateTitle(hSelect)
	local hImage = hSelect:Lookup("Image_CoverTitle")
	
	if hSelect.bSelect then
		hImage:Show()
		hImage:SetAlpha(255)
	elseif hSelect.bEnter then
		hImage:Show()
		hImage:SetAlpha(125)
	else
		hImage:Hide()
	end
	
end

function SuggestPanel.UpdateSuggestInfo(hFrame, bHome)
	local hPlayer = GetClientPlayer()
	if not hPlayer then
		return
	end
	
	local hPlayerName = hFrame:Lookup("", "Text_Name")
	hPlayerName:SetText(hPlayer.szName)
	
	local hPlayerLevel = hFrame:Lookup("", "Text_Level")
	hPlayerLevel:SetText(hPlayer.nLevel)
	
	local szForce = g_tStrings.tForceTitle[hPlayer.dwForceID]
	local hForceName = hFrame:Lookup("", "Text_School")
	hForceName:SetText(szForce)
	
	local szCamp = g_tStrings.STR_GUILD_CAMP_NAME[hPlayer.nCamp]
	local hCampName = hFrame:Lookup("", "Text_Camp")
	hCampName:SetText(szCamp)
	
	local hList = hFrame:Lookup("", "Handle_List")
	hList:Clear()
	
	local hSuggestQuest = hList:AppendItemFromIni(SUGGEST_PANEL_PATH, "TreeLeaf_Group")
	hSuggestQuest.szTitle = "Quest"
	local hQuestTitle = hSuggestQuest:Lookup("Text_GroupName")
	hQuestTitle:SetText(g_tStrings.SUGGEST_QUEST_TITLE)
	
	if hFrame.tCollapse["Quest"] then
		hSuggestQuest:Collapse()
	else
		hSuggestQuest:Expand()
	end
	local tSuggestQuest = {}
	if hPlayer.nLevel <= 50 then
	 	tSuggestQuest = Table_GetQuestSuggest(hPlayer.nLevel, hPlayer.dwForceID)
	else
		tSuggestQuest = Table_GetQuestSuggest(hPlayer.nLevel, hPlayer.nCamp)
	end
	for _, tArea in pairs(tSuggestQuest) do
		local hQuest = hList:AppendItemFromIni(SUGGEST_PANEL_PATH, "TreeLeaf_Title")
		hQuest.bQuest = true
		hQuest.dwMapID = tArea.dwMapID
		hQuest.dwAreaID = tArea.dwAreaID
		local szMapName = Table_GetMapName(tArea.dwMapID)
		local szAreaName = MiddleMap.GetMapAreaName(tArea.dwMapID, tArea.dwAreaID)
		local hQuestName = hQuest:Lookup("Text_TitleName")
		hQuestName:SetText(szMapName .. "  " .. szAreaName)
		hQuest:Lookup("Image_CoverTitle"):Hide()
	end
	
	
	local hSuggestCopy = hList:AppendItemFromIni(SUGGEST_PANEL_PATH, "TreeLeaf_Group")
	hSuggestCopy.szTitle = "Copy"
	local hCopyTitle = hSuggestCopy:Lookup("Text_GroupName")
	hCopyTitle:SetText(g_tStrings.SUGGEST_COPY_TITLE)
	
	if hFrame.tCollapse["Copy"] then
		hSuggestCopy:Collapse()
	else
		hSuggestCopy:Expand()

	end
	
	local tSuggestCopy = Table_GetCopySuggest(hPlayer.nLevel)
	for _, dwID in pairs(tSuggestCopy) do
		local hCopy = hList:AppendItemFromIni(SUGGEST_PANEL_PATH, "TreeLeaf_Title")
		hCopy.bCopy = true
		hCopy.dwMapID = dwID
		local szCopyName = Table_GetMapName(dwID)
		local hCopyName = hCopy:Lookup("Text_TitleName")
		hCopyName:SetText(szCopyName)
		hCopy:Lookup("Image_CoverTitle"):Hide()
	end
	
	
	local hSuggestBattleField = hList:AppendItemFromIni(SUGGEST_PANEL_PATH, "TreeLeaf_Group")
	hSuggestBattleField.szTitle = "BattleField"
	local hBattleFieldTitle = hSuggestBattleField:Lookup("Text_GroupName")
	hBattleFieldTitle:SetText(g_tStrings.SUGGEST_BATTLEFILED_TITLE)
	
	if hFrame.tCollapse["BattleField"] then
		hSuggestBattleField:Collapse()
	else
		hSuggestBattleField:Expand()
	end
	
	local tSuggestBattleField = Table_GetBattleFieldSuggest(hPlayer.nLevel)
	for _, dwID in pairs(tSuggestBattleField) do 
		local hBattleField = hList:AppendItemFromIni(SUGGEST_PANEL_PATH, "TreeLeaf_Title")
		hBattleField.bBattleField = true
		local szBattleFieldName = Table_GetMapName(dwID)
		local hBattleFieldName = hBattleField:Lookup("Text_TitleName")
		hBattleFieldName:SetText(szBattleFieldName)
		hBattleField:Lookup("Image_CoverTitle"):Hide()
	end
	
	
	hList:FormatAllItemPos()
	SuggestPanel.UpdataScrollInfo(hFrame, bHome)
end

function SuggestPanel.UpdataScrollInfo(hFrame, bHome)
	local hList = hFrame:Lookup("", "Handle_List")
	local nWidth, nHeight = hList:GetSize()
	local nAllWidth, nAllHeight = hList:GetAllItemSize()
	
	local nStepCount = math.ceil((nAllHeight - nHeight) / SCROLL_STEP_SIZE)
	local hScroll = hFrame:Lookup("Scroll_List")
	hScroll:SetStepCount(nStepCount)
	local hBtnUp = hFrame:Lookup("Btn_Up")
	local hBtnDown = hFrame:Lookup("Btn_Down")
		
	if nStepCount > 0 then
		hScroll:Show()
		hBtnUp:Show()
		hBtnDown:Show()
	else
		hScroll:Hide()
		hBtnUp:Hide()
		hBtnDown:Hide()
	end
	
	if bHome then
		hScroll:ScrollHome()
	end
end

function OpenSuggestPanel(bDisableSound)
	if IsSuggestPanelOpened() then
		return 
	end
	
	Wnd.OpenWindow("SuggestPanel")
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end	
end

function IsSuggestPanelOpened()
	local hFrame = Station.Lookup("Normal/SuggestPanel")
	
	if hFrame and hFrame:IsVisible() then
		return true
	end
	
	return false
end

function CloseSuggestPanel(bDisableSound)
	if not IsSuggestPanelOpened() then
		return
	end
	
	Wnd.CloseWindow("SuggestPanel")
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND, g_sound.CloseFrame)
	end
	
end

