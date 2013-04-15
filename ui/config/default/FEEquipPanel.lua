FEEquipPanel = {}
FEEquipInfoPanel = {}

local MILLION_NUM = 1048576
local nBoxCount = 16
local nMaxAttrib = 3
local nMaxLevel = 12
local tAttribColor = { 67, 205, 128 }

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

local INI_FILE_PATH = "UI/Config/Default/FEEquipPanel.ini"

function FEEquipPanel.OnFrameCreate()
	this:RegisterEvent("FE_STRENGTH_EQUIP")
	
	FEEquipPanel.Clear(this)

	InitFrameAutoPosInfo(this, 1, nil, nil, function() CloseFEEquipPanel(true) end)
end

function FEEquipPanel.OnFrameBreathe()
	local player = GetClientPlayer()
	if not player or player.nMoveState == MOVE_STATE.ON_DEATH then
		CloseFEEquipPanel()
		return
	end
	
	if FEEquipPanel.dwTargetType then
		if FEEquipPanel.dwTargetType == TARGET.NPC then
			local npc = GetNpc(FEEquipPanel.dwTargetID)
			if not npc or not npc.CanDialog(player) then
				CloseFEEquipPanel()
			end
		elseif FEEquipPanel.dwTargetType == TARGET.DOODAD then
			local doodad = GetDoodad(FEEquipPanel.dwTargetID)
			if not doodad or not doodad.CanDialog(player) then
				CloseFEEquipPanel()
			end
		end
	end
end

function FEEquipPanel.OnEvent(szEvent)
	if szEvent == "FE_STRENGTH_EQUIP" then
		local frame = Station.Lookup("Normal/FEEquipPanel")
		local handle = frame:Lookup("", "Handle_Item")
		local nResult = arg0
		local player = GetClientPlayer()
		if nResult == DIAMOND_RESULT_CODE.SUCCESS then
			for i = 1, nBoxCount, 1 do
				local box = handle:Lookup("Box_Item" .. i)
				FEEquipPanel.ClearBox(box, "FEEquip" .. "Box_Item" .. i)
			end
			FEEquipPanel.UpdateInfo(frame)
			
			local equipBox = frame:Lookup("", ""):Lookup("Box_FE")
			local item = GetPlayerItem(player, equipBox.dwBox, equipBox.dwX)
			
			AddUILockItem("FEEquip", equipBox.dwBox, equipBox.dwX)
			if equipBox.nStrengthLevel < item.nStrengthLevel then
				OutputMessage("MSG_ANNOUNCE_YELLOW", g_tStrings.tFEEquip.SUCCEED)
			else
				OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFEEquip.FAILED)
			end
		elseif nResult == DIAMOND_RESULT_CODE.NEED_EQUIPMENT then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFECommon.BOX_JUST_FOR_EQUIP)
		elseif nResult == DIAMOND_RESULT_CODE.NEED_IN_PACKAGE then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFECommon.NEED_IN_PACKAGE)
		elseif nResult == DIAMOND_RESULT_CODE.EQUIP_UP_TO_MAX_LEVEL then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFEEquip.UP_TO_MAX_LEVEL)
		elseif nResult == DIAMOND_RESULT_CODE.ATLEAST_ONE_MATERIAL then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFECommon.ATLEAST_ONE_MATERIAL)
		elseif nResult == DIAMOND_RESULT_CODE.NOT_ENOUGH_MONEY_FOR_COST then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFECommon.NOT_ENOUGH_MONEY_FOR_COST)
		else
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFEEquip.FAILED)
		end
	end
end

function FEEquipPanel.OnItemLButtonDrag()
	this:SetObjectPressed(0)
	local szName = this:GetName()
	if Hand_IsEmpty() then
		if not this:IsEmpty() then
			if IsCursorInExclusiveMode() then
				OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.SRT_ERROR_CANCEL_CURSOR_STATE)
			elseif szName == "Box_FE" then
				Hand_Pick(this)
				FEEquipPanel.ClearBox(this, "FEEquip")
				FEEquipPanel.ClearText(this:GetRoot())
			elseif this.state == "main" then 
				FEEquipPanel.RemoveDiamon(this, true)
				FEEquipPanel.UpdateInfo(this:GetRoot())
			end
		end
	end
