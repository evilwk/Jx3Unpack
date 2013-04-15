local TYPE = {
	DIAMOND = 0,
	EQUIPMENT = 1,
	COLOR = 2,
}

local MILLION_NUMBER = 1048576				--百分率基数
local BOX_COUNT = 16						--最大的宝石原料数量
local DIAMOND_MAX_LEVEL = 6					--宝石的最大等级
local CHANGE_COLOR_DIAMOND = 1
local UPDATE_COLOR_DIAMOND = 8

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

local SFX1 = {
	Ttl=32,
	Camera={ 0, 0, -200, 0, 0, 0, nil, nil, nil, nil, false }, 
	Models={
		[1]={ 
			Model={
				Name="SFX1",
				--File="data/source/other/特效/系统/SFX/升级/升级01.Sfx",
				File="data/source/other/特效/系统/SFX/其他/合成01.Sfx",
				Translation={x=0, y=0, z=0},
				Rotation={x=0.85,y=0,z=0,w=0.525},
				Scaling={x=0.35,y=0.35,z=0.35},
		
				Ani={
					File="",
					PlayType="once",
					Speed=1,
					StartTime=0
				}
			}
		}
	}
}

local SFX2 = {
	Ttl=32,
	Camera={ 0, 0, -200, 0, 0, 0, nil, nil, nil, nil, false }, 
	Models={
		[1]={ 
			Model={
				Name="SFX2",
				--File="data/source/other/特效/系统/SFX/升级/升级01.Sfx",
				File="data/source/other/特效/系统/SFX/其他/合成02.Sfx",
				Translation={x=0, y=0, z=0},
				Rotation={x=0.85,y=0,z=0,w=0.525},
				Scaling={x=0.35,y=0.35,z=0.35},
		
				Ani={
					File="",
					PlayType="once",
					Speed=1,
					StartTime=0
				}
			}
		}
	}
}

FEProducePanel = {
	type = TYPE.DIAMOND,
	stamina = 0,
	sfxon = false,
	sfxtime = 0,
}

FEEquipInfoPanel = {}

function FEEquipInfoPanel.OnFrameCreate()
	local btn = this:Lookup("Btn_Close")
	btn:Hide()
end

function FEProducePanel.OnChangeColorDiamondResult(nResult)
	local frame = Station.Lookup("Normal/FEProducePanel")
	local player = GetClientPlayer()
	if not player then
		return
	end
			
	if nResult == DIAMOND_RESULT_CODE.SUCCESS then
		local box = frame:Lookup("", ""):Lookup("Box_FE")
		OutputMessage("MSG_ANNOUNCE_YELLOW", g_tStrings.tFEProduce.CHANGE_COLOE_DIAMOND_SUCCEED)
		FEProducePanel.ClearMaterial(frame)
		FEProducePanel.Update(frame)
	elseif nResult == DIAMOND_RESULT_CODE.NOT_ENOUGH_FREE_ROOM then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFECommon.NO_ENOUGH_ROOM)
	elseif nResult == DIAMOND_RESULT_CODE.ATLEAST_ONE_MATERIAL then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFECommon.NOT_ENOUGH_MATERAL)
	elseif nResult == DIAMOND_RESULT_CODE.NOT_ENOUGH_MONEY_FOR_COST then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFECommon.NOT_ENOUGH_MONEY_FOR_COST)
	elseif nResult == DIAMOND_RESULT_CODE.NOT_ENOUGH_STAMINA then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFECommon.NOT_ENOUGH_STAMINA)
	elseif nResult == DIAMOND_RESULT_CODE.CAN_NOT_OPERATE_IN_FIGHT then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFEProduce.CAN_NOT_OPERATE_IN_FIGHT)
	elseif nResult == DIAMOND_RESULT_CODE.TARGET_DIAMOND_MUSTBE_SINGLE then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFEProduce.MAIN_DIAMON_CAN_NOT_STACKED)
	elseif nResult == DIAMOND_RESULT_CODE.SCENE_FORBID then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFECommon.SCENE_FORBID)
	elseif nResult == DIAMOND_RESULT_CODE.COLOR_DIAMOND_LEVEL_CANNOT_CHANGE then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFEProduce.COLOR_DIAMOND_LEVEL_CANNOT_CHANGE)
	elseif nResult == DIAMOND_RESULT_CODE.COLOR_DIAMOND_LEVEL_CANNOT_UPDATE then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFEProduce.COLOR_DIAMOND_LEVEL_CANNOT_UPDATE)
	elseif nResult == DIAMOND_RESULT_CODE.ERROR_MATERIAL_COUNT then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFEProduce.ERROR_MATERIAL_COUNT)
	else
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFEProduce.CHANGE_COLOR_DIAMOND_FAILED)
		FEProducePanel.ClearMaterial(frame)
		FEProducePanel.Update(frame)
		PlaySound(SOUND.UI_SOUND, g_sound.FEProduceEquipFail)
	end
end

function FEProducePanel.OnUpdateColorDiamondResult(nResult)
	local frame = Station.Lookup("Normal/FEProducePanel")
	local player = GetClientPlayer()
	if not player then
		return
	end
	
	local box = frame:Lookup("", ""):Lookup("Box_FE")
	local item = GetPlayerItem(player, box.dwBox, box.dwX)
	if not item then
		return
	end
			
	if nResult == DIAMOND_RESULT_CODE.SUCCESS then
		OutputMessage("MSG_ANNOUNCE_YELLOW", g_tStrings.tFEProduce.UPDATE_COLOE_DIAMOND_SUCCEED)
		FEProducePanel.ClearMaterial(frame)
		FEProducePanel.Update(frame)
	elseif nResult == DIAMOND_RESULT_CODE.NOT_ENOUGH_FREE_ROOM then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFECommon.NO_ENOUGH_ROOM)
	elseif nResult == DIAMOND_RESULT_CODE.ATLEAST_ONE_MATERIAL then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFECommon.NOT_ENOUGH_MATERAL)
	elseif nResult == DIAMOND_RESULT_CODE.NOT_ENOUGH_MONEY_FOR_COST then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFECommon.NOT_ENOUGH_MONEY_FOR_COST)
	elseif nResult == DIAMOND_RESULT_CODE.NOT_ENOUGH_STAMINA then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFECommon.NOT_ENOUGH_STAMINA)
	elseif nResult == DIAMOND_RESULT_CODE.CAN_NOT_OPERATE_IN_FIGHT then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFEProduce.CAN_NOT_OPERATE_IN_FIGHT)
	elseif nResult == DIAMOND_RESULT_CODE.TARGET_DIAMOND_MUSTBE_SINGLE then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFEProduce.MAIN_DIAMON_CAN_NOT_STACKED)
	elseif nResult == DIAMOND_RESULT_CODE.SCENE_FORBID then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFECommon.SCENE_FORBID)
	elseif nResult == DIAMOND_RESULT_CODE.COLOR_DIAMOND_LEVEL_CANNOT_CHANGE then
		local nLevel = GetMaxChangeColorDiamondLevel()
		if nLevel >= item.nDetail then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFEProduce.COLOR_DIAMOND_LEVEL_CANNOT_CHANGE)
		else
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFEProduce.COLOR_DIAMOND_LEVEL_CANNOT_CHANGE)
		end
	elseif nResult == DIAMOND_RESULT_CODE.COLOR_DIAMOND_LEVEL_CANNOT_UPDATE then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFEProduce.COLOR_DIAMOND_LEVEL_CANNOT_UPDATE)
	elseif nResult == DIAMOND_RESULT_CODE.ERROR_MATERIAL_COUNT then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFEProduce.ERROR_MATERIAL_COUNT)
	else
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFEProduce.UPADTE_COLOR_DIAMOND_FAILED)
		FEProducePanel.ClearMaterial(frame)
		FEProducePanel.Update(frame)
		PlaySound(SOUND.UI_SOUND, g_sound.FEProduceEquipFail)
	end
end

