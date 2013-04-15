local function GetFormatTime(nTime, bFrame)
	if bFrame then
		nTime = math.floor(nTime / GLOBAL.GAME_FPS)
	end
	
	local nH = math.floor(nTime / 3600 % 24)
	local nM = math.floor((nTime % 3600) / 60)
	local nS = math.floor((nTime % 3600) % 60)
	local szTimeText = ""
	
	if nH < 10 then
		szTimeText = szTimeText.."0"
	end
	szTimeText= szTimeText..nH..":"

	if nM < 10 then
		szTimeText = szTimeText.."0"
	end
	szTimeText= szTimeText..nM..":"
	
	if nS < 10 then
		szTimeText = szTimeText.."0"
	end
	szTimeText= szTimeText..nS
	
	return szTimeText
end

local function GetBuffLeftTime(dwBuffID)
	local tBuffList = GetClientPlayer().GetBuffList()
	if tBuffList and dwBuffID then
		for _, tBuff in pairs(tBuffList) do
			if tBuff.dwID == dwBuffID then
				return tBuff.nEndFrame
			end
		end
	end
	return
end

PartyRecruitPanel =
{
	nSelGroup = 1002,
	tEnterState= {},
	tAttendQueue = {},
}

RegisterCustomData("PartyRecruitPanel.tEnterState")

local INI_FILE_PATH = "UI/Config/Default/PartyRecruitPanel.ini"
local INI_FILE_PATH1 = "UI/Config/Default/TwoDungeonReward.ini"

local ESCAPE_BUFFER_ID = 1852
local SCORE_LEVEL_IMAGE_FRAME = 
{
	[1] = 59,
	[2] = 60,
	[3] = 61,
	[4] = 62,
	[5] = 63,
	[6] = 64,
}
 
local l_GroupInfo = 
{
	[1002] = {szName = g_tStrings.STR_FT_TWO_MAN_DUNGEON, bTwoMan = true, nCheckCount = 0},
}

function PartyRecruitPanel.OnFrameCreate()
	local l_tThis = PartyRecruitPanel
	
	this:RegisterEvent("PARTY_ADD_MEMBER")
	this:RegisterEvent("PARTY_DELETE_MEMBER")
	this:RegisterEvent("TEAM_AUTHORITY_CHANGED")
	this:RegisterEvent("PARTY_DISBAND")
	this:RegisterEvent("ON_BATTLEFIELD_REWARD_DATA")
	this:RegisterEvent("BATTLE_FIELD_STATE_UPDATE")
	this:RegisterEvent("BATTLE_FIELD_UPDATE_TIME")
    this:RegisterEvent("GET_TODAY_ZHANCHANG_RESPOND")
    
	this.nLoopCount = 0
	l_tThis.InitDungeonGroup(this)
	--l_tThis.InitDungeon(this)
	BattleFieldQueue.OnFrameCreate(this)
    
	local szState = GetPartyRecruitState()
	InitFrameAutoPosInfo(this, 1, nil, nil, function() ClosePartyRecruitPanel(true) end)
end

function PartyRecruitPanel.OnFrameBreathe()
	this.nLoopCount = (this.nLoopCount or 0) + 1
	if this.nLoopCount == 4 then
		this.nLoopCount = 0
		
		if this.nEscapeEndTime then
			local dwFrame = GetLogicFrameCount()
			if this.nEscapeEndTime > dwFrame then
				local text = this:Lookup("PageSet_Total/Page_DungeonGroup", "Text_etime")
				local szText = GetFormatTime(this.nEscapeEndTime - dwFrame, true)
				szText = g_tStrings.STR_FT_ESCAPE_TIME..szText
				text:SetText(szText)
			else
				local text = this:Lookup("PageSet_Total/Page_DungeonGroup", "Text_etime")
				text:SetText("")
				this.nEscapeEndTime = nil
			end
		end
	end
end

function PartyRecruitPanel.OnEvent(szEvent)
	BattleFieldQueue.OnEvent(szEvent)
	if szEvent == "PARTY_ADD_MEMBER" or szEvent == "PARTY_DELETE_MEMBER" or 
	   szEvent == "TEAM_AUTHORITY_CHANGED" or  szEvent == "PARTY_DISBAND" then
		local frame = this:GetRoot()
		PartyRecruitPanel.UpdateButtonState(frame)
	end
end

function PartyRecruitPanel.UpdateButtonState(frame, bUpdateTime)
	local hPage = frame:Lookup("PageSet_Total/Page_DungeonGroup")
	hPage:Lookup("Btn_DGPartyQueue"):Enable(false)
		
	local player = GetClientPlayer()
	if player.IsInParty() then
		if player.IsPartyLeader() then
			hPage:Lookup("Btn_DGPartyQueue"):Enable(true)
		end
	end
	
	if bUpdateTime then
		local textTime = hPage:Lookup("", "Text_etime")
		textTime:SetText("")
		
		local nEndTime = GetBuffLeftTime(ESCAPE_BUFFER_ID)
		frame.nEscapeEndTime = tonumber(nEndTime)
		if nEndTime then
			hPage:Lookup("Btn_DGQueue"):Enable(false)
			hPage:Lookup("Btn_DGPartyQueue"):Enable(false)
			textTime:SetFontScheme(27)
		end
	end
end

function PartyRecruitPanel.InitDungeonGroup(frame)
	local l_tThis = PartyRecruitPanel
	
	local hPage = frame:Lookup("PageSet_Total/Page_DungeonGroup")
	local hWnd = hPage:Lookup("Wnd_DungeonGroup")
	
	hWnd:Lookup("Btn_GroupUp"):Hide()
	hWnd:Lookup("Btn_GroupDown"):Hide()
	
	PartyRecruitPanel.UpdateButtonState(frame, true)
	
	l_tThis.UpdateGroupList(frame)
end

function PartyRecruitPanel.InitDungeon(frame)
	local l_tThis = PartyRecruitPanel
	
	l_tThis.UpdateGDungeonList(frame)
