CHARACTER_ROLE_TURN_YAW = math.pi / 18

local EQUIPMENT_SUIT_COUNT = 3

CharacterPanel={
	m_aCameraInfo = {
		[0] = { -30, 160, -25, 0, 150, 0 }, --rtInvalid = 0,
		[1] = { 0, 70, -240, 0, 100, 150 }, --rtStandardMale,     // 标准男
		[2] = { 0, 78, -235, 0, 100, 150 }, --rtStandardFemale,   // 标准女
		[3] = { -30, 160, -25, 0, 150, 0 }, --rtStrongMale,       // 魁梧男
		[4] = { -30, 160, -25, 0, 150, 0 }, --rtSexyFemale,       // 性感女
		[5] = { -30, 160, -25, 0, 150, 0 }, --rtLittleBoy,        // 小男孩
		[6] = { 0, 70, -215, 0, 80, 150 }  --rtLittleGirl,       // 小孩女
	};
	
	m_nObjectType = INVENTORY_INDEX.EQUIP;
	
	m_boxHightLightBox1 = nil;
	m_boxHightLightBox2 = nil;
	
	m_aRepresentID = nil;
	m_CharacterModelView = nil;
	m_RidesModelView = nil;
	
	m_bShowExtent = true;
	
	m_bShowDesignation = false;
	m_bShowPendant = false;
	m_bShowWeaponBag = true;
    nReputationSelForceID = nil,
    tReputationCollapse = {},
    m_nSelectSuitIndex = 0,
};

RegisterCustomData("CharacterPanel.m_bShowWeaponBag")
RegisterCustomData("CharacterPanel.m_bShowExtent")
RegisterCustomData("CharacterPanel.nReputationSelForceID")
RegisterCustomData("CharacterPanel.tReputationCollapse")

function CharacterPanel.GetPageBattle()
	return Station.Lookup("Normal/CharacterPanel/Page_Main/Page_Battle")
end

function CharacterPanel.GetPageRides()
	return Station.Lookup("Normal/CharacterPanel/Page_Main/Page_Ride")
end

function CharacterPanel.GetFrame()
	return Station.Lookup("Normal/CharacterPanel")
end

function CharacterPanel.PlayerStateUpdate()
	local player = GetClientPlayer()
	if not player then
		return
	end
	local handle = CharacterPanel.GetPageBattle():Lookup("", "")	
	local szForce = g_tStrings.tForceTitle[player.dwForceID]
	if not szForce then
		szForce = g_tStrings.STR_CHARACTER_NO_FORCE
	end

	handle:Lookup("Text_Lv"):SetText(FormatString(g_tStrings.STR_CHARACTER_LV_FORCE, player.nLevel, szForce))	
end

function CharacterPanel.InitEvents()
	this:RegisterEvent("UI_SCALED")
    this:RegisterEvent("PLAYER_STATE_UPDATE")
    this:RegisterEvent("PLAYER_LEVEL_UPDATE")
    this:RegisterEvent("EQUIP_ITEM_UPDATE")
    this:RegisterEvent("PLAYER_DISPLAY_DATA_UPDATE")
    this:RegisterEvent("CURRENT_PLAYER_FORCE_CHANGED")
    this:RegisterEvent("UPDATE_REPUTATION")
    this:RegisterEvent("LOADING_END")
    this:RegisterEvent("UPDATE_KILL_POINT")
	this:RegisterEvent("UPDATE_CAMP_INFO")
	this:RegisterEvent("OPEN_CHAR_INFO")
	this:RegisterEvent("CLOSE_CHAR_INFO")
	this:RegisterEvent("OPEN_DESIGNATION_PANEL")
	this:RegisterEvent("CLOSE_DESIGNATION_PANEL")
	this:RegisterEvent("OPEN_PENDANT_PANEL")
	this:RegisterEvent("CLOSE_PENDANT_PANEL")
	this:RegisterEvent("ON_SLECT_WAIST_PENDANT")
	this:RegisterEvent("ON_SLECT_BACK_PENDANT")
	this:RegisterEvent("ON_PENDANT_LIST_CHANGED")
	this:RegisterEvent("CHANGE_CAMP")
	this:RegisterEvent("SYNC_DESIGNATION_DATA")
	this:RegisterEvent("SET_CURRENT_DESIGNATION")
	this:RegisterEvent("CHANGE_CAMP_FLAG")
	this:RegisterEvent("SKILL_MOUNT_KUNG_FU")
	this:RegisterEvent("SWITCH_BIGSWORD")
	this:RegisterEvent("CHARACTER_PANEL_BRING_TOP")
	this:RegisterEvent("SET_MINI_AVATAR")
	this:RegisterEvent("OPEN_FEPRODUCE_PANEL")
	this:RegisterEvent("CLOSE_FEPRODUCE_PANEL")
	this:RegisterEvent("EQUIP_CHANGE")
	this:RegisterEvent("UNEQUIPALL")
	this:RegisterEvent("SYNC_EQUIPID_ARRAY")
	this:RegisterEvent("OPEN_WEAPON_BAG")
	this:RegisterEvent("CLOSE_WEAPON_BAG")
    this:RegisterEvent("ON_SET_EXTERIOR_SET_RESPOND")
    this:RegisterEvent("PLAYER_HIDE_HAT_CHANGE")
end

function CharacterPanel.UpdateDesignation(frame)
	local player = GetClientPlayer()
	if not player then
		return
	end
	frame:Lookup("Page_Main/Page_Battle", "Text_Designation"):SetText(GetPlayerDesignation(player.dwID))
end

function CharacterPanel.UpdateAllEquipBox(page)
	if not page then
		return
	end
	
	for i = 0, EQUIPMENT_INVENTORY.TOTAL, 1 do
		local box = CharacterPanel.GetEquipBox(page, i)
		if box then
		    box:SetBoxIndex(i)
			box:SetOverTextPosition(0, ITEM_POSITION.RIGHT_BOTTOM)
			box:SetOverTextFontScheme(0, 15)
			CharacterPanel.UpdataEquipItem(i)
		end
	end
	CharacterPanel.UpdatePendant(page)
end

function CharacterPanel.UpdatePendant(page)
	local boxWaistPendant = page:Lookup("Wnd_Equit", "Box_Waist_Extend")
	local boxBackPendant = page:Lookup("Wnd_Equit", "Box_Back_Extend")
	boxWaistPendant.bPendant = true
	boxBackPendant.bPendant = true
	local player = GetClientPlayer()
	if player then
		local t = player.GetRepresentID() or {}
		local nWaist = t[EQUIPMENT_REPRESENT.WAIST_EXTEND]
		boxWaistPendant.nWaist = nWaist
		local itemInfo, dwTabType, dwTabIndex = GetWaistPendantItemInfo(nWaist)
		if itemInfo then
			boxWaistPendant:SetObject(UI_OBJECT_ITEM_INFO, itemInfo.nUiId, 0, dwTabType, dwTabIndex)
			boxWaistPendant:SetObjectIcon(Table_GetItemIconID(itemInfo.nUiId))
			UpdateItemBoxExtend(boxWaistPendant, itemInfo)		
		else
			boxWaistPendant:ClearObject()
		end
		
		local nBack = t[EQUIPMENT_REPRESENT.BACK_EXTEND]
		boxBackPendant.nBack = nBack
		local itemInfo, dwTabType, dwTabIndex = GetBackPendantItemInfo(nBack)
		if itemInfo then
			boxBackPendant:SetObject(UI_OBJECT_ITEM_INFO, itemInfo.nUiId, 0, dwTabType, dwTabIndex)
			boxBackPendant:SetObjectIcon(Table_GetItemIconID(itemInfo.nUiId))
			UpdateItemBoxExtend(boxBackPendant, itemInfo)		
		else
			boxBackPendant:ClearObject()
		end
	else
		boxWaistPendant:ClearObject()
		boxBackPendant:ClearObject()
	end
end

function CharacterPanel.UpdateAnimation(wndCangJian, bHeavySwordSelected)
	if not wndCangJian then
		return
	end
	
	if bHeavySwordSelected then
		wndCangJian:Lookup("", "Animate_HeavySword"):Show()
		wndCangJian:Lookup("", "Animate_LightSword"):Hide()
		wndCangJian:Lookup("CheckBox_SwitchSword"):Check(true)
	else
		wndCangJian:Lookup("", "Animate_HeavySword"):Hide()
		wndCangJian:Lookup("", "Animate_LightSword"):Show()
		wndCangJian:Lookup("CheckBox_SwitchSword"):Check(false)
	end
end

function CharacterPanel.InitPageBattle()
	local player = GetClientPlayer()
	if not player then
		return
	end

	local page = CharacterPanel.GetPageBattle()
	
	local wndWeapon = page:Lookup("Wnd_Weapon")
	local wndCangJian = page:Lookup("Wnd_CangJian")
	
	if player.bCanUseBigSword then
		wndWeapon:Hide()
		wndCangJian:Show()
		CharacterPanel.UpdateAnimation(wndCangJian, player.bBigSwordSelected)
	else
		wndWeapon:Show()
		wndCangJian:Hide()
	end
		
	CharacterPanel.UpdateAllEquipBox(page)
    
    page:Lookup("CheckBox_Hide"):Check(player.bHideHat)
    page:Lookup("CheckBox_ShowExterior"):Check(player.IsApplyExterior())
    page:Lookup("", "Text_Title"):SetText(player.szName)

    -----------------人物显示-----------------
	local scene = page:Lookup("Scene_Role")
	local w, h = scene:GetSize()

	local ci = CharacterPanel.m_aCameraInfo[player.nRoleType]
	if CharacterPanel.m_CharacterModelView then
		CharacterPanel.m_CharacterModelView:UnloadModel()
		CharacterPanel.m_CharacterModelView:release()
		CharacterPanel.m_CharacterModelView = nil
	end
	
	CharacterPanel.m_CharacterModelView = PlayerModelView.new()
	CharacterPanel.m_CharacterModelView:init()
	CharacterPanel.m_CharacterModelView:SetCamera({ ci[1], ci[2], ci[3], ci[4], ci[5], ci[6], math.pi / 4, w / h, nil, nil, true })
	scene:SetScene(CharacterPanel.m_CharacterModelView.m_scene)
	CharacterPanel.m_fRoleYaw = 0
	CharacterPanel.m_bTurnLeft = false;
	CharacterPanel.m_bTurnRight = false;
	CharacterPanel.UpdatePlayerShow()
	
	CharacterPanel.UpdateKillPoint(page:GetRoot())
	CharacterPanel.UpdateEquipScores(page:GetRoot())
	
	CharacterPanel.UpdateMiniAvatar(page)
	CharacterPanel.UpdateEquipControl(page)
end

function CharacterPanel.UpdateEquipControl(page)
	local player = GetClientPlayer()
	if not player then
		return
	end
	
	if not page then
		page = CharacterPanel.GetPageBattle()
	end
	
	local nIndex = player.GetEquipIDArray(0) + 1
	CharacterPanel.nEquipIndex = nIndex
	
	local check = {}
	for i = 1, EQUIPMENT_SUIT_COUNT do
		check[i] = page:Lookup("CheckBox_PageNum" .. i)
		check[i].bIgnore = true
		check[i]:Check(i == nIndex)
		check[i].bIgnore = false
	end
end

function CharacterPanel.SetEquipSuitIndex(index)
	local player = GetClientPlayer()
	if not player then
		return
	end
	
	if index < 1 or index > EQUIPMENT_SUIT_COUNT then
		return
	end
	
	RemoteCallToServer("OnExchangeEquipBackUp", index - 1)
end

function CharacterPanel.UpdateMiniAvatar(page)
	local player = GetClientPlayer()
	if not player then
		return
	end

	if not page then
		page = CharacterPanel.GetPageBattle()
	end
	
	local roleChangeHandle = page:Lookup("", "Handle_RoleChange")
	local imgRole = roleChangeHandle:Lookup("Image_Player")
	if player.dwMiniAvatarID == 0 then
		local szFileName = RoleChange.GetSchoolAvatarPath(player.dwForceID)
		imgRole:SetImageType(IMAGE.NORMAL)
		imgRole:FromTextureFile(szFileName)
	else
		local tAvatar = RoleChange.tAvatars[player.dwMiniAvatarID]
		if tAvatar then
			local szFileName = RoleChange.GetRoleAvatarPath(tAvatar.szFileName)
			imgRole:SetImageType(IMAGE.FLIP_HORIZONTAL)
			imgRole:FromTextureFile(szFileName)
		end
	end
end

function CharacterPanel.InitPageRides()
	local page = CharacterPanel.GetPageRides()

    page:Lookup("", "Box_RideBox"):SetBoxIndex(EQUIPMENT_INVENTORY.HORSE)
    page:Lookup("", "Box_RideEquipBox1").nMountIndex = ENCHANT_INDEX.MOUNT1
    page:Lookup("", "Box_RideEquipBox2").nMountIndex = ENCHANT_INDEX.MOUNT2
    page:Lookup("", "Box_RideEquipBox3").nMountIndex = ENCHANT_INDEX.MOUNT3
    page:Lookup("", "Box_RideEquipBox4").nMountIndex = ENCHANT_INDEX.MOUNT4

    CharacterPanel.UpdataRideItem()
 
	-----------------坐骑显示-----------------
	local scene = page:Lookup("Scene_Rides")
	local wr, hr = scene:GetSize()
	if CharacterPanel.m_RidesModelView then
		CharacterPanel.m_RidesModelView:UnloadRidesModel()
		CharacterPanel.m_RidesModelView:release()
		CharacterPanel.m_RidesModelView = nil
	end
	
	CharacterPanel.m_RidesModelView = RidesModelView.new()
	CharacterPanel.m_RidesModelView:init()
	CharacterPanel.m_RidesModelView:SetCamera({ 0, 120, -410, 0, 150, 150, math.pi / 4, wr / hr, nil, nil, true })
	scene:SetScene(CharacterPanel.m_RidesModelView.m_scene)
	CharacterPanel.m_fRidesYaw = math.pi / 10
	CharacterPanel.m_bRidesTurnLeft = false
	CharacterPanel.m_bRidesTurnRight = false
	CharacterPanel.UpdateRidesShow()