function FEProducePanel.OnEvent(event)
	if event == "DIAMON_UPDATE" then
		local nResult = arg0
		local frame = Station.Lookup("Normal/FEProducePanel")
		if nResult == DIAMOND_RESULT_CODE.SUCCESS then
			local box = frame:Lookup("", ""):Lookup("Box_FE")
			local player = GetClientPlayer()
			if not player then
				return
			end
			local item = GetPlayerItem(player, box.dwBox, box.dwX)
			if not item then
				return
			end
			if item.nDetail > box.nDetail then
				--FEProducePanel.PlayLevelupAnimation(frame)
				FEProducePanel.PlaySuccessAnimation(frame, item.nDetail - box.nDetail)
				OutputMessage("MSG_ANNOUNCE_YELLOW", g_tStrings.tFEProduce.SUCCEED)
			else
				OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFEProduce.FAILED)
			end
			--FEProducePanel.PlayDisppearAnimation(frame)
			FEProducePanel.ClearMaterial(frame)
			FEProducePanel.Update(frame)
		elseif nResult == DIAMOND_RESULT_CODE.NOT_ENOUGH_FREE_ROOM then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFECommon.NO_ENOUGH_ROOM)
		elseif nResult == DIAMOND_RESULT_CODE.ATLEAST_ONE_MATERIAL then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFECommon.ATLEAST_ONE_MATERIAL)
		elseif nResult == DIAMOND_RESULT_CODE.DIAMOND_UP_TO_MAX_LEVEL then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFEProduce.DIAMOND_UP_TO_MAX_LEVEL)
		elseif nResult == DIAMOND_RESULT_CODE.NOT_ENOUGH_MONEY_FOR_COST then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFECommon.NOT_ENOUGH_MONEY_FOR_COST)
		elseif nResult == DIAMOND_RESULT_CODE.NOT_ENOUGH_STAMINA then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFECommon.NOT_ENOUGH_STAMINA)
		elseif nResult == DIAMOND_RESULT_CODE.CAN_NOT_OPERATE_IN_FIGHT then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFEProduce.CAN_NOT_OPERATE_IN_FIGHT)
		elseif nResult == DIAMOND_RESULT_CODE.TARGET_DIAMOND_MUSTBE_SINGLE then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFEProduce.MAIN_DIAMON_CAN_NOT_STACKED)
		elseif nResult == DIAMOND_RESULT_CODE.SCENE_FORBID then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFECommon.SCENE_FORBID)
		else
			FEProducePanel.PlayDisppearAnimation(frame)
			FEProducePanel.ClearMaterial(frame)
			FEProducePanel.Update(frame)
			PlaySound(SOUND.UI_SOUND, g_sound.FEProduceDiamondFail)
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFEProduce.FAILED)
		end
	elseif event == "FE_STRENGTH_EQUIP" then
		local frame = Station.Lookup("Normal/FEProducePanel")
		local handle = frame:Lookup("", "Handle_Item")
		local nResult = arg0
		local player = GetClientPlayer()
		if nResult == DIAMOND_RESULT_CODE.SUCCESS then
			local box = frame:Lookup("", ""):Lookup("Box_FE")
			local item = GetPlayerItem(player, box.dwBox, box.dwX)
			
			AddUILockItem("FEEquip", box.dwBox, box.dwX)
			if box.nStrengthLevel < item.nStrengthLevel then
				--FEProducePanel.PlayLevelupAnimation(frame)
				FEProducePanel.PlaySuccessAnimation(frame, item.nStrengthLevel - box.nStrengthLevel)
				OutputMessage("MSG_ANNOUNCE_YELLOW", g_tStrings.tFEEquip.SUCCEED)
			else
				OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFEEquip.FAILED)
			end
			--FEProducePanel.PlayDisppearAnimation(frame)
			FEProducePanel.ClearMaterial(frame)
			FEProducePanel.Update(frame)
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
		elseif nResult == DIAMOND_RESULT_CODE.NOT_ENOUGH_STAMINA then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFECommon.NOT_ENOUGH_STAMINA)
		elseif nResult == DIAMOND_RESULT_CODE.NEED_EQUIP_BIND then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFECommon.NEED_EQUIP_BIND)
		elseif nResult == DIAMOND_RESULT_CODE.CAN_NOT_OPERATE_IN_FIGHT then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFEProduce.CAN_NOT_OPERATE_IN_FIGHT)
		elseif nResult == DIAMOND_RESULT_CODE.SCENE_FORBID then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFECommon.SCENE_FORBID)
		else
			local frame = Station.Lookup("Normal/FEProducePanel")
			FEProducePanel.PlayDisppearAnimation(frame)
			FEProducePanel.ClearMaterial(frame)
			FEProducePanel.Update(frame)
			PlaySound(SOUND.UI_SOUND, g_sound.FEProduceEquipFail)
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFEEquip.FAILED)
		end
	elseif event == "CHANGE_COLOR_DIAMOND_RESPOND" then
		FEProducePanel.OnChangeColorDiamondResult(arg0)
	elseif event == "UPDATE_COLOR_DIAMOND_RESPOND" then
		FEProducePanel.OnUpdateColorDiamondResult(arg0)
	end
end

function FEProducePanel.OnFrameCreate()
	this:RegisterEvent("DIAMON_UPDATE")
	this:RegisterEvent("FE_STRENGTH_EQUIP")
	this:RegisterEvent("CHANGE_COLOR_DIAMOND_RESPOND")
	this:RegisterEvent("UPDATE_COLOR_DIAMOND_RESPOND")
	
	FEProducePanel.Init(this)
	
	InitFrameAutoPosInfo(this, 1, nil, nil, function() CloseFEProducePanel(true) end)
end

function FEProducePanel.OnFrameBreathe()
	local player = GetClientPlayer()
	if not player or player.nMoveState == MOVE_STATE.ON_DEATH then
		CloseFEProducePanel()
		return
	end
	
	if FEProducePanel.sfxon then
		if FEProducePanel.sfxtime <= 0 then
			local handle = Station.Lookup("Normal/FEProducePanel"):Lookup("", "")
			handle:Lookup("Animate_GQ"):Hide()
		end
		FEProducePanel.sfxtime = FEProducePanel.sfxtime - 1
	end
end

function FEProducePanel.OnItemLButtonUp()
	this:SetObjectPressed(0)
end

function FEProducePanel.OnItemLButtonDown()
	this:SetObjectPressed(1)
end

function FEProducePanel.OnItemLButtonDrag()
	this:SetObjectPressed(0)
	local name = this:GetName()
	if Hand_IsEmpty() then
		if not this:IsEmpty() then
			if IsCursorInExclusiveMode() then
				OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.SRT_ERROR_CANCEL_CURSOR_STATE)
			elseif name == "Box_FE" then
				Hand_Pick(this)
				if FEProducePanel.type == TYPE.DIAMOND then
					FEProducePanel.ResetBox(this, "FEProduce")
				elseif FEProducePanel.type == TYPE.EQUIPMENT then
					FEProducePanel.ResetBox(this, "FEEquip")
				elseif FEProducePanel.type == TYPE.COLOR then
					FEProducePanel.ResetBox(this, "FEColorDiamond")
				end
				FEProducePanel.ResetStatic(this:GetRoot())
			elseif this.state == "main" then
				FEProducePanel.PickUpActiveDiamond(this, true)
				FEProducePanel.Update(this:GetRoot())
			end
			HideTip()
		end
	end
end

function FEProducePanel.OnItemLButtonDragEnd()
	this.bIgnoreClick = true
	local name = this:GetName()
	if not Hand_IsEmpty() then
		if name == "Box_FE" then
			local box_hand, hand_count = Hand_Get()
			FEProducePanel.OnExchangeBoxItem(this, box_hand, hand_count, true)
		else
			local box_hand, hand_count = Hand_Get()
			FEProducePanel.AddDiamond(this, box_hand, hand_count, true)
		end
	end
end

function FEProducePanel.OnItemLButtonClick()
	local name = this:GetName()
	if name == "Box_FE" then
		if Hand_IsEmpty() then
			if not this:IsEmpty() then
				if IsCursorInExclusiveMode() then
					OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.SRT_ERROR_CANCEL_CURSOR_STATE)
				else
					Hand_Pick(this)
					if FEProducePanel.type == TYPE.DIAMOND then
						FEProducePanel.ResetBox(this, "FEProduce")
					elseif FEProducePanel.type == TYPE.EQUIPMENT then
						FEProducePanel.ResetBox(this, "FEEquip")
					elseif FEProducePanel.type == TYPE.COLOR then
						FEProducePanel.ResetBox(this, "FEColorDiamond")
					end
					FEProducePanel.ResetStatic(this:GetRoot())
				end
				HideTip()
			end
		else
			local box, count = Hand_Get()
			FEProducePanel.OnExchangeBoxItem(this, box, count, true)
		end
	else
		local box_index = tonumber(string.sub(name, 9, -1)) or 0
		if box_index > 0 and box_index <= BOX_COUNT then
			if Hand_IsEmpty() then
				if not this:IsEmpty() and this.state == "main" then
					if IsCursorInExclusiveMode() then
						OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.SRT_ERROR_CANCEL_CURSOR_STATE)
					else
						FEProducePanel.PickUpActiveDiamond(this, true)
						FEProducePanel.Update(this:GetRoot())
					end
					HideTip()
				end
			else
				local boxHand, nHandCount = Hand_Get()
				FEProducePanel.AddDiamond(this, boxHand, nHandCount, true)
			end
		end
	end
