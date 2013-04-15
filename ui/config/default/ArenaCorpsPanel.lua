local lc_tOpenCorps = 
{
	[ARENA_TYPE.ARENA_2V2] = false,
	[ARENA_TYPE.ARENA_3V3] = false,
	[ARENA_TYPE.ARENA_5V5] = false,
}

local ARENA_TIME =
{
	WEEK = g_tStrings.STR_ARENA_WEEK ,
	LAST_WEEK = g_tStrings.STR_ARENA_LAST_WEEK,
	SEASON = g_tStrings.STR_ARENA_SEASON,
}

local lc_tArenaTime = 
{
	[ARENA_TYPE.ARENA_2V2] = ARENA_TIME.WEEK,
	[ARENA_TYPE.ARENA_3V3] = ARENA_TIME.WEEK,
	[ARENA_TYPE.ARENA_5V5] = ARENA_TIME.WEEK,
}

local lc_tCorpsID = {}

ArenaCorpsPanel = 
{
	nCheckArenaType = ARENA_TYPE.ARENA_2V2,
}
local INI_FILE_PATH = "ui/config/default/ArenaCorpsPanel.ini"

local CREATE_GOLD = 100
local CREATE_MONEY_FONT = 162

local lc_hFrame
local lc_hWndArena
local lc_hHandleOn
local lc_hHandleUnder
local lc_tCorpsInfo = {}
local lc_tMembersInfo = {}
local lc_dwPeekPlayerID

local function GetArenaPlayer()
	local player = GetClientPlayer()
	if lc_dwPeekPlayerID ~= player.dwID then
		return GetPlayer(lc_dwPeekPlayerID)
	end
	return player
end

function ArenaCorpsPanel.OnFrameCreate()
	this:RegisterEvent("UI_SCALE")
	this:RegisterEvent("CORPS_OPERATION")
	this:RegisterEvent("ARENA_POPUP_MENU_CNAHGE")
	this:RegisterEvent("SYNC_CORPS_LIST")
	this:RegisterEvent("SYNC_CORPS_BASE_DATA")
	this:RegisterEvent("SYNC_CORPS_MEMBER_DATA")
	
	ArenaCorpsPanel.Init(this)
	
	ArenaCorpsPanel.UpdateCorpsInfo()
	InitFrameAutoPosInfo(this, 1, nil, nil, function() CloseArenaCorpsPanel(true) end)
end

function ArenaCorpsPanel.OnFrameBreathe()
	if not ArenaCorpsPanel.bClientPlayer then
		if not ArenaCorpsPanel.nFrameCount then
			ArenaCorpsPanel.nFrameCount = 0
		end
		
		if ArenaCorpsPanel.nFrameCount >= 16 then
			if not GetArenaPlayer() then
				CloseArenaCorpsPanel();
				return;
			end
			ArenaCorpsPanel.nFrameCount = 0
		end
		ArenaCorpsPanel.nFrameCount = ArenaCorpsPanel.nFrameCount + 1
	end
end

function ArenaCorpsPanel.Init(hFrame)
	lc_hFrame = hFrame
	lc_hWndArena = hFrame:Lookup("Wnd_Arena")
	lc_hHandleOn = lc_hWndArena:Lookup("", "Handle_InfoOn")
	lc_hHandleUnder = lc_hWndArena:Lookup("", "Handle_InfoUnder")
	lc_hCheck2v2 = hFrame:Lookup("CheckBox_Two")
	lc_hCheck3v3 = hFrame:Lookup("CheckBox_Three")
	lc_hCheck5v5 = hFrame:Lookup("CheckBox_Five")
	
	local szTitle = ""
	if not ArenaCorpsPanel.bClientPlayer then
		local PPlayer = GetArenaPlayer()
		szTitle =  PPlayer.szName
		
		lc_hFrame:Lookup("", "Text_Title"):SetText(szTitle)
	end
	
	SyncCorpsList(lc_dwPeekPlayerID);
	ArenaCorpsPanel.InitSwitchBtn()
	
	local text = lc_hWndArena:Lookup("Btn_SelectDate", "Text_SelectDate")
	text:SetText(lc_tArenaTime[ArenaCorpsPanel.nCheckArenaType])
	
	local hCurrency = lc_hFrame:Lookup("", "Text_Currency")
	if not ArenaCorpsPanel.bClientPlayer then
		hCurrency:Hide()
	else
		hCurrency:Show()
		hCurrency:SetText(FormatString(g_tStrings.STR_AREAN_AWARD, GetArenaPlayer().nArenaAward or 0))
	end
end

