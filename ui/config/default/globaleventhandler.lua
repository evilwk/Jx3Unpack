local AUTO_EXIT_INTERVAL = 35 * 60 * 1000
local nLeftTimeRemindCount = 0 -- 剩余时间提醒的次数，服务器16s提醒一次

local function IsSelfData(dwCharacter)
    local player = GetClientPlayer()
	if not player then
		return false
	end
    
    if player.dwID == dwCharacter then
        return true
    elseif not IsPlayer(dwCharacter) then
        local Npc = GetNpc(dwCharacter)
        if Npc and Npc.dwEmployer == player.dwID then
            return true
        end
    end
    return false
end

local function IsPartyData(dwCharacter)
    local player = GetClientPlayer()
	if not player then
		return false
	end
    
    if IsParty(dwCharacter, player.dwID) then
        return true
    elseif not IsPlayer(dwCharacter) then
        local Npc = GetNpc(dwCharacter)
        if Npc and Npc.dwEmployer ~= 0 then
            local hTeam = GetClientTeam()
            if hTeam and hTeam.IsPlayerInTeam(Npc.dwEmployer) then
                return true
            end
        end
    end
    return false
end

GlobalEventHandler={
	tBreatheAction = {},
	tBeAddFoeEndSeconds = {},
	tLastShowBeAddFoeLeftSeconds = {},
	tAddFoeEndSeconds = {},
	tLastShowAddFoeLeftSeconds = {},

OnFrameCreate=function()
--	Trace("OnFrameCreate("..szSelfName..")\n")
	this:RegisterEvent("SYS_MSG")

	this:RegisterEvent("NPC_TALK")

	this:RegisterEvent("SHOP_OPENSHOP")

	this:RegisterEvent("PEEK_OTHER_PLAYER")		-- 查看玩家装备属性

	this:RegisterEvent("NPC_DISPLAY_DATA_UPDATE")
	this:RegisterEvent("PLAYER_DISPLAY_DATA_UPDATE")

	-----------队伍相关托管-----------------------------------------------------------------
	this:RegisterEvent("PARTY_MESSAGE_NOTIFY")
	this:RegisterEvent("PARTY_DISBAND")
	this:RegisterEvent("PARTY_UPDATE_BASE_INFO")
	this:RegisterEvent("PARTY_LOOT_MODE_CHANGED")
	this:RegisterEvent("PARTY_ROLL_QUALITY_CHANGED")
	this:RegisterEvent("TEAM_AUTHORITY_CHANGED")
	this:RegisterEvent("PARTY_SET_FORMATION_LEADER")
	this:RegisterEvent("PARTY_SET_MARK")
	this:RegisterEvent("PARTY_DELETE_MEMBER")
	this:RegisterEvent("PARTY_UPDATE_MEMBER_INFO")

	----------交易托管-------------------------------------
	this:RegisterEvent("TRADING_INVITE")
	this:RegisterEvent("TRADING_OPEN_NOTIFY")
	this:RegisterEvent("AUCTION_MESSAGE_NOTIFY")

	this:RegisterEvent("OPEN_BANK")

	this:RegisterEvent("PLAYER_TALK")
	this:RegisterEvent("ANNOUNCE_TALK")
   
	this:RegisterEvent("GET_PLAYER_MESSAGE_MAIL")
	this:RegisterEvent("PLAYER_DEATH")

	this:RegisterEvent("NPC_TALK_USE_SENTENCE_ID")

	this:RegisterEvent("NPC_ENTER_SCENE")
	this:RegisterEvent("NPC_LEAVE_SCENE")

	---------生活技能相关托管------------------------------
	this:RegisterEvent("OPEN_RECIPE_BOOK")
	this:RegisterEvent("OPEN_BOOK")	--预留读书面板事件响应
	this:RegisterEvent("PEEK_PLAYER_BOOK_STATE")
	this:RegisterEvent("FE_BREAK_EQUIP") --装备分解

	--------- PK相关 --------------------------------------
	this:RegisterEvent("APPLY_DUEL")
	this:RegisterEvent("LEAVE_DUEL")

	---------拾取物品相关-----------------------------------
	this:RegisterEvent("BEGIN_ROLL_ITEM")
	this:RegisterEvent("LOOT_ITEM")
	this:RegisterEvent("DISTRIBUTE_ITEM")
    this:RegisterEvent("ROLL_ITEM")
    this:RegisterEvent("CANCEL_ROLL_ITEM")
    this:RegisterEvent("OPEN_DOODAD")

    this:RegisterEvent("MONEY_UPDATE")
	this:RegisterEvent("SELF_ST_CHANGE")

    this:RegisterEvent("START_ESCORT_QUEST")


    this:RegisterEvent("PLAY_MINI_GAME")

    ---------好友相关-----------------------------------------
    this:RegisterEvent("PLAYER_FELLOWSHIP_LOGIN")
    this:RegisterEvent("PLAYER_FELLOWSHIP_CHANGE")
    this:RegisterEvent("PLAYER_ADD_FELLOWSHIP_ATTRACTION")
    this:RegisterEvent("PLAYER_BE_ADD_FELLOWSHIP")
    this:RegisterEvent("PLAYER_APPLY_BE_ADD_FOE")
    this:RegisterEvent("PLAYER_HAS_BE_ADD_FOE")
    this:RegisterEvent("PLAYER_ADD_FOE_BEGIN")
    this:RegisterEvent("PLAYER_ADD_FOE_END")
    this:RegisterEvent("PREPARE_ADD_FOE_RESULT")

    this:RegisterEvent("REPUTATION_LEVEL_UP")

    this:RegisterEvent("SKILL_UPDATE")

    this:RegisterEvent("LEARN_PROFESSION")
    this:RegisterEvent("FORGET_PROFESSION")
    this:RegisterEvent("LEARN_RECIPE")
    this:RegisterEvent("PROFESSION_LEVEL_UP")
    this:RegisterEvent("PROFESSION_MAX_LEVEL_UP")

	this:RegisterEvent("PLAYER_LEVEL_UP")

    this:RegisterEvent("OT_ACTION_PROGRESS_BREAK")

	this:RegisterEvent("ON_SWITCH_MAP")
	this:RegisterEvent("ON_OPEN_VENATION_RETCODE")

	this:RegisterEvent("ON_CAST_COMMON_SKILL")
	this:RegisterEvent("SHARE_QUEST")

	this:RegisterEvent("UPDATE_SELECT_TARGET")
	this:RegisterEvent("ON_SET_USE_BIGBAGPANEL")

	this:RegisterEvent("QUEST_ACCEPTED")
	this:RegisterEvent("QUEST_FAILED")
	this:RegisterEvent("QUEST_CANCELED")
	this:RegisterEvent("QUEST_FINISHED")
	this:RegisterEvent("QUEST_DATA_UPDATE")
	this:RegisterEvent("QUEST_MARK_UPDATE")

	this:RegisterEvent("INVITE_JOIN_TONG_REQUEST")

	this:RegisterEvent("TONG_STATE_CHANGE") 		--帮会状态改变
	this:RegisterEvent("TONG_GROUP_RIGHT_CHANGE") 	-- 用户组权限发生变化
	this:RegisterEvent("TONG_GROUP_NAME_CHANGE")	-- 用户组名称被修改
	this:RegisterEvent("TONG_GROUP_WAGE_CHANGE")	-- 用户组工资额度被调整
	this:RegisterEvent("TONG_MEMBER_JOIN")			-- 有成员加入
	this:RegisterEvent("TONG_MEMBER_QUIT")			-- 有人退出帮会（主动退出或被踢）
	this:RegisterEvent("TONG_MEMBER_CHANGE_GROUP")	-- 成员被移动到别的用户组
	this:RegisterEvent("TONG_MASTER_CHANGE")		-- 帮主移交成功
    this:RegisterEvent("TONG_MASTER_CHANGE_START")  -- 帮主移交申请成功，开始倒计时
    this:RegisterEvent("TONG_MASTER_CHANGE_CANCEL") -- 取消帮主移交申请
	this:RegisterEvent("TONG_CAMP_CHANGE")
	this:RegisterEvent("CHANGE_TONG_NOTIFY")
	this:RegisterEvent("TONG_MEMBER_FIRED")
	this:RegisterEvent("TONG_MEMBER_LOGIN")
	this:RegisterEvent("TONG_MEMBER_LEAVE")
	this:RegisterEvent("TONG_GROUP_ENABLED")
	this:RegisterEvent("TONG_MAX_MEMBER_COUNT_CHANGE")

	this:RegisterEvent("CALL_LUA_ERROR")

	this:RegisterEvent("NEW_ACHIEVEMENT")
	this:RegisterEvent("ACHIEVEMENT_ANNOUNCE")
	this:RegisterEvent("SYNC_ACHIEVEMENT_DATA")

	this:RegisterEvent("ACQUIRE_DESIGNATION")
	this:RegisterEvent("DESIGNATION_ANNOUNCE")
	this:RegisterEvent("SET_GENERATION_NOTIFY")
	this:RegisterEvent("REMOVE_DESIGNATION")

	this:RegisterEvent("UI_TRAIN_VALUE_UPDATE")

	this:RegisterEvent("CHARGE_LIMIT_NOTIFT")

	this:RegisterEvent("UPDATE_ACHIEVEMENT_POINT")

	this:RegisterEvent("REPUTATION_LEVEL_UPDATE")

	this:RegisterEvent("ACCOUNT_END_TIME")

	this:RegisterEvent("LOADING_END")
	this:RegisterEvent("SYSTEM_PUNISH_NOTIFY")
	this:RegisterEvent("REMOTE_PLAYER_LIMIT_NOTIFY")
	this:RegisterEvent("UPDATE_KILL_POINT")
	
	this:RegisterEvent("KILL_PLAYER_HIGHEST_TITLE")
	this:RegisterEvent("ON_ADD_DEVELOPMENT_POINT_NOTIFY")
	
	this:RegisterEvent("PLAY_BG_MUSIC")
end;

OnEvent=function(event)
	if event == "SYS_MSG" then
		GlobalEventHandler.OnSysMsgEvent(event)
	elseif event == "ON_CAST_COMMON_SKILL" then
		g_bCastCommonSkill = arg0
	elseif event == "NPC_TALK" then
		GlobalEventHandler.OnNpcTalk(event)

	elseif event == "SHOP_OPENSHOP" then
		GlobalEventHandler.OnShopOpenShopEvent(event)

	elseif event == "PEEK_OTHER_PLAYER" then
		if arg0 == PEEK_OTHER_PLAYER_RESPOND.SUCCESS then
			OpenPlayerView(arg1)
		end

	-----------队伍相关托管-----------------------------------------------------------------
	elseif event == "PARTY_MESSAGE_NOTIFY" then
		GlobalEventHandler.OnPartyEvent(event)
	elseif event == "PARTY_DISBAND" then
		GlobalEventHandler.OnPartyEvent(event)
		GlobalEventHandler.UpdatePartyMark()
	elseif event == "PARTY_UPDATE_BASE_INFO" then
		GlobalEventHandler.OnPartyEvent(event)
	elseif event == "PARTY_LOOT_MODE_CHANGED" then
		GlobalEventHandler.OnPartyEvent(event)
	elseif event == "PARTY_ROLL_QUALITY_CHANGED" then
		GlobalEventHandler.OnPartyEvent(event)
	elseif event == "TEAM_AUTHORITY_CHANGED" then
		GlobalEventHandler.OnPartyEvent(event)
	elseif event == "PARTY_SET_FORMATION_LEADER" then
		GlobalEventHandler.OnPartyEvent(event)
	elseif event == "PARTY_SET_MARK" then
		GlobalEventHandler.UpdatePartyMark()
	elseif event == "PARTY_DELETE_MEMBER"
	or event == "PARTY_UPDATE_MEMBER_INFO" then
		if arg1 == GetClientPlayer().dwID then -- myself
			GlobalEventHandler.UpdatePartyMark()
		end

	----------交易托管-------------------------------------
	elseif event == "TRADING_INVITE" then
		GlobalEventHandler.OnTradingEvent(event)
	elseif event == "TRADING_OPEN_NOTIFY" then
		GlobalEventHandler.OnTradingEvent(event)

	elseif event == "PLAYER_TALK" then
		GlobalEventHandler.OnPlayerTalk(event)
	elseif event == "ANNOUNCE_TALK" then
		GlobalEventHandler.OnAnnounceTalk(event)
	elseif event == "GET_PLAYER_MESSAGE_MAIL" then
		GlobalEventHandler.OnPlayerMessage(event)
	elseif event == "PLAYER_DEATH" then
		Camera_EnableControl(CONTROL_AUTO_RUN, false)
	elseif event == "NPC_TALK_USE_SENTENCE_ID" then
		GlobalEventHandler.OnPlayerTalk(event)
	---------生活技能相关托管------------------------------

	elseif event == "OPEN_BOOK" then --预留开启读书面板
		GlobalEventHandler.OnOpenReadBook(event)
	elseif event == "PEEK_PLAYER_BOOK_STATE" then
		GlobalEventHandler.OnOpenReadComparePanel(event)
	elseif event == "FE_BREAK_EQUIP" then
		GlobalEventHandler.OnBreakEquip(event)

	---------PK相关----------------------------------------
	elseif event == "APPLY_DUEL" then
		GlobalEventHandler.OnApplyDuel(event)
	elseif event == "LEAVE_DUEL" then
		----PK离开战斗中心倒计时开始,设定为10秒
		local dwPunishFrame = 10
		CreatePKLeavePanel(dwPunishFrame)
	elseif event == "OPEN_BANK" then
		OpenBankPanel(TARGET.NPC, arg0)

	--------拾取相关-------------------------------------
	elseif event == "BEGIN_ROLL_ITEM" then
		GlobalEventHandler.OnLootEvent(event)
	elseif event == "LOOT_ITEM" then
		GlobalEventHandler.OnLootEvent(event)
    elseif event == "DISTRIBUTE_ITEM" then
		GlobalEventHandler.OnLootEvent(event)
	elseif event == "ROLL_ITEM" then
		GlobalEventHandler.OnLootEvent(event)
	elseif event == "CANCEL_ROLL_ITEM" then
		GlobalEventHandler.OnLootEvent(event)
	elseif event == "OPEN_DOODAD" then
		GlobalEventHandler.OnLootEvent(event)

	elseif event == "MONEY_UPDATE" then
		GlobalEventHandler.OnMoneyUpdate(event)
	elseif event == "SELF_ST_CHANGE" then
		GlobalEventHandler.OnSelfSTChange(event)

	elseif event == "START_ESCORT_QUEST" then
		GlobalEventHandler.OnStartEscortQuest(event)
	elseif event == "PLAY_MINI_GAME" then
		GlobalEventHandler.OnPlayMiniGame(arg0)
	elseif event == "PLAYER_FELLOWSHIP_LOGIN" then
		GlobalEventHandler.OnFriendLogin(arg0, arg1, arg2)
	elseif event == "PLAYER_FELLOWSHIP_CHANGE" then
		GlobalEventHandler.OnFriendRespond(arg0, arg1, arg2, arg3, arg4)
	elseif event == "PLAYER_ADD_FELLOWSHIP_ATTRACTION" then
	    GlobalEventHandler.OnAddFellowShipAttaction(arg0, arg1);
	elseif event == "PLAYER_FELLOWSHIP_ATTRACTION_FALL_OFF" then
	    GlobalEventHandler.OnFellowShipAttactionFallOff();
	elseif event == "PLAYER_BE_ADD_FELLOWSHIP" then
	    GlobalEventHandler.OnBeAddFellowShip(arg0, arg1, arg2);
	elseif event == "PLAYER_APPLY_BE_ADD_FOE" then
		GlobalEventHandler.OnApplyBeAddFoe(arg0, arg1)
	elseif event == "PLAYER_HAS_BE_ADD_FOE" then
		GlobalEventHandler.OnHasBeAddFoe(arg0)		
	elseif event == "PLAYER_ADD_FOE_BEGIN" then
		GlobalEventHandler.OnAddFoeBegin(arg0, arg1)
	elseif event == "PLAYER_ADD_FOE_END" then
		GlobalEventHandler.OnAddFoeEnd(arg0)
    elseif event == "PREPARE_ADD_FOE_RESULT" then
        GlobalEventHandler.OnPrepareAddFoe(arg0)
	elseif event == "REPUTATION_LEVEL_UP" then
		GlobalEventHandler.OnReputeUpdate(arg0)
	elseif event == "SKILL_UPDATE" then
		GlobalEventHandler.OnSkillUpdate(arg0, arg1)
	elseif event == "LEARN_PROFESSION" then
		ShowFullScreenSFX("LearnProfession")
	elseif event == "FORGET_PROFESSION" then
		ShowFullScreenSFX("ForgetProfession")
	elseif event == "LEARN_RECIPE" then
		ShowFullScreenSFX("LearnRecipe")
	elseif event == "PROFESSION_LEVEL_UP" then
		ShowFullScreenSFX("ProfessionLevelUp")
	elseif event == "PROFESSION_MAX_LEVEL_UP" then
		ShowFullScreenSFX("ProfessionMaxLevelUp")
	elseif event == "PLAYER_LEVEL_UP" then
		GlobalEventHandler.OnPlayerLevelUp()
	elseif event == "OT_ACTION_PROGRESS_BREAK" then
		if arg0 == GetClientPlayer().dwID then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_OT_ACTION_PROGRESS_BREAK);
		end
	elseif event == "ON_SWITCH_MAP" then
	    GlobalEventHandler.OnSwitchMap(arg0)
	elseif event == "ON_OPEN_VENATION_RETCODE" then
		local player = GetClientPlayer()
		local dwID = arg1
		if not arg0 then
		 	local dwLevel = player.GetSkillLevel(dwID) + 1
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.MSG_VENATION_GET_FAIL1)
		else
			local dwLevel = player.GetSkillLevel(dwID)
			if dwLevel == 0 then
				dwLevel = 1
			end
			OutputMessage("MSG_ANNOUNCE_YELLOW", g_tStrings.MSG_VENATION_GET_SUCCEED1)
			if VenationCost[dwID] and VenationCost[dwID][dwLevel] then
				OutputMessage("MSG_SYS", FormatString(g_tStrings.MSG_VENATION_GET_SUCCEED2, Table_GetSkillName(dwID, dwLevel), GetActualCostTrain(player, VenationCost[dwID][dwLevel])))
			else
				OutputMessage("MSG_SYS", FormatString(g_tStrings.MSG_VENATION_GET_SUCCEED3, Table_GetSkillName(dwID, dwLevel)))
			end
		end
	elseif event == "SHARE_QUEST" then
	    GlobalEventHandler.OnShareQuest(arg0, arg1, arg2)
	elseif event == "UPDATE_SELECT_TARGET" then
		local dwLastType, dwLastID = GlobalEventHandler.dwLastTargetType, GlobalEventHandler.dwLastTargetID
		local player = GetClientPlayer()
		local dwTargetType, dwTargetID = player.GetTarget();
		
		if not dwLastType or not dwLastID then
			dwLastType, dwLastID = TARGET.NO_TARGET, 0
		elseif dwTargetType ~= dwLastType or dwTargetID ~= dwLastID then
			TargetSelection_DetachSceneObject(dwLastID, dwLastType)

			SceneObject_SetBrightness(dwLastType, dwLastID, 0)
		end
		if dwTargetType == TARGET.PLAYER or dwTargetType == TARGET.NPC then
			local nForceRelationType = 0
			if IsPlayer(dwTargetID) then
	   		        nForceRelationType = GetRelation(player.dwID, dwTargetID)
			else
				nForceRelationType = GetRelation(dwTargetID, player.dwID)
			end

			TargetSelection_AttachSceneObject(dwTargetID, dwTargetType)
			TargetSelection_ShowSFX(nForceRelationType)

			SceneObject_SetBrightness(dwLastType, dwLastID, 0)
			SceneObject_SetBrightness(dwTargetType, dwTargetID, 1)
		else
			TargetSelection_HideSFX()
		end
		
		GlobalEventHandler.dwLastTargetType, GlobalEventHandler.dwLastTargetID = dwTargetType, dwTargetID
		OpenTargetPanel(dwTargetType, dwTargetID)
	elseif event == "ON_SET_USE_BIGBAGPANEL" then
		if not IsUseBigBagPanel() then
			OpenBagList()
		end
	elseif event == "QUEST_ACCEPTED" then
		local tQuestStringInfo = Table_GetQuestStringInfo(arg1)
		local szFont = GetMsgFontString("MSG_SYS")
		local szMsg = "<text>text="..EncodeComponentsString(g_tStrings.MSG_ACCEPT_QUEST)..szFont.."</text>"
			..MakeQuestLink("["..tQuestStringInfo.szName.."]", szFont, arg1)
			.."<text>text="..EncodeComponentsString(g_tStrings.STR_FULL_STOP.."\n")..szFont.."</text>"
		OutputMessage("MSG_SYS", szMsg, true)
		local szText = FormatString(g_tStrings.QUEST_SHARE_ACCEPT, GetClientPlayer().szName)
		ShareQuestTrace(szText, arg1)
	elseif event == "QUEST_FAILED" then
		local player = GetClientPlayer()
    	local dwQuestID = player.GetQuestID(arg0)
    	local tQuestStringInfo = Table_GetQuestStringInfo(dwQuestID)
		local szFont = GetMsgFontString("MSG_SYS")
		local szMsg = "<text>text="..EncodeComponentsString(g_tStrings.MSG_QUEST_YOU)..szFont.."</text>"
			..MakeQuestLink("["..tQuestStringInfo.szName.."]", szFont, dwQuestID)
			.."<text>text="..EncodeComponentsString(g_tStrings.MSG_QUEST_FAIL)..szFont.."</text>"
		OutputMessage("MSG_SYS", szMsg, true)
        OutputMessage("MSG_ANNOUNCE_RED", FormatString(g_tStrings.MSG_QUEST_FAILED, tQuestStringInfo.szName))
		local nSysFont = GetMsgFont("MSG_SYS")
		local r, g, b = GetMsgFontColor("MSG_SYS")
		local szText = FormatString(g_tStrings.QUEST_SHARE_FAILED, GetClientPlayer().szName)
		local szEnd = g_tStrings.QUEST_SHARE_FAILED1
		ShareQuestTrace(szText, dwQuestID, szEnd)
	elseif event == "QUEST_CANCELED" then
		local tQuestStringInfo = Table_GetQuestStringInfo(arg0)
		local szFont = GetMsgFontString("MSG_SYS")
		local szMsg = "<text>text="..EncodeComponentsString(g_tStrings.MSG_QUEST_ABANDON)..szFont.."</text>"
			..MakeQuestLink("["..tQuestStringInfo.szName.."]", szFont, arg0)
			.."<text>text="..EncodeComponentsString(g_tStrings.STR_FULL_STOP.."\n")..szFont.."</text>"
		OutputMessage("MSG_SYS", szMsg, true)
		local szText = FormatString(g_tStrings.QUEST_SHARE_CANCEL, GetClientPlayer().szName)
		ShareQuestTrace(szText, arg0)
	elseif event == "QUEST_FINISHED" then
		if arg1 == 0 then
			local tQuestStringInfo = Table_GetQuestStringInfo(arg0)
			local szFont = GetMsgFontString("MSG_SYS")
			if arg2 then
				ShowFullScreenSFX("FinishAssistQuest")

				if arg3 > 0 then
					OutputMessage("MSG_SYS", FormatString(g_tStrings.ADD_STAMINA, arg3))
				else
					OutputMessage("MSG_SYS", g_tStrings.ADD_STAMINA_FULL)
				end

				if arg4 > 0 then
					OutputMessage("MSG_SYS", FormatString(g_tStrings.ADD_THEW, arg4))
				else
					OutputMessage("MSG_SYS", g_tStrings.ADD_THEW_FULL)
				end

				local szMsg = "<text>text="..EncodeComponentsString(g_tStrings.FINISH_ASSIST_QUEST)..szFont.."</text>"
					..MakeQuestLink("["..tQuestStringInfo.szName.."]", szFont, arg0)
					.."<text>text="..EncodeComponentsString(g_tStrings.STR_FULL_STOP.."\n")..szFont.."</text>"
				OutputMessage("MSG_SYS", szMsg, true)

			else
				ShowFullScreenSFX("FinishQuest")
				local szMsg = "<text>text="..EncodeComponentsString(g_tStrings.MSG_QUEST_FINISH)..szFont.."</text>"
					..MakeQuestLink("["..tQuestStringInfo.szName.."]", szFont, arg0)
					.."<text>text="..EncodeComponentsString(g_tStrings.STR_FULL_STOP.."\n")..szFont.."</text>"
				OutputMessage("MSG_SYS", szMsg, true)
				local szText = FormatString(g_tStrings.QUEST_SHARE_FINISH, GetClientPlayer().szName)
				ShareQuestTrace(szText, arg0)
			end
		end
	elseif event == "QUEST_DATA_UPDATE" then
		if arg0 >= 0 then
			GlobalEventHandler.OnQuestDataUpdate(arg0, arg1, arg2, arg3)
		end
	elseif event == "QUEST_MARK_UPDATE" then
		UpdateNpcTitleEffect(arg0)
	elseif event == "NPC_DISPLAY_DATA_UPDATE" then
		UpdateNpcTitleEffect(arg0)
	elseif event == "PLAYER_DISPLAY_DATA_UPDATE" then
		UpdatePlayerTitleEffect(arg0)
	elseif event == "NPC_ENTER_SCENE" then
		OnNpcEnterScene(arg0)
	elseif event == "NPC_LEAVE_SCENE" then
		OnNpcLeaveScene(arg0)
	elseif event == "INVITE_JOIN_TONG_REQUEST" then
		GlobalEventHandler.OnInviteJoinTong(arg0, arg1, arg2, arg3)
	elseif event == "AUCTION_MESSAGE_NOTIFY" then
		GlobalEventHandler.OnAuctionNotify(arg0, arg1, arg2)
	elseif event == "TONG_STATE_CHANGE" then
		GlobalEventHandler.OnTongStateChange(arg0)
	elseif event == "TONG_GROUP_RIGHT_CHANGE" then
		GlobalEventHandler.OnTongGroupRightChange(arg0)
	elseif event == "TONG_GROUP_NAME_CHANGE" then
		GlobalEventHandler.OnTongGroupNameChange(arg0, arg1)
	elseif event == "TONG_GROUP_WAGE_CHANGE" then
		GlobalEventHandler.OnTongGroupWageChange(arg0, arg1)
	elseif event == "TONG_MEMBER_JOIN" then
		GlobalEventHandler.OnTongMemberJoin(arg0)
	elseif event == "TONG_MEMBER_QUIT" then
		GlobalEventHandler.OnTongMemberQuit(arg0)
	elseif event == "TONG_MEMBER_CHANGE_GROUP" then
		GlobalEventHandler.OnTongMemberChangeGroup(arg0, arg1, arg2)
	elseif event == "TONG_MASTER_CHANGE" or 
    event == "TONG_MASTER_CHANGE_START" or 
    event == "TONG_MASTER_CHANGE_CANCEL" then
		GlobalEventHandler.OnTongMasterChange(event, arg0, arg1)
	elseif event == "TONG_CAMP_CHANGE" then
		GlobalEventHandler.OnTongCampChanged(arg0)
	elseif event == "CHANGE_TONG_NOTIFY" then
		GlobalEventHandler.OnChangeTong(arg0, arg1)
	elseif event == "TONG_MEMBER_FIRED" then
		GlobalEventHandler.OnTongMemberFired(arg0)
	elseif event == "CONTRIBUTION_UPDATE" then
	elseif event == "TONG_MEMBER_LOGIN" then
		GlobalEventHandler.OnTongMemberLogin(arg0)
	elseif event == "TONG_MEMBER_LEAVE" then
		GlobalEventHandler.OnTongMemberLogout(arg0)
	elseif event == "TONG_GROUP_ENABLED" then
		GlobalEventHandler.OnTongGroupEnable(arg0)
	elseif event == "NEW_ACHIEVEMENT" then
		GlobalEventHandler.OnNewAchievement(arg0)
	elseif event == "ACHIEVEMENT_ANNOUNCE" then
		GlobalEventHandler.OnAchievementAnnounce(arg0, arg1, arg2)
	elseif event == "SYNC_ACHIEVEMENT_DATA" then
		if arg0 ~= GetClientPlayer().dwID then
			CompareAchievement(arg0)
		end
	elseif event == "TONG_MAX_MEMBER_COUNT_CHANGE" then
		GlobalEventHandler.OnTongMaxNumChanged(arg0)
	elseif event == "CALL_LUA_ERROR" then
		GlobalEventHandler.OnLuaCallError()
	elseif event == "ACQUIRE_DESIGNATION" then
		GlobalEventHandler.OnAcuireDesignation(arg0, arg1)
	elseif event == "DESIGNATION_ANNOUNCE" then
		GlobalEventHandler.OnDesignationAnnounce(arg0, arg1, arg2, arg3)
	elseif event == "SET_GENERATION_NOTIFY" then
		GlobalEventHandler.OnSetDesignationGeneration(arg0, arg1, arg2)
	elseif event == "REMOVE_DESIGNATION" then
		GlobalEventHandler.OnRemoveDesignation(arg0, arg1)
	elseif event == "UI_TRAIN_VALUE_UPDATE" then
		if arg0 > 0 then
			OutputMessage("MSG_TRAIN", FormatString(g_tStrings.STR_GET_TRAIN_VALUE, arg0))
		end
	elseif event == "CHARGE_LIMIT_NOTIFT" then
		GlobalEventHandler.OnChargeLimitNotify(arg0)
	elseif event == "UPDATE_ACHIEVEMENT_POINT" then
		if arg0 > 0 then
			OutputMessage("MSG_ACHIEVEMENT", FormatString(g_tStrings.STR_GET_ACHIEVEMENT_POINT, arg0))
		elseif arg0 < 0 then
			OutputMessage("MSG_ACHIEVEMENT", FormatString(g_tStrings.STR_LOSS_ACHIEVEMENT_POINT, -arg0))
		end
	elseif event == "REPUTATION_LEVEL_UPDATE" then
		GlobalEventHandler.OnReputationRespond(arg0, arg1)
	elseif event == "ACCOUNT_END_TIME" then
		GlobalEventHandler.ShowNoTimeMessage()
	elseif event == "LOADING_END" then
		GlobalEventHandler.LoadingEnd()
	elseif event == "SYSTEM_PUNISH_NOTIFY" then
		if arg0 == SYSTEM_PUNISH_RESULT_CODE.CHEAT_PUNISH then
			OutputMessage("MSG_SYS", g_tStrings.CHEAT_WARNING_SELF)
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.CHEAT_WARNING_SELF)
		elseif arg0 == SYSTEM_PUNISH_RESULT_CODE.TARGET_CHEAT then
			OutputMessage("MSG_SYS", g_tStrings.CHEAT_WARNING_OTHER)
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.CHEAT_WARNING_OTHER)
		end
	elseif event == "REMOTE_PLAYER_LIMIT_NOTIFY" then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_REMOTE_PLAYER_LIMIT_NOTIFY[arg0])
	elseif event == "UPDATE_KILL_POINT" then
		if arg2 > arg1 then
			OutputMessage("MSG_SYS", FormatString(g_tStrings.ADD_KILLPOINT, arg2 - arg1))
		elseif arg1 > arg2 then
			OutputMessage("MSG_SYS", FormatString(g_tStrings.REDUCE_KILLPOINT, arg1 - arg2))
		end
	elseif event == "KILL_PLAYER_HIGHEST_TITLE" then
		local hPlayer = GetClientPlayer()
		local hTarget = GetPlayer(arg0)
		if hPlayer and hTarget then
			local szTitleName = g_tStrings.STR_CAMP_HIGHEST[hTarget.nCamp]
			local szTip = g_tStrings.STR_KILL.." "..szTitleName.." "..hTarget.szName
			OnBowledCharacterHeadLog(hPlayer.dwID, szTip, 199)
		end
	elseif event == "PLAY_BG_MUSIC" then
		local szMusic = MiddleMap.GetMapAreaBgMusic(arg0, arg1)
		if szMusic and szMusic ~= "" then
			PlayBgMusic(szMusic)
		else
			StopBgMusic()
		end
	elseif event == "ON_ADD_DEVELOPMENT_POINT_NOTIFY" then
		local nPoint = arg0
		if nPoint > 0 then
			OutputMessage("MSG_DEVELOPMENT_POINT", FormatString(g_tStrings.STR_QUEST_CAN_GET_DEVELOPMENT_POINT .. "\n", nPoint))
		else
			OutputMessage("MSG_DEVELOPMENT_POINT", FormatString(g_tStrings.GUILD_MAX_DEVELOPMENT_POINT .. "\n", nPoint))
		end
	end
