FEEquipExtractPanel = {}

local tPanelKind = 
{
	["UnMount"] = 0,				--装备镶嵌剥离面板被打开
	["UnStrength"] = 1,			--装备强化剥离面板被打开
}

local nBoxCount = 16

local tEquipKind = 
{
	"MELEE_WEAPON",
	"RANGE_WEAPON",
	"CHEST",
	"HELM",
	"AMULET",
	"RING",
	"WAIST",
	"PENDANT",
	"PANTS",
	"BOOTS",
	"BANGLE",
}

function FEEquipExtractPanel.OnFrameCreate()
	this:RegisterEvent("EQUIP_UNMOUNT")
	this:RegisterEvent("EQUIP_UNSTRENGTH")

	FEEquipExtractPanel.Init(this)

	InitFrameAutoPosInfo(this, 1, nil, nil, function() CloseFEProducePeelPanel(true) end)
end

function FEEquipExtractPanel.OnFrameBreathe()
	local player = GetClientPlayer()
	if not player or player.nMoveState == MOVE_STATE.ON_DEATH then
		CloseFEProducePeelPanel()
		return
	end
	
	if FEEquipExtractPanel.dwTargetType then
		if FEEquipExtractPanel.dwTargetType == TARGET.NPC then
			local npc = GetNpc(FEEquipExtractPanel.dwTargetID)
			if not npc or not npc.CanDialog(player) then
				CloseFEProducePeelPanel()
			end
		elseif FEEquipExtractPanel.dwTargetType == TARGET.DOODAD then
			local doodad = GetDoodad(FEEquipExtractPanel.dwTargetID)
			if not doodad or not doodad.CanDialog(player) then
				CloseFEProducePeelPanel()
			end
		end
	end
end

function FEEquipExtractPanel.OnEvent(szEvent)
	if szEvent == "EQUIP_UNMOUNT" then
		local nResult = arg0
		if nResult == DIAMOND_RESULT_CODE.SUCCESS then
			FEEquipExtractPanel.Init(Station.Lookup("Normal/FEEquipExtractPanel"))
			OutputMessage("MSG_ANNOUNCE_YELLOW", g_tStrings.tFEExtract.UNMOUNT_SUCCESS)
		elseif nResult == DIAMOND_RESULT_CODE.NEED_EQUIPMENT then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFEExtract.NEED_EQUIP)
		elseif nResult == DIAMOND_RESULT_CODE.NEED_IN_PACKAGE then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFEExtract.NEED_IN_PACKAGE)
		elseif nResult == DIAMOND_RESULT_CODE.NOT_ENOUGH_FREE_ROOM then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFECommon.NO_ENOUGH_ROOM)
		elseif nResult == DIAMOND_RESULT_CODE.CAN_NOT_OPERATE_IN_FIGHT then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFEExtract.CAN_NOT_OPERATE_IN_FIGHT)
		elseif nResult == DIAMOND_RESULT_CODE.NOT_ENOUGH_MONEY_FOR_COST then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFECommon.NOT_ENOUGH_MONEY_FOR_COST)
		elseif nResult == DIAMOND_RESULT_CODE.SCENE_FORBID then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFECommon.SCENE_FORBID)
		else
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFEExtract.UNMOUNT_FAILED)
		end
	elseif szEvent == "EQUIP_UNSTRENGTH" then
		local nResult = arg0
		if nResult == DIAMOND_RESULT_CODE.SUCCESS then
			FEEquipExtractPanel.Init(Station.Lookup("Normal/FEEquipExtractPanel"))
			OutputMessage("MSG_ANNOUNCE_YELLOW", g_tStrings.tFEExtract.UNSTRENGTH_SUCCESS)
			PlaySound(SOUND.UI_SOUND, g_sound.FEExtractSuccess)
		elseif nResult == DIAMOND_RESULT_CODE.NEED_EQUIPMENT then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFEExtract.NEED_EQUIP)
		elseif nResult == DIAMOND_RESULT_CODE.NEED_IN_PACKAGE then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFEExtract.NEED_IN_PACKAGE)
		elseif nResult == DIAMOND_RESULT_CODE.NOT_ENOUGH_FREE_ROOM then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFECommon.NO_ENOUGH_ROOM)
		elseif nResult == DIAMOND_RESULT_CODE.CAN_NOT_OPERATE_IN_FIGHT then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFEExtract.CAN_NOT_OPERATE_IN_FIGHT)
		elseif nResult == DIAMOND_RESULT_CODE.NOT_ENOUGH_MONEY_FOR_COST then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFECommon.NOT_ENOUGH_MONEY_FOR_COST)
		elseif nResult == DIAMOND_RESULT_CODE.SCENE_FORBID then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFECommon.SCENE_FORBID)
		else
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFEExtract.UNSTRENGTH_FAILED)
		end
	end
