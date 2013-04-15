WeaponBag = {}
local INI_FILE_PATH = "ui/config/default/WeaponBag.ini"

local lc_hFrame
local lc_hBoxList
--local item = GetPlayerItem(player, nGWBoxIndex, dwX)
--  local dwSize = player.GetBoxSize(nGWBoxIndex)
function WeaponBag.OnFrameCreate()
	this:RegisterEvent("BULLETBACKUP_ITEM_UPDATE")
	this:RegisterEvent("EQUIP_ITEM_UPDATE")
	
	WeaponBag.InitObject(this)
	WeaponBag.UpdateBoxList()
end

function WeaponBag.OnEvent(event)
	if event == "BULLETBACKUP_ITEM_UPDATE" or event == "EQUIP_ITEM_UPDATE" then
		if arg0 == INVENTORY_INDEX.BULLET_PACKAGE then
			WeaponBag.UpdateBoxList()
		end
	end
end

function WeaponBag.InitObject(frame)
	lc_hFrame = frame
	lc_hBoxList = frame:Lookup("", "Handle_Boxs")
end

function WeaponBag.UpdateBoxList()
	local player = GetClientPlayer()
	local dwBagSize = player.GetBoxSize(INVENTORY_INDEX.BULLET_PACKAGE)
	lc_hBoxList:Clear()
	
	for i=1, dwBagSize, 1 do
		local hItem = lc_hBoxList:AppendItemFromIni(INI_FILE_PATH, "Handle_Box")
		local box = hItem:Lookup("Box")
		box.dwBox = INVENTORY_INDEX.BULLET_PACKAGE
		box.dwX = i - 1
		box.nCount = 0
		
		local item = GetPlayerItem(player, INVENTORY_INDEX.BULLET_PACKAGE, i - 1)
		if item then
			UpdataItemBoxObject(box, INVENTORY_INDEX.BULLET_PACKAGE, i-1, item)
			box.nCount = item.nStackNum
		end
	end
	lc_hBoxList:FormatAllItemPos()
end

function WeaponBag.ItemToBag(box)
	if box:IsEmpty() then
		return
	end
	
	if not box:IsObjectEnable() then
		return
	end
	
	if IsBigBagFull() then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.GUILD_BANK_ERROR_BAG_IS_FULL)
		return
	end
	local dwSrcBox, dwSrcX = box.dwBox, box.dwX
	local dwDstBox, dwDstX = Bag_GetFreeBox()
	if dwDstBox and dwDstX then
		OnExchangeItem(dwSrcBox, dwSrcX, dwDstBox, dwDstX, box.nCount)
	end
end

--==========msg==============
function WeaponBag.OnItemLButtonDown()
	local szName = this:GetName()
	if szName == "Box" then
		this.bIgnoreClick = nil
		
		this:SetObjectStaring(false)
		this:SetObjectPressed(1)
	end
end


function WeaponBag.OnItemLButtonUp()
	local szName = this:GetName()
	if szName == "Box" then
		this:SetObjectPressed(0)
	end
end

function WeaponBag.OnItemLButtonDrag()
	local szName = this:GetName()
	if szName == "Box" then
		this:SetObjectPressed(0)
		if not this:IsObjectEnable() or not this.dwBox or not this.dwX then
			return
		end
	
		if UserSelect.DoSelectItem(this.dwBox, this.dwX) then
			return
		end
	
		if Hand_IsEmpty() and not this:IsEmpty() then
			if IsCursorInExclusiveMode() then
				OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.SRT_ERROR_CANCEL_CURSOR_STATE)
				PlayTipSound("010")
			else
				Hand_Pick(this)
			end
		end
	end
end

function WeaponBag.OnItemLButtonDragEnd()
	local szName = this:GetName()
	if szName == "Box" then
		this.bIgnoreClick = true
		
		if not this:IsObjectEnable() then
			if not Hand_IsEmpty() and not this:IsEmpty() then
				local box = Hand_Get()
				local dwType, _, dwBox, dwX = box:GetObject()
				local dwTType, _, dwTBox, dwTX = this:GetObject()
				if dwType == dwTType and dwBox == dwTBox and dwX == dwTX then
					Hand_Clear()
				end
			end
			return
		end
		
		if not Hand_IsEmpty() then
			WeaponBag.OnExchangeBoxAndHandBoxItem(this)
		end	
	end
end

function WeaponBag.OnItemLButtonClick()
	local szName = this:GetName()
	if szName == "Box" then
		if this.bIgnoreClick then
			this.bIgnoreClick = nil
			return
		end
		
		if not this:IsObjectEnable() then
			if not Hand_IsEmpty() and not this:IsEmpty() then
				local box = Hand_Get()
				local dwType, _, dwBox, dwX = box:GetObject()
				local dwTType, _, dwTBox, dwTX = this:GetObject()
				if dwType == dwTType and dwBox == dwTBox and dwX == dwTX then
					Hand_Clear()
				end
			end
			return
		end
		
		if UserSelect.DoSelectItem(this.dwBox, this.dwX) then
			return
		end
		
		if (IsShiftKeyDown() and not IsCursorInExclusiveMode())	or Cursor.GetCurrentIndex() == CURSOR.SPLIT then
			OnSplitBoxItem(this, function() return (not IsWeaponBagOpen()) end)
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
		else
			WeaponBag.OnExchangeBoxAndHandBoxItem(this)
		end	
	end
end

function WeaponBag.OnItemLButtonDBClick()
	WeaponBag.OnItemLButtonClick()
end

