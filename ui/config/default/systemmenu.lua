SystemMenu = 
{
	bOpen = true, bCanDrag = true, bToggle = true,
	DefaultAnchor = {s = "BOTTOMRIGHT", r = "BOTTOMRIGHT", x = 0, y = 0},
	Anchor = {s = "BOTTOMRIGHT", r = "BOTTOMRIGHT", x = 0, y = 0},
	DefaultAnchorCorner = "BOTTOMRIGHT",
	AnchorCorner = "BOTTOMRIGHT"
}

RegisterCustomData("SystemMenu.bOpen")
RegisterCustomData("SystemMenu.bCanDrag")
RegisterCustomData("SystemMenu.Anchor")
RegisterCustomData("SystemMenu.AnchorCorner")

function SystemMenu.OnFrameCreate()
	this:RegisterEvent("UI_SCALED")
	this:RegisterEvent("ON_ENTER_CUSTOM_UI_MODE")
	this:RegisterEvent("ON_LEAVE_CUSTOM_UI_MODE")
	this:RegisterEvent("SYSTEM_MENU_ANCHOR_CHANGED")
	this:RegisterEvent("SYSTEM_MENU_ANCHOR_CORNER_CHANGED")
	this:RegisterEvent("CUSTOM_DATA_LOADED")
	this:RegisterEvent("SYNC_ROLE_DATA_END")
	this:RegisterEvent("PLAYER_LEVEL_UPDATE")
	this:RegisterEvent("QUEST_ACCEPTED")
	this:RegisterEvent("UPDATE_TONG_DIPLOMACY_INFO")
	
	SystemMenu.UpdateAnchor(this)
	SystemMenu.UpdateAnchorCorner(this)
	UpdateCustomModeWindow(this, g_tStrings.SYS_MENU)
end

function SystemMenu.OnEvent(event)
	if event == "UI_SCALED" or event == "SYSTEM_MENU_ANCHOR_CHANGED" then
		SystemMenu.UpdateAnchor(this)
	elseif event == "ON_ENTER_CUSTOM_UI_MODE" or event == "ON_LEAVE_CUSTOM_UI_MODE" then
		UpdateCustomModeWindow(this)
	elseif event == "SYSTEM_MENU_ANCHOR_CORNER_CHANGED" then
		SystemMenu.UpdateAnchorCorner(this)
	elseif event == "CUSTOM_DATA_LOADED" then
		SetSysMenuStatus(SystemMenu.bOpen, SystemMenu.bCanDrag)
		SystemMenu.UpdateAnchorCorner(this)
	elseif event == "QUEST_ACCEPTED" then
		local hQuest = this:Lookup("Wnd_Menu/Btn_Quest")
		FireHelpEvent("OnCommentToOpenQuest", arg1, hQuest)
	elseif event == "SYNC_ROLE_DATA_END" or event == "PLAYER_LEVEL_UPDATE" then
		local hBtnPartyRecruit = this:Lookup("Wnd_Menu/Btn_PartyRecruit")
		if hBtnPartyRecruit then
			FireHelpEvent("OnCommentToOpenPartyRecruit", hBtnPartyRecruit)
		end
        SystemMenu.UpdateTongDiplomacy(this)
	elseif event == "UPDATE_TONG_DIPLOMACY_INFO" then
		SystemMenu.UpdateTongDiplomacy(this)
	end
end

function SystemMenu.UpdateTongDiplomacy(frame)
    local hGuildImage = this:Lookup("Wnd_Menu/Btn_Guild"):Lookup("", "Image_Guild")
    if IsInXuanZhanState() then
        hGuildImage:Show()
    else
        hGuildImage:Hide()
    end
end

function SystemMenu.UpdateAnchor(frame)
	frame:SetPoint(SystemMenu.Anchor.s, 0, 0, SystemMenu.Anchor.r, SystemMenu.Anchor.x, SystemMenu.Anchor.y)
	frame:CorrectPos()
end

