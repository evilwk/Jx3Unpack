SkillTipPanel = 
{
	nItemCount,
	tActionBarInUse = {},
	tBuffTipEndFrame = {},
	tRefreshCD = {},
	tTipDatas = {},
	tSFXFlag = {},
	tSFXWndHanlde = {},
	
	DefaultAnchor = {s = "TOPLEFT", r = "CENTER",  x = -385, y = 202},
	Anchor = {s = "TOPLEFT", r = "CENTER", x = -385, y = 202},
}

SkillTipPanel.bShowPanel = true

RegisterCustomData("SkillTipPanel.Anchor")
RegisterCustomData("SkillTipPanel.bShowPanel")

local function CheckBuff(hTarget, szBuffID, szLevel, szStackNum, szSource, dwSkillID)
	local bEnable = false
	if not hTarget then 
		return bEnable
	end
	
	local tBuff = hTarget.GetBuffList()
	if not tBuff then
		return bEnable
	end
	
	local dwClientPlayerID = UI_GetClientPlayerID()
	local dwBuffID = tonumber(szBuffID)
	local dwLevel = tonumber(szLevel)
	local dwStackNum = tonumber(szStackNum) or 0
	
	for _, v in pairs(tBuff) do
		if szSource ~= "MYSELF" or v.dwSkillSrcID == dwClientPlayerID then 
			if v.dwID == dwBuffID and v.nLevel >= dwLevel and v.nStackNum > dwStackNum then 
				if SkillTipPanel.tBuffTipEndFrame[dwSkillID] then 
					if SkillTipPanel.tBuffTipEndFrame[dwSkillID] > v.nEndFrame then
						SkillTipPanel.tBuffTipEndFrame[dwSkillID] = v.nEndFrame
					end
				else
					SkillTipPanel.tBuffTipEndFrame[dwSkillID] = v.nEndFrame
				end
				
				bEnable = true
				break
			end
		end
	end
	return bEnable
end

local function CheckLife(hTarget, szCondition, szPercent)
	local bEnable = false
	
	if not hTarget then 
		return bEnable
	end
			
	if hTarget.nMoveState == MOVE_STATE.ON_DEATH then
		return bEnable
	end
	
	local dwPlayerLifePercent = hTarget.nCurrentLife / hTarget.nMaxLife
	local dwPercent = szPercent / 100
	
	if szCondition == "+" then 
		if dwPercent < dwPlayerLifePercent then 
			bEnable = true;
		end
	elseif szCondition == "-" then 
		if dwPercent > dwPlayerLifePercent then 
			bEnable = true;
		end
	end
	
	return bEnable
end

local function CheckMana(hTarget, szCondition, szPercent)
	local bEnable = false
	
	if not hTarget then 
		return bEnable
	end
	
	if hTarget.nCurrentLife == 1 then
		return bEnable
	end
	
	local dwPlayerManaPercent = hTarget.nCurrentMana / hTarget.nMaxMana
	local dwPercent = szPercent / 100
	
	if szCondition == "+" then 
		if dwPercent < dwPlayerManaPercent then 
			bEnable = true;
		end
	elseif szCondition == "-" then 
		if dwPercent > dwPlayerManaPercent then 
			bEnable = true;
		end
	end
	
	return bEnable
end

local function CheckAccumulate(szAccumulateValue)
	local nAccumulateValue = tonumber(szAccumulateValue)
	local player = GetClientPlayer()
	if player.nAccumulateValue >= nAccumulateValue then 
		return true
	end	
	return false;
end

local function CheckDoSkill(szSkillID, szLevel)
	local dwSkillID = tonumber(szSkillID)
	local dwLevel = tonumber(szLevel)
	if dwSkillID == SkillTipPanel.nLastDoSkillID and dwLevel >= SkillTipPanel.nLastDoSkillLevel then
		return true
	end
	return false
end

local function IsCD(dwSkillID, dwSkillLevel)
	local player = GetClientPlayer()
	local bCool, nLeft, nTotal = player.GetSkillCDProgress(dwSkillID, dwSkillLevel)
	if bCool and nTotal > 24 then 
		return true
	end
	return false
end

