local MAX_PAY_GOLD = 200000
local function GetPatterns()
	local szAllLowerChar = ""
	local szAllSuperChar = ""
	for i = 0, 26 do 
		local nByte = string.byte('a')
		szAllLowerChar = szAllLowerChar .. string.char(nByte + i) 
		nByte = string.byte('A')
		szAllSuperChar = szAllSuperChar .. string.char(nByte + i)
	end
	local szALLNumber = ""
	for i = 0, 9 do
		szALLNumber = szALLNumber .. i
	end
	local szOther = ",.:\\/，。·：、 　"
	
	local szMustHaveRisk = szAllLowerChar .. szAllSuperChar .. szOther  -- 骗子邮件内容必须出现的字符集,包含所有的字母 + 一些额外指定的字符
	local szMayHaveRisk = szALLNumber  --骗子邮件内容可能会出现的字符集,包含所有数字.这个是对必须出现的字符集的补充。
	return szMayHaveRisk, szMustHaveRisk
end

local CHARACTER_SET_MAIL_MAY_HAVE_RISK, CHARACTER_SET_MAIL_MUST_HAVE_RISK = GetPatterns()
local MIN_RISK_CHARACTER_APPEAR_NUM = 5 --邮件内容连续出现几个数，会被认定为骗子邮件

local tMailFrame = 
{
	{8, 0, 4, 2, 6}, -- no read
	{9, 1, 5, 3, 7}, -- already read
}

MailPanel =
{
	nSendMoney = 30,
	szFilter = "all",
	bAutoDelete = false,
}

RegisterCustomData("MailPanel.bAutoDelete")

function MailPanel.OnFrameCreate()
	this.bDoubleSize = true
	this:RegisterEvent("SEND_MAIL_RESULT")
	this:RegisterEvent("MAIL_LIST_UPDATE")
	this:RegisterEvent("GET_MAIL_CONTENT")
	this:RegisterEvent("BAG_ITEM_UPDATE")

	this:RegisterEvent("MONEY_UPDATE")

	this:RegisterEvent("PLAYER_FELLOWSHIP_UPDATE")
	this:RegisterEvent("PLAYER_FELLOWSHIP_CHANGE")

	this:RegisterEvent("MAIL_FILTER_CHANGED")

	local pageSet = this:Lookup("PageSet_Total")

	local page = pageSet:Lookup("Page_Receive")
	local handle = page:Lookup("", "")
	local hList = handle:Lookup("Handle_MailList")
	hList:Clear()
	MailPanel.UpdateScrollInfo(hList)
	GetMailClient().ApplyMailList()
	local hContent = handle:Lookup("Handle_MailContent")
	MailPanel.UpdateScrollInfo(hContent)
	MailPanel.UpdateFilterText(page)
	page:Lookup("CheckBox_AutoDel"):Check(MailPanel.bAutoDelete)

	local page = pageSet:Lookup("Page_Send")
	MailPanel.UpdateSelfMoneyShow(page:Lookup("", ""))
	MailPanel.UpdateSendBtnState(page)
	MailPanel.UpdateLetterMoney(page)
	MailPanel.UpdateFrendList(page:Lookup("", "Handle_NameList"))
	GetClientPlayer().UpdateFellowshipInfo()

	handle = page:Lookup("", "Handle_Write")
	for i = 0, 7, 1 do
		local box = handle:Lookup("Box_Item"..i)
		box:SetOverTextPosition(0, ITEM_POSITION.RIGHT_BOTTOM)
		box:SetOverTextFontScheme(0, 15)
		box.bDeliverItem = true
	end

	InitFrameAutoPosInfo(this, 2, "Dialog", nil, function() CloseMailPanel(true) end)

	if not GetClientPlayer().IsAchievementAcquired(1000) then
		RemoteCallToServer("OnClientAddAchievement", "Mail_First_Recv")
	end
end

function MailPanel.OnItemMouseWheel()
	local nDistance = Station.GetMessageWheelDelta()
	local szName = this:GetName()
	if szName == "Handle_NameList" then
		this:GetParent():GetParent():Lookup("Scroll_PlayerList"):ScrollNext(nDistance)
		return true
	elseif szName == "Handle_MailList" then
		this:GetParent():GetParent():Lookup("Scroll_MailList"):ScrollNext(nDistance)
		return true
	elseif szName == "Handle_MailContent" then
		this:GetParent():GetParent():Lookup("Scroll_MailContent"):ScrollNext(nDistance)
		return true
	end
	return false
end

function MailPanel.OnMouseWheel()
	if this:GetName() == "MailPanel" then
		return true
	end
end

function MailPanel.UpdateItemLock(handle)
	RemoveUILockItem("mail")
	if handle then
		for i = 0, 7, 1 do
			local box = handle:Lookup("Box_Item"..i)
			if not box:IsEmpty() then
				AddUILockItem("mail", box.nBag, box.nIndex)
			end
		end
	end
end

function MailPanel.OnFrameBreathe()
	local player = GetClientPlayer()
	if not player or player.nMoveState == MOVE_STATE.ON_DEATH then
		CloseMailPanel()
		return
	end

    if MailPanel.dwTargetType == TARGET.NPC then
		local npc = GetNpc(MailPanel.dwTargetID)
		if not npc or not npc.CanDialog(player) then
			CloseMailPanel()
			return
		end
    elseif MailPanel.dwTargetType == TARGET.DOODAD then
		local doodad = GetDoodad(MailPanel.dwTargetID)
		if not doodad or not doodad.CanDialog(player) then
			CloseMailPanel()
			return
		end
    end

	if MailPanel.nSendIndex then
		if not this.nSendCount then
			this.nSendCount = 0
		end
		this.nSendCount = this.nSendCount + 1
		if this.nSendCount > 10 * 16 then --10s
			MailPanel.OnSendMailResult(this:Lookup("PageSet_Total/Page_Send"),
				MailPanel.nSendIndex, MAIL_RESPOND_CODE.FAILED)
			this.nSendCount = 0
		end
	else
		this.nSendCount = 0
	end
end

function MailPanel.UpdateFilterText(page)
	local szText = g_tStrings.STR_MAIL_ALL
	if MailPanel.szFilter == "player" then
		szText = g_tStrings.STR_MAIL_PLAYER
	elseif MailPanel.szFilter == "auction" then
		szText = g_tStrings.STR_MAIL_AUCTION
	elseif MailPanel.szFilter == "system" then
		szText = g_tStrings.STR_MAIL_SYS
	elseif MailPanel.szFilter == "attachments" then
		szText = g_tStrings.STR_MAIL_ATTACHMENT
	elseif MailPanel.szFilter == "empty" then
		szText = g_tStrings.STR_MAIL_EMPTY
	elseif MailPanel.szFilter == "read" then
		szText = g_tStrings.STR_MAIL_READ
	elseif MailPanel.szFilter == "unread" then
		szText = g_tStrings.STR_MAIL_UNREAD
	end
	page:Lookup("Btn_Fliter", "Text_Fliter"):SetText(szText)
end

function MailPanel.OnEvent(event)
	if event == "SEND_MAIL_RESULT" then
		MailPanel.OnSendMailResult(this:Lookup("PageSet_Total/Page_Send"), arg0, arg1)
	elseif event == "MAIL_LIST_UPDATE" then
		local page = this:Lookup("PageSet_Total/Page_Receive")
		MailPanel.UpdateMailList(page:Lookup("", "Handle_MailList"))
	elseif event == "MAIL_FILTER_CHANGED" then
		local page = this:Lookup("PageSet_Total/Page_Receive")
		MailPanel.UpdateFilterText(page)
		MailPanel.UpdateMailList(page:Lookup("", "Handle_MailList"))
	elseif event == "GET_MAIL_CONTENT" then
		MailPanel.OnGetMainContent(this:Lookup("PageSet_Total/Page_Receive"), arg0)
	elseif event == "MONEY_UPDATE" then
		MailPanel.UpdateSelfMoneyShow(this:Lookup("PageSet_Total/Page_Send", ""))
	elseif event == "PLAYER_FELLOWSHIP_UPDATE" or event == "PLAYER_FELLOWSHIP_CHANGE" then
		MailPanel.UpdateFrendList(this:Lookup("PageSet_Total/Page_Send", "Handle_NameList"))
	elseif event == "BAG_ITEM_UPDATE" then
		local hPage = this:Lookup("PageSet_Total/Page_Send")
		local handle = hPage:Lookup("", "Handle_Write")
		for i = 0, 7, 1 do
			local box = handle:Lookup("Box_Item"..i)
			if not box:IsEmpty() and box.nBag == arg0 and box.nIndex == arg1 then
				box:ClearObject()
				box:SetOverText(0, "")
				MailPanel.UpdateItemLock(handle)
			end
		end
		MailPanel.UpdateSendBtnState(hPage)
	end
end

function MailPanel.UpdateMailTitleByID(handle, dwID)
	local nCount = handle:GetItemCount() - 1
	for i = 0, nCount, 1 do
		local hI = handle:Lookup(i)
		if hI.dwID == dwID then
			MailPanel.UpdateMailTitle(hI)
			break
		end
	end
end

