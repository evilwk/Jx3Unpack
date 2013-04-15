
function UpdatePlayerTitleEffect(dwPlayerID)
	if not GetPlayer(dwPlayerID) then	-- Player is not in the scene or offline
		return
	end
	
	local hPlayer = GetClientPlayer()
	local dwEffectID = TITLE_EFFECT_NONE
	if hPlayer.IsInParty() then	-- party mark
		local tPartyMark = GetClientTeam().GetTeamMark()
		if tPartyMark and tPartyMark[dwPlayerID] then
			local nPartyMark = tPartyMark[dwPlayerID]
			assert(nPartyMark > 0 and nPartyMark <= #PARTY_TITLE_MARK_EFFECT_LIST)
			dwEffectID = PARTY_TITLE_MARK_EFFECT_LIST[nPartyMark]
		end
	end
	SceneObject_SetTitleEffect(TARGET.PLAYER, dwPlayerID, dwEffectID)
end

function OutputPlayerTip(dwPlayerID, Rect)
	--如果是自己，则不显示tip
	local player = GetPlayer(dwPlayerID)
	if not player then
		return
	end
	
	local clientPlayer = GetClientPlayer()
	
	if not IsCursorInExclusiveMode() then	
		if clientPlayer.dwID == dwPlayerID then
			return
		end
	end
	
	local r, g, b = GetForceFontColor(dwPlayerID, clientPlayer.dwID)
	local szTip = ""

	--------------名字-------------------------
    szTip = szTip.."<Text>text="..EncodeComponentsString(FormatString(g_tStrings.STR_NAME_PLAYER, player.szName)).." font=80".." r="..r.." g="..g.." b="..b.." </text>"
    
    -------------称号----------------------------        
    if player.szTitle ~= "" then
    	szTip = szTip.."<Text>text="..EncodeComponentsString("<"..player.szTitle..">\n").." font=0 </text>"
    end
    
    if player.dwTongID ~= 0 then
    	local szName = GetTongClient().ApplyGetTongName(player.dwTongID)
    	if szName and szName ~= "" then
    		szTip = szTip.."<Text>text="..EncodeComponentsString("["..szName.."]\n").." font=0 </text>"
    	end
    end
    
    -------------等级----------------------------
    if player.nLevel - clientPlayer.nLevel > 10 and not clientPlayer.IsPlayerInMyParty(dwPlayerID) then 
    	szTip = szTip.."<Text>text="..EncodeComponentsString(g_tStrings.STR_PLAYER_H_UNKNOWN_LEVEL).." font=82 </text>"
    else
    	szTip = szTip.."<Text>text="..EncodeComponentsString(FormatString(g_tStrings.STR_PLAYER_H_WHAT_LEVEL, player.nLevel)).." font=82 </text>"
    end
    
	if g_tReputation.tReputationTable[player.dwForceID] then
		szTip = szTip.."<Text>text="..EncodeComponentsString(g_tReputation.tReputationTable[player.dwForceID].szName.."\n").." font=82 </text>"
	end
	
	if IsParty(dwPlayerID, clientPlayer.dwID) then
		local hTeam = GetClientTeam()
		local tMemberInfo = hTeam.GetMemberInfo(dwPlayerID)
		if tMemberInfo then
			local szMapName = Table_GetMapName(tMemberInfo.dwMapID)
			if szMapName then
				szTip = szTip.."<Text>text="..EncodeComponentsString(szMapName.."\n").." font=82 </text>"
			end
		end
	end
    
	if player.bCampFlag then
		szTip = szTip .. GetFormatText(g_tStrings.STR_TIP_CAMP_FLAG, 163)
	end
	
    local nCamp = player.nCamp
    szTip = szTip .. GetFormatText(g_tStrings.STR_GUILD_CAMP_NAME[nCamp], 82)
    
    if IsCtrlKeyDown() then
    	szTip = szTip.."<Text>text="..EncodeComponentsString(FormatString(g_tStrings.TIP_PLAYER_ID, player.dwID)).." font=102 </text>"
    	szTip = szTip.."<Text>text="
		szTip = szTip..EncodeComponentsString(FormatString(g_tStrings.TIP_REPRESENTID_ID, player.dwModelID.." "..var2str(player.GetRepresentID()))).." font=102 </text>" 
    end
    
    OutputTip(szTip, 345, Rect)
end

--同阵营返回true，敌对，返回false
function InteractPlayer(dwPlayerID)
	local dwClientPlayerID = GetClientPlayer().dwID
	if IsEnemy(dwClientPlayerID, dwPlayerID) then
		return false
	else
		return true
	end
end


function NeedHightlightPlayer(dwPlayerID)
	--TODO:可能会根据技能，势力，自身状态之类的条件做
	return false
end


function CanSelectPlayer(dwPlayerID)
	--自己
	local clientPlayer = GetClientPlayer()
	if clientPlayer.dwID == dwPlayerID then
		return false
	end
	
	return true
end

function ChangeCursorWhenOverPlayer(dwPlayerID)
	local dwClientPlayerID = GetClientPlayer().dwID
	if IsCursorInExclusiveMode() then	
		return
	end
	
	if dwClientPlayerID == dwPlayerID then
		Cursor.Switch(CURSOR.NORMAL)
	elseif IsEnemy(dwClientPlayerID, dwPlayerID) then
		Cursor.Switch(CURSOR.ATTACK)
	else
		local player = GetPlayer(dwPlayerID)
		if IsParty(dwClientPlayerID, dwPlayerID) then
			Cursor.Switch(CURSOR.NORMAL)
		elseif IsAlly(dwClientPlayerID, dwPlayerID) then
			Cursor.Switch(CURSOR.NORMAL)
		else
			Cursor.Switch(CURSOR.NORMAL)
		end
	end
end

function NeedHightlightPlayerWhenOver(dwPlayerID)
	if GetClientPlayer().dwID == dwPlayerID then
		return false
	end
	return true
end

function TradingInviteToPlayer(dwID)
	local player = GetPlayer(dwID)
	local ClientPlayer = GetClientPlayer()
	
	if not player then
	    OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_ERROR_TRADING_TARGET_NOT_IN_GAME)
	end
	
	if not player.CanDialog(ClientPlayer) then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_ERROR_TRADING_TOO_FAR)
	elseif IsEnemy(ClientPlayer.dwID, player.dwID) then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_TRADING_ENEMY)
    else
		if CheckHaveLocked(SAFE_LOCK_EFFECT_TYPE.TRADE) then
			return
		end
	
		local bResult = ClientPlayer.TradingInviteRequest(dwID)
		if bResult then
			OutputMessage("MSG_ANNOUNCE_YELLOW", FormatString(g_tStrings.STR_TRADING_INVITE2, player.szName))
		end
	end
	
