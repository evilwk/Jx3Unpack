FEPeelPanel = {
	mount_count = 0,
}

local SLOT_COUNT = 3

local EQUIP_TYPE = {
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

function FEPeelPanel.OnFrameBreathe()
	local player = GetClientPlayer()
	if not player or player.nMoveState == MOVE_STATE.ON_DEATH then
		CloseFEEquipExtractPanel()
		return
	end
	
	if FEPeelPanel.dwTargetType then
		if FEPeelPanel.dwTargetType == TARGET.NPC then
			local npc = GetNpc(FEPeelPanel.dwTargetID)
			if not npc or not npc.CanDialog(player) then
				CloseFEEquipExtractPanel()
			end
		elseif FEPeelPanel.dwTargetType == TARGET.DOODAD then
			local doodad = GetDoodad(FEPeelPanel.dwTargetID)
			if not doodad or not doodad.CanDialog(player) then
				CloseFEEquipExtractPanel()
			end
		end
	end
end

function FEPeelPanel.OnFrameCreate()
	this:RegisterEvent("EQUIP_UNMOUNT")

	InitFrameAutoPosInfo(this, 1, nil, nil, function() CloseFEEquipExtractPanel(true) end)
	
	FEPeelPanel.Init(this)
	FEPeelPanel.Update(this)
end

function FEPeelPanel.OnItemMouseEnter()
	this:SetObjectMouseOver(1)
	local name = this:GetName()
	if name == "Box_FE" then
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
		if not this:IsEmpty() then
			OutputItemTip(UI_OBJECT_ITEM, this.dwBox, this.dwX, nil, {x, y, w, h})
		else
			OutputTip(GetFormatText(g_tStrings.tFEExtract.UNMOUNT_EQUIP_TIP), 400, {x, y ,w, h})
		end
	elseif not this:IsEmpty() then
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
		OutputItemTip(UI_OBJECT_ITEM_INFO, 0, this.dwTabType, this.dwIndex, {x, y, w, h})
	end
end

function FEPeelPanel.OnItemLButtonDrag()
	this:SetObjectPressed(0)
	local name = this:GetName()
	if Hand_IsEmpty() then
		if not this:IsEmpty() then
			if IsCursorInExclusiveMode() then
				OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.SRT_ERROR_CANCEL_CURSOR_STATE)
			elseif name == "Box_FE" then
				Hand_Pick(this)
				FEPeelPanel.Init(this:GetRoot())
			end
		end
	end
end

function FEPeelPanel.OnItemLButtonDragEnd()
	this.bIgnoreClick = true
	local name = this:GetName()
	if not Hand_IsEmpty() then
		if name == "Box_FE" then
			local boxHand, nHandCount = Hand_Get()
			FEPeelPanel.ExchangeBoxItem(this, boxHand, nHandCount, true)
		else
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFEExtract.CAN_NOT_DO_THIS)
		end
	end
end

function FEPeelPanel.OnItemLButtonClick()
	local name = this:GetName()
	if name == "Box_FE" then
		if Hand_IsEmpty() then
			if not this:IsEmpty() then
				if IsCursorInExclusiveMode() then
					OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.SRT_ERROR_CANCEL_CURSOR_STATE)
				else
					Hand_Pick(this)
					FEPeelPanel.Init(this:GetRoot())
					HideTip()
				end
			end
		else
			local boxHand, nHandCount = Hand_Get()
			FEPeelPanel.ExchangeBoxItem(this, boxHand, nHandCount, true)
		end
	elseif not Hand_IsEmpty() then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFEExtract.CAN_NOT_DO_THIS)
	end
end

function FEPeelPanel.OnItemMouseLeave()
	this:SetObjectMouseOver(0)
	HideTip()
end

function FEPeelPanel.OnItemLButtonUp()
	this:SetObjectPressed(0)
end

function FEPeelPanel.OnItemLButtonDown()
	this:SetObjectPressed(1)
end

function FEPeelPanel.ResetBox(box, name)
	box.dwBox = 0
	box.dwX = 0
	box.nCount = 0
	box:ClearObject()
	box:SetOverText(0, "")
	
	if name then
		RemoveUILockItem(name)
	end
end

function FEPeelPanel.ResetHandle(frame, index)
	local handle = frame:Lookup("", "Handle_Item_" .. index)
	if not handle then
		return
	end
	
	local lbox = handle:Lookup("Box_Stone_" .. index)
	local rbox = handle:Lookup("Box_Stone1_" .. index)
	FEPeelPanel.ResetBox(lbox)
	FEPeelPanel.ResetBox(rbox)
	
	local text1 = handle:Lookup("Text_StoneName_" .. index)
	local text2 = handle:Lookup("Text_StoneMes_" .. index)
	text1:SetText("")
	text2:SetText("")
	
	local text_gold = handle:Lookup("Text_Gold_" .. index)
	local text_silver = handle:Lookup("Text_Silver_" .. index)
	local text_cooper = handle:Lookup("Text_Cooper_" .. index)
	text_gold:SetText("")
	text_silver:SetText("")
	text_cooper:SetText("0")
	
	local image_gold = handle:Lookup("Image_Gold_" .. index)
	local image_silver = handle:Lookup("Image_Silver_" .. index)
	local image_cooper = handle:Lookup("Image_Cooper_" .. index)
	image_gold:Hide()
	image_silver:Hide()
	image_cooper:Show()
	
	local btn = frame:Lookup("Btn_Peel" .. index)
	btn:Enable(false)
	if handle:IsVisible() then
		btn:Show()
	else
		btn:Hide()
	end
