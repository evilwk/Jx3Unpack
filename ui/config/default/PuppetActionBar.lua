local INI_PATH =  "ui/Config/Default/PuppetActionBar.ini"
local PUPPET_ACTION_BOX_SIZE = 45
local PUPPET_ACTION_BOX_INTERVAL = 0
local PUPPET_ACTION_BOX_GROUP_INTERVAL = 12

PuppetActionBar = {}

PuppetActionBar.tAnchor = {s = "BOTTOMCENTER", r = "BOTTOMCENTER", x = -200, y = -212}
RegisterCustomData("PuppetActionBar.tAnchor")

function PuppetActionBar.OnFrameCreate()
	this:RegisterEvent("HOT_KEY_RELOADED")
	this:RegisterEvent("UI_SCALED")
	this:RegisterEvent("REMOVE_PUPPET_TEMPLATEID")
	this:RegisterEvent("PLAYER_ENTER_SCENE")
	
	PuppetActionBar.OnEvent("UI_SCALED")
end

function PuppetActionBar.OnEvent(szEvent)
	if szEvent == "HOT_KEY_RELOADED" then
		PuppetActionBar.UpdateHotkey(this, this.nCount)
	elseif szEvent == "UI_SCALED" then
		PuppetActionBar.UpdateAnchor(this)
	elseif szEvent == "REMOVE_PUPPET_TEMPLATEID" then
		ClosePuppetActionBar()
	elseif szEvent == "PLAYER_ENTER_SCENE" then ---ÊÇ·ñÐèÒª
		local hPlayer = GetClientPlayer()
		if hPlayer and hPlayer.dwID == arg0 then
			ClosePuppetActionBar()
		end
	end
end

function PuppetActionBar.UpdateAnchor(hFrame)
	local tAnchor = PuppetActionBar.tAnchor
	hFrame:SetPoint(tAnchor.s, 0, 0, tAnchor.r, tAnchor.x, tAnchor.y)
	hFrame:CorrectPos()
end

function PuppetActionBar.OnFrameDragEnd()
	PuppetActionBar.tAnchor = GetFrameAnchor(this)
	PuppetActionBar.UpdateAnchor(this)
end

function PuppetActionBar.OnFrameBreathe()
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
		local nKey, bShift, bCtrl, bAlt = Hotkey.Get("ACTIONBAR6_BUTTON"..i)
        local hSkill = hBox:Lookup("Handle_SkillBox" .. i)
        hSkillBox = hSkill:Lookup("Box_Skill")
		
		if hSkillBox then
			UpdataSkillCDProgress(hPlayer, hSkillBox)
		end
	end
end

function PuppetActionBar.OnItemLButtonDown()
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

function PuppetActionBar.OnItemLButtonUp()
	if not this.bSkillBox then
		return
	end
	
	this:SetObjectPressed(0)
end

function PuppetActionBar.OnItemLButtonClick()
	if not this.bSkillBox then
		return
	end
	PuppetActionBar.OnUseActionBarObject(this)
end

function PuppetActionBar.OnItemLButtonDBClick()
	PuppetActionBar.OnItemLButtonClick()
end

function PuppetActionBar.OnItemRButtonDown()
	if not this.bSkillBox then
		return
	end
	
	this:SetObjectPressed(1)
end

function PuppetActionBar.OnItemRButtonUp()
	if not this.bSkillBox then
		return
	end
	this:SetObjectPressed(0)
end

function PuppetActionBar.OnItemRButtonClick()
	if not this.bSkillBox then
		return
	end
	
	PuppetActionBar.OnUseActionBarObject(this)
end

function PuppetActionBar.OnItemRButtonDBClick()
	PuppetActionBar.OnItemRButtonClick()
end

function PuppetActionBar.OnUseActionBarObject(hBox)
	local nSkillID, nLevel = hBox:GetObjectData()
	hBox.bPuppetActionBar = true
	OnUseSkill(nSkillID, nLevel, hBox)
end

function PuppetActionBar.OnItemMouseEnter()
	if not this.bSkillBox then
		return
	end
	
	this:SetObjectMouseOver(1)
	local x, y = this:GetAbsPos()
	local w, h = this:GetSize()
	local nSkilID, nLevel = this:GetObjectData()
	OutputSkillTip(nSkilID, nLevel, {x, y, w, h, 1}, false)
end

function PuppetActionBar.OnItemMouseLeave()
	if not this.bSkillBox then
		return
	end
	
	this:SetObjectMouseOver(0)
	HideTip()
end