end;

OnChargeLimitNotify = function(nCode)
	if nCode == CHARGE_LIMIT_CODE.LOGIN_MESSAGE then
		local szMsg = g_tStrings.tChargeLimit[nCode]
		if szMsg and szMsg ~= "" then
			OutputMessage("MSG_SYS", szMsg)
		end
	else
		OpenPayRemind(nCode, true)
	end
end;

OnSetDesignationGeneration = function(dwID, nGeneration, nCharacter)
	local player = GetClientPlayer()
	if dwID == player.dwID then
		local nPrefix = player.GetCurrentDesignationPrefix()
		local nPostfix = player.GetCurrentDesignationPostfix()
		local nGeneration = player.GetDesignationGeneration()
		local nCharacter = player.GetDesignationByname()
		local bShow = player.GetDesignationBynameDisplayFlag()
		local nForceID = player.dwForceID
		local aGen = g_tTable.Designation_Generation:Search(nForceID, nGeneration)
		local szDesignation = ""
		if aGen then
			szDesignation = szDesignation..aGen.szName
			if aGen.szCharacter and aGen.szCharacter ~= "" then
				local aCharacter = g_tTable[aGen.szCharacter]:Search(nCharacter)
				if aCharacter then
					szDesignation = szDesignation..aCharacter.szName
				end
			end
		end
		OutputMessage("MSG_DESGNATION", FormatString(g_tStrings.STR_GET_GENERATION, szDesignation))
	else
		local player = GetPlayer(dwID)
		if player then
			local aGen = g_tTable.Designation_Generation:Search(player.dwForceID, nGeneration)
			local szDesignation = ""
			if aGen then
				szDesignation = szDesignation..aGen.szName
				if aGen.szCharacter and aGen.szCharacter ~= "" then
					local aCharacter = g_tTable[aGen.szCharacter]:Search(nCharacter)
					if aCharacter then
						szDesignation = szDesignation..aCharacter.szName
					end
				end
			end

			local szFont = GetMsgFontString("MSG_DESGNATION")
			local szNameLink = MakeNameLink("["..player.szName.."]", szFont)
			OutputMessage("MSG_DESGNATION", FormatLinkString(g_tStrings.STR_OTHER_GET_GENERATION, szFont, szNameLink, szDesignation), true)
		end
	end
end;

OnDesignationAnnounce = function(szName, nPrifix, nPostfix, nChannel)
	local szChannel = "MSG_DESGNATION"
	local szFont = GetMsgFontString(szChannel)
	local szNameLink
	if GetClientPlayer().szName == szName then
		szNameLink = GetFormatText(g_tStrings.STR_YOU, "1 "..szFont)
	else
		szNameLink = MakeNameLink("["..szName.."]", szFont)
	end

	local player = GetClientPlayer()
	if nPrifix ~= 0 then
		local aDesignation = g_tTable.Designation_Prefix:Search(nPrifix)
		if aDesignation then
			local aInfo = GetDesignationPrefixInfo(nPrifix)
			local bWorld = aInfo.nType == DESIGNATION_PREFIX_TYPE.WORLD_DESIGNATION 
			local bCampTitle = aInfo.nType == DESIGNATION_PREFIX_TYPE.MILITARY_RANK_DESIGNATION
			if bWorld then
				OutputMessage(szChannel, FormatLinkString(g_tStrings.STR_GET_DESGNATION_WORLD, szFont, szNameLink,
					MakeDesignationLink("["..aDesignation.szName.."]", szFont, nPrifix, true)), true);
			elseif bCampTitle then
				OutputMessage(szChannel, FormatLinkString(g_tStrings.STR_GET_DESGNATION_TITLE, szFont, szNameLink,
					MakeDesignationLink("["..aDesignation.szName.."]", szFont, nPrifix, true)), true);
			else
				OutputMessage(szChannel, FormatLinkString(g_tStrings.STR_GET_DESGNATION_PREFIX, szFont, szNameLink,
					MakeDesignationLink("["..aDesignation.szName.."]", szFont, nPrifix, true)), true);
			end
		end
	end

	if nPostfix ~= 0 then
		local aDesignation = g_tTable.Designation_Postfix:Search(nPostfix)
		if aDesignation then
			OutputMessage(szChannel, FormatLinkString(g_tStrings.STR_GET_DESGNATION_POSTFIX, szFont, szNameLink,
				MakeDesignationLink("["..aDesignation.szName.."]", szFont, nPostfix, false)), true);
		end
	end
end;

OnAcuireDesignation = function(nPrifix, nPostfix)
	if nPrifix ~= 0 then
		CreateNewDesignationPanel(nPrifix, true)
	end

	if nPostfix ~= 0 then
		CreateNewDesignationPanel(nPostfix, false)
	end
end;

OnRemoveDesignation = function(nPrifix, nPostfix)
	local szChannel = "MSG_DESGNATION"
	local szFont = GetMsgFontString(szChannel)
	local szNameLink = GetFormatText(g_tStrings.STR_YOU, "1 "..szFont)

	local player = GetClientPlayer()
	if nPrifix ~= 0 then
		local aDesignation = g_tTable.Designation_Prefix:Search(nPrifix)
		if aDesignation then
			local aInfo = GetDesignationPrefixInfo(nPrifix)
			local bWorld = aInfo.nType == DESIGNATION_PREFIX_TYPE.WORLD_DESIGNATION 
			local bCampTitle = aInfo.nType == DESIGNATION_PREFIX_TYPE.MILITARY_RANK_DESIGNATION
			if bWorld then
				OutputMessage(szChannel, FormatLinkString(g_tStrings.STR_LOSE_DESGNATION_WORLD, szFont, szNameLink,
					MakeDesignationLink("["..aDesignation.szName.."]", szFont, nPrifix, true)), true);
			elseif bCampTitle then
				OutputMessage(szChannel, FormatLinkString(g_tStrings.STR_LOSE_DESGNATION_TITLE, szFont, szNameLink,
					MakeDesignationLink("["..aDesignation.szName.."]", szFont, nPrifix, true)), true);
			else
				OutputMessage(szChannel, FormatLinkString(g_tStrings.STR_LOSE_DESGNATION_PREFIX, szFont, szNameLink,
					MakeDesignationLink("["..aDesignation.szName.."]", szFont, nPrifix, true)), true);
			end
		end
	end

	if nPostfix ~= 0 then
		local aDesignation = g_tTable.Designation_Postfix:Search(nPostfix)
		if aDesignation then
			OutputMessage(szChannel, FormatLinkString(g_tStrings.STR_LOSE_DESGNATION_POSTFIX, szFont, szNameLink,
				MakeDesignationLink("["..aDesignation.szName.."]", szFont, nPostfix, false)), true);
		end
	end
end;

OnPlayerLevelUp = function()
	PlaySound(SOUND.UI_SOUND,g_sound.LevelUp)
end;

OnAchievementAnnounce = function(szName, nChannel, dwAchievement)
	local aAchievement = g_tTable.Achievement:Search(dwAchievement)
	if aAchievement and aAchievement.nVisible ~= 0 then
		local szMsg = aAchievement.szMsg
		if not szMsg or szMsg == "" then
			szMsg = g_tStrings.STR_ACHIEVEMENT_AQUARE
		else
			szMsg = szMsg.."\n"
		end

		local szChannel = "MSG_ACHIEVEMENT"
		local szFont = GetMsgFontString(szChannel)
		local szNameLink
		if GetClientPlayer().szName == szName then
			szNameLink = GetFormatText(g_tStrings.STR_YOU, "1 "..szFont)
		else
			szNameLink = MakeNameLink("["..szName.."]", szFont)
		end
		OutputMessage(szChannel, FormatLinkString(szMsg, szFont, szNameLink,
			MakeAchievementLink("["..aAchievement.szName.."]", szFont, dwAchievement)), true);
	end
end;

OnNewAchievement = function(dwAchievement)
	CreateNewAchievementPanel(dwAchievement)
end;

OnTongGroupEnable = function(szName)
	OutputMessage("MSG_SYS", FormatString(g_tStrings.STR_GUILD_GROUP_ENABLE, szName))
end;

OnTongMaxNumChanged = function(nCount)
	OutputMessage("MSG_SYS", FormatString(g_tStrings.STR_GUILD_UPDATE_MAX_MEMBER_COUNT, nCount))
end;

OnTongMemberLogin = function(szName)
	local szFont = GetMsgFontString("MSG_GUILD")
	OutputMessage("MSG_GUILD", FormatLinkString(g_tStrings.STR_GUILD_MEMBER_LOGIN, szFont, MakeNameLink("["..szName.."]", szFont)), true);
end;

OnTongMemberLogout = function(szName)
	local szFont = GetMsgFontString("MSG_GUILD")
	OutputMessage("MSG_GUILD", FormatLinkString(g_tStrings.STR_GUILD_MEMBER_LOGOUT, szFont, MakeNameLink("["..szName.."]", szFont)), true);
end;

OnTongMemberFired  = function(szMemberName)
	local szFont = GetMsgFontString("MSG_SYS")
	OutputMessage("MSG_SYS", FormatLinkString(g_tStrings.STR_GUILD_OTHER_FIRED, szFont, MakeNameLink("["..szMemberName.."]", szFont)), true);
end;

OnChangeTong = function(szName, nReason)
	if nReason == TONG_CHANGE_REASON.JOIN then
		if not GetClientPlayer().IsAchievementAcquired(836) then
			RemoteCallToServer("OnClientAddAchievement", "TONG|JOIN")
		end
	elseif nReason == TONG_CHANGE_REASON.CREATE then
		if not GetClientPlayer().IsAchievementAcquired(837) then
			RemoteCallToServer("OnClientAddAchievement", "TONG|CREATE")
		end
	end

	local szMsg = g_tStrings.STR_TONG_CHANGE_REASON[nReason]
	if szMsg and szMsg ~= "" then
		OutputMessage("MSG_SYS", FormatString(szMsg, szName))
	end

	if nReason == TONG_CHANGE_REASON.CREATE then
		OutputMessage("MSG_SYS", g_tStrings.STR_GUILD_STATE_TRIAL)
	end
end;

OnTongCampChanged = function(nCamp)
	local szCamp = g_tStrings.STR_CAMP_TITLE[nCamp]
	if szCamp then
		OutputMessage("MSG_SYS", FormatString(g_tStrings.STR_GUILD_CAMP_CHANGED, szCamp))
	end
end;

OnLuaCallError = function()
	if _g_ShowLuaErrMsg then
		local szError = GetLastLuaError()
		OutputMessage("MSG_SYS", szError)
	end
end;

OnTongStateChange = function(nTongState)
--！！这里请自行改成枚举变量检查，对应枚举已经导出了
	local szMessage
	if nTongState == TONG_STATE.DISBAND then
		szMessage = g_tStrings.STR_GUILD_STATE_DISBAND
        OutputWarningMessage("MSG_WARNING_GREEN", szMessage)
	elseif nTongState == TONG_STATE.NORMAL then
		szMessage = g_tStrings.STR_GUILD_STATE_NORMAL
        OutputWarningMessage("MSG_REWARD_GREEN", szMessage)
	elseif nTongState == TONG_STATE.TRIAL then
		szMessage = g_tStrings.STR_GUILD_STATE_TRIAL
	end
	if szMessage then
		OutputMessage("MSG_SYS", szMessage);
	end
end;

OnTongGroupRightChange = function(szGroupName)
	OutputMessage("MSG_SYS", FormatString(g_tStrings.STR_GUILD_ACCESS_CHANGED, szGroupName));
end;

OnTongGroupNameChange = function(szOldGroupName, szNewGroupName)
	OutputMessage("MSG_SYS", FormatString(g_tStrings.STR_GUILD_NAME_CHANGED, szOldGroupName, szNewGroupName));
end;

OnTongGroupWageChange = function(szGroupName, nWage)
	OutputMessage("MSG_SYS", FormatString(g_tStrings.STR_GUILD_WAGE_CHANGED, szGroupName, nWage));
end;

OnTongMemberJoin = function(szMemberName)
	local szFont = GetMsgFontString("MSG_SYS")
	OutputMessage("MSG_SYS", FormatLinkString(g_tStrings.STR_GUILD_OTHER_JION, szFont, MakeNameLink("["..szMemberName.."]", szFont)), true);
end;

OnTongMemberQuit = function(szMemberName)
	local szFont = GetMsgFontString("MSG_SYS")
	OutputMessage("MSG_SYS", FormatLinkString(g_tStrings.STR_GUILD_OTHER_QUIT, szFont, MakeNameLink("["..szMemberName.."]", szFont)), true);
end;

OnTongMemberChangeGroup = function(szMemberName, szOldGroupName, szNewGroupName)
	local szFont = GetMsgFontString("MSG_SYS")
	OutputMessage("MSG_SYS", FormatLinkString(g_tStrings.STR_GUILD_CHANGE_GROUP, szFont, MakeNameLink("["..szMemberName.."]", szFont), szOldGroupName, szNewGroupName), true);
end;

OnTongMasterChange = function(szEvent, szOldMasterName, szNewMasterName)
    local hTongClient = GetTongClient()
	hTongClient.ApplyTongInfo()
    local szFont = GetMsgFontString("MSG_SYS")
    local szMsg = ""
    if szEvent == "TONG_MASTER_CHANGE_START" then
        szMsg = FormatLinkString(
            g_tStrings.STR_GUILD_CHANGE_MASTER_START, 
            szFont, 
            MakeNameLink("["..szOldMasterName.."]", szFont), 
            MakeNameLink("["..szNewMasterName.."]", szFont)
        )
    elseif szEvent == "TONG_MASTER_CHANGE_CANCEL" then
        szMsg = FormatLinkString(
            g_tStrings.STR_GUILD_CHANGE_MASTER_CANCEL, 
            szFont, 
            MakeNameLink("["..szOldMasterName.."]", szFont)
        )
    elseif szEvent == "TONG_MASTER_CHANGE" then
        szMsg = FormatLinkString(
            g_tStrings.STR_GUILD_CHANGE_MASTER, 
            szFont, 
            MakeNameLink("["..szOldMasterName.."]", szFont), 
            MakeNameLink("["..szNewMasterName.."]", szFont)
        )
    end
	
	OutputMessage("MSG_SYS", szMsg, true);
end;

OnAuctionNotify = function(nNotifyID, szSaleName, nPrice)
	local szMsg = g_tAuctionString.tAuctionNotify[nNotifyID]
	if not szMsg or szMsg == "" then
		return
	end
	local szFont = GetMsgFontString("MSG_ITEM")

	if nNotifyID == AUCTION_MESSAGE_CODE.BID_LOST or nNotifyID == AUCTION_MESSAGE_CODE.TIME_OVER then
		szMsg = FormatString(szMsg, szSaleName, szFont)
	else
		local szMoney = GetMoneyText(nPrice, szFont)
		szMsg = FormatString(szMsg, szMoney, szSaleName, szFont)
	end
	OutputMessage("MSG_SYS", szMsg, true);
end;

OnInviteJoinTong = function(dwInviterID, dwTongID, szInviterName, szTongName)
	if IsFilterOperate("INVITE_JOIN_TONG_REQUEST") then
		GetTongClient().RespondInviteJoinTong(dwInviterID, dwTongID, false)
		return
	end
	
	local dwStartTime = GetTickCount()
	local msg =
	{
		szMessage = FormatString(g_tStrings.STR_GUILD_INVITE, szInviterName, szTongName),
		szName = "OnInviteJoinTong",
		fnAutoClose = function() return GetTickCount() - dwStartTime > 2 * 60 * 1000 end,
		fnCancelAction = function() GetTongClient().RespondInviteJoinTong(dwInviterID, dwTongID, false) end,
		{szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = function() GetTongClient().RespondInviteJoinTong(dwInviterID, dwTongID, true) end},
		{szOption = g_tStrings.STR_HOTKEY_CANCEL, fnAction = function() GetTongClient().RespondInviteJoinTong(dwInviterID, dwTongID, false) end}
	}
	MessageBox(msg)
end;

OnQuestDataUpdate = function(nQuestIndex, eEventType, nValue1, nValue2)
	local player = GetClientPlayer()
	local dwQuestID = player.GetQuestID(nQuestIndex)
	local questTrace = player.GetQuestTraceInfo(dwQuestID)
	local tQuestStringInfo = Table_GetQuestStringInfo(dwQuestID)
	if eEventType == QUEST_EVENT_TYPE.KILL_NPC then
		for k, v in pairs(questTrace.kill_npc) do
			if v.i == nValue1 and v.have <= v.need then
				v.have = math.min(v.have, v.need)
				local szName = Table_GetNpcTemplateName(v.template_id)
				if not szName or szName == "" then
					szName = "Unknown Npc"
				end
				local szText = szName .."："..v.have.."/"..v.need
				if v.have == v.need then
					szText = szText..g_tStrings.STR_QUEST_QUEST_WAS_FINISHED
				end
				szText = szText.."\n"
				OutputMessage("MSG_ANNOUNCE_YELLOW", szText)
				ShareQuestTrace("["..GetClientPlayer().szName.."]"..szText, dwQuestID, "", true)
				break
			end
		end
	elseif eEventType == QUEST_EVENT_TYPE.GET_ITEM then
		for k, v in pairs(questTrace.need_item) do
			if v.type == nValue1 and v.index == nValue2 and v.have <= v.need then
				local itemInfo = GetItemInfo(v.type, v.index)
				local nBookID = v.need
				if itemInfo.nGenre == ITEM_GENRE.BOOK then
					v.need = 1
				end
				v.have = math.min(v.have, v.need)
				local szName = "Unknown Item"
				if itemInfo then
					szName = GetItemNameByItemInfo(itemInfo, nBookID)
				end
				local szText = szName.."："..v.have.."/"..v.need
				if v.have == v.need then
					szText = szText..g_tStrings.STR_QUEST_QUEST_WAS_FINISHED
				end
				szText = szText.."\n"
				OutputMessage("MSG_ANNOUNCE_YELLOW", szText)
				ShareQuestTrace("["..GetClientPlayer().szName.."]"..szText, dwQuestID, "", true)
				break
			end
		end
	elseif eEventType == QUEST_EVENT_TYPE.SET_QUEST_VALUE then
		for k, v in pairs(questTrace.quest_state) do
			if v.i == nValue1 and v.have <= v.need then
				local szName = tQuestStringInfo["szQuestValueStr" .. (v.i + 1)]
				v.have = math.min(v.have, v.need)
				local szText = szName.."："..v.have.."/"..v.need
				if v.have == v.need then
					szText = szText..g_tStrings.STR_QUEST_QUEST_WAS_FINISHED
				end
				szText = szText.."\n"
				OutputMessage("MSG_ANNOUNCE_YELLOW", szText)
				ShareQuestTrace("["..GetClientPlayer().szName.."]"..szText, dwQuestID, "", true)
				break
			end
		end
	end
end;

OnReputeUpdate = function(dwReputeID)
	local aRepu = g_tReputation.tReputationTable[dwReputeID]
	if not aRepu then
		return
	end

	local aLevel = g_tReputation.tReputationLevelTable[GetClientPlayer().GetReputeLevel(dwReputeID)]
	if not aLevel then
		return
	end
	OutputMessage("MSG_REPUTATION", FormatString(g_tStrings.STR_MSG_REPUTE_CHANGED, aRepu.szName, aLevel.szLevel));
	if arg1 then
		ShowFullScreenSFX("ReputationLevelUp")
	else
		ShowFullScreenSFX("ReputationLevelDown")
	end
end;

OnSkillUpdate = function(dwSkillID, dwSkillLevel)
	if not Table_IsSkillShow(dwSkillID, dwSkillLevel) then
		return
	end
	local szName = Table_GetSkillName(dwSkillID, dwSkillLevel)
	if dwSkillLevel > 1 then
		local szLevel = FormatString(g_tStrings.STR_SKILL_H_THE_WHAT_LEVEL1, NumberToChinese(dwSkillLevel))
		OutputMessage("MSG_SYS", FormatString(g_tStrings.STR_SET_PROFESSION_MAX_LEVEL, szName, szLevel));
		ShowFullScreenSFX("SkillLevelUp")
	elseif dwSkillLevel == 1 then
		OutputMessage("MSG_SYS", FormatString(g_tStrings.STR_LEARN_RECIPE, szName));
		ShowFullScreenSFX("SkillLevelUp")
		NewSkillBarOnNewSkill(dwSkillID, dwSkillLevel)
	else
		szName = Table_GetSkillName(dwSkillID, 1)
		OutputMessage("MSG_SYS", FormatString(g_tStrings.STR_FORGET_SKILL, szName));
	end
end;

OnSwitchMap = function(nErrorID)
	local strMsg = g_tStrings.tSwitchMap[nErrorID];
	if strMsg then
		OutputMessage("MSG_ANNOUNCE_RED", strMsg);
	end
end;

OnShareQuest = function(nResultCode, dwQuestID, dwDestPlayerID)
    local szMsg = g_tStrings.tShareQuestMsg[nResultCode]
    
	if not szMsg then
	    return
	end
	
    if nResultCode == SHARE_QUEST.TOO_FAR or 
       nResultCode == SHARE_QUEST.QUEST_LIST_FULL or
       nResultCode == SHARE_QUEST.ERROR_CAMP
    then
        local szMemberName = GetTeammateName(dwDestPlayerID)
        if not szMemberName then
            return
        end

        szMsg = FormatString(szMsg, szMemberName)
    elseif  nResultCode == SHARE_QUEST.SUCCESS or
            nResultCode == SHARE_QUEST.FAILED or
            nResultCode == SHARE_QUEST.ALREADY_ACCEPT_QUEST or
            nResultCode == SHARE_QUEST.ALREADY_FINISHED_QUEST or
            nResultCode == SHARE_QUEST.ACCEPT_QUEST
    then
        local szMemberName = GetTeammateName(dwDestPlayerID)
        if not szMemberName then
            return
        end

        local tQuestStringInfo = Table_GetQuestStringInfo(dwQuestID)
        if not tQuestStringInfo then
            return
        end

        szMsg = FormatString(szMsg, szMemberName, tQuestStringInfo.szName)
    end

	OutputMessage("MSG_SYS", szMsg)
end;

OnFriendLogin = function(bOnLine, szName, bFoe)
    if szName == "----" then
        return
    end

    if not bFoe then
    	if bOnLine then
    		local szFont = GetMsgFontString("MSG_SYS")
    		local szNameLink = MakeNameLink("["..szName.."]", szFont)
    		OutputMessage("MSG_SYS", FormatString(g_tStrings.STR_MSG_PARTYMEMBER_ONLINE, szNameLink, szFont), true);
    		PlaySound(SOUND.UI_SOUND, g_sound.Friend)
    	else
    		local szFont = GetMsgFontString("MSG_SYS")
    		local szNameLink = MakeNameLink("["..szName.."]", szFont)
    		OutputMessage("MSG_SYS", FormatString(g_tStrings.STR_MSG_PARTYMEMBER_OFFLINE, szNameLink, szFont), true);
    	end
    else
    	if bOnLine then
    		local szFont = GetMsgFontString("MSG_SYS")
    		local szNameLink = MakeNameLink("["..szName.."]", szFont)
    		OutputMessage("MSG_SYS", FormatString(g_tStrings.SRT_MSG_ENEMY_ONLINE, szNameLink, szFont), true);
    	else
    		local szFont = GetMsgFontString("MSG_SYS")
    		local szNameLink = MakeNameLink("["..szName.."]", szFont)
    		OutputMessage("MSG_SYS", FormatString(g_tStrings.SRT_MSG_ENEMY_OFFLINE, szNameLink, szFont), true);
    	end
    end
