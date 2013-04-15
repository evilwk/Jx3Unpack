Queue={

m_pFocusWindow=nil;
	
OnFrameKeyDown=function()
	local szKey = GetKeyName(Station.GetMessageKey())
	if szKey == "ESC" then
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
		this:Hide()
		Login_GiveupQueue()
	end
	return 1
end;

OnFrameCreate=function()
	this:RegisterEvent("UI_SCALED")
	this:RegisterEvent("LOGIN_QUEUE_STATE")
	Queue.OnEvent("UI_SCALED")
end;

OnFrameShow=function()
	local frameMessage=Station.Lookup("Topmost/LoginMessage")
	if frameMessage and frameMessage:IsVisible() then
		frameMessage:Hide()
	end
	local frameWaiting=Station.Lookup("Topmost/LoginWaiting")
	if frameWaiting and frameWaiting:IsVisible() then
		frameWaiting:Hide()
	end
	
	Queue.m_pFocusWindow=Station.GetFocusWindow()

	this:BringToTop()
	Station.SetFocusWindow(this)
end;

OnFrameHide=function()
	if Queue.m_pFocusWindow and Queue.m_pFocusWindow:IsValid() then
		Station.SetFocusWindow(Queue.m_pFocusWindow)
	end
end;

OnEvent=function(event)
	if event == "LOGIN_QUEUE_STATE" then 
		local textQueue = this:Lookup("Wnd_Queue", "Text_Queue")
		textQueue:SetText(tostring(arg0 + 1))

		local frameQueue = this:GetRoot()
		if not frameQueue:IsVisible() then
			frameQueue:Show()
		end
	elseif event == "UI_SCALED" then
		local wnd = this:Lookup("Wnd_Queue")
		if wnd then
			local w, h = wnd:GetSize()
			local wAll, hAll = Station.GetClientSize()
			wnd:SetRelPos((wAll - w) / 2, (hAll - h) / 2)
			this:SetSize(wAll, hAll)
		end
	end
end;

OnLButtonClick=function()
	local szName = this:GetName()
	if szName == "Btn_Cancel" then
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
	    local nWidth, nHeight = Station.GetClientSize()
		local tMsg =
		{
		    x = nWidth / 2, y = nHeight / 2,
			szMessage = g_tGlue.STR_GIVEUP_QUEUE_SURE,
			szName = "GiveupQueue",
			fnAutoClose = function() return IsInLoading() end,
			{szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = function() Login_GiveupQueue() end },
			{szOption = g_tStrings.STR_HOTKEY_CANCEL},
		}
		MessageBox(tMsg)
	end
end;


}

function IsQueueOpened()
	local hQueue = Station.Lookup("Topmost/Queue")
	return hQueue and hQueue.IsVisible()
end	
