Target = 
{
	bShowActionBar = true, 
	bShowStateValue = true,
	bStandard = false,
	DefaultAnchor = {s = "TOPLEFT", r = "TOPLEFT",  x = 480, y = 10},
	Anchor = {s = "TOPLEFT", r = "TOPLEFT", x = 480, y = 10},
    nVersion = 0,
    nCurrentVersion = 1,
	bIsEnemy = false,
	nDispelCount = 0,
}

RegisterCustomData("Target.bShowActionBar")
RegisterCustomData("Target.bShowStateValue")
RegisterCustomData("Target.bStandard")
RegisterCustomData("Target.Anchor")
RegisterCustomData("Target.nVersion")

ACTION_STATE = 
{
	NONE = 1,
	PREPARE = 2,
	DONE = 3,
	BREAK = 4,
	FADE = 5,
}
local INI_FILE 
local COMMON_INI_FILE = "ui/config/default/TargetCommon.ini"
local lc_hTotal
local lc_hBuff
local lc_hBuffText
local lc_hDebuff
local lc_hDebuffText

local lc_nBuffVersion = 0


local function AdjustBuffBg()
	local Image, ImageOther
	if Target.bIsEnemy then 
		Image = lc_hTotal:Lookup("Image_BuffBG")
		ImageOther = lc_hTotal:Lookup("Image_DebuffBG")
	else 
		Image = lc_hTotal:Lookup("Image_DebuffBG")
		ImageOther = lc_hTotal:Lookup("Image_BuffBG")
	end
	
	local nWide = Target.nDispelCount * 30
	local _, nHeight = Image:GetSize()
	Image:SetSize(nWide, nHeight)
	
	_, nHeight = ImageOther:GetSize()
	ImageOther:SetSize(0, nHeight)
end

local function AddDispelBuffCount()
	Target.nDispelCount = Target.nDispelCount + 1
	AdjustBuffBg()
end 

local function RemoveDispelBuffCount()
	Target.nDispelCount = Target.nDispelCount - 1
	if Target.nDispelCount < 0 then 
		Target.nDispelCount = 0
	end
	AdjustBuffBg()
end 

local function ClearDispelBuffCount()
	Target.nDispelCount = 0
	AdjustBuffBg()
end 

function Target.OnFrameCreate()
	this:RegisterEvent("NPC_STATE_UPDATE")
	this:RegisterEvent("NPC_LEAVE_SCENE")

	this:RegisterEvent("BUFF_UPDATE")

	this:RegisterEvent("PLAYER_STATE_UPDATE")
	this:RegisterEvent("PLAYER_ENTER_SCENE")
	this:RegisterEvent("PLAYER_LEAVE_SCENE")

	this:RegisterEvent("UPDATE_RELATION")
	this:RegisterEvent("UPDATE_ALL_RELATION")
		
	this:RegisterEvent("PLAYER_LEVEL_UP")
	
	this:RegisterEvent("OT_ACTION_PROGRESS_BREAK")
	this:RegisterEvent("PARTY_UPDATE_BASE_INFO")
	this:RegisterEvent("UPDATE_PLAYER_SCHOOL_ID")
	this:RegisterEvent("SET_SHOW_VALUE_BY_PERCENTAGE")
	this:RegisterEvent("SET_SHOW_VALUE_TWO_FORMAT")
	this:RegisterEvent("SET_TARGET_SHOW_STATE_VALUE")
	
	this:RegisterEvent("PARTY_SET_MARK")
	this:RegisterEvent("SET_SHOW_STANDARD_TARGET")
	
	this:RegisterEvent("UI_SCALED")
	this:RegisterEvent("ON_ENTER_CUSTOM_UI_MODE")
	this:RegisterEvent("ON_LEAVE_CUSTOM_UI_MODE")
	this:RegisterEvent("TARGET_ANCHOR_CHANGED")
	
	this:RegisterEvent("NPC_DROP_TARGET_UPDATE")
	this:RegisterEvent("CUSTOM_DATA_LOADED")
	this:RegisterEvent("CHANGE_CAMP")
	this:RegisterEvent("UI_ON_DAMAGE_EVENT")
	this:RegisterEvent("CHANGE_CAMP_FLAG")
	
	this:RegisterEvent("TARGET_MINI_AVATAR_MISC")
	this:RegisterEvent("SET_MINI_AVATAR")
	this:RegisterEvent("SKILL_MOUNT_KUNG_FU")
	this:RegisterEvent("SKILL_UNMOUNT_KUNG_FU")

	Target.Init(this)
	Target.UpdateAnchor(this)
	Target.UpdateKungfu(this)
	UpdateCustomModeWindow(this, g_tStrings.TARGET)
end

function Target.Init(frame)
	lc_hTotal = frame:Lookup("", "")
	lc_hBuff = lc_hTotal:Lookup("Handle_Buff")
	lc_hBuffText = lc_hTotal:Lookup("Handle_TextBuff")
	lc_hDebuff = lc_hTotal:Lookup("Handle_Debuff")
	lc_hDebuffText = lc_hTotal:Lookup("Handle_TextDebuff")

	lc_hBuff:Clear()
	lc_hBuffText:Clear()
	lc_hDebuff:Clear()
	lc_hDebuffText:Clear()
	
	lc_hBuff.tItem = {}
	lc_hBuff.tVersion = {}
	
	lc_hBuffText.tItem = {}
	lc_hBuffText.tVersion = {}
	
	lc_hDebuff.tItem = {}
	lc_hDebuff.tVersion = {}
	
	lc_hDebuffText.tItem = {}
	lc_hDebuffText.tVersion = {}
	lc_nBuffVersion = 0
	
	frame:Lookup("", "Image_NPCMark"):Hide()
	
	local _, nHeight, nPosX, nPosY
	
	ImageBuffBg = lc_hTotal:AppendItemFromIni(COMMON_INI_FILE, "Image_BuffBG")
	_, nHeight = ImageBuffBg:GetSize()
	ImageBuffBg:SetSize(0, nHeight)
	nPosX, nPosY = lc_hBuff:GetAbsPos()
	ImageBuffBg:SetAbsPos(nPosX, nPosY)
	nPosX, nPosY = lc_hBuff:GetRelPos()
	ImageBuffBg:SetRelPos(nPosX, nPosY)
	
	ImageDebuffBg = lc_hTotal:AppendItemFromIni(COMMON_INI_FILE, "Image_DebuffBG")
	_, nHeight = ImageDebuffBg:GetSize()
	ImageDebuffBg:SetSize(0, nHeight)
	nPosX, nPosY = lc_hDebuff:GetAbsPos()
	ImageDebuffBg:SetAbsPos(nPosX, nPosY)
	nPosX, nPosY = lc_hDebuff:GetRelPos()
	ImageDebuffBg:SetRelPos(nPosX, nPosY)
	
end

function Target.OnFrameDrag()
end

function Target.OnFrameDragSetPosEnd()
end

function Target.OnFrameDragEnd()
	this:CorrectPos()
	Target.Anchor = GetFrameAnchor(this, "TOPLEFT")