end

function FEProducePanel.OnLButtonClick()
	local name = this:GetName()
	if name == "Btn_Close" then
		CloseFEProducePanel(true)
	elseif name == "Btn_Mode" then
		CloseFEProducePanel(true)
		OpenFEQuickPanel()
	elseif name == "Btn_Making_2" then
		FEProducePanel.ChangeColorDiamond(this)
	elseif name == "Btn_Making_3" then
		if FEProducePanel.type == TYPE.COLOR then
			FEProducePanel.UpdateColorDiamond(this)
		else
			FEProducePanel.Produce(this)
		end
	end
end

function FEProducePanel.OnItemRButtonClick()
	local name = this:GetName()
	if name == "Box_FE" then
		if not this:IsEmpty() then
			if FEProducePanel.type == TYPE.DIAMOND then
				FEProducePanel.ResetBox(this, "FEProduce")
			elseif FEProducePanel.type == TYPE.EQUIPMENT then
				FEProducePanel.ResetBox(this, "FEEquip")
			elseif FEProducePanel.type == TYPE.COLOR then
				FEProducePanel.ResetBox(this, "FEColorDiamond")
			end
			FEProducePanel.ResetStatic(this:GetRoot())
			FEProducePanel.Update(this:GetRoot())
			local type = this:GetObjectType()
			if IsObjectItem(type) then
				PlayItemSound(this:GetObjectData(), true)
			else
				PlaySound(SOUND.UI_SOUND, g_sound.TakeUpSkill)
			end
			HideTip()
		end
	else
		local box_index = tonumber(string.sub(name, 9, -1)) or 0
		if box_index > 0 and box_index <= BOX_COUNT then
			if not this:IsEmpty() and this.state == "main" then
				FEProducePanel.PickUpActiveDiamond(this)
				FEProducePanel.Update(this:GetRoot())
				local type = this:GetObjectType()
				if IsObjectItem(type) then
					PlayItemSound(this:GetObjectData(), true)
				else
					PlaySound(SOUND.UI_SOUND, g_sound.TakeUpSkill)
				end
				HideTip()
			end
		end
	end
end

function FEProducePanel.OnItemMouseEnter()
	this:SetObjectMouseOver(1)
	local name = this:GetName()
	local x, y = this:GetAbsPos()
	local w, h = this:GetSize()
	if name == "Box_FE" then
		if this:IsEmpty() then
			if FEProducePanel.type == TYPE.DIAMOND then
				OutputTip(GetFormatText(g_tStrings.tFEProduce.NO_MOTHER_DIAMON), 400, {x, y ,w, h})
			elseif FEProducePanel.type == TYPE.EQUIPMENT then
				OutputTip(GetFormatText(g_tStrings.tFEEquip.EQUIP_CAN_NOT_EMPTY), 400, {x, y ,w, h})
			end
		else
			OutputItemTip(UI_OBJECT_ITEM, this.dwBox, this.dwX, nil, {x, y, w, h})
		end
	else
		if this.state == "main" or this.state == "static" then
			OutputItemTip(UI_OBJECT_ITEM, this.dwBox, this.dwX, nil, {x, y, w, h})
		elseif FEProducePanel.type ~= TYPE.COLOR then
			OutputTip(GetFormatText(g_tStrings.tFEProduce.NO_MATERIAL_DIAMON), 400, {x, y ,w, h})
		end
	end
end

function FEProducePanel.OnItemMouseLeave()
	this:SetObjectMouseOver(0)
	HideTip()
end

function FEProducePanel.OnCheckBoxCheck()
	local name = this:GetName()
	local pretype = FEProducePanel.type
	if name == "CheckBox_Produce" then
		FEProducePanel.type = TYPE.DIAMOND
		FEProducePanel.UpdateCheckBox()
		FEProducePanel.Adjust(this:GetRoot(), pretype)
		FEProducePanel.Update(this:GetParent())
	elseif name == "CheckBox_Equip" then
		FEProducePanel.type = TYPE.EQUIPMENT
		FEProducePanel.UpdateCheckBox()
		FEProducePanel.Adjust(this:GetRoot(), pretype)
		FEProducePanel.Update(this:GetParent())
	elseif name == "CheckBox_ColorStone" then
		FEProducePanel.type = TYPE.COLOR
		FEProducePanel.UpdateCheckBox()
		FEProducePanel.Adjust(this:GetRoot(), pretype)
		FEProducePanel.FormatColorDiamondText(this:GetRoot())
		FEProducePanel.FormatColorDiamondCost(this:GetRoot())
		FEProducePanel.Update(this:GetParent())
	end
end

function FEProducePanel.OnCheckBoxUncheck()
	FEProducePanel.UpdateCheckBox()
end

function FEProducePanel.Adjust(frame, pretype)
	if not frame then
		frame = Station.Lookup("Normal/FEProducePanel")
	end
	
	local handle = frame:Lookup("", "")
	local box = handle:Lookup("Box_FE")

	if box.type == "diamond" and FEProducePanel.type ~= TYPE.DIAMOND then
		FEProducePanel.ResetBox(box, "FEProduce")
	elseif box.type == "equipment" and FEProducePanel.type ~= TYPE.EQUIPMENT then
		FEProducePanel.ResetBox(box, "FEEquip")
	elseif box.type == "color" and FEProducePanel.type ~= TYPE.COLOR then
		FEProducePanel.ResetBox(box, "FEColorDiamond")
	end
	
	if FEProducePanel.type == TYPE.COLOR or pretype == TYPE.COLOR then
		FEProducePanel.ResetBox(box, "FEProduce")
		FEProducePanel.ResetBox(box, "FEEquip")
		FEProducePanel.ResetBox(box, "FEColorDiamond")
		for i = 1, BOX_COUNT do
			local box1 = frame:Lookup("", "Handle_Item"):Lookup("Box_Item" .. i)
			FEProducePanel.ResetBox(box1, "FEProduce" .. "Box_Item" .. i)
		end
	end
	
	FEProducePanel.ResetStatic(frame)
end

function FEProducePanel.CloseInfoPanel()
	local frame = Station.Lookup("Normal/FEEquipInfoPanel")
	
	if not frame then
		return
	end
	
	Wnd.CloseWindow("FEEquipInfoPanel")
end

function FEProducePanel.ClearMaterial(frame)
	local handle = frame:Lookup("", "Handle_Item")
	for i = 1, BOX_COUNT do
		local box = handle:Lookup("Box_Item" .. i)
		FEProducePanel.ResetBox(box, "FEProduce" .. "Box_Item" .. i)
	end
end

function FEProducePanel.OpenInfoPanel(x, y)
	if IsOptionOrOptionChildPanelOpened() then
		return
	end
	
	local frame = Station.Lookup("Normal/FEEquipInfoPanel")
	if frame then
		return
	end
	
	frame = Wnd.OpenWindow("FEEquipInfoPanel")
	frame:SetRelPos(x - 4, y + 40)
end

function FEProducePanel.OutputInfo(text)
	local frame = Station.Lookup("Normal/FEEquipInfoPanel")
	if not frame then
		return
	end
	
	local handle = frame:Lookup("", "Handle_Message")
	handle:Clear()
	handle:AppendItemFromString(text)
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

