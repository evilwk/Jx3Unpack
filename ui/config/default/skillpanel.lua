SkillPanel = {}

local aSkillPanelData = {}

local function SetSkillPanelData(box)
	local dwType, nData1, nData2, nData3, nData4, nData5, nData6 = box:GetObject()
	aSkillPanelData[box] = {dwType, nData1, nData2, nData3, nData4, nData5, nData6}
end

function SkillPanel.OnFrameCreate()
	this.bDoubleSize = true
	this:RegisterEvent("SKILL_UPDATE")
	this:RegisterEvent("SKILL_EXP_UPDATE")
	this:RegisterEvent("SKILL_MOUNT_KUNG_FU")
	this:RegisterEvent("SKILL_UNMOUNT_KUNG_FU")
	this:RegisterEvent("EQUIP_ITEM_UPDATE")
	this:RegisterEvent("SYNC_ROLE_DATA_END")
	this:RegisterEvent("ADD_SKILL_RECIPE")
	this:RegisterEvent("SWITCH_BIGSWORD")
	this:RegisterEvent("PLAYER_LEVEL_UPDATE")
	this:RegisterEvent("MYSTIQUE_ACTIVE_UPDATE")
	
	SkillPanel.UpdateSchoolInfo(this)
	
	InitFrameAutoPosInfo(this, 2, nil, nil, function() CloseSkillPanel(true) end)  
end

function SkillPanel.UpdateSchoolInfo(frame)
	local player = GetClientPlayer()
	if not player then
		return
	end
	local aSchool = player.GetSchoolList()
	for i = 0, 10, 1 do
		local dwSchoolID = aSchool[i + 1]
		local checkSchool = frame:Lookup("CheckBox_M"..i)
		checkSchool.dwSchoolID = dwSchoolID
		if dwSchoolID then
			checkSchool:Show()
			checkSchool:Lookup("", ""):Lookup(0):SetText(Table_GetSkillSchoolName(dwSchoolID))
			if not frame.dwSchoolID then
				frame.dwSchoolID = dwSchoolID
				SkillPanel.UpdateSkillInSchool(frame:Lookup("Wnd_Content", ""), dwSchoolID)
			end
			if frame.dwSchoolID == dwSchoolID then
				checkSchool:Check(true)
			else
				checkSchool:Check(false)
			end
		else
			checkSchool:Hide()
		end
	end
end

function SkillPanel.OnCheckBoxCheck()
	local frame = this:GetParent()
	local szNameMe = this:GetName()
	for i = 0, 10, 1 do
		local szName = "CheckBox_M"..i
		if szNameMe == szName then
			if frame.dwSchoolID ~= this.dwSchoolID then
				frame.dwSchoolID = this.dwSchoolID
				SkillPanel.UpdateSkillInSchool(frame:Lookup("Wnd_Content", ""), this.dwSchoolID)
				PlaySound(SOUND.UI_SOUND, g_sound.OpenFrame)
			end
			frame:Lookup(szName):Check(true)
			this:BringToTop()
		else
			frame:Lookup(szName):Check(false)
		end
	end
end

function SkillPanel.OnScrollBarPosChanged()
	local nCurrentValue = this:GetScrollPos()
	local frame = this:GetParent()
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
end

function SkillPanel.GetKungfuList(dwSchoolID)
	local player = GetClientPlayer()
	local t = g_tTable.SchoolSkill:Search(dwSchoolID)
	local a = {}
	if t and t.szSkill then
		local szKungfu = t.szSkill
		for s in string.gmatch(szKungfu, "%d+") do
			local dwID = tonumber(s)
			if dwID then
				a[dwID] = player.GetSkillLevel(dwID) or 0
			end
		end
	end
	
	local aLearned = player.GetKungfuList(dwSchoolID)
	if aLearned then
		for k, v in pairs(aLearned) do
			a[k] = v
		end
	end
	
	return a
end

function SkillPanel.UpdateSkillInSchool(handle, dwSchoolID)
	local aKungfu = SkillPanel.GetKungfuList(dwSchoolID)
	local hKF = handle:Lookup("Handle_List")
	hKF:Clear()
	handle:GetParent():Lookup("Scroll_List"):ScrollHome()
	handle.bNotSel = nil
	for dwID, dwLevel in pairs(aKungfu) do
		local dwShowlevel = dwLevel
		if dwLevel == 0 then
			dwShowlevel = 1
		end
		if Table_IsSkillShow(dwID, dwShowlevel) then
			SkillPanel.NewKungfu(hKF, dwID, dwLevel)
		end
	end	
	if hKF:GetItemCount() > 0 then
		hKF:Lookup(0):Select()
		hKF.bNotSel = nil
	else
		SkillPanel.UpdateSkillInKungfu(hKF:GetParent(), nil, nil, true)
	end	
	SkillPanel.UpdateScrollInfo(hKF)
	handle:Lookup("Image_Describe"):FromIconID(Table_GetSkillSchoolIconID(dwSchoolID))
