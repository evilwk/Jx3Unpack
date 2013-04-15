
local PRICE_TYPE_MAX_SIZE = 3
local EXTERIOR_SET_NUM = 3
local EXTERIOR_BUY_MAX_NUMBER = 5
local EXTERIOR_SUB_NUMBER = 5
local INI_FILE = "UI/Config/Default/ExteriorBuy.ini"
local EXTERIOR_BUY_MAX_SIZE = 989
local EXTERIOR_BUY_MIN_SIZE = 685

ExteriorBuy = {}

ExteriorBuy.bWaitting = false

function ExteriorBuy.OnFrameCreate()
    this:RegisterEvent("MONEY_UPDATE")
	this:RegisterEvent("SYNC_COIN")
    this:RegisterEvent("EXTERIOR_FREE_COUNT_UPDATE")
    this:RegisterEvent("ON_EXTERIOR_BUY_RESPOND")
    
    InitFrameAutoPosInfo(this, 2, "ExteriorBuy", nil, function() CloseExteriorBuy(true) end)
end

function ExteriorBuy.OnEvent(szEvent)
    if szEvent == "MONEY_UPDATE" then
		ExteriorBuy.UpdateMyMoney(this)
	elseif szEvent == "SYNC_COIN" then
		ExteriorBuy.UpdateMyMoney(this)
    elseif szEvent == "EXTERIOR_FREE_COUNT_UPDATE" then
        ExteriorBuy.UpdateMyMoney(this)
    elseif szEvent == "ON_EXTERIOR_BUY_RESPOND" then
        ExteriorBuy.OnExteriorBuyRespond(this, arg0)
    end
end

function ExteriorBuy.OnLButtonClick()
    local szName = this:GetName()
    local hFrame = this:GetRoot()
    if szName == "Btn_Close" then
        CloseExteriorBuy()
    elseif szName == "Btn_Charge" then
        OpenInternetExplorer(tUrl.Recharge, true)
    elseif szName == "Btn_Sure" then
        ExteriorBuy.SureBuy(hFrame)
    elseif szName == "Btn_Return" then
        ExteriorBuy.RenewPreView(hFrame)
    elseif szName == "Btn_Close2" then
        ExteriorBuy.ShowWndPlayer(hFrame, false)
    end
end

function ExteriorBuy.UpdateSureBtnState(hFrame, bChange)
    local hBtnSure = hFrame:Lookup("Btn_Sure")
    if bChange then
        hBtnSure:Enable(true)
    else
        hBtnSure:Enable(false)
    end
end

function ExteriorBuy.OnExteriorBuyRespond(hFrame, nResult)
    if nResult == EXTERIOR_BUY_RESPOND_CODE.BUY_SUCCESS then
        ExteriorBuy.InitItemList(hFrame)
    end
end

function ExteriorBuy.GetCurrentBuyEquip(hFrame)
    local tBuy = {}
    local hList = hFrame:Lookup("", "Handle_Box")
    local nCount = hList:GetItemCount()
    for i = 0, nCount - 1 do
        local hItem = hList:Lookup(i)
        local hBox = hItem:Lookup("Box_Item")
        local nExteriorSub  = Exterior_BoxIndexToExteriorSub(i)
        if not hBox:IsEmpty() then
            local tBuySub = {}
            local _, dwBox, dwX = hBox:GetObjectData()
            tBuySub.dwExteriorID = hItem.dwExteriorID
            tBuySub.nPayType = hItem.nPayType
            tBuySub.nTimeType = hItem.nTimeType
            tBuySub.dwBox = dwBox
            tBuySub.dwPos = dwX
            table.insert(tBuy, tBuySub)
        end
    end
    return tBuy
end