local function CanDoSkill(dwSkillID, dwSkillLevel)
	local skill = GetSkill(dwSkillID, dwSkillLevel)
	if skill and skill.UITestCast(UI_GetClientPlayerID(), IsSkillCastMyself(skill)) then 
		return true
	end
	return false
end

local function CheckSkill(dwSkillID, nLevel)
	if dwSkillID == 0 then 
		return false
	end 
	
	local player = GetClientPlayer()
	local nSkillLevel = player.GetSkillLevel(dwSkillID)
	if nSkillLevel < nLevel then 
		return false
	end
	
	if IsCD(dwSkillID, nLevel) or not CanDoSkill(dwSkillID, nLevel) then
		return false
	end
	
	return true	
end

local function IsInParty(dwID)
	local player = GetClientPlayer()
	if player then
		return player.IsPlayerInMyParty(dwID)
	end
end

local function GetLeftTime(nEndFrame)
    local szResult = ""
    local nFont = 162
    local nLogic = GetLogicFrameCount()
    local nLeft = nEndFrame - nLogic
    local nH, nM, nS = GetTimeToHourMinuteSecond(nLeft, true)
    
    if nH >= 1 then
        if nM >= 1 or nS >= 1 then
            nH = nH + 1
        end
        szResult = nH .. ""
        nFont = 162
    elseif nM >= 1 then
        if nS >= 1 then
            nM = nM + 1
        end
        szResult = nM .. "'"
        nFont = 163
    else 
        szResult = nS .."''"
        nFont = 166
    end
    return szResult, nFont, nLeft
end

local function RefreshBox(frame)
	local handleBox = frame:Lookup("", "Handle_Box")
	local handleHotkeyText = frame:Lookup("", "Handle_HotkeyText")
	local handleNameText = frame:Lookup("", "Handle_NameText")
	
	local dwTickCount = GetTickCount()
	
	local nCount = SkillTipPanel.nItemCount
    for i = 0, nCount - 1, 1 do
		local tTipData = SkillTipPanel.tTipDatas[i+1]
		local hBox = handleBox:Lookup(i)
		local hHotkeyText = handleHotkeyText:Lookup(i)
		local hNameText = handleNameText:Lookup(i)
		if tTipData then 
			hBox.dwSkillID = tTipData.SkillID
			hBox.nLevel = tTipData.Level
			hBox:SetObject(UI_OBJECT_SKILL, tTipData.SkillID)
			hBox:SetObjectIcon(Table_GetSkillIconID(tTipData.SkillID, tTipData.Level))
			hBox.dwDelayTime = nil
				
			hHotkeyText:SetText(tTipData.szHotKey)
			hNameText:SetText(tTipData.szName)
			
			hBox:Show();
			hHotkeyText:Show()
			hNameText:Show()
		else
			hBox:SetAlpha(255)
			hBox:ClearObject()
			hBox:SetObjectPressed(0)
			hBox:SetObjectMouseOver(0)
			
			-- Remove时做延时
			hBox.dwDelayTime = dwTickCount + 500
			
			hHotkeyText:Hide()
			hNameText:Hide()
		end
	end
end

function SkillTipPanel.OnFrameCreate()
	this:RegisterEvent("BUFF_UPDATE")
	this:RegisterEvent("PLAYER_STATE_UPDATE")
	this:RegisterEvent("NPC_STATE_UPDATE")
	this:RegisterEvent("SKILL_MOUNT_KUNG_FU")
	this:RegisterEvent("UI_UPDATE_ACCUMULATE")
	this:RegisterEvent("DO_SKILL_CAST")
	this:RegisterEvent("TARGET_LOST")
	this:RegisterEvent("TARGET_CHANGE")
	this:RegisterEvent("FIGHT_HINT")
	
	this:RegisterEvent("UI_SCALED")
	this:RegisterEvent("ON_ENTER_CUSTOM_UI_MODE")
	this:RegisterEvent("ON_LEAVE_CUSTOM_UI_MODE")
	this:RegisterEvent("SKILL_TIP_ANCHOR_CHANGED")
	this:RegisterEvent("CUSTOM_DATA_LOADED")

	SkillTipPanel.Init(this)
	SkillTipPanel.UpdateAnchor(this)
	UpdateCustomModeWindow(this, g_tStrings.SKILLTIP_PANEL)