end

function SkillPanel.UpdateScrollInfo(handle)
	handle:Sort()
	local nCount = handle:GetItemCount() - 1
	local hSel = nil
	for i = 0, nCount, 1 do
		local hI = handle:Lookup(i)
		local w, h = hI:GetSize()
		hI:SetRelPos(0, 14 + h * (nCount - i))
		if hI.bSel then
			hSel = hI
		end
	end
	if hSel then
		hSel:SetIndex(nCount)
	end
	handle:FormatAllItemPos()
	local w, h = handle:GetSize()
	local wA, hA = handle:GetAllItemSize()
	local scroll = handle:GetParent():GetParent():Lookup("Scroll_List")
	local nStep = math.ceil((hA - h) / 10)
	scroll:SetStepCount(nStep)
	
	if nStep > 0 then
		scroll:Show()
		scroll:GetParent():Lookup("Btn_Up"):Show()
		scroll:GetParent():Lookup("Btn_Down"):Show()
	else
		scroll:Hide()
		scroll:GetParent():Lookup("Btn_Up"):Hide()
		scroll:GetParent():Lookup("Btn_Down"):Hide()	
	end
end

function SkillPanel.UpdateMytiqueActive(frame, dwSkillID, dwSkillLevel)
    local player = GetClientPlayer()
    local hList = frame:Lookup("Wnd_Content", "Handle_Content");
    local nCount = hList:GetItemCount() - 1
    for i = 0, nCount , 1 do
        local hItem = hList:Lookup(i)
        local dwID = hItem.dwID
        local dwLevel = player.GetSkillLevel(hItem.dwID)
        if dwSkillID == dwID and dwSkillLevel == dwLevel then
            local nCount = player.GetSkillRecipeKeyCount(dwID, dwLevel)
            for i = 1, 4 do
                if i <= nCount then
                    hItem:Lookup("Image_Point0"..i):Show()
                else
                    hItem:Lookup("Image_Point0"..i):Hide()
                end
            end
        end
    end
end