function ExteriorBuy.SureBuy(hFrame)
    local hPlayer = GetClientPlayer()
	if not hPlayer then
		return
	end
    
    local hExteriorClient = GetExterior()
    if not hExteriorClient then
        return
    end
    
    local nRepeatIndex = ExteriorBuy.CheckItemRepeat(hFrame)
    if nRepeatIndex then
        local szMsg = FormatString(g_tStrings.EXTERIOR_ERROR_BUY_ITEM_REPEAT, nRepeatIndex)
		local tMsg = 
		{
			bModal = true,
			szName = "exterior_buy_less_money",
			fnAutoClose = function() return not IsExteriorBuyOpened() end,
			szMessage = szMsg,
			{szOption = g_tStrings.STR_HOTKEY_SURE},
		}
		MessageBox(tMsg)
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
			szName = "exterior_buy_less_money",
			fnAutoClose = function() return not IsExteriorBuyOpened() end,
			szMessage = szMsg,
			{szOption = g_tStrings.STR_HOTKEY_SURE},
		}
		MessageBox(tMsg)
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
            szPrice = szPrice .. FormatString(g_tStrings.MPNEY_GOLD, nGold) .. g_tStrings.STR_COMMA
        end
        
        if nFreeCount > 0 then
            szPrice = szPrice .. nFreeCount .. g_tStrings.EXTERIOR_FREE_COUNT.. g_tStrings.STR_COMMA
        end
        
        szMsg = FormatString(g_tStrings.EXTERIOR_BUY_SURE, szPrice)
    end
   
    local fnSureAction = function()
        local tBuy = ExteriorBuy.GetCurrentBuyEquip(hFrame)
        local nResult = hExteriorClient.BuyExteriorFromItem(tBuy)
        ExteriorBuy.UpdateSureBtnState(hFrame, false)
        ExteriorBuy_SetWaitting(true)
        if nResult ~= EXTERIOR_BUY_RESPOND_CODE.BUY_SUCCESS then
            OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tExteriorBuyRespond[nResult])
            OutputMessage("MSG_SYS", g_tStrings.tExteriorBuyRespond[nResult])
            ExteriorBuy_SetWaitting(false)
        end
    end
    local tMsg = 
    {
        bModal = true,
        szName = "exterior_buy_sure_buy",
        fnAutoClose = function() return not IsExteriorBuyOpened() end,
        szMessage = szMsg,
        {szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = fnSureAction},
        {szOption = g_tStrings.STR_HOTKEY_CANCEL},
    }
    MessageBox(tMsg)
end

function ExteriorBuy.CheckItemRepeat(hFrame)
    local hList = hFrame:Lookup("", "Handle_Box")
    if hFrame.nBuyItemCount <= 0 then
        return
    end
    for i = 0, hFrame.nBuyItemCount - 1 do
        local hItem = hList:Lookup(i)
        local dwExteriorID = hItem.dwExteriorID
        for j = i + 1, hFrame.nBuyItemCount - 1 do
            local hItemOther = hList:Lookup(j)
            if dwExteriorID == hItemOther.dwExteriorID then
                return i + 1
            end
        end
    end
    
    return
end

function ExteriorBuy.OnMouseEnterSubBox(hBox)
    local hExteriorClient = GetExterior()
    if not hExteriorClient then
        return
    end
    local hItem = hBox:GetParent()
    local dwExteriorID = hItem.dwExteriorID
    
    if dwExteriorID > 0 then
        local tExteriorInfo = hExteriorClient.GetExteriorInfo(dwExteriorID)
        local szTip = Table_GetExteriorGenreName(tExteriorInfo.nGenre) .. "\n"
        szTip = szTip .. Table_GetExteriorSetName(tExteriorInfo.nGenre, tExteriorInfo.nSet)
        szTip = szTip .. g_tStrings.STR_CONNECT .. g_tStrings.tExteriorSubName[tExteriorInfo.nSubType]
        local x, y = hBox:GetAbsPos()
        local w, h = hBox:GetSize()
        szTip = GetFormatText(szTip) 
        OutputTip(szTip, 400, {x, y, w, h})
    end
    
    hBox:SetObjectMouseOver(true)
end

function ExteriorBuy.OnItemMouseEnter()
    local szName = this:GetName()
    if szName == "Box_Item" then
        this:SetObjectMouseOver(true)
        if not this:IsEmpty() then
            ExteriorBuy.OnMouseEnterSubBox(this)
        end
    elseif szName == "Handle_Price1" or szName == "Handle_Price2" or szName == "Handle_Price3" then
        this.bMouseOver = true
        ExteriorBuy.UpdatePriceCheckState(this)
    elseif szName == "Handle_PreView" then
        this.bMouseOver = true
        ExteriorBuy.UpdatePreViewState(this)
    end
end

function ExteriorBuy.OnItemMouseLeave()
    local szName = this:GetName()
    if szName == "Box_Item" then
        this:SetObjectMouseOver(false)
        HideTip()
    elseif szName == "Handle_Price1" or szName == "Handle_Price2" or szName == "Handle_Price3" then
        this.bMouseOver = false
        ExteriorBuy.UpdatePriceCheckState(this)
    elseif szName == "Handle_PreView" then
        this.bMouseOver = false
        ExteriorBuy.UpdatePreViewState(this)
    end
end

function ExteriorBuy.OnItemLButtonDown()
	local szName = this:GetName()
	if szName == "Box_Item" then
		this:SetObjectPressed(1)
	end
end

