ZhenPaiSkill=
{
}

local l_bClientPlayer = true
local COLUMN_COUNT = 4
local ROW_COUNT = 6
local tTalentTab = nil;
local tTalentTabView = {};
local tTalentSkillID = {};

local nTotalTalentPoint = 0
local nOwnTalentPoint = 0

local nOwnTalentPointView = 0
local tOperateList = {}

local TALENT_LEARNING = false
local TALENT_INDEX = 1
local TALENT_LEARN_SKILL = -1;

local SERIES_TYPE =
{
    LEFT = 1,
    RIGHT = 2,
}
local SERIES_TYPE_STRING =
{
    [SERIES_TYPE.LEFT] = "Left",
    [SERIES_TYPE.RIGHT] = "Right",
}

local nUsedTalentPoint = {[SERIES_TYPE.LEFT] = 0, [SERIES_TYPE.RIGHT] = 0,}

local WIDGET = 
{
    hFrame = nil,
    hLeftWnd = nil,
    hRightWnd = nil,
}

local function InitObject(hFrame)
    WIDGET.hFrame = hFrame
    WIDGET.hLeftWnd = hFrame:Lookup("Wnd_LeftSkill")
    WIDGET.hRightWnd = hFrame:Lookup("Wnd_RightSkill")
end

local function OwnTalentPointChange()
    WIDGET.hFrame:Lookup("", "Text_Point"):SetText(nOwnTalentPointView)
    WIDGET.hFrame:Lookup("", "Handle_All1"):Lookup("Text_UsePoint"):SetText(nUsedTalentPoint[SERIES_TYPE.LEFT])
    WIDGET.hFrame:Lookup("", "Handle_All2"):Lookup("Text_UsePoint1"):SetText(nUsedTalentPoint[SERIES_TYPE.RIGHT])
    
    if nOwnTalentPointView < nOwnTalentPoint then
        WIDGET.hFrame:Lookup("Btn_Learn"):Enable(true)
    else
        WIDGET.hFrame:Lookup("Btn_Learn"):Enable(false)
    end
end

local function SetPointTextColor(nSeriesID, nRow, nColumn)
    local dwSkillID = tTalentSkillID[nSeriesID][nRow][nColumn]
    local dwLevel = tTalentTabView[nSeriesID][nRow][nColumn]
    local skill = GetSkill(dwSkillID, 1)
    local nIndex = (nRow - 1) * COLUMN_COUNT + nColumn
    local r, g ,b = 0, 255, 0
    
    if not skill then
        Trace(string.format("klua error: GetSkill(%s, 1) is nil", dwSkillID));
        return
    end
    
    if skill.dwMaxLevel == dwLevel then
        r, g, b = 255, 150, 0
    end
    
    local hText
    if nSeriesID == SERIES_TYPE.LEFT then
        local hHandle = WIDGET.hLeftWnd:Lookup("", ""):Lookup(nIndex - 1)
        hText = hHandle:Lookup("Text_Left")
    else
        local hHandle = WIDGET.hRightWnd:Lookup("", ""):Lookup(nIndex - 1)
        hText = hHandle:Lookup("Text_Right")
    end
    hText:SetFontColor(r, g, b)
    local nR, nG,nB= hText:GetFontColor()
end

local function GetSkillLevel(dwSkillID)
    if l_bClientPlayer then
        local player = GetClientPlayer()
        local nLevel = player.GetSkillLevel(dwSkillID)
        return (nLevel or 0)
    else
        return ZhenPaiSkill.aSkill[dwSkillID] or 0
    end
end

local function GetForceKungFuData(dwForceID)
	local tResult = {}
    local nCount = g_tTable.Talent:GetRowCount()
    for i = 1, nCount do
        local tLine = g_tTable.Talent:GetRow(i)
        if tLine.dwForceID ==  dwForceID then
            tResult[tLine.nTalentType] = {szTalentName = tLine.szTalentName, szImage = tLine.szImage, nIconID = tLine.nIconID}
        end
    end
    return tResult
end

function GetTalentPoint(nSeriesID, nRow, nColumn)
    if not tTalentTabView[nSeriesID] or 
       not tTalentTabView[nSeriesID][nRow] or 
       not tTalentTabView[nSeriesID][nRow][nColumn] then
       return
    end
    return tTalentTabView[nSeriesID][nRow][nColumn]
