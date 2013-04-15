local ACTIVE_POPULARIZE_STATE_UNDER_WAY = 1
local ACTIVE_POPULARIZE_STATE_UNOPENED = 2
local INI_PATH =  "ui/Config/Default/ActivePopularize.ini"
local ACTIVE_POPULARIZE_CARD_TOTAL_COUNT = 3
local ACTIVE_POPULARIZE_AWARD_COUNT = 8
local FONT_NORMAL = 106
local FONT_TITLE = 59
local FONT_NAME = 164
local FONT_FIT = 198
local FONT_NOT_FIT = 196
local CARD_TYPE = {ACTIVE = 1, AWARD = 2}
local tActiveLabelFrame = {10, 0, 13}
local tNumberFrame = {1, 2, 0, 3, 4}

ActivePopularize = {}

ActivePopularize.bPopActivePopularize = true

-- RegisterCustomData("ActivePopularize.bPopActivePopularize") // 以后还要加，暂时不去掉了

function ActivePopularize.OnFrameCreate()
    this:RegisterEvent("UI_SCALED")
    
    ActivePopularize.OnEvent("UI_SCALED")
    local hBtnCalender = this:Lookup("Btn_Calender")
    hBtnCalender:Hide()
    --this:Lookup("CheckBox_Choose"):Check(not ActivePopularize.bPopActivePopularize)
end
function ActivePopularize.OnCheckBoxCheck()
    local szName = this:GetName()
    if szName == "CheckBox_Choose" then
        ActivePopularize.bPopActivePopularize = false
    end
end

function ActivePopularize.OnCheckBoxUncheck()
    local szName = this:GetName()
    if szName == "CheckBox_Choose" then
        ActivePopularize.bPopActivePopularize = true
    end
end

function ActivePopularize.OnFrameBreathe()
    if not this.tActiveList or not this.nStartIndex then
        return
    end
    local tActiveList = this.tActiveList
    local nTime = GetCurrentTime()
    for _, tActive in ipairs(tActiveList) do
        if tActive.nCardType == CARD_TYPE.ACTIVE and nTime > tActive.nEndTime then
            ActivePopularize.InitFrameInfo(this)
            return
        end
    end
    local hHandleCard = this:Lookup("", "Handle_Cards")
    local nIndex = this.nStartIndex
    
    local nShowCount = this.nShowCount
    for i = 1, nShowCount do
        local hCard = hHandleCard:Lookup("Handle_Card" .. i)
        local tActive = tActiveList[nIndex]
        if tActive.nCardType == CARD_TYPE.ACTIVE then
            ActivePopularize.UpdateCardActiveTime(hCard:Lookup("Handle_Active"), tActive)
        end
        nIndex = nIndex + 1
    end
end

function ActivePopularize.OnEvent(szEvent)
	if szEvent == "UI_SCALED" then
		this:SetPoint("CENTER", 0, 0, "CENTER", 0, 0)
	end
end

function ActivePopularize.OnItemMouseEnter()
    local szName = this:GetName()
	local szType = this:GetType()
    local hFrame = this:GetRoot()
    if szName == "Handle_Button" then
        this:Lookup("Image_Button"):SetFrame(21)
    elseif szName == "Handle_ReButton" then
        this:Lookup("Image_ReButton"):SetFrame(21)
    elseif szName == "Image_Box" then
         local x, y = this:GetAbsPos()
         local w, h = this:GetSize()
         OutputTip(this.szTip, 400, {x, y, w, h})
    elseif szName == "Image_CardBg" then
        local hCard = this:GetParent():GetParent()
        local nExpendIndex = hFrame.nExpendIndex
        if nExpendIndex ~= hCard.nIndex then
            local hImageLight = this:GetParent():Lookup("Image_CardLight")
            hImageLight:Show()
        end
    elseif szName == "Image_AwardBg" then
        local hCard = this:GetParent():GetParent()
        local nExpendIndex = hFrame.nExpendIndex
        if nExpendIndex ~= hCard.nIndex then
            local hImageLight = this:GetParent():Lookup("Image_ReCardLight")
            hImageLight:Show()
        end
	elseif szType == "Text" and this:IsLink() then
		local nFont = this:GetFontScheme()
		this.nFont = nFont
		this:SetFontScheme(164)
		local hHandle = this:GetParent()
		hHandle:FormatAllItemPos()
    elseif this.nAwardIndex then
        local tLine = g_tTable.CalenderAward:Search(this.nAwardIndex)
        if tLine then
            local x, y = this:GetAbsPos()
            local w, h = this:GetSize()
            OutputTip(GetFormatText(FormatString(g_tStrings.ACTIVE_POPULARIZE_SCORE_TIP, tLine.szName , this.nAwardScore)), 400, {x, y, w, h})	
        end
    elseif this.nAwardName then
        local x, y = this:GetAbsPos()
        local w, h = this:GetSize()
        local szTip = ActivePopularize.GetAwardRemindTip(this.tAward)
        OutputTip(szTip, 400, {x, y, w, h})
	end
