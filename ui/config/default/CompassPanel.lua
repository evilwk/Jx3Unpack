----------------------------------------------------------------------
-- 活动罗盘界面
-- Date:	2010.04.10
-- Author:	Danexx
-- Comment:	即使与全世界为敌，我也要守护缪！

--			如果我们还能回到那个季节
--				我希望
--				能多一些阳光。

--			那样
--				你的影子
--				是不是就能在我的心中
--					刻的更加深刻呢？

-- PS: 		我真的不想的~~
----------------------------------------------------------------------
HORO_STATE = {UPPER = 1, MID = 2, LOWER = 3,}
local COMPASS_PANEL_SCHOOL_COUNT = 8

local nRotateSpeed = 50
local nArrowAlpha = 200
local nFoundDist = 255
local dwFindChestCDBuffID = 1821
local dwFindChestCDDelay = 16
local dwHoroBuffID = 1818
local dwPartyDigBuffID = 1819
local nDoomBuffLevel = 13


local bCDBuff = false
local bDoomBuff = false
local bLowLevel = false
local bOutScene = false

local nLastCheckTime = GetCurrentTime()
local tLocalData = {}
local tChestZoneTable = {}
local szAllowMap_Force = ""
local szAllowMap_Wild = ""

CompassPanel = CompassPanel or {}
CompassPanel.frameSelf = nil
CompassPanel.wndShownImage = nil
CompassPanel.handleMain = nil
CompassPanel.handleImages = nil

CompassPanel.tImageChestArrow = {}
CompassPanel.tImageBossArrow = {}
CompassPanel.imageCameraArrow = nil

CompassPanel.Anchor = {fXScale = 0.85, fYScale = 0.25};		RegisterCustomData("CompassPanel.Anchor")
CompassPanel.bOpen = false;									RegisterCustomData("CompassPanel.bOpen")
CompassPanel.szTipName = "";

CompassPanel.nStateIndex = 0;
CompassPanel.nStateLeftDay = 0;
CompassPanel.nStateMaxLevel = 0;
CompassPanel.nStateSysLevel = 0;
CompassPanel.nHoroDunValue = 0;								RegisterCustomData("CompassPanel.nHoroDunValue")
CompassPanel.nHoroDigValue = 0;								RegisterCustomData("CompassPanel.nHoroDigValue")
CompassPanel.States = {[HORO_STATE.UPPER] = {}, [HORO_STATE.MID] = {}, [HORO_STATE.LOWER] = {}, }

CompassPanel.tBuffInfo = {}
CompassPanel.tBuffValue = {}								RegisterCustomData("CompassPanel.tBuffValue")
CompassPanel.tEffects = {tArray = {}}

-- 下面这个定义了哪些BUFF具有哪些效果
CompassPanel.tBuffEffectList = {
	[1818] = {
		[1] = {101, 100, 103, 105, 41, 42},
		[2] = {102, 100, 103, 41, 42},
		[3] = {102, 100, 103, 41, 42},
		[4] = {102, 100, 103, 106, 41, 42},
		[5] = {102, 100, 103, 41, 42},
		[6] = {102, 100, 103, 105, 41, 42},
		[7] = {102, 100, 103, 105, 41, 42},
		[8] = {102, 100, 103, 105, 41, 42},
		[9] = {102, 100, 103, 105, 41, 42},
		[10] = {100, 103, 41, 42},
		[11] = {100, 103, 41, 42},
		[12] = {100, 103, 41, 42},
		[13] = {104},
	},
}

-------------------------------------------------------------
local GetSteperCount = function()
	return GetCurrentTime() - nLastCheckTime
end

local RequestHoroSysData = function()
	RemoteCallToServer("OnHoroSysDataRequest")
end

-------------------------------------------------------------
function CompassPanel.OnFrameCreate()
	this:RegisterEvent("RENDER_FRAME_UPDATE")
	this:RegisterEvent("LOADING_END")
	this:RegisterEvent("UI_SCALED")
	this:RegisterEvent("CUSTOM_DATA_LOADED")
	this:RegisterEvent("BUFF_UPDATE")
end

function CompassPanel.OnEvent(event)
	if event == "RENDER_FRAME_UPDATE" then
		CompassPanel.DrawAllArrow()
	elseif event == "LOADING_END" then
		local scene = GetClientScene();
		local dwCurrentMapID = scene.dwMapID
		local szMapName = Table_GetMapName(dwCurrentMapID)
		bOutScene = true
		for i = 1, #tChestZoneTable do
			if tChestZoneTable[i] == szMapName then
				bOutScene = false
				break
			end
		end
		RequestHoroSysData()
	elseif event == "UI_SCALED" then
		CompassPanel.OnUIScaled()
	elseif event == "CUSTOM_DATA_LOADED" then
		CompassPanel.OnCustomDataLoaded()
	elseif event == "BUFF_UPDATE" then
		CompassPanel.UpdateTipEffectList()
	end
