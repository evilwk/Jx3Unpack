------------------------------------------------
-- 文件名    :  MiddleMap.lua
-- 创建人    :  kingbeyond	
-- 创建时间  :  2007-5-22 18:30	
-- 用途(模块):  界面-中地图
------------------------------------------------
local nDynamicRequestTime = 60 * 1000
local MIDDLE_MAP_MIN_ALPHA = 128
local g_tDynamicMapID = 
{
	[25] = true,
	[27] = true,
}

MiddleMap = 
{
	w = 1024, h = 1024, scale = 0.001, startx = 0, starty = 0, nFlagCount = 6,
	nIndex  = 0, dwMapID = 0, bUI = false, scaleFinal = 0.001, nAlpha = 255,
	aInfo = {}, aFlag = {}, aArea = {}, aLoad = {}, aNpc = {},
	aShowFlag = {true, true, true, true, true, true, true},
    
	-- bShowAcceptedQuest = true,
	-- bShowAcceptedQuest这个标记去掉了，但是怕以后有人用了同样的变量，这个变量会被记在玩家本地，部分老玩家会有
	-- 所以以后尽量不用这个标记,特别是需要保存在本地的时候
	--bShowCanAcceptQuest = true,
	--bShowImportantNpc = true,
	bShowActivitySymbol = true,
	--bMapTraceQuest = false,
	tCanAcceptQuest = {},
	tFieldPQ = {},
	--szQuestShow = "ShowNoGray",
	tQuestFinishFrame = {szFrame = "ui/Image/QuestPanel/QuestPanel.UITex", Normal = 32, Over = 33, Check = 33},
	tQuestTargetFrame = {szFrame = "ui/Image/MiddleMap/MapWindow.UITex", Normal = 107, Over = 105, Check = 106},
	tTrafficFrame = {
		[0] = {Normal = 3, Over = 4, Self = 7, Disable = 6, Down = 5};
		[1] = {Normal = 12, Over = 13, Self = 11, Disable = 10, Down = 9};
	},
    
    tQuestShow = 
    {
        ["Normal"] = true,
        ["Repeat"] = true,
        ["Low"] = true,
        ["Lower"] = false,
    },
}

MiddleMap.tSelectNpc = {}
RegisterCustomData("MiddleMap.aShowFlag")
RegisterCustomData("MiddleMap.nAlpha")
RegisterCustomData("MiddleMap.aFlag")
--RegisterCustomData("MiddleMap.bShowCanAcceptQuest")
--RegisterCustomData("MiddleMap.szQuestShow")
--RegisterCustomData("MiddleMap.bShowImportantNpc")
RegisterCustomData("MiddleMap.bShowActivitySymbol")
--RegisterCustomData("MiddleMap.bMapTraceQuest")
RegisterCustomData("MiddleMap.tQuestShow")
RegisterCustomData("MiddleMap.tSelectNpc")

local INI_FILE_PATH = "UI/Config/Default/MiddleMap.ini"
local FONT_QUEST_NAME = 59
local FONT_QUEST_TARGET_NOT_FINISH = 0
local FONT_NOTE = 161
local NUMBER_BIT_SIZE = 32
local ACTIVITY_SYMBOL_REQUEST_INTERVAL = 1000 * 30

local SHOWFLAG_CHECKBUTTON_PREFIX = "CheckBox_"
local tQuestMarkRegion = 
{
	nX = 7, nY = 63, nW = 1033 , nH = 775,
}
local tFieldMarkStateFrame = 
{
	[0] = 242, --正常旗子
	[1] = 241, -- 蓝色旗子
	[2] = 240, -- 红色旗子
	[3] = 244, -- 马车
	[4] = 243, -- 骆驼
 }

local tNeedFieldMarkMap = 
{
	[50] = true,
	[121] = true,
}

local tActivityShieldMap =
{
	[27] = true,
	[25] = true,
}

local tExpendFrame = {Normal = 12, Expand = 8}

local szShowFlagImagePath = "ui/Image/Common/Money.UITex"
local tShowFlagFrame = {11, 5, 6, 7, 9, 10}
local tSelectNpcFrame = {UnCheckNormal = 27, UnCheckOver = 28, CheckNormal = 30, CheckOver = 29}
local tSelectAreaFrame = {UnSelectNormal = 58, UnSelectOver = 59, SelectNormal = 20, SelectOver = 60}


local function Table_GetMapDynamicData()
	if not MiddleMap.tDynamicParam then
		local tResult = {}
		local nCount = g_tTable.Map_DynamicData:GetRowCount()
		
		--Row One for default value
		for i = 2, nCount do
			local tData = g_tTable.Map_DynamicData:GetRow(i)
			tResult[tData.nType] = tData
		end	
		MiddleMap.tDynamicParam = tResult
	end
	return MiddleMap.tDynamicParam
end

function MiddleMap.OnFrameCreate()
	this:RegisterEvent("UI_SCALED")
	this:RegisterEvent("LOADING_END")
	this:RegisterEvent("LAST_DIE_POS_CHANGED")
	this:RegisterEvent("ON_MARK_QUEST_TARGET_PLACE")
	this:RegisterEvent("CUSTOM_DATA_LOADED")
	this:RegisterEvent("SELECT_QUEST_AREA")
	this:RegisterEvent("MARK_NPC")
	this:RegisterEvent("QUEST_ACCEPTED")
	this:RegisterEvent("QUEST_CANCELED")
	this:RegisterEvent("QUEST_FINISHED")
	this:RegisterEvent("QUEST_DATA_UPDATE")
	this:RegisterEvent("QUEST_LIST_UPDATE")
	this:RegisterEvent("DAILY_QUEST_UPDATE")
	this:RegisterEvent("SYNC_ROLE_DATA_END")
	this:RegisterEvent("PLAYER_REVIVE")
	this:RegisterEvent("ACTIVITY_SYMBOL_RESPOND")
	this:RegisterEvent("ON_TRACE_QUEST")
	
	local hMap = this:Lookup("", "Handle_Map")
	hMap:Lookup("Image_Map").bMap = true
	MiddleMap.nQuestCount = 0
	
	local hTeammate = hMap:Lookup("Handle_Teammate")
	hTeammate.bHandle = true
	hTeammate:Clear()
	
	hMap:Lookup("Handle_MapMark").bHandle = true
	
	this:Lookup("Scroll_Alpha"):SetScrollPos(MiddleMap.nAlpha)
	this:Lookup("", "Text_AlphaPer"):SetText(math.floor(100 * MiddleMap.nAlpha / 255).."%")
	MiddleMap.OnEvent("UI_SCALED")	
	
	this:Lookup("CheckBox_QuestPage"):Check(true)
	this:Lookup("CheckBox_ActiveNPC"):Check(MiddleMap.bShowActivitySymbol)
	
    for szKey, bShow in pairs(MiddleMap.tQuestShow) do
        local hCheckQuesShow = this:Lookup("CheckBox_QuestShow" .. szKey)
        hCheckQuesShow:Check(bShow)
    end
end

function MiddleMap.OnFrameBreathe()
	local player = GetClientPlayer()
	if not player then
		return
	end
	
	local handle = this:Lookup("", "Handle_Map")
	local x, y = handle:GetAbsPos()
	
	if player.GetScene().dwMapID == MiddleMap.dwMapID then
		local img = handle:Lookup("Image_Player")
		img:Show()
		img:SetRotate((255 - player.nFaceDirection) * 6.2832 / 255)
		img.x, img.y = player.nX, player.nY
		local wI, hI = img:GetSize()
		local xR, yR = MiddleMap.LPosToHPos(img.x, img.y, wI, hI)
		img:SetRelPos(xR, yR)
		img:SetAbsPos(x + xR, y + yR)
		
		local ani = handle:Lookup("Animate_Player")
		ani:Show()
		ani.x, ani.y = player.nX, player.nY
		wI, hI = ani:GetSize()
		xR, yR = MiddleMap.LPosToHPos(ani.x, ani.y, wI, hI)
		ani:SetRelPos(xR, yR)
		ani:SetAbsPos(x + xR, y + yR)
	else
		handle:Lookup("Image_Player"):Hide()
		handle:Lookup("Animate_Player"):Hide()
	end
	
	local nIndex = 0
	local hTeammate = handle:Lookup("Handle_Teammate")
	if player.IsInParty() then
		local hTeam = GetClientTeam()
		local nGroupNum = hTeam.nGroupNum
		for i = 0, nGroupNum - 1 do
			local tGroupInfo = hTeam.GetGroupInfo(i)
			if tGroupInfo and tGroupInfo.MemberList then
				for _, dwID in pairs(tGroupInfo.MemberList) do
					local tMemberInfo = hTeam.GetMemberInfo(dwID)
					if dwID ~= player.dwID and tMemberInfo.bIsOnLine and tMemberInfo.dwMapID == MiddleMap.dwMapID then
						local hFlag = hTeammate:Lookup(nIndex)
						if not hFlag then
							hFlag = hTeammate:AppendItemFromIni(INI_FILE_PATH, "Image_Teammate")
						end
						
						local wI, hI = hFlag:GetSize()
						local xR, yR = MiddleMap.LPosToHPos(tMemberInfo.nPosX, tMemberInfo.nPosY, wI, hI)
						hFlag:SetRelPos(xR, yR)
						hFlag:SetAbsPos(x + xR, y + yR)
						hFlag.bTeammate = true
						hFlag.dwID = dwID
						hFlag.x, hFlag.y = tMemberInfo.nPosX, tMemberInfo.nPosY
						
						nIndex = nIndex + 1					
					end
				end
			end
		end
	else
		hTeammate:Clear()
	end
	
	local nCount = hTeammate:GetItemCount()
	for i = nCount - 1, nIndex, -1 do
		hTeammate:RemoveItem(i)
	end
	
	MiddleMap.UpdatePingPoint(handle)
	MiddleMap.UpdateAreaInfoTip(this)
	if MiddleMap.nFlashCount and MiddleMap.nFlashCount > 0 then
		MiddleMap.UpdateFlashData(handle:Lookup("Handle_DynamicData"))
	end
	
	if WorldMap.bInFight then
		local img = this:Lookup("", "Image_OnAttack")
		img:Show()
		if img.bAdd then
			local nAlpha = img:GetAlpha()
			nAlpha = nAlpha + 30
			img:SetAlpha(nAlpha)
			if nAlpha >= 255 then
				img.bAdd = false
			end
		else
			local nAlpha = img:GetAlpha()
			nAlpha = nAlpha - 30
			img:SetAlpha(nAlpha)
			if nAlpha <= 0 then
				img.bAdd = true
			end
		end
	else
		this:Lookup("", "Image_OnAttack"):Hide()
	end
	
	if MiddleMap.bPrepareRequest and g_tDynamicMapID[MiddleMap.dwMapID] then
		local nTickCount = GetTickCount()
		if nTickCount - MiddleMap.nLastDynamicRequestTime > nDynamicRequestTime then
			RemoteCallToServer("On_Map_GetDynamicNotifyRequest", MiddleMap.dwMapID)
			MiddleMap.bPrepareRequest = nil
			MiddleMap.nLastDynamicRequestTime = nTickCount
		end
	end
	
	if not MiddleMap.bTraffic then
		return
	end
	
	if player.nMoveState == MOVE_STATE.ON_DEATH then
		CloseMiddleMap()
		return
	end
	
	if MiddleMap.dwNpcID then
		local hNpc = GetNpc(MiddleMap.dwNpcID)
		if not hNpc or not hNpc.CanDialog(player) then
			CloseMiddleMap()
		end
	end
end

function MiddleMap.OnEvent(event)
	if event == "LOADING_END" then
		local scene = GetClientScene()
		local dwMapID = scene.dwMapID
		MiddleMap.nLastSymbolTime = nil
		MiddleMap.InitMapCanAcceptQuestInfo(dwMapID)
		if IsMiddleMapOpened() then
			MiddleMap.ShowMap(this)
		end
		MiddleMap.MarkPlayerQuest(this)
		MiddleMap.UpdateQuestList(this)
	elseif event == "LAST_DIE_POS_CHANGED" then
		MiddleMap.UpdateDieMark(this:Lookup("", "Handle_Map"))
	elseif event == "ON_MARK_QUEST_TARGET_PLACE" then
		MiddleMap.UpdateQuestMark(this)
	elseif event == "UI_SCALED" then
		local wC, hC = Station.GetClientSize(false)
		local w, h = this:GetSize()
		local wFact, hFact = Station.OriginalToAdjustPos(w, h)
		
		local fScale = wC / wFact
		if hFact * fScale > hC then
			fScale = hC / hFact
		end
		if wFact * fScale > 1280 then
			fScale = 1280 / wFact
		end
		if fScale ~= 1 then
			this:Scale(fScale, fScale)
		end
		tQuestMarkRegion.nX = fScale * tQuestMarkRegion.nX
		tQuestMarkRegion.nY = fScale * tQuestMarkRegion.nY
		tQuestMarkRegion.nW = fScale * tQuestMarkRegion.nW
		tQuestMarkRegion.nH = fScale * tQuestMarkRegion.nH
		MiddleMap.UpdateMapPos(this:Lookup("", "Handle_Map"))
		
		this:SetPoint("CENTER", 0, 0, "CENTER", 0, 0)
	elseif event == "CUSTOM_DATA_LOADED" then
		MiddleMap.MarkPlayerQuest(this)	
		MiddleMap.UpdateQuestList(this)
	elseif event == "SELECT_QUEST_AREA" then
		MiddleMap.OnSelectArea(this, arg0)
	elseif event == "MARK_NPC" then
		MiddleMap.MarkNpc(this, arg0, arg1, arg2, arg3, arg4)
	elseif event == "QUEST_ACCEPTED" or event == "QUEST_CANCELED" 
	or event == "QUEST_FINISHED" or event == "QUEST_DATA_UPDATE" 
	or event == "QUEST_LIST_UPDATE" or event == "SYNC_ROLE_DATA_END"
	or event == "DAILY_QUEST_UPDATE" or event == "PLAYER_REVIVE" then
		MiddleMap.MarkPlayerQuest(this)
		MiddleMap.UpdateQuestList(this)
	elseif event == "ACTIVITY_SYMBOL_RESPOND" then
		MiddleMap.UpdateActivitySymbol(this, arg0, arg1)
	elseif event == "ON_TRACE_QUEST" then
		MiddleMap.UpdateQuestBtnState(this)
		MiddleMap.UpdateQuestTraceState(this, arg0)
	end
end

function MiddleMap.InitFieldMark(hFrame, dwMapID)
	local hFieldMark = hFrame:Lookup("", "Handle_FieldMark")
	if tNeedFieldMarkMap[dwMapID] and MiddleMap.dwFieldMapID and  MiddleMap.dwFieldMapID == dwMapID then
		hFieldMark:Show()
		if MiddleMap.tFieldMark then
			MiddleMap.UpdateFieldMarkState(hFrame, MiddleMap.tFieldMark)
		end
	else
		hFieldMark:Hide()
	end
end

function MiddleMap.UpdateFieldMarkState(hFrame, tFieldMark)
	local hFieldMark = hFrame:Lookup("", "Handle_FieldMark")
	local nCount = hFieldMark:GetItemCount()
	hFieldMark:Show()
	for i = 0, nCount - 1 do
		local hMark = hFieldMark:Lookup(i)
		hMark:Hide()
	end
	
	local nIndex = 0
	for _,  tMark in pairs(tFieldMark) do
		local hMark = hFieldMark:Lookup(nIndex)
		if not hMark then
			hMark = hFieldMark:AppendItemFromIni(INI_FILE_PATH, "Image_FieldMark")
			hMark.bFieldMark = true
		end
		hMark:SetFrame(tFieldMarkStateFrame[tMark.nState])
		hMark:AutoSize()
		hMark.nState = tMark.nState
		local nWidth, nHeight = hMark:GetSize()
		local nX, nY = MiddleMap.LPosToHPos(tMark.nX, tMark.nY, nWidth, nHeight)
		hMark:SetRelPos(nX, nY)
		hMark:Show()
		nIndex = nIndex + 1
	end
	
	hFieldMark:FormatAllItemPos()
