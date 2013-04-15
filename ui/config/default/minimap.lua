local CYCLOPAEDIA_BUTTON_FRAME = 15
local tLearnCraft = {}
Minimap =
{
	dwTeammate = 1, --队友
	dwSparking = 2, --提示点
	dwDeath = 3, --死亡点
	dwQuestNpc = 4, --任务相关npc
	dwDoodad = 5, --采花点，采矿点等
	dwMapMark = 6, --问路标记
	dwFuncNpc = 7, --功能NPC
	dwRedName = 8,	--红名标记
	
	szBackgroundMusic = "",
	
	bOpen = true,
	DefaultAnchor = {s = "TOPRIGHT", r = "TOPRIGHT", x = 0, y = 0},
	Anchor = {s = "TOPRIGHT", r = "TOPRIGHT", x = 0, y = 0},
	DefaultAnchorCorner = "TOPRIGHT",
	AnchorCorner = "TOPRIGHT",
	
	bSearchRedName = false,
	bOutputBattleFieldTip = false,
	bOutputArenaTip = false,
	tNpcSearch = {},
	tSearchInfo = {},
}

RegisterCustomData("Minimap.bOpen")
RegisterCustomData("Minimap.RadarType")
RegisterCustomData("Minimap.RadarParam")
RegisterCustomData("Minimap.Anchor")
RegisterCustomData("Minimap.AnchorCorner")
RegisterCustomData("Minimap.tSearchInfo")

local MINIMAP_READNAME_ICON_FRAME = 185
local MINIMAP_IMAGE_PATH = "ui\\Image\\Minimap\\Minimap.UITex"

local RADAR_BUTTON = { "Btn_RMain", "Btn_RFlower", "Btn_RSearch", "Btn_RCopy", "Btn_RCraft"} 
local SEARCH_TYPE = 
{ 
	ALL = 1,
	NPC = 2,
	READNAME = 3,
}

local CRAFT_TYPE =    
{
    NONE = 1,
    MAIN = 2,
    FLOWER = 3,
}

local CRAFT_ID = 
{
	MAIN = 11,
	FLOWER = 10,
}

local tBattleField = {} -- tBattleField[dwMapID] = { nNotifyType, nAvgQueueTime, nPassTime, nCopyIndex }

local tRedNamePlayerList = {}
local tNpcSearchMenuData = 	-- npctype对应npctype.txt表
{
	{ bSearch = false, nType = SEARCH_TYPE.ALL, },
	{ bSearch = false, nType = SEARCH_TYPE.NPC, tNpcType = { 17 } },
	{ bSearch = false, nType = SEARCH_TYPE.NPC, tNpcType = { 15 } },
	{ bSearch = false, nType = SEARCH_TYPE.NPC, tNpcType = { 16 } },
	{ bSearch = false, nType = SEARCH_TYPE.NPC, tNpcType = { 18 } },
	{ bSearch = false, nType = SEARCH_TYPE.NPC, tNpcType = { 1, 2, 3, 4 } },
	{ bSearch = false, nType = SEARCH_TYPE.NPC, tNpcType = { 7 } },
	{ bSearch = false, nType = SEARCH_TYPE.NPC, tNpcType = { 8 } },
	{ bSearch = false, nType = SEARCH_TYPE.NPC, tNpcType = { 14 } },
	{ bSearch = false, nType = SEARCH_TYPE.NPC, tNpcType = { 13 } },
	{ bSearch = false, nType = SEARCH_TYPE.NPC, tNpcType = { 12 } },
	{ bSearch = false, nType = SEARCH_TYPE.NPC, tNpcType = { 6, 5 } },
	{ bSearch = false, nType = SEARCH_TYPE.NPC, tNpcType = { 10, 9 } },
	{ bSearch = false, nType = SEARCH_TYPE.NPC, tNpcType = { 11 } },
	{ bSearch = false, nType = SEARCH_TYPE.NPC, tNpcType = { 19, 20 } },
	{ bSearch = false, nType = SEARCH_TYPE.READNAME, },
}

local tCraftMenuData =   
{
  {nType = CRAFT_TYPE.NONE, tCraftType = {"ui/Image/button/SystemButton.UITex", 4, g_tStrings.STR_CRAFT_NONE}},  --没有进行任何一项操作时
  {nType = CRAFT_TYPE.MAIN, tCraftType = {"ui/Image/Minimap/Minimap.UITex", 76, g_tStrings.STR_CRAFT_MAIN}, dwProfessionID = 1},  --RMain 采金
  {nType = CRAFT_TYPE.FLOWER, tCraftType = {"ui/Image/Minimap/Minimap.UITex", 68, g_tStrings.STR_CRAFT_FLOWER}, dwProfessionID = 2}, --RFlower 神农
  }

function Minimap.OnFrameCreate()
	this:RegisterEvent("PLAYER_ENTER_SCENE")
	this:RegisterEvent("PLAYER_DEATH")
	this:RegisterEvent("PARTY_NOTIFY_SIGNPOST")
	this:RegisterEvent("UPDATE_NPC_MINIMAP_MARK")
	this:RegisterEvent("UPDATE_DOODAD_MINIMAP_MARK")
	this:RegisterEvent("UPDATE_REGION_INFO")
	this:RegisterEvent("UPDATE_MAP_MARK")
	this:RegisterEvent("UPDATE_MID_MAP_MARK")
	this:RegisterEvent("UPDATE_RADAR")
	this:RegisterEvent("MAIL_LIST_UPDATE")
	this:RegisterEvent("MAIL_READED")
	this:RegisterEvent("GMREPLY_SHOW")
	this:RegisterEvent("UI_SCALED")
	this:RegisterEvent("ON_ENTER_CUSTOM_UI_MODE")
	this:RegisterEvent("ON_LEAVE_CUSTOM_UI_MODE")
	this:RegisterEvent("MINIMAP_ANCHOR_CHANGED")
	this:RegisterEvent("MINIMAP_ANCHOR_CORNER_CHANGED")
	this:RegisterEvent("MINMAP_OPEN_STATUS_CHANGED")
	this:RegisterEvent("UPDATE_RELATION")
	this:RegisterEvent("LOADING_END")
	this:RegisterEvent("BATTLE_FIELD_STATE_UPDATE")
	this:RegisterEvent("BATTLE_FIELD_NOTIFY")
	this:RegisterEvent("ARENA_STATE_UPDATE")
	this:RegisterEvent("ARENA_NOTIFY")
	this:RegisterEvent("CUSTOM_DATA_LOADED")
	this:RegisterEvent("CLOSE_COURES")
	this:RegisterEvent("QUEST_ACCEPTED")
	this:RegisterEvent("PARTY_RECRUITY_STATE_UPDATE")
	this:RegisterEvent("BANK_LOCK_RESPOND")
	this:RegisterEvent("LEARN_PROFESSION")
    this:RegisterEvent("FORGET_PROFESSION")
	this:RegisterEvent("SYNC_ROLE_DATA_END")
	
	local wndM = this:Lookup("Wnd_Minimap")
	wndM:Lookup("Minimap_Map"):SetScale(2.0)
	local wndOver = wndM:Lookup("Wnd_Over")
	wndOver:Lookup("Btn_ZoomIn"):Enable(false)
	
	Minimap.UpdatePartyRecruityButton(this)
	Minimap.UpdateBattleFieldButton(this)
	Minimap.UpdateArenaButton(this);
	Minimap.UpdateMailCount(this)
	Minimap.UpdateRadarState(this)