end

function PartyRecruitPanel.UpdateGroupList(frame)
	local l_tThis = PartyRecruitPanel
	
	local hPage = frame:Lookup("PageSet_Total/Page_DungeonGroup")
	local hList = hPage:Lookup("", "Handle_DungeonGroup")
	hList:Clear()
	
	for k, v in pairs(l_GroupInfo) do
		local hItem = hList:AppendItemFromIni(INI_FILE_PATH, "HI_Group01")
		local hLevel = hItem:Lookup("Text_Group01Lv")
		
		hItem.bGroup = true
		hItem.nGroupID = k
		hItem:Lookup("Text_Group01Name"):SetText(v.szName)
		
		if v.nLevel then
			hLevel:Show()
			hLevel:SetText(FormatString(g_tStrings.TIP_LEVEL_WHAT,  v.nLevel))
		end
		
		if l_tThis.nSelGroup == k then
			l_tThis.Selected(hItem)
			if v.bTwoMan then
				l_tThis.UpdateTwoManContent(frame, hItem.nGroupID)
			else
				l_tThis.UpdateGroupContent(frame, nGroupID)
			end
		end
	end
	
	local hScroll  = hPage:Lookup("Scroll_DGroup")
	local hBtnUp   = hPage:Lookup("Btn_DGroupUp")
	local hBtnDown = hPage:Lookup("Btn_DGroupDown")
	l_tThis.OnUpdateScorllList(hList, hScroll, hBtnUp, hBtnDown)
end

function PartyRecruitPanel.UpdateGroupContent(frame, nGroupID)
	local hWnd = frame:Lookup("PageSet_Total/Page_DungeonGroup/Wnd_DungeonGroup")
	local hGroup = hWnd:Lookup("", "")
	hGroup:Lookup("Text_Group01Title"):SetText(l_GroupInfo[nGroupID].szName)
	
	--=================
	hWnd:Lookup("Btn_GroupUp"):Hide()
	hWnd:Lookup("Btn_GroupDown"):Hide()
end

function PartyRecruitPanel.UpdateTwoManContent(frame, nGroupID)
	local hWnd = frame:Lookup("PageSet_Total/Page_DungeonGroup/Wnd_TwoPlayerDungeon")
	local hGroup = hWnd:Lookup("", "")
	hGroup:Lookup("Text_TPDTitle"):SetText(l_GroupInfo[nGroupID].szName)
end

function PartyRecruitPanel.OnUpdateScorllList(hList, hScroll, hBtnUp, hBtnDown)
	hList:FormatAllItemPos()
	local w, h = hList:GetSize()
	local wAll, hAll = hList:GetAllItemSize()
	local nStepCount = math.ceil((hAll - h) / 10)
	
	hScroll:SetStepCount(nStepCount)
	if nStepCount > 0 then
		hScroll:Show()
		hBtnUp:Show()
		hBtnDown:Show()
	else
		hScroll:Hide()
		hBtnUp:Hide()
		hBtnDown:Hide()
	end
end

function PartyRecruitPanel.OnScrollBarPosChanged()
	local nCurrentValue = this:GetScrollPos()
	local szName = this:GetName()
	if szName == "Scroll_DGroup" then
		
	elseif szName == "Scroll_HelpText" then
		local Page = this:GetParent()
		if nCurrentValue == 0 then
			Page:Lookup("Btn_Up"):Enable(false)
		else
			Page:Lookup("Btn_Up"):Enable(true)
		end
		
		if nCurrentValue == this:GetStepCount() then
			Page:Lookup("Btn_Down"):Enable(false)
		else
			Page:Lookup("Btn_Down"):Enable(true)
		end
	    Page:Lookup("", "Handle_HelpText"):SetItemStartRelPos(0, - nCurrentValue * 10)	
	end
end

function OnPartyRecruitMapDataNotify(nDungeonType, dwMapID, tData)
	local l_tThis = PartyRecruitPanel
	local player = GetClientPlayer()
	local scene = player.GetScene()
	
	
	if nDungeonType == 0 then
		tData.nDungeonType = nDungeonType
		tData.dwMapID =  dwMapID
		l_tThis.tTeamResult = tData

        if IsTwoDungeonRewardOpened() then
            UpdateTwoDungeonReward();
        end
	else
		l_tThis.bDungeonEnd = nil
		
        if IsTwoDungeonRewardOpened() then
            CloseTwoDungeonReward()
        end
	end
	
	local szState = GetPartyRecruitState()
	if szState == "InFTDungeon" and scene.dwMapID == dwMapID and not l_tThis.tEnterState[dwMapID] then
		if not IsTwoDungeonRewardOpened() then
            OpenTwoDungeonReward();
        end
        local frame = Station.Lookup("Normal/TwoDungeonReward")
		TwoDungeonReward.UpdateHelp(frame)
        frame:Lookup("PageSet_Integration"):ActivePage("Page_Help")
		l_tThis.tEnterState[dwMapID] = true
	end
	
	if l_tThis.tRewards and szState == "DungeonEnd" and IsTwoDungeonRewardOpened() then
		UpdateTwoDungeonReward(l_tThis.tRewards)
	end
    
    if IsTwoDungeonRewardOpened() then
        local frame = Station.Lookup("Normal/TwoDungeonReward")
        TwoDungeonReward.UpdateBtnState(frame)
    end
	
	FireEvent("PARTY_RECRUITY_DATA_UPDATE")
	FireEvent("PARTY_RECRUITY_STATE_UPDATE")
end

local function UpdateBgStatus(hItem)
	local img = nil
	local szName = hItem:GetName()
	if szName == "HI_Group01" then
		img = hItem:Lookup("Image_GroupCover01")
	elseif szName == "HI_Dungeon01" then
		img = hItem:Lookup("Image_DungeonCover01")
	else
		return
	end
	
	if hItem.bSel then
		img:Show()
		img:SetAlpha(255)
	elseif hItem.bOver then
		img:Show()
		img:SetAlpha(128)
	else
		img:Hide()
	end