end

function CharacterPanel.OnFrameCreate()
	CharacterPanel.InitEvents()
	
	this.bIniting = true
	
	CharacterPanel.Update(this)
	
	this.bIniting = false
	
	this.nLoopCount = 0
	
	InitFrameAutoPosInfo(this, 2, nil, nil, function() CloseCharacterPanel(true) end)
end

function CharacterPanel.Update(frame)
	CharacterPanel.m_aRepresentID = nil
	
	CharacterPanel.UpdateDesignation(frame)
	
	CharacterPanel.InitPageBattle()
	CharacterPanel.InitPageRides()
	
	CharacterPanel.HighlightHandItemEquipPos()

    CharacterPanel.PlayerStateUpdate()
    CharacterPanel.InitReputation(frame:Lookup("Page_Main/Page_Reputation"))
    
	CharacterPanel.UpdateCampButton(frame)
	
	CharacterPanel.InitCampPage(frame:Lookup("Page_Main/Page_Camp"))
end

function CharacterPanel.OnFrameBreathe()
	local player = GetClientPlayer()
	if not player then
		return
	end
	
	local page = CharacterPanel.GetPageBattle()
	if page and page:IsVisible() then
		for i = 0, EQUIPMENT_INVENTORY.TOTAL, 1 do
			local box = CharacterPanel.GetEquipBox(page, i)
			if box then
				UpdataItemCDProgress(player, box, INVENTORY_INDEX.EQUIP, box:GetBoxIndex())			
			end
		end

		if CharacterPanel.m_bTurnLeft then
			CharacterPanel.m_fRoleYaw = CharacterPanel.m_fRoleYaw + CHARACTER_ROLE_TURN_YAW
			CharacterPanel.m_CharacterModelView.m_modelRole["MDL"]:SetYaw(CharacterPanel.m_fRoleYaw)
		elseif CharacterPanel.m_bTurnRight then
			CharacterPanel.m_fRoleYaw = CharacterPanel.m_fRoleYaw - CHARACTER_ROLE_TURN_YAW
			CharacterPanel.m_CharacterModelView.m_modelRole["MDL"]:SetYaw(CharacterPanel.m_fRoleYaw)
		end
	end
	
	local RidesPage = CharacterPanel.GetPageRides()
	if RidesPage and RidesPage:IsVisible() then
		if CharacterPanel.m_RidesModelView and CharacterPanel.m_RidesModelView.m_RidesMDL then
			if CharacterPanel.m_bRidesTurnLeft then
				CharacterPanel.m_fRidesYaw = CharacterPanel.m_fRidesYaw + CHARACTER_ROLE_TURN_YAW
				CharacterPanel.m_RidesModelView.m_RidesMDL["MDL"]:SetYaw(CharacterPanel.m_fRidesYaw)
			elseif CharacterPanel.m_bRidesTurnRight then
				CharacterPanel.m_fRidesYaw = CharacterPanel.m_fRidesYaw - CHARACTER_ROLE_TURN_YAW
				CharacterPanel.m_RidesModelView.m_RidesMDL["MDL"]:SetYaw(CharacterPanel.m_fRidesYaw)
			end
		end
	end
	
	local szText, szTime = CampActiveTime.GetTime()
	local hPage = this:Lookup("Page_Main/Page_Camp")
	local hOthersContent = hPage:Lookup("", "Handle_CampAll/Handle_Others/Handle_OthersContent")
	local textLeftTime1 = hOthersContent:Lookup("Text_WarLeftTime1")
	local textLeftTime2 = hOthersContent:Lookup("Text_WarLeftTime2")
	textLeftTime1:SetText(szText)
	textLeftTime2:SetText(szTime)
end

function CharacterPanel.OnFrameDestroy()
	if CharacterPanel.m_CharacterModelView then
		CharacterPanel.m_CharacterModelView:UnloadModel()
		CharacterPanel.m_CharacterModelView:release()
		CharacterPanel.m_CharacterModelView = nil
	end
	
	if CharacterPanel.m_RidesModelView then
		CharacterPanel.m_RidesModelView:UnloadRidesModel()
		CharacterPanel.m_RidesModelView:release()
		CharacterPanel.m_RidesModelView = nil
	end
end

function CharacterPanel.UnmountAllEquip()
	RemoteCallToServer("OnUnEquipAll", CharacterPanel.m_nSelectSuitIndex - 1)
end

function CharacterPanel.OnChangeEquipResult(result)
	if result == ITEM_RESULT_CODE.SPRINT then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.SRT_ERROR_CAN_NOT_CHANGE_SPRINT)
		return
	end
	
	if result == ITEM_RESULT_CODE.ERROR_EQUIP_PLACE
		or result == ITEM_RESULT_CODE.FORCE_ERROR
		or result == ITEM_RESULT_CODE.TOO_LOW_AGILITY
		or result == ITEM_RESULT_CODE.TOO_LOW_STRENGTH
		or result == ITEM_RESULT_CODE.TOO_LOW_SPIRIT
		or result == ITEM_RESULT_CODE.TOO_LOW_VITALITY
		or result == ITEM_RESULT_CODE.CANNOT_EQUIP
		or result == ITEM_RESULT_CODE.CANNOT_PUT_THAT_PLACE
		or result == ITEM_RESULT_CODE.GENDER_ERROR
		or result == ITEM_RESULT_CODE.FAILED
		or result == ITEM_RESULT_CODE.CAMP_CAN_NOT_EQUIP then
		local msg = {
			szMessage = FormatString(g_tStrings.STR_UNEQUIP_ALL, CharacterPanel.m_nSelectSuitIndex, CharacterPanel.m_nSelectSuitIndex), 
			szName = "UnequipMsgBox", 
			{szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = CharacterPanel.UnmountAllEquip, szSound = g_sound.Trade},
			{szOption = g_tStrings.STR_HOTKEY_CANCEL}
		}
		MessageBox(msg)
	elseif result ~= ITEM_RESULT_CODE.SUCCESS then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tItem_Msg[result])
	end
end

function CharacterPanel.OnUnmountAllEquipResult(result)
	if result ~= ITEM_RESULT_CODE.SUCCESS then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tItem_Msg[result])
	end
end

function CharacterPanel.OnEvent(event)
	if event == "UI_SCALED" then
		CharacterPanel.UpdatePlayerShow()
		CharacterPanel.UpdateRidesShow()
  
	elseif event == "PLAYER_STATE_UPDATE" then
		if arg0 == GetClientPlayer().dwID then
			CharacterPanel.PlayerStateUpdate()
		end
	elseif event == "PLAYER_LEVEL_UPDATE" then
		if arg0 == GetClientPlayer().dwID then
			CharacterPanel.PlayerStateUpdate()
		end
	elseif event == "EQUIP_ITEM_UPDATE" then
		if arg0 == INVENTORY_INDEX.EQUIP then
			if arg1 == EQUIPMENT_INVENTORY.HORSE then
				CharacterPanel.UpdataRideItem()
			else
				CharacterPanel.UpdataEquipItem(arg1)
				CharacterPanel.UpdateEquipScores(this)
			end
		end
	elseif event == "PLAYER_DISPLAY_DATA_UPDATE" then
		if arg0 == GetClientPlayer().dwID then
			CharacterPanel.UpdatePlayerShow()
			CharacterPanel.UpdateRidesShow()
		end
	elseif event == "CURRENT_PLAYER_FORCE_CHANGED" then
		CharacterPanel.Update(this)
	elseif event == "UPDATE_REPUTATION" then
		if arg1 then
			CharacterPanel.InitReputation(this:Lookup("Page_Main/Page_Reputation"))
		else
			CharacterPanel.UpdateReputation(this:Lookup("Page_Main/Page_Reputation"), arg0)
		end
	elseif event == "LOADING_END" then
		CharacterPanel.Update(this)
	elseif event == "UPDATE_KILL_POINT" then
	    CharacterPanel.UpdateKillPoint(this)
	elseif event == "UPDATE_CAMP_INFO" then
		if IsCharacterPanelOpened() then
			local hPage = this:Lookup("Page_Main/Page_Camp")
			local bRankMinimize = hPage:Lookup("", "Handle_CampAll/Handle_RankInfo").bMinimize
			local bCampMinimize = hPage:Lookup("", "Handle_CampAll/Handle_CampInfo").bMinimize
			local bOtherMinimize = hPage:Lookup("", "Handle_CampAll/Handle_Others").bMinimize
			CharacterPanel.UpdateCampPage(hPage, bRankMinimize, bCampMinimize, bOtherMinimize)
		end
	elseif event == "CHANGE_CAMP" or event == "CHANGE_CAMP_FLAG" then
		local hPlayer = GetClientPlayer()
		if hPlayer and hPlayer.dwID == arg0 then
			CharacterPanel.UpdateCampButton(this)
			if IsCharacterPanelOpened() then
				local hPage = this:Lookup("Page_Main/Page_Camp")
				local bRankMinimize = hPage:Lookup("", "Handle_CampAll/Handle_RankInfo").bMinimize
				local bCampMinimize = hPage:Lookup("", "Handle_CampAll/Handle_CampInfo").bMinimize
				local bOtherMinimize = hPage:Lookup("", "Handle_CampAll/Handle_Others").bMinimize
				CharacterPanel.UpdateCampPage(hPage, bRankMinimize, bCampMinimize, bOtherMinimize)
			end
		end
	elseif event == "OPEN_CHAR_INFO" then
		CharacterPanel.m_bShowExtent = true
		CharacterPanel.UpdateFrameSize(this, false)
		local c = this:Lookup("Page_Main/Page_Battle/CheckBox_Info")
		c.bDisable = true
		c:Check(true)
		c.bDisable = false
	elseif event == "CLOSE_CHAR_INFO" then
		if arg0 then
			CharacterPanel.m_bShowExtent = false
		end
		CharacterPanel.UpdateFrameSize(this, true)
		local c = this:Lookup("Page_Main/Page_Battle/CheckBox_Info")
		c.bDisable = true
		c:Check(false)
		c.bDisable = false
	elseif event == "OPEN_DESIGNATION_PANEL" then
		CharacterPanel.m_bShowDesignation = true		
		CharacterPanel.UpdateFrameSize(this, false)
		local c = this:Lookup("Page_Main/Page_Battle/CheckBox_Designation")
		c.bDisable = true
		c:Check(true)
		c.bDisable = false		
	elseif event == "CLOSE_DESIGNATION_PANEL" then
		if arg0 then
			CharacterPanel.m_bShowDesignation = false
		end
		CharacterPanel.UpdateFrameSize(this, true)
		local c = this:Lookup("Page_Main/Page_Battle/CheckBox_Designation")
		c.bDisable = true
		c:Check(false)
		c.bDisable = false
	elseif event == "OPEN_PENDANT_PANEL" then
		CharacterPanel.m_bShowPendant = true		
		CharacterPanel.UpdateFrameSize(this, false)
		local c = this:Lookup("Page_Main/Page_Battle/CheckBox_Pendant")
		c.bDisable = true
		c:Check(true)
		c.bDisable = false		
	elseif event == "CLOSE_PENDANT_PANEL" then
		if arg0 then
			CharacterPanel.m_bShowPendant = false
		end
		CharacterPanel.UpdateFrameSize(this, true)
		local c = this:Lookup("Page_Main/Page_Battle/CheckBox_Pendant")
		c.bDisable = true
		c:Check(false)
		c.bDisable = false
	elseif event == "OPEN_WEAPON_BAG" then
		CharacterPanel.m_bShowWeaponBag = true
		
	elseif event == "CLOSE_WEAPON_BAG" then
		if arg0 then
			CharacterPanel.m_bShowWeaponBag = false
		end
		
	elseif event == "ON_SLECT_WAIST_PENDANT" or event == "ON_PENDANT_LIST_CHANGED" or event == "ON_SLECT_BACK_PENDANT" then
		CharacterPanel.UpdatePendant(CharacterPanel.GetPageBattle())
	elseif event == "SYNC_DESIGNATION_DATA" or event == "SET_CURRENT_DESIGNATION" then
		if arg0 == GetClientPlayer().dwID then
			CharacterPanel.UpdateDesignation(this)
		end
	elseif event == "SKILL_MOUNT_KUNG_FU" then
		local player = GetClientPlayer()
		local page = CharacterPanel.GetPageBattle()
		local wndWeapon = page:Lookup("Wnd_Weapon")
		local wndCangJian = page:Lookup("Wnd_CangJian")
		if player and player.bCanUseBigSword then
			wndWeapon:Hide()
			wndCangJian:Show()
			CharacterPanel.UpdateAnimation(wndCangJian, player.bBigSwordSelected)
		else
			wndWeapon:Show()
			wndCangJian:Hide()
		end
		CharacterPanel.UpdateAllEquipBox(page)
	elseif event == "SWITCH_BIGSWORD" then
		local player = GetClientPlayer()
		local page = CharacterPanel.GetPageBattle()
		local wndCangJian = page:Lookup("Wnd_CangJian")
		if player and player.bCanUseBigSword then
			CharacterPanel.UpdateAnimation(wndCangJian, arg0 ~= 0)
		end
	elseif event == "CHARACTER_PANEL_BRING_TOP" then
		this:BringToTop()
	elseif event == "SET_MINI_AVATAR" then
		CharacterPanel.UpdateMiniAvatar()
	elseif event == "EQUIP_CHANGE" then
		CharacterPanel.OnChangeEquipResult(arg0)
		CharacterPanel.Update(CharacterPanel.GetFrame())
	elseif event == "UNEQUIPALL" then
		CharacterPanel.OnUnmountAllEquipResult(arg0)
		CharacterPanel.Update(CharacterPanel.GetFrame())
	elseif event == "SYNC_EQUIPID_ARRAY" then
		CharacterPanel.Update(CharacterPanel.GetFrame())
    elseif event == "ON_SET_EXTERIOR_SET_RESPOND" then
        local hPage = CharacterPanel.GetPageBattle()
        hPage:Lookup("CheckBox_ShowExterior"):Check(true)
    elseif event == "PLAYER_HIDE_HAT_CHANGE" then
        local hPlayer = GetClientPlayer()
        if hPlayer then
            local hPage = CharacterPanel.GetPageBattle()
            hPage:Lookup("CheckBox_Hide"):Check(hPlayer.bHideHat)
        end
	end
