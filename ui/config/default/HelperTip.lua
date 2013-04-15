HelperTip = {}

function HelperTip.OnFrameCreate()
	this:RegisterEvent("HELP_PANEL_SHOW_INFO_CHANGED")
end

function HelperTip.UpdateContent(hFrame, szMessage)
	local hWnd = hFrame:Lookup("Wnd_HelperTip")
	local hContent = hWnd:Lookup("", "Handle_Message")
	hContent:Clear()
	hContent:AppendItemFromString(szMessage)
	hContent:FormatAllItemPos()
end

function HelperTip.OnEvent(szEvent)
	if szEvent == "HELP_PANEL_SHOW_INFO_CHANGED" then
		if not IsShowHelpPanel() then
			CloseHelperTipPanel(true)
		end
	end
end

function HelperTip.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_Close" then
		CloseHelperTipPanel()
	end
end

function OpenHelperTipPanel(szMessage)
	if not IsShowHelpPanel() then
		return
	end
	
	if not IsHelperTipPanelOpened() then
		Wnd.OpenWindow("HelperTip")	
	end
	
	local hFrame = Station.Lookup("Normal/HelperTip")
	hFrame:BringToTop()
	
	HelperTip.UpdateContent(hFrame, szMessage)
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
end

function IsHelperTipPanelOpened()
	local hFrame = Station.Lookup("Normal/HelperTip")
	if hFrame then
		return true
	end
	
	return false
end

function CloseHelperTipPanel(bDisableSound)
	if not IsHelperTipPanelOpened() then
		return 
	end
	
	Wnd.CloseWindow("HelperTip")
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end	
end