end

function PartyRecruitPanel.Selected(hItem)
	if not hItem then
		return
	end
	
	local hList = hItem:GetParent()
	local nCount = hList:GetItemCount()
	for i = 0, nCount - 1, 1 do
		local hItem = hList:Lookup(i)
		if hItem.bSel then
			hItem.bSel = false
			UpdateBgStatus(hItem)
		end
	end
	
	PartyRecruitPanel.nSelGroup = hItem.nGroupID
	
	hItem.bSel = true
	UpdateBgStatus(hItem)
	PartyRecruitPanel.UpdateLeaveQueueButton()
end

local function JoinDungeonQueue(bParty)
	local scene = GetClientPlayer().GetScene()
	if scene.nType ~= MAP_TYPE.NORMAL_MAP then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_FT_CAN_NOT_ATTEND)
		return
	end
	
	assert(PartyRecruitPanel.nSelGroup ~= nil)
	assert(bParty ~= nil)
	RemoteCallToServer("OnRequestJoinDungeonQueue", PartyRecruitPanel.nSelGroup, bParty)
end

local function LeaveDungeonQueue(dwQueueID)
	assert(dwQueueID ~= nil)
	RemoteCallToServer("OnRequestLeaveDungeonQueue", dwQueueID)
end

function ConfirmEnterDungeon(dwMapID, nCopyID)
	assert(dwMapID ~= nil)
	assert(nCopyID ~= nil)
	RemoteCallToServer("OnConfirmEnterDungeon", dwMapID, nCopyID)	
end

function CancelEnterDungeon(dwMapID, nCopyID)
	local l_tThis = PartyRecruitPanel
	
	l_tThis.tCanEnterMap = nil
	l_tThis.nEnterEndTime = nil
	FireEvent("PARTY_RECRUITY_STATE_UPDATE")
	
	assert(dwMapID ~= nil)
	assert(nCopyID ~= nil)
	RemoteCallToServer("OnCancelEnterDungeon", dwMapID, nCopyID)	
end

function PartyRecruitPanel.OnMouseWheel()
	
	local nDistance = Station.GetMessageWheelDelta()
	
	local szName = this:GetName()
	if szName == "Page_Help" then
		this:Lookup("Scroll_HelpText"):ScrollNext(nDistance)
		return 1
	end
end

function PartyRecruitPanel.OnLButtonHold()
	local szName = this:GetName()
    if szName == "Btn_Up" then
		this:GetParent():Lookup("Scroll_HelpText"):ScrollPrev()
	elseif szName == "Btn_Down" then
		this:GetParent():Lookup("Scroll_HelpText"):ScrollNext()
	end
end

function PartyRecruitPanel.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_DGQueue" then
		JoinDungeonQueue(false)
		
	elseif szName == "Btn_DGPartyQueue" then
		JoinDungeonQueue(true)
		
	elseif szName == "Btn_DQueue" then
		
	elseif szName == "Btn_DPartyQueue" then
	elseif szName == "Btn_DLeaveQueue" then
		if PartyRecruitPanel.nSelGroup then
			LeaveDungeonQueue(PartyRecruitPanel.nSelGroup)
		end
	elseif szName == "Btn_Leave" then
		PartyRecruitPanel.MessageWarning()
		
	elseif szName == "Btn_Close" then
		ClosePartyRecruitPanel()
		
	elseif szName == "Btn_Up" or szName == "Btn_Down" then
		PartyRecruitPanel.OnLButtonHold()
    else
        BattleFieldQueue.OnLButtonClick()
	end
	
	PlaySound(SOUND.UI_SOUND,g_sound.Button)
end

function PartyRecruitPanel.MessageWarning()
		local fun = function()
			RemoteCallToServer("OnLeaveFindTeamDungeon")
			PartyRecruitPanel.tTeamResult = nil
		end
		
		local scene = GetClientPlayer().GetScene()
		PartyRecruitPanel.nCurdwMapID = scene.dwMapID
		
		local funClose = function()
			local scene = GetClientPlayer().GetScene()
			if scene.dwMapID ~= PartyRecruitPanel.nCurdwMapID then
				return true
			end
			return false
		end
		
		local szContent = "<text>text="..EncodeComponentsString(g_tStrings.STR_FT_LEAVE_DUNGEON_ILLEAGAL).." </text>"
		local msg =
		{
		  	bRichText = true,
			szMessage = szContent,
			szName = "LeaveFindDungeon",
			fnAutoClose = funClose,
		}
		table.insert(msg, { szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = fun, })
		table.insert(msg, { szOption = g_tStrings.STR_PLAYER_CANCEL})
		
		MessageBox(msg)
end

function PartyRecruitPanel.OnItemLButtonDown()
	local l_tThis = PartyRecruitPanel
	
	local szName = this:GetName()
	if this.bGroup then
		l_tThis.Selected(this)
		if l_GroupInfo[this.nGroupID].bTwoMan then
			l_tThis.UpdateTwoManContent(this:GetRoot(), this.nGroupID)
		else
			l_tThis.UpdateGroupContent(this:GetRoot(), this.nGroupID)
		end
		
	elseif this.bGDungeon then
		l_tThis.Selected(this)
    else
        BattleFieldQueue.OnItemLButtonDown()
	end
end

local function GetGroupTip(nGroupID)
	local tInfo = l_GroupInfo[nGroupID]
	local szTip = l_GroupInfo[nGroupID].szName.."£º"
	local bFirst = true
	
	if not tInfo.tMap then
		return 
	end
	
	for k , v in pairs(tInfo.tMap) do
		if not bFirst then
			szTip = szTip.."£¬"	
		end
		
		szTip = szTip.."["..Table_GetMapName(v).."]"
		bFirst = false
	end
	szTip = szTip.."¡£"
	return szTip
end