function ArenaCorpsPanel.OnEvent(szEvent)
	if szEvent == "UI_SCALE" then
	elseif szEvent == "SYNC_CORPS_LIST" then
		if lc_dwPeekPlayerID ~= arg0 then
			return
		end
		
		for i=ARENA_TYPE.ARENA_BEGIN, ARENA_TYPE.ARENA_END - 1, 1 do
			local dwCorpsID = GetCorpsID(i, lc_dwPeekPlayerID)
			lc_tCorpsID[i] = dwCorpsID
			if dwCorpsID ~= 0 then
				lc_tOpenCorps[i] = true
				SyncCorpsBaseData(dwCorpsID, false, lc_dwPeekPlayerID)
			else
				lc_tOpenCorps[i] = false
			end
		end
		ArenaCorpsPanel.InitSwitchBtn()
		
	elseif szEvent == "SYNC_CORPS_BASE_DATA" then
		local dwCorpsID = arg0
		local nCorpsType = arg1
		local dwPeekPlayerID = arg2
		local bRank = arg3
		if bRank == 1 then
			return
		end
		
		if lc_dwPeekPlayerID ~= dwPeekPlayerID then
			return
		end
		
		lc_tCorpsInfo[nCorpsType] = GetCorpsInfo(dwCorpsID, false)
		
		ArenaCorpsPanel.UpdateSwitchBtn()
		if nCorpsType == ArenaCorpsPanel.nCheckArenaType then
			ArenaCorpsPanel.UpdateCorpsInfo()
		end
		
	elseif szEvent == "SYNC_CORPS_MEMBER_DATA" then
		local dwCorpsID = arg0
		local nCorpsType = arg1
		local dwPeekPlayerID = arg2
		local bRank = arg3
		if bRank == 1 then
			return
		end
		
		if lc_dwPeekPlayerID ~= dwPeekPlayerID then
			return
		end
		
		if ArenaCorpsPanel.nCheckArenaType == nCorpsType then
			ArenaCorpsPanel.UpdateCorpsInfo()
		end
		
	elseif szEvent == "ARENA_POPUP_MENU_CNAHGE"	then
		if arg0 == "Text_SelectDate" then
			lc_tArenaTime[ArenaCorpsPanel.nCheckArenaType] = arg1
			ArenaCorpsPanel.UpdateCorpsInfo()
		end
	end
end

function ArenaCorpsPanel.UpdateButton(tMember)
	local hBtn = lc_hWndArena:Lookup("Btn_Add")
	if not ArenaCorpsPanel.bClientPlayer then
		hBtn:Hide()
	else
		hBtn:Show()
	end
	
	local bLeader = ArenaCorpsPanel.IsClientLeader(ArenaCorpsPanel.nCheckArenaType, tMember)
	hBtn:Enable(bLeader)
end

function ArenaCorpsPanel.IsClientLeader(dwCorpsType, tMember)
	tMember  = ArenaCorpsPanel.GetPersonInfo(dwCorpsType, tMember)
	if tMember and tMember.bLeader then
		return true
	end
	return false
end

function ArenaCorpsPanel.GetMemberInfo(dwCorpsType)
	--Output(dwCorpsType, lc_tCorpsID[dwCorpsType])
	if not lc_tCorpsID[dwCorpsType] or lc_tCorpsID[dwCorpsType] == 0 then
		return
	end
	
	local tMember = GetCorpsMemberInfo(lc_tCorpsID[dwCorpsType], false)
	if not tMember then
		SyncCorpsMemberData(lc_tCorpsID[dwCorpsType], false, lc_dwPeekPlayerID)
		return
	end
	return tMember
end

function ArenaCorpsPanel.GetPersonInfo(dwCorpsType, tMember)
	if not lc_tCorpsID[dwCorpsType] or lc_tCorpsID[dwCorpsType] == 0 then
		return
	end
	
	if not tMember then
		tMember = ArenaCorpsPanel.GetMemberInfo(dwCorpsType)
		if not tMember then
			return
		end
	end
	--[[
	local tInfo = lc_tMembersInfo[dwCorpsType]
	if tInfo.tPersonInfo then
		return tInfo.tPersonInfo
	end
	]]
	
	local player = GetArenaPlayer()
	if not player then
		return
	end
	
	for k, v in pairs(tMember) do
		if v.szPlayerName == player.szName then
			ArenaCorpsPanel.tPersonInfo = v
			return ArenaCorpsPanel.tPersonInfo
		end
	end
end

function ArenaCorpsPanel.UpdateCorpsInfo()
	local dwCorpsType = ArenaCorpsPanel.nCheckArenaType
	
	local text = lc_hWndArena:Lookup("Btn_SelectDate", "Text_SelectDate")
	text:SetText(lc_tArenaTime[dwCorpsType])
	
	
	local tMember = {}
	if lc_tOpenCorps[dwCorpsType] then
		tMember = ArenaCorpsPanel.GetMemberInfo(dwCorpsType) or  {}
		
	end
	ArenaCorpsPanel.UpdateButton(tMember)
	
	ArenaCorpsPanel.UpdateOnInfo(dwCorpsType, tMember)
	ArenaCorpsPanel.UpdateUnderInfo(dwCorpsType, tMember)
end

