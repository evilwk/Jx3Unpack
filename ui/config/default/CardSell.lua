
CardSell = {}

local SELL_TYPE_OPTION = {"CheckBox_D1", "CheckBox_D2", "CheckBox_D3"}

function CardSell.OnFrameCreate()
	this:RegisterEvent("SYNC_COIN")
	InitFrameAutoPosInfo(this, 1, "Dialog", nil, function() CloseCardSell(true) end)
end

function CardSell.OnEvent(szEvent)
	if szEvent == "SYNC_COIN" then
		CardSell.UpdateFrame(this)
	end
end

function CardSell.OnLButtonClick()
	local hFrame = this:GetRoot()
	local szName = this:GetName()
	if szName == "Btn_Sure" then
		local dwID, nPrice, nTime = hFrame.dwID, GoldSilverAndCopperToMoney(hFrame.nMony, 0, 0), hFrame.nTime
		local msg = 
		{
			szName = "card_sell_confirm",
			szMessage = FormatString(g_tStrings.STR_CARD_SELL_CONFIRM, hFrame.nCoin, hFrame.nMony),
			fnAutoClose = function() return not IsCardSellOpened() end,
			{szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = function() GetGameCardClient().SellCoin(dwID, nPrice, nTime) CloseCardSell() end},
			{szOption = g_tStrings.STR_HOTKEY_CANCEL},
		}
		MessageBox(msg)
	elseif szName == "Btn_Buy" then
		OpenInternetExplorer(tUrl.Recharge, true)
	elseif szName == "Btn_Cancel" or szName == "Btn_Close" then
		CloseCardSell()
	end
end

function CardSell.OnCheckBoxCheck()
	local szName = this:GetName()
	local hFrame = this:GetRoot()
	if szName == "CheckBox_M1" then
		hFrame.nCoin = this.nCoin
		hFrame.dwID = this.dwID
		hFrame:Lookup("CheckBox_M2"):Check(false)
		hFrame:Lookup("CheckBox_M3"):Check(false)
	elseif szName == "CheckBox_M2" then
		hFrame.nCoin = this.nCoin
		hFrame.dwID = this.dwID
		hFrame:Lookup("CheckBox_M1"):Check(false)
		hFrame:Lookup("CheckBox_M3"):Check(false)
	elseif szName == "CheckBox_M3" then	
		hFrame.nCoin = this.nCoin
		hFrame.dwID = this.dwID
		hFrame:Lookup("CheckBox_M1"):Check(false)
		hFrame:Lookup("CheckBox_M2"):Check(false)
	elseif szName == "CheckBox_T1" then
		hFrame.nTime = 12
		hFrame:Lookup("CheckBox_T2"):Check(false)
		hFrame:Lookup("CheckBox_T3"):Check(false)
	elseif szName == "CheckBox_T2" then
		hFrame.nTime = 24
		hFrame:Lookup("CheckBox_T1"):Check(false)
		hFrame:Lookup("CheckBox_T3"):Check(false)
	elseif szName == "CheckBox_T3" then
		hFrame.nTime = 48
		hFrame:Lookup("CheckBox_T1"):Check(false)
		hFrame:Lookup("CheckBox_T2"):Check(false)
	end
	CardSell.UpdateSellBtnState(hFrame)
end

--[[
function CardSell.OnFrameBreathe()
	local hPlayer = GetClientPlayer()
	local hNpc = GetNpc(this.dwNpcID)
	if not hPlayer 
	or hPlayer.nMoveState == MOVE_STATE.ON_DEATH
	or not hNpc
	or not hNpc.CanDialog(hPlayer) then
		CloseCardSell()
	end
end
--]]

function CardSell.UpdateSellBtnState(frame)
	local btn = frame:Lookup("Btn_Sure")
	local szMoney = frame:Lookup("Edit_Value"):GetText()
	local nMony = 0
	if szMoney ~= "" then
		nMony = tonumber(szMoney)
	end
	
	if frame.nCoin and frame.nTime and nMony and nMony > 0 then
		frame.nMony = nMony
		btn:Enable(true)
	else
		frame.nMony = nil
		btn:Enable(false)
	end
end

function CardSell.FormatTimeDesc(nCoin, nType, nGameTime)
    local szDesc = ""
    szDesc = nCoin .. g_tStrings.STR_CURRENT_TONG_BAO .. " "
    if nType == GAME_CARD_TYPE.MONTH_CARD then
        local nDay = math.floor(nGameTime / (60 * 60 * 24))
        szDesc = szDesc .. nDay .. g_tStrings.STR_BUFF_H_TIME_D
        local nHour = math.floor((nGameTime - nDay * (60 * 60 * 24)) / (60 * 60))
        if nHour > 0 then
            szDesc = szDesc .. nHour .. g_tStrings.STR_BUFF_H_TIME_H
        end
    elseif nType == GAME_CARD_TYPE.POINT_CARD then
        szDesc = szDesc .. math.ceil(nGameTime / 60) .. g_tStrings.STR_BUFF_H_TIME_M
    elseif nType == GAME_CARD_TYPE.DAY_CARD then
        szDesc = szDesc .. nGameTime .. g_tStrings.STR_BUFF_H_TIME_D_SHORT
    end
    
    return szDesc