end;

GetFellowshipName = function(dwGroupID)
	if dwGroupID == 0 then
		return g_tStrings.STR_FRIEND_GOOF_FRIEND
	else
		return GetClientPlayer().GetFellowshipGroupName(dwGroupID)
	end
end;

OnFriendRespond = function(arg0, arg1, arg2, arg3, arg4)
	if arg0 == PLAYER_FELLOWSHIP_RESPOND.SUCCESS_ADD then
		local szFont = GetMsgFontString("MSG_SYS")
		local szNameLink = MakeNameLink("["..arg4.."]", szFont)
		local szMsg = szNameLink..
		                "<text>text="..
		                EncodeComponentsString(g_tStrings.tFellowshipString[PLAYER_FELLOWSHIP_RESPOND.SUCCESS_ADD])..
		                szFont..
		                "</text>"
		OutputMessage("MSG_SYS", szMsg, true);
	elseif arg0 == PLAYER_FELLOWSHIP_RESPOND.SUCCESS_ADD_FOE then
		local szFont = GetMsgFontString("MSG_SYS")
		local szNameLink = MakeNameLink("["..arg4.."]", szFont)
		local szMsg = szNameLink..
		                "<text>text="..
		                EncodeComponentsString(g_tStrings.tFellowshipString[PLAYER_FELLOWSHIP_RESPOND.SUCCESS_ADD_FOE])..
		                szFont..
		                "</text>"
		OutputMessage("MSG_SYS", szMsg, true);
	elseif arg0 == PLAYER_FELLOWSHIP_RESPOND.SUCCESS_ADD_BLACK_LIST then
		local szFont = GetMsgFontString("MSG_SYS")
		local szNameLink = MakeNameLink("["..arg4.."]", szFont)
		local szMsg = szNameLink..
		                "<text>text="..
		                EncodeComponentsString(g_tStrings.tFellowshipString[PLAYER_FELLOWSHIP_RESPOND.SUCCESS_ADD_BLACK_LIST])..
		                szFont..
		                "</text>"
		OutputMessage("MSG_SYS", szMsg, true);
	elseif arg0 == PLAYER_FELLOWSHIP_RESPOND.SUCCESS_DEL then
		local szMsg = FormatString(g_tStrings.tFellowshipString[PLAYER_FELLOWSHIP_RESPOND.SUCCESS_DEL], arg4, GlobalEventHandler.GetFellowshipName(arg2));
		OutputMessage("MSG_SYS", szMsg);
	end
end;

OnAddFellowShipAttaction = function(szAlliedPlayerName, nAttraction)
    local szMsg;

    if nAttraction < 0 then
        szMsg = FormatString(g_tStrings.REDUCE_FELLOWSHIP_ATTRACTION, szAlliedPlayerName, -nAttraction);
    elseif nAttraction > 0 then
        szMsg = FormatString(g_tStrings.ADD_FELLOWSHIP_ATTRACTION, szAlliedPlayerName, nAttraction);
    end

    OutputMessage("MSG_ATTRACTION", szMsg);
end;

OnFellowShipAttactionFallOff = function()
    OutputMessage("MSG_ATTRACTION", g_tStrings.FELLOWSHIP_ATTRACTION_FALL_OFF);
end;

OnBeAddFellowShip = function(arg0, arg1, arg2)
	if arg0 == PLAYER_FELLOWSHIP_RESPOND.SUCCESS_BE_ADD_FRIEND then
		if IsFilterOperate("PLAYER_BE_ADD_FELLOWSHIP") then
			return
		end
	
		local font = GetMsgFontString("MSG_SYS")
		local szMessage = MakeNameLink("["..arg2.."]", font).."<text>text="..EncodeComponentsString(g_tStrings.MSG_FRIEND_SUCCEED_BE_ADD_FRIEND)..font.."</text>"
		OutputMessage("MSG_SYS", szMessage, true);
		local msg =
		{
			szMessage = FormatString(g_tStrings.STR_FRIEND_NEED_ADD_FRIEND, arg2),
			szName = "NeedAddFriend",
			{szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = function() GetClientPlayer().AddFellowship(arg2) end},
			{szOption = g_tStrings.STR_HOTKEY_CANCEL, fnAction = function()  end}
		}
		MessageBox(msg)
	end
end;

OnApplyBeAddFoe=function(szName, nSeconds)
	if szName then
        OutputMessage("MSG_SYS", FormatString(g_tStrings.STR_APPLY_BE_ADD_FOE, szName, nSeconds))
        GlobalEventHandler.tBeAddFoeEndSeconds[szName] = nSeconds + math.ceil(GetTickCount() / 1000)
        GlobalEventHandler.tLastShowBeAddFoeLeftSeconds[szName] = -1
		GlobalEventHandler.ShowLeftTimeBeAddFoe()
    end
end;

OnHasBeAddFoe=function(szName)
	if szName then
		local szMsg = FormatString(g_tStrings.STR_HAS_BE_ADD_FOE, szName)
		OutputMessage("MSG_SYS", szMsg)
		OutputMessage("MSG_ANNOUNCE_YELLOW", szMsg)
		GlobalEventHandler.tBeAddFoeEndSeconds[szName] = 0
		GlobalEventHandler.tLastShowBeAddFoeLeftSeconds[szName] = -1
	end
end;


OnAddFoeBegin=function(szName, nSeconds)
	if szName then
        OutputMessage("MSG_SYS", FormatString(g_tStrings.STR_ADD_FOE_BEGIN, szName, nSeconds))
        GlobalEventHandler.tAddFoeEndSeconds[szName] = nSeconds + math.ceil(GetTickCount() / 1000)
        GlobalEventHandler.tLastShowAddFoeLeftSeconds[szName] = -1
		GlobalEventHandler.ShowLeftTimeAddFoe()
    end
end;

OnAddFoeEnd=function(szName)
	if szName then
		local szMsg = FormatString(g_tStrings.STR_ADD_FOE_END, szName)
		OutputMessage("MSG_SYS", szMsg)
		OutputMessage("MSG_ANNOUNCE_YELLOW", szMsg)
		GlobalEventHandler.tAddFoeEndSeconds[szName] = 0
		GlobalEventHandler.tLastShowAddFoeLeftSeconds[szName] = -1
	end
end;

OnPrepareAddFoe=function(nRespondCode)
    if nRespondCode > PLAYER_PREPARE_FELLOWSHIP_RESULT.SUCCESS then
        local szMsg = g_tStrings.tFellowshipPrepareFoeString[nRespondCode];

    	if not szMsg then
    		szMsg = "";
    	end
    	OutputMessage("MSG_ANNOUNCE_RED", szMsg);
    end
end;

OnPlayMiniGame = function(nGameID)
	if nGameID == 1 then
		OpenFindBugGame()
	end
end;

OnLootEvent = function(event)

	if event == "BEGIN_ROLL_ITEM" then
		local dwFrame = GetLogicFrameCount()
		if not CreateLootRoll(dwFrame, arg0, arg1, arg2) then
			CreateLootRollMini(dwFrame, arg0, arg1, arg2)
		end
	elseif event == "LOOT_ITEM" then
    	local player = GetPlayer(arg0)
    	local item = GetItem(arg1)
    	local nCount = arg2
    	local playerName
    	local szItemName = GetItemNameByItem(item)

		if GetClientPlayer().dwID == player.dwID then
			playerName = g_tStrings.STR_NAME_YOU
			FireHelpEvent("OnGetItem", arg1)
			if IsBigBagFull() then
				FireHelpEvent("OnBagFull")
			end
		else
			playerName = player.szName
		end

		local szFont = GetMsgFontString("MSG_ITEM")
		local szItemLink = MakeItemLink("["..szItemName.."]", szFont..GetItemFontColorByQuality(item.nQuality, true), arg1)

		if nCount > 1 then
			OutputMessage("MSG_ITEM", FormatString(g_tStrings.STR_LOOT_ITEM_RICH, playerName, szFont, szItemLink, nCount), true)
		else
			OutputMessage("MSG_ITEM", FormatString(g_tStrings.STR_LOOT_ITEM_RICH_ONE, playerName, szFont, szItemLink), true)
		end
	elseif event == "DISTRIBUTE_ITEM" then
		local player = GetPlayer(arg0)
		local item = GetItem(arg1)
		local szItemName = GetItemNameByItem(item)
		local szFont = GetMsgFontString("MSG_ITEM")
		local szItemLink = MakeItemLink("["..szItemName.."]", szFont..GetItemFontColorByQuality(item.nQuality, true), arg1)

		if GetClientPlayer().dwID == player.dwID then
			playerName = g_tStrings.STR_NAME_YOU
			FireHelpEvent("OnGetItem", arg1)
			if IsBigBagFull() then
				FireHelpEvent("OnBagFull")
			end
		else
			playerName = player.szName
		end

		OutputMessage("MSG_ITEM", FormatString(g_tStrings.STR_DISTRIBUTE_ITEM, szItemLink, szFont, playerName), true)
    elseif event == "ROLL_ITEM" then
    	local player = GetPlayer(arg0)
    	local item = GetItem(arg1)
    	local playerName
    	local szItemName = GetItemNameByItem(item)
		if GetClientPlayer().dwID == player.dwID then
			playerName = g_tStrings.STR_NAME_YOU
		else
			playerName = player.szName
		end
		local szMode = g_tStrings.LOOT_MODE_NEED
		if arg2 == ROLL_ITEM_CHOICE.GREED then
			szMode = g_tStrings.LOOT_MODE_GREED
		end
		local szFont = GetMsgFontString("MSG_ITEM")
		local szItemLink = MakeItemLink("["..szItemName.."]", szFont..GetItemFontColorByQuality(item.nQuality, true), arg1)
    	OutputMessage("MSG_ITEM", FormatString(g_tStrings.STR_PLAYER_ROLL_POINTS_RICH, playerName, szFont, szItemLink, szMode, arg3), true)
    elseif event == "CANCEL_ROLL_ITEM" then
    	local player = GetPlayer(arg0)
    	local item = GetItem(arg1)
    	local playerName
    	local szItemName = GetItemNameByItem(item)
		if GetClientPlayer().dwID == player.dwID then
			playerName = g_tStrings.STR_NAME_YOU
		else
			playerName = player.szName
		end
		local szFont = GetMsgFontString("MSG_ITEM")
		local szItemLink = MakeItemLink("["..szItemName.."]", szFont..GetItemFontColorByQuality(item.nQuality, true), arg1)
		OutputMessage("MSG_ITEM", FormatString(g_tStrings.STR_PLAYER_CANCEL_ROLL_RICH, playerName, szFont, szItemLink), true)
	elseif event == "OPEN_DOODAD" then
		OpenLootList(arg0)
	end
end;

OnMoneyUpdate=function()
	if arg2 then
		local nMoney = arg0
		local nPrevMoney = arg1
		local nDeltaMoney = arg0 - arg1
		if nDeltaMoney > 0 then
			local szFont = GetMsgFontString("MSG_MONEY")
			local szMoney = GetMoneyText(nDeltaMoney, szFont)
			OutputMessage("MSG_MONEY", FormatString(g_tStrings.STR_LOOT_ITEM_RICH_ONE, g_tStrings.STR_NAME_YOU, szFont, szMoney), true)
		end
	end
end;

OnSelfSTChange=function(event)
	local nDeltaStamina = arg0;
	local nDeltaThew = arg1;

	if nDeltaStamina < 0 then
		local szMsg = FormatString(g_tStrings.STR_CRAFT_COST_STAMINA_ENTER, -nDeltaStamina)
		OutputMessage("MSG_THEW_STAMINA", szMsg)
	elseif nDeltaStamina > 0 then
		local szMsg = FormatString(g_tStrings.STR_CRAFT_ADD_STAMINA_ENTER, nDeltaStamina)
		OutputMessage("MSG_THEW_STAMINA", szMsg)
	end

	if nDeltaThew < 0 then
		local szMsg = FormatString(g_tStrings.STR_CRAFT_COST_THEW_ENTER, -nDeltaThew)
		OutputMessage("MSG_THEW_STAMINA", szMsg)
	elseif nDeltaThew > 0 then
		local szMsg = FormatString(g_tStrings.STR_CRAFT_ADD_THEW_ENTER, nDeltaThew)
		OutputMessage("MSG_THEW_STAMINA", szMsg)
	end
end;

OnOpenReadBook=function(event)
	OpenCraftReaderPanel(arg0, arg1, arg2, arg3, true)
end;

OnOpenReadComparePanel=function(event)
	OpenCraftReadComparePanel(arg0, true)
end;

OnBreakEquip=function(event)
	nResult = arg0
	if nResult == DIAMOND_RESULT_CODE.SUCCESS then
		OutputMessage("MSG_ANNOUNCE_YELLOW", g_tStrings.BREAK_EQUIP_SUCCUSS)
	elseif nResult == DIAMOND_RESULT_CODE.NOT_ENOUGH_FREE_ROOM then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.BREAK_EQUIP_NOT_ENOUGH_FREE_ROOM)
	elseif nResult == DIAMOND_RESULT_CODE.CAN_NOT_OPERATE_IN_FIGHT then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.BREAK_EQUIP_CAN_NOT_OPERATE_IN_FIGHT)
	elseif nResult == DIAMOND_RESULT_CODE.NOT_ENOUGH_THEW then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.BREAK_EQUIP_NOT_ENOUGH_THEW)
	elseif nResult == DIAMOND_RESULT_CODE.SCENE_FORBID then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFECommon.SCENE_FORBID)
	else
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.BREAK_EQUIP_FAIL)
	end
end;

OnTradingEvent=function(event)
	if event == "TRADING_OPEN_NOTIFY" then
		OpenTradePanel(arg0)
	elseif event == "TRADING_INVITE" then
		local player = GetPlayer(arg0)
		local dwPlayerID = arg0

		local fnTradingReply = function(bAgree)
			local cP = GetClientPlayer()
			if bAgree then
				cP.TradingInviteRespond(true)
			else
				local player = GetPlayer(dwPlayerID)
				if not player or not player.CanDialog(cP) then
					OutputMessage("MSG_SYS", g_tStrings.STR_TRADING_CANCEL_REASON_TOO_FAR)
				elseif player.nMoveState == MOVE_STATE.ON_DEATH then
					OutputMessage("MSG_SYS", FormatString(g_tStrings.STR_TRADING_CANCEL_REASON_WHO_DIE, player.szName))
				elseif cP.nMoveState == MOVE_STATE.ON_DEATH then
					OutputMessage("MSG_SYS", FormatString(g_tStrings.STR_TRADING_CANCEL_REASON_WHO_DIE, g_tStrings.STR_YOU))
				else
					OutputMessage("MSG_SYS", g_tStrings.STR_TRADING_YOU_CANCEL)
					PlayTipSound("054")
				end
				cP.TradingInviteRespond(false)
			end
		end

		local fnAutoCloseTrade = function()
			local player = GetPlayer(dwPlayerID)
			if not player or not player.CanDialog(GetClientPlayer()) or player.nMoveState == MOVE_STATE.ON_DEATH or GetClientPlayer().nMoveState == MOVE_STATE.ON_DEATH then
				fnTradingReply(false)
				return true
			end
		end
		
		if IsFilterOperate(event) then
			fnTradingReply(false)
			return
		end

		local msg =
		{
			szMessage = FormatString(g_tStrings.STR_TRADING_INVITE, player.szName),
			szName = "TradingInvite",
			fnAutoClose = fnAutoCloseTrade,
			fnCancelAction = function() fnTradingReply(false) end,
			{szOption = g_tStrings.STR_ACCEPT, fnAction = function() fnTradingReply(true) end},
			{szOption = g_tStrings.STR_REFUSE, fnAction = function() fnTradingReply(false) end}
		}
		MessageBox(msg)

		AddContactPeople(player.szName)
	end
end;

OnStartEscortQuest=function(event)
	if event == "START_ESCORT_QUEST" then
		local player = GetPlayer(arg0)
		local dwPlayerID = arg0
		local dwQuestID = arg1
		local tQuestStringInfo = Table_GetQuestStringInfo(dwQuestID)
		local nLiveTime = GLOBAL.START_QUEST_DELAY / GLOBAL.GAME_FPS;
		local dwStartTime = GetTickCount()

		local fnAutoCloseQuest = function()
			if GetTickCount() - dwStartTime > nLiveTime * 1000 then
				return true
			else
				return false
			end
		end

		local msg =
		{
			szMessage = FormatString(g_tStrings.STR_QUEST_START_TEAM, player.szName, tQuestStringInfo.szName),
			szName = "EscortQuest",
			fnAutoClose = fnAutoCloseQuest,
			--fnCancelAction =
			{szOption = g_tStrings.STR_ACCEPT, fnAction = function() GetClientPlayer().AcceptEscortQuest(dwPlayerID, dwQuestID) end, nCountDownTime = nLiveTime},
			{szOption = g_tStrings.STR_REFUSE, fnAction = function()  end}
		}
		MessageBox(msg)
	end
end;

OnApplyDuel=function(event)
	if event == "APPLY_DUEL" then
		local ClientPlayer = GetClientPlayer();
		local player = GetPlayer(arg0)

		local fnAutoCloseTrade = function()
			local ePKState = GetClientPlayer().GetPKState()
			if ePKState ~= PK_STATE.CONFIRM_DUEL then
				return true
			end
		end

		local fnCancelActionTrade = function()
		    local ePKState = GetClientPlayer().GetPKState()
	        if ePKState == PK_STATE.CONFIRM_DUEL then
		        GetClientPlayer().RefuseDuel()
		    end
		end

		if player and player.dwID ~= ClientPlayer.dwID then
			local msg =
			{
				szMessage = FormatString(g_tStrings.STR_PK_DUEL_INVITE, player.szName),
				szName = "ApplyDuel",
				fnAutoClose = fnAutoCloseTrade,
				fnCancelAction = fnCancelActionTrade,
				{szOption = g_tStrings.STR_ACCEPT, fnAction = function() GetClientPlayer().AcceptDuel() end},
				{szOption = g_tStrings.STR_REFUSE, fnAction = function() GetClientPlayer().RefuseDuel() end}
			}
			MessageBox(msg, true)
			PlaySound(SOUND.UI_SOUND,g_sound.Invite)
		end
		FireHelpEvent("OnApplyFight")
	end
end;

PreProcessTalkData = function(dwID, data)
	if type(data) == "table" then
		for k, v in ipairs(data) do
			if v.type == "text" then
				v.text = StringReplaceW(v.text, "\n", "")
				local _, t = GWTextEncoder_EncodeTalkData(v.text)
				if t then
					local szText = ""
					for key, value in ipairs(t) do
						if value.name == "text" then
							szText = szText..value.context
						elseif value.name == "AT" then
							local bFace = false
							if value.attribute.face then
								bFace = true
							end
							Character_PlayAnimation(dwID, GetClientPlayer().dwID, tonumber(value.attribute.actionid), bFace)
						elseif value.name == "SD" then
							Character_PlaySound(dwID, GetClientPlayer().dwID, value.attribute.soundid, false)
						end
					end
					v.text = szText
				end
			end
		end
	else
		data = StringReplaceW(data, "\n", "")
		local _, t = GWTextEncoder_EncodeTalkData(data)
		if t then
			local szText = ""
			for key, value in ipairs(t) do
				if value.name == "text" then
					szText = szText..value.context
				elseif value.name == "AT" then
					local bFace = false
					if value.attribute.face then
						bFace = true
					end
					Character_PlayAnimation(dwID, GetClientPlayer().dwID, tonumber(value.attribute.actionid), bFace)
				elseif value.name == "SD" then
					Character_PlaySound(dwID, GetClientPlayer().dwID, value.attribute.soundid, false)
				end
			end
			data = szText
		end
	end
	return data
end;

GetTalkChannelHead = function(i, n)
	local mt = "MSG_GROUP"
	local f = GetMsgFontString(mt)
	local mg = "<text>text="..EncodeComponentsString(FormatString(g_tStrings.STR_TALK_HEAD_CHANNEL, i))..f.."</text>"..MakeNameLink("["..n.."]", f)
	return mt, f, mg, g_tStrings.STR_TALK_HEAD_SAY1
end;

