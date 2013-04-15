local INI_PATH =  "ui/Config/Default/PetActionBar.ini"
local PET_NORMAT_SKILL_COUNT = 6
local PET_ACTION_BAR_BG_MORE_SIZE = 200
local PET_ACTION_BOX_SIZE = 45
local function fnGroup1(tGroup, nIndex)
	local hAnimate = nil
	for nSkillIndex in pairs(tGroup.tSkill) do
		local hAnimate = GetPetActionBarSkillAnimate(nSkillIndex)
		if hAnimate then
			hAnimate:Hide()
		end
	end
	tGroup.GroupState = nIndex
	local hAnimate = GetPetActionBarSkillAnimate(nIndex)
	if hAnimate then
		hAnimate:Show()
	end
end

local function fnGroup2(tGroup, nIndex)
	local hAnimate = nil
	
	local bState = tGroup.GroupState
	if type(nIndex) == "boolean" then
		bState = nIndex
	end
	for nSkillIndex in pairs(tGroup.tSkill) do
		local hAnimate = GetPetActionBarSkillAnimate(nSkillIndex)
		nIndex = nSkillIndex
		if hAnimate then
			hAnimate:Hide()
		end
	end
	if bState then
		bState = false
	else
		bState = true
	end
	
	tGroup.GroupState = bState
	if bState then
		local hAnimate = GetPetActionBarSkillAnimate(nIndex)
		if hAnimate then
			hAnimate:Show()
		end
	end
end

local tPetSkillGroups = 
{
	{tSkill = {[2] = 2, [3] = 3}, GroupState = 2, DefaultState = 2, fnAction = fnGroup1},
	{tSkill = {[4] = 4, [5] = 5, [6] = 6}, GroupState = 5, DefaultState = 5, fnAction = fnGroup1},
	{tSkill = {[7] = 7}, GroupState = false, DefaultState = false, fnAction = fnGroup2},
}

PetActionBar = {}

PetActionBar.tAnchor = {s = "BOTTOMCENTER", r = "BOTTOMCENTER", x = -200, y = -212}
RegisterCustomData("PetActionBar.tAnchor")


function PetActionBar.OnFrameCreate()
	this:RegisterEvent("HOT_KEY_RELOADED")
	this:RegisterEvent("UI_SCALED")
	this:RegisterEvent("REMOVE_PET_TEMPLATEID")
	this:RegisterEvent("PLAYER_ENTER_SCENE")
	
	PetActionBar.OnEvent("UI_SCALED")
end

function PetActionBar.OnEvent(szEvent)
	if szEvent == "HOT_KEY_RELOADED" then
		PetActionBar.UpdateHotkey(this, this.nCount)
	elseif szEvent == "UI_SCALED" then
		PetActionBar.UpdateAnchor(this)
	elseif szEvent == "REMOVE_PET_TEMPLATEID" then
		ClosePetActionBar()
	elseif szEvent == "PLAYER_ENTER_SCENE" then
		local hPlayer = GetClientPlayer()
		if hPlayer and hPlayer.dwID == arg0 then
			ClosePetActionBar()
		end
	end
end

function PetActionBar.UpdateAnchor(hFrame)
	local tAnchor = PetActionBar.tAnchor
	hFrame:SetPoint(tAnchor.s, 0, 0, tAnchor.r, tAnchor.x, tAnchor.y)
	hFrame:CorrectPos()
end

function PetActionBar.OnFrameDragEnd()
	PetActionBar.tAnchor = GetFrameAnchor(this)
	PetActionBar.UpdateAnchor(this)
end

function PetActionBar.OnFrameBreathe()
	local hPlayer = GetClientPlayer()
	if not hPlayer then
		return 
	end
	
	if not this.nCount then
		return
	end
	
	local hTotalHandle = this:Lookup("", "")
	local hBox = hTotalHandle:Lookup("Handle_Box/Handle_SkillMod")
	
	for i = 1, this.nCount do
		local nKey, bShift, bCtrl, bAlt = Hotkey.Get("ACTIONBAR5_BUTTON"..i)
		local hSkillBox = nil
		if i <= PET_NORMAT_SKILL_COUNT then
			hSkillBox = hBox:Lookup("Box_Skills" .. i)
		else 
			local hSkill = hBox:Lookup("Handle_OtherSkill/Handle_SkillBox" .. i)
			hSkillBox = hSkill:Lookup("Box_Skill")
		end
		
		if hSkillBox then
			UpdataSkillCDProgress(hPlayer, hSkillBox)
		end
	end
