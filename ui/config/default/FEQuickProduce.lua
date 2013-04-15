FEQuickProduce = {}

local DIAMOND_MAX_LEVEL = 6					--宝石的最大等级

local DIAMOND_MASK = 
{
	[g_tStrings.tFEName[1]] = 0,
	[g_tStrings.tFEName[2]] = 1,
	[g_tStrings.tFEName[3]] = 2,
	[g_tStrings.tFEName[4]] = 3,
	[g_tStrings.tFEName[5]] = 4,
}

function GetDiamondTypeFromName(name)
	return DIAMOND_MASK[name]
end

function FEQuickProduce.OnFrameCreate()
	this:RegisterEvent("QUICK_UPDATE_DIAMOND")

	FEQuickProduce.Init(this)

	InitFrameAutoPosInfo(this, 1, nil, nil, function() CloseFEQuickPanel(true) end)
end

function FEQuickProduce.OnFrameBreathe()
	local player = GetClientPlayer()
	if not player or player.nMoveState == MOVE_STATE.ON_DEATH then
		CloseFEQuickPanel()
		return
	end
end

function FEQuickProduce.OnEvent(event)
	if event == "QUICK_UPDATE_DIAMOND" then
		local nResult = arg0
		if nResult == DIAMOND_RESULT_CODE.SUCCESS then
			OutputMessage("MSG_ANNOUNCE_YELLOW", g_tStrings.tFEProduce.SUCCEED)
		elseif nResult == DIAMOND_RESULT_CODE.NOT_ENOUGH_STAMINA then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFECommon.NOT_ENOUGH_STAMINA)
		elseif nResult == DIAMOND_RESULT_CODE.NOT_ENOUGH_MONEY_FOR_COST then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFECommon.NOT_ENOUGH_MONEY_FOR_COST)
		elseif nResult == DIAMOND_RESULT_CODE.NOT_ENOUGH_MATERIAL then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFECommon.NOT_ENOUGH_MATERAL)
		elseif nResult == DIAMOND_RESULT_CODE.NOT_ENOUGH_FREE_ROOM then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFECommon.NO_ENOUGH_ROOM)
		else
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tFEProduce.FAILED)
		end
		FEQuickProduce.Update()
	end
end

function FEQuickProduce.PopKindList(btn)
	local frame = this:GetRoot()
	local wnd = this:GetParent()
	local handle = wnd:Lookup("", "")
	local img = handle:Lookup("Image_SelectBg1")
	local width, height = img:GetSize()
	local xPos, yPos = img:GetAbsPos()
	
	local list = {
		nMiniWidth = width,
		x = xPos,
		y = yPos + height,
		fnAction = function(UserData, isCheck)
			local text = handle:Lookup("Text_SelContent1")
			text:SetText(tostring(UserData))
			btn.kind = UserData
			FEQuickProduce.Update(frame)
		end,
		fnAutoClose = function()
			if IsFEQuickPanelOpened() then
				return false
			else
				return true
			end
		end,
	}
	
	for k, v in ipairs(g_tStrings.tFEName) do
		table.insert(list, {szOption = v, UserData = v})
	end
	
	PopupMenu(list)
end

function FEQuickProduce.PopLevelList(btn)
	local frame = this:GetRoot()
	local wnd = this:GetParent()
	local handle = wnd:Lookup("", "")
	local img = handle:Lookup("Image_SelectBg2")
	local width, height = img:GetSize()
	local xPos, yPos = img:GetAbsPos()
	
	local list = {
		nMiniWidth = width,
		x = xPos,
		y = yPos + height,
		fnAction = function(UserData, isCheck)
			local text = handle:Lookup("Text_SelContent2")
			text:SetText(tostring(UserData))
			btn.level = UserData
			FEQuickProduce.Update(frame)
		end,
		fnAutoClose = function()
			if IsFEQuickPanelOpened() then
				return false
			else
				return true
			end
		end,
	}
	
	for i = 2, DIAMOND_MAX_LEVEL do
		table.insert(list, {szOption = tostring(i), UserData = i})
	end
	
	PopupMenu(list)
end

function FEQuickProduce.OnLButtonClick()
	local name = this:GetName()
	if name == "Btn_Close" then
		CloseFEQuickPanel()
	elseif name == "Btn_Mode" then
		CloseFEQuickPanel(true)
		OpenFEProducePanel()
	elseif name == "Btn_Select1" then
		FEQuickProduce.PopKindList(this)
	elseif name == "Btn_Select2" then
		FEQuickProduce.PopLevelList(this)
	elseif name == "Btn_Making" then
		FEQuickProduce.QuickProduce(this:GetRoot())
	end
end

function FEQuickProduce.CheckInput(edit)
	if not edit.maxnum then
		return
	end
	local num = tonumber(edit:GetText()) or 0
	if num > edit.maxnum then
		edit.ignore = true
		edit:SetText(tostring(edit.maxnum))
	end