OnPlayerTalk=function(event)
    local dwTalkerID = arg0
    local nChannel = arg1
	local bEcho = arg2
	local szName = arg3

	local t = nil
	local szMsgType   = nil
	local bOutputFlag = true
	local szMsg = ""
	local szPlainText = ""
	local szFont = ""
	local szLeft = ""
	local player = GetClientPlayer()
	if not player then
		return
	end

	local bUsePlainTextOnly = false
	if nChannel == PLAYER_TALK_CHANNEL.NPC_SAY_TO_ID then
		bEcho = false
		nChannel = PLAYER_TALK_CHANNEL.NPC_NEARBY
		szPlainText = g_tStrings.tNpcSentence[arg2]
		szPlainText = GlobalEventHandler.PreProcessTalkData(dwTalkerID, szPlainText)
		bUsePlainTextOnly = true
	else
		t = player.GetTalkData()
		if not t then
			return
		end
		if t[1] and t[1].type == "text" and t[1].text == "BG_CHANNEL_MSG" then
			FireEvent("ON_BG_CHANNEL_MSG")
			return
		end
	end

	if nChannel == PLAYER_TALK_CHANNEL.WHISPER then
		szMsgType = "MSG_WHISPER"
		szFont = GetMsgFontString(szMsgType)
		local bAutoReply = t[1] and t[1].type == "text" and (t[1].text == "afk" or t[1].text == "atr")
		if bAutoReply then
			table.remove(t, 1)
		end
        if bEcho then
        	AddContactPeople(szName)
        	szMsg = "<text>text="..EncodeComponentsString(g_tStrings.STR_TALK_HEAD_WHISPER_REPLY)..szFont.."</text>"..MakeNameLink("["..szName.."]", szFont)
            szLeft = g_tStrings.STR_TALK_HEAD_SAY
        else
        	local player = GetClientPlayer()
        	if player and player.szName ~= szName then
        		AddContactPeople(szName)
        		if not bAutoReply then
		        	local tATR = EditBox.GetATR()
		        	if tATR then --自动回复
		        		player.Talk(PLAYER_TALK_CHANNEL.WHISPER, szName, tATR)
					elseif Station.GetIdleTime() > 300000 then --3分钟玩家没有用户输入，自动回复
						player.Talk(PLAYER_TALK_CHANNEL.WHISPER, szName, EditBox.GetAFK())
					end
				end
			end
            szMsg = MakeNameLink("["..szName.."]", szFont)
            szLeft = g_tStrings.STR_TALK_HEAD_WHISPER
            EditBox.AddReply(szName)
        end
        PlaySound(SOUND.UI_SOUND,g_sound.Whisper)
	elseif nChannel == PLAYER_TALK_CHANNEL.NEARBY   		then
		szMsgType = "MSG_NORMAL"
		szFont = GetMsgFontString(szMsgType)
		szMsg = MakeNameLink("["..szName.."]", szFont)
		szLeft = g_tStrings.STR_TALK_HEAD_SAY
	elseif nChannel == PLAYER_TALK_CHANNEL.TEAM     		then
		szMsgType = "MSG_PARTY"
		szFont = GetMsgFontString(szMsgType)
		szMsg = MakeMsgLink(g_tStrings.STR_TALK_HEAD_PARTY, szFont)..MakeNameLink("["..szName.."]", szFont)
		szLeft = g_tStrings.STR_TALK_HEAD_SAY1
	elseif nChannel == PLAYER_TALK_CHANNEL.TONG then
		szMsgType = "MSG_GUILD"
		szFont = GetMsgFontString(szMsgType)
		szMsg = MakeMsgLink(g_tStrings.STR_TALK_HEAD_TONG, szFont)..MakeNameLink("["..szName.."]", szFont)
		szLeft = g_tStrings.STR_TALK_HEAD_SAY1
	elseif nChannel == PLAYER_TALK_CHANNEL.TONG_SYS then
		szMsgType = "MSG_GUILD"
        szFont = GetMsgFontString(szMsgType)
		szMsg = MakeMsgLink(g_tStrings.STR_TALK_HEAD_TONG, szFont)
		szLeft = ""
	elseif nChannel == PLAYER_TALK_CHANNEL.WORLD then
		szMsgType = "MSG_WORLD"
		szFont = GetMsgFontString(szMsgType)
		szMsg = MakeMsgLink(g_tStrings.STR_TALK_HEAD_WORLD, szFont)..MakeNameLink("["..szName.."]", szFont)
		szLeft = g_tStrings.STR_TALK_HEAD_SAY1
	elseif nChannel == PLAYER_TALK_CHANNEL.FORCE then
		szMsgType = "MSG_SCHOOL"
		szFont = GetMsgFontString(szMsgType)
		szMsg = MakeMsgLink(g_tStrings.STR_TALK_HEAD_SCHOOL, szFont)..MakeNameLink("["..szName.."]", szFont)
		szLeft = g_tStrings.STR_TALK_HEAD_SAY1
	elseif nChannel == PLAYER_TALK_CHANNEL.CAMP then
		szMsgType = "MSG_CAMP"
		szFont = GetMsgFontString(szMsgType)
		szMsg = MakeMsgLink(g_tStrings.STR_TALK_HEAD_CAMP, szFont).."<text>text="..EncodeComponentsString(g_tStrings.STR_TALK_CAMP_NAME[player.nCamp])..szFont.."</text>"..MakeNameLink("["..szName.."]", szFont)
		szLeft = g_tStrings.STR_TALK_HEAD_SAY1
	elseif nChannel == PLAYER_TALK_CHANNEL.MENTOR then
		szMsgType = "MSG_MENTOR"
		szFont = GetMsgFontString(szMsgType)
		szMsg = MakeMsgLink(g_tStrings.STR_TALK_HEAD_MENTOR, szFont)..MakeNameLink("["..szName.."]", szFont)
		szLeft = g_tStrings.STR_TALK_HEAD_SAY1
	elseif nChannel == PLAYER_TALK_CHANNEL.FRIENDS then
		szMsgType = "MSG_FRIEND"
		szFont = GetMsgFontString(szMsgType)
		szMsg = MakeMsgLink(g_tStrings.STR_TALK_HEAD_FRIEND, szFont)..MakeNameLink("["..szName.."]", szFont)
		szLeft = g_tStrings.STR_TALK_HEAD_SAY1
	elseif nChannel == PLAYER_TALK_CHANNEL.RAID then
		szMsgType = "MSG_TEAM"
		szFont = GetMsgFontString(szMsgType)
		szMsg = MakeMsgLink(g_tStrings.STR_TALK_HEAD_TEAM, szFont)..MakeNameLink("["..szName.."]", szFont)
		szLeft = g_tStrings.STR_TALK_HEAD_SAY1
	elseif nChannel == PLAYER_TALK_CHANNEL.SENCE    		then
		szMsgType = "MSG_MAP"
		szFont = GetMsgFontString(szMsgType)
		szMsg = MakeMsgLink(g_tStrings.STR_TALK_HEAD_SENCE, szFont)..MakeNameLink("["..szName.."]", szFont)
		szLeft = g_tStrings.STR_TALK_HEAD_SAY1
	elseif nChannel == PLAYER_TALK_CHANNEL.BATTLE_FIELD then
		szMsgType = "MSG_BATTLE_FILED"
		szFont = GetMsgFontString(szMsgType)
		szMsg = MakeMsgLink(g_tStrings.STR_TALK_HEAD_BATTLE_FILED, szFont)..MakeNameLink("["..szName.."]", szFont)
		szLeft = g_tStrings.STR_TALK_HEAD_SAY1
	elseif nChannel == PLAYER_TALK_CHANNEL.CHANNEL1 		then
		szMsgType, szFont, szMsg, szLeft = GlobalEventHandler.GetTalkChannelHead(1, szName)
	elseif nChannel == PLAYER_TALK_CHANNEL.CHANNEL2 		then
		szMsgType, szFont, szMsg, szLeft = GlobalEventHandler.GetTalkChannelHead(2, szName)
	elseif nChannel == PLAYER_TALK_CHANNEL.CHANNEL3 		then
		szMsgType, szFont, szMsg, szLeft = GlobalEventHandler.GetTalkChannelHead(3, szName)
	elseif nChannel == PLAYER_TALK_CHANNEL.CHANNEL4 		then
		szMsgType, szFont, szMsg, szLeft = GlobalEventHandler.GetTalkChannelHead(4, szName)
	elseif nChannel == PLAYER_TALK_CHANNEL.CHANNEL5 		then
		szMsgType, szFont, szMsg, szLeft = GlobalEventHandler.GetTalkChannelHead(5, szName)
	elseif nChannel == PLAYER_TALK_CHANNEL.CHANNEL6 		then
		szMsgType, szFont, szMsg, szLeft = GlobalEventHandler.GetTalkChannelHead(6, szName)
	elseif nChannel == PLAYER_TALK_CHANNEL.CHANNEL7 		then
		szMsgType, szFont, szMsg, szLeft = GlobalEventHandler.GetTalkChannelHead(7, szName)
	elseif nChannel == PLAYER_TALK_CHANNEL.CHANNEL8 		then
		szMsgType, szFont, szMsg, szLeft = GlobalEventHandler.GetTalkChannelHead(8, szName)
	elseif nChannel == PLAYER_TALK_CHANNEL.LOCAL_SYS 		then
		szMsgType = "MSG_SYS"
        szFont = GetMsgFontString(szMsgType)
		szMsg = ""
		szLeft = ""
        
	elseif nChannel == PLAYER_TALK_CHANNEL.GM_MESSAGE		then
		szMsgType = "MSG_SYS"
		szFont = GetMsgFontString(szMsgType)
		szMsg = ""
		szLeft = "："
	elseif nChannel == PLAYER_TALK_CHANNEL.NPC_WHISPER     then
		szMsgType = "MSG_NPC_WHISPER"
		szFont = GetMsgFontString(szMsgType)
		szMsg = "<text>text="..EncodeComponentsString("["..szName.."]")..szFont.."</text>"
		szLeft = g_tStrings.STR_TALK_HEAD_WHISPER
	elseif nChannel == PLAYER_TALK_CHANNEL.NPC_NEARBY   	then
		szMsgType = "MSG_NPC_NEARBY"
		szFont = GetMsgFontString(szMsgType)
		szMsg = "<text>text="..EncodeComponentsString("["..szName.."]")..szFont.."</text>"
		szLeft = g_tStrings.STR_TALK_HEAD_SAY
	elseif nChannel == PLAYER_TALK_CHANNEL.NPC_PARTY    	then
		szMsgType = "MSG_NPC_PARTY"
		szFont = GetMsgFontString(szMsgType)
		szMsg = "<text>text="..EncodeComponentsString(g_tStrings.STR_TALK_HEAD_PARTY.."["..szName.."]")..szFont.."</text>"
		szLeft = g_tStrings.STR_TALK_HEAD_SAY1
	elseif nChannel == PLAYER_TALK_CHANNEL.NPC_SENCE    	then
		szMsgType = "MSG_NPC_YELL"
		szFont = GetMsgFontString(szMsgType)
		szMsg = "<text>text="..EncodeComponentsString(g_tStrings.STR_TALK_HEAD_SENCE.."["..szName.."]")..szFont.."</text>"
		szLeft = g_tStrings.STR_TALK_HEAD_SAY2
	elseif nChannel == PLAYER_TALK_CHANNEL.FACE             then
		szMsgType = "MSG_FACE"
		szFont = GetMsgFontString(szMsgType)
		szMsg = ""
		szLeft = ""
	elseif nChannel == PLAYER_TALK_CHANNEL.NPC_FACE         then
		szMsgType = "MSG_NPC_FACE"
		szFont = GetMsgFontString(szMsgType)
		szMsg = ""
		szLeft = ""
	elseif nChannel == PLAYER_TALK_CHANNEL.NPC_SAY_TO_CAMP then
		szMsgType = "MSG_CAMP"
		szFont = GetMsgFontString(szMsgType)
		szMsg = MakeMsgLink(g_tStrings.STR_TALK_HEAD_CAMP, szFont).."<text>text="..EncodeComponentsString(g_tStrings.STR_TALK_CAMP_NAME[player.nCamp])..szFont.."</text><text>text="..EncodeComponentsString("["..szName.."]")..szFont.."</text>"
		szLeft = g_tStrings.STR_TALK_HEAD_SAY1
	end

	if not szMsgType then
		return
	end

	if not bUsePlainTextOnly then
		t = GlobalEventHandler.PreProcessTalkData(dwTalkerID, t)

		local nFaceCount = 0;
		for k, v in ipairs(t) do    --处理格式化文本
			local szAddEnd = ""
			if k == #t then
				szAddEnd = "\n"
			end
			if v.type == "text" then
				local hAnimate = EmotionPanel_ParseFaceIcon(v.text, szFont, nFaceCount)
				if hAnimate then
					nFaceCount = nFaceCount + 1
					szMsg = szMsg.."<text>text="..EncodeComponentsString(szLeft)..szFont.."</text>"
					szMsg = szMsg..hAnimate
					szMsg = szMsg.."<text>text="..EncodeComponentsString(szAddEnd)..szFont.."</text>"
				else
					szMsg = szMsg.."<text>text="..EncodeComponentsString(szLeft..v.text..szAddEnd)..szFont.."</text>"
				end
				szLeft = ""
		        szPlainText = szPlainText..v.text
		    elseif v.type == "emotion" then
			    szMsg = ""
			    szLeft = g_tStrings.STR_FACE
			else
				if szLeft ~= "" then
					szMsg = szMsg.."<text>text="..EncodeComponentsString(szLeft)..szFont.."</text>"
					szLeft = ""
				end
				if v.type == "item" then
					local item = player.GetTalkLinkItem(v.item)
					if item then
						local szItemName = GetItemNameByItem(item)
						szMsg = szMsg..MakeItemLink("["..szItemName.."]"..szAddEnd, szFont..GetItemFontColorByQuality(item.nQuality, true), v.item)
				        szPlainText = szPlainText.."["..szItemName.."]"
			        else
			        	szMsg = szMsg.."<text>text="..EncodeComponentsString(g_tStrings.STR_TALK_UNKNOWN_ITEM_LINK..szAddEnd)..szFont.."</text>"
			        	szPlainText = szPlainText..g_tStrings.STR_TALK_UNKNOWN_ITEM_LINK
			        end
			    elseif v.type == "iteminfo" then
					local intemInfo = GetItemInfo(v.tabtype, v.index)
					if intemInfo then
						local szItemName = GetItemNameByItemInfo(intemInfo)
						szMsg = szMsg..MakeItemInfoLink("["..szItemName.."]"..szAddEnd, szFont..GetItemFontColorByQuality(intemInfo.nQuality, true), v.version, v.tabtype, v.index)
				        szPlainText = szPlainText.."["..szItemName.."]"
					else
			        	szMsg = szMsg.."<text>text="..EncodeComponentsString(g_tStrings.STR_TALK_UNKNOWN_ITEM_LINK..szAddEnd)..szFont.."</text>"
			        	szPlainText = szPlainText..g_tStrings.STR_TALK_UNKNOWN_ITEM_LINK
					end
				elseif v.type == "name" then
					szMsg = szMsg..MakeNameLink("["..v.name.."]"..szAddEnd, szFont)
					szPlainText = szPlainText.."["..v.name.."]"
				elseif v.type == "quest" then
		            local tQuestStringInfo = Table_GetQuestStringInfo(v.questid)
		            if tQuestStringInfo then
						szMsg = szMsg..MakeQuestLink("["..tQuestStringInfo.szName.."]"..szAddEnd, szFont, v.questid)
						szPlainText = szPlainText.."["..tQuestStringInfo.szName.."]"
					else
			        	szMsg = szMsg.."<text>text="..EncodeComponentsString(g_tStrings.STR_TALK_UNKNOWN_QUEST_LINK..szAddEnd)..szFont.."</text>"
			        	szPlainText = szPlainText..g_tStrings.STR_TALK_UNKNOWN_QUEST_LINK
		            end
		        elseif v.type == "recipe" then
		        	local recipe = GetRecipe(v.craftid, v.recipeid)
		            if recipe then
		            	local szRecipeName = Table_GetRecipeName(v.craftid, v.recipeid)
						szMsg = szMsg..MakeRecipeLink("["..szRecipeName.."]"..szAddEnd, szFont, v.craftid, v.recipeid)
						szPlainText = szPlainText.."["..szRecipeName.."]"
					else
			        	szMsg = szMsg.."<text>text="..EncodeComponentsString(g_tStrings.STR_TALK_UNKNOWN_RECIPE_LINK..szAddEnd)..szFont.."</text>"
			        	szPlainText = szPlainText..g_tStrings.STR_TALK_UNKNOWN_RECIPE_LINK
		            end
				elseif v.type == "enchant" then
		        	local szName = Table_GetEnchantName(v.proid, v.craftid, v.recipeid)
		        	local nQuality = Table_GetEnchantQuality(v.proid, v.craftid, v.recipeid)
		            if szName then
						szMsg = szMsg..MakeEnchantLink("["..szName.."]"..szAddEnd, szFont..GetItemFontColorByQuality(nQuality, true), v.proid, v.craftid, v.recipeid)
						szPlainText = szPlainText.."["..szName.."]"
					else
			        	szMsg = szMsg.."<text>text="..EncodeComponentsString(g_tStrings.STR_TALK_UNKNOWN_RECIPE_LINK..szAddEnd)..szFont.."</text>"
			        	szPlainText = szPlainText..g_tStrings.STR_TALK_UNKNOWN_RECIPE_LINK
		            end
		        elseif v.type == "skill" then
		        	local szSkillName = Table_GetSkillName(v.skill_id, v.skill_level)
					szMsg = szMsg..MakeSkillLink("["..szSkillName.."]"..szAddEnd, szFont, v)
					szPlainText = szPlainText.."["..szSkillName.."]"
				elseif v.type == "skillrecipe" then
					local tSkillRecipe = Table_GetSkillRecipe(v.id, v.level)
					local szSkillRecipeName = ""
					if tSkillRecipe then
						szSkillRecipeName = tSkillRecipe.szName
					end
					szMsg = szMsg..MakeSkillRecipeLink("["..szSkillRecipeName.."]"..szAddEnd, szFont, v.id, v.level)
					szPlainText = szPlainText.."["..szSkillRecipeName.."]"
				elseif v.type == "book" then
					local intemInfo = GetItemInfo(v.tabtype, v.index)
					if intemInfo then
						local nBookID, nSegmentID = GlobelRecipeID2BookID(v.bookinfo)
						local szBookName = Table_GetSegmentName(nBookID, nSegmentID)
						szMsg = szMsg..MakeBookLink("["..szBookName.."]"..szAddEnd, szFont..GetItemFontColorByQuality(intemInfo.nQuality, true), v.version, v.tabtype, v.index, v.bookinfo)
						szPlainText = szPlainText.."["..szBookName.."]"
					end
				elseif v.type == "achievement" then
					local aAchievement = g_tTable.Achievement:Search(v.id)
					if aAchievement then
						szMsg = szMsg..MakeAchievementLink("["..aAchievement.szName.."]"..szAddEnd, szFont, v.id)
						szPlainText = szPlainText.."["..aAchievement.szName.."]"
					end
				elseif v.type == "designation" then
					local aDesignation
					if v.prefix then
						aDesignation = g_tTable.Designation_Prefix:Search(v.id)
					else
						aDesignation = g_tTable.Designation_Postfix:Search(v.id)
					end
					if aDesignation then
						szMsg = szMsg..MakeDesignationLink("["..aDesignation.szName.."]"..szAddEnd, szFont, v.id, v.prefix)
						szPlainText = szPlainText.."["..aDesignation.szName.."]"
					end
				elseif v.type == "eventlink" then
					szMsg = szMsg..MakeEventLink(v.name..szAddEnd, szFont, v.name, v.linkinfo)
					szPlainText = szPlainText..v.name
				end
			end
		end
	else
		szMsg = szMsg.."<text>text="..EncodeComponentsString(szLeft..szPlainText.."\n")..szFont.."</text>"
		szLeft = ""
	end
    
	if nChannel == PLAYER_TALK_CHANNEL.GM_MESSAGE then
		GMPanel_GMReply(szPlainText)
	elseif bOutputFlag and szMsg ~= "" and szLeft == "" then
		OutputMessage(szMsgType, szMsg, true)
	end

	if szPlainText ~= "" then
	    if
	        nChannel == PLAYER_TALK_CHANNEL.NEARBY or
	        nChannel == PLAYER_TALK_CHANNEL.TEAM or
	        nChannel == PLAYER_TALK_CHANNEL.RAID or
	        nChannel == PLAYER_TALK_CHANNEL.SENCE or
	        nChannel == PLAYER_TALK_CHANNEL.BATTLE_FIELD or
	        nChannel == PLAYER_TALK_CHANNEL.NPC_NEARBY or
	        nChannel == PLAYER_TALK_CHANNEL.NPC_PARTY or
	        nChannel == PLAYER_TALK_CHANNEL.NPC_SENCE
	    then
		    local prevArg0=arg0
            local prevArg1=arg1
            local prevArg2=arg2

    		arg0=szPlainText
    		arg1=dwTalkerID
            arg2=nChannel

    		FireEvent("PLAYER_SAY")

    		arg0=prevArg0
    		arg1=prevArg1
    		arg2=prevArg2
    	end
	end
end;

OnAnnounceTalk=function(event)
	local nChannel 		= arg0
	local bChatShow		= arg1
	local bScrollShow	= arg2
	local bCalendarShow	= arg3

	local t = nil
	local szMsgType   = nil
	local szMsg 	  = ""
	local szPlainText = ""
	local szFont = ""
	local szLeft = ""
	local player = GetClientPlayer()
	if not player then
		return
	end

	t = player.GetTalkData()
	if not t then
		return
	end
    --[[
	if 
		nChannel ~= PLAYER_TALK_CHANNEL.GLOBAL_SYS and
		nChannel ~= PLAYER_TALK_CHANNEL.GM_ANNOUNCE and
		nChannel ~= PLAYER_TALK_CHANNEL.TO_TONG_GM_ANNOUNCE and
		nChannel ~= PLAYER_TALK_CHANNEL.TO_PLAYER_GM_ANNOUNCE
	then
        return
    end
    ]]
	if bChatShow then
		szMsgType = "MSG_SYS"
		szFont = GetMsgFontString(szMsgType)
		szMsg = "<image>path=\"UI/Image/Minimap/Minimap.UITex\" frame=184</image>"
		szLeft = ""
	end
    
	t = GlobalEventHandler.PreProcessTalkData(nil, t)
	for k, v in ipairs(t) do    --处理格式化文本
		local szAddEnd = ""
		if k == #t then
			szAddEnd = "\n"
		end
		if v.type == "text" then
			szMsg = szMsg.."<text>text="..EncodeComponentsString(szLeft..v.text..szAddEnd)..szFont.."</text>"
			szLeft = ""
			szPlainText = szPlainText..v.text
	        end
	end
    
    if bChatShow then
        OutputMessage(szMsgType, szMsg, true)
    end
    
    if bScrollShow then
        szMsgType = "MSG_GM_ANNOUNCE"
        OutputMessage(szMsgType, szPlainText)
    end
	
    if bCalendarShow then
        local argSave0 = arg0
        local argSave1 = arg1
        arg0 = szPlainText
        arg1 = GetCurrentTime()
        FireEvent("CHANNEL_GM_ANNOUNCE")
        arg0 = argSave0
        arg1 = argSave1
    end
end;

OnPlayerMessage=function(event)
    local dwMailID = arg0
    local szSender, szTitle, nTime, t = GetMailClient().GetPlayerMessage(dwMailID)
	if not t then
		return
	end

	local player = GetClientPlayer()
	if not player then
		return
	end

	local szTime = FormatTimeString(nTime)
    local nChannel = PLAYER_TALK_CHANNEL.WHISPER
    local szMsgType = "MSG_WHISPER"
    local szFont = GetMsgFontString(szMsgType)
    local szLeft = g_tStrings.STR_TALK_HEAD_WHISPER

	local szMsg = ""
    szMsg = szMsg.."<text>text="..EncodeComponentsString(" "..szTime.." ")..szFont.."</text>"
    szMsg = szMsg..MakeNameLink("["..szSender.."]", szFont)

	t = GlobalEventHandler.PreProcessTalkData(dwTalkerID, t)

	for k, v in ipairs(t) do    --处理格式化文本
		local szAddEnd = ""
		if k == #t then
			szAddEnd = "\n"
		end
		if v.type == "text" then
			szMsg = szMsg.."<text>text="..EncodeComponentsString(szLeft..v.text..szAddEnd)..szFont.."</text>"
			szLeft = ""
	    elseif v.type == "emotion" then
		    szMsg = "<text>text="..EncodeComponentsString(" "..szTime.." ")..szFont.."</text>"
		    szLeft = g_tStrings.STR_FACE
		else
			if szLeft ~= "" then
				szMsg = szMsg.."<text>text="..EncodeComponentsString(szLeft)..szFont.."</text>"
				szLeft = ""
			end
			if v.type == "item" then
				local item = player.GetTalkLinkItem(v.item)
				if item then
					local szItemName = GetItemNameByItem(item)
					szMsg = szMsg..MakeItemLink("["..szItemName.."]"..szAddEnd, szFont..GetItemFontColorByQuality(item.nQuality, true), v.item)
		        else
		        	szMsg = szMsg.."<text>text="..EncodeComponentsString(g_tStrings.STR_TALK_UNKNOWN_ITEM_LINK..szAddEnd)..szFont.."</text>"
		        end
		    elseif v.type == "iteminfo" then
				local intemInfo = GetItemInfo(v.tabtype, v.index)
				if intemInfo then
					local szItemName = GetItemNameByItemInfo(intemInfo)
					szMsg = szMsg..MakeItemInfoLink("["..szItemName.."]"..szAddEnd, szFont..GetItemFontColorByQuality(intemInfo.nQuality, true), v.version, v.tabtype, v.index)
					else
		        	szMsg = szMsg.."<text>text="..EncodeComponentsString(g_tStrings.STR_TALK_UNKNOWN_ITEM_LINK..szAddEnd)..szFont.."</text>"
				end
			elseif v.type == "name" then
				szMsg = szMsg..MakeNameLink("["..v.name.."]"..szAddEnd, szFont)
			elseif v.type == "quest" then
	            local tQuestStringInfo = Table_GetQuestStringInfo(v.questid)
	            if tQuestStringInfo then
					szMsg = szMsg..MakeQuestLink("["..tQuestStringInfo.szName.."]"..szAddEnd, szFont, v.questid)
				else
		        	szMsg = szMsg.."<text>text="..EncodeComponentsString(g_tStrings.STR_TALK_UNKNOWN_QUEST_LINK..szAddEnd)..szFont.."</text>"
	            end
	        elseif v.type == "recipe" then
	        	local recipe = GetRecipe(v.craftid, v.recipeid)
	            if recipe then
	            	local szRecipeName = Table_GetRecipeName(v.craftid, v.recipeid)
					szMsg = szMsg..MakeRecipeLink("["..szRecipeName.."]"..szAddEnd, szFont, v.craftid, v.recipeid)
				else
		        	szMsg = szMsg.."<text>text="..EncodeComponentsString(g_tStrings.STR_TALK_UNKNOWN_RECIPE_LINK..szAddEnd)..szFont.."</text>"
	            end
			elseif v.type == "enchant" then
	        	local szName = Table_GetEnchantName(v.proid, v.craftid, v.recipeid)
	        	local nQuality = Table_GetEnchantQuality(v.proid, v.craftid, v.recipeid)
	            if szName then
					szMsg = szMsg..MakeEnchantLink("["..szName.."]"..szAddEnd, szFont..GetItemFontColorByQuality(nQuality, true), v.proid, v.craftid, v.recipeid)
				else
		        	szMsg = szMsg.."<text>text="..EncodeComponentsString(g_tStrings.STR_TALK_UNKNOWN_RECIPE_LINK..szAddEnd)..szFont.."</text>"
	            end
	        elseif v.type == "skill" then
	        	local szSkillName = Table_GetSkillName(v.skill_id, v.skill_level)
				szMsg = szMsg..MakeSkillLink("["..szSkillName.."]"..szAddEnd, szFont, v)
			elseif v.type == "skillrecipe" then
				local tSkillRecipe = Table_GetSkillRecipe(v.id, v.level)
				local szSkillRecipeName = ""
				if tSkillRecipe then
					szSkillRecipeName = tSkillRecipe.szName
				end
				szMsg = szMsg..MakeSkillRecipeLink("["..szSkillRecipeName.."]"..szAddEnd, szFont, v.id, v.level)
			elseif v.type == "book" then
				local intemInfo = GetItemInfo(v.tabtype, v.index)
				if intemInfo then
					local nBookID, nSegmentID = GlobelRecipeID2BookID(v.bookinfo)
					local szBookName = Table_GetSegmentName(nBookID, nSegmentID)
					szMsg = szMsg..MakeBookLink("["..szBookName.."]"..szAddEnd, szFont..GetItemFontColorByQuality(intemInfo.nQuality, true), v.version, v.tabtype, v.index, v.bookinfo)
				end
			elseif v.type == "achievement" then
				local aAchievement = g_tTable.Achievement:Search(v.id)
				if aAchievement then
					szMsg = szMsg..MakeAchievementLink("["..aAchievement.szName.."]"..szAddEnd, szFont, v.id)
				end
			elseif v.type == "designation" then
				local aDesignation
				if v.prefix then
					aDesignation = g_tTable.Designation_Prefix:Search(v.id)
				else
					aDesignation = g_tTable.Designation_Postfix:Search(v.id)
				end
				if aDesignation then
					szMsg = szMsg..MakeDesignationLink("["..aDesignation.szName.."]"..szAddEnd, szFont, v.id, v.prefix)
				end
			end
		end
	end

	if szMsg ~= "" then
        OutputMessage(szMsgType, szMsg, true)
    end

	GetMailClient().DeleteMail(dwMailID)
end;

