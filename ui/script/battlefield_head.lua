
local tNotifyList = {}
local bBlacklist = false
local nBlacklistLastTime = 0

local NORMAL_FONT = 162
local STRESS_FONT = 163

function BattleField_MessageBoxCanEnter(dwMapID)
    if not tNotifyList[dwMapID] or tNotifyList[dwMapID].bHide then
        return
    end
    
    CloseMessageBox("BattleField_Leave_" .. dwMapID)
    local szTime = FormatBattleFieldTime(MAX_BATTLE_FIELD_OVERTIME)
    local tMsg = 
    {
        bRichText = true,
        szMessage = FormatString(
            g_tStrings.STR_BATTLEFIELD_MESSAGE_ENTER, 
            GetBattleFieldQueueName(dwMapID, tNotifyList[dwMapID].nCopyIndex), 
            szTime,
            STRESS_FONT
        ),
        szName = "BattleField_Enter_" .. dwMapID,
        {szOption = g_tStrings.STR_HOTKEY_ENTER, fnAction = function() DoAcceptJoinBattleField(tNotifyList[dwMapID].nCenterIndex, dwMapID, tNotifyList[dwMapID].nCopyIndex, tNotifyList[dwMapID].nGroupID, tNotifyList[dwMapID].dwJoinValue) end, },
        {szOption = g_tStrings.STR_HOTKEY_HIDE, fnAction = function() tNotifyList[dwMapID].bHide = true; OutputMessage("MSG_SYS", g_tStrings.STR_BATTLEFIELD_MESSAGE_ENTER_HIDE) end},
        {szOption = g_tStrings.STR_HOTKEY_FANGQI, fnAction = function() BattleField_MessageBoxLeave(dwMapID) end, },
    }
    MessageBox(tMsg)
end

function BattleField_MessageBoxLeave(dwMapID)
    CloseMessageBox("BattleField_Enter_" .. dwMapID)
    local tMsg = 
    {
        szMessage = FormatString(g_tStrings.STR_BATTLEFIELD_MESSAGE_SURE_LEAVE, GetBattleFieldQueueName(dwMapID, tNotifyList[dwMapID].nCopyIndex)), 
        szName = "BattleField_Leave_" .. dwMapID,
        {szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = function() DoLeaveBattleFieldQueue(dwMapID) end, },
        {szOption = g_tStrings.STR_HOTKEY_CANCEL, fnAction = function() BattleField_MessageBoxCanEnter(dwMapID) end },
    }
    MessageBox(tMsg)
end

function OnBattleFieldNotify(dwMapID, nNotifyType, nAvgQueueTime, nPassTime, nCopyIndex, nCenterIndex, nGroupID, dwJoinValue)
	-- update data
	if nNotifyType == BATTLE_FIELD_NOTIFY_TYPE.QUEUE_INFO 
	or nNotifyType == BATTLE_FIELD_NOTIFY_TYPE.JOIN_BATTLE_FIELD then
        local bFirst = false
		if not tNotifyList[dwMapID] then
			tNotifyList[dwMapID] = {}
            bFirst = true
		end
        local nOldType = tNotifyList[dwMapID].nNotifyType
		tNotifyList[dwMapID].nNotifyType = nNotifyType
		tNotifyList[dwMapID].nAvgQueueTime = nAvgQueueTime
		tNotifyList[dwMapID].nPassTime = nPassTime
		
		if nNotifyType == BATTLE_FIELD_NOTIFY_TYPE.JOIN_BATTLE_FIELD then
			tNotifyList[dwMapID].nCopyIndex = nCopyIndex
			tNotifyList[dwMapID].nCenterIndex = nCenterIndex
		end
		
		tNotifyList[dwMapID].nGroupID = nGroupID
		tNotifyList[dwMapID].dwJoinValue = dwJoinValue
        if nOldType == nNotifyType then
            FireEvent("BATTLE_FIELD_UPDATE_TIME")
        end
        
        if bFirst then
            FireEvent("BATTLE_FIELD_STATE_UPDATE")
        end
	elseif nNotifyType == BATTLE_FIELD_NOTIFY_TYPE.LEAVE_BATTLE_FIELD then
		CloseMessageBox("BattleField_Enter_" .. dwMapID)
		tNotifyList[dwMapID] = nil
		FireEvent("BATTLE_FIELD_STATE_UPDATE")
	elseif nNotifyType == BATTLE_FIELD_NOTIFY_TYPE.IN_BLACK_LIST then
		bBlacklist = true
		nBlacklistLastTime = nPassTime
		FireEvent("BATTLE_FIELD_STATE_UPDATE")
	elseif nNotifyType == BATTLE_FIELD_NOTIFY_TYPE.LEAVE_BLACK_LIST then
		bBlacklist = false
		nBlacklistLastTime = nil
		FireEvent("BATTLE_FIELD_STATE_UPDATE")
	end
	
	if nNotifyType == BATTLE_FIELD_NOTIFY_TYPE.JOIN_BATTLE_FIELD then
		if not tNotifyList[dwMapID].bRemind then
			BattleField_MessageBoxCanEnter(dwMapID)
			tNotifyList[dwMapID].bRemind = true
		end
        FireEvent("BATTLE_FIELD_STATE_UPDATE")
	end
