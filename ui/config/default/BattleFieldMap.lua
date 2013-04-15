BattleFieldMap = 
{
	w = 1024, h = 1024, scale = 0.001, startx = 0, starty = 0, 
	nIndex = 0, dwMapID = 0, scaleFinal = 0.001, 
	
	fPlayerScale = 0.7,
	tData = {},
	bLoadData = false,
	bExpand = true,
	nVersion = 0,
	nFlashCount = 0,
	fAlpha = 1.0,
	
	DefaultAnchor = {s = "TOPLEFT", r = "BOTTOMRIGHT", x = -400, y = -400},
	Anchor = {s = "TOPLEFT", r = "BOTTOMRIGHT", x = -400, y = -400},
	
	bTurnOn = true,
}

local lc_tMapAlpha = 
{
	0.5, 0.55, 0.6, 0.65, 0.7, 0.75, 0.8, 0.85, 0.9, 0.95, 1.0,
}

local CURRENT_VERSION = 0
local INI_FILE_PATH = "ui/config/default/BattleFieldMap.ini"

local lc_hFrame
local lc_hImgPlayer
local lc_hAniPlayer
local lc_hImagBg
local lc_hImagMap
local lc_hHandleMap
local lc_hHandleTot
local lc_hHandleTeam
local lc_hHandleData
local lc_hTime
local lc_hGood
local lc_hEvil

local function FormatLeftTime(nTime)
	if not nTime then
		return "00"
	end
	
	if nTime < 10 then
		return "0"..nTime
	end
	return nTime
end

local function Table_GetBattleFieldData()
	local tBattleData = {}
	local nCount = g_tTable.BattleFieldData:GetRowCount()
	
	--Row One for default value
	for i = 2, nCount do
		local tData = g_tTable.BattleFieldData:GetRow(i)
		tBattleData[tData.nType] = tData
	end
	
	return tBattleData
end

function BattleFieldMap.OnFrameCreate()
	this:RegisterEvent("UI_SCALED")
	
	BattleFieldMap.InitObject(this);
	BattleFieldMap.Init()
end

function BattleFieldMap.OnEvent(event)
	if event == "UI_SCALED" then
		BattleFieldMap.UpdateAnchor(this)	
	end
end

function BattleFieldMap.OnFrameBreathe()
	BattleFieldMap.UpdateTime()
	
	if BattleFieldMap.bExpand then
		if BattleFieldMap.nFlashCount > 0 then
			BattleFieldMap.UpdateFlashMark()
		end
		
		local player = GetClientPlayer();
		if not player then
			return
		end
	
		BattleFieldMap.UpdatePlayer(player)
		BattleFieldMap.UpdateTeamate(player)
		lc_hHandleMap:FormatAllItemPos()
	end
end

function BattleFieldMap.OnFrameDragEnd()
	this:CorrectPos()
	BattleFieldMap.Anchor = GetFrameAnchor(this)
end

function BattleFieldMap.UpdateAnchor(frame)
	frame:SetPoint(BattleFieldMap.Anchor.s, 0, 0, BattleFieldMap.Anchor.r, BattleFieldMap.Anchor.x, BattleFieldMap.Anchor.y)
	frame:CorrectPos()
end

function BattleFieldMap.InitObject(frame)
	lc_hFrame 	  = frame
	lc_hTime	  = frame:Lookup("Wnd_Title", "Text_Time")
	lc_hHandleTot = frame:Lookup("Wnd_List", "")
	lc_hImagBg    = lc_hHandleTot:Lookup("Image_Bg")
	lc_hHandleMap = lc_hHandleTot:Lookup("Handle_Map")
	lc_hImagMap   = lc_hHandleMap:Lookup("Image_Map")
	lc_hImgPlayer = lc_hHandleMap:Lookup("Image_Player")
	lc_hAniPlayer = lc_hHandleMap:Lookup("Animate_Player")
	lc_hHandleTeam = lc_hHandleMap:Lookup("Handle_Teammate")
	lc_hHandleData = lc_hHandleMap:Lookup("Handle_Data")
	
	local hInfo    = lc_hHandleTot:Lookup("Handle_Info")
	lc_hGood	   = hInfo:Lookup("Handle_Good")
	lc_hEvil	   = hInfo:Lookup("Handle_Bad")
