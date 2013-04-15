
local INI_FILE = "UI/Config/Default/ExteriorBox.ini"
local INI_FILE_BOX_LIST = "UI/Config/Default/ExteriorBoxList.ini"
local EXTERIOR_SUB_NUMBER = 5
local SUB_MAX_COUNT_FOR_ONE_PAGE = 8
local SUB_MAX_COUNT_FOR_TIME_PAGE = 4
local EXTERIOR_SET_NUM = 3
local EXTERIOR_BOX_WARNING_TIME = 60 * 60 * 24 * 3 -- 3天

local tExpendFrame = {Normal = 12, Expand = 8}

ExteriorBox = {}

ExteriorBox.nFilterSubType = 0
ExteriorBox.szFilterCheckName = "CheckBox_All"
ExteriorBox.bFilterMyBox = true

local tFilterTypeCheck = 
{
    ["CheckBox_All"] = 0,
    ["CheckBox_Helm"] = EQUIPMENT_SUB.HELM,
    ["CheckBox_Chest"] = EQUIPMENT_SUB.CHEST,
    ["CheckBox_Bangle"] = EQUIPMENT_SUB.BANGLE,
    ["CheckBox_Waist"] = EQUIPMENT_SUB.WAIST,
    ["CheckBox_Boots"] = EQUIPMENT_SUB.BOOTS,
}

local tCollectDivide = {{1, "Normal"}, {4, "More"}, {7, "Cool"}}
local tCollectFrame = 
{
    [EXTERIOR_GENRE.JIANGHU] = {Normal = 0, More = 1, Cool = 2},
    [EXTERIOR_GENRE.SCHOOL] = {Normal = 3, More = 4, Cool = 5},
    [EXTERIOR_GENRE.FORCE] = {Normal = 6, More = 7, Cool = 8},
}

function ExteriorBox.OnFrameCreate()
    this:RegisterEvent("ON_SET_EXTERIOR_SET_RESPOND")
    this:RegisterEvent("UI_SCALED")
    this:RegisterEvent("ON_EXTERIOR_BUY_RESPOND")
    this:RegisterEvent("RENDER_FRAME_UPDATE")
    this:RegisterEvent("ON_HAIR_CHANGE_RESPOND")
    this:RegisterEvent("PLAYER_HIDE_HAT_CHANGE")
    this:RegisterEvent("EXTERIOR_FREE_COUNT_UPDATE")
    this:RegisterEvent("HAIR_FREE_COUNT_UPDATE")
    
    ExteriorBox.OnEvent("UI_SCALED")
    
    this:Lookup("PageSet_Goods/CheckBox_Clothes"):Hide()
end

function ExteriorBox.OnEvent(szEvent)
	if szEvent == "UI_SCALED" then
		this:SetPoint("CENTER", 0, 0, "CENTER", 0, 0)
    elseif szEvent == "ON_EXTERIOR_BUY_RESPOND" then
        ExteriorBox.OnExteriorBuyRespond(this, arg0)
    elseif szEvent == "ON_SET_EXTERIOR_SET_RESPOND" then
        ExteriorBox.OnSetExteriorSetRespond(hFrame, arg0)
    elseif szEvent == "ON_HAIR_CHANGE_RESPOND" then
        ExteriorBox.OnHairChangeRespond(hFrame, arg0)
    elseif szEvent == "PLAYER_HIDE_HAT_CHANGE" then
        local hPlayer = GetClientPlayer()
        if hPlayer then
            this:Lookup("CheckBox_HideHat"):Check(hPlayer.bHideHat)
        end
    elseif szEvent == "EXTERIOR_FREE_COUNT_UPDATE" or 
        szEvent == "HAIR_FREE_COUNT_UPDATE" 
    then
        ExteriorBox.UpdateMyMoney(this)
    end
end

function ExteriorBox.OnHairChangeRespond(hFrame, nResult)
    ExteriorBox.UpdateHairPage(hFrame)
end

function ExteriorBox.OnSetExteriorSetRespond(hFrame, nResult)
    ExteriorBox.ShowCurrentSet(hFrame)
end

function ExteriorBox.OnExteriorBuyRespond(hFrame, nResult)
    if nResult == EXTERIOR_BUY_RESPOND_CODE.BUY_SUCCESS then
        ExteriorBox.OnMyExteriorBoxUpdate()
        ExteriorBox.UpdateAllSubPage(hFrame)
    end
end

function ExteriorBox.UpdateAllSubPage(hFrame)
    local hPageExterior = hFrame:Lookup("PageSet_Goods/Page_Clothes")
    local hWndOverView = hPageExterior:Lookup("Wnd_OverView")
    local hWndBox = hPageExterior:Lookup("Wnd_Box")
    ExteriorBox.UpdateOverViewTimePage(hWndOverView, hWndOverView.nPage)
    ExteriorBox.UpdateBoxPageList(hWndBox, hWndBox.nPage)
end

function ExteriorBox.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_Close" then
        CloseExteriorBox()
    elseif szName == "Btn_Reset" then
        ExteriorBox.Reset(this:GetRoot())
    elseif szName == "Btn_SureChange" then
        ExteriorBox.SureChange(this:GetRoot())
    elseif szName == "Btn_ZoomIn" then
        FireUIEvent("EXTERIOR_CHARACTER_SET_CAME_RARADIUS", "ExteriorBox", "Min")
    elseif szName == "Btn_ZoomOut" then
        FireUIEvent("EXTERIOR_CHARACTER_SET_CAME_RARADIUS", "ExteriorBox", "Max")
    elseif szName == "Btn_PagePrev" then
		local hPage = this:GetParent()
        ExteriorBox.UpdateBoxPageList(hPage, hPage.nPage - 1)
    elseif szName == "Btn_PageNext" then
		local hPage = this:GetParent()
        ExteriorBox.UpdateBoxPageList(hPage, hPage.nPage + 1)
    elseif szName == "Btn_TPagePrev" then
		local hPage = this:GetParent()
        ExteriorBox.UpdateOverViewTimePage(hPage, hPage.nPage - 1)
    elseif szName == "Btn_TPageNext" then
		local hPage = this:GetParent()
        ExteriorBox.UpdateOverViewTimePage(hPage, hPage.nPage + 1)
    elseif szName == "Btn_HeadL_0" then
        local hPageHair = this:GetParent()
        ExteriorBox.SelectHead(hPageHair, hPageHair.nHeadIndex - 1)
    elseif szName == "Btn_HeadR_0" then
        local hPageHair = this:GetParent()
        ExteriorBox.SelectHead(hPageHair, hPageHair.nHeadIndex + 1)
    elseif szName == "Btn_BangL_0" then
        local hPageHair = this:GetParent()
        ExteriorBox.SelectBang(hPageHair, hPageHair.nBangIndex - 1)
    elseif szName == "Btn_BangR_0" then
        local hPageHair = this:GetParent()
        ExteriorBox.SelectBang(hPageHair, hPageHair.nBangIndex + 1)
    elseif szName == "Btn_PlaitL_0" then
        local hPageHair = this:GetParent()
        ExteriorBox.SelectPlait(hPageHair, hPageHair.nPlaitIndex - 1)
    elseif szName == "Btn_PlaitR_0" then
        local hPageHair = this:GetParent()
        ExteriorBox.SelectPlait(hPageHair, hPageHair.nPlaitIndex + 1)
    elseif szName == "Btn_FaceL_0" then
        local hPageHair = this:GetParent()
        ExteriorBox.SelectFace(hPageHair, hPageHair.nFaceIndex - 1)
    elseif szName == "Btn_FaceR_0" then
        local hPageHair = this:GetParent()
        ExteriorBox.SelectFace(hPageHair, hPageHair.nFaceIndex + 1)
	end
end

function ExteriorBox.SureChange(hFrame)
    ExteriorBox.SetExteriorSet(hFrame)
    ExteriorBox.SetHair(hFrame)
    
    ExteriorBox.UpdateSureBtnState(hFrame, false)
end

function ExteriorBox.SetHair(hFrame)
    local tRepresentID = hFrame.tRepresentID
    if not tRepresentID then
        return
    end
    local nHairID = tRepresentID[EQUIPMENT_REPRESENT.HAIR_STYLE]
	local nFaceID = tRepresentID[EQUIPMENT_REPRESENT.FACE_STYLE]
    
    RemoteCallToServer("OnPlayerChangeHair", nFaceID, nHairID)
end

function ExteriorBox.Reset(hFrame)
    ExteriorBox.ShowCurrentSet(hFrame)
    ExteriorBox.UpdateHairPage(hFrame)
    ExteriorBox.UpdateAllSubPage(hFrame)
    
    ExteriorBox.UpdateSureBtnState(hFrame, false)
end

function ExteriorBox.SelectHead(hPageHair, nIndex)
    if nIndex < 1 then
        nIndex = 1
    end
    
    if nIndex > #hPageHair.tHead then
        nIndex = #hPageHair.tHead
    end
    hPageHair.nHeadIndex = nIndex
    hPageHair.nBangIndex = 1
    hPageHair.nPlaitIndex = 1
    ExteriorBox.UpdateHairUIID(hPageHair)
    ExteriorBox.OnHairTrayOn(hPageHair)
end

function ExteriorBox.SelectBang(hPageHair, nIndex)
    if nIndex < 1 then
        nIndex = 1
    end
    local nHeadID = hPageHair.tHead[hPageHair.nHeadIndex]
    local tBang = hPageHair.tBang[nHeadID]
    if nIndex > #tBang then
        nIndex = #tBang
    end
    
    hPageHair.nBangIndex = nIndex
    hPageHair.nPlaitIndex = 1
    ExteriorBox.UpdateHairUIID(hPageHair)
    ExteriorBox.OnHairTrayOn(hPageHair)
