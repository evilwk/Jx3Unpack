
ItemBox = {}

local ITEMBOX_INI_FILE = "ui/config/default/ItemBox.ini"

function ItemBox.OnFrameCreate()
	this:RegisterEvent("UI_SCALED")
end

function ItemBox.OnEvent(szEvent)
	if szEvent == "UI_SCALED" then
		ItemBox.UpdateSize(this)
		ItemBox.UpdateScrollInfo(this:Lookup("", "Handle_Desc"))
		ItemBox.UpdateScrollInfo(this:Lookup("", "Handle_Item"))
	end
end

function ItemBox.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_Close" then
    	CloseItemBox()
  elseif szName == "Btn_Sure" then
  	local hFrame = this:GetRoot()
  	if hFrame.fnSureAction then
    	hFrame.fnSureAction(hFrame.tItemList)
    else
	  	if hFrame.dwBagIndex and hFrame.dwPos then
	  		if hFrame.bBreak then
	  			RemoteCallToServer("OnBreakEquip", hFrame.dwBagIndex, hFrame.dwPos)
	  		else
	  			RemoteCallToServer("OnLootBoxItem", hFrame.dwBagIndex, hFrame.dwPos)
	  		end	
	  	end
  		CloseItemBox()
  	end
  end	
end

function ItemBox.OnItemMouseEnter()
	local szName = this:GetName()
	if szName == "Box_Item" then
		local nPosX, nPosY = this:GetAbsPos()
		local nWidth, nHeight = this:GetSize()
		this:SetObjectMouseOver(true)
		OutputItemTip(
			UI_OBJECT_ITEM_INFO, 
			0, 
			this.dwTabType, 
			this.dwIndex, 
			{nPosX, nPosY, nWidth, nHeight},
			nil, nil, nil, nil, this.nBookID
		)
	end
end

function ItemBox.OnItemMouseLeave()
	local szName = this:GetName()
	if szName == "Box_Item" then
		this:SetObjectMouseOver(false)
	end
	HideTip()
end

function ItemBox.SetEncodeDesc(hFrame, szEncodeDesc)
	local hDesc = hFrame:Lookup("", "Handle_Desc")
	hDesc:Clear()
	
	if not szEncodeDesc then
		return
	end

	local _, tDescList = GWTextEncoder_Encode(szEncodeDesc)
	if not tDescList then
		return
	end
	
	local hPlayer = GetClientPlayer()
	if not hPlayer then
		return
	end

	for nIndex, tDesc in ipairs(tDescList) do
		if tDesc.name == "text" then
			hDesc:AppendItemFromString(GetFormatText(tDesc.context, 162))
		elseif tDesc.name == "N" then
			hDesc:AppendItemFromString(GetFormatText(hPlayer.szName, 162))
		elseif tDesc.name == "C" then
			hDesc:AppendItemFromString(GetFormatText(g_tStrings.tRoleTypeToName[hPlayer.nRoleType], 162))
		elseif tDesc.name == "F" then
			hDesc:AppendItemFromString(GetFormatText(tDesc.attribute.text, tDesc.attribute.fontid))
		elseif tDesc.name == "T" then
			if not tDesc.attribute.paramid then
				if tDesc.attribute.tipid then
					hDesc:AppendItemFromString("<image>eventid=256 path=\"fromiconid\" frame=" .. hDesc.attribute.picid .. "</image>")
					local img = hDesc:Lookup(hDesc:GetItemCount() - 1)
					img.nTipID = tonumber(hDesc.attribute.tipid)
					img.bTipPic = true
				else
					hDesc:AppendItemFromString("<image>path=\"fromiconid\" frame=" .. hDesc.attribute.picid .. "</image>")
				end
			end
		elseif tDesc.name == "H" then
			hDesc:AppendItemFromString("<null>h=" .. tDesc.attribute.height .. "</null>")
		elseif tDesc.name == "G" then
			local szSpace = g_tStrings.STR_TWO_CHINESE_SPACE
			if tDesc.attribute.english then
				szSpace = "    "
			end
			hDesc:AppendItemFromString("<text>text=\"".. szSpace .. "\" font=160</text>")
		elseif tDesc.name == "J" then
			local nMoney = tonumber(tDesc.attribute.money)
			local nFontID = 162
			if tDesc.attribute.compare and nMoney > hPlayer.GetMoney() then
				nFontID = 166
			end
			hDesc:AppendItemFromString(GetMoneyText(nMoney, "font=" .. nFontID))
		else
			if tDesc.context then
				hDesc:AppendItemFromString(GetFormatText("<" .. tDesc.context .. ">", 162))
			end
		end
	end
	hDesc:FormatAllItemPos()