end

function ActivePopularize.OnItemMouseLeave()
    local szName = this:GetName()
	local szType = this:GetType()
    if szName == "Handle_Button" then
        this:Lookup("Image_Button"):SetFrame(20)
    elseif szName == "Handle_ReButton" then
        this:Lookup("Image_ReButton"):SetFrame(20)
    elseif szName == "Image_CardBg" then
        local hImageLight = this:GetParent():Lookup("Image_CardLight")
        hImageLight:Hide()
    elseif szName == "Image_AwardBg" then
        local hImageLight = this:GetParent():Lookup("Image_ReCardLight")
        hImageLight:Hide()
	elseif szType == "Text" and this:IsLink() then
		if this.nFont then
			this:SetFontScheme(this.nFont)
			local hHandle = this:GetParent()
			hHandle:FormatAllItemPos()
		end
	end
    HideTip()
end

function ActivePopularize.OnLButtonClick()
    local szName = this:GetName()
    local hFrame = this:GetRoot()
    if szName == "Btn_Close" then
        CloseActivePopularize()
    elseif szName == "Btn_Left" then
        local nExpendIndex = hFrame.nExpendIndex
        local nShowCount = hFrame.nShowCount
        if nExpendIndex ==  nShowCount then
            nExpendIndex = -1
            nShowCount = nShowCount + 1
        end
        ActivePopularize.Update(hFrame, hFrame.tActiveList, hFrame.nStartIndex - 1, nShowCount, nExpendIndex)
    elseif szName == "Btn_Right" then
        local nExpendIndex = hFrame.nExpendIndex
        local nShowCount = hFrame.nShowCount
        local nStartIndex = hFrame.nStartIndex
        if nExpendIndex == 1 then
            nExpendIndex = -1
            nShowCount = nShowCount + 1
        else
            nStartIndex = nStartIndex + 1
        end
        ActivePopularize.Update(hFrame, hFrame.tActiveList, nStartIndex, nShowCount, nExpendIndex)
    elseif szName == "Btn_Calender" then
        --OpenCalenderPanel()
    end
end