function ArenaCorpsPanel.InitSwitchBtn()
	lc_hFrame.bIniting = true
	
	local hCheck2v2 = lc_hFrame:Lookup("CheckBox_Two")
	local hCheck3v3 = lc_hFrame:Lookup("CheckBox_Three")
	local hCheck5v5 = lc_hFrame:Lookup("CheckBox_Five")
	
	hCheck2v2:Enable(lc_tOpenCorps[ARENA_TYPE.ARENA_2V2])
	hCheck3v3:Enable(lc_tOpenCorps[ARENA_TYPE.ARENA_3V3])
	hCheck5v5:Enable(lc_tOpenCorps[ARENA_TYPE.ARENA_5V5])
	
	hCheck2v2:Check(false)
	hCheck3v3:Check(false)
	hCheck5v5:Check(false)
	
	if not lc_tOpenCorps[ARENA_TYPE.ARENA_2V2] and not lc_tOpenCorps[ARENA_TYPE.ARENA_3V3] and
	   not lc_tOpenCorps[ARENA_TYPE.ARENA_5V5] then
	   
	   lc_hWndArena:Hide()
	   lc_hFrame:Lookup("", "Text_Introduction"):Show()
	   lc_hFrame:Lookup("", "Image_ArenaIBg"):Show()
	else
		if not lc_tOpenCorps[ArenaCorpsPanel.nCheckArenaType] then
			for i=ARENA_TYPE.ARENA_BEGIN, ARENA_TYPE.ARENA_END - 1, 1 do
				if lc_tOpenCorps[i] then
					ArenaCorpsPanel.nCheckArenaType = i
					break;
				end
			end
		end
		local nCorpsType = ArenaCorpsPanel.nCheckArenaType
		
		lc_hWndArena:Show()
		lc_hFrame:Lookup("", "Text_Introduction"):Hide()
		lc_hFrame:Lookup("", "Image_ArenaIBg"):Hide()
		hCheck2v2:Check(nCorpsType == ARENA_TYPE.ARENA_2V2)
		hCheck3v3:Check(nCorpsType == ARENA_TYPE.ARENA_3V3)
		hCheck5v5:Check(nCorpsType == ARENA_TYPE.ARENA_5V5)
	end
	
	hCheck2v2.bEnable = lc_tOpenCorps[ARENA_TYPE.ARENA_2V2]
	hCheck3v3.bEnable = lc_tOpenCorps[ARENA_TYPE.ARENA_3V3]
	hCheck5v5.bEnable = lc_tOpenCorps[ARENA_TYPE.ARENA_5V5]
	
	ArenaCorpsPanel.UpdateSwitchBtn()
	lc_hFrame.bIniting = false
end

function ArenaCorpsPanel.UpdateSwitchBtn()
	local hCheck2v2 = lc_hFrame:Lookup("CheckBox_Two")
	local hCheck3v3 = lc_hFrame:Lookup("CheckBox_Three")
	local hCheck5v5 = lc_hFrame:Lookup("CheckBox_Five")
	
	local szLevel = g_tStrings.STR_ARENA_LEVEL
	local function GetLevelDesc(dwCorpsType)
		if not lc_tOpenCorps[dwCorpsType] then
			return FormatString(szLevel, "--")
		end
		
		local tInfo = lc_tCorpsInfo[dwCorpsType]
		if tInfo then
			return FormatString(szLevel, tInfo.nCorpsLevel)
		else
			return FormatString(szLevel, "--")
		end
	end
	
	hCheck2v2:Lookup("", "Text_Two"):SetText(GetLevelDesc(ARENA_TYPE.ARENA_2V2))
	hCheck3v3:Lookup("", "Text_Three"):SetText(GetLevelDesc(ARENA_TYPE.ARENA_3V3))
	hCheck5v5:Lookup("", "Text_Five"):SetText(GetLevelDesc(ARENA_TYPE.ARENA_5V5))
end

function ArenaCorpsPanel.UpdateOnInfo(dwCorpsType, tMember)
	if not lc_hWndArena:IsVisible() then
		return
	end

	local tInfo = lc_tCorpsInfo[dwCorpsType] or {}
	
	local eArenaTime = lc_tArenaTime[ArenaCorpsPanel.nCheckArenaType]
	lc_hHandleOn:Lookup("Text_Type"):SetText(g_tStrings.tCorpsType[dwCorpsType])
	lc_hHandleOn:Lookup("Text_NameOn"):SetText(tInfo.szCorpsName or g_tStrings.STR_ARENA_NAME)
	
	local tPerson = ArenaCorpsPanel.GetPersonInfo(dwCorpsType, tMember) or {}
	local nTotalCount, nWinCount, nLevel, nGrowupLevel = ArenaCorpsPanel.GetInfoByTime(tInfo, eArenaTime)
	nTotalCount = nTotalCount or 0
	nWinCount = nWinCount or 0
	
	local nPersonCount = ArenaCorpsPanel.GetInfoByTime(tPerson, eArenaTime)
	nPersonCount = nPersonCount or 0

	local nLoseCount = nTotalCount - nWinCount
	
	lc_hHandleOn:Lookup("Text_GradeOnNme"):SetText(nLevel or "--")
	lc_hHandleOn:Lookup("Text_RankingOnNme"):SetText(tInfo.dwRanking or "--")
	
	local hList = lc_hHandleOn:Lookup("Handle_InfoOnList")
	hList:Lookup("Text_DateOn"):SetText(lc_tArenaTime[ArenaCorpsPanel.nCheckArenaType])
	
	hList:Lookup("Text_RDigitalOn"):SetText(nTotalCount)
	hList:Lookup("Text_VDDigitalOn"):SetText(FormatString(g_tStrings.STR_ARENA_V_L, nWinCount, nLoseCount))
	hList:Lookup("Text_PDigitalOn"):SetText(nPersonCount)
end

