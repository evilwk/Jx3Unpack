ExitPanel = {}

function ExitPanel.OnFrameCreate()
	this:RegisterEvent("UI_SCALED")
	this:RegisterEvent("FIGHT_HINT")
	ExitPanel.OnEvent("UI_SCALED")	
	Station.SetFocusWindow(this)
end

function ExitPanel.OnFrameKeyDown()
	local szKey = GetKeyName(Station.GetMessageKey())
	if szKey == "Esc" then
		CloseExitPanel()
		return 1
	end
	return 0
end

function ExitPanel.OnEvent(event)
	if event == "UI_SCALED" then
		this:SetPoint("TOPCENTER", 0, 0, "TOPCENTER", 0, 360)
		ExitPanel.UpdateBgImageSize(this)		
	elseif event == "FIGHT_HINT" then
		if arg0 then
			CloseExitPanel()
		end
	end
end

function ExitPanel.UpdateBgImageSize(frame)
	local handle = this:Lookup("", "")
	local img = handle:Lookup("Image_Back")
	img:SetSize(Station.GetClientSize())
	local x, y = handle:GetAbsPos()
	img:SetRelPos(-x, -y)
	handle:FormatAllItemPos()
end

function ExitPanel.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_Sure" then
		if ExitPanel.szReason == "returntologin" then
			ReInitUI(LOAD_LOGIN_REASON.RETURN_GAME_LOGIN)
		elseif ExitPanel.szReason == "returntorole" then
			ReInitUI(LOAD_LOGIN_REASON.RETURN_ROLE_LIST)
		else
			ExitGame()
		end
	elseif szName == "Btn_Cancel" then
		CloseExitPanel()

		if ExitPanel.szReason == "loginclose" then
			local _,_,_,szVersionEx = GetVersion()
			if szVersionEx == "snda" then
				if Login.m_StateLeaveFunction == Login.LeavePassword then
					Login.ShowSdoaWindows(true)
				end
			end	
		end
	end
end

function OpenExitPanel(szReason, bDisableSound)
	ExitPanel.szReason = szReason
	local frame = Wnd.OpenWindow("ExitPanel")

	if szReason == "close" then
		frame:Lookup("", "Text_ExitGame"):SetText(g_tStrings.EXIT_QUIT) 
	elseif szReason == "loginclose" then
		local _,_,_,szVersionEx = GetVersion()
		if szVersionEx == "snda" then
			if Login.m_StateLeaveFunction == Login.LeavePassword then
				Login.ShowSdoaWindows(false)
			end
		end	
		frame:Lookup("", "Text_ExitGame"):SetText(g_tStrings.EXIT_LOGIN_QUIT)
	elseif szReason == "returntologin" then
		frame:Lookup("", "Text_ExitGame"):SetText(g_tStrings.EXIT_RETURN_LOGIN)
	elseif szReason == "returntorole" then
		frame:Lookup("", "Text_ExitGame"):SetText(g_tStrings.EXIT_RETURN_CHOOSE)
	end
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
end

function IsExitPanelOpened()
	local frame = Station.Lookup("Topmost2/ExitPanel")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end

function CloseExitPanel(bDisableSound)
	Wnd.CloseWindow("ExitPanel")
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
end
