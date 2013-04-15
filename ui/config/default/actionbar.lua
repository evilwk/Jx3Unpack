ActionBar = 
{
	nPage = 1,
	bLock = false,
	aShowBg = {true, true, true, true},
	DefaultAnchor = 	
	{
		{s = "BOTTOMCENTER", rw = "Lowest1/MainBarPanel", r = "BOTTOMCENTER", x = 21, y = -24},
		{s = "BOTTOMCENTER", rw = "Lowest1/MainBarPanel", r = "BOTTOMCENTER", x = 21, y = -76},
		{s = "BOTTOMCENTER", r = "BOTTOMCENTER", x = 21, y = -128},
		{s = "BOTTOMCENTER", r = "BOTTOMCENTER", x = 21, y = -180},
	},

	Anchor = 
	{
		{s = "BOTTOMCENTER", rw = "Lowest1/MainBarPanel", r = "BOTTOMCENTER", x = 21, y = -24},
		{s = "BOTTOMCENTER", rw = "Lowest1/MainBarPanel", r = "BOTTOMCENTER", x = 21, y = -76},
		{s = "BOTTOMCENTER", r = "BOTTOMCENTER", x = 21, y = -128},
		{s = "BOTTOMCENTER", r = "BOTTOMCENTER", x = 21, y = -180},
	},
	
	AnchorTop = 
	{
		{s = "TOPCENTER", rw = "Lowest1/MainBarPanel", r = "TOPCENTER", x = 21, y = 24},
		{s = "TOPCENTER", rw = "Lowest1/MainBarPanel", r = "TOPCENTER", x = 21, y = 76},	
	},
	Size = {16, 16, 16, 16},
	Line = {1, 1, 1, 1},
	
	aSavePos = 
	{
		{0, 160, 320, 3200},
		{480, 3360, 3520, 3680},
		{640, 640, 640, 640},
		{800, 800, 800, 800},
	},
	
	tSkillIDToBox = {},
	
}
g_bActionBar_CoolDownShow = false

local aActionBarData = {}

local function SetActionBarData(box)
	local dwType, nData1, nData2, nData3, nData4, nData5, nData6 = box:GetObject()
	aActionBarData[box] = {dwType, nData1, nData2, nData3, nData4, nData5, nData6}
end

function ActionBar_GetBox(dwSkillID) 
	return ActionBar.tSkillIDToBox[dwSkillID]
end

function ActionBar.OnFrameCreate()
	this:RegisterEvent("BAG_ITEM_UPDATE")
	this:RegisterEvent("BANK_ITEM_UPDATE")
	this:RegisterEvent("SOLD_ITEM_UPDATE")
	this:RegisterEvent("SKILL_UPDATE")
	this:RegisterEvent("CRAFT_REMOVE")
	this:RegisterEvent("HOT_KEY_RELOADED")
	this:RegisterEvent("EQUIP_ITEM_UPDATE")
	this:RegisterEvent("DESTROY_ITEM")
	this:RegisterEvent("EXCHANGE_ITEM")
	this:RegisterEvent("LOADING_END")
	this:RegisterEvent("ON_ACTIONBAR_BG_SHOW")
	this:RegisterEvent("ON_SELECT_MAIN_ACTIONBAR_PAGE")
	this:RegisterEvent("ON_SET_ACTIONBAR_COUNT")
	this:RegisterEvent("ON_SET_ACTIONBAR_LINE")
	this:RegisterEvent("HAND_PICK_OBJECT")
	this:RegisterEvent("HAND_CLEAR_OBJECT")
	this:RegisterEvent("OPEN_SKILL_PANEL")
	this:RegisterEvent("CLOSE_SKILL_PANEL")
	this:RegisterEvent("CLOSE_CRAFT_BOX")
	this:RegisterEvent("ON_OPEN_ACTIONBAR")
	this:RegisterEvent("ON_CLOSE_ACTIONBAR")
	this:RegisterEvent("MAINBAR_PANEL_POS_CHANGED")
	this:RegisterEvent("MAINBAR_PANEL_ANCHOR_EDGE_CHANGED")
	this:RegisterEvent("ON_REMOVE_MACRO")
	this:RegisterEvent("ON_CHANGE_MACRO")
	
	this:RegisterEvent("UI_SCALED")
	this:RegisterEvent("ON_ENTER_CUSTOM_UI_MODE")
	this:RegisterEvent("ON_LEAVE_CUSTOM_UI_MODE")
	this:RegisterEvent("ACTIONBAR_ANCHOR_CHANGED")
	this:RegisterEvent("SWITCH_BIGSWORD")
end

function ActionBar.OnFrameDrag()
end

function ActionBar.OnFrameDragSetPosEnd()
end

function ActionBar.OnFrameDragEnd()
	this:CorrectPos()
	SetActionBarAnchor(this.nGroup, GetFrameAnchor(this))
end

function ActionBar.UpdateAnchor(frame)
	if frame.nGroup == 1 or frame.nGroup == 2 then
		local szEdge = GetMainBarPanelAnchorEdge()
		if szEdge == "TOP" then
			local anchor = ActionBar.AnchorTop[frame.nGroup]
			frame:SetPoint(anchor.s, 0, 0, anchor.rw, anchor.r, anchor.x, anchor.y)
		else
			local anchor = ActionBar.Anchor[frame.nGroup]
			frame:SetPoint(anchor.s, 0, 0, anchor.rw, anchor.r, anchor.x, anchor.y)
		end
	else
		local anchor = ActionBar.Anchor[frame.nGroup]
		frame:SetPoint(anchor.s, 0, 0, anchor.r, anchor.x, anchor.y)
		frame:CorrectPos()
	end
end

function ActionBar.UpdateCustomModeWindow(frame)
	if frame.nGroup == 3 then
		UpdateCustomModeWindow(frame, g_tStrings.ACTIONBAR3)
	elseif frame.nGroup == 4 then
		UpdateCustomModeWindow(frame, g_tStrings.ACTIONBAR4)
	else
		UpdateCustomModeWindow(frame, nil, nil, true)
	end
end

function ActionBar.Init(frame)
	local handle = frame:Lookup("", "")
	local hBg = handle:Lookup("Handle_Bg")
	local hBox = handle:Lookup("Handle_Box")
	local hText = handle:Lookup("Handle_Text")
	local hTextCool = handle:Lookup("Handle_Cool")
	hBg:Clear()
	hBox:Clear()
	hText:Clear()
	hTextCool:Clear()
	local nCount, nLine = ActionBar.Size[frame.nGroup], ActionBar.Line[frame.nGroup]
	if nLine == 0 then
		nLine = 1
	end
	local nW = math.ceil(nCount / nLine)
	local x, y, n = 0, 0, 1
	for i = 1, nLine, 1 do
		hBg:AppendItemFromString("<image>path=\"ui/Image/Minimap/Minimap.UITex\" frame=145 </image>")
		local img = hBg:Lookup(hBg:GetItemCount() - 1)
		img:SetRelPos(x, y)
		x = x + 2
		for j = 1, nW, 1 do
			if n > nCount then
				break
			end
			if n == 9 and nLine == 1 and nCount == 16 then
				hBg:AppendItemFromString("<image>path=\"ui/Image/Minimap/Minimap.UITex\" frame=144 </image>")
				local img = hBg:Lookup(hBg:GetItemCount() - 1)
				img:SetRelPos(x, y)
				x = x + 4
			end
			hBg:AppendItemFromString("<image>path=\"ui/Image/Minimap/Minimap.UITex\" frame=135 </image>")
			hBox:AppendItemFromString("<box>w=48 h=48 eventid=525311 lockshowhide=1 </box>")
			hText:AppendItemFromString("<text>w=1 h=1 lockshowhide=1 font=15</text>")
			hText:AppendItemFromString("<text>w=1 h=1 halign=2 valign=2 lockshowhide=1 font=15</text>")
			hTextCool:AppendItemFromString("<text>w=48 h=48 halign=1 valign=1 font=23</text>")
			
			local img = hBg:Lookup(hBg:GetItemCount() - 1)
			local box = hBox:Lookup(hBox:GetItemCount() - 1)
			local textKey = hText:Lookup(hText:GetItemCount() - 2)
			local textNum = hText:Lookup(hText:GetItemCount() - 1)
			local textTime = hTextCool:Lookup(hTextCool:GetItemCount() - 1)
			
			img:SetName(n)
			box:SetName(n)
			textKey:SetName(n.."Key")
			textNum:SetName(n.."Num")
			box.nIndex = n
			box.nGroup = frame.nGroup
			box.nSave = frame.nSavePos + (n - 1) * 10
			img:SetRelPos(x, y)
			box:SetRelPos(x + 1, y + 2)
			textTime:SetRelPos(x + 2, y + 3)
			
			textKey:SetRelPos(x + 1, y + 2)
			textNum:SetRelPos(x + 48, y + 49)
			x, n = x + 50, n + 1
		end
		hBg:AppendItemFromString("<image>path=\"ui/Image/Minimap/Minimap.UITex\" frame=143 </image>")
		local img = hBg:Lookup(hBg:GetItemCount() - 1)
		img:SetRelPos(x, y)
		x, y = 0, y + 52
		if n > nCount then
			break
		end
	end
	hBg:SetSize(10000, 10000)
	hBg:FormatAllItemPos()
	local w, h = hBg:GetAllItemSize()
	hBg:SetSize(w, h)
	hBox:SetSize(w, h)
	hText:SetSize(w, h)
	handle:SetSize(w, h)
	frame:SetSize(w, h)
	hBox:FormatAllItemPos()
	hText:FormatAllItemPos()
	hTextCool:FormatAllItemPos()
	ActionBar.UpdateHotkey(frame)
	ActionBar.UpdateBgShow(frame)
	ActionBar.LoadGroupSave(frame)
		
	ActionBar.UpdateAnchor(frame)
	ActionBar.UpdateCustomModeWindow(frame)
