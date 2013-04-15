local STAT_TYPE = 
{
	DAMAGE = g_tStrings.STR_DAMAGE_STATISTIC,
	THERAPY = g_tStrings.STR_THERAPY_STATISTIC,
	BE_DAMAGE = g_tStrings.STR_BE_DAMAGE_STATISTIC,
}
local STAT_TYPE2ID = 
{
	[STAT_TYPE.DAMAGE] = 0,
	[STAT_TYPE.THERAPY] = 1,
	[STAT_TYPE.BE_DAMAGE] = 2,
}

local DATA_TYPE = 
{
	TOTAL = 0,
	ONCE = 1,
}

local DATA_TYPE_STRING =
{
	[DATA_TYPE.TOTAL] = g_tStrings.STR_TOTAL_STATISTIC,
	[DATA_TYPE.ONCE] = g_tStrings.STR_ONCE_STATISTIC,
}

local lc_tClientPlayer = {}
local lc_tPlayerInfo = {}

local lc_CurrentHis = 
{
	
	[DATA_TYPE.TOTAL] = nil,
	[DATA_TYPE.ONCE] = nil,
}

local lc_tHistory =
{
	[STAT_TYPE.DAMAGE] = 
	{
		[DATA_TYPE.TOTAL] = {},
		[DATA_TYPE.ONCE] = {},
	},
	[STAT_TYPE.THERAPY] = 
	{
		[DATA_TYPE.TOTAL] = {},
		[DATA_TYPE.ONCE] = {},
	},
	[STAT_TYPE.BE_DAMAGE] = 
	{
		[DATA_TYPE.TOTAL] = {},
		[DATA_TYPE.ONCE] = {},
	},
}

local HISTORY_MAX_COUNT = 10
local INI_FILE = "ui/config/default/FightingStatistic.ini"

FightingStatistic = 
{
	eStatType = STAT_TYPE.DAMAGE,
	eDataType = DATA_TYPE.TOTAL,
	bOpenHistory = false,
	bExpand = true,
	eOpenType = "party",
	bSingleStart = false,
	
	DefaultAnchor = {s = "TOPLEFT", r = "BOTTOMRIGHT", x = -400, y = -400},
	Anchor = {s = "TOPLEFT", r = "BOTTOMRIGHT", x = -400, y = -400},
	
	nVersion = 0,
}
local CURRENT_VERSION = 3
local OBJECT = FightingStatistic
--ui\Image\Common\Money.UITex
local lc_tForceID = 
{
	[0] = {nNorFrame = 210, nLeadFrame=217}, -- 江湖 绿色
	[1] = {nNorFrame = 203, nLeadFrame=216}, --少林   橙黄
	[2] = {nNorFrame = 205, nLeadFrame=212}, --万花  紫色 
	[3] = {nNorFrame = 206, nLeadFrame=215}, --天策   桔红
	[4] = {nNorFrame = 209, nLeadFrame=218}, --纯阳  蓝色  
	[5] = {nNorFrame = 204, nLeadFrame=211}, --七秀   粉红
	[6] = {nNorFrame = 208, nLeadFrame=213}, --五毒   亮蓝
	[7] = {nNorFrame = 207, nLeadFrame=214}, --唐门   蓝绿
	[8] = {nNorFrame = 168, nLeadFrame=219}, --藏剑   黄色
}

local lc_nSelfFrame = 220

RegisterCustomData("FightingStatistic.eStatType")
RegisterCustomData("FightingStatistic.eDataType")
RegisterCustomData("FightingStatistic.bExpand")
RegisterCustomData("FightingStatistic.eOpenType")
RegisterCustomData("FightingStatistic.Anchor")
RegisterCustomData("FightingStatistic.nVersion")

local FRAME_PTR
function FightingStatistic.OnFrameCreate()
	this:RegisterEvent("STAT_SINGLE_END");
	this:RegisterEvent("UPDATE_STAT_DATA");
	this:RegisterEvent("SYNC_ROLE_DATA_END")
	this:RegisterEvent("UI_SCALED")
	
	ActivePlayerStatData(true);
	
	FRAME_PTR = this
	
	this.bIniting = true
	
	this:Lookup("Wnd_List"):Lookup("", "Handle_info"):Clear()
	
	--保持当前数据最新
	OBJECT.UpdateList()
	OBJECT.ExpandFrame(OBJECT.bExpand)
	OBJECT.UpdateAnchor(this)
	OBJECT.UpdateBtnState()
	this.bIniting = false
end