end

local function SetTalentPoint(nSeriesID, nRow, nColumn, Value)
    local nDelta = Value - tTalentTabView[nSeriesID][nRow][nColumn]
    
    tTalentTabView[nSeriesID][nRow][nColumn] = Value
    nUsedTalentPoint[nSeriesID] = nUsedTalentPoint[nSeriesID] + nDelta
    nOwnTalentPointView = nOwnTalentPointView - nDelta
    
    OwnTalentPointChange()
    SetPointTextColor(nSeriesID, nRow, nColumn)
end

local function IsSkillCanDelOne(hBox)
    local nViewLevel = GetTalentPoint(hBox.nSeriesID, hBox.nRow, hBox.nColumn)
    local player = GetClientPlayer()
    local nLevel = player.GetSkillLevel(hBox.dwSkillID)
    if nViewLevel - 1 >= nLevel then
        return true
    end
    return false
end

local function DoAddOperate(nSeriesID, nRow, nColumn)
    local bExist = false;
    for _, tInfo in ipairs(tOperateList) do
        if tInfo[1] == nSeriesID and tInfo[2] == nRow and tInfo[3] == nColumn then
            bExist = true
            break;
        end
    end
    if not bExist then
        table.insert(tOperateList, {nSeriesID, nRow, nColumn})
    end
    
    local nValue = GetTalentPoint(nSeriesID, nRow, nColumn)
    SetTalentPoint(nSeriesID, nRow, nColumn, nValue + 1)
    ZhenPaiSkill.UpdateBoxClickState()
end


local function DoDelOperate(nSeriesID, nRow, nColumn)
    local nIndex = -1;
    for i, tInfo in ipairs(tOperateList) do
        if tInfo[1] == nSeriesID and tInfo[2] == nRow and tInfo[3] == nColumn then
            nIndex = i
            break;
        end
    end
    
    if nIndex ~= -1 then
        local nValue = GetTalentPoint(nSeriesID, nRow, nColumn) - 1
        SetTalentPoint(nSeriesID, nRow, nColumn, nValue)
        ZhenPaiSkill.UpdateBoxClickState()
        
        local player = GetClientPlayer()
        local dwSkillID = tTalentSkillID[nSeriesID][nRow][nColumn]
        local nLevel = player.GetSkillLevel(dwSkillID)
        if nLevel == nValue then
            table.remove(tOperateList, nIndex)
        end
    end
end

local function GetSkillViewLevel(dwSkillID)
    for i=1, ROW_COUNT , 1 do 
        for j = 1, COLUMN_COUNT, 1 do
            if tTalentSkillID[SERIES_TYPE.LEFT][i][j] then
                if tTalentSkillID[SERIES_TYPE.LEFT][i][j] == dwSkillID then
                    return tTalentTabView[SERIES_TYPE.LEFT][i][j]
                end
                
                if tTalentSkillID[SERIES_TYPE.RIGHT][i][j] == dwSkillID then
                    return tTalentTabView[SERIES_TYPE.RIGHT][i][j]
                end
            end
        end
    end
end

local function GetTalentWidgetName(nSeriesID)
    local szKey = SERIES_TYPE_STRING[nSeriesID]
    local szBox = "Box_"..szKey
    local szText = "Text_"..szKey
    local szImage = "Image_"..szKey.."Arrow"
    local szImageBG = "Image_"..szKey.."Bg"
    local szImageC = "Image_"..szKey.."Circle"
    return szBox, szText, szImage, szImageBG, szImageC
end

local function InitTalentWidget()
    local szFileIni = "ui/Config/Default/ZhenPaiSkill.ini"
    local hLeftWnd = WIDGET.hLeftWnd
    local hRightWnd = WIDGET.hRightWnd
    
    local hHandleLeft = hLeftWnd:Lookup("", "")
    local hHandleRight = hRightWnd:Lookup("", "")
    
    hHandleLeft:Clear()
    hHandleRight:Clear()
    for i=1, ROW_COUNT, 1 do
        for j=1, COLUMN_COUNT, 1 do
            hHandleLeft:AppendItemFromIni(szFileIni, "Handle_LeftTep")
            hHandleRight:AppendItemFromIni(szFileIni, "Handle_RightTep")
        end
    end
    hHandleLeft:FormatAllItemPos()
    hHandleRight:FormatAllItemPos()
