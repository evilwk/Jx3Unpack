local SHOW_ITEM = 
{
    BANG_GONG = g_tStrings.STR_CURRENT_CONTRIBUTION,
    XIA_YI = g_tStrings.STR_CURRENT_XIAYI,
    WEI_WANG = g_tStrings.STR_CURRENT_PRESTIGE,
    ZJ_JIFEN = g_tStrings.STR_CURRENT_ZHANJIE,
    ZJ_LEVEL = g_tStrings.STR_ZHANJIE_LEVEL,
    JIAN_BEN = g_tStrings.STR_CURRENT_EXAMPRINT,
    MOENY = g_tStrings.STR_MAIL_TITLE_MONEY,
    JH_ZHILI = g_tStrings.STR_CURRENT_JIANGHU_ZILI,
    TONG_BAO = g_tStrings.STR_CURRENT_TONG_BAO,
    FENGYUN_LU = g_tStrings.STR_ITEM_SHOW_FENGYUN_LU,
    EQUIP_SEARCH = g_tStrings.STR_ITEM_SHOW_EQUIP,
    MI_JING = g_tStrings.STR_ITEM_SHOW_MI_JING,
    ONLINE_DELAY = g_tStrings.STR_ONLINE_DELAY,
    FPS = "FPS",
    ARENA_AWARD = g_tStrings.STR_CURRENT_ARENA_AWARD,
    CPU = "CPU",
    WORK_SET = g_tStrings.STR_WORK_SET,
	MENTOR_SCORE = g_tStrings.STR_MENTOR_SCORE,
}

local UITEX_PATH0 = "ui/Image/Minimap/Minimap.UITex"
local UITEX_PATH1 = "ui/Image/Minimap/MapMark.UITex"

MainMessageLine = 
{
    tShow = 
	{
		SHOW_ITEM.MI_JING,
		SHOW_ITEM.FENGYUN_LU,
		SHOW_ITEM.EQUIP_SEARCH,
		SHOW_ITEM.ONLINE_DELAY,
		--SHOW_ITEM.FPS,
		--SHOW_ITEM.CPU,
		--SHOW_ITEM.WORK_SET,
	},
	
	clone(tDefault),
    bNormalHide = false,
    
    DefaultAnchor = {s = "TOPLEFT", r = "TOPLEFT",  x = 0, y = 0},
	Anchor = {s = "TOPLEFT", r = "TOPLEFT", x = 0, y = 0},
    nVersion = 0,
}

RegisterCustomData("MainMessageLine.tShow")
RegisterCustomData("MainMessageLine.bNormalHide")
RegisterCustomData("MainMessageLine.Anchor")
RegisterCustomData("MainMessageLine.nVersion")

local OVER_FONT = 202
local CURRENT_VERSION = 1
local INI_FILE = "ui/Config/Default/MainMessageLine.ini"
local OBJECT = MainMessageLine
local lc_tSetting = 
{
    {name=SHOW_ITEM.BANG_GONG, nFrame=17, fnTip="currencyTip", fnAddHandle="addCurrency"}, -- 帮贡
    {name=SHOW_ITEM.XIA_YI, nFrame=25, fnTip="currencyTip", fnAddHandle="addCurrency"},  -- 侠义
    
    {name=SHOW_ITEM.ARENA_AWARD, nFrame=167, fnTip="currencyTip", fnAddHandle="addCurrency"}, -- 名剑币
    {name=SHOW_ITEM.WEI_WANG, nFrame=22, fnTip="currencyTip", fnAddHandle="addCurrency"}, -- 威望
    {name=SHOW_ITEM.ZJ_JIFEN, nFrame=24, fnTip="currencyTip", fnAddHandle="addCurrency"}, -- 战阶积分
    {name=SHOW_ITEM.ZJ_LEVEL, fnTip="commomTip", fnAddHandle="addCommom"},  -- 战阶等级
    {name=SHOW_ITEM.JIAN_BEN, nFrame=18, fnTip="currencyTip", fnAddHandle="addCurrency"}, --监本印文
    {name=SHOW_ITEM.MOENY, fnAddHandle="addMoney"}, --金钱
    {name=SHOW_ITEM.JH_ZHILI, fnTip="commomTip", fnAddHandle="addCommom"}, --江湖资历
    {name=SHOW_ITEM.TONG_BAO, nFrame=15, fnTip=nil, fnAddHandle="addCurrency"}, --通宝
	{name=SHOW_ITEM.MENTOR_SCORE, fnTip="commomTip", fnAddHandle="addCommom"}, --师徒装备分数
 
    {name=SHOW_ITEM.ONLINE_DELAY, fnTip=nil, fnAddHandle="addCommom"}, --网络延迟
    {name=SHOW_ITEM.FPS, fnTip=nil, fnAddHandle="addCommom"}, --fps
    {name=SHOW_ITEM.CPU, fnTip=nil, fnAddHandle="addCommom"}, --Cpu
    {name=SHOW_ITEM.WORK_SET, fnTip=nil, fnAddHandle="addCommom"}, --Work_set
    
    {name=SHOW_ITEM.FENGYUN_LU, nFrame=114, fnTip="linkTip", fnAddHandle="addLink", uitex=UITEX_PATH1}, --风云录
    {name=SHOW_ITEM.EQUIP_SEARCH, nFrame=245, fnAddHandle="addLink", uitex=UITEX_PATH0}, --装备大全
    {name=SHOW_ITEM.MI_JING, nFrame=205,  fnTip="linkTip", fnAddHandle="addLink", uitex=UITEX_PATH0, menu="PopupDungeonMenu"}, --武林秘境
}

