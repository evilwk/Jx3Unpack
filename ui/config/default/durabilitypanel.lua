DurabilityPanel = 
{
	DefaultAnchor = {s = "TOPRIGHT", r = "TOPRIGHT",  x = -240, y = 140},
	Anchor = {s = "TOPRIGHT", r = "TOPRIGHT", x = -240, y = 140}
}

RegisterCustomData("DurabilityPanel.Anchor")

function DurabilityPanel.OnFrameCreate()
	this:RegisterEvent("UI_SCALED")
	this:RegisterEvent("ON_ENTER_CUSTOM_UI_MODE")
	this:RegisterEvent("ON_LEAVE_CUSTOM_UI_MODE")
	this:RegisterEvent("DURABILITY_ANCHOR_CHANGED")
	this:RegisterEvent("CUSTOM_DATA_LOADED")
	
	this.nCount = 0
	
	DurabilityPanel.UpdateAnchor(this)
	UpdateCustomModeWindow(this, g_tStrings.DURABILITY, true)	
end

function DurabilityPanel.OnFrameDrag()
end

function DurabilityPanel.OnFrameDragSetPosEnd()
end

function DurabilityPanel.OnFrameDragEnd()
	this:CorrectPos()
	DurabilityPanel.Anchor = GetFrameAnchor(this)
end

function DurabilityPanel.UpdateAnchor(frame)
	frame:SetPoint(DurabilityPanel.Anchor.s, 0, 0, DurabilityPanel.Anchor.r, DurabilityPanel.Anchor.x, DurabilityPanel.Anchor.y)
	frame:CorrectPos()
end

function DurabilityPanel.OnEvent(event)
	if event == "UI_SCALED" then
		DurabilityPanel.UpdateAnchor(this)
	elseif event == "ON_ENTER_CUSTOM_UI_MODE" or event == "ON_LEAVE_CUSTOM_UI_MODE" then
		UpdateCustomModeWindow(this, nil, true)
	elseif event == "DURABILITY_ANCHOR_CHANGED" then
		DurabilityPanel.UpdateAnchor(this)
	elseif event == "CUSTOM_DATA_LOADED" then
		DurabilityPanel.UpdateAnchor(this)
	end
end