--	Minimap.OnUpdataCurrentMap(this)
	Minimap.UpdateCalenderBtnDate(this)

	Minimap.UpdateAnchorCorner(this)
	Minimap.UpdateAnchor(this)
	UpdateCustomModeWindow(this, g_tStrings.MINI_MAP)
	
	Minimap.UpdateSearchType()
	
	local hBtnCraft = this:Lookup("Wnd_Minimap/Wnd_Over/Btn_RCraft")
	hBtnCraft:Hide()
	
end

function Minimap.UpdateAnchorCorner(frame)
	local page = frame:Lookup("Wnd_Corner")
	local pageMap = frame:Lookup("Wnd_Minimap")
	local checkbox = page:Lookup("CheckBox_Switch")
	local handle = page:Lookup("", "")
	local img = handle:Lookup("Image_Coner")
	local text = handle:Lookup("Text_Name")
	local szPath = "ui/Image/Minimap/Minimap.UITex"
	if Minimap.AnchorCorner == "TOPLEFT" then
		page:SetRelPos(0, 0)
		pageMap:SetRelPos(0, 19)
		checkbox:SetRelPos(2, 2)
		checkbox:SetAnimation(szPath, 62, 58, 65, 61, 60, 64, 59, 63, 61, 65)
		img:SetImageType(IMAGE.FLIP_HORIZONTAL)
		img:SetRelPos(0, 0)
		text:SetRelPos(0, 0)
		handle:FormatAllItemPos()
		img:SetAreaTestFile("ui/Image/TargetPanel/TriAngleDRTL.area")
	elseif Minimap.AnchorCorner == "BOTTOMLEFT" then
		page:SetRelPos(0, 172)
		pageMap:SetRelPos(0, 0)
		checkbox:SetRelPos(2, 40)
		checkbox:SetAnimation(szPath, 42, 34, 29, 37, 36, 44, 35, 43, 37, 29)
		img:SetImageType(IMAGE.FLIP_CENTRAL)
		img:SetRelPos(0, 0)
		text:SetRelPos(0, 47)
		handle:FormatAllItemPos()
		img:SetAreaTestFile("ui/Image/TargetPanel/TriAngleBL.area")
	elseif Minimap.AnchorCorner == "BOTTOMRIGHT" then
		page:SetRelPos(0, 172)
		pageMap:SetRelPos(0, 0)
		checkbox:SetRelPos(196, 36)
		checkbox:SetAnimation(szPath, 58, 62, 61, 65, 64, 60, 63, 59, 65, 61)
		img:SetImageType(IMAGE.FLIP_VERTICAL)
		img:SetRelPos(156, 0)
		text:SetRelPos(0, 47)
		handle:FormatAllItemPos()
		img:SetAreaTestFile("ui/Image/TargetPanel/TriAngleBR.area")
	else --TOPRIGHT
		page:SetRelPos(0, 0)
		pageMap:SetRelPos(0, 19)
		checkbox:SetRelPos(196, 2)
		checkbox:SetAnimation(szPath, 34, 42, 37, 29, 44, 36, 43, 35, 29, 37)
		img:SetImageType(IMAGE.NORMAL)
		img:SetRelPos(156, 0)
		text:SetRelPos(0, 0)
		handle:FormatAllItemPos()
		img:SetAreaTestFile("ui/Image/TargetPanel/TriAngleTR.area")
	end
end

function Minimap.UpdateAnchor(frame)
	frame:SetPoint(Minimap.Anchor.s, 0, 0, Minimap.Anchor.r, Minimap.Anchor.x, Minimap.Anchor.y)
	frame:CorrectPos()
end

function Minimap.OnFrameDrag()
end

function Minimap.OnFrameDragSetPosEnd()
	Minimap.AnchorCorner = GetFrameAnchorCorner(this)
	FireEvent("MINIMAP_ANCHOR_CORNER_CHANGED")
end

function Minimap.OnFrameDragEnd()
	this:CorrectPos()
	Minimap.AnchorCorner = GetFrameAnchorCorner(this)
	FireEvent("MINIMAP_ANCHOR_CORNER_CHANGED")
	Minimap.Anchor = GetFrameAnchor(this)
end

function Minimap.OnFrameBreathe()
	local hPlayer = GetClientPlayer()
	if not hPlayer then
		return
	end	
	
	local scene = hPlayer.GetScene()
	if not scene then
        return
	end
	
	local minimap = this:Lookup("Wnd_Minimap/Minimap_Map")
	
	local x, y, z = Scene_GameWorldPositionToScenePosition(hPlayer.nX, hPlayer.nY, hPlayer.nZ, 0)
	local nLayer = GetMinimapLayer(scene.dwID, x, y, z)
	minimap:UpdataSelfPos(nLayer, x, z, hPlayer.nFaceDirection)
	
	if hPlayer.IsInParty() then
		local hTeam = GetClientTeam()
		local nGroupNum = hTeam.nGroupNum
		for i = 0, nGroupNum - 1 do
			local tGroupInfo = hTeam.GetGroupInfo(i)
			if tGroupInfo and tGroupInfo.MemberList then
				for _, dwID in pairs(tGroupInfo.MemberList) do
					local tMemberInfo = hTeam.GetMemberInfo(dwID)
					if dwID ~= hPlayer.dwID and tMemberInfo.bIsOnLine and hPlayer.IsPartyMemberInSameScene(dwID) then
						x, y, z = Scene_GameWorldPositionToScenePosition(tMemberInfo.nPosX, tMemberInfo.nPosY, 0, 0)
						minimap:UpdataArrowPoint(Minimap.dwTeammate, dwID, 10, 11, x, z, 16)					
					end
				end
			end
		end
	end

	if Minimap.bSearchRedName then
		for nIndex, dwPlayerID in pairs(tRedNamePlayerList) do	-- red name playe flag
			local hPlayer = GetPlayer(dwPlayerID)
			if not hPlayer then
				table.remove(tRedNamePlayerList, nIndex)	-- leave the scene or offline
			else
				local nX, _, nZ = Scene_GameWorldPositionToScenePosition(hPlayer.nX, hPlayer.nY, hPlayer.nZ, 0)
				minimap:UpdataArrowPoint(Minimap.dwRedName, dwPlayerID, MINIMAP_READNAME_ICON_FRAME, 48, nX, nZ, 16)
			end
		end
	end
	
	local tNpcList = GetNpcList()
	for _, dwNpcID in pairs(tNpcList) do
		local hNpc = GetNpc(dwNpcID)
		assert(hNpc)
		local tNpc = g_tTable.Npc:Search(hNpc.dwTemplateID)
		local dwNpcTypeID = nil
		if tNpc then
			dwNpcTypeID = tNpc.dwTypeID
		end
		if dwNpcTypeID then
			local tNpcType = g_tTable.NpcType:Search(dwNpcTypeID)
			if tNpcType and tNpcType.dwTypeID and IsSearchTypeNpc(tNpcType.dwTypeID)
			and tNpcType.nMinimapImageFrame and tNpcType.nMinimapImageFrame > 0 then
				local nX, _, nZ = Scene_GameWorldPositionToScenePosition(hNpc.nX, hNpc.nY, hNpc.nZ, 0)
				minimap:UpdataArrowPoint(Minimap.dwFuncNpc, dwNpcID, tNpcType.nMinimapImageFrame, 48, nX, nZ, 16)
			end
		end
	end
    
	if Minimap.bDeath and hPlayer.nMoveState ~= MOVE_STATE.ON_DEATH then
		if scene.dwMapID ~= Minimap.nDeathMapID then
			minimap:RemovePoint(Minimap.dwDeath, 0)	--清除
			Minimap.bDeath = false
		else
			local x, y, z = Scene_GameWorldPositionToScenePosition(Minimap.nDeathX, Minimap.nDeathY, Minimap.nDeathZ, 0)
			local nDieLayer = GetMinimapLayer(scene.dwID, x, y, z)
			local dX = hPlayer.nX - Minimap.nDeathX
			local dY = hPlayer.nY - Minimap.nDeathY
			local nInDis = 300
			if nDieLayer == nLayer and dX > -nInDis and dX < nInDis and dY > -nInDis and dY < nInDis then
				minimap:RemovePoint(Minimap.dwDeath, 0)
				SetLastDiePos(nil, nil, nil, nil)
				Minimap.bDeath = false
			end
		end
	end
	
	if Minimap.bMapMark then
		if scene.dwMapID ~= Minimap.nMapMarkMapID then
			minimap:RemovePoint(Minimap.dwMapMark, 0)	--清除
			Minimap.bMapMark = false
		else
			local dX = hPlayer.nX - Minimap.nMapMarkX
			local dY = hPlayer.nY - Minimap.nMapMarkY
			local nInDis = 300
			if Minimap.nMapMarkZ == nLayer and dX > -nInDis and dX < nInDis and dY > -nInDis and dY < nInDis then
				minimap:RemovePoint(Minimap.dwMapMark, 0)
				MiddleMap_UpdateMapMark(0, 0, 0, nil, true)
				Minimap.bMapMark = false
			end
		end
	end
	
	if this.nRegion and not IsInLoading() then
		local argSave = arg0
			arg0 = this.nRegion
			FireEvent("UPDATE_REGION_INFO")
			this.nRegion = nil
		arg0 = argSave
	end
	
	local nEnterEndTime = GetPartyRecruitWaitEnterEndTime()
	if nEnterEndTime then
		local nLeftTime = nEnterEndTime - GetTickCount()
		if nLeftTime <= 0 then
			FireEvent("PARTY_RECRUITY_CANCEL_ENTER")
		end
	end
	
    local dwCloseMapID, nCloseTime = BattleField_GetCloseMapInfo()
    if dwCloseMapID and nCloseTime and dwCloseMapID == scene.dwMapID then
        local dwCurrentTime = GetTickCount()
        local nLeftTime = math.floor((nCloseTime - dwCurrentTime) / 1000)
        if nLeftTime >= 0 then
            OutputMessage("MSG_ANNOUNCE_RED", FormatString(g_tStrings.STR_BATTLEFIEDL_CLOSE_TIP, nLeftTime));
        else
            BattleField_SetCloseMapInfo(nil, nil)
        end
    end
    
	local tEndEnterTime = Arena_GetEnterEndTime()
    if tEndEnterTime then
		for k, v in pairs(tEndEnterTime) do
			local nSeconds = Arena_GetEnterLeftSeconds(v.nArenaEnterCount, v.dwStartTime)
			if nSeconds == 0 then
				DoLeaveArenaQueue(k)
			end
		end
    end
	
	local nTime = GetCurrentTime()
	local tToday = TimeToDate(nTime)
	if Minimap.nDay and tToday.day ~= Minimap.nDay then
		Minimap.UpdateCalenderBtnDate(this)
	end