function MailPanel.OnGetMainContent(page, dwID)
	local MailClient = GetMailClient()
	local mailInfo = MailClient.GetMailInfo(dwID)
	if not mailInfo then
		return
	end

	local handle = page:Lookup("", "")
	if handle.dwSelID == dwID then
		handle.dwID = dwID
		if mailInfo.bGotContentFlag then
			mailInfo.Read()
			MailPanel.FireMailReadEvent(dwID)
		end
		MailPanel.UpdateMailInfo(handle)
	end

	local hList = handle:Lookup("Handle_MailList")
	MailPanel.UpdateMailTitleByID(hList, dwID)
	if MailPanel.bAutoDelete and not mailInfo.bItemFlag and not mailInfo.bMoneyFlag and mailInfo.bGotContentFlag and mailInfo.GetText() == "" then
		MailClient.DeleteMail(dwID)
		local nIndex = nil
		local nCount = hList:GetItemCount() - 1
		for i = 0, nCount, 1 do
			if hList:Lookup(i).dwID == dwID then
				nIndex = i
				break
			end
		end
		MailPanel.UpdateMailList(hList, nIndex)
	end
end

function MailPanel.ClearMailInfo(handle)
	handle:Lookup("Text_Name"):SetText("")
	handle:Lookup("Text_Name").szName = nil
	handle:Lookup("Text_Title"):SetText("")
	local hMsg = handle:Lookup("Handle_MailContent")
	hMsg:Lookup("Text_Message"):SetText("")
	hMsg:Lookup("Text_Risk"):SetText("")
	MailPanel.UpdateScrollInfo(hMsg)

	for i = 1, 8, 1 do
		handle:Lookup("Box_Item0"..i):Hide()
	end
	handle:Lookup("Box_Money"):Hide()

	local page = handle:GetParent()
	page.dwShowID = nil
	MailPanel.UpdateBtnState(page)
end

function MailPanel.UpdateMailInfo(handle)
	if not handle.dwID then
		MailPanel.ClearMailInfo(handle)
		return
	end
	local mailInfo = GetMailClient().GetMailInfo(handle.dwID)
	local szRisk = ""
	local hTextName = handle:Lookup("Text_Name")
	hTextName.szName = mailInfo.szSenderName
	local szContent = mailInfo.GetText()
	if mailInfo.GetType() == MAIL_TYPE.PLAYER then
		hTextName:SetText(g_tStrings.STR_MAIL_NO_SYSTEM .. mailInfo.szSenderName)
		local bRisk = MailPanel.IsRiskMail(szContent)
		if bRisk then
			szRisk = g_tStrings.STR_MAIL_HAVE_RISH .. "\n\n"
		end
	else
		hTextName:SetText(mailInfo.szSenderName)
	end
	handle:Lookup("Text_Title"):SetText(mailInfo.szTitle)

	for i = 1, 8, 1 do
		local box = handle:Lookup("Box_Item0"..i)
		local hImagePrice = handle:Lookup("Image_ItemPrice0"..i)
		local item, nPrice = mailInfo.GetItem(i - 1), mailInfo.nAllItemPrice
		box.bItemBox = true
		box.nIndex = i - 1
		box.dwID = handle.dwID
		if item then
			box:Show()
			box:SetObject(UI_OBJECT_ITEM_ONLY_ID, item.nUiId, item.dwID, item.nVersion, item.dwTabType, item.dwIndex)
			box:SetObjectIcon(Table_GetItemIconID(item.nUiId))
			UpdateItemBoxExtend(box, item)
			box:SetOverTextPosition(0, ITEM_POSITION.RIGHT_BOTTOM)
			box:SetOverTextFontScheme(0, 15)
			if item.bCanStack and item.nStackNum > 1 then
				box:SetOverText(0, item.nStackNum)
			else
				box:SetOverText(0, "")
			end
			if nPrice > 0 then
				hImagePrice:Show()
			else
				hImagePrice:Hide()
			end
		else
			hImagePrice:Hide()
			box:Hide()
		end
	end

	local box = handle:Lookup("Box_Money")
	if mailInfo.nMoney ~= 0 then
		box:SetObject(UI_OBJECT_NOT_NEED_KNOWN, 0)
		box:SetObjectIcon(582)
		box:Show()
		box.bMoney = true
		box.nMoney = mailInfo.nMoney
		box.dwID = handle.dwID
	else
		box:Hide()
	end
	
	local hMsg = handle:Lookup("Handle_MailContent")
	hMsg:Lookup("Text_Message"):SetText(szContent)
	hMsg:Lookup("Text_Risk"):SetText(szRisk)
	MailPanel.UpdateScrollInfo(hMsg)

	local page = handle:GetParent()
	page.dwShowID = handle.dwID
	MailPanel.UpdateBtnState(page)
end

function MailPanel.UpdateBtnState(page)

	local nChoose = 0
	local hList = page:Lookup("", "Handle_MailList")
	local nCount = hList:GetItemCount() - 1
	for i = 0, nCount, 1 do
		if hList:Lookup(i).bChoose then
			nChoose = nChoose + 1
		end
	end

	local mailInfo = nil
	if page.dwShowID then
		mailInfo = GetMailClient().GetMailInfo(page.dwShowID)
	end

	if nChoose > 0 then
		page:Lookup("Btn_Forward"):Enable(false)
		page:Lookup("Btn_Reply"):Enable(false)
		page:Lookup("Btn_Delete"):Enable(true)
		page:Lookup("Btn_Return"):Enable(false)
	elseif mailInfo then
		page:Lookup("Btn_Forward"):Enable(true)
		page:Lookup("Btn_Reply"):Enable(mailInfo.GetType() == MAIL_TYPE.PLAYER)
		page:Lookup("Btn_Delete"):Enable(true)
		page:Lookup("Btn_Return"):Enable(mailInfo.GetType() == MAIL_TYPE.PLAYER and (mailInfo.bMoneyFlag or mailInfo.bItemFlag))
	else
		page:Lookup("Btn_Forward"):Enable(false)
		page:Lookup("Btn_Reply"):Enable(false)
		page:Lookup("Btn_Delete"):Enable(false)
		page:Lookup("Btn_Return"):Enable(false)
	end
end

function MailPanel.FireMailReadEvent(dwID)
	local args = arg0
	arg0 = dwID
	FireEvent("MAIL_READED")
	arg0 = args
end

function MailPanel.SelectLetter(hI)
	local hP = hI:GetParent()
	local nCount = hP:GetItemCount() - 1
	for i = 0, nCount, 1 do
		local hB = hP:Lookup(i)
		hB.bSel = false
		MailPanel.UpdateMailTitle(hB)
	end
	hI.bSel = true
	local handle = hP:GetParent()
	local mailInfo = GetMailClient().GetMailInfo(hI.dwID)
	if mailInfo.bGotContentFlag then
		mailInfo.Read()
		MailPanel.FireMailReadEvent(hI.dwID)
		handle.dwID = hI.dwID
	else
		mailInfo.RequestContent(MailPanel.dwTargetID)
		handle.dwID = nil
	end
	handle.dwSelID = hI.dwID
	MailPanel.UpdateMailInfo(handle)

	MailPanel.UpdateMailTitle(hI)
end

function MailPanel.OnItemLButtonDown()
	if this.bDeliverItem then
		this.bIgnoreClick = false
		if IsCtrlKeyDown() then
			if not this:IsEmpty() then
				local _, dwBox, dwX = this:GetObjectData()
				if IsGMPanelReceiveItem() then
					GMPanel_LinkItem(dwBox, dwX)
				else
					EditBox_AppendLinkItem(dwBox, dwX)
				end
			end
			this.bIgnoreClick = true
		end
		if not this.bDisable then
			this:SetObjectPressed(1)
		end
	end
end

function MailPanel.OnItemLButtonUp()
	if this.bDeliverItem then
		if not this.bDisable then
			this:SetObjectPressed(0)
		end
	end
end


function MailPanel.OnItemLButtonClick()
	if this.bTitle then
		MailPanel.SelectLetter(this)
		PlaySound(SOUND.UI_SOUND, g_sound.PickupPaper)
	elseif this.bItemBox then
		if IsCtrlKeyDown() then
			local _, dwID = this:GetObjectData()
			if IsGMPanelReceiveItem() then
				GMPanel_LinkItem(dwID)
			else
				EditBox_AppendLinkItem(dwID)
			end
		else
			local mailInfo = GetMailClient().GetMailInfo(this.dwID)
			if mailInfo.nAllItemPrice > 0 then
				local hItemBox = this
				local tMsg = 
				{
					szName = "TakeItemSure",
					bRichText = true,
					szMessage = GetFormatText(g_tStrings.STR_MAIL_TAKE_PAY_MAIL1, 0) 
					.. GetMoneyTipText(mailInfo.nAllItemPrice, 0, true)
					.. GetFormatText(g_tStrings.STR_MAIL_TAKE_PAY_MAIL12, 0),
					fnAutoClose = function() if IsMailPanelOpened() then return false else return true end end,
					{
						szOption = g_tStrings.STR_HOTKEY_SURE,
						fnAction = function()
							if GetClientPlayer().GetMoney() < mailInfo.nAllItemPrice then
								OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_MAIL_TAKE_PAY_MAIL_NOT_ENOUGH_MONTY)
							else
								mailInfo.TakePayItem(hItemBox.nIndex)
								PlayItemSound(hItemBox:GetObjectData(), true)
							end
						end
					},
					{szOption = g_tStrings.STR_HOTKEY_CANCEL},
				}
				
				if CheckHaveLocked(SAFE_LOCK_EFFECT_TYPE.MAIL, "GiveMoney") then
					return
				end
	
				MessageBox(tMsg)
			else
				mailInfo.TakeItem(this.nIndex)
				PlayItemSound(this:GetObjectData(), true)
			end
			
		end
	elseif this.bMoney then
		local mailInfo = GetMailClient().GetMailInfo(this.dwID)
		mailInfo.TakeMoney()
		PlaySound(SOUND.UI_SOUND, g_sound.Trade)
	elseif this.bDeliverItem then
		if this.bIgnoreClick then
			this.bIgnoreClick = false
			return
		end

		if this.bDisable then
			return
		end
		if Hand_IsEmpty() then
			MailPanel.OnItemLButtonDrag()
		else
			MailPanel.OnItemLButtonDragEnd()
		end
	elseif this.bMailChoose then
		local hP = this:GetParent()
		hP.bChoose = not hP.bChoose
		MailPanel.UpdateMailTitle(hP)
		MailPanel.UpdateBtnState(hP:GetParent():GetParent():GetParent())
	end
