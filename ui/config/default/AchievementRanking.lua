AchievementRanking = {}
AchievementRanking.tGlobalRanking = {}
AchievementRanking.tGlobalAreanRanking = {}

local ARENA_PAGE = 10
local MAX_PAGE = 20
AchievementRanking.tArenaPage = 
{
	["Arena_2V2"] = 0,
	["Arena_3V3"] = 0,
	["Arena_5V5"] = 0,
}
local tArenaType = 
{
	["Arena_2V2"] = ARENA_TYPE.ARENA_2V2,
	["Arena_3V3"] = ARENA_TYPE.ARENA_3V3,
	["Arena_5V5"] = ARENA_TYPE.ARENA_5V5,
}

RegisterCustomData("AchievementRanking.tGlobalRanking")

local function GetArenaRankKey(nArenaType)
	for k, v in pairs(tArenaType) do
		if v ==  nArenaType then
			return k
		end
	end
end

function AchievementRanking.GetMemberInfo(dwCorpsID)
	local tMember = GetCorpsMemberInfo(dwCorpsID, true)
	if not tMember then
		local bCoolDown = (not SyncCorpsMemberData(dwCorpsID, true, GetClientPlayer().dwID))
		local nCurrentTime = GetCurrentTime()
		if bCoolDown then
			OutputMessage("MSG_ANNOUNCE_YELLOW", g_tStrings.STR_SYNC_MEMBER_INFO)
			OutputMessage("MSG_SYS", g_tStrings.STR_SYNC_MEMBER_INFO.."\n")
		end
		
		if bCoolDown and (not AchievementRanking.nSyncCorpsMemTime or  nCurrentTime > AchievementRanking.nSyncCorpsMemTime) then
			AchievementRanking.nSyncCorpsMemTime = GetCurrentTime() + 15
		end
		return
	end
	return tMember
end

function AchievementRanking.OnFrameCreate()
	this:RegisterEvent("ON_FENGYUNLU_GET_RANKING")
	this:RegisterEvent("SYNC_CORPS_RANK_LIST")
	this:RegisterEvent("SYNC_CORPS_BASE_DATA")
	this:RegisterEvent("SYNC_CORPS_MEMBER_DATA")
	
	InitFrameAutoPosInfo(this, 2, nil, nil, function() CloseAchievementRanking(true) end)
end

function AchievementRanking.OnFrameBreathe()
	if AchievementRanking.dwCorpsID and AchievementRanking.nSyncCorpsMemTime then
		local nCurrentTime = GetCurrentTime()
		if nCurrentTime > AchievementRanking.nSyncCorpsMemTime then
			SyncCorpsMemberData(AchievementRanking.dwCorpsID, true, GetClientPlayer().dwID)
			AchievementRanking.nSyncCorpsMemTime = nil
		end
	end
end

function AchievementRanking.OnEvent(szEvent)
	if szEvent == "ON_FENGYUNLU_GET_RANKING" then
		if arg2 == true then
			AchievementRanking.OnSyncGlobalRankingInfo(this, arg0, arg1, arg3, arg4)
		else
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_GET_GLOBALE_RANKING_FAILED)
		end
	elseif szEvent == "SYNC_CORPS_RANK_LIST" then
		local nCorpsType = arg0
		local nPageIndex = arg1
		AchievementRanking.OnSyncCorpsRankList(this, nCorpsType, nPageIndex)
		
	elseif szEvent == "SYNC_CORPS_BASE_DATA" then
		local dwCorpsID = arg0
		local nCorpsType = arg1
		local dwPeekPlayerID = arg2
		local bRank = arg3
		if bRank ~= 1 then
			return
		end
		
		local szKey = GetArenaRankKey(nCorpsType)
		local nPageIndex = AchievementRanking.tArenaPage[szKey]
		local tGlobal = AchievementRanking.tGlobalAreanRanking[szKey]
		if nPageIndex and tGlobal.tCorpsIndex[nPageIndex] and tGlobal.tCorpsIndex[nPageIndex][dwCorpsID] then
			local nIndex = tGlobal.tCorpsIndex[nPageIndex][dwCorpsID]
			tGlobal.tRanking[nIndex] = GetCorpsInfo(dwCorpsID, true)
			if tGlobal.tRanking[nIndex] then
				tGlobal.tRanking[nIndex].dwCorpsID = dwCorpsID
			end
			AchievementRanking.UpdateSelectRanking(this:Lookup("PageSet_Achievement/Page_RANK"))
		end
		
	elseif szEvent == "SYNC_CORPS_MEMBER_DATA" then
		local bRank = arg3
		if bRank ~= 1 then
			return
		end
		
		if arg0 ==  AchievementRanking.dwCorpsID then
			AchievementRanking.UpdateCorpsMembers(this)
		end
	end
