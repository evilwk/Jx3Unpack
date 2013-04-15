Player =
{
	bShowStateValue = true;
	bShowPercentage = false;
	bShowTwoFormat = false;
	aAccumulateShow =
	{
		{},
		{"10"},
		{"11"},
		{"11", "20"},
		{"11", "21"},
		{"11", "21", "30"},
		{"11", "21", "31"},
		{"11", "21", "31", "40"},
		{"11", "21", "31", "41"},
		{"11", "21", "31", "41", "50"},
		{"11", "21", "31", "41", "51"},
	},
	aAccumulateHide =
	{
		{"10", "11", "20", "21", "30", "31", "40", "41", "50", "51"},
		{"11", "20", "21", "30", "31", "40", "41", "50", "51"},
		{"10", "20", "21", "30", "31", "40", "41", "50", "51"},
		{"10", "21", "30", "31", "40", "41", "50", "51"},
		{"10", "20", "30", "31", "40", "41", "50", "51"},
		{"10", "20", "31", "40", "41", "50", "51"},
		{"10", "20", "30", "40", "41", "50", "51"},
		{"10", "20", "30", "41", "50", "51"},
		{"10", "20", "30", "40", "50", "51"},
		{"10", "20", "30", "40", "51"},
		{"10", "20", "30", "40", "50"},
	},
	DefaultAnchor = {s = "TOPLEFT", r = "TOPLEFT", x = 5, y = 10},
	Anchor = {s = "TOPLEFT", r = "TOPLEFT", x = 5, y = 10},
	
	Avatars = Table_GetPlayerMiniAvatars(),
}

RegisterCustomData("Player.bShowStateValue")
RegisterCustomData("Player.bShowPercentage")
RegisterCustomData("Player.bShowTwoFormat")
RegisterCustomData("Player.Anchor")

local function UpdataQiXiuImage(hImage)
	if hImage.bClickDown then
		hImage:SetFrame(89)
	elseif hImage.bInside then
		hImage:SetFrame(86)
	elseif hImage.bChecked then
		hImage:SetFrame(88)
	else
		hImage:SetFrame(85)
	end
end

function Player.OnFrameCreate()
	this:RegisterEvent("PLAYER_STATE_UPDATE")
	this:RegisterEvent("PLAYER_LEVEL_UPDATE")
    this:RegisterEvent("SYNC_ROLE_DATA_END")

	this:RegisterEvent("UI_SCALED")
	this:RegisterEvent("ON_ENTER_CUSTOM_UI_MODE")
	this:RegisterEvent("ON_LEAVE_CUSTOM_UI_MODE")
	this:RegisterEvent("PLAYER_ANCHOR_CHANGED")
	this:RegisterEvent("CURRENT_PLAYER_FORCE_CHANGED")


	---------队伍相关事件-----------------------------
	this:RegisterEvent("TEAM_AUTHORITY_CHANGED")
	this:RegisterEvent("PARTY_DISBAND")
	this:RegisterEvent("PARTY_SYNC_MEMBER_DATA")
	this:RegisterEvent("PARTY_SET_FORMATION_LEADER")

	---------战斗事件---------------------------------
	this:RegisterEvent("FIGHT_HINT")
	this:RegisterEvent("UI_UPDATE_ACCUMULATE")
	this:RegisterEvent("SKILL_MOUNT_KUNG_FU")
	this:RegisterEvent("SKILL_UNMOUNT_KUNG_FU")
	this:RegisterEvent("SET_SHOW_VALUE_BY_PERCENTAGE")
	this:RegisterEvent("SET_SHOW_VALUE_TWO_FORMAT")
	this:RegisterEvent("SET_SHOW_PLAYER_STATE_VALUE")
	this:RegisterEvent("PARTY_SET_MARK")
	this:RegisterEvent("CUSTOM_DATA_LOADED")

	this:RegisterEvent("PARTY_CAMP_CHANGE")
	this:RegisterEvent("CHANGE_CAMP")
	this:RegisterEvent("PARTY_DELETE_MEMBER")
	this:RegisterEvent("PARTY_UPDATE_MEMBER_INFO")
	this:RegisterEvent("UI_ON_DAMAGE_EVENT")
	this:RegisterEvent("CHANGE_CAMP_FLAG")
	
	--------小头像事件------------------------------
	this:RegisterEvent("SET_MINI_AVATAR")

	Player.Update(this)

	Player.UpdateAnchor(this)
	UpdateCustomModeWindow(this, g_tStrings.PLAYER_HEAD, nil, nil, true)
end

