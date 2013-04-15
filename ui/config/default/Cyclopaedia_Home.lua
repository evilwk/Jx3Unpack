local INTERVAL = 15
local QUEST_SHOW_MAX_NUMBER = 5
local STEP_SIZE = 100
local INI_PATH =  "ui/Config/Default/Cyclopaedia.ini"
local tCareerLevel = {1, 12, 15, 20}
local tQuestLevel = {0, 10, 15, 25, 30, 48, 55, 65, 70, 75, 80}
local tCopyLevel = {15, 20, 30, 40, 48, 55, 70, 75, 80}

----tCyclopaediaSkill[x][y] = {} x:阶段(第一阶段是1~10级) y:玩家门派
local tCyclopaediaSkill =  Table_GetCyclopaediaSkill()
local tOtherMaster = 
{
	{1, {{2, 6}}},
	{11, {{1, 6}, {1, 8}, {1, 15}}},
}

local tSchollMaster = 
{
	[1] = {{43, 5}},
	[2] = {{44, 2}},
	[3] = {{45, 16}},
	[4] = {{46, 7}},
	[5] = {{47, 11}},
	[8] = {{48, 5}},
}

Cyclopaedia_Home = {}
Cyclopaedia_Home.tJX3DailyState = {}

RegisterCustomData("Cyclopaedia_Home.tJX3DailyState")

local INI_PATH = "ui/Config/Default/Cyclopaedia.ini"
local STEP_SIZE = 10

RegisterCustomData("Cyclopaedia_Home.tJX3DailyState")

function Cyclopaedia_Home.OnEvent(hFrame, szEvent)
	if szEvent == "PLAYER_LEVEL_UPDATE"
	or szEvent == "QUEST_ACCEPTED" 
	or szEvent == "SKILL_UPDATE"
	or szEvent == "CURRENT_PLAYER_FORCE_CHANGED"
	or szEvent == "QUEST_CANCELED"
	or szEvent == "SYNC_ROLE_DATA_END"
	then
		Cyclopaedia_Home.tQuestMap = nil
		Cyclopaedia_Home.tCopyMap = nil
		Cyclopaedia_Home.Update(hFrame)
	end
end

function Cyclopaedia_Home.OnLButtonClick(hButton)
	local szName = hButton:GetName()
	if szName == "Btn_JX3Daily" then
		OpenJX3Daily()
		FireDataAnalysisEvent("CYCLOPAEDIA_HOME_LEFT", {"JX3Daily"})
	elseif szName == "Btn_Calender" then
		--OpenCalenderPanel()
	end
end

function Cyclopaedia_Home.OnLButtonDown(hButton)
	--[[
	local szName = hButton:GetName()
	local hWnd = hButton:GetParent()
	if szName == "Btn_SkillUp" then
		hWnd:Lookup("Scroll_Skill"):ScrollPrev()
	elseif szName == "Btn_SkillDown" then
		hWnd:Lookup("Scroll_Skill"):ScrollNext()
	elseif szName == "Btn_CopyUp" then
		hWnd:Lookup("Scroll_Copy"):ScrollPrev()
	elseif szName == "Btn_CopyDown" then
		hWnd:Lookup("Scroll_Copy"):ScrollNext()
	end
	--]]
end


function Cyclopaedia_Home.OnItemMouseEnter(hItem)
	local szName = hItem:GetName()
	local hParent = hItem:GetParent()
	if szName == "Handle_MapListMod" then
		if hItem.bClick then
			hItem:Lookup("Image_highlight"):Show()
		end
	elseif szName == "Image_Flag" or szName == "Image_Flag1" then
		hItem:SetFrame(22)
	elseif szName == "NPCGuide" then
		local nFont = this:GetFontScheme()
		hItem.nNormalFont = nFont
		hItem:SetFontScheme(164)
		this:GetParent():FormatAllItemPos()
	elseif szName == "Box_SkillMod" then
		local dwSkillID, dwLevel = this:GetObjectData()
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
		OutputSkillTip(dwSkillID, dwLevel, {x, y, w, h}, true, true, true, true)
	elseif szName == "Handle_CopyListMod" then
		if hItem.bClick then
			hItem:Lookup("Image_Copyhighlight"):Show()
		end
	elseif hParent:GetName() == "Handle_LTitle" then
		if hItem.bCanSelect then	
			hItem.bMouse = true
			Cyclopaedia_Home.UpdateListTitle(hItem)
		end
	end