end

function PetActionBar.OnItemLButtonDown()
	if not this.bSkillBox then
		return
	end
	
	if IsCtrlKeyDown() then
		local nSkillID, nLevel = this:GetObjectData()
		if IsGMPanelReceiveSkill() then
			GMPanel_LinkSkill(nSkillID, nLevel)
		else
			EditBox_AppendLinkSkill(GetClientPlayer().GetSkillRecipeKey(nSkillID, nLevel))
		end
	end
	
	this:SetObjectStaring(false)
	this:SetObjectPressed(1)
end

function PetActionBar.OnItemLButtonUp()
	if not this.bSkillBox then
		return
	end
	
	this:SetObjectPressed(0)
end

function PetActionBar.OnItemLButtonClick()
	if not this.bSkillBox then
		return
	end
	PetActionBar.OnUseActionBarObject(this)
end

function PetActionBar.OnItemLButtonDBClick()
	PetActionBar.OnItemLButtonClick()
end

function PetActionBar.OnItemRButtonDown()
	if not this.bSkillBox then
		return
	end
	
	this:SetObjectPressed(1)
end

function PetActionBar.OnItemRButtonUp()
	if not this.bSkillBox then
		return
	end
	this:SetObjectPressed(0)
end

function PetActionBar.OnItemRButtonClick()
	if not this.bSkillBox then
		return
	end
	
	PetActionBar.OnUseActionBarObject(this)
end

function PetActionBar.OnItemRButtonDBClick()
	PetActionBar.OnItemRButtonClick()
end

function PetActionBar.OnUseActionBarObject(hBox)
	local nSkillID, nLevel = hBox:GetObjectData()
	hBox.bPetActionBar = true
	OnUseSkill(nSkillID, nLevel, hBox)
end

function PetActionBar_UpdateBoxState(hBox)
	if not hBox or not hBox.nIndex then
		return
	end
	
	local nIndex = hBox.nIndex
	for _, tGroup in ipairs(tPetSkillGroups) do
		if tGroup.tSkill[nIndex] then
			tGroup.fnAction(tGroup, nIndex)
		end
	end
end

function PetActionBar.OnItemMouseEnter()
	if not this.bSkillBox then
		return
	end
	
	this:SetObjectMouseOver(1)
	local x, y = this:GetAbsPos()
	local w, h = this:GetSize()
	local nSkilID, nLevel = this:GetObjectData()
	OutputSkillTip(nSkilID, nLevel, {x, y, w, h, 1}, false)
end

function PetActionBar.OnItemMouseLeave()
	if not this.bSkillBox then
		return
	end
	
	this:SetObjectMouseOver(0)
	HideTip()
end

function PetActionBar.Update(hFrame, tSkill)
	local nCount = #tSkill
	hFrame.nCount = nCount
	PetActionBar.Init(hFrame, nCount)
	local hTotalHandle = hFrame:Lookup("", "")
	local hBox = hTotalHandle:Lookup("Handle_Box/Handle_SkillMod")
	for nIndex, tSkillData in ipairs(tSkill) do
		local nSkillID = tSkillData[1]
		local nLevel = tSkillData[2]
		
		local hSkillBox = nil
		if nIndex <= PET_NORMAT_SKILL_COUNT then
			hSkillBox = hBox:Lookup("Box_Skills" .. nIndex)
		else
			local hSkill = hBox:Lookup("Handle_OtherSkill/Handle_SkillBox" .. nIndex)
			hSkillBox = hSkill:Lookup("Box_Skill")
		end
		
		if nSkillID and nSkillID ~= 0 and hSkillBox then
			hSkillBox:SetObject(UI_OBJECT_SKILL, nSkillID, nLevel)
			hSkillBox:SetObjectIcon(Table_GetSkillIconID(nSkillID, nLevel))
			hSkillBox.bSkillBox = true
			hSkillBox.nIndex = nIndex
		end
	end
	
	for _, tGroup in ipairs(tPetSkillGroups) do
		tGroup.fnAction(tGroup, tGroup.DefaultState)
	end
end