end

function CharacterPanel.OnSetFocus()
	FireEvent("CHARACTER_PANEL_BRING_TOP")
end

function CharacterPanel.UpdateFrameSize(frame, bClose)
	local w, h = frame:GetSize()
	if bClose then
		w = w - 230
	else
		w = w + 230
	end
	--local w, h = 380, 554
	--[[
	if IsCharInfoOpened() then
		w = w + 230
	end
	
	if IsDesignationPanelOpened() then
		w = w  230
	end
	
	if IsPendantPanelOpened() then
		w = w + 230
	end
	]]
	frame:SetSize(w, h)
	CorrectAutoPosFrameAfterClientResize()
end

function CharacterPanel.UpdateKillPoint(frame)
	local text = frame:Lookup("Page_Main/Page_Battle", "Text_RageValue")
	local player = GetClientPlayer()
	if not player then
		return
	end
	local nValue = player.nCurrentKillPoint
	local nFont = 162
	if nValue <= 0 then
		nFont = 162
	elseif nValue <= 100 then
		nFont = 162
	elseif nValue <= 300 then
		nFont = 157
	elseif nValue < 500 then
		nFont = 164
	else
		nFont = 111
	end
	text:SetText(nValue)
	text:SetFontScheme(nFont)
end

function CharacterPanel.OutputScoresTip(handle, player)
	local nBaseScores = player.GetBaseEquipScore()
	local nStrengthScores = player.GetStrengthEquipScore()
	local nStoneScores = player.GetMountsEquipScore()
	
	local szTip = FormatString(g_tStrings.STR_ITEM_H_ITEM_SCORE, nBaseScores + nStrengthScores + nStoneScores)
	local x, y = handle:GetAbsPos()
	local w, h = handle:GetSize()
	szTip = GetFormatText(szTip.."\n", 157)
	szTip = szTip .. g_tStrings.STR_EQUIP_SCORES_TIP
	szTip = szTip .. GetFormatText("\n\n")
	szTip = szTip .. GetFormatText(g_tStrings.STR_EQUIP_BASE_SCORES ..g_tStrings.STR_COLON..nBaseScores.."\n")
	szTip = szTip .. GetFormatText(g_tStrings.STR_EQUIP_STRENGTH_SCORES ..g_tStrings.STR_COLON..nStrengthScores.."\n")
	szTip = szTip .. GetFormatText(g_tStrings.STR_EQUIP_STONE_SCORES ..g_tStrings.STR_COLON..nStoneScores.."\n")
	OutputTip(szTip, 400, {x, y, w, h})
end

function CharacterPanel.OutputSingleScoresTip(handle, szName, nScores)
	local x, y = handle:GetAbsPos()
	local w, h = handle:GetSize()
	szTip = GetFormatText(szName ..g_tStrings.STR_COLON..nScores.."\n")
	OutputTip(szTip, 400, {x, y, w, h})
end

function CharacterPanel.UpdateEquipScores(frame, player)
	local text = frame:Lookup("Page_Main/Page_Battle", "Text_EquipScores")
	
	local image = frame:Lookup("Page_Main/Page_Battle", "Image_EquipS")
	local imageH1 = frame:Lookup("Page_Main/Page_Battle", "Image_EquipSorce1")
	local imageH2 = frame:Lookup("Page_Main/Page_Battle", "Image_EquipSorce2")
	local imageH3 = frame:Lookup("Page_Main/Page_Battle", "Image_EquipSorce3")
	
	local image1 = frame:Lookup("Page_Main/Page_Battle", "Image_EquipSorce1_1")
	local image2 = frame:Lookup("Page_Main/Page_Battle", "Image_EquipSorce2_1")
	local image3 = frame:Lookup("Page_Main/Page_Battle", "Image_EquipSorce3_1")
	
	if not player then
		player = GetClientPlayer()
	end
	
	local nBaseScores = player.GetBaseEquipScore()
	local nStrengthScores = player.GetStrengthEquipScore()
	local nStoneScores = player.GetMountsEquipScore()
	local nScores =  nBaseScores + nStrengthScores + nStoneScores
	if nScores > 0 then
		text:SetText(nScores)
	else
		text:SetText("")
	end
	
	local nScoreLevel = GetEquipScoresLevel(nScores)
	image:SetFrame(101 + nScoreLevel)
	
	image1:Hide()
	image2:Hide()
	image3:Hide()
	if nBaseScores > 0 then
		image1:Show()
	end
	if nStrengthScores > 0 then
		image2:Show()
	end
	if nStoneScores > 0 then
		image3:Show()
	end
	
	imageH1.OnItemMouseEnter=function()
		CharacterPanel.OutputSingleScoresTip(this, g_tStrings.STR_EQUIP_BASE_SCORES, nBaseScores)
	end
	image1.OnItemMouseEnter = imageH1.OnItemMouseEnter
	
	imageH2.OnItemMouseEnter=function()
		CharacterPanel.OutputSingleScoresTip(this, g_tStrings.STR_EQUIP_STRENGTH_SCORES, nStrengthScores)
	end
	image2.OnItemMouseEnter = imageH2.OnItemMouseEnter
	
	imageH3.OnItemMouseEnter=function()
		CharacterPanel.OutputSingleScoresTip(this, g_tStrings.STR_EQUIP_STONE_SCORES, nStoneScores)
	end
	image3.OnItemMouseEnter = imageH3.OnItemMouseEnter
	
	text.OnItemMouseLeave=function()
		HideTip()
	end
	image.OnItemMouseLeave=text.OnItemMouseLeave
	imageH1.OnItemMouseLeave=text.OnItemMouseLeave
	imageH2.OnItemMouseLeave=text.OnItemMouseLeave
	imageH3.OnItemMouseLeave=text.OnItemMouseLeave
	image1.OnItemMouseLeave=text.OnItemMouseLeave
	image2.OnItemMouseLeave=text.OnItemMouseLeave
	image3.OnItemMouseLeave=text.OnItemMouseLeave	
	
	text.OnItemMouseEnter=function()
		CharacterPanel.OutputScoresTip(this, player)
	end
	
	image.OnItemMouseEnter=function()
		CharacterPanel.OutputScoresTip(this, player)
	end
end

function CharacterPanel.IsPlayerRepresentModified(player)
	local bModified = false

	if not CharacterPanel.m_aRepresentID then
		CharacterPanel.m_aRepresentID = player.GetRepresentID()
		bModified = true
	else
		local aRepresentID = player.GetRepresentID()
		for i, v in pairs(aRepresentID) do
			if v ~= CharacterPanel.m_aRepresentID[i] then
				CharacterPanel.m_aRepresentID[i] = v
				bModified = true
			end
		end
	end
	
	return bModified
end

function CharacterPanel.UpdatePlayerShow()
	local player = GetClientPlayer()
	if not player then
		return
	end
	if not CharacterPanel.m_CharacterModelView then
		return
	end

	if CharacterPanel.IsPlayerRepresentModified(player) then
		CharacterPanel.m_CharacterModelView:UnloadModel()
		CharacterPanel.m_CharacterModelView:LoadPlayerRes(player.dwID, false)
		CharacterPanel.m_CharacterModelView:LoadModel()
		CharacterPanel.m_CharacterModelView:PlayAnimation("Idle", "loop")
		
		if CharacterPanel.m_CharacterModelView.m_modelRole then
			CharacterPanel.m_CharacterModelView.m_modelRole["MDL"]:SetYaw(CharacterPanel.m_fRoleYaw)
		end
	end
end

function CharacterPanel.UpdateRidesShow()
	local player = GetClientPlayer()
	if not player then
		return
	end
	if not CharacterPanel.m_RidesModelView then
		return
	end
	
	if not CharacterPanel.m_aRepresentID then
		return
	end
	
	local nHorseStyle = CharacterPanel.m_aRepresentID[EQUIPMENT_REPRESENT.HORSE_STYLE]
	if nHorseStyle == 0 then
		CharacterPanel.m_RidesModelView:UnloadRidesModel()
	else
		CharacterPanel.m_RidesModelView:UnloadRidesModel()
		CharacterPanel.m_RidesModelView:LoadRidesRes(player.dwID, false)
		CharacterPanel.m_RidesModelView:LoadRidesModel()
		CharacterPanel.m_RidesModelView:PlayRidesAnimation("Idle", "loop")
		
		if CharacterPanel.m_RidesModelView.m_RidesMDL then
			CharacterPanel.m_RidesModelView.m_RidesMDL["MDL"]:SetYaw(CharacterPanel.m_fRidesYaw)
		end
	end
end

function CharacterPanel.UpdataRideName(item)
	local text = CharacterPanel.GetPageRides():Lookup("", "Text_RideName")
	if item then
		text:SetText(GetItemNameByItem(item))
	else
		text:SetText("")
	end
end

function CharacterPanel.UpdataRideItem()
	local player = GetClientPlayer()
	if not player then
		return
	end
    local box = CharacterPanel.GetPageRides():Lookup("", "Box_RideBox")
    if not box then
        return
    end 
    local item = GetPlayerItem(player, INVENTORY_INDEX.EQUIP, EQUIPMENT_INVENTORY.HORSE)
    CharacterPanel.UpdataRideName(item)
    UpdataItemBoxObject(box, INVENTORY_INDEX.EQUIP, EQUIPMENT_INVENTORY.HORSE, item)
    
	if item and item.nDetail ~= 0 then
		local page = CharacterPanel.GetPageRides()
	
	    for i = 1, 4 do
	    	page:Lookup("", "Image_RideBox"..i):Hide()
	    	page:Lookup("", "Box_RideEquipBox"..i):Hide()
	    	page:Lookup("Btn_Unload"..i):Hide()
	    end
	else
		local page = CharacterPanel.GetPageRides()
	
	    for i = 1, 4 do
	    	page:Lookup("", "Image_RideBox"..i):Show()
	    	page:Lookup("", "Box_RideEquipBox"..i):Show()
	    	page:Lookup("Btn_Unload"..i):Show()
	    end
	end

    for i = 1, 4 do
    	local boxRideEquip = CharacterPanel.GetPageRides():Lookup("", "Box_RideEquipBox"..i)
    	if not boxRideEquip then
            return
    	end
    	if item then
            local nUiId = GetItemEnchantUIID(item.GetMountEnchantID(boxRideEquip.nMountIndex));
            UpdateMountBoxObject(boxRideEquip, nUiId, nUiId > 0)
        else
            UpdateMountBoxObject(boxRideEquip, nil, false)
        end
    end
end

function CharacterPanel.GetEquipBox(page, nIndex)
	if nIndex == EQUIPMENT_INVENTORY.HELM then
		return page:Lookup("Wnd_Equit", "Box_Helm")
	elseif nIndex == EQUIPMENT_INVENTORY.CHEST then
		return page:Lookup("Wnd_Equit", "Box_Chest")
	elseif nIndex == EQUIPMENT_INVENTORY.BANGLE then
		return page:Lookup("Wnd_Equit", "Box_Bangle")
	elseif nIndex == EQUIPMENT_INVENTORY.WAIST then
		return page:Lookup("Wnd_Equit", "Box_Waist")
	elseif nIndex == EQUIPMENT_INVENTORY.PANTS then
		return page:Lookup("Wnd_Equit", "Box_Pants")
	elseif nIndex == EQUIPMENT_INVENTORY.BOOTS then
		return page:Lookup("Wnd_Equit", "Box_Boots")
	elseif nIndex == EQUIPMENT_INVENTORY.AMULET then
		return page:Lookup("Wnd_Equit", "Box_Amulet")
	elseif nIndex == EQUIPMENT_INVENTORY.PENDANT then
		return page:Lookup("Wnd_Equit", "Box_Pendant")
	elseif nIndex == EQUIPMENT_INVENTORY.LEFT_RING then
		return page:Lookup("Wnd_Equit", "Box_LeftRing")
	elseif nIndex == EQUIPMENT_INVENTORY.RIGHT_RING then
		return page:Lookup("Wnd_Equit", "Box_RightRing")
	end
	
	local wndWeapon = page:Lookup("Wnd_Weapon")
	local wndCangJian = page:Lookup("Wnd_CangJian")
	if wndWeapon:IsVisible() then
		if nIndex == EQUIPMENT_INVENTORY.MELEE_WEAPON then
			return wndWeapon:Lookup("", "Box_MeleeWeapon")
		elseif nIndex == EQUIPMENT_INVENTORY.RANGE_WEAPON then
			return wndWeapon:Lookup("", "Box_RangeWeapon")
		elseif nIndex == EQUIPMENT_INVENTORY.ARROW then
			return wndWeapon:Lookup("", "Box_AmmoPouch")
		end
	elseif wndCangJian:IsVisible() then
		if nIndex == EQUIPMENT_INVENTORY.MELEE_WEAPON then
			return wndCangJian:Lookup("", "Box_LightSword")
		elseif nIndex == EQUIPMENT_INVENTORY.BIG_SWORD then
			return wndCangJian:Lookup("", "Box_HeavySword")
		elseif nIndex == EQUIPMENT_INVENTORY.RANGE_WEAPON then
			return wndCangJian:Lookup("", "Box_RangeWeaponCJ")
		elseif nIndex == EQUIPMENT_INVENTORY.ARROW then
			return wndCangJian:Lookup("", "Box_AmmoPouchCJ")
		end
	end
