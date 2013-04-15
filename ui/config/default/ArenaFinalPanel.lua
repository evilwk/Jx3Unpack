ArenaFinalPanel = 
{
	bArenaEnd = false
}

local RED_FONT = 33
local BLUE_FONT = 35
local RED_BG = 13
local BLUE_BG = 15

local INI_FILE = "ui/config/default/ArenaFinalPanel.ini"
local OBJECT = ArenaFinalPanel
local lc_hFrame
local lc_hWndList
local lc_hList

local function IsEmptyTable(t)
	if not t then
		return true;
	end
	
	for k, v  in pairs(t) do
		return false
	end
	return true
end

function ArenaFinalPanel.OnFrameCreate()
	this:RegisterEvent("BATTLE_FIELD_SYNC_STATISTICS")
	this:RegisterEvent("SYNC_ARENA_STATISTICS")
	this:RegisterEvent("SYS_MSG")
	this:RegisterEvent("UI_SCALED")
	
	ArenaFinalPanel.OnEvent("UI_SCALED")
	ArenaFinalPanel.Init(this)
end

function ArenaFinalPanel.Init(hFrame)
	lc_hFrame = hFrame
	lc_hWndList = hFrame:Lookup("Wnd_List")
	lc_hList = lc_hWndList:Lookup("", "Handle_List")
	
	lc_hWndList:Lookup("", "Text_Time"):SetText("")
	ArenaFinalPanel.UpdateList()
end

function ArenaFinalPanel.OnEvent(event)
	if event == "UI_SCALED" then
		this:SetPoint("CENTER", 0, 0, "CENTER", 0, 0)
		
	elseif event == "BATTLE_FIELD_SYNC_STATISTICS" then
		ArenaFinalPanel.OnSyncPQ(this)
	
	elseif event == "SYNC_ARENA_STATISTICS" then
		ArenaFinalPanel.OnSyncArena(this)
	
	elseif szEvent == "SYS_MSG" then
		if arg0 == "UI_OME_BANISH_PLAYER" then
			if arg1 == BANISH_CODE.MAP_REFRESH or arg1 == BANISH_CODE.NOT_IN_MAP_OWNER_PARTY then
				this.nBanishTime = arg2 * 1000 + GetTickCount()
			elseif arg1 == BANISH_CODE.CANCEL_BANISH then
				this.nBanishTime = nil
			end
		end
	end
end

function ArenaFinalPanel.OnFrameBreathe()
	local hBanishText = this:Lookup("Wnd_List", "Text_WarningTime")
	local nCurTime = GetTickCount()
	if this.nBanishTime and this.nBanishTime > nCurTime  then
		local nTime = math.floor((this.nBanishTime - nCurTime) / 1000)
		hBanishText:SetText(FormatString(g_tStrings.STR_BATTLEFIELD_BANISH, nTime .. g_tStrings.STR_BUFF_H_TIME_S))
		hBanishText:Show()
	else
		this.nBanishTime = nil
		hBanishText:SetText("")
		hBanishText:Hide()
	end
end

function ArenaFinalPanel.OnSyncArena()
	local tStat = GetArenaStatistics() -- Arena_Test
	if not tStat or IsEmptyTable(tStat) then
		return
	end
	
	for k, v in pairs(tStat) do
		if not v.nKillCount then
			v.nKillCount = 0
		end
	end
	
	ArenaFinalPanel.tArenaStat = tStat
	
	ArenaFinalPanel.MergeData()
	ArenaFinalPanel.UpdateList();
end

function ArenaFinalPanel.OnSyncPQ()
	local tPQStat = GetBattleFieldStatistics()
	if not tPQStat or IsEmptyTable(tPQStat) then
		return
	end
	
	ArenaFinalPanel.tPQStat = tPQStat
	local _, _, nBeginTime, nEndTime  = GetBattleFieldPQInfo()
	local nCurrentTime = GetCurrentTime()
	if nBeginTime and nBeginTime > 0 then
		local nTime = 0
		if nEndTime ~= 0 and nCurrentTime > nEndTime then
			nTime = nEndTime - nBeginTime
		else
			nTime = nCurrentTime - nBeginTime
		end
		local szTime = GetTimeText(nTime)
		lc_hWndList:Lookup("", "Text_Time"):SetText(g_tStrings.STR_BATTLEFIELD_TIME_USED .. " " .. szTime)
	end
	
	ArenaFinalPanel.MergeData()
end