end

function ZhenPaiSkill.Init(hFrame)
    InitObject(hFrame)
    InitTalentWidget()

    tOperateList = {}
    TALENT_LEARNING = false
    TALENT_INDEX = 1
    TALENT_LEARN_SKILL = -1;

    local player = GetClientPlayer()
    if not ZhenPaiSkill.dwForceID then
        ZhenPaiSkill.dwForceID = player.dwForceID
    end
    
    tTalentTab = GetTalentTab(ZhenPaiSkill.dwForceID) or {}
    nTotalTalentPoint = GetMaxTalentPoint(player.nLevel)
    
    hFrame:Lookup("Btn_Learn"):Enable(false)
    ZhenPaiSkill.InitKungFu(hFrame)
    ZhenPaiSkill.UpdateTalent(tTalentTab)
    if not l_bClientPlayer then
        hFrame:Lookup("Btn_Learn"):Enable(false)
        if ZhenPaiSkill.szPlayerName then
            local szTitle = GetString("STR_TANLENT_TITLE").."("..ZhenPaiSkill.szPlayerName..")"
            hFrame:Lookup("", "Text_SkillTitle"):SetText(szTitle)
        end
        
        local aSkill = {}
        local function GetRequestSkillID(nSeriesID)
            for k, v in pairs(tTalentTab[nSeriesID]) do
                for _, dwSkillID in pairs(v) do
                    if dwSkillID and dwSkillID ~= 0 then
                        table.insert(aSkill, dwSkillID)
                    end
                end
            end
        end
        GetRequestSkillID(SERIES_TYPE.LEFT)
        GetRequestSkillID(SERIES_TYPE.RIGHT)
        RemoteCallToServer("OnGetSkillLevelRequest", ZhenPaiSkill.dwPlayerID, aSkill)
    end
end

function ZhenPaiSkill.InitKungFu(hFrame)
    local tKungFu = GetForceKungFuData(ZhenPaiSkill.dwForceID)
    
    local hHandle1 = hFrame:Lookup("", "Handle_All1")
    local hHandle2 = hFrame:Lookup("", "Handle_All2")
    local hBoxKF1 = hHandle1:Lookup("Box_AllBg1")
    local hBoxKF2 = hHandle2:Lookup("Box_AllBg2")
    
    ZhenPaiSkill.tTalentName = {}
    
    local tLeft = tKungFu[SERIES_TYPE.LEFT]
    hBoxKF1:SetObject(UI_OBJECT_NOT_NEED_KNOWN)
	hBoxKF1:SetObjectIcon(tLeft.nIconID)
    hHandle1:Lookup("Text_SkillName1"):SetText(tLeft.szTalentName)
    ZhenPaiSkill.tTalentName[SERIES_TYPE.LEFT] = tLeft.szTalentName
    
    local hImage = hFrame:Lookup("", "Image_Talent1")
    hImage:FromTextureFile(tLeft.szImage)
    hImage:AutoSize()
    
    local tRight = tKungFu[SERIES_TYPE.RIGHT]
    hBoxKF2:SetObject(UI_OBJECT_NOT_NEED_KNOWN)
	hBoxKF2:SetObjectIcon(tRight.nIconID)
    hHandle2:Lookup("Text_SkillName2"):SetText(tRight.szTalentName)
    ZhenPaiSkill.tTalentName[SERIES_TYPE.RIGHT] = tRight.szTalentName
    
    local hImage = hFrame:Lookup("", "Image_Talent2")
    hImage:FromTextureFile(tRight.szImage)
    hImage:AutoSize()
    hFrame:Lookup("Btn_Default"):Enable(l_bClientPlayer);
end

function ZhenPaiSkill.OnFrameCreate()
    this:RegisterEvent("SKILL_UPDATE")
    this:RegisterEvent("PLAYER_LEVEL_UPDATE")
    this:RegisterEvent("ON_GET_SKILL_LEVEL_RESULT")
    
    ZhenPaiSkill.Init(this)
    InitFrameAutoPosInfo(this, 1, nil, nil, function() CloseZhenPaiSkill(true) end)
end