end

function AchievementRanking.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_Close" then
		CloseAchievementRanking()
	elseif szName == "Btn_CloseCmp" then
		AchievementRanking.CloseCorpsMembers(this:GetRoot())
	elseif szName == "Btn_ABack" then
		local hFrame = this:GetRoot()
		AchievementRanking.ChangePageIndex(hFrame, -1)
		
	elseif szName == "Btn_ANext" then
		local hFrame = this:GetRoot()
		AchievementRanking.ChangePageIndex(hFrame, 1)
	end
end

function AchievementRanking.OnItemLButtonDown()
    if this.bGroup then
        if this:IsExpand() then
			this:Collapse()
		else
			this:Expand()
		end
        local hList = this:GetParent()
        hList:FormatAllItemPos()
        FireUIEvent("SCROLL_UPDATE_LIST", "Handle_ListRANK", "AchievementRanking", true)
    elseif this.bTitle then
        AchievementRanking.SelectList(this)
	elseif  this.bGlobalGuildRanking then
		AchievementRanking.SelGlobalRanking(this)
	elseif this.bGlobalPlayerRanking then
		AchievementRanking.SelGlobalRanking(this)
	elseif this.szArenaName then
		AchievementRanking.SelGlobalRanking(this)
		AchievementRanking.dwCorpsID = this.aInfo.dwCorpsID
		AchievementRanking.UpdateCorpsMembers(this:GetRoot())
	end
end

function AchievementRanking.SelectList(hSelect)
    if hSelect.bSel then
        return
    end
    local hHandle = hSelect:GetParent()
    local nCount = hHandle:GetItemCount()
    for i = 0, nCount - 1 do
        local hChild = hHandle:Lookup(i)
        if hChild.bSel then
            hChild.bSel = false
            AchievementRanking.UpdateSelShow(hChild)
        end
    end
    hSelect.bSel = true
    AchievementRanking.UpdateSelShow(hSelect)
    local hPage = hHandle:GetParent():GetParent()
    hPage.bSel = true
	hPage.dwGeneral = hSelect.dwGeneral
	hPage.dwSub =hSelect.dwSub
	hPage.dwDetail = hSelect.dwDetail
    AchievementRanking.UpdateSelectRanking(hPage)
end

