FEActivationPanel = {
	active = {},
}

local SLOT_COUNT = 3
local FEA_COUNT	 = 3
local INI_FILE_PATH = "UI/Config/Default/FEActivationPanel.ini"
local IMAGE_EAGE = 2
local DIAMOND_MAX_LEVEL = 6					--宝石的最大等级

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

local IMAGE_FRAME = {
	[0] = 21,		--没有五行属性
	[1] = 29,		--金
	[2] = 28,		--木
	[4] = 30,		--土
	[8] = 31,		--水
	[16] = 27,		--火
	[3] = 15,		--金木
	[5] = 14,		--金水
	[17] = 16,		--金土
	[9] = 13, 		--金火
	[18] = 20, 		--木土
	[6] = 18,		--木水
	[10] = 11,		--木火
	[20] = 19,		--土水
	[24] = 12, 		--土火
	[12] = 17,		--水火
	
	[31] = 18		--测试用
}

local IMAGE_ACTIVE =
{
	[0] = 32,
	[1] = 32,
	[2] = 32,
	[3] = 32
}

local MOUNT_TYPE = {
	[0] = { "NULL", "NULL" },		--没有五行属性
	[3] = { "金", "木" },
	[5] = { "金", "水" },
	[17] = { "金", "土" },
	[9] = { "金", "火" },
	[18] = { "木", "土" },
	[6] = { "木", "水" },
	[10] = { "木", "火" },
	[20] = { "土", "水" },
	[24] = { "土", "火" },
	[12] = { "水", "火" },

	[31] = { "NULL", "NULL" }	--测试用
}

function GetFEMountType(mask)
	local mt = MOUNT_TYPE[mask]
	if mt then
		return mt[1], mt[2]
	end
end

local MOUNT_FONT = {	--金27，木198， 土164， 火196， 水47
	[0] = { 27, 163 },
	[3] = { 27, 198 },
	[5] = { 27, 47 },
	[17] = { 27, 164 },
	[9] = { 27, 196 },
	[18] = { 198, 164 },
	[6] = { 198, 47 },
	[10] = { 198, 196 },
	[20] = { 164, 47 },
	[24] = { 164, 196 },
	[12] = { 47, 196 },

	[31] = { 163, 163 }
}

local ADJUST_POS = {
	[1] = { { x = 16, y = 68 }, { x = 0, y = 0 }, { x = 0, y = 0 }, { x = 16, y = 188} },
	[2] = { { x = 16, y = 42 }, { x = 16, y = 102 }, { x = 0, y = 0 }, { x = 16, y = 188} },
	[3] = { { x = 16, y = 32 }, { x = 16, y = 82 }, { x = 16, y = 132 }, { x = 16, y = 188 } },
}

local ADJUST_TEXT_POS = {
	[1] = { { x = 70, y = 68 }, { x = 0, y = 0 }, { x = 0, y = 0 }, { x = 70, y = 188 } },
	[2] = { { x = 70, y = 42 }, { x = 70, y = 102 }, { x = 0, y = 0 }, { x = 70, y = 188 } },
	[3] = { { x = 70, y = 32 }, { x = 70, y = 82 }, { x = 70, y = 132 }, { x = 70, y = 188} },
}

local ADJUST_BUTTON_POS = {
	[1] = { { x = 200, y = 146 }, { x = 0, y = 0 }, { x = 0, y = 0 }, { x = 200, y = 206} },
	[2] = { { x = 200, y = 120 }, { x = 200, y = 180 }, { x = 0, y = 0 }, { x = 200, y = 240 } },
	[3] = { { x = 200, y = 110 }, { x = 200, y = 160 }, { x = 200, y = 210 }, { x = 200, y = 270} },
}

local ADJUST_ANIMATE_POS = {
	[1] = { { x = 14, y = 66 }, { x = 0, y = 0 }, { x = 0, y = 0 }, { x = 14, y = 186} },
	[2] = { { x = 14, y = 40 }, { x = 14, y = 100 }, { x = 0, y = 0 }, { x = 14, y = 186} },
	[3] = { { x = 14, y = 30 }, { x = 14, y = 80 }, { x = 14, y = 130 }, { x = 14, y = 186 } },
}

local ADJUST_MOUNT_POS = {
	["box"] = { x = 30, y = 71 },
	["image"] = { x = 28, y = 69 },
	["text"] = { x = 82, y = 69 },
	["button"] = { x = 200, y = 152 },
	["animation"] = { x = 28, y = 69 }
}

local DIAMOND_TYPE = 
{
	[0] = { name = "五行石·金", font = 27 },
	[1] = { name = "五行石·木", font = 198 },
	[2] = { name = "五行石·水", font = 47 },
	[3] = { name = "五行石·火", font = 196 },
	[4] = { name = "五行石·土", font = 194 },
	[5] = { name = "所有五行石", font = 194 },
}

function GetDiamondFormatString(nType)
	local diamond = DIAMOND_TYPE[nType]
	if not diamond then
		return ""
	end
	
	local szText = FormatString(g_tStrings.tActivation.DIAMON_NAME, diamond.name)
	return szText, diamond.font
end

function FEActivationPanel.OnFrameCreate()
	this:RegisterEvent("MOUNT_DIAMON")
	this:RegisterEvent("MOUNT_COLOR_DIAMON")
	this:RegisterEvent("BAG_ITEM_UPDATE")
	this:RegisterEvent("SWITCH_BIGSWORD")
	
	InitFrameAutoPosInfo(this, 1, nil, nil, function() CloseFEActivationPanel(true) end)
	
	FEActivationPanel.SetLayout(this)
	FEActivationPanel.Update(this, true)
end

function FEActivationPanel.OnFrameBreathe()
	local player = GetClientPlayer()
	if not player or player.nMoveState == MOVE_STATE.ON_DEATH then
		CloseFEActivationPanel()
		return
	end
end

function FEActivationPanel.OnItemMouseEnter()
	local name = this:GetName()
	if name == "Image_Jin" or name == "Image_Mu" or name == "Image_Shui" or name == "Image_Huo" 
					or name == "Image_Tu" then
		FEActivationPanel.OutputFEImageTip(this)
		return
	end
	
	this:SetObjectPressed(1)
	if name == "Box_FE1" or name == "Box_FE2" or name == "Box_FE3" then
		FEActivationPanel.OutputSlotAttributeTip(this)
	elseif not this:IsEmpty() then
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
		OutputItemTip(UI_OBJECT_ITEM, this.dwBox, this.dwX, nil, {x, y, w, h})
	elseif name == "Box_FE4" then
		FEActivationPanel.OutputColorSlotTip(this)
	elseif name == "Box_Weapon" then
		FEActivationPanel.OutputWeaponColorDiamondTip(this)
	end