end

local function AdjustSFXFrame()
	SkillTipPanel.SFXFrame :SetPoint("CENTER", 0, 0, "CENTER", 0, 0);
	SkillTipPanel.SFXFrame :CorrectPos()
end

function SkillTipPanel.Init(frame)
	SkillTipPanel.SFXFrame = Wnd.OpenWindow("SFXFrame")
	AdjustSFXFrame()
	
	local hSFXWnd = SkillTipPanel.SFXFrame:Lookup("Wnd_SFX_1")
	table.insert(SkillTipPanel.tSFXWndHanlde, hSFXWnd)
	hSFXWnd:Hide()
	
	hSFXWnd = SkillTipPanel.SFXFrame:Lookup("Wnd_SFX_2")
	table.insert(SkillTipPanel.tSFXWndHanlde, hSFXWnd)
	hSFXWnd:Hide()
	
	hSFXWnd = SkillTipPanel.SFXFrame:Lookup("Wnd_SFX_3")
	table.insert(SkillTipPanel.tSFXWndHanlde, hSFXWnd)
	hSFXWnd:Hide()
	
	local handleBox = frame:Lookup("", "Handle_Box")
	SkillTipPanel.nItemCount = handleBox:GetItemCount()
end

function SkillTipPanel.OnItemLButtonDown()
	if this:GetType() == "Box" and not this.dwDelayTime then
		this:SetObjectPressed(1)
	end
end

function SkillTipPanel.OnItemRButtonDown()
	if this:GetType() == "Box" and not this.dwDelayTime then
		this:SetObjectPressed(1)
	end
end

function SkillTipPanel.OnItemLButtonUp()
	if this:GetType() == "Box"  then
		this:SetObjectPressed(0)
	end
end

function SkillTipPanel.OnItemRButtonUp()
	if this:GetType() == "Box" then
		this:SetObjectPressed(0)
	end
end

function SkillTipPanel.OnItemRefreshTip()
	return SkillTipPanel.OnItemMouseEnter()
end

function SkillTipPanel.OnItemMouseEnter()
    if this:GetType() == "Box" and not this.dwDelayTime then
		this:SetObjectMouseOver(1)
		OutputSkillTip(this.dwSkillID, this.nLevel, {0, 0, 0, 0, 1}, false)
	end
end

function SkillTipPanel.OnItemMouseLeave()
    if this:GetType() == "Box" then
		this:SetObjectMouseOver(0) 
		HideTip()
	end
end

function SkillTipPanel.OnItemLButtonClick()

	if not this:GetType() == "Box" then 
		return 
	end

	local dwSkillID = this.dwSkillID
	local dwSkillLevel = this.nLevel
		
	local hSmallBox = ActionBar_GetBox(dwSkillID)
	
	OnUseSkill(dwSkillID, dwSkillLevel, hSmallBox)
end

function SkillTipPanel.OnItemRButtonClick()
	if not this:GetType() == "Box" then 
		return 
	end

	local dwSkillID = this.dwSkillID
	local dwSkillLevel = this.nLevel
		
	local hSmallBox = ActionBar_GetBox(dwSkillID)
	
	OnUseSkill(dwSkillID, dwSkillLevel, hSmallBox)
end

