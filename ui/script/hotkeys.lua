local SCREENSHOT_QUALITY = 100
local SCREENSHOT_SUFFIX = "jpg"
local lc_tACloseTopmost = {}
local lc_tAutoClose = {}

g_aVKeyToDesc = 
{
--	0x0,		0x1,		0x2,		0x3,		0x4,		0x5,		0x6,		0x7,		0x8,		0x9,		0xA,		0xB,		0xC,		0xD,		0xE,		0xF,
				"LButton",	"RButton",	"Cancel",	"MButton",	"XButton1",	"XButton2",	"",			"Backspace","Tab",		"",			"",			"Clear",	"Enter",	"",			"",
	"Shift",	"Ctrl",		"Alt",		"Pause",	"CapLock",	"Hanguel",	"",			"Junja",	"Final",	"Kanji",	"",			"Esc",		"Convert",	"NonConvert","Accept",	"ModeChange",
	"Space",	"PageUp",	"PageDown",	"End",		"Home",		"Left",		"Up",		"Right",	"Down",		"Select",	"Print",	"Execute",	"PrintScreen",	"Insert",	"Delete",	"Help",
	"0",		"1",		"2",		"3",		"4",		"5",		"6",		"7",		"8",		"9",		"",			"",			"",			"",			"",			"",
	"",			"A",		"B",		"C",		"D",		"E",		"F",		"G",		"H",		"I",		"J",		"K",		"L",		"M",		"N",		"O",
	"P",		"Q",		"R",		"S",		"T",		"U",		"V",		"W",		"X",		"Y",		"Z",		"LWin",		"RWin",		"Apps",		"",			"",
	"Num0",		"Num1",		"Num2",		"Num3",		"Num4",		"Num5",		"Num6",		"Num7",		"Num8",		"Num9",		"Multiply",	"Add",		"Separator","Subtract",	"Decimal",	"Divide",
	"F1",		"F2",		"F3",		"F4",		"F5",		"F6",		"F7",		"F8",		"F9",		"F10",		"F11",		"F12",		"F13",		"F14",		"F15",		"F16",
	"F17",		"F18",		"F19",		"F20",		"F21",		"F22",		"F23",		"F24",		"",			"",			"",			"",			"",			"",			"",			"",
	"NumLock",	"ScrollLock","",		"",			"",			"",			"",			"",			"",			"",			"",			"",			"",			"",			"",			"",
	"",			"",			"",			"",			"",			"",			"BrowserBack","BrowserForward","BrowserRefresh","BrowserStop","BrowserSearch","BrowserFavorites","BrowserHome","VolumeMute","VolumeDown","VolumeUp",
	"MediaNextTrack","MediaPrevTrack","MediaStop","MediaPlayPause","LaunchMail","LaunchMediaSelect","LaunchApp1","LaunchApp2","","","OEM1","OEMPlus","OEMComma","OEMMinus","OEMPeriod",	"OEM2",
	"OEM3",		"",			"",			"",			"",			"",			"",			"",			"",			"",			"",			"",			"",			"",			"",			"",
	"",			"",			"",			"",			"",			"",			"",			"",			"",			"",			"",			"[",		"\\",		"]",		"'",		"",
	"",			"",			"",			"",			"",			"",			"",			"",			"",			"",			"",			"",			"",			"",			"",			"",
	"",			"",			"",			"",			"",			"",			"",			"",			"",			"",			"",			"",			"",			"",			"",			"",
	"MouseWheelUp","MouseWheelDown","MouseHover",""
};

g_aDescToVKey = {[""] = 0 }
for index, value in pairs(g_aVKeyToDesc) do
	if value ~= "" then
		g_aDescToVKey[value] = index
	end
end

function GetKeyValue(szKey)
	return g_aDescToVKey[szKey]
end

function GetKeyName(nKey)
	if nKey == 0 then
		return ""
	end
	return g_aVKeyToDesc[nKey]
end

function IsShiftKeyDown()
	return Hotkey.IsKeyDown(0x10)
end

function IsCtrlKeyDown()
	return Hotkey.IsKeyDown(0x11)