end

function FEEquipPanel.OnItemLButtonDragEnd()
	this.bIgnoreClick = true
	local szName = this:GetName()
	if not Hand_IsEmpty() then
		local boxHand, nHandCount = Hand_Get()
		if szName == "Box_FE" then
			FEEquipPanel.ExchangeEquipBoxItem(this, boxHand, nHandCount, true)
		else
			FEEquipPanel.AddDiamon(this, boxHand, nHandCount, true)
		end
	end
end

function FEEquipPanel.Clear(frame)
	if not frame then
		frame = Station.Lookup("Normal/FEEquipPanel")
	end
	
	local equipBox = frame:Lookup("", ""):Lookup("Box_FE")
	local handle = frame:Lookup("", "Handle_Item")
	local btnMaking = frame:Lookup("Btn_Making")
	
	FEEquipPanel.ClearBox(equipBox, "FEEquip")
	btnMaking:Enable(false)
	
	for i = 1, nBoxCount, 1 do
		local box = handle:Lookup("Box_Item" .. i)
		FEEquipPanel.ClearBox(box, "FEEquip" .. "Box_Item" .. i)
	end
	
	FEEquipPanel.ClearText(frame)
end

function FEEquipPanel.ClearBox(box, szLockName)
	box.state = "empty"
	box.dwBox = 0
	box.dwX = 0
	box.nCount = 0
	RemoveUILockItem(szLockName)
	
	box:ClearObject()
	box:SetOverText(0, "")
	box:EnableObject(true)
end

function FEEquipPanel.ClearText(frame)
	local handle = frame:Lookup("", "")
	handle:Lookup("Text_Rate"):SetText("")
	handle:Lookup("Handle_LvUp"):Clear()
	handle:Lookup("Text_Gold"):SetText("")
	handle:Lookup("Text_Silver"):SetText("")
	handle:Lookup("Text_Cooper"):SetText("0")
	handle:Lookup("Image_Gold"):Hide()
	handle:Lookup("Image_Silver"):Hide()
	handle:Lookup("Text_Produce"):SetText(g_tStrings.tFEEquip.EQUIP_CAN_NOT_EMPTY)
end

function FEEquipPanel.OnItemMouseEnter()
	this:SetObjectMouseOver(1)
	local szName = this:GetName()
	local x, y = this:GetAbsPos()
	local w, h = this:GetSize()
	if szName == "Box_FE" then
		if this:IsEmpty() then
			OutputTip(GetFormatText(g_tStrings.tFEEquip.EQUIP_CAN_NOT_EMPTY), 400, {x, y ,w, h})
		else
			OutputItemTip(UI_OBJECT_ITEM, this.dwBox, this.dwX, nil, {x, y, w, h})
		end
	else
		if this.state == "main" or this.state == "static" then
			OutputItemTip(UI_OBJECT_ITEM, this.dwBox, this.dwX, nil, {x, y, w, h})
		else
			OutputTip(GetFormatText(g_tStrings.tFEEquip.NO_EQUIP), 400, {x, y ,w, h})
		end
	end
end

function FEEquipPanel.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_Making" then
		FEEquipPanel.EnchantEquip(this:GetRoot())
	elseif szName == "Btn_Close" then
		CloseFEEquipPanel()
	end
end

function FEEquipPanel.EnchantEquip(frame)
	local player = GetClientPlayer()
	if not player then
		return
	end
	
	local handle = frame:Lookup("", "")
	local equipBox = handle:Lookup("Box_FE")
	if equipBox:IsEmpty() then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFEEquip.EQUIP_CAN_NOT_EMPTY)
		return
	end
	
	local nMaterial, tMaterial = FEEquipPanel.GetMaterialTable(frame)
	if nMaterial == 0 then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFECommon.ATLEAST_ONE_MATERIAL)
		return
	end
	
	local item = GetPlayerItem(player, equipBox.dwBox, equipBox.dwX)
	if not item then
		return
	end
	equipBox.nStrengthLevel = item.nStrengthLevel
	
	RemoteCallToServer("OnStrengthEquip", FEEquipPanel.dwTargetID, equipBox.dwBox, equipBox.dwX, tMaterial)