function ZhenPaiSkill.OnEvent(szEvent)
    if szEvent == "SKILL_UPDATE" then
         if TALENT_LEARNING or (not l_bClientPlayer) then
            return
        end
        
        local hBtn = this:Lookup("Btn_Learn")
        if not hBtn:IsEnabled() then
            ZhenPaiSkill.UpdateTalent(tTalentTab)
        end
    elseif szEvent == "PLAYER_LEVEL_UPDATE" then
        if not l_bClientPlayer then
            return 
        end
        
        local player =  GetClientPlayer()
        local nOldTotal = nTotalTalentPoint
        nTotalTalentPoint = GetMaxTalentPoint(player.nLevel)
        
        nOwnTalentPoint = nOwnTalentPoint + (nTotalTalentPoint - nOldTotal)
        nOwnTalentPointView = nOwnTalentPointView + (nTotalTalentPoint - nOldTotal)
        
        OwnTalentPointChange();
        ZhenPaiSkill.UpdateBoxClickState()
    elseif szEvent == "ON_GET_SKILL_LEVEL_RESULT" then
       if arg0 == ZhenPaiSkill.dwPlayerID and not l_bClientPlayer and IsZhenPaiSkillOpened() then
			ZhenPaiSkill.aSkill = ZhenPaiSkill.aSkill or {}
			local t = arg1 or {}
			for k, v in pairs(t) do
				ZhenPaiSkill.aSkill[k] = v
			end
            ZhenPaiSkill.UpdateTalent(tTalentTab)
		end
    end
end

local function UpdateArrowImage(hWnd, tData, nCurrentRow, tRelation, nSeriesID)
    local szKey = SERIES_TYPE_STRING[nSeriesID]
    local _,_, szImage = GetTalentWidgetName(nSeriesID)
    
    local tMap = {}
    for _, tSkill in pairs(tRelation.PreviousTab) do
        tMap[tSkill[1]] = true
    end
    
    local tSkill = tData[nSeriesID]
    local hList = hWnd:Lookup("", "")
    for i = 1, nCurrentRow - 1, 1 do 
        for j = 1, COLUMN_COUNT, 1 do
            local nIndex = (i - 1) * COLUMN_COUNT + j
            if tSkill and tSkill[i] and tSkill[i][j] and tSkill[i][j] > 0 then
                local dwSkillID = tSkill[i][j]
            
                if tMap[dwSkillID] then
                    local hHandle = hList:Lookup(nIndex - 1)
                    local hImage = hHandle:Lookup(szImage)
                    hImage:Show()
                    break;
                end
            end
        end
    end
end

local function InitSkillData(tData, nSeriesID)
    if not tData[nSeriesID] then
        tData[nSeriesID] = {}
    end
    
    for i=1, ROW_COUNT, 1 do
        if not tData[nSeriesID][i] then
            tData[nSeriesID][i] = {}
        end
        for j=1, COLUMN_COUNT, 1 do
            tData[nSeriesID][i][j] = 0
        end
    end
end

local function UpdateOneTalent(hWnd, tData, nSeriesID)
    local szBox, szText, szImage, szImageBg = GetTalentWidgetName(nSeriesID)
    
    InitSkillData(tTalentTabView, nSeriesID)
    InitSkillData(tTalentSkillID, nSeriesID)
    
    local tSkill = tData[nSeriesID]
    local tView = tTalentTabView[nSeriesID]
    local tSkillID = tTalentSkillID[nSeriesID]
    
    local hList = hWnd:Lookup("", "")
    for i=1, ROW_COUNT, 1 do
        for j=1, COLUMN_COUNT, 1 do
            local nIndex = (i - 1) * COLUMN_COUNT + j
            local hHandle = hList:Lookup(nIndex - 1)
            local hBox = hHandle:Lookup(szBox)
            local hText = hHandle:Lookup(szText)
            local hImageBg = hHandle:Lookup(szImageBg)

            hHandle:Lookup(szImage):Hide()
            hImageBg:Hide()
            hText:SetText("")
            hBox:ClearObject()
            
            if tSkill and tSkill[i] and tSkill[i][j] and tSkill[i][j] > 0 then
                local dwSkillID = tSkill[i][j]
                local nLevel = GetSkillLevel(dwSkillID) or 0
                
                hImageBg:Show()
                
                hBox.bTalentBox = true
                hBox.dwSkillID = dwSkillID
                hBox.nRow = i
                hBox.nColumn = j
                hBox.nSeriesID = nSeriesID
                
                tView[i][j] = nLevel
                tSkillID[i][j] = dwSkillID
                nUsedTalentPoint[nSeriesID] = nUsedTalentPoint[nSeriesID] + nLevel
                
                hBox:SetObject(UI_OBJECT_SKILL, dwSkillID, nLevel)
                hBox:SetObjectIcon(Table_GetSkillIconID(dwSkillID, 1))   
                hText:SetText(nLevel)
                SetPointTextColor(nSeriesID, i, j)
                
                local dwSubSkillID = GetTalentSubSkill(ZhenPaiSkill.dwForceID, nSeriesID,  dwSkillID)
                if dwSubSkillID then
                    local hImageArrow = hHandle:Lookup(szImage)
                    hImageArrow:Show()
                end
            end
        end
    end