end

function Target.UpdateAnchor(frame)
	frame:SetPoint(Target.Anchor.s, 0, 0, Target.Anchor.r, Target.Anchor.x, Target.Anchor.y)
	frame:CorrectPos()
end

Target.nBreatheCount = 0
function Target.OnFrameBreathe()
	Target.UpdateAction(this)
	
	Target.nBreatheCount = Target.nBreatheCount + 1
	if Target.nBreatheCount == 3 then
		Target.nBreatheCount = 0
	else
		return
	end
    
    UpdateBufferTime(lc_hBuff, lc_hBuffText)
    UpdateBufferTime(lc_hDebuff, lc_hDebuffText)
end

function Target.UpdateMountType(frame)
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

function Target.UpdateState(frame)
	Target.UpdateLM(frame)
	Target.UpdateName(frame)
	Target.UpdateLevel(frame)
	Target.UpdateBuff(frame)
	Target.UpdateAction(frame)
	Target.UpdateHead(frame)
	Target.UpdateKungfu(frame)
	Target.UpdateTargetMark(frame)
	Target.UpdateCamp(frame)
end

function Target.UpdateTargetMark(hFrame)
	local hPlayer = GetClientPlayer()
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

local function OnUpdateProgress(hProgress)
	local hHighlight = hProgress:GetParent():Lookup("Image_Flash")
	local fCurPercent = hProgress:GetPercentage()
    if fCurPercent < 1 then
    	local nStartPosX, _ = hProgress:GetAbsPos()
    	local nFullWidth, _ = hProgress:GetSize()
    	local nHighlightWidth, _ = hHighlight:GetSize()
    	local _, nPosY = hHighlight:GetAbsPos()
    	hHighlight:SetAbsPos(nStartPosX + nFullWidth * fCurPercent - nHighlightWidth, nPosY)
    	hHighlight:Show()
    else
    	hHighlight:Hide()
    end	
end

function Target.UpdateLM(hFrame)
	local hTarget = nil
	local bHideBar = false
	if hFrame.dwType == TARGET.PLAYER then
		hTarget = GetPlayer(hFrame.dwID)
	elseif hFrame.dwType == TARGET.NPC then
		hTarget = GetNpc(hFrame.dwID)
		bHideBar = (hTarget and not hTarget.CanSeeLifeBar())
	end
	
	local szHealth, szMana = "", ""
	local fHealth, fMana = 0, 0
	if hTarget then
		local hPlayer = GetClientPlayer()
		local bDanger = hTarget.nLevel - hPlayer.nLevel > SHOW_TARGET_LEVEL_LIMITS and not hPlayer.IsPlayerInMyParty(hFrame.dwID)
		if hTarget.nMaxLife > 0 then
			fHealth = hTarget.nCurrentLife / hTarget.nMaxLife
			szHealth = GetStateString(hTarget.nCurrentLife, hTarget.nMaxLife, bDanger)
		end
		
		if hTarget.nMaxMana > 0 and hTarget.nMaxMana ~= 1 then
			fMana = hTarget.nCurrentMana / hTarget.nMaxMana
			szMana = GetStateString(hTarget.nCurrentMana, hTarget.nMaxMana, bDanger)
		end
	end
	
	local hTotal = hFrame:Lookup("", "")
	local tImgHealth = {}
	local tImgSubHealth = {}
	
	local hHealth1 = hTotal:Lookup("Image_Health")
	local hSubHealth1 = hTotal:Lookup("Image_SubHealth")
	local hHealth2 = hTotal:Lookup("Image_Health02")
	local hSubHealth2 = hTotal:Lookup("Image_SubHealth02")
	local hHealth3 = hTotal:Lookup("Image_Health03")
	local hSubHealth3 = hTotal:Lookup("Image_SubHealth03")
	
	table.insert(tImgHealth, hHealth1)
	table.insert(tImgSubHealth, hSubHealth1)
	if hFrame.nIntensity and hFrame.nIntensity > 1 and hHealth2 then
		table.insert(tImgHealth, hHealth2)
		table.insert(tImgSubHealth, hSubHealth2)
	end
	if hFrame.nIntensity and hFrame.nIntensity > 3 and hHealth3 then
		table.insert(tImgHealth, hHealth3)
		table.insert(tImgSubHealth, hSubHealth3)		
	end
	
	local nCount = #tImgHealth
	for i = 1, nCount do
		if fHealth >= i / nCount then
			tImgSubHealth[i]:SetPercentage(1)
			tImgSubHealth[i]:Show()
			tImgHealth[i]:SetPercentage(1)
			tImgHealth[i]:Show()
		elseif fHealth > (i - 1) / nCount then
			local fCurPercent = fHealth * nCount - i + 1
			
			local fSubPercent = 0
			if hTarget.nMoveState == MOVE_STATE.ON_DEATH
			or hFrame.dwLastTarget ~= hFrame.dwID then
				fSubPercent = fCurPercent
			else
				fSubPercent = tImgHealth[i]:GetPercentage()
			end
			tImgSubHealth[i]:SetPercentage(fSubPercent)
			tImgSubHealth[i]:Show()
			
			tImgHealth[i]:SetPercentage(fCurPercent)
			tImgHealth[i]:Show()
		else
			tImgSubHealth[i]:Hide()
			tImgHealth[i]:Hide()
		end
	end
	hFrame.dwLastTarget = hFrame.dwID
	
	hTotal:Lookup("Image_Mana"):SetPercentage(fMana)
	hTotal.szHealth, hTotal.szMana = szHealth, szMana
	
	local hTextHealth = hTotal:Lookup("Text_Health")
	local hTextMana = hTotal:Lookup("Text_Mana")
	if not IsTargetShowStateValue() or bHideBar then
		hTextHealth:Hide()
		hTextMana:Hide()
	else
		hTextHealth:SetText(szHealth)
		hTextHealth:Show()
		hTextMana:SetText(szMana)
		hTextMana:Show()		
	end
	
	if hFrame.dwType == TARGET.PLAYER and hFrame.dwMountType then
		Target.UpdateHeaderBg(hFrame)
	
		local imgMana = hTotal:Lookup("Image_Mana")
		imgMana:Show()
		
		if IsPlayerManaHide(hFrame.dwMountType) then
			imgMana:Hide()
			hTextMana:Hide()
			
			Target.UpdateHeaderBg(hFrame, true)
		end
	end
end

function Target.UpdateHeaderBg(frame, bHide)
	local fnVisible=function(szName, bShow)
		local img = frame:Lookup("", szName)
		img:Hide()
		if bShow then
			img:Show()
		end
	end
	
	fnVisible("Image_FBgC", bHide)
	fnVisible("Image_FBgCR", bHide)
	fnVisible("Image_FBgCRR", bHide)
	fnVisible("Image_FBgR", bHide)
	fnVisible("Image_FBgL", bHide)
	
	fnVisible("Image_TarBgL", not bHide)
	fnVisible("Image_TarBgC", not bHide)
	fnVisible("Image_TarBgCR", not bHide)
	fnVisible("Image_TarBgCRR", not bHide)
	fnVisible("Image_TarBgR", not bHide)
