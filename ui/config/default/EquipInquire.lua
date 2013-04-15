EquipInquire = {}
local OBJECT = EquipInquire
local STR_OBJECT = g_tEquipInquireStrings
local INI_FILE_PATH = "/ui/Config/Default/EquipInquireItem.ini"
local RESULT_PAGE_START = {1,1,1}
local PAGE_RESULT_COUNT = 20
local l_tResultHistory = {{},{},{}}
local l_tSourceInfo = {}

local ORDER_MODE = { ASCEND = 1, DESCEND = 2,}
local SORT_MODE = 
{
    NAME = 1,
    EQUIP_TYPE = 2,
    REQUIRE_LEVEL = 3,
    QUALITY_LEVEL = 4,
}

local l_CurrentSortOption = 
{
    {SORT_MODE.NAME, ORDER_MODE.DESCEND, "CheckBox_RName"}, 
    {SORT_MODE.NAME, ORDER_MODE.DESCEND, "CheckBox_DRName"}, 
    {SORT_MODE.NAME, ORDER_MODE.DESCEND, "CheckBox_BRName"},
}
local SORTING_INDEX=1

local EXPAND_ITEM_TYPE = {}
local MAX_INT  = 200000000
local MIN_INT  = 0
local l_tCatalogSelect = {AucType = -1, AucSubType = -1,}
local l_tResultSelect = {}
local tLinkString = {}
local LINK_STRING_INDEX = 0;

local WIDGET = 
{
    hPageSearch = nil, hWndSearch = nil, hWndResult = nil, hCatalog1 = nil,
    hPageDrop=nil, hWndDrop=nil, hWndDropResult = nil, hCatalog2 = nil,
    hPageBnis=nil, hWndBnis=nil, hWndBnisResult = nil, hCatalog3 = nil,
}

local l_tDefaultCondition =
{
	["Edit_ItemName"] = {name=g_tAuctionString.STR_ITEM_NAME, value=STR_OBJECT.STR_TYPE_ALL},
	["Edit_Level1"]    = {name="", value=MIN_INT},
    ["Edit_Level2"]    = {name="", value=MAX_INT},
	["Edit_Quality1"]  =  {name="", value=MIN_INT},
	["Edit_Quality2"]   = {name="", value=MAX_INT},
    ["Text_Quality"] = {name=g_tAuctionString.STR_ITEM_QUALITY, value=-1, bHandle=true},
    ["Text_From"] = {name=STR_OBJECT.STR_GET_NAME, value=STR_OBJECT.STR_TYPE_ALL, bHandle=true},
    ["Text_School"] = {name=STR_OBJECT.STR_SCHOOL_KUNGFU, value=STR_OBJECT.STR_TYPE_ALL, value1=STR_OBJECT.STR_TYPE_ALL, bHandle=true},
    ["Text_Camp"] = {name=g_tStrings.CAMP, value=-1, bHandle=true},
    ["Text_form"] = {name=STR_OBJECT.STR_PVPPVE, value=STR_OBJECT.STR_TYPE_ALL, bHandle=true},
    ["Text_property"] = {name=STR_OBJECT.STR_PROPERTY, value=STR_OBJECT.STR_TYPE_ALL, bHandle=true},
    ["CheckBox_Set"] = {name="", value=false},
}
local l_tInitCondition = clone(l_tDefaultCondition)

local SRC_TYPE = 
{
    DUNGEON = 0, --"副本"，
    REPUTATION = 1, --"声望"
    PRESTIGE = 1, --威望，
    CONTRIBUTE = 1, --帮贡
    OUTDOORBOSS = 1, --野外boss
    WORLD = 2, --掉落
    SHOP = 1, --"商店"
}

local SRC_FLITER_TYPE = 
{
    DUNGEON = 1, --"副本"，
    SHOP = 2, --"商店（声望商，威望商，帮贡商）"
    WORLD = 3, --世界掉落（野外boss， 掉落）
}

function EquipInquire.OnFrameCreate()
    this:RegisterEvent("UI_SCALED")
    this:RegisterEvent("EVENT_LINK_NOTIFY")
    
    EquipInquire.OnEvent("UI_SCALED")
    OBJECT.InitObject(this)
    OBJECT.InitCondition(l_tInitCondition)
    OBJECT.InitCatalog()
    OBJECT.InitResultList()
    OBJECT.UpdateSourceDesc()
end

local function OnLinkEvent(szLinkInfo)
    --"Dungeon_Boss名字"
    --"Shop_商店名"
    local szKey, szInfo = szLinkInfo:match("(%w+)_(.*)")
    if szKey == "Dungeon" then
        local nMapID, nStringID= szInfo:match("(%d+)_(%d+)")
        local szName = EquipInquire_GetLinkString(tonumber(nStringID))
        OBJECT.LinkDungeon(tonumber(nMapID), szName)
    elseif szKey == "Shop" then
        local szName = EquipInquire_GetLinkString(tonumber(szInfo))
        OBJECT.LinkShop(szName)
    end
end

function EquipInquire.OnEvent(szEvent)
    if szEvent == "EVENT_LINK_NOTIFY" then
        OnLinkEvent(arg0)
    elseif szEvent == "UI_SCALED" then
		this:SetPoint("CENTER", 0, 0, "CENTER", 50, 50)
    end
end

function EquipInquire.InitObject(frame)
    WIDGET.hPageSearch = frame:Lookup("PageSet_Totle/Page_Find")   
    WIDGET.hWndSearch = WIDGET.hPageSearch:Lookup("Wnd_Search")
    WIDGET.hWndResult = WIDGET.hPageSearch:Lookup("Wnd_Result")
    WIDGET.hCatalog1 = WIDGET.hWndSearch:Lookup("", "Handle_SearchList")
    
    WIDGET.hPageDrop = frame:Lookup("PageSet_Totle/Page_Drop")   
    WIDGET.hWndDrop = WIDGET.hPageDrop:Lookup("Wnd_DropList")
    WIDGET.hWndDropResult = WIDGET.hPageDrop:Lookup("Wnd_DropResult")
    WIDGET.hCatalog2 = WIDGET.hWndDrop:Lookup("", "Handle_DropListTot")
    
    WIDGET.hPageBnis = frame:Lookup("PageSet_Totle/Page_Businessmen")
    WIDGET.hWndBnis = WIDGET.hPageBnis:Lookup("Wnd_BusinessmenList")
    WIDGET.hWndBnisResult = WIDGET.hPageBnis:Lookup("Wnd_BusinessmenResult")
    WIDGET.hCatalog3 = WIDGET.hWndBnis:Lookup("", "Handle_BLListContent")
end

function EquipInquire.InitCondition(tCondition)
    local hWnd = WIDGET.hWndSearch
    for szWidget, Data in pairs(tCondition) do
        local hWidget
        if Data.bHandle then
            hWidget = hWnd:Lookup("", szWidget)
        else
            hWidget = hWnd:Lookup(szWidget)
        end
        if szWidget == "CheckBox_Set" then
            hWidget:Check(Data.value)
        else
            hWidget:SetText(Data.name)
            hWidget.Value = Data.value
            hWidget.Value1 = Data.value1
        end
    end
end

function EquipInquire.InitCatalog()
    EquipInquire.UpdateCatalog1()
    EquipInquire.UpdateCatalog2()
    EquipInquire.UpdateCatalog3()
end

function EquipInquire.InitResultList()
    local tResult = {}
    OBJECT.UpdateResultList1(tResult)
    OBJECT.UpdateResultList2(tResult)
    OBJECT.UpdateResultList3(tResult)
    
    local hCheck1 = WIDGET.hWndResult:Lookup(l_CurrentSortOption[1][3])
    OBJECT.UpdateSortStatus(hCheck1, true)
    
    hCheck1 = WIDGET.hWndDropResult:Lookup(l_CurrentSortOption[2][3])
    OBJECT.UpdateSortStatus(hCheck1, true)
    
    hCheck1 = WIDGET.hWndBnisResult:Lookup(l_CurrentSortOption[3][3])
    OBJECT.UpdateSortStatus(hCheck1, true)
