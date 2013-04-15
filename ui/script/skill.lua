_gbSelfCastSkill = true
_gbCastSkillKeepDown = false

RegisterCustomData("_gbSelfCastSkill")
RegisterCustomData("_gbCastSkillKeepDown")

local FONT_SKILL_NAME = 31
local FONT_SKILL_LEVEL = 61
local FONT_SKILL_SEP_DESC = 101
local FONT_SKILL_DESC = 100
local FONT_SKILL_DESC1 = 47

function IsSelfCastSkill()
	return _gbSelfCastSkill
end

function SetSelfCastSkill(bSelf)
	_gbSelfCastSkill = bSelf
end

function IsCastSkillKeepDown()
	if IsSelfCastSkill() then
		return false
	end
	return _gbCastSkillKeepDown
end

function SetCastSkillKeepDown(bKeep)
	_gbCastSkillKeepDown = bKeep
end

function OnAddOnUseSkill(nSkillID, nSkillLevel)
    local hPlayer = GetClientPlayer()
    if not hPlayer then
        return
    end
    local dwTargetType, dwTargetID = hPlayer.GetTarget()
    if not dwTargetType or not dwTargetID then
			dwTargetType, dwTargetID = TARGET.NO_TARGET, 0
    end
    if dwTargetType == TARGET.PLAYER then
        return
    end
    
    OnUseSkill(nSkillID, nSkillLevel)
end

function IsSkillCastMyself(skill)  
	local bTargetSelf =  false
	if skill and IsSelfCastSkill() then
		if (skill.nCastMode == SKILL_CAST_MODE.TARGET_SINGLE or skill.nCastMode == SKILL_CAST_MODE.TARGET_CHAIN) and 
			(skill.nEffectType == SKILL_CAST_EFFECT_TYPE.BENEFICIAL) then
			local dwTargetID, dwTargetType = Target_GetTargetData()
			local dwPlayerID = UI_GetClientPlayerID()
			if dwTargetType == TARGET.NPC or dwTargetType == TARGET.PLAYER then
				if IsEnemy(dwPlayerID, dwTargetID) then
					bTargetSelf = true
				end
			else
				bTargetSelf = true
			end
		end
	end
	return bTargetSelf
end

