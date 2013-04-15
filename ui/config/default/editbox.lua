EditBox =
{
	aInput = {}, bAlwaysShow = true, aName = {}, aReply = {},
	
	aChannel =
	{
		["/gm "] = true,
		["/ "] = true,
		["/ie "] = true,
		["/afk "] = true,
		["/atr "] = true,
		["/s "] = true,
		["/p "] = true,
		["/y "] = true,
		["/b "] = true,
		["/w "] = true,
		["/g "] = true,
		["/h "] = true,
		["/t "] = true,
		["/f "] = true,
		["/c "] = true,
		["/m "] = true,
		["/o "] = true,		
		["/r "] = true,
		["/1 "] = true,
		["/2 "] = true,
		["/3 "] = true,
		["/4 "] = true,
		["/5 "] = true,
		["/6 "] = true,
		["/7 "] = true,
		["/8 "] = true,
	},	
	
	aMap = 
	{
		["　"] = " ",["？"] = "?",["／"] = "/", ["、"] = "/",
		["A"] = "a",["ａ"] = "a",["Ａ"] = "a",
		["B"] = "b",["ｂ"] = "b",["Ｂ"] = "b",
		["C"] = "c",["ｃ"] = "c",["Ｃ"] = "c",
		["D"] = "d",["ｄ"] = "d",["Ｄ"] = "d",
		["E"] = "e",["ｅ"] = "e",["Ｅ"] = "e",
		["F"] = "f",["ｆ"] = "f",["Ｆ"] = "f",
		["G"] = "g",["ｇ"] = "g",["Ｇ"] = "g",
		["H"] = "h",["ｈ"] = "h",["Ｈ"] = "h",
		["I"] = "i",["ｉ"] = "i",["Ｉ"] = "i",
		["J"] = "i",["ｊ"] = "i",["Ｊ"] = "i",
		["K"] = "k",["ｋ"] = "k",["Ｋ"] = "k",
		["L"] = "l",["ｌ"] = "l",["Ｌ"] = "l",
		["M"] = "m",["ｍ"] = "m",["Ｍ"] = "m",
		["N"] = "n",["ｎ"] = "n",["Ｎ"] = "n",
		["O"] = "o",["ｏ"] = "o",["Ｏ"] = "o",
		["P"] = "p",["ｐ"] = "p",["Ｐ"] = "p",
		["Q"] = "q",["ｑ"] = "q",["Ｑ"] = "q",
		["R"] = "r",["ｒ"] = "r",["Ｒ"] = "r",
		["S"] = "s",["ｓ"] = "s",["Ｓ"] = "s",
		["T"] = "t",["ｔ"] = "t",["Ｔ"] = "t",
		["U"] = "u",["ｕ"] = "u",["Ｕ"] = "u",
		["V"] = "v",["ｖ"] = "v",["Ｖ"] = "v",
		["W"] = "w",["ｗ"] = "w",["Ｗ"] = "w",
		["X"] = "x",["ｘ"] = "x",["Ｘ"] = "x",
		["Y"] = "y",["ｙ"] = "y",["Ｙ"] = "y",
		["Z"] = "z",["ｚ"] = "z",["Ｚ"] = "z",
	}
}

RegisterCustomData("EditBox.bAlwaysShow")

function EditBox.GetChannel(szHeader)
	local s2 = string.sub(szHeader, 1, 2)
	local s1 = string.sub(szHeader, 1, 1)
	local s, i
	if s1 == "/" then  
		s, i = "/", 2
	elseif s2 == "／" then
		s, i = "/", 3
	elseif s2 == "、" then
		s, i = "/", 3
	else
		return
	end
	while i < 12 do
		local c = string.byte(szHeader, i)
		if not c then
			return
		end
		local sc
		if c >= 0x80 then
			sc = string.sub(szHeader, i, i + 1)
			i = i + 2
		else
			sc = string.sub(szHeader, i, i)
			i = i + 1
		end
		if sc == "" then
			return
		end
		local sr = EditBox.aMap[sc]
		s = s..(sr or sc)
		if EditBox.aChannel[s] then
			return s, string.sub(szHeader, i, -1)
		end		
	end
end

function EditBox.IsCommandBegin(szHeader)
	local s2 = string.sub(szHeader, 1, 2)
	local s1 = string.sub(szHeader, 1, 1)
	if s1 == "/" or s2 == "／" then
		return true
	end
	return false
end

function EditBox.FormatCommand(szCommand)
	local s, i = "", 1
	while true do
		local c = string.byte(szCommand, i)
		if not c then
			break
		end
		local sc
		if c >= 0x80 then
			sc = string.sub(szCommand, i, i + 1)
			i = i + 2
		else
			sc = string.sub(szCommand, i, i)
			i = i + 1
		end
		if sc == "" then
			break
		end
		local sr = EditBox.aMap[sc]
		sr = sr or sc
		if sr ~= " " then
			s = s..sr
		end
	end
	return s
end

function EditBox.GetPrevInput()
	if not EditBox.nIndex then
		local nIndex = #(EditBox.aInput)
		if nIndex == 0 then
			return nil
		end
		EditBox.nIndex = nIndex
		return EditBox.aInput[nIndex]
	end
	
	if EditBox.nIndex > 1 then
		EditBox.nIndex = EditBox.nIndex - 1
		return EditBox.aInput[EditBox.nIndex]
	end
	return nil
end

function EditBox.GetNextInput()
	if not EditBox.nIndex then
		return nil
	end
	if EditBox.nIndex >= #(EditBox.aInput) then
		return nil
	end
	
	EditBox.nIndex = EditBox.nIndex + 1
	return EditBox.aInput[EditBox.nIndex]
end

function EditBox.AppendHistory(Input)
	for k, v in pairs(EditBox.aInput) do
		if EditBox.IsHistoryEq(v, Input) then
			table.remove(EditBox.aInput, k)
			break
		end
	end
	table.insert(EditBox.aInput, Input)
	if #(EditBox.aInput) > 20 then --20条记录
		table.remove(EditBox.aInput, 1)
	end
end

function EditBox.IsHistoryEq(aL, aR)
	if #aL ~= #aR then
		return false
	end
	for kL, vL in ipairs(aL) do
		local vR = aR[kL]
		if not vR then
			return false
		end
		for k, v in pairs(vL) do
			if v ~= vR[k] then
				return false
			end
		end
	end
	return true
end

