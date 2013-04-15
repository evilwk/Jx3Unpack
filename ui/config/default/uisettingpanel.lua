UISettingPanel = 
{
	minUIScale = 0.7,
	maxUIScale = 1.0,
	defaultUIScale = 0.9,
	nUIStep = 3000,
	nUIPageStep = 100,
	
	nShakeMode = 0,
	bCloseGJInJump = false,
}
	
local l_tCameraDefaultSetting =
{
    nResetMode = 1,
    fDragSpeed = 1.0,
    fMaxCameraDistance = 800,
    nShakeMode = 0,
    bFrameShake = false,
    nAngle = 45,
    bCloseGJInJump = false,
}
local CAMERA_SETTTING = {}

function UISettingPanel.OnFrameCreate()
	this:RegisterEvent("UI_SCALED")
		
	this.bDisable = true
	this.bDisableSound = true
    UISettingPanel.InitCameraSettings(this)
	UISettingPanel.DumpCameraSettings(this)
	UISettingPanel.DumpActionBarSetting(this)
	UISettingPanel.DumpDisplaySetting(this)
	UISettingPanel.DumpStateValueSetting(this)
	UISettingPanel.DumpCombatSetting(this)
	UISettingPanel.DumpBagSetting(this)
	UISettingPanel.DumpBuffSetting(this)
	UISettingPanel.DumpHatredSetting(this)
	UISettingPanel.DumpBasicSetting(this)
	
	UISettingPanel.OnEvent("UI_SCALED")
	
	local hList = this:Lookup("", "Handle_List")
	UISettingPanel.SelectPage(hList:Lookup(0))	
	
	UISettingPanel.SetChanged(this, false)
	this.bDisableSound = false
	this.bDisable = false
	
	local _, _, szVersionLineName = GetVersion()
	local hCheckKoreaLogo = this:Lookup("Wnd_BasicSetting/CheckBox_KoreaLogo")
	local hCheckHelpComment = this:Lookup("Wnd_BasicSetting/CheckBox_HelpComment")
	if szVersionLineName == "zhkr" then
		hCheckHelpComment:Hide()
		hCheckKoreaLogo:Show()
	else 
		hCheckHelpComment:Show()
		hCheckKoreaLogo:Hide()
	end
end

function UISettingPanel.OnEvent(event)
	if event == "UI_SCALED" then
		if not this.bDisable then
			this.bDisableSound = true
			UISettingPanel.DumpBasicSetting(this)
			this.bDisableSound = false			
		end
		
		local hList = this:Lookup("", "Handle_List")
		UISettingPanel.UpdateScrollInfo(hList)
		this:SetPoint("CENTER", 0, 0, "CENTER", 0, 0)
	end
end

function UISettingPanel.InitCameraSettings(frame)
    CAMERA_SETTTING = CAMERA_SETTTING or {}
	local fDragSpeed, fMaxCameraDistance, fSpringResetSpeed, fCameraResetSpeed, nResetMode = Camera_GetParams()
	CAMERA_SETTTING.nResetMode = nResetMode
	CAMERA_SETTTING.fDragSpeed = fDragSpeed
	CAMERA_SETTTING.nShakeMode = UISettingPanel.nShakeMode
	CAMERA_SETTTING.bFrameShake = IsFrameShake()
	CAMERA_SETTTING.bCloseGJInJump = UISettingPanel.bCloseGJInJump
	
	local wndCamera = frame:Lookup("Wnd_Camera")
	local hScrollCS = wndCamera:Lookup("Scroll_CS")
	hScrollCS.Slider = cMultipleSlider.new(3, 20)
	hScrollCS:SetStepCount(20)
	
	CAMERA_SETTTING.fMaxCameraDistance = fMaxCameraDistance
	local hScrollCH = wndCamera:Lookup("Scroll_CH")
	hScrollCH.Slider = cSlider.new(1, 2000, 100)
	hScrollCH:SetStepCount(100)
	
	local a3DEngineOption = KG3DEngine.Get3DEngineOption()
	local a3DEngineCaps = KG3DEngine.Get3DEngineOptionCaps(a3DEngineOption)
    
	local nMinAngle = math.floor(a3DEngineCaps.fMinCameraAngle * 180 / math.pi)
	local nMaxAngle = math.floor(a3DEngineCaps.fMaxCameraAngle * 180 / math.pi)
	
	CAMERA_SETTTING.nAngle = math.floor(a3DEngineOption.fCameraAngle * 180 / math.pi)
	UISettingPanel.fPrecision = a3DEngineOption.fCameraAngle - (CAMERA_SETTTING.nAngle * math.pi / 180)
	
	local hScrollGJ = wndCamera:Lookup("Scroll_GJ")
	local nTotalCount = nMaxAngle - nMinAngle
	hScrollGJ.Slider = cSlider.new(nMinAngle, nMaxAngle, nTotalCount)
	hScrollGJ:SetStepCount(nTotalCount)
end

function UISettingPanel.DumpCameraSettings(frame)
    local tSettings = CAMERA_SETTTING
    local wndCamera = frame:Lookup("Wnd_Camera")
	wndCamera:Lookup("CheckBox_C1"):Check(tSettings.nResetMode == 0)
	wndCamera:Lookup("CheckBox_C2"):Check(tSettings.nResetMode == 1)
	wndCamera:Lookup("CheckBox_C3"):Check(tSettings.nResetMode == 2)
	
	--wndCamera:Lookup("CheckBox_Shake"):Check(tSettings.bShock)
	
	local hTextShake = wndCamera:Lookup("Btn_Shake"):Lookup("", "Text_Shake")
	hTextShake:SetText(g_tStrings.tShakeTitle[tSettings.nShakeMode])
	hTextShake.szType = nil
	
	wndCamera:Lookup("CheckBox_TargetShake"):Check(tSettings.bFrameShake)
	
	local hScrollCS = wndCamera:Lookup("Scroll_CS")
    local nStep = math.ceil(hScrollCS.Slider:GetStep(tSettings.fDragSpeed));
	hScrollCS:SetScrollPos(nStep)
	
	local hScrollCH = wndCamera:Lookup("Scroll_CH")
	hScrollCH:SetScrollPos(hScrollCH.Slider:GetStep(tSettings.fMaxCameraDistance))
	
	local hScrollGJ = wndCamera:Lookup("Scroll_GJ")
	hScrollGJ:SetScrollPos(hScrollGJ.Slider:GetStep(tSettings.nAngle))
	
	wndCamera:Lookup("CheckBox_CloseGJ"):Check(tSettings.bCloseGJInJump)
end

function UISettingPanel.DumpBasicSetting(frame)
	local wndBasic = frame:Lookup("Wnd_BasicSetting")

	local sU = wndBasic:Lookup("Scroll_UIScale")
	local fS = Station.GetMaxUIScale()
	sU.Slider = cSlider.new(fS * UISettingPanel.minUIScale, fS * UISettingPanel.maxUIScale, UISettingPanel.nUIStep)
	sU:SetStepCount(UISettingPanel.nUIStep)
	sU:SetPageStepCount(UISettingPanel.nUIPageStep)
	sU:SetScrollPos(sU.Slider:GetStep(Station.GetUIScale()))
	
	local sT = wndBasic:Lookup("Scroll_TextScale")
	sT:SetScrollPos(2 + Font.GetOffset())
	
	wndBasic:Lookup("CheckBox_CastKeep"):Check(IsCastSkillKeepDown())
	wndBasic:Lookup("CheckBox_AutoCast"):Check(IsSelfCastSkill())
	wndBasic:Lookup("CheckBox_SwapMouse"):Check(IsMouseButtonSwaped())
	wndBasic:Lookup("CheckBox_AutoPickup"):Check(LootList_IsRButtonPickupAll())
	wndBasic:Lookup("CheckBox_NearMouse"):Check(LootList_IsOpenPosNearMouse())
	wndBasic:Lookup("CheckBox_Help"):Check(IsShowHelpPanel())
	wndBasic:Lookup("CheckBox_Edit"):Check(not IsEditBoxAlwaysShow())
	wndBasic:Lookup("CheckBox_TarAct"):Check(IsTargetShowActionBar())
	wndBasic:Lookup("CheckBox_LoginTip"):Check(IsShowLoginTip())
	wndBasic:Lookup("CheckBox_StandardTarget"):Check(IsShowStandardTarget())
	wndBasic:Lookup("CheckBox_Matrix"):Check(IsShowMatrix())
	wndBasic:Lookup("CheckBox_AutoShow"):Check(IsAutoTraceQuest())
	wndBasic:Lookup("CheckBox_MouseMove"):Check(IsMouseMove())
    wndBasic:Lookup("CheckBox_SearchTarget"):Check(not SearchTarget_IsOldVerion())
	wndBasic:Lookup("CheckBox_KoreaLogo"):Check(IsShowKoreaLogo())
	wndBasic:Lookup("CheckBox_BattleMap"):Check(BattleFieldMap_IsTurnOn())
end

function UISettingPanel.DumpBagSetting(frame)
	local wndBag = frame:Lookup("Wnd_Bag")
	wndBag:Lookup("CheckBox_Big"):Check(IsUseBigBagPanel())
	wndBag:Lookup("CheckBox_BagC"):Check(IsUseCompactBagPanel())
	wndBag:Lookup("CheckBox_BankC"):Check(IsUseCompactBankPanel())
	wndBag:Lookup("CheckBox_BagSize"):Check(IsShowBagSize())
	wndBag:Lookup("CheckBox_BagBg"):Check(IsBagShowBg())
	
	local text_A = wndBag:Lookup("", "Text_BagSort")
	local szType = GetBagSortType()
	if szType == "left_to_right" then
		text_A:SetText(g_tStrings.SORT_LEFT_RIGHT)
	elseif szType == "right_to_left" then
		text_A:SetText(g_tStrings.SORT_RIGHT_LEFT)
	elseif szType == "top_to_bottom" then
		text_A:SetText(g_tStrings.SORT_TOP_BOTTOM)
	elseif szType == "bottom_to_top" then
		text_A:SetText(g_tStrings.SORT_BOTTOM_TOP)
	else
		text_A:SetText(g_tStrings.SORT_RIGHT_LEFT)
	end
	text_A.szType = nil
end

function UISettingPanel.DumpBuffSetting(frame)
	local wndBuff = frame:Lookup("Wnd_Buff")
	wndBuff:Lookup("CheckBox_BuffShowText"):Check(IsBuffListShowText())
	wndBuff:Lookup("CheckBox_DebuffShowText"):Check(IsDebuffListShowText())

	local text_A = wndBuff:Lookup("", "Text_BuffSort")
	local szType = GetBuffListSortType()
	if szType == "right_to_left" then
		text_A:SetText(g_tStrings.SORT_RIGHT_LEFT)
	elseif szType == "left_to_right" then
		text_A:SetText(g_tStrings.SORT_LEFT_RIGHT)
	end
	text_A.szType = nil

	local text_A = wndBuff:Lookup("", "Text_DebuffSort")
	local szType = GetDebuffListSortType()
	if szType == "right_to_left" then
		text_A:SetText(g_tStrings.SORT_RIGHT_LEFT)
	elseif szType == "left_to_right" then
		text_A:SetText(g_tStrings.SORT_LEFT_RIGHT)
	end
	text_A.szType = nil

	local scroll = wndBuff:Lookup("Scroll_BuffLine")
	scroll:SetStepCount(15)
	scroll:SetScrollPos(GetBuffListLine() - 1)
	wndBuff:Lookup("", "Text_BuffLine"):SetText(GetBuffListLine())

	local scroll = wndBuff:Lookup("Scroll_BuffSize")
	scroll:SetStepCount(52)
	scroll:SetScrollPos(GetBuffListSize() - 12)
	wndBuff:Lookup("", "Text_BuffSize"):SetText(GetBuffListSize())
	
	local scroll = wndBuff:Lookup("Scroll_DebuffLine")
	scroll:SetStepCount(15)
	scroll:SetScrollPos(GetDebuffListLine() - 1)
	wndBuff:Lookup("", "Text_DebuffLine"):SetText(GetDebuffListLine())

	local scroll = wndBuff:Lookup("Scroll_DebuffSize")
	scroll:SetStepCount(52)
	scroll:SetScrollPos(GetDebuffListSize() - 12)
	wndBuff:Lookup("", "Text_DebuffSize"):SetText(GetDebuffListSize())