function OnUseSkill(nSkillID, nSkillLevel, box)
    if nSkillID == 605 then  -- 上下马技能
    	RideHorse()
    	return
    end
    
    if nSkillID == 81 then -- 地图传送技能
    	OpenWorldMap(true, 0, true)
    	return
    end
    
	local player = GetClientPlayer()
	
	nSkillLevel = player.GetSkillLevel(nSkillID)
	if not nSkillLevel or nSkillLevel == 0 then
		nSkillLevel = 1
	end
	
	local skill = GetSkill(nSkillID, nSkillLevel)
    if not skill or skill.bIsPassiveSkill then 
    	return
    end

	local bNormal = true
	local nSkillResult
    if skill.nCastMode == SKILL_CAST_MODE.POINT_AREA or skill.nCastMode == SKILL_CAST_MODE.POINT then
    	local fnAction = function(x, y, z)
    		Selection_HideSFX()
    		nSkillResult = CastSkillXYZ(nSkillID, nSkillLevel, x, y, z)
    		CheckCastSkillResult(nSkillResult, box)
    	end
    	local fnCancel = function()
    		Selection_HideSFX()
    	end
    	local fnCondition = function(x, y, z)
    		if SceneMain_IsCursorIn() then
				local skill = GetSkill(nSkillID, nSkillLevel)
				if skill.CheckDistance(GetClientPlayer().dwID, x, y, z) == SKILL_RESULT_CODE.SUCCESS then
					if not bNormal then
						Selection_HideSFX()
					end
					
					Selection_ShowSFX(nSkillID, nSkillLevel)
					bNormal = true
					return true
				else
					if bNormal then
						Selection_HideSFX()
					end
					Selection_ShowSFX(SKILL_SELECT_POINT_UNNORMAL.nSkillID, SKILL_SELECT_POINT_UNNORMAL.nLevel)			
					bNormal = false
				end
    		end
    		return false
    	end
    	
    	if skill.UITestCast(player.dwID, IsSkillCastMyself(skill)) then
            local bCool, nLeft, nTotal = player.GetSkillCDProgress(nSkillID, nSkillLevel)
            if not bCool or nLeft == 0 and nTotal == 0 then
                Selection_ShowSFX(nSkillID, nSkillLevel)
                UserSelect.SelectPoint(fnAction, fnCancel, fnCondition, box)
            else
                OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_ERROR_SKILL_SKILL_NOT_READY)
            end
        end
    else
    	UserSelect.CancelSelect()
    	
    	local dwTargetType, dwTargetID = player.GetTarget()
    	local bTargetSelf = false
    	if IsSelfCastSkill() then
			if (skill.nCastMode == SKILL_CAST_MODE.TARGET_SINGLE or skill.nCastMode == SKILL_CAST_MODE.TARGET_CHAIN) and 
				(skill.nEffectType == SKILL_CAST_EFFECT_TYPE.BENEFICIAL) then
	    		if dwTargetType == TARGET.NPC or dwTargetType == TARGET.PLAYER then
	    			if IsEnemy(player.dwID, dwTargetID) then
						bTargetSelf = true
					end
				else
					bTargetSelf = true
	    		end
    		end
    	else
    		if IsCastSkillKeepDown() then
				local bKeppDown, bEnemy = false, true
	    		if skill.nCastMode == SKILL_CAST_MODE.TARGET_AREA or skill.nCastMode == SKILL_CAST_MODE.TARGET_SINGLE then
	    			bKeppDown = true
	    			if skill.nEffectType == SKILL_CAST_EFFECT_TYPE.BENEFICIAL then
	    				bEnemy = false
	    			end
	    		end
	    		
	    		if bKeppDown then
		    		if dwTargetType == TARGET.NPC or dwTargetType == TARGET.PLAYER then
		    			local bIsEnemy = IsEnemy(player.dwID, dwTargetID)
		    			if (bEnemy and bIsEnemy) or (not bEnemy and not bIsEnemy) then
							bKeppDown = false
						end
		    		end
	    		end
	    		if bKeppDown then
			    	local fnAction = function(dwType, dwID)
			    		local player = GetClientPlayer()
					    local bCommonSkill, bMelee = IsCommonSkill(nSkillID)
					    if bCommonSkill then
					    	nSkillResult = CastCommonSkill(bMelee)
					    	CheckCastSkillResult(nSkillResult, box)
					    else
					    	nSkillResult = CastSkill(nSkillID, nSkillLevel, dwType, dwID)
					    	CheckCastSkillResult(nSkillResult, box)
					    end
			    	end
			    	local fnCancel = function()
			    	end
			    	local fnCondition = function(dwType, dwID)
			    		if dwType == TARGET.NPC or dwType == TARGET.PLAYER then
		    				local bIsEnemy = IsEnemy(GetClientPlayer().dwID, dwID)
		    				if (bEnemy and bIsEnemy) or (not bEnemy and not bIsEnemy) then
								return true
							end
		    			end
		    			return false
			    	end	    		
	    			UserSelect.SelectCharacter(fnAction, fnCancel, fnCondition, box)
	    			return
	    		end
    		end
    	end
    	
	    local bCommonSkill, bMelee = IsCommonSkill(nSkillID)
	    if bCommonSkill then
	    	nSkillResult = CastCommonSkill(bMelee)
	    	CheckCastSkillResult(nSkillResult, box)
	    else
			nSkillResult = CastSkill(nSkillID, nSkillLevel, bTargetSelf)
		    CheckCastSkillResult(nSkillResult, box)
	    end
    end
end

function CheckCastSkillResult(nSkillResult, hBox)
	if hBox and hBox.bPetActionBar and nSkillResult and nSkillResult == SKILL_RESULT_CODE.SUCCESS then
    	PetActionBar_UpdateBoxState(hBox)
    end
end

function UpdataSkillCDProgress(player, box)
	local nLeftTime
	local dwSkillID, dwSkillLevel = box:GetObjectData()
	local skill = GetSkill(dwSkillID, dwSkillLevel)
	if skill then
		if skill.bIsPassiveSkill or Table_IsSkillFormation(dwSkillID, dwSkillLevel) then
			box:EnableObject(true)
		else
			if skill.UITestCast(player.dwID, IsSkillCastMyself(skill)) then
				box:EnableObject(true)
			else
				box:EnableObject(false)
			end
		end
	else
		box:EnableObject(false)
	end
	
	local bCommon, bMelee = IsCommonSkill(dwSkillID)
	if bCommon and bMelee then
		if g_bCastCommonSkill then
			box:SetObjectInUse(true)
		else
			box:SetObjectInUse(false)
		end
		return nLeftTime
	end

    local bCool, nLeft, nTotal = player.GetSkillCDProgress(dwSkillID, dwSkillLevel)
    if bCool then
        if nLeft == 0 and nTotal == 0 then
            if box:IsObjectCoolDown() then
                box:SetObjectCoolDown(0)
                box:SetObjectSparking(1)
            end
        else
            box:SetObjectCoolDown(1)
            box:SetCoolDownPercentage(1 - nLeft / nTotal)
        end
		nLeftTime = nLeft
    else
        box:SetObjectCoolDown(0)
    end
	return nLeftTime
end