end

function FEQuickProduce.OnEditChanged()
	local name = this:GetName()
	if name == "Edit_Select3" then
		if not this.ignore then
			FEQuickProduce.CheckInput(this)
		end
		this.ignore = false
		FEQuickProduce.Update()
	end
end

function FEQuickProduce.Update(frame)
	if not frame then
		frame = Station.Lookup("Normal/FEQuickProduce")
	end
	
	local player = GetClientPlayer()
	if not player or not frame then
		return
	end
	
	FEQuickProduce.UpdateNumUp(frame)
	
	local wnd = frame:Lookup("Wnd_QuickProduce")
	local handle = wnd:Lookup("", "")
	local handleMsg = handle:Lookup("Handle_Message")
	local btn1 = wnd:Lookup("Btn_Select1")
	local btn2 = wnd:Lookup("Btn_Select2")
	local btnMake = wnd:Lookup("Btn_Making")
	local textNum = wnd:Lookup("Edit_Select3")
	local canProduce = true
	
	FEQuickProduce.CheckInput(textNum)
	
	local kind = btn1.kind or ""
	local level = btn2.level or 0
	local num = tonumber(textNum:GetText()) or 0
	
	if num == 0 then
		canProduce = false
	end
	
	local text = FormatString(g_tStrings.tFEProduce.QUICK_RESULT1, Conversion2ChineseNumber(level), kind)
	text = text .. FormatString(g_tStrings.tFEProduce.QUICK_RESULT2, num)
	text = "<text>text=\"" .. text .. "\" font=27 </text>"
	local textResult = handleMsg:Lookup("Handle_FEResult")
	textResult:Clear()
	textResult:AppendItemFromString(text)
	textResult:FormatAllItemPos()
	
	text = FormatString(g_tStrings.tFEProduce.QUICK_RESULT1, Conversion2ChineseNumber(1), kind, num)
	textResult = handleMsg:Lookup("Text_TFETitle")
	textResult:SetText(text)
	
	textResult = handleMsg:Lookup("Text_TEnergyTitle")
	textResult:SetText(g_tStrings.tFEProduce.QUICK_STAMINA)
	
	textResult = handleMsg:Lookup("Text_TMoneyTitle")
	textResult:SetText(g_tStrings.tFEProduce.QUICK_MONEY)
	
	local result = GetQuickUpdateDiamondInfo(GetDiamondTypeFromName(kind), level, num)
	if not result then
		return
	end
	
	local diamondNeed, diamondAll = result.nNeedMaterialDiamond, result.nHaveMaterialDiamond
	
	if diamondNeed > diamondAll then
		canProduce = false
	end
	
	text = FormatString(g_tStrings.tFEProduce.QUICK_DIAMOND, diamondNeed)
	textResult = handleMsg:Lookup("Text_FEConsume")
	textResult:SetText(text)
	
	text = FormatString(g_tStrings.tFEProduce.QUICK_DIAMOND, diamondAll)
	textResult = handleMsg:Lookup("Text_FEOwn")
	textResult:SetText(text)
	
	local stamina, money = result.nNeedStamina, result.nNeedMoney
	
	text = FormatString(g_tStrings.tFEProduce.QUICK_STAMINA_NUM, stamina)
	textResult = handleMsg:Lookup("Text_EnergyConsume")
	textResult:SetText(text)
	
	local gold, silver, cooper = MoneyToGoldSilverAndCopper(money)
	local handleMoney = handleMsg:Lookup("Handle_MoneyConsume")
	local textGold = handleMoney:Lookup("Text_New_0")
	local textSilver = handleMoney:Lookup("Text_New_1")
	local textCooper = handleMoney:Lookup("Text_New_2")
	local imgGold = handleMoney:Lookup("Image_New_0")
	local imgSilver = handleMoney:Lookup("Image_New_1")
	local imgCooper = handleMoney:Lookup("Image_New_2")
	
	if gold > 0 then
		textGold:SetText(tostring(gold))
		imgGold:Show()
	else
		textGold:SetText("")
		imgGold:Hide()
	end
	
	if silver > 0 then
		textSilver:SetText(tostring(silver))
		imgSilver:Show()
	else
		textSilver:SetText("")
		imgSilver:Hide()
	end
	if gold > 100 then
		imgCooper:Hide()
		textCooper:SetText("")
	else
		imgCooper:Show()
		textCooper:SetText(tostring(cooper))
	end
	
	handleMoney:FormatAllItemPos()
	
	local staminaAll = player.nCurrentStamina
	text = FormatString(g_tStrings.tFEProduce.QUICK_STAMINA_NUM, staminaAll)
	textResult = handleMsg:Lookup("Text_EnergyOwn")
	textResult:SetText(text)
	
	if stamina > staminaAll then
		canProduce = false
	end
	
	local moneyAll = player.GetMoney()
	textResult = handleMsg:Lookup("Text_MoneyOwn")
	if moneyAll < money then
		text = g_tStrings.tFEProduce.QUICK_MONEY2
	else
		text = g_tStrings.tFEProduce.QUICK_MONEY1
	end
	textResult:SetText(text)
	
	if money > moneyAll then
		canProduce = false
	end
	
	if canProduce then
		btnMake:Enable(true)
	else
		btnMake:Enable(false)
	end
