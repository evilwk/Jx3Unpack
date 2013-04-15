local GROUP_NAME = 
{
    [1] = "PVE",
    [2] = "PVP",
    [3] = g_tStrings.STR_CURRENT_TYPE_FREE,
}
local CURRENCY_TYPE = 
{
    ["ITEM"] = 1,
    ["BANG_GONG"] = 2,
    ["XIA_YI"] = 3,
    ["WEI_WANG"] = 4,
    ["ZHANJIE_JIFEN"] = 5,
    ["JIANYIN_WENBEN"] = 6,
	["ARENA_AWARD"] = 7,
}   

local INI_FILE_PATH = "UI/Config/Default/Currency.ini"

Currency = 
{
    nMaxCheckCount = 3,
    tCheck= {},
}

local tGroupCollapse = {}
local hCurrentFrame= nil

RegisterCustomData("Currency.tCheck")

function Currency.OnFrameCreate()
	this:RegisterEvent("MONEY_UPDATE")
	this:RegisterEvent("SYNC_COIN")
    this:RegisterEvent("BAG_ITEM_UPDATE")
    this:RegisterEvent("CONTRIBUTION_UPDATE")
    this:RegisterEvent("UPDATE_JUSTICE")
    this:RegisterEvent("UPDATE_EXAMPRINT")
    this:RegisterEvent("UPDATE_PRESTIGE")
	this:RegisterEvent("UPDATE_ARENAAWARD")
    this:RegisterEvent("TITLE_POINT_UPDATE")
    
    
    Currency.UpdateCurrencyList(this)
    Currency.UpdateMoney(this)
    InitFrameAutoPosInfo(this, 1, nil, nil, function() CloseCurrencyPanel(true) end)
end

function Currency.OnEvent(szEvent)
    if szEvent == "MONEY_UPDATE" then
        Currency.UpdateMoney(this)
    elseif szEvent == "SYNC_COIN" then
        Currency.UpdateMoney(this)
        
    elseif szEvent == "SYNC_ROLE_DATA_END" then
        local tCurrencyData = Table_GetCurrencyList()
        local tCheck = clone(Currency.tCheck)
        Currency.tCheck = {}
        for _, szName in ipairs(tCheck) do
            for k, v in pairs(tCurrencyData) do
                if v.szName == szName then
                    Currency.CheckCurrency(szName)
                    break;
                end
            end
        end
    elseif szEvent == "BAG_ITEM_UPDATE" or 
           szEvent == "CONTRIBUTION_UPDATE" or 
           szEvent == "UPDATE_PRESTIGE" or 
           szEvent == "UPDATE_JUSTICE" or
           szEvent == "TITLE_POINT_UPDATE" or
           szEvent == "UPDATE_EXAMPRINT" or
		   szEvent == "UPDATE_ARENAAWARD" then
           
        Currency.UpdateCurrencyList(this)
    end
end

local function IsCheckCurrency(szName)
    for k, v in pairs(Currency.tCheck) do
        if v == szName then
            return true;
        end
    end
    return false;
end

local function UpdateCheck()
    if not hCurrentFrame then
        return
    end
    
    local hList = hCurrentFrame:Lookup("", "Handle_Money")
    local nGroupCount = hList:GetItemCount()
    for i = 0, nGroupCount - 1, 1 do
        local hGroup = hList:Lookup(i)
        local nCount = hGroup:GetItemCount()
        for j = 1, nCount - 1, 1 do 
            local hOption = hGroup:Lookup(j)
            local hFilter = hOption:Lookup("Handle_Filter")
            local hCheckImg = hFilter:Lookup("Image_CheckNormal")
            if IsCheckCurrency(hOption.szName) then
                hCheckImg:Show()
            else
                hCheckImg:Hide()
            end
        end
    end
end

