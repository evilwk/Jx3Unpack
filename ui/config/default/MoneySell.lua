
MoneySell = {}

local SELL_TYPE_OPTION = {"CheckBox_D1", "CheckBox_D2", "CheckBox_D3"}

function MoneySell.OnFrameCreate()
	this:RegisterEvent("MONEY_UPDATE")
	InitFrameAutoPosInfo(this, 1, "Dialog", nil, function() CloseMoneySell(true) end)
end

function MoneySell.OnEvent(szEvent)
	if szEvent == "MONEY_UPDATE" then
		MoneySell.UpdateFrame(this)
	end
end

function MoneySell.OnLButtonClick()
	local hPlayer = GetClientPlayer()
	if not hPlayer then
		return
	end
	
	local hFrame = this:GetRoot()
	local szName = this:GetName()
	if szName == "Btn_Sure" then
		local dwID, nPrice, nTime = hFrame.dwID, GoldSilverAndCopperToMoney(hFrame.nMony, 0, 0), hFrame.nTime
		local nTotalPrice = nPrice + hFrame.nMoneyTax
		local nMony = hPlayer.GetMoney()
		if nTotalPrice > nMony then
			local msg = 
			{
				szName = "money_sell_not_enough_money",
				szMessage = g_tStrings.STR_MONEY_BUY_NOT_ENOUGH_MONEY,
				fnAutoClose = function() return not IsMoneySellOpened() end,
				{szOption = g_tStrings.STR_HOTKEY_SURE},
			}
			MessageBox(msg)
		else
			local msg = 
			{
				szName = "money_sell_confirm",
				szMessage = FormatString(g_tStrings.STR_MONEY_SELL_CONFIRM, hFrame.nMony, hFrame.nCoin),
				fnAutoClose = function() return not IsMoneySellOpened() end,
				{szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = function() GetGameCardClient().SellMoney(dwID, nPrice, nTime) CloseMoneySell() end},
				{szOption = g_tStrings.STR_HOTKEY_CANCEL},
			}
			MessageBox(msg)
		end
	elseif szName == "Btn_Buy" then
		OpenInternetExplorer(tUrl.Recharge, true)
	elseif szName == "Btn_Cancel" or szName == "Btn_Close" then
		CloseMoneySell()
	end
end

function MoneySell.OnCheckBoxCheck()
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
	MoneySell.UpdateSellBtnState(hFrame)
end

--[[
function MoneySell.OnFrameBreathe()
	local hPlayer = GetClientPlayer()
	local hNpc = GetNpc(this.dwNpcID)
	if not hPlayer 
	or hPlayer.nMoveState == MOVE_STATE.ON_DEATH
	or not hNpc
	or not hNpc.CanDialog(hPlayer) then
		CloseMoneySell()
	end
end
--]]

function MoneySell.UpdateSellBtnState(frame)
	local btn = frame:Lookup("Btn_Sure")
	local szMoney = frame:Lookup("Edit_Value"):GetText()
	local nMony = 0
	if szMoney ~= "" then
		nMony = tonumber(szMoney)
	end
	
	frame.nSellMoney = nMony
	if frame.nCoin and frame.nTime and nMony and nMony > 0 then
		frame.nMony = nMony
		btn:Enable(true)
	else
		frame.nMony = nil
		btn:Enable(false)
	end
end

function MoneySell.UpdateFrame(hFrame)
	hFrame.tInfoList = GetGameCardInfoList()
	
	hFrame.nChargeMode = GetChargeMode()
	local hPlayer = GetClientPlayer()
	local nMony = hPlayer.GetMoney()
	local nGold, nSilver, nCopper = MoneyToGoldSilverAndCopper(nMony)
	hFrame:Lookup("", "Text_SelfGold"):SetText(nGold)
	
	local hSellNote = hFrame:Lookup("", "Handle_Message")
	hSellNote:Clear()
    hFrame.nChargeMode = GetChargeMode()
    if hFrame.nChargeMode == 0 then
        hFrame.nChargeMode = GAME_CARD_TYPE.MONTH_CARD
    end
    
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
            hCheck:Enable(true)
            nIndex = nIndex + 1
         end
    end
    
	MoneySell.UpdateSellBtnState(hFrame)
	
	hSellNote:FormatAllItemPos()
	FireUIEvent("SCROLL_UPDATE_LIST", "Handle_Message", "MoneySell", true)
end

function MoneySell.OnEditChanged()
	local hFrame = this:GetRoot()
	local szName = this:GetName()
	if szName == "Edit_Value" then
		MoneySell.UpdateSellBtnState(hFrame)
		local nPrice = GoldSilverAndCopperToMoney(hFrame.nSellMoney, 0, 0)
		local nMoneyTax = GetGameCardClient().GetSellMoneyTax(nPrice)
		hFrame.nMoneyTax = nMoneyTax
		local nGoldTax, nSilverTax, nCopperTax = MoneyToGoldSilverAndCopper(nMoneyTax)
		local hTextTaxGold = hFrame:Lookup("", "Text_FeeGold")
		hTextTaxGold:SetText(nGoldTax)
		local hTextTaxSilver = hFrame:Lookup("", "Text_FeeSilver")
		hTextTaxSilver:SetText(nSilverTax)
		local hTextTaxCooper = hFrame:Lookup("", "Text_FeeCooper")
		hTextTaxCooper:SetText(nCopperTax)
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Scrollbar
do  
    RegisterScrollEvent("MoneySell")
    
    UnRegisterScrollAllControl("MoneySell")
        
    local szFramePath = "Normal/MoneySell"
    RegisterScrollControl(
        szFramePath, 
        "Btn_Up", "Btn_Down", 
        "Scroll_List", 
        {"", "Handle_Message"})
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function OpenMoneySell(bDisableSound)
	if CheckHaveLocked(SAFE_LOCK_EFFECT_TYPE.COIN, "COIN") then
		return
	end
	
	if IsMoneySellOpened() then
		CloseMoneySell(true)
	end
		
	local hFrame = Wnd.OpenWindow("MoneySell")
	
	MoneySell.UpdateFrame(hFrame)

	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND, g_sound.OpenFrame)	
	end
end

function IsMoneySellOpened()
	local frame = Station.Lookup("Normal/MoneySell")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end

function CloseMoneySell(bDisableSound)
	Wnd.CloseWindow("MoneySell")
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND, g_sound.OpenFrame)	
	end
end

local function OnMoneySellRespond()
	if arg0 == GAME_CARD_RESPOND_CODE.SUCCEED then
		OutputMessage("MSG_SYS", g_tStrings.STR_MONEY_SELL_RESPOND[arg0]);
	else
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_MONEY_SELL_RESPOND[arg0]);        
	end
end

RegisterEvent("GAME_CARD_SELL_MONEY_RESPOND", OnMoneySellRespond)