end

function IsAltKeyDown()
	return Hotkey.IsKeyDown(0x12)
end

function IsKeyDown(szKey)
	local nValue = GetKeyValue(szKey)
	if nValue and nValue ~= 0 then
		return Hotkey.IsKeyDown(nValue)
	end
	return false
end

function GetKeyShow(nKey, bShift, bCtrl, bAlt, bShort)
	if bShort then
		local szMKey = g_tHotKey.taVKeyToShowDescShort[nKey]
		if not szMKey or szMKey == "" then
			return ""
		end
		local szKey = ""		
		if bCtrl then
			szKey = szKey..g_tHotKey.taVKeyToShowDescShort[0x11].."+"
		end
		if bAlt then
			szKey = szKey..g_tHotKey.taVKeyToShowDescShort[0x12].."+"
		end
		if bShift then
			szKey = szKey..g_tHotKey.taVKeyToShowDescShort[0x10].."+"
		end
		return szKey..szMKey
	end

	local szMKey = g_tHotKey.taVKeyToShowDesc[nKey]
	if not szMKey or szMKey == "" then
		return ""
	end
	local szKey = ""	
	if bCtrl then
		szKey = szKey..g_tHotKey.taVKeyToShowDesc[0x11].."+"
	end
	if bAlt then
		szKey = szKey..g_tHotKey.taVKeyToShowDesc[0x12].."+"
	end
	if bShift then
		szKey = szKey..g_tHotKey.taVKeyToShowDesc[0x10].."+"
	end
	return szKey..szMKey
end


---------------------------------------------------------------------------------------
local bPrepareStart = false
local nPrepareStartTime = 0
local bStart = false
local nStartTime = 0
local bInCarrier = false
function MoveForwardStart()	
    if bInCarrier then
        OnUseSkill(3799, 1)
    else
        Camera_EnableControl(CONTROL_FORWARD, true)
        CheckStartSpecalQinggong()
    end
	
end

function MoveForwardStop()
	Camera_EnableControl(CONTROL_FORWARD, false)
    CheckEndSpecalQinggong()
end

function MoveBackwardStart()
    if bInCarrier then
        OnUseSkill(3800, 1)
    else
        Camera_EnableControl(CONTROL_BACKWARD, true)
        local player = GetClientPlayer()
        if player and bStart then
            bStart = false
            player.Sprint(false)
        end
    end
end

function MoveBackwardStop()
	Camera_EnableControl(CONTROL_BACKWARD, false)
end

function TurnLeftStart()
	Camera_EnableControl(CONTROL_TURN_LEFT, true)
end

function TurnLeftStop()
	Camera_EnableControl(CONTROL_TURN_LEFT, false)
end

function TurnRightStart()
	Camera_EnableControl(CONTROL_TURN_RIGHT, true)
end

function TurnRightStop()
	Camera_EnableControl(CONTROL_TURN_RIGHT, false)
end

function StrafeLeftStart()
    if bInCarrier then
        OnUseSkill(3801, 1)
    else
        Camera_EnableControl(CONTROL_STRAFE_LEFT, true)
    end
end

function StrafeLeftStop()

	Camera_EnableControl(CONTROL_STRAFE_LEFT, false)
end

function StrafeRightStart()
    if bInCarrier then
        OnUseSkill(3802, 1)
    else
        Camera_EnableControl(CONTROL_STRAFE_RIGHT, true)
    end
end

function StrafeRightStop()
	Camera_EnableControl(CONTROL_STRAFE_RIGHT, false)
end

function MoveUpStart()
    Camera_EnableControl(CONTROL_UP, true)
end

function MoveUpStop()
    Camera_EnableControl(CONTROL_UP, false)
end

function MoveDownStart()
    Camera_EnableControl(CONTROL_DOWN, true)
end

function MoveDownStop()
    Camera_EnableControl(CONTROL_DOWN, false)
end

