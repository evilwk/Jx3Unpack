local STR_OBJECT = g_tEquipInquireStrings
local tFliterSearchItem = 
{
    {nSortID = 5, nSubSortID=1},
}
local tFliterSortID = { [1] = true, [2]= true, [3]=true, [4]=true}

local ITEM_SRC_TYPE = 
{
    DUNGEON = STR_OBJECT.STR_SRC_TYPE[1], --"副本"，
    REPUTATION = STR_OBJECT.STR_SRC_TYPE[2], --"声望"
    PRESTIGE = STR_OBJECT.STR_SRC_TYPE[3], --威望，
    CONTRIBUTE = STR_OBJECT.STR_SRC_TYPE[4], --帮贡
    OUTDOORBOSS = STR_OBJECT.STR_SRC_TYPE[5], --野外BOSS
    WORLD = STR_OBJECT.STR_SRC_TYPE[6], --掉落
    SHOP = STR_OBJECT.STR_SRC_TYPE[7], --"商店"
    QUEST = STR_OBJECT.STR_SRC_TYPE[8], --"任务"
    ACTIVITY = STR_OBJECT.STR_SRC_TYPE[9], --"活动"
    CRAFT = STR_OBJECT.STR_SRC_TYPE[10], --"生活技能"
	MING_JIAN = STR_OBJECT.STR_SRC_TYPE[11], -- 名剑
}

local ITEM_SRC_FLITER_TYPE = 
{
    DUNGEON = STR_OBJECT.SRC_FLITER_TYPE[1], --"副本"，
    SHOP = STR_OBJECT.SRC_FLITER_TYPE[2], --"商店（声望商，威望商，帮贡商）"
    WORLD = STR_OBJECT.SRC_FLITER_TYPE[3], --世界掉落（野外boss， 掉落）
}

local FLITER_TYPES = 
{
	[ITEM_SRC_FLITER_TYPE.DUNGEON] = {ITEM_SRC_TYPE.DUNGEON},
	[ITEM_SRC_FLITER_TYPE.SHOP] = {
		ITEM_SRC_TYPE.REPUTATION, 
		ITEM_SRC_TYPE.PRESTIGE, 
		ITEM_SRC_TYPE.SHOP, 
		ITEM_SRC_TYPE.MING_JIAN, 
		ITEM_SRC_TYPE.CONTRIBUTE
	},
	[ITEM_SRC_FLITER_TYPE.WORLD] = 
	{
		ITEM_SRC_TYPE.WORLD,
		ITEM_SRC_TYPE.OUTDOORBOSS
	},
}

local function IsHaveBelongMapID(tBelongMapID, dwMapID)
    if not tBelongMapID then
        return false
    end
    
    for _, dwID in pairs(tBelongMapID) do
        if tonumber(dwID) == dwMapID then
            return true;
        end
    end
    return false;
end

local function IsCanUseByCamp(hItemInfo, nCamp)
    if nCamp == -1 then --全部
        return true
    elseif not hItemInfo.bCanNeutralCampUse and not hItemInfo.bCanGoodCampUse and not hItemInfo.bCanEvilCampUse then
        return false;
    elseif nCamp == CAMP.NEUTRAL and hItemInfo.bCanNeutralCampUse and not hItemInfo.bCanGoodCampUse and not hItemInfo.bCanEvilCampUse then -- 中立 
        return true
    elseif nCamp == CAMP.GOOD and hItemInfo.bCanGoodCampUse and not hItemInfo.bCanNeutralCampUse and not hItemInfo.bCanEvilCampUse then -- 浩气 
        return true
    elseif nCamp == CAMP.EVIL and hItemInfo.bCanEvilCampUse and not hItemInfo.bCanNeutralCampUse and not hItemInfo.bCanGoodCampUse then -- 恶人
        return true
    end
    return false
end

local function MatchString(szSrc, szDst)
    local nPos = StringFindW(szSrc, szDst)
    if not nPos then
       return false;
    end

    return true
end

local function JudgeName(szSrc, szDst)
    if szDst == STR_OBJECT.STR_TYPE_ALL or szDst == "" then
        return true
    end
    return MatchString(szSrc, szDst)
end