end

function Minimap.OnEvent(event)
	if event == "UPDATE_NPC_MINIMAP_MARK" then
		local x, y, z = Scene_GameWorldPositionToScenePosition(arg1, arg2, 0, 0)
		this:Lookup("Wnd_Minimap/Minimap_Map"):UpdataStaticPoint(Minimap.dwQuestNpc, arg0, 50, x, z, 32)
	elseif event == "UPDATE_DOODAD_MINIMAP_MARK" then
		local x, y, z = Scene_GameWorldPositionToScenePosition(arg1, arg2, 0, 0) --todo根据不同的类型显示采花还是采矿
		local nFrame = 2
		if arg3 == 1 then     --采矿
			nFrame = 16
		elseif arg3 == 2 then --神农
			nFrame = 2
		elseif arg3 == 3 then --搜索
			nFrame = 46
		elseif arg3 == 9 then --抄录
			nFrame = 10
		end
		this:Lookup("Wnd_Minimap/Minimap_Map"):UpdataStaticPoint(Minimap.dwDoodad, arg0, nFrame, x, z, 32)	
	elseif event == "PLAYER_DEATH" then
		local hPlayer = GetClientPlayer()		
		local scene = hPlayer.GetScene()
		local x, y, z = Scene_GameWorldPositionToScenePosition(hPlayer.nX, hPlayer.nY, hPlayer.nZ, 0)
		this:Lookup("Wnd_Minimap/Minimap_Map"):UpdataArrowPoint(Minimap.dwDeath, 0, 45, 47, x, z) --死亡的位置
		Minimap.bDeath = true
		SetLastDiePos(scene.dwMapID, hPlayer.nX, hPlayer.nY, hPlayer.nZ)
	elseif event == "PLAYER_ENTER_SCENE" then
		local hPlayer = GetClientPlayer()
		if hPlayer and hPlayer.dwID == arg0 then
			if hPlayer.nLevel < 10 then
				this:Lookup("Wnd_Minimap/Wnd_Over/Btn_Ad"):SetAnimateGroupNormal(CYCLOPAEDIA_BUTTON_FRAME)
			end
			Minimap.OnUpdataCurrentMap(this)
			Minimap.UpdateMailCount(this)	
			Minimap.UpdateBattleFieldButton(this)	
			Minimap.UpdateArenaButton(this)
		else
			Minimap.UpdateRedNamePlayerList(arg0)
		end
	elseif event == "PARTY_NOTIFY_SIGNPOST" then
		Minimap.nPartySignPostX, Minimap.nPartySignPostY = arg0, arg1
		Minimap.nPartySignPostTime = GetTickCount()
		local x, y, z = Scene_GameWorldPositionToScenePosition(arg0, arg1, 0, 0)
		this:Lookup("Wnd_Minimap/Minimap_Map"):UpdataAnimatePoint(Minimap.dwSparking, 0, 69, x, z, 80)
		PlaySound(SOUND.UI_SOUND,g_sound.MapHit)
	elseif event == "UPDATE_REGION_INFO" then
		if IsInLoading() then
			this.nRegion = arg0
			return
		end
		this.nRegion = nil
		local dwMapID = GetClientPlayer().GetScene().dwMapID
		local szName = MiddleMap.GetMapAreaName(dwMapID, arg0)
		if szName then
			this:Lookup("Wnd_Corner", "Text_Name"):SetText(szName)
			local argS = arg0
			arg0 = szName
			FireEvent("PLAYER_ENTER_AREA")
			arg0 = argS
		end
		local szMusic = MiddleMap.GetMapAreaBgMusic(dwMapID, arg0)
		if szMusic and szMusic ~= "" then
			PlayBgMusic(szMusic)
		else
			StopBgMusic()
		end		
	elseif event == "UPDATE_MAP_MARK" then
		local hPlayer = GetClientPlayer()
		local scene = hPlayer.GetScene()
		
		local x, y, z = Scene_GameWorldPositionToScenePosition(arg0, arg1, arg2, 0)
		this:Lookup("Wnd_Minimap/Minimap_Map"):UpdataArrowPoint(Minimap.dwMapMark, 0, 1, 48, x, z) --问路标记点
		Minimap.bMapMark = true
		Minimap.nMapMarkX, Minimap.nMapMarkY, Minimap.nMapMarkZ, Minimap.szMapMarkName = arg0, arg1, GetMinimapLayer(scene.dwID, x, y, z), arg4
		Minimap.nMapMarkMapID = scene.dwMapID
		MiddleMap_UpdateMapMark(arg3, arg0, arg1, arg4)
	elseif event == "UPDATE_MID_MAP_MARK" then
		MiddleMap_AddFlagPoint(arg0, arg1, arg2, arg3, arg4)
	elseif event == "UPDATE_RADAR" then
		Minimap.RadarType, Minimap.RadarParam = arg0, arg1
		Minimap.UpdateRadarState(this)
	elseif event == "MAIL_LIST_UPDATE" or event == "MAIL_READED" then
		Minimap.UpdateMailCount(this)
	elseif event == "GMREPLY_SHOW" then
		local hGMMsgBtn = this:Lookup("Wnd_Minimap/Wnd_Over/Btn_GMMsg")
		Minimap.UpdateGMMsgState(hGMMsgBtn, arg0)
	elseif event == "UI_SCALED" then
		Minimap.UpdateAnchor(this)
	elseif event == "ON_ENTER_CUSTOM_UI_MODE" or event == "ON_LEAVE_CUSTOM_UI_MODE" then
		UpdateCustomModeWindow(this)
	elseif event == "MINIMAP_ANCHOR_CHANGED" then
		Minimap.UpdateAnchor(this)
	elseif event == "MINIMAP_ANCHOR_CORNER_CHANGED" then
		Minimap.UpdateAnchorCorner(this)
	elseif event == "MINMAP_OPEN_STATUS_CHANGED" then
		this.bDisableSound = true
		this:Lookup("Wnd_Corner/CheckBox_Switch"):Check(not Minimap.bOpen)
		this.bDisableSound = false
	elseif event == "UPDATE_RELATION" then
		Minimap.UpdateRedNamePlayerList(arg0)
	elseif event == "LOADING_END" then
		GetMailClient().ApplyMailList()
		if Minimap.RadarType and Minimap.RadarParam then
			GetClientPlayer().SetMinimapRadar(Minimap.RadarType, Minimap.RadarParam)
		end
		Minimap.UpdateLock(this)
	elseif event == "BATTLE_FIELD_STATE_UPDATE" then
		Minimap.UpdateBattleFieldButton(this)
	elseif event == "BATTLE_FIELD_NOTIFY" then
		if Minimap.bOutputBattleFieldTip then
			Minimap.OutputBattleFieldTip(this)
		end
	elseif event == "ARENA_STATE_UPDATE" then
		Minimap.UpdateArenaButton(this)
	elseif event == "ARENA_NOTIFY" then
		if Minimap.bOutputArenaTip then
			Minimap.OutputArenaTip(this)
		end
	elseif event == "CUSTOM_DATA_LOADED" then
		UpdateCustomModeWindow(this)
		Minimap.UpdateAnchor(this)
		Minimap.UpdateAnchorCorner(this)
		this.bDisableSound = true
		this:Lookup("Wnd_Corner/CheckBox_Switch"):Check(not Minimap.bOpen)
		this.bDisableSound = false
	elseif event == "CLOSE_COURES" then
		local hBtn = this:Lookup("Wnd_Minimap/Wnd_Over/Btn_Ad")
		if hBtn then
			FireHelpEvent("OnClosePanel", "COURES", hBtn)
		end
	elseif event == "QUEST_ACCEPTED" then
		local hBtn = this:Lookup("Wnd_Minimap/Wnd_Over/Btn_BigMap")
		FireHelpEvent("OnCommentToOpenMiddlemap", arg1, hBtn)
	elseif event == "PARTY_RECRUITY_STATE_UPDATE" then
		Minimap.UpdatePartyRecruityButton(this:GetRoot())
		if Minimap.bOutputPartyRecruityTip then
			Minimap.OutputPartyRecruityTip(this:GetRoot())
		end
	elseif event == "BANK_LOCK_RESPOND" then
		Minimap.UpdateLock(this)
	elseif event == "SYNC_ROLE_DATA_END" then  
		Minimap.UpdateLearnCraft(this)
	elseif event == "LEARN_PROFESSION" then 
	    Minimap.UpdateLearnCraft(this, arg0)
	elseif event == "FORGET_PROFESSION" then
		Minimap.RemoveCraft(this, arg0)
	end