local GET_DESC = 
{
    [SHOW_ITEM.BANG_GONG] = {text=g_tStrings.STR_SHOW_ITEM_GET0, },
    [SHOW_ITEM.XIA_YI] = {text=g_tStrings.STR_SHOW_ITEM_GET1,},
    [SHOW_ITEM.WEI_WANG] = {text=g_tStrings.STR_SHOW_ITEM_GET2,},
    [SHOW_ITEM.ZJ_JIFEN] = {text=g_tStrings.STR_SHOW_ITEM_GET2,},
    [SHOW_ITEM.JIAN_BEN] = {text=g_tStrings.STR_SHOW_ITEM_GET3,},
    [SHOW_ITEM.JH_ZHILI] = {text=g_tStrings.STR_SHOW_ITEM_GET4,},
    [SHOW_ITEM.ZJ_LEVEL] = {text=g_tStrings.STR_SHOW_ITEM_GET5,},
    [SHOW_ITEM.FENGYUN_LU] = {text=g_tStrings.STR_SHOW_ITEM_GET6, shortCut=g_tStrings.STR_FENGYUN_LU_SHORTCUT},
    [SHOW_ITEM.MI_JING] = {text=g_tStrings.STR_SHOW_ITEM_GET7},
	[SHOW_ITEM.ARENA_AWARD] = {text=g_tStrings.STR_SHOW_ITEM_GET8},
	[SHOW_ITEM.MENTOR_SCORE] = {text=g_tStrings.STR_SHOW_ITEM_GET9},
}

local lc_tSettingIndex = {}
local lc_tMenuGroup = 
{
    {name="PVE", tItem = {SHOW_ITEM.BANG_GONG, SHOW_ITEM.XIA_YI}},
    {name="PVP", tItem = {SHOW_ITEM.WEI_WANG, SHOW_ITEM.ZJ_JIFEN, SHOW_ITEM.ZJ_LEVEL, SHOW_ITEM.ARENA_AWARD}},
    {name=g_tStrings.STR_CURRENT_TYPE_FREE, tItem = {SHOW_ITEM.JIAN_BEN, SHOW_ITEM.MOENY, SHOW_ITEM.JH_ZHILI, SHOW_ITEM.TONG_BAO, SHOW_ITEM.MENTOR_SCORE}},
    {name=g_tStrings.OTHER, tItem = {SHOW_ITEM.MI_JING, SHOW_ITEM.FENGYUN_LU, SHOW_ITEM.EQUIP_SEARCH,  SHOW_ITEM.ONLINE_DELAY, SHOW_ITEM.FPS, SHOW_ITEM.CPU, SHOW_ITEM.WORK_SET}},
}

local lc_tBreatheUpdate = {}
local lc_Frame
local lc_MainList
local lc_bMouseLeave = false
function MainMessageLine.getFPSFont(fps)
    local nFont = 102
    if fps >= 40 then
        nFont = 105
    elseif fps >= 20 then
        nFont = 101
    end
    return nFont
end

function MainMessageLine.getPingFont(pingTime)
    local nFont = 102
    if pingTime <= 300 then
        nFont = 105
    elseif pingTime <= 800 then
        nFont = 101
    end
    return nFont
end

function MainMessageLine.OnFrameCreate()
    this:RegisterEvent("UI_SCALED")
    this:RegisterEvent("SYNC_COIN")
    this:RegisterEvent("MONEY_UPDATE")
    this:RegisterEvent("CONTRIBUTION_UPDATE")
    this:RegisterEvent("UPDATE_EXAMPRINT")
    this:RegisterEvent("UPDATE_JUSTICE")
    this:RegisterEvent("UPDATE_PRESTIGE")
    this:RegisterEvent("TITLE_POINT_UPDATE")
    this:RegisterEvent("ON_ENTER_CUSTOM_UI_MODE")
	this:RegisterEvent("ON_LEAVE_CUSTOM_UI_MODE")
    this:RegisterEvent("MAINMESSAGELINE_ANCHOR_CHANGED")
    this:RegisterEvent("UPDATE_ACHIEVEMENT_POINT")
	this:RegisterEvent("UPDATE_ACHIEVEMENT_COUNT")
	this:RegisterEvent("UPDATE_ARENAAWARD")
	this:RegisterEvent("ON_SYNC_TA_EQUIPS_SCORE")
	
    lc_Frame = this;
    lc_MainList = this:Lookup("", "Handle_MainMessage")
    OBJECT.initIndex();
    OBJECT.updateShow(this);
    if OBJECT.bNormalHide then
        OBJECT.HideMainLine()
    end
    
	MainMessageLine.OnEvent("UI_SCALED")
    OBJECT.UpdateAnchor(this)
    UpdateCustomModeWindow(this, g_tStrings.STR_MAIN_ITEM_SHOW)	