function UpdateKungfuCDProgress(player, box)
	local dwSkillID, dwSkillLevel = box:GetObjectData()
    local bCool, nLeft, nTotal = player.GetSkillCDProgress(dwSkillID, dwSkillLevel)
    if bCool then
        if nLeft == 0 and nTotal == 0 then
            if box:IsObjectCoolDown() then
                box:SetObjectCoolDown(0)
                box:SetObjectSparking(1)
            end
        else
            box:SetObjectCoolDown(1)
            box:SetCoolDownPercentage(1 - nLeft / nTotal)
        end
    else
        box:SetObjectCoolDown(0)
    end	
end

function GetSkillkeyDesc(skillInfo, szkey)
	if not skillInfo then
		return ""
	end
	if szkey == "BuffDurationFrame" then
		return skillInfo.BuffDurationFrame / GLOBAL.GAME_FPS
	elseif szkey == "DebuffDurationFrame" then
		return skillInfo.DebuffDurationFrame / GLOBAL.GAME_FPS
	elseif szkey == "Dot" then
		return FormatString(g_tStrings.STR_DOT_TIP_DAMAGE, skillInfo.DotCount * skillInfo.DotIntervalFrame / GLOBAL.GAME_FPS, skillInfo.DotCount * skillInfo.DotDamage)
	elseif szkey == "Hot" then
		return FormatString(g_tStrings.STR_HOT_TIP_THERAPY, skillInfo.HotCount * skillInfo.HotIntervalFrame / GLOBAL.GAME_FPS, skillInfo.HotCount * skillInfo.HotTherapy)
	end
	
	local nMin, nMax = skillInfo["Min"..szkey], skillInfo["Max"..szkey]
	if nMin and nMax then
		if nMin == nMax then
			return math.abs(nMin)
		end
		return math.abs(nMin).."-"..math.abs(nMax)
	end	
	return szkey
end