end

function FEQuickProduce.Init(frame)
	local wnd = frame:Lookup("Wnd_QuickProduce")
	local handle = wnd:Lookup("", "")
	
	local text = handle:Lookup("Text_SelContent1")
	local btn = wnd:Lookup("Btn_Select1")
	
	local kind = g_tStrings.tFEName[1]
	text:SetText(kind)
	btn.kind = kind
	
	text = handle:Lookup("Text_SelContent2")
	btn = wnd:Lookup("Btn_Select2")
	
	local level = 3
	text:SetText(tostring(level))
	btn.level = level
	
	text = wnd:Lookup("Edit_Select3")
	text:SetText("1")
	
	text.maxnum = 0
	
	FEQuickProduce.Update(frame)
end

function FEQuickProduce.UpdateNumUp(frame)
	local wnd = frame:Lookup("Wnd_QuickProduce")
	local btn = wnd:Lookup("Btn_Select1")
	
	local kind = btn.kind
	
	btn = wnd:Lookup("Btn_Select2")
	local level = btn.level
	
	local text = wnd:Lookup("Edit_Select3")
	
	local mask = GetDiamondTypeFromName(kind)
	local itemInfo = GetDiamondInfo(mask, level, false)
	if not itemInfo then
		return
	end
	
	text.maxnum = itemInfo.nMaxDurability
end

function FEQuickProduce.QuickProduce(frame)
	local wnd = frame:Lookup("Wnd_QuickProduce")
	local btn = wnd:Lookup("Btn_Select1")
	local kind = btn.kind
	
	btn = wnd:Lookup("Btn_Select2")
	local level = btn.level
	
	local text = wnd:Lookup("Edit_Select3")
	local num = tonumber(text:GetText()) or 0
	local mask = GetDiamondTypeFromName(kind)
	
	local result = GetQuickUpdateDiamondInfo(GetDiamondTypeFromName(kind), level, num)
	local diamondNeed, diamondAll = result.nNeedMaterialDiamond, result.nHaveMaterialDiamond
	local stamina, money = result.nNeedStamina, result.nNeedMoney
	local gold, silver, cooper = MoneyToGoldSilverAndCopper(money)
	
	local msgString = FormatString(g_tStrings.tFEProduce.QUICK_MONEY_FORMAT, gold, silver, cooper)
	msgString = FormatString(g_tStrings.tFEProduce.QUICK_SURE_STRING, num, Conversion2ChineseNumber(level), kind, diamondNeed, kind, stamina, msgString)
	
	local fn = function()
		RemoteCallToServer("OnQuickUpdateDiamond", GetDiamondTypeFromName(kind), level, num)
		FEQuickProduce.Update(frame)
	end
	
	local msg = {
		bRichText = true,
		szMessage = msgString, 
		szName = "QuickProduceDiamondSure", 
		fnAutoClose = function() if not IsFEQuickPanelOpened() then return true end end,
		{szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = fn, szSound = g_sound.Trade},
		{szOption = g_tStrings.STR_HOTKEY_CANCEL}
	}
	
	MessageBox(msg)
end

function IsFEQuickPanelOpened()
	local frame = Station.Lookup("Normal/FEQuickProduce")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end

function OpenFEQuickPanel(isDisableSound)
	local player = GetClientPlayer()
	if not player or player.nMoveState == MOVE_STATE.ON_DEATH or IsOptionOrOptionChildPanelOpened() then
		return
	end
	
	--关闭五行石相关其他界面
	CloseFEProducePanel(true)
	CloseFEActivationPanel(true)
	CloseFEEquipExtractPanel(true)
	
	if not IsFEQuickPanelOpened() then
		Wnd.OpenWindow("FEQuickProduce")
	end
	
	if not isDisableSound then
		PlaySound(SOUND.UI_SOUND, g_sound.OpenFrame)
	end
	
	FireEvent("OPEN_FEQUICK_PANEL")
end

function CloseFEQuickPanel(isDisableSound)
	if IsFEQuickPanelOpened() then
		Wnd.CloseWindow("FEQuickProduce")
	end
	
	if not isDisableSound then
		PlaySound(SOUND.UI_SOUND, g_sound.CloseFrame)
	end
	
	FireEvent("CLOSE_FEQUICK_PANEL")
end