function Jump()
    if bInCarrier then
        OnUseSkill(3779, 1)
    else
        local player = GetClientPlayer()
        if not player then
            return
        end
        
        local nMoveState = player.nMoveState
        local bOnHorse = player.bOnHorse
        
        if player.bOnHorse then
            if nMoveState == MOVE_STATE.ON_STAND or IsCharacterMoving(CONTROL_BACKWARD) then
                OnUseSkill(48,1)
            else
                Camera_EnableControl(CONTROL_JUMP, true)
            end
        else
            FireEvent("ON_PLAYER_JUMP")
            
            if (nMoveState == MOVE_STATE.ON_RUN 
            or nMoveState == MOVE_STATE.ON_WALK
            or nMoveState == MOVE_STATE.ON_STAND) 
            and IsCharacterMoving(CONTROL_BACKWARD) then
                Camera_LockControl(8)
                OnUseSkill(9007,1)
            else
                Camera_EnableControl(CONTROL_JUMP, true)
            end
        end
    end
end

function RideHorse()
	local player = GetClientPlayer()
	if not GetPlayerItem(player, INVENTORY_INDEX.EQUIP, EQUIPMENT_INVENTORY.HORSE) then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.DIS_NOT_EQUIP_HORSE)
		return
	elseif player.GetSkillLevel(605) < 1 then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.DID_NOT_LEARN_RIDE)
		return
	end
	
	if player.bOnHorse then
		OnUseSkill(54,1)
	else
		OnUseSkill(53,1)
	end
end

function DownHorse()
end

function EndJump()
end

function ToggleAutoRun()
	Camera_ToggleControl(CONTROL_AUTO_RUN)
end

function ToggleSheath()
	local player=GetClientPlayer()
	local nMoveState = player.nMoveState
	
    if nMoveState == MOVE_STATE.ON_SIT 
	or nMoveState == MOVE_STATE.ON_DEATH
	or player.bFightState then
    	return
    end
    
	if player.bSheathFlag then
		player.SetSheath(0)
	else
		player.SetSheath(1)
	end
end

function ToggleSitDown()
	local player=GetClientPlayer()
	if player.nMoveState == MOVE_STATE.ON_SIT then
    	player.Stand()
    else
    	OnUseSkill(17, 1) --打坐技能
    end
	collectgarbage("collect")
end

function CameraSetView(fAngle)
	Camera_SetView(fAngle)
end

function ToggleRun()
	Camera_ToggleControl(CONTROL_WALK)
end

function ActionButtonDown(nGroupID, nButtonID)
	ActionBar_ButtonDown(nGroupID, nButtonID)
end

function ActionButtonUp(nGroupID, nButtonID)
	ActionBar_ButtonUp(nGroupID, nButtonID)
end

function ChangeActionBarPage(nPage)
	SelectMainActionBarPage(nPage)
end

function ActionBar_PageDown()
	SelectMainActionBarPage(GetMainActionBarPage() + 1)
end

function ActionBar_PageUp()
	SelectMainActionBarPage(GetMainActionBarPage() - 1)
end

function LockOrUnlockActionBar()
	if IsActionBarLocked() then
		LockActionBar(false)
	else
		LockActionBar(true)
	end
end

function SelectPlayer()
	SelectSelf()
end