end

function ItemBox.SetItemList(hFrame, tItemList)
	local hItemList = hFrame:Lookup("", "Handle_Item")
	hItemList:Clear()
	
	if not tItemList then
		return
	end
	
	for nIndex, tItem in ipairs(tItemList) do
		local hItemInfo = GetItemInfo(tItem.dwTabType, tItem.dwIndex)
		local nIconID = Table_GetItemIconID(hItemInfo.nUiId)
		
		local hItem = hItemList:AppendItemFromIni(ITEMBOX_INI_FILE, "Handle_Box")
		local hBox = hItem:Lookup("Box_Item")
		hBox.dwTabType = tItem.dwTabType
		hBox.dwIndex = tItem.dwIndex
		hBox.nStackNum = tItem.nStackNum
		hBox.nBookID = tItem.nBookID
		-- hBox:SetBoxIndex(nIndex)
		hBox:SetObject(UI_OBJECT_ITEM)
		hBox:SetObjectIcon(nIconID)
		UpdateItemBoxExtend(hBox, hItemInfo)
		if tItem.bCanStack and tItem.nStackNum > 1 then
			hBox:SetOverText(0, tItem.nStackNum)
		else
			hBox:SetOverText("")
		end
		
		local hTextItem = hItem:Lookup("Text_Item")
		local szItemName = GetItemNameByItemInfo(hItemInfo, tItem.nBookID)
		hTextItem:SetText(szItemName)
		local nR, nG, nB = GetItemFontColorByQuality(hItemInfo.nQuality)
		hTextItem:SetFontColor(nR, nG, nB)
	end
	hItemList:FormatAllItemPos()
end

function ItemBox.UpdateSize(hFrame)
	local hDesc = hFrame:Lookup("", "Handle_Desc")
	
	local _, nPosY = hDesc:GetRelPos()
	local _, nDescHeight = hDesc:GetAllItemSize()
	local hImgBreak = hFrame:Lookup("", "Image_Break")
	if nDescHeight > 0 then
		if nDescHeight > 180 then
			nDescHeight = 180
		end
		SetWidgetHeight(hDesc, nDescHeight)
		
		SetWidgetHeight(hFrame:Lookup("Scroll_List"), nDescHeight - 36)
		SetWidgetRelPosY(hFrame:Lookup("Btn_Down"), nPosY + nDescHeight - 20)
		
		nPosY = nPosY + nDescHeight + 5
		
		SetWidgetRelPosY(hImgBreak, nPosY)
		hImgBreak:Show()
		local _, nBreakHeight = hImgBreak:GetSize()
		nPosY = nPosY + nBreakHeight + 5
	else
		hImgBreak:Hide()		
	end
	
	local nItemNewHeight = 320
	if nDescHeight > 0 then
		local _, nDescPosY = hDesc:GetRelPos()
		nItemNewHeight = nItemNewHeight + nDescPosY - nPosY
	end
	
	local hItemList = hFrame:Lookup("", "Handle_Item")
	local _, nItemHeight = hItemList:GetAllItemSize()
	if nItemHeight < nItemNewHeight then
		nItemNewHeight = nItemHeight
	end
	
	SetWidgetHeight(hItemList, nItemNewHeight)
	SetWidgetRelPosY(hItemList, nPosY)
	
	local hItemScroll = hFrame:Lookup("Scroll_Item")
	SetWidgetHeight(hItemScroll, nItemNewHeight - 36)
	SetWidgetRelPosY(hItemScroll, nPosY + 15)
	
	SetWidgetRelPosY(hFrame:Lookup("Btn_UpItem"), nPosY)
	SetWidgetRelPosY(hFrame:Lookup("Btn_DownItem"), nPosY + nItemNewHeight - 20)
	
	nPosY = nPosY + nItemNewHeight + 10
	
	local nFrameNewHeight = nPosY + 35
	if nFrameNewHeight < 300 then
		nFrameNewHeight = 300
	end
	
	SetWidgetRelPosY(hFrame:Lookup("Btn_Sure"), nFrameNewHeight - 33)
	
	local _, nHeadHeight = hFrame:Lookup("", "Image_CBg1"):GetSize()
	local _, nFootHeight = hFrame:Lookup("", "Image_CBg8"):GetSize()
	local nCenterBgHeight = nFrameNewHeight - nHeadHeight - nFootHeight
	
	SetWidgetHeight(hFrame:Lookup("", "Image_CBg3"), nCenterBgHeight)
	SetWidgetHeight(hFrame:Lookup("", "Image_CBg4"), nCenterBgHeight)
	SetWidgetHeight(hFrame:Lookup("", "Image_CBg5"), nCenterBgHeight)
	
	local hTotal = hFrame:Lookup("", "")
	SetWidgetHeight(hTotal, nFrameNewHeight)
	hTotal:FormatAllItemPos()
	
	SetWidgetHeight(hFrame, nFrameNewHeight)
	
	local nPosX, nPosY = Cursor.GetPos()
	local nClientWidth, nClientHeight = Station.GetClientSize()
	local nFrameWidth, _ = hFrame:GetSize()
	if nPosX > nClientWidth / 2 then
		nPosX = nPosX - nFrameWidth
	end
	if nPosY > nClientHeight / 2 then
		nPosY = nPosY - nFrameNewHeight
	end
	
	hFrame:SetRelPos(nPosX, nPosY)
	hFrame:CorrectPos()
