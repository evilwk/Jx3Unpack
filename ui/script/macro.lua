---------------------------------------
--------------宏相关操作---------------
------Created by Hu Chang Yin----------
------	  肠断春江欲尽头	 ----------
------	  杖藜徐步立芳洲	 ----------
------	  颠狂柳絮随风去	 ----------
------	  轻薄桃花逐水流	 ----------
---------------------------------------

local aCommand = {}
local aCommandHelp = {}
local aDelayCall = {}
local aXCast = {}
g_Macro = {}
g_MacroInfo = {}
RegisterCustomData("g_Macro")

local bLoadedMacro = false
local function LoadMacro()
	if bLoadedMacro then
		return
	end
	bLoadedMacro = true

	local szRegion, szServer = GetUserServer(); 
	local szPath =  GetUserAccount() .. "\\" .. szRegion .. "\\" .. szServer .. "_" .. GetUserRoleName() .. ".dat"
	
	local byCustomData = LoadDataFromFile(szPath)
	if byCustomData then
		if IsEncodedData(byCustomData) then
			byCustomData = DecodeData(byCustomData)
		end
		
		if byCustomData then
			local tCustomData = {}
			local funcData = loadstring(byCustomData)
			if funcData then
				local tFuncEnv = {}
				setfenv(funcData, tFuncEnv)
				funcData()
				tCustomData = tFuncEnv._custom_data_
			end
			
			if tCustomData["g_Macro"] then
				g_Macro = tCustomData["g_Macro"]
			end						
		end
	end
end

RegisterEvent("PLAYER_ENTER_GAME", LoadMacro)

local Condition = {}

function Condition.exists()
	local dwTargetType, dwTargetID = GetClientPlayer().GetTarget()
	return (dwTargetType == TARGET.PLAYER or dwTargetType == TARGET.NPC) and dwTargetID ~= 0
end

function Condition.noexists()
	return not Condition.exists()
end

function Condition.dead()
	local dwTargetType, dwTargetID = GetClientPlayer().GetTarget()
	if dwTargetType == TARGET.PLAYER then
		local player = GetPlayer(dwTargetID)
		if player and player.nMoveState == MOVE_STATE.ON_DEATH then
			return true
		end
	end 
	return false
end

function Condition.nodead()
	local dwTargetType, dwTargetID = GetClientPlayer().GetTarget()
	if dwTargetType == TARGET.PLAYER then
		local player = GetPlayer(dwTargetID)
		if player and player.nMoveState ~= MOVE_STATE.ON_DEATH then
			return true
		end
	elseif dwTargetType == TARGET.NPC then
		return true
	end 
	return false	
end

function Condition.ally()
	local player = GetClientPlayer()
	local dwTargetType, dwTargetID = player.GetTarget()
	if dwTargetType == TARGET.PLAYER or dwTargetType == TARGET.NPC then
		return IsAlly(player.dwID, dwTargetID)
	end
	return false
end

function Condition.enemy()
	local player = GetClientPlayer()
	local dwTargetType, dwTargetID = player.GetTarget()
	if dwTargetType == TARGET.PLAYER or dwTargetType == TARGET.NPC then
		return IsEnemy(player.dwID, dwTargetID)
	end
	return false
end

function Condition.neutrality()
	local player = GetClientPlayer()
	local dwTargetType, dwTargetID = player.GetTarget()
	if dwTargetType == TARGET.PLAYER or dwTargetType == TARGET.NPC then
		return IsNeutrality(player.dwID, dwTargetID)
	end
	return false
end

function Condition.combat()
	return GetClientPlayer().bFightState
end

function Condition.nocombat()
	return not GetClientPlayer().bFightState
end

function Condition.mounted()
	return GetClientPlayer().bOnHorse
end

function Condition.unmounted()
	return not GetClientPlayer().bOnHorse
end

function Condition.life(szLife)
	local fLife = tonumber(szLife)
	local player = GetClientPlayer()
	if player.nMaxLife > 0 and player.nCurrentLife / player.nMaxLife <= fLife then
		return true
	end
	return false
end

function Condition.mana(szMana)
	local fMana = tonumber(szMana)
	local player = GetClientPlayer()
	if player.nMaxMana > 0 and player.nCurrentMana / player.nMaxMana <= fMana then
		return true
	end
	return false
end

