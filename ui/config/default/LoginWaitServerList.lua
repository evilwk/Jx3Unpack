LoginWaitServerList={
	m_nTime=0;
	m_nReloginCount = 0;

OnFrameCreate=function()
	this:RegisterEvent("UI_SCALED")
	LoginWaitServerList.OnEvent("UI_SCALED")
end;

OnFrameBreathe=function()
	local nTime = GetTickCount()
	if nTime >= LoginWaitServerList.m_nTime then
		if LoginWaitServerList.m_nReloginCount < 3 then
			LoginServerList.RequestRemoteServerList()
			LoginWaitServerList.m_nReloginCount = LoginWaitServerList.m_nReloginCount + 1
			LoginWaitServerList.m_nTime = GetTickCount() + 10000
		else
			LoginServerList.HandleInteractionRequestResult()
		end
	end
end;

OnFrameShow=function()
	this:BringToTop()
end;

OnFrameHide=function()
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

}