end

function CompassPanel.OnFrameDragEnd()
	if not CompassPanel.frameSelf then
		return
	end
	local nW, nH = Station.GetClientSize(true)
	local nX, nY = CompassPanel.frameSelf:GetAbsPos()
	CompassPanel.Anchor = {
		fXScale = nX / nW,
		fYScale = nY / nH,
	}
end

function CompassPanel.OnFrameBreathe()
	if dwFindChestCDDelay > 0 then
		dwFindChestCDDelay = dwFindChestCDDelay - 1
	end
	CompassPanel.UpdateBuffInfo()
	CompassPanel.UpdateAllArrowRotate()
	CompassPanel.UpdateStateInfo()
	CompassPanel.OutputTips()
	
	local player = GetClientPlayer()
	if not player then
		return
	end
end

function CompassPanel.OnItemMouseEnter()
	local szName = this:GetName()
	if szName == "Image_TimeBuff" then
		CompassPanel.szTipName = "Image_TimeBuff"
	elseif szName == "Image_TimeBG" or szName == "Text_Time" then
		CompassPanel.szTipName = "Image_TimeBG"
	elseif szName == "Image_State" or szName == "Text_State" then
		CompassPanel.szTipName = "Image_State"
	end
end
function CompassPanel.OnItemMouseLeave()
	CompassPanel.szTipName = ""
	HideTip(true)
end
function CompassPanel.OnMouseEnter()
	local szName = this:GetName()
	if szName == "Btn_Chests" then
		CompassPanel.szTipName = "Btn_Chests"
	end
end
function CompassPanel.OnMouseLeave()
	local szName = this:GetName()
	CompassPanel.szTipName = ""
	if szName == "Wnd_ShownImage" then
		HideTip()
	else
		HideTip(true)
	end
end

function CompassPanel.OnLButtonClick()
	if dwFindChestCDDelay == 0 then
		RemoteCallToServer("OnHoroSysUpdateLocRequest")
	end
	dwFindChestCDDelay = 16
end