end

function UISettingPanel.DumpHatredSetting(frame)
	local wndHatred = frame:Lookup("Wnd_Hatred")
	---============仇恨统计==================
	local szType = GetShowHatredPanelType()
	if szType == "close" then
		wndHatred:Lookup("CheckBox_Close"):Check(true)
		wndHatred:Lookup("CheckBox_Dungeon"):Check(false)
		wndHatred:Lookup("CheckBox_AlwaysDisplay"):Check(false)
		wndHatred:Lookup("CheckBox_PartyShow"):Check(false)
	elseif szType == "copy" then
		wndHatred:Lookup("CheckBox_Close"):Check(false)
		wndHatred:Lookup("CheckBox_Dungeon"):Check(true)
		wndHatred:Lookup("CheckBox_AlwaysDisplay"):Check(false)
		wndHatred:Lookup("CheckBox_PartyShow"):Check(false)
	elseif szType == "party" then
		wndHatred:Lookup("CheckBox_PartyShow"):Check(true)
		wndHatred:Lookup("CheckBox_Close"):Check(false)
		wndHatred:Lookup("CheckBox_Dungeon"):Check(false)
		wndHatred:Lookup("CheckBox_AlwaysDisplay"):Check(false)
	else
		wndHatred:Lookup("CheckBox_Close"):Check(false)
		wndHatred:Lookup("CheckBox_Dungeon"):Check(false)
		wndHatred:Lookup("CheckBox_AlwaysDisplay"):Check(true)
		wndHatred:Lookup("CheckBox_PartyShow"):Check(false)
	end
		
	if IsHatredPanelShowForceColor() then
		wndHatred:Lookup("CheckBox_SchoolColor"):Check(true)
	else
		wndHatred:Lookup("CheckBox_SchoolColor"):Check(false)
	end
	---============伤害统计==================
	local szType = GetFStatisticOpenType()
	if szType == "close" then
		wndHatred:Lookup("CheckBox_CloseF"):Check(true)
		wndHatred:Lookup("CheckBox_DungeonF"):Check(false)
		wndHatred:Lookup("CheckBox_AlwaysDisplayF"):Check(false)
		wndHatred:Lookup("CheckBox_PartyShowF"):Check(false)
	elseif szType == "copy" then
		wndHatred:Lookup("CheckBox_CloseF"):Check(false)
		wndHatred:Lookup("CheckBox_DungeonF"):Check(true)
		wndHatred:Lookup("CheckBox_AlwaysDisplayF"):Check(false)
		wndHatred:Lookup("CheckBox_PartyShowF"):Check(false)
	elseif szType == "party" then
		wndHatred:Lookup("CheckBox_CloseF"):Check(false)
		wndHatred:Lookup("CheckBox_DungeonF"):Check(false)
		wndHatred:Lookup("CheckBox_AlwaysDisplayF"):Check(false)
		wndHatred:Lookup("CheckBox_PartyShowF"):Check(true)
	else
		wndHatred:Lookup("CheckBox_CloseF"):Check(false)
		wndHatred:Lookup("CheckBox_DungeonF"):Check(false)
		wndHatred:Lookup("CheckBox_AlwaysDisplayF"):Check(true)
		wndHatred:Lookup("CheckBox_PartyShowF"):Check(false)
	end
end

function UISettingPanel.DumpDisplaySetting(frame)
	local WndDisplay = frame:Lookup("Wnd_Display")
	
	WndDisplay:Lookup("CheckBox_NN"):Check(GetGlobalTopHeadFlag(GLOBAL_HEAD_NPC, GLOBAL_HEAD_NAME))
	WndDisplay:Lookup("CheckBox_NT"):Check(GetGlobalTopHeadFlag(GLOBAL_HEAD_NPC, GLOBAL_HEAD_TITLE))
	WndDisplay:Lookup("CheckBox_NB"):Check(GetGlobalTopHeadFlag(GLOBAL_HEAD_NPC, GLOBAL_HEAD_LEFE))	
	WndDisplay:Lookup("CheckBox_PN"):Check(GetGlobalTopHeadFlag(GLOBAL_HEAD_OTHERPLAYER, GLOBAL_HEAD_NAME))
	WndDisplay:Lookup("CheckBox_PT"):Check(GetGlobalTopHeadFlag(GLOBAL_HEAD_OTHERPLAYER, GLOBAL_HEAD_TITLE))
	WndDisplay:Lookup("CheckBox_PB"):Check(GetGlobalTopHeadFlag(GLOBAL_HEAD_OTHERPLAYER, GLOBAL_HEAD_LEFE))
	WndDisplay:Lookup("CheckBox_SN"):Check(GetGlobalTopHeadFlag(GLOBAL_HEAD_CLIENTPLAYER, GLOBAL_HEAD_NAME))
	WndDisplay:Lookup("CheckBox_ST"):Check(GetGlobalTopHeadFlag(GLOBAL_HEAD_CLIENTPLAYER, GLOBAL_HEAD_TITLE))
	WndDisplay:Lookup("CheckBox_SB"):Check(GetGlobalTopHeadFlag(GLOBAL_HEAD_CLIENTPLAYER, GLOBAL_HEAD_LEFE))	
	WndDisplay:Lookup("CheckBox_ShowSelfGuild"):Check(GetGlobalTopHeadFlag(GLOBAL_HEAD_CLIENTPLAYER, GLOBAL_HEAD_GUILD))
	WndDisplay:Lookup("CheckBox_ShowOtherGuild"):Check(GetGlobalTopHeadFlag(GLOBAL_HEAD_OTHERPLAYER, GLOBAL_HEAD_GUILD))
	WndDisplay:Lookup("CheckBox_PlayerP"):Check(IsPlayerBalloonVisible())
	WndDisplay:Lookup("CheckBox_NpcP"):Check(IsNpcBalloonVisible())
	WndDisplay:Lookup("CheckBox_TargetTarget"):Check(IsShowTargetTarget())
	WndDisplay:Lookup("CheckBox_HideQuest"):Check(IsHideQuestShow())
	WndDisplay:Lookup("CheckBox_HideHead"):Check(GetClientPlayer().bHideHat)
	WndDisplay:Lookup("CheckBox_ShowTeamQuest"):Check(IsShowTeamateQuestTrace())
	WndDisplay:Lookup("CheckBox_SkillTip"):Check(IsSkillTipPanel())
	
	do
        local a3DEngineOption = KG3DEngine.Get3DEngineOption()
        WndDisplay:Lookup("CheckBox_TDName"):Check(not a3DEngineOption.b2DCaptionSave)
	end
end

function UISettingPanel.DumpActionBarSetting(frame)
	local WndActionBar = frame:Lookup("Wnd_ActionBar")
	
	WndActionBar:Lookup("CheckBox_AL"):Check(IsActionBarLocked())
	
	WndActionBar:Lookup("CheckBox_A1"):Check(IsActionBarOpened(1))
	WndActionBar:Lookup("CheckBox_A2"):Check(IsActionBarOpened(2))
	WndActionBar:Lookup("CheckBox_A3"):Check(IsActionBarOpened(3))
	WndActionBar:Lookup("CheckBox_A4"):Check(IsActionBarOpened(4))
	
	WndActionBar:Lookup("CheckBox_ShowA1Bg"):Check(IsShowActionBarBg(1))
	WndActionBar:Lookup("CheckBox_ShowA2Bg"):Check(IsShowActionBarBg(2))
	WndActionBar:Lookup("CheckBox_ShowA3Bg"):Check(IsShowActionBarBg(3))
	WndActionBar:Lookup("CheckBox_ShowA4Bg"):Check(IsShowActionBarBg(4))
	
	local scroll = WndActionBar:Lookup("Scroll_A3Box")
	scroll:SetStepCount(15)
	scroll:SetScrollPos(GetActionBarCount(3) - 1)
	WndActionBar:Lookup("", "Text_A3BoxV"):SetText(GetActionBarCount(3))
	
	local scroll = WndActionBar:Lookup("Scroll_A3Raw")
	scroll:SetStepCount(15)
	scroll:SetScrollPos(GetActionBarLine(3) - 1)
	WndActionBar:Lookup("", "Text_A3RawV"):SetText(GetActionBarLine(3))

	local scroll = WndActionBar:Lookup("Scroll_A4Box")
	scroll:SetStepCount(15)
	scroll:SetScrollPos(GetActionBarCount(4) - 1)
	WndActionBar:Lookup("", "Text_A4BoxV"):SetText(GetActionBarCount(4))
	
	local scroll = WndActionBar:Lookup("Scroll_A4Raw")
	scroll:SetStepCount(15)
	scroll:SetScrollPos(GetActionBarLine(4) - 1)
	WndActionBar:Lookup("", "Text_A4RawV"):SetText(GetActionBarLine(4))
end

function UISettingPanel.DumpStateValueSetting(frame)
	local wndStateValue = frame:Lookup("Wnd_StateValue")
	
	wndStateValue:Lookup("CheckBox_Player"):Check(IsPlayerShowStateValue())
	wndStateValue:Lookup("CheckBox_Target"):Check(IsTargetShowStateValue())
	wndStateValue:Lookup("CheckBox_Team"):Check(IsTeammateShowStateValue())
	wndStateValue:Lookup("CheckBox_Persent"):Check(IsShowStateValueByPercentage())
	wndStateValue:Lookup("CheckBox_Exp"):Check(IsExpShowStateValue())
	wndStateValue:Lookup("CheckBox_Cool"):Check(IsActionBarCoolDownShow())
	wndStateValue:Lookup("CheckBox_TowFormat"):Check(IsShowStateValueTwoFormat())
end

function UISettingPanel.DumpCombatSetting(frame)
	local wndCombat = frame:Lookup("Wnd_Combat")
	
	wndCombat:Lookup("CheckBox_Merge"):Check(IsMergeDamage())

	local t = GetCombatMeToTargetSetting()
	
	wndCombat:Lookup("CheckBox_DD01"):Check(t.bShangHai)
	wndCombat:Lookup("CheckBox_DH01"):Check(t.bZhiLiao)
	wndCombat:Lookup("CheckBox_DC01"):Check(t.bQiTa)
	if t.bQiTa then
		wndCombat:Lookup("CheckBox_Recovery01"):Check(t.bChaiZhao)
		wndCombat:Lookup("CheckBox_Hedge01"):Check(t.bDuoShan)
		wndCombat:Lookup("CheckBox_HitOff01"):Check(t.bPianLi)
		wndCombat:Lookup("CheckBox_Discern01"):Check(t.bShiPo)
		wndCombat:Lookup("CheckBox_HJ01"):Check(t.bHuaJie)
		wndCombat:Lookup("CheckBox_MY01"):Check(t.bMianYi)
		wndCombat:Lookup("CheckBox_DX01"):Check(t.bDiXiao)
		wndCombat:Lookup("CheckBox_ShowSkill"):Check(t.bSkillName)
	else
		wndCombat:Lookup("CheckBox_Recovery01"):Enable(false)
		wndCombat:Lookup("CheckBox_Hedge01"):Enable(false)
		wndCombat:Lookup("CheckBox_HitOff01"):Enable(false)
		wndCombat:Lookup("CheckBox_Discern01"):Enable(false)
		wndCombat:Lookup("CheckBox_HJ01"):Enable(false)
		wndCombat:Lookup("CheckBox_MY01"):Enable(false)
		wndCombat:Lookup("CheckBox_DX01"):Enable(false)
		wndCombat:Lookup("CheckBox_ShowSkill"):Enable(false)
	end
		
	local t = GetCombatTargetToMeSetting()
	
	wndCombat:Lookup("CheckBox_DD02"):Check(t.bShangHai)
	wndCombat:Lookup("CheckBox_DH02"):Check(t.bZhiLiao)
	wndCombat:Lookup("CheckBox_DC02"):Check(t.bQiTa)
	if t.bQiTa then
		wndCombat:Lookup("CheckBox_Recovery02"):Check(t.bChaiZhao)
		wndCombat:Lookup("CheckBox_Hedge02"):Check(t.bDuoShan)
		wndCombat:Lookup("CheckBox_HitOff02"):Check(t.bPianLi)
		wndCombat:Lookup("CheckBox_HJ02"):Check(t.bHuaJie)
		wndCombat:Lookup("CheckBox_MY02"):Check(t.bMianYi)
		wndCombat:Lookup("CheckBox_DX02"):Check(t.bDiXiao)
		wndCombat:Lookup("CheckBox_GB02"):Check(t.bZengYi)
		wndCombat:Lookup("CheckBox_GD02"):Check(t.bJianYi)
		wndCombat:Lookup("CheckBox_ShowSkill1"):Check(t.bSkillName)
	else
		wndCombat:Lookup("CheckBox_Recovery02"):Enable(false)
		wndCombat:Lookup("CheckBox_Hedge02"):Enable(false)
		wndCombat:Lookup("CheckBox_HitOff02"):Enable(false)
		wndCombat:Lookup("CheckBox_HJ02"):Enable(false)
		wndCombat:Lookup("CheckBox_MY02"):Enable(false)
		wndCombat:Lookup("CheckBox_DX02"):Enable(false)
		wndCombat:Lookup("CheckBox_GB02"):Enable(false)
		wndCombat:Lookup("CheckBox_GD02"):Enable(false)
		wndCombat:Lookup("CheckBox_ShowSkill1"):Enable(false)
	end