end

function ExteriorBox.SelectPlait(hPageHair, nIndex)
    if nIndex < 1 then
        nIndex = 1
    end
    local nHeadID = hPageHair.tHead[hPageHair.nHeadIndex]
    local tBang = hPageHair.tBang[nHeadID]
    local nBangID = tBang[hPageHair.nBangIndex]
    local tPlait = hPageHair.tPlait[nHeadID][nBangID]
    if nIndex > #tPlait then
        nIndex = #tPlait
    end
    
    hPageHair.nPlaitIndex = nIndex
    ExteriorBox.UpdateHairUIID(hPageHair)
    ExteriorBox.OnHairTrayOn(hPageHair)
end

function ExteriorBox.SelectFace(hPageHair, nIndex)
    if nIndex < 1 then
        nIndex = 1
    end
    if nIndex > #hPageHair.tFace then
        nIndex = #hPageHair.tFace
    end
    
    hPageHair.nFaceIndex = nIndex
    ExteriorBox.UpdateHairUIID(hPageHair)
    ExteriorBox.OnHairTrayOn(hPageHair)
end

function ExteriorBox.SetExteriorSet(hFrame)
    local hPlayer = GetClientPlayer()
    if not hPlayer then
        return
    end
    
    local bNotHave = false
    
    local nCurrentSetID = hPlayer.GetCurrentSetID()
    local tSet = {}
    local hBoxHandle = hFrame:Lookup("", "Handle_Boxes")
    for i = 1, EXTERIOR_SUB_NUMBER do
        local hBox = hBoxHandle:Lookup("Box_" .. i)
        local nExteriorSub = Exterior_BoxIndexToExteriorSub(i)
        tSet[nExteriorSub] = hBox.dwExteriorID
    end
    RemoteCallToServer("OnSetExteriorSet", nCurrentSetID, tSet)
end

function ExteriorBox.UpdateSureBtnState(hFrame, bChange)
    local hButtonSure = hFrame:Lookup("Btn_SureChange")
    hButtonSure:Enable(bChange)
end

function ExteriorBox.OnItemRButtonClick()
    local szName = this:GetName()
    local hParent = this:GetParent()
    if hParent then
        local szParentName = hParent:GetName()
        if szParentName == "Handle_Boxes" and this:GetType() == "Box" then
            local szIndex = string.match(szName, "Box_(%d)")
            local nIndex = tonumber(szIndex)
            ExteriorBox.CancelTryOn(this:GetRoot(), this.dwExteriorID, nIndex)
        end
    end
end

function ExteriorBox.CancelTryOn(hFrame, dwTryOnExteriorID, nIndex)
    local hPlayer = GetClientPlayer()
	if not hPlayer then
		return
	end
    if not hFrame.tRepresentID then
        hFrame.tRepresentID = hPlayer.GetRepresentID()
    end
    local nCurrentSetID = hPlayer.GetCurrentSetID()
    local tExteriorSet = hPlayer.GetExteriorSet(nCurrentSetID)
    local nExteriorSub  = Exterior_BoxIndexToExteriorSub(nIndex)
    local dwExteriorID = tExteriorSet[nExteriorSub]
    if dwTryOnExteriorID == dwExteriorID then
        dwExteriorID = 0
    end
    ExteriorBox.UpdateExteriorSubBox(hFrame, nIndex, dwExteriorID)
    FireUIEvent("EXTERIOR_CHARACTER_UPDATE", "ExteriorBox", hFrame.tRepresentID)
    ExteriorBox.UpdateAllSubPage(hFrame)
    ExteriorBox.UpdateSureBtnState(hFrame, true)
end

function ExteriorBox.OnItemLButtonDown()
    local szName = this:GetName()
    if szName == "Box_Item" then
       this:SetObjectPressed(1)
    end
end

function ExteriorBox.OnItemLButtonUp()
	local szName = this:GetName()
    if szName == "Box_Item" then
       this:SetObjectPressed(0)
    end
end

function ExteriorBox.OnItemLButtonDBClick()
    local szName = this:GetName()
    if szName == "Handle_Set" then
        ExteriorBox.OnSetTryOn(hFrame, this.nGenre, this.nSet)
    end
end

function ExteriorBox.OnItemLButtonClick()
    local szName = this:GetName()
    if szName == "Text_Mybutton1" or szName == "Text_Tbutton1" then
        local hSubInfo = this:GetParent():GetParent()
        ExteriorBox.OnSubTryOn(hSubInfo, hSubInfo.dwID, false)
    elseif szName == "Text_Mybutton2" or szName == "Text_Tbutton2" then
        local hSubInfo = this:GetParent():GetParent()
        ExteriorBox.OnSubTryOn(hSubInfo, hSubInfo.dwID, true)
    elseif szName == "Text_Tbutton3" then
        local hSub = this:GetParent():GetParent()
        OpenExteriorRenew(hSub.dwID)
    elseif szName == "Image_ListBg1" then
        local hSelect = this:GetParent()
        if hSelect.bExpend then
            hSelect.bExpend = false
        else
            hSelect.bExpend = true
        end
        ExteriorBox.SelectGenre(hSelect, hSelect.bExpend)
    elseif szName == "Handle_Set" then
        ExteriorBox.SelectSet(this)
    elseif szName == "Handle_OverViewTitle" then
        ExteriorBox.SelectOverView(this)
    elseif szName == "Handle_LatestBuy" then
        ExteriorBox.SelectLatestBuy(this)
    elseif szName == "Box_Item" then
        local hSubInfo = this:GetParent()
        ExteriorBox.OnSubTryOn(hSubInfo, hSubInfo.dwID, false)
    elseif szName == "Handle_ViewButton" then
        local hSubInfo = this:GetParent()
        ExteriorBox.OnSubTryOn(hSubInfo, hSubInfo.dwID, false)
    end
end

function ExteriorBox.OnSetTryOn(hFrame, nGenre, nSet)
    local tRepresentID = hFrame.tRepresentID
    local tSet = Table_GetExteriorSet(nGenre, nSet)
    for i = 1, EXTERIOR_SUB_NUMBER do
        local dwExteriorID = tSet["nSub" .. i]
        if dwExteriorID > 0 then
            ExteriorBox.UpdateExteriorSubBox(hFrame, i, dwExteriorID)
        end
    end
    FireUIEvent("EXTERIOR_CHARACTER_UPDATE", "ExteriorBox", tRepresentID)
    ExteriorBox.UpdateSureBtnState(hFrame, true)
    ExteriorBox.UpdateAllSubPage(hFrame)
end

function ExteriorBox.OnSubTryOn(hSubInfo, dwID, bSet)
    local hFrame = hSubInfo:GetRoot()
    local tRepresentID = hFrame.tRepresentID
    local hExteriorClient = GetExterior()
    if not hExteriorClient then
        return
    end
    
    local tExteriorInfo = hExteriorClient.GetExteriorInfo(dwID)
    if bSet then
        local nGenre = tExteriorInfo.nGenre
        local nSet = tExteriorInfo.nSet
        ExteriorBox.OnSetTryOn(hFrame, nGenre, nSet)
    else
        local nIndex = Exterior_SubToBoxIndex(tExteriorInfo.nSubType)
        ExteriorBox.UpdateExteriorSubBox(hFrame, nIndex, dwID)
        
        FireUIEvent("EXTERIOR_CHARACTER_UPDATE", "ExteriorBox", tRepresentID)
        ExteriorBox.UpdateSureBtnState(hFrame, true)
        
        ExteriorBox.UpdateAllSubPage(hFrame)
    end
end

function ExteriorBox.OnItemMouseEnter()
    local szName = this:GetName()
    local hParent = this:GetParent()
    local szParentName = ""
    if hParent then
        szParentName = hParent:GetName()
    end
    if szName == "Text_Mybutton1" then
        hParent:Lookup("Image_MyButton1_1"):Show()
        ExteriorBox.UpdateSubBtnState(hParent:GetParent())
    elseif szName == "Text_Mybutton2" then
        hParent:Lookup("Image_MyButton2_1"):Show()
        ExteriorBox.UpdateSubBtnState(hParent:GetParent())
     elseif szName == "Text_Tbutton1" then
        hParent:Lookup("Image_TButton1_1"):Show()
        ExteriorBox.UpdateSubBtnState(hParent:GetParent())
     elseif szName == "Text_Tbutton2" then
        hParent:Lookup("Image_TButton2_1"):Show()
        ExteriorBox.UpdateSubBtnState(hParent:GetParent())
     elseif szName == "Text_Tbutton3" then
        hParent:Lookup("Image_TButton3_1"):Show()
        ExteriorBox.UpdateSubBtnState(hParent:GetParent())
    elseif szName == "Image_ListBg1" then
        local hGenre = hParent
        hGenre.bMouseOver = true
        ExteriorBox.UpdateGenreTitle(hGenre)
    elseif szName == "Handle_Set" then
        this.bMouseOver = true
        ExteriorBox.UpdateSetTile(this)
    elseif szName == "Handle_OverViewTitle" or szName == "Handle_LatestBuy" then
        this.bMouseOver = true
        ExteriorBox.UpdateTilte(this)
    elseif szName == "Handle_CardMode" then
        ExteriorBox.UpdateSubBtnState(this)
    elseif szName == "Handle_CollectSub" then
        local szTip = g_tStrings.EXTERIOR_SUB_COLLECT_NUMBER_TIP
        for nSub in pairs(g_tStrings.tExteriorSubName) do
            local tSubCount = ExteriorBox.tAllExteriorBox.tMyInfo.tSubCount
            szTip = szTip .. g_tStrings.tExteriorSub[nSub] .. g_tStrings.STR_COLON .. tSubCount[nSub] .. "\n"
        end
        local x, y = Cursor.GetPos()
        szTip = GetFormatText(szTip)
        OutputTip(szTip, 400, {x, y, 10, 10})
    elseif szParentName == "Handle_Boxes" and this:GetType() == "Box" then
        ExteriorBox.OnMouseEnterSubBox(this)
    elseif szName == "Handle_ViewButton" then
        this:Lookup("Image_MyButton1_1_3"):Show()
    elseif szName == "Box_Item" then
        this:SetObjectMouseOver(1)
    end