function SkillPanel.NewKungfu(handle, dwID, dwLevel)
	handle:AppendItemFromIni("UI/Config/Default/SkillPanel.ini", "Handle_KF", "")
	local hI = handle:Lookup(handle:GetItemCount() - 1)
	
	hI.Update = function(hItem, dwID, dwLevel)
		hItem.bLearned = dwLevel > 0
		if dwLevel == 0 then
			dwLevel = 1
		end
		hItem.dwID = dwID
		hItem.dwLevel = dwLevel
		local player = GetClientPlayer()
		local skill = GetSkill(dwID, dwLevel)
		hItem:SetUserData(-Table_GetSkillSortOrder(dwID, dwLevel))
		if skill.nUIType == 3 then
			hItem:Lookup("Text_Type"):SetText(g_tStrings.FORMATION_NAME)
			hItem:Lookup("Image_BoxBg"):FromUITex("ui\\Image\\Common\\MainPanel_1.UITex", 16)
			hItem:Lookup("Image_BoxBgOver"):FromUITex("ui\\Image\\Common\\MainPanel_1.UITex", 17)
			hItem:Lookup("Image_BoxBgSel"):FromUITex("ui\\Image\\Common\\MainPanel_1.UITex", 15)		
		elseif skill.nUIType == 2 then --内功
			hItem:Lookup("Text_Type"):SetText(g_tStrings.STR_SKILL_NG)
			hItem:Lookup("Image_BoxBg"):FromUITex("ui\\Image\\Common\\MainPanel_1.UITex", 18)
			hItem:Lookup("Image_BoxBgOver"):FromUITex("ui\\Image\\Common\\MainPanel_1.UITex", 19)
			hItem:Lookup("Image_BoxBgSel"):FromUITex("ui\\Image\\Common\\MainPanel_1.UITex", 22)
		else
			hItem:Lookup("Text_Type"):SetText(g_tStrings.STR_SKILL_ZS)
			hItem:Lookup("Image_BoxBg"):FromUITex("ui\\Image\\Common\\MainPanel_1.UITex", 1)
			hItem:Lookup("Image_BoxBgOver"):FromUITex("ui\\Image\\Common\\MainPanel_1.UITex", 2)
			hItem:Lookup("Image_BoxBgSel"):FromUITex("ui\\Image\\Common\\MainPanel_1.UITex", 3)			
		end
		
		local text = hItem:Lookup("Text_Name")
		text:SetText(Table_GetSkillName(dwID, dwLevel))
		if hItem.bLearned then
			text:SetFontScheme(163)
		else
			text:SetFontScheme(161)
		end
		
		local box = hItem:Lookup("Box_Skill")
		box.bLearned = hItem.bLearned
		box:SetObject(UI_OBJECT_SKILL, dwID, dwLevel)
		box:SetObjectIcon(Table_GetSkillIconID(dwID, dwLevel))
		box:EnableObject(box.bLearned)
	end
	hI:Update(dwID, dwLevel)
	
	hI.OnItemMouseEnter = function()
		this.bIn = true
		if not this.bSel then
			this:Lookup("Image_BoxBg"):Show()
			this:Lookup("Image_BoxBgOver"):Show()
		end
	end
	hI.OnItemMouseLeave = function()
		this.bIn = false
		if not this.bSel then
			this:Lookup("Image_BoxBg"):Show()
			this:Lookup("Image_BoxBgOver"):Hide()
		end
	end
	
	hI.Select = function(hI)
		if not hI.bSel then
			local hP = hI:GetParent()
			local nCount = hP:GetItemCount() - 1
			for i = 0, nCount, 1 do
				if hP:Lookup(i).bSel then
					local hLS = hP:Lookup(i)
					hLS.bSel = nil
					if hLS.bIn then
						hLS:Lookup("Image_BoxBgOver"):Show()
						hLS:Lookup("Image_BoxBg"):Hide()
					else
						hLS:Lookup("Image_BoxBgOver"):Hide()
						hLS:Lookup("Image_BoxBg"):Show()
					end
					hLS:Lookup("Image_BoxBgSel"):Hide()
					hLS:Lookup("Text_Type"):SetFontScheme(162)
					if hLS.bLearned then
						hLS:Lookup("Text_Name"):SetFontScheme(163)
					else
						hLS:Lookup("Text_Name"):SetFontScheme(161)
					end
					local box = hLS:Lookup("Box_Skill")
					box:SetSize(box.w, box.h)
					box:SetRelPos(box.x, box.y)
					hLS:FormatAllItemPos()
					break
				end
			end
			hI:Lookup("Image_BoxBg"):Hide()
			hI:Lookup("Image_BoxBgOver"):Hide()
			hI:Lookup("Image_BoxBgSel"):Show()
			hI:Lookup("Text_Type"):SetFontScheme(0)
			if hI.bLearned then
				hI:Lookup("Text_Name"):SetFontScheme(65)
			else
				hI:Lookup("Text_Name"):SetFontScheme(161)
			end
			
			local box = hI:Lookup("Box_Skill")
			box.w, box.h = box:GetSize()
			box.x, box.y = box:GetRelPos()
			box:SetSize(box.w + 8, box.h + 8)
			box:SetRelPos(box.x - 3, box.y - 5)
			hI:FormatAllItemPos()
			hI.bSel = true
			SkillPanel.UpdateScrollInfo(hP)
			SkillPanel.UpdateSkillInKungfu(hP:GetParent(), hI.dwID, hI.dwLevel)
		end
	end

	hI.OnItemLButtonDown = function()
		hI:Select()
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
	end
	
	local box = hI:Lookup("Box_Skill")
	box:Show()
	box.OnItemMouseEnter = function()
		local dwSkillID, dwLevel = this:GetObjectData()
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
		OutputSkillTip(dwSkillID, dwLevel, {x, y, w, h}, true, true, true, true)
		
		local thisSave = this
		this = thisSave:GetParent()
		this.OnItemMouseEnter()
		this = thisSave
	end
	box.OnItemRefreshTip = box.OnItemMouseEnter
	
	box.OnItemMouseLeave = function()
		HideTip()
		
		local thisSave = this
		this = thisSave:GetParent()
		this.OnItemMouseLeave()
		this = thisSave					
	end
	
	box.OnItemLButtonDown = function()
		if IsCtrlKeyDown() then
			local dwSkillID, dwLevel = this:GetObjectData()
			if IsGMPanelReceiveSkill() then
				GMPanel_LinkSkill(dwSkillID, dwLevel)
			else			
				EditBox_AppendLinkSkill(GetClientPlayer().GetSkillRecipeKey(dwSkillID, dwLevel))
			end
		else
			this:GetParent():Select()
			PlaySound(SOUND.UI_SOUND, g_sound.Button)
		end
		this:SetObjectStaring(false)
	end
	
	hI:Lookup("Image_BoxBg"):Show()
	if handle:GetParent().bNotSel then
		hI:Select()
		handle:GetParent().bNotSel = nil
	end
