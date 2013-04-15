DropLinePanel = {}

function DropLinePanel.OnFrameCreate()
	this:RegisterEvent("UI_SCALED")
	DropLinePanel.OnEvent("UI_SCALED")	
	this:Lookup("Wnd_All", "Text_Msg"):SetText(g_tStrings.STR_MSG_LOGIN_DROPLINE)
end

function DropLinePanel.OnEvent(event)
	if event == "UI_SCALED" then
		local wnd = this:Lookup("Wnd_All")
		if wnd then
			local w, h = wnd:GetSize()
			local wAll, hAll = Station.GetClientSize()
			wnd:SetRelPos((wAll - w) / 2, (hAll - h) / 2)
			this:SetSize(wAll, hAll)
		end
	end
end

function DropLinePanel.OnFrameKeyDown()
	return true
end

function DropLinePanel.OnLButtonDown()
	local szName = this:GetName()
	if szName == "Btn_ReLink" then 
		PlaySound(SOUND.UI_SOUND, g_sound.CloseFrame)
	elseif szName == "Btn_ReturnLogin" then
		PlaySound(SOUND.UI_SOUND, g_sound.CloseFrame)
		ReInitUI(LOAD_LOGIN_REASON.RETURN_GAME_LOGIN)
	elseif szName == "Btn_ExitGame" then
		PlaySound(SOUND.UI_SOUND, g_sound.CloseFrame)
    	ExitGame()
    end
end

function OpenDropLinePanel()
	if Station.Lookup("Topmost2/DropLinePanel") then
		return
	end
	local frame = Wnd.OpenWindow("DropLinePanel")
	Station.SetFocusWindow(frame)
	PlaySound(SOUND.UI_SOUND, g_sound.OpenFrame)
end

function IsDropLinePanelOpened()
	local frame = Station.Lookup("Topmost2/DropLinePanel")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end