end

function FEPeelPanel.Init(frame)
	local handle = frame:Lookup("", "")
	local box_equip = handle:Lookup("Box_FE")
	local text_tip = handle:Lookup("Text_Tip")
	
	FEPeelPanel.ResetBox(box_equip, "FEPeel")
	for i = 1, SLOT_COUNT do
		local handle_item = frame:Lookup("", "Handle_Item_" .. i)
		handle_item:Hide()
		FEPeelPanel.ResetHandle(frame, i)
	end
end

function FEPeelPanel.Uninit(frame)
	if not frame then
		frame = Station.Lookup("Normal/FEPeelPanel")
	end
	
	if not frame then
		return
	end
	
	local handle = frame:Lookup("", "")
	local box_equip = handle:Lookup("Box_FE")
	FEPeelPanel.ResetBox(box_equip, "FEPeel")
end

function FEPeelPanel.Update(frame)
	if not frame then
		frame = Station.Lookup("Normal/FEPeelPanel")
	end
	
	local player = GetClientPlayer()
	if not player then
		return
	end
	
	local handle = frame:Lookup("", "")
	local box = handle:Lookup("Box_FE")
	
	local item = GetPlayerItem(player, box.dwBox, box.dwX)
	if not item then
		return
	end
	
	local slots = item.GetSlotCount()
	for i = 1, SLOT_COUNT do
		local handle_item = frame:Lookup("", "Handle_Item_" .. i)
		if i <= slots then
			handle_item:Show()
		else
			handle_item:Hide()
		end
		FEPeelPanel.ResetHandle(frame, i)
	end
end

function FEPeelPanel.EquipmentHit(item)
	if not item then
		return false
	end
	for _, v in ipairs(EQUIP_TYPE) do
		if item.nSub == EQUIPMENT_SUB[v] then
			return true
		end
	end
	return false
end

function FEPeelPanel.ExchangeBoxItem(box, box_desc, hand_count, bhand)
	if not box or not box_desc then
		return
	end
	
	local player = GetClientPlayer()
	if not player then
		return
	end
	
	local type = box_desc:GetObjectType()
	local _, bbox, xbox = box_desc:GetObjectData()
	
	if type ~= UI_OBJECT_ITEM or not bbox or bbox < INVENTORY_INDEX.PACKAGE or bbox > INVENTORY_INDEX.PACKAGE4 then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFECommon.NEED_IN_PACKAGE)
		return
	end
	
	local item = GetPlayerItem(player, bbox, xbox)
	if not item then
		return
	end
	
	if item.nGenre ~= ITEM_GENRE.EQUIPMENT then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFEExtract.NOT_EQUIP)
		return
	end
	
	if not FEPeelPanel.EquipmentHit(item) then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFEExtract.EQUIP_CAN_NOT_EXTRACT)
		return
	end
	
	local ret = player.UnMountAllDiamonds(FEPeelPanel.dwTargetID, bbox, xbox)
	if ret ~= DIAMOND_RESULT_CODE.SUCCESS then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFEExtract.UNMOUNT_JUST_FOR_PROPERTY_EQUIP)
		return
	else
		local diamonds = GetDisplayDiamonds()
		if #diamonds == 0 then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFEExtract.UNMOUNT_JUST_FOR_PROPERTY_EQUIP)
			return
		end
	end
	
	if not box:IsEmpty() then
		FEPeelPanel.ResetBox(box, "FEPeel")
	end
	
	box.szName = item.szName
	box.dwBox = bbox
	box.dwX = xbox
	box.nCount = hand_count
	UpdataItemBoxObject(box, bbox, xbox, item)
	AddUILockItem("FEPeel", bbox, xbox)
	
	if bhand then
		Hand_Clear()
	else
		if IsObjectItem(type) then
			PlayItemSound(box_desc:GetObjectData(), true)
		else
			PlaySound(SOUND.UI_SOUND, g_sound.TakeUpSkill)
		end
	end
	
	FEPeelPanel.Update(box:GetRoot())
end

function AddItemToFEPeelPanel(box, count)
	local frame = Station.Lookup("Normal/FEPeelPanel")
	if not frame then
		return
	end
	
	local box_equip = frame:Lookup("", ""):Lookup("Box_FE")
	if not box_equip then
		return
	end
	
	FEPeelPanel.ExchangeBoxItem(box_equip, box, count)
end

function IsFEPeelPanelOpened()
	local frame = Station.Lookup("Normal/FEPeelPanel")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end

function CloseFEEquipExtractPanel(bDisableSound)
	FEPeelPanel.Uninit()

	if IsFEPeelPanelOpened() then
		Wnd.CloseWindow("FEPeelPanel")
	end
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseAuction)
	end
end

function OpenFEEquipExtractPanel(type, id, kind, bDisableSound)
	if kind == "UnStrength" then
		OpenFEProducePeelPanel(type, id, kind, bDisableSound)
		return
	end

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
	
	FEPeelPanel.dwTargetType = type
	FEPeelPanel.dwTargetID = id
	
	if not IsFEPeelPanelOpened() then
		Wnd.OpenWindow("FEPeelPanel")
	end
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
end