end

function FEEquipExtractPanel.OnItemMouseLeave()
	this:SetObjectMouseOver(0)
	HideTip()
end

function FEEquipExtractPanel.OnItemLButtonUp()
	this:SetObjectPressed(0)
end

function FEEquipExtractPanel.OnItemLButtonDown()
	this:SetObjectPressed(1)
end

function FEEquipExtractPanel.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_Making" then
		FEEquipExtractPanel.ExtractEquip(this:GetRoot())
	elseif szName == "Btn_Close" then
		CloseFEProducePeelPanel()
	end
end

function FEEquipExtractPanel.OnItemLButtonDrag()
	this:SetObjectPressed(0)
	local szName = this:GetName()
	if Hand_IsEmpty() then
		if not this:IsEmpty() then
			if IsCursorInExclusiveMode() then
				OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.SRT_ERROR_CANCEL_CURSOR_STATE)
			elseif szName == "Box_FE" then
				Hand_Pick(this)
				RemoveUILockItem("FEEquipExtract")
				this.dwBox = 0
				this.dwX = 0
				this.nCount = 0
				this:ClearObject()
				this:SetOverText(0, "")
				FEEquipExtractPanel.UpdateInfo(this:GetRoot())
			end
		end
	end
end

function FEEquipExtractPanel.OnItemLButtonDragEnd()
	this.bIgnoreClick = true
	local szName = this:GetName()
	if not Hand_IsEmpty() then
		if szName == "Box_FE" then
			local boxHand, nHandCount = Hand_Get()
			FEEquipExtractPanel.ExchangeBoxItem(this, boxHand, nHandCount, true)
		else
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFEExtract.CAN_NOT_DO_THIS)
		end
	end
end

function FEEquipExtractPanel.OnItemRButtonClick()
	local szName = this:GetName()
	if szName == "Box_FE" and not this:IsEmpty() then
		RemoveUILockItem("FEEquipExtract")
		this.dwBox = 0
		this.dwX = 0
		this.nCount = 0
		this:ClearObject()
		this:SetOverText(0, "")
		FEEquipExtractPanel.UpdateInfo(this:GetRoot())
		HideTip()
		local nType = this:GetObjectType()
		if IsObjectItem(nType) then
			PlayItemSound(this:GetObjectData(), true)
		else
			PlaySound(SOUND.UI_SOUND, g_sound.TakeUpSkill)
		end
	end
end

function FEEquipExtractPanel.OnItemMouseEnter()
	this:SetObjectMouseOver(1)
	local szName = this:GetName()
	if szName == "Box_FE" then
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
		if not this:IsEmpty() then
			OutputItemTip(UI_OBJECT_ITEM, this.dwBox, this.dwX, nil, {x, y, w, h})
		else
			if FEEquipExtractPanel.kind == tPanelKind.UnMount then
				OutputTip(GetFormatText(g_tStrings.tFEExtract.UNMOUNT_EQUIP_TIP), 400, {x, y ,w, h})
			else
				OutputTip(GetFormatText(g_tStrings.tFEExtract.UNSTRENGTH_EQUIP_TIP), 400, {x, y ,w, h})
			end
		end
	elseif not this:IsEmpty() then
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
		OutputItemTip(UI_OBJECT_ITEM_INFO, 0, this.dwTabType, this.dwIndex, {x, y, w, h})
	end
end

