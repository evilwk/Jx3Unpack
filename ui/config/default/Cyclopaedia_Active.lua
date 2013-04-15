local INI_PATH =  "ui/Config/Default/Cyclopaedia_Active.ini"
local STEP_SIZE = 10
local FONT_NORMAL = 106
local FONT_TITLE = 59
local FONT_SUB_TITLE = 163
local FONT_DISSATISFY = 102
local FONT_DISABLE = 108

Cyclopaedia_Active = {}

function Cyclopaedia_Active.Update(hWnd)
	local tTotalList = Cyclopaedia_Active.GetList()
	Cyclopaedia_Active.UpdateList(hWnd, tTotalList)
	local hList = hWnd:Lookup("", "Handle_Active")
	Cyclopaedia_Active.Select(hList:Lookup(0))
end

function Cyclopaedia_Active.OnEditSpecialKeyDown(hItem)
	local szKey = GetKeyName(Station.GetMessageKey())
	local szName = hItem:GetName()
	if szName == "Edit_ActiveSearch" and szKey == "Enter" then
		local hWnd = this:GetParent()
		local szText = hItem:GetText()
		Cyclopaedia_Active.SearchInfo(hWnd, szText)
	end
end

function Cyclopaedia_Active.OnItemLButtonDown(hItem)
	local szName = hItem:GetName()
	if szName == "TreeLeaf_Active" and not hItem.tInfo.bActivity then
		if hItem.bActiveClass or hItem.bActiveSubClass then
			if hItem:IsExpand() then
				hItem:Collapse()
			else
				hItem:Expand()
			end
			local hList = hItem:GetParent()
			hList:FormatAllItemPos()
			Cyclopaedia_Active.UpdateListScroll(hList)
		end
		Cyclopaedia_Active.Select(hItem)
	end
end

function Cyclopaedia_Active.OnItemMouseEnter(hItem)
	local szName = hItem:GetName()
	if szName == "TreeLeaf_Active" and not hItem.tInfo.bActivity then
		hItem.bMouse = true
		Cyclopaedia_Active.UpdateTitle(hItem)
	end
end

function Cyclopaedia_Active.OnItemMouseLeave(hItem)
	local szName = hItem:GetName()
	if szName == "TreeLeaf_Active" and not hItem.tInfo.bActivity then
		hItem.bMouse = false
		Cyclopaedia_Active.UpdateTitle(hItem)
	end
end

function Cyclopaedia_Active.OnItemMouseWheel(hItem)
	local nDistance = Station.GetMessageWheelDelta()
	local szName = hItem:GetName()
	
	if szName == "Handle_Active" then
		local hWnd = hItem:GetParent():GetParent()
		hWnd:Lookup("Scroll_ActiveLeft"):ScrollNext(nDistance)
	elseif szName == "Handle_Info" then 
		local hWndInfo = hItem:GetParent()
		hWndInfo:Lookup("Scroll_ActiveInfo"):ScrollNext(nDistance)
	end
end

function Cyclopaedia_Active.OnLButtonClick(hButton)
	local szName = hButton:GetName()
	if szName == "Btn_ActiveSearch" then
		local hWnd = hButton:GetParent()
		local szText = hWnd:Lookup("Edit_ActiveSearch"):GetText()
		Cyclopaedia_Active.SearchInfo(hWnd, szText)
	end
end

function Cyclopaedia_Active.OnLButtonDwon(hButton)
	local szName = hButton:GetName()
	local hWnd = hButton:GetParent()
    if szName == "Btn_ActiveInfoUp" then
		hWnd:Lookup("Scroll_ActiveInfo"):ScrollPrev()
	elseif szName == "Btn_ActiveInfoDown" then
		hWnd:Lookup("Scroll_ActiveInfo"):ScrollNext()
	elseif szName == "Btn_ActiveUp" then
		hWnd:Lookup("Scroll_ActiveLeft"):ScrollPrev()
	elseif szName == "Btn_ActiveDown" then
		hWnd:Lookup("Scroll_ActiveLeft"):ScrollNext()
	end
end