local function IsInRange(nMin, nMax, nValue)
    if nValue < nMin or nValue > nMax then
        return false
    end
    return true
end

local function JudgeSourceType(SrcType, Key)
    if Key == STR_OBJECT.STR_TYPE_ALL then
        return true
    end
    for szFliterType, tType in pairs(FLITER_TYPES) do
		if szFliterType == Key then
			for _, v in pairs(tType) do
				if MatchString(SrcType, v) then
					return true
				end
			end
			return false;
		end
	end
    return false;
end

local function JudgeType(SrcType, DstType, TypeAll)
    if not TypeAll then
        TypeAll = STR_OBJECT.STR_TYPE_ALL
    end
    
    if SrcType == TypeAll or DstType == TypeAll then
        return true;
    end
    return (SrcType == DstType)
end

local function JudgeSet(bSetCheck, nSetID)
    if not bSetCheck then
        return true
    end
    
    if nSetID ~= 0 then
        return true
    end
    return false;
end

local function JudgePvePvp(szSrcPvePvp, szDstPvePvp)
    if szDstPvePvp == STR_OBJECT.STR_TYPE_ALL then
        return true
    end
    
    if szDstPvePvp == szSrcPvePvp then
        return true
    end
    return false
end

local function JudgeMagicType(szSrc, szDst)
    if szDst == STR_OBJECT.STR_TYPE_ALL then
        return true
    end
    
    if szSrc == STR_OBJECT.STR_TYPE_ALL then
        return false
    end
    
    return MatchString(szSrc, szDst)
end

local function FormatDropRate(fValue)
    fValue = fValue + 0.000005
    fValue = fValue * 100
    fValue = string.format("%.2f", fValue)
    return tostring(fValue) .. "%"
end

local function IsBossName(szBossName)
    for key, value in pairs(g_tEquipInquireStrings.DUNGEON) do
        for _, tLayer1 in pairs(value.tDungeon) do
            local tBoss = tLayer1.tNormalBoss or {}
            for _, szName in pairs(tBoss) do
                if szName == szBossName then
                    return true
                end
            end
            local tBoss = tLayer1.tHardBoss or {}
            for _, szName in pairs(tBoss) do
                if szName == szBossName then
                    return true
                end
            end
        end
    end
    return false
end

local function GetDropRateText(fDropRate)
    local szDropRate = FormatDropRate(fDropRate)
    if szDropRate == "0.00%" then
        szDropRate = g_tStrings.STR_GUILD_LAST_ONLINE_TIME_UNKNOWN
    end
    return GetFormatText(STR_OBJECT.STR_DROP_RATE..szDropRate)
end

