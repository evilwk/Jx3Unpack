-------新版队友界面------------------

Teammate = 
{
	bShowStateValue = false,
	
	DefaultAnchor = {s = "TOPLEFT", r = "TOPLEFT", x = 5, y = 255},
	Anchor = {s = "TOPLEFT", r = "TOPLEFT", x = 5, y = 255},	
}

RegisterCustomData("Teammate.bShowStateValue")
RegisterCustomData("Teammate.Anchor")

function Teammate.OnFrameCreate()
	this:RegisterEvent("BUFF_UPDATE")
	this:RegisterEvent("PARTY_UPDATE_BASE_INFO")
	this:RegisterEvent("PARTY_UPDATE_MEMBER_INFO")
	this:RegisterEvent("PLAYER_STATE_UPDATE")
	this:RegisterEvent("PARTY_SET_MEMBER_ONLINE_FLAG")
	this:RegisterEvent("TEAM_AUTHORITY_CHANGED")
	this:RegisterEvent("PARTY_DELETE_MEMBER")
	this:RegisterEvent("PARTY_DISBAND")
	this:RegisterEvent("PLAYER_LEAVE_SCENE")
	this:RegisterEvent("PARTY_ADD_MEMBER")
	this:RegisterEvent("PARTY_SYNC_MEMBER_DATA")
	this:RegisterEvent("PARTY_UPDATE_MEMBER_LMR")
	this:RegisterEvent("PARTY_INVITE_REQUEST")
	this:RegisterEvent("PARTY_APPLY_REQUEST")
	this:RegisterEvent("PARTY_SET_FORMATION_LEADER")
	this:RegisterEvent("UPDATE_PLAYER_SCHOOL_ID")
	this:RegisterEvent("SET_SHOW_VALUE_BY_PERCENTAGE")
	this:RegisterEvent("SET_SHOW_TEAMMATE_STATE_VALUE")
	this:RegisterEvent("SYNC_ROLE_DATA_END")
	this:RegisterEvent("PARTY_SET_MARK")
	this:RegisterEvent("TEAM_CHANGE_MEMBER_GROUP")
	
	this:RegisterEvent("UI_SCALED")
	this:RegisterEvent("ON_ENTER_CUSTOM_UI_MODE")
	this:RegisterEvent("ON_LEAVE_CUSTOM_UI_MODE")
	this:RegisterEvent("TEAMMATE_ANCHOR_CHANGED")	
	this:RegisterEvent("CUSTOM_DATA_LOADED")

	Teammate.Update(this)
	UpdateCustomModeWindow(this, g_tStrings.TEAMMATE)	
end

function Teammate.OnFrameDrag()
end

function Teammate.OnFrameDragSetPosEnd()
end

function Teammate.OnFrameDragEnd()
	this:CorrectPos()
	Teammate.Anchor = GetFrameAnchor(this)
end

function Teammate.UpdateAnchor(frame)
	frame:SetPoint(Teammate.Anchor.s, 0, 0, Teammate.Anchor.r, Teammate.Anchor.x, Teammate.Anchor.y)
	frame:CorrectPos()
end

function Teammate.OnFrameBreathe()
    local hMemberList = this:Lookup("", "")
    local nCount = hMemberList:GetItemCount() - 1
    for i = 0, nCount, 1 do
        local hItem = hMemberList:Lookup(i)
        local hBuff = hItem:Lookup("Handle_Buff")
        local hDebuff = hItem:Lookup("Handle_Debuff")
        Teammate.UpdateBufferSparking(hBuff)
        Teammate.UpdateBufferSparking(hDebuff)
    end
end

function Teammate.Update(hFrame)
	Teammate.UptadePartyList(hFrame)
	Teammate.UpdateAnchor(hFrame)	
end

function Teammate.UptadePartyList(hFrame)
	local hMemberList = hFrame:Lookup("", "")
	hMemberList:Clear()	
	
	local hPlayer = GetClientPlayer()
	if not hPlayer or not hPlayer.IsInParty() then
		return
	end
		
	local hTeam = GetClientTeam()
	local nGroupID = hTeam.GetMemberGroupIndex(hPlayer.dwID)
	local tGroupInfo = hTeam.GetGroupInfo(nGroupID)
	for _, dwID in pairs(tGroupInfo.MemberList) do
		Teammate.AddPartyMember(hMemberList, dwID)
	end
	Teammate.UpdatePosInfo(hFrame)
	Teammate.UpdatePartyMark(hFrame)
end

function Teammate.UpdateMemberInfo(frame, dwID)
	local hMember = Teammate.GetMemberHandle(this, dwID)
	if hMember then
		local bHideMana = hMember.bHideMana
		Teammate.UpdateMemberLFData(hMember)
		
		if bHideMana ~= hMember.bHideMana then
			if IsTeammateShowStateValue() then
				hMember:Lookup("Text_Health"):Show()
				hMember:Lookup("Text_Mana"):Show()
			else
				hMember:Lookup("Text_Health"):Hide()
				hMember:Lookup("Text_Mana"):Hide()
			end
			
			if hMember.bHideMana then
				hMember:Lookup("Text_Mana"):Hide()
			end
		end
	end
end