function Cyclopaedia_Active.OnScrollBarPosChanged(hScroll)
	local szName = hScroll:GetName()
	local nCurrentValue = hScroll:GetScrollPos()
	if szName == "Scroll_ActiveInfo" then
		local hWndInfo = hScroll:GetParent()
		if nCurrentValue == 0 then
			hWndInfo:Lookup("Btn_ActiveInfoUp"):Enable(false)
		else
			hWndInfo:Lookup("Btn_ActiveInfoUp"):Enable(true)
		end
		
		if nCurrentValue == hScroll:GetStepCount() then
			hWndInfo:Lookup("Btn_ActiveInfoDown"):Enable(false)
		else
			hWndInfo:Lookup("Btn_ActiveInfoDown"):Enable(true)
		end
		hWndInfo:Lookup("", ""):SetItemStartRelPos(0, - nCurrentValue * STEP_SIZE)
	elseif szName == "Scroll_ActiveLeft" then
		local hWnd = hScroll:GetParent()
		if nCurrentValue == 0 then
			hWnd:Lookup("Btn_ActiveUp"):Enable(false)
		else
			hWnd:Lookup("Btn_ActiveUp"):Enable(true)
		end
		
		if nCurrentValue == hScroll:GetStepCount() then
			hWnd:Lookup("Btn_ActiveDown"):Enable(false)
		else
			hWnd:Lookup("Btn_ActiveDown"):Enable(true)
		end
		hWnd:Lookup("", "Handle_Active"):SetItemStartRelPos(0, - nCurrentValue * STEP_SIZE)
	end
end

function Cyclopaedia_Active.Select(hSelect)
	local hList = hSelect:GetParent()
	local nCount = hList:GetItemCount()
	
	for i = 0, nCount - 1 do
		hChild = hList:Lookup(i)
		if hChild.bSelect then
			hChild.bSelect = false
			Cyclopaedia_Active.UpdateTitle(hChild)
			break
		end
	end
	
	hSelect.bSelect = true
	Cyclopaedia_Active.UpdateTitle(hSelect)
	Cyclopaedia_Active.UpdateInfo(hSelect)
end

function Cyclopaedia_Active.UpdateInfo(hSelect)
	local hWndInfo = hSelect:GetParent():GetParent():GetParent()
	local hInfo = hWndInfo:Lookup("Wnd_Info", "")
	hInfo:Clear()
	local dwClassID = hSelect.tInfo.dwClassID
	local dwID = hSelect.tInfo.dwID
	if hSelect.tInfo.bActivity then
		--Cyclopaedia_Active.UpdateActivityInfo(hInfo, dwClassID, dwID)
	elseif hSelect.tInfo.bDailyQuest then
		Cyclopaedia_Active.UpdateDailyQuestInfo(hInfo, dwClassID, dwID)
	elseif hSelect.tInfo.bDungeon then
		Cyclopaedia_Active.UpdateDungeonInfo(hInfo, dwClassID, dwID)
	elseif hSelect.tInfo.bFieldPQ then
		Cyclopaedia_Active.UpdateFieldPQInfo(hInfo, dwClassID, dwID)
	end
	
	hInfo:FormatAllItemPos()
	Cyclopaedia_Active.UpdateInfoScroll(hInfo, true)
end

function Cyclopaedia_Active.UpdateFieldPQInfo(hInfo, dwPQTemplateID, nStep)
	if nStep then
		local tFieldPQStep = Table_GetFieldPQString(dwPQTemplateID, nStep)
		hInfo:AppendItemFromString(GetFormatText(tFieldPQStep.szName .. "\n", FONT_TITLE))
		hInfo:AppendItemFromString(GetFormatText("   " .. tFieldPQStep.szDesc .. "\n", FONT_NORMAL))
	elseif dwPQTemplateID then
		local tFieldPQInfo = Table_GetFieldPQ(dwPQTemplateID)
		hInfo:AppendItemFromString(GetFormatText(tFieldPQInfo.szName .. "\n", FONT_TITLE))
		hInfo:AppendItemFromString(GetFormatText("   " .. tFieldPQInfo.szDesc .. "\n", FONT_NORMAL))
	end	

	hInfo:FormatAllItemPos()
end


function Cyclopaedia_Active.UpdateActivityInfo(hInfo, dwClassID, dwActivityID)
	local tRecord = Table_GetActivityContent(dwClassID, dwActivityID)
	hInfo:AppendItemFromString(tRecord.szContent)
	
	if tRecord.szLink ~= "" then
		hInfo:AppendItemFromString(GetFormatText("\n\n\n\n" .. g_tStrings.CYCLOPAEDIA_LINK, FONT_TITLE))
		hInfo:AppendItemFromString(tRecord.szLink)
	end
	
	hInfo:FormatAllItemPos()