end

function UISettingPanel.SetChanged(frame, bChanged)
	frame.bChanged = bChanged
	frame:Lookup("Btn_Apply"):Enable(frame.bChanged)
end

function UISettingPanel.OnCheckBoxCheck()
	local szName = this:GetName()
	if szName == "CheckBox_AutoCast" then
		this:GetParent():Lookup("CheckBox_CastKeep"):Check(false)
		this:GetParent():Lookup("CheckBox_CastKeep"):Enable(false)
	elseif szName == "CheckBox_DC01" then
		local wndCombat = this:GetParent()
		wndCombat:Lookup("CheckBox_Recovery01"):Enable(true)
		wndCombat:Lookup("CheckBox_Hedge01"):Enable(true)
		wndCombat:Lookup("CheckBox_HitOff01"):Enable(true)
		wndCombat:Lookup("CheckBox_Discern01"):Enable(true)
		wndCombat:Lookup("CheckBox_HJ01"):Enable(true)
		wndCombat:Lookup("CheckBox_MY01"):Enable(true)
		wndCombat:Lookup("CheckBox_DX01"):Enable(true)
		wndCombat:Lookup("CheckBox_ShowSkill"):Enable(true)
		local t = GetCombatMeToTargetSetting()
		wndCombat:Lookup("CheckBox_Recovery01"):Check(t.bChaiZhao)
		wndCombat:Lookup("CheckBox_Hedge01"):Check(t.bDuoShan)
		wndCombat:Lookup("CheckBox_HitOff01"):Check(t.bPianLi)
		wndCombat:Lookup("CheckBox_Discern01"):Check(t.bShiPo)
		wndCombat:Lookup("CheckBox_HJ01"):Check(t.bHuaJie)
		wndCombat:Lookup("CheckBox_MY01"):Check(t.bMianYi)
		wndCombat:Lookup("CheckBox_DX01"):Check(t.bDiXiao)
		wndCombat:Lookup("CheckBox_ShowSkill"):Check(t.bSkillName)
	elseif szName == "CheckBox_DC02" then
		local wndCombat = this:GetParent()
		wndCombat:Lookup("CheckBox_Recovery02"):Enable(true)
		wndCombat:Lookup("CheckBox_Hedge02"):Enable(true)
		wndCombat:Lookup("CheckBox_HitOff02"):Enable(true)
		wndCombat:Lookup("CheckBox_HJ02"):Enable(true)
		wndCombat:Lookup("CheckBox_MY02"):Enable(true)
		wndCombat:Lookup("CheckBox_DX02"):Enable(true)
		wndCombat:Lookup("CheckBox_GB02"):Enable(true)
		wndCombat:Lookup("CheckBox_GD02"):Enable(true)
		wndCombat:Lookup("CheckBox_ShowSkill1"):Enable(true)
		local t = GetCombatTargetToMeSetting()		
		wndCombat:Lookup("CheckBox_Recovery02"):Check(t.bChaiZhao)
		wndCombat:Lookup("CheckBox_Hedge02"):Check(t.bDuoShan)
		wndCombat:Lookup("CheckBox_HitOff02"):Check(t.bPianLi)
		wndCombat:Lookup("CheckBox_HJ02"):Check(t.bHuaJie)
		wndCombat:Lookup("CheckBox_MY02"):Check(t.bMianYi)
		wndCombat:Lookup("CheckBox_DX02"):Check(t.bDiXiao)
		wndCombat:Lookup("CheckBox_GB02"):Check(t.bZengYi)
		wndCombat:Lookup("CheckBox_GD02"):Check(t.bJianYi)
		wndCombat:Lookup("CheckBox_ShowSkill1"):Check(t.bSkillName)
	elseif szName == "CheckBox_AlwaysDisplay" then
		this:GetParent():Lookup("CheckBox_Dungeon"):Check(false)
		this:GetParent():Lookup("CheckBox_Close"):Check(false)
		this:GetParent():Lookup("CheckBox_PartyShow"):Check(false)
	elseif szName == "CheckBox_Dungeon" then	
		this:GetParent():Lookup("CheckBox_AlwaysDisplay"):Check(false)
		this:GetParent():Lookup("CheckBox_Close"):Check(false)
		this:GetParent():Lookup("CheckBox_PartyShow"):Check(false)
		
	elseif szName == "CheckBox_PartyShow" then
		this:GetParent():Lookup("CheckBox_AlwaysDisplay"):Check(false)
		this:GetParent():Lookup("CheckBox_Dungeon"):Check(false)
		this:GetParent():Lookup("CheckBox_Close"):Check(false)
		
	elseif szName == "CheckBox_Close" then
		this:GetParent():Lookup("CheckBox_AlwaysDisplay"):Check(false)
		this:GetParent():Lookup("CheckBox_Dungeon"):Check(false)
		this:GetParent():Lookup("CheckBox_PartyShow"):Check(false)
	
	elseif szName == "CheckBox_AlwaysDisplayF" then
		this:GetParent():Lookup("CheckBox_DungeonF"):Check(false)
		this:GetParent():Lookup("CheckBox_CloseF"):Check(false)
		this:GetParent():Lookup("CheckBox_PartyShowF"):Check(false)
		
	elseif szName == "CheckBox_DungeonF" then	
		this:GetParent():Lookup("CheckBox_AlwaysDisplayF"):Check(false)
		this:GetParent():Lookup("CheckBox_CloseF"):Check(false)
		this:GetParent():Lookup("CheckBox_PartyShowF"):Check(false)
		
	elseif szName == "CheckBox_CloseF" then
		this:GetParent():Lookup("CheckBox_AlwaysDisplayF"):Check(false)
		this:GetParent():Lookup("CheckBox_DungeonF"):Check(false)
		this:GetParent():Lookup("CheckBox_PartyShowF"):Check(false)
	
	elseif szName == "CheckBox_PartyShowF" then
		this:GetParent():Lookup("CheckBox_AlwaysDisplayF"):Check(false)
		this:GetParent():Lookup("CheckBox_DungeonF"):Check(false)
		this:GetParent():Lookup("CheckBox_CloseF"):Check(false)
		
	elseif szName == "CheckBox_C1" or szName == "CheckBox_C2" or szName == "CheckBox_C3" then
		this:GetParent():Lookup("CheckBox_C1"):Check(szName == "CheckBox_C1")
		this:GetParent():Lookup("CheckBox_C2"):Check(szName == "CheckBox_C2")
		this:GetParent():Lookup("CheckBox_C3"):Check(szName == "CheckBox_C3")
    end
	
	local frame = this:GetRoot()
	if not frame.bDisable then
		UISettingPanel.SetChanged(frame, true)
	end
	if not frame.bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.Button)
	end
end

function UISettingPanel.OnCheckBoxUncheck()
	local szName = this:GetName()
	if szName == "CheckBox_AutoCast" then
		this:GetParent():Lookup("CheckBox_CastKeep"):Enable(true)
		if IsCastSkillKeepDown() then
			this:GetParent():Lookup("CheckBox_CastKeep"):Check(true)
		else
			this:GetParent():Lookup("CheckBox_CastKeep"):Check(false)
		end
	elseif szName == "CheckBox_DC01" then
		local wndCombat = this:GetParent()
		wndCombat:Lookup("CheckBox_Recovery01"):Check(false)
		wndCombat:Lookup("CheckBox_Hedge01"):Check(false)
		wndCombat:Lookup("CheckBox_HitOff01"):Check(false)
		wndCombat:Lookup("CheckBox_Discern01"):Check(false)
		wndCombat:Lookup("CheckBox_HJ01"):Check(false)
		wndCombat:Lookup("CheckBox_MY01"):Check(false)
		wndCombat:Lookup("CheckBox_DX01"):Check(false)
		wndCombat:Lookup("CheckBox_Recovery01"):Enable(false)
		wndCombat:Lookup("CheckBox_Hedge01"):Enable(false)
		wndCombat:Lookup("CheckBox_HitOff01"):Enable(false)
		wndCombat:Lookup("CheckBox_Discern01"):Enable(false)
		wndCombat:Lookup("CheckBox_HJ01"):Enable(false)
		wndCombat:Lookup("CheckBox_MY01"):Enable(false)
		wndCombat:Lookup("CheckBox_DX01"):Enable(false)
		wndCombat:Lookup("CheckBox_ShowSkill"):Enable(false)
	elseif szName == "CheckBox_DC02" then
		local wndCombat = this:GetParent()
		wndCombat:Lookup("CheckBox_Recovery02"):Check(false)
		wndCombat:Lookup("CheckBox_Hedge02"):Check(false)
		wndCombat:Lookup("CheckBox_HitOff02"):Check(false)
		wndCombat:Lookup("CheckBox_HJ02"):Check(false)
		wndCombat:Lookup("CheckBox_MY02"):Check(false)
		wndCombat:Lookup("CheckBox_DX02"):Check(false)
		wndCombat:Lookup("CheckBox_GB02"):Check(false)
		wndCombat:Lookup("CheckBox_GD02"):Check(false)
		wndCombat:Lookup("CheckBox_Recovery02"):Enable(false)
		wndCombat:Lookup("CheckBox_Hedge02"):Enable(false)
		wndCombat:Lookup("CheckBox_HitOff02"):Enable(false)
		wndCombat:Lookup("CheckBox_HJ02"):Enable(false)
		wndCombat:Lookup("CheckBox_MY02"):Enable(false)
		wndCombat:Lookup("CheckBox_DX02"):Enable(false)
		wndCombat:Lookup("CheckBox_GB02"):Enable(false)
		wndCombat:Lookup("CheckBox_GD02"):Enable(false)
		wndCombat:Lookup("CheckBox_ShowSkill1"):Enable(false)
	end
	local frame = this:GetRoot()
	if not frame.bDisable then
		UISettingPanel.SetChanged(frame, true)
	end
	if not frame.bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.Button)
	end
end