function PartyRecruitPanel.OnItemMouseEnter()
	local szName = this:GetName()
	
	if this.bGroup or this.bGDungeon then
		this.bOver = true
		UpdateBgStatus(this)
		
		local szTip = GetGroupTip(this.nGroupID)
    	if szTip then
	    	local x, y = this:GetAbsPos()
	    	local w, h = this:GetSize()
			
	    	local szTip = "<text>text="..EncodeComponentsString(szTip).." font=18 </text>"
			OutputTip(szTip, 300, {x, y, w, h})
		end
    else
        BattleFieldQueue.OnItemMouseEnter()
	end
end

function PartyRecruitPanel.OnItemMouseLeave()
	local szName = this:GetName()
	if this.bGroup or this.bGDungeon then
		this.bOver = false
		UpdateBgStatus(this)
		HideTip()
    else
        BattleFieldQueue.OnItemMouseLeave()
	end
end

function PartyRecruitPanel.OnItemMouseWheel()

end

function PartyRecruitPanel.IsInFindTeamDungeon()
	local l_tThis = PartyRecruitPanel
	local player = GetClientPlayer()
	
	local tInfo = l_tThis.tTeamResult
	if tInfo then
		local nDungeonType = tInfo.nDungeonType
		if nDungeonType == 0 and player.GetScene().dwMapID == tInfo.dwMapID then
			return true
		end
	end
	return false
end

function PartyRecruitPanel.UpdateLeaveQueueButton()
	if not IsPartyRecruitPanelOpened() then
		return
	end
	
	local frame = Station.Lookup("Normal/PartyRecruitPanel")
	if not frame then
		return
	end
	
	local l_tThis = PartyRecruitPanel
	local nQueueID = l_tThis.nSelGroup 
	
	local hBtn = frame:Lookup("PageSet_Total/Page_DungeonGroup/Btn_DLeaveQueue")
	if nQueueID and l_tThis.tAttendQueue[nQueueID] then
		hBtn:Show()
	else
		hBtn:Hide()
	end
end

function GetPartyRecruitState()
	local l_tThis = PartyRecruitPanel
	
    if l_tThis.bDungeonEnd then
    	return "DungeonEnd"
    end
    
	if l_tThis.IsInFindTeamDungeon() then
		return "InFTDungeon"
	end
	
	if l_tThis.tCanEnterMap then
		return "CanEnter"
	end
	
	local tAttend = l_tThis.tAttendQueue or {}
	for k, v in pairs(tAttend) do
		return "InQueue"
	end
	
	return "Normal"
end

function GetPartyRecruitTip()
	local l_tThis = PartyRecruitPanel
	
	local szState = GetPartyRecruitState()
	local szTip = ""
	if szState == "DungeonEnd" then
		szTip = szTip .. GetFormatText(g_tStrings.STR_FT_GAME_END, 163)
		szTip = szTip .. GetFormatText("\n\n", 162)
	elseif szState == "InFTDungeon" then
		local scene = GetClientPlayer().GetScene()
		local szMapName = Table_GetMapName(scene.dwMapID)
		szTip = szTip .. GetFormatText(FormatString(g_tStrings.STR_FT_IN_DUNGEON, szMapName), 163)
		szTip = szTip .. GetFormatText("\n\n", 162)
	elseif szState == "InQueue" then
		l_tThis.tAttendQueue = l_tThis.tAttendQueue or {}
		for dwQueueID, v in pairs(l_tThis.tAttendQueue) do
			local szName = "\"font=162 </text><text>text=\""..l_GroupInfo[dwQueueID].szName.."\"font=163</text><text>text=\""
			local szText = "<text>text=\""..FormatString(g_tStrings.STR_FT_GROUP_PARTY, szName).."\"font=162</text>"
			szTip = szTip ..szText
			szTip = szTip .. GetFormatText("\n", 162)
			
			szTip = szTip .. GetFormatText(g_tStrings.STR_BATTLEFIELD_QUEUE_TIME_UNKNOW, 162)
			szTip = szTip .. GetFormatText("\n\n", 162)
		end
	elseif szState == "CanEnter" then
		local tInfo = l_tThis.tCanEnterMap
		local szMapName = ""--Table_GetMapName(tInfo.dwMapID)
		szTip = szTip .. GetFormatText(FormatString(g_tStrings.STR_FT_CAN_ENTER_DUNGEON, szMapName), 162)
		szTip = szTip .. GetFormatText("\n", 162)
		
		local nLeftTime = 0
		local dwCurrentTime = GetTickCount()
		if l_tThis.nEnterEndTime and dwCurrentTime < l_tThis.nEnterEndTime then
			nLeftTime = math.floor((l_tThis.nEnterEndTime - dwCurrentTime) / 1000)
		else
			l_tThis.tCanEnterMap = nil
			l_tThis.nEnterEndTime = nil
			FireEvent("PARTY_RECRUITY_STATE_UPDATE")
			return
		end
		
		szTip = szTip .. GetFormatText(g_tStrings.STR_FT_LEFT_ENTER_TIME, 162)
		szTip = szTip .. GetFormatText(FormatString(g_tStrings.STR_MAIL_LEFT_SECOND, nLeftTime), 163)
		
		szTip = szTip .. GetFormatText("\n\n", 162)
	end
	
	return szTip
end


