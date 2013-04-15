_g_AutoPosFrame1, _g_AutoPosFrame2, _g_AutoPosFrameCloseDisable = nil, nil, false

function _ColseAutoPosFrame(nIndex)
	if nIndex == 1 then
		if _g_AutoPosFrame1 then
			if _g_AutoPosFrame1._AutoPosInfo and _g_AutoPosFrame1._AutoPosInfo.fnAutoClose then
				_g_AutoPosFrame1._AutoPosInfo.fnAutoClose()
			end
			_g_AutoPosFrame1 = nil
		end
	else
		if _g_AutoPosFrame2 then
			if _g_AutoPosFrame2._AutoPosInfo and _g_AutoPosFrame2._AutoPosInfo.fnAutoClose then
				_g_AutoPosFrame2._AutoPosInfo.fnAutoClose()
			end
			_g_AutoPosFrame2 = nil
		end
	end
end

function _ValidateAutoPosInfo()
	if _g_AutoPosFrame2 then
		if not _g_AutoPosFrame2:IsValid() or not _g_AutoPosFrame2:IsVisible() then
			_g_AutoPosFrame2 = nil
		end
	end

	if _g_AutoPosFrame1 then
		if not _g_AutoPosFrame1:IsValid() or not _g_AutoPosFrame1:IsVisible() then
			_g_AutoPosFrame1 = _g_AutoPosFrame2
			_g_AutoPosFrame2 = nil
		end
	else
		_g_AutoPosFrame1 = _g_AutoPosFrame2
		_g_AutoPosFrame2 = nil	
	end
end

function CorrectAutoPosFrameWhenShow(frame)
	if _g_AutoPosFrameCloseDisable then
		return
	end
	
	frame:BringToTop()
	_ValidateAutoPosInfo()
	if frame == _g_AutoPosFrame1 or frame == _g_AutoPosFrame2 then
		CorrectAutoPosFrameAfterClientResize()
		return
	end
	
	if not frame._AutoPosInfo then
		return
	end
	
	_g_AutoPosFrameCloseDisable = true
	if _g_AutoPosFrame1 then
		if _g_AutoPosFrame2 then
			if frame._AutoPosInfo.szFriendly and frame._AutoPosInfo.szFriendly == _g_AutoPosFrame2:GetName() then
				_ColseAutoPosFrame(1)
				_g_AutoPosFrame1 = _g_AutoPosFrame2
				_g_AutoPosFrame2 = nil
			end
			if _g_AutoPosFrame1._AutoPosInfo.nSize + frame._AutoPosInfo.nSize > 3 then
				_ColseAutoPosFrame(1)
				_ColseAutoPosFrame(2)
				_g_AutoPosFrame1 = frame
				_g_AutoPosFrame2 = nil
			else
				_ColseAutoPosFrame(2)
				_g_AutoPosFrame2 = frame
			end
		else
			if frame._AutoPosInfo.szOnly and frame._AutoPosInfo.szOnly == _g_AutoPosFrame1._AutoPosInfo.szOnly then
				_ColseAutoPosFrame(1)
				_g_AutoPosFrame1 = frame
			elseif _g_AutoPosFrame1._AutoPosInfo.nSize + frame._AutoPosInfo.nSize > 3 then
				_ColseAutoPosFrame(1)
				_g_AutoPosFrame1 = frame
			else
				_g_AutoPosFrame2 = frame
			end
		end
	else
		_g_AutoPosFrame1 = frame
	end
	_g_AutoPosFrameCloseDisable = false
	
	CorrectAutoPosFrameAfterClientResize()
end

function CorrectAutoPosFrameWhenHide(frame)
	if _g_AutoPosFrameCloseDisable then
		return
	end
	_ValidateAutoPosInfo()	
	if frame == _g_AutoPosFrame2 then
		_g_AutoPosFrame2 = nil	
	elseif frame == _g_AutoPosFrame1 then
		_g_AutoPosFrame1 = _g_AutoPosFrame2
		_g_AutoPosFrame2 = nil
	end
	CorrectAutoPosFrameAfterClientResize()
end

function CorrectAutoPosFrameAfterClientResize()
	if _g_AutoPosFrameCloseDisable then
		return
	end
	_ValidateAutoPosInfo()
	if _g_AutoPosFrame1 then
		_g_AutoPosFrame1:SetPoint("TOPLEFT", 0, 0, "TOPLEFT", 10, 150)
		
		local argS = arg0
		arg0 = _g_AutoPosFrame1:GetName()
		FireEvent("CORRECT_AUTO_POS")
		arg0 = argS
	end
	if _g_AutoPosFrame2 then
		_g_AutoPosFrame2:SetPoint("TOPLEFT", 0, 0, _g_AutoPosFrame1, "TOPRIGHT", 0, 0)
		local argS = arg0
		arg0 = _g_AutoPosFrame2:GetName()
		FireEvent("CORRECT_AUTO_POS")
		arg0 = argS
	end