function FightingStatistic.OnEvent(event)
	if event == "UPDATE_STAT_DATA" then
		--保持当前数据最新
		OBJECT.UpdateSingleData()
		if not OBJECT.bOpenHistory then
			OBJECT.UpdateList()
		end
		
	elseif event == "STAT_SINGLE_END" then
		--OBJECT.UpdateHistroy(STAT_TYPE.DAMAGE, DATA_TYPE.TOTAL)
		--OBJECT.UpdateHistroy(STAT_TYPE.THERAPY, DATA_TYPE.TOTAL)
		--OBJECT.UpdateHistroy(STAT_TYPE.BE_DAMAGE, DATA_TYPE.TOTAL)
		
		OBJECT.UpdateHistroy(STAT_TYPE.DAMAGE, DATA_TYPE.ONCE)
		OBJECT.UpdateHistroy(STAT_TYPE.THERAPY, DATA_TYPE.ONCE)
		OBJECT.UpdateHistroy(STAT_TYPE.BE_DAMAGE, DATA_TYPE.ONCE)
	
	elseif event == "UI_SCALED" then
		OBJECT.UpdateAnchor(this)	
	end
end

local function GetPercent(nValue, nTotal)
	local fPercent = 0
	if nTotal ~= 0 then
		fPercent = (nValue / nTotal)
	end
	return fPercent
end

function FightStat_FormatPercent(nValue, nTotal)
	local fPercent = GetPercent(nValue, nTotal)
	local szP = string.format("%.1f%%", fPercent * 100)
	return szP
end

function FightingStatistic.UpdateState()
	FRAME_PTR.bIniting = true
	
	OBJECT.ExpandFrame(OBJECT.bExpand)
	OBJECT.UpdateAnchor(FRAME_PTR)
	
	FRAME_PTR.bIniting = false
end

function FightingStatistic.OnFrameDragEnd()
	this:CorrectPos()
	FightingStatistic.Anchor = GetFrameAnchor(this)
end

function FightingStatistic.UpdateAnchor(frame)
	frame:SetPoint(FightingStatistic.Anchor.s, 0, 0, FightingStatistic.Anchor.r, FightingStatistic.Anchor.x, FightingStatistic.Anchor.y)
	frame:CorrectPos()
end

function FightingStatistic.UpdateSingleData()
	if not IsSingleFStatisticOpened() then
		return
	end
	
	local tData = SingleFStatistic_GetData()
	if tData then
		local dwPlayerID = tData.dwPlayerID
		local tResult, nTotalValue = QuerySkillStatData(dwPlayerID, OBJECT.eDataType)
		tResult = tResult or {}
		OBJECT.MergeSkillData(tResult)
		
		tData.tSkill = tResult
		tData.nTotalValue = nTotalValue
		SingleFStatistic_UpdateData(tData)
	end
end

function FightingStatistic.UpdateHistroy(nStatType, eDataType)
	local nCurrentTime = GetCurrentTime()
	local tDate = TimeToDate(nCurrentTime)
	local szTime = "%s/%s/%s %02d:%02d:%02d"
	szTime = string.format(szTime, tDate.year, tDate.month, tDate.day, tDate.hour, tDate.minute, tDate.second)
	
	local tResult, nTotalValue = QueryPlayerStatData(eDataType, STAT_TYPE2ID[nStatType])
	tResult = tResult or {}
	
	local tHistory = lc_tHistory[nStatType][eDataType]
	local nLen = #tHistory
	if nLen == HISTORY_MAX_COUNT + 1 then
		table.remove(tHistory, HISTORY_MAX_COUNT)
	end
	table.insert(tHistory, 0, {szTime=szTime, nTotalValue=nTotalValue, tData=tResult})
end

function FightingStatistic.GetPlayerInfo(dwPlayerID, hTeam)
	if lc_tPlayerInfo[dwPlayerID] then
		return lc_tPlayerInfo[dwPlayerID]
	end
	
	if hTeam then
		local tMemberInfo = hTeam.GetMemberInfo(dwPlayerID)
		if tMemberInfo then
			lc_tPlayerInfo[dwPlayerID] = 
			{
				szPlayerName = tMemberInfo.szName,
				dwForceID = tMemberInfo.dwForceID,
				nLevel = tMemberInfo.nLevel,
				bClientPlayer = (dwPlayerID == UI_GetClientPlayerID()),
			}
		end
	else
		local player = GetClientPlayer()
		if player and dwPlayerID == player.dwID then
			lc_tPlayerInfo[dwPlayerID] = 
			{
				szPlayerName = player.szName,
				dwForceID = player.dwForceID,
				nLevel = player.nLevel,
				bClientPlayer = true,
			}
		end
	end
	return lc_tPlayerInfo[dwPlayerID]
end