function Currency.CheckCurrency(szName, bOff)
    local tCheck = Currency.tCheck
    if bOff then
        for k, v in pairs(tCheck) do
            if v == szName then
                table.remove(tCheck, k)
                break
            end
        end
    else
        table.insert(tCheck, szName)
        local nSize = #tCheck
        if nSize > Currency.nMaxCheckCount then
            table.remove(tCheck, 1)
            UpdateCheck()
        end
    end
    FireEvent("CURRENCY_CHECK_NOTIFY")
end

function Currency.GetCurrencyNumber(tInfo)
    local player = GetClientPlayer()

    if tInfo.dwType == CURRENCY_TYPE["ITEM"] then
        local nCount = player.GetItemAmountInAllPackages(tInfo.dwTabIndex, tInfo.nItemID)
        local itemInfo = GetItemInfo(tInfo.dwTabIndex, tInfo.nItemID)
        return nCount, itemInfo.nMaxExistAmount
    elseif tInfo.dwType == CURRENCY_TYPE["BANG_GONG"] then
        local levelUp = GetLevelUpData(player.nRoleType, player.nLevel)
        local nMaxContribution = levelUp['MaxContribution'] or 0
        local nLimit = player.GetContributionRemainSpace()
        return player.nContribution, nMaxContribution, nLimit
    elseif tInfo.dwType == CURRENCY_TYPE["XIA_YI"] then
        local nMaxCount = player.GetMaxJustice()
        local nLimit = player.GetJusticeRemainSpace()
        return player.nJustice, nMaxCount, nLimit
        
    elseif tInfo.dwType == CURRENCY_TYPE["WEI_WANG"] then
        local nLimit = player.GetPrestigeRemainSpace()
        return player.nCurrentPrestige, player.GetMaxPrestige(), nLimit
        
    elseif tInfo.dwType == CURRENCY_TYPE["ZHANJIE_JIFEN"] then
        return player.nTitlePoint , player.GetRankPointPercentage()
        
    elseif tInfo.dwType == CURRENCY_TYPE["JIANYIN_WENBEN"] then
        local nMaxCount = player.GetMaxExamPrint()
        local nLimit  = player.GetExamPrintRemainSpace()
        
        return player.nExamPrint, nMaxCount, nLimit 
    elseif tInfo.dwType == CURRENCY_TYPE["ARENA_AWARD"] then
        local nMaxCount = player.GetMaxArenaAward()
        local nLimit  = player.GetArenaAwardRemainSpace()
        
        return player.nArenaAward, nMaxCount, nil
    end
    return 0
end

function Currency.UpdateMoney(hFrame)
	local player = GetClientPlayer()
    local nMoney = player.GetMoney()
    
    local nGold, nSilver, nCopper = MoneyToGoldSilverAndCopper(nMoney)
    local hTextG = hFrame:Lookup("", "Text_ROwnGold")
    local hTextS = hFrame:Lookup("", "Text_ROwnSliver")
    local hTextC = hFrame:Lookup("", "Text_ROwnCopper")
    local hTextCoin = hFrame:Lookup("", "Text_Coin")
    
    hTextG:SetText(nGold)
    hTextS:SetText(nSilver)
    hTextC:SetText(nCopper)
    hTextCoin:SetText(player.nCoin)
end

