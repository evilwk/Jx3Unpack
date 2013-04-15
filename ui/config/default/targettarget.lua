TargetTarget = 
{
	bTargetTargetShowFlag = true,
	
	DefaultAnchor = {s = "TOPLEFT", r = "TOPLEFT",  x = 810, y = 65},
	Anchor = {s = "TOPLEFT", r = "TOPLEFT", x = 810, y = 65},
    nVersion = 0,
    nCurrentVersion = 1,
}

local lc_hTotal
local lc_hBuff
local lc_hBuffText
local lc_hDebuff
local lc_hDebuffText
local lc_nBuffVersion = 0

RegisterCustomData("TargetTarget.Anchor")
RegisterCustomData("TargetTarget.bTargetTargetShowFlag")
RegisterCustomData("TargetTarget.nVersion")

local INI_FILE = "ui\\Config\\Default\\TargetTarget.ini"
function TargetTarget.UpdateInfo(hFrame)
	local hTarget = GetTargetHandle(hFrame.dwType, hFrame.dwID)
	if not hTarget then
		return
	end

	local szPath, nFrame = "", 0
	local hPlayer = GetClientPlayer()

	if hFrame.dwType == TARGET.PLAYER then
		if hTarget.dwMiniAvatarID == 0 then
			szPath = RoleChange.GetSchoolAvatarPath(hTarget.dwForceID)
		else
			szPath = GetPlayerMiniAvatarFile(hTarget.dwMiniAvatarID)
		end
		
		local img = hFrame:Lookup("", "Image_NewTarget")
		img:FromTextureFile(szPath)
		