end

function FEActivationPanel.OnItemMouseLeave()
	local name = this:GetName()
	if name == "Image_Jin" or name == "Image_Mu" or name == "Image_Shui" or name == "Image_Huo" 
					or name == "Image_Tu" then
		HideTip()
		return
	end
	
	this:SetObjectPressed(0)
	HideTip()
end

function FEActivationPanel.OnItemLButtonClick()
	local name = this:GetName()
	if name == "Box_FE1" or name == "Box_FE2" or name == "Box_FE3" or name == "Box_FE4" then
		if Hand_IsEmpty() then
			if not this:IsEmpty() then
				if IsCursorInExclusiveMode() then
					OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.SRT_ERROR_CANCEL_CURSOR_STATE)
				else
					Hand_Pick(this)
					FEActivationPanel.ResetBox(this, "FEActivation" .. name)
					FEActivationPanel.Update(this:GetRoot())
				end
			end
		else
			local boxHand, nHandCount = Hand_Get()
			FEActivationPanel.ExchangeBoxItem(this, boxHand, nHandCount, true)
			FEActivationPanel.Update(this:GetRoot())
		end
	end
end

function FEActivationPanel.OnItemRButtonClick()
	local name = this:GetName()
	if name == "Box_FE1" or name == "Box_FE2" or name == "Box_FE3" and not this:IsEmpty() then
		FEActivationPanel.ResetBox(this, "FEActivation" .. name)
		FEActivationPanel.Update(this:GetRoot())
		local box_type = this:GetObjectType()
		if IsObjectItem(box_type) then
			PlayItemSound(this:GetObjectData(), true)
		else
			PlaySound(SOUND.UI_SOUND, g_sound.TakeUpSkill)
		end
	end
end

function FEActivationPanel.OnLButtonClick()
	local name = this:GetName()
	if name == "Btn_Setting" then
		FEActivationPanel.Active(this:GetRoot(), 1)
	elseif name == "Btn_Setting1" then
		FEActivationPanel.Active(this:GetRoot(), 2)
	elseif name == "Btn_Setting2" then
		FEActivationPanel.Active(this:GetRoot(), 3)
	elseif name == "Btn_Setting3" then
		FEActivationPanel.Mount(this:GetRoot())
	elseif name == "Btn_Close" then
		CloseFEActivationPanel()
	end
end

function FEActivationPanel.OnEvent(event)
	if event == "MOUNT_DIAMON" then
		FEActivationPanel.OnMountDiamond(arg0)
		FEActivationPanel.Update()
	elseif event == "MOUNT_COLOR_DIAMON" then
		FEActivationPanel.OnMountDiamond(arg0)
		FEActivationPanel.Update()
	elseif event == "BAG_ITEM_UPDATE" then
		RemoveUILockItem("FEActivation")
		AddUILockItem("FEActivation", FEActivationPanel.dwBox, FEActivationPanel.dwX)
	elseif event == "SWITCH_BIGSWORD" then
		CloseFEActivationPanel()
	end
end

function FEActivationPanel.OnMountDiamond(result)
	if result == DIAMOND_RESULT_CODE.SUCCESS then
		OutputMessage("MSG_ANNOUNCE_YELLOW", g_tStrings.tActivation.SUCCESS)
	elseif result == DIAMOND_RESULT_CODE.CAN_NOT_OPERATE_IN_FIGHT then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tActivation.CAN_NOT_OPERATE_IN_FIGHT)
	elseif result == DIAMOND_RESULT_CODE.NEED_EQUIP_BIND then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tActivation.NEED_EQUIP_BIND)
	elseif result == DIAMOND_RESULT_CODE.SCENE_FORBID then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFECommon.SCENE_FORBID)
	else
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tActivation.FAILED)
	end
end

function FEActivationPanel.Mount(frame)
	local box_equip = frame:Lookup("", ""):Lookup("Box_FE")
	local handle = frame:Lookup("", "Handle_FE")
	local box = handle:Lookup("Box_FE4")
	local animate = handle:Lookup("Animate_XQ4")
	
	if box_equip:IsEmpty() then
		CloseFEActivationPanel()
		return
	end

	local fnActive = function()
		RemoteCallToServer("OnMountColorDiamond", box_equip.dwBox, box_equip.dwX, box.dwBox, box.dwX)
		FEActivationPanel.ResetBox(box, "FEActivationBox_FE4")
		
		animate:Show()
		animate:SetAnimate("ui/Image/UICommon/FEPanel3.UITex", 1, 0)
		FEActivationPanel.Update(frame)
	end

	if not box:IsEmpty() then
		local msg = {
			szMessage = g_tStrings.tActivation.MOUNT_MESSAGE, 
			szName = "MountSlotSure", 
			fnAutoClose = function() if not IsFEActivationPanelOpened() then return true end end,
			{szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = fnActive, szSound = g_sound.Trade},
			{szOption = g_tStrings.STR_HOTKEY_CANCEL}
		}
		MessageBox(msg)
	end
end

function FEActivationPanel.Active(frame, index)
	local box_equip = frame:Lookup("", ""):Lookup("Box_FE")
	local handle = frame:Lookup("", "Handle_FE")
	local box = handle:Lookup("Box_FE" .. index)
	local animate = handle:Lookup("Animate_XQ" .. index)
	
	if box_equip:IsEmpty() then
		CloseFEActivationPanel()
		return
	end

	local fnActive = function()
		RemoteCallToServer("OnMountDiamond", box_equip.dwBox, box_equip.dwX, box.dwBox, box.dwX, index - 1)
		FEActivationPanel.ResetBox(box, "FEActivationBox_FE" .. index)
		
		animate:Show()
		animate:SetAnimate("ui/Image/UICommon/FEPanel3.UITex", 1, 0)
		FEActivationPanel.Update(frame)
	end

	if not box:IsEmpty() then
		local msg = {
			szMessage = g_tStrings.tActivation.MESSAGE, 
			szName = "ActiveSlotSure", 
			fnAutoClose = function() if not IsFEActivationPanelOpened() then return true end end,
			{szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = fnActive, szSound = g_sound.Trade},
			{szOption = g_tStrings.STR_HOTKEY_CANCEL}
		}
		MessageBox(msg)
	end
end

function FEActivationPanel.ResetBox(box, name)
	box.dwBox = 0
	box.dwX = 0
	box.nCount = 0
	box.nLevel = 0
	box:ClearObject()
	box:SetOverText(0, "")
	
	if name then
		RemoveUILockItem(name)
	end
end

