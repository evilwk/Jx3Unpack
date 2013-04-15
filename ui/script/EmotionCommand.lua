function IsEmotion(szText)
	for k, v in pairs(g_tExpression.tEmotion) do
		if szText == v[1] then
			return true;
		end
	end
	return false;
end;

function GetEmotion(szText)
	for k, v in pairs(g_tExpression.tEmotion) do
		if szText == v[1] then
			return v;
		end
	end

	return nil
end;

function EmotionParseName(tTextData, szPattern, szReplace)
	local tResult = {}
	for k, tText in ipairs(tTextData) do
		if tText.type == "text" then
			local szSrc, szText = tText.text, ""
			local nPos, nLen = 1, string.len(szSrc)
			while (nPos <= nLen) do
				local nStart, nEnd = StringFindW(szSrc, szPattern, nPos)
				if not nStart then
					szText = string.sub(szSrc, nPos)
					table.insert(tResult, {type="text", text=szText})
					break
				end	
				
				szText = string.sub(szSrc, nPos, nStart - 1) or ""
				if szText ~= "" then
					table.insert(tResult, {type="text", text=szText})
				end
				
				table.insert(tResult, {type="name", text="["..szReplace.."]", name=szReplace})
				nPos = nEnd + 1
			end
		else
			table.insert(tResult, tText)
		end
	end
	
	return tResult
end

function ProcessEmotion(szEmotion)
	local player = GetClientPlayer()
	if not player then 
		return
	end
	
	local t = GetEmotion(szEmotion)
	if not t then
		return
	end 
	
	local nChannel, szWhisperName = EditBox_GetChannel()
	if not nChannel then
	  nChannel = PLAYER_TALK_CHANNEL.NEARBY
	end
		
	local dwTargetType, dwTargetID 
	local szName, szText
	
	if not szWhisperName then
		szWhisperName = ""
		dwTargetType, dwTargetID = player.GetTarget()
	end

	if szWhisperName ~= "" then
		szName = szWhisperName
		szText = t[3]
	elseif dwTargetType == TARGET.PLAYER then
		local playerT = GetPlayer(dwTargetID)
		if playerT then
			szName = playerT.szName
			szText = t[3]
		end
	elseif dwTargetType == TARGET.NPC then
		local npcT = GetNpc(dwTargetID)
		if npcT then
			szName = npcT.szName
			szText = t[3]
		end
	else  
		dwTargetID = 0
	end

	if not szText then
		szText = t[2]
	end
		
	local tWord =
	{
		{type = "emotion"},
		{type="text", text=szText}
	}
	
	tWord = EmotionParseName(tWord, "$N", player.szName)
	if szName then
		tWord = EmotionParseName(tWord, "$n", szName)
	end
	
	-- ·¢ËÍ±íÇé
	player.Talk(nChannel, szWhisperName, tWord)
	DoAction(dwTargetID, t[4]);	
	
	local argS0, argS1, argS2 = arg0, arg1, arg2
	arg0, arg1, arg2 = dwTargetType, dwTargetID, szEmotion
	FireEvent("ON_USE_EMOTION")
	arg0, arg1, arg2 = argS0, argS1, argS2
	
end

function GetEmotionPopupMenu()
	local menu = {fnAction = ProcessEmotion}
	for k, v in pairs(g_tExpression.tEmotion) do
		table.insert(menu, {szOption = v[1], UserData = v[1]})
	end
	return menu
end