end

function Cyclopaedia_Home.OnItemMouseLeave(hItem)
	local szName = hItem:GetName()
	local hParent = hItem:GetParent()
	if szName == "Handle_MapListMod" then
		if hItem.bClick then
			hItem:Lookup("Image_highlight"):Hide()
		end
	elseif szName == "Image_Flag" or szName == "Image_Flag1" then
		hItem:SetFrame(23)
	elseif szName == "NPCGuide" then
		hItem:SetFontScheme(this.nNormalFont)
		this:GetParent():FormatAllItemPos()
	elseif szName == "Box_SkillMod" then
		HideTip()
	elseif szName == "Handle_CopyListMod" then
		if hItem.bClick then
			hItem:Lookup("Image_Copyhighlight"):Hide()
		end
	elseif hParent:GetName() == "Handle_LTitle" then
		hItem.bMouse = false
		Cyclopaedia_Home.UpdateListTitle(hItem)
	end
end

function Cyclopaedia_Home.OnItemLButtonDown(hItem)
	local szName = hItem:GetName()
	local hParent = hItem:GetParent()
	if szName == "Image_Flag" then
		local hQuest = hItem:GetParent()
		OnMarkQuestTarget(hQuest.dwQuestID, "accept", 0)
	elseif szName == "Handle_MapListMod" then
		Cyclopaedia_Home.SelectAreaOrCopy(hItem.dwMapID, hItem.dwAreaID)
	elseif szName == "NPCGuide" then
		local dwLinkID = this:GetUserData()
		local dwMapID = this.dwMapID
		OnLinkNpc(dwLinkID, dwMapID)
	elseif szName == "Handle_CopyListMod" then
		Cyclopaedia_Home.SelectAreaOrCopy(hItem.dwMapID)
	elseif szName == "Image_Flag1" then
		local hCopy = hItem:GetParent()
		Cyclopaedia_Home.SelectAreaOrCopy(hCopy.dwMapID)
	elseif hParent:GetName() == "Handle_LTitle" then
		if hItem.bCanSelect then
			Cyclopaedia_Home.SelectCareer(hItem)
		end
	end
end

function Cyclopaedia_Home.SelectAreaOrCopy(dwMapID, dwAreaID)
	local hPlayer = GetClientPlayer()
	if not hPlayer then
		return
	end
	
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

function Cyclopaedia_Home.OnItemMouseWheel(hList)
	--[[
	local nDistance = Station.GetMessageWheelDelta()
	local szName = this:GetName()
	
	if szName == "Handle_List3" then
		local hWnd = hList:GetParent()
		hWnd:Lookup("Scroll_Skill"):ScrollNext(nDistance)
	elseif szName == "Handle_List5" then
		local hWnd = hList:GetParent()
		hWnd:Lookup("Scroll_Copy"):ScrollNext(nDistance)
	end
	--]]
	return 1
end