function Condition.rage(szRage)
	local fRage = tonumber(szRage)
	local player = GetClientPlayer()
	if player.nMaxRage > 0 and player.nCurrentRage / player.nMaxRage <= fRage then
		return true
	end
	return false
end

function Condition.accumulate(szAccumulate)
	local fAccumulate = tonumber(szAccumulate)
	local player = GetClientPlayer()
	if player.nAccumulateValue >= fAccumulate then
		return true
	end
	return false
end

function Condition.lessaccumulate(szAccumulate)
	local fAccumulate = tonumber(szAccumulate)
	local player = GetClientPlayer()
	if player.nAccumulateValue < fAccumulate then
		return true
	end
	return false
end

function Condition.buff(szBuff)
	local aBuff = {}
	szBuff = szBuff.."|"
	local nEnd = StringFindW(szBuff, "|")
	while nEnd do
		local s = string.sub(szBuff, 1, nEnd - 1)
		if s ~= "" then
			s = StringReplaceW(s, " ", "")		
		end
		if s ~= "" then
			aBuff[s] = true
		end
		szBuff = string.sub(szBuff, nEnd + 1, -1)
		nEnd = StringFindW(szBuff, "|")
	end
	local t = GetClientPlayer().GetBuffList() or {}
	local nIndex = 0
	for k, v in ipairs(t) do
		local szName = Table_GetBuffName(v.dwID, v.nLevel)
		if szName and aBuff[szName] then
			return true
		end
	end
	return false
end

function Condition.nobuff(szBuff)
	return not Condition.buff(szBuff)
end

local function TestCondition(szCondition)
	if not szCondition or szCondition == "" then
		return true
	end
	szCondition = StringLowerW(szCondition)..","
	local nEnd = StringFindW(szCondition, ",")
	while nEnd do
		local s = string.sub(szCondition, 1, nEnd - 1)
		if s ~= "" then
			s = StringReplaceW(s, " ", "")
		end
		local sParam = ""
		local i = StringFindW(s, ":")
		if i then
			sParam = string.sub(s, i + 1, -1)
			s = string.sub(s, 1, i - 1)
		end
		if Condition[s] and not Condition[s](sParam) then
			return false
		end
		szCondition = string.sub(szCondition, nEnd + 1, -1)
		nEnd = StringFindW(szCondition, ",")
	end
		
	return true
end

local function GetMacroInfo(szMacro)
	local szCD, szCDType, szCondition, szTip, szPureMacro = "", "", "", "", ""

	szMacro = "\n"..szMacro
	local i, j = StringFindW(szMacro, "\n#")
	while i do
		szPureMacro = szPureMacro..string.sub(szMacro, 1, i - 1)
		szMacro = string.sub(szMacro, j, -1)
		i, j = StringFindW(szMacro, "\n#")
		local i1, j1 = StringFindW(szMacro, "\n/")
		if not i or (i1 and i > i1) then
			i, j = i1, j1
		end
		local szContent = nil		
		if i then
			szContent = string.sub(szMacro, 1, i - 1)
			szMacro = string.sub(szMacro, i, -1)
		else
			szContent = szMacro
			szMacro = ""
		end
		i, j = StringFindW(szContent, " ")
		if i then
			local szKey = StringLowerW(string.sub(szContent, 1, i - 1))
			if szKey == "#tip" then
				szTip = szTip..string.sub(szContent, j + 1, -1)
			elseif szKey == "#cd" then
				szCD = string.sub(szContent, j + 1, -1)
			elseif szKey == "#condition" then
				szCondition = string.sub(szContent, j + 1, -1)
			end
		end
		i, j = StringFindW(szMacro, "\n#")
	end
	szPureMacro = szPureMacro..szMacro
	
	local t = {}
	
	i = StringFindW(szCD, ":")
	if i then
		szCDType = string.sub(szCD, 1, i - 1)
		szCD = string.sub(szCD, i + 1, -1)
	end
	while string.sub(szCD, 1, 1) == " " do
		szCD = strin.sub(szCD, 2, -1)
	end
	while string.sub(szCD, -1, -1) == " " do
		szCD = strin.sub(szCD, 1, -2)
	end
	t.szCD = szCD
	if szCDType ~= "" then
		szCDType = StringReplaceW(szCDType, " ", "")
	end
	t.szCDType = StringLowerW(szCDType)
	
	if szCondition ~= "" then
		szCondition = StringReplaceW(szCondition, " ", "")
	end
	t.szCondition = szCondition
	
	t.szTip = szTip
	t.szPureMacro = szPureMacro
	return t