end

function CharacterPanel.UpdataEquipItem(nItemIndex)
    local player = GetClientPlayer()
    if not player then
    	return
    end
    local box = CharacterPanel.GetEquipBox(CharacterPanel.GetPageBattle(), nItemIndex)
    if not box then --如果是背包，就不存在
        return
    end
    local item = GetPlayerItem(player, INVENTORY_INDEX.EQUIP, nItemIndex)
    UpdataItemBoxObject(box, INVENTORY_INDEX.EQUIP, nItemIndex, item)
end

function CharacterPanel.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_Close" then
		CloseCharacterPanel()
--[[
	elseif szName == "Btn_SwitchCampFlag" then
		local hPlayer = GetClientPlayer()
		if hPlayer.bCampFlag then
			RemoteCallToServer("OnCloseCampFlag")
		else
			local tMsg = 
			{
				szMessage = g_tStrings.STR_CONFIRM_MSG_CAMP_FLAG,
				szName = "Camp_Flag_Confirm_Msg",
				{szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = function() RemoteCallToServer("OnOpenCampFlag") end, },
				{szOption = g_tStrings.STR_HOTKEY_CANCEL, },
			}
			MessageBox(tMsg)
		end
--]]
	elseif string.sub(szName, 1, string.len("Btn_Unload")) == "Btn_Unload" then
		--卸除马具
		local nIndex = string.sub(szName, -1)
		local page = CharacterPanel.GetPageRides()
		local box = page:Lookup("", "Box_RideEquipBox"..nIndex)
		if not box:IsEmpty() then
		    local nMountIndex = box.nMountIndex
		    UnMountRidesEquip(nMountIndex)
		end
	elseif szName == "Btn_RoleChange" then
		OpenRoleChangePanel()
	elseif szName == "Btn_PagePrev" then
		CharacterPanel.m_nSelectSuitIndex = CharacterPanel.nEquipIndex - 1
		CharacterPanel.SetEquipSuitIndex(CharacterPanel.nEquipIndex - 1)
	elseif szName == "Btn_PageNext" then
		CharacterPanel.m_nSelectSuitIndex = CharacterPanel.nEquipIndex + 1
		CharacterPanel.SetEquipSuitIndex(CharacterPanel.nEquipIndex + 1)
    elseif szName == "Btn_Clothes" then
        OpenExteriorBox()
	end
end

function CharacterPanel.OnLButtonDown()
	local szName = this:GetName()
	if szName == "Btn_TurnLeft" then
		CharacterPanel.m_bTurnLeft = true
		CharacterPanel.m_bTurnRight = false
	elseif szName == "Btn_TurnRight" then
		CharacterPanel.m_bTurnRight = true
		CharacterPanel.m_bTurnLeft = false
	elseif szName == "Btn_RidesTurnLeft" then
		CharacterPanel.m_bRidesTurnLeft = true
		CharacterPanel.m_bRidesTurnRight = false
	elseif szName == "Btn_RidesTurnRight" then
		CharacterPanel.m_bRidesTurnLeft = false
		CharacterPanel.m_bRidesTurnRight = true
	end
end

function CharacterPanel.OnLButtonUp()
	local szName = this:GetName()
	if szName == "Btn_TurnLeft" then
		CharacterPanel.m_bTurnLeft = false
	elseif szName == "Btn_TurnRight" then
		CharacterPanel.m_bTurnRight = false
	elseif szName == "Btn_RidesTurnLeft" then
		CharacterPanel.m_bRidesTurnLeft = false
	elseif szName == "Btn_RidesTurnRight" then
		CharacterPanel.m_bRidesTurnRight = false
	end
end

function CharacterPanel.UpdateSwitchCampFlagState(handle)
	if not handle then
		return
	end
	
	local img = handle:Lookup("Image_SwitchCampFlag")
	if not handle.bEnable then
		img:SetFrame(41)
	elseif handle.bDown then
		img:SetFrame(40)
	elseif handle.bOver then
		img:SetFrame(39)
	else
		img:SetFrame(38)
	end
end
-----------左键操作----------------
function CharacterPanel.OnItemLButtonDown()
	this.bIgnoreClick = nil
	if this:GetName() == "Handle_SwitchCampFlag" then
		this.bDown = true
		CharacterPanel.UpdateSwitchCampFlagState(this)
		return
	elseif IsCtrlKeyDown() and not this:IsEmpty() then
		if this.bPendant then
			local _, nVersion, dwTabType, dwIndex = this:GetObjectData()
			if IsGMPanelReceiveItem() then
				GMPanel_LinkItemInfo(nVersion, dwTabType, dwIndex)
			else
				EditBox_AppendLinkItemInfo(nVersion, dwTabType, dwIndex, this.count)
			end			
		else
			local _, dwBox, dwX = this:GetObjectData()
			if IsGMPanelReceiveItem() then
				GMPanel_LinkItem(dwBox, dwX)
			else		
				EditBox_AppendLinkItem(dwBox, dwX)
			end
		end
		this.bIgnoreClick = true
	end
	
	this:SetObjectPressed(1)
end

function CharacterPanel.OnItemLButtonUp()
	if this:GetName() == "Handle_SwitchCampFlag" then
		this.bDown = false
		CharacterPanel.UpdateSwitchCampFlagState(this)
		return
	end
	
	this:SetObjectPressed(0)
end

function CharacterPanel.OnItemLButtonDrag()
	this:SetObjectPressed(0)
	
	if this.bPendant then
		return
	end
	
	if not this:IsObjectEnable() then
		return
	end
	
	if UserSelect.DoSelectItem(CharacterPanel.m_nObjectType, this:GetBoxIndex()) then
		return
	end
	
	if (IsShiftKeyDown() and not IsCursorInExclusiveMode()) or Cursor.GetCurrentIndex() == CURSOR.SPLIT then
		OnSplitBoxItem(this)
		return
	end	
	
	if Hand_IsEmpty() then
		if not this:IsEmpty() then
			if IsCursorInExclusiveMode() then
				OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.SRT_ERROR_CANCEL_CURSOR_STATE)
				PlayTipSound("010")
			else
				Hand_Pick(this)
			end
		end
	end
end

function CharacterPanel.OnItemLButtonDragEnd()
	this.bIgnoreClick = true
	
	if not this:IsObjectEnable() then
		if not Hand_IsEmpty() and not this:IsEmpty() then
			local box = Hand_Get()
			local dwType, _, dwBox, dwX = box:GetObjectData()
			local dwTType, _, dwTBox, dwTX = this:GetObjectData()
			if dwType == dwTType and dwBox == dwTBox and dwX == dwTX then
				Hand_Clear()
			end
		end
		return
	end
	
	if string.sub(this:GetName(), 1, 16) == "Box_RideEquipBox" then
		local player = GetClientPlayer()
		local horse = player.GetItem(INVENTORY_INDEX.EQUIP, EQUIPMENT_INVENTORY.HORSE)
		if horse then
			local box = Hand_Get()
			local _, dwBox, dwX = box:GetObjectData()
			MountRidesEquip(dwBox, dwX)
		else
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.DIS_NOT_EQUIP_HORSE)
		end
		
		return
	end

	if not Hand_IsEmpty() then
		CharacterPanel.OnExchangeBoxAndHandBoxItem(this)
	end	
	this:SetObjectMouseOver(1)
end

function CharacterPanel.OnItemLButtonClick()
	if this:GetName() == "Handle_SwitchCampFlag" and this.bEnable then
		local hPlayer = GetClientPlayer()
		if hPlayer.bCampFlag then
			RemoteCallToServer("OnCloseCampFlag")
		else
			local tMsg = 
			{
				szMessage = g_tStrings.STR_CONFIRM_MSG_CAMP_FLAG,
				szName = "Camp_Flag_Confirm_Msg",
				{szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = function() RemoteCallToServer("OnOpenCampFlag") end, },
				{szOption = g_tStrings.STR_HOTKEY_CANCEL, },
			}
			MessageBox(tMsg)
		end
		return
	end
	
	local hFrame = this:GetRoot()
	local hPage = hFrame:Lookup("Page_Main"):GetActivePage()
	if hPage then
		local szPage = hPage:GetName()
		if szPage == "Page_Camp" then
			local bRankMinimize = hPage:Lookup("", "Handle_CampAll/Handle_RankInfo").bMinimize
			local bCampMinimize = hPage:Lookup("", "Handle_CampAll/Handle_CampInfo").bMinimize
			local bOtherMinimize = hPage:Lookup("", "Handle_CampAll/Handle_Others").bMinimize
			local szName = this:GetName()
			if szName == "Image_RankTitle" then
				CharacterPanel.UpdateCampPage(hPage, not bRankMinimize, bCampMinimize, bOtherMinimize)
			elseif szName == "Image_CampTitle" then
				if not bCampMinimize then
					FireDataAnalysisEvent("CLICK_CAMP")
				end
				
				CharacterPanel.UpdateCampPage(hPage, bRankMinimize, not bCampMinimize, bOtherMinimize)
			elseif szName == "Image_OTitle" then
				CharacterPanel.UpdateCampPage(hPage, bRankMinimize, bCampMinimize, not bOtherMinimize)
			end
			return
		end
	end
	
	if this.bIgnoreClick then
		this.bIgnoreClick = nil
		return
	end
	
	if not this:IsObjectEnable() then
		if not Hand_IsEmpty() and not this:IsEmpty() then
			local box = Hand_Get()
			local dwType, _, dwBox, dwX = box:GetObjectData()
			local dwTType, _, dwTBox, dwTX = this:GetObjectData()
			if dwType == dwTType and dwBox == dwTBox and dwX == dwTX then
				Hand_Clear()
			end
		end
		return
	end
	
	if this.bPendant then
		if not Hand_IsEmpty() then
			CharacterPanel.OnExchangeBoxAndHandBoxItem(this)
		end
		return
	end
	
	if UserSelect.DoSelectItem(CharacterPanel.m_nObjectType, this:GetBoxIndex()) then
		return
	end
	
	if (IsShiftKeyDown() and not IsCursorInExclusiveMode()) or Cursor.GetCurrentIndex() == CURSOR.SPLIT then
		OnSplitBoxItem(this)
		return
	end
	
	if Cursor.GetCurrentIndex() == CURSOR.REPAIRE or Cursor.GetCurrentIndex() == CURSOR.UNABLEREPAIRE then	--修理物品
		if not this:IsEmpty() then
			ShopRepairItem(CharacterPanel.m_nObjectType, this:GetBoxIndex())
		end
		return
	end
	
	if Hand_IsEmpty() then
		if not this:IsEmpty() then
			if IsCursorInExclusiveMode() then
				OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.SRT_ERROR_CANCEL_CURSOR_STATE)
				PlayTipSound("010")
			else
				if this.bPendant then
					
				else
					Hand_Pick(this)
				end
			end
		end
	else
		CharacterPanel.OnExchangeBoxAndHandBoxItem(this)
	end	
	this:SetObjectMouseOver(1)
end

function CharacterPanel.OnExchangeBoxAndHandBoxItem(box)
	local boxHand, nHandCount = Hand_Get()	
	local nSourceType = boxHand:GetObjectType()
	if nSourceType == UI_OBJECT_SKILL then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_ERROR_CANNOT_DRAG_SKILL_IN_CHARACTORPANEL)
		return
	elseif nSourceType == UI_OBJECT_CRAFT then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_ERROR_CANNOT_DRAG_CRAFT_IN_CHARACTORPANEL)
		return
	elseif nSourceType == UI_OBJECT_OTER_PLAYER_ITEM then
		local _, dwBox, dwX, dwSaleID = boxHand:GetObjectData()
		local dwBox2 = CharacterPanel.m_nObjectType
		local dwX2 = box:GetBoxIndex()
		MarketTradePanel_BuyItem(dwBox, dwX, dwSaleID, dwBox2, dwX2)	
		Hand_Clear()	
		return
	elseif nSourceType ~= UI_OBJECT_ITEM then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_ERROR_CANNOT_DRAG_ITEM_IN_CHARACTORPANEL)
		return
	end
		
	local _, dwBox1, dwX1 = boxHand:GetObjectData()
	
	if box.bPendant then
		local bEquiped = false
		local player = GetClientPlayer()
		local item = player.GetItem(dwBox1, dwX1)
		if item and item.nGenre == ITEM_GENRE.EQUIPMENT then
			if item.nSub == EQUIPMENT_SUB.BACK_EXTEND then
				if box:GetName() == "Box_Back_Extend" then
					OnUsePendentItem(dwBox1, dwX1)
					bEquiped = true
				end
			elseif item.nSub == EQUIPMENT_SUB.WAIST_EXTEND then
				if box:GetName() == "Box_Waist_Extend" then
					OnUsePendentItem(dwBox1, dwX1)
					bEquiped = true
				end
			end
		end
		if not bEquiped then
			if box:GetName() == "Box_Back_Extend" then
				OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_ERROR_ONLY_BACK_PENDANT)
				PlayTipSound("012")
			elseif box:GetName() == "Box_Waist_Extend" then
				OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_ERROR_ONLY_WAIST_PENDANT)
				PlayTipSound("012_1")
			end
		end
		return
	end
	
	local dwBox2 = CharacterPanel.m_nObjectType
	local dwX2 = box:GetBoxIndex()
	
	if OnExchangeItem(dwBox1, dwX1, dwBox2, dwX2, nHandCount) then
		Hand_Clear()
	end