function ExteriorBuy.OnItemLButtonUp()
	local szName = this:GetName()
	if szName == "Box_Item" then
		this:SetObjectPressed(0)
	end
end

function ExteriorBuy.OnItemLButtonClick()
	local szName = this:GetName()
    if szName == "Handle_Price1" or szName == "Handle_Price2" or szName == "Handle_Price3" then
        ExteriorBuy.CheckPrice(this)
    elseif szName == "Box_Item" then
		if Hand_IsEmpty() then
			ExteriorBuy.OnItemLButtonDrag()
		else
			ExteriorBuy.OnItemLButtonDragEnd()
		end
    elseif szName == "Handle_PreView" then
        ExteriorBuy.CheckPreView(this)
	end
end

function ExteriorBuy.OnItemRButtonClick()
	local szName = this:GetName()
    if szName == "Box_Item" then
        if not this:IsEmpty() then
            ExteriorBuy.RemoveItem(this:GetParent())
        end
	end
end

function ExteriorBuy.OnItemLButtonDrag()
	local szName = this:GetName()
    if szName == "Box_Item" then
		if Hand_IsEmpty() then
			if not this:IsEmpty() then
				if IsCursorInExclusiveMode() then
					OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.SRT_ERROR_CANCEL_CURSOR_STATE)
					PlayTipSound("010")
				else
					Hand_Pick(this)
                    ExteriorBuy.RemoveItem(this:GetParent())
				end
			end
		end
	end
end

function ExteriorBuy.OnItemLButtonDragEnd()
	local szName = this:GetName()
    if szName == "Box_Item" then
		if Hand_IsEmpty() then
			return
		end
		local boxHand = Hand_Get()
		if boxHand:GetObjectType() ~= UI_OBJECT_ITEM then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_MSG_MAIL_ONLY_BAG_ITEM)
			return
		end

		local _, dwBox, dwX = boxHand:GetObjectData()
		if not IsObjectFromPackage(dwBox) then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_MSG_MAIL_ONLY_BAG_ITEM)
			return
		end

		local hItem = GetPlayerItem(GetClientPlayer(), dwBox, dwX)
		if not hItem then
			return
		end
        
        if not ExteriorBuy.CanBuyExterior(hItem) then
            return
        end
    
		if this:IsEmpty() then
			Hand_Clear()
            ExteriorBuy.AddBuyItem(this:GetRoot(), dwBox, dwX)
		else
            local _, dwThisBox, dwThisX = this:GetObjectData()
            RemoveUILockItem("ExteriorBuy", dwThisBox, dwThisX)
			Hand_Pick(this)
            ExteriorBuy.UpdateSubExterior(this:GetParent(), dwBox, dwX)
		end
		AddUILockItem("ExteriorBuy", dwBox, dwX)
        
		if this:IsObjectMouseOver() then
			ExteriorBuy.OnItemMouseEnter()
		end
        ExteriorBuy.UpdateSureBtnState(hFrame, true)
	end
end

function ExteriorBuy.CheckPreView(hPreView)
    hPreView.bCheck = not hPreView.bCheck
    local hItem = hPreView:GetParent()
    local hList = hItem:GetParent()
    local hFrame = hList:GetRoot()
    if hPreView.bCheck then
        for i = 0, hFrame.nBuyItemCount - 1 do
            hChild = hList:Lookup(i)
            local hBox = hChild:Lookup("Box_Item")
            local hChildPreView = hChild:Lookup("Handle_PreView")
            if hBox:IsEmpty() then
                break
            end
            if hChildPreView.bCheck and 
            hChild ~= hItem and 
            hItem.nRepresentSub == hChild.nRepresentSub then
                hChildPreView.bCheck = false
                ExteriorBuy.UpdatePreViewState(hChildPreView)
            end
        end
        ExteriorBuy.PreView(hFrame, hItem.nRepresentSub, hItem.dwExteriorID)
    else
        ExteriorBuy.PreView(hFrame, hItem.nRepresentSub)
    end
    
    ExteriorBuy.UpdatePreViewState(hPreView)
end

function ExteriorBuy.UpdatePreViewState(hPreView)
    local hItem = hPreView:GetParent()
    if hPreView.bCheck or hPreView.bMouseOver then
        hPreView:Lookup("Image_PreView2"):Show()
    else
        hPreView:Lookup("Image_PreView2"):Hide()
    end
    if hPreView.bCheck then
        hItem:Lookup("Image_Bg1"):Show()
    else
        hItem:Lookup("Image_Bg1"):Hide()
    end
end