end

function ExteriorBox.OnItemMouseLeave()
    local szName = this:GetName()
    local hParent = this:GetParent()
    local szParentName = ""
    if hParent then
        szParentName = hParent:GetName()
    end
    if szName == "Text_Mybutton1" then
        if hParent and hParent:Lookup("Image_MyButton1_1") then
            hParent:Lookup("Image_MyButton1_1"):Hide()
        end
        ExteriorBox.UpdateSubBtnState(hParent:GetParent())
    elseif szName == "Text_Mybutton2" then
        if hParent and hParent:Lookup("Image_MyButton2_1") then
            hParent:Lookup("Image_MyButton2_1"):Hide()
        end
        ExteriorBox.UpdateSubBtnState(hParent:GetParent())
    elseif szName == "Text_Tbutton1" then
        if hParent and hParent:Lookup("Image_TButton1_1") then
            hParent:Lookup("Image_TButton1_1"):Hide()
        end
        ExteriorBox.UpdateSubBtnState(hParent:GetParent())
    elseif szName == "Text_Tbutton2" then
        if hParent and hParent:Lookup("Image_TButton2_1") then 
            hParent:Lookup("Image_TButton2_1"):Hide()
        end
        ExteriorBox.UpdateSubBtnState(hParent:GetParent())
    elseif szName == "Text_Tbutton3" then
        if hParent and hParent:Lookup("Image_TButton3_1") then
            hParent:Lookup("Image_TButton3_1"):Hide()
        end
        ExteriorBox.UpdateSubBtnState(hParent:GetParent())
    elseif szName == "Image_ListBg1" then
        local hGenre = hParent
        hGenre.bMouseOver = false
        ExteriorBox.UpdateGenreTitle(hGenre)
    elseif szName == "Handle_CardMode" then
        ExteriorBox.UpdateSubBtnState(this)
    elseif szName == "Handle_CollectSub" then
        HideTip()
    elseif szName == "Handle_Set" then
        this.bMouseOver = false
        ExteriorBox.UpdateSetTile(this)
    elseif szName == "Handle_OverViewTitle" or szName == "Handle_LatestBuy" then
        this.bMouseOver = false
        ExteriorBox.UpdateTilte(this)
    elseif szParentName == "Handle_Boxes" and this:GetType() == "Box" then
        this:SetObjectMouseOver(0)
        HideTip()
    elseif szName == "Handle_ViewButton" then
        if this:Lookup("Image_MyButton1_1_3") then
            this:Lookup("Image_MyButton1_1_3"):Hide()
        end
    elseif szName == "Box_Item" then
        this:SetObjectMouseOver(0)
    end
end

function ExteriorBox.OnMouseEnterSubBox(hBox)
    local hExteriorClient = GetExterior()
    if not hExteriorClient then
        return
    end
    
    local dwExteriorID = hBox.dwExteriorID
    if dwExteriorID > 0 then
        local tExteriorInfo = hExteriorClient.GetExteriorInfo(dwExteriorID)
        local szTip = Table_GetExteriorSetName(tExteriorInfo.nGenre, tExteriorInfo.nSet)
        szTip = szTip .. g_tStrings.STR_CONNECT .. g_tStrings.tExteriorSubName[tExteriorInfo.nSubType]
        local x, y = hBox:GetAbsPos()
        local w, h = hBox:GetSize()
        szTip = GetFormatText(szTip)
        OutputTip(szTip, 400, {x, y, w, h})
    end
    
    hBox:SetObjectMouseOver(1)
end

function ExteriorBox.UpdateGenreTitle(hGenre)
    local hGenreOver = hGenre:Lookup("Image_ListCover")
    if hGenre.bSelect or hGenre.bMouseOver then
        hGenreOver:Show()
    else
        hGenreOver:Hide()
    end
end

function ExteriorBox.OnCheckBoxCheck()
    local szName = this:GetName()
    if szName == "CheckBox_HideHat" then
        ExteriorBox.HideHat(this:GetRoot(), true)
    elseif ExteriorBox.isFilterTypeCheck(szName) then
        if not ExteriorBox.bInitFilterCheck then
            ExteriorBox.CheckFilterType(this)
        end
    end
end

function ExteriorBox.HideHat(hFrame, bHide)
    local hPlayer = GetClientPlayer()
    if not hPlayer then
        return
    end

    local hExteriorClient = GetExterior()
    if not hExteriorClient then
        return
    end
    
    local tRepresentID = hFrame.tRepresentID
    if not tRepresentID then
        return
    end
    
    hPlayer.HideHat(bHide)
    if bHide then
        tRepresentID[EQUIPMENT_REPRESENT.HELM_STYLE] = 0
    else
        local hBoxHandle = hFrame:Lookup("", "Handle_Boxes")
        local nIndex = Exterior_RepresentToBoxIndex(EQUIPMENT_REPRESENT.HELM_STYLE)
        local hBox = hBoxHandle:Lookup("Box_" .. nIndex)
        if not hBox:IsEmpty() and hBox.dwExteriorID > 0 then
            local tExteriorInfo = hExteriorClient.GetExteriorInfo(hBox.dwExteriorID)
            tRepresentID[EQUIPMENT_REPRESENT.HELM_STYLE] = tExteriorInfo.nRepresentID
        end
    end
    FireUIEvent("PLAYER_HIDE_HAT_CHANGE")
    FireUIEvent("EXTERIOR_CHARACTER_UPDATE", "ExteriorBox", hFrame.tRepresentID)
end

function ExteriorBox.ShowCurrentSet(hFrame)
    local hPlayer = GetClientPlayer()
	if not hPlayer then
		return
	end
    
    hFrame.tRepresentID = hPlayer.GetRepresentID()
    local nCurrentSetID = hPlayer.GetCurrentSetID()
    local tExteriorSet = hPlayer.GetExteriorSet(nCurrentSetID)
    for i = 1, EXTERIOR_SUB_NUMBER do
        local nExteriorSub  = Exterior_BoxIndexToExteriorSub(i)
        local dwExteriorID = tExteriorSet[nExteriorSub]
        ExteriorBox.UpdateExteriorSubBox(hFrame, i, dwExteriorID)
    end
    FireUIEvent("EXTERIOR_CHARACTER_UPDATE", "ExteriorBox", hFrame.tRepresentID)
end

function ExteriorBox.UpdateExteriorSubBox(hFrame, nIndex, dwExteriorID)
    local hPlayer = GetClientPlayer()
    if not hPlayer then
        return 
    end
    local hExteriorClient = GetExterior()
    if not hExteriorClient then
        return
    end
    
    local tRepresentID = hFrame.tRepresentID
    local hBoxHandle = hFrame:Lookup("", "Handle_Boxes")
    local hBox = hBoxHandle:Lookup("Box_" .. nIndex)
    local hTimeWarningImage = hBoxHandle:Lookup("Image_" .. nIndex .. "_Time")
    hBox.dwExteriorID = dwExteriorID
    
    local nRepresentSub = Exterior_BoxIndexToRepresentSub(nIndex)
    local nSubType = Exterior_BoxIndexToSub(nIndex)
    local nRepresentColor = Exterior_RepresentSubToColor(nRepresentSub)
    local tExteriorInfo = hExteriorClient.GetExteriorInfo(dwExteriorID)
    if dwExteriorID > 0 then
        hBox:SetObject(UI_OBJECT_NOT_NEED_KNOWN, 0)
        hBox:SetObjectIcon(tExteriorInfo.nIconID)
        local nTimeType, nTime = hPlayer.IsHaveExterior(dwExteriorID)
        local nCurrentTime = GetCurrentTime()
        
        if nTimeType == EXTERIOR_TIME_TYPE.LIMIT and (nTime - nCurrentTime) < EXTERIOR_BOX_WARNING_TIME then
            hTimeWarningImage:Show()
        else
            hTimeWarningImage:Hide()
        end
        if hPlayer.IsHaveExterior(dwExteriorID) then
            hBox:EnableObject(true)
        else
            hBox:EnableObject(false)
        end
    else
        hTimeWarningImage:Hide()
        hBox:ClearObject()
        hBox:SetOverText(0, "")
    end
    local nEquipSub = Exterior_RepresentSubToEquipSub(nRepresentSub)
    local hItem = GetPlayerItem(hPlayer, INVENTORY_INDEX.EQUIP, nEquipSub)
    if not hItem or  dwExteriorID > 0 then
        if not hPlayer.bHideHat or nSubType ~= EQUIPMENT_SUB.HELM then
            tRepresentID[nRepresentSub] = tExteriorInfo.nRepresentID
            tRepresentID[nRepresentColor] = tExteriorInfo.nColorID
        end
    else
        if not hPlayer.bHideHat or nSubType ~= EQUIPMENT_SUB.HELM then
            tRepresentID[nRepresentSub] = hItem.nRepresentID
            tRepresentID[nRepresentColor] = hItem.nColorID
        end
    end