function SkillTipPanel.OnEvent(event)
	if not this:IsVisible() then
		return
	end
	
	if event == "UI_SCALED" then
		SkillTipPanel.UpdateAnchor(this)
		AdjustSFXFrame()
	elseif event == "CUSTOM_DATA_LOADED" then
		if arg0 == "Role" then
			SkillTipPanel.UpdateAnchor(this)
		end
	elseif event == "ON_ENTER_CUSTOM_UI_MODE" or event == "ON_LEAVE_CUSTOM_UI_MODE" then
		UpdateCustomModeWindow(this)
	elseif event == "SKILL_TIP_ANCHOR_CHANGED" then
		SkillTipPanel.UpdateAnchor(this)
	end
	
	if event == "FIGHT_HINT" then
		SkillTipPanel.bInFight = arg0
		if not SkillTipPanel.bInFight then
			SkillTipPanel.ClearTipBox()
			SkillTipPanel.ClearUseActionBar()
			SkillTipPanel.ClearSFX()
		end
	end
	
	if not SkillTipPanel.bInFight then 
		return
	end
	
	local tSkillTipData
	if event == "BUFF_UPDATE" then
		if arg0 == Target_GetTargetID() and Target_IsEnemy() then
			tSkillTipData = SkillTipPanel.GetSkillTipData({"szTargetBuff"})			-- 目标BUFF
		elseif arg0 == UI_GetClientPlayerID() then
			tSkillTipData = SkillTipPanel.GetSkillTipData({"szPlayerBuff"})			-- 自身BUFF
		end
	elseif event == "PLAYER_STATE_UPDATE" then
		if arg0 == UI_GetClientPlayerID() then										-- 自身血量内力
			tSkillTipData = SkillTipPanel.GetSkillTipData({"szPlayerLife", "szPlayerMana"})
		elseif arg0 == Target_GetTargetID() then
			if Target_IsEnemy() then 												-- 敌人是玩家血量内力
				tSkillTipData = SkillTipPanel.GetSkillTipData({"szTargetLife", "szTargetMana"})
			elseif IsInParty(arg0) then 											-- 队友血量内力
				tSkillTipData = SkillTipPanel.GetSkillTipData({"szTeammateLife"})
			end
		end
	elseif event == "NPC_STATE_UPDATE" then
		if arg0 == Target_GetTargetID() and Target_IsEnemy() then					-- 敌人是NPC血量内力
			tSkillTipData = SkillTipPanel.GetSkillTipData({"szTargetLife", "szTargetMana"})
		end
	elseif event == "UI_UPDATE_ACCUMULATE" then										-- 自身豆数
		tSkillTipData = SkillTipPanel.GetSkillTipData({"szPlayerAccumulate"})
	elseif event == "DO_SKILL_CAST" then
		if arg0 == UI_GetClientPlayerID() then 
			SkillTipPanel.nLastDoSkillID = arg1
			SkillTipPanel.nLastDoSkillLevel = arg2
			tSkillTipData = SkillTipPanel.GetSkillTipData({"szDoSkill"})
		end
	elseif event == "TARGET_LOST" then
	
	elseif event == "TARGET_CHANGE" then
				
		return;
	end
	
	if tSkillTipData then 
		SkillTipPanel.UpdateSkillTip(this, tSkillTipData)
	end
	SkillTipPanel.UpdateTipBox(this)
end

function SkillTipPanel.UpdateSkillTip(frame, tSkillTipData)
	local tParam, bShowTip
	for _, szTipID in pairs(tSkillTipData) do 
		local dwTipID = tonumber(szTipID)
		tParam, bShowTip, dwTargetID = SkillTipPanel.CheckEvent(dwTipID)
		if tParam then 
			local szShowType = tParam["szShowType"]
			local szShowData = tParam["szShowData"]
			local fScale = tParam["fScale"]
			if bShowTip then 
				if szShowType == "FLASH_BOX" then
					SkillTipPanel.InUseActionBar(tParam.dwSkillID, dwTargetID, tParam.dwMaxTime)
				elseif szShowType == "SHOW_TIP" then
					SkillTipPanel.NewTipBox(frame, tParam.dwSkillID, tParam.dwSkillLevel, dwTargetID, tParam.dwMaxTime)
				end
				
				if szShowData and szShowData ~= "" then 
					SkillTipPanel.ShowSFX(szShowData, fScale)
				end
				
			else
				if not SkillTipPanel.tRefreshCD[dwTipID] then
					if szShowType == "FLASH_BOX" then
						SkillTipPanel.UnUseActionBar(tParam.dwSkillID)
					elseif szShowType == "SHOW_TIP" then
						SkillTipPanel.RemoveTipBox(frame, tParam.dwSkillID, tParam.dwSkillLevel)
					end
					
					if szShowData and szShowData ~= "" then 
						SkillTipPanel.HideSFX(szShowData)
					end
				end
			end
		end
	end
end