end

function ActionBar.UpdateSaveIndex(frame)
	local hBox = frame:Lookup("", "Handle_Box")
	local nCount = hBox:GetItemCount() - 1
	for i = 0, nCount, 1 do
		local box = hBox:Lookup(i)
		box.nSave = frame.nSavePos + (box.nIndex - 1) * 10
	end
end

----------左键操作-------------------
function ActionBar.OnItemLButtonDown()
	this.bDisableClick = nil
	if IsCtrlKeyDown() and not this:IsEmpty() then
		local nType = this:GetObjectType()
		if nType == UI_OBJECT_ITEM then
			local _, dwBox, dwX = this:GetObjectData()
			if IsGMPanelReceiveItem() then
				GMPanel_LinkItem(dwBox, dwX)
			else
				EditBox_AppendLinkItem(dwBox, dwX)
			end
			this.bDisableClick = true
		elseif nType == UI_OBJECT_ITEM_INFO then
			local _, nVersion, dwType, dwIndex = this:GetObjectData()
			if IsGMPanelReceiveItem() then
				GMPanel_LinkItemInfo(nVersion, dwType, dwIndex)
			else
				EditBox_AppendLinkItemInfo(nVersion, dwType, dwIndex)
			end
			this.bDisableClick = true
		elseif nType == UI_OBJECT_SKILL then
			local dwSkilID, dwSkillLevel = this:GetObjectData()
			if IsGMPanelReceiveSkill() then
				GMPanel_LinkSkill(dwSkilID, dwSkillLevel)
			else
				EditBox_AppendLinkSkill(GetClientPlayer().GetSkillRecipeKey(dwSkilID, dwSkillLevel))
			end
			this.bDisableClick = true
		elseif nType == UI_OBJECT_CRAFT then
		end
	end
	
	this:SetObjectStaring(false)
	this:SetObjectPressed(1)
end

function ActionBar.OnItemLButtonUp()
	this:SetObjectPressed(0)
end

function ActionBar.OnItemLButtonDrag()
	if not Hand_IsEmpty() then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.SRT_ERROR_DROP_HAND_OBJ_WHEN_DRAG)
		PlayTipSound("001")
		return
	end
	
	if ActionBar.bLock and not IsShiftKeyDown() then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.SRT_ERROR_LOCK_ACTIONBAR_WHEN_DRAG)
		PlayTipSound("008")
		return
	end
	
	if this:IsEmpty() then
		return
	end
	
	if IsCursorInExclusiveMode() then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.SRT_ERROR_CANCEL_CURSOR_STATE)
		PlayTipSound("010")
		return
	end
	
	Hand_Pick(this, nil, true)
	this:ClearObject()
	SetActionBarData(this)
	this:SetUserData(-1)
	ActionBar.UpdateBoxNum(this, "")
	ActionBar.UpdateBoxShow(this)
	ActionBar.Save(this)
	HideTip()
end

function ActionBar.OnItemLButtonDragEnd()
	this.bDisableClick = true
	if Hand_IsEmpty() then
		return
	end
	ActionBar.OnChangeHandAndBoxItem(this)
	
	--数据分析
	local dwType, dwID = this:GetObject()
	FireDataAnalysisEvent("DRAG_NEWBIE_SKILL", {dwType, dwID})
	FireDataAnalysisEvent("FIRST_DRAG_SKILL", {dwType, dwID})
end

function ActionBar.OnItemLButtonClick()
	if this.bDisableClick then
		this.bDisableClick = nil
		return
	end
	if Hand_IsEmpty() then
		ActionBar.OnUseActionBarObject(this)
	else
		ActionBar.OnChangeHandAndBoxItem(this)
	end
end

function ActionBar.OnItemLButtonDBClick()
	ActionBar.OnItemLButtonClick()
end

----------右键操作-------------------
function ActionBar.OnItemRButtonDown()
	this:SetObjectPressed(1)
	this:SetObjectStaring(false)
end

function ActionBar.OnItemRButtonUp()
	this:SetObjectPressed(0)
end

function ActionBar.OnItemRButtonClick()
	if not this:IsEmpty() then
		if this:GetObjectType() == UI_OBJECT_SKILL and IsShiftKeyDown() then
			local dwSkillID, dwSkillLevel = this:GetObjectData()
			OpenMystiquePanel(dwSkillID, dwSkillLevel)
		else
			ActionBar.OnUseActionBarObject(this)	
		end
	end
end

function ActionBar.OnItemRButtonDBClick()
	ActionBar.OnItemRButtonClick()
end

function ActionBar.OnUseActionBarObject(box)
	if box:IsEmpty() then
		return
	end
	box:SetObjectStaring(false)

	local t = aActionBarData[box]
	if not t then
		return
	end

	local player = GetClientPlayer()

	local nObjectType = t[1]
    if nObjectType == UI_OBJECT_ITEM_INFO then
    	local _, dwV, dwT, dwI = t[2], t[3], t[4], t[5]
    	local dwBox, dwX = player.GetItemPos(dwT, dwI)
    	if dwBox and dwX then
    		OnUseItem(dwBox, dwX, box)
    	end
    elseif nObjectType == UI_OBJECT_ITEM then
    	local _, dwBox, dwX = t[2], t[3], t[4]
		if dwBox == INVENTORY_INDEX.EQUIP then
			local item = GetPlayerItem(player, dwBox, dwX)
			if item and item.nSub == EQUIPMENT_SUB.PACKAGE then
				if IsBagPanelOpened(EquipIndexToBagPanelIndex(dwX)) then
					CloseBagPanel(EquipIndexToBagPanelIndex(dwX))
				else
					OpenBagPanel(EquipIndexToBagPanelIndex(dwX))
				end
			else
				OnUseItem(dwBox, dwX, box)
			end
		else
			local item = GetPlayerItem(player, dwBox, dwX)
			if item and item.nGenre == ITEM_GENRE.EQUIPMENT then
				if item.nSub == EQUIPMENT_SUB.BACK_EXTEND or item.nSub == EQUIPMENT_SUB.WAIST_EXTEND then
					OnUsePendentItem(dwBox, dwX)
				else			
					local eRetCode, nEquipPos = player.GetEquipPos(dwBox, dwX)
					if eRetCode == ITEM_RESULT_CODE.SUCCESS then
						OnExchangeItem(dwBox, dwX, INVENTORY_INDEX.EQUIP, nEquipPos)
						PlayItemSound(item.nUiId)
					else
						OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tItem_Msg[eRetCode])
					end
				end
			else
				OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.SRT_ERROR_CAN_NOT_EQUIP)
				PlayTipSound("009")
			end
		end
    elseif nObjectType == UI_OBJECT_SKILL then
		local dwSkillID, dwSkillLevel = t[2], t[3]
		OnUseSkill(dwSkillID, dwSkillLevel, box)
    elseif nObjectType == UI_OBJECT_CRAFT then
    	local nProID, nBranchID, nCraftID = t[2], t[3], t[4]
		OnUseCraft(nProID, nBranchID, nCraftID, box)
	elseif nObjectType == UI_OBJECT_SYS_BTN then
		local dwID = t[2]
		OnUseSysBtn(dwID)
	elseif nObjectType == UI_OBJECT_MACRO then
		local dwID = t[2]
		if CanUseMacro(dwID) then
			ExcuteMacroByID(dwID)
		else
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.SRT_ERROR_CAN_NOT_USE_MACRO)
		end
    end
