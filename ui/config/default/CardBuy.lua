CardBuy = {}

local INI_FILE_PATH = "UI/Config/Default/CardBuy.ini"

local SORT_TYPE = 
{
	[GAME_CARD_ORDER_TYPE.BY_GAME_TIME] = "CheckBox_Days",
	[GAME_CARD_ORDER_TYPE.BY_END_TIME] = "CheckBox_Time",
	[GAME_CARD_ORDER_TYPE.BY_PRICE] = "CheckBox_Value",
}

function CardBuy.OnFrameCreate()
	this:RegisterEvent("GAME_CARD_LOOKUP_COIN_RESPOND")
	this:RegisterEvent("SYNC_COIN")
	
	InitFrameAutoPosInfo(this, 1, "Dialog", nil, function() CloseCardBuy(true) end)
end

function CardBuy.OnEvent(szEvent)
	if szEvent == "GAME_CARD_LOOKUP_COIN_RESPOND" then
		CardBuy.OnLookupRespond(this)
	elseif szEvent == "SYNC_COIN" then
		CardBuy.UpdateFrame(this)
	end
end

function CardBuy.OnLButtonClick()
	local hFrame = this:GetRoot()
	local szName = this:GetName()
	if szName == "Btn_Sure" then
		local tMsg = nil
		if not hFrame.nSelectedCard then
			tMsg = 
			{
				szName = "card_buy_select_card",
				fnAutoClose = function() return not IsCardBuyOpened() end,
				szMessage = g_tStrings.STR_CARD_SELL_SELECT_CARD,
				{szOption = g_tStrings.STR_HOTKEY_SURE},
			}
		else
			local tData = CardBuy.GetCardInfoByID(hFrame, hFrame.nSelectedCard)
			local hPlayer = GetClientPlayer()
			if hPlayer.GetMoney() < tData.Price then
				tMsg = 
				{
					szName = "card_buy_less_money",
					fnAutoClose = function() return not IsCardBuyOpened() end,
					szMessage = g_tStrings.STR_CARD_BUY_LESS_MONEY,
					{szOption = g_tStrings.STR_HOTKEY_SURE},
				}
			else
				if GetChargeMode() == CHARGE_MODE.POINT_CARD then
					tMsg = 
					{
						szName = "card_buy_confirm",
						fnAutoClose = function() return not IsCardBuyOpened() end,
						szMessage = FormatString(g_tStrings.STR_CARD_BUY_CONFIRM_POINT_CARD, tData.Price / 10000, 
							FormatString(g_tStrings.STR_MAIL_LEFT_MINUTE, math.floor(tData.GameTime / 60))),
						{szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = function() CardBuy.BuyCard() end, },
						{szOption = g_tStrings.STR_HOTKEY_CANCEL, },
					}										
				else -- if GetChargeMode() == CHARGE_MODE.MONTH_CARD then
					tMsg = 
					{
						szName = "card_buy_confirm",
						fnAutoClose = function() return not IsCardBuyOpened() end,
						szMessage = FormatString(g_tStrings.STR_CARD_BUY_CONFIRM_MONTH_CARD, tData.Price / 10000, GetTimeText(tData.GameTime)),
						{szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = function() CardBuy.BuyCard() end, },
						{szOption = g_tStrings.STR_HOTKEY_CANCEL, },
					}					
				end
			end
		end
		
		if tMsg then
			MessageBox(tMsg)
		end
	elseif szName == "Btn_Back" then
		CardBuy.UpdateCardInfo(hFrame, hFrame.nStartIndex - hFrame.nCountPerPage, hFrame.eCardType, hFrame.eSortType, hFrame.bDesc)
	elseif szName == "Btn_Next" then
		CardBuy.UpdateCardInfo(hFrame, hFrame.nStartIndex + hFrame.nCount, hFrame.eCardType, hFrame.eSortType, hFrame.bDesc)
	elseif szName == "Btn_Cancel" then
		if hFrame.nSelectedCard then
			local dwCardID = hFrame.nSelectedCard
			local tMsg = 
			{
				szName = "card_cancle_confirm",
				szMessage = g_tStrings.STR_CARD_SELL_CANCEL,
				fnAutoClose = function() return not IsCardBuyOpened() end,
				{szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = function() GetGameCardClient().CancelCoin(dwCardID) CloseCardBuy() end, },
				{szOption = g_tStrings.STR_HOTKEY_CANCEL, },
			}
			MessageBox(tMsg)
		end
	elseif szName == "Btn_Close" then
		CloseCardBuy()
	end