end

function SkillPanel.IsCommonSkill(dwID)
	if not IsCommonSkill(dwID) then
		return false, false, false
	end
	local player = GetClientPlayer()
	if dwID == player.GetCommonSkill(false) then
		return true, true, false
	elseif dwID == player.GetCommonSkill(true) then
		return true, true, true
	end
	return true, false, false
end

function SkillPanel.GetSkillList(dwKungfuID)
	local player = GetClientPlayer()
	local t = g_tTable.KungfuSkill:Search(dwKungfuID)
	local a = {}
	if t and t.szSkill then
		local szSkill = t.szSkill
		for s in string.gmatch(szSkill, "%d+") do
			local dwID = tonumber(s)
			if dwID then
				a[dwID] = player.GetSkillLevel(dwID) or 0
			end
		end
	end
	
	local aLearned = player.GetSkillList(dwKungfuID)
	if aLearned then
		for k, v in pairs(aLearned) do
			a[k] = v
		end
	end
	
	return a
end

function SkillPanel.UpdateSkillInKungfu(handle, dwKungfuID, dwKungfulevel, bClear)
	aSkillPanelData = {}
	if bClear then
		handle.dwKungfuID = nil
		handle:Lookup("Handle_Content"):Clear()
		handle:Lookup("Text_Describe"):SetText("")
		handle:Lookup("Text_TlName"):SetText("")
		return
	end
	
	handle.dwKungfuID = dwKungfuID
	local hList = handle:Lookup("Handle_Content")
	hList:Clear()
	local aSkill = SkillPanel.GetSkillList(dwKungfuID)
	for dwID, dwLevel in pairs(aSkill) do
		local dwShowlevel = dwLevel
		if dwLevel == 0 then
			dwShowlevel = 1
		end
		if Table_IsSkillShow(dwID, dwShowlevel) then
			local bCommon, bCurrent, bMelee = SkillPanel.IsCommonSkill(dwID)
			if not bCommon or bCurrent then
				SkillPanel.NewSkill(hList, dwID, dwLevel, bCommon, bMelee)
			end
		end
	end
	hList:Sort()
	hList:FormatAllItemPos()
	handle:Lookup("Text_Describe"):SetText(Table_GetSkillDesc(dwKungfuID, 10000))
	handle:Lookup("Text_TlName"):SetText(Table_GetSkillName(dwKungfuID, dwKungfulevel))
end