function TogglePanel(szFrame)
	if szFrame == "OPTION" then				--系统菜单
		--注意：用户按ESC的时候可能还要做其它事情，比如，取消技能等.
		
		------------取消百草园面板------------------------
		if FarmPanel and FarmPanel.frameSelf and FarmPanel.frameSelf:IsVisible() then
			FarmPanel.ClosePanel()
			return
		end
		if IrrigatePanel and IrrigatePanel.frameSelf and IrrigatePanel.frameSelf:IsVisible() then
			IrrigatePanel.ClosePanel()
			return
		end
		
		------------取消隐藏界面------------------------
		if not Station.IsVisible() then
			if FilterMask and FilterMask.bHideUI then
				return
			end
			Station.Show()
			return
		end
		
		-----------关闭退出游戏确认面板---------------
		if IsExitPanelOpened() then
			CloseExitPanel()
			return
		end
		
		-------------关闭帮会重命名面板------------------
		if IsGuildRenameOpened() then
			CloseGuildRename()
			return
		end
		
		--------------关闭奖励通用面板-----------------
		if IsItemBoxOpened() then
			CloseItemBox()
			return
		end
		
		-----------关闭世界地图，以及相关---------------
		if IsTrafficSurepanelOpened() then
			CloseTrafficSurepanel()
			return
		end
		
		if IsWorldMapOpend() then
			CloseWorldMap()
			return
		end
		
		-----------关闭召唤面板------------------
		if IsCallFriendPannelOpened() then
			CloseCallFriendPannel()
			return
		end

		if IsCallGuildMemberPannelOpened() then
			CloseCallGuildMemberPannel()
			return
		end
		
		------------关闭中地图,以及相关------------------
		if IsEditMiddleMapFlagOpened()  then
			CloseEditMiddleMapFlag()
			return
		end
		
		if IsMiddleMapOpened() then
			CloseMiddleMap()
			return
		end
		
		if IsUICustomModePanelOpened() then
			CloseUICustomModePanel()
			return
		end
		
			
  		if IsOpenEmotionManagePanel() then
  			CloseEmotionManagePanel()
  			return
  		end
  
		if IsOpenEmotionPanel() then
			CloseEmotionPanel()
			return
		end
		
		----------取消手上的物品和其他鼠标状态----------------
		if not Hand_IsEmpty() then
			Hand_Clear()
			return
		end		
		
		-------------取消MessageBox--------------
		if CloseLastMessageBox() then
			return
		end
		
		for k, v in pairs(lc_tACloseTopmost) do
			if v.fnCondition and v.fnCondition() then
				v.fnAction()
				return
			end
		end
		
		-------------取消输入数字,和输入名字的面板----------
		local bProcessed = false
		if CloseGetNamePanel() then
			bProcessed = true
		end
		if CloseGetNumberPanel() then
			bProcessed = true
		end
		if CloseGetPricePanel() then
			bProcessed = true
		end
		if bProcessed then
			return
		end
		
		-------------关闭副本提示面板------------
		if IsIntroduceOpened() then
			CloseIntroduce()
			return
		end
		
		-------------关闭经脉面板--------------
		if IsChannelsPanelOpened() then
			CloseChannelsPanel()
			return
		end
		
		if IsVideoSettingPanelOpened() then
			CloseVideoSettingPanel()
			return
		end
		
		--------------IE面板--------------------
		if CloseLastInternetExplorer() then
			return
		end		

		--------------Esc菜单上的面板------------
		if CloseOptionAndOptionChildPanel() then
			return
		end
		
		-------------历程界面----------------------------
		if IsCouresOpened() and CanCloseCouresPanel() then
			CloseCoures()
			return
		end
		
		------------理发店界面--------------------------
		if IsHairShopOpened() then
			CloseHairShop()
			return
		end
		
		-------------问卷界面----------------------------
		if IsQuestionnairePanelOpened() then
			CloseQuestionnairePanel()
			return
		end
		
        ---------------逍遥问问---------------------------
		if IsXoyoAskPanelOpened() then
			CloseXoyoAskPanel()
			return
		end
        
		---------------江湖指南---------------------------
		if IsCyclopaediaOpened() then
			CloseCyclopaedia()
			return
		end
		
		-----------------活动日历---------------------------
		if IsCalenderPanelOpened() then
			CloseCalenderPanel()
			return
		end
        
        -----------------装备大全---------------------------
		if IsEquipInquireOpened() then
			CloseEquipInquire()
			return
		end
        
		-----------------帮会擂台------------------------
		if IsTongArenaOpened() then
			CloseTongArena()
			return
		end
		        
		--------------GM面板--------------------
		if IsGMPanelOpened() then
			CloseGMPanel()
			return
		end	
		
		--------------科举面板--------------------
		if ExaminationPanel.IsOpened() then
			ExaminationPanel:ClosePanel()
			return
		end
		
		if IsTongTechTreePanelOpened() then
			CloseTongTechTreePanel()
			return
		end
		
		if IsFishPanelOpened() then
			CloseFishPanel()
			
			return
		end
		
		if IsTongFarmPanelOpened() then
			CloseTongFarmPanel()
			return
		end
		
		------------帮会工资-------------------
		if IsGuildSalaryPanelOpened() then
			CloseGuildSalaryPanel()
			return
		end
		
		if IsPayPathPanelOpened() then
			ClosePayPathPanel()
			return
		end
		
		if IsGuildListPanelOpened() then
			CloseGuildListPanel()
			return
		end
        ---------------------活动推广界面-----------------
        if IsActivePopularizeOpened() then
			CloseActivePopularize()
			return
		end
        
         ---------------------衣柜界面-----------------
        if IsExteriorBoxOpened() then
			CloseExteriorBox()
			return
		end
        
		------------关闭所有ItemLink--------------------
		bProcessed = false
		if CloseLinkTipPanel() then
			bProcessed = true
		end
		
		if CloseAllAchievementTip() then
			bProcessed = true
		end
		if bProcessed then
			return
		end
		
		------------关闭拾取面板----------------
		if IsLootListOpened() then
			CloseLootList()
			return
		end
		
		if IsBattleFieldPanelOpen() then
			CloseBattleFieldPanel()
			return
		end
		
		if IsTwoDungeonRewardOpened() then
			CloseTwoDungeonReward()
			return
		end
        
		if IsRandomRewardPanelOpened() then
			CloseRandomRewardPanel()
			return true
		end
		
		--------------二级菜单上的面板----------
		local bProcessed = false
		if CorrectAutoPosFrameEscClose() then
			bProcessed = true
		end
		
		-------------背包---------------------
		if not IsAllBagPanelClosed() then
			CloseAllBagPanel()
			bProcessed = true
		end
		if bProcessed then
			return
		end
	
	    ----------取消玩家正释放的技能等其他行为--------
		if GetClientPlayer().StopCurrentAction() then
			return
		end
				
		if IsCursorInExclusiveMode() then
			Cursor.Switch(CURSOR.NORMAL)
			return
		end

		--------------取消target-----------------
		if IsTargetPanelOpened() then
			CloseTargetPanel()
			return
		end
		
		
		if IsWeaponBagOpen() and not CharacterPanel_IsCharacterOpen() then
			CloseWeaponBag()
			return
		end
		
		for k, v in pairs(lc_tAutoClose) do
			if v.fnCondition and v.fnCondition() then
				v.fnAction()
				return
			end
		end
		
		----------打开Esc面板-----------
		OpenOptionPanel()
	elseif szFrame == "GM" then 
		if IsGMPanelOpened() then
			CloseGMPanel()
		else
			OpenGMPanel("Bug")
		end		
	elseif szFrame == "EQUIP" then  		--装备
		if IsCharacterPanelOpened() then
			CloseCharacterPanel()
		else
			OpenCharacterPanel()
		end
	elseif szFrame == "FRIEND" then		--好友
		if IsPartyPanelOpened() then
			ClosePartyPanel()
		else
			OpenPartyPanel()
		end
	elseif szFrame == "GUILD" then --帮会
		if IsGuildPanelOpened() then
			CloseGuildPanel()
		else
			OpenGuildPanel()
		end
	elseif szFrame == "PRODUCT" then
		if IsFEProducePanelOpened() then
			CloseFEProducePanel()
		else
			OpenFEProducePanel()
		end
    elseif szFrame == "QUEST" then		--任务
		if IsQuestPanelOpened() then
			CloseQuestPanel()
		else
			OpenQuestPanel()
		end    
	elseif szFrame == "SKILL" then		--技能
		if IsSkillPanelOpened() then
			CloseSkillPanel()
		else
			OpenSkillPanel()
		end
	elseif szFrame == "CHANNEL" then --经脉
		if IsChannelsPanelOpened() then
			CloseChannelsPanel()
		else
			OpenChannelsPanel()
		end		
	elseif szFrame == "CRAFT" then		--生活技能
		if IsCraftPanelOpened() then
			CloseCraftPanel()
		else
			OpenCraftPanel()
		end
	elseif szFrame == "STUDY" then		--阅读
		if IsCraftReadManagePanelOpened() then
			CloseCraftReadManagePanel()
		else
			OpenCraftReadManagePanel()
		end
	elseif szFrame == "UI_CUSTOM_MODE" then
		if IsUICustomModePanelOpened() then
			CloseUICustomModePanel()
		else
			OpenUICustomModePanel()
		end
	elseif szFrame == "FOUNDRY" then
	elseif szFrame == "FPS" then 	--FPS
		Wnd.ToggleWindow("FPS")
