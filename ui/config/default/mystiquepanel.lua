MystiquePanel = {}

local RECIPE_GROUP_BG_BUTTOM_SPACE = 16
local MYSTIQUEPANEL_INI_FILE = "UI/Config/Default/MystiquePanel.ini"
local SKILL_TIP_FONT_ATTACH = 165


local nRecipeActicedCount = 0
local nRecipeScrollPos = 0
local nRecipeTipScrollPos = 0
local tRecipeGroupMinimizeState = {}

function MystiquePanel.OnFrameCreate()
	this:RegisterEvent("SKILL_RECIPE_LIST_UPDATE")
	this:Lookup("", "Handle_List"):Clear()
	this:Lookup("Scroll_List"):Hide()
	this:Lookup("Btn_Up"):Hide()
	this:Lookup("Btn_Down"):Hide()
	
	nRecipeScrollPos = 0
	nRecipeTipScrollPos = 0
	tRecipeGroupMinimizeState = {}
	
	InitFrameAutoPosInfo(this, 1, nil, "SkillPanel", function() CloseMystiquePanel(true) end)
end

function MystiquePanel.OnEvent(event)
	if event == "SKILL_RECIPE_LIST_UPDATE" then
		nRecipeScrollPos = this:Lookup("Scroll_List"):GetScrollPos()
		nRecipeTipScrollPos = this:Lookup("Scroll_Tip"):GetScrollPos()
			
		MystiquePanel.Update(this)
	end
end

function MystiquePanel.Update(frame)	
	local dwID, dwLevel = MystiquePanel.dwSkillID, MystiquePanel.dwLevel
	local handle = frame:Lookup("", "")
	
--	local box = handle:Lookup("Box_MainSkill")
--	box:SetObject(UI_OBJECT_SKILL, dwID, dwLevel)
--	box:SetObjectIcon(Table_GetSkillIconID(dwID, dwLevel))	
	
	local hTip = handle:Lookup("Handle_SkillTip")
	MystiquePanel.UpdateTip(hTip)
	
	local hList = handle:Lookup("Handle_List")
	MystiquePanel.UpdateList(hList)
	
	-- MystiquePanel.UpdateEquiped(handle, hList)
end

function MystiquePanel.UpdateEquiped(handle, hList)
	for i = 1, 4, 1 do
		handle:Lookup("Box_"..i):ClearObject()
	end
	local nIndex = 1
	local nCount = hList:GetItemCount() - 1
	for i = 0, nCount, 1 do
		local hI = hList:Lookup(i)
		if hI.bEquiped then
			local box = handle:Lookup("Box_"..nIndex)
			box:SetObject(UI_OBJECT_SKILL_RECIPE, hI.dwID, hI.dwLevel)
			local tSkillRecipe = Table_GetSkillRecipe(hI.dwID, hI.dwLevel)
			local nIconID = -1
			if tSkillRecipe then
				nIconID = tSkillRecipe.nIconID
			end
			box:SetObjectIcon(nIconID)
			nIndex = nIndex + 1
			if nIndex > 4 then
				break
			end
		end
	end
end