end

function EquipInquire.UpdateResultList1(tResult)
    local hList = WIDGET.hWndResult:Lookup("", "Handle_List")
    local hDisplay = WIDGET.hWndSearch:Lookup("", "Handle_Display1")
    hDisplay:Clear()
    local nStart = RESULT_PAGE_START[1]
    OBJECT.UpdateResultList(hList, nStart, tResult)
    
    OBJECT.UpdatePageInfo(WIDGET.hWndSearch, "Btn_Back", "Btn_Next", "Text_Page", RESULT_PAGE_START[1], #tResult)
end

function EquipInquire.UpdateResultList2(tResult)
    local hList = WIDGET.hWndDropResult:Lookup("", "Handle_List1")
    local hDisplay = WIDGET.hWndDrop:Lookup("", "Handle_Display2")
    hDisplay:Clear()
    local nStart = RESULT_PAGE_START[2]
    OBJECT.UpdateResultList(hList, nStart, tResult)
    
    OBJECT.UpdatePageInfo(WIDGET.hWndDrop, "Btn_Back1", "Btn_Next1", "Text_Page1", RESULT_PAGE_START[2], #tResult)
end

function EquipInquire.UpdateResultList3(tResult)
    local hList = WIDGET.hWndBnisResult:Lookup("", "Handle_List2")
    local hDisplay = WIDGET.hWndBnis:Lookup("", "Handle_Display3")
    hDisplay:Clear()
    
    local nStart = RESULT_PAGE_START[3]
    OBJECT.UpdateResultList(hList, nStart, tResult)
    
    OBJECT.UpdatePageInfo(WIDGET.hWndBnis, "Btn_Back2", "Btn_Next2", "Text_Page2", RESULT_PAGE_START[3], #tResult)
end

function EquipInquire.UpdateResultList(hList, nStart, tResult)
    local szHandleName = hList:GetName()
    hList:Clear()
    hList.hSelItem = nil
    l_tSourceInfo[szHandleName] = {}
    local nEnd = nStart + PAGE_RESULT_COUNT - 1
    nEnd = math.min(nEnd, #tResult)
    for i=nStart, nEnd, 1 do
        local tItem = tResult[i]
        local hItem = hList:AppendItemFromIni(INI_FILE_PATH, "Handle_ItemList")
        local hBox = hItem:Lookup("Box_Bg")
        local hItemInfo = GetItemInfo(tItem.dwTabType, tItem.nItemID)
        local nIconID = Table_GetItemIconID(hItemInfo.nUiId)
        local tRecommend = g_tTable.EquipRecommend:Search(hItemInfo.nRecommendID)
        local szSchool = ""
        if tRecommend and tRecommend.szDesc then
            szSchool = tRecommend.szDesc
        end
        hItem.dwTabType = tItem.dwTabType
        hItem.nItemID = tItem.nItemID
        hBox.dwTabType = tItem.dwTabType
        hBox.nItemID = tItem.nItemID
        local szKey = tItem.dwTabType..tItem.nItemID
        l_tSourceInfo[szHandleName][szKey] = EquipInquire_FormatData(tItem)
        local tResult = l_tSourceInfo[szHandleName][szKey]
        
        hBox:SetObject(UI_OBJECT_ITEM_INFO, GLOBAL.CURRENT_ITEM_VERSION, tItem.dwTabType, tItem.nItemID)
        hBox:SetObjectIcon(nIconID)
        hItem:Lookup("Text_BoxName"):SetText(tItem.szName)
        local r, g, b = GetItemFontColorByQuality(hItemInfo.nQuality)
        hItem:Lookup("Text_BoxName"):SetFontColor(r, g, b)
        
        hItem:Lookup("Text_BoxCategory"):SetText(tItem.szEquipType)
        hItem:Lookup("Text_BoxLevel"):SetText(tItem.nRequireLevel)
        hItem:Lookup("Text_BoxQuality"):SetText(tItem.nQualityLevel)
        hItem:Lookup("Text_BoxCamp"):SetText(tItem.szCampRequest)
        hItem:Lookup("Text_BoxSchool"):SetText(szSchool)
        hItem:Lookup("Text_BoxDrop"):SetText(tResult.szSourceDesc)
        if i == nStart then
            EquipInquire_SelectResult(hItem, "Image_Light")
            OBJECT.UpdateSourceDesc(hItem)
        end
    end
    FireUIEvent("SCROLL_UPDATE_LIST", szHandleName, "EquipInquire", true)
end

function EquipInquire.UpdateCatalog1()
    local tItemType = EquipInquire_GetCatalog1()
    OBJECT.UpdateCatalog(WIDGET.hCatalog1, tItemType)
end

function EquipInquire.UpdateCatalog2()
    local hList = WIDGET.hCatalog2
    local szHandleName = hList:GetName();
    hList:Clear()
    for _, tInfo in ipairs(STR_OBJECT.DUNGEON) do
        local szName = tInfo.szType
        local hTmplt1 = hList:AppendItemFromIni(INI_FILE_PATH, "Handle_DropTmplt1")
        local imgBg1 = hTmplt1:Lookup("Image_DropListBg1")
        local imgBg2 = hTmplt1:Lookup("Image_DropListBg2")
        local imgCover = hTmplt1:Lookup("Image_DropListCover")
        local imgMin = hTmplt1:Lookup("Image_DropMinimize")
        hTmplt1.Type = szName
		hTmplt1.bDungeon = true
        if hList.FirstSel == hTmplt1.Type then
            hTmplt1.bSel = true
            local hTot1 = hTmplt1:Lookup("Handle_TmpTot1")
            local w, h = OBJECT.AddSecondTemplate(hTot1, tInfo.tDungeon or {}, tInfo.szSuffixNormal, tInfo.szSuffixHard)
            imgBg1:Hide()
            imgBg2:Show()
            imgCover:Show()
            imgMin:SetFrame(8)

            local wB, _ = imgBg2:GetSize()
            imgBg2:SetSize(wB, h + 50)

            local wL, _ = hList:GetSize()
            hTmplt1:SetSize(wL, h + 50)
        else
            imgBg1:Show()
            imgBg2:Hide()
            imgCover:Hide()
            imgMin:SetFrame(12)
            imgBg2:SetSize(0, 0)

            local w, h = imgBg1:GetSize()
            hTmplt1:SetSize(w, h)
        end

        hTmplt1:Lookup("Text_DropListTitle"):SetText(szName)
    end
    FireUIEvent("SCROLL_UPDATE_LIST", szHandleName, "EquipInquire")
end

function EquipInquire.AddSecondTemplate(hTmpTot1, tData, szSuffixNormal, szSuffixHard)
    local hCatalog = WIDGET.hCatalog2

    hTmpTot1:Clear()
    for _, tInfo in pairs(tData) do
        local szName = tInfo.szDunName
        local hTmplt2 = hTmpTot1:AppendItemFromIni(INI_FILE_PATH, "Handle_DropTmplt2")
        local imgCover =  hTmplt2:Lookup("Image_DropListCover01")
        hTmplt2.Type = szName
		hTmplt2.bDungeon = true
        if hCatalog.SecondSel == hTmplt2.Type then
            hTmplt2.bSel = true
            local hTot2 = hTmplt2:Lookup("Handle_TmpTot2")
            local nAddW, nAddH = OBJECT.AddThirdTemplate(
                hTot2, 
                {tInfo.nNormalID, tInfo.tNormalBoss, szSuffix=szSuffixNormal}, 
                {tInfo.nHardID, tInfo.tHardBoss, szSuffix=szSuffixHard}
            )
            local nW, nH = hTmplt2:GetSize();
            hTmplt2:SetSize(nW + nAddW, nH + nAddH);
            imgCover:Show()
        else
            imgCover:Hide()
        end
        hTmplt2:Lookup("Text_DropList01"):SetText(szName)
    end

    hTmpTot1:Show()
    hTmpTot1:FormatAllItemPos()
    hTmpTot1:SetSizeByAllItemSize()
    return hTmpTot1:GetSize()
end

function EquipInquire.AddThirdTemplate(hTmpTot2, tData, tData1)
    local hCatalog = WIDGET.hCatalog2
    hTmpTot2:Clear()

    local function Add(szPrefix, tInfo)
        if not tInfo or not tInfo[1] or not tInfo[2] then
            return
        end
        
        for _, szName in pairs(tInfo[2]) do
            local hTmplt3 = hTmpTot2:AppendItemFromIni(INI_FILE_PATH, "Handle_DropTmplt3")
            local imgCover = hTmplt3:Lookup("Image_DropListCover03")
            hTmplt3.Type = szName
            hTmplt3.Type1 = tInfo[1]
            hTmplt3.szPrefix = szPrefix
			hTmplt3.bDungeon = true
            if hCatalog.ThirdSel == hTmplt3.Type and  hCatalog.ThirdSel1 == hTmplt3.Type1 then
                hTmplt3.bSel = true
                imgCover:Show()
            else
                imgCover:Hide()
            end
            
            if StringLengthW(szName) > 6 then
                szName = StringSubW(szName, 1, 3).."..."
            end
            if szPrefix and szPrefix ~= "" then
                hTmplt3:Lookup("Text_DropList03"):SetText(szName.."("..szPrefix..")")
            else
                hTmplt3:Lookup("Text_DropList03"):SetText(szName)
            end
            
            hTmplt3.OnItemMouseEnter = function()
                local x, y  = Cursor.GetPos()
                local w, h  = this:GetSize()
                local szWord = this.Type
                if szPrefix and szPrefix ~= "" then
                    szWord = szWord .. "("..szPrefix..")"
                end
                local szTip = GetFormatText(szWord)
                OutputTip(szTip, 400, {x, y+20, 0, 0})
                
                this.bOver = true
                EquipInquire_UpdateBgStatus(this, "Image_DropListCover03")
            end
            hTmplt3.OnItemMouseLeave= function()
                HideTip()
                
                this.bOver = false
                EquipInquire_UpdateBgStatus(this, "Image_DropListCover03")
            end
        end
    end
    Add(tData.szSuffix, tData)
    Add(tData1.szSuffix, tData1)
    
	hTmpTot2:Show()
	hTmpTot2:FormatAllItemPos()
	hTmpTot2:SetSizeByAllItemSize()
	return hTmpTot2:GetSize()
end

function EquipInquire.AddSecondC3(hTmpTot1, tData)
	local hCatalog = WIDGET.hCatalog3

    hTmpTot1:Clear()
    for _, tInfo in pairs(tData) do
		local bLast = (type(tInfo) ~= "table")
		
        local szName = ""
		if bLast then
			szName = tInfo
		else
			szName = tInfo[1]
		end
		
        local hTmplt2 = hTmpTot1:AppendItemFromIni(INI_FILE_PATH, "Handle_DropTmplt2")
        local imgCover =  hTmplt2:Lookup("Image_DropListCover01")
        hTmplt2.Type = szName
		hTmplt2.bShop = true
		hTmplt2.bLast = bLast
        if hCatalog.SecondSel == hTmplt2.Type then
            hTmplt2.bSel = true
			if not hTmplt2.bLast then
				local hTot2 = hTmplt2:Lookup("Handle_TmpTot2")
				local nAddW, nAddH = OBJECT.AddThirdC3(hTot2, tInfo[2], tInfo.szSuffix)
				local nW, nH = hTmplt2:GetSize();
				hTmplt2:SetSize(nW + nAddW, nH + nAddH);
			end
            imgCover:Show()
        else
            imgCover:Hide()
        end
        hTmplt2:Lookup("Text_DropList01"):SetText(szName)
    end

    hTmpTot1:Show()
    hTmpTot1:FormatAllItemPos()
    hTmpTot1:SetSizeByAllItemSize()
    return hTmpTot1:GetSize()
end

function EquipInquire.AddThirdC3(hTmpTot2, tData, szSuffix)
	local hCatalog = WIDGET.hCatalog3
    hTmpTot2:Clear()
	szSuffix = szSuffix or ""
        
	for _, szName in pairs(tData) do
		local hTmplt3 = hTmpTot2:AppendItemFromIni(INI_FILE_PATH, "Handle_DropTmplt3")
		local imgCover = hTmplt3:Lookup("Image_DropListCover03")
		hTmplt3.Type = szName
		hTmplt3.bShop = true
		hTmplt3.szSuffix = szSuffix or ""
		if hCatalog.ThirdSel == hTmplt3.Type then
			hTmplt3.bSel = true
			imgCover:Show()
		else
			imgCover:Hide()
		end

		hTmplt3:Lookup("Text_DropList03"):SetText(szName)
		
		hTmplt3.OnItemMouseEnter = function()
			local x, y  = Cursor.GetPos()
			local w, h  = this:GetSize()
			
			this.bOver = true
			EquipInquire_UpdateBgStatus(this, "Image_DropListCover03")
		end
		hTmplt3.OnItemMouseLeave= function()
			HideTip()
			
			this.bOver = false
			EquipInquire_UpdateBgStatus(this, "Image_DropListCover03")
		end
	end
    
	hTmpTot2:Show()
	hTmpTot2:FormatAllItemPos()
	hTmpTot2:SetSizeByAllItemSize()
	return hTmpTot2:GetSize()
end

function EquipInquire.UpdateCatalog3()
	local hList = WIDGET.hCatalog3
    local szHandleName = hList:GetName();
    hList:Clear()
    for _, tInfo in ipairs(STR_OBJECT.SHOP) do
        local szName = tInfo[1]
        local hTmplt1 = hList:AppendItemFromIni(INI_FILE_PATH, "Handle_DropTmplt1")
        local imgBg1 = hTmplt1:Lookup("Image_DropListBg1")
        local imgBg2 = hTmplt1:Lookup("Image_DropListBg2")
        local imgCover = hTmplt1:Lookup("Image_DropListCover")
        local imgMin = hTmplt1:Lookup("Image_DropMinimize")
        hTmplt1.Type = szName
		hTmplt1.bShop = true
        if hList.FirstSel == hTmplt1.Type then
            hTmplt1.bSel = true
            local hTot1 = hTmplt1:Lookup("Handle_TmpTot1")
            local w, h = OBJECT.AddSecondC3(hTot1, tInfo[2])
            imgBg1:Hide()
            imgBg2:Show()
            imgCover:Show()
            imgMin:SetFrame(8)

            local wB, _ = imgBg2:GetSize()
            imgBg2:SetSize(wB, h + 50)

            local wL, _ = hList:GetSize()
            hTmplt1:SetSize(wL, h + 50)
        else
            imgBg1:Show()
            imgBg2:Hide()
            imgCover:Hide()
            imgMin:SetFrame(12)
            imgBg2:SetSize(0, 0)

            local w, h = imgBg1:GetSize()
            hTmplt1:SetSize(w, h)
        end

        hTmplt1:Lookup("Text_DropListTitle"):SetText(szName)
    end
    FireUIEvent("SCROLL_UPDATE_LIST", szHandleName, "EquipInquire")
end

function EquipInquire.UpdateCatalog(hListLv1, tItemType)
    local szHandleName = hListLv1:GetName()
	hListLv1:Clear()
	for _, tInfo in ipairs(tItemType) do
        local Type = tInfo.type
        local szName = tInfo.name
		local hListLv2 = hListLv1:AppendItemFromIni(INI_FILE_PATH, "Handle_ListContent")
		local imgBg1 = hListLv2:Lookup("Image_SearchListBg1")
		local imgBg2 = hListLv2:Lookup("Image_SearchListBg2")
		local imgCover = hListLv2:Lookup("Image_SearchListCover")
		local imgMin = hListLv2:Lookup("Image_Minimize")
        hListLv2.Type = Type
		if hListLv1.Type == Type then
			hListLv2.bSel = true
			local hListLv3 = hListLv2:Lookup("Handle_Items")
	    	local w, h = OBJECT.AddSubTypeList(hListLv3, tInfo.tSubType or {})
	    	imgBg1:Hide()
	    	imgBg2:Show()
	    	imgCover:Show()
	    	imgMin:SetFrame(8)

	    	local wB, _ = imgBg2:GetSize()
	    	imgBg2:SetSize(wB, h + 50)

	    	local wL, _ = hListLv2:GetSize()
	    	hListLv2:SetSize(wL, h + 50)
	    else
	    	imgBg1:Show()
	    	imgBg2:Hide()
	    	imgCover:Hide()
	    	imgMin:SetFrame(12)
	    	imgBg2:SetSize(0, 0)

	    	local w, h = imgBg1:GetSize()
	    	hListLv2:SetSize(w, h)
	    end
		hListLv2:Lookup("Text_ListTitle"):SetText(szName)
	end
    FireUIEvent("SCROLL_UPDATE_LIST", szHandleName, "EquipInquire")
end

function EquipInquire.UpdatePageInfo(hWnd, szBack, szNext, szText, nStart, nTotal)
    local hBtnBack = hWnd:Lookup(szBack)
    local hBtnNext = hWnd:Lookup(szNext)
    local hText = hWnd:Lookup("", szText)
    local nEnd = nStart + PAGE_RESULT_COUNT - 1
    nEnd = math.min(nEnd, nTotal)
	hBtnBack:Enable(nStart ~= 1)
	hBtnNext:Enable(nEnd < nTotal)
	if nTotal == 0 then
		hText:SetText("(0-0(0))")
	else
		hText:SetText(nStart.."-"..nEnd.." ("..nTotal..")")
	end
end



function EquipInquire.UpdateSourceDesc(hItem)
    if not hItem then
        FireUIEvent("SCROLL_UPDATE_LIST", "Handle_Display1", "EquipInquire", true)
        FireUIEvent("SCROLL_UPDATE_LIST", "Handle_Display2", "EquipInquire", true)
        FireUIEvent("SCROLL_UPDATE_LIST", "Handle_Display3", "EquipInquire", true)
        return
    end
    
    local szHandleName = hItem:GetParent():GetName()
    local tSourceInfo = hItem.tSourceInfo
    local hDisplay = nil
    if szHandleName == "Handle_List" then
        hDisplay = WIDGET.hWndSearch:Lookup("", "Handle_Display1")
    elseif szHandleName == "Handle_List1" then
        hDisplay = WIDGET.hWndDrop:Lookup("", "Handle_Display2")
    elseif szHandleName == "Handle_List2" then
        hDisplay = WIDGET.hWndBnis:Lookup("", "Handle_Display3")
    end
    hDisplay:Clear()
    
    local szKey = hItem.dwTabType .. hItem.nItemID
    local szText = EquipInquire_GetItemSourceDesc(l_tSourceInfo[szHandleName][szKey])
    hDisplay:AppendItemFromString(szText)
    
    FireUIEvent("SCROLL_UPDATE_LIST", hDisplay:GetName(), "EquipInquire", true)
end

function EquipInquire.AddSubTypeList(hList, tSubType)
    local hTot = hList:GetParent():GetParent()
	for _, tInfo in pairs(tSubType) do
        local Type = tInfo.type
        local szName = tInfo.name
		local hItem = hList:AppendItemFromIni(INI_FILE_PATH, "Handle_List01")
		local imgCover =  hItem:Lookup("Image_SearchListCover01")
        hItem.Type = Type
		if hTot.SubType == Type then
			hItem.bSel = true
			imgCover:Show()
		else
			imgCover:Hide()
		end
		hItem:Lookup("Text_List01"):SetText(szName)
	end
	hList:Show()
	hList:FormatAllItemPos()
	hList:SetSizeByAllItemSize()
	return hList:GetSize()
end

local function SortCmp(tItemA, tItemB)
    local tInfo = l_CurrentSortOption[SORTING_INDEX]
    if tInfo[1] == SORT_MODE.NAME then
        if  tItemA.szName == tItemB.szName then
            return tItemA.nQualityLevel < tItemB.nQualityLevel
        end
        
        if tInfo[2] == ORDER_MODE.ASCEND then
            return tItemA.szName < tItemB.szName
        else
            return tItemA.szName > tItemB.szName
        end
    elseif tInfo[1] == SORT_MODE.REQUIRE_LEVEL then
        if  tItemA.nRequireLevel == tItemB.nRequireLevel then
            return tItemA.szName > tItemB.szName
        end
        
        if tInfo[2] == ORDER_MODE.ASCEND then
            return tItemA.nRequireLevel < tItemB.nRequireLevel
        else
            return tItemA.nRequireLevel > tItemB.nRequireLevel
        end
    elseif tInfo[1] == SORT_MODE.QUALITY_LEVEL then
        if  tItemA.nQualityLevel == tItemB.nQualityLevel then
            return tItemA.szName > tItemB.szName
        end
        
        if tInfo[2] == ORDER_MODE.ASCEND then
            return tItemA.nQualityLevel < tItemB.nQualityLevel
        else
            return tItemA.nQualityLevel > tItemB.nQualityLevel
        end
    elseif tInfo[1] == SORT_MODE.EQUIP_TYPE then
        if  tItemA.szEquipType == tItemB.szEquipType then
            return tItemA.szName > tItemB.szName
        end
        
        if tInfo[2] == ORDER_MODE.ASCEND then
            return tItemA.szEquipType < tItemB.szEquipType
        else
            return tItemA.szEquipType > tItemB.szEquipType
        end
    end
    return true
end

function EquipInquire.Sort(tData)
    if l_CurrentSortOption[SORTING_INDEX][1] == SORT_MODE.NAME or 
       l_CurrentSortOption[SORTING_INDEX][1] == SORT_MODE.EQUIP_TYPE then
        os.setlocale("")
    end
    
    table.sort(tData, SortCmp)
    
    if l_CurrentSortOption[SORTING_INDEX][1] == SORT_MODE.NAME or 
       l_CurrentSortOption[SORTING_INDEX][1] == SORT_MODE.EQUIP_TYPE then
        os.setlocale("C")
    end
end

function EquipInquire.OnSearchClick()
    local hWnd = WIDGET.hWndSearch
    
    for szWidget, Data in pairs(l_tInitCondition) do
        local hWidget
        if Data.bHandle then
            hWidget = hWnd:Lookup("", szWidget)
        else
            hWidget = hWnd:Lookup(szWidget)
        end
        
        if szWidget == "CheckBox_Set" then
            l_tInitCondition[szWidget].value = hWidget:IsCheckBoxChecked()
        else
            local szText = hWidget:GetText()
            l_tInitCondition[szWidget].name = szText
            l_tInitCondition[szWidget].value = hWidget.Value
            l_tInitCondition[szWidget].value1 = hWidget.Value1
        end
    end
    local hCatalog1 = WIDGET.hCatalog1
    local tResult
    if hCatalog1.Type == 5 or hCatalog1.Type == 6 or hCatalog1.Type == 7 then
            tResult = EquipInquire_SearchEquip(
            l_tInitCondition["Edit_ItemName"].value,
            tonumber(l_tInitCondition["Edit_Level1"].value),
            tonumber(l_tInitCondition["Edit_Level2"].value),
            tonumber(l_tInitCondition["Edit_Quality1"].value),
            tonumber(l_tInitCondition["Edit_Quality2"].value),
            tonumber(l_tInitCondition["Text_Quality"].value),
            l_tDefaultCondition["Text_From"].value, 
            l_tDefaultCondition["Text_School"].value1,--门派
            l_tDefaultCondition["Text_School"].value, --外功, 内功, 防御, 治疗 ..
            l_tDefaultCondition["Text_property"].value,
            tonumber(l_tDefaultCondition["Text_Camp"].value),
            l_tDefaultCondition["Text_form"].value,
            tonumber(hCatalog1.Type) or -1,
            tonumber(hCatalog1.SubType) or -1,
            l_tDefaultCondition["CheckBox_Set"].value
        )
    else
        tResult = EquipInquire_SearchEquip(
            l_tInitCondition["Edit_ItemName"].value,
            tonumber(l_tInitCondition["Edit_Level1"].value),
            tonumber(l_tInitCondition["Edit_Level2"].value),
            tonumber(l_tInitCondition["Edit_Quality1"].value),
            tonumber(l_tInitCondition["Edit_Quality2"].value),
            tonumber(l_tInitCondition["Text_Quality"].value),
            l_tInitCondition["Text_From"].value, 
            l_tInitCondition["Text_School"].value1,--门派
            l_tInitCondition["Text_School"].value, --外功, 内功, 防御, 治疗 ..
            l_tInitCondition["Text_property"].value,
            tonumber(l_tInitCondition["Text_Camp"].value),
            l_tInitCondition["Text_form"].value,
            tonumber(hCatalog1.Type) or -1,
            tonumber(hCatalog1.SubType) or -1,
            l_tInitCondition["CheckBox_Set"].value
        )
    end

    l_tResultHistory[1] = tResult or {}
    SORTING_INDEX=1
    EquipInquire.Sort(l_tResultHistory[1])
    
    RESULT_PAGE_START[1] = 1
    OBJECT.UpdateResultList1(l_tResultHistory[1])
    if #l_tResultHistory[1] == 0 then
        OutputMessage("MSG_ANNOUNCE_RED", STR_OBJECT.STR_FIND_NO_RESULT)
    end
end

function EquipInquire.OnDungeonSearchClick(szBossName, nType)
    local tResult = EquipInquire_SearchDungeonEquip(szBossName, nType)
    l_tResultHistory[2] = tResult or {}
    SORTING_INDEX=2
    EquipInquire.Sort(l_tResultHistory[2])
    RESULT_PAGE_START[2] = 1
    OBJECT.UpdateResultList2(l_tResultHistory[2])
    if #l_tResultHistory[2] == 0 then
        OutputMessage("MSG_ANNOUNCE_RED", STR_OBJECT.STR_FIND_NO_RESULT)
    end
end

function EquipInquire.OnShopSearchClick(szShopName)
    local tResult = EquipInquire_SearchShopEquip(szShopName)
    l_tResultHistory[3] = tResult or {}
    SORTING_INDEX=3
    EquipInquire.Sort(l_tResultHistory[3])
    RESULT_PAGE_START[3] = 1
    OBJECT.UpdateResultList3(l_tResultHistory[3])
    if #l_tResultHistory[3] == 0 then
        OutputMessage("MSG_ANNOUNCE_RED", STR_OBJECT.STR_FIND_NO_RESULT)
    end
end

function EquipInquire.LinkDungeon(nMapID, szBossName)
    local hPage = WIDGET.hPageDrop
    local hCatalog = WIDGET.hCatalog2
    
    if hPage:IsVisible() and tonumber(hCatalog.ThirdSel1) == nMapID and hCatalog.ThirdSel == szBossName then
        return
    end
    
    local szFirst, szSecond = EquipInquire_DungeonFirstAndSecond(nMapID, szBossName)
    if not szFirst or  not szSecond then
        Trace("KLUA[ERROR] EquipInquire.LinkDungeon(szBossName) szBossName is not exist")
        return
    end
    
    local hPageSet = hPage:GetParent()
   -- if hPageSet:GetActivePage() == hPage then
    --    return
   -- end
    hPageSet:ActivePage(hPage:GetName())
    hCatalog.FirstSel = szFirst
    hCatalog.SecondSel = szSecond
    hCatalog.ThirdSel = szBossName
    hCatalog.ThirdSel1 = nMapID

    OBJECT.UpdateCatalog2()
    OBJECT.OnDungeonSearchClick(szBossName, nMapID)
end

function EquipInquire.LinkShop(szShopName)
    local hPage = WIDGET.hPageBnis
    local hCatalog = WIDGET.hCatalog3
    if hPage:IsVisible() and hCatalog.SubType == szShopName then
        return
    end
    
    local szFirst, szSecond, szThird, szSuffix = EquipInquire_ShopFirst(szShopName)
    if not szFirst then
        Trace("KLUA[ERROR] EquipInquire.LinkShop(szShopName) szShopName is not exist")
        return
    end
    
    local hPage = WIDGET.hPageBnis
    local hPageSet = hPage:GetParent()
   -- if hPageSet:GetActivePage() == hPage then
   --     return
   -- end
    hPageSet:ActivePage(hPage:GetName())
    hCatalog.FirstSel = szFirst
	hCatalog.SecondSel = szSecond
    hCatalog.ThirdSel = szThird

    OBJECT.UpdateCatalog3()
    OBJECT.OnShopSearchClick(szShopName)
end

function EquipInquire.ChangeFilterEnableState(bEnable)
    local hWndSearch = WIDGET.hWndSearch
    hWndSearch:Lookup("Btn_From"):Enable(bEnable)
    hWndSearch:Lookup("Btn_School"):Enable(bEnable)
    hWndSearch:Lookup("Btn_Camp"):Enable(bEnable)
    hWndSearch:Lookup("Btn_form"):Enable(bEnable)
    hWndSearch:Lookup("Btn_property"):Enable(bEnable)
    hWndSearch:Lookup("CheckBox_Set"):Enable(bEnable)
end

--=========键盘 鼠标 消息========================================

function EquipInquire.OnItemLButtonDBClick()
    local szName = this:GetName()
    if szName == "Handle_List01" then
		EquipInquire.OnSearchClick()
    end
end

function EquipInquire.OnItemLButtonClick()
	local szName = this:GetName()
	if szName == "Handle_ListContent" then
        EquipInquire.ChangeFilterEnableState(true)
        local fnUpdate = nil
        local hCatalog = nil
        local szText = this:GetParent():GetName()
        if szText == "Handle_SearchList" then
            fnUpdate = EquipInquire.UpdateCatalog1
            hCatalog = WIDGET.hCatalog1
        end
        
		if this.Type == hCatalog.Type then
            hCatalog.Type = nil
            hCatalog.SubType = nil
		else
            hCatalog.SubType = nil
			hCatalog.Type = this.Type
            local nType = tonumber(hCatalog.Type)
            if nType== 5 or nType == 6 or nType == 7 then
                EquipInquire.ChangeFilterEnableState(false)
            end
		end
        fnUpdate()
    elseif szName == "Handle_List01" then
        local fnUpdate, hCatalog = nil
        
        local szText = this:GetParent():GetParent():GetParent():GetName()
        if szText == "Handle_SearchList" then
            fnUpdate = EquipInquire.UpdateCatalog1
            hCatalog = WIDGET.hCatalog1
            local nType = tonumber(hCatalog.Type)
        end
        
        hCatalog.SubType = this.Type
        fnUpdate()
    elseif szName == "Handle_ItemList" then
        EquipInquire_SelectResult(this, "Image_Light")
        OBJECT.UpdateSourceDesc(this)
    elseif szName == "Handle_DropTmplt1" and this.bDungeon then
        local hCatalog = WIDGET.hCatalog2
        hCatalog.SecondSel = nil
        hCatalog.ThirdSel = nil
        hCatalog.ThirdSel1 = nil
        if hCatalog.FirstSel == this.Type then
            hCatalog.FirstSel = nil
        else
            hCatalog.FirstSel = this.Type
        end
        OBJECT.UpdateCatalog2()
        
    elseif szName == "Handle_DropTmplt2" and this.bDungeon  then
        local hCatalog = WIDGET.hCatalog2
        hCatalog.ThirdSel = nil
        hCatalog.ThirdSel1 = nil
        if hCatalog.SecondSel == this.Type then
            hCatalog.SecondSel = nil
        else
            hCatalog.SecondSel = this.Type
        end
        OBJECT.UpdateCatalog2()
        
    elseif szName == "Handle_DropTmplt3" and this.bDungeon then
        local hCatalog = WIDGET.hCatalog2
        hCatalog.ThirdSel = this.Type
        hCatalog.ThirdSel1 = this.Type1
        OBJECT.UpdateCatalog2()
        OBJECT.OnDungeonSearchClick(this.Type, this.Type1)
		
	elseif szName == "Handle_DropTmplt1" and this.bShop then
		local hCatalog = WIDGET.hCatalog3
        hCatalog.SecondSel = nil
        hCatalog.ThirdSel = nil
        if hCatalog.FirstSel == this.Type then
            hCatalog.FirstSel = nil
        else
            hCatalog.FirstSel = this.Type
        end
        OBJECT.UpdateCatalog3()
	elseif szName == "Handle_DropTmplt2" and this.bShop then
        local hCatalog = WIDGET.hCatalog3
        hCatalog.ThirdSel = nil
        if hCatalog.SecondSel == this.Type then
            hCatalog.SecondSel = nil
        else
            hCatalog.SecondSel = this.Type
        end
        OBJECT.UpdateCatalog3()
		if this.bLast then
			OBJECT.OnShopSearchClick(this.Type)
		end
		
	elseif szName == "Handle_DropTmplt3" and  this.bShop then
        local hCatalog = WIDGET.hCatalog3
        hCatalog.ThirdSel = this.Type
        OBJECT.UpdateCatalog3()
		OBJECT.OnShopSearchClick(this.szSuffix..this.Type)
    end
	PlaySound(SOUND.UI_SOUND,g_sound.Button)
end

function EquipInquire.OnItemMouseEnter()
	local szName = this:GetName()
    if szName == "Box_Bg" then
		if not this:IsEmpty() then
			local x, y = this:GetAbsPos()
			local w, h = this:GetSize()
            OutputItemTip(UI_OBJECT_ITEM_INFO, GLOBAL.CURRENT_ITEM_VERSION, this.dwTabType, this.nItemID, {x, y, w, h})
		end
	elseif szName == "Handle_ItemList" or szName == "Handle_ListContent" or szName == "Handle_List01" or 
           szName == "Handle_DropTmplt1" or szName == "Handle_DropTmplt2" then
		local tImage = 
        {
            ["Handle_ItemList"] = "Image_Light",
            ["Handle_ListContent"] = "Image_SearchListCover",
            ["Handle_List01"] = "Image_SearchListCover01",
            ["Handle_DropTmplt1"] = "Image_DropListCover",
            ["Handle_DropTmplt2"] = "Image_DropListCover01",
        }
        this.bOver = true
		EquipInquire_UpdateBgStatus(this, tImage[szName])
        
    elseif this:IsLink() and this:GetType() == "Text" then
        this.nFont=this:GetFontScheme()
        this:SetFontScheme(188)
	end
end

function EquipInquire.OnItemMouseLeave()
	local szName = this:GetName()
	if szName == "Box_Bg" then
		HideTip()
	elseif szName == "Handle_ItemList" or szName == "Handle_ListContent" or szName == "Handle_List01" or 
           szName == "Handle_DropTmplt1" or szName == "Handle_DropTmplt2"  then
        local tImage = 
        {
            ["Handle_ItemList"] = "Image_Light",
            ["Handle_ListContent"] = "Image_SearchListCover",
            ["Handle_List01"] = "Image_SearchListCover01",
            ["Handle_DropTmplt1"] = "Image_DropListCover",
            ["Handle_DropTmplt2"] = "Image_DropListCover01",
        }
		this.bOver = false
		EquipInquire_UpdateBgStatus(this, tImage[szName])
    elseif this:IsLink() and this:GetType() == "Text" then
        this:SetFontScheme(this.nFont)
	end
end
 
function EquipInquire.OnItemLButtonDown()
	local szName = this:GetName()
	if szName == "Box_Bg" then
        if IsCtrlKeyDown() then
            EditBox_AppendLinkItemInfo(GLOBAL.CURRENT_ITEM_VERSION, this.dwTabType, this.nItemID)
        end
	end
end

function EquipInquire.OnLButtonClick() 
    local szName = this:GetName()
    if szName == "Btn_Search" then
        EquipInquire.OnSearchClick()
    elseif szName == "Btn_SearchDefault" then
        OBJECT.InitCondition(l_tDefaultCondition)
        l_tInitCondition = clone(l_tDefaultCondition)
        
        WIDGET.hCatalog1.Type=nil
        WIDGET.hCatalog1.SubType=nil
        EquipInquire.UpdateCatalog1()
        EquipInquire.ChangeFilterEnableState(true)
    elseif szName == "Btn_Back" then
        RESULT_PAGE_START[1] = math.max(1, RESULT_PAGE_START[1] - PAGE_RESULT_COUNT)
        OBJECT.UpdateResultList1(l_tResultHistory[1])
    elseif szName == "Btn_Next" then
        RESULT_PAGE_START[1] = RESULT_PAGE_START[1] + PAGE_RESULT_COUNT
        OBJECT.UpdateResultList1(l_tResultHistory[1])
    elseif szName == "Btn_Back1" then
        RESULT_PAGE_START[2] = math.max(1, RESULT_PAGE_START[2] - PAGE_RESULT_COUNT)
        OBJECT.UpdateResultList2(l_tResultHistory[2])
    elseif szName == "Btn_Next1" then
        RESULT_PAGE_START[2] = RESULT_PAGE_START[2] + PAGE_RESULT_COUNT
        OBJECT.UpdateResultList2(l_tResultHistory[2])
    elseif szName == "Btn_Back2" then
        RESULT_PAGE_START[3] = math.max(1, RESULT_PAGE_START[3] - PAGE_RESULT_COUNT)
        OBJECT.UpdateResultList3(l_tResultHistory[3])
    elseif szName == "Btn_Next2" then
        RESULT_PAGE_START[3] = RESULT_PAGE_START[3] + PAGE_RESULT_COUNT
        OBJECT.UpdateResultList3(l_tResultHistory[3])
    elseif szName == "Btn_Close" then
        CloseEquipInquire()
    end
end

function EquipInquire.OnLButtonDown()
    local szName = this:GetName()
        
    if szName == "Btn_Quality" then
        if not this:IsEnabled() then
            return
        end
        
		local tData = {}
		for k, v in pairs(g_tAuctionString.tSearchQuality) do
            local r, g, b = GetItemFontColorByQuality(v)
			table.insert(tData, {name=k, value=v, r=r, g=g, b=b})
		end
		table.sort(tData, function(a, b) return a.value < b.value end)
		table.insert(tData, 1, {name=g_tAuctionString.STR_ITEM_QUALITY, value=-1})

		local text = this:GetParent():Lookup("", "Text_Quality")
		EquipInquire_PopupMenu(this, text, tData)
        return true
    elseif szName == "Btn_From" then
        if not this:IsEnabled() then
            return
        end
        
        local tData = {}
		for k, v in ipairs(STR_OBJECT.SRC_FLITER_TYPE) do
			table.insert(tData, {name=v, value=v})
		end
		table.insert(tData, 1, {name=STR_OBJECT.STR_GET_NAME, value=STR_OBJECT.STR_TYPE_ALL})
        
		local text = this:GetParent():Lookup("", "Text_From")
		EquipInquire_PopupMenu(this, text, tData)
        return true
    elseif szName == "Btn_School" then
        if not this:IsEnabled() then
            return
        end
        
        local tData = {}
		for k, v in ipairs(STR_OBJECT.SCHOOL_FLITER) do
            local szSchool = v[1]
            local szKungfu1 = v[2][1]
            local szKungfu2 = v[3][1]
			table.insert(tData, {name=szSchool.."（"..szKungfu1.."）", value=v[2][2], value1=szSchool})
            table.insert(tData, {name=szSchool.."（"..szKungfu2.."）", value=v[3][2], value1=szSchool})
		end
		table.insert(tData, 1, {name=STR_OBJECT.STR_SCHOOL_KUNGFU , value=STR_OBJECT.STR_TYPE_ALL, value1=STR_OBJECT.STR_TYPE_ALL})
        
		local text = this:GetParent():Lookup("", "Text_School")
		EquipInquire_PopupMenu(this, text, tData)
        return true
    elseif szName == "Btn_Camp" then
        if not this:IsEnabled() then
            return
        end
        
        local tData = 
        {
            {name=g_tStrings.CAMP, value=-1},
            --{name=g_tStrings.STR_GUILD_CAMP_NAME[CAMP.NEUTRAL], value=CAMP.NEUTRAL},
            {name=g_tStrings.STR_GUILD_CAMP_NAME[CAMP.GOOD], value=CAMP.GOOD},
            {name=g_tStrings.STR_GUILD_CAMP_NAME[CAMP.EVIL], value=CAMP.EVIL},
        }
		local text = this:GetParent():Lookup("", "Text_Camp")
		EquipInquire_PopupMenu(this, text, tData)
        return true
    elseif szName == "Btn_form" then
        if not this:IsEnabled() then
            return
        end
        local tData = 
        {
            {name="PVE&PVP", value=STR_OBJECT.STR_TYPE_ALL},
            {name="PVE", value="PVE"},
            {name="PVP", value="PVP"},
        }
		local text = this:GetParent():Lookup("", "Text_form")
		EquipInquire_PopupMenu(this, text, tData)
        return true
    elseif szName == "Btn_property" then
        if not this:IsEnabled() then
            return
        end
        local tData = {}
		for k, v in ipairs(STR_OBJECT.MAGIC_TYPE) do
			table.insert(tData, {name=v, value=v})
		end
		table.insert(tData, 1, {name=STR_OBJECT.STR_PROPERTY, value=STR_OBJECT.STR_TYPE_ALL})
        
		local text = this:GetParent():Lookup("", "Text_property")
		EquipInquire_PopupMenu(this, text, tData)
        return true    
    end
end

function EquipInquire.OnSetFocus()
  	local szName = this:GetName()
  	if szName == "Edit_ItemName" then
        local szText = this:GetText()
  		if szText == g_tAuctionString.STR_ITEM_NAME then
  			EquipInquire.bEditItemName = true
  			this:SetText("")
  		else
  			this:SelectAll()
  		end
  	end
end

function EquipInquire.OnKillFocus()
	local szName = this:GetName()
  	if szName == "Edit_ItemName" then
  		local szText = this:GetText()
  		if not szText or szText == "" then
  			this:SetText(g_tAuctionString.STR_ITEM_NAME)
  		end
  	end
    
    if this:GetType() == "WndEdit" then
        local szText = this:GetText();
        local DefaultValue = l_tDefaultCondition[szName].value
        if not szText or szText == g_tAuctionString.STR_ITEM_NAME or szText == "" then
            szText = DefaultValue
        end
        this.Value = szText
    end
end

function EquipInquire.UpdateSortStatus(hCheckBox, bInit)
    local tCheckBox= 
    {
        ["Wnd_Result"] = {
            fnUpdate = EquipInquire.UpdateResultList1,
            nIndex=1,
            tCheck={
                ["CheckBox_RName"]={imgUp="Image_RNameUp", imgDown="Image_RNameDown", SortMode=SORT_MODE.NAME},
                ["CheckBox_RCategory"]={imgUp="Image_RCategoryUp", imgDown="Image_RCategoryDown", SortMode=SORT_MODE.EQUIP_TYPE},
                ["CheckBox_RLevel"]= {imgUp="Image_RLevelUp", imgDown="Image_RLevelDown", SortMode=SORT_MODE.REQUIRE_LEVEL},
                ["CheckBox_Quality"] = {imgUp="Image_QualityCB00", imgDown="Image_QualityCB01", SortMode=SORT_MODE.QUALITY_LEVEL},
            },
        },
        ["Wnd_DropResult"] = {
            fnUpdate = EquipInquire.UpdateResultList2,
            nIndex=2,
            tCheck={
                ["CheckBox_DRName"] = {imgUp="Image_DRNameUp", imgDown="Image_DRNameDown", SortMode=SORT_MODE.NAME},
                ["CheckBox_DRCategory"] = {imgUp="Image_DRCategoryUp", imgDown="Image_DRCategoryDown", SortMode=SORT_MODE.EQUIP_TYPE},
                ["CheckBox_DRLevel"] = {imgUp="Image_DRLevelUp", imgDown="Image_DRLevelDown", SortMode=SORT_MODE.REQUIRE_LEVEL},
                ["CheckBox_DRQuality"] = {imgUp="Image_DRQuality00", imgDown="Image_DRQuality01", SortMode=SORT_MODE.QUALITY_LEVEL},
            },
        },
        ["Wnd_BusinessmenResult"] = {
            fnUpdate = EquipInquire.UpdateResultList3,
            nIndex=3,
            tCheck={
                ["CheckBox_BRName"]={imgUp="Image_BRNameUp", imgDown="Image_BRNameDown", SortMode=SORT_MODE.NAME},
                ["CheckBox_BRCategory"]={imgUp="Image_BRCategoryUp", imgDown="Image_BRCategoryDown", SortMode=SORT_MODE.EQUIP_TYPE},
                ["CheckBox_BRLevel"]={imgUp="Image_BRLevelUp", imgDown="Image_BRLevelDown", SortMode=SORT_MODE.REQUIRE_LEVEL},
                ["CheckBox_BRQuality"]={imgUp="Image_BRQuality00", imgDown="Image_BRQuality01", SortMode=SORT_MODE.QUALITY_LEVEL},
            }
        },
    }
	local szName = hCheckBox:GetName()
    local hWnd = hCheckBox:GetParent()
    local szParent = hWnd:GetName()
    local tCheckData = tCheckBox[szParent]

    if not tCheckData or not tCheckData.tCheck[szName] then
        return false
    end
    local fnUpdateResult = tCheckData.fnUpdate
    local nIndex = tCheckData.nIndex
    local tResult = l_tResultHistory[nIndex]
    if bInit then
        for szCheckBoxName, tBox in pairs(tCheckData.tCheck) do
            local hCheckB = hWnd:Lookup(szCheckBoxName)
            local hImgUp = hCheckB:Lookup("", tBox.imgUp)
            local hImgDown = hCheckB:Lookup("", tBox.imgDown)
            hImgUp:Hide()
            hImgDown:Hide()	
            if szCheckBoxName == l_CurrentSortOption[nIndex][3] then
                if l_CurrentSortOption[nIndex][2] == ORDER_MODE.ASCEND then
                    hImgUp:Show()
                else
                    hImgDown:Show()
                end
            end
        end
        return true
    end
    
    for szCheckBoxName, tBox in pairs(tCheckData.tCheck) do
        local hCheckB = hWnd:Lookup(szCheckBoxName)
        local hImgUp = hCheckB:Lookup("", tBox.imgUp)
        local hImgDown = hCheckB:Lookup("", tBox.imgDown)
        if szCheckBoxName ~= szName then
            hImgUp:Hide()
            hImgDown:Hide()
        else
            if not hImgDown:IsVisible() then
                hImgUp:Hide()
                hImgDown:Show()
                l_CurrentSortOption[nIndex][2] = ORDER_MODE.DESCEND
            else
                hImgUp:Show()
                hImgDown:Hide()
                l_CurrentSortOption[nIndex][2] =  ORDER_MODE.ASCEND
            end
            l_CurrentSortOption[nIndex][1] = tBox.SortMode
            l_CurrentSortOption[nIndex][3] = szCheckBoxName
        end
    end
    SORTING_INDEX = nIndex
    EquipInquire.Sort(tResult)
    fnUpdateResult(tResult)
    return true
end

function EquipInquire.OnCheckBoxCheck()
	local frame = this:GetRoot()
	if frame.bIniting then
		return
	end
    
    local bDone = OBJECT.UpdateSortStatus(this)
    if bDone then
        PlaySound(SOUND.UI_SOUND, g_sound.Button)
        return true
    end

	PlaySound(SOUND.UI_SOUND, g_sound.Button)
end

function EquipInquire.OnCheckBoxUncheck()
	local frame = this:GetRoot()
	if frame.bIniting then
		return
	end
    
    local bDone = OBJECT.UpdateSortStatus(this)
    if bDone then
        PlaySound(SOUND.UI_SOUND, g_sound.Button)
        return true
    end
    PlaySound(SOUND.UI_SOUND, g_sound.Button)
end

local function TabFocusEdit()
    local tTabEdit = 
    {
        "Edit_ItemName",
        "Edit_Level1",
        "Edit_Level2",
        "Edit_Quality1",
        "Edit_Quality2",
    }
	local focusEdit = Station.GetFocusWindow()
	local szName = nil
	if focusEdit then
		szName = focusEdit:GetName()
	end
				
	local nIndex = -1
	local nSize = #tTabEdit
	for k, v in ipairs(tTabEdit) do
		if v == szName then
			nIndex = k + 1
			if nIndex > nSize then
				nIndex = 1
			end
			break;
		end
	end
	if nIndex == -1 then
		nIndex = 1
	end
	
	local edit = WIDGET.hWndSearch:Lookup(tTabEdit[nIndex]);
	edit:SelectAll()
	Station.SetFocusWindow(edit)
end

function EquipInquire.OnFrameKeyDown()
	local szKey = GetKeyName(Station.GetMessageKey())
    local hPageSearch = WIDGET.hPageSearch
    local hWndSearch  = WIDGET.hWndSearch 
	if szKey == "Enter" and hPageSearch:IsVisible() then
		local btn  = hWndSearch:Lookup("Btn_Search")

		local thisSave = this
		this = btn
		if hWndSearch and hWndSearch:IsVisible() and btn:IsEnabled() then
            Station.SetFocusWindow(btn)
			EquipInquire.OnLButtonClick()
		end
		this = thisSave
		return 1
	
	elseif szKey == "Tab" then 
		if hPageSearch and hPageSearch:IsVisible()  then
			TabFocusEdit()
		end
		return 1
	end
	return 0
end

--========================================================
function IsEquipInquireOpened(bDisableSound)
    local frame = Station.Lookup("Normal/EquipInquire")
    if frame and frame:IsVisible() then
        return true
    end
end

function OpenEquipInquire()
    if IsOptionOrOptionChildPanelOpened() then
		return
	end

	local frame = Wnd.OpenWindow("EquipInquire")
	EquipInquire.InitObject(frame);
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end 
end

function CloseEquipInquire(bDisableSound)
    if IsEquipInquireOpened() then
		Wnd.CloseWindow("EquipInquire")
	end
    l_tResultHistory = {{}, {}, {}}
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end
end

function EquipInquire_GetLinkString(nID)
    for k, v in pairs(tLinkString) do
        if v == nID then
            return k
        end
    end
end

function EquipInquire_GetLinkStringID(szLinkString)
    if tLinkString[szLinkString] then
        return tLinkString[szLinkString]
    else
        if LINK_STRING_INDEX > 100 then
            tLinkString = {}
            LINK_STRING_INDEX = 0
        end
        tLinkString[szLinkString] = LINK_STRING_INDEX
        LINK_STRING_INDEX = LINK_STRING_INDEX + 1
        return LINK_STRING_INDEX - 1
    end
end

do
    RegisterScrollEvent("EquipInquire")
    
    UnRegisterScrollAllControl("EquipInquire")
        
    local szFramePath = "Normal/EquipInquire"
    local szWndPath = "PageSet_Totle/Page_Find/Wnd_Search"
    RegisterScrollControl(
        szFramePath, 
        szWndPath.."/Btn_SUp", szWndPath.."/Btn_SDown", 
        szWndPath.."/Scroll_Search", 
        {szWndPath, "Handle_SearchList"})

    RegisterScrollControl(
        szFramePath, 
        szWndPath.."/Btn_UpDis1", szWndPath.."/Btn_DownDis1", 
        szWndPath.."/Scroll_Dis1", 
        {szWndPath, "Handle_Display1"})
        
    szWndPath = "PageSet_Totle/Page_Find/Wnd_Result"
    RegisterScrollControl(
        szFramePath, 
        szWndPath.."/Btn_RUp", szWndPath.."/Btn_RDown", 
        szWndPath.."/Scroll_Result", 
        {szWndPath, "Handle_List"})

    szWndPath = "PageSet_Totle/Page_Drop/Wnd_DropList"
    RegisterScrollControl(
        szFramePath, 
        szWndPath.."/Btn_DUp", szWndPath.."/Btn_DDown", 
        szWndPath.."/Scroll_Drop", 
        {szWndPath, "Handle_DropListTot"})

    RegisterScrollControl(
        szFramePath, 
        szWndPath.."/Btn_UpDis2", szWndPath.."/Btn_DownDis2", 
        szWndPath.."/Scroll_Dis2", 
        {szWndPath, "Handle_Display2"})
        
    szWndPath = "PageSet_Totle/Page_Drop/Wnd_DropResult"
    RegisterScrollControl(
        szFramePath, 
        szWndPath.."/Btn_DRUp", szWndPath.."/Btn_DRDown", 
        szWndPath.."/Scroll_DRResult", 
        {szWndPath, "Handle_List1"})

    szWndPath = "PageSet_Totle/Page_Businessmen/Wnd_BusinessmenList"
    RegisterScrollControl(
        szFramePath, 
        szWndPath.."/Btn_BLUp", szWndPath.."/Btn_BLDown", 
        szWndPath.."/Scroll_BusinessmenList", 
        {szWndPath, "Handle_BLListContent"})

    RegisterScrollControl(
        szFramePath, 
        szWndPath.."/Btn_UpDis3", szWndPath.."/Btn_DownDis3", 
        szWndPath.."/Scroll_Dis3", 
        {szWndPath, "Handle_Display3"})
        
    szWndPath = "PageSet_Totle/Page_Businessmen/Wnd_BusinessmenResult"
    RegisterScrollControl(
        szFramePath, 
        szWndPath.."/Btn_BRUp", szWndPath.."/Btn_BRDown", 
        szWndPath.."/Scroll_BRResult", 
        {szWndPath, "Handle_List2"})
end
