RoleChange = {
	nSchoolMiniAvatar = 2,
	nStandardMiniAvatar = 6,
	tAvatars = Table_GetPlayerMiniAvatars(),
}

local tForcePinyin = 
{
	[g_tStrings.tForceTitle[0]] = "jianghu",
	[g_tStrings.tForceTitle[1]] = "shaolin",
	[g_tStrings.tForceTitle[2]] = "wanhua",
	[g_tStrings.tForceTitle[3]] = "tiance",
	[g_tStrings.tForceTitle[4]] = "chunyang",
	[g_tStrings.tForceTitle[5]] = "qixiu",
	[g_tStrings.tForceTitle[6]] = "wudu",
	[g_tStrings.tForceTitle[8]] = "cangjian",
	[g_tStrings.tForceTitle[7]] = "tangmen",
}

local function GetForceTitlePinyin(dwForceID)
	local szName = g_tStrings.tForceTitle[dwForceID]
	if not szName  then
		szName = g_tStrings.tForceTitle[0]
	end
    if tForcePinyin[szName] then
		szName = tForcePinyin[szName]
	else
		szName = tForcePinyin[g_tStrings.tForceTitle[0]]
	end
	return szName
end

function RoleChange.GetRoleAvatarPath(szFileName)
	return "ui\\Image\\PlayerAvatar\\" .. szFileName
end

function RoleChange.GetSchoolAvatarPath(dwSchoolID)
	local szName = GetForceTitlePinyin(dwSchoolID).. ".tga"
	return RoleChange.GetRoleAvatarPath(szName)
end

function RoleChange.OnFrameCreate()
	this:RegisterEvent("CURRENT_PLAYER_FORCE_CHANGED")
	
	RoleChange.InitPanel(this)

	InitFrameAutoPosInfo(this, 1, nil, nil, function() CloseRoleChangePanel(true) end)
end

function RoleChange.OnEvent(event)
	if event == "CURRENT_PLAYER_FORCE_CHANGED" then
		RoleChange.InitPanel(this)
	end
end

function RoleChange.InitPanel(frame)
	local player = GetClientPlayer()
	if not player then
		return
	end
	
	local handle = frame:Lookup("", "")
	local tSchoolAvatars = Table_GetPlayerMiniAvatarsFromTypeAndKindID(player.nRoleType, player.dwForceID)
	local tStandardAvatars = Table_GetPlayerMiniAvatarsFromTypeAndKindID(player.nRoleType, 0)
	
	local img = handle:Lookup("Image_School0")
	img["dwForceID"] = player.dwForceID
	img["dwSchoolID"] = player.dwSchoolID
	img["tAvatar"] = {}
	img.tAvatar["dwID"] = 0
	if player.dwMiniAvatarID == 0 then
		img["bChecked"] = true
	else
		img["bChecked"] = false
	end
	
	for i = 1, RoleChange.nSchoolMiniAvatar do
		img = handle:Lookup("Image_School" .. i)
		local tAvatar = tSchoolAvatars[i]
		
		if player.dwForceID ~= 0 and player.dwMiniAvatarID == tAvatar.dwID then
			img["bChecked"] = true
		else
			img["bChecked"] = false
		end
		
		if player.dwForceID ~= 0 then
			img.tAvatar = tAvatar
		end
	end
	
	for i = 1, RoleChange.nStandardMiniAvatar do
		img = handle:Lookup("Image_Normal" .. i)
		local tAvatar = tStandardAvatars[i]
		
		if not tAvatar or player.dwMiniAvatarID ~= tAvatar.dwID then
			img["bChecked"] = false
		else
			img["bChecked"] = true
		end
		
		img.tAvatar = tAvatar
	end
	
	RoleChange.Update(frame)
end