end

function MailPanel.OnItemLButtonDBClick()
	MailPanel.OnItemLButtonClick()
end

function MailPanel.OnItemRButtonDown()
	if this.bDeliverItem then
		if not this.bDisable then
			this:SetObjectPressed(1)
		end
	end
end

function MailPanel.OnItemRButtonUp()
	if this.bDeliverItem then
		if not this.bDisable then
			this:SetObjectPressed(0)
		end
	end
end

function MailPanel.OnItemRButtonClick()
	if this.bItemBox then
		MailPanel.OnItemLButtonClick()
	elseif this.bMoney then
		MailPanel.OnItemLButtonClick()
	elseif this.bDeliverItem then
		if not this.bDisable then
			this:ClearObject()
			this:SetOverText(0, "")
			if this:IsObjectMouseOver() then
				MailPanel.OnItemMouseEnter()
			end
			local hPageSend = this:GetParent():GetParent():GetParent()
			MailPanel.UpdateLetterMoney(hPageSend)
			MailPanel.UpdateItemLock(this:GetParent())
			MailPanel.UpdateSendBtnState(hPageSend)
		end
	end
end

function MailPanel.OnItemMouseEnter()
	if this.bTitle then
		this.bOver = true
		MailPanel.UpdateMailTitle(this)
	elseif this.bItemBox then
		this:SetObjectMouseOver(true)
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
		local _, dwID = this:GetObjectData()
		OutputItemTip(UI_OBJECT_ITEM_ONLY_ID, dwID, nil, nil, {x, y, w, h})
	elseif this.bMoney then
		this:SetObjectMouseOver(true)
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
		local szTip = "<text>text="..EncodeComponentsString(g_tStrings.STR_MAIL_HAVE_MONEY).."</text>"..GetMoneyTipText(this.nMoney, 106)
		OutputTip(szTip, 300, {x, y, w, h})
	elseif this.bDeliverItem then
		if not this.bDisable then
			this:SetObjectMouseOver(true)
		end
		if this:IsEmpty() then
			local x, y = this:GetAbsPos()
			local w, h = this:GetSize()
			local szTip = "<text>text="..EncodeComponentsString(g_tStrings.MAIN_TIP6).."</text>"
			OutputTip(szTip, 300, {x, y, w, h})
		else
			local _, dwBox, dwX = this:GetObjectData()
			local x, y = this:GetAbsPos()
			local w, h = this:GetSize()
			OutputItemTip(UI_OBJECT_ITEM, dwBox, dwX, nil, {x, y, w, h})
		end
	elseif this.bMailChoose then
		this.bOver = true
		MailPanel.UpdateMailTitle(this:GetParent())
	end
end

function MailPanel.OnItemMouseLeave()
	if this.bTitle then
		this.bOver = false
		MailPanel.UpdateMailTitle(this)
	elseif this.bItemBox then
		this:SetObjectMouseOver(false)
		HideTip()
	elseif this.bMoney then
		this:SetObjectMouseOver(false)
		HideTip()
	elseif this.bDeliverItem then
		if not this.bDisable then
			this:SetObjectMouseOver(false)
		end
		HideTip()
	elseif this.bMailChoose then
		this.bOver = false
		MailPanel.UpdateMailTitle(this:GetParent())
	end
end

function MailPanel.OnItemLButtonDrag()
	if this.bDeliverItem then
		if this.bDisable then
			return
		end
		if Hand_IsEmpty() then
			if not this:IsEmpty() then
				if IsCursorInExclusiveMode() then
					OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.SRT_ERROR_CANCEL_CURSOR_STATE)
					PlayTipSound("010")
				else
					Hand_Pick(this)
					this:ClearObject()
					this:SetOverText(0, "")
					if this:IsObjectMouseOver() then
						MailPanel.OnItemMouseEnter()
					end
					local hPageSend = this:GetParent():GetParent():GetParent()
					MailPanel.UpdateLetterMoney(hPageSend)
					MailPanel.UpdateItemLock(this:GetParent())
					MailPanel.UpdateSendBtnState(hPageSend)
				end
			end
		end
	end
end

function MailPanel.OnItemLButtonDragEnd()
	if this.bDeliverItem then
		this.bIgnoreClick = true
		if this.bDisable then
			return
		end
		if Hand_IsEmpty() then
			return
		end
		local boxHand, nHandCount = Hand_Get()
		if boxHand:GetObjectType() ~= UI_OBJECT_ITEM then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_MSG_MAIL_ONLY_BAG_ITEM)
			return
		end

		local _, dwBox, dwX = boxHand:GetObjectData()
		if not IsObjectFromBag(dwBox) then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_MSG_MAIL_ONLY_BAG_ITEM)
			return
		end

		if nHandCount then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_MSG_MAIL_ONLY_GROUP_ITEM)
			return
		end

		local item = GetPlayerItem(GetClientPlayer(), dwBox, dwX)
		if not item then
			return
		end
		
		local itemInfo = GetItemInfo(item.dwTabType, item.dwIndex)
		if item.bBind and itemInfo.dwIgnoreBindMask == 0 then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.ERROR_MAIL_NOT_BOUND)
			return
		elseif itemInfo.nExistType ~= ITEM_EXIST_TYPE.PERMANENT then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.ERROR_MAIL_NOT_TIME_LIMIT)
			return
		end

		if this:IsEmpty() then
			Hand_Clear()
		else
			Hand_Pick(this)
		end

		this:SetObject(UI_OBJECT_ITEM, item.nUiId, dwBox, dwX, item.nVersion, item.dwTabType, item.dwIndex)
		this:SetObjectIcon(Table_GetItemIconID(item.nUiId))
		UpdateItemBoxExtend(this, item)
		this.nBag = dwBox
		this.nIndex = dwX
		if item and item.bCanStack and item.nStackNum > 1 then
			this:SetOverText(0, item.nStackNum)
		else
			this:SetOverText(0, "")
		end
		if this:IsObjectMouseOver() then
			MailPanel.OnItemMouseEnter()
		end
		local page = this:GetParent():GetParent():GetParent()
		MailPanel.UpdateLetterMoney(page)
		MailPanel.UpdateItemLock(this:GetParent())

		local edit = page:Lookup("Edit_Title")
		if edit:GetText() == "" then
			edit:SetText(GetItemNameByItem(item))
		end
		MailPanel.UpdateSendBtnState(this:GetParent():GetParent():GetParent())
	end
end


function MailPanel.UpdateMailTitle(hI)
	local mailInfo = GetMailClient().GetMailInfo(hI.dwID)

	if mailInfo.GetType() == MAIL_TYPE.PLAYER then
		hI:Lookup("Text_FromName"):SetText(g_tStrings.STR_MAIL_NO_SYSTEM .. mailInfo.szSenderName)
	else
		hI:Lookup("Text_FromName"):SetText(mailInfo.szSenderName)
	end
	
	hI:Lookup("Text_FromTitle"):SetText(mailInfo.szTitle)

	local dwTime = mailInfo.GetLeftTime()
	if dwTime < 86400 then
		hI:Lookup("Text_FromTime"):SetFontScheme(70)
	else
		hI:Lookup("Text_FromTime"):SetFontScheme(160)
	end
	local szTimeLeft = ""
	if dwTime >= 86400 then
		szTimeLeft = FormatString(g_tStrings.STR_MAIL_LEFT_DAY, math.floor(dwTime / 86400))
	elseif dwTime >= 3600 then
		szTimeLeft = FormatString(g_tStrings.STR_MAIL_LEFT_HOURE, math.floor(dwTime / 3600))
	elseif dwTime >= 60 then
		szTimeLeft = FormatString(g_tStrings.STR_MAIL_LEFT_MINUTE, math.floor(dwTime / 60))
	else
		szTimeLeft = g_tStrings.STR_MAIL_LEFT_LESS_ONE_M
	end
	hI:Lookup("Text_FromTime"):SetText(szTimeLeft)
	hI:SetUserData(-dwTime)

	local imgSelect = hI:Lookup("Image_Select")
	imgSelect.bMailChoose = true
	if hI.bChoose then
		if imgSelect.bOver then
			imgSelect:SetFrame(29)
		else
			imgSelect:SetFrame(30)
		end
	else
		if imgSelect.bOver then
			imgSelect:SetFrame(28)
		else
			imgSelect:SetFrame(27)
		end
	end

	local imgOver = hI:Lookup("Image_FromOver")
	if hI.bSel then
		imgOver:Show()
		imgOver:SetAlpha(255)
	elseif hI.bOver or imgSelect.bOver then
		imgOver:Show()
		imgOver:SetAlpha(128)
	else
		imgOver:Hide()
	end
	local nImageIndex = 5
	if mailInfo.GetType() == MAIL_TYPE.SYSTEM then
		nImageIndex = 1
	elseif mailInfo.GetType() == MAIL_TYPE.AUCTION then
		nImageIndex = 2
	elseif mailInfo.bPayFlag then
		nImageIndex = 3
	elseif mailInfo.bItemFlag then
		nImageIndex = 4
	else
		nImageIndex = 5
	end

	local hImageFlag = hI:Lookup("Image_Flag")
	local nGroup = 1
	if mailInfo.bReadFlag then
		nGroup = 2
	end
	hImageFlag:SetFrame(tMailFrame[nGroup][nImageIndex])
