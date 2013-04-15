function GetMapName(dwMapID)
	if not dwMapID then
        Trace("[UI GetPartyMemberMapName] error get dwMapID Player="..dwPlayerID..")\n")
		return
	end
	
	local szMapName = Table_GetMapName(dwMapID)
	if not szMapName then
        Trace("[UI GetPartyMemberMapName] error get Table_GetMapName("..dwMapID..")\n")
		return
	end
	
	return szMapName
end


function GetPartyMemberMapID(dwPlayerID)
	local player = GetPlayer(dwPlayerID)
	if player and player.IsInParty() and player.IsInMyParty(dwPlayerID) then
		local hTeam = GetClientTeam()
		local tMemberInfo = hTeam.GetMemberInfo(dwPlayerID)
		if tMemberInfo then
			return tMemberInfo.dwMapID
		end
	end
end


function GetClientPlayerMapID()
	local clientPlayer = GetClientPlayer()
	if not clientPlayer then
        Trace("[UI GetClientPlayerMapID] error get client player\n")
        return
	end
	
	local scene = clientPlayer.GetScene()
	if not scene then
        Trace("[UI GetClientPlayerMapID] error get scene\n")
        return
	end
	
	return scene.dwMapID
end


function GetPartyMemberMapName(dwPlayerID)
	local dwMapID = GetPartyMemberMapID(dwPlayerID)
	if not dwMapID then
        Trace("[UI GetPartyMemberMapName] error get map id, maybe player("..dwPlayerID..") not party member \n")
		return
	end
	
	return GetMapName(dwMapID)
end


function GetClientPlayerMapName()
	local dwMapID = GetClientPlayerMapID()
	if not dwMapID then
        Trace("[UI GetClientPlayerMapName] error map id\n")
	end
	
	return GetMapName(dwMapID)
end
