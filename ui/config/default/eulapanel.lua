EULAPanel={

m_pFocusWindow = nil;

OnFrameCreate=function()
	this:RegisterEvent("UI_SCALED")
	EULAPanel.OnEvent("UI_SCALED")

	local handleMessage = this:Lookup("WndEULA", "Handle_EULAMessage")
	handleMessage:AppendItemFromString(GetEULAText())
	handleMessage:FormatAllItemPos()

	EULAPanel.UpdateScrollInfo(handleMessage)
end;

OnFrameShow=function()
	EULAPanel.UpdateEULA()
	EULAPanel.UpdateButtonState()

	EULAPanel.m_pFocusWindow = Station.GetFocusWindow()
end;

OnFrameHide=function()
	if EULAPanel.m_pFocusWindow and EULAPanel.m_pFocusWindow:IsValid() then
		Station.SetFocusWindow(EULAPanel.m_pFocusWindow)
	end
end;

OnEvent=function(event)
	if event == "UI_SCALED" then
		this:SetSize(Station.GetClientSize())
		this:Lookup("WndEULA"):SetPoint("CENTER", 0, 0, "CENTER", 0, 0)
	end
end;

OnLButtonClick=function()
	PlaySound(SOUND.UI_SOUND, g_sound.Button)

	local szName = this:GetName()
	if szName == "Btn_Sure" then
		Wnd.CloseWindow("EULAPanel")
	elseif szName == "Btn_Cancel" then
		LoginPassword.AcceptEULA(false)

		local _,_,_,szVersionType = GetVersion()
		if szVersionType == "snda" then
			if not g_tLoginData.bAcceptEULA then
				ExitGame()
			end
		else
			EULAPanel.UpdateButtonState()
			LoginPassword.UpdateEULA()
			LoginPassword.UpdateButtonState()
			Wnd.CloseWindow("EULAPanel")
		end
	end
end;

OnCheckBoxCheck=function()
	PlaySound(SOUND.UI_SOUND, g_sound.Button)

	local szName = this:GetName()
	if szName == "CheckBox_Agree" then
		LoginPassword.AcceptEULA(true)
	end

	EULAPanel.UpdateButtonState()
	LoginPassword.UpdateEULA()
	LoginPassword.UpdateButtonState()
end;

OnCheckBoxUncheck=function()
	PlaySound(SOUND.UI_SOUND, g_sound.Button)

	local szName = this:GetName()
	if szName == "CheckBox_Agree" then
		LoginPassword.AcceptEULA(false)
	end

	EULAPanel.UpdateButtonState()
	LoginPassword.UpdateEULA()
	LoginPassword.UpdateButtonState()
end;

UpdateEULA=function()
	local checkboxEULA = Station.Lookup("Topmost/EULAPanel/WndEULA/CheckBox_Agree")
	checkboxEULA:Check(g_tLoginData.bAcceptEULA)
end;

UpdateButtonState=function()
	local btnSure = this:GetRoot():Lookup("WndEULA/Btn_Sure")
	btnSure:Enable(g_tLoginData.bAcceptEULA)
end;

OnLButtonHold=function()
	local szName = this:GetName()
	if szName == "Btn_Up" then
		this:GetParent():Lookup("Scroll_EULA"):ScrollPrev(1)
	elseif szName == "Btn_Down" then
		this:GetParent():Lookup("Scroll_EULA"):ScrollNext(1)
    end
end;

OnLButtonDown=function()
	EULAPanel.OnLButtonHold()
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
	if szName == "Handle_EULAMessage" then
		this:GetParent():GetParent():Lookup("Scroll_EULA"):ScrollNext(nDistance)
	end
	return 1
end;

OnScrollBarPosChanged=function()
	local szName = this:GetName()
	local nCurrentValue = this:GetScrollPos()
	
	local btnUp, btnDown, handle
	if szName == "Scroll_EULA" then
		btnUp = this:GetParent():Lookup("Btn_Up")
		btnDown = this:GetParent():Lookup("Btn_Down")
		handle = this:GetParent():Lookup("", "Handle_EULAMessage")
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
	if szName == "Handle_EULAMessage" then
		wndRoot:Lookup("Scroll_EULA"):SetStepCount(nStep)
		if nStep > 0 then
	    	wndRoot:Lookup("Scroll_EULA"):Show()
	    	wndRoot:Lookup("Btn_Up"):Show()
	    	wndRoot:Lookup("Btn_Down"):Show()
	    	wndRoot:Lookup("", "Image_ScrollBg"):Show()		
		else
	    	wndRoot:Lookup("Scroll_EULA"):Hide()
	    	wndRoot:Lookup("Btn_Up"):Hide()
	    	wndRoot:Lookup("Btn_Down"):Hide()
	    	wndRoot:Lookup("", "Image_ScrollBg"):Hide()
	    end
	end	
end;

};