function FEProducePanel.Update(frame)
	if not frame then
		frame = Station.Lookup("Normal/FEProducePanel")
	end
	
	local player = GetClientPlayer()
	if not player then
		return
	end
	
	local handle = frame:Lookup("", "")
	local box = handle:Lookup("Box_FE")
	local text = handle:Lookup("Text_Produce")
	local btn = frame:Lookup("Btn_Making")
	local btn2 = frame:Lookup("Btn_Making_2")
	local btn3 = frame:Lookup("Btn_Making_3")
	
	FEProducePanel.CloseInfoPanel()
	
	if FEProducePanel.type == TYPE.DIAMOND then
		text:SetText(g_tStrings.tFEProduce.NO_MOTHER_DIAMON)
	elseif FEProducePanel.type == TYPE.EQUIPMENT then
		text:SetText(g_tStrings.tFEProduce.NO_EQUIPMENT)
	elseif FEProducePanel.type == TYPE.COLOR then
		text:SetText(g_tStrings.tFEProduce.NO_COLOR_DIAMON)
	end
	
	if box.type == "none" then
		return
	end
	
	local item = GetPlayerItem(player, box.dwBox, box.dwX)
	if not item then
		return
	end
	local level = item.nDetail
	local level_strength = item.nStrengthLevel
	local itemInfo = GetItemInfo(item.dwTabType, item.dwIndex)
	
	box.nDetail = level
	box.nStrengthLevel = level_strength
	
	--btn:Enable(false)
	btn2:Enable(false)
	btn3:Enable(false)
	if not box:IsEmpty() then
		if FEProducePanel.type == TYPE.DIAMOND then
			if level >= DIAMOND_MAX_LEVEL then
				text:SetText(g_tStrings.tFEProduce.DIAMOND_UP_TO_MAX_LEVEL)
			else
				text:SetText(FormatString(g_tStrings.tFEProduce.DIAMON_CURRENT_LEVEL, level))
			end
		elseif FEProducePanel.type == TYPE.EQUIPMENT then
			local x, y = frame:GetRelPos()
			local w, h = frame:GetSize()
			FEProducePanel.OpenInfoPanel(x + w, y)
		
			if level_strength >= itemInfo.nMaxStrengthLevel then
				text:SetText(g_tStrings.tFEEquip.UP_TO_MAX_LEVEL)
				FEProducePanel.CloseInfoPanel()
			else
				text:SetText(FormatString(g_tStrings.tFEEquip.CURRENT_LEVEL, item.nStrengthLevel))
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
				szTip = szTip .. GetFormatText(FormatString(g_tStrings.STR_ITEM_H_ITEM_LEVEL, item.nLevel + GetStrengthQualityLevel(item.nStrengthLevel)), 163)
				szTip = szTip .. FormatString(g_tStrings.tFEEquip.EQUIP_INFO, item.nLevel + GetStrengthQualityLevel(item.nStrengthLevel + 1))
				FEProducePanel.OutputInfo(szTip)
			end
		elseif FEProducePanel.type == TYPE.COLOR then
			text:SetText(FormatString(g_tStrings.tFEProduce.COLOR_DIAMOND_LEVEL, level))
		end
		UpdataItemBoxObject(box, box.dwBox, box.dwX, item)
	end
	
	local diamond_count, material = FEProducePanel.GetMaterialTable(frame)
	if diamond_count > 0 and diamond_count <= BOX_COUNT then
		if FEProducePanel.type == TYPE.COLOR then
			if diamond_count == CHANGE_COLOR_DIAMOND then
				btn2:Enable(true)
			elseif diamond_count == UPDATE_COLOR_DIAMOND then
				btn3:Enable(true)
			end
		else
			btn3:Enable(true)
		end
	end
	
	if FEProducePanel.type == TYPE.DIAMOND then
		FEProducePanel.FormatDiamondProduceText(frame, box, level)
		FEProducePanel.FormatDiamondProduceCost(frame, box)
	elseif FEProducePanel.type == TYPE.EQUIPMENT then
		FEProducePanel.FormatEquipmentProduceText(frame, box, level_strength)
		FEProducePanel.FormatEquipmentProduceCost(frame, box)
	elseif FEProducePanel.type == TYPE.COLOR then
		FEProducePanel.FormatColorDiamondText(frame)
		FEProducePanel.FormatColorDiamondCost(frame)
	end
end

function FEProducePanel.FormatEquipmentProduceCost(frame, box)
	local diamond_count, material = FEProducePanel.GetMaterialTable(frame)
	local handle = frame:Lookup("", "")
	local goldText = handle:Lookup("Text_Gold")
	local silverText = handle:Lookup("Text_Silver")
	local cooperText = handle:Lookup("Text_Cooper")
	local goldImage = handle:Lookup("Image_Gold")
	local silverImage = handle:Lookup("Image_Silver")
	local cooperImage = handle:Lookup("Image_Cooper")
	
	handle:Lookup("Text_FE"):Show()
	handle:Lookup("Text_Money"):Show()
	
	local ret, cost = false, 0
	if diamond_count > 0 then
		ret, cost = GetStrengthEquipInfo(box.dwBox, box.dwX, material)
	end
	if not ret then
		cost = 0
	end
	local glod, silver, cooper = MoneyToGoldSilverAndCopper(cost)
	if gold == 0 then
		goldImage:Hide()
		goldText:SetText("")
	else
		goldImage:Show()
		goldText:SetText(glod)
	end
	
	if silver == 0 and gold == 0 then
		silverImage:Hide()
		silverText:SetText("")
	else
		silverImage:Show()
		silverText:SetText(silver)
	end
	
	cooperImage:Show()
	cooperText:SetText(cooper)

	handle:Lookup("Text_Money"):Show()
end

function FEProducePanel.FormatColorDiamondCost(frame)
	local handle = frame:Lookup("", "")
	handle:Lookup("Text_Gold"):SetText("")
	handle:Lookup("Text_Silver"):SetText("")
	handle:Lookup("Text_Cooper"):SetText("")
	handle:Lookup("Image_Gold"):Hide()
	handle:Lookup("Image_Silver"):Hide()
	handle:Lookup("Image_Cooper"):Hide()
end

function FEProducePanel.FormatDiamondProduceCost(frame, box)
	local diamond_count, material = FEProducePanel.GetMaterialTable(frame)
	local handle = frame:Lookup("", "")
	local goldText = handle:Lookup("Text_Gold")
	local silverText = handle:Lookup("Text_Silver")
	local cooperText = handle:Lookup("Text_Cooper")
	local goldImage = handle:Lookup("Image_Gold")
	local silverImage = handle:Lookup("Image_Silver")
	local cooperImage = handle:Lookup("Image_Cooper")
	
	local ret, cost, stamina = GetDiamondUpdateCost(box.dwBox, box.dwX, material)
	if not ret then
		cost = 0
	end
	local glod, silver, cooper = MoneyToGoldSilverAndCopper(cost)
	if gold == 0 then
		goldImage:Hide()
		goldText:SetText("")
	else
		goldImage:Show()
		goldText:SetText(glod)
	end
	
	if silver == 0 and gold == 0 then
		silverImage:Hide()
		silverText:SetText("")
	else
		silverImage:Show()
		silverText:SetText(silver)
	end
	
	cooperImage:Show()
	cooperText:SetText(cooper)

	handle:Lookup("Text_Money"):Show()
	FEProducePanel.stamina = stamina
end

function FEProducePanel.FormatEquipmentProduceText(frame, box, level)
	local diamond_count, material = FEProducePanel.GetMaterialTable(frame)
	local handle = frame:Lookup("", "")
	local text1 = handle:Lookup("Text_Tip01")
	local text2 = handle:Lookup("Text_Tip02")
	local text3 = handle:Lookup("Text_Tip03")
	local text_rate1 = handle:Lookup("Text_Tip01Rate")
	local text_rate2 = handle:Lookup("Text_Tip02Rate")
	local text_rate3 = handle:Lookup("Text_Tip03Rate")
	
	local rate = 0
	if diamond_count > 0 and diamond_count <= BOX_COUNT then
		_, _, rate, stamina = GetStrengthEquipInfo(box.dwBox, box.dwX, material)
	end
	
	local szText = ""
	local szTextTipRate = ""
	local oneRate = rate / MILLION_NUMBER * 100
	local blank = ""
	
	if oneRate >= 100 then
		blank = "" 
	elseif oneRate >= 10 then
		blank = "   "
	else
		blank = "     "
	end
	
	if level < box.nMaxStrengthLevel then
		szText = FormatString(g_tStrings.tFEProduce.DIAMON_UPDATE, level + 1)
		szTextTipRate = FormatString(g_tStrings.tFEProduce.DIAMON_RATE, blank, string.format("%.2f", oneRate))
	end
	
	text1:SetText(szText)
	text2:SetText("")
	text3:SetText("")
	text_rate1:SetText(szTextTipRate)
	text_rate2:SetText("")
	text_rate3:SetText("")
	
	FEProducePanel.rate = rate
	FEProducePanel.stamina = stamina