function FEActivationPanel.OnItemLButtonDrag()
	local name = this:GetName()
	this:SetObjectPressed(0)
	if Hand_IsEmpty() then
		if not this:IsEmpty() then
			if IsCursorInExclusiveMode() then
				OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.SRT_ERROR_CANCEL_CURSOR_STATE)
			elseif name == "Box_FE1" or name == "Box_FE2" or name == "Box_FE3" or name == "Box_FE4" then
				Hand_Pick(this)
				RemoveUILockItem("FEActivation" .. name)
				this.dwBox = 0
				this.dwX = 0
				this:ClearObject()
				this:SetOverText(0, "")
				FEActivationPanel.Update(this:GetRoot())
			end
		end
	end
end

function FEActivationPanel.OnItemLButtonDragEnd()
	this.bIgnoreClick = true
	local name = this:GetName()
	if not Hand_IsEmpty() then
		if name == "Box_FE1" or name == "Box_FE2" or name == "Box_FE3" or name == "Box_FE4" then
			local box, hand_count = Hand_Get()
			FEActivationPanel.ExchangeBoxItem(this, box, hand_count, true)
			FEActivationPanel.Update(this:GetRoot())
		end
	end
end

function FEActivationPanel.OnItemLButtonUp()
	this:SetObjectPressed(0)
end

function FEActivationPanel.OnItemLButtonDown()
	this:SetObjectPressed(1)
end

function FEActivationPanel.ExchangeBoxItem(box, box_dsc, hand_count, bhand)
	local player = GetClientPlayer()
	if not player or not box or not box_dsc then
		return
	end
	
	local box_type = box_dsc:GetObjectType()
	local _, bbox, xbox = box_dsc:GetObjectData()
	
	if box_type ~= UI_OBJECT_ITEM or not bbox or bbox < INVENTORY_INDEX.PACKAGE or bbox > INVENTORY_INDEX.PACKAGE4 then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tActivation.MATERIAL_JUST_FOR_DIAMON)
		return
	end
	
	local item = GetPlayerItem(player, bbox, xbox)
	if not item then
		return
	end
	
	local name = box:GetName()
	local count = 1
	if item.bCanStack then
		count = item.nStackNum
	end
	
	if name == "Box_FE4" then
		if item.nGenre ~= ITEM_GENRE.COLOR_DIAMOND then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tActivation.MATERIAL_JUST_FOR_COLOR_DIAMON)
			return
		end
	else
		if item.nGenre ~= ITEM_GENRE.DIAMOND then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tActivation.MATERIAL_JUST_FOR_DIAMON)
			return
		end
		
		if count > 1 then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tActivation.MATERIAL_ONLY)
			return
		elseif hand_count and hand_count ~= count then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFECommon.DIAMON_UNPACK)
			return
		end
	end
	
	if not box:IsEmpty() then
		RemoveUILockItem("FEActivation" .. name)
	end
	box.szName = item.name
	box.dwBox = bbox
	box.dwX = xbox
	box.nCount = hand_count
	box.nLevel = item.nDetail
	UpdataItemBoxObject(box, bbox, xbox, item)
	
	if bhand then
		Hand_Clear()
	else
		if IsObjectItem(box_type) then
			PlayItemSound(box_dsc:GetObjectData(), true)
		else
			PlaySound(SOUND.UI_SOUND, g_sound.TakeUpSkill)
		end
	end

	AddUILockItem("FEActivation" .. name, bbox, xbox)
end

function FEActivationPanel.GetDiamondTipString(mask, index)
	return FormatString(g_tStrings.tActivation.DIAMON_TIP, MOUNT_TYPE[mask][index], MOUNT_FONT[mask][index])
end

function FEActivationPanel.OutputWeaponColorDiamondTip(box)
	local x, y = box:GetAbsPos()
	local w, h = box:GetSize()
	local szText = ""
	local szTip = ""
	
	if not box.dwTabType and not box.dwIndex then
		szText = g_tStrings.tActivation.WEAPON_NONE_TIP
		szTip = "<text>text=" .. EncodeComponentsString(szText) .. " font=18 </text>"
	else
		szTip = GetItemInfoTip(0, box.dwTabType, box.dwIndex)
	end
	
	OutputTip(szTip, 355, {x, y ,w, h})
end

function FEActivationPanel.OutputFEImageTip(image)
	local x, y = image:GetAbsPos()
	local w, h = image:GetSize()
	local szTip = ""
	
	local counts, levels = image.counts, image.levels
	local name, font = GetDiamondFormatString(image.type)
	
	szTip = g_tStrings.tActivation.TOTAL_DIAMOND1
	szTip = szTip .. "<text>text=" .. EncodeComponentsString(name) .. " font=" .. font .. " </text>"
	
	local szText = FormatString(g_tStrings.tActivation.TOTAL_DIAMOND2, counts, levels)
	szTip = szTip .. szText
	
	OutputTip(szTip, 355, {x, y ,w, h})
end

function FEActivationPanel.OutputColorSlotTip(box)
	local x, y = box:GetAbsPos()
	local w, h = box:GetSize()
	local szText = ""
	local szTip = ""
	local player = GetClientPlayer()
	local item = GetPlayerItem(player, FEActivationPanel.dwBox, FEActivationPanel.dwX)
	
	local nEnchantID = item.GetMountFEAEnchantID()
	if not nEnchantID then
		return
	end
	
	if nEnchantID == 0 then
		szTip = g_tStrings.tActivation.COLOR_SLOT_TIP_NONE
	else
		local dwTabType, dwIndex = GetColorDiamondInfoFromEnchantID(nEnchantID)
		local itemInfo = GetItemInfo(dwTabType, dwIndex)
		if not itemInfo then
			return
		end
		
		szText = FormatString(g_tStrings.tActivation.DIAMON_MOUNT_ALREADY, Table_GetItemName(itemInfo.nUiId))
		szTip = szTip .. "<text>text=" .. EncodeComponentsString(szText) .. 
			" font=60 " .. GetItemFontColorByQuality(itemInfo.nQuality, true) .. " </text>"
	end
	
	OutputTip(szTip, 355, {x, y ,w, h})
end