end

function GetMacroName(dwID)
	local t = g_Macro[dwID]
	if t then
		return t.szName or ""
	end
	return ""
end

function GetMacroIcon(dwID)
	local t = g_Macro[dwID]
	if t then
		return t.nIcon or 0
	end
end

function GetMacroDesc(dwID)
	local t = g_Macro[dwID]
	if t then
		local tInfo = g_MacroInfo[dwID]
		if not tInfo then
			tInfo = GetMacroInfo(GetMacroContent(dwID))
			g_MacroInfo[dwID] = tInfo
		end
		
		local szOrgDesc = t.szDesc or ""
		local szAddDesc = tInfo.szTip or ""

		return szOrgDesc, szAddDesc 
	end
	return "", ""
end

function GetMacroContent(dwID)
	local t = g_Macro[dwID]
	if t then
		return t.szMacro or ""
	end
	return ""
end

function IsMacroRemoved(dwID)
	local t = g_Macro[dwID]
	if not t or t.bRemoved then
		return true
	end
	return false
end

local function GetPureMacro(szMacro)
	local szPureMacro = ""

	szMacro = "\n"..szMacro
	local i, j = StringFindW(szMacro, "\n#")
	while i do
		szPureMacro = szPureMacro..string.sub(szMacro, 1, i - 1)
		szMacro = string.sub(szMacro, j, -1)
		i, j = StringFindW(szMacro, "\n#")
		local i1, j1 = StringFindW(szMacro, "\n/")
		if not i or (i1 and i > i1) then
			i, j = i1, j1
		end
		if i then
			szMacro = string.sub(szMacro, i, -1)
		else
			szMacro = ""
		end
		i, j = StringFindW(szMacro, "\n#")
	end
	szPureMacro = szPureMacro..szMacro
	
	return szPureMacro
end

function UpdateMacroCDProgress(player, box)
	local nLeftTime
	local dwID = box:GetObjectData()
	local t = g_MacroInfo[dwID]
	if not t then
		t = GetMacroInfo(GetMacroContent(dwID))
		g_MacroInfo[dwID] = t
	end

	box:EnableObject(TestCondition(t.szCondition))

	if not t.szCD or t.szCD == "" then
		box:SetObjectCoolDown(false)
		return
	end
	
	if t.szCDType == "item" then
		local tItem = g_ItemNameToID[t.szCD]
		if not tItem then
			box:SetObjectCoolDown(false)
			return nLeftTime
		end
		
		local bCool, nLeft, nTotal = player.GetItemCDProgress(0, tItem[1], tItem[2])
	    if bCool then
	        if nLeft == 0 and nTotal == 0 then
	            if box:IsObjectCoolDown() then
	                box:SetObjectCoolDown(false)
	                box:SetObjectSparking(true)
	            end
	        else
	            box:SetObjectCoolDown(true)
	            box:SetCoolDownPercentage(1 - nLeft / nTotal)
	        end
			nLeftTime = nLeft
	    else
	        box:SetObjectCoolDown(false)
	    end
	    return
	end

	local dwSkillID = g_SkillNameToID[t.szCD]
	if not dwSkillID then
		box:EnableObject(false)
		box:SetObjectCoolDown(false)
		return		
	end

	local dwSkillLevel = player.GetSkillLevel(dwSkillID)
	if not dwSkillLevel or dwSkillLevel == 0 then
		box:EnableObject(false)
		box:SetObjectCoolDown(false)
		return	nLeftTime	
	end
	
	local skill = GetSkill(dwSkillID, dwSkillLevel)
	if not skill or not skill.UITestCast(player.dwID, IsSkillCastMyself(skill)) then
		box:EnableObject(false)
	end
	
	local bCool, nLeft, nTotal = player.GetSkillCDProgress(dwSkillID, dwSkillLevel)
    if bCool then
        if nLeft == 0 and nTotal == 0 then
            if box:IsObjectCoolDown() then
                box:SetObjectCoolDown(false)
                box:SetObjectSparking(true)
            end
        else
            box:SetObjectCoolDown(true)
            box:SetCoolDownPercentage(1 - nLeft / nTotal)
        end
		nLeftTime = nLeft
    else
        box:SetObjectCoolDown(false)
    end
	
	return nLeftTime