end

function Minimap.RemoveCraft(hFrame, dwProfessionID)
	local hBtnCraft   =  hFrame:Lookup("Wnd_Minimap/Wnd_Over/Btn_RCraft")
	local hBtnMain    =  hFrame:Lookup("Wnd_Minimap/Wnd_Over/Btn_RMain")
	local hBtnFlower  =  hFrame:Lookup("Wnd_Minimap/Wnd_Over/Btn_RFlower")
	
	local hPlayer = GetClientPlayer()
	if not hPlayer then
		return
	end
	
	local dwFlowerProfessionID =  tCraftMenuData[CRAFT_TYPE.FLOWER].dwProfessionID
	local dwMainProfessionID   =  tCraftMenuData[CRAFT_TYPE.MAIN].dwProfessionID
	
	if dwProfessionID then
		tLearnCraft[dwProfessionID] = false 
			
		if dwProfessionID == dwMainProfessionID    then
		    hBtnMain:Hide()
		    if tLearnCraft[dwFlowerProfessionID] then
		        hBtnFlower:Show()
				hPlayer.SetMinimapRadar(MINI_RADAR_TYPE.FIND_CRAFT_DOODAD, dwFlowerProfessionID)
			else 
				hBtnCraft:Hide() 
				hPlayer.SetMinimapRadar(MINI_RADAR_TYPE.NO_RADAR, 0)
			end
		elseif dwProfessionID == dwFlowerProfessionID then
			hBtnFlower:Hide()
		    if tLearnCraft[dwMainProfessionID] then
			    hBtnMain:Show() 
				hPlayer.SetMinimapRadar(MINI_RADAR_TYPE.FIND_CRAFT_DOODAD, dwMainProfessionID)
		    else                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              
			    hBtnCraft:Hide() 
				hPlayer.SetMinimapRadar(MINI_RADAR_TYPE.NO_RADAR, 0)
			end
		end
   end
end

local function GetCraftInfo(dwProfessionID, dwCraftID)
	local tCraft
	if not dwCraftID then
		tCraft = g_tTable.Craft:Search(dwProfessionID)
    else
		tCraft = g_tTable.Craft:Search(dwProfessionID, dwCraftID)
    end
    
	if tCraft then
		return tCraft
	end	
end

function Minimap.UpdateLearnCraft(hFrame, dwProfessionID)
	local hPlayer = GetClientPlayer()
	if not hPlayer then
		return
	end
	
	local hBtnCraft   =  hFrame:Lookup("Wnd_Minimap/Wnd_Over/Btn_RCraft")
	local hBtnMain    =  hFrame:Lookup("Wnd_Minimap/Wnd_Over/Btn_RMain")
	local hBtnFlower  =  hFrame:Lookup("Wnd_Minimap/Wnd_Over/Btn_RFlower")
	
	local ProTab = hPlayer.GetProfession()
	for key, val in pairs(ProTab) do		
		local nProID = val.ProfessionID
		local tCraftTab = GetCraftInfo(nProID)
		if tCraftTab then
			local tCraft = GetCraft(tCraftTab.dwCraftID)
			tLearnCraft[tCraft.ProfessionID] = true 
	    end
	end
	
	if dwProfessionID == tCraftMenuData[CRAFT_TYPE.MAIN].dwProfessionID then
		hBtnMain:Show()
		hBtnFlower:Hide()
		hBtnCraft:Hide()
		hPlayer.SetMinimapRadar(MINI_RADAR_TYPE.FIND_CRAFT_DOODAD, dwProfessionID)
		
	elseif dwProfessionID == tCraftMenuData[CRAFT_TYPE.FLOWER].dwProfessionID then
		hBtnFlower:Show()
		hBtnCraft:Hide()
		hBtnMain:Hide()
		hPlayer.SetMinimapRadar(MINI_RADAR_TYPE.FIND_CRAFT_DOODAD, dwProfessionID)
	end	
