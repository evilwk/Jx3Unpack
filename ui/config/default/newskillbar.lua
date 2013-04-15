NewSkillBar = {nCount = 0}

function NewSkillBar.OnFrameCreate()
	this:RegisterEvent("UI_SCALED")
	this:RegisterEvent("SKILL_UPDATE")
	this:Lookup("", ""):Clear()
	NewSkillBar.OnEvent("UI_SCALED")
end

function NewSkillBar.OnEvent(event)
	if event == "UI_SCALED" then
		this:SetPoint("CENTER", 0,0, "CENTER", 0, 0)
	elseif event == "SKILL_UPDATE" then
		local handle = this:Lookup("", "")
		local nCount = handle:GetItemCount() - 1
		for i = 0, nCount, 1 do
			local box = handle:Lookup(i)
			local _, dwID, dwLevel = box:GetObject()
			if dwID == arg0 then
				if arg1 == 0 then
					box:Hide()
					NewSkillBar.nCount = NewSkillBar.nCount - 1
					if NewSkillBar.nCount <= 0 then
						Wnd.CloseWindow("NewSkillBar")
						NewSkillBar.nCount = 0
					end
				else
					box:SetObject(UI_OBJECT_SKILL, arg0, arg1)
					box:SetObjectStaring(true)
					box:SetObjectIcon(Table_GetSkillIconID(arg0, arg1))
				end
				break
			end
		end 
	end
end

function NewSkillBar.OnItemMouseEnter()
	this:SetObjectMouseOver(true)
	local dwSkillID, dwLevel = this:GetObjectData()
	local x, y = this:GetAbsPos()
	local w, h = this:GetSize()
	OutputSkillTip(dwSkillID, dwLevel, {x, y, w, h}, true)
end

function NewSkillBar.OnItemMouseLeave()
	this:SetObjectMouseOver(false)
	HideTip()
end

function NewSkillBar.OnItemLButtonDown()
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
end	

function NewSkillBar.OnItemLButtonUp()
	this:SetObjectPressed(false)
end

function NewSkillBar.OnItemLButtonClick()
	if this.bIgnoreClick then
		this.bIgnoreClick = false
		return
	end
--	local dwSkillID, dwLevel = this:GetObjectData()
--	OnUseSkill(dwSkillID, dwLevel, this)	
	NewSkillBar.OnItemLButtonDrag()
end

function NewSkillBar.OnItemLButtonDrag()
	if Hand_IsEmpty() and IsCursorInExclusiveMode() then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.SRT_ERROR_CANCEL_CURSOR_STATE)
		PlayTipSound("010")
	else
		Hand_Pick(this)
		this:Hide()
		NewSkillBar.nCount = NewSkillBar.nCount - 1
		if NewSkillBar.nCount <= 0 then
			Wnd.CloseWindow("NewSkillBar")
			NewSkillBar.nCount = 0
		end
	end
end

function NewSkillBar.OnItemRButtonDown()
	this:SetObjectPressed(true)
end

function NewSkillBar.OnItemRButtonUp()
	this:SetObjectPressed(false)
end

function NewSkillBar.OnItemRButtonClick()
--	local dwSkillID, dwLevel = this:GetObjectData()
--	OnUseSkill(dwSkillID, dwLevel, this)
end

local aNewSkill = {}
function NewSkillBarOnNewSkill(dwID, dwLevel)
	aNewSkill[dwID] = true
	local skill = GetSkill(dwID, dwLevel)
	if skill.bIsPassiveSkill then
		return
	end
	if skill.dwBelongKungfu == 0 then
		return
	end
	
	if Table_IsSkillFormation(dwID, dwLevel) then
		return
	end
	
	local frame = Wnd.OpenWindow("NewSkillBar")
	frame:Show()
	local handle = frame:Lookup("", "")
	local nIndex = handle:GetItemCount()
	handle:AppendItemFromIni("UI/Config/Default/NewSkillBar.ini", "Box_Skill", "")
	local box = handle:Lookup(nIndex)
	box:SetObject(UI_OBJECT_SKILL, dwID, dwLevel)
	box:SetObjectIcon(Table_GetSkillIconID(dwID, dwLevel))
	box:Show()
	NewSkillBar.nCount = NewSkillBar.nCount + 1
	box:SetObjectStaring(true)
	box:SetRelPos((nIndex % 5) * (48 + 2), math.floor(nIndex / 5) * (48 + 2))
	handle:FormatAllItemPos()
	
	FireHelpEvent("OnCommentDragSkill", dwID, box)
end

function IsSkillNewLearned(dwID)
	if aNewSkill[dwID] then
		return true
	end
	return false
end