end

function Cyclopaedia_Active.UpdateDailyQuestInfo(hInfo, dwTypeID, dwQuestID)
	local tRecord = Table_GetDailyQuestContent(dwTypeID, dwQuestID)
	
	if dwTypeID ~= 0 and dwQuestID ~= 0 then
		Cyclopaedia_Active.UpdateDailyQuestContent(hInfo, dwQuestID)
	else
		hInfo:AppendItemFromString(tRecord.szContent)
	end
	
	if tRecord.szLink ~= "" then
		hInfo:AppendItemFromString(GetFormatText("\n\n\n\n" .. g_tStrings.CYCLOPAEDIA_LINK, FONT_TITLE))
		hInfo:AppendItemFromString(tRecord.szLink)
	end
	hInfo:FormatAllItemPos()
end


function Cyclopaedia_Active.UpdateDailyQuestContent(hInfo, dwQuestID)
	local tQuestInfo = GetQuestInfo(dwQuestID)
    local tQuestStringInfo = Table_GetQuestStringInfo(dwQuestID)
    
    local hPlayer = GetClientPlayer()
    local szText = GetFormatText(tQuestStringInfo.szName .. "\n", FONT_TITLE)
    
    if hPlayer.GetQuestState(dwQuestID) == QUEST_STATE.FINISHED then
		szText = szText .. GetFormatText(g_tStrings.STR_QUEST_FINISHED.."\n", FONT_NORMAL)
	else
		szText = szText .. GetFormatText(g_tStrings.STR_QUEST_UNFINISHED.."\n", FONT_DISSATISFY)
	end
	
	local szQuestClass = Table_GetQuestClass(tQuestInfo.dwQuestClassID)
	szText = szText .. GetFormatText(szQuestClass .. "\n", FONT_NORMAL)
	
	szText = szText .. GetFormatText(g_tStrings.TIP_START_LEVEL, FONT_NORMAL)
	
	if hPlayer.nLevel < tQuestInfo.nMinLevel then
		szText = szText .. GetFormatText(tQuestInfo.nMinLevel .. "\n", FONT_DISSATISFY)
	else
		szText = szText .. GetFormatText(tQuestInfo.nMinLevel .. "\n", FONT_NORMAL)
	end
	
	if tQuestInfo.dwRequireSchoolMask ~= 0 then
		local bFirst = true
		local szSchool = ""
		local bRequireSchool = false
		szSchool = GetFormatText(g_tStrings.QUEST_NEED_SCHOOL, FONT_NORMAL)
		for dwForceID, v in pairs(g_tStrings.tForceTitle) do
			if GetNumberBit(tQuestInfo.dwRequireSchoolMask, dwForceID + 1) then
				local nFont = FONT_DISSATISFY
				if hPlayer.dwForceID == dwForceID then
					nFont = FONT_NORMAL
				end
				if not bFirst then
					szSchool = szSchool .. GetFormatText(g_tStrings.QUEST_OR, FONT_NORMAL)
				end
				szSchool = szSchool .. GetFormatText(v, nFont)
				bFirst = false
			else
				bRequireSchool = true
			end
		end
		szSchool = szSchool .. GetFormatText("\n", FONT_NORMAL)
		
		if bRequireSchool then
			szText = szSchool
		end
	end
	
	local bFirst = true
	local bRequireCamp = false
	local szCamp = GetFormatText(g_tStrings.QUEST_NEED_CAMP, FONT_NORMAL)
	for nCamp, v in pairs(g_tStrings.STR_GUILD_CAMP_NAME) do
		if GetNumberBit(tQuestInfo.nRequireCampMask, nCamp + 1) then
			local nFont = FONT_DISSATISFY
			if hPlayer.nCamp == nCamp then
				nFont = FONT_NORMAL
			end
			if not bFirst then
				szCamp = szCamp .. GetFormatText(g_tStrings.QUEST_OR, FONT_NORMAL)
			end
			szCamp = szCamp .. GetFormatText(v, nFont)
			bFirst = false
		else
			bRequireCamp = true
		end
	end

	if bRequireCamp then
		szText = szText .. szCamp .. GetFormatText("\n", FONT_NORMAL)
	end
	local szRepute = GetFormatText(g_tStrings.QUEST_NEED_REPUTATION, FONT_NORMAL)
	local szConnect = g_tStrings.QUEST_OR
	if tQuestInfo.bRequireReputeAll then
		szConnect = g_tStrings.STR_AND
	end
	local bRepute = false
	bFirst = true
	for i = 1, QUEST_COUNT.QUEST_PARAM_COUNT do
		if tQuestInfo["dwRequireForceID" .. i] > 0 then
			bRepute = true
			local nFont = FONT_DISSATISFY
			
			local nCurrentRepute = hPlayer.GetReputeLevel(tQuestInfo["dwRequireForceID" .. i])
			if nCurrentRepute >= tQuestInfo["nReputeLevelMin" .. i] and nCurrentRepute <= tQuestInfo["nReputeLevelMax" .. i] then
				nFont = FONT_NORMAL
			end
			
			if not bFirst then
				szRepute = szRepute .. GetFormatText(szConnect, FONT_NORMAL)
			end
			
			szRepute = szRepute .. GetFormatText(g_tReputation.tReputationTable[tQuestInfo["dwRequireForceID" .. i]].szName, nFont)
			local szReputeLevel = FormatString(
				g_tStrings.QUEST_REPUTATION_SECT, 
				g_tReputation.tReputationLevelTable[tQuestInfo["nReputeLevelMin" .. i]].szLevel,
				g_tReputation.tReputationLevelTable[tQuestInfo["nReputeLevelMax" .. i]].szLevel
			)
			szRepute = szRepute .. GetFormatText(szReputeLevel, nFont)
			bFirst = true
		end
	end
	
	if bRepute then
		szText = szText .. szRepute .. GetFormatText("\n", FONT_NORMAL)
	end
		
	local bStart = false
    if tQuestInfo.dwStartNpcTemplateID ~= 0 then
    	local szNpcName = Table_GetNpcTemplateName(tQuestInfo.dwStartNpcTemplateID)
    	szText = szText .. GetFormatText(g_tStrings.TIP_START ..  szNpcName , FONT_NORMAL)
    	bStart = true
    elseif tQuestInfo.dwStartItemType ~= 0 and questInfo.dwStartItemIndex ~= 0 then
    	local tItemInfo = GetItemInfo(tQuestInfo.dwStartItemType, tQuestInfo.dwStartItemIndex)
    	if tItemInfo then
    		local szItemName = GetItemNameByItemInfo(tItemInfo)
    		szText = szText .. GetFormatText(g_tStrings.TIP_START .. szItemName .. g_tStrings.TIP_ITEM, FONT_NORMAL)
    		bStart = true
    	end
    end
    
    if bStart then
		local szQuestPos = Table_GetQuestPosInfo(dwQuestID, "accept", nIndex)
		if szQuestPos then
			szText = szText .. GetFormatImage("ui/Image/QuestPanel/QuestPanel.UITex", 36, 24, 24, 341, "Image_Accept")
		end
		szText = szText .. GetFormatText("\n", FONT_NORMAL)
	end

    
    if tQuestInfo.dwEndNpcTemplateID ~= 0 then
    	local szNpcName = Table_GetNpcTemplateName(tQuestInfo.dwEndNpcTemplateID)
    	szText = szText .. GetFormatText(g_tStrings.TIP_END .. szNpcName, FONT_NORMAL)
		local szQuestPos = Table_GetQuestPosInfo(dwQuestID, "finish", nIndex)
		if szQuestPos then
			szText = szText .. GetFormatImage("ui/Image/QuestPanel/QuestPanel.UITex", 32, 24, 24, 341, "Image_Finish")
		end
		szText = szText .. GetFormatText("\n", FONT_NORMAL)
    end
    szText = szText .. GetFormatText(g_tStrings.TIP_QUEST_TARGET, FONT_TITLE)
	
	hInfo:AppendItemFromString(szText)
	
	local hImageAccept = hInfo:Lookup("Image_Accept")
	if hImageAccept then
		hImageAccept.dwQuestID = dwQuestID
    	hImageAccept.OnItemMouseEnter = function()
    		local x, y = this:GetAbsPos()
    		local w, h = this:GetSize()
    		local szTip = GetFormatText(g_tStrings.QUEST_LOOKUP_FINISH_PLACE, FONT_TITLE)
    		OutputTip(szTip, 345, {x, y, w, h})
    		this:SetFrame(37)
    	end
    	hImageAccept.OnItemMouseLeave = function()
    		HideTip()
    		this:SetFrame(36)
    	end
    	hImageAccept.OnItemLButtonClick = function()
				OnMarkQuestTarget(this.dwQuestID, "finish", 0)
    	end
	end
	
	local hImageFinish = hInfo:Lookup("Image_Finish")
	if hImageFinish then
		hImageFinish.dwQuestID = dwQuestID
    	hImageFinish.OnItemMouseEnter = function()
    		local x, y = this:GetAbsPos()
    		local w, h = this:GetSize()
    		local szTip = GetFormatText(g_tStrings.QUEST_LOOKUP_FINISH_PLACE, FONT_TITLE)
    		OutputTip(szTip, 345, {x, y, w, h})
    		this:SetFrame(33)
    	end
    	hImageFinish.OnItemMouseLeave = function()
    		HideTip()
    		this:SetFrame(32)
    	end
    	hImageFinish.OnItemLButtonClick = function()
			OnMarkQuestTarget(this.dwQuestID, "finish", 0)
    	end
	end
	
	
	QuestAcceptPanel.EncodeString(hInfo, tQuestStringInfo.szObjective.."\n", FONT_NORMAL)
	QuestAcceptPanel.UpdateHortation(hInfo, tQuestInfo, false, false, true)