function GetPartyRecruitMenu()
	local l_tThis = PartyRecruitPanel
	
	local tMenu ={}
	local player = GetClientPlayer()
	local szState = GetPartyRecruitState()
	
	if szState == "DungeonEnd" then
		table.insert(tMenu, { szOption = g_tStrings.STR_FT_LEAVE_DEUNGEON, fnAction = function() RemoteCallToServer("OnLeaveFindTeamDungeon") end, })
		return tMenu
	end	
	
	if szState == "InFTDungeon" then
		table.insert(tMenu, { szOption = g_tStrings.STR_FT_FORCE_LEAVE, fnAction = function()  PartyRecruitPanel.MessageWarning()  end, })
		return tMenu
	end
		
	if szState == "CanEnter" then
		local tInfo = l_tThis.tCanEnterMap
		local szName = Table_GetMapName(tInfo.dwMapID)
			
		table.insert(tMenu, { szOption = g_tStrings.STR_FT_ENTER_DUNGEON, fnAction = function() ConfirmEnterDungeon(tInfo.dwMapID, tInfo.nCopyIndex) end, })
		table.insert(tMenu, { szOption = g_tStrings.STR_FT_CANCEL_DUNGEON, fnAction = function() CancelEnterDungeon(tInfo.dwMapID, tInfo.nCopyIndex) end, })
		return tMenu
	end
	
	if szState == "InQueue" then
		l_tThis.tAttendQueue = l_tThis.tAttendQueue or {}
		--l_tThis.tAttendQueue[1003] = true
		for dwQueueID, v in pairs(l_tThis.tAttendQueue) do
			table.insert(tMenu, { szOption = l_GroupInfo[dwQueueID].szName.."£º"..g_tStrings.STR_FT_LEAVE_QUEUE, fnAction = function() LeaveDungeonQueue(dwQueueID) end})
			--table.insert(tMenu, {bDevide = true})
		end
		return tMenu
	end
	
	if szState == "Normal" then
		table.insert(tMenu, { szOption = g_tStrings.STR_DUNGEON_OPEN, fnAction = function() OpenPartyRecruitPanel() end, })
		return tMenu
	end
end

function CanEnterPartyRecruitDungeon(dwMapID, nCopyIndex, nEnterEndTime)
	local l_tThis = PartyRecruitPanel
	
	if not l_tThis.tCanEnterMap  then
		l_tThis.tCanEnterMap = {}
	end
	
	l_tThis.tCanEnterMap["dwMapID"] = dwMapID
	l_tThis.tCanEnterMap["nCopyIndex"] = nCopyIndex

	local fun = function()
		ConfirmEnterDungeon(dwMapID, nCopyIndex)
	end
	
	if not nEnterEndTime then
		nEnterEndTime = GetTickCount() + 30 * 1000	
		FireEvent("PARTY_RECRUITY_STATE_UPDATE")
	end
	PartyRecruitPanel.nEnterEndTime = nEnterEndTime
	
	local funClose = function()
		local dwCurrentTime = GetTickCount()
		if not PartyRecruitPanel.nEnterEndTime or PartyRecruitPanel.nEnterEndTime <= dwCurrentTime then
			return true
		end
		return false
	end
	
	local szMapName = ""--Table_GetMapName(dwMapID) 
	local szContent = "<text>text="..EncodeComponentsString(FormatString(g_tStrings.STR_FT_ENTER_TIP_INFO, szMapName)).." </text>"
	local msg = nil
	msg =
	{
	  	bRichText = true,
		szMessage = szContent,
		szName = "EnterFindDungeon",
		fnAutoClose = funClose,
	}
	
	local nCountTime = math.floor(nEnterEndTime - GetTickCount()) / 1000
	table.insert(msg, { szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = fun, nCountDownTime = nCountTime})
	table.insert(msg, { szOption = g_tStrings.STR_HOTKEY_HIDE})
	
	MessageBox(msg)
	
	RemoteCallToServer("OnGetPlayerQueueIDList")
end

function GetPartyRecruitWaitEnterEndTime()
	return PartyRecruitPanel.nEnterEndTime
end
--==============================================================
--UpdateTwoDungeonReward({dwMapID=57, [1]={122,22,44,55}, [2]={234,456,7567,87}})

TwoDungeonReward = {}

function TwoDungeonReward.OnFrameCreate()
	UpdateTwoDungeonReward(PartyRecruitPanel.tRewards)
	TwoDungeonReward.UpdateHelp(this);
    TwoDungeonReward.UpdateBtnState(this)
	
	local player = GetClientPlayer()
	local scene = player.GetScene()
	RemoteCallToServer("OnRequestFindTeamDungeonInfo", scene.dwMapID, scene.dwID)
end

function TwoDungeonReward.OnFrameBreathe()
    local nPQEndFrame = FindTeamPQObjective.GetPQEndFrame()
    if nPQEndFrame then
        local dwFrame = GetLogicFrameCount()
        local nLeftFrame = nPQEndFrame - dwFrame
        if nLeftFrame < 0 then
            nLeftFrame = 0
        end
        
        local hText = this:Lookup("PageSet_Integration/Page_State/Wnd_TPDState", "Text_TPDTime")
        local szText = g_tStrings.STR_BATTLEFIELD_TIME_LEFT..GetFormatTime(nLeftFrame, true)
        hText:SetText(szText)
        hText:Show()
    end
end

function IsTwoDungeonRewardOpened()
	local frame = Station.Lookup("Normal/TwoDungeonReward")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end

function OpenTwoDungeonReward(bDisableSound)
	if IsTwoDungeonRewardOpened() then
		return
	end
    
    local frame = Wnd.OpenWindow("TwoDungeonReward")
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
end

function CloseTwoDungeonReward(bDisableSound)
	if not IsTwoDungeonRewardOpened() then
		return
	end
	Wnd.CloseWindow("TwoDungeonReward")
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end
end

function TwoDungeonReward.UpdateBtnState(frame)
    local szState = GetPartyRecruitState()
    local handle = frame:Lookup("PageSet_Integration/Page_State/Btn_Exit", "")
    if szState == "DungeonEnd" then
        handle:Lookup("Text_Exit"):SetText(g_tStrings.STR_FT_LEAVE_DEUNGEON)
    else
        handle:Lookup("Text_Exit"):SetText(g_tStrings.STR_FT_FORCE_LEAVE)
    end
end

function TwoDungeonReward.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_Close" then
		CloseTwoDungeonReward()
	elseif szName == "Btn_Exit" then
		RemoteCallToServer("OnLeaveFindTeamDungeon")
	end
end