function FightingStatistic.InitListItems(hFrame, nItemCount)
	local hWnd = hFrame:Lookup("Wnd_List")
	local hItemMe = hWnd:Lookup("", "Handle_Me")
	local hList = hWnd:Lookup("", "Handle_info")
	local nCount = hList:GetItemCount()
	local szHandle = ""
	if nCount == nItemCount then
		return
	end

	hList:Clear()
	for i=1, nItemCount, 1 do
		szHandle = "Handle_Colour1"
		if i <=3 then
			szHandle = "Handle_Colour"
		end
		
		local hItem = hList:AppendItemFromIni(INI_FILE, szHandle);
		if i <= 3 then
			hItem:Lookup("Image_Digital"):SetFrame(169 + i - 1)
		else
			hItem:Lookup("Image_School1"):SetName("Image_School")
			hItem:Lookup("Text_Name1"):SetName("Text_Name")
			hItem:Lookup("Text_Information1"):SetName("Text_Information")
		end
	end
end

function FightingStatistic.UpdateItem(hItem, nValue, nDps, nTotal, tPlayerInfo, nFirstValue)
	local nIndex = hItem:GetIndex()
	local dwForceID, szPlayerName = tPlayerInfo.dwForceID, tPlayerInfo.szPlayerName
	local szInfo = nValue.."/"..nDps.."("..FightStat_FormatPercent(nValue, nTotal)..")"
	if nIndex >= 3 then
		hItem:Lookup("Text_Name"):SetText((nIndex + 1).."."..szPlayerName)
	else
		hItem:Lookup("Text_Name"):SetText(szPlayerName)
	end
	local hImgColor = hItem:Lookup("Image_School")
	hItem:Lookup("Text_Information"):SetText(szInfo)
	--hItem:SetSize(285, 28)
	--hItem:Show()

	hImgColor:Hide()
	if lc_tForceID[dwForceID] then
		local tFrame = lc_tForceID[dwForceID]
		if nIndex >= 3 then
			hImgColor:SetFrame(tFrame.nNorFrame)
		else
			hImgColor:SetFrame(tFrame.nLeadFrame)
		end
		
		local fpercent = GetPercent(nValue, nFirstValue)
		hImgColor:SetPercentage(fpercent)
		hImgColor:Show()
		
		if tPlayerInfo.bClientPlayer then
			hImgColor:SetFrame(lc_nSelfFrame)
		end
	end
end

function FightingStatistic.UpdateSelfItem(hItem, nRank, nValue, nDps, nTotal, tPlayerInfo)
	local hIconImg = hItem:Lookup("Image_Icon")
	local hTextName = hItem:Lookup("Text_NameM")
	local hTextData = hItem:Lookup("Text_NameAmoutM")
	if not tPlayerInfo then
		hItem:Hide()
	else
		hItem:Show()
		local szInfo = nValue.."/"..nDps.."("..FightStat_FormatPercent(nValue, nTotal)..")"
		hTextData:SetText(szInfo);
		hTextName:SetText(tPlayerInfo.szPlayerName);
		hIconImg:SetFrame(nRank + 169)
	end
end

function FightingStatistic.UpdateList()
	local hFrame = FRAME_PTR
	local tResult, nTotalValue = QueryPlayerStatData(OBJECT.eDataType, STAT_TYPE2ID[OBJECT.eStatType])
	tResult = tResult or {}
	
	--[[调试用
	if not IsTableEmpty(tResult) then
		nTotalValue= 0
		for i=1, 10, 1 do 
			table.insert(tResult, clone(tResult[1]))
			tResult[i+1].nValue = i * 100
			nTotalValue = nTotalValue + tResult[i+1].nValue * 1
		end
	end
	]]
	OBJECT.UpdateStatList(hFrame, tResult, nTotalValue)
end