function AchievementRanking.OnItemMouseEnter()
	if this.bTitle then
		this.bOver = true
		AchievementRanking.UpdateSelShow(this)
		if this.bGlobalRanking then
			local tRankingInfo = g_tTable.Ranking:Search(this.dwDetail)
			if tRankingInfo and tRankingInfo.szDesc ~= "" then
				local x, y = this:GetAbsPos()
				local w, h = this:GetSize()
				OutputTip(tRankingInfo.szDesc, 400, {x, y, w, h})			
			end
		end
    elseif this.bGlobalPlayerRanking then
		this.bOver = true
		AchievementRanking.UpdateGlobalRankingSelShow(this)
		local aRankingInfo = g_tTable.Ranking:Search(this.dwDetail)
		if aRankingInfo then
			local x, y = this:GetAbsPos()
			local w, h = this:GetSize()
			local szTip = GetFormatText(this.aInfo[1].."\n", 27)..
				GetFormatText(FormatString(g_tStrings.ACHIEVEMENT_RANK_LEVEL, this.aInfo[4]), 18)..
				GetFormatText(FormatString(g_tStrings.ACHIEVEMENT_RANK_SCHOOL, g_tStrings.tForceTitle[this.aInfo[5]] or g_tStrings.STR_CHARACTER_NO_FORCE), 18)..
				GetFormatText(FormatString(g_tStrings.ACHIEVEMENT_RANK_CAMP, g_tStrings.STR_GUILD_CAMP_NAME[this.aInfo[6]]), 18)..
				GetFormatText(FormatString(g_tStrings.ACHIEVEMENT_RANK_GUILD, this.aInfo[2]), 18)..
				GetFormatText(FormatString(g_tStrings.ACHIEVEMENT_RANK_VALUE, aRankingInfo.szValueName, this.aInfo[7]), 18)
			OutputTip(szTip, 400, {x, y, w, h})
		end
	elseif this.bGlobalGuildRanking then
		this.bOver = true
		AchievementRanking.UpdateGlobalRankingSelShow(this)
		local aRankingInfo = g_tTable.Ranking:Search(this.dwDetail)
		if aRankingInfo then
			local x, y = this:GetAbsPos()
			local w, h = this:GetSize()
			local szTip = GetFormatText(this.aInfo[1].."\n", 27)..
				GetFormatText(FormatString(g_tStrings.ACHIEVEMENT_RANK_GUILD_MASTER, this.aInfo[2]), 18)..
				GetFormatText(FormatString(g_tStrings.ACHIEVEMENT_RANK_GUILD_CAMP, g_tStrings.STR_GUILD_CAMP_NAME[this.aInfo[3]]), 18)..
				GetFormatText(FormatString(g_tStrings.ACHIEVEMENT_RANK_GUILD_MEMBER, this.aInfo[4]), 18)..
				GetFormatText(FormatString(g_tStrings.ACHIEVEMENT_RANK_VALUE, aRankingInfo.szValueName, this.aInfo[5]), 18)
			OutputTip(szTip, 400, {x, y, w, h})
		end
	elseif this.szArenaName then
		this.bOver = true
		AchievementRanking.UpdateGlobalRankingSelShow(this)
	end
end

function AchievementRanking.OnItemMouseLeave()
	if this.bTitle then
		this.bOver = false
		AchievementRanking.UpdateSelShow(this)
		HideTip()
    elseif this.bGlobalPlayerRanking then
		this.bOver = false
		AchievementRanking.UpdateGlobalRankingSelShow(this)
		HideTip()
	elseif this.bGlobalGuildRanking then
		this.bOver = false
		AchievementRanking.UpdateGlobalRankingSelShow(this)			
		HideTip()
	elseif this.szArenaName then
		this.bOver = false
		AchievementRanking.UpdateGlobalRankingSelShow(this)
		HideTip()
	end
end

function AchievementRanking.OnItemRButtonDown()
    if this.bGlobalPlayerRanking then
		local szName = this.szName
		local player = GetClientPlayer()
		local menu = 
		{
			{szOption = g_tStrings.STR_SAY_SECRET, fnAction = function() EditBox_TalkToSomebody(szName) end},
			{szOption = g_tStrings.STR_MAKE_PARTY, bDisable = not CanMakeParty(), fnAction = function() GetClientTeam().InviteJoinTeam(szName) AddContactPeople(szName) end},
			{szOption = g_tStrings.STR_MAKE_FRIEND, fnAction = function() GetClientPlayer().AddFellowship(szName) AddContactPeople(szName) end},
		    {szOption = g_tStrings.INVITE_ADD_GUILD, bDisable = player.dwTongID == 0, fnAction = function() InvitePlayerJoinTong(szName) AddContactPeople(szName) end},
		}
		PopupMenu(menu)
	end
end

function AchievementRanking.UpdateSelShow(hI)
	if AchievementRanking.bIniting then
		return
	end
	
	local img = hI:Lookup("Sel")
	local text = hI:Lookup("Name")
	if hI.bSel then
		img:Show()
		img:SetAlpha(255)
		text:SetFontScheme(162)
	elseif hI.bOver then
		img:Show()
		img:SetAlpha(128)
		text:SetFontScheme(162)
	else
		img:Hide()
		text:SetFontScheme(160)
	end
end