function SystemMenu.UpdateAnchorCorner(frame)
	local page = frame:Lookup("Wnd_Corner")
	local pageMenu = frame:Lookup("Wnd_Menu")
	local checkbox = page:Lookup("CheckBox_Switch")
	local img = page:Lookup("", "Image_Coner")
	local szPath = "ui/Image/Minimap/Minimap.UITex"
	if SystemMenu.AnchorCorner == "TOPLEFT" then
		page:SetRelPos(0, 0)
		pageMenu:SetRelPos(16, 30)
		checkbox:SetRelPos(0, 0)
		checkbox:SetAnimation(szPath, 62, 58, 65, 61, 60, 64, 59, 63, 61, 65)
		img:SetImageType(IMAGE.FLIP_HORIZONTAL)
		page:SetAreaTestFile("ui/Image/TargetPanel/TriAngleDRTL.area")
	elseif SystemMenu.AnchorCorner == "TOPRIGHT" then
		page:SetRelPos(0, 0)
		pageMenu:SetRelPos(16, 30)
		checkbox:SetRelPos(38, 2)
		checkbox:SetAnimation(szPath, 34, 42, 37, 29, 44, 36, 43, 35, 29, 37)
		img:SetImageType(IMAGE.NORMAL)
		page:SetAreaTestFile("ui/Image/TargetPanel/TriAngleTR.area")
	elseif SystemMenu.AnchorCorner == "BOTTOMLEFT" then
		pageMenu:SetRelPos(18, 0)
		local _, H = pageMenu:GetSize()
		page:SetRelPos(0, H - 40)
        
		pageMenu:SetRelPos(18, 0)
		checkbox:SetRelPos(0, 42)
		checkbox:SetAnimation(szPath, 42, 34, 29, 37, 36, 44, 35, 43, 37, 29)
		img:SetImageType(IMAGE.FLIP_CENTRAL)
		page:SetAreaTestFile("ui/Image/TargetPanel/TriAngleBL.area")
	else
		pageMenu:SetRelPos(20, 0)
		local _, H = pageMenu:GetSize()
		page:SetRelPos(0, H - 40)
		checkbox:SetRelPos(38, 38)
		checkbox:SetAnimation(szPath, 58, 62, 61, 65, 64, 60, 63, 59, 65, 61)
		img:SetImageType(IMAGE.FLIP_VERTICAL)
		page:SetAreaTestFile("ui/Image/TargetPanel/TriAngleBR.area")
	end
end

function SystemMenu.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_Char" then
		if SystemMenu.bToggle then
			if IsCharacterPanelOpened() then
				CloseCharacterPanel()
			else
				OpenCharacterPanel()
			end		
		else
			OpenCharacterPanel()
		end
	elseif szName == "Btn_Skill" then
		if SystemMenu.bToggle then
			if IsSkillPanelOpened() then
				CloseSkillPanel()
			else
				OpenSkillPanel()
			end		
		else
			OpenSkillPanel()
		end
	elseif szName == "Btn_Quest" then
		if SystemMenu.bToggle then
			if IsQuestPanelOpened() then
				CloseQuestPanel()
			else
				OpenQuestPanel()
			end
		else
			OpenQuestPanel()
		end
	elseif szName == "Btn_Craft" then
		if SystemMenu.bToggle then
			if IsCraftPanelOpened() then
				CloseCraftPanel()
			else
				OpenCraftPanel()
			end		
		else
			OpenCraftPanel()
		end
	elseif szName == "Btn_Read" then		
		if SystemMenu.bToggle then
			if IsCraftReadManagePanelOpened() then
				CloseCraftReadManagePanel()
			else
				OpenCraftReadManagePanel()
			end		
		else
			OpenCraftReadManagePanel()
		end
		
	elseif szName == "Btn_Friend" then
		if SystemMenu.bToggle then
			if IsPartyPanelOpened() then
				ClosePartyPanel()
			else
				OpenPartyPanel()
			end		
		else
			OpenPartyPanel()
		end
	elseif szName == "Btn_Guild" then
		if SystemMenu.bToggle then
			if IsGuildPanelOpened() then
				CloseGuildPanel()
			else
				OpenGuildPanel()
			end		
		else
			OpenGuildPanel()
		end
	elseif szName == "Btn_Channel" then
		if SystemMenu.bToggle then
			if IsChannelsPanelOpened() then
				CloseChannelsPanel()
			else
				OpenChannelsPanel()
			end	
		else
			OpenChannelsPanel()
		end
	elseif szName == "Btn_GM" then
		if SystemMenu.bToggle then
			if IsGMPanelOpened() then
				CloseGMPanel()
			else
				OpenGMPanel("Helper")
			end
		else	
			OpenOptionPanel()
		end
	elseif szName == "Btn_Option" then
		if SystemMenu.bToggle then
			if IsOptionPanelOpened() then
				CloseOptionPanel()
			else
				OpenOptionPanel()
			end
		else	
			OpenOptionPanel()
		end
	elseif szName == "Btn_PartyRecruit" then
		if SystemMenu.bToggle then
			if IsPartyRecruitPanelOpened() then
				ClosePartyRecruitPanel()
			else
				OpenPartyRecruitPanel()
			end
		else
			OpenPartyRecruitPanel()
		end
	elseif szName == "Btn_Achievement" then
		if SystemMenu.bToggle then
			if IsAchievementPanelOpened() then
				CloseAchievementPanel()
			else
				OpenAchievementPanel()
			end
		else
			OpenAchievementPanel()
		end
	elseif szName == "Btn_Mentor" then
		if SystemMenu.bToggle then
			if IsMentorPanelOpened() then
				CloseMentorPanel()
			else
				OpenMentorPanel()
			end
		else
			OpenMentorPanel()
		end	
	elseif szName == "Btn_FEStone" then
		if SystemMenu.bToggle then
			if IsFEProducePanelOpened() then
				CloseFEProducePanel()
			else
				OpenFEProducePanel()
			end
		else
			OpenFEProducePanel()
		end	
     elseif szName == "Btn_Talent" then
		if SystemMenu.bToggle then
			if IsZhenPaiSkillOpened() then
				CloseZhenPaiSkill()
			else
				OpenZhenPaiSkill()
			end
		else
			OpenZhenPaiSkill()
		end	
	elseif szName == "Btn_Amphitheater" then
		if SystemMenu.bToggle then
			if IsArenaCorpsPanelOpened() then
				CloseArenaCorpsPanel()
			else
				OpenArenaCorpsPanel()
			end
		else
			OpenArenaCorpsPanel()
		end	
	end