function FormatSkillTipByRecipeKey(tRecipeKey, bNextLevelDesc, bShortDesc, bRecipeList, bShowProfit, nTalentSkillLevel)
	local hPlayer = GetClientPlayer()
	if not hPlayer then
		return ""
	end
	
	local dwID = tRecipeKey.skill_id
	local nLevel = tRecipeKey.skill_level
	
	local hSkillInfo = GetSkillInfo(tRecipeKey)
	
	local tOriRecipeKey = clone(tRecipeKey)
	for nIndex = 1, 12, 1 do
		tOriRecipeKey["recipe"..nIndex] = 0
	end
	local hOriSkillInfo = GetSkillInfo(tOriRecipeKey)

	local tSkillInfo = Table_GetSkill(dwID, nLevel)
	local hSkill = GetSkill(dwID, nLevel)
	
	local bHaveNextLevel = false
	local szTip = GetFormatText(tSkillInfo.szName, FONT_SKILL_NAME)
   
	local dwDescLevel = 9999
	if hSkill.dwBelongKungfu == 0 then
		if hSkill.nUIType == 2 then
			local szSkillLevel = FormatString(g_tStrings.STR_SKILL_H_THE_WHAT_LEVEL, NumberToChinese(nLevel))
	    	szTip = szTip .. GetFormatText(szSkillLevel, FONT_SKILL_LEVEL)
			szTip = szTip .. GetFormatText(g_tStrings.tMountRequestTable[hSkill.dwBelongSchool] .. "\n", 106)
			if not bShorDesc then
				dwDescLevel = nLevel
			end
		else
			local szSchool = Table_GetSkillSchoolName(hSkill.dwBelongSchool);
			szTip = szTip .. GetFormatText("\n" .. szSchool .. g_tStrings.STR_SKILL_ZS .. "\n", 106)
		end
	else
		if hSkill.bIsPassiveSkill then
			szTip = szTip .. GetFormatText("\n" .. g_tStrings.STR_SKILL_PASSIVE_SKILL, 106)
		elseif tSkillInfo.bFormation ~= 0 then
			szTip = szTip .. GetFormatText("\n" .. g_tStrings.FORMATION_GAMBIT, 106)
		else
			local szSkillLevel = FormatString(g_tStrings.STR_SKILL_H_THE_WHAT_LEVEL, NumberToChinese(nLevel))
			if nTalentSkillLevel then
				szSkillLevel = FormatString(g_tStrings.STR_SKILL_H_THE_WHAT_LEVEL, nTalentSkillLevel.."/"..hSkill.dwMaxLevel)
			end
            
			szTip = szTip .. GetFormatText(szSkillLevel, FONT_SKILL_LEVEL)
			szTip = szTip .. FormatCastRadius(hSkill.nCastMode, hSkillInfo, hOriSkillInfo, bShowProfit) .. GetFormatText("\t", 106)
			szTip = szTip .. FormatCastCost(hSkillInfo, hOriSkillInfo, bShowProfit, hSkill.nCostManaBasePercent) .. GetFormatText("\n", 106)
	    
			szTip = szTip .. GetFormatText(g_tStrings.STR_SKILL_H_WEAPEN_REQUIRE, 106)
			local nWeaponFont = 102
			if hSkill.CheckWeaponRequest(hPlayer.dwID) == SKILL_RESULT_CODE.SUCCESS then
				nWeaponFont = 106
			end
			szTip = szTip .. GetFormatText(g_tStrings.tWeaponLimitTable[hSkill.dwWeaponRequest], nWeaponFont)
		 	
		 	szTip = szTip .. GetFormatText("\t", 106)
		 	if dwID == 605 then
			 	if hPlayer.bOnHorse then
			 		szTip = szTip .. GetFormatText(g_tStrings.STR_SKILL_H_CAST_IMMIDIATLY, 106)
				else
			 		szTip = szTip .. GetFormatText(g_tStrings.STR_SKILL_H_CAST_TIME .. 3 .. g_tStrings.STR_BUFF_H_TIME_S, 106)
			 	end
			else
				szTip = szTip .. FormatCastTime(hSkillInfo, hOriSkillInfo, bShowProfit) .. GetFormatText("\n", 106)
			end
			
			szTip = szTip .. GetFormatText(g_tStrings.STR_SKILL_H_LEIGONG_REQUIRE, 106)
			local szText = ""
			if hSkill.dwMountRequestDetail ~= 0 then
				szText = Table_GetSkillName(hSkill.dwMountRequestDetail, 1) .. "\t"
			else
				szText = g_tStrings.tMountRequestTable[hSkill.dwMountRequestType] .. "\t"
			end
			local nFont = 102
			if hSkill.CheckMountRequest(hPlayer.dwID) == SKILL_RESULT_CODE.SUCCESS then
				nFont = 106
			end
			szTip = szTip .. GetFormatText(szText, nFont)
			
			szTip = szTip ..FormatCooldown(dwID, nLevel, hSkillInfo, hOriSkillInfo, bShowProfit) .. GetFormatText("\n", 106)
			
			bHaveNextLevel = true
		end
		dwDescLevel = nLevel
	end
	
	local tDescSkillInfo = Table_GetSkill(dwID, dwDescLevel)
	if tDescSkillInfo.szSpecialDesc ~= "" then
		szTip = szTip .. GetFormatText(tDescSkillInfo.szSpecialDesc .. "\n", FONT_SKILL_SEP_DESC)
	end
    
	local szSkillDesc, szSkillDesc1 = GetSkillDesc(dwID, dwDescLevel, tRecipeKey, hSkillInfo)
	szTip = szTip .. GetFormatText(szSkillDesc .. "\n", FONT_SKILL_DESC)
    
    if szSkillDesc1 and szSkillDesc1 ~= "" then
        szTip = szTip .. GetFormatText(szSkillDesc1, FONT_SKILL_DESC1)
    end
    
	local szRecipeDesc, szRecipeList = FormatRecipeList(tRecipeKey)
	szTip = szTip .. szRecipeDesc
	
	--以下为测试代码
	if IsCtrlKeyDown() then
		szTip = szTip .. GetFormatText("调试用信息：".."\n".."ID:"..dwID.." Level:"..nLevel.."\n", 102)
	end
	--以上为测试代码
	
	if bHaveNextLevel then
		szTip = szTip .. FormatNextLevelDesc(hSkill, bNextLevelDesc, bShowProfit)
	end
	
	if bRecipeList then
		szTip = szTip .. szRecipeList
	end
	
	return szTip	
end

function FormatSkillTip(dwID, nLevel, bNextLevelDesc, bShortDesc, bRecipeList, bShowProfit, nTalentSkillLevel)
	local hPlayer = GetClientPlayer()
	if not hPlayer then
		return ""
	end
	
	local tRecipeKey = hPlayer.GetSkillRecipeKey(dwID, nLevel)
	if tRecipeKey then
		return FormatSkillTipByRecipeKey(tRecipeKey, bNextLevelDesc, bShortDesc, bRecipeList, bShowProfit, nTalentSkillLevel)
	end
end	