end

function ActionBar.UpdateHotkey(frame)
	local hBox = frame:Lookup("", "Handle_Box")
	local hText = frame:Lookup("", "Handle_Text")
	local szCmd = "ACTIONBAR"..frame.nGroup
	local nCount = hBox:GetItemCount()
	for i = 1, nCount, 1 do
		local nKey, bShift, bCtrl, bAlt = Hotkey.Get(szCmd.."_BUTTON"..i)
		hText:Lookup(i.."Key"):SetText(GetKeyShow(nKey, bShift, bCtrl, bAlt, true))
	end
end

function ActionBar.OnItemRefreshTip()
	return ActionBar.OnItemMouseEnter()
end

function ActionBar.OnItemMouseEnter()
    if this:GetType() == "Box" then
		this:SetObjectMouseOver(1)
		ActionBar.ActionBarShowTip(this)
	end
end

function ActionBar.ActionBarShowTip(box)
	local x, y = this:GetAbsPos()
	local w, h = this:GetSize()
	local nType = box:GetObjectType()
	if nType == UI_OBJECT_ITEM then		
		local _, dwBox, dwX = box:GetObjectData()
		OutputItemTip(UI_OBJECT_ITEM, dwBox, dwX, nil, {x, y, w, h, 1}, nil, nil, nil, dwBox == INVENTORY_INDEX.EQUIP, nil)
	elseif nType == UI_OBJECT_ITEM_INFO then
		local _, nVersion, dwType, dwIndex = box:GetObjectData()
		OutputItemTip(UI_OBJECT_ITEM_INFO, nVersion, dwType, dwIndex, {x, y, w, h, 1})
	elseif nType == UI_OBJECT_SKILL then
		local dwSkilID, dwSkillLevel = box:GetObjectData()
		OutputSkillTip(dwSkilID, dwSkillLevel, {x, y, w, h, 1}, false)
	elseif nType == UI_OBJECT_CRAFT then
		local nProID, nBranchID, nCraftID = box:GetObjectData()
		OutputCraftTip(nProID, nBranchID, nCraftID, {x, y, w, h, 1})
	elseif nType == UI_OBJECT_SYS_BTN then
		local dwID = box:GetObjectData()
		local szTip = GetSysBtnTip(dwID)
		if szTip and szTip ~= "" then
			OutputAutoTipInfoByText(szTip, 2, true, x, y, w, h)
		end
	elseif nType == UI_OBJECT_MACRO then
		local dwID = box:GetObjectData()
		OutputMacroTip(dwID, {x, y, w, h, 1})
	end
end

function ActionBar.OnItemMouseLeave()
    if this:GetType() == "Box" then
		this:SetObjectMouseOver(0)
		HideTip()
	end
end

function ActionBar.OnChangeHandAndBoxItem(box)
	if not box:IsEmpty() and ActionBar.bLock and not IsShiftKeyDown() then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.SRT_ERROR_LOCK_ACTIONBAR_WHEN_DRAG)
		PlayTipSound("008")
		return
	end
	
	local player = GetClientPlayer()

	local boxHand = Hand_Get()
	local dwType, nData1, nData2, nData3, nData4, nData5, nData6 = boxHand:GetObject()
	local nIconID = boxHand:GetObjectIcon()
	
	if dwType == UI_OBJECT_ITEM then
		local item = GetPlayerItem(player, nData2,nData3)
		if not item or item.nGenre ~= ITEM_GENRE.EQUIPMENT then
			dwType, nData2, nData3, nData4 = UI_OBJECT_ITEM_INFO, nData4, nData5, nData6
		end
	elseif dwType == UI_OBJECT_ITEM_ONLY_ID then
		dwType, nData2, nData3, nData4 = UI_OBJECT_ITEM_INFO, nData3, nData4, nData5
	end

	if box:IsEmpty() then
		Hand_Clear()
	else
		Hand_Pick(box, nil, true)
	end

	box:SetObject(dwType, nData1, nData2, nData3, nData4, nData5, nData6)
	SetActionBarData(box)
	box:SetObjectIcon(nIconID)
	ActionBar.UpdateBoxNum(box, "")
	
	if dwType == UI_OBJECT_ITEM  then
		local item = GetPlayerItem(player, nData2, nData3)
		if not item then
			box:ClearObject()
			SetActionBarData(box)
			ActionBar.UpdateBoxShow(box)
			return
		end
		if item.nSub == EQUIPMENT_SUB.ARROW then
			ActionBar.UpdateBoxNum(box, item.nStackNum)
		end
		UpdateItemBoxExtend(box, item)
	elseif dwType == UI_OBJECT_ITEM_INFO then
		local itemInfo = GetItemInfo(nData3, nData4)
		if not itemInfo or itemInfo.nGenre == ITEM_GENRE.BOOK then
			OutputMessage("MSG_ANNOUNCE_RED",g_tStrings.MSG_CAN_NOT_DRAG_BOOK_IN_ACTIONBAR)
			box:ClearObject()
			SetActionBarData(box)
			ActionBar.UpdateBoxShow(box)
			return
		end
		
		local nItemCount = player.GetItemAmount(nData3, nData4)
		ActionBar.UpdateBoxNum(box, nItemCount)
		box:EnableObject(nItemCount > 0)
		UpdateItemBoxExtend(box, itemInfo)
	elseif dwType == UI_OBJECT_SKILL then
		FireHelpEvent("OnDragSkillToActionBar", nData1, nData2, box)
	end
	ActionBar.UpdateBoxShow(box)
	
	ActionBar.Save(box)
end

local function GetCoolTimeText(nLeft)
	nLeft = nLeft or 0
	local szText = ""
	local nTimeType = 2
	local nH, nM, nS = GetTimeToHourMinuteSecond(nLeft, true)
	if nH > 0 then
		if nM > 0 or nS > 0 then
			nH = nH + 1
		end
		szText = nH ..'h'
		nTimeType = 0
	elseif nM  > 0 then
		if nS > 0 then
			nM = nM+ 1
		end
		szText = nM ..'m'
		nTimeType = 1
	elseif nS >= 0 then
		szText = nS
		if nS < 11 then
			nTimeType = 2
		else
			nTimeType = 3
		end
	end
	return szText, nTimeType
end

local function ShowCoolDownTime(hText, nLeft)
	local szOld = hText:GetText() or ""
	local nS = math.floor(nLeft / 16)
	if nS == 0 and szOld == "" then
		return
	end
	
	if nLeft == 0 and szOld == "0" then
		hText:SetText("")
		return
	end
	
	if szOld == "" and nS == 1 then
		return
	end

	local szText, nTimeType = GetCoolTimeText(nLeft)
	if nTimeType == 0 then
		hText:SetFontColor(255, 255, 255)
	elseif nTimeType == 1 then
		hText:SetFontColor(255, 255, 0)
	elseif nTimeType == 2 then
		if not hText.nSpark or hText.nSpark == 7 then
			hText.nSpark = 0
			hText.bSpark = not hText.bSpark
		end
		hText.nSpark = hText.nSpark + 1
		
		if hText.bSpark then
			hText:SetFontColor(255, 255, 255)
		else
			hText:SetFontColor(255, 0, 0)
		end
	elseif nTimeType == 3 then
		hText:SetFontColor(255, 255, 0)
	end
	hText:SetText(szText)
end