function FightingStatistic.UpdateStatList(hFrame, tResult, nTotalValue)
	local hWnd = hFrame:Lookup("Wnd_List")
	local hItemMe = hWnd:Lookup("", "Handle_Me")
	local hList = hWnd:Lookup("", "Handle_info")
	
	OBJECT.UpdateSelfItem(hItemMe)
	
	local ClientPlayer = GetClientPlayer()
	if ClientPlayer and ClientPlayer.IsInParty() then
		hTeam = GetClientTeam()
	end
	
	local nDataCount = #tResult;
	OBJECT.InitListItems(hFrame, nDataCount);
	table.sort(tResult, function(a, b) return a.nValue > b.nValue end)
	
	local nIndex = 0
	local nFirstValue = 0
	local nCount = hList:GetItemCount()
	for k, v in pairs(tResult) do
		local dwPlayerID = v.dwID
		local nValue = v.nValue
		local nDps = v.nValuePer
		local bMember = false
		if nValue > 0 then
			local tPlayerInfo = OBJECT.GetPlayerInfo(dwPlayerID, hTeam);
			
			if tPlayerInfo then
				if nIndex == 0 then
					nFirstValue = nValue
				--[[ 调试用
					tPlayerInfo.bClientPlayer = true
				else
					tPlayerInfo.bClientPlayer = false
					tPlayerInfo.dwForceID = math.min(nIndex - 1, 8)
					]]
				end
				local hItem = hList:Lookup(nIndex)
				hItem.dwPlayerID = dwPlayerID
				OBJECT.UpdateItem(hItem, nValue, nDps, nTotalValue, tPlayerInfo, nFirstValue)
				
				if tPlayerInfo.bClientPlayer then
					hItemMe.dwPlayerID = dwPlayerID
					OBJECT.UpdateSelfItem(hItemMe, nIndex, nValue, nDps, nTotalValue, tPlayerInfo)
				end
				nIndex = nIndex + 1
			end
		end
	end
	for i=nCount-1, nIndex, -1 do
		hList:RemoveItem(i)
	end
	
	FireUIEvent("SCROLL_UPDATE_LIST", hList:GetName(), "FightingStatistic", false)
end

function FightingStatistic.menuCheck(szItemName)
	FRAME_PTR:Lookup("Wnd_Title"):Lookup("", "Text_Title"):SetText(szItemName)
	OBJECT.eStatType = szItemName
	OBJECT.UpdateList()
	OBJECT.UpdateBtnState()
end

function FightingStatistic.IsMenuChecked(szItemName)
	return OBJECT.eStatType == szItemName
end

function FightingStatistic.PopupSTypeMenu()
	local tMenu = 
	{
		{szOption = STAT_TYPE.DAMAGE, bMCheck=true, bChecked = OBJECT.IsMenuChecked(STAT_TYPE.DAMAGE), fnAction=function() OBJECT.menuCheck(STAT_TYPE.DAMAGE) end },
		{szOption = STAT_TYPE.THERAPY, bMCheck=true, bChecked = OBJECT.IsMenuChecked(STAT_TYPE.THERAPY), fnAction=function() OBJECT.menuCheck(STAT_TYPE.THERAPY) end },
		{szOption = STAT_TYPE.BE_DAMAGE, bMCheck=true, bChecked = OBJECT.IsMenuChecked(STAT_TYPE.BE_DAMAGE), fnAction=function() OBJECT.menuCheck(STAT_TYPE.BE_DAMAGE) end },
	}
	PopupMenu(tMenu)
end

function FightingStatistic.DataTypeMenuCheck(eType)
	OBJECT.eDataType = eType
	OBJECT.bOpenHistory = false
	OBJECT.UpdateList()
	OBJECT.UpdateBtnState()
end

function FightingStatistic.PopupDataTypeMenu()
	local tMenu = 
	{
		{szOption = g_tStrings.STR_ONCE_STATISTIC, bMCheck=true, bChecked = (OBJECT.eDataType == DATA_TYPE.ONCE), fnAction=function() OBJECT.DataTypeMenuCheck(DATA_TYPE.ONCE) end },
		{szOption = g_tStrings.STR_TOTAL_STATISTIC, bMCheck=true, bChecked = (OBJECT.eDataType == DATA_TYPE.TOTAL), fnAction=function() OBJECT.DataTypeMenuCheck(DATA_TYPE.TOTAL) end },
	}
	PopupMenu(tMenu)
end


function FightingStatistic.OutputStatistic(szMsgType)
	local tChannel = 
	{
		["MSG_NORMAL"] = PLAYER_TALK_CHANNEL.NEARBY,
		["MSG_PARTY"] = PLAYER_TALK_CHANNEL.TEAM,
		["MSG_GUILD"] = PLAYER_TALK_CHANNEL.TONG,
		["MSG_TEAM"] = PLAYER_TALK_CHANNEL.RAID,
	}
	local nChannel = tChannel[szMsgType]
	if nChannel then
		local player = GetClientPlayer()
		local tText = FightingStatistic.GetStatisticMsg()
		for k, v in ipairs(tText) do
			player.Talk(nChannel, "", v)
		end
	end
end

function FightingStatistic.PopupOutputMenu()
	local tMenu = 
	{
		{szOption = g_tStrings.tChannelName["MSG_NORMAL"],  fnAction=function() OBJECT.OutputStatistic("MSG_NORMAL") end },
		{szOption = g_tStrings.tChannelName["MSG_PARTY"],  fnAction=function() OBJECT.OutputStatistic("MSG_PARTY") end },
		{szOption = g_tStrings.tChannelName["MSG_GUILD"],  fnAction=function() OBJECT.OutputStatistic("MSG_GUILD") end },
		{szOption = g_tStrings.tChannelName["MSG_TEAM"],  fnAction=function() OBJECT.OutputStatistic("MSG_TEAM") end },
	}
	PopupMenu(tMenu)