function DurabilityPanel.OnFrameBreathe()
	local player = GetClientPlayer()
	if not player then
		return
	end 
	
	if this.nCount < 16 then
		this.nCount = this.nCount + 1
		return
	end
	this.nCount = 0
	
	local handle = this:Lookup("", "")
	local bShow = false
	
	local item = GetPlayerItem(player, INVENTORY_INDEX.EQUIP, EQUIPMENT_INVENTORY.HELM)
	if item and item.nCurrentDurability == 0 then
		handle:Lookup("Helm_Normal"):Hide()
		handle:Lookup("Helm_Warning"):Hide()
		handle:Lookup("Helm_Damage"):Show()
		bShow = true
		FireHelpEvent("OnLossDurability", "Damage", handle:Lookup("Helm_Damage"))
	elseif item and item.nCurrentDurability <= item.nMaxDurability / 10 then
		handle:Lookup("Helm_Normal"):Hide()
		handle:Lookup("Helm_Warning"):Show()
		handle:Lookup("Helm_Damage"):Hide()
		FireHelpEvent("OnLossDurability", "Warning")
		bShow = true
	else
		handle:Lookup("Helm_Normal"):Show()
		handle:Lookup("Helm_Warning"):Hide()
		handle:Lookup("Helm_Damage"):Hide()		
	end
	
	item = GetPlayerItem(player, INVENTORY_INDEX.EQUIP, EQUIPMENT_INVENTORY.CHEST)
	if item and item.nCurrentDurability == 0 then
		handle:Lookup("Chest_Normal"):Hide()
		handle:Lookup("Chest_Warning"):Hide()
		handle:Lookup("Chest_Damage"):Show()
		FireHelpEvent("OnLossDurability", "Damage", handle:Lookup("Chest_Damage"))
		bShow = true
	elseif item and item.nCurrentDurability <= item.nMaxDurability / 10 then
		handle:Lookup("Chest_Normal"):Hide()
		handle:Lookup("Chest_Warning"):Show()
		handle:Lookup("Chest_Damage"):Hide()
		FireHelpEvent("OnLossDurability", "Warning")
		bShow = true
	else
		handle:Lookup("Chest_Normal"):Show()
		handle:Lookup("Chest_Warning"):Hide()
		handle:Lookup("Chest_Damage"):Hide()		
	end

	item = GetPlayerItem(player, INVENTORY_INDEX.EQUIP, EQUIPMENT_INVENTORY.BANGLE)
	if item and item.nCurrentDurability == 0 then
		handle:Lookup("Bangle_Normal"):Hide()
		handle:Lookup("Bangle_Warning"):Hide()
		handle:Lookup("Bangle_Damage"):Show()
		FireHelpEvent("OnLossDurability", "Damage", handle:Lookup("Bangle_Damage"))
		bShow = true
	elseif item and item.nCurrentDurability <= item.nMaxDurability / 10 then
		handle:Lookup("Bangle_Normal"):Hide()
		handle:Lookup("Bangle_Warning"):Show()
		handle:Lookup("Bangle_Damage"):Hide()
		FireHelpEvent("OnLossDurability", "Warning")
		bShow = true
	else
		handle:Lookup("Bangle_Normal"):Show()
		handle:Lookup("Bangle_Warning"):Hide()
		handle:Lookup("Bangle_Damage"):Hide()		
	end
	
	item = GetPlayerItem(player, INVENTORY_INDEX.EQUIP, EQUIPMENT_INVENTORY.WAIST)
	if item and item.nCurrentDurability == 0 then
		handle:Lookup("Waist_Normal"):Hide()
		handle:Lookup("Waist_Warning"):Hide()
		handle:Lookup("Waist_Damage"):Show()
		FireHelpEvent("OnLossDurability", "Damage", handle:Lookup("Waist_Damage"))
		bShow = true
	elseif item and item.nCurrentDurability <= item.nMaxDurability / 10 then
		handle:Lookup("Waist_Normal"):Hide()
		handle:Lookup("Waist_Warning"):Show()
		handle:Lookup("Waist_Damage"):Hide()
		FireHelpEvent("OnLossDurability", "Warning")
		bShow = true
	else
		handle:Lookup("Waist_Normal"):Show()
		handle:Lookup("Waist_Warning"):Hide()
		handle:Lookup("Waist_Damage"):Hide()		
	end

	item = GetPlayerItem(player, INVENTORY_INDEX.EQUIP, EQUIPMENT_INVENTORY.PANTS)
	if item and item.nCurrentDurability == 0 then
		handle:Lookup("Pants_Normal"):Hide()
		handle:Lookup("Pants_Warning"):Hide()
		handle:Lookup("Pants_Damage"):Show()
		FireHelpEvent("OnLossDurability", "Damage", handle:Lookup("Pants_Damage"))
		bShow = true
	elseif item and item.nCurrentDurability <= item.nMaxDurability / 10 then
		handle:Lookup("Pants_Normal"):Hide()
		handle:Lookup("Pants_Warning"):Show()
		handle:Lookup("Pants_Damage"):Hide()
		FireHelpEvent("OnLossDurability", "Warning")
		bShow = true
	else
		handle:Lookup("Pants_Normal"):Show()
		handle:Lookup("Pants_Warning"):Hide()
		handle:Lookup("Pants_Damage"):Hide()		
	end

	item = GetPlayerItem(player, INVENTORY_INDEX.EQUIP, EQUIPMENT_INVENTORY.BOOTS)
	if item and item.nCurrentDurability == 0 then
		handle:Lookup("Boots_Warning"):Hide()
		handle:Lookup("Boots_Warning"):Hide()
		handle:Lookup("Boots_Damage"):Show()
		FireHelpEvent("OnLossDurability", "Damage", handle:Lookup("Boots_Damage"))
		bShow = true
	elseif item and item.nCurrentDurability <= item.nMaxDurability / 10 then
		handle:Lookup("Boots_Normal"):Hide()
		handle:Lookup("Boots_Warning"):Show()
		handle:Lookup("Boots_Damage"):Hide()
		FireHelpEvent("OnLossDurability", "Warning")
		bShow = true
	else
		handle:Lookup("Boots_Normal"):Show()
		handle:Lookup("Boots_Warning"):Hide()
		handle:Lookup("Boots_Damage"):Hide()		
	end

	item = GetPlayerItem(player, INVENTORY_INDEX.EQUIP, EQUIPMENT_INVENTORY.MELEE_WEAPON)
	if item and item.nCurrentDurability == 0 then
		handle:Lookup("Weapon_Normal"):Hide()
		handle:Lookup("Weapon_Warning"):Hide()
		handle:Lookup("Weapon_Damage"):Show()
		FireHelpEvent("OnLossDurability", "Damage", handle:Lookup("Weapon_Damage"))
		bShow = true
	elseif item and item.nCurrentDurability <= item.nMaxDurability / 10 then
		handle:Lookup("Weapon_Normal"):Hide()
		handle:Lookup("Weapon_Warning"):Show()
		handle:Lookup("Weapon_Damage"):Hide()
		FireHelpEvent("OnLossDurability", "Warning")
		bShow = true
	else
		handle:Lookup("Weapon_Normal"):Show()
		handle:Lookup("Weapon_Warning"):Hide()
		handle:Lookup("Weapon_Damage"):Hide()		
	end

	item = GetPlayerItem(player, INVENTORY_INDEX.EQUIP, EQUIPMENT_INVENTORY.RANGE_WEAPON)
	if item and item.nCurrentDurability == 0 then
		handle:Lookup("RangeWeapon_Normal"):Hide()
		handle:Lookup("RangeWeapon_Warning"):Hide()
		handle:Lookup("RangeWeapon_Damage"):Show()
		FireHelpEvent("OnLossDurability", "Damage", handle:Lookup("RangeWeapon_Damage"))
		bShow = true
	elseif item and item.nCurrentDurability <= item.nMaxDurability / 10 then
		handle:Lookup("RangeWeapon_Normal"):Hide()
		handle:Lookup("RangeWeapon_Warning"):Show()
		handle:Lookup("RangeWeapon_Damage"):Hide()
		FireHelpEvent("OnLossDurability", "Warning")
		bShow = true
	else
		handle:Lookup("RangeWeapon_Normal"):Show()
		handle:Lookup("RangeWeapon_Warning"):Hide()
		handle:Lookup("RangeWeapon_Damage"):Hide()		
	end
	
	if bShow then
		handle:Show()
	else
		handle:Hide()
	end