SkillTipPanel.nBreatheCount = 0
function SkillTipPanel.OnFrameBreathe()

	if not SkillTipPanel.bInFight then 
		return 
	end

	if SkillTipPanel.nBreatheCount == 3 then
		SkillTipPanel.nBreatheCount = 0
	end
	
	if SkillTipPanel.nBreatheCount ~= 0 then
		SkillTipPanel.nBreatheCount = SkillTipPanel.nBreatheCount + 1
		return
	end

	local dwTickCount = GetTickCount()
	local handleBox = this:Lookup("", "Handle_Box")
	local nCount = SkillTipPanel.nItemCount
    for i = 0, nCount - 1, 1 do
        local hBox = handleBox:Lookup(i)
		local dwSkillID = hBox.dwSkillID
				
		if SkillTipPanel.tBuffTipEndFrame[dwSkillID] then 
			local _, __, nLeftFrame = GetLeftTime(SkillTipPanel.tBuffTipEndFrame[dwSkillID]) 
            if nLeftFrame > 0 and nLeftFrame < 80 then
                local nAlpha = hBox:GetAlpha()
                if hBox.bAdd then
                    nAlpha =  nAlpha + 80
                else
                    nAlpha =  nAlpha - 80
                end
                nAlpha = math.min(nAlpha, 255)
                nAlpha = math.max(nAlpha, 0)
                hBox:SetAlpha(nAlpha)
                if nAlpha == 255 then
                    hBox.bAdd = false;
                elseif nAlpha <= 0 then
                    hBox.bAdd = true;
                end
			elseif nLeftFrame < 0 then 
				SkillTipPanel.tBuffTipEndFrame[dwSkillID] = nil
            else
                hBox:SetAlpha(255)
            end 
        end
		
		if hBox.dwDelayTime and hBox.dwDelayTime < dwTickCount then 
			hBox.dwDelayTime = nil
			hBox:Hide()
		end
	end
	
end

function SkillTipPanel.GetSkillTipData(tKey)
	local tResult = {}
	local tTipInfo = SkillTipPanel.GetTipInfo()
	if tTipInfo then
		local tSkillTipID 
		for _, v in pairs(tKey) do
			szInfo = tTipInfo[v] or ""
			tSkillTipID = SplitString(szInfo, ";")
			for _, v in pairs(tSkillTipID) do
				table.insert(tResult, v)
			end
		end
	end
	return tResult
end

local function IsTargetRelation(szType)
	if szType == "TARGET_BUFF" or szType == "TARGET_MANA" or 
	   szType == "TARGET_LIFE" or szType == "TEAMMATE_LIFE" then 
		return true
	end
end

function SkillTipPanel.CheckEvent(dwSkillTipID)
	local tSkillEvent = g_tTable.SkillTip_Event:Search(dwSkillTipID)
	if not tSkillEvent then 
		return
	end
	
	local dwTargetID
	local bShowTip = true
	local szCondition = tSkillEvent["szCondition"] or ""
	local tConditions = SplitString(szCondition, ";")
	for _, dwCondictionID in pairs(tConditions) do
		local tCondition = g_tTable.SkillTip_Condition:Search(dwCondictionID)
		if not tCondition or not SkillTipPanel.CheckCondictions(tCondition, tSkillEvent) then 
			bShowTip = false
			break
		end
		
		if not dwTargetID and IsTargetRelation(tCondition.szType) then
			dwTargetID = Target_GetTargetID()
		end
	end
	return tSkillEvent, bShowTip, dwTargetID
end
 
 local function GetTarget()
	dwID, dwType = Target_GetTargetData()
	local hTarget
	if dwType == TARGET.NPC then
		hTarget = GetNpc(dwID)
	elseif dwType == TARGET.PLAYER then 
		hTarget = GetPlayer(dwID)
	end
	return hTarget
 end
  
 local tConditionParams = 
 {
	["TARGET_BUFF"] = {fnJudge=CheckBuff, fnGetTarget=GetTarget},
	["CLIENT_BUFF"] = {fnJudge=CheckBuff, fnGetTarget=GetClientPlayer},
	["TARGET_LIFE"] = {fnJudge=CheckLife, fnGetTarget=GetTarget},
	["CLIENT_LIFE"] = {fnJudge=CheckLife, fnGetTarget=GetClientPlayer},
	["TARGET_MANA"] = {fnJudge=CheckMana, fnGetTarget=GetTarget},
	["CLIENT_MANA"] = {fnJudge=CheckMana, fnGetTarget=GetClientPlayer},
	["REFRESH_CD"] = {fnJudge=CheckDoSkill},
	["CLIENT_ACCUMULATE"] = {fnJudge=CheckAccumulate},
	["TEAMMATE_LIFE"] = {fnJudge=CheckLife, fnGetTarget=GetTarget},
 }
 