function CompassPanel.OutputTips()
	if CompassPanel.szTipName == "" then
		return
	end
    
	local nMouseX, nMouseY = Cursor.GetPos()	
	if CompassPanel.szTipName == "Image_TimeBuff" then
    --[[
		-- TIP 名称部分
		local szBuffName = HORO_SYS_STRINGS.NO_BUFF_NAME
		local bDisableTipName = true
		if CompassPanel.tBuffInfo.dwID then
			szBuffName = Table_GetBuffName(CompassPanel.tBuffInfo.dwID, CompassPanel.tBuffInfo.nLevel)
			bDisableTipName = false
		end
		local szBuffTime = CompassPanel.GetBoldString(CompassPanel.handleMain:Lookup("Text_Time"):GetText())
		local szTipBase = CompassPanel.FormatTipsString(HORO_SYS_STRINGS.TIME_BUFF_STRING.TITLE, bDisableTipName, szBuffName, szBuffTime)
		
		-- TIP 挖宝和副本运势部分
		local nDunValue = CompassPanel.GetHoroDunValue() or 0
		if bDisableTipName then
			nDunValue = 0
		end
		local szTipDun =  CompassPanel.FormatTipsString(HORO_SYS_STRINGS.TIME_BUFF_STRING.DUN_VALUE, (not nDunValue or nDunValue <= 0), nDunValue)
		local nDigValue = CompassPanel.GetHoroDigValue() or 0
		if bDisableTipName then
			nDigValue = 0
		end
		local szTipDig =  CompassPanel.FormatTipsString(HORO_SYS_STRINGS.TIME_BUFF_STRING.DIG_VALUE, (not nDigValue or nDigValue <= 0), nDigValue)
		
		-- TIP 的 EFFECT 效果部分
		local bHasEffect = false
		local szTipEffect = CompassPanel.FormatTipsString("<F106 \n>")
		for i = 1, #CompassPanel.tEffects.tArray do
			local tBuffInfo = CompassPanel.tEffects.tArray[i]
			local nEffectID = tBuffInfo.nEffectID
			if CompassPanel.tEffects[nEffectID] then
				local dwBuffID, nBuffLevel = tBuffInfo.dwID, tBuffInfo.nLevel
				local nCustomValue1, nCustomValue2 = CompassPanel.GetHoroCustomValues(dwBuffID, nBuffLevel)
				nCustomValue1 = nCustomValue1 or 0; nCustomValue2 = nCustomValue2 or 0
				local szEffect = CompassPanel.tEffectList[nEffectID].szEffect
				local szEffectHelp = CompassPanel.tEffectList[nEffectID].szEffectHelp
				local bDisableTipEffect, nValue1, nValue2 = false, 0, 0
				if CompassPanel.tEffectList[nEffectID].funcCondition then
					bDisableTipEffect, nValue1, nValue2 = CompassPanel.tEffectList[nEffectID].funcCondition(nDunValue, nDigValue, nCustomValue1, nCustomValue2)
					bDisableTipEffect = not bDisableTipEffect		-- 返回值是是否高亮, 这里接收的是是否灰掉
				end
				
				szTipEffect = szTipEffect .. CompassPanel.FormatTipsString(szEffect, bDisableTipEffect, nValue1, nValue2)
				if IsCtrlKeyDown() then
					szTipEffect = szTipEffect .. CompassPanel.FormatTipsString(szEffectHelp, bDisableTipEffect)
				end
				bHasEffect = true
			end
		end
		if not bHasEffect then
			szTipEffect = ""
		end
		
		-- TIP 的结尾说明部分
		local szTipHelp = ""
		if IsCtrlKeyDown() then
			szTipHelp = CompassPanel.FormatTipsString(HORO_SYS_STRINGS.SYSTIP.HIDE) .. CompassPanel.FormatTipsString(CompassPanel.tHelpTipList.szHoroHelp)
		else
			szTipHelp = CompassPanel.FormatTipsString(HORO_SYS_STRINGS.SYSTIP.SHOW)
		end
		
		-- 拼接并且显示整个 TIP
		local szTip = szTipBase .. szTipDun .. szTipDig .. szTipEffect .. szTipHelp
		OutputTip(szTip, 550, {nMouseX, nMouseY, 0, 0})
        ]]
	elseif CompassPanel.szTipName == "Image_TimeBG" or CompassPanel.szTipName == "Text_Time" then
		--[[
        -- TIP 名称部分
		local szBuffTime = CompassPanel.GetBoldString(CompassPanel.handleMain:Lookup("Text_Time"):GetText())
		local szTipBase = CompassPanel.FormatTipsString(HORO_SYS_STRINGS.TIME_BUFF_STRING.TIME, false, szBuffTime)
		
		-- TIP 的结尾说明部分
		local szTipHelp = ""
		if IsCtrlKeyDown() then
			szTipHelp = CompassPanel.FormatTipsString(HORO_SYS_STRINGS.SYSTIP.HIDE) .. CompassPanel.FormatTipsString(CompassPanel.tHelpTipList.szTimeHelp)
		else
			szTipHelp = CompassPanel.FormatTipsString(HORO_SYS_STRINGS.SYSTIP.SHOW)
		end
		
		-- 拼接并且显示整个 TIP
		local szTip = szTipBase .. szTipHelp
		OutputTip(szTip, 550, {nMouseX, nMouseY, 0, 0})	
        ]]
	elseif CompassPanel.szTipName == "Image_State" or CompassPanel.szTipName == "Text_State" then
        --[[
		if not CompassPanel.nStateIndex or CompassPanel.nStateIndex < 1 then
			return
		end
		
		-- TIP 名称部分
		local szStateName = CompassPanel.GetBoldString(CompassPanel.handleMain:Lookup("Text_State"):GetText())
		local szTipBase = CompassPanel.FormatTipsString(HORO_SYS_STRINGS.STATE_STRING, false,
			szStateName, CompassPanel.States[CompassPanel.nStateIndex].nLevel, CompassPanel.nStateMaxLevel, CompassPanel.GetBoldString(CompassPanel.States[CompassPanel.nStateIndex].nExp), CompassPanel.GetBoldString(CompassPanel.States[CompassPanel.nStateIndex].nUpExp), (10 - CompassPanel.nStateLeftDay * 2)
		)
		
		-- TIP 的结尾说明部分
		local szTipHelp = ""
		if IsCtrlKeyDown() then
			szTipHelp = CompassPanel.FormatTipsString(HORO_SYS_STRINGS.SYSTIP.HIDE) .. CompassPanel.FormatTipsString(CompassPanel.tHelpTipList.szStateHelp)
		else
			szTipHelp = CompassPanel.FormatTipsString(HORO_SYS_STRINGS.SYSTIP.SHOW)
		end
		
		-- 拼接并且显示整个 TIP
		local szTip = szTipBase .. szTipHelp
		OutputTip(szTip, 550, {nMouseX, nMouseY, 0, 0})	
    ]]
	elseif CompassPanel.szTipName == "Btn_Chests" then
		-- TIP 名称部分
		local szTipBase = CompassPanel.FormatTipsString(HORO_SYS_STRINGS.CHESTS_STRING.FIND, false)
		local szTipLeftTime = CompassPanel.FormatTipsString(HORO_SYS_STRINGS.CHESTS_STRING.TIME, false, CompassPanel.GetBoldString(CompassPanel.GetBuffLeftTime(dwFindChestCDBuffID)))
		local szTipDigLeftTime = CompassPanel.FormatTipsString(HORO_SYS_STRINGS.CHESTS_STRING.PARTY_DIG_TIME, false, CompassPanel.GetBoldString(CompassPanel.GetBuffLeftTime(dwPartyDigBuffID)))
		
		local nDigMapID = 0
		local szDigMapName = HORO_SYS_STRINGS.NO_BUFF_NAME
		for i = 1, #tLocalData.tChestList do
			local tChestInfo = tLocalData.tChestList[i]
			if tChestInfo.nIndex == 3 then
				nDigMapID = tChestInfo.nMapID
			end
		end
		if nDigMapID > 0 then
			szDigMapName = Table_GetMapName(nDigMapID) or szDigMapName
		end
		local szTipDigPartyScene = CompassPanel.FormatTipsString(HORO_SYS_STRINGS.CHESTS_STRING.PARTY_DIG_SCENE, false, szDigMapName)
		
		-- TIP 警告部分
		local szTipNotice = ""
		if bLowLevel then
			szTipNotice = szTipNotice .. CompassPanel.FormatTipsString(HORO_SYS_STRINGS.REQUIREMENT.LEVEL)
		end
		if bCDBuff then
			szTipNotice = szTipNotice .. CompassPanel.FormatTipsString(HORO_SYS_STRINGS.REQUIREMENT.FINDCD)
		end
		
		--[[
		if bDoomBuff then
			szTipNotice = szTipNotice .. CompassPanel.FormatTipsString(HORO_SYS_STRINGS.REQUIREMENT.DOOM)
		end
		
		--]]
		
		if bOutScene then
			szTipNotice = szTipNotice .. CompassPanel.FormatTipsString(HORO_SYS_STRINGS.REQUIREMENT.SCENE, false, szAllowMap_Force, szAllowMap_Wild)
		end
		if szTipNotice ~= "" then
			szTipNotice = CompassPanel.FormatTipsString("<F102 \n>") .. szTipNotice
		end

		-- TIP 的结尾说明部分
		local szTipHelp = ""
		--[[
		if IsCtrlKeyDown() then
			szTipHelp = CompassPanel.FormatTipsString(HORO_SYS_STRINGS.SYSTIP.HIDE) .. CompassPanel.FormatTipsString(CompassPanel.tHelpTipList.szButtonHelp)
		else
			szTipHelp = CompassPanel.FormatTipsString(HORO_SYS_STRINGS.SYSTIP.SHOW)
		end
		--]]
		
		-- 拼接并且显示整个 TIP
		local szTip = szTipBase .. szTipLeftTime .. szTipDigLeftTime .. szTipDigPartyScene .. szTipNotice .. szTipHelp
		OutputTip(szTip, 550, {nMouseX, nMouseY, 0, 0})	
	else
	end