local function FormatSourceDesc(szSourceDesc)
    local tResult = {}
    for szString in string.gmatch(szSourceDesc, "%b{}") do
        local tBoss = SplitString(szString:sub(2, #szString - 1), ",")
        table.insert(tResult, tBoss)
    end
    if #tResult == 0 then
        local tBoss = SplitString(szSourceDesc, ",")
        table.insert(tResult, tBoss)
    end
    return tResult
end

local function GetDungeonDesc(tSourceDesc, tBelongMapID, szOther, szBossPrefix)
    local szUnknow = g_tStrings.STR_GUILD_LAST_ONLINE_TIME_UNKNOWN
    if not tSourceDesc or #tSourceDesc == 0 then
        return GetFormatText(szOther..szUnknow)
    end
    
    local szText = ""
    local szText1  = ""
    for i, tBoss in ipairs(tSourceDesc) do
        if i ~= 1 then
            szText = szText..GetFormatText("\n\n")
        end
        
        local dwMapID = tBelongMapID[i]
        local szMapName = szUnknow
        if dwMapID and dwMapID ~= "0" then
            szMapName = Table_GetMapName(tonumber(dwMapID)) --副本名
            if szMapName == "" then
                szMapName = szUnknow
            end
        end
        szText = szText..GetFormatText(szOther..szMapName)

        local szBoss, szNpc = "", ""
        for k, szName in ipairs(tBoss) do
            if IsBossName(szName) then
                local nID = EquipInquire_GetLinkStringID(szName)
                szBoss = szBoss..GetFormatText(szName, 16,nil,nil,nil,nil,nil, nil, nil, "Dungeon_"..dwMapID.."_"..nID)
                szBoss = szBoss..GetFormatText("  ")
            else
                szNpc = szNpc .. GetFormatText("["..szName.."] ")
            end
        end
        if szBoss ~= "" then
            szText = szText..GetFormatText("\n"..szBossPrefix)..szBoss
        end
        if szNpc ~= "" then
            szText = szText..GetFormatText("\n"..STR_OBJECT.STR_MONSTER)..szNpc
        end
    end
    return szText
end

local function GetReputationDesc(tSourceDesc, szSourceForce , szPrestigeRequire, szOther) -- szOther = szSourceType.. STR_OBJECT.STR_SHOP
    local szUnknow = g_tStrings.STR_GUILD_LAST_ONLINE_TIME_UNKNOWN
    if not tSourceDesc or #tSourceDesc == 0 then
        return GetFormatText(szOther.. g_tStrings.STR_COLON .. szUnknow)
    end
    
    local szText = ""
    szText = szText .. GetFormatText(szSourceForce..szOther)
    for k, szName in pairs(tSourceDesc) do
        local nID = EquipInquire_GetLinkStringID(szName)
        szText = szText..GetFormatText(szName, 16, nil, nil, nil, nil, nil, nil, nil, "Shop_"..nID)
    end
    
    if szPrestigeRequire ~= "" then
        szText = szText..GetFormatText("\n"..STR_OBJECT.STR_NEED_REPUTATION .. szSourceForce.." "..szPrestigeRequire)
    end
    
    return szText
end

local function GetPrestigeDesc(tSourceDesc, szSourceForce , szOther)
    local szUnknow = g_tStrings.STR_GUILD_LAST_ONLINE_TIME_UNKNOWN
    if not tSourceDesc or #tSourceDesc == 0 then
        return GetFormatText(szOther .. szUnknow)
    end
    
    local szText = ""
    szText = szText .. GetFormatText(szSourceForce .. szOther)
    for k, szName in pairs(tSourceDesc) do
        local nID = EquipInquire_GetLinkStringID(szName)
        szText = szText..GetFormatText(szName, 16, nil, nil, nil, nil, nil, nil, nil, "Shop_"..nID)
        szText = szText..GetFormatText("  ")
    end
    return szText
end

local function GetContributeDesc(tSourceDesc, szOther)
    local szUnknow = g_tStrings.STR_GUILD_LAST_ONLINE_TIME_UNKNOWN
    if not tSourceDesc or #tSourceDesc == 0 then
        return GetFormatText(szOther .. szUnknow)
    end
    
    local szText = ""
    szText = szText .. GetFormatText(szOther)
    for k, szName in ipairs(tSourceDesc) do
        local nID = EquipInquire_GetLinkStringID(szName)
        szText = szText..GetFormatText(szName, 16, nil, nil, nil, nil, nil, nil, nil, "Shop_"..nID)
        szText = szText..GetFormatText("  ")
    end
    
    return szText
end

local function GetOutlineBoss(tSourceDesc, tBelongMapID)
    local szUnknow = g_tStrings.STR_GUILD_LAST_ONLINE_TIME_UNKNOWN
    if not tSourceDesc or #tSourceDesc == 0 then
        return GetFormatText(STR_OBJECT.STR_BOSS_YEWAI .. szUnknow)
    end
            
    local szText = ""
    for nIndex, tSource in pairs(tSourceDesc) do
        if nIndex ~= 1 then
            szText = szText..GetFormatText("\n")
        end
        
        local szMapName = szUnknow
        local dwMapID = tBelongMapID[nIndex]
        if dwMapID and dwMapID ~= "0" then
            szMapName = Table_GetMapName(tonumber(dwMapID))
        end
        szText = szText .. GetFormatText(g_tStrings.HEADER_SHOW_MAP..szMapName)
        szText = szText .. GetFormatText("\n"..STR_OBJECT.STR_BOSS_YEWAI)
        
        if #tSource == 0 then
            szText = szText..GetFormatText(szUnknow)
        else
            for k, szName in ipairs(tSource) do
                szText = szText..GetFormatText("["..szName.."] ")
            end
        end
    end
    return szText
end

local function GetCommonDesc(tSourceDesc)
    local szText = ""
    for nIndex, tSource in ipairs(tSourceDesc) do
        if type(tSource) == "table" then
            for k, szName in pairs(tSource) do
                szText = szText..GetFormatText(szName.." ")
            end
        else
            szText = szText..GetFormatText(tSource.." ")
        end
    end
    return szText
end

local function GetItemSourceDesc(szSourceType, tSourceDesc, tBelongMapID, szSourceForce , szPrestigeRequire)
	local szLine = GetFormatText("\n")
    local szText = ""
    local szUnknow = g_tStrings.STR_GUILD_LAST_ONLINE_TIME_UNKNOWN
     
	if JudgeSourceType(szSourceType, ITEM_SRC_FLITER_TYPE.SHOP) then  --商店 shop
		if szSourceType == ITEM_SRC_TYPE.REPUTATION then
			local szOther = szSourceType..STR_OBJECT.STR_SHOP..g_tStrings.STR_COLON
			szText = szText .. GetReputationDesc(tSourceDesc, szSourceForce , szPrestigeRequire, szOther)
		elseif szSourceType== ITEM_SRC_TYPE.CONTRIBUTE then
			local szOther = STR_OBJECT.STR_TONG_SHOP..g_tStrings.STR_COLON
			szText = szText .. GetContributeDesc(tSourceDesc, szOther)
		else
			local szOther = szSourceType..STR_OBJECT.STR_SHOP..g_tStrings.STR_COLON
			szText = szText .. GetPrestigeDesc(tSourceDesc, szSourceForce , szOther)
		end
	elseif JudgeSourceType(szSourceType, ITEM_SRC_FLITER_TYPE.DUNGEON) then  --秘境
		szText = szText..GetDungeonDesc(tSourceDesc, tBelongMapID, STR_OBJECT.STR_DUENGON_WORD, STR_OBJECT.STR_BOSS)
	
	elseif JudgeSourceType(szSourceType, ITEM_SRC_FLITER_TYPE.WORLD) then  --世界
	    if szSourceType== ITEM_SRC_TYPE.WORLD then
			if not tSourceDesc or #tSourceDesc == 0 then
				szText = szText .. GetFormatText(STR_OBJECT.STR_DROP_WORLD .. szUnknow)
			else
				szText = szText .. GetFormatText(STR_OBJECT.STR_DROP_WORLD)
				szText = szText .. GetCommonDesc(tSourceDesc)
			end
        
		elseif szSourceType == ITEM_SRC_TYPE.OUTDOORBOSS then
			szText = szText..GetDungeonDesc(tSourceDesc, tBelongMapID, g_tStrings.HEADER_SHOW_MAP, STR_OBJECT.STR_BOSS_YEWAI)
		else
			szText = szText..GetDungeonDesc(tSourceDesc, tBelongMapID, g_tStrings.HEADER_SHOW_MAP, STR_OBJECT.STR_BOSS_YEWAI)
		end
		
    elseif szSourceType== ITEM_SRC_TYPE.QUEST or
           szSourceType== ITEM_SRC_TYPE.ACTIVITY then
        szText = szText .. GetFormatText(szSourceType.. g_tStrings.STR_COLON)
        if not tSourceDesc or #tSourceDesc == 0 then
            szText = szText .. GetFormatText(szUnknow)
        else
            szText = szText .. GetCommonDesc(tSourceDesc)
        end
        
    elseif szSourceType == ITEM_SRC_TYPE.CRAFT then
        szText = szText .. GetFormatText(szSourceType.. g_tStrings.STR_COLON)
        if not tSourceDesc or #tSourceDesc == 0 then
            szText = szText .. GetFormatText(szUnknow)
        else
            szText = szText .. GetCommonDesc(tSourceDesc)
        end
    else
        szText = szText .. GetCommonDesc(tSourceDesc)
    end
    return szText
end


function EquipInquire_GetItemSourceDesc(tInfo)
    local szText = ""
    for i, tSource in ipairs(tInfo.tSourceDesc) do
        local szSourceType = tInfo.tSourceType[i] or {}
        local tSourceDesc = tInfo.tSourceDesc[i] or {}
        local tBelongMapID = tInfo.tBelongMapID or {}
        local szSourceForce = tInfo.szSourceForce or ""
        local szPrestigeRequire  = tInfo.szPrestigeRequire  or ""
        if szSourceType and szSourceType ~= "" then
            if szText ~= "" then
                szText = szText .. GetFormatText("\n\n")
            end
            szText = szText .. GetItemSourceDesc(szSourceType, tSourceDesc, tBelongMapID, szSourceForce, szPrestigeRequire )
        end
    end
    
    local szDesc = tInfo.szOtherDesc
    if szDesc and szDesc ~= "" then
        szText = szText .. GetFormatText("\n"..szDesc)
    end
    if szText == "" then
        szText = GetFormatText(g_tStrings.STR_GUILD_LAST_ONLINE_TIME_UNKNOWN)
    end
    return szText
end

function EquipInquire_GetDungeonType(dwMapID)
    local szMapName = Table_GetMapName(dwMapID)
    local _, nMapType, nMaxPlayerCount= GetMapParams(dwMapID)
    
	local nType = nil
    if nMapType == MAP_TYPE.DUNGEON then
        local nRefreshCycle = GetMapRefreshInfo(dwMapID)
        if nRefreshCycle == 0 and nMaxPlayerCount <= 5 then
            nType = DUNGEON_TYPE.NORMAL
        elseif nRefreshCycle ~= 0 and nMaxPlayerCount <= 5 then
            nType = DUNGEON_TYPE.HARD
        elseif nRefreshCycle ~= 0 and nMaxPlayerCount > 5 then
            nType = DUNGEON_TYPE.RAID
        end
    end
    return nType
end

function EquipInquire_GetCatalog1()
    local function IsFliterItem(nSortID, nSubSortID)
        for _, v in pairs(tFliterSearchItem) do
            if (v.nSortID == nSortID and v.nSubSortID == nSubSortID) then
                return true;
            end
        end
        return false;
    end

    local tItemType = {}
    for szType, tSubType in pairs(g_tAuctionString.tSearchSort) do
        if tFliterSortID[tSubType.nSortID] then
            local tData = {name=szType, type=tSubType.nSortID,  tSubType = {}}
            for szSubType, nID in pairs(tSubType.tSubSort) do
                if not IsFliterItem(tSubType.nSortID, nID) then
                    table.insert(tData.tSubType, {name=szSubType, type=nID})
                end
            end
            table.sort(tData.tSubType, function(a, b) return a.type < b.type end)
            table.insert(tItemType, tData)
        end
	end
    table.sort(tItemType, function(a, b) return a.type < b.type end)
    return tItemType
end

function EquipInquire_GetCatalog3()
    local tItemType = {}
    for _, tInfo in ipairs(g_tEquipInquireStrings.SHOP) do
        local tData = {name=tInfo[1], type=tInfo[1], tSubType={}}
        for _, szName in ipairs(tInfo[2]) do
            table.insert(tData.tSubType, {name=szName, type=szName})
        end
        table.insert(tItemType, tData)
	end
    return tItemType
end

local function GetCampUse(hItemInfo)
    local szCamp = ""
    if not hItemInfo.bCanGoodCampUse and not hItemInfo.bCanEvilCampUse and not  hItemInfo.bCanNeutralCampUse then
        return ""
    end
    
    if hItemInfo.bCanGoodCampUse then
        szCamp = szCamp..g_tStrings.TIP_CAMP_GOOD
    end
    
    if hItemInfo.bCanEvilCampUse then
        if hItemInfo.bCanGoodCampUse then
            szCamp = szCamp..STR_OBJECT.STR_OR_WORD
        end
        szCamp = szCamp..g_tStrings.TIP_CAMP_EVIL
    end
    
    if hItemInfo.bCanNeutralCampUse then
        if hItemInfo.bCanGoodCampUse or hItemInfo.bCanEvilCampUse then
            szCamp = szCamp..STR_OBJECT.STR_OR_WORD
        end
        szCamp = szCamp..g_tStrings.TIP_CAMP_NEUTRAL
    end
    return szCamp;
end

local function GetItemInfoRequireLevel(nTabType, itemInfo)
    if nTabType == ITEM_TABLE_TYPE.OTHER then
        return itemInfo.nRequireLevel
    else
        local requireAttrib = itemInfo.GetRequireAttrib()
        for k, v in pairs(requireAttrib) do
            if v.nID == 5 then
                return v.nValue
            end
        end
    end
    return 0
end

local function GetItemAuctionType(nAucType, nAucSubType)
    for k, v in pairs(g_tAuctionString.tSearchSort) do
        if v.nSortID == nAucType then
            for szKey, nID in pairs(v.tSubSort) do
                if nID == nAucSubType then
                    return szKey
                end
            end
        end
    end
end

local function FormatItemInfo(tLine)
    local itemInfo = GetItemInfo(tLine.dwTabType, tLine.nItemID)
    local szItemName =  GetItemNameByItemInfo(itemInfo)
    
    return {
                szName = szItemName,
                dwTabType = tLine.dwTabType,
                nItemID = tLine.nItemID,
                szEquipType = GetItemAuctionType(tLine.nAucType, tLine.nAucSubType),
                nRequireLevel = GetItemInfoRequireLevel(dwTabType, itemInfo),
                nQualityLevel = itemInfo.nLevel,
                szCampRequest = GetCampUse(itemInfo),
                nSchoolID = tLine.nSchoolID,
                szSourceType = tLine.szSourceType,
                szSourceDesc = tLine.szSourceDesc,  
                szSourceForce = tLine.szSourceForce,
                szBelongMapID = tLine.szBelongMapID,
                szPrestigeRequire = tLine.szPrestigeRequire,
            }
end

function EquipInquire_SearchEquip(
    szName, 
    nRequireLevelMin, nRequireLevelMax, 
    nQualityLevelMin, nQualityLevelMax, 
    nQuality, 
    szSourceType,
    szSchool,
    szMagicKind, --（内功加 门派）外功, 内功, 防御, 治疗 ..
    szMagicType, -- 属性 (无双、会心, 破防 ...)
    nCamp, -- 0 中立 1 浩气盟 2 恶人谷
    szPvePvp, -- pve pve
    nType, nSubType,
    bSetChecked
)
	local tEquip = {}
	local nCount = g_tTable.EquipDB:GetRowCount()
    for i=2, nCount do
		local tLine = g_tTable.EquipDB:GetRow(i)
        local itemInfo = GetItemInfo(tLine.dwTabType, tLine.nItemID)
        if itemInfo then
            local nRequireLevel = GetItemInfoRequireLevel(tLine.dwTabType, itemInfo)
            local szItemName =  GetItemNameByItemInfo(itemInfo)
            local bFliter = false
            
            if not JudgeName(szItemName, szName) or 
               tLine.nAucType == -1 or 
               tLine.nAucSubType == -1 or 
               not JudgeType(tLine.nAucType, nType, -1) or
               not JudgeType(tLine.nAucSubType, nSubType, -1) or 
               not IsInRange(nRequireLevelMin, nRequireLevelMax, nRequireLevel) or
               not JudgeType(itemInfo.nQuality, nQuality, -1) or 
               not IsInRange(nQualityLevelMin, nQualityLevelMax, itemInfo.nLevel) or
               not JudgeType(Table_GetSkillSchoolName(tLine.nSchoolID), szSchool, STR_OBJECT.STR_TYPE_ALL) or 
               not JudgeType(tLine.szMagicKind, szMagicKind, STR_OBJECT.STR_TYPE_ALL) or 
               not JudgeMagicType(tLine.szMagicType, szMagicType) or 
               not JudgeSourceType(tLine.szSourceType, szSourceType) or
               not IsCanUseByCamp(itemInfo, nCamp) or
               not JudgePvePvp(tLine.szPvePvp, szPvePvp)  or 
               not JudgeSet(bSetChecked, tLine.nSetID) then
                bFliter = true;
            end
            if not bFliter then
                local tData = FormatItemInfo(tLine)
                table.insert(tEquip, tData)
            end
        else
            Trace("item dwTabType="..tLine.dwTabType.." nItemID="..tLine.nItemID.." is not Exist!")
        end
	end
	return tEquip
end

function EquipInquire_SearchDungeonEquip(szBossName, nMapID)
    local tEquip = {}
	local nCount = g_tTable.EquipDB:GetRowCount()
	for i = 2, nCount do
		local tLine = g_tTable.EquipDB:GetRow(i)
        local tBelongMapID
        if tLine.szBelongMapID and tLine.szBelongMapID ~= "0" then
            tBelongMapID = SplitString(tLine.szBelongMapID, ",")
        end
        
        if (MatchString(tLine.szSourceType, ITEM_SRC_TYPE.DUNGEON) or MatchString(tLine.szSourceType, ITEM_SRC_TYPE.OUTDOORBOSS)) and 
           IsHaveBelongMapID(tBelongMapID, nMapID) and 
           MatchString(tLine.szSourceDesc, szBossName) then
            local tData = FormatItemInfo(tLine)
            table.insert(tEquip, tData)     
        end        
    end
    return tEquip;
end

function EquipInquire_GetDungeonEquip(nMapID)
    local tEquip = {}
	local nCount = g_tTable.EquipDB:GetRowCount()
	for i = 2, nCount do
		local tLine = g_tTable.EquipDB:GetRow(i)
        local tBelongMapID = {}
        if tLine.szBelongMapID and tLine.szBelongMapID ~= "0" then
            tBelongMapID = SplitString(tLine.szBelongMapID, ",")
        end
        
        if IsHaveBelongMapID(tBelongMapID, nMapID) then
            tResult = EquipInquire_FormatData(tLine)
            local nIndex = 1
            for k, szType in ipairs(tResult.tSourceType) do
                if szType == ITEM_SRC_TYPE.DUNGEON then
                    nIndex = k
                    break
                end
            end
            local tSource = tResult.tSourceDesc[nIndex]
            nIndex = 1
            for k, ID in ipairs(tBelongMapID) do
                if ID == nMapID then
                    nIndex = k
                end
            end
            local tBossName = tSource[nIndex] or {}
            for k, szName in pairs(tBossName) do
                if not tEquip[szName] then
                    tEquip[szName] = {}
                end
                table.insert(tEquip[szName], {dwTabType=tLine.dwTabType, nItemID=tLine.nItemID})
            end
        end     
    end
    return tEquip;
end

function EquipInquire_SearchShopEquip(szShopName)
    local tEquip = {}
	local nCount = g_tTable.EquipDB:GetRowCount()
	for i = 2, nCount do
		local tLine = g_tTable.EquipDB:GetRow(i)
        if JudgeSourceType(tLine.szSourceType, ITEM_SRC_FLITER_TYPE.SHOP) then
            local bChoose = false
            if szShopName == EQUIP_SEARCH_ALL then
                bChoose = true
            elseif MatchString(tLine.szSourceDesc, szShopName) then
                bChoose = true
            end
            if bChoose then
                local tData = FormatItemInfo(tLine)
                table.insert(tEquip, tData)    
            end            
        end      
    end
    return tEquip; 
end

function EquipInquire_PopupMenu(hBtn, text, tData)
	if hBtn.bIgnor then
		hBtn.bIgnor = nil
		return
	end
    
	local szName = text:GetName()
	local xT, yT = text:GetAbsPos()
	local wT, hT = text:GetSize()
	local menu =
	{
		nMiniWidth = wT,
		x = xT, y = yT + hT,
		fnCancelAction = function()
			if hBtn:IsValid() then
				local x, y = Cursor.GetPos()
				local xA, yA = hBtn:GetAbsPos()
				local w, h = hBtn:GetSize()
				if x >= xA and x < xA + w and y >= yA and y <= yA + h then
                    hBtn.bIgnor = true
				end
			end
		end,
		fnAction = function(UserData)
			if text:IsValid() then
                text:SetText(UserData.name)
                text.Value = UserData.value
                if szName == "Text_School" then
                    text.Value1 = UserData.value1
                end
			end
		end,
		fnAutoClose = function() return not IsEquipInquireOpened() end,
	}
	for k, v in ipairs(tData) do
        table.insert(menu, {szOption = v.name, UserData= v, r = v.r, g = v.g, b = v.b})
	end
	PopupMenu(menu)
end

function EquipInquire_SelectResult(hSelItem, szImage)
    local hList = hSelItem:GetParent()
    if hList.hSelItem then
        hList.hSelItem.bSel = false
        EquipInquire_UpdateBgStatus(hList.hSelItem, szImage)
    end
    hSelItem.bSel = true
    hList.hSelItem = hSelItem
    EquipInquire_UpdateBgStatus(hSelItem, szImage)
end

function EquipInquire_UpdateBgStatus(hItem, szImage)
    if not hItem then
		return
	end
	local img = hItem:Lookup(szImage)
	if not img then
		return
	end

	if hItem.bSel then
		img:Show()
		img:SetAlpha(255)
	elseif hItem.bOver then
		img:Show()
		img:SetAlpha(128)
	else
		img:Hide()
	end
end

function EquipInquire_DungeonFirstAndSecond(nMapID, szName)
    for k, tFirst in ipairs(STR_OBJECT.DUNGEON) do
        local szFirstName = tFirst.szType
        for _, tSecond in ipairs(tFirst.tDungeon) do
            local szSecondName = tSecond.szDunName
            if nMapID == tSecond.nNormalID then
                for _, szBossName in ipairs(tSecond.tNormalBoss) do
                    if szBossName == szName then
                        return szFirstName, szSecondName
                    end
                end
            end
            if nMapID == tSecond.nHardID then
                for _, szBossName in ipairs(tSecond.tHardBoss) do
                    if szBossName == szName then
                        return szFirstName, szSecondName
                    end
                end
            end
        end
    end
    return
end

function EquipInquire_ShopFirst(szName)
    for k, tFirst in ipairs(STR_OBJECT.SHOP) do
        local szFirstName = tFirst[1]
        for _, tSecond in ipairs(tFirst[2]) do
			if type(tSecond) == "table" then
				local szSuffix = tSecond.szSuffix or ""
				for _, szShopName in ipairs(tSecond[2]) do
					local szDst = szSuffix..szShopName
					if szDst == szName then
						return szFirstName, tSecond[1], szShopName, szSuffix
					end
				end
			else
				if tSecond == szName then
					return szFirstName, tSecond
				end
			end
        end
    end
    return
end

    
local function GetPaseResult(szString, szBegin, szEnd)
    local tData = {}
    if string.sub(szString, 1,1) ~= szBegin or string.sub(szString, #szString) ~= szEnd then
        return SplitString(szString, ","), szString
    end
    
    local szWord = ""
    for szSubString in string.gmatch(szString, "%b"..szBegin..szEnd) do
        local szNew = ""
        if szSubString ~= (szBegin..szEnd) then
            szNew = string.sub(szSubString, 2, #szSubString - 1)
        end
        
        local szResult, szNewWord = GetPaseResult(szNew, "[", "]")
        szWord = szWord .." "..szNewWord
        table.insert(tData, szResult)
    end
    return tData, szWord
end

function EquipInquire_FormatData(tInfo)
    local tResult = {}
    tResult.tBelongMapID = {}
    if tInfo.szBelongMapID and tInfo.szBelongMapID ~= "" and tInfo.szBelongMapID ~= 0 then
        tResult.tBelongMapID = SplitString(tInfo.szBelongMapID, ",")
    end

    tResult.tSourceType = {}
    tResult.tSourceType = SplitString(tInfo.szSourceType, ",")

    tResult.szSourceForce = tInfo.szSourceForce
    tResult.szPrestigeRequire = tInfo.szPrestigeRequire
    
    if tInfo.szSourceDesc and tInfo.szSourceDesc ~= "" then
        local szSourceDesc, szDesc = string.match(tInfo.szSourceDesc, "(.+)(%b())")
        if szSourceDesc then
            tInfo.szSourceDesc = szSourceDesc
        end
        tResult.szOtherDesc = szDesc or ""
    end
    
    tResult.tSourceDesc = {}
    if tInfo.szSourceDesc and tInfo.szSourceDesc ~= "" then
        tResult.tSourceDesc, tResult.szSourceDesc = GetPaseResult(tInfo.szSourceDesc, "{", "}")
    end
    return tResult
end