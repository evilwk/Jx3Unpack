
local MAX_RAID_GROUP_COUNT = 6
local MAX_RAID_GROUP_MEMBER_COUNT = 5
local CUSTOM_RAID_GROUP_ID = -1
local MAX_RAID_CUSTOM_GROUP_MEMBER_COUNT = 10
local READY_CONFIRM_INIT = 0
local READY_CONFIRM_OK = 1
local READY_CONFIRM_NOT_YET = 2
local RAID_FRAME_UPDATE_INTERVAL_TIME = 0.5 * 1000
local RAID_FRAME_CLOSE_DISTANCE = 24 * 64
local RAID_FRAME_CLOSE_DISTANCE_LOWER = 20 * 64
local RAID_FRAME_MEMBER_LOWER_LIFE = 0.3
local RAID_PANEL_STATE_NOT_SHOW_BUFFS = 0
local RAID_PANEL_STATE_SHOW_BUFF = 1
local RAID_PANEL_STATE_SHOW_DEBUFF = 2

local RAIDPANEL_INI_FILE = "ui\\Config\\Default\\RaidPanel.ini"

RaidPanel_Base = class()

local tMainFramePosition = { nX = 20, nY = 240 }
local tRaidFramePosition = 
{
	{ nX = 190, nY = 240 },
	{ nX = 330, nY = 240 },
	{ nX = 470, nY = 240 },
	{ nX = 610, nY = 240 },
	{ nX = 750, nY = 240 },
}

local bRaidEditMode = false
local bHideReadyConfirm = false

function RaidPanel_Base.OnFrameCreate()
	this:RegisterEvent("PARTY_SYNC_MEMBER_DATA")
	this:RegisterEvent("PARTY_ADD_MEMBER")
	this:RegisterEvent("PARTY_DISBAND")
	this:RegisterEvent("PARTY_DELETE_MEMBER")
	this:RegisterEvent("PARTY_UPDATE_MEMBER_INFO")
	this:RegisterEvent("PARTY_UPDATE_MEMBER_LMR")
	this:RegisterEvent("PARTY_SET_MEMBER_ONLINE_FLAG")
	this:RegisterEvent("PLAYER_STATE_UPDATE")
	this:RegisterEvent("BUFF_UPDATE")
	this:RegisterEvent("UPDATE_PLAYER_SCHOOL_ID")
	this:RegisterEvent("PARTY_SET_MARK")
	
	this:RegisterEvent("UI_SCALED")
	
	this:RegisterEvent("TEAM_AUTHORITY_CHANGED")
	this:RegisterEvent("PARTY_SET_FORMATION_LEADER")
	
	this:RegisterEvent("MINIMIZE_RAID_TEAM_FRAME")
	this:RegisterEvent("CLOSE_RAID_TEAM_FRAME")
	this:RegisterEvent("RIAD_FRAME_EDIT_MODE")
	this:RegisterEvent("RAID_SHOW_OPTION_UPDATED")
	
	this:RegisterEvent("RIAD_READY_CONFIRM_RECEIVE_QUESTION")
	this:RegisterEvent("RIAD_READY_CONFIRM_RECEIVE_ANSWER")
end

function RaidPanel_Base.OnFrameDragEnd()
	if not RaidPanel.tGroupSettings[this.nGroupID] then
		RaidPanel.tGroupSettings[this.nGroupID] = {}
	end
		
	local tPos = {}
	tPos.nX, tPos.nY = this:GetRelPos()
	RaidPanel.tGroupSettings[this.nGroupID].tPos = tPos
end

function RaidPanel_Base.OnFrameBreathe()
	RaidPanel.UpdateLFAlpha(this)
	local nTime = GetTickCount()
	if not RaidPanel.tGroupSettings.bShowDistanceColor then
		return
	end
	if not this.nStartTime or nTime - this.nStartTime> RAID_FRAME_UPDATE_INTERVAL_TIME then
		RaidPanel.UpdateDistance(this)
		this.nStartTime = nTime
	end
end

function RaidPanel_Base.OnEvent(szEvent)
	if szEvent == "PARTY_SYNC_MEMBER_DATA"
	or szEvent == "PARTY_ADD_MEMBER" then
		if this.nGroupID == arg2 then
			RaidPanel.UpdateRaidFrame(this)
		end
		RaidPanel.UpdateGroupTabs(this)
	elseif szEvent == "PARTY_DELETE_MEMBER" then
		if this.bMainFrame then
			RaidPanel.tMemberState[arg1] = nil
			local hPlayer = GetClientPlayer()
			if hPlayer.dwID == arg1 then
				CloseRaidPanel()
				return
			end
			RaidPanel.CustomGroupDelMember(nil, arg1)
		end
		if this.nGroupID == arg3 then
			RaidPanel.UpdateRaidFrame(this)
		end
		RaidPanel.UpdateGroupTabs(this)
	elseif szEvent == "PARTY_DISBAND" then
		if this.bMainFrame then
			CloseRaidPanel()
		end
	elseif szEvent == "PARTY_UPDATE_MEMBER_INFO"
	or szEvent == "UPDATE_PLAYER_SCHOOL_ID" then
		local hMember = RaidPanel.GetMemberHandle(this, arg1)
		if hMember then
			RaidPanel.UpdateMemberLFData(hMember)
		end
	elseif szEvent == "PARTY_UPDATE_MEMBER_LMR" then
		local hMember = RaidPanel.GetMemberHandle(this, arg1)
		if hMember then
			RaidPanel.UpdateMemberHFData(hMember)
		end
	elseif szEvent == "PLAYER_STATE_UPDATE" then
		local hMember = RaidPanel.GetMemberHandle(this, arg0)
		if hMember then
			RaidPanel.UpdateMemberLFData(hMember)
		end
	elseif szEvent == "PARTY_SET_MEMBER_ONLINE_FLAG" then
		local hMember = RaidPanel.GetMemberHandle(this, arg1)
		if hMember then
			RaidPanel.UpdateMemberLFData(hMember)
			RaidPanel.UpdateMemberHFData(hMember)
			RaidPanel.RefreshMemberBuff(hMember, true, true)
		end
	elseif szEvent == "PARTY_SET_MARK" then
		RaidPanel.UpdateMemberMark(this)
	elseif szEvent == "BUFF_UPDATE" then
		local hMember = RaidPanel.GetMemberHandle(this, arg0)
		if not hMember then
			return
		end
		
		if arg7 then
			RaidPanel.RefreshMemberBuff(hMember, true, true)
			return
		end
		local bDelete = arg1
		local bCanCancel = arg3
		if (bCanCancel and RaidPanel.tGroupSettings.nBuffShowState ~= RAID_PANEL_STATE_SHOW_BUFF) or 
		   (not bCanCancel and RaidPanel.tGroupSettings.nBuffShowState ~= RAID_PANEL_STATE_SHOW_DEBUFF) then
			return
		end
			
		if bDelete then
			RaidPanel.RefreshMemberBuff(hMember, bCanCancel, not bCanCancel)
		else
			local szName = "Handle_Debuff"
			if bCanCancel then
				szName = "Handle_Buff"
			end
			local hBuff = RaidPanel.GetBuffHandle(hMember, szName)
			RaidPanel.UpdateMemberBuff(hBuff, bDelete, arg2, bCanCancel, arg4, arg5, arg6, arg8)
		end
	elseif szEvent == "CLOSE_RAID_TEAM_FRAME" then
		RaidPanel.UpdateGroupTabs(this)
	elseif szEvent == "MINIMIZE_RAID_TEAM_FRAME" then
		this.bMinimize = arg0
		RaidPanel.FormatRaidFrame(this)
	elseif szEvent == "TEAM_AUTHORITY_CHANGED" then
		local hMember = RaidPanel.GetMemberHandle(this, arg2)
		if hMember then
			RaidPanel.UpdateMemberLFData(hMember)
		end
		local hMember = RaidPanel.GetMemberHandle(this, arg3)
		if hMember then
			RaidPanel.UpdateMemberLFData(hMember)
		end
	elseif szEvent == "PARTY_SET_FORMATION_LEADER" then
		local hMemberNewLeader = RaidPanel.GetMemberHandle(this, arg0)
		if hMemberNewLeader then
			local hMemberOldLeader = RaidPanel.GetMemberHandle(this, this.dwFormationLeader)
			this.dwFormationLeader = arg0
			
			RaidPanel.UpdateMemberLFData(hMemberNewLeader)
			if hMemberOldLeader then
				RaidPanel.UpdateMemberLFData(hMemberOldLeader)
			end
		end
	elseif szEvent == "RIAD_FRAME_EDIT_MODE" then
		RaidPanel.UpdateEditMode(this)
	elseif szEvent == "RAID_SHOW_OPTION_UPDATED" then
		RaidPanel.UpdateRaidFrame(this)
	elseif szEvent == "RIAD_READY_CONFIRM_RECEIVE_QUESTION" then
		local hPlayer = GetClientPlayer()
		if arg0 ~= hPlayer.dwID then
			RaidPanel.ConfirmReady(arg0)
		end
	elseif szEvent == "RIAD_READY_CONFIRM_RECEIVE_ANSWER" then
		RaidPanel.tMemberState[arg0].nReadyConfirm = arg1
		RaidPanel.ChangeReadyConfirm(arg0, arg1)
	end
end

