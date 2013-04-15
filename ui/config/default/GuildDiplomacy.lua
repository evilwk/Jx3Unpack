GuildDiplomacy = 
{
    
}
local FONT_XUANZHAN = 157

local l_tXuanZhanParam = 
{
    {nIndex=0, time=1, cost=50, cost1=100},
    {nIndex=1, time=3, cost=150, cost1=300},
    {nIndex=2, time=5, cost=250, cost1=500},
}

local l_hFrame = nil
--=帮会宣战
local l_hWndXuanZhan = nil
local l_hWndTab1 = nil
local l_hWndTab2 = nil

local INI_FILE = "ui/Config/Default/GuildPanel.ini"

function GuildDiplomacy.InitObject(frame)
    l_hFrame = frame
    l_hWndXuanZhan = frame:Lookup("PageSet_Total/Page_Diplomatic/Wnd_GuildDeclaration")
    l_hWndTab1 = l_hWndXuanZhan:Lookup("Wnd_Declaration")
    l_hWndTab2 = l_hWndXuanZhan:Lookup("Wnd_Promised")
end

function GuildDiplomacy.OnCreate(frame)
    GuildDiplomacy.InitObject(frame)
    l_hWndTab1:Show()
    l_hWndTab1:Lookup("Edit_BgName"):SetText("")
    l_hWndTab1:Lookup("Btn_Announced"):Enable(false)
    
    local text = l_hWndTab1:Lookup("Btn_BgTime"):Lookup("", ""):Lookup(0)
    text:SetText(l_tXuanZhanParam[1].time .. g_tStrings.STR_BUFF_H_TIME_H)
    text.value = 1
    
    l_hWndTab2:Hide()
    
    l_hWndXuanZhan:Lookup("CheckBox_Declaration"):Check(true)
    l_hWndXuanZhan:Lookup("CheckBox_Promised"):Check(false)
    
    local hI = l_hWndXuanZhan:GetParent():Lookup("", "Handle_List_3"):Lookup("HI_GuildDeclaration")
    GuildPanel.SelectPage(hI)
    
    GuildDiplomacy.UpdateXiaohaoDian()
    GuildDiplomacy.UpdateTime()
end

function GuildDiplomacy.InitWhenOpen(frame)
    GuildDiplomacy.InitObject(frame)
    if GuildDiplomacy.IsXuanZhanPageVisible() then
        if l_hWndTab1:IsVisible() then
            GuildDiplomacy.UpdateTime()
            GuildDiplomacy.UpdateXuanZhanBtn()
        elseif l_hWndTab2:IsVisible() then
            local player = GetClientPlayer()
            local tData = GetTongDiplomacyList(player.dwTongID, TONG_DIPLOMACY_RELATION_TYPE.WAR)
            GuildDiplomacy.UpdateYingZhanList(tData)
        end
    end
end

function GuildDiplomacy.OnFrameBreathe()
    if not GuildDiplomacy.nCount or GuildDiplomacy.nCount == 8 then
        GuildDiplomacy.nCount = 0
    else
        GuildDiplomacy.nCount = GuildDiplomacy.nCount + 1
    end
    
    if GuildDiplomacy.nCount == 0 and GuildDiplomacy.IsXuanZhanPageVisible() and l_hWndTab1:IsVisible() then
        GuildDiplomacy.UpdateTime()
    end
end

function GuildDiplomacy.OnEvent(szEvent)
    if szEvent == "UPDATE_TONG_INFO_FINISH" then
        if GuildDiplomacy.IsXuanZhanPageVisible() and l_hWndTab1:IsVisible() then 
            GuildDiplomacy.UpdateTime()
            GuildDiplomacy.UpdateXuanZhanBtn()
        end
    elseif szEvent == "UPDATE_TONG_DIPLOMACY_INFO" or szEvent == "UPDATE_TONG_SIMPLE_INFO" then
        if GuildDiplomacy.IsXuanZhanPageVisible() and l_hWndTab2:IsVisible() then
            local player = GetClientPlayer()
            local tData = GetTongDiplomacyList(player.dwTongID, TONG_DIPLOMACY_RELATION_TYPE.WAR)
            GuildDiplomacy.UpdateYingZhanList(tData)
        end
    end
end

--====宣战==========================================
function GuildDiplomacy.IsXuanZhanCanRequest()
    local guild = GetTongClient()
    local nEndTime = guild.nNextDiplomacyWarTime or 0
    local nLeftTime = nEndTime - GetCurrentTime();
    return nLeftTime <= 0
end

function GuildDiplomacy.UpdateXuanZhanBtn()
    local hBtn = l_hWndTab1:Lookup("Btn_Announced")
    local edit = l_hWndTab1:Lookup("Edit_BgName")
    local szText = edit:GetText()
    if szText and szText ~= "" and GuildDiplomacy.IsXuanZhanCanRequest() then
        hBtn:Enable(true)
    else
        hBtn:Enable(false)
    end
