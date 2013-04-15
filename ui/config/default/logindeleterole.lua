LoginDeleteRole={

m_pFocusWindow = nil;
	
GetQuestion=function()
	local n = math.random(#g_tGlue.tLoginDeleteRoleQuestions)
	return g_tGlue.tLoginDeleteRoleQuestions[n]
end;

OnFrameCreate=function()
	this:RegisterEvent("UI_SCALED")
	LoginDeleteRole.OnEvent("UI_SCALED")
end;

OnFrameShow=function()
	LoginDeleteRole.UpdateButtonState()
	LoginDeleteRole.UpdateQuestion()
	LoginDeleteRole.UpdateRoleName()
	LoginDeleteRole.UpdateTip()

	LoginDeleteRole.m_pFocusWindow = Station.GetFocusWindow()

	Station.SetFocusWindow("Topmost/LoginDeleteRole")
	this:FocusHome()
end;

OnFrameHide=function()
	if LoginDeleteRole.m_pFocusWindow and LoginDeleteRole.m_pFocusWindow:IsValid() then
		Station.SetFocusWindow(LoginDeleteRole.m_pFocusWindow)
	end
end;

OnEvent=function(event)
	if event == "UI_SCALED" then
		this:SetSize(Station.GetClientSize())
		this:Lookup("WndDeleteRole"):SetPoint("CENTER", 0, -70, "CENTER", 0, 0)
	end
end;

DeleteRole=function()
	local szAnswer = LoginDeleteRole.GetAnswer()
	if szAnswer then
		local szQuestion = this:GetRoot():Lookup("WndDeleteRole", "Text_Question"):GetText()
		if szAnswer == szQuestion then
			local re = LoginRoleList.m_aRoleEquip[LoginRoleList.m_nSelectIndex + 1]
			Login.BeginWait(g_tGlue.tLoginString["DELETING_ROLE"])
			Login_DeleteRole(re["RoleName"], re["RoleName"])
		
			Wnd.CloseWindow("LoginDeleteRole")
		else
			LoginMessage.ShowMessage(g_tGlue.tLoginString["ANSWER_ERROR"])
		end
	else
		LoginMessage.ShowMessage(g_tGlue.tLoginString["ANSWER_CANNOT_EMPTY"])
	end
end;

OnLButtonClick=function()
	PlaySound(SOUND.UI_SOUND, g_sound.Button)

	local szName = this:GetName()
	if szName == "Btn_OK" then
		LoginDeleteRole.DeleteRole()
	elseif szName == "Btn_Cancel" then
		Wnd.CloseWindow("LoginDeleteRole")
	end
end;

OnEditSpecialKeyDown=function()
	local szKey = GetKeyName(Station.GetMessageKey())
	local szName = this:GetName()
	if szName == "Edit_Answer" then
		if szKey == "Enter" then
			if Station.Lookup("Topmost/LoginDeleteRole/WndDeleteRole/Btn_OK"):IsEnabled() then
				LoginDeleteRole.DeleteRole()
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
	
	if szKey == "Esc" then
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
		Wnd.CloseWindow("LoginDeleteRole")
		return 1
	end
	
	return 0
end;

OnEditChanged=function()
	local szName = this:GetName()
	if szName == "Edit_Answer" then
		LoginDeleteRole.UpdateButtonState()
	end
end;

UpdateButtonState=function()
	local frame = Station.Lookup("Topmost/LoginDeleteRole/WndDeleteRole")
	if frame then
		local nAnswerText = frame:Lookup("Edit_Answer"):GetTextLength()
		if nAnswerText > 1 then
			frame:Lookup("Btn_OK"):Enable(true)
		else
			frame:Lookup("Btn_OK"):Enable(false)
		end
	end
end;

UpdateRoleName=function()
	local re = LoginRoleList.m_aRoleEquip[LoginRoleList.m_nSelectIndex + 1]
	local sz = re["RoleName"].."("..re["RoleLevel"]..g_tStrings.STR_LEVEL..")"
	this:GetRoot():Lookup("WndDeleteRole", "Text_RoleName"):SetText(sz)
end;

UpdateTip=function()
	local nRoleLevel = LoginRoleList.m_aRoleEquip[LoginRoleList.m_nSelectIndex + 1]["RoleLevel"]
	local szTip = ""
	if nRoleLevel >= 20 then
		szTip = g_tGlue.STR_DELETE_ROLE_TIP1
	else
		szTip = g_tGlue.STR_DELETE_ROLE_TIP2
	end
	this:GetRoot():Lookup("WndDeleteRole", "Text_Lv20Message"):SetText(szTip)
end;

UpdateQuestion=function()
	local szQuestion = LoginDeleteRole.GetQuestion()
	this:GetRoot():Lookup("WndDeleteRole", "Text_Question"):SetText(szQuestion)
end;

GetAnswer=function()
	local frame = Station.Lookup("Topmost/LoginDeleteRole/WndDeleteRole")
	local szAnswer = frame:Lookup("Edit_Answer"):GetText()

	if szAnswer == "" then
		szAnswer = nil
	end

	return szAnswer
end;

};