function EditBox.AddName(szName)
	for k, v in pairs(EditBox.aName) do
		if v == szName then
			table.remove(EditBox.aName, k)
			break
		end
	end
	table.insert(EditBox.aName, szName)
	if #(EditBox.aName) > 5 then --5条记录
		table.remove(EditBox.aName, 1)
	end
end

function EditBox.AddReply(szName)
	for k, v in pairs(EditBox.aReply) do
		if v == szName then
			table.remove(EditBox.aReply, k)
			break
		end
	end
	table.insert(EditBox.aReply, szName)
	if #(EditBox.aReply) > 10 then --10条记录
		table.remove(EditBox.aReply, 1)
	end
end

function EditBox.GetPrevReply()
	if not EditBox.aReply then
		return EditBox.GetLastReply()
	end
	
	local n = #(EditBox.aReply)
	for k, v in ipairs(EditBox.aReply) do
		if v == EditBox.szName then
			if k == 1 then
				return EditBox.aReply[n]
			end
			return EditBox.aReply[k - 1]
		end
	end
	
	return EditBox.GetLastReply()
end

function EditBox.GetNextReply()
	if not EditBox.szName then
		return EditBox.GetLastReply()
	end
	
	local n = #(EditBox.aReply)
	for k, v in ipairs(EditBox.aReply) do
		if v == EditBox.szName then
			if k == n then
				return EditBox.aReply[1]
			end
			return EditBox.aReply[k + 1]
		end
	end
	
	return EditBox.GetLastReply()
end

function EditBox.GetLastReply()
	local n = #(EditBox.aReply)
	if n == 0 then
		return nil
	end
	return EditBox.aReply[n]
end

function EditBox.OnFrameCreate()
	this:RegisterEvent("UI_SCALED")
	this:RegisterEvent("CHAT_PANEL_POS_CHANGED")
	this:RegisterEvent("CUSTOM_DATA_LOADED")
	
	this:Lookup("", "Text_Channel"):Show()
	EditBox.AdjustHeaderShow()
	EditBox.AdjustPos(this)
end

function EditBox.OnEvent(event)
	if event == "UI_SCALED" or event == "CHAT_PANEL_POS_CHANGED" then
		EditBox.AdjustPos(this)
	elseif event == "CUSTOM_DATA_LOADED" then
		SetEditBoxAlwaysShow(IsEditBoxAlwaysShow())
	end
end

function EditBox.OnOpenChannel(btn)
	if btn.bIgnor then
		btn.bIgnor = nil
		return
	end

	local OnChangeChanel = function(szHeader)
		if szHeader then
			EditBox.AdjustHeaderShow(szHeader)
			local edit = Station.Lookup("Lowest2/EditBox/Edit_Input")
			Station.SetFocusWindow(edit)
			local t = edit:GetTextStruct()
			if t and #t == 1 and t[1] and t[1].type == "text" and (t[1].text == "/w " or t[1].text == "/w　") then
				edit:ClearText()
			end
		end
	end
	
	local OnWhisper = function(szName)
		if szName ~= "" then
			szName = szName.." "
		end
		local edit = Station.Lookup("Lowest2/EditBox/Edit_Input")
		Station.SetFocusWindow(edit)
		local t = edit:GetTextStruct()
		t = t or {}
		if t[1] then
			if t[1].type == "text" then
				if not (t[1].text == "/w " or t[1].text == "/w　") then
					t[1].text = "/w "..szName..t[1].text
				end				
			else
				table.insert(t, 1, {type = "text", text = "/w "..szName})
			end
		else
			t[1] = {type = "text", text = "/w "..szName}
		end
		EditBox.SetEditTextStruct(edit, t)
	end
	local fx, fy = this:GetAbsPos()
	local menu = 
	{
		fnAction = OnChangeChanel, x = fx, y = fy,
		fnCancelAction = function() 
			local btn = Station.Lookup("Lowest2/EditBox/Btn_Channel") 
			if btn then
				local x, y = Cursor.GetPos()
				local xA, yA = btn:GetAbsPos()
				local w, h = btn:GetSize()
				if x >= xA and x < xA + w and y >= yA and y <= yA + h then
					btn.bIgnor = true
				end
			end
		end,
		fnAutoClose = function() return not IsEditBoxOpened() end,		
	}
	
	local player = GetClientPlayer()
	
	local rT, gT, bT