function ArenaCorpsPanel.UpdateUnderInfo(dwCorpsType,  tMember)
	if not lc_hWndArena:IsVisible() then
		return
	end
	
	tMember = tMember or  {}
	local tInfo = lc_tCorpsInfo[dwCorpsType] or {}
	local hList = lc_hHandleUnder:Lookup("Handle_InfoList")
	hList:Clear()
	
	local nTotalCount, nPersonCount, nWinCount, nLevel
	
	local eArenaTime = lc_tArenaTime[ArenaCorpsPanel.nCheckArenaType]
	
	nTotalCount = ArenaCorpsPanel.GetInfoByTime(tInfo, eArenaTime, 0)
	for k, v in pairs(tMember) do
		local hItem = hList:AppendItemFromIni(INI_FILE_PATH, "Handle_Item")
		nPersonCount, nWinCount, nLevel, nGrowupLevel = ArenaCorpsPanel.GetInfoByTime(v, eArenaTime, 0)

		local szPath, nFrame = GetForceImage(v.dwForceID)
		hItem:Lookup("Image_USchool"):FromUITex(szPath, nFrame)
			
		hItem:Lookup("Text_UName"):SetText(v.szPlayerName)
		hItem:Lookup("Text_UChangC"):SetText(nPersonCount)
		hItem:Lookup("Text_UV_L"):SetText(FormatString(g_tStrings.STR_ARENA_V_L, nWinCount, nPersonCount - nWinCount))
		hItem:Lookup("Text_UPChangC"):SetText(nGrowupLevel)
		if v.bLeader  then
			hItem:Lookup("Image_Leader"):Show()
		end
		
		hItem.dwCorpsID  = lc_tCorpsID[dwCorpsType]
		hItem.dwPlayerID = v.dwPlayerID
		hItem.bLeader = v.bLeader
		hItem.szPlayerName = v.szPlayerName
	end
	FireUIEvent("SCROLL_UPDATE_LIST", hList:GetName(), "ArenaCorpsPanel", true)
end

function ArenaCorpsPanel.GetInfoByTime(tInfo, eArenaTime, default)
	if not tInfo then
		return default, default, default
	end
	
	local nTotalCount = tInfo.dwWeekTotalCount or default
	local nWinCount = tInfo.dwWeekWinCount or default
	local nCorpsLevel = tInfo.nCorpsLevel or default
	local nGrowupLevel = tInfo.nGrowupLevel or default
	
	if eArenaTime == ARENA_TIME.LAST_WEEK then
		nGrowupLevel = tInfo.nLastGrowupLevel or default
		nCorpsLevel = tInfo.nLastCorpsLevel or default
		nTotalCount = tInfo.dwLastWeekTotalCount or default
		nWinCount = tInfo.dwLastWeekWinCount or default
	elseif eArenaTime == ARENA_TIME.SEASON then
		nTotalCount = tInfo.dwSeasonTotalCount or default
		nWinCount = tInfo.dwSeasonWinCount or default
	end
	
	return nTotalCount, nWinCount, nCorpsLevel, nGrowupLevel
end

function ArenaCorpsPanel.TryOpenCorpsWnd(dwCorpsType)
	if not ArenaCorpsPanel.bClientPlayer then
		return
	end
	
	if not lc_tOpenCorps[dwCorpsType] then
		--弹出面板
		local szMsg = g_tStrings.STR_ARENA_BLANK_POS
		szMsg = szMsg .. FormatString(g_tStrings.STR_ARENA_CORPS_NAME, g_tStrings.tCorpsType[dwCorpsType])
		szMsg = szMsg .. "<text>text=\"\n\" </text>" .. g_tStrings.STR_ARENA_BLANK_POS
		szMsg = szMsg .. FormatString(g_tStrings.STR_ARENA_MONEY, GetGoldText(CREATE_GOLD, CREATE_MONEY_FONT))
		GetUserInput(szMsg, function(szText) CreateCorps(dwCorpsType, szText) end, nil, nil, nil, nil, 15, nil, true, true)
	end
end
--===========msg===========================
function ArenaCorpsPanel.OnItemMouseEnter()
	local szName = this:GetName()
	if szName == "Handle_Item" then
		this.bOver = true
		ArenaCorpsPanel.UpdateBgStatus(this, "Image_Light")
	end
	
end

function ArenaCorpsPanel.OnItemMouseLeave()
	local szName = this:GetName()
	if szName == "Handle_Item" then
		this.bOver = false
		ArenaCorpsPanel.UpdateBgStatus(this, "Image_Light")
	end
end

function ArenaCorpsPanel.OnItemLButtonClick()
	local szName = this:GetName()
	if szName == "Handle_Item" then
		ArenaCorpsPanel.SelectResult(this, "Image_Light")
    end
end

function ArenaCorpsPanel.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_Close" then
		CloseArenaCorpsPanel()
		
	elseif szName == "Btn_Add" and lc_tOpenCorps[ArenaCorpsPanel.nCheckArenaType] then
		local dwCorpsID = lc_tCorpsID[ArenaCorpsPanel.nCheckArenaType]
		GetUserInput(g_tStrings.STR_ARENA_MEMBER_NAME, function(szText) InvitationJoinCorps(szText, dwCorpsID) end, nil, nil, nil, nil, 15, nil, nil)
		--弹出面板
	end
end

