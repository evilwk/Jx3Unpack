LoginWaiting={

m_pFocusWindow=nil;
	
OnFrameKeyDown=function()
	local szKey = GetKeyName(Station.GetMessageKey())
	if szKey == "ESC" then
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
		this:Hide()
		Login_CancelLogin()
	end
	return 1
end;

OnFrameCreate=function()
	this:RegisterEvent("UI_SCALED")
	LoginWaiting.OnEvent("UI_SCALED")
end;

OnFrameShow=function()
	local frameMessage=Station.Lookup("Topmost/LoginMessage")
	if frameMessage and frameMessage:IsVisible() then
		frameMessage:Hide()
	end
	local frameQueue=Station.Lookup("Topmost/Queue")
	if frameQueue and frameQueue:IsVisible() then
		frameQueue:Hide()
	end
	
	LoginWaiting.m_pFocusWindow=Station.GetFocusWindow()

	this:BringToTop()
	Station.SetFocusWindow(this)
end;

OnFrameHide=function()
	if LoginWaiting.m_pFocusWindow and LoginWaiting.m_pFocusWindow:IsValid() then
		Station.SetFocusWindow(LoginWaiting.m_pFocusWindow)
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
		end
	end
end;

}
