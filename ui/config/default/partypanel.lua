PartyPanel = {}

RegisterCustomData("PartyPanel.aNear")

function PartyPanel.OnFrameCreate()
	this:RegisterEvent("PARTY_UPDATE_BASE_INFO")
	this:RegisterEvent("PARTY_ADD_MEMBER")
	this:RegisterEvent("PARTY_DELETE_MEMBER")
	this:RegisterEvent("PARTY_LOOT_MODE_CHANGED")
	this:RegisterEvent("PARTY_ROLL_QUALITY_CHANGED")
	this:RegisterEvent("PARTY_SET_MEMBER_ONLINE_FLAG")
	this:RegisterEvent("PARTY_DISBAND")
	this:RegisterEvent("TEAM_CHANGE_MEMBER_GROUP")
	this:RegisterEvent("TEAM_AUTHORITY_CHANGED")
	this:RegisterEvent("PARTY_SYNC_MEMBER_DATA")
	this:RegisterEvent("PARTY_SET_FORMATION_LEADER")
	this:RegisterEvent("PARTY_SET_MARK")
	
	this:RegisterEvent("PLAYER_FELLOWSHIP_UPDATE")
	this:RegisterEvent("PLAYER_FELLOWSHIP_CHANGE")
	this:RegisterEvent("PLAYER_FELLOWSHIP_LOGIN")
	this:RegisterEvent("PLAYER_FOE_UPDATE")
	this:RegisterEvent("PLAYER_BLACK_LIST_UPDATE")
	this:RegisterEvent("LATEST_CONTACT_PEOPLE_CHANGED")
	this:RegisterEvent("CUSTOM_DATA_LOADED")
	this:RegisterEvent("PARTY_LEVEL_UP_RAID")
	this:RegisterEvent("CHANGE_REFUSE_TEAM_INVITE_FLAG_NOTIFY")
	
	PartyPanel.UpdatePartyInfo(this)
	PartyPanel.UpdateFriend(this)
	PartyPanel.UpdateEnemy(this)
	PartyPanel.UpdateBlackList(this)
	PartyPanel.UpdateNear(this)
	
	local pageCompany = this:Lookup("PageSet_Main/Page_Company")
	local pageCompanySet = pageCompany:Lookup("PageSet_Company")
	local cbEnemy = pageCompanySet:Lookup("CheckBox_Enemy")
	if IsPlayerNeutral() then
		cbEnemy:Enable(false)
	else
		cbEnemy:Enable(true)
	end
	
	InitFrameAutoPosInfo(this, 1, nil, nil, function() ClosePartyPanel(true) end)
end

function PartyPanel.OnEvent(event)
	if event == "PLAYER_FELLOWSHIP_UPDATE" then
		PartyPanel.UpdateFriend(this)
	elseif event == "PLAYER_FELLOWSHIP_CHANGE" then
		PartyPanel.UpdateFriend(this)
	elseif event == "PLAYER_FELLOWSHIP_LOGIN" then
		PartyPanel.UpdateFriend(this)
	elseif event == "LATEST_CONTACT_PEOPLE_CHANGED" then
		PartyPanel.UpdateNear(this)
	elseif event == "PLAYER_FOE_UPDATE" then
		PartyPanel.UpdateEnemy(this)
	elseif event == "PLAYER_BLACK_LIST_UPDATE" then
		PartyPanel.UpdateBlackList(this)
	elseif event == "CUSTOM_DATA_LOADED" then
		PartyPanel.UpdateNear(this)
	elseif event == "CHANGE_REFUSE_TEAM_INVITE_FLAG_NOTIFY" then
		PartyPanel.UpdateInviteFlag(this)
	else
		PartyPanel.UpdatePartyInfo(this)
	end
end

function PartyPanel.UpdateInviteFlag(frame)
	local c = frame:Lookup("PageSet_Main/Page_Party/CheckBox_DisableInvite")
	c.bDisable = true
	local player = GetClientPlayer()
	if player and player.bRefuseTeamInvite then
		c:Check(true)
	else
		c:Check(false)
	end
	c.bDisable = false
end

function PartyPanel.OnCheckBoxCheck()
	local szName = this:GetName()
	if szName == "CheckBox_DisableInvite" then
		if not this.bDisable then
			RemoteCallToServer("OnSetRefuseTeamInvite", true)
		end
	end
end

function PartyPanel.OnCheckBoxUncheck()
	local szName = this:GetName()
	if szName == "CheckBox_DisableInvite" then
		if not this.bDisable then
			RemoteCallToServer("OnSetRefuseTeamInvite", false)
		end
	end
end