end

function CardBuy.OnCheckBoxCheck()
	local szName = this:GetName()
	local hFrame = this:GetRoot()
	if szName == "CheckBox_M" then
	else
		for eSort, szCheckBox in pairs(SORT_TYPE) do
			if szName == szCheckBox then
				CardBuy.UpdateCardInfo(hFrame, 0, hFrame.eCardType, eSort, true)
				break
			end
		end	
	end
end

function CardBuy.OnCheckBoxUncheck()
	local hFrame = this:GetRoot()
	local szName = this:GetName()
	for eSort, szCheckBox in pairs(SORT_TYPE) do
		if szName == szCheckBox and hFrame.eSortType == eSort then
			CardBuy.UpdateCardInfo(hFrame, 0, hFrame.eCardType, hFrame.eSortType, false)
			break
		end
	end	
end

function CardBuy.OnItemLButtonClick()
	local szName = this:GetName()
	if szName == "Handle_ListItem" then
		CardBuy.SelectListItem(this:GetRoot(), this.nID)
	end
end

function CardBuy.OnItemMouseEnter()
end

function CardBuy.OnItemMouseLeave()
end

--[[
function CardBuy.OnFrameBreathe()
	local hPlayer = GetClientPlayer()
	local hNpc = GetNpc(this.dwNpcID)
	if not hPlayer 
	or hPlayer.nMoveState == MOVE_STATE.ON_DEATH
	or not hNpc
	or not hNpc.CanDialog(hPlayer) then
		CloseCardBuy()
	end
end
--]]
function CardBuy.UpdateFrame(hFrame)
	local hPlayer = GetClientPlayer()
	
	hFrame:Lookup("", "Text_TongBao"):SetText(hPlayer.nCoin)
	
	local c = hFrame:Lookup("CheckBox_M")
	c:Check(true)
	if GetChargeMode() == CHARGE_MODE.POINT_CARD then
		c:Lookup("", "Text_M"):SetText(g_tStrings.CHARGE_MODE_POINT)
		CardBuy.UpdateCardInfo(hFrame, 0, GAME_CARD_TYPE.POINT_CARD, GAME_CARD_ORDER_TYPE.BY_GAME_TIME, true)
	else --if GetChargeMode() == CHARGE_MODE.MONTH_CARD then
		c:Lookup("", "Text_M"):SetText(g_tStrings.CHARGE_MODE_MONTH)
		CardBuy.UpdateCardInfo(hFrame, 0, GAME_CARD_TYPE.MONTH_CARD, GAME_CARD_ORDER_TYPE.BY_GAME_TIME, true)
	end
end

function CardBuy.SelectListItem(hFrame, nID)
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
		hFrame.nSelectedCardSellerName = hSelected.szSellerName		
		if hSelected.szSellerName == GetClientPlayer().szName then
			hFrame:Lookup("Btn_Cancel"):Enable(true)
		else
			hFrame:Lookup("Btn_Cancel"):Enable(false)
		end
		hFrame:Lookup("Btn_Sure"):Enable(true)
	else
		hFrame.nSelectedCard = nil
		hFrame.nSelectedCardSellerName = nil
		hFrame:Lookup("Btn_Sure"):Enable(false)
		hFrame:Lookup("Btn_Cancel"):Enable(false)
	end
end

function CardBuy.UpdateCardInfo(hFrame, nStartIndex, eCardType, eSortType, bDesc)
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
	hFrame.nSelectedCardSellerName = nil
	
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
	hGameCard.ApplyLookupCoin(eCardType, nStartIndex, eSortType, bDesc)
end

function CardBuy.OnLookupRespond(hFrame)
	local hGameCard = GetGameCardClient()
	local nTotalCount, tCardData = hGameCard.GetLookupCoinResult()
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
		hListItem:Lookup("Text_Times"):SetText(CardBuy.GetLeftTimetext(tDataLine.LeftTime))
		hListItem:Lookup("Text_Name"):SetText(tDataLine.SellerName)
		local nGold = MoneyToGoldSilverAndCopper(tDataLine.Price)
		hListItem:Lookup("Text_Money"):SetText(nGold)
		hListItem.tData = tDataLine
	end
	CardBuy.UpdateScrollInfo(hList)