end

function MiddleMap.UpdateActivitySymbol(hFrame, dwMapID, dwSymbol)
	if dwMapID ~= MiddleMap.dwMapID then
		return
	end
	
	local hActivityMark = hFrame:Lookup("", "Handle_ActivitySymbol")
	hActivityMark:Clear()
	
	for i = 1, 32 do
		if GetNumberBit(dwSymbol, i) then
			local tSymbol = Table_GetActivitySymbol(dwMapID, i)
			if tSymbol then
				for _, tPoint in ipairs(tSymbol.tPointList) do
					local hMark = hActivityMark:AppendItemFromIni(INI_FILE_PATH, "Image_ActivitySymbol")
					hMark:FromUITex(tSymbol.szImagePath, tSymbol.nFrame)
					hMark:AutoSize()
					local nWidth, nHeight = hMark:GetSize()
					local nX, nY = MiddleMap.LPosToHPos(tPoint[1], tPoint[2], nWidth, nHeight)
					hMark.bActivitySymbol = true
					hMark.dwMapID = dwMapID
					hMark.nSymbolID = i
					hMark:SetRelPos(nX, nY)
					hMark:Show()
				end
			end
		end
	end
	hActivityMark:FormatAllItemPos()
end

function MiddleMap.MarkActivitySymbol(hFrame)
	local bClear = true
	local hPlayer = GetClientPlayer()
	if hPlayer then
		local hScene = hPlayer.GetScene()
		local dwMapID = hScene.dwMapID
		
		if dwMapID == MiddleMap.dwMapID and not tActivityShieldMap[dwMapID] then
			local nTime = GetTickCount()
			if not MiddleMap.nLastSymbolTime or nTime - MiddleMap.nLastSymbolTime > ACTIVITY_SYMBOL_REQUEST_INTERVAL then
				RemoteCallToServer("On_Map_RequestActivitySymbol", dwMapID)
				MiddleMap.nLastSymbolTime = nTime
			end
			bClear = false
		end
	end
	if bClear then
		MiddleMap.nLastSymbolTime = nil
		local hActivityMark = hFrame:Lookup("", "Handle_ActivitySymbol")
		hActivityMark:Clear()
	end
end

function MiddleMap.UpdateActivitySymbolShow(hFrame)
	local hActivityMark = hFrame:Lookup("", "Handle_ActivitySymbol")
	if MiddleMap.bShowActivitySymbol then
		hActivityMark:Show()
	else 
		hActivityMark:Hide()
	end
end

MiddleMap.nLastDynamicRequestTime = 0
function MiddleMap.ShowMap(frame, dwMapID, nIndex)
	if not dwMapID or not nIndex then
		local player = GetClientPlayer()
		local scene = player.GetScene()
		dwMapID = scene.dwMapID
		MiddleMap.InitMiddleMapInfo(dwMapID)
		local x, y, z = Scene_GameWorldPositionToScenePosition(player.nX, player.nY, player.nZ, 0)
		local nArea = GetRegionInfo(scene.dwID, x, y, z)
		nIndex = MiddleMap.GetMapMiddleMapIndex(scene.dwMapID, nArea)
		if not nIndex then
			nIndex = 0
		end
		
		if MiddleMap.dwMapID ~= 0 and dwMapID ~= MiddleMap.dwMapID then
			MiddleMap.dwMapMarkMapID = nil
			MiddleMap.dwMapMarkX = nil
			MiddleMap.dwMapMarkY = nil
		end
	else
		MiddleMap.InitMiddleMapInfo(dwMapID)
	end
	
	if nIndex and nIndex ~= 0 then
		MiddleMap.bInCity = true
	else
		MiddleMap.bInCity = false
	end
	if dwMapID ~= MiddleMap.dwMapID or MiddleMap.nIndex ~= nIndex then
		MiddleMap.dwMapID, MiddleMap.nIndex = dwMapID, nIndex
		MiddleMap.UpdateCurrentMap(frame)
	end
	
	local hMap = frame:Lookup("", "Handle_Map")
	MiddleMap.UpdateDynamicData(hMap)
	
	MiddleMap.bPrepareRequest = nil
	if g_tDynamicMapID[dwMapID] then
		local nTickCount = GetTickCount()
		if nTickCount - MiddleMap.nLastDynamicRequestTime > nDynamicRequestTime then
			RemoteCallToServer("On_Map_GetDynamicNotifyRequest", dwMapID)
			MiddleMap.nLastDynamicRequestTime = nTickCount
		else
			MiddleMap.bPrepareRequest = true
		end
	end
	
	MiddleMap.UpdateQuestOrMapCheckState(frame)
	MiddleMap.InitFieldMark(frame, dwMapID)
	local hQuestMarkList = frame:Lookup("", "Handle_QuestMap")
    --[[
	if MiddleMap.bTraffic then
		hQuestMarkList:Hide()
	else
		hQuestMarkList:Show()
	end
    --]]
	MiddleMap.MarkActivitySymbol(frame) ---------活动标记需要每次打开中地图界面的时候检查是否发请求
	local thisSave = this
	this = frame
	MiddleMap.OnFrameBreathe()
	this = thisSave
end

function MiddleMap.UpdateQuestOrMapCheckState(hFrame)
	local hCheckQuest = hFrame:Lookup("CheckBox_QuestPage")
	local hCheckMap = hFrame:Lookup("CheckBox_MapPage")
	if MiddleMap.nQuestCount > 0 and not MiddleMap.bInCity then
		hCheckQuest:Enable(true)
		if MiddleMap.bForceCheckQuest then
			MiddleMap.SelectQuestOrMap(hFrame, true)
		end
	else
		hCheckQuest:Enable(false)
		MiddleMap.SelectQuestOrMap(hFrame, false)
	end
end

function MiddleMap.UpdateCurrentMap(frame)
	local handle = frame:Lookup("", "")
	local hMap = handle:Lookup("Handle_Map")
	local img = hMap:Lookup("Image_Map")
	img.bMap = true
	local szName = Table_GetMapName(MiddleMap.dwMapID)
	local szPath = GetMapParams(MiddleMap.dwMapID)
	local aM = MiddleMap.aInfo[MiddleMap.dwMapID]
	if aM and aM[MiddleMap.nIndex] then
		local t = aM[MiddleMap.nIndex]
		if t.name then
			szName = t.name
		end
		frame:Lookup("", "Handle_WorldMap/Text_Map"):SetText(szName)
		handle:Lookup("Text_Title"):SetText(szName)
		img:FromTextureFile(szPath.."minimap\\"..t.image)
		MiddleMap.w = t.width
		MiddleMap.h = t.height
		MiddleMap.scale = t.scale
		MiddleMap.startx = t.startx
		MiddleMap.starty = t.starty
		MiddleMap.bIncopy = t.copy
		MiddleMap.bInRresherRoom = t.fresherroom
		MiddleMap.bInBattlefield = t.battlefield		
	else
		CloseMiddleMap(true)
	end
	---------------自己--------------------------
	local player = GetClientPlayer()
	local scene = player.GetScene()
	if scene.dwMapID == MiddleMap.dwMapID then
		local img = hMap:Lookup("Image_Player")
		img:Show()
		img.x, img.y = player.nX, player.nY 
		img.bSelf = true
		local ani = hMap:Lookup("Animate_Player")
		ani:Show()
		ani.x, ani.y = player.nX, player.nY
		ani.bSelf = true
		ani.bAni = true
				
	end	
	
	local hTeammate = hMap:Lookup("Handle_Teammate")
	hTeammate:Clear()

	-------------标记点--------------------------
	MiddleMap.UpdateMapFlag(hMap)
	MiddleMap.UpdateQuestList(frame)
	MiddleMap.MarkFieldPQ(frame)
	MiddleMap.UpdateQuestMark(frame)
	MiddleMap.MarkPlayerQuest(frame)
	MiddleMap.UpdateMapPos(hMap)
	MiddleMap.UpdateDieMark(hMap)
	MiddleMap.UpdateMapMark(hMap)
	MiddleMap.UpdatePingPoint(hMap)
	MiddleMap.UpdateAreaOrNpcMark(hMap)
	MiddleMap.UpdateAreaOrNpcList(frame)
    MiddleMap.UpdateSelectNpcMark(frame)
	MiddleMap.UpdateAlpha(frame)
end

function MiddleMap.SelectQuestOrMap(hFrame, bQuest)
	local hWndTool = hFrame:Lookup("Wnd_Tool")
	local hWndQuest = hFrame:Lookup("Wnd_Quest")
	local hCheckQuest = hFrame:Lookup("CheckBox_QuestPage")
	local hCheckMap = hFrame:Lookup("CheckBox_MapPage")
	local hTargetMark = hFrame:Lookup("", "Handle_QuestTargetMark")
	local hQuestAcceptedMark = hFrame:Lookup("", "Handle_QuestAcceptedMark")
	if bQuest then
		hWndQuest:Show()
		hWndTool:Hide()
		--hTargetMark:Show()
		--hQuestAcceptedMark:Show()
		hCheckMap:Check(false)
		hCheckQuest:Check(true)
	else
		hWndQuest:Hide()
		--hTargetMark:Hide()
		--hQuestAcceptedMark:Hide()
		hWndTool:Show()
		hCheckQuest:Check(false)
		hCheckMap:Check(true)
	end
end

function MiddleMap.UpdateMapFlag(hMap)
	local hMapMark = hMap:Lookup("Handle_MapMark")
	local nIndex = 0
	local aF = MiddleMap.aFlag[MiddleMap.dwMapID]
	if aF then
		for k, v in pairs(aF) do
			local img = hMapMark:Lookup(nIndex)
			if img then
				img:SetFrame(tShowFlagFrame[v.nType])
			else
				img = hMapMark:AppendItemFromIni(INI_FILE_PATH, "Image_Flag", "")
			end
			img:LockShowAndHide(true)
			img:RegisterEvent(511)
			if MiddleMap.aShowFlag[v.nType] then
			 	img:Show()
			 else
			 	img:Hide()
			 end
			img.x = v.x
			img.y = v.y
			img.szName = v.name
			img.bFlag = true
			img.nType = v.nType
			img.k = k
			nIndex = nIndex + 1
		end
	end
	local nCount = hMapMark:GetItemCount() - 1
	for i = nIndex, nCount, 1 do
		hMapMark:Lookup(i):Hide()
	end
	MiddleMap.UpdateMapPos(hMap)
end

function MiddleMap.MatchFilter(szInput, szFiler)
	if szFiler == "" then
		return 1
	end
	return string.find(szInput, szFiler)
end

function MiddleMap.SelectAreaOrNpcTrunk(hTrunk, bExpend)
    local hList = hTrunk:GetParent()
    if bExpend then
        local nCount = hList:GetItemCount()
        for i = 0, nCount - 1 do
            local hChild = hList:Lookup(i)
            if hChild ~= hTrunk then
                MiddleMap.UpdateAreaOrNpcTruckSize(hChild, false)
            end
        end
    end
    MiddleMap.UpdateAreaOrNpcTruckSize(hTrunk, bExpend)
    
    hList:FormatAllItemPos()
    FireUIEvent("SCROLL_UPDATE_LIST", "Handle_NpcOrAreaList", "MiddleMap", false)
end

function MiddleMap.UpdateAreaOrNpcTruckSize(hTrunk, bExpend)
    local hHandleList = hTrunk:Lookup("Handle_List")
    local hTrunkBgOver = hTrunk:Lookup("Image_ListBg")
    local hTrunkTitleOver = hTrunk:Lookup("Image_ListCover")
    local hImageMinize = hTrunk:Lookup("Image_Minimize")
    local nWidth, nHeight = hTrunk:GetSize()
    local nPosX, nPosY = hHandleList:GetRelPos()
    hTrunk.bExpend = bExpend
    if bExpend then
         hHandleList:FormatAllItemPos()
        hHandleList:SetSizeByAllItemSize()
        local _, nListSize = hHandleList:GetSize()
        nHeight = math.ceil(nPosY + nListSize + 5)
        hHandleList:Show()
        hTrunkTitleOver:Show()
        hImageMinize:SetFrame(tExpendFrame.Expand)
    else
        hHandleList:SetSize(0, 0)
        hHandleList:Hide()
        _, nHeight = hTrunkTitleOver:GetSize()
        hTrunkTitleOver:Hide()
        hImageMinize:SetFrame(tExpendFrame.Normal)
    end
    hTrunk:FormatAllItemPos()
    hTrunk:SetSize(nWidth, nHeight)
end

function MiddleMap.SelectArea(hArea)
    local hList = hArea:GetParent()
	local nCount = hList:GetItemCount() - 1
	for i = 0, nCount, 1 do
		local hChild = hList:Lookup(i)
        if hChild ~= hArea then
              hChild.bSelect = false
            MiddleMap.UpdateAreaTitle(hChild)
        end
	end
	
	if hArea.bSelect then
        hArea.bSelect = false
        MiddleMap.UnSelectArea(hArea:GetRoot())
    else
        hArea.bSelect = true
        MiddleMap.UpdateAreaTitle(hArea)
        MiddleMap.dwAreaOrNpcMapID = MiddleMap.dwMapID
        MiddleMap.nAreaOrNpcX = hArea.x
        MiddleMap.nAreaOrNpcY = hArea.y
        MiddleMap.szAreaOrNpcName = hArea.name
        MiddleMap.szAreaOrNpcKind = hArea.kind
        MiddleMap.nAreaOrNpcType = hArea.type
        MiddleMap.nAreaID = hArea.nAreaID
        MiddleMap.bArea = hArea.bArea
        
        MiddleMap.UpdateAreaOrNpcMark(hArea:GetRoot():Lookup("", "Handle_Map"))
    end
end

function MiddleMap.UpdateAreaTitle(hSelect)
    local hImage = hSelect:Lookup("Image_AreaOption")
    if hSelect.bSelect then
        if hSelect.bMouseOver then
            hImage:SetFrame(tSelectAreaFrame.SelectOver)
        else
            hImage:SetFrame(tSelectAreaFrame.SelectNormal)
        end
    else
        if hSelect.bMouseOver then
            hImage:SetFrame(tSelectAreaFrame.UnSelectOver)
        else
            hImage:SetFrame(tSelectAreaFrame.UnSelectNormal)
        end
    end

end

function MiddleMap.SelectNpc(hNpc)
    if hNpc.bCheck then
        hNpc.bCheck = false
    else
        hNpc.bCheck = true
    end
    
    if not MiddleMap.tSelectNpc[MiddleMap.dwMapID] then
        MiddleMap.tSelectNpc[MiddleMap.dwMapID] = {}
    end
    
    if not MiddleMap.tSelectNpc[MiddleMap.dwMapID][MiddleMap.nIndex] then
        MiddleMap.tSelectNpc[MiddleMap.dwMapID][MiddleMap.nIndex] = {}
    end
    local tCurrentSelectNpc = MiddleMap.tSelectNpc[MiddleMap.dwMapID][MiddleMap.nIndex]
    if hNpc.bCheck then
        tCurrentSelectNpc[hNpc.dwID] = {dwID, hNpc.tGroup}
    else
        tCurrentSelectNpc[hNpc.dwID] = nil
    end
    MiddleMap.UpdateNpcTitle(hNpc)
    MiddleMap.UpdateSelectNpcMark(hNpc:GetRoot())
end