function UISettingPanel.UpdateActionBarSetting(frame)
	local WndActionBar = frame:Lookup("Wnd_ActionBar")
	
	local bLock = WndActionBar:Lookup("CheckBox_AL"):IsCheckBoxChecked()
	if bLock ~= IsActionBarLocked() then
		LockActionBar(bLock)
	end
	
	local bShow = WndActionBar:Lookup("CheckBox_ShowA1Bg"):IsCheckBoxChecked()
	if bShow ~= IsShowActionBarBg(1) then
		ShowActionBarBg(1, bShow)
	end

	local bShow = WndActionBar:Lookup("CheckBox_ShowA2Bg"):IsCheckBoxChecked()
	if bShow ~= IsShowActionBarBg(2) then
		ShowActionBarBg(2, bShow)
	end

	local bShow = WndActionBar:Lookup("CheckBox_ShowA3Bg"):IsCheckBoxChecked()
	if bShow ~= IsShowActionBarBg(3) then
		ShowActionBarBg(3, bShow)
	end

	local bShow = WndActionBar:Lookup("CheckBox_ShowA4Bg"):IsCheckBoxChecked()
	if bShow ~= IsShowActionBarBg(4) then
		ShowActionBarBg(4, bShow)
	end
	
	local nStep = WndActionBar:Lookup("Scroll_A3Box"):GetScrollPos() + 1
	if nStep ~= GetActionBarCount(3) then
		SetActionBarCount(3, nStep)
	end

	local nStep = WndActionBar:Lookup("Scroll_A3Raw"):GetScrollPos() + 1
	if nStep ~= GetActionBarLine(3) then
		SetActionBarLine(3, nStep)
	end

	local nStep = WndActionBar:Lookup("Scroll_A4Box"):GetScrollPos() + 1
	if nStep ~= GetActionBarCount(4) then
		SetActionBarCount(4, nStep)
	end

	local nStep = WndActionBar:Lookup("Scroll_A4Raw"):GetScrollPos() + 1
	if nStep ~= GetActionBarLine(4) then
		SetActionBarLine(4, nStep)
	end
	
	local bOpen = WndActionBar:Lookup("CheckBox_A2"):IsCheckBoxChecked()
	if bOpen then
		OpenActionBar(2)
	else
		CloseActionBar(2)
	end
	
	local bOpen = WndActionBar:Lookup("CheckBox_A3"):IsCheckBoxChecked()
	if bOpen then
		OpenActionBar(3)
	else
		CloseActionBar(3)
	end

	local bOpen = WndActionBar:Lookup("CheckBox_A4"):IsCheckBoxChecked()
	if bOpen then
		OpenActionBar(4)
	else
		CloseActionBar(4)
	end
end

function UISettingPanel.UpdateBuffSetting(frame)
	local wndBuff = frame:Lookup("Wnd_Buff")
	SetBuffListShowText(wndBuff:Lookup("CheckBox_BuffShowText"):IsCheckBoxChecked())
	SetDebuffListShowText(wndBuff:Lookup("CheckBox_DebuffShowText"):IsCheckBoxChecked())
	
	local text_A = wndBuff:Lookup("", "Text_BuffSort")
	if text_A.szType then
		SetBuffListSortType(text_A.szType)
	end

	local text_A = wndBuff:Lookup("", "Text_DebuffSort")
	if text_A.szType then
		SetDebuffListSortType(text_A.szType)
	end

	SetBuffListLine(wndBuff:Lookup("Scroll_BuffLine"):GetScrollPos() + 1)
	SetBuffListSize(wndBuff:Lookup("Scroll_BuffSize"):GetScrollPos() + 12)
	SetDebuffListLine(wndBuff:Lookup("Scroll_DebuffLine"):GetScrollPos() + 1)
	SetDebuffListSize(wndBuff:Lookup("Scroll_DebuffSize"):GetScrollPos() + 12)
end

function UISettingPanel.UpdateHatredSetting(frame)
	local wndHatred = frame:Lookup("Wnd_Hatred")
	
	local szType = "always"
	if wndHatred:Lookup("CheckBox_Close"):IsCheckBoxChecked() then
		szType = "close"
	elseif wndHatred:Lookup("CheckBox_Dungeon"):IsCheckBoxChecked() then
		szType = "copy"
	elseif wndHatred:Lookup("CheckBox_PartyShow"):IsCheckBoxChecked() then
		szType = "party"
	end
	SetShowHatredPanelType(szType)
	
	SetHatredPanelShowForceColor(wndHatred:Lookup("CheckBox_SchoolColor"):IsCheckBoxChecked())
	
	local szType = "always"
	if wndHatred:Lookup("CheckBox_CloseF"):IsCheckBoxChecked() then
		szType = "close"
	elseif wndHatred:Lookup("CheckBox_DungeonF"):IsCheckBoxChecked() then
		szType = "copy"
	elseif wndHatred:Lookup("CheckBox_PartyShowF"):IsCheckBoxChecked() then
		szType = "party"
	end
	SetFStatisticOpenType(szType)
end

function UISettingPanel.UpdateBagSetting(frame)
	local wndBag = frame:Lookup("Wnd_Bag")
	SetBagShowBg(wndBag:Lookup("CheckBox_BagBg"):IsCheckBoxChecked())
	local szType = wndBag:Lookup("", "Text_BagSort").szType
	if szType then
		SetBagSortType(szType)
	end
	--数据统计
	if IsUseBigBagPanel() and not wndBag:Lookup("CheckBox_Big"):IsCheckBoxChecked() then
		FireDataAnalysisEvent("NOT_BIG_BAG")
	end
	
	SetShowBagSize(wndBag:Lookup("CheckBox_BagSize"):IsCheckBoxChecked())
	SetUseCompactBagPanel(wndBag:Lookup("CheckBox_BagC"):IsCheckBoxChecked())
	SetUseCompactBankPanel(wndBag:Lookup("CheckBox_BankC"):IsCheckBoxChecked())
	SetUseBigBagPanel(wndBag:Lookup("CheckBox_Big"):IsCheckBoxChecked())
end

function UISettingPanel.OnScrollBarPosChanged()
	local nCurrentValue = this:GetScrollPos()
	local szName = this:GetName()
	if szName == "Scroll_UIScale" then
		this:GetParent():Lookup("", "Text_UIScaleV"):SetText(string.format("%.2f", this.Slider:ChangeToArea(UISettingPanel.minUIScale, UISettingPanel.maxUIScale, nCurrentValue)))
	elseif szName == "Scroll_TextScale" then
		if nCurrentValue > 2 then
			this:GetParent():Lookup("", "Text_TextScaleV"):SetText("+"..(nCurrentValue - 2))
		else
			this:GetParent():Lookup("", "Text_TextScaleV"):SetText(nCurrentValue - 2)
		end
	elseif szName == "Scroll_List" then
		local nCurrentValue = this:GetScrollPos()
		local frame = this:GetParent()
		if nCurrentValue == 0 then
			frame:Lookup("Btn_Up"):Enable(false)
		else
			frame:Lookup("Btn_Up"):Enable(true)
		end
		if nCurrentValue == this:GetStepCount() then
			frame:Lookup("Btn_Down"):Enable(false)
		else
			frame:Lookup("Btn_Down"):Enable(true)
		end
		
	    local handle = frame:Lookup("", "Handle_List")
	    handle:SetItemStartRelPos(0, - nCurrentValue * 10)
	elseif szName == "Scroll_A3Raw" then
		this:GetParent():Lookup("", "Text_A3RawV"):SetText(nCurrentValue + 1)
	elseif szName == "Scroll_A3Box" then
		this:GetParent():Lookup("", "Text_A3BoxV"):SetText(nCurrentValue + 1)
	elseif szName == "Scroll_A4Raw" then
		this:GetParent():Lookup("", "Text_A4RawV"):SetText(nCurrentValue + 1)
	elseif szName == "Scroll_A4Box" then
		this:GetParent():Lookup("", "Text_A4BoxV"):SetText(nCurrentValue + 1)
	elseif szName == "Scroll_BuffLine" then
		this:GetParent():Lookup("", "Text_BuffLine"):SetText(nCurrentValue + 1)
	elseif szName == "Scroll_BuffSize" then
		this:GetParent():Lookup("", "Text_BuffSize"):SetText(nCurrentValue + 12)
	elseif szName == "Scroll_DebuffLine" then
		this:GetParent():Lookup("", "Text_DebuffLine"):SetText(nCurrentValue + 1)
	elseif szName == "Scroll_DebuffSize" then
		this:GetParent():Lookup("", "Text_DebuffSize"):SetText(nCurrentValue + 12)
    elseif szName == "Scroll_CS" then
		this:GetParent():Lookup("", "Text_CS"):SetText(string.format("%.2f", this.Slider:GetValue(nCurrentValue)))
	elseif szName == "Scroll_CH" then
		this:GetParent():Lookup("", "Text_CH"):SetText(string.format("%.2f", (this.Slider:GetValue(nCurrentValue) * 2400 / 2000)/ 100))-- 400 为了跟以前 显示的一样，不让玩家察觉到
    end
    
    local frame = this:GetRoot()
	if not frame.bDisable and szName ~= "Scroll_List" then
		UISettingPanel.SetChanged(frame, true)
	end
end

function UISettingPanel.UpdateShowHeadInfoSetting(frame)
	local WndDisplay = frame:Lookup("Wnd_Display")
	
	SetGlobalTopHeadFlag(GLOBAL_HEAD_NPC, GLOBAL_HEAD_NAME, WndDisplay:Lookup("CheckBox_NN"):IsCheckBoxChecked())
	SetGlobalTopHeadFlag(GLOBAL_HEAD_NPC, GLOBAL_HEAD_TITLE, WndDisplay:Lookup("CheckBox_NT"):IsCheckBoxChecked())
	SetGlobalTopHeadFlag(GLOBAL_HEAD_NPC, GLOBAL_HEAD_LEFE, WndDisplay:Lookup("CheckBox_NB"):IsCheckBoxChecked())

	SetGlobalTopHeadFlag(GLOBAL_HEAD_OTHERPLAYER, GLOBAL_HEAD_NAME, WndDisplay:Lookup("CheckBox_PN"):IsCheckBoxChecked())
	SetGlobalTopHeadFlag(GLOBAL_HEAD_OTHERPLAYER, GLOBAL_HEAD_TITLE, WndDisplay:Lookup("CheckBox_PT"):IsCheckBoxChecked())
	SetGlobalTopHeadFlag(GLOBAL_HEAD_OTHERPLAYER, GLOBAL_HEAD_LEFE, WndDisplay:Lookup("CheckBox_PB"):IsCheckBoxChecked())

	SetGlobalTopHeadFlag(GLOBAL_HEAD_CLIENTPLAYER, GLOBAL_HEAD_NAME, WndDisplay:Lookup("CheckBox_SN"):IsCheckBoxChecked())
	SetGlobalTopHeadFlag(GLOBAL_HEAD_CLIENTPLAYER, GLOBAL_HEAD_TITLE, WndDisplay:Lookup("CheckBox_ST"):IsCheckBoxChecked())
	SetGlobalTopHeadFlag(GLOBAL_HEAD_CLIENTPLAYER, GLOBAL_HEAD_LEFE, WndDisplay:Lookup("CheckBox_SB"):IsCheckBoxChecked())
	
	SetGlobalTopHeadFlag(GLOBAL_HEAD_CLIENTPLAYER, GLOBAL_HEAD_GUILD, WndDisplay:Lookup("CheckBox_ShowSelfGuild"):IsCheckBoxChecked())
	SetGlobalTopHeadFlag(GLOBAL_HEAD_OTHERPLAYER, GLOBAL_HEAD_GUILD, WndDisplay:Lookup("CheckBox_ShowOtherGuild"):IsCheckBoxChecked())
	
	ShowPlayerBalloon(WndDisplay:Lookup("CheckBox_PlayerP"):IsCheckBoxChecked())
	ShowNpcBalloon(WndDisplay:Lookup("CheckBox_NpcP"):IsCheckBoxChecked())

	ShowTargetTarget(WndDisplay:Lookup("CheckBox_TargetTarget"):IsCheckBoxChecked())
	SetHideQuestShow(WndDisplay:Lookup("CheckBox_HideQuest"):IsCheckBoxChecked())

	GetClientPlayer().HideHat(WndDisplay:Lookup("CheckBox_HideHead"):IsCheckBoxChecked())
	SetShowTeamateQuestTrace(WndDisplay:Lookup("CheckBox_ShowTeamQuest"):IsCheckBoxChecked())
	
	SetSkillTipPanel(WndDisplay:Lookup("CheckBox_SkillTip"):IsCheckBoxChecked())

    
    do
        local a3DEngineOption = KG3DEngine.Get3DEngineOption()
        a3DEngineOption.b2DCaptionSave = not WndDisplay:Lookup("CheckBox_TDName"):IsCheckBoxChecked();
        KG3DEngine.Set3DEngineOption(a3DEngineOption)
    end
	Global_UpdateHeadTopPosition()
