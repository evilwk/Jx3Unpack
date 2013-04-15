local lc_tAnchor = {s = "TOPLEFT", t="Topmost/Minimap", r = "BOTTOMLEFT", x = -20, y = 80}

local lc_tBreatheFunction = {}

local function InitPanelParam(frame, tAnchor, fnBreathe)
	frame:RegisterEvent("UI_SCALED")
	frame.Anchor = tAnchor or clone(lc_tAnchor)
	
	frame.OnEvent = function(event)
		if event == "UI_SCALED" then
			if this.UpdateAnchor then
				this.UpdateAnchor(this)
			end
		end
	end
	
	frame.OnFrameDragEnd = function()
		this:CorrectPos()
		this.Anchor = GetFrameAnchor(this)
	end

	frame.UpdateAnchor = function(frame)
		if frame.Anchor.t then
			frame:SetPoint(frame.Anchor.s, 0, 0, frame.Anchor.t, frame.Anchor.r, frame.Anchor.x, frame.Anchor.y)
		else
			frame:SetPoint(frame.Anchor.s, 0, 0, frame.Anchor.r, frame.Anchor.x, frame.Anchor.y)
		end
		frame:CorrectPos()
	end
	
	if fnBreathe then
		frame.OnFrameBreathe = function()
			fnBreathe()
		end
	end
	frame.UpdateAnchor(frame)
end

function IsCommonBlankPanelOpened(szPanelName)
	local hFrame = Station.Lookup("Normal/CommonBlankPanel_"..szPanelName)
	if hFrame and hFrame:IsVisible() then
		return hFrame
	end
	
	return nil
end

function OpenCommonBlankPanel(bDisableSound, szPanelName, tAnchor, fnBreathe)
	hFrame = IsCommonBlankPanelOpened(szPanelName)
	if  hFrame then
		return hFrame
	end
	
	hFrame = Wnd.OpenWindow("CommonBlankPanel", "CommonBlankPanel_".. szPanelName)
	InitPanelParam(hFrame, tAnchor, fnBreathe)
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end

	return hFrame
end

function CloseCommonBlankPanel(bDisableSound, szPanelName)
	if not IsCommonBlankPanelOpened(szPanelName) then
		return
	end
	
	Wnd.CloseWindow("CommonBlankPanel_"..szPanelName)
	lc_tBreatheFunction["CommonBlankPanel_"..szPanelName] = nil
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end
end

function CommonBlankPanel_GetHandleContent(szPanelName)
	local hFrame = Station.Lookup("Normal/CommonBlankPanel_"..szPanelName)
	if not hFrame or not hFrame:IsVisible() then
		return
	end
	
	return hFrame:Lookup("", ""):Lookup("Handle_Content")
end

function CommonBlankPanel_GetTotHandle(szPanelName)
	local hFrame = Station.Lookup("Normal/CommonBlankPanel_"..szPanelName)
	if not hFrame or not hFrame:IsVisible() then
		return
	end
	
	return hFrame:Lookup("", "")
end

function CommonBlankPanel_SetAnchor(szPanelName, tAnchor)
	lc_tAnchor = tAnchor
end