end

function FightingStatistic.HistoryCheck(nIndex)
	if nIndex == 0 then
		OBJECT.bOpenHistory = false
		OBJECT.UpdateList()
	else
		OBJECT.bOpenHistory = true
		local tResult = lc_tHistory[OBJECT.eStatType][OBJECT.eDataType]
		OBJECT.UpdateStatList(FRAME_PTR, tResult[nIndex].tData, tResult[nIndex].nTotalValue)
	end
end

function FightingStatistic.PopupHistoryMenu()
	local tMenu = {}
	local tData = lc_tHistory[OBJECT.eStatType][OBJECT.eDataType]
	local nCount = #tData
	
	if nCount == 0 then
		table.insert(tMenu, {szOption=g_tStrings.STR_FIGHT_NORECORD})
	else
		if OBJECT.bOpenHistory then
			table.insert(tMenu, {szOption=g_tStrings.STR_FIGHT_RET_STAT, fnAction=function() OBJECT.HistoryCheck(0) end})
		end
		
		for i=1, nCount, 1 do
			table.insert(tMenu, 
				{
					szOption = FormatString(g_tStrings.STR_FIGHT_LOOK_RECORD, OBJECT.eStatType, tData[i].szTime),
					fnAction = function() OBJECT.HistoryCheck(i) end
				}
			)
		end
	end
	PopupMenu(tMenu)
end

function FightingStatistic.UpdateBtnState()
	if OBJECT.eDataType == DATA_TYPE.ONCE then
		FRAME_PTR:Lookup("Wnd_Title"):Lookup("", "Text_Title"):SetText(FightingStatistic.eStatType.."("..g_tStrings.STR_STAT_SINGLE..")")
	else
		FRAME_PTR:Lookup("Wnd_Title"):Lookup("", "Text_Title"):SetText(FightingStatistic.eStatType)
	end
	
	if OBJECT.eDataType == DATA_TYPE.ONCE then
		local hCheck = FRAME_PTR:Lookup("Wnd_Title"):Lookup("CheckBox_SStart")
		hCheck:Show()
		
		local oldState = FRAME_PTR.bIniting
		FRAME_PTR.bIniting = true
		
		hCheck:Check(OBJECT.bSingleStart)
		ActivePlayerSingleStatData(OBJECT.bSingleStart)
		
		FRAME_PTR.bIniting = oldState
	else
		FRAME_PTR:Lookup("Wnd_Title"):Lookup("CheckBox_SStart"):Hide()
	end
	FRAME_PTR:Lookup("Wnd_Title"):Lookup("Btn_Examine"):Enable(OBJECT.eDataType == DATA_TYPE.ONCE)
end

function FightingStatistic.GetStatisticMsg()
	local hWnd = FRAME_PTR:Lookup("Wnd_List")
	local hItemMe = hWnd:Lookup("", "Handle_Me")
	local hList = hWnd:Lookup("", "Handle_info")
	local nCount = hList:GetItemCount() - 1
	local tText = {}
	local szData = "***********"..OBJECT.eStatType.."("..DATA_TYPE_STRING[OBJECT.eDataType]..")***********"
	table.insert(tText, {{type="text", text=szData}})
	for i = 0, nCount, 1 do
		local hItem = hList:Lookup(i)
		local szText1 = hItem:Lookup("Text_Name"):GetText()
		local szText2 = hItem:Lookup("Text_Information"):GetText()
	
		local tData = {}
		if (i < 1) then
			table.insert(tData, {type="text", text=g_tStrings.STR_FIGNHT_FIRST_ICON})
		elseif (i < 2) then
			table.insert(tData, {type="text", text=g_tStrings.STR_FIGNHT_SECD_ICON})
		elseif (i < 3) then
			table.insert(tData, {type="text", text=g_tStrings.STR_FIGNHT_THIRD_ICON})
		end
		
		szData = string.format("%s：%s", szText1, szText2)
		table.insert(tData, {type="text", text=szData})
		
		table.insert(tText, tData)
	end
	table.insert(tText, {{type="text", text="********************************************"}})
	return tText
end