function Cyclopaedia_Home.OnScrollBarPosChanged(hScroll)
	--[[
	local szName = hScroll:GetName()
	local nCurrentValue = hScroll:GetScrollPos()
	if szName == "Scroll_Skill" then
		local hWnd = hScroll:GetParent()
		if nCurrentValue == 0 then
			hWnd:Lookup("Btn_SkillUp"):Enable(false)
		else
			hWnd:Lookup("Btn_SkillUp"):Enable(true)
		end
		
		if nCurrentValue == this:GetStepCount() then
			hWnd:Lookup("Btn_SkillDown"):Enable(false)
		else
			hWnd:Lookup("Btn_SkillDown"):Enable(true)
		end
		hWnd:Lookup("", ""):SetItemStartRelPos(0, - nCurrentValue * STEP_SIZE)
	elseif szName == "Scroll_Copy" then
		local hWnd = hScroll:GetParent()
		if nCurrentValue == 0 then
			hWnd:Lookup("Btn_CopyUp"):Enable(false)
		else
			hWnd:Lookup("Btn_CopyUp"):Enable(true)
		end
		
		if nCurrentValue == this:GetStepCount() then
			hWnd:Lookup("Btn_CopyDown"):Enable(false)
		else
			hWnd:Lookup("Btn_CopyDown"):Enable(true)
		end
		hWnd:Lookup("", ""):SetItemStartRelPos(0, - nCurrentValue * STEP_SIZE)
	end
	--]]
end

function Cyclopaedia_Home.Update(hFrame)
    local hBtnCalender = hFrame:Lookup("Btn_Calender")
    hBtnCalender:Hide()
	Cyclopaedia_Home.UpdateList(hFrame)
end

function Cyclopaedia_Home.UpdateList(hFrame)
	local hList = hFrame:Lookup("PageSet_Total/Page_Head", "Handle_LTitle")
	local hPlayer = GetClientPlayer()
	if not hPlayer then
		return 
	end
	
	local hLast = nil
	local bSelect = false
	local nCount = hList:GetItemCount()
	for i = 0, nCount - 1 do
		local hItem = hList:Lookup(i)
		if hItem.bSelect then
			Cyclopaedia_Home.SelectCareer(hItem)
			bSelect = true
		end
		if tCareerLevel[i + 1] and hPlayer.nLevel >= tCareerLevel[i + 1] then
			hItem:Lookup(0):SetFontScheme(59)
			hItem.bCanSelect = true
			hLast = hItem
		else
			hItem.bCanSelect = false
			hItem:Lookup(0):SetFontScheme(45)
		end
	end
	
	if not bSelect and hLast then
		Cyclopaedia_Home.SelectCareer(hLast)
	end
end

function Cyclopaedia_Home.SelectCareer(hSelect)
	local hList = hSelect:GetParent()
	local hPageHead = hList:GetParent():GetParent()
	local nCount = hList:GetItemCount()
	for i = 0, nCount - 1 do
		local hItem = hList:Lookup(i)
		hItem.bSelect = false
		Cyclopaedia_Home.UpdateListTitle(hItem)
		local szName = hItem:GetName()
		local szSuffix = string.match(szName, "Handle_(.*)")
		local hWnd = hPageHead:Lookup("Wnd_" .. szSuffix)
		hWnd:Hide()
	end
	
	hSelect.bSelect = true
	Cyclopaedia_Home.UpdateListTitle(hSelect)
	local szName = hSelect:GetName()
	local szSuffix = string.match(szName, "Handle_(.*)")
	local hWnd = hPageHead:Lookup("Wnd_" .. szSuffix)
	hWnd:Show()
	local szName = hWnd:GetName()
	if szName == "Wnd_Quest" then
		Cyclopaedia_Home.UpdateQuest(hWnd)
	elseif szName == "Wnd_Skill" then
		Cyclopaedia_Home.UpdateSkill(hWnd)
	elseif szName == "Wnd_Copy" then
		Cyclopaedia_Home.UpdateCopy(hWnd)
	elseif szName == "Wnd_Social" then
		Cyclopaedia_Home.UpdateSocial(hWnd)
	end
end

function Cyclopaedia_Home.UpdateSocial(hWnd)
	FireUIEvent("SCROLL_UPDATE_LIST", "Handle_List1", "Cyclopaedia", true)
end

function Cyclopaedia_Home.UpdateListTitle(hTitle)
	if hTitle.bSelect then
		hTitle:Lookup(1):Show()
		hTitle:Lookup(1):SetAlpha(256)
	elseif hTitle.bMouse then
		hTitle:Lookup(1):Show()
		hTitle:Lookup(1):SetAlpha(126)
	else
		hTitle:Lookup(1):Hide()
	end
