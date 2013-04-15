----------------------------------------------------------------------------------------------------------
-- FileName		：	PlayerView.lua
-- Creator		：	tongxuehu@kingsoft.net
-- Create Date	：	2007-11-16 14:31:10
-- Comment		：	look over player info frame.(Modify from CharacterPanel)
-----------------------------------------------------------------------------------------------------------
CHARACTER_ROLE_TURN_YAW = math.pi / 18

PlayerView = {
	m_aCameraInfo = 
	{
		[0] = { -30, 160, -25, 0, 150, 0 }, --rtInvalid = 0,
		[1] = { 0, 78, -245, 0, 100, 150 }, --rtStandardMale,     // 标准男
		[2] = { 0, 78, -235, 0, 100, 150 }, --rtStandardFemale,   // 标准女
		[3] = { -30, 160, -25, 0, 150, 0 }, --rtStrongMale,       // 魁梧男
		[4] = { -30, 160, -25, 0, 150, 0 }, --rtSexyFemale,       // 性感女
		[5] = { -30, 160, -25, 0, 150, 0 }, --rtLittleBoy,        // 小男孩
		[6] = { 0, 70, -215, 0, 80, 150 }  --rtLittleGirl,       // 小孩女
	};
	
	m_aRepresentID 	= {}; 		-- 记录当前模型的ID，用于优化
	m_dwPlayerID	= 0;
	
	m_bTurnLeft 	= false;	-- 为了实现点住转身按钮持续转身
	m_bTurnRight 	= false;
	m_fRoleYaw     	= 0;
	
	m_bRidesTurnLeft  = false;
	m_bRidesTurnRight = false;
	m_fRidesYaw		  = 0;
};

-- 打开面板接口
function OpenPlayerView(nPlayerID)
	if IsOptionOrOptionChildPanelOpened() then
		return
	end

	PlayerView.m_dwPlayerID = nPlayerID
	local player = GetPlayer(nPlayerID)
	if not player then
		return
	end
	
	local objFrame = Wnd.OpenWindow("PlayerView") 			-- 不管有没开着，都要再打开一次
	objFrame:Show()
	objFrame:Lookup("Page_Main"):ActivePage("Page_Battle")	-- 激活装备属性页
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
	
	PlayerView.Update()
	
	-- 七夕活动戒指数据同步
	local dwSelfID = GetClientPlayer().dwID
    if not IsRemotePlayer(dwSelfID) and not IsRemotePlayer(PlayerView.m_dwPlayerID) then
	--if not Player.tInscriptionList or not Player.tInscriptionList[dwSelfID] then
		RemoteCallToServer("OnInscriptionRequest", dwSelfID)
	--end
	--if PlayerView.m_dwPlayerID and (not Player.tInscriptionList or not Player.tInscriptionList[PlayerView.m_dwPlayerID]) then
		RemoteCallToServer("OnInscriptionRequest", PlayerView.m_dwPlayerID)
	--end
    end
end

function ClosePlayerView(bDisableSound)
	if not IsPlayerViewOpened() then
		return
	end
	
	Station.Lookup("Normal/PlayerView"):Hide()
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end
end

function PlayerView.OnFrameCreate()	
	PlayerView.m_objModelView = PlayerModelView.new()
	PlayerView.m_objModelView:init()
	
	PlayerView.m_objRidesModelView = RidesModelView.new()
	PlayerView.m_objRidesModelView:init()
	
	InitFrameAutoPosInfo(this, 1, nil, nil, function() ClosePlayerView(true) end)
end

function PlayerView.OnFrameDestroy()
	if PlayerView.m_objModelView then
		PlayerView.m_objModelView:UnloadModel()
		PlayerView.m_objModelView:release()
		PlayerView.m_objModelView = nil
	end
	
	if PlayerView.m_objRidesModelView then
		PlayerView.m_objRidesModelView:UnloadRidesModel()
		PlayerView.m_objRidesModelView:release()
		PlayerView.m_objRidesModelView = nil
	end
end

function PlayerView.OnFrameBreathe()

	local player = GetPlayer(PlayerView.m_dwPlayerID)
	if not player then
		ClosePlayerView()
		return
	end
	
	local objPage = PlayerView.GetPageBattle()
	if objPage and objPage:IsVisible() then
		if PlayerView.m_bTurnLeft then
			PlayerView.m_fRoleYaw = PlayerView.m_fRoleYaw + CHARACTER_ROLE_TURN_YAW
			PlayerView.m_objModelView.m_modelRole["MDL"]:SetYaw(PlayerView.m_fRoleYaw)
		elseif PlayerView.m_bTurnRight then
			PlayerView.m_fRoleYaw = PlayerView.m_fRoleYaw - CHARACTER_ROLE_TURN_YAW
			PlayerView.m_objModelView.m_modelRole["MDL"]:SetYaw(PlayerView.m_fRoleYaw)
		end
	end
	
	local Ridespage = PlayerView.GetPageRides()
	if Ridespage and Ridespage:IsVisible() then
		if PlayerView.m_bRidesTurnLeft then
			PlayerView.m_fRidesYaw = PlayerView.m_fRidesYaw + CHARACTER_ROLE_TURN_YAW
			PlayerView.m_objRidesModelView.m_RidesMDL["MDL"]:SetYaw(PlayerView.m_fRidesYaw)
		elseif PlayerView.m_bRidesTurnRight then
			PlayerView.m_fRidesYaw = PlayerView.m_fRidesYaw - CHARACTER_ROLE_TURN_YAW
			PlayerView.m_objRidesModelView.m_RidesMDL["MDL"]:SetYaw(PlayerView.m_fRidesYaw)
		end
	end
end

function PlayerView.Update()
	PlayerView.UpdatePlayerEquipt()
    PlayerView.UpdatePlayerInfo()
	PlayerView.UpdatePlayerView()
end;

function PlayerView.UpdatePendant(page)
	local boxWaistPendant = page:Lookup("Wnd_Equit", "Box_Extend")
	local boxBackPendant = page:Lookup("Wnd_Equit", "Box_Amice")
	boxWaistPendant.bPendant = true
	boxBackPendant.bPendant = true
	local player =  GetPlayer(PlayerView.m_dwPlayerID)
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


function PlayerView.OutputScoresTip(handle)
	local player = GetPlayer(PlayerView.m_dwPlayerID)
	if not player then
		return
	end
	
	local nBaseScores = GetAllEquipBaseScores(player)
	local nStrengthScores = GetAllStrengthSocres(player)
	local nStoneScores = GetAllStoneSocres(player)
	
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

function PlayerView.UpdateEquipScores(frame)
	local player = GetPlayer(PlayerView.m_dwPlayerID)
	if not player then
		return
	end
	CharacterPanel.UpdateEquipScores(frame, player)
end


-- 更新玩家装备
function PlayerView.UpdatePlayerEquipt()
	local player = GetPlayer(PlayerView.m_dwPlayerID)
	if not player then
		ClosePlayerView()
		return
	end
	
	local hBattlePage = PlayerView.GetPageBattle()
	local wndWeapon = hBattlePage:Lookup("Wnd_Weapon")
	local wndCangJian = hBattlePage:Lookup("Wnd_CangJian")
	local kungfuMount = player.GetKungfuMount()
	if kungfuMount and kungfuMount.dwMountType == 6 then --藏剑
		wndWeapon:Hide()
		wndCangJian:Show()
		PlayerView.UpdateAnimation(wndCangJian, player.bBigSwordSelected)
	else
		wndWeapon:Show()
		wndCangJian:Hide()
	end
	
	for nItemIndex = 0, EQUIPMENT_INVENTORY.TOTAL, 1 do
		local objBox = PlayerView.GetBox(hBattlePage, nItemIndex)
		if objBox then
			local objItem = GetPlayerItem(player, INVENTORY_INDEX.EQUIP, nItemIndex)
	    	UpdataItemBoxObject(objBox, INVENTORY_INDEX.EQUIP, nItemIndex, objItem)
        end
    end
    
    PlayerView.UpdatePendant(hBattlePage)
    
    --更新坐骑马具
    local item = GetPlayerItem(player, INVENTORY_INDEX.EQUIP, EQUIPMENT_INVENTORY.HORSE)
    local box  = PlayerView.GetPageRides():Lookup("", "Box_RideBox")
	local text = PlayerView.GetPageRides():Lookup("", "Text_RideName")
	if item then
		text:SetText(GetItemNameByItem(item))
	else
		text:SetText("")
	end
	UpdataItemBoxObject(box, INVENTORY_INDEX.EQUIP, EQUIPMENT_INVENTORY.HORSE, item)
	PlayerView.UpdateEquipScores(hBattlePage:GetRoot())
end

-- 更新玩家属性
function PlayerView.UpdatePlayerInfo()
	local player = GetPlayer(PlayerView.m_dwPlayerID)
	if not player then
		ClosePlayerView()
		return
	end

	local hBattlePage = PlayerView.GetPageBattle():Lookup("", "")
	
	--[[
	hBattlePage:Lookup("Text_StrengthValue"):SetText(player.nCurrentStrength)	
	hBattlePage:Lookup("Text_AgilityValue"):SetText(player.nCurrentAgility)
	hBattlePage:Lookup("Text_VitalityValue"):SetText(player.nCurrentVitality)
	hBattlePage:Lookup("Text_SpiritValue"):SetText(player.nCurrentSpirit)
	hBattlePage:Lookup("Text_SpunkValue"):SetText(player.nCurrentSpunk)
	
	hBattlePage:Lookup("Text_PhysicsDamageValue"):SetText(player.nPhysicsAttackPowerBase)
	hBattlePage:Lookup("Text_PhysicsDefenceValue"):SetText(player.nPhysicsShield)
	hBattlePage:Lookup("Text_SpunkAttackPowerValue"):SetText(player.nSpunkAttackPower)
	
	hBattlePage:Lookup("Text_PoisonMagicShieldValue"):SetText(player.nPoisonMagicShield)
	hBattlePage:Lookup("Text_SolarMagicShieldValue"):SetText(player.nSolarMagicShield)
	hBattlePage:Lookup("Text_NeutralMagicShieldValue"):SetText(player.nNeutralMagicShield)
	hBattlePage:Lookup("Text_LunarMagicShieldValue"):SetText(player.nLunarMagicShield)
	]]
	
	hBattlePage:Lookup("Text_Title"):SetText(player.szName)
	local szForce = g_tStrings.STR_CHARACTER_NO_FORCE
	if g_tReputation.tReputationTable[player.dwForceID] then
		szForce = g_tReputation.tReputationTable[player.dwForceID].szName
	end
	hBattlePage:Lookup("Text_Lv"):SetText(FormatString(g_tStrings.STR_CHARACTER_LV_FORCE, player.nLevel, szForce))
	
--[[
	hBattlePage:Lookup("Text_HitValue"):SetText(player.nPhysicsAttackHit)
	hBattlePage:Lookup("Text_DodgeValue"):SetText(player.nDodge)
	hBattlePage:Lookup("Text_CriticalStrikeValue"):SetText(player.nPhysicsCriticalStrike)
	
	hBattlePage:Lookup("Text_SolorMagicDefenceValue"):SetText(player.nSolarMagicDefence)
	hBattlePage:Lookup("Text_NeutralMagicDefenceValue"):SetText(player.nNeutralMagicDefence)
	hBattlePage:Lookup("Text_LunarMagicDefenceValue"):SetText(player.nLunarMagicDefence)	
	hBattlePage:Lookup("Text_PoisonDefenceValue"):SetText(player.nPoisonMagicDefence)
]]
end

-- 更新玩家形象
function PlayerView.UpdatePlayerView()
	local player = GetPlayer(PlayerView.m_dwPlayerID)
	if not player then
		ClosePlayerView()
		return
	end

	local cScene = PlayerView.GetPageBattle():Lookup("Scene_Role")
	cScene:SetScene(PlayerView.m_objModelView.m_scene)
	
	local tbViewInfo = PlayerView.m_aCameraInfo[player.nRoleType]
	local nWidth, nHeight = cScene:GetSize()
	local tbCameraSetting = { tbViewInfo[1], tbViewInfo[2], tbViewInfo[3], tbViewInfo[4], tbViewInfo[5], 
		tbViewInfo[6], math.pi / 4, nWidth / nHeight, nil, nil, true }
	PlayerView.m_objModelView:SetCamera(tbCameraSetting)
	
	-- 优化更换角色模型的开销
	-- 比较RepresentID的值，如果值全部相等，则表示模型一致，不重新加载该模型
	
	local aRepresentID = player.GetRepresentID() -- 当前角色的模型
	for i = 0, EQUIPMENT_REPRESENT.TOTAL - 1 do		-- 遍历比较
		if aRepresentID[i] ~= PlayerView.m_aRepresentID[i] then -- 如果有不同，则重载
			PlayerView.m_aRepresentID = aRepresentID
			PlayerView.m_objModelView:UnloadModel()
			PlayerView.m_objModelView:LoadPlayerRes(player.dwID, false)
			PlayerView.m_objModelView:LoadModel()
			PlayerView.m_objModelView:PlayAnimation("Idle", "loop")

			if PlayerView.m_objModelView.m_modelRole then
				PlayerView.m_objModelView.m_modelRole["MDL"]:SetYaw(PlayerView.m_fRoleYaw)
			end
			break	-- 重载完成，跳出循环
		end
	end
	
	local rScene = PlayerView.GetPageRides():Lookup("Scene_Rides")
	rScene:SetScene(PlayerView.m_objRidesModelView.m_scene)

	local wr, hr = rScene:GetSize()
	PlayerView.m_objRidesModelView:SetCamera({ 0, 120, -380, 0, 120, 150, math.pi / 4, wr / hr, nil, nil, true })
	
	local nHorseStyle = PlayerView.m_aRepresentID[EQUIPMENT_REPRESENT.HORSE_STYLE]
	if nHorseStyle == 0 then
		PlayerView.m_objRidesModelView:UnloadRidesModel()
	else
		PlayerView.m_objRidesModelView:UnloadRidesModel()
		PlayerView.m_objRidesModelView:LoadRidesRes(PlayerView.m_dwPlayerID, false)
		PlayerView.m_objRidesModelView:LoadRidesModel()
		PlayerView.m_objRidesModelView:PlayRidesAnimation("Idle", "loop")
		if PlayerView.m_objRidesModelView.m_RidesMDL then
			PlayerView.m_objRidesModelView.m_RidesMDL["MDL"]:SetYaw(PlayerView.m_fRoleYaw)
		end
	end
end

function PlayerView.GetPageBattle()
	return Station.Lookup("Normal/PlayerView/Page_Main/Page_Battle")
end

function PlayerView.GetPageRides()
	return Station.Lookup("Normal/PlayerView/Page_Main/Page_Ride")
end

function PlayerView.GetBox(objPage, nIndex)
	if nIndex == EQUIPMENT_INVENTORY.HELM then
		return objPage:Lookup("Wnd_Equit", "Box_Helm")
	elseif nIndex == EQUIPMENT_INVENTORY.CHEST then
		return objPage:Lookup("Wnd_Equit", "Box_Chest")
	elseif nIndex == EQUIPMENT_INVENTORY.BANGLE then
		return objPage:Lookup("Wnd_Equit", "Box_Bangle")
	elseif nIndex == EQUIPMENT_INVENTORY.WAIST then
		return objPage:Lookup("Wnd_Equit", "Box_Waist")
	elseif nIndex == EQUIPMENT_INVENTORY.PANTS then
		return objPage:Lookup("Wnd_Equit", "Box_Pants")
	elseif nIndex == EQUIPMENT_INVENTORY.BOOTS then
		return objPage:Lookup("Wnd_Equit", "Box_Boots")
	elseif nIndex == EQUIPMENT_INVENTORY.WAIST_EXTEND then
		return objPage:Lookup("Wnd_Equit", "Box_Extend")
	elseif nIndex == EQUIPMENT_INVENTORY.AMULET then
		return objPage:Lookup("Wnd_Equit", "Box_Amulet")
	elseif nIndex == EQUIPMENT_INVENTORY.PENDANT then
		return objPage:Lookup("Wnd_Equit", "Box_Pendant")
	elseif nIndex == EQUIPMENT_INVENTORY.LEFT_RING then
		return objPage:Lookup("Wnd_Equit", "Box_LeftRing")
	elseif nIndex == EQUIPMENT_INVENTORY.RIGHT_RING then
		return objPage:Lookup("Wnd_Equit", "Box_RightRing")
	elseif nIndex == EQUIPMENT_INVENTORY.BACK_EXTEND then
		return objPage:Lookup("Wnd_Equit", "Box_Amice")
	end
	
	local wndWeapon = objPage:Lookup("Wnd_Weapon")
	local wndCangJian = objPage:Lookup("Wnd_CangJian")
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

function PlayerView.OnActivePage(nPage, nLast)
	if nLast ~= -1 and nPage ~= nLast then
		PlaySound(SOUND.UI_SOUND, g_sound.OpenFrame)
	end
end

function PlayerView.OnItemLButtonDown()
	if this:GetType() == "Box" and IsCtrlKeyDown() and not this:IsEmpty() then
		local player = GetPlayer(PlayerView.m_dwPlayerID)
		if not player then
			ClosePlayerView()
			return
		end
		
		local _, dwBox, dwX = this:GetObjectData()		
		local dwID = GetPlayerItem(player, dwBox, dwX).dwID
		if IsGMPanelReceiveItem() then
			GMPanel_LinkItem(dwID)
		else
			EditBox_AppendLinkItem(dwID)
		end
	end
end

function PlayerView.OnItemMouseEnter()
	if this:GetType() == "Box" and not this:IsEmpty() then
		local szName = this:GetName()
		if szName == "Box_Extend" then
			local x, y = this:GetAbsPos()
			local w, h = this:GetSize()
			OutputWaistPendantTip(this.nWaist, {x, y, w, h})
		elseif szName == "Box_Amice" then
			local x, y = this:GetAbsPos()
			local w, h = this:GetSize()
			OutputBackPendantTip(this.nBack, {x, y, w, h})
		else
			local player = GetPlayer(PlayerView.m_dwPlayerID)
			if not player then
				ClosePlayerView()
				return
			end
			local _, dwBox, dwX = this:GetObjectData()
			local x, y = this:GetAbsPos()
			local w, h = this:GetSize()
			-- 七夕戒指处理不同的额外TIP
			Player.dwQixiRingOwnerID = PlayerView.m_dwPlayerID
			OutputItemTip(UI_OBJECT_ITEM_ONLY_ID, GetPlayerItem(player, dwBox, dwX).dwID, nil, nil, {x, y, w, h}, nil, nil, nil, nil, nil, PlayerView.m_dwPlayerID)
			Player.dwQixiRingOwnerID = nil
		end
	end		
end

function PlayerView.OnItemMouseLeave()
	if this:GetType() == "Box" then
		HideTip()
	end	
end

function PlayerView.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_Close" then
		ClosePlayerView()
	end
end

function PlayerView.OnLButtonDown()
	local szName = this:GetName()
	if szName == "Btn_TurnLeft" then
		PlayerView.m_bTurnLeft = true
		PlayerView.m_bTurnRight = false
	elseif szName == "Btn_TurnRight" then
		PlayerView.m_bTurnRight = true
		PlayerView.m_bTurnLeft = false
	elseif szName == "Btn_RidesTurnLeft" then
		PlayerView.m_bRidesTurnLeft = true
		PlayerView.m_bRidesTurnRight = false
	elseif szName == "Btn_RidesTurnRight" then
		PlayerView.m_bRidesTurnLeft = false
		PlayerView.m_bRidesTurnRight = true
	end
end

function PlayerView.OnLButtonUp()
	local szName = this:GetName()
	if szName == "Btn_TurnLeft" then
		PlayerView.m_bTurnLeft = false
	elseif szName == "Btn_TurnRight" then
		PlayerView.m_bTurnRight = false
	elseif szName == "Btn_RidesTurnLeft" then
		PlayerView.m_bRidesTurnLeft = false
	elseif szName == "Btn_RidesTurnRight" then
		PlayerView.m_bRidesTurnRight = false
	end
end

function IsPlayerViewOpened()
	local frame = Station.Lookup("Normal/PlayerView")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end

function PlayerView.UpdateAnimation(wndCangJian, bHeavySwordSelected)
	if not wndCangJian then
		return
	end
	
	if bHeavySwordSelected then
		wndCangJian:Lookup("", "Animate_HeavySword"):Show()
		wndCangJian:Lookup("", "Animate_LightSword"):Hide()
	else
		wndCangJian:Lookup("", "Animate_HeavySword"):Hide()
		wndCangJian:Lookup("", "Animate_LightSword"):Show()
	end
end