end

-----------右键操作------------------
function CharacterPanel.OnItemRButtonDown()
	this:SetObjectPressed(1)
end

function CharacterPanel.OnItemRButtonUp()
	this:SetObjectPressed(0)
end

function CharacterPanel.OnItemRButtonClick()
	if IsShiftKeyDown() and not this:IsEmpty() then
		OpenFEActivationPanel(this)
		return
	end
	
	if IsCtrlKeyDown() and not this:IsEmpty() then
		local player = GetClientPlayer()
		local _, dwBox, dwX = this:GetObjectData()
		
		if dwBox == INVENTORY_INDEX.EQUIP and 
		   dwX == EQUIPMENT_SUB.MELEE_WEAPON and IsCanWeaponBagOpen() then
			if IsWeaponBagOpen() then
				CloseWeaponBag(nil, true)
			else
				OpenWeaponBag()
			end
		end
		return
	end
	
	if this.bPendant then
		return
	end
	
	if IsShopOpened() then
		 OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_ERROR_SELL_ONLY_BAG_ITEM)
		 PlayTipSound("003")
		return
	end
	local nBoxIndex = CharacterPanel.m_nObjectType
	local nBoxItemIndex = this:GetBoxIndex()
	OnUseItem(nBoxIndex, nBoxItemIndex, this)
end

function CharacterPanel.GetAblityTitleTipText(szTitle, nBase, nCurrent)
	local szTitle = "<text>text="..EncodeComponentsString(szTitle..nCurrent.."("..nBase).."font=32</text>"
	if nCurrent == nBase then
		szTitle = szTitle.."<text>text=\")\\\n\"font=32</text>"
	elseif nCurrent > nBase then
		szTitle = szTitle.."<text>text=\"+"..(nCurrent - nBase).."\"font=36</text><text>text=\")\\\n\"font=32</text>"
	else
		szTitle = szTitle.."<text>text=\""..(nCurrent - nBase).."\"font=33</text><text>text=\")\\\n\"font=32</text>"
	end
	return szTitle
end

function CharacterPanel.GetSuitTip(index)
	local szTip = ""
	local szText = FormatString(g_tStrings.STR_SUIT_TIP, index)
	szTip = "<text>text=" .. EncodeComponentsString(szText) .. " font=60 r=255 g=255 b=255 </text>"
	if CharacterPanel.nEquipIndex == index then
		szTip = szTip .. "<text>text=" .. EncodeComponentsString(g_tStrings.STR_SUIT_EQUIPED) .. " font=192 </text>"
	else
		szTip = szTip .. "<text>text=" .. EncodeComponentsString(g_tStrings.STR_SUIT_EQUIP) .. " font=60 r=0 g=200 b=70 </text>"
	end
	return szTip
end

function CharacterPanel.OnItemMouseEnter()
	if this:GetType() == "Box" then
		this:SetObjectMouseOver(1)
		
		if this.bPendant then
			if not this:IsEmpty() then
				local x, y = this:GetAbsPos()
				local w, h = this:GetSize()
				if this:GetName() == "Box_Back_Extend" then
					OutputBackPendantTip(this.nBack, {x, y, w, h})
				elseif this:GetName() == "Box_Waist_Extend"  then
					OutputWaistPendantTip(this.nWaist, {x, y, w, h})
				end
			end
			return
		end
		
		if string.sub(this:GetName(), 1, 16) == "Box_RideEquipBox" then
			if not this:IsEmpty() then
				local nUiId = this:GetObjectData()
				local x, y = this:GetAbsPos()
				local w, h = this:GetSize()
				OutputItemTip(UI_OBJECT_MOUNT, nUiId, nil, nil, {x, y, w, h})
			end
			return
		end

		if not this:IsEmpty() then
			local _, dwBox, dwX = this:GetObjectData()
			local x, y = this:GetAbsPos()
			local w, h = this:GetSize()
			-- 七夕戒指处理不同的额外TIP
			Player.dwQixiRingOwnerID = GetClientPlayer().dwID
			OutputItemTip(UI_OBJECT_ITEM, dwBox, dwX, nil, {x, y, w, h}, nil, nil, nil, true)
			Player.dwQixiRingOwnerID = nil
		end
		
		if UserSelect.IsSelectItem() then
			UserSelect.SatisfySelectItem(CharacterPanel.m_nObjectType, this:GetBoxIndex())
			return
		end
		
		if this:IsEmpty() then
			if Cursor.GetCurrentIndex() == CURSOR.SPLIT then
				Cursor.Switch(CURSOR.UNABLESPLIT)
			elseif Cursor.GetCurrentIndex() == CURSOR.REPAIRE then
				Cursor.Switch(CURSOR.UNABLEREPAIRE)			
			elseif not IsCursorInExclusiveMode() then
				Cursor.Switch(CURSOR.NORMAL)
			end
		else
			local _, dwBox, dwX = this:GetObjectData()
			if Cursor.GetCurrentIndex() == CURSOR.SPLIT then
				local item = GetPlayerItem(GetClientPlayer(), dwBox, dwX)
				if not item or not item.bCanStack or item.nStackNum < 2 then
					Cursor.Switch(CURSOR.UNABLESPLIT)
				end
			elseif Cursor.GetCurrentIndex() == CURSOR.REPAIRE then
				local item = GetPlayerItem(GetClientPlayer(), dwBox, dwX)
				if not item or not item.IsRepairable() then
					Cursor.Switch(CURSOR.UNABLEREPAIRE)
				end
			elseif not IsCursorInExclusiveMode() then
				Cursor.Switch(CURSOR.NORMAL)
			end
		end
	elseif this:GetName() == "Handle_SwitchCampFlag" then
		this.bOver = true
		CharacterPanel.UpdateSwitchCampFlagState(this)
	elseif this:GetName() == "Handle_PageNum1" then
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
		OutputTip(CharacterPanel.GetSuitTip(1), 400, {x, y, w, h})
	elseif this:GetName() == "Handle_PageNum2" then
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
		OutputTip(CharacterPanel.GetSuitTip(2), 400, {x, y, w, h})
	elseif this:GetName() == "Handle_PageNum3" then
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
		OutputTip(CharacterPanel.GetSuitTip(3), 400, {x, y, w, h})
	elseif this:GetName() == "Image_CampEmpty" then
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
		local hPlayer = GetClientPlayer()
		local szTip = GetFormatText(g_tStrings.STR_CAMP_PRESTIGE.. hPlayer.nCurrentPrestige.."/"..hPlayer.GetMaxPrestige())
		szTip = szTip .. GetFormatText(g_tStrings.STR_COMMA.. g_tStrings.STR_CURRENCY_REMAIN_GET..hPlayer.GetPrestigeRemainSpace())
        
		OutputTip(szTip, 400, {x, y, w, h})	
        
	elseif this:GetName() == "Image_Limit" then
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
        
		local hPlayer = GetClientPlayer()

		local szTip = GetFormatText(g_tStrings.STR_CURRENCY_REMAIN_GET.. hPlayer.GetPrestigeRemainSpace())
		OutputTip(szTip, 400, {x, y, w, h})	
	else
		local szName = this:GetName()
		local player = GetClientPlayer()
		local szTip = ""
		if szName == "Text_StrengthLabel" or szName == "Text_StrengthValue" then
			szTip = CharacterPanel.GetAblityTitleTipText(g_tStrings.MSG_STRENGTH, player.nStrengthBase, player.nCurrentStrength)
				.."<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_STRENGTH_UP, player.nCurrentStrength * 2)).."</text>"
		elseif szName == "Text_AgilityLabel" or szName == "Text_AgilityValue" then
			szTip = CharacterPanel.GetAblityTitleTipText(g_tStrings.MSG_AGILITY, player.nAgilityBase, player.nCurrentAgility)
				.."<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_AGILITY_UP1, player.nCurrentAgility * 3, player.nCurrentAgility * 2)).."</text>"
		elseif szName == "Text_VitalityLabel" or szName == "Text_VitalityValue" then
			szTip = CharacterPanel.GetAblityTitleTipText(g_tStrings.MSG_VIGOR, player.nVitalityBase, player.nCurrentVitality)
				.."<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_LIFE_UP1, player.nCurrentVitality * 10)).."</text>"
		elseif szName == "Text_SpiritLabel" or szName == "Text_SpiritValue" then
			szTip = CharacterPanel.GetAblityTitleTipText(g_tStrings.MSG_SPIRIT, player.nSpiritBase, player.nCurrentSpirit)
				.."<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_SPIRIT_UP1, player.nCurrentSpirit * 10, player.nCurrentSpirit)).."</text>"
		elseif szName == "Text_SpunkLabel" or szName == "Text_SpunkValue" then
			local value0 = math.floor(player.nCurrentSpunk * 0.075 + 0.5)
			local value1 = math.floor(player.nCurrentSpunk * 0.025 + 0.5)
			local value2 = player.nCurrentSpunk * 2
			szTip = CharacterPanel.GetAblityTitleTipText(g_tStrings.MSG_SPUNK, player.nSpunkBase, player.nCurrentSpunk)
				.."<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_SPUNK_REPLENISH_UP, value0, value1, value2)).."</text>"
		elseif szName == "Text_PhysicsDamageLabel" or szName == "Text_PhysicsDamageValue" then
			szTip = "<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_PHYSICS_ATTACK_WHAT, player.nPhysicsAttackPowerBase)).."font=32</text>"
				.."<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_PHYSICS_ATTACK_UP, player.nPhysicsAttackPowerBase)).."</text>"
		elseif szName == "Text_SolarMagicShieldLabel" or szName == "Text_SolarMagicShieldValue" then
			local value = string.format("%.2f", 100 * player.nSolarMagicShield / (player.nSolarMagicShield + 9 * player.nLevel)).."%"
			szTip = "<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_SOLAR_SHIELD_VALUE, player.nSolarMagicShield)).."font=32</text>"
				.."<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_SOLAR_DAMAGE_AVERAGE_DOWN, value)).."</text>"
		elseif szName == "Text_NeutralMagicShieldLabel" or szName == "Text_NeutralMagicShieldValue" then
			local value = string.format("%.2f", 100 * player.nNeutralMagicShield / (player.nNeutralMagicShield + 9 * player.nLevel)).."%"
			szTip = "<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_NEUTRAL_SHIELD_VALUE, player.nNeutralMagicShield)).."font=32</text>"
				.."<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_NEUTRAL_DAMAGE_AVERAGE_DOWN, value)).."</text>"
		elseif szName == "Text_LunarMagicShieldLabel" or szName == "Text_LunarMagicShieldValue" then
			local value = string.format("%.2f", 100 * player.nLunarMagicShield / (player.nLunarMagicShield + 9 * player.nLevel)).."%"
			szTip = "<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_LUNAR_SHIELD_VALUE, player.nLunarMagicShield)).."font=32</text>"
				.."<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_LUNAR_DAMAGE_AVERAGE_DOWN, value)).."</text>"		
		elseif szName == "Text_PoisonMagicShieldLabel" or szName == "Text_PoisonMagicShieldValue" then
			local value = string.format("%.2f", 100 * player.nPoisonMagicShield / (player.nPoisonMagicShield + 9 * player.nLevel)).."%"
			szTip = "<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_POISON_SHIELD_VALUE, player.nPoisonMagicShield)).."font=32</text>"
				.."<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_POISON_DAMAGE_AVERAGE_DOWN, value)).."</text>"		
		elseif szName == "Text_DefendLabel" or szName == "Text_DefendValue" then
			local value = string.format("%.2f", 100 * player.nPhysicsShield / (player.nLevel * 270 + player.nPhysicsShield)).."%"
			szTip = "<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_PHYSICS_SHIELD_VALUE, player.nPhysicsShield)).."font=32</text>"
				.."<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_PHYSICS_DAMAGE_AVERAGE_DOWN, value)).."</text>"
		elseif szName == "Image_Camp1" then
			local hCampInfo = GetCampInfo()
			szTip = "<text>text="..EncodeComponentsString(g_tStrings.STR_CAMP_LEVEL_TITLE[hCampInfo.nCampLevel]).."font=32</text>"
		elseif szName == "Text_RankNow2" then
			local nTitle = player.nTitle
			szTip = Table_GetTitleRankTip(nTitle)
		elseif szName == "Text_RankNext2" then
			local nTitle = player.nTitle
			szTip = Table_GetTitleRankTip(nTitle + 1)
		elseif szName == "Image_Rank2" then
			local nPointPercentage = player.GetRankPointPercentage()
			if nPointPercentage > 100 then
				nPointPercentage = 100
			end
			if nPointPercentage ~= -1 then
				if nPointPercentage == 100 and player.nTitle == 13 then
					szTip = "<text>text="..EncodeComponentsString(g_tStrings.STR_TITLE_NEED_RANK).."font=32</text>"
				else
					szTip = "<text>text="..EncodeComponentsString(tostring(nPointPercentage).."%").."font=32</text>"
				end
			end
		end
		
		if szTip ~= "" then
			local x, y = this:GetAbsPos()
			local w, h = this:GetSize()
			OutputTip(szTip, 400, {x, y, w, h})
		end		
	end		
