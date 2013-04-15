KeyPanel={

OnFrameCreate=function()
	this:RegisterEvent("ACTIVITY_PASSWORD_RESULT")
	this:RegisterEvent("ACTIVITY_PASSWORD_URL_RECIVE")
	this:RegisterEvent("UI_SCALED")
	
	KeyPanel.OnEvent("UI_SCALED")
end;

OnFrameShow=function()
	this:Lookup("Edit_Key"):SetText("")
end;

OnEvent=function(event)
	if event == "UI_SCALED" then
		this:SetPoint("CENTER", 0, -70, "CENTER", 0, 0)
	elseif event == "ACTIVITY_PASSWORD_RESULT" then
		KeyPanel.ShowResult(arg0)
	elseif event == "ACTIVITY_PASSWORD_URL_RECIVE" then
		OpenInternetExplorer(arg0, true)
	end
end;

OnLButtonClick=function()
	PlaySound(SOUND.UI_SOUND, g_sound.Button)

	local szName = this:GetName()
	if szName == "Btn_Sure" then
		local EditKey = this:GetParent():Lookup("Edit_Key")
		local szKey = EditKey:GetText()
		
		RemoteCallToServer("OnActivityPasswordReceived", szKey, 1)
	elseif szName == "Btn_Msg" then
		local EditKey = this:GetParent():Lookup("Edit_Key")
		local szKey = EditKey:GetText()
		
		RemoteCallToServer("OnActivityPasswordReceived", szKey, 0)
	elseif szName == "Btn_Cancel" then
		CloseKeyPanel()
	elseif szName == "Btn_Close" then
		CloseKeyPanel()
	end
end;

ShowResult = function(szResult)
	local nWidth, nHeight = Station.GetClientSize()
	local tMsg =
	{
		x = nWidth / 2, y = nHeight / 2,
		szMessage = g_tStrings.tActivityPasswordResult[szResult] or "",
		szName = "ActivityPasswordResult",
		{
		    szOption = g_tStrings.STR_HOTKEY_SURE,
		    fnAction = function()	
				if szResult == "Success" then
					CloseKeyPanel()
				end
		    end
		},
	}
	MessageBox(tMsg)
end;

};

OpenKeyPanel = function(bDisableSound)
	if IsKeyPanelOpened() then
		return
	end
	
	local frame = Station.Lookup("Normal/KeyPanel")
	if not frame then
		frame = Wnd.OpenWindow("KeyPanel")
	end
	frame:Show()
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
end;

IsKeyPanelOpened = function()
	local frame = Station.Lookup("Normal/KeyPanel")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end;

CloseKeyPanel = function(bDisableSound)
	if not IsKeyPanelOpened() then
		return
	end
	
	local frame = Station.Lookup("Normal/KeyPanel")
	frame:Hide()
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end
end;