OnPartyEvent=function(event)
    if event == "PARTY_MESSAGE_NOTIFY" then

        local szMsg = ""
        if arg0 == PARTY_NOTIFY_CODE.PNC_PLAYER_INVITE_NOT_EXIST then
            szMsg = FormatString(g_tStrings.STR_MSG_PLAYER_INVITE_NOT_EXIST, arg1)
            PlaySound(SOUND.UI_SOUND,g_sound.ActionFailed)
        elseif arg0 == PARTY_NOTIFY_CODE.PNC_PLAYER_APPLY_NOT_EXIST then
            szMsg = FormatString(g_tStrings.STR_MSG_PLAYER_APPLY_NOT_EXIST, arg1)
            PlaySound(SOUND.UI_SOUND,g_sound.ActionFailed)
        elseif arg0 == PARTY_NOTIFY_CODE.PNC_PLAYER_ALREAD_IN_YOUR_PARTY then
            szMsg = FormatString(g_tStrings.STR_MSG_PLAYER_ALREAD_IN_YOUR_PARTY, arg1)
        elseif arg0 == PARTY_NOTIFY_CODE.PNC_PLAYER_ALREAD_IN_OTHER_PARTY then
            szMsg = FormatString(g_tStrings.STR_MSG_PLAYER_ALREAD_IN_OTHER_PARTY, arg1)
        elseif arg0 == PARTY_NOTIFY_CODE.PNC_YOU_ALREAD_IN_PARTY_STATE then
            szMsg = FormatString(g_tStrings.STR_MSG_YOU_ALREAD_IN_PARTY_STATE, arg1)
        elseif arg0 == PARTY_NOTIFY_CODE.PNC_PLAYER_IS_BUSY then
            szMsg = FormatString(g_tStrings.STR_MSG_PLAYER_IS_BUSY, arg1)
        elseif arg0 == PARTY_NOTIFY_CODE.PNC_INVITATION_DENIED then
            szMsg = FormatString(g_tStrings.STR_MSG_INVITATION_DENIED, arg1)
        elseif arg0 == PARTY_NOTIFY_CODE.PNC_APPLICATION_DENIED then
            szMsg = FormatString(g_tStrings.STR_MSG_APPLICATION_DENIED, arg1)
        elseif arg0 == PARTY_NOTIFY_CODE.PNC_PLAYER_NOT_ONLINE then
            szMsg = FormatString(g_tStrings.STR_MSG_PLAYER_NOT_ONLINE, arg1)
        elseif arg0 == PARTY_NOTIFY_CODE.PNC_DEST_PARTY_IS_FULL then
            szMsg = FormatString(g_tStrings.STR_MSG_DEST_PARTY_IS_FULL, arg1)
        elseif arg0 == PARTY_NOTIFY_CODE.PNC_YOUR_PARTY_IS_FULL then
            szMsg = FormatString(g_tStrings.STR_MSG_YOUR_PARTY_IS_FULL, arg1)
        elseif arg0 == PARTY_NOTIFY_CODE.PNC_INVITATION_OUT_OF_DATE then
            szMsg = FormatString(g_tStrings.STR_MSG_INVITATION_OUT_OF_DATE, arg1)
        elseif arg0 == PARTY_NOTIFY_CODE.PNC_APPLICATION_OUT_OF_DATE then
            szMsg = FormatString(g_tStrings.STR_MSG_APPLICATION_OUT_OF_DATE, arg1)
        elseif arg0 == PARTY_NOTIFY_CODE.PNC_PARTY_CREATED then
            szMsg = g_tStrings.STR_MSG_PARTY_CREATED
        elseif arg0 == PARTY_NOTIFY_CODE.PNC_PARTY_JOINED then
            szMsg = FormatString(g_tStrings.STR_MSG_PARTY_JOINED, arg1)
			
        elseif arg0 == PARTY_NOTIFY_CODE.PNC_INVITATION_DONE then
            szMsg = FormatString(g_tStrings.STR_MSG_INVITATION_DONE, arg1)
        elseif arg0 == PARTY_NOTIFY_CODE.PNC_APPLICATION_DONE then
            szMsg = FormatString(g_tStrings.STR_MSG_APPLICATION_DONE, arg1)
			
        elseif arg0 == PARTY_NOTIFY_CODE.PNC_INVITATION_REJECT then
            szMsg = FormatString(g_tStrings.STR_MSG_INVITATION_REJECT, arg1)
        elseif arg0 == PARTY_NOTIFY_CODE.PNC_APPLICATION_REJECT then
            szMsg = FormatString(g_tStrings.STR_MSG_APPLICATION_REJECT, arg1)
        elseif arg0 == PARTY_NOTIFY_CODE.PNC_CAMP_ERROR then
        	szMsg = g_tStrings.STR_MSG_CAMP_ERROR
        	PlaySound(SOUND.UI_SOUND,g_sound.ActionFailed)
        elseif arg0 == PARTY_NOTIFY_CODE.PNC_INVITE_SYSTEM_TEAM then
        	szMsg = g_tStrings.STR_MSG_INVITE_SYSTEM_TEAM
        elseif arg0 == PARTY_NOTIFY_CODE.PNC_APPLY_SYSTEM_TEAM then
        	szMsg = g_tStrings.STR_MSG_APPLY_SYSTEM_TEAM
        elseif arg0 == PARTY_NOTIFY_CODE.PNC_REFUSE_ALL_TEAM_INVITE then
        	szMsg = g_tStrings.STR_MSG_REFUSE_ALL_TEAM_INVITE
        end

        OutputMessage("MSG_SYS", szMsg)

	elseif event == "PARTY_DISBAND" then
        OutputMessage("MSG_SYS", g_tStrings.STR_MSG_YOUR_PARTY_DISBAND)
	elseif event == "PARTY_UPDATE_BASE_INFO" then
	    if not arg4 then --仅加入队伍的时候需要下面的提示
	        return
	    end

		if arg2 == PARTY_LOOT_MODE.FREE_FOR_ALL then
			OutputMessage("MSG_SYS", FormatString(g_tStrings.STR_MSG_CURRENT_LOOTMODE, g_tStrings.STR_LOOTMODE_FREE_FOR_ALL))
		elseif arg2 == PARTY_LOOT_MODE.DISTRIBUTE then
			OutputMessage("MSG_SYS", FormatString(g_tStrings.STR_MSG_CURRENT_LOOTMODE, g_tStrings.STR_LOOTMODE_DISTRIBUTE))
			OutputMessage("MSG_SYS", g_tStrings.STR_MSG_DISTRIBUTE_WARNING)
		elseif arg2 == PARTY_LOOT_MODE.GROUP_LOOT then
			OutputMessage("MSG_SYS", FormatString(g_tStrings.STR_MSG_CURRENT_LOOTMODE, g_tStrings.STR_LOOTMODE_GROUP_LOOT))
		else
			Trace("PARTY_LOOT_MODE_CHANGED changed to a unkown mode!\n")
		end

		if arg3 == 2 then
			OutputMessage("MSG_SYS", FormatString(g_tStrings.STR_MSG_CURRENT_ROLLQUALITY, g_tStrings.STR_ROLLQUALITY_GREEN))
		elseif arg3 == 3 then
			OutputMessage("MSG_SYS", FormatString(g_tStrings.STR_MSG_CURRENT_ROLLQUALITY, g_tStrings.STR_ROLLQUALITY_BLUE))
		elseif arg3 == 4 then
			OutputMessage("MSG_SYS", FormatString(g_tStrings.STR_MSG_CURRENT_ROLLQUALITY, g_tStrings.STR_ROLLQUALITY_PURPLE))
		elseif arg3 == 5 then
			OutputMessage("MSG_SYS", FormatString(g_tStrings.STR_MSG_CURRENT_ROLLQUALITY, g_tStrings.STR_ROLLQUALITY_NACARAT))
		else
			Trace("PARTY_ROLL_QUALITY_CHANGED changed to a unkown ROLLQUALITY!\n")
		end		
		
		local hTeam = GetClientTeam()
		if hTeam.nCamp ~= CAMP.NEUTRAL then
			OutputMessage("MSG_SYS", g_tStrings.STR_TEAM_CAMP_MSG_NEW)
		end

	elseif event == "PARTY_LOOT_MODE_CHANGED" then
		if arg1 == PARTY_LOOT_MODE.FREE_FOR_ALL then
			OutputMessage("MSG_SYS", FormatString(g_tStrings.STR_MSG_LOOTMODE_CHANGED, g_tStrings.STR_LOOTMODE_FREE_FOR_ALL))
		elseif arg1 == PARTY_LOOT_MODE.DISTRIBUTE then
			OutputMessage("MSG_SYS", FormatString(g_tStrings.STR_MSG_LOOTMODE_CHANGED, g_tStrings.STR_LOOTMODE_DISTRIBUTE))
			OutputMessage("MSG_SYS", g_tStrings.STR_MSG_DISTRIBUTE_WARNING)
		elseif arg1 == PARTY_LOOT_MODE.GROUP_LOOT then
			OutputMessage("MSG_SYS", FormatString(g_tStrings.STR_MSG_LOOTMODE_CHANGED, g_tStrings.STR_LOOTMODE_GROUP_LOOT))
		else
			Trace("PARTY_LOOT_MODE_CHANGED changed to a unkown mode!\n")
		end
	elseif event == "PARTY_ROLL_QUALITY_CHANGED" then
		if arg1 == 2 then
			OutputMessage("MSG_SYS", FormatString(g_tStrings.STR_MSG_ROLLQUALITY_CHANGED, g_tStrings.STR_ROLLQUALITY_GREEN))
		elseif arg1 == 3 then
			OutputMessage("MSG_SYS", FormatString(g_tStrings.STR_MSG_ROLLQUALITY_CHANGED, g_tStrings.STR_ROLLQUALITY_BLUE))
		elseif arg1 == 4 then
			OutputMessage("MSG_SYS", FormatString(g_tStrings.STR_MSG_ROLLQUALITY_CHANGED, g_tStrings.STR_ROLLQUALITY_PURPLE))
		elseif arg1 == 5 then
			OutputMessage("MSG_SYS", FormatString(g_tStrings.STR_MSG_ROLLQUALITY_CHANGED, g_tStrings.STR_ROLLQUALITY_NACARAT))
		else
			Trace("PARTY_ROLL_QUALITY_CHANGED changed to a unkown ROLLQUALITY!\n")
		end
	elseif event == "TEAM_AUTHORITY_CHANGED" then
		local szMsg = nil
		local szName = GetTeammateName(arg3)
		if arg0 == TEAM_AUTHORITY_TYPE.LEADER then
			szMsg = FormatString(g_tStrings.STR_MSG_PARTY_LEADER_CHANGED, szName)
		elseif arg0 == TEAM_AUTHORITY_TYPE.DISTRIBUTE then
			szMsg = FormatString(g_tStrings.STR_MSG_PARTY_SET_DISTRIBUTE_MAN, szName)
		elseif arg0 == TEAM_AUTHORITY_TYPE.MARK then
			szMsg = FormatString(g_tStrings.STR_MSG_PARTY_SET_MARK_MAN, szName)
		end
		if szMsg then
			OutputMessage("MSG_SYS", szMsg)
		end
	elseif event == "PARTY_SET_FORMATION_LEADER" then
		if Teammate.IsInMyGroup(arg0) then
			local szName = GetTeammateName(arg0)
			OutputMessage("MSG_SYS", FormatString(g_tStrings.STR_MSG_PARTY_SET_FORMATION_LEADER, szName))
		end
	end
end;

m_tLastPartyMarkList = {};
UpdatePartyMark = function(bRefresh)
	local tMarkList = {}
	local hPlayer = GetClientPlayer()
	if hPlayer.IsInParty() then
		tMarkList = GetClientTeam().GetTeamMark() or {}
	end

	if bRefresh then
		GlobalEventHandler.m_tLastPartyMarkList = {}
	end

	for dwID, dwMarkID in pairs(tMarkList) do
		if GlobalEventHandler.m_tLastPartyMarkList[dwID] then
			if GlobalEventHandler.m_tLastPartyMarkList[dwID] ~= dwMarkID then
				GlobalEventHandler.UpdateTitleEffect(dwID)
			end
			GlobalEventHandler.m_tLastPartyMarkList[dwID] = nil
		else
			GlobalEventHandler.UpdateTitleEffect(dwID)
		end
	end

	for dwID, dwMarkID in pairs(GlobalEventHandler.m_tLastPartyMarkList) do
		GlobalEventHandler.UpdateTitleEffect(dwID)
	end

	GlobalEventHandler.m_tLastPartyMarkList = tMarkList
end;

UpdateTitleEffect = function(dwID)
	if IsPlayer(dwID) then
		UpdatePlayerTitleEffect(dwID)
	else
		UpdateNpcTitleEffect(dwID)
	end
end;

OnShopOpenShopEvent=function(event)
	if event == "SHOP_OPENSHOP" then
		OpenShop(arg0, arg1, arg2, arg3, arg4)
	end
end;

OnNpcTalk=function(event)
    local dwNpcID = arg0
    local szText = Table_GetSmartDialog(arg3, arg1)
    local nChannel = arg2
	local szChannel = nil
	local szMsg = nil
	local hNpc = GetNpc(dwNpcID)
	local szName = Table_GetNpcTemplateName(hNpc.dwTemplateID)
    if nChannel == PLAYER_TALK_CHANNEL.WHISPER then
    	szChannel = "MSG_NPC_WHISPER"
    	szMsg = "["..szName.."]"..g_tStrings.STR_TALK_HEAD_WHISPER..szText.."\n"
    elseif nChannel == PLAYER_TALK_CHANNEL.NEARBY then
    	szChannel = "MSG_NPC_NEARBY"
    	szMsg = "["..szName.."]"..g_tStrings.STR_TALK_HEAD_SAY..szText.."\n"
    elseif nChannel == PLAYER_TALK_CHANNEL.SENCE then
    	szChannel = "MSG_NPC_YELL"
    	szMsg = "["..szName.."]"..g_tStrings.STR_TALK_HEAD_SAY2..szText.."\n"
    else
    	szChannel = "MSG_NPC_NEARBY"
    	szMsg = "["..szName.."]"..g_tStrings.STR_TALK_HEAD_SAY..szText.."\n"
    end

    if szChannel and szMsg then
    	OutputMessage(szChannel, szMsg)
    end

end;

OnSysMsgEvent=function(event)
	if arg0 == "UI_OME_SKILL_CAST_LOG" then
		GlobalEventHandler.OnSkillCast(arg1, arg2, arg3);
	elseif arg0 == "UI_OME_SKILL_CAST_RESPOND_LOG" then
		GlobalEventHandler.OnSkillCastRespond(arg1, arg2, arg3, arg4);
	elseif arg0 == "UI_OME_SKILL_EFFECT_LOG" then
		GlobalEventHandler.OnSkillEffectLog(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9);
	elseif arg0 == "UI_OME_SKILL_BLOCK_LOG" then
		GlobalEventHandler.OnSkillBlockLog(arg1, arg2, arg3, arg4, arg5, arg6)
	elseif arg0 == "UI_OME_SKILL_SHIELD_LOG" then
		GlobalEventHandler.OnSkillShieldLog(arg1, arg2, arg3, arg4, arg5)
	elseif arg0 == "UI_OME_SKILL_MISS_LOG" then
		GlobalEventHandler.OnSkillMissLog(arg1, arg2, arg3, arg4, arg5)
	elseif arg0 == "UI_OME_SKILL_HIT_LOG" then
	    GlobalEventHandler.OnSkillHitLog(arg1, arg2, arg3, arg4, arg5);
	elseif arg0 == "UI_OME_SKILL_DODGE_LOG" then
		GlobalEventHandler.OnSkillDodgeLog(arg1, arg2, arg3, arg4, arg5);
	elseif arg0 == "UI_OME_COMMON_HEALTH_LOG" then
		GlobalEventHandler.OnCommonHealthLog(arg1, arg2);
	elseif arg0 == "UI_OME_EXP_LOG" then
		GlobalEventHandler.OnExpLog(arg1, arg2);
	elseif arg0 == "UI_OME_BUFF_LOG" then
		GlobalEventHandler.OnBuffLog(arg1, arg2, arg3, arg4, arg5);
	elseif arg0 == "UI_OME_BUFF_IMMUNITY" then
		GlobalEventHandler.OnBuffImmunity(arg1, arg2, arg3, arg4)
	elseif arg0 == "UI_OME_DEATH_NOTIFY" then
		GlobalEventHandler.OnDeathNotify(arg1, arg2, arg3);
	elseif arg0 == "UI_OME_SKILL_RESPOND" then
		GlobalEventHandler.OnSkillRespond(arg1);
	elseif arg0 == "UI_OME_ITEM_RESPOND" then
		GlobalEventHandler.OnItemRespond(arg1);
	elseif arg0 == "UI_OME_ADD_ITEM_RESPOND" then
		GlobalEventHandler.OnAddItemRespond(arg1);
    elseif arg0 == "UI_OME_USE_ITEM_RESPOND" then
		GlobalEventHandler.OnUseItemRespond(arg1);
	elseif arg0 == "UI_OME_TRADING_RESPOND" then
		GlobalEventHandler.OnTradingRespond(arg1);
	elseif arg0 == "UI_OME_SHOP_RESPOND" then
		GlobalEventHandler.OnShopRespond(arg1, arg2);
	elseif arg0 == "UI_OME_MAIL_RESPOND" then
		GlobalEventHandler.OnMailRespond(arg1);
	elseif arg0 == "UI_OME_MAIL_COUNT_INFO" then
		GlobalEventHandler.OnMailCountInfo(arg1, arg2)
	elseif arg0 == "UI_OME_CHAT_RESPOND" then
		GlobalEventHandler.ResponseMsgOnTalkError(arg1);
	elseif arg0 == "UI_OME_LOOT_RESPOND" then
		GlobalEventHandler.OnLootRespond(arg1);
	elseif arg0 == "UI_OME_CRAFT_RESPOND" then
		GlobalEventHandler.OnCraftRespond(arg1, arg2, arg3, arg4, arg5);
	elseif arg0 == "UI_OME_QUEST_RESPOND" then
		GlobalEventHandler.OnQuestRespond(arg1, arg2);
	elseif arg0 == "UI_OME_APPLY_DUEL" then
		GlobalEventHandler.OnApplyDuelRespond(arg1, arg2);
	elseif arg0 == "UI_OME_ACCEPT_DUEL" then
		GlobalEventHandler.OnAcceptDuelRespond(arg1, arg2);

		GlobalEventHandler.nEndFrame = arg3
		GlobalEventHandler.nLastShowSecond = -1;
		local nLeftSeconds = (GlobalEventHandler.nEndFrame - GetLogicFrameCount()) / 16;
		nLeftSeconds = math.ceil(nLeftSeconds)
		if nLeftSeconds > 0 and GlobalEventHandler.nLastShowSecond ~= nLeftSeconds then
		    OutputMessage("MSG_ANNOUNCE_YELLOW", FormatString(g_tStrings.STR_PK_START_DUEL_CALCULAGRAPH, nLeftSeconds));
		    GlobalEventHandler.nLastShowSecond = nLeftSeconds
		end

	elseif arg0 == "UI_OME_REFUSE_DUEL" then
		GlobalEventHandler.OnRefuseDuelRespond(arg1, arg2);
	elseif arg0 == "UI_OME_START_DUEL" then
		--PK开始倒计时结束
		GlobalEventHandler.nEndFrame = 0
		GlobalEventHandler.nLastShowSecond = -1

		GlobalEventHandler.OnStartDuelRespond(arg1);
	elseif arg0 == "UI_OME_CANCEL_DUEL" then
		--PK开始倒计时结束
		GlobalEventHandler.nEndFrame = 0
	    GlobalEventHandler.nLastShowSecond = -1
		GlobalEventHandler.OnCancelDuelRespond(arg1);
	elseif arg0 == "UI_OME_WIN_DUEL" then
		GlobalEventHandler.OnWinDuelRespond(arg1, arg2);
	elseif arg0 == "UI_OME_FINISH_DUEL" then
		GlobalEventHandler.OnFinishDuelRespond();
	elseif arg0 == "UI_OME_APPLY_SLAY" then
		GlobalEventHandler.OnApplySlayRespond(arg1, arg2);
	elseif arg0 == "UI_OME_START_SLAY" then
		GlobalEventHandler.OnStartSlayRespond(arg1);
	elseif arg0 == "UI_OME_CLOSE_SLAY" then
		GlobalEventHandler.OnCloseSlayRespond(arg1, arg2);
	elseif arg0 == "UI_OME_SLAY_CLOSED" then
		GlobalEventHandler.OnSlayClosedRespond(arg1);
	elseif arg0 == "UI_OME_SYS_ERROR" then
		OutputMessage("MSG_ANNOUNCE_RED", arg1);
	elseif arg0 == "UI_OME_LEVEL_UP" then
		GlobalEventHandler.OnLevelUpMessage()
	elseif arg0 == "UI_OME_FELLOWSHIP_RESPOND" then
		GlobalEventHandler.OnFellowshipMessage(arg1);
	elseif arg0 == "UI_OME_LEARN_PROFESSION" then
		GlobalEventHandler.OnLearnProfession(arg1);
	elseif arg0 == "UI_OME_LEARN_BRANCH" then
		GlobalEventHandler.OnLearnBranch(arg1, arg2);
	elseif arg0 == "UI_OME_FORGET_PROFESSION" then
		GlobalEventHandler.OnForgetProfession(arg1);
	elseif arg0 == "UI_OME_ADD_PROFESSION_PROFICIENCY" then
		GlobalEventHandler.OnAddProfessionProficiency(arg1, arg2);
	elseif arg0 == "UI_OME_PROFESSION_LEVEL_UP" then
		GlobalEventHandler.OnProfessionLevelUp(arg1, arg2);
	elseif arg0 == "UI_OME_SET_PROFESSION_MAX_LEVEL" then
		GlobalEventHandler.OnSetProfessionMaxLevel(arg1,arg2);
	elseif arg0 == "UI_OME_LEARN_RECIPE" then
		GlobalEventHandler.OnLearnRecipe(arg1, arg2)
	elseif arg0 == "UI_OME_PK_RESPOND" then
		GlobalEventHandler.OnPKRespond(arg1);
	elseif arg0 == "UI_OME_BANISH_PLAYER" then
		if not IsInBattleField() and not IsInArena() then
			GlobalEventHandler.OnBanishPlayer(arg1, arg2);
		elseif arg1 == BANISH_CODE.MAP_UNLOAD then
			OnBattleFieldMapUnload(arg2)
		end
	elseif arg0 == "UI_OME_CHECK_OPNE_DOODAD" then
	    GlobalEventHandler.OnCheckOpenDoodad();
	end
end;

----------------------- 生活技能学习提示 -------------------------
OnLearnProfession=function(nProfessionID)
	local profession = GetProfession(nProfessionID)
	if profession and nProfessionID ~= 8 and nProfessionID ~= 9 and nProfessionID ~= 10 and nProfessionID ~= 11 then
	    --不显示阅读,佛学，道学，杂集的学习
		OutputMessage("MSG_SYS", FormatString(g_tStrings.STR_LEARN_PROFESSION, Table_GetProfessionName(nProfessionID)))
	end

	FireHelpEvent("OnLearnCraft", nProfessionID)
end;

OnLearnBranch=function(nProfessionID, nBranchID)
	local profession = GetProfession(nProfessionID);

	if profession then
		local szBranchName = Table_GetBranchName(nProfessionID, nBranchID);
		if szBranchName then
			OutputMessage("MSG_SYS", FormatString(g_tStrings.STR_LEARN_BRANCH, Table_GetProfessionName(nProfessionID), szBranchName))
		end
	end
end;

OnForgetProfession=function(nProfessionID)
	local profession = GetProfession(nProfessionID);

	if profession then
		OutputMessage("MSG_SYS", FormatString(g_tStrings.STR_FORGET_PROFESSION, Table_GetProfessionName(nProfessionID)))
	end
end;

OnAddProfessionProficiency=function(nProfessionID, nExp)
	local profession = GetProfession(nProfessionID);

	if profession then
		OutputMessage("MSG_SYS", FormatString(g_tStrings.STR_ADD_PROFESSION_PROFICIENCY, Table_GetProfessionName(nProfessionID), nExp))
	end
end;

OnProfessionLevelUp=function(nProfessionID, nNewLevel)
	local profession = GetProfession(nProfessionID)
	if profession then
		OutputMessage("MSG_SYS", FormatString(g_tStrings.STR_PROFESSION_LEVEL_UP, Table_GetProfessionName(nProfessionID), nNewLevel))

		local hPlayer = GetClientPlayer()
		if hPlayer then
			local nMaxLevel = hPlayer.GetProfessionMaxLevel(nProfessionID)
			FireHelpEvent("OnCraftLevelUp", nProfessionID, nNewLevel, nMaxLevel)
		end
	end
end;

OnSetProfessionMaxLevel=function(nProfessionID, nNewMaxLevel)
	if nProfessionID == 8 or nProfessionID == 9 or nProfessionID == 10 or nProfessionID == 11 then
		return
	end

	local profession = GetProfession(nProfessionID);

	if profession then
		local szLevelName = g_tStrings.tProfessionLevelName[nNewMaxLevel];
		if szLevelName then
			OutputMessage("MSG_SYS", FormatString(g_tStrings.STR_SET_PROFESSION_MAX_LEVEL, szLevelName, Table_GetProfessionName(nProfessionID)))
		end

		FireHelpEvent("OnProfessionMaxLevelUp", nProfessionID, nNewMaxLevel)
	end
end;

OnLearnRecipe=function(nCraftID, nRecipeID)
	OutputMessage("MSG_SYS", FormatString(g_tStrings.STR_LEARN_RECIPE, Table_GetRecipeName(nCraftID, nRecipeID)));
	-- FireHelpEvent("OnLearnRecipe", nCraftID, nRecipeID) -- 新手帮助内容还未实现
end;

OnReputationRespond = function(dwReputeID, nAddNum)
	local szMsg = ""
	local aRepu = g_tReputation.tReputationTable[dwReputeID]
	if not aRepu then
		return
	end

	if nAddNum >= 0 then
		OutputMessage("MSG_REPUTATION", FormatString(g_tStrings.STR_MSG_REPUTE_ADD, aRepu.szName, nAddNum));
	else
		OutputMessage("MSG_REPUTATION", FormatString(g_tStrings.STR_MSG_REPUTE_DEL, aRepu.szName, -nAddNum));
	end
end;

OnPKRespond = function(dwPKCode)
	local szMsg = g_tStrings.tPKResult[dwPKCode];
	if szMsg then
		OutputMessage("MSG_ANNOUNCE_RED", szMsg);
	end
end;

OnBanishPlayer = function(nBanishCode, nLeftSeconds)
	if arg1 == BANISH_CODE.MAP_REFRESH then
		OpenBanishPanel(arg2, "refresh_copy")
	elseif arg1 == BANISH_CODE.NOT_IN_MAP_OWNER_PARTY then
		OpenBanishPanel(arg2, "party_copy")
	elseif arg1 == BANISH_CODE.CANCEL_BANISH then
		CloseBanishPanel()
	elseif arg1 == BANISH_CODE.NOT_IN_MAP_OWNER_TONG then
		OpenBanishPanel(arg2, "guild")
	end
end;

OnCheckOpenDoodad = function()
    OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_CHECK_OPEN_DOODAD)
end;

OnLevelUpMessage=function()
--[[
	local nLevel = arg1
	local nStrength = arg2
	local nAgility = arg3
	local nVigor = arg4
	local nSpirit = arg5
	local nSpunk = arg6
	local nMaxLife = arg7
	local nMaxMana = arg8
	local nMaxRage = arg9
	local nMaxStamina = arg10
	local nMaxThew = arg11

	if nLevel ~= 0 then	OutputMessage("MSG_SYS", FormatString(g_tStrings.STR_MSG_LEVEL_UP, nLevel)) end
	if nStrength ~= 0 then OutputMessage("MSG_SYS", FormatString(g_tStrings.STR_MSG_LEVEL_UP_STRENGTH, nStrength)) end
	if nVigor ~= 0 then OutputMessage("MSG_SYS", FormatString(g_tStrings.STR_MSG_LEVEL_UP_VIGOR, nVigor)) end
	if nSpirit ~= 0 then OutputMessage("MSG_SYS", FormatString(g_tStrings.STR_MSG_LEVEL_UP_SPIRIT, nSpirit)) end
	if nAgility ~= 0 then OutputMessage("MSG_SYS", FormatString(g_tStrings.STR_MSG_LEVEL_UP_AGILITY, nAgility)) end
	if nSpunk ~= 0 then OutputMessage("MSG_SYS", FormatString(g_tStrings.STR_MSG_LEVEL_UP_SPUNK, nSpunk)) end
	if nMaxLife ~= 0 then OutputMessage("MSG_SYS", FormatString(g_tStrings.STR_MSG_LEVEL_UP_MAX_LIFE, nMaxLife)) end
	if nMaxMana ~= 0 then OutputMessage("MSG_SYS", FormatString(g_tStrings.STR_MSG_LEVEL_UP_MAX_MANA, nMaxMana)) end
	if nMaxStamina ~= 0 then OutputMessage("MSG_SYS", FormatString(g_tStrings.STR_MSG_LEVEL_UP_MAX_STAMINA, nMaxStamina)) end
	if nMaxThew ~= 0 then OutputMessage("MSG_SYS", FormatString(g_tStrings.STR_MSG_LEVEL_UP_MAX_THEW, nMaxThew)) end

	if nMaxRage ~= 0 then OutputMessage("MSG_SYS", FormatString(g_tStrings.STR_MSG_LEVEL_UP_MAX_RAGE, nMaxRage)) end
]]
end;