end

function FEEquipPanel.OnItemMouseLeave()
	this:SetObjectMouseOver(0)
	HideTip()
end

function FEEquipPanel.OnItemLButtonUp()
	this:SetObjectPressed(0)
end

function FEEquipPanel.OnItemLButtonDown()
	this:SetObjectPressed(1)
end

function FEEquipPanel.OnItemRButtonClick()
	local szName = this:GetName()
	if szName == "Box_FE" then
		if not this:IsEmpty() then
			FEEquipPanel.ClearBox(this, "FEEquip")
			FEEquipPanel.ClearText(this:GetRoot())
			FEEquipPanel.UpdateInfo(this:GetRoot())
			HideTip()
			local nType = this:GetObjectType()
			if IsObjectItem(nType) then
				PlayItemSound(this:GetObjectData(), true)
			else
				PlaySound(SOUND.UI_SOUND, g_sound.TakeUpSkill)
			end
		end
	else
		local nBoxIndex = tonumber(string.sub(szName, 9, -1)) or 0
		if nBoxIndex > 0 and nBoxIndex <= nBoxCount and szName == "Box_Item" .. nBoxIndex then
			if not this:IsEmpty() and this.state == "main" then
				FEEquipPanel.RemoveDiamon(this)
				FEEquipPanel.UpdateInfo(this:GetRoot())
				HideTip()
				local nType = this:GetObjectType()
				if IsObjectItem(nType) then
					PlayItemSound(this:GetObjectData(), true)
				else
					PlaySound(SOUND.UI_SOUND, g_sound.TakeUpSkill)
				end
			end
		end
	end
end

function FEEquipPanel.OnItemLButtonClick()
	local szName = this:GetName()
	if szName == "Box_FE" then
		if Hand_IsEmpty() then
			if not this:IsEmpty() then
				if IsCursorInExclusiveMode() then
					OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.SRT_ERROR_CANCEL_CURSOR_STATE)
				else
					Hand_Pick(this)
					FEEquipPanel.ClearBox(this, "FEEquip")
					FEEquipPanel.ClearText(this:GetRoot())
					FEEquipPanel.UpdateInfo(this:GetRoot())
					HideTip()
				end
			end
		else
			local boxHand, nHandCount = Hand_Get()
			FEEquipPanel.ExchangeEquipBoxItem(this, boxHand, nHandCount, true)
			HideTip()
		end
	else
		local nBoxIndex = tonumber(string.sub(szName, 9, -1)) or 0
		if nBoxIndex > 0 and nBoxIndex <= nBoxCount and szName == "Box_Item" .. nBoxIndex then
			if Hand_IsEmpty() then
				if not this:IsEmpty() and this.state == "main" then
					if IsCursorInExclusiveMode() then
						OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.SRT_ERROR_CANCEL_CURSOR_STATE)
					else
						FEEquipPanel.RemoveDiamon(this, true)
						HideTip()
					end
				end
			else
				local boxHand, nHandCount = Hand_Get()
				FEEquipPanel.AddDiamon(this, boxHand, nHandCount, true)
				HideTip()
			end
		end
	end
end