end

function Minimap.UpdateLock(frame)
	local hLock = this:Lookup("Wnd_Minimap/Wnd_Over/Btn_Lock")
	local hUnLock = this:Lookup("Wnd_Minimap/Wnd_Over/Btn_UnLock")
	Lock_UpdateState(hLock, hUnLock)
end

function Minimap.UpdatePartyRecruityButton(hFrame)
	local hBtnFT = hFrame:Lookup("Wnd_Minimap/Wnd_Over/Btn_FindTeam")
	local szState = GetPartyRecruitState()
	
	hBtnFT:Hide()
	if szState == "InFTDungeon" or szState == "InQueue" or szState == "CanEnter" or szState == "DungeonEnd" then
		hBtnFT:Show()
	end
end

function Minimap.OutputPartyRecruityTip(hFrame)
	local hBtnFT = hFrame:Lookup("Wnd_Minimap/Wnd_Over/Btn_FindTeam")
	local szTip = GetPartyRecruitTip()
	if szTip and #szTip > 0 then
		local nX, nY = hBtnFT:GetAbsPos()
		local nWidth, nHeight = hBtnFT:GetSize()
		OutputTip(szTip, 300, {nX, nY, nWidth, nHeight})	
	end
end

function Minimap.UpdateBattleFieldButton(hFrame)
	local hBtnBattleBlacklist = hFrame:Lookup("Wnd_Minimap/Wnd_Over/Btn_BattleFieldForbid")
	local hBtnBattleField = hFrame:Lookup("Wnd_Minimap/Wnd_Over/Btn_BattleField")
	local szInfo = HasBattleFieldInfo()
	if szInfo == "disable" then
		hBtnBattleField:Hide()
		hBtnBattleBlacklist:Show()
	elseif szInfo == "normal" then
		hBtnBattleField:Show()
		hBtnBattleBlacklist:Hide()
	else
		hBtnBattleField:Hide()
		hBtnBattleBlacklist:Hide()
	end
end

function Minimap.UpdateArenaButton(hFrame)
	local hBtnArenaBlacklist = hFrame:Lookup("Wnd_Minimap/Wnd_Over/Btn_ArenaForbid")
	local hBtnArena = hFrame:Lookup("Wnd_Minimap/Wnd_Over/Btn_Arena")
	local szInfo = HasArenaInfo()
	if szInfo == "disable" then
		hBtnArena:Hide()
		hBtnArenaBlacklist:Show()
	elseif szInfo == "normal" then
		hBtnArena:Show()
		hBtnArenaBlacklist:Hide()
	else
		hBtnArena:Hide()
		hBtnArenaBlacklist:Hide()
	end
end

function Minimap.UpdateRedNamePlayerList(dwID)
	if not IsPlayer(dwID) or GetClientPlayer().dwID == dwID then
		return
	end
		
	for nIndex, dwPlayerID in pairs(tRedNamePlayerList) do 
		if dwPlayerID == dwID then
			table.remove(tRedNamePlayerList, nIndex)
			break
		end
	end
	
	local hPlayer = GetPlayer(dwID)
	if hPlayer and hPlayer.bRedName then
		table.insert(tRedNamePlayerList, dwID)
	end
end

function Minimap.UpdateRadarState(hFrame)
    local hOver = hFrame:Lookup("Wnd_Minimap/Wnd_Over")
	local hBtnCraft = hOver:Lookup("Btn_RCraft")
	
	local dwFlowerProfessionID =  tCraftMenuData[CRAFT_TYPE.FLOWER].dwProfessionID
	local dwMainProfessionID   =  tCraftMenuData[CRAFT_TYPE.MAIN].dwProfessionID
   
	local nCurRadarBtnIndex = nil
	if Minimap.RadarType and Minimap.RadarParam then 
		if Minimap.RadarParam == 1 then	    --采矿
			nCurRadarBtnIndex = 1
		elseif Minimap.RadarParam == 2 then --神农
			nCurRadarBtnIndex = 2
		elseif Minimap.RadarParam == 3 then --搜索
			nCurRadarBtnIndex = 3
		elseif Minimap.RadarParam == 9 then --抄录
			nCurRadarBtnIndex = 4
		elseif Minimap.RadarParam == 0 and 
			(tLearnCraft[dwFlowerProfessionID] or tLearnCraft[dwMainProfessionID])
		then
			nCurRadarBtnIndex = 5
		end
	end
		
	for nIndex, szBtn in ipairs(RADAR_BUTTON) do
		if nCurRadarBtnIndex and nCurRadarBtnIndex == nIndex then
			if nCurRadarBtnIndex == 5 then
				hBtnCraft:Show()  
			else
				hOver:Lookup(szBtn):Show()
				hBtnCraft:Hide() 
			end
		else
			hOver:Lookup(szBtn):Hide()
		end
	end
end

function Minimap.UpdateCalenderBtnDate(hWnd)
	local hBtn = hWnd:Lookup("Wnd_Minimap/Wnd_Over/Btn_Calender")
	local nTime = GetCurrentTime()
	local tToday = TimeToDate(nTime)
	hBtn:Lookup("", "Text_Calender"):SetText(tToday.day)
	Minimap.nDay = tToday.day
end

function Minimap.OnMouseEnter()
	local szName = this:GetName()
	if szName == "Btn_Mail" then
		local nUnread, nTotal, nSysUnRead, nsysTotal = GetMailClient().CountMail()
		local szText
		if nSysUnRead == 0 then
			szText = FormatString(g_tStrings.MINIMAP_MAIL_TIP1, nTotal, nUnread)
		else
			szText = FormatString(g_tStrings.MINIMAP_MAIL_TIP2, nTotal, nUnread, nSysUnRead)
		end
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
		OutputTip(GetFormatText(szText, 162), 200, {x, y, w, h})
	elseif szName == "Btn_RMain" or szName == "Btn_RFlower" or szName == "Btn_RCraft" or szName == "Btn_RSearch" or szName == "Btn_RCopy" then
		Minimap.OutputRadarTip(this)
	elseif szName == "Btn_BattleField" or szName == "Btn_BattleFieldForbid" then
		Minimap.bOutputBattleFieldTip = true
		Minimap.OutputBattleFieldTip(this:GetRoot())
	elseif szName == "Btn_Arena" or szName == "Btn_ArenaForbid" then
		Minimap.bOutputArenaTip = true
		Minimap.OutputArenaTip(this:GetRoot())	
		
	elseif szName == "Btn_FindTeam" then
		Minimap.bOutputPartyRecruityTip = true
		Minimap.OutputPartyRecruityTip(this:GetRoot())
	elseif szName == "Btn_Lock" then
		local szTip = Lock_GetTip()
		if szTip and szTip ~= nil then
			local x, y = this:GetAbsPos()
			local w, h = this:GetSize()
			OutputTip(szTip, 200, {x, y, w, h})
		end
	end
end

function Minimap.OutputBattleFieldTip(hFrame)
	local hBtnBattleField = hFrame:Lookup("Wnd_Minimap/Wnd_Over/Btn_BattleField")
	local szTip = GetBattleFieldStateTip()
	if szTip and #szTip > 0 then
		local nX, nY = hBtnBattleField:GetAbsPos()
		local nWidth, nHeight = hBtnBattleField:GetSize()
		OutputTip(szTip, 300, {nX, nY, nWidth, nHeight})	
	end
end

function Minimap.OutputArenaTip(hFrame)
	local hBtnArena = hFrame:Lookup("Wnd_Minimap/Wnd_Over/Btn_Arena")
	local szTip = GetArenaStateTip()
	if szTip and #szTip > 0 then
		local nX, nY = hBtnArena:GetAbsPos()
		local nWidth, nHeight = hBtnArena:GetSize()
		OutputTip(szTip, 400, {nX, nY, nWidth, nHeight})	
	end