function FEActivationPanel.OutputSlotAttributeTip(box)
	local x, y = box:GetAbsPos()
	local w, h = box:GetSize()
	local szText = ""
	local szTip = ""
	local player = GetClientPlayer()
	local item = GetPlayerItem(player, FEActivationPanel.dwBox, FEActivationPanel.dwX)
	local szName = box:GetName()
	local nSlot = tonumber(string.sub(szName, 7, -1), 10)
	local equipAttrib = item.GetSlotAttrib(nSlot - 1, 0)
	
	szTip = g_tStrings.tActivation.DIAMON_NOT_MOUNT1
	szText = FEActivationPanel.GetDiamondTipString(equipAttrib.nMask, 1)	
	szTip = szTip .. szText .. g_tStrings.tActivation.DIAMON_NOT_MOUNT2
	szText = FEActivationPanel.GetDiamondTipString(equipAttrib.nMask, 2)	
	szTip = szTip .. szText .. g_tStrings.tActivation.DIAMON_NOT_MOUNT3
	
	if FEActivationPanel.active[szName] then
		local nEnchantID = item.GetMountDiamondEnchantID(nSlot - 1)
		local nType, nIndex = GetDiamondInfoFromEnchantID(nEnchantID)
		local itemDiamonInfo = GetItemInfo(nType, nIndex)
		szText = FormatString(g_tStrings.tActivation.DIAMON_MOUNT_ALREADY, Table_GetItemName(itemDiamonInfo.nUiId))
		szTip = szTip .. "<text>text=\"\n\" </text>" .. "<text>text=" .. EncodeComponentsString(szText) .. 
			" font=60 " .. GetItemFontColorByQuality(itemDiamonInfo.nQuality, true) .. " </text>"
	end

	for i = 1, DIAMOND_MAX_LEVEL do 
		szTip = szTip .. "<text>text=\"\n\" </text>"
		local equipAttrib = item.GetSlotAttrib(nSlot - 1, i)
		szText = FormatString(Table_GetMagicAttributeInfo(equipAttrib.nID, true), equipAttrib.Param0, equipAttrib.Param1)
		szText = GetPureText(szText)
		szText = FormatString(g_tStrings.tActivation.EFFECT_PREVIEW, Conversion2ChineseNumber(i), szText)
		szTip = szTip .. szText
	end

	OutputTip(szTip, 355, {x, y ,w, h})
end