end

function MailPanel.UpdateMailList(handle, nIndex)
	handle:Clear()
	local szIniFile = "UI/Config/Default/MailPannelAdd.ini"

	local aMail = GetMailClient().GetMailList(MailPanel.szFilter) or {}
	for i, dwID in ipairs(aMail) do
		handle:AppendItemFromIni(szIniFile, "Handle_From")
		local hI = handle:Lookup(i - 1)
		hI.dwID = dwID
		hI.bTitle = true
		MailPanel.UpdateMailTitle(hI)
	end
	handle:Sort()
	MailPanel.UpdateScrollInfo(handle)

	local nCount = handle:GetItemCount()
	if nCount > 0 then
		if nIndex then
			if nIndex >= nCount then
				nIndex = nCount - 1
			end
			MailPanel.SelectLetter(handle:Lookup(nIndex))
		else
			local bDo = false
			local hP = handle:GetParent()
			local nCount = handle:GetItemCount() - 1
			for i = 0, nCount, 1 do
				local hI = handle:Lookup(i)
				if hI.dwID == hP.dwID then
					MailPanel.SelectLetter(hI)
					bDo = true
					break
				end
			end
			if not bDo then
				MailPanel.SelectLetter(handle:Lookup(0))
			end
		end
	else
		local h = handle:GetParent()
		h.dwSelID = nil
		h.dwID = nil
		MailPanel.UpdateMailInfo(h)
	end

	handle.bUpdated = true

	handle:GetParent():GetParent():Lookup("CheckBox_SelectAll"):Check(false)
end

function MailPanel.AddSender(page, szSender)
	local editN = page:Lookup("Edit_Name")
	if editN.bDisable then
		return
	end
	local szName = editN:GetText()
	local aS = MailPanel.GetSenderList(szName..";")
	if table.getn(aS) > 0 then
		local editCN = page:Lookup("Edit_CName")
		if editCN.bDisable then
			return
		end
		editCN.bNotUpdate = true
		if editCN:GetText() == "" then
			editCN:SetText(szSender)
		else
			editCN:SetText(editCN:GetText()..";"..szSender)
		end
		editCN.bNotUpdate = nil
	else
		editN.bNotUpdate = true
		editN:SetText(szSender)
		editN.bUpdate = nil
	end
end

function MailPanel.RemoveSender(page, szSender)
	local editCN = page:Lookup("Edit_CName")
	if editCN.bDisable then
		return
	end
	local szName = editCN:GetText()
	local aS = MailPanel.GetSenderList(szName..";")
	for i = table.getn(aS), 1, -1 do
		if aS[i] == szSender then
			local szResult = ""
			for k, v in pairs(aS) do
				if k ~= i then
					if szResult == "" then
						szResult = v
					else
						szResult = szResult..";"..v
					end
				end
			end

			editCN.bNotUpdate = true
			editCN:SetText(szResult)
			editCN.bNotUpdate = nil
			MailPanel.UpdateSenderList(page)
			return
		end
	end

	local editN = page:Lookup("Edit_Name")
	if editN.bDisable then
		return
	end
	local szName = editN:GetText()
	local aS = MailPanel.GetSenderList(szName..";")
	for i = table.getn(aS), 1, -1 do
		if aS[i] == szSender then
			local szResult = ""
			for k, v in pairs(aS) do
				if k ~= i then
					if szResult == "" then
						szResult = v
					else
						szResult = szResult..";"..v
					end
				end
			end

			editN.bNotUpdate = true
			editN:SetText(szResult)
			editN.bNotUpdate = nil
			MailPanel.UpdateSenderList(page)
			return
		end
	end
end

function MailPanel.UpdateSenderList(page)
	local aSel = {}
	local aS = MailPanel.GetSenderList(page:Lookup("Edit_CName"):GetText()..";")
	for k, v in pairs(aS) do
		table.insert(aSel, v)
	end
	aS = MailPanel.GetSenderList(page:Lookup("Edit_Name"):GetText()..";")
	for k, v in pairs(aS) do
		table.insert(aSel, v)
	end

	local handle = page:Lookup("", "Handle_NameList")
	local nCount = handle:GetItemCount() - 1
	for i = 0, nCount, 1 do
		local hI = handle:Lookup(i)
		local szName = hI:Lookup("Text_PName"):GetText()
		local bNotFind = true
		for k, v in pairs(aSel) do
			if v == szName then
				hI.bSel = true
				hI:Lookup("Image_Sel"):Show()
				bNotFind = false
				break
			end
		end
		if bNotFind then
			hI.bSel = nil
			hI:Lookup("Image_Sel"):Hide()
		end
	end
end

function MailPanel.UpdateFrendList(handle)
	handle:Clear()
	local szIniFile = "UI/Config/Default/MailPanelFriend.ini"
	local aFrend = GetClientPlayer().GetFellowshipNameList()
	if not aFrend then
		aFrend = {}
	end
	for index, szName in pairs(aFrend) do
		handle:AppendItemFromIni(szIniFile, "Handle_Name")
		local hI = handle:Lookup(handle:GetItemCount() - 1)
		hI:SetName("")
		hI:Lookup("Text_PName"):SetText(szName)
		hI.nIndex = k
		hI.OnItemLButtonClick = function()
			local hP = this:GetParent()
			if hP.bDisable then
				return
			end
			if this.bSel then
				this.bSel = nil
				this:Lookup("Image_Sel"):Hide()
				MailPanel.RemoveSender(hP:GetParent():GetParent(), this:Lookup("Text_PName"):GetText())
			else
				this.bSel = true
				this:Lookup("Image_Sel"):Show()
				MailPanel.AddSender(hP:GetParent():GetParent(), this:Lookup("Text_PName"):GetText())
			end
			PlaySound(SOUND.UI_SOUND, g_sound.Button)
		end
		hI.OnItemMouseEnter = function()
			this:Lookup("Image_NameOver"):Show()
		end
		hI.OnItemMouseLeave = function()
			this:Lookup("Image_NameOver"):Hide()
		end
	end
	MailPanel.UpdateScrollInfo(handle)
	MailPanel.UpdateSenderList(handle:GetParent():GetParent())
end

function MailPanel.OnActivePage()
	local nLast = this:GetLastActivePageIndex()
	local nPage = this:GetActivePageIndex()
	if nLast ~= -1 and nPage ~= nLast then
		PlaySound(SOUND.UI_SOUND, g_sound.OpenFrame)
	end

	local page = this:GetActivePage()
	local szName = page:GetName()
	if szName == "Page_Receive" then
		local hList = page:Lookup("", "Handle_MailList")
		if not hList.bUpdated then
			MailPanel.UpdateMailList(hList)
		end
	end
end

function MailPanel.UpdateSelfMoneyShow(handle)
    local nGold, nSilver, nCopper = MoneyToGoldSilverAndCopper(GetClientPlayer().GetMoney())
    local textG = handle:Lookup("Text_SGold")
    local textS = handle:Lookup("Text_SSliver")
    local textC = handle:Lookup("Text_SCopper")
    local imageG = handle:Lookup("Image_SGold")
    local imageS = handle:Lookup("Image_SSliver")
    local imageC = handle:Lookup("Image_SCopper")
    textG:SetText(nGold)
    textS:SetText(nSilver)
    textC:SetText(nCopper)
    imageG:Show()
    imageS:Show()
    imageC:Show()
    if nGold == 0 then
    	textG:SetText("")
    	imageG:Hide()
    	if nSilver == 0 then
    		textS:SetText("")
    		imageS:Hide()
    	end
    end
end