function AchievementRanking.OnSyncGlobalRankingInfo(hFrame, szKey, tMsg, nStartIndex, nNextIndex)
    if nNextIndex ~= 0 then
        RemoteCallToServer("OnQueryGlobalRanking", szKey, nNextIndex, 1)
    end
    
    local tGlobalKey = AchievementRanking.tGlobalRanking[szKey]
   
    if not tGlobalKey or not tGlobalKey.tRanking then
        AchievementRanking.tGlobalRanking[szKey] = {nQueryTime = GetCurrentTime(), tRanking = {}}
        tGlobalKey = AchievementRanking.tGlobalRanking[szKey]
    end
	
    local tRanking = tGlobalKey.tRanking
    for _, v in ipairs(tMsg) do
        table.insert(tRanking, v)
    end
	AchievementRanking.UpdateSelectRanking(hFrame:Lookup("PageSet_Achievement/Page_RANK"))
end

function AchievementRanking.OnSyncCorpsRankList(hFrame, nCorpsType, nPageIndex)
	local szKey = tArenaType[ARENA_TYPE.ARENA_2V2]
	for k, v in pairs(tArenaType) do
		if v == nCorpsType then
			szKey = k
			break;
		end
	end
	
	AchievementRanking.tGlobalAreanRanking[szKey] = AchievementRanking.tGlobalAreanRanking[szKey] or {}
    local tGlobalKey = AchievementRanking.tGlobalAreanRanking[szKey]
	
	tGlobalKey.tRanking = tGlobalKey.tRanking or {}
	tGlobalKey.tCorpsIndex = tGlobalKey.tCorpsIndex or {}
	tGlobalKey.nQueryTime  = tGlobalKey.nQueryTime or GetCurrentTime()
	tGlobalKey.tCorpsIndex[nPageIndex] = tGlobalKey.tCorpsIndex[nPageIndex] or {}
	
	local tCorpsIndex = tGlobalKey.tCorpsIndex[nPageIndex]
	local nEndIndex = (nPageIndex + 1) * ARENA_PAGE - 1
	for nIndex=nPageIndex * ARENA_PAGE, nEndIndex, 1 do
		local dwCorpsID = GetCorpsRankID(nCorpsType, nIndex)
		if dwCorpsID ~= 0 then
			SyncCorpsBaseData(dwCorpsID, true, GetClientPlayer().dwID)
			tCorpsIndex[dwCorpsID] = nIndex
		end
	end
end

function AchievementRanking.UpdateGlobalRankingSelShow(hI)
	if AchievementRanking.bIniting then
		return
	end
	
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

function AchievementRanking.SelGlobalRanking(hI)
	if hI.bSel then
		return
	end
	local hP = hI:GetParent()
	local nCount = hP:GetItemCount() - 1
	for i = 0, nCount, 1 do
		local hB = hP:Lookup(i)
		if hB.bSel then
			hB.bSel = false
			AchievementRanking.UpdateGlobalRankingSelShow(hB)
			break
		end
	end
	
	hI.bSel = true
	AchievementRanking.UpdateGlobalRankingSelShow(hI)
end