end

function CorrectAutoPosFrameEscClose(bDisableSound)
	_ValidateAutoPosInfo()
	local bDo = false
	_g_AutoPosFrameCloseDisable = true
	if _g_AutoPosFrame2 then
		_ColseAutoPosFrame(2)
		bDo = true
	end
	if _g_AutoPosFrame1 then
		_ColseAutoPosFrame(1)
		bDo = true
	end
	if bDo and not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end
	_g_AutoPosFrameCloseDisable = false
	return bDo
end

function InitFrameAutoPosInfo(frame, nSize, szOnly, szFriendly, fnAutoClose)
	local bFirst = false
	if not frame._AutoPosInfo then
		frame._AutoPosInfo = {}
		bFirst = true
	end
	
	frame._AutoPosInfo.nSize = nSize
	frame._AutoPosInfo.szOnly = szOnly
	frame._AutoPosInfo.szFriendly = szFriendly
	frame._AutoPosInfo.fnAutoClose = fnAutoClose
	if bFirst or frame._AutoPosInfo.NewOnFrameShow ~= frame.OnFrameShow then
		frame._AutoPosInfo.OnFrameShow = frame.OnFrameShow
		frame.OnFrameShow = function()
			CorrectAutoPosFrameWhenShow(this)
			if this._AutoPosInfo.OnFrameShow then
				return this._AutoPosInfo.OnFrameShow()
			elseif this:GetSelf().OnFrameShow then
				return this:GetSelf().OnFrameShow()
			end
		end
		frame._AutoPosInfo.NewOnFrameShow = frame.OnFrameShow
	end
	
	if bFirst or frame._AutoPosInfo.NewOnFrameHide ~= frame.OnFrameShow then
		frame._AutoPosInfo.OnFrameHide = frame.OnFrameHide
		frame.OnFrameHide = function()
			CorrectAutoPosFrameWhenHide(this)
			if this._AutoPosInfo.OnFrameHide then
				return this._AutoPosInfo.OnFrameHide()
			elseif this:GetSelf().OnFrameHide then
				return this:GetSelf().OnFrameHide()
			end
		end
		frame._AutoPosInfo.NewOnFrameHide = frame.OnFrameHide
	end
end

function GetFrameAnchor(frame, szPoint)
	local x, y = frame:GetAbsPos()
	local w, h = frame:GetSize()
	
	if szPoint then
		if szPoint == "TOPLEFT" then
		elseif szPoint == "TOPCENTER" then
			x = x + w / 2
		elseif szPoint == "TOPRIGHT" then
			x = x + w
		elseif szPoint == "RIGHTCENTER" then
			x, y = x + w, y + h / 2
		elseif szPoint == "BOTTOMRIGHT" then 
			x, y = x + w, y + h
		elseif szPoint == "BOTTOMCENTER" then
			x, y = x + w / 2, y + h
		elseif szPoint == "BOTTOMLEFT" then
			y = y + h
		elseif szPoint == "LEFTCENTER" then
			y = y + h / 2
		elseif szPoint == "CENTER" then
			x, y = x + w / 2, y + h / 2
		else
			szPoint = "TOPLEFT"
		end
		w, h = 0, 0
	end
	
	local xC, yC = x + w / 2, y + h / 2
	local wA, hA = Station.GetClientSize()
	local wC, hC = wA / 2, hA / 2
	local a = {"TOPLEFT", "TOPCENTER", "TOPRIGHT", "RIGHTCENTER", "BOTTOMRIGHT", "BOTTOMCENTER", "BOTTOMLEFT", "LEFTCENTER", "CENTER"}
	local s = {}
	s[1] = {x, y}
	s[2] = {xC - wC, y}
	s[3] = {x + w - wA, y}
	s[4] = {x + w - wA, yC - hC}
	s[5] = {x + w - wA, y + h - hA}
	s[6] = {xC - wC, y + h - hA}
	s[7] = {x, y + h - hA}
	s[8] = {x, yC - hC}
	s[9] = {xC - wC, yC - hC}
	
	local n, nDis = 1, nil
	for i, v in ipairs(s) do
		local nD = v[1] * v[1] + v[2] * v[2]
		if not nDis then
			nDis = nD
		else
			if nD <= nDis then
				n = i
				nDis = nD
			end
		end
	end
	return {s = szPoint or a[n], r = a[n], x = s[n][1], y = s[n][2]}
end

function GetFrameAnchorCorner(frame)
	local x, y = frame:GetAbsPos()
	local w, h = frame:GetSize()
	local xC, yC = x + w / 2, y + h / 2
	local wA, hA = Station.GetClientSize()
	local wC, hC = wA / 2, hA / 2
	
	if xC > wC then
		if yC > hC then
			return "BOTTOMRIGHT"
		else
			return "TOPRIGHT"
		end
	else
		if yC > hC then
			return "BOTTOMLEFT"
		else
			return "TOPLEFT"
		end
	end