function PuppetActionBar.Update(hFrame, tSkill, tGroup)
	local nCount = #tSkill
	hFrame.nCount = nCount
	PuppetActionBar.Init(hFrame, nCount, tGroup)
	local hTotalHandle = hFrame:Lookup("", "")
	local hBox = hTotalHandle:Lookup("Handle_Box/Handle_SkillMod")
	for nIndex, tSkillData in ipairs(tSkill) do
		local nSkillID = tSkillData[1]
		local nLevel = tSkillData[2]
		
        local hSkill = hBox:Lookup("Handle_SkillBox" .. nIndex)
        hSkillBox = hSkill:Lookup("Box_Skill")
		
		if nSkillID and nSkillID ~= 0 and hSkillBox then
			hSkillBox:SetObject(UI_OBJECT_SKILL, nSkillID, nLevel)
			hSkillBox:SetObjectIcon(Table_GetSkillIconID(nSkillID, nLevel))
			hSkillBox.bSkillBox = true
			hSkillBox.nIndex = nIndex
		end
	end
end

function PuppetActionBar.Init(hFrame, nCount, tGroup)
	local hTotalHandle = hFrame:Lookup("", "")
	local hSkillHandle = hTotalHandle:Lookup("Handle_Box/Handle_SkillMod")
	hSkillHandle:Clear()
    
    local nIndex = 1
    local nSize = 0
    for _, nGroupCount in ipairs(tGroup) do
        for i = 1, nGroupCount do
            local hSkill = hSkillHandle:AppendItemFromIni(INI_PATH, "Handle_Mod", "Handle_SkillBox" .. nIndex)
            hSkill:SetRelPos(nSize, 0)
            local fWidth = hSkill:GetSize()
            nSize = nSize + fWidth
            nIndex = nIndex + 1
        end
        nSize = nSize + PUPPET_ACTION_BOX_GROUP_INTERVAL
    end
    hSkillHandle:FormatAllItemPos()
    local _, fSkillHeight = hSkillHandle:GetSize()
    local fSkillWidth = PUPPET_ACTION_BOX_SIZE * nCount
    hSkillHandle:SetSize(fSkillWidth, fSkillHeight)
	local hBg = hTotalHandle:Lookup("Handle_Bg/Image_Background")
	local _, fBgHeight = hBg:GetSize()
	local fBgWidth = PUPPET_ACTION_BOX_SIZE * (nCount + 2)
	hBg:SetSize(fBgWidth, fBgHeight)
	PuppetActionBar.UpdateHotkey(hFrame, nCount)
	PuppetActionBar.UpdateAnchor(hFrame)
end

function PuppetActionBar.UpdateHotkey(hFrame, nCount)
	local hTotalHandle = hFrame:Lookup("", "")
	local hBox = hTotalHandle:Lookup("Handle_Box/Handle_SkillMod")
	for i = 1, nCount do
		local nKey, bShift, bCtrl, bAlt = Hotkey.Get("ACTIONBAR6_BUTTON"..i)
        local hSkill = hBox:Lookup("Handle_SkillBox" .. i)
        hText = hSkill:Lookup("Text_Skill")
		if hText then
			hText:SetText(GetKeyShow(nKey, bShift, bCtrl, bAlt, true))
		end
	end
end

function OpenPuppetActionBar(dwNpcTemplateID, bDisableSound)
	if not dwNpcTemplateID then
		return
	end
	
	local tSkill, tGroup = Table_GetPuppetSkill(dwNpcTemplateID)
	if not tSkill or not tGroup then
		return
	end
	if not IsPuppetActionBarOpened() then
		Wnd.OpenWindow("PuppetActionBar")
	end
	local hFrame = Station.Lookup("Normal/PuppetActionBar")
	hFrame.dwNpcTemplateID = dwNpcTemplateID
	
	PuppetActionBar.Update(hFrame, tSkill, tGroup)
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND, g_sound.OpenFrame)
	end
end

function IsPuppetActionBarOpened()
	local hFrame = Station.Lookup("Normal/PuppetActionBar")
	if hFrame then
		return true
	end
	
	return false
end

function ClosePuppetActionBar()
	if not IsPuppetActionBarOpened() then
		return
	end
	Wnd.CloseWindow("PuppetActionBar")
end

function GetPuppetActionBarBox(nIndex)
	local hFrame = Station.Lookup("Normal/PuppetActionBar")
	local hTotalHandle = hFrame:Lookup("", "")
	local hBox = hTotalHandle:Lookup("Handle_Box/Handle_SkillMod")
    local hSkillHandle = hBox:Lookup("Handle_SkillBox" .. nIndex)
    hSkillBox =  hSkillHandle:Lookup("Box_Skill")
	
	return hSkillBox
end