function RoleChange.Update(frame, bFocus)
	local handle = frame:Lookup("", "")
	
	local img = handle:Lookup("Image_School0") 
	local imgFocus = handle:Lookup("Image_School0Focus")
	if img.bChecked then
		imgFocus:Show()
	else
		imgFocus:Hide()
	end
	if not bFocus then
		local szPath, nFrame = GetForceImage(img.dwForceID)
		img:FromUITex(szPath, nFrame)
	end
	
	for i = 1, RoleChange.nSchoolMiniAvatar do
		img = handle:Lookup("Image_School" .. i)
		if not img.tAvatar then
			break
		end
		imgFocus = handle:Lookup("Image_School" .. i .. "Focus")
		local tAvatar = img.tAvatar
		local szFileName = RoleChange.GetRoleAvatarPath(tAvatar.szFileName)
		
		if img.bChecked then
			imgFocus:Show()
		else
			imgFocus:Hide()
		end
		
		if not bFocus then
			img:FromTextureFile(szFileName)
		end
	end
	
	for i = 1, RoleChange.nStandardMiniAvatar do
		img = handle:Lookup("Image_Normal" .. i)
		imgFocus = handle:Lookup("Image_Normal" .. i .. "Focus")
		local tAvatar = img.tAvatar
		if not tAvatar then
			img:Hide()
			break
		else
			img:Show()
		end
		local szFileName = RoleChange.GetRoleAvatarPath(tAvatar.szFileName)
		if img.bChecked then
			imgFocus:Show()
		else
			imgFocus:Hide()
		end
		
		if not bFocus then
			img:FromTextureFile(szFileName)
		end
	end
end

function RoleChange.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_Cancel" or szName == "Btn_Close" then
		CloseRoleChangePanel()
	elseif szName == "Btn_Sure" then
		local img = RoleChange.FindCheckedImage(this:GetParent():Lookup("", ""))
		local dwAvatar = img.tAvatar.dwID
		RemoteCallToServer("OnSetMiniAvatar", dwAvatar)
		CloseRoleChangePanel()
	end
end

function RoleChange.OnItemLButtonDown()
	local handle = this:GetParent()
	local szName = this:GetName()
	local img = handle:Lookup(szName)
	if not img.tAvatar then
		return
	end
	
	local imgFocus = handle:Lookup(szName .. "Focus")
	if img.bChecked == false then
		imgFocus:Hide()
	end
end

function RoleChange.OnItemLButtonDBClick()
	if not this.tAvatar then
		return
	end

	local dwAvatar = this.tAvatar.dwID
	RemoteCallToServer("OnSetMiniAvatar", dwAvatar)
	CloseRoleChangePanel()
end

function RoleChange.OnItemLButtonUp()
	local handle = this:GetParent()
	local szName = this:GetName()
	local img = handle:Lookup(szName)
	if not img.tAvatar then
		return
	end
	
	local imgFocus = handle:Lookup(szName .. "Focus")
	if img.bChecked == false then
		local imgChecked = RoleChange.FindCheckedImage(handle)
		if imgChecked then
			imgChecked.bChecked = false
		end
		img.bChecked = true
		RoleChange.Update(handle:GetParent(), true)
	end
end

function RoleChange.OnItemMouseEnter()
	local handle = this:GetParent()
	local szName = this:GetName()
	local img = handle:Lookup(szName)
	if not img.tAvatar then
		return
	end
	
	local imgFocus = handle:Lookup(szName .. "Focus")
	if img.bChecked == false then
		imgFocus:Show()
	end
end

function RoleChange.OnItemMouseLeave()
	local handle = this:GetParent()
	local szName = this:GetName()
	local img = handle:Lookup(szName)
	if not img.tAvatar then
		return
	end
	
	local imgFocus = handle:Lookup(szName .. "Focus")
	if img.bChecked == false then
		imgFocus:Hide()
	end
end

function RoleChange.FindCheckedImage(handle)
	for i = 0, RoleChange.nSchoolMiniAvatar do
		local img = handle:Lookup("Image_School" .. i)
		if img.bChecked then
			return img
		end
	end
	
	for i = 1, RoleChange.nStandardMiniAvatar do
		local img = handle:Lookup("Image_Normal" .. i)
		if img.bChecked then
			return img
		end
	end
end

function IsRoleChangePanelOpened()
	local frame = Station.Lookup("Normal/RoleChange")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end