local function FormatKungFuTip(dwID, nLevel, tRect, bShortDesc)
    local player = GetClientPlayer()
    local szTip = ""
    szTip = szTip .. FormatSkillTip(dwID, nLevel, tRect, bShortDesc);
    
    
    local aSkill = player.GetSkillList(dwID)
    local tInfo = {}
    for dwSubID, dwSubLevel in pairs(aSkill) do
        local fSort = Table_GetSkillSortOrder(dwSubID, dwSubLevel);
        table.insert(tInfo, {dwID=dwSubID, dwLevel=dwSubLevel, fSort = fSort})
    end
    table.sort(tInfo, function(tA, tB) return tA.fSort < tB.fSort; end)
    
    FONT_SKILL_NAME = 37
    for _, tData in pairs(tInfo) do
        local dwSkillID, dwLevel = tData.dwID, tData.dwLevel
        if Table_IsSkillShow(dwSkillID,  dwLevel) then
             szTip = szTip ..FormatSkillTip(dwSkillID, dwLevel, tRect, bShortDesc);
        end
    end
    FONT_SKILL_NAME = 31
    
    return szTip;
end

function OutputSkillTip(dwID, nLevel, tRect, bNextLevelDesc, bShortDesc, bRecipeList, bShowProfit, nTalentSkillLevel)
    local tSkillInfo = Table_GetSkill(dwID, nLevel) 
    local hSkill = GetSkill(dwID, nLevel)
    local szTip = ""

    if hSkill.dwBelongKungfu == 0 and hSkill.nUIType == 2 then
        szTip = FormatKungFuTip(dwID, nLevel, tRect, bNextLevelDesc)
    else
        szTip = FormatSkillTip(dwID, nLevel, bNextLevelDesc, bShortDesc, bRecipeList, bShowProfit, nTalentSkillLevel)
    end

    if tSkillInfo.bFormation ~= 0 then
        OutputTip(szTip, 2048, tRect)
    else
        OutputTip(szTip, 400, tRect)
    end
end

local function FormatValueText(nValue, nOriValue, nBaseFont, bShowProfit, bNegativeProfit, nDigits, bTimeText, bTimeGameFrame)
	if not nDigits then
		nDigits = 0
	end
	
	local nDiff = tonumber(FixFloat(nValue - nOriValue, nDigits))
	local nFont = nil
	if nDiff == 0 then
		nFont = nBaseFont
	elseif (nDiff > 0 and bNegativeProfit)
	or (nDiff < 0 and not bNegativeProfit) then
		nFont = 166
	else
		nFont = 165
	end
	
	if not bShowProfit or nDiff == 0 then
		local szValueText = FixFloat(nValue, nDigits)
		if bTimeText then
			szValueText = GetTimeText(szValueText, bTimeGameFrame)
		end
		return GetFormatText(szValueText, nFont)
	end

	local szValueText = FixFloat(nOriValue, nDigits)
	if bTimeText then
		szValueText = GetTimeText(szValueText, bTimeGameFrame)
	end
	
	local szDiffText = "("
	if nDiff < 0 then
		szDiffText = szDiffText .. "-"
	else
		szDiffText = szDiffText .. "+"
	end
	
	local szDiff = FixFloat(math.abs(nDiff), nDigits)
	if bTimeText then
		szDiff = GetTimeText(szDiff, bTimeGameFrame)
	end
	szDiffText = szDiffText .. szDiff .. ")"
	
	return GetFormatText(szValueText, nBaseFont) .. GetFormatText(szDiffText, nFont)
end

function ConvertRadius(nRadius)
	return nRadius / GLOBAL.CELL_LENGTH * GLOBAL.LOGICAL_CELL_CM_LENGTH / 100
end

function FormatCastRadius(nCastMode, hSkillInfo, hOriSkillInfo, bShowProfit)
	if nCastMode ~= SKILL_CAST_MODE.TARGET_AREA 
	and nCastMode ~= SKILL_CAST_MODE.POINT_AREA 
	and nCastMode ~= SKILL_CAST_MODE.TARGET_SINGLE 
	and nCastMode ~= SKILL_CAST_MODE.POINT 
	and nCastMode ~= SKILL_CAST_MODE.TARGET_CHAIN then
		return FormatHandle(GetFormatText(g_tStrings.STR_SKILL_H_CAST_DIS_NO, 106))
	end	
	
	local szCastRadius = GetFormatText(g_tStrings.STR_SKILL_H_CAST_MAX_DIS1)
	if hSkillInfo.MinRadius ~= 0 or hOriSkillInfo.MinRadius ~= 0 then
		local nMin = ConvertRadius(hSkillInfo.MinRadius)
		local nOriMin = ConvertRadius(hOriSkillInfo.MinRadius)
    	szCastRadius = szCastRadius .. FormatValueText(nMin, nOriMin, 106, bShowProfit, false, 1)
    	szCastRadius = szCastRadius .. GetFormatText(" - ", 106)
    end

	local nMax = ConvertRadius(hSkillInfo.MaxRadius)
    local nOriMax = ConvertRadius(hOriSkillInfo.MaxRadius)
    szCastRadius = szCastRadius .. FormatValueText(nMax, nOriMax, 106, bShowProfit, false, 1)
	szCastRadius = szCastRadius .. GetFormatText(g_tStrings.STR_METER, 106)
	return FormatHandle(szCastRadius)