end

function MainMessageLine.OnFrameBreathe()
    if lc_bMouseLeave and OBJECT.bNormalHide then
        OBJECT.HideMainLine()
    end
    
    if not this:IsVisible() then
        return
    end
        
    if not this.nFrameCount or this.nFrameCount == 8 then
        this.nFrameCount = 0
    end
    
    if this.nFrameCount == 0 then
        for _, t in pairs(lc_tBreatheUpdate) do
            local hItem = lc_MainList:Lookup(t.nIndex)
            if hItem then
                local nValue, nFont1 = t.fn(hItem.itemName)
                local text = hItem:Lookup("Text_Content")
                local nFont = text:GetFontScheme()
                if nFont1 ~= nil then
                    nFont = nFont1
                end
                text:SetText(nValue.." ")
                text:SetFontScheme(nFont)
            end
        end
    end
    this.nFrameCount = this.nFrameCount + 1
end

function MainMessageLine.IsItemExist(name)
    for k, v in pairs(OBJECT.tShow) do
        if v == name then
            return true;
        end
    end
    return false;
end

function MainMessageLine.ProcessVersion0()
    if #OBJECT.tShow < 8 then
        if not OBJECT.IsItemExist(SHOW_ITEM.MI_JING) then
            table.insert(OBJECT.tShow, SHOW_ITEM.MI_JING)
        end
        if not OBJECT.IsItemExist(SHOW_ITEM.FENGYUN_LU) then
            table.insert(OBJECT.tShow, SHOW_ITEM.FENGYUN_LU)
        end
        if not OBJECT.IsItemExist(SHOW_ITEM.EQUIP_SEARCH) then
            table.insert(OBJECT.tShow, SHOW_ITEM.EQUIP_SEARCH)
        end
    else
        if not OBJECT.IsItemExist(SHOW_ITEM.MI_JING) then
            table.insert(OBJECT.tShow, SHOW_ITEM.MI_JING)
        end
        if not OBJECT.IsItemExist(SHOW_ITEM.FENGYUN_LU) then
            table.insert(OBJECT.tShow, SHOW_ITEM.FENGYUN_LU)
        end
    end
end

function MainMessageLine.OnEvent(event)
    if event == "UI_SCALED" then
        OBJECT.adjustSize()
		MainMessageLine.UpdateValue(this)
        OBJECT.UpdateAnchor(this)
	elseif event == "ON_ENTER_CUSTOM_UI_MODE" or event == "ON_LEAVE_CUSTOM_UI_MODE" then
		UpdateCustomModeWindow(this)
    elseif event == "MAINMESSAGELINE_ANCHOR_CHANGED" then
        OBJECT.UpdateAnchor(this)
    elseif event == "SYNC_COIN" or event == "MONEY_UPDATE" or event == "CONTRIBUTION_UPDATE" or 
       event == "UPDATE_EXAMPRINT" or event == "UPDATE_JUSTICE" or event == "UPDATE_PRESTIGE" or
       event == "TITLE_POINT_UPDATE" or event == "UPDATE_ACHIEVEMENT_POINT" or 
       event == "UPDATE_ACHIEVEMENT_COUNT" or 
	   event == "UPDATE_ARENAAWARD" or
	   event == "ON_SYNC_TA_EQUIPS_SCORE" then
       
	   MainMessageLine.UpdateValue(this)
	   if event == "CONTRIBUTION_UPDATE" then
			local hObject = MainMessageLine.GetItemObject(this, g_tStrings.STR_CURRENT_CONTRIBUTION)
			if hObject then
				local text = hObject:Lookup("Text_Title")
				FireHelpEvent("OnCommentToKnowGuild", text, 2)
			end
		end
    end
end

function MainMessageLine.OnFrameDragEnd()
	this:CorrectPos()
	MainMessageLine.Anchor = GetFrameAnchor(this)
end

function MainMessageLine.UpdateAnchor(frame)
	frame:SetPoint(MainMessageLine.Anchor.s, 0, 0, MainMessageLine.Anchor.r, MainMessageLine.Anchor.x, MainMessageLine.Anchor.y)
	frame:CorrectPos()
end