--[[本地指令和脚本指令改为默认不可见。	
	if g_bDebugMode then
		rT, gT, bT = EditBox.GetEditFontColorByHeader("/gm ")
		table.insert(menu, {szOption = g_tStrings.CHANNEL_SEVER_ORDER, r = rT, g = gT, b = bT, UserData = "/gm "})
		rT, gT, bT = EditBox.GetEditFontColorByHeader("? ")
		table.insert(menu, {szOption = g_tStrings.CHANNEL_LOCAL_ORDER, r = rT, g = gT, b = bT, UserData = "/ "})
	end
]]	
	rT, gT, bT = EditBox.GetEditFontColorByHeader("/s ")
	table.insert(menu, {szOption = g_tStrings.CHANNEL_NEARBY_SIGN, r = rT, g = gT, b = bT, UserData = "/s "})
	
	rT, gT, bT = EditBox.GetEditFontColorByHeader("/y ")
	table.insert(menu, {szOption = g_tStrings.CHANNEL_MAP_SIGN, r = rT, g = gT, b = bT, UserData = "/y "})

	if player.GetScene() and player.GetScene().nType == MAP_TYPE.BATTLE_FIELD then
		rT, gT, bT = EditBox.GetEditFontColorByHeader("/b ")
		table.insert(menu, {szOption = g_tStrings.CHANNEL_BATTLE_FIELD_SIGN, r = rT, g = gT, b = bT, UserData = "/b "})
	end
	
	local szState = GetPartyRecruitState()
	if szState == "InFTDungeon" then --寻求组队进入的副本后 所用的系统队伍频道 和战场频道是一样的
		rT, gT, bT = EditBox.GetEditFontColorByHeader("/b ")
		table.insert(menu, {szOption = g_tStrings.CHANNEL_BATTLE_FIELD_SIGN, r = rT, g = gT, b = bT, UserData = "/b "})
	end
	
	if player.dwTongID and player.dwTongID ~= 0 then
		rT, gT, bT = EditBox.GetEditFontColorByHeader("/g ")
		table.insert(menu, {szOption = g_tStrings.CHANNEL_FACTION_SIGN, r = rT, g = gT, b = bT, UserData = "/g "})
	end

	if player.dwTeamID ~= GLOBAL.INVALID_PARTY_ID then
		rT, gT, bT = EditBox.GetEditFontColorByHeader("/p ")
		table.insert(menu, {szOption = g_tStrings.CHANNEL_PARTY_SIGN, r = rT, g = gT, b = bT, UserData = "/p "})
	end
	
	if GetClientTeam().nGroupNum > 1 then
		rT, gT, bT = EditBox.GetEditFontColorByHeader("/t ")
		table.insert(menu, {szOption = g_tStrings.CHANNEL_TEAM_SIGN, r = rT, g = gT, b = bT, UserData = "/t "})
	end
	
	rT, gT, bT = EditBox.GetEditFontColorByHeader("/h ")
	table.insert(menu, {szOption = g_tStrings.CHANNEL_WORLD_SIGN, r = rT, g = gT, b = bT, UserData = "/h "})
	
	if player.dwForceID ~= 0 then
		rT, gT, bT = EditBox.GetEditFontColorByHeader("/f ")
		table.insert(menu, {szOption = g_tStrings.CHANNEL_SCHOOL_SIGN, r = rT, g = gT, b = bT, UserData = "/f "})
	end
	
	rT, gT, bT = EditBox.GetEditFontColorByHeader("/c ")
	table.insert(menu, {szOption = g_tStrings.CHANNEL_CAMP_SIGN, r = rT, g = gT, b = bT, UserData = "/c "})
	
	rT, gT, bT = EditBox.GetEditFontColorByHeader("/m ")
	table.insert(menu, {szOption = g_tStrings.CHANNEL_MENTOR_SIGN, r = rT, g = gT, b = bT, UserData = "/m "})	

	rT, gT, bT = EditBox.GetEditFontColorByHeader("/o ")
	table.insert(menu, {szOption = g_tStrings.CHANNEL_FRIEND_SIGN, r = rT, g = gT, b = bT, UserData = "/o "})	
	
	rT, gT, bT = EditBox.GetEditFontColorByHeader("/w ")
	table.insert(menu, {szOption = g_tStrings.CHANNEL_WHISPER_SIGN, r = rT, g = gT, b = bT, UserData = "", fnAction = OnWhisper})
		
	if #(EditBox.aName) > 0 then
		table.insert(menu, {bDevide = true})
	end
	for k, v in pairs(EditBox.aName) do
		table.insert(menu, {szOption = g_tStrings.WHISPER..v, r = rT, g = gT, b = bT, UserData = v, fnAction = OnWhisper})
	end
	
--[[
	{szOption = g_tStrings.CHANNEL_BUILD.."1(/1 )", UserData = "/1 "},
	{szOption = g_tStrings.CHANNEL_BUILD.."2(/2 )", UserData = "/2 "},
	{szOption = g_tStrings.CHANNEL_BUILD.."3(/3 )", UserData = "/3 "},
	{szOption = g_tStrings.CHANNEL_BUILD.."4(/4 )", UserData = "/4 "},
	{szOption = g_tStrings.CHANNEL_BUILD.."5(/5 )", UserData = "/5 "},
	{szOption = g_tStrings.CHANNEL_BUILD.."6(/6 )", UserData = "/6 "},
	{szOption = g_tStrings.CHANNEL_BUILD.."7(/7 )", UserData = "/7 "},
	{szOption = g_tStrings.CHANNEL_BUILD.."8(/8 )", UserData = "/8 "},
]]
	
	PopupMenu(menu)
	local frame = GetPopupMenu()
	if frame then
		frame:SetPoint("BOTTOMLEFT", 0, 0, btn, "TOPLEFT", 0, 0)
	end	
end

function EditBox.OnIgnoreKeyDown()
	local szKey = GetKeyName(Station.GetMessageKey())
--[[
	if szKey == "Up" then
		return 1
	elseif szKey == "Down" then
		return 1
	elseif szKey == "Left" then
		return 1		
	elseif szKey == "Right" then
		return 1
	end
	return 0
]]
	return 0
end

function EditBox.SetEditTextStruct(edit, t)
	edit:ClearText()
	for k, v in ipairs(t) do
		if v.type == "text" then
			edit:InsertText(v.text)
		else
			edit:InsertObj(v.text, v)
		end
	end
end

function EditBox.OnEditSpecialKeyDown()
	local szKey = GetKeyName(Station.GetMessageKey())
	local nResult = 0
	if szKey == "Enter" then
		local szInput = this:GetText()
		if EditBox.ProcessInput(this) then
			CloseEditBox()
		end
		nResult = 1
	elseif szKey == "Up" then
		local bKeep = false
		if not EditBox.nIndex then
			bKeep = true
		end
		local t = EditBox.GetPrevInput()
		if t then
			if bKeep then
				EditBox.CurrentInput = this:GetTextStruct()
			end
			EditBox.SetEditTextStruct(this, t)
		end
		nResult = 1
	elseif szKey == "Down" then
		local t = EditBox.GetNextInput()
		if t then
			EditBox.SetEditTextStruct(this, t)
		else
			if EditBox.CurrentInput then
				EditBox.SetEditTextStruct(this, EditBox.CurrentInput)
				EditBox.CurrentInput = nil
				EditBox.nIndex = nil
			end
		end
		nResult = 1
	elseif szKey == "Esc" then
		Station.SetFocusWindow(nil)
		nResult = 1
	elseif szKey == "Tab" then
		if string.sub(EditBox.szHeader, 1, 3)== "/w " then	
			if IsShiftKeyDown() then
				local szName = EditBox.GetPrevReply()
				if szName then
					EditBox_TalkToSomebody(szName)
				end
			else
				local szName = EditBox.GetNextReply()
				if szName then
					EditBox_TalkToSomebody(szName)
				end
			end
		end
		nResult = 1
	end
	
	return nResult
end