function Player.Update(frame)
	local player = GetClientPlayer()
	if not player then
		return
	end

	Player.UpdateLFData(frame)
	Player.UpdateHFData(frame)
	Player.UpdatePlayerMark(frame)
	Player.UpdateKungfu(frame)

	Player.OnFightFlagUpdate(frame)
	Player.UpdatePlayerStateValueShow(frame)

	Player.OnMountKF(frame)
end

function Player.UpdateLFData(hFrame)
	local hPlayer = GetClientPlayer()
	if not hPlayer then
		return
	end

	local hTeam = GetClientTeam()
	local hTotal = hFrame:Lookup("", "")
	local bInParty = hPlayer.IsInParty()

	-- Name
	local hTextPlayer = hTotal:Lookup("Text_Player")
	hTextPlayer:SetText(hPlayer.szName)
	local nR, nG, nB = GetForceFontColor(hPlayer.dwID, hPlayer.dwID)
	hTextPlayer:SetFontColor(nR, nG, nB)

	-- Level
	hTotal:Lookup("Text_Level"):SetText(hPlayer.nLevel)

	-- Team Authority
    local hImgLeader = hTotal:Lookup("Image_Flag")
    if bInParty and hPlayer.dwID == hTeam.GetAuthorityInfo(TEAM_AUTHORITY_TYPE.LEADER) then
    	hImgLeader:Show()
    else
    	hImgLeader:Hide()
    end

    local hImgDistribute = hTotal:Lookup("Image_Boss")
    if bInParty and hPlayer.dwID == hTeam.GetAuthorityInfo(TEAM_AUTHORITY_TYPE.DISTRIBUTE) then
    	hImgDistribute:Show()
    else
    	hImgDistribute:Hide()
    end

    local hImgMark = hTotal:Lookup("Image_Mark")
    if bInParty and hPlayer.dwID == hTeam.GetAuthorityInfo(TEAM_AUTHORITY_TYPE.MARK) then
    	hImgMark:Show()
    else
    	hImgMark:Hide()
    end


	local bFormation = false
	if bInParty then
		local nGroupID = hTeam.GetMemberGroupIndex(hPlayer.dwID)
		if nGroupID then
			local tGroupInfo = hTeam.GetGroupInfo(nGroupID)
			if tGroupInfo and tGroupInfo.dwFormationLeader == hPlayer.dwID then
				bFormation = true
			end
		end
	end
    local hImgFormation = hTotal:Lookup("Image_Center")
    if bFormation then
    	hImgFormation:Show()
    else
    	hImgFormation:Hide()
    end

	-- Camp
	local nFrame = GetCampImageFrame(hPlayer.nCamp, hPlayer.bCampFlag)
	local hImageCamp = hTotal:Lookup("Image_Camp")
	SetImage(hImageCamp, nFrame)

	-- Team Camp
	local nTeamCampFrame = nil
	if bInParty then
		local eTeamCamp = hTeam.nCamp
		if eTeamCamp == CAMP.GOOD then
			nTeamCampFrame = 74
		elseif eTeamCamp == CAMP.EVIL then
			nTeamCampFrame = 73
		end
	end
	local hImageTeamCamp = hTotal:Lookup("Image_TeamCamp")
	SetImage(hImageTeamCamp, nTeamCampFrame)
end

function Player.UpdateMiniAvatar(frame, force)
	local player = GetClientPlayer()
	if not player then
		return
	end
	
	if not frame then
		frame = Player_GetFrame()
	end
	
	local handle = frame:Lookup("", "")
	local img = handle:Lookup("Image_NewPlayer")
	
	local dwAvatar = player.dwMiniAvatarID
	if force or not dwAvatar or dwAvatar == 0 then
		local szFile = RoleChange.GetSchoolAvatarPath(player.dwForceID)
		img:SetImageType(IMAGE.NORMAL)
		img:FromTextureFile(szFile)
	else
		local szFile = RoleChange.GetRoleAvatarPath(Player.Avatars[dwAvatar].szFileName)
		img:SetImageType(IMAGE.FLIP_HORIZONTAL)
		img:FromTextureFile(szFile)
	end
end

function Player.UpdateKungfu(frame)
	local player = GetClientPlayer()
	if not player then
		return
	end

	local handle = frame:Lookup("", "")
