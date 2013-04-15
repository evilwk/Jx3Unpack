
local tNotifyList = {}
local bBlacklist = false
local nBlacklistLastTime = 0

local NORMAL_FONT = 162
local STRESS_FONT = 163

function Arena_MessageBoxCanEnter(nArenaType)
    if not tNotifyList[nArenaType] or tNotifyList[nArenaType].bHide then
        return
    end
	local tData = tNotifyList[nArenaType]
	
	nCount = Arena_GetEnterLeftSeconds(tData.nArenaEnterCount, tData.dwStartTime)
    CloseMessageBox("Arena_Leave_" .. nArenaType)
    local szTime = FormatArenaTime(MAX_BATTLE_FIELD_OVERTIME)
    local tMsg = 
    {
        bRichText = true,
        szMessage = FormatString(
            g_tStrings.STR_BATTLEFIELD_MESSAGE_ENTER, 
            g_tStrings.STR_ARENA_TITLE, 
            szTime,
            STRESS_FONT
        ),
        szName = "Arena_Enter_" .. nArenaType,
        {szOption = g_tStrings.STR_HOTKEY_ENTER, nCountDownTime = nCount, dwStartTime = tData.dwStartTime, fnAction = function() 
			DoAcceptJoinArena(nArenaType, tData.nCenterID, tData.dwMapID, tData.nCopyIndex, tData.nGroupID, tData.dwJoinValue, tData.dwCorpsID) end, },
        {szOption = g_tStrings.STR_HOTKEY_HIDE, fnAction = function() tNotifyList[nArenaType].bHide = true; OutputMessage("MSG_SYS", g_tStrings.STR_ARENA_MESSAGE_ENTER_HIDE) end},
        {szOption = g_tStrings.STR_HOTKEY_FANGQI, fnAction = function() Arena_MessageBoxLeave(nArenaType) end, },
		
		fnAutoClose=function()
			local nLeft = Arena_GetEnterLeftSeconds(tData.nArenaEnterCount, tData.dwStartTime)
			if nLeft == 0 then
				DoLeaveArenaQueue(nArenaType)
				return true
			end
			return false;
		end
    }
    MessageBox(tMsg)
end

function Arena_MessageBoxLeave(nArenaType)
    CloseMessageBox("Arena_Enter_" .. nArenaType)
    local tMsg = 
    {
        szMessage = FormatString(g_tStrings.STR_BATTLEFIELD_MESSAGE_SURE_LEAVE, g_tStrings.STR_ARENA_TITLE), 
        szName = "Arena_Leave_" .. nArenaType,
        {szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = function() DoLeaveArenaQueue(nArenaType) end, },
        {szOption = g_tStrings.STR_HOTKEY_CANCEL, fnAction = function() Arena_MessageBoxCanEnter(nArenaType) end },
    }
    MessageBox(tMsg)
end

function OnArenaNotify(nType, nArenaType, dwCorpsID, nAvgQueueTime, nPassTime, dwMapID, nCopyIndex, nCenterID, nGroupID, dwJoinValue)
	-- update data
	if nType == ARENA_NOTIFY_TYPE.ARENA_QUEUE_INFO 
	or nType == ARENA_NOTIFY_TYPE.LOG_IN_ARENA_MAP then
        local bFirst = false
		if not tNotifyList[nArenaType] then
			tNotifyList[nArenaType] = {}
			bFirst = true
			
			if nType == ARENA_NOTIFY_TYPE.ARENA_QUEUE_INFO then
				local szTip = FormatString(g_tStrings.STR_ARENA_QUEUE_WAIT, g_tStrings.tCorpsType[nArenaType])
				OutputMessage("MSG_ANNOUNCE_YELLOW", szTip)
				OutputMessage("MSG_SYS", szTip);
			end
		end
        local nOldType = tNotifyList[nArenaType].nNotifyType
		tNotifyList[nArenaType].nArenaType = nArenaType
		tNotifyList[nArenaType].nNotifyType = nType
		tNotifyList[nArenaType].nAvgQueueTime = nAvgQueueTime
		tNotifyList[nArenaType].nPassTime = nPassTime
		tNotifyList[nArenaType].dwCorpsID = dwCorpsID
			
		if nType == ARENA_NOTIFY_TYPE.LOG_IN_ARENA_MAP then
			tNotifyList[nArenaType].nCopyIndex = nCopyIndex
			tNotifyList[nArenaType].nCenterID = nCenterID
			tNotifyList[nArenaType].dwMapID = dwMapID
				
			tNotifyList[nArenaType].nGroupID = nGroupID
			tNotifyList[nArenaType].dwJoinValue = dwJoinValue
			--tNotifyList[nArenaType].nArenaEnterCount = GetCurrentTime() + MAX_BATTLE_FIELD_OVERTIME;
		end

        if nOldType == nType then
            FireEvent("ARENA_UPDATE_TIME")
        end
        
        if bFirst then
            FireEvent("ARENA_STATE_UPDATE")
        end
	elseif nType == ARENA_NOTIFY_TYPE.LOG_OUT_ARENA_MAP then
	elseif nType == ARENA_NOTIFY_TYPE.IN_BLACK_LIST then
	elseif nType == ARENA_NOTIFY_TYPE.LEAVE_BLACK_LIST then
	end
	
	if nType == ARENA_NOTIFY_TYPE.LOG_IN_ARENA_MAP then
		if not tNotifyList[nArenaType].bRemind then
			tNotifyList[nArenaType].dwStartTime = GetTickCount()
			tNotifyList[nArenaType].nArenaEnterCount = MAX_BATTLE_FIELD_OVERTIME
			Arena_MessageBoxCanEnter(nArenaType)
			tNotifyList[nArenaType].bRemind = true
		end
        FireEvent("ARENA_STATE_UPDATE")
	end