--		Wnd.ToggleWindow("ActiveMessage0")
	elseif szFrame == "DEBUG" then
		Wnd.ToggleWindow("Debug")
		Wnd.ToggleWindow("DebugNpcPortrait")
	elseif szFrame == "SCENE" then
		SceneMain_ToggleVisible()
	elseif szFrame == "SCENE_MINI" then
		--Wnd.ToggleWindow("SceneMini")
	elseif szFrame == "ACHIEVEMENT" then
		if IsAchievementPanelOpened() then
			CloseAchievementPanel()
		else
			OpenAchievementPanel()
		end
	elseif szFrame == "MENTOR" then
		if IsMentorPanelOpened() then
			CloseMentorPanel()
		else
			OpenMentorPanel()
		end
        --[[
	elseif szFrame == "PARTY_RECRUIT" then
		if IsPartyRecruitPanelOpened() then
			ClosePartyRecruitPanel()
		else
			OpenPartyRecruitPanel()
		end
        ]]
	elseif szFrame == "TALENT" then
		if IsZhenPaiSkillOpened() then
			CloseZhenPaiSkill()
		else
			OpenZhenPaiSkill()
		end
	elseif szFrame == "ARENA_PANEL" then
		if IsArenaCorpsPanelOpened() then
			CloseArenaCorpsPanel()
		else
			OpenArenaCorpsPanel()
		end
	end