end

function CompassPanel.UpdateTipEffectList()
	local player = GetClientPlayer()
	if not player then
		return
	end
	local tBuffList = player.GetBuffList()
	CompassPanel.tEffects = {tArray = {}}
	if tBuffList then
		local nIndex = 1
		for _, tBuff in pairs(tBuffList) do
			if CompassPanel.tBuffEffectList[tBuff.dwID] and CompassPanel.tBuffEffectList[tBuff.dwID][tBuff.nLevel] then
				for i = 1, #CompassPanel.tBuffEffectList[tBuff.dwID][tBuff.nLevel] do
					local nEffectID = CompassPanel.tBuffEffectList[tBuff.dwID][tBuff.nLevel][i]
					if not CompassPanel.tEffects[nEffectID] then
						CompassPanel.tEffects[nEffectID] = {nEffectID = nEffectID, dwID = tBuff.dwID, nLevel = tBuff.nLevel}
						CompassPanel.tEffects.tArray[nIndex] = CompassPanel.tEffects[nEffectID]
						nIndex = nIndex + 1
					end
				end
			end
		end
	end
end

-------------------------------------------------------------
function CompassPanel.OnCustomDataLoaded()
	if arg0 ~= "Role" then
		return
	end
	
	if CompassPanel.bOpen then
		CompassPanel.OpenPanel()
	else
		CompassPanel.ClosePanel()
	end
	CompassPanel.UptatePanelPos()
end

function CompassPanel.OnUIScaled()
	CompassPanel.UptatePanelPos()
end

function CompassPanel.UptatePanelPos()
	if CompassPanel.frameSelf then
		local nW, nH = Station.GetClientSize(true)
		CompassPanel.frameSelf:SetAbsPos(nW * CompassPanel.Anchor.fXScale, nH * CompassPanel.Anchor.fYScale)
	end
end