end

function OpenItemBoxByItem(bResult, dwBagIndex, dwPos)
	if not bResult then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_MSG_OPEN_ITEMBOX_FAIL)
		PlayTipSound("017")
		return
	end
	
	local hPlayer = GetClientPlayer()
	if not hPlayer then
		return
	end
	
	local hBox = hPlayer.GetItem(dwBagIndex, dwPos)
	if not hBox then
		return
	end
	
	local hBoxInfo = GetItemInfo(hBox.dwTabType, hBox.dwIndex)
	if not hBoxInfo then
		return
	end
	
	hPlayer.OpenBox(dwBagIndex, dwPos)
	
	local tItemObjList = hPlayer.GetBoxItem()
		
	local tBoxInfo = g_tTable.BoxInfo:Search(hBoxInfo.dwBoxTemplateID)
	
	local hFrame = OpenItemBox(tBoxInfo.szTitle, tBoxInfo.szDesc, tItemObjList)
	hFrame.dwBagIndex = dwBagIndex
	hFrame.dwPos = dwPos
end

function OpenItemBoxByCraft(dwBagIndex, dwPos)
	local hPlayer = GetClientPlayer()
	if not hPlayer then
		return
	end
	
	local hEquip = hPlayer.GetItem(dwBagIndex, dwPos)
	if not hEquip then
		return
	end
	
	hPlayer.BreakEquip(dwBagIndex, dwPos)
	local tDiamond = GetDisplayDiamonds()
	local nTop = #tDiamond
	local tItemList = {}
	
	for i, hDiamond in ipairs(tDiamond) do	--使相同的宝石叠加显示
		local bFlag = false
		for _, tItem in ipairs(tItemList) do
			if tItem.dwTabType == hDiamond.dwTabType and tItem.dwIndex == hDiamond.dwIndex then
				tItem.nStackNum = tItem.nStackNum + 1
				bFlag = true
				break
			end
		end
		if not bFlag then
			local tNewItem = {}
			tNewItem.dwTabType = hDiamond.dwTabType
			tNewItem.dwIndex = hDiamond.dwIndex
			tNewItem.bCanStack = hDiamond.bCanStack
			tNewItem.nStackNum = hDiamond.nStackNum
			table.insert(tItemList, tNewItem)
		end
	end
	
	local hFrame = OpenItemBox(g_tStrings.BREAK_EQUIP_BOX_TITLE, g_tStrings.BREAK_EQUIP_BOX_DESC, tItemList)
	hFrame.dwBagIndex = dwBagIndex
	hFrame.dwPos = dwPos
	hFrame.bBreak = true
end