function FEEquipExtractPanel.OnItemLButtonClick()
	local szName = this:GetName()
	if szName == "Box_FE" then
		if Hand_IsEmpty() then
			if not this:IsEmpty() then
				if IsCursorInExclusiveMode() then
					OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.SRT_ERROR_CANCEL_CURSOR_STATE)
				else
					Hand_Pick(this)
					FEEquipExtractPanel.Init(this:GetRoot())
					HideTip()
				end
			end
		else
			local boxHand, nHandCount = Hand_Get()
			FEEquipExtractPanel.ExchangeBoxItem(this, boxHand, nHandCount, true)
		end
	elseif not Hand_IsEmpty() then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFEExtract.CAN_NOT_DO_THIS)
	end
end

function FEEquipExtractPanel.Init(frame)
	local handle = frame:Lookup("", "")
	local equipBox = handle:Lookup("Box_FE")
	local handleItem = frame:Lookup("", "Handle_Item")
	local textTitle = handle:Lookup("Text_Title")
	local textProduce = handle:Lookup("Text_Produce")
	
	if FEEquipExtractPanel.kind == tPanelKind.UnMount then
		textTitle:SetText(g_tStrings.tFEExtract.UNMOUNT_TITLE)
		textProduce:SetText(g_tStrings.tFEExtract.UNMOUNT_EQUIP_TIP)
	else
		textTitle:SetText(g_tStrings.tFEExtract.UNSTRENGTH_TITLE)
		textProduce:SetText(g_tStrings.tFEExtract.UNSTRENGTH_EQUIP_TIP)
	end
	
	RemoveUILockItem("FEEquipExtract")
	equipBox.dwBox = 0
	equipBox.dwX = 0
	equipBox.nCount = 0
	equipBox:ClearObject()
	equipBox:SetOverText(0, "")
	for i = 1, nBoxCount, 1 do
		local box = handleItem:Lookup("Box_Item" .. i)
		box:ClearObject()
		box:SetOverText(0, "")
	end
	
	local btnMaking = frame:Lookup("Btn_Making")
	btnMaking:Enable(false)
	
	local goldText = handle:Lookup("Text_Gold")
	local silverText = handle:Lookup("Text_Silver")
	local cooperText = handle:Lookup("Text_Cooper")
	local goldImage = handle:Lookup("Image_Gold")
	local silverImage = handle:Lookup("Image_Silver")
	local cooperImage = handle:Lookup("Image_Cooper")
	
	goldText:SetText("")
	goldImage:Hide()
	silverImage:Hide()
	silverText:SetText("")
	cooperText:SetText("0")
end

function FEEquipExtractPanel.ExtractEquip(frame)
	local player = GetClientPlayer()
	if not player then
		return
	end

	local equipBox = frame:Lookup("", ""):Lookup("Box_FE")
	if equipBox:IsEmpty() then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFEExtract.BOX_CAN_NOT_EMPTY)
		return
	end
	
	if FEEquipExtractPanel.kind == tPanelKind.UnMount then
		RemoteCallToServer("OnUnMountAllDiamonds", FEEquipExtractPanel.dwTargetID, equipBox.dwBox, equipBox.dwX)
	else
		RemoteCallToServer("OnUnStrengthEquip", FEEquipExtractPanel.dwTargetID, equipBox.dwBox, equipBox.dwX)
	end
end