end

function BattleFieldMap.Init()
	lc_hFrame.bIniting = true
	
	BattleFieldMap.tBattleParam = Table_GetBattleFieldData()
	BattleFieldMap.UpdateAnchor(lc_hFrame)
	BattleFieldMap.ExpandFrame(BattleFieldMap.bExpand)
	lc_hTime:SetText("")
	lc_hHandleTeam:Clear()
	lc_hHandleData:Clear()
	lc_hGood:Clear()
	lc_hEvil:Clear()
	lc_hHandleTot:Lookup("Handle_Info"):Hide()
	
	local _, _, nBeginTime, nEndTime  = GetBattleFieldPQInfo()
	BattleFieldMap.nEndTime = nEndTime
	
	BattleFieldMap.UpdateMapPos()
	local tData = BattleFieldMap.tData
	lc_hImagMap:FromTextureFile(tData.szImgPath)
	
	BattleFieldMap.UpdateBattleData()
	BattleFieldMap.UpdateBattleGainData();
	BattleFieldMap.UpdateAlpha(BattleFieldMap.fAlpha)
	
	lc_hFrame.bIniting = false
end

function BattleFieldMap.UpdateAlpha(fAlpha)
	BattleFieldMap.fAlpha = fAlpha
	local nValue = math.floor(255 * fAlpha)
	lc_hImagMap:SetAlpha(nValue)
	lc_hImagBg:SetAlpha(nValue)
end

function BattleFieldMap.PopupMenu()
	local tMenu = 
	{
		{szOption=g_tStrings.STR_MAP_NOT_ALPHA}, 
	}
	for k, v in pairs(lc_tMapAlpha) do
		local szPer = string.format("%.0f%%", v * 100)
		table.insert(tMenu[1], 
			{szOption=szPer, bMCheck=true, bChecked = (BattleFieldMap.fAlpha == v), 
			fnAction=function() BattleFieldMap.UpdateAlpha(v) end});
	end
	PopupMenu(tMenu)
end

function BattleFieldMap.UpdateTime()
	if BattleFieldMap.bInBattlefield and BattleFieldMap.nEndTime then
		local _, _, nBeginTime, nEndTime  = GetBattleFieldPQInfo()
		BattleFieldMap.nEndTime = nEndTime
	
		local nCurrentTime = GetCurrentTime()
		local nTime = BattleFieldMap.nEndTime - nCurrentTime
		if nTime < 0 then
			return 
		end
		
		local szTime = ""
		local nH, nM, nS = GetTimeToHourMinuteSecond(nTime, false)
		szTime = szTime..FormatLeftTime(nH)
		szTime = szTime..":"..FormatLeftTime(nM)
		szTime = szTime..":"..FormatLeftTime(nS)
		
		lc_hTime:SetText(FormatString(g_tStrings.STR_BUFF_H_LEFT_TIME_MSG, szTime))
	end
end

function BattleFieldMap.UpdatePlayer(player)
	local x, y = lc_hHandleMap:GetAbsPos()
	
	lc_hImgPlayer:SetRotate((255 - player.nFaceDirection) * 6.2832 / 255)
	lc_hImgPlayer.x, lc_hImgPlayer.y = player.nX, player.nY
	local wI, hI = lc_hImgPlayer:GetSize()
	local xR, yR = BattleFieldMap.LPosToHPos(lc_hImgPlayer.x, lc_hImgPlayer.y, wI, hI)
	lc_hImgPlayer:SetRelPos(xR, yR)
	lc_hImgPlayer:SetAbsPos(x + xR, y + yR)
	
	lc_hAniPlayer.x, lc_hAniPlayer.y = player.nX, player.nY
	wI, hI = lc_hAniPlayer:GetSize()
	xR, yR = BattleFieldMap.LPosToHPos(lc_hAniPlayer.x, lc_hAniPlayer.y, wI, hI)
	lc_hAniPlayer:SetRelPos(xR, yR)
	lc_hAniPlayer:SetAbsPos(x + xR, y + yR)