end
---------------数据统计
function UISettingPanel.DataAnlysis_BasicSettingAdjust(frame)
	local wndBasic = frame:Lookup("Wnd_BasicSetting")
	local nOffLast = Font.GetOffset()
	local nOff = wndBasic:Lookup("Scroll_TextScale"):GetScrollPos() - 2
	local sU = wndBasic:Lookup("Scroll_UIScale")
	local fScale = sU.Slider:GetValue(sU:GetScrollPos())
	local fLastUIScale = Station.GetUIScale()
	
	if nOff ~= nOffLast then
		FireDataAnalysisEvent("FONT_ZOOM", {nOff})
	end	
	
	local fS = Station.GetMaxUIScale()
	local fDefScale = fS * UISettingPanel.defaultUIScale
	if math.abs(fScale - fLastUIScale) > 0.01 then
		FireDataAnalysisEvent("UI_ZOOM", {fDefScale, fScale})
	end
	
	if IsShowHelpPanel() and not wndBasic:Lookup("CheckBox_Help"):IsCheckBoxChecked() then
		FireDataAnalysisEvent("DROP_NEW_HELP")
	end
	
	if not IsMouseMove() and wndBasic:Lookup("CheckBox_MouseMove"):IsCheckBoxChecked() then
		FireDataAnalysisEvent("SELECT_MOUSE_MOVE")
	end
	
	if IsAutoTraceQuest() and not wndBasic:Lookup("CheckBox_AutoShow"):IsCheckBoxChecked() then
		FireDataAnalysisEvent("CANCEL_AUTO_TRACE_QUEST")
	end
end

function UISettingPanel.UpdateBasicSetting(frame)
	local wndBasic = frame:Lookup("Wnd_BasicSetting")
	
	frame.bDisable = true
	---------------数据统计
	UISettingPanel.DataAnlysis_BasicSettingAdjust(frame)
	
	local nOffLast = Font.GetOffset()
	local nOff = wndBasic:Lookup("Scroll_TextScale"):GetScrollPos() - 2
	local sU = wndBasic:Lookup("Scroll_UIScale")
	local fScale = sU.Slider:GetValue(sU:GetScrollPos())
	if nOff ~= nOffLast then
		Font.SetOffset(nOff)
		Station.SetUIScale(fScale, true)
	else
		Station.SetUIScale(fScale, false)
	end
	frame.bDisable = false
		
	SetSelfCastSkill(wndBasic:Lookup("CheckBox_AutoCast"):IsCheckBoxChecked())
	SetCastSkillKeepDown(wndBasic:Lookup("CheckBox_CastKeep"):IsCheckBoxChecked())

	SwapMouseButton(wndBasic:Lookup("CheckBox_SwapMouse"):IsCheckBoxChecked())
	LootList_SetRButtonPickupAll(wndBasic:Lookup("CheckBox_AutoPickup"):IsCheckBoxChecked())
	LootList_SetOpenPosNearMouse(wndBasic:Lookup("CheckBox_NearMouse"):IsCheckBoxChecked())
	SetShowHelpPanel(wndBasic:Lookup("CheckBox_Help"):IsCheckBoxChecked())
	SetEditBoxAlwaysShow(not wndBasic:Lookup("CheckBox_Edit"):IsCheckBoxChecked())
	SetTargetShowActionBar(wndBasic:Lookup("CheckBox_TarAct"):IsCheckBoxChecked())
	SetShowLoginTip(wndBasic:Lookup("CheckBox_LoginTip"):IsCheckBoxChecked())
	SetShowStandardTarget(wndBasic:Lookup("CheckBox_StandardTarget"):IsCheckBoxChecked())
	SetShowMatrix(wndBasic:Lookup("CheckBox_Matrix"):IsCheckBoxChecked())
	SetAutoTraceQuest(wndBasic:Lookup("CheckBox_AutoShow"):IsCheckBoxChecked())
	SetMouseMove(wndBasic:Lookup("CheckBox_MouseMove"):IsCheckBoxChecked())
	SetShowKoeraLogo(wndBasic:Lookup("CheckBox_KoreaLogo"):IsCheckBoxChecked())
	BattleFieldMap_TurnOn(wndBasic:Lookup("CheckBox_BattleMap"):IsCheckBoxChecked())
    
    local bCheck = wndBasic:Lookup("CheckBox_SearchTarget"):IsCheckBoxChecked()
    if bCheck then
        SearchTarget_SetOtherSettting("nVersion", 2, "Enmey")
        SearchTarget_SetOtherSettting("nVersion", 2, "Ally")
    else
        SearchTarget_SetOtherSettting("nVersion", 1, "Enmey")
        SearchTarget_SetOtherSettting("nVersion", 1, "Ally")
    end
end

function UISettingPanel.UpdateStateValueSetting(frame)
	local wndStateValue = frame:Lookup("Wnd_StateValue")
	
	SetPlayerShowStateValue(wndStateValue:Lookup("CheckBox_Player"):IsCheckBoxChecked())
	SetTargetShowStateValue(wndStateValue:Lookup("CheckBox_Target"):IsCheckBoxChecked())
	SetTeammateShowStateValue(wndStateValue:Lookup("CheckBox_Team"):IsCheckBoxChecked())
	SetShowStateValueByPercentage(wndStateValue:Lookup("CheckBox_Persent"):IsCheckBoxChecked())
	SetExpShowStateValue(wndStateValue:Lookup("CheckBox_Exp"):IsCheckBoxChecked())
	SetActionBarCoolDownShow(wndStateValue:Lookup("CheckBox_Cool"):IsCheckBoxChecked())
	SetShowStateValueTwoFormat(wndStateValue:Lookup("CheckBox_TowFormat"):IsCheckBoxChecked())
end

function UISettingPanel.UpdateCameraSettings(frame)
	local wndCamera = frame:Lookup("Wnd_Camera")

	local fDragSpeed, fMaxCameraDistance, fSpringResetSpeed, fCameraResetSpeed, nResetMode = Camera_GetParams()
	
	--追尾模式 : 从不 = 0, 智能 = 1, 总是= 2
	if wndCamera:Lookup("CheckBox_C1"):IsCheckBoxChecked() then
		nResetMode = 0
	elseif wndCamera:Lookup("CheckBox_C2"):IsCheckBoxChecked() then
		nResetMode = 1
	elseif wndCamera:Lookup("CheckBox_C3"):IsCheckBoxChecked() then
		nResetMode = 2
	end
	
	local text_A = wndCamera:Lookup("Btn_Shake", "Text_Shake")
	if text_A.szType then
		UISettingPanel.nShakeMode = text_A.szType
	end
	
	if UISettingPanel.nShakeMode == 0 then
		rlcmd("set camera shake mode 0")
		
	elseif UISettingPanel.nShakeMode == 1 then
		rlcmd("set camera shake mode 1")
		
	elseif UISettingPanel.nShakeMode == 2 then
		rlcmd("set camera shake mode 2")
	end
	
	local cS = wndCamera:Lookup("Scroll_CS")
	fDragSpeed = cS.Slider:GetValue(cS:GetScrollPos())
    
	local cH = wndCamera:Lookup("Scroll_CH")
	fMaxCameraDistance = cH.Slider:GetValue(cH:GetScrollPos())
	Camera_SetParams(fDragSpeed, fMaxCameraDistance, fSpringResetSpeed, fCameraResetSpeed, nResetMode)
	
	--SetShock(wndCamera:Lookup("CheckBox_Shake"):IsCheckBoxChecked())
	SetFrameShake(wndCamera:Lookup("CheckBox_TargetShake"):IsCheckBoxChecked())
    
    local a3DEngineOption = KG3DEngine.Get3DEngineOption()
	local a3DEngineCaps = KG3DEngine.Get3DEngineOptionCaps(a3DEngineOption)
    
    hScroll = wndCamera:Lookup("Scroll_GJ")
	a3DEngineOption.fCameraAngle = hScroll.Slider:GetValue(hScroll:GetScrollPos()) * math.pi / 180 + UISettingPanel.fPrecision
    KG3DEngine.Set3DEngineOption(a3DEngineOption)
	
	UISettingPanel.bCloseGJInJump = wndCamera:Lookup("CheckBox_CloseGJ"):IsCheckBoxChecked()
	if UISettingPanel.bCloseGJInJump then
		rlcmd("close sprint camera")
	else
		rlcmd("open sprint camera")
	end
end

function UISettingPanel.UpdateCombatSetting(frame)
	local wndCombat = frame:Lookup("Wnd_Combat")
	
	local bMerge = wndCombat:Lookup("CheckBox_Merge"):IsCheckBoxChecked()
	SetMergeDamage(bMerge)
	
	local t = GetCombatMeToTargetSetting()
	t.bShangHai = wndCombat:Lookup("CheckBox_DD01"):IsCheckBoxChecked()
	t.bZhiLiao = wndCombat:Lookup("CheckBox_DH01"):IsCheckBoxChecked()
	t.bQiTa = wndCombat:Lookup("CheckBox_DC01"):IsCheckBoxChecked()
	if t.bQiTa then
		t.bChaiZhao = wndCombat:Lookup("CheckBox_Recovery01"):IsCheckBoxChecked()
		t.bDuoShan = wndCombat:Lookup("CheckBox_Hedge01"):IsCheckBoxChecked()
		t.bPianLi = wndCombat:Lookup("CheckBox_HitOff01"):IsCheckBoxChecked()
		t.bShiPo = wndCombat:Lookup("CheckBox_Discern01"):IsCheckBoxChecked()
		t.bHuaJie = wndCombat:Lookup("CheckBox_HJ01"):IsCheckBoxChecked()
		t.bMianYi = wndCombat:Lookup("CheckBox_MY01"):IsCheckBoxChecked()
		t.bDiXiao = wndCombat:Lookup("CheckBox_DX01"):IsCheckBoxChecked()
		t.bSkillName = wndCombat:Lookup("CheckBox_ShowSkill"):IsCheckBoxChecked()
	end
	SetCombatMeToTargetSetting(t)
	
	local t = GetCombatTargetToMeSetting()
	t.bShangHai = wndCombat:Lookup("CheckBox_DD02"):IsCheckBoxChecked()
	t.bZhiLiao = wndCombat:Lookup("CheckBox_DH02"):IsCheckBoxChecked()
	t.bQiTa = wndCombat:Lookup("CheckBox_DC02"):IsCheckBoxChecked()
	if t.bQiTa then
		t.bChaiZhao = wndCombat:Lookup("CheckBox_Recovery02"):IsCheckBoxChecked()
		t.bDuoShan = wndCombat:Lookup("CheckBox_Hedge02"):IsCheckBoxChecked()
		t.bPianLi = wndCombat:Lookup("CheckBox_HitOff02"):IsCheckBoxChecked()
		t.bHuaJie = wndCombat:Lookup("CheckBox_HJ02"):IsCheckBoxChecked()
		t.bMianYi = wndCombat:Lookup("CheckBox_MY02"):IsCheckBoxChecked()
		t.bDiXiao = wndCombat:Lookup("CheckBox_DX02"):IsCheckBoxChecked()
		t.bZengYi = wndCombat:Lookup("CheckBox_GB02"):IsCheckBoxChecked()
		t.bJianYi = wndCombat:Lookup("CheckBox_GD02"):IsCheckBoxChecked()
		t.bSkillName = wndCombat:Lookup("CheckBox_ShowSkill1"):IsCheckBoxChecked()
	end
	SetCombatTargetToMeSetting(t)