function RaidPanel_Base.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_TeamClose" then
		RaidPanel.CloseRaidFrame(this:GetRoot())
	elseif szName == "Btn_Option" then
		local tMenu = {}
		RaidPanel.InsertRaidMenu(tMenu)
		if #tMenu > 0 then
			PopupMenu(tMenu)
		end
	elseif szName == "Btn_CustomWindow" then
		RaidPanel.OpenRaidFrame(this.nGroupID)
		this:Hide()
	else
		local _, _, szIndex = string.find(szName, "Btn_Team(%d+)")
		if szIndex and this.nGroupID then
			RaidPanel.OpenRaidFrame(this.nGroupID)
			this:Hide()
		end
	end	
end

function RaidPanel_Base.OnCheckBoxCheck()
	local szName = this:GetName()
	if szName == "CheckBox_Lock" then
		local hTeam = GetClientTeam()
		for nGroupID = CUSTOM_RAID_GROUP_ID, hTeam.nGroupNum - 1 do
			local hFrame = Station.Lookup("Normal/RaidPanel_" .. nGroupID)
			if hFrame then
				hFrame:EnableDrag(false)
			end
		end
	elseif szName == "CheckBox_Minimize" then
		arg0bak = arg0
		arg0 = true
		FireEvent("MINIMIZE_RAID_TEAM_FRAME")
		arg0 = arg0bak
	end
end

function RaidPanel_Base.OnCheckBoxUncheck()
	local szName = this:GetName()
	if szName == "CheckBox_Lock" then
		local hTeam = GetClientTeam()
		for nGroupID = CUSTOM_RAID_GROUP_ID, hTeam.nGroupNum - 1 do
			local hFrame = Station.Lookup("Normal/RaidPanel_" .. nGroupID)
			if hFrame then
				hFrame:EnableDrag(true)
			end
		end
	elseif szName == "CheckBox_Minimize" then
		arg0bak = arg0
		arg0 = false
		FireEvent("MINIMIZE_RAID_TEAM_FRAME")
		arg0 = arg0bak
	end
end

function RaidPanel_Base.OnItemLButtonClick()
	local szName = this:GetName()
	local _, _, szIndex = string.find(szName, "Handle_Player_(%d+)")
	if szIndex and this.dwID then
		SetTarget(TARGET.PLAYER, this.dwID)
	end
end

function RaidPanel_Base.OnItemRButtonClick()
	local tMenu = {}
	local szName = this:GetName()
	if szName == "Handle_TeamTitle" then
		RaidPanel.InsertGroupTitleMenu(tMenu, this:GetRoot().nGroupID)
	elseif szName == "Handle_RaidMain" then
		local tMenu = {}
		RaidPanel.InsertRaidMenu(tMenu)
		if #tMenu > 0 then
			PopupMenu(tMenu)
		end
	else
		local _, _, szIndex = string.find(szName, "Handle_Player_(%d+)")
		if szIndex then
			local hPlayer = GetClientPlayer()
			local hTeam = GetClientTeam()
			if hTeam.GetAuthorityInfo(TEAM_AUTHORITY_TYPE.LEADER) == hPlayer.dwID then
				RaidPanel.InsertChangeGroupMenu(tMenu, this.dwID)
			end
			
			if this.dwID ~= hPlayer.dwID then
				InsertTeammateMenu(tMenu, this.dwID)
			else
				InsertPlayerMenu(tMenu)
			end
		end
	end
	if tMenu and #tMenu > 0 then
		PopupMenu(tMenu)
	end
end

function RaidPanel_Base.OnItemMouseEnter()
	local szName = this:GetName()
	if szName == "Image_Health" then
		this:GetParent():Lookup("Text_Health"):Show()
	elseif szName == "Image_Mana" then
		local hMember = this:GetParent()
		if not hMember.bHideMana then
			hMember:Lookup("Text_Mana"):Show()
		end
	elseif szName == "Image_RightButton_N" then
		this:SetFrame(94)
	else
		local _, _, szIndex = string.find(szName, "Handle_Player_(%d+)")
		if szIndex and this.dwID then
			OutputTeamMemberTip(this.dwID)
			if bRaidEditMode then
				this:Lookup("Image_EditBgOver"):Show()
			end
		end
	end
end

function RaidPanel_Base.OnItemMouseLeave()
	HideTip()
	local szName = this:GetName()
	if szName == "Image_Health" then
		this:GetParent():Lookup("Text_Health"):Hide()
	elseif szName == "Image_Mana" then
		local hMember = this:GetParent()
		if not hMember.bHideMana then
			hMember:Lookup("Text_Mana"):Hide()
		end
	elseif szName == "Image_RightButton_N" then
		this:SetFrame(93)
	else
		local _, _, szIndex = string.find(szName, "Handle_Player_(%d+)")
		if szIndex and this.dwID and bRaidEditMode then
			this:Lookup("Image_EditBgOver"):Hide()
		end
	end
end

local nDragGroupID = nil
local dwDragMemberID = nil
function RaidPanel_Base.OnItemLButtonDrag()
	local szName = this:GetName()
	local _, _, szIndex = string.find(szName, "Handle_Player_(%d+)")
	if szIndex and bRaidEditMode then
		local hFrame = this:GetRoot()
		if hFrame.nGroupID == CUSTOM_RAID_GROUP_ID then
			for nIndex, dwMemberID in ipairs(RaidPanel.tCustomGroup.MemberList) do
				if dwMemberID == this.dwID then
					table.remove(RaidPanel.tCustomGroup.MemberList, nIndex)
					break
				end
			end
			local hRaidFrame = Station.Lookup("Normal/RaidPanel_" .. CUSTOM_RAID_GROUP_ID)
			RaidPanel.UpdateRaidFrame(hRaidFrame)
		else
			nDragGroupID = hFrame.nGroupID
			dwDragMemberID = this.dwID
			OpenRaidDragPanel(this.dwID)
		end
	end
end

function RaidPanel_Base.OnItemLButtonDragEnd()
	local hFrame = this:GetRoot()
	local nTargetGroup = hFrame.nGroupID
	if nDragGroupID and dwDragMemberID and nTargetGroup and (nDragGroupID ~= nTargetGroup) then
		if nTargetGroup == CUSTOM_RAID_GROUP_ID then
			RaidPanel.CustomGroupAddMember(hFrame, dwDragMemberID)
		else
			local nTargetMember = 0
			local _, _, szIndex = string.find(this:GetName(), "Handle_Player_(%d+)")
			if szIndex then
				nTargetMember = this.dwID
			end
			local hPlayer = GetClientPlayer()
			local hTeam = GetClientTeam()
			if (hFrame.nCount < MAX_RAID_GROUP_MEMBER_COUNT or nTargetMember ~= 0)
			and hTeam.GetAuthorityInfo(TEAM_AUTHORITY_TYPE.LEADER) == hPlayer.dwID then
				hTeam.ChangeMemberGroup(dwDragMemberID, nTargetGroup, nTargetMember)
			end
		end
		nDragGroupID = nil
		dwDragMemberID = nil
		CloseRaidDragPanel()
	end
end

function RaidPanel_Base.OnItemLButtonDown()
	local szName = this:GetName()
	if szName == "Image_RightButton_N" then
		this:SetFrame(95)
	end
end

function RaidPanel_Base.OnItemLButtonUp()
	local szName = this:GetName()
	if szName == "Image_RightButton_N" then
		this:SetFrame(93)
		local tMenu = {}
		local handlePlayer = this:GetParent():GetParent()
		local szHandle = handlePlayer:GetName()
		local _, _, szIndex = string.find(szHandle, "Handle_Player_(%d+)")
		if szIndex then
			local hPlayer = GetClientPlayer()
			local hTeam = GetClientTeam()
			if hTeam.GetAuthorityInfo(TEAM_AUTHORITY_TYPE.LEADER) == hPlayer.dwID then
				RaidPanel.InsertChangeGroupMenu(tMenu, handlePlayer.dwID)
			end
			
			if handlePlayer.dwID ~= hPlayer.dwID then
				InsertTeammateMenu(tMenu, handlePlayer.dwID)
			else
				InsertPlayerMenu(tMenu)
			end
		end
		if tMenu and #tMenu > 0 then
			PopupMenu(tMenu)
		end
	else
		if this.dwID == dwDragMemberID then
			nDragGroupID = nil
			dwDragMemberID = nil
		end
		CloseRaidDragPanel()
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------



RaidPanel = 
{
	tMemberState = {},
	tCustomGroup = { MemberList = {} },
	
	tGroupSettings = {
		nUseStyle = 0,
		nBuffShowState = RAID_PANEL_STATE_SHOW_BUFF,
		bShowDistanceColor = true,
	},
}

RegisterCustomData("RaidPanel.tGroupSettings")

function RaidPanel.OpenRaidFrame(nGroupID)
	local hRaidFrame = Station.Lookup("Normal/RaidPanel_" .. nGroupID)
	if not hRaidFrame then
		hRaidFrame = Wnd.OpenWindow("RaidPanel", "RaidPanel_" .. nGroupID)
		hRaidFrame.nGroupID = nGroupID
	end
	
	RaidPanel.UpdateRaidFrame(hRaidFrame)
	RaidPanel.UpdatePosition(hRaidFrame)
end

function RaidPanel.CloseRaidFrame(hFrame)
	Wnd.CloseWindow(hFrame)
	FireEvent("CLOSE_RAID_TEAM_FRAME")
end