end

function GuildDiplomacy.UpdateTime()
    local guild = GetTongClient()
    local nEndTime = guild.nNextDiplomacyWarTime or 0
    local nLeftTime = nEndTime - GetCurrentTime();
    local text = l_hWndTab1:Lookup("", "Text_TimeRemainingDisplay")
    if nLeftTime < 0 then
        nLeftTime = 0
    end
    
    if nLeftTime ~= text.nLeftTime then
        local szText = GuildDiplomacy.GetTimeText(nLeftTime)
        text:SetText(szText);
        text.nLeftTime = nLeftTime
        if nLeftTime == 0 then
            GuildDiplomacy.UpdateXuanZhanBtn()
        end
    end
end

function GuildDiplomacy.UpdateXiaohaoDian()
    local text = l_hWndTab1:Lookup("Btn_BgTime"):Lookup("", ""):Lookup(0)
    local nIndex = text.value
    local tParam = l_tXuanZhanParam[nIndex]
    l_hWndTab1:Lookup("", "Text_ConsumptionDisplay"):SetText(tParam.cost..g_tStrings.GUILD_DIPLOMACY_POINT0)
    l_hWndTab1:Lookup("", "Text_ConsumptionDisplay1"):SetText(tParam.cost1..g_tStrings.GUILD_DIPLOMACY_POINT1)
end


function GuildDiplomacy.RequestDeclareWar()
    local edit = l_hWndTab1:Lookup("Edit_BgName")
    local text = l_hWndTab1:Lookup("Btn_BgTime"):Lookup("", ""):Lookup(0)
    local nIndex = l_tXuanZhanParam[text.value].nIndex
    local szTongName = edit:GetText()
    
    RemoteCallToServer("On_Tong_DeclareWarRequest", szTongName, nIndex)
end

--==========宣战 end================================================

function GuildDiplomacy.UpdateYingZhanList(tData)
    local hList = l_hWndTab2:Lookup("", "Handle_ListPromised")
    hList:Clear()
    
    tData = tData or {}
    local player = GetClientPlayer()
    for _, tTong in ipairs(tData) do
        local nLeftTime = tTong.nEndTime - GetCurrentTime()
        if  nLeftTime > 0 then
            
            local dwTongID = tTong.dwDstTongID
            local szState = g_tStrings.GUILD_DIPLOMACY_XUANZHAN
            if tTong.dwDstTongID == player.dwTongID then
                dwTongID = tTong.dwSrcTongID
                szState = g_tStrings.GUILD_DIPLOMACY_YINGZHAN
            end
            local tTong = GetTongSimpleInfo(dwTongID)
            if tTong then
                local hItem = hList:AppendItemFromIni(INI_FILE, "HI_ItemListP")
                if szState == g_tStrings.GUILD_DIPLOMACY_XUANZHAN then
                    hItem:SetIndex(0)
                    hItem:Lookup("Text_ListPromisedName"):SetFontScheme(FONT_XUANZHAN)
                    hItem:Lookup("Text_ListCamp"):SetFontScheme(FONT_XUANZHAN)
                    hItem:Lookup("Text_ListCount"):SetFontScheme(FONT_XUANZHAN)
                    hItem:Lookup("Text_ListTime"):SetFontScheme(FONT_XUANZHAN)
                end
                
                
                local szTongName = tTong.szTongName or ""
                local szCamp = g_tStrings.STR_CAMP_TITLE[tTong.nCamp]
                local szTime = GetTimeText(nLeftTime, false, true)
                
                hItem:Lookup("Text_ListPromisedName"):SetText(szTongName)
                hItem:Lookup("Text_ListCamp"):SetText(szCamp)
                hItem:Lookup("Text_ListCount"):SetText(szState)
                hItem:Lookup("Text_ListTime"):SetText(szTime)
            end
         end
    end
    
    FireUIEvent("SCROLL_UPDATE_LIST", hList:GetName(), "GuildPanel", true)
end
--=========common ================================
function GuildDiplomacy.PopupMenu(hBtn, text, tData)
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
                text.value = UserData.value
                GuildDiplomacy.UpdateXiaohaoDian()
			end
		end,
		fnAutoClose = function() return not IsGuildDiplomacyVisible() end,
	}
	for k, v in ipairs(tData) do
        table.insert(menu, {szOption = v.name, UserData= v, r = v.r, g = v.g, b = v.b})
	end
	PopupMenu(menu)
end