end

function FEProducePanel.FormatColorDiamondText(frame)
	local handle = frame:Lookup("", "")
	handle:Lookup("Text_Tip01"):SetText("")
	handle:Lookup("Text_Tip02"):SetText("")
	handle:Lookup("Text_Tip03"):SetText("")
	handle:Lookup("Text_Tip01Rate"):SetText("")
	handle:Lookup("Text_Tip02Rate"):SetText("")
	handle:Lookup("Text_Tip03Rate"):SetText("")
	handle:Lookup("Text_FE"):Hide()
	handle:Lookup("Text_Money"):Hide()
	handle:Lookup("Text_CSTip1"):Show()
	handle:Lookup("Text_CSTip2"):Show()
end

function FEProducePanel.FormatDiamondProduceText(frame, box, level)
	local handle = frame:Lookup("", "")
	local diamond_count, material = FEProducePanel.GetMaterialTable(frame)
	
	local text1 = handle:Lookup("Text_Tip01")
	local text2 = handle:Lookup("Text_Tip02")
	local text3 = handle:Lookup("Text_Tip03")
	local text_rate1 = handle:Lookup("Text_Tip01Rate")
	local text_rate2 = handle:Lookup("Text_Tip02Rate")
	local text_rate3 = handle:Lookup("Text_Tip03Rate")
	
	handle:Lookup("Text_FE"):Show()
	handle:Lookup("Text_Money"):Show()
	
	local rate1, rate2 = 0, 0
	if diamond_count > 0 and diamond_count <= BOX_COUNT then
		_, rate1, rate2 = GetDiamondUpdateRate(box.dwBox, box.dwX, material)
	end
	
	local szText1 = ""
	local szText2 = ""
	local szText3 = ""
	local szTextTipRate1 = ""
	local szTextTipRate2 = ""
	local szTextTipRate3 = ""
	local oneRate = rate1 / MILLION_NUMBER * 100
	local twoRate = rate2 / MILLION_NUMBER * 100
	local totalRate = oneRate + twoRate
	local oneBlank = ""
	local twoBlank = ""
	local totalBlank = ""
	
	if oneRate >= 100 then
		oneBlank = "" 
	elseif oneRate >= 10 then
		oneBlank = "   "
	else
		oneBlank = "     "
	end
	if twoRate >= 100 then
		twoBlank = "" 
	elseif twoRate >= 10 then
		twoBlank = "   "
	else 
		twoBlank = "     "
	end
	if totalRate >= 100 then
		totalBlank = "" 
	elseif totalRate >= 10 then
		totalBlank = "   "
	else 
		totalBlank = "     "
	end
	
	if level == DIAMOND_MAX_LEVEL then
		szText1 = ""
	elseif level == DIAMOND_MAX_LEVEL - 1 then
		szText1 = FormatString(g_tStrings.tFEProduce.DIAMON_UPDATE, level + 1)
		szTextTipRate1 = FormatString(g_tStrings.tFEProduce.DIAMON_RATE, oneBlank, string.format("%.2f", oneRate))
		szText3 = g_tStrings.tFEProduce.PRODUCE_TOTAL_RATE
		szTextTipRate3 = FormatString(g_tStrings.tFEProduce.DIAMON_TOTAL_RATE, totalBlank, string.format("%.2f", totalRate))
	else
		szText1 = FormatString(g_tStrings.tFEProduce.DIAMON_UPDATE, level + 1)
		szTextTipRate1 = FormatString(g_tStrings.tFEProduce.DIAMON_RATE, oneBlank, string.format("%.2f", oneRate))
		szText2 = FormatString(g_tStrings.tFEProduce.DIAMON_UPDATE, level + 2)
		szTextTipRate2 = FormatString(g_tStrings.tFEProduce.DIAMON_RATE, twoBlank, string.format("%.2f", twoRate))
		szText3 = g_tStrings.tFEProduce.PRODUCE_TOTAL_RATE
		szTextTipRate3 = FormatString(g_tStrings.tFEProduce.DIAMON_TOTAL_RATE, totalBlank, string.format("%.2f", totalRate))
	end
	text1:SetText(szText1)
	text2:SetText(szText2)
	text3:SetText(szText3)
	text_rate1:SetText(szTextTipRate1)
	text_rate2:SetText(szTextTipRate2)
	text_rate3:SetText(szTextTipRate3)
	
	FEProducePanel.rate = rate1 + rate2
end

function FEProducePanel.GetMaterialTable(frame)
	local diamond_count = 0
	local material = {}
	local handle = frame:Lookup("", "Handle_Item")
	
	for i = 1, BOX_COUNT do
		local box = handle:Lookup("Box_Item" .. i)
		if box.state == "main" or box.state == "static" then
			table.insert(material, {box.dwBox, box.dwX})
			diamond_count = diamond_count + 1
		end
	end
	
	return diamond_count, material
end

function FEProducePanel.AddDiamond(box, box_dsc, hand_count, bhand)
	if not box or not box_dsc then
		return
	end
	
	local player = GetClientPlayer()
	if not player then
		return
	end
	
	local box_type = box_dsc:GetObjectType()
	local _, bbox, xbox = box_dsc:GetObjectData()
	
	if box_type ~= UI_OBJECT_ITEM or (not bbox or bbox < INVENTORY_INDEX.PACKAGE or bbox > INVENTORY_INDEX.PACKAGE4) then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFEProduce.ITEM_NEED_IN_PACKAGE)
		return
	end
	
	local item = GetPlayerItem(player, bbox, xbox)
	if not item then
		return
	end
	
	local box_fe = box:GetRoot():Lookup("", ""):Lookup("Box_FE")
	
	if FEProducePanel.type == TYPE.COLOR then
			if item.nGenre ~= ITEM_GENRE.COLOR_DIAMOND or box_fe.nDetail ~= item.nDetail then
				OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFECommon.MATERIAL_JUST_FOR_COLOR_DIAMON)
				return
			end
	else
		if item.nGenre ~= ITEM_GENRE.DIAMOND then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFECommon.MATERIAL_JUST_FOR_DIAMON)
			return
		end
	end
	
	local count = 1
	if item.bCanStack then
		count = item.nStackNum
	end
	
	if hand_count and hand_count ~= count then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFECommon.DIAMON_UNPACK)
		return
	end
	
	local ebox_count = FEProducePanel.GetEmptyBoxCount(box:GetParent())
	if ebox_count < count then
		if FEProducePanel.type == TYPE.COLOR then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFECommon.COLOR_BOX_FULL)
		else
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFECommon.MATERIAL_BOX_FULL)
		end
		return
	end
	
	local name = "Box_Item" .. BOX_COUNT - ebox_count + 1
	local ebox = box:GetParent():Lookup(name)
	ebox.szName = item.szName
	ebox.dwBox = bbox
	ebox.dwX   = xbox
	ebox.nCount = count
	ebox.state = "main"
	ebox:SetObject(UI_OBJECT_ITEM, item.nUiId, bbox, xbox, item.nVersion, item.dwTabType, item.dwIndex)	
	ebox:SetObjectIcon(Table_GetItemIconID(item.nUiId))
	ebox:SetOverText(0, "")
	
	if ebox:IsObjectMouseOver() then
		local x, y = ebox:GetAbsPos()
		local w, h = ebox:GetSize()
		OutputItemTip(UI_OBJECT_ITEM, bbox, xbox, nil, {x, y, w, h})	
	end
	
	AddUILockItem("FEProduce" .. name, bbox, xbox)
	
	for i = BOX_COUNT - ebox_count + 2, BOX_COUNT - ebox_count + count do
		ebox = box:GetParent():Lookup("Box_Item" .. i)
		ebox.state = "static"
		ebox.IconID = Table_GetItemIconID(item.nUiId)
		ebox:SetObject(UI_OBJECT_NOT_NEED_KNOWN, 0)
		ebox:SetObjectIcon(ebox.IconID)
		ebox:EnableObject(false)
		ebox.dwBox = bbox
		ebox.dwX = xbox
	end
	
	if bhand then
		Hand_Clear(true)
	--[[else
		if IsObjectItem(box_type) then
			PlayItemSound(box_dsc:GetObjectData(), true)
		else
			PlaySound(SOUND.UI_SOUND, g_sound.TakeUpSkill)
		end
	]]
	end

	PlaySound(SOUND.UI_SOUND, g_sound.FEAddDiamond)
	
	ebox:GetRoot():Lookup("", ""):Lookup("Animate_GQ"):Hide()
	FEProducePanel.Update(box:GetRoot())