end

function BattleFieldMap.UpdateTeamate(player)
	local nIndex = 0
	local x, y = lc_hHandleMap:GetAbsPos()
	
	if player.IsInParty() then
		local hTeam = GetClientTeam()
		local nGroupNum = hTeam.nGroupNum
		for i = 0, nGroupNum - 1 do
			local tGroupInfo = hTeam.GetGroupInfo(i)
			if tGroupInfo and tGroupInfo.MemberList then
				for _, dwID in pairs(tGroupInfo.MemberList) do
					local tMemberInfo = hTeam.GetMemberInfo(dwID)
					if dwID ~= player.dwID and tMemberInfo.bIsOnLine and tMemberInfo.dwMapID == BattleFieldMap.dwMapID then
						local hFlag = lc_hHandleTeam:Lookup(nIndex)
						if not hFlag then
							hFlag = lc_hHandleTeam:AppendItemFromIni(INI_FILE_PATH, "Image_Teammate")
						end
						
						local wI, hI = hFlag:GetSize()
						local xR, yR = BattleFieldMap.LPosToHPos(tMemberInfo.nPosX, tMemberInfo.nPosY, wI, hI)
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
		lc_hHandleTeam:Clear()
	end
	
	local nCount = lc_hHandleTeam:GetItemCount()
	for i = nCount - 1, nIndex, -1 do
		lc_hHandleTeam:RemoveItem(i)
	end
	
	lc_hHandleTeam:FormatAllItemPos()
end

function BattleFieldMap.UpdateFlashMark()
	local nCount = lc_hHandleData:GetItemCount()
	for i=0, nCount - 1, 1 do
		local hFlag = lc_hHandleData:Lookup(i)
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
				BattleFieldMap.nFlashCount = BattleFieldMap.nFlashCount - 1
			end
		end
	end
end

local function AdjustHandleItems(hList, nCount)
	local nItemCount = hList:GetItemCount()
	local nNeedItem = nCount - nItemCount
	
	if nNeedItem > 0 then
		for i = 1, nNeedItem, 1 do
			hList:AppendItemFromIni(INI_FILE_PATH, "Image_Data")
		end
	else
		local nDelCount = -nNeedItem
		for i=1, nDelCount, 1 do
			hList:RemoveItem(nItemCount - i)
		end
	end
end

function BattleFieldMap.UpdateBattleData()
	local tData = BattleFieldMap.tMarkData or {}
	local x, y = lc_hHandleData:GetAbsPos()
	
	local nCount = #tData
	
	AdjustHandleItems(lc_hHandleData, nCount)
	
	BattleFieldMap.nFlashCount = 0;
	for i=1, nCount, 1 do 
		local tMarkD = tData[i]
		local tParam = BattleFieldMap.tBattleParam[tMarkD.nType]
		local hFlag = lc_hHandleData:Lookup(i - 1)
		hFlag:Hide()
		if tParam then
			hFlag:Show()
			hFlag:FromUITex(tParam.szImage, tParam.nFrame)
			hFlag:SetAlpha(255)
			
			local wI, hI = hFlag:GetSize()
			local xR, yR = BattleFieldMap.LPosToHPos(tMarkD.aPoint[1], tMarkD.aPoint[2], wI, hI)
			hFlag:SetRelPos(xR, yR)
			hFlag:SetAbsPos(x + xR, y + yR)
			
			hFlag.nType = tMarkD.nType
			hFlag.bFlash = tMarkD.bFlash
			hFlag.nFlashEndTime = tMarkD.nFlashEnd
			
			hFlag.x, hFlag.y = tMarkD.aPoint[1], tMarkD.aPoint[2]
			
			if hFlag.bFlash then
				BattleFieldMap.nFlashCount = BattleFieldMap.nFlashCount + 1
			end
		end
	end
	lc_hHandleData:FormatAllItemPos()
end