function MystiquePanel.UpdateList(hList)
	hList:Clear()
	
    tRecipeList = Table_GetRecipeList(MystiquePanel.dwSkillID)
    if not tRecipeList or #tRecipeList < 1 then
		return
	end
    
	local hPlayer = GetClientPlayer()
	local tMyRecipeList = hPlayer.GetSkillRecipeList(MystiquePanel.dwSkillID, MystiquePanel.dwLevel)
	if not tMyRecipeList then
        tMyRecipeList = {}
	end
    local tMyRecipeMap = {}
    for _, tRecipe in ipairs(tMyRecipeList) do
        tMyRecipeMap[tRecipe.recipe_id] = tRecipe
    end
    
	local tRecipeGroupMap = {}
	for nIndex, tRecipe in ipairs(tRecipeList) do
        local tRecipeInfo = {}
		local tSkillRecipe = Table_GetSkillRecipe(tRecipe.recipe_id, tRecipe.recipe_level)
        local dwID = 0
        if tSkillRecipe then
            dwID = tSkillRecipe.dwTypeID
        end
        assert(dwID)
        if not tRecipeGroupMap[dwID] then
            tRecipeGroupMap[dwID] = {}
        end
        if tMyRecipeMap[tRecipe.recipe_id] then
            tRecipeInfo = tMyRecipeMap[tRecipe.recipe_id]
            tRecipeInfo.bHave = true
        else
            tRecipeInfo = tRecipe
            tRecipeInfo.bHave = false
        end
        table.insert(tRecipeGroupMap[dwID], tRecipeInfo)
	end
	nRecipeActicedCount = 0
	for dwTypeID, tRecipeGroup in pairs(tRecipeGroupMap) do
		MystiquePanel.AddRecipeGroup(hList, dwTypeID, tRecipeGroup)	
	end
	
    local hActicedNumber = hList:GetParent():Lookup("Text_Number")
    hActicedNumber:SetText(nRecipeActicedCount .. "/" .. MAX_SKILL_REICPE_COUNT)
	MystiquePanel.UpdateScrollInfo(hList)
end

function MystiquePanel.AddRecipeGroup(hList, dwTypeID, tRecipeGroup)
	local nGroupActivedCount = 0
	local hGroup = hList:AppendItemFromIni(MYSTIQUEPANEL_INI_FILE, "Handle_Group", "Handle_Group_" .. dwTypeID)
	hGroup.dwTypeID = dwTypeID
	local hItems = hGroup:Lookup("Handle_Items")
	for nIndex, tRecipe in ipairs(tRecipeGroup) do
		local hItem = hItems:AppendItemFromIni(MYSTIQUEPANEL_INI_FILE, "Handle_Item", "Handle_Item" .. nIndex)
		local hBox = hItem:Lookup("Box_Mys")
		hBox:SetObject(UI_OBJECT_SKILL_RECIPE, tRecipe.recipe_id, tRecipe.recipe_level)
		local tSkillRecipe = Table_GetSkillRecipe(tRecipe.recipe_id, tRecipe.recipe_level)
		local nIconID = -1
		if tSkillRecipe then
			nIconID = tSkillRecipe.nIconID
		end
		hBox:SetObjectIcon(nIconID)
        hBox.bActive = tRecipe.active
        hBox.bHave = tRecipe.bHave
		local hActived = hItem:Lookup("Animate_Actived")
		if tRecipe.active then
			hActived:Show()
			nGroupActivedCount = nGroupActivedCount + 1
		else
			hActived:Hide()
		end
        local hImageNotOwn = hItem:Lookup("Image_NotOwn")
        if tRecipe.bHave then
            hImageNotOwn:Hide()
        else 
            hImageNotOwn:Show()
        end
		hItem.dwID = tRecipe.recipe_id
		hItem.dwLevel = tRecipe.recipe_level
	end
	hItems:FormatAllItemPos()
	hItems:SetSizeByAllItemSize()
	
	nRecipeActicedCount = nRecipeActicedCount + nGroupActivedCount
	
	local tSkillRecipeType = g_tTable.SkillRecipeType:Search(dwTypeID)
	local szDesc = ""
	if tSkillRecipeType then
		szDesc = tSkillRecipeType.szDesc
	end
	hGroup:Lookup("Text_Name"):SetText(szDesc)
	
	local nGroupWidth, _ = hGroup:GetSize()
	local _, nTitleHeight = hGroup:Lookup("Image_Bright"):GetSize()
	local _, nItemsHeight = hItems:GetSize()

	local nGroupHeight = nTitleHeight + nItemsHeight + RECIPE_GROUP_BG_BUTTOM_SPACE
	hGroup:Lookup("Image_Bg"):SetSize(nGroupWidth, nGroupHeight)
	hGroup:SetSize(nGroupWidth, nGroupHeight)
	hGroup:AdjustItemShowInfo()
	
	MystiquePanel.MinimizeRecipeGroup(hGroup, tRecipeGroupMinimizeState[dwTypeID])
end