function MainMessageLine.initIndex()
    for k, v in ipairs(lc_tSetting) do
        lc_tSettingIndex[v.name] = k
    end
end

function MainMessageLine.isItemShow(szName)
    for _, name in ipairs(OBJECT.tShow) do
        if name == szName then
            return true;
        end
    end
    return false
end

function MainMessageLine.UpdateValue(frame)
	local hList = lc_MainList
	local nCount = hList:GetItemCount() - 1
	for i=0, nCount, 1 do
		local hItem = hList:Lookup(i)
		local nW, nH = hItem:GetSize()
		hItem:SetSize(nW + 100, nH)
		local tOption = MainMessageLine.getSetting(hItem.itemName)
		OBJECT[tOption.fnAddHandle](hList, tOption.name, hItem)
        hItem.itemName = tOption.name;
	end
	hList:FormatAllItemPos();
end

function MainMessageLine.updateShow(frame)
	local hList = lc_MainList

	frame.bIniting = true
	hList:Clear()
	frame.bIniting = false
	
    lc_tBreatheUpdate = {}
    for _, name in ipairs(OBJECT.tShow) do
        local tOption = OBJECT.getSetting(name)
        local hItem = OBJECT[tOption.fnAddHandle](hList, tOption.name)
        hItem.itemName = tOption.name;
        if tOption.name == SHOW_ITEM.FPS or 
        tOption.name == SHOW_ITEM.ONLINE_DELAY or
        tOption.name == SHOW_ITEM.CPU or 
        tOption.name == SHOW_ITEM.WORK_SET
        then
            local nIndex = hItem:GetIndex()
            table.insert(lc_tBreatheUpdate, {nIndex=nIndex, fn=OBJECT.getCommomValue})
        end
    end

    hList:FormatAllItemPos();
end

function MainMessageLine.getSetting(szName)
    local nIndex = lc_tSettingIndex[szName]
    return lc_tSetting[nIndex]
end

function MainMessageLine.PopupDungeonMenu()
	local player = GetClientPlayer()
	local bCanReset = false
	if not player.IsInParty() or player.IsPartyLeader() then
		bCanReset = true
	end
	
	local tMenu = 
	{
		{
			szOption = g_tStrings.STR_DUNGEON_OPEN, 
			bDisable = false, 
			fnAction = function() 
				OpenDungeonInfoPanel() 
			end, 
			fnAutoClose = function() return true end, 
		},
		
		{
			szOption = g_tStrings.STR_DUNGEON_MODE, fnAutoClose = function() return true end, 
			{szOption = g_tStrings.STR_DUNGEON_NORMAL_MODE, bMCheck = true, bChecked = (player.bHeroFlag == false), fnAction = function() player.bHeroFlag = false end, fnAutoClose = function() return true end},
			{szOption = g_tStrings.STR_DUNGEON_HARD_MODE, bDisable = (player.nLevel < 70), bMCheck = true, bChecked = player.bHeroFlag, fnAction = function() player.bHeroFlag = true end, fnAutoClose = function() return true end},
		},
		{
			 szOption = g_tStrings.STR_DUNGEON_RESET, 
			 bDisable = not bCanReset,
			 fnAction = function()
			 	RemoteCallToServer("OnResetMapRequest", 0)
			 end, 
			 
			 fnAutoClose = function() return true end, 
		 },
	}
	PopupMenu(tMenu)
end


function MainMessageLine.menuCheck(szName)
    local bShow = false;
    for k, name in ipairs(OBJECT.tShow) do
        if name == szName then
            table.remove(OBJECT.tShow, k)
            bShow = true
            break;
        end
    end
    if not bShow then
        table.insert(OBJECT.tShow, szName)
    end
    OBJECT.updateShow(lc_Frame)
end

function MainMessageLine.normalHideCheck()
    OBJECT.bNormalHide = not OBJECT.bNormalHide 
    if OBJECT.bNormalHide then
        OBJECT.HideMainLine()
    else
        OBJECT.ShowMainLine()
    end
end

function MainMessageLine.createMenu()
    local menu = {}
    for k, t in ipairs(lc_tMenuGroup) do
        table.insert(menu, {szOption = t.name, bNotHead = true})
        for _, itemName in ipairs(t.tItem) do
            table.insert(menu, {szOption = itemName, bCheck=true, bChecked = OBJECT.isItemShow(itemName), fnAction=function() OBJECT.menuCheck(itemName) end })
        end
        table.insert(menu, {bDevide = true})
    end
    table.insert(menu, {szOption = g_tStrings.STR_HIDE_INFO_BAR, bCheck=true, bChecked=OBJECT.bNormalHide, fnAction=function() OBJECT.normalHideCheck() end})
    return menu
end