function BattleFieldMap.UpdateBattleGainData()
	if not BattleFieldMap.tGainData then
		lc_hHandleTot:Lookup("Handle_Info"):Hide()
		return
	end
	
	lc_hHandleTot:Lookup("Handle_Info"):Show()
	lc_hGood:Clear()
	
	local tData = BattleFieldMap.tGainData or {}
	local tGood = tData.tGood or {}
	
	for k, v in ipairs(tGood) do
		local tParam = BattleFieldMap.tBattleParam[v.nType]
		if tParam then
			local hItem = lc_hGood:AppendItemFromIni(INI_FILE_PATH, "Handle_IconG")
			hItem:Lookup("Image_Good"):FromUITex(tParam.szImage, tParam.nFrame)
			hItem:Lookup("Text_Good"):SetText(v.nCount)
		end
	end
	lc_hGood:FormatAllItemPos()
	
	local tEvil = tData.tEvil or {}
	lc_hEvil:Clear()
	for k, v in ipairs(tEvil) do
		local tParam = BattleFieldMap.tBattleParam[v.nType]
		if tParam then
			local hItem = lc_hEvil:AppendItemFromIni(INI_FILE_PATH, "Handle_IconE")
			hItem:Lookup("Image_BadE"):FromUITex(tParam.szImage, tParam.nFrame)
			hItem:Lookup("Text_BadE"):SetText(v.nCount)
		end
	end
	lc_hEvil:FormatAllItemPos()	
end

function BattleFieldMap.UpdateMapPos()
	local tData = BattleFieldMap.tData
	local w, h = lc_hHandleMap:GetSize()
	
	local nHeight = h
	local nWidth = tData.w * h / tData.h
	if nWidth > w then
		nWidth = w
		nHeight = tData.h * w / tData.w
	end
	
	lc_hImagMap:SetSize(nWidth, nHeight)
	local x, y = (w - nWidth) / 2, (h - nHeight) / 2
	lc_hImagMap:SetRelPos(x, y)
	
	BattleFieldMap.mapx, BattleFieldMap.mapy = x, y + nHeight
	BattleFieldMap.scaleFinal = tData.scale * nWidth / tData.w
	BattleFieldMap.scaleImg = nWidth / tData.w
	
	local nPW, nPH = lc_hImgPlayer:GetSize()
	lc_hImgPlayer:SetSize(nPW * BattleFieldMap.fPlayerScale, nPH * BattleFieldMap.fPlayerScale)
	
	nPW, nPH = lc_hAniPlayer:GetSize()
	lc_hAniPlayer:SetSize(nPW * BattleFieldMap.fPlayerScale, nPH * BattleFieldMap.fPlayerScale)
end

function BattleFieldMap.LPosToHPos(x, y, w, h)
	local tData = BattleFieldMap.tData
	local xR = BattleFieldMap.mapx + (x - tData.startx) * BattleFieldMap.scaleFinal
	local yR = BattleFieldMap.mapy - (y - tData.starty) * BattleFieldMap.scaleFinal
	if w and h then
		return xR - w / 2, yR - h / 2
	end
	return xR, yR
end

function BattleFieldMap.HPosToLPos(x, y, w, h)
	local tData = BattleFieldMap.tData
	if w and h then
		x, y = x + w / 2, y + h / 2
	end
	
	local xR = tData.startx + (x - BattleFieldMap.mapx) / BattleFieldMap.scaleFinal
	local yR = tData.starty + (BattleFieldMap.mapy - y) / BattleFieldMap.scaleFinal
	return xR, yR
end
--===============msg=================

function BattleFieldMap.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_Setting" then
		BattleFieldMap.PopupMenu()
		return true
	end
end

function BattleFieldMap.OnItemMouseEnter()
	local x, y = this:GetAbsPos()
	local w, h = this:GetSize()
	local szName = this:GetName()
	if szName == "Image_Teammate" then
		local szName = GetTeammateName(this.dwID)
		if szName then
			local r, g, b = GetPartyMemberFontColor()
			local szTip = "<text>text="..EncodeComponentsString(szName).."font=80 r="..r.." g="..g.." b="..b.."</text>"
			OutputTip(szTip, 200, {x, y, w, h})
		end
	elseif szName == "Image_Player" then
		OutputTip(GetFormatText(g_tStrings.MAP_POSITION_SELF), 200, {x + 40, y + 40, w, h})
	end
