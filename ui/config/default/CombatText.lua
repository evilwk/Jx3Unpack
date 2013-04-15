CombatText = {}

POINT_TYPE_MOVE = 1
POINT_TYPE_QUEUE = 2
POINT_TYPE_MERGE = 3

local MERGE_EFFECT_SCALE = 0.0
local POINT_DIE_OUT_TIME = 6
local INI_FILE = "ui\\Config\\Default\\CombatText.ini"

CombatText.tPointList = nil
CombatText.tTrackList = nil

CombatText.tTrackMap = {}
CombatText.tPointState = {}

local TRACK_MAP_KEY = 
{
	{"nDamagePhysics", "_damage_physics", SKILL_RESULT_TYPE.PHYSICS_DAMAGE},
	{"nDamageSolarMagic", "_damage_solar_magic", SKILL_RESULT_TYPE.SOLAR_MAGIC_DAMAGE},
	{"nDamageNeutralMagic", "_damage_neutral_magic", SKILL_RESULT_TYPE.NEUTRAL_MAGIC_DAMAGE},
	{"nDamageLunarMagic", "_damage_lunar_magic", SKILL_RESULT_TYPE.LUNAR_MAGIC_DAMAGE},
	{"nDamagePosion", "_damage_poison", SKILL_RESULT_TYPE.POISON_DAMAGE},
	{"nDamageReflectied", "_damage_reflectied", SKILL_RESULT_TYPE.REFLECTIED_DAMAGE},
	{"nDamageTherapy", "_damage_therapy", SKILL_RESULT_TYPE.THERAPY},
	{"nDamageStealLife", "_damage_steal_life", SKILL_RESULT_TYPE.STEAL_LIFE},
	{"nDamageAbsorb", "_damage_absorb_damage", SKILL_RESULT_TYPE.ABSORB_DAMAGE},
	{"nDamageShield", "_damage_shield_damage", SKILL_RESULT_TYPE.SHIELD_DAMAGE},
	{"nDamageParry", "_damage_parry_damage", SKILL_RESULT_TYPE.PARRY_DAMAGE},
	{"nDamageInsight", "_damage_insight_damage", SKILL_RESULT_TYPE.INSIGHT_DAMAGE},
	{"nStateText", "_state_text"},
	{"nBuff", "_buff"},
	{"nDeBuff", "_debuff"},
}
TRACK_MAP_KEY_TARGET_SELF = "self"
TRACK_MAP_KEY_TARGET_OTHER = "other"

function CombatText.OnFrameCreate()
    this:RegisterEvent("COMMON_HEALTH_TEXT")
    this:RegisterEvent("SKILL_EFFECT_TEXT")
    this:RegisterEvent("SKILL_MISS")
    this:RegisterEvent("SKILL_DODGE")
    this:RegisterEvent("SKILL_BLOCK")
    this:RegisterEvent("SKILL_BUFF")
    this:RegisterEvent("BUFF_IMMUNITY")
    this:RegisterEvent("DO_SKILL_CAST")
    this:RegisterEvent("SYS_MSG")
    this:RegisterEvent("PLAYER_LEAVE_SCENE")
	
	this:Lookup("", ""):Clear()
	
	if not CombatText.tPointList or not CombatText.tTrackList then
		CombatText.LoadData()
	end
end