function EditBox.OnEditChanged()
	local t = this:GetTextStruct()
	if not t[1] or t[1].type ~= "text" then
		return
	end
	
	local szHeader, szLeft = EditBox.GetChannel(t[1].text)
	if not szHeader then
		return
	end
	
	if not g_bDebugMode and (szHeader == "/ " or szHeader == "/gm ") then
		return
	end
	
	if szHeader == "/w " then
		while szLeft ~= "" do
			if string.sub(szLeft, 1, 1) == " " then
				szLeft = string.sub(szLeft, 2, -1)
			elseif string.sub(szLeft, 1, 2) == "　" then
				szLeft = string.sub(szLeft, 3, -1)
			else
				break
			end
		end
		local nStartE, nEndE = string.find(szLeft, " ", 1, true)
		local nStartC, nEndC = string.find(szLeft, "　", 1, true)
		local nStart, nEnd = nil, nil
		if nStartE and nEndE and nStartC and nEndC then
			if nStartE < nStartC then
				nStart, nEnd = nStartE, nEndE
			else
				nStart, nEnd = nStartC, nEndC
			end
		elseif nStartE and nEndE then
			nStart, nEnd = nStartE, nEndE
		elseif nStartC and nEndC then
			nStart, nEnd = nStartC, nEndC
		end	
		if not nStart or not nEnd then
			return
		end
		szHeader = szHeader..string.sub(szLeft, 1, nStart - 1).." "
		szLeft = string.sub(szLeft, nEnd + 1, -1)
	elseif szHeader == "/r " then
		local szReply = EditBox.GetLastReply()
		if not szReply then
			return
		end
		szHeader = "/w "..szReply.." "
	end

	t[1].text = szLeft
	EditBox.AdjustHeaderShow(szHeader)
	EditBox.SetEditTextStruct(this, t)
end

function EditBox.AdjustHeaderShow(szHeader)
	if szHeader then
		EditBox.szHeader = szHeader
	end
	if not EditBox.szHeader then
		EditBox.szHeader = "/s "
	end
	
	EditBox.szName = nil
	local s = EditBox.szHeader
	local sShow = g_tStrings.HEADER_SHOW_SAY
	if s == "/gm " then
		sShow = "GM："
	elseif s == "/ " then
		sShow = "CMD："
	elseif s == "/ie " then
		sShow = g_tStrings.HEADER_SHOW_IE
	elseif s == "/afk " then
		sShow = g_tStrings.HEADER_SHOW_AFK
	elseif s == "/atr " then
		sShow = g_tStrings.HEADER_SHOW_AUTO_RESPOND
	elseif s == "/s " then
		sShow = g_tStrings.HEADER_SHOW_SAY
	elseif s == "/p " then
		sShow = g_tStrings.HEADER_SHOW_CHAT_PARTY
	elseif s == "/y " then
		sShow = g_tStrings.HEADER_SHOW_MAP
	elseif s == "/b " then
		sShow = g_tStrings.HEADER_SHOW_BATTLE_FIELD
	elseif s == "/g " then
		sShow = g_tStrings.HEADER_SHOW_CHAT_FACTION
	elseif s == "/h " then
		sShow = g_tStrings.HEADER_SHOW_WORLD
	elseif s == "/t " then
		sShow = g_tStrings.HEADER_SHOW_TEAM
	elseif s == "/f " then
		sShow = g_tStrings.HEADER_SHOW_SCHOOL
	elseif s == "/c " then
		sShow = g_tStrings.HEADER_SHOW_CAMP
	elseif s == "/m " then
		sShow = g_tStrings.HEADER_SHOW_MENTOR
	elseif s == "/o " then
		sShow = g_tStrings.HEADER_SHOW_FRIEND
	elseif s == "/1 " then
		sShow = g_tStrings.HEADER_SHOW_CHANNEL1
	elseif s == "/2 " then
		sShow = g_tStrings.HEADER_SHOW_CHANNEL2
	elseif s == "/3 " then
		sShow = g_tStrings.HEADER_SHOW_CHANNEL3
	elseif s == "/4 " then
		sShow = g_tStrings.HEADER_SHOW_CHANNEL4
	elseif s == "/5 " then
		sShow = g_tStrings.HEADER_SHOW_CHANNEL5
	elseif s == "/6 " then
		sShow = g_tStrings.HEADER_SHOW_CHANNEL6
	elseif s == "/7 " then
		sShow = g_tStrings.HEADER_SHOW_CHANNEL7
	elseif s == "/8 " then
		sShow = g_tStrings.HEADER_SHOW_CHANNEL8
	else
		if string.sub(s, 1, 3) == "/w " then
			EditBox.szName = string.sub(s, 4, -2)
			sShow = FormatString(g_tStrings.HEADER_SHOW_FACE, EditBox.szName)
		else
			EditBox.szHeader = "/s "
			sShow = g_tStrings.HEADER_SHOW_SAY		
		end
	end
	
	local frame = Station.Lookup("Lowest2/EditBox")
	local text = frame:Lookup("", "Text_Channel")
	local r, g, b = EditBox.GetEditFontColorByHeader()
	text:SetFontColor(r, g, b)
	text:SetText(sShow)
	text:AutoSize()
	local edit = frame:Lookup("Edit_Input")
	edit:SetFontColor(r, g, b)
	
	local x, y = text:GetRelPos()
	local w, h = text:GetSize()
	local wF, hF = frame:GetSize()
	text:SetSize(w, hF)
	local xE, yE = edit:GetRelPos()
	local wE, hE = edit:GetSize()
	local btnEn = frame:Lookup("Btn_Enter")
	local wA = btnEn:GetRelPos()
	edit:SetRelPos(x + w + 1, yE)
	edit:SetSize(wA - w - x - 2, hE)
end

function EditBox.GetAFK()
	if EditBox.afk then
		return EditBox.afk
	else
		return {{type = "text", text = "afk"}, {type = "text", text = g_tStrings.STR_AUTO_REPLAY_LEAVE}}
	end
end

function EditBox.GetATR()
	if EditBox.atr then
		return EditBox.atr
	end
end