--------------------------------- PK提示 --------------------------------------------
OnApplyDuelRespond=function(dwSrcPlayerID, dwDstPlayerID)
	local SrcPlayer = GetPlayer(dwSrcPlayerID)
	local DstPlayer = GetPlayer(dwDstPlayerID)
	local dwClientID = GetClientPlayer().dwID
	if dwSrcPlayerID == dwClientID or dwDstPlayerID == dwClientID then
		FireHelpEvent("OnApplyFight")
	end
	if SrcPlayer and DstPlayer then
		OutputMessage("MSG_SYS", FormatString(g_tStrings.STR_PK_APPLY_DUEL, SrcPlayer.szName, DstPlayer.szName))
	end

	local ClientPlayer = GetClientPlayer();
	if ClientPlayer.dwID == dwSrcPlayerID then
		ClientPlayer.Talk(PLAYER_TALK_CHANNEL.NEARBY, "", {{type = "text", text = g_tStrings.STR_PK_APPLY_DUEL_EXT[Random(1, #g_tStrings.STR_PK_APPLY_DUEL_EXT)]}})
		DoAction(0, 10150);
	end
end;

OnAcceptDuelRespond=function(dwSrcPlayerID, dwDstPlayerID)
	local SrcPlayer = GetPlayer(dwSrcPlayerID)
	local DstPlayer = GetPlayer(dwDstPlayerID)

	if SrcPlayer and DstPlayer then
		OutputMessage("MSG_SYS", FormatString(g_tStrings.STR_PK_ACCEPT_DUEL, SrcPlayer.szName, DstPlayer.szName))
	end

	local ClientPlayer = GetClientPlayer();
	if ClientPlayer.dwID == dwSrcPlayerID then
		ClientPlayer.Talk(PLAYER_TALK_CHANNEL.NEARBY, "", {{type = "text", text = g_tStrings.STR_PK_ACCEPT_DUEL_EXT[Random(1, #g_tStrings.STR_PK_ACCEPT_DUEL_EXT)]}})
		DoAction(0, 10150);
	end
end;

OnRefuseDuelRespond=function(dwSrcPlayerID, dwDstPlayerID)
	local SrcPlayer = GetPlayer(dwSrcPlayerID)
	local DstPlayer = GetPlayer(dwDstPlayerID)
	local szMsg = g_tStrings.STR_PK_CANCEL_DUEL

	if SrcPlayer and DstPlayer then
	    szMsg = FormatString(g_tStrings.STR_PK_REFUSE_DUEL, SrcPlayer.szName, DstPlayer.szName);
	end

	OutputMessage("MSG_SYS", szMsg)
end;

OnStartDuelRespond=function(dwTargetPlayerID)
	OutputMessage("MSG_ANNOUNCE_YELLOW", g_tStrings.STR_PK_START_DUEL)
end;

OnCancelDuelRespond=function(dwTargetPlayerID)
	OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_PK_CANCEL_DUEL)
end;

OnWinDuelRespond=function(dwWinnerID, dwLosserID)
	local Winner = GetPlayer(dwWinnerID)
	local Losser = GetPlayer(dwLosserID)
	local ClientPlayer = GetClientPlayer();

	if Losser and Losser.dwID == ClientPlayer.dwID then
		local szMsg = FormatString(g_tStrings.STR_PK_LOSS_ANOTHER, Losser.szName)
		if Winner then
			szMsg = FormatString(g_tStrings.STR_PK_LOSS_DUEL, Losser.szName, Winner.szName);
		end
		OutputMessage("MSG_SYS", szMsg)
		ClientPlayer.Talk(PLAYER_TALK_CHANNEL.NEARBY, "", {{type = "text", text = g_tStrings.STR_PK_LOSS_DUEL_EXT[Random(1, #g_tStrings.STR_PK_LOSS_DUEL_EXT)]}})
		DoAction(0, 10150)
	elseif Winner then
		local szMsg = FormatString(g_tStrings.STR_PK_WIN_ANOTHER, Winner.szName)
		if Losser then
			szMsg = FormatString(g_tStrings.STR_PK_WIN_DUEL, Winner.szName, Losser.szName)
		end
		OutputMessage("MSG_SYS", szMsg)
	end

	if Winner and Winner.dwID == ClientPlayer.dwID then
		ClientPlayer.Talk(PLAYER_TALK_CHANNEL.NEARBY, "", {{type = "text", text = g_tStrings.STR_PK_WIN_DUEL_EXT[Random(1, #g_tStrings.STR_PK_WIN_DUEL_EXT)]}})
	end
end;

OnFinishDuelRespond = function()
	OutputMessage("MSG_SYS", g_tStrings.STR_PK_FINISH_DUEL)
end;

GetPlayerName=function(dwPlayerID)
    local player = GetPlayer(dwPlayerID)

	if not player then
	    return
	end

	local szName = player.szName

	if dwPlayerID == GetClientPlayer().dwID then
	    szName = g_tStrings.STR_NAME_YOU
	end

	return szName
end;

OnApplySlayRespond=function(dwPlayerID, nSeconds)
	local szName = GlobalEventHandler.GetPlayerName(dwPlayerID)

	if szName then
        OutputMessage("MSG_SYS", FormatString(g_tStrings.STR_PK_APPLY_SLAY, szName, nSeconds))
    end
end;

OnStartSlayRespond=function(dwPlayerID)
	local szName = GlobalEventHandler.GetPlayerName(dwPlayerID)

	if szName and szName ~= "" then
	    OutputMessage("MSG_SYS", FormatString(g_tStrings.STR_PK_START_SLAY, szName))
	end
end;

OnCloseSlayRespond=function(dwPlayerID, nSeconds)
	local szName = GlobalEventHandler.GetPlayerName(dwPlayerID)

	if szName then
	    local szMsg = FormatString(g_tStrings.STR_PK_CLOSE_SLAY, szName, nSeconds);
	    OutputMessage("MSG_SYS", szMsg)
	end
end;

OnSlayClosedRespond=function(dwPlayerID)
    local szName = GlobalEventHandler.GetPlayerName(dwPlayerID)

	if szName then
	    OutputMessage("MSG_SYS", FormatString(g_tStrings.STR_PK_SLAY_CLOSED, szName))
	end
end;


--------------------------------- 战斗日志 ----------------------------------------------------------------------
GetCasterName=function(dwCharacter)
	local szCasterName = GlobalEventHandler.GetCharacterTipInfo(dwCharacter)
	if szCasterName == g_tStrings.STR_NAME_UNKNOWN then
		szCasterName = ""
	else
		szCasterName = szCasterName..g_tStrings.STR_PET_SKILL_LOG
	end
	return szCasterName
end;

GetCharacterTipInfo=function(dwCharacter)
    local Player = GetClientPlayer()
    local szCharacter = g_tStrings.STR_NAME_UNKNOWN;
    
    if IsPlayer(dwCharacter) then
		Character = GetPlayer(dwCharacter);
	else
		Character = GetNpc(dwCharacter);
	end
    if not Character then
		return szCharacter;
	end
    
    local szMidString = g_tStrings.STR_PET_SKILL_LOG
	if (dwCharacter == Player.dwID) then
		szCharacter = g_tStrings.STR_NAME_YOU;
	elseif not IsPlayer(dwCharacter) and Character.dwEmployer ~= 0  then -- is Pet
        if (Character.dwEmployer == Player.dwID) then
            szCharacter = g_tStrings.STR_NAME_YOU..szMidString..Character.szName;
        else
            local Employer = GetPlayer(Character.dwEmployer)
            if Employer then
                szCharacter = Employer.szName..szMidString..Character.szName
            else
                szCharacter = g_tStrings.STR_SOME_BODY..szMidString..Character.szName
            end
        end
    else
        szCharacter = Character.szName;
	end
    return szCharacter
end;

OnSkillCast=function(dwCaster, dwSkillID, dwLevel)
	local ClientPlayer = GetClientPlayer()
	if not ClientPlayer then
		return
	end

    local szCasterName = GlobalEventHandler.GetCharacterTipInfo(dwCaster)
	local szSkillName = Table_GetSkillName(dwSkillID, dwLevel)
	if not szSkillName then
		Trace("OnSkillCast:Cannot get skill name (dwSkillID = "..dwSkillID..", nLevel = "..nLevel..")\n")
		return
	end

	local szMsg = FormatString(g_tStrings.STR_SKILL_CAST_LOG, szCasterName, szSkillName)
	local szChannel = GlobalEventHandler.GetChannelOnSkillCast(dwCaster)
	if not szChannel then
		Trace("OnSkillCast Get Skill Channel failed!\n")
		return
	end
	OutputMessage(szChannel, szMsg)
end;

OnSkillCastRespond=function(dwCaster, dwSkillID, dwLevel, nRespond)
	local ClientPlayer = GetClientPlayer()
	if not ClientPlayer then
		return
	end
    
    local szCasterName = GlobalEventHandler.GetCharacterTipInfo(dwCaster)
	local szSkillName = Table_GetSkillName(dwSkillID, dwLevel)
	if not szSkillName then
		Trace("OnSkillCast:Cannot get skill name (dwSkillID = "..dwSkillID..", nLevel = "..nLevel..")\n")
		return
	end

	szRespond = GlobalEventHandler.GetSkillRespondText(nRespond)

	local szMsg = FormatString(g_tStrings.STR_SKILL_CAST_RESPOND_LOG, szCasterName, szSkillName, szRespond)
	local szChannel = GlobalEventHandler.GetChannelOnSkillCastRespond(dwCaster)
	if not szChannel then
		Trace("OnSkillCastRespond Get Skill Channel failed!\n")
		return
	end

	OutputMessage(szChannel, szMsg)
end;

OnSkillEffectLog=function(dwCaster, dwTarget, bReact, nEffectType, dwID, dwLevel, bCriticalStrike, nCount, tResult)
	if nCount <= 2 then
		return
	end
	
	local nTotal = 0
	local szDamage = ""
	local nValue = tResult[SKILL_RESULT_TYPE.PHYSICS_DAMAGE]
	if nValue and nValue > 0 then
		if szDamage ~= "" then
			szDamage = szDamage..g_tStrings.STR_COMMA
		end	
		nTotal = nTotal + nValue
		szDamage = szDamage..FormatString(g_tStrings.SKILL_DAMAGE, nValue, g_tStrings.STR_SKILL_PHYSICS_DAMAGE)
	end
	
	nValue = tResult[SKILL_RESULT_TYPE.SOLAR_MAGIC_DAMAGE]
	if nValue and nValue > 0 then
		if szDamage ~= "" then
			szDamage = szDamage..g_tStrings.STR_COMMA
		end
		nTotal = nTotal + nValue
		szDamage = szDamage..FormatString(g_tStrings.SKILL_DAMAGE, nValue, g_tStrings.STR_SKILL_SOLAR_MAGIC_DAMAGE)
	end
	
	nValue = tResult[SKILL_RESULT_TYPE.NEUTRAL_MAGIC_DAMAGE]
	if nValue and nValue > 0 then
		if szDamage ~= "" then
			szDamage = szDamage..g_tStrings.STR_COMMA
		end
		nTotal = nTotal + nValue
		szDamage = szDamage..FormatString(g_tStrings.SKILL_DAMAGE, nValue, g_tStrings.STR_SKILL_NEUTRAL_MAGIC_DAMAGE)
	end

	nValue = tResult[SKILL_RESULT_TYPE.LUNAR_MAGIC_DAMAGE]
	if nValue and nValue > 0 then
		if szDamage ~= "" then
			szDamage = szDamage..g_tStrings.STR_COMMA
		end
		nTotal = nTotal + nValue
		szDamage = szDamage..FormatString(g_tStrings.SKILL_DAMAGE, nValue, g_tStrings.STR_SKILL_LUNAR_MAGIC_DAMAGE)
	end

	nValue = tResult[SKILL_RESULT_TYPE.POISON_DAMAGE]
	if nValue and nValue > 0 then
		if szDamage ~= "" then
			szDamage = szDamage..g_tStrings.STR_COMMA
		end
		nTotal = nTotal + nValue
		szDamage = szDamage..FormatString(g_tStrings.SKILL_DAMAGE, nValue, g_tStrings.STR_SKILL_POISON_DAMAGE)
	end
	
	if szDamage ~= "" then
		GlobalEventHandler.OnSkillDamageLog(dwCaster, dwTarget, bReact, nEffectType, dwID, dwLevel, bCriticalStrike, szDamage, tResult, nTotal)
	end
	
	nValue = tResult[SKILL_RESULT_TYPE.THERAPY]
	if nValue and nValue > 0 then
		GlobalEventHandler.OnSkillTherapyLog(dwCaster, dwTarget, nEffectType, dwID, dwLevel, bCriticalStrike, tResult)
	end

	nValue = tResult[SKILL_RESULT_TYPE.REFLECTIED_DAMAGE]
	if nValue and nValue > 0 then
		GlobalEventHandler.OnSkillReflectiedDamageLog(dwCaster, dwTarget, nValue);
	end

	nValue = tResult[SKILL_RESULT_TYPE.STEAL_LIFE]
	if nValue and nValue > 0 then
		GlobalEventHandler.OnSkillStealLifeLog(dwCaster, dwTarget, nValue);
	end

	nValue = tResult[SKILL_RESULT_TYPE.ABSORB_DAMAGE]
	if nValue and nValue > 0 then
		GlobalEventHandler.OnSkillDamageAbsorbLog(dwCaster, dwTarget, nEffectType, dwID, dwLevel, nValue);
	end

	nValue = tResult[SKILL_RESULT_TYPE.SHIELD_DAMAGE]
	if nValue and nValue > 0 then
		GlobalEventHandler.OnSkillDamageShieldLog(dwCaster, dwTarget, nEffectType, dwID, dwLevel, nValue);
	end

	nValue = tResult[SKILL_RESULT_TYPE.PARRY_DAMAGE]
	if nValue and nValue > 0 then
		GlobalEventHandler.OnSkillDamageParryLog(dwCaster, dwTarget, nEffectType, dwID, dwLevel, nValue);
	end

	nValue = tResult[SKILL_RESULT_TYPE.INSIGHT_DAMAGE]
	if nValue and nValue > 0 then
		GlobalEventHandler.OnSkillDamageInsightLog(dwCaster, dwTarget, nEffectType, dwID, dwLevel, nValue);
	end	
	
	nValue = tResult[SKILL_RESULT_TYPE.TRANSFER_LIFE]
	if nValue and nValue > 0 then
		GlobalEventHandler.OnSkillDamageTransferLog(dwCaster, dwTarget, nEffectType, dwID, dwLevel, nValue, SKILL_RESULT_TYPE.TRANSFER_LIFE)
	end	
	
	nValue = tResult[SKILL_RESULT_TYPE.TRANSFER_MANA]
	if nValue and nValue > 0 then
		GlobalEventHandler.OnSkillDamageTransferLog(dwCaster, dwTarget, nEffectType, dwID, dwLevel, nValue, SKILL_RESULT_TYPE.TRANSFER_MANA)
	end	
end;

---------------------------------- 技能伤害 ---------------------------------------------------------------------

g_DamageType = {
	[SKILL_RESULT_TYPE.PHYSICS_DAMAGE]     		= g_tStrings.STR_SKILL_PHYSICS_DAMAGE;
	[SKILL_RESULT_TYPE.SOLAR_MAGIC_DAMAGE] 		= g_tStrings.STR_SKILL_SOLAR_MAGIC_DAMAGE;
	[SKILL_RESULT_TYPE.NEUTRAL_MAGIC_DAMAGE] 	= g_tStrings.STR_SKILL_NEUTRAL_MAGIC_DAMAGE;
	[SKILL_RESULT_TYPE.LUNAR_MAGIC_DAMAGE] 		= g_tStrings.STR_SKILL_LUNAR_MAGIC_DAMAGE;
	[SKILL_RESULT_TYPE.POISON_DAMAGE] 			= g_tStrings.STR_SKILL_POISON_DAMAGE;
	[SKILL_RESULT_TYPE.REFLECTIED_DAMAGE] 		= g_tStrings.STR_SKILL_REFLECTIED_DAMAGE;
};

g_TransferType = {
	[SKILL_RESULT_TYPE.TRANSFER_LIFE] = g_tStrings.STR_SKILL_LIFE;
	[SKILL_RESULT_TYPE.TRANSFER_MANA] = g_tStrings.STR_SKILL_MANA,
};

OnSkillDamageLog=function(dwCaster, dwTarget, bReact, nType, dwID, nLevel, bCriticalStrike, szDamage, tResult, nTotalDamage)
    local szCasterName = GlobalEventHandler.GetCasterName(dwCaster)
    local szTargetName = GlobalEventHandler.GetCharacterTipInfo(dwTarget)
    
    if dwCaster == dwTarget then
        szTargetName = g_tStrings.STR_NAME_OWN
    end
    
	local szSkillName = nil;
	if nType == SKILL_EFFECT_TYPE.SKILL then
		szSkillName = Table_GetSkillName(dwID, nLevel);
	elseif nType == SKILL_EFFECT_TYPE.BUFF then
		szSkillName = Table_GetBuffName(dwID, nLevel);
	end

	if not szSkillName then
		szSkillName = g_tStrings.STR_UNKOWN_SKILL;
	end

	local szCriticalStrike = "";

	if bCriticalStrike then
		szCriticalStrike = g_tStrings.STR_SKILL_CRITICALSTRIKE;
	end

	local nEffectDamage = tResult[SKILL_RESULT_TYPE.EFFECTIVE_DAMAGE] or 0
	
	local szMsg
	if nTotalDamage == nEffectDamage then
		szMsg = FormatString(g_tStrings.SKILL_DAMAGE_LOG,
			szCasterName, szSkillName, szCriticalStrike, szTargetName, szDamage)
	else
		szMsg = FormatString(g_tStrings.SKILL_EFFECT_DAMAGE_LOG,
			szCasterName, szSkillName, szCriticalStrike, szTargetName, szDamage, nEffectDamage)
	end
	local szChannel = GlobalEventHandler.GetChannelOnDamage(dwCaster, dwTarget)
	if szChannel == nil then
		Trace("OnSkillDamageLog Get Skill Channel failed!\n")
		return
	end
	OutputMessage(szChannel, szMsg);
end;


-- 伤害被反弹
OnSkillReflectiedDamageLog=function(dwCaster, dwTarget, nDamage)
    local szCasterName = GlobalEventHandler.GetCharacterTipInfo(dwCaster)
    local szTargetName = GlobalEventHandler.GetCharacterTipInfo(dwTarget)
    
	local szMsg = FormatString(g_tStrings.STR_SKILL_REFLECTIED_DAMAGE_LOG_MSG, szTargetName, szCasterName, nDamage)

	local szChannel = GlobalEventHandler.GetChannelOnDamage(dwCaster, dwTarget)
	if szChannel == nil then
		Trace("OnSkillReflectiedDamageLog Get Skill Channel failed!\n")
		return
	end

	OutputMessage(szChannel, szMsg)
end;


OnCommonHealthLog=function(dwTarget, nDeltaLife)
    local szTargetName = GlobalEventHandler.GetCharacterTipInfo(dwTarget)
	local szMsg = nil;
	local szChannel = nil
	if nDeltaLife < 0 then
		szMsg = FormatString(g_tStrings.STR_SKILL_COMMON_DAMAGE_LOG_MSG, szTargetName, -nDeltaLife)
		szChannel = GlobalEventHandler.GetChannelOnCommonHealth(dwTarget)
	elseif nDeltaLife > 0 then
		szMsg = FormatString(g_tStrings.STR_SKILL_COMMON_THERAPY_LOG_MSG, szTargetName, nDeltaLife)
		szChannel = GlobalEventHandler.GetChannelOnCommonHealth(dwTarget)
	end
	OutputMessage(szChannel, szMsg);
end;

--------------------------------- 技能加血 ----------------------------------------------------------------------
OnSkillTherapyLog=function(dwCaster, dwTarget, nEffectType, dwID, dwLevel, bCriticalStrike, tResult)
    local szCasterName = GlobalEventHandler.GetCasterName(dwCaster)
    local szTargetName = GlobalEventHandler.GetCharacterTipInfo(dwTarget)
	if dwCaster == dwTarget then
        szTargetName = g_tStrings.STR_NAME_OWN
    end
	
    local szSkillName = nil;

	if nEffectType == SKILL_EFFECT_TYPE.SKILL then
		szSkillName = Table_GetSkillName(dwID, dwLevel);
	elseif nEffectType == SKILL_EFFECT_TYPE.BUFF then
		szSkillName = Table_GetBuffName(dwID, dwLevel)
	end

	if not szSkillName then
		szSkillName = g_tStrings.STR_UNKOWN_SKILL
	end

	local szCriticalStrike = "";

	if bCriticalStrike then
		szCriticalStrike = g_tStrings.STR_SKILL_CRITICALSTRIKE;
	end
	
	local nTherapy = tResult[SKILL_RESULT_TYPE.THERAPY] or 0
	local nEffectTherapy = tResult[SKILL_RESULT_TYPE.EFFECTIVE_THERAPY] or 0
	
	local szMsg
	if nEffectTherapy == nTherapy then
		szMsg = FormatString(g_tStrings.SKILL_THERAPY_LOG,
			szCasterName, szSkillName, szCriticalStrike, szTargetName, nTherapy)
	else
		szMsg = FormatString(g_tStrings.SKILL_EFFECT_THERAPY_LOG,
			szCasterName, szSkillName, szCriticalStrike, szTargetName, nTherapy, nEffectTherapy)
	end

	local szChannel = GlobalEventHandler.GetChannelOnTherapy(dwCaster, dwTarget)
	if not szChannel then
		Trace("OnSkillTherapyLog Get Skill Channel failed!\n")
		return
	end
	OutputMessage(szChannel, szMsg);

end;

--偷取生命
OnSkillStealLifeLog=function(dwCaster, dwTarget, nHealth)
    local szCasterName = GlobalEventHandler.GetCharacterTipInfo(dwCaster)
    local szTargetName = GlobalEventHandler.GetCharacterTipInfo(dwTarget)

	local szMsg = FormatString(g_tStrings.STR_SKILL_STEAL_LIFE_LOG_MSG, szCasterName, szTargetName, nHealth)

	local szChannel = nil
	local player = GetClientPlayer()
	if not player then
		return
	end

	if dwCaster == player.dwID or dwTarget == player.dwID then
		szChannel = "MSG_SKILL_SELF_SKILL"
	else
		szChannel = "MSG_SKILL_PARTY_SKILL"
	end

	OutputMessage(szChannel, szMsg)

end;

-- 攻击被吸收
OnSkillDamageAbsorbLog=function(dwCaster, dwTarget, nEffectType, dwID, dwLevel, nDamage)
    local szCasterName = GlobalEventHandler.GetCasterName(dwCaster)
    local szTargetName = GlobalEventHandler.GetCharacterTipInfo(dwTarget)

    local szSkillName = nil;
	if nEffectType == SKILL_EFFECT_TYPE.SKILL then
		szSkillName = Table_GetSkillName(dwID, dwLevel);
	elseif nEffectType == SKILL_EFFECT_TYPE.BUFF then
		szSkillName = Table_GetBuffName(dwID, dwLevel)
	end

	if not szSkillName then
		szSkillName = g_tStrings.STR_NAME_UNKNOWN;
	end

	local szMsg = FormatString(g_tStrings.STR_SKILL_DAMAGE_ABSORB_LOG_MSG, szCasterName, szSkillName, szTargetName, nDamage)

 	local szChannel = GlobalEventHandler.GetChannelOnDamage(dwCaster, dwTarget)
 	if szChannel == nil then
		Trace("OnSkillDamageAbsorbLog Get Skill Channel failed!\n")
		return
 	end

	OutputMessage(szChannel, szMsg)

end;

--攻击被抵消
OnSkillDamageShieldLog=function(dwCaster, dwTarget, nEffectType, dwID, dwLevel, nDamage)
    local szCasterName = GlobalEventHandler.GetCasterName(dwCaster)
    local szTargetName = GlobalEventHandler.GetCharacterTipInfo(dwTarget)
	
    local szSkillName = nil;
	if nEffectType == SKILL_EFFECT_TYPE.SKILL then
		szSkillName = Table_GetSkillName(dwID, dwLevel);
	elseif nEffectType == SKILL_EFFECT_TYPE.BUFF then
		szSkillName = Table_GetBuffName(dwID, dwLevel)
	end

	if not szSkillName then
		szSkillName = g_tStrings.STR_NAME_UNKNOWN
	end

	local szMsg = FormatString(g_tStrings.STR_SKILL_DAMAGE_SHIELD_LOG_MSG, szCasterName, szSkillName, szTargetName, nDamage)
	local szChannel = GlobalEventHandler.GetChannelOnDamage(dwCaster, dwTarget)
	if szChannel == nil then
		Trace("OnSkillDamageShieldLog Get Skill Channel failed!\n")
		return
	end

	OutputMessage(szChannel, szMsg)

end;

--攻击被招架
OnSkillDamageParryLog=function(dwCaster, dwTarget, nEffectType, dwID, dwLevel, nDamage)
    local szCasterName = GlobalEventHandler.GetCasterName(dwCaster)
    local szTargetName = GlobalEventHandler.GetCharacterTipInfo(dwTarget)

    local szSkillName = nil;
	if nEffectType == SKILL_EFFECT_TYPE.SKILL then
		szSkillName = Table_GetSkillName(dwID, dwLevel);
	elseif nEffectType == SKILL_EFFECT_TYPE.BUFF then
		szSkillName = Table_GetBuffName(dwID, dwLevel)
	end

	if not szSkillName then
		szSkillName = g_tStrings.STR_NAME_UNKNOWN
	end

	local szMsg = FormatString(g_tStrings.STR_SKILL_DAMAGE_PARRY_LOG_MSG, szCasterName, szSkillName, szTargetName, nDamage)
	local szChannel = GlobalEventHandler.GetChannelOnDamage(dwCaster, dwTarget)
	if szChannel == nil then
		Trace("OnSkillDamageParryLog Get Skill Channel failed!\n")
		return
	end

	OutputMessage(szChannel, szMsg)

end;

--技能被识破
OnSkillDamageInsightLog=function(dwCaster, dwTarget, nEffectType, dwID, dwLevel, nDamage)
    local szCasterName = GlobalEventHandler.GetCasterName(dwCaster)
    local szTargetName = GlobalEventHandler.GetCharacterTipInfo(dwTarget)
	
    local szSkillName = nil;
	if nEffectType == SKILL_EFFECT_TYPE.SKILL then
		szSkillName = Table_GetSkillName(dwID, dwLevel);
	elseif nEffectType == SKILL_EFFECT_TYPE.BUFF then
		szSkillName = Table_GetBuffName(dwID, dwLevel)
	end

	if not szSkillName then
		szSkillName = g_tStrings.STR_NAME_UNKNOWN
	end

	local szMsg = FormatString(g_tStrings.STR_SKILL_DAMAGE_INSIGHT_LOG_MSG, szCasterName, szSkillName, szTargetName, nDamage)
	local szChannel = GlobalEventHandler.GetChannelOnDamage(dwCaster, dwTarget)
	if szChannel == nil then
		Trace("OnSkillDamageInsightLog Get Skill Channel failed!\n")
		return
	end

	OutputMessage(szChannel, szMsg)

end;

OnSkillDamageTransferLog=function(dwCaster, dwTarget, nEffectType, dwID, dwLevel, nDamage, dwTransferType)
	local szCasterName = GlobalEventHandler.GetCasterName(dwCaster)
    local szTargetName = GlobalEventHandler.GetCharacterTipInfo(dwTarget)

    local szSkillName = nil;
	if nEffectType == SKILL_EFFECT_TYPE.SKILL then
		szSkillName = Table_GetSkillName(dwID, dwLevel);
	elseif nEffectType == SKILL_EFFECT_TYPE.BUFF then
		szSkillName = Table_GetBuffName(dwID, dwLevel)
	end

	if not szSkillName then
		szSkillName = g_tStrings.STR_NAME_UNKNOWN
	end

	local szMsg = FormatString(g_tStrings.STR_SKILL_DAMAGE_TRANSFER_LOG_MSG, szCasterName, szSkillName,
		 szTargetName, nDamage, GlobalEventHandler.g_TransferType[dwTransferType])
	local szChannel = GlobalEventHandler.GetChannelOnDamage(dwCaster, dwTarget)
	if szChannel == nil then
		Trace("OnSkillDamageTransferLog Get Skill Channel failed!\n")
		return
	end

	OutputMessage(szChannel, szMsg)

end;

--技能被格挡
OnSkillBlockLog=function(dwCaster, dwTarget, nEffectType, dwID, dwLevel, dwDamageType)
    local szCasterName = GlobalEventHandler.GetCasterName(dwCaster)
    local szTargetName = GlobalEventHandler.GetCharacterTipInfo(dwTarget)

    local szSkillName = nil;

	if nEffectType == SKILL_EFFECT_TYPE.SKILL then
		szSkillName = Table_GetSkillName(dwID, dwLevel);
	elseif nEffectType == SKILL_EFFECT_TYPE.BUFF then
		szSkillName = Table_GetBuffName(dwID, dwLevel)
	end

	if not szSkillName then
		return
	end

	local szMsg = FormatString(g_tStrings.STR_SKILL_BLOCK_LOG_MSG,
		szCasterName, szSkillName, GlobalEventHandler.g_DamageType[dwDamageType], szTargetName)

	local szChannel = GlobalEventHandler.GetChannelOnBlock(dwCaster, dwTarget)
	if szChannel == nil then
		Trace("OnSkillBlockLog Get Skill Channel failed!\n")
		return
	end

	OutputMessage(szChannel, szMsg)

end;


OnSkillShieldLog=function(dwCaster, dwTarget, nEffectType, dwID, dwLevel)
    local szCasterName = GlobalEventHandler.GetCharacterTipInfo(dwCaster)
    local szTargetName = GlobalEventHandler.GetCharacterTipInfo(dwTarget)

    local szSkillName = nil;
	if nEffectType == SKILL_EFFECT_TYPE.SKILL then
		szSkillName = Table_GetSkillName(dwID, dwLevel);
	elseif nEffectType == SKILL_EFFECT_TYPE.BUFF then
		szSkillName = Table_GetBuffName(dwID, dwLevel);
	end

	if not szSkillName then
		return
	end

	local szMsg = FormatString(g_tStrings.STR_SKILL_SHIELD_LOG_MSG, szCasterName, szSkillName, szTargetName)

	local szChannel = GlobalEventHandler.GetChannelOnShield(dwCaster, dwTarget)
	if szChannel == nil then
		Trace("OnSkillShieldLog Get Skill Channel failed!\n")
		return
	end

	OutputMessage(szChannel, szMsg);
end;

OnSkillMissLog=function(dwCaster, dwTarget, nEffectType, dwID, dwLevel)
    local szCasterName = GlobalEventHandler.GetCasterName(dwCaster)

	local szSkillName = nil;
	if nEffectType == SKILL_EFFECT_TYPE.SKILL then
		szSkillName = Table_GetSkillName(dwID, dwLevel);
	elseif nEffectType == SKILL_EFFECT_TYPE.BUFF then
		szSkillName = Table_GetBuffName(dwID, dwLevel);
	end

	if not szSkillName then
		return
	end

	local szMsg = FormatString(g_tStrings.STR_SKILL_MISS_LOG_MSG, szCasterName, szSkillName)
	local szChannel = GlobalEventHandler.GetChannelOnMiss(dwCaster, dwTarget)
	if szChannel == nil then
		Trace("OnSkillMissLog Get Skill Channel failed!\n")
		return
	end
	OutputMessage(szChannel, szMsg);
end;
---------------------------------- 技能命中目标 -----------------------------------------------------------------

OnSkillHitLog=function(dwCaster, dwTarget, nEffectType, dwID, dwLevel)
    local szCasterName = GlobalEventHandler.GetCasterName(dwCaster)
    local szTargetName = GlobalEventHandler.GetCharacterTipInfo(dwTarget)

	local szSkillName = nil;
	if nEffectType == SKILL_EFFECT_TYPE.SKILL then
		szSkillName = Table_GetSkillName(dwID, dwLevel);
	elseif nEffectType == SKILL_EFFECT_TYPE.BUFF then
		szSkillName = Table_GetBuffName(dwID, dwLevel);
	end

	if not szSkillName then
		return
	end

	local szMsg = FormatString(g_tStrings.STR_SKILL_HIT_LOG_MSG, szCasterName, szSkillName, szTargetName)

	local szChannel = GlobalEventHandler.GetChannelOnHit(dwCaster, dwTarget)

	if szChannel == nil then
		Trace("OnSkillHitLog Get Skill Channel failed!\n")
		return
	end

	OutputMessage(szChannel, szMsg);

end;
---------------------------------- 技能被闪避 -------------------------------------------------------------------

OnSkillDodgeLog=function(dwCaster, dwTarget, nEffectType, dwID, dwLevel)
    local szCasterName = GlobalEventHandler.GetCasterName(dwCaster)
    local szTargetName = GlobalEventHandler.GetCharacterTipInfo(dwTarget)

    local szSkillName = nil;
	if nEffectType == SKILL_EFFECT_TYPE.SKILL then
		szSkillName = Table_GetSkillName(dwID, dwLevel);
	elseif nEffectType == SKILL_EFFECT_TYPE.BUFF then
		szSkillName = Table_GetBuffName(dwID, dwLevel);
	end

	if not szSkillName then
		return
	end

	local szMsg = FormatString(g_tStrings.STR_SKILL_DODGE_LOG_MSG, szCasterName, szSkillName, szTargetName)
	local szChannel = GlobalEventHandler.GetChannelOnDodge(dwCaster, dwTarget)
	if szChannel == nil then
		Trace("OnSkillDodgeLog Get Skill Channel failed!\n")
		return
	end

	OutputMessage(szChannel, szMsg);
end;

OnExpLog=function(dwPlayerID, nAddExp)
	local szMsg = FormatString(g_tStrings.STR_EXP_YOU_GET_EXP_MSG, nAddExp);

	OutputMessage("MSG_EXP", szMsg);
end;

OnBuffLog=function(dwTarget, bCanCancel, dwID, bAddOrDel, nLevel)
	if not Table_BuffIsVisible(dwID, nLevel) then
		return
	end

    local szTargetName = GlobalEventHandler.GetCharacterTipInfo(dwTarget)
	local szBuffName = Table_GetBuffName(dwID, nLevel)

	local szMsg = ""
	if bAddOrDel ~= 0 then
	   szMsg = FormatString(g_tStrings.STR_YOU_GET_SOME_EFFECT_MSG, szTargetName, szBuffName)
    else
	   szMsg = FormatString(g_tStrings.STR_YOU_LOSE_SOME_EFFECT_MSG, szBuffName, szTargetName)
	end

	local szChannel = GlobalEventHandler.GetChannelOnBuff(dwTarget, bCanCancel)
	if not szChannel then
		--Trace("OnBuffLog Get Skill Channel failed!\n")
		return
	end

	OutputMessage(szChannel, szMsg)

end;

OnBuffImmunity=function(dwTarget, bCanCancel, dwID, nLevel)
    local szTargetName = GlobalEventHandler.GetCharacterTipInfo(dwTarget)
	local szBuffName = Table_GetBuffName(dwID, nLevel)

	local szMsg = ""

	szMsg = FormatString(g_tStrings.STR_BUFF_IMMUNITY_LOG_MSG, szBuffName, szTargetName)

	local szChannel = GlobalEventHandler.GetChannelOnBuff(dwTarget, bCanCancel)
	if not szChannel then
		--Trace("OnBuffImmunity Get Skill Channel failed!\n")
		return
	end

	OutputMessage(szChannel, szMsg)

end;

OnDeathNotify=function(dwID, nLeftReviveFrame, szKiller)
	local player = GetClientPlayer()
	if dwID == player.dwID then
		OutputMessage("MSG_OTHER_DEATH", FormatString(g_tStrings.STR_MSG_BE_HURT, g_tStrings.STR_NAME_YOU))
		if szKiller and szKiller ~= "" then
			OutputMessage("MSG_OTHER_DEATH", FormatString(g_tStrings.STR_MSG_HURT_PEOPLE, g_tStrings.STR_NAME_YOU, szKiller))
		end
		--CreateRevivePanel(nLeftReviveFrame / GLOBAL.GAME_FPS)
		FireHelpEvent("OnDeath")
	elseif IsParty(dwID, player.dwID) then
		local szName = GetTeammateName(dwID)
		if szName and szName ~= "" then
			OutputMessage("MSG_OTHER_DEATH", FormatString(g_tStrings.STR_MSG_BE_HURT, szName))
			if szKiller and szKiller ~= "" then
				OutputMessage("MSG_OTHER_DEATH", FormatString(g_tStrings.STR_MSG_HURT_PEOPLE, szName, szKiller))
			end
		end
	elseif IsPlayer(dwID) then
		local targ = GetPlayer(dwID)
		if targ then
			OutputMessage("MSG_OTHER_DEATH", FormatString(g_tStrings.STR_MSG_BE_HURT, targ.szName))
			if szKiller and szKiller ~= "" then
				OutputMessage("MSG_OTHER_DEATH", FormatString(g_tStrings.STR_MSG_HURT_PEOPLE, targ.szName, szKiller))
			end
		end
	else
        local szTargetName = GlobalEventHandler.GetCharacterTipInfo(dwID)
		local targ = GetNpc(dwID)
		if targ then
			OutputMessage("MSG_OTHER_DEATH", FormatString(g_tStrings.STR_MSG_BE_KILLED, szTargetName))
			if szKiller and szKiller ~= "" then
				OutputMessage("MSG_OTHER_DEATH", FormatString(g_tStrings.STR_MSG_KILLED_PEOPLE, szTargetName, szKiller))
				FireHelpEvent("OnKillEnemy", szKiller, dwID)
			end
		end
	end
end;

GetSkillRespondText=function(nRespondCode)
  local szMsg = nil

  if (nRespondCode == SKILL_RESULT_CODE.INVALID_CAST_MODE) then
		szMsg = g_tStrings.STR_ERROR_SKILL_INVALID_CAST_MODE
		PlayTipSound("025")
	elseif (nRespondCode == SKILL_RESULT_CODE.NOT_ENOUGH_LIFE) then
		szMsg = g_tStrings.STR_ERROR_SKILL_NOT_ENOUGH_LIFE
		PlayTipSound("026")
	elseif (nRespondCode == SKILL_RESULT_CODE.NOT_ENOUGH_MANA) then
		szMsg = g_tStrings.STR_ERROR_SKILL_NOT_ENOUGH_MANA
		PlayTipSound("027")
    elseif (nRespondCode == SKILL_RESULT_CODE.NOT_ENOUGH_RAGE) then
        szMsg = g_tStrings.STR_ERROR_SKILL_NOT_ENOUGH_RAGE
        PlayTipSound("028")
    elseif (nRespondCode == SKILL_RESULT_CODE.NOT_ENOUGH_ENERGY) then
        szMsg = g_tStrings.STR_ERROR_SKILL_NOT_ENOUGH_ENERGY
    elseif (nRespondCode == SKILL_RESULT_CODE.NOT_ENOUGH_TRAIN) then
        szMsg = g_tStrings.STR_ERROR_SKILL_NOT_ENOUGH_TRAIN
        PlayTipSound("029")
	elseif (nRespondCode == SKILL_RESULT_CODE.NOT_ENOUGH_STAMINA) then
		szMsg = g_tStrings.STR_ERROR_SKILL_NOT_ENOUGH_STAMINA
		PlayTipSound("030")
	elseif (nRespondCode == SKILL_RESULT_CODE.NOT_ENOUGH_ITEM) then
		szMsg = g_tStrings.STR_ERROR_SKILL_NOT_ENOUGH_ITEM
		PlayTipSound("031")
	elseif (nRespondCode == SKILL_RESULT_CODE.NOT_ENOUGH_AMMO) then
		szMsg = g_tStrings.STR_ERROR_SKILL_NOT_ENOUGH_AMMO
		PlayTipSound("033")
	elseif (nRespondCode == SKILL_RESULT_CODE.SKILL_NOT_READY) then
		szMsg = g_tStrings.STR_ERROR_SKILL_SKILL_NOT_READY
		PlayTipSound("058")
	elseif (nRespondCode == SKILL_RESULT_CODE.INVALID_SKILL) then
		szMsg = g_tStrings.STR_ERROR_SKILL_INVALID_SKILL
	elseif (nRespondCode == SKILL_RESULT_CODE.INVALID_TARGET) then
		szMsg = g_tStrings.STR_ERROR_SKILL_INVALID_TARGET
	elseif (nRespondCode == SKILL_RESULT_CODE.NO_TARGET) then
		szMsg = g_tStrings.STR_ERROR_SKILL_NO_TARGET
		PlayTipSound("035")
	elseif (nRespondCode == SKILL_RESULT_CODE.TOO_CLOSE_TARGET) then
		szMsg = g_tStrings.STR_ERROR_SKILL_TOO_CLOSE_TARGET
		PlayTipSound("036")
	elseif (nRespondCode == SKILL_RESULT_CODE.TOO_FAR_TARGET) then
		szMsg = g_tStrings.STR_ERROR_SKILL_TOO_FAR_TARGET
		PlayTipSound("037")
	elseif (nRespondCode == SKILL_RESULT_CODE.OUT_OF_ANGLE) then
		szMsg = g_tStrings.STR_ERROR_SKILL_OUT_OF_ANGLE
		PlayTipSound("038")
	elseif (nRespondCode == SKILL_RESULT_CODE.TARGET_INVISIBLE) then
		szMsg = g_tStrings.STR_ERROR_SKILL_TARGET_INVISIBLE
	elseif (nRespondCode == SKILL_RESULT_CODE.WEAPON_ERROR) then
		szMsg = g_tStrings.STR_ERROR_SKILL_WEAPON_ERROR
		PlayTipSound("039")
	elseif (nRespondCode == SKILL_RESULT_CODE.WEAPON_DESTROY) then
		szMsg = g_tStrings.STR_ERROR_SKILL_WEAPON_DESTROY
		PlayTipSound("040")
	elseif (nRespondCode == SKILL_RESULT_CODE.AMMO_ERROR) then
		szMsg = g_tStrings.STR_ERROR_SKILL_AMMO_ERROR
		PlayTipSound("041")
	elseif (nRespondCode == SKILL_RESULT_CODE.NOT_EQUIT_AMMO) then
		szMsg = g_tStrings.STR_ERROR_SKILL_NOT_EQUIT_AMMO
	elseif (nRespondCode == SKILL_RESULT_CODE.MOUNT_ERROR) then
		szMsg = g_tStrings.STR_ERROR_SKILL_MOUNT_ERROR
		PlayTipSound("042")
	elseif (nRespondCode == SKILL_RESULT_CODE.IN_OTACTION) then
		szMsg = g_tStrings.STR_ERROR_IN_OTACTION
		PlayTipSound("053")
	elseif (nRespondCode == SKILL_RESULT_CODE.ON_SILENCE) then
		szMsg = g_tStrings.STR_ERROR_SKILL_ON_SILENCE
		PlayTipSound("043")
	elseif (nRespondCode == SKILL_RESULT_CODE.NOT_FORMATION_LEADER) then
		szMsg = g_tStrings.STR_ERROR_SKILL_NOT_FORMATION_LEADER
	elseif (nRespondCode == SKILL_RESULT_CODE.NOT_ENOUGH_MEMBER) then
		szMsg = g_tStrings.STR_ERROR_SKILL_NOT_ENOUGH_MEMBER
		PlayTipSound("044")
	elseif (nRespondCode == SKILL_RESULT_CODE.NOT_START_ACCUMULATE) then
		local skill = GetClientPlayer().GetKungfuMount()
		if skill and skill.dwMountType == 5 then --少林内功
			szMsg = g_tStrings.STR_ERROR_SKILL_NOT_FANJIZHI
			PlayTipSound("046")
		else
			szMsg = g_tStrings.STR_ERROR_SKILL_NOT_START_ACCUMULATE
			PlayTipSound("045")
		end
	elseif (nRespondCode == SKILL_RESULT_CODE.SKILL_ERROR) then
        szMsg = g_tStrings.STR_ERROR_SKILL_SKILL_ERROR
	elseif (nRespondCode == SKILL_RESULT_CODE.BUFF_ERROR) then
        szMsg = g_tStrings.STR_ERROR_SKILL_BUFF_ERROR
        PlayTipSound("047")
    elseif (nRespondCode == SKILL_RESULT_CODE.NOT_IN_FIGHT) then
        szMsg = g_tStrings.STR_ERROR_SKILL_NOT_IN_FIGHT
    elseif (nRespondCode == SKILL_RESULT_CODE.MOVE_STATE_ERROR) then
    	local player = GetClientPlayer()

    	szMsg = FormatString(g_tStrings.STR_ERROR_SKILL_MOVE_STATE_ERROR, g_tStrings.tPlayerMoveState[player.nMoveState])
    elseif (nRespondCode == SKILL_RESULT_CODE.DST_MOVE_STATE_ERROR) then
    	local player = GetClientPlayer()
    	local eTargetType, dwTargetID = player.GetTarget()
    	local target

    	if (eTargetType == TARGET.NPC) then
    		target = GetNpc(dwTargetID)
    	elseif (eTargetType == TARGET.PLAYER) then
    		target = GetPlayer(dwTargetID)
    	end

    	if target then
    		if target.nMoveState == MOVE_STATE.ON_DEATH then
    			szMsg = g_tStrings.STR_ERROR_SKILL_TARGET_ON_DEATH
    			PlayTipSound("048")
    		else
	    		szMsg = FormatString(g_tStrings.STR_ERROR_SKILL_DST_MOVE_STATE_ERROR, g_tStrings.tPlayerMoveState[target.nMoveState])
    		end
    	else
    		szMsg = g_tStrings.STR_ERROR_SKILL_UNABLE_CAST
    	end
    elseif (nRespondCode == SKILL_RESULT_CODE.ERROR_BY_HORSE) then
    	local player = GetClientPlayer()

    	if player.bOnHorse then
    		szMsg = g_tStrings.STR_ERROR_SKILL_NOT_ON_HORSE
    	else
    		PlayTipSound("049")
    		szMsg = g_tStrings.STR_ERROR_SKILL_ON_HORSE
    	end
    elseif (nRespondCode == SKILL_RESULT_CODE.BUFF_INVALID) then
        szMsg = g_tStrings.STR_ERROR_SKILL_BUFF_INVALID
    elseif (nRespondCode == SKILL_RESULT_CODE.FORCE_EFFECT) then
        szMsg = g_tStrings.STR_ERROR_SKILL_FORCE_EFFECT
        PlayTipSound("050")
    elseif (nRespondCode == SKILL_RESULT_CODE.BUFF_IMMUNITY) then
        szMsg = g_tStrings.STR_ERROR_SKILL_BUFF_IMMUNITY
        PlayTipSound("051")
    elseif (nRespondCode == SKILL_RESULT_CODE.TARGET_LIFE_ERROR) then
        szMsg = g_tStrings.STR_ERROR_SKILL_TARGET_LIFE_ERROR
    elseif (nRespondCode == SKILL_RESULT_CODE.SELF_LIFE_ERROR) then
        szMsg = g_tStrings.STR_ERROR_SKILL_SELF_LIFE_ERROR
    elseif (nRespondCode == SKILL_RESULT_CODE.MAP_BAN) then
        szMsg = g_tStrings.STR_ERROR_SKILL_MAP_BAN
        PlayTipSound("052")
    elseif (nRespondCode == SKILL_RESULT_CODE.TARGET_STEALTH) then
		szMsg = g_tStrings.STR_ERROR_SKILL_TARGET_STEALTH
	elseif (nRespondCode == SKILL_RESULT_CODE.ERROR_BY_SPRINT) then
		local player = GetClientPlayer()

    	if player.bSprintFlag then
    		szMsg = g_tStrings.STR_ERROR_SKILL_NOT_IN_SPRINT
    	else
    		szMsg = g_tStrings.STR_ERROR_SKILL_IN_SPRINT
    	end
	else
		szMsg = g_tStrings.STR_ERROR_SKILL_UNABLE_CAST
	end

	return szMsg
end;

OnSkillRespond=function(nRespondCode)

  	local szMsg = GlobalEventHandler.GetSkillRespondText(nRespondCode)
	if not szMsg then
		Trace("Unexpect skill respond code ("..nRespondCode..")\n")
		return
	end
	OutputMessage("MSG_ANNOUNCE_RED", szMsg);
    if nRespondCode == SKILL_RESULT_CODE.FORCE_EFFECT then
        OutputMessage("MSG_SKILL_SELF_FAILED", szMsg..g_tStrings.STR_FULL_STOP.."\n")
	end
end;

OnShopRespond = function(nRespondCode, nMoney)

	local szMsg = g_tStrings.g_ShopStrings[nRespondCode]

	if not szMsg then
		return
	end
	
	if nRespondCode == SHOP_SYSTEM_RESPOND_CODE.SELL_FAILED then
		PlayTipSound("079")
	elseif nRespondCode == SHOP_SYSTEM_RESPOND_CODE.BUY_FAILED then
		PlayTipSound("079_1")
	elseif nRespondCode == SHOP_SYSTEM_RESPOND_CODE.REPAIR_FAILED then
		PlayTipSound("079_2")
	elseif nRespondCode == SHOP_SYSTEM_RESPOND_CODE.NOT_ENOUGH_MONEY then
		PlayTipSound("080")
	elseif nRespondCode == SHOP_SYSTEM_RESPOND_CODE.NOT_ENOUGH_PRESTIGE then
		PlayTipSound("081")
	elseif nRespondCode == SHOP_SYSTEM_RESPOND_CODE.NOT_ENOUGH_CONTRIBUTION then
		PlayTipSound("081_1")
	elseif nRespondCode == SHOP_SYSTEM_RESPOND_CODE.ACHIEVEMENT_RECORD_ERROR then
		PlayTipSound("082")
	elseif nRespondCode == SHOP_SYSTEM_RESPOND_CODE.NOT_ENOUGH_ACHIEVEMENT_POINT then
		PlayTipSound("082_1")
	elseif nRespondCode == SHOP_SYSTEM_RESPOND_CODE.NOT_ENOUGH_MENTOR_VALUE then
		PlayTipSound("083")
	elseif nRespondCode == SHOP_SYSTEM_RESPOND_CODE.ITEM_SOLD_OUT then
		PlayTipSound("084")
	elseif nRespondCode == SHOP_SYSTEM_RESPOND_CODE.BAG_FULL then
		PlayTipSound("006")
	elseif nRespondCode == SHOP_SYSTEM_RESPOND_CODE.CAN_NOT_SELL then
		PlayTipSound("085")
	elseif nRespondCode == SHOP_SYSTEM_RESPOND_CODE.NOT_ENOUGH_ITEM then
		PlayTipSound("086")
	elseif nRespondCode == SHOP_SYSTEM_RESPOND_CODE.ITEM_CD then
		PlayTipSound("087")
	elseif nRespondCode == SHOP_SYSTEM_RESPOND_CODE.HAVE_TOO_MUCH_MONEY then
		PlayTipSound("088")
	elseif nRespondCode == SHOP_SYSTEM_RESPOND_CODE.TITLE_TOO_LOW then
		PlayTipSound("089")
	elseif nRespondCode == SHOP_SYSTEM_RESPOND_CODE.NOT_ENOUGH_CORPS_VALUE then
		--PlayTipSound("089")
	end

	if (nRespondCode == SHOP_SYSTEM_RESPOND_CODE.SELL_SUCCESS) then
		OutputMessage("MSG_ANNOUNCE_YELLOW", szMsg)
		PlaySound(SOUND.UI_SOUND,g_sound.Sell)
		return
	elseif (nRespondCode == SHOP_SYSTEM_RESPOND_CODE.BUY_SUCCESS) then
		OutputMessage("MSG_ANNOUNCE_YELLOW", szMsg)
		PlaySound(SOUND.UI_SOUND,g_sound.Trade)
		return
	elseif (nRespondCode == SHOP_SYSTEM_RESPOND_CODE.REPAIR_SUCCESS) then
		OutputMessage("MSG_ANNOUNCE_YELLOW", szMsg)
		PlaySound(SOUND.UI_SOUND,g_sound.Repair)

		if nMoney > 0 then
			local szFont = GetMsgFontString("MSG_ITEM")
			local szMoney = GetMoneyText(nMoney, szFont)
			OutputMessage("MSG_MONEY", "<text>text=\""..g_tStrings.STR_SHOP_REPAIR_COST_MONEY.."\" font="..szFont.."</text>"..szMoney.."<text>text=\"\n\" font="..szFont.."</text>", true)
		end

		return
	else
		OutputMessage("MSG_ANNOUNCE_RED", szMsg);
	end
end;

OnMailRespond=function(nRespondCode)
	local szMsg = ""
	
	if nRespondCode == MAIL_RESPOND_CODE.SUCCEED then
		szMsg = g_tStrings.STR_MAIL_SUCCEED;
		OutputMessage("MSG_ANNOUNCE_YELLOW", szMsg);
		return
	elseif nRespondCode == MAIL_RESPOND_CODE.FAILED then
		szMsg = g_tStrings.STR_MAIL_FAILED;
	elseif nRespondCode == MAIL_RESPOND_CODE.SYSTEM_BUSY then
		szMsg = g_tStrings.STR_MAIL_SYSTEM_BUSY;
	elseif nRespondCode == MAIL_RESPOND_CODE.DST_NOT_EXIST then
		szMsg = g_tStrings.STR_MAIL_DST_NOT_EXIST;
		PlayTipSound("104")
	elseif nRespondCode == MAIL_RESPOND_CODE.DST_REMOTE_PLAYER then
		szMsg = g_tStrings.STR_MAIL_DST_REMOTE_PLAYER;
		PlayTipSound("104")
	elseif nRespondCode == MAIL_RESPOND_CODE.NOT_ENOUGH_MONEY then
		szMsg = g_tStrings.STR_MAIL_NOT_ENOUGH_MONEY;
	elseif nRespondCode == MAIL_RESPOND_CODE.ITEM_AMOUNT_LIMIT then
		szMsg = g_tStrings.STR_MAIL_ITEM_AMOUNT_LIMIT;
	elseif nRespondCode == MAIL_RESPOND_CODE.NOT_ENOUGH_ROOM then
		szMsg = g_tStrings.STR_MAIL_NOT_ENOUGH_ROOM;
	elseif nRespondCode == MAIL_RESPOND_CODE.MAIL_NOT_FOUND then
		szMsg = g_tStrings.STR_MAIL_NOT_FOUND;
	elseif nRespondCode == MAIL_RESPOND_CODE.MAIL_BOX_FULL then
		szMsg = g_tStrings.STR_MAIL_BOX_FULL;
	elseif nRespondCode == MAIL_RESPOND_CODE.RETURN_MAIL_FAILED then
		szMsg = g_tStrings.STR_MAIL_RETURN_MAIL_FAILED;
	elseif nRespondCode == MAIL_RESPOND_CODE.ITEM_BE_BIND then
		szMsg = g_tStrings.STR_MAIL_ITEM_BE_BIND;
	elseif nRespondCode == MAIL_RESPOND_CODE.TIME_LIMIT_ITEM then
		szMsg = g_tStrings.STR_TIME_LIMIT_ITEM;
	elseif nRespondCode == MAIL_RESPOND_CODE.ITEM_NOT_IN_PACKAGE then
		szMsg = g_tStrings.STR_MAIL_ITEM_NOT_IN_PACKAGE;
	elseif nRespondCode == MAIL_RESPOND_CODE.MONEY_LIMIT then
		szMsg = g_tStrings.STR_MAIL_MONEY_LIMIT;
	elseif nRespondCode == MAIL_RESPOND_CODE.DST_NOT_SELF then
		szMsg = g_tStrings.STR_MAIL_DST_NOT_SELF;
	elseif nRespondCode == MAIL_RESPOND_CODE.DELETE_REFUSED then
		szMsg = g_tStrings.STR_MAIL_DELETE_REFUSED;
	elseif nRespondCode == MAIL_RESPOND_CODE.SELF_MAIL_BOX_FULL then
		szMsg = g_tStrings.STR_MAIL_SELF_MAIL_BOX_FULL;
	elseif nRespondCode == MAIL_RESPOND_CODE.TOO_FAWAY then
		szMsg = g_tStrings.STR_MAIL_TOO_FAR_AWAY;
	end;

	OutputMessage("MSG_ANNOUNCE_RED", szMsg);
end;

OnMailCountInfo=function(nUnreadCount, nTotalCount)
	local szMsg = ""
	szMsg = FormatString(g_tStrings.STR_MSG_MAIL_COUNT_INFO, nUnreadCount, nTotalCount)
	OutputMessage("MSG_SYS", szMsg)
	PlaySound(SOUND.UI_SOUND,g_sound.NewMail)
end;

-------------------------拾取物品的返回结果-----------------------------
OnLootRespond=function(nRespondCode)
	local szMsg = g_tStrings.tLootResult[nRespondCode]
	if szMsg then
	    OutputMessage("MSG_ANNOUNCE_RED", szMsg);
	    if nRespondCode == LOOT_ITEM_RESULT_CODE.INVENTORY_IS_FULL then
	    	PlayTipSound("006")
	    elseif nRespondCode == LOOT_ITEM_RESULT_CODE.NOT_EXIST_LOOT_ITEM then
	    	PlayTipSound("013")
	    elseif nRespondCode == LOOT_ITEM_RESULT_CODE.ADD_LOOT_ITEM_FAILED then
	    elseif nRespondCode == LOOT_ITEM_RESULT_CODE.NO_LOOT_TARGET then
	    elseif nRespondCode == LOOT_ITEM_RESULT_CODE.TOO_FAR_TO_LOOT then
	    	PlayTipSound("014")
	    elseif nRespondCode == LOOT_ITEM_RESULT_CODE.OVER_ITEM_LIMIT then
	    	PlayTipSound("015")
	    end
	end
end;

-------------------------使用生活技能的返回结果----------------------
OnCraftRespond=function(nRespondCode, dwCraftID, dwRecipeID, dwTargetType, dwTargetID)
	--local szMsg = g_tStrings.tCraftResultString[nRespondCode].." "..nRespondCode.." "..dwCraftID.." "..dwRecipeID.." "..dwTargetType.." "..dwTargetID;
	local szMsg = "";

	if nRespondCode == CRAFT_RESULT_CODE.SUCCESS then
		local hPlayer = GetClientPlayer()
		local recipe = GetRecipe(dwCraftID, dwRecipeID);
		if recipe.nCraftType == ALL_CRAFT_TYPE.COLLECTION or recipe.nCraftType == ALL_CRAFT_TYPE.COPY then
			if recipe.nThew > 0 then
			    szMsg = FormatString(g_tStrings.STR_CRAFT_COST_THEW_ENTER, recipe.nThew)
                OutputMessage("MSG_THEW_STAMINA", szMsg)
			end
		elseif recipe.nCraftType == ALL_CRAFT_TYPE.PRODUCE  or recipe.nCraftType == ALL_CRAFT_TYPE.READ or recipe.nCraftType == ALL_CRAFT_TYPE.ENCHANT then
		    if recipe.nStamina > 0 then
		        szMsg = FormatString(g_tStrings.STR_CRAFT_COST_STAMINA_ENTER, recipe.nStamina)
                OutputMessage("MSG_THEW_STAMINA", szMsg)
		    end

		    if recipe.nCraftType == ALL_CRAFT_TYPE.READ then
		    	szMsg = g_tStrings.STR_CRAFT_READ_SUCCESS
                OutputMessage("MSG_SYS", szMsg)
		    	local argS = arg0
		    	arg0 = BookID2GlobelRecipeID(recipe.dwID, recipe.dwSubID)
		    	FireEvent("ON_READ_BOOK")
		    	arg0 = argS

		    	if hPlayer then
			    	local tSegmentBook = hPlayer.GetBookSegmentList(recipe.dwID)
			    	local nBookNum = Table_GetBookNumber(recipe.dwID, 1)
					local nHaveNum = #tSegmentBook
					if nHaveNum == nBookNum then
						FireHelpEvent("OnOneBookListReaded")
					end
				end
			end
		end

		
		if hPlayer then
			if hPlayer.nCurrentStamina == 0 or hPlayer.nCurrentThew == 0 then
				FireHelpEvent("OnWithoutStaminaOrThew")
			end
		end

		if recipe.nCraftType == ALL_CRAFT_TYPE.COLLECTION or recipe.nCraftType == ALL_CRAFT_TYPE.PRODUCE then
			local nCurrentLevel = hPlayer.GetProfessionLevel(recipe.dwProfessionID)
			local nMaxLevel = hPlayer.GetProfessionMaxLevel(recipe.dwProfessionID)
			if nCurrentLevel == nMaxLevel and nMaxLevel < 50 then
				OutputMessage("MSG_SYS", g_tStrings.STR_CRAFT_NOT_EXP_MIDDLE);
			elseif nCurrentLevel == nMaxLevel and nMaxLevel < 70 then
				OutputMessage("MSG_SYS", g_tStrings.STR_CRAFT_NOT_EXP_HIGH);
			end
		end

		return;
	elseif nRespondCode == CRAFT_RESULT_CODE.NOT_ENOUGH_STAMINA then
		local recipe = GetRecipe(dwCraftID, dwRecipeID);
		if recipe then
			szMsg = FormatString(g_tStrings.tCraftResultString[nRespondCode], recipe.nStamina)
		end
  elseif nRespondCode == CRAFT_RESULT_CODE.NOT_ENOUGH_THEW then
		local recipe = GetRecipe(dwCraftID, dwRecipeID);
		if recipe then
			szMsg = FormatString(g_tStrings.tCraftResultString[nRespondCode], recipe.nThew)
		end
	elseif nRespondCode == CRAFT_RESULT_CODE.TOO_LOW_PROFESSION_LEVEL then
		local craft = GetCraft(dwCraftID);
		local profession = GetProfession(craft.ProfessionID);
		local recipe = GetRecipe(dwCraftID, dwRecipeID);
		if recipe and profession then
			szMsg = FormatString(g_tStrings.tCraftResultString[nRespondCode], Table_GetProfessionName(craft.ProfessionID), recipe.dwRequireProfessionLevel)
		end
	elseif nRespondCode == CRAFT_RESULT_CODE.PROFESSION_NOT_LEARNED then
		local craft = GetCraft(dwCraftID);
		local profession = GetProfession(craft.ProfessionID);
		if profession then
			szMsg = FormatString(g_tStrings.tCraftResultString[nRespondCode], Table_GetProfessionName(craft.ProfessionID))
		end
	elseif nRespondCode == CRAFT_RESULT_CODE.ERROR_TOOL then
		local recipe = GetRecipe(dwCraftID, dwRecipeID);
		if recipe then
			local ItemInfo = GetItemInfo(recipe.dwToolItemType, recipe.dwToolItemIndex);
			local szItemName = GetItemNameByItemInfo(ItemInfo)
			if ItemInfo then
				szMsg = FormatString(g_tStrings.tCraftResultString[nRespondCode], szItemName);
			end
		end
	elseif nRespondCode == CRAFT_RESULT_CODE.REQUIRE_DOODAD then
		local recipe = GetRecipe(dwCraftID, dwRecipeID);
		if recipe then
			local doodadTemplateID = recipe.dwRequireDoodadID;
			local doodadTemplate = GetDoodadTemplate(doodadTemplateID);
			if doodadTemplate then
				local szName = Table_GetDoodadTemplateName(doodadTemplate.dwTemplateID)
				szMsg = FormatString(g_tStrings.tCraftResultString[nRespondCode], szName)
			end
		end
	elseif nRespondCode == CRAFT_RESULT_CODE.TOO_LOW_EXT_PROFESSION_LEVEL then
	    local recipe = GetRecipe(dwCraftID, dwRecipeID);
		local profession = GetProfession(recipe.dwProfessionIDExt);

		if recipe and profession then
			szMsg = FormatString(g_tStrings.tCraftResultString[nRespondCode], Table_GetProfessionName(recipe.dwProfessionIDExt), recipe.dwRequireProfessionLevelExt)
		end
	elseif nRespondCode == CRAFT_RESULT_CODE.EXT_PROFESSION_NOT_LEARNED then
	  local recipe = GetRecipe(dwCraftID, dwRecipeID);
		local profession = GetProfession(recipe.dwProfessionIDExt);
		if profession then
			szMsg = FormatString(g_tStrings.tCraftResultString[nRespondCode], Table_GetProfessionName(recipe.dwProfessionIDExt))
		end
	else
		szMsg = g_tStrings.tCraftResultString[nRespondCode];
	end
	
	if nRespondCode == CRAFT_RESULT_CODE.SKILL_NOT_READY then
		PlayTipSound("058")
	elseif nRespondCode == CRAFT_RESULT_CODE.WEAPON_ERROR then
		PlayTipSound("059")
	elseif nRespondCode == CRAFT_RESULT_CODE.ADD_ITEM_FAILED then
		PlayTipSound("060")
	elseif nRespondCode == CRAFT_RESULT_CODE.INVENTORY_IS_FULL then
		PlayTipSound("006")
	elseif nRespondCode == CRAFT_RESULT_CODE.BOOK_IS_ALREADY_MEMORIZED then
		PlayTipSound("061")
	elseif nRespondCode == CRAFT_RESULT_CODE.BOOK_CANNOT_BE_COPY then
		PlayTipSound("061_1")
	elseif nRespondCode == CRAFT_RESULT_CODE.ITEM_TYPE_ERROR then
		PlayTipSound("062")
	elseif nRespondCode == CRAFT_RESULT_CODE.DOING_OTACTION then
		PlayTipSound("063")
	end

	OutputMessage("MSG_ANNOUNCE_RED", szMsg);
end;

-------------------------任务操作的返回结果--------------------------
OnQuestRespond=function(nRespondCode, dwQuestID)
	local szMsg = g_tStrings.tQuestResultString[nRespondCode];
	
	if nRespondCode == QUEST_RESULT.QUESTLIST_FULL then
		PlayTipSound("064")
	elseif nRespondCode == QUEST_RESULT.ERROR_QUEST_STATE then
		PlayTipSound("065")
	elseif nRespondCode == QUEST_RESULT.NOT_ENOUGH_FREE_ROOM then
		PlayTipSound("006")
	elseif nRespondCode == QUEST_RESULT.DAILY_QUEST_FULL then
		PlayTipSound("066")
	elseif nRespondCode == QUEST_RESULT.ERROR_CAMP then
		PlayTipSound("067")
	elseif nRespondCode == QUEST_RESULT.CHARGE_LIMIT then
		PlayTipSound("068")
	elseif nRespondCode == QUEST_RESULT.ERROR_REPUTE then
		PlayTipSound("069")
	end
	
	if not szMsg then
		szMsg = "";
	end

	if nRespondCode == QUEST_RESULT.ERROR_REPUTE then
		local hPlayer = GetClientPlayer()
		if not hPlayer then
			return
		end
		local t = hPlayer.GetQuestReputationInfo(dwQuestID)
		if not t then
			return
		end
		for i,v in pairs(t) do
			if g_tReputation.tReputationTable[i] then
				local reputationname = g_tReputation.tReputationTable[i].szName
				if reputationname then
					if v == "low" then
						szMsg = FormatString(g_tStrings.STR_REPUTATION_TOO_LOW, reputationname);
					elseif v == "high" then
						szMsg = FormatString(g_tStrings.STR_REPUTATION_TOO_HIGH, reputationname);
					else
					  szMsg = "";
					end
					OutputMessage("MSG_ANNOUNCE_RED", szMsg);

				end
			end
		end
		return
	end

	OutputMessage("MSG_ANNOUNCE_RED", szMsg);
end;

---------------------------好友操作的返回结果------------------------
OnFellowshipMessage=function(nRespondCode)
	local szMsg = g_tStrings.tFellowshipErrorString[nRespondCode];
	if nRespondCode == PLAYER_FELLOWSHIP_RESPOND.ERROR_INVALID_NAME then
		PlayTipSound("070")
	elseif nRespondCode == PLAYER_FELLOWSHIP_RESPOND.ERROR_ADD_SELF then
		PlayTipSound("071")
	elseif nRespondCode == PLAYER_FELLOWSHIP_RESPOND.ERROR_LIST_FULL then
		PlayTipSound("072")
	elseif nRespondCode == PLAYER_FELLOWSHIP_RESPOND.ERROR_EXISTS then
		PlayTipSound("073")
	elseif nRespondCode == PLAYER_FELLOWSHIP_RESPOND.ERROR_NOT_FOUND then
		PlayTipSound("074")
	elseif nRespondCode == PLAYER_FELLOWSHIP_RESPOND.ERROR_FOE_LIST_FULL then
		PlayTipSound("075")
	elseif nRespondCode == PLAYER_FELLOWSHIP_RESPOND.ERROR_BLACK_LIST_FULL then
		PlayTipSound("076")
	elseif nRespondCode == PLAYER_FELLOWSHIP_RESPOND.ERROR_BLACK_LIST_EXISTS then
		PlayTipSound("077")
	elseif nRespondCode == PLAYER_FELLOWSHIP_RESPOND.ERROR_SET_GROUP then
		PlayTipSound("078")
	end
	if not szMsg then
		szMsg = "";
	end

	OutputMessage("MSG_ANNOUNCE_RED", szMsg);
end;

OnItemRespond=function(nRespondCode)
	local szMsg = g_tStrings.tItem_Msg[nRespondCode]
	
	if nRespondCode == ITEM_RESULT_CODE.PLAYER_IS_DEAD then
		PlayTipSound("101")
	elseif nRespondCode == ITEM_RESULT_CODE.ERROR_EQUIP_PLACE then
		PlayTipSound("102")
	elseif nRespondCode == ITEM_RESULT_CODE.ITEM_BINDED then
		PlayTipSound("103")
	elseif nRespondCode == ITEM_RESULT_CODE.BANK_PASSWORD_EXIST then
		--PlayTipSound("103")
	end

	if szMsg ~= "" then
		OutputMessage("MSG_ANNOUNCE_RED", szMsg);
	end

end;


OnAddItemRespond=function(nRespondCode)
	local szMsg = g_tStrings.tAdd_Item_Msg[nRespondCode]
	if nRespondCode == ADD_ITEM_RESULT_CODE.ITEM_AMOUNT_LIMITED and arg2 ~= "" then
		szMsg = FormatString(g_tStrings.STR_ITEM_AMOUNT_LIMITED_WITH_NAME, arg2);
	end

	if szMsg ~= "" then
		OutputMessage("MSG_ANNOUNCE_RED", szMsg);
	end

end;


-------------------------使用物品的返回结果--------------------------
OnUseItemRespond=function(nRespondCode)
	local szMsg = g_tStrings.tUse_Item_Msg[nRespondCode]
	
	if nRespondCode == USE_ITEM_RESULT_CODE.FAILED then
		PlayTipSound("100")
	elseif nRespondCode == USE_ITEM_RESULT_CODE.NOT_READY then
		PlayTipSound("091")
	elseif nRespondCode == USE_ITEM_RESULT_CODE.NOT_READY then
		PlayTipSound("091")
	elseif nRespondCode == USE_ITEM_RESULT_CODE.ON_HORSE then
		PlayTipSound("099")
	elseif nRespondCode == USE_ITEM_RESULT_CODE.IN_FIGHT then
		PlayTipSound("098")
	end

	if nRespondCode == USE_ITEM_RESULT_CODE.REQUIRE_PROFESSION then
	    profession = GetProfession(arg2)
	    if profession then
	        szMsg = FormatString(szMsg, Table_GetProfessionName(arg2))
	    end
	elseif nRespondCode == USE_ITEM_RESULT_CODE.REQUIRE_PROFESSION_BRANCH then
	    profession = GetProfession(arg2)
	    if profession then
	        local szBranchName = Table_GetBranchName(arg2, arg3)
	        if szBranchName then
	            szMsg = FormatString(szMsg, Table_GetProfessionName(arg2), szBranchName)
	        end
	    end
	elseif nRespondCode == USE_ITEM_RESULT_CODE.PROFESSION_LEVEL_TOO_LOW then
	    profession = GetProfession(arg2)
	    if profession then
	        szMsg = FormatString(szMsg, Table_GetProfessionName(arg2), arg3)
	    end
	end

	if szMsg ~= "" then
		OutputMessage("MSG_ANNOUNCE_RED", szMsg);
	end

end;

OnTradingRespond=function(nRespondCode)
	local szMsg = g_tStrings.tTradingResultString[nRespondCode]

	if not szMsg then
	    return;
	end

	if nRespondCode == TRADING_RESPOND_CODE.SUCCESS then
		OutputMessage("MSG_ANNOUNCE_YELLOW", szMsg)
		PlaySound(SOUND.UI_SOUND,g_sound.Trade)
		return
	elseif nRespondCode == TRADING_RESPOND_CODE.REFUSE_INVITE then
		PlayTipSound("054")
	elseif nRespondCode == TRADING_RESPOND_CODE.TARGET_NOT_IN_GAME then
		PlayTipSound("055")
	elseif nRespondCode == TRADING_RESPOND_CODE.TARGET_BUSY then
		PlayTipSound("056")
	elseif nRespondCode == TRADING_RESPOND_CODE.TOO_FAR then
		PlayTipSound("057")
	end

	OutputMessage("MSG_ANNOUNCE_RED", szMsg)

	return;
end;

ResponseMsgOnTalkError=function(nRespondCode)
	local szMsg = ""
	if nRespondCode == PLAYER_TALK_ERROR.PLAYER_NOT_FOUND then
	    szMsg = g_tStrings.STR_TALK_ERROR_PLAYER_NOT_FOUND
	elseif nRespondCode == PLAYER_TALK_ERROR.NOT_IN_PARTY then
	    szMsg = g_tStrings.STR_TALK_ERROR_NOT_IN_PARTY
	elseif nRespondCode == PLAYER_TALK_ERROR.NOT_IN_SENCE then
	    szMsg = g_tStrings.STR_TALK_ERROR_NOT_IN_SENCE
	elseif nRespondCode == PLAYER_TALK_ERROR.PLAYER_OFFLINE then
	    szMsg = g_tStrings.STR_TALK_ERROR_PLAYER_OFFLINE
	elseif nRespondCode == PLAYER_TALK_ERROR.YOU_BLACKLIST_TARGET then
	    szMsg = g_tStrings.STR_TALK_ERROR_YOU_BLACKLIST_TARGET
	elseif nRespondCode == PLAYER_TALK_ERROR.TARGET_BLACKLIST_YOU then
	    szMsg = g_tStrings.STR_TALK_ERROR_TARGET_BLACKLIST_YOU
	elseif nRespondCode == PLAYER_TALK_ERROR.BAN then
	    szMsg = g_tStrings.STR_TALK_ERROR_BAN
	elseif nRespondCode == PLAYER_TALK_ERROR.SCENE_CD then
	    szMsg = g_tStrings.STR_TALK_ERROR_SCENE_CD
	elseif nRespondCode == PLAYER_TALK_ERROR.NOT_IN_TONG then
		szMsg = g_tStrings.STR_TALK_ERROR_NOT_IN_TONG
	elseif nRespondCode == PLAYER_TALK_ERROR.TONG_CAN_NOT_SPEAK then
		szMsg = g_tStrings.STR_TALK_ERROR_TONG_CAN_NOT_SPEAK
	elseif nRespondCode == PLAYER_TALK_ERROR.DAILY_LIMIT then
		szMsg = g_tStrings.STR_TALK_ERROR_DAILY_LIMIT
	elseif nRespondCode == PLAYER_TALK_ERROR.NOT_IN_FORCE then
		szMsg = g_tStrings.STR_TALK_ERROR_NOT_IN_FORCE
	elseif nRespondCode == PLAYER_TALK_ERROR.REMOTE_PLAYER_LIMIT then
		szMsg = g_tStrings.STR_TALK_ERROR_REMOTE_PLAYER_LIMIT
	end

	if szMsg ~= "" then
		OutputMessage("MSG_SYS", szMsg)
	end
end;

GetChannelOnSkillCast=function(dwCaster)
	local szChannel = nil
	if IsSelfData(dwCaster) then
		szChannel = "MSG_SKILL_SELF_SKILL"
	elseif IsPartyData(dwCaster) then
		szChannel = "MSG_SKILL_PARTY_SKILL"
	elseif IsPlayer(dwCaster) then
		szChannel = "MSG_SKILL_OTHERS_SKILL"
	else
		szChannel = "MSG_SKILL_NPC_SKILL"
	end
	return szChannel
end;

GetChannelOnSkillCastRespond=function(dwCaster)
	return "MSG_SKILL_SELF_FAILED"
end;

GetChannelOnMiss=function(dwCaster, dwTarget)
	local szChannel = nil
	if IsSelfData(dwCaster) or IsSelfData(dwTarget) then
		szChannel = "MSG_SKILL_SELF_MISS"
	elseif IsPartyData(dwCaster) or IsPartyData(dwTarget) then
		szChannel = "MSG_SKILL_PARTY_MISS"
	elseif IsPlayer(dwCaster) or IsPlayer(dwTarget) then
	    szChannel = "MSG_SKILL_OTHERS_MISS"
    else
        szChannel = "MSG_SKILL_NPC_SKILL"
	end
	return szChannel
end;

GetChannelOnHit=function(dwCaster, dwTarget)
	local szChannel = nil
	if IsSelfData(dwCaster) or IsSelfData(dwTarget) then
		szChannel = "MSG_SKILL_SELF_SKILL"
	elseif IsPartyData(dwCaster) or IsPartyData(dwTarget) then
		szChannel = "MSG_SKILL_PARTY_SKILL"
    elseif IsPlayer(dwCaster) or IsPlayer(dwTarget) then
        szChannel = "MSG_SKILL_OTHERS_SKILL"
    else
    	szChannel = "MSG_SKILL_NPC_SKILL"
	end
	return szChannel
end;

GetChannelOnShield=function(dwCaster, dwTarget)
	local szChannel = nil
	if IsSelfData(dwCaster) or IsSelfData(dwTarget) then
		szChannel = "MSG_SKILL_SELF_SKILL"
	else
		szChannel = "MSG_SKILL_PARTY_SKILL"
	end
	return szChannel
end;

GetChannelOnDodge=function(dwCaster, dwTarget)
	local szChannel = nil
	if IsSelfData(dwCaster) or IsSelfData(dwTarget) then
		szChannel = "MSG_SKILL_SELF_SKILL"
	else
		szChannel = "MSG_SKILL_PARTY_SKILL"
	end

	return szChannel
end;

GetChannelOnInsight=function(dwCaster, dwTarget)
	local szChannel = nil
	if IsSelfData(dwCaster) or IsSelfData(dwTarget) then
		szChannel = "MSG_SKILL_SELF_SKILL"
	else
		szChannel = "MSG_SKILL_PARTY_SKILL"
	end

	return szChannel
end;

GetChannelOnParry=function(dwCaster, dwTarget)
	local szChannel = nil
	if IsSelfData(dwCaster) or IsSelfData(dwTarget) then
		szChannel = "MSG_SKILL_SELF_SKILL"
	else
		szChannel = "MSG_SKILL_PARTY_SKILL"
	end

	return szChannel
end;

GetChannelOnBlock=function(dwCaster, dwTarget)
	local szChannel = nil
	if IsSelfData(dwCaster) or IsSelfData(dwTarget) then
		szChannel = "MSG_SKILL_SELF_SKILL"
	else
		szChannel = "MSG_SKILL_PARTY_SKILL"
	end

	return szChannel
end;

GetChannelOnDamage=function(dwCaster, dwTarget)
	local szChannel = nil
	if IsSelfData(dwCaster) or IsSelfData(dwTarget) then
		szChannel = "MSG_SKILL_SELF_SKILL"
    else
		szChannel = "MSG_SKILL_PARTY_SKILL"
	end

	return szChannel
end;

GetChannelOnTherapy=function(dwCaster, dwTarget)
	local szChannel = nil
	if IsSelfData(dwCaster) or IsSelfData(dwTarget) then
		szChannel = "MSG_SKILL_SELF_SKILL"
	else
		szChannel = "MSG_SKILL_PARTY_SKILL"
	end

	return szChannel
end;

GetChannelOnCommonHealth=function(dwTarget)
	local szChannel = nil
	if IsSelfData(dwTarget) then
		szChannel = "MSG_SKILL_SELF_SKILL"
	elseif IsPartyData(dwTarget) then
		szChannel = "MSG_SKILL_PARTY_SKILL"
	else
		szChannel = "MSG_SKILL_OTHERS_SKILL"
	end
	return szChannel
end;

GetChannelOnDeath=function(dwTarget)
	local szChannel = nil
	if IsSelfData(dwTarget) then
		szChannel = "MSG_SKILL_SELF_SKILL"
	elseif IsPartyData(dwTarget) then
		szChannel = "MSG_SKILL_PARTY_SKILL"
	else
		szChannel = "MSG_SKILL_OTHERS_SKILL"
	end

	return szChannel
end;

GetChannelOnBuff=function(dwTarget, bCanCancel)
	local szChannel = nil
	if bCanCancel then
		if IsSelfData(dwTarget) then
			szChannel = "MSG_SKILL_SELF_BUFF"
		elseif IsPartyData(dwTarget) then
			szChannel = "MSG_SKILL_PARTY_BUFF"
		end
	else
		if IsSelfData(dwTarget) then
			szChannel = "MSG_SKILL_SELF_DEBUFF"
		elseif IsPartyData(dwTarget) then
			szChannel = "MSG_SKILL_PARTY_DEBUFF"
		end
	end
	return szChannel
end;



OnFrameBreathe=function()
	OnAcceleratProgressActive()
	OnAcceleratShakeFrame()
	if GlobalEventHandler.nEndFrame and GlobalEventHandler.nEndFrame > 0 then
		local nLeftSeconds = (GlobalEventHandler.nEndFrame - GetLogicFrameCount()) / 16;
		nLeftSeconds = math.ceil(nLeftSeconds)
		if nLeftSeconds > 0 and GlobalEventHandler.nLastShowSecond ~= nLeftSeconds then
		    OutputMessage("MSG_ANNOUNCE_YELLOW", FormatString(g_tStrings.STR_PK_START_DUEL_CALCULAGRAPH, nLeftSeconds));
		    GlobalEventHandler.nLastShowSecond = nLeftSeconds
		end
	end
--[[
	if Station.GetIdleTime() > AUTO_EXIT_INTERVAL then
		if not IsAutoExitPanelOpened() and not IsQueueOpened() then
			OpenAutoExitPanel()
		end
	end
]]
	OnCommentObjectBreathe()

	Macro_OnActive()

	for szKey, fnAction in pairs(GlobalEventHandler.tBreatheAction) do
		assert(fnAction)
		fnAction()
	end
	
	GlobalEventHandler.ShowLeftTimeBeAddFoe()
	GlobalEventHandler.ShowLeftTimeAddFoe()
	
	UpdatePlayerSyncFrameInterval()
end;

ShowLeftTimeBeAddFoe=function()
	for szName, _ in pairs(GlobalEventHandler.tBeAddFoeEndSeconds) do
		if GlobalEventHandler.tBeAddFoeEndSeconds[szName] and GlobalEventHandler.tBeAddFoeEndSeconds[szName] > 0 then
			local nLeftSeconds = GlobalEventHandler.tBeAddFoeEndSeconds[szName] - math.ceil(GetTickCount() / 1000)
			if nLeftSeconds > 0 and GlobalEventHandler.tLastShowBeAddFoeLeftSeconds[szName] ~= nLeftSeconds then
			    OutputMessage("MSG_SYS", nLeftSeconds..g_tStrings.STR_BUFF_H_TIME_S.."\n");
			    GlobalEventHandler.tLastShowBeAddFoeLeftSeconds[szName] = nLeftSeconds
			end
		end
	end
end;

ShowLeftTimeAddFoe=function()
	for szName, _ in pairs(GlobalEventHandler.tAddFoeEndSeconds) do
		if GlobalEventHandler.tAddFoeEndSeconds[szName] and GlobalEventHandler.tAddFoeEndSeconds[szName] > 0 then
			local nLeftSeconds = GlobalEventHandler.tAddFoeEndSeconds[szName] - math.ceil(GetTickCount() / 1000)
			if nLeftSeconds > 0 and GlobalEventHandler.tLastShowAddFoeLeftSeconds[szName] ~= nLeftSeconds then
			    OutputMessage("MSG_SYS", nLeftSeconds..g_tStrings.STR_BUFF_H_TIME_S.."\n");
			    GlobalEventHandler.tLastShowAddFoeLeftSeconds[szName] = nLeftSeconds
			end
		end
	end
end;

}

function GlobalEventHandler.OnFrameRender()
	-- OnAcceleratProgressActive()
end

function GlobalEventHandler.ShowNoTimeMessage()
	local tLeftTime = {[0] = "30", [19] = "25", [37] = "20", [56] = "15", [75] = "10", [94] = "5", [97] = "4", [101] = "3", [105] = "2", [108] = "1"}
	local szTime = tLeftTime[nLeftTimeRemindCount]

	if szTime then
		local tMsg =
		{
			bRichText = true,
			szMessage = FormatString(g_tStrings.STR_NO_TIME_TIP, szTime, tUrl.Recharge),
			szName = "NoTimeTip",
			{
			    szOption = g_tStrings.STR_CLICK_RECHARGE,
			     fnAction = function()
			        OpenInternetExplorer(tUrl.Recharge, true)
			     end
			},
		}
		MessageBox(tMsg)
	end

	nLeftTimeRemindCount = nLeftTimeRemindCount + 1
end

function GlobalEventHandler.LoadingEnd()
    LoadActionBarSetting()
    local player = GetClientPlayer()
    if player.nMoveState == MOVE_STATE.ON_DEATH then
        --CreateRevivePanel(player.GetReviveLeftFrame() / GLOBAL.GAME_FPS + 1)
    end
    GlobalEventHandler.UpdatePartyMark(true)

    player.UpdateFellowshipInfo()
    player.UpdateFoeInfo()
    player.UpdateBlackListInfo()
	GlobalEventHandler.ShowTongMessage()
end

function GlobalEventHandler.ShowTongMessage()
	local player = GetClientPlayer();
	local guild = GetTongClient();

	if not player or player.dwTongID == 0 then
		return
	end

	if not guild then
		return
	end

	local szMessage = guild.szOnlineMessage;
	if szMessage and #szMessage > 0 then
		local szMsg = g_tStrings.STR_TALK_HEAD_TONG..g_tStrings.STR_GUILD_ONLINE_MSG..szMessage
		if string.sub(szMessage, -1, -1) ~= "\n" then
			szMsg = szMsg .."\n"
		end
		OutputMessage("MSG_GUILD", szMsg)
	end
end

function RegisterBreatheEvent(szKey, fnAction)
	assert(type(szKey) == "string")
	GlobalEventHandler.tBreatheAction[szKey] = fnAction
end
