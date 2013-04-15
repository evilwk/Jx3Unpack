LoginTokenPanel = {}

function LoginTokenPanel.OnFrameCreate()
	this:RegisterEvent("UI_SCALED")
	LoginTokenPanel.OnEvent("UI_SCALED")
end

function LoginTokenPanel.OnFrameShow()
	local focus = Station.GetFocusWindow()
	if focus and focus:IsValid() and focus:GetRoot():GetName() == "LoginMessage" then
		focus:Hide()
		Station.SetFocusWindow(this)
		this:FocusHome()
		focus:Show()
	else
		Station.SetFocusWindow(this:Lookup("Wnd_All/Edit_Password"))
	end
end

function LoginTokenPanel.OnEvent(event)
	if event == "UI_SCALED" then
		this:SetSize(Station.GetClientSize())
		
		local wndAll = this:Lookup("Wnd_All")
		wndAll:SetPoint("CENTER", 0, 0, "CENTER", 0, 0)
	end
end

function LoginTokenPanel.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_OK" then
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
		local szCode = this:GetParent():Lookup("Edit_Password"):GetText()
		Login_MibaoVerify(szCode)
	elseif szName == "Btn_Cancel" then
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
		this:GetParent():Lookup("Edit_Password"):SetText("")
		Login.HideLoginTokenPanel()
		Login.EnterPassword()
	end
end

function LoginTokenPanel.ShowErrorCode(szErrorCode)
	local nWidth, nHeight = Station.GetClientSize()
	local tMsg =
	{
		x = nWidth / 2, y = nHeight / 2,
		szMessage = szErrorCode,
		szName = "TokenError",
		fnAutoClose = function() return IsInLoading() end,
		{
		    szOption = g_tStrings.STR_HOTKEY_SURE,
		    fnAction = function()
				local frame = Station.Lookup("Topmost/LoginTokenPanel/Wnd_All")
				if frame then
					frame:Lookup("Edit_Password"):SetText("")
				end    	
		    end
		},
	}
	MessageBox(tMsg)
end

function LoginTokenPanel.OnEditChanged()
	local szName = this:GetName()
	if szName == "Edit_Password" then
		LoginTokenPanel.UpdateButtonState()
	end
end;

function LoginTokenPanel.UpdateButtonState()
	local frame = Station.Lookup("Topmost/LoginTokenPanel")
	if frame then
		local nPasswordText = frame:Lookup("Wnd_All/Edit_Password"):GetTextLength()
		if nPasswordText == 6 or nPasswordText == 8 then
			frame:Lookup("Wnd_All/Btn_OK"):Enable(true)
		else
			frame:Lookup("Wnd_All/Btn_OK"):Enable(false)
		end
	end
end;