function Teammate.OnEvent(event)
	if event == "BUFF_UPDATE" then
		if not Teammate.IsInMyGroup(arg0) then
			return
		end
		
		local hMember = Teammate.GetMemberHandle(this, arg0)
		if not hMember then
			return
		end
		
		if arg7 then
			Teammate.RefreshBuff(hMember, true, true)
			if not hMember.bInit then
				Teammate.ShowNoteImage(hMember)
				hMember.bInit = true
			end
		else
			local bDelete = arg1
			local bCanCancel = arg3
			if bDelete then 
				Teammate.RefreshBuff(hMember, bCanCancel, not bCanCancel)
			else
				local szName = "Handle_Debuff"
				if bCanCancel then
					szName = "Handle_Buff"
				end
				local hBuff = Teammate.GetBuffHandle(hMember, szName)
				Teammate.UpdateBuff(hBuff, arg1, arg2, bCanCancel, arg4, arg5, arg6, arg8, arg9)
			end
			if Table_BuffIsVisible(arg4, arg8) then
				Teammate.ShowNoteImage(hMember)
			end
		end
						
	elseif event == "PARTY_UPDATE_BASE_INFO" then
		Teammate.Update(this)
	elseif event == "PARTY_UPDATE_MEMBER_LMR" then
		if not Teammate.IsInMyGroup(arg1) then
			return
		end
		
		local hMember = Teammate.GetMemberHandle(this, arg1)
		if hMember then
			Teammate.UpdateMemberHFData(hMember)
		end
	elseif event == "PARTY_UPDATE_MEMBER_INFO" then
		if not Teammate.IsInMyGroup(arg1) then
			return
		end
		
		Teammate.UpdateMemberInfo(this, arg1)
	elseif event == "PLAYER_STATE_UPDATE" then
		if not Teammate.IsInMyGroup(arg0) then
			return
		end
		Teammate.UpdateMemberInfo(this, arg0)
	elseif event == "PARTY_SET_MEMBER_ONLINE_FLAG" then
		if not Teammate.IsInMyGroup(arg1) then
			return
		end
		
		local hMember = Teammate.GetMemberHandle(this, arg1)
		if hMember then
			Teammate.UpdateMemberLFData(hMember)
		end
	elseif event == "TEAM_AUTHORITY_CHANGED" then
		local bUpdate = false
		if Teammate.IsInMyGroup(arg2) then
			local hMember = Teammate.GetMemberHandle(this, arg2)
			if hMember then
				Teammate.UpdateMemberLFData(hMember)
				bUpdate = true
			end
		end
		
		if Teammate.IsInMyGroup(arg3) then
			local hMember = Teammate.GetMemberHandle(this, arg3)
			if hMember then
				Teammate.UpdateMemberLFData(hMember)
				bUpdate = true
			end
		end

		if bUpdate then
			Teammate.UpdatePosInfo(this)
		end
	elseif event == "PARTY_SET_FORMATION_LEADER" then
		if not Teammate.IsInMyGroup(arg0) then
			return
		end
		
		local hMemberList = this:Lookup("", "")
		local nCount = hMemberList:GetItemCount()
		for i = 0, nCount - 1 do
			local hMember = hMemberList:Lookup(i)
			if hMember.bFormationLeader or hMember.dwID == arg0 then
				Teammate.UpdateMemberLFData(hMember)
			end
		end
	elseif event == "TEAM_CHANGE_MEMBER_GROUP" then
		local hPlayer = GetClientPlayer()
		local hTeam = GetClientTeam()
		local nGroup = hTeam.GetMemberGroupIndex(hPlayer.dwID)
		if nGroup == arg1 or nGroup == arg2 then
			Teammate.UptadePartyList(this)
		end
	elseif event == "PARTY_DELETE_MEMBER" then
		local hMemberList = this:Lookup("", "")
		local hPlayer = GetClientPlayer()
		if hPlayer.dwID == arg1 then
			hMemberList:Clear()
		else
			local hTeam = GetClientTeam()
			local nMyGroup = hTeam.GetMemberGroupIndex(hPlayer.dwID)
			if nMyGroup ~= arg3 then
				return
			end
			Teammate.DeletePartyMember(hMemberList, arg1)
		end		
	elseif event == "PARTY_DISBAND" then
		this:Lookup("", ""):Clear()
	elseif event == "PLAYER_LEAVE_SCENE" then
		if not Teammate.IsInMyGroup(arg0) then
			return
		end
		
		local handle = this:Lookup("", "")
		local nCount = handle:GetItemCount()
		for i = 0, nCount - 1 do
			local hI = handle:Lookup(i)
			if hI.dwID == arg0 then
				hI:Lookup("Handle_Buff"):Clear()
				hI:Lookup("Handle_Debuff"):Clear()
				local hMember = Teammate.GetMemberHandle(this, arg0)
				Teammate.ClearNoteImage(hMember)
				break
			end
		end
	elseif event == "PARTY_ADD_MEMBER" then
		if Teammate.AddPartyMember(this:Lookup("", ""), arg1) then
			PlaySound(SOUND.UI_SOUND,g_sound.Complete)
		end
	elseif event == "PARTY_SYNC_MEMBER_DATA" then
		Teammate.AddPartyMember(this:Lookup("", ""), arg1)
	elseif event == "PARTY_INVITE_REQUEST" then
		if IsFilterOperate("PARTY_INVITE_REQUEST") then
			GetClientTeam().RespondTeamInvite(arg0, 0)
			return
		end
		
		local szSrc = arg0
		local dwTime = GetTickCount()
		local msg =
		{
			szName = "IMTP_"..szSrc, 
			szMessage = FormatString(g_tStrings.STR_PLAYER_INVITE_PARTY, arg0, arg3, g_tStrings.tForceTitle[arg2], g_tStrings.STR_GUILD_CAMP_NAME[arg1]),
			fnAutoClose = function() return GetTickCount() - dwTime > 2000 * 60 end,
			fnCancelAction = function() GetClientTeam().RespondTeamInvite(szSrc, 0) end,
			{szOption = g_tStrings.STR_ACCEPT, fnAction=function() GetClientTeam().RespondTeamInvite(szSrc, 1) return end, szSound = g_sound.Complete},
			{szOption = g_tStrings.STR_REFUSE, fnAction=function() GetClientTeam().RespondTeamInvite(szSrc, 0) return end}
		}
		MessageBox(msg, true)
		AddContactPeople(arg0)
		PlaySound(SOUND.UI_SOUND,g_sound.Invite)
	elseif event == "PARTY_APPLY_REQUEST" then	
		if IsFilterOperate("PARTY_APPLY_REQUEST") then
			GetClientTeam().RespondTeamApply(arg0, 0)
			return
		end
		
		local szSrc = arg0
		local dwTime = GetTickCount()
		local msg = 
		{
			szName = "ATMP_"..szSrc, 
			szMessage = FormatString(g_tStrings.STR_PLAYER_APPLY_PARTY, arg0, arg3, g_tStrings.tForceTitle[arg2], g_tStrings.STR_GUILD_CAMP_NAME[arg1]),
			fnAutoClose = function() return GetTickCount() - dwTime > 2000 * 60 end,
			fnCancelAction = function() GetClientTeam().RespondTeamApply(szSrc, 0) end,
			{szOption = g_tStrings.STR_ACCEPT, fnAction=function() GetClientTeam().RespondTeamApply(szSrc, 1) return end, szSound = g_sound.Complete},
			{szOption = g_tStrings.STR_REFUSE, fnAction=function() GetClientTeam().RespondTeamApply(szSrc, 0) return end}
		}
		MessageBox(msg, true)
		AddContactPeople(arg0)
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	elseif event == "UPDATE_PLAYER_SCHOOL_ID" then
		local hMember = Teammate.GetMemberHandle(this, arg0)
		if hMember then
			Teammate.UpdateMemberLFData(hMember)
		end
	elseif event == "SYNC_ROLE_DATA_END" then
		Teammate.UptadePartyList(this)
		local hMemberList = this:Lookup("", "")
		local nCount = hMemberList:GetItemCount()
		for i = 0, nCount - 1 do
			Teammate.UpdateMemberLFData(hMemberList:Lookup(i))
		end
	elseif event == "PARTY_SET_MARK" then
		Teammate.UpdatePartyMark(this)
	elseif event == "SET_SHOW_VALUE_BY_PERCENTAGE" or event == "SET_SHOW_TEAMMATE_STATE_VALUE" then
		local hMemberList = this:Lookup("", "")
		Teammate.UpdateTeamateStateValueShow(hMemberList)
		local nCount = hMemberList:GetItemCount()
		for i = 0, nCount - 1 do
			Teammate.UpdateMemberHFData(hMemberList:Lookup(i))
		end
	elseif event == "UI_SCALED" then
		Teammate.UpdateAnchor(this)
	elseif event == "ON_ENTER_CUSTOM_UI_MODE" or event == "ON_LEAVE_CUSTOM_UI_MODE" then
		UpdateCustomModeWindow(this)
	elseif event == "TEAMMATE_ANCHOR_CHANGED" then
		Teammate.UpdateAnchor(this)
	elseif event == "CUSTOM_DATA_LOADED" then
		Teammate.UpdateAnchor(this)
	end