end

function GetCurrentArena()
	return tNotifyList
end


function GetArenaQueueDesc(nArenaType, nFont1, nFont2, nVersion)
    local tData = tNotifyList[nArenaType] 
    if not tData then
        return
    end
    nFont1 = nFont1 or NORMAL_FONT
    nFont2 = nFont2 or STRESS_FONT
    nVersion = nVersion or 0

    if tData.nNotifyType == ARENA_NOTIFY_TYPE.ARENA_QUEUE_INFO then
        local szCorpsType = g_tStrings.tCorpsType[nArenaType]
    	szCorpsType = GetFormatText(szCorpsType, nFont2)
        
        local szTip1 = FormatString(
            g_tStrings.STR_ARENA_QUEUE_WAIT, 
            "\"font=" .. nFont1 .. " </text>" .. szCorpsType .. "<text>text=\""
        )
        szTip1 = "<text>text=\"" .. szTip1 .. "\" font=" .. nFont1 .. "</text>"
	
        local nAvgTime = tData.nAvgQueueTime
        local szTip2 = GetFormatText(g_tStrings.STR_BATTLEFIELD_QUEUE_TIME_UNKNOW .. "\n", nFont1) 
        if nAvgTime > 0 then
            szTip2 = GetFormatText(g_tStrings.STR_BATTLEFIELD_QUEUE_AVGTIME, nFont1)
            szTip2 = szTip2 .. GetFormatText(FormatArenaTime(nAvgTime) .. "\n", nFont2)
        end
        
        local szTip3 = GetFormatText(g_tStrings.STR_BATTLEFIELD_QUEUE_PASSTIME, nFont1)
        local nPassTime = tData.nPassTime
        if nPassTime then
            szTip3 = szTip3 .. GetFormatText(FormatArenaTime(nPassTime) .. "\n", nFont2)
        end
        return szTip1, szTip2, szTip3
    end
    
    if tData.nNotifyType == ARENA_NOTIFY_TYPE.LOG_IN_ARENA_MAP then
        if nVersion == 1 then
			local szCorpsType = g_tStrings.tCorpsType[nArenaType]
            local szTip1, szTip2 = FormaArenaJoinTipVer1(
                szCorpsType,
                MAX_BATTLE_FIELD_OVERTIME - tData.nPassTime,
                nFont1,
                nFont2
            )
            return szTip1, szTip2
        else
            local szJoinTip = FormatArenaJoinTip(
                szCorpsType,
                MAX_BATTLE_FIELD_OVERTIME - tData.nPassTime,
                nFont1,
                nFont2
            )
            return szJoinTip
        end
        
    end
end

function GetArenaStateTip()
	local tTip = {}

	if IsInArena() then
		table.insert(tTip, GetFormatText(g_tStrings.STR_ARENA_TITLE, NORMAL_FONT))
	end
		
	for nArenaType, tData in pairs(tNotifyList) do
		if tData.nNotifyType == ARENA_NOTIFY_TYPE.ARENA_QUEUE_INFO then
			local szQueueTip = FormatArenaQueueTip(
				g_tStrings.tCorpsType[nArenaType],
				tData.nPassTime, 
				tData.nAvgQueueTime
			)
			table.insert(tTip, szQueueTip)
		elseif tData.nNotifyType == ARENA_NOTIFY_TYPE.LOG_IN_ARENA_MAP then
			local nLeft = Arena_GetEnterLeftSeconds(tData.nArenaEnterCount, tData.dwStartTime)
			local szJoinTip = FormatArenaJoinTip(
				g_tStrings.tCorpsType[nArenaType],
				nLeft
			)
			table.insert(tTip, szJoinTip)
		end
	end
	
	local szTip = nil
	for _, szSubTip in ipairs(tTip) do
		if not szTip then
			szTip = ""
		else
			szTip = szTip .. GetFormatText("\n\n", NORMAL_FONT)
		end
		szTip = szTip .. szSubTip
	end

	return szTip