end

function FormatCastCost(hSkillInfo, hOriSkillInfo, bShowProfit, nCostManaBasePercent)
	local szCastCost = nil
    
    if nCostManaBasePercent == 0 then
        if hSkillInfo.CostMana ~= 0 or hOriSkillInfo.CostMana ~= 0 then
            szCastCost = GetFormatText(g_tStrings.STR_SKILL_H_MANA_COST, 106)
            szCastCost = szCastCost .. FormatValueText(hSkillInfo.CostMana, hOriSkillInfo.CostMana, 106, bShowProfit, true)
        end
    elseif nCostManaBasePercent and (hSkillInfo.CostMana ~= 0 or hOriSkillInfo.CostMana ~= 0) then
        local nManaFont = 106
        local player = GetClientPlayer();
        local nDiff = tonumber(FixFloat(hSkillInfo.CostMana - hOriSkillInfo.CostMana, 0))
        if nDiff ~= 0 then
            nManaFont = 165
        end
        
        local nBaseValue = 30 * player.nLevel + 60
        local nPercent = FixFloat((hSkillInfo.CostMana / nBaseValue) * 100, 0)
        local nValue =  hSkillInfo.CostMana
        szCastCost = FormatString(g_tStrings.STR_SKILL_PERCENT_MANA, 106, nPercent, nManaFont, nValue)
    end
    
	if hSkillInfo.CostLife ~= 0 or hOriSkillInfo.CostLife ~= 0 then
		szCastCost = GetFormatText(g_tStrings.STR_SKILL_H_LIFE_COST, 106)
		szCastCost = szCastCost .. FormatValueText(hSkillInfo.CostLife, hOriSkillInfo.CostLife, 106, bShowProfit, true)
	end
	
	if not szCastCost then
		szCastCost = GetFormatText(g_tStrings.STR_SKILL_H_MANA_COST_NO, 106)
	end
	return FormatHandle(szCastCost)
end

function FormatCastTime(hSkillInfo, hOriSkillInfo, bShowProfit)
	if hSkillInfo.CastTime == 0 and hOriSkillInfo.CastTime == 0 then
		return FormatHandle(GetFormatText(g_tStrings.STR_SKILL_H_CAST_IMMIDIATLY, 106))
	end
	
	local szCastTime = GetFormatText(g_tStrings.STR_SKILL_H_CAST_TIME, 106)
	szCastTime = szCastTime .. FormatValueText(hSkillInfo.CastTime, hOriSkillInfo.CastTime, 106, bShowProfit, true, 1, true, true)
	return FormatHandle(szCastTime)
end

function FormatCooldown(dwID, nLevel, hSkillInfo, hOriSkillInfo, bShowProfit)
	local nCooldown = 0
	local nOriCooldown = 0
	for i = 1, 3 do
		local szKey = "CoolDown" .. i
		if hSkillInfo[szKey] > nCooldown then
			nCooldown = hSkillInfo[szKey]
		end
		if hOriSkillInfo[szKey] > nOriCooldown then
			nOriCooldown = hOriSkillInfo[szKey]
		end
	end
	
	if (nCooldown == 0 and nOriCooldown == 0)
	or (nCooldown == 24 and nOriCooldown == 24) then
		return FormatHandle(GetFormatText(g_tStrings.STR_SKILL_NOT_NEED_REST, 106))
	end
	
	local szCooldown = FormatValueText(nCooldown, nOriCooldown, 106, bShowProfit, true, 1, true, true)
	szCooldown = szCooldown .. GetFormatText(g_tStrings.STR_SKILL_NEED_REST_UNIT, 106)
	
	local hPlayer = GetClientPlayer()
	local szCurrentCooldown = ""
	local bCooldown, nLeft, nTotal = hPlayer.GetSkillCDProgress(dwID, nLevel)
	if bCooldown and nLeft > 0 then
		local szLeftTime = GetTimeText(nLeft, true, false, true)
		szCurrentCooldown = GetFormatText(FormatString(g_tStrings.STR_SKILL_NEED_REST_LEFT, szLeftTime), 102)
	end
	return FormatHandle(szCooldown) .. FormatHandle(szCurrentCooldown)
end

