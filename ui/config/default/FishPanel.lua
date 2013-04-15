local FISH_PROCESS_TIME = 20 * 1000

FishPanel = {}

function FishPanel.OnFrameCreate()
	this:RegisterEvent("UI_SCALED")
	this:RegisterEvent("CLOSE_FISH_PANEL")
	this:RegisterEvent("FISH_PROCESS_BREAK")
	this:RegisterEvent("FISH_START_PROCESS_BAR")
	
	FishPanel.OnEvent("UI_SCALED")
end

function FishPanel.OnEvent(szEvent)
	if szEvent == "UI_SCALED" then
		this:SetPoint("CENTER", 0, 0, "CENTER", 0, 0)
	elseif szEvent == "CLOSE_FISH_PANEL" then
		CloseFishPanel()
	elseif szEvent == "FISH_PROCESS_BREAK" then
		FishPanel.FlashProcessBar(this)
	elseif szEvent == "FISH_START_PROCESS_BAR" then
		FishPanel.StartProcessBar(this)
	end
end

function FishPanel.OnFrameRender()
	if not this.nStartTime then
		return
	end
	
	local nCurrentTime = GetTickCount()
	local nPast = nCurrentTime - this.nStartTime
	local fPercentage = nPast / FISH_PROCESS_TIME;
	fPercentage = 1 - fPercentage
	FishPanel.SetProgressBarPercentage(this, fPercentage)
end

function FishPanel.SetProgressBarPercentage(hFrame, fPercentage)
	if fPercentage < 0 then
		fPercentage = 0
	end
	if fPercentage > 1 then
		fPercentage = 1
	end		
	hFrame:Lookup("", "Handle_FishCD/Image_FishProcess"):SetPercentage(fPercentage)
end

function FishPanel.StartProcessBar(hFrame)
	hFrame.nStartTime = GetTickCount()
	hFrame:Lookup("", "Handle_FishCD"):Show()
	FishPanel.SetProgressBarPercentage(hFrame, 1)
end

function FishPanel.FlashProcessBar(hFrame)
	hFrame.nStartTime = nil
	hFrame:Lookup("", "Handle_FishCD"):Hide()
end

function FishPanel.OnLButtonClick()
	local szName = this:GetName()
	local hFrame = this:GetRoot()
	if szName == "Btn_xiagan" then
		RemoteCallToServer("OnApplyFangGanRequest")
	elseif szName == "Btn_shougan" then
		RemoteCallToServer("OnApplyShouGanRequest")
		FishPanel.FlashProcessBar(hFrame)
	elseif szName == "Btn_Close" then
		CloseFishPanel()
	end
end

function OpenFishPanel(bDisableSound)
	if IsFishPanelOpened() then
		return
	end
	
	local hFrame = Wnd.OpenWindow("FishPanel")
	FishPanel.FlashProcessBar(hFrame)
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND, g_sound.OpenFrame)
	end
end

function CloseFishPanel(bDisableSound)
	if not IsFishPanelOpened() then
		return
	end
	
	Wnd.CloseWindow("FishPanel")
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND, g_sound.CloseFrame)
	end
end

function IsFishPanelOpened()
	local hFrame = Station.Lookup("Normal/FishPanel")
	if hFrame then
		return true
	end
	
	return false
end