end

function Cyclopaedia_Active.UpdateInfoScroll(hList, bHome)
	local hWnd = hList:GetParent()
	local hScroll = hWnd:Lookup("Scroll_ActiveInfo")
	local fWidthAll, fHeightAll = hList:GetAllItemSize()
	local fWidth, fHeight = hList:GetSize()
	local nStepCount = math.ceil((fHeightAll - fHeight) / STEP_SIZE)
	hScroll:SetStepCount(nStepCount)
	
	if bHome then
		hScroll:ScrollHome()
	end
	if nStepCount > 0 then
		hScroll:Show()
		hWnd:Lookup("Btn_ActiveInfoUp"):Show()
		hWnd:Lookup("Btn_ActiveInfoDown"):Show()
	else
		hScroll:Hide()
		hWnd:Lookup("Btn_ActiveInfoUp"):Hide()
		hWnd:Lookup("Btn_ActiveInfoDown"):Hide()
	end
end

function Cyclopaedia_Active.UpdateTitle(hItem)
	local hImage = hItem:Lookup(1)
	if hItem.bSelect then
		hImage:Show()
	elseif hItem.bMouse then
		hImage:Show()
	else
		hImage:Hide()
	end
end

function Cyclopaedia_Active.UpdateList(hWnd, tTotalList, bExpand)
	local hList = hWnd:Lookup("", "Handle_Active")
	hList:Clear()
	
	--the first class must display in order
	for _, tClass in pairs(tTotalList) do
		local hClass = hList:AppendItemFromIni(INI_PATH, "TreeLeaf_Active", "TreeLeaf_Active")
		hClass:Lookup("Text_Active"):SetText(tClass.tInfo.szName)
		if tClass.tInfo.bActivity then
			hClass:Lookup("Text_Active"):SetFontScheme(FONT_DISABLE)
		end
		if bExpand then
			hClass:Expand()
		end
		hClass.tInfo = tClass.tInfo
		hClass.bActiveClass = true
		
		for _, tSub in pairs(tClass.tList) do
			local hSubClass = hList:AppendItemFromIni(INI_PATH, "TreeLeaf_Class", "TreeLeaf_Active")
			hSubClass:Lookup("Text_Class"):SetText(tSub.tInfo.szName)
			
			hSubClass.tInfo = tSub.tInfo
			if bExpand then
				hSubClass:Expand()
			end
			hSubClass.bActiveSubClass = true
			
			for _, tRecord in pairs(tSub.tList) do
				local hTitle = hList:AppendItemFromIni(INI_PATH, "TreeLeaf_Title", "TreeLeaf_Active")
				hTitle:Lookup("Text_Title"):SetText(tRecord.tInfo.szName)
				
				hTitle.tInfo = tRecord.tInfo
			end
		end
	end
	
	hList:FormatAllItemPos()
	Cyclopaedia_Active.UpdateListScroll(hList, true)