function RaidPanel.UpdateRaidFrame(hFrame)
	local hPlayer = GetClientPlayer()
	local hTeam = GetClientTeam()
	
	local tGroupInfo = RaidPanel.GetGroupInfo(hFrame.nGroupID)
	if not tGroupInfo then
		Log("[UI DEBUG] function RaidPanel.UpdateRaidFrame(hFrame) tGroupInfo = nil, nGroupID = " .. tostring(hFrame.nGroupID))
		return
	end
	
	hFrame.nCount = #tGroupInfo.MemberList
	
	local nMaxCount = MAX_RAID_GROUP_MEMBER_COUNT
	if hFrame.nGroupID == CUSTOM_RAID_GROUP_ID then
		nMaxCount = MAX_RAID_CUSTOM_GROUP_MEMBER_COUNT
	end
	local szTitle = string.format(
		"%s(%d/%d)", 
		RaidPanel.GetGroupTitle(hFrame.nGroupID),
		hFrame.nCount,
		nMaxCount
	)
	local hGroupTitle = hFrame:Lookup("Wnd_Team", "Handle_TeamTitle/Text_TeamTitle")
	hGroupTitle:SetText(szTitle)
	
	local nPlayerGroupID = hTeam.GetMemberGroupIndex(hPlayer.dwID)
	hFrame.bMainFrame = (hFrame.nGroupID == nPlayerGroupID)
	
	local hMemberList = hFrame:Lookup("Wnd_Team", "Handle_PlayerList")
	hMemberList:Clear()
	
	hFrame.dwFormationLeader = tGroupInfo.dwFormationLeader
	
	for _, dwMemberID in ipairs(tGroupInfo.MemberList) do
		if not RaidPanel.tMemberState[dwMemberID] then
			RaidPanel.tMemberState[dwMemberID] = { bHide = false, nReadyConfirm = READY_CONFIRM_OK }
		end
				
		if not RaidPanel.tMemberState[dwMemberID].bHide then
			local hMember = hMemberList:AppendItemFromIni(
				RAIDPANEL_INI_FILE, 
				"Handle_Player", 
				"Handle_Player_" .. dwMemberID
			)
			hMember.dwID = dwMemberID
			if not RaidPanel.tGroupSettings.bShowDistanceColor then
				hMember:Lookup("Image_State"):Hide()
			end
			RaidPanel.UpdateMemberLFData(hMember)
			RaidPanel.UpdateMemberHFData(hMember)
			RaidPanel.RefreshMemberBuff(hMember, true, true)
		end
	end
	if RaidPanel.tGroupSettings.bShowDistanceColor then
		RaidPanel.UpdateDistance(hFrame)
	end
	
	RaidPanel.UpdateEditMode(hFrame)
	RaidPanel.UpdateMemberMark(hFrame)
	RaidPanel.FormatRaidFrame(hFrame)
end

function RaidPanel.UpdateDistance(hFrame)
	local hPlayer = GetClientPlayer()
	if not hPlayer then
		return 
	end
	hFrame.nStartTime = GetTickCount()
	local dwPlayerID = hPlayer.dwID
	local hMemberList = hFrame:Lookup("Wnd_Team", "Handle_PlayerList")
	local nCount = hMemberList:GetItemCount()
	for i = 0, nCount - 1 do 
		local hMember = hMemberList:Lookup(i)
		if dwPlayerID ~= dwID and hMember.bOnline then
			local hImageState = hMember:Lookup("Image_State")
			local dwDistance = GetCharacterDistance(dwPlayerID, hMember.dwID)
			if dwDistance == -1 then
				hImageState:Show()
				hImageState:SetFrame(84)
			else 
				if dwDistance < RAID_FRAME_CLOSE_DISTANCE_LOWER then 
					hImageState:Hide()
				elseif dwDistance < RAID_FRAME_CLOSE_DISTANCE then
					hImageState:Show()
					hImageState:SetFrame(83)
				else
					hImageState:Show()
					hImageState:SetFrame(85)
				end
			end
		end
	end
end

function RaidPanel.UpdateLFAlpha(hFrame)
	local hPlayer = GetClientPlayer()
	if not hPlayer then
		return 
	end
	local dwPlayerID = hPlayer.dwID
	local hMemberList = hFrame:Lookup("Wnd_Team", "Handle_PlayerList")
	local nCount = hMemberList:GetItemCount()
	for i = 0, nCount - 1 do 
		local hMember = hMemberList:Lookup(i)
		local hImageLife = hMember:Lookup("Image_Health")
		local hShadow = hMember:Lookup("Image_Shadow")
		
		if hImageLife:GetPercentage() < RAID_FRAME_MEMBER_LOWER_LIFE and hImageLife:GetPercentage() > 0 then
			if not hImageLife.bLow then
				hImageLife.bLow = true
				hShadow:Show()
				hShadow:SetAlpha(0)
				hShadow:SetUserData(1)
			end
			
			local nAlpha = hShadow:GetAlpha()
			if hShadow:GetUserData() == 1 then
				nAlpha = nAlpha + 30
				hShadow:SetAlpha(nAlpha)
				if nAlpha > 150 then
					hShadow:SetUserData(0)
				end
			else
				nAlpha = nAlpha - 30
				hShadow:SetAlpha(nAlpha)
				if nAlpha < 0 then
					hShadow:SetUserData(1)
				end
			end
		else
			hShadow:Hide()
			hImageLife.bLow = false
		end
	end
end

function RaidPanel.FormatRaidFrame(hFrame)
	local hWndTabs = hFrame:Lookup("Wnd_Tabs")
	local hWndTeam = hFrame:Lookup("Wnd_Team")
	local hWndMainTitle = hFrame:Lookup("Wnd_MainTitle")
	if hFrame.bMinimize then
		if hFrame.bMainFrame then
			hWndMainTitle:Show()
			hWndTeam:Hide()
			hWndTabs:Hide()
			local _, nTitleHeight = hWndMainTitle:GetSize()
			local nFrameWidth, _ = hFrame:GetSize()
			hFrame:SetSize(nFrameWidth, nTitleHeight)
		else
			RaidPanel.CloseRaidFrame(hFrame)
		end
		return
	end
		
	local hBtnClose = hFrame:Lookup("Wnd_Team/Btn_TeamClose")
	if hFrame.bMainFrame then
		hWndMainTitle:Show()
		hWndTeam:Show()
		hWndTabs:Show()
		hBtnClose:Hide()
	else
		hWndMainTitle:Hide()
		hWndTabs:Hide()
		hBtnClose:Show()
	end
	
	local hPlayer = GetClientPlayer()
	local hHandleTeam = hWndTeam:Lookup("", "")
	local hMemberList = hHandleTeam:Lookup("Handle_PlayerList")
	local nCount = hMemberList:GetItemCount()
	for i = 0, nCount - 1 do
		local hMember = hMemberList:Lookup(i)
		if hMember.dwID == hPlayer.dwID then
			hMember:SetUserData(0)
		elseif hMember.bLeader then
			hMember:SetUserData(1)
		elseif hMember.bOnline then
			hMember:SetUserData(2)
		else
			hMember:SetUserData(3)
		end
		
		local nWidth, nHeight = hMember:GetSize()
		if RaidPanel.tGroupSettings.nBuffShowState ~= RAID_PANEL_STATE_NOT_SHOW_BUFFS then
			hMember:SetSize(nWidth, 65)
		else
			hMember:SetSize(nWidth, 50)
		end
	end
	hMemberList:Sort()
	hMemberList:FormatAllItemPos()
	
	local _, nHeight = hMemberList:GetAllItemSize()
	nHeight = nHeight + 10
	if RaidPanel.tGroupSettings.nBuffShowState ~= RAID_PANEL_STATE_NOT_SHOW_BUFFS then
		if nHeight < 350 then -- Default Min Size 350
			nHeight = 350
		end
	else
		if nHeight < 280 then -- Default Min Size 300
			nHeight = 280
		end
	end
	local nListWidth, _ = hMemberList:GetSize()
	hMemberList:SetSize(nListWidth, nHeight)
	
	local hTeamTitle = hHandleTeam:Lookup("Handle_TeamTitle")
	local _, nTitleHeight = hTeamTitle:GetSize()
	nHeight = nHeight + nTitleHeight
	
	local hImgBg = hHandleTeam:Lookup("Image_TeamBg")
	local nBgWidth, _ = hImgBg:GetSize()
	hImgBg:SetSize(nBgWidth, nHeight)
	
	local nHandleTeamWidth, _ = hHandleTeam:GetSize()
	hHandleTeam:SetSize(nHandleTeamWidth, nHeight)
	hWndTeam:SetSize(nHandleTeamWidth, nHeight)
	
	local nTabsWidth, _ = hWndTabs:GetSize()
	hWndTabs:SetSize(nTabsWidth, nHeight)
	
	local _, nRaidMainHeight = hWndMainTitle:GetSize()
	nHeight = nHeight + nRaidMainHeight
	
	local nFrameWidth, _ = hFrame:GetSize()
	hFrame:SetSize(nFrameWidth, nHeight)
		
	RaidPanel.UpdateGroupTabs(hFrame)
end