function SkillPanel.NewSkill(handle, dwID, dwLevel, bCommon, bMelee)
	handle:AppendItemFromIni("UI/Config/Default/SkillPanel.ini", "Handle_Skill", "")
	local hI = handle:Lookup(handle:GetItemCount() - 1)
	
	if bCommon then
		hI.bCommon = true
		if bMelee then
			hI.bMelee = true
		end
	end
	hI.Update = function(hItem, dwID, dwLevel)
		hItem.bLearned = dwLevel > 0
		if dwLevel == 0 then
			dwLevel = 1
		end	
		hItem.dwID = dwID
		hItem.dwLevel = dwLevel
		local plaer = GetClientPlayer()
		local textName = hItem:Lookup("Text_SkillName")
		textName:SetText(Table_GetSkillName(dwID, dwLevel))

		local textLv = hItem:Lookup("Text_SkillLv")
		if hItem.bLearned then
			if Table_IsSkillFormation(dwID, dwLevel) then
				textLv:SetText(g_tStrings.FORMATION_GAMBIT)
			else
				textLv:SetText(FormatString(g_tStrings.STR_SKILL_H_THE_WHAT_LEVEL, NumberToChinese(dwLevel)))
			end
			textName:SetFontScheme(163)
			textLv:SetFontScheme(162)
		else
			local t = g_tTable.OpenSkillLevel:Search(dwID)
			if t and t.dwLevel then
				if t.dwLevel > GetClientPlayer().nLevel then
					textName:SetFontScheme(161)
					textLv:SetFontScheme(161)
					textLv:SetText(FormatString(g_tStrings.OPEN_SKILL_LEVEL, t.dwLevel))
				else
					textName:SetFontScheme(165)
					textLv:SetFontScheme(165)
					textLv:SetText(g_tStrings.CAN_LEARN_SKILL_NOW)
				end
			else
				textName:SetFontScheme(163)
				textLv:SetFontScheme(162)
				textLv:SetText(FormatString(g_tStrings.STR_SKILL_H_THE_WHAT_LEVEL, NumberToChinese(1)))
			end
		end
		hItem:SetUserData(Table_GetSkillSortOrder(dwID, dwLevel))
		
		local skill = GetSkill(dwID, dwLevel)		
		if skill.dwLevelUpExp == 0 or dwLevel == skill.dwMaxLevel then
			hItem:Lookup("Image_SkillExp"):SetPercentage(0)
		else
			hItem:Lookup("Image_SkillExp"):SetPercentage(plaer.GetSkillExp(skill.dwSkillID) / skill.dwLevelUpExp)
		end
		
		local nCount = plaer.GetSkillRecipeKeyCount(dwID, dwLevel)
		for i = 1, 4 do
			if i <= nCount then
				hItem:Lookup("Image_Point0"..i):Show()
			else
				hItem:Lookup("Image_Point0"..i):Hide()
			end
		end
		
		if not skill.bIsPassiveSkill and not Table_IsSkillFormation(dwID, dwLevel) and hItem.bLearned and IsSkillNewLearned(hItem.dwID) then
			hItem:Lookup("Animate_Learn"):Show()
		else
			hItem:Lookup("Animate_Learn"):Hide()
		end
				
		local box = hItem:Lookup("Box_SkillIcon")
		box:SetObject(UI_OBJECT_SKILL, dwID, dwLevel)
		SetSkillPanelData(box)
		box:SetObjectIcon(Table_GetSkillIconID(dwID, dwLevel))
		box.bIsPassiveSkill = skill.bIsPassiveSkill
		box.bFormation = Table_IsSkillFormation(dwID, dwLevel)
		box.bLearned = hItem.bLearned
		box:EnableObject(box.bLearned)
		
		if skill.bIsPassiveSkill or box.bFormation then
			hItem:Lookup("Image_Mystique"):Hide()
			hItem:Lookup("Image_SkillIconBg"):Hide()
			hItem:Lookup("Image_SkillIconBg02"):Show()
			hItem:Lookup("Image_SkillIconBg03"):Hide()
			hItem:Lookup("Image_SkillExp"):Hide()
			box:SetIndex(0)
			box:SetRelPos(6, 6)
			textName:SetRelPos(62, 10)
			textLv:SetRelPos(62, 30)
			hItem:FormatAllItemPos()
		else
            tRecipeList = Table_GetRecipeList(dwID)
            if not tRecipeList or #tRecipeList < 1 then
                hItem:Lookup("Image_Mystique"):Hide()
            else
                hItem:Lookup("Image_Mystique"):Show()
            end
			hItem:Lookup("Image_SkillIconBg"):Show()
			hItem:Lookup("Image_SkillIconBg02"):Hide()
			hItem:Lookup("Image_SkillIconBg03"):Hide()
			hItem:Lookup("Image_SkillExp"):Show()
		end
		
		local tRecipe = plaer.GetSkillRecipeList(dwID, dwLevel)
		if tRecipe then
			hItem.nRecipeCount = #tRecipe
		end
		
		local imgMystique = hItem:Lookup("Image_Mystique")
		if hItem.nRecipeCount and hItem.nRecipeCount > 0 then
			imgMystique:SetFrame(45)
		else
			imgMystique:SetFrame(8)
		end
	end
	hI:Update(dwID, dwLevel)
	
	local box = hI:Lookup("Box_SkillIcon")
	box.OnItemMouseEnter = function()
		if not this.bIsPassiveSkill or not this.bFormation then
			this:SetObjectMouseOver(true)
		end
		local dwSkillID, dwLevel = this:GetObjectData()
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
		OutputSkillTip(dwSkillID, dwLevel, {x, y, w, h}, true, true, true, true)
	end	
	box.OnItemRefreshTip = box.OnItemMouseEnter
	
	box.OnItemMouseLeave = function()
		if not this.bIsPassiveSkill or not this.bFormation then
			this:SetObjectMouseOver(false)
		end
		HideTip()
	end
	
	box.OnItemLButtonDown = function()
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
		this:SetObjectStaring(false)
		this:SetObjectPressed(true)
	end
	box.OnItemLButtonUp = function()
		this:SetObjectPressed(false)
	end
	box.OnItemLButtonDrag = function()
		if Hand_IsEmpty() and IsCursorInExclusiveMode() then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.SRT_ERROR_CANCEL_CURSOR_STATE)
			PlayTipSound("010")
		else
			local dwSkillID, dwLevel = this:GetObjectData()
			local skill = GetSkill(dwSkillID, dwLevel)
			if skill.bIsPassiveSkill then
				OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_ERROR_SKILL_PASSIVE_SKILL)
				PlayTipSound("011")
			elseif this.bFormation then
				OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.FORMATION_CAN_NOT_DRG)
			elseif not this.bLearned then
				OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.SKILL_UNLEARNED_CAN_NOT_DRAG)
			else
				Hand_Pick(this)
			end
		end
	end
	
	box.OnItemRButtonDown = box.OnItemLButtonDown
	box.OnItemRButtonUp = box.OnItemLButtonUp
	
	local imgMystique = hI:Lookup("Image_Mystique")
	imgMystique.OnItemMouseEnter = function()
		this.bIn = true
		local hItem = this:GetParent()
		if hItem.nRecipeCount and hItem.nRecipeCount > 0 then
			this:SetFrame(46)
		else
			this:SetFrame(9)
		end
	end
	imgMystique.OnItemMouseLeave = function()
		this.bIn = false
		local hItem = this:GetParent()
		if hItem.nRecipeCount and hItem.nRecipeCount > 0 then
			this:SetFrame(45)
		else
			this:SetFrame(8)
		end
	end
	imgMystique.OnItemLButtonDown = function()
		local hItem = this:GetParent()
		if hItem.nRecipeCount and hItem.nRecipeCount > 0 then
			this:SetFrame(47)
		else
			this:SetFrame(10)
		end
	end
	imgMystique.OnItemLButtonUp = function()
		local hItem = this:GetParent()
		if this.bIn then
			if hItem.nRecipeCount and hItem.nRecipeCount > 0 then
				this:SetFrame(46)
			else
				this:SetFrame(9)
			end
		else
			if hItem.nRecipeCount and hItem.nRecipeCount > 0 then
				this:SetFrame(45)
			else
				this:SetFrame(8)
			end
		end
	end
	imgMystique.OnItemLButtonClick = function()
		local hP = this:GetParent()
		OpenOrCloseMystiquePanel(hP.dwID, hP.dwLevel)
	end
	
	local imgExp = hI:Lookup("Image_SkillExp")
	imgExp.OnItemMouseEnter = function()
		local hP = this:GetParent()
		local skill = GetSkill(hP.dwID, hP.dwLevel)
		local nExp = GetClientPlayer().GetSkillExp(skill.dwSkillID)
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
		local szTip = ""
		if skill.dwLevelUpExp ~= 0 and hP.dwLevel ~= skill.dwMaxLevel then
			szTip = "<text>text="..EncodeComponentsString(FormatString(g_tStrings.SKILL_EXP, nExp, skill.dwLevelUpExp, 
				string.format("%.2f", 100 * nExp / skill.dwLevelUpExp).."%")).."</text>"
			OutputTip(szTip, 400, {x, y, w, h})
		end
	end
	imgExp.OnItemMouseLeave = function()
		HideTip()
	end