function WeaponBag.OnItemRButtonClick()
	local szName = this:GetName()
	if szName == "Box" then
		if this:IsEmpty() then
			return
		end
		
		if not this:IsObjectEnable() then
			return
		end

		local player = GetClientPlayer()
		local nUiId, dwBox, dwX = this:GetObjectData()

		if not this:IsEmpty() and dwBox and dwX then
			WeaponBag.ItemToBag(this)
			return
		end
	end
end

function WeaponBag.OnItemRButtonDown()
	local szName = this:GetName()
	if szName == "Box" then
		this:SetObjectPressed(1)
		this:SetObjectStaring(false)	
	end
end

function WeaponBag.OnItemRButtonUp()
	local szName = this:GetName()
	if szName == "Box" then
		this:SetObjectPressed(0)
	end
end

function WeaponBag.OnItemMouseEnter()
	local szName = this:GetName()
	if szName == "Box" then
		this:SetObjectMouseOver(1)
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
		if not this:IsEmpty() then
			local _, dwBox, dwX = this:GetObjectData()
			OutputItemTip(UI_OBJECT_ITEM, dwBox, dwX, nil, {x, y, w, h})
		end
	end
end

function WeaponBag.OnItemMouseLeave()
	local szName = this:GetName()
	if szName == "Box" then
		this:SetObjectMouseOver(0)
		HideTip()
	end
end

function WeaponBag.OnLButtonClick()
	local szName = this:GetName()
    if szName == "Btn_Close" then
    	CloseWeaponBag(nil, true)
    end
end

--==========msg end==============

function WeaponBag.OnExchangeBoxAndHandBoxItem(box)
	local boxHand, nHandCount = Hand_Get()	
	local nSourceType = boxHand:GetObjectType()
	if nSourceType == UI_OBJECT_SKILL then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_ERROR_CANNOT_DRAG_SKILL_IN_BAGPANEL)
		PlayTipSound("001")
		return
	elseif nSourceType == UI_OBJECT_CRAFT then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_ERROR_CANNOT_DRAG_CRAFT_IN_BAGPANEL)
		PlayTipSound("001")
		return
	elseif nSourceType == UI_OBJECT_OTER_PLAYER_ITEM then
		local _, dwBox, dwX, dwSaleID = boxHand:GetObjectData()
		MarketTradePanel_BuyItem(dwBox, dwX, dwSaleID, box.dwBox, box.dwX)
		Hand_Clear()
		return
	elseif nSourceType ~= UI_OBJECT_ITEM then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_ERROR_CANNOT_DRAG_ITEM_IN_BAGPANEL)
		PlayTipSound("001")
		return	
	end	
		
	local _, dwBox1, dwX1 = boxHand:GetObjectData()
	local dwBox2, dwX2 = box.dwBox, box.dwX
	if OnExchangeItem(dwBox1, dwX1, dwBox2, dwX2, nHandCount) then
		Hand_Clear()
	end
end

function WeaponBag_GetItemBox(dwBox, dwX, bEvenUnVisible)
	local frame = Station.Lookup("Normal/WeaponBag")
	if frame and (frame:IsVisible() or bEvenUnVisible) then
		if dwBox == INVENTORY_INDEX.BULLET_PACKAGE then
			local hList = frame:Lookup("", "Handle_Boxs")
			local hBox  = hList:Lookup(dwX):Lookup("Box")
			return hBox
		end
	end	
end

function OpenWeaponBag(bDiableSound, bNotFire)
	if IsWeaponBagOpen() then
		return
	end

	lc_hFrame = Wnd.OpenWindow("WeaponBag")
	if not bNotFire then
		FireUIEvent("OPEN_WEAPON_BAG")
	end
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
end

function CloseWeaponBag(bDisableSound, bFlag)
	if not IsWeaponBagOpen() then
		return
	end
	
	Wnd.CloseWindow("WeaponBag")
	FireUIEvent("CLOSE_WEAPON_BAG", bFlag)
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end
end

function IsWeaponBagOpen()
	local hFrame = Station.Lookup("Normal/WeaponBag")
	if hFrame and hFrame:IsVisible() then
		return true
	end
	
	return false
end

function WeaponBag_GetFreeBox()
	local player = GetClientPlayer()
	local nBoxSize = player.GetBoxFreeRoomSize(INVENTORY_INDEX.BULLET_PACKAGE)
	if nBoxSize and nBoxSize ~= 0 then
		local dwX = player.GetFreeRoom(INVENTORY_INDEX.BULLET_PACKAGE, ITEM_GENRE.EQUIPMENT, EQUIPMENT_SUB.BULLET)
		if dwX then
			return INVENTORY_INDEX.BULLET_PACKAGE, dwX
		end
	end
end

function IsCanWeaponBagOpen()
	local player = GetClientPlayer()
	local item = GetPlayerItem(player, INVENTORY_INDEX.EQUIP, EQUIPMENT_SUB.MELEE_WEAPON)
	if item and item.nGenre == ITEM_GENRE.EQUIPMENT and item.nDetail == WEAPON_DETAIL.BOW then
		return true
	end
	return false
end

local function OnEquipUpdate()
	if arg1 ~= EQUIPMENT_SUB.MELEE_WEAPON then
		return
	end
	
	if IsCanWeaponBagOpen() then
		if CharacterPanel_IsShowWeaponBag() and CharacterPanel_IsCharacterOpen() and 
		   not IsWeaponBagOpen() then
			OpenWeaponBag()
		end
	elseif IsWeaponBagOpen() then
		CloseWeaponBag()
	end
end

RegisterEvent("EQUIP_ITEM_UPDATE", OnEquipUpdate)

do
    local Anchor = {s = "TOPLEFT", r = "TOPRIGHT", x = 0, y = 6}
    RegisterFollowPanel("Normal/CharacterPanel", "Normal/WeaponBag", Anchor) 
end