function RaidPanel.UpdateMemberMark(hFrame)
	local hTeam = GetClientTeam()
	local tPartyMark = hTeam.GetTeamMark()
	if not tPartyMark then
		return
	end
	
	local hMemberList = hFrame:Lookup("Wnd_Team", "Handle_PlayerList")
	local nCount = hMemberList:GetItemCount()
	for nIndex = 0, nCount - 1 do
		local hMember = hMemberList:Lookup(nIndex)
		
		local nIconFrame = nil
		local nMarkID = tPartyMark[hMember.dwID]
		if nMarkID then
			assert(nMarkID > 0 and nMarkID <= #PARTY_MARK_ICON_FRAME_LIST)
			nIconFrame = PARTY_MARK_ICON_FRAME_LIST[nMarkID]
		end
		
		local hImageMark = hMember:Lookup("Image_NPCMark")
		if nIconFrame then
			hImageMark:FromUITex(PARTY_MARK_ICON_PATH, nIconFrame)
			hImageMark:Show()
		else
			hImageMark:Hide()
		end
	end	
end

function RaidPanel.UpdatePosition(hFrame)
	local tSetting = RaidPanel.tGroupSettings[hFrame.nGroupID]
	if tSetting and tSetting.tPos then
		hFrame:SetRelPos(tSetting.tPos.nX, tSetting.tPos.nY)
		return
	end
	
	local tDefaultPos = nil
	if hFrame.bMainFrame then
		tDefaultPos = tMainFramePosition
	else
		local nIndex = 1
		for i = 0, hFrame.nGroupID do
			local hFrame = Station.Lookup("Normal/RaidPanel_" .. i)
			if hFrame and not hFrame.bMainFrame then
				nIndex = nIndex + 1
			end
		end
		tDefaultPos = tRaidFramePosition[nIndex]
	end
	
	if tDefaultPos then
		hFrame:SetRelPos(tDefaultPos.nX, tDefaultPos.nY)
	end
end

function RaidPanel.UpdateKungfu(handle, tMemberInfo)
	local img = handle:Lookup("Image_School")
	if RaidPanel.tGroupSettings.nUseStyle ~= 0 then
		img:Hide()
		return
	end
--	local kf = GetSkill(tMemberInfo.dwMountKungfuID, 1)
--	local dwKungfuType = 0
--	if kf then
--		dwKungfuType = kf.dwMountType
--	end
--	local szPath, nFrame = GetKungfuImage(dwKungfuType)
	local szPath, nFrame = GetForceImage(tMemberInfo.dwForceID)
	img:Show()
	img:FromUITex(szPath, nFrame)
end

function RaidPanel.UpdateMemberLFData(hMember)
	local hTeam = GetClientTeam()
	local tMemberInfo = hTeam.GetMemberInfo(hMember.dwID)
	local dwMountType = 0
	
	if tMemberInfo.dwMountKungfuID ~= 0 then
		local kf = GetSkill(tMemberInfo.dwMountKungfuID, 1)
		if kf then
			dwMountType = kf.dwMountType
		end
	end
	hMember.bHideMana = IsPlayerManaHide(dwMountType)
	
	local imgForce = hMember:Lookup("Image_Force")
	local imgForce1 = hMember:Lookup("Image_Force_1")
	local hTextName = hMember:Lookup("Text_Name")
	local hTextName1 = hMember:Lookup("Text_Name_1")
	
	if RaidPanel.tGroupSettings.nUseStyle == 0 then
		local szPath = ""
		local nFrame = 0
		if tMemberInfo.dwMiniAvatarID == 0 then
			szPath, nFrame = GetForceImage(tMemberInfo.dwForceID)
			imgForce:SetImageType(IMAGE.NORMAL)
			imgForce:FromUITex(szPath, nFrame)
		else
			szPath = GetPlayerMiniAvatarFile(tMemberInfo.dwMiniAvatarID, tMemberInfo.bIsOnLine)
			imgForce:SetImageType(IMAGE.FLIP_HORIZONTAL)
			imgForce:FromTextureFile(szPath)
		end
		imgForce:Show()
		imgForce1:Hide()
		hMember:Lookup("Handle_RightButton"):Lookup("Image_RightButton_N"):Show()
		hTextName:Show()
		hTextName1:Hide()
		hTextName:SetText(tMemberInfo.szName)
	elseif RaidPanel.tGroupSettings.nUseStyle == 1 or tMemberInfo.dwMountKungfuID == 0 then
		local szPath, nFrame = GetForceImage(tMemberInfo.dwForceID)
		imgForce:Hide()
		imgForce1:Show()
		imgForce1:FromUITex(szPath, nFrame)
		hMember:Lookup("Handle_RightButton"):Lookup("Image_RightButton_N"):Hide()
		
		hTextName:Hide()
		hTextName1:Show()
		hTextName1:SetText(tMemberInfo.szName)
	else
		local nIconID = Table_GetSkillIconID(tMemberInfo.dwMountKungfuID, 0)
		imgForce:Hide()
		imgForce1:Show()
		imgForce1:FromIconID(nIconID)
		hMember:Lookup("Handle_RightButton"):Lookup("Image_RightButton_N"):Hide()
		
		hTextName:Hide()
		hTextName1:Show()
		hTextName1:SetText(tMemberInfo.szName)
	end
		
	RaidPanel.UpdateKungfu(hMember, tMemberInfo)
	
	local hImageOffline = hMember:Lookup("Image_OffLine")
	local hImageLife = hMember:Lookup("Image_Health")
	local hImageMana = hMember:Lookup("Image_Mana")
	local hImageState = hMember:Lookup("Image_State")
	hMember.bOnline = tMemberInfo.bIsOnLine
	if hMember.bOnline then
		hTextName:SetFontScheme(18)
		hTextName1:SetFontScheme(18)
		hImageLife:Show()
		hImageMana:Show()
	else
		hTextName:SetFontScheme(108)
		hTextName1:SetFontScheme(108)
		hImageLife:Hide()
		hImageMana:Hide()
		hImageState:Hide()
	end
	
	if hMember.bHideMana then
		hImageMana:Hide()
	end
	
	local hTextLevel = hMember:Lookup("Text_Level")
	if RaidPanel.tGroupSettings.bShowLevel and hMember.bOnline then
		hTextLevel:SetText(tMemberInfo.nLevel)
		hTextLevel:Show()
	else
		hTextLevel:Hide()
	end
	
	local nCampFrame = nil
	if tMemberInfo.nCamp == CAMP.GOOD then
		nCampFrame = 7
	elseif tMemberInfo.nCamp == CAMP.EVIL then
		nCampFrame = 5
	end
	local hImageCamp = hMember:Lookup("Image_Camp")
	if RaidPanel.tGroupSettings.bShowCamp and nCampFrame then
		hImageCamp:SetFrame(nCampFrame)
		hImageCamp:Show()
	else
		hImageCamp:Hide()
	end
	
	local hImageCover = hMember:Lookup("Image_Cover")
	if not bHideReadyConfirm and RaidPanel.tMemberState[hMember.dwID].nReadyConfirm ~= READY_CONFIRM_OK then
		hImageCover:Show()
	else
		hImageCover:Hide()
	end

	local hImageReady = hMember:Lookup("Image_Ready")
	if not bHideReadyConfirm and RaidPanel.tMemberState[hMember.dwID].nReadyConfirm == READY_CONFIRM_NOT_YET then
		hImageReady:Show()
	else
		hImageReady:Hide()
	end
	
	local hImageLeader = hMember:Lookup("Image_Flag")
	hMember.bLeader = (hTeam.GetAuthorityInfo(TEAM_AUTHORITY_TYPE.LEADER) == hMember.dwID)
	if hMember.bLeader then
		hImageLeader:Show()
	else
		hImageLeader:Hide()
	end
	
	local hImageDistribute = hMember:Lookup("Image_Boss")
	if hTeam.GetAuthorityInfo(TEAM_AUTHORITY_TYPE.DISTRIBUTE) == hMember.dwID then
		hImageDistribute:Show()
	else
		hImageDistribute:Hide()
	end
	
	local hImageMark = hMember:Lookup("Image_Mark")
	if hTeam.GetAuthorityInfo(TEAM_AUTHORITY_TYPE.MARK) == hMember.dwID then
		hImageMark:Show()
	else
		hImageMark:Hide()
	end
	
	local hImageFormation = hMember:Lookup("Image_Center")
	if hMember:GetRoot().dwFormationLeader == hMember.dwID then
		hImageFormation:Show()
	else
		hImageFormation:Hide()
	end
	
	local hMatrix = hMember:Lookup("Handle_Matrix")
	hMatrix.nFormationCoefficient = GetFormationEffect(tMemberInfo.nFormationCoefficient)
	for i = 1, 7 do
		local hMatrixPoint = hMatrix:Lookup("Image_" .. i .. "H")
		if i <= hMatrix.nFormationCoefficient then
			hMatrixPoint:Show()
		else
			hMatrixPoint:Hide()
		end
	end
end

function RaidPanel.UpdateMemberHFData(hMember)
	local hTeam = GetClientTeam()
	local tMemberInfo = hTeam.GetMemberInfo(hMember.dwID)
			
	local hImageLife = hMember:Lookup("Image_Health")
	local hTextHealth = hMember:Lookup("Text_Health")
	if tMemberInfo.nMaxLife > 0 then
		hImageLife:SetPercentage(tMemberInfo.nCurrentLife / tMemberInfo.nMaxLife)
		hTextHealth:SetText(tMemberInfo.nCurrentLife .. "/" .. tMemberInfo.nMaxLife)
	end

	local hImageMana = hMember:Lookup("Image_Mana")
	local hTextMana = hMember:Lookup("Text_Mana")
	if tMemberInfo.nMaxMana > 0 and tMemberInfo.nMaxMana ~= 1 then
		hImageMana:SetPercentage(tMemberInfo.nCurrentMana / tMemberInfo.nMaxMana)
		hTextMana:SetText(tMemberInfo.nCurrentMana .. "/" .. tMemberInfo.nMaxMana)
	end
	
	local dwMountType = 0
	if tMemberInfo.dwMountKungfuID ~= 0 then
		local kf = GetSkill(tMemberInfo.dwMountKungfuID, 1)
		if kf then
			dwMountType = kf.dwMountType
		end
	end
	hMember.bHideMana = IsPlayerManaHide(dwMountType)
	
	if hMember.bHideMana then
		hImageMana:Hide()
	else
		hImageMana:Show()
	end
end

function RaidPanel.OnMemberChangeGroup(dwSrcMember, nSrcGroup, dwDesMember, nDesGroup)
	local hPlayer = GetClientPlayer()
	local hTeam = GetClientTeam()
	
	local hSrcFrame = Station.Lookup("Normal/RaidPanel_" .. nSrcGroup)
	local hDesFrame = Station.Lookup("Normal/RaidPanel_" .. nDesGroup)
	
	if dwSrcMember == hPlayer.dwID then
		if not hDesFrame then
			RaidPanel.OpenRaidFrame(nDesGroup)
			if hSrcFrame then
				RaidPanel.CloseRaidFrame(hSrcFrame)
			end
		else
			RaidPanel.UpdateRaidFrame(hDesFrame)
			if hSrcFrame then
				RaidPanel.UpdateRaidFrame(hSrcFrame)
			end
		end
	elseif dwDesMember == hPlayer.dwID then
		if not hSrcFrame then
			RaidPanel.OpenRaidFrame(nSrcGroup)
			if hDesFrame then
				RaidPanel.CloseRaidFrame(hDesFrame)
			end
		else
			RaidPanel.UpdateRaidFrame(hSrcFrame)
			if hDesFrame then
				RaidPanel.UpdateRaidFrame(hDesFrame)
			end
		end
	else
		if hSrcFrame then
			RaidPanel.UpdateRaidFrame(hSrcFrame)
		end
		if hDesFrame then
			RaidPanel.UpdateRaidFrame(hDesFrame)
		end

		local nMyGroup = hTeam.GetMemberGroupIndex(hPlayer.dwID)
		local hMainFrame = Station.Lookup("Normal/RaidPanel_" .. nMyGroup)
		RaidPanel.UpdateGroupTabs(hMainFrame)
	end
	
	rlcmd("UpdateLODLevel")
end

function RaidPanel.UpdateEditMode(hFrame)
	local hMemberList = hFrame:Lookup("Wnd_Team", "Handle_PlayerList")
	local nCount = hMemberList:GetItemCount()
	for i = 0, nCount - 1 do
		local hMember = hMemberList:Lookup(i)
		local hImgEditBg = hMember:Lookup("Image_EditBg")
		if bRaidEditMode then
			hImgEditBg:Show()
		else
			hImgEditBg:Hide()
		end
	end	
end

function RaidPanel.GetMemberHandle(hFrame, dwID)
	if not hFrame then
		local hTeam = GetClientTeam()
		local nGroupID = hTeam.GetMemberGroupIndex(dwID)
		hFrame = Station.Lookup("Normal/RaidPanel_" .. nGroupID)
	end
	
	if not hFrame then
		return
	end
	
	local hMemberList = hFrame:Lookup("Wnd_Team", "Handle_PlayerList")
	local nCount = hMemberList:GetItemCount()
	for nIndex = 0, nCount - 1 do
		local hMember = hMemberList:Lookup(nIndex)
		if hMember.dwID == dwID then
			return hMember
		end
	end		
end

function RaidPanel.CustomGroupAddMember(hCustomFrame, dwMemberID)
	if #RaidPanel.tCustomGroup.MemberList >= MAX_RAID_CUSTOM_GROUP_MEMBER_COUNT then
		return
	end

	for nIndex, dwMemberID in ipairs(RaidPanel.tCustomGroup.MemberList) do
		if dwMemberID == dwDragMemberID then
			table.remove(RaidPanel.tCustomGroup.MemberList, nIndex)
			break
		end
	end
	table.insert(RaidPanel.tCustomGroup.MemberList, dwMemberID)
	
	if not hCustomFrame then
		hCustomFrame = Station.Lookup("Normal/RaidPanel_" .. CUSTOM_RAID_GROUP_ID)
	end
	if hCustomFrame then
		RaidPanel.UpdateRaidFrame(hCustomFrame)
	end
end

function RaidPanel.CustomGroupDelMember(hCustomFrame, dwMemberID)
	local bUpdate = false
	local nCount = #RaidPanel.tCustomGroup.MemberList
	for i = nCount, 1, -1 do
		if RaidPanel.tCustomGroup.MemberList[i] == dwMemberID then
			table.remove(RaidPanel.tCustomGroup.MemberList, i)
			bUpdate = true
		end		
	end
	
	if not bUpdate then
		return
	end
	
	if not hCustomFrame then
		hCustomFrame = Station.Lookup("Normal/RaidPanel_" .. CUSTOM_RAID_GROUP_ID)
	end
	if hCustomFrame then
		RaidPanel.UpdateRaidFrame(hCustomFrame)
	end
end

function RaidPanel.SetFrameAlpha(fAlpha)
	local nAlpha = fAlpha * 255
	for nGroupID = CUSTOM_RAID_GROUP_ID, MAX_RAID_GROUP_COUNT do
		local hFrame = Station.Lookup("Normal/RaidPanel_" .. nGroupID)
		if hFrame then
			local hBg = hFrame:Lookup("Wnd_Team", "Image_TeamBg")
			hBg:SetAlpha(nAlpha)
		end
	end
end

function RaidPanel.GetFrameAlpha()
	for nGroupID = CUSTOM_RAID_GROUP_ID, MAX_RAID_GROUP_COUNT do
		local hFrame = Station.Lookup("Normal/RaidPanel_" .. nGroupID)
		if hFrame and hFrame.bMainFrame then
			local hBg = hFrame:Lookup("Wnd_Team", "Image_TeamBg")
			local nAlpha = hBg:GetAlpha()
			return nAlpha / 255
		end
	end
end

function RaidPanel.InsertRaidMenu(tMenu)
	local tSubMenu = nil
	local hTeam = GetClientTeam()
	local hPlayer = GetClientPlayer()
	if hTeam.GetAuthorityInfo(TEAM_AUTHORITY_TYPE.DISTRIBUTE) == hPlayer.dwID then
		InsertDistributeMenu(tMenu, hTeam.bSystem)
	end
	
	tSubMenu = 
	{
		szOption = g_tStrings.STR_RAID_MENU_RAID_EDIT, 
		bCheck = true, 
		bChecked = bRaidEditMode,
		fnAction = function(tUserData, bCheck)
			bRaidEditMode = bCheck
			GetPopupMenu():Hide()
			FireEvent("RIAD_FRAME_EDIT_MODE")
		end
	}
	table.insert(tMenu, tSubMenu)
		
	tSubMenu = 
	{
		szOption = g_tStrings.STR_RAID_MENU_READY_CONFIRM,
		bDisable = not IsLeader(),
		fnAction = function()
			local tMsg = 
			{
				szMessage = g_tStrings.STR_RAID_MSG_START_READY_CONFIRM,
				szName = "StartReadyConfirm",
				{szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = function() RaidPanel.StartReadyConfirm() end, },
				{szOption = g_tStrings.STR_HOTKEY_CANCEL, },
			}
			MessageBox(tMsg)
		end
	}
	table.insert(tMenu, tSubMenu)
		
	tSubMenu = 
	{
		szOption = g_tStrings.STR_RAID_MENU_HIDE_READY_CONFIRM,
		bCheck = true,
		bChecked = bHideReadyConfirm,
		fnAction = function(tUserData, bCheck)
			bHideReadyConfirm = bCheck
			RaidPanel.UpdateReadyConfirm()
			GetPopupMenu():Hide()
		end
	}
	table.insert(tMenu, tSubMenu)
	
	table.insert(tMenu, {bDevide = true})
	
	tSubMenu = 
	{
		szOption = g_tStrings.STR_RAID_MENU_BG_ALPHA,
		fnAction = function()
			local nPosX, nPosY = Cursor.GetPos()
			GetUserPercentage(
				RaidPanel.SetFrameAlpha, 
				nil, 
				RaidPanel.GetFrameAlpha(), 
				g_tStrings.WINDOW_ADJUST_BG_ALPHA, 
				{nPosX, nPosY, nPosX + 1, nPosY + 1}
			)
		end
	}
	table.insert(tMenu, tSubMenu)
	
	tSubMenu = 
	{
		szOption = g_tStrings.STR_RAID_MENU_OPEN_TEAMMATE,
		bCheck = true,
		bChecked = IsTeammateOpened(),
		fnAction = function(tUserData, bCheck) 
			if bCheck then
				OpenTeammate()
			else
				CloseTeammate()
			end
			GetPopupMenu():Hide()
		end,
	}
	table.insert(tMenu, tSubMenu)
	
	tSubMenu = 
	{
		szOption = g_tStrings.STR_RAID_MENU_SHOW_LEVEL,
		bCheck = true,
		bChecked = RaidPanel.tGroupSettings.bShowLevel,
		fnAction = function(tUserData, bCheck)
			RaidPanel.tGroupSettings.bShowLevel = bCheck
			FireEvent("RAID_SHOW_OPTION_UPDATED")
			GetPopupMenu():Hide()
		end,
	}
	table.insert(tMenu, tSubMenu)
	
	tSubMenu = 
	{
		szOption = g_tStrings.STR_RAID_MENU_SHOW_CAMP,
		bCheck = true,
		bChecked = RaidPanel.tGroupSettings.bShowCamp,
		fnAction = function(tUserData, bCheck) 
			RaidPanel.tGroupSettings.bShowCamp = bCheck
			FireEvent("RAID_SHOW_OPTION_UPDATED")
			GetPopupMenu():Hide()
		end,
	}
	table.insert(tMenu, tSubMenu)
	
	table.insert(tMenu, {bDevide = true})
	
	local fnShowColorDistance = function(UserData, bCheck)
		RaidPanel.tGroupSettings.bShowDistanceColor = not bCheck
		FireEvent("RAID_SHOW_OPTION_UPDATED")
		GetPopupMenu():Hide()
	end
	
	tSubMenu = { 
		szOption = g_tStrings.STR_RAID_MENU_SHOW_DISTANCE_COLOR,
		bCheck = true,
		bChecked = not RaidPanel.tGroupSettings.bShowDistanceColor,
		fnAction = fnShowColorDistance,
	}
	table.insert(tMenu, tSubMenu)
	
	table.insert(tMenu, {bDevide = true})
	
	local fnBuffShowState = function(UserData, bCheck)
		RaidPanel.tGroupSettings.nBuffShowState = UserData
		FireEvent("RAID_SHOW_OPTION_UPDATED")
		GetPopupMenu():Hide()
	end
	
	tSubMenu = { 
		szOption = g_tStrings.STR_RAID_MENU_NOT_SHOW_DEBUFF_AND_DEBUFF,
		bMCheck = true,
		bChecked = RaidPanel.tGroupSettings.nBuffShowState == RAID_PANEL_STATE_NOT_SHOW_BUFFS,
		UserData = RAID_PANEL_STATE_NOT_SHOW_BUFFS,
		fnAction = fnBuffShowState,
	}
	table.insert(tMenu, tSubMenu)
	
	tSubMenu = { 
		szOption = g_tStrings.STR_RAID_MENU_SHOW_BUFF,
		bMCheck = true,
		bChecked = RaidPanel.tGroupSettings.nBuffShowState == RAID_PANEL_STATE_SHOW_BUFF,
		UserData = RAID_PANEL_STATE_SHOW_BUFF,
		fnAction = fnBuffShowState,
	}
	table.insert(tMenu, tSubMenu)
	
	tSubMenu = { 
		szOption = g_tStrings.STR_RAID_MENU_SHOW_DEBUFF,
		bMCheck = true,
		bChecked = RaidPanel.tGroupSettings.nBuffShowState == RAID_PANEL_STATE_SHOW_DEBUFF,
		UserData = RAID_PANEL_STATE_SHOW_DEBUFF,
		fnAction = fnBuffShowState,
	}
	table.insert(tMenu, tSubMenu)
	
	table.insert(tMenu, {bDevide = true})
	
	tSubMenu = {
		szOption = g_tStrings.STR_RAID_MENU_USE_AVATAR,
		bMCheck = true,
		bChecked = RaidPanel.tGroupSettings.nUseStyle == 0,
		fnAction = function(tUserData, bCheck)
			RaidPanel.tGroupSettings.nUseStyle = 0
			FireEvent("RAID_SHOW_OPTION_UPDATED")
			GetPopupMenu():Hide()
		end,
	}
	table.insert(tMenu, tSubMenu)
	
	tSubMenu = {
		szOption = g_tStrings.STR_RAID_MENU_USE_SCHOOL,
		bMCheck = true,
		bChecked = RaidPanel.tGroupSettings.nUseStyle == 1,
		fnAction = function(tUserData, bCheck)
			RaidPanel.tGroupSettings.nUseStyle = 1
			FireEvent("RAID_SHOW_OPTION_UPDATED")
			GetPopupMenu():Hide()
		end,
	}
	table.insert(tMenu, tSubMenu)
	
	tSubMenu = {
		szOption = g_tStrings.STR_RAID_MENU_USE_KUNGFU,
		bMCheck = true,
		bChecked = RaidPanel.tGroupSettings.nUseStyle == 2,
		fnAction = function(tUserData, bCheck)
			RaidPanel.tGroupSettings.nUseStyle = 2
			FireEvent("RAID_SHOW_OPTION_UPDATED")
			GetPopupMenu():Hide()
		end,
	}
	table.insert(tMenu, tSubMenu)
	
	table.insert(tMenu, {bDevide = true})
	tSubMenu = { 
		szOption = g_tStrings.STR_TEAM_PARTY_SYNC_CLOSE,
		bCheck = true,
		bChecked = (not IsSyncTeamFightData()),
		UserData = "",
		fnAction = function(UserData, bCheck) 
			SetTeamSkillEffectSyncOption(not bCheck) 
			SetSyncTeamFightDataState(not bCheck) 
		end,
		
		fnMouseEnter = function(hItem)
			local x, y = hItem:GetAbsPos()
			local w, h = hItem:GetSize()
			local szTip = g_tStrings.STR_TEAM_PARTY_SYNC
			OutputTip(szTip, 335, {x, y, w, h})
		end
	}
	table.insert(tMenu, tSubMenu)
	
--	tSubMenu = {
--		szOption = g_tStrings.STR_RAID_MENU_CLASSIC,
--		bCheck = true,
--		bChecked = RaidPanel.tGroupSettings.bClassic,
--		fnAction = function(tUserData, bCheck)
--			RaidPanel.tGroupSettings.bClassic = bCheck
--			FireEvent("RAID_SHOW_OPTION_UPDATED")
--			GetPopupMenu():Hide()
--		end,
--	}
--	table.insert(tMenu, tSubMenu)
	
	table.insert(tMenu, {bDevide = true})
	RaidPanel.InsertForceCountMenu(tMenu)	
end

function RaidPanel.InsertChangeGroupMenu(tMenu, dwMemberID)
	local hTeam = GetClientTeam()
	local tSubMenu = { szOption = g_tStrings.STR_RAID_MENU_CHANG_GROUP }
	
	local nCurGroupID = hTeam.GetMemberGroupIndex(dwMemberID)
	for i = 0, hTeam.nGroupNum - 1 do
		if i ~= nCurGroupID then
			local tGroupInfo = hTeam.GetGroupInfo(i)
			if tGroupInfo and tGroupInfo.MemberList then
				local tSubSubMenu = 
				{
					szOption = g_tStrings.STR_NUMBER[i + 1],
					bDisable = (#tGroupInfo.MemberList >= MAX_RAID_GROUP_MEMBER_COUNT),
					fnAction = function() GetClientTeam().ChangeMemberGroup(dwMemberID, i, 0) end,
					fnAutoClose = function() return true end,
				}
				table.insert(tSubMenu, tSubSubMenu)
			end
		end
	end

	local tSubSubMenu = 
	{
		szOption = g_tStrings.STR_CUSTOM_TEAM,
		bDisable = (#RaidPanel.tCustomGroup.MemberList >= MAX_RAID_CUSTOM_GROUP_MEMBER_COUNT),
		fnAction = function() RaidPanel.CustomGroupAddMember(nil, dwMemberID) end,
	}
	table.insert(tSubMenu, tSubSubMenu)
	
	table.insert(tMenu, tSubMenu)
end

function RaidPanel.InsertForceCountMenu(tMenu)
	local tForceList = {}
	local hTeam = GetClientTeam()
	for nGroupID = 0, hTeam.nGroupNum - 1 do
		local tGroupInfo = hTeam.GetGroupInfo(nGroupID)
		for _, dwMemberID in ipairs(tGroupInfo.MemberList) do
			local tMemberInfo = hTeam.GetMemberInfo(dwMemberID)
			if not tForceList[tMemberInfo.dwForceID] then
				tForceList[tMemberInfo.dwForceID] = 0
			end
			tForceList[tMemberInfo.dwForceID] = tForceList[tMemberInfo.dwForceID] + 1
		end
	end
	local tSubMenu = { szOption = g_tStrings.STR_RAID_MENU_FORCE_COUNT }
	for dwForceID, nCount in pairs(tForceList) do
		table.insert(tSubMenu, { szOption = g_tStrings.tForceTitle[dwForceID] .. "   " .. nCount })
	end
	table.insert(tMenu, tSubMenu)
end

function RaidPanel.InsertGroupTitleMenu(tMenu, nGroupID)
	local hTeam = GetClientTeam()
	local tGroupInfo = RaidPanel.GetGroupInfo(nGroupID)
	local tSubMenu = { szOption = g_tStrings.STR_RAID_MENU_SHOW_MEMBER }
	for _, dwMemberID in ipairs(tGroupInfo.MemberList) do
		local tMemberInfo = hTeam.GetMemberInfo(dwMemberID)
		local tSubSubMenu = 
		{ 
			szOption = tMemberInfo.szName,
			bCheck = true, 
			bChecked = not RaidPanel.tMemberState[dwMemberID].bHide,
			fnAction = function(tUserData, bCheck) 
				RaidPanel.tMemberState[dwMemberID].bHide = not bCheck
				local hRaidFrame = Station.Lookup("Normal/RaidPanel_" .. nGroupID)
				RaidPanel.UpdateRaidFrame(hRaidFrame)
				GetPopupMenu():Hide()
			end,
		}
		table.insert(tSubMenu, tSubSubMenu)
	end
	table.insert(tMenu, tSubMenu)
end

function RaidPanel.GetGroupInfo(nGroupID)
	local tGroupInfo = nil
	if nGroupID ~= CUSTOM_RAID_GROUP_ID then
		local hTeam = GetClientTeam()
		tGroupInfo = hTeam.GetGroupInfo(nGroupID)
	else
		tGroupInfo = RaidPanel.tCustomGroup
	end
	return tGroupInfo
end

function RaidPanel.TestReadyConfirm(nGroupID)
	local tGroupInfo = RaidPanel.GetGroupInfo(nGroupID)
	for _, dwMemberID in ipairs(tGroupInfo.MemberList) do
		if RaidPanel.tMemberState[dwMemberID] and RaidPanel.tMemberState[dwMemberID].nReadyConfirm ~= READY_CONFIRM_OK then
			return true
		end
	end
	return false
end

function RaidPanel.UpdateGroupTabs(hFrame)
	if not hFrame.bMainFrame then
		return
	end

	local hTeam = GetClientTeam()
	local nTabIndex = 1
	local hTabsPage = hFrame:Lookup("Wnd_Tabs")
	for nGroupID = 0, hTeam.nGroupNum - 1 do
		local hGroupTab = hTabsPage:Lookup("Btn_Team" .. nTabIndex)
		
		local hRaidFrame = Station.Lookup("Normal/RaidPanel_" .. nGroupID)
		if not hRaidFrame then
			hGroupTab:Lookup("", "Text_Team" .. nTabIndex):SetText(g_tStrings.STR_NUMBER[nGroupID + 1])
			local hReadyConfirm = hGroupTab:Lookup("", "Image_TeamCover" .. nTabIndex)
			if not bHideReadyConfirm and RaidPanel.TestReadyConfirm(nGroupID) then
				hReadyConfirm:Show()
			else
				hReadyConfirm:Hide()
			end
			
			local tGroupInfo = hTeam.GetGroupInfo(nGroupID)
			local hImgHaveMember = hGroupTab:Lookup("", "Image_Member" .. nTabIndex)
			if tGroupInfo and tGroupInfo.MemberList and #tGroupInfo.MemberList > 0 then
				hImgHaveMember:Show()
			else
				hImgHaveMember:Hide()
			end
			
			hGroupTab.nGroupID = nGroupID
			hGroupTab:Show()
			
			nTabIndex = nTabIndex + 1
		end
	end
	
	for nIndex = nTabIndex, MAX_RAID_GROUP_COUNT - 1 do
		local hGroupTab = hFrame:Lookup("Wnd_Tabs/Btn_Team" .. nIndex)
		if hGroupTab then
			hGroupTab:Hide()
		end
	end
	
	local hCustomGroup = Station.Lookup("Normal/RaidPanel_" .. CUSTOM_RAID_GROUP_ID)
	local hCustomGroupTab = hFrame:Lookup("Wnd_Tabs/Btn_CustomWindow")
	if hCustomGroup then
		hCustomGroupTab:Hide()
	else
		local hImgHaveMember = hCustomGroupTab:Lookup("", "Image_MemberC")
		if #RaidPanel.tCustomGroup.MemberList > 0 then
			hImgHaveMember:Show()
		else
			hImgHaveMember:Hide()
		end
		hCustomGroupTab:Show()
	end
	
	local _, hFrameHeight = hFrame:GetSize()
	local _, nTabHeight = hCustomGroupTab:GetSize()
	local nPosX, _ = hCustomGroupTab:GetRelPos()
	hCustomGroupTab:SetRelPos(nPosX, hFrameHeight - nTabHeight - 10)
	hCustomGroupTab.nGroupID = CUSTOM_RAID_GROUP_ID
end

function RaidPanel.HideLeftItem(handle, nNeed, bFormat)
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
	if bFormat then
		handle:FormatAllItemPos()
	end
end

function RaidPanel.GetBuffHandle(hMember, szName)
	if not hMember[szName] then
		hMember[szName] = hMember:Lookup(szName)
	end
	return hMember[szName]
end

function RaidPanel.RefreshMemberBuff(hMember, bUpdateBuff, bUpdateDebuff)
	local hBuff = RaidPanel.GetBuffHandle(hMember, "Handle_Buff")
	local hDebuff = RaidPanel.GetBuffHandle(hMember, "Handle_Debuff")
	
	local nBuffIndex = 0;
	local nDebuffIndex = 0;
	local nBuffCount = hBuff:GetItemCount()
	local nDebuffCount = hDebuff:GetItemCount()
	local hPlayer = GetPlayer(hMember.dwID)
	local box
	if hPlayer then
		local tBuffList = hPlayer.GetBuffList() or {}
		for _, tBuff in pairs(tBuffList) do
			if Table_BuffIsVisible(tBuff.dwID, tBuff.nLevel) then
				if bUpdateBuff and tBuff.bCanCancel then
					if RaidPanel.tGroupSettings.nBuffShowState == RAID_PANEL_STATE_SHOW_BUFF then
						box = nil
						if nBuffIndex < nBuffCount then
							box = hBuff:Lookup(nBuffIndex)
						end
						nBuffIndex = nBuffIndex + 1
						RaidPanel.CreateMemberBuff(hBuff, box, tBuff.nIndex, true, tBuff.dwID, tBuff.nStackNum, tBuff.nEndFrame, tBuff.nLevel)
					end
				elseif bUpdateDebuff and not tBuff.bCanCancel then
					if RaidPanel.tGroupSettings.nBuffShowState == RAID_PANEL_STATE_SHOW_DEBUFF then
						box = nil
						if nDebuffIndex < nDebuffCount then
							box = hDebuff:Lookup(nDebuffIndex)
						end
						nDebuffIndex = nDebuffIndex + 1
						RaidPanel.CreateMemberBuff(hDebuff, box, tBuff.nIndex, true, tBuff.dwID, tBuff.nStackNum, tBuff.nEndFrame, tBuff.nLevel)
					end
				end		
			end
		end
	end
	
	if bUpdateBuff then
		RaidPanel.HideLeftItem(hBuff, nBuffIndex, nBuffIndex > nBuffCount)
	end
	
	if bUpdateDebuff then
		RaidPanel.HideLeftItem(hDebuff, nDebuffIndex, nDebuffIndex > nDebuffCount)
	end
end

function RaidPanel.CreateMemberBuff(hBuffList, hBuff, nIndex, bCanCancel, dwBuffID, nCount, nEndFrame, nLevel)
	if not hBuff then
		hBuffList:AppendItemFromString("<box> w=15 h=15 eventid=256 postype=7 </box>")
		local nItemCount = hBuffList:GetItemCount() 
		hBuff = hBuffList:Lookup(nItemCount - 1)
		
		hBuff.OnItemMouseEnter = function()
			this:SetObjectMouseOver(1)
			local nTime = math.floor(this.nEndFrame - GetLogicFrameCount()) / 16 + 1
			local x, y = this:GetAbsPos()
			local w, h = this:GetSize()
			local dwCaracter = this:GetParent():GetParent().dwID
			OutputBuffTip(dwCaracter, this.dwBuffID, this.nLevel, this.nCount, this.bShowTime and not this.bCanCancel, nTime, {x, y, w, h})					
		end
		hBuff.OnItemMouseHover = hBuff.OnItemMouseEnter
		hBuff.OnItemMouseLeave = function()
			HideTip()
			this:SetObjectMouseOver(0)
		end
		
	end
	hBuff:SetName("b_"..nIndex)
	hBuff:Show()
	hBuff.nCount = nCount
	hBuff.nEndFrame = nEndFrame
	hBuff.bCanCancel = bCanCancel
	hBuff.dwBuffID = dwBuffID
	hBuff.nLevel = nLevel
	hBuff.nIndex = nIndex
	hBuff.bSparking = Table_BuffNeedSparking(dwBuffID, nLevel)
	hBuff.bShowTime = Table_BuffNeedShowTime(dwBuffID, nLevel)
	hBuff:SetObject(UI_OBJECT_NOT_NEED_KNOWN, dwBuffID)
	hBuff:SetObjectIcon(Table_GetBuffIconID(dwBuffID, nLevel))
	hBuff:SetOverTextFontScheme(0, 15)
	if nCount > 1 then
		hBuff:SetOverText(0, nCount)
	else
		hBuff:SetOverText(0, "")
	end
end

function RaidPanel.UpdateMemberBuff(hBuffList, bDelete, nIndex, bCanCancel, dwBuffID, nCount, nEndFrame, nLevel)
	if not Table_BuffIsVisible(dwBuffID, nLevel) then
		return
	end
	
	local hBuff = hBuffList:Lookup("b_"..nIndex)
	if not hBuff then
		local nItemCount = hBuffList:GetItemCount()
		if hBuffList.nNeedBox < nItemCount then
			hBuff = hBuffList:Lookup(hBuffList.nNeedBox)
			hBuffList.nNeedBox = hBuffList.nNeedBox + 1
		end
	end
	
	local bCreate = false
	if not hBuff then
		bCreate = true
	end
	
	RaidPanel.CreateMemberBuff(hBuffList, hBuff, nIndex, bCanCancel, dwBuffID, nCount, nEndFrame, nLevel)
	if bCreate then
		hBuffList.nNeedBox = hBuffList.nNeedBox + 1
		hBuffList:FormatAllItemPos()
	end
end

function RaidPanel.GetGroupTitle(nGroupID)
	if nGroupID ~= CUSTOM_RAID_GROUP_ID then
		return g_tStrings.STR_TEAM .. g_tStrings.STR_NUMBER[nGroupID + 1]
	else
		return g_tStrings.STR_CUSTOM_TEAM
	end	
end

function RaidPanel.StartReadyConfirm()
	bHideReadyConfirm = false
	
	local hPlayer = GetClientPlayer()
	local hTeam = GetClientTeam()
	
	for nGroupID = 0, hTeam.nGroupNum - 1 do
		local tGroupInfo = hTeam.GetGroupInfo(nGroupID)
		for _, dwMemberID in ipairs(tGroupInfo.MemberList) do
			if not RaidPanel.tMemberState[dwMemberID] then
				RaidPanel.tMemberState[dwMemberID] = { bHide = false, nReadyConfirm = READY_CONFIRM_OK }
			end
			RaidPanel.tMemberState[dwMemberID].nReadyConfirm = READY_CONFIRM_INIT
		end
	end
	
	RaidPanel.tMemberState[hPlayer.dwID].nReadyConfirm = READY_CONFIRM_OK
	
	RaidPanel.UpdateReadyConfirm()
	
	RemoteCallToServer("OnStartRollCall")
end

function RaidPanel.ConfirmReady(dwLeaderID)
	local hTeam = GetClientTeam()
	local tMemberInfo = hTeam.GetMemberInfo(dwLeaderID)
	
	local tMsg = 
	{
		bRichText = true,
		szMessage = FormatString(g_tStrings.STR_RAID_MSG_READY_CONFIRM, tMemberInfo.szName),
		szName = "ReadyConfirm"..dwLeaderID,
		{szOption = g_tStrings.STR_HOTKEY_READY_OK, fnAction = function() RemoteCallToServer("OnVerifyReady", dwLeaderID, READY_CONFIRM_OK) end, },
		{szOption = g_tStrings.STR_HOTKEY_READY_NOT_YET, fnAction = function() RemoteCallToServer("OnVerifyReady", dwLeaderID, READY_CONFIRM_NOT_YET) end, },
	}
	MessageBox(tMsg)
end

function RaidPanel.UpdateReadyConfirm()
	local hPlayer = GetClientPlayer()
	local hTeam = GetClientTeam()
	local nMyGroup = hTeam.GetMemberGroupIndex(hPlayer.dwID)
	local hMainFrame = Station.Lookup("Normal/RaidPanel_" .. nMyGroup)
	local hTabsPage = hMainFrame:Lookup("Wnd_Tabs")
	
	local nTabIndex = 1
	for nGroupID = 0, hTeam.nGroupNum - 1 do
		local hFrame = Station.Lookup("Normal/RaidPanel_" .. nGroupID)
		if hFrame then
			local hMemberList = hFrame:Lookup("Wnd_Team", "Handle_PlayerList")
			local nCount = hMemberList:GetItemCount()
			for nIndex = 0, nCount - 1 do
				local hMember = hMemberList:Lookup(nIndex)
				local hImageCover = hMember:Lookup("Image_Cover")
				local hImageReady = hMember:Lookup("Image_Ready")
				local nReadyState = RaidPanel.tMemberState[hMember.dwID].nReadyConfirm
				
				if bHideReadyConfirm then
					hImageCover:Hide()
					hImageReady:Hide()
				elseif nReadyState == READY_CONFIRM_OK then
					hImageCover:Hide()
					hImageReady:Hide()
				elseif nReadyState == READY_CONFIRM_NOT_YET then
					hImageCover:Show()
					hImageReady:Show()
				elseif nReadyState == READY_CONFIRM_INIT then
					hImageCover:Show()
					hImageReady:Hide()
				end
			end
		else
			local hGroupTab = hTabsPage:Lookup("Btn_Team"..nTabIndex)
			local hReadyConfirm = hGroupTab:Lookup("", "Image_TeamCover"..nTabIndex)
			
			if bHideReadyConfirm then
				hReadyConfirm:Hide()
			elseif RaidPanel.TestReadyConfirm(nGroupID) then
				hReadyConfirm:Show()
			else
				hReadyConfirm:Hide()
			end
			
			nTabIndex = nTabIndex + 1
		end
	end
end

function RaidPanel.ChangeReadyConfirm(dwMemberID, nReadyState)
	if bHideReadyConfirm then
		return
	end
	
	local hTeam = GetClientTeam()
	local nGroupID = hTeam.GetMemberGroupIndex(dwMemberID)
	local hFrame = Station.Lookup("Normal/RaidPanel_" .. nGroupID)
	
	if hFrame then
		local hMemberList = hFrame:Lookup("Wnd_Team", "Handle_PlayerList")
		local nCount = hMemberList:GetItemCount()
		for nIndex = 0, nCount - 1 do
			local hMember = hMemberList:Lookup(nIndex)	
			if hMember.dwID == dwMemberID then
				local hImageCover = hMember:Lookup("Image_Cover")
				local hImageReady = hMember:Lookup("Image_Ready")
				
				if bHideReadyConfirm then
					hImageCover:Hide()
					hImageReady:Hide()
				elseif nReadyState == READY_CONFIRM_OK then
					hImageCover:Hide()
					hImageReady:Hide()
				elseif nReadyState == READY_CONFIRM_NOT_YET then
					hImageCover:Show()
					hImageReady:Show()
				elseif nReadyState == READY_CONFIRM_INIT then
					hImageCover:Show()
					hImageReady:Hide()
				end
				
				break
			end
		end
	else
		local hPlayer = GetClientPlayer()
		local nMyGroup = hTeam.GetMemberGroupIndex(hPlayer.dwID)
		local hMainFrame = Station.Lookup("Normal/RaidPanel_" .. nMyGroup)
		local hTabsPage = hMainFrame:Lookup("Wnd_Tabs")
		local hReadyConfirm = nil
		
		for nTabIndex = 1, hTeam.nGroupNum do
			local hGroupTab = hTabsPage:Lookup("Btn_Team" .. nTabIndex)
			if hGroupTab:Lookup("", "Text_Team" .. nTabIndex):GetText() == g_tStrings.STR_NUMBER[nGroupID + 1] then
				hReadyConfirm = hGroupTab:Lookup("", "Image_TeamCover" .. nTabIndex)
				break
			end
		end
		
		if not hReadyConfirm then
			return
		end
		
		if bHideReadyConfirm then
			hReadyConfirm:Hide()
		elseif nReadyState ~= READY_CONFIRM_OK then
			hReadyConfirm:Show()
		else
			hReadyConfirm:Hide()
		end
	end
end

function ConvertToRaid()
	local tMsg = 
	{
		szMessage = g_tStrings.STR_MSG_RAID_CONFIRM,
		szName = "ConvertToRaidConfirm",
		{szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = function() GetClientTeam().LevelUpRaid() end, },
		{szOption = g_tStrings.STR_HOTKEY_CANCEL, },
	}
	MessageBox(tMsg)	
end

function OpenRaidPanel()
	local hPlayer = GetClientPlayer()
	if not hPlayer or not hPlayer.IsInParty() then
		return
	end
	
	local hTeam = GetClientTeam()
	if hTeam.nGroupNum <= 1 then
		return
	end
		
	local nGroupID = hTeam.GetMemberGroupIndex(hPlayer.dwID)
	RaidPanel.OpenRaidFrame(nGroupID)
	CloseTeammate()
	
	local hRaidFrame = Station.Lookup("Normal/RaidPanel_" .. nGroupID)
	if hRaidFrame then
		local hBtnOption = hRaidFrame:Lookup("Wnd_MainTitle/Btn_Option")
		if hBtnOption and hBtnOption:IsVisible() then
			FireHelpEvent("OnOpenpanel", "RaidPanel", hBtnOption)
		end
	end
end

function CloseRaidPanel()
	for nGroupID = CUSTOM_RAID_GROUP_ID, MAX_RAID_GROUP_COUNT do
		Wnd.CloseWindow("RaidPanel_" .. nGroupID)
	end
	
	RaidPanel.tMemberState = {}
	RaidPanel.tCustomGroup = { MemberList = {} }
	OpenTeammate()
	bRaidEditMode = false
end

function IsRaidOpened()
	for nGroupID = CUSTOM_RAID_GROUP_ID, MAX_RAID_GROUP_COUNT do
		local hFrame = Station.Lookup("Normal/RaidPanel_" .. nGroupID)
		if hFrame then
			return true
		end
	end	
end

local function OnReset()
    if IsRaidOpened() then
		CloseRaidPanel()
	end
end

local function OnUpdateBaseInfo()
	if IsRaidOpened() then
		CloseRaidPanel()
	end
	OpenRaidPanel()
end

local function OnLevelUpRaid()
	OpenRaidPanel()
    OutputMessage("MSG_SYS", g_tStrings.STR_MSG_RAID_CONVERTED)
    local hPlayer = GetClientPlayer()
    if not hPlayer then
        return
    end
    local hClientTeam = GetClientTeam()
    if not hClientTeam then
        return
    end
    local dwDistribute = hClientTeam.GetAuthorityInfo(TEAM_AUTHORITY_TYPE.DISTRIBUTE)
    if IsLeader() and dwDistribute == hPlayer.dwID then
        local tMsg = 
        {
            szMessage = g_tStrings.STR_RAID_MSG_LOOTMODE_DISTRIBUTE,
            szName = "lootmodedistribute",
            {szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = function() GetClientTeam().SetTeamLootMode(PARTY_LOOT_MODE.DISTRIBUTE) end},
            {szOption = g_tStrings.STR_HOTKEY_CANCEL, },
        }
        MessageBox(tMsg)
    end
end

function IsLeader()
	local hTeam = GetClientTeam()
	local hPlayer = GetClientPlayer()
	if hTeam.GetAuthorityInfo(TEAM_AUTHORITY_TYPE.LEADER) == hPlayer.dwID then
		return true
	end
	return false
end

RegisterEvent("PARTY_LEVEL_UP_RAID", OnLevelUpRaid)
RegisterEvent("SYNC_ROLE_DATA_END", OpenRaidPanel)
RegisterEvent("PARTY_RESET", OnReset)
RegisterEvent("PARTY_UPDATE_BASE_INFO", OnUpdateBaseInfo)
RegisterEvent("TEAM_CHANGE_MEMBER_GROUP", function() RaidPanel.OnMemberChangeGroup(arg0, arg1, arg3, arg2) end)

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------