function ArenaCorpsPanel.OnLButtonDown()
    local szName = this:GetName()
	if szName == "Btn_SelectDate" then
        if not this:IsEnabled() then
            return
        end
        
        local tData = 
        {
            {name = ARENA_TIME.WEEK, value = ARENA_TIME.WEEK},
            {name = ARENA_TIME.LAST_WEEK, value = ARENA_TIME.LAST_WEEK},
			{name = ARENA_TIME.SEASON, value = ARENA_TIME.SEASON},
        }
		local text = this:Lookup("", "Text_SelectDate")
		ArenaCorpsPanel.PopupMenu(this, text, tData)
        return true
	elseif szName == "CheckBox_Two" and not this.bEnable then
		ArenaCorpsPanel.TryOpenCorpsWnd(ARENA_TYPE.ARENA_2V2)
		
	elseif szName == "CheckBox_Three" and not this.bEnable then
		ArenaCorpsPanel.TryOpenCorpsWnd(ARENA_TYPE.ARENA_3V3)
		
	elseif szName == "CheckBox_Five" and not this.bEnable then
		ArenaCorpsPanel.TryOpenCorpsWnd(ARENA_TYPE.ARENA_5V5)
		
	end
end


function ArenaCorpsPanel.OnItemRButtonClick()
	local szName = this:GetName()
	if szName == "Handle_Item" then
		if not ArenaCorpsPanel.bClientPlayer then
			return
		end
	
		if this.bIgnor then
			this.bIgnor = nil
			return
		end
		local fnClose=function()
			if not IsArenaCorpsPanelOpened() then
				return true
			end
			return false;
		end	
		
		local nArenaType =  ArenaCorpsPanel.nCheckArenaType
		local xC, yC = Cursor.GetPos()
		local menu = 
		{
			nMiniWidth = 150,
			x = xC, y = yC,
			fnCancelAction = function() 
				if this:IsValid() then
					local x, y = Cursor.GetPos()
					local xA, yA = this:GetAbsPos()
					local w, h = this:GetSize()
					if x >= xA and x < xA + w and y >= yA and y <= yA + h then
						this.bIgnor = true
					end
				end
			end,
			
			fnAction = function(UserData)
				local szType = UserData[1]
				if szType == g_tStrings.STR_TEAMMATE_CHANGE_PARTY_LEADER then
					local szMsg = FormatString(g_tStrings.STR_ARENA_CHANGE_SURE_TIP, g_tStrings.tCorpsType[nArenaType])
					ArenaCorpsPanel.MessageBox(szMsg, "ArenaCorps_Change", CorpsChangeLeader, fnClose, UserData[2], UserData[3])
					
				
				elseif szType == g_tStrings.STR_ARENA_DESTORY then
					local szMsg = FormatString(g_tStrings.STR_ARENA_DESTORY_TIP, g_tStrings.tCorpsType[nArenaType])
					ArenaCorpsPanel.MessageBox(szMsg, "ArenaCorps_destory", DestroyCorps, fnClose, UserData[3])
					
				elseif szType == g_tStrings.STR_ARENA_INVITE then
					 GetClientTeam().InviteJoinTeam(UserData[4])
					--InvitationJoinCorps(UserData.dwPlayerID, UserData.dwCorpsID)
					
				elseif szType == g_tStrings.STR_ARENA_REMOVE then
					local szMsg = FormatString(g_tStrings.STR_AREAN_REMOVE_TIP, UserData[4])
					ArenaCorpsPanel.MessageBox(szMsg, "ArenaCorps_remove", CorpsDelMember, fnClose, UserData[2], UserData[3])
					
				elseif szType == g_tStrings.STR_ARENA_WHISPER then
					
					EditBox_TalkToSomebody(UserData[4])
					
				elseif szType == g_tStrings.STR_ARENA_EXIT then
					local szMsg = FormatString(g_tStrings.STR_ARENA_EXIT_TIP, UserData[4])
					ArenaCorpsPanel.MessageBox(szMsg, "ArenaCorps_Exit", CorpsDelMember, fnClose, UserData[2], UserData[3])
				end
			end,
			fnAutoClose = function() return not IsArenaCorpsPanelOpened() end,
		}
		
		local nMemberCount = this:GetParent():GetItemCount()
		local tPerson = ArenaCorpsPanel.GetPersonInfo(ArenaCorpsPanel.nCheckArenaType)
		
		if tPerson and tPerson.dwPlayerID ~= this.dwPlayerID then
			table.insert(menu, {szOption=g_tStrings.STR_ARENA_INVITE, bDisable = not CanMakeParty(),
				UserData={g_tStrings.STR_ARENA_INVITE, this.dwPlayerID, this.dwCorpsID, this.szPlayerName}})
		end
		
		table.insert(menu, {szOption=g_tStrings.STR_ARENA_WHISPER,
			UserData={g_tStrings.STR_ARENA_WHISPER, this.dwPlayerID, this.dwCorpsID, this.szPlayerName}})
		
		table.insert(menu, {bDevide= true})
		
		if tPerson and tPerson.bLeader and tPerson.dwPlayerID ~= this.dwPlayerID then
			table.insert(menu, {szOption=g_tStrings.STR_TEAMMATE_CHANGE_PARTY_LEADER, 
				UserData={g_tStrings.STR_TEAMMATE_CHANGE_PARTY_LEADER, this.dwPlayerID, this.dwCorpsID, this.szPlayerName}})
		end
		
		if tPerson and tPerson.bLeader and tPerson.dwPlayerID == this.dwPlayerID and nMemberCount == 1 then
			table.insert(menu, {szOption=g_tStrings.STR_ARENA_DESTORY, 
				UserData={g_tStrings.STR_ARENA_DESTORY, this.dwPlayerID, this.dwCorpsID, this.szPlayerName}})
		end
		
		if tPerson and tPerson.bLeader and tPerson.dwPlayerID ~= this.dwPlayerID then
			table.insert(menu, {szOption=g_tStrings.STR_ARENA_REMOVE, 
				UserData={g_tStrings.STR_ARENA_REMOVE, this.dwPlayerID, this.dwCorpsID, this.szPlayerName}})
		end
		
		if tPerson and not tPerson.bLeader and tPerson.dwPlayerID == this.dwPlayerID then
			table.insert(menu, {szOption=g_tStrings.STR_ARENA_EXIT, 
				UserData={g_tStrings.STR_ARENA_EXIT, this.dwPlayerID, this.dwCorpsID, g_tStrings.tCorpsType[ArenaCorpsPanel.nCheckArenaType]}})
		end
		
		PopupMenu(menu)
	end