end

function ExteriorBox.OnCheckBoxUncheck()
    local szName = this:GetName()
    if szName == "CheckBox_HideHat" then
         ExteriorBox.HideHat(this:GetRoot(), false)
    end
end

function ExteriorBox.isFilterTypeCheck(szName)
    for szCheckName in pairs(tFilterTypeCheck) do
        if szCheckName == szName then
            return true
        end
    end
    return false
end

function ExteriorBox.CheckMyBox(hCheck)
    local hPage = hCheck:GetParent()
    local hList = hPage:Lookup("", "Handle_List")
    local nCount = hList:GetItemCount()
    local hSelect = nil
    for i = 0, nCount - 1 do
        local hGenre = hList:Lookup(i)
        if not hGenre.bOverView then
            ExteriorBox.UpdateGenreList(hGenre, hGenre.tGenre, ExteriorBox.bFilterMyBox)
            if hGenre.bSelect then
                hSelect = hGenre
            end
        end
    end
    
    hList:FormatAllItemPos()
    if hSelect then
        ExteriorBox.SelectGenre(hSelect, hSelect.bExpend)
    end
end

function ExteriorBox.CheckFilterType(hCheck)
    local hWndBox = hCheck:GetParent()
    for szCheckName, nFilterSubType in pairs(tFilterTypeCheck) do
        local hCheckFilter = hWndBox:Lookup(szCheckName)
        if hCheckFilter == hCheck then 
            ExteriorBox.nFilterSubType = nFilterSubType
        else
            hCheckFilter:Check(false)
        end
    end
    if hWndBox.bLatestBuy then
        ExteriorBox.UpdateLatestBuyPage(hWndBox)
    else
        ExteriorBox.UpdateBoxPage(hWndBox)
    end
end

function ExteriorBox.InitFrame(hFrame)
    local hPlayer = GetClientPlayer()
    if not hPlayer then
        return
    end
    RegisterExteriorCharacter("ExteriorBox", "Normal/ExteriorBox", "Scene_Role", "Btn_TurnLeft", "Btn_TurnRight", true)
    ExteriorBox.ShowCurrentSet(hFrame)
    HairShop_InitHairs()
    local hWndHair = hFrame:Lookup("Wnd_Hair")
    --hWndHair:Hide()
    
    local hCheckBoxHair = hFrame:Lookup("PageSet_Goods/CheckBox_Hair")
    hCheckBoxHair:Hide()
    local hCheckBoxMy = hFrame:Lookup("PageSet_Goods/Page_Clothes/CheckBox_My")
    hCheckBoxMy:Hide()
    
    hFrame:Lookup("CheckBox_HideHat"):Check(hPlayer.bHideHat)
    local nFaceID, nHeadID, nBangID, nPlaitID = HairShop_GetCurrentHairID()
    local nHeadUIID = HairShop_GetHairUIID("Head", nHeadID)
    local hHandleTotal = hFrame:Lookup("", "")
    local hHead = hHandleTotal:Lookup("Text_Head")
    hHead:SetText(nHeadUIID)
    local nBangUIID = HairShop_GetHairUIID("Bang", nBangID)
    local hBang = hHandleTotal:Lookup("Text_Bang")
    hBang:SetText(nBangUIID)
    local nPlaitUIID = HairShop_GetHairUIID("Plait", nPlaitID)
    local hPlait = hHandleTotal:Lookup("Text_Plait")
    hPlait:SetText(nPlaitUIID)
    local nFaceUIID = HairShop_GetHairUIID("Face", nFaceID)
    local hFace = hHandleTotal:Lookup("Text_Face")
    hFace:SetText(nFaceUIID)
    ExteriorBox.UpdateSureBtnState(hFrame, false)
    
    ExteriorBox.UpdateMyMoney(hFrame)
end

function ExteriorBox.ShowPlayer(hFrame)
    local hPlayer = GetClientPlayer()
	if not hPlayer then
		return
	end

    if not hFrame.tRepresentID then
        hFrame.tRepresentID = hPlayer.GetRepresentID()
    end
    FireUIEvent("EXTERIOR_CHARACTER_UPDATE", "ExteriorBox", hFrame.tRepresentID)
end

function ExteriorBox.UpdateTitle(hItem)
	local hImage = hItem:Lookup(1)
	if hItem.bSelect then
		hImage:Show()
	elseif hItem.bMouse then
		hImage:Show()
	else
		hImage:Hide()
	end
end

function ExteriorBox.GetSelectSubArray(tSubArray, nFilterSubType, nStartIndex, nEndIndex)
    if nFilterSubType == 0 then
        return tSubArray, nStartIndex, nEndIndex
    end
    local hExteriorClient = GetExterior()
    if not hExteriorClient then
        return
    end
    
    local tArray = {}
    for i = nStartIndex, nEndIndex do
        local dwID = tSubArray[i]
        local tExteriorInfo = hExteriorClient.GetExteriorInfo(dwID)
        local nSubType = tExteriorInfo.nSubType
        if nFilterSubType == nSubType then
            table.insert(tArray, dwID)
        end
    end
    return tArray, 1, #tArray
end

function ExteriorBox.UpdatePageState(hPage, nPage, nTotalPage, bOverView)
    local hText
    local hBtnPrev
    local hBtnNext
    if bOverView then
        hText = hPage:Lookup("", "Text_TPageNum")
        hBtnPrev = hPage:Lookup("Btn_TPagePrev")
        hBtnNext = hPage:Lookup("Btn_TPageNext")
    else
        hText = hPage:Lookup("", "Text_PageNum")
        hBtnPrev = hPage:Lookup("Btn_PagePrev")
        hBtnNext = hPage:Lookup("Btn_PageNext")
    end
    hText:SetText(nPage .. "/" .. nTotalPage)
    if nPage <= 1 then
        hBtnPrev:Enable(false)
    else
        hBtnPrev:Enable(true)
    end
    if nPage >= nTotalPage then
        hBtnNext:Enable(false)
    else
        hBtnNext:Enable(true)
    end
end

function ExteriorBox.UpdateBoxPageList(hPage, nPage)
    local tSubArray = hPage.tSelectArray
    local nCount = hPage.nEndIndex - hPage.nStartIndex + 1
    if nCount < 0 then
        nCount = 0
    end
    local nTotalPage = math.ceil(nCount / SUB_MAX_COUNT_FOR_ONE_PAGE)
    if nPage < 1 then
        nPage = 1
    elseif nPage > nTotalPage then
        nPage = nTotalPage 
    end
    hPage.nPage = nPage
    ExteriorBox.UpdatePageState(hPage, nPage, nTotalPage, false)
    local nStartIndex = hPage.nStartIndex + (nPage - 1) * SUB_MAX_COUNT_FOR_ONE_PAGE
    local nEndIndex = nStartIndex + SUB_MAX_COUNT_FOR_ONE_PAGE - 1
    if nEndIndex > hPage.nEndIndex then
        nEndIndex = hPage.nEndIndex
    end
    
    local hList = hPage:Lookup("", "Handle_Content")
    hList:Clear()
    if nStartIndex > 0 and nStartIndex <= nEndIndex then
        for i = nStartIndex, nEndIndex do
            local dwID = tSubArray[i]
            local hSubInfo = hList:AppendItemFromIni(INI_FILE, "Handle_CardMode")
            
            ExteriorBox.UpdateSubInfo(hSubInfo, dwID)
        end
    end
    hList:FormatAllItemPos()
end

function ExteriorBox.IsSubTryOn(hFrame, dwExteriorID)
    if dwExteriorID <= 0 then
        return false
    end
    local hBoxHandle = hFrame:Lookup("", "Handle_Boxes")
    for i = 1, EXTERIOR_SUB_NUMBER do
        local hBox = hBoxHandle:Lookup("Box_" .. i)
        if hBox.dwExteriorID == dwExteriorID then
            return true
        end
    end
    
    return false
end

function ExteriorBox.UpdateSubInfo(hSubInfo, dwID)
    local hExteriorClient = GetExterior()
    if not hExteriorClient then
        return
    end
    
    local hPlayer = GetClientPlayer()
    if not hPlayer then
        return hPlayer
    end
    
    local hFrame = hSubInfo:GetRoot()
    hSubInfo.dwID = dwID
    local tExteriorInfo = hExteriorClient.GetExteriorInfo(dwID)
    local szSetName = Table_GetExteriorSetName(tExteriorInfo.nGenre, tExteriorInfo.nSet)
    hSubInfo:Lookup("Text_Name"):SetText(szSetName .. g_tStrings.STR_CONNECT .. g_tStrings.tExteriorSubName[tExteriorInfo.nSubType])
    hSubInfo:Lookup("Text_ItemName"):SetText(g_tStrings.tExteriorSub[tExteriorInfo.nSubType])
    local tMyBoxMap = ExteriorBox.tAllExteriorBox.tMyInfo.tMyBoxMap
    local szText = ""
    local hTime = hSubInfo:Lookup("Text_Date")
    local hImageNotOwn = hSubInfo:Lookup("Image_NotOwn")
    local hBox = hSubInfo:Lookup("Box_Item")
    hBox:SetObject(UI_OBJECT_NOT_NEED_KNOWN, 0)
    hBox:SetObjectIcon(tExteriorInfo.nIconID)
    local nTimeType, nTime = hPlayer.IsHaveExterior(dwID)
    local bShowNew = false
    if nTimeType then
        hTime:SetFontScheme(18)
        if nTimeType == EXTERIOR_TIME_TYPE.PERMANENT then
            szText = g_tStrings.EXTERIOR_HAVE_PERMANENT
        else
            local nLeftTime = nTime - GetCurrentTime()
            if nLeftTime < 0 then
                nLeftTime = 0
            end
            if nLeftTime < EXTERIOR_BOX_WARNING_TIME then
                hTime:SetFontScheme(111)
            end
            szText = GetTimeText(nLeftTime, nil, true)
            szText = FormatString(g_tStrings.EXTERIOR_HAVE, szText)
        end
       
        hImageNotOwn:Hide()
        hSubInfo.nTimeType = nTimeType
        if nTimeType == EXTERIOR_TIME_TYPE.LIMIT then
            bShowNew = true
        end
    else
       szText = g_tStrings.EXTERIOR_NOT_HAVE
       hImageNotOwn:Show()
       hTime:SetFontScheme(111)
    end
    hTime:SetText(szText)
    hSubInfo.bShowNew = bShowNew
    if bShowNew then
        hSubInfo:Lookup("Handle_Button"):Hide()
        hSubInfo:Lookup("Handle_TButton"):Show()
    else
        hSubInfo:Lookup("Handle_Button"):Show()
        hSubInfo:Lookup("Handle_TButton"):Hide()
    end
    hInTryOn = hSubInfo:Lookup("Animate_HighLight")
    if ExteriorBox.IsSubTryOn(hFrame, dwID) then
        hInTryOn:Show()
    else
        hInTryOn:Hide()
    end
    ExteriorBox.UpdateSubBtnState(hSubInfo)