end

function SystemMenu.OnMouseEnter()
    local szName = this:GetName()
    if szName == "Btn_Guild" then
        local x, y = this:GetAbsPos()
        local w, h = this:GetSize()
            
        local image = this:Lookup("", "Image_Guild")
        if image:IsVisible() then
            local szTip = GetString("STR_TONG_WAR_TIP")
            OutputTip(szTip, 400, {x, y, w, h})
        else
            local szTip = GetString("STR_SYSTEM_GUILD")
            OutputAutoTipInfoByText(szTip, 2, true, x, y, w, h)
        end
    end
end

function SystemMenu.OnMouseLeave()
    local szName = this:GetName()
    if szName == "Btn_Guild" then
        HideTip()
    end
end

function SystemMenu.OnItemLButtonDown()
	return false
end

function SystemMenu.OnItemLButtonUp()
	return false
end

function SystemMenu.OnItemLButtonDrag()
	if not SystemMenu.bCanDrag then
		return
	end
	if not Hand_IsEmpty() then
		return
	end
	if IsCursorInExclusiveMode() then
		return
	end
	local szName = this:GetName()
	local dwID = nil
	if szName == "Box_Char" then
		dwID = SYS_BTN_CHARACTER
	elseif szName == "Box_Skill" then
		dwID = SYS_BTN_SKILL
	elseif szName == "Box_Quest" then
		dwID = SYS_BTN_QUEST
	elseif szName == "Box_Amphitheater" then
		dwID = SYS_BTN_ARENA
	elseif szName == "Box_Craft" then
		dwID = SYS_BTN_CRAFT
	elseif szName == "Box_Read" then
		dwID = SYS_BTN_READ
	elseif szName == "Box_Friend" then
		dwID = SYS_BTN_FRIEND
	elseif szName == "Box_Guild" then
		dwID = SYS_BTN_GUILD
	elseif szName == "Box_Channel" then
		dwID = SYS_BTN_CHANNEL
	elseif szName == "Box_GM" then
		dwID = SYS_BTN_GM
	elseif szName == "Box_Option" then
		dwID = SYS_BTN_OPTION
        --[[
	elseif szName == "Box_PartyRecruit" then
		dwID = SYS_BIN_PARTY_RECRUIT
        ]]
	elseif szName == "Box_Achievement" then
		dwID = SYS_BTN_ACHIEVEMENT
	elseif szName == "Box_Mentor" then
		dwID = SYS_BTN_MENTOR
    elseif szName == "Box_Talent" then
        dwID = SYS_BTN_TALENT
	end
	
	if dwID then
		this:SetObject(UI_OBJECT_SYS_BTN, dwID)
		this:SetObjectIcon(GetSysBtnIcon(dwID))
		Hand_Pick(this)
		this:ClearObject()
		Station.ReleaseCapture()
	end