end

function Teammate.UpdatePosInfo(frame)
	local handle = frame:Lookup("", "")
	local nCount = handle:GetItemCount() - 1
	for i = 0, nCount, 1 do
		local hMember = handle:Lookup(i)
		if hMember.bLeader then
			hMember:SetUserData(0)
		elseif hMember.bOnline then
			hMember:SetUserData(1)
		else
			hMember:SetUserData(2)
		end
	end
	handle:Sort()
	handle:FormatAllItemPos()
	local w, h = handle:GetAllItemSize()
	if h < 62 then
		h = 62
	end
	w = frame:GetSize()
	frame:SetSize(w, h)
	UpdateCustomModeWindow(frame)
	Teammate.UpdateAnchor(frame)
end

function Teammate.IsInMyGroup(dwMemberID)
	local hPlayer = GetClientPlayer()
	if not hPlayer or not hPlayer.IsInParty() then
		return
	end
	
	if not hPlayer.IsPlayerInMyParty(dwMemberID) then
		return
	end
	
	local hTeam = GetClientTeam()
	local nMyGroup = hTeam.GetMemberGroupIndex(hPlayer.dwID)
	local nMemberGroup = hTeam.GetMemberGroupIndex(dwMemberID)
	if hTeam.IsPlayerInTeam(dwMemberID) and nMyGroup == nMemberGroup then
		return true
	end
end

function Teammate.AddPartyMember(hMemberList, dwID)
	local hPlayer = GetClientPlayer()
	if not hPlayer or hPlayer.dwID == dwID then
		return false
	end
	
	if not Teammate.IsInMyGroup(dwID) then
		return false
	end
	
	local hMember = Teammate.GetMemberHandle(hMemberList:GetRoot(), dwID)
	if not hMember then
		hMember = hMemberList:AppendItemFromIni("UI/Config/Default/Teammate.ini", "Handle_Teammate", "")
		hMember.dwID = dwID
		hMember:Lookup("Handle_Buff"):Clear()
		hMember:Lookup("Handle_Debuff"):Clear()
	end
	
	Teammate.UpdateMemberLFData(hMember)
	Teammate.UpdateMemberHFData(hMember)
	
	Teammate.UpdateTeamateStateValueShow(hMemberList)
	Teammate.UpdatePosInfo(hMemberList:GetRoot())
	
	local hImageHead = hMember:Lookup("Image_Head")
	FireHelpEvent("OnMakeParty", hImageHead)
	
	return true
end

function Teammate.DeletePartyMember(hMemberList, dwMemberID)
	local hMember = Teammate.GetMemberHandle(hMemberList:GetRoot(), dwMemberID)
	if hMember then
		local nIndex = hMember:GetIndex()
		hMemberList:RemoveItem(nIndex)
		Teammate.UpdatePosInfo(hMemberList:GetRoot())
	end