function ActionBar.OnFrameBreathe()
	local player = GetClientPlayer()
    if not player then
    	return
    end
	
    local hBox = this:Lookup("", "Handle_Box")
    local nCount = hBox:GetItemCount() - 1
	local hCool= this:Lookup("", "Handle_Cool")
    for i = 0, nCount, 1 do
        local box = hBox:Lookup(i)
        local hTextCool = hCool:Lookup(i)
        local nLeftTime
        if not box:IsEmpty() then
            local nType = box:GetObjectType()
            if nType == UI_OBJECT_ITEM then
            	local _, v1, v2 = box:GetObjectData()
            	nLeftTime = UpdataItemCDProgress(player, box, v1, v2) or 0
				
            elseif nType == UI_OBJECT_ITEM_INFO then
            	local _, v1, v2, v3 = box:GetObjectData()
            	nLeftTime = UpdataItemCDProgress(player, box, v1, v2, v3) or 0
				
            elseif nType == UI_OBJECT_SKILL then
            	nLeftTime = UpdataSkillCDProgress(player, box) or 0
				local dwSkillID, dwSkillLevel = box:GetObjectData()
				box.nGroup = this.nGroup
				box.nIndex = i + 1
				ActionBar.tSkillIDToBox[dwSkillID] = box
				
            elseif nType == UI_OBJECT_CRAFT then
            	OnUpdateCraftState(player, box)
            elseif nType == UI_OBJECT_SYS_BTN then
            	local dwID = box:GetObjectData()
            	if IsSysbtnUsed(dwID) then
            		box:SetObjectSelected(true)
            	else
            		box:SetObjectSelected(false)
            	end
            elseif nType == UI_OBJECT_MACRO then
            	nLeftTime = UpdateMacroCDProgress(player, box) or 0
            end
        end
		
        if IsActionBarCoolDownShow() and nLeftTime ~= nil then
            	ShowCoolDownTime(hTextCool, nLeftTime)
        else
            	hTextCool:SetText("")
        end
    end
end

function ActionBar.OnEvent(event)
	if event == "EQUIP_ITEM_UPDATE" then
		if arg1 == EQUIPMENT_INVENTORY.MELEE_WEAPON then
			ActionBar.UpdataCommonSkillInActionBar(this, true)
		elseif arg1 == EQUIPMENT_INVENTORY.RANGE_WEAPON then
			ActionBar.UpdataCommonSkillInActionBar(this, false)
		elseif arg1 == EQUIPMENT_INVENTORY.ARROW then
			ActionBar.UpdataItem(this, arg0, arg1)
		end
	elseif event == "BAG_ITEM_UPDATE" or event == "BANK_ITEM_UPDATE" or event == "SOLD_ITEM_UPDATE" then
		ActionBar.UpdataItem(this, arg0, arg1)
	elseif event == "DESTROY_ITEM" then
		ActionBar.EquipItemPosChanged(this, arg0, arg1, INVENTORY_INDEX.INVALID, 0)
		ActionBar.UpdataItemInActionBar(this, arg2, arg3, arg4)
	elseif event == "EXCHANGE_ITEM" then
		ActionBar.EquipItemPosChanged(this, arg0, arg1, arg2, arg3)
	elseif event == "LOADING_END" then
		ActionBar.LoadGroupSave(this)
	elseif event == "SKILL_UPDATE" then
		ActionBar.UpdataSkillInActionBar(this, arg0, arg1)
	elseif event == "CRAFT_REMOVE" then
		ActionBar.UpdataCraftInActionBar(this, arg0)
	elseif event == "HOT_KEY_RELOADED" then
		ActionBar.UpdateHotkey(this)
	elseif event == "ON_ACTIONBAR_BG_SHOW" then
		if arg0 == this.nGroup then
			ActionBar.UpdateBgShow(this)
		end
	elseif event == "ON_SELECT_MAIN_ACTIONBAR_PAGE" then
		if this.nGroup == 1 or this.nGroup == 2 then
			this.nSavePos = ActionBar.aSavePos[this.nGroup][GetMainActionBarPage()]
			ActionBar.UpdateSaveIndex(this)
			ActionBar.LoadGroupSave(this)
		end
	elseif event == "ON_SET_ACTIONBAR_COUNT" then
		if arg0 == this.nGroup then
			ActionBar.Init(this)
		end
	elseif event == "ON_SET_ACTIONBAR_LINE" then
		if arg0 == this.nGroup then
			ActionBar.Init(this)
		end
	elseif event == "HAND_PICK_OBJECT" then
		ActionBar.UpdateBgShow(this)
	elseif event == "HAND_CLEAR_OBJECT" then
		ActionBar.UpdateBgShow(this)
	elseif event == "OPEN_SKILL_PANEL" then
		ActionBar.UpdateBgShow(this)
	elseif event == "CLOSE_SKILL_PANEL" then
		ActionBar.UpdateBgShow(this)
	elseif event == "CLOSE_CRAFT_BOX" then
		ActionBar.ClosedCraftBoxRadarInActionBar(this)
	elseif event == "MAINBAR_PANEL_POS_CHANGED" or event == "MAINBAR_PANEL_ANCHOR_EDGE_CHANGED" then
		ActionBar.UpdateAnchor(this)
	elseif event == "ON_REMOVE_MACRO" then
		ActionBar.OnRemoveMacro(this, arg0)
	elseif event == "ON_CHANGE_MACRO" then
		ActionBar.OnMacroChanged(this, arg0)
	elseif event == "UI_SCALED" then
		ActionBar.UpdateAnchor(this)
	elseif event == "ON_ENTER_CUSTOM_UI_MODE" or event == "ON_LEAVE_CUSTOM_UI_MODE" then
		ActionBar.UpdateCustomModeWindow(this)
	elseif event == "ACTIONBAR_ANCHOR_CHANGED" then
		if arg0 == this.nGroup then
			ActionBar.UpdateAnchor(this)
		end
	elseif event == "SWITCH_BIGSWORD" then
		ActionBar.UpdataCommonSkillInActionBar(this, true)
	end
end

function ActionBar.OnRemoveMacro(frame, dwID)
	local hBox = frame:Lookup("", "Handle_Box")
    local nCount = hBox:GetItemCount() - 1
    for i = 0, nCount, 1 do
        local box = hBox:Lookup(i)
        if not box:IsEmpty() then
            local nType, dwMacroID = box:GetObject()
            if nType == UI_OBJECT_MACRO and dwMacroID == dwID then
				box:ClearObject()
				SetActionBarData(box)
				ActionBar.UpdateBoxShow(box)
				ActionBar.UpdateBoxNum(box, "")
            end
        end
    end
    
    if frame.nGroup ~= 1 then
    	return
    end
	for nPos = 0, 950, 10 do
		if GetUserPreferences(nPos, "c") == 6 then
        	if GetUserPreferences(nPos + 1, "d") == dwID then
				SetUserPreferences(nPos, "c", 0)
        	end
		end
	end
	for nPos = 3200, 3830, 10 do
		if GetUserPreferences(nPos, "c") == 6 then
        	if GetUserPreferences(nPos + 1, "d") == dwID then
				SetUserPreferences(nPos, "c", 0)
        	end
		end
	end
end

function ActionBar.OnMacroChanged(frame, dwID)
	local hBox = frame:Lookup("", "Handle_Box")
    local nCount = hBox:GetItemCount() - 1
    for i = 0, nCount, 1 do
        local box = hBox:Lookup(i)
        if not box:IsEmpty() then
            local nType, dwMacroID = box:GetObject()
            if nType == UI_OBJECT_MACRO and dwMacroID == dwID then
            	box:SetObjectIcon(GetMacroIcon(dwID))
            end
        end
    end
end

function ActionBar.UpdateBgShow(frame)
	local handle = frame:Lookup("", "")
	local hBg = handle:Lookup("Handle_Bg")
	local bShow = ActionBar.aShowBg[frame.nGroup]
	if not Hand_IsEmpty() or IsSkillPanelOpened() then
		bShow = true
	end
	
	frame:SetSizeWithAllChild(not bShow)
	if bShow then
		if not hBg:IsVisible() then
			hBg:Show()
			local hBox = handle:Lookup("Handle_Box")
			local hText = handle:Lookup("Handle_Text")
			local nCount = hBox:GetItemCount() - 1
			local nCountT = hText:GetItemCount() - 1
			for i = 0, nCount, 1 do
				hBox:Lookup(i):Show()
			end
			for i = 0, nCountT, 1 do
				hText:Lookup(i):Show()
			end
		end
	else
		if hBg:IsVisible() then
			hBg:Hide()
			local hBox = handle:Lookup("Handle_Box")
			local hText = handle:Lookup("Handle_Text")
			local nCount = hBox:GetItemCount() - 1
			for i = 0, nCount, 1 do
				local box = hBox:Lookup(i)
				if box:IsEmpty() then
					box:Hide()
					hText:Lookup(box.nIndex.."Num"):Hide()
					hText:Lookup(box.nIndex.."Key"):Hide()
				end
			end
		end
	end
