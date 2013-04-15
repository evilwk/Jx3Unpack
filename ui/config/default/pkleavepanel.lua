PKLeavePanel = {}

function PKLeavePanel.OnFrameCreate()
	this:RegisterEvent("RETURN_DUEL")
	this:RegisterEvent("FINISH_DUEL")
	this:RegisterEvent("SYS_MSG")
	this:RegisterEvent("UI_SCALED")
	this:RegisterEvent("")
	
	this:SetPoint("CENTER", 0, 0, "CENTER", 0, 0)
	
	PKLeavePanel.UpdateState()
	PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
end

function PKLeavePanel.UpdateState()
	local handle = this:Lookup("", "Handle_Message")
	handle:Lookup("Text_Time"):SetText(FormatString(g_tStrings.STR_PK_LEAVE_DUEL_CALCULAGRAPH, 10))
	handle:FormatAllItemPos()
	
	PKLeavePanel.OnFrameBreathe()
end

function PKLeavePanel.OnFrameBreathe()
	local nTimes = math.floor((PKLeavePanel.nPunishFrame - GetTickCount()) / 1000)
	
	if nTimes < 0 then --PK远离时间到达
		return
	end
	
	local handle = this:Lookup("", "Handle_Message")
	handle:Lookup("Text_Time"):SetText(FormatString(g_tStrings.STR_PK_LEAVE_DUEL_CALCULAGRAPH, nTimes))
	handle:FormatAllItemPos()
end


function PKLeavePanel.OnEvent(event)
	if event == "SYS_MSG" then
	 	if arg0 == "UI_OME_WIN_DUEL" or arg0 == "UI_OME_CANCEL_DUEL" then
	 		Wnd.CloseWindow("PKLeavePanel")
	 		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	 	end		
	elseif event == "RETURN_DUEL" then
		Wnd.CloseWindow("PKLeavePanel")
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	elseif event == "FINISH_DUEL" then
		Wnd.CloseWindow("PKLeavePanel")
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	elseif event == "UI_SCALED" then
		this:SetPoint("CENTER", 0, 0, "CENTER", 0, 0)
	end
end

function CreatePKLeavePanel(dwPunishFrame)
	--设定为10秒
	PKLeavePanel.nPunishFrame = (dwPunishFrame + 1) * 1000 + GetTickCount()
	Wnd.OpenWindow("PKLeavePanel")
end

function PKLeavePanel_GetName()
	return "PKLeavePanel"
end