--		local kungfu = hTarget.GetKungfuMount()
--		local dwKungfuType = 0
--		if kungfu then
--			dwKungfuType = kungfu.dwMountType
--		end
--		local szPath, nFrame = GetKungfuImage(dwKungfuType)
--		local szPath, nFrame = GetForceImage(hTarget.dwForceID)
--		hFrame:Lookup("", "Image_Target"):FromUITex(szPath, nFrame)
	elseif hFrame.dwType == TARGET.NPC then
		local dwModelID = GetNpc(hFrame.dwID).dwModelID
		local imgTarget = hFrame:Lookup("", "Image_Target")
		local imgNewTarget = hFrame:Lookup("", "Image_NewTarget")
		
		local szProtraitPath = NPC_GetProtrait(dwModelID)
		local szHeadImageFilePath = NPC_GetHeadImageFile(dwModelID)
		if szProtraitPath and IsFileExist(szProtraitPath) then
			szPath = szProtraitPath
		else
			szPath = szHeadImageFilePath
		end
		
		if IsFileExist(szPath) then
			--imgTarget:Hide()
			--imgNewTarget:Show()
			imgNewTarget:FromTextureFile(szPath)
		else
			--imgTarget:Show()
			--imgNewTarget:Hide()
			szPath, nFrame = GetNpcHeadImage(hFrame.dwID)
			imgNewTarget:FromUITex(szPath, nFrame)
		end
	end
	
	-- name
	local hTargetName = hFrame:Lookup("", "Text_Target")
	hTargetName:SetFontColor(GetForceFontColor(hFrame.dwID, hPlayer.dwID))
	local szTargetUIName = GetTargetUIName(hFrame.dwType, hFrame.dwID)
	hTargetName:SetText(szTargetUIName)
	
	-- level
	local hLevelText = hFrame:Lookup("", "Text_Level")
	local hLevelImage = hFrame:Lookup("", "Image_Danger")
	local nLevelDiff = hTarget.nLevel - hPlayer.nLevel
	if hPlayer.IsPlayerInMyParty(hFrame.dwID) or nLevelDiff <= SHOW_TARGET_LEVEL_LIMITS then
		local nFont = GetTargetLevelFont(nLevelDiff)
		hLevelText:SetFontScheme(nFont)
		hLevelText:SetText(hTarget.nLevel)
		hLevelText:Show()
		hLevelImage:Hide()
	else
		hLevelText:Hide()
		hLevelImage:Show()
	end
	
	-- camp
	local nFrame = nil
	if hFrame.dwType == TARGET.PLAYER then
		local hTarget = GetTargetHandle(hFrame.dwType, hFrame.dwID)
		nFrame = GetCampImageFrame(hTarget.nCamp, hTarget.bCampFlag)
	end
		
	local hImageCamp = hFrame:Lookup("", "Image_Camp")
	SetImage(hImageCamp, nFrame)

	-- party mark
	local hImageMark = hFrame:Lookup("", "Image_NPCMark") 
	local nIconFrame = nil
	if hPlayer.IsInParty() then
		local tPartyMark = GetClientTeam().GetTeamMark()
		assert(tPartyMark)
		if tPartyMark and tPartyMark[hFrame.dwID] then
			local nMarkID = tPartyMark[hFrame.dwID]
			assert(nMarkID > 0 and nMarkID <= #PARTY_MARK_ICON_FRAME_LIST)
			nIconFrame = PARTY_MARK_ICON_FRAME_LIST[nMarkID]
		end
	end
	if nIconFrame then
		hImageMark:FromUITex(PARTY_MARK_ICON_PATH, nIconFrame)
		hImageMark:Show()
	else
		hImageMark:Hide()
	end
end

function TargetTarget.UpdateName(hFrame)
	local hTarget = GetTargetHandle(hFrame.dwType, hFrame.dwID)
	if not hTarget then
		return
	end
	
	local hPlayer = GetClientPlayer()
	local hTargetName = hFrame:Lookup("", "Text_Target")
	hTargetName:SetFontColor(GetForceFontColor(hFrame.dwID, hPlayer.dwID))
end

function TargetTarget.UpdateState(hFrame)
	local hPlayer = GetClientPlayer()
	local fLife = 0
	local fMana = 0
	local nIntensity = nil
	local bShowState = IsTargetShowStateValue()
	local bCanSeeState = true
	
	local hTarget = GetTargetHandle(hFrame.dwType, hFrame.dwID)
	if not hTarget then
		return
	end
		
	if hFrame.dwType == TARGET.NPC then
		nIntensity = GetNpcIntensity(hTarget)
		bCanSeeState = hTarget.CanSeeLifeBar()
	end
	
	local bDanger = hTarget.nLevel - hPlayer.nLevel > SHOW_TARGET_LEVEL_LIMITS 
		and not hPlayer.IsPlayerInMyParty(hFrame.dwID)
	
	local hTotal = hFrame:Lookup("", "")
	if hTarget.nMaxLife ~= 0 then
		fLife = hTarget.nCurrentLife / hTarget.nMaxLife
		local hTextLife = hTotal:Lookup("Text_Health")
		if bShowState and bCanSeeState then
			local szLife = GetStateString(hTarget.nCurrentLife, hTarget.nMaxLife, bDanger, true)
			hTextLife:SetText(szLife)
			hTextLife:Show()
		else
			hTextLife:Hide()
		end
	end
	local hTextMana = hTotal:Lookup("Text_Mana")
	hTextMana:Hide()
	if hTarget.nMaxMana > 1 then
		fMana = hTarget.nCurrentMana / hTarget.nMaxMana
		if bShowState and bCanSeeState then
			local szMana = GetStateString(hTarget.nCurrentMana, hTarget.nMaxMana, bDanger, true)
			hTextMana:SetText(szMana)
			hTextMana:Show()
		else
			hTextMana:Hide()
		end
	end
	
	local hImageLife = hTotal:Lookup("Image_Health")
	local hImageSubLife = hTotal:Lookup("Image_SubHealth")
	
	local fSubPercent = 0
	if hTarget.nMoveState == MOVE_STATE.ON_DEATH 
	or hFrame.dwLastTarget ~= hFrame.dwID then
		fSubPercent = fLife
	else
		fSubPercent = hImageLife:GetPercentage()
	end
	hImageSubLife:SetPercentage(fSubPercent)
	
	hFrame.dwLastTarget = hFrame.dwID
	hImageLife:SetPercentage(fLife)
	local imgMana = hTotal:Lookup("Image_Mana")
	imgMana:SetPercentage(fMana)
	
	if hFrame.dwType == TARGET.PLAYER and hFrame.dwMountType then
		hFrame:Lookup("", "Image_TarBg"):Show()
		hFrame:Lookup("", "Image_TarBgF"):Hide()
		imgMana:Show()
		if IsPlayerManaHide(hFrame.dwMountType) then
			imgMana:Hide()
			hTextMana:Hide()
			
			hFrame:Lookup("", "Image_TarBg"):Hide()
			hFrame:Lookup("", "Image_TarBgF"):Show()
		end
	end
end

function TargetTarget.UpdateBuff(hFrame)
	local hTarget = GetTargetHandle(hFrame.dwType, hFrame.dwID)
	assert(hTarget)
    
	local nBuffCount = lc_hBuff:GetItemCount()
	local nDebuffCount = lc_hDebuff:GetItemCount()
	
	local nBuffNeed = 0
	local nDebuffNeed = 0
	local function UpdateSBuff(v)
		if not Table_BuffIsVisible(v.dwID, v.nLevel) then
			return
		end

		local box
		if v.bCanCancel then
			if nBuffNeed < nBuffCount then
				box = lc_hBuff:Lookup(nBuffNeed)
			end
			
			TargetTarget.UpdateNewBuff(lc_hBuff, box, v.nIndex, true, v.dwID, v.nStackNum, v.nEndFrame, v.nLevel, v.dwSkillSrcID, true)
			nBuffNeed = nBuffNeed + 1
		else
			if nDebuffNeed < nDebuffCount then
				box = lc_hDebuff:Lookup(nDebuffNeed)
			end
			
			TargetTarget.UpdateNewBuff(lc_hDebuff, box, v.nIndex, false, v.dwID, v.nStackNum, v.nEndFrame, v.nLevel, v.dwSkillSrcID, true)
			nDebuffNeed = nDebuffNeed + 1
		end
	end
    
	lc_nBuffVersion = lc_nBuffVersion + 1
	
	local buffTable = hTarget.GetBuffList()	
	if buffTable then
        local dwID = GetClientPlayer().dwID
        local tOtherBuff = {}
        for k, v in pairs(buffTable) do
            if v.dwSkillSrcID == dwID then
                UpdateSBuff(v)
            else
                table.insert(tOtherBuff, k)
            end
        end
        
		for _, k in pairs(tOtherBuff) do
            local v = buffTable[k]
            UpdateSBuff(v)
		end
	end
	
	Target.RemoveLeftItem(lc_hBuff, nBuffNeed)
	Target.RemoveLeftItem(lc_hDebuff, nDebuffNeed)
	
	lc_hBuff:FormatAllItemPos()
	lc_hDebuff:FormatAllItemPos()
end

function TargetTarget.OnFrameCreate()
	this:RegisterEvent("NPC_STATE_UPDATE")
	this:RegisterEvent("NPC_LEAVE_SCENE")

	this:RegisterEvent("BUFF_UPDATE")

	this:RegisterEvent("PLAYER_STATE_UPDATE")
	this:RegisterEvent("PLAYER_ENTER_SCENE")

	this:RegisterEvent("UPDATE_RELATION")
	this:RegisterEvent("UPDATE_ALL_RELATION")
		
	this:RegisterEvent("PLAYER_LEVEL_UP")
	
	this:RegisterEvent("OT_ACTION_PROGRESS_BREAK")
	this:RegisterEvent("PARTY_UPDATE_BASE_INFO")
	this:RegisterEvent("UPDATE_PLAYER_SCHOOL_ID")
	this:RegisterEvent("SET_SHOW_VALUE_BY_PERCENTAGE")
	this:RegisterEvent("SET_TARGET_SHOW_STATE_VALUE")
	
	this:RegisterEvent("PARTY_SET_MARK")
	
	this:RegisterEvent("UI_SCALED")
	this:RegisterEvent("ON_ENTER_CUSTOM_UI_MODE")
	this:RegisterEvent("ON_LEAVE_CUSTOM_UI_MODE")
	this:RegisterEvent("TARGET_TARGET_ANCHOR_CHANGED")
	this:RegisterEvent("CUSTOM_DATA_LOADED")
	
	this:RegisterEvent("CHANGE_CAMP")
	this:RegisterEvent("CHANGE_CAMP_FLAG")
	this:RegisterEvent("UI_ON_DAMAGE_EVENT")
	
	this:RegisterEvent("TARGET_TARGET_MINI_AVATAR_MISC")
	this:RegisterEvent("SET_MINI_AVATAR")
	
	TargetTarget.Init(this)
	TargetTarget.UpdateAnchor(this)
	UpdateCustomModeWindow(this, g_tStrings.TARGET_TARGET)
end

function TargetTarget.Init(frame)
	lc_hTotal = frame:Lookup("", "")
	lc_hBuff = lc_hTotal:Lookup("Handle_Buff")
	lc_hDebuff = lc_hTotal:Lookup("Handle_Debuff")
	lc_hBuff:Clear()
	lc_hDebuff:Clear()
	
	lc_hBuff.tItem = {}
	lc_hBuff.tVersion = {}
	lc_hDebuff.tItem = {}
	lc_hDebuff.tVersion = {}
	
	lc_nBuffVersion = 0
end

function TargetTarget.OnFrameBreathe()
	TargetTarget.UpdateAction(this)
end

function TargetTarget.OnFrameDrag()
end

function TargetTarget.OnFrameDragSetPosEnd()
end

function TargetTarget.OnFrameDragEnd()
	this:CorrectPos()
	TargetTarget.Anchor = GetFrameAnchor(this)
end

function TargetTarget.UpdateAnchor(hFrame)
	hFrame:SetPoint(TargetTarget.Anchor.s, 0, 0, TargetTarget.Anchor.r, TargetTarget.Anchor.x, TargetTarget.Anchor.y)
	hFrame:CorrectPos()
end

function TargetTarget.OnEvent(event)
	if not this:IsVisible() then
		return
	end
	
	if event == "PLAYER_STATE_UPDATE" then
		if this.dwType == TARGET.PLAYER and this.dwID == arg0 then
			TargetTarget.UpdateMountType(this)
			TargetTarget.UpdateState(this)
		end
	elseif event == "PLAYER_ENTER_SCENE" then
		if GetClientPlayer().dwID == arg0 then
			Wnd.CloseWindow("TargetTarget")
		end
	elseif event == "NPC_STATE_UPDATE" then
		if this.dwType == TARGET.NPC and this.dwID == arg0 then
			TargetTarget.UpdateState(this)
		end
	elseif event == "SET_SHOW_VALUE_BY_PERCENTAGE" or
		event == "SET_TARGET_SHOW_STATE_VALUE"then
		TargetTarget.UpdateState(this)
	elseif event == "UPDATE_PLAYER_SCHOOL_ID" or
		event == "PLAYER_LEVEL_UP" then
		if arg0 == this.dwID then
			TargetTarget.UpdateInfo(this)
		end
	elseif event == "PARTY_SET_MARK" then
		TargetTarget.UpdateInfo(this)
	elseif event == "OT_ACTION_PROGRESS_BREAK" then
		if arg0 == this.dwID then
			TargetTarget.OnActionBreak(this)
		end
	elseif event == "BUFF_UPDATE" then
		if this.dwID == arg0 then
			if arg7 then
				TargetTarget.UpdateBuff(this)
			else
				if arg3 then			
					TargetTarget.UpdateSingleBuff(lc_hBuff, arg1, arg2, true, arg4, arg5, arg6, arg8, arg9)
				else
					TargetTarget.UpdateSingleBuff(lc_hDebuff, arg1, arg2, false, arg4, arg5, arg6, arg8, arg9)
				end
			end
		end
	elseif event == "UI_SCALED" then
		TargetTarget.UpdateAnchor(this)
	elseif event == "ON_ENTER_CUSTOM_UI_MODE" or event == "ON_LEAVE_CUSTOM_UI_MODE" then
		UpdateCustomModeWindow(this)
	elseif event == "TARGET_TARGET_ANCHOR_CHANGED" then
		TargetTarget.UpdateAnchor(this)
	elseif event == "CUSTOM_DATA_LOADED" then
		TargetTarget.UpdateAnchor(this)
	elseif event == "CHANGE_CAMP" or event == "CHANGE_CAMP_FLAG" then
		if arg0 == this.dwID then
			TargetTarget.UpdateInfo(this)
		end
	elseif event == "UI_ON_DAMAGE_EVENT" then
		if arg0 == this.dwID then
			TargetTarget.OnDamageEvent(this, arg1, arg2)
		end		
	elseif event == "TARGET_TARGET_MINI_AVATAR_MISC" then
		TargetTarget.UpdateInfo(this)
	elseif event == "SET_MINI_AVATAR" then
		TargetTarget.UpdateInfo(this)
	end
end

function TargetTarget.OnItemLButtonDown()
	SelectTargetTarget()
end

function TargetTarget.OnItemMouseEnter()
	local szName = this:GetName()
	local hFrame = this:GetRoot()
	if szName == "Image_Camp" then
		if hFrame.dwType == TARGET.PLAYER then
			local hPlayer = GetPlayer(hFrame.dwID)
			local nX, nY = this:GetAbsPos()
			local nWidth, nHeight = this:GetSize()
			local szTip = GetFormatText(g_tStrings.STR_CAMP_TITLE[hPlayer.nCamp], 163)
			if hPlayer.bCampFlag then
				local szText = FormatString(g_tStrings.STR_SYS_MSG_OPEN_CAMP_FALG, "")
				szTip = szTip .. GetFormatText("\n" .. szText, 162)
			end
			OutputTip(szTip, 200, {nX, nY, nWidth, nHeight})
		end
	end
end

function TargetTarget.OnItemMouseLeave()
	HideTip()
end

function TargetTarget.OnDamageEvent(hFrame, nDamage, bCriticalStrike)
	local hImgHealth = hFrame:Lookup("", "Image_Health")
	local hImgSubHealth = hFrame:Lookup("", "Image_SubHealth")
	local fMainPercent = hImgHealth:GetPercentage()
	
	local hTarget = nil
	if hFrame.dwType == TARGET.PLAYER then
		hTarget = GetPlayer(hFrame.dwID)
	elseif hFrame.dwType == TARGET.NPC then
		hTarget = GetNpc(hFrame.dwID)
	end
	
	local fMainPercent = hImgHealth:GetPercentage()
	if not hTarget or hTarget.nMaxLife == 0 then
		hImgSubHealth:SetPercentage(fMainPercent)
		return
	end
	
	local fCurPercent = hImgSubHealth:GetPercentage()
	local fPercent = nDamage / hTarget.nMaxLife
	if fMainPercent > fCurPercent - fPercent then
		fCurPercent = fMainPercent
	else
		fCurPercent = fCurPercent - fPercent
	end
	hImgSubHealth:SetPercentage(fCurPercent)
	
	if IsFrameShake() and bCriticalStrike then
		ShakeWindow(hFrame)
	end
end

function TargetTarget.OnActionBreak(hFrame)
	local hActionBar = hFrame:Lookup("", "Handle_Bar")
	hActionBar.nActionState = ACTION_STATE.BREAK
end

function TargetTarget.UpdateAction(hFrame)
	local hTarget = GetTargetHandle(hFrame.dwType, hFrame.dwID)
	local hActionBar = hFrame:Lookup("", "Handle_Bar")
	if not Target.bShowActionBar or not hTarget then
		hActionBar:Hide()
		return
	end
	
	local bPrePare, dwID, dwLevel, fP = hTarget.GetSkillPrepareState()
	if bPrePare and hActionBar.nActionState ~= ACTION_STATE.PREPARE then
		hActionBar:SetAlpha(255)
		hActionBar:Show()
		hActionBar:Lookup("Image_Progress"):Show()
		hActionBar:Lookup("Image_FlashS"):Hide()
		hActionBar:Lookup("Image_FlashF"):Hide()
		hActionBar:Lookup("Text_Name"):SetText(Table_GetSkillName(dwID, dwLevel))
		hActionBar.nActionState = ACTION_STATE.PREPARE
	elseif not bPrePare and hActionBar.nActionState == ACTION_STATE.PREPARE then
		hActionBar.nActionState = ACTION_STATE.DONE
	end
	
	if hActionBar.nActionState == ACTION_STATE.PREPARE then
		hActionBar:Lookup("Image_Progress"):SetPercentage(fP)
	elseif hActionBar.nActionState == ACTION_STATE.DONE then
		hActionBar:Lookup("Image_FlashS"):Show()
		hActionBar.nActionState = ACTION_STATE.FADE
	elseif hActionBar.nActionState == ACTION_STATE.BREAK then
		hActionBar:Lookup("Image_FlashF"):Show()
		hActionBar.nActionState = ACTION_STATE.FADE
	elseif hActionBar.nActionState == ACTION_STATE.FADE then
		local nAlpha = hActionBar:GetAlpha() - 10
		if nAlpha > 0 then
			hActionBar:SetAlpha(nAlpha)
		else
			hActionBar.nActionState = ACTION_STATE.NONE
		end
	else
		hActionBar:Hide()
	end	
end

function TargetTarget.UpdateSingleBuff(handle, bDelete, nIndex, bCanCancel, dwBuffID, nCount, nEndFrame, nLevel, dwSkillSrcID)
	if not Table_BuffIsVisible(dwBuffID, nLevel) then
		return
	end
    
	local szKey = "b"..nIndex
    local szIniFile = INI_FILE
	if bDelete then
		if handle.tItem[szKey] and handle.tVersion[szKey] == lc_nBuffVersion then
			handle:RemoveItem(handle.tItem[szKey])
			handle:FormatAllItemPos()
		end
	else
        local player = GetClientPlayer()
		local box = handle.tItem[szKey]
		if box then
			box.nCount = nCount
			box.nEndFrame = nEndFrame
			box.bCanCancel = bCanCancel
			box.dwBuffID = dwBuffID
			box.nLevel = nLevel
			box.bSparking = Table_BuffNeedSparking(dwBuffID, nLevel)
			box.bShowTime = Table_BuffNeedShowTime(dwBuffID, nLevel)
			box:SetObject(UI_OBJECT_NOT_NEED_KNOWN, dwBuffID)
			box:SetObjectIcon(Table_GetBuffIconID(dwBuffID, nLevel))
			if nCount > 1 then
				box:SetOverText(0, nCount)
			end
		else
			TargetTarget.UpdateNewBuff(handle, nil, nIndex, bCanCancel, dwBuffID, nCount, nEndFrame, nLevel, dwSkillSrcID, bNotFormat)
		end
	end
end

function TargetTarget.UpdateNewBuff(handle, box, nIndex, bCanCancel, dwBuffID, nCount, nEndFrame, nLevel, dwSkillSrcID, bNotFormat)
	if not box then
		box = handle:AppendItemFromIni(INI_FILE, "Box")
		
		box.OnItemMouseEnter = function()
			local frame = this:GetRoot()
			this:SetObjectMouseOver(1)
			local nTime = math.floor(this.nEndFrame - GetLogicFrameCount()) / 16 + 1
			local x, y = this:GetAbsPos()
			local w, h = this:GetSize()
			OutputBuffTip(frame.dwID, this.dwBuffID, this.nLevel, this.nCount, this.bShowTime and not box.bCanCancel, nTime, {x, y, w, h})					
		end
		box.OnItemMouseHover = box.OnItemMouseEnter
		
		box.OnItemMouseLeave = function()
			HideTip()
			this:SetObjectMouseOver(0)
		end
	end
	local szKey = "b"..nIndex
	box:SetName(szKey)
	box.nCount = nCount
	box.nEndFrame = nEndFrame
	box.bCanCancel = bCanCancel
	box.dwBuffID = dwBuffID
	box.nLevel = nLevel
	box.nIndex = nIndex
	box.bSparking = Table_BuffNeedSparking(dwBuffID, nLevel)
	box.bShowTime = Table_BuffNeedShowTime(dwBuffID, nLevel)
	box:SetObject(UI_OBJECT_NOT_NEED_KNOWN, dwBuffID)
	box:SetObjectIcon(Table_GetBuffIconID(dwBuffID, nLevel))
	box:SetOverTextFontScheme(0, 15)
	
	handle.tItem[szKey] = box
	handle.tVersion[szKey] = lc_nBuffVersion
	
	if nCount > 1 then
		box:SetOverText(0, nCount)
	end
	
	if not bNotFormat then
		handle:FormatAllItemPos()
	end
end

function TargetTarget.UpdateMountType(frame)
	if frame.dwType ~= TARGET.PLAYER then
		return
	end
	
	frame.dwMountType = nil
	local hTarget = GetPlayer(frame.dwID)
	if hTarget then
		local kungfu = hTarget.GetKungfuMount()
		if kungfu then
			frame.dwMountType = kungfu.dwMountType
		end
	end
end

function UpdateTargetTarget()
	if not TargetTarget.bTargetTargetShowFlag then
		TargetTarget.dwType = nil
		TargetTarget.dwID = nil
		Wnd.CloseWindow("TargetTarget")
		return
	end
	
	local hFrame = Station.Lookup("Normal/TargetTarget")
	if not hFrame then
		hFrame = Wnd.OpenWindow("TargetTarget")
	end
	
	local player = GetClientPlayer()
	local hTargetTarget = nil
	local hTarget = nil
	if player then
		hTarget = GetTargetHandle(player.GetTarget())
	end
	if hTarget then
		hTargetTarget = GetTargetHandle(hTarget.GetTarget())
	end
	
	if hTargetTarget then
		hFrame.dwType, hFrame.dwID = hTarget.GetTarget()
		if TargetTarget.dwType ~= hFrame.dwType or TargetTarget.dwID ~= hFrame.dwID then
			TargetTarget.dwType = hFrame.dwType
			TargetTarget.dwID = hFrame.dwID
			
			TargetTarget.UpdateMountType(hFrame)
			
			TargetTarget.UpdateInfo(hFrame)
			TargetTarget.UpdateBuff(hFrame)
			hFrame:Lookup("", "Handle_Bar").nActionState = nil
			TargetTarget.UpdateState(hFrame)
		else
			TargetTarget.UpdateName(hFrame)
		end
		hFrame:Show()
	else
		TargetTarget.dwType = nil
		TargetTarget.dwID = nil
			
		hFrame:Hide()
	end
end

function GetTargetHandle(dwType, dwID)
	local hTarget = nil
	if dwType == TARGET.PLAYER then
		hTarget = GetPlayer(dwID)
	elseif dwType == TARGET.NPC then
		hTarget = GetNpc(dwID)
	end
	return hTarget
end

function GetTargetUIName(dwType, dwID)
	local hTarget = nil
	local szTargetUIName = ""
	if dwType == TARGET.PLAYER then
		hTarget = GetPlayer(dwID)
		szTargetUIName = hTarget.szName
	elseif dwType == TARGET.NPC then
		hTarget = GetNpc(dwID)
		szTargetUIName = hTarget.szName
		if hTarget.dwEmployer ~= 0 then
			local hEmployer = GetPlayer(hTarget.dwEmployer)
			if not hEmployer then
				szTargetUIName = g_tStrings.STR_SOME_BODY .. g_tStrings.STR_PET_SKILL_LOG .. hTarget.szName
			else
				szTargetUIName = hEmployer.szName .. g_tStrings.STR_PET_SKILL_LOG .. hTarget.szName
			end
		end
	end
	return szTargetUIName
end

function ShowTargetTarget(bShow)
	TargetTarget.bTargetTargetShowFlag = bShow
	UpdateTargetTarget()
end

function IsShowTargetTarget()
	return TargetTarget.bTargetTargetShowFlag
end

function SelectTargetTarget()
	local hPlayer = GetClientPlayer()
	local hTarget = GetTargetHandle(hPlayer.GetTarget())
	if hTarget then
		local dwType, dwID = hTarget.GetTarget()
		if dwType == TARGET.PLAYER and dwID == hPlayer.dwID then
			SelectSelf()
		else
			SelectTarget(dwType, dwID)
		end
	end
end

function TargetTarget_SetAnchorDefault()
	TargetTarget.Anchor.s = TargetTarget.DefaultAnchor.s
	TargetTarget.Anchor.r = TargetTarget.DefaultAnchor.r
	TargetTarget.Anchor.x = TargetTarget.DefaultAnchor.x
	TargetTarget.Anchor.y = TargetTarget.DefaultAnchor.y
	FireEvent("TARGET_TARGET_ANCHOR_CHANGED")
end

function TargetTarget_VersionChange()
    if arg0 == "Role" and TargetTarget.nVersion < TargetTarget.nCurrentVersion then
        TargetTarget.nVersion = TargetTarget.nCurrentVersion
        TargetTarget.Anchor = {s = "TOPLEFT", r = "TOPLEFT", x = 810, y = 65}
        FireUIEvent("TARGET_ANCHOR_CHANGED")
    end
end

RegisterEvent("CUSTOM_UI_MODE_SET_DEFAULT", TargetTarget_SetAnchorDefault)
RegisterEvent("CUSTOM_DATA_LOADED", TargetTarget_VersionChange)