end

function Cyclopaedia_Home.UpdateQuest(hWndQuest)
	Cyclopaedia_Home.UpdateQuestMap(hWndQuest)
	Cyclopaedia_Home.UpdateSuggestQuest(hWndQuest)
	
	FireUIEvent("SCROLL_UPDATE_LIST", "Handle_List", "Cyclopaedia", true)
end

function Cyclopaedia_Home.UpdateCopy(hWndCopy)
	Cyclopaedia_Home.UpdateCopyMap(hWndCopy)
	Cyclopaedia_Home.UpdateSuggestCopy(hWndCopy)
	
	FireUIEvent("SCROLL_UPDATE_LIST", "Handle_List5", "Cyclopaedia", true)
end

function Cyclopaedia_Home.UpdateCopyListScroll(hList, bHome)
	local hWnd = hList:GetParent()
	local hScroll = hWnd:Lookup("Scroll_Copy")
	local fWidthAll, fHeightAll = hList:GetAllItemSize()
	local fWidth, fHeight = hList:GetSize()
	local nStepCount = math.ceil((fHeightAll - fHeight) / STEP_SIZE)
	hScroll:SetStepCount(nStepCount)
	
	if nStepCount > 0 then
		hScroll:Show()
		hWnd:Lookup("Btn_CopyUp"):Show()
		hWnd:Lookup("Btn_CopyDown"):Show()
	else
		hScroll:Hide()
		hWnd:Lookup("Btn_CopyUp"):Hide()
		hWnd:Lookup("Btn_CopyDown"):Hide()
	end
	
	if bHome then
		hScroll:ScrollHome()
	end
end