function FEEquipPanel.RemoveDiamon(box, bHand)
	if not box or box:IsEmpty() then
		return
	elseif bHand then
		Hand_Pick(box)
	end
	
	local szName = box:GetName()
	local nStartBox = tonumber(string.sub(szName, 9, -1))
	local player = GetClientPlayer()
	local nStep = this.nCount
	
	for i = nStartBox, nStartBox + nStep -1 do
		local hGroupBox = box:GetParent():Lookup("Box_Item" .. i)
		FEEquipPanel.ClearBox(hGroupBox, "FEEquip" .. "Box_Item" .. i)
	end
	
	for i = nStartBox + nStep, nBoxCount, 1 do
		local hBoxFrom = box:GetParent():Lookup("Box_Item" .. i)
		local hBoxTo = box:GetParent():Lookup("Box_Item" .. i - nStep)
		if hBoxFrom.state == "main" then
			hBoxTo.szName = hBoxFrom.szName
			hBoxTo.dwBox = hBoxFrom.dwBox
			hBoxTo.dwX = hBoxFrom.dwX
			hBoxTo.nCount = hBoxFrom.nCount
			hBoxTo.state = "main"
			FEEquipPanel.ClearBox(hBoxFrom, "FEEquip" .. "Box_Item" ..i)
			
			local item = GetPlayerItem(player, hBoxTo.dwBox, hBoxTo.dwX)
			if not item then
				return
			end
			hBoxTo:SetObject(UI_OBJECT_ITEM, item.nUiId, hBoxTo.dwBox, hBoxTo.dwX, item.nVersion, item.dwTabType, item.dwIndex)	
			hBoxTo:SetObjectIcon(Table_GetItemIconID(item.nUiId))
			hBoxTo:SetOverText(0, "")
			hBoxTo:EnableObject(true)
			AddUILockItem("FEEquip" .. "Box_Item" .. i - nStep, hBoxTo.dwBox, hBoxTo.dwX)
		elseif hBoxFrom.state == "static" then
			hBoxTo.state = "static"
			hBoxTo.dwBox = hBoxFrom.dwBox
			hBoxTo.dwX = hBoxFrom.dwX
			hBoxTo.nCount = hBoxFrom.nCount
			hBoxTo.IconID = hBoxFrom.IconID
			hBoxTo:SetObject(UI_OBJECT_NOT_NEED_KNOWN, 0)
			hBoxTo:SetObjectIcon(hBoxTo.IconID)
			hBoxTo:EnableObject(false)
			FEEquipPanel.ClearBox(hBoxFrom, "FEEquip" .. "Box_Item" ..i)
		end
	end
	
	FEEquipPanel.UpdateInfo(box:GetRoot())
end

function FEEquipPanel.AddDiamon(boxItem, boxDsc, nHandCount, bHand)
	if not boxItem or not boxDsc then
		return
	end
	
	local player = GetClientPlayer()
	if not player then
		return
	end
	
	local nType = boxDsc:GetObjectType()
	local _, dwBox, dwX = boxDsc:GetObjectData()
	
	if nType ~= UI_OBJECT_ITEM or not dwBox or dwBox < INVENTORY_INDEX.PACKAGE or dwBox > INVENTORY_INDEX.PACKAGE4 then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFECommon.MATERIAL_JUST_FOR_DIAMON)
		return 
	end
	
	local item = GetPlayerItem(player, dwBox, dwX)
	if not item then
		return
	end
	
	if item.nGenre ~= ITEM_GENRE.DIAMOND then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFECommon.MATERIAL_JUST_FOR_DIAMON)
		return
	end
	
	local nCount = 1
	if item.bCanStack then
		nCount = item.nStackNum
	end
	
	if nHandCount and nHandCount < nCount then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFECommon.DIAMON_UNPACK)
		return
	end
	
	local handle = boxItem:GetParent()
	local nEmptyBox = 0
	for i = 1, nBoxCount, 1 do
		local box = handle:Lookup("Box_Item" .. i)
		if box.state == "empty" then
			nEmptyBox = nEmptyBox + 1
		end
	end
	
	if nEmptyBox < nCount then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFECommon.MATERIAL_BOX_FULL)
		return
	end
	
	local szName = "Box_Item" .. nBoxCount - nEmptyBox + 1
	local emptyBox = handle:Lookup(szName)
	emptyBox.state = "main"
	emptyBox.szName = item.szName
	emptyBox.dwBox = dwBox
	emptyBox.dwX = dwX
	emptyBox.nCount = nCount
	emptyBox:SetObject(UI_OBJECT_ITEM, item.nUiId, dwBox, dwX, item.nVersion, item.dwTabType, item.dwIndex)	
	emptyBox:SetObjectIcon(Table_GetItemIconID(item.nUiId))
	emptyBox:SetOverText(0, "")
	if emptyBox:IsObjectMouseOver() then
		local x, y = emptyBox:GetAbsPos()
		local w, h = emptyBox:GetSize()
		OutputItemTip(UI_OBJECT_ITEM, dwBox, dwX, nil, {x, y, w, h})	
	end
	--UpdataItemBoxObject(emptyBox, emptyBox.dwBox, emptyBox.dwX, item)
	AddUILockItem("FEEquip" .. szName, dwBox, dwX)
	for i = nBoxCount -  nEmptyBox + 2, nBoxCount - nEmptyBox + nCount do
		emptyBox = handle:Lookup("Box_Item" .. i)
		emptyBox.state = "static"
		emptyBox.IconID = Table_GetItemIconID(item.nUiId)
		emptyBox:SetObject(UI_OBJECT_NOT_NEED_KNOWN, 0)
		emptyBox:SetObjectIcon(emptyBox.IconID)
		emptyBox:EnableObject(false)
		emptyBox.dwBox = dwBox
		emptyBox.dwX = dwX
	end
	
	if bHand then
		Hand_Clear()
	else
		if IsObjectItem(nType) then
			PlayItemSound(boxDsc:GetObjectData(), true)
		else
			PlaySound(SOUND.UI_SOUND, g_sound.TakeUpSkill)
		end
	end
	
	FEEquipPanel.UpdateInfo(boxItem:GetRoot())