function Currency.UpdateCurrencyList(hFrame)
    local hList = hFrame:Lookup("", "Handle_Money")
    local tCurrencyData = Table_GetCurrencyList()
    local tGroup = {}
    for k, v in pairs(tCurrencyData) do
        if not tGroup[v.dwGroupID] then
            tGroup[v.dwGroupID] = {}
        end
        table.insert(tGroup[v.dwGroupID], v)
    end
    hList:Clear();
    for dwGroupID, tData in pairs(tGroup) do
        local hGroup = hList:AppendItemFromIni(INI_FILE_PATH, "Handle_Group")
        hGroup:Clear()
        hGroup.dwGroupID = dwGroupID
        
        local hTitle = hGroup:AppendItemFromIni(INI_FILE_PATH, "Handle_Title")
        local hGroupImg = hTitle:Lookup("Image_GroupBg")
        local hExpandImg = hTitle:Lookup("Image_Expand")
        hTitle:Lookup("Text_TitleDesc"):SetText(GROUP_NAME[dwGroupID])
        for k, tInfo in pairs(tData) do
            local nCount, nMaxCount, nLimit = Currency.GetCurrencyNumber(tInfo)
            local hOption = hGroup:AppendItemFromIni(INI_FILE_PATH, "Handle_Option")
            local hFilter = hOption:Lookup("Handle_Filter")
            local hCheckImg = hFilter:Lookup("Image_CheckNormal")
            local hImagePercentage  = hOption:Lookup("Image_PVEFull")
            local hImageLimit = hOption:Lookup("Image_PVELimit")
            local hTextName = hOption:Lookup("Text_Name")
            local hImageLogo = hOption:Lookup("Image_Logo")
            
            hTextName:SetText(tInfo.szName)
            hImageLogo:SetFrame(tInfo.nFrame)
            if tInfo.dwType == CURRENCY_TYPE["ZHANJIE_JIFEN"] then
                hImagePercentage:SetPercentage(nMaxCount / 100)
                
            elseif nCount == 0 and nMaxCount == nil then
                hImagePercentage:SetPercentage(0)
            else
				local fPer = 0
                if nMaxCount ~= 0 then
                	fPer = nCount / nMaxCount
                end
                hImagePercentage:SetPercentage(fPer)
            end
            
            if nLimit == nil then
                hImageLimit:Hide()
            else
                local x, y = hImagePercentage:GetRelPos()
                local ax, ay = hImagePercentage:GetAbsPos()
                local w, h = hImagePercentage:GetSize()
            
                local wImg, hImg = hImageLimit:GetSize()
                local nTotal = nCount + nLimit
                nTotal = math.min(nTotal, nMaxCount);
                local fPer = 0
                if nMaxCount ~= 0 then
                	fPer = nTotal / nMaxCount
                end
                hImageLimit:SetRelPos(x + w * fPer - wImg / 2, y)
                hImageLimit:SetAbsPos(ax + w * fPer - wImg / 2, ay)
            end
            
            hOption.nCount = nCount
            hOption.nMaxCount = nMaxCount
            hOption.nLimit = nLimit
            
            hOption.dwType = tInfo.dwType
            hOption.dwTabIndex = tInfo.dwTabIndex
            hOption.nItemID = tInfo.nItemID
            
            hOption.szDesc1 = tInfo.szDesc1
            hOption.szDesc2 = tInfo.szDesc2
            hOption.szName = tInfo.szName
            if IsCheckCurrency(tInfo.szName) then
                hCheckImg:Show()
            else
                hCheckImg:Hide()
            end
            if tGroupCollapse[dwGroupID] then
                hOption:Hide()
            end
        end
        
        hGroup:FormatAllItemPos() 
        if not tGroupCollapse[dwGroupID] then
            local nAllW, nAllH = hGroup:GetAllItemSize()
            local nW, nH = hGroup:GetSize()
            if nAllH > nH then
                hGroupImg:SetSize(nW, nAllH + 20)
                hGroup:SetSize(nW, nAllH + 20)          
            end
            hExpandImg:SetFrame(13)
        else
            local nW, nH = hTitle:GetSize()
            hGroup:SetSize(nW, nH)
            hGroupImg:Hide()
            hExpandImg:SetFrame(9)
        end
    end
    Currency.UpdateScrollInfo(hList, true)
    FireEvent("CURRENCY_CHECK_NOTIFY")
end

function Currency.UpdateScrollInfo(hList, bHome)
    hList:FormatAllItemPos()
    local hFrame = hList:GetRoot()
    local scroll = hFrame:Lookup("Scroll_List")
    local wAll, hAll = hList:GetAllItemSize()
    local w, h = hList:GetSize()
    local nCountStep = math.ceil((hAll - h) / 10)

    scroll:SetStepCount(nCountStep)
    if nCountStep > 0 then
        scroll:Show()
        hFrame:Lookup("Btn_Up"):Show()
        hFrame:Lookup("Btn_Down"):Show()
    else
        scroll:Hide()
        hFrame:Lookup("Btn_Up"):Hide()
        hFrame:Lookup("Btn_Down"):Hide()
    end
    if bHome then
        scroll:ScrollHome()
    end
