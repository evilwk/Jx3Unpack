ItemBuySure = {}

function ItemBuySure.OnFrameCreate()
    this:RegisterEvent("UI_SCALED")
    
    ItemBuySure.OnEvent("UI_SCALED")
end

function ItemBuySure.OnFrameBreathe()
    if not IsShopOpened() then
		CloseItemBuySure()
    end

end

function ItemBuySure.OnEvent(szEvent)
	if szEvent == "UI_SCALED" then
		this:SetPoint("CENTER", 0, 0, "CENTER", 0, 0)
	end
end

function ItemBuySure.OnLButtonClick()
    local szName = this:GetName()
    local hFrame = this:GetRoot()
    if szName == "Btn_Sure" then
        BuyItem(hFrame.nNpcID, hFrame.nShopID, hFrame.nCurrentOpenPage, hFrame.nIndex, hFrame.nNumber)
        CloseItemBuySure()
    elseif szName == "Btn_Cancel" then
        CloseItemBuySure()
    end
end

function ItemBuySure.OnItemMouseEnter()
    local szName = this:GetName()
    if szName == "Box_Item" then
		this:SetObjectMouseOver(1)
		if not this:IsEmpty() then
			local _, dwID = this:GetObjectData()
			local x, y = this:GetAbsPos()
			local w, h = this:GetSize()
			OutputItemTip(UI_OBJECT_ITEM_ONLY_ID, dwID, nil, nil, {x, y, w, h}, false, "shop", this.aShopInfo)
		end
	end
end

function ItemBuySure.OnItemMouseLeave()
	HideTip()
	if szName == "Box_Item" then
		this:SetObjectMouseOver(0)
	end
end

function ItemBuySure.Update(hFrame)
    local nNpcID = hFrame.nNpcID
    local nShopID = hFrame.nShopID
    local nCurrentOpenPage = hFrame.nCurrentOpenPage
    local nIndex = hFrame.nIndex
    local nNumber = hFrame.nNumber
    local dwItemID = GetShopItemID(nShopID, nCurrentOpenPage, nIndex)
    local hItem = GetItem(dwItemID)
    if not hItem then
        return
    end
    local nPrice = GetShopItemBuyPrice(nNpcID, nShopID, nCurrentOpenPage, nIndex)
    local nCount = -1
    local hHandleItem = hFrame:Lookup("", "Handle_Sale/Handle_Item")
    
    ShopPanel.OnOnUpdataItemInfo(hHandleItem, nIndex, hItem, nPrice, nCount, false, nNumber)
    
    local szMessage = FormatLinkString(g_tStrings.BUY_ITEM_SURE, "font=162", GetFormatText("["..GetItemNameByItem(hItem).."]", 
				"166"..GetItemFontColorByQuality(hItem.nQuality, true)))
    local hMessage = hFrame:Lookup("", "Handle_Message")
    hMessage:Clear()
    hMessage:AppendItemFromString(szMessage)
    hMessage:FormatAllItemPos()
end

function OpenItemBuySure(nNpcID, nShopID, nCurrentOpenPage, nIndex, nNumber, bDisableSound)
	if not IsItemBuySureOpened() then
		Wnd.OpenWindow("ItemBuySure")
	end
	local hFrame = Station.Lookup("Topmost/ItemBuySure")
    hFrame.nNpcID = nNpcID
    hFrame.nShopID = nShopID
    hFrame.nCurrentOpenPage = nCurrentOpenPage
    hFrame.nIndex = nIndex
    hFrame.nNumber = nNumber
    ItemBuySure.Update(hFrame)
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end	
end



function IsItemBuySureOpened()
	local hFrame = Station.Lookup("Topmost/ItemBuySure")
	if hFrame and hFrame:IsVisible() then
		return true
	end
	return false
end

function CloseItemBuySure(bDisableSound)
	if not IsItemBuySureOpened() then
		return
	end
	Wnd.CloseWindow("ItemBuySure")
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end
end