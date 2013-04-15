g_tJiangHuClient = {};

function GetJiangHuData()
  local nSize = table.maxn(g_tJiangHuClient)
  if nSize == 0 then
    return g_tExpression.tJiangHu;
  else 
    return g_tJiangHuClient;
  end
end


function IsJiangHuWord(szText)
  local tJiangHu = GetJiangHuData()
	for k, v in pairs(tJiangHu) do
		if szText == v[1] then
			return true;
		end
	end
	
	return false;
end;

function GetJiangHuWord(szText)
  local tJiangHu = GetJiangHuData()
	for k, v in pairs(tJiangHu) do
		if szText == v[1] then
			return v;
		end
	end

	return nil
end;

function ProcessJiangHuWord(szJiangHuWord)
	local player = GetClientPlayer()
	if not player then
	  return 
	end
	
	local t = GetJiangHuWord(szJiangHuWord)
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
	end

	if not szText then
	  szText = t[2]
	end
	
	local tWord =
	{
		{type = "emotion"},
		{type = "text", text=szText},
	}
	tWord = EmotionParseName(tWord, "$N", player.szName)
	
	if szName then
		tWord = EmotionParseName(tWord, "$n", szName)
	end
	
	player.Talk(nChannel, szWhisperName, tWord)
	return
end