function Cyclopaedia_Home.UpdateSkill(hWndSkill)
	local hPlayer = GetClientPlayer()
	if not hPlayer then
		return
	end
	
	local hTotalHandle = hWndSkill:Lookup("", "")
	local hSectionList = hTotalHandle:Lookup("Handle_RTop")
	for nIndex, tSection in ipairs(tCyclopaediaSkill) do
		local hSection = hSectionList:Lookup("Handle_SkillList" .. nIndex)
		hSection:Clear()
		Cyclopaedia_Home.AddSectionSkill(hSection, tSection[0])
		if hPlayer.dwForceID > 0 then
			Cyclopaedia_Home.AddSectionSkill(hSection, tSection[hPlayer.dwForceID])
		end
		hSection:FormatAllItemPos()
	end
	
	local hContentSkill = hTotalHandle:Lookup("Handle_RContentSkill")
	local hSkill = hContentSkill:Lookup("Handle_NewSkill")
	hSkill:Clear()
	local szSkill = Table_GetLearnSkillInfo(hPlayer.nLevel, hPlayer.dwForceID)
	for s in string.gmatch(szSkill, "%d+") do
		local dwID = tonumber(s)
		local dwLevel = hPlayer.GetSkillLevel(dwID)
		if dwLevel == 0 then
			local hSkillBox = hSkill:AppendItemFromIni(INI_PATH, "Box_SkillMod")
			hSkillBox:SetObject(UI_OBJECT_SKILL, dwID, 1)
			hSkillBox:SetObjectIcon(Table_GetSkillIconID(dwID, 1))
		end
	end
	hSkill:FormatAllItemPos()
	local fWidth = hSkill:GetSize()
	local _, fHeight = hSkill:GetAllItemSize()
	hSkill:SetSize(fWidth, fHeight)
	local _, fY = hSkill:GetRelPos()
	fWidth = hContentSkill:GetSize()
	hContentSkill:SetSize(fWidth, fY + fHeight)
	
	local hSkillMaster = hTotalHandle:Lookup("Handle_RSContent/Handle_Master")
	hSkillMaster:Clear()
	local tProperMaster = {}
	for _, tMaster in ipairs(tOtherMaster) do
		if hPlayer.nLevel < tMaster[1] then
			break
		end
		tProperMaster = tMaster[2]
	end
	hSkillMaster:AppendItemFromString(GetFormatText(g_tStrings.CYCLOPAEDIA_OTHER_MASTER, 18))
	for nIndex, tMaster in ipairs(tProperMaster) do
		local tLink = Table_GetCareerLinkNpcInfo(tMaster[1], tMaster[2])
		local szMapName = Table_GetMapName(tMaster[2])
		local szNpcName = Table_GetNpcTemplateName(tLink.dwNpcID)
		if nIndex > 1 then
			hSkillMaster:AppendItemFromString(GetFormatText(g_tStrings.STR_PAUSE))
		end
		hSkillMaster:AppendItemFromString(GetFormatText(szMapName .. " " .. szNpcName, 18))
		local szNpcGuide = MakeNPCGuideLink(g_tStrings.CAREER_GUIDE_NPC, 163, tMaster[1], tMaster[2]) 
		hSkillMaster:AppendItemFromString(szNpcGuide)
	end
	
	if hPlayer.dwForceID > 0 then
		hSkillMaster:AppendItemFromString(GetFormatText("\n" .. g_tStrings.CYCLOPAEDIA_SCHOLL_MASTER, 18))
		for nIndex, tMaster in ipairs(tSchollMaster[hPlayer.dwForceID]) do
		local tLink = Table_GetCareerLinkNpcInfo(tMaster[1], tMaster[2])
		local szMapName = Table_GetMapName(tMaster[2])
		local szNpcName = Table_GetNpcTemplateName(tLink.dwNpcID)
		if nIndex > 1 then
			hSkillMaster:AppendItemFromString(GetFormatText(g_tStrings.STR_PAUSE))
		end
			hSkillMaster:AppendItemFromString(GetFormatText(szMapName .. " " .. szNpcName, 18))
			local szNpcGuide = MakeNPCGuideLink(g_tStrings.CAREER_GUIDE_NPC, 163, tMaster[1], tMaster[2]) 
			hSkillMaster:AppendItemFromString(szNpcGuide)
		end
	end
	
	hSkillMaster:FormatAllItemPos()
	hTotalHandle:FormatAllItemPos()
	
	--Cyclopaedia_Home.UpdateSkillListScroll(hTotalHandle, true)
	FireUIEvent("SCROLL_UPDATE_LIST", "Handle_List3", "Cyclopaedia", true)
end

function Cyclopaedia_Home.UpdateSkillListScroll(hList, bHome)
	local hWnd = hList:GetParent()
	local hScroll = hWnd:Lookup("Scroll_Skill")
	local fWidthAll, fHeightAll = hList:GetAllItemSize()
	local fWidth, fHeight = hList:GetSize()
	local nStepCount = math.ceil((fHeightAll - fHeight) / STEP_SIZE)
	hScroll:SetStepCount(nStepCount)
	
	if nStepCount > 0 then
		hScroll:Show()
		hWnd:Lookup("Btn_SkillUp"):Show()
		hWnd:Lookup("Btn_SkillDown"):Show()
	else
		hScroll:Hide()
		hWnd:Lookup("Btn_SkillUp"):Hide()
		hWnd:Lookup("Btn_SkillDown"):Hide()
	end
	
	if bHome then
		hScroll:ScrollHome()
	end
end

function Cyclopaedia_Home.AddSectionSkill(hSection, tSkills)
	if not tSkills then
		return 
	end
	for _, tTheSkill in ipairs(tSkills) do
		local hBox = hSection:AppendItemFromIni(INI_PATH, "Box_SkillMod")
		local dwID = tTheSkill[1]
		local dwLevel = tTheSkill[2]
		hBox:SetObject(UI_OBJECT_SKILL, dwID, dwLevel)
		hBox:SetObjectIcon(Table_GetSkillIconID(dwID, dwLevel))
	end
	hSection:FormatAllItemPos()
	local fWidth, fHeight = hSection:GetAllItemSize()
	hSection:SetSize(fWidth, fHeight)