function AchievementRanking.UpdateSelectRanking(page)
	local hFrame = page:GetRoot()
	local handle = page:Lookup("", "")
	local hA = handle:Lookup("Handle_RANKList")
	local hD = handle:Lookup("Handle_DescRANK")
	local hG = handle:Lookup("Handle_GuildTitle")
	local hP = handle:Lookup("Handle_PlayerTitle")
	local hArena = handle:Lookup("Handle_ArenaT")

	hA:Show(page.bSel)
	hG:Show(page.bSel)
	hP:Show(page.bSel)
	hArena:Show(page.bSel)
	hD:Show(not page.bSel)
	
	AchievementRanking.bIniting = true
	hA:Clear()
	AchievementRanking.bIniting = false
	
	AchievementRanking.UpdatePageBtn(hFrame, 0, true)

	
	local tRankingInfo = g_tTable.Ranking:Search(page.dwDetail)
	if not tRankingInfo then
		hG:Hide()
		hP:Hide()
		FireUIEvent("SCROLL_UPDATE_LIST", "Handle_RANKList", "AchievementRanking", true)
		return
	end
	local nPageIndex = 0
	if tArenaType[tRankingInfo.szKey] ~= nil then
		nPageIndex = AchievementRanking.tArenaPage[tRankingInfo.szKey]
	end
	
	if tRankingInfo.nType ~= 2 then
		AchievementRanking.dwCorpsID = nil
		AchievementRanking.UpdateCorpsMembers(hFrame)
	end

	local tRanking = AchievementRanking.GetGlobalRankingValue(tRankingInfo.szKey, nPageIndex) or {}
	if tRankingInfo.nType == 1 then --帮会
		hG:Show()
		hP:Hide()
		hArena:Hide()
		hG:Lookup("Text_GuildValue"):SetText(tRankingInfo.szValueName)
		
		local szIniFile = "UI/Config/Default/AchivementRankingGuild.ini"
		for k, v in ipairs(tRanking) do
			local hI = hA:AppendItemFromIni(szIniFile, "Handle_Guild")
			hI.bGlobalGuildRanking = true
			hI.aInfo = v
			hI.dwDetail = page.dwDetail
			hI:Lookup("Text_Name"):SetText(v[1])
			local img = hI:Lookup("Image_Order"..k)
			local text = hI:Lookup("Text_Order")
			if img then
				img:Show()
				text:Hide()
			else
				text:Show()
				text:SetText(k)
			end
			hI:Lookup("Text_Value"):SetText(v[5])
			hI:Lookup("Image_Neutral"):Show(v[3] == CAMP.NEUTRAL)
			hI:Lookup("Image_Good"):Show(v[3] == CAMP.GOOD)
			hI:Lookup("Image_Evil"):Show(v[3] == CAMP.EVIL)
		end
		
	elseif tRankingInfo.nType == 2 then --竞技场
		hG:Hide()
		hP:Hide()
		hArena:Show()
		hArena:Lookup("Text_PlayerValueA"):SetText(tRankingInfo.szValueName)
		hA.szKey = tRankingInfo.szKey
		
		local szIniFile = "UI/Config/Default/AchievementRanking.ini"
		local nEndIndex = (nPageIndex + 1) * ARENA_PAGE - 1
		for nIndex=nPageIndex * ARENA_PAGE, nEndIndex, 1 do
			if tRanking[nIndex] then
				v = tRanking[nIndex]
				local hI = hA:AppendItemFromIni(szIniFile, "Handle_ArenaItem")
				hI:Show()
				hI.bGlobalArenaRanking = true
				hI.aInfo = v
				--hI.dwDetail = page.dwDetail
				hI.szArenaName = v.szCorpsName
				hI:Lookup("Text_NameAI"):SetText(v.szCorpsName)
				local img = hI:Lookup("Image_Order"..(nIndex + 1))
				local text = hI:Lookup("Text_RankAI")
				if img then
					img:Show()
					text:Hide()
				else
					text:Show()
					text:SetText(v.dwRanking)
				end
				local szTip = FormatString(g_tStrings.STR_ARENA_V_L, v.dwSeasonWinCount, v.dwSeasonTotalCount - v.dwSeasonWinCount)
				hI:Lookup("Text_V_LI"):SetText(szTip)
				hI:Lookup("Text_PlayerValueAI"):SetText(v.nLastCorpsLevel)
			end
		end
		AchievementRanking.UpdatePageBtn(page:GetRoot(), nPageIndex, false)
	else
		hG:Hide()
		hArena:Hide()
		hP:Show()
		hP:Lookup("Text_PlayerValue"):SetText(tRankingInfo.szValueName)
		
		local szIniFile = "UI/Config/Default/AchivementRankingPlayer.ini"
		for k, v in ipairs(tRanking) do
			local hI = hA:AppendItemFromIni(szIniFile, "Handle_Player")
			hI.bGlobalPlayerRanking = true
			hI.aInfo = v
			hI.szName = v[1]
			hI.dwDetail = page.dwDetail
			
			hI:Lookup("Text_Name"):SetText(v[1])
			hI:Lookup("Text_Level"):SetText(v[4])
			local img = hI:Lookup("Image_Order"..k)
			local text = hI:Lookup("Text_Order")
			if img then
				img:Show()
				text:Hide()
			else
				text:Show()
				text:SetText(k)
			end
			hI:Lookup("Text_Value"):SetText(v[7])
			hI:Lookup("Image_School"):FromUITex(GetForceImage(v[5]))
		end
	end
	
	
	FireUIEvent("SCROLL_UPDATE_LIST", "Handle_RANKList", "AchievementRanking", true)