function ArenaFinalPanel.MergeData()
	if not OBJECT.tArenaStat or not OBJECT.tPQStat then
		return
	end
	
	local tTableIndex = {}
	for dwPlayerID, v in pairs(OBJECT.tPQStat) do
		OBJECT.tPQStat[dwPlayerID].dwPlayerID = dwPlayerID
		tTableIndex[v.Name] = v
	end
	
	for k, v in pairs(OBJECT.tArenaStat) do
		local t = tTableIndex[v.szPlayerName]
		if t then
			OBJECT.tArenaStat[k].nBattleFieldSide = t.BattleFieldSide
			OBJECT.tArenaStat[k].dwForceID = t.ForceID
			OBJECT.tArenaStat[k].nKillCount = t[PQ_STATISTICS_INDEX.DECAPITATE_COUNT]
			OBJECT.tArenaStat[k].nDamge = t[PQ_STATISTICS_INDEX.HARM_OUTPUT]
			OBJECT.tArenaStat[k].nHealth = t[PQ_STATISTICS_INDEX.TREAT_OUTPUT]
		end
	end
	ArenaFinalPanel.UpdateList();
end

function ArenaFinalPanel.UpdateList()
	local function fnCamp(a, b)
		if not a.nKillCount or not b.nKillCount then
			return true
		end
		
		return a.nKillCount > b.nKillCount
	end
	
	local tData = OBJECT.tArenaStat or {}
	table.sort(tData, fnCamp)
	
	local tCorpsID = {}
	lc_hList:Clear()
	for k, t in ipairs(tData) do
		local hItem = lc_hList:AppendItemFromIni(INI_FILE, "Handle_Player")
		
		if t.nBattleFieldSide == 1 then  		
			hItem:Lookup("Image_Bg"):SetFrame(BLUE_BG) -- 1 蓝色（Frame=15）
		else
			hItem:Lookup("Image_Bg"):SetFrame(RED_BG) --0 红色（Frame=13）
		end
		if t.nBattleFieldSide then
			tCorpsID[t.dwCorpsID] = t.nBattleFieldSide
		end
		
		hItem.dwCorpsID = t.dwCorpsID
		
		local szPath, nFrame = GetForceImage(t.dwForceID)
		hItem:Lookup("Image_School"):FromUITex(szPath, nFrame)
		
		hItem:Lookup("Text_Name"):SetText(t.szPlayerName)
		hItem:Lookup("Text_CorpsName"):SetText(t.szCorpsName)
		hItem:Lookup("Text_Kill"):SetText(t.nKillCount)
		hItem:Lookup("Text_Damage"):SetText(t.nDamge)
		hItem:Lookup("Text_Health"):SetText(t.nHealth)
		hItem:Lookup("Text_Level"):SetText(t.nCorpsLevel + t.nDeltaCorpsLevel)
		hItem:Lookup("Text_Score"):SetText(t.nDeltaCorpsLevel)
	end
	
	local nCount = lc_hList:GetItemCount() - 1
	for i=0, nCount, 1 do
		local hItem = lc_hList:Lookup(i)
		
		if tCorpsID[hItem.dwCorpsID] then
			if tCorpsID[hItem.dwCorpsID] == 1 then  
				hItem:Lookup("Image_Bg"):SetFrame(BLUE_BG) -- 1 蓝色（Frame=15）
			else
				hItem:Lookup("Image_Bg"):SetFrame(RED_BG) --0 红色（Frame=13）
			end
		end
	end
	FireUIEvent("SCROLL_UPDATE_LIST", lc_hList:GetName(), "ArenaFinalPanel", true)
end

local szCommonPanelName = "Arena"
local szCDPanelName = "ArenaCD"
function ArenaFinalPanel.UpdateArenaPlayerCountShow(tData)
	if not IsInArena() then
		return
	end
	
	if not IsCommonBlankPanelOpened(szCommonPanelName) then
		OpenCommonBlankPanel(nil, szCommonPanelName)
	end
	
	local hList = CommonBlankPanel_GetHandleContent(szCommonPanelName)
	hList:Clear();
	
	if tData then
		local nClientSide = GetClientPlayer().nBattleFieldSide
		local nOtherSide  = 0
		local nFontC = BLUE_FONT --蓝：35 
		local nFontO = RED_FONT -- 红：33
		if nClientSide == 0 then
			nOtherSide = 1
			nFontC = RED_FONT
			nFontO = BLUE_FONT
		end
		
		local szTip = FormatString(g_tStrings.STR_ARENA_SLEFT_TITLE, nFontC, tData[nClientSide] or 0)
		hList:AppendItemFromString(szTip)
		
		local szTip = FormatString(g_tStrings.STR_ARENA_OTHER_TITLE, nFontO, tData[nOtherSide] or 0)
		hList:AppendItemFromString(szTip)
	end
	hList:FormatAllItemPos()
end

--==============================================
function ArenaFinalPanel.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_Leave" then
		CloseArenaFinalPanel()
		LogOutArena()
	end
end

function IsArenaFinalPanelOpened()
	local hFrame = Station.Lookup("Normal/ArenaFinalPanel")
	if hFrame and hFrame:IsVisible() then
		return true
	end
	
	return false