end

function FEEquipPanel.GetMaterialTable(frame)
	local nMaterial = 0
	local tMaterial = {}
	local handle = frame:Lookup("", "Handle_Item")
	
	for i = 1, nBoxCount, 1 do
		local box = handle:Lookup("Box_Item" .. i)
		if box.state == "main" or box.state == "static" then
			table.insert(tMaterial, {box.dwBox, box.dwX})
			nMaterial = nMaterial + 1
		end
	end
	
	return nMaterial, tMaterial
end

function FEEquipPanel.ExchangeEquipBoxItem(equipBox, descBox, nHandCount, bHand)
	if not equipBox or not descBox then
		return
	end
	
	local player = GetClientPlayer()
	if not player then
		return
	end
	
	local nType = descBox:GetObjectType()
	local _, dwBox, dwX = descBox:GetObjectData()
	
	if nType ~= UI_OBJECT_ITEM or not dwBox then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFEEquip.JUST_FOR_EQUIP)
		return
	end
	
	if dwBox < INVENTORY_INDEX.PACKAGE or dwBox > INVENTORY_INDEX.PACKAGE4 then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFECommon.NEED_IN_PACKAGE)
		return
	end
	
	local item = GetPlayerItem(player, dwBox, dwX)
	if not item then
		return
	end
	
	if item.nGenre ~= ITEM_GENRE.EQUIPMENT then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFEEquip.JUST_FOR_EQUIP)
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
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFEEquip.JUST_FOR_PROPERTY_EQUIP)
		return
	end
	
	if item.nStrengthLevel == nMaxLevel then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFEEquip.UP_TO_MAX_LEVEL)
		return
	end
	
	if not equipBox:IsEmpty() then
		RemoveUILockItem("FEEquip")
	end
	equipBox.szName = item.szName
	equipBox.dwBox = dwBox
	equipBox.dwX = dwX
	equipBox.nCount = nHandCount
	equipBox.state = "main"
	UpdataItemBoxObject(equipBox, equipBox.dwBox, equipBox.dwX, item)
	
	if bHand then
		Hand_Clear()
	else
		if IsObjectItem(nType) then
			PlayItemSound(descBox:GetObjectData(), true)
		else
			PlaySound(SOUND.UI_SOUND, g_sound.TakeUpSkill)
		end
	end
	
	AddUILockItem("FEEquip", dwBox, dwX)
	FEEquipPanel.UpdateInfo(equipBox:GetRoot())
end

function FEEquipInfoPanel.OnFrameCreate()
	local btn = this:Lookup("Btn_Close")
	btn:Hide()
end

function FEEquipPanel.OpenInfoPanel(x, y)
	if IsOptionOrOptionChildPanelOpened() then
		return
	end
	
	local frame = Station.Lookup("Topmost1/FEEquipInfoPanel")
	if frame then
		return
	end
	
	frame = Wnd.OpenWindow("FEEquipInfoPanel")
	frame:SetRelPos(x - 4, y + 40)
end

function FEEquipPanel.CloseInfoPanel()
	local frame = Station.Lookup("Topmost1/FEEquipInfoPanel")
	
	if not frame then
		return
	end
	
	Wnd.CloseWindow("FEEquipInfoPanel")
end