end

function SkillPanel.OnItemLButtonClick()
	if this.bIgnoreClick or this.bFormation then
		this.bIgnoreClick = false
		return
	end
	local t = aSkillPanelData[this]
	if t then
		OnUseSkill(t[2], t[3], this)	
	end
end

function SkillPanel.OnItemRButtonClick()
	local t = aSkillPanelData[this]
	if t then
		OnUseSkill(t[2], t[3], this)	
	end
end

function SkillPanel.ForgetSkill(frame, dwID, dwLevel)
	dwLevel = 1
	local skill = GetSkill(dwID, dwLevel)
	local check = nil
	for i = 0, 10, 1 do
		local checkSchool = frame:Lookup("CheckBox_M"..i)
		if checkSchool:IsVisible() and checkSchool.dwSchoolID == skill.dwBelongSchool then
			check = checkSchool
			break
		end
	end
	if not check then
		return
	end
	local aKungfu = GetClientPlayer().GetKungfuList(skill.dwBelongSchool) or {}
	local bEmpty = true
	for v, k in pairs(aKungfu) do
		bEmpty = false
		break
	end
	
	if bEmpty then
		frame.dwSchoolID = nil
		SkillPanel.UpdateSchoolInfo(frame)
		return
	end
	if check:IsCheckBoxChecked() then
		if skill.dwBelongKungfu == 0 then
			local handle = frame:Lookup("Wnd_Content", "Handle_List")
			local nCount = handle:GetItemCount() - 1
			for i = 0, nCount, 1 do
				local hI = handle:Lookup(i)
				if hI.dwID == dwID then
					handle:RemoveItem(i)
					break
				end
			end
			if handle:GetItemCount() == 0 then
				frame.dwSchoolID = nil
				SkillPanel.UpdateSchoolInfo(frame)
			else
				if handle:GetParent().dwKungfuID == dwID then
					handle:Lookup(0):Select()
				end
				SkillPanel.UpdateScrollInfo(handle)
			end
		else
			local handle = frame:Lookup("Wnd_Content", "Handle_Content")
			if skill.dwBelongKungfu == handle:GetParent().dwKungfuID then
				local nCount = handle:GetItemCount() - 1
				for i = 0, nCount, 1 do
					local hI = handle:Lookup(i)
					if hI.dwID == dwID then
						handle:RemoveItem(i)
						handle:FormatAllItemPos()
						break
					end
				end
			end
		end
	end	