end

function Minimap.OnMouseLeave()
	HideTip()
	Minimap.bOutputBattleFieldTip = false
	Minimap.bOutputPartyRecruityTip = false
	Minimap.bOutputArenaTip = false;
end

function Minimap.OutputRadarTip(btn)
	local szName = btn:GetName()
	
	szText = GetFormatText(g_tStrings.MINIMAP_RADA, 80)
	if szName == "Btn_RCraft" then
	    szText = szText..GetFormatText(g_tStrings.MINIMAP_RADA_CRAFT, 80)
	elseif szName == "Btn_RMain" then
		szText = szText..GetFormatText(g_tStrings.MINIMAP_RADA_MAIN, 80)
	elseif szName == "Btn_RFlower" then
	    szText = szText..GetFormatText(g_tStrings.MINIMAP_RADA_FLOWER, 80)
	elseif szName == "Btn_RSearch" then
	    szText = szText..GetFormatText(g_tStrings.MINIMAP_RADA_SEARCH, 80)
	elseif szName == "Btn_RCopy" then
	    szText = szText..GetFormatText(g_tStrings.MINIMAP_RADA_COPY, 80)
	end
	local x, y = btn:GetAbsPos()
	local w, h = btn:GetSize()	
	OutputTip(szText, 200, {x, y, w, h})
end

function Minimap.UpdateMailCount(frame)
	local nUnread, nTotal, nSysUnRead, nsysTotal = GetMailClient().CountMail()
	local btn = frame:Lookup("Wnd_Minimap/Wnd_Over/Btn_Mail")
	if nUnread and nUnread > 0 then
		btn:Show()
		FireHelpEvent("OnAcceptMail", btn)
	else
		btn:Hide()
	end
end

function Minimap.OnRButtonClick()
	local szName = this:GetName()
	if szName == "Btn_RSearch" or szName == "Btn_RCopy" then --右键点击关闭功能
		GetClientPlayer().SetMinimapRadar(MINI_RADAR_TYPE.NO_RADAR, 0)
	elseif szName == "Btn_BattleField" then
		local tMenu = GetBattleFieldMenu()
		if tMenu then
			PopupMenu(tMenu)
		end
	elseif szName == "Btn_Arena" then
		local tMenu = GetArenaMenu()
		if tMenu then
			PopupMenu(tMenu)
		end
	elseif szName == "Btn_Dungeon" then
		Minimap.PopupDungeonMenu()
	elseif szName == "Btn_FindTeam" then
		local tMenu = GetPartyRecruitMenu()
		if tMenu then
			PopupMenu(tMenu)
		end
	end
end

function Minimap.OnUpdataCurrentMap(frame)
	local hPlayer = GetClientPlayer()
	if not hPlayer then
		return
	end	
	local scene = hPlayer.GetScene()
	if not scene then
        return
	end
	
	local szName = Table_GetMapName(scene.dwMapID)
	local szPath = GetMapParams(scene.dwMapID)
	if not szPath then
		Trace("UI Minimap GetMapParams failed\n")
		return
	end
	
	frame:Lookup("Wnd_Minimap/Minimap_Map"):SetMapPath(szPath)
	local textF = frame:Lookup("Wnd_Minimap/Wnd_Over", "Text_Fresher")
	if scene.dwMapID == 1 then
		local nNum = scene.nCopyIndex
		textF:SetText(FormatString(g_tStrings.MINIMAP_WHAT_DAOXIANGCUN,NumberToChinese(nNum)))
	else
		textF:SetText("")
	end
	frame:Lookup("Wnd_Corner", "Text_Name"):SetText(szName)
	
	if Minimap.nDeathMapID and Minimap.nDeathX and Minimap.nDeathY and Minimap.nDeathZ and Minimap.nDeathMapID == scene.dwMapID then
		local x, y, z = Scene_GameWorldPositionToScenePosition(Minimap.nDeathX, Minimap.nDeathY, Minimap.nDeathZ, 0)
		this:Lookup("Wnd_Minimap/Minimap_Map"):UpdataArrowPoint(Minimap.dwDeath, 0, 45, 47, x, z) --死亡的位置
		Minimap.bDeath = true		
	end
end

function Minimap.OnMinimapMouseEnterObj()
	local dwType, dwID = this:GetOverObj()
	local x, y = Cursor.GetPos()
	local rect = {x, y, 20, 20}
	if dwType == Minimap.dwTeammate then
		local szName = GetTeammateName(dwID)
		if szName then
			local r, g, b = GetPartyMemberFontColor()
			local szTip = "<text>text="..EncodeComponentsString(szName.."\n").."font=80 r="..r.." g="..g.." b="..b.."</text>"
			OutputTip(szTip, 200, rect)
		end
	elseif dwType == Minimap.dwSparking then
		local szTip = "<text>text="..EncodeComponentsString(g_tStrings.MAP_SUMMON_PLACE).."</text>"
		OutputTip(szTip, 200, rect)
	elseif dwType == Minimap.dwDeath then
		local szTip = "<text>text="..EncodeComponentsString(g_tStrings.MAP_DEATH_PLACE).."</text>"
		OutputTip(szTip, 200, rect)
	elseif dwType == Minimap.dwQuestNpc then
		local npc = GetNpc(dwID)
		if npc then
			local r, g, b = GetForceFontColor(npc.dwID, GetClientPlayer().dwID)
			local szTip = "<text>text="..EncodeComponentsString(npc.szName.."\n").."font=80 r="..r.." g="..g.." b="..b.."</text>"
			OutputTip(szTip, 200, rect)			
		end
	elseif dwType == Minimap.dwDoodad then
		local doodad = GetDoodad(dwID)
		if doodad then
			local szName = Table_GetDoodadName(doodad.dwTemplateID, doodad.dwNpcTemplateID)
			local szTip = "<text>text="..EncodeComponentsString(szName.."\n").."font=37</text>"
			OutputTip(szTip, 200, rect)
		end
	elseif dwType == Minimap.dwMapMark then
		local szText = g_tStrings.MINIMAP_MARK
		if Minimap.szMapMarkName then
			szText = Minimap.szMapMarkName
		end
		local szTip = "<text>text="..EncodeComponentsString(szText).."</text>"
		OutputTip(szTip, 200, rect)
	elseif dwType == Minimap.dwFuncNpc then
		OutputNpcTip(dwID, rect)
	elseif dwType == Minimap.dwRedName then
		OutputPlayerTip(dwID, rect)
	end
end

function Minimap.OnMinimapMouseLeaveObj()
	HideTip()
end

function Minimap.OnMinimapMouseEnterSelf()
end

function Minimap.OnMinimapMouseLeaveSelf()
end

function Minimap.OnMinimapSendInfo(fX, fY)
	local fX, fY = this:GetSendPos()
	local x, y, z = Scene_ScenePositionToGameWorldPosition(fX, 0, fY)
	GetClientTeam().TeamNotifySignpost(x, y)
	
	local argS0, argS1 = arg0, arg1
	arg0, arg1 = x, y
	FireEvent("PARTY_NOTIFY_SIGNPOST")
	arg0, arg1 = argS0, argS1
	
	FireDataAnalysisEvent("FIRST_USE_MINIMAP_RADAR")
end

function Minimap.OnLButtonDown()
	local szName = this:GetName()
	if szName == "Btn_ZoomIn" or szName == "Btn_ZoomOut" then
		Minimap.OnLButtonHold()
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
	end
end