end

function Cyclopaedia_Home.UpdateQuestMap(hWndQuest)
	local hPlayer = GetClientPlayer()
	if not hPlayer then
		return
	end
	local tQuestMap = Cyclopaedia_Home.GetQuestMap()
	local hHandle = hWndQuest:Lookup("", "Handle_ImageTotal")
	local nCount = #tQuestLevel
	for i = 1, nCount - 1 do
		local hMapList = hHandle:Lookup("Handle_MapList" .. i)
		hMapList:Clear()
		for _, tMap in ipairs(tQuestMap[i]) do
			local hMap = hMapList:AppendItemFromIni(INI_PATH, "Handle_MapListMod")
			local szMapName = Table_GetMapName(tMap.dwMapID)
			hMap:Lookup("Text_MapName"):SetText(szMapName)
			hMap.dwMapID = tMap.dwMapID
			hMap.dwAreaID = tMap.dwAreaID
			
			if hPlayer.nLevel >= tQuestLevel[i] and hPlayer.nLevel < tQuestLevel[i + 1] then
				hMap.bClick = true
				hMap:Lookup("Image_Low"):Hide()
				hMap:Lookup("Image_high"):Show()
				hMap:Lookup("Text_MapName"):SetFontScheme(198)
			elseif hPlayer.nLevel > tQuestLevel[i] then
				hMap.bClick = true
				hMap:Lookup("Image_Low"):Show()
				hMap:Lookup("Image_high"):Hide()
				hMap:Lookup("Text_MapName"):SetFontScheme(162)
			else
				hMap.bClick = false
				hMap:Lookup("Image_Low"):Show()
				hMap:Lookup("Image_high"):Hide()
				hMap:Lookup("Text_MapName"):SetFontScheme(161)
			end
		end
		if #tQuestMap[i] == 0 then
			hMapList:AppendItemFromIni(INI_PATH, "Handle_Text")
		end
		hMapList:FormatAllItemPos()
	end
end

function Cyclopaedia_Home.UpdateSuggestQuest(hWndQuest)
	local hList = hWndQuest:Lookup("", "Handle_RBlock")
	hList:Clear()
	
	local tQuest = Cyclopaedia_Home.GetSuggestQuest()
	for _, dwQuestID in ipairs(tQuest) do 
		local hQuest = hList:AppendItemFromIni(INI_PATH, "Handle_QuestContent")
		local tQuestStringInfo = Table_GetQuestStringInfo(dwQuestID)
		hQuest:Lookup("Text_QuestName"):SetText(tQuestStringInfo.szName)
		hQuest.dwQuestID = dwQuestID
	end
	hList:FormatAllItemPos()
end

function Cyclopaedia_Home.GetQuestMap()
	if not Cyclopaedia_Home.tQuestMap then
		Cyclopaedia_Home.tQuestMap = {}
		local nCount = #tQuestLevel
		local hPlayer = GetClientPlayer()
		if hPlayer then 
			
			for i = 1, nCount - 1 do
				local tMap = Table_GetSuggestMap(hPlayer.dwForceID, tQuestLevel[i], tQuestLevel[i + 1] - 1)
				table.insert(Cyclopaedia_Home.tQuestMap, tMap)
			end
		end
	end
	
	return Cyclopaedia_Home.tQuestMap
end

function Cyclopaedia_Home.GetCopyMap()
	if not Cyclopaedia_Home.tCopyMap then
		Cyclopaedia_Home.tCopyMap = {}
		local nCount = #tCopyLevel
		for i = 1, nCount - 1 do
			local tMap = Table_GetCopyMap(tCopyLevel[i], tCopyLevel[i + 1] - 1)
			table.insert(Cyclopaedia_Home.tCopyMap, tMap)
		end
	end
	return Cyclopaedia_Home.tCopyMap