end

function SkillPanel.OnPlayerLevelUp(frame)
	local plaer = GetClientPlayer()
	local handle = frame:Lookup("Wnd_Content", "Handle_List")
	local nCount = handle:GetItemCount() - 1
	for i = 0, nCount, 1 do
		local hI = handle:Lookup(i)
		hI:Update(hI.dwID, plaer.GetSkillLevel(hI.dwID) or 0)
	end
	
	handle = frame:Lookup("Wnd_Content", "Handle_Content")
	local nCount = handle:GetItemCount() - 1
	for i = 0, nCount, 1 do
		local hI = handle:Lookup(i)
		hI:Update(hI.dwID, plaer.GetSkillLevel(hI.dwID) or 0)
	end	
	
end

function SkillPanel.UpdateSkill(frame, dwID, dwLevel)
	local dwShowLevel = dwLevel
	if dwLevel == 0 then
		dwShowLevel = 1
	end
	if not Table_IsSkillShow(dwID, dwShowLevel) then
		return
	end
	local skill = GetSkill(dwID, dwLevel)
	local check = nil
	for i = 0, 10, 1 do
		local checkSchool = frame:Lookup("CheckBox_M"..i)
		if checkSchool:IsVisible() and checkSchool.dwSchoolID == skill.dwBelongSchool then
			check = checkSchool
			break
		end
	end
	
	if not check then
		SkillPanel.UpdateSchoolInfo(frame)
		for i = 0, 10, 1 do
			local checkSchool = frame:Lookup("CheckBox_M"..i)
			if checkSchool:IsVisible() and checkSchool.dwSchoolID == skill.dwBelongSchool then
				check = checkSchool
				break
			end
		end
	end
	
	if check and check:IsCheckBoxChecked() then
		if skill.dwBelongKungfu == 0 then
			local handle = frame:Lookup("Wnd_Content", "Handle_List")
			local nCount = handle:GetItemCount() - 1
			for i = 0, nCount, 1 do
				local hI = handle:Lookup(i)
				if hI.dwID == dwID then
					hI:Update(dwID, dwLevel)
					return
				end
			end
			if not handle:GetParent().dwKungfuID then
				handle:GetParent().bNotSel = true
			end
			SkillPanel.NewKungfu(handle, dwID, dwLevel)
			SkillPanel.UpdateScrollInfo(handle)
		else
			local hTotal = frame:Lookup("Wnd_Content", "")
			local bCommon, bCurrent, bMelee = SkillPanel.IsCommonSkill(dwID)
			if bCommon and not bCurrent then
				return
			end
			local dwCurrent = hTotal.dwKungfuID
			if dwCurrent and dwCurrent == skill.dwBelongKungfu then
				local handle = hTotal:Lookup("Handle_Content")
				local nCount = handle:GetItemCount() - 1
				for i = 0, nCount, 1 do
					local hI = handle:Lookup(i)
					if hI.dwID == dwID then 
						hI:Update(dwID, dwLevel)
						return
					elseif hI.bCommon and bCommon then
						if bMelee then
							if hI.bMelee then
								hI:Update(dwID, dwLevel)
								return							
							end
						else
							if not hI.bMelee then
								hI:Update(dwID, dwLevel)
								return						
							end		
						end
					end
				end
				SkillPanel.NewSkill(handle, dwID, dwLevel, bCommon, bMelee)
				handle:Sort()
				handle:FormatAllItemPos()
			end
		end
	end		
end