end

function ExteriorBox.UpdateSubBtnState(hSubInfo)
    local hButton
    if hSubInfo.bShowNew then
        hButton = hSubInfo:Lookup("Handle_TButton")
    else
        hButton = hSubInfo:Lookup("Handle_Button")
    end
    
    local nX, nY = Cursor.GetPos()
    local bPtInHandle = hSubInfo:PtInItem(nX, nY)
    if bPtInHandle then
        hSubInfo.bMouseOver = true
    else
        hSubInfo.bMouseOver = false
    end
    
    if hSubInfo.bMouseOver then
        hButton:Show()
    else
        hButton:Hide()
    end

end

function ExteriorBox.GetBoxCount(nGenre, nSet)
    local nMyCount = 0
    local nTotalCount = 0
    if nGenre == 0 and nSet == 0 then
        nTotalCount = ExteriorBox.tAllExteriorBox.tAllInfo.nTotalCount
        nMyCount = ExteriorBox.tAllExteriorBox.tMyInfo.nTotalCount
    else
        nTotalCount = ExteriorBox.tAllExteriorBox.tAllInfo.tCountMap[nGenre][nSet]
        nMyCount = ExteriorBox.tAllExteriorBox.tMyInfo.tCountMap[nGenre][nSet]
    end
    
    return nMyCount, nTotalCount
end

function ExteriorBox.OnMyExteriorBoxUpdate()
    local hPlayer = GetClientPlayer()
    if not hPlayer then
        return
    end
    local hExteriorClient = GetExterior()
    if not hExteriorClient then
        return
    end
    --local tMyBoxMap = {[15] = 1200, [1] = 0, [16] = 1300, [18] = 0, [3] = 0, [8] = 0}
    local tMyBoxMap = hPlayer.GetAllExterior()
    local tMySubArray = {}
    local nTotalCount = 0
    local nTotalPermanent = 0
    local tMyCountMap = {}
    local tMyInfo = {}
    local tGenreCount = {}
    local tTimeLimitSub = {}
    local tSubCount = {
        [EQUIPMENT_SUB.HELM] = 0,  -- 头部
        [EQUIPMENT_SUB.CHEST] = 0, -- 上衣
        [EQUIPMENT_SUB.BANGLE] = 0,  -- 护手
        [EQUIPMENT_SUB.WAIST] = 0, -- 腰带
        [EQUIPMENT_SUB.BOOTS] = 0 ,-- 鞋子
    }
    tAllExteriorBox = ExteriorBox.tAllExteriorBox
    tAllExteriorBox.tMyInfo = tMyInfo
    tMyInfo.tCountMap = tMyCountMap
    tMyInfo.tSubArray = tMySubArray
    tMyInfo.tGenreCount = tGenreCount
    tMyInfo.tMyBoxMap = tMyBoxMap
    tMyInfo.tTimeLimitSub = tTimeLimitSub
    tMyInfo.tSubCount = tSubCount
    for _, tGenre in ipairs(tAllExteriorBox.tGenres) do
        local tMyGenreInfo = {}
        local nGenre = tGenre.nGenre
        tMyGenreInfo.nTotalCount = 0
        tMyGenreInfo.nStartIndex = nTotalCount + 1
        tMyGenreInfo.nEndIndex = -1
        tGenre.tMyInfo = tMyGenreInfo
        tMyCountMap[nGenre] = {}
        tMyCountMap[nGenre][0] = 0
        tGenreCount[nGenre] = 0
        for _, tSet in ipairs(tGenre.tSetArray) do
            local nSet = tSet.nSet
            local nStartIndex = tSet.tAllInfo.nStartIndex
            local nEndIndex = tSet.tAllInfo.nEndIndex
            local tMySetInfo = {}
            tMySetInfo.nStartIndex = nTotalCount + 1
            tMySetInfo.nEndIndex = -1
            tMySetInfo.nTotalCount = 0
            tSet.tMyInfo = tMySetInfo
            local nCount = 0
            local nPermanentGenreCount = 0
            for i = nStartIndex, nEndIndex do
                local dwID = tAllExteriorBox.tAllInfo.tSubArray[i]
                --local dwID = tSub[1]
                local tExteriorInfo = hExteriorClient.GetExteriorInfo(dwID)
                if tMyBoxMap[dwID] then
                    -- TODO 收集限时装备
                    
                    if tMyBoxMap[dwID].nTimeType == EXTERIOR_TIME_TYPE.LIMIT then
                        table.insert(tTimeLimitSub, {dwID, tMyBoxMap[dwID].nEndTime})
                    end
                    nCount = nCount + 1
                    if tMyBoxMap[dwID].nTimeType == EXTERIOR_TIME_TYPE.PERMANENT then
                        nPermanentGenreCount = nPermanentGenreCount + 1
                        local nSubType = tExteriorInfo.nSubType
                        if not tSubCount[nSubType] then
                            tSubCount[nSubType] = 0
                        end
                        tSubCount[nSubType] = tSubCount[nSubType] + 1
                        nTotalPermanent = nTotalPermanent + 1
                    end
                    table.insert(tMySubArray, dwID)
                    nTotalCount = nTotalCount + 1
                    tMySetInfo.nEndIndex = nTotalCount
                    tMyGenreInfo.nEndIndex = nTotalCount
                  
                end
            end
            if nPermanentGenreCount == nEndIndex - nStartIndex + 1 then
                tGenreCount[nGenre] = tGenreCount[nGenre] + 1
            end
            tMySetInfo.nTotalCount = nCount
            tMyGenreInfo.nTotalCount = tMyGenreInfo.nTotalCount + nCount
            tMyCountMap[nGenre][0] = tMyGenreInfo.nTotalCount
            tMyCountMap[nGenre][nSet] = nCount
        end
    end
    tMyInfo.nTotalCount = nTotalCount
    tMyInfo.nTotalPermanent = nTotalPermanent
    local fnTimeLimitCompare = function(tLeft, tRight)
        return tLeft[2] < tRight[2]
    end
    table.sort(tTimeLimitSub, fnTimeLimitCompare)
end

function ExteriorBox.InitAllBoxInfo()
    if not ExteriorBox.tAllExteriorBox then
        ExteriorBox.tAllExteriorBox = Table_GetAllExteriorBox()
    end
    ExteriorBox.OnMyExteriorBoxUpdate()
end

function ExteriorBox.UpdateLatestBuyPage(hWndBox)
    local hPlayer = GetClientPlayer()
    if not hPlayer then
        return
    end
    
    local nFilterSubType = ExteriorBox.nFilterSubType
    local tSubArray = hPlayer.GetLatestBuyExterior()
    local nStartIndex = 1
    local nEndIndex = #tSubArray
    hWndBox.tSelectArray, hWndBox.nStartIndex, hWndBox.nEndIndex = ExteriorBox.GetSelectSubArray(tSubArray, nFilterSubType, nStartIndex, nEndIndex)
    ExteriorBox.UpdateBoxPageList(hWndBox, 1)
end

function ExteriorBox.UpdateBoxPage(hWndBox)
    local bMy = ExteriorBox.bFilterMyBox
    local nFilterSubType = ExteriorBox.nFilterSubType
    local tSubArray 
    local tSelectInfo = {}
    if bMy then
        tSubArray = ExteriorBox.tAllExteriorBox.tMyInfo.tSubArray
        tSelectInfo = ExteriorBox.tSelectMyInfo
    else
        tSelectInfo = ExteriorBox.tSelectAllInfo
        tSubArray = ExteriorBox.tAllExteriorBox.tAllInfo.tSubArray
    end
    local nStartIndex = tSelectInfo.nStartIndex
    local nEndIndex = tSelectInfo.nEndIndex
    hWndBox.tSelectArray, hWndBox.nStartIndex, hWndBox.nEndIndex = ExteriorBox.GetSelectSubArray(tSubArray, nFilterSubType, nStartIndex, nEndIndex)
    ExteriorBox.UpdateBoxPageList(hWndBox, 1)
end