function GuildDiplomacy.GetTimeText(nTime, bFrame)
	if bFrame then
		nTime = nTime / GLOBAL.GAME_FPS
	end
	
	--local nD = math.floor(nTime / 3600 / 24)
	local nH = math.floor(nTime / 3600)
	local nM = math.floor((nTime % 3600) / 60)
	local nS = (nTime % 3600) % 60
	
	local szTimeText = ""
	if nH < 10 then
        nH = "0"..nH
    end
    
    if nM < 10 then
        nM = "0"..nM
    end
    
    if nS < 10 then
        nS = "0"..nS
    end
	return nH .. ":" .. nM .. ":" .. nS
end
--=========common end================================

--==============================================================
function GuildDiplomacy.OnLButtonDown()
    local szName = this:GetName()
    if szName == "Btn_BgTime" then
        local text = this:Lookup("", ""):Lookup(0)
        local tData = {}
        for i, tParam in ipairs(l_tXuanZhanParam) do
            table.insert(tData, {name=tParam.time..g_tStrings.STR_BUFF_H_TIME_H, value=i});
        end
        GuildDiplomacy.PopupMenu(this, text, tData)
        return true
    end
end

function GuildDiplomacy.OnLButtonClick()
    local szName = this:GetName()
    if szName == "Btn_Announced" then
        local szTongName = l_hWndTab1:Lookup("Edit_BgName"):GetText();
        local msg = 
		{
			szMessage = FormatString(g_tStrings.GUILD_DIPLOMACY_SURE, szTongName),
			szName = "GuildDiplomacyDeclareWar", 
			fnAutoClose = function() if not IsGuildPanelOpened() then return true end end,
			{szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = function() GuildDiplomacy.RequestDeclareWar() end},
			{szOption = g_tStrings.STR_HOTKEY_CANCEL}
		}
		MessageBox(msg)
    end
end

function GuildDiplomacy.OnCheckBoxCheck()
    local bProcess = true
    local szName = this:GetName()
    if szName == "CheckBox_Declaration" then
        l_hWndTab1:Show()
        l_hWndTab2:Hide()
        this:GetParent():Lookup("CheckBox_Promised"):Check(false)
        
        GuildDiplomacy.UpdateTime()
        GuildDiplomacy.UpdateXuanZhanBtn()
            
    elseif szName == "CheckBox_Promised" then
        l_hWndTab1:Hide()
        l_hWndTab2:Show()
        this:GetParent():Lookup("CheckBox_Declaration"):Check(false)
        
        local player = GetClientPlayer()
        local tData = GetTongDiplomacyList(player.dwTongID, TONG_DIPLOMACY_RELATION_TYPE.WAR)
        GuildDiplomacy.UpdateYingZhanList(tData)
    else
        bProcess = false;
    end
    return bProcess;
end

function GuildDiplomacy.OnEditChanged()
    local szName = this:GetName()
    if szName == "Edit_BgName" then
        GuildDiplomacy.UpdateXuanZhanBtn()
        return true;
    end
    return false
end

function GuildDiplomacy.OnDiplomacyPageActive()
    GuildDiplomacy.InitWhenOpen(l_hFrame)
end

--==============msg end===================================
function GuildDiplomacy.IsXuanZhanPageVisible()
    if not IsGuildDiplomacyVisible() then
        return false;
    end
    
    if l_hWndXuanZhan and l_hWndXuanZhan:IsVisible() then
        return true
    end
    return false;
end

--===========================================================

function IsGuildDiplomacyVisible()
    if not IsGuildPanelOpened() then
        return false;
    end
    
    local frame = Station.Lookup("Normal/GuildPanel")
    if not frame then 
        return false
    end
    
    local hPage = frame:Lookup("PageSet_Total/Page_Diplomatic")
    if hPage and hPage:IsVisible() then
        return true
    end
    
    return false
end

function IsInXuanZhanState()
    local player = GetClientPlayer()
    if player.dwTongID <= 0 then
        return false;
    end
    
    local tData = GetTongDiplomacyList(player.dwTongID, TONG_DIPLOMACY_RELATION_TYPE.WAR)
    if #tData > 0 then
        return true
    end
    return false
end

function RegisterGuildDiplomacyScroll()
    local szFramePath = "Normal/GuildPanel"
    local szWndPath = "PageSet_Total/Page_Diplomatic/Wnd_GuildDeclaration/Wnd_Promised"
    RegisterScrollControl(
        szFramePath, 
        szWndPath.."/Btn_ListPromisedUp", szWndPath.."/Btn_ListPromisedDown", 
        szWndPath.."/Scroll_ListPromised", 
        {szWndPath, "Handle_ListPromised"})
end

local function GuildDiplomacyChange()
    local player = GetClientPlayer()
    if player.SyncTongDiplomacyDate then
        player.SyncTongDiplomacyDate()
    end
    FireEvent("UPDATE_TONG_DIPLOMACY_INFO")
end
RegisterEvent("CHANGE_TONG_NOTIFY", GuildDiplomacyChange)

RegisterGuildDiplomacyScroll()