end

function FEProducePanel.PickUpActiveDiamond(box, pick)
	if pick then
		Hand_Pick(box)
	end
	
	local player = GetClientPlayer()
	if not player then
		return
	end
	
	local name = box:GetName()
	local box_si = tonumber(string.sub(name, 9, -1))
	local step = this.nCount
	
	for i = box_si, box_si + step - 1 do
		local fbox = box:GetParent():Lookup("Box_Item" .. i)
		FEProducePanel.ResetBox(fbox, "FEProduce" .. "Box_Item" .. i)
	end
	
	for i = box_si + step, BOX_COUNT do
		local fbox = box:GetParent():Lookup("Box_Item" .. i)
		local tbox = box:GetParent():Lookup("Box_Item" .. i - step)
		if fbox.state == "main" then
			RemoveUILockItem("FEProduce" .. "Box_Item" .. i)
			tbox.state = "main"
			tbox.szName = fbox.szName
			tbox.dwBox = fbox.dwBox
			tbox.dwX = fbox.dwX
			tbox.nCount = fbox.nCount
			local item = GetPlayerItem(player, tbox.dwBox, tbox.dwX)
			if not item then
				return
			end
			tbox:SetObject(UI_OBJECT_ITEM, item.nUiId, tbox.dwBox, tbox.dwX, item.nVersion, item.dwTabType, item.dwIndex)	
			tbox:SetObjectIcon(Table_GetItemIconID(item.nUiId))
			tbox:SetOverText(0, "")
			tbox:EnableObject(true)
			AddUILockItem("FEProduce" .. "Box_Item" .. i - step, tbox.dwBox, tbox.dwX)
		elseif fbox.state == "static" then
			tbox.state = "static"
			tbox.dwBox = fbox.dwBox
			tbox.dwX = fbox.dwX
			tbox.nCount = fbox.nCount
			tbox.IconID = fbox.IconID
			tbox:SetObject(UI_OBJECT_NOT_NEED_KNOWN, 0)
			tbox:SetObjectIcon(fbox.IconID)
			tbox:EnableObject(false)
		end
		fbox:ClearObject()
		fbox:SetOverText(0, "")
		fbox:EnableObject(true)
		fbox.state = "empty"
	end
end

function FEProducePanel.Init(frame)
	if not frame then
		frame = Station.Lookup("Normal/FEProducePanel")
	end
	
	local handle = frame:Lookup("", "")
	local box_main = handle:Lookup("Box_FE")
	local handle_item = frame:Lookup("", "Handle_Item")
	local btn_make = frame:Lookup("Btn_Making")
	local btn2 = frame:Lookup("Btn_Making_2")
	local btn3 = frame:Lookup("Btn_Making_3")
	
	FEProducePanel.ResetBox(box_main, "FEProduce")
	FEProducePanel.ResetBox(box_main, "FEEquip")
	FEProducePanel.ResetBox(box_main, "FEColorDiamond")
	for i = 1, BOX_COUNT do
		local box = handle_item:Lookup("Box_Item" .. i)
		FEProducePanel.ResetBox(box, "FEProduce" .. "Box_Item" .. i)
	end
	
	FEProducePanel.ResetStatic(frame)
	FEProducePanel.UpdateCheckBox(frame)
	FEProducePanel.ResetAnimation(frame)
	
	btn_make:Hide()
	btn2:Enable(false)
	btn3:Enable(false)
end

function FEProducePanel.ResetAnimation(frame)
	local handle = frame:Lookup("", "")
	local handle_item = frame:Lookup("", "Handle_Item")
	
	handle:Lookup("Animate_GQ"):Hide()
	handle:Lookup("Animate_QH"):Hide()
	for i = 1, BOX_COUNT do
		handle_item:Lookup("Animate_Item" .. i):Hide()
	end
end

function FEProducePanel.UpdateCheckBox(frame)
	if not frame then
		frame = Station.Lookup("Normal/FEProducePanel")
	end
	
	local ck_diamond = frame:Lookup("CheckBox_Produce")
	local ck_equipment = frame:Lookup("CheckBox_Equip")
	local ck_color = frame:Lookup("CheckBox_ColorStone")
	
	if FEProducePanel.type == TYPE.DIAMOND then
		ck_diamond:Check(true)
		ck_equipment:Check(false)
		ck_color:Check(false)
	elseif FEProducePanel.type == TYPE.EQUIPMENT then
		ck_diamond:Check(false)
		ck_equipment:Check(true)
		ck_color:Check(false)
	elseif FEProducePanel.type == TYPE.COLOR then
		ck_diamond:Check(false)
		ck_equipment:Check(false)
		ck_color:Check(true)
	end
end

function FEProducePanel.ResetBox(box, name)
	box.state = "empty"
	box.type = "none"
	box.dwBox = 0
	box.dwX = 0
	box.nCount = 0
	
	RemoveUILockItem(name)
	
	box:ClearObject()
	box:SetOverText(0, "")
	box:EnableObject(true)
end

function FEProducePanel.GetEmptyBoxCount(handle)
	local count = 0
	for i = 1, BOX_COUNT do
		local box = handle:Lookup("Box_Item" .. i)
		if box.state == "empty" then
			count = count + 1
		end
	end
	return count
end

function FEProducePanel.ResetStatic(frame)
	if not frame then
		frame = Station.Lookup("Normal/FEProducePanel")
	end
	
	local handle = frame:Lookup("", "")
	
	handle:Lookup("Text_Tip01"):SetText("")
	handle:Lookup("Text_Tip02"):SetText("")
	handle:Lookup("Text_Tip03"):SetText("")
	handle:Lookup("Text_Tip01Rate"):SetText("")
	handle:Lookup("Text_Tip02Rate"):SetText("")
	handle:Lookup("Text_Tip03Rate"):SetText("")
	handle:Lookup("Text_FE"):Show()
	handle:Lookup("Text_Money"):Show()
	handle:Lookup("Text_CSTip1"):Hide()
	handle:Lookup("Text_CSTip2"):Hide()
	
	handle:Lookup("Text_Gold"):SetText("")
	handle:Lookup("Text_Silver"):SetText("")
	handle:Lookup("Text_Cooper"):SetText("0")
	
	handle:Lookup("Image_Gold"):Hide()
	handle:Lookup("Image_Silver"):Hide()
	handle:Lookup("Image_Cooper"):Show()
	
	if FEProducePanel.type == TYPE.DIAMOND then
		handle:Lookup("Text_Produce"):SetText(g_tStrings.tFEProduce.NO_MOTHER_DIAMON)
	elseif FEProducePanel.type == TYPE.EQUIPMENT then
		handle:Lookup("Text_Produce"):SetText(g_tStrings.tFEProduce.NO_EQUIPMENT)
	elseif FEProducePanel.type == TYPE.COLOR then
		FEProducePanel.FormatColorDiamondText(frame)
		handle:Lookup("Text_Produce"):SetText(g_tStrings.tFEProduce.NO_COLOR_DIAMON)
	end
end

function FEProducePanel.Produce(btn)
	local frame = btn:GetRoot()
	local box = frame:Lookup("", ""):Lookup("Box_FE")
	
	if FEProducePanel.type == TYPE.DIAMOND then
		FEProducePanel.ProduceDiamond(frame, box)
	elseif FEProducePanel.type == TYPE.EQUIPMENT then
		FEProducePanel.ProduceEquipment(frame, box)
	end
end

function FEProducePanel.GetSureBoxMsg()
	local msg = ""
	local rate1 = FEProducePanel.rate / MILLION_NUMBER
	local rate2 = 1 - rate1
	local stamina = FEProducePanel.stamina
	
	rate1 = rate1 * 100
	rate2 = rate2 * 100
	
	msg = FormatString(g_tStrings.tFEProduce.SURE_STRING, string.format("%.2f", rate1), string.format("%.2f", rate2), tostring(stamina))
	
	return msg
end