function FEActivationPanel.SetLayout(frame)
	local handle = frame:Lookup("", "Handle_FE")
	local box = frame:Lookup("", ""):Lookup("Box_FE")
	local box1 = handle:Lookup("Box_FE1")
	local box2 = handle:Lookup("Box_FE2")
	local box3 = handle:Lookup("Box_FE3")
	local box4 = handle:Lookup("Box_FE4")
	local image1 = handle:Lookup("Image_FE1")
	local image2 = handle:Lookup("Image_FE2")
	local image3 = handle:Lookup("Image_FE3")
	local image4 = handle:Lookup("Image_FE4")
	local imagex1 = handle:Lookup("Image_Old1")
	local imagex2 = handle:Lookup("Image_Old2")
	local imagex3 = handle:Lookup("Image_Old3")
	local imagex4 = handle:Lookup("Image_Old4")
	local text1 = handle:Lookup("Text_Mes1")
	local text2 = handle:Lookup("Text_Mes2")
	local text3 = handle:Lookup("Text_Mes3")
	local text4 = handle:Lookup("Text_Mes4")
	local ani1 = handle:Lookup("Animate_XQ1")
	local ani2 = handle:Lookup("Animate_XQ2")
	local ani3 = handle:Lookup("Animate_XQ3")
	local ani4 = handle:Lookup("Animate_XQ4")
	local btn1 = frame:Lookup("Btn_Setting")
	local btn2 = frame:Lookup("Btn_Setting1")
	local btn3 = frame:Lookup("Btn_Setting2")
	local btn4 = frame:Lookup("Btn_Setting3")
	
	box.dwBox = FEActivationPanel.dwBox
	box.dwX = FEActivationPanel.dwX
	
	local slot_count = FEActivationPanel.nSlots
	
	box1:Hide(); box2:Hide(); box3:Hide(); box4:Hide()
	image1:Hide(); image2:Hide(); image3:Hide(); image4:Hide()
	imagex1:Hide(); imagex2:Hide(); imagex3:Hide(); imagex4:Hide()
	text1:SetText(""); text2:SetText(""); text3:SetText(""); text4:SetText("")
	btn1:Hide(); btn2:Hide(); btn3:Hide(); btn4:Hide()
	ani1:Hide(); ani2:Hide(); ani3:Hide(); ani4:Hide()
	
	if slot_count == 3 then
		box1:Show(); box2:Show(); box3:Show()
		image1:Show(); image2:Show(); image3:Show()
		btn1:Show(); btn2:Show(); btn3:Show()
		
		box1:SetRelPos(ADJUST_POS[3][1].x, ADJUST_POS[3][1].y)
		image1:SetRelPos(ADJUST_POS[3][1].x - IMAGE_EAGE, ADJUST_POS[3][1].y - IMAGE_EAGE)
		imagex1:SetRelPos(ADJUST_POS[3][1].x, ADJUST_POS[3][1].y)
		text1:SetRelPos(ADJUST_TEXT_POS[3][1].x, ADJUST_TEXT_POS[3][1].y)
		btn1:SetRelPos(ADJUST_BUTTON_POS[3][1].x, ADJUST_BUTTON_POS[3][1].y)
		ani1:SetRelPos(ADJUST_ANIMATE_POS[3][1].x, ADJUST_ANIMATE_POS[3][1].y)
		
		box2:SetRelPos(ADJUST_POS[3][2].x, ADJUST_POS[3][2].y)
		image2:SetRelPos(ADJUST_POS[3][2].x - IMAGE_EAGE, ADJUST_POS[3][2].y - IMAGE_EAGE)
		imagex2:SetRelPos(ADJUST_POS[3][2].x, ADJUST_POS[3][2].y)
		text2:SetRelPos(ADJUST_TEXT_POS[3][2].x, ADJUST_TEXT_POS[3][2].y)
		btn2:SetRelPos(ADJUST_BUTTON_POS[3][2].x, ADJUST_BUTTON_POS[3][2].y)
		ani2:SetRelPos(ADJUST_ANIMATE_POS[3][2].x, ADJUST_ANIMATE_POS[3][2].y)
		
		box3:SetRelPos(ADJUST_POS[3][3].x, ADJUST_POS[3][3].y)
		image3:SetRelPos(ADJUST_POS[3][3].x - IMAGE_EAGE, ADJUST_POS[3][3].y - IMAGE_EAGE)
		imagex3:SetRelPos(ADJUST_POS[3][3].x, ADJUST_POS[3][3].y)
		text3:SetRelPos(ADJUST_TEXT_POS[3][3].x, ADJUST_TEXT_POS[3][3].y)
		btn3:SetRelPos(ADJUST_BUTTON_POS[3][3].x, ADJUST_BUTTON_POS[3][3].y)
		ani3:SetRelPos(ADJUST_ANIMATE_POS[3][3].x, ADJUST_ANIMATE_POS[3][3].y)
		
		if FEActivationPanel.bMount then
			box4:Show(); image4:Show(); btn4:Show()
			box4:SetRelPos(ADJUST_POS[3][4].x, ADJUST_POS[3][4].y)
			image4:SetRelPos(ADJUST_POS[3][4].x - IMAGE_EAGE, ADJUST_POS[3][4].y - IMAGE_EAGE)
			imagex4:SetRelPos(ADJUST_POS[3][4].x, ADJUST_POS[3][4].y)
			text4:SetRelPos(ADJUST_TEXT_POS[3][4].x, ADJUST_TEXT_POS[3][4].y)
			btn4:SetRelPos(ADJUST_BUTTON_POS[3][4].x, ADJUST_BUTTON_POS[3][4].y)
			ani4:SetRelPos(ADJUST_ANIMATE_POS[3][4].x, ADJUST_ANIMATE_POS[3][4].y)
		end
	elseif slot_count == 2 then
		box1:Show(); box2:Show()
		image1:Show(); image2:Show()
		btn1:Show(); btn2:Show()
		
		box1:SetRelPos(ADJUST_POS[2][1].x, ADJUST_POS[2][1].y)
		image1:SetRelPos(ADJUST_POS[2][1].x - IMAGE_EAGE, ADJUST_POS[2][1].y - IMAGE_EAGE)
		imagex1:SetRelPos(ADJUST_POS[2][1].x, ADJUST_POS[2][1].y)
		text1:SetRelPos(ADJUST_TEXT_POS[2][1].x, ADJUST_TEXT_POS[2][1].y)
		btn1:SetRelPos(ADJUST_BUTTON_POS[2][1].x, ADJUST_BUTTON_POS[2][1].y)
		ani1:SetRelPos(ADJUST_ANIMATE_POS[2][1].x, ADJUST_ANIMATE_POS[2][1].y)
		
		box2:SetRelPos(ADJUST_POS[2][2].x, ADJUST_POS[2][2].y)
		image2:SetRelPos(ADJUST_POS[2][2].x - IMAGE_EAGE, ADJUST_POS[2][2].y - IMAGE_EAGE)
		imagex2:SetRelPos(ADJUST_POS[2][2].x, ADJUST_POS[2][2].y)
		text2:SetRelPos(ADJUST_TEXT_POS[2][2].x, ADJUST_TEXT_POS[2][2].y)
		btn2:SetRelPos(ADJUST_BUTTON_POS[2][2].x, ADJUST_BUTTON_POS[2][2].y)
		ani2:SetRelPos(ADJUST_ANIMATE_POS[2][2].x, ADJUST_ANIMATE_POS[2][2].y)
		
		box3:SetRelPos(ADJUST_POS[2][3].x, ADJUST_POS[2][3].y)
		image3:SetRelPos(ADJUST_POS[2][3].x - IMAGE_EAGE, ADJUST_POS[2][3].y - IMAGE_EAGE)
		imagex3:SetRelPos(ADJUST_POS[2][3].x, ADJUST_POS[2][3].y)
		
		if FEActivationPanel.bMount then
			box4:Show(); image4:Show(); btn4:Show()
			box4:SetRelPos(ADJUST_POS[2][4].x, ADJUST_POS[2][4].y)
			image4:SetRelPos(ADJUST_POS[2][4].x - IMAGE_EAGE, ADJUST_POS[2][4].y - IMAGE_EAGE)
			imagex4:SetRelPos(ADJUST_POS[2][4].x, ADJUST_POS[2][4].y)
			text4:SetRelPos(ADJUST_TEXT_POS[2][4].x, ADJUST_TEXT_POS[2][4].y)
			btn4:SetRelPos(ADJUST_BUTTON_POS[2][4].x, ADJUST_BUTTON_POS[2][4].y)
			ani4:SetRelPos(ADJUST_ANIMATE_POS[2][4].x, ADJUST_ANIMATE_POS[2][4].y)
		end
	elseif slot_count == 1 then
		box1:Show()
		image1:Show()
		btn1:Show()
		
		box1:SetRelPos(ADJUST_POS[1][1].x, ADJUST_POS[1][1].y)
		image1:SetRelPos(ADJUST_POS[1][1].x - IMAGE_EAGE, ADJUST_POS[1][1].y - IMAGE_EAGE)
		imagex1:SetRelPos(ADJUST_POS[1][1].x, ADJUST_POS[1][1].y)
		text1:SetRelPos(ADJUST_TEXT_POS[1][1].x, ADJUST_TEXT_POS[1][1].y)
		btn1:SetRelPos(ADJUST_BUTTON_POS[1][1].x, ADJUST_BUTTON_POS[1][1].y)
		ani1:SetRelPos(ADJUST_ANIMATE_POS[1][1].x, ADJUST_ANIMATE_POS[1][1].y)
		
		box2:SetRelPos(ADJUST_POS[1][2].x, ADJUST_POS[1][2].y)
		image2:SetRelPos(ADJUST_POS[1][2].x - IMAGE_EAGE, ADJUST_POS[1][2].y - IMAGE_EAGE)
		imagex2:SetRelPos(ADJUST_POS[1][2].x, ADJUST_POS[1][2].y)
		
		box3:SetRelPos(ADJUST_POS[1][3].x, ADJUST_POS[1][3].y)
		image3:SetRelPos(ADJUST_POS[1][3].x - IMAGE_EAGE, ADJUST_POS[1][3].y - IMAGE_EAGE)
		imagex3:SetRelPos(ADJUST_POS[1][3].x, ADJUST_POS[1][3].y)
		
		if FEActivationPanel.bMount then
			box4:Show(); image4:Show(); btn4:Show()
			box4:SetRelPos(ADJUST_POS[1][4].x, ADJUST_POS[1][4].y)
			image4:SetRelPos(ADJUST_POS[1][4].x - IMAGE_EAGE, ADJUST_POS[1][4].y - IMAGE_EAGE)
			imagex4:SetRelPos(ADJUST_POS[1][4].x, ADJUST_POS[1][4].y)
			text4:SetRelPos(ADJUST_TEXT_POS[1][4].x, ADJUST_TEXT_POS[1][4].y)
			btn4:SetRelPos(ADJUST_BUTTON_POS[1][4].x, ADJUST_BUTTON_POS[1][4].y)
			ani4:SetRelPos(ADJUST_ANIMATE_POS[1][4].x, ADJUST_ANIMATE_POS[1][4].y)
		end
	elseif FEActivationPanel.bMount then
		box4:Show(); image4:Show(); btn4:Show()
		box4:SetRelPos(ADJUST_MOUNT_POS["box"].x, ADJUST_MOUNT_POS["box"].y)
		image4:SetRelPos(ADJUST_MOUNT_POS["image"].x, ADJUST_MOUNT_POS["image"].y)
		imagex4:SetRelPos(ADJUST_MOUNT_POS["image"].x, ADJUST_MOUNT_POS["image"].y)
		text4:SetRelPos(ADJUST_MOUNT_POS["text"].x, ADJUST_MOUNT_POS["text"].y)
		btn4:SetRelPos(ADJUST_MOUNT_POS["button"].x, ADJUST_MOUNT_POS["button"].y)
		ani4:SetRelPos(ADJUST_MOUNT_POS["animation"].x, ADJUST_MOUNT_POS["animation"].y)
	end
	handle:FormatAllItemPos()