function MailPanel.UpdateSendBtnState(page)
	local editN = page:Lookup("Edit_Name")
	local editT = page:Lookup("Edit_Title")
	local btn = page:Lookup("Btn_Deliver")
	if not btn then
		return
	end
	
	if editN and editN:GetText() ~= "" and editT and editT:GetText() ~= "" then
		btn:Enable(true)
	else
		btn:Enable(false)
	end
	
	local bItem = false
	local hItemHandle = page:Lookup("", "Handle_Write")
	for i = 0, 7 do
		local hBox = hItemHandle:Lookup("Box_Item" .. i)
		if not hBox:IsEmpty() then
			bItem = true
		end
	end
	
	if not bItem and MailPanel.bPayMail then
		btn:Enable(false)
	end
end

function MailPanel.OnEditChanged()
	local szName = this:GetName()
	if szName == "Edit_Name" then
		local page = this:GetParent()
		MailPanel.UpdateSendBtnState(page)
		MailPanel.UpdateLetterMoney(page)
		if not this.bNotUpdate then
			MailPanel.UpdateSenderList(page)
		end
	elseif szName == "Edit_CName" then
		local page = this:GetParent()
		MailPanel.UpdateLetterMoney(page)
		if not this.bNotUpdate then
			MailPanel.UpdateSenderList(page)
		end
	elseif szName == "Edit_Title" then
		MailPanel.UpdateSendBtnState(this:GetParent())
--	elseif szName == "Edit_Message" then
	elseif szName == "Edit_Gold" or szName == "Edit_Silver" or szName == "Edit_Copper" then
		local szText = this:GetText()
		if szText ~= "" and tonumber(szText) ~= 0 then
			local edit = this:GetParent():Lookup("Edit_Title")
			if edit:GetText() == "" then
				edit:SetText(g_tStrings.STR_MAIL_TITLE_MONEY)
			end
		end
	elseif szName == "Edit_SearchName" then
		MailPanel.FindFrend(this:GetParent())
	elseif szName == "Edit_GoldPay" or szName == "Edit_SilverPay" or szName == "Edit_CopperPay" then
		if not MailPanel.bInit then
			local hPageSend = this:GetParent()
			local bOver = MailPanel.CheckPayMoneyOver(hPageSend)
			if bOver then
				MailPanel.bInit = true
				hPageSend:Lookup("Edit_GoldPay"):SetText(MAX_PAY_GOLD)
				hPageSend:Lookup("Edit_SilverPay"):SetText(0)
				hPageSend:Lookup("Edit_CopperPay"):SetText(0)
				MailPanel.bInit = false
			end
		end
	end
end

function MailPanel.CheckPayMoneyOver(hPageSend)
	local nGold = 0
	local szGold = hPageSend:Lookup("Edit_GoldPay"):GetText()
	if szGold ~= "" then
		nGold = tonumber(szGold)
	end
	local nSilver = 0
	local szSilver = hPageSend:Lookup("Edit_SilverPay"):GetText()
	if szSilver~= "" then
		nSilver = tonumber(szSilver)
	end
	
	local nCopper = 0
	local szCopper = hPageSend:Lookup("Edit_CopperPay"):GetText()
	if szCopper ~= "" then
		nCopper = tonumber(szCopper)
	end
	
	if nGold > MAX_PAY_GOLD then
		return true
	elseif nGold == MAX_PAY_GOLD then
		if nSilver > 0 or nCopper > 0 then
			return true
		end
	end
	
	return false
end

function MailPanel.OnEditSpecialKeyDown()
	local szKey = GetKeyName(Station.GetMessageKey())
	local szName = this:GetName()
	if szKey == "Enter" then
		if szName == "Edit_SearchName" then
			MailPanel.FindFrend(this:GetParent())
			return 1
		end
	elseif szKey == "Tab" then
		if szName == "Edit_Name" then
			Station.SetFocusWindow(this:GetParent():Lookup("Edit_CName"))
			return 1
		elseif szName == "Edit_CName" then
			Station.SetFocusWindow(this:GetParent():Lookup("Edit_Title"))
			return 1
		elseif szName == "Edit_Title" then
			Station.SetFocusWindow(this:GetParent():Lookup("Edit_Message"))
			return 1
		elseif szName == "Edit_Message" then
			Station.SetFocusWindow(this:GetParent():Lookup("Edit_Gold"))
			return 1
		elseif szName == "Edit_Gold" then
			Station.SetFocusWindow(this:GetParent():Lookup("Edit_Silver"))
			return 1
		elseif szName == "Edit_Silver" then
			Station.SetFocusWindow(this:GetParent():Lookup("Edit_Copper"))
			return 1
		elseif szName == "Edit_Copper" then
			Station.SetFocusWindow(this:GetParent():Lookup("Edit_SearchName"))
			return 1
		elseif szName == "Edit_SearchName" then
			Station.SetFocusWindow(this:GetParent():Lookup("Edit_Name"))
			return 1
		end
	end

	return 0
end

function MailPanel.OnLButtonDown()
	local szName = this:GetName()
	if szName == "Btn_Fliter" then
		if this.bIgnore then
			this.bIgnore = nil
			return
		end
		if not this:IsEnabled() then
			return
		end

		local btn = this
		local text = this:Lookup("", "Text_Fliter")
		local xA, yA = text:GetAbsPos()
		local w, h = text:GetSize()
		local menu =
		{
			nMiniWidth = w,
			x = xA, y = yA + h,
			fnCancelAction = function()
				if btn:IsValid() then
					local x, y = Cursor.GetPos()
					local xA, yA = btn:GetAbsPos()
					local w, h = btn:GetSize()
					if x >= xA and x < xA + w and y >= yA and y <= yA + h then
						btn.bIgnore = true
					end
				end
			end,
			fnAction = function(UserData, bCheck)
				if MailPanel.szFilter ~= UserData then
					MailPanel.szFilter = UserData
					FireEvent("MAIL_FILTER_CHANGED")
				end
			end,
			fnAutoClose = function() return not IsMailPanelOpened() end,

			{szOption = g_tStrings.STR_MAIL_ALL, UserData = "all"},
			{szOption = g_tStrings.STR_MAIL_PLAYER, UserData = "player"},
			{szOption = g_tStrings.STR_MAIL_AUCTION, UserData = "auction"},
			{szOption = g_tStrings.STR_MAIL_SYS, UserData = "system"},
			{szOption = g_tStrings.STR_MAIL_ATTACHMENT, UserData = "attachments"},
			{szOption = g_tStrings.STR_MAIL_EMPTY, UserData = "empty"},
			{szOption = g_tStrings.STR_MAIL_READ, UserData = "read"},
			{szOption = g_tStrings.STR_MAIL_UNREAD, UserData = "unread"},
		}
		PopupMenu(menu)
		return true
	else
		MailPanel.OnLButtonHold()
	end
end

function MailPanel.UpdateScrollInfo(hList)
	local scroll, btnUp, btnDown

	local szName = hList:GetName()

	local page = hList:GetParent():GetParent()
	if szName == "Handle_MailList" then
		scroll = page:Lookup("Scroll_MailList")
		btnUp = page:Lookup("Btn_MailListUp")
		btnDown = page:Lookup("Btn_MailListDown")
	elseif szName == "Handle_MailContent" then
		scroll = page:Lookup("Scroll_MailContent")
		btnUp = page:Lookup("Btn_MailContentUp")
		btnDown = page:Lookup("Btn_MailContentDown")
	elseif szName == "Handle_NameList" then
		scroll = page:Lookup("Scroll_PlayerList")
		btnUp = page:Lookup("Btn_PlayerListUp")
		btnDown = page:Lookup("Btn_PlayerListDown")
	end

	hList:FormatAllItemPos()
	local wAll, hAll = hList:GetAllItemSize()
    local w, h = hList:GetSize()
    local nCountStep = math.ceil((hAll - h) / 10)
    scroll:SetStepCount(nCountStep)
    if nCountStep > 0 and hList:IsVisible() then
    	scroll:Show()
    	btnUp:Show()
    	btnDown:Show()
    else
    	scroll:Hide()
    	btnUp:Hide()
    	btnDown:Hide()
    end
end


function MailPanel.OnLButtonHold()
	local szName = this:GetName()
	if szName == "Btn_MailListUp" then
		this:GetParent():Lookup("Scroll_MailList"):ScrollPrev(1)
	elseif szName == "Btn_MailListDown" then
		this:GetParent():Lookup("Scroll_MailList"):ScrollNext(1)
	elseif szName == "Btn_MailContentUp" then
		this:GetParent():Lookup("Scroll_MailContent"):ScrollPrev(1)
	elseif szName == "Btn_MailContentDown" then
		this:GetParent():Lookup("Scroll_MailContent"):ScrollNext(1)
	elseif szName == "Btn_PlayerListUp" then
		this:GetParent():Lookup("Scroll_PlayerList"):ScrollPrev(1)
	elseif szName == "Btn_PlayerListDown" then
		this:GetParent():Lookup("Scroll_PlayerList"):ScrollNext(1)
    end
end