end

function Currency.OnScrollBarPosChanged()
    local hFrame = this:GetRoot()
    local nCurrentValue = this:GetScrollPos()
	local szName = this:GetName()
    if szName == "Scroll_List" then
        if nCurrentValue == 0 then
            hFrame:Lookup("Btn_Up"):Enable(false)
        else
            hFrame:Lookup("Btn_Up"):Enable(true)
        end
        if nCurrentValue == this:GetStepCount() then
            hFrame:Lookup("Btn_Down"):Enable(false)
        else
            hFrame:Lookup("Btn_Down"):Enable(true)
        end
        hFrame:Lookup("", "Handle_Money"):SetItemStartRelPos(0, - nCurrentValue * 10)
    end
end

local function UpdateOptionBG(handle)
    if not handle then
        return 
    end
    
    local hImgSel = handle:Lookup("Image_Sel")
    if handle.bSel then
        hImgSel:SetAlpha(255)
        hImgSel:Show()
    elseif handle.bOver then
        hImgSel:SetAlpha(128)
        hImgSel:Show()
    else
        hImgSel:Hide()
    end
end

local function UpdateFilterBG(handle)
    if not handle then
        return 
    end
    
    local hImgNor = handle:Lookup("Image_Nomal")
    local hImgCheck = handle:Lookup("Image_CheckNormal")
    if handle.bOver then
        hImgNor:SetFrame(3)
        hImgCheck:SetFrame(7)
    else
        hImgNor:SetFrame(5)
        hImgCheck:SetFrame(6)
    end
end

function Currency.OnItemMouseEnter()
    local szName = this:GetName()
    if szName == "Handle_Filter" then
        this.bOver = true
        UpdateFilterBG(this)
    elseif szName == "Handle_Option" then
        this.bOver = true
        UpdateOptionBG(this)
        
    elseif szName == "Image_Logo" then
        local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
        local r, g, b = 255, 255, 255
        local hOption = this:GetParent()
        if hOption.dwType == CURRENCY_TYPE["ITEM"] then
            local itemInfo = GetItemInfo(hOption.dwTabIndex, hOption.nItemID)
            r, g, b  = GetItemFontColorByQuality(itemInfo.nQuality)
        end
        
        local szTip = ""
        szTip = szTip .. GetFormatText(hOption.szName.."\n", 60, r, g, b)
        if hOption.szDesc1 and hOption.szDesc1 ~= "" then 
            szTip  = szTip .. GetFormatText(hOption.szDesc1.."\n", 18)
        end
        
        if hOption.szDesc2 and hOption.szDesc2 ~= "" then
            szTip  = szTip .. GetFormatText(hOption.szDesc2.."\n", 163)
        end
        
        OutputTip(szTip, 600, {x, y, w, h})	
    elseif szName == "Image_PVELimit" then
        local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
        
        local hItem = this:GetParent();
        local szName = hItem:Lookup("Text_Name"):GetText()
        local szTip = ""
        szTip = szTip .. GetFormatText(g_tStrings.STR_CURRENCY_REMAIN_GET.. hItem.nLimit)
        OutputTip(szTip, 400, {x, y, w, h})	
        
    elseif szName == "Image_PVEEmpty" then
        local hItem = this:GetParent();

        local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
        local szName = hItem:Lookup("Text_Name"):GetText()
        local szTip = "" 
        if hItem.dwType == CURRENCY_TYPE["ZHANJIE_JIFEN"] then
            szTip = GetFormatText(szName..g_tStrings.STR_COLON..hItem.nCount)
            szTip = szTip..GetFormatText(g_tStrings.STR_COMMA ..GetString("STR_CAMP_RANKLINE")..hItem.nMaxCount .. "%")
        else
            szTip = GetFormatText(szName..g_tStrings.STR_COLON..hItem.nCount.."/"..hItem.nMaxCount)
        end
        
        if hItem.nLimit then
            szTip = szTip .. GetFormatText(g_tStrings.STR_COMMA..g_tStrings.STR_CURRENCY_REMAIN_GET .. hItem.nLimit)
        end
        OutputTip(szTip, 400, {x, y, w, h})
    end
