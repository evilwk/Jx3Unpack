local PRICE_TYPE_MAX_SIZE = 3

ExteriorRenew = {}

ExteriorRenew.bWaitting = false

function ExteriorRenew.OnFrameCreate()
    this:RegisterEvent("UI_SCALED")

    ExteriorRenew.OnEvent("UI_SCALED")
end

function ExteriorRenew.OnEvent(szEvent)
	if szEvent == "UI_SCALED" then
		this:SetPoint("CENTER", 0, 0, "CENTER", 0, 0)
	end
end

function ExteriorRenew.OnCheckBoxCheck()
    local szName = this:GetName()
    if szName == "CheckBox_Type_Msg1" or szName == "CheckBox_Type_Msg2" or szName == "CheckBox_Type_Msg3" then
        if not ExteriorRenew.bCheckPrice then
            ExteriorRenew.CheckPrice(this)
        end
    end
end

function ExteriorRenew.OnLButtonClick()
    local szName = this:GetName()
    if szName == "Btn_Sure" then
        ExteriorRenew.SureBuy(this:GetRoot())
    elseif szName == "Btn_Cancel" or szName == "Btn_Close" then
        CloseExteriorRenew()
    elseif szName == "Btn_Charge" then
        OpenInternetExplorer(tUrl.Recharge, true)
    end
end

function ExteriorRenew.SureBuy(hFrame)
    local hPlayer = GetClientPlayer()
	if not hPlayer then
		return
	end
    
	local nCoin = hFrame.nCoin
    local nGold = hFrame.nGold
    local nFreeCount = hFrame.nFreeCount
    local nPlayerMoney = hPlayer.GetMoney()
    local nPlayerGold = MoneyToGoldSilverAndCopper(nPlayerMoney)
    local nExteriorFreeCount = hPlayer.GetExteriorFreeCount()
	if nCoin > hPlayer.nCoin or nGold > nPlayerGold or nFreeCount > nExteriorFreeCount then
		local szMsg = g_tStrings.EXTERIOR_ERROR_BUY_LESS_MONEY
		local tMsg = 
		{
			bModal = true,
			szName = "exterior_renew_less_money",
			fnAutoClose = function() return not IsExteriorRenewOpened() end,
			szMessage = szMsg,
			{szOption = g_tStrings.STR_HOTKEY_SURE},
		}
		MessageBox(tMsg)
        return 
    end
    
    if hPlayer.bFightState then
       OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tExteriorBuyRespond[EXTERIOR_BUY_RESPOND_CODE.IN_FIGHT])
       OutputMessage("MSG_SYS", g_tStrings.tExteriorBuyRespond[EXTERIOR_BUY_RESPOND_CODE.IN_FIGHT])
       return
    end
    
    if hPlayer.nMoveState == MOVE_STATE.ON_DEATH then
       OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tExteriorBuyRespond[EXTERIOR_BUY_RESPOND_CODE.YOU_DEATH])
       OutputMessage("MSG_SYS", g_tStrings.tExteriorBuyRespond[EXTERIOR_BUY_RESPOND_CODE.YOU_DEATH])
       return
    end
    
    if CheckPlayerIsRemote(hPlayer.dwID, g_tStrings.tExteriorBuyRespond[EXTERIOR_BUY_RESPOND_CODE.SELF_REMOTE]) then
        return
    end
    
    local szMsg = ""
    if nCoin == 0 and nGold == 0 and nFreeCount == 0 then
        szMsg = g_tStrings.EXTERIOR_BUY_SURE_FREE
    else
        local szPrice = ""
        if nCoin > 0 then
            szPrice = nCoin .. g_tStrings.STR_CURRENT_TONG_BAO .. g_tStrings.STR_COMMA
        end
        if nGold > 0 then
            szPrice = FormatString(g_tStrings.MPNEY_GOLD, nGold) .. g_tStrings.STR_COMMA
        end
        if nFreeCount > 0 then
            szPrice = nFreeCount .. g_tStrings.EXTERIOR_FREE_COUNT.. g_tStrings.STR_COMMA
        end
        
        szMsg = FormatString(g_tStrings.EXTERIOR_BUY_SURE, szPrice)
    end
   
    local fnSureAction = function()
        local tBuy = {}
        table.insert(tBuy, {dwExteriorID = hFrame.dwID, nTimeType = hFrame.nTimeType, nPayType = hFrame.nPayType})
        RemoteCallToServer("OnRenewExterior", tBuy)
        ExteriorRenew_SetWaitting(true)
    end
    local tMsg = 
    {
        bModal = true,
        szName = "exterior_renew_sure_buy",
        fnAutoClose = function() return not IsExteriorRenewOpened() end,
        szMessage = szMsg,
        {szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = fnSureAction},
        {szOption = g_tStrings.STR_HOTKEY_CANCEL},
    }
    MessageBox(tMsg)
end