function CombatText.OnFrameBreathe()
	local hTotal = this:Lookup("", "")
	local nTextCount = hTotal:GetItemCount()
	local tOriginCache = {}
	
	local nIndex = 0
	while nIndex < nTextCount do
		local hText = hTotal:Lookup(nIndex)
		
		if not tOriginCache[hText.dwCharacterID] then
			local nSceneX, nSceneY, nSceneZ = Scene_GetCharacterTop(hText.dwCharacterID)
			if nSceneX and nSceneY and nSceneZ then
				local nScreenX, nScreenY = Scene_ScenePointToScreenPoint(nSceneX, nSceneY, nSceneZ)
				local tOrigin = {}
				tOrigin.nX, tOrigin.nY = Station.AdjustToOriginalPos(nScreenX, nScreenY)
				tOriginCache[hText.dwCharacterID] = tOrigin
			end
		end
		if tOriginCache[hText.dwCharacterID] then
			hText.nOriginX = tOriginCache[hText.dwCharacterID].nX
			hText.nOriginY = tOriginCache[hText.dwCharacterID].nY
		end
		
		if hText.nOriginX and hText.nOriginY then
			CombatText.UpdateText(hText)
		else
			hText.bDelete = true
		end
		
		if hText.bDelete then
			hTotal:RemoveItem(nIndex)
			nTextCount = nTextCount - 1
		else
			nIndex = nIndex + 1
		end
	end
	hTotal:FormatAllItemPos()
end

function CombatText.OnEvent(szEvent)
	if szEvent == "SKILL_MISS"
	or szEvent == "SKILL_DODGE"
	or szEvent == "SKILL_BLOCK" then
		CombatText.NewStateText(this, arg1, g_tStrings.COMBAT_STATE_TEXT[szEvent])
	elseif szEvent == "BUFF_IMMUNITY" then
		CombatText.NewStateText(this, arg0, g_tStrings.COMBAT_STATE_TEXT[szEvent])
	elseif szEvent == "COMMON_HEALTH_TEXT" then
		-- CombatText.NewEffectText(this, arg0, arg1)
	elseif szEvent == "SKILL_EFFECT_TEXT" then
		CombatText.NewSkillEffectText(this, arg1, arg3, arg4, arg2, arg5, arg6)
	elseif szEvent == "SKILL_BUFF" then
		CombatText.NewBuffText(this, arg0, arg2, arg3, arg1)
	elseif szEvent == "PLAYER_LEAVE_SCENE" then
		CombatText.DeletePointByTarget(this, arg0)
	end
end

function CombatText.DeletePointByTarget(hFrame, dwTargetID)
	local hTotal = hFrame:Lookup("", "")
	local nCount = hTotal:GetItemCount()
	for i = 0, nCount - 1 do
		local hText = hTotal:Lookup(i)
		if hText.dwCharacterID == dwTargetID then
			hText.bDelete = true
		end
	end
end

function CombatText.SelectTrackByTime(tTrackList)
	local nSelectTrackID = nil
	local nLastUpdateTime = nil
	for _, nTrackID in ipairs(tTrackList) do
		local tTrack = CombatText.tTrackList[nTrackID]
		if not tTrack.nLastUpdateTime then
			nSelectTrackID = nTrackID
			break
		end
		
		if not nLastUpdateTime or nLastUpdateTime > tTrack.nLastUpdateTime then
			nSelectTrackID = nTrackID
			nLastUpdateTime = tTrack.nLastUpdateTime
		end
	end
	CombatText.tTrackList[nSelectTrackID].nLastUpdateTime = GetCurrentTime()
	return nSelectTrackID
end

function CombatText.NewStateText(hFrame, dwCharacterID, szText)
	local hPlayer = GetClientPlayer()
	local szKey = nil
	if  hPlayer.dwID == dwCharacterID then
		szKey = "self_state_text"
	else
		szKey = "other_state_text"
	end
	
	if not CombatText.tTrackMap[szKey] then
		return
	end
	
	local nTrackID = CombatText.SelectTrackByTime(CombatText.tTrackMap[szKey])
	if not nTrackID then
		return
	end
	
	CombatText.CreateText(hFrame, szText, nTrackID, dwCharacterID)
end