end

function GetCurrentBattleField()
	return tNotifyList
end


function GetBattleFieldQueueDesc(dwMapID, nFont1, nFont2, nVersion)
    local tData = tNotifyList[dwMapID] 
    if not tData then
        return
    end
    nFont1 = nFont1 or NORMAL_FONT
    nFont2 = nFont2 or STRESS_FONT
    nVersion = nVersion or 0

    if tData.nNotifyType == BATTLE_FIELD_NOTIFY_TYPE.QUEUE_INFO then
        local szBattleField = GetBattleFieldQueueName(dwMapID, 0)
    	szBattleField = GetFormatText(szBattleField, nFont2)
        
        local szTip1 = FormatString(
            g_tStrings.STR_BATTLEFIELD_QUEUE_WAIT, 
            "\"font=" .. nFont1 .. " </text>" .. szBattleField .. "<text>text=\""
        )
        szTip1 = "<text>text=\"" .. szTip1 .. "\" font=" .. nFont1 .. "</text>"
	
        local nAvgTime = tData.nAvgQueueTime
        local szTip2 = GetFormatText(g_tStrings.STR_BATTLEFIELD_QUEUE_TIME_UNKNOW .. "\n", nFont1) 
        if nAvgTime > 0 then
            szTip2 = GetFormatText(g_tStrings.STR_BATTLEFIELD_QUEUE_AVGTIME, nFont1)
            szTip2 = szTip2 .. GetFormatText(FormatBattleFieldTime(nAvgTime) .. "\n", nFont2)
        end
        
        local szTip3 = GetFormatText(g_tStrings.STR_BATTLEFIELD_QUEUE_PASSTIME, nFont1)
        local nPassTime = tData.nPassTime
        if nPassTime then
            szTip3 = szTip3 .. GetFormatText(FormatBattleFieldTime(nPassTime) .. "\n", nFont2)
        end
        return szTip1, szTip2, szTip3
    end
    
    if tData.nNotifyType == BATTLE_FIELD_NOTIFY_TYPE.JOIN_BATTLE_FIELD then
        if nVersion == 1 then
            local szTip1, szTip2 = FormatBattleFieldJoinTipVer1(
                GetBattleFieldQueueName(dwMapID, tData.nCopyIndex),  
                MAX_BATTLE_FIELD_OVERTIME - tData.nPassTime,
                nFont1,
                nFont2
            )
            return szTip1, szTip2
        else
            local szJoinTip = FormatBattleFieldJoinTip(
                GetBattleFieldQueueName(dwMapID, tData.nCopyIndex),  
                MAX_BATTLE_FIELD_OVERTIME - tData.nPassTime,
                nFont1,
                nFont2
            )
            return szJoinTip
        end
        
    end
end