function PartyPanel.UpdatePartyInfo(frame)
	local page = frame:Lookup("PageSet_Main/Page_Party")
	local handle = page:Lookup("", "")
	local hList = handle:Lookup("Handle_Teammate")

	PartyPanel.UpdateInviteFlag(frame)
	
	local hPlayer = GetClientPlayer()
	if not hPlayer then
		return
	end
	
	local hTeam = GetClientTeam()
		
	local nQuality = hTeam.nRollQuality
	local szText, nFont = g_tStrings.STR_ROLLQUALITY_GREEN, 80
	if nQuality == 3 then
		szText, nFont = g_tStrings.STR_ROLLQUALITY_BLUE, 77
	elseif nQuality == 4 then
		szText, nFont = g_tStrings.STR_ROLLQUALITY_PURPLE, 74
	elseif nQuality == 5 then
		szText, nFont = g_tStrings.STR_ROLLQUALITY_NACARAT, 68
	end
	local text = handle:Lookup("Text_LootLevel")
	text:SetText(szText)
	text:SetFontScheme(nFont)

	local nMode = hTeam.nLootMode
	szText = g_tStrings.STR_LOOTMODE_FREE_FOR_ALL
	if nMode == PARTY_LOOT_MODE.DISTRIBUTE then
		szText = g_tStrings.STR_LOOTMODE_DISTRIBUTE
	elseif nMode == PARTY_LOOT_MODE.GROUP_LOOT then
		szText = g_tStrings.STR_LOOTMODE_GROUP_LOOT
	end
	handle:Lookup("Text_LootMode"):SetText(szText)
	
	if not hPlayer.IsInParty() then
		page:Lookup("Btn_Raid"):Enable(false)
		page:Lookup("Btn_LeaveParty"):Enable(false)
		page:Lookup("Btn_KickParty"):Enable(false)
		page:Lookup("Btn_ChangePartyLeader"):Enable(false)
		page:Lookup("Btn_InviteParty"):Enable(true)
		page:Lookup("Btn_LootModeSel"):Enable(false)
		page:Lookup("Btn_LootLevelSel"):Enable(false)

		local nCount = hList:GetItemCount() - 1
		for i = 0, nCount, 1 do
			hList:Lookup(i):Hide()
		end
		hList.dwID = nil
		return
	end
	
	local dwLeader = hTeam.GetAuthorityInfo(TEAM_AUTHORITY_TYPE.LEADER)
	local dwDistributeMan = hTeam.GetAuthorityInfo(TEAM_AUTHORITY_TYPE.DISTRIBUTE)
	local dwMarkMan = hTeam.GetAuthorityInfo(TEAM_AUTHORITY_TYPE.MARK)
	
	page:Lookup("Btn_Raid"):Enable(hPlayer.IsPartyLeader() and hTeam.nGroupNum <= 1 and hPlayer.nLevel >= CONVERT_RAID_PLAYER_MIN_LEVEL)
	page:Lookup("Btn_LeaveParty"):Enable(true)
	page:Lookup("Btn_KickParty"):Enable(hPlayer.IsPartyLeader())
	page:Lookup("Btn_ChangePartyLeader"):Enable(hPlayer.IsPartyLeader() and not hPlayer.IsPartyFull())
	page:Lookup("Btn_InviteParty"):Enable(hPlayer.IsPartyLeader())
	page:Lookup("Btn_LootModeSel"):Enable(dwDistributeMan == hPlayer.dwID)
	page:Lookup("Btn_LootLevelSel"):Enable(dwDistributeMan == hPlayer.dwID)
	
	local tPartyMark = hTeam.GetTeamMark() or {}
	
	hList:Clear()
	local nGroupNum = hTeam.nGroupNum
	for nGroupID = 0, nGroupNum - 1 do
		local tGroupInfo = hTeam.GetGroupInfo(nGroupID)
		local dwFormationLeader = tGroupInfo.dwFormationLeader
		if nGroupNum > 1 and #tGroupInfo.MemberList > 0 then
			local hGroupTitle = hList:AppendItemFromIni("UI/Config/default/PartyPanel.ini", "Handle_Member")
			hGroupTitle:Lookup("Text_Name"):SetText(g_tStrings.STR_TEAM .. g_tStrings.STR_NUMBER[nGroupID + 1])
			hGroupTitle:SetUserData(nGroupID * 100)
		end
		for i, dwID in ipairs(tGroupInfo.MemberList) do
			local hI = hList:AppendItemFromIni("UI/Config/default/PartyPanel.ini", "Handle_Member")
			hI.dwID = dwID
			hI.bTeammate = true
			
			local tMemberInfo = hTeam.GetMemberInfo(hI.dwID)
			
			local text = hI:Lookup("Text_Name")
			text:SetText("  " .. tMemberInfo.szName)
			
			if tMemberInfo.bIsOnLine then
				hI:SetUserData(nGroupID * 100 + 2)
				text:SetFontScheme(0)
			else
				hI:SetUserData(nGroupID * 100 + 3)
				text:SetFontScheme(61)
			end
			
			if dwID == dwLeader then
				hI:SetUserData(nGroupID * 100 + 1)
				hI:Lookup("Image_Flag"):Show()
			else
				hI:Lookup("Image_Flag"):Hide()
			end
			
			if dwID == dwFormationLeader then
				hI:Lookup("Image_Center"):Show()
			else
				hI:Lookup("Image_Center"):Hide()
			end
	
			if dwID == dwDistributeMan then
				hI:Lookup("Image_Boss"):Show()
			else
				hI:Lookup("Image_Boss"):Hide()
			end
			
			if dwID == dwMarkMan then
				hI:Lookup("Image_Mark"):Show()
			else
				hI:Lookup("Image_Mark"):Hide()
			end
			
			local hImageMark = hI:Lookup("Image_PartyMark")
			local nMarkID = tPartyMark[dwID]
			if nMarkID then
				assert(nMarkID > 0 and nMarkID <= #PARTY_MARK_ICON_FRAME_LIST)
				nIconFrame = PARTY_MARK_ICON_FRAME_LIST[nMarkID]
				hImageMark:FromUITex(PARTY_MARK_ICON_PATH, nIconFrame)
				hImageMark:Show()
			else
				hImageMark:Hide()
			end
		end
	end
	hList:Sort()
	hList:FormatAllItemPos()
	
	PartyPanel.UpdatePartyScrollInfo(hList)
	
	local nCount = hList:GetItemCount()
	local hSel = nil
	for i = 0, nCount - 1 do
		local hI = hList:Lookup(i)
		if hI.dwID == hList.dwID then
			hSel = hI
			break
		end
		if not hSel then
			hSel = hI
		end
	end
	if hSel then
		PartyPanel.SelTeammate(hSel)
	end
	
end

function PartyPanel.GetAttractionLevel(attraction)
	local nLevel, fP = 1, 0
	if attraction <= 100 then
		nLevel, fP = 1, math.max(attraction / 100, 0)
	elseif attraction <= 200 then
		nLevel, fP = 2, (attraction - 100) / 100
	elseif attraction <= 300 then
		nLevel, fP = 3, (attraction - 200) / 100
	elseif attraction <= 500 then
		nLevel, fP = 4, (attraction - 300) / 200
	elseif attraction <= 800 then
		nLevel, fP = 5, (attraction - 500) / 300
	else
		nLevel, fP = 6, math.min(1, (attraction - 800) / 200)
	end
	return nLevel, fP
end

function PartyPanel.UpdateFriendInfo(hI)
	local aInfo = hI.aInfo
	
	local textN = hI:Lookup("Text_N")
	local textL = hI:Lookup("Text_L")

	local bOnline = aInfo.level ~= 0
	local nFont = PartyPanel.GetFellowFont(bOnline, aInfo.married, aInfo.brother)
	
	textN:SetFontScheme(nFont)
	textL:SetFontScheme(nFont)
	
	textN:SetText(aInfo.name)
	
	local szLevel = ""
	if bOnline then
		szLevel = FormatString(g_tStrings.STR_FRIEND_WTHAT_LEVEL, aInfo.level)
	end
	textL:SetText(szLevel)
	
	local szPath, nFrame = GetForceImage(aInfo.forceid) 
	local imgSchool = hI:Lookup("Image_School")
	imgSchool:FromUITex(szPath, nFrame)
	
	local imgBgNormal = hI:Lookup("Image_Attraction1")
	local imgBgMarried = hI:Lookup("Image_Attraction2")
	local nFrame = 50
	if aInfo.married then
		imgBgNormal:Hide()
		imgBgMarried:Show()
		nFrame = 47
	elseif aInfo.brother then
		imgBgNormal:Hide()
		imgBgMarried:Show()
		nFrame = 51
	else
		imgBgNormal:Show()
		imgBgMarried:Hide()
	end
	local nLevel, fP = PartyPanel.GetAttractionLevel(aInfo.attraction)
	for i = 1, nLevel, 1 do
		local img = hI:Lookup(i.."H")
		img:SetFrame(nFrame)
		img:Show()
		if i == nLevel then
			img:SetPercentage(fP)
		else
			img:SetPercentage(1)
		end
	end
	for i = nLevel + 1, 7, 1 do
		hI:Lookup(i.."H"):Hide()
	end
end

function PartyPanel.UpdateFriendShow(hI)
	local img = nil
	if hI.bFriendGroup then
	 	img = hI:Lookup("Image_O")
	else
		img = hI:Lookup("Image_S")
	end
	
	if not img then
		return
	end
	
	if hI.bSel then
		img:Show()
		img:SetAlpha(255)
	elseif hI.bOver then
		img:Show()
		img:SetAlpha(128)
	else
		img:Hide()
	end
end

function PartyPanel.UpdateFriendContentShow(frame)
	local bVisible = false
	local pageSet = frame:Lookup("PageSet_Main")
	local pageCompany = pageSet:Lookup("Page_Company")
	if pageSet:GetActivePage() == pageCompany then
		local pageCompanySet = pageCompany:Lookup("PageSet_Company")
		local pageFriend = pageCompanySet:Lookup("Page_Friend")
		if pageCompanySet:GetActivePage() == pageFriend then
			local hList = pageFriend:Lookup("", "")
			if not hList.bFriendGroup and hList.name then
				bVisible = true
			end
		end
	end
	
	if not bVisible then
		PartyPanel.HideFriendContent(frame)
	end
end

function PartyPanel.ShowFriendContent(frame)
	local page = frame:Lookup("Wnd_FriendInfo")
	if page:IsVisible() then
		return
	end
	page:Show()
	frame:SetSize(460, 544)
	CorrectAutoPosFrameAfterClientResize()
end

function PartyPanel.HideFriendContent(frame)
	local page = frame:Lookup("Wnd_FriendInfo")
	if not page:IsVisible() then
		return
	end
	page:Hide()
	frame:SetSize(230, 544)
	CorrectAutoPosFrameAfterClientResize()
end

function PartyPanel.UpdateFriendContent(frame, dwID, nGroup)
	local player = GetClientPlayer()
	local aInfo = player.GetFellowshipData(dwID)
	if not aInfo then
		return
	end
	
	local page = frame:Lookup("Wnd_FriendInfo")
	page.dwID, page.nGroup, page.remark, page.name = dwID, nGroup, aInfo.remark, aInfo.name
	local handle = page:Lookup("", "")
	local hInfo = handle:Lookup("Handle_Info")
	
	local textN = hInfo:Lookup("Text_FriendName")
	local textL = hInfo:Lookup("Text_FriendLevel")
	local textA = hInfo:Lookup("Text_FriendAttraction")
	local textM = hInfo:Lookup("Text_FriendMap")
	local textS = hInfo:Lookup("Text_FriendSchool")

	local bOnline = aInfo.level ~= 0
	local nFont = PartyPanel.GetFriendFont(bOnline, aInfo.married, aInfo.brother)	
	textN:SetFontScheme(nFont)
	
	textN:SetText(aInfo.name)
	
	local szLevel = ""
	if bOnline then
		szLevel = FormatString(g_tStrings.STR_FRIEND_WTHAT_LEVEL, aInfo.level)
	end
	textL:SetText(szLevel)

    local nLevel = PartyPanel.GetAttractionLevel(aInfo.attraction)
    local szLevel = g_tStrings.tAttractionLevel[nLevel].."("..aInfo.attraction..")"
	textA:SetText(szLevel)
	
	local szSchoolName = GetForceTitle(aInfo.forceid)
	textS:SetText(szSchoolName)
	
	local imgBgNormal = hInfo:Lookup("Image_AttractionBg1")
	local imgBgMarried = hInfo:Lookup("Image_Attractionbg2")
	local nFrame = 50
	if aInfo.married then
		imgBgNormal:Hide()
		imgBgMarried:Show()
		nFrame = 47
	elseif aInfo.brother then
		imgBgNormal:Hide()
		imgBgMarried:Show()
		nFrame = 51
	else
		imgBgNormal:Show()
		imgBgMarried:Hide()
	end
	
	local nLevel, fP = PartyPanel.GetAttractionLevel(aInfo.attraction)
	for i = 1, nLevel, 1 do
		local img = hInfo:Lookup("Image_Heart"..i)
		img:SetFrame(nFrame)
		img:Show()
		if i == nLevel then
			img:SetPercentage(fP)
		else
			img:SetPercentage(1)
		end
	end
	for i = nLevel + 1, 7, 1 do
		hInfo:Lookup("Image_Heart"..i):Hide()
	end
	
	local szMap = ""
	if not bOnline then
	    szMap = g_tStrings.STR_FRIEND_NOT_ON_LINE
	elseif aInfo.attraction >= 0 then
        if aInfo.mapid == 0 then
            szMap = g_tStrings.STR_FRIEND_CANNOT_KNOW_WHAT_MAP_CAMP
        else
            szMap = Table_GetMapName(aInfo.mapid)
        end
	else
	    szMap = g_tStrings.STR_FRIEND_CANNOT_KNOW_WHAT_MAP
	end
	textM:SetText(szMap)
	
	if aInfo.remark == "" then
	    aInfo.remark = g_tStrings.STR_FRIEND_INPUT_MARK
	end
	page:Lookup("Edit_Name"):SetText(aInfo.remark)
	
	local szGroup = ""
	if nGroup == 0 then
		szGroup = g_tStrings.STR_FRIEND_GOOF_FRIEND
	else
		szGroup = player.GetFellowshipGroupName(nGroup)
	end
	handle:Lookup("Text_Group"):SetText(szGroup)
end

function PartyPanel.SelFriend(hI)
	local hList = hI:GetParent()
	local nCount = hList:GetItemCount() - 1
	for i = 0, nCount, 1 do
		local hB = hList:Lookup(i)
		if hB.bSel then
			hB.bSel = false
			PartyPanel.UpdateFriendShow(hB)
			break
		end
	end
	
	hI.bSel = true
	PartyPanel.UpdateFriendShow(hI)
	
	if hI.bFriendGroup then
		hList.bFriendGroup = true
		hList.name = hI.name
	else
		hList.bFriendGroup = false
		hList.name = hI.aInfo.name
		PartyPanel.UpdateFriendContent(hList:GetRoot(), hI.aInfo.id, hI.nGroup)
	end
	PartyPanel.UpdateFriendContentShow(hList:GetRoot())
	hList:GetParent():Lookup("Btn_DelFriend"):Enable(not hI.bFriendGroup or hI.nGroup ~= 0)
end

function PartyPanel.UpdateFriendScrollInfo(hList)
	local page = hList:GetParent()
	local scroll = page:Lookup("Scroll_Friend")
	hList:FormatAllItemPos()
	local wAll, hAll = hList:GetAllItemSize()
    local w, h = hList:GetSize()
    local nCountStep = math.ceil((hAll - h) / 10)
    scroll:SetStepCount(nCountStep)
    if nCountStep > 0 then
    	scroll:Show()
    	page:Lookup("Btn_UpFriend"):Show()
    	page:Lookup("Btn_DownFriend"):Show()
    else
    	scroll:Hide()
    	page:Lookup("Btn_UpFriend"):Hide()
    	page:Lookup("Btn_DownFriend"):Hide()
    end
end

function PartyPanel.UpdateEnemyScrollInfo(hList)
	local page = hList:GetParent()
	local scroll = page:Lookup("Scroll_Enemy")
	hList:FormatAllItemPos()
	local wAll, hAll = hList:GetAllItemSize()
    local w, h = hList:GetSize()
    local nCountStep = math.ceil((hAll - h) / 10)
    scroll:SetStepCount(nCountStep)
    if nCountStep > 0 then
    	scroll:Show()
    	page:Lookup("Btn_UpEnemy"):Show()
    	page:Lookup("Btn_DownEnemy"):Show()
    else
    	scroll:Hide()
    	page:Lookup("Btn_UpEnemy"):Hide()
    	page:Lookup("Btn_DownEnemy"):Hide()
    end
end

function PartyPanel.UpdateBlackListScrollInfo(hList)
	local page = hList:GetParent()
	local scroll = page:Lookup("Scroll_BlackList")
	hList:FormatAllItemPos()
	local wAll, hAll = hList:GetAllItemSize()
    local w, h = hList:GetSize()
    local nCountStep = math.ceil((hAll - h) / 10)
    scroll:SetStepCount(nCountStep)
    if nCountStep > 0 then
    	scroll:Show()
    	page:Lookup("Btn_UpBlackList"):Show()
    	page:Lookup("Btn_DownBlackList"):Show()
    else
    	scroll:Hide()
    	page:Lookup("Btn_UpBlackList"):Hide()
    	page:Lookup("Btn_DownBlackList"):Hide()
    end
end

function PartyPanel.UpdateNearScrollInfo(hList)
	local page = hList:GetParent()
	local scroll = page:Lookup("Scroll_Near")
	hList:FormatAllItemPos()
	local wAll, hAll = hList:GetAllItemSize()
    local w, h = hList:GetSize()
    local nCountStep = math.ceil((hAll - h) / 10)
    scroll:SetStepCount(nCountStep)
    if nCountStep > 0 then
    	scroll:Show()
    	page:Lookup("Btn_UpNear"):Show()
    	page:Lookup("Btn_DownNear"):Show()
    else
    	scroll:Hide()
    	page:Lookup("Btn_UpNear"):Hide()
    	page:Lookup("Btn_DownNear"):Hide()
    end
end

function PartyPanel.UpdatePartyScrollInfo(hList)
	local page = hList:GetParent():GetParent()
	local scroll = page:Lookup("Scroll_Party")
	local wAll, hAll = hList:GetAllItemSize()
    local w, h = hList:GetSize()
    local nCountStep = math.ceil((hAll - h) / 10)
    scroll:SetStepCount(nCountStep)
    if nCountStep > 0 then
    	scroll:Show()
    	page:Lookup("Btn_UpParty"):Show()
    	page:Lookup("Btn_DownParty"):Show()
    else
    	scroll:Hide()
    	page:Lookup("Btn_UpParty"):Hide()
    	page:Lookup("Btn_DownParty"):Hide()
    end
end

function PartyPanel.UpdateFriend(frame)
	local page = frame:Lookup("PageSet_Main/Page_Company/PageSet_Company/Page_Friend")
	local hList = page:Lookup("", "")
	
	hList:Clear()
	local aClose, aCloseF = hList.aClose or {}, {}
	local szIniFile = "UI/Config/default/PartyPanel.ini"
	local player = GetClientPlayer()
	local aGroup = player.GetFellowshipGroupInfo()
	aGroup = aGroup or {}
	table.insert(aGroup, 1, {id = 0, name = g_tStrings.STR_FRIEND_GOOF_FRIEND})
	local nIndex = 0
	for k, v in ipairs(aGroup) do
		hList:AppendItemFromIni(szIniFile, "Handle_T")
		local hI = hList:Lookup(nIndex)
		nIndex = nIndex + 1
		hI.bFriendGroup = true
		hI.nGroup = v.id
		hI.name = v.name
		hI:Lookup("Text_T"):SetText(v.name)
		if aClose[v.name] then
			aCloseF[v.name] = true
			hI:Collapse()
		else
			hI:Expand()
		end
		
		local aFriend = player.GetFellowshipInfo(v.id) or {}
		for i, aInfo in ipairs(aFriend) do
			hList:AppendItemFromIni(szIniFile, "Handle_C")
			local hI = hList:Lookup(nIndex)
			nIndex = nIndex + 1
			hI.bFriend = true
			hI.nGroup = v.id
			hI.aInfo = aInfo
			PartyPanel.UpdateFriendInfo(hI)
		end
	end
	hList.aClose = aCloseF
	
	PartyPanel.UpdateFriendScrollInfo(hList)
	
	local hSel = nil
	local nCount = hList:GetItemCount() - 1
	for i = 0, nCount, 1 do
		local hI = hList:Lookup(i)
		if hI.bFriendGroup then
			if hList.bFriendGroup and hI.name == hList.name then
				hSel = hI
				break
			end
		else
			if not hList.bFriendGroup and hI.aInfo.name == hList.name then
				hSel = hI
				break
			end		
		end
	end
	if hSel then
		PartyPanel.SelFriend(hSel)
	else
		hList.bFriendGroup, hList.name = nil, nil
		page:Lookup("Btn_DelFriend"):Enable(false)
	end
	PartyPanel.UpdateFriendContentShow(frame)
end

function PartyPanel.UpdateEnemyShow(hI)
	local img = hI:Lookup("Image_SE")
	if hI.bSel then
		img:Show()
		img:SetAlpha(255)
	elseif hI.bOver then
		img:Show()
		img:SetAlpha(128)
	else
		img:Hide()
	end	
end

function PartyPanel.SelEnemy(hI)
	local hList = hI:GetParent()
	local nCount = hList:GetItemCount() - 1
	for i = 0, nCount, 1 do
		local hB = hList:Lookup(i)
		if hB.bSel then
			hB.bSel = false
			PartyPanel.UpdateEnemyShow(hB)
			break
		end
	end
	
	hI.bSel = true
	PartyPanel.UpdateEnemyShow(hI)
	
	hList.name = hI.aInfo.name
	hList:GetParent():Lookup("Btn_DelEnemy"):Enable(true)
end


function PartyPanel.UpdateEnemyInfo(hI)
	local textN = hI:Lookup("Text_NE")
	local textL = hI:Lookup("Text_LE")
	
	local bOnline = hI.aInfo.level ~= 0
	local nFont = PartyPanel.GetFellowFont(bOnline)
	
	textN:SetFontScheme(nFont)
	textL:SetFontScheme(nFont)
	
	textN:SetText(hI.aInfo.name)
	local szLevel = ""
	if bOnline then
		szLevel = FormatString(g_tStrings.STR_FRIEND_WTHAT_LEVEL, hI.aInfo.level)
	end
	textL:SetText(szLevel)
	
	local imgSchool = hI:Lookup("Image_SchoolE")
	imgSchool:Show()
	local szPath, nFrame = GetForceImage(hI.aInfo.forceid) 
	imgSchool:FromUITex(szPath, nFrame)
	
	local nEnemyCamp = hI.aInfo.camp
	local imgCampERen = hI:Lookup("Image_Camp_ERren")
	local imgCampHaoqi = hI:Lookup("Image_Camp_Haoqi")
	if nEnemyCamp == 1 then
		imgCampERen:Hide()
		imgCampHaoqi:Show()
	elseif nEnemyCamp == 2 then
		imgCampERen:Show()
		imgCampHaoqi:Hide()
	else
		imgCampERen:Hide()
		imgCampHaoqi:Hide()
	end
end

function PartyPanel.UpdateEnemy(frame)
	local page = frame:Lookup("PageSet_Main/Page_Company/PageSet_Company/Page_Enemy")
	local hList = page:Lookup("", "")
	
	hList:Clear()
	local szIniFile = "UI/Config/default/PartyPanel.ini"
	local player = GetClientPlayer()
	local aEnemy = player.GetFoeInfo()
	aEnemy = aEnemy or {}

	local nIndex = 0
	for k, v in ipairs(aEnemy) do
		hList:AppendItemFromIni(szIniFile, "Handle_E")
		local hI = hList:Lookup(nIndex)
		nIndex = nIndex + 1
		hI.bEnemy = true
		hI.aInfo = v
		PartyPanel.UpdateEnemyInfo(hI)
	end

	PartyPanel.UpdateEnemyScrollInfo(hList)

	local hSel = nil
	local nCount = hList:GetItemCount() - 1
	for i = 0, nCount, 1 do
		local hI = hList:Lookup(i)
		if hI.aInfo.name == hList.name then
			hSel = hI
			break
		end
	end
	if hSel then
		PartyPanel.SelEnemy(hSel)
	else
		page:Lookup("Btn_DelEnemy"):Enable(false)
	end
		
    local bEnable = GetClientPlayer().CanAddFoe() and not IsPlayerNeutral()
    page:Lookup("Btn_AddEnemy"):Enable(bEnable)
end

function PartyPanel.UpdateBlackListShow(hI)
	local img = hI:Lookup("Image_SB")
	if hI.bSel then
		img:Show()
		img:SetAlpha(255)
	elseif hI.bOver then
		img:Show()
		img:SetAlpha(128)
	else
		img:Hide()
	end	
end

function PartyPanel.SelBlackList(hI)
	local hList = hI:GetParent()
	local nCount = hList:GetItemCount() - 1
	for i = 0, nCount, 1 do
		local hB = hList:Lookup(i)
		if hB.bSel then
			hB.bSel = false
			PartyPanel.UpdateBlackListShow(hB)
			break
		end
	end
	
	hI.bSel = true
	PartyPanel.UpdateBlackListShow(hI)
	
	hList.name = hI.aInfo.name
	hList:GetParent():Lookup("Btn_DelBlackList"):Enable(true)
end


function PartyPanel.UpdateBlackListInfo(hI)
	local textN = hI:Lookup("Text_NB")
	textN:SetFontScheme(nFont)	
	textN:SetText(hI.aInfo.name)
end

function PartyPanel.UpdateBlackList(frame)
	local page = frame:Lookup("PageSet_Main/Page_Company/PageSet_Company/Page_BlackList")
	local hList = page:Lookup("", "")
	
	hList:Clear()
	local szIniFile = "UI/Config/default/PartyPanel.ini"
	local player = GetClientPlayer()
	local aBlackList = player.GetBlackListInfo()
	aBlackList = aBlackList or {}

	local nIndex = 0
	for k, v in ipairs(aBlackList) do
		hList:AppendItemFromIni(szIniFile, "Handle_B")
		local hI = hList:Lookup(nIndex)
		nIndex = nIndex + 1
		hI.bBlackList = true
		hI.aInfo = v
		PartyPanel.UpdateBlackListInfo(hI)
	end

	PartyPanel.UpdateBlackListScrollInfo(hList)

	local hSel = nil
	local nCount = hList:GetItemCount() - 1
	for i = 0, nCount, 1 do
		local hI = hList:Lookup(i)
		if hI.aInfo.name == hList.name then
			hSel = hI
			break
		end
	end
	if hSel then
		PartyPanel.SelBlackList(hSel)
	else
		page:Lookup("Btn_DelBlackList"):Enable(false)
	end
end

function PartyPanel.UpdateNearShow(hI)
	local img = hI:Lookup("Image_SN")
	if hI.bSel then
		img:Show()
		img:SetAlpha(255)
	elseif hI.bOver then
		img:Show()
		img:SetAlpha(128)
	else
		img:Hide()
	end	
end

function PartyPanel.SelNear(hI)
	local hList = hI:GetParent()
	local nCount = hList:GetItemCount() - 1
	for i = 0, nCount, 1 do
		local hB = hList:Lookup(i)
		if hB.bSel then
			hB.bSel = false
			PartyPanel.UpdateNearShow(hB)
			break
		end
	end
	
	hI.bSel = true
	PartyPanel.UpdateNearShow(hI)
	
	hList.name = hI.name
end


function PartyPanel.UpdateNearInfo(hI)
	local textN = hI:Lookup("Text_NN")
	textN:SetFontScheme(nFont)	
	textN:SetText(hI.name)
end

function PartyPanel.UpdateNear(frame)
	local page = frame:Lookup("PageSet_Main/Page_Company/PageSet_Company/Page_Near")
	local hList = page:Lookup("", "")
	
	hList:Clear()
	local szIniFile = "UI/Config/default/PartyPanel.ini"
	local player = GetClientPlayer()
	local aNear = PartyPanel.aNear or {}

	local nCount = #aNear
	for i = nCount, 1, -1 do
		local hI = hList:AppendItemFromIni(szIniFile, "Handle_N")
		hI.bNear = true
		hI.name = aNear[i]
		PartyPanel.UpdateNearInfo(hI)
	end

	PartyPanel.UpdateNearScrollInfo(hList)

	local hSel = nil
	local nCount = hList:GetItemCount() - 1
	for i = 0, nCount, 1 do
		local hI = hList:Lookup(i)
		if hI.name == hList.name then
			hSel = hI
			break
		end
	end
	if hSel then
		PartyPanel.SelNear(hSel)
	end
end

function PartyPanel.UpdateTeammateShow(hI)
	local img = hI:Lookup("Image_Sel")
	if hI.bSel then
		img:Show()
		img:SetAlpha(255)
	elseif hI.bOver then
		img:Show()
		img:SetAlpha(128)
	else
		img:Hide()
	end
end

function PartyPanel.SelTeammate(hI)
	if not hI.bTeammate then
		return
	end
	
	local hList = hI:GetParent()
	local nCount = hList:GetItemCount() - 1
	for i = 0, nCount, 1 do
		local hB = hList:Lookup(i)
		hB.bSel = false
		PartyPanel.UpdateTeammateShow(hB)
	end
	hList.dwID = hI.dwID
	hI.bSel = true
	PartyPanel.UpdateTeammateShow(hI)
end

function PartyPanel.OnItemLButtonDown()
	if this.bTeammate then
		PartyPanel.SelTeammate(this)
	elseif this.bFriendGroup then
		PartyPanel.SelFriend(this)
		local hList = this:GetParent()
		if this:IsExpand() then
			this:Collapse()
			hList.aClose[this.name] = true
		else
			this:Expand()
			hList.aClose[this.name] = nil
		end
		PartyPanel.UpdateFriendScrollInfo(hList)
	elseif this.bFriend then
		PartyPanel.SelFriend(this)
	elseif this.bEnemy then
		PartyPanel.SelEnemy(this)
	elseif this.bBlackList then
		PartyPanel.SelBlackList(this)	
	elseif this.bNear then
		PartyPanel.SelNear(this)	
	end
end

function PartyPanel.OnItemLButtonClick()
	if this.bTeammate then
	elseif this.bFriend then
		PartyPanel.ShowFriendContent(this:GetRoot())
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
end

function PartyPanel.OnItemLButtonDBClick()
	if this.bPartyMember then
		EditBox_TalkToSomebody(GetTeammateName(this.dwID))
	elseif this.bFriendGroup then
		PartyPanel.OnItemLButtonDown()
	elseif this.bFriend then
		EditBox_TalkToSomebody(this.aInfo.name)
	elseif this.bEnemy then
		EditBox_TalkToSomebody(this.aInfo.name)
	elseif this.bBlackList then
		EditBox_TalkToSomebody(this.aInfo.name)
	elseif this.bNear then
		EditBox_TalkToSomebody(this.name)
	end
end
			
function PartyPanel.OnItemRButtonDown()
	if this.bTeammate then
		local hPlayer = GetClientPlayer()
		local tMenu = { fnAutoClose = function() if IsPartyPanelOpened() then return false else return true end end }	
		if this.dwID ~= hPlayer.dwID then
			InsertTeammateMenu(tMenu, this.dwID)
		else
			InsertPlayerMenu(tMenu)
		end
		PopupMenu(tMenu)
	elseif this.bFriendGroup then
		PartyPanel.OnItemLButtonDown()
		local bEnable = this.nGroup ~= 0
		local dwGroupID = this.nGroup
		local AddFriendGroup = function()
			GetUserInput(g_tStrings.STR_FRIEND_INPUT_G_NAME, function(szText) PartyPanel.AddOrRenameFriendGroup(szText) end, nil, nil, nil, nil, 15)
		end

		local DelFriendGroup = function()
			local msg =
			{
				szMessage = g_tStrings.STR_DEL_FRIEND_GROUP_SURE,
				szName = "DelFriendSure",
				{szOption = g_tStrings.STR_HOTKEY_SURE, 
				    fnAction = function()
				        local bDel = GetClientPlayer().DelFellowshipGroup(dwGroupID)
				        if bDel then 
				            OutputMessage("MSG_SYS", g_tStrings.FELLOWSHIP_GROUP_SUCCESS_DEL) 
				        end
				    end 
				 },
				{szOption = g_tStrings.STR_HOTKEY_CANCEL},
			}
			MessageBox(msg)
		end

		local ChangeFriendGroupName = function()
			local szDefault = GetClientPlayer().GetFellowshipGroupName(dwGroupID)
			GetUserInput(g_tStrings.STR_FRIEND_INPUT_G_NAME, function(szText) PartyPanel.AddOrRenameFriendGroup(szText, true, szDefault, dwGroupID) end, nil, nil, nil, szDefault, 15)
		end

		local menu =
		{
			fnAutoClose = function() if IsPartyPanelOpened() then return false else return true end end,
			{szOption = g_tStrings.STR_FRIEND_ADD_G, fnAction = AddFriendGroup },
			{szOption = g_tStrings.STR_FRIEND_DEL_G, bDisable = not bEnable, fnAction = DelFriendGroup },
			{szOption = g_tStrings.STR_FRIEND_CHANG_G_NAME, bDisable = not bEnable, fnAction = ChangeFriendGroupName },
		}
		PopupMenu(menu)
	elseif this.bFriend then
		PartyPanel.OnItemLButtonDown()
		local dwFriendID = this.aInfo.id
		local dwFriendGroupID = this.nGroup
		local szFriendName = this.aInfo.name
		local pClientPlayer = GetClientPlayer()
		local DelFriend = function()
			local msg =
			{
				szMessage = g_tStrings.STR_DEL_FRIEND_SURE,
				szName = "DelFriendSure",
				{
				    szOption = g_tStrings.STR_HOTKEY_SURE, 
				    fnAction = function()
				    	FireEvent("DELETE_FELLOWSHIP") 
				        bResult = pClientPlayer.DelFellowship(dwFriendID) 
				        if bResult then
            			    local szFont = GetMsgFontString("MSG_SYS") 
            			    local szNameLink = MakeNameLink("["..szFriendName.."]", szFont)
            			    local szMsg = szNameLink.."<text>text="..EncodeComponentsString(g_tStrings.FELLOWSHIP_SUCCESS_DEL)..szFont.."</text>"
				            OutputMessage("MSG_SYS", szMsg, true)
				        end
				    end 
				},
				{szOption = g_tStrings.STR_HOTKEY_CANCEL},
			}
			MessageBox(msg)
		end

		local MoveToGroup = function(nGroup, szGroupName)
			local bResult = GetClientPlayer().SetFellowshipGroup(dwFriendID, dwFriendGroupID, nGroup)
			if bResult then   
			    local szFont = GetMsgFontString("MSG_SYS") 
			    local szNameLink = MakeNameLink("["..szFriendName.."]", szFont)
			    local szMsg = szNameLink..
			                    "<text>text="..
			                    EncodeComponentsString(
			                        FormatString(g_tStrings.FELLOWSHIP_GROUP_SUCCESS_SET, szGroupName)
			                        )..szFont..
			                    "</text>"
			                      
			    OutputMessage("MSG_SYS", szMsg, true)
			end
		end

		local menu =
		{
			fnAutoClose = function() if IsPartyPanelOpened() then return false else return true end end,
			{szOption = g_tStrings.STR_SAY_SECRET, fnAction = function() EditBox_TalkToSomebody(szFriendName) end},
			{szOption = g_tStrings.STR_MAKE_PARTY, bDisable = not CanMakeParty(), fnAction = function() GetClientTeam().InviteJoinTeam(szFriendName) AddContactPeople(szFriendName) end},
			{szOption = g_tStrings.STR_FRIEND_DEL, fnAction = DelFriend },
			{szOption = g_tStrings.STR_FRIEND_ADD_EMENY, bDisable = not pClientPlayer.CanAddFoe() or IsPlayerNeutral(), fnAction = function() RemoteCallToServer("OnPrepareAddFoe", szFriendName) end },
			{szOption = g_tStrings.INVITE_ADD_GUILD, bDisable = pClientPlayer.dwTongID == 0, fnAction = function() InvitePlayerJoinTong(szFriendName) end},
			{szOption = g_tStrings.STR_FRIEND_ADD_BLACKLIST, fnAction = function() GetClientPlayer().AddBlackList(szFriendName) if not GetClientPlayer().IsAchievementAcquired(981) then RemoteCallToServer("OnClientAddAchievement", "BlackList_First_Add") end end},
		}
		
		local a = {}
		local aGroup = GetClientPlayer().GetFellowshipGroupInfo() or {}
		table.insert(aGroup, 1, {id = 0, name = g_tStrings.STR_FRIEND_GOOF_FRIEND})
		for k, v in ipairs(aGroup) do
			if dwFriendGroupID ~= v.id then
				table.insert(a, {szOption = v.name, fnAction = function() MoveToGroup(v.id, v.name) end })
			end
		end
		if #a > 0 then
			a.szOption = g_tStrings.STR_FRIEND_MOVE_TO
			table.insert(menu, a)
		end
		PopupMenu(menu)
	elseif this.bEnemy then
		PartyPanel.OnItemLButtonDown()
	    local nEnemyId = this.aInfo.id
	    local szEnemyName = this.aInfo.name
		local menu =
		{
			fnAutoClose = function() if IsPartyPanelOpened() then return false else return true end end,
			{
			    szOption = g_tStrings.STR_FRIEND_DEL_EMENY,
			    fnAction = function() 
			        local bResult = DelFoe(nEnemyId) 
			        if bResult then
        			    local szFont = GetMsgFontString("MSG_SYS") 
        			    local szNameLink = MakeNameLink("["..szEnemyName.."]", szFont)
        			    local szMsg = szNameLink.."<text>text="..EncodeComponentsString(g_tStrings.FELLOWSHIP_SUCCESS_DEL_FOE)..szFont.."</text>"
    		            OutputMessage("MSG_SYS", szMsg, true)
			        end
			    end
			},
		}
		PopupMenu(menu)
	elseif this.bBlackList then
		PartyPanel.OnItemLButtonDown()
	    local nBlackListId = this.aInfo.id
	    local szBlackListName = this.aInfo.name
	    
		local menu =
		{
			fnAutoClose = function() if IsPartyPanelOpened() then return false else return true end end,
			{
			    szOption = g_tStrings.STR_FRIEND_DEL_BLACKLIST,
			    fnAction = function() 
			        local bResult = GetClientPlayer().DelBlackList(nBlackListId) 
			        if bResult then
        			    local szFont = GetMsgFontString("MSG_SYS") 
        			    local szNameLink = MakeNameLink("["..szBlackListName.."]", szFont)
        			    local szMsg = szNameLink.."<text>text="..EncodeComponentsString(g_tStrings.FELLOWSHIP_SUCCESS_DEL_BLACK_LIST)..szFont.."</text>"
    		            OutputMessage("MSG_SYS", szMsg, true)
			        end
			    end
			},
		}
		PopupMenu(menu)
	elseif this.bNear then
		PartyPanel.OnItemLButtonDown()
		local szFriendName = this.name

		local menu =
		{
			fnAutoClose = function() if IsPartyPanelOpened() then return false else return true end end,
			{szOption = g_tStrings.STR_SAY_SECRET, fnAction = function() EditBox_TalkToSomebody(szFriendName) end},
			{szOption = g_tStrings.STR_MAKE_PARTY, bDisable = not CanMakeParty(), fnAction = function() GetClientTeam().InviteJoinTeam(szFriendName) AddContactPeople(szFriendName) end},
			{szOption = g_tStrings.INVITE_ADD_GUILD, bDisable = GetClientPlayer().dwTongID == 0, fnAction = function() InvitePlayerJoinTong(szFriendName) end},
			{szOption = g_tStrings.STR_MAKE_FRIEND, fnAction = function() GetClientPlayer().AddFellowship(szFriendName) end },
		}
		PopupMenu(menu)
	end
end

function PartyPanel.OnMouseEnter()
	if this:GetName() == "CheckBox_Enemy" then
		if IsPlayerNeutral() then
			local x, y = this:GetAbsPos()
			local w, h = this:GetSize()
			local szTip = "<text>text=".. EncodeComponentsString(g_tStrings.STR_ADD_FOE_CONDITION).." font=162 </text>"
			OutputTip(szTip, 345, {x, y, w, h})
		end
	end
end

function PartyPanel.OnMouseLeave()
	HideTip()
end

function PartyPanel.OnItemMouseEnter()
	if this.bTeammate then
		this.bOver = true
		PartyPanel.UpdateTeammateShow(this)
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
		OutputTeamMemberTip(this.dwID, {x, y, w, h})
	elseif this.bFriendGroup then
		this.bOver = true
		PartyPanel.UpdateFriendShow(this)
	elseif this.bFriend then
		this.bOver = true
		PartyPanel.UpdateFriendShow(this)		
	elseif this.bEnemy then
		this.bOver = true
		PartyPanel.UpdateEnemyShow(this)
	elseif this.bBlackList then
		this.bOver = true
		PartyPanel.UpdateBlackListShow(this)
	elseif this.bNear then
		this.bOver = true
		PartyPanel.UpdateNearShow(this)
	end
end

function PartyPanel.OnSetFocus()
    if this:GetName() == "Edit_Name" then
        szText = this:GetText()
        if szText  == g_tStrings.STR_FRIEND_INPUT_MARK then
            this:SetText("")
        end
    end
end

function PartyPanel.OnKillFocus()
    if this:GetName() == "Edit_Name" then
        hPage = this:GetRoot():Lookup("Wnd_FriendInfo")
        szText = hPage:Lookup("Edit_Name"):GetText()
		if szText ~= hPage.remark then
            GetClientPlayer().SetFellowshipRemark(hPage.dwID, szText)
        end
    end
end

function PartyPanel.OnItemMouseLeave()
	if this.bTeammate then
		this.bOver = false
		PartyPanel.UpdateTeammateShow(this)		
		HideTip()
	elseif this.bFriendGroup then
		this.bOver = false
		PartyPanel.UpdateFriendShow(this)
	elseif this.bFriend then
		this.bOver = false
		PartyPanel.UpdateFriendShow(this)
	elseif this.bEnemy then
		this.bOver = false
		PartyPanel.UpdateEnemyShow(this)
	elseif this.bBlackList then
		this.bOver = false
		PartyPanel.UpdateBlackListShow(this)
	elseif this.bNear then
		this.bOver = false
		PartyPanel.UpdateNearShow(this)		
	end
end

function PartyPanel.OnActivePage()
	local nLast = this:GetLastActivePageIndex()
	local nPage = this:GetActivePageIndex()
	if nLast ~= -1 and nPage ~= nLast then
		PlaySound(SOUND.UI_SOUND, g_sound.OpenFrame)
	end
	PartyPanel.UpdateFriendContentShow(this:GetRoot())
end

function PartyPanel.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_InviteParty" then
		if IsAddFriendPanelOpened("party") then
			CloseAddFriendPanel()
		else
			OpenAddFriendPanel("party")
		end
	elseif szName == "Btn_Raid" then
		ConvertToRaid()
	elseif szName == "Btn_LeaveParty" then
		GetClientTeam().RequestLeaveTeam()
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
	elseif szName == "Btn_KickParty" then
		local hList = this:GetParent():Lookup("", "Handle_Teammate")
		GetClientTeam().TeamKickoutMember(GetTeammateName(hList.dwID))
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
	elseif szName == "Btn_ChangePartyLeader" then
		local hList = this:GetParent():Lookup("", "Handle_Teammate")
		GetClientTeam().SetAuthorityInfo(TEAM_AUTHORITY_TYPE.LEADER, hList.dwID)
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
	elseif szName == "Btn_Close" then
		ClosePartyPanel()

	-------------------好友相关-------------------------------
	elseif szName == "Btn_AddFriend" then
		if IsAddFriendPanelOpened("friend") then
			CloseAddFriendPanel()
		else
			OpenAddFriendPanel("friend")
		end
	elseif szName == "Btn_DelFriend" then
		local hList = this:GetParent():Lookup("", "")
		local nCount = hList:GetItemCount() - 1
		for i = 0, nCount, 1 do
			local hI = hList:Lookup(i)
			if hI.bSel then
				if hI.bFriendGroup then
					local nDelGroup = hI.nGroup
					local msg =
					{
						szMessage = g_tStrings.STR_DEL_FRIEND_GROUP_SURE,
						szName = "DelFriendSure",
						{szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = function() GetClientPlayer().DelFellowshipGroup(nDelGroup) end },
						{szOption = g_tStrings.STR_HOTKEY_CANCEL},
					}
					MessageBox(msg)
				else
					local dwDelID, nDelGroup = hI.aInfo.id, hI.nGroup
					local szFriendName = hI.aInfo.name
					local msg =
					{
						szMessage = g_tStrings.STR_DEL_FRIEND_SURE,
						szName = "DelFriendSure",
						{
							szOption = g_tStrings.STR_HOTKEY_SURE, 
							fnAction = function()
								FireEvent("DELETE_FELLOWSHIP")
								local bResult = GetClientPlayer().DelFellowship(dwDelID)
				        			if bResult then
            			    					local szFont = GetMsgFontString("MSG_SYS") 
            			    					local szNameLink = MakeNameLink("["..szFriendName.."]", szFont)
            			    					local szMsg = szNameLink.."<text>text="..EncodeComponentsString(g_tStrings.FELLOWSHIP_SUCCESS_DEL)..szFont.."</text>"
				            				OutputMessage("MSG_SYS", szMsg, true)
				        			end
							end 
						},
						{szOption = g_tStrings.STR_HOTKEY_CANCEL},
					}
					MessageBox(msg)
				end
				break
			end
		end
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
	elseif szName == "Btn_AddFriendGroup" then
		GetUserInput(g_tStrings.STR_FRIEND_INPUT_G_NAME, function(szText) PartyPanel.AddOrRenameFriendGroup(szText) end, nil, nil, nil, nil, 15)
	elseif szName == "Btn_AddEnemy" then
		if IsAddFriendPanelOpened("enemy") then
			CloseAddFriendPanel()
		else
			OpenAddFriendPanel("enemy")
		end
	elseif szName == "Btn_DelEnemy" then
		local hList = this:GetParent():Lookup("", "")
		local nCount = hList:GetItemCount() - 1
		for i = 0, nCount, 1 do
			local hI = hList:Lookup(i)
			if hI.bSel then
				local dwDelID = hI.aInfo.id
				local szEnemyName = hI.aInfo.name
		        local bResult = DelFoe(dwDelID) 
		        if bResult then
    			    local szFont = GetMsgFontString("MSG_SYS") 
    			    local szNameLink = MakeNameLink("["..szEnemyName.."]", szFont)
    			    local szMsg = szNameLink.."<text>text="..EncodeComponentsString(g_tStrings.FELLOWSHIP_SUCCESS_DEL_FOE)..szFont.."</text>"
		            OutputMessage("MSG_SYS", szMsg, true)
		        end
				break	
			end
		end
	elseif szName == "Btn_AddBlackList" then
		if IsAddFriendPanelOpened("blacklist") then
			CloseAddFriendPanel()
		else
			OpenAddFriendPanel("blacklist")
		end	
	elseif szName == "Btn_DelBlackList" then
		local hList = this:GetParent():Lookup("", "")
		local nCount = hList:GetItemCount() - 1
		for i = 0, nCount, 1 do
			local hI = hList:Lookup(i)
			if hI.bSel then
				local dwDelID = hI.aInfo.id
				local szBlackListName = hI.aInfo.name
		        local bResult = GetClientPlayer().DelBlackList(dwDelID) 
		        if bResult then
    			    local szFont = GetMsgFontString("MSG_SYS") 
    			    local szNameLink = MakeNameLink("["..szBlackListName.."]", szFont)
    			    local szMsg = szNameLink.."<text>text="..EncodeComponentsString(g_tStrings.FELLOWSHIP_SUCCESS_DEL_BLACK_LIST)..szFont.."</text>"
		            OutputMessage("MSG_SYS", szMsg, true)
		        end
				break	
			end
		end
	elseif szName == "Btn_CloseInfo" then
		PartyPanel.HideFriendContent(this:GetRoot())
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	elseif szName == "Btn_SendBrow" then
		if IsOpenEmotionPanel() then
	    	CloseEmotionPanel()
		else
			local x, y = this:GetAbsPos()
			local w, h = this:GetSize()
			OpenEmotionPanel(false, {x, y, w, h})
			EditBox_TalkToSomebody(this:GetParent().name)
		end
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
		return 1
	elseif szName == "Btn_AddParty" then
		GetClientTeam().InviteJoinTeam(this:GetParent().name)
		AddContactPeople(this:GetParent().name)
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
	elseif szName == "Btn_SendMessege" then
		EditBox_TalkToSomebody(this:GetParent().name)
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
	end
end

function PartyPanel.OnLButtonDown()
	local szName = this:GetName()
	if szName == "Btn_LootModeSel" then	--选择分配模式
		if this.bIgnor then
			this.bIgnor = nil
			return
		end

		if not this:IsEnabled() then
			return
		end

		local text = this:GetParent():Lookup("", "Text_LootMode")
		local xA, yA = text:GetAbsPos()
		local w, h = text:GetSize()
		local menu =
		{
			nMiniWidth = w,
			x = xA, y = yA + h,
			fnCancelAction = function()
				local btn = Station.Lookup("Normal/PartyPanel/Page_Main/Page_Party/Btn_LootModeSel")
				if btn then
					local x, y = Cursor.GetPos()
					local xA, yA = btn:GetAbsPos()
					local w, h = btn:GetSize()
					if x >= xA and x < xA + w and y >= yA and y <= yA + h then
						btn.bIgnor = true
					end
				end
			end,
			fnAutoClose = function() if IsPartyPanelOpened() then return false else return true end end,
			{szOption = g_tStrings.STR_LOOTMODE_FREE_FOR_ALL, fnAction = function() GetClientTeam().SetTeamLootMode(PARTY_LOOT_MODE.FREE_FOR_ALL) end },
			{szOption = g_tStrings.STR_LOOTMODE_DISTRIBUTE, fnAction = function() GetClientTeam().SetTeamLootMode(PARTY_LOOT_MODE.DISTRIBUTE) end },
			{szOption = g_tStrings.STR_LOOTMODE_GROUP_LOOT, fnAction = function() GetClientTeam().SetTeamLootMode(PARTY_LOOT_MODE.GROUP_LOOT) end }
		}
		PopupMenu(menu)
		return true
	elseif szName == "Btn_LootLevelSel" then --选择分配等级
		if this.bIgnor then
			this.bIgnor = nil
			return
		end
		if not this:IsEnabled() then
			return
		end

		local text = this:GetParent():Lookup("", "Text_LootLevel")
		local xA, yA = text:GetAbsPos()
		local w, h = text:GetSize()
		local menu =
		{
			nMiniWidth = w,
			x = xA, y = yA + h,
			fnCancelAction = function()
				local btn = Station.Lookup("Normal/PartyPanel/Page_Main/Page_Party/Btn_LootLevelSel")
				if btn then
					local x, y = Cursor.GetPos()
					local xA, yA = btn:GetAbsPos()
					local w, h = btn:GetSize()
					if x >= xA and x < xA + w and y >= yA and y <= yA + h then
						btn.bIgnor = true
					end
				end
			end,
			fnAutoClose = function() if IsPartyPanelOpened() then return false else return true end end,
			{szOption = g_tStrings.STR_ROLLQUALITY_GREEN, nFont = 80, fnAction = function() GetClientTeam().SetTeamRollQuality(2) end },
			{szOption = g_tStrings.STR_ROLLQUALITY_BLUE, nFont = 77, fnAction = function() GetClientTeam().SetTeamRollQuality(3) end },
			{szOption = g_tStrings.STR_ROLLQUALITY_PURPLE, nFont = 74, fnAction = function() GetClientTeam().SetTeamRollQuality(4) end },
			{szOption = g_tStrings.STR_ROLLQUALITY_NACARAT, nFont = 68, fnAction = function() GetClientTeam().SetTeamRollQuality(5) end }
		}
		PopupMenu(menu)
		return true
	elseif szName == "Btn_Group" then
		if this.bIgnor then
			this.bIgnor = nil
			return
		end
		if not this:IsEnabled() then
			return
		end
		
		local text = this:GetParent():Lookup("", "Text_Group")
		local xA, yA = text:GetAbsPos()
		local w, h = text:GetSize()
		local page = this:GetParent()
		local dwFriendID = page.dwID
		local dwFriendGroupID = page.nGroup
		
		local SelectGroup = function(nGroup)
			if nGroup == 0 then
				text:SetText(g_tStrings.STR_FRIEND_GOOF_FRIEND)
			else
				text:SetText(GetClientPlayer().GetFellowshipGroupName(nGroup))
			end
			GetClientPlayer().SetFellowshipGroup(dwFriendID, dwFriendGroupID, nGroup)
		end

		local menu = {}
		local aGroup = GetClientPlayer().GetFellowshipGroupInfo() or {}
		table.insert(aGroup, 1, {id = 0, name = g_tStrings.STR_FRIEND_GOOF_FRIEND})
		for k, v in ipairs(aGroup) do
			table.insert(menu, {szOption = v.name, UserData = v.id, fnAction = SelectGroup })
		end
		if #menu > 0 then
			menu.szOption = g_tStrings.STR_FRIEND_MOVE_TO
			menu.nMiniWidth = w
			menu.x = xA
			menu.y = yA + h
			menu.fnCancelAction = function()
				local btn = Station.Lookup("Normal/PartyPanel/Wnd_FriendInfo/Btn_Group")
				if btn then
					local x, y = Cursor.GetPos()
					local xA, yA = btn:GetAbsPos()
					local w, h = btn:GetSize()
					if x >= xA and x < xA + w and y >= yA and y <= yA + h then
						btn.bIgnor = true
					end
				end
			end
			menu.fnAutoClose = function() 
				return not  IsPartyPanelOpened()
			end
			PopupMenu(menu)
		end
		return true
	elseif szName == "Btn_UpFriend" then
		PartyPanel.OnLButtonHold()
	elseif szName == "Btn_DownFriend" then
		PartyPanel.OnLButtonHold()
	elseif szName == "Btn_UpEnemy" then
		PartyPanel.OnLButtonHold()
	elseif szName == "Btn_DownEnemy" then
		PartyPanel.OnLButtonHold()
	elseif szName == "Btn_UpBlackList" then
		PartyPanel.OnLButtonHold()
	elseif szName == "Btn_DownBlackList" then
		PartyPanel.OnLButtonHold()
	elseif szName == "Btn_UpNear" then
		PartyPanel.OnLButtonHold()
	elseif szName == "Btn_DownNear" then
		PartyPanel.OnLButtonHold()
	elseif szName == "Btn_UpParty" then
		PartyPanel.OnLButtonHold()
	elseif szName == "Btn_DownParty" then
		PartyPanel.OnLButtonHold()
	end
end

function PartyPanel.GetFellowFont(bOnline, bCouple, bBrother)
	local nFont = 0
	if bCouple then
		if bOnline then
			nFont = 162
		else
			nFont = 108
		end
	elseif bBrother then
		if bOnline then
			nFont = 162
		else
			nFont = 108
		end
	else
		if bOnline then
			nFont = 162
		else
			nFont = 108
		end
	end
	return nFont
end

function PartyPanel.GetFriendFont(bOnline, bCouple, bBrother)
	local nFont = 0
	if bCouple then
		if bOnline then
			nFont = 41
		else
			nFont = 30
		end
	elseif bBrother then
		if bOnline then
			nFont = 41
		else
			nFont = 30
		end
	else
		if bOnline then
			nFont = 41
		else
			nFont = 30
		end
	end
	return nFont
end

function PartyPanel.OnLButtonHold()
	local szName = this:GetName()
	if szName == "Btn_UpFriend" then
		this:GetParent():Lookup("Scroll_Friend"):ScrollPrev()
	elseif szName == "Btn_DownFriend" then
		this:GetParent():Lookup("Scroll_Friend"):ScrollNext()
	elseif szName == "Btn_UpEnemy" then
		this:GetParent():Lookup("Scroll_Enemy"):ScrollPrev()
	elseif szName == "Btn_DownEnemy" then
		this:GetParent():Lookup("Scroll_Enemy"):ScrollNext()
	elseif szName == "Btn_UpBlackList" then
		this:GetParent():Lookup("Scroll_BlackList"):ScrollPrev()
	elseif szName == "Btn_DownBlackList" then
		this:GetParent():Lookup("Scroll_BlackList"):ScrollNext()
	elseif szName == "Btn_UpNear" then
		this:GetParent():Lookup("Scroll_Near"):ScrollPrev()
	elseif szName == "Btn_DownNear" then
		this:GetParent():Lookup("Scroll_Near"):ScrollNext()
	elseif szName == "Btn_UpParty" then
		this:GetParent():Lookup("Scroll_Party"):ScrollPrev()
	elseif szName == "Btn_DownParty" then
		this:GetParent():Lookup("Scroll_Party"):ScrollNext()
	end
end

function PartyPanel.OnScrollBarPosChanged()
	local page = this:GetParent()
	local nCurrentValue = this:GetScrollPos()
	local szName = this:GetName()
	if szName == "Scroll_Friend" then
		page:Lookup("Btn_UpFriend"):Enable(nCurrentValue ~= 0)
		page:Lookup("Btn_DownFriend"):Enable(nCurrentValue ~= this:GetStepCount())
		page:Lookup("", ""):SetItemStartRelPos(0, - 10 * nCurrentValue)
	elseif szName == "Scroll_Enemy" then
		page:Lookup("Btn_UpEnemy"):Enable(nCurrentValue ~= 0)
		page:Lookup("Btn_DownEnemy"):Enable(nCurrentValue ~= this:GetStepCount())
		page:Lookup("", ""):SetItemStartRelPos(0, - 10 * nCurrentValue)
	elseif szName == "Scroll_BlackList" then
		page:Lookup("Btn_UpBlackList"):Enable(nCurrentValue ~= 0)
		page:Lookup("Btn_DownBlackList"):Enable(nCurrentValue ~= this:GetStepCount())
		page:Lookup("", ""):SetItemStartRelPos(0, - 10 * nCurrentValue)
	elseif szName == "Scroll_Near" then
		page:Lookup("Btn_UpNear"):Enable(nCurrentValue ~= 0)
		page:Lookup("Btn_DownNear"):Enable(nCurrentValue ~= this:GetStepCount())
		page:Lookup("", ""):SetItemStartRelPos(0, - 10 * nCurrentValue)
	elseif szName == "Scroll_Party" then
		page:Lookup("Btn_UpParty"):Enable(nCurrentValue ~= 0)
		page:Lookup("Btn_DownParty"):Enable(nCurrentValue ~= this:GetStepCount())
		page:Lookup("", "Handle_Teammate"):SetItemStartRelPos(0, - 10 * nCurrentValue)
	end
end

function PartyPanel.OnItemMouseWheel()
	local nDistance = Station.GetMessageWheelDelta()
	local page = this:GetParent()
	local szName = page:GetName()
	if szName == "Page_Friend" then
		page:Lookup("Scroll_Friend"):ScrollNext(nDistance)
	elseif szName == "Page_Enemy" then
		page:Lookup("Scroll_Enemy"):ScrollNext(nDistance)
	elseif szName == "Page_BlackList" then
		page:Lookup("Scroll_BlackList"):ScrollNext(nDistance)
	elseif szName == "Page_Near" then
		page:Lookup("Scroll_Near"):ScrollNext(nDistance)
	elseif this:GetParent():GetParent():GetName() == "Page_Party" then
		page = this:GetParent():GetParent()
		page:Lookup("Scroll_Party"):ScrollNext(nDistance)
	end
	
	return 1
end

function PartyPanel.AddOrRenameFriendGroup(szText, bRename, szOrg, dwGroupID)
	if bRename and szOrg == szText then
		return
	end
	
	if szText == "" then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_MSG_GROUP_NAME_EMPTY)
		return
	end
	
	local player = GetClientPlayer()
	local aGroup = player.GetFellowshipGroupInfo()
	aGroup = aGroup or {}
	table.insert(aGroup, 1, {id = 0, name = g_tStrings.STR_FRIEND_GOOF_FRIEND})
	for k, v in ipairs(aGroup) do
		if v.name == szText then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_MSG_GROUP_EXIST)
			return
		end
	end
	
	for i = 1, #g_tStrings.tRelationClass do
	    if g_tStrings.tRelationClass[i] == szText then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_MSG_GROUP_EXIST)
			return
		end
	end
	
	if bRename then
		local bResult = player.RenameFellowshipGroup(dwGroupID, szText)
		if bResult then
		    OutputMessage("MSG_ANNOUNCE_YELLOW", g_tStrings.FELLOWSHIP_GROUP_SUCCESS_RENAME)
		end
	else
		player.AddFellowshipGroup(szText)
	end