function OpenItemBox(szTitle, szDesc, tItemList, fnSureAction, bDisableSound)
	local hFrame = Station.Lookup("Topmost/ItemBox")
	if not hFrame then
		hFrame = Wnd.OpenWindow("ItemBox")
	end
	
	local hTextTitle = hFrame:Lookup("", "Text_BoxTitle")
	hTextTitle:SetText(szTitle or "")
	
	ItemBox.SetEncodeDesc(hFrame, szDesc)
	ItemBox.SetItemList(hFrame, tItemList)
	ItemBox.UpdateSize(hFrame)
	hFrame.fnSureAction = fnSureAction
	
	ItemBox.UpdateScrollInfo(hFrame:Lookup("", "Handle_Desc"))
	ItemBox.UpdateScrollInfo(hFrame:Lookup("", "Handle_Item"))
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND, g_sound.OpenFrame)
	end
	
	return hFrame
end

function CloseItemBox(bDisableSound)
	Wnd.CloseWindow("ItemBox")
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND, g_sound.CloseFrame)
	end
end

function IsItemBoxOpened()
	return Station.Lookup("Topmost/ItemBox")
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- 滚动条通用实现，维护以下常量表

local SCROLLBAR_LIST = 
{
	Handle_Desc = { szBtnUp = "Btn_Up", szBtnDown = "Btn_Down", szScroll = "Scroll_List", },
	Handle_Item = { szBtnUp = "Btn_UpItem", szBtnDown = "Btn_DownItem", szScroll = "Scroll_Item" },
}

function ItemBox.UpdateScrollInfo(hList)
	hList:FormatAllItemPos()
	
	local szList = hList:GetName()
	if not SCROLLBAR_LIST[szList] then
		return
	end
	
	local _, nItemHeight = hList:GetAllItemSize()
	local _, nHeight = hList:GetSize()
	
	local hFrame = hList:GetRoot()
	local hScroll = hFrame:Lookup(SCROLLBAR_LIST[szList].szScroll)
	
	nItemHeight = math.floor(nItemHeight)
	nHeight = math.floor(nHeight)
	local nCountStep = math.ceil((nItemHeight - nHeight) / 10)
	hScroll:SetStepCount(nCountStep)
	
	if not hList.nScrollPos then
		hList.nScrollPos = 0
	end
	hScroll:SetScrollPos(hList.nScrollPos)
	
	local hBtnUp = hFrame:Lookup(SCROLLBAR_LIST[szList].szBtnUp)
	local hBtnDown = hFrame:Lookup(SCROLLBAR_LIST[szList].szBtnDown)
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

function ItemBox.OnLButtonHold()
	local szName = this:GetName()
	local hFrame = this:GetRoot()
	for _, tScroll in pairs(SCROLLBAR_LIST) do
		if szName == tScroll.szBtnUp then
			hFrame:Lookup(tScroll.szScroll):ScrollPrev(1)
			break
		elseif szName == tScroll.szBtnDown then
			hFrame:Lookup(tScroll.szScroll):ScrollNext(1)
			break
		end
	end
end

function ItemBox.OnLButtonDown()
	ItemBox.OnLButtonHold()
end

function ItemBox.OnScrollBarPosChanged()
	local hFrame = this:GetRoot()
	local szName = this:GetName()
		
	local nCurrentValue = this:GetScrollPos()
	for szList, tScroll in pairs(SCROLLBAR_LIST) do
		if szName == tScroll.szScroll then
			local hBtnUp = hFrame:Lookup(tScroll.szBtnUp)
			local hBtnDown = hFrame:Lookup(tScroll.szBtnDown)
			hBtnUp:Enable(nCurrentValue ~= 0)
			hBtnUp:Enable(nCurrentValue ~= this:GetStepCount())
			
		    hFrame:Lookup("", szList):SetItemStartRelPos(0, - nCurrentValue * 10)
		    break
		end
	end
end

function ItemBox.OnItemMouseWheel()
	local szName = this:GetName()
	local hFrame = this:GetRoot()
	for szList, tScroll in pairs(SCROLLBAR_LIST) do
		if szName == szList then
			local hScroll = hFrame:Lookup(tScroll.szScroll)
			if hScroll:IsVisible() then
				local nDistance = Station.GetMessageWheelDelta()
				hScroll:ScrollNext(nDistance)
			end
		    break
		end
	end
	return true	
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
