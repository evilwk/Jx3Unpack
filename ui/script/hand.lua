function OnGlobalRButtonDown()
	if IsCursorInExclusiveMode() then
		return 1
	end	
	return 0
end

function OnGlobalRButtonUp()
	if IsCursorInExclusiveMode() then
		Hand_Clear()
		UserSelect.CancelSelect()
		Cursor.Switch(CURSOR.NORMAL)
		return 0
	end
	return 0
end

function OnGlobalRButtonDBClick()
	return OnGlobalRButtonUp()
end

function Hand_IsEmpty()
	local box = Station.Lookup("Lowest/Hand", "Box_Hand")
	if box then
		return box:IsEmpty()
	end
	return false
end

function Hand_Clear(bForPick)
	local box = Station.Lookup("Lowest/Hand", "Box_Hand")
	if not box or box:IsEmpty() then
		return
	end
	
	CloseMessageBox("DropItemSure")
	
	local nType = box:GetObjectType()
	if not bForPick then
		if IsObjectItem(nType) then
			PlayItemSound(box:GetObjectData(), true)
		else
			PlaySound(SOUND.UI_SOUND, g_sound.DropSkill)
		end
	end
	
	-----------------ReEnable装物品的格子--------------
	if nType == UI_OBJECT_ITEM then
		RemoveUILockItem("hand")
	end
	
	CharacterPanel_OnHandDropObj()	
		
	box:ClearObject()
	box:SetBoxIndex(-1)
	box:SetUserData(-1)
	box.nCount = nil
	box.bAction = nil
	
	if not IsCursorInExclusiveMode() or Cursor.GetCurrentIndex() == CURSOR.HAND_OBJECT then
		Cursor.Switch(CURSOR.NORMAL)
	end
	FireEvent("HAND_CLEAR_OBJECT")
end

function Hand_Get()
	local box = Station.Lookup("Lowest/Hand", "Box_Hand")
	return box, box.nCount
end

function Hand_Pick(box, nCount, bAction)
	local boxHand = Station.Lookup("Lowest/Hand", "Box_Hand")
	if not boxHand then
		return
	end
	
	Hand_Clear(box)
	
	if not box then
		return	
	end
	
	local nType = box:GetObjectType()
	if IsObjectItem(nType) then
		PlayItemSound(box:GetObjectData(), true)
	else
		PlaySound(SOUND.UI_SOUND, g_sound.TakeUpSkill)
	end
	
	-----------------DIsable装物品的格子--------------	
	if nType == UI_OBJECT_ITEM then
		local _, dwBox, dwX = box:GetObjectData()
		AddUILockItem("hand", dwBox, dwX)
	end
	
	boxHand:SetUserData(box:GetUserData())
	boxHand:SetBoxIndex(box:GetBoxIndex())
	boxHand:SetObject(box:GetObject())
	boxHand:SetObjectIcon(box:GetObjectIcon())
	boxHand.nCount = nCount
	boxHand.bAction = bAction
	
	Cursor.Switch(CURSOR.HAND_OBJECT, box:GetObjectIcon())
	
	FireEvent("HAND_PICK_OBJECT")
end

function Hand_DropHandObj()
	if Hand_IsEmpty() then
		return false
	end
	
	local box = Hand_Get()
	if not box then
		return false
	end
	
	local nType = box:GetObjectType()
	if nType == UI_OBJECT_ITEM and not box.bAction then
		OnDestroyItem()
	else
		Hand_Clear()
	end
	return true
end

--光标是否在一个只有主动取消才能改变的状态。
function IsCursorInExclusiveMode()
	local nIndex = Cursor.GetCurrentIndex()
	if nIndex == CURSOR.HAND_OBJECT 
		or nIndex == CURSOR.REPAIRE or nIndex == CURSOR.UNABLEREPAIRE
		or nIndex == CURSOR.SPLIT or nIndex == CURSOR.UNABLESPLIT
		or nIndex == CURSOR.CAST or nIndex == CURSOR.UNABLECAST 
		or nIndex == CURSOR.MARKPRICE then
		return true
	end
	return false
end

UserSelect = {nType = 0}

function UserSelect.SetSelectedBox(box)
	if UserSelect.szWndPath and UserSelect.szBoxPath then
		local box = Station.Lookup(UserSelect.szWndPath, UserSelect.szBoxPath)
		if box then
			box:SetObjectSelected(0)
		end
	end
	UserSelect.szWndPath = nil
	UserSelect.szBoxPath = nil
	if box then
		box:SetObjectSelected(1)
		UserSelect.szWndPath, UserSelect.szBoxPath = box:GetTreePath()
	end	
end

function UserSelect.RefreshSelectedBox()
	if UserSelect.szWndPath and UserSelect.szBoxPath then
		local box = Station.Lookup(UserSelect.szWndPath, UserSelect.szBoxPath)
		if box then
			box:SetObjectSelected(1)
		end
	end
end

function UserSelect.SelectPoint(fnAction, fnCancel, fnCondition, box)
	UserSelect.CancelSelect()
	UserSelect.nType = 1
	UserSelect.fnAction = fnAction
	UserSelect.fnCancel = fnCancel
	UserSelect.fnCondition = fnCondition
	Cursor.Switch(CURSOR.UNABLECAST)
	UserSelect.SetSelectedBox(box)