end

function GetSelectFellow()
	if not IsPartyPanelOpened() then
		return
	end
	
	local frame = Station.Lookup("Normal/PartyPanel")
	if not frame:Lookup("Wnd_FriendInfo"):IsVisible() then
		return
	end
	
	local page = frame:Lookup("PageSet_Main/Page_Company/PageSet_Company/Page_Friend")
	local hList = page:Lookup("", "")
	
	local nCount = hList:GetItemCount() - 1
	for i = 0, nCount, 1 do
		local hB = hList:Lookup(i)
		if hB.bSel then
			return hB.aInfo.id, hB.aInfo.name
		end
	end
	return nil, nil
end

function OpenPartyPanel(bDisableSound, szFrame)
    if CheckPlayerIsRemote(nil, g_tStrings.STR_REMOTE_NOT_TIP1) then
        return
    end
    
	if IsOptionOrOptionChildPanelOpened() then
		return
	end

	if IsPartyPanelOpened() then
		return
	end
		
	local frame = Wnd.OpenWindow("PartyPanel")
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
	
	local player = GetClientPlayer()
	player.UpdateFellowshipInfo()
	player.UpdateFoeInfo()
	player.UpdateBlackListInfo()

	if not szFrame then
		szFrame = "FRIEND"
	end
	if szFrame == "PARTY" then
		frame:Lookup("PageSet_Main"):ActivePage("Page_Party")
	elseif szFrame == "FRIEND" then
		frame:Lookup("PageSet_Main"):ActivePage("Page_Company")
	else
		frame:Lookup("PageSet_Main"):ActivePage("Page_Party")
	end
end

function ClosePartyPanel(bDisableSound)
	if not IsPartyPanelOpened() then
		return
	end
	Wnd.CloseWindow("PartyPanel")
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end
end

function IsPartyPanelOpened()
	local frame = Station.Lookup("Normal/PartyPanel")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end

function AddContactPeople(szName)
	if not PartyPanel.aNear then
		PartyPanel.aNear = {}
	end
	
	for k, v in ipairs(PartyPanel.aNear) do
		if v == szName then
			table.remove(PartyPanel.aNear, k)
			break
		end
	end
	table.insert(PartyPanel.aNear, szName)
	if #(PartyPanel.aNear) > 30 then
		table.remove(PartyPanel.aNear, 1)
	end
	FireEvent("LATEST_CONTACT_PEOPLE_CHANGED")
end

function IsPlayerNeutral()
	local player = GetClientPlayer()
	
	return player.nCamp == CAMP.NEUTRAL
end