function FightingStatistic.MergeSkillData(tSkill)
	local tSkillNameMap = {}
	local tDelete = {}
	for k, v in pairs(tSkill) do
		local nCount = v.dwHit - v.dwCriticalStrike - v.dwInsight - v.dwDodge
		if nCount == 0 then
			v.bDisable = true
		end
		
		if v.dwCriticalStrike == 0 then
			v.bCSDisable = true
		end
			
		local szSkillName = FStatistic_GetDamageSrcName(v.dwID, v.nSrcType)
		local t = tSkillNameMap[szSkillName]
		if t then
			t.nDamage = t.nDamage + v.nDamage
			t.dwCount = t.dwCount + v.dwCount
			t.dwHit = t.dwHit + v.dwHit
			t.dwInsight = t.dwInsight + v.dwInsight
			t.dwCriticalStrike = t.dwCriticalStrike + v.dwCriticalStrike
			t.dwShield = t.dwShield + v.dwShield
			
			
			t.nTotalDamage = t.nTotalDamage + v.nTotalDamage;
			t.nTotalCSDamage = t.nTotalCSDamage + v.nTotalCSDamage;
			
			if t.bDisable and not v.bDisable then
				t.nMinDamage = v.nMinDamage
				t.nMaxDamage = v.nMaxDamage
			
			elseif not t.bDisable and not v.bDisable then
				t.nMinDamage = math.min(t.nMinDamage, v.nMinDamage)
				t.nMaxDamage = math.max(t.nMaxDamage, v.nMaxDamage)
			end
			
			if t.bCSDisable and not v.bCSDisable then
				t.nMinCSDamage = v.nMinCSDamage
				t.nMaxCSDamage = v.nMaxCSDamage
			
			elseif not t.bCSDisable and not v.bCSDisable then
				t.nMinCSDamage = math.min(t.nMinCSDamage, v.nMinCSDamage)
				t.nMaxCSDamage = math.max(t.nMaxCSDamage, v.nMaxCSDamage)
			end
			
			tDelete[k] = true
		else
			tSkillNameMap[szSkillName] = v
		end
	end
	
	for i=#tSkill, 1, -1 do
		if tDelete[i] then
			table.remove(tSkill, i)
		end
	end
end

function FStatistic_GetDamageSrcName(dwID, nSrcType)
	local szSkillName = ""
	if nSrcType == 1 then
		szSkillName = Table_GetSkillName(dwID, 1)
	elseif nSrcType == 2 then
		szSkillName = Table_GetBuffName(dwID, 1)
	end
	return szSkillName
end

function FightingStatistic.GetDamageTip(dwPlayerID)

	--local tSkill = tTestSkill
	local tSkill, nTotalValue = QuerySkillStatData(dwPlayerID, OBJECT.eDataType)
	local szTip = ""
	
	tSkill = tSkill or {}
	OBJECT.MergeSkillData(tSkill)
	local function cmp(a, b)
		if a.nDamage ~= b.nDamage then
			return a.nDamage > b.nDamage
		end
		return a.dwCount < b.dwCount
	end
	table.sort(tSkill, cmp)
	
	local szColon = g_tStrings.STR_COLON
	for k, v in pairs(tSkill) do
		local szSkillName = FStatistic_GetDamageSrcName(v.dwID, v.nSrcType)
		if szSkillName and szSkillName ~= "" then
			if v.dwReact ~=0 then
				szSkillName = g_tStrings.STR_DAMAGE_REACT
			end
			szTip = szTip..GetFormatText(szSkillName.."\n", nil, 255, 202, 126);
			
			if v.nType == 0 and v.nDamage ~= 0 then
				szTip = szTip..GetFormatText(g_tStrings.STR_TOTAL_DAMAGE..szColon..v.nDamage.."\n", nil);
			elseif v.nType == 1 and v.nDamage ~= 0 then
				szTip = szTip..GetFormatText(g_tStrings.STR_TOTAL_THERAPY..szColon..v.nDamage.."\n", nil);
			end
			
			szTip = szTip..GetFormatText(g_tStrings.STR_HIT_NAME..szColon, nil, 255, 202, 126)..GetFormatText(v.dwHit.." ");
			szTip = szTip..GetFormatText(g_tStrings.STR_INSIGHT_NAME..szColon, nil, 255, 202, 126)..GetFormatText(v.dwInsight.." ");
			szTip = szTip..GetFormatText(g_tStrings.STR_CS_NAME..szColon, nil, 255, 202, 126)..GetFormatText(v.dwCriticalStrike.." ");
			szTip = szTip..GetFormatText(g_tStrings.STR_MISS_NAME..szColon, nil, 255, 202, 126)..GetFormatText(v.dwCount - v.dwHit - v.dwShield.."\n");
		end
	end
	return szTip
end