end

function Target.UpdateName(frame)
	local player = GetClientPlayer()
	local tar = GetTargetHandle(frame.dwType, frame.dwID)
	
	local text = frame:Lookup("", "Text_Target")
	--[[
	if frame.dwType == TARGET.NPC and not tar.CanSeeName() then
		text:SetText("")
		return
	end
	]]
	
	text:SetFontColor(GetForceFontColor(frame.dwID, player.dwID))
	local szTargetUIName = GetTargetUIName(frame.dwType, frame.dwID)
	if tar then
		text:SetText(szTargetUIName)
	else
		text:SetText("")
	end
end

function Target.UpdateCamp(hFrame)
	local nFrame = nil
	if hFrame.dwType == TARGET.PLAYER then
		local hTarget = GetTargetHandle(hFrame.dwType, hFrame.dwID)
		nFrame = GetCampImageFrame(hTarget.nCamp, hTarget.bCampFlag)
	end
		
	local hImageCamp = hFrame:Lookup("", "Image_Camp")
	SetImage(hImageCamp, nFrame)
end

function Target.UpdateKungfu(frame)
	if frame.dwType ~= TARGET.PLAYER then
		return
	end
	
	local player = GetTargetHandle(frame.dwType, frame.dwID)
	if not player then
		return
	end
	
--	local kungfu = player.GetKungfuMount()
--	local dwKungfuType = 0
--	
--	if kungfu then
--		dwKungfuType = kungfu.dwMountType
--	end
--	
--	local szPath, nFrame = GetKungfuImage(dwKungfuType)
	local szPath, nFrame = GetForceImage(player.dwForceID)
	local img = frame:Lookup("", "Image_Target")
	img:FromUITex(szPath, nFrame)
	
	local nCount = GetPlayerSchoolNumber(player)
	if nCount > 0 then
		frame:Lookup("", "Text_Others"):SetText(nCount)
	else
		frame:Lookup("", "Text_Others"):SetText("")
	end
end

function Target.UpdateHead(frame)
	local szPath, nFrame = "", 0
	if frame.dwType == TARGET.PLAYER then
		local hTarget = GetTargetHandle(frame.dwType, frame.dwID)
		
		if hTarget.dwMiniAvatarID == 0 then
			szPath = RoleChange.GetSchoolAvatarPath(hTarget.dwForceID)
		else
			szPath = GetPlayerMiniAvatarFile(hTarget.dwMiniAvatarID)
		end
		local img = frame:Lookup("", "Image_NewTarget")
		img:FromTextureFile(szPath, true)
	elseif frame.dwType == TARGET.NPC then
		local player = GetClientPlayer()
		local npc = GetNpc(frame.dwID)
		local dwModelID = npc.dwModelID
		local imgTarget = frame:Lookup("", "Image_Target")
		local imgNewTarget = frame:Lookup("", "Image_NewTarget")
		
		local szProtraitPath = NPC_GetProtrait(dwModelID)
		local szHeadImageFilePath = NPC_GetHeadImageFile(dwModelID)
		if szProtraitPath and IsFileExist(szProtraitPath) then
			szPath = szProtraitPath
		else
			szPath = szHeadImageFilePath
		end
		
		if IsFileExist(szPath) then
			imgTarget:Hide()
			imgNewTarget:Show()
			imgNewTarget:FromTextureFile(szPath, true)
		else
			imgTarget:Show()
			imgNewTarget:Hide()
			szPath, nFrame = GetNpcHeadImage(frame.dwID)
			imgTarget:FromUITex(szPath, nFrame)
		end
		
		local bNotMine = npc.dwDropTargetPlayerID ~= 0 and npc.dwDropTargetPlayerID ~= player.dwID and not player.IsPlayerInMyParty(npc.dwDropTargetPlayerID)
		local imgOthersExp = frame:Lookup("", "Image_OthersExp")
		if bNotMine then
			imgOthersExp:Show()
		else
			imgOthersExp:Hide()
		end
	end
end

function Target.UpdateLevel(frame)
	local player = GetClientPlayer()
	local tar = GetTargetHandle(frame.dwType, frame.dwID)
	local text = frame:Lookup("", "Text_Level")
	local img = frame:Lookup("", "Image_Danger")
	if tar then
		local nDiff = tar.nLevel - player.nLevel
		local nFont = GetTargetLevelFont(nDiff)
		if player.IsPlayerInMyParty(frame.dwID) or nDiff <= SHOW_TARGET_LEVEL_LIMITS then
			text:Show()
			img:Hide()
		else
			text:Hide()
			img:Show()
		end
		text:SetFontScheme(nFont)
		text:SetText(tar.nLevel)
	else
		text:Hide()
		img:Hide()
	end
end

function Target.AdjustBufferSize(frame)
    local handle = frame:Lookup("", "")
	local hBuff = handle:Lookup("Handle_Buff")
	local hDebuff = handle:Lookup("Handle_Debuff")
    
    local nOldW, nOldH = hBuff:GetSize()
    hBuff:SetSizeByAllItemSize()
    local _, nH = hBuff:GetSize()
    nH = math.max(nH, nOldH)
    
    hBuff:SetSize(nOldW, nOldH)
    local nPosX, nPosY = hBuff:GetAbsPos()
    local nRelX, nRelY = hBuff:GetRelPos()
    hDebuff:SetAbsPos(nPosX, nPosY + nH)
    hDebuff:SetRelPos(nRelX, nRelY + nH)
end

function Target.RemoveLeftItem(handle, nNeed)
	local nCount = handle:GetItemCount()
	local nLeft = nCount - nNeed
	for i=1, nLeft, 1 do
		handle:RemoveItem(nCount - i)
	end
end

function Target.UpdateBuff(frame)
	local tar = GetTargetHandle(frame.dwType, frame.dwID)
	if not tar then
		return
	end

	local nBuffCount = lc_hBuff:GetItemCount()
	local nBuffTextCount = lc_hBuffText:GetItemCount()
	assert(nBuffCount == nBuffTextCount)
	
	local nDebuffCount = lc_hDebuff:GetItemCount()
	local nDebuffTextCount = lc_hDebuffText:GetItemCount()
	assert(nDebuffCount == nDebuffTextCount)
	
	ClearDispelBuffCount()
	
	local nBuffNeed = 0
	local nDebuffNeed = 0
	
    local function UpdateSBuff(v)
		if not Table_BuffIsVisible(v.dwID, v.nLevel) then
			return false
		end

		local box, text
		if v.bCanCancel then
			if nBuffNeed < nBuffCount then
				box = lc_hBuff:Lookup(nBuffNeed)
				text = lc_hBuffText:Lookup(nBuffNeed)
			end
			Target.UpdateNewBuff(lc_hBuff, lc_hBuffText, box, text, v.nIndex, true, v.dwID, v.nStackNum, v.nEndFrame, v.nLevel, v.dwSkillSrcID, true)
			nBuffNeed = nBuffNeed + 1
		else
			if nDebuffNeed < nDebuffCount then
				box = lc_hDebuff:Lookup(nDebuffNeed)
				text = lc_hDebuffText:Lookup(nDebuffNeed)
			end
			
			Target.UpdateNewBuff(lc_hDebuff, lc_hDebuffText, box, text, v.nIndex, false, v.dwID, v.nStackNum, v.nEndFrame, v.nLevel, v.dwSkillSrcID, true)
			nDebuffNeed = nDebuffNeed + 1
		end
		return true
    end
    
	lc_nBuffVersion = lc_nBuffVersion + 1
	local buffTable = tar.GetBuffList()	
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
	Target.RemoveLeftItem(lc_hBuffText, nBuffNeed)
	Target.RemoveLeftItem(lc_hDebuff, nDebuffNeed)
	Target.RemoveLeftItem(lc_hDebuffText, nDebuffNeed)
	
	lc_hBuff:FormatAllItemPos()
	lc_hBuffText:FormatAllItemPos()
	lc_hDebuff:FormatAllItemPos()
	lc_hDebuffText:FormatAllItemPos()