end

function ActionBar.UpdateBoxShow(box)
	local hPP = box:GetParent():GetParent()
	local bShow = hPP:Lookup("Handle_Bg"):IsVisible() or not box:IsEmpty()
	if bShow then
		if not box:IsVisible() then
			box:Show()
			hPP:Lookup("Handle_Text/"..box.nIndex.."Num"):Show()
			hPP:Lookup("Handle_Text/"..box.nIndex.."Key"):Show()
		end
	else
		if box:IsVisible() then
			box:Hide()
			hPP:Lookup("Handle_Text/"..box.nIndex.."Num"):Hide()
			hPP:Lookup("Handle_Text/"..box.nIndex.."Key"):Hide()
		end
	end
end

function ActionBar.EquipItemPosChanged(frame, dwBox1, dwX1, dwBox2, dwX2)
	local player = GetClientPlayer()
	local hBox = frame:Lookup("", "Handle_Box")
    local nCount = hBox:GetItemCount() - 1
    for i = 0, nCount, 1 do
        local box = hBox:Lookup(i)
        if not box:IsEmpty() then
            local nType = box:GetObjectType()
            if nType == UI_OBJECT_ITEM then
            	local nData1, nData2, nData3, nData4, nData5, nData6 = box:GetObjectData()
            	if nData2 == dwBox1 and nData3 == dwX1 then
					if dwBox2 == INVENTORY_INDEX.INVALID or dwBox2 == INVENTORY_INDEX.SOLD_LIST then
						box:ClearObject()
						SetActionBarData(box)
						ActionBar.UpdateBoxShow(box)
						ActionBar.UpdateBoxNum(box, "")
					else
						local nIcon = box:GetObjectIcon()
						box:SetObject(nType, nData1, dwBox2, dwX2, nData4, nData5, nData6)
						SetActionBarData(box)
						box:SetObjectIcon(nIcon)
						local item = GetPlayerItem(player, dwBox2, dwX2)
						if item and item.nGenre == ITEM_GENRE.EQUIPMENT and item.nSub == EQUIPMENT_SUB.ARROW then
							ActionBar.UpdateBoxNum(box, item.nStackNum)
						else
							ActionBar.UpdateBoxNum(box, "")
						end
						UpdateItemBoxExtend(box, item)
					end
				elseif nData2 == dwBox2 and nData3 == dwX2 then
					if dwBox1 == INVENTORY_INDEX.INVALID or dwBox1 == INVENTORY_INDEX.SOLD_LIST then
						box:ClearObject()
						SetActionBarData(box)
						ActionBar.UpdateBoxShow(box)
						ActionBar.UpdateBoxNum(box, "")
					else
						local nIcon = box:GetObjectIcon()
						box:SetObject(nType, nData1, dwBox1, dwX1, nData4, nData5, nData6)
						SetActionBarData(box)
						box:SetObjectIcon(nIcon)
						local item = GetPlayerItem(player, dwBox1, dwX1)
						if item and item.nGenre == ITEM_GENRE.EQUIPMENT and item.nSub == EQUIPMENT_SUB.ARROW then
							ActionBar.UpdateBoxNum(box, item.nStackNum)
						else
							ActionBar.UpdateBoxNum(box, "")
						end
						UpdateItemBoxExtend(box, item)
					end
            	end
            end
        end
    end
    
    if frame.nGroup ~= 1 then
    	return
    end
	for nPos = 0, 950, 10 do
		if GetUserPreferences(nPos, "c") == 2 then
			local nB = GetUserPreferences(nPos + 1, "c")
			local nI = GetUserPreferences(nPos + 2, "c")
        	if nB == dwBox1 and nI == dwX1 then
				if dwBox2 == INVENTORY_INDEX.INVALID or
					dwBox2 == INVENTORY_INDEX.SOLD_LIST then
					SetUserPreferences(nPos, "c", 0)
				else
					SetUserPreferences(nPos, "ccc", 2, dwBox2, dwX2)
				end
			elseif nB == dwBox2 and nI == dwX2 then
				if dwBox1 == INVENTORY_INDEX.INVALID or
					dwBox1 == INVENTORY_INDEX.SOLD_LIST then
					SetUserPreferences(nPos, "c", 0)
				else
					SetUserPreferences(nPos, "ccc", 2, dwBox1, dwX1)
				end
        	end
		end
	end
	for nPos = 3200, 3830, 10 do
		if GetUserPreferences(nPos, "c") == 2 then
			local nB = GetUserPreferences(nPos + 1, "c")
			local nI = GetUserPreferences(nPos + 2, "c")
        	if nB == dwBox1 and nI == dwX1 then
				if dwBox2 == INVENTORY_INDEX.INVALID or
					dwBox2 == INVENTORY_INDEX.SOLD_LIST then
					SetUserPreferences(nPos, "c", 0)
				else
					SetUserPreferences(nPos, "ccc", 2, dwBox2, dwX2)
				end
			elseif nB == dwBox2 and nI == dwX2 then
				if dwBox1 == INVENTORY_INDEX.INVALID or
					dwBox1 == INVENTORY_INDEX.SOLD_LIST then
					SetUserPreferences(nPos, "c", 0)
				else
					SetUserPreferences(nPos, "ccc", 2, dwBox1, dwX1)
				end
        	end
		end
	end
  
end

function ActionBar.UpdataItem(frame, dwBox, dwX)
	local item = GetPlayerItem(GetClientPlayer(), dwBox, dwX)
	if not item then
		return
	end
	
	if item.nGenre == ITEM_GENRE.EQUIPMENT then
		if item.nSub == EQUIPMENT_SUB.ARROW then
			local hBox = frame:Lookup("", "Handle_Box")
		    local nCount = hBox:GetItemCount() - 1
		    for i = 0, nCount, 1 do
		        local box = hBox:Lookup(i)
		        if not box:IsEmpty() then
		            local nType = box:GetObjectType()
		            if nType == UI_OBJECT_ITEM then
		            	local _, dwTBox, dwTX = box:GetObjectData()
		            	if dwTBox == dwBox and dwTX == dwX then
		            		ActionBar.UpdateBoxNum(box, item.nStackNum)
		            	end
		            end
		        end
		    end
		end
	else
		ActionBar.UpdataItemInActionBar(frame, item.nVersion, item.dwTabType, item.dwIndex)
	end
end

function ActionBar.UpdateBoxNum(box, szNum)
	box:GetParent():GetParent():Lookup("Handle_Text/"..box.nIndex.."Num"):SetText(szNum)
end

function ActionBar.UpdataItemInActionBar(frame, nVersion, dwTableType, dwIndex)
	local hBox = frame:Lookup("", "Handle_Box")
	local nAccount = nil
    local nCount = hBox:GetItemCount() - 1
    for i = 0, nCount, 1 do
        local box = hBox:Lookup(i)
        if not box:IsEmpty() then
            local nType = box:GetObjectType()
            if nType == UI_OBJECT_ITEM_INFO then
            	local _, nV, dwT, dwI = box:GetObjectData()
            	if dwT == dwTableType and dwI == dwIndex then
            		if not nAccount then
            			nAccount = GetClientPlayer().GetItemAmount(dwTableType, dwIndex)
            		end
            		ActionBar.UpdateBoxNum(box, nAccount)
            		box:EnableObject(nAccount > 0)
            	end
            end
        end
    end
end

function ActionBar.UpdataCommonSkillInActionBar(frame, bMelee)
	local hBox = frame:Lookup("", "Handle_Box")
	local player = GetClientPlayer()
	local dwSkillID = player.GetCommonSkill(bMelee)
	if not dwSkillID or dwSkillID == 0 then
		return
	end

    local nCount = hBox:GetItemCount() - 1
    for i = 0, nCount, 1 do
        local box = hBox:Lookup(i)
        if not box:IsEmpty() then
            local nType = box:GetObjectType()
            if nType == UI_OBJECT_SKILL then    
           		local dwBoxSkillID = box:GetObjectData()
           		local bBoxCommon, bBoxMelee = IsCommonSkill(dwBoxSkillID)
           		if bBoxCommon and bBoxMelee == bMelee then
           			box:SetObject(UI_OBJECT_SKILL, dwSkillID, 1)
           			SetActionBarData(box)
           			box:SetObjectIcon(Table_GetSkillIconID(dwSkillID, 1))           		
           		end
           	end
        end
    end
