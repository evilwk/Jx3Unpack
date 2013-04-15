function GetForceFontColor(dwPeerID, dwSelfID)
	local bInParty = false
	local player = GetClientPlayer()
	if player then
		if player.dwID == dwPeerID then
			bInParty = player.IsPlayerInMyParty(dwSelfID)
		elseif player.dwID == dwSelfID then
			bInParty = player.IsPlayerInMyParty(dwPeerID)
		end
	end
	
	local src = dwPeerID
	local dest = dwSelfID
	
	if IsPlayer(dwPeerID) and IsPlayer(dwSelfID) then
	    src = dwSelfID
	    dest = dwPeerID
	end
	
	local r, g, b
	if dwSelfID == dwPeerID then
		r, g, b = 255, 255, 0
	elseif bInParty or IsParty(src, dest) then
		r, g, b = GetPartyMemberFontColor()
	elseif IsEnemy(src, dest) then
		r, g, b = 255, 0, 0
	elseif IsNeutrality(src, dest) then
		r, g, b = 255, 255, 0
	elseif IsAlly(src, dest) then
		r, g, b = 0, 200, 72
	else
		r, g, b = 255, 0, 0
	end
	return r, g, b
end

function GetHeadTextForceFontColor(dwPeerID, dwSelfID)
	local bInParty = false
	local player = GetClientPlayer()
	if player then
		if player.dwID == dwPeerID then
			bInParty = player.IsPlayerInMyParty(dwSelfID)
		elseif player.dwID == dwSelfID then
			bInParty = player.IsPlayerInMyParty(dwPeerID)
		end
	end
	
	local src = dwPeerID
	local dest = dwSelfID
	
	if IsPlayer(dwPeerID) and IsPlayer(dwSelfID) then
	    src = dwSelfID
	    dest = dwPeerID
	end
	
	local r, g, b
	if dwSelfID == dwPeerID then
		r, g, b = 0, 255, 0
	elseif bInParty or IsParty(src, dest) then
		r, g, b = GetPartyMemberFontColor()
	elseif IsEnemy(src, dest) then
		r, g, b = 255, 0, 0
	elseif IsNeutrality(src, dest) then
		r, g, b = 255, 255, 0
	elseif IsAlly(src, dest) then
		r, g, b = 0, 200, 72
	else
		r, g, b = 255, 0, 0
	end
	return r, g, b
end

function GetPartyMemberFontColor()
	return 126, 126, 255
end

function GetNpcHeadImage(dwID)
	local szPath, nFrame = "ui/Image/TargetPanel/Target.UITex", 47
	local player = GetClientPlayer()
	local npc = GetNpc(dwID)
	if not npc then
		return szPath, frame
	end
	
	local a = 
	{
		[1] = 47, [2] = 50, [3] = 52, [4] = 54, [5] = 67, [6] = 69, [7] = 60, [8] = 65, [9] = 47
	}
		
	nFrame = a[npc.nSpecies] or 64
	if nFrame == 47 and IsEnemy(dwID, player.dwID) then
		nFrame = 57
	end

	return szPath, nFrame
end

function GetForceTitle(dwForceID)
	if g_tStrings.tForceTitle[dwForceID] then
		return g_tStrings.tForceTitle[dwForceID]
	else
		return ""
	end
end

local FORCE_IMAGE_PATH = "ui/Image/TargetPanel/Target.UITex"
local FORCE_IMAGE_FRAME = -- [ForceID] = nFrame -> "settings\RelationForce.tab"
{
	[0] = 64,
	[1] = 59,
	[2] = 63,
	[3] = 62,
	[4] = 49,
	[5] = 56,
	[6] = 107,
	[7] = 108,
	[8] = 88,
}

function GetForceImage(dwForceID)
	if not FORCE_IMAGE_FRAME[dwForceID] then
		dwForceID = 0
	end
	return FORCE_IMAGE_PATH, FORCE_IMAGE_FRAME[dwForceID]
end

local KUNGFU_IMAGE_PATH = "ui/Image/TargetPanel/Target.UITex"
local KUNGFU_IMAGE_FRAME = 
{
	[0] = 64,
	[1] = 62,
	[2] = 63,
	[3] = 49,
	[4] = 56,
	[5] = 59,
	[6] = 88,
}

function GetKungfuImage(dwKungfuType)
	if not KUNGFU_IMAGE_FRAME[dwKungfuType] then
		dwKungfuType = 0
	end
	return KUNGFU_IMAGE_PATH, KUNGFU_IMAGE_FRAME[dwKungfuType]
end

local FORCE_TO_SCHOOL = 
{
    [1] = 5, --少林
    [2] = 2, -- 万花
    [3] = 1, -- 天策
    [4] = 3, --纯阳
    [5] = 4, --七秀
	[6] = 9, --五毒
	[7] = 10, --唐门
    [8] = 6, --藏剑
	[9] = 7, --丐帮
	[10] = 8, --明教
}

function GetSchoolByForce(nForceID)
    return FORCE_TO_SCHOOL[nForceID]
end

function GetForceKungfu(dwSchoolID)
    local aKF = {}
	local t = g_tTable.SchoolSkill:Search(dwSchoolID)
    if t and t.szSkill then
		local szKungfu = t.szSkill
		for s in string.gmatch(szKungfu, "%d+") do
			local dwID = tonumber(s)
			if dwID then
                local Skill = GetSkill(dwID, 1)
                if Skill and Skill.nUIType == 2 then
                    table.insert(aKF, dwID)
                end
			end
		end
	end
    return aKF
end