--	local kungfu = player.GetKungfuMount()
--	local dwKungfuType = 0
--	
--	if kungfu then
--		dwKungfuType = kungfu.dwMountType
--	end
--	
--	local szPath, nFrame = GetKungfuImage(dwKungfuType)
--	handle:Lookup("Image_Player"):FromUITex(szPath, nFrame)
	local szPath, nFrame = GetForceImage(player.dwForceID)
	handle:Lookup("Image_Player"):FromUITex(szPath, nFrame)
	
	local nCount = GetPlayerSchoolNumber(player)
	if nCount > 0 then
		handle:Lookup("Text_Others"):SetText(nCount)
	else
		handle:Lookup("Text_Others"):SetText("")
	end
end

local function OnUpdateProgress(hProgress)
	local hHighlight = hProgress:GetParent():Lookup("Image_Flash")
	local fCurPercent = hProgress:GetPercentage()
    if fCurPercent < 1 then
    	local nStartPosX, _ = hProgress:GetAbsPos()
    	local nFullWidth, _ = hProgress:GetSize()
    	local nHighlightWidth, _ = hHighlight:GetSize()
    	local _, nPosY = hHighlight:GetAbsPos()
    	hHighlight:SetAbsPos(nStartPosX + nFullWidth * fCurPercent - nHighlightWidth, nPosY)
    	hHighlight:Show()
    else
    	hHighlight:Hide()
    end	
end

function Player.UpdateHFData(hFrame)
	local hPlayer = GetClientPlayer()
	local hTotal = hFrame:Lookup("", "")

	Player.UpdateHeaderBg(hFrame)
	
	local hTextHealth = hTotal:Lookup("Text_Health")
	local hImageHealth = hTotal:Lookup("Image_Health")
	local hHighlight = hTotal:Lookup("Image_Flash")
	local hImgSubHealth = hFrame:Lookup("", "Image_SubHealth")
	if hPlayer.nMaxLife > 0 then
		local fHealth = hPlayer.nCurrentLife / hPlayer.nMaxLife
		
		local fSubPercent = 0
		if hPlayer.nMoveState == MOVE_STATE.ON_DEATH then
			fSubPercent = fHealth
		else
			fSubPercent = hImageHealth:GetPercentage()
		end
		hImgSubHealth:SetPercentage(fSubPercent)
		
		hImageHealth:SetPercentage(fHealth)
		
		local szShow = GetStateString(hPlayer.nCurrentLife, hPlayer.nMaxLife)
		hTextHealth:SetText(szShow)
	else
	    hImageHealth:SetPercentage(0)
	    hTextHealth:SetText("")
	    hHighlight:Hide()
    end

	local hImageMana = hTotal:Lookup("Image_Mana")
	local hTextMana = hTotal:Lookup("Text_Mana")
	hImageMana:Show()
	hTextMana:Show()
	if hPlayer.nMaxMana > 0 and hPlayer.nMaxMana ~= 1 then
		local fMana = hPlayer.nCurrentMana / hPlayer.nMaxMana
	    hImageMana:SetPercentage(fMana)
		
		local szShow = GetStateString(hPlayer.nCurrentMana, hPlayer.nMaxMana) 
	    hTextMana:SetText(szShow)
	else
	    hImageMana:SetPercentage(0)
	    hTextMana:SetText("")
    end
    
	if not IsPlayerShowStateValue() then
		hTextMana:Hide()
	end
	
    local player = GetClientPlayer()
    local hCangjian = hTotal:Lookup("Handle_CangJian")
    local cSwitchSword = hTotal:GetRoot():Lookup("CheckBox_SwitchSword")
    if player and player.bCanUseBigSword then
        hCangjian:Show()
        cSwitchSword:Show()
    	Player.UpdateCangjianRage(hCangjian)
    	Player.UpdateCangjianSwitchSword(cSwitchSword, player.bBigSwordSelected)
    	FireHelpEvent("OnCommentToSwitchSword", cSwitchSword)
    else
    	hCangjian:Hide()
    	cSwitchSword:Hide()
    end
	Player.OnUpdateTangmenEnergy(hFrame)
end