end

function FEActivationPanel.Reset()
	for i = 1, SLOT_COUNT do
		FEActivationPanel.active["Box_FE" .. i] = false
	end
end

function FEActivationPanel.Update(frame, force)
	if not frame then
		frame = Station.Lookup("Normal/FEActivationPanel")
	end
	local player = GetClientPlayer()
	if not player then
		return
	end
	
	local handle = frame:Lookup("", "")
	local box = handle:Lookup("Box_FE")
	local box_weapon = handle:Lookup("Box_Weapon")
	local handle_item = frame:Lookup("", "Handle_FE")
	local boxs = {}
	boxs[1] = handle_item:Lookup("Box_FE1")
	boxs[2] = handle_item:Lookup("Box_FE2")
	boxs[3] = handle_item:Lookup("Box_FE3")
	boxs[4] = handle_item:Lookup("Box_FE4")
	local btns = {}
	btns[1] = frame:Lookup("Btn_Setting")
	btns[2] = frame:Lookup("Btn_Setting1")
	btns[3] = frame:Lookup("Btn_Setting2")
	btns[4] = frame:Lookup("Btn_Setting3")
	local texts = {}
	texts[1] = handle_item:Lookup("Text_Mes1")
	texts[2] = handle_item:Lookup("Text_Mes2")
	texts[3] = handle_item:Lookup("Text_Mes3")
	texts[4] = handle_item:Lookup("Text_Mes4")
	local anis = {}
	anis[1] = handle_item:Lookup("Animate_XQ1")
	anis[2] = handle_item:Lookup("Animate_XQ2")
	anis[3] = handle_item:Lookup("Animate_XQ3")
	anis[4] = handle_item:Lookup("Animate_XQ4")
	
	FEActivationPanel.Reset()
	
	local count = FEActivationPanel.nSlots
	local bbox, xbox = FEActivationPanel.dwBox, FEActivationPanel.dwX
	
	local item = GetPlayerItem(player, bbox, xbox)
	if not item or item.nGenre ~= ITEM_GENRE.EQUIPMENT then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tActivation.JUST_FOR_EQUIP)
		CloseFEActivationPanel()
		return
	end
	
	UpdataItemBoxObject(box, bbox, xbox, item)
	FEActivationPanel.UpdateSlotActiveState(item)
	
	for i = 1, SLOT_COUNT do
		btns[i]:Enable(false)
	end
	btns[4]:Enable(false)
	
	local slot_count = item.GetSlotCount()
	local diamonds = { [0] = { nCount = 0, nIntensity = 0 }, 
		{ nCount = 0, nIntensity = 0 }, { nCount = 0, nIntensity = 0 }, 
		{ nCount = 0, nIntensity = 0 }, { nCount = 0, nIntensity = 0 } }
	
	for i = 1, slot_count do
		local slot_level = 0
		local box_slot = handle_item:Lookup("Box_FE" .. i)
		local active = false
		local image = handle_item:Lookup("Image_Old" .. i)
		image:Hide()
		texts[i]:SetText("")
		if force and FEActivationPanel.active["Box_FE" .. i] then
			anis[i]:Show()
			anis[i]:SetAnimate("ui/Image/UICommon/FEPanel3.UITex", 1, 0)
		end
		if not boxs[i]:IsEmpty() then
			local diamond = GetPlayerItem(player, boxs[i].dwBox, boxs[i].dwX)
			if not diamond or diamond.nGenre ~= ITEM_GENRE.DIAMOND then
				CloseFEActivationPanel()
				return
			end
			diamonds[diamond.nSub].nCount = diamonds[diamond.nSub].nCount + 1
			diamonds[diamond.nSub].nIntensity = diamonds[diamond.nSub].nIntensity + diamond.nDetail
			slot_level = diamond.nDetail
			
			local nEnchantID = item.GetMountDiamondEnchantID(i - 1)
			local itemDiamonInfo = false
			if nEnchantID > 0 then
				local nType, nIndex = GetDiamondInfoFromEnchantID(nEnchantID)
				if nType and nIndex then
					itemDiamonInfo = GetItemInfo(nType, nIndex)
				end
			end
			if itemDiamonInfo then
				diamonds[itemDiamonInfo.nSub].nCount = diamonds[itemDiamonInfo.nSub].nCount - 1
				diamonds[itemDiamonInfo.nSub].nIntensity = diamonds[itemDiamonInfo.nSub].nIntensity - itemDiamonInfo.nDetail
			end
			btns[i]:Enable(true)
			active = GetSlotActiveFlagAdded(bbox, xbox, i - 1, boxs[i].dwBox, boxs[i].dwX)
		else
			local nEnchantID = item.GetMountDiamondEnchantID(i - 1)
			local itemDiamonInfo = false
			if nEnchantID > 0 then
				local nType, nIndex = GetDiamondInfoFromEnchantID(nEnchantID)
				if nType and nIndex then
					itemDiamonInfo = GetItemInfo(nType, nIndex)
				end
			end
			image:Show()
			if itemDiamonInfo then
				slot_level = itemDiamonInfo.nDetail
				image:FromIconID(Table_GetItemIconID(itemDiamonInfo.nUiId))
			end
		end
		
		local equipAttrib = item.GetSlotAttrib(i - 1, slot_level)
		equipAttrib = equipAttrib or {}
		local actived = item.IsDiamondSlotAttributeActive(i - 1)
		local bUseAttribute = true
		if not active and not actived then
			equipAttrib.Param0 = "？"
			equipAttrib.Param1 = "？"
			bUseAttribute = false
		else
			if not boxs[i]:IsEmpty() and not active then
				equipAttrib.Param0 = "？"
				equipAttrib.Param1 = "？"
				bUseAttribute = false
			end
		end
		
		image = handle_item:Lookup("Image_FE" .. i)
		image:SetFrame(IMAGE_FRAME[equipAttrib.nMask])
		
		local szText = nil
		if not bUseAttribute then
			szText = g_tStrings.tDeactives[equipAttrib.nID]
		end
		
		if not szText then
			szText = FormatString(Table_GetMagicAttributeInfo(equipAttrib.nID, true), equipAttrib.Param0, equipAttrib.Param1)
			szText = GetPureText(szText)
		end
		
		if active then
			texts[i]:SetFontScheme(105)
			--szText = FormatString(g_tStrings.tActivation.ACTIVE_SLOT, szText, 105)
		else
			if actived and boxs[i]:IsEmpty() then
				texts[i]:SetFontScheme(105)
				--szText = FormatString(g_tStrings.tActivation.ACTIVE_SLOT, szText, 105)
			else
				texts[i]:SetFontScheme(161)
				--szText = FormatString(g_tStrings.tActivation.ACTIVE_SLOT, szText, 161)
			end
		end
		texts[i]:SetText(szText)
	end
	
	FEActivationPanel.nEnchantID = item.GetMountFEAEnchantID()
	if not boxs[4]:IsEmpty() then
		local diamond = GetPlayerItem(player, boxs[4].dwBox, boxs[4].dwX)
		if not diamond or diamond.nGenre ~= ITEM_GENRE.COLOR_DIAMOND then
			CloseFEActivationPanel()
			return
		end
		
		local image = handle_item:Lookup("Image_Old4")
		image:Hide()
		
		local itemInfo = GetItemInfo(diamond.dwTabType, diamond.dwIndex)
		if not itemInfo then
			return
		end
		
		local szText = Table_GetItemName(itemInfo.nUiId)
		texts[4]:SetText(szText)
		texts[4]:SetFontScheme(105)
		btns[4]:Enable(true)
	elseif FEActivationPanel.nEnchantID then
		if FEActivationPanel.nEnchantID == 0 then
			local image = handle_item:Lookup("Image_Old4")
			image:Hide()
			texts[4]:SetText("")
		elseif FEActivationPanel.nEnchantID > 0 then
			local image = handle_item:Lookup("Image_Old4")
			image:Show()
			texts[4]:SetText("")
			anis[4]:Show()
			anis[4]:SetAnimate("ui/Image/UICommon/FEPanel3.UITex", 1, 0)

			local dwTabType, dwIndex = GetColorDiamondInfoFromEnchantID(FEActivationPanel.nEnchantID)
			local itemInfo = GetItemInfo(dwTabType, dwIndex)
			if not itemInfo then
				return
			end

			local szText = Table_GetItemName(itemInfo.nUiId)
			texts[4]:SetText(szText)
			texts[4]:SetFontScheme(161)
			image:FromIconID(Table_GetItemIconID(itemInfo.nUiId))
		end
	end
	
	FEActivationPanel.UpdateWeaponActiveState(player, box_weapon, handle)
	FEActivationPanel.UpdateFECount(handle, diamonds)
