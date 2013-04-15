MoneyBuy = {}

local INI_FILE_PATH = "UI/Config/Default/MoneyBuy.ini"

local SORT_TYPE = 
{
	[GAME_CARD_ORDER_TYPE.BY_GAME_TIME] = "CheckBox_Days",
	[GAME_CARD_ORDER_TYPE.BY_END_TIME] = "CheckBox_Time",
	[GAME_CARD_ORDER_TYPE.BY_PRICE] = "CheckBox_Value",
}

function MoneyBuy.OnFrameCreate()
	this:RegisterEvent("GAME_CARD_LOOKUP_MONEY_RESPOND")
	this:RegisterEvent("SYNC_COIN")
	
	InitFrameAutoPosInfo(this, 1, "Dialog", nil, function() CloseMoneyBuy(true) end)
end

function MoneyBuy.OnEvent(szEvent)
	if szEvent == "GAME_CARD_LOOKUP_MONEY_RESPOND" then
		MoneyBuy.OnLookupRespond(this)
	elseif szEvent == "SYNC_COIN" then
		MoneyBuy.UpdateFrame(this)
	end
end

function MoneyBuy.OnLButtonClick()
	local hFrame = this:GetRoot()
	local szName = this:GetName()
	if szName == "Btn_Sure" then
		local tMsg = nil
		if not hFrame.nSelectedCard then
			tMsg = 
			{
				szName = "money_buy_select_card",
				fnAutoClose = function() return not IsMoneyBuyOpened() end,
				szMessage = g_tStrings.STR_MONEY_SELL_SELECT_MONEY,
				{szOption = g_tStrings.STR_HOTKEY_SURE},
			}
		else
			local tData = MoneyBuy.GetCardInfoByID(hFrame, hFrame.nSelectedCard)
			local hPlayer = GetClientPlayer()
			if hPlayer.nCoin < tData.Coin then
				tMsg = 
				{
					szName = "money_buy_less_money",
					fnAutoClose = function() return not IsMoneyBuyOpened() end,
					szMessage = g_tStrings.STR_MONEY_BUY_LESS_CARD,
					{szOption = g_tStrings.STR_HOTKEY_SURE},
				}
			else
				if GetChargeMode() == CHARGE_MODE.POINT_CARD then
					tMsg = 
					{
						szName = "card_money_buy_confirm",
						fnAutoClose = function() return not IsMoneyBuyOpened() end,
						szMessage = FormatString(g_tStrings.STR_MONEY_BUY_CONFIRM_POINT_CARD, 
							FormatString(g_tStrings.STR_MAIL_LEFT_MINUTE, math.floor(tData.GameTime / 60)), tData.Price / 10000),
						{szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = function() MoneyBuy.BuyMoney() end, },
						{szOption = g_tStrings.STR_HOTKEY_CANCEL, },
					}										
				else -- if GetChargeMode() == CHARGE_MODE.MONTH_CARD then
					tMsg = 
					{
						szName = "card_money_buy_confirm",
						fnAutoClose = function() return not IsMoneyBuyOpened() end,
						szMessage = FormatString(g_tStrings.STR_MONEY_BUY_CONFIRM_MONTH_CARD, GetTimeText(tData.GameTime), tData.Price / 10000),
						{szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = function() MoneyBuy.BuyMoney() end, },
						{szOption = g_tStrings.STR_HOTKEY_CANCEL, },
					}					
				end
			end
		end
		
		if tMsg then
			MessageBox(tMsg)
		end
	elseif szName == "Btn_Back" then
		MoneyBuy.UpdateCardInfo(hFrame, hFrame.nStartIndex - hFrame.nCountPerPage, hFrame.eCardType, hFrame.eSortType, hFrame.bDesc)
	elseif szName == "Btn_Next" then
		MoneyBuy.UpdateCardInfo(hFrame, hFrame.nStartIndex + hFrame.nCount, hFrame.eCardType, hFrame.eSortType, hFrame.bDesc)
	elseif szName == "Btn_Cancel" then
		if hFrame.nSelectedCard then
			local dwCardID = hFrame.nSelectedCard
			local tMsg = 
			{
				szName = "money_cancle_confirm",
				szMessage = g_tStrings.STR_MONEY_SELL_CANCEL,
				fnAutoClose = function() return not IsMoneyBuyOpened() end,
				{szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = function() GetGameCardClient().CancelMoney(dwCardID) CloseMoneyBuy() end, },
				{szOption = g_tStrings.STR_HOTKEY_CANCEL, },
			}
			MessageBox(tMsg)
		end
	elseif szName == "Btn_Close" then
		CloseMoneyBuy()
	end
end

function MoneyBuy.OnCheckBoxCheck()
	local szName = this:GetName()
	local hFrame = this:GetRoot()
	if szName == "CheckBox_M" then
	else
		for eSort, szCheckBox in pairs(SORT_TYPE) do
			if szName == szCheckBox then
				MoneyBuy.UpdateCardInfo(hFrame, 0, hFrame.eCardType, eSort, true)
				break
			end
		end	
	end
end