function TwoDungeonReward.OnItemMouseEnter()
	if this.nMoney then
		local szTip = GetMoneyText(this.nMoney, 162)
		if szTip then
			local x, y = this:GetAbsPos()
			local w, h = this:GetSize()
		    	
			OutputTip(szTip, 300, {x, y, w, h})
		end
	end
end

function TwoDungeonReward.OnItemMouseLeave()
	HideTip()
end

function TwoDungeonReward.UpdateHelp(frame)
	local szState = GetPartyRecruitState()
	if szState ~= "InFTDungeon" then
		return
	end
	
	local player = GetClientPlayer()
	local tInfo = Table_GetDungeonInfo(player.GetScene().dwMapID)
	local szHelpImage, szHelpText = tInfo.szHelpImage, tInfo.szHelpText
    
	local hHandleHelpPage = frame:Lookup("PageSet_Integration/Page_Help", "")
	local hHandleHelpText = hHandleHelpPage:Lookup("Handle_HelpText")
	hHandleHelpText:Clear()
	
	if szHelpText then
		hHandleHelpText:AppendItemFromString(szHelpText)
		hHandleHelpText:FormatAllItemPos()
	end
	
	local hIamgeHelp = hHandleHelpPage:Lookup("Image_Help")
	if szHelpImage and #szHelpImage > 0 then
		hIamgeHelp:FromTextureFile(szHelpImage)
		hIamgeHelp:Show()
	else
		hIamgeHelp:Hide()
	end
	
	local hScroll, hBtnUp, hBtnDown
	hScroll = frame:Lookup("PageSet_Integration/Page_Help/Scroll_HelpText")
	hBtnUp = frame:Lookup("PageSet_Integration/Page_Help/Btn_Up")
	hBtnDown = frame:Lookup("PageSet_Integration/Page_Help/Btn_Down")
	hHandleHelpText:FormatAllItemPos();
    
	PartyRecruitPanel.OnUpdateScorllList(hHandleHelpText, hScroll, hBtnUp, hBtnDown)
end

function UpdateTwoDungeonReward(tRewards)
	local l_tThis = PartyRecruitPanel
    local player = GetClientPlayer()
	local scene = player.GetScene()
    
	if tRewards and tRewards["dwMapID"] ~= scene.dwMapID then
		return
	end
	
	local tTeamResult = l_tThis.tTeamResult
	if not tTeamResult then
		return
	end
	local frame = Station.Lookup("Normal/TwoDungeonReward")
    local hWnd =  frame:Lookup("PageSet_Integration/Page_State/Wnd_TPDState")
	local hList = hWnd:Lookup("", "Handle_List")
	hList:Clear()
	
	local dwMapID = tTeamResult.dwMapID
	if tTeamResult.nDungeonType == 0 and dwMapID then
		local szMapName = Table_GetMapName(dwMapID) or ""
		frame:Lookup("", "Text_Title"):SetText(szMapName)
		
		local tTitle = tTeamResult.tTitle
		hWnd:Lookup("CheckBox_3", "Text_Describe1"):SetText(tTitle[1])
		hWnd:Lookup("CheckBox_4", "Text_Describe2"):SetText(tTitle[2])		
		hWnd:Lookup("CheckBox_5", "Text_Describe3"):SetText(tTitle[3])
		hWnd:Lookup("CheckBox_6", "Text_Describe4"):SetText(tTitle[4])
		
		local tData = tTeamResult.tData
		
		local hTeam = GetClientTeam()
		local nGroupNum = hTeam.nGroupNum
		for i = 0, nGroupNum - 1 do
			local tGroupInfo = hTeam.GetGroupInfo(i)
			if tGroupInfo and tGroupInfo.MemberList then
				for _, dwID in pairs(tGroupInfo.MemberList) do
					if tData[dwID] then
						local hItem = hList:AppendItemFromIni(INI_FILE_PATH1, "Handle_Player")
						local tMemberInfo = hTeam.GetMemberInfo(dwID)
						local szPlayerName = tMemberInfo.szName or ""
						
						local szPath, nFrame = GetForceImage(tMemberInfo.dwForceID)	
						hItem:Lookup("Image_School"):FromUITex(szPath, nFrame)
						hItem:Lookup("Text_PlayerName"):SetText(szPlayerName)
						hItem:Lookup("Text_Lv"):SetText(tMemberInfo.nLevel)
						
						for k, szT in ipairs(tTitle) do
							local szValue = ""
							if szT and szT ~= "" then
								szValue = tData[dwID][k]
							end
							hItem:Lookup("Text_PlayerDescribe"..k):SetText(szValue)
						end
						
                        if tRewards and tRewards[dwID] then
                            hItem:Lookup("Text_S1"):SetText(tRewards[dwID][1])
                            hItem:Lookup("Text_S2"):SetText(tRewards[dwID][2])
                        
						
                            local nGold, nSliver, nCopper = MoneyToGoldSilverAndCopper(tRewards[dwID][3])
                            nGold = nGold or 0
                            nSliver = nSliver or 0
                            local nMoney = nGold * 100 + nSliver
                        
                            local hTextMoney = hItem:Lookup("Text_S3")
                            hTextMoney:SetText(nMoney)
                            hTextMoney.nMoney = tRewards[dwID][3]
                            
                            hItem:Lookup("Text_S4"):SetText(tRewards[dwID][4])
                        else
                            hItem:Lookup("Text_S1"):SetText("")
                            hItem:Lookup("Text_S2"):SetText("")
                            hItem:Lookup("Text_S3"):SetText("")
                            hItem:Lookup("Text_S4"):SetText("")
                        end
					end
				end
			end
		end
        if tRewards and tRewards[player.dwID] then
            hWnd:Lookup("", "Text_Score"):Show()
            hWnd:Lookup("", "Image_Score"):Show()
            local nScoreLevel = SCORE_LEVEL_IMAGE_FRAME[tRewards[player.dwID][5]]
            hWnd:Lookup("", "Image_Score"):SetFrame(nScoreLevel)
        else
            hWnd:Lookup("", "Text_Score"):Hide()
            hWnd:Lookup("", "Image_Score"):Hide()
		end
		hList:FormatAllItemPos()
		
		FireEvent("PARTY_RECRUITY_STATE_UPDATE")
	end