end

function CardSell.UpdateFrame(hFrame)
	hFrame.tInfoList = GetGameCardInfoList()
	
	hFrame.nChargeMode = GetChargeMode()
    if hFrame.nChargeMode == 0 then
        hFrame.nChargeMode = GAME_CARD_TYPE.MONTH_CARD
    end
    
	local hPlayer = GetClientPlayer()
	hFrame:Lookup("", "Text_TongBao"):SetText(hPlayer.nCoin)
	
	local hSellNote = hFrame:Lookup("", "Handle_Message")
	hSellNote:Clear()
	hFrame:Lookup("CheckBox_M1"):Hide()
	hFrame:Lookup("CheckBox_M2"):Hide()
	hFrame:Lookup("CheckBox_M3"):Hide()
    if hFrame.nChargeMode == CHARGE_MODE.POINT_CARD then
		hFrame.nCardType = GAME_CARD_TYPE.POINT_CARD
        hSellNote:AppendItemFromString(g_tStrings.STR_CARD_SELL_NOTE_POINT_CARD)
    else
        hFrame.nCardType = GAME_CARD_TYPE.MONTH_CARD
		hSellNote:AppendItemFromString(g_tStrings.STR_CARD_SELL_NOTE_MONTH_CARD)
    end
    local nIndex = 1
    for _, tCardType in ipairs(hFrame.tInfoList) do
        if nIndex > 3 then 
            break
        end
        if hFrame.nChargeMode == tCardType.Type then
            local hCheck = hFrame:Lookup("CheckBox_M" .. nIndex)
            local szDesc = CardSell.FormatTimeDesc(tCardType.Coin, tCardType.Type, tCardType.GameTime)
            hCheck:Lookup("", "Text_M" .. nIndex):SetText(szDesc)
            hCheck.nCoin = tCardType.Coin
            hCheck.dwID = tCardType.ID
            hCheck:Show()
            hCheck:Enable(hCheck.nCoin <= hPlayer.nCoin)
            nIndex = nIndex + 1
         end
    end
	
	CardSell.UpdateSellBtnState(hFrame)
	CardSell.UpdateScrollInfo(hSellNote)	
end

function CardSell.OnEditChanged()
	CardSell.UpdateSellBtnState(this:GetRoot())
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Scrollbar

function CardSell.UpdateScrollInfo(hList)
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

function CardSell.OnLButtonHold()
	local szName = this:GetName()
	local hScroll = this:GetRoot():Lookup("Scroll_List")
	if szName == "Btn_Up" then
		hScroll:ScrollPrev(1)
	elseif szName == "Btn_Down" then
		hScroll:ScrollNext(1)
	end
end

function CardSell.OnLButtonDown()
	CardSell.OnLButtonHold()
end

function CardSell.OnScrollBarPosChanged()
	local hFrame = this:GetRoot()
	local szName = this:GetName()
	
	local nCurrentValue = this:GetScrollPos()
	if szName == "Scroll_List" then
		local hBtnUp = hFrame:Lookup("Btn_Up")
		local hBtnDown = hFrame:Lookup("Btn_Down")
		hBtnUp:Enable(nCurrentValue ~= 0)
		hBtnUp:Enable(nCurrentValue ~= this:GetStepCount())
		
	    hFrame:Lookup("", "Handle_Message"):SetItemStartRelPos(0, - nCurrentValue * 10)	
	end
end

function CardSell.OnItemMouseWheel()
	local nDistance = Station.GetMessageWheelDelta()
	local hScroll = this:GetRoot():Lookup("Scroll_List")
	if hScroll:IsVisible() then
		hScroll:ScrollNext(nDistance)
	end
	return true	
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function OpenCardSell(bDisableSound)
	if IsCardSellOpened() then
		CloseCardSell(true)
	end
		
	local hFrame = Wnd.OpenWindow("CardSell")
	
	CardSell.UpdateFrame(hFrame)

	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND, g_sound.OpenFrame)	
	end
end

function IsCardSellOpened()
	local frame = Station.Lookup("Normal/CardSell")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end

function CloseCardSell(bDisableSound)
	Wnd.CloseWindow("CardSell")
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND, g_sound.OpenFrame)	
	end
end

local function OnCardSellRespond()
	if arg0 == GAME_CARD_RESPOND_CODE.SUCCEED then
		OutputMessage("MSG_SYS", g_tStrings.STR_CARD_SELL_RESPOND[arg0]);
	else
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_CARD_SELL_RESPOND[arg0]);        
	end
end

RegisterEvent("GAME_CARD_SELL_COIN_RESPOND", OnCardSellRespond)