-------------------------------------------------------------
function CompassPanel.OnHoroSysDataUpdate(tHoroSysData)
	CompassPanel.nStateIndex = tHoroSysData.nStateIndex
	CompassPanel.nStateLeftDay = tHoroSysData.nStateLeftDay
	CompassPanel.nStateMaxLevel = tHoroSysData.nStateMaxLevel
	CompassPanel.nStateSysLevel = tHoroSysData.nStateSysLevel
	CompassPanel.nHoroDunValue = tHoroSysData.nHoroDunValue
	CompassPanel.nHoroDigValue = tHoroSysData.nHoroDigValue
	CompassPanel.States = tHoroSysData.States
	
	local tBuff = tHoroSysData.Buff or {}
	if tBuff.dwID then
		local dwBuffID = tBuff.dwID
		local nBuffLevel = tBuff.nLevel
		local nValue = tBuff.nValue
		if not CompassPanel.tBuffValue[dwBuffID] then
			CompassPanel.tBuffValue[dwBuffID] = {}
		end
		CompassPanel.tBuffValue[dwBuffID][nBuffLevel] = nValue
		CompassPanel.tBuffInfo = tBuff
	end
	
	local tLoc = tHoroSysData.Locs or {}
	tLocalData.tBossList = {}
	tLocalData.tChestList = {}
	if tLoc.Player.nMapID and tLoc.Player.nMapID ~= 0 then
		table.insert(tLocalData.tChestList, {nIndex = 4, nMapID = tLoc.Player.nMapID, nX = tLoc.Player.nX, nY = tLoc.Player.nY, nCompassAngle = tLoc.Player.nCompassAngle})
	end
	if tLoc.Party.nMapID and tLoc.Party.nMapID ~= 0 then
		table.insert(tLocalData.tChestList, {nIndex = 3, nMapID = tLoc.Party.nMapID, nX = tLoc.Party.nX, nY = tLoc.Party.nY, nCompassAngle = tLoc.Party.nCompassAngle})
	end
end

function CompassPanel.GetHoroBuffValue(dwBuffID, nBuffLevel)
	if CompassPanel.tBuffInfo.dwID == dwBuffID and CompassPanel.tBuffInfo.nLevel == nBuffLevel and CompassPanel.tBuffValue[dwBuffID] then
		return CompassPanel.tBuffValue[dwBuffID][nBuffLevel]
	end
end
-- 获取副本运气等级
function CompassPanel.GetHoroDunValue()
	return CompassPanel.nHoroDunValue
end
-- 获取挖宝运气等级
function CompassPanel.GetHoroDigValue()
	return CompassPanel.nHoroDigValue
end
-- 获取副本自定义等级
function CompassPanel.GetHoroCustomValues(dwBuffID, nBuffLevel)
	return CompassPanel.GetHoroBuffValue(dwBuffID, nBuffLevel)
end