function MiddleMap.UpdateSelectNpcMark(hFrame)
    local hSelectNpcMark = hFrame:Lookup("", "Handle_SelectNpcMark")
    hSelectNpcMark:Clear()
    local tCurrentSelectNpc = {}
    if MiddleMap.tSelectNpc[MiddleMap.dwMapID] and MiddleMap.tSelectNpc[MiddleMap.dwMapID][MiddleMap.nIndex] then
        tCurrentSelectNpc = MiddleMap.tSelectNpc[MiddleMap.dwMapID][MiddleMap.nIndex]
    end
    
    for dwID, tSelect in pairs(tCurrentSelectNpc) do
        local tGroup = tSelect[2]
        for _, tNpc in ipairs(tGroup) do
            local tPoint = tNpc.tPoint
            local nNpcType = tNpc.nNpcType
            for _, tP in ipairs(tPoint) do
                local hPoint = hSelectNpcMark:AppendItemFromIni(INI_FILE_PATH, "Image_Npc")
                if nNpcType > 0 then
                    local tNpcType = g_tTable.NpcType:Search(nNpcType)
                    if tNpcType and tNpcType.nMinimapImageFrame and tNpcType.nMinimapImageFrame >= 0 then
                        hPoint:FromUITex("ui/Image/Minimap/Minimap.UITex", tNpcType.nMinimapImageFrame)
                    end
                end
                hPoint:AutoSize()
                hPoint:RegisterEvent(0x100)
                local x, y = hSelectNpcMark:GetAbsPos()
                local wI, hI = hPoint:GetSize()
                local xR, yR = MiddleMap.LPosToHPos(tP[1], tP[2], wI, hI)
                hPoint.x = tP[1]
                hPoint.y = tP[2]
                hPoint:SetRelPos(xR, yR)
                hPoint:SetAbsPos(x + xR, y + yR)
                hPoint.szName = Table_GetNpcTemplateName(tNpc.nNpcID)
                hPoint.szKind = tNpc.szKind
            end
        end
	end
    hSelectNpcMark:FormatAllItemPos()
end

function MiddleMap.UpdateNpcTitle(hNpc)
    local hImageCheck = hNpc:Lookup("Image_NpcOption")
    if hNpc.bCheck then
        if hNpc.bMouseOver then
            hImageCheck:SetFrame(tSelectNpcFrame.CheckOver)
        else
            hImageCheck:SetFrame(tSelectNpcFrame.CheckNormal)
        end
    else
        if hNpc.bMouseOver then
            hImageCheck:SetFrame(tSelectNpcFrame.UnCheckOver)
        else
            hImageCheck:SetFrame(tSelectNpcFrame.UnCheckNormal)
        end
    end

end

function MiddleMap.UpdateAreaOrNpcList(hFrame, bSearch)
    local hWndTool = hFrame:Lookup("Wnd_Tool")
    local szFilter = hWndTool:Lookup("Edit_Search"):GetText()
    local hList = hWndTool:Lookup("", "Handle_NpcOrAreaList")
    
    if not bSearch then
        hList:Clear()
        local hNpcTrunk = hList:AppendItemFromIni(INI_FILE_PATH, "Handle_Mode", "Handle_NpcTrunk")
        hNpcTrunk:Lookup("Text_ListTitle"):SetText(g_tStrings.MIDDLEMAP_COMMON_NPC)
        
        local hAreaTrunk = hList:AppendItemFromIni(INI_FILE_PATH, "Handle_Mode", "Handle_AreaTrunk")
        hAreaTrunk:Lookup("Text_ListTitle"):SetText(g_tStrings.MIDDLEMAP_AREA)
    end
    
    local hNpcTrunk = hList:Lookup("Handle_NpcTrunk")
    local hNpcList = hNpcTrunk:Lookup("Handle_List")
    hNpcList:Clear()
    FireHelpEvent("OnOpenpanel", "MIDDLEMAP", hNpcTrunk:Lookup("Text_ListTitle"))
    local nIndex = 0
    local aNpc = MiddleMap.aNpc[MiddleMap.dwMapID] or {}
    local tCurrentSelectNpc = {}
    if MiddleMap.tSelectNpc[MiddleMap.dwMapID] and MiddleMap.tSelectNpc[MiddleMap.dwMapID][MiddleMap.nIndex] then
        tCurrentSelectNpc = MiddleMap.tSelectNpc[MiddleMap.dwMapID][MiddleMap.nIndex]
    end
    
    for k, v in pairs(aNpc) do
        local szName = v.kind
        if v.middlemap == MiddleMap.nIndex and szName and MiddleMap.MatchFilter(szName, szFilter) then
            local hNpc = hNpcList:AppendItemFromIni(INI_FILE_PATH, "Handle_Npc")
            nIndex = nIndex + 1
            hNpc.bNpc = true
            hNpc.dwID = v.id
            hNpc.k = k
            hNpc.tGroup = v.group
            hNpc.kind = v.kind
            hNpc.type = v.type
            hNpc:Lookup("Text_NpcName"):SetText(szName)
            hNpc.bCheck = false
            hNpc:FormatAllItemPos()
            if tCurrentSelectNpc[v.id] then
                hNpc.bCheck = true
                MiddleMap.UpdateNpcTitle(hNpc)
            end
        end
    end
    hNpcList:FormatAllItemPos()
    local bSelectNpc = true
    if bSearch then
        bSelectNpc = hNpcTrunk.bExpend
    end
    MiddleMap.UpdateAreaOrNpcTruckSize(hNpcTrunk, bSelectNpc)
    
    local hAreaTrunk = hList:Lookup("Handle_AreaTrunk")
    local hAreaList = hAreaTrunk:Lookup("Handle_List")
    hAreaList:Clear()
    local aArea = MiddleMap.aArea[MiddleMap.dwMapID] or {}
    for k, v in pairs(aArea) do
        if v.middlemap == MiddleMap.nIndex and MiddleMap.MatchFilter(v.name, szFilter) and v.bShow then
            local hArea = hAreaList:AppendItemFromIni(INI_FILE_PATH, "Handle_Area")
            nIndex = nIndex + 1
            hArea.bArea = true
            hArea.nAreaID = k
            hArea.x = v.x
            hArea.y = v.y
            hArea.name = v.name
            hArea.type = v.type
            hArea:Lookup("Text_AreaName"):SetText(v.name)
            hArea.bSelect = false
            hArea:FormatAllItemPos()
        end
    end
    hAreaList:FormatAllItemPos()
    MiddleMap.UpdateAreaOrNpcTruckSize(hAreaTrunk, not bSelectNpc)
    hList:FormatAllItemPos()
    FireUIEvent("SCROLL_UPDATE_LIST", "Handle_NpcOrAreaList", "MiddleMap", true)
end

function MiddleMap.UpdateMapMark(handle)
	local img = handle:Lookup("Image_MapMark")
	if MiddleMap.dwMapMarkMapID and MiddleMap.dwMapID == MiddleMap.dwMapMarkMapID then	
		local t = {1, 1, 1, 1}
		img:SetFrame(t[MiddleMap.dwMapMarkType])
		img:Show()
		img.x, img.y = MiddleMap.dwMapMarkX, MiddleMap.dwMapMarkY
		img.szName = MiddleMap.szMapMarkName
		
		local x, y = handle:GetAbsPos()
		local wI, hI = img:GetSize()
		local xR, yR = MiddleMap.LPosToHPos(img.x, img.y, wI, hI)
		img:SetRelPos(xR, yR)
		img:SetAbsPos(x + xR, y + yR)
		img.bMapMark = true
	else
		img:Hide()
	end
end

function MiddleMap.UpdateDieMark(handle)
	local img = handle:Lookup("Image_Die")
	local dwDieMapID, nX, nY = GetLastDiePos()
	if dwDieMapID and MiddleMap.dwMapID == dwDieMapID then	
		img:Show()
		img.x, img.y = nX, nY
		
		local x, y = handle:GetAbsPos()
		local wI, hI = img:GetSize()
		local xR, yR = MiddleMap.LPosToHPos(img.x, img.y, wI, hI)
		img:SetRelPos(xR, yR)
		img:SetAbsPos(x + xR, y + yR)
		img.bDie = true
	else
		img:Hide()
	end
end


local NPC_POINT_TYPE_IMAGE_FRAME = 
{
	[2] = 200,
	[4] = 201,
	[5] = 201,
	[6] = 200,
}

local QUEST_MARK_ANIMATE_FRAME_TRANSFER = 
{
	[50]  = 2, --任务完成
	[199] = 14,	--小怪
	[200] = 15, --精英
	[201] = 13, --头目
	[202] = 16,  --旗帜
	[208] = 0,   -- 接任务
}

function MiddleMap.UpdateQuestMark(hFrame)
	local hQuestMarkList = hFrame:Lookup("", "Handle_QuestMap")
	hQuestMarkList:Clear()
	
	local dwQuestID, szType, nIndex = GetMarkQuestTargetPlace()
	
	MiddleMap.UpdateQuestTarget(hQuestMarkList, true, dwQuestID, szType, nIndex)
	
	hQuestMarkList:FormatAllItemPos()
end

function MiddleMap.UpdateQuestTarget(hHandle, bAnimate, dwQuestID, szType, nIndex, bFirstHide)
	local tPointList = nil
	if dwQuestID and szType then
		tPointList = Table_GetQuestPoint(dwQuestID, szType, nIndex)
	end
	if not tPointList or not tPointList[MiddleMap.dwMapID] then
		return
	end
	local bFirst = true
	for _, tPoint in ipairs(tPointList[MiddleMap.dwMapID]) do
		local nFrame = -1
		if szType == "finish" then
			nFrame = 50
		elseif szType == "accept" then
			nFrame = 208
            
		else
			nFrame = 199
			if tPoint[5] then
				nFrame = tPoint[5]
			elseif tPoint[3] == "N" and tPoint[4] then
				local hNpcTemplate = GetNpcTemplate(tPoint[4])
				local nIntensity = hNpcTemplate.nIntensity
				if NPC_POINT_TYPE_IMAGE_FRAME[nIntensity] then
					nFrame = NPC_POINT_TYPE_IMAGE_FRAME[nIntensity]
				end
			elseif tPoint[3] == "P" then
				nFrame = 202
			end
		end
		local hPoint = nil
		if bAnimate then
			hPoint = hHandle:AppendItemFromIni(INI_FILE_PATH, "Animate_QuestPoint")
			nFrame = QUEST_MARK_ANIMATE_FRAME_TRANSFER[nFrame]
			hPoint:SetGroup(nFrame)
			hPoint:AutoSize()
			if szType == "finish" then
				FireHelpEvent("OnCommentToMarkQuestFinish", dwQuestID, hPoint)
			end
		else
			hPoint = hHandle:AppendItemFromIni(INI_FILE_PATH, "Image_Quest")
            local szPath = "ui/Image/Minimap/Minimap.UITex"
            if szType == "accept" then
                nFrame = MiddleMap.GetAcceptQuestShowFrame(dwQuestID)
                szPath = "ui/Image/Common/DialogueLabel.UITex"
            end
			if nFrame >= 0 then
				hPoint:FromUITex(szPath, nFrame)
				hPoint:AutoSize()
			end
		end
		
		local nWidth, nHeight = hPoint:GetSize()
		local nX, nY = MiddleMap.LPosToHPos(tPoint[1], tPoint[2], nWidth, nHeight)
		hPoint:Hide()
		if nX > tQuestMarkRegion.nX 
		and nX + nWidth < tQuestMarkRegion.nX + tQuestMarkRegion.nW 
		and nY > tQuestMarkRegion.nY 
		and nY + nHeight < tQuestMarkRegion.nY + tQuestMarkRegion.nH 
		then
			hPoint:SetRelPos(nX, nY)
			hPoint.dwQuestID = dwQuestID
			hPoint.szType = szType
			hPoint.nIndex = nIndex
			if tPoint[3] == "N" and tPoint[4] then
				hPoint.dwNpcTemplateID = tPoint[4]
			elseif tPoint[3] == "D" and tPoint[4] then
				hPoint.dwDoodadTemplateID = tPoint[4]
			end
			hPoint:Show()
		end
		if bFirst and bFirstHide then
			hPoint:Hide()
		end
		bFirst = false
	end
	hHandle:FormatAllItemPos()
end

function MiddleMap.MarkPlayerQuest(hFrame)
	local hQuestMarkList = hFrame:Lookup("", "Handle_QuestCanAcceptMark")
	hQuestMarkList:Clear()
	
	MiddleMap.MarkAllCanAcceptQuest(hQuestMarkList)
	
	hQuestMarkList:FormatAllItemPos()
end

function MiddleMap.MarkFieldPQ(hFrame)
	local hFieldPQMark = hFrame:Lookup("", "Handle_FieldPQMark")
	hFieldPQMark:Clear()
	
	local dwMapID = MiddleMap.dwMapID
	if not MiddleMap.tFieldPQ[dwMapID] then
		return
	end
	
	for _, dwPQTemplateID in ipairs(MiddleMap.tFieldPQ[dwMapID]) do
		local hFieldPQ = hFieldPQMark:AppendItemFromIni(INI_FILE_PATH, "Image_FieldPQ")
		local nWidth, nHeight = hFieldPQ:GetSize()
		local tPQ = Table_GetFieldPQ(dwPQTemplateID)
		local nX, nY = MiddleMap.LPosToHPos(tPQ.fX, tPQ.fY, nWidth, nHeight)
		hFieldPQ.bFieldPQ = true
		hFieldPQ.dwPQTemplateID = dwPQTemplateID
		hFieldPQ:SetRelPos(nX, nY)
		hFieldPQ:Show()
	end
	
	hFieldPQMark:FormatAllItemPos()
end

function MiddleMap.MarkAllAcceptedQuest(hhandle)
	local hPlayer = GetClientPlayer()
	if not hPlayer then
		return
	end
	
	local tQuest = hPlayer.GetQuestTree()
	for _, tClass in pairs(tQuest) do
		for _, nQuesIndex in pairs(tClass) do
			local dwQuestID = hPlayer.GetQuestID(nQuesIndex)
			local tQuestTrace = hPlayer.GetQuestTraceInfo(dwQuestID)
			
			if tQuestTrace.finish then
				if Table_GetQuestPosInfo(dwQuestID, "finish", 0) then
					MiddleMap.UpdateQuestTarget(hhandle, false, dwQuestID, "finish", 0)
				end
			else
				for _, v in pairs(tQuestTrace.quest_state) do
					if v.have < v.need and Table_GetQuestPosInfo(dwQuestID, "quest_state", v.i) then
						MiddleMap.UpdateQuestTarget(hhandle, false, dwQuestID, "quest_state", v.i)
					end
				end
				
				for _, v in pairs(tQuestTrace.kill_npc) do
					if v.have < v.need and Table_GetQuestPosInfo(dwQuestID, "kill_npc", v.i) then
						MiddleMap.UpdateQuestTarget(hhandle, false, dwQuestID, "kill_npc", v.i)
					end
				end
				
				for _, v in pairs(tQuestTrace.need_item) do
					if v.have < v.need and Table_GetQuestPosInfo(dwQuestID, "need_item", v.i) then
						MiddleMap.UpdateQuestTarget(hhandle, false, dwQuestID, "need_item", v.i)
					end
				end
			end
		end
	end
end

function MiddleMap.MarkAllCanAcceptQuest(hhandle)
	local dwMapID = MiddleMap.dwMapID
	if not MiddleMap.tCanAcceptQuest[dwMapID] then
		return
	end
	local hPlayer = GetClientPlayer()
	if not hPlayer then
		return
	end
	
	for dwQuestID, tObject in pairs(MiddleMap.tCanAcceptQuest[dwMapID]) do
		local bCanAccept = false
		for _, tInfo in pairs(tObject) do
			local szType = tInfo[1]
			local dwObject = tInfo[2]
			
			assert(szType == "D" or szType == "N")
			if dwObject > 0 then
				local eCanAccept = hPlayer.CanAcceptQuest(dwQuestID, dwObject)
				if eCanAccept == QUEST_RESULT.SUCCESS then
					bCanAccept = true
					break
				end
			end
		end 
		
		if bCanAccept then
			local bShow = MiddleMap.IsShowQuest(dwQuestID, hPlayer)
			if bShow then
				MiddleMap.UpdateQuestTarget(hhandle, false, dwQuestID, "accept")
			end
		end
	end
	