function ExteriorBox.SelectOverView(hOverViewTitle)
    local hList = hOverViewTitle:GetParent()
    
    local hLatestBuy = hList:Lookup("Handle_LatestBuy")
    hLatestBuy.bSelect = false
    ExteriorBox.UpdateTilte(hLatestBuy)
    
    local hGenreList = hList:GetParent():Lookup("Handle_List")
    ExteriorBox.UnSelectAllGenre(hGenreList)
    
    local hPageClothes = hList:GetParent():GetParent()
    ExteriorBox.ShowHomePage(hPageClothes, true)
    
    hOverViewTitle.bSelect = true
    ExteriorBox.UpdateTilte(hOverViewTitle)
end

function ExteriorBox.SelectLatestBuy(hLatestBuy)
    local hList = hLatestBuy:GetParent()
    local hOverViewTitle = hList:Lookup("Handle_OverViewTitle")
    hOverViewTitle.bSelect = false
    ExteriorBox.UpdateTilte(hOverViewTitle)
    
    local hGenreList = hList:GetParent():Lookup("Handle_List")
    ExteriorBox.UnSelectAllGenre(hGenreList)
    
    local hPageClothes = hList:GetParent():GetParent()
    local hWndBox = hPageClothes:Lookup("Wnd_Box")
   
    hLatestBuy.bSelect = true
    ExteriorBox.UpdateTilte(hLatestBuy)
    
    hWndBox.bLatestBuy = true
    ExteriorBox.ShowHomePage(hPageClothes, false)
    ExteriorBox.InitFilterCheck(hWndBox, true)
    ExteriorBox.UpdateLatestBuyPage(hWndBox)
end

function ExteriorBox.UpdateTilte(hTitle)
    hOver = hTitle:Lookup(0)
    if hTitle.bSelect or hTitle.bMouseOver then
        hOver:Show()
    else
        hOver:Hide()
    end
end

function ExteriorBox.UnSelectAllGenre(hList)
    local nCount = hList:GetItemCount()
    for i = 0, nCount - 1 do
        hGenre = hList:Lookup(i)
        hGenre.bSelect = false
        ExteriorBox.UnSelectGenreAllSet(hGenre)
        ExteriorBox.UpdateGenreSize(hGenre, hGenre.bExpend)
    end
    hList:FormatAllItemPos()
    FireUIEvent("SCROLL_UPDATE_LIST", "Handle_List", "ExteriorBox", false)
end

function ExteriorBox.UnSelectOverView(hPageClothes)
    local hList = hPageClothes:Lookup("", "Handle_List1")
    
    local hOverViewTitle = hList:Lookup("Handle_OverViewTitle")
    hOverViewTitle.bSelect = false
    ExteriorBox.UpdateTilte(hOverViewTitle)
    
    local hLatestBuy = hList:Lookup("Handle_LatestBuy")
    hLatestBuy.bSelect = false
    ExteriorBox.UpdateTilte(hLatestBuy)
end

function ExteriorBox.SelectGenre(hSelect, bExpend)
    local hList = hSelect:GetParent()
    ExteriorBox.UnSelectAllGenre(hList)
    local hPageClothes = hList:GetParent():GetParent()
    ExteriorBox.UnSelectOverView(hPageClothes)
    hSelect.bSelect = true
    hSelect.bExpend = bExpend
    ExteriorBox.UpdateGenreSize(hSelect, hSelect.bExpend)
    hList:FormatAllItemPos()
    FireUIEvent("SCROLL_UPDATE_LIST", "Handle_List", "ExteriorBox", false)
    local hWndBox = hPageClothes:Lookup("Wnd_Box")
    ExteriorBox.ShowHomePage(hPageClothes, false)
    hWndBox.bLatestBuy = false
    local tGenre = hSelect.tGenre
    ExteriorBox.tSelectAllInfo = tGenre.tAllInfo
    ExteriorBox.tSelectMyInfo = tGenre.tMyInfo
    ExteriorBox.InitFilterCheck(hWndBox, true)
    ExteriorBox.UpdateBoxPage(hWndBox)
    ExteriorBox.UnSelectGenreAllSet(hSelect)
end

function ExteriorBox.ShowHomePage(hPageClothes, bHome)
    local hWndOverView = hPageClothes:Lookup("Wnd_OverView")
    local hWndBox = hPageClothes:Lookup("Wnd_Box")
    
    if bHome then
        hWndBox:Hide()
        hWndOverView:Show()
    else
         hWndBox:Show()
        hWndOverView:Hide()
    end
end

function ExteriorBox.UnSelectGenreAllSet(hGenre)
    local hList = hGenre:Lookup("Handle_SetList")
    local nCount = hList:GetItemCount()
    for i = 0, nCount - 1 do
        hSet = hList:Lookup(i)
        if hSet.bSelect then
            hSet.bSelect = false
            ExteriorBox.UpdateSetTile(hSet)
        end
    end
end

function ExteriorBox.SelectSet(hSet)
    
    local hList = hSet:GetParent()
    local hGenreList = hList:GetParent():GetParent()
    ExteriorBox.UnSelectAllGenre(hGenreList)
    hPageClothes = hList:GetParent():GetParent():GetParent():GetParent()
    local hWndBox = hPageClothes:Lookup("Wnd_Box")
    local tSet = hSet.tSet
    ExteriorBox.tSelectAllInfo = tSet.tAllInfo
    ExteriorBox.tSelectMyInfo = tSet.tMyInfo
    ExteriorBox.InitFilterCheck(hWndBox, false)
    ExteriorBox.UpdateBoxPage(hWndBox)
    hSet.bSelect = true
    ExteriorBox.UpdateSetTile(hSet)
    
    hWndBox.bLatestBuy = false
    ExteriorBox.ShowHomePage(hPageClothes, false)
    ExteriorBox.UnSelectOverView(hPageClothes)
end

function ExteriorBox.UpdateSetTile(hSet)
    if hSet.bSelect or hSet.bMouseOver then
        hSet:Lookup("Image_Cover"):Show()
    else
        hSet:Lookup("Image_Cover"):Hide()
    end
end

function ExteriorBox.UpdateMyMoney(hFrame)
    local hPlayer = GetClientPlayer()
    if not hPlayer then
        return
    end
    local hPageClothes = hFrame:Lookup("PageSet_Goods/Page_Clothes")
    local hWndOverView = hPageClothes:Lookup("Wnd_OverView")
    local hFreeCount = hWndOverView:Lookup("", "Text_FreeTNum")
    local nExteriorFreeCount = hPlayer.GetExteriorFreeCount()
    hFreeCount:SetText(nExteriorFreeCount)

    local hPageHair = hFrame:Lookup("Wnd_Hair")
    local nHairFreeCount = hPlayer.GetHairFreeCount()
    local hFreeCountText = hPageHair:Lookup("", "Text_FreeNum_0")
    hFreeCountText:SetText(nHairFreeCount)
end

function ExteriorBox.UpdateOverViewPage(hFrame)
    local hPlayer = GetClientPlayer()
    if not hPlayer then
        return
    end
    local hPageClothes = hFrame:Lookup("PageSet_Goods/Page_Clothes")
    local hWndOverView = hPageClothes:Lookup("Wnd_OverView")
    ExteriorBox.UpdateOverViewCollect(hWndOverView)
    ExteriorBox.UpdateOverViewTimePage(hWndOverView, 1)
    local hOverViewTitle = hPageClothes:Lookup("", "Handle_List1/Handle_OverViewTitle")
    local hLatestBuy = hPageClothes:Lookup("", "Handle_List1/Handle_LatestBuy")
    
    local tLatestBuySubArray = hPlayer.GetLatestBuyExterior()
    if #tLatestBuySubArray > 0 then
        ExteriorBox.SelectLatestBuy(hLatestBuy)
    else
        ExteriorBox.SelectOverView(hOverViewTitle)
    end
end

function ExteriorBox.UpdateOverViewCollect(hWndOverView)
    local hCollectContent = hWndOverView:Lookup("", "Handle_CollectContent")
    hCollectContent:Clear()
    local tMyInfo = ExteriorBox.tAllExteriorBox.tMyInfo
    for i, tGenre in ipairs(ExteriorBox.tAllExteriorBox.tGenres) do
        local hCollect = hCollectContent:AppendItemFromIni(INI_FILE, "Handle_CollectMode")
        local szName = tGenre.szName
        local nCount = tMyInfo.tGenreCount[tGenre.nGenre]
        local szDivide = "Normal"
        if nCount > 0 then
            for j = #tCollectDivide, 1, -1 do
                local tDivide = tCollectDivide[j]
                if nCount >= tDivide[1] then
                    szDivide = tDivide[2]
                    break
                end
            end
        end
        local nFrame = tCollectFrame[tGenre.nGenre][szDivide]
        hCollect:Lookup("Image_SCardBg"):SetFrame(nFrame)
        hCollect:Lookup("Text_TotleNum"):SetText(FormatString(g_tStrings.EXTERIOR_SET_COLLECT_NUMBER, nCount))
    end
    local hCollect = hCollectContent:AppendItemFromIni(INI_FILE, "Handle_CollectMode", "Handle_CollectSub")
    local nCount = tMyInfo.nTotalPermanent
    hCollect:Lookup("Image_SCardBg"):SetFrame(9)
    hCollect:Lookup("Text_TotleNum"):SetText(FormatString(g_tStrings.EXTERIOR_SUB_COLLECT_NUMBER, nCount))
    hCollectContent:FormatAllItemPos()
end