end

function Cyclopaedia_Active.UpdateDungeonInfo(hInfo, dwClassID, dwMapID)
	
	if dwMapID then
		local szContent = ""
		local szName = Table_GetMapName(dwMapID)
		szContent = szContent .. GetFormatText(szName .. "\n" , FONT_TITLE)
		
		local tRecord = Table_GetDungeonInfo(dwMapID)
		
		szContent = szContent .. GetFormatText(g_tStrings.DUNGEON_ENTER_LEVEL, FONT_SUB_TITLE) .. GetFormatText(tRecord.nMinLevel .. "\n", FONT_NORMAL)
		
		szContent = szContent .. GetFormatText(g_tStrings.DUNGEON_FIT_LEVEL, FONT_SUB_TITLE)
		if tRecord.nFitMinLevel == tRecord.nFitMaxLevel then
			szContent = szContent .. GetFormatText(tRecord.nFitMinLevel .. "\n", FONT_NORMAL)
		else
			szContent = szContent .. GetFormatText(tRecord.nFitMinLevel .. g_tStrings.DUNGEON_INTERVAL_SYMBOL .. tRecord.nFitMaxLevel .. "\n", FONT_NORMAL)
		end
		
		local _, _, nMaxPlayerCount = GetMapParams(dwMapID)
		
		szContent = szContent .. GetFormatText(g_tStrings.DUNGEON_ENTER_NUMBER, FONT_SUB_TITLE) .. GetFormatText(nMaxPlayerCount .. "\n", FONT_NORMAL)
		
		szContent = szContent .. GetFormatText(g_tStrings.DUNGEON_ENTER_INFO, FONT_SUB_TITLE) .. GetFormatText(tRecord.szEnterWay .. "\n", FONT_NORMAL)
		if tRecord.szBossInfo ~= "" then
			szContent = szContent .. GetFormatText(g_tStrings.DUNGEON_BOSS_INFO, FONT_SUB_TITLE) .. GetFormatText(tRecord.szBossInfo .. "\n", FONT_NORMAL)
		end
		
		if tRecord.szTutorial ~= "" then
			szContent = szContent .. GetFormatText(g_tStrings.DUNGEON_TUTORIAL, FONT_SUB_TITLE) .. tRecord.szTutorial .. GetFormatText("\n"  , FONT_NORMAL)
		end
		
		if tRecord.szIntroduction ~= "" then
			szContent = szContent .. GetFormatText(g_tStrings.DUNGEON_INTRODUCTION, FONT_SUB_TITLE) .. tRecord.szIntroduction .. GetFormatText("\n"  , FONT_NORMAL)
		end
		
		hInfo:AppendItemFromString(szContent)
	elseif dwClassID then
		local tRecord = Table_GetDungeonClass(dwClassID)
		
		hInfo:AppendItemFromString(tRecord.szContent)
		
		if tRecord.szLink ~= "" then
			hInfo:AppendItemFromString(GetFormatText("\n\n\n\n" .. g_tStrings.CYCLOPAEDIA_LINK, FONT_TITLE))
			hInfo:AppendItemFromString(tRecord.szLink)
		end
	end
	hInfo:FormatAllItemPos()
