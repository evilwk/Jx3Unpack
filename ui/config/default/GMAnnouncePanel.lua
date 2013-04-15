GMAnnouncePanel =
{
	DefaultAnchor = {s = "TOPCENTER", r = "TOPCENTER",  x = 0, y = 90},
	Anchor = {s = "TOPCENTER", r = "TOPCENTER", x = 0, y = 140}
}

local l_tGMMsg = 
{
}
local l_nShowMsgCount = 0
local MOVE_DIS = 3

RegisterCustomData("GMAnnouncePanel.Anchor")

function GMAnnouncePanel.OnFrameCreate()
	this:RegisterEvent("UI_SCALED")
	this:RegisterEvent("ON_ENTER_CUSTOM_UI_MODE")
	this:RegisterEvent("ON_LEAVE_CUSTOM_UI_MODE")
	this:RegisterEvent("GMANNOUNCE_ANCHOR_CHANGED")
	this:RegisterEvent("CUSTOM_DATA_LOADED")

    RegisterMsgMonitor(GMAnnounceMsgMonitor, {"MSG_GM_ANNOUNCE"})
    
	GMAnnouncePanel.UpdateAnchor(this)
	UpdateCustomModeWindow(this, g_tStrings.STR_GOVER_ANNOUNCEMENT, true)	
end

function GMAnnouncePanel.OnFrameDrag()
end

function GMAnnouncePanel.OnFrameDragSetPosEnd()
end

function GMAnnouncePanel.OnFrameDragEnd()
	this:CorrectPos()
	GMAnnouncePanel.Anchor = GetFrameAnchor(this)
end

function GMAnnouncePanel.UpdateAnchor(frame)
	frame:SetPoint(GMAnnouncePanel.Anchor.s, 0, 0, GMAnnouncePanel.Anchor.r, GMAnnouncePanel.Anchor.x, GMAnnouncePanel.Anchor.y)
	frame:CorrectPos()
end

function GMAnnouncePanel.OnEvent(event)
	if event == "UI_SCALED" then
		GMAnnouncePanel.UpdateAnchor(this)
	elseif event == "ON_ENTER_CUSTOM_UI_MODE" or event == "ON_LEAVE_CUSTOM_UI_MODE" then
		UpdateCustomModeWindow(this, nil, true)
	elseif event == "GMANNOUNCE_ANCHOR_CHANGED" then
		GMAnnouncePanel.UpdateAnchor(this)
	elseif event == "CUSTOM_DATA_LOADED" then
		GMAnnouncePanel.UpdateAnchor(this)
	end
end

function GMAnnouncePanel.OnFrameDestroy()
	UnRegisterMsgMonitor(GMAnnouncePanelMsgMonitor)
end

function GMAnnouncePanel.OnFrameBreathe()
    if #l_tGMMsg > 0 and l_nShowMsgCount == 0  then
        local t = l_tGMMsg[1]
        GMAnnouncePanel.SendMsg(this, t.szText, t.nFont, t.bRich, t.r, t.g, t.b, t.szType)
        table.remove(l_tGMMsg, 1)
    end
    
    if l_nShowMsgCount > 0 then
        GMAnnouncePanel.ScrollMsg(this)
    end
end

function GMAnnouncePanel.ScrollMsg(frame)
    local handle = frame:Lookup("", ""):Lookup("Handle_MSG")
    local nCount = handle:GetItemCount() - 1
    
    local nHX, nHY = handle:GetAbsPos()
    for i = 0, nCount, 1 do
        local text = handle:Lookup(i)
        local nW, nH = text:GetSize()
        local nX, nY = text:GetAbsPos()
        local _, nRelY = text:GetRelPos()
        text:SetIntPos(true)
        text:SetAbsPos(nX - MOVE_DIS, nY)
        text:SetRelPos(nX - nHX - MOVE_DIS, nRelY)
        text:SetIntPos(false)
    end
    
    LAST_TEXT_FREE = false;
    
    local text = handle:Lookup(0)
    local nHW = handle:GetSize()
    
    local nX, nY = text:GetAbsPos()
    local nW, nH = text:GetSize()
    
    if nHX - nX >= nW then
        l_nShowMsgCount = l_nShowMsgCount - 1
        if l_nShowMsgCount == 0 then
            text:SetText("")
        end
    end
end

function GMAnnouncePanel.SendMsg(frame, szMsg, nFont, bRich, r, g, b, szType)
	if bRich then
		szMsg = GetPureText(szMsg)
	end
	
	if not szMsg or szMsg == "" then
		return
	end
    
    local hParent = frame:Lookup("", "")
	local handle = hParent:Lookup("Handle_MSG")
	if not handle then
		return
	end
    
    local text = handle:Lookup("Text_Msg")
    local nX, nY = handle:GetAbsPos()
    local nW, nH = handle:GetSize()
    text:SetText(szMsg)
    text:SetAbsPos(nX + nW, nY)
    text:SetFontScheme(nFont)
    text:SetFontColor(r, g, b)
    text:AutoSize()
    
    l_nShowMsgCount = l_nShowMsgCount + 1
end

function GMAnnounceMsgMonitor(szMsg, nFont, bRich, r, g, b, szType)
	if bRich then
		szMsg = GetPureText(szMsg)
	end
	
	if not szMsg or szMsg == "" then
		return
	end
    
    if not StringLengthW or not StringSubW then
        Trace("KLUA[Error] StringLengthW StringSubW is nil")
        return
    end
    table.insert(l_tGMMsg, {szText=szMsg, nFont=nFont, bRich=bRich, r=r, g=g, b=b, szType=szType});
end

function GMAnnouncePanel_SetAnchorDefault()
	GMAnnouncePanel.Anchor.s = GMAnnouncePanel.DefaultAnchor.s
	GMAnnouncePanel.Anchor.r = GMAnnouncePanel.DefaultAnchor.r
	GMAnnouncePanel.Anchor.x = GMAnnouncePanel.DefaultAnchor.x
	GMAnnouncePanel.Anchor.y = GMAnnouncePanel.DefaultAnchor.y
	FireEvent("GMANNOUNCE_ANCHOR_CHANGED")
end

RegisterEvent("CUSTOM_UI_MODE_SET_DEFAULT", GMAnnouncePanel_SetAnchorDefault)