end

function ActionBar.UpdataSkillInActionBar(frame, dwSkillID, dwSkillLevel)
	local hBox = frame:Lookup("", "Handle_Box")
    local nCount = hBox:GetItemCount() - 1
    for i = 0, nCount, 1 do
        local box = hBox:Lookup(i)
        if not box:IsEmpty() then
            local nType = box:GetObjectType()
            if nType == UI_OBJECT_SKILL then    
           		local dwBoxSkillID, dwBoxSkillLevel = box:GetObjectData()
           		if dwBoxSkillID == dwSkillID then
           			if dwSkillLevel == 0 then
           				box:ClearObject()
           				SetActionBarData(box)
           				ActionBar.UpdateBoxShow(box)
           			else
           				box:SetObject(UI_OBJECT_SKILL, dwSkillID, dwSkillLevel)
           				SetActionBarData(box)
           				box:SetObjectIcon(Table_GetSkillIconID(dwSkillID, dwSkillLevel))
           			end
           		end
           	end
        end
    end
    if dwSkillLevel == 0 then
	    for nPos = 0, 950, 10 do
			if GetUserPreferences(nPos, "c") == 3 and GetUserPreferences(nPos + 1, "d") == dwSkillID then
	        	SetUserPreferences(nPos, "c", 0)
			end
		end
		for nPos = 3200, 3830, 10 do
			if GetUserPreferences(nPos, "c") == 3 and GetUserPreferences(nPos + 1, "d") == dwSkillID then
	        	SetUserPreferences(nPos, "c", 0)
			end
		end		
	end
end

function ActionBar.UpdataCraftInActionBar(frame, nProID)
	local hBox = frame:Lookup("", "Handle_Box")
	local nCount = hBox:GetItemCount() - 1
    for i = 0, nCount, 1 do
        local box = handle:Lookup(i) 
        if not box:IsEmpty() then
            local nType = box:GetObjectType()
            if nType == UI_OBJECT_CRAFT then    
           		local nBoxProID, nBoxBranchID, nBoxCraftID = box:GetObjectData()
           		if nBoxProID == nProID then
           			box:ClearObject()
           			SetActionBarData(box)
           			ActionBar.UpdateBoxShow(box)
           			ActionBar.UpdateBoxNum(box, "")
           		end
           	end
        end
    end
    
    if frame.nGroup ~= 1 then
    	return
    end
    for nPos = 0, 950, 10 do
		if GetUserPreferences(nPos, "c") == 4 and GetUserPreferences(nPos + 1, "c") == nProID then
        	SetUserPreferences(nPos, "c", 0)
		end
	end
	for nPos = 3200, 3830, 10 do
		if GetUserPreferences(nPos, "c") == 4 and GetUserPreferences(nPos + 1, "c") == nProID then
        	SetUserPreferences(nPos, "c", 0)
		end
	end	
end

function ActionBar.ClosedCraftBoxRadarInActionBar(frame)
	local hBox = frame:Lookup("", "Handle_Box")
	local nCount = hBox:GetItemCount() - 1
	for i = 0, nCount, 1 do
		local box = hBox:Lookup(i) 
        if not box:IsEmpty() and box:GetObjectType() == UI_OBJECT_CRAFT then
       		local nBoxProID, nBoxBranchID, nBoxCraftID = box:GetObjectData()
   			local Craft = GetCraft(nBoxCraftID)
			local nCraftType = Craft.CraftType
			if nCraftType == ALL_CRAFT_TYPE.RADAR then
				box:SetObjectSelected(false)
			end
        end
	end
end

function ActionBar.LoadSave(box)
	local nPos = box.nSave
	local nType = GetUserPreferences(nPos, "c")
	if nType == 1 then --item
		local nT = GetUserPreferences(nPos + 2, "c")
		local nI = GetUserPreferences(nPos + 3, "w")
		local itemInfo = GetItemInfo(nT, nI)
		if itemInfo then
			box:SetObject(UI_OBJECT_ITEM_INFO, itemInfo.nUiId, nV, nT, nI)
			SetActionBarData(box)
			box:SetObjectIcon(Table_GetItemIconID(itemInfo.nUiId))
            nAccount = GetClientPlayer().GetItemAmount(nT, nI)
			ActionBar.UpdateBoxNum(box, nAccount)
    		box:EnableObject(nAccount > 0)
    		ActionBar.UpdateBoxShow(box)
    		UpdateItemBoxExtend(box, itemInfo)
			return
		end
	elseif nType == 2 then --equip
		local nB = GetUserPreferences(nPos + 1, "c")
		local nI = GetUserPreferences(nPos + 2, "c")
		local item = GetPlayerItem(GetClientPlayer(), nB, nI)
		if item and item.nGenre == ITEM_GENRE.EQUIPMENT then
			box:SetObject(UI_OBJECT_ITEM, item.nUiId, nB, nI, item.nVersion, item.dwTabType, item.dwIndex)
			SetActionBarData(box)
			box:SetObjectIcon(Table_GetItemIconID(item.nUiId))
			if item.nSub == EQUIPMENT_SUB.ARROW then
				ActionBar.UpdateBoxNum(box, item.nStackNum)
			else
				ActionBar.UpdateBoxNum(box, "")
			end
			ActionBar.UpdateBoxShow(box)
			UpdateItemBoxExtend(box, item)
			return
		end
	elseif nType == 3 then --skill
		local player = GetClientPlayer()
		local nSkillID = GetUserPreferences(nPos + 1, "d")
		local bCommon, bMelee = IsCommonSkill(nSkillID)
		local nLevel = player.GetSkillLevel(nSkillID)
		if bCommon then
			nSkillID = player.GetCommonSkill(bMelee)
		end
		if nLevel == 0 then
			nLevel = 1
		end
		if nSkillID and nSkillID ~= 0 then
			box:SetObject(UI_OBJECT_SKILL, nSkillID, nLevel)
			SetActionBarData(box)
			box:SetObjectIcon(Table_GetSkillIconID(nSkillID, nLevel))
			ActionBar.UpdateBoxNum(box, "")
			ActionBar.UpdateBoxShow(box)
			return
		end
	elseif nType == 4 then -- craft
		local nProID	= GetUserPreferences(nPos + 1, "c")
		local nBranchID = GetUserPreferences(nPos + 2, "c")
		local nCraftID 	= GetUserPreferences(nPos + 3, "c")
		
		if nProID ~= 0 then
			box:SetObject(UI_OBJECT_CRAFT, nProID, nBranchID, nCraftID)
			SetActionBarData(box)
			box:SetObjectIcon(Table_GetCraftIconID(nProID, nCraftID))
			ActionBar.UpdateBoxNum(box, "")
			ActionBar.UpdateBoxShow(box)
			return
		end
	elseif nType == 5 then -- sys btn
		local dwID = GetUserPreferences(nPos + 1, "c")
		box:SetObject(UI_OBJECT_SYS_BTN, dwID)
		SetActionBarData(box)
		box:SetObjectIcon(GetSysBtnIcon(dwID))
		ActionBar.UpdateBoxNum(box, "")
		ActionBar.UpdateBoxShow(box)
		return
	elseif nType == 6 then -- macro
		local dwID = GetUserPreferences(nPos + 1, "d")
		box:SetObject(UI_OBJECT_MACRO, dwID)
		SetActionBarData(box)
		box:SetObjectIcon(GetMacroIcon(dwID))
		ActionBar.UpdateBoxNum(box, "")
		ActionBar.UpdateBoxShow(box)
		return
	end
	
	box:ClearObject()
	SetActionBarData(box)
	ActionBar.UpdateBoxNum(box, "")
	ActionBar.UpdateBoxShow(box)
end

function ActionBar.LoadGroupSave(frame)
	local hBox = frame:Lookup("", "Handle_Box")
	local nCount = hBox:GetItemCount() - 1
	for i = 0, nCount, 1 do
		ActionBar.LoadSave(hBox:Lookup(i))
	end
end