function ExteriorBox.UpdateOverViewTimePage(hWndOverView, nPage)
    local tMyInfo = ExteriorBox.tAllExteriorBox.tMyInfo
    local hTimeContent = hWndOverView:Lookup("", "Handle_TimeContent")
    hTimeContent:Clear()
    local nCount = #tMyInfo.tTimeLimitSub

    local nTotalPage = math.ceil(nCount / SUB_MAX_COUNT_FOR_TIME_PAGE)
    if nPage < 1 then
        nPage = 1
    elseif nPage > nTotalPage then
        nPage = nTotalPage 
    end
    hWndOverView.nPage = nPage
    if nCount > 0 then
        local nStart = (nPage - 1 ) * SUB_MAX_COUNT_FOR_TIME_PAGE + 1
        local nEnd = nPage * SUB_MAX_COUNT_FOR_TIME_PAGE
        if nEnd > nCount then
            nEnd = nCount
        end
        for i = nStart, nEnd do
            local tSub = tMyInfo.tTimeLimitSub[i]
            local hSubInfo = hTimeContent:AppendItemFromIni(INI_FILE, "Handle_CardMode")
            ExteriorBox.UpdateSubInfo(hSubInfo, tSub[1])
        end
    else
        hTimeContent:AppendItemFromString(GetFormatText(g_tStrings.EXTERIOR_NOT_HAVE_TIME_SUB))
    end
    ExteriorBox.UpdatePageState(hWndOverView, nPage, nTotalPage, true)
    hTimeContent:FormatAllItemPos()
end

function ExteriorBox.UpdateClothesList(hFrame)
    ExteriorBox.InitAllBoxInfo()
    local hPage = hFrame:Lookup("PageSet_Goods/Page_Clothes")
    local hList = hPage:Lookup("", "Handle_List")
    hList:Clear()
    --ExteriorBox.AddOverViewCloseList(hList)
    ExteriorBox.InitMyFilterCheck(hPage)
    for i, tGenre in ipairs(ExteriorBox.tAllExteriorBox.tGenres) do
        local hGenre = hList:AppendItemFromIni(INI_FILE_BOX_LIST, "Handle_Genre")
        hGenre.bOverView = false
        ExteriorBox.UpdateGenreList(hGenre, tGenre, ExteriorBox.bFilterMyBox)
        hGenre.tGenre = tGenre
    end
    hList:FormatAllItemPos()
    local nCount = hList:GetItemCount()
    ExteriorBox.SelectGenre(hList:Lookup(nCount - 1), true)
    FireUIEvent("SCROLL_UPDATE_LIST", "Handle_List", "ExteriorBox", true)
end

function ExteriorBox.InitFilterCheck(hWndBox, bEnable)
    ExteriorBox.bInitFilterCheck = true
    local hCheckAll = hWndBox:Lookup("CheckBox_All")
    hCheckAll:Check(true)
    ExteriorBox.nFilterSubType = 0
    for szCheckName in pairs(tFilterTypeCheck) do
        local hCheckFilter = hWndBox:Lookup(szCheckName)
        if hCheckFilter ~=  hCheckAll then
            hCheckFilter:Check(false)
        end
        hCheckFilter:Enable(bEnable)
    end
    ExteriorBox.bInitFilterCheck = false
end

function ExteriorBox.InitMyFilterCheck(hPageExterior)
    ExteriorBox.bMyFilterInit = true
    local hCheckMy = hPageExterior:Lookup("CheckBox_My")
    hCheckMy:Check(ExteriorBox.bFilterMyBox)
    ExteriorBox.bMyFilterInit = false
end

function ExteriorBox.GetSetFont(nGenre, nSet, nMyCount, nTotalCount)
    local hPlayer = GetClientPlayer()
    if not hPlayer then
        return
    end
    local nFont = 18
    if nMyCount == nTotalCount then
        local bNotPermanent = false
        local tSet = Table_GetExteriorSet(nGenre, nSet)
        for i = 1, EXTERIOR_SUB_NUMBER do
            local dwExteriorID = tSet["nSub" .. i]
            if dwExteriorID > 0 then
                local nTimeType, nTime = hPlayer.IsHaveExterior(dwExteriorID)
                if nTimeType ~= EXTERIOR_TIME_TYPE.PERMANENT then
                    bNotPermanent = true
                end
            end
        end
        if bNotPermanent then
            nFont = 206
        else
            nFont = 112
        end
    elseif nMyCount > 0 then
        return 18
    end
    return nFont
end

function ExteriorBox.UpdateGenreList(hGenre, tGenre, bMy)
    hGenre:Lookup("Text_ListTitle"):SetText(tGenre.szName)
    local hSetList = hGenre:Lookup("Handle_SetList")
    hSetList:Clear()
    local tSetMap = ExteriorBox.tAllExteriorBox.tSetMap
    local tSetArray = tGenre.tSetArray or {}
    for i, tSet in ipairs(tSetArray) do
        local nSet = tSet.nSet
        local nMyCount, nTotalCount = ExteriorBox.GetBoxCount(tGenre.nGenre, nSet)
        if not bMy or nMyCount > 0 then
            local hSet = hSetList:AppendItemFromIni(INI_FILE_BOX_LIST, "Handle_Set")
            local szText = tSetMap[nSet][1]
            hSet.tSet = tSet
            hSet.nGenre = tGenre.nGenre
            hSet.nSet = nSet
            szText = szText .. " " .. nMyCount .. "/" .. nTotalCount
            local hSetName = hSet:Lookup("Text_Set")
            hSetName:SetText(szText)
            local nFont = ExteriorBox.GetSetFont(tGenre.nGenre, nSet, nMyCount, nTotalCount)
            hSetName:SetFontScheme(nFont)
        end
    end
    hSetList:FormatAllItemPos()
    hSetList:SetSizeByAllItemSize()
    if bMy then
        hGenre.bExpend = true
    end
    ExteriorBox.UpdateGenreSize(hGenre, hGenre.bExpend)
end

function ExteriorBox.UpdateGenreSize(hGenre, bExpend)
    local hSetList = hGenre:Lookup("Handle_SetList")
    --local hGenreBgOver = hGenre:Lookup("Image_ListBg2")
    local hGenreTitleOver = hGenre:Lookup("Image_ListCover")
    local hImageMinize = hGenre:Lookup("Image_Minimize")
    local nWidth, nHeight = hGenre:GetSize()
    local nPosX, nPosY = hSetList:GetRelPos()
    hGenre.bExpend = bExpend
    if hGenre.bSelect then
        hGenreTitleOver:Show()
    else
        hGenreTitleOver:Hide()
    end
    if bExpend then
        hSetList:FormatAllItemPos()
        hSetList:SetSizeByAllItemSize()
        local _, nSetHeight = hSetList:GetSize()
        nHeight = nPosY + nSetHeight + 15
        hSetList:Show()
        --hGenreBgOver:Show()
        --hGenreBgOver:SetSize(nWidth, nHeight)
        hImageMinize:SetFrame(tExpendFrame.Expand)
    else
        hSetList:SetSize(0, 0)
        hSetList:Hide()
        --hGenreBgOver:SetSize(0, 0)
        --hGenreBgOver:Hide()
        _, nHeight = hGenreTitleOver:GetSize()
        hImageMinize:SetFrame(tExpendFrame.Normal)
    end
    hGenre:SetSize(nWidth, nHeight)
end

function ExteriorBox.UpdateHairPage(hFrame)
    local hPlayer = GetClientPlayer()
	if not hPlayer then
		return
	end
    
    local hHairShopClient = GetHairShop()
	if not hHairShopClient then
		return 
	end
    
    --local hPageHair = hFrame:Lookup("PageSet_Goods/Page_Hair")
    local hPageHair = hFrame:Lookup("Wnd_Hair")
    
	local tRepresentID = hPlayer.GetRepresentID()
	local nSelfHairID = tRepresentID[EQUIPMENT_REPRESENT.HAIR_STYLE]
	local nSelfFaceID = tRepresentID[EQUIPMENT_REPRESENT.FACE_STYLE]
    local tHair = hPlayer.GetAllHair(HAIR_STYLE.HAIR)
    local tHead = {}
    local tBang = {}
    local tPlait = {}
    local nSelfHeadIndex = 0
    local nSelfBangIndex = 0
    local nSelfPlaitIndex = 0
    local nSelfFaceIndex = 0
    local tTempHair = {}
    for _, nHairID in ipairs(tHair) do
        local nHeadID, nBangID, nPlaitID = hHairShopClient.GetHairIndex(nHairID)
        table.insert(tTempHair, {nHeadID, nBangID, nPlaitID, nHairID})
    end
    local fnSortCompare = function(tLeft, tRight)
        if tLeft[1] == tRight[1] then
            if tLeft[2] == tRight[2] then
                return tLeft[3] < tRight[3]
            end
            return tLeft[2] < tRight[2]
        end
        return tLeft[1] < tRight[1]
    end
    table.sort(tTempHair, fnSortCompare)
    local nLastHeadID = -1
    local nLastBangID = -1
    local nLastPlaitID = -1
    for _, tIndex in ipairs(tTempHair) do
        nHeadID = tIndex[1]
        nBangID = tIndex[2]
        nPlaitID = tIndex[3]
        if nLastHeadID ~= nHeadID then
            table.insert(tHead, nHeadID)
        end
        if not tBang[nHeadID] then
            tBang[nHeadID] = {}
        end
        if nLastHeadID ~= nHeadID or nLastBangID ~= nBangID then
            table.insert(tBang[nHeadID], nBangID)
        end
        if not tPlait[nHeadID] then
            tPlait[nHeadID] = {}
        end
        if not tPlait[nHeadID][nBangID] then
            tPlait[nHeadID][nBangID] = {}
        end
        if nLastHeadID ~= nHeadID or nLastBangID ~= nBangID or nLastPlaitID ~= nPlaitID then
            table.insert(tPlait[nHeadID][nBangID], nPlaitID)
        end
        local nHairID = tIndex[4]
        if nSelfHairID == nHairID then
            nSelfHeadIndex = #tHead
            nSelfBangIndex = #tBang[nHeadID]
            nSelfPlaitIndex = #tPlait[nHeadID][nBangID]
        end
        
        nLastHeadID = nHeadID
        nLastBangID = nBangID
        nLastPlaitID = nPlaitID
    end
    
    local tFace = hPlayer.GetAllHair(HAIR_STYLE.FACE)
    for nIndex, nFaceID in ipairs(tFace) do
        if nSelfFaceID == nFaceID then
            nSelfFaceIndex = nIndex
        end
    end
    hPageHair.tHead = tHead
    hPageHair.nHeadIndex = nSelfHeadIndex
    hPageHair.tBang = tBang
    hPageHair.nBangIndex = nSelfBangIndex
    hPageHair.tPlait = tPlait
    hPageHair.nPlaitIndex = nSelfPlaitIndex
    hPageHair.tFace = tFace
    hPageHair.nFaceIndex = nSelfFaceIndex
    ExteriorBox.UpdateHairUIID(hPageHair)
    
    local hTip = hPageHair:Lookup("", "Text_SLTip")
    if ExteriorBox.CanChangeHead() then
        hTip:Hide()
    else
        hTip:Show()
    end
    ExteriorBox.UpdateSureBtnState(hFrame, false)