--[[
function ExteriorBuy.CheckFree(hFree)
    local hItem = hFree:GetParent()
    hFree.bCheck = not hFree.bCheck
    
    ExteriorBuy.UpdateFreeCheckState(hFree)
    if hFree.bCheck then
        local hSelect
        local nSelectTime = -1
        for i = 1, PRICE_TYPE_MAX_SIZE do
            local hPrice = hItem:Lookup("Handle_Price" .. i)
            if hPrice.nTimeType == EXTERIOR_TIME_TYPE.PERMANENT then
                hSelect = hPrice
                break
            elseif hPrice.nTimeType == EXTERIOR_TIME_TYPE.LIMIT then
                nTime = 7
            else
                nTime = math.floor(hPrice.nLeftTime / (24 * 60 * 60))
            end
            if nTime >= nSelectTime then
                hSelect = hPrice
            end
        end
        hSelect.bFree = true
        ExteriorBuy.CheckPrice(hSelect)
    else
        for i = 1, PRICE_TYPE_MAX_SIZE do
            local hPrice = hItem:Lookup("Handle_Price" .. i)
            if hPrice.bFree then
                hPrice.bFree = false
                ExteriorBuy.CheckPrice(hPrice)
                break
            end
        end
    end
    ExteriorBuy.UpdatePriceInfo(hFrame)
end

function ExteriorBuy.UpdateFreeCheckState(hFree)
    local nShowIndex = 0
    if hFree.bCheck then
        if hFree.bMouseOver then
            nShowIndex = 2
        else
            nShowIndex = 3
        end
    else
        if hFree.bMouseOver then
            nShowIndex = 1
        else
            nShowIndex = 0
        end
    end
    
    for i = 0, 3 do
        if i ~= nShowIndex then
            hFree:Lookup(i):Hide()
        end
    end
    hFree:Lookup(nShowIndex):Show()
end
--]]

function ExteriorBuy.CheckPrice(hPrice)
    local hItem = hPrice:GetParent()
    for i = 1, PRICE_TYPE_MAX_SIZE do
        hChild = hItem:Lookup("Handle_Price" .. i)
        if hChild:IsVisible() and hChild ~= hPrice then
            hChild.bCheck = false
            ExteriorBuy.UpdatePriceCheckState(hChild)
        end
    end
    
    hPrice.bCheck = true
    hItem.nTimeType = hPrice.nTimeType
    hItem.nPayType = hPrice.nPayType
    hItem.nPrice = hPrice.nPrice
    ExteriorBuy.UpdatePriceInfo(hItem:GetRoot())
    ExteriorBuy.UpdatePriceCheckState(hPrice)
end

function ExteriorBuy.UpdatePriceCheckState(hPrice)
    if hPrice.bMouseOver then
        if hPrice.nTimeType == EXTERIOR_TIME_TYPE.END then
            local x, y = hPrice:GetAbsPos()
            local w, h = hPrice:GetSize()
            local szTip = GetFormatText(hPrice.szTimeTip)
            OutputTip(szTip, 400, {x, y, w, h})
        end
    else
        HideTip()
    end
    if hPrice.bCheck then
        if hPrice.bMouseOver then
            nShowIndex = 2
        else
            nShowIndex = 3
        end
    else
        if hPrice.bMouseOver then
            nShowIndex = 1
        else
            nShowIndex = 0
        end
    end
    for i = 0, 3 do
        if i ~= nShowIndex then
            hPrice:Lookup(i):Hide()
        end
    end
    hPrice:Lookup(nShowIndex):Show()
end

function ExteriorBuy.UpdateMyMoney(hFrame)
    local hPlayer = GetClientPlayer()
    if not hPlayer then
        return
    end
    local hTotalHandle = hFrame:Lookup("", "")
    local hCoin = hTotalHandle:Lookup("Text_TongBao")
    local hGold = hTotalHandle:Lookup("Text_Gold")
    local hFreeTime = hTotalHandle:Lookup("Text_FreeTimes")
    local hFreeTimeImage = hTotalHandle:Lookup("Image_FreeTimes")
    local nMoney = hPlayer.GetMoney()
    local nGold, nSilver, nCopper = MoneyToGoldSilverAndCopper(nMoney)
    hCoin:SetText(hPlayer.nCoin)
    hGold:SetText(nGold)
    local nExteriorFreeCount = hPlayer.GetExteriorFreeCount()
    local hTotalFreeTime = hTotalHandle:Lookup("Text_FreeTotle_Msg")
    local hTotalFreeTimeImage = hTotalHandle:Lookup("Image_FreeTotle_Icon")
    
    if nExteriorFreeCount > 0 then
        hFreeTime:Show()
        hFreeTimeImage:Show()
        hTotalFreeTime:Show()
        hTotalFreeTimeImage:Show()
    else
        hFreeTime:Hide()
        hFreeTimeImage:Hide()
        hTotalFreeTime:Hide()
        hTotalFreeTimeImage:Hide()
    end
    hFreeTime:SetText(nExteriorFreeCount)
    
   