end

function CardBuy.GetLeftTimetext(nTime)
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

function CardBuy.GetCardInfoByID(hFrame, nID)
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

function CardBuy.UpdateScrollInfo(hList)
	hList:FormatAllItemPos()
	
	local _, nItemHeight = hList:GetAllItemSize()
	local _, nHeight = hList:GetSize()
	
	local hFrame = hList:GetRoot()
	local hScroll = hFrame:Lookup("Scroll_List")
	local nCountStep = math.ceil((nItemHeight - nHeight) / 10)
	hScroll:SetStepCount(nCountStep)
	
	if not hList.nScrollPos then
		hList.nScrollPos = 0
	end
	hScroll:SetScrollPos(hList.nScrollPos)
	
	local hBtnUp = hFrame:Lookup("Btn_Up")
	local hBtnDown = hFrame:Lookup("Btn_Down")
	if nCountStep > 0 then
		hBtnUp:Show()
		hBtnDown:Show()
		hScroll:Show()
	else
		hBtnUp:Hide()
		hBtnDown:Hide()
		hScroll:Hide()
	end
end

function CardBuy.OnLButtonHold()
	local szName = this:GetName()
	local hScroll = this:GetRoot():Lookup("Scroll_List")
	if szName == "Btn_Up" then
		hScroll:ScrollPrev(1)
	elseif szName == "Btn_Down" then
		hScroll:ScrollNext(1)
	end
end

function CardBuy.OnLButtonDown()
	CardBuy.OnLButtonHold()
end

function CardBuy.OnScrollBarPosChanged()
	local nCurrentValue = this:GetScrollPos()
	local hFrame = this:GetRoot()
	local szName = this:GetName()
	if szName == "Scroll_List" then
		local hBtnUp = hFrame:Lookup("Btn_Up")
		local hBtnDown = hFrame:Lookup("Btn_Down")
		hBtnUp:Enable(nCurrentValue ~= 0)
		hBtnUp:Enable(nCurrentValue ~= this:GetStepCount())
		
	    hFrame:Lookup("", "Handle_List"):SetItemStartRelPos(0, - nCurrentValue * 10)	
	end
end

function CardBuy.OnItemMouseWheel()
	local nDistance = Station.GetMessageWheelDelta()
	local hScroll = this:GetRoot():Lookup("Scroll_List")
	if hScroll:IsVisible() then
		hScroll:ScrollNext(nDistance)
	end
	return true	
end

function CardBuy.BuyCard()
	local hFrame = GetCardBuy()
	if not hFrame then
		return
	end
	
	local tData = CardBuy.GetCardInfoByID(hFrame, hFrame.nSelectedCard)
	local hGameCard = GetGameCardClient()
	hGameCard.BuyCoin(hFrame.nSelectedCard, tData.Price)
	CloseCardBuy()
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function GetCardBuy()
	return Station.Lookup("Normal/CardBuy")
end

function OpenCardBuy(bDisableSound)	
	if CheckHaveLocked(SAFE_LOCK_EFFECT_TYPE.COIN, "COIN") then
		return
	end
	
	local hFrame = GetCardBuy()
	if not hFrame then
		hFrame = Wnd.OpenWindow("CardBuy")
	end
	CardBuy.UpdateFrame(hFrame)
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND, g_sound.OpenFrame)	
	end
end

function IsCardBuyOpened()
	local frame = Station.Lookup("Normal/CardBuy")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end

function CloseCardBuy()
	local hFrame = GetCardBuy()
	if hFrame then
		Wnd.CloseWindow(hFrame)
	end
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND, g_sound.OpenFrame)	
	end
end

local function OnCardBuyRespond()
	if arg0 == GAME_CARD_RESPOND_CODE.SUCCEED then
		OutputMessage("MSG_SYS", g_tStrings.STR_CARD_BUY_RESPOND[arg0]);
	else
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_CARD_BUY_RESPOND[arg0]);        
	end
end

RegisterEvent("GAME_CARD_BUY_COIN_RESPOND", OnCardBuyRespond)