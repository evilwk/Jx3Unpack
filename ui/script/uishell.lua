	
UIShell={
	m_bLoadMainUI=false;
	
CheckConfig = function()
	local szIniFile = "config.ini"
	local ini = Ini.Open(szIniFile)
	if not ini then
		return
	end

	local nValue = ini:ReadInteger("Debug", "ShowLuaErrMsg", 0)
	if nValue and nValue ~= 0 then
		_g_ShowLuaErrMsg = true
	end

	ini:Close()
end;

LoadLoginUI=function(bReLogin)
	local szBgMusic = Table_GetPath("LOGIN_BGM")
	PlayBgMusic(szBgMusic)
	
	Wnd.OpenWindow("LoadingPanel"):Hide()
	Wnd.OpenWindow("LoginWaitServerList"):Hide()
	Wnd.OpenWindow("LoginServerList"):Hide()
	Wnd.OpenWindow("LoginSingleRole"):Hide()
	Wnd.OpenWindow("LoginWaiting"):Hide()

	if g_tLoginData.bShowLogo then
		Wnd.OpenWindow("LoginLogo"):Hide()
	end
	
	Wnd.OpenWindow("LoginPassword"):Hide()
	Wnd.OpenWindow("LoginSwordLogo"):Hide()
	Wnd.OpenWindow("LoginCustomRole"):Hide()
	Wnd.OpenWindow("LoginCustomRoleNext"):Hide()
	Wnd.OpenWindow("LoginRoleList"):Hide()
	Wnd.OpenWindow("LoginMessage"):Hide()
	Wnd.OpenWindow("Queue"):Hide()
	Wnd.OpenWindow("SecurityCard"):Hide()
	Wnd.OpenWindow("LoginRename"):Hide()
	Wnd.OpenWindow("LoginTokenPanel"):Hide()
	
	if bReLogin then
		Login.EnterRoleList()
		Login.RequestRelogin()
	else
		--[[
		if g_tLoginData.bShowLogo then
			LoginLogo.ShowCG()
		else
			LoginLogo.ShowLogo()
		end
		Login.EnterLogo()
		g_tLoginData.bShowLogo = false 
		--]]
		Login.EnterPassword()
	end
end;

CloseAllLoginWindow=function()
	StopBgMusic()

	Wnd.CloseWindow("Queue")
	Wnd.CloseWindow("LoginServerList")
	Wnd.CloseWindow("LoginWaitServerList")

	Wnd.CloseWindow("LoginSingleRole")
	Wnd.CloseWindow("LoginWaiting")
	if g_tLoginData.bShowLogo then
		Wnd.CloseWindow("LoginLogo")
	end
	Wnd.CloseWindow("LoginPassword")
	Wnd.CloseWindow("LoginSwordLogo")
	Wnd.CloseWindow("LoginCustomRole")
	Wnd.CloseWindow("LoginCustomRoleNext")
	Wnd.CloseWindow("LoginRoleName")
	Wnd.CloseWindow("LoginHomeplace")
	Wnd.CloseWindow("LoginRoleList")
	Wnd.CloseWindow("LoginMessage")
	Wnd.CloseWindow("SecurityCard")
	Wnd.CloseWindow("LoginRename")
	Wnd.CloseWindow("LoginTokenPanel")
end;

UnloadLoginUI=function()
	UIShell.CloseAllLoginWindow()
end;

ResizeUI = function()
	if UIShell.m_bLoadMainUI then
		Wnd.AdjustFrameListPosition("\\UI\\Config\\framelist.ini")
		CorrectAutoPosFrameAfterClientResize()
	end
end;

IsAreadyInGame = function()
	return UIShell.m_bLoadMainUI
end;

CloseAllWindow = function()
	local tLayer = 
	{
		"Lowest",
		"Lowest1",
		"Lowest2",
		"Normal",
		"Normal1",
		"Normal2",
		"Topmost",
		"Topmost1",
		"Topmost2",
	}
	
	local fnClose = function(frame)
		local hBorther = frame
		while hBorther do
			local hNext = hBorther
			hBorther = hBorther:GetNext()
			Wnd.CloseWindow(hNext:GetName())
		end
	end
	
	for k, v in pairs(tLayer) do
		local hRoot = Station.Lookup(v)
		local frame = hRoot:GetFirstChild()
		if frame then
			fnClose(frame)
		end
	end
end;

};