end

function CharacterPanel.OnItemRefreshTip()
	return CharacterPanel.OnItemMouseEnter()
end

function CharacterPanel.OnItemMouseLeave()
	if this:GetType() == "Box" then
		this:SetObjectMouseOver(0)	
		HideTip()
		if UserSelect.IsSelectItem() then
			UserSelect.SatisfySelectItem(-1, -1, true)
			return
		end		
		
		if Cursor.GetCurrentIndex() == CURSOR.UNABLESPLIT then
			Cursor.Switch(CURSOR.SPLIT)
		elseif Cursor.GetCurrentIndex() == CURSOR.UNABLEREPAIRE then
			Cursor.Switch(CURSOR.REPAIRE)
		elseif not IsCursorInExclusiveMode() then
			Cursor.Switch(CURSOR.NORMAL)
		end
				
		if CharacterPanel.m_boxHightLightBox1 and CharacterPanel.m_boxHightLightBox1:IsValid() then
			local boxH = CharacterPanel.m_boxHightLightBox1
			if boxH and boxH:GetIndex() == this:GetIndex() then
				return
			end
		end
		if CharacterPanel.m_boxHightLightBox2 and CharacterPanel.m_boxHightLightBox2:IsValid() then
			local boxH = CharacterPanel.m_boxHightLightBox2
			if boxH and boxH:GetIndex() == this:GetIndex() then
				return
			end
		end
	elseif this:GetName() == "Handle_SwitchCampFlag" then
		this.bOver = false
		CharacterPanel.UpdateSwitchCampFlagState(this)
	else
		HideTip()
	end	
end

function CharacterPanel.UnHighlightHandItemEquipPos()
	if CharacterPanel.m_boxHightLightBox1 and CharacterPanel.m_boxHightLightBox1:IsValid() then
		local boxLast = CharacterPanel.m_boxHightLightBox1
		if boxLast then
			boxLast:SetObjectMouseOver(0)
		end
	end
	if CharacterPanel.m_boxHightLightBox2 and CharacterPanel.m_boxHightLightBox2:IsValid() then
		local boxLast = CharacterPanel.m_boxHightLightBox2
		if boxLast then
			boxLast:SetObjectMouseOver(0)
		end
	end	
	CharacterPanel.m_boxHightLightBox1 = nil
	CharacterPanel.m_boxHightLightBox2 = nil
end

function CharacterPanel.HighlightHandItemEquipPos()
	local box = Hand_Get()
	if not box then
		return
	end
	if box:GetObjectType() ~= UI_OBJECT_ITEM then
		return
	end
	local player = GetClientPlayer()
	local _, dwBox, dwX = box:GetObjectData()
	local item = GetPlayerItem(player, dwBox, dwX)
	if not item or item.nGenre ~= ITEM_GENRE.EQUIPMENT then
		return	--不是物品或者装备
	end
	
	CharacterPanel.UnHighlightHandItemEquipPos()
	
	local page = CharacterPanel.GetPageBattle()
	if not page then
		return
	end
	
	local boxHightLightBox1 = nil
	local boxHightLightBox2 = nil
	if item.nSub == EQUIPMENT_SUB.MELEE_WEAPON then
		boxHightLightBox1 = CharacterPanel.GetEquipBox(page, EQUIPMENT_INVENTORY.MELEE_WEAPON)
	elseif item.nSub == EQUIPMENT_SUB.RANGE_WEAPON then
		boxHightLightBox1 = CharacterPanel.GetEquipBox(page, EQUIPMENT_INVENTORY.RANGE_WEAPON)
	elseif item.nSub == EQUIPMENT_SUB.ARROW then
		boxHightLightBox1 = CharacterPanel.GetEquipBox(page, EQUIPMENT_INVENTORY.ARROW )
	elseif item.nSub == EQUIPMENT_SUB.CHEST then
		boxHightLightBox1 = CharacterPanel.GetEquipBox(page, EQUIPMENT_INVENTORY.CHEST)		
	elseif item.nSub == EQUIPMENT_SUB.HELM then
		boxHightLightBox1 = CharacterPanel.GetEquipBox(page, EQUIPMENT_INVENTORY.HELM)		
	elseif item.nSub == EQUIPMENT_SUB.AMULET then
		boxHightLightBox1 = CharacterPanel.GetEquipBox(page, EQUIPMENT_INVENTORY.AMULET)		
	elseif item.nSub == EQUIPMENT_SUB.RING then
		boxHightLightBox1 = CharacterPanel.GetEquipBox(page, EQUIPMENT_INVENTORY.LEFT_RING)		
		boxHightLightBox2 = CharacterPanel.GetEquipBox(page, EQUIPMENT_INVENTORY.RIGHT_RING)
	elseif item.nSub == EQUIPMENT_SUB.WAIST then
		boxHightLightBox1 = CharacterPanel.GetEquipBox(page, EQUIPMENT_INVENTORY.WAIST)		
	elseif item.nSub == EQUIPMENT_SUB.PENDANT then
		boxHightLightBox1 = CharacterPanel.GetEquipBox(page, EQUIPMENT_INVENTORY.PENDANT)		
	elseif item.nSub == EQUIPMENT_SUB.PANTS then
		boxHightLightBox1 = CharacterPanel.GetEquipBox(page, EQUIPMENT_INVENTORY.PANTS)		
	elseif item.nSub == EQUIPMENT_SUB.BOOTS then
		boxHightLightBox1 = CharacterPanel.GetEquipBox(page, EQUIPMENT_INVENTORY.BOOTS)		
	elseif item.nSub == EQUIPMENT_SUB.BANGLE then
		boxHightLightBox1 = CharacterPanel.GetEquipBox(page, EQUIPMENT_INVENTORY.BANGLE)		
	elseif item.nSub == EQUIPMENT_SUB.WAIST_EXTEND then
		boxHightLightBox1 = page:Lookup("Wnd_Equit", "Box_Waist_Extend")
	elseif item.nSub == EQUIPMENT_SUB.BACK_EXTEND then
		boxHightLightBox1 = page:Lookup("Wnd_Equit", "Box_Back_Extend")
	elseif item.nSub == EQUIPMENT_SUB.HORSE then
		boxHightLightBox1 = CharacterPanel.GetPageRides():Lookup("", "Box_RideBox")
	elseif item.nSub == EQUIPMENT_SUB.PACKAGE then 	--背包没有放在这里
	else
	end
	
	if boxHightLightBox1 then
		boxHightLightBox1:SetObjectMouseOver(1)
		CharacterPanel.m_boxHightLightBox1 = boxHightLightBox1
	end
	if boxHightLightBox2 then
		boxHightLightBox2:SetObjectMouseOver(1)
		CharacterPanel.m_boxHightLightBox2 = boxHightLightBox2
	end	
end

function CharacterPanel.OnCheckBoxCheck()
	local frame = this:GetRoot()
	if this.bIgnore or frame.bIniting then
		return
	end
	
	local szName = this:GetName()
	if szName == "CheckBox_Info" and not this.bDisable then
		OpenCharInfo()
		FireDataAnalysisEvent("FIRST_OPEN_CHARACTER_PROPERTY")
	elseif szName == "CheckBox_Designation" and not this.bDisable then
		OpenDesignationPanel()
	elseif szName == "CheckBox_Pendant" and not this.bDisable then
		OpenPendantPanel()
	elseif szName == "CheckBox_Hide" then
		local player = GetClientPlayer()
		if player then
			player.HideHat(true)
            FireUIEvent("PLAYER_HIDE_HAT_CHANGE")
		end
	elseif szName == "CheckBox_SwitchSword" then
		local player = GetClientPlayer()
		if player and not player.bBigSwordSelected and player.bCanUseBigSword then
			RemoteCallToServer("OnSelectBigSword")
		end
	elseif szName == "CheckBox_PageNum1" then
		CharacterPanel.m_nSelectSuitIndex = 1
		CharacterPanel.SetEquipSuitIndex(1)
	elseif szName == "CheckBox_PageNum2" then
		CharacterPanel.m_nSelectSuitIndex = 2
		CharacterPanel.SetEquipSuitIndex(2)
	elseif szName == "CheckBox_PageNum3" then
		CharacterPanel.m_nSelectSuitIndex = 3
		CharacterPanel.SetEquipSuitIndex(3)
    elseif szName == "CheckBox_Clothes" then
        OpenExteriorBox()
    elseif szName == "CheckBox_ShowExterior" then
        RemoteCallToServer("OnApplyExterior")
	end
end

function CharacterPanel.OnCheckBoxUncheck()
	local frame = this:GetRoot()
	if this.bIgnore or frame.bIniting then
		return
	end
	
	local szName = this:GetName()
	if szName == "CheckBox_Info" and not this.bDisable then
		CloseCharInfo()
	elseif szName == "CheckBox_Designation" and not this.bDisable then
		CloseDesignationPanel()
	elseif szName == "CheckBox_Pendant" and not this.bDisable then
		ClosePendantPanel()
	elseif szName == "CheckBox_Produce" and not this.bDisable then
		CloseFEProducePanel()
	elseif szName == "CheckBox_Hide" then
		local player = GetClientPlayer()
		if player then
			player.HideHat(false)
            FireUIEvent("PLAYER_HIDE_HAT_CHANGE")
		end
	elseif szName == "CheckBox_SwitchSword" then
		local player = GetClientPlayer()
		if player and player.bBigSwordSelected then
			RemoteCallToServer("OnSelectCommonWeapon")
		end
	elseif szName == "CheckBox_PageNum1" or szName == "CheckBox_PageNum2" or szName == "CheckBox_PageNum3" then
		this.bIgnore = true
		this:Check(true)
		this.bIgnore = false
    elseif szName == "CheckBox_Clothes" then
        CloseExteriorBox()
    elseif szName == "CheckBox_ShowExterior" then
        RemoteCallToServer("OnUnApplyExterior")
	end
end