function MainMessageLine.adjustSize()
    local w, h= Station.GetClientSize()
    local oldW, oldH = lc_Frame:GetSize()
    local nDelta = w - oldW
    lc_Frame:SetSize(oldW + nDelta, oldH)
    
    local hMain = lc_Frame:Lookup("", "")
    oldW, oldH = hMain:GetSize()
    hMain:SetSize(oldW + nDelta, oldH)
    
    local nCount = hMain:GetItemCount()
    for i = 0, nCount - 1, 1 do
        local hItem = hMain:Lookup(i)
        oldW, oldH = hItem:GetSize()
        hItem:SetSize(oldW + nDelta, oldH)
    end
end

function MainMessageLine.HideMainLine()
    local hMain = lc_Frame:Lookup("", "")
    local nCount = hMain:GetItemCount()
    for i = 0, nCount - 1, 1 do
        hMain:Lookup(i):Hide()
    end
    lc_Frame:Lookup("Btn_Settings"):Hide()
end

function MainMessageLine.ShowMainLine()
    local hMain = lc_Frame:Lookup("", "")
    local nCount = hMain:GetItemCount()
    for i = 0, nCount - 1, 1 do
        hMain:Lookup(i):Show()
    end
    lc_Frame:Lookup("Btn_Settings"):Show()
end

function MainMessageLine.IsLink2OpenPanel(name)
    if name == SHOW_ITEM.BANG_GONG or 
        name == SHOW_ITEM.JIAN_BEN or name == SHOW_ITEM.XIA_YI or 
        name == SHOW_ITEM.MOENY or name == SHOW_ITEM.TONG_BAO or
        name == SHOW_ITEM.JH_ZHILI or name == SHOW_ITEM.FENGYUN_LU or 
        name == SHOW_ITEM.EQUIP_SEARCH or name == SHOW_ITEM.MI_JING or
		name == SHOW_ITEM.ZJ_JIFEN or name == SHOW_ITEM.WEI_WANG or 
		name == SHOW_ITEM.ARENA_AWARD then
        return true
    elseif name == SHOW_ITEM.ZJ_LEVEL then
        local player = GetClientPlayer()
        if player.nCamp == CAMP.NEUTRAL then
            return false
        end
        return true;
    end
    return false;
end

function MainMessageLine.UpdateFont(hItem, bOver)
	if lc_Frame.bIniting then
		return
	end
	
    local szName = hItem:GetName()
    if szName == "Handle_Currency" or szName == "Handle_Info" then
        local text = hItem:Lookup("Text_Title")
        local nFont = hItem.nTitleFont
        if bOver then
            hItem.nTitleFont = text:GetFontScheme()
            nFont = OVER_FONT
        end
        text:SetFontScheme(nFont)
        
        text = hItem:Lookup("Text_Content")
        nFont = hItem.nContentFont
        if bOver then
            hItem.nContentFont = text:GetFontScheme()
            nFont = OVER_FONT
        end
        text:SetFontScheme(nFont)
    elseif szName == "Handle_Money" then
        local text = hItem:Lookup("Text_Money")
        local nFont = hItem.nTitleFont
        if bOver then
            hItem.nTitleFont = text:GetFontScheme()
            nFont = OVER_FONT
        end
        text:SetFontScheme(nFont)
        
        text = hItem:Lookup("Text_Gold")
        nFont = hItem.nGoldFont
        if bOver then
            hItem.nGoldFont = text:GetFontScheme()
            nFont = OVER_FONT
        end
        text:SetFontScheme(nFont)
        
        text = hItem:Lookup("Text_sliver")
        nFont = hItem.nSliverFont
        if bOver then
            hItem.nSliverFont = text:GetFontScheme()
            nFont = OVER_FONT
        end
        text:SetFontScheme(nFont)
        
        text = hItem:Lookup("Text_copper")
        nFont = hItem.nCopperFont
        if bOver then
            hItem.nCopperFont = text:GetFontScheme()
            nFont = OVER_FONT
        end
        text:SetFontScheme(nFont)
    elseif szName == "Handle_Link" then
        local text = hItem:Lookup("Text_Title")
        local nFont = hItem.nTitleFont
        if bOver then
            hItem.nTitleFont = text:GetFontScheme()
            nFont = OVER_FONT
        end
        text:SetFontScheme(nFont)
    end
end

--mouse -----------------------------------------------
function MainMessageLine.OnLButtonClick()
    local szName = this:GetName()
    if szName == "Btn_Settings" then
        local tMenu = MainMessageLine.createMenu()
        PopupMenu(tMenu)
    end
end