end

function Target.UpdateAction(frame)
	local tar = GetTargetHandle(frame.dwType, frame.dwID)
	local handle = frame:Lookup("", "Handle_Bar")
	if not Target.bShowActionBar or not tar then
		handle:Hide()
		return
	end
	
	local bPrePare, dwID, dwLevel, fP = tar.GetSkillPrepareState()
	if bPrePare and handle.nActionState ~= ACTION_STATE.PREPARE then
		handle:SetAlpha(255)
		handle:Show()
		handle:Lookup("Image_Progress"):Show()
		handle:Lookup("Image_FlashS"):Hide()
		handle:Lookup("Image_FlashF"):Hide()
		handle:Lookup("Text_Name"):SetText(Table_GetSkillName(dwID, dwLevel))
		handle.nActionState = ACTION_STATE.PREPARE
	elseif not bPrePare and handle.nActionState == ACTION_STATE.PREPARE then
		handle.nActionState = ACTION_STATE.DONE
	end
	
	if handle.nActionState == ACTION_STATE.PREPARE then
		handle:Lookup("Image_Progress"):SetPercentage(fP)
	elseif handle.nActionState == ACTION_STATE.DONE then
		handle:Lookup("Image_FlashS"):Show()
		handle.nActionState = ACTION_STATE.FADE
	elseif handle.nActionState == ACTION_STATE.BREAK then
		handle:Lookup("Image_FlashF"):Show()
		handle.nActionState = ACTION_STATE.FADE
	elseif handle.nActionState == ACTION_STATE.FADE then
		local nAlpha = handle:GetAlpha()
		nAlpha = nAlpha - 10
		if nAlpha > 0 then
			handle:SetAlpha(nAlpha)
		else
			handle.nActionState = ACTION_STATE.NONE
		end
	else
		handle:Hide()
	end	
end

function Target.OnActionBreak(frame)
	local handle = frame:Lookup("", "Handle_Bar")
	handle.nActionState = ACTION_STATE.BREAK
end

function Target.OnEvent(event)
	if not this:IsVisible() then
		return
	end
		
	if event == "PLAYER_STATE_UPDATE" then
		if this.dwType == TARGET.PLAYER and this.dwID == arg0 then
			Target.UpdateMountType(this)
			Target.UpdateLM(this)
		end
	elseif event == "NPC_STATE_UPDATE" then
		if this.dwType == TARGET.NPC and this.dwID == arg0 then
			Target.UpdateLM(this)
		end
	elseif event == "BUFF_UPDATE" then
		if this.dwID == arg0 then
			if arg7 then
				Target.UpdateBuff(this)
			else
				if arg3 then			
					UpdateSingleBuff(lc_hBuff, lc_hBuffText, arg1, arg2, true, arg4, arg5, arg6, arg8, arg9)
				else
					UpdateSingleBuff(lc_hDebuff, lc_hDebuffText, arg1, arg2, false, arg4, arg5, arg6, arg8, arg9)
				end
			end
		end
	elseif event == "PLAYER_LEAVE_SCENE" then
		local player = GetClientPlayer()
		if this.dwType == TARGET.PLAYER and (this.dwID == arg0 or not player or player.dwID == arg0)then
			SelectTarget(TARGET.NO_TARGET, 0)
		end
	elseif event == "NPC_LEAVE_SCENE" then
		if this.dwType == TARGET.NPC and this.dwID == arg0 then
			SelectTarget(TARGET.NO_TARGET, 0)
		end
	elseif event == "PLAYER_ENTER_SCENE" then
		if GetClientPlayer().dwID == arg0 then
			CloseTargetPanel()
			SelectTarget(TARGET.NO_TARGET, 0)
		end
	elseif event == "UPDATE_RELATION" then
		if this.dwID == arg0 then
			Target.FoceUpdateCurrentTarget()
		end
	elseif event == "UPDATE_ALL_RELATION" then
		Target.FoceUpdateCurrentTarget()
	elseif event == "PLAYER_LEVEL_UP" then
		if this.dwType == TARGET.PLAYER and this.dwID == arg0 then
			Target.UpdateLevel(this)
		end
	elseif event == "OT_ACTION_PROGRESS_BREAK" then
		if arg0 == this.dwID then
			Target.OnActionBreak(this)
		end
	elseif event == "PARTY_UPDATE_BASE_INFO" then
		Target.FoceUpdateCurrentTarget()
	elseif event == "UPDATE_PLAYER_SCHOOL_ID" then
		if arg0 == this.dwID then
			Target.UpdateHead(this)
			Target.UpdateKungfu(this)
		end
	elseif event == "SET_SHOW_VALUE_BY_PERCENTAGE" then
		Target.UpdateLM(this)
	elseif event == "SET_SHOW_VALUE_TWO_FORMAT" then
		Target.UpdateLM(this)
	elseif event == "SET_TARGET_SHOW_STATE_VALUE" then
		Target.UpdateLM(this)
	elseif event == "PARTY_SET_MARK" then
		Target.UpdateTargetMark(this)
	elseif event == "SET_SHOW_STANDARD_TARGET" then
		Target.FoceUpdateCurrentTarget()
	elseif event == "UI_SCALED" then
		Target.UpdateAnchor(this)
	elseif event == "ON_ENTER_CUSTOM_UI_MODE" or event == "ON_LEAVE_CUSTOM_UI_MODE" then
		UpdateCustomModeWindow(this)
	elseif event == "TARGET_ANCHOR_CHANGED" then
		Target.UpdateAnchor(this)
	elseif event == "NPC_DROP_TARGET_UPDATE" then
		if arg0 == this.dwID then
			Target.UpdateHead(this)
		end
	elseif event == "CUSTOM_DATA_LOADED" then
		Target.UpdateAnchor(this)
	elseif event == "CHANGE_CAMP" or event == "CHANGE_CAMP_FLAG" then
		if arg0 == this.dwID then
			Target.UpdateCamp(this)
		end
	elseif event == "UI_ON_DAMAGE_EVENT" then
		if arg0 == this.dwID then
			Target.OnDamageEvent(this, arg1, arg2)
		end
	elseif event == "TARGET_MINI_AVATAR_MISC" then
		Target.UpdateHead(this)
		Target.UpdateKungfu(this)
	elseif event == "SET_MINI_AVATAR" then
		Target.UpdateHead(this)
	elseif event == "SKILL_MOUNT_KUNG_FU" then
		Target.UpdateKungfu(this)
	elseif event == "SKILL_UNMOUNT_KUNG_FU" then
		Target.UpdateKungfu(this)
	end