end

function AchievementRanking.UpdateCorpsMembers(hFrame)
	local hWnd = hFrame:Lookup("Wnd_Cmp")
	local INI_FILE_PATH = "ui/config/default/AchievementRanking.ini"
	local dwCorpsID = AchievementRanking.dwCorpsID
	if not dwCorpsID then
		hWnd:Hide()
		AchievementRanking.UpdateSize(hFrame)
		return
	end
	hWnd:Show()
	
	local hList = hWnd:Lookup("", "Handle_MemList")
	hList:Clear()
	local tMember = AchievementRanking.GetMemberInfo(dwCorpsID) or {}
	for k, v in pairs(tMember) do
		local hItem = hList:AppendItemFromIni(INI_FILE_PATH, "Handle_Item")
		
		local szPath, nFrame = GetForceImage(v.dwForceID)
		hItem:Lookup("Image_School"):FromUITex(szPath, nFrame)
		hItem:Lookup("Text_Name"):SetText(v.szPlayerName)
		hItem:Lookup("Text_CC"):SetText(v.dwSeasonTotalCount)
		hItem:Lookup("Text_CL_V"):SetText(FormatString(g_tStrings.STR_ARENA_V_L, v.dwSeasonWinCount, v.dwSeasonTotalCount - v.dwSeasonWinCount))
		hItem:Lookup("Text_GX"):SetText(v.nLastGrowupLevel)
	end
	AchievementRanking.UpdateSize(hFrame)
	FireUIEvent("SCROLL_UPDATE_LIST", hList:GetName(), "AchievementRanking", true)
end

function AchievementRanking.UpdateSize(frame)
	local wndCmp = frame:Lookup("Wnd_Cmp")
	local w1, _ = wndCmp:GetSize()
	if wndCmp:IsVisible() then
		frame:SetSize(frame.nFrameW + w1, frame.nFrameH)
	else
		frame:SetSize(frame.nFrameW, frame.nFrameH)
	end
	CorrectAutoPosFrameAfterClientResize()
end

function AchievementRanking.CloseCorpsMembers(hFrame)
	AchievementRanking.dwCorpsID = nil
	AchievementRanking.UpdateCorpsMembers(hFrame)
end

function AchievementRanking.Init(hFrame)
	AchievementRanking.tArenaPage = 
	{
		["Arena_2V2"] = 0,
		["Arena_3V3"] = 0,
		["Arena_5V5"] = 0,
	}
	
	hFrame.nFrameW, hFrame.nFrameH = hFrame:GetSize()
	AchievementRanking.UpdatePageBtn(hFrame, nil, true)
	AchievementRanking.InitRanking(hFrame)
	AchievementRanking.UpdateCorpsMembers(hFrame)
end