function EditBox.ProcessInput(edit)
	local t = edit:GetTextStruct()
	if not t then
		return true
	end
	local nSize = #t
	if nSize == 0 then
		return true
	end
	
	local tSrcData = clone(t)
	local s = EditBox.szHeader 
	local player = GetClientPlayer()
	local nChannel = nil
	
	--处理表情命令
	if nSize == 1 and t[1].type == "text" and EditBox.IsCommandBegin(t[1].text) then
		local szHeader, szLeft = EditBox.GetChannel(t[1].text.." ")
		if szHeader then
			if not g_bDebugMode and (szHeader == "/ " or szHeader == "/gm ") then
				OutputMessage("MSG_SYS", g_tExpression.STR_EMOTION_COMMAND_ERROR)
			else
				t[1].text = t[1].text.." "
				EditBox.SetEditTextStruct(edit, t)
				return false
			end
		else
			local szCommand = t[1].text --EditBox.FormatCommand(t[1].text)
			if szCommand == "/cafk" then
				EditBox.afk = nil
				OutputMessage("MSG_SYS", g_tStrings.MSG_PROCESS_INPUT1)
			elseif szCommand == "/catr" then
				EditBox.atr = nil
				OutputMessage("MSG_SYS", g_tStrings.MSG_PROCESS_INPUT2)
			elseif IsEmotion(szCommand) then
				ProcessEmotion(szCommand)
		  	elseif IsJiangHuWord(szCommand) then
		    	ProcessJiangHuWord(szCommand)
			elseif ExcuteMacro then
				if not ExcuteMacro(szCommand) then
					OutputMessage("MSG_SYS", g_tExpression.STR_EMOTION_COMMAND_ERROR)
				end
			else
				OutputMessage("MSG_SYS", g_tExpression.STR_EMOTION_COMMAND_ERROR)
			end
		end
		edit:ClearText()
		EditBox.AppendHistory(t)
		return true
	end
	
	t = EmotionPanel_ParseFaceIconCommand(t)
	
	if string.sub(s, 1, 3) == "/w " then
		local szName = string.sub(s, 4, -2)
		player.Talk(PLAYER_TALK_CHANNEL.WHISPER, szName, t)
		EditBox.AddName(szName)
		EditBox.AddReply(szName)		
		nChannel = PLAYER_TALK_CHANNEL.WHISPER
	elseif s == "/gm " then
		if g_bDebugMode then
			SendGMCommand(edit:GetText())
		end
	elseif s == "/ " then
		if g_bDebugMode then
			ExcuteMacro("/script "..edit:GetText())
		end
	elseif s == "/ie " then
		OpenInternetExplorer(edit:GetText())
	elseif s == "/afk " then
		EditBox.afk = t
		OutputMessage("MSG_SYS", g_tStrings.MSG_PROCESS_INPUT3)
	elseif s == "/atr " then
		table.insert(t, 1, {type = "text", text = "atr"})
		EditBox.atr = t
		OutputMessage("MSG_SYS", g_tStrings.MSG_PROCESS_INPUT4)
	elseif s == "/s " then
		nChannel = PLAYER_TALK_CHANNEL.NEARBY
	elseif s == "/p " then
		nChannel = PLAYER_TALK_CHANNEL.TEAM
	elseif s == "/y " then
		nChannel = PLAYER_TALK_CHANNEL.SENCE
	elseif s == "/b " then
		nChannel = PLAYER_TALK_CHANNEL.BATTLE_FIELD
	elseif s == "/g " then
		nChannel = PLAYER_TALK_CHANNEL.TONG
	elseif s == "/h " then
		nChannel = PLAYER_TALK_CHANNEL.WORLD
	elseif s == "/t " then
		nChannel = PLAYER_TALK_CHANNEL.RAID
	elseif s == "/f " then
		nChannel = PLAYER_TALK_CHANNEL.FORCE
	elseif s == "/c " then
		nChannel = PLAYER_TALK_CHANNEL.CAMP
	elseif s == "/m " then
		nChannel = PLAYER_TALK_CHANNEL.MENTOR
	elseif s == "/o " then
		nChannel = PLAYER_TALK_CHANNEL.FRIENDS
	elseif s == "/1 " then
		nChannel = PLAYER_TALK_CHANNEL.CHANNEL1
	elseif s == "/2 " then
		nChannel = PLAYER_TALK_CHANNEL.CHANNEL2
	elseif s == "/3 " then
		nChannel = PLAYER_TALK_CHANNEL.CHANNEL3
	elseif s == "/4 " then
		nChannel = PLAYER_TALK_CHANNEL.CHANNEL4
	elseif s == "/5 " then
		nChannel = PLAYER_TALK_CHANNEL.CHANNEL5
	elseif s == "/6 " then
		nChannel = PLAYER_TALK_CHANNEL.CHANNEL6
	elseif s == "/7 " then
		nChannel = PLAYER_TALK_CHANNEL.CHANNEL7
	elseif s == "/8 " then
		nChannel = PLAYER_TALK_CHANNEL.CHANNEL8
	end
	
	if nChannel then
		if nChannel ~= PLAYER_TALK_CHANNEL.WHISPER then
			player.Talk(nChannel, "", t)
		end	

		local argS = arg0
		arg0 = nChannel
		FireEvent("ON_USE_CHAT")
		arg0 = argS
	end
	
	edit:ClearText()
	EditBox.AppendHistory(tSrcData)
	return true
end

function EditBox.OnRButtonClick()
	local szName = this:GetName()
	if szName == "Btn_Face" then
	  if IsOpenEmotionPanel() then
	    CloseEmotionPanel()
	  else
	  	local x, y = this:GetAbsPos()
	  	local w, h = this:GetSize()
	    OpenEmotionPanel(false, {x, y, w, h})
	  end
	  return 1
	end
end

function EditBox.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_Channel" then
		EditBox.OnOpenChannel(this)
	elseif szName == "Btn_Enter" then
		local edit = this:GetParent():Lookup("Edit_Input")
		if EditBox.ProcessInput(edit) then
			CloseEditBox()
		else
			Station.SetFocusWindow(edit)
		end
  elseif szName == "Btn_Face" then
  	if IsOpenEmotionPanel() then
	    CloseEmotionPanel()
	  else
	    local x, y = this:GetAbsPos()
	  	local w, h = this:GetSize()
	    OpenEmotionPanel(false, {x, y, w, h})
	  end
	  return 1
	end
end

function EditBox.GetEditFontColorByHeader(szHeader)
	local s = EditBox.szHeader
	if szHeader then
		s = szHeader
	end
	local r, g, b = 255, 255, 255 --默认字体
	if s == "/gm " then
	elseif s == "/" then
	elseif s == "/s " then
		r, g, b = GetMsgFontColor("MSG_NORMAL")
	elseif s == "/p " then
		r, g, b = GetMsgFontColor("MSG_PARTY")
	elseif s == "/y " then
		r, g, b = GetMsgFontColor("MSG_MAP")
	elseif s == "/b " then
		r, g, b = GetMsgFontColor("MSG_BATTLE_FILED")		
	elseif s == "/g " then
		r, g, b = GetMsgFontColor("MSG_GUILD")
	elseif s == "/h " then
		r, g, b = GetMsgFontColor("MSG_WORLD")
	elseif s == "/t " then
		r, g, b = GetMsgFontColor("MSG_TEAM")
	elseif s == "/f " then
		r, g, b = GetMsgFontColor("MSG_SCHOOL")
	elseif s == "/c " then
		r, g, b = GetMsgFontColor("MSG_CAMP")
	elseif s == "/m " then
		r, g, b = GetMsgFontColor("MSG_MENTOR")
	elseif s == "/o " then
		r, g, b = GetMsgFontColor("MSG_FRIEND")
	elseif s == "/1 " then
		r, g, b = GetMsgFontColor("MSG_GROUP")
	elseif s == "/2 " then
		r, g, b = GetMsgFontColor("MSG_GROUP")
	elseif s == "/3 " then
		r, g, b = GetMsgFontColor("MSG_GROUP")
	elseif s == "/4 " then
		r, g, b = GetMsgFontColor("MSG_GROUP")
	elseif s == "/5 " then
		r, g, b = GetMsgFontColor("MSG_GROUP")
	elseif s == "/6 " then
		r, g, b = GetMsgFontColor("MSG_GROUP")
	elseif s == "/7 " then
		r, g, b = GetMsgFontColor("MSG_GROUP")
	elseif s == "/8 " then
		r, g, b = GetMsgFontColor("MSG_GROUP")
	else
		if string.sub(s, 1, 3) == "/w " then
			r, g, b = GetMsgFontColor("MSG_WHISPER")
		end
	end
	return r, g, b