function SkillTipPanel.CheckCondictions(tCondition, tSkillDes)
	local bEnable = false	
	local szConditionType = tCondition.szType
	local szAgr1 = tCondition.szArg1
	local szAgr2 = tCondition.szArg2
	local szAgr3 = tCondition.szArg3
	local szAgr4 = tCondition.szArg4
		
	local dwSkillTipID = tSkillDes["dwID"]
	local dwSkillID = tSkillDes["dwSkillID"]
	local dwSkillLevel = tSkillDes["dwSkillLevel"]
	
	if szConditionType == "CAN_DO_SKILL" then
		bEnable = CheckSkill(dwSkillID, dwSkillLevel)
		return bEnable
	end
	
	local fnJudge = tConditionParams[szConditionType].fnJudge
	local fnGetTarget = tConditionParams[szConditionType].fnGetTarget
	
	if fnGetTarget then 
		bEnable = fnJudge(fnGetTarget(), szAgr1, szAgr2, szAgr3, szAgr4, dwSkillID)
	else
		bEnable = fnJudge(szAgr1, szAgr2, szAgr3, szAgr4)
	end
	
	if szConditionType == "REFRESH_CD" then
		SkillTipPanel.tRefreshCD[dwSkillTipID] = true
	end
	
	return bEnable
end


function SkillTipPanel.NewTipBox(frame, dwSkillID, nLevel, dwTargetID, dwMaxTime)
	for index, v in pairs(SkillTipPanel.tTipDatas) do 
		if v.SkillID == dwSkillID and v.Level == nLevel then 
			return 
		end
	end

	local tTipData = {}
	tTipData.SkillID = dwSkillID;
	tTipData.Level= nLevel;
	tTipData.szName = Table_GetSkillName(dwSkillID, nLevel)
	local hSmallBox = ActionBar_GetBox(dwSkillID)
	if hSmallBox then 
		local szCmd = "ACTIONBAR"..hSmallBox.nGroup
		local nKey, bShift, bCtrl, bAlt = Hotkey.Get(szCmd.."_BUTTON"..hSmallBox.nIndex)
		tTipData.szHotKey = GetKeyShow(nKey, bShift, bCtrl, bAlt, true)
	else
		tTipData.szHotKey = ""
	end
	
	if dwMaxTime and dwMaxTime ~= 0 then
		local dwTickCount = GetTickCount()
		tTipData.MaxTime = dwTickCount + dwMaxTime * 1000
	end
	tTipData.Target = dwTargetID
	
	local handleBox = frame:Lookup("", "Handle_Box")
	local nCount = SkillTipPanel.nItemCount
	local nLen = #SkillTipPanel.tTipDatas
	if nLen == nCount then
		table.remove(SkillTipPanel.tTipDatas)
	end
	
	local bAddTipData = false
	for i = 1, nCount do 
		if not SkillTipPanel.tTipDatas[i] then 
			SkillTipPanel.tTipDatas[i] = tTipData
			bAddTipData = true
			break
		end
	end
	if not bAddTipData then 
		table.insert(SkillTipPanel.tTipDatas, 1, tTipData)
	end
	
	RefreshBox(frame)
	SkillTipPanel.InUseActionBar(dwSkillID, dwTargetID, dwMaxTime)
end