end

function ArenaCorpsPanel.OnCheckBoxCheck()
	if lc_hFrame.bIniting then
		return
	end
    
	lc_hFrame.bIniting = true
	
	local szName = this:GetName()
	if szName == "CheckBox_Two" then
		lc_hFrame:Lookup("CheckBox_Three"):Check(false)
		lc_hFrame:Lookup("CheckBox_Five"):Check(false)
		
		ArenaCorpsPanel.nCheckArenaType = ARENA_TYPE.ARENA_2V2

	elseif szName == "CheckBox_Three" then
		lc_hFrame:Lookup("CheckBox_Two"):Check(false)
		lc_hFrame:Lookup("CheckBox_Five"):Check(false)
		
		ArenaCorpsPanel.nCheckArenaType = ARENA_TYPE.ARENA_3V3
		
	elseif szName == "CheckBox_Five" then
		lc_hFrame:Lookup("CheckBox_Three"):Check(false)
		lc_hFrame:Lookup("CheckBox_Two"):Check(false)
		
		ArenaCorpsPanel.nCheckArenaType = ARENA_TYPE.ARENA_5V5
		
	end
	if not lc_tCorpsInfo[ArenaCorpsPanel.nCheckArenaType] then
		SyncCorpsBaseData(lc_tCorpsID[ArenaCorpsPanel.nCheckArenaType], false, lc_dwPeekPlayerID)
	end

	ArenaCorpsPanel.UpdateCorpsInfo()
	
	lc_hFrame.bIniting = false
	PlaySound(SOUND.UI_SOUND, g_sound.Button)
end

--===========msg  end===========================
function ArenaCorpsPanel.SyncCorpsList()
	lc_tOpenCorps[ARENA_TYPE.ARENA_2V2] = false
	lc_tOpenCorps[ARENA_TYPE.ARENA_3V3] = false
	lc_tOpenCorps[ARENA_TYPE.ARENA_5V5] = false
	
	SyncCorpsList(lc_dwPeekPlayerID)
end

function ArenaCorpsPanel.PopupMenu(hBtn, text, tData)
	if hBtn.bIgnor then
		hBtn.bIgnor = nil
		return
	end
    
	local szName = text:GetName()
	local xT, yT = text:GetAbsPos()
	local wT, hT = text:GetSize()
	local menu =
	{
		nMiniWidth = wT,
		x = xT, y = yT + hT,
		fnCancelAction = function()
			if hBtn:IsValid() then
				local x, y = Cursor.GetPos()
				local xA, yA = hBtn:GetAbsPos()
				local w, h = hBtn:GetSize()
				if x >= xA and x < xA + w and y >= yA and y <= yA + h then
                    hBtn.bIgnor = true
				end
			end
		end,
		fnAction = function(UserData)
			if text:IsValid() then
                text:SetText(UserData.name)
                text.Value = UserData.value
				FireUIEvent("ARENA_POPUP_MENU_CNAHGE", szName, text.Value);
			end
		end,
		fnAutoClose = function() return not IsArenaCorpsPanelOpened() end,
	}
	for k, v in ipairs(tData) do
        table.insert(menu, {szOption = v.name, UserData= v, r = v.r, g = v.g, b = v.b})
	end
	PopupMenu(menu)
end

function ArenaCorpsPanel.MessageBox(szMsg, szName, fn, fnClose, Param1, Param2)
    local tMsg = 
    {
        bRichText = true,
        szMessage = szMsg,
        szName = szName,
        {szOption = g_tStrings.STR_HOTKEY_SURE, 
		fnAction = function() 
			if Param1 and Param2 then
				fn(Param1, Param2) 
			elseif Param1 then
				fn(Param1) 
			else
				fn() 
			end
		end, },
        {szOption = g_tStrings.STR_HOTKEY_CANCEL, fnAction = function()  end},
		fnAutoClose = fnClose,
    }
    MessageBox(tMsg)
end