end

function GetArenaMenu()
	local tMenu = nil
	
	if IsInArena() then
		tMenu = { { szOption = g_tStrings.STR_BATTLEFIELD_MENU_LEAVE, fnAction = function() LogOutArena() end, } }
	end
	
	for nArenaType, tData in pairs(tNotifyList) do
		if tData.nNotifyType == ARENA_NOTIFY_TYPE.ARENA_QUEUE_INFO or tData.nNotifyType == ARENA_NOTIFY_TYPE.LOG_IN_ARENA_MAP then
			local szCorpsType = g_tStrings.tCorpsType[nArenaType]
			if tMenu then
				table.insert(tMenu, {bDevide = true})
			else
				tMenu = {}
			end
			
			table.insert(tMenu, { szOption = szCorpsType, bDisable = true, nFont = STRESS_FONT, })
			if tData.nNotifyType == ARENA_NOTIFY_TYPE.LOG_IN_ARENA_MAP then
				table.insert(tMenu, { szOption = g_tStrings.STR_BATTLEFIELD_MENU_ENTER, fnAction = function() 
				DoAcceptJoinArena(nArenaType, tNotifyList[nArenaType].nCenterID, tNotifyList[nArenaType].dwMapID, tNotifyList[nArenaType].nCopyIndex, tNotifyList[nArenaType].nGroupID, tNotifyList[nArenaType].dwJoinValue, tNotifyList[nArenaType].dwCorpsID) end, })
			end

			if tData.nNotifyType == ARENA_NOTIFY_TYPE.ARENA_QUEUE_INFO then
				table.insert(tMenu, { szOption = g_tStrings.STR_BATTLEFIELD_MENU_LEAVE, fnAction = function() DoLeaveArenaQueue(nArenaType) end, })
			end
            
			if tData.nNotifyType == ARENA_NOTIFY_TYPE.LOG_IN_ARENA_MAP then
				table.insert(tMenu, { szOption = g_tStrings.STR_HOTKEY_FANGQI, fnAction = function() Arena_MessageBoxLeave(nArenaType) end, })
			end
		end
	end
	return tMenu
end


function IsInArenaQueue(nArenaType)
    if tNotifyList[nArenaType] and tNotifyList[nArenaType].nNotifyType == ARENA_NOTIFY_TYPE.ARENA_QUEUE_INFO then
        return true;
    end
    return false;
end

function IsCanEnterArena()
    if not tNotifyList then
        return false
    end
    
    for _, t in pairs(tNotifyList) do 
        if t and t.nNotifyType == ARENA_NOTIFY_TYPE.LOG_IN_ARENA_MAP then
            return true;
        end
    end
    return false;
end

function HasArenaInfo()
	local hPlayer = GetClientPlayer()
	if not hPlayer then
		return
	end
	
	if bBlacklist then
		return "disable"
	end
	
	for _, _ in pairs(tNotifyList) do
		return "normal"
	end	
	
	if IsInArena() then
		return "normal"
	end
end

function IsInArena()
	local hPlayer = GetClientPlayer()
	if hPlayer then
		local hScene = hPlayer.GetScene()
		return hScene.bIsArenaMap
		--return Table_IsBattleFieldMap(hScene.dwMapID)
	end
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function DoAcceptJoinArena(nArenaType, nCenterID, dwMapID, nCopyIndex, nGroupID, dwJoinValue, dwCorpsID)
	CloseMessageBox("Arena_Enter_" .. nArenaType)
	tNotifyList[nArenaType] = nil
	FireEvent("ARENA_STATE_UPDATE")
	LogInArena(nArenaType, nCenterID, dwMapID, nCopyIndex, nGroupID, dwJoinValue, dwCorpsID)
end

function DoLeaveArenaQueue(nArenaType)
	CloseMessageBox("Arena_Enter_" .. nArenaType)
	tNotifyList[nArenaType] = nil
	FireEvent("ARENA_STATE_UPDATE")
	LeaveArenaQueue()
end

function FormatArenaTime(nTime)
	local szTime
	if nTime > 60 then
		szTime = math.floor(nTime / 60) .. g_tStrings.STR_BUFF_H_TIME_M
	else
		szTime = nTime .. g_tStrings.STR_BUFF_H_TIME_S
	end
	return szTime
end

