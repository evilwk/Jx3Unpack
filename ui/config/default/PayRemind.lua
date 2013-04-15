PayRemind = {}

PayRemind.Anchor = {s = "CENTER", r = "CENTER",  x = 0, y = 0}

function PayRemind.OnFrameCreate()
	this:RegisterEvent("UI_SCALED")

	PayRemind.UpdateAnchor(this)
end

function PayRemind.OnEvent(szEvent)
	if szEvent == "UI_SCALED" then
		PayRemind.UpdateAnchor(this)
	end
end

function PayRemind.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_Charge" then
		OpenInternetExplorer(tUrl.Recharge, true)
	elseif szName == "Btn_Cancle" or szName == "Btn_Close" then
		ClosePayRemind()
    end
end

function PayRemind.UpdateAnchor(hFrame)
	hFrame:SetPoint(PayRemind.Anchor.s, 0, 0, PayRemind.Anchor.r, PayRemind.Anchor.x, PayRemind.Anchor.y)
	hFrame:CorrectPos()
end

function PayRemind.Update(hFrame, nCode)
	local szMsg = g_tStrings.tChargeLimit[nCode]
	hFrame:Lookup("", "Text_Reason"):SetText(szMsg)

	local szText = ""
	szText = GetFormatText(g_tStrings.STR_CHARGE_TIP_TYPE_TXT)

	local hHandleTip = hFrame:Lookup("", "Handle_Tip")
	hHandleTip:Clear()
	hHandleTip:AppendItemFromString(szText)
	hHandleTip:FormatAllItemPos()
end

function OpenPayRemind(nCode, bDisableSound)
	if not IsPayRemindOpened() then
		Wnd.OpenWindow("PayRemind")
	end

	local hFrame = Station.Lookup("Topmost2/PayRemind")
	hFrame:BringToTop()
	hFrame:Show()

	PayRemind.Update(hFrame, nCode)

	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
	return hFrame
end

function ClosePayRemind(bDisableSound)
	if not IsPayRemindOpened() then
		return
	end
	local hFrame = Station.Lookup("Topmost2/PayRemind")
	hFrame:Hide()

	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end
end

function IsPayRemindOpened()
	local hFrame = Station.Lookup("Topmost2/PayRemind")
	if hFrame and hFrame:IsVisible() then
		return true
	end
	return false
end

RegisterAutoClose_Topmost("PayRemind", IsPayRemindOpened, ClosePayRemind)