end

function Target.OnDamageEvent(hFrame, nDamage, bCriticalStrike)
	local nBarCount = 1
	if hFrame.nIntensity == 2 or hFrame.nIntensity == 3 then
		nBarCount = 2
	elseif hFrame.nIntensity == 4 then
		nBarCount = 3
	end
	
	local hCurHealth = nil
	local hCurSubHealth = nil

	local hHealth3 = hFrame:Lookup("", "Image_Health03")
	local hHealth2 = hFrame:Lookup("", "Image_Health02")
	local hHealth1 = hFrame:Lookup("", "Image_Health")
	if hHealth3 and hHealth3:IsVisible() then
		hCurHealth = hHealth3
		hCurSubHealth = hFrame:Lookup("", "Image_SubHealth03")
	elseif hHealth2 and hHealth2:IsVisible() then
		hCurHealth = hHealth2
		hCurSubHealth = hFrame:Lookup("", "Image_SubHealth02")
	else
		hCurHealth = hHealth1
		hCurSubHealth = hFrame:Lookup("", "Image_SubHealth")
	end

	local hTarget = nil
	if hFrame.dwType == TARGET.PLAYER then
		hTarget = GetPlayer(hFrame.dwID)
	elseif hFrame.dwType == TARGET.NPC then
		hTarget = GetNpc(hFrame.dwID)
	end
	
	local fMainPercent = hCurHealth:GetPercentage()
	if not hTarget or hTarget.nMaxLife == 0 then
		hCurSubHealth:SetPercentage(fMainPercent)
		return
	end
	
	local fCurPercent = hCurSubHealth:GetPercentage()
	local fPercent = (nDamage / hTarget.nMaxLife) % (1 / nBarCount)
	
	if fMainPercent > fCurPercent - fPercent then
		fCurPercent = fMainPercent
	else
		fCurPercent = fCurPercent - fPercent
	end
	
	hCurSubHealth:SetPercentage(fCurPercent)
	
	if IsFrameShake() and bCriticalStrike then
		ShakeWindow(hFrame)
	end
end

function Target.FoceUpdateCurrentTarget()
	local dwType, dwID = GetClientPlayer().GetTarget()
	local as0, as1 = arg0, arg1
	arg0, arg1 = dwType, dwID
	FireEvent("UPDATE_SELECT_TARGET")
	arg0, arg1 = as0, as1
end

function Target.OnItemLButtonDown()
	local frame = this:GetRoot()
	if UserSelect.DoSelectCharacter(frame.dwType, frame.dwID) then
		return
	end
	
	if IsCtrlKeyDown() then
		if IsPlayer(frame.dwID) then 
			if IsGMPanelReceivePlayer() then
				GMPanel_LinkPlayerID(frame.dwID)
			else
				EditBox_AppendLinkPlayer(GetPlayer(frame.dwID).szName)
			end
		else 
			if IsGMPanelReceiveNpc() then
				GMPanel_LinkNpcID(frame.dwID) 
			end
		end
	end
end;

function Target.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_RightButton" then
		Target.OnItemRButtonDown(this:GetRoot())
	end
end

function Target.OnItemRButtonDown(frame)
	local menu = {}
	local player = GetClientPlayer()
	
	if not frame then
		frame = this:GetRoot()
	end
	
	if player.IsInParty() then
		local hTeam = GetClientTeam()
		if player.dwID == hTeam.GetAuthorityInfo(TEAM_AUTHORITY_TYPE.MARK) then -- Party Mark
			InsertMarkMenu(menu, frame.dwID)
		end
	end
	
	if frame.dwType == TARGET.PLAYER and frame.dwID ~= GetClientPlayer().dwID then		
		local objtype, objid = frame.dwType, frame.dwID
		local playerT = GetPlayer(frame.dwID)
		local szTargetName = playerT.szName
		local dwID = frame.dwID
		local hTeam = GetClientTeam()
		local hScene = playerT.GetScene() 
		local fPosX, fPosY, fPosZ = playerT.GetAbsoluteCoordinate()

		if player.IsInParty() then	
			if player.IsPlayerInMyParty(frame.dwID) then
				InsertTeammateLeaderMenu(menu, frame.dwID)
			else
				if player.IsPartyLeader() and not player.IsPartyFull() then
					table.insert(menu, {szOption = g_tStrings.STR_MAKE_PARTY, fnDisable = function() return not CanMakeParty() end, fnAction = function() GetClientTeam().InviteJoinTeam(szTargetName) AddContactPeople(szTargetName) end})
				end
			end
		else
			table.insert(menu, {szOption = g_tStrings.STR_MAKE_PARTY, fnDisable = function() return not CanMakeParty() end, fnAction = function() GetClientTeam().InviteJoinTeam(szTargetName) AddContactPeople(szTargetName) end})
		end
        table.insert(menu, {bDevide = true})
        
        InsertPlayerCommonMenu(menu, dwID, szTargetName)
		table.insert(menu, {szOption = g_tStrings.STR_FIRENDLY_FIGHT, fnDisable = function() return not (GetClientPlayer().CanApplyDuel(dwID)) end, fnAction = function() GetClientPlayer().ApplyDuel(objid) AddContactPeople(szTargetName) end})		
		
		table.insert(menu, {szOption = g_tStrings.STR_ARENA_INVITE_TARGET, 
				{szOption = g_tStrings.tCorpsType[ARENA_TYPE.ARENA_2V2], fnDisable = function() return (not Arena_IsCorpsCreate(ARENA_TYPE.ARENA_2V2)) end, fnAction = function() InvitationJoinCorps(szTargetName, GetCorpsID(ARENA_TYPE.ARENA_2V2, GetClientPlayer().dwID)) end},
				{szOption = g_tStrings.tCorpsType[ARENA_TYPE.ARENA_3V3], fnDisable = function() return (not Arena_IsCorpsCreate(ARENA_TYPE.ARENA_3V3)) end, fnAction = function() InvitationJoinCorps(szTargetName, GetCorpsID(ARENA_TYPE.ARENA_3V3, GetClientPlayer().dwID)) end},
				{szOption = g_tStrings.tCorpsType[ARENA_TYPE.ARENA_5V5], fnDisable = function() return (not Arena_IsCorpsCreate(ARENA_TYPE.ARENA_5V5)) end, fnAction = function() InvitationJoinCorps(szTargetName, GetCorpsID(ARENA_TYPE.ARENA_5V5, GetClientPlayer().dwID)) end},
			}
		)
		table.insert(menu, {bDevide = true})
		
		
		table.insert(menu, {szOption = g_tStrings.STR_MAKE_TRADDING, fnDisable = function() return GetPlayer(dwID).nMoveState == MOVE_STATE.ON_DEATH or not GetClientPlayer().CanDialog(GetPlayer(dwID)) end, 
                fnAction = function() 
                    if CheckPlayerIsRemote() or CheckPlayerIsRemote(dwID) then
                        return
                    end
                    TradingInviteToPlayer(objid) 
                    AddContactPeople(szTargetName) 
                    end})
		table.insert(menu, {szOption = g_tStrings.STR_COMPARE_BOOK, fnDisable = function() return not GetPlayer(dwID) end, fnAction = function() PeekOtherPlayerBook(dwID) end})
		table.insert(menu, {szOption = g_tStrings.STR_LOOKUP, fnDisable = function() return not GetPlayer(dwID) end, fnAction = function() ViewInviteToPlayer(dwID) end })
		table.insert(menu, {szOption = g_tStrings.LOOKUP_ASSIST_QUEST, fnDisable = function() return not GetPlayer(dwID) end, fnAction = function() if CheckPlayerIsRemote(dwID) then return end OpenQuestContrastPanel(dwID) end})		
		table.insert(menu, {szOption = g_tStrings.LOOKUP_ACHIEVEMENT, fnDisable = function() return GetPlayer(dwID) == nil end, fnAction = function() if CheckPlayerIsRemote(dwID) then return end ApplyAchievementData(dwID) end})
		table.insert(menu, {szOption = g_tStrings.LOOKUP_CHANNEL, fnDisable = function() return GetPlayer(dwID) == nil end, fnAction = function() ViewOtherPlayerChannels(dwID) end})
        table.insert(menu, {szOption = g_tStrings.LOOKUP_TANLENT, 
            fnDisable = function() 
                local OtherPlayer = GetPlayer(dwID)
                if not OtherPlayer then
                    return true
                end   
                if OtherPlayer.dwForceID == IDENTITY.JIANG_HU then
                    return true;
                end
                return false
            end, 
            fnAction = function() ViewOtherZhenPaiSkill(dwID) end})
		
		table.insert(menu, {szOption = g_tStrings.LOOKUP_CORPS, 
            fnDisable = function() 
                local OtherPlayer = GetPlayer(dwID)
                if not OtherPlayer then
                    return true
                end   
                return false
            end, 
            fnAction = function() CloseArenaCorpsPanel() OpenArenaCorpsPanel(nil, dwID) end})
			
	    table.insert(menu, {szOption = g_tStrings.MENTOR_GET_APPRENTICE, fnAction = function() RemoteCallToServer("OnApplyApprentice", szTargetName) end})
	    table.insert(menu, {szOption = g_tStrings.MENTOR_GET_MASTER, fnAction = function() RemoteCallToServer("OnApplyMentor", szTargetName) end})