end

function BattleFieldMap.OnItemMouseLeave()
	local szName = this:GetName()
	if szName == "Image_Teammate" or  szName == "Image_Player" then
		HideTip()
	end
end

function BattleFieldMap.OnCheckBoxCheck()
	if lc_hFrame.bIniting then
		return
	end
	
	local szName = this:GetName()
	if szName == "CheckBox_Minimize" then
		BattleFieldMap.ExpandFrame()
	end
end

function BattleFieldMap.OnCheckBoxUncheck()
	if lc_hFrame.bIniting then
		return
	end
	
	local szName = this:GetName()
	if szName == "CheckBox_Minimize" then
		BattleFieldMap.ExpandFrame()
	end
end

--===============msg end=================

function BattleFieldMap.ExpandFrame(bExpand)
	if bExpand ~= nil then
		BattleFieldMap.bExpand = not bExpand
	end
	
	if BattleFieldMap.bExpand then
		lc_hFrame:SetSize(301, 32)	
		lc_hFrame:Lookup("Wnd_List"):Hide()
		lc_hFrame:Lookup("Wnd_Title"):Lookup("CheckBox_Minimize"):Check(true)
	else
		lc_hFrame:SetSize(301, 295)
		lc_hFrame:Lookup("Wnd_List"):Show()
		lc_hFrame:Lookup("Wnd_Title"):Lookup("CheckBox_Minimize"):Check(false)
	end
	
	BattleFieldMap.bExpand = not BattleFieldMap.bExpand
end


function OpenBattleFieldMap(bDiableSound, dwMapID)
	if IsBattleFieldMapOpen() then
		return
	end
	
	BattleFieldMap.dwMapID = dwMapID
	BattleFieldMap.bInBattlefield = IsInBattleField()
	BattleFieldMap.InitMapData(dwMapID)
	
	lc_hFrame = Wnd.OpenWindow("BattleFieldMap")
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
end

function CloseBattleFieldMap(bDisableSound)
	if not IsBattleFieldMapOpen() then
		return
	end
	
	BattleFieldMap.dwMapID = nil
	BattleFieldMap.bLoadData = false
	BattleFieldMap.nEndTime = nil
	--BattleFieldMap.tMarkData = nil
	--BattleFieldMap.tGainData = nil
	
	Wnd.CloseWindow("BattleFieldMap")
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end
end

function IsBattleFieldMapOpen()
	local hFrame = Station.Lookup("Normal/BattleFieldMap")
	if hFrame and hFrame:IsVisible() then
		return true
	end
	
	return false
end


local function UpdateBattleMapOpenState()
	if not BattleFieldMap.bTurnOn then 
		CloseBattleFieldMap(true)
	else
		local hPlayer = GetClientPlayer()
		if not hPlayer then
			return 
		end
	
		--FillBattleData()
		if IsInBattleField() then
			BattleFieldMap.bInBattlefield = true
			local dwMapID = hPlayer.GetScene().dwMapID
			
			OpenBattleFieldMap(nil, dwMapID)
		else
			BattleFieldMap.bInBattlefield = false
			BattleFieldMap.tMarkData = nil
			BattleFieldMap.tGainData = nil
	
			CloseBattleFieldMap(true);
		end
	end
end

local function OnEnterScene(szEvent)
	if szEvent ~= "PLAYER_ENTER_SCENE" then
		return
	end
	
	UpdateBattleMapOpenState()
end


function BattleFieldMap.InitMapData(dwMapID)
	MiddleMap.InitMiddleMapInfo(dwMapID)
	local nIndex = BattleFieldMap.GetAreaIndex()
	
	BattleFieldMap.LoadMapData(dwMapID, nIndex)
end

function BattleFieldMap.GetAreaIndex()
	local player = GetClientPlayer()
	local scene = player.GetScene()
	local dwMapID = scene.dwMapID
	
	local x, y, z = Scene_GameWorldPositionToScenePosition(player.nX, player.nY, player.nZ, 0)
	local nArea = GetRegionInfo(scene.dwID, x, y, z)
	local nIndex = MiddleMap.GetMapMiddleMapIndex(scene.dwMapID, nArea)
	if not nIndex then
		nIndex = 0
	end
	
	return nIndex