end

function SystemMenu.OnItemLButtonDragEnd()
	if Hand_IsEmpty() then
		return
	end
	local boxHand = Hand_Get()
	if boxHand:GetObjectType() == UI_OBJECT_SYS_BTN then
		Hand_Clear()
	end
end

function SystemMenu.OnCheckBoxCheck()
	local szName = this:GetName()
	if szName == "CheckBox_Switch" then
		CloseSysMenu()
	end
end

function SystemMenu.OnCheckBoxUncheck()
	local szName = this:GetName()
	if szName == "CheckBox_Switch" then
		OpenSysMenu()
	end
end

function SystemMenu.OnFrameDrag()
end

function SystemMenu.OnFrameDragSetPosEnd()
	SystemMenu.AnchorCorner = GetFrameAnchorCorner(this)
	FireEvent("SYSTEM_MENU_ANCHOR_CORNER_CHANGED")
end

function SystemMenu.OnFrameDragEnd()
	this:CorrectPos()
	SystemMenu.AnchorCorner = GetFrameAnchorCorner(this)
	FireEvent("SYSTEM_MENU_ANCHOR_CORNER_CHANGED")
	SystemMenu.Anchor = GetFrameAnchor(this)
end

function OpenSysMenu(bDisbleSound)
	if IsSysMenuOpened() then
		return
	end
	local frame = Wnd.OpenWindow("SystemMenu")
	frame:Lookup("Wnd_Corner/CheckBox_Switch"):Check(false)
	frame:Lookup("Wnd_Menu"):Show()
	if not bDisbleSound then
		PlaySound(SOUND.UI_SOUND, g_sound.OpenFrame)
	end
	SystemMenu.bOpen = true
end

function CloseSysMenu(bDisbleSound)
	if not IsSysMenuOpened() then
		return
	end
	local frame = Station.Lookup("Topmost/SystemMenu")
	if frame then
		frame:Lookup("Wnd_Corner/CheckBox_Switch"):Check(true)
		frame:Lookup("Wnd_Menu"):Hide()
		if not bDisbleSound then
			PlaySound(SOUND.UI_SOUND, g_sound.CloseFrame)
		end
	end
	SystemMenu.bOpen = false
end

function IsSysMenuOpened()
	local frame = Station.Lookup("Topmost/SystemMenu")
	if frame and frame:Lookup("Wnd_Menu"):IsVisible() then
		return true
	end
	return false
end

SYS_BTN_CHARACTER =	1
SYS_BTN_SKILL = 2
SYS_BTN_QUEST = 3
SYS_BTN_CRAFT = 4
SYS_BTN_READ = 5
SYS_BTN_FRIEND = 6
SYS_BTN_GUILD = 7
SYS_BTN_CHANNEL = 8
SYS_BTN_GM = 9
SYS_BTN_OPTION = 10
SYS_BIN_PARTY_RECRUIT = 11
SYS_BTN_ACHIEVEMENT = 12
SYS_BTN_MENTOR = 13
SYS_BTN_TALENT = 14
SYS_BTN_ARENA = 15