--		table.insert(menu, {szOption = g_tStrings.MENTOR_GET_DIRECT_APPRENTICE, fnAction = function() RemoteCallToServer("OnApplyDirectApprentice", szTargetName) end})
		table.insert(menu, {szOption = g_tStrings.MENTOR_GET_DIRECT_MASTER, fnAction = function() RemoteCallToServer("OnApplyDirectMentor", szTargetName) end})
		
		table.insert(menu, {bDevide = true})
		
		table.insert(menu, {szOption = g_tStrings.STR_ADD_EMENY, fnDisable = function() return not GetClientPlayer().CanAddFoe() or IsPlayerNeutral() or playerT.nCamp == CAMP.NEUTRAL end, fnAction = function() if CheckPlayerIsRemote() or CheckPlayerIsRemote(dwID) then return end RemoteCallToServer("OnPrepareAddFoe", szTargetName) end} )
		--table.insert(menu, {bDevide = true})
		--table.insert(menu, {szOption = g_tStrings.STR_BINGING_ROLE, fnAction = function() RemoteCallToServer("NPProject_MasterBinding", dwID) end})
		--table.insert(menu, {bDevide = true})
		
		table.insert(menu, {szOption = g_tStrings.STR_ADD_BLACKLIST, fnAction = function() if CheckPlayerIsRemote() or CheckPlayerIsRemote(dwID) then return end GetClientPlayer().AddBlackList(szTargetName) if not GetClientPlayer().IsAchievementAcquired(981) then  RemoteCallToServer("OnClientAddAchievement", "BlackList_First_Add") end end})
		
		function ReportRabot()
			local hScene = playerT.GetScene() 	
			local dwMapID, szMapName, fPosX, fPosY, fPosZ = nil, "", nil, nil, nil
			if hScene then
				dwMapID = hScene.dwMapID
				szMapName = Table_GetMapName(dwMapID)
				fPosX, fPosY, fPosZ = playerT.GetAbsoluteCoordinate()
			end
			GMPanel_ReportRabot(szTargetName, szMapName, dwMapID, fPosX, fPosY, fPosZ)
		end
		table.insert(menu, {szOption = g_tStrings.REPORT_RABOT, fnAction = ReportRabot})
		
		if BattleField_IsCanReportPlayer(szTargetName) then
			table.insert(menu, {szOption = g_tStrings.STR_REPORT_GUAJI, fnAction = function() BattleField_ReprotRobot(dwID) end})
		end
	end
	
	local dwID = frame.dwID
	table.insert(menu, {szOption = g_tStrings.BUG_SUBMIT, fnAction = function() if IsPlayer(dwID) then GMPanel_BugReportPlayerID(dwID) else GMPanel_BugReportNpcID(dwID) end end})
	if menu and #menu > 0 then
		PopupMenu(menu)
	end
end

function Target.OnItemMouseHover()
	Target.OnItemMouseEnter()
end

function Target.OnItemMouseEnter()
	local frame = this:GetRoot()
	if UserSelect.IsSelectCharacter() then
		UserSelect.SatisfySelectCharacter(frame.dwType, frame.dwID)
	end	
	
	local szName = this:GetName()
	if not IsTargetShowStateValue() then
		if szName == "Image_Health" then
			local handle = this:GetParent()
			handle:Lookup("Text_Health"):SetText(handle.szHealth)
			return
		elseif szName == "Image_Mana" then
			local handle = this:GetParent()
			handle:Lookup("Text_Mana"):SetText(handle.szMana)
			return
		end
	end
	
	if szName == "Image_Camp" then
		if frame.dwType == TARGET.PLAYER then
			local hPlayer = GetPlayer(frame.dwID)
			local nX, nY = this:GetAbsPos()
			local nWidth, nHeight = this:GetSize()
			local szTip = GetFormatText(g_tStrings.STR_CAMP_TITLE[hPlayer.nCamp], 163)
			if hPlayer.bCampFlag then
				local szText = FormatString(g_tStrings.STR_SYS_MSG_OPEN_CAMP_FALG, "")
				szTip = szTip .. GetFormatText("\n" .. szText, 162)
			end
			OutputTip(szTip, 200, {nX, nY, nWidth, nHeight})
		end
	elseif szName == "Image_Target" then
		if frame.dwType == TARGET.PLAYER then
			local player = GetPlayer(frame.dwID)
			local nX, nY = this:GetAbsPos()
			local nWidth, nHeight = this:GetSize()
			local szTip = GetPlayerKungfuTip(player)
			OutputTip(szTip, 400, {nX, nY, nWidth, nHeight})
		end
	end