end

function UISettingPanel.SetDefault(frame)
	frame.bDisableSound = true
	
	local wndBasic = frame:Lookup("Wnd_BasicSetting")
	wndBasic:Lookup("Scroll_TextScale"):SetScrollPos(2)
	local sU = wndBasic:Lookup("Scroll_UIScale")
	sU:SetScrollPos(sU.Slider:GetStepFromArea(UISettingPanel.minUIScale, UISettingPanel.maxUIScale, UISettingPanel.defaultUIScale))
	wndBasic:Lookup("CheckBox_AutoCast"):Check(true)
	wndBasic:Lookup("CheckBox_CastKeep"):Check(false)
	wndBasic:Lookup("CheckBox_SwapMouse"):Check(false)
	wndBasic:Lookup("CheckBox_AutoPickup"):Check(false)
	wndBasic:Lookup("CheckBox_NearMouse"):Check(true)
	wndBasic:Lookup("CheckBox_Help"):Check(true)
	wndBasic:Lookup("CheckBox_HelpComment"):Check(true)
	wndBasic:Lookup("CheckBox_Edit"):Check(false)
	wndBasic:Lookup("CheckBox_TarAct"):Check(true)
	
	wndBasic:Lookup("CheckBox_LoginTip"):Check(true)
	wndBasic:Lookup("CheckBox_StandardTarget"):Check(false)
	wndBasic:Lookup("CheckBox_Matrix"):Check(true)
	wndBasic:Lookup("CheckBox_AutoShow"):Check(true)
	wndBasic:Lookup("CheckBox_MouseMove"):Check(false)
    wndBasic:Lookup("CheckBox_SearchTarget"):Check(true)
	wndBasic:Lookup("CheckBox_KoreaLogo"):Check(true)
	wndBasic:Lookup("CheckBox_BattleMap"):Check(true)
	
	local WndDisplay = frame:Lookup("Wnd_Display")
	WndDisplay:Lookup("CheckBox_NN"):Check(true)
	WndDisplay:Lookup("CheckBox_NT"):Check(true)
	WndDisplay:Lookup("CheckBox_NB"):Check(false)
	WndDisplay:Lookup("CheckBox_PN"):Check(true)
	WndDisplay:Lookup("CheckBox_PT"):Check(true)
	WndDisplay:Lookup("CheckBox_PB"):Check(false)
	WndDisplay:Lookup("CheckBox_SN"):Check(false)
	WndDisplay:Lookup("CheckBox_ST"):Check(false)
	WndDisplay:Lookup("CheckBox_SB"):Check(false)	
	WndDisplay:Lookup("CheckBox_PlayerP"):Check(true)
	WndDisplay:Lookup("CheckBox_NpcP"):Check(true)	
	WndDisplay:Lookup("CheckBox_TargetTarget"):Check(true)
	WndDisplay:Lookup("CheckBox_HideQuest"):Check(true)
	WndDisplay:Lookup("CheckBox_HideHead"):Check(false)
	WndDisplay:Lookup("CheckBox_ShowTeamQuest"):Check(true)
	WndDisplay:Lookup("CheckBox_ShowSelfGuild"):Check(false)
	WndDisplay:Lookup("CheckBox_ShowOtherGuild"):Check(true)
    WndDisplay:Lookup("CheckBox_TDName"):Check(false)
	WndDisplay:Lookup("CheckBox_SkillTip"):Check(true)
    
	local WndActionBar = frame:Lookup("Wnd_ActionBar")
	WndActionBar:Lookup("CheckBox_AL"):Check(false)
	WndActionBar:Lookup("CheckBox_A1"):Check(true)
	WndActionBar:Lookup("CheckBox_A2"):Check(false)
	WndActionBar:Lookup("CheckBox_A3"):Check(false)
	WndActionBar:Lookup("CheckBox_A4"):Check(false)
	WndActionBar:Lookup("CheckBox_ShowA1Bg"):Check(true)
	WndActionBar:Lookup("CheckBox_ShowA2Bg"):Check(true)
	WndActionBar:Lookup("CheckBox_ShowA3Bg"):Check(true)
	WndActionBar:Lookup("CheckBox_ShowA4Bg"):Check(true)
	
	WndActionBar:Lookup("Scroll_A3Box"):SetScrollPos(15)
	WndActionBar:Lookup("", "Text_A3BoxV"):SetText("16")
	WndActionBar:Lookup("Scroll_A3Raw"):SetScrollPos(0)
	WndActionBar:Lookup("", "Text_A3RawV"):SetText("1")
	
	WndActionBar:Lookup("Scroll_A4Box"):SetScrollPos(15)
	WndActionBar:Lookup("", "Text_A4BoxV"):SetText("16")
	WndActionBar:Lookup("Scroll_A4Raw"):SetScrollPos(0)
	WndActionBar:Lookup("", "Text_A4RawV"):SetText("1")
	
	local wndStateValue = frame:Lookup("Wnd_StateValue")
	wndStateValue:Lookup("CheckBox_Player"):Check(true)
	wndStateValue:Lookup("CheckBox_Target"):Check(true)
	wndStateValue:Lookup("CheckBox_Team"):Check(false)
	wndStateValue:Lookup("CheckBox_Persent"):Check(false)
	wndStateValue:Lookup("CheckBox_Exp"):Check(true)
	wndStateValue:Lookup("CheckBox_Cool"):Check(true)
	wndStateValue:Lookup("CheckBox_TowFormat"):Check(false)
	
	local wndCombat = frame:Lookup("Wnd_Combat")
	wndCombat:Lookup("CheckBox_Merge"):Check(true)
	
	wndCombat:Lookup("CheckBox_DD01"):Check(true)
	wndCombat:Lookup("CheckBox_DH01"):Check(true)
	wndCombat:Lookup("CheckBox_ShowSkill"):Check(true)
	wndCombat:Lookup("CheckBox_ShowSkill1"):Check(true)
	
	wndCombat:Lookup("CheckBox_DC01"):Check(true)
	wndCombat:Lookup("CheckBox_Recovery01"):Check(true)
	wndCombat:Lookup("CheckBox_Hedge01"):Check(true)
	wndCombat:Lookup("CheckBox_HitOff01"):Check(true)
	wndCombat:Lookup("CheckBox_Discern01"):Check(true)
	wndCombat:Lookup("CheckBox_HJ01"):Check(true)
	wndCombat:Lookup("CheckBox_MY01"):Check(true)
	wndCombat:Lookup("CheckBox_DX01"):Check(true)
	wndCombat:Lookup("CheckBox_DD02"):Check(true)
	wndCombat:Lookup("CheckBox_DH02"):Check(true)
	wndCombat:Lookup("CheckBox_DC02"):Check(true)
	wndCombat:Lookup("CheckBox_Recovery02"):Check(true)
	wndCombat:Lookup("CheckBox_Hedge02"):Check(true)
	wndCombat:Lookup("CheckBox_HitOff02"):Check(true)
	wndCombat:Lookup("CheckBox_HJ02"):Check(true)
	wndCombat:Lookup("CheckBox_MY02"):Check(true)
	wndCombat:Lookup("CheckBox_DX02"):Check(true)
	wndCombat:Lookup("CheckBox_GB02"):Check(true)
	wndCombat:Lookup("CheckBox_GD02"):Check(true)

	local wndBag = frame:Lookup("Wnd_Bag")
	wndBag:Lookup("CheckBox_BagSize"):Check(true)
	wndBag:Lookup("CheckBox_Big"):Check(true)
	wndBag:Lookup("CheckBox_BagC"):Check(false)
	wndBag:Lookup("CheckBox_BankC"):Check(false)
	wndBag:Lookup("CheckBox_BagBg"):Check(true)
	local text_A = wndBag:Lookup("", "Text_BagSort")
	text_A:SetText(g_tStrings.SORT_LEFT_RIGHT)
	text_A.szType = "left_to_right"
	
	local wndBuff = frame:Lookup("Wnd_Buff")
	wndBuff:Lookup("CheckBox_BuffShowText"):Check(true)
	wndBuff:Lookup("CheckBox_DebuffShowText"):Check(true)
	local text_A = wndBuff:Lookup("", "Text_BuffSort")
	text_A:SetText(g_tStrings.SORT_LEFT_RIGHT)
	text_A.szType = "left_to_right"

	local text_A = wndBuff:Lookup("", "Text_DebuffSort")
	text_A:SetText(g_tStrings.SORT_LEFT_RIGHT)
	text_A.szType = "left_to_right"
	
	wndBuff:Lookup("Scroll_BuffLine"):SetScrollPos(0)
	wndBuff:Lookup("", "Text_BuffLine"):SetText("1")
	wndBuff:Lookup("Scroll_BuffSize"):SetScrollPos(28)
	wndBuff:Lookup("", "Text_BuffSize"):SetText("40")

	wndBuff:Lookup("Scroll_DebuffLine"):SetScrollPos(0)
	wndBuff:Lookup("", "Text_DebuffLine"):SetText("1")
	wndBuff:Lookup("Scroll_DebuffSize"):SetScrollPos(28)
	wndBuff:Lookup("", "Text_DebuffSize"):SetText("40")
	
	local wndHatred = frame:Lookup("Wnd_Hatred")
	wndHatred:Lookup("CheckBox_PartyShow"):Check(true)
	wndHatred:Lookup("CheckBox_SchoolColor"):Check(true)
	
	wndHatred:Lookup("CheckBox_PartyShowF"):Check(true)
	
    local tSettings = l_tCameraDefaultSetting
    local wndCamera = frame:Lookup("Wnd_Camera")
	wndCamera:Lookup("CheckBox_C1"):Check(tSettings.nResetMode == 0)
	wndCamera:Lookup("CheckBox_C2"):Check(tSettings.nResetMode == 1)
	wndCamera:Lookup("CheckBox_C3"):Check(tSettings.nResetMode == 2)
	
	local hTextShake = wndCamera:Lookup("Btn_Shake", "Text_Shake")
	hTextShake:SetText(g_tStrings.tShakeTitle[tSettings.nShakeMode])
	hTextShake.szType = tSettings.nShakeMode
	
	--wndCamera:Lookup("CheckBox_Shake"):Check(tSettings.bShock)
	wndCamera:Lookup("CheckBox_TargetShake"):Check(tSettings.bFrameShake)
	
	local hScrollCS = wndCamera:Lookup("Scroll_CS")
	hScrollCS:SetScrollPos(hScrollCS.Slider:GetStep(tSettings.fDragSpeed))
	
	local hScrollCH = wndCamera:Lookup("Scroll_CH")
	hScrollCH:SetScrollPos(hScrollCH.Slider:GetStep(tSettings.fMaxCameraDistance))
	
	local hScrollGJ = wndCamera:Lookup("Scroll_GJ")
	hScrollGJ:SetScrollPos(hScrollGJ.Slider:GetStep(tSettings.nAngle))
    
	wndCamera:Lookup("CheckBox_CloseGJ"):Check(tSettings.bCloseGJInJump)
	
	frame.bDisableSound = false
end