function MailPanel.OnScrollBarPosChanged()
	local nCurrentValue = this:GetScrollPos()
	local szUpBtn, szDownBtn, szHandle, szStepLen
	local szName = this:GetName()
	if szName == "Scroll_MailList" then
		szUpBtn, szDownBtn, szHandle, nStep = "Btn_MailListUp", "Btn_MailListDown", "Handle_MailList", 10
	elseif szName == "Scroll_MailContent" then
		szUpBtn, szDownBtn, szHandle, nStep = "Btn_MailContentUp", "Btn_MailContentDown", "Handle_MailContent", 10
	elseif szName == "Scroll_PlayerList" then
		szUpBtn, szDownBtn, szHandle, nStep = "Btn_PlayerListUp", "Btn_PlayerListDown", "Handle_NameList", 10
	end
	local page = this:GetParent()
	if nCurrentValue == 0 then
		page:Lookup(szUpBtn):Enable(false)
	else
		page:Lookup(szUpBtn):Enable(true)
	end
	if nCurrentValue == this:GetStepCount() then
		page:Lookup(szDownBtn):Enable(false)
	else
		page:Lookup(szDownBtn):Enable(true)
	end
    page:Lookup("", szHandle):SetItemStartRelPos(0, - nCurrentValue * nStep)
end

function MailPanel.ReplyOrForward(pageR, bReply)
	local pageS = pageR:GetParent():Lookup("Page_Send")
	pageS:Lookup("Edit_Message"):SetText(pageR:Lookup("", "Handle_MailContent/Text_Message"):GetText())
	local szName = ""
	if bReply then
		local hTextName = pageR:Lookup("", "Text_Name")
		if hTextName.szName then
			szName = hTextName.szName
		end
	end
	pageS:Lookup("Edit_Name"):SetText(szName)
	pageS:Lookup("Edit_CName"):SetText("")
	local szTitle = pageR:Lookup("", "Text_Title"):GetText()
	if bReply then
		szTitle = FormatString(g_tStrings.STR_MAIL_REPLAY, szTitle)
	else
		szTitle = FormatString(g_tStrings.STR_MAIL_FORWARD, szTitle)
	end
	pageS:Lookup("Edit_Title"):SetText(szTitle)
	pageR:GetParent():ActivePage("Page_Send")

	if bReply then
		Station.SetFocusWindow(pageS:Lookup("Edit_Message"))
		pageS:Lookup("Edit_Message"):SelectAll()
	else
		Station.SetFocusWindow(pageS:Lookup("Edit_Name"))
	end
end

function MailPanel.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_Forward" then
		MailPanel.ReplyOrForward(this:GetParent(), false)
	elseif szName == "Btn_Reply" then
		MailPanel.ReplyOrForward(this:GetParent(), true)
	elseif szName == "Btn_Return" then
		local handle = this:GetParent():Lookup("", "")
		if not handle.dwID then
			return
		end
		local mailInfo = GetMailClient().GetMailInfo(handle.dwID)
		if not mailInfo then
			return
		end

		if not mailInfo.bMoneyFlag and not mailInfo.bItemFlag then
			local CantReturnMsg =
			{
				szMessage = g_tStrings.STR_MAIL_NO_ATTACHMENT_CANT_RETURN,
				szName = "CantReturnMailSure",
				fnAutoClose = function() return not IsMailPanelOpened() end,
				{szOption = g_tStrings.STR_HOTKEY_SURE},
			}
			MessageBox(CantReturnMsg)
			return
		end

		local hMailList = handle:Lookup("Handle_MailList")
		local nIndex = 0
		local nCount = hMailList:GetItemCount() - 1
		for i = 0, nCount, 1 do
			if hMailList:Lookup(i).bSel then
				nIndex = i
				break
			end
		end
		local dwMID = handle.dwID
		local fnReturnMail = function()
			GetMailClient().ReturnMail(dwMID)
			if hMailList:IsValid() then
				MailPanel.UpdateMailList(hMailList, nIndex)
			end
		end

		local msg =
		{
			szMessage = g_tStrings.STR_MAIL_RETURN_SURE,
			szName = "ReturnMailSure",
			fnAutoClose = function() return not IsMailPanelOpened() end,
			{szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = fnReturnMail },
			{szOption = g_tStrings.STR_HOTKEY_CANCEL},
		}
		MessageBox(msg)
	elseif szName == "Btn_Delete" then
		local handle = this:GetParent():Lookup("", "")
		local hMailList = handle:Lookup("Handle_MailList")
		local aDelete = {}
		local nCount = hMailList:GetItemCount() - 1
		local nIndex = nil
		for i = 0, nCount, 1 do
			local hI = hMailList:Lookup(i)
			if hI.bChoose then
				table.insert(aDelete, hI.dwID)
				if not nIndex then
					nIndex = i
				end
			end
			if hI.dwID == handle.dwID then
				nIndex = i
			end
		end

		local bSelect = true
		if #aDelete == 0 then
			bSelect = false
			if not handle.dwID then
				return
			else
				table.insert(aDelete, handle.dwID)
			end
		end
		local fnDelMail = function()
			local MailClient = GetMailClient()
			for k, v in ipairs(aDelete) do
				local mailInfo = GetMailClient().GetMailInfo(v)
				if mailInfo and not mailInfo.bItemFlag and not mailInfo.bMoneyFlag then
					MailClient.DeleteMail(v)
				end
			end
			if hMailList:IsValid() then
				MailPanel.UpdateMailList(hMailList, nIndex)
			end
		end

		local szMsg = g_tStrings.STR_MAIL_DEL_SURE
		if bSelect then
			szMsg = g_tStrings.STR_MAIL_DEL_SEL_SURE
		end
		local msg =
		{
			szMessage = szMsg,
			szName = "DelMailSure",
			fnAutoClose = function() return not IsMailPanelOpened() end,
			{szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = fnDelMail },
			{szOption = g_tStrings.STR_HOTKEY_CANCEL},
		}
		MessageBox(msg)
	elseif szName == "Btn_Deliver" then
		MailPanel.SendMail(this:GetParent())
		PlaySound(SOUND.UI_SOUND, g_sound.Mail)
	elseif szName == "Btn_Close" then
		CloseMailPanel()
	end
end

function MailPanel.OnCheckBoxCheck()
	local szName = this:GetName()
	if szName == "CheckBox_SelectAll" then
		local hList = this:GetParent():Lookup("", "Handle_MailList")
		local nCount = hList:GetItemCount() - 1
		for i = 0, nCount, 1 do
			local hI = hList:Lookup(i)
			if not hI.bChoose then
				hI.bChoose = true
				MailPanel.UpdateMailTitle(hI)
			end
		end
		MailPanel.UpdateBtnState(this:GetParent())
	elseif szName == "CheckBox_AutoDel" then
		MailPanel.bAutoDelete = true
	elseif szName == "CheckBox_PayMail" then
		local hPageSend = this:GetParent()
		MailPanel.UpdatePayEditState(hPageSend, true)
		MailPanel.UpdateSendBtnState(hPageSend)
	elseif szName == "CheckBox_Send" then
		local hPageSend = this:GetParent():Lookup("Page_Send")
		local bState = hPageSend:Lookup("CheckBox_PayMail"):IsCheckBoxChecked()
		MailPanel.UpdatePayEditState(hPageSend, bState)
	end
end

function MailPanel.OnCheckBoxUncheck()
	local szName = this:GetName()
	if szName == "CheckBox_SelectAll" then
		local hList = this:GetParent():Lookup("", "Handle_MailList")
		local nCount = hList:GetItemCount() - 1
		for i = 0, nCount, 1 do
			local hI = hList:Lookup(i)
			if hI.bChoose then
				hI.bChoose = false
				MailPanel.UpdateMailTitle(hI)
			end
		end
		MailPanel.UpdateBtnState(this:GetParent())
	elseif szName == "CheckBox_AutoDel" then
		MailPanel.bAutoDelete = false
	elseif szName == "CheckBox_PayMail" then
		local hPageSend = this:GetParent()
		MailPanel.UpdatePayEditState(hPageSend, false)
		MailPanel.UpdateSendBtnState(hPageSend)
	end
end

function MailPanel.UpdatePayEditState(hPageSend, bState)
	hPageSend:Lookup("Edit_Gold"):Enable(not bState)
	hPageSend:Lookup("Edit_Silver"):Enable(not bState)
	hPageSend:Lookup("Edit_Copper"):Enable(not bState)
	hPageSend:Lookup("Edit_GoldPay"):Enable(bState)
	hPageSend:Lookup("Edit_SilverPay"):Enable(bState)
	hPageSend:Lookup("Edit_CopperPay"):Enable(bState)
	hPageSend:Lookup("CheckBox_PayMail"):Check(bState)
	MailPanel.bPayMail = bState
	if bState then
		hPageSend:Lookup("", "Handle_TotalPrice/Text_TotalPrice"):SetFontScheme(173)
		hPageSend:Lookup("", "Handle_Write/Text_Money"):SetFontScheme(110)
		hPageSend:Lookup("Edit_Gold"):SetText("")
		hPageSend:Lookup("Edit_Silver"):SetText("")
		hPageSend:Lookup("Edit_Copper"):SetText("")
	else
		hPageSend:Lookup("", "Handle_TotalPrice/Text_TotalPrice"):SetFontScheme(110)
		hPageSend:Lookup("", "Handle_Write/Text_Money"):SetFontScheme(173)
		hPageSend:Lookup("Edit_GoldPay"):SetText("")
		hPageSend:Lookup("Edit_SilverPay"):SetText("")
		hPageSend:Lookup("Edit_CopperPay"):SetText("")
	end
end