function CharacterPanel.InitReputation(page)
    local hRepution = page:Lookup("", "")
	local handle = hRepution:Lookup("Handle_R")
	handle:Clear()
          
	local player = GetClientPlayer()
	if not player then
		return
	end
	
	handle.nCkeck = 30
	handle.nCkeckAndLock = 32
	handle.nUnCkeck = 27
	handle.nUnCkeckAndLock = 31
	
	handle.UpdateScrollInfo = function(handle)
		handle:FormatAllItemPos()
		local w, h = handle:GetSize()
		local wAll, hAll = handle:GetAllItemSize()
	
		local nStep = math.ceil((hAll - h) / 10)
		
		local scroll = handle:GetParent():GetParent():Lookup("Scroll_RepuScroll")
		scroll:SetStepCount(nStep)
		if nStep > 0 then
			scroll:Show()
			scroll:GetParent():Lookup("Btn_RepuUp"):Show()
			scroll:GetParent():Lookup("Btn_RepuDown"):Show()
		else
			scroll:Hide()
			scroll:GetParent():Lookup("Btn_RepuUp"):Hide()
			scroll:GetParent():Lookup("Btn_RepuDown"):Hide()			
		end	
	end
	
	handle.OnItemMouseWheel = function()
		local nDistance = Station.GetMessageWheelDelta()
		this:GetParent():GetParent():Lookup("Scroll_RepuScroll"):ScrollNext(nDistance)
		return 1
	end
	
	page:Lookup("Scroll_RepuScroll").OnScrollBarPosChanged = function()
		local nCurrentValue = this:GetScrollPos()
		local page = this:GetParent()
		if nCurrentValue == 0 then
			page:Lookup("Btn_RepuUp"):Enable(false)
		else
			page:Lookup("Btn_RepuUp"):Enable(true)
		end
		
		if nCurrentValue == this:GetStepCount() then
			page:Lookup("Btn_RepuDown"):Enable(false)
		else
			page:Lookup("Btn_RepuDown"):Enable(true)
		end
		
		local handle = page:Lookup("", "Handle_R")
	    handle:SetItemStartRelPos(0,  - 10 * nCurrentValue)
	end
	
	page:Lookup("Btn_RepuUp").OnLButtonDown = function()
		this.OnLButtonHold()
	end
	page:Lookup("Btn_RepuUp").OnLButtonHold = function()
		this:GetParent():Lookup("Scroll_RepuScroll"):ScrollPrev()
	end
	page:Lookup("Btn_RepuDown").OnLButtonDown = function()
		this.OnLButtonHold()
	end
	page:Lookup("Btn_RepuDown").OnLButtonHold = function()
		this:GetParent():Lookup("Scroll_RepuScroll"):ScrollNext()
	end
	
	local szIniFile = "UI/Config/Default/CharacterPanel.ini"
	
    local function UpdateBgState(hItem)
        local hImage = hItem:Lookup("Image_S")
        if not hImage then
            return
        end
        
        if hItem.bSel then
            hImage:Show();
        elseif hItem.bOver then
            hImage:Show();
        else
            hImage:Hide();
        end
    end
    
    local function UpdateSelect(hItem)
        local hList = hItem:GetParent();
        local hOldItem = hList.hSelItem
        if hOldItem then
            hOldItem.bSel = false;
            UpdateBgState(hOldItem)
        end
        hItem.bSel = true
        hList.hSelItem = hItem
        CharacterPanel.nReputationSelForceID = hItem.dwID
        UpdateBgState(hItem)
        if IsCharacterPanelOpened() and page and page:IsVisible() then
            CharacterPanel.ShowForceInfo(hItem.dwID, true)
        end
    end
    
    handle.hSelItem = nil
	for k, tVersion in ipairs(g_tReputation.tReputationGroupTable) do
		local hT1 = handle:AppendItemFromIni(szIniFile, "Handle_T")
		local szVersionName = tVersion.szVersionName
		hT1:SetName("")
		hT1.bTitle = true
        hT1.szTitle = szVersionName
		hT1:Lookup("Text_T"):SetText(szVersionName)
		if not CharacterPanel.tReputationCollapse[szVersionName] then
            hT1:Expand()
        else
            hT1:Collapse()
        end
		
		hT1.OnItemMouseEnter = function()
			this:Lookup("Image_O"):Show()
		end
		
		hT1.OnItemMouseLeave = function()
			this:Lookup("Image_O"):Hide()
		end
		
		hT1.OnItemLButtonDown = function()
			this:ExpandOrCollapse()
            local szName = this.szTitle
            CharacterPanel.tReputationCollapse[szName] = not CharacterPanel.tReputationCollapse[szName]
            
			PlaySound(SOUND.UI_SOUND,g_sound.Button)
			local hP = this:GetParent()
			hP.UpdateScrollInfo(hP)
		end
	    for id, v in ipairs(tVersion.tGroup) do
            local hT2 = handle:AppendItemFromIni(szIniFile, "Handle_T1")
            hT2.bGroup = true
            hT2:SetName("")
            hT2:Lookup("Text_T1"):SetText(v.szName)
            hT2.szTitle = szVersionName.."_"..v.szName
            if not CharacterPanel.tReputationCollapse[hT2.szTitle] then
                hT2:Expand()
            else
                hT2:Collapse()
            end
        
            hT2.OnItemMouseEnter = function()
                this:Lookup("Image_O1"):Show()
            end
            
            hT2.OnItemMouseLeave = function()
                this:Lookup("Image_O1"):Hide()
            end
            
            hT2.OnItemLButtonDown = function()
                this:ExpandOrCollapse()
                local szName = this.szTitle
                CharacterPanel.tReputationCollapse[szName] = not CharacterPanel.tReputationCollapse[szName]
                PlaySound(SOUND.UI_SOUND,g_sound.Button)
                local hP = this:GetParent()
                hP.UpdateScrollInfo(hP)
            end
            local dwPlayerFoceID = player.dwForceID
            local aForce = v.aForce
            for kI, vI in ipairs(aForce) do
                local aRep = g_tReputation.tReputationTable[vI]
                local bAdd = true
                if not aRep then
                    bAdd = false
                elseif aRep.bHide then
                    if not aRep.bInShow or dwPlayerFoceID ~= vI then
                        bAdd = false
                    end
                else
                    if aRep.nInNoShou and dwPlayerFoceID == aRep.nInNoShou then
                        bAdd = false
                    end
                end
                if player.IsReputationHide(vI) then
                    bAdd = false
                end
                --bAdd = true
                if bAdd then
                    local hI = handle:AppendItemFromIni(szIniFile, "Handle_C")
                    hI:SetName("")
                    local textR = hI:Lookup("Text_R")
                    textR:SetText(aRep.szName)
                    hI.dwID = vI
                    hI.szDesc = aRep.szDesc.." </text>"
                    hI.bForce = true
                    if not CharacterPanel.nReputationSelForceID then
                        CharacterPanel.nReputationSelForceID = vI;
                    end
                    
                    if CharacterPanel.nReputationSelForceID == vI then
                        UpdateSelect(hI)
                    end
                    
                    hI.OnItemMouseEnter = function()
                        this.bOver = true;
                        UpdateBgState(this);
                    end
                    
                    hI.OnItemMouseLeave = function()
                        this.bOver = false;
                        UpdateBgState(this);
                    end

                    hI.OnItemLButtonDown = function()
                        UpdateSelect(this)
                    end
                    
                    hI.OnItemRButtonDown = function()
                        this.OnItemLButtonDown()
                    end
                    
                    textR.OnItemMouseEnter = function()
                        local hP = this:GetParent()
                        hP.bOver = true;
                        UpdateBgState(hP);
                        
                        local x, y = this:GetAbsPos()
                        local w, h = this:GetSize()
                        OutputTip(hP.szDesc, 300, {x, y, w, h})				
                    end
                    
                    textR.OnItemMouseLeave = function()
                        HideTip()
                        local hP = this:GetParent();
                        hP.bOver = false;
                        UpdateBgState(hP);
                    end
                    
                    local textRL = hI:Lookup("Text_RL")
                    textRL.OnItemMouseEnter = function()
                        local hP = this:GetParent()
                        hP.bOver = true;
                        UpdateBgState(hP);
                        local x, y = this:GetAbsPos()
                        local w, h = this:GetSize()
                        local player = GetClientPlayer()
                        local szText = player.GetReputation(hP.dwID).."/"..GetReputeLimit(player.GetReputeLevel(hP.dwID))
                        OutputTip("<text>text="..EncodeComponentsString(szText).."</text>", 300, {x, y, w, h})
                    end
                    
                    textRL.OnItemMouseLeave = function()
                        HideTip()
                        local hP = this:GetParent();
                        hP.bOver = false;
                        UpdateBgState(hP);
                    end
                end
            end
            local nLast = handle:GetItemCount() - 1
            if nLast >= 0 and handle:Lookup(nLast).bGroup then
                handle:RemoveItem(nLast)
            end
		end
	end
	
	CharacterPanel.UpdateReputation(page)
    handle.UpdateScrollInfo(handle)
end

function CharacterPanel.ShowForceInfo(dwForceID, bHome)
    ReputationIntroduce_ShowInfo(dwForceID, bHome);
end

function CharacterPanel.GetReputeLevelText(nLevel)
	local v = g_tReputation.tReputationLevelTable[nLevel]
	if not v then
		return "", 0
	end
	return v.szLevel, v.nFont
end

function CharacterPanel.OnActivePage()
	local nLast = this:GetLastActivePageIndex()
	local nPage = this:GetActivePageIndex()
	if nLast ~= -1 and nPage ~= nLast then
		PlaySound(SOUND.UI_SOUND, g_sound.OpenFrame)
	end
	
    local hPage = this:GetActivePage()
    if hPage then
		local szPage = hPage:GetName()
        if szPage ~= "Page_Reputation" then
            if IsReputationIntroduceOpened() then
                CloseReputationIntroduce()
            end
        end
    end
    
    if hPage then
		local szPage = hPage:GetName()
		if szPage == "Page_Camp" then
			CharacterPanel.UpdateCampPage(hPage, false, false, false)
		end
	end
	
	local activePage = this:GetActivePage()
	if activePage and activePage:GetName() == "Page_Battle" then
		if CharacterPanel.m_bShowExtent then
			OpenCharInfo(true)
		else
			CloseCharInfo(true, true)
		end
		
		if CharacterPanel.m_bShowDesignation then
			OpenDesignationPanel(true)
		else
			CloseDesignationPanel(true, true)
		end
		
		if CharacterPanel.m_bShowPendant then
			OpenPendantPanel(true)
		else
			ClosePendantPanel(true, true)
		end
		
		if CharacterPanel.m_bShowWeaponBag and IsCanWeaponBagOpen() then
			OpenWeaponBag()
		else
			CloseWeaponBag(true)
		end
	else
		CloseCharInfo(true, true)
		CloseDesignationPanel(true, true)
		ClosePendantPanel(true, true)
		
		CloseWeaponBag(true)
	end
        
	if activePage then
		local szPage = activePage:GetName()
		if szPage == "Page_Reputation" then
            if CharacterPanel.nReputationSelForceID then
                CharacterPanel.ShowForceInfo(CharacterPanel.nReputationSelForceID, true)
            end
        end
    end
    
	if activePage then
		local szPageName = activePage:GetName()
		if szPageName == "Page_Reputation" then
			FireDataAnalysisEvent("FIRST_OPEN_REPUTATION_PANEL")
		elseif szPageName == "Page_Ride" then
			FireDataAnalysisEvent("FIRST_OPEN_HORSE_PANEL")
		elseif szPageName == "Page_Camp" then
			FireDataAnalysisEvent("FIRST_OPEN_CAMP_PANEL")
		end
	end
end

function CharacterPanel.UpdateReputation(page, dwForceID)
	local player = GetClientPlayer()
	if not player then
		return
	end
	local handle = page:Lookup("", "Handle_R")
	local nCount = handle:GetItemCount() - 1
	for i = 0, nCount, 1 do
		local hI = handle:Lookup(i)
		if hI.bForce and (not dwForceID or hI.dwID == dwForceID) then
			local nLevel = player.GetReputeLevel(hI.dwID)
			if not nLevel then
				return
			end
			local text = hI:Lookup("Text_RL")
			text:SetFontScheme(g_tReputation.tReputationLevelTable[nLevel].nFont)
			text:SetText(g_tReputation.tReputationLevelTable[nLevel].szLevel)
			
			local img = hI:Lookup("Image_R")
			img:SetFrame(g_tReputation.tReputationLevelTable[nLevel].nFrame)
			img:SetPercentage(player.GetReputation(hI.dwID) / GetReputeLimit(nLevel))
		end
	end	
end

function CharacterPanel.UpdateCampButton(hFrame)
	local hPlayer = GetClientPlayer()
	if hPlayer then
		hFrame:Lookup("Page_Main/CheckBox_Camp"):Enable(hPlayer.nCamp ~= CAMP.NEUTRAL)
	end
end

function CharacterPanel.GetPlayerTitleDesc(nTitle)
	if not nTitle or nTitle <= 0 or nTitle > 14 then
		return g_tStrings.STR_NONE, g_tStrings.STR_NONE
	end
	
	local player = GetClientPlayer()
	local szTitle, szTitleBuff = g_tStrings.STR_NONE, g_tStrings.STR_NONE
	local dwID = GetDesignationIDByTitleAndCamp(nTitle, player.nCamp)
	local t = g_tTable.Designation_Prefix:Search(dwID)
	if t then
		szTitle = t.szName
		local szTitleLevel = FormatString(g_tStrings.STR_CAMP_TITLE_LEVEL, g_tStrings.STR_CAMP_TITLE_NUMBER[nTitle])
		szTitle = szTitle.."("..szTitleLevel..")"
	end
	
	if nTitle > 7 then
		local aInfo = GetDesignationPrefixInfo(dwID)
		if aInfo then 
			szTitleBuff = GetBuffDesc(aInfo.dwBuffID, aInfo.nBuffLevel, "desc")
		end
	end
	
	return szTitle, szTitleBuff
end

function CharacterPanel.InitCampPage(page)
	local handle = page:Lookup("", "Handle_CampAll")
	
	handle.UpdateScrollInfo = function(handle)
		handle:FormatAllItemPos()
		local w, h = handle:GetSize()
		local wAll, hAll = handle:GetAllItemSize()
	
		local nStep = math.ceil((hAll - h) / 10)
		
		local scroll = handle:GetParent():GetParent():Lookup("Scroll_CampScroll")
		scroll:SetStepCount(nStep)
		if nStep > 0 then
			scroll:Show()
			scroll:GetParent():Lookup("Btn_CampUp"):Show()
			scroll:GetParent():Lookup("Btn_CampDown"):Show()
		else
			scroll:Hide()
			scroll:GetParent():Lookup("Btn_CampUp"):Hide()
			scroll:GetParent():Lookup("Btn_CampDown"):Hide()			
		end	
	end
	
	handle.OnItemMouseWheel = function()
		local nDistance = Station.GetMessageWheelDelta()
		this:GetParent():GetParent():Lookup("Scroll_CampScroll"):ScrollNext(nDistance)
		return 1
	end
	
	page:Lookup("Scroll_CampScroll").OnScrollBarPosChanged = function()
		local nCurrentValue = this:GetScrollPos()
		local page = this:GetParent()
		if nCurrentValue == 0 then
			page:Lookup("Btn_CampUp"):Enable(false)
		else
			page:Lookup("Btn_CampUp"):Enable(true)
		end
		
		if nCurrentValue == this:GetStepCount() then
			page:Lookup("Btn_CampDown"):Enable(false)
		else
			page:Lookup("Btn_CampDown"):Enable(true)
		end
		
		local handle = page:Lookup("", "Handle_CampAll")
	    handle:SetItemStartRelPos(0,  - 10 * nCurrentValue)
	end
	
	page:Lookup("Btn_CampUp").OnLButtonDown = function()
		this.OnLButtonHold()
	end
	page:Lookup("Btn_CampUp").OnLButtonHold = function()
		this:GetParent():Lookup("Scroll_CampScroll"):ScrollPrev()
	end
	page:Lookup("Btn_CampDown").OnLButtonDown = function()
		this.OnLButtonHold()
	end
	page:Lookup("Btn_CampDown").OnLButtonHold = function()
		this:GetParent():Lookup("Scroll_CampScroll"):ScrollNext()
	end
	
end