end

function CanUseMacro(dwID)
	local t = g_MacroInfo[dwID]
	if not t then
		t = GetMacroInfo(GetMacroContent(dwID))
		g_MacroInfo[dwID] = t
	end

	return TestCondition(t.szCondition)
end

function ExcuteMacroByID(dwID)
	local szMacro = GetMacroContent(dwID)
	if szMacro and szMacro ~= "" then
		ExcuteMacro(szMacro)
	end
end

function RemoveMacro(dwID)
	if g_Macro[dwID] then
		g_Macro[dwID] = {bRemoved = true}
	end
	local argS = arg0
	arg0 = dwID
	FireEvent("ON_REMOVE_MACRO")
	arg0 = argS
end

function AddMacro(szName, nIcon, szDesc, szMacro)
	for k, v in ipairs(g_Macro) do
		if v.bRemoved then
			v.szName = szName
			v.nIcon = nIcon
			v.szDesc = szDesc
			v.szMacro = szMacro
			v.bRemoved = nil
			return k
		end
	end
	
	table.insert(g_Macro, {szName = szName, nIcon = nIcon, szDesc = szDesc, szMacro = szMacro})
	return #g_Macro
end

function SetMacro(dwID, szName, nIcon, szDesc, szMacro)
	if not g_Macro[dwID] then
		return
	end
	g_Macro[dwID] = {szName = szName, nIcon = nIcon, szDesc = szDesc, szMacro = szMacro}
	g_MacroInfo[dwID] = nil
	local argS = arg0
	arg0 = dwID
	FireEvent("ON_CHANGE_MACRO")
	arg0 = argS
end

function OutputMacroTip(dwID, Rect)
	local szName = GetMacroName(dwID)
	if not szName or szName == "" then
		return
	end
	local szTip = GetFormatText(szName.."\n", 31)
	szTip = szTip..GetFormatText(g_tStrings.STR_MARCO.."\n", 106)
	local szdesc, szdesc1 = GetMacroDesc(dwID)
	if szdesc1 ~= "" then
		if szdesc == "" then
			szdesc = szdesc1
		else
			szdesc = szdesc.."\n"..szdesc1
		end
	end
	szTip = szTip..GetFormatText(szdesc, 100)
	OutputTip(szTip, 400, Rect)
end

function AppendCommand(key, fn, szHelp)
	key = StringLowerW(key)
	aCommand["/"..key] = fn
	if szHelp then
		aCommandHelp[key] = szHelp
	end
end

local function ProcessCommand(szCmd, szLeft)
	local szKey, szParam
	local i = StringFindW(szCmd, " ")
	if i then
		szKey = string.sub(szCmd, 1, i - 1)
		szParam = string.sub(szCmd, i + 1, -1)
	else
		szKey, szParam = szCmd, ""
	end
	szKey = StringLowerW(szKey)

	if szKey and aCommand[szKey] then
		local r1, r2 = aCommand[szKey](szParam, szLeft)
		if r1 == nil then
			r1, r2 = true, nil
		end
		return r1, r2
	end
	return false
end

local function GetCommand(szMacro)
	local szCmd, szLeft
	local i, j = StringFindW(szMacro, "\n/")
	if i then
		szCmd = string.sub(szMacro, 1, i - 1)
		szLeft = string.sub(szMacro, j, - 1)
	else
		szCmd, szLeft = szMacro, ""
	end
	while string.sub(szCmd, -1, -1) == "\n" do
		szCmd = string.sub(szCmd, 1, -2)
	end
	return szCmd, szLeft
end

local function GetMacroFunction()
	local tInfo = _g_CurrentExcuteMacro
	if not tInfo then
		tInfo = {}
	end
	local fnExcute = function(szMacro)
		local r = false
		if not tInfo.bInExcute then
			if not Station.IsInUserAction() then
				return r
			end
			tInfo.bInExcute = true
			tInfo.aOnce = {}
		end

		r = true
		_g_CurrentExcuteMacro = tInfo
		local szCmd, szLeft = "", szMacro
		while true do
			szCmd, szLeft = GetCommand(szLeft)
			if szCmd == "" then
				if szLeft == "" then
					break
				end
			else
				local r1, r2 = ProcessCommand(szCmd, szLeft)
				if not r1 then
					r = false
					break
				end
				if r2 and r2 == "delay" then
					r = false
					break
				end
			end
		end
		_g_CurrentExcuteMacro = nil
		return r
	end
	return fnExcute