end

function ViewInviteToPlayer(dwPlayerID)
	local player = GetPlayer(dwPlayerID)
	if player then
		PeekOtherPlayer(dwPlayerID)
	else
		OutputMessage("MSG_ANNOUNCE_RED", FormatString(g_tStrings.STR_VIEW_INVITE_TOO_FAR, player.szName))
	end
end

function GetPlayerDesignation(dwPlayerID)
	local player = GetPlayer(dwPlayerID)	
	if not player then
		return ""
	end

	local nPrefix = player.GetCurrentDesignationPrefix()
	local nPostfix = player.GetCurrentDesignationPostfix()
	local nGeneration = player.GetDesignationGeneration()
	local nCharacter = player.GetDesignationByname()
	local bShow = player.GetDesignationBynameDisplayFlag()
	local nForceID = player.dwForceID

	local szDesignation = ""
	if nPrefix ~= 0 then
		local aPrefix = g_tTable.Designation_Prefix:Search(nPrefix)
		if aPrefix then
			szDesignation = szDesignation..aPrefix.szName
		end
	end
	
	if nPostfix ~= 0 then
		local aPostfix = g_tTable.Designation_Postfix:Search(nPostfix)
		if aPostfix then
			szDesignation = szDesignation..aPostfix.szName
		end
	end
	
	if bShow then
		local aGen = g_tTable.Designation_Generation:Search(nForceID, nGeneration)
		if aGen then
			szDesignation = szDesignation..aGen.szName
			if aGen.szCharacter and aGen.szCharacter ~= "" then
				local aCharacter = g_tTable[aGen.szCharacter]:Search(nCharacter)
				if aCharacter then
					szDesignation = szDesignation..aCharacter.szName
				end
			end
		end
	end
	return szDesignation
end

g_bFrameShakeFlag = false
RegisterCustomData("g_bFrameShakeFlag")

function IsFrameShake()
	return g_bFrameShakeFlag
end

function SetFrameShake(bFrameShake)
	g_bFrameShakeFlag = bFrameShake
end

function IsRoleMale(nRoleType)
	if nRoleType == ROLE_TYPE.STANDARD_MALE or nRoleType == ROLE_TYPE.STRONG_MALE or nRoleType == ROLE_TYPE.LITTLE_BOY then
		return true
	end
	return false
end

function IsRoleFemale()
	if nRoleType == ROLE_TYPE.STANDARD_FEMALE or nRoleType == ROLE_TYPE.SEXY_FEMALE or nRoleType == ROLE_TYPE.LITTLE_GIRL then
		return true
	end
	return false
end

function CheckPlayerIsRemote(dwPlayerID, szMsg)
    if not szMsg then
        szMsg = g_tStrings.STR_REMOTE_NOT_TIP
    end
    if not dwPlayerID then
        dwPlayerID = GetClientPlayer().dwID
    end
    if IsRemotePlayer(dwPlayerID) then
        OutputMessage("MSG_ANNOUNCE_RED", szMsg);
        OutputMessage("MSG_SYS", szMsg.."\n");
        return true;
    end
    return false
end