function OpenRoleChangePanel(bDisableSound)
	if IsRoleChangePanelOpened() then
		return
	end
	
	local player = GetClientPlayer()
	if not player then
		return
	end
	
	Wnd.OpenWindow("RoleChange")
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
end

function CloseRoleChangePanel(bDisableSound)
	if IsRoleChangePanelOpened() then
		Wnd.CloseWindow("RoleChange")
	end
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseAuction)
	end
end

function GetPlayerMiniAvatarFile(dwID, bOnline)
	if not RoleChange.tAvatars[dwID] then
		dwID = 1
	end
	local szName = RoleChange.tAvatars[dwID].szFileName
	if bOnline == false then
		szName = string.gsub(szName, "%.", "_0%.")
	end
	return RoleChange.GetRoleAvatarPath(szName)
end

function GetPlayerKungfuTip(player)
	if not player then
		return
	end

	local szTip = GetFormatText(g_tStrings.STR_CURRENT_KUNGFU, 59)
	local kungfuMount = player.GetKungfuMount()
	local szText = ""
	local dwSchoolID = 0
	local aKungfu, nKungfuCount = player.GetAllMountKungfu()
	
	for i, v in pairs(aKungfu) do
		local kf = GetSkill(i, v)
		aKungfu[i] = kf
	end
	
	if not kungfuMount then
		szText = GetFormatText(g_tStrings.STR_CURRENT_KUNGFU_NONE, 18)
		szTip = szTip .. szText
	else
		dwSchoolID = kungfuMount.dwBelongSchool
		local bFirst = true
		
		szText = GetFormatText(Table_GetSkillSchoolName(dwSchoolID), 18, Table_GetSchoolColor(dwSchoolID))
		szTip = szTip .. szText
		szTip = szTip .. GetFormatText("£¨", 18)
        local tSkillInfo = Table_GetSkill(kungfuMount.dwSkillID, kungfuMount.dwLevel)
		szTip = szTip .. GetFormatText(tSkillInfo.szName, 18)
--		for i, kf in pairs(aKungfu) do
--			if kf.dwBelongSchool == dwSchoolID then
--				if not bFirst then
--					szTip = szTip .. GetFormatText("¡¢", 18)
--				end
--				bFirst = false
--				szTip = szTip .. GetFormatText(kf.szSkillName, 18)
--			end
--		end
		szTip = szTip .. GetFormatText("£©\n", 18)
	end
	
	szTip = szTip .. GetFormatText(g_tStrings.STR_OTHER_KUNGFU, 59)
	local tMark = {}
	local bExistOthers = false
	for i, v in pairs(aKungfu) do
		if v.dwBelongSchool ~= dwSchoolID and not tMark[i] then
			tMark[i] = true
			bTotalFirst = false
			bExistOthers = true
			szText = GetFormatText(Table_GetSkillSchoolName(v.dwBelongSchool), 18, Table_GetSchoolColor(v.dwBelongSchool))
			szTip = szTip .. szText
			szTip = szTip .. GetFormatText("£¨", 18)
            local tSkillInfo = Table_GetSkill(v.dwSkillID, v.dwLevel)
			szTip = szTip .. GetFormatText(tSkillInfo.szName, 18)
			for j, kf in pairs(aKungfu) do
				if not tMark[j] and kf.dwBelongSchool == v.dwBelongSchool then
					tMark[j] = true
					szTip = szTip .. GetFormatText("¡¢", 18)
                    local tSkillInfo = Table_GetSkill(kf.dwSkillID, kf.dwLevel)
					szTip = szTip .. GetFormatText(tSkillInfo.szName, 18)
				end
			end
			szTip = szTip .. GetFormatText("£©\n", 18)
		end
	end
	if not bExistOthers then
		szTip = szTip .. GetFormatText(g_tStrings.STR_CURRENT_KUNGFU_NONE, 18)
	end
	
	return szTip
end

function GetPlayerSchoolNumber(player)
	local aSchool = player.GetSchoolList()
	if aSchool then
		local nCount = 0
		for i, v in ipairs(aSchool) do
			if v ~= 0 then
				nCount = nCount + 1
			end
		end
		return nCount
	end
	return 0
end