end

function ExcuteMacro(szMacro)
	szMacro = GetPureMacro(szMacro)
	return GetMacroFunction()(szMacro)
end

function Macro_OnActive()
	local nTime = GetTickCount()
	local nCount = #aDelayCall
	for i = nCount, 1, -1 do
		local v = aDelayCall[i]
		if nTime >= v[1] then
			local f = v[2]
			table.remove(aDelayCall, i)
			f()
		end
	end
end

function DelayCall(nTime, fn)
	table.insert(aDelayCall, {GetTickCount() + nTime * 1000, fn})
end

local function ExucteScriptCommand(szScript)
	local f = loadstring(szScript)
	if f then
		setfenv(f, _AddOn)
		local r = xpcall(f, MsgError)
		if r ~= true then
			return false
		end
	end
end

local function ExcuteDelayCommand(szDelayTime, szLeftMacro)
	local f = GetMacroFunction()
	DelayCall(tonumber(szDelayTime), function() f(szLeftMacro) end)
	return true, "delay"
end

local nLastTime = 0
local function Roll(szRollNumber)
	local nCurrentTime = GetCurrentTime()
	if nCurrentTime - nLastTime < 2 then
		return
	end
	nLastTime = nCurrentTime
	--[[
	宏命令帮助：如/ROLL ? 或者/ROLL HELP，？支持中英文，HELP支持大小写，希望以后所有的宏命令都统一加上帮助。
	--]]
	--
	local lowRollNumber = string.lower(szRollNumber)
	if lowRollNumber == "help" or lowRollNumber == "?" or lowRollNumber == "？" then
		OutputMessage("MSG_SYS", tHelp["roll"] .. "\n")
		return
	end
	--帮助结束
	local nDefaultMin, nDefaultMax = 1, 100

	if not szRollNumber or szRollNumber == "" then							--没有参数
		RemoteCallToServer("ClientNormalRoll", nDefaultMin, nDefaultMax)
		return
	end

	local szRolllow, szRollHigh = szRollNumber:match("^%s*(%d+)%s*(%d*)%s*$")

	if not szRolllow or szRolllow == "" then								--没有参数
		RemoteCallToServer("ClientNormalRoll", nDefaultMin, nDefaultMax)
		return
	end

	if not szRollHigh or szRollHigh == "" then								--是否有第二个参数
		szRollHigh = szRolllow
		szRolllow = tostring(nDefaultMin)
	end

	local nRolllow = tonumber(szRolllow:sub(1,5))
	local nRollHigh = tonumber(szRollHigh:sub(1,5))

	if nRolllow and nRollHigh and nRolllow < nRollHigh then				--第二个参数是否合法
		RemoteCallToServer("ClientNormalRoll", nRolllow, nRollHigh)
	else
		RemoteCallToServer("ClientNormalRoll", nDefaultMin, nDefaultMax)
	end
end

local function Help(szWhichOne)
	local szLowString = string.lower(szWhichOne)
	local szHelp = aCommandHelp[szLowString]
	if not szHelp or szHelp == "" then
		szHelp = g_tStrings.HELPME_HELP
	end
	
	if szHelp and szHelp ~= "" then
		OutputMessage("MSG_SYS", szHelp .. "\n")
	end	
end

local function GetCondition(szContent)
	local szSkill, szCondition = "", ""
	local nEnd = StringFindW(szContent, "[")
	if nEnd then
		szContent = string.sub(szContent, nEnd + 1, -1)
		nEnd = StringFindW(szContent, "]")
		if nEnd then
			szSkill = string.sub(szContent, nEnd + 1, -1)
			szCondition = string.sub(szContent, 1, nEnd - 1)
		end
	else
		szSkill = szContent
	end
	return szCondition, szSkill
end