end

function ZhenPaiSkill.UpdateTalent(tData)
    local hLeftWnd = WIDGET.hLeftWnd
    local hRightWnd = WIDGET.hRightWnd
    
    nUsedTalentPoint[SERIES_TYPE.LEFT] = 0
    nUsedTalentPoint[SERIES_TYPE.RIGHT] = 0
    
    UpdateOneTalent(hLeftWnd, tData, SERIES_TYPE.LEFT)
    UpdateOneTalent(hRightWnd, tData, SERIES_TYPE.RIGHT)
    nOwnTalentPoint = nTotalTalentPoint - nUsedTalentPoint[SERIES_TYPE.LEFT] - nUsedTalentPoint[SERIES_TYPE.RIGHT]
    
    nOwnTalentPointView = nOwnTalentPoint 
    
    OwnTalentPointChange();
    ZhenPaiSkill.UpdateBoxClickState()
end


function ZhenPaiSkill.UpdateBoxClickState()
    local function UpdateWnd(hWnd, nSeriesID)
        local szBox, szText, szImage, szImageBg, szImageC = GetTalentWidgetName(nSeriesID)
        local hList = hWnd:Lookup("", "")
        for i=1, ROW_COUNT , 1 do 
            for j = 1, COLUMN_COUNT, 1 do
                local nIndex = (i - 1) * COLUMN_COUNT + j
                local hHandle = hList:Lookup(nIndex - 1)
                local hBox = hHandle:Lookup(szBox)
                if hBox.bTalentBox then
                    local bLight = false
                    if l_bClientPlayer then
                        local nRetCode = CanAddTalent(tTalentTabView, ZhenPaiSkill.dwForceID, nSeriesID,  i, j)
                        bLight = (nRetCode == ERR_TALENT_SUCCESS)
                    end
                    if tTalentTabView[nSeriesID][i][j] > 0 or bLight then
                        hBox:EnableObject(true)
                        hHandle:Lookup(szImageC):Show()
                        hHandle:Lookup(szText):SetText(tTalentTabView[nSeriesID][i][j])
                    else
                        hBox:EnableObject(false)
                        hHandle:Lookup(szImageC):Hide()
                        hHandle:Lookup(szText):SetText("")
                    end
                end
            end
        end
    end
    
    local hLeftWnd = WIDGET.hLeftWnd
    local hRightWnd = WIDGET.hRightWnd
    
    UpdateWnd(hLeftWnd, SERIES_TYPE.LEFT)
    UpdateWnd(hRightWnd, SERIES_TYPE.RIGHT)
end

function ZhenPaiSkill.LearnTalent()
    local player = GetClientPlayer()
    local nSize = #tOperateList
    if TALENT_INDEX > nSize then
        return "Finish"
    end
    
    local tInfo = tOperateList[TALENT_INDEX]
    local nSeriesID, nRow, nColumn = tInfo[1], tInfo[2], tInfo[3]
    local dwSkillID = tTalentSkillID[nSeriesID][nRow][nColumn]
    local nLevel = player.GetSkillLevel(dwSkillID) or 0
    local nPoint = GetTalentPoint(nSeriesID, nRow, nColumn)
    if nPoint > nLevel then
        TALENT_LEARN_SKILL = dwSkillID
        player.OpenTalent(dwSkillID, nPoint)
        return "Success"
    else
        TALENT_INDEX = TALENT_INDEX + 1
        local szResult = ZhenPaiSkill.LearnTalent()
        if szResult == "Finish" then
            return "Finish"
        end
    end