end

function Currency.OnItemMouseLeave()
    local szName = this:GetName()
    if szName == "Handle_Filter" then
        this.bOver = false
        UpdateFilterBG(this)
    elseif szName == "Handle_Option" then
        this.bOver = false
        UpdateOptionBG(this)
    elseif szName == "Image_Logo" or szName == "Image_PVELimit" or szName == "Image_PVEEmpty"  then
        HideTip()
    end
end

function Currency.OnItemLButtonClick()
    local szName = this:GetName()
    if szName == "Handle_Title" then
        local hGroup = this:GetParent()
        tGroupCollapse[hGroup.dwGroupID] = not tGroupCollapse[hGroup.dwGroupID]
        Currency.UpdateCurrencyList(this:GetRoot())
        
    elseif szName == "Handle_Option" then
       local hFliter = this:Lookup("Handle_Filter")
       local hCheckImg = hFliter:Lookup("Image_CheckNormal")
       if hCheckImg:IsVisible() then
            hCheckImg:Hide()
            Currency.CheckCurrency(this.szName, true)
        else
            hCheckImg:Show()
            Currency.CheckCurrency(this.szName, false)
        end
    elseif szName == "Handle_Filter" then
        local hCheckImg = this:Lookup("Image_CheckNormal")
        local hOption = this:GetParent();
        if hCheckImg:IsVisible() then
            hCheckImg:Hide()
            Currency.CheckCurrency(hOption.szName, true)
        else
            hCheckImg:Show()
            Currency.CheckCurrency(hOption.szName, false)
        end
    end
end

function Currency.OnLButtonClick()
    local szName = this:GetName()
    if szName == "Btn_Close" then
        CloseCurrencyPanel()
    end
end

function Currency.OnLButtonDown()
    Currency.OnLButtonHold()
end

function Currency.OnLButtonHold()
    local szName = this:GetName()
    if szName == "Btn_Up" then
        this:GetParent():Lookup("Scroll_List"):ScrollPrev()
    elseif szName == "Btn_Down" then
        this:GetParent():Lookup("Scroll_List"):ScrollNext()
    end
end

function Currency.OnItemMouseWheel()
	local nDistance = Station.GetMessageWheelDelta()
	local szName = this:GetName()
    
	if szName == "Handle_Money" then
        local hFrame = this:GetRoot()
		hFrame:Lookup("Scroll_List"):ScrollNext(nDistance)
	end
    return 1
end

function IsCurrencyPanelOpened()
    local hFrame = Station.Lookup("Normal/Currency")
	if hFrame and hFrame:IsVisible() then
		return true
	end
	return false
end

function CloseCurrencyPanel(bDisableSound)
    if IsCurrencyPanelOpened() then
		Wnd.CloseWindow("Currency")
	end

	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseAuction)
	end
end

function OpenCurrencyPanel(bDisableSound)
    if IsCurrencyPanelOpened() then
        return
    end
    
    hCurrentFrame = Wnd.OpenWindow("Currency")
    if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenAuction)
	end
end

function Currency_GetCheckedCurrency()
    local tResult = {}
    local tCurrencyData = Table_GetCurrencyList()
    for k, v in pairs(tCurrencyData) do
        for nIndex, szName in ipairs(Currency.tCheck) do
            if v.szName == szName then
                local nCount = Currency.GetCurrencyNumber(v) 
                tResult[nIndex] = {szName=v.szName, nCount = nCount, nFrame= v.nFrame}
                break
            end
        end
    end
    return tResult