end

function MiddleMap.IsShowQuest(dwQuestID, hPlayer)
    local hQuestInfo = GetQuestInfo(dwQuestID)
    if hQuestInfo.bRepeat then
        if MiddleMap.tQuestShow["Repeat"] then
            return true
        else
            return false
        end
       
    end
	local nDifficult = hPlayer.GetQuestDiffcultyLevel(dwQuestID)
	
    if nDifficult == QUEST_DIFFICULTY_LEVEL.LOWER_LEVEL then
        if MiddleMap.tQuestShow["Lower"] then
            return true
        else
            return false
        end
    elseif nDifficult == QUEST_DIFFICULTY_LEVEL.LOW_LEVEL then
        if MiddleMap.tQuestShow["Low"] then
            return true
        else
            return false
        end
    else
        if MiddleMap.tQuestShow["Normal"] then
            return true
        else
            return false
        end
    end
    
	return true
end

function MiddleMap.GetAcceptQuestShowFrame(dwQuestID)
    local nFrame = 13
    local hPlayer = GetClientPlayer()
    if not hPlayer then
        return nFrame
    end

    local hQuestInfo = GetQuestInfo(dwQuestID)
    if hQuestInfo.bRepeat then
        nFrame = 5
    else
        local nDifficult = hPlayer.GetQuestDiffcultyLevel(dwQuestID)
        if nDifficult == QUEST_DIFFICULTY_LEVEL.LOW_LEVEL  then
            nFrame = 68
        elseif nDifficult == QUEST_DIFFICULTY_LEVEL.LOWER_LEVEL then
            nFrame = 8
        end
    end
    
    return nFrame
end

function MiddleMap.InitMapCanAcceptQuestInfo(dwMapID)
	if MiddleMap.tCanAcceptQuest[dwMapID] then
		return
	end
	
	MiddleMap.tCanAcceptQuest[dwMapID] = Table_GetAllSceneQuest(dwMapID)
end

function MiddleMap.InitMapFieldPQInfo(dwMapID)
	if MiddleMap.tFieldPQ[dwMapID] then
		return
	end
	
	MiddleMap.tFieldPQ[dwMapID] = Table_GetSceneFieldPQ(dwMapID)
end

function MiddleMap.UpdateAreaOrNpcMark(handle)
	local img = handle:Lookup("Image_AreaOrNpc")
	if MiddleMap.dwAreaOrNpcMapID and MiddleMap.dwMapID == MiddleMap.dwAreaOrNpcMapID then	
		img:Show()
		img.x, img.y = MiddleMap.nAreaOrNpcX, MiddleMap.nAreaOrNpcY
		if MiddleMap.nAreaID then
			local szPath = GetMapParams(MiddleMap.dwAreaOrNpcMapID)
			img:FromTextureFile(szPath.."minimap\\"..MiddleMap.nAreaID.."_"..MiddleMap.nIndex..".tga")
			img:AutoSize()
			local w, h = img:GetSize()
			img:SetSize(w * MiddleMap.scaleImg, h * MiddleMap.scaleImg)
			img:ClearEvent()
		else
			img:FromUITex("ui/Image/Minimap/Minimap.UITex", nFrame)
			img:AutoSize()
			img:RegisterEvent(0x100)
		end
				
		local x, y = handle:GetAbsPos()
		local wI, hI = img:GetSize()
		local xR, yR = MiddleMap.LPosToHPos(img.x, img.y, wI, hI)
		img:SetRelPos(xR, yR)
		img:SetAbsPos(x + xR, y + yR)
		img.bAreaOrNpc = true
	else
		img:Hide()
	end
end

function MiddleMap.UpdatePingPoint(handle)
	local pingX, pingY = GetPartySignPostPos()
	local ani = handle:Lookup("Animate_Ping")
	if pingX and pingY then
		ani:Show()
		ani.x, ani.y = pingX, pingY
				
		local x, y = handle:GetAbsPos()
		local wI, hI = ani:GetSize()
		local xR, yR = MiddleMap.LPosToHPos(ani.x, ani.y, wI, hI)
		ani:SetRelPos(xR, yR)
		ani:SetAbsPos(x + xR, y + yR)
		ani.bPing = true	
	else
		ani:Hide()
	end
end

function MiddleMap.UpdateMapPos(handle)
	local w, h = handle:GetSize()
	
	local nHeight = h
	local nWidth = MiddleMap.w * h / MiddleMap.h
	if nWidth > w then
		nWidth = w
		nHeight = MiddleMap.h * w / MiddleMap.w
	end
	
	local img = handle:Lookup("Image_Map")
	img:SetSize(nWidth, nHeight)
	local x, y = (w - nWidth) / 2, (h - nHeight) / 2
	img:SetRelPos(x, y)
	
	MiddleMap.mapx, MiddleMap.mapy = x, y + nHeight
	MiddleMap.scaleFinal = MiddleMap.scale * nWidth / MiddleMap.w
	MiddleMap.scaleImg = nWidth / MiddleMap.w
	
	local nCount = handle:GetItemCount() - 1
	for i = 0, nCount, 1 do
		local item = handle:Lookup(i)
		if item.bHandle then
			local nHC = item:GetItemCount() - 1
			for j = 0, nHC, 1 do
				local iH = item:Lookup(j)
				if iH:IsVisible() then
					local wI, hI = iH:GetSize()
					iH:SetRelPos(MiddleMap.LPosToHPos(iH.x, iH.y, wI, hI))
				end
			end
			item:FormatAllItemPos()
		elseif item.bMap then
		elseif item:IsVisible() then
			local wI, hI = item:GetSize()
			if item.x then
				item:SetRelPos(MiddleMap.LPosToHPos(item.x, item.y, wI, hI))
			end
		end
	end
	handle:FormatAllItemPos()
end

function MiddleMap.LPosToHPos(x, y, w, h)
	local xR = MiddleMap.mapx + (x - MiddleMap.startx) * MiddleMap.scaleFinal
	local yR = MiddleMap.mapy - (y - MiddleMap.starty) * MiddleMap.scaleFinal
	if w and h then
		return xR - w / 2, yR - h / 2
	end
	return xR, yR
end

function MiddleMap.HPosToLPos(x, y, w, h)
	if w and h then
		x, y = x + w / 2, y + h / 2
	end
	
	local xR = MiddleMap.startx + (x - MiddleMap.mapx) / MiddleMap.scaleFinal
	local yR = MiddleMap.starty + (MiddleMap.mapy - y) / MiddleMap.scaleFinal
	return xR, yR
end

function MiddleMap.OnLButtonClick()
	local hFrame = this:GetRoot()
	local szName = this:GetName()
    if szName == "Btn_Close" then
    	CloseMiddleMap()
    elseif szName == "Btn_WorldMap" then
    	CloseMiddleMap(true)
    	OpenWorldMap()
    elseif szName == "Btn_Sel" then
    elseif szName == "Btn_QCancel" then
		local hPlayer = GetClientPlayer()
		if MiddleMap.dwQuestID and hPlayer then
			local dwQuestID = MiddleMap.dwQuestID
			local tQuestStringInfo = Table_GetQuestStringInfo(dwQuestID)
			if tQuestStringInfo then
				local fCancelQuest = function()
					local hPlayer = GetClientPlayer()
					hPlayer.CancelQuest(hPlayer.GetQuestIndex(dwQuestID))        	
				end
				local tMsg = 
				{
					bModal = true,
					szMessage = FormatString(g_tStrings.STR_QUEST_SURE_REMOVE_QUEST, tQuestStringInfo.szName),
					szName = "MCancelQuestResult", 
					{szOption = g_tStrings.STR_QUEST_SURE, fnAction = fCancelQuest},
					{szOption = g_tStrings.STR_QUEST_CANCEL},
				}
				MessageBox(tMsg)
			end
		end
	elseif szName == "Btn_QTrace" then
		if MiddleMap.dwQuestID then
			local dwQuestID = MiddleMap.dwQuestID
			if not IsTraceQuest(dwQuestID) then
				AddTraceQuest(dwQuestID)
			end
			MiddleMap.UpdateQuestBtnState(hFrame)
			MiddleMap.UpdateQuestTraceState(hFrame, dwQuestID)
		end
	elseif szName == "Btn_QCancelTrace" then
		if MiddleMap.dwQuestID then
			local dwQuestID = MiddleMap.dwQuestID
			if IsTraceQuest(dwQuestID) then
				RemoveTraceQuest(dwQuestID)
			end
			MiddleMap.UpdateQuestBtnState(hFrame)
			MiddleMap.UpdateQuestTraceState(hFrame, dwQuestID)
		end
	elseif szName == "Btn_QShare" then
		local hPlayer = GetClientPlayer()
		if MiddleMap.dwQuestID and hPlayer then
			hPlayer.ShareQuest(hPlayer.GetQuestIndex(MiddleMap.dwQuestID))
			PlaySound(SOUND.UI_SOUND, g_sound.Button)
			FireDataAnalysisEvent("SHARE_QUEST")
		end
    end
end

function MiddleMap.UpdateAlpha(frame)
	local handle = frame:Lookup("", "")
	handle:Lookup("Handle_Map"):SetAlpha(MiddleMap.nAlpha)
	handle:Lookup("Image_L1"):SetAlpha(MiddleMap.nAlpha)
	handle:Lookup("Image_L2"):SetAlpha(MiddleMap.nAlpha)
	handle:Lookup("Image_L3"):SetAlpha(MiddleMap.nAlpha)
	handle:Lookup("Image_L4"):SetAlpha(MiddleMap.nAlpha)
	handle:Lookup("Image_R1"):SetAlpha(MiddleMap.nAlpha)
	handle:Lookup("Image_R2"):SetAlpha(MiddleMap.nAlpha)
	handle:Lookup("Image_R3"):SetAlpha(MiddleMap.nAlpha)
	handle:Lookup("Image_R4"):SetAlpha(MiddleMap.nAlpha)
	handle:Lookup("Image_North"):SetAlpha(MiddleMap.nAlpha)
	handle:Lookup("Image_West"):SetAlpha(MiddleMap.nAlpha)
	handle:Lookup("Image_East"):SetAlpha(MiddleMap.nAlpha)
	handle:Lookup("Image_South"):SetAlpha(MiddleMap.nAlpha)
end

function MiddleMap.OnScrollBarPosChanged()
	local nCurrentValue = this:GetScrollPos()
	local szName = this:GetName()
    if szName == "Scroll_Alpha" then
        local nAlpha = MIDDLE_MAP_MIN_ALPHA + (255 - MIDDLE_MAP_MIN_ALPHA) * nCurrentValue / this:GetStepCount()
        if nAlpha ~= MiddleMap.nAlpha then
            MiddleMap.nAlpha = nAlpha
            MiddleMap.UpdateAlpha(this:GetRoot())
            this:GetParent():Lookup("", "Text_AlphaPer"):SetText(math.floor(100 * MiddleMap.nAlpha / 255).."%")
        end
    end
end

function MiddleMap.OnLButtonDown()
	local szName = this:GetName()
	
	if szName == "Btn_Sel" then
		if this.bIgnor then
			this.bIgnor = nil
			return
		end
		if not this:IsEnabled() then
			return
		end		
		
		local text = this:GetParent():Lookup("", "Handle_WorldMap/Text_Map")
		local xA, yA = text:GetAbsPos()
		local w, h = text:GetSize()
		local menu = 
		{
			nMiniWidth = w,
			x = xA, y = yA + h,
			fnCancelAction = function() 
				local btn = Station.Lookup("Topmost1/MiddleMap/Btn_Sel") 
				if btn then
					local x, y = Cursor.GetPos()
					local xA, yA = btn:GetAbsPos()
					local w, h = btn:GetSize()
					if x >= xA and x < xA + w and y >= yA and y <= yA + h then
						btn.bIgnor = true
					end
				end
			end,
			fnAutoClose = function() if IsMiddleMapOpened() then return false else return true end end,
		}
        local fnSelectMapAction = function(UserData, bCheck)
				MiddleMap.ShowMap(Station.Lookup("Topmost1/MiddleMap"), UserData[1], UserData[2])
		end
		local bHave = false
		local player = GetClientPlayer()
		local aI = GetMapList()
        local tMapGroup = {}
        for _, dwMapID in ipairs(aI) do
            if player.GetMapVisitFlag(dwMapID) then
                local nGroup = Table_GetMapGroupID(dwMapID)
                if not tMapGroup[nGroup] then
                    tMapGroup[nGroup] = {}
                end
                local tGroup = tMapGroup[nGroup]
                table.insert(tGroup, dwMapID)
            end
        end
		for nGroup, tGroup in pairs(tMapGroup) do
            local tGroupInfo = Table_GetMapGroup(nGroup)
            local szName = tGroupInfo.szName
            local tSubMenu = {szOption = szName}
            for _, dwMapID in ipairs(tGroup) do
				local szMiddleMap0, szMiddleMap1 = Table_GetMiddleMap(dwMapID)
				if szMiddleMap0 ~= "" then
					bHave = true
					table.insert(tSubMenu, {szOption = szMiddleMap0, UserData = {dwMapID, 0}, fnAction = fnSelectMapAction})
				end
				if szMiddleMap1 ~= "" then
					bHave = true
					table.insert(tSubMenu, {szOption = szMiddleMap1, UserData = {dwMapID, 1}, fnAction = fnSelectMapAction})
				end
			end
            table.insert(menu, tSubMenu)
		end
		if bHave then
			PopupMenu(menu)
		end
		return true
	elseif szName == "Btn_MarkSetting" then
		local fPosX, fPosY = this:GetAbsPos()
		local hFrame = this:GetRoot()
		local w, h = this:GetSize()
		
		local tMenu =
		{
			nMiniWidth = w,
			x = fPosX,
			y = fPosY + h,
			fnAction = function(UserData, bCheck)
                MiddleMap.aShowFlag[UserData] = bCheck
				MiddleMap.UpdateMapFlag(hFrame:Lookup("", "Handle_Map"))
			end,
			fnAutoClose = function() 
				if IsMiddleMapOpened() then 
					return false 
				else 
					return true 
				end 
			end,
		}
		
		for nIndex, nFlagFrame in pairs(tShowFlagFrame) do
			table.insert(tMenu, 
                {
                    szOption = "", UserData = nIndex, bCheck = true, bChecked = MiddleMap.aShowFlag[nIndex],
                    szIcon = szShowFlagImagePath, nFrame = nFlagFrame, 
                }
            )
		end
	
    	PopupMenu(tMenu)
    	return true
    end
end

function MiddleMap.OnMouseWheel()
	local szName = this:GetName()
	if szName == "MiddleMap" then
		return true
	end
end

function MiddleMap.NewFlagPoint(handle, x, y, nType, szName)	
	if not x or not y then
		local xC, yC = Cursor.GetPos()
		local xH, yH = handle:GetAbsPos()
		x, y = MiddleMap.HPosToLPos(xC - xH, yC - yH)
	end
	
	if not nType then
		nType = 1
	end
	if nType < 1 then
		nType = 1
	end
	if nType > 6 then
		nType = 6
	end
	
	if not szName then
		szName = g_tStrings.MIDDLEMAP_NEW_FLAG
	end
	
	if not MiddleMap.aFlag[MiddleMap.dwMapID] then
		MiddleMap.aFlag[MiddleMap.dwMapID] = {}
	end
	
	local aFlag = MiddleMap.aFlag[MiddleMap.dwMapID] 
	local v = {nType = nType, x = x, y = y, name = szName}
	
	local hMapMark = handle:Lookup("Handle_MapMark")
	local img = hMapMark:AppendItemFromIni(INI_FILE_PATH, "Image_Flag")
    img:AutoSize()
    img:SetFrame(tShowFlagFrame[v.nType])
	img:LockShowAndHide(true)
	img:RegisterEvent(511)
	if MiddleMap.aShowFlag[v.nType] then
	 	img:Show()
	 else
	 	img:Hide()
	 end
	img.x = v.x
	img.y = v.y
	img.szName = v.name
	img.bFlag = true
	img.nType = v.nType
	img.k = #aFlag + 1
	MiddleMap.UpdateMapPos(handle)
	table.insert(aFlag, v)
	return img