local function MacroTarget(szContent)
	if _g_CurrentExcuteMacro.aOnce["Target"] then
		return
	end

	local szCondition, szContent = GetCondition(szContent)
	if TestCondition(szCondition) then
		if szContent ~= "" then
			szContent = StringReplaceW(szContent, " ", "")
		end
		if szContent == GetClientPlayer().szName then
			SelectSelf()
			return
		end
		
		local aPlayer = GetAllPlayer() or {}
		for k, v in pairs(aPlayer) do
			if v.szName == szContent then
				SelectTarget(TARGET.PLAYER, v.dwID)
				return
			end
		end
		local aNpc = GetAllNpc() or {}
		for k, v in pairs(aNpc) do
			if v.szName == szContent then
				SelectTarget(TARGET.NPC, v.dwID)
				return
			end
		end
	end
	_g_CurrentExcuteMacro.aOnce["Target"] = true
end

local function Cast(szContent)
	if _g_CurrentExcuteMacro.aOnce["CastSkillOrUseItem"] then
		return
	end
	local szCondition, szSkill = GetCondition(szContent)
	if TestCondition(szCondition) then
		while string.sub(szSkill, 1, 1) == " " do
			szSkill = string.sub(szSkill, 2, -1)
		end
	
		while string.sub(szSkill, -1, -1) == " " do
			szSkill = string.sub(szSkill, 1, -2)
		end	

		local dwID = g_SkillNameToID[szSkill]
		if dwID then
			OnAddOnUseSkill(dwID, 1)
		end
	end
	
	_g_CurrentExcuteMacro.aOnce["CastSkillOrUseItem"] = true
end

local function GetXCastTable(szContent)
	if aXCast[szContent] then
		return aXCast[szContent]
	end
	
	local t = {}
	aXCast[szContent] = t	
	
	t.aSkill = {}
	t.nResetTime = nil
	t.bCtrl = false
	t.bShift = false
	t.bAlt = false
	t.dwTime = 0
	
	local i, j = StringFindW(szContent, "=")
	if i then
		local szKey = string.sub(szContent, 1, j - 1)
		while string.sub(szKey, -1, -1) == " " do
			szKey = string.sub(szKey, 1, -2)
		end
		while string.sub(szKey, 1, 1) == " " do
			szKey = string.sub(szKey, 2, -1)
		end
		szKey = StringLowerW(szKey)
		if szKey == "reset" then
			szContent = string.sub(szContent, j + 1, -1)
			while true do
				while string.sub(szContent, 1, 1) == " " do
					szContent = string.sub(szContent, 2, -1)
				end
				local szSub = StringLowerW(string.sub(szContent, 1, 5))
				if szSub == "shift" then
					t.bShift = true
					szContent = string.sub(szContent, 6, -1)
				elseif string.sub(szSub, 1, 4) == "ctrl" then
					t.bCtrl = true
					szContent = string.sub(szContent, 5, -1)
				elseif string.sub(szSub, 1, 3) == "alt" then
					t.bAlt = true
					szContent = string.sub(szContent, 4, -1)
				else
					local i1, j1 = string.find(szContent, "%d+")
					if i1 and i1 == 1 then
						t.nResetTime = tonumber(string.sub(szContent, i1, j1))
						szContent = string.sub(szContent, j1 + 1, -1)
					end
				end
				while string.sub(szContent, 1, 1) == " " do
					szContent = string.sub(szContent, 2, -1)
				end
				if string.sub(szContent, 1, 1) ~= "|" then
					break
				end
				szContent = string.sub(szContent, 2, -1)
			end
		end
	end	
	
	
	szContent = szContent..","
	local nEnd = StringFindW(szContent, ",")
	while nEnd do
		local s = string.sub(szContent, 1, nEnd - 1)
		while string.sub(s, 1, 1) == " " do
			s = string.sub(s, 2, 1)
		end
		while string.sub(s, -1, -1) == " " do
			s = string.sub(s, 1, -2)
		end
		
		if s ~= "" then
			table.insert(t.aSkill, s)
		end
		szContent = string.sub(szContent, nEnd + 1, -1)
		nEnd = StringFindW(szContent, ",")
	end
	return t
end