function ActivePopularize.OnItemLButtonClick()
    local hFrame = this:GetRoot()
    local szName = this:GetName()
    if szName == "Handle_Button" or 
    szName == "Image_CardBg_Expend" or
    szName == "Image_AwardBg_Expend" or
    szName == "Handle_ReButton" then
        local nShowCount = ACTIVE_POPULARIZE_CARD_TOTAL_COUNT
        local nStartIndex = hFrame.nStartIndex
        if (#hFrame.tActiveList - nStartIndex + 1 < nShowCount) and nStartIndex > 1 then
            nStartIndex = nStartIndex - 1
        end
        ActivePopularize.Update(hFrame, hFrame.tActiveList, nStartIndex, nShowCount, -1)
    elseif szName == "Image_CardBg" or szName == "Image_AwardBg" then
        local hCard = this:GetParent():GetParent()
        local nExpendIndex = hFrame.nExpendIndex
        if nExpendIndex == hCard.nIndex then
            return
        end
        local nExpendIndex = hCard.nIndex
        local nShowCount = ACTIVE_POPULARIZE_CARD_TOTAL_COUNT - 1
        local nStartIndex = hFrame.nStartIndex
        if hCard.nIndex == ACTIVE_POPULARIZE_CARD_TOTAL_COUNT then
            nStartIndex = nStartIndex + 1
            nExpendIndex = nExpendIndex - 1
        end
        ActivePopularize.Update(hFrame, hFrame.tActiveList, nStartIndex, nShowCount, nExpendIndex)
    end
end

function ActivePopularize.Update(hFrame, tActiveList, nStartIndex, nShowCount, nExpendIndex)
    local hHandleCard = hFrame:Lookup("", "Handle_Cards")
    hHandleCard:Show()
    hFrame.tActiveList = tActiveList
    hFrame.nStartIndex = nStartIndex
    hFrame.nExpendIndex = nExpendIndex
    hFrame.nShowCount = nShowCount
    local nIndex = nStartIndex
    ActivePopularize.UpdateScrollPos(hFrame, nExpendIndex)

    for i = 1, nShowCount do
        if not tActiveList[nIndex] then
            break
        end
        local hCard = hHandleCard:Lookup("Handle_Card" .. i)
        local tActive = tActiveList[nIndex]
        local bExpend = (nExpendIndex == i)
        ActivePopularize.UpdateCard(hCard, tActive, bExpend)
        nIndex = nIndex + 1
    end
    local hBtnLeft = hFrame:Lookup("Btn_Left")
    local hBtnRight = hFrame:Lookup("Btn_Right")
    
    hBtnLeft:Enable(nStartIndex > 1)
    hBtnRight:Enable(nStartIndex + nShowCount - 1 < #tActiveList)
    if #tActiveList == 0 then
        hHandleCard:Hide()
    end
end

function ActivePopularize.UpdateCard(hCard, tActive, bExpend)
    local hCardActive = hCard:Lookup("Handle_Active")
    local hCardAward = hCard:Lookup("Handle_Award")
    if tActive.nCardType == CARD_TYPE.ACTIVE then
        ActivePopularize.UpdateCardActive(hCardActive, tActive, bExpend)
        hCardActive:FormatAllItemPos()
        local _, fHeight = hCardAward:GetSize()
        hCardAward:SetSize(0, fHeight)
        hCardAward:FormatAllItemPos()

    elseif tActive.nCardType == CARD_TYPE.AWARD then
        ActivePopularize.UpdateCardAward(hCardAward, tActive, bExpend)
        hCardAward:FormatAllItemPos()
        local _, fHeight = hCardActive:GetSize()
        hCardActive:SetSize(0, fHeight)
        hCardActive:FormatAllItemPos()

    end
    hCard:FormatAllItemPos()
    hCard:GetParent():FormatAllItemPos()
end

function ActivePopularize.UpdateCardAward(hCardAward, tAwardRemind, bExpend)
    
    local hImageCount = hCardAward:Lookup("Image_Num")
    hImageCount:SetFrame(tNumberFrame[#tAwardRemind])
    local hContent = hCardAward:Lookup("Handle_Award_Content")
    local fWidth = 0
    local _, fHeight = hCardAward:GetSize()
    local hImageCardBg = hCardAward:Lookup("Image_AwardBg")
    local hImageCardExpend = hCardAward:Lookup("Image_AwardBg_Expend")
    local hCard = hCardAward:GetParent()
    local nCardIndex = hCard.nIndex
    if not bExpend then
        fWidth = 284
        hCardAward:SetSize(fWidth, fHeight)
        hContent:Hide()
        hImageCardBg:Show()
        hImageCardExpend:Hide()
        hCardAward:FormatAllItemPos()
        hCard:SetSize(fWidth, fHeight)
        return 
    end
    hCardAward:Lookup("Image_ReCardLight"):Hide()
    hImageCardBg:Hide()
    hImageCardExpend:Show()
    fWidth = 583
    hCardAward:SetSize(fWidth, fHeight)
    hCard:SetSize(fWidth, fHeight)
    local hMessage = hCardAward:Lookup("Handle_Award_Content/Handle_Award_ActiveMessage")
    hMessage:Clear()
    for nIndex, tAward in ipairs(tAwardRemind) do
        if nIndex > 1 then
            hMessage:AppendItemFromString(GetFormatText("\n"))
        end
        hMessage:AppendItemFromString(GetFormatText(tAward.szName .. g_tStrings.STR_COLON, FONT_NAME, nil, nil, nil, 256))
        local nCount = hMessage:GetItemCount()
        local hName = hMessage:Lookup(nCount - 1)
        hName.nAwardName = true
        hName.tAward = tAward
        hMessage:AppendItemFromString(tAward.szLink .. GetFormatText("\n"))
        hMessage:AppendItemFromString(tAward.szAward .. GetFormatText("\n"))
    end
    hMessage:FormatAllItemPos()
    hCardAward:FormatAllItemPos()
    ActivePopularize.ResisterScroll(nCardIndex, tAwardRemind.nCardType)
    FireUIEvent("SCROLL_UPDATE_LIST", "Handle_Award_ActiveMessage", "ActivePopularize", true)
end

function ActivePopularize.GetAwardRemindTip(tAward)
    local szTip = ""
    local bFit = ActivePopularize.CheckLevel(tAward.tLevel)
    szTip = GetFormatText(tAward.szName .. "\n", FONT_NAME)
    local nFont = FONT_FIT
    if not bFit then
        nFont = FONT_NOT_FIT
    end
    szTip = szTip .. GetFormatText(g_tStrings.TONG_ACTIVITY_JOIN_LEVEL, FONT_TITLE) .. GetFormatText(tAward.szLevel .. "\n", nFont)
    szTip = szTip .. GetFormatText(g_tStrings.ACTIVE_POPULARIZE_TIME, FONT_TITLE) .. GetFormatText(tAward.szTimeRepresent .. "\n")
    szTip = szTip .. GetFormatText(g_tStrings.ACTIVE_POPULARIZE_DETAIL, FONT_TITLE) .. tAward.szDetails .. GetFormatText("\n")
    
    return szTip
end

function ActivePopularize.UpdateCardActive(hCardActive, tActive, bExpend)
    hCardActive:Lookup("Text_ActiveType"):SetText(g_tStrings.tActiveClass[tActive.nClass])
    hCardActive:Lookup("Text_ActiveName"):SetText(tActive.szName)
    local hMessage = hCardActive:Lookup("Handle_Message")
    for i = 1, ACTIVE_POPULARIZE_AWARD_COUNT do
        local hImageAward = hMessage:Lookup("Image_Award" .. i .. "_Tiao")
        hImageAward:SetPercentage(0)
        local hBg = hMessage:Lookup("Image_Award" .. i .. "_Bg")
        hBg.nAwardIndex = i
        hBg.nAwardScore = 0
        if tActive.tAward[i] then
            hImageAward:SetPercentage(tActive.tAward[i] / 100)
            hBg.nAwardScore = tActive.tAward[i]
        end
    end
    ActivePopularize.UpdateCardActiveTime(hCardActive, tActive)
    ActivePopularize.UpdateCardActiveContent(hCardActive, tActive, bExpend)
    local hImageLabel = hCardActive:Lookup("Image_Label")
    hImageLabel:Hide()
    if tActive.nLabel > 0 then
        hImageLabel:Show()
        hImageLabel:SetFrame(tActiveLabelFrame[tActive.nLabel])
        local fWidth = hImageLabel:GetSize()
        local fCardWidth = hCardActive:GetSize()
        local _, fY = hImageLabel:GetRelPos()
        hImageLabel:SetRelPos(fCardWidth - fWidth - 16, fY)
    end
    
    local hImageBox = hMessage:Lookup("Image_Box")
    hImageBox:Hide()
    if tActive.nLuckdraw > 0 then
        hImageBox:Show()
        hImageBox.szTip = tActive.szLuckdrawText
        if tActive.szLuckPath ~= "" and tActive.nLuckFrame then
            hImageBox:FromUITex(tActive.szLuckPath, tActive.nLuckFrame)
        end
    end
    local hTextLevel = hMessage:Lookup("Text_Level")
    local szLevel = string.sub(tActive.szLevel, 1, #tActive.szLevel - 1)
    hTextLevel:SetText(g_tStrings.TONG_ACTIVITY_JOIN_LEVEL .. szLevel)
    local bFit = ActivePopularize.CheckLevel(tActive.tLevel)
    if bFit then
        hTextLevel:SetFontScheme(FONT_FIT)
    else
        hTextLevel:SetFontScheme(FONT_NOT_FIT)
    end
    hCardActive:FormatAllItemPos()
    hCardActive:GetParent():FormatAllItemPos()
end

function ActivePopularize.CheckLevel(tLevel)
    local hPlayer = GetClientPlayer()
    if not hPlayer then
        return
    end
    local nLevel = hPlayer.nLevel
    local bFit = false
    for _, tLevelSect in ipairs(tLevel) do
        if tLevelSect[1] >= tLevelSect[2] then
            if nLevel >= tLevelSect[1] then
                bFit = true
                break
            end
        else 
            if nLevel >= tLevelSect[1] and nLevel <= tLevelSect[2] then
                bFit = true
                break
            end
        end
    end
    
    return bFit
end

function ActivePopularize.UpdateCardActiveTime(hCardActive, tActive)
    local hMessage = hCardActive:Lookup("Handle_Message")
    local hImageTimeBg = hMessage:Lookup("Image_Time1")
    local hImageTime = hMessage:Lookup("Image_Time2")
    local hTextTime = hMessage:Lookup("Text_Time")
    local nTime = GetCurrentTime()
    if tActive.nStartTime < nTime then
        local nLiveTime = tActive.nEndTime - nTime
        local nTimePercentage =  nLiveTime / (tActive.nEndTime - tActive.nStartTime)
        local szTime = GetTimeText(nLiveTime, false, true, true, true) .. g_tStrings.ACTIVE_POPULARIZE_FINISH
        hImageTime:SetPercentage(1 - nTimePercentage)
        
        hImageTimeBg:Show()
        hImageTime:Show()
        hTextTime:SetText(szTime)
        hTextTime:SetFontScheme(177)
    else
        hImageTimeBg:Hide()
        hImageTime:Hide()
        local nNeedTime = tActive.nStartTime - nTime
        szTime = GetTimeText(nNeedTime, false, true, true, true) .. g_tStrings.ACTIVE_POPULARIZE_START
        hTextTime:SetText(szTime)
        hTextTime:SetFontScheme(196)
    end
end

function ActivePopularize.ResisterScroll(nIndex, nCardType)
    RegisterScrollEvent("ActivePopularize")
    
    UnRegisterScrollAllControl("ActivePopularize")
    
    local szFramePath = "Normal/ActivePopularize"
    if nCardType == CARD_TYPE.ACTIVE then
        RegisterScrollControl(
            szFramePath, 
            "Btn_UP", "Btn_Down", 
            "Scroll_Content", 
            {"", "Handle_Cards/Handle_Card" .. nIndex .. "/Handle_Active/Handle_Content/Handle_ActiveMessage" .. nIndex})
    elseif  nCardType == CARD_TYPE.AWARD then
        RegisterScrollControl(
            szFramePath, 
            "Btn_UP", "Btn_Down", 
            "Scroll_Content", 
            {"", "Handle_Cards/Handle_Card" .. nIndex .. "/Handle_Award/Handle_Award_Content/Handle_Award_ActiveMessage"})
    end
end

function ActivePopularize.UpdateCardActiveContent(hCardActive, tActive, bExpend)
    local hCard = hCardActive:GetParent()
    local nIndex = hCard.nIndex
    local hContent = hCardActive:Lookup("Handle_Content")
    local fWidth = 0
    local _, fHeight = hCardActive:GetSize()
    local hImageCardBg = hCardActive:Lookup("Image_CardBg")
    local hImageCardExpend = hCardActive:Lookup("Image_CardBg_Expend")
    if not bExpend then
        fWidth = 284
        hCardActive:SetSize(fWidth, fHeight)
        hCard:SetSize(fWidth, fHeight)
        hContent:Hide()
        hCardActive:FormatAllItemPos()
        hImageCardBg:Show()
        if tActive.szBackgroundImage ~= "" then
            hImageCardBg:FromTextureFile(tActive.szBackgroundImage)
        end
        hImageCardExpend:Hide()
        return 
    end
     hImageCardBg:Hide()
     hImageCardExpend:Show()
     hCardActive:Lookup("Image_CardLight"):Hide()
     if tActive.szBackgroundImageExpend ~= "" then
        hImageCardExpend:FromTextureFile(tActive.szBackgroundImageExpend)
     end
    fWidth = 583
    hCardActive:SetSize(fWidth, fHeight)
    hCard:SetSize(fWidth, fHeight)
    hContent:Show()
    local szHandleName = "Handle_ActiveMessage" .. nIndex
    local hContentMsg = hContent:Lookup(szHandleName)
    ActivePopularize.AppendActiveDetail(hContentMsg, tActive)
    hContent:FormatAllItemPos()
    hCardActive:FormatAllItemPos()
    
    ActivePopularize.ResisterScroll(nIndex, tActive.nCardType)
    FireUIEvent("SCROLL_UPDATE_LIST", szHandleName, "ActivePopularize", true)
end

function ActivePopularize.AppendActiveDetail(hContentMsg, tActive)
    hContentMsg:Clear()
    local szMsg = GetFormatText(g_tStrings.ACTIVE_POPULARIZE_TIME .. "\n", FONT_TITLE)
    szMsg = szMsg .. GetFormatText("        " .. tActive.szTimeRepresent .. "\n\n", FONT_NORMAL)
    szMsg = szMsg .. GetFormatText(g_tStrings.ACTIVE_POPULARIZE_MAP .. "\n", FONT_TITLE)
    szMsg = szMsg .. tActive.szDetailMap .. GetFormatText("\n\n")
    szMsg = szMsg .. GetFormatText(g_tStrings.ACTIVE_POPULARIZE_AWARD .. "\n", FONT_TITLE)
    szMsg = szMsg .. tActive.szDetailAwards  .. GetFormatText("\n\n")
    szMsg = szMsg .. GetFormatText(g_tStrings.ACTIVE_POPULARIZE_DETAIL .. "\n", FONT_TITLE)
    szMsg = szMsg .. tActive.szText 
    hContentMsg:AppendItemFromString(szMsg)
    hContentMsg:FormatAllItemPos()
end

function ActivePopularize.UpdateScrollPos(hFrame, nExpendIndex)
    local hScroll = hFrame:Lookup("Scroll_Content")
    local hBtnUp = hFrame:Lookup("Btn_UP")
    local hBtnDown = hFrame:Lookup("Btn_Down")
    if nExpendIndex == -1 then
        hScroll:Hide()
        hBtnUp:Hide()
        hBtnDown:Hide()
    else
        hScroll:Show()
        hBtnUp:Show()
        hBtnDown:Show()
        local _, fY = hScroll:GetRelPos()
        fX = 606 + (nExpendIndex - 1) * 299
        hScroll:SetRelPos(fX, fY)
        _, fY = hBtnUp:GetRelPos()
        fX = 603 + (nExpendIndex - 1) * 299
        hBtnUp:SetRelPos(fX, fY)
         _, fY = hBtnDown:GetRelPos()
        hBtnDown:SetRelPos(fX, fY)
    end
end

function ActivePopularize.Init(hFrame)
    local hHandleCard = hFrame:Lookup("", "Handle_Cards")
    hHandleCard:Clear()
    for i = 1, ACTIVE_POPULARIZE_CARD_TOTAL_COUNT do
        if i > 1 then
            hHandleCard:AppendItemFromIni(INI_PATH, "Handle_CMode")
        end
        local hCard = hHandleCard:AppendItemFromIni(INI_PATH, "Handle_CardMode", "Handle_Card" .. i)
        hCard.nIndex = i
        local hCardActive = hCard:Lookup("Handle_Active")
        local hContent = hCardActive:Lookup("Handle_Content/Handle_ActiveMessage")
        hContent:SetName("Handle_ActiveMessage" .. i)
    end
    
    
    hHandleCard:FormatAllItemPos()
end

function ActivePopularize.GetTheActiveInfo(tTheActive)
    local tLine = g_tTable.CalenderActivity:Search(tTheActive[1])
	tLine = Table_ParseCalenderActivity(tLine)
    tLine.nStartTime = tTheActive[3]
    tLine.nEndTime = tTheActive[4]
    return tLine
end

function ActivePopularize.InitFrameInfo(hFrame, tTheActive)
    local tActiveList = ActivePopularize.GetActiveList(tTheActive)
    local nShowCount = ACTIVE_POPULARIZE_CARD_TOTAL_COUNT
    local nExpendIndex = -1
    if tTheActive then
        nShowCount = ACTIVE_POPULARIZE_CARD_TOTAL_COUNT - 1
        nExpendIndex = 1
    end
    ActivePopularize.Update(hFrame, tActiveList, 1, nShowCount, nExpendIndex)

end
function ActivePopularize.GetActiveList(tTheActive)
    local nTime = GetCurrentTime()
    local tTime = TimeToDate(nTime)
    local tActiveList = {}
    local nTotalCount = ACTIVE_POPULARIZE_CARD_TOTAL_COUNT
    if tTheActive then
        tTheActive = ActivePopularize.GetTheActiveInfo(tTheActive)
        if nTime > tTheActive.nStartTime and nTime < tTheActive.nEndTime then
            tTheActive.nState = ACTIVE_POPULARIZE_STATE_UNDER_WAY
        else 
            tTheActive.nState = ACTIVE_POPULARIZE_STATE_UNOPENED
        end
        
        nTotalCount = nTotalCount - 1
    end
    local tAllActive = Table_GetCalenderOfDay(tTime.year, tTime.month, tTime.day, 4)
    local SortByStartTime = function(tLeft, tRight)
        if tLeft.nStartTime == tRight.nStartTime then
            return tLeft.nLabel > tLeft.nLabel
        end
        return tLeft.nStartTime < tRight.nStartTime
    end
    table.sort(tAllActive, SortByStartTime)
    for _, tActive in ipairs(tAllActive) do
        if nTime > tActive.nStartTime and nTime < tActive.nEndTime then
            tActive.nState = ACTIVE_POPULARIZE_STATE_UNDER_WAY
            tActive.nCardType = CARD_TYPE.ACTIVE
            table.insert(tActiveList, tActive)
        end
    end
    
    if #tActiveList < nTotalCount then
        for _, tActive in ipairs(tAllActive) do
            if nTime < tActive.nStartTime and 
            ( 
                not tTheActive or 
                tTheActive.dwID ~= tActive.dwID or 
                tTheActive.nStartTime ~= tActive.nStartTime or
                tTheActive.nEndTime ~= tActive.nEndTime 
            )
            then
                tActive.nState = ACTIVE_POPULARIZE_STATE_UNOPENED
                tActive.nCardType = CARD_TYPE.ACTIVE
                table.insert(tActiveList, tActive)
                if #tActiveList >= nTotalCount then
                    break
                end
            end
        end
    end
    
    if #tActiveList < nTotalCount then
        tTime = GetNextDay(tTime)
        tAllActive = Table_GetCalenderOfDay(tTime.year, tTime.month, tTime.day, 4)
        table.sort(tAllActive, SortByStartTime)
        for _, tActive in ipairs(tAllActive) do
            if not tTheActive or 
            tTheActive.dwID ~= tActive.dwID or 
            tTheActive.nStartTime ~= tActive.nStartTime or 
            tTheActive.nEndTime ~= tActive.nEndTime 
            then
                tActive.nState = ACTIVE_POPULARIZE_STATE_UNOPENED
                tActive.nCardType = CARD_TYPE.ACTIVE
                table.insert(tActiveList, tActive)
                if #tActiveList >= nTotalCount then
                    break
                end
            end
        end
    end
    local SortActive = function(tLeft, tRight)
        if tLeft.nState == tRight.nState then
            if tLeft.nStartTime == tRight.nStartTime then
                return tLeft.nLabel > tLeft.nLabel
            end
            return tLeft.nStartTime < tRight.nStartTime
        end
        return tLeft.nState < tRight.nState
    end
    table.sort(tActiveList, SortActive)
    
    local tAwardRemind = Table_GetPlayerAwardRemind()
    if tAwardRemind and #tAwardRemind > 0 then
        tAwardRemind.nCardType = CARD_TYPE.AWARD
        table.insert(tActiveList, 1, tAwardRemind)
    end
    
    if tTheActive then
        tTheActive.nCardType = CARD_TYPE.ACTIVE
        table.insert(tActiveList, 1, tTheActive)
    end
    
    return tActiveList
end

function IsActivePopularizeOpened()
	local hFrame = Station.Lookup("Normal/ActivePopularize")
	if hFrame then
		return true
	end
	
	return false
end


function OpenActivePopularize(tTheActive, bDisableSound)
	if not IsActivePopularizeOpened() then
		Wnd.OpenWindow("ActivePopularize")
    end
    
    CloseCalenderPanel()
    local hFrame = Station.Lookup("Normal/ActivePopularize")
    ActivePopularize.Init(hFrame)
    ActivePopularize.InitFrameInfo(hFrame, tTheActive)
    
    if not bDisableSound then
		PlaySound(SOUND.UI_SOUND, g_sound.OpenFrame)
	end
end


function CloseActivePopularize(bDisableSound)
	if not IsActivePopularizeOpened() then
		return
	end
	
	Wnd.CloseWindow("ActivePopularize")
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND, g_sound.CloseFrame)
	end
end