end

function ToggleBag(nBagID)
	if IsBagPanelOpened(nBagID) then
		CloseBagPanel(nBagID)
	else
		OpenBagPanel(nBagID)
	end
end

function OpenOrCloseAllBags()
	if IsAllBagPanelOpened() then
		CloseAllBagPanel()
	else
		OpenAllBagPanel()
	end
end

function TakeScreenshot()
	local szFilePath = ScreenShot(SCREENSHOT_SUFFIX, SCREENSHOT_QUALITY)
	if szFilePath then
		OutputMessage("MSG_ANNOUNCE_YELLOW",g_tStrings.SCREENSHOT)
		
		local szScreenshot = g_tStrings.SCREENSHOT_MSG .. szFilePath .. "\n"
		OutputMessage("MSG_SYS", szScreenshot)
	end
end

function NextView()
	OutputMessage("MSG_ANNOUNCE_RED","TODO:NextView()\n")
	--TODO:
end

function PrevView()
	OutputMessage("MSG_ANNOUNCE_RED","TODO:PrevView()\n")
	--TODO:
end

function CameraZoomIn()
	Camera_Zoom(0.9)
end

function CameraZoomOut()
	Camera_Zoom(1.1)
end

function MoveViewInStart()
	OutputMessage("MSG_ANNOUNCE_RED","TODO:MoveViewInStart()\n")
	--TODO:
end

function MoveViewInStop()
	OutputMessage("MSG_ANNOUNCE_RED","TODO:MoveViewInStop()\n")
	--TODO:
end

function MoveViewOutStart()
	OutputMessage("MSG_ANNOUNCE_RED","TODO:MoveViewOutStart()\n")
	--TODO:
end

function MoveViewOutStop()
	OutputMessage("MSG_ANNOUNCE_RED","TODO:MoveViewOutStop()\n")
	--TODO:
end

function MoveViewLeftStart()
	OutputMessage("MSG_ANNOUNCE_RED","TODO:MoveViewLeftStart()\n")
	--TODO:
end

function MoveViewLeftStop()
	OutputMessage("MSG_ANNOUNCE_RED","TODO:MoveViewLeftStop()\n")
	--TODO:
end

function MoveViewRightStart()
	OutputMessage("MSG_ANNOUNCE_RED","TODO:MoveViewRightStart()\n")
	--TODO:
end

function MoveViewRightStop()
	OutputMessage("MSG_ANNOUNCE_RED","TODO:MoveViewRightStop()\n")
	--TODO:
end

function MoveViewUpStart()
	OutputMessage("MSG_ANNOUNCE_RED","TODO:MoveViewUpStart()\n")
	--TODO:
end

function MoveViewUpStop()
	OutputMessage("MSG_ANNOUNCE_RED","TODO:MoveViewUpStop()\n")
	--TODO:
end

function MoveViewDownStart()
	OutputMessage("MSG_ANNOUNCE_RED","TODO:MoveViewDownStart()\n")
	--TODO:
end

function MoveViewDownStop()
	OutputMessage("MSG_ANNOUNCE_RED","TODO:MoveViewDownStop()\n")
	--TODO:
end

function SetView(nViewIndex)
	OutputMessage("MSG_ANNOUNCE_RED","TODO:SetView()\n")
	--TODO:
end

function SaveView(nViewIndex)
	OutputMessage("MSG_ANNOUNCE_RED","TODO:SaveView()\n")
	--TODO:
end

function ResetView(nViewIndex)
	OutputMessage("MSG_ANNOUNCE_RED","TODO:ResetView()\n")
	--TODO:
end

function FlipCameraYaw(nAngle)
	OutputMessage("MSG_ANNOUNCE_RED","TODO:FlipCameraYaw()\n")
	--TODO:
end

function CameraOrSelectOrMoveStart(stickyFlag)
	Ctrl_CameraOrSelectOrMoveStart(stickyFlag)
end

function CameraOrSelectOrMoveStop(stickyFlag)
	Ctrl_CameraOrSelectOrMoveStop(stickyFlag)
end

function TakeKinescope()
	if IsMovieRecord() then
		FinishMovieRecord()
	else
		local nWidth, nHeight = Station.GetClientSize()
		local tMsg =
		{
			x = nWidth / 2, y = nHeight / 2,
			bVisibleWhenHideUI = true, --在隐藏UI的模式下仍然显示。
			szMessage = g_tStrings.MSG_SLOWER_AFTER_OPEN_MOVIE,
			szName = "IsOpenMovie",
			{szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = function() StartMovieRecord() end},
			{szOption = g_tStrings.STR_HOTKEY_CANCEL, fnAction = function() end}
		}
		MessageBox(tMsg)
	end
end

function OnCaptureHotkey()
	local nKey, bShift, bCtrl, bAlt = Hotkey.GetCaptureKey()
	HotkeyPanel_SetHotkey(nKey, bShift, bCtrl, bAlt)
end

function OnCancelHotkeySetting()
	HotkeyPanel_CancelSetHotkey()
end

function ToggleUI()
	if Station.IsVisible() then
		Station.Hide()
	else
		if FilterMask and FilterMask.bHideUI then
			return
		end
		Station.Show()
	end
end

--控制中地图
function ToggleMiddleMap()
	if IsWorldMapOpend() then
		CloseWorldMap()
	elseif IsMiddleMapOpened() then
		CloseMiddleMap()
	else
		OpenMiddleMap()
	end
end

function ToggleWorldMap()
	if IsWorldMapOpend() then
		CloseWorldMap()
	else
		if IsMiddleMapOpened() then
			CloseMiddleMap(true)
		end
		OpenWorldMap()
	end
end

function OpenChatEditBox()
	OpenEditBox()
end

function AttackTarget()
	CastCommonSkill(true)
end

function ShortCutReply()
	local szName = EditBox.GetLastReply()
	if szName then
		EditBox_TalkToSomebody(szName)
	end
end

function FollowTarget()
	local player = GetClientPlayer()
	if player then
		local dwType, dwID = player.GetTarget()
		if dwType == TARGET.PLAYER then
			StartFollow(dwType, dwID)
		end
	end
end