end

--===============================================


function OnPartyRecruitResponse(dwQueueID, szMsg, tErrorInfo)
	local l_tThis = PartyRecruitPanel
	local tSuccessMsg = 
	{
		["JoinSuccess"] = g_tStrings.STR_FT_ATTEND,
		--["EnterSuccess"] = g_tStrings.STR_FT_ATTEND,
		["LeaveSuccess"] = g_tStrings.STR_FT_LEAVE_QUEUE,
	}
	
	local tFailedMsg = 
	{
		["EnterFailed"] = g_tStrings.STR_FT_ENTER_FAILED,
		["JoinFailed_Level"] = g_tStrings.STR_FT_JION_FAILED_LEVEL,
		["JoinFailed_T_MaxPlayer"] = g_tStrings.STR_FT_PLAYERS_ILLEAGAL,
		["JoinFailed_InQueue"] = g_tStrings.STR_FT_IN_QUEUE,
		["JoinFailed_Team"] = g_tStrings.STR_FT_TEAM_JION_FAILED,
		["JoinFailed_Death"] = g_tStrings.STR_FT_DEATH,
		["JoinFailed_InWait"]= g_tStrings.STR_FT_IN_WAIT,
		["JoinFailed_KillPoint"] = g_tStrings.STR_FT_JION_FAIL_KILLPOINT,
		["JoinFailed_Slay"] = g_tStrings.STR_FT_JION_FAIL_SLAY,
		["JoinFailed_InBattleQueue"] = g_tStrings.STR_FT_JION_FAIL_IN_BATTLE_QUEUE,
		["JoinFailed_Remote_Error"] = g_tStrings.STR_FT_JION_FAIL_REMOTE_ERROR,
		["JoinFailed_Unknow"] = g_tStrings.STR_FT_JION_FAIL_UNKNOW,
		
		["EnterFailed_Scene"]= g_tStrings.STR_FT_ENTER_FAIL_SCENE,
		["EnterFailed_AutoFly"] = g_tStrings.STR_FT_ENTER_FAIL_AUTOFLY,
		["EnterFailed_Death"] = g_tStrings.STR_FT_ENTER_FAIL_DEATH,
		["EnterFailed_Fight"] = g_tStrings.STR_FT_ENTER_FAIL_FIGHT,
		["EnterFailed_KillPoint"] = g_tStrings.STR_FT_ENTER_FAIL_KILLPOINT,
		["EnterFailed_Slay"] = g_tStrings.STR_FT_ENTER_FAIL_SLAY,
		
		--["JoinFailed_DeBuff"]
		--["JoinFailed_T_Death"] = g_tStrings.STR_FT_TEAM_JION_DEATH,
		["JoinFailed_T_Level"] = g_tStrings.STR_FT_TEAM_JION_FAILED_LEVEL,
		["JoinFailed_T_DeBuff"] = g_tStrings.STR_FT_TEAM_JION_FAILED_DEBUFF,
		["JoinFailed_T_DifScene"] = g_tStrings.STR_FT_TEAM_JION_FAILED_DIFF_SCENE,
		--["JoinFailed_T_SceneType"] = g_tStrings.STR_FT_TEAM_JION_FAILED_SCENE,
		["JoinFailed_T_InQueue"] = g_tStrings.STR_FT_TEAM_JION_IN_QUEUE,
		["JoinFailed_T_NoScene"] = g_tStrings.STR_FT_TEAM_JION_UNKNOW_ERROR,
		["JoinFailed_T_InWait"] = g_tStrings.STR_FT_TEAM_IN_WAIT,
		["JoinFailed_T_PlayerIsNil"] = g_tStrings.STR_FT_TEAM_PLAYER_IS_NIL,
		["JoinFailed_T_KillPoint"] = g_tStrings.STR_FT_TEAM_PLAYER_KILLPOINT,
		["JoinFailed_T_Slay"] = g_tStrings.STR_FT_TEAM_PLAYER_SLAY,
		["JoinFailed_T_InBattleQueue"] = g_tStrings.STR_FT_TEAM_PLAYER_MEMBER_IN_BATTLE_QUEUE,
		["JoinFailed_T_MemberInBattleQueue"] = g_tStrings.STR_FT_TEAM_PLAYER_MEMBER_IN_BATTLE_QUEUE,
		["JoinFailed_T_Remote_Error"] = g_tStrings.STR_FT_TEAM_PLAYER_REMOTE_ERROR,
		["JoinFailed_T_Unknow"] = g_tStrings.STR_FT_TEAM_PLAYER_UNKNOW,
	}
	

	if szMsg == "JoinSuccess" then
		if not l_tThis.tAttendQueue then
			l_tThis.tAttendQueue = {}
		end
		
		l_tThis.tAttendQueue[dwQueueID] = true
		FireEvent("PARTY_RECRUITY_STATE_UPDATE")
		
		PartyRecruitPanel.UpdateLeaveQueueButton()
	elseif szMsg == "LeaveSuccess" then
		if not l_tThis.tAttendQueue then
			l_tThis.tAttendQueue = {}
		end
		
		l_tThis.tAttendQueue[dwQueueID] = nil
		
		FireEvent("PARTY_RECRUITY_STATE_UPDATE")
		
		PartyRecruitPanel.UpdateLeaveQueueButton()
	elseif szMsg == "EnterSuccess" then
	--elseif szMsg == "EnterFailed_Death" then
	--	CanEnterPartyRecruitDungeon(l_tThis.tCanEnterMap.dwMapID, l_tThis.tCanEnterMap.nCopyIndex, l_tThis.nEnterEndTime)
	end
	
	if tSuccessMsg[szMsg] then
		OutputMessage("MSG_ANNOUNCE_YELLOW", tSuccessMsg[szMsg])
		OutputMessage("MSG_SYS", tSuccessMsg[szMsg].."\n")
	end
	
	if tFailedMsg[szMsg] then
		OutputMessage("MSG_ANNOUNCE_RED", tFailedMsg[szMsg])
		if szMsg ~= "JoinFailed_Team"  then
			OutputMessage("MSG_SYS", tFailedMsg[szMsg].."\n") 
		end
	end
	
	if szMsg == "JoinFailed_Team" and tErrorInfo then
		OutputMessage("MSG_SYS", g_tStrings.STR_FT_TEAM_JION_FAILED_SYS.."\n")
		
		local hTeam = GetClientTeam()
		for szError, tPlayer in pairs(tErrorInfo) do
			for k, dwID in pairs(tPlayer) do 
				local tMemberInfo = hTeam.GetMemberInfo(dwID)
				if tMemberInfo then
					OutputMessage("MSG_SYS", FormatString(tFailedMsg[szError].."\n", tMemberInfo.szName))
				end
			end
		end
	end