function FEProducePanel.ChangeColorDiamond(btn)
	local frame = btn:GetRoot()
	local handle = frame:Lookup("", "")
	local box = handle:Lookup("Box_FE")
	local szMsg = ""
	
	if box:IsEmpty() then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFEProduce.MAIN_COLOR_DIAMOND_CAN_NOT_EMPTY)
		return
	end
	
	local player = GetClientPlayer()
	if not player then
		return
	end
	
	local item = GetPlayerItem(player, box.dwBox, box.dwX)
	if not item then
		return
	end
	
	local diamond_count, material = FEProducePanel.GetMaterialTable(frame)
	if diamond_count ~= CHANGE_COLOR_DIAMOND then
		OutputMessage("MSG_ANNOUNCE_RED", FormatString(g_tStrings.tFEProduce.CHANGE_COLOR_NUMBER, CHANGE_COLOR_DIAMOND))
		return
	end
	
	local fn = function()
		RemoteCallToServer("OnChangeColorDiamond", box.dwBox, box.dwX, material)
		FEProducePanel.Update(frame)
	end
	
	local tRet = GetChangeColorDiamondInfo(box.nDetail)
	if not tRet then
		local nLevel = GetMaxChangeColorDiamondLevel()
		if nLevel < item.nDetail then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFEProduce.COLOR_DIAMOND_LEVEL_MAX_CHANGE)
		else
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFEProduce.CHANGE_COLOR_DIAMOND_FAILED)
		end
		return
	end
	
	local glod, silver, cooper = MoneyToGoldSilverAndCopper(tRet.nNeedMoney)
	glod = glod or 0
	silver = silver or 0
	cooper = cooper or 0
	
	szMsg = FormatString(g_tStrings.tFEProduce.CHANGE_COLOR_MSG, glod, silver, cooper, tRet.nNeedStamina)
	
	local msg = {
		bRichText = true,
		szMessage = szMsg, 
		szName = "ChangeColorDiamond", 
		fnAutoClose = function() if not IsFEProducePanelOpened() then return true end end,
		{szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = fn, szSound = g_sound.Trade},
		{szOption = g_tStrings.STR_HOTKEY_CANCEL}
	}
	
	MessageBox(msg)
end

function FEProducePanel.UpdateColorDiamond(btn)
	local frame = btn:GetRoot()
	local handle = frame:Lookup("", "")
	local box = handle:Lookup("Box_FE")
	local szMsg = ""
	
	if box:IsEmpty() then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFEProduce.MAIN_COLOR_DIAMOND_CAN_NOT_EMPTY)
		return
	end
	
	local player = GetClientPlayer()
	if not player then
		return
	end
	
	local item = GetPlayerItem(player, box.dwBox, box.dwX)
	if not item then
		return
	end
	
	local diamond_count, material = FEProducePanel.GetMaterialTable(frame)
	if diamond_count ~= UPDATE_COLOR_DIAMOND then
		OutputMessage("MSG_ANNOUNCE_RED", FormatString(g_tStrings.tFEProduce.UPDATE_COLOR_NUMBER, UPDATE_COLOR_DIAMOND))
		return
	end
	
	local fn = function()
		RemoteCallToServer("OnUpdateColorDiamond", box.dwBox, box.dwX, material)
		FEProducePanel.Update(frame)
	end
	
	local tRet = GetUpdateColorDiamondInfo(box.nDetail)
	if not tRet then
		local nLevel = GetMaxUpdateColorDiamondLevel()
		if nLevel < item.nDetail then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFEProduce.COLOR_DIAMOND_LEVEL_MAX_UPDATE)
		else
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFEProduce.UPADTE_COLOR_DIAMOND_FAILED)
		end
		return
	end
	
	local glod, silver, cooper = MoneyToGoldSilverAndCopper(tRet.nNeedMoney)
	glod = glod or 0
	silver = silver or 0
	cooper = cooper or 0
	
	szMsg = FormatString(g_tStrings.tFEProduce.UPDATE_COLOR_MSG, glod, silver, cooper, tRet.nNeedStamina)
	
	local msg = {
		bRichText = true,
		szMessage = szMsg, 
		szName = "UpdateColorDiamond", 
		fnAutoClose = function() if not IsFEProducePanelOpened() then return true end end,
		{szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = fn, szSound = g_sound.Trade},
		{szOption = g_tStrings.STR_HOTKEY_CANCEL}
	}
	
	MessageBox(msg)
end

function FEProducePanel.ProduceDiamond(frame, box)
	if box:IsEmpty() then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFEProduce.MAIN_DIAMON_CAN_NOT_EMPTY)
		return
	end
	
	local diamond_count, material = FEProducePanel.GetMaterialTable(frame)
	if diamond_count == 0 then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFECommon.ATLEAST_ONE_MATERIAL)
		return
	end
	
	local fn = function()
		RemoteCallToServer("OnUpdateDiamond", box.dwBox, box.dwX, material)
		FEProducePanel.Update(frame)
	end
	
	local msg = {
		bRichText = true,
		szMessage = FEProducePanel.GetSureBoxMsg(), 
		szName = "ProduceDiamondSure", 
		fnAutoClose = function() if not IsFEProducePanelOpened() then return true end end,
		{szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = fn, szSound = g_sound.Trade},
		{szOption = g_tStrings.STR_HOTKEY_CANCEL}
	}
	
	MessageBox(msg)
end

function FEProducePanel.ProduceEquipment(frame, box)
	local player = GetClientPlayer()
	if not player then
		return
	end
	
	if box:IsEmpty() then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFEEquip.EQUIP_CAN_NOT_EMPTY)
		return
	end
	
	local diamond_count, material = FEProducePanel.GetMaterialTable(frame)
	if diamond_count == 0 then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFECommon.ATLEAST_ONE_MATERIAL)
		return
	end
	
	local item = GetPlayerItem(player, box.dwBox, box.dwX)
	if not item then
		return
	end
	
	box.nStrengthLevel = item.nStrengthLevel
	
	local fn = function()
		RemoteCallToServer("OnStrengthEquip", box.dwBox, box.dwX, material)
		FEProducePanel.Update(frame)
	end
	
	local msg = {
		bRichText = true,
		szMessage = FEProducePanel.GetSureBoxMsg(), 
		szName = "ProduceEquipmentSure", 
		fnAutoClose = function() if not IsFEProducePanelOpened() then return true end end,
		{szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = fn, szSound = g_sound.Trade},
		{szOption = g_tStrings.STR_HOTKEY_CANCEL}
	}
	
	MessageBox(msg)
end