end

function MiddleMap.RemoveFlagPoint(hMapMark, nIndex)
	local img = hMapMark:Lookup(nIndex)
	local hMap = hMapMark:GetRoot():Lookup("", "Handle_Map")
	table.remove(MiddleMap.aFlag[MiddleMap.dwMapID], img.k)
	img:Hide()
	MiddleMap.UpdateMapFlag(hMap)
	MiddleMap.UpdateMapPos(hMap)
end

function MiddleMap.RenameFlagPoint(hMapMark, nIndex, nType, szName)
	local img = hMapMark:Lookup(nIndex)
	MiddleMap.aFlag[MiddleMap.dwMapID][img.k].nType = nType
	MiddleMap.aFlag[MiddleMap.dwMapID][img.k].name = szName
	img.nType = nType
	img.szName = szName
	img:SetFrame(tShowFlagFrame[nType])
end

function MiddleMap.OnItemLButtonDown()
	local szName = this:GetName()
	if szName == "Image_TrafficNode" then
		this.bDown = true
		MiddleMap.UpdateTrafficNodeState(this)
	end
end

function MiddleMap.OnItemLButtonUp()
	local szName = this:GetName()
	if szName == "Image_TrafficNode" then
		this.bDown = false
		MiddleMap.UpdateTrafficNodeState(this)
	end
end

function MiddleMap.MarkNpc(hFrame, dwNpcID, szName, fX, fY, szKind)
	MiddleMap.UnSelectArea(hFrame)
	MiddleMap.dwAreaOrNpcMapID = MiddleMap.dwMapID
	MiddleMap.nAreaOrNpcX = fX
	MiddleMap.nAreaOrNpcY = fY
	MiddleMap.szAreaOrNpcName = szName
	MiddleMap.szAreaOrNpcKind = szKind
	MiddleMap.nAreaID = nil
	MiddleMap.bArea = false
	
	ClearMarkQuestTargetPlace()
	MiddleMap.UpdateAreaOrNpcMark(hFrame:Lookup("", "Handle_Map"))
end

function MiddleMap.UnSelectArea(hFrame)
    local hList = hFrame:Lookup("Wnd_Tool", "Handle_NpcOrAreaList/Handle_AreaTrunk/Handle_List")
	local nCount = hList:GetItemCount() - 1
	for i = 0, nCount, 1 do
		local hChild = hList:Lookup(i)
		hChild.bSelect = false
		MiddleMap.UpdateAreaTitle(hChild)
	end
	
	MiddleMap.dwAreaOrNpcMapID = nil
	MiddleMap.UpdateAreaOrNpcMark(hList:GetRoot():Lookup("", "Handle_Map"))
end

function MiddleMap.OnItemLButtonClick()
	local hFrame = this:GetRoot()
	local szName = this:GetName()
	if szName == "Image_TrafficNode" then
		if not this.bDisable then
			if this.bSelfNode then
				OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.TRAFFIC_MIDDLE_ALEADY_IN_THIS_AREA)
			else
				OpenTrafficSurepanel(this.dwNodeID, this.dwCityID, this.szName, true)
			end
		end
    elseif szName == "Image_ListBg" then
        local hTrunk = this:GetParent()
        if hTrunk.bExpend then
            hTrunk.bExpend = false
        else
            hTrunk.bExpend = true
        end
        MiddleMap.SelectAreaOrNpcTrunk(hTrunk, hTrunk.bExpend)
    elseif szName == "Handle_Npc" then
        MiddleMap.SelectNpc(this)
    elseif szName == "Handle_Area" then
        MiddleMap.SelectArea(this)
	elseif this.bFlag then
		local nIndex = this:GetIndex()
		local fnSave = function(nType, szName)
			MiddleMap.nLastType = nType
			MiddleMap.RenameFlagPoint(Station.Lookup("Topmost1/MiddleMap", "Handle_Map/Handle_MapMark"), nIndex, nType, szName)
		end
		local fnDel = function()
			MiddleMap.RemoveFlagPoint(Station.Lookup("Topmost1/MiddleMap", "Handle_Map/Handle_MapMark"), nIndex)
		end
		local fnAutoClose = function()
			if Station.Lookup("Topmost1/MiddleMap") then
				return false
			end
			return true
		end
		
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
		EditMiddleMapFlag(MiddleMap.dwMapID, this.szName, this.nType, this.x, this.y, fnSave, fnDel, fnAutoClose, {x, y, w, h}, nil, this.bNew)
	elseif this.bMap then
		if IsShiftKeyDown() then
			local xC, yC = Cursor.GetPos()
			local xH, yH = this:GetParent():GetAbsPos()
			x, y = MiddleMap.HPosToLPos(xC - xH, yC - yH)
			SendGMCommand("player.SetPosition("..x..","..y..", 0)")
			CloseMiddleMap()
		end
	elseif this.bQuestTitle then
		ClearMarkQuestTargetPlace()
		MiddleMap.SelectQuest(hFrame, this.dwQuestID, true)
	elseif this.bAcceptedMark then
		ClearMarkQuestTargetPlace()
		MiddleMap.SelectQuest(hFrame, this.dwQuestID, true)
	end
end

function MiddleMap.OnItemLButtonDBClick()
	return MiddleMap.OnItemLButtonClick()
end

function MiddleMap.OnItemRButtonDown()

end

function MiddleMap.OnItemRButtonUp()

end

function MiddleMap.OnItemRButtonClick()
	if this.bMap then
		local img = MiddleMap.NewFlagPoint(this:GetParent(), nil, nil, MiddleMap.nLastType)
		local thisSave = this
		this = img
		this.bNew = true
		MiddleMap.OnItemLButtonClick()
		this.bNew = false
		this = thisSave
	elseif this.bFlag then
		return MiddleMap.OnItemLButtonClick()
	end
end

function MiddleMap.OnItemRButtonDBClick()
	if this.bFlag then
		return MiddleMap.OnItemLButtonClick()
	end
end

function MiddleMap.UpdateAreaInfoTip(frame)
	local handle = frame:Lookup("", "Handle_Map")
	local imgMap = handle:Lookup("Image_Map")
	local szName = nil
	if imgMap and imgMap.bInMap then
		local xC, yC = Cursor.GetPos()
		local xH, yH = handle:GetAbsPos()
		local x, y = MiddleMap.HPosToLPos(xC - xH, yC - yH)
		local x, y, z = Scene_GameWorldPositionToScenePosition(x, y, 0, 0)
		local nArea = GetRegionInfo(MiddleMap.dwMapID, x, y, z, true)
		szName = MiddleMap.GetMapAreaName(MiddleMap.dwMapID, nArea)
	end
	if szName and szName ~= "" then
		frame:Lookup("", "Text_Tip"):SetText(szName)
	else
		frame:Lookup("", "Text_Tip"):SetText("")
	end
end

function MiddleMap.OutputQuestTargetTip(dwQuestID, szType, nIndex, x, y, w, h)
	local hPlayer = GetClientPlayer()
	if not hPlayer then
		return
	end
	local szTip = ""
	local FormatQuestTip = function(szTarget, szQuestName)
		local szQuestTip = GetFormatText("[" .. szQuestName .. "]\n", FONT_QUEST_NAME) 
		.. GetFormatText(szTarget) 	
		return szQuestTip
	end
	local hQuestInfo = GetQuestInfo(dwQuestID)
	local tQuestStringInfo = Table_GetQuestStringInfo(dwQuestID)
	local szQuestName = tQuestStringInfo.szName 
	
	if szType == "quest_state" then
		local szState = tQuestStringInfo["szQuestValueStr"..(nIndex + 1)]
		if szState and szState ~= "" then
			szTip = szTip .. FormatQuestTip(szState, szQuestName)			
		end
	elseif szType == "kill_npc" then
		local szNpc = Table_GetNpcTemplateName(hQuestInfo["dwKillNpcTemplateID"..(nIndex + 1)])
		if szNpc and szNpc ~= "" then
			szTip = szTip .. FormatQuestTip(szNpc, szQuestName)						
		end
	elseif szType == "need_item" then
		local dwType, dwIndex = hQuestInfo["dwEndRequireItemType"..(nIndex + 1)], hQuestInfo["dwEndRequireItemIndex"..(nIndex + 1)]
    	local itemInfo = GetItemInfo(dwType, dwIndex)
    	local szItem = ""
    	if itemInfo then
    		szItem = GetItemNameByItemInfo(itemInfo)
    	end
		if szItem and szItem ~= "" then
			szTip = szTip .. FormatQuestTip(szItem, szQuestName)	
		end
	end
	if szTip and szTip ~= "" then
		OutputTip(szTip, 300, {x, y, w, h})
	end
end

function MiddleMap.OnItemMouseEnter()
	local x, y = this:GetAbsPos()
	local w, h = this:GetSize()
	w = w + 20
	h = h + 20
	local szName = this:GetName()
	if szName == "Animate_QuestPoint" then
		local dwQuestID = this.dwQuestID
		local szType = this.szType
		local nIndex = this.nIndex
		if dwQuestID then
			if szType == "accept" or szType == "finish" then
				OutputQuestTip(dwQuestID, {x, y, w, h})
			else
				MiddleMap.OutputQuestTargetTip(dwQuestID, szType, nIndex, x, y, w, h)
			end
		end
	elseif szName == "Image_Quest" then
		local dwQuestID = this.dwQuestID
		local szType = this.szType
		local nIndex = this.nIndex
		if dwQuestID then
			if szType == "accept" or szType == "finish" then
				OutputQuestTip(dwQuestID, {x, y, w, h})
			else
				MiddleMap.OutputQuestTargetTip(dwQuestID, szType, nIndex, x, y, w, h)
			end
		end
	elseif szName == "Image_FieldPQ" then
		local dwPQTemplateID = this.dwPQTemplateID
		if dwPQTemplateID then
			OutputFieldPQTip(dwPQTemplateID, {x, y, w, h})
		end
	elseif szName == "Image_ActivitySymbol" then
		local tSymbol = Table_GetActivitySymbol(this.dwMapID, this.nSymbolID)
		local szTip = GetFormatText(tSymbol.szName .. "\n" .. tSymbol.szDesc)
		OutputTip(szTip, 200, {x, y, w, h})
	elseif szName == "Image_TrafficNode" then
		OutputTip(GetFormatText(this.szName), 200, {x, y, w, h})
		this.bOver = true
		MiddleMap.UpdateTrafficNodeState(this)
    elseif szName == "Image_Npc" then
        local szTip = GetFormatText(this.szName)
        if this.szKind and this.szKind ~= "" then
            szTip = szTip..GetFormatText("\n".."<"..this.szKind..">")
        end
        OutputTip(szTip, 200, {x, y, w, h})
    elseif szName == "Handle_Npc" then
        this.bMouseOver = true
        MiddleMap.UpdateNpcTitle(this)
    elseif szName == "Handle_Area" then
        this.bMouseOver = true
        MiddleMap.UpdateAreaTitle(this)
	elseif this.bSelf and this.bAni then
		OutputTip(GetFormatText(g_tStrings.MAP_POSITION_SELF), 200, {x, y, w, h})
	elseif this.bTeammate then
		local szName = GetTeammateName(this.dwID)
		if szName then
			local r, g, b = GetPartyMemberFontColor()
			local szTip = "<text>text="..EncodeComponentsString(szName).."font=80 r="..r.." g="..g.." b="..b.."</text>"
			OutputTip(szTip, 200, {x, y, w, h})
		end
	elseif this.bFlag then
		OutputTip("<text>text="..EncodeComponentsString(this.szName).."</text>", 200, {x, y, w, h})
	elseif this.bMapMark then
		OutputTip("<text>text="..EncodeComponentsString(this.szName).."</text>", 200, {x, y, w, h})
	elseif this.bPing then
		OutputTip("<text>text="..EncodeComponentsString(g_tStrings.MAP_SUMMON_PLACE).."</text>", 200, {x, y, w, h})
	elseif this.bDie then
		OutputTip("<text>text="..EncodeComponentsString(g_tStrings.MAP_DEATH_PLACE).."</text>", 200, {x, y, w, h})
	elseif this.bMap then
		this.bInMap = true
		MiddleMap.UpdateAreaInfoTip(this:GetRoot())
	elseif this.bAreaOrNpc then
		if not MiddleMap.bArea then
			local szTip = GetFormatText(MiddleMap.szAreaOrNpcName)
			if MiddleMap.szAreaOrNpcKind and MiddleMap.szAreaOrNpcKind ~= "" then
				szTip = szTip..GetFormatText("\n".."<"..MiddleMap.szAreaOrNpcKind..">")
			end
			OutputTip(szTip, 200, {x, y, w, h})
		end
	elseif this.bQuestTitle then
		this.bOver = true
		MiddleMap.UpdateQuestTitleState(this)
	elseif this.bAcceptedMark then
		this.bOver = true
		MiddleMap.UpdateQuestAcceptedMarkState(this)
		local szTip = MiddleMap.GetQuestTraceTextOfMap(this.dwQuestID, true)
		OutputTip(szTip, 200, {x, y, w, h})
	elseif this.nDynamicType then
		local tData = Table_GetMapDynamicData()
		local tParam = tData[this.nDynamicType]
		if tParam and tParam.szTip and tParam.szTip ~= "" then
			local szTip = tParam.szTip
			OutputTip(szTip, 200, {x, y, w, h})
		end
	end
end

function MiddleMap.OnItemMouseLeave()
	szName = this:GetName()
	if szName == "Image_TrafficNode" then
		this.bOver = false
		MiddleMap.UpdateTrafficNodeState(this)
    elseif szName == "Handle_Npc" then
        this.bMouseOver = false
        MiddleMap.UpdateNpcTitle(this)
    elseif szName == "Handle_Area" then
        this.bMouseOver = false
        MiddleMap.UpdateAreaTitle(this)
	elseif this.bMap then
		this.bInMap = false
		MiddleMap.UpdateAreaInfoTip(this:GetRoot())
	elseif this.bQuestTitle then
		this.bOver = false
		MiddleMap.UpdateQuestTitleState(this)
	elseif this.bAcceptedMark then
		this.bOver = false
		MiddleMap.UpdateQuestAcceptedMarkState(this)
	end
	HideTip()
end

function MiddleMap.OnCheckBoxCheck()
	local szName = this:GetName()
	local hFrame = this:GetRoot()
	if szName == "CheckBox_ActiveNPC" then
		MiddleMap.bShowActivitySymbol = true
		MiddleMap.UpdateActivitySymbolShow(hFrame)
	elseif szName == "CheckBox_QuestPage" then
		if this:IsCheckBoxActive() then
			MiddleMap.SelectQuestOrMap(hFrame, true)
		end
	elseif szName == "CheckBox_MapPage" then
		MiddleMap.SelectQuestOrMap(hFrame, false)
    elseif szName == "CheckBox_QuestShowNormal" or 
    szName == "CheckBox_QuestShowRepeat" or 
    szName == "CheckBox_QuestShowLow" or
    szName == "CheckBox_QuestShowLower" then
        MiddleMap.CheckQuestShow(this, true)
	end
	
	PlaySound(SOUND.UI_SOUND, g_sound.Button)
end