function MailPanel.GetSenderList(szName)
	szName = StringReplaceW(szName, " ", "") --英文空格
	szName = StringReplaceW(szName, g_tStrings.STR_MAIL_CHINESE_SPACE, "") --中文空格
	szName = StringReplaceW(szName, g_tStrings.STR_MAIL_CHINESE_FEN, ";") --中文分号
	local t = {}

	local nStart = 1
	local nEnd = StringFindW(szName, ";")
	while nEnd do
		local w = string.sub(szName, nStart, nEnd - 1)
		if w and w ~= "" then
			table.insert(t, w)
		end
		nStart = nEnd + 1
		nEnd = StringFindW(szName, ";", nStart)
	end
	return t
end

function MailPanel.GetSendMoney(page)
	local nMoney = 0
	local szGold = page:Lookup("Edit_Gold"):GetText()
	if szGold ~= "" then
		nMoney = tonumber(szGold) * 10000
	end
	local szSilver = page:Lookup("Edit_Silver"):GetText()
	if szSilver ~= "" then
		nMoney = nMoney + tonumber(szSilver) * 100
	end
	local szCopper = page:Lookup("Edit_Copper"):GetText()
	if szCopper ~= "" then
		nMoney = nMoney + tonumber(szCopper)
	end
	return nMoney
end

function MailPanel.GetPayMoney(hPageSend)
	local nGold = 0
	local szGold = hPageSend:Lookup("Edit_GoldPay"):GetText()
	if szGold ~= "" then
		nGold = tonumber(szGold)
	end
	local nSilver = 0
	local szSilver = hPageSend:Lookup("Edit_SilverPay"):GetText()
	if szSilver~= "" then
		nSilver = tonumber(szSilver)
	end
	
	local nCopper = 0
	local szCopper = hPageSend:Lookup("Edit_CopperPay"):GetText()
	if szCopper ~= "" then
		nCopper = tonumber(szCopper)
	end
	
	local nPayMoney = GoldSilverAndCopperToMoney(nGold, nSilver, nCopper)
	return nPayMoney
end

function MailPanel.SendMail(page)
	if CheckHaveLocked(SAFE_LOCK_EFFECT_TYPE.MAIL, "send") then
		return
	end
		
	local szSendTitle = page:Lookup("Edit_Title"):GetText()
	local szReceiver = page:Lookup("Edit_Name"):GetText()

	local aLetter = {}
	--检测输入的正确性
	local aS = MailPanel.GetSenderList(szReceiver..";")
	local nS = table.getn(aS)
	if nS == 0 then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_MAIL_PLS_INPUT_NAME)
		return
	elseif nS ~= 1 then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_MAIL_ONLY_ONE_RECEIVER)
		return
	end

	if szSendTitle == "" then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_MAIL_PLS_INPUT_TITLE)
		return
	end

	--以后可能要检查又没有足够的money
	local nMoney = MailPanel.GetSendMoney(page)
	if nMoney + MailPanel.nSendMoney > GetClientPlayer().GetMoney() then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_MAIL_NOT_ENOUGHT_MONEY)
		return
	end

	if IsBagInSort() or IsBankInSort() then
		local handle = page:Lookup("", "Handle_Write")
		for i = 0, 7, 1 do
			local box = handle:Lookup("Box_Item"..i)
			if not box:IsEmpty() then
				OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_CANNOT_MAIL_ITEM_INSORT)
				return
			end
		end
	end

	local tMsg = 
	{
		szName = "SendMailSure",
		bRichText = true,
		fnAutoClose = function() if IsMailPanelOpened() then return false else return true end end,
		{
			szOption = g_tStrings.STR_HOTKEY_SURE,
			fnAction = function()
				local page = Station.Lookup("Normal/MailPanel/PageSet_Total/Page_Send")
				if page then
					MailPanel.SafeSendMail(page)
				end
			end
		},
		{szOption = g_tStrings.STR_HOTKEY_CANCEL},
	}
	if MailPanel.bPayMail then
		local nPayMoney = MailPanel.GetPayMoney(page)
		if nPayMoney == 0 then
			tMsg.szMessage = GetFormatText(g_tStrings.STR_MAIL_PAY_NULL, 0)
			MessageBox(tMsg)
		else
			MailPanel.SafeSendMail(page)
		end
		
	elseif nMoney > 0 then
		tMsg.szMessage = GetFormatText(g_tStrings.STR_MAIL_SEND_MONEY_SURE_1, 0) 
		.. GetMoneyTipText(nMoney, 0)
		.. GetFormatText(FormatString(g_tStrings.STR_MAIL_SEND_MONEY_SURE_2, aS[1]), 0)
		MessageBox(tMsg)
	else
		MailPanel.SafeSendMail(page)
	end
end

function MailPanel.SafeSendMail(page)
	local szSendTitle = page:Lookup("Edit_Title"):GetText()
	local szText = page:Lookup("Edit_Message"):GetText()
	local szReceiver = page:Lookup("Edit_Name"):GetText()
	local szCReceiver = page:Lookup("Edit_CName"):GetText()

	local aLetter = {}
	local aS = MailPanel.GetSenderList(szReceiver..";")
	local handle = page:Lookup("", "Handle_Write")

	local bFirst = true
	for k, v in pairs(aS) do
		if bFirst then
			bFirst = false
			local nMoneyToSend = 0
			local nMoneyToPay = 0
			if MailPanel.bPayMail then
				nMoneyToPay = MailPanel.GetPayMoney(page)
			else
				nMoneyToSend = MailPanel.GetSendMoney(page)
			end
			local Letter = {szName = v, szTitle = szSendTitle, szMsg = szText, nMoney = nMoneyToSend, nPrice = nMoneyToPay, aItem = {}}
			for i = 0, 7, 1 do
				local box = handle:Lookup("Box_Item"..i)
				if not box:IsEmpty() then
					table.insert(Letter.aItem, {dwBox = box.nBag, dwX = box.nIndex})
				end
			end
			table.insert(aLetter, Letter)
		else
			local Letter = {szName = v, szTitle = szSendTitle, szMsg = szText, nMoney = 0, bCopy = true, nPrice = 0, aItem = {}}
			table.insert(aLetter, Letter)
		end
	end

	--抄送人员名单
	local aCS = MailPanel.GetSenderList(szCReceiver..";")
	for k, v in pairs(aCS) do
		local Letter = {szName = v, szTitle = szSendTitle, szMsg = szText, nMoney = 0, bCopy = true, nPrice = 0, aItem = {}}
		table.insert(aLetter, Letter)
	end

	MailPanel.aLetter = aLetter
	page:Lookup("Edit_Title"):Enable(false)
	page:Lookup("Edit_Message"):Enable(false)
	page:Lookup("Edit_Name"):Enable(false)
	page:Lookup("Edit_Name").bDisable = true
	page:Lookup("Edit_CName"):Enable(false)
	page:Lookup("Edit_CName").bDisable = true
	page:Lookup("Edit_Gold"):Enable(false)
	page:Lookup("Edit_Silver"):Enable(false)
	page:Lookup("Edit_Copper"):Enable(false)
	page:Lookup("Edit_GoldPay"):Enable(false)
	page:Lookup("Edit_SilverPay"):Enable(false)
	page:Lookup("Edit_CopperPay"):Enable(false)

	page:Lookup("Btn_Deliver"):Enable(false)

	page:Lookup("", "Handle_NameList").bDisable = true

	for i = 0, 7, 1 do
		local box = handle:Lookup("Box_Item"..i)
		box:EnableObject(false)
		box.bDisable = true
	end

	MailPanel.OnSendMail(page)
end

function MailPanel.UpdateSendInfo(page, szText)
	page:Lookup("", "Text_Info"):SetText(szText)
end

function MailPanel.UpdateLetterMoney(page)

	local nCount = 1

	local aCS = MailPanel.GetSenderList(page:Lookup("Edit_CName"):GetText()..";")
	nCount = nCount + table.getn(aCS)

	if nCount == 1 then
		page:Lookup("", "Handle_Write/Text_Price"):SetText("30")
	else
		page:Lookup("", "Handle_Write/Text_Price"):SetText(nCount.." X 30")
	end
	MailPanel.nSendMoney = nCount * 30
end

function MailPanel.OnSendMailResult(page, nIndex, nCode)
	if not MailPanel.aLetter then
		return
	end

	MailPanel.nSendIndex = nil

	local bSuccess = false
	if nCode == MAIL_RESPOND_CODE.SUCCEED then
		bSuccess = true
	elseif nCode == MAIL_RESPOND_CODE.FAILED then
	elseif nCode == MAIL_RESPOND_CODE.SYSTEM_BUSY then
	elseif nCode == MAIL_RESPOND_CODE.DST_NOT_EXIST then