function FormatArenaQueueTip(szBattleField, nPassTime, nAvgTime)
	local szBattleField = GetFormatText(szBattleField, STRESS_FONT)
	local szTip = FormatString(
		g_tStrings.STR_BATTLEFIELD_QUEUE_WAIT, 
		"\"font=" .. NORMAL_FONT .. " </text>" .. szBattleField .. "<text>text=\""
	)
	szTip = szTip .. "\n"
	szTip = "<text>text=\"" .. szTip .. "\" font=" .. NORMAL_FONT .. "</text>"
	
	if nAvgTime > 0 then
		szTip = szTip .. GetFormatText(g_tStrings.STR_BATTLEFIELD_QUEUE_AVGTIME, NORMAL_FONT)
		szTip = szTip .. GetFormatText(FormatArenaTime(nAvgTime) .. "\n", STRESS_FONT)
	else
		szTip = szTip .. GetFormatText(g_tStrings.STR_BATTLEFIELD_QUEUE_TIME_UNKNOW .. "\n", NORMAL_FONT)
	end
	
	szTip = szTip .. GetFormatText(g_tStrings.STR_BATTLEFIELD_QUEUE_PASSTIME, NORMAL_FONT)
	szTip = szTip .. GetFormatText(FormatArenaTime(nPassTime) .. "\n", STRESS_FONT)
	szTip = szTip .. g_tStrings.STR_ARENA_QUEUE_TIP
	return szTip
end

function FormatArenaJoinTip(szCorpsType, nLastTime, nFont1, nFont2)
    nFont1 = nFont1 or NORMAL_FONT
    nFont2 = nFont2 or STRESS_FONT
    
	local szCorpsType = GetFormatText(szCorpsType, nFont2)
	local szLastTime = GetFormatText(FormatArenaTime(nLastTime), nFont2)
	local szTip = FormatString(
		g_tStrings.STR_BATTLEFIELD_QUEUE_ENTER, 
		"\"font=" .. nFont1 .. " </text>" .. szCorpsType .. "<text>text=\"", 
		"\"font=" .. nFont1 .. " </text>" .. szLastTime .. "<text>text=\""
	)
	return "<text>text=\"" .. szTip .. "\" font=" .. nFont1 .. "</text>"
end

function FormaArenaJoinTipVer1(szCorpsType, nLastTime, nFont1, nFont2)
    nFont1 = nFont1 or NORMAL_FONT
    nFont2 = nFont2 or STRESS_FONT
    
	local szCorpsType = GetFormatText(szCorpsType, nFont2)
	local szLastTime = GetFormatText(FormatArenaTime(nLastTime), nFont2)
    local szTip1 = FormatString(g_tStrings.BATTLE_FIELD_CAN_ENTER, szCorpsType, nFont1)
        
    local szTip2 = FormatString(g_tStrings.BATTLE_FIELD_CAN_ENTER_TIME, szLastTime, nFont1)
    
	return szTip1, szTip2 
end

function FormatArenaBlacklistTip(nLastTime)
	local szLastTime = GetFormatText(FormatArenaTime(nLastTime), STRESS_FONT)
	local szTip = FormatString(
		g_tStrings.STR_BATTLEFIELD_BLACK_LIST, 
		"\"font=" .. NORMAL_FONT .. " </text>" .. szLastTime .. "<text>text=\""
	)
	return "<text>text=\"" .. szTip .. "\" font=" .. NORMAL_FONT .. "</text>"
end

local function OnLeaveArenaQueue()
	for k, v in pairs(tNotifyList) do
		tNotifyList[k] = nil
	end
	FireEvent("ARENA_STATE_UPDATE")
end

function Arena_GetEnterEndTime()
	local tTime
	for i=ARENA_TYPE.ARENA_BEGIN, ARENA_TYPE.ARENA_END - 1, 1 do
	    if tNotifyList[i] and tNotifyList[i].nNotifyType == ARENA_NOTIFY_TYPE.LOG_IN_ARENA_MAP then
			if not tTime then
				tTime = {}
			end
			tTime[i] = {dwStartTime=tNotifyList[i].dwStartTime, nArenaEnterCount=tNotifyList[i].nArenaEnterCount}
		end
	end
	return tTime
end

function Arena_GetEnterLeftSeconds(nCountDownTime, dwStartTime)
	local nSeconds = nCountDownTime - (GetTickCount() - dwStartTime) / 1000
	nSeconds = math.floor(nSeconds)
	if nSeconds < 0 then
		nSeconds = 0
	end
	return nSeconds
end
			
RegisterEvent("LEAVE_ARENA_QUEUE", OnLeaveArenaQueue)
RegisterEvent("ARENA_NOTIFY", function() OnArenaNotify(arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9) end)