local function XCast(szContent)
	if _g_CurrentExcuteMacro.aOnce["CastSkillOrUseItem"] then
		return
	end

	local t = GetXCastTable(szContent)
	local dwTime = GetTickCount()
	if t.nResetTime and dwTime - t.dwTime >= t.nResetTime * 1000 then
		t.nIndex = nil
	end
	
	if t.bCtrl and IsCtrlKeyDown() then
		t.nIndex = nil
	end
	
	if t.bShift and IsShiftKeyDown() then
		t.nIndex = nil
	end
	
	if t.bAlt and IsAltKeyDown() then
		t.nIndex = nil
	end
	
	t.dwTime = dwTime 
	if not t.nIndex then
		t.nIndex = 1
	else
		t.nIndex = t.nIndex + 1
		if not t.aSkill[t.nIndex] then
			t.nIndex = 1
		end
	end
	
	local szSkill = t.aSkill[t.nIndex]
	if szSkill then
		local dwID = g_SkillNameToID[szSkill]
		if dwID then
			OnAddOnUseSkill(dwID, 1)
		end
	end
	
	_g_CurrentExcuteMacro.aOnce["CastSkillOrUseItem"] = true
end

local function Use(szContent)
	if _g_CurrentExcuteMacro.aOnce["CastSkillOrUseItem"] then
		return
	end

	local szCondition, szItem = GetCondition(szContent)
	if TestCondition(szCondition) then
		while string.sub(szItem, 1, 1) == " " do
			szItem = string.sub(szItem, 2, -1)
		end
	
		while string.sub(szItem, -1, -1) == " " do
			szItem = string.sub(szItem, 1, -2)
		end	
	
		local t = g_ItemNameToID[szItem]
		if t then
	    	local dwBox, dwX = GetClientPlayer().GetItemPos(t[1], t[2])
	    	if dwBox and dwX then
	    		OnUseItem(dwBox, dwX)
	    	end
		end
	end
	
	_g_CurrentExcuteMacro.aOnce["CastSkillOrUseItem"] = true
end

local nLastTime = 0
local function TigerYellFuncFactory(nActionID)
	return function()
		local player = GetClientPlayer()
		local _, dwTargetID = player.GetTarget()
		if IsPlayer(dwTargetID) then
			return
		end
		local target = GetNpc(dwTargetID)
		if not target then
			return
		end
		if target.dwTemplateID ~= 6823 then
			return
		end
		local nCurrentTime = GetCurrentTime()
		if nCurrentTime - nLastTime <= 5 then
			return
		end
		nLastTime = nCurrentTime
		RemoteCallToServer("OnSpringTigerCommand", nActionID)
	end
end
--兔子跳脚本(响应兔子和兔子阿甘)
local function RabbitJumpFuncFactory(nActionID)
	return function()
		local player = GetClientPlayer()
		local _, dwTargetID = player.GetTarget()
		if IsPlayer(dwTargetID) then
			return
		end
		local target = GetNpc(dwTargetID)
		if not target then
			return
		end
		if target.dwTemplateID ~= 10221 and target.dwTemplateID ~= 10488 and target.dwTemplateID ~= 10223 and target.dwTemplateID ~= 10417 and target.dwTemplateID ~= 10222 and target.dwTemplateID ~= 10489 then
			return
		end
		
		local nCurrentTime = GetCurrentTime()
		if nCurrentTime - nLastTime <= 5 then
			return
		end
		nLastTime = nCurrentTime
		RemoteCallToServer("OnSpringRabbitCommand", nActionID)
	end
end
--灯笼龙指令脚本(响应龙年灯笼龙)
local function DragonLightFuncFactory(nActionID)
	return function()
		local player = GetClientPlayer()
		local _, dwTargetID = player.GetTarget()
		if IsPlayer(dwTargetID) then
			return
		end
		local target = GetNpc(dwTargetID)
		if not target then
			return
		end
		if target.dwTemplateID ~= 16607 and target.dwTemplateID ~= 16608 and target.dwTemplateID ~= 16644 then
			return
		end
		
		local nCurrentTime = GetCurrentTime()
		if nCurrentTime - nLastTime <= 5 then
			return
		end
		nLastTime = nCurrentTime
		RemoteCallToServer("On_ChunjieDragon_DoAction", nActionID)
	end
end

local nPlayedCheckTime = 0
local function Played()
	local nCurrentTime = GetCurrentTime()
	if (nCurrentTime - nPlayedCheckTime) < 1 then
		return
	end
	nPlayedCheckTime = nCurrentTime

	RemoteCallToServer("OnPlayedCheckCommand")