end
--=======================提示信息
local function OutputCurrencyMessage(szMsgType, nOldValue, nCurrentValue, nLimit, nMaxValue, szCurrency, tipType)
    FireEvent("CURRENCY_VALUE_UPDATE")
    if nOldValue > nCurrentValue then
        if tipType == 1 then
            OutputMessage(szMsgType, FormatString(g_tStrings.STR_CURRENCY_UPDATE_TIP1, nOldValue - nCurrentValue, szCurrency))
        elseif tipType == 2 then
            OutputMessage(szMsgType, FormatString(g_tStrings.STR_CURRENCY_UPDATE_TIP2, nOldValue - nCurrentValue, szCurrency))
        end
		
	elseif nOldValue < nCurrentValue then
		if tipType == 1 then
            OutputMessage(szMsgType, FormatString(g_tStrings.STR_CURRENCY_UPDATE_TIP3, nCurrentValue - nOldValue, szCurrency))
        elseif tipType == 2 then
            OutputMessage(szMsgType, FormatString(g_tStrings.STR_CURRENCY_UPDATE_TIP4, nCurrentValue - nOldValue, szCurrency))
        end
	end
    
    if nLimit == 0 and nOldValue <= nCurrentValue then
        OutputMessage(szMsgType, FormatString(g_tStrings.STR_CURRENCY_UPDATE_TIP5, szCurrency))
    end
end

local function OnJusticeUpdate()
    local nOldValue = arg0
    
    local player = GetClientPlayer()
    local nMaxValue = player.GetMaxJustice()
    local nCurrentValue = player.nJustice
    local nLimit = player.GetJusticeRemainSpace()
	
	if nCurrentValue > nOldValue then
		FireUIEvent("CURRENCY_GET", "OnFirstGetJustice")
	end
	
    OutputCurrencyMessage("MSG_MONEY", nOldValue, nCurrentValue, nLimit, nMaxValue, g_tStrings.STR_CURRENT_XIAYI, 2)
end

local function OnExamPrintUpdate()
    local nOldValue = arg0
    
    local player = GetClientPlayer()
    local nMaxValue = player.GetMaxExamPrint()
    local nCurrentValue = player.nExamPrint
    local nLimit = player.GetExamPrintRemainSpace()
	
	if nCurrentValue > nOldValue then
		FireUIEvent("CURRENCY_GET", "OnFirstGetExamPrint")
	end
	
    OutputCurrencyMessage("MSG_MONEY", nOldValue, nCurrentValue, nLimit, nMaxValue, g_tStrings.STR_CURRENT_EXAMPRINT, 1)
end

local function OnArenaAwardUpdate()
    local nOldValue = arg0
    
    local player = GetClientPlayer()
    local nMaxValue = player.GetMaxArenaAward()
    local nCurrentValue = player.nArenaAward
    local nLimit = player.GetArenaAwardRemainSpace()
	
	if nCurrentValue > nOldValue then
		FireUIEvent("CURRENCY_GET", "OnFirstGetArenaAware")
	end
	
    OutputCurrencyMessage("MSG_MONEY", nOldValue, nCurrentValue, nLimit, nMaxValue, g_tStrings.STR_CURRENT_ARENA_AWARD, 1)
end

local function OnPrestigeUpdate()
    local nOldValue = arg0
    
    local player = GetClientPlayer()
    local nMaxValue = player.GetMaxPrestige()
    local nCurrentValue = player.nCurrentPrestige
    local nLimit = player.GetPrestigeRemainSpace()
	
	if nCurrentValue > nOldValue then
		FireUIEvent("CURRENCY_GET", "OnFirstGetPrestige")
	end
	
    OutputCurrencyMessage("MSG_PRESTIGE", nOldValue, nCurrentValue, nLimit, nMaxValue, g_tStrings.STR_CURRENT_PRESTIGE, 2)
end