function GetBattleFieldStateTip()
	local tTip = {}
	if bBlacklist then
		local szBlacklist = FormatBattleFieldBlacklistTip(nBlacklistLastTime)
		table.insert(tTip, szBlacklist)
	end
	
	if IsInBattleField() then
		local hScene = GetClientPlayer().GetScene()
		local szBattleFiledName = GetBattleFieldQueueName(hScene.dwMapID, hScene.nCopyIndex)
		if szBattleFiledName then
			local szInBattleField = GetFormatText(g_tStrings.STR_BATTLEFIELD_FIGHTING, NORMAL_FONT) .. GetFormatText(szBattleFiledName, STRESS_FONT)
			table.insert(tTip, szInBattleField)
		end
	end
		
	for dwMapID, tData in pairs(tNotifyList) do
		if tData.nNotifyType == BATTLE_FIELD_NOTIFY_TYPE.QUEUE_INFO then
			local szQueueTip = FormatBattleFieldQueueTip(
				GetBattleFieldQueueName(dwMapID, 0),--tData.nCopyIndex), 
				tData.nPassTime, 
				tData.nAvgQueueTime
			)
			table.insert(tTip, szQueueTip)
		elseif tData.nNotifyType == BATTLE_FIELD_NOTIFY_TYPE.JOIN_BATTLE_FIELD then
			local szJoinTip = FormatBattleFieldJoinTip(
				GetBattleFieldQueueName(dwMapID, tData.nCopyIndex),  
				MAX_BATTLE_FIELD_OVERTIME - tData.nPassTime
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

function GetBattleFieldMenu()
	local tMenu = nil
	
	if IsInBattleField() then
		tMenu = { { szOption = g_tStrings.STR_BATTLEFIELD_MENU_LEAVE, fnAction = function() LeaveBattleField() end, } }
	end
	
	for dwMapID, tData in pairs(tNotifyList) do
		if tData.nNotifyType == BATTLE_FIELD_NOTIFY_TYPE.QUEUE_INFO 
		or tData.nNotifyType == BATTLE_FIELD_NOTIFY_TYPE.JOIN_BATTLE_FIELD then
			if tMenu then
				table.insert(tMenu, {bDevide = true})
			else
				tMenu = {}
			end
			
			table.insert(tMenu, { szOption = GetBattleFieldQueueName(dwMapID, tData.nCopyIndex), bDisable = true, nFont = STRESS_FONT, })
			if tData.nNotifyType == BATTLE_FIELD_NOTIFY_TYPE.JOIN_BATTLE_FIELD then
				table.insert(tMenu, { szOption = g_tStrings.STR_BATTLEFIELD_MENU_ENTER, fnAction = function() DoAcceptJoinBattleField(tData.nCenterIndex, dwMapID, tData.nCopyIndex, tData.nGroupID, tData.dwJoinValue) end, })
			end

			if tData.nNotifyType == BATTLE_FIELD_NOTIFY_TYPE.QUEUE_INFO then
				table.insert(tMenu, { szOption = g_tStrings.STR_BATTLEFIELD_MENU_LEAVE, fnAction = function() DoLeaveBattleFieldQueue(dwMapID) end, })
			end
            
			if tData.nNotifyType == BATTLE_FIELD_NOTIFY_TYPE.JOIN_BATTLE_FIELD then
				table.insert(tMenu, { szOption = g_tStrings.STR_HOTKEY_FANGQI, fnAction = function() BattleField_MessageBoxLeave(dwMapID) end, })
			end
		end
	end
	return tMenu
end

function GetBattleFieldQueueName(dwMapID, nCopyIndex)
	local szName = Table_GetBattleFieldName(dwMapID)
    --[[
	if nCopyIndex and nCopyIndex ~= 0 then
		szName = szName .. "(" .. nCopyIndex .. ")"
	end
    ]]
	return szName
end

function IsInBattleFieldQueue(dwMapID)
    if tNotifyList[dwMapID] and tNotifyList[dwMapID].nNotifyType == BATTLE_FIELD_NOTIFY_TYPE.QUEUE_INFO then
        return true;
    end
    return false;
end

function IsCanEnterBattleField()
    if not tNotifyList then
        return false
    end
    
    for dwMapID, t in pairs(tNotifyList) do 
        if t and t.nNotifyType == BATTLE_FIELD_NOTIFY_TYPE.JOIN_BATTLE_FIELD then
            return true;
        end
    end
    return false;
end

function IsInBattleFieldBacklist()
	return bBlacklist
end

function GetBattleFieldBackCoolTime()
    return nBlacklistLastTime
end

function HasBattleFieldInfo()
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
	
	if IsInBattleField() then
		return "normal"
	end
end

function IsInBattleField()
	local hPlayer = GetClientPlayer()
	if hPlayer then
		local hScene = hPlayer.GetScene()
		return Table_IsBattleFieldMap(hScene.dwMapID)
	end
end

function BattleField_ReprotRobot(dwPlayerID)
	RemoteCallToServer("On_Zhanchang_Jubaoguaji", dwPlayerID)
end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function DoAcceptJoinBattleField(nCenterIndex, dwMapID, nCopyIndex, nGroupID, dwJoinValue)
	CloseMessageBox("BattleField_Enter_" .. dwMapID)
	tNotifyList[dwMapID] = nil
	FireEvent("BATTLE_FIELD_STATE_UPDATE")
	AcceptJoinBattleField(nCenterIndex, dwMapID, nCopyIndex, nGroupID, dwJoinValue)
end

function DoLeaveBattleFieldQueue(dwMapID)
	CloseMessageBox("BattleField_Enter_" .. dwMapID)
	tNotifyList[dwMapID] = nil
	FireEvent("BATTLE_FIELD_STATE_UPDATE")
	LeaveBattleFieldQueue(dwMapID)
end

function FormatBattleFieldTime(nTime)
	local szTime
	if nTime > 60 then
		szTime = math.floor(nTime / 60) .. g_tStrings.STR_BUFF_H_TIME_M
	else
		szTime = nTime .. g_tStrings.STR_BUFF_H_TIME_S
	end
	return szTime
end

function FormatBattleFieldQueueTip(szBattleField, nPassTime, nAvgTime)
	local szBattleField = GetFormatText(szBattleField, STRESS_FONT)
	local szTip = FormatString(
		g_tStrings.STR_BATTLEFIELD_QUEUE_WAIT, 
		"\"font=" .. NORMAL_FONT .. " </text>" .. szBattleField .. "<text>text=\""
	)
	szTip = szTip .. "\n"
	szTip = "<text>text=\"" .. szTip .. "\" font=" .. NORMAL_FONT .. "</text>"
	
	if nAvgTime > 0 then
		szTip = szTip .. GetFormatText(g_tStrings.STR_BATTLEFIELD_QUEUE_AVGTIME, NORMAL_FONT)
		szTip = szTip .. GetFormatText(FormatBattleFieldTime(nAvgTime) .. "\n", STRESS_FONT)
	else
		szTip = szTip .. GetFormatText(g_tStrings.STR_BATTLEFIELD_QUEUE_TIME_UNKNOW .. "\n", NORMAL_FONT)
	end
	
	szTip = szTip .. GetFormatText(g_tStrings.STR_BATTLEFIELD_QUEUE_PASSTIME, NORMAL_FONT)
	szTip = szTip .. GetFormatText(FormatBattleFieldTime(nPassTime) .. "\n", STRESS_FONT)
	return szTip
end

function FormatBattleFieldJoinTip(szBattleField, nLastTime, nFont1, nFont2)
    nFont1 = nFont1 or NORMAL_FONT
    nFont2 = nFont2 or STRESS_FONT
    
	local szBattleField = GetFormatText(szBattleField, nFont2)
	local szLastTime = GetFormatText(FormatBattleFieldTime(nLastTime), nFont2)
	local szTip = FormatString(
		g_tStrings.STR_BATTLEFIELD_QUEUE_ENTER, 
		"\"font=" .. nFont1 .. " </text>" .. szBattleField .. "<text>text=\"", 
		"\"font=" .. nFont1 .. " </text>" .. szLastTime .. "<text>text=\""
	)
	return "<text>text=\"" .. szTip .. "\" font=" .. nFont1 .. "</text>"
end

function FormatBattleFieldJoinTipVer1(szBattleField, nLastTime, nFont1, nFont2)
    nFont1 = nFont1 or NORMAL_FONT
    nFont2 = nFont2 or STRESS_FONT
    
	local szBattleField = GetFormatText(szBattleField, nFont2)
	local szLastTime = GetFormatText(FormatBattleFieldTime(nLastTime), nFont2)
    local szTip1 = FormatString(g_tStrings.BATTLE_FIELD_CAN_ENTER, szBattleField, nFont1)
        
    local szTip2 = FormatString(g_tStrings.BATTLE_FIELD_CAN_ENTER_TIME, szLastTime, nFont1)
    
	return szTip1, szTip2 
end

function FormatBattleFieldBlacklistTip(nLastTime)
	local szLastTime = GetFormatText(FormatBattleFieldTime(nLastTime), STRESS_FONT)
	local szTip = FormatString(
		g_tStrings.STR_BATTLEFIELD_BLACK_LIST, 
		"\"font=" .. NORMAL_FONT .. " </text>" .. szLastTime .. "<text>text=\""
	)
	return "<text>text=\"" .. szTip .. "\" font=" .. NORMAL_FONT .. "</text>"
end

local tBanishTime = { 5 * 60, 3 * 60, 60, 45, 30, 15, 0}
local nLastBanishIndex = nil
function OnBattleFieldMapUnload(nBanishTime)
	for nIndex, nTime in ipairs(tBanishTime) do
		if nBanishTime <= nTime and tBanishTime[nIndex + 1] and nBanishTime > tBanishTime[nIndex + 1] then
			if nLastBanishIndex ~= nIndex then
				local szTime = GetTimeText(tBanishTime[nIndex])
				OutputMessage("MSG_SYS", FormatString(g_tStrings.STR_BATTLEFIELD_MESSAGE_MAP_UNLOAD, szTime))
				nLastBanishIndex = nIndex
			end
			return
		end
	end
	nLastBanishIndex = nil
end

RegisterEvent("BATTLE_FIELD_NOTIFY", function() OnBattleFieldNotify(arg3, arg0, arg1, arg2, arg4, arg5, arg6, arg7) end)