function MystiquePanel.MinimizeRecipeGroup(hGroup, bMini)
	assert(hGroup)
	
	local hImageBg = hGroup:Lookup("Image_Bg")
	local hItems = hGroup:Lookup("Handle_Items")
	local hImageMinimize = hGroup:Lookup("Image_Minimize")
	if bMini then
		hItems:Hide()
		hImageBg:Hide()
		local nGroupWidth, _ = hGroup:GetSize()
		local _, nTitleHeight = hGroup:Lookup("Image_Bright"):GetSize()
		hGroup:SetSize(nGroupWidth, nTitleHeight + RECIPE_GROUP_BG_BUTTOM_SPACE / 2)
		hImageMinimize:SetFrame(8)
	else
		hItems:Show()
		hImageBg:Show()
		local nGroupWidth, _ = hGroup:GetSize()
		local _, nTitleHeight = hGroup:Lookup("Image_Bright"):GetSize()
		local _, nItemsHeight = hItems:GetSize()
		local nGroupHeight = nTitleHeight + nItemsHeight + RECIPE_GROUP_BG_BUTTOM_SPACE
		hGroup:Lookup("Image_Bg"):SetSize(nGroupWidth, nGroupHeight)
		hGroup:SetSize(nGroupWidth, nGroupHeight)
		hImageMinimize:SetFrame(12)
	end
	
	tRecipeGroupMinimizeState[hGroup.dwTypeID] = bMini
	MystiquePanel.UpdateScrollInfo(hGroup:GetParent())
end

function MystiquePanel.UpdateScrollInfo(handle)
	local frame = handle:GetRoot()
	handle:FormatAllItemPos()
	
	local wAll, hAll = handle:GetAllItemSize()
	local w, h = handle:GetSize()
	local scroll = frame:Lookup("Scroll_List")
	local nCountStep = math.ceil((hAll - h) / 10)
	scroll:SetStepCount(nCountStep)
	scroll:SetScrollPos(nRecipeScrollPos)
	if nCountStep > 0 then
		frame:Lookup("Btn_Up"):Show()
		frame:Lookup("Btn_Down"):Show()
		scroll:Show()
	else
		frame:Lookup("Btn_Up"):Hide()
		frame:Lookup("Btn_Down"):Hide()
		scroll:Hide()
	end
end

function MystiquePanel.UpdateTip(handle)
	handle:Clear()
	
	local szTip = FormatSkillTip(MystiquePanel.dwSkillID, MystiquePanel.dwLevel, false, false, false, true)
	szTip = string.gsub(szTip, "\t", "\n")
	handle:AppendItemFromString(szTip)
	MystiquePanel.UpdateTipScrollInfo(handle)
end

function MystiquePanel.UpdateTipScrollInfo(handle)
	local frame = handle:GetRoot()
	handle:FormatAllItemPos()
	
	local wAll, hAll = handle:GetAllItemSize()
	local w, h = handle:GetSize()
	local scroll = frame:Lookup("Scroll_Tip")
	local nCountStep = math.ceil((hAll - h) / 10)
	scroll:SetStepCount(nCountStep)
	scroll:SetScrollPos(nRecipeTipScrollPos)
	if nCountStep > 0 then
		frame:Lookup("Btn_UpTip"):Show()
		frame:Lookup("Btn_DownTip"):Show()
		scroll:Show()
	else
		frame:Lookup("Btn_UpTip"):Hide()
		frame:Lookup("Btn_DownTip"):Hide()
		scroll:Hide()
	end
end

function MystiquePanel.OnItemMouseEnter()
	if this:GetType() == "Box" then
		this:SetObjectMouseOver(true)
		local nType = this:GetObjectType()
		if nType == UI_OBJECT_SKILL then
			local dwSkillID, dwLevel = this:GetObjectData()
			local x, y = this:GetAbsPos()
			local w, h = this:GetSize()
			OutputSkillTip(dwSkillID, dwLevel, {x, y, w, h}, true)
		elseif nType == UI_OBJECT_SKILL_RECIPE then
			local x, y = this:GetAbsPos()
			local w, h = this:GetSize()		
			local dwID, dwLevel = this:GetObjectData()
			OutputSkillRecipeTip(dwID, dwLevel, {x, y, w, h}, false, {bHave = this.bHave, bActive = this.bActive})
		end
	end