function CombatText.NewBuffText(hFrame, dwCharacterID, dwID, dwLevel, bCanCancel)
	local hPlayer = GetClientPlayer()
	
	local szKey = nil
	if hPlayer.dwID == dwCharacterID then
		szKey = TRACK_MAP_KEY_TARGET_SELF
	else
		szKey = TRACK_MAP_KEY_TARGET_OTHER
	end
	
	if bCanCancel then
		szKey = szKey .. "_buff"
	else
		szKey = szKey .. "_debuff"
	end
		
	if not CombatText.tTrackMap[szKey] then
		return
	end
	
	local nTrackID = CombatText.SelectTrackByTime(CombatText.tTrackMap[szKey])
	if not nTrackID then
		return
	end
	
	if not Table_BuffIsVisible(dwID, dwLevel) then
		return
	end	
	
	local szBuffName = Table_GetBuffName(dwID, dwLevel);
	CombatText.CreateText(hFrame, szBuffName, nTrackID, dwCharacterID)
end	

function CombatText.NewSkillEffectText(hFrame, dwCharacterID, nDamageType, nDamage, nCriticalStrike, dwSkillID, dwSkillLevel)
	local hPlayer = GetClientPlayer()
	
	local szKey = nil
	if hPlayer.dwID == dwCharacterID then
		szKey = TRACK_MAP_KEY_TARGET_SELF
	else
		szKey = TRACK_MAP_KEY_TARGET_OTHER
	end
	
	for _, tKey in ipairs(TRACK_MAP_KEY) do
		if tKey[3] == nDamageType then
			szKey = szKey .. tKey[2]
			break
		end
	end
	
	if not CombatText.tTrackMap[szKey] then
		return
	end
	
	local nTrackID = CombatText.SelectTrackByTime(CombatText.tTrackMap[szKey])
	if not nTrackID then
		return
	end
	
	CombatText.CreateText(hFrame, nDamage, nTrackID, dwCharacterID)
end

function CombatText.CreateText(hFrame, szText, nTrackID, dwCharacterID)
	assert(nTrackID and CombatText.tTrackList[nTrackID])
	local hTotal = hFrame:Lookup("", "")
	local hText = hTotal:AppendItemFromIni(INI_FILE, "Text_CombatText")
	hText:SetText(szText)
	hText.dwID = GetTickCount()
	hText.nTrackID = nTrackID
	hText.nText = tonumber(szText)
	hText.nCurStep = 1
	hText.dwCharacterID = dwCharacterID
	hText:AutoSize()
end

function CombatText.SetTextPos(hText, nX, nY)
	local nWidth, nHeight = hText:GetSize()
	hText:SetRelPos(nX - nWidth / 2, nY - nHeight / 2)
end

function CombatText.UpdateText(hText)
	local tTrack = CombatText.tTrackList[hText.nTrackID]
	if tTrack[hText.nCurStep] then
		local nPointID = tTrack[hText.nCurStep]
		local tPoint = CombatText.tPointList[nPointID]
		if hText.bDeath then
			CombatText.UpdateDeathPoint(hText)
		elseif tPoint.nType == POINT_TYPE_MOVE then
			CombatText.UpdateMovePoint(hText)
		elseif tPoint.nType == POINT_TYPE_QUEUE then
			CombatText.UpdateQueuePoint(hText)
		elseif tPoint.nType == POINT_TYPE_MERGE then	
			CombatText.UpdateMergePoint(hText)
		end
	else
		hText.bDelete = true
	end
end