function UISettingPanel.OnLButtonDown()
	local szName = this:GetName()
	if szName == "Btn_BagSort" then
		if this.bIgnor then
			this.bIgnor = nil
			return
		end
		
		if not this:IsEnabled() then
			return
		end		
		
		local text = this:GetParent():Lookup("", "Text_BagSort")
		local xA, yA = text:GetAbsPos()
		local w, h = text:GetSize()		
		local menu = 
		{
			nMiniWidth = w,
			x = xA, y = yA + h,
			fnCancelAction = function() 
				local btn = Station.Lookup("Topmost/UISettingPanel/Wnd_Bag/Btn_BagSort") 
				if btn then
					local x, y = Cursor.GetPos()
					local xA, yA = btn:GetAbsPos()
					local w, h = btn:GetSize()
					if x >= xA and x < xA + w and y >= yA and y <= yA + h then
						btn.bIgnor = true
					end
				end
			end,
			fnAction = function(UserData, bCheck)
				local frame = Station.Lookup("Topmost/UISettingPanel")
				if frame then
					local wndBag = frame:Lookup("Wnd_Bag")
					local text = wndBag:Lookup("", "Text_BagSort")
					text:SetText(UserData[1])
					text.szType = UserData[2]
					UISettingPanel.SetChanged(frame, true)
				end
			end,
			fnAutoClose = function()  return not IsUISettingPanelOpened() end,
			{szOption = g_tStrings.SORT_LEFT_RIGHT, UserData = {g_tStrings.SORT_LEFT_RIGHT, "left_to_right"}},
			{szOption = g_tStrings.SORT_RIGHT_LEFT, UserData = {g_tStrings.SORT_RIGHT_LEFT, "right_to_left"}},
			{szOption = g_tStrings.SORT_TOP_BOTTOM, UserData = {g_tStrings.SORT_TOP_BOTTOM, "top_to_bottom"}},
			{szOption = g_tStrings.SORT_BOTTOM_TOP, UserData = {g_tStrings.SORT_BOTTOM_TOP, "bottom_to_top"}},
		}
		PopupMenu(menu)
		return true
	elseif szName == "Btn_BuffSort" then
		if this.bIgnor then
			this.bIgnor = nil
			return
		end
		
		if not this:IsEnabled() then
			return
		end		
		
		local text = this:GetParent():Lookup("", "Text_BuffSort")
		local xA, yA = text:GetAbsPos()
		local w, h = text:GetSize()		
		local menu = 
		{
			nMiniWidth = w,
			x = xA, y = yA + h,
			fnCancelAction = function() 
				local btn = Station.Lookup("Topmost/UISettingPanel/Wnd_Buff/Btn_BuffSort") 
				if btn then
					local x, y = Cursor.GetPos()
					local xA, yA = btn:GetAbsPos()
					local w, h = btn:GetSize()
					if x >= xA and x < xA + w and y >= yA and y <= yA + h then
						btn.bIgnor = true
					end
				end
			end,
			fnAction = function(UserData, bCheck)
				local frame = Station.Lookup("Topmost/UISettingPanel")
				if frame then
					local wndBag = frame:Lookup("Wnd_Buff")
					local text = wndBag:Lookup("", "Text_BuffSort")
					text:SetText(UserData[1])
					text.szType = UserData[2]
					UISettingPanel.SetChanged(frame, true)
				end
			end,
			fnAutoClose = function()  return not IsUISettingPanelOpened() end,
			{szOption = g_tStrings.SORT_LEFT_RIGHT, UserData = {g_tStrings.SORT_LEFT_RIGHT, "left_to_right"}},
			{szOption = g_tStrings.SORT_RIGHT_LEFT, UserData = {g_tStrings.SORT_RIGHT_LEFT, "right_to_left"}},
		}
		PopupMenu(menu)
		return true
	elseif szName == "Btn_DebuffSort" then
		if this.bIgnor then
			this.bIgnor = nil
			return
		end
		
		if not this:IsEnabled() then
			return
		end		
		
		local text = this:GetParent():Lookup("", "Text_DebuffSort")
		local xA, yA = text:GetAbsPos()
		local w, h = text:GetSize()		
		local menu = 
		{
			nMiniWidth = w,
			x = xA, y = yA + h,
			fnCancelAction = function() 
				local btn = Station.Lookup("Topmost/UISettingPanel/Wnd_Buff/Btn_DebuffSort") 
				if btn then
					local x, y = Cursor.GetPos()
					local xA, yA = btn:GetAbsPos()
					local w, h = btn:GetSize()
					if x >= xA and x < xA + w and y >= yA and y <= yA + h then
						btn.bIgnor = true
					end
				end
			end,
			fnAction = function(UserData, bCheck)
				local frame = Station.Lookup("Topmost/UISettingPanel")
				if frame then
					local wndBag = frame:Lookup("Wnd_Buff")
					local text = wndBag:Lookup("", "Text_DebuffSort")
					text:SetText(UserData[1])
					text.szType = UserData[2]
					UISettingPanel.SetChanged(frame, true)
				end
			end,
			fnAutoClose = function()  return not IsUISettingPanelOpened() end,
			{szOption = g_tStrings.SORT_LEFT_RIGHT, UserData = {g_tStrings.SORT_LEFT_RIGHT, "left_to_right"}},
			{szOption = g_tStrings.SORT_RIGHT_LEFT, UserData = {g_tStrings.SORT_RIGHT_LEFT, "right_to_left"}},
		}
		PopupMenu(menu)
		return true
		
	elseif szName == "Btn_Shake" then
		if this.bIgnor then
			this.bIgnor = nil
			return
		end
		
		if not this:IsEnabled() then
			return
		end		
		
		local text = this:Lookup("", "Text_Shake")
		local xA, yA = text:GetAbsPos()
		local w, h = text:GetSize()		
		local menu = 
		{
			nMiniWidth = w,
			x = xA, y = yA + h,
			fnCancelAction = function() 
				local btn = Station.Lookup("Topmost/UISettingPanel/Wnd_Camera/Btn_Shake") 
				if btn then
					local x, y = Cursor.GetPos()
					local xA, yA = btn:GetAbsPos()
					local w, h = btn:GetSize()
					if x >= xA and x < xA + w and y >= yA and y <= yA + h then
						btn.bIgnor = true
					end
				end
			end,
			fnAction = function(UserData, bCheck)
				local frame = Station.Lookup("Topmost/UISettingPanel")
				if frame then
					local wndShake = frame:Lookup("Wnd_Camera")
					local text = wndShake:Lookup("Btn_Shake", "Text_Shake")
					text:SetText(UserData[1])
					text.szType = UserData[2]
					UISettingPanel.SetChanged(frame, true)
				end
			end,
			fnAutoClose = function()  return not IsUISettingPanelOpened() end,
		}
		for k, v in pairs(g_tStrings.tShakeTitle) do
			table.insert(menu, {szOption = v, UserData = {v,k}})
		end
		PopupMenu(menu)
		return true
	end
end	


function UISettingPanel.OnLButtonClick()
	local szSelfName = this:GetName()
    if szSelfName == "Btn_Close" or szSelfName == "Btn_Cancel" then
    	CloseUISettingPanel()
    elseif szSelfName == "Btn_Sure" then
    	local frame = this:GetRoot()
    	if frame.bChanged then
	    	UISettingPanel.UpdateCombatSetting(frame)
	    	UISettingPanel.UpdateStateValueSetting(frame)
	    	UISettingPanel.UpdateActionBarSetting(frame)
	    	UISettingPanel.UpdateShowHeadInfoSetting(frame)
	    	UISettingPanel.UpdateBasicSetting(frame)
	    	UISettingPanel.UpdateBagSetting(frame)
	    	UISettingPanel.UpdateBuffSetting(frame)
	    	UISettingPanel.UpdateHatredSetting(frame)
            UISettingPanel.UpdateCameraSettings(frame)
	    	SaveUISetting()
	    	FireEvent("APPLY_UI_SETTING")
    	end
    	CloseUISettingPanel()
    elseif szSelfName == "Btn_Default" then
    	UISettingPanel.SetDefault(this:GetRoot())
    	PlaySound(SOUND.UI_SOUND,g_sound.Button)
    elseif szSelfName == "Btn_Apply" then
    	local frame = this:GetRoot()
    	UISettingPanel.UpdateCombatSetting(frame)
    	UISettingPanel.UpdateStateValueSetting(frame)
    	UISettingPanel.UpdateActionBarSetting(frame)
    	UISettingPanel.UpdateShowHeadInfoSetting(frame)
    	UISettingPanel.UpdateBasicSetting(frame)
    	UISettingPanel.UpdateBagSetting(frame)
    	UISettingPanel.UpdateBuffSetting(frame)
    	UISettingPanel.UpdateHatredSetting(frame)
        UISettingPanel.UpdateCameraSettings(frame)
    	UISettingPanel.SetChanged(frame, false)
    	SaveUISetting()
    	FireEvent("APPLY_UI_SETTING")
    	PlaySound(SOUND.UI_SOUND,g_sound.Button)
    end
end

function UISettingPanel.OnItemLButtonDown()
	local szName = this:GetName()
	local szTitle = string.sub(szName, 1, 3)
	if szTitle == "HI_" then
		if this.bSel then
			return
		end
		UISettingPanel.SelectPage(this)
	end
end

function UISettingPanel.OnItemMouseEnter()
	local szName = this:GetName()
	local szTitle = string.sub(szName, 1, 3)
	if szTitle == "HI_" then
		if not this.bSel then
			this:Lookup(0):Show()
			this:Lookup(0):SetAlpha(127)
		end
	end
end

function UISettingPanel.OnItemMouseLeave()
	local szName = this:GetName()
	local szTitle = string.sub(szName, 1, 3)
	if szTitle == "HI_" then
		if not this.bSel then
			this:Lookup(0):Hide()
		end
	end
end

function UISettingPanel.SelectPage(hI)
	local hP = hI:GetParent()
	local nCount = hP:GetItemCount() - 1
	for i = 0, nCount, 1 do
		local hB = hP:Lookup(i)
		hB:Lookup(0):Hide()
		hB.bSel = false
		
		local szLeft = string.sub(hB:GetName(), 4, -1)
		hP:GetRoot():Lookup("Wnd_"..szLeft):Hide()
	end
	hI:Lookup(0):Show()
	hI:Lookup(0):SetAlpha(255)
	hI.bSel = true
	local szLeft = string.sub(hI:GetName(), 4, -1)
	hP:GetRoot():Lookup("Wnd_"..szLeft):Show()
end

function UISettingPanel.UpdateScrollInfo(handle)
	handle:FormatAllItemPos()
	local w, h = handle:GetSize()
	local wAll, hAll = handle:GetAllItemSize()

	local nStep = math.ceil((hAll - h) / 10)
	
	local scroll = handle:GetRoot():Lookup("Scroll_List")
	if nStep > 0 then
		scroll:Show()
		scroll:GetParent():Lookup("Btn_Up"):Show()
		scroll:GetParent():Lookup("Btn_Down"):Show()
	else
		scroll:Hide()
		scroll:GetParent():Lookup("Btn_Up"):Hide()
		scroll:GetParent():Lookup("Btn_Down"):Hide()			
	end	
	scroll:SetStepCount(nStep)
end

function UISettingPanel.OnLButtonHold()
    local szName = this:GetName()
	if szName == "Btn_Up" then
		this:GetParent():Lookup("Scroll_List"):ScrollPrev(1)
	elseif szName == "Btn_Down" then
		this:GetParent():Lookup("Scroll_List"):ScrollNext(1)
    end
end

function UISettingPanel.OnItemMouseWheel()
	local nDistance = Station.GetMessageWheelDelta()
	this:GetParent():Lookup("Scroll_List"):ScrollNext(nDistance)
	return 1
end


function OpenUISettingPanel(bDisableSound)
	if IsUISettingPanelOpened() then
		return
	end
	
	Wnd.OpenWindow("UISettingPanel")
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end	
end

function CloseUISettingPanel(bDisableSound)
	if not IsUISettingPanelOpened() then
		return
	end
	Wnd.CloseWindow("UISettingPanel")
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end
end

function IsUISettingPanelOpened()
	local frame = Station.Lookup("Topmost/UISettingPanel")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end

function LoadQuestShow()
	--任务追踪:因为加载时机不同需要分开Load
	local szIniFile = GetUserDataPath()
	if szIniFile == "" then
		return
	end
	szIniFile = szIniFile.."\\setting.ini"

	local szSection = "QuestShow"
	
	local iniS = Ini.Open(szIniFile)
	if iniS then
		local nCount = iniS:ReadInteger(szSection, "Count", 0)
		for index = 1, nCount, 1 do
			local nQuestID = iniS:ReadInteger(szSection, "QusetID"..index, 0)
			local nQuestTabID = iniS:ReadInteger(szSection, "QusetTabID"..index, 0)
			local nCheckQuestTabID = GetClientPlayer().GetQuestID(nQuestID)
			if nQuestTabID == nCheckQuestTabID then
				QuestShow.OnGetQuestShowInfo("Add", nQuestID, nQuestTabID, false)
			end
		end
		iniS:Close()
	end