function SkillTipPanel.RemoveTipBox(frame, dwSkillID, nLevel)
	for index, v in pairs(SkillTipPanel.tTipDatas) do 
		if v.SkillID == dwSkillID and v.Level == nLevel then 
			--table.remove(SkillTipPanel.tTipDatas, index)
			SkillTipPanel.tTipDatas[index] = nil
		end
	end
	
	RefreshBox(frame)
	
	SkillTipPanel.UnUseActionBar(dwSkillID)
end

function SkillTipPanel.ClearTipBox()
	SkillTipPanel.tTipDatas = {}
	
	local frame = this:GetRoot()
	local handleBox = frame:Lookup("", "Handle_Box")
	local handleHotkeyText = frame:Lookup("", "Handle_HotkeyText")
	local handleNameText = frame:Lookup("", "Handle_NameText")
	
	local nCount = SkillTipPanel.nItemCount
    for i = 0, nCount - 1, 1 do
		local hBox = handleBox:Lookup(i)
		local hHotkeyText = handleHotkeyText:Lookup(i)
		local hNameText = handleNameText:Lookup(i)
		
		hBox:SetAlpha(255);
		hBox:Hide();
		hBox.dwDelayTime = nil
		
		hHotkeyText:Hide();
		hNameText:Hide();
	end
end

function SkillTipPanel.UpdateTipBox(frame)
	local dwTickCount = GetTickCount()
	for index, v in pairs(SkillTipPanel.tTipDatas) do 
		local dwSkillID = v.SkillID
		local nSkillLevel = v.Level
		if v.Target and v.Target ~= Target_GetTargetID() then 
			SkillTipPanel.tTipDatas[index] = nil
		elseif not CheckSkill(dwSkillID, nSkillLevel) then
			SkillTipPanel.tTipDatas[index] = nil
		elseif v.MaxTime then 
			if v.MaxTime <= dwTickCount then
				SkillTipPanel.tTipDatas[index] = nil
			end
		end
	end
	
	RefreshBox(frame);

	SkillTipPanel.UpdateActionBar()
end

function SkillTipPanel.InUseActionBar(dwSkillID, dwTargetID, dwMaxTime)
	if SkillTipPanel.tActionBarInUse[dwSkillID] then
		return 
	end
	
	local hSmallBox = ActionBar_GetBox(dwSkillID)
	if hSmallBox then
		hSmallBox:SetObjectInUse(true)
		SkillTipPanel.tActionBarInUse[dwSkillID] = true
		hSmallBox.dwTarget = dwTargetID
		if dwMaxTime and dwMaxTime ~= 0 then
			local dwTickCount = GetTickCount()
			hSmallBox.dwMaxTime = dwTickCount + dwMaxTime * 1000
		end
	end
end

function SkillTipPanel.UnUseActionBar(dwSkillID)
	if not SkillTipPanel.tActionBarInUse[dwSkillID] then
		return 
	end
	
	local hSmallBox = ActionBar_GetBox(dwSkillID)
	if hSmallBox then
		hSmallBox:SetObjectInUse(false)
		hSmallBox.dwTarget = nil
		hSmallBox.dwMaxTime = nil
	end
	
	SkillTipPanel.tActionBarInUse[dwSkillID] = nil
end

function SkillTipPanel.ClearUseActionBar()
	for k, _ in pairs(SkillTipPanel.tActionBarInUse) do 
		local hSmallBox = ActionBar_GetBox(k)
		hSmallBox:SetObjectInUse(false)
		hSmallBox.dwTarget = nil
		hSmallBox.dwMaxTime = nil
		SkillTipPanel.tActionBarInUse[k] = nil
	end
end

function SkillTipPanel.UpdateActionBar()
	local dwTickCount = GetTickCount()
	for dwID, _ in pairs(SkillTipPanel.tActionBarInUse) do 
		local hSmallBox = ActionBar_GetBox(dwID)
		if hSmallBox then 
			local dwSkillID, nSkillLevel = hSmallBox:GetObjectData()
			if (hSmallBox.dwTarget and hSmallBox.dwTarget ~= Target_GetTargetID()) or
			   (not CheckSkill(dwSkillID, nSkillLevel)) then
				SkillTipPanel.UnUseActionBar(dwSkillID)
			end
			if hSmallBox.dwMaxTime and hSmallBox.dwMaxTime < dwTickCount then 
				SkillTipPanel.UnUseActionBar(dwSkillID)
			end
		end
	end