function CombatText.UpdateMovePoint(hText)
	local tTrack = CombatText.tTrackList[hText.nTrackID]
	local nNextStep = hText.nCurStep + 1
	if not tTrack[nNextStep] then
		hText.bDelete = true
		return
	end
	
	local tSrcPoint = CombatText.tPointList[tTrack[hText.nCurStep]]
	local tDesPoint = CombatText.tPointList[tTrack[nNextStep]]
	local nXOffset = tSrcPoint.nX - tDesPoint.nX
	local nYOffset = tSrcPoint.nY - tDesPoint.nY
		
	if not hText.fProgress then
		hText.fProgress = 0
		local fDesToSrc = math.sqrt(nXOffset * nXOffset + nYOffset * nYOffset)
		hText.fProgressInc = tSrcPoint.nSpeed / fDesToSrc
	end
	
	local nAlpha = CombatText.Blend(tSrcPoint.nAlpha, tDesPoint.nAlpha, hText.fProgress)
	hText:SetAlpha(nAlpha)
	
	local nRed = CombatText.Blend(tSrcPoint.nRed, tDesPoint.nRed, hText.fProgress)
	local nGreen = CombatText.Blend(tSrcPoint.nGreen, tDesPoint.nGreen, hText.fProgress)
	local nBlue = CombatText.Blend(tSrcPoint.nBlue, tDesPoint.nBlue, hText.fProgress)
	hText:SetFontColor(nRed, nGreen, nBlue)
	
	local nCurScale = tSrcPoint.fScale * (1 - hText.fProgress) + tDesPoint.fScale * hText.fProgress
	hText:SetFontScale(nCurScale)
	hText:AutoSize()
	
	local nPosX = tSrcPoint.nX - nXOffset * hText.fProgress + hText.nOriginX
	local nPosY = tSrcPoint.nY - nYOffset * hText.fProgress + hText.nOriginY
	CombatText.SetTextPos(hText, nPosX, nPosY)
		
	hText.fProgress = hText.fProgress + hText.fProgressInc
	if hText.fProgress >= 1 then
		hText.nCurStep = nNextStep
		hText.fProgress = nil
		hText.fProgressInc = nil
	end
end

function CombatText.UpdateQueuePoint(hText)
	local szKey = CombatText.GetPointKey(hText)
	local tPoint = CombatText.tPointList[CombatText.tTrackList[hText.nTrackID][hText.nCurStep]]
	if CombatText.tPointState[szKey] == hText.dwID then
		CombatText.SetTextPos(hText, tPoint.nX + hText.nOriginX, tPoint.nY + hText.nOriginY)
		hText.nDeathTime = hText.nDeathTime - 1
		hText.bDeath = (hText.nDeathTime <= 0)
	elseif hText.szLastQueuePoint == szKey then
		CombatText.UpdateMovePoint(hText)
	else
		CombatText.tPointState[szKey] = hText.dwID
		
		hText.nDeathTime = tPoint.nDeathTime
		hText:SetAlpha(tPoint.nAlpha)
		hText:SetFontColor(tPoint.nRed, tPoint.nGreen, tPoint.nBlue)
		hText:SetFontScale(tPoint.fScale)
		hText:AutoSize()
		
		hText.szLastQueuePoint = szKey
	end
end

function CombatText.UpdateMergePoint(hText)
	local tPoint = CombatText.tPointList[CombatText.tTrackList[hText.nTrackID][hText.nCurStep]]
	
	local szKey = CombatText.GetPointKey(hText)
	if not CombatText.tPointState[szKey] then
		CombatText.tPointState[szKey] = { nText = hText.nText or 0, nCount = 0, bRefresh = true }
		
		hText:SetAlpha(tPoint.nAlpha)
		hText:SetFontColor(tPoint.nRed, tPoint.nGreen, tPoint.nBlue)
		hText.bMergePoint = true
	end
	
	local tPointState = CombatText.tPointState[szKey]
	if hText.bMergePoint then
		if tPointState.bRefresh then
			hText:SetFontScale(tPointState.nCount * tPoint.fScaleInc + tPoint.fScale + MERGE_EFFECT_SCALE)
			hText:SetText(tPointState.nText)
			hText.nDeathTime = tPoint.nDeathTime
			tPointState.bRefresh = false
		else
			hText:SetFontScale(tPointState.nCount * tPoint.fScaleInc + tPoint.fScale)
		end
		hText:AutoSize()
		
		CombatText.SetTextPos(hText, tPoint.nX + hText.nOriginX, tPoint.nY + hText.nOriginY)		
		hText.nDeathTime = hText.nDeathTime - 1
		hText.bDeath = (hText.nDeathTime <= 0)
	else
		if hText.nText then
			tPointState.nText = tPointState.nText + hText.nText
		end
		tPointState.nCount = tPointState.nCount + 1
		tPointState.bRefresh = true
		hText.bDelete = true
	end
end