end

function FEActivationPanel.UpdateWeaponActiveState(player, box_weapon, handle)
	local weapon = nil
	local nActive = 0
	local dwBox = 0
	local dwX = 0
	
	if player.bBigSwordSelected then
		weapon = player.GetItem(INVENTORY_INDEX.EQUIP, EQUIPMENT_INVENTORY.BIG_SWORD)
		dwBox = INVENTORY_INDEX.EQUIP
		dwX = EQUIPMENT_INVENTORY.BIG_SWORD
	else
		weapon = player.GetItem(INVENTORY_INDEX.EQUIP, EQUIPMENT_INVENTORY.MELEE_WEAPON)
		dwBox = INVENTORY_INDEX.EQUIP
		dwX = EQUIPMENT_INVENTORY.MELEE_WEAPON
	end
	
	box_weapon.dwTabType = nil
	box_weapon.dwIndex = nil
	
	if weapon then
		for i = 1, FEA_COUNT, 1 do
			local bActive = GetFEAActiveFlag(player.dwID, dwBox, dwX, i - 1)
			if bActive then
				nActive = nActive + 1
			end
		end
		local iamgeWeapon = handle:Lookup("Image_Weapon")
		iamgeWeapon:SetFrame(IMAGE_ACTIVE[nActive])
		iamgeWeapon:Show()

		box_weapon.dwBox = dwBox
		box_weapon.dwX = dwX
		--UpdataItemBoxObject(box_weapon, INVENTORY_INDEX.EQUIP, EQUIPMENT_INVENTORY.MELEE_WEAPON, weapon)
		
		local nEnchantID = weapon.GetMountFEAEnchantID()
		if nEnchantID > 0 then
			local dwTabType, dwIndex = GetColorDiamondInfoFromEnchantID(nEnchantID)
			local itemInfo = GetItemInfo(dwTabType, dwIndex)
			if not itemInfo then
				return
			end
			
			iamgeWeapon:FromIconID(Table_GetItemIconID(itemInfo.nUiId))
			box_weapon.dwTabType = dwTabType
			box_weapon.dwIndex = dwIndex
		end
	end
end

function FEActivationPanel.UpdateFECount(handle, diamonds)
	local textJin = handle:Lookup("Text_Jin")
	local textMu = handle:Lookup("Text_Mu")
	local textShui = handle:Lookup("Text_Shui")
	local textHuo = handle:Lookup("Text_Huo")
	local textTu = handle:Lookup("Text_Tu")
	local textJinLve = handle:Lookup("Text_JinLevel")
	local textMuLve = handle:Lookup("Text_MuLevel")
	local textShuiLve = handle:Lookup("Text_ShuiLevel")
	local textHuoLve = handle:Lookup("Text_HuoLevel")
	local textTuLve = handle:Lookup("Text_TuLevel")
	local imageJin = handle:Lookup("Image_Jin")
	local imageMu = handle:Lookup("Image_Mu")
	local imageShui = handle:Lookup("Image_Shui")
	local imageHuo = handle:Lookup("Image_Huo")
	local imageTu = handle:Lookup("Image_Tu")
	
	local player = GetClientPlayer()
	if not player then
		return
	end
	
	local tDiamonType = GetAllEquipDiamondInfo()
	local bEquip = FEActivationPanel.dwBox == INVENTORY_INDEX.EQUIP
	
	if FEActivationPanel.dwX == EQUIPMENT_INVENTORY.BIG_SWORD and not player.bBigSwordSelected then
		bEquip = false
	end
	
	if FEActivationPanel.dwX == EQUIPMENT_INVENTORY.MELEE_WEAPON and player.bBigSwordSelected then
		bEquip = false
	end
	
	if bEquip then	
		for i = 0, 4, 1 do
			tDiamonType[i].nCount = tDiamonType[i].nCount + diamonds[i].nCount
			tDiamonType[i].nIntensity = tDiamonType[i].nIntensity + diamonds[i].nIntensity
		end
	end
	textJin:SetText(tDiamonType[0].nCount)
	textMu:SetText(tDiamonType[1].nCount)
	textShui:SetText(tDiamonType[2].nCount)
	textHuo:SetText(tDiamonType[3].nCount)
	textTu:SetText(tDiamonType[4].nCount)
	textJinLve:SetText(tDiamonType[0].nIntensity)
	textMuLve:SetText(tDiamonType[1].nIntensity)
	textShuiLve:SetText(tDiamonType[2].nIntensity)
	textHuoLve:SetText(tDiamonType[3].nIntensity)
	textTuLve:SetText(tDiamonType[4].nIntensity)
	
	imageJin.counts = tDiamonType[0].nCount
	imageMu.counts = tDiamonType[1].nCount
	imageShui.counts = tDiamonType[2].nCount
	imageHuo.counts = tDiamonType[3].nCount
	imageTu.counts = tDiamonType[4].nCount
	
	imageJin.levels = tDiamonType[0].nIntensity
	imageMu.levels = tDiamonType[1].nIntensity
	imageShui.levels = tDiamonType[2].nIntensity
	imageHuo.levels = tDiamonType[3].nIntensity
	imageTu.levels = tDiamonType[4].nIntensity
	
	imageJin.type = 0
	imageMu.type = 1
	imageShui.type = 2
	imageHuo.type = 3
	imageTu.type = 4