end

function Cyclopaedia_Active.GetList()
	local tTotalList = {}
	
	--[[
	local tActivity = Table_GetActivityList()
	table.insert(tTotalList, tActivity)
	--]]
	
	local tDailyQuest = Table_GetDailyQuestList()
	table.insert(tTotalList, tDailyQuest)
	
	local tDungeonList = Table_GetDungeonList()
	table.insert(tTotalList, tDungeonList)
	
	local tFieldPQList = Table_GetFieldPQList()
	table.insert(tTotalList, tFieldPQList)
	
	local tActivity = {}
	tActivity.tInfo = {}
	tActivity.tInfo.szName = g_tStrings.CYCLOPAEDIA_ACTIVE
	tActivity.tInfo.bActivity = true
	tActivity.tList = {}
	table.insert(tTotalList, tActivity)
	
	return tTotalList
end

function Cyclopaedia_Active.UpdateListScroll(hList, bHome)
	local hWnd = hList:GetParent():GetParent()
	local hScroll = hWnd:Lookup("Scroll_ActiveLeft")
	local fWidthAll, fHeightAll = hList:GetAllItemSize()
	local fWidth, fHeight = hList:GetSize()
	local nStepCount = math.ceil((fHeightAll - fHeight) / STEP_SIZE)
	hScroll:SetStepCount(nStepCount)
	
	if nStepCount > 0 then
		hScroll:Show()
		hWnd:Lookup("Btn_ActiveUp"):Show()
		hWnd:Lookup("Btn_ActiveDown"):Show()
	else
		hScroll:Hide()
		hWnd:Lookup("Btn_ActiveUp"):Hide()
		hWnd:Lookup("Btn_ActiveDown"):Hide()
	end
	
	if bHome then
		hScroll:ScrollHome()
	end