function MoneyBuy.OnCheckBoxUncheck()
	local hFrame = this:GetRoot()
	local szName = this:GetName()
	for eSort, szCheckBox in pairs(SORT_TYPE) do
		if szName == szCheckBox and hFrame.eSortType == eSort then
			MoneyBuy.UpdateCardInfo(hFrame, 0, hFrame.eCardType, hFrame.eSortType, false)
			break
		end
	end	
end

function MoneyBuy.OnItemLButtonClick()
	local szName = this:GetName()
	if szName == "Handle_ListItem" then
		MoneyBuy.SelectListItem(this:GetRoot(), this.nID)
	end
end

function MoneyBuy.OnItemMouseEnter()
end

function MoneyBuy.OnItemMouseLeave()
end

--[[
function MoneyBuy.OnFrameBreathe()
	local hPlayer = GetClientPlayer()
	local hNpc = GetNpc(this.dwNpcID)
	if not hPlayer 
	or hPlayer.nMoveState == MOVE_STATE.ON_DEATH
	or not hNpc
	or not hNpc.CanDialog(hPlayer) then
		CloseMoneyBuy()
	end
end
--]]
function MoneyBuy.UpdateFrame(hFrame)
	local hPlayer = GetClientPlayer()
	if not hPlayer then
		return
	end
	
	hFrame:Lookup("", "Text_TongBao"):SetText(hPlayer.nCoin)
	hFrame.tInfoList = GetGameCardInfoList()
	
	local c = hFrame:Lookup("CheckBox_M")
	c:Check(true)
	if GetChargeMode() == CHARGE_MODE.POINT_CARD then
		c:Lookup("", "Text_M"):SetText(g_tStrings.CHARGE_MODE_POINT)
		MoneyBuy.UpdateCardInfo(hFrame, 0, GAME_CARD_TYPE.POINT_CARD, GAME_CARD_ORDER_TYPE.BY_GAME_TIME, true)
	else --if GetChargeMode() == CHARGE_MODE.MONTH_CARD then
		c:Lookup("", "Text_M"):SetText(g_tStrings.CHARGE_MODE_MONTH)
		MoneyBuy.UpdateCardInfo(hFrame, 0, GAME_CARD_TYPE.MONTH_CARD, GAME_CARD_ORDER_TYPE.BY_GAME_TIME, true)
	end
end

function MoneyBuy.SelectListItem(hFrame, nID)
	local hList = hFrame:Lookup("", "Handle_List")
	local hSelected = nil
	local nCount = hList:GetItemCount()
	for i = 0, nCount - 1 do
		local hListItem = hList:Lookup(i)
		local hImgHighLight = hListItem:Lookup("Image_Cover")
		if hListItem.nID == nID then
			hSelected = hListItem
			hImgHighLight:Show()
		else
			hImgHighLight:Hide()
		end
	end
	
	if hSelected then
		hFrame.nSelectedCard = hSelected.nID
		hFrame.szSelectedCardSellerName = hSelected.szSellerName		
		if hSelected.szSellerName == GetClientPlayer().szName then
			hFrame:Lookup("Btn_Cancel"):Enable(true)
		else
			hFrame:Lookup("Btn_Cancel"):Enable(false)
		end
		hFrame:Lookup("Btn_Sure"):Enable(true)
	else
		hFrame.nSelectedCard = nil
		hFrame.szSelectedCardSellerName = nil
		hFrame:Lookup("Btn_Sure"):Enable(false)
		hFrame:Lookup("Btn_Cancel"):Enable(false)
	end
end

function MoneyBuy.UpdateCardInfo(hFrame, nStartIndex, eCardType, eSortType, bDesc)
	if hFrame.nStartIndex == nStartIndex 
	and hFrame.eCardType == eCardType 
	and hFrame.eSortType == eSortType 
	and hFrame.bDesc == bDesc then
		return
	end
	
	hFrame.nStartIndex = nStartIndex
	hFrame.eCardType = eCardType
	hFrame.eSortType = eSortType
	hFrame.bDesc = bDesc
	
	hFrame:Lookup("", "Handle_List"):Clear()
	hFrame.nSelectedCard = nil
	hFrame.szSelectedCardSellerName = nil
	
	hFrame:Lookup("Btn_Sure"):Enable(false)
	hFrame:Lookup("Btn_Cancel"):Enable(false)
	
	if nStartIndex < 0 then
		nStartIndex = 0
	end
	if nStartIndex == 0 then
		hFrame.nCountPerPage = nil
	end
	
	for eSort, szCheckBox in pairs(SORT_TYPE) do
		local hCheckBox = hFrame:Lookup(szCheckBox)
		hCheckBox:Check(eSort == eSortType and bDesc)
		
		local hHandleSort = hCheckBox:Lookup("", "")
		local hImgUp = hHandleSort:Lookup(0)
		local hImgDown = hHandleSort:Lookup(1)
		if hFrame.eSortType == eSort then
			if bDesc then
				hImgUp:Hide()
				hImgDown:Show()
			else
				hImgUp:Show()
				hImgDown:Hide()
			end
		else
			hImgUp:Hide()
			hImgDown:Hide()
		end
	end
	
	hFrame:Lookup("CheckBox_M"):Check(true)
	
	local hGameCard = GetGameCardClient()
	hGameCard.ApplyLookupMoney(eCardType, nStartIndex, eSortType, bDesc)