end

function UserSelect.SelectItem(fnAction, fnCancel, fnCondition, box, bBreakEquip)
	UserSelect.CancelSelect()
	UserSelect.nType = 2
	UserSelect.fnAction = fnAction
	UserSelect.fnCancel = fnCancel
	UserSelect.fnCondition = fnCondition
	UserSelect.bBreakEquip = bBreakEquip
	if bBreakEquip then
		Cursor.Switch(CURSOR.UNABLESPLIT)
	else
		Cursor.Switch(CURSOR.UNABLECAST)
	end
	UserSelect.SetSelectedBox(box)
end

function UserSelect.SelectCharacter(fnAction, fnCancel, fnCondition, box)
	UserSelect.CancelSelect()
	UserSelect.nType = 3
	UserSelect.fnAction = fnAction
	UserSelect.fnCancel = fnCancel
	UserSelect.fnCondition = fnCondition
	Cursor.Switch(CURSOR.UNABLECAST)
	UserSelect.SetSelectedBox(box)
end

function UserSelect.CancelSelect()
	if UserSelect.nType == 0 then
		return
	end
	if UserSelect.fnCancel then
		UserSelect.fnCancel()
	end
	UserSelect.nType = 0
	UserSelect.fnAction = nil
	UserSelect.fnCancel = nil
	UserSelect.fnCondition = nil
	Cursor.Switch(CURSOR.NORMAL)
	UserSelect.SetSelectedBox(nil)
end

function UserSelect.IsSelectPoint()
	if UserSelect.nType == 1 then
		return true
	end
	return false
end

function UserSelect.SatisfySelectPoint(x, y, z, bFalse)
	if UserSelect.nType ~= 1 then
		return false
	end
	local bSatisfied = true
	if bFalse then
		bSatisfied = false
	elseif UserSelect.fnCondition then
		bSatisfied = UserSelect.fnCondition(x, y, z)
	end
	if bSatisfied then
		Cursor.Switch(CURSOR.CAST)
	else
		Cursor.Switch(CURSOR.UNABLECAST)
	end
	return bSatisfied
end

function UserSelect.DoSelectPoint(x, y, z)
	if UserSelect.nType == 1 then
		if UserSelect.SatisfySelectPoint(x, y, z) then
			UserSelect.fnAction(x, y, z)
			UserSelect.nType = 0
			UserSelect.fnAction = nil
			UserSelect.fnCancel = nil
			UserSelect.fnCondition = nil
			Cursor.Switch(CURSOR.NORMAL)
			UserSelect.SetSelectedBox(nil)
		end
		return true
	end
	return false
end

function UserSelect.IsSelectItem()
	if UserSelect.nType == 2 then
		return true
	end
	return false
end

function UserSelect.SatisfySelectItem(dwBox, dwX, bFalse)
	if UserSelect.nType ~= 2 then
		return false
	end

	--TODO:判断鼠标是否在道具上
	
	local bSatisfied = true
	if bFalse then
		bSatisfied = false
	elseif UserSelect.fnCondition then
		bSatisfied = UserSelect.fnCondition(dwBox, dwX)
	end
	
	if UserSelect.bBreakEquip then
		if bSatisfied then
			Cursor.Switch(CURSOR.SPLIT)
		else
			Cursor.Switch(CURSOR.UNABLESPLIT)
		end
	else
		if bSatisfied then
			Cursor.Switch(CURSOR.CAST)
		else
			Cursor.Switch(CURSOR.UNABLECAST)
		end
	end
	return bSatisfied
end

function UserSelect.DoSelectItem(dwBox, dwX)
	if UserSelect.nType == 2 then
		if UserSelect.SatisfySelectItem(dwBox, dwX) then
			UserSelect.fnAction(dwBox, dwX)
			UserSelect.nType = 0
			UserSelect.fnAction = nil
			UserSelect.fnCancel = nil
			UserSelect.fnCondition = nil
			Cursor.Switch(CURSOR.NORMAL)
			UserSelect.SetSelectedBox(nil)
		end
		return true
	end
	return false
end

function UserSelect.IsSelectCharacter()
	if UserSelect.nType == 3 then
		return true
	end
	return false
end

function UserSelect.SatisfySelectCharacter(dwType, dwID, bFalse)
	if UserSelect.nType ~= 3 then
		return false
	end
	local bSatisfied = true
	if bFalse then
		bSatisfied = false
	elseif UserSelect.fnCondition then
		bSatisfied = UserSelect.fnCondition(dwType, dwID)
	end
	if bSatisfied then
		Cursor.Switch(CURSOR.CAST)
	else
		Cursor.Switch(CURSOR.UNABLECAST)
	end
	return bSatisfied
end

function UserSelect.DoSelectCharacter(dwType, dwID)
	if UserSelect.nType == 3 then
		if UserSelect.SatisfySelectCharacter(dwType, dwID) then
			UserSelect.fnAction(dwType, dwID)
			UserSelect.nType = 0
			UserSelect.fnAction = nil
			UserSelect.fnCancel = nil
			UserSelect.fnCondition = nil
			Cursor.Switch(CURSOR.NORMAL)
			UserSelect.SetSelectedBox(nil)
		end
		return true
	end
	return false
end