end
local function CreateTime()
	local nCurrentTime = GetCurrentTime()
	if (nCurrentTime - nPlayedCheckTime) < 1 then
		return
	end
	nPlayedCheckTime = nCurrentTime

	RemoteCallToServer("OnCreateTimeCheckCommand")
end

local function TangMenPig(nActionID)
	return function()
		local player = GetClientPlayer()
		if not player then 
			return 
		end 
		local _, dwTargetID = player.GetTarget()
		local target = GetNpc(dwTargetID)
		if not target then
			return
		end
	
		if not (target.dwTemplateID == 15549 or target.dwTemplateID == 15550 or target.dwTemplateID == 15560
			or target.dwTemplateID == 15559 or target.dwTemplateID == 15561) then
			return
		end
		RemoteCallToServer("On_TangMenPig_DoAction", nActionID)
	end
end

AppendCommand("script", ExucteScriptCommand)
AppendCommand("delay", ExcuteDelayCommand)
AppendCommand("showerrmsg", function(szShow) g_ShowLuaErrMsg = szShow == "true" end)
AppendCommand("roll", Roll, g_tStrings.HELPME_ROLL)
AppendCommand("help", Help, g_tStrings.HELPME_HELP)
AppendCommand("cast", Cast)
AppendCommand("xcast", XCast)
AppendCommand("target", MacroTarget)
AppendCommand("use", Use)

AppendCommand(g_tStrings.CHUNJIE_TIGER_COMMAND[1], TigerYellFuncFactory(10150))
AppendCommand(g_tStrings.CHUNJIE_TIGER_COMMAND[2], TigerYellFuncFactory(10151))
AppendCommand(g_tStrings.CHUNJIE_TIGER_COMMAND[3], TigerYellFuncFactory(10152))
AppendCommand(g_tStrings.CHUNJIE_TIGER_COMMAND[4], TigerYellFuncFactory(10153))
AppendCommand(g_tStrings.CHUNJIE_TIGER_COMMAND[5], TigerYellFuncFactory(10154))

--以下的代码是阿甘的动作代码
AppendCommand(g_tStrings.CHUNJIE_RABBIT_COMMAND[1], RabbitJumpFuncFactory(10150))
AppendCommand(g_tStrings.CHUNJIE_RABBIT_COMMAND[2], RabbitJumpFuncFactory(10151))
AppendCommand(g_tStrings.CHUNJIE_RABBIT_COMMAND[3], RabbitJumpFuncFactory(10152))
AppendCommand(g_tStrings.CHUNJIE_RABBIT_COMMAND[4], RabbitJumpFuncFactory(10154))--10154只作为标记传递信息
AppendCommand(g_tStrings.CHUNJIE_RABBIT_COMMAND[5], RabbitJumpFuncFactory(10153))

--以下代码是灯笼龙的动作代码
AppendCommand(g_tStrings.CHUNJIE_DRAGON_COMMAND[1], DragonLightFuncFactory(10030))
AppendCommand(g_tStrings.CHUNJIE_DRAGON_COMMAND[2], DragonLightFuncFactory(10031))
AppendCommand(g_tStrings.CHUNJIE_DRAGON_COMMAND[3], DragonLightFuncFactory(10032))
AppendCommand(g_tStrings.CHUNJIE_DRAGON_COMMAND[4], DragonLightFuncFactory(10033))
AppendCommand(g_tStrings.CHUNJIE_DRAGON_COMMAND[5], DragonLightFuncFactory(10001))

--以下的代码是唐门猪的动作代码
AppendCommand(g_tStrings.TangMenPig[1], TangMenPig(10154))
AppendCommand(g_tStrings.TangMenPig[2], TangMenPig(10155))
AppendCommand(g_tStrings.TangMenPig[3], TangMenPig(10156))
AppendCommand(g_tStrings.TangMenPig[4], TangMenPig(10157))
AppendCommand(g_tStrings.TangMenPig[5], TangMenPig(10158))

AppendCommand("played", Played, g_tStrings.HELPME_PLAYED)
AppendCommand(g_tStrings.COMMAND_PLAYED.PLAYED, Played, g_tStrings.HELPME_PLAYED)
AppendCommand("createtime", CreateTime, g_tStrings.HELPME_CREATETIME)
AppendCommand(g_tStrings.COMMAND_PLAYED.CREATETIME, CreateTime, g_tStrings.HELPME_CREATETIME)


