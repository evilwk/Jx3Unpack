XoyoAsk = {}

function XoyoAsk.OnFrameCreate()
    this:RegisterEvent("UI_SCALED")
    
    XoyoAsk.OnEvent("UI_SCALED")
end

function XoyoAsk.OnLButtonClick()
    local szName = this:GetName()
    if szName == "Btn_Close" then
        CloseXoyoAskPanel()
    end
end

function XoyoAsk.OnEvent(szEvent)
    if szEvent == "UI_SCALED" then
		this:SetPoint("CENTER", 0, 0, "CENTER", 0, 0)
	end
end

function XoyoAsk.Update(hFrame, szURL)
    local hWebPage = hFrame:Lookup("WebPage_Page")
	if szURL then
		hWebPage:Navigate(szURL)
	end
    Station.SetFocusWindow(hWebPage)
end

function OpenSelfXoyoAsk()
    local szURL = GetXoyoAskURL()
    OpenXoyoAskPanel(szURL)
end

function OpenXoyoAskPanel(szURL, bDisableSound)
	if not IsCalenderPanelOpened() then
		Wnd.OpenWindow("XoyoAsk")
	end
	local hFrame = Station.Lookup("Normal/XoyoAsk")
    XoyoAsk.Update(hFrame, szURL)
	hFrame:BringToTop()
    
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND, g_sound.OpenFrame)
	end
end

function IsXoyoAskPanelOpened()
	local hFrame = Station.Lookup("Normal/XoyoAsk")
	if hFrame then
		return true
	end
	
	return false
end

function CloseXoyoAskPanel(bDisableSound)
	if not IsXoyoAskPanelOpened() then
		return
	end
	
	Wnd.CloseWindow("XoyoAsk")
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND, g_sound.CloseFrame)
	end
end