end

function ExteriorBuy.UpdatePriceInfo(hFrame)
    local hTotalHandle = hFrame:Lookup("", "")
    local hList = hTotalHandle:Lookup("Handle_Box")
    local nGold = 0
    local nCoin = 0
    local nFreeCount = 0
    local nCount = hList:GetItemCount()
    for i = 0, nCount - 1 do
        hItem = hList:Lookup(i)
        local hFree = hItem:Lookup("Handle_Free")
        local hBox = hItem:Lookup("Box_Item")
        if not hBox:IsEmpty() then
            if hItem.nPayType == EXTERIOR_PAY_TYPE.MONEY then
                nGold = nGold + hItem.nPrice
            elseif hItem.nPayType == EXTERIOR_PAY_TYPE.COIN then
                nCoin = nCoin + hItem.nPrice
            elseif hItem.nPayType == EXTERIOR_PAY_TYPE.FREE then
                nFreeCount = nFreeCount + hItem.nPrice
            end
        end
        
    end
    local hCoin = hTotalHandle:Lookup("Text_TBTotle_Msg")
    local hGold = hTotalHandle:Lookup("Text_GoldTotle_Msg")
    local hFreeCount = hTotalHandle:Lookup("Text_FreeTotle_Msg")
    hCoin:SetText(nCoin)
    hGold:SetText(nGold)
    hFreeCount:SetText(nFreeCount)
    hFrame.nCoin = nCoin
    hFrame.nGold = nGold
    hFrame.nFreeCount = nFreeCount
    
    local hBtnOk = hFrame:Lookup("Btn_Sure")
    if nCoin > 0 or nGold > 0 or nFreeCount > 0 then
        hBtnOk:Enable(true)
    else
        hBtnOk:Enable(false)
    end
end

function ExteriorBuy.ShowWndPlayer(hFrame, bShow)
    local hWndPlayer = hFrame:Lookup("Wnd_3D")
    
    local nWidth, nHeight = hFrame:GetSize()
    if bShow then
        nWidth = EXTERIOR_BUY_MAX_SIZE
        hWndPlayer:Show()
    else
        nWidth = EXTERIOR_BUY_MIN_SIZE
        hWndPlayer:Hide()
        ExteriorBuy.RenewPreView(hFrame)
    end

    hFrame:SetSize(nWidth, nHeight)
    CorrectAutoPosFrameAfterClientResize()
end

function ExteriorBuy.InitFrame(hFrame)
    ExteriorBuy.UpdateMyMoney(hFrame)
    
    RegisterExteriorCharacter("ExteriorBuy", "Normal/ExteriorBuy", "Wnd_3D/Scene_Role", "Btn_TurnLeft", "Btn_TurnRight")
    ExteriorBuy.InitItemList(hFrame)
    ExteriorBuy.ShowCurrentSet(hFrame)
    ExteriorBuy.ShowWndPlayer(hFrame, false)
end

function ExteriorBuy.InitItemList(hFrame)
    local hList = hFrame:Lookup("", "Handle_Box")
    hList:Clear()
    hFrame.nBuyItemCount = 0
    local hItem = hList:AppendItemFromIni(INI_FILE, "Handle_Item", "Handle_Item")
    ExteriorBuy.UpdateSubExterior(hItem, nil, nil)
    hList:FormatAllItemPos()
    ExteriorBuy.UpdatePriceInfo(hFrame)
    ExteriorBuy.UpdateSureBtnState(hFrame, false)
end

function ExteriorBuy.RemoveItem(hItem)
    local hList = hItem:GetParent()
    local hFrame = hList:GetRoot()
    
    if hFrame.nBuyItemCount >= EXTERIOR_BUY_MAX_NUMBER then
        local hEmpty = hList:AppendItemFromIni(INI_FILE, "Handle_Item")
        ExteriorBuy.UpdateSubExterior(hEmpty, nil, nil)
    end
    
    hFrame.nBuyItemCount = hFrame.nBuyItemCount - 1
    local hBox = hItem:Lookup("Box_Item")
    local _, dwThisBox, dwThisX = hBox:GetObjectData()
    RemoveUILockItem("ExteriorBuy", dwThisBox, dwThisX)
    hList:RemoveItem(hItem)
    hList:FormatAllItemPos()
    
    ExteriorBuy.UpdatePriceInfo(hFrame)
end