function FEProducePanel.OnExchangeBoxItem(box, box_dsc, hand_count, bhand)
	if not box or not box_dsc then
		return
	end
	
	local player = GetClientPlayer()
	if not player then
		return
	end
	
	local box_dec_type = box_dsc:GetObjectType()
	local _, bbox, xbox = box_dsc:GetObjectData()
	
	if box_dec_type ~= UI_OBJECT_ITEM or not bbox or bbox < INVENTORY_INDEX.PACKAGE 
		or bbox > INVENTORY_INDEX.PACKAGE4 then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFEProduce.ITEM_NEED_IN_PACKAGE)
		return
	end
	
	local item = GetPlayerItem(player, bbox, xbox)
	if not item then
		return
	end
	
	local count = 1
	if item.bCanStack then
		count = item.nStackNum
	end
	
	if FEProducePanel.type == TYPE.DIAMOND then
		if item.nGenre ~= ITEM_GENRE.DIAMOND then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFEProduce.MAIN_BOX_JUST_FOR_DIAMON)
			return
		end
		
		if item.nDetail == DIAMOND_MAX_LEVEL or item.nDetail > DIAMOND_MAX_LEVEL then
			OutputMessage("MSG_ANNOUNCE_YELLOW", g_tStrings.tFEProduce.DIAMOND_UP_TO_MAX_LEVEL)
			return
		end
		
		if count > 1 then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFEProduce.MAIN_DIAMON_CAN_NOT_STACKED)
			return
		elseif hand_count and hand_count ~= count then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFECommon.DIAMON_UNPACK)
			return
		end
		
		if not box:IsEmpty() then
			RemoveUILockItem("FEProduce")
		end
		box.szName = item.szName
		box.dwBox = bbox
		box.dwX   =	xbox
		box.nCount = count
		box.state = "main"
		box.type = "diamond"
		box.nDetail = item.nDetail
		
		AddUILockItem("FEProduce", bbox, xbox)
		PlaySound(SOUND.UI_SOUND, g_sound.FEAddMainDiamond)
	elseif FEProducePanel.type == TYPE.EQUIPMENT then
		if item.nGenre ~= ITEM_GENRE.EQUIPMENT then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFEEquip.JUST_FOR_EQUIP)
			return
		end
		
		local item_hit = false
		for _, v in ipairs(EQUIP_TYPE) do
			if item.nSub == EQUIPMENT_SUB[v] then
				item_hit = true
				break
			end
		end
		if not item_hit then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFEEquip.JUST_FOR_PROPERTY_EQUIP)
			return
		end
		
		local itemInfo = GetItemInfo(item.dwTabType, item.dwIndex)
		
		if item.nStrengthLevel >= itemInfo.nMaxStrengthLevel then
			OutputMessage("MSG_ANNOUNCE_YELLOW", g_tStrings.tFEEquip.UP_TO_MAX_LEVEL)
			return
		end
		
		if not box:IsEmpty() then
			RemoveUILockItem("FEEquip")
		end
		
		box.szName = item.szName
		box.dwBox = bbox
		box.dwX = xbox
		box.nCount = hand_count
		box.nMaxStrengthLevel = itemInfo.nMaxStrengthLevel
		box.state = "main"
		box.type = "equipment"
		box.nStrengthLevel = item.nStrengthLevel
		
		box:GetRoot():Lookup("", ""):Lookup("Animate_GQ"):Hide()
		
		AddUILockItem("FEEquip", bbox, xbox)
		if IsObjectItem(box_dec_type) then
			PlayItemSound(box_dsc:GetObjectData(), true)
		else
			PlaySound(SOUND.UI_SOUND, g_sound.TakeUpSkill)
		end
	elseif FEProducePanel.type == TYPE.COLOR then
		if item.nGenre ~= ITEM_GENRE.COLOR_DIAMOND then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFEProduce.MAIN_BOX_JUST_FOR_COLOR_DIAMON)
			return
		end
		
		if count > 1 then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFEProduce.MAIN_COLOR_DIAMON_CAN_NOT_STACKED)
			return
		elseif hand_count and hand_count ~= count then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFECommon.DIAMON_UNPACK)
			return
		end
		
		if not box:IsEmpty() then
			RemoveUILockItem("FEColorDiamond")
		end
		box.szName = item.szName
		box.dwBox = bbox
		box.dwX   =	xbox
		box.nCount = count
		box.state = "main"
		box.type = "color"
		box.nDetail = item.nDetail
		
		AddUILockItem("FEColorDiamond", bbox, xbox)
		PlaySound(SOUND.UI_SOUND, g_sound.FEAddMainDiamond)
	end
	
	if bhand then
		Hand_Clear(true)
	--[[else
		if IsObjectItem(box_dec_type) then
			PlayItemSound(box_dsc:GetObjectData(), true)
		else
			PlaySound(SOUND.UI_SOUND, g_sound.TakeUpSkill)
		end
		]]
	end
	
	UpdataItemBoxObject(box, box.dwBox, box.dwX, item)
	
	FEProducePanel.Update(box:GetRoot())
end

function FEProducePanel.RemoveAllUILock()
	RemoveUILockItem("FEProduce")
	RemoveUILockItem("FEEquip")
	RemoveUILockItem("FEColorDiamond")
	
	for i = 1, BOX_COUNT do
		RemoveUILockItem("FEProduce" .. "Box_Item" .. i)
	end
end

function FEProducePanel.ColorDiamondAdd(frame, box, count)
	local box_fe = frame:Lookup("", ""):Lookup("Box_FE")
	if box_fe:IsEmpty() then
		FEProducePanel.OnExchangeBoxItem(box_fe, box, count)
	else
		local handle = frame:Lookup("", "Handle_Item")
		local tbox = handle:Lookup("Box_Item1")
		FEProducePanel.AddDiamond(tbox, box, count)
	end
end

function FEProducePanel.DiamondProduceAdd(frame, box, count)
	local box_fe = frame:Lookup("", ""):Lookup("Box_FE")
	if box_fe:IsEmpty() then
		FEProducePanel.OnExchangeBoxItem(box_fe, box, count)
	else
		local handle = frame:Lookup("", "Handle_Item")
		local tbox = handle:Lookup("Box_Item1")
		FEProducePanel.AddDiamond(tbox, box, count)
	end
end

function FEProducePanel.EquipmentProduceAdd(frame, box, count)
	local player = GetClientPlayer()
	if not player then
		return
	end
	
	local handle = frame:Lookup("", "Handle_Item")
	local ebox = frame:Lookup("", ""):Lookup("Box_FE")
	local mbox = handle:Lookup("Box_Item1")
	
	local _, bbox, xbox = box:GetObjectData()
	local item = GetPlayerItem(player, bbox, xbox)
	if not item then
		return
	end
	
	if item.nGenre == ITEM_GENRE.EQUIPMENT then
		FEProducePanel.OnExchangeBoxItem(ebox, box, count)
	elseif item.nGenre == ITEM_GENRE.DIAMOND then
		FEProducePanel.AddDiamond(mbox, box, count)
	else
		if ebox:IsEmpty() then
			FEProducePanel.OnExchangeBoxItem(ebox, box, count)
		else	
			FEProducePanel.AddDiamond(mbox, box, count)
		end
	end
end

function FEProducePanel.PlayDisppearAnimation(frame)
	if not frame then
		frame = Station.Lookup("Normal/FEProducePanel")
	end
	local handle = frame:Lookup("", "Handle_Item")
	for i = 1, BOX_COUNT do
		local box = handle:Lookup("Box_Item" .. i)
		local animate = handle:Lookup("Animate_Item" .. i)
		if box.state ~= "empty" then
			animate:Show()
			animate:SetAnimate("ui/Image/Common/Animate.UITex", 1, 0)
		end
	end
end

function FEProducePanel.PlayUISFX(frame)
	local handle = frame:Lookup("", "")
	handle:Lookup("Animate_GQ"):Show()
	FEProducePanel.sfxon = true
	FEProducePanel.sfxtime = 5 * 16
end

function FEProducePanel.PlaySuccessAnimation(frame, lve)
	if not frame then
		frame = Station.Lookup("Normal/FEProducePanel")
	end
	local swnd = frame:Lookup("Scene_QH")
	
	if lve == 1 then
		PlaySFX(swnd, SFX1)
	elseif lve == 2 then
		PlaySFX(swnd, SFX2)
	end
	
	FEProducePanel.PlayUISFX(frame)
end

function FEProducePanel.PlayLevelupAnimation(frame)
	if not frame then
		frame = Station.Lookup("Normal/FEProducePanel")
	end
	local handle = frame:Lookup("", "")
	local animate = handle:Lookup("Animate_QH")
	animate:Show()
	animate:SetAnimate("ui/Image/UICommon/FEPanel3.UITex", 0, 0)
end

function IsFEProducePanelOpened()
	local frame = Station.Lookup("Normal/FEProducePanel")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end

function OpenFEProducePanel(bDisableSound)
	local player = GetClientPlayer()
	if not player or player.nMoveState == MOVE_STATE.ON_DEATH
		or IsOptionOrOptionChildPanelOpened() then
		return
	end
	
	CloseFEActivationPanel(true)
	CloseFEEquipExtractPanel(true)
	
	if CheckHaveLocked(SAFE_LOCK_EFFECT_TYPE.OPERATE_DIAMOND, "OPERATE_DIAMOND") then
		return
	end
	
	if not IsFEProducePanelOpened()then
		Wnd.OpenWindow("FEProducePanel")
	end
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND, g_sound.OpenFrame)
	end
	
	FireEvent("OPEN_FEPRODUCE_PANEL")
end

function CloseFEProducePanel(bDisableSound)
	FEProducePanel.RemoveAllUILock()
	
	if IsFEProducePanelOpened() then
		Wnd.CloseWindow("FEProducePanel")
		FEProducePanel.CloseInfoPanel()
	end
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND, g_sound.CloseFrame)
	end
	
	FireEvent("CLOSE_FEPRODUCE_PANEL")
end

function AddProduceItemOnBag(box, count)
	local frame = Station.Lookup("Normal/FEProducePanel")
	
	if FEProducePanel.type == TYPE.DIAMOND then
		FEProducePanel.DiamondProduceAdd(frame, box, count)
	elseif FEProducePanel.type == TYPE.EQUIPMENT then
		FEProducePanel.EquipmentProduceAdd(frame, box, count)
	elseif FEProducePanel.type == TYPE.COLOR then
		FEProducePanel.ColorDiamondAdd(frame, box, count)
	end
end