end

function Target.OnItemMouseLeave(szSelfName)
	HideTip()
	if not IsTargetShowStateValue() then
		local szName = this:GetName()
		if szName == "Image_Health" then
			this:GetParent():Lookup("Text_Health"):SetText("")
		elseif szName == "Image_Mana" then
			this:GetParent():Lookup("Text_Mana"):SetText("")
		end
	end
	if UserSelect.IsSelectCharacter() then
		UserSelect.SatisfySelectCharacter(TARGET.NO_TARGET, 0, true)
	end
end

function GetNpcIntensity(npc)
	if not npc then
		return 1
	end
	local n = npc.nIntensity
	if n == 2 or n == 6 then --领袖
		return 4
	elseif n == 5 then --头目
		return 3
	elseif n == 4 then -- 高手
		return 2
	end
    return 1 --普通
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

function UpdateBufferTime(hBuffList, hTextList)
    local nCount = hBuffList:GetItemCount() - 1
    for i=0, nCount, 1 do
        local hBox = hBuffList:Lookup(i)
        local hText = hTextList:Lookup(i)
        
        local szTime, nFont, nLeftFrame = GetLeftTime(hBox.nEndFrame)
        if nLeftFrame > 0 then
            if hBox.bShowTime and szTime ~= hText.szTime then
                hText:SetText(szTime)
                hText:SetFontScheme(nFont)
                hText.szTime = szTime
            end
            
            if hBox.bSparking and nLeftFrame < 480 then
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
            else
                hBox:SetAlpha(255)
            end
        end
    end
end

function UpdateSingleBuff(handle, hTextHandle, bDelete, nIndex, bCanCancel, dwBuffID, nCount, nEndFrame, nLevel, dwSkillSrcID, bNotFormat)
	if not Table_BuffIsVisible(dwBuffID, nLevel) then
		return
	end

	local szKey = "b"..nIndex
    local szIniFile = INI_FILE
	if bDelete then
		if handle.tItem[szKey] and lc_nBuffVersion == handle.tVersion[szKey] then
			handle:RemoveItem(handle.tItem[szKey])
			handle:FormatAllItemPos()
			
			local box = handle.tItem[szKey]
			if box.bDispel then 
				RemoveDispelBuffCount()
				box.bDispel = nil
			end
		end
		
		if hTextHandle.tItem[szKey] and lc_nBuffVersion == hTextHandle.tVersion[szKey] then
			hTextHandle:RemoveItem(hTextHandle.tItem[szKey])
			hTextHandle:FormatAllItemPos()
		end
	else
		local box = handle.tItem[szKey]
		local hText = hTextHandle.tItem[szKey]
		if box and hText then
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
			Target.UpdateNewBuff(handle, hTextHandle, nil, nil, nIndex, bCanCancel, dwBuffID, nCount, nEndFrame, nLevel, dwSkillSrcID, bNotFormat)
		end
	end
end

function Target.UpdateNewBuff(handle, hTextHandle, box, hText, nIndex, bCanCancel, dwBuffID, nCount, nEndFrame, nLevel, dwSkillSrcID, bNotFormat)
	local frame = this:GetRoot()
	if not box or not hText then
		local nCount = hTextHandle:GetItemCount()
		hTextHandle:AppendItemFromString("<text>postype=7 halign=1 valign=1</text>")
		hText = hTextHandle:Lookup(nCount)
		
		nCount = handle:GetItemCount()
		handle:AppendItemFromString("<box>w=25 h=25 postype=7 eventid=262912</box>")
		box = handle:Lookup(nCount)
		
		hText:SetText("")
		local nW, nH = box:GetSize()
		box.nW, box.nH = nW, nH
		box.OnItemMouseEnter = function()
			this:SetObjectMouseOver(1)
			local nTime = math.floor(this.nEndFrame - GetLogicFrameCount()) / 16 + 1
			local x, y = this:GetAbsPos()
			local w, h = this:GetSize()
			if nTime < 0 then
			   nTime = 0
			end
			
			OutputBuffTip(frame.dwID, this.dwBuffID, this.nLevel, this.nCount, this.bShowTime and not box.bCanCancel, nTime, {x, y, w, h})					
		end
		box.OnItemMouseHover = box.OnItemMouseEnter
		
		box.OnItemMouseLeave = function()
			HideTip()
			this:SetObjectMouseOver(0)
		end
	end
	
	if not hText then
		Trace("target buff AppendItemFromIni("..INI_FILE..", \"Text_Time\") failed")
		return
	end
	local szKey = "b"..nIndex
	box:SetName(szKey)
	hText:SetName(szKey)

	
	handle.tItem[szKey] = box
	handle.tVersion[szKey] = lc_nBuffVersion
	
	hTextHandle.tItem[szKey] = hText
	hTextHandle.tVersion[szKey] = lc_nBuffVersion
		
	box.bDispel = nil
	local nTW, nTH = hText:GetSize()
	if dwSkillSrcID and UI_GetClientPlayerID() == dwSkillSrcID then
		box:SetSize(box.nW + 5, box.nH + 5)
		hText:SetSize(box.nW + 5, nTH)
		box:SetIndex(0)
		hText:SetIndex(0)
	elseif ((bCanCancel and Target.bIsEnemy) or (not bCanCancel and not Target.bIsEnemy)) and
			IsBuffDispel(dwBuffID, nLevel) then 
		box:SetSize(box.nW + 5, box.nH + 5)
		hText:SetSize(box.nW + 5, nTH)
		box:SetIndex(0)
		hText:SetIndex(0)
		box.bDispel = true
		AddDispelBuffCount()
	else
		box:SetSize(box.nW, box.nH)
		hText:SetSize(box.nW, nTH)
	end
	
	
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
	box:SetAlpha(255)
	
	hText.szTime = nil
	hText:SetText("")
	if box.bShowTime then
		local szTime, nFont, nLeftFrame = GetLeftTime(box.nEndFrame)
		if nLeftFrame > 0 then
			hText:SetText(szTime)
			hText:SetFontScheme(nFont)
			hText.szTime = szTime
		end
	end
	
	if nCount > 1 then
		box:SetOverText(0, nCount)
	else 
		box:SetOverText(0, "")
	end
	
	if not bNotFormat then
		handle:FormatAllItemPos()
		hTextHandle:FormatAllItemPos()
	end
end