function SkillPanel.OnEvent(event)
	if event == "SKILL_UPDATE" then
		if arg1 > 1 then
			SkillPanel.UpdateSkill(this, arg0, arg1)
		elseif arg1 == 1 then
			SkillPanel.UpdateSkill(this, arg0, arg1)
		else
			SkillPanel.ForgetSkill(this, arg0, arg1)
		end
	elseif event == "SKILL_EXP_UPDATE" then
		SkillPanel.UpdateSkill(this, arg0, arg1)
	elseif event == "SKILL_MOUNT_KUNG_FU" then
		SkillPanel.UpdateSkill(this, arg0, arg1)
	elseif event == "SKILL_UNMOUNT_KUNG_FU" then
		SkillPanel.UpdateSkill(this, arg0, arg1)
	elseif event == "EQUIP_ITEM_UPDATE"then
		if arg1 == EQUIPMENT_INVENTORY.MELEE_WEAPON then
			local player = GetClientPlayer()
			local dwSkillID = player.GetCommonSkill(true)
			if dwSkillID ~= 0 then
				SkillPanel.UpdateSkill(this, dwSkillID, 1)
			end
		elseif arg1 == EQUIPMENT_INVENTORY.RANGE_WEAPON then
			local player = GetClientPlayer()
			local dwSkillID = player.GetCommonSkill(false)
			if dwSkillID ~= 0 then
				SkillPanel.UpdateSkill(this, dwSkillID, 1)
			end
		end
	elseif event == "SWITCH_BIGSWORD" then
		local player = GetClientPlayer()
		local dwSkillID = player.GetCommonSkill(true)
		if dwSkillID ~= 0 then
			SkillPanel.UpdateSkill(this, dwSkillID, 1)
		end
	elseif event == "SYNC_ROLE_DATA_END" then
		SkillPanel.UpdateSchoolInfo(this)
	elseif event == "ADD_SKILL_RECIPE" then
		local dwSkillID, nLevel = GetSkillByRecipe(arg0, arg1)
		if dwSkillID and nLevel then
			SkillPanel.UpdateSkill(this, dwSkillID, nLevel)
		end
	elseif event == "PLAYER_LEVEL_UPDATE" then
		if arg0 == GetClientPlayer().dwID then
			SkillPanel.OnPlayerLevelUp(this)
		end
	elseif event == "MYSTIQUE_ACTIVE_UPDATE" then
		SkillPanel.UpdateMytiqueActive(this, arg0, arg1)
	end
end

function SkillPanel.OnLButtonClick()
    if this:GetName() == "Btn_Close" then
    	CloseSkillPanel()
    end
end

function SkillPanel.OnLButtonDown()
	SkillPanel.OnLButtonHold()
end

function SkillPanel.OnLButtonHold()
	local szName = this:GetName()
	if szName == "Btn_Up" then
		this:GetParent():Lookup("Scroll_List"):ScrollPrev(1)
	elseif szName == "Btn_Down" then
		this:GetParent():Lookup("Scroll_List"):ScrollNext(1)	
    end
end

function SkillPanel.OnItemMouseWheel()
	local nDistance = Station.GetMessageWheelDelta()
	this:GetParent():Lookup("Scroll_List"):ScrollNext(nDistance)
	return 1
end

function SkillPanel.OnFrameBreathe()	
	local player = GetClientPlayer()
	if not player then
		return
	end
	local handle = this:Lookup("Wnd_Content", "")	
	
	local hList = handle:Lookup("Handle_Content")
	nCount = hList:GetItemCount() - 1

	for i = 0, nCount, 1 do
		local box = hList:Lookup(i):Lookup("Box_SkillIcon")
		if box.bLearned then
			UpdataSkillCDProgress(player, box)
		end
	end
	
end

---------------------插件重新实现方法:--------------------------------
--2, SkillPanel = nil
--2, 重载下面函数
----------------------------------------------------------------------
function OpenSkillPanel(bDisableSound)
	if IsOptionOrOptionChildPanelOpened() then
		return
	end

	if IsSkillPanelOpened() then
		return
	end
	local frame = Wnd.OpenWindow("SkillPanel")
	frame:Show()
	FireHelpEvent("OnOpenpanel", "SKILL")
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
	
	FireEvent("OPEN_SKILL_PANEL")
end

function CloseSkillPanel(bDisableSound)
	if not IsSkillPanelOpened() then
		return
	end
	local frame = Station.Lookup("Normal/SkillPanel")
	frame:Hide()
	--Wnd.CloseWindow("SkillPanel")
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end
	FireEvent("CLOSE_SKILL_PANEL")
end

function IsSkillPanelOpened()
	local frame = Station.Lookup("Normal/SkillPanel")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end