function PetActionBar.Init(hFrame, nCount)
	local hTotalHandle = hFrame:Lookup("", "")
	local hBox = hTotalHandle:Lookup("Handle_Box/Handle_SkillMod")
	
	local hOtherHandle = hBox:Lookup("Handle_OtherSkill")
	hOtherHandle:Clear()
	for i = PET_NORMAT_SKILL_COUNT + 1, nCount do
		hOtherHandle:AppendItemFromIni(INI_PATH, "Handle_Mod", "Handle_SkillBox" .. i)
	end
	local _, fOhterHeight = hOtherHandle:GetSize()
	local fOtherWidth = (nCount - PET_NORMAT_SKILL_COUNT) * PET_ACTION_BOX_SIZE
	hOtherHandle:SetSize(fOtherWidth, fOhterHeight)
	hOtherHandle:FormatAllItemPos()
	local hBg = hTotalHandle:Lookup("Handle_Bg/Image_Background")
	local _, fBgHeight = hBg:GetSize()
	local fBgWidth = PET_ACTION_BOX_SIZE * (nCount + 2)
	hBg:SetSize(fBgWidth, fBgHeight)
	local _, fWindowHeight = hFrame:GetSize()
	--hFrame:SetSize(fBgWidth, fWindowHeight)
	PetActionBar.UpdateHotkey(hFrame, nCount)
	PetActionBar.UpdateAnchor(hFrame)
	
end

function PetActionBar.UpdateHotkey(hFrame, nCount)
	local hTotalHandle = hFrame:Lookup("", "")
	local hBox = hTotalHandle:Lookup("Handle_Box/Handle_SkillMod")
	
	for i = 1, nCount do
		local nKey, bShift, bCtrl, bAlt = Hotkey.Get("ACTIONBAR5_BUTTON"..i)
		local hText = nil
		if i <= PET_NORMAT_SKILL_COUNT then
			hText = hBox:Lookup("Text_Skills" .. i)
		else 
			local hSkill = hBox:Lookup("Handle_OtherSkill/Handle_SkillBox" .. i)
			hText = hSkill:Lookup("Text_Skill")
		end
		if hText then
			hText:SetText(GetKeyShow(nKey, bShift, bCtrl, bAlt, true))
		end
	end
end

function OpenPetActionBar(dwNpcTemplateID, bDisableSound)
	if not dwNpcTemplateID then
		return
	end
	
	local tSkill = Table_GetPetSkill(dwNpcTemplateID)
	if not tSkill then
		return
	end
	
	if not IsPetActionBarOpened() then
		Wnd.OpenWindow("PetActionBar")
	end
	local hFrame = Station.Lookup("Normal/PetActionBar")
	hFrame.dwNpcTemplateID = dwNpcTemplateID
	
	PetActionBar.Update(hFrame, tSkill)
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND, g_sound.OpenFrame)
	end
end

function IsPetActionBarOpened()
	local hFrame = Station.Lookup("Normal/PetActionBar")
	if hFrame then
		return true
	end
	
	return false
end

function ClosePetActionBar()
	if not IsPetActionBarOpened() then
		return
	end
	Wnd.CloseWindow("PetActionBar")
	
	FireEvent("REMOVE_PET_TEMPLATEID")
end

function GetPetActionBarBox(nIndex)
	local hFrame = Station.Lookup("Normal/PetActionBar")
	local hTotalHandle = hFrame:Lookup("", "")
	local hBox = hTotalHandle:Lookup("Handle_Box/Handle_SkillMod")
	local hSkillBox = nil
	if nIndex <= PET_NORMAT_SKILL_COUNT then
		hSkillBox = hBox:Lookup("Box_Skills" .. nIndex)
	else
		local hSkillHandle = hBox:Lookup("Handle_OtherSkill/Handle_SkillBox" .. nIndex)
		hSkillBox =  hSkillHandle:Lookup("Box_Skill")
	end
	
	return hSkillBox
end

function GetPetActionBarSkillAnimate(nIndex)
	local hFrame = Station.Lookup("Normal/PetActionBar")
	if nIndex > hFrame.nCount then
		return
	end
	
	local hTotalHandle = hFrame:Lookup("", "")
	local hBox = hTotalHandle:Lookup("Handle_Box/Handle_SkillMod")
	local hAnimate = nil
	if nIndex <= PET_NORMAT_SKILL_COUNT then
		hAnimate = hBox:Lookup("Animate_Skills" .. nIndex)
	else
		local hSkillHandle = hBox:Lookup("Handle_OtherSkill/Handle_SkillBox" .. nIndex)
		if hSkillHandle then
			hAnimate =  hSkillHandle:Lookup("Animate_Skill")
		end
	end
	
	return hAnimate
end