end

function MystiquePanel.OnItemMouseLeave()
	if this:GetType() == "Box" then
		this:SetObjectMouseOver(false)
		HideTip()
	end
end

function MystiquePanel.OnItemLButtonDown()
	local szName = this:GetName()
	if szName == "Box_MainSkill" then
		if IsCtrlKeyDown() then
			local dwSkillID, dwLevel = this:GetObjectData()
			if IsGMPanelReceiveSkill() then
				GMPanel_LinkSkill(dwSkillID, dwLevel)
			else
				EditBox_AppendLinkSkill(GetClientPlayer().GetSkillRecipeKey(dwSkillID, dwLevel))
			end
			this.bIgnoreClick = true
			return
		end
		this.bIgnoreClick = false	
		this:SetObjectPressed(true)
		MystiquePanel.bTip = true
	elseif szName == "Box_1" or szName == "Box_2" or szName == "Box_3" or szName == "Box_4" or szName == "Box_Mys" then
		if IsCtrlKeyDown() and not this:IsEmpty() then
			local dwID, dwLevel = this:GetObjectData()
			EditBox_AppendLinkSkillRecipe(dwID, dwLevel)
		end
		MystiquePanel.bTip = true
	elseif szName == "Handle_SkillTip" then
		MystiquePanel.bTip = true
	elseif szName == "Handle_List" then
		MystiquePanel.bTip = false
	else
		MystiquePanel.bTip = false
	end
end

function MystiquePanel.OnItemLButtonUp()
	local szName = this:GetName()
	if szName == "Box_MainSkill" then
		this:SetObjectPressed(false)
	end
end

function MystiquePanel.OnItemLButtonClick()	
	local szName = this:GetName()
	if szName == "Box_Mys" then
		if nRecipeActicedCount >= MAX_SKILL_REICPE_COUNT then
			OutputMessage("MSG_ANNOUNCE_RED", FormatString(g_tStrings.SKILL_RECIPE_ERROR_MAX_COUNT, MAX_SKILL_REICPE_COUNT))
			return
		end
		
        if not this.bHave then
            OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.SKILL_RECIPE_ERROR_NOT_HAVE)
        else
            local hItem = this:GetParent()
            local nRetCode = GetClientPlayer().ActiveSkillRecipe(hItem.dwID, hItem.dwLevel)
            if nRetCode ~= SKILL_RECIPE_RESULT_CODE.SUCCESS then
                if nRetCode == SKILL_RECIPE_RESULT_CODE.ERROR_IN_FIGHT then
                    OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.SKILL_RECIPE_ERROR_INFIGHT_ON)
                else
                    OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.SKILL_RECIPE_ERROR_UNKNOWN_ON)
                end
            else
                FireUIEvent("MYSTIQUE_ACTIVE_UPDATE", MystiquePanel.dwSkillID, MystiquePanel.dwLevel)
                
                FireEvent("ON_ACTIVE_SKILL_RECIPE")
                
                FireDataAnalysisEvent("MYSTIQUE_ACTIVE")
            end

        end
	elseif szName == "Animate_Actived" then
		local hItem = this:GetParent()
		local nRetCode = GetClientPlayer().DeactiveSKillRecipe(hItem.dwID, hItem.dwLevel)
		if nRetCode ~= SKILL_RECIPE_RESULT_CODE.SUCCESS then
			if nRetCode == SKILL_RECIPE_RESULT_CODE.ERROR_IN_FIGHT then
				OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.SKILL_RECIPE_ERROR_INFIGHT_OFF)
			else
				OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.SKILL_RECIPE_ERROR_UNKNOWN_OFF)
			end
		else
			FireUIEvent("MYSTIQUE_ACTIVE_UPDATE", MystiquePanel.dwSkillID, MystiquePanel.dwLevel)
		end
	elseif szName == "Image_Bright" then
		local hGroup = this:GetParent()
		MystiquePanel.MinimizeRecipeGroup(hGroup, not tRecipeGroupMinimizeState[hGroup.dwTypeID])
	end
