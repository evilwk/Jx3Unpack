local KOREA_LOGO_PANEL_LIVE_TIME = 1000 * 3
local KOREA_LOGO_PANEL_SHOW_INTERVAL = 60 * 60

KoreaLogo = {}

KoreaLogo.DefaultAnchor = {s = "TOPRIGHT", r = "TOPRIGHT", x = -250, y = 80}
KoreaLogo.Anchor = {s = "TOPRIGHT", r = "TOPRIGHT", x = -250, y = 80}
KoreaLogo.bShowPanel = true

RegisterCustomData("KoreaLogo.Anchor")
RegisterCustomData("KoreaLogo.bShowPanel")

function KoreaLogo.OnFrameCreate()
	this:RegisterEvent("UI_SCALED")
	this:RegisterEvent("ON_ENTER_CUSTOM_UI_MODE")
	this:RegisterEvent("ON_LEAVE_CUSTOM_UI_MODE")
	this:RegisterEvent("KOREA_LOGO_PANEL_ANCHOR_CHANGED")
	
	KoreaLogo.UpdateAnchor(this)
	UpdateCustomModeWindow(this, g_tStrings.KOREA_LOGO)
end

function KoreaLogo.OnFrameBreathe()
	if not this.nStartTime then
		return
	end
	
	if GetTickCount() - this.nStartTime > KOREA_LOGO_PANEL_LIVE_TIME then
		CloseKoreaLogoPanel(true)
		this.nStartTime = nil
		DelayCall(KOREA_LOGO_PANEL_SHOW_INTERVAL, OpenKoreaLogoPanel)
	end
end

function KoreaLogo.OnEvent(szEvent)
	if szEvent == "ON_ENTER_CUSTOM_UI_MODE" then
		OpenKoreaLogoPanel(true)
		UpdateCustomModeWindow(this)
	elseif szEvent == "ON_LEAVE_CUSTOM_UI_MODE" then
		UpdateCustomModeWindow(this)
		CloseKoreaLogoPanel(true)
	elseif szEvent == "UI_SCALED" or szEvent == "KOREA_LOGO_PANEL_ANCHOR_CHANGED" then
		KoreaLogo.UpdateAnchor(this)
	end
end

function KoreaLogo.UpdateAnchor(hFrame)
	hFrame:SetPoint(KoreaLogo.Anchor.s, 0, 0, KoreaLogo.Anchor.r, KoreaLogo.Anchor.x, KoreaLogo.Anchor.y)
	hFrame:CorrectPos()
end

function KoreaLogo.OnFrameDragEnd()
	this:CorrectPos()
	KoreaLogo.Anchor = GetFrameAnchor(this)
	FireEvent("KOREA_LOGO_PANEL_ANCHOR_CHANGED")
end

function OpenKoreaLogoPanel()
	if not IsKoreaLogoPanelOpened() then
		Wnd.OpenWindow("KoreaLogo")
	end
	
	if IsInUICustomMode() or IsShowKoreaLogo() then
		local hFrame = Station.Lookup("Normal/KoreaLogo")
		hFrame:Show()
		hFrame.nStartTime = GetTickCount()
		KoreaLogo.UpdateAnchor(hFrame)
		if not bDisableSound then
			PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
		end
	end	
end

function IsKoreaLogoPanelOpened()
	local hFrame = Station.Lookup("Normal/KoreaLogo")
	if hFrame then
		return true
	end
	
	return false
end

function CloseKoreaLogoPanel(bDisableSound)
	if not IsKoreaLogoPanelOpened() then
		return 
	end
	
	if not IsInUICustomMode() then
		local hFrame = Station.Lookup("Normal/KoreaLogo")
		hFrame:Hide()
		--Wnd.CloseWindow("KoreaLogo")
		if not bDisableSound then
			PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
		end	
	end
end

function KoreaLogoPanel_SetAnchorDefault()
	KoreaLogo.Anchor.s = KoreaLogo.DefaultAnchor.s
	KoreaLogo.Anchor.r = KoreaLogo.DefaultAnchor.r
	KoreaLogo.Anchor.x = KoreaLogo.DefaultAnchor.x
	KoreaLogo.Anchor.y = KoreaLogo.DefaultAnchor.y
	FireEvent("KOREA_LOGO_PANEL_ANCHOR_CHANGED")
end

function OnKoreaLogoPanelComment()
	local hKoreaIcon = this:Lookup("", "Handle_KoreaIcon")
	local _, _, szVersionLineName = GetVersion()
	if szVersionLineName ~= "zhkr" then
		return
	end
	OpenKoreaLogoPanel()
end

function SetShowKoeraLogo(bShow)
	KoreaLogo.bShowPanel = bShow
	if bShow then
		OnKoreaLogoPanelComment()
	else
		CloseKoreaLogoPanel()
	end
end

function IsShowKoreaLogo()
	return KoreaLogo.bShowPanel
end

RegisterEvent("PLAYER_ENTER_GAME", function() OnKoreaLogoPanelComment() end)
RegisterEvent("CUSTOM_UI_MODE_SET_DEFAULT", KoreaLogoPanel_SetAnchorDefault)
