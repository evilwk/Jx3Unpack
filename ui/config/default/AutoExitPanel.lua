local RETURN_LOGIN_INTERVAL = 5 * 60 * 1000

AutoExitPanel = {}

function AutoExitPanel.OnFrameCreate()
	this:RegisterEvent("UI_SCALED")
	
	AutoExitPanel.UpdateScaled()	
	Station.SetFocusWindow(this)
end

function AutoExitPanel.OnEvent(event)
	if event == "UI_SCALED" then
		AutoExitPanel.UpdateScaled()
	end
end

function AutoExitPanel.UpdateScaled()
	this:SetPoint("CENTER", 0, 0, "CENTER", 0, 0)
end
function AutoExitPanel.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_Cancel" then
		CloseAutoExitPanel()
	end
end

function AutoExitPanel.OnFrameBreathe()
	local nInterval = GetTickCount() - this.dwStartTime
	
	if nInterval < RETURN_LOGIN_INTERVAL then
		local szCountDownTime = ""
		local nTime = math.floor((RETURN_LOGIN_INTERVAL - nInterval) / 1000)
		
		local nMinute = math.floor(nTime / 60)
		local  nSecond = nTime - nMinute * 60
		
		szCountDownTime = string.format("%d%d:%d%d", math.floor(nMinute / 10), nMinute % 10 , math.floor(nSecond / 10), nSecond % 10)
		
		this:Lookup("", "Text_CountDown"):SetText(szCountDownTime)
	else
		FireDataAnalysisEvent("PLAYER_AUTO_EXIT")
		ReInitUI(LOAD_LOGIN_REASON.AUTO_EXIT)
	end
end

function OpenAutoExitPanel(bDisableSound)
	local hFrame = Wnd.OpenWindow("AutoExitPanel")
	hFrame:Lookup("", "Text_AutoExit"):SetText(g_tStrings.MSG_AUTO_EXIT)
	hFrame.dwStartTime = GetTickCount()
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
end

function IsAutoExitPanelOpened()
	local hFrame = Station.Lookup("Topmost2/AutoExitPanel")
	return hFrame and hFrame:IsVisible() 
end

function CloseAutoExitPanel(bDisableSound)
	Wnd.CloseWindow("AutoExitPanel")
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
end