function ActionBar.Save(box)
	if box:IsEmpty() then
		SetUserPreferences(box.nSave, "c", 0)
	else
		local nType = box:GetObjectType()
		if nType == UI_OBJECT_ITEM then
			local _, nB, nI = box:GetObjectData()
			SetUserPreferences(box.nSave, "ccc", 2, nB, nI)	
		elseif nType == UI_OBJECT_ITEM_INFO then
			local _, nV, nT, nI = box:GetObjectData()
			SetUserPreferences(box.nSave, "cccw", 1, nV, nT, nI)
		elseif nType == UI_OBJECT_SKILL then
			local nSkillID = box:GetObjectData()
			SetUserPreferences(box.nSave, "cd", 3, nSkillID)
		elseif nType == UI_OBJECT_CRAFT then
			local nProID, nBranchID, nCraftID = box:GetObjectData()
			SetUserPreferences(box.nSave, "cccc", 4, nProID, nBranchID, nCraftID)
		elseif nType == UI_OBJECT_SYS_BTN then
			local dwID = box:GetObjectData()
			SetUserPreferences(box.nSave, "cc", 5, dwID)
		elseif nType == UI_OBJECT_MACRO then
			local dwID = box:GetObjectData()
			SetUserPreferences(box.nSave, "cd", 6, dwID)
		end
	end
end

function ActionBar.New()
	local t = 
	{
		OnFrameCreate = ActionBar.OnFrameCreate,
		OnItemLButtonDown = ActionBar.OnItemLButtonDown,
		OnItemLButtonUp = ActionBar.OnItemLButtonUp,
		OnItemLButtonDrag = ActionBar.OnItemLButtonDrag,
		OnItemLButtonDragEnd = ActionBar.OnItemLButtonDragEnd,
		OnItemLButtonClick = ActionBar.OnItemLButtonClick,
		OnItemLButtonDBClick = ActionBar.OnItemLButtonDBClick,
		OnItemRButtonDown = ActionBar.OnItemRButtonDown,
		OnItemRButtonUp = ActionBar.OnItemRButtonUp,
		OnItemRButtonClick = ActionBar.OnItemRButtonClick,
		OnItemRButtonDBClick = ActionBar.OnItemRButtonDBClick,
		OnItemMouseEnter = ActionBar.OnItemMouseEnter,
		OnItemRefreshTip = ActionBar.OnItemRefreshTip,
		OnItemMouseLeave = ActionBar.OnItemMouseLeave,
		OnFrameBreathe = ActionBar.OnFrameBreathe,
		OnEvent = ActionBar.OnEvent,
		OnFrameDrag = ActionBar.OnFrameDrag,
		OnFrameDragSetPosEnd = ActionBar.OnFrameDragSetPosEnd,
		OnFrameDragEnd = ActionBar.OnFrameDragEnd,
	}
	return t
end

ActionBar1 = ActionBar.New()
ActionBar2 = ActionBar.New()
ActionBar3 = ActionBar.New()
ActionBar4 = ActionBar.New()

function OpenActionBar(i)
	if IsActionBarOpened(i) then
		return
	end

	local aSavePos = ActionBar.aSavePos[i]
	if not aSavePos then
		return
	end
	local nPage = GetMainActionBarPage()
	
	local frame = Wnd.OpenWindow("ActionBar", "ActionBar"..i)
	
	local nSavePos = nil
	--[[
	if i <= 2 then
		frame:ChangeRelation("Lowest")
	else
		frame:ChangeRelation("Normal")
	end
	]]
	frame.nGroup = i
	frame.nSavePos = aSavePos[nPage]
	ActionBar.Init(frame)
	SaveActionBarSetting()
	argS = arg0
	arg0 = i
	FireEvent("ON_OPEN_ACTIONBAR")
	arg0 = argS
	if i ~= 1 and not GetClientPlayer().IsAchievementAcquired(1006) then
		RemoteCallToServer("OnClientAddAchievement", "Open_Quick_Launch")		
	end
end

function IsActionBarOpened(i)
	local frame = nil
	if i == 1 or i == 2 then
		frame = Station.Lookup("Lowest/ActionBar"..i)
	else
		frame = Station.Lookup("Lowest/ActionBar"..i)
	end
	if frame and frame:IsVisible() then
		return true
	end
	return false
end

function GetActionBarFrame(i)
	if i == 1 or i == 2 then
		return Station.Lookup("Lowest/ActionBar"..i)
	else
		return Station.Lookup("Lowest/ActionBar"..i)
	end
end

function CloseActionBar(i)
	if not IsActionBarOpened(i) then
		return
	end
	Wnd.CloseWindow("ActionBar"..i)
	SaveActionBarSetting()
	argS = arg0
	arg0 = i
	FireEvent("ON_CLOSE_ACTIONBAR")
	arg0 = argS	
end

function LockActionBar(bLock)
	ActionBar.bLock = bLock
	SaveActionBarSetting()
	FireEvent("ON_ACTIONBAR_LOCK")
end

function IsActionBarLocked()
	return ActionBar.bLock
end

function ShowActionBarBg(nGroup, bShow)
	ActionBar.aShowBg[nGroup] = bShow
	SaveActionBarSetting()
	local argS = arg0
	arg0 = nGroup
	FireEvent("ON_ACTIONBAR_BG_SHOW")
	arg0 = argS
end

function IsShowActionBarBg(nGroup)
	return ActionBar.aShowBg[nGroup]
end

function GetMainActionBarPage()
	return ActionBar.nPage
end

function SelectMainActionBarPage(nPage)
	if nPage < 1 then
		nPage = 4
	end
	if nPage > 4 then
		nPage = 1
	end
	if nPage == ActionBar.nPage then
		return
	end
	ActionBar.nPage = nPage
	SaveActionBarSetting()
	local argS = arg0
	arg0 = nPage
	FireEvent("ON_SELECT_MAIN_ACTIONBAR_PAGE")
	arg0 = argS
end

function SetActionBarCount(nGroup, nCount)
	ActionBar.Size[nGroup] = nCount
	SaveActionBarSetting()
	
	local argS = arg0
	arg0 = nGroup
	FireEvent("ON_SET_ACTIONBAR_COUNT")
	arg0 = argS
end

function GetActionBarCount(nGroup)
	return ActionBar.Size[nGroup]
end

function SetActionBarLine(nGroup, nLine)
	ActionBar.Line[nGroup] = nLine
	SaveActionBarSetting()

	local argS = arg0
	arg0 = nGroup
	FireEvent("ON_SET_ACTIONBAR_LINE")
	arg0 = argS
end

function GetActionBarLine(nGroup)
	return ActionBar.Line[nGroup]
end

function GetActionBarAnchor(nGroup)
	return ActionBar.Anchor[nGroup]
end

function SetActionBarAnchor(nGroup, Anchor)
	ActionBar.Anchor[nGroup] = Anchor
	SaveActionBarSetting()

	local argS = arg0
	arg0 = nGroup
	FireEvent("ACTIONBAR_ANCHOR_CHANGED")
	arg0 = argS
end

local function Inner_GetActionBarBox(nGroupID, nIndex)
	if nGroupID == 1 or nGroupID == 2 then
		return Station.Lookup("Lowest/ActionBar"..nGroupID, "Handle_Box/"..nIndex)
	elseif nGroupID == 5 then
		local hBox = GetPetActionBarBox(nIndex)
		return hBox
    elseif nGroupID == 6 then
        local hBox = GetPuppetActionBarBox(nIndex)
        return hBox
	else
		return Station.Lookup("Lowest/ActionBar"..nGroupID, "Handle_Box/"..nIndex)
	end
end

function GetActionBarBox(nGroupID, nIndex)
	return Inner_GetActionBarBox(nGroupID, nIndex)
end

function ActionBar_ButtonDown(nGroupID, nIndex)
	local box = Inner_GetActionBarBox(nGroupID, nIndex)
	if box then
		box:SetObjectPressed(1)
	end
end

function ActionBar_ButtonUp(nGroupID, nIndex)
	local box = Inner_GetActionBarBox(nGroupID, nIndex)
	if box then
		box:SetObjectPressed(0)
		if nGroupID == 5 then
			PetActionBar.OnUseActionBarObject(box)
        elseif nGroupID == 6 then
            PuppetActionBar.OnUseActionBarObject(box)
		else
			ActionBar.OnUseActionBarObject(box)	
		end
	end
end