function FightingStatistic.ExpandFrame(bExpand)
	if bExpand ~= nil then
		OBJECT.bExpand = not bExpand
	end
	
	if OBJECT.bExpand then
		FRAME_PTR:SetSize(309, 32)	
		FRAME_PTR:Lookup("Wnd_List"):Hide()
		FRAME_PTR:Lookup("Wnd_Title"):Lookup("CheckBox_Minimize"):Check(true)
		ActivePlayerStatData(false)
	else
		FRAME_PTR:SetSize(309, 295)
		FRAME_PTR:Lookup("Wnd_List"):Show()
		FRAME_PTR:Lookup("Wnd_Title"):Lookup("CheckBox_Minimize"):Check(false)
		ActivePlayerStatData(true)
	end
	
	OBJECT.bExpand = not OBJECT.bExpand
end

function FightingStatistic.OpenSingleData(dwPlayerID)
	--local tSkill, nTotalValue = tTestSkill, 300--
	local tSkill, nTotalValue = QuerySkillStatData(dwPlayerID, OBJECT.eDataType)
	tSkill = tSkill or {}
	OBJECT.MergeSkillData(tSkill)
	local tData = {
		nTotalValue = nTotalValue,
		dwPlayerID = dwPlayerID,
		tPlayerInfo = FightingStatistic.GetPlayerInfo(dwPlayerID),
		eDataType = OBJECT.eDataType,
		tSkill = tSkill,
	}
	OpenSingleFStatistic(tData)
end

--=====msg ==========================

function FightingStatistic.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_Setting" then
		OBJECT.PopupSTypeMenu()
		return true
	elseif szName == "Btn_Empty" then--清空
		ClearPlayerStatData()
		OBJECT.UpdateList()
		
	elseif szName == "Btn_Issuance" then
		OBJECT.PopupOutputMenu()
		return true
	elseif szName == "Btn_Examine" then
		OBJECT.PopupHistoryMenu()
	elseif szName == "Btn_Switch" then
		OBJECT.PopupDataTypeMenu()
	end
end

function FightingStatistic.OnCheckBoxCheck()
	if FRAME_PTR.bIniting then
		return
	end
	
	local szName = this:GetName()
	if szName == "CheckBox_Minimize" then
		FightingStatistic.ExpandFrame()
	elseif szName == "CheckBox_SStart" then
		ActivePlayerSingleStatData(true)
		OBJECT.bSingleStart = true
	end
end

function FightingStatistic.OnCheckBoxUncheck()
	if FRAME_PTR.bIniting then
		return
	end
	
	local szName = this:GetName()
	if szName == "CheckBox_Minimize" then
		FightingStatistic.ExpandFrame()
	elseif szName == "CheckBox_SStart" then
		ActivePlayerSingleStatData(false)
		OBJECT.bSingleStart = false
	end
end

function FightingStatistic.OnItemLButtonDown()
	local szName = this:GetName()
	if szName == "Handle_Colour1" or szName == "Handle_Colour" or szName == "Handle_Me" then
		if OBJECT.bOpenHistory then
			return
		end
		
		local eType = OBJECT.eStatType		
		if eType == STAT_TYPE.DAMAGE or eType == STAT_TYPE.THERAPY then
			OBJECT.OpenSingleData(this.dwPlayerID)
			return
		end
	end
end

function FightingStatistic.OnItemMouseEnter()
	local szName = this:GetName()
	if szName == "Handle_Colour1" or szName == "Handle_Colour" or szName == "Handle_Me" then
		if OBJECT.bOpenHistory then
			return
		end
		
		local eType = OBJECT.eStatType
		if eType == STAT_TYPE.DAMAGE or eType == STAT_TYPE.THERAPY then
			local x, y = this:GetAbsPos()
			local w, h = this:GetSize()
			local szTip = OBJECT.GetDamageTip(this.dwPlayerID)
			if szTip then
				OutputTip(szTip, 400, {x, y, w, h})
			end
		end
	end
end

function FightingStatistic.OnItemMouseLeave()
	local szName = this:GetName()
	if szName == "Handle_Colour1" or szName == "Handle_Colour" or szName == "Handle_Me" then
		HideTip()
	end
end

function FightingStatistic.OnMouseEnter()
	local szName = this:GetName()
	if szName == "CheckBox_Minimize" then
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
		local szTip = ""
		if FightingStatistic.bExpand then
			szTip = GetFormatText(g_tStrings.STR_STATISTIC_NOT_EXPAND)
		else
			szTip = GetFormatText(g_tStrings.STR_STATISTIC_EXPAND)
		end
		
		OutputTip(szTip, 400, {x, y, w, h})
	elseif szName == "CheckBox_SStart" then
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
		local szTip = ""
		if FightingStatistic.bSingleStart then
			szTip = GetFormatText(g_tStrings.STR_STAT_SINGLE_END)
		else
			szTip = GetFormatText(g_tStrings.STR_STAT_SINGLE_START)
		end
		OutputTip(szTip, 400, {x, y, w, h})
	end