function ExteriorBuy.AddBuyItem(hFrame, dwBoxID, dwIndex)
    AddUILockItem("ExteriorBuy", dwBoxID, dwIndex)
    hFrame.nBuyItemCount = hFrame.nBuyItemCount + 1
    local hList = hFrame:Lookup("", "Handle_Box")
    local hItem = hList:Lookup(hFrame.nBuyItemCount - 1)
    ExteriorBuy.UpdateSubExterior(hItem, dwBoxID, dwIndex)
    if hFrame.nBuyItemCount < EXTERIOR_BUY_MAX_NUMBER then
        local hEmpty = hList:AppendItemFromIni(INI_FILE, "Handle_Item")
        ExteriorBuy.UpdateSubExterior(hEmpty, nil, nil)
    end
    hList:FormatAllItemPos()
    ExteriorBuy.UpdatePriceInfo(hFrame)
    ExteriorBuy.UpdateSureBtnState(hFrame, true)
end

function ExteriorBuy.RenewPreView(hFrame)
    local hList = hFrame:Lookup("", "Handle_Box")
    for i = 0, hFrame.nBuyItemCount - 1 do
        local hItem = hList:Lookup(i)
        local hPreView = hItem:Lookup("Handle_PreView")
        if hPreView.bCheck then
            hPreView.bCheck = false
            ExteriorBuy.UpdatePreViewState(hPreView)
        end
    end
    ExteriorBuy.ShowCurrentSet(hFrame)
    
end

function ExteriorBuy.PreView(hFrame, nRepresentSub, dwExteriorID)
    local hPlayer = GetClientPlayer()
    if not hPlayer then
        return
    end
    
    local hExteriorClient = GetExterior()
    if not hExteriorClient then
        return
    end
    ExteriorBuy.ShowWndPlayer(hFrame, true)
    if not dwExteriorID then
        local nCurrentSetID = hPlayer.GetCurrentSetID()
        local tExteriorSet = hPlayer.GetExteriorSet(nCurrentSetID)
        local nExteriorSub = Exterior_RepresentSubToExteriorSub(nRepresentSub)
        dwExteriorID = tExteriorSet[nExteriorSub]
    end
    
    local nRepresentColor = Exterior_RepresentSubToColor(nRepresentSub)
    local tExteriorInfo = hExteriorClient.GetExteriorInfo(dwExteriorID)
    local nEquipSub = Exterior_RepresentSubToEquipSub(nRepresentSub)
    local hItem = GetPlayerItem(hPlayer, INVENTORY_INDEX.EQUIP, nEquipSub)
    if not hItem or dwExteriorID > 0 then
        hFrame.tRepresentID[nRepresentSub] = tExteriorInfo.nRepresentID
        hFrame.tRepresentID[nRepresentColor] = tExteriorInfo.nColorID
    else
        hFrame.tRepresentID[nRepresentSub] = hItem.nRepresentID
        hFrame.tRepresentID[nRepresentColor] = hItem.nColorID
    end
   
    FireUIEvent("EXTERIOR_CHARACTER_UPDATE", "ExteriorBuy", hFrame.tRepresentID)
end

function ExteriorBuy.ShowCurrentSet(hFrame)
    local hPlayer = GetClientPlayer()
	if not hPlayer then
		return
	end
    
    local hExteriorClient = GetExterior()
    if not hExteriorClient then
        return
    end
    
    hFrame.tRepresentID = hPlayer.GetRepresentID()
    
    tRepresentID = hFrame.tRepresentID
    local nCurrentSetID = hPlayer.GetCurrentSetID()
    local tExteriorSet = hPlayer.GetExteriorSet(nCurrentSetID)
    for i = 1, EXTERIOR_SUB_NUMBER do
        local nExteriorSub  = Exterior_BoxIndexToExteriorSub(i)
        local dwExteriorID = tExteriorSet[nExteriorSub]
        if dwExteriorID > 0 then
            local tExteriorInfo = hExteriorClient.GetExteriorInfo(dwExteriorID)
            local nRepresentSub = Exterior_BoxIndexToRepresentSub(i)
            local nRepresentColor = Exterior_RepresentSubToColor(nRepresentSub)
            tRepresentID[nRepresentSub] = tExteriorInfo.nRepresentID
            tRepresentID[nRepresentColor] = tExteriorInfo.nColorID
        end
    end
   
    FireUIEvent("EXTERIOR_CHARACTER_UPDATE", "ExteriorBuy", hFrame.tRepresentID)
end