local function OnTitlePointUpdate()
    local nNewTitlePoint = arg0
    local nAddTitlePoint = arg1
    
	if nAddTitlePoint > 0 then
		FireUIEvent("CURRENCY_GET", "OnFirstGetPointTitle")
	end
	
    OutputMessage("MSG_PRESTIGE", FormatString(g_tStrings.TITLE_POINT_ADD, nAddTitlePoint))
end

local function OnContributionUpdate()
	local nOldValue = arg0
    --local nCurrentValue = arg1
    
    local player = GetClientPlayer()
    local levelUp = GetLevelUpData(player.nRoleType, player.nLevel)
    local nMaxValue = levelUp['MaxContribution'] or 0
    local nLimit = player.GetContributionRemainSpace()
    local nCurrentValue = player.nContribution
    
	if nCurrentValue > nOldValue then
		FireUIEvent("CURRENCY_GET", "OnGetContribution")
	end
    OutputCurrencyMessage("MSG_CONTRIBUTE", nOldValue, nCurrentValue, nLimit, nMaxValue, g_tStrings.STR_CURRENT_CONTRIBUTION, 2)
end

local function OnAchievementCountUpdate()
	local player = GetClientPlayer()
	local nValue = player.GetAchievementRecord()
	if nValue > 0 then
		FireUIEvent("CURRENCY_GET", "OnFirstGetJHZILI")
	end
end

local function OnSyncCoinUpdate()
	local player = GetClientPlayer()
	local nValue = player.nCoin
	if nValue > 0 then
		FireUIEvent("CURRENCY_GET", "OnFirstGetCoin")
	end
end

local function OnMaxCurrentNotify(szMsgType, szCurrency)
    OutputMessage(szMsgType, FormatString(g_tStrings.STR_CURRENCY_UPDATE_TIP6, szCurrency))
    PlayTipSound("016")
end

local function OnSyncMentorScoreUpdate()
	local player = GetClientPlayer()
	local nValue = player.dwTAEquipsScore
	if nValue > 0 then
		FireUIEvent("CURRENCY_GET", "OnFirstGetMentorScore")
	end
end

RegisterEvent("CONTRIBUTION_UPDATE", OnContributionUpdate)
RegisterEvent("UPDATE_EXAMPRINT", OnExamPrintUpdate)
RegisterEvent("UPDATE_JUSTICE", OnJusticeUpdate)
RegisterEvent("UPDATE_PRESTIGE", OnPrestigeUpdate)
RegisterEvent("TITLE_POINT_UPDATE", OnTitlePointUpdate)
RegisterEvent("UPDATE_ARENAAWARD", OnArenaAwardUpdate)
RegisterEvent("UPDATE_ACHIEVEMENT_COUNT", OnAchievementCountUpdate)
RegisterEvent("SYNC_COIN", OnSyncCoinUpdate)
RegisterEvent("ON_SYNC_TA_EQUIPS_SCORE", OnSyncMentorScoreUpdate)


RegisterEvent("MAX_JUSTICE_NOTIFY", function() OnMaxCurrentNotify("MSG_MONEY", g_tStrings.STR_CURRENT_XIAYI) end)
RegisterEvent("MAX_EXAMPRINT_NOTIFY", function() OnMaxCurrentNotify("MSG_MONEY", g_tStrings.STR_CURRENT_EXAMPRINT) end)
RegisterEvent("MAX_CONTRIBUTION_NOTIFY", function() OnMaxCurrentNotify("MSG_CONTRIBUTE", g_tStrings.STR_CURRENT_CONTRIBUTION) end)
RegisterEvent("MAX_PRESTIGE_NOTIFY", function() OnMaxCurrentNotify("MSG_PRESTIGE", g_tStrings.STR_CURRENT_PRESTIGE) end)
RegisterEvent("MAX_ARENAAWARD_NOTIFY", function() OnMaxCurrentNotify("MSG_MONEY", g_tStrings.STR_CURRENT_ARENA_AWARD) end)


RegisterEvent("SYNC_ROLE_DATA_END", function(szEvent) Currency.OnEvent(szEvent) end)