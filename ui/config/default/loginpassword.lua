
LoginPassword=
{
	m_keyboard={
		[1]={"a","A"},
		[2]={"b","B"},
		[3]={"c","C"},
		[4]={"d","D"},
		[5]={"e","E"},
		[6]={"f","F"},
		[7]={"g","G"},
		[8]={"h","H"},
		[9]={"i","I"},
		[10]={"j","J"},
		[11]={"k","K"},
		[12]={"l","L"},
		[13]={"m","M"},
		[14]={"n","N"},
		[15]={"o","O"},
		[16]={"p","P"},
		[17]={"q","Q"},
		[18]={"r","R"},
		[19]={"s","S"},
		[20]={"t","T"},
		[21]={"u","U"},
		[22]={"v","V"},
		[23]={"w","W"},
		[24]={"x","X"},
		[25]={"y","Y"},
		[26]={"z","Z"},
		[27]={"`","~"},
		[28]={"1","!"},
		[29]={"2","@"},
		[30]={"3","#"},
		[31]={"4","$"},
		[32]={"5","%"},
		[33]={"6","^"},
		[34]={"7","&"},
		[35]={"8","*"},
		[36]={"9","("},
		[37]={"0",")"},
		[38]={"-","_"},
		[39]={"=","+"},
		[40]={"[","{"},
		[41]={"]","}"},
		[42]={"\\","|"},
		[43]={";",":"},
		[44]={"'","\""},
		[45]={",","<"},
		[46]={".",">"},
		[47]={"/","?"}
	};
	
	m_bSdoaInitFinished = false;
	m_bSdoaShowLoginDialog = false;
	
	m_nTime = nil;
	m_nSndaTime = nil;

ShuffleKeyboard=function()
	local c = #LoginPassword.m_keyboard
	for i = 1, c do
		local n = math.random(c)
		local t = LoginPassword.m_keyboard[n]
		LoginPassword.m_keyboard[n] = LoginPassword.m_keyboard[i]
		LoginPassword.m_keyboard[i] = t
	end
end;

UpdateKeyboard=function(wndKeyboard)
	if not wndKeyboard then
		wndKeyboard = this:GetRoot():Lookup("WndKeyboard")
	end
	
	local shift = wndKeyboard:Lookup("CheckBox_KbShift"):IsCheckBoxChecked()

	for i = 1, #LoginPassword.m_keyboard do
		local btn = wndKeyboard:Lookup(string.format("Btn_Kb%02d", i))
		btn:Lookup("", string.format("Text_Kb%02dA", i)):SetText(LoginPassword.m_keyboard[i][2])
		btn:Lookup("", string.format("Text_Kb%02dB", i)):SetText(LoginPassword.m_keyboard[i][1])
		if shift then
			btn:Lookup("", string.format("Text_Kb%02dA", i)):SetFontScheme(162)
			btn:Lookup("", string.format("Text_Kb%02dB", i)):SetFontScheme(109)
		else
			btn:Lookup("", string.format("Text_Kb%02dA", i)):SetFontScheme(109)
			btn:Lookup("", string.format("Text_Kb%02dB", i)):SetFontScheme(162)
		end
	end
end;

UpdateServerName=function()
	if not wndServer then
		wndServer = Station.Lookup("Normal/LoginPassword/WndServer")
	end

	local szRegionName, szServerName = LoginServerList.GetSelectedShowServer()
	if not szRegionName then
		szRegionName = ""
	end
	if not szServerName then
		szServerName = ""
    end

	wndServer:Lookup("", "Text_Region"):SetText(szRegionName)
	wndServer:Lookup("", "Text_Server"):SetText(szServerName)
end;

RequestUpdateServerName = function()
	if g_bRequestRemoteServerListSuccess then
		LoginPassword.UpdateServerName()
	else
		LoginPassword.bRequestUpdateServerName = true
		LoginServerList.RequestRemoteServerList()
	end
end;

AcceptEULA=function(bAccept)
	g_tLoginData.bAcceptEULA = bAccept
end;

UpdateEULA=function()
	local checkboxEULA = Station.Lookup("Normal/LoginPassword/WndPassword/CheckBox_EULA")
	checkboxEULA:Check(g_tLoginData.bAcceptEULA)
end;

UpdateRememberAccount=function()
	local checkboxRememberAccount = Station.Lookup("Normal/LoginPassword/WndPassword/CheckBox_RememberAccount")
	checkboxRememberAccount.m_bManual = true
	checkboxRememberAccount:Check(g_tLoginData.bRememberAccount)
	checkboxRememberAccount.m_bManual = false
end;

OnFrameHide=function()
	CloseCGSelectPanel()
	Wnd.CloseWindow("EULAPanel")
end;

OnFrameShow=function()
	local wndKeyboard = this:Lookup("WndKeyboard")
	LoginPassword.UpdateKeyboard(wndKeyboard)

	LoginPassword.RequestUpdateServerName()

	LoginPassword.UpdateEULA()
	LoginPassword.UpdateButtonState()
	LoginPassword.UpdateRememberAccount()

	local bEnableKeyboard = this:Lookup("WndPassword"):Lookup("CheckBox_Keyboard"):IsCheckBoxChecked()
	if bEnableKeyboard then
		wndKeyboard:Show()
	else
		wndKeyboard:Hide()
	end
	
	local focus = Station.GetFocusWindow()
	if focus and focus:IsValid() and focus:GetRoot():GetName() == "LoginMessage" then
		focus:Hide()
		Station.SetFocusWindow(this)
		this:FocusHome()
		focus:Show()
	else
		local szText = this:Lookup("WndPassword/Edit_Account"):GetText()
		if szText and szText ~= "" then
			Station.SetFocusWindow(this:Lookup("WndPassword/Edit_Password"))
		else
			Station.SetFocusWindow(this:Lookup("WndPassword/Edit_Account"))
		end
	end

	local handleBulletinMessage = this:Lookup("WndBulletin", "Handle_BulletinMessage")
    handleBulletinMessage:Clear()
	handleBulletinMessage:AppendItemFromString(GetBulletinText())
	handleBulletinMessage:FormatAllItemPos()
	LoginPassword.UpdateScrollInfo(handleBulletinMessage)
  
	Interaction_Request("Bulletin", tUrl.Bulletin, "", "", 80)
end;

OnFrameBreathe=function()
	if LoginPassword.m_nTime then
		local nTime = GetTickCount()
		if nTime - LoginPassword.m_nTime > 3000 then
			local nIndex = GetInternetExplorerIndex(tUrl.BindCardSuccess)
			if nIndex then
				CloseInternetExplorer(nIndex)
				Login.Relogin()
			end
			
			LoginPassword.m_nTime = nil
		end
	end
	    	
	if Login.m_bBindCard then
		local nIndex = GetInternetExplorerIndex(tUrl.BindCardSuccess)
		if nIndex then
			Login.m_bBindCard = false
			LoginPassword.m_nTime = GetTickCount()
		end
	end
	
	local _,_,_,szVersionType = GetVersion()
	if szVersionType == "snda" then
		if LoginPassword.m_nSndaTime then
			local nTime = GetTickCount()
			if nTime - LoginPassword.m_nSndaTime > 3000 then
				local nIndex = GetInternetExplorerIndexFromTitle("%[%d+%]")
				if nIndex then
					CloseInternetExplorer(nIndex)
				end
				
				LoginPassword.m_nSndaTime = nil
			end
		end
	
		if Login.m_bSndaBindCard then
			local nIndex = GetInternetExplorerIndexFromTitle("%[%d+%]")
			if nIndex then
				Login.m_bSndaBindCard = false
				LoginPassword.m_nSndaTime = GetTickCount()
			end
		end
	end
end;

OnFrameCreate=function()
	math.randomseed(GetCurrentTime())

	this:RegisterEvent("UI_SCALED")
	this:RegisterEvent("INTERACTION_REQUEST_RESULT")
	this:RegisterEvent("SDOA_INIT")
	this:RegisterEvent("SDOA_LOGIN")
	
	LoginPassword.OnEvent("UI_SCALED")
	
	LoginServerList.SetSelectedServer(g_tLoginData.szRegion or "", g_tLoginData.szServer or "")
	
	if g_tLoginData.szAccount then
		this:Lookup("WndPassword/Edit_Account"):SetText(g_tLoginData.szAccount)
	end
	local checkboxRememberAccount = this:Lookup("WndPassword"):Lookup("CheckBox_RememberAccount")
	checkboxRememberAccount.m_bManual = true
	checkboxRememberAccount:Check(g_tLoginData.bRememberAccount)
	checkboxRememberAccount.m_bManual = false

	this:Lookup("WndPassword"):Lookup("CheckBox_Keyboard"):Check(false)
	this:Lookup("WndKeyboard"):Hide()
	
	this:Lookup("WndVersion", "Text_Version"):SetText(LoginPassword.GetVersionString())
	
	Interaction_Request("TextFilter", tUrl.TextFilter, "", "", 80)

	local _,_,_,szVersionEx = GetVersion()
	if szVersionEx == "snda" then
		Station.Lookup("Normal/LoginPassword/WndPassword"):Hide()
	end
end;

UpdateSdoaLoginDialogSize=function()
	local _,_,_,szVersionEx = GetVersion()
	if szVersionEx == "snda" then
		local w, h = Station.GetClientSize(false)

		if SdoaWinExists("igwUserLoginDialog") then
			local extent = SdoaGetWinExtent("igwUserLoginDialog")
			if extent then
				extent.left = w / 2 - extent.width / 2
				extent.top = h / 2 - extent.height / 2
				SdoaSetWinExtent("igwUserLoginDialog", extent)
			end

			Login.UpdateSdoaTaskBarPosition("LOGIN")
		end
	end
end;

CommitShowSdoaLoginDialog=function()
	local _,_,_,szVersionEx = GetVersion()
	if szVersionEx == "snda" and LoginPassword.m_bSdoaInitFinished and LoginPassword.m_bSdoaShowLoginDialog then
		if SdoaWinExists("igwUserLoginDialog") then
			SdoaSetWinVisible("igwUserLoginDialog", true)
		else
			SdoaSetScreenStatus("mini")
			SdoaLogin()
			LoginPassword.UpdateSdoaLoginDialogSize()

			if not g_tLoginData.bAcceptEULA then
				Login.ShowSdoaWindows(false)
			end
		end
	end
end;

ShowSdoaLoginDialog=function()
	local _, _, _, _, nAreaID, nGroupID = LoginServerList.GetSelectedServer()

	if nAreaID and nGroupID then
		SdoaSetAreaInfo(nAreaID, nGroupID)
	end
	
	LoginPassword.m_bSdoaShowLoginDialog = true
	LoginPassword.CommitShowSdoaLoginDialog()
end;

OnEvent=function(event)
	if event == "UI_SCALED" then
		this:SetSize(Station.GetClientSize())
		
		local wndPassword = this:Lookup("WndPassword")
		wndPassword:SetPoint("CENTER", 0, 0, "CENTER", 0, 0)
		this:Lookup("WndOption"):SetPoint("BOTTOMRIGHT", -25, -58, "BOTTOMRIGHT", -25, -58)
		this:Lookup("WndBulletin"):SetPoint("TOPRIGHT", -20, 122, "TOPRIGHT", -20, 122)
		this:Lookup("WndVersion"):SetPoint("TOPRIGHT", -30, 25, "TOPRIGHT", -30, 25)
		this:Lookup("WndKeyboard"):SetPoint("TOPCENTER", 0, 0, wndPassword, "BOTTOMCENTER", 0, 70)
		this:Lookup("WndServer"):SetPoint("TOPRIGHT", -20, 50, "TOPRIGHT", -20, 50)
		this:Lookup("WndLogo"):SetPoint("BOTTOMLEFT", 15, -10, "BOTTOMLEFT", 15, -10)
		this:Lookup("WndKINGSOFT"):SetPoint("BOTTOMRIGHT", -35, -35, "BOTTOMRIGHT", -35, -35)	
		this:Lookup("WndAnnounce"):SetPoint("BOTTOMCENTER", 0, -10, "BOTTOMCENTER", 0, -10)	

		LoginPassword.UpdateSdoaLoginDialogSize()

	elseif event == "SDOA_INIT" then
		if arg0 == "FINISHED" then
			LoginPassword.m_bSdoaInitFinished = true
			LoginPassword.CommitShowSdoaLoginDialog()
		end
	elseif event == "SDOA_LOGIN" then
		LoginPassword.HandleSdoaLogin(arg0, arg1, arg2, arg3, arg4)
	elseif event == "INTERACTION_REQUEST_RESULT" then
		if arg0 == "Bulletin" and arg1 then
			local _, _, szBulletinType, szBulletinContent = string.find(arg2, "([^\n]*)\n(.*)")
			if not szBulletinType or not szBulletinContent then
				return
			end
            
        	local textBulletinType = this:Lookup("WndBulletin", "Text_BulletinType")
        	local handleBulletinMessage = this:Lookup("WndBulletin", "Handle_BulletinMessage")
        	
			szBulletinContent = "<text>text="..EncodeComponentsString(szBulletinContent).." font=18 </text>"
            
        	textBulletinType:SetText(szBulletinType)
        	
        	handleBulletinMessage:Clear()
        	handleBulletinMessage:AppendItemFromString(szBulletinContent)
        	handleBulletinMessage:FormatAllItemPos()
	        LoginPassword.UpdateScrollInfo(handleBulletinMessage)
	    elseif arg0 == "TextFilter" and arg1 then
	    	if arg2 then
	    		AddFilterText(arg2)
	    	end
	    end
	end
end;

OnLButtonClick=function()
	local szName = this:GetName()
	if szName == "Btn_OK" then
		LoginPassword.SaveAccountAndPassword()

		Login.StepNext()
	elseif szName == "Btn_OptionMovie" then
		OpenCGSelectPanel()
	elseif szName == "Btn_OptionStuff" then
		OpenCreditsPanel()
		--PlaySound(SOUND.UI_SOUND, g_sound.Button)
	elseif szName == "Btn_OptionQuit" then
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
		ExitGame()
	elseif szName == "Btn_OptionJX3URL" then
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
		OpenInternetExplorer(tUrl.OfficialWeb, true)
	elseif szName == "Btn_OptionRecharge" then
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
		OpenInternetExplorer(tUrl.Recharge, true)
	elseif szName == "Btn_OptionJoinUs" then
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
		OpenInternetExplorer(tUrl.JoinUs, true)
	elseif szName == "Btn_OptionService" then
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
		OpenInternetExplorer(tUrl.JX3Service, true)
	elseif szName == "Btn_Register" then
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
		OpenInternetExplorer(tUrl.Register, true)
	elseif szName == "Btn_FindPassword" then
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
		OpenInternetExplorer(tUrl.FindPassword, true)
	elseif szName == "Btn_KingsoftToken" then
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
		OpenInternetExplorer(tUrl.BindToken, true)
	elseif szName == "Btn_ChangeServer" then
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
		Login.ShowServerList()
	elseif szName == "Btn_ReadEULA" then
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
		Station.SetFocusWindow(this:GetRoot())
		this:GetRoot():FocusHome()
		Wnd.OpenWindow("EULAPanel")
	elseif szName == "Btn_KbRandom" then
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
		local wndKeyboard = this:GetRoot():Lookup("WndKeyboard")
		LoginPassword.ShuffleKeyboard()
		LoginPassword.UpdateKeyboard(wndKeyboard)
	elseif szName == "Btn_KbBackspace" then
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
		this:GetRoot():Lookup("WndPassword/Edit_Password"):Backspace()
		LoginPassword.UpdateButtonState()
	else
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
		local frame = this:GetRoot()
		local i = tonumber(string.sub(szName, string.len("Btn_Kb") + 1))
		local shift = frame:Lookup("WndKeyboard/CheckBox_KbShift"):IsCheckBoxChecked()
		local j = 1
		if shift then
			j = 2
		end
		frame:Lookup("WndPassword/Edit_Password"):InsertText(LoginPassword.m_keyboard[i][j])
		LoginPassword.UpdateButtonState()
    end
end;

OnLButtonHold=function()
	local szName = this:GetName()
	if szName == "Btn_Up" then
		this:GetParent():Lookup("Scroll_Bulletin"):ScrollPrev(1)
	elseif szName == "Btn_Down" then
		this:GetParent():Lookup("Scroll_Bulletin"):ScrollNext(1)
    end
end;

OnLButtonDown=function()
	LoginPassword.OnLButtonHold()
end;

OnLButtonUp=function()
	local szName = this:GetName()
	if szName == "Btn_Up" then
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
	elseif szName == "Btn_Down" then
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
    end
end;

OnItemMouseWheel=function()
	local szName = this:GetName()
	local nDistance = Station.GetMessageWheelDelta()
	if szName == "Handle_BulletinMessage" then
		this:GetParent():GetParent():Lookup("Scroll_Bulletin"):ScrollNext(nDistance)
	end
	return 1
end;

OnEditSpecialKeyDown=function()
	local szKey = GetKeyName(Station.GetMessageKey())
	local szName = this:GetName()
	if szName == "Edit_Account" then
		if szKey == "Enter" then
			this:GetRoot():FocusNext()
			return 1
		elseif szKey == "Down" then
			this:GetRoot():FocusNext()
			return 1
		elseif szKey == "Up" then
			this:GetRoot():FocusPrev()
			return 1
		end	
	elseif szName == "Edit_Password" then	
		if szKey == "Enter" then
			if Station.Lookup("Normal/LoginPassword/WndPassword/Btn_OK"):IsEnabled() then
				Login.StepNext()
			end
			return 1
		elseif szKey == "Down" then
			this:GetRoot():FocusNext()
			return 1
		elseif szKey == "Up" then
			this:GetRoot():FocusPrev()
			return 1
		end
	end
	
	return 0
end;

UpdateButtonState=function()
	local frame = Station.Lookup("Normal/LoginPassword/WndPassword")
	if frame then
		local nAccountText = frame:Lookup("Edit_Account"):GetTextLength()
		local nPasswordText = frame:Lookup("Edit_Password"):GetTextLength()
		if nAccountText > 3 and nPasswordText > 0 and g_tLoginData.bAcceptEULA then
			frame:Lookup("Btn_OK"):Enable(true)
		else
			frame:Lookup("Btn_OK"):Enable(false)
		end
	end
end;

OnEditChanged=function()
	local szName = this:GetName()
	if szName == "Edit_Account" or szName == "Edit_Password" then
		LoginPassword.UpdateButtonState()
	end
end;

OnScrollBarPosChanged=function()
	local szName = this:GetName()
	local nCurrentValue = this:GetScrollPos()
	
	local btnUp, btnDown, handle
	if szName == "Scroll_Bulletin" then
		btnUp = this:GetParent():Lookup("Btn_Up")
		btnDown = this:GetParent():Lookup("Btn_Down")
		handle = this:GetParent():Lookup("", "Handle_BulletinMessage")
	end
	
	if nCurrentValue == 0 then
		btnUp:Enable(false)
	else
		btnUp:Enable(true)
	end	
	
	if nCurrentValue == this:GetStepCount() then
		btnDown:Enable(false)
	else
		btnDown:Enable(true)
	end
	
	handle:SetItemStartRelPos(0, -nCurrentValue * 10)	
end;

UpdateScrollInfo=function(handle)
	handle:FormatAllItemPos()
	local w, h = handle:GetSize()
	local wAll, hAll = handle:GetAllItemSize()
	local nStep = (hAll - h) / 10
	local szName = handle:GetName()
	local wndRoot = handle:GetParent():GetParent()
	if szName == "Handle_BulletinMessage" then
		wndRoot:Lookup("Scroll_Bulletin"):SetStepCount(nStep)
		if nStep > 0 then
	    	wndRoot:Lookup("Scroll_Bulletin"):Show()
	    	wndRoot:Lookup("Btn_Up"):Show()
	    	wndRoot:Lookup("Btn_Down"):Show()
	    	wndRoot:Lookup("", "Image_ScrollBg"):Show()		
		else
	    	wndRoot:Lookup("Scroll_Bulletin"):Hide()
	    	wndRoot:Lookup("Btn_Up"):Hide()
	    	wndRoot:Lookup("Btn_Down"):Hide()
	    	wndRoot:Lookup("", "Image_ScrollBg"):Hide()
	    end
	end	
end;

OnCheckBoxCheck=function()
	PlaySound(SOUND.UI_SOUND, g_sound.Button)
	local szName = this:GetName()

	if szName == "CheckBox_RememberAccount" then
		if not this.m_bManual then
			local cx, cy = Station.GetClientSize()
			local msg = 
			{
				x = cx / 2;
				y = cy / 2;
				szName = "RememberAccountCheck";
				szMessage = g_tGlue.LOGIN_REMBEMBER_ACCOUNT_MSG;
				bModal = true;
	
				fnAction = function(nIndex)
					if nIndex == 1 then
						g_tLoginData.bRememberAccount = true
					elseif nIndex == 2 then
						local frame = Station.Lookup("Normal/LoginPassword/WndPassword")
						local checkboxRememberAccount = frame:Lookup("CheckBox_RememberAccount")
	
						g_tLoginData.bRememberAccount = false
						checkboxRememberAccount.m_bManual = true
						checkboxRememberAccount:Check(false)
						checkboxRememberAccount.m_bManual = false
						
						g_tLoginData.szRegion = ""
						g_tLoginData.szServer = ""
						g_tLoginData.szAccount = ""
					end
				end;
	
				{ szOption = g_tStrings.STR_PLAYER_SURE },
				{ szOption = g_tStrings.STR_PLAYER_CANCEL },
			};
			MessageBox(msg)
		end
	elseif szName == "CheckBox_Keyboard" then
		this:GetRoot():Lookup("WndKeyboard"):Show()
	elseif szName == "CheckBox_KbShift" then
		local wndKeyboard = this:GetRoot():Lookup("WndKeyboard")
		LoginPassword.UpdateKeyboard(wndKeyboard)
	elseif szName == "CheckBox_EULA" then
		LoginPassword.AcceptEULA(true)
		LoginPassword.UpdateButtonState()
	end
end;

OnCheckBoxUncheck=function()
	PlaySound(SOUND.UI_SOUND, g_sound.Button)
	local szName = this:GetName()

	if szName == "CheckBox_RememberAccount" then
		if not this.m_bManual then
			local cx, cy = Station.GetClientSize()
			local msg = 
			{
				x = cx / 2;
				y = cy / 2;
				szName = "RememberAccountUncheck";
				szMessage = g_tGlue.LOGIN_UNCHEDK_REMBEMBER_ACCOUNT;
				bModal = true;
	
				fnAction = function(nIndex)
					if nIndex == 1 then
						g_tLoginData.bRememberAccount = false
					elseif nIndex == 2 then
						local frame = Station.Lookup("Normal/LoginPassword/WndPassword")
						local checkboxRememberAccount = frame:Lookup("CheckBox_RememberAccount")
	
						g_tLoginData.bRememberAccount = true
						checkboxRememberAccount.m_bManual = true
						checkboxRememberAccount:Check(true)
						checkboxRememberAccount.m_bManual = false
					end
				end;
	
				{ szOption = g_tStrings.STR_PLAYER_SURE },
				{ szOption = g_tStrings.STR_PLAYER_CANCEL },
			};
			MessageBox(msg)
		end
	elseif szName == "CheckBox_Keyboard" then
		this:GetRoot():Lookup("WndKeyboard"):Hide()
	elseif szName == "CheckBox_KbShift" then
		local wndKeyboard = this:GetRoot():Lookup("WndKeyboard")
		LoginPassword.UpdateKeyboard(wndKeyboard)
	elseif szName == "CheckBox_EULA" then
		LoginPassword.AcceptEULA(false)
		LoginPassword.UpdateButtonState()
	end
end;

SaveAccountAndPassword=function()
	local _,_,_,szVersionEx = GetVersion()
	if szVersionEx ~= "snda" then
		local frame = Station.Lookup("Normal/LoginPassword/WndPassword")
		Login.m_szAccount = frame:Lookup("Edit_Account"):GetText()
		Login.m_szPasswordLen = frame:Lookup("Edit_Password"):GetTextLength()
		Login.m_szPassword = "Normal/LoginPassword/WndPassword/Edit_Password" 
	end
end;

ClearAccount=function()
	local frame = Station.Lookup("Normal/LoginPassword/WndPassword")
	frame:Lookup("Edit_Account"):SetText("")
end;

ClearPassword=function()
	local frame = Station.Lookup("Normal/LoginPassword/WndPassword")
	if frame then
		frame:Lookup("Edit_Password"):SetText("")
	end
end;

GetVersionString=function()
	local szVersionLineFullName, szVersion, szVersionLineName = GetVersion()
	return g_tGlue.tLoginString["VERSION"]..szVersion
end;

ShowSdoaLoginErrorMessage=function(szErrorCode)
	local nWidth, nHeight = Station.GetClientSize()
	local tMsg =
	{
		x = nWidth / 2, y = nHeight / 2,
		szMessage = szErrorCode,
		szName = "SdoaLoginErrorMessage",
		{
			szOption = g_tGlue.STR_HOTKEY_OK,
		},
	}
	MessageBox(tMsg)
end;


HandleSdoaLogin=function(szErrorCode, szSessionId, szSndaId, szIdentityState, szAppendix)
	if szErrorCode == "OK" then
		Login_SetSndaIDToken(szSndaId, szSessionId)

		Login.m_szAccount = szSndaId
		Login.m_szPasswordLen = 0
		Login.m_szPassword = "" 

		Login.StepNext()
	elseif szErrorCode == "CANCEL" then
		OpenExitPanel("loginclose")
	end
end;
};