function FormatNextLevelDesc(hSkill, bNextLevelDesc, bShowProfit)
	local dwID = hSkill.dwSkillID
	local nLevel = hSkill.dwLevel
	local szNextLevelDesc = ""
	if nLevel == hSkill.dwMaxLevel then
		szNextLevelDesc = GetFormatText(g_tStrings.STR_SKILL_H_TOP_LEAVEL, 106)
	else
		nLevel = nLevel + 1
		local hPlayer = GetClientPlayer()
		local tRecipeKey = hPlayer.GetSkillRecipeKey(dwID, nLevel)
		local hSkillInfo = GetSkillInfo(tRecipeKey)
		
		local tOriRecipeKey = clone(tRecipeKey)		
		for nIndex = 1, 12, 1 do
			tOriRecipeKey["recipe"..nIndex] = 0
		end
		local hOriSkillInfo = GetSkillInfo(tOriRecipeKey)
		
		local szLevelExp = FormatString(g_tStrings.STR_SKILL_H_NEXT_LEVEL_EXP, hPlayer.GetSkillExp(dwID), hSkill.dwLevelUpExp)
		szNextLevelDesc = GetFormatText(szLevelExp, 106)
		if bNextLevelDesc then
			szNextLevelDesc = szNextLevelDesc .. GetFormatText("\t", 106) 
			szNextLevelDesc = szNextLevelDesc .. FormatCastCost(hSkillInfo, hOriSkillInfo, bShowProfit,  hSkill.nCostManaBasePercent)
			local szSkillDesc = GetSkillDesc(dwID, nLevel, tRecipeKey, hSkillInfo)
			szNextLevelDesc = szNextLevelDesc .. GetFormatText(szSkillDesc .. "\n", 100)	
		end
	end
	return szNextLevelDesc
end

function FormatRecipeList(tRecipeKey)
	local szDescList = ""
	local szRecipeList = ""
	for i = 1, 12 do
		local dwRID, dwRLevel = SkillRecipeKeyToIDAndLevel(tRecipeKey["recipe"..i])
		if dwRID ~= 0 then
			local tSkillRecipe = Table_GetSkillRecipe(dwRID, dwRLevel)
			local szName = ""
			if tSkillRecipe then
				local tRecipeType = g_tTable.SkillRecipeType:Search(tSkillRecipe.dwTypeID)
				if tRecipeType and tRecipeType.nAddToTip == 1 then
					szDescList = szDescList .. GetFormatText(tSkillRecipe.szDesc .. "\n", 165)
				end
				
				local szScript = "this.OnItemLButtonDown = function() "
				szScript = szScript .. "local x, y = this:GetAbsPos();"
				szScript = szScript .. "local w, h = this:GetSize();"
				szScript = szScript .. "OutputSkillRecipeTip(" .. dwRID .. ", " .. dwRLevel .. ", {x, y, w, h}, true);"
				szScript = szScript .. "end"
                
                local _, _, nSkillRecipeType, _ = GetSkillRecipeBaseInfo(dwRID, dwRLevel)
                if nSkillRecipeType ~= SKILL_RECIPE_TYPE.EQUIPMENT then
                    szRecipeList = szRecipeList .. GetFormatText(tSkillRecipe.szName .. "\n", 100, nil, nil, nil, 1, szScript)
                end
            end
		end
	end
	
	if szRecipeList ~= "" then
		szRecipeList = GetFormatText(g_tStrings.STR_SKILL_HAVE_RECIPE .. "\n", 106) .. szRecipeList
	end
	
	return szDescList, szRecipeList
end

function OutputSkillLink(tRecipeKey, tRect)
	local szTip = FormatSkillTipByRecipeKey(tRecipeKey, false, false, true, false)
	local tSkillInfo = Table_GetSkill(tRecipeKey.skill_id, tRecipeKey.skill_level)
	
	local szLink = "skill" .. tRecipeKey.skill_id .. "x" .. tRecipeKey.skill_level
	if tSkillInfo.bFormation ~= 0  then
		OutputTip(szTip, 10000, tRect, nil, true, szLink)
	else
		OutputTip(szTip, 400, tRect, nil, true, szLink)
	end
end

function GetSubSkillDesc(dwID, dwLevel, bShort)
	local player = GetClientPlayer()
	local skillkey = player.GetSkillRecipeKey(dwID, dwLevel)
	local skillInfo = GetSkillInfo(skillkey)
	return GetSkillDesc(dwID, dwLevel, skillkey, skillInfo, bShort)
end