function CharacterPanel.UpdateCampPage(hPage, bRankMinimize, bCampMinimize, bOtherMinimize)
	local hPlayer = GetClientPlayer()
	local nTitlePoint = hPlayer.nTitlePoint -- 战阶积分
	local nKillCount = hPlayer.dwKillCount -- 击杀敌对阵营玩家数
	
	local hImagePercentage = hPage:Lookup("", "Image_CampFull")
	local hImageLimit = hPage:Lookup("", "Image_Limit")
    
	local nLimit = hPlayer.GetPrestigeRemainSpace()
	local x, y = hImagePercentage:GetRelPos()
	local ax, ay = hImagePercentage:GetAbsPos()
	local w, h = hImagePercentage:GetSize()

	local wImg, hImg = hImageLimit:GetSize()
	local nTotal = hPlayer.nCurrentPrestige + nLimit
	local MaxPrestige = hPlayer.GetMaxPrestige()
	nTotal = math.min(nTotal, MaxPrestige);

	hImageLimit:SetRelPos(x + w * (nTotal / MaxPrestige) - wImg / 2, y)
	hImageLimit:SetAbsPos(ax + w * (nTotal / MaxPrestige) - wImg / 2, ay)
	hImagePercentage:SetPercentage(hPlayer.nCurrentPrestige /  MaxPrestige)
	
	hPage:Lookup("", "Text_CampPageTitle"):SetText(g_tStrings.STR_CAMP_TITLE[hPlayer.nCamp])
	hPage:Lookup("", "Text_Prestige"):SetText(g_tStrings.STR_CAMP_PRESTIGE)
	hPage:Lookup("", "Text_Point"):SetText(g_tStrings.STR_CAMP_TITLE_POINT..nTitlePoint)
	hPage:Lookup("", "Text_Kill2"):SetText(nKillCount)
	
	local hCampAll = hPage:Lookup("", "Handle_CampAll")

	local nTitle = hPlayer.nTitle -- 当前战阶
	local szTitle, szTitleBuff = CharacterPanel.GetPlayerTitleDesc(nTitle)
	local nNextTitle = nTitle + 1
	local szNextTitle, szNextTitleBuff = CharacterPanel.GetPlayerTitleDesc(nNextTitle)
	local szNeedTitlePoint, szNeedPointRank = "", ""
	if nTitle < 7 then
		local nNeedPoint = Table_GetNextTitleRankPoint(nTitle)
		szNeedTitlePoint, szNeedPointRank = tostring(nNeedPoint), g_tStrings.STR_NONE
	else
		local nNeedPoint = GetNextTitleNeedPoint(nTitle)
		szNeedTitlePoint, szNeedPointRank = g_tStrings.STR_NONE, tostring(nNeedPoint)
	end
	local fPointPercentage = hPlayer.GetRankPointPercentage() / 100
	if fPointPercentage < 0 then
		fPointPercentage = 0
	end
	if fPointPercentage > 1 then
		fPointPercentage = 1
	end
	local hRank = hCampAll:Lookup("Handle_RankInfo")
	local hRankContent = hRank:Lookup("Handle_RankContent")
	local hRankBg = hRank:Lookup("Image_RankBg")
	local hRankMinimize = hRank:Lookup("Image_RankMinimize")
	if bRankMinimize then
		hRankContent:Hide()
		hRankBg:Hide()
		hRankMinimize:SetFrame(8)
		local nTitleWidth, nTitleHeight = hRank:Lookup("Image_RankTitle"):GetSize()
		hRank:SetSize(nTitleWidth, nTitleHeight)
	else
		hRankContent:Show()
		hRankBg:Show()
		hRankMinimize:SetFrame(12)
		local nBgWidth, nBgHeight = hRankBg:GetSize()
		hRank:SetSize(nBgWidth, nBgHeight)
		
		hRankContent:Lookup("Text_RankNow2"):SetText(szTitle)
		hRankContent:Lookup("Text_PropertyNow2"):SetText(szTitleBuff)
		hRankContent:Lookup("Text_RankNext2"):SetText(szNextTitle)
		hRankContent:Lookup("Text_PropertyNext2"):SetText(szNextTitleBuff)
		hRankContent:Lookup("Image_Rank2"):SetPercentage(fPointPercentage)
	end
	hRank.bMinimize = bRankMinimize
	
	local hCamp = hCampAll:Lookup("Handle_CampInfo")
	local hCampContent = hCamp:Lookup("Handle_CampContent")
	local hCampBg = hCamp:Lookup("Image_CampBg")
	local hCampMinimize = hCamp:Lookup("Image_CampMinimize")
	if bCampMinimize then
		hCampContent:Hide()
		hCampBg:Hide()
		hCampMinimize:SetFrame(8)
		local nTitleWidth, nTitleHeight = hCamp:Lookup("Image_CampTitle"):GetSize()
		hCamp:SetSize(nTitleWidth, nTitleHeight)
	else
		hCampContent:Show()
		hCampBg:Show()
		hCampMinimize:SetFrame(12)
		local nBgWidth, nBgHeight = hCampBg:GetSize()
		hCamp:SetSize(nBgWidth, nBgHeight)
		
		local hCampInfo = GetCampInfo()
		local nGoodCampScore = hCampInfo.nGoodCampScore
		local nEvilCampScore = hCampInfo.nEvilCampScore
		local nLastWinCamp = hCampInfo.nLastWinCamp
		local szWinner = g_tStrings.STR_CAMP_TITLE[nLastWinCamp]
		if nLastWinCamp == CAMP.NEUTRAL then
			szWinner = g_tStrings.STR_CAMP_TIE
		end
		local fPercentage = 0.5
		if nGoodCampScore + nEvilCampScore > 0 then
			fPercentage = nGoodCampScore / (nGoodCampScore + nEvilCampScore)
		end
		hCampContent:Lookup("Image_HQLine"):SetPercentage(fPercentage)
		hCampContent:Lookup("Image_ERLine"):SetPercentage(1 - fPercentage)
		--hCampContent:Lookup("Image_Camp1"):SetPercentage(fPercentage)
		--hCampContent:Lookup("Image_Camp2"):SetPercentage(fPercentage)
		hCampContent:Lookup("Text_Camp1"):SetText(g_tStrings.STR_CAMP_TITLE[CAMP.GOOD] .. g_tStrings.STR_COLON .. nGoodCampScore)
		hCampContent:Lookup("Text_Camp2"):SetText(g_tStrings.STR_CAMP_TITLE[CAMP.EVIL] .. g_tStrings.STR_COLON .. nEvilCampScore)
		
		local nMaxScore, nMinScore = hCampInfo.GetLevelScore(hCampInfo.nCampLevel)
		hCampContent:Lookup("Text_Morale1"):SetText(g_tStrings.STR_CAMP_WINNER .. szWinner)
		hCampContent:Lookup("Text_Morale2"):SetText(g_tStrings.STR_CAMP_LEFT_SCORE .. (hCampInfo.nCampScore - nMinScore))
		local hPrize = hCampContent:Lookup("Handle_Prize")
		hPrize:Clear()
		--hPrize:AppendItemFromString(GetCampAwardTip(hPlayer.nCamp))
		hPrize:FormatAllItemPos()
	end
	hCamp.bMinimize = bCampMinimize
	
	local hOther = hCampAll:Lookup("Handle_Others")
	local hOtherContent = hOther:Lookup("Handle_OthersContent")
	local hOtherBg = hOther:Lookup("Image_OBg")
	local hOtherMinimize = hOther:Lookup("Image_OMinimize")
	local hSwitchCampFlag = hOtherContent:Lookup("Handle_SwitchCampFlag")
	if bOtherMinimize then
		hOtherContent:Hide()
		hOtherBg:Hide()
		hOtherMinimize:SetFrame(8)
		local nTitleWidth, nTitleHeight = hOther:Lookup("Image_OTitle"):GetSize()
		hOther:SetSize(nTitleWidth, nTitleHeight)
	else
		hOtherContent:Show()
		hOtherBg:Show()
		hOtherMinimize:SetFrame(12)
		local nBgWidth, nBgHeight = hOtherBg:GetSize()
		hOther:SetSize(nBgWidth, nBgHeight)
	end
	hOther.bMinimize = bOtherMinimize
	
	hCampAll:FormatAllItemPos()
	
	local hSwitchCampFlagText = hSwitchCampFlag:Lookup("Text_SwitchCampFlag")
	if hPlayer.bCampFlag then
		hSwitchCampFlagText:SetText(g_tStrings.STR_CLOSE_CAMP_FLAG)
		hSwitchCampFlag.bEnable = hPlayer.CanCloseCampFlag()
	else
		hSwitchCampFlagText:SetText(g_tStrings.STR_OPEN_CAMP_FLAG)
		hSwitchCampFlag.bEnable = hPlayer.CanOpenCampFlag()
	end
	
	--hCampAll.nScrollPos = hPage:Lookup("Scroll_CampScroll"):GetScrollPos()
	hCampAll.UpdateScrollInfo(hCampAll)
	CharacterPanel.UpdateSwitchCampFlagState(hSwitchCampFlag)
end

function CharacterPanel.UpdateCampScrollInfo(hHandle)
	hHandle:FormatAllItemPos()
	
	local _, nItemHeight = hHandle:GetAllItemSize()
	local _, nHeight = hHandle:GetSize()
	
	local hPage = hHandle:GetRoot():Lookup("Page_Main/Page_Camp")
	local hScroll = hPage:Lookup("Scroll_CampScroll")
	local nCountStep = math.ceil((nItemHeight - nHeight) / 10)
	hScroll:SetStepCount(nCountStep)
	hScroll:SetScrollPos(hHandle.nScrollPos)
	if nCountStep > 0 then
		hPage:Lookup("Btn_CampUp"):Show()
		hPage:Lookup("Btn_CampDown"):Show()
		hScroll:Show()
	else
		hPage:Lookup("Btn_CampUp"):Hide()
		hPage:Lookup("Btn_CampDown"):Hide()
		hScroll:Hide()
	end
end

---------------------插件重新实现方法:--------------------------------
--2, CharacterPanel = nil
--2, 重载下面函数
----------------------------------------------------------------------
function OpenCharacterPanel(bDisableSound, szFrame)
	if IsOptionOrOptionChildPanelOpened() then
		return
	end
	if IsCharacterPanelOpened() then
		return
	end
	
	local frame = Station.Lookup("Normal/CharacterPanel")
	frame:Show()
	FireEvent("CHARACTER_PANEL_BRING_TOP")
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
	
	if not szFrame then
		szFrame = "EQUIP"
	end
	if szFrame == "EQUIP" then
		frame:Lookup("Page_Main"):ActivePage("Page_Battle")
	elseif szFrame == "REPUTATION" then
		frame:Lookup("Page_Main"):ActivePage("Page_Reputation")
	elseif szFrame == "RIDE" then
		frame:Lookup("Page_Main"):ActivePage("Page_Ride")
	elseif szFrame == "CAMP" then
		local hPlayer = GetClientPlayer()
		if hPlayer.nCamp ~= CAMP.NEUTRAL then
			frame:Lookup("Page_Main"):ActivePage("Page_Camp")
		else
			frame:Hide()
		end
	else
		frame:Lookup("Page_Main"):ActivePage("Page_Battle")
	end
	
	-- 七夕活动戒指数据同步
	local dwSelfID = GetClientPlayer().dwID
	--if not Player.tInscriptionList or not Player.tInscriptionList[dwSelfID] then
    if not IsRemotePlayer(dwSelfID) then
		RemoteCallToServer("OnInscriptionRequest", dwSelfID)
    end
	--end
	
	RemoteCallToServer("OnSyncEquipIDArray")
end

function CloseCharacterPanel(bDisableSound)
	if not IsCharacterPanelOpened() then
		return
	end
	
	local frame = Station.Lookup("Normal/CharacterPanel")
	frame:Hide()
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end
	
	CloseCharInfo(true, true)
	CloseDesignationPanel(true, true)
	ClosePendantPanel(true, true)
end

function IsCharacterPanelOpened()
	local frame = Station.Lookup("Normal/CharacterPanel")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end

function CharacterPanel_OnHandPickObj()
	if CharacterPanel then
		CharacterPanel.HighlightHandItemEquipPos()
	end
end

function CharacterPanel_OnHandDropObj()
	if CharacterPanel then
		CharacterPanel.UnHighlightHandItemEquipPos()
	end
end

function CharacterPanel_GetItemBox(dwBox, dwID, bEvenUnVisible)
	if dwBox == INVENTORY_INDEX.EQUIP then
		local frame = Station.Lookup("Normal/CharacterPanel")
		if frame and (frame:IsVisible() or bEvenUnVisible) then
			return CharacterPanel.GetEquipBox(frame:Lookup("Page_Main/Page_Battle"), dwID)
		end
	end
	return nil
end

function GetCharacterPanelPath()
	return "Normal/CharacterPanel"
end

function OnSuitChangeHotkey(index)
	if index < 1 or index > 3 then
		return
	end
	CharacterPanel.m_nSelectSuitIndex = index
	CharacterPanel.SetEquipSuitIndex(index)
end

function CharacterPanel_IsCharacterOpen()
	if not IsCharacterPanelOpened() then
		return false
	end
	
	local frame = Station.Lookup("Normal/CharacterPanel")
	local hPage = frame:Lookup("Page_Main"):Lookup("Page_Battle")
	if hPage == frame:Lookup("Page_Main"):GetActivePage() then
		return true
	end
	return false
end

function CharacterPanel_IsShowWeaponBag()
	return CharacterPanel.m_bShowWeaponBag
end