function Player.UpdateCangjianRage(hCangjian)
	if not hCangjian then
		return
	end
	
	local hPlayer = GetClientPlayer()
    local hImageShort = hCangjian:Lookup("Image_Short")
    local hTextShort = hCangjian:Lookup("Text_Short")
    local hAniShort = hCangjian:Lookup("Animate_Short")
    local hImageLong = hCangjian:Lookup("Image_Long")
    local hTextLong = hCangjian:Lookup("Text_Long")
    local hAniLong = hCangjian:Lookup("Animate_Long")
    local szShow = nil

    if hPlayer.nMaxRage > 100 then
	    hImageShort:Hide()
	    hTextShort:Hide()
   		hAniShort:Hide()

	    hImageLong:Show()
	    hTextLong:Show()
   		hAniLong:Show()
   		
   		szShow = "Long"
    else	    
	    hImageShort:Show()
	    hTextShort:Show()
	    hAniShort:Show()
	    
	    hImageLong:Hide()
	    hTextLong:Hide()
   		hAniLong:Hide()
   		
   		szShow = "Short"
    end
    
    if hPlayer.nMaxRage > 0 then
    	local fRage = hPlayer.nCurrentRage / hPlayer.nMaxRage
    	
    	hCangjian:Lookup("Image_"..szShow):SetPercentage(fRage)
    	
	    if IsShowStateValueByPercentage() then
	    	hCangjian:Lookup("Text_"..szShow):SetText(string.format("%d%%", 100 * fRage))
	    else
	    	hCangjian:Lookup("Text_"..szShow):SetText(hPlayer.nCurrentRage .. "/" .. hPlayer.nMaxRage)
	    end
    else
	    hCangjian:Lookup("Image_"..szShow):SetPercentage(0)
	    hCangjian:Lookup("Text_"..szShow):SetText("")
    end
	
	Player.HideMana(hCangjian:GetRoot());
end

function Player.UpdateCangjianSwitchSword(cSwitchSword, bHeavySwordSelected)
	if not cSwitchSword then
		return
	end
	
	if bHeavySwordSelected then
		cSwitchSword:Check(true)
	else
		cSwitchSword:Check(false)
	end
end

function Player.OnFrameDrag()
end

function Player.OnFrameDragSetPosEnd()
end

function Player.OnFrameDragEnd()
	this:CorrectPos()
	Player.Anchor = GetFrameAnchor(this)
end

function Player.UpdateAnchor(frame)
	frame:SetPoint(Player.Anchor.s, 0, 0, Player.Anchor.r, Player.Anchor.x, Player.Anchor.y)
	frame:CorrectPos()
end