function FEEquipPanel.OutputInfo(szText)
	local frame = Station.Lookup("Topmost1/FEEquipInfoPanel")
	if not frame then
		return
	end
	
	local handle = frame:Lookup("", "Handle_Message")
	handle:Clear()
	handle:AppendItemFromString(szText)
	handle:FormatAllItemPos()
	
	handle = frame:Lookup("", "")
	local handleMsg = handle:Lookup("Handle_Message")
	local w, h = handleMsg:GetAllItemSize()
	w, h = 255, h + 19

	handleMsg:SetSize(w, h)
	handleMsg:SetItemStartRelPos(0, 0)
	
	local image = handle:Lookup("Image_Bg")
	image:SetSize(w, h)	
	
	handle:SetSize(10000, 10000)
	handle:FormatAllItemPos()
	w, h = handle:GetAllItemSize()
	handle:SetSize(w, h)
	frame:SetSize(w, h)
end

function FEEquipPanel.UpdateInfo(frame)
	local player = GetClientPlayer()
	if not player then
		return
	end
	
	local handle = frame:Lookup("", "")
	local equipBox = handle:Lookup("Box_FE")
	local btnMaking = frame:Lookup("Btn_Making")
	local textProduce = handle:Lookup("Text_Produce")
	btnMaking:Enable(false)
	if equipBox:IsEmpty() then
		FEEquipPanel.CloseInfoPanel()
		textProduce:SetText(g_tStrings.tFEEquip.EQUIP_CAN_NOT_EMPTY)
		return
	else
		local x, y = frame:GetRelPos()
		local w, h = frame:GetSize()
		FEEquipPanel.OpenInfoPanel(x + w, y)
	end
	
	local item = GetPlayerItem(player, equipBox.dwBox, equipBox.dwX)
	if not item then
		return
	end
	
	if item.nStrengthLevel == nMaxLevel then
		textProduce:SetText(g_tStrings.tFEEquip.UP_TO_MAX_LEVEL)
		FEEquipPanel.CloseInfoPanel()
	else
		textProduce:SetText(FormatString(g_tStrings.tFEEquip.CURRENT_LEVEL, item.nStrengthLevel))
		local tAttrib1 = item.GetMagicAttribByStrengthLevel(item.nStrengthLevel)
		local tAttrib2 = item.GetMagicAttribByStrengthLevel(item.nStrengthLevel + 1)
		local szTip = ""
		local nTipTop = 0
		if tAttrib1 then
			nTipTop = #tAttrib1
		end
		
		szTip = "<text>text=" .. EncodeComponentsString(FormatString(g_tStrings.tFEEquip.INFO_LEVEL, item.nStrengthLevel + 1)) ..
			" font=31 </text>"
		szTip = szTip .. "<text>text=\"\\\n\"</text>"
		
		for i = 1, nTipTop, 1 do
			local szText = FormatString(Table_GetMagicAttributeInfo(tAttrib1[i].nID, true), tAttrib1[i].nValue1, tAttrib1[i].nValue2)
			if szText ~= "" then
				szText = szText .. FormatString(g_tStrings.tFEEquip.EQUIP_INFO, tAttrib2[i].nValue1)
				szText = szText .. "<text>text=\"\\\n\"</text>"
				szTip = szTip .. szText
			end
		end
		
		FEEquipPanel.OutputInfo(szTip)
	end
	
	local nMaterial, tMaterial = FEEquipPanel.GetMaterialTable(frame)
	local nRate = 0
	local nCost = 0
	local bResult = false
	
	if nMaterial > 0 and nMaterial <= nBoxCount then
		btnMaking:Enable(true)
		bResult, nCost, nRate = GetStrengthEquipInfo(equipBox.dwBox, equipBox.dwX, tMaterial)
	end
	
	local nGold, nSilver, nCooper = MoneyToGoldSilverAndCopper(nCost)
	local rateText = handle:Lookup("Text_Rate")
	local lvUpText = handle:Lookup("Handle_LvUp")
	local goldText = handle:Lookup("Text_Gold")
	local silverText = handle:Lookup("Text_Silver")
	local cooperText = handle:Lookup("Text_Cooper")
	local goldImage = handle:Lookup("Image_Gold")
	local silverImage = handle:Lookup("Image_Silver")
	local cooperImage = handle:Lookup("Image_Cooper")
	
	lvUpText:Clear()
	if item.nStrengthLevel < nMaxLevel then
		rateText:SetText(FormatString(g_tStrings.tFEEquip.LEVEL_UP_RATE, string.format("%.2f", nRate / MILLION_NUM * 100)))
		local szLvUpText = FormatString(g_tStrings.tFEEquip.LEVEL_UP, item.nStrengthLevel + 1)
		lvUpText:AppendItemFromString(szLvUpText)
		lvUpText:FormatAllItemPos()
	end
	