end

function EditBox.Clear()
	EditBox.nIndex = nil
	EditBox.CurrentInput = nil
	local edit = Station.Lookup("Lowest2/EditBox/Edit_Input")
	edit:ClearText()
end

function EditBox.OnSetFocus()
	EditBox.bOnFocus = true
	FireEvent("EDIT_BOX_ON_FOCUS")
	
	FireHelpEvent("OnOpenpanel", "EDITBOX", this)
end

function EditBox.OnKillFocus()
	EditBox.bOnFocus = false
	FireEvent("EDIT_BOX_ON_FOCUS")
	
	FireHelpEvent("OnCloseComment", "Comment_EditBox")
end

function EditBox.OnMouseEnter()
	EditBox.bMouseEnter = true
	FireEvent("EDIT_BOX_MOUSE_ENTER")
end

function EditBox.OnMouseLeave()
	EditBox.bMouseEnter = false
	FireEvent("EDIT_BOX_MOUSE_ENTER")
end

function EditBox.AdjustPos(frame)
	local mChat = ChatPanel_Base_GetMgFrame()
	if mChat then
		frame:SetPoint("TOPLEFT", 0, 0, mChat, "BOTTOMLEFT", 4, 1)
	else
		frame:SetPoint("BOTTOMLEFT", 0, 0, "BOTTOMLEFT", 4, -140)
	end
end

function EditBox_AppendLinkItem(dwItemIDOrdwBox, dwX)
	if not IsEditBoxOpened() then
		OpenEditBox()
	end
	
	local item = nil
	if dwX then
		item = GetPlayerItem(GetClientPlayer(), dwItemIDOrdwBox, dwX)
	else
		item = GetItem(dwItemIDOrdwBox)
	end
	if not item then
		return false
	end
	local szName = "["..GetItemNameByItem(item).."]"
	
	local edit = Station.Lookup("Lowest2/EditBox/Edit_Input")
	edit:InsertObj(szName, {type = "item", text = szName, item = item.dwID})
	
	Station.SetFocusWindow(edit)
	return true
end

function EditBox_AppendLinkItemInfo(nVersion, nTabtype, nIndex, nBookInfo)
	if not IsEditBoxOpened() then
		OpenEditBox()
	end
	
	local itemInfo = GetItemInfo(nTabtype, nIndex)
	if not itemInfo then
		return false
	end
	if itemInfo.nGenre == ITEM_GENRE.BOOK then
		if not nBookInfo then
			return false
		end
		
		local nBookID, nSegmentID = GlobelRecipeID2BookID(nBookInfo)
		local szName = "["..Table_GetSegmentName(nBookID, nSegmentID).."]"
		
		local edit = Station.Lookup("Lowest2/EditBox/Edit_Input")
		edit:InsertObj(szName, {type = "book", text = szName, version = nVersion, tabtype = nTabtype, index = nIndex, bookinfo = nBookInfo})
		Station.SetFocusWindow(edit)
	else
		local szName = "["..GetItemNameByItemInfo(itemInfo).."]"
		
		local edit = Station.Lookup("Lowest2/EditBox/Edit_Input")
		edit:InsertObj(szName, {type = "iteminfo", text = szName, version = nVersion, tabtype = nTabtype, index = nIndex})
		Station.SetFocusWindow(edit)
	end
	return true
end

function EditBox_AppendLinkBook(nBookInfo)
	if not IsEditBoxOpened() then
		OpenEditBox()
	end
		
	if not nBookInfo then
		return false
	end
	
	local nBookID, nSegmentID = GlobelRecipeID2BookID(nBookInfo)
	local nVersion, nTabtype = GLOBAL.CURRENT_ITEM_VERSION, 5
	local nIndex = Table_GetBookItemIndex(nBookID, nSegmentID)
	
	local szName = "["..Table_GetSegmentName(nBookID, nSegmentID).."]"
	
	local itemInfo = GetItemInfo(nTabtype, nIndex)
	if not itemInfo or itemInfo.nGenre ~= ITEM_GENRE.BOOK then
		return false
	end
		
	local edit = Station.Lookup("Lowest2/EditBox/Edit_Input")
	edit:InsertObj(szName, {type = "book", text = szName, version = nVersion, tabtype = nTabtype, index = nIndex, bookinfo = nBookInfo})
	Station.SetFocusWindow(edit)
	return true
end

function EditBox_AppendLinkPlayer(szPlayerName)
	if not IsEditBoxOpened() then
		OpenEditBox()
	end

	local edit = Station.Lookup("Lowest2/EditBox/Edit_Input")
	edit:InsertObj("["..szPlayerName.."]", {type = "name", text = "["..szPlayerName.."]", name = szPlayerName})
	
	Station.SetFocusWindow(edit)
	return true
end

function EditBox_AppendLinkQuest(dwQuestID)
	if not IsEditBoxOpened() then
		OpenEditBox()
	end
	local tQuestStringInfo = Table_GetQuestStringInfo(dwQuestID)
	if not tQuestStringInfo then
		return false
	end
	
	local szName = "["..tQuestStringInfo.szName.."]"

	local edit = Station.Lookup("Lowest2/EditBox/Edit_Input")
	edit:InsertObj(szName, {type = "quest", text = szName, questid = dwQuestID})
	
	Station.SetFocusWindow(edit)
	return true
end