function AchievementRanking.InitRanking(hFrame)
	local dwGeneral = 3
	
	local hPage = hFrame:Lookup("PageSet_Achievement/Page_RANK")
	local handle = hPage:Lookup("", "")
	local hList = handle:Lookup("Handle_ListRANK")
	local hAchievement = handle:Lookup("Handle_RANKList")
	hList:Clear()
	hAchievement:Clear()
	local aGeneral = g_tTable.AchievementGeneral:Search(dwGeneral)
	if not aGeneral then
		FireUIEvent("SCROLL_UPDATE_LIST", "Handle_ListRANK", "AchievementRanking", true)
		return
	end	
	--page:GetParent():Lookup("CheckBox_RANK", "Text_RANK"):SetText(aGeneral.szName)
	local szIniFile = "UI/Config/Default/AchievementAdd.ini"
	local szSubs = aGeneral.szSubs
	for s in string.gmatch(szSubs, "%d+") do
		local dwSub = tonumber(s)
		local aSub = g_tTable.AchievementSub:Search(dwSub)
		if aSub then
			local hGroup = hList:AppendItemFromIni(szIniFile, "Group")
			hGroup.dwGeneral = dwGeneral
			hGroup.dwSub = dwSub
			hGroup.bGroup = true
			hGroup.bGlobalRanking = true
			local img = hGroup:Lookup("Image_SelGroup")
			local text = hGroup:Lookup("Text_Group")
			img:SetName("Sel")
			text:SetName("Name")
			text:SetText(aSub.szName)
			
			local szDetails = aSub.szDetails
			for s in string.gmatch(szDetails, "%d+") do
				local dwDetail = tonumber(s)
				local aDetail = g_tTable.Ranking:Search(dwDetail)
				if aDetail then
					local hTitle = hList:AppendItemFromIni(szIniFile, "Title")
					hTitle.dwGeneral = dwGeneral
					hTitle.dwSub = dwSub
					hTitle.dwDetail = dwDetail
					hTitle.bTitle = true
					hTitle.bGlobalRanking = true
					local img = hTitle:Lookup("Image_Sel")
					local text = hTitle:Lookup("Text_Title")
					img:SetName("Sel")
					text:SetName("Name")
					text:SetText(aDetail.szName)
				end
			end
		end
	end
	hList:FormatAllItemPos()
	FireUIEvent("SCROLL_UPDATE_LIST", "Handle_ListRANK", "AchievementRanking", true)
	FireUIEvent("SCROLL_UPDATE_LIST", "Handle_RANKList", "AchievementRanking", true)
end

function AchievementRanking.ChangePageIndex(hFrame, nDelta)
	local hPage = hFrame:Lookup("PageSet_Achievement/Page_RANK")
	local hA = hPage:Lookup("", "Handle_RANKList")
	local szKey = hA.szKey
	local nPageIndex = AchievementRanking.tArenaPage[szKey] + nDelta
	nPageIndex = math.max(nPageIndex, 0)
	nPageIndex = math.min(nPageIndex, MAX_PAGE - 1)

	if nPageIndex ~= AchievementRanking.tArenaPage[szKey] then
		AchievementRanking.tArenaPage[szKey] = nPageIndex
		AchievementRanking.UpdateSelectRanking(hPage)
	end
end

function AchievementRanking.GetArenaRankingValue(szKey, nPageIndex)
	nPageIndex = nPageIndex or  0
	local a = AchievementRanking.tGlobalAreanRanking[szKey]
	local nTime = GetCurrentTime()
	local nArenaType = tArenaType[szKey]
	if not a or not a.nQueryTime then
		SyncCorpsRankList(nArenaType, nPageIndex)
		AchievementRanking.tGlobalAreanRanking[szKey] = {nQueryTime = nTime}
		return {}
	elseif (not a.tCorpsIndex or not a.tCorpsIndex[nPageIndex]) and nTime > a.nQueryTime + 2 then --2sCd
		SyncCorpsRankList(nArenaType, nPageIndex)
		AchievementRanking.tGlobalAreanRanking[szKey].nQueryTime = nTime
		return {}		
	elseif (not a.tRanking or IsTableEmpty(a.tRanking)) and nTime > a.nQueryTime + 2 then --2sCd
		AchievementRanking.OnSyncCorpsRankList(hFrame, nArenaType, nPageIndex)
		return {}
	end
	return a.tRanking or {}
end