function Player.UpdatePlayerMark(hFrame)
	local hPlayer = GetClientPlayer()
	local hImageMark = hFrame:Lookup("", "Image_NPCMark")
	local nIconFrame = nil
	if hPlayer.IsInParty() then
		local tPartyMark = GetClientTeam().GetTeamMark()
		if tPartyMark and tPartyMark[hPlayer.dwID] then
			local nMarkID = tPartyMark[hPlayer.dwID]
			assert(nMarkID > 0 and nMarkID <= #PARTY_MARK_ICON_FRAME_LIST)
			nIconFrame = PARTY_MARK_ICON_FRAME_LIST[nMarkID]
		end
	end

	if nIconFrame then
		hImageMark:FromUITex(PARTY_MARK_ICON_PATH, nIconFrame)
		hImageMark:Show()
	else
		hImageMark:Hide()
	end
end

function Player.OnFrameBreathe()
	local player = GetClientPlayer()
	if not player then
		return
	end

	local s = this:Lookup("", "Image_Shadow")
	local hImageHealth = this:Lookup("", "Image_Health")
	if hImageHealth:GetPercentage() < 0.5 then
		if not this.bLow then
			this.bLow = true
			FireHelpEvent("OnHealthLow", hImageHealth)
		end
		if s:IsVisible()  then
			local alpha = s:GetAlpha()
			if s:GetUserData() == 1 then
				alpha = alpha + 30
				s:SetAlpha(alpha)
				if alpha > 150 then
					s:SetUserData(0)
				end
			else
				alpha = alpha - 30
				s:SetAlpha(alpha)
				if alpha < 0 then
					s:SetUserData(1)
				end
			end
		else
			s:Show()
			s:SetAlpha(0)
			s:SetUserData(1)
		end
	else
		this.bLow = false
		s:Hide()
	end
end

function Player.OnEvent(event)
	if event == "PLAYER_STATE_UPDATE" then
		if arg0 == GetClientPlayer().dwID then
			Player.UpdateHFData(this)
		end
	elseif event == "PLAYER_LEVEL_UPDATE" 
	or event == "CHANGE_CAMP_FLAG" then
		if arg0 == GetClientPlayer().dwID then
			Player.UpdateLFData(this)
		end
	elseif event == "SYNC_ROLE_DATA_END" then
		Player.Update(this)
		Player.UpdateMiniAvatar(this)
	elseif event == "CURRENT_PLAYER_FORCE_CHANGED" then
		Player.Update(this)
		
		RemoteCallToServer("OnSetMiniAvatar", 0)
		Player.UpdateMiniAvatar(this, true)
	elseif event == "TEAM_AUTHORITY_CHANGED" then
		local hPlayer = GetClientPlayer()
		if arg2 == hPlayer.dwID or arg3 == hPlayer.dwID then
			Player.UpdateLFData(this)
		end
	elseif event == "PARTY_SET_FORMATION_LEADER" then
		Player.UpdateLFData(this)
	elseif event == "PARTY_SYNC_MEMBER_DATA" then
		Player.UpdateLFData(this)
	elseif event == "PARTY_DISBAND" then
		Player.UpdateLFData(this)
		Player.UpdatePlayerMark(this)
	elseif event == "FIGHT_HINT" then
		Player.OnFightFlagUpdate(this)
	elseif event == "UI_UPDATE_ACCUMULATE" then
		Player.OnUpdateAccumulateValue(this)
	elseif event == "SKILL_MOUNT_KUNG_FU" then
		Player.UpdateLFData(this)
		Player.OnMountKF(this)
		Player.UpdateKungfu(this)
	elseif event == "SKILL_UNMOUNT_KUNG_FU" then
		Player.OnMountKF(this)
		Player.UpdateKungfu(this)
	elseif event == "SET_SHOW_VALUE_BY_PERCENTAGE" or event == "SET_SHOW_VALUE_TWO_FORMAT" then
		Player.UpdatePlayerStateValueShow(this)
		Player.UpdateHFData(this)
	elseif event == "SET_SHOW_PLAYER_STATE_VALUE" then
		Player.UpdatePlayerStateValueShow(this)
		Player.UpdateHFData(this)
	elseif event == "PARTY_SET_MARK" then
		Player.UpdatePlayerMark(this)
	elseif event == "UI_SCALED" then
		Player.UpdateAnchor(this)
	elseif event == "ON_ENTER_CUSTOM_UI_MODE" or event == "ON_LEAVE_CUSTOM_UI_MODE" then
		UpdateCustomModeWindow(this, nil, nil, nil, true)
	elseif event == "PLAYER_ANCHOR_CHANGED" then
		Player.UpdateAnchor(this)
	elseif event == "CUSTOM_DATA_LOADED" then
		Player.UpdateAnchor(this)
	elseif event == "PARTY_CAMP_CHANGE" then
		Player.UpdateLFData(this)
		--[[
		local eCamp = GetClientTeam().nCamp
		if g_tStrings.STR_TEAM_CAMP_MSG[eCamp] then
			OutputMessage("MSG_SYS", g_tStrings.STR_TEAM_CAMP_MSG[eCamp])
		end
		--]]
	elseif event == "PARTY_DELETE_MEMBER" then
		local hPlayer = GetClientPlayer()
		if arg1 == hPlayer.dwID then
			Player.UpdateLFData(this)
			Player.UpdatePlayerMark(this)
		end
	elseif event == "CHANGE_CAMP" then
		local hPlayer = GetClientPlayer()
		if hPlayer and arg0 == hPlayer.dwID then
			Player.UpdateLFData(this)
			if not hPlayer.IsAchievementAcquired(979) then
				RemoteCallToServer("OnClientAddAchievement", "CAMP|JOIN")
			end
		end
	elseif event == "UI_ON_DAMAGE_EVENT" then
		local hPlayer = GetClientPlayer()
		if hPlayer.dwID == arg0 then
			Player.OnDamageEvent(this, arg1, arg2)
		end
	elseif event == "SWITCH_BIGSWORD" then
		local player = GetClientPlayer()
		local cSwitchSword = this:Lookup("CheckBox_SwitchSword")
		if player and player.bCanUseBigSword then
			Player.UpdateCangjianSwitchSword(cSwitchSword, arg0 ~= 0)
		end
	elseif event == "SET_MINI_AVATAR" then
		Player.UpdateMiniAvatar()
	end
end

function Player.OnDamageEvent(hFrame, nDamage, bCriticalStrike)
	local hImgHealth = hFrame:Lookup("", "Image_Health")
	local hImgSubHealth = hFrame:Lookup("", "Image_SubHealth")
	local fMainPercent = hImgHealth:GetPercentage()
	
	local hPlayer = GetClientPlayer()
	if not hPlayer or hPlayer.nMaxLife == 0 then
		hImgSubHealth:SetPercentage(fMainPercent)
		return
	end
	
	local fCurPercent = hImgSubHealth:GetPercentage()
	local fPercent = nDamage / hPlayer.nMaxLife
	if fMainPercent > fCurPercent - fPercent then
		fCurPercent = fMainPercent
	else
		fCurPercent = fCurPercent - fPercent
	end
	hImgSubHealth:SetPercentage(fCurPercent)
	
	if IsFrameShake() and bCriticalStrike then
		ShakeWindow(hFrame)
	end
end

function Player.OnMountKF(frame)
	local player = GetClientPlayer()
	local skill = player.GetKungfuMount()
	local szShow = ""
	local szShowSub = ""
	if skill then
		if skill.dwMountType == 3 then --纯阳内功
			szShow = "Handle_ChunYang"
			szShowSub = "CY_"
		elseif skill.dwMountType == 5 then --少林内功
			szShow = "Handle_ShaoLin"
			szShowSub = "SL_"
		elseif skill.dwMountType == 10 then --唐门内功
			szShow = "Handle_TangMen"
			szShowSub = "TM_"
		elseif skill.dwMountType == 4 then  -- 七秀内功
			szShow = "Handle_QiXiu"
			szShowSub = "QX_"
		end
	end
	local handle = frame:Lookup("", "")

	local aShow =
	{
		"Handle_ChunYang",
		"Handle_ShaoLin",
		"Handle_TangMen",
		"Handle_QiXiu",
	}
	for k, v in pairs(aShow) do
		if szShow == v then
			handle:Lookup(v):Show()
		else
			handle:Lookup(v):Hide()
		end
	end

	this.szShow = szShow
	this.szShowSub = szShowSub
	
	if szShow == "Handle_ChunYang" or szShow == "Handle_ShaoLin" or szShow == "Handle_QiXiu"then
		Player.OnUpdateAccumulateValue(this)
	elseif szShow == "Handle_TangMen" then
		Player.OnUpdateTangmenEnergy(this)
	end
end
--player.nMaxEnergy=1000
function Player.OnUpdateAccumulateValue(frame)
	if not frame.szShow or frame.szShow == "" then
		return
	end
	local handle = frame:Lookup("", frame.szShow)
	if handle then
		local nValue = GetClientPlayer().nAccumulateValue
		if nValue < 0 then
			nValue = 0
		end
		if frame.szShow == "Handle_ShaoLin" then
			if nValue > 3 then
				nValue = 3
			end
			local szSub = frame.szShowSub
			for i = 1, nValue, 1 do
				handle:Lookup(szSub..i):Show()
			end
			for i = nValue + 1, 3, 1 do
				handle:Lookup(szSub..i):Hide()
			end
		elseif frame.szShow == "Handle_QiXiu" then
			local hText = handle:Lookup("Text_Layer")
			local hImage = handle:Lookup("Image_QX_Btn")
			if nValue > 10 then
				nValue = 10
			end
			if nValue > 0 then 
				hText:SetText(nValue)
				hText:Show()
				hImage.bChecked = true
			else
				hText:Hide()
				hImage.bChecked = false
			end
			UpdataQiXiuImage(hImage)
			
			local szSub = frame.szShowSub
			for i = 1, nValue, 1 do
				handle:Lookup(szSub..i):Show()
			end
			for i = nValue + 1, 10, 1 do
				handle:Lookup(szSub..i):Hide()
			end
		else
			if nValue > 10 then
				nValue = 10
			end
			nValue = nValue + 1
			local szSub = frame.szShowSub
			local aShow = Player.aAccumulateShow[nValue]
			local aHide = Player.aAccumulateHide[nValue]
			for k, v in pairs(aShow) do
				handle:Lookup(szSub..v):Show()
			end
			for k, v in pairs(aHide) do
				handle:Lookup(szSub..v):Hide()
			end
		end
	end
end

function Player.UpdateHeaderBg(frame, bHide)
	local fnVisible=function(szName, bShow)
		local img = frame:Lookup("", szName)
		img:Hide()
		if bShow then
			img:Show()
		end
	end
	
	fnVisible("Image_BackC_F", bHide)
	fnVisible("Image_BackR_F", bHide)
	fnVisible("Image_BackRR_F", bHide)
	fnVisible("Image_BackR2_F", bHide)
	fnVisible("Image_BackL_F", bHide)
	
	fnVisible("Image_BackL", not bHide)
	fnVisible("Image_BackC", not bHide)
	fnVisible("Image_BackR", not bHide)
	fnVisible("Image_BackRR", not bHide)
	fnVisible("Image_BackR2", not bHide)
end

function Player.HideMana(frame)
	local hImageMana = frame:Lookup("", "Image_Mana")
	local hTextMana  = frame:Lookup("", "Text_Mana")
	hImageMana:Hide();
	hTextMana:Hide();
	
	Player.UpdateHeaderBg(frame, true)
end

function Player.OnUpdateTangmenEnergy(frame)
	if not frame.szShow or frame.szShow ~= "Handle_TangMen" then
		return
	end
	
	local hList = frame:Lookup("", "Handle_TangMen")
	local textNumber = hList:Lookup("Text_Energy")
	local imgEnergy = hList:Lookup("Image_Strip")
	local imgFrame = hList:Lookup("Image_Frame")
	--nMaxEnergy
	--nCurrentEnergy
	--nEnergyReplenish
	local player = GetClientPlayer();
	if player.nMaxEnergy > 0 then
		local fPer = player.nCurrentEnergy / player.nMaxEnergy
		imgEnergy:SetPercentage(fPer)
		if IsShowStateValueByPercentage() then
	    	textNumber:SetText(string.format("%d%%", 100 * fPer))
	    else
	    	textNumber:SetText(player.nCurrentEnergy .. "/" .. player.nMaxEnergy)
	    end
	else
		imgEnergy:SetPercentage(0)
	    textNumber:SetText("")
	end

	Player.HideMana(frame)
end

function Player.OnFightFlagUpdate(frame)
	local img = frame:Lookup("", "Image_Fight")
	if GetClientPlayer().bFightState then
		img:Show()
		FireHelpEvent("OnEnterFight", img)
	else
		img:Hide()
	end
end

function Player.UpdatePlayerStateValueShow(frame)
	if IsPlayerShowStateValue() then
		frame:Lookup("", "Text_Health"):Show()
		frame:Lookup("", "Text_Mana"):Show()
	else
		frame:Lookup("", "Text_Health"):Hide()
		frame:Lookup("", "Text_Mana"):Hide()
	end
end

function Player.OnItemMouseEnter()
	if UserSelect.IsSelectCharacter() then
		UserSelect.SatisfySelectCharacter(TARGET.PLAYER, GetClientPlayer().dwID)
	end
	local szName = this:GetName()
	if szName == "Image_Health" then
		this:GetParent():Lookup("Text_Health"):Show()
	elseif szName == "Image_Mana" then
		this:GetParent():Lookup("Text_Mana"):Show()
	elseif szName == "Image_Camp" then
		local hPlayer = GetClientPlayer()
		local nX, nY = this:GetAbsPos()
		local nWidth, nHeight = this:GetSize()
		local szTip = GetFormatText(g_tStrings.STR_CAMP_TITLE[hPlayer.nCamp], 163)
		if hPlayer.bCampFlag then
			local szText = FormatString(g_tStrings.STR_SYS_MSG_OPEN_CAMP_FALG, "")
			szTip = szTip .. GetFormatText("\n" .. szText, 162)
			
			local nEndTime = GetCloseCampFlagTime()
			if nEndTime > 0 then
				local nCurTime = GetCurrentTime()
				if nCurTime < nEndTime then
					local szTime = GetTimeText(nEndTime - nCurTime, false, true, true, true)
					local szText = FormatString(g_tStrings.STR_SYS_MSG_WAIT_CLOSE_CAMP_FLAG, szTime)
					szTip = szTip .. GetFormatText(szText, 162)		
				end
			end
		end
		OutputTip(szTip, 200, {nX, nY, nWidth, nHeight})
	elseif szName == "Image_TeamCamp" then
		local hTeam = GetClientTeam()
		local nX, nY = this:GetAbsPos()
		local nWidth, nHeight = this:GetSize()
		local szTip = GetFormatText(g_tStrings.STR_IN_TEAM, 163)
		OutputTip(szTip, 200, {nX, nY, nWidth, nHeight})
	elseif szName == "Text_Others" or szName == "Image_Player" then
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
		local player = GetClientPlayer()
		local szTip = GetPlayerKungfuTip(player)
		OutputTip(szTip, 400, {x, y, w, h})
	elseif szName == "Image_QX_Btn" then
		this.bInside = true
		UpdataQiXiuImage(this)
	end
end

function Player.OnItemMouseLeave()
	HideTip()
	local szName = this:GetName()
	if szName == "Image_Health" then
		if not IsPlayerShowStateValue() then
			this:GetParent():Lookup("Text_Health"):Hide()
		end
	elseif szName == "Image_Mana" then
		if not IsPlayerShowStateValue() then
			this:GetParent():Lookup("Text_Mana"):Hide()
		end
	end
	if UserSelect.IsSelectCharacter() then
		UserSelect.SatisfySelectCharacter(TARGET.NO_TARGET, 0, true)
	end
	
	if szName == "Image_QX_Btn" then
		local nAccumulateValue = GetClientPlayer().nAccumulateValue
		this.bInside = false
		UpdataQiXiuImage(this)
	end
end

function Player.OnLButtonClick()
	local szName = this:GetName()
	
	if szName == "Btn_RoleChange" then
		Player.OnItemRButtonDown()
	end
end

function Player.OnItemLButtonUp()
	if this:GetName() == "Image_QX_Btn" then
		local nAccumulateValue = GetClientPlayer().nAccumulateValue
		if nAccumulateValue == 0 then 
			OnUseSkill(537, 0)
		else
			local buffList = GetClientPlayer().GetBuffList()
			local dwIndex
			for _,v in pairs(buffList) do
				if v.dwID == 409 then 
					dwIndex = v.nIndex
					break
				end
			end
			if dwIndex then 
				GetClientPlayer().CancelBuff(dwIndex)
			end
		end
		this.bClickDown = false
		UpdataQiXiuImage(this)
		return 
	end
end

function Player.OnItemLButtonDown()
	if this:GetName() == "Image_QX_Btn" then
		this.bClickDown = true
		UpdataQiXiuImage(this)
		return 
	end

	if UserSelect.DoSelectCharacter(TARGET.PLAYER, GetClientPlayer().dwID) then
		return
	end

	if IsCtrlKeyDown() then
		if IsGMPanelReceivePlayer(dwID) then
			GMPanel_LinkPlayerID(GetClientPlayer().dwID)
		else
			EditBox_AppendLinkPlayer(GetClientPlayer().szName)
		end
		return
	end

	SelectSelf()
end

function Player.OnItemRButtonDown()
	local menu = {}
	InsertPlayerMenu(menu)
	if menu and #menu > 0 then
		PopupMenu(menu)
	end
end

function Player.OnItemLButtonDBClick()
	if this:GetName() == "Image_NewPlayer" then
		OpenCharacterPanel()
	end
end

function Player.OnCheckBoxCheck()
	local szName = this:GetName()
	if szName == "CheckBox_SwitchSword" then
		local player = GetClientPlayer()
		if player and not player.bBigSwordSelected and player.bCanUseBigSword then
			RemoteCallToServer("OnSelectBigSword")
		end
	end
end

function Player.OnCheckBoxUncheck()
	local szName = this:GetName()
	if szName == "CheckBox_SwitchSword" then
		local player = GetClientPlayer()
		if player and player.bBigSwordSelected then
			RemoteCallToServer("OnSelectCommonWeapon")
		end
	end
end

function Player_GetFrame()
	return Station.Lookup("Normal/Player")
end

function UpdatePlayerImage()
	local player = GetClientPlayer()
	local image = Station.Lookup("Normal/Player", "Image_NewPlayer")

	DrawPlayerModelImage(player.dwID, SelfPortraitCameraInfo[player.nRoleType], image, true)
end

function IsPlayerShowStateValue()
	if Player.bShowStateValue then
		return true
	end
	return false
end

function SetPlayerShowStateValue(bShow)
	if Player.bShowStateValue == bShow then
		return
	end
	Player.bShowStateValue = bShow

	FireEvent("SET_SHOW_PLAYER_STATE_VALUE")
end

function IsShowStateValueByPercentage()
	if Player.bShowPercentage then
		return true
	end
	return false
end

function IsShowStateValueTwoFormat()
	if Player.bShowTwoFormat then
		return true
	end
	return false
end

function SetShowStateValueByPercentage(bPercentage)
	if Player.bShowPercentage == bPercentage then
		return
	end

	Player.bShowPercentage = bPercentage

	FireEvent("SET_SHOW_VALUE_BY_PERCENTAGE")
end

function SetShowStateValueTwoFormat(bShow)
	if Player.bShowTwoFormat == bShow then
		return
	end

	Player.bShowTwoFormat = bShow

	FireEvent("SET_SHOW_VALUE_TWO_FORMAT")
end

function Player_SetAnchorDefault()
	Player.Anchor.s = Player.DefaultAnchor.s
	Player.Anchor.r = Player.DefaultAnchor.r
	Player.Anchor.x = Player.DefaultAnchor.x
	Player.Anchor.y = Player.DefaultAnchor.y
	FireEvent("PLAYER_ANCHOR_CHANGED")
end

RegisterEvent("CUSTOM_UI_MODE_SET_DEFAULT", Player_SetAnchorDefault)