local function SetEnemyFlag(hTarget)
	local dwPeerID = hTarget.dwID
	local dwSelfID = UI_GetClientPlayerID()
	
	local src = dwPeerID
	local dest = dwSelfID
	
	if IsPlayer(dwPeerID) and IsPlayer(dwSelfID) then
	    src = dwSelfID
	    dest = dwPeerID
	end
	
	if IsEnemy(src, dest) then 
		Target.bIsEnemy = true
	else
		Target.bIsEnemy = false
	end
end

function OpenTargetPanel(dwType, dwID)
	local player = GetClientPlayer()
	local szName = nil
	local nIntensity = nil
	local hTarget = nil

	local dwMountType
	
    INI_FILE = "ui/config/default/"
	if dwType == TARGET.PLAYER then
		hTarget = GetPlayer(dwID)
		if not hTarget then
			return
		end
		local kungfu = hTarget.GetKungfuMount()
		if kungfu then
			dwMountType =  kungfu.dwMountType
		end
		
		if IsEnemy(dwID, player.dwID) then
			szName = "TargetPlayer11"
		else
			szName = "TargetPlayer10"
		end
	elseif dwType == TARGET.NPC then
		hTarget = GetNpc(dwID)
		if not hTarget then
			return
		end
		nIntensity = GetNpcIntensity(hTarget)
		szName = "Target"..nIntensity
		if IsEnemy(dwID, player.dwID) then
			szName = szName.."2"
		elseif IsNeutrality(dwID, player.dwID) then
			szName = szName.."1"
		else
			szName = szName.."0"
		end
	elseif dwType == TARGET.NO_TARGET then
		CloseTargetPanel()
		return
	end
	if not szName then
		return
	end
	
	if Target.bStandard then
		szName = szName.."S"
	end
    INI_FILE = INI_FILE..szName..".ini"
	local frame = Station.Lookup("Normal/Target")
	if frame then
		if frame.szName ~= szName then
			Wnd.CloseWindow("Target")
			frame = Wnd.OpenWindow(szName, "Target")
			frame.szName = szName
			Target.dwType = nil
			Target.dwID = nil
		end
	else
		frame = Wnd.OpenWindow(szName, "Target")
		frame.szName = szName
	end
	
	frame.dwType = dwType
	frame.dwID = dwID
	frame.nIntensity = nIntensity
	frame.dwMountType = dwMountType
	
	SetEnemyFlag(hTarget)
	
	frame:Show()
	if Target.dwType ~= dwType or Target.dwID ~= dwID then
		Target.dwType = dwType
		Target.dwID = dwID
	
		Target.UpdateState(frame)
		Target.UpdateAnchor(frame)
	else
		Target.UpdateName(frame)
	end
	
	UpdateTargetTarget()
    
	frame:Lookup("", "Handle_Bar").nActionState = nil
		
	local hImageTarget
	if dwType == TARGET.PLAYER then
		hImageTarget = frame:Lookup("", "Image_NewTarget")
	elseif dwType == TARGET.NPC then
		local dwModelID = GetNpc(frame.dwID).dwModelID
		local szProtraitPath = NPC_GetProtrait(dwModelID)
		local szHeadImageFilePath = NPC_GetHeadImageFile(dwModelID)
		if szProtraitPath and IsFileExist(szProtraitPath) then
			szPath = szProtraitPath
		else
			szPath = szHeadImageFilePath
		end
		
		if IsFileExist(szPath) then
			hImageTarget = frame:Lookup("", "Image_NewTarget")
		else
			hImageTarget = frame:Lookup("", "Image_Target")
		end
	end
	
	FireHelpEvent("OnSelectTarget", dwType, dwID, hImageTarget)
end

function IsTargetPanelOpened()
	local frame = Station.Lookup("Normal/Target")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end

function CloseTargetPanel()
	local frame = Station.Lookup("Normal/Target")
	if frame then
		frame:Hide()
	end

	SelectTarget(TARGET.NO_TARGET, 0)
	
	Target.dwType = nil
	Target.dwID = nil
			
	UpdateTargetTarget()
end

function IsTargetShowStateValue()
	if Target.bShowStateValue then
		return true
	end
	return false
end

function SetTargetShowStateValue(bShow)
	if Target.bShowStateValue == bShow then
		return
	end
	Target.bShowStateValue = bShow
	
	FireEvent("SET_TARGET_SHOW_STATE_VALUE")
end

function IsTargetShowActionBar()
	if Target.bShowActionBar then
		return true
	end
	return false
end

function SetTargetShowActionBar(bShow)
	Target.bShowActionBar = bShow
end

function SetShowStandardTarget(bStandard)
	Target.bStandard = bStandard
	FireEvent("SET_SHOW_STANDARD_TARGET")
end

function IsShowStandardTarget()
	return Target.bStandard
end

function SelectTarget(dwType, dwID)
	local bSel = false
	local player = GetClientPlayer();
	if not player then
		return
	end
	
	if dwType == TARGET.PLAYER then
		bSel = CanSelectPlayer(dwID)
	elseif dwType == TARGET.NPC then
		bSel = CanSelectNpc(dwID)
	elseif dwType == TARGET.DOODAD then
		--bSel = CanSelectDoodad(dwID) 界面不能选中doodad
	elseif dwType == TARGET.NO_TARGET then
		bSel = true
	end
	
	if not bSel then
		dwType = TARGET.NO_TARGET
		dwID = 0
	end
	
	local as0, as1 = arg0, arg1
	SetTarget(dwType, dwID)
	arg0, arg1 = as0, as1
end

function SelectSelf()
	local player = GetClientPlayer()
	SetTarget(TARGET.PLAYER, player.dwID)
end

function GetTargetLevelFont(nLevelDiff)
	local nFont = 16
	if nLevelDiff > 4 then	-- 红
		nFont = 159
	elseif nLevelDiff > 2 then	-- 桔
		nFont = 168
	elseif nLevelDiff > -3 then	-- 黄
		nFont = 16
	elseif nLevelDiff > -6 then	-- 绿
		nFont = 167
	else				-- 灰
		nFont = 169
	end
	return nFont
end

function Target_SetAnchorDefault()
	Target.Anchor.s = Target.DefaultAnchor.s
	Target.Anchor.r = Target.DefaultAnchor.r
	Target.Anchor.x = Target.DefaultAnchor.x
	Target.Anchor.y = Target.DefaultAnchor.y
	FireEvent("TARGET_ANCHOR_CHANGED")
end

function Target_VersionChange()
    if arg0 == "Role" and Target.nVersion < Target.nCurrentVersion then
        Target.nVersion = Target.nCurrentVersion
        Target.Anchor = {s = "TOPLEFT", r = "TOPLEFT", x = 480, y = 10}
        FireUIEvent("TARGET_ANCHOR_CHANGED")
    end
end

RegisterEvent("CUSTOM_UI_MODE_SET_DEFAULT", Target_SetAnchorDefault)
RegisterEvent("CUSTOM_DATA_LOADED", Target_VersionChange)

function Target_GetTargetID()
	return Target.dwID
end

function Target_IsEnemy()
	return Target.bIsEnemy
end

function Target_GetTargetData()
	return Target.dwID, Target.dwType
end