end

function Cyclopaedia_Home.UpdateCopyMap(hWndCopy)
	local hPlayer = GetClientPlayer()
	if not hPlayer then
		return
	end
	local tCopyMap = Cyclopaedia_Home.GetCopyMap()
	local hHandle = hWndCopy:Lookup("", "Handle_CRTop")
	local nCount = #tCopyLevel
	for i = 1, nCount - 1 do
		local hMapList = hHandle:Lookup("Handle_CopyList" .. i)
		hMapList:Clear()
		for _, dwMapID in ipairs(tCopyMap[i]) do
			local hMap = hMapList:AppendItemFromIni(INI_PATH, "Handle_CopyListMod")
			local szMapName = Table_GetMapName(dwMapID)
			hMap:Lookup("Text_CopyName"):SetText(szMapName)
			hMap.dwMapID = dwMapID
			
			if hPlayer.nLevel >= tCopyLevel[i] and hPlayer.nLevel < tCopyLevel[i + 1] then
				hMap.bClick = true
				hMap:Lookup("Image_CopyLow"):Hide()
				hMap:Lookup("Image_Copyhigh"):Show()
				hMap:Lookup("Text_CopyName"):SetFontScheme(198)
			elseif hPlayer.nLevel > tCopyLevel[i] then
				hMap.bClick = false
				hMap:Lookup("Image_CopyLow"):Show()
				hMap:Lookup("Image_Copyhigh"):Hide()
				hMap:Lookup("Text_CopyName"):SetFontScheme(162)
			else
				hMap.bClick = false
				hMap:Lookup("Image_CopyLow"):Show()
				hMap:Lookup("Image_Copyhigh"):Hide()
				hMap:Lookup("Text_CopyName"):SetFontScheme(161)
			end
		end
		hMapList:FormatAllItemPos()
	end
end

function Cyclopaedia_Home.UpdateSuggestCopy(hWndCopy)
	local hPlayer = GetClientPlayer()
	if not hPlayer then
		return
	end
	local hTotalHandle = hWndCopy:Lookup("", "")
	local hSuggestCopy = hTotalHandle:Lookup("Handle_RContentCopy")
	local hList = hSuggestCopy:Lookup("Handle_SuggestCopy")
	hList:Clear()
	local tCopy = Table_GetCopySuggest(hPlayer.nLevel)
	for _, dwMapID in ipairs(tCopy) do 
		local hCopy = hList:AppendItemFromIni(INI_PATH, "Handle_CopyContent")
		hCopy.dwMapID = dwMapID
		local szMapName = Table_GetMapName(dwMapID)
		hCopy:Lookup("Text_CopyName1"):SetText(szMapName)
	end
	hList:FormatAllItemPos()
	local fWidth = hList:GetSize()
	local _, fHeight = hList:GetAllItemSize()
	hList:SetSize(fWidth, fHeight)
	local _, fY = hList:GetRelPos()
	fWidth = hSuggestCopy:GetSize()
	hSuggestCopy:SetSize(fWidth, fY + fHeight)
	hTotalHandle:FormatAllItemPos()
end

function Cyclopaedia_Home.GetPlayerSuggestMap()
	local tMap = {}
	local hPlayer = GetClientPlayer()
	if not hPlayer then
		return tMap
	end
	local tQuestMap = Cyclopaedia_Home.GetQuestMap()
	for nIndex, nLevel in ipairs(tQuestLevel) do
		if hPlayer.nLevel < nLevel then
			tMap = tQuestMap[nIndex - 1]
			break
		end
	end
	
	return tMap
end