end

function LoadUISetting()
	local szIniFile = GetUserDataPath()
	if szIniFile == "" then
		return
	end
	szIniFile = szIniFile.."\\setting.ini"

	local szSection = "UISetting"
	
	local iniS = Ini.Open(szIniFile)
	if not iniS then
		ShowPlayerBalloon(true)
		ShowNpcBalloon(true)
		
		return
	end

	
	value = iniS:ReadInteger(szSection, "ShowPlayerBalloon", 0)
	if value and value ~= 0 then
		ShowPlayerBalloon(true)
	else
		ShowPlayerBalloon(false)
	end		

	value = iniS:ReadInteger(szSection, "ShowNpcBalloon", 0)
	if value and value ~= 0 then
		ShowNpcBalloon(true)
	else
		ShowNpcBalloon(false)
	end	
	
	value = iniS:ReadInteger(szSection, "ShowHideQuest", 1)
	if value and value ~= 0 then
		SetHideQuestShow(true)
	else
		SetHideQuestShow(false)
	end

	value = iniS:ReadInteger(szSection, "SelfCast", 1)
	if value and value ~= 0 then
		SetSelfCastSkill(true)
	else
		SetSelfCastSkill(false)
	end

	value = iniS:ReadInteger(szSection, "CastKeep", 0)
	if value and value ~= 0 then
		SetCastSkillKeepDown(true)
	else
		SetCastSkillKeepDown(false)
	end
	
	value = iniS:ReadInteger(szSection, "AutoPickup", 0)
	if value and value ~= 0 then
		LootList_SetRButtonPickupAll(true)
	else
		LootList_SetRButtonPickupAll(false)
	end

	value = iniS:ReadInteger(szSection, "PickupNearMouse", 1)
	if not value or value ~= 0 then
		LootList_SetOpenPosNearMouse(true)
	else
		LootList_SetOpenPosNearMouse(false)
	end

	value = iniS:ReadInteger(szSection, "EditBoxAlwaysShow", 1)
	if not value or value ~= 0 then
		SetEditBoxAlwaysShow(true)
	else
		SetEditBoxAlwaysShow(false)
	end
	
	value = iniS:ReadInteger(szSection, "ShowPlayerValue", 1)
	if value and value ~= 0 then
		SetPlayerShowStateValue(true)
	else
		SetPlayerShowStateValue(false)
	end

	value = iniS:ReadInteger(szSection, "ShowTargetValue", 1)
	if value and value ~= 0 then
		SetTargetShowStateValue(true)
	else
		SetTargetShowStateValue(false)
	end

	value = iniS:ReadInteger(szSection, "ShowTeammateValue", 0)
	if value and value ~= 0 then
		SetTeammateShowStateValue(true)
	else
		SetTeammateShowStateValue(false)
	end

	value = iniS:ReadInteger(szSection, "ShowValuePercentage", 0)
	if value and value ~= 0 then
		SetShowStateValueByPercentage(true)
	else
		SetShowStateValueByPercentage(false)
	end

	value = iniS:ReadInteger(szSection, "ShowExpValue", 1)
	if value and value ~= 0 then
		SetExpShowStateValue(true)
	else
		SetExpShowStateValue(false)
	end

	value = iniS:ReadInteger(szSection, "ShowTargetActionBar", 1)
	if value and value == 0 then
		SetTargetShowActionBar(false)
	else
		SetTargetShowActionBar(true)
	end

	value = iniS:ReadInteger(szSection, "ShowLoginTip", 1)
	if value and value == 0 then
		SetShowLoginTip(false)
	else
		SetShowLoginTip(true)
	end
	
	local t = GetCombatMeToTargetSetting()
	for k, v in pairs(t) do
		value = iniS:ReadInteger(szSection, "ComBate_Me_"..k, 1)
		if value and value == 0 then
			t[k] = false
		else
			t[k] = true
		end
	end
	SetCombatMeToTargetSetting(t)

	local t = GetCombatTargetToMeSetting()
	for k, v in pairs(t) do
		value = iniS:ReadInteger(szSection, "ComBate_Tar_"..k, 1)
		if value and value == 0 then
			t[k] = false
		else
			t[k] = true
		end
	end
	SetCombatTargetToMeSetting(t)

	value = iniS:ReadInteger(szSection, "SwapMouseButton", -1357)
	if not value or value == -1357 then
	elseif value == 1 then
		SwapMouseButton(true)
	else
		SwapMouseButton(false)
	end

	local bOpen, bCanDrag = GetSysMenuStatus()
	value = iniS:ReadInteger(szSection, "SysMenuDrag", 1)
	if value and value ~= 0 then
		bCanDrag = true
	else
		bCanDrag = false
	end
	value = iniS:ReadInteger(szSection, "SysMenuOpen", 1)
	if not value or value ~= 0 then
		bOpen = true
	else
		bOpen = false
	end
	SetSysMenuStatus(bOpen, bCanDrag)
	
    value = iniS:ReadInteger(szSection, "SelectTargetOldVersion", 0)
    if not value or value ~= 0 then
		SearchTarget_SetOtherSettting("nVersion", 1, "Enmey")
        SearchTarget_SetOtherSettting("nVersion", 1, "Ally")
	else
		SearchTarget_SetOtherSettting("nVersion", 2, "Enmey")
        SearchTarget_SetOtherSettting("nVersion", 2, "Ally")
	end  

	iniS:Close()
end

function LoadUIScaleSetting()
	local szIniFile = GetUserDataPath()
	if szIniFile == "" then
		return
	end
	szIniFile = szIniFile.."\\setting.ini"

	local szSection = "UISetting"
	
	local iniS = Ini.Open(szIniFile)
	if not iniS then
		Font.SetOffset(0)
		local fS = Station.GetMaxUIScale()
		local slider = cSlider.new(UISettingPanel.minUIScale, UISettingPanel.maxUIScale, UISettingPanel.nUIStep)
		local fUIScale = slider:ChangeToAreaFromValue(fS * UISettingPanel.minUIScale, fS * UISettingPanel.maxUIScale, UISettingPanel.defaultUIScale)
		Station.SetUIScale(fUIScale, true)
		return
	end
	
	local value = iniS:ReadInteger(szSection, "TextScale", 0)
	if not value then
		value = 0
	end
	Font.SetOffset(value)
	
	value = iniS:ReadFloat(szSection, "UIScale", UISettingPanel.defaultUIScale)
	if not value then
		value = UISettingPanel.defaultUIScale
	end
	local fS = Station.GetMaxUIScale()
	local slider = cSlider.new(UISettingPanel.minUIScale, UISettingPanel.maxUIScale, UISettingPanel.nUIStep)
	local fUIScale = slider:ChangeToAreaFromValue(fS * UISettingPanel.minUIScale, fS * UISettingPanel.maxUIScale, value)
	Station.SetUIScale(fUIScale, true)
	
	iniS:Close()
end

function SaveUISetting()
	local szIniFile = GetUserDataPath()
	if szIniFile == "" then
		return
	end
	szIniFile = szIniFile.."\\setting.ini"

	local szSection = "UISetting"
	
	local iniS = Ini.Open(szIniFile)
	if not iniS then
		iniS = Ini.Create()
	else
		iniS:EraseSection(szSection)
	end
	if not iniS then
		Trace("[UI UISettingPanel] error open create ini file "..szIniFile.."On SaveUISetting!\n")	
	end

	local fS = Station.GetMaxUIScale()
	local slider = cSlider.new(fS * UISettingPanel.minUIScale, fS * UISettingPanel.maxUIScale, UISettingPanel.nUIStep)
	local fUIScale = slider:ChangeToAreaFromValue(UISettingPanel.minUIScale, UISettingPanel.maxUIScale, Station.GetUIScale())
	iniS:WriteFloat(szSection, "UIScale", fUIScale)

	iniS:WriteInteger(szSection, "TextScale", Font.GetOffset())
	
	if IsMouseButtonSwaped() then
		iniS:WriteInteger(szSection, "SwapMouseButton", 1)
	else
		iniS:WriteInteger(szSection, "SwapMouseButton", 0)
	end
    
	if SearchTarget_IsOldVerion() then
		iniS:WriteInteger(szSection, "SelectTargetOldVersion", 1)
	else
		iniS:WriteInteger(szSection, "SelectTargetOldVersion", 0)
	end
    
	iniS:Save(szIniFile)

	iniS:Close()
	
end

AddLoadSettingFunction(LoadUISetting)
AddSaveSettingFunction(SaveUISetting)


---------------------------------头顶文字-----------------------------------------
GLOBAL_HEAD_CLIENTPLAYER = 0;
GLOBAL_HEAD_OTHERPLAYER = 1;
GLOBAL_HEAD_NPC = 2;

GLOBAL_HEAD_LEFE = 0;
GLOBAL_HEAD_GUILD = 1;
GLOBAL_HEAD_TITLE = 2;
GLOBAL_HEAD_NAME = 3;

g_bGlobalTopHeadFlag = 
{
	{false, false, true, false}, 
	{false, true, true, true}, 
	{false, false, true, true}
}

RegisterCustomData("g_bGlobalTopHeadFlag")
RegisterCustomData("UISettingPanel.nShakeMode")
RegisterCustomData("UISettingPanel.bCloseGJInJump")

function GetGlobalTopHeadFlag(nCharacterType, nHeadType)
	return g_bGlobalTopHeadFlag[nCharacterType + 1][nHeadType + 1]
end

function SetGlobalTopHeadFlag(nCharacterType, nHeadType, bShow)
	g_bGlobalTopHeadFlag[nCharacterType + 1][nHeadType + 1] = bShow
	Global_SetTopHeadFlag(nCharacterType, nHeadType, bShow)
end

function InitGlobalTopHeadFlag()
	if arg0 ~= "Role" then
		return
	end
	for i = 0, 2, 1 do
		for j = 0, 3, 1 do
			local bShow = false
			if g_bGlobalTopHeadFlag[i + 1][j + 1] then
				bShow = true
			end
			Global_SetTopHeadFlag(i, j, bShow)
		end
	end
	Global_UpdateHeadTopPosition()
end

local function UpdateShakeMode()
	if UISettingPanel.nShakeMode == 0 then
		rlcmd("set camera shake mode 0")
		
	elseif UISettingPanel.nShakeMode == 1 then
		rlcmd("set camera shake mode 1")
		
	elseif UISettingPanel.nShakeMode == 2 then
		rlcmd("set camera shake mode 2")
	end
	
	if UISettingPanel.bCloseGJInJump then
		rlcmd("close sprint camera")
	else
		rlcmd("open sprint camera")
	end
end

local lc_bSyncTeamFightData = true
function IsSyncTeamFightData()
	return lc_bSyncTeamFightData
end

function SetSyncTeamFightDataState(bState)
	lc_bSyncTeamFightData = bState
end

local function OnPartyMsgNotify()
	if arg0 == PARTY_NOTIFY_CODE.PNC_PARTY_JOINED or 
	   arg0 == PARTY_NOTIFY_CODE.PNC_PARTY_CREATED then
		SetTeamSkillEffectSyncOption(true)
		lc_bSyncTeamFightData = true
	end
end

local function OnLoadingEnd()
	SetTeamSkillEffectSyncOption(lc_bSyncTeamFightData)
end

RegisterEvent("PARTY_MESSAGE_NOTIFY", OnPartyMsgNotify)
RegisterEvent("LOADING_END", OnLoadingEnd)
RegisterEvent("CUSTOM_DATA_LOADED", 
	function() 
		InitGlobalTopHeadFlag() 
		
		if arg0 == "Role" then
			UpdateShakeMode()
		end
	end
)