function UpdateSdoaInitFlag()
	local _,_,_,szVersionType = GetVersion()
	if szVersionType == "snda" then
		LoginPassword.m_bSdoaInitFinished = true
	end
end;

function LoadLoginUI()
	local nReason = GetLoadLoginReason()
	local bReLogin = false
	if nReason == LOAD_LOGIN_REASON.START_GAME_LOGIN then
		UIShell.CheckConfig()
	elseif nReason == LOAD_LOGIN_REASON.RETURN_GAME_LOGIN then
		if g_tLoginData then
			g_tLoginData.szAccount = Login_GetAccount()
			Login.m_szAccount = g_tLoginData.szAccount
		end
		UIShell.CheckConfig()
		ResetGameworld()
		UpdateSdoaInitFlag()
	elseif nReason == LOAD_LOGIN_REASON.RETURN_ROLE_LIST then
		if g_tLoginData then
			g_tLoginData.szAccount = Login_GetAccount()
			Login.m_szAccount = g_tLoginData.szAccount
		end
		UIShell.CheckConfig()
		ResetGameworld()
		bReLogin = true
	elseif nReason == LOAD_LOGIN_REASON.RETURN_CLEAR_UI then
		ResetGameworld()
		return
	elseif nReason == LOAD_LOGIN_REASON.KICK_OUT_BY_GM then
		if g_tLoginData then
			g_tLoginData.szAccount = Login_GetAccount()
			Login.m_szAccount = g_tLoginData.szAccount
		end	
		UpdateSdoaInitFlag()
	elseif nReason == LOAD_LOGIN_REASON.KICK_OUT_BY_OTHERS then
		if g_tLoginData then
			g_tLoginData.szAccount = Login_GetAccount()
			Login.m_szAccount = g_tLoginData.szAccount
		end	
		UIShell.CheckConfig()
		ResetGameworld()
		UpdateSdoaInitFlag()
	elseif nReason == LOAD_LOGIN_REASON.AUTO_EXIT then
		if g_tLoginData then
			g_tLoginData.szAccount = Login_GetAccount()
			Login.m_szAccount = g_tLoginData.szAccount
		end	
		UIShell.CheckConfig()
		ResetGameworld()
		UpdateSdoaInitFlag()
	end

	UIShell.LoadLoginUI(bReLogin)
	
	if nReason == LOAD_LOGIN_REASON.KICK_OUT_BY_GM 
	or nReason == LOAD_LOGIN_REASON.KICK_OUT_BY_OTHERS 
	then
		Login.ShowSdoaWindows(false)
		ShowKickOutMessage(nReason)
	elseif nReason == LOAD_LOGIN_REASON.AUTO_EXIT then
		Login.ShowSdoaWindows(false)
		ShowAutoExitMessage()
	end
end

function ShowKickOutMessage(nReason)
    local nX = nil
    local nY = nil
	local wnd = Station.Lookup("Normal/LoginPassword"):Lookup("WndPassword")
	if wnd then
	    nX, nY = wnd:GetRelPos()
	end
	
	if nReason == LOAD_LOGIN_REASON.KICK_OUT_BY_GM then
	    -- 
    elseif nReason == LOAD_LOGIN_REASON.KICK_OUT_BY_OTHERS then
		local msg =
		{
		    x = nX, y = nY,
		    bModal = true,
			szMessage = FormatString(g_tGlue.tLoginString.BE_KICK_ACCOUNT, tUrl.CustomerServiceWeb),
			szName = "BeKickAccount",
			{
				szOption = g_tStrings.STR_HOTKEY_SURE, 
				fnAction = function() 
					Login.ShowSdoaWindows(true)
				end 
			},
		}
		MessageBox(msg)
    end
end

function ShowAutoExitMessage()
	local nWidth, nHeight = Station.GetClientSize()
	local tMsg =
	{
		x = nWidth / 2, y = nHeight / 2,
		szMessage = g_tStrings.MSG_BE_AUTO_EXIT,
		szName = "AutoExitMessage",
		{
			szOption = g_tStrings.STR_HOTKEY_SURE, 
			fnAction = function()
				Login.ShowSdoaWindows(true)
			end
		},
	}
	MessageBox(tMsg)
end

function UnloadLoginUI()
	UIShell.UnloadLoginUI()
end

function ResizeUI()
	UIShell.ResizeUI()
end