function EditBox_AppendLinkRecipe(dwCraftID, dwRecipeID)
	if not IsEditBoxOpened() then
		OpenEditBox()
	end
	
	local recipe = GetRecipe(dwCraftID, dwRecipeID)
	if not recipe then
		return false
	end
	
	local szRecipeName = Table_GetRecipeName(dwCraftID, dwRecipeID)
	local szName = "["..szRecipeName.."]"

	local edit = Station.Lookup("Lowest2/EditBox/Edit_Input")
	edit:InsertObj(szName, {type = "recipe", text = szName, craftid = dwCraftID, recipeid = dwRecipeID})
	
	Station.SetFocusWindow(edit)
	return true
end

function EditBox_AppendLinkEnchant(dwProID, dwCraftID, dwRecipeID)
	if not IsEditBoxOpened() then
		OpenEditBox()
	end
	
	local szName = "["..Table_GetEnchantName(dwProID, dwCraftID, dwRecipeID).."]"
	
	local edit = Station.Lookup("Lowest2/EditBox/Edit_Input")
	edit:InsertObj(szName, {type = "enchant", text = szName, proid = dwProID, craftid = dwCraftID, recipeid = dwRecipeID})
	
	Station.SetFocusWindow(edit)
	return true
end

function EditBox_AppendLinkSkill(skillKey)
	if not IsEditBoxOpened() then
		OpenEditBox()
	end
	
	if not skillKey then
		return
	end
	
	local szName = "["..Table_GetSkillName(skillKey.skill_id, skillKey.skill_level).."]"

	skillKey.type = "skill"
	skillKey.text = szName

	local edit = Station.Lookup("Lowest2/EditBox/Edit_Input")
	edit:InsertObj(szName, skillKey)
	
	Station.SetFocusWindow(edit)
	return true
end

function EditBox_AppendLinkSkillRecipe(dwID, dwLevel)
	if not IsEditBoxOpened() then
		OpenEditBox()
	end
	local tSkillRecipe = Table_GetSkillRecipe(dwID, dwLevel)
	local szName = "[]"
	if tSkillRecipe then
		szName = "["..tSkillRecipe.szName.."]"
	end
	local edit = Station.Lookup("Lowest2/EditBox/Edit_Input")
	edit:InsertObj(szName, {type = "skillrecipe", text = szName, id = dwID, level = dwLevel})
	
	Station.SetFocusWindow(edit)
	return true
end

function EditBox_AppendLinkAchievement(dwAchievementID)
	if not IsEditBoxOpened() then
		OpenEditBox()
	end
	
	local aAchievement = g_tTable.Achievement:Search(dwAchievementID)
	if not aAchievement then
		return
	end
	local szName = "["..aAchievement.szName.."]"
	local edit = Station.Lookup("Lowest2/EditBox/Edit_Input")
	edit:InsertObj(szName, {type = "achievement", text = szName, id = dwAchievementID})
	
	Station.SetFocusWindow(edit)
	return true
end

function EditBox_AppendLinkDesignation(dwDesignation, bPrefix)
	if not IsEditBoxOpened() then
		OpenEditBox()
	end
	local aDesignation 
	if bPrefix then
		aDesignation = g_tTable.Designation_Prefix:Search(dwDesignation)
	else
		aDesignation = g_tTable.Designation_Postfix:Search(dwDesignation)
	end
	
	if not aDesignation then
		return
	end
	
	local szName = "["..aDesignation.szName.."]"
	local edit = Station.Lookup("Lowest2/EditBox/Edit_Input")
	edit:InsertObj(szName, {type = "designation", text = szName, id = dwDesignation, prefix = bPrefix})
	
	Station.SetFocusWindow(edit)
	return true
end

function EditBox_AppendEventLink(szName, szLinkInfo)
	if not IsEditBoxOpened() then
		OpenEditBox()
	end
	
	local szText = szName
	local edit = Station.Lookup("Lowest2/EditBox/Edit_Input")
	edit:InsertObj(szText, {type = "eventlink", text = szText, name = szName, linkinfo = szLinkInfo or ""})
	
	Station.SetFocusWindow(edit)
	return true
end

function IsEditBoxOnFocus()
  if EditBox.bOnFocus then
    return true
  end
  return false
end

function IsEditBoxMouseEnter()
  if EditBox.bMouseEnter then
    return true
  end
  return false
end

function IsChannelHeader(szHeader)
	if EditBox.GetChannel(szHeader) then
		return true
	end
	return false
end

function EditBox.OnFrameKeyDown()
	local nResult = 0
	local focusWnd = Station.GetFocusWindow()
	if not focusWnd then
		return 0
	elseif focusWnd and focusWnd:GetName() ~= "Edit_Input" then
		return 0
	end
  
	local szKey = GetKeyName(Station.GetMessageKey())
	local szHeader = EditBox.szHeader
    local nAimIndex = nil
	local aChannel = 
	{
	  [1] = "/w ", 
	  [2] = "/ ",
	  [3] = "/s ",
	  [4] = "/p ",
	  [5] = "/y ",
	  [6] = "/g ",
	  [7] = "/gm ", 
	  nSize = 6
	}
	if g_bDebugMode then
	  aChannel.nSize = aChannel.nSize  + 1
	end
	
	if string.sub(szHeader, 1, 3) == aChannel[1] then
	  nAimIndex = 1
	else
		for i = 2, aChannel.nSize, 1 do
	    if aChannel[i] == szHeader then
	      nAimIndex = i
	      break
	    end
	  end
	end

	if not nAimIndex then
	  return 0
	end
	
	if szKey == "PageUp" then
	  if nAimIndex == 1 then
	    nAimIndex = aChannel.nSize
	  else
	    nAimIndex = nAimIndex - 1
	  end
	  EditBox.AdjustHeaderShow(aChannel[nAimIndex])
	  nResult = 1
	elseif szKey == "PageDown" then
	  if nAimIndex == aChannel.nSize then
	    nAimIndex = 1
	  else 
	    nAimIndex = nAimIndex + 1
	  end
	  EditBox.AdjustHeaderShow(aChannel[nAimIndex])
	  nResult = 1
	end	  
	return nResult
end