end

function FEActivationPanel.UpdateSlotActiveState(item)
	local count = FEActivationPanel.nSlots
	
	for i = 1, count do
		local nEnchantID = item.GetMountDiamondEnchantID(i - 1)
		local itemDiamonInfo = false
		if nEnchantID > 0 then	
			local nType, nIndex = GetDiamondInfoFromEnchantID(nEnchantID)
			if nType and nIndex then
				itemDiamonInfo = GetItemInfo(nType, nIndex)
			end
		end
		if itemDiamonInfo then
			FEActivationPanel.active["Box_FE" .. i] = true
		else
			FEActivationPanel.active["Box_FE" .. i] = false
		end
	end
	
	local nEnchantID = item.GetMountFEAEnchantID()
	FEActivationPanel.nEnchantID = nEnchantID
end

function FEActivationPanel.EquipmentHit(item)
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

function OpenFEActivationPanel(box, bDisableSound)
	if IsOptionOrOptionChildPanelOpened() then
		return
	end
	
	local player = GetClientPlayer()
	if not player then
		return
	end
	
	CloseFEProducePanel(true)
	CloseFEActivationPanel(true)
	
	local obj_type = box:GetObjectType()
	local _, bbox, xbox = box:GetObjectData()
	
	if obj_type ~= UI_OBJECT_ITEM then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tActivation.JUST_FOR_EQUIP)
		return
	end
	
	local item = GetPlayerItem(player, bbox, xbox)
	if not item then
		return
	end
	
	if item.nGenre ~= ITEM_GENRE.EQUIPMENT then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tActivation.JUST_FOR_EQUIP)
		return
	end
	
	if not FEActivationPanel.EquipmentHit(item) then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tActivation.JUST_FOR_PROPERTY_EQUIP)
		return
	end
	
	local item_info = GetItemInfo(item.dwTabType, item.dwIndex)
	if not item_info then
		return
	end
	
	local slot_count = item.GetSlotCount()
	local can_mount = item.CanMountColorDiamond()
	if slot_count == 0 and not can_mount then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tActivation.NO_SLOT)
		return
	end
	
	if CheckHaveLocked(SAFE_LOCK_EFFECT_TYPE.OPERATE_DIAMOND, "OPERATE_DIAMOND") then
		return
	end

	FEActivationPanel.dwBox = bbox
	FEActivationPanel.dwX = xbox
	FEActivationPanel.dwTabType = item.dwTabType
	FEActivationPanel.dwIndex = item.dwIndex
	FEActivationPanel.nSlots = slot_count
	FEActivationPanel.bMount = can_mount
	
	Wnd.OpenWindow("FEActivationPanel")
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end

	AddUILockItem("FEActivation", bbox, xbox)
end

function CloseFEActivationPanel(bDisableSound)
	RemoveUILockItem("FEActivation")
	RemoveUILockItem("FEActivationBox_FE1")
	RemoveUILockItem("FEActivationBox_FE2")
	RemoveUILockItem("FEActivationBox_FE3")
	RemoveUILockItem("FEActivationBox_FE4")

	if IsFEActivationPanelOpened() then
		Wnd.CloseWindow("FEActivationPanel")
	end

	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND, g_sound.CloseFrame)
	end
end

function IsFEActivationPanelOpened()
	local frame = Station.Lookup("Normal/FEActivationPanel")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end

function MountItemOnBag(box, count)
	local frame = Station.Lookup("Normal/FEActivationPanel")
	if not frame then
		return
	end
end

function AddFEActivationOnItemRButton(box, count)
	local frame = Station.Lookup("Normal/FEActivationPanel")
	if not frame then
		return
	end
	
	local player = GetClientPlayer()
	if not player then
		return
	end
	
	local item = GetPlayerItem(player, FEActivationPanel.dwBox, FEActivationPanel.dwX)
	if not item then
		return
	end
	
	local box_type = box:GetObjectType()
	local _, bbox, xbox = box:GetObjectData()
	
	local item_box = GetPlayerItem(player, bbox, xbox)
	local handle = frame:Lookup("", "Handle_FE")
	if item_box and item_box.nGenre == ITEM_GENRE.COLOR_DIAMOND then
		local boxItem = handle:Lookup("Box_FE4")
		
		if boxItem:IsVisible() then
			FEActivationPanel.ExchangeBoxItem(boxItem, box, count)
			FEActivationPanel.Update(frame)
		end
		
		return
	end

	local bFull = true
	local bMount = false
	for i = 1, SLOT_COUNT, 1 do
		local szName = "Box_FE" .. i
		local boxItem = handle:Lookup(szName)
		local nEnchantID = item.GetMountDiamondEnchantID(i - 1)
		local itemDiamonInfo = false
		if nEnchantID > 0 then
			local nType, nIndex = GetDiamondInfoFromEnchantID(nEnchantID)
			if nType and nIndex then
				itemDiamonInfo = GetItemInfo(nType, nIndex)
			end
		end
		
		if boxItem:IsEmpty() and boxItem:IsVisible() then
			if not itemDiamonInfo then	
				FEActivationPanel.ExchangeBoxItem(boxItem, box, count)
				FEActivationPanel.Update(frame)
				bFull = false
				bMount = false
				break
			else
				bFull = false
				bMount = true
			end
		end
	end
	
	if bFull then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tActivation.NOT_ENOUGH_SLOT)
		return
	elseif bMount then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tActivation.NO_SLOT_MATCH)
		return
	end
end