function MiddleMap.OnCheckBoxUncheck()
	local hFrame = this:GetRoot()
	local szName = this:GetName()
	if szName == "CheckBox_ActiveNPC" then
		MiddleMap.bShowActivitySymbol = false
		MiddleMap.UpdateActivitySymbolShow(hFrame)
    elseif szName == "CheckBox_QuestShowNormal" or 
    szName == "CheckBox_QuestShowRepeat" or 
    szName == "CheckBox_QuestShowLow" or 
    szName == "CheckBox_QuestShowLower" then
        MiddleMap.CheckQuestShow(this, false)
	
	end
	PlaySound(SOUND.UI_SOUND, g_sound.Button)
end

function MiddleMap.CheckQuestShow(hCheck, bCheck)
    local szName = this:GetName()
    local szShow = string.match(szName, "CheckBox_QuestShow([%a]+)")
    MiddleMap.tQuestShow[szShow] = bCheck
    local hFrame = hCheck:GetRoot()
    MiddleMap.MarkPlayerQuest(hFrame)
end

function MiddleMap.OnEditChanged()
	local szName = this:GetName()
	if szName == "Edit_Search" then
		MiddleMap.UpdateAreaOrNpcList(this:GetRoot(), true)
	end
end

function MiddleMap.OnSetFocus()
	local szName = this:GetName()
	if szName == "Edit_Search" then
		this:SelectAll()
	end
end

function MiddleMap.OnKillFocus()
	local szName = this:GetName()
	if szName == "Edit_Search" then
	end	
end

function MiddleMap.GetMapMiddleMapIndex(dwMapID, nArea)
	MiddleMap.InitMiddleMapInfo(dwMapID)
	if MiddleMap.aArea[dwMapID] and MiddleMap.aArea[dwMapID][nArea] then
		return MiddleMap.aArea[dwMapID][nArea].middlemap
	end
	return 0
end

function MiddleMap.GetMapAreaBgMusic(dwMapID, nArea)
	MiddleMap.InitMiddleMapInfo(dwMapID)
	if MiddleMap.aArea[dwMapID] and MiddleMap.aArea[dwMapID][nArea] then
		return MiddleMap.aArea[dwMapID][nArea].backgroundmusic
	end
	return ""	
end

function MiddleMap.GetMapAreaName(dwMapID, nArea)
	MiddleMap.InitMiddleMapInfo(dwMapID)
	if MiddleMap.aArea[dwMapID] and MiddleMap.aArea[dwMapID][nArea] then
		return MiddleMap.aArea[dwMapID][nArea].name
	end
	return ""
end

function MiddleMap.InitMiddleMapInfo(dwMapID)
	if MiddleMap.aLoad[dwMapID] then
		return
	end
	
	local aInfo = {}
	local aArea = {}
	local aNpc = {}
	local szPath = GetMapParams(dwMapID)
	local iniC = Ini.AdjustOpen(szPath.."minimap\\config.ini")
	local tMapName = {Table_GetMiddleMap(dwMapID)}
	if iniC then
		for i = 0, 1 do
			local szSection = "middlemap"..i
			if iniC:IsSectionExist(szSection) then
				local t = {}
				if iniC:ReadInteger(szSection, "copy", 0) ~= 0 then
					t.copy = true
				end
				if iniC:ReadInteger(szSection, "fresherroom", 0) ~= 0 then
					t.fresherroom = true
				end
				if iniC:ReadInteger(szSection, "battlefield", 0) ~= 0 then
					t.battlefield = true
				end
				t.name = tMapName[i + 1]
				t.image = iniC:ReadString(szSection, "image", "")
				t.width = iniC:ReadInteger(szSection, "width", 1024)
				t.height = iniC:ReadInteger(szSection, "height", 1024)
				t.scale = iniC:ReadFloat(szSection, "scale", 0.001)
				t.startx = iniC:ReadFloat(szSection, "startx", 0)
				t.starty = iniC:ReadFloat(szSection, "starty", 0)
				aInfo[i] = t
			end
		end
		iniC:Close()
	end

	local tAreaTitle = 
	{
		{f="i", t="id"},
		{f="s", t="name"},
		{f="i", t="middlemap"},
		{f="p", t="backgroundmusic"},
		{f="i", t="type"},
		{f="i", t="x"},
		{f="i", t="y"},
		{f="i", t="z"},
		{f="i", t="show"},
	}
	local tArea = KG_Table.Load(szPath.."minimap\\area.tab", tAreaTitle, FILE_OPEN_MODE.NORMAL)
	if tArea then
		local t = {}
		local nRowCount = tArea:GetRowCount()
		for nRow = 2, nRowCount do
			local tRow = tArea:GetRow(nRow)

			local id = tRow.id
			local szName = tRow.name
			local nMiddlemap = tRow.middlemap
			local szBackgroundmusic = tRow.backgroundmusic
			local nType = tRow.type
			local nX = tRow.x
			local nY = tRow.y
			local nZ = tRow.z
			local nShow = tRow.show
			t[id] = {name = szName, middlemap = nMiddlemap, backgroundmusic = szBackgroundmusic, type = nType, x = nX, y = nY, z = nZ, bShow = not nShow or nShow ~= 0}
		end
		aArea = t
		tArea = nil
	else
		local tabR = Tab.Open(szPath.."minimap\\area.tab")
		if tabR then
			local t = {}
			local nRow = tabR:GetHeight()
			for i = 2, nRow, 1 do
				local id = tabR:GetInteger(i, "id", 0)
				local szName = tabR:GetString(i, "name", "")
				local nMiddlemap = tabR:GetInteger(i, "middlemap", 0)
				local szBackgroundmusic = tabR:GetString(i, "backgroundmusic", "")
				local nType = tabR:GetInteger(i, "type", 0)
				local nX = tabR:GetInteger(i, "x", 0)
				local nY = tabR:GetInteger(i, "y", 0)
				local nZ = tabR:GetInteger(i, "z", 0)
				local nShow = tabR:GetInteger(i, "show", 1)
				nX = nX or 0
				nY = nY or 0
				t[id] = {name = szName, middlemap = nMiddlemap, backgroundmusic = szBackgroundmusic, type = nType, x = nX, y = nY, z = nZ, bShow = not nShow or nShow ~= 0}
			end
			aArea = t
			tabR:Close()
		end
	end
	
	local tNpcTitle = 
	{
		{f="i", t="id"},
        {f="i", t="npcid"},
		{f="i", t="middlemap"},
		{f="s", t="kind"},
		{f="i", t="type"},
		{f="s", t="position"},
		{f="i", t="important"},
		{f="i", t="npctype"},
	}
	local tNpc = KG_Table.Load(szPath.."minimap\\npc.tab", tNpcTitle, FILE_OPEN_MODE.NORMAL)
    local function ParsePosition(szPosition)
        local tPoint = {}
        for szX, szY, szZ in string.gmatch(szPosition, "([%d]+),([%d]+),([%d]+);?") do
            local nX = tonumber(szX)
            local nY = tonumber(szY)
            local nZ = tonumber(szZ)
            table.insert(tPoint, {nX, nY})
        end
        
        return tPoint
    end
	if tNpc then
		local t = {}
		local nRowCount = tNpc:GetRowCount()
        local tIDMap = {}
		for nRow = 2, nRowCount do
			local tRow = tNpc:GetRow(nRow)

			local nID = tRow.id
            local nNpcID = tRow.npcid
			local nMiddlemap = tRow.middlemap
			local szKind = tRow.kind
			local nType = tRow.type
            local tPoint = ParsePosition(tRow.position)
			local bImportant = tRow.important and tRow.important ~= 0
			local nNpcType = tRow.npctype
            if nNpcID == 0 then
                table.insert(t, {id = nID, middlemap = nMiddlemap, type = nType, kind = szKind, important = bImportant, group ={ }})
                tIDMap[nID] = #t
            else
                local nIndex = tIDMap[nID]
                local tNpcGroup = t[nIndex].group
                table.insert(tNpcGroup, {nNpcID = nNpcID, tPoint = tPoint, nNpcType = nNpcType, szKind = szKind})
            end
		end
		aNpc = t
		tNpc = nil
	else
		local tabR = Tab.Open(szPath.."minimap\\npc.tab")
		if tabR then
			local t = {}
            local tIDMap = {}
			local nRow = tabR:GetHeight()
			for i = 3, nRow, 1 do
				local nID = tabR:GetInteger(i, "id", 0)
                local nNpcID = tabR:GetInteger(i, "npcid", 0)
				local nMiddlemap = tabR:GetInteger(i, "middlemap", 0)
				local nType = tabR:GetInteger(i, "type", 0)
				local szKind = tabR:GetString(i, "kind", "")
                local szPosition = tabR:GetString(i, "position", "")
                local tPoint = ParsePosition(szPosition)
				local nImportant = tabR:GetInteger(i, "important", 0)
				local bImportant = nImportant and nImportant ~= 0
				local nNpcType = tabR:GetInteger(i, "npctype", 0)
                if nNpcID == 0 then
                    table.insert(t, {id = nID, middlemap = nMiddlemap, type = nType, kind = szKind, important = bImportant, group={}})
                    tIDMap[nID] = #t
                else
                    local nIndex = tIDMap[nID]
                    local tNpcGroup = t[nIndex].group
                    table.insert(tNpcGroup, {nNpcId = nNpcID, tPoint = tPoint, nNpcType = nNpcType, szKind = szKind})
                end
			end
			aNpc = t
			tabR:Close()
		end	
	end
	
	MiddleMap.aInfo[dwMapID] = aInfo
	MiddleMap.aArea[dwMapID] = aArea
	MiddleMap.aNpc[dwMapID] = aNpc
	MiddleMap.aLoad[dwMapID] = true	
	MiddleMap.InitMapCanAcceptQuestInfo(dwMapID)
	MiddleMap.InitMapFieldPQInfo(dwMapID)
end

function MiddleMap.OnSelectArea(hFrame, dwAreaID)
	local hList = hFrame:Lookup("Wnd_Tool", "Handle_NpcOrAreaList/Handle_AreaTrunk/Handle_List")
	local nCount = hList:GetItemCount()
	for i = 0, nCount - 1 do
		local hChild = hList:Lookup(i)
		if hChild.bArea and hChild.nAreaID == dwAreaID then
			MiddleMap.SelectArea(hChild)
			break
		end
	end
end

function MiddleMap.UpdateQuestList(hFrame)
	local tFinishQuestList, tAcceptQuestist = MiddleMap.GetQuestListOfMap(MiddleMap.dwMapID)
	local nCount = #tFinishQuestList + #tAcceptQuestist
	MiddleMap.nQuestCount = nCount
	local hQuestList = hFrame:Lookup("Wnd_Quest", "Handle_QuestList")
	local hQuestAcceptedMark = hFrame:Lookup("", "Handle_QuestAcceptedMark")
	local hQuestTargetMark = hFrame:Lookup("", "Handle_QuestTargetMark")
	local hInfo = hFrame:Lookup("Wnd_Quest", "Handle_QuestMsg")
	
	hQuestTargetMark:Clear()
	hInfo:Clear()
	hQuestList:Clear()
	hQuestAcceptedMark:Clear()
	local hQuest
	local dwFirstQuestID = nil
	for nIndex, tQuest in ipairs(tFinishQuestList) do
		local dwQuestID = tQuest[1]
		if not dwFirstQuestID then
			dwFirstQuestID = dwQuestID
		end
		
		hQuest = hQuestList:AppendItemFromIni(INI_FILE_PATH, "Handle_QuestTitle", "Handle_QuestTitle" .. dwQuestID)
		hQuest.bFinish = true
		hQuest.szTraceType = tQuest[4]
		hQuest.nTraceIndex = tQuest[5]
		MiddleMap.UpdateQuestTitle(hQuest, dwQuestID)
		local hMark = hQuestAcceptedMark:AppendItemFromIni(INI_FILE_PATH, "Handle_AcceptMark", "Handle_AcceptMark" .. dwQuestID)
		hMark.bFinish = true
		hMark.szTraceType = tQuest[4]
		hMark.nTraceIndex = tQuest[5]
		MiddleMap.UpdateAcceptedMark(hMark, dwQuestID, tQuest[2], tQuest[3])
	end
	
	for nIndex, tQuest in ipairs(tAcceptQuestist) do
		local dwQuestID = tQuest[1]
		if not dwFirstQuestID then
			dwFirstQuestID = dwQuestID
		end
		hQuest = hQuestList:AppendItemFromIni(INI_FILE_PATH, "Handle_QuestTitle", "Handle_QuestTitle" .. dwQuestID)
		hQuest.bFinish = false
		hQuest.nIndex = nIndex
		hQuest.szTraceType = tQuest[4]
		hQuest.nTraceIndex = tQuest[5]
		MiddleMap.UpdateQuestTitle(hQuest, dwQuestID)
		local hMark = hQuestAcceptedMark:AppendItemFromIni(INI_FILE_PATH, "Handle_AcceptMark", "Handle_AcceptMark" .. dwQuestID)
		hMark.bFinish = false
		hMark.nIndex = nIndex
		hMark.szTraceType = tQuest[4]
		hMark.nTraceIndex = tQuest[5]
		MiddleMap.UpdateAcceptedMark(hMark, dwQuestID, tQuest[2], tQuest[3])
	end
	hQuestList:FormatAllItemPos()
	hQuestAcceptedMark:FormatAllItemPos()
	FireUIEvent("SCROLL_UPDATE_LIST", "Handle_QuestList", "MiddleMap", true)
	
	if MiddleMap.dwQuestID then
		local dwQuestID = MiddleMap.dwQuestID
		local hSelect = hQuestList:Lookup("Handle_QuestTitle" .. dwQuestID)
		if hSelect then
			MiddleMap.SelectQuest(hFrame, dwQuestID, false)
		else
			MiddleMap.dwQuestID = nil
		end
	end
	
	if not MiddleMap.dwQuestID and dwFirstQuestID then
		MiddleMap.SelectQuest(hFrame, dwFirstQuestID, true)
	end
	
	MiddleMap.UpdateQuestOrMapCheckState(hFrame)
end

function MiddleMap.UpdateQuestTitleState(hQuest)
	local hImageSel = hQuest:Lookup("Image_Sel")
	if hQuest.bSelect then
		hImageSel:Show()
		hImageSel:SetAlpha(255)
	elseif hQuest.bOver then
		hImageSel:Show()
		hImageSel:SetAlpha(128)
	else
		hImageSel:Hide()
	end
end

function MiddleMap.UpdateAcceptedMark(hMark, dwQuestID, fX, fY)
	hMark.dwQuestID = dwQuestID
	hMark.bAcceptedMark = true
	local hHandle = hMark:GetParent()
	local hImageNunmber = hMark:Lookup("Image_IndexNumber")
	local hNumber = hMark:Lookup("Text_IndexNumber")
	local tFrame
	if hMark.bFinish then
		tFrame = MiddleMap.tQuestFinishFrame
		hNumber:Hide()
	else
		tFrame = MiddleMap.tQuestTargetFrame
		hNumber:SetText(hMark.nIndex)
		hNumber:Show()
	end
	hImageNunmber:FromUITex(tFrame.szFrame, tFrame.Normal)
	hImageNunmber:AutoSize()
	
	local nWidth, nHeight = hMark:GetSize()
	local nX, nY = MiddleMap.LPosToHPos(fX, fY, nWidth, nHeight)
	hMark:SetRelPos(nX, nY)
	hMark:Show()
	hHandle:FormatAllItemPos()
end