function Minimap.OnLButtonHold()
	local szSelfName = this:GetName()
	if szSelfName == "Btn_ZoomIn" then
		local mp = this:GetParent():GetParent():Lookup("Minimap_Map")
		local scale = mp:GetScale()
		scale = scale * 1.1
		if scale >= 2.0 then
			scale = 2.0
			this:Enable(0)
		end
		this:GetParent():Lookup("Btn_ZoomOut"):Enable(1)
		mp:SetScale(scale)
	elseif szSelfName == "Btn_ZoomOut" then
		local mp = this:GetParent():GetParent():Lookup("Minimap_Map")
		local scale = mp:GetScale()
		scale = scale * 0.9
		if scale <= 0.5 then
			scale = 0.5
			this:Enable(0)
		end
		this:GetParent():Lookup("Btn_ZoomIn"):Enable(1)
		mp:SetScale(scale)
    end
end

function Minimap.OnCheckBoxCheck()
	if this:GetName() == "CheckBox_Switch" then
		local frame = this:GetRoot()
		if not frame.bDisableSound then
			PlaySound(SOUND.UI_SOUND, g_sound.Button)
		end
		frame:Lookup("Wnd_Minimap"):Hide()
		Minimap.bOpen = false
	end
end

function Minimap.OnCheckBoxUncheck()
	if this:GetName() == "CheckBox_Switch" then
		local frame = this:GetRoot()
		if not frame.bDisableSound then
			PlaySound(SOUND.UI_SOUND, g_sound.Button)
		end
		frame:Lookup("Wnd_Minimap"):Show()
		Minimap.bOpen = true
	end
end

local bFristClickFarmBTN = true
function Minimap.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_BigMap" then
		if IsMiddleMapOpened() then
			CloseMiddleMap()
		else
			OpenMiddleMap()
		end
	elseif szName == "Btn_Ad" then
		this:SetAnimateGroupNormal(CYCLOPAEDIA_BUTTON_FRAME)
		if IsCyclopaediaOpened() then
			CloseCyclopaedia()
		else
			OpenCyclopaedia()
		end
	elseif szName == "Btn_GMMsg" then
		if this.bHaveMsg then
			FireEvent("GMAPPEAL_SHOW")
		else
			OpenGMPanel("Bug")
			FireEvent("GMAPPEAL_SHOW")
		end
		Minimap.UpdateGMMsgState(this, false)
	elseif szName == "Btn_NpcSearch" then
		Minimap.PopupSearchMenu()
	elseif szName == "Btn_BattleField" then
		if IsInBattleField() then
			SwitchBattleFieldPanel()
		end
		
	elseif szName == "Btn_Arena" then
		if IsInArena() and IsArenaFinished() then
			SwitchArenaFinalPanel()
		end
	elseif szName == "Btn_Dungeon" then
		if IsDungeonInfoPanelOpened() then
			CloseDungeonInfoPanel()
		else
			OpenDungeonInfoPanel()
		end
	elseif szName == "Btn_Newspaper" then
		OpenJX3Daily()
	elseif szName == "Btn_FindTeam" then
		local szState = GetPartyRecruitState()
		if szState == "DungeonEnd" or szState == "InFTDungeon" then
			if IsTwoDungeonRewardOpened() then
				CloseTwoDungeonReward()
			else
				OpenTwoDungeonReward()
			end
		end
	elseif szName == "Btn_Farm" and FarmPanel then
		if FarmPanel.frameSelf and FarmPanel.frameSelf:IsVisible() then
			FarmPanel.ClosePanel()
		else
			if bFristClickFarmBTN then
				FarmPanel.RandomTongListRequest(10)	
				bFristClickFarmBTN = nil
			end
			FarmPanel.OpenPanel()
		end
	elseif szName == "Btn_Achievement" then
		if IsAchievementPanelOpened() then
			CloseAchievementPanel()
		else
			OpenAchievementPanel()
		end
	elseif szName == "Btn_Research"	then
		local _,_, szVersionLineName, szVersionEx = GetVersion()
		if szVersionEx ~= "snda" and szVersionLineName ~= "zhintl" then
			OpenInternetExplorer(tUrl.Questionnaire..MD5(GetUserAccount()))
		end
	elseif szName == "Btn_Calender"	then
		
		if IsActivePopularizeOpened() then 
			CloseActivePopularize()
		else
			OpenActivePopularize()
		end
	elseif szName == "Btn_PayPath" then
		if IsPayPathPanelOpened() then
			ClosePayPathPanel()
		else
			OpenPayPathPanel()
		end
    elseif szName == "Btn_Rank" then
        if IsAchievementRankingOpened() then
            CloseAchievementRanking()
        else
            OpenAchievementRanking()
         end
 	elseif szName == "Btn_Lock" then
		Lock_Click()
	elseif szName == "Btn_UnLock" then
		UnLock_Click()
	elseif szName == "Btn_RCraft" or szName == "Btn_RMain" or szName == "Btn_RFlower" then
		Minimap.PopupCraftMenu() 
	end
end

function Minimap.PopupDungeonMenu()
	local hPlayer = GetClientPlayer()
	local bCanReset = false
	if not hPlayer.IsInParty() or hPlayer.IsPartyLeader() then
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
			{szOption = g_tStrings.STR_DUNGEON_NORMAL_MODE, bMCheck = true, bChecked = (hPlayer.bHeroFlag == false), fnAction = function() hPlayer.bHeroFlag = false end, fnAutoClose = function() return true end},
			{szOption = g_tStrings.STR_DUNGEON_HARD_MODE, bDisable = (hPlayer.nLevel < 70), bMCheck = true, bChecked = hPlayer.bHeroFlag, fnAction = function() hPlayer.bHeroFlag = true end, fnAutoClose = function() return true end},
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

function Minimap.PopupSearchMenu()
	local tMenu = {}
	for nIndex, tData in ipairs(tNpcSearchMenuData) do
		local tMenuItem = 
		{ 
			szOption = g_tStrings.tNpcSearchMenu[nIndex], 
			bCheck = true, 
			bChecked = tData.bSearch, 
			fnAction = function() Minimap.OnSelectSearchType(nIndex) end,
			fnAutoClose = function() return true end,
		}
		
		if tData.nType == SEARCH_TYPE.NPC and tData.tNpcType and tData.tNpcType[1] then
			local tNpcType = g_tTable.NpcType:Search(tData.tNpcType[1])
			assert(tNpcType)
			if tNpcType.nMinimapImageFrame and tNpcType.nMinimapImageFrame >= 0 then
				tMenuItem.szIcon = MINIMAP_IMAGE_PATH
				tMenuItem.nFrame = tNpcType.nMinimapImageFrame
				tMenuItem.szLayer = "ICON_RIGHT"
			end
		elseif tData.nType == SEARCH_TYPE.READNAME then
			tMenuItem.szIcon = MINIMAP_IMAGE_PATH
			tMenuItem.nFrame = MINIMAP_READNAME_ICON_FRAME
			tMenuItem.szLayer = "ICON_RIGHT"
		end
		table.insert(tMenu, tMenuItem)
	end
	PopupMenu(tMenu)
end