end

function BattleFieldMap.LoadMapData(dwMapID, nIndex)
	if BattleFieldMap.bLoadData then
		return
	end

	local aM = MiddleMap.aInfo[dwMapID]
	
	local tData = BattleFieldMap.tData
	local szName = Table_GetMapName(dwMapID)
	local szPath = GetMapParams(dwMapID)
	if aM and aM[nIndex] then
		local t = aM[nIndex]
		if t.name then
			szName = t.name
		end
		
		tData.szName = szName
		tData.szImgPath = "ui/image/minimap/BMap_"..dwMapID..".tga" --szPath.."minimap\\"..t.image
		tData.w = t.width
		tData.h = t.height
		tData.scale = t.scale
		tData.startx = t.startx
		tData.starty = t.starty
		tData.bIncopy = t.copy
		tData.bInRresherRoom = t.fresherroom
		tData.bInBattlefield = t.battlefield
		
		BattleFieldMap.bLoadData = true
	end
	
end

local function OnBattleMarkDataNotify(tData)
	BattleFieldMap.tMarkData = tData
	if IsBattleFieldMapOpen() then
		BattleFieldMap.UpdateBattleData()
	end
end

local function OnBattleGainDataNotify(tData)
	BattleFieldMap.tGainData = tData
	if IsBattleFieldMapOpen() then
		BattleFieldMap.UpdateBattleGainData()
	end
end

function BattleFieldMap_IsTurnOn()
	return BattleFieldMap.bTurnOn
end

function BattleFieldMap_TurnOn(bOpen)
	if BattleFieldMap.bTurnOn ~= bOpen then
		BattleFieldMap.bTurnOn = bOpen
		UpdateBattleMapOpenState()
	end
end

RegisterCustomData("BattleFieldMap.fAlpha")
RegisterCustomData("BattleFieldMap.bExpand")
RegisterCustomData("BattleFieldMap.Anchor")
RegisterCustomData("BattleFieldMap.nVersion")
RegisterCustomData("BattleFieldMap.bTurnOn")

RegisterEvent("ON_BATTLE_FIELD_MAKR_DATA_NOTIFY", function() OnBattleMarkDataNotify(arg0) end)
RegisterEvent("ON_BATTLE_FIELD_GAIN_DATA_NOTIFY", function() OnBattleGainDataNotify(arg0) end)
RegisterEvent("PLAYER_ENTER_SCENE", function(szEvent) OnEnterScene(szEvent) end)

Battle_GainData = 
{
	tGood=
	{
		{nType=4, nCount=1},--ÆìÖÄ
		{nType=7, nCount=3},--ïÚ³µ
	},
	
	tEvil =
	{
		{nType=4 , nCount=0},--ÆìÖÄ
		{nType=7 , nCount=3},--ïÚ³µ
	},
}
Battle_Data = {}
function FillBattleData()

Battle_Data = 
{
	{nType=0, aPoint={GetClientPlayer().nX + 1000, GetClientPlayer().nY + 10000}},
	{nType=1, aPoint={GetClientPlayer().nX + 1000, GetClientPlayer().nY - 5000}, bFlash=true, nFlashEnd = GetCurrentTime() + 10},
	{nType=2, aPoint={GetClientPlayer().nX + 20000, GetClientPlayer().nY + 10000}},
	{nType=3, aPoint={GetClientPlayer().nX + 20000, GetClientPlayer().nY - 5000}},
	{nType=4, aPoint={GetClientPlayer().nX + 20000, GetClientPlayer().nY - 10000}},
	{nType=5, aPoint={GetClientPlayer().nX + 15000, GetClientPlayer().nY - 6000}},
	{nType=6, aPoint={GetClientPlayer().nX + 15000, GetClientPlayer().nY + 6000}},
	{nType=7, aPoint={GetClientPlayer().nX + 5000, GetClientPlayer().nY + 8000}},
	{nType=8, aPoint={GetClientPlayer().nX + 5000, GetClientPlayer().nY - 8000}},
	
}

end