function ArenaCorpsPanel.SelectResult(hSelItem, szImage)
    local hList = hSelItem:GetParent()
    if hList.hSelItem then
        hList.hSelItem.bSel = false
        EquipInquire_UpdateBgStatus(hList.hSelItem, szImage)
    end
	
    hSelItem.bSel = true
    hList.hSelItem = hSelItem
    ArenaCorpsPanel.UpdateBgStatus(hSelItem, szImage)
end

function ArenaCorpsPanel.UpdateBgStatus(hItem, szImage)
    if not hItem then
		return
	end
	local img = hItem:Lookup(szImage)
	if not img then
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
--=============
function IsArenaCorpsPanelOpened()
	local hFrame = Station.Lookup("Normal/ArenaCorpsPanel")
	if hFrame and hFrame:IsVisible() then
		return true
	end
	
	return false
end

function OpenArenaCorpsPanel(bDisableSound, dwPlayerID)
	if IsArenaCorpsPanelOpened() then
		return
	end
	
	ArenaCorpsPanel.bClientPlayer = false;
	if not dwPlayerID then
		dwPlayerID  = GetClientPlayer().dwID
		ArenaCorpsPanel.bClientPlayer = true;
	end
	lc_dwPeekPlayerID = dwPlayerID
	
	if not ArenaCorpsPanel.bClientPlayer then
		lc_tOpenCorps = {}
	end
	
	lc_hFrame = Wnd.OpenWindow("ArenaCorpsPanel")
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
end

function CloseArenaCorpsPanel(bDisableSound)
	if not IsArenaCorpsPanelOpened() then
		return
	end
	
	if not ArenaCorpsPanel.bClientPlayer then
		lc_tOpenCorps = {}
	end
	
	lc_tCorpsInfo = {}
	Wnd.CloseWindow("ArenaCorpsPanel")
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end
end

local function OnInviteRespond(dwCorpsID, dwCorpsType, dwOperatorID, dwBeOperatorID, szOperatorName, szBeOperatorName)
	if IsFilterOperate("INVITE_ARENA_CORPS") then
		 ApplyInvitationJoinCorps(dwOperatorID, dwCorpsID, false)
		return
	end
		
	local player = GetClientPlayer()
	if player.dwID == dwBeOperatorID then
	    local tMsg = 
		{
			bRichText = true,
			szMessage = FormatString(g_tStrings.STR_ARENA_INVITE_MSG, szOperatorName, g_tStrings.tCorpsType[dwCorpsType]),
			szName = "ArenaCorps_beInvite",
			{szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = function() ApplyInvitationJoinCorps(dwOperatorID, dwCorpsID, true) end, },
			{szOption = g_tStrings.STR_HOTKEY_CANCEL, fnAction = function() ApplyInvitationJoinCorps(dwOperatorID, dwCorpsID, false) end},
		}
		MessageBox(tMsg)
	end
end