function CompassPanel.GetBuffLeftTime(dwBuffID)
	local tBuffList = GetClientPlayer().GetBuffList()
	local szLeftTime = [[--'--"]]
	if tBuffList and dwBuffID then
		for _, tBuff in pairs(tBuffList) do
			if tBuff.dwID == dwBuffID then
				local nLeftTimeTotal = math.floor((tBuff.nEndFrame - GetLogicFrameCount()) / 16)
				if nLeftTimeTotal > 0 then
					local nLeftH = math.floor(nLeftTimeTotal / 3600)
					local nLeftM = math.floor((nLeftTimeTotal - nLeftH * 3600) / 60)
					local nLeftS = math.floor((nLeftTimeTotal - nLeftH * 3600 - nLeftM * 60))
					if nLeftH > 0 then
						szLeftTime = nLeftH .. [[:]]
					else
						szLeftTime = ""
					end
					if nLeftM < 10 then
						szLeftTime = szLeftTime .. "0" .. nLeftM .. [[']]
					else
						szLeftTime = szLeftTime .. nLeftM .. [[']]
					end
					if nLeftS < 10 then
						szLeftTime = szLeftTime .. "0" .. nLeftS .. [["]]
					else
						szLeftTime = szLeftTime .. nLeftS .. [["]]
					end
				end
				break
			end
		end
	end
	return szLeftTime
end

function CompassPanel.GetStarString(nStar, nMaxStar)
	local szStar = HORO_SYS_STRINGS.STAR.STAR
	local szHalfStar = HORO_SYS_STRINGS.STAR.HALFSTAR
	local szStarString = ""
	nMaxStar = nMaxStar or 20
	if nStar < 0 then
		nStar = 0
	elseif nStar > nMaxStar then
		nStar = nMaxStar
	end
	szStarString = szStar:rep(math.floor(nStar / 2)) .. szHalfStar:rep(nStar % 2)
	return szStarString
end

function CompassPanel.GetBoldString(szString)
	if not szString then
		return ""
	end
	szString = tostring(szString)
	local szBold = szString:gsub("[%d':" .. [["]] .. "]", function(szChar)
		local tTranstable = HORO_SYS_STRINGS.NUMBER_BOLD
		if tTranstable[szChar] then
			return tTranstable[szChar]
		else
			return szChar
		end
	end)
	return szBold
end

function CompassPanel.GetTwoPointAngle(nOX, nOY, nX, nY)
	local nPi = math.pi
	local nTwoPi = math.pi * 2
	
	local nDist = ((nX - nOX) ^ 2 + (nY - nOY) ^ 2) ^ 0.5
	if nDist == 0 then
		return -1
	end
	local nAngle = math.asin((nY - nOY) / nDist)
	if nX < nOX then
		nAngle = nPi + nAngle
	else
		nAngle = nTwoPi - nAngle
	end
	return nAngle, nDist
end

function CompassPanel.ClampAngle(nAngle)
	local nPi = math.pi
	local nTwoPi = math.pi * 2
	
	if nAngle >= nTwoPi then
		nAngle = nAngle - nTwoPi
	elseif nAngle < 0 then
		nAngle = nAngle + nTwoPi
	end
	return nAngle
end

function CompassPanel.SetArrowColor(imageArrow, nIndex)
	if not imageArrow or nIndex > 5 or nIndex < 1 then
		return
	end
	local nFrameList = {4, 5, 6, 7, 8}
	imageArrow:SetFrame(nFrameList[nIndex])
end
-------------------------------------------------------------
function CompassPanel.UpdateStateInfo()
	local player = GetClientPlayer()		
	local tStatesName = HORO_SYS_STRINGS.STATE_NAMES
	local nStateIndex = CompassPanel.nStateIndex
	local szStateName = tStatesName[nStateIndex]
	if not szStateName then
		szStateName = HORO_SYS_STRINGS.NO_BUFF_NAME
	end
	CompassPanel.handleMain:Lookup("Text_State"):SetText(szStateName)
end


function CompassPanel.UpdateBuffInfo()
	CompassPanel.tBuffInfo = {}
	local player = GetClientPlayer()
	if not player then
		return
	end
	local scene = player.GetScene()
	if not scene then
		return
	end
	local dwCurrentMapID = scene.dwMapID
	local tBuffList = player.GetBuffList()
	bCDBuff = false
	bDoomBuff = false
	bLowLevel = player.nLevel < 20
	if tBuffList then
		for _, tBuff in pairs(tBuffList) do
			if tBuff.dwID == dwHoroBuffID then
				CompassPanel.tBuffInfo = tBuff
			end
			if tBuff.dwID == dwFindChestCDBuffID then
				bCDBuff = true
			end
			if tBuff.dwID == dwHoroBuffID and tBuff.nLevel == nDoomBuffLevel then
				bDoomBuff = true
			end
		end
	end
	local bEnable = CompassPanel.frameSelf:Lookup("Btn_Chests"):IsEnabled()
	if bCDBuff or bDoomBuff or bLowLevel or bOutScene then
        if bEnable then
            CompassPanel.frameSelf:Lookup("Btn_Chests"):Enable(false)
            FireUIEvent("COMPASS_CHEST_STATE_UPDATE")
        end
	else
        if not bEnable then
            CompassPanel.frameSelf:Lookup("Btn_Chests"):Enable(true)
            FireUIEvent("COMPASS_CHEST_STATE_UPDATE")
        end
	end

	local szLeftTime = CompassPanel.GetBuffLeftTime(CompassPanel.tBuffInfo.dwID)
	CompassPanel.handleMain:Lookup("Text_Time"):SetText(szLeftTime)
	CompassPanel.handleMain:Lookup("Text_Time"):SetFontColor(0, 200, 100)
	
	local nIconID = 572
	if CompassPanel.tBuffInfo.dwID then
		local nIconIDNew = Table_GetBuffIconID(CompassPanel.tBuffInfo.dwID, CompassPanel.tBuffInfo.nLevel)
		if nIconIDNew > 0 then
			nIconID = nIconIDNew
		end
	end
	
	local imageTimeBuff = CompassPanel.handleImages:Lookup("Image_TimeBuff")
	if not imageTimeBuff then
		return
	end
	if not imageTimeBuff.nIconID or imageTimeBuff.nIconID ~= nIconID then
		imageTimeBuff:FromIconID(nIconID)
		imageTimeBuff.nIconID = nIconID
	end
end

function CompassPanel.UpdateAllArrowRotate()
	if not CompassPanel.IsOpened() then
		return
	end
	local player = GetClientPlayer()
	if not player then
		return
	end
	local scene = player.GetScene()
	local dwCurrentMapID = scene.dwMapID
	local bShowFlash = false

	for i = 1, 5 do
		local tTargetList = {tLocalData.tChestList, tLocalData.tBossList}
		local tImageArrow = {CompassPanel.tImageChestArrow, CompassPanel.tImageBossArrow}
		for j = 1, #tTargetList do
			if tTargetList[j][i] then
				tImageArrow[j][i]:Show()
				local nMapID = tTargetList[j][i].nMapID
				if dwCurrentMapID ~= nMapID  or bLowLevel or bOutScene then
					tImageArrow[j][i]:Hide()
					bShowFlash = false
				else
					local nTargetX, nTargetY = tTargetList[j][i].nX, tTargetList[j][i].nY
					if nTargetX > 0 or nTargetY > 0 then
						local nTargetAngle, nDist = CompassPanel.GetTwoPointAngle(player.nX, player.nY, nTargetX, nTargetY)
						tTargetList[j][i].nCompassAngle = CompassPanel.ClampAngle(nTargetAngle)
						if nDist <= nFoundDist then
							bShowFlash = true
							tImageArrow[j][i]:Hide()
						end
					end
				end
				tImageArrow[j][i]:SetAlpha(nArrowAlpha)
				CompassPanel.SetArrowColor(tImageArrow[j][i], tTargetList[j][i].nIndex)
			else
				tImageArrow[j][i]:Hide()
			end
		end
	end
	
	if bShowFlash then
		CompassPanel.handleImages:Lookup("Animate_Found"):Show()
	else
		CompassPanel.handleImages:Lookup("Animate_Found"):Hide()
	end
end

function CompassPanel.DrawAllArrow()
	if not CompassPanel.IsOpened() then
		return
	end
	
	for i = 1, 5 do
		local tTargetList = {tLocalData.tChestList, tLocalData.tBossList}
		local tImageArrow = {CompassPanel.tImageChestArrow, CompassPanel.tImageBossArrow}
		for j = 1, #tTargetList do
			if tTargetList[j][i] and tTargetList[j][i].nCompassAngle then
				local nAngle = tTargetList[j][i].nCompassAngle
				local nAngleDraw = tImageArrow[j][i].nCompassAngleForDraw
			
				if nAngle - math.pi <= 0 then
					if nAngleDraw >= math.pi + nAngle then
						nAngleDraw = math.pi * 2 - nAngleDraw
					end
				else
					if nAngleDraw <= nAngle - math.pi then
						nAngleDraw = math.pi * 2 + nAngleDraw
					end
				end
				local nAngleOffset = math.abs(nAngleDraw - nAngle)
				if nAngleOffset >= math.pi then
					nAngleOffset = math.pi
				end
				if nAngleDraw >= nAngle then
					tImageArrow[j][i].nCompassAngleForDraw = nAngleDraw - (0 + nAngleOffset / (math.pi * nRotateSpeed))
				else
					tImageArrow[j][i].nCompassAngleForDraw = nAngleDraw + (0 + nAngleOffset / (math.pi * nRotateSpeed))
				end
				tImageArrow[j][i]:SetRotate(tImageArrow[j][i].nCompassAngleForDraw)
			else
				tImageArrow[j][i]:Hide()
			end
		end
	end

	local _, nCameraAngle = Camera_GetRTParams()
	CompassPanel.imageCameraArrow:SetRotate(CompassPanel.ClampAngle(nCameraAngle - math.pi / 2))
end

-- szTips 格式如: <F100 这里是黄色><F106 这里是白色>
function CompassPanel.FormatTipsString(szTips, bDisable, ...)
	local szFormated = ""
	local tArgList = {...}
	if not szTips then
		return szFormated
	end
	for i = 1, 8 do
		if not tArgList[i] then
			tArgList[i] = ""
		end
	end
	if tArgList[i] ~= "" then
		szTips = szTips:format(unpack(tArgList))
	end
	
	local nFontGrayID = 110
	for szTag in szTips:gmatch("%b<>") do
		if szTag:match("^<(%bF )") then
			local szFontStr = szTag:match("^<(%bF )")
			local nFontID = tonumber(szFontStr:sub(2, -2))
			if bDisable then
				nFontID = nFontGrayID
			end
			if nFontID then
				local szContent = szTag:sub(#szFontStr + 2, -2)
				szFormated = szFormated .. "<Text>text=" .. EncodeComponentsString(szContent) .. " font=" .. nFontID .. " </text>"
			end
		elseif szTag:match("^<(%bS )") then
			local szStarStr = szTag:match("^<(%bS )")
			local nFontID = tonumber(szStarStr:sub(2, -2))
			local nFontRedID = 112
			if bDisable then
				nFontID = nFontGrayID
				nFontRedID = nFontGrayID
			end
			if nFontID then
				local nStarCount = 0
				local nMaxLevel = 20
				local szContent = szTag:sub(#szStarStr + 2, -2)
				if szContent:match("(%d*) (%d*)") then
					nStarCount, nMaxLevel = szContent:match("(%d*) (%d*)")
					nStarCount = tonumber(nStarCount)
					nMaxLevel = math.min(tonumber(nMaxLevel) or 20, CompassPanel.nStateSysLevel)
				else
					nStarCount = tonumber(szContent)
				end
				if nStarCount then
					if nStarCount >= CompassPanel.nStateSysLevel then
						nStarCount = CompassPanel.nStateSysLevel
					end
					local nShowStarCount = nStarCount
					if nShowStarCount > nMaxLevel then
						nShowStarCount = nMaxLevel
					end
					szFormated = szFormated .. "<Text>text=" .. EncodeComponentsString(CompassPanel.GetStarString(nShowStarCount, nMaxLevel)) .. " font=" .. nFontID .. " </text>" ..
						"<Text>text=" .. EncodeComponentsString(CompassPanel.GetStarString(math.floor((nMaxLevel - nStarCount) / 2) * 2, nMaxLevel)) .. " font=" .. nFontGrayID .. " </text>" ..
						"<Text>text=" .. EncodeComponentsString(CompassPanel.GetStarString(nStarCount - nMaxLevel, nMaxLevel)) .. " font=" .. nFontRedID .. " </text>"
				end
			end
		end
	end
	return szFormated
end
-------------------------------------------------------------
function CompassPanel.OpenPanel()
	local frame = Station.Lookup("Normal/CompassPanel")
	if not frame then
		frame = Wnd.OpenWindow("CompassPanel")
	end
	frame:Show()
	CompassPanel.bOpen = true
	
	if not CompassPanel.frameSelf then
		CompassPanel.frameSelf = frame
		CompassPanel.wndShownImage = CompassPanel.frameSelf:Lookup("Wnd_ShownImage")
		CompassPanel.handleMain = CompassPanel.wndShownImage:Lookup("", "")
		CompassPanel.handleImages = CompassPanel.wndShownImage:Lookup("", "Handle_Images")
		
		CompassPanel.tImageCompass = {
			CompassPanel.handleImages:Lookup("Image_Compass_Red"),
			CompassPanel.handleImages:Lookup("Image_Compass_Blue"),
			CompassPanel.handleImages:Lookup("Image_Compass_Yellow"),
		}
		
		for i = 1, 5 do
			CompassPanel.tImageChestArrow[i] = CompassPanel.handleImages:Lookup("Image_Chest_" .. i)
			CompassPanel.tImageChestArrow[i].nCompassAngleForDraw = 0
			CompassPanel.tImageBossArrow[i] = CompassPanel.handleImages:Lookup("Image_Boss_" .. i)
			CompassPanel.tImageBossArrow[i].nCompassAngleForDraw = 0
		end
		
		CompassPanel.imageCameraArrow = CompassPanel.handleImages:Lookup("Image_Camera")
		CompassPanel.imageCameraArrow:Show()
		
		tChestZoneTable = {
			------------------八大门派地图
			Table_GetMapName(2),				--万花
			Table_GetMapName(5),				--少林
			Table_GetMapName(7),				--纯阳
			Table_GetMapName(11),				--天策
			Table_GetMapName(16),				--七秀
			Table_GetMapName(49),				--藏剑
			Table_GetMapName(102),				--五毒
            Table_GetMapName(122),		        --唐门
			--------------------野外场景地图
			Table_GetMapName(9),				--洛道
			Table_GetMapName(10),				--寇岛
			Table_GetMapName(12),				--枫华
			Table_GetMapName(13),				--金水
			Table_GetMapName(108),              --成都
			Table_GetMapName(100),              --白龙口
			Table_GetMapName(104),               --黑龙沼
		}
		szAllowMap_Force = ""
		szAllowMap_Wild = ""
		for i = 1, #tChestZoneTable do
			if i <= COMPASS_PANEL_SCHOOL_COUNT then
				szAllowMap_Force = szAllowMap_Force .. HORO_SYS_STRINGS.SCENE_BRACKETS:format(tChestZoneTable[i])
			else
				szAllowMap_Wild = szAllowMap_Wild .. HORO_SYS_STRINGS.SCENE_BRACKETS:format(tChestZoneTable[i])
			end
		end
        CompassPanel.UptatePanelPos()
	end
	
	local hPlayer = GetClientPlayer()
	if hPlayer then
		local dwCurrentMapID = hPlayer.GetScene().dwMapID
		local szMapName = Table_GetMapName(dwCurrentMapID)
		bOutScene = true
		for i = 1, #tChestZoneTable do
			if tChestZoneTable[i] == szMapName then
				bOutScene = false
				break
			end
		end
	end
end

function CompassPanel.ClosePanel()
	local frame = Station.Lookup("Normal/CompassPanel")
	if not frame then
		return
	end
	frame:Hide()
	CompassPanel.bOpen = false
end

function CompassPanel.IsOpened()
	local frame = Station.Lookup("Normal/CompassPanel")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end

function CompassPanel_IsChestsCanClick()
    if not CompassPanel.IsOpened() then
       return false;
    end
    
    local bEnable = CompassPanel.frameSelf:Lookup("Btn_Chests"):IsEnabled();
    return bEnable
end

function CompassPanel_RequestHoroSysUpdateLoc()
    if dwFindChestCDDelay == 0 then
        RemoteCallToServer("OnHoroSysUpdateLocRequest")
    end
    dwFindChestCDDelay = 16
end

-- CompassPanel.OpenPanel()