end

function PartyRecruitPanel.OnPlayerClientReady()
	local l_tThis = PartyRecruitPanel
	
	local player = GetClientPlayer()
	if arg0 ~= player.dwID then
		return
	end
	
	l_tThis.bDungeonEnd = nil
	l_tThis.tAttendQueue = {}
	l_tThis.nEnterEndTime = nil
	l_tThis.tTeamResult = nil
	l_tThis.tCanEnterMap = nil
	l_tThis.bMapEntering = nil
	 
	if IsTwoDungeonRewardOpened() then
        CloseTwoDungeonReward()
	end
	
	local scene = GetClientScene()
	RemoteCallToServer("OnRequestFindTeamDungeonInfo", scene.dwMapID, scene.dwID)
	
	if IsPartyRecruitPanelOpened() then		
		local frame = Station.Lookup("Normal/PartyRecruitPanel")
		l_tThis.UpdateButtonState(frame, true)
	end
	
	RemoteCallToServer("OnGetPlayerQueueIDList")
	RemoteCallToServer("OnIsPlayerInWaitConfirm")
	
	FireEvent("PARTY_RECRUITY_STATE_UPDATE")
end

function OnPartyRecruitDungeonFinished(tRewards)
	local l_tThis = PartyRecruitPanel
	
	l_tThis.tRewards = tRewards
	l_tThis.bDungeonEnd = true
	
	local player = GetClientPlayer()
	local scene = player.GetScene()
	RemoteCallToServer("OnRequestFindTeamDungeonInfo", scene.dwMapID, scene.dwID)
end

function PartyRecruitRequestPQInfo()
	local l_tThis = PartyRecruitPanel
	
	if IsTwoDungeonRewardOpened() or not l_tThis.bMapEntering then
		l_tThis.bMapEntering = true
		
		local player = GetClientPlayer()
		local scene = player.GetScene()
		RemoteCallToServer("OnRequestFindTeamDungeonInfo", scene.dwMapID, scene.dwID)
	end
end

function OnResponseQueryQueueState(tQueueID)
	local l_tThis = PartyRecruitPanel
	tQueueID = tQueueID or  {}
	l_tThis.tAttendQueue = {}
	for k, dwQueueID in pairs(tQueueID) do
		l_tThis.tAttendQueue[dwQueueID] = true
	end
	
	FireEvent("PARTY_RECRUITY_STATE_UPDATE")
	
	PartyRecruitPanel.UpdateLeaveQueueButton()
end

function PartyRecruitPanel.WaitingTimeEnd()
	local tInfo = PartyRecruitPanel.tCanEnterMap
	if tInfo.dwMapID and tInfo.nCopyIndex then
		CancelEnterDungeon(tInfo.dwMapID, tInfo.nCopyIndex)
	end
	
	PartyRecruitPanel.tCanEnterMap = nil
	PartyRecruitPanel.nEnterEndTime = nil
	FireEvent("PARTY_RECRUITY_STATE_UPDATE")
end

function IsPartyRecruitPanelOpened()
	local frame = Station.Lookup("Normal/PartyRecruitPanel")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end

function OpenPartyRecruitPanel(bDisableSound)
	if IsPartyRecruitPanelOpened() then
		return
	end
	
	local frame = Wnd.OpenWindow("PartyRecruitPanel")
	BattleFieldQueue.InitWhenOpen(frame)
    
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
end

function ClosePartyRecruitPanel()
	if not IsPartyRecruitPanelOpened() then
		return
	end
	Wnd.CloseWindow("PartyRecruitPanel")
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end
end

do
    RegisterScrollEvent("PartyRecruitPanel")
    UnRegisterScrollAllControl("PartyRecruitPanel")
    
    local szFramePath = "Normal/PartyRecruitPanel"
    local szWndPath = "PageSet_Total/Page_Battlefield/Wnd_Battlefield"
    RegisterScrollControl(
        szFramePath, 
        szWndPath.."/Btn_BattlefieldUp", szWndPath.."/Btn_BattlefieldDown", 
        szWndPath.."/Scroll_Battlefield", 
        {szWndPath, "Handle_TwoPlayerBattlefield"})
        
    szWndPath = "PageSet_Total/Page_Battlefield/Wnd_Battlefield"
    RegisterScrollControl(
        szFramePath, 
        szWndPath.."/Btn_BattlefieldUp", szWndPath.."/Btn_BattlefieldDown", 
        szWndPath.."/Scroll_Battlefield", 
        {szWndPath, "Handle_TwoPlayerBattlefield"})
end

RegisterEvent("LOADING_END", PartyRecruitPanel.OnPlayerClientReady)
RegisterEvent("PARTY_RECRUITY_CANCEL_ENTER", PartyRecruitPanel.WaitingTimeEnd)

--SYNC_ROLE_DATA_END