function ActionBar_SetAnchorDefault()
	for i = 1, #(ActionBar.Anchor), 1 do
		ActionBar.Anchor[i].s = ActionBar.DefaultAnchor[i].s
		ActionBar.Anchor[i].r = ActionBar.DefaultAnchor[i].r
		ActionBar.Anchor[i].rw = ActionBar.DefaultAnchor[i].rw
		ActionBar.Anchor[i].x = ActionBar.DefaultAnchor[i].x
		ActionBar.Anchor[i].y = ActionBar.DefaultAnchor[i].y
		
		local argS = arg0
		arg0 = i
		FireEvent("ACTIONBAR_ANCHOR_CHANGED")
		arg0 = argS
	end
end

function GetSkillActionBarBox(dwSkillID)
	local hBox
	for i = 1, 4 do
		if IsActionBarOpened(i) then
			local hFrame = GetActionBarFrame(i)
			local nCount = GetActionBarCount(i)
			local hHandleBox = hFrame:Lookup("", "Handle_Box")
			for j = 0, nCount - 1 do
				hBox = hHandleBox:Lookup(j)
				if not hBox:IsEmpty() then
		            local nType = hBox:GetObjectType()
		            if nType == UI_OBJECT_SKILL then    
		           		local dwBoxSkillID = hBox:GetObjectData()
		           		if dwBoxSkillID == dwSkillID then
		           			return hBox
		           		end
		           	end
		        end
			end
		end
	end
	
	return nil
end
RegisterEvent("CUSTOM_UI_MODE_SET_DEFAULT", ActionBar_SetAnchorDefault)

function InitFirstLoginSkill()
    local hPlayer = GetClientPlayer()
    if not hPlayer then
        return
    end
    local dwSelectKungfuIndex = hPlayer.dwSelectKungfuIndex
    
    local tSkill = Table_GetFirstLoginSkill(dwSelectKungfuIndex)
    if not tSkill then
        return
    end
    local nIndex = 0
    for i = 1, 16 do 
        local dwSkilID = tSkill["dwSkillID" .. i]
        if dwSkilID > 0 then
            SetUserPreferences(nIndex, "cd", 3, dwSkilID)
        end
        nIndex = nIndex + 10
    end
end

function LoadActionBarSetting()
	ActionBar.bLoading = true
    ActionBar.bLoaded = true
	LockActionBar(GetUserPreferences(1382, "b"))

	ShowActionBarBg(1, not GetUserPreferences(1386, "b"))
	ShowActionBarBg(2, not GetUserPreferences(1387, "b"))
	ShowActionBarBg(3, not GetUserPreferences(1388, "b"))
	ShowActionBarBg(4, not GetUserPreferences(1389, "b"))
	
	local v = GetUserPreferences(1390, "c")
	if v ~= 0 then
		SelectMainActionBarPage(v)
	end
	local v1, v2 = GetUserPreferences(1391, "c"), GetUserPreferences(1392, "c")
	if v1 ~= 0 and v2 ~= 0 then
		SetActionBarCount(3, v1)
		SetActionBarLine(3, v2)
	end
	local v1, v2 = GetUserPreferences(1393, "c"), GetUserPreferences(1394, "c")
	if v1 ~= 0 and v2 ~= 0 then
		SetActionBarCount(4, v1)
		SetActionBarLine(4, v2)
	end
	
	local a = GetSaveAnchor(1395)
	if a then
		SetActionBarAnchor(3, a)
	end
	a = GetSaveAnchor(1405)
	if a then
		SetActionBarAnchor(4, a)
	end
	
	if not GetUserPreferences(1450, "b") then
		SetUserPreferences(1450, "b", true)
        InitFirstLoginSkill()
        --[[
		local dwSkillID = GetClientPlayer().GetCommonSkill(true)
		if dwSkillID ~= 0 then
			SetUserPreferences(0, "cd", 3, dwSkillID) --普通攻击
		end
		SetUserPreferences(10, "cd", 3, 49) --回风扫叶
		SetUserPreferences(20, "cd", 3, 34) --暗器
		SetUserPreferences(150, "cd", 3, 17) --打坐
        --]]
	end
	
	OpenActionBar(1)
	if GetUserPreferences(1383, "b") then
		OpenActionBar(2)
	else
		CloseActionBar(2)
	end
	if GetUserPreferences(1384, "b") then
		OpenActionBar(3)
	else
		CloseActionBar(3)
	end
	if GetUserPreferences(1385, "b") then
		OpenActionBar(4)
	else
		CloseActionBar(4)
	end
	ActionBar.bLoading = false
end

function SaveActionBarSetting()
	if ActionBar.bLoading then
		return
	end
    
    if not ActionBar.bLoaded then
        return
    end
	SetUserPreferences(
		1382, "bbbbbbbbccccc", IsActionBarLocked(), IsActionBarOpened(2), IsActionBarOpened(3), IsActionBarOpened(4), 
		not IsShowActionBarBg(1), not IsShowActionBarBg(2), not IsShowActionBarBg(3), not IsShowActionBarBg(4), GetMainActionBarPage(),
		GetActionBarCount(3), GetActionBarLine(3), GetActionBarCount(4), GetActionBarLine(4))
	SaveAnchor(1395, ActionBar.Anchor[3])
	SaveAnchor(1405, ActionBar.Anchor[4])
end

function IsActionBarCoolDownShow()
	return g_bActionBar_CoolDownShow
end

function SetActionBarCoolDownShow(bShow)
	g_bActionBar_CoolDownShow = bShow
end

RegisterCustomData("g_bActionBar_CoolDownShow")

function ActionBar_PlayerLevelUp()
    local hPlayer = GetClientPlayer()
    if not hPlayer then
        return
    end
	if arg0 == hPlayer.dwID  then
        if hPlayer.nLevel == 30 then
            OpenActionBar(2)
            OpenActionBar(3)
        end
        if hPlayer.nLevel == 50 then
            OpenActionBar(2)
            OpenActionBar(3)
            OpenActionBar(4)
        end
    end

end
RegisterEvent("PLAYER_LEVEL_UPDATE", ActionBar_PlayerLevelUp)
-----------界面存储方案说明(0 - 1999,严禁重复,超出或乱加)-----------
--0 - 159 		Actionbar1第1页,16个格子,每个格子大小为10字节
--160 - 319		Actionbar1第2页,16个格子,每个格子大小为10字节
--320 - 479		Actionbar1第3页,16个格子,每个格子大小为10字节

--480 - 639		Actionbar2,16个格子,每个格子大小为10字节
--640 - 799		Actionbar3,16个格子,每个格子大小为10字节
--800 - 959		Actionbar4,16个格子,每个格子大小为10字节

--960 - 1023	kungfu 绑定快捷栏数据
--1200 - 1299   保存新手帮助需要保存的数据
--1300 - 1339	保存任务追踪的数据(最多10个任务)
--1340 			是否有追踪任务点
--1341			追踪任务点questid
--1345			追踪任务点类型
--1346			追踪任务点index
--1347          追踪任务点在玩家questtrace的index
--1350 -1370	问卷调查

--1382			if true Lock ActionBar
--1383			if true ActionBar 2 is Open
--1384			if true ActionBar 3 is Open
--1385			if true ActionBar 4 is open
--1386			if true ActionBar 1 is Show Bg
--1387			if true ActionBar 2 is Show Bg
--1388			if true ActionBar 3 is Show Bg
--1389			if true ActionBar 4 is Show Bg
--1390			主快捷栏打开第几页
--1391			ActionBar 3个数
--1392			ActionBar 3行数
--1393			ActionBar 4个数
--1394			ActionBar 4行数
--1395 - 1404	ActionBar 3 Anchor 信息
--1405 - 1414	ActionBar 4 Anchor 信息

--1450			if false when first login
--1451          玩家是否记录了操作方式
--1452          玩家是鼠标操作(true)，还是键盘操作(false)

--1500 - 3102
--1500			if true when store hotkey
--1501			store hotkey count
--1502 - 3101   hotkey data 200 * 8 (hash, key)

--3200 - 3359   Actionbar1第4页,16个格子,每个格子大小为10字节
--3360 - 3519   Actionbar2第2页,16个格子,每个格子大小为10字节
--3520 - 3679   Actionbar2第3页,16个格子,每个格子大小为10字节
--3680 - 3839   Actionbar2第4页,16个格子,每个格子大小为10字节

--------------------------------------------------------------------