function EditBox_GetChannel()
	local szHeader = EditBox.szHeader
	local szName = nil
	local nChannel = nil
  	if not szHeader then
  	elseif string.sub(szHeader, 1, 3) == "/w " then
		szName = string.sub(szHeader, 4, -2)
		nChannel = PLAYER_TALK_CHANNEL.WHISPER
	elseif szHeader == "/ " then
	   nChannel = PLAYER_TALK_CHANNEL.FACE
	elseif szHeader == "/s " then
		nChannel = PLAYER_TALK_CHANNEL.NEARBY
	elseif szHeader == "/p " then
		nChannel = PLAYER_TALK_CHANNEL.TEAM
	elseif szHeader == "/y " then
		nChannel = PLAYER_TALK_CHANNEL.SENCE
	elseif szHeader == "/g " then
		nChannel = PLAYER_TALK_CHANNEL.TONG
	elseif szHeader == "/h " then
		nChannel = PLAYER_TALK_CHANNEL.WORLD
	elseif szHeader == "/t " then
		nChannel = PLAYER_TALK_CHANNEL.RAID
	elseif szHeader == "/f " then
		nChannel = PLAYER_TALK_CHANNEL.SCHOOL
	elseif szHeader == "/c " then
		nChannel = PLAYER_TALK_CHANNEL.CAMP
	elseif szHeader == "/m " then
		nChannel = PLAYER_TALK_CHANNEL.MENTOR
	elseif szHeader == "/o " then
		nChannel = PLAYER_TALK_CHANNEL.FRIEND
	elseif szHeader == "/b " then
		nChannel = PLAYER_TALK_CHANNEL.BATTLE_FIELD
	elseif szHeader == "/1 " then
		nChannel = PLAYER_TALK_CHANNEL.CHANNEL1
	elseif szHeader == "/2 " then
		nChannel = PLAYER_TALK_CHANNEL.CHANNEL2
	elseif szHeader == "/3 " then
		nChannel = PLAYER_TALK_CHANNEL.CHANNEL3
	elseif szHeader == "/4 " then
		nChannel = PLAYER_TALK_CHANNEL.CHANNEL4
	elseif szHeader == "/5 " then
		nChannel = PLAYER_TALK_CHANNEL.CHANNEL5
	elseif szHeader == "/6 " then
		nChannel = PLAYER_TALK_CHANNEL.CHANNEL6
	elseif szHeader == "/7 " then
		nChannel = PLAYER_TALK_CHANNEL.CHANNEL7
	elseif szHeader == "/8 " then
		nChannel = PLAYER_TALK_CHANNEL.CHANNEL8
	end
	return nChannel, szName
end

function OpenEditBox()
--	EditBox.Clear()
	EditBox.nIndex = nil
	EditBox.CurrentInput = nil

	local frame = Station.Lookup("Lowest2/EditBox")
	if frame then
		EditBox.AdjustPos(frame)
		frame:Show()
		local hEditInput = frame:Lookup("Edit_Input")
		Station.SetFocusWindow(hEditInput)
		FireHelpEvent("OnOpenpanel", "EDITBOX", hEditInput)
	end
end

function CloseEditBox()
--	EditBox.Clear()
	EditBox.nIndex = nil
	EditBox.CurrentInput = nil

	local frame = Station.Lookup("Lowest2/EditBox")
	if frame then
		if IsEditBoxAlwaysShow() then
			Station.SetFocusWindow(nil)
		else
			frame:Hide()
		end
		FireHelpEvent("OnCloseComment", "Comment_EditBox")
	end
end

function IsEditBoxOpened()
	local frame = Station.Lookup("Lowest2/EditBox")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end

function EditBox_TalkToSomebody(szName)
	if not IsEditBoxOpened() then
		OpenEditBox()
	end
	
	local edit = Station.Lookup("Lowest2/EditBox/Edit_Input")
	local t = edit:GetTextStruct()
	t = t or {}
	if t[1] then
		if t[1].type == "text" then
			t[1].text = "/w "..szName.." "..t[1].text
		else
			table.insert(t, 1, {type = "text", text = "/w "..szName.." "})
		end
	else
		t[1] = {type = "text", text = "/w "..szName.." "}
	end
	EditBox.SetEditTextStruct(edit, t)
	Station.SetFocusWindow(edit)
end

function EditBox_TalkInMsg(szMsgName)
	if not IsEditBoxOpened() then
		OpenEditBox()
	end
	local szHeader
	if szMsgName == g_tStrings.STR_TALK_HEAD_PARTY then --"[小队]",
		szHeader = "/p "
	elseif szMsgName == g_tStrings.STR_TALK_HEAD_TONG then --"[帮会]",
		szHeader = "/g "
	elseif szMsgName == g_tStrings.STR_TALK_HEAD_SENCE then --"[地图]",
		szHeader = "/y "
	elseif szMsgName == g_tStrings.STR_TALK_HEAD_BATTLE_FILED then --"[战场]",
		szHeader = "/b "
	elseif szMsgName == g_tStrings.STR_TALK_HEAD_WORLD then --"[世界]",
		szHeader = "/h "
	elseif szMsgName == g_tStrings.STR_TALK_HEAD_TEAM then --"[团队]",
		szHeader = "/t "
	elseif szMsgName == g_tStrings.STR_TALK_HEAD_SCHOOL then --"[门派]",
		szHeader = "/f "
	elseif szMsgName == g_tStrings.STR_TALK_HEAD_CAMP then --"[阵营]",
		szHeader = "/c "
	elseif szMsgName == g_tStrings.STR_TALK_HEAD_MENTOR then
		szHeader = "/m "
	elseif szMsgName == g_tStrings.STR_TALK_HEAD_FRIEND then
		szHeader = "/o "
	end
	
	if szHeader then
		EditBox.AdjustHeaderShow(szHeader)
		local edit = Station.Lookup("Lowest2/EditBox/Edit_Input")
		Station.SetFocusWindow(edit)
		local t = edit:GetTextStruct()
		if t and #t == 1 and t[1] and t[1].type == "text" and (t[1].text == "/w " or t[1].text == "/w　") then
			edit:ClearText()
		end
	end
end

function EditBox_TalkSomething(tData)
	if not IsEditBoxOpened() then
		OpenEditBox()
	end
	
	local edit = Station.Lookup("Lowest2/EditBox/Edit_Input")
	local t = edit:GetTextStruct()
	t = t or {}
	table.insert(t, tData)
	
	EditBox.SetEditTextStruct(edit, t)
	Station.SetFocusWindow(edit)
end

function EditBox_OnMsgColorChanged()
	EditBox.AdjustHeaderShow()
end

function IsEditBoxAlwaysShow()
	return EditBox.bAlwaysShow
end

function SetEditBoxAlwaysShow(bAlwaysShow)
	EditBox.bAlwaysShow = bAlwaysShow
	if IsEditBoxAlwaysShow() then
		if not IsEditBoxOpened() then
			OpenEditBox()
			CloseEditBox()
		end
	else
		if IsEditBoxOpened() then
			CloseEditBox()
		end
	end
end
