UICustomModePanel = 
{
	bCustomMode = false,
	Anchor = {s = "TOPCENTER", r = "TOPCENTER",  x = 0, y = 450}
}

RegisterCustomData("UICustomModePanel.Anchor")

function UICustomModePanel.OnFrameCreate()
	this:RegisterEvent("UI_SCALED")
	this:RegisterEvent("CUSTOM_UI_MODE_ANCHOR_LOADED")
	this:RegisterEvent("CUSTOM_DATA_LOADED")
	
	UICustomModePanel.OnEvent("UI_SCALED")
end

function UICustomModePanel.OnEvent(event)
	if event == "UI_SCALED" or event == "CUSTOM_UI_MODE_ANCHOR_LOADED" then
		this:SetPoint(UICustomModePanel.Anchor.s, 0, 0, UICustomModePanel.Anchor.r, UICustomModePanel.Anchor.x, UICustomModePanel.Anchor.y)
		this:CorrectPos()
	elseif event == "CUSTOM_DATA_LOADED" then
		this:SetPoint(UICustomModePanel.Anchor.s, 0, 0, UICustomModePanel.Anchor.r, UICustomModePanel.Anchor.x, UICustomModePanel.Anchor.y)
		this:CorrectPos()
	end
end

function UICustomModePanel.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_Sure" then
		CloseUICustomModePanel()
	elseif szName == "Btn_Default" then
		FireEvent("CUSTOM_UI_MODE_SET_DEFAULT")
	end
end

function UICustomModePanel.OnFrameDrag()
end

function UICustomModePanel.OnFrameDragSetPosEnd()
end

function UICustomModePanel.OnFrameDragEnd()
	this:CorrectPos()
	UICustomModePanel.Anchor = GetFrameAnchor(this)
end

function OpenUICustomModePanel(bDisableSound)
	if IsUICustomModePanelOpened() then
		return
	end
	
	local frame = Wnd.OpenWindow("UICustomModePanel")
	frame:Show()
	frame:BringToTop()
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
	
	UICustomModePanel.bCustomMode = true
	FireEvent("ON_ENTER_CUSTOM_UI_MODE")
	
	FireDataAnalysisEvent("UI_CUSTOM_MODE")
end

function CloseUICustomModePanel(bDisableSound)
	if not IsUICustomModePanelOpened() then
		return
	end
	Wnd.CloseWindow("UICustomModePanel")
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end
	
	UICustomModePanel.bCustomMode = false
	FireEvent("ON_LEAVE_CUSTOM_UI_MODE")
end

function IsUICustomModePanelOpened()
	local frame = Station.Lookup("Topmost/UICustomModePanel")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end

function UICustomModePanel_Load()
	local szIniFile = GetUserDataPath()
	if szIniFile == "" then
		return
	end
	szIniFile = szIniFile.."\\PannelSave.ini"

	local iniS = Ini.Open(szIniFile)
	if not iniS then
		return
	end
	
	local szSection = "UICustomModePanel"
	
	local value = iniS:ReadString(szSection, "SelfSide", UICustomModePanel.Anchor.s)
	if value then
		UICustomModePanel.Anchor.s = value
	end
	value = iniS:ReadString(szSection, "RelSide", UICustomModePanel.Anchor.r)
	if value then
		UICustomModePanel.Anchor.r = value
	end
	value = iniS:ReadInteger(szSection, "RelX", UICustomModePanel.Anchor.x)
	if value then
		UICustomModePanel.Anchor.x = value
	end
	value = iniS:ReadInteger(szSection, "RelY", UICustomModePanel.Anchor.y)
	if value then
		UICustomModePanel.Anchor.y = value
	end
	
	FireEvent("CUSTOM_UI_MODE_ANCHOR_LOADED")
	
	iniS:Close()
end

function IsInUICustomMode()
	return UICustomModePanel.bCustomMode
end

function UpdateCustomModeWindow(frame, szName, bPenetrable, bDisable, bSizeWithAllChild)
	local page = frame:Lookup("Wnd_CustomMode")
	if bDisable then
		page:Hide()
		return IsInUICustomMode()
	end
	local handle = page:Lookup("", "")
	local imgNormal = handle:Lookup("Image_CMNormal")
	local imgOver = handle:Lookup("Image_CMOver")
	local text = handle:Lookup("Text_CMName")
	local w, h = frame:GetSize()
	page:SetSize(w, h)
	handle:SetSize(w, h)
	handle.UpdateState = function(handle)
		if handle.bOver then
			handle:Lookup("Image_CMNormal"):Hide()
			handle:Lookup("Image_CMOver"):Show()
		else
			handle:Lookup("Image_CMNormal"):Show()
			handle:Lookup("Image_CMOver"):Hide()
		end
	end
	handle.OnItemMouseEnter = function()
		this.bOver = true
		this:UpdateState()
	end
	handle.OnItemMouseLeave = function()
		this.bOver = false
		this:UpdateState()
	end
	handle:UpdateState()
	imgNormal:SetSize(w, h)
	imgOver:SetSize(w, h)
	text:SetSize(w, h)
	if szName then
		text:SetText(szName)
	end
	if IsInUICustomMode() then
		page:Show()
		frame:EnableDrag(true)
		frame:SetDragArea(0, 0, w, h)
		if bPenetrable then
			frame:SetMousePenetrable(false)
		end
		if bSizeWithAllChild then
			frame:SetSizeWithAllChild(true)
		end
		return true
	else
		page:Hide()
		frame:EnableDrag(false)
		if bPenetrable then
			frame:SetMousePenetrable(true)
		end
		if bSizeWithAllChild then
			frame:SetSizeWithAllChild(false)
		end
		return false
	end
end
RegisterLoadFunction(UICustomModePanel_Load)