function GetSkillDesc(dwSkillID, dwSkillLevel, skillkey, skillInfo, bShort)
    local szDesc = ""
    local szDesc1 = ""
    if bShort then
        szDesc = Table_GetSkillShortDesc(dwSkillID, dwSkillLevel)
        if szDesc == "" then
            szDesc = Table_GetSkillDesc(dwSkillID, dwSkillLevel)
        end
    else
        szDesc = Table_GetSkillDesc(dwSkillID, dwSkillLevel)
    end

    szDesc = string.gsub(szDesc, "<SKILL (.-)>", function(szkey)  return GetSkillkeyDesc(skillInfo, szkey) end)
    szDesc = string.gsub(szDesc, "<SUB (%d+) (%d+)>", function(dwID, dwLevel) if dwLevel == "0" then dwLevel = dwSkillLevel end return GetSubSkillDesc(dwID, dwLevel, bShort) end)
    szDesc = string.gsub(szDesc, "<BUFF (%d+) (%d+) (%w+)>", function(dwID, nLevel, szKey) if nLevel == "0" then nLevel = dwSkillLevel end return GetBuffDesc(dwID, nLevel, szKey) end)
    szDesc = string.gsub(szDesc, "<BINDBUFF (%d+) (%d+) (%d+) (%w+)>", function(dwType, dwID, nLevel, szKey) if nLevel == "0" then nLevel = dwSkillLevel end return GetBindBuffDesc(dwType, dwID, nLevel, szKey, skillkey) end)
    szDesc = string.gsub(
        szDesc, 
        "<KUNGFU (%d+) (%d+) (.-)>", 
        function(szKungFuID, szLevel, szShow)
            local player = GetClientPlayer()
            local Kungfu = player.GetKungfuMount()
            if Kungfu.dwSkillID ==  tonumber(szKungFuID) and Kungfu.dwLevel >= tonumber(szLevel) then
                szDesc1 = szDesc1..szShow .. "\n"
            end
            return ""
        end
    )
    szDesc = string.gsub(
        szDesc, 
        "<TALENT (%d+) (%d+) (.-)>", 
        function(szSkillID, szLevel, szShow)
            local player = GetClientPlayer()
            local nSkillID = tonumber(szSkillID)
            local nReLevel = tonumber(szLevel) or 1
            local nLevel = player.GetSkillLevel(nSkillID)
            if nLevel == nReLevel then
                szDesc1 = szDesc1..szShow .. "\n"
            end
            return ""
        end
    )
    return szDesc, szDesc1
end

function OutputSkillRecipeTip(dwID, dwLevel, Rect, bLink, tMoreInfo)
	local tSkillRecipe = Table_GetSkillRecipe(dwID, dwLevel)
	local szName = ""
	local szDesc = ""
	if tSkillRecipe then
		szName = tSkillRecipe.szName
		szDesc = tSkillRecipe.szDesc
	end
	local szTip = GetFormatText(szName.."\n", 31)
	local dwSkillID, dwSkillLevel, _, dwSkillRecipeType = GetSkillRecipeBaseInfo(dwID, dwLevel)
	local szSkillName = ""
	if dwSkillRecipeType and dwSkillRecipeType ~= 0 then
		szSkillName = Table_GetSkillName(dwSkillRecipeType)
	elseif dwSkillID then
		if dwSkillLevel and dwSkillLevel ~= 0 then -- 0 表示不限制秘籍在技能上的使用等级
			szSkillName = Table_GetSkillName(dwSkillID, dwSkillLevel)
		else
			szSkillName = Table_GetSkillName(dwSkillID)
		end
	end
	szTip = szTip..GetFormatText(szSkillName.."\n", 162)
	szTip = szTip..GetFormatText(szDesc.."\n", 100)
    if tMoreInfo then
        if tMoreInfo.bHave then
            if tMoreInfo.bActive then
                szTip = szTip .. GetFormatText(g_tStrings.STR_SKILL_RECIPE_ACTIVE, 161)
            else
                szTip = szTip .. GetFormatText(FormatString(g_tStrings.STR_SKILL_RECIPE_NOT_ACTIVE_TIP, MAX_SKILL_REICPE_COUNT), 185)

            end
        else
            szTip = szTip .. GetFormatText(g_tStrings.TIP_UNREAD, 196)
        end
    end
	OutputTip(szTip, 400, Rect, nil, bLink, "skillrecipe"..dwID.."x"..dwLevel)
end

function GetSkillByRecipe(dwRecipeID, nRecipeLevel)
	local hPlayer = GetClientPlayer()
	local tSchoolList = hPlayer.GetSchoolList()
	if tSchoolList then
		for _, dwSchoolID in pairs(tSchoolList) do
			local tKungfuList = hPlayer.GetKungfuList(dwSchoolID)
			if tKungfuList then
				for dwKungfuID, _ in pairs(tKungfuList) do
					local tSkillList = hPlayer.GetSkillList(dwKungfuID)
					if tSkillList then
						for dwSkillID, nSkillLevel in pairs(tSkillList) do
							local tRecipeList = hPlayer.GetSkillRecipeList(dwSkillID, nSkillLevel)
							if tRecipeList then
								for _, tRecipe in ipairs(tRecipeList) do
									if tRecipe and tRecipe.recipe_id and tRecipe.recipe_level
									and tRecipe.recipe_id == dwRecipeID and tRecipe.recipe_level == nRecipeLevel then
										return dwSkillID, nSkillLevel
									end
								end
							end
						end
					end
				end
			end
		end
	end
end
