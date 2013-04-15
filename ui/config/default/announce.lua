Announce =
{
	DefaultAnchor = {s = "TOPCENTER", r = "TOPCENTER",  x = 0, y = 190},
	Anchor = {s = "TOPCENTER", r = "TOPCENTER", x = 0, y = 190}
}

RegisterCustomData("Announce.Anchor")

function Announce.OnFrameCreate()
	this:RegisterEvent("UI_SCALED")
	this:RegisterEvent("ON_ENTER_CUSTOM_UI_MODE")
	this:RegisterEvent("ON_LEAVE_CUSTOM_UI_MODE")
	this:RegisterEvent("ANNOUNCE_ANCHOR_CHANGED")
	this:RegisterEvent("CUSTOM_DATA_LOADED")

	RegisterMsgMonitor(AnnounceMsgMonitor, {"MSG_ANNOUNCE_RED" , "MSG_ANNOUNCE_YELLOW"})
	
	Announce.UpdateAnchor(this)
	UpdateCustomModeWindow(this, g_tStrings.ANNOUNCE, true)	
end

function Announce.OnFrameDrag()
end

function Announce.OnFrameDragSetPosEnd()
end

function Announce.OnFrameDragEnd()
	this:CorrectPos()
	Announce.Anchor = GetFrameAnchor(this)
end

function Announce.UpdateAnchor(frame)
	frame:SetPoint(Announce.Anchor.s, 0, 0, Announce.Anchor.r, Announce.Anchor.x, Announce.Anchor.y)
	frame:CorrectPos()
end

function Announce.OnEvent(event)
	if event == "UI_SCALED" then
		Announce.UpdateAnchor(this)
	elseif event == "ON_ENTER_CUSTOM_UI_MODE" or event == "ON_LEAVE_CUSTOM_UI_MODE" then
		UpdateCustomModeWindow(this, nil, true)
	elseif event == "ANNOUNCE_ANCHOR_CHANGED" then
		Announce.UpdateAnchor(this)
	elseif event == "CUSTOM_DATA_LOADED" then
		Announce.UpdateAnchor(this)
	end
end

function Announce.OnFrameDestroy()
	UnRegisterMsgMonitor(AnnounceMsgMonitor)
end
	
function Announce.OnFrameBreathe()
	if this.nDis and this.nDis > 0 then
		this.nDis = this.nDis - 1
		return
	end
	this.nDis = 3
	local handle = this:Lookup("", "")
	local nCount = handle:GetItemCount() - 1
	for i = 0, nCount, 1 do
		local text = handle:Lookup(i)
		if text:IsVisible() then
			local nLeft = text:GetAlpha() - 10
			if nLeft < 0 then
				text:Hide()
			else
				text:SetAlpha(nLeft)
			end
		end
	end
end

function AnnounceMsgMonitor(szMsg, nFont, bRich, r, g, b, szType)
	if bRich then
		szMsg = GetPureText(szMsg)
	end
	
	if not szMsg or szMsg == "" then
		return
	end

	local handle = Station.Lookup("Topmost2/Announce", "")
	if not handle then
		return
	end

	local nCount = handle:GetItemCount() - 1
	for i = 0, nCount, 1 do
		local text = handle:Lookup(i)
		if text:IsVisible() and text:GetText() == szMsg then
			text:SetIndex(nCount)
			text:SetFontScheme(nFont)
			text:SetFontColor(r, g, b)
			text:SetAlpha(255)
			handle:FormatAllItemPos()
			return
		end
	end	
	
	local text = handle:Lookup(0)
	text:SetIndex(nCount)
	text:SetFontScheme(nFont)
	text:SetFontColor(r, g, b)
	text:SetAlpha(255)
	text:SetText(szMsg)
	text:Show()
	handle:FormatAllItemPos()
	
	if szType == "MSG_ANNOUNCE_RED" then
		PlaySound(SOUND.UI_ERROR_SOUND, g_sound.ActionFailed)
	end
end

function Announce_SetAnchorDefault()
	Announce.Anchor.s = Announce.DefaultAnchor.s
	Announce.Anchor.r = Announce.DefaultAnchor.r
	Announce.Anchor.x = Announce.DefaultAnchor.x
	Announce.Anchor.y = Announce.DefaultAnchor.y
	FireEvent("ANNOUNCE_ANCHOR_CHANGED")
end

RegisterEvent("CUSTOM_UI_MODE_SET_DEFAULT", Announce_SetAnchorDefault)