--	for i = 1, nAttribTop, 1 do
--		if tAttrib1[i].nValue1 ~= tAttrib2[i].nValue1 then
--			local szText = FormatString(Table_GetMagicAttributeInfo(tAttrib1[i].nID, true), tAttrib1[i].nValue1, tAttrib1[i].nValue2)
--			table.insert(tStrengthAttrib, { szText, tAttrib1[i].nValue1, tAttrib2[i].nValue1 } )
--		end
--	end
--	
--	handleTip:Clear()
--	for i = 1, nMaxAttrib, 1 do
--		if tStrengthAttrib[i] then
--			local handleSubTip = handleTip:AppendItemFromIni(INI_FILE_PATH, "Handle_Tip1")
--			local szText = tStrengthAttrib[i][1] .. FormatString(g_tStrings.tFEEquip.EQUIP_INFO, tStrengthAttrib[i][3])
--			handleSubTip:AppendItemFromString(szText)
--			handleSubTip:FormatAllItemPos()
--		end
--	end
--	handleTip:FormatAllItemPos()
	
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
	
	cooperImage:Show()
	cooperText:SetText(nCooper)
		
	handle:Lookup("Text_Money"):Show()
end

function OpenFEEquipPanel(dwTargetType, dwTargetID, bDisableSound)
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
	
	FEEquipPanel.dwTargetType = dwTargetType
	FEEquipPanel.dwTargetID = dwTargetID
	
	if not IsFEEquipPanelOpened() then
		Wnd.OpenWindow("FEEquipPanel")
	end
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
end

function CloseFEEquipPanel(bDisableSound)
	RemoveUILockItem("FEEquip")
	for i = 1, nBoxCount, 1 do
		RemoveUILockItem("FEEquip" .. "Box_Item" .. i)
	end
	
	if IsFEEquipPanelOpened() then
		FEEquipPanel.CloseInfoPanel()
		Wnd.CloseWindow("FEEquipPanel")
	end
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseAuction)
	end
end

function IsFEEquipPanelOpened()
	local frame = Station.Lookup("Normal/FEEquipPanel")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end

function AddFEEquipDiamonOnItemRButtonClick(box, nCount)
	local frame = Station.Lookup("Normal/FEEquipPanel")
	if not frame then
		return
	end
	local handle = frame:Lookup("", "Handle_Item")
	
	local equipBox = frame:Lookup("", ""):Lookup("Box_FE")
	local materialBox = handle:Lookup("Box_Item1")
	
	local player = GetClientPlayer()
	local _, dwBox, dwX = box:GetObjectData()
	local item = GetPlayerItem(player, dwBox, dwX)
	if not item then
		return
	end
	
	if item.nGenre == ITEM_GENRE.EQUIPMENT then
		FEEquipPanel.ExchangeEquipBoxItem(equipBox, box, nCount)
	elseif item.nGenre == ITEM_GENRE.DIAMOND then
		FEEquipPanel.AddDiamon(materialBox, box, nCount)
	else
		if equipBox:IsEmpty() then
			FEEquipPanel.ExchangeEquipBoxItem(equipBox, box, nCount)
		else	
			FEEquipPanel.AddDiamon(materialBox, box, nCount)
		end
	end
end

function IsItemCanBeEquip(nGenre, nSub)
	if nGenre ~= ITEM_GENRE.EQUIPMENT then
		return false
	end
	local bSubKind = false
	for _, v in ipairs(tEquipKind) do
		if nSub == EQUIPMENT_SUB[v] then
			bSubKind = true
			break
		end
	end
	return bSubKind
end