end

function MoneyBuy.OnLookupRespond(hFrame)
	local hGameCard = GetGameCardClient()
	local nTotalCount, tCardData = hGameCard.GetLookupMoneyResult()
	hFrame.nCount = #tCardData
	if not hFrame.nCountPerPage then
		hFrame.nCountPerPage = hFrame.nCount
	end
	
	local szPage = string.format("%d-%d(%d)", hFrame.nStartIndex + 1, hFrame.nStartIndex + hFrame.nCount, nTotalCount)
	hFrame:Lookup("", "Text_Page"):SetText(szPage)
	
	hFrame:Lookup("Btn_Back"):Enable(hFrame.nStartIndex > 0)
	hFrame:Lookup("Btn_Next"):Enable(hFrame.nStartIndex + hFrame.nCount < nTotalCount)
	
	local hList = hFrame:Lookup("", "Handle_List")
	hList:Clear()
	for nIndex, tDataLine in ipairs(tCardData) do
		local hListItem = hList:AppendItemFromIni(INI_FILE_PATH, "Handle_ListItem")
		hListItem.nID = tDataLine.ID
		hListItem.szSellerName = tDataLine.SellerName
		if tDataLine.Type == GAME_CARD_TYPE.POINT_CARD then
			hListItem:Lookup("Text_Day"):SetText(FormatString(g_tStrings.STR_MAIL_LEFT_MINUTE, math.floor(tDataLine.GameTime / 60)))
		else --tDataLine.Type == GAME_CARD_TYPE.MONTH_CARD then
			hListItem:Lookup("Text_Day"):SetText(GetTimeText(tDataLine.GameTime))
		end
		hListItem:Lookup("Text_Times"):SetText(MoneyBuy.GetLeftTimetext(tDataLine.LeftTime))
		hListItem:Lookup("Text_Name"):SetText(tDataLine.SellerName)
		local nGold = MoneyToGoldSilverAndCopper(tDataLine.Price)
		hListItem:Lookup("Text_Money"):SetText(nGold)
		hListItem.tData = tDataLine
	end
	hList:FormatAllItemPos()
	FireUIEvent("SCROLL_UPDATE_LIST", "Handle_List", "MoneyBuy", true)
end

function MoneyBuy.GetLeftTimetext(nTime)
	local nHour = nTime / 3600
	if nHour >= 1 then
		return math.floor(nHour + 0.5)..g_tStrings.STR_BUFF_H_TIME_H
	end
	
	local nMinite = nTime / 60
	if nMinite <= 1 then
		nMinite = 1
	end
	return math.floor(nMinite + 0.5)..g_tStrings.STR_BUFF_H_TIME_M
end

function MoneyBuy.GetCardInfoByID(hFrame, nID)
	local hList = hFrame:Lookup("", "Handle_List")
	local nCount = hList:GetItemCount()
	for i = 0, nCount do
		local hListItem = hList:Lookup(i)
		if hListItem.nID == nID then
			return hListItem.tData
		end
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Scrollbar

do  
    RegisterScrollEvent("MoneyBuy")
    
    UnRegisterScrollAllControl("MoneyBuy")
        
    local szFramePath = "Normal/MoneyBuy"
    RegisterScrollControl(
        szFramePath, 
        "Btn_Up", "Btn_Down", 
        "Scroll_List", 
        {"", "Handle_List"})
end

function MoneyBuy.BuyMoney()
	local hFrame = GetMoneyBuy()
	if not hFrame then
		return
	end
	
	local tData = MoneyBuy.GetCardInfoByID(hFrame, hFrame.nSelectedCard)
	local hGameCard = GetGameCardClient()
	hGameCard.BuyMoney(hFrame.nSelectedCard, tData.Coin)
	CloseMoneyBuy()
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function GetMoneyBuy()
	return Station.Lookup("Normal/MoneyBuy")
end

function OpenMoneyBuy(bDisableSound)	
	local hFrame = GetMoneyBuy()
	if not hFrame then
		hFrame = Wnd.OpenWindow("MoneyBuy")
	end
	MoneyBuy.UpdateFrame(hFrame)
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND, g_sound.OpenFrame)	
	end
end

function IsMoneyBuyOpened()
	local frame = Station.Lookup("Normal/MoneyBuy")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end

function CloseMoneyBuy()
	local hFrame = GetMoneyBuy()
	if hFrame then
		Wnd.CloseWindow(hFrame)
	end
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND, g_sound.OpenFrame)	
	end
end

local function OnMoneyBuyRespond()
	if arg0 == GAME_CARD_RESPOND_CODE.SUCCEED then
		OutputMessage("MSG_SYS", g_tStrings.STR_MONEY_BUY_RESPOND[arg0]);
	else
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_MONEY_BUY_RESPOND[arg0]);        
	end
end

RegisterEvent("GAME_CARD_BUY_MONEY_RESPOND", OnMoneyBuyRespond)