end

function OpenArenaFinalPanel(bDisableSound)
	if IsArenaFinalPanelOpened() then
		return
	end
	
	lc_hFrame = Wnd.OpenWindow("ArenaFinalPanel")
	
	ArenaFinalPanel.tArenaStat = nil
	ArenaFinalPanel.tPQStat = nil
	ArenaFinalPanel.nClientSideCorpsID = nil
	ApplyArenaStatistics()
	ApplyBattleFieldStatistics()
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
end

function CloseArenaFinalPanel(bDisableSound)
	if not IsArenaFinalPanelOpened() then
		return
	end
	
	Wnd.CloseWindow("ArenaFinalPanel")
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end
end

function SwitchArenaFinalPanel()
	if IsArenaFinalPanelOpened() then
		CloseArenaFinalPanel(bDisableSound)
	else
		OpenArenaFinalPanel(bDiableSound)
	end
end

function IsArenaFinished()
	return ArenaFinalPanel.bArenaEnd
end

local function StartCDBreathe()
	if ArenaFinalPanel.nStartCountDown then
		local nLeftTime = ArenaFinalPanel.nStartCountDown
		if nLeftTime >= 0 then
			local nLeft = nLeftTime
			local hTotal = CommonBlankPanel_GetTotHandle(szCDPanelName)
			local img = hTotal:Lookup(0)
			if img.nCountDown ~= nLeft then
				if nLeft == 0 then
					--local frame = hTotal:GetRoot()
					--frame.Anchor = {s = "CENTER", r = "CENTER", x = -60, y = -200}
					--frame.UpdateAnchor(frame)
					img:FromTextureFile("ui/image/common/number_start.tga")
				else
					img:FromTextureFile("ui/image/common/number_"..nLeft..".tga")
				end
				img:AutoSize()
				img.nCountDown = nLeft
				img:SetAlpha(255)
			else
				local nAlpha = img:GetAlpha()
				nAlpha = nAlpha - 14
				if nAlpha <= 0 and nLeftTime == 0 then
					ArenaFinalPanel.nStartCountDown = nil
					CloseCommonBlankPanel(nil, szCDPanelName)
					return
				end
				
				if nAlpha < 0 then
					nAlpha = 255
				end
				img:SetAlpha(nAlpha)
			end
		end
	end
end

local function InitStartCDPanel()
	local tAnchor = {s = "CENTER", r = "CENTER", x = -20, y = -200}
	
	OpenCommonBlankPanel(nil, szCDPanelName, tAnchor, StartCDBreathe)
	local hTotal = CommonBlankPanel_GetTotHandle(szCDPanelName)
	hTotal:Clear()
	hTotal:AppendItemFromString("<image>x=0 y=0 </image>")
	
	hTotal:GetRoot():SetMousePenetrable(true)
	
	hTotal:FormatAllItemPos()
end

local function OnPlayerEnterScene()
	local hPlayer = GetClientPlayer()
	if hPlayer and hPlayer.dwID == arg0 then
		if not IsInArena() then
			CloseArenaFinalPanel()
			CloseCommonBlankPanel(nil, szCommonPanelName)
			CloseCommonBlankPanel(nil, szCDPanelName)
		else
			ArenaFinalPanel.bArenaEnd = false
			InitStartCDPanel()
		end
	end
end

local function OnArenaEnd()
	OpenArenaFinalPanel()
	ArenaFinalPanel.bArenaEnd = true
end

local function OnArenaEventNotify()
	local szEvent = arg0
	
	if szEvent == "PLAYER_UPDATE" then
		if IsInArena() then
			local tData = arg1
			ArenaFinalPanel.UpdateArenaPlayerCountShow(tData)
		end
	elseif szEvent == "START_COUNT_DOWN" then
		if IsInArena() then
			ArenaFinalPanel.nStartCountDown = arg1
		end
	end
end

RegisterEvent("OnArenaEventNotify", OnArenaEventNotify)
RegisterEvent("PLAYER_ENTER_SCENE", OnPlayerEnterScene)
RegisterEvent("ARENA_END", OnArenaEnd)

function ArenaStartCD_TestFun()
	InitStartCDPanel()
	ArenaFinalPanel.tCountInfo = {nStartTime = GetCurrentTime() + 15, nCount  = 5}
end

do
    RegisterScrollEvent("ArenaFinalPanel")
    
    UnRegisterScrollAllControl("ArenaFinalPanel")
        
    local szFramePath = "Normal/ArenaFinalPanel"
    local szWndPath = "Wnd_List"
    RegisterScrollControl(
        szFramePath, 
        szWndPath.."/Btn_Up", szWndPath.."/Btn_Down", 
        szWndPath.."/Scroll_S", 
        {szWndPath, "Handle_List"})
end