function GetSysBtnTip(dwID)
	local szTip = ""
	if dwID == SYS_BTN_CHARACTER then
		szTip = GetString("STR_SYSTEM_CHARCTER")
	elseif dwID == SYS_BTN_SKILL then
		szTip = GetString("STR_SYSTEM_SKILL")
	elseif dwID == SYS_BTN_QUEST then
		szTip = GetString("STR_SYSTEM_QUEST")
	elseif dwID == SYS_BTN_ARENA then
		szTip = GetString("STR_SYSTEM_AMPHITHEATER")
	elseif dwID == SYS_BTN_CRAFT then
		szTip = GetString("STR_SYSTEM_CRAFT")
	elseif dwID == SYS_BTN_READ then
		szTip = GetString("STR_SYSTEM_READ")
	elseif dwID == SYS_BTN_FRIEND then
		szTip = GetString("STR_SYSTEM_RELATION")
	elseif dwID == SYS_BTN_GUILD then
		szTip = GetString("STR_SYSTEM_GUILD")
	elseif dwID == SYS_BTN_CHANNEL then
		szTip = GetString("STR_SYSTEM_CHANNEL")
	elseif dwID == SYS_BTN_GM then
		szTip = GetString("STR_SYSTEM_GM")
	elseif dwID == SYS_BTN_OPTION then
		szTip = GetString("STR_SYSTEM_SYSTEM")
	elseif dwID == SYS_BIN_PARTY_RECRUIT then
		szTip = GetString("STR_SYSTEM_PARTY_RECRUIT")
	elseif dwID == SYS_BTN_ACHIEVEMENT then
		szTip = GetString("STR_SYSTEM_ACHIVEMENT")
	elseif dwID == SYS_BTN_MENTOR then
		szTip = GetString("STR_SYSTEM_MENTOR")
    elseif dwID == SYS_BTN_TALENT then
        szTip = GetString("STR_SYSTEM_TALENT")
	end
	return szTip
end

function GetSysBtnIcon(dwID)
	if dwID == SYS_BTN_CHARACTER then
		return 881
	elseif dwID == SYS_BTN_SKILL then
		return 883
	elseif dwID == SYS_BTN_QUEST then
		return 882
	elseif dwID == SYS_BTN_ARENA then
		return 3287	
	elseif dwID == SYS_BTN_CRAFT then
		return 879
	elseif dwID == SYS_BTN_READ then
		return 885
	elseif dwID == SYS_BTN_FRIEND then
		return 880
	elseif dwID == SYS_BTN_GUILD then
		return 878
	elseif dwID == SYS_BTN_CHANNEL then
		return 1437
	elseif dwID == SYS_BTN_GM then
		return 1555
	elseif dwID == SYS_BTN_OPTION then
		return 884
	elseif dwID == SYS_BIN_PARTY_RECRUIT then
		return 1890
	elseif dwID == SYS_BTN_ACHIEVEMENT then
		return 2116
	elseif dwID == SYS_BTN_MENTOR then
		return 2237
    elseif dwID == SYS_BTN_TALENT then
        return 3039
	end
end

function OnUseSysBtn(dwID)
	if dwID == SYS_BTN_CHARACTER then
		if IsCharacterPanelOpened() then
			CloseCharacterPanel()
		else
			OpenCharacterPanel()
		end
	elseif dwID == SYS_BTN_SKILL then
		if IsSkillPanelOpened() then
			CloseSkillPanel()
		else
			OpenSkillPanel()
		end
	elseif dwID == SYS_BTN_QUEST then
		if IsQuestPanelOpened() then
			CloseQuestPanel()
		else
			OpenQuestPanel()
		end
	elseif dwID == SYS_BTN_ARENA then
		if IsArenaCorpsPanelOpened() then
			CloseArenaCorpsPanel()
		else
			OpenArenaCorpsPanel()
		end
	elseif dwID == SYS_BTN_CRAFT then
		if IsCraftPanelOpened() then
			CloseCraftPanel()
		else
			OpenCraftPanel()
		end
	elseif dwID == SYS_BTN_READ then
		if IsCraftReadManagePanelOpened() then
			CloseCraftReadManagePanel()
		else
			OpenCraftReadManagePanel()
		end		
	elseif dwID == SYS_BTN_FRIEND then
		if IsPartyPanelOpened() then
			ClosePartyPanel()
		else
			OpenPartyPanel()
		end
	elseif dwID == SYS_BTN_GUILD then
		if IsGuildPanelOpened() then
			CloseGuildPanel()
		else
			OpenGuildPanel()
		end
	elseif dwID == SYS_BTN_CHANNEL then
		if IsChannelsPanelOpened() then
			CloseChannelsPanel()
		else
			OpenChannelsPanel()
		end
	elseif dwID == SYS_BTN_GM then
		if IsGMPanelOpened() then
			CloseGMPanel()
		else
			OpenGMPanel("Helper")
		end
	elseif dwID == SYS_BTN_OPTION then
		if IsOptionPanelOpened() then
			CloseOptionPanel()
		else
			OpenOptionPanel()
		end
        --[[
	elseif dwID == SYS_BIN_PARTY_RECRUIT then
		if IsPartyRecruitPanelOpened() then
			ClosePartyRecruitPanel()
		else
			OpenPartyRecruitPanel()
		end
        ]]
	elseif dwID == SYS_BTN_ACHIEVEMENT then
		if IsAchievementPanelOpened() then
			CloseAchievementPanel()
		else
			OpenAchievementPanel()
		end
	elseif dwID == SYS_BTN_MENTOR then
		if IsMentorPanelOpened() then
			CloseMentorPanel()
		else
			OpenMentorPanel()
		end
    elseif dwID == SYS_BTN_TALENT then
		if IsZhenPaiSkillOpened() then
			CloseZhenPaiSkill()
		else
			OpenZhenPaiSkill()
		end
	end