end

function Cyclopaedia_Active.SearchInfo(hWnd, szText)
	local tTotalList = Cyclopaedia_Active.GetList()
	local bSearch = false
	local tResult = {}
	
	for _, tClass in pairs(tTotalList) do
		if StringFindW(tClass.tInfo.szName, szText) then
			table.insert(tResult, tClass)
			bSearch = true
		else
			local tActive
			for _, tSub in pairs(tClass.tList) do
				if StringFindW(tSub.tInfo.szName, szText) then
					if not tActive then
						tActive = {}
						tActive.tInfo = tClass.tInfo
						tActive.tList = {}
					end
					table.insert(tActive.tList, tSub)
					bSearch = true
				else
					for _, tRecord in pairs(tSub.tList) do
						if StringFindW(tRecord.tInfo.szName, szText) then
							if not tActive then
								tActive = {}
								tActive.tInfo = tClass.tInfo
								tActive.tList = {}
							end
							table.insert(tActive.tList, tRecord)
							bSearch = true
						end
					end
				end
			end
			
			if tActive then
				table.insert(tResult, tActive)
			end
		end
	end
	
	if bSearch then
		Cyclopaedia_Active.UpdateList(hWnd, tResult, true)
		local hList = hWnd:Lookup("", "Handle_Active")
		Cyclopaedia_Active.Select(hList:Lookup(0))
	else
		Cyclopaedia_Active.UpdateNoSearch(hWnd)
	end
end

function Cyclopaedia_Active.UpdateNoSearch(hWnd)
	local hList = hWnd:Lookup("", "Handle_Active")
	hList:Clear()
	local szText = GetFormatText(g_tStrings.NOT_FINED, 162)
	local hNoScarch = hList:AppendItemFromIni(INI_PATH, "TreeLeaf_Active", "TreeeLeaf_NoSearch")
	hNoScarch:Lookup("Text_Active"):SetText(g_tStrings.NOT_FINED)
	hList:FormatAllItemPos()
	Cyclopaedia_Active.UpdateListScroll(hList)
	
	local hInfo = hWnd:Lookup("Wnd_Info", "")
	hInfo:Clear()
	Cyclopaedia_Active.UpdateInfoScroll(hInfo, true)
end

function Cyclopaedia_LinkActive(hFrame, szLinkEvent, dwClassID, dwID)
	local hWnd = hFrame:Lookup("PageSet_Total/Page_Active/Wnd_Active")
	Cyclopaedia_Active.Update(hWnd)
	local hList = hWnd:Lookup("", "Handle_Active")
	
	local nCount = hList:GetItemCount()
	for i = 0, nCount - 1 do
		local hTitle = hList:Lookup(i)
		if IsActiveEventMatch(szLinkEvent, hTitle) then
			if hTitle.bActiveClass or (hTitle.bActiveSubClass and hTitle.tInfo.dwClassID == dwClassID) then 
				hTitle:Expand()
				hList:FormatAllItemPos()
				Cyclopaedia_Active.UpdateListScroll(hList)
				Cyclopaedia_Active.Select(hTitle)
			end
			
			if hTitle.tInfo.dwClassID == dwClassID and hTitle.tInfo.dwID == dwID then
				Cyclopaedia_Active.Select(hTitle)
				break
			end
		end
	end
end

function IsActiveEventMatch(szLinkEvent, hTitle)
	if szLinkEvent == "Active" and hTitle.tInfo.bActivity then
		return true
	end
	
	if szLinkEvent == "QuestDaily" and hTitle.tInfo.bDailyQuest then
		return true
	end
		
	if szLinkEvent == "DungeonInfo" and hTitle.tInfo.bDungeon then
		return true
	end
	
	if szLinkEvent == "FieldPQ" and hTitle.tInfo.bFieldPQ then
		return true
	end
	
	return false
end