end

function ExteriorBox.GetCurrentHairID(hPageHair)
    local hPlayer = GetClientPlayer()
	if not hPlayer then
		return
	end
    
    local hHairShopClient = GetHairShop()
	if not hHairShopClient then
		return 
	end
    
	local tRepresentID = hPlayer.GetRepresentID()
	local nSelfHairID = tRepresentID[EQUIPMENT_REPRESENT.HAIR_STYLE]
	local nSelfFaceID = tRepresentID[EQUIPMENT_REPRESENT.FACE_STYLE]
    
	local nSelfHeadID, nSelfBangID, nSelfPlaitID = hHairShopClient.GetHairIndex(nSelfHairID)
    local nHeadID = 0
    local nBangID = 0
    local nPlaitID = 0
    local nFaceID = 0
    local tHead = {}
    local tBang = {}
    local tPlait = {}
    if hPageHair.nHeadIndex == 0 then
        nHeadID = nSelfHeadID
        nBangID = nSelfBangID
        nPlaitID = nSelfPlaitID
    else
        tHead = hPageHair.tHead
        nHeadID = hPageHair.tHead[hPageHair.nHeadIndex]
        tBang = hPageHair.tBang[nHeadID]
        nBangID = tBang[hPageHair.nBangIndex]
        tPlait = hPageHair.tPlait[nHeadID][nBangID]
        nPlaitID = tPlait[hPageHair.nPlaitIndex]
    end
    local tFace = {}
    if hPageHair.nFaceIndex == 0 then
        nFaceID = nSelfFaceID
    else
        nFaceID = hPageHair.tFace[hPageHair.nFaceIndex]
        tFace = hPageHair.tFace
    end
    return nHeadID, nBangID, nPlaitID, nFaceID, tHead, tBang, tPlait, tFace
end

function ExteriorBox.UpdateHairUIID(hPageHair)
    local nHeadID, nBangID, nPlaitID, nFaceID, tHead, tBang, tPlait, tFace = ExteriorBox.GetCurrentHairID(hPageHair)
    hPageHair.nSelectHeadID = nHeadID
    hPageHair.nSelectBangID = nBangID
    hPageHair.nSelectPlaitID = nPlaitID
    hPageHair.nSelectnFaceID = nFaceID
    hPageHair.tSelectHead = tHead
    hPageHair.tSelectBang = tBang
    hPageHair.tSelectPlait = tPlait
    hPageHair.tSelectFace = tFace
    
    local nHeadUIID = HairShop_GetHairUIID("Head", nHeadID)
    local nBangUIID = HairShop_GetHairUIID("Bang", nBangID)
    local nPlaitUIID = HairShop_GetHairUIID("Plait", nPlaitID)
    local nFaceUIID = HairShop_GetHairUIID("Face", nFaceID)
    local hHandleHair = hPageHair:Lookup("", "")
    local hHead = hHandleHair:Lookup("Text_SelectHead")
    hHead:SetText(nHeadUIID)
    local hBang = hHandleHair:Lookup("Text_SelectBang")
    hBang:SetText(nBangUIID)
    local hPlait = hHandleHair:Lookup("Text_SelectPlait")
    hPlait:SetText(nPlaitUIID )
    local hFace = hHandleHair:Lookup("Text_SelectFace")
    hFace:SetText(nFaceUIID)
    ExteriorBox.OnHairTrayOn(hPageHair)
    ExteriorBox.UpdateHairBtnState(hPageHair)
end

function ExteriorBox.UpdateHairBtnState(hPageHair)
    local hBtnHeadL = hPageHair:Lookup("Btn_HeadL_0")
    local hBtnHeadR = hPageHair:Lookup("Btn_HeadR_0")
    local hBtnBangL = hPageHair:Lookup("Btn_BangL_0")
    local hBtnBangR = hPageHair:Lookup("Btn_BangR_0")
    local hBtnPlaitL = hPageHair:Lookup("Btn_PlaitL_0")
    local hBtnPlaitR = hPageHair:Lookup("Btn_PlaitR_0")
    local hBtnFaceL = hPageHair:Lookup("Btn_FaceL_0")
    local hBtnFaceR = hPageHair:Lookup("Btn_FaceR_0")
    local bCanChangeHead = ExteriorBox.CanChangeHead()
    ExteriorBox.UpdateTheHairBtnState(hBtnHeadL, hBtnHeadR, hPageHair.nHeadIndex, #hPageHair.tSelectHead, not bCanChangeHead)
    ExteriorBox.UpdateTheHairBtnState(hBtnBangL, hBtnBangR, hPageHair.nBangIndex, #hPageHair.tSelectBang, not bCanChangeHead)
    ExteriorBox.UpdateTheHairBtnState(hBtnPlaitL, hBtnPlaitR, hPageHair.nPlaitIndex, #hPageHair.tSelectPlait, not bCanChangeHead)
    ExteriorBox.UpdateTheHairBtnState(hBtnFaceL, hBtnFaceR, hPageHair.nFaceIndex, #hPageHair.tSelectFace)
end

function ExteriorBox.CanChangeHead()
	local hPlayer = GetClientPlayer()
	if not hPlayer then
		return
	end
	
	if hPlayer.dwForceID == 1 and hPlayer.GetQuestState(7440) ~= QUEST_STATE.FINISHED then
		return false
	end
	return true
end

function ExteriorBox.UpdateTheHairBtnState(hBtnL, HBtnR, nSelfIndex, nCount, bFroceDisable)
    if nSelfIndex == 0 or nSelfIndex == 1 then
        hBtnL:Enable(false)
    else
        hBtnL:Enable(true)
    end
    
    if nSelfIndex == 0 or nSelfIndex == nCount then
        HBtnR:Enable(false)
    else
        HBtnR:Enable(true)
    end
    
    if bFroceDisable then
        hBtnL:Enable(false)
        HBtnR:Enable(false)
    end
end

function ExteriorBox.OnHairTrayOn(hPageHair)
    local nFaceID = hPageHair.nSelectnFaceID
    local nHeadID = hPageHair.nSelectHeadID
    local nBangID = hPageHair.nSelectBangID
    local nPlaitID = hPageHair.nSelectPlaitID
    local tLine = g_tTable.ReHeadIndex:Search(nHeadID, nBangID, nPlaitID)
    local nHairID = tLine.nHairID
    
    local hFrame = hPageHair:GetRoot()
    local tRepresentID = hFrame.tRepresentID
    
    tRepresentID[EQUIPMENT_REPRESENT.HAIR_STYLE] = nHairID
	tRepresentID[EQUIPMENT_REPRESENT.FACE_STYLE] = nFaceID
    
    FireUIEvent("EXTERIOR_CHARACTER_UPDATE", "ExteriorBox", tRepresentID)
    ExteriorBox.UpdateSureBtnState(hFrame, true)
end

function OpenExteriorBox(bDisableSound)
	if not IsExteriorBoxOpened() then
		Wnd.OpenWindow("ExteriorBox")
	end
	local hFrame = Station.Lookup("Normal/ExteriorBox")
	ExteriorBox.InitFrame(hFrame)
    ExteriorBox.UpdateClothesList(hFrame)
    ExteriorBox.UpdateOverViewPage(hFrame)
    ExteriorBox.UpdateHairPage(hFrame)

	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
end

function IsExteriorBoxOpened()
	local hFrame = Station.Lookup("Normal/ExteriorBox")
	if hFrame then
		return true
	end
	
	return false
end

function CloseExteriorBox(bDisableSound)
	if not IsExteriorBoxOpened() then
		return 
	end
    CloseExteriorRenew()
	Wnd.CloseWindow("ExteriorBox")
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end	
end

do  
    RegisterScrollEvent("ExteriorBox")
    
    UnRegisterScrollAllControl("ExteriorBox")
        
    local szFramePath = "Normal/ExteriorBox"
    local szPageClothes = "PageSet_Goods/Page_Clothes"
    RegisterScrollControl(
        szFramePath, 
        szPageClothes.."/Btn_UP", szPageClothes.."/Btn_Down", 
        szPageClothes.."/Scroll_List", 
        {szPageClothes, "Handle_List"})
end