function MiddleMap.SelectQuest(hFrame, dwQuestID, bHome)
	MiddleMap.dwQuestID = dwQuestID
	local hQuestList = hFrame:Lookup("Wnd_Quest", "Handle_QuestList")
	local hQuest = hQuestList:Lookup("Handle_QuestTitle" .. dwQuestID)
	local nCount = hQuestList:GetItemCount()
	for i = 0, nCount - 1 do 
		local hChild = hQuestList:Lookup(i)
		if hChild.bSelect then
			hChild.bSelect = false
			MiddleMap.UpdateQuestTitleState(hChild)
		end
	end
	hQuest.bSelect = true
	MiddleMap.UpdateQuestTitleState(hQuest)
	MiddleMap.UpdateQuestInfo(hFrame, dwQuestID, bHome)
	
	local hQuestAcceptedMark = hFrame:Lookup("", "Handle_QuestAcceptedMark")
	nCount = hQuestAcceptedMark:GetItemCount()
	for i = 0, nCount - 1 do
		local hChild = hQuestAcceptedMark:Lookup(i)
		if hChild.bSelect then
			hChild.bSelect = false
			MiddleMap.UpdateQuestAcceptedMarkState(hChild)
		end
	end
	local hMark = hQuestAcceptedMark:Lookup("Handle_AcceptMark" .. dwQuestID)
	hMark.bSelect = true
	MiddleMap.UpdateQuestAcceptedMarkState(hMark)
	
	if hMark.bFinish then
		local hQuestTargetMark = hFrame:Lookup("", "Handle_QuestTargetMark")
		hQuestTargetMark:Clear()
	else
		MiddleMap.MarkTargetOfQuest(hFrame, dwQuestID, hMark.szTraceType, hMark.nTraceIndex)
	end
	hMark:SetIndex(nCount - 1)
	hQuestAcceptedMark:FormatAllItemPos()

	MiddleMap.UpdateQuestBtnState(hFrame)
end

function MiddleMap.UpdateQuestBtnState(hFrame)
	local hBtnQCancel = hFrame:Lookup("Wnd_Quest/Btn_QCancel")
	local hBtnTrace = hFrame:Lookup("Wnd_Quest/Btn_QTrace")
	local hBtnCancelTrace = hFrame:Lookup("Wnd_Quest/Btn_QCancelTrace")
	local hBtnShare = hFrame:Lookup("Wnd_Quest/Btn_QShare")
	if MiddleMap.dwQuestID then
		local dwQuestID = MiddleMap.dwQuestID
		hBtnQCancel:Show()
		hBtnQCancel:Enable(true)
		hBtnShare:Show()
		if IsTraceQuest(dwQuestID) then
			hBtnCancelTrace:Show()
			hBtnCancelTrace:Enable(true)
			hBtnTrace:Hide()
		else
			hBtnCancelTrace:Hide()
			hBtnTrace:Show()
			hBtnTrace:Enable(true)
		end
		
		hBtnShare:Enable(GetQuestInfo(dwQuestID).bShare)
	else
		hBtnQCancel:Hide()
		hBtnTrace:Hide()
		hBtnCancelTrace:Hide()
		hBtnShare:Hide()
	end
end

function MiddleMap.MarkTargetOfQuest(hFrame, dwQuestID, szType, nTraceIndex)
	local hQuestTargetMark = hFrame:Lookup("", "Handle_QuestTargetMark")
	hQuestTargetMark:Clear()
	local hPlayer = GetClientPlayer()
	if not hPlayer then
		return
	end
	local bFirstPointHide = false
	local tQuestTrace = hPlayer.GetQuestTraceInfo(dwQuestID)
	for k, v in pairs(tQuestTrace.quest_state) do
		if v.have < v.need then
			bFirstPointHide = false
			if szType == "quest_state" and v.i == nTraceIndex then
				bFirstPointHide = true
			end
			MiddleMap.UpdateQuestTarget(hQuestTargetMark, false, dwQuestID, "quest_state", v.i, bFirstPointHide)
		end
	end
	
	for k, v in pairs(tQuestTrace.kill_npc) do
		if v.have < v.need then
			bFirstPointHide = false
			if szType == "kill_npc" and v.i == nTraceIndex then
				bFirstPointHide = true
			end
			MiddleMap.UpdateQuestTarget(hQuestTargetMark, false, dwQuestID, "kill_npc", v.i, bFirstPointHide)
		end
	end
	
	for k, v in pairs(tQuestTrace.need_item) do
		local itemInfo = GetItemInfo(v.type, v.index)
		local nBookID = v.need
		if itemInfo.nGenre == ITEM_GENRE.BOOK then
			v.need = 1
		end
		if v.have < v.need then
			bFirstPointHide = false
			if szType == "kill_npc" and v.i == nTraceIndex then
				bFirstPointHide = true
			end
			MiddleMap.UpdateQuestTarget(hQuestTargetMark, false, dwQuestID, "need_item", v.i, bFirstPointHide)
		end
	end
	
	hQuestTargetMark:FormatAllItemPos()
end

function MiddleMap.UpdateQuestAcceptedMarkState(hMark)
	local tFrame = MiddleMap.tQuestTargetFrame
	if hMark.bFinish then
		tFrame = MiddleMap.tQuestFinishFrame
	end 
	local hImageNunmber = hMark:Lookup("Image_IndexNumber")
	if hMark.bSelect then
		hImageNunmber:SetFrame(tFrame.Check)
	elseif hMark.bOver then
		hImageNunmber:SetFrame(tFrame.Over)
	else
		hImageNunmber:SetFrame(tFrame.Normal)
	end
end

function MiddleMap.UpdateQuestInfo(hFrame, dwQuestID, bHome)
	local hInfo  = hFrame:Lookup("Wnd_Quest", "Handle_QuestMsg")
	hInfo:Clear()
	local hPlayer = GetClientPlayer()
	if not hPlayer then
		return
	end
	local tQuestInfo = GetQuestInfo(dwQuestID)
	local tQuestStringInfo = Table_GetQuestStringInfo(dwQuestID)
	local tQuestTrace = hPlayer.GetQuestTraceInfo(dwQuestID)
	
	hInfo:AppendItemFromString(GetFormatText(tQuestStringInfo.szName.."\n\n", 1))
	QuestAcceptPanel.UpdateHortation(hInfo, tQuestInfo, false, false, false, true)
	hInfo:AppendItemFromString(GetFormatText("\n" .. g_tStrings.STR_QUEST_QUEST_GOAL,  1))
	QuestAcceptPanel.EncodeString(hInfo, tQuestStringInfo.szObjective.."\n", 160)
	QuestPanel.AppendQuestTrace(hInfo, tQuestTrace, tQuestStringInfo)
	hInfo:AppendItemFromString(GetFormatText(g_tStrings.STR_QUEST_QUEST_DESCRIPTION, 1))
    QuestAcceptPanel.EncodeString(hInfo, tQuestStringInfo.szDescription.."\n\n", 160, false)
    hInfo:FormatAllItemPos()
	FireUIEvent("SCROLL_UPDATE_LIST", "Handle_QuestMsg", "MiddleMap", bHome)
end

function MiddleMap.UpdateQuestTitle(hQuest, dwQuestID)
	local hPlayer = GetClientPlayer()
	if not hPlayer then
		return 
	end
	hQuest.dwQuestID = dwQuestID
	hQuest.bQuestTitle = true
	local tQuestTrace = hPlayer.GetQuestTraceInfo(dwQuestID)
	local tQuestStringInfo = Table_GetQuestStringInfo(dwQuestID)
	local hInfo = hQuest:Lookup("Handle_Title")
	hInfo:Clear()
	local szText = MiddleMap.GetQuestTraceTextOfMap(dwQuestID)
	hInfo:AppendItemFromString(szText)
	
	local hImageNunmber = hQuest:Lookup("Image_Number")
	local hNumber = hQuest:Lookup("Text_Number")
	local tFrame
	if hQuest.bFinish then
		tFrame = MiddleMap.tQuestFinishFrame
		hNumber:Hide()
	else
		tFrame = MiddleMap.tQuestTargetFrame
		hNumber:SetText(hQuest.nIndex)
		hNumber:Show()
	end
	hImageNunmber:FromUITex(tFrame.szFrame, tFrame.Normal)
	hImageNunmber:AutoSize()
	
	local fWidth = hInfo:GetSize()
	hInfo:SetSize(fWidth, 500)
	hInfo:FormatAllItemPos()
	local _, fHeight = hInfo:GetAllItemSize()
	
	hInfo:SetSize(fWidth, fHeight)
	hQuest:FormatAllItemPos()
	local fMiniHeight = 50
	if fHeight < fMiniHeight then
		fHeight = fMiniHeight
	end
	fWidth = hQuest:GetSize()
	local hImageSel = hQuest:Lookup("Image_Sel")
	hImageSel:Hide()
	hImageSel:SetSize(fWidth, fHeight)
	hQuest:SetSize(fWidth, fHeight)
	local hFrame = hQuest:GetRoot()
	MiddleMap.UpdateQuestTraceState(hFrame, dwQuestID)
end

function MiddleMap.UpdateQuestTraceState(hFrame, dwQuestID)
	local hQuestList = hFrame:Lookup("Wnd_Quest", "Handle_QuestList")
	local hQuest = hQuestList:Lookup("Handle_QuestTitle" .. dwQuestID)
	if not hQuest then
		return
	end
	local hImgTrace = hQuest:Lookup("Image_QTrace")
	if IsTraceQuest(dwQuestID) then
		hImgTrace:Show()
	else
		hImgTrace:Hide()
	end
end

function MiddleMap.GetQuestTraceTextOfMap(dwQuestID, bTip)
	local dwMapID = MiddleMap.dwMapID
	local szText = ""
	local hPlayer = GetClientPlayer()
	if not hPlayer then
		return szText
	end
	local tQuestTrace = hPlayer.GetQuestTraceInfo(dwQuestID)
	local tQuestStringInfo = Table_GetQuestStringInfo(dwQuestID)
	if bTip then
		szText = GetFormatText("[" .. tQuestStringInfo.szName .. "]", FONT_QUEST_NAME)
	else
		szText = GetFormatText(tQuestStringInfo.szName, FONT_QUEST_NAME)
	end
	
	local szState = ""
	if tQuestTrace.finish then
		szState = g_tStrings.STR_QUEST_QUEST_CAN_FINISH
	elseif tQuestTrace.fail then
		szState = g_tStrings.STR_QUEST_QUEST_WAS_FAILED
	elseif tQuestStringInfo.szQuestDiff then
		szState = tQuestStringInfo.szQuestDiff
	end	
	szText = szText .. GetFormatText(szState .. "\n", nFont)
	if tQuestTrace.finish then
		return szText
	end
	
	if tQuestTrace.time then
		local nTime = tQuestTrace.time
		if tQuestTrace.fail then
			nTime = 0
		end
		local szTime = GetTimeText(nTime)
		szText = szText .. GetFormatText(g_tStrings.STR_TWO_CHINESE_SPACE..g_tStrings.STR_QUEST_TIME_LIMIT..szTime.."\n")
	end

	for k, v in pairs(tQuestTrace.quest_state) do
		if v.have < v.need then
			local tPointList = Table_GetQuestPoint(dwQuestID, "quest_state", v.i)
			if tPointList and tPointList[dwMapID] then
				local szName = tQuestStringInfo["szQuestValueStr" .. (v.i + 1)]
				local szTarget = g_tStrings.STR_TWO_CHINESE_SPACE..szName.."："..v.have.."/"..v.need
				szText = szText ..  GetFormatText(szTarget .. "\n", FONT_QUEST_TARGET_NOT_FINISH)
			end	
		end
	end
	
	local bKillNpc = false
	for k, v in pairs(tQuestTrace.kill_npc) do
		if v.have < v.need then
			local tPointList = Table_GetQuestPoint(dwQuestID, "kill_npc", v.i)
			if tPointList and tPointList[dwMapID] then
				local szName = Table_GetNpcTemplateName(v.template_id)
				if not szName or szName == "" then
					szName = "Unknown Npc"
				end
				local szTarget = g_tStrings.STR_TWO_CHINESE_SPACE.. szName .."："..v.have.."/"..v.need
				szText = szText ..  GetFormatText(szTarget .. "\n", FONT_QUEST_TARGET_NOT_FINISH)
			end
		end
	end

	for k, v in pairs(tQuestTrace.need_item) do
		local itemInfo = GetItemInfo(v.type, v.index)
		local nBookID = v.need
		if itemInfo.nGenre == ITEM_GENRE.BOOK then
			v.need = 1
		end
		if v.have < v.need then
			local tPointList = Table_GetQuestPoint(dwQuestID, "need_item", v.i)
			if tPointList and tPointList[dwMapID] then
				local szName = "Unknown Item"
				if itemInfo then
					szName = GetItemNameByItemInfo(itemInfo, nBookID)
				end
				local szTarget = g_tStrings.STR_TWO_CHINESE_SPACE.. szName .."："..v.have.."/"..v.need
				szText = szText ..  GetFormatText(szTarget .. "\n", FONT_QUEST_TARGET_NOT_FINISH)
			end
		end
	end
	
	return szText
end

function MiddleMap.GetQuestListOfMap(dwMapID)
	local tFinishQuestOfMap = {}
	local tAcceptQuestOfMap = {}
	local hPlayer = GetClientPlayer()
	if not hPlayer then
		return tQuestOfMap
	end
	local tQuestList = hPlayer.GetQuestList()
	for _, dwQuestID in pairs(tQuestList) do
		local fX, fY ,szType, nIndex = MiddleMap.GetQuestFinishPoint(dwQuestID, dwMapID)
		if fX then
			table.insert(tFinishQuestOfMap, {dwQuestID, fX, fY, szType, nIndex}) -- 已完成的的任务
		else
			fX, fY, szType, nIndex  = MiddleMap.GetQuestTargetPoint(dwQuestID, dwMapID)
			if fX then
				table.insert(tAcceptQuestOfMap, {dwQuestID, fX, fY, szType, nIndex}) -- 未完成的任务
			end
		end
	end
	return tFinishQuestOfMap, tAcceptQuestOfMap
end

function MiddleMap.GetQuestFinishPoint(dwQuestID, dwMapID)
	local hPlayer = GetClientPlayer()
	if not hPlayer then
		return
	end
	local tQuestTrace = hPlayer.GetQuestTraceInfo(dwQuestID)
	local tPointList = Table_GetQuestPoint(dwQuestID, "finish", 0)
	if tPointList and tPointList[dwMapID]and tQuestTrace.finish then
		local tPoint = tPointList[dwMapID][1]
		return tPoint[1], tPoint[2], "finish"
	end
end

function MiddleMap.GetQuestTargetPoint(dwQuestID, dwMapID)
	local hPlayer = GetClientPlayer()
	if not hPlayer then
		return
	end
	local tQuestTrace = hPlayer.GetQuestTraceInfo(dwQuestID)
	for k, v in pairs(tQuestTrace.quest_state) do
		if v.have < v.need then
			local tPointList = Table_GetQuestPoint(dwQuestID, "quest_state", v.i)
			if tPointList and tPointList[dwMapID] then
				local tPoint = tPointList[dwMapID][1]
				return tPoint[1], tPoint[2], "quest_state", v.i
			end
		end
	end
	
	for k, v in pairs(tQuestTrace.kill_npc) do
		if v.have < v.need then
			local tPointList = Table_GetQuestPoint(dwQuestID, "kill_npc", v.i)
			if tPointList and tPointList[dwMapID] then
				local tPoint = tPointList[dwMapID][1]
				return tPoint[1], tPoint[2], "kill_npc", v.i
			end
		end
	end
	
	for k, v in pairs(tQuestTrace.need_item) do
		local itemInfo = GetItemInfo(v.type, v.index)
		local nBookID = v.need
		if itemInfo.nGenre == ITEM_GENRE.BOOK then
			v.need = 1
		end
		if v.have < v.need then
			local tPointList = Table_GetQuestPoint(dwQuestID, "need_item", v.i)
			if tPointList and tPointList[dwMapID] then
				local tPoint = tPointList[dwMapID][1]
				return tPoint[1], tPoint[2], "need_item", v.i
			end
		end
	end
end