function ExteriorRenew.CheckPrice(hCheck)
    ExteriorRenew.bCheckPrice = true
    local hFrame = hCheck:GetParent()
    for i = 1, PRICE_TYPE_MAX_SIZE do
        hPrice = hFrame:Lookup("CheckBox_Type_Msg" .. i)
        if hPrice ~= hCheck then
            hPrice:Check(false)
        end
    end
    
    hFrame.nTimeType = hCheck.nTimeType
    hFrame.nPayType = hCheck.nPayType
    hFrame.nGold = 0
    hFrame.nCoin = 0
    hFrame.nFreeCount = 0
    if hCheck.nPayType == EXTERIOR_PAY_TYPE.MONEY then
        hFrame.nGold = hCheck.nPrice
    elseif hCheck.nPayType == EXTERIOR_PAY_TYPE.COIN then
        hFrame.nCoin = hCheck.nPrice
    elseif hCheck.nPayType == EXTERIOR_PAY_TYPE.FREE then
        hFrame.nFreeCount = hCheck.nPrice
    end
    ExteriorRenew.bCheckPrice = false
end

function ExteriorRenew.UpdateFrame(hFrame, dwID)
    local hPlayer = GetClientPlayer()
    if not hPlayer then
        return 
    end
    local hExteriorClient = GetExterior()
    if not hExteriorClient then
        return
    end
    
    local hBox = hFrame:Lookup("", "Box_Item")
    local nHaveTimeType = hPlayer.IsHaveExterior(dwID)
    local tExteriorInfo = hExteriorClient.GetExteriorInfo(dwID)
    hFrame.dwID = dwID
    local nPriceIndex = 1
    hBox:SetObject(UI_OBJECT_NOT_NEED_KNOWN, 0)
    hBox:SetObjectIcon(tExteriorInfo.nIconID)
    local nExteriorFreeCount = hPlayer.GetExteriorFreeCount()
    for _, nTimeType in ipairs(g_tExteriorTimeType) do
        tPayType = tExteriorInfo.tPrice[nTimeType]
        for _, nPayType in ipairs(g_tExteriorPayType) do
            local nPrice = tPayType[nPayType]
            if nPriceIndex > PRICE_TYPE_MAX_SIZE then
                break
            end
            
            if nPrice >= 0 and (nPayType ~= EXTERIOR_PAY_TYPE.FREE or nExteriorFreeCount > 0) then
                if nPayType == EXTERIOR_PAY_TYPE.MONEY then
                    nPrice = MoneyToGoldSilverAndCopper(nPrice)
                end
                local hPrice = hFrame:Lookup("CheckBox_Type_Msg" .. nPriceIndex)
                hPrice:Show()
                local szText = ""
                if nTimeType == EXTERIOR_TIME_TYPE.END then
                    local nEndTime = tExteriorInfo.nLimitTime
                    local nLeftTime = nEndTime - GetCurrentTime()
                    if nLeftTime < 0 then
                        nLeftTime = 0
                    end
                    szText = GetTimeText(nLeftTime, nil, true)
                    hPrice.nLeftTime = nLeftTime
                    
                    local tTime = TimeToDate(nEndTime)
                    local szTimeTip = string.format("%d.%2d.%2d", tTime.year, tTime.month, tTime.day)
                    hPrice.szTimeTip = szTimeTip
                else
                    szText = g_tStrings.tExteriorTimeType[nTimeType]
                end
                
                if nHaveTimeType and nHaveTimeType ~= EXTERIOR_TIME_TYPE.LIMIT then
                    hPrice.nPrice = 0
                else
                    hPrice.nPrice = nPrice
                end
                szText = szText
                local hTextTime = hPrice:Lookup("", "Text_Type_Msg" .. nPriceIndex)
                local hTextMoney = hPrice:Lookup("", "Text_Type_Money" .. nPriceIndex)
                local hMoney = hPrice:Lookup("", "Image_Type_Money" .. nPriceIndex)
                hTextTime:SetText(szText)
                hTextMoney:SetText(hPrice.nPrice)
                local szPath = g_tExteriorPayTypeFrame[nPayType][1]
                local nFrame = g_tExteriorPayTypeFrame[nPayType][2]
                hMoney:FromUITex(szPath, nFrame)
                
                hPrice.nTimeType = nTimeType
                hPrice.nPayType = nPayType
                nPriceIndex = nPriceIndex + 1
            end
        end
    end
    
    for i = nPriceIndex, PRICE_TYPE_MAX_SIZE do
         local hPrice = hFrame:Lookup("CheckBox_Type_Msg" .. i)
         hPrice:Hide()
    end
    
    local hPrice = hFrame:Lookup("CheckBox_Type_Msg1")
    if hPrice:IsVisible() then
        hPrice:Check(true)
    end
end

function OpenExteriorRenew(dwID, bDisableSound)
	if not IsExteriorRenewOpened() then
		Wnd.OpenWindow("ExteriorRenew")
	end
	local hFrame = Station.Lookup("Normal1/ExteriorRenew")
    ExteriorRenew.UpdateFrame(hFrame, dwID)
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
end

function IsExteriorRenewOpened()
	local hFrame = Station.Lookup("Normal1/ExteriorRenew")
	if hFrame then
		return true
	end
	
	return false
end

function CloseExteriorRenew(bDisableSound)
	if not IsExteriorRenewOpened() then
		return 
	end
	Wnd.CloseWindow("ExteriorRenew")
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end	
end

function ExteriorRenew_SetWaitting(bWaitting)
    ExteriorRenew.bWaitting = bWaitting
end

function ExteriorRenew_IsWaitting()
    return ExteriorRenew.bWaitting
end