function EquipKongfu(dwID)
	local player = GetClientPlayer()
	if player then
		local dwLevel = player.GetSkillLevel(dwID)
		if dwLevel and dwLevel > 0 then
			player.MountKungfu(dwID, dwLevel, true)
		end
	end
end

function CastSkillByKeyDown(szType)
    local dwID = 0;
    if szType == "SKILL_CAST_FORWARD" then
        dwID = 9003
    elseif szType == "SKILL_CAST_BACK" then
        dwID = 9004
    elseif szType == "SKILL_CAST_LEFT" then
        dwID = 9005
    elseif szType == "SKILL_CAST_RIGHT" then
        dwID = 9006
    end
    
    local player = GetClientPlayer()
    if player then
        local dwLevel = player.GetSkillLevel(dwID)
        if dwLevel and dwLevel > 0 then
            CastSkill(dwID, dwLevel)
        end
    end
end

function ToggleNpc()
	if _g_HideNPc then
		rlcmd("show npc")
		_g_HideNPc = false
	else
		rlcmd("hide npc")
		_g_HideNPc = true
	end
end

function TogglePlayer()
	if _g_HidePlayerType == "-player" then
		rlcmd("show player")
		_g_HidePlayerType = nil
		RemoteCallToServer("OnSetOptimizationNetworkFlag", 0)
	elseif _g_HidePlayerType == "-player+party" then
		rlcmd("show party player")
		_g_HidePlayerType = "-player" 
	else
		rlcmd("hide player")
		_g_HidePlayerType = "-player+party"
		RemoteCallToServer("OnSetOptimizationNetworkFlag", 1)
	end
end

function PlayerChangeSuit(index)
	OnSuitChangeHotkey(index)
end

function CheckStartSpecalQinggong()
    if bStart then 
        return
    end
    
    local nTime = GetTickCount()
    if not bPrepareStart then
        PrepareStartSpecalQinggong()
        return
    end
    if nTime - nPrepareStartTime > 500 then
        PrepareStartSpecalQinggong()
        return
    end
    StartSpecalQinggong()
end

function PrepareStartSpecalQinggong()
     bPrepareStart = true
     nPrepareStartTime = GetTickCount()
end

function StartSpecalQinggong()
    nStartTime = GetTickCount()
	
	local player = GetClientPlayer()
	if player then
	    if player.bIgnoreGravity then 
	        return
	    end
	    bStart = true
	    player.Sprint(true)
	end

    --ToggleMiddleMap()
end

function CheckEndSpecalQinggong()
    if bStart then
        EndSpecalQinggong()
        return
    end
    if bPrepareStart then
        if GetTickCount() - nPrepareStartTime > 500 then
             PrepareEndSpecalQinggong()
        end
    end
end

function PrepareEndSpecalQinggong()
    bPrepareStart = false
end

function EndSpecalQinggong()
	local player = GetClientPlayer()
	if player then
    		if player.bIgnoreGravity then 
		    return
		end
		bStart = false
		player.Sprint(false)
	end

    --ToggleMiddleMap()
end

_g_HidePlayerType = "+player"

rlcmd("show npc")
rlcmd("show player")

function RegisterAutoClose(szKey, fnCondition, fnAction)
	if not lc_tAutoClose[szKey] then
		lc_tAutoClose[szKey] = {}
	end
	lc_tAutoClose[szKey].fnCondition = fnCondition
	lc_tAutoClose[szKey].fnAction = fnAction
end

function RegisterAutoClose_Topmost(szKey, fnCondition, fnAction)
	if not lc_tACloseTopmost[szKey] then
		lc_tACloseTopmost[szKey] = {}
	end
	lc_tACloseTopmost[szKey].fnCondition = fnCondition
	lc_tACloseTopmost[szKey].fnAction = fnAction
end

function EnterOrLeaveCarrier(szEvent)
    if szEvent == "CHANGE_CARRIER_STATE" then
        bInCarrier = arg0
    end
end

RegisterEvent("CHANGE_CARRIER_STATE", function(szEvent) EnterOrLeaveCarrier(szEvent) end)
