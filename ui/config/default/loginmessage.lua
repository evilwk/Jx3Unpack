LoginMessage={
	m_nMessageEvent=nil;
	m_pFocusWindow=nil;

OnFrameCreate=function()
	this:RegisterEvent("UI_SCALED")
	LoginMessage.OnEvent("UI_SCALED")
end;

OnFrameShow=function()
	local frameWaiting=Station.Lookup("Topmost/LoginWaiting")
	if frameWaiting and frameWaiting:IsVisible() then
		frameWaiting:Hide()
	end
	local frameQueue=Station.Lookup("Topmost/Queue")
	if frameQueue and frameQueue:IsVisible() then
		frameQueue:Hide()
	end

	LoginMessage.m_pFocusWindow=Station.GetFocusWindow()

	this:BringToTop()
	Station.SetFocusWindow(this)

	local _,_,_,szVersionType = GetVersion()
	if szVersionType == "snda" then
		Login.ShowSdoaWindows(false)
	end
end;

OnFrameHide=function()
	local _,_,_,szVersionType = GetVersion()
	if szVersionType == "snda" then
		if Login.m_StateLeaveFunction == Login.LeavePassword then
			local wndServerList=Station.Lookup("Topmost/LoginServerList")
			if not (wndServerList and wndServerList:IsVisible()) then
				Login.ShowSdoaWindows(true)
			end
		end
	end

	if LoginMessage.m_pFocusWindow and LoginMessage.m_pFocusWindow:IsValid() then
		Station.SetFocusWindow(LoginMessage.m_pFocusWindow)
	end
end;

OnEvent=function(event)
	if event == "UI_SCALED" then
		local wnd = this:Lookup("Wnd_All")
		if wnd then
			local w, h = wnd:GetSize()
			local wAll, hAll = Station.GetClientSize()
			wnd:SetRelPos((wAll - w) / 2, (hAll - h) / 2)
			this:SetSize(wAll, hAll)
			this:Lookup("", ""):SetSize(wAll, hAll)
		end
	end
end;

OnFrameKeyDown=function()
	this:Hide()
	PlaySound(SOUND.UI_SOUND, g_sound.CloseFrame)
	return 1
end;

OnItemLButtonClick=function()
	this:GetRoot():Hide()
	PlaySound(SOUND.UI_SOUND, g_sound.CloseFrame)
	return 1
end;

OnItemLButtonDBClick=function()
	this:GetRoot():Hide()
	PlaySound(SOUND.UI_SOUND, g_sound.CloseFrame)
	return 1
end;

OnItemRButtonClick=function()
	this:GetRoot():Hide()
	PlaySound(SOUND.UI_SOUND, g_sound.CloseFrame)
	return 1
end;

OnItemRButtonDBClick=function()
	this:GetRoot():Hide()
	PlaySound(SOUND.UI_SOUND, g_sound.CloseFrame)
	return 1
end;

ShowEventMessage=function(nMessageEvent)
	local aEventNameTable={}

	aEventNameTable[LOGIN.UNABLE_TO_CONNECT_SERVER]=g_tGlue.tLoginString["UNABLE_TO_CONNECT_SERVER"]
	aEventNameTable[LOGIN.MISS_CONNECTION]=g_tGlue.tLoginString["MISS_CONNECTION"]
	aEventNameTable[LOGIN.SYSTEM_MAINTENANCE]=g_tGlue.tLoginString["SYSTEM_MAINTENANCE"]
    aEventNameTable[LOGIN.UNMATCHED_PROTOCOL_VERSION]=g_tGlue.tLoginString["UNMATCHED_PROTOCOL_VERSION"]
	aEventNameTable[LOGIN.HANDSHAKE_ACCOUNT_SYSTEM_LOST]=g_tGlue.tLoginString["HANDSHAKE_ACCOUNT_SYSTEM_LOST"]
	aEventNameTable[LOGIN.VERIFY_ALREADY_IN_GATEWAY]=g_tGlue.tLoginString["VERIFY_ALREADY_IN_GATEWAY"]
	aEventNameTable[LOGIN.VERIFY_IN_GATEWAY_BLACK_LIST]=g_tGlue.tLoginString["VERIFY_IN_GATEWAY_BLACK_LIST"]
	aEventNameTable[LOGIN.VERIFY_SUCCESS]=g_tGlue.tLoginString["VERIFY_SUCCESS"]
	aEventNameTable[LOGIN.VERIFY_IN_GAME]=g_tGlue.tLoginString["VERIFY_IN_GAME"]
	aEventNameTable[LOGIN.VERIFY_ACC_PSW_ERROR]=g_tGlue.tLoginString["VERIFY_ACC_PSW_ERROR"]
	aEventNameTable[LOGIN.VERIFY_NO_MONEY]=g_tGlue.tLoginString["VERIFY_NO_MONEY"]
	aEventNameTable[LOGIN.VERIFY_NOT_ACTIVE]=g_tGlue.tLoginString["VERIFY_NOT_ACTIVE"]
	aEventNameTable[LOGIN.VERIFY_ACTIVATE_CODE_ERR]=g_tGlue.tLoginString["VERIFY_ACTIVATE_CODE_ERR"]
	aEventNameTable[LOGIN.VERIFY_IN_OTHER_GROUP]=g_tGlue.tLoginString["VERIFY_IN_OTHER_GROUP"]
	aEventNameTable[LOGIN.VERIFY_ACC_FREEZED]=FormatString(g_tGlue.tLoginString["VERIFY_ACC_FREEZED"], tPhone.CustomerService)
	aEventNameTable[LOGIN.VERIFY_ACC_SMS_LOCK]=g_tGlue.tLoginString["VERIFY_ACC_SMS_LOCK"]
	aEventNameTable[LOGIN.VERIFY_PAYSYS_BLACK_LIST]=g_tGlue.tLoginString["VERIFY_PAYSYS_BLACK_LIST"]
	aEventNameTable[LOGIN.VERIFY_UNKNOWN_ERROR]=g_tGlue.tLoginString["VERIFY_UNKNOWN_ERROR"]
    aEventNameTable[LOGIN.GET_ROLE_LIST_SUCCESS]=g_tGlue.tLoginString["GET_ROLE_LIST_SUCCESS"]
    aEventNameTable[LOGIN.UPDATE_HOMETOWN_LIST]=g_tGlue.tLoginString["UPDATE_HOMETOWN_LIST"]
    aEventNameTable[LOGIN.CREATE_ROLE_SUCCESS]=g_tGlue.tLoginString["CREATE_ROLE_SUCCESS"]
	aEventNameTable[LOGIN.CREATE_ROLE_NAME_EXIST]=g_tGlue.tLoginString["CREATE_ROLE_NAME_EXIST"]
	aEventNameTable[LOGIN.CREATE_ROLE_INVALID_NAME]=g_tGlue.tLoginString["CREATE_ROLE_INVALID_NAME"]
	aEventNameTable[LOGIN.CREATE_ROLE_NAME_TOO_LONG]=g_tGlue.tLoginString["CREATE_ROLE_NAME_TOO_LONG"]
	aEventNameTable[LOGIN.CREATE_ROLE_NAME_TOO_SHORT]=g_tGlue.tLoginString["CREATE_ROLE_NAME_TOO_SHORT"]
	aEventNameTable[LOGIN.CREATE_ROLE_UNABLE_TO_CREATE]=g_tGlue.tLoginString["CREATE_ROLE_UNABLE_TO_CREATE"]
    aEventNameTable[LOGIN.REQUEST_LOGIN_GAME_SUCCESS]=g_tGlue.tLoginString["REQUEST_LOGIN_GAME_SUCCESS"]
    aEventNameTable[LOGIN.REQUEST_LOGIN_GAME_OVERLOAD]=g_tGlue.tLoginString["REQUEST_LOGIN_GAME_OVERLOAD"]
    aEventNameTable[LOGIN.REQUEST_LOGIN_GAME_MAINTENANCE]=g_tGlue.tLoginString["REQUEST_LOGIN_GAME_MAINTENANCE"]
	aEventNameTable[LOGIN.REQUEST_LOGIN_GAME_ROLEFREEZE]=g_tGlue.tLoginString["REQUEST_LOGIN_GAME_ROLEFREEZE"]
	aEventNameTable[LOGIN.REQUEST_LOGIN_GAME_SWITCH_CENTER]=g_tGlue.tLoginString["REQUEST_LOGIN_GAME_SWITCH_CENTER"]
    aEventNameTable[LOGIN.REQUEST_LOGIN_GAME_CHANGE_ACCOUNT]=g_tGlue.tLoginString["REQUEST_LOGIN_GAME_CHANGE_ACCOUNT"]
    aEventNameTable[LOGIN.REQUEST_LOGIN_GAME_UNKNOWN_ERROR]=g_tGlue.tLoginString["REQUEST_LOGIN_GAME_UNKNOWN_ERROR"]
    aEventNameTable[LOGIN.DELETE_ROLE_SUCCESS]=g_tGlue.tLoginString["DELETE_ROLE_SUCCESS"]
    aEventNameTable[LOGIN.DELETE_ROLE_DELAY]=g_tGlue.tLoginString["DELETE_ROLE_DELAY"]
    aEventNameTable[LOGIN.DELETE_ROLE_TONG_MASTER]=g_tGlue.tLoginString["DELETE_ROLE_TONG_MASTER"]
    aEventNameTable[LOGIN.DELETE_ROLE_FREEZE_ROLE]=g_tGlue.tLoginString["DELETE_ROLE_FREEZE_ROLE"]
    aEventNameTable[LOGIN.DELETE_ROLE_UNKNOWN_ERROR]=g_tGlue.tLoginString["DELETE_ROLE_UNKNOWN_ERROR"]
    aEventNameTable[LOGIN.GIVEUP_QUEUE_SUCCESS]=g_tGlue.tLoginString["GIVEUP_QUEUE_SUCCESS"]
    aEventNameTable[LOGIN.GIVEUP_QUEUE_ERROR]=g_tGlue.tLoginString["GIVEUP_QUEUE_ERROR"]
    aEventNameTable[LOGIN.RENAME_NAME_ALREADY_EXIST]=g_tGlue.tLoginString["RENAME_NAME_ALREADY_EXIST"]
    aEventNameTable[LOGIN.RENAME_NAME_TOO_LONG]=g_tGlue.tLoginString["RENAME_NAME_TOO_LONG"]
    aEventNameTable[LOGIN.RENAME_NAME_TOO_SHORT]=g_tGlue.tLoginString["RENAME_NAME_TOO_SHORT"]
    aEventNameTable[LOGIN.RENAME_NEW_NAME_ERROR]=g_tGlue.tLoginString["RENAME_NEW_NAME_ERROR"]
    aEventNameTable[LOGIN.RENAME_ERROR]=g_tGlue.tLoginString["RENAME_ERROR"]

	LoginMessage.m_nMessageEvent=nMessageEvent

	LoginMessage.ShowMessage(aEventNameTable[nMessageEvent])
end;

ShowMessage=function(szText)
	local frame=Station.Lookup("Topmost/LoginMessage")
	frame:Lookup("Wnd_All", "Text_Message"):SetText(szText)
	if not frame:IsVisible() then
		frame:Show()
	end
end;

}
