PayPathPanel = {}

function PayPathPanel.OnFrameCreate()
	this:RegisterEvent("UI_SCALED")
	
	PayPathPanel.OnEvent("UI_SCALED")
end

function PayPathPanel.OnEvent(szEvent)
	if szEvent == "UI_SCALED" then
		this:SetPoint("TOPRIGHT", 0, 0, "TOPRIGHT", -300, 100)
	end
end

function PayPathPanel.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_Close" then
		ClosePayPathPanel()
	end
end

function PayPathPanel.OnItemMouseEnter()
	local szName = this:GetName()
	if szName == "Handle_URL" then
		local hImageOver = this:Lookup("Image_URL2")
		hImageOver:Show()
	elseif szName == "Handle_CardBuy" then
		local hImageOver = this:Lookup("Image_CardBuy2")
		hImageOver:Show()
	elseif szName == "Handle_CardSell" then
		local hImageOver = this:Lookup("Image_CardSell2")
		hImageOver:Show()
	elseif szName == "Handle_MoneyBuy" then
		local hImageOver = this:Lookup("Image_MoneyBuy2")
		hImageOver:Show()
	elseif szName == "Handle_MoneySell" then
		local hImageOver = this:Lookup("Image_MoneySell2")
		hImageOver:Show()
	end
end

function PayPathPanel.OnItemMouseLeave()
	local szName = this:GetName()
	if szName == "Handle_URL" then
		local hImageOver = this:Lookup("Image_URL2")
		hImageOver:Hide()
	elseif szName == "Handle_CardBuy" then
		local hImageOver = this:Lookup("Image_CardBuy2")
		hImageOver:Hide()
	elseif szName == "Handle_CardSell" then
		local hImageOver = this:Lookup("Image_CardSell2")
		hImageOver:Hide()
	elseif szName == "Handle_MoneyBuy" then
		local hImageOver = this:Lookup("Image_MoneyBuy2")
		hImageOver:Hide()
	elseif szName == "Handle_MoneySell" then
		local hImageOver = this:Lookup("Image_MoneySell2")
		hImageOver:Hide()
	end
end

function PayPathPanel.OnItemLButtonClick()
		local szName = this:GetName()
	if szName == "Handle_URL" then
		OpenInternetExplorer(tUrl.Recharge, true)
	elseif szName == "Handle_CardBuy" then
		OpenCardBuy()
	elseif szName == "Handle_CardSell" then
		OpenCardSell()
	elseif szName == "Handle_MoneyBuy" then
		OpenMoneyBuy()
	elseif szName == "Handle_MoneySell" then
		OpenMoneySell()
	end
end

function OpenPayPathPanel(bDisableSound)
    if CheckPlayerIsRemote(nil, g_tStrings.STR_REMOTE_NOT_TIP1) then
        return
    end
    
	if IsPayPathPanelOpened() then
		return
	end
	
	Wnd.OpenWindow("PayPathPanel")
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND, g_sound.OpenFrame)
	end
end

function ClosePayPathPanel(bDisableSound)
	if not IsPayPathPanelOpened() then
		return
	end
	
	Wnd.CloseWindow("PayPathPanel")
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND, g_sound.CloseFrame)
	end
end

function IsPayPathPanelOpened()
	local hFrame = Station.Lookup("Normal/PayPathPanel")
	if hFrame then
		return true
	end
	
	return false
end