end

function IsSysbtnUsed(dwID)
	if dwID == SYS_BTN_CHARACTER then
		return IsCharacterPanelOpened()
	elseif dwID == SYS_BTN_SKILL then
		return IsSkillPanelOpened()
	elseif dwID == SYS_BTN_QUEST then
		return IsQuestPanelOpened()
	elseif dwID == SYS_BTN_ARENA then
		return IsArenaCorpsPanelOpened()
	elseif dwID == SYS_BTN_CRAFT then
		return IsCraftPanelOpened()
	elseif dwID == SYS_BTN_READ then
		return IsCraftReadManagePanelOpened()
	elseif dwID == SYS_BTN_FRIEND then
		return IsPartyPanelOpened()
	elseif dwID == SYS_BTN_GUILD then
		return IsGuildPanelOpened()
	elseif dwID == SYS_BTN_CHANNEL then
		return IsChannelsPanelOpened()
	elseif dwID == SYS_BTN_GM then
		return IsGMPanelOpened()
	elseif dwID == SYS_BTN_OPTION then
		return IsOptionPanelOpened()
	elseif dwID == SYS_BIN_PARTY_RECRUIT then
		return IsPartyRecruitPanelOpened()
	elseif dwID == SYS_BTN_ACHIEVEMENT then
		return IsAchievementPanelOpened()
	elseif dwID == SYS_BTN_MENTOR then
		return IsMentorPanelOpened()
   elseif dwID == SYS_BTN_TALENT then
		return IsZhenPaiSkillOpened()
	end
	return false
end

function GetSysMenuStatus()
	return SystemMenu.bOpen, SystemMenu.bCanDrag
end

function SetSysMenuStatus(bOpen, bCanDrag)
	SystemMenu.bOpen, SystemMenu.bCanDrag = bOpen, bCanDrag
	if bOpen then
		OpenSysMenu(true)
	else
		CloseSysMenu(true)
	end
end

function GetSysMenuBtnObject(szBtnName)
	local frame = Station.Lookup("Topmost/SystemMenu")
	if frame and frame:Lookup("Wnd_Menu"):IsVisible() then
		local hObject = frame:Lookup("Wnd_Menu"):Lookup(szBtnName)
		return hObject
	end
end

function HideGuildSysBtnAnimate()
	local hBtn = GetSysMenuBtnObject("Btn_Guild")
	if hBtn then
		hBtn:Lookup("", "Animate_Guild"):Hide()
	end
end

function SystemMenu_SetAnchorDefault()
	SystemMenu.Anchor.s = SystemMenu.DefaultAnchor.s
	SystemMenu.Anchor.r = SystemMenu.DefaultAnchor.r
	SystemMenu.Anchor.x = SystemMenu.DefaultAnchor.x
	SystemMenu.Anchor.y = SystemMenu.DefaultAnchor.y
	FireEvent("SYSTEM_MENU_ANCHOR_CHANGED")
	SystemMenu.AnchorCorner = SystemMenu.DefaultAnchorCorner
	FireEvent("SYSTEM_MENU_ANCHOR_CORNER_CHANGED")
end

RegisterEvent("CUSTOM_UI_MODE_SET_DEFAULT", SystemMenu_SetAnchorDefault)