function Minimap.PopupCraftMenu()
	local tMenu = {}
	local nNum = 0
	local hFrame = Station.Lookup("Topmost/Minimap")
	local hBtnCraft = hFrame:Lookup("Wnd_Minimap/Wnd_Over/Btn_RCraft")
	
	for nIndex, tData in ipairs(tCraftMenuData) do 
		local tMenuItem =
		{
			szOption = tData.tCraftType[3],
			bCheck = true,
			bChecked = false,
			fnAction = function() Minimap.OnSelectCraftType(nIndex) end,
			fnAutoClose = function() return true end,
		}
		if (Minimap.RadarParam == 1 and nIndex == 2) or 
		(Minimap.RadarParam == 2 and nIndex == 3) or 
		(Minimap.RadarParam == 0 and nIndex == 1) 
		then
			tMenuItem.bChecked = true
		end
		
		tMenuItem.szIcon = tData.tCraftType[1]
		tMenuItem.nFrame = tData.tCraftType[2]
		tMenuItem.szLayer = "ICON_RIGHT"
		
		if tLearnCraft[tData.dwProfessionID] then
			table.insert(tMenu, tMenuItem)
			nNum = nNum + 1
		elseif tData.nType == CRAFT_TYPE.NONE then
			table.insert(tMenu, tMenuItem) 
		end
	end
	
	if nNum == 0 then
		hBtnCraft:Hide()
	else
		PopupMenu(tMenu)
	end
end

function Minimap.OnSelectSearchType(nIndex)
	FireDataAnalysisEvent("FIRST_USE_MINIMAP_GUIDE")
	assert(nIndex > 0 and nIndex <= #tNpcSearchMenuData)
	if tNpcSearchMenuData[nIndex].nType == SEARCH_TYPE.ALL then
		local bSearch = not tNpcSearchMenuData[nIndex].bSearch
		for _, tData in ipairs(tNpcSearchMenuData) do
			tData.bSearch = bSearch
		end
	else
		tNpcSearchMenuData[nIndex].bSearch = not tNpcSearchMenuData[nIndex].bSearch
		
		local tAllSearchMenu = nil
		local bAllSearch = true
		for _, tData in ipairs(tNpcSearchMenuData) do
			if tData.nType == SEARCH_TYPE.ALL then
				tAllSearchMenu = tData
			else
				bAllSearch = bAllSearch and tData.bSearch
			end
		end
		tAllSearchMenu.bSearch = bAllSearch
	end
	
	Minimap.UpdateSearchType()
	GetPopupMenu():Hide()
end


function Minimap.OnSelectCraftType(nIndex)  
	FireDataAnalysisEvent("FIRST_USE_MINIMAP_GUIDE")
    assert(nIndex > 0 and nIndex <= #tCraftMenuData)
	Minimap.UpdateCraftSearchType(nIndex)  
	GetPopupMenu():Hide()
end

function Minimap.UpdateSearchType()
	Minimap.tNpcSearch = {}
	Minimap.tSearchInfo = {}
	for i, tData in ipairs(tNpcSearchMenuData) do
		if tData.nType == SEARCH_TYPE.NPC then
			if tData.bSearch then
				for _, nNpcType in pairs(tData.tNpcType) do
					Minimap.tNpcSearch[nNpcType] = true
				end
				table.insert(Minimap.tSearchInfo, i)
			end
		elseif tData.nType == SEARCH_TYPE.READNAME then
			Minimap.bSearchRedName = tData.bSearch
		end
	end
	UpdateAllNpcTitleEffect()
end

function Minimap.UpdateCraftSearchType(nIndex)  
	local hPlayer = GetClientPlayer()
	if not hPlayer then
		return
	end
	
	local hFrame      =  Station.Lookup("Topmost/Minimap")
	local hBtnCraft   =  hFrame:Lookup("Wnd_Minimap/Wnd_Over/Btn_RCraft")
	local hBtnMain    =  hFrame:Lookup("Wnd_Minimap/Wnd_Over/Btn_RMain") 
	local hBtnFlower  =  hFrame:Lookup("Wnd_Minimap/Wnd_Over/Btn_RFlower") 
	
	if tCraftMenuData[nIndex].nType == CRAFT_TYPE.MAIN then   --采金
		hBtnCraft:Hide()			
		hBtnMain:Show()
		hBtnFlower:Hide()
		hPlayer.SetMinimapRadar(MINI_RADAR_TYPE.FIND_CRAFT_DOODAD, tCraftMenuData[nIndex].dwProfessionID)
	elseif tCraftMenuData[nIndex].nType == CRAFT_TYPE.FLOWER then  --神农
		hBtnFlower:Show() 
		hBtnCraft:Hide()
		hBtnMain:Hide()
		hPlayer.SetMinimapRadar(MINI_RADAR_TYPE.FIND_CRAFT_DOODAD, tCraftMenuData[nIndex].dwProfessionID)
	elseif tCraftMenuData[nIndex].nType == CRAFT_TYPE.NONE then   --不选
		hBtnCraft:Show()
		hPlayer.SetMinimapRadar(MINI_RADAR_TYPE.NO_RADAR, 0)
	end			
end

function Minimap.OnRButtonDown()
	local szName = this:GetName()
	if szName == "Btn_Ad" then
		local menu = 
		{
			{szOption = g_tStrings.MINIMAP_AUTO_ONLINE_REMIND,bCheck = true, bChecked = IsShowLoginTip(),  fnAction = function(UserData, bCkeck) SetShowLoginTip(bCkeck) end},
		}
		PopupMenu(menu)
		return true
	end
end

function Minimap.UpdateGMMsgState(hGMMsgBtn, nDisabled)
	if nDisabled then
		hGMMsgBtn:Lookup("", ""):Show()
	else
		hGMMsgBtn:Lookup("", ""):Hide()
	end
end

function SetLastDiePos(dwMapID, nX, nY, nZ)
	Minimap.nDeathMapID, Minimap.nDeathX, Minimap.nDeathY, Minimap.nDeathZ = dwMapID, nX, nY, nZ
	FireEvent("LAST_DIE_POS_CHANGED")
end

function GetLastDiePos()
	return Minimap.nDeathMapID, Minimap.nDeathX, Minimap.nDeathY, Minimap.nDeathZ
end

function GetMinimapFrame()
	return Station.Lookup("Topmost/Minimap")
end

function GetPartySignPostPos()
	if Minimap.nPartySignPostX and Minimap.nPartySignPostY then
		if GetTickCount() - Minimap.nPartySignPostTime < 6000 then
			return Minimap.nPartySignPostX, Minimap.nPartySignPostY
		end
		Minimap.nPartySignPostX, Minimap.nPartySignPostY = nil, nil
	end
	return nil, nil
end

function Minimap_OnUIScaled()
end

function SetMinimapOpenStatus(bOpen)
	Minimap.bOpen = bOpen
	FireEvent("MINMAP_OPEN_STATUS_CHANGED")
end

function GetMinimapOpenStatus()
	return Minimap.bOpen
end

function IsSearchTypeNpc(dwNpcTypeID)
	return Minimap.tNpcSearch[dwNpcTypeID]
end

function Minimap_SetAnchorDefault()
	Minimap.Anchor.s = Minimap.DefaultAnchor.s
	Minimap.Anchor.r = Minimap.DefaultAnchor.r
	Minimap.Anchor.x = Minimap.DefaultAnchor.x
	Minimap.Anchor.y = Minimap.DefaultAnchor.y
	FireEvent("MINIMAP_ANCHOR_CHANGED")
	Minimap.AnchorCorner = Minimap.DefaultAnchorCorner
	FireEvent("MINIMAP_ANCHOR_CORNER_CHANGED")
end
RegisterEvent("CUSTOM_UI_MODE_SET_DEFAULT", Minimap_SetAnchorDefault)

function Minimap_UpdateSearch()
    local t = Minimap.tSearchInfo or {}
	for k, v in ipairs(tNpcSearchMenuData) do
		v.bSearch = false
	end
	for i, nIndex in ipairs(t) do
		if tNpcSearchMenuData[nIndex] then
			tNpcSearchMenuData[nIndex].bSearch = true
		end
	end
	Minimap.UpdateSearchType()
end
RegisterEvent("CUSTOM_DATA_LOADED", Minimap_UpdateSearch)