end

function Teammate.UpdatePartyMark(hFrame)
	local hPlayer = GetClientPlayer()
	if not hPlayer.IsInParty() then
		return
	end
	
	local tPartyMark = GetClientTeam().GetTeamMark()
	if not tPartyMark then
		return
	end
	
	local hTotal = hFrame:Lookup("", "")
	local nCount = hTotal:GetItemCount()
	for i = 0, nCount - 1 do
		local nIconFrame = nil
		local hPartyMember = hTotal:Lookup(i)
		local hImageMark = hPartyMember:Lookup("Image_NPCMark")
		local nMarkID = tPartyMark[hPartyMember.dwID]

		if nMarkID then
			assert(nMarkID > 0 and nMarkID <= #PARTY_MARK_ICON_FRAME_LIST)
			nIconFrame = PARTY_MARK_ICON_FRAME_LIST[nMarkID]
		end

		if nIconFrame then
			hImageMark:FromUITex(PARTY_MARK_ICON_PATH, nIconFrame)
			hImageMark:Show()
		else
			hImageMark:Hide()
		end
	end
end

function Teammate.UpdateMemberHFData(hMember)
	local hTeam = GetClientTeam()
	local tMemberInfo = hTeam.GetMemberInfo(hMember.dwID)
	
	local hImgHealth = hMember:Lookup("Image_Health")
	local hTextHealth = hMember:Lookup("Text_Health")
	if tMemberInfo.nMaxLife > 0 then
		local fPercent = tMemberInfo.nCurrentLife / tMemberInfo.nMaxLife
		hImgHealth:SetPercentage(fPercent)
		
		local szShow = GetStateString(tMemberInfo.nCurrentLife, tMemberInfo.nMaxLife, false, true)
		hTextHealth:SetText(szShow);
	else
		hImgHealth:SetPercentage(0)
		hTextHealth:SetText("")	
	end
	
	local hImgMana = hMember:Lookup("Image_Mana")
	local hTextMana = hMember:Lookup("Text_Mana")
	if tMemberInfo.nMaxMana > 0 and tMemberInfo.nMaxMana ~= 1 then
		local fPercent = tMemberInfo.nCurrentMana / tMemberInfo.nMaxMana
		hImgMana:SetPercentage(fPercent)
		
		local szShow = GetStateString(tMemberInfo.nCurrentMana, tMemberInfo.nMaxMana, false, true)
		hTextMana:SetText(szShow);
	else
		hImgMana:SetPercentage(0)
		hTextMana:SetText("")
	end	
	
	if hMember.bHideMana then
		hTextMana:Hide()
	end	
end

function Teammate.UpdateTeamateStateValueShow(hMemberList)
	local nCount = hMemberList:GetItemCount() - 1
	for i = 0, nCount, 1 do
		local hMember = hMemberList:Lookup(i)
		if IsTeammateShowStateValue() then
			hMember:Lookup("Text_Health"):Show()
			hMember:Lookup("Text_Mana"):Show()
		else
			hMember:Lookup("Text_Health"):Hide()
			hMember:Lookup("Text_Mana"):Hide()
		end
		if hMember.bHideMana then
			hMember:Lookup("Text_Mana"):Hide()
		end
	end
end

function Teammate.GetMemberHandle(hFrame, dwMemberID)
	local hMemberList = hFrame:Lookup("", "")
	local nCount = hMemberList:GetItemCount()
	for i = 0, nCount - 1 do
		local hMember = hMemberList:Lookup(i)
		if hMember.dwID == dwMemberID then
			return hMember
		end
	end
end

function Teammate.UpdateKungfu(handle, tMemberInfo)
--	local kf = GetSkill(tMemberInfo.dwMountKungfuID, 1)
--	local dwKungfuType = 0
--	if kf then
--		dwKungfuType = kf.dwMountType
--	end
--	local szPath, nFrame = GetKungfuImage(dwKungfuType)
	local szPath, nFrame = GetForceImage(tMemberInfo.dwForceID)
	handle:Lookup("Image_School"):FromUITex(szPath, nFrame)
end

function Teammate.UpdateMemberLFData(hMember)
	if not hMember then
		return
	end

	local hTeam = GetClientTeam()
	local tMemberInfo = hTeam.GetMemberInfo(hMember.dwID)
	local dwMountType = 0
	if tMemberInfo.dwMountKungfuID ~= 0 then
		local kf = GetSkill(tMemberInfo.dwMountKungfuID, 1)
		if kf then
			dwMountType = kf.dwMountType
		end
	end
	local bHideMana = IsPlayerManaHide(dwMountType)
	
	hMember.bHideMana = bHideMana
	
	local szFile = ""
	local img = hMember:Lookup("Image_Head")
	if tMemberInfo.dwMiniAvatarID == 0 then
		local szPath, nFrame = GetForceImage(tMemberInfo.dwForceID)
		img:SetImageType(IMAGE.NORMAL)
		img:FromUITex(szPath, nFrame)
	else
		szFile = GetPlayerMiniAvatarFile(tMemberInfo.dwMiniAvatarID, tMemberInfo.bIsOnLine)
		img:SetImageType(IMAGE.FLIP_HORIZONTAL)
		img:FromTextureFile(szFile)
	end
	
	Teammate.UpdateKungfu(hMember, tMemberInfo)
	
	local hTextName = hMember:Lookup("Text_Name")
	hTextName:SetText(tMemberInfo.szName)
	local hTextLevel = hMember:Lookup("Text_Level")
	local hImageOffline = hMember:Lookup("Image_OffLine")
	local hImageLife = hMember:Lookup("Image_Health")
	
	local hImageBack = hMember:Lookup("Image_Back")
	local hImageFBack = hMember:Lookup("Image_FBack")
	local hImageOfflineF = hMember:Lookup("Image_OffLineF")
	
	local hImageMana = hMember:Lookup("Image_Mana")
	hMember.bOnline = tMemberInfo.bIsOnLine
	if hMember.bOnline then
		hTextName:SetFontScheme(18)
		hTextLevel:SetText(tMemberInfo.nLevel)
		hTextLevel:Show()
		
		hImageLife:SetPercentage(tMemberInfo.nCurrentLife / tMemberInfo.nMaxLife)
		hImageLife:Show()
		
		hImageMana:SetPercentage(tMemberInfo.nCurrentMana / tMemberInfo.nMaxMana)
		hImageMana:Show()
		
		hImageFBack:Hide()
		if bHideMana then
			hImageMana:Hide()
			hImageFBack:Show()
		end
		
		hImageOffline:Hide()
		hImageOfflineF:Hide()
	else
		hTextName:SetFontScheme(108)
		hTextLevel:Hide()
		
		hImageLife:Hide()
		hImageMana:Hide()
		
		if bHideMana then
			hImageOfflineF:Show()
		else
			hImageOffline:Show()
		end
	end	
	
	hMember.bLeader = (hTeam.GetAuthorityInfo(TEAM_AUTHORITY_TYPE.LEADER) == hMember.dwID)	
	local hImageLeader = hMember:Lookup("Image_Flag")
	if hMember.bLeader then
		hImageLeader:Show()
	else
		hImageLeader:Hide()
	end
	
	local hPlayer = GetClientPlayer()
	local nGroupID = hTeam.GetMemberGroupIndex(hPlayer.dwID)
	local tGroupInfo = hTeam.GetGroupInfo(nGroupID)
	hMember.bFormationLeader = (tGroupInfo.dwFormationLeader == hMember.dwID)
	local hImageFormation = hMember:Lookup("Image_Center")
	if hMember.bFormationLeader then
		hImageFormation:Show()
	else
		hImageFormation:Hide()
	end
	
	hMember.bDistribute = (hTeam.GetAuthorityInfo(TEAM_AUTHORITY_TYPE.DISTRIBUTE) == hMember.dwID)
	local hImageDistribute = hMember:Lookup("Image_Boss")
	if hMember.bDistribute then
		hImageDistribute:Show()
	else
		hImageDistribute:Hide()
	end
	
	hMember.bMark = (hTeam.GetAuthorityInfo(TEAM_AUTHORITY_TYPE.MARK) == hMember.dwID)
	local hImageMark = hMember:Lookup("Image_Mark")
	if hMember.bMark then
		hImageMark:Show()
	else
		hImageMark:Hide()
	end
	
	local hMatrix = hMember:Lookup("Handle_Matrix")
	hMatrix.nFormationCoefficient = tMemberInfo.nFormationCoefficient
	if hMatrix.nFormationCoefficient > 3000 then
		hMatrix.nFormationCoefficient = 3000
	end
	
	local nFormationEffect = GetFormationEffect(hMatrix.nFormationCoefficient)
	for i = 1, 7 do
		local hMatrixPoint = hMatrix:Lookup(i .. "H_3")
		if i <= nFormationEffect then
			hMatrixPoint:Show()
		else
			hMatrixPoint:Hide()
		end
	end
end

function Teammate.OnItemLButtonUp()
	local szName = this:GetName()
	if szName == "Image_RightButton_N" then
		this:SetFrame(93)
		local tMenu = {}
		local hMember = this:GetParent():GetParent()
		InsertTeammateMenu(tMenu, hMember.dwID)
		if tMenu and #tMenu > 0 then
			PopupMenu(tMenu)
		end
	end
end

function Teammate.OnItemLButtonDown()
	local szName = this:GetName()
	if szName == "Image_RightButton_N" then
		this:SetFrame(95)
	end

	local hMember = this:GetParent()
	if UserSelect.DoSelectCharacter(TARGET.PLAYER, hMember.dwID) then
		return
	end

	if IsCtrlKeyDown() then
		local hTeam = GetClientTeam()
		local tMemberInfo = hTeam.GetMemberInfo(hMember.dwID)
		if IsGMPanelReceivePlayer(hMember.dwID) then
			local hPlayer = GetPlayer(hMember.dwID)
			if hPlayer then
				GMPanel_LinkPlayerID(hMember.dwID)
			else
				GMPanel_LinkPlayerName(tMemberInfo.szName)
			end
		else
			EditBox_AppendLinkPlayer(tMemberInfo.szName)
		end
		return
	end
	SelectTarget(TARGET.PLAYER, hMember.dwID)
end

function Teammate.OnItemRButtonDown()
	local tMenu = {}
	local hMember = this:GetParent()
	InsertTeammateMenu(tMenu, hMember.dwID)
	if tMenu and #tMenu > 0 then
		PopupMenu(tMenu)
	end
end

------------------------Buff相关-----------------------------------

function Teammate.UpdateBufferSparking(hBuffList)
    local nCount = hBuffList:GetItemCount() - 1
    for i=0, nCount, 1 do
        local hBox = hBuffList:Lookup(i)
        
        local nLogic = GetLogicFrameCount()
        local nEndFrame = hBox.nEndFrame or 0;
        local nLeftFrame = nEndFrame - nLogic
        if nLeftFrame > 0 then
            if  hBox.bSparking and nLeftFrame < 480 then
                local nAlpha = hBox:GetAlpha()
                if hBox.bAdd then
                    nAlpha =  nAlpha + 20
                else
                    nAlpha =  nAlpha - 20
                end
                nAlpha = math.min(nAlpha, 255)
                nAlpha = math.max(nAlpha, 0)
                hBox:SetAlpha(nAlpha)
                if nAlpha == 255 then
                    hBox.bAdd = false;
                elseif nAlpha <= 0 then
                    hBox.bAdd = true;
                end
            else
                hBox:SetAlpha(255)
            end
        end
    end
end

function Teammate.GetBuffHandle(hMember, szName)
	if not hMember[szName] then
		hMember[szName] = hMember:Lookup(szName)
	end
	return hMember[szName]
end

function Teammate.HideLeftItem(handle, nNeed, bFormat)
	local nCount = handle:GetItemCount()
	local nLeft = nCount - nNeed
	if nLeft > 10 then
		for i=1, nLeft, 1 do
			handle:RemoveItem(nCount - i)
		end
	else
		nCount = nCount - 1
		for i=nNeed, nCount, 1 do
			handle:Lookup(i):Hide()
		end
	end
	
	handle.nNeedBox = nNeed
	handle:FormatAllItemPos()
end

function Teammate.RefreshBuff(handle, bUpdateBuff, bUpdateDebuff)
	local player = GetPlayer(handle.dwID)
	
	local hBuff   = Teammate.GetBuffHandle(handle, "Handle_Buff")
	local hDebuff = Teammate.GetBuffHandle(handle, "Handle_Debuff")
	hBuff:Clear()
	hDebuff:Clear()
	    
	if not player then
		return
	end
    
	local box
	local nBuffIndex = 0
	local nDebuffIndex = 0
	local nBuffCount = hBuff:GetItemCount()
	local nDebuffCount = hDebuff:GetItemCount()
	
	hBuff.bIniting = true;
	hDebuff.bIniting = true;
	local function UpdateSBuff(v)
		if not Table_BuffIsVisible(v.dwID, v.nLevel) then
			return
		end
		if bUpdateBuff and v.bCanCancel then
			if nBuffIndex < nBuffCount then
				box = hBuff:Lookup(nBuffIndex)
			end
			nBuffIndex = nBuffIndex + 1
			Teammate.CreateBuff(hBuff, box, v.nIndex, true, v.dwID, v.nStackNum, v.nEndFrame, v.nLevel, v.dwSkillSrcID)
		elseif bUpdateDebuff and not v.bCanCancel then
			if nDebuffIndex < nDebuffCount then
				box = hDebuff:Lookup(nDebuffIndex)
			end
			nDebuffIndex = nDebuffIndex + 1
			Teammate.CreateBuff(hDebuff, box, v.nIndex, false, v.dwID, v.nStackNum, v.nEndFrame, v.nLevel, v.dwSkillSrcID)
		end
	end
	local buffTable = player.GetBuffList()	
	if buffTable then
		local dwID = UI_GetClientPlayerID()
		local tOtherBuff = {}
		for k, v in pairs(buffTable) do
			if v.dwSkillSrcID == dwID then
				UpdateSBuff(v)
			else
				table.insert(tOtherBuff, k)
			end
		end
	
		for _, k in pairs(tOtherBuff) do
			local v = buffTable[k]
			UpdateSBuff(v)
		end
	end	

	
	if bUpdateBuff then
		Teammate.HideLeftItem(hBuff, nBuffIndex, nBuffIndex > nBuffCount)
	end
	
	if bUpdateDebuff then
		Teammate.HideLeftItem(hDebuff, nDebuffIndex, nDebuffIndex > nDebuffCount)
	end
	hBuff.bIniting = false;
	hDebuff.bIniting = false;
end

function Teammate.CreateBuff(handle, box, nIndex, bCanCancel, dwBuffID, nCount, nEndFrame, nLevel, dwSkillSrcID)
	if not box then
		handle:AppendItemFromString("<box> postype=7 w=18 h=18 eventid=262912 </box>")
		local nItemCount = handle:GetItemCount()
		box = handle:Lookup(nItemCount - 1)
		box.OnItemMouseEnter = function()
			this:SetObjectMouseOver(1)
			local nTime = math.floor(this.nEndFrame - GetLogicFrameCount()) / 16 + 1
			local x, y = this:GetAbsPos()
			local w, h = this:GetSize()
			local dwCaracter = this:GetParent():GetParent().dwID
			if nTime < 0 then
				nTime = 0
			end
			OutputBuffTip(dwCaracter, this.dwBuffID, this.nLevel, this.nCount, this.bShowTime and not this.bCanCancel, nTime, {x, y, w, h})					
		end
		box.OnItemMouseHover = box.OnItemMouseEnter
		box.OnItemMouseLeave = function()
			HideTip()
			this:SetObjectMouseOver(0)
		end
	end
	
	if dwSkillSrcID and UI_GetClientPlayerID() == dwSkillSrcID then
		local nW, nH = box:GetSize()
		box:SetSize(23, 23)
		if not handle.bIniting then
			box:SetIndex(0)
		end
	else
		box:SetSize(18, 18)
	end
	box:Show()
	box:SetName("b"..nIndex)
	box.nCount = nCount
	box.nEndFrame = nEndFrame
	box.bCanCancel = bCanCancel
	box.dwBuffID = dwBuffID
	box.nLevel = nLevel
	box.nIndex = nIndex
	box.bSparking = Table_BuffNeedSparking(dwBuffID, nLevel)
	box.bShowTime = Table_BuffNeedShowTime(dwBuffID, nLevel)
	box:SetObject(UI_OBJECT_NOT_NEED_KNOWN, dwBuffID)
	box:SetObjectIcon(Table_GetBuffIconID(dwBuffID, nLevel))
	box:SetOverTextFontScheme(0, 15)
	if nCount > 1 then
		box:SetOverText(0, nCount)
	else
		box:SetOverText(0, "")
	end
end

function Teammate.UpdateBuff(handle, bDelete, nIndex, bCanCancel, dwBuffID, nCount, nEndFrame, nLevel, dwSkillSrcID)
	if not Table_BuffIsVisible(dwBuffID, nLevel) then
		return
	end
	
	local box = handle:Lookup("b"..nIndex)
	if not box then
		local nItemCount = handle:GetItemCount()
		if handle.nNeedBox < nItemCount then
			box = handle:Lookup(handle.nNeedBox)
			handle.nNeedBox = handle.nNeedBox + 1
		end
	end
	
	local bCreate = false
	if not box then
		bCreate = true
	end
	
	Teammate.CreateBuff(handle, box, nIndex, bCanCancel, dwBuffID, nCount, nEndFrame, nLevel, dwSkillSrcID)
	if bCreate or UI_GetClientPlayerID() == dwSkillSrcID then
		handle.nNeedBox = handle.nNeedBox + 1
		handle:FormatAllItemPos()
	end
end

function Teammate.ShowNoteImage(handle)
	local bShowImage = false
	local player = GetPlayer(handle.dwID)
	
	if not player then 
		return 
	end
	
	local buffTable = player.GetBuffList()
	local hNoteImage = handle:Lookup("Image_DebuffBg")
	
	if buffTable then
		for _, v in pairs(buffTable) do
			if not v.bCanCancel then
				if IsBuffDispel(v.dwID, v.nLevel) then
					bShowImage = true
					break
				end
			end
		end
	end

	if bShowImage then 
		hNoteImage:Show()
	else 
		hNoteImage:Hide()
	end
end

function Teammate.ClearNoteImage(handle)
	local hNoteImage = handle:Lookup("Image_DebuffBg")
	hNoteImage:Hide()
	handle.bInit = false
end

function Teammate.OnItemMouseEnter()
	local szName = this:GetName()
	if szName == "Image_Back" then
		local hP = this:GetParent()
		if UserSelect.IsSelectCharacter() then
			UserSelect.SatisfySelectCharacter(TARGET.PLAYER, hP.dwID)
		end
		OutputTeamMemberTip(hP.dwID)
	elseif szName == "Handle_Matrix" then
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
	    Teammate.OutputFormationTip(this, {x, y, w, h})
	elseif szName == "Image_RightButton_N" then
		this:SetFrame(94)
	else
		local hP = this:GetParent()
		local szName = this:GetName()
		if szName == "Image_Health" then
			this:GetParent():Lookup("Text_Health"):Show()
			OutputTeamMemberTip(hP.dwID)
		elseif szName == "Image_Mana" then
			local hMember = this:GetParent()
			if not hMember.bHideMana then
				hMember:Lookup("Text_Mana"):Show()
			end
			OutputTeamMemberTip(hP.dwID)
        elseif szName == "Image_Head" then
            OutputTeamMemberTip(hP.dwID)
		end
	end
end

function Teammate.OutputFormationTip(hMatrix, rc)
    if not hMatrix then
        return
    end
    local tNumber = {"一", "二", "三", "四", "五", "六", "七"}
    local nFormationEffect, nCurrentMaxFormation = GetFormationEffect(hMatrix.nFormationCoefficient)
    local szTip = ""
    
    szTip = szTip.."<text>text="..
            EncodeComponentsString(FormatString(g_tStrings.FORMATION_COEFFICIENT, hMatrix.nFormationCoefficient, nCurrentMaxFormation))..
            " font=65 </text>"
    szTip = szTip.."<text>text="..
            EncodeComponentsString(FormatString(g_tStrings.FORMATION_EFFECT, tNumber[nFormationEffect]))..
            " font=106 </text>"
    szTip = szTip.."<text>text="..
            EncodeComponentsString(g_tStrings.FORMATION_INCREASE_FUNCTION)..
            " font=106 </text>"
    OutputTip(szTip, 345, rc)
end

function GetFormationEffect(nFormation)
    local nEffect = 0
    local nCurrentMaxFormation = 0
    if nFormation <= 200 then
        nEffect = 1
        nCurrentMaxFormation = 200
    elseif nFormation <= 400 then
        nEffect = 2
        nCurrentMaxFormation = 400
    elseif nFormation <= 600 then
        nEffect = 3
        nCurrentMaxFormation = 600
    elseif nFormation <= 1000 then
        nEffect = 4
        nCurrentMaxFormation = 1000
    elseif nFormation <= 1600 then
        nEffect = 5
        nCurrentMaxFormation = 1600
    elseif nFormation <= 2000 then
        nEffect = 6
        nCurrentMaxFormation = 2000
    else
        nEffect = 7
        nCurrentMaxFormation = 3000
    end
    return nEffect, nCurrentMaxFormation     
end

function Teammate.OnItemMouseLeave()
	HideTip()
	if this:GetName() == "Image_Back" then
		if UserSelect.IsSelectCharacter() then
			UserSelect.SatisfySelectCharacter(TARGET.NO_TARGET, 0, true)
		end	
	elseif szName == "Image_RightButton_N" then
		this:SetFrame(93)
	else
		local szName = this:GetName()
		if szName == "Image_Health" then
			if not IsTeammateShowStateValue() then
				this:GetParent():Lookup("Text_Health"):Hide()
			end
		elseif szName == "Image_Mana" then
			local hMember = this:GetParent()
			if not IsTeammateShowStateValue() and not hMember.bHideMana then
				hMember:Lookup("Text_Mana"):Hide()
			end
		end		
	end
end


function SelectTeammate(nIndex)	--选择队友从1开始
	local handle = Station.Lookup("Normal/Teammate", "")
	if handle then
		local hI = handle:Lookup(nIndex - 1)
		if hI then
			SelectTarget(TARGET.PLAYER, hI.dwID)
		end
	end
end

function IsTeammateShowStateValue()
	if Teammate.bShowStateValue then
		return true
	end
	return false
end

function SetTeammateShowStateValue(bShow)
	if Teammate.bShowStateValue == bShow then
		return
	end
	Teammate.bShowStateValue = bShow
	FireEvent("SET_SHOW_TEAMMATE_STATE_VALUE")
end

function CanMakeParty()
	local player = GetClientPlayer()
	return not (player.IsInParty() and (not player.IsPartyLeader() or player.IsPartyFull()))
end

function Teammate_SetAnchorDefault()
	Teammate.Anchor.s = Teammate.DefaultAnchor.s
	Teammate.Anchor.r = Teammate.DefaultAnchor.r
	Teammate.Anchor.x = Teammate.DefaultAnchor.x
	Teammate.Anchor.y = Teammate.DefaultAnchor.y
	FireEvent("TEAMMATE_ANCHOR_CHANGED")
end

RegisterEvent("CUSTOM_UI_MODE_SET_DEFAULT", Teammate_SetAnchorDefault)


function OpenTeammate()
	local hFrame = Station.Lookup("Normal/Teammate")
	if hFrame then
		hFrame:Show()
	end
end

function CloseTeammate()
	local hFrame = Station.Lookup("Normal/Teammate")
	if hFrame then
		hFrame:Hide()
	end	
end

function IsTeammateOpened()
	local hFrame = Station.Lookup("Normal/Teammate")
	if hFrame then
		return hFrame:IsVisible()
	end
end

function LoadTeammateSetting()
	local szIniFile = GetUserDataPath()
	if szIniFile == "" then
		return
	end
	szIniFile = szIniFile.."\\PannelSave.ini"
	local szSection = "Teammate"
	
	local iniS = Ini.Open(szIniFile)
	if not iniS then
		return
	end
	
	local value = iniS:ReadString(szSection, "SelfSide", Teammate.Anchor.s)
	if value then
		Teammate.Anchor.s = value
	end
	value = iniS:ReadString(szSection, "RelSide", Teammate.Anchor.r)
	if value then
		Teammate.Anchor.r = value
	end
	value = iniS:ReadInteger(szSection, "RelX", Teammate.Anchor.x)
	if value then
		Teammate.Anchor.x = value
	end
	value = iniS:ReadInteger(szSection, "RelY", Teammate.Anchor.y)
	if value then
		Teammate.Anchor.y = value
	end
	
	FireEvent("TEAMMATE_ANCHOR_CHANGED")

	iniS:Close()
end

RegisterLoadFunction(LoadTeammateSetting)

function GetTeammateName(dwMemberID)
	local hTeam = GetClientTeam()
	local tMemberInfo = hTeam.GetMemberInfo(dwMemberID)
	if tMemberInfo then
		return tMemberInfo.szName
	end
end

function OutputTeamMemberTip(dwID, rc)
	if GetPlayer(dwID) then
		OutputPlayerTip(dwID, rc)
		return
	end
	
	local hTeam = GetClientTeam()
	local tMemberInfo = hTeam.GetMemberInfo(dwID)

	local r, g, b = GetPartyMemberFontColor()
    local szTip = GetFormatText(FormatString(g_tStrings.STR_NAME_PLAYER, tMemberInfo.szName), 80, r, g, b)
    if tMemberInfo.bIsOnLine then
    	szTip = szTip .. GetFormatText(FormatString(g_tStrings.STR_PLAYER_H_WHAT_LEVEL, tMemberInfo.nLevel), 82)
		local szMapName = Table_GetMapName(tMemberInfo.dwMapID)
		if szMapName then
			szTip = szTip .. GetFormatText(szMapName .. "\n", 82)
		end
        
        local nCamp = tMemberInfo.nCamp
        szTip = szTip .. GetFormatText(g_tStrings.STR_GUILD_CAMP_NAME[nCamp], 82)
    else
    	szTip = szTip .. GetFormatText(g_tStrings.STR_FRIEND_NOT_ON_LINE .. "\n", 82)
    end
    OutputTip(szTip, 345, rc)
end


local function OnTeamAddMember()
	local hTeam = GetClientTeam()
	local tMemberInfo = hTeam.GetMemberInfo(arg1)
	if hTeam.nGroupNum > 1 then
		OutputMessage("MSG_SYS", FormatString(g_tStrings.STR_MSG_JOIN_RAID, tMemberInfo.szName))	
	else
		OutputMessage("MSG_SYS", FormatString(g_tStrings.STR_MSG_JOIN_YOU_PARTY, tMemberInfo.szName))	
	end
end

local function OnTeamDelMember()
	local hPlayer = GetClientPlayer()	
	local hTeam = GetClientTeam()
	if hPlayer.dwID == arg1 then
		if hTeam.nGroupNum > 1 then
			OutputMessage("MSG_SYS", FormatString(g_tStrings.STR_MSG_LEVEL_RAID, g_tStrings.STR_NAME_YOU))
		else
			OutputMessage("MSG_SYS", FormatString(g_tStrings.STR_MSG_LEAVE_YOU_PARTY, g_tStrings.STR_NAME_YOU))
		end
	else
		if hTeam.nGroupNum > 1 then
			OutputMessage("MSG_SYS", FormatString(g_tStrings.STR_MSG_LEVEL_RAID, arg2))
		else
			OutputMessage("MSG_SYS", FormatString(g_tStrings.STR_MSG_LEAVE_YOU_PARTY, arg2))
		end
	end			
end

RegisterEvent("PARTY_ADD_MEMBER", OnTeamAddMember)
RegisterEvent("PARTY_DELETE_MEMBER", OnTeamDelMember)