end

function GetTalentTip(dwSkillID, nSeriesID, nRow, nColumn)
    local szTip = ""
    local szName = ""
    local player = GetClientPlayer()
	local dwLevel = 0
    local skill = nil
    
    if l_bClientPlayer then
        dwLevel = GetSkillViewLevel(dwSkillID)
    else
        dwLevel = ZhenPaiSkill.aSkill[dwSkillID]
    end

    if dwLevel == 0 then
        szName = Table_GetSkillName(dwSkillID, 1)
        skill = GetSkill(dwSkillID, 1)
    else
        szName = Table_GetSkillName(dwSkillID, dwLevel)
        skill = GetSkill(dwSkillID, dwLevel)
    end
    if not skill then
        return ""
    end
    szTip = szTip..GetFormatText(szName, 31)
    szTip = szTip..GetFormatText(FormatString(g_tStrings.STR_SKILL_H_THE_WHAT_LEVEL, dwLevel.."/"..skill.dwMaxLevel), 61)
    
    local GetSkillDesc=function(nSkillID, nLevel, bNext)
        local szResult = ""
        local skillkey = player.GetSkillRecipeKey(nSkillID, nLevel)
        local skillInfo = GetSkillInfo(skillkey)
        local szDesc = GetSkillDesc(nSkillID, nLevel, skillkey, skillInfo)
        if szDesc ~= "" then
            if not bNext then
              --szResult = szResult..GetFormatText(g_tStrings.CURRENT_LEVEL, 106)
            else
                szResult = szResult..GetFormatText("\n" .. g_tStrings.STR_NEXT_LEVEL, 106)
            end
            szResult = szResult..GetFormatText(szDesc.."\n", 100)
        end 
        return szResult
    end
    local GetDelOnePointTip=function(nSkillID, nLevel)
        local dwHaveLevel =  player.GetSkillLevel(nSkillID)
        local szResult = ""
        if l_bClientPlayer and dwHaveLevel~=  nLevel then
            szResult = szResult..GetFormatText(g_tStrings.STR_TALENT_DEL_TIP, 102)
        end
        return szResult
    end
    
    if dwLevel == 0 then
        local tCondition = GetTalentCondition(ZhenPaiSkill.dwForceID, dwSkillID)
        for _, tInfo in ipairs(tCondition.PreviousTab) do
            local dwPrevSkillID = tInfo[1]
            local dwPrevLevel = tInfo[2]
            local dwViewLevel = GetSkillViewLevel(dwPrevSkillID)
            local szPrevName = Table_GetSkillName(dwPrevSkillID, 1)
            
            if dwViewLevel < dwPrevLevel then
                szTip = szTip..GetFormatText(FormatString(g_tStrings.STR_NEED_TALENT_POINT, dwPrevLevel).." " .. szPrevName .. "\n", 102)
            end

        end
                    
        if tCondition.nAllPoint > 0 then
            local tInfo = StatisticsTalentSubsectionInfo(tTalentTabView)
            if tInfo[nSeriesID][nRow] < tCondition.nAllPoint then
                local szTalentName = ZhenPaiSkill.tTalentName[nSeriesID]
                szTip = szTip..GetFormatText(FormatString(g_tStrings.STR_NEED_TALENT_POINT, tCondition.nAllPoint).." "..szTalentName.."\n", 102)
            end
        end
        szTip = szTip .. GetSkillDesc(dwSkillID, dwLevel + 1);
        szTip = szTip .. GetDelOnePointTip(dwSkillID, dwLevel)
        
    elseif dwLevel == skill.dwMaxLevel then
        szTip = szTip .. GetSkillDesc(dwSkillID, dwLevel);
        szTip = szTip..GetFormatText(g_tStrings.STR_SKILL_H_TOP_LEAVEL, 106)
        szTip = szTip..GetDelOnePointTip(dwSkillID, dwLevel)
    else
        szTip = szTip .. GetSkillDesc(dwSkillID, dwLevel);
        szTip = szTip .. GetSkillDesc(dwSkillID, dwLevel + 1, true);
        szTip = szTip .. GetDelOnePointTip(dwSkillID, dwLevel)
    end
    
    if IsCtrlKeyDown() then
        szTip = szTip..GetFormatText("\nµ÷ÊÔÐÅÏ¢£º\n", 102);
        szTip = szTip..GetFormatText("ID:"..dwSkillID.." Level:"..dwLevel, 102);
    end
    return szTip
