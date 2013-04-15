local COUNT_DOWN_TIME = 1000 * 10

CheatWarningPanel = {}

function CheatWarningPanel.OnFrameCreate()
	this:RegisterEvent("UI_SCALED")
	CheatWarningPanel.UpdatePos(this)
	
	this.dwStartTime = GetTickCount()
end

function CheatWarningPanel.OnFrameBreathe()
	if not this.dwStartTime then
		return
	end
	
	local dwTime = GetTickCount() - this.dwStartTime
	local hBtn = this:Lookup("Btn_Sure")
	local hText = hBtn:Lookup("", "Text_Sure")
	if dwTime < COUNT_DOWN_TIME then
		local nTime = math.floor((COUNT_DOWN_TIME - dwTime) / 1000)
		hBtn:Enable(false)
		hText:SetText(g_tStrings.STR_HOTKEY_SURE .. " " .. nTime)
		return
	end
	
	hBtn:Enable(true)
	hText:SetText(g_tStrings.STR_HOTKEY_SURE)
	this.dwStartTime = nil
end

function CheatWarningPanel.OnEvent(szEvent)
	if szEvent == "UI_SCALED" then
		CheatWarningPanel.UpdatePos(this)
	end
end

function CheatWarningPanel.UpdatePos(hFrame)
	local fWidthAll, fHeightAll = Station.GetClientSize()
	local fPosX, fPosY = hFrame:GetAbsPos()
	local fWidth, fHeight = hFrame:GetSize()
	
	hFrame:SetRelPos((fWidthAll - fWidth) / 2, (fHeightAll - fHeight) / 2)
	hFrame:SetAbsPos((fWidthAll - fWidth) / 2, (fHeightAll - fHeight) / 2)
end

function CheatWarningPanel.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_Sure" then
		CloseCheatWarningPanel()
	end
end

function CloseCheatWarningPanel(bDisableSound)
	if not IsCheatWarningPanelOpened() then
		return 
	end
	
	Wnd.CloseWindow("CheatWarningPanel")
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end	
end

function OpenCheatWarningPanel(bDisableSound)
	if not IsCheatWarningPanelOpened() then
		Wnd.OpenWindow("CheatWarningPanel")
	end
	
	local hFrame = Station.Lookup("Topmost2/CheatWarningPanel")
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
end

function IsCheatWarningPanelOpened()
	local hFrame = Station.Lookup("Topmost2/CheatWarningPanel")
	if hFrame then
		return true
	end
	
	return false
end