function CombatText.UpdateDeathPoint(hText)
	if not hText.nDieOutTime then
		hText.nDieOutTime = POINT_DIE_OUT_TIME
	end
	
	hText.nDieOutTime = hText.nDieOutTime - 1
	local tPoint = CombatText.tPointList[CombatText.tTrackList[hText.nTrackID][hText.nCurStep]]
	hText:SetAlpha(tPoint.nAlpha * hText.nDieOutTime / POINT_DIE_OUT_TIME)
	if hText.nDieOutTime <= 0 then
		local szKey = CombatText.GetPointKey(hText)
		CombatText.tPointState[szKey] = nil
		hText.bDelete = true
	end
end

function CombatText.GetPointKey(hText)
	return hText.dwCharacterID .. hText.nTrackID .. hText.nCurStep
end

function CombatText.LoadData()
	CombatText.tPointList = {}
	local nCount = g_tTable.CombatTextPoint:GetRowCount()
	for i = 1, nCount do
		local tRow = g_tTable.CombatTextPoint:GetRow(i)
		
		local tPoint = {}
		tPoint.nType = tRow.nType
		tPoint.nX = tRow.nX
		tPoint.nY = tRow.nY   
		tPoint.fScale = tRow.fScale
		tPoint.nAlpha = tRow.nAlpha
		tPoint.nRed = tRow.nRed
		tPoint.nGreen = tRow.nGreen
		tPoint.nBlue = tRow.nBlue
		
		if tPoint.nType == POINT_TYPE_MOVE then
			tPoint.nSpeed = math.floor(tRow.fParam1)
		elseif tPoint.nType == POINT_TYPE_QUEUE then
			tPoint.nDeathTime = math.floor(tRow.fParam1)
			tPoint.nSpeed = math.floor(tRow.fParam2)
		elseif tPoint.nType == POINT_TYPE_MERGE then
			tPoint.nDeathTime = math.floor(tRow.fParam1)
			tPoint.fScaleInc = tRow.fParam2
		end
		
		CombatText.tPointList[tRow.nID] = tPoint
	end
	g_tTable.CombatTextPoint = nil
	
	CombatText.tTrackList = {}
	local nCount = g_tTable.CombatTextTrack:GetRowCount()
	for i = 1, nCount do
		local tRow = g_tTable.CombatTextTrack:GetRow(i)
		local szPointList = tRow.szPointList
		local nTrackID = tRow.nID
		tRow.szPointList = nil
		tRow.nID = nil
		local tTrack = clone(tRow)
		for szPointID in string.gmatch(szPointList, "%d+") do
			table.insert(tTrack, tonumber(szPointID))
	    end
	    CombatText.tTrackList[nTrackID] = tTrack
	end
	g_tTable.CombatTextTrack = nil
	
	CombatText.ResetRuntimState()
end

function CombatText.ResetRuntimState()
	CombatText.tPointState = {}
	CombatText.tTrackMap = {}
	
	for nTrackID, tTrack in pairs(CombatText.tTrackList) do
		for _, tKey in ipairs(TRACK_MAP_KEY) do
			local szIndex = tKey[1]
			if tTrack[szIndex] == 1 then
				if tTrack.nSelf == 1 then
					local szKey = TRACK_MAP_KEY_TARGET_SELF .. tKey[2]
					if not CombatText.tTrackMap[szKey] then
						CombatText.tTrackMap[szKey] = {}
					end
					table.insert(CombatText.tTrackMap[szKey], nTrackID)
				end
				if tTrack.nOther == 1 then
					local szKey = TRACK_MAP_KEY_TARGET_OTHER .. tKey[2]
					if not CombatText.tTrackMap[szKey] then
						CombatText.tTrackMap[szKey] = {}
					end
					table.insert(CombatText.tTrackMap[szKey], nTrackID)
				end				
			end
		end
	end
end

function CombatText.Blend(nLeft, nRight, fPercent)
	return nLeft * (1 - fPercent) + nRight * fPercent
end