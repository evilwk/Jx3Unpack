LoginRename={

m_pFocusWindow = nil;

OnFrameCreate=function()
	this:RegisterEvent("UI_SCALED")
	LoginRename.OnEvent("UI_SCALED")
end;

OnFrameShow=function()
	LoginRename.m_pFocusWindow = Station.GetFocusWindow()

	Station.SetFocusWindow("Topmost/LoginRename")
	this:FocusHome()
end;

OnFrameHide=function()
	if LoginRename.m_pFocusWindow and LoginRename.m_pFocusWindow:IsValid() then
		Station.SetFocusWindow(LoginRename.m_pFocusWindow)
	end
end;

OnEvent=function(event)
	if event == "UI_SCALED" then
		this:SetSize(Station.GetClientSize())
		this:Lookup("Wnd_Rename"):SetPoint("CENTER", 0, -70, "CENTER", 0, 0)
	end
end;

OnLButtonClick=function()
	PlaySound(SOUND.UI_SOUND, g_sound.Button)

	local szName = this:GetName()
	if szName == "Btn_OK" then
		EditAnswer = this:GetParent():Lookup("Edit_Answer")
		nRoleNameLength = EditAnswer:GetTextLength()
		szRoleName = EditAnswer:GetText()
		
		if Login.CheckRoleName(nRoleNameLength, szRoleName) then
			Login_Rename(LoginRename.szOldRoleName, szRoleName)
		end
	elseif szName == "Btn_Cancel" then
		CloseLoginRename()
		Login.StepNext()
	elseif szName == "Btn_Close" then
		CloseLoginRename()
	end
end;

OnCheckBoxCheck=function()
	if this:GetName() == "CheckBox_HideTip" then
		g_tLoginRenameHideTip[LoginRename.szOldRoleName] = true
	end
	
	PlaySound(SOUND.UI_SOUND, g_sound.Button)
end;

OnCheckBoxUncheck=function()
	if this:GetName() == "CheckBox_HideTip" then
		g_tLoginRenameHideTip[LoginRename.szOldRoleName] = false
	end
	
	PlaySound(SOUND.UI_SOUND, g_sound.Button)
end;

OnEditSpecialKeyDown=function()
	local szKey = GetKeyName(Station.GetMessageKey())
	
	if szKey == "Esc" then
		CloseLoginRename()
		return 1
	end
	
	return 0
end;

};

OpenLoginRename = function(szRoleName, bDisableSound)
	if IsLoginRenameOpened() then
		return
	end
	
	if not szRoleName or szRoleName == "" then
		return
	end
	
	LoginRename.szOldRoleName = szRoleName
	
	local frame = Station.Lookup("Topmost/LoginRename")
	if not frame then
		frame = Wnd.OpenWindow("LoginRename")
	end
	frame:Show()
	
	frame:Lookup("Wnd_Rename", "Text_Message"):SetText(g_tGlue.STR_LOGIN_RENAME)
	
	if g_tLoginRenameHideTip[LoginRename.szOldRoleName] then
		frame:Lookup("Wnd_Rename"):Lookup("CheckBox_HideTip"):Check(true)
	else
		frame:Lookup("Wnd_Rename"):Lookup("CheckBox_HideTip"):Check(false)
	end
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
end;

IsLoginRenameOpened = function()
	local frame = Station.Lookup("Topmost/LoginRename")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end;

CloseLoginRename = function(bDisableSound)
	if not IsLoginRenameOpened() then
		return
	end
	
	local frame = Station.Lookup("Topmost/LoginRename")
	frame:Hide()
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end
end;