function ExteriorBuy.UpdateSubExterior(hListItem, dwBox, dwX)
    local hPlayer = GetClientPlayer()
    if not hPlayer then
        return 
    end
    local hExteriorClient = GetExterior()
    if not hExteriorClient then
        return
    end
    local hFrame = hListItem:GetRoot()
    local hList = hListItem:GetParent()
    local hBox = hListItem:Lookup("Box_Item")
    local hPreView = hListItem:Lookup("Handle_PreView")
    local hEmptyText = hListItem:Lookup("Text_Tip")
    if not dwBox and  not dwX then
        hBox:ClearObject()
		hBox:SetOverText(0, "")
        for i = 1, PRICE_TYPE_MAX_SIZE do
            local hPrice = hListItem:Lookup("Handle_Price" .. i)
            hPrice:Hide()
        end
        
        hPreView:Hide()
        hEmptyText:Show()
    else
        hPreView:Show()
        hEmptyText:Hide()
        local hItem = GetPlayerItem(hPlayer, dwBox, dwX)
        hBox:SetObject(UI_OBJECT_ITEM, hItem.nUiId, dwBox, dwX, hItem.nVersion, hItem.dwTabType, hItem.dwIndex)
		hBox:SetObjectIcon(Table_GetItemIconID(hItem.nUiId))
        
        local dwExteriorID = hExteriorClient.GetExteriorIndex(hItem.nSub, hItem.nRepresentID, hItem.nColorID, hPlayer.dwForceID)
        local nRepresentSub = Exterior_SubToRepresentSub(hItem.nSub)
        hListItem.nRepresentSub = nRepresentSub
        hListItem.dwExteriorID = dwExteriorID
        
        -- local nHaveTimeType = hPlayer.IsHaveExterior(dwExteriorID)
        local tExteriorInfo = hExteriorClient.GetExteriorInfo(dwExteriorID)
        local nExteriorFreeCount = hPlayer.GetExteriorFreeCount()
        local nPriceIndex = 1
        for _, nTimeType in ipairs(g_tExteriorTimeType) do
            tPayType = tExteriorInfo.tPrice[nTimeType]
            for _, nPayType in ipairs(g_tExteriorPayType) do
                
                local nPrice = tPayType[nPayType]
                if nPriceIndex > PRICE_TYPE_MAX_SIZE then
                    break
                end
                
                if nPrice >= 0 and (nPayType ~= EXTERIOR_PAY_TYPE.FREE or nExteriorFreeCount > 0)then
                    if nPayType == EXTERIOR_PAY_TYPE.MONEY then
                        nPrice = MoneyToGoldSilverAndCopper(nPrice)
                    end
                    local hPrice = hListItem:Lookup("Handle_Price" .. nPriceIndex)
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
                    
                    --[[
                    if nHaveTimeType and nHaveTimeType ~= EXTERIOR_TIME_TYPE.LIMIT then
                        hPrice.nPrice = 0
                    else
                        hPrice.nPrice = nPrice
                    end
                    --]]
                    hPrice.nPrice = nPrice
                    local hTextTime = hPrice:Lookup("Text_Checkbox_Time" .. nPriceIndex)
                    local hTextMoney = hPrice:Lookup("Text_Checkbox_Money" .. nPriceIndex)
                    local hMoney = hPrice:Lookup("Image_Checkbox_Money" .. nPriceIndex)
                    hTextTime:SetText(szText)
                    hTextMoney:SetText(hPrice.nPrice)
                    local szPath = g_tExteriorPayTypeFrame[nPayType][1]
                    local nFrame = g_tExteriorPayTypeFrame[nPayType][2]
                    hMoney:FromUITex(szPath, nFrame)
                    
                    hPrice.nTimeType = nTimeType
                    hPrice.nPayType = nPayType
                    ExteriorBuy.UpdatePriceCheckState(hPrice)
                    nPriceIndex = nPriceIndex + 1
                end
            end
        end
        
        for i = nPriceIndex, PRICE_TYPE_MAX_SIZE do
             local hPrice = hListItem:Lookup("Handle_Price" .. i)
             hPrice:Hide()
        end
        
        local hPrice = hListItem:Lookup("Handle_Price1")
        if hPrice:IsVisible() then
            ExteriorBuy.CheckPrice(hPrice)
        end
    end
end