end

function DurabilityPanel_SetAnchorDefault()
	DurabilityPanel.Anchor.s = DurabilityPanel.DefaultAnchor.s
	DurabilityPanel.Anchor.r = DurabilityPanel.DefaultAnchor.r
	DurabilityPanel.Anchor.x = DurabilityPanel.DefaultAnchor.x
	DurabilityPanel.Anchor.y = DurabilityPanel.DefaultAnchor.y
	FireEvent("DURABILITY_ANCHOR_CHANGED")
end

RegisterEvent("CUSTOM_UI_MODE_SET_DEFAULT", DurabilityPanel_SetAnchorDefault)

function LoadDurabilityPanelSetting()
	local szIniFile = GetUserDataPath()
	if szIniFile == "" then
		OpenDebuffList()
		return
	end
	szIniFile = szIniFile.."\\PannelSave.ini"

	local iniS = Ini.Open(szIniFile)
	if not iniS then
		OpenDebuffList()
		return
	end
	
	local szSection = "DurabilityPanel"	
	
	local Anchor = {}
	local value = iniS:ReadString(szSection, "SelfSide", DurabilityPanel.Anchor.s)
	if value then
		Anchor.s = value
	end
	value = iniS:ReadString(szSection, "RelSide", DurabilityPanel.Anchor.r)
	if value then
		Anchor.r = value
	end
	value = iniS:ReadInteger(szSection, "RelX", DurabilityPanel.Anchor.x)
	if value then
		Anchor.x = value
	end
	value = iniS:ReadInteger(szSection, "RelY", DurabilityPanel.Anchor.y)
	if value then
		Anchor.y = value
	end
	
	if Anchor.s and Anchor.r and Anchor.x and Anchor.y then
		DurabilityPanel.Anchor = Anchor
		FireEvent("DURABILITY_ANCHOR_CHANGED")
	end
	
	iniS:Close()
end

RegisterLoadFunction(LoadDurabilityPanelSetting)