function MiddleMap.GetQuestMapID(dwQuestID)
	if not dwQuestID then
		return
	end
	local hPlayer = GetClientPlayer()
	if not hPlayer then
		return
	end
	local hScene = hPlayer.GetScene()
	local dwSceneMapID = hScene.dwMapID
	local dwMapID
	local function GetFirstMapID(tPointList)
		local dwFirstMapID = nil
		if tPointList then
			for nIndex in pairs(tPointList) do
				dwFirstMapID = nIndex
				break
			end
		end
		return dwFirstMapID
	end
	local tQuestTrace = hPlayer.GetQuestTraceInfo(dwQuestID)
	if tQuestTrace.finish then
		local tPointList = Table_GetQuestPoint(dwQuestID, "finish", 0)
		if tPointList and tPointList[dwSceneMapID] then
			dwMapID = dwSceneMapID
		else
			dwMapID = GetFirstMapID(tPointList)
		end
		return dwMapID
	end
	
	for k, v in pairs(tQuestTrace.quest_state) do
		if v.have < v.need then
			local tPointList = Table_GetQuestPoint(dwQuestID, "quest_state", v.i)
			if tPointList and tPointList[dwSceneMapID] then
				return dwSceneMapID
			elseif not dwMapID then
				dwMapID = GetFirstMapID(tPointList)
			end
		end
	end
	
	for k, v in pairs(tQuestTrace.kill_npc) do
		if v.have < v.need then
			local tPointList = Table_GetQuestPoint(dwQuestID, "kill_npc", v.i)
			if tPointList and tPointList[dwSceneMapID] then
				return dwSceneMapID
			elseif not dwMapID then
				dwMapID = GetFirstMapID(tPointList)
			end
		end
	end
	
	for k, v in pairs(tQuestTrace.need_item) do
		local itemInfo = GetItemInfo(v.type, v.index)
		local nBookID = v.need
		if itemInfo.nGenre == ITEM_GENRE.BOOK then
			v.need = 1
		end
		if v.have < v.need then
			local tPointList = Table_GetQuestPoint(dwQuestID, "need_item", v.i)
			if tPointList and tPointList[dwSceneMapID] then
				return dwSceneMapID
			elseif not dwMapID then
				dwMapID = GetFirstMapID(tPointList)
			end
		end
	end
	return dwMapID
end

function MiddleMap.UpdateTraffic(hFrame, bTraffic)
	local hTrafficHandle = hFrame:Lookup("", "Handle_Traffic")
	local hTrafficBg = hFrame:Lookup("", "Image_TrafficBg")
	if not bTraffic then
		hTrafficHandle:Hide()
		hTrafficBg:Hide()
		return
	end
	hTrafficHandle:Clear()
	hTrafficHandle:Show()
	hTrafficBg:Show()
	
	for _, tNode in ipairs(MiddleMap.tTrafficNode) do
		local hTrafficNode = hTrafficHandle:AppendItemFromIni(INI_FILE_PATH, "Image_TrafficNode")
		hTrafficNode:Show()
		hTrafficNode.bTrafficNode = true
		hTrafficNode.dwTrafficID = tNode.dwTrafficID
		hTrafficNode.dwNodeID = tNode.dwNodeID
		hTrafficNode.dwCityID = tNode.dwCityID
		hTrafficNode.bDisable = tNode.bDisable
		hTrafficNode.szName = tNode.szName
		hTrafficNode.nType = tNode.nType
		if tNode.dwTrafficID == MiddleMap.dwTrafficID then
			hTrafficNode.bSelfNode = true
		end
		MiddleMap.UpdateTrafficNodeState(hTrafficNode)
		hTrafficNode:AutoSize()
		local nWidth, nHeight = hTrafficNode:GetSize()
		local nX, nY = MiddleMap.LPosToHPos(tNode.nX, tNode.nY, nWidth, nHeight)
		hTrafficNode:SetRelPos(nX, nY)
	end
	hTrafficHandle:FormatAllItemPos()
	hFrame:Lookup("CheckBox_MapPage"):Check(true)
end

function MiddleMap.UpdateTrafficNodeState(hNode)
	local tFrame = MiddleMap.tTrafficFrame[hNode.nType]
	if hNode.bSelfNode then
		hNode:SetFrame(tFrame.Self)
	elseif hNode.bDisable then
		hNode:SetFrame(tFrame.Disable)
	elseif hNode.bDown then
		hNode:SetFrame(tFrame.Down)
	elseif hNode.bOver then
		hNode:SetFrame(tFrame.Over)
	else
		hNode:SetFrame(tFrame.Normal)
	end
end

local function AdjustHandleItems(hList, nCount)
	local nItemCount = hList:GetItemCount()
	local nNeedItem = nCount - nItemCount
	
	if nNeedItem > 0 then
		for i = 1, nNeedItem, 1 do
			hList:AppendItemFromIni(INI_FILE_PATH, "Image_Dynamic")
		end
	else
		local nDelCount = -nNeedItem
		for i=1, nDelCount, 1 do
			hList:RemoveItem(nItemCount - i)
		end
	end
end

function MiddleMap.UpdateFlashData(hData)
	local nCount = hData:GetItemCount() - 1
	for i=0, nCount, 1 do
		local hFlag = hData:Lookup(i)
		if hFlag.bFlash then
			local nCurrentTime = GetCurrentTime()
			if hFlag.nFlashEndTime > nCurrentTime then
				local nAlpha = hFlag:GetAlpha() - 25
				if nAlpha < 0 then
					hFlag:SetAlpha(255)
				else
					hFlag:SetAlpha(nAlpha)
				end
			else
				hFlag.bFlash = false
				hFlag:SetAlpha(255)
				MiddleMap.nFlashCount = MiddleMap.nFlashCount - 1
			end
		end
	end
end

MiddleMap.tDynamicData={};
function MiddleMap.UpdateDynamicData(hMap)
	local dwMapID = MiddleMap.dwMapID
	local tData = MiddleMap.tDynamicData[dwMapID] or {}
	
	local hData = hMap:Lookup("Handle_DynamicData")
	local nCount = #tData
	
	AdjustHandleItems(hData, nCount)
	local tDynamicParam = Table_GetMapDynamicData()
	MiddleMap.nFlashCount = 0;
	for i=1, nCount, 1 do 
		local tMarkD = tData[i]
		local tParam = tDynamicParam[tMarkD.nType]
		local hFlag = hData:Lookup(i - 1)
		hFlag:Hide()
		if tParam then
			hFlag:Show()
			hFlag:FromUITex(tParam.szImage, tParam.nFrame)
			hFlag:SetAlpha(255)
			
			if tParam.nWidth ~= 0 then
				hFlag:SetSize(tParam.nWidth, tParam.nHeight)
			else
				hFlag:AutoSize()
			end
			
			local wI, hI = hFlag:GetSize()
			local xR, yR = MiddleMap.LPosToHPos(tMarkD.aPoint[1], tMarkD.aPoint[2], wI, hI)
			hFlag:SetRelPos(xR, yR)
			
			hFlag.nDynamicType = tMarkD.nType
			hFlag.bFlash = tMarkD.bFlash
			hFlag.nFlashEndTime = tMarkD.nFlashEnd
			
			--hFlag.x, hFlag.y = tMarkD.aPoint[1], tMarkD.aPoint[2]
			
			if hFlag.bFlash then
				MiddleMap.nFlashCount = MiddleMap.nFlashCount + 1
			end
		end
	end
	hData:FormatAllItemPos()
end

function OpenMiddleMap(dwMapID, nIndex, bTraffic, bDisableSound)
	CloseWorldMap(true)
	local frame = Station.Lookup("Topmost1/MiddleMap")
	if frame then
		frame:Show()
	else
		frame = Wnd.OpenWindow("MiddleMap")
	end
	MiddleMap.bTraffic = bTraffic
	
	MiddleMap.ShowMap(frame, dwMapID, nIndex)
	MiddleMap.UpdateTraffic(frame, bTraffic)
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
	if not GetClientPlayer().IsAchievementAcquired(1004) then
		RemoteCallToServer("OnClientAddAchievement", "Open_Middle_Map")
	end
	
	MiddleMap.nLastAlpha = MiddleMap.nAlpha 
end

function IsMiddleMapOpened()
	local frame = Station.Lookup("Topmost1/MiddleMap")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end

function CloseMiddleMap(bDisableSound)
	local frame = Station.Lookup("Topmost1/MiddleMap")
	if frame then
		frame:Hide()
	end
	CloseEditMiddleMapFlag(true)
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end
	
	if MiddleMap.nLastAlpha and MiddleMap.nAlpha ~= MiddleMap.nLastAlpha then
		FireDataAnalysisEvent("ADJUST_MIDDLE_MAP_DIAPHANEITY", {MiddleMap.nAlpha})
		MiddleMap.nLastAlpha = nil
	end
end

function MiddleMap_UpdateMapMark(nType, x, y, szName, bRemove)
	if bRemove then
		MiddleMap.dwMapMarkMapID = nil
		MiddleMap.dwMapMarkX = nil
		MiddleMap.dwMapMarkY = nil
		MiddleMap.dwMapMarkType = nil
		MiddleMap.szMapMarkName = nil
	else
		MiddleMap.dwMapMarkMapID = GetClientPlayer().GetScene().dwMapID
		MiddleMap.dwMapMarkX = x
		MiddleMap.dwMapMarkY = y
		MiddleMap.dwMapMarkType = nType
		MiddleMap.szMapMarkName = szName
	end
	
	local handle = Station.Lookup("Topmost1/MiddleMap", "Handle_Map")
	if handle then
		MiddleMap.UpdateMapMark(handle)
	end
end

function MiddleMap_AddFlagPoint(dwMapID, x, y, nType, szName)
	if dwMapID == MiddleMap.dwMapID then
		local handle = Station.Lookup("Topmost1/MiddleMap", "Handle_Map")
		if handle then
			MiddleMap.NewFlagPoint(handle, x, y, nType, szName)
			return
		end
	end
	
	MiddleMap.InitMiddleMapInfo(dwMapID)
	table.insert(MiddleMap.aFlag[dwMapID], {nType = nType, x = x, y= y, name = szName})
end

function MiddleMap_OpenQuestMap(dwQuestID)
	local dwMapID = MiddleMap.GetQuestMapID(dwQuestID)
	if dwMapID then
		MiddleMap.dwQuestID = dwQuestID
		MiddleMap.dwMapID = nil
		ClearMarkQuestTargetPlace()
		MiddleMap.bForceCheckQuest = true
		OpenMiddleMap(dwMapID, 0)
		MiddleMap.bForceCheckQuest = false
	else
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_OPEN_QUEST_MAP_ERROR)
	end
end

function OpenTrafficMiddleMap(dwTrafficID, dwNpcID)
	local hPlayer = GetClientPlayer()
	if not hPlayer then
		return
	end
	local hScene = hPlayer.GetScene()
	local dwMapID = hScene.dwMapID
	local szPath = GetMapParams(dwMapID)
	local tTrafficLineTitle = 
	{
		{f="i", t="dwTrafficID1"},
		{f="i", t="dwTrafficID2"},
		{f="i", t="dwNodeID"},
		{f="i", t="dwCityID"},
		{f="i", t="nCamp"},
	}
	local tTrafficLineFile = KG_Table.Load(szPath.."minimap\\trafficline.tab", tTrafficLineTitle, FILE_OPEN_MODE.NORMAL)
	if not tTrafficLineFile then
		Log("Load " .. szPath.."minimap\\trafficline.tab file failed" )
		return 
	end
	local tTrafficNodeTitle = 
	{
		{f="i", t="dwTrafficID"},
		{f="s", t="szName"},
		{f="i", t="nX"},
		{f="i", t="nY"},
		{f="i", t="nZ"},
		{f="i", t="nType"},
	}
	
	local tTrafficNodeFile = KG_Table.Load(szPath.."minimap\\trafficnode.tab", tTrafficNodeTitle, FILE_OPEN_MODE.NORMAL)
	
	if not tTrafficNodeFile then
		Log("Load " .. szPath.."minimap\\trafficnode.tab file failed" )
		return 
	end
	
	local nCount = tTrafficNodeFile:GetRowCount()
	local tTrafficNode = {}
	for i = 2, nCount do -- row 1 for Default 
		local tNode = tTrafficNodeFile:GetRow(i)
		tNode.bDisable = false
		if tNode.dwTrafficID ~= dwTrafficID then
			local tLine = tTrafficLineFile:Search(dwTrafficID, tNode.dwTrafficID)
			if not tLine then
				tNode.bDisable = true
			else
				if tLine.nCamp ~= CAMP.NEUTRAL and hPlayer.nCamp ~= tLine.nCamp then
					tNode.bDisable = true
				end
				tNode.dwNodeID = tLine.dwNodeID
				tNode.dwCityID = tLine.dwCityID
			end
		end
		table.insert(tTrafficNode, tNode)
	end
	
	MiddleMap.tTrafficNode = tTrafficNode
	MiddleMap.dwTrafficID = dwTrafficID
	MiddleMap.dwNpcID = dwNpcID
	OpenMiddleMap(dwMapID, 0, true)
end

do  
    RegisterScrollEvent("MiddleMap")
    
    UnRegisterScrollAllControl("MiddleMap")
        
    local szFramePath = "Topmost1/MiddleMap"
    local szWndPath = "Wnd_Quest"
    RegisterScrollControl(
        szFramePath, 
        szWndPath.."/Btn_QUp1", szWndPath.."/Btn_QDown1", 
        szWndPath.."/Scroll_QList", 
        {szWndPath, "Handle_QuestList"}
    )

    RegisterScrollControl(
        szFramePath, 
        szWndPath.."/Btn_QUp2", szWndPath.."/Btn_QDown2", 
        szWndPath.."/Scroll_QMList", 
        {szWndPath, "Handle_QuestMsg"}
    )
    szWndPath = "Wnd_Tool"
    RegisterScrollControl(
        szFramePath, 
        szWndPath.."/Btn_Up", szWndPath.."/Btn_Down", 
        szWndPath.."/Scroll_List", 
        {szWndPath, "Handle_NpcOrAreaList"}
    )
end

local function MiddleMap_OnUpdateFieldMarkSate(szEvent)
	if szEvent ~= "ON_FIELD_MARK_STATE_UPDATE" then
		return
	end
	local hPlayer = GetClientPlayer()
	if not hPlayer then
		return 
	end
	
	local dwMapID = hPlayer.GetScene().dwMapID
	
	MiddleMap.dwFieldMapID = dwMapID
	MiddleMap.tFieldMark = arg0
	if IsMiddleMapOpened() then
		local hFrame = Station.Lookup("Topmost1/MiddleMap")
		MiddleMap.UpdateFieldMarkState(hFrame, arg0)
	end
end

local function MiddleMap_OnEnterScene(szEvent)
	if szEvent ~= "PLAYER_ENTER_SCENE" then
		return
	end
	
	local hPlayer = GetClientPlayer()
	if not hPlayer or hPlayer.dwID ~= arg0 then
		return 
	end
	
	local dwMapID = hPlayer.GetScene().dwMapID
	
	if MiddleMap.dwFieldMapID and MiddleMap.dwFieldMapID ~= dwMapID then
		MiddleMap.tFieldMark = nil
	end
end

local function OnMapDynamicDataNoitfy(dwMapID, tData)
	MiddleMap.tDynamicData[dwMapID] = tData
	if IsMiddleMapOpened() and MiddleMap.dwMapID == dwMapID then
		local hFrame = Station.Lookup("Topmost1/MiddleMap")
		local hMap   = hFrame:Lookup("", "Handle_Map")
		MiddleMap.UpdateDynamicData(hMap)
	end
end

RegisterEvent("ON_FIELD_MARK_STATE_UPDATE", function(szEvent) MiddleMap_OnUpdateFieldMarkSate(szEvent) end)
RegisterEvent("PLAYER_ENTER_SCENE", function(szEvent) MiddleMap_OnEnterScene(szEvent) end)
RegisterEvent("ON_MAP_DYNAMIC_DATA_NOTIFY", function() OnMapDynamicDataNoitfy(arg0, arg1) end)