function FEEquipExtractPanel.ExchangeBoxItem(box, descBox, nHandCount, bHand)
	if not box or not descBox then
		return
	end

	local player = GetClientPlayer()
	if not player then
		return
	end
	
	local nType = descBox:GetObjectType()
	local _, dwBox, dwX = descBox:GetObjectData()
	
	if nType ~= UI_OBJECT_ITEM or not dwBox or dwBox < INVENTORY_INDEX.PACKAGE or dwBox > INVENTORY_INDEX.PACKAGE4 then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFECommon.NEED_IN_PACKAGE)
		return
	end
	
	local item = GetPlayerItem(player, dwBox, dwX)
	if not item then
		return
	end
	
	if item.nGenre ~= ITEM_GENRE.EQUIPMENT then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFEExtract.NOT_EQUIP)
		return
	end
	
	local bSubKind = false
	for _, v in ipairs(tEquipKind) do
		if item.nSub == EQUIPMENT_SUB[v] then
			bSubKind = true
			break
		end
	end
	if not bSubKind then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFEExtract.EQUIP_CAN_NOT_EXTRACT)
		return
	end
	
	if FEEquipExtractPanel.kind == tPanelKind.UnStrength then
		if item.nStrengthLevel == 0 then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFEExtract.UNSTRENGTH_JUST_FOR_PROPERTY_EQUIP)
			return
		end
	else
		local ret = player.UnMountAllDiamonds(FEEquipExtractPanel.dwTargetID, dwBox, dwX)
		if ret ~= DIAMOND_RESULT_CODE.SUCCESS then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFEExtract.UNMOUNT_JUST_FOR_PROPERTY_EQUIP)
			return
		else
			local tDiamon = GetDisplayDiamonds()
			if #tDiamon ==0 then
				OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFEExtract.UNMOUNT_JUST_FOR_PROPERTY_EQUIP)
				return
			end
		end
	end
	
	if not box:IsEmpty() then
		RemoveUILockItem("FEEquipExtract")
	end
	box.szName = item.szName
	box.dwBox = dwBox
	box.dwX = dwX
	box.nCount = nHandCount
	UpdataItemBoxObject(box, dwBox, dwX, item)
	
	if bHand then
		Hand_Clear()
	else
		if IsObjectItem(nType) then
			PlayItemSound(descBox:GetObjectData(), true)
		else
			PlaySound(SOUND.UI_SOUND, g_sound.TakeUpSkill)
		end
	end
	
	AddUILockItem("FEEquipExtract", dwBox, dwX)
	FEEquipExtractPanel.UpdateInfo(box:GetRoot())
end

function FEEquipExtractPanel.UpdateInfo(frame)
	local player = GetClientPlayer()
	if not player then
		return
	end
	
	local handle = frame:Lookup("", "")
	local equipBox = handle:Lookup("Box_FE")
	local btnMaking = frame:Lookup("Btn_Making")
	local goldText = handle:Lookup("Text_Gold")
	local silverText = handle:Lookup("Text_Silver")
	local cooperText = handle:Lookup("Text_Cooper")
	local goldImage = handle:Lookup("Image_Gold")
	local silverImage = handle:Lookup("Image_Silver")
	local cooperImage = handle:Lookup("Image_Cooper")
	local textProduce = handle:Lookup("Text_Produce")
	
	goldText:SetText("")
	goldImage:Hide()
	silverImage:Hide()
	silverText:SetText("")
	cooperText:SetText("0")
	if FEEquipExtractPanel.kind == tPanelKind.UnMount then
		textProduce:SetText(g_tStrings.tFEExtract.UNMOUNT_EQUIP_TIP)
	else
		textProduce:SetText(g_tStrings.tFEExtract.UNSTRENGTH_EQUIP_TIP)
	end
	btnMaking:Enable(false)
	
	local handleItem = frame:Lookup("", "Handle_Item")
	for i = 1, nBoxCount, 1 do
		local box = handleItem:Lookup("Box_Item" .. i)
		box:ClearObject()
		box:SetOverText(0, "")
	end
	
	local item = GetPlayerItem(player, equipBox.dwBox, equipBox.dwX)
	if not item then
		return
	end
	
	local canExtract = false
	local nCost = 0
	
	if FEEquipExtractPanel.kind == tPanelKind.UnMount then
		if not equipBox:IsEmpty() then
			textProduce:SetText(g_tStrings.tFEExtract.UNMOUNT_CURRENT_EQUIP)
		end
		local bRet, nTmpCost = GetUnMountAllDiamondsCost(equipBox.dwBox, equipBox.dwX)
		if bRet then
			nCost = nTmpCost
		end
		local ret = player.UnMountAllDiamonds(FEEquipExtractPanel.dwTargetID, equipBox.dwBox, equipBox.dwX)
		if ret == DIAMOND_RESULT_CODE.SUCCESS then
			canExtract = true
		end
	elseif FEEquipExtractPanel.kind == tPanelKind.UnStrength then
		if not equipBox:IsEmpty() then
			textProduce:SetText(FormatString(g_tStrings.tFEExtract.UNSTRENGTH_CURRENT_LEVEL, item.nStrengthLevel))
		end
		local bRet, nTmpCost = GetUnStrengthEquipCost(equipBox.dwBox, equipBox.dwX)
		if bRet then
			nCost = nTmpCost
		end
		local ret = player.UnStrengthEquip(FEEquipExtractPanel.dwTargetID, equipBox.dwBox, equipBox.dwX)
		if ret == DIAMOND_RESULT_CODE.SUCCESS then
			canExtract = true
		end
	end
	
	local nGold, nSilver, nCooper = MoneyToGoldSilverAndCopper(nCost)
	if not equipBox:IsEmpty() then
		if nGold == 0 then
			goldImage:Hide()
			goldText:SetText("")
		else
			goldImage:Show()
			goldText:SetText(nGold)
		end
		
		if nSilver == 0 and nGold == 0 then
			silverImage:Hide()
			silverText:SetText("")
		else
			silverImage:Show()
			silverText:SetText(nSilver)
		end
	end
	cooperText:SetText(nCooper)
	
	local tDiamon = {}
	if canExtract then
		tDiamon = GetDisplayDiamonds()
	end
	
	if #tDiamon > 0 then
		btnMaking:Enable(true)
	end
	
	local nIndex = 1
	for _, diamon in ipairs(tDiamon) do
		local icon = Table_GetItemIconID(diamon.nUiId)
		for nStackNum = 1, diamon.nStackNum, 1 do
			local box = handleItem:Lookup("Box_Item" .. nIndex)
			nIndex = nIndex + 1
			box:SetObject(UI_OBJECT_ITEM)
			box:SetObjectIcon(icon)
			box.dwTabType = diamon.dwTabType
			box.dwIndex = diamon.dwIndex
		end
	end