function MainMessageLine.OnItemLButtonDown()
    local szName = this:GetName()
    
    if this.itemName then
        local name = this.itemName
        local szLinkInfo = MainMessageLine.GetCurrencyLinkInfo(name)
        if szLinkInfo and szLinkInfo ~= "" then
            FireUIEvent("EVENT_LINK_NOTIFY", szLinkInfo)
        elseif name == SHOW_ITEM.BANG_GONG then
            OpenGuildPanel()
        elseif name == SHOW_ITEM.ZJ_LEVEL then
            CloseCharacterPanel()
            OpenCharacterPanel(nil, "CAMP")
        elseif name == SHOW_ITEM.JIAN_BEN or name == SHOW_ITEM.XIA_YI then
            OpenCurrencyPanel()
        elseif name == SHOW_ITEM.MOENY or name == SHOW_ITEM.TONG_BAO then
            OpenAllBagPanel()
        elseif name == SHOW_ITEM.JH_ZHILI or name == SHOW_ITEM.FENGYUN_LU then
            OpenAchievementPanel()
        elseif name == SHOW_ITEM.EQUIP_SEARCH then
            OpenEquipInquire()
        elseif name == SHOW_ITEM.MI_JING then
            OpenDungeonInfoPanel()    
        end
    end
end

function MainMessageLine.OnItemRButtonDown()
    local szName = this:GetName()
    
    if this.itemName then
        local name = this.itemName
        local tOption = OBJECT.getSetting(name)
        if tOption and tOption.menu then
            OBJECT[tOption.menu]()
        end
    end
end

function MainMessageLine.OnItemMouseEnter()
    local szName = this:GetName()
    if this.itemName then
    	local x, y = this:GetAbsPos()
        local w, h = this:GetSize()
    
        local tOption = OBJECT.getSetting(this.itemName)
        if tOption and tOption.fnTip then
            local szTip = OBJECT[tOption.fnTip](this.itemName);
            OutputTip(szTip, 400, {x, y, w, h})
        end
        if OBJECT.IsLink2OpenPanel(this.itemName) then
            OBJECT.UpdateFont(this, true)
        end
        
    elseif OBJECT.bNormalHide then
        OBJECT.ShowMainLine()
    end
    lc_bMouseLeave = false;
end

function MainMessageLine.OnItemMouseLeave()
    local szName = this:GetName()
    if this.itemName  then
        HideTip()
        
        if OBJECT.IsLink2OpenPanel(this.itemName) then
            OBJECT.UpdateFont(this, false)
        end
    end
    lc_bMouseLeave = true;
end

function MainMessageLine.OnMouseEnter()
    lc_bMouseLeave = false;
end

function MainMessageLine.OnMouseLeave()
    lc_bMouseLeave = true;
end


--mouse end-----------------------------------------------
function MainMessageLine.linkTip(szName)
    local szTip = GetFormatText(szName)
    if GET_DESC[szName] then
        if GET_DESC[szName].shortCut then
            szTip = szTip .. GetFormatText(GET_DESC[szName].shortCut)
        end
        szTip = szTip .. GetFormatText("\n"..GET_DESC[szName].text, 163)
    end
    return szTip
end

function MainMessageLine.commomTip(szName)
    local nValue = OBJECT.getCommomValue(szName)
    szTip = GetFormatText(szName..g_tStrings.STR_COLON..nValue)
    if GET_DESC[szName] then
        szTip = szTip .. GetFormatText("\n"..GET_DESC[szName].text, 163)
    end
    return szTip
end

function MainMessageLine.currencyTip(szName)
    local nCount, nMaxCount, nLimit = OBJECT.GetCurrencyNumber(szName)
    
    if szName == SHOW_ITEM.ZJ_JIFEN then
       szTip = GetFormatText(szName..g_tStrings.STR_COLON..nCount)
       szTip = szTip..GetFormatText("\n" ..GetString("STR_CAMP_RANKLINE")..nMaxCount .. "%")
    else
        szTip = GetFormatText(szName..g_tStrings.STR_COLON..nCount.."/"..nMaxCount)
    end
        
    if nLimit then
        szTip = szTip .. GetFormatText("\n"..g_tStrings.STR_CURRENCY_REMAIN_GET .. nLimit)
    end
    if GET_DESC[szName] then
        szTip = szTip .. GetFormatText("\n"..GET_DESC[szName].text, 163)
    end
    return szTip
end

function MainMessageLine.GetCurrencyNumber(szName)
    local player = GetClientPlayer()

    if szName == SHOW_ITEM.BANG_GONG then
        local levelUp = GetLevelUpData(player.nRoleType, player.nLevel)
        local nMaxContribution = levelUp['MaxContribution'] or 0
        local nLimit = player.GetContributionRemainSpace()
        return player.nContribution, nMaxContribution, nLimit
        
    elseif szName == SHOW_ITEM.XIA_YI then
        local nMaxCount = player.GetMaxJustice()
        local nLimit = player.GetJusticeRemainSpace()
        return player.nJustice, nMaxCount, nLimit
        
    elseif szName == SHOW_ITEM.WEI_WANG then
        local nLimit = player.GetPrestigeRemainSpace()
        return player.nCurrentPrestige, player.GetMaxPrestige(), nLimit
        
    elseif szName == SHOW_ITEM.ZJ_JIFEN then
        return player.nTitlePoint , player.GetRankPointPercentage()
        
    elseif szName == SHOW_ITEM.JIAN_BEN then
        local nMaxCount = player.GetMaxExamPrint()
        local nLimit  = player.GetExamPrintRemainSpace()
        
        return player.nExamPrint, nMaxCount, nLimit 
		
    elseif szName == SHOW_ITEM.ARENA_AWARD then
        local nMaxCount = player.GetMaxArenaAward()
        local nLimit  = player.GetArenaAwardRemainSpace()
        
        return player.nArenaAward, nMaxCount, nil
    end
    return 0