--		bSuccess = true
	elseif nCode == MAIL_RESPOND_CODE.NOT_ENOUGH_MONEY then
	elseif nCode == MAIL_RESPOND_CODE.ITEM_AMOUNT_LIMIT then
	elseif nCode == MAIL_RESPOND_CODE.NOT_ENOUGH_ROOM then
	elseif nCode == MAIL_RESPOND_CODE.MONEY_LIMIT then
	elseif nCode == MAIL_RESPOND_CODE.MAIL_NOT_FOUND then
	elseif nCode == MAIL_RESPOND_CODE.TOTAL then
	end

	if MailPanel.aLetter[nIndex] then
		MailPanel.aLetter[nIndex].bSuccess = bSuccess
	end

	local bEnd = MailPanel.OnSendMail(page)

	if bEnd then
		local szName = ""
		local szCName = ""
		local bAllSuccess = true
		local bMoneyFail = false
		local bPayMailFail = false
		local handle = page:Lookup("", "Handle_Write")

		local nTotalCount = table.getn(MailPanel.aLetter)
		local nFailedCount = 0
		for k, v in pairs(MailPanel.aLetter) do
			if not v.bSuccess then
				nFailedCount = nFailedCount + 1
				bAllSuccess = false
				if v.bCopy then
					if szCName == "" then
						szCName = v.szName
					else
						szCName = szCName..";"..v.szName
					end
				else
					szName = v.szName
				end
				if v.nMoney ~= 0 then
					bMoneyFail = true
				end
				if v.nPrice ~= 0 then
					bPayMailFail = true
				end
			end
		end

		local editT = page:Lookup("Edit_Title")
		local editM = page:Lookup("Edit_Message")
		local editN = page:Lookup("Edit_Name")
		local editCN = page:Lookup("Edit_CName")
		local editG = page:Lookup("Edit_Gold")
		local editS = page:Lookup("Edit_Silver")
		local editC = page:Lookup("Edit_Copper")
		editT:Enable(true)
		editM:Enable(true)
		editN:Enable(true)
		editN.bDisable = nil
		editCN:Enable(true)
		editCN.bDisable = nil
		editG:Enable(true)
		editS:Enable(true)
		editC:Enable(true)

		page:Lookup("", "Handle_NameList").bDisable = nil

		if not bMoneyFail then
			editG:SetText("")
			editS:SetText("")
			editC:SetText("")
		end
		
		if not bPayMailFail then
			page:Lookup("Edit_GoldPay"):SetText("")
			page:Lookup("Edit_SilverPay"):SetText("")
			page:Lookup("Edit_CopperPay"):SetText("")
			MailPanel.UpdatePayEditState(page, false)
		end

		for i = 0, 7, 1 do
			local box = handle:Lookup("Box_Item"..i)
			box:EnableObject(true)
			box.bDisable = nil
			box:ClearObject()
			box:SetOverText(0, "")
		end

		MailPanel.UpdateSendBtnState(page)
		editN.bNotUpdate = true
		editCN.bNotUpdate = true
		editN:SetText(szName)
		editCN:SetText(szCName)
		editN.bNotUpdate = nil
		editCN.bNotUpdate = nil
		MailPanel.UpdateSenderList(page)
		MailPanel.UpdateItemLock(handle)

		if bAllSuccess then
			editT:SetText("")
			editM:SetText("")

			MailPanel.UpdateSendInfo(page, g_tStrings.STR_MAIL_SEND_OK)
		else
			MailPanel.UpdateSendInfo(page, FormatString(g_tStrings.STR_MAIL_SEND_TOTAL_ONFO, nTotalCount, nFailedCount))
		end

		MailPanel.UpdateSendBtnState(page)
		MailPanel.aLetter = nil
	end
end

function MailPanel.OnSendMail(page)
	if not MailPanel.aLetter then
		return true
	end

	local MailClient = GetMailClient()

	local nCount = table.getn(MailPanel.aLetter)
	local bEnd = true
	for k, v in pairs(MailPanel.aLetter) do
		if not v.bSend then
			MailPanel.nSendIndex = k
			MailPanel.UpdateSendInfo(page, FormatString(g_tStrings.STR_MAIL_SEND_INFO, k, nCount))

			v.bSend = true
			MailClient.SendMail(k, MailPanel.dwTargetID, v.szName, v.szTitle, v.szMsg, v.nMoney, v.nPrice, v.aItem)
			bEnd = false
			break
		end
	end

	if not GetClientPlayer().IsAchievementAcquired(999) then
		RemoteCallToServer("OnClientAddAchievement", "Mail_First_Send")
	end

	return bEnd
end

function MailPanel.FindFrend(page)
	local edit = page:Lookup("Edit_SearchName")
	local szInput = edit:GetText()

	local handle = page:Lookup("", "Handle_NameList")
	local nCount = handle:GetItemCount() - 1
	if szInput == "" then
		for i = 0, nCount, 1 do
			local hI = handle:Lookup(i)
			hI:SetUserData(hI.nIndex)
			hI:LockShowAndHide(false)
		end
	else
		for i = 0, nCount, 1 do
			local bFind = false
			local hI = handle:Lookup(i)
			local nUserData = 10000
			local szName = hI:Lookup("Text_PName"):GetText()
			if szName == szInput then
				nUserData = 1
				bFind = true
			else
				local nPos = StringFindW(szName, szInput)
				if nPos then
					nUserData = 2 + nPos
					bFind = true
				end
			end
			if bFind then
				hI:LockShowAndHide(false)
			else
				hI:LockShowAndHide(true)
				hI:Hide()
			end
			hI:SetUserData(nUserData)
		end
	end
	handle:Sort()
	handle:FormatAllItemPos()
	page:Lookup("Scroll_PlayerList"):ScrollHome()
end

local function MailPanel_StringFindCharW(szText, szChar)
	if StringFindW(szText, szChar) then
		return true
	end
	return false
end

function MailPanel.IsRiskMail(szContent)
	local bRisk = false
	local bHaveMustChar = false
	local nCount = 0
	for i = 1, StringLengthW(szContent) do
		local szChar = StringSubW(szContent, i, i)
		local bIsMayChar = MailPanel_StringFindCharW(CHARACTER_SET_MAIL_MAY_HAVE_RISK, szChar)
		if not bIsMayChar then
			bIsMayChar = not IsWPrint(szChar)
		end
		local bIsMustchar = false
		if not bIsMayChar then
			bIsMustchar = MailPanel_StringFindCharW(CHARACTER_SET_MAIL_MUST_HAVE_RISK, szChar)
			if bIsMustchar then
				bHaveMustChar = true
			end
		end
		
		if bIsMayChar or bIsMustchar then
			nCount = nCount + 1
		else
			nCount = 0
			bHaveMustChar = false
		end
		if nCount >= MIN_RISK_CHARACTER_APPEAR_NUM and bHaveMustChar then
			bRisk = true
			break
		end
	end
	
	return bRisk
end

function OpenMailPanel(dwTargetType, dwTargetID, bDisableSound)
	if IsOptionOrOptionChildPanelOpened() then
		return
	end

	if not GetClientPlayer().IsAchievementAcquired(995) then
		RemoteCallToServer("OnClientAddAchievement", "Mail_Frist_Use")
	end

	local player = GetClientPlayer()
	if not player or player.nMoveState == MOVE_STATE.ON_DEATH then
		return
	end

	MailPanel.dwTargetType = dwTargetType
	MailPanel.dwTargetID = dwTargetID

	Wnd.OpenWindow("MailPanel")

	MailPanel.UpdateItemLock()

	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
	FireHelpEvent("OnOpenpanel", "MAIL")
end

function IsMailPanelOpened()
	local frame = Station.Lookup("Normal/MailPanel")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end

function CloseMailPanel(bDisableSound)
	MailPanel.UpdateItemLock()
	Wnd.CloseWindow("MailPanel")
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end
end

function AppendMailItem(dwBox, dwX)
	local item = GetPlayerItem(GetClientPlayer(), dwBox, dwX)
	if not item then
		return
	end
	
	local itemInfo = GetItemInfo(item.dwTabType, item.dwIndex)
	if item.bBind and itemInfo.dwIgnoreBindMask == 0 then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.ERROR_MAIL_NOT_BOUND)
		return
	elseif itemInfo.nExistType ~= ITEM_EXIST_TYPE.PERMANENT then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.ERROR_MAIL_NOT_TIME_LIMIT)
		return
	end

	local page = Station.Lookup("Normal/MailPanel/PageSet_Total/Page_Send")
	if not page then
		return
	end
	local handle = page:Lookup("", "Handle_Write")
	if not handle then
		return
	end
	for i = 0, 7, 1 do
		local box = handle:Lookup("Box_Item"..i)
		if not box.bDisable and box:IsEmpty() then
			box:SetObject(UI_OBJECT_ITEM, item.nUiId, dwBox, dwX, item.nVersion, item.dwTabType, item.dwIndex)
			box:SetObjectIcon(Table_GetItemIconID(item.nUiId))
			UpdateItemBoxExtend(box, item)
			box.nBag = dwBox
			box.nIndex = dwX
			if item and item.bCanStack and item.nStackNum > 1 then
				box:SetOverText(0, item.nStackNum)
			else
				box:SetOverText(0, "")
			end
			if box:IsObjectMouseOver() then
				local thisSave = this
				this = box
				MailPanel.OnItemMouseEnter()
				this = thisSave
			end
			MailPanel.UpdateLetterMoney(handle:GetParent():GetParent())
			MailPanel.UpdateItemLock(handle)

			local edit = page:Lookup("Edit_Title")
			if edit:GetText() == "" then
				edit:SetText(GetItemNameByItem(item))
			end
			MailPanel.UpdateSendBtnState(page)
			return
		end
	end
	OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_ERROR_MAIL_ITEM_IS_FULL);
	PlayTipSound("004")
end
