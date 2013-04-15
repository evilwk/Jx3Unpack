-----------------------------------------------
-- 文件名    :  Talent.lua
-- 创建人    :  linjiaqi
-- 创建时间  :  2011-02-25
-- 用途(模块):  天赋系统
-- 用途  	 :  UI端天赋操作
------------------------------------------------

function GetTalentTab(nForceID)
    return TALENT_TAB[nForceID]
end

function GetTalentSkillRequire(nForceID)
    return TALENT_TAB[nForceID]
end

function GetTalentSubSkill(nForceID, nSeriesID, dwSkillID)
    if not TALENT_PREV_SKILL_MAPPING_TAB[nForceID]  or 
       not TALENT_PREV_SKILL_MAPPING_TAB[nForceID][nSeriesID] or
       not TALENT_PREV_SKILL_MAPPING_TAB[nForceID][nSeriesID][dwSkillID] then
       return nil
    end
    
    return TALENT_PREV_SKILL_MAPPING_TAB[nForceID][nSeriesID][dwSkillID]
end

-- 是否可以加点,有返回码
function CanAddTalent(TalentPointTab, nForceID, nSeriesID, nRow, nColum)
	local player = GetClientPlayer()
	if not player then
		return ERR_TALENT_ERROR
	end
	if player.dwForceID ~= nForceID then
		return ERR_TALENT_NOT_FIRST_FORCE
	end
	
	local nHadTalentPoint = GetHadTalentPoint(TalentPointTab)
	if nHadTalentPoint <= 0 then
		return ERR_TALENT_NOT_ENOUGH_POINT
	end
	
	local nSkillID = GetSkillID(player.dwForceID, nSeriesID, nRow, nColum)
	if nSkillID == 0 then
		return ERR_TALENT_ERROR
	end
	
	local tCondition = GetTalentCondition(player.dwForceID, nSkillID)
	if not tCondition then
		return ERR_TALENT_ERROR
	end
	
	local nSkillPoint = GetTabInfo(TalentPointTab, nSeriesID, nRow, nColum)
	if not nSkillPoint then
		return ERR_TALENT_ERROR
	end
	local TalentSkill = GetSkill(nSkillID, 1)
	if not TalentSkill then
		return ERR_TALENT_ERROR
	end 
	if nSkillPoint >= TalentSkill.dwMaxLevel then
		return ERR_TALENT_MAX_SKILL_LEVEL
	end
	
	-- 预先添加一点
    local tTalent = clone(TalentPointTab)
	tTalent[nSeriesID][nRow][nColum] = tTalent[nSeriesID][nRow][nColum] + 1
	
	-- 系之间关系
	local TalentSubsectionInfo = StatisticsTalentSubsectionInfo(tTalent)
	if not TalentSubsectionInfo[1] or not TalentSubsectionInfo[2] then
		return ERR_TALENT_ERROR
	end
	if TalentSubsectionInfo[1].nTotal > 0 and 
	   TalentSubsectionInfo[1].nTotal < TALENT_OPEN_SERIES_POINT and 
	   TalentSubsectionInfo[2].nTotal > 0 and 
	   TalentSubsectionInfo[2].nTotal < TALENT_OPEN_SERIES_POINT then
		return ERR_TALENT_NOT_ENOUGH_SERIES_POINT		
	end
	
	return IsAllLegalTalent(player, tTalent)
end

-- 是否可以删点,有返回码
function CanDelTalent(TalentPointTab, nForceID, nSeriesID, nRow, nColum)
	local player = GetClientPlayer()
	if not player then
		return ERR_TALENT_ERROR
	end
	if player.dwForceID ~= nForceID then
		return ERR_TALENT_NOT_FIRST_FORCE
	end
	
	local nSkillID = GetSkillID(player.dwForceID, nSeriesID, nRow, nColum)
	if nSkillID == 0 then
		return ERR_TALENT_ERROR
	end
	
	local nSkillPoint = GetTabInfo(TalentPointTab, nSeriesID, nRow, nColum)
	if not nSkillPoint then
		return ERR_TALENT_ERROR
	end
	if nSkillPoint <= 0 then
		return ERR_TALENT_MAX_SKILL_LEVEL
	end
	
	if not nSkillPoint or nSkillPoint <= 0 then
		return ERR_TALENT_MIN_SKILL_LEVEL
	end
	
	-- 预先删除一点
    local tTalent = clone(TalentPointTab)
	tTalent[nSeriesID][nRow][nColum] = tTalent[nSeriesID][nRow][nColum] - 1
	
	
	-- 系之间关系
	local TalentSubsectionInfo = StatisticsTalentSubsectionInfo(tTalent)
	if not TalentSubsectionInfo[1] or not TalentSubsectionInfo[2] then
		return ERR_TALENT_ERROR
	end
	if TalentSubsectionInfo[1].nTotal > 0 and 
	   TalentSubsectionInfo[1].nTotal < TALENT_OPEN_SERIES_POINT and 
	   TalentSubsectionInfo[2].nTotal > 0 and 
	   TalentSubsectionInfo[2].nTotal < TALENT_OPEN_SERIES_POINT then
		return ERR_TALENT_NOT_ENOUGH_SERIES_POINT		
	end

	return IsAllLegalTalent(player, tTalent)