end

function ZhenPaiSkill.ConfirmLearnSkill()
    TALENT_INDEX = 1
    TALENT_LEARNING = true
    
    local hFrame = WIDGET.hFrame
    hFrame:Lookup("Btn_Learn"):Enable(false)
    local szResult = ZhenPaiSkill.LearnTalent()
    if szResult == "Finish" then
        hFrame:Lookup("Btn_Learn"):Enable(true)
        tOperateList = {}
    end
end

--===========================================
function ZhenPaiSkill.OnLButtonClick()
    local szName = this:GetName()
    if szName == "Btn_Learn" then
        if TALENT_LEARNING or (not l_bClientPlayer) then
            return
        end
        local msg = 
		{
			szMessage = g_tStrings.STR_TALENT_CONFIRM_TIP,
			szName = "TalentLearnConfirm", 
			fnAutoClose = function() if not IsZhenPaiSkillOpened() then return true end end,
			{szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = function() ZhenPaiSkill.ConfirmLearnSkill() end},
			{szOption = g_tStrings.STR_HOTKEY_CANCEL}
		}
		MessageBox(msg)
        
    elseif szName == "Btn_Default" then
        if TALENT_LEARNING or (not l_bClientPlayer) then
            return
        end
        tOperateList = {}
        ZhenPaiSkill.UpdateTalent(tTalentTab)
    elseif szName == "Btn_Close" then
        CloseZhenPaiSkill();
    end
end

function ZhenPaiSkill.OnItemLButtonClick()
    local szName = this:GetName()
    if this.bTalentBox and l_bClientPlayer then
        if TALENT_LEARNING then
            return
        end
        
        if IsCtrlKeyDown() then
            local dwID = this.dwSkillID
		 	local player = GetClientPlayer()
		 	local dwLevel = 0 
            if l_bClientPlayer then
                dwLevel = GetSkillViewLevel(dwID)
            else
                dwLevel = ZhenPaiSkill.aSkill[dwID]
            end
            
		 	if dwLevel == 0 then
		 		dwLevel = 1
		 	end
			if IsGMPanelReceiveSkill() then
				GMPanel_LinkSkill(dwID, dwLevel)
			else
				EditBox_AppendLinkSkill(player.GetSkillRecipeKey(dwID, dwLevel))
			end
            return
        end
        
        local nRetCode = CanAddTalent(tTalentTabView, ZhenPaiSkill.dwForceID, this.nSeriesID,  this.nRow, this.nColumn) 
        if nRetCode == ERR_TALENT_SUCCESS then
            local nLevel = GetTalentPoint(this.nSeriesID, this.nRow, this.nColumn) + 1
            local hItem = this:GetParent()
            local _, szText = GetTalentWidgetName(this.nSeriesID)
            hItem:Lookup(szText):SetText(nLevel)
            
            DoAddOperate(this.nSeriesID, this.nRow, this.nColumn)
            ZhenPaiSkill.OnItemMouseEnter();
        end
    end
end

function ZhenPaiSkill.OnItemRButtonClick()
    local szName = this:GetName()
    if this.bTalentBox and l_bClientPlayer and IsSkillCanDelOne(this) then
        if TALENT_LEARNING then
            return
        end
        
        local nRetCode = CanDelTalent(tTalentTabView, ZhenPaiSkill.dwForceID, this.nSeriesID,  this.nRow, this.nColumn) 
        if nRetCode == ERR_TALENT_SUCCESS then
            local nLevel = GetTalentPoint(this.nSeriesID, this.nRow, this.nColumn) - 1
            local hItem = this:GetParent()
            local _, szText = GetTalentWidgetName(this.nSeriesID)
            hItem:Lookup(szText):SetText(nLevel)

            DoDelOperate(this.nSeriesID, this.nRow, this.nColumn)
            ZhenPaiSkill.OnItemMouseEnter();
        end
    end
end