end

function MystiquePanel.OnItemRButtonClick()
	 MystiquePanel.OnItemLButtonClick()
end

function MystiquePanel.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_Close" then
		CloseMystiquePanel()
	end
end

function MystiquePanel.OnLButtonHold()
	local szName = this:GetName()
	if szName == "Btn_Up" then
		this:GetParent():Lookup("Scroll_List"):ScrollPrev(1)
	elseif szName == "Btn_Down" then
		this:GetParent():Lookup("Scroll_List"):ScrollNext(1)
	elseif szName == "Btn_UpTip" then
		this:GetParent():Lookup("Scroll_Tip"):ScrollPrev(1)
	elseif szName == "Btn_DownTip" then
		this:GetParent():Lookup("Scroll_Tip"):ScrollNext(1)
	end
end

function MystiquePanel.OnLButtonDown()
	MystiquePanel.OnLButtonHold()
end

function MystiquePanel.OnScrollBarPosChanged()
	local nCurrentValue = this:GetScrollPos()
	local frame = this:GetParent()
	local szName = this:GetName()
	if szName == "Scroll_List" then
		if nCurrentValue == 0 then
			frame:Lookup("Btn_Up"):Enable(0)
		else
			frame:Lookup("Btn_Up"):Enable(1)
		end
		if nCurrentValue == this:GetStepCount() then
			frame:Lookup("Btn_Down"):Enable(0)
		else
			frame:Lookup("Btn_Down"):Enable(1)
		end		
	    frame:Lookup("", "Handle_List"):SetItemStartRelPos(0, - nCurrentValue * 10)	
	elseif szName == "Scroll_Tip" then
		if nCurrentValue == 0 then
			frame:Lookup("Btn_UpTip"):Enable(0)
		else
			frame:Lookup("Btn_UpTip"):Enable(1)
		end
		if nCurrentValue == this:GetStepCount() then
			frame:Lookup("Btn_DownTip"):Enable(0)
		else
			frame:Lookup("Btn_DownTip"):Enable(1)
		end
	    frame:Lookup("", "Handle_SkillTip"):SetItemStartRelPos(0, - nCurrentValue * 10)
	end
end

function MystiquePanel.OnItemMouseWheel()
	local nDistance = Station.GetMessageWheelDelta()
	if MystiquePanel.bTip then
		local scroll = this:GetParent():Lookup("Scroll_Tip")
		if scroll:IsVisible() then
			scroll:ScrollNext(nDistance)
		else
			this:GetParent():Lookup("Scroll_List"):ScrollNext(nDistance)
		end
	else
		local scroll = this:GetParent():Lookup("Scroll_List")
		if scroll:IsVisible() then
			scroll:ScrollNext(nDistance)
		else	
			this:GetParent():Lookup("Scroll_Tip"):ScrollNext(nDistance)
		end
	end
	return true	
end

function OpenMystiquePanel(dwSkillID, dwLevel, bDisableSound)
	local frame = Station.Lookup("Normal/MystiquePanel")
	if not frame then
		frame = Wnd.OpenWindow("MystiquePanel")
	end
	
	MystiquePanel.dwSkillID = dwSkillID
	MystiquePanel.dwLevel = dwLevel
	
	MystiquePanel.Update(frame)
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND, g_sound.OpenFrame)
	end
end

function OpenOrCloseMystiquePanel(dwSkillID, dwLevel, bDisableSound)
	if IsOptionOrOptionChildPanelOpened() then
		return
	end

	if IsMystiquePanelOpened() and MystiquePanel.dwSkillID == dwSkillID and MystiquePanel.dwLevel == dwLevel then
		CloseMystiquePanel(bDisableSound)
	else
		OpenMystiquePanel(dwSkillID, dwLevel, bDisableSound)
	end
end

function IsMystiquePanelOpened()
	if Station.Lookup("Normal/MystiquePanel") then
		return true
	end
	return false
end

function CloseMystiquePanel(bDisableSound)
	Wnd.CloseWindow("MystiquePanel")
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND, g_sound.CloseFrame)
	end	
end