end

function FightingStatistic.OnMouseLeave()
	local szName = this:GetName()
	if szName == "CheckBox_Minimize" or szName == "CheckBox_SStart" then
		HideTip()
	end
end

--=====msg end==========================
function IsFightingStatisticOpened()
	local frame = Station.Lookup("Normal/FightingStatistic")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end

function OpenFightingStatistic()
    if IsFightingStatisticOpened() then
        return
    end
    
	Wnd.OpenWindow("FightingStatistic")
    if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
end

function CloseFightingStatistic()
	ActivePlayerStatData(false);
    if IsFightingStatisticOpened() then
		Wnd.CloseWindow("FightingStatistic")
	end
	CloseSingleFStatistic();
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end
end

local function UpdateFStatisticOpenState()
	if FightingStatistic.eOpenType == "close" then 
		CloseFightingStatistic(true)
	elseif FightingStatistic.eOpenType == "copy" then
		local player = GetClientPlayer()
		if player then
			local _, nMapType = GetMapParams(player.GetMapID())
			if nMapType == 1 then
				OpenFightingStatistic(true)
			else
				CloseFightingStatistic(true)
			end
		else
			CloseFightingStatistic(true)
		end
	elseif FightingStatistic.eOpenType == "party" then
		local player = GetClientPlayer()
		if player and player.IsInParty() then
			OpenFightingStatistic(true)
		else
			CloseFightingStatistic(true)
		end
	else
		OpenFightingStatistic(true)
	end
end

function GetFStatisticOpenType()
	return FightingStatistic.eOpenType
end

function SetFStatisticOpenType(szType)
	if FightingStatistic.eOpenType ~= szType then
		FightingStatistic.eOpenType = szType
		UpdateFStatisticOpenState()
	end
end

function FightingStatistic.ProcessVersion0()
	FightingStatistic.eOpenType = "close"
end

function FightingStatistic.ProcessVersion1()
	FightingStatistic.eDataType = DATA_TYPE.TOTAL
end

function FightingStatistic.ProcessVersion2()
	FightingStatistic.eOpenType = "party"
end

RegisterEvent("CUSTOM_DATA_LOADED", 
	function() 
		if arg0 ~= "Role" then 
			return 
		end 
		
		if CURRENT_VERSION ~= FightingStatistic.nVersion then
			if FightingStatistic.nVersion == 0 then
				FightingStatistic.ProcessVersion0()
			elseif FightingStatistic.nVersion == 1 then
				FightingStatistic.ProcessVersion1()
			end
			
			if CURRENT_VERSION == 3 then
				FightingStatistic.ProcessVersion2()
			end
		end
		FightingStatistic.nVersion = CURRENT_VERSION
		
		UpdateFStatisticOpenState()
		if IsFightingStatisticOpened() then
			 FightingStatistic.UpdateState()
		end
	end
)

local function OnPartyMsgNotify()
	if arg0 == PARTY_NOTIFY_CODE.PNC_PARTY_CREATED or arg0 == PARTY_NOTIFY_CODE.PNC_PARTY_JOINED then		
		if FightingStatistic.eOpenType == "party" then
			OpenFightingStatistic(true)
		end
	end
end

local function OnTeamDelMember()
	if GetClientPlayer().dwID == arg1 then
		if FightingStatistic.eOpenType == "party" then
			CloseFightingStatistic(true)
		end
	end
end

RegisterEvent("PARTY_DISBAND", UpdateFStatisticOpenState)
RegisterEvent("PARTY_DELETE_MEMBER", OnTeamDelMember)
RegisterEvent("PARTY_MESSAGE_NOTIFY", OnPartyMsgNotify)
RegisterEvent("SYNC_ROLE_DATA_END", UpdateFStatisticOpenState)
RegisterEvent("PLAYER_ENTER_SCENE",  function () if GetClientPlayer().dwID == arg0 then UpdateFStatisticOpenState() end end)

do
    RegisterScrollEvent("FightingStatistic")
    
    UnRegisterScrollAllControl("FightingStatistic")
        
    local szFramePath = "Normal/FightingStatistic"
    local szWndPath = "Wnd_List"
    RegisterScrollControl(
        szFramePath, 
        szWndPath.."/Btn_Up", szWndPath.."/Btn_Down", 
        szWndPath.."/Scroll_FightingStatistic", 
        {szWndPath, "Handle_info"})
end