end

function GetFrameAnchorEdge(frame, szLimit)
	local x, y = frame:GetAbsPos()
	local w, h = frame:GetSize()
	local xC, yC = x + w / 2, y + h / 2
	local wA, hA = Station.GetClientSize()
	local wC, hC = wA / 2, hA / 2
	
	if szLimit then
		if szLimit == "VERTICAL" then
			if yC > hC then
				return "BOTTOM"
			else
				return "TOP"
			end			
		elseif szLimit == "HORIZEN" then
			if xC > wC then
				return "RIGHT"
			else
				return "LEFT"
			end
		end
	else
		local a = {"LEFT", "RIGHT", "TOP", "BOTTOM"}
		local b = {xC, wA - xC, yC, hA - yC }
		local i = nil
		for k, v in pairs(b) do
			if not i then
				i = k
			else
				if v < b[k] then
					i = k
				end
			end
		end
		return a[i]
	end
end

function GetSaveAnchor(nPos)
	local a = {"TOPLEFT", "TOPCENTER", "TOPRIGHT", "RIGHTCENTER", "BOTTOMRIGHT", "BOTTOMCENTER", "BOTTOMLEFT", "LEFTCENTER", "CENTER"}
	local st = GetUserPreferences(nPos, "c")
	local rt = GetUserPreferences(nPos + 1, "c")
	if not a[st] or not a[rt] then
		return nil
	end
	return {s = a[st], r = a[rt], x = GetUserPreferences(nPos + 2, "n"), y = GetUserPreferences(nPos + 6, "n")}
end

function SaveAnchor(nPos, Anchor)
	if not Anchor then
		SetUserPreferences(nPos, "ccnn", 0, 0, 0, 0)
		return
	end
	local a = {TOPLEFT = 1, TOPCENTER = 2, TOPRIGHT = 3, RIGHTCENTER = 4, BOTTOMRIGHT = 5, BOTTOMCENTER = 6, BOTTOMLEFT = 7, LEFTCENTER = 8, CENTER = 9}
	SetUserPreferences(nPos, "ccnn", a[Anchor.s], a[Anchor.r], Anchor.x, Anchor.y)
end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

AUTOPOS_TYPE_LEFT = 1
AUTOPOS_TYPE_RIGHT = 2
AUTOPOS_TYPE_FIXED = 3

local AUTOPOS_MOVE_STEP = 20

local tAutoPosDefaultAnchor = 
{
	[AUTOPOS_TYPE_LEFT] = {s = "TOPLEFT", r = "TOPLEFT",  x = 40, y = 80},
	[AUTOPOS_TYPE_RIGHT] = {s = "TOPRIGHT", r = "TOPRIGHT",  x = 40, y = 80},
}

g_tWindowAnchor = {}

RegisterCustomData("g_tWindowAnchor")

function AutoPos_Register(hFrame, nAutoPosType)
	hFrame._AutoPos_OnFrameShow = hFrame.OnFrameShow
	hFrame.OnFrameShow = function()
		if hFrame._AutoPos_OnFrameShow then
			hFrame._AutoPos_OnFrameShow()
		end
		
		local szFrameName = hFrame:GetName()
		if not szFrameName or #szFrameName == 0 then
			return
		end
			
		local tAnchor = nil
		if g_tWindowAnchor[szFrameName] then
			tAnchor = g_tWindowAnchor[szFrameName]
		else
			tAnchor = clone(tAutoPosDefaultAnchor[nAutoPosType])
			
			tAutoPosDefaultAnchor[nAutoPosType].x = tAutoPosDefaultAnchor[nAutoPosType].x + AUTOPOS_MOVE_STEP
			tAutoPosDefaultAnchor[nAutoPosType].y = tAutoPosDefaultAnchor[nAutoPosType].y + AUTOPOS_MOVE_STEP
		end

		if tAnchor then		
			hFrame:SetPoint(tAnchor.s, 0, 0, tAnchor.r, tAnchor.x, tAnchor.y)
			hFrame:CorrectPos()
		end
	end
	
	hFrame._AutoPos_OnFrameDragEnd = hFrame.OnFrameDragEnd
	hFrame.OnFrameDragEnd = function()
		if hFrame._AutoPos_OnFrameDragEnd then
			hFrame._AutoPos_OnFrameDragEnd()
		end
		
		this:CorrectPos()
		tAnchor = GetFrameAnchor(this)
		
		local szFrameName = hFrame:GetName()
		if not szFrameName or #szFrameName == 0 then
			return
		end

		g_tWindowAnchor[szFrameName] = tAnchor
	end
end