end

function SkillTipPanel.ShowSFX(szSFXPath, fScale)
	if SkillTipPanel.tSFXFlag[szSFXPath] then 
		return 
	end
		
	for nIndex, hSFXWnd in pairs(SkillTipPanel.tSFXWndHanlde) do 
		if not hSFXWnd:IsVisible() then 
			hSFXWnd:Show()
			hSFXWnd:LoadSFX(szSFXPath)
			if fScale and fScale ~= 0 then 
				hSFXWnd:SetScale(fScale)
			end
			
			SkillTipPanel.tSFXFlag[szSFXPath] = nIndex
			break
		end
	end
	
end 

function SkillTipPanel.HideSFX(szSFXPath)
	local nIndex = SkillTipPanel.tSFXFlag[szSFXPath]
		
	if nIndex then 
		local hSFXWnd = SkillTipPanel.tSFXWndHanlde[nIndex]
		if hSFXWnd then 
			hSFXWnd:Hide()
		end
		SkillTipPanel.tSFXFlag[szSFXPath] = nil
	end
end 

function SkillTipPanel.ClearSFX()
	SkillTipPanel.tSFXFlag= {}
		
	for _, hSFXWnd in pairs(SkillTipPanel.tSFXWndHanlde) do 
		hSFXWnd:Hide()
	end
end 

function SkillTipPanel.GetTipInfo()
	if SkillTipPanel.tSkillTipInfo then 
		return SkillTipPanel.tSkillTipInfo
	end
	
	local dwKungfuID = UI_GetPlayerMountKungfuID()
	SkillTipPanel.tSkillTipInfo = g_tTable.SkillTip_Kungfu:Search(dwKungfuID)
	
	return SkillTipPanel.tSkillTipInfo
end

function SkillTipPanel.UpdateAnchor(frame)
	frame:SetPoint(SkillTipPanel.Anchor.s, 0, 0, SkillTipPanel.Anchor.r, SkillTipPanel.Anchor.x, SkillTipPanel.Anchor.y)
	frame:CorrectPos()
end

function SkillTipPanel.OnFrameDragEnd()
	this:CorrectPos()
	SkillTipPanel.Anchor = GetFrameAnchor(this, "TOPLEFT")
end

function SkillTip_SetAnchorDefault()
	SkillTipPanel.Anchor.s = SkillTipPanel.DefaultAnchor.s
	SkillTipPanel.Anchor.r = SkillTipPanel.DefaultAnchor.r
	SkillTipPanel.Anchor.x = SkillTipPanel.DefaultAnchor.x
	SkillTipPanel.Anchor.y = SkillTipPanel.DefaultAnchor.y
	FireEvent("SKILL_TIP_ANCHOR_CHANGED")
end

RegisterEvent("CUSTOM_UI_MODE_SET_DEFAULT", SkillTip_SetAnchorDefault)

function OpenSkillTipPanel()
	local hFrame = Station.Lookup("Normal/SkillTipPanel")
	local hSFXFrame = Station.Lookup("Normal/SFXFrame")
	if not hFrame then
		hFrame = Wnd.OpenWindow("SkillTipPanel")
	end
	if not hSFXFrame then
		hSFXFrame = Wnd.OpenWindow("SFXFrame")
	end
end

function CloseSkillTipPanel()
	Wnd.CloseWindow("SkillTipPanel")
	Wnd.CloseWindow("SFXFrame")	
end

function SetSkillTipPanel(bShow)
	SkillTipPanel.bShowPanel = bShow
	SkillTipPanel.bShowPanel = false
	if SkillTipPanel.bShowPanel then 
		OpenSkillTipPanel()
	else
		CloseSkillTipPanel()
	end
end

function IsSkillTipPanel()
	SkillTipPanel.bShowPanel = false
	return SkillTipPanel.bShowPanel
end

-- 注册切内功消息
RegisterEvent("SKILL_MOUNT_KUNG_FU", function() SkillTipPanel.tSkillTipInfo=nil end)
RegisterEvent("LOADING_END", function() SetSkillTipPanel(IsSkillTipPanel()) end)