function ZhenPaiSkill.OnItemMouseEnter()
    local szName = this:GetName()
    if this.bTalentBox then
        local x, y = this:GetAbsPos()
        local w, h = this:GetSize()
        
        local dwSkillID = this.dwSkillID
        local skill = GetSkill(dwSkillID, 1)
        if skill.bIsPassiveSkill then
            local szTip = GetTalentTip(dwSkillID, this.nSeriesID,  this.nRow, this.nColumn)
            OutputTip(szTip, 300, {x, y, w, h})
        else
            local dwLevel, dwLevel1 = 1, 0
            if l_bClientPlayer then
                dwLevel = GetSkillViewLevel(dwSkillID)
            else
                dwLevel = ZhenPaiSkill.aSkill[dwSkillID]
            end
            dwLevel1 = dwLevel
            if dwLevel == 0 then
                dwLevel = 1
            end
            OutputSkillTip(dwSkillID, dwLevel, {x, y, w, h}, true, true, true, true, dwLevel1)
        end
    end
end

function ZhenPaiSkill.OnItemMouseLeave()
    local szName = this:GetName()
    if this.bTalentBox then
        HideTip()
    end
end

--==============================================

function IsZhenPaiSkillOpened()
    local hFrame = Station.Lookup("Normal/ZhenPaiSkill")
    if hFrame and hFrame:IsVisible() then
        return true
    end
    return false
end

function OpenZhenPaiSkill(bDisableSound)
    if IsZhenPaiSkillOpened() then
        return
    end
    
    local player = GetClientPlayer()
    if player.dwForceID == IDENTITY.JIANG_HU then
        OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_TALENT_NOT_OPEN_TIP)
        return
    end
    
    ZhenPaiSkill.dwPlayerID = player.dwID
    ZhenPaiSkill.dwForceID = player.dwForceID
    l_bClientPlayer = true

    local hFrame = Wnd.OpenWindow("ZhenPaiSkill")
    ZhenPaiSkill.Init(hFrame)
    
    if not bDisableSound then
        PlaySound(SOUND.UI_SOUND, g_sound.OpenFrame)
    end
end

function ViewOtherZhenPaiSkill(dwPlayerID, bDisableSound) 
    local player = GetPlayer(dwPlayerID)
    if not player then
        return
    end
    
    if player.dwForceID == IDENTITY.JIANG_HU then
        OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_TALENT_NOT_OPEN_TIP1)
        return
    end
    
    ZhenPaiSkill.dwForceID = player.dwForceID
    l_bClientPlayer = false
    ZhenPaiSkill.dwPlayerID = dwPlayerID
    ZhenPaiSkill.aSkill = {}
    ZhenPaiSkill.szPlayerName = player.szName
    
    local hFrame = Wnd.OpenWindow("ZhenPaiSkill")
    ZhenPaiSkill.Init(hFrame)
    
    if not bDisableSound then
        PlaySound(SOUND.UI_SOUND, g_sound.OpenFrame)
    end
end

function CloseZhenPaiSkill(bDisableSound)
    if not IsZhenPaiSkillOpened() then
        return
    end
    
    Wnd.CloseWindow("ZhenPaiSkill")
    if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end
end

local function OnLearnTalentRespond()
    local nRetCode = arg0
    local nSkillID = arg1
    if nRetCode == ERR_TALENT_SUCCESS and TALENT_LEARN_SKILL == nSkillID then
        TALENT_INDEX = TALENT_INDEX + 1
        local szResult = ZhenPaiSkill.LearnTalent()
        if szResult == "Finish" then
            OutputMessage("MSG_ANNOUNCE_YELLOW", g_tStrings.STR_TALENT_LEARN_SUCCESS)
            TALENT_LEARNING = false;
            TALENT_INDEX = -1
            TALENT_LEARN_SKILL = -1
            tOperateList = {}
            if IsZhenPaiSkillOpened() then
                WIDGET.hFrame:Lookup("Btn_Learn"):Enable(true)
                ZhenPaiSkill.UpdateTalent(tTalentTab)
            end
        end
    else
        OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_TALENT_LEARN_FAIL)
        TALENT_LEARNING = false;
        TALENT_INDEX = -1;
        TALENT_LEARN_SKILL = -1
        if IsZhenPaiSkillOpened() then
            ZhenPaiSkill.UpdateTalent(tTalentTab)
        end
    end
end

RegisterEvent("ON_OPEN_TALENT_RETCODE", OnLearnTalentRespond)