end


-- 是否全部合法
function IsAllLegalTalent(player, TalentPointTab)
	if not TalentPointTab or not player then
		return ERR_TALENT_ERROR
	end
    
    for nSeriesID, t in pairs(TalentPointTab) do
        for nRow, tInfo in ipairs(t) do
            for nColumn, nPoint in ipairs(tInfo) do
                local nRetCode = IsLegalTalent(player, TalentPointTab, player.dwForceID, nSeriesID, nRow, nColumn)
				if nRetCode ~= ERR_TALENT_SUCCESS then
					return nRetCode
				end
            end
        end
    end
    
	return ERR_TALENT_SUCCESS
end

-- 是否合法
function IsLegalTalent(player, TalentPointTab, nForceID, nSeriesID, nRow, nColum)
	if not player or not TalentPointTab then
		return ERR_TALENT_ERROR
	end
	if player.dwForceID ~= nForceID then
		return ERR_TALENT_NOT_FIRST_FORCE
	end
	
	local nSkillID = GetSkillID(player.dwForceID, nSeriesID, nRow, nColum)
	if nSkillID == 0 then
		return ERR_TALENT_SUCCESS -- 可能这个位置上没有技能
	end
	
	local nSkillPoint = GetTabInfo(TalentPointTab, nSeriesID, nRow, nColum)	
	if not nSkillPoint then
		return ERR_TALENT_ERROR
	end
	if nSkillPoint == 0 then
		return ERR_TALENT_SUCCESS -- 可能这个位置上没有点天赋
	end
	
	local tCondition = GetTalentCondition(player.dwForceID, nSkillID)
	if not tCondition then
		return ERR_TALENT_ERROR
	end
		
	local TalentSubsectionInfo = StatisticsTalentSubsectionInfo(TalentPointTab)
	if not TalentSubsectionInfo then
		return ERR_TALENT_ERROR
	end
	
	-- 以下为天赋条件判断:
	-- 等级
	if player.nLevel < tCondition.nNeedLevel then
		return ERR_TALENT_LEVEL_LOWER
	end
	
	-- 本天赋点数
	local TalentSkill = GetSkill(nSkillID, 1)
	if not TalentSkill then
		return ERR_TALENT_ERROR
	end 
	if nSkillPoint < 0 then
		return ERR_TALENT_MIN_SKILL_LEVEL
	end
	if nSkillPoint > TalentSkill.dwMaxLevel then
		return ERR_TALENT_MAX_SKILL_LEVEL
	end
	
	-- 上N-1层点数关系
	if not TalentSubsectionInfo[nSeriesID] or not TalentSubsectionInfo[nSeriesID][nRow] then
		return ERR_TALENT_ERROR
	end
	if TalentSubsectionInfo[nSeriesID][nRow] < tCondition.nAllPoint then
		return ERR_TALENT_NOT_ENOUGH_ADDUP_POINT
	end
	
	-- 关联技能情况
	if not tCondition.PreviousTab then
		return ERR_TALENT_ERROR
	end
	for i = 1, #tCondition.PreviousTab do
		local nPrevSkillID 		= tCondition.PreviousTab[i][1]
		local nPrevSkillLevel	= tCondition.PreviousTab[i][2]
		if nPrevSkillLevel ~= 0 then
			local nS, nX, nY = GetPositionBySkillID(player.dwForceID, nPrevSkillID)
			if nS ~= 0 and nX ~= 0 and nY ~= 0 then
				local nTalentPoint = GetTabInfo(TalentPointTab, nS, nX, nY)
				if not nTalentPoint then
					return ERR_TALENT_ERROR
				end
				if nTalentPoint < nPrevSkillLevel then
					return ERR_TALENT_NOT_ENOUGH_SKILL_POINT
				end
			end
		end
	end
	
	return ERR_TALENT_SUCCESS
end

function GetHadTalentPoint(TalentPointTab)
	local player = GetClientPlayer()
	if not player then
		return 0
	end
	
	local nHadTalentPoint = GetMaxTalentPoint(player.nLevel) - GetUsedTalentPoint(TalentPointTab)
	if nHadTalentPoint <= 0 then
		return 0
	end
	return nHadTalentPoint	
end

function GetUsedTalentPoint(TalentPointTab)
	local nUsedPoint = 0;
	if not TalentPointTab then
		return 0
	end
    
    for nSeriesID, t in pairs(TalentPointTab) do
        for nRow, tInfo in ipairs(t) do
            for nColumn, nPoint in ipairs(tInfo) do
                nUsedPoint = nUsedPoint + nPoint
            end
        end
    end
	return nUsedPoint
end