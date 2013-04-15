
local bUseYY = false
local bSuccess = false

function BeginUseYY()
	local player = GetClientPlayer()
	if not player then
		return
	end

	if not player.IsInParty() then
		return
	end
	
	local hTeam = GetClientTeam()
	if not hTeam then
		return
	end

	local nResult = YY_RunService("3rdParty\\YYSetup3804.exe")
	if nResult ~= 0 then
		local msg = 
		{
			szMessage = g_tStrings.OPEN_YY_WEB..tUrl.YYDownload, 
			szName = "download_yy", 
			{szOption = g_tStrings.OPEN_YY_WEB, fnAction = function() OpenInternetExplorer(tUrl.YYDownload) end },
			{szOption = g_tStrings.STR_HOTKEY_CANCEL},
		}
		MessageBox(msg)
		return
	end

	if not bUseYY then
		bUseYY = true
		FireEvent("USE_YY_STATE_CHANGED")
	end
	bSuccess = false 
	
	YY_SetPosition(200, 120)
	
	nResult = YY_LoadInGame("KING_JW3|YY3D9|HOOK9ALL")
	if nResult ~= 0 then
		return
	end
	nResult = YY_SetUserName(player.szName)
	if nResult ~= 0 then
		return
	end
	nResult = YY_JoinTeam(Login.m_szServerIP..":"..tostring(Login.m_nServerPort).."@"..tostring(hTeam.dwTeamID))
	if nResult ~= 0 then
		return
	end
	if player.IsPartyLeader() then
		nResult = YY_SetTeamAdmin(true)
	else
		nResult = YY_SetTeamAdmin(false)
	end
	if nResult ~= 0 then
		return
	end
		
	nResult = YY_SetPipShow(true)
	if nResult ~= 0 then
		return
	end
	
	bSuccess = true
end

function EndUseYY()
	if bUseYY then
		bUseYY = false
		FireEvent("USE_YY_STATE_CHANGED")
	end
	bSuccess = false
	YY_SetPipShow(false)
	YY_JoinTeam(nil)	
end

function IsInUseYY()
	return bUseYY
end

local tLoopCount = 0
local function YYBreathe()
	if bUseYY then
		tLoopCount = tLoopCount + 1
		if tLoopCount < 16 then
			return
		end
		
		tLoopCount = 0

		local player = GetClientPlayer()
		if not player then
			EndUseYY()
			return
		end

		if not player.IsInParty() then
			EndUseYY()
			return
		end
	
		local hTeam = GetClientTeam()
		if not hTeam then
			EndUseYY()
			return
		end
		
		if not bSuccess then
			BeginUseYY()
			return
		end
		
		if player.IsPartyLeader() then
			nResult = YY_SetTeamAdmin(true)
		else
			nResult = YY_SetTeamAdmin(false)
		end
	end
end

RegisterBreatheEvent("YY_Breathe", YYBreathe)
RegisterEvent("UI_LUA_RESET", function() EndUseYY() end)
