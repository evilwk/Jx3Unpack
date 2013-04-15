MoviePanel = {}

function MoviePanel.OnFrameCreate()
	this:RegisterEvent("UI_SCALED")
	this:RegisterEvent("LOGIN_GAME")
	MoviePanel.OnEvent("UI_SCALED")
end

function MoviePanel.OnEvent(szEvent)
	if szEvent == "UI_SCALED" then
		MoviePanel.UpdateAnchor(this)
	elseif szEvent == "LOGIN_GAME" then
		local hFrame = this:GetRoot()
		MoviePanel.ShowHotKey(hFrame)
	end
end

function MoviePanel.UpdateAnchor()
	local nXoffset = 20
	this:SetPoint("BOTTOMLEFT", 0, 0, "BOTTOMLEFT", nXoffset, 0)
	this:CorrectPos()
end

function MoviePanel.OnFrameBreathe()
	this:BringToTop()
end

function MoviePanel.ShowHotKey(hFrame)
	local szKey = GetHotkey("KINESCOPE")
	if not szKey or szKey == "" then
		return 
	end
	hFrame:Lookup("","Text_Message"):SetText(FormatString(g_tStrings.MSG_MOVIE_HOTKEY, szKey))
end

function GetHotkey(szKeyName)
	local nKey, nShift, nCtrl, nAlt = Hotkey.Get(szKeyName)
	local szKey = GetKeyShow(nKey, nShift, nCtrl, nAlt)
	if not szKey or szKey == "" then
		nKey, nShift, nCtrl, nAlt = Hotkey.Get(szKeyName, 2)
		szkey = GetKeyShow(nKey, nShift, nCtrl, nAlt)		
	end
	if not szKey or szKey == "" then
		return nil
	end
	return szKey
end

function StartMovieRecord()
	local hFrame = Wnd.OpenWindow("MoviePanel")
	
	local t = GetMovieRecordSetting()	
	MovieRecord(t.nRSize, t.nFilter, t.nQuality, t.nCode, t.nFps)
	local szKey = GetHotkey("KINESCOPE")
	if szKey then
		hFrame:Lookup("","Text_Message"):SetText(FormatString(g_tStrings.MSG_MOVIE_HOTKEY, szKey))
	else
		hFrame:Lookup("","Text_Message"):SetText(g_tStrings.MSG_MOVIE_RECORD)
	end
	hFrame:Show()
end

function FinishMovieRecord()
	MovieStop()
	Wnd.OpenWindow("MoviePanel"):Hide()
end