function ExteriorBuy.CanBuyExterior(hItem)
    if not hItem then
        return false
    end
    
    local hExteriorClient = GetExterior()
    if not hExteriorClient then
        return
    end
    
    local hPlayer = GetClientPlayer()
    if not hPlayer then
        return false
    end
    
    if hItem.nGenre ~= ITEM_GENRE.EQUIPMENT then
        OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.EXTERIOR_ERROR_BUY_NOT_EQUIP)
        return false
    end
    
    nRepresentSub = Exterior_SubToRepresentSub(hItem.nSub)
    if not nRepresentSub then
        OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.EXTERIOR_ERROR_BUY_NOT_SUB)
        return false
    end
    
    local dwExteriorID = hExteriorClient.GetExteriorIndex(hItem.nSub, hItem.nRepresentID, hItem.nColorID, hPlayer.dwForceID)
    if not dwExteriorID then
        OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.EXTERIOR_ERROR_BUY_NOT_EXTERIOR)
        return false
    end
    
    local nHaveTimeType = hPlayer.IsHaveExterior(dwExteriorID)
    if nHaveTimeType then
        OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.EXTERIOR_ERROR_BUY_IS_HAVE)
        return false
    end
        
    local tExteriorInfo = hExteriorClient.GetExteriorInfo(dwExteriorID)
    
    if tExteriorInfo.nGenre == EXTERIOR_GENRE.SCHOOL and hPlayer.dwForceID ~= tExteriorInfo.nForceID then
        OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.EXTERIOR_ERROR_BUY_OTHER_FORCE)
        return false
    end
    
    return true
end

function ExteriorBuy.OnFrameBreathe()
	local hPlayer = GetClientPlayer()
	if not hPlayer then
		return
	end
	if not this.dwNpcID then
		CloseExteriorBuy()
		return
	end
	
	local hNpc = GetNpc(this.dwNpcID)
	if not hNpc or not hNpc.CanDialog(hPlayer) then
		CloseExteriorBuy()
	end
end

function OpenExteriorBuy(dwNpcID, bDisableSound)
	if not IsExteriorBuyOpened() then
		Wnd.OpenWindow("ExteriorBuy")
	end
    RemoveUILockItem("ExteriorBuy")
	OpenAllBagPanel(true)
	local hFrame = Station.Lookup("Normal/ExteriorBuy")
	hFrame:BringToTop()
	hFrame.dwNpcID = dwNpcID
	ExteriorBuy.InitFrame(hFrame)
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
end

function IsExteriorBuyOpened()
	local hFrame = Station.Lookup("Normal/ExteriorBuy")
	if hFrame then
		return true
	end
	
	return false
end

function CloseExteriorBuy(bDisableSound)
	if not IsExteriorBuyOpened() then
		return 
	end
    if ExteriorBuy_IsWaitting() then
        local szMsg = g_tStrings.EXTERIOR_BUY_WAINTING_RESPOND
		local tMsg = 
		{
            bModal = true,
			szName = "exterior_buy_waitting",
			szMessage = szMsg,
			{szOption = g_tStrings.STR_HOTKEY_SURE},
		}
		MessageBox(tMsg)
    end
	Wnd.CloseWindow("ExteriorBuy")
    RemoveUILockItem("ExteriorBuy")
	CloseAllBagPanel(true)
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end	
end

function AddItemToExteriorBuy(dwBoxID, dwIndex)
	local hPlayer = GetClientPlayer()
	local hItem = GetPlayerItem(hPlayer, dwBoxID, dwIndex)
	if not hItem then
		return
	end
	
	if not IsExteriorBuyOpened() then
		return
	end
	
	if IsBagInSort() then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_CANNOT_TRADE_ITEM_INSORT)
		return
	end

    if not IsObjectFromPackage(dwBoxID) then
        OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_MSG_MAIL_ONLY_BAG_ITEM)
        return
    end
        
    if not ExteriorBuy.CanBuyExterior(hItem) then
        return
    end
    
    local hFrame = Station.Lookup("Normal/ExteriorBuy")
    local nCount = hFrame.nBuyItemCount
    if nCount >= EXTERIOR_BUY_MAX_NUMBER then
        OutputMessage("MSG_ANNOUNCE_RED", FormatString(g_tStrings.EXTERIOR_ERROR_BUY_MAX_NUMBER, EXTERIOR_BUY_MAX_NUMBER))
        return
    end
	
	ExteriorBuy.AddBuyItem(hFrame, dwBoxID, dwIndex)
end

function ExteriorBuy_GetCurrentSet()
    local hPlayer = GetClientPlayer()
	if not hPlayer then
		return
	end

    if not hFrame.tRepresentID then
        hFrame.tRepresentID = hPlayer.GetRepresentID()
    end
    local nCurrentSetID = hPlayer.GetCurrentSetID()
    local tExteriorSet = hPlayer.GetExteriorSet(nCurrentSetID)
end

function ExteriorBuy_SetWaitting(bWaitting)
    ExteriorBuy.bWaitting = bWaitting
end

function ExteriorBuy_IsWaitting()
    return ExteriorBuy.bWaitting
end