local function OnCorpsOperation()
	local nType = arg0
	local nRetCode = arg1
	local dwCorpsID = arg2
	local dwCorpsType = arg3
	local dwOperatorID = arg4
	local dwBeOperatorID = arg5
	local szOperatorName = arg6
	local szBeOperatorName = arg7
	local szCorpsName = arg8
	
	local player = GetClientPlayer()
	if nRetCode == CORPS_OPERATION_RESULT_CODE.SUCCESS then
		local szTip = ""
		local dwCPlayerID = GetClientPlayer().dwID
		if nType == CORPS_OPERATION_TYPE.CORPS_CREATE then
			if IsArenaCorpsPanelOpened() and  ArenaCorpsPanel.bClientPlayer then
				lc_tOpenCorps[dwCorpsType] = true
				SyncCorpsBaseData(dwCorpsID, false, lc_dwPeekPlayerID)
				lc_tCorpsID[dwCorpsType] = dwCorpsID
				ArenaCorpsPanel.InitSwitchBtn()
				ArenaCorpsPanel.UpdateCorpsInfo()
			end
			szTip = g_tStrings.tArenaCorpsResult[nType][nRetCode]
			
		elseif nType == CORPS_OPERATION_TYPE.CORPS_DEL_MEMBER then
			if not lc_tOpenCorps[dwCorpsType] then 
				return
			end
			
			szTip = g_tStrings.tArenaCorpsResult[nType][nRetCode]
			if player.dwID == dwBeOperatorID then
				szTip = FormatString(szTip, "", g_tStrings.tCorpsType[dwCorpsType])
			else
				if not szBeOperatorName or szBeOperatorName == "" then
					szBeOperatorName = "目标" 
				end
				
				szTip = FormatString(szTip, szBeOperatorName, g_tStrings.tCorpsType[dwCorpsType])
			end
			
			if IsArenaCorpsPanelOpened() and ArenaCorpsPanel.bClientPlayer then
				if player.dwID == dwBeOperatorID then
					lc_tOpenCorps[dwCorpsType] = false
					lc_tCorpsInfo[dwCorpsType] = nil
					lc_tCorpsID[dwCorpsType] = nil
					ArenaCorpsPanel.InitSwitchBtn()
					ArenaCorpsPanel.UpdateCorpsInfo()
				else
					--SyncCorpsBaseData(dwCorpsID, false)
					SyncCorpsMemberData(dwCorpsID, false, lc_dwPeekPlayerID)
				end
			end
			
		elseif nType == CORPS_OPERATION_TYPE.CORPS_DESTROY then
			--Output("CORPS_OPERATION_TYPE.CORPS_DESTROY")
			lc_tOpenCorps[dwCorpsType] = false
			lc_tCorpsInfo[dwCorpsType] = nil
			lc_tCorpsID[dwCorpsType] = nil
				
			if IsArenaCorpsPanelOpened() and ArenaCorpsPanel.bClientPlayer then
				ArenaCorpsPanel.InitSwitchBtn()
				ArenaCorpsPanel.UpdateCorpsInfo()
			end
			szTip = g_tStrings.tArenaCorpsResult[nType][nRetCode]
			
		elseif nType == CORPS_OPERATION_TYPE.CORPS_ADD_MEMBER then
			if IsArenaCorpsPanelOpened() and ArenaCorpsPanel.bClientPlayer  then
				if player.dwID == dwBeOperatorID  then
					SyncCorpsList(lc_dwPeekPlayerID)
				else
					SyncCorpsMemberData(dwCorpsID, false, lc_dwPeekPlayerID)
					--SyncCorpsBaseData(dwCorpsID, false)
				end
			end
			szTip = g_tStrings.tArenaCorpsResult[nType][nRetCode]
			if player.dwID == dwBeOperatorID  then
				szTip = FormatString(szTip, g_tStrings.STR_NAME_YOU, g_tStrings.tCorpsType[dwCorpsType], szCorpsName)
			else
				if not szBeOperatorName or szBeOperatorName == "" then
					szBeOperatorName = "目标"
				end
				szTip = FormatString(szTip, szBeOperatorName, g_tStrings.tCorpsType[dwCorpsType], szCorpsName)
			end
			
		elseif nType == CORPS_OPERATION_TYPE.INVITATION_JOIN_CORPS then
			OnInviteRespond(dwCorpsID, dwCorpsType, dwOperatorID, dwBeOperatorID, szOperatorName, szBeOperatorName)
			if player.dwID == dwOperatorID then
				szTip = g_tStrings.tArenaCorpsResult[nType][nRetCode]
				szTip = FormatString(szTip, szBeOperatorName, g_tStrings.tCorpsType[dwCorpsType])
			end
			
		elseif nType == CORPS_OPERATION_TYPE.CORPS_CHANGE_LEADER then
			if IsArenaCorpsPanelOpened() and ArenaCorpsPanel.bClientPlayer  then
				SyncCorpsMemberData(dwCorpsID, false, lc_dwPeekPlayerID)
				--SyncCorpsBaseData(dwCorpsID, false)
			end
			
			szTip = FormatString(g_tStrings.tArenaCorpsResult[nType][nRetCode], g_tStrings.tCorpsType[dwCorpsType], szBeOperatorName)
		end
		
		if szTip and szTip ~= "" then
			OutputMessage("MSG_ANNOUNCE_YELLOW", szTip);
			OutputMessage("MSG_SYS", szTip); 
		end
	else
		if player.dwID == dwOperatorID  then
			local szTip = g_tStrings.tArenaCorpsResult[nType][nRetCode]
			OutputMessage("MSG_ANNOUNCE_RED", szTip);	
			OutputMessage("MSG_SYS", szTip); 
		end
	end
end

local function OnCorpsNotify(szEvent)
	if szEvent == "CANCEL_INVITATION_JOIN_CORPS" then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_ARENA_CANCEL_INVITE);
        OutputMessage("MSG_SYS", g_tStrings.STR_ARENA_CANCEL_INVITE); 
	end
end

local lc_tClientOpenCorps = {}
local function OnSyncCorpsList()
	local dwCPlayerID = GetClientPlayer().dwID
	if arg0 ~= dwCPlayerID then
		return
	end
	
	for i=ARENA_TYPE.ARENA_BEGIN, ARENA_TYPE.ARENA_END - 1, 1 do
		local dwCorpsID = GetCorpsID(i, dwCPlayerID)
		lc_tCorpsID[i] = dwCorpsID
		if dwCorpsID ~= 0 then
			lc_tClientOpenCorps[i] = true
		else
			lc_tClientOpenCorps[i] = false
		end
	end
end

function Arena_IsCorpsCreate(nCorpsType)
	return lc_tClientOpenCorps[nCorpsType]
end

RegisterEvent("SYNC_CORPS_LIST", OnSyncCorpsList)
RegisterEvent("CORPS_OPERATION", OnCorpsOperation)
RegisterEvent("CANCEL_INVITATION_JOIN_CORPS", function () OnCorpsNotify("CANCEL_INVITATION_JOIN_CORPS") end )

do
    RegisterScrollEvent("ArenaCorpsPanel")
    
    UnRegisterScrollAllControl("ArenaCorpsPanel")
        
    local szFramePath = "Normal/ArenaCorpsPanel"
    local szWndPath = "Wnd_Arena"
    RegisterScrollControl(
        szFramePath, 
        szWndPath.."/Btn_Up", szWndPath.."/Btn_Down", 
        szWndPath.."/Scroll_List", 
        {szWndPath, "Handle_InfoUnder/Handle_InfoList"})
		
end

RegisterEvent("LOADING_END", function () SyncCorpsList(GetClientPlayer().dwID) end)