function AchievementRanking.GetGlobalRankingValue(szKey, nPageIndex)
	if tArenaType[szKey] ~= nil then
		return AchievementRanking.GetArenaRankingValue(szKey, nPageIndex)
	end
	
	local a = AchievementRanking.tGlobalRanking[szKey]
	local nTime = GetCurrentTime()
	if not a or not a.nQueryTime then
		RemoteCallToServer("OnQueryGlobalRanking", szKey, 1, 1)
		AchievementRanking.tGlobalRanking[szKey] = {nQueryTime = nTime, tRanking = {}}
		return {}
	elseif (not a.tRanking or #(a.tRanking) == 0) and nTime > a.nQueryTime + 2 then --2sCd
		RemoteCallToServer("OnQueryGlobalRanking", szKey, 1, 1)
		AchievementRanking.tGlobalRanking[szKey] = {nQueryTime = nTime, tRanking = {}}
		return {}		
	end
	
	local nlastQTime = a.nQueryTime or 0
	local nTimeRefresh = AchievementRanking.GetRankingRefreshTime(nTime)
	if nTime > nTimeRefresh and nlastQTime < nTimeRefresh then
		RemoteCallToServer("OnQueryGlobalRanking", szKey, 1, 1)
		a.nQueryTime = nTime
		AchievementRanking.tGlobalRanking[szKey] = {nQueryTime = nTime, tRanking = {}}
		return {}
	end
	return a.tRanking
end

function AchievementRanking.GetRankingRefreshTime(nTime)
    local aTime = TimeToDate(nTime)
	local nTimeRefresh = DateToTime(aTime.year, aTime.month, aTime.day, 7, 0, 0)
    local nDay = aTime.weekday
    if nDay == 0 then
        nDay = 7
    end
    
    nTimeRefresh = nTimeRefresh - (nDay - 1) * 24 * 3600
    if nDay == 1 and nTime < nTimeRefresh then -- 如果当前时间是周一的0~7点，那么刷新时间应该是上周一的7点
        nTimeRefresh = nTimeRefresh - 7 * 24 * 3600
    end
    return nTimeRefresh
end

function AchievementRanking.UpdatePageBtn(hFrame, nPageIndex, bHide)
	local hPage = hFrame:Lookup("PageSet_Achievement/Page_RANK")
	local hBtnBack = hPage:Lookup("Btn_ABack")
	local hBtnNext = hPage:Lookup("Btn_ANext")
	local hTextPage = hPage:Lookup("", "Text_Page")
	if bHide then
		hBtnBack:Hide()
		hBtnNext:Hide()
		hTextPage:Hide()
		return
	end
	hBtnBack:Show()
	hBtnNext:Show()
	hTextPage:Show()
	
	if nPageIndex == 0 then
		hBtnBack:Enable(false)
	else
		hBtnBack:Enable(true)
	end
	
	if nPageIndex == MAX_PAGE - 1 then
		hBtnNext:Enable(false)
	else
		hBtnNext:Enable(true)
	end
	hTextPage:SetText((nPageIndex + 1).."/"..MAX_PAGE)
end

function OpenAchievementRanking(bDisableSound)
	if not IsAchievementRankingOpened() then
		Wnd.OpenWindow("AchievementRanking")
	end
	local hFrame = Station.Lookup("Normal/AchievementRanking")
	 AchievementRanking.Init(hFrame)
	 
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND, g_sound.OpenFrame)
	end
end

function IsAchievementRankingOpened()
	local hFrame = Station.Lookup("Normal/AchievementRanking")
	if hFrame then
		return true
	end
	
	return false
end

function CloseAchievementRanking(bDisableSound)
	if not IsAchievementRankingOpened() then
		return
	end
	
	AchievementRanking.dwCorpsID = nil
	Wnd.CloseWindow("AchievementRanking")
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND, g_sound.CloseFrame)
	end
end

do  
    RegisterScrollEvent("AchievementRanking")
    
    UnRegisterScrollAllControl("AchievementRanking")
        
    local szFramePath = "Normal/AchievementRanking"
    local szWndPath = "PageSet_Achievement/Page_RANK"
    RegisterScrollControl(
        szFramePath, 
        szWndPath.."/Btn_UpR", szWndPath.."/Btn_DownR", 
        szWndPath.."/Scroll_ListR", 
        {szWndPath, "Handle_ListRANK"})

    RegisterScrollControl(
        szFramePath, 
        szWndPath.."/Btn_AUpR", szWndPath.."/Btn_ADownR", 
        szWndPath.."/Scroll_AchievementR", 
        {szWndPath, "Handle_RANKList"})
	
	szWndPath = "Wnd_Cmp"
	RegisterScrollControl(
        szFramePath, 
        szWndPath.."/Btn_Up_Info", szWndPath.."/Btn_Down_Info", 
        szWndPath.."/Scroll_Info", 
        {szWndPath, "Handle_MemList"})
end