function Cyclopaedia_Home.GetSuggestQuest()
	local hPlayer = GetClientPlayer()
	if not hPlayer then
		return
	end
	local tSuggestQuest = {}
	local hScene = hPlayer.GetScene()
	local dwMapID = hScene.dwMapID
	tSuggestQuest = Cyclopaedia_Home.GetSuggestQuestOfMap(tSuggestQuest, dwMapID)
	if #tSuggestQuest < QUEST_SHOW_MAX_NUMBER then
		local tQuestMap = Cyclopaedia_Home.GetPlayerSuggestMap()
		for _, tMap in ipairs(tQuestMap) do
			if dwMapID ~= tMap.dwMapID then
				tSuggestQuest = Cyclopaedia_Home.GetSuggestQuestOfMap(tSuggestQuest, tMap.dwMapID)
				if #tSuggestQuest >= QUEST_SHOW_MAX_NUMBER then
					break
				end
			end
		end
	end
	return tSuggestQuest
end

function Cyclopaedia_Home.GetSuggestQuestOfMap(tSuggestQuest, dwMapID)
	local hPlayer = GetClientPlayer()
	if not hPlayer then
		return
	end
	
	local tSceneQuest = Table_GetAllSceneQuest(dwMapID)	
	local IsSuggestQuest = function(dwQuestID, dwObject)
		local eCanAccept = hPlayer.CanAcceptQuest(dwQuestID, dwObject)
		if eCanAccept ~= QUEST_RESULT.SUCCESS then
			return false
		end
		local nDifficult = hPlayer.GetQuestDiffcultyLevel(dwQuestID)
		
		 if nDifficult == QUEST_DIFFICULTY_LEVEL.LOW_LEVEL or nDifficult == QUEST_DIFFICULTY_LEVEL.LOWER_LEVEL then
			return false
		end
		
		return true
	end
	
	for dwQuestID, tObject in pairs(tSceneQuest) do
		for _, tInfo in pairs(tObject) do
			local szType = tInfo[1]
			local dwObject = tInfo[2]
			assert(szType == "D" or szType == "N")
			if dwObject > 0 then
				local bSuggest = IsSuggestQuest(dwQuestID, dwObject)
				if bSuggest then
					table.insert(tSuggestQuest, dwQuestID)
					break
				end
			end
		end
		if #tSuggestQuest >= QUEST_SHOW_MAX_NUMBER then
			break
		end
	end
	
	return tSuggestQuest
end

function OpenJX3Daily()
	Cyclopaedia_Home.tJX3DailyState.bRead = true
		
	FireEvent("OPEN_JX3DAILY")
	return OpenInternetExplorer(tUrl.JX3Daily)
end

function GetJX3DailyState()
	return Cyclopaedia_Home.tJX3DailyState
end

do  
    RegisterScrollEvent("Cyclopaedia")
    
    UnRegisterScrollAllControl("Cyclopaedia")
        
    local szFramePath = "Normal/Cyclopaedia"
    local szWndPath = "PageSet_Total/Page_Head/Wnd_Quest"
    RegisterScrollControl(
        szFramePath, 
        szWndPath.."/Btn_QuestUp", szWndPath.."/Btn_QuestDown", 
        szWndPath.."/Scroll_Quest", 
        {szWndPath, "Handle_List"})

	local szWndPath = "PageSet_Total/Page_Head/Wnd_Social"
    RegisterScrollControl(
        szFramePath, 
        szWndPath.."/Btn_SocialUp", szWndPath.."/Btn_SocialDown", 
        szWndPath.."/Scroll_Social", 
        {szWndPath, "Handle_List1"}
    )
   
   	local szWndPath = "PageSet_Total/Page_Head/Wnd_Skill"
    RegisterScrollControl(
        szFramePath, 
        szWndPath.."/Btn_SkillUp", szWndPath.."/Btn_SkillDown", 
        szWndPath.."/Scroll_Skill", 
        {szWndPath, "Handle_List3"}
    )
    
    local szWndPath = "PageSet_Total/Page_Head/Wnd_Copy"
    RegisterScrollControl(
        szFramePath, 
        szWndPath.."/Btn_CopyUp", szWndPath.."/Btn_CopyDown", 
        szWndPath.."/Scroll_Copy", 
        {szWndPath, "Handle_List5"}
    )
end


