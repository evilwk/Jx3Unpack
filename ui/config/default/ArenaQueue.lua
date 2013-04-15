
local function OnJoinArenaQueue()
	if arg0 == ARENA_RESULT_CODE.SUCCESS then
		--OutputMessage("MSG_SYS", g_tStrings.tArenaResult[arg0]);
	else
		local szTip = g_tStrings.tArenaResult[arg0]
		if szTip then
			local szName = arg2
			local player = GetClientPlayer();
			
			
			if szName and szName ~= player.szName then
				szTip = FormatString(szTip, g_tStrings.STR_BATTLE_JION_QUEUE_TIP1.."["..szName.."]")
			else
				szTip = FormatString(szTip, g_tStrings.STR_BATTLE_JION_QUEUE_TIP)
			end
			
			OutputMessage("MSG_ANNOUNCE_RED", szTip);
			OutputMessage("MSG_SYS", szTip); 
		end
	end
end

local function OnLeaveArenaQueue()
    OutputMessage("MSG_SYS", g_tStrings.STR_ARENA_LEAVE_QUEUE); 
    OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_ARENA_LEAVE_QUEUE); 
end

RegisterEvent("JOIN_ARENA_QUEUE", OnJoinArenaQueue)
RegisterEvent("LEAVE_ARENA_QUEUE", OnLeaveArenaQueue)