end

function CloseFEProducePeelPanel(bDisableSound)
	RemoveUILockItem("FEEquipExtract")
	for i = 1, nBoxCount, 1 do
		RemoveUILockItem("FEEquipExtract" .. "Box_Item" .. i)
	end
	
	if IsFEEquipExtractPanelOpened() then
		Wnd.CloseWindow("FEEquipExtractPanel")
	end
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND, g_sound.CloseFrame)
	end
end

function IsFEEquipExtractPanelOpened()
	local frame = Station.Lookup("Normal/FEEquipExtractPanel")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end

function OpenFEProducePeelPanel(dwTargetType, dwTargetID, kind, bDisableSound)
	if IsOptionOrOptionChildPanelOpened() then
		return
	end
	
	local player = GetClientPlayer()
	if not player or player.nMoveState == MOVE_STATE.ON_DEATH then
		return
	end
	
	CloseFEProducePanel(true)
	CloseFEActivationPanel(true)
	CloseFEEquipExtractPanel(true)
	CloseFEProducePeelPanel(true)
	
	if CheckHaveLocked(SAFE_LOCK_EFFECT_TYPE.OPERATE_DIAMOND, "OPERATE_DIAMOND") then
		return
	end
	
	FEEquipExtractPanel.dwTargetType = dwTargetType
	FEEquipExtractPanel.dwTargetID = dwTargetID
	
	if kind == "UnMount" then
		FEEquipExtractPanel.kind = tPanelKind.UnMount
	elseif kind == "UnStrength" then
		FEEquipExtractPanel.kind = tPanelKind.UnStrength
	end
	
	if not IsFEEquipExtractPanelOpened() then
		Wnd.OpenWindow("FEEquipExtractPanel")
	end
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
end

function AddFEEquipExtractOnItemRButtonClick(box, nCount)
	local frame = Station.Lookup("Normal/FEEquipExtractPanel")
	if not frame then
		return
	end
	
	local equipBox = frame:Lookup("", ""):Lookup("Box_FE")
	if not equipBox then
		return
	end
	
	FEEquipExtractPanel.ExchangeBoxItem(equipBox, box, nCount)
end