end

function MainMessageLine.getCommomValue(szName)
    local player = GetClientPlayer();
    if szName == SHOW_ITEM.JH_ZHILI then --江湖资历
        local nValue = player.GetAchievementRecord()
        return nValue
    elseif szName == SHOW_ITEM.ZJ_LEVEL then
        local nValue = player.nTitle
        return nValue
    elseif szName == SHOW_ITEM.FPS then
        local fps = GetFPS()
        local nFont = OBJECT.getFPSFont(fps)
        return fps, nFont
    elseif szName == SHOW_ITEM.ONLINE_DELAY then
        local pingTime = GetPing()
        local nFont = OBJECT.getPingFont(pingTime)
        return pingTime, nFont
     elseif szName == SHOW_ITEM.CPU then
        local nCpu = GetCpuUsage()
        
        return nCpu .. "%"
    elseif szName == SHOW_ITEM.WORK_SET then
        local nWorkSet = GetWorkSet()
        
        return math.ceil(nWorkSet / 1024) .. " M"
	elseif szName == SHOW_ITEM.MENTOR_SCORE then
		return player.dwTAEquipsScore
    end
    return 0
end

local function LookupChangeObject(hItem, szName, szChangeName)
    local textTitle = hItem:Lookup(szName)
	if textTitle then
		textTitle:SetName(szChangeName)
	else
		textTitle = hItem:Lookup(szChangeName)
    end
	return textTitle
end

function MainMessageLine.addLink(handle, szName, hItem)
    local player = GetClientPlayer();
	if not hItem then
		hItem = handle:AppendItemFromIni(INI_FILE, "Handle_Link");
	end
    local tOption = MainMessageLine.getSetting(szName)
    
    local textTitle = LookupChangeObject(hItem, "Text_TitleL", "Text_Title")
	textTitle:SetText(szName.." ")
	textTitle:AutoSize()
	
    local image = hItem:Lookup("Image_IconL")
    if tOption.nFrame and tOption.uitex then
        image:FromUITex(tOption.uitex, tOption.nFrame)
    else
        image:SetSize(0, 0);
    end
    
    hItem:FormatAllItemPos();
    hItem:SetSizeByAllItemSize();
    return hItem
end

function MainMessageLine.addCommom(handle, szName, hItem)
    local player = GetClientPlayer();
	if not hItem then
		hItem = handle:AppendItemFromIni(INI_FILE, "Handle_Info");
	end
	
	local text = LookupChangeObject(hItem, "Text_ContentI", "Text_Content")
    
    local textTitle = LookupChangeObject(hItem, "Text_TitleI", "Text_Title")
    textTitle:SetText(szName..g_tStrings.STR_COLON)

	local nValue, nFont1 = MainMessageLine.getCommomValue(szName)
	local nFont = text:GetFontScheme()
	if nFont1 ~= nil then
		nFont = nFont1
	end
	text:SetText(nValue)
	text:SetFontScheme(nFont)
	
	text:AutoSize()
    --hItem:AppendItemFromString(GetFormatText("   "))
    hItem:FormatAllItemPos();
    hItem:SetSizeByAllItemSize();
    return hItem
end

function MainMessageLine.addMoney(handle, szName, hItem)
	if not hItem then
		hItem = handle:AppendItemFromIni(INI_FILE, "Handle_Money");
	end
	
    local nMoney = GetClientPlayer().GetMoney()
    local nGold, nSilver, nCopper = MoneyToGoldSilverAndCopper(nMoney)
    local textGold = hItem:Lookup("Text_Gold")
    local textSliver = hItem:Lookup("Text_sliver")
    local textCopper = hItem:Lookup("Text_copper")
    textGold:SetText(nGold)
    textSliver:SetText(nSilver)
    textCopper:SetText(nCopper)
    --hItem:AppendItemFromString(GetFormatText("   "))
    hItem:FormatAllItemPos();
    hItem:SetSizeByAllItemSize();
    return hItem
end

function MainMessageLine.addCurrency(handle, szName, hItem)
    local nCount = 0
    if szName == SHOW_ITEM.TONG_BAO then
        nCount = GetClientPlayer().nCoin
    else
        nCount = OBJECT.GetCurrencyNumber(szName)
    end
    
    local tOption = OBJECT.getSetting(szName)
	if not hItem then
		hItem = handle:AppendItemFromIni(INI_FILE, "Handle_Currency")
	end
	
    local textTitle = hItem:Lookup("Text_Title")
    local textContent = hItem:Lookup("Text_Content")
    local img = hItem:Lookup("Image_Icon")
    
    textTitle:SetText(szName..g_tStrings.STR_COLON)
    textContent:SetText(nCount.." ")
	textContent:AutoSize()
	
    img:SetFrame(tOption.nFrame)
    --hItem:AppendItemFromString(GetFormatText("   "))
    hItem:FormatAllItemPos();
    hItem:SetSizeByAllItemSize();
    return hItem
end

function OpenMainMessageLine()
    local frame = Wnd.OpenWindow("MainMessageLine")
end

function MainMessageLine_SetAnchorDefault()
	MainMessageLine.Anchor.s = MainMessageLine.DefaultAnchor.s
	MainMessageLine.Anchor.r = MainMessageLine.DefaultAnchor.r
	MainMessageLine.Anchor.x = MainMessageLine.DefaultAnchor.x
	MainMessageLine.Anchor.y = MainMessageLine.DefaultAnchor.y
	FireEvent("MAINMESSAGELINE_ANCHOR_CHANGED")
end

function MainMessageLine.IsNotExistItem(name)
    for k, v in pairs(SHOW_ITEM) do
        if (v == name) then
            return false;
        end
    end
    return true;
end

function MainMessageLine.IsItemShow(name)
    for _, v in pairs(MainMessageLine.tShow) do
        if (v == name) then
            return true;
        end
    end
    return false;
end


function MainMessageLine.GetCurrencyLinkInfo(szItemName)
    local nCount = g_tTable.Currency:GetRowCount()
	for i = 2, nCount do
		local tLine = g_tTable.Currency:GetRow(i)
		if tLine.szName == szItemName then
			return tLine.szLinkInfo
		end
	end
	return
end

function MainMessageLine.OnLoadData()
    if CURRENT_VERSION ~= MainMessageLine.nVersion then
        if MainMessageLine.nVersion == 0 then
            MainMessageLine.ProcessVersion0()
        end
    end
    MainMessageLine.nVersion = CURRENT_VERSION
    local nSize = #MainMessageLine.tShow
    for i=nSize, 1, -1 do
        local name = MainMessageLine.tShow[i]
        if MainMessageLine.IsNotExistItem(name) then
            table.remove(MainMessageLine.tShow, i);
        end
    end
    
    local frame = Station.Lookup("Normal/MainMessageLine")
    if frame and GetClientPlayer() then
        MainMessageLine.UpdateAnchor(frame)
        MainMessageLine.updateShow(frame)
    end
end

function MainMessageLine.GetItemObject(frame, szName)
	if frame and frame:IsVisible() then
		local hList = frame:Lookup("", "Handle_MainMessage")
		if hList and hList:IsVisible() then
			local nCount = hList:GetItemCount() - 1
			for i=0, nCount, 1 do
				local hItem = hList:Lookup(i)
				if hItem and hItem.itemName == szName then
					return hItem
				end
			end
		end
	end
end

local function OnCurrentFirstGet()
	local szType = arg0
	local tMap = 
	{
		["OnGetContribution"] = SHOW_ITEM.BANG_GONG,
		["OnFirstGetJustice"] = SHOW_ITEM.XIA_YI,
		["OnFirstGetPrestige"] = SHOW_ITEM.WEI_WANG,
		["OnFirstGetPointTitle"] = SHOW_ITEM.ZJ_JIFEN,
		["OnFirstGetArenaAware"] = SHOW_ITEM.ARENA_AWARD,
		["OnFirstGetExamPrint"] = SHOW_ITEM.JIAN_BEN,
		["OnFirstGetCoin"] = SHOW_ITEM.TONG_BAO,
		["OnFirstGetJHZILI"] = SHOW_ITEM.JH_ZHILI,
		["OnFirstGetMentorScore"] = SHOW_ITEM.MENTOR_SCORE
	}
	if tMap[szType] then
		local nType = tMap[szType]
		if not MainMessageLine.IsItemShow(nType) then
			table.insert(MainMessageLine.tShow, nType)
			local frame = Station.Lookup("Normal/MainMessageLine")
			if frame then
				MainMessageLine.updateShow(frame)
			end
		end
	end
end

RegisterEvent("CURRENCY_FIRST_GET", OnCurrentFirstGet)
RegisterEvent("CUSTOM_DATA_LOADED", MainMessageLine.OnLoadData)
RegisterEvent("CUSTOM_UI_MODE_SET_DEFAULT", MainMessageLine_SetAnchorDefault)
RegisterEvent("